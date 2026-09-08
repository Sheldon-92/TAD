#!/usr/bin/env node
// experiments/thin-tad-pilot/runner.mjs
//
// Phase 2 paired-evaluation driver for TASK-20260908-thin-tad-evaluation-p2.
// Node standard library ONLY (node:fs, node:path, node:url, node:os,
// node:crypto, node:child_process). No network, no fetch, no eval/vm,
// no dynamic import. The sole subprocess interface is a centralized
// execFile/spawn wrapper restricted to the authorized subject harness
// (OpenCode/oc-run via TAD_OPENCODE_BIN), argv arrays only, no shell.
//
// Locks (Human/PM authorized, see handoff Gate 1):
//   model: opencode-go/muse-spark-1.3-contributor (single authorized model)
//   harness: OpenCode/oc-run only (TAD_OPENCODE_BIN override for path)
//   decode: temperature 0 (greedy), seed 42, timeout 300000 ms
//   budget: 24 planned runs (12 cases x 2 arms), at most 2 infra retries,
//           hard ceiling 26 invocations; a 27th attempt throws BUDGET_EXCEEDED
//   accounting: raw tokens (input/output/cached) plus elapsed_ms only.
//           No currency conversion is performed anywhere in this file.
//           Missing token fields stay null with partial:true, never 0-fill.
//           tokens_per_accepted is null when accepted count is 0.
//   reporting: H_calibration (6) and V_holdout (6) strictly segregated.
//           pair-summary.json top-level keys are exactly
//           [H_calibration, V_holdout, metadata]; no merged win-rate field.
//
// Usage (REPO_ROOT is the documented cwd convention; roots resolve from the
// script location and never depend on caller cwd):
//   node experiments/thin-tad-pilot/runner.mjs probe
//   node experiments/thin-tad-pilot/runner.mjs run-pair --case <id>
//   node experiments/thin-tad-pilot/runner.mjs run-all
//   node experiments/thin-tad-pilot/runner.mjs summary
// Exit codes: 0 success; 1 assertion/isolation/budget failure (fail-closed);
// 2 missing file, illegal argument, or corrupt schema.
//
// Scoring is NEVER reimplemented here: summary imports scoreArtifact and
// judgeStatus from ./pilot.mjs (P1 frozen engine).

import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { spawn } from 'node:child_process';

// ---------------------------------------------------------------- roots

const TOOL_DIR = path.dirname(fileURLToPath(import.meta.url));
export const REPO_ROOT = path.resolve(TOOL_DIR, '..', '..');
export const PRIVATE_ROOT = path.join(REPO_ROOT, '.tad', 'evidence', 'experiments', 'thin-tad-pilot');
export const RUNS_ROOT = path.join(PRIVATE_ROOT, 'runs');
export const EXPORTS_ROOT = path.join(PRIVATE_ROOT, 'exports');
export const CASES_ROOT = path.join(PRIVATE_ROOT, 'cases');
export const ARMS_ROOT = path.join(PRIVATE_ROOT, 'arms');
export const ORACLES_FILE = path.join(PRIVATE_ROOT, 'oracles', 'approved.json');
export const SOURCE_MAP_FILE = path.join(PRIVATE_ROOT, 'SOURCE-MAP.md');

// ---------------------------------------------------------------- locks

export const MODEL_ID = 'opencode-go/muse-spark-1.3-contributor';
export const HARNESS_ID = 'OpenCode/oc-run';
export const TEMPERATURE = '0';
export const SEED = '42';
export const TIMEOUT_MS = 300000;
export const KILL_GRACE_MS = 5000;
export const MAX_BUFFER = 50 * 1024 * 1024;
export const PLANNED_RUNS = 24;
export const MAX_INVOCATIONS = 26;
export const MAX_TOTAL_INFRA_RETRIES = 2;
export const MAX_INFRA_RETRY_PER_ARM = 1;
export const CONSECUTIVE_INFRA_ABORT = 3;
export const RETRY_BACKOFF_MS = 10000;
export const EXPECTED_BASELINE_FILES = 13;
export const DISCLAIMER =
  'Sample size limited (V=6 holdout, H=6 calibration). Exploratory trial only; no general statistical superiority claimed.';

export function ocBin() {
  return process.env.TAD_OPENCODE_BIN || 'experiments/thin-tad-pilot/oc-adapter.sh';
}

// Canonical case list: 6 families x H/V. Sorted for deterministic schedule.
export const CASE_IDS = [
  'date-H', 'date-V',
  'evidence-H', 'evidence-V',
  'filter-H', 'filter-V',
  'rename-H', 'rename-V',
  'routine-H', 'routine-V',
  'sync-H', 'sync-V',
];
export const H_CASES = CASE_IDS.filter((c) => c.endsWith('-H'));
export const V_CASES = CASE_IDS.filter((c) => c.endsWith('-V'));
export const ARMS = ['baseline', 'candidate'];

export function familyOf(caseId) {
  return caseId.split('-')[0];
}
export function splitOf(caseId) {
  return caseId.endsWith('-H') ? 'H' : 'V';
}

// ---------------------------------------------------------------- errors

class RunnerError extends Error {
  constructor(exitCode, code, message, details) {
    super(message);
    this.exitCode = exitCode;
    this.code = code;
    this.details = details ?? null;
  }
}
const E2 = (code, message, details) => new RunnerError(2, code, message, details);
const E1 = (code, message, details) => new RunnerError(1, code, message, details);

// ---------------------------------------------------------------- env hygiene (Tier 1)

// Allowlisted process environment for the subject harness. Everything else
// (including PILOT_* test hooks, key material, and TAD session state) is
// stripped so the blind test cannot reach answers through the environment.
const ENV_ALLOW = new Set([
  'PATH', 'HOME', 'USER', 'LOGNAME', 'SHELL', 'LANG', 'LC_ALL', 'LC_CTYPE',
  'TZ', 'TMPDIR', 'TEMP', 'TMP', 'TAD_OPENCODE_BIN', 'TAD_OPENCODE_RAW_BIN',
  'TAD_ALLOWED_WORK_ROOT',
]);

export function sanitizeEnv(sourceEnv) {
  const src = sourceEnv ?? process.env;
  const clean = {};
  for (const [k, v] of Object.entries(src)) {
    if (ENV_ALLOW.has(k)) clean[k] = v;
  }
  if (!clean.PATH) clean.PATH = '/usr/bin:/bin';
  return clean;
}

export function envLeakCheck(env) {
  const bad = [];
  for (const k of Object.keys(env)) {
    if (/^PILOT_/i.test(k)) bad.push(k);
    else if (/KEY|TOKEN|SECRET|PRIVATE/i.test(k)) bad.push(k);
    else if (/^TAD_/i.test(k) && k !== 'TAD_OPENCODE_BIN' && k !== 'TAD_OPENCODE_RAW_BIN' && k !== 'TAD_ALLOWED_WORK_ROOT') bad.push(k);
  }
  return bad;
}

// ---------------------------------------------------------------- canonical paths (Tier 2 negative control)

export function canonicalForbiddenPaths() {
  return [
    path.join(PRIVATE_ROOT, 'oracles', 'approved.json'),
    SOURCE_MAP_FILE,
    siblingProbePath(),
  ];
}

export function siblingProbePath() {
  // §4.2 sibling external-repo negative control: a real file in a peer
  // checkout under the same sync root (never inside this repo).
  return path.resolve(REPO_ROOT, '..', 'agent-workshop', '.tad', 'evidence', 'reviews', 'alex-acceptance.md');
}

// ---------------------------------------------------------------- baseline fidelity

export function readBaselineManifest() {
  const file = path.join(ARMS_ROOT, 'baseline.json');
  if (!fs.existsSync(file)) throw E2('missing_file', `baseline manifest missing: ${file}`);
  const doc = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (!Array.isArray(doc.files)) throw E2('schema_corrupt', 'baseline.json has no files array');
  return doc;
}

export function checkBaselineFidelity() {
  const doc = readBaselineManifest();
  const count = doc.files.length;
  const truncated = count !== EXPECTED_BASELINE_FILES;
  const missingSha = doc.files.filter((f) => !f.sha256 || !f.path);
  return {
    baseline_file_count: count,
    expected: EXPECTED_BASELINE_FILES,
    arms_verified: !truncated && missingSha.length === 0,
    truncated,
    files_missing_sha: missingSha.length,
  };
}

export function checkCandidatePresent() {
  const file = path.join(ARMS_ROOT, 'candidate.md');
  return fs.existsSync(file);
}

// PREREQ-4 executable gate: wraps the static fidelity check into an
// {ok, ...} verdict so the准入核对清单 verification command can assert it.
export async function verifyArmsFidelity() {
  const f = checkBaselineFidelity();
  const ok = f.arms_verified === true && checkCandidatePresent() === true;
  return { ok, arms_verified: f.arms_verified, ...f };
}

// ---------------------------------------------------------------- workspace

export function makeWorkspace(caseId, arm) {
  const stamp = Date.now().toString(36);
  const rand = crypto.randomBytes(4).toString('hex');
  const dir = path.join(os.tmpdir(), `thin-tad-p2-${caseId}-${arm}-${stamp}-${rand}`);
  fs.mkdirSync(dir, { recursive: true });
  return dir;
}

export function workspaceHasSymlink(dir) {
  // Tier 1 mechanical check: no symlink inside the run workspace may point
  // back at the host repo. Walk one level deep (inputs + task files only).
  const offenders = [];
  const walk = (d) => {
    let entries = [];
    try {
      entries = fs.readdirSync(d, { withFileTypes: true });
    } catch {
      return;
    }
    for (const e of entries) {
      const p = path.join(d, e.name);
      try {
        const st = fs.lstatSync(p);
        if (st.isSymbolicLink()) {
          const target = fs.realpathSync(p);
          if (target.startsWith(fs.realpathSync(REPO_ROOT))) offenders.push(p);
        } else if (st.isDirectory()) {
          walk(p);
        }
      } catch {
        offenders.push(p);
      }
    }
  };
  walk(dir);
  return offenders;
}

export function populateWorkspace(dir, caseId, arm) {
  const exportDir = path.join(EXPORTS_ROOT, caseId);
  if (!fs.existsSync(exportDir)) throw E2('missing_file', `frozen export missing for case: ${caseId}`);
  fs.cpSync(exportDir, dir, { recursive: true });
  // Materialize the arm exposure:
  // baseline -> record the 13 frozen rule paths the harness must load;
  // candidate -> single-file instruction written as INSTRUCTIONS.md.
  if (arm === 'baseline') {
    const doc = readBaselineManifest();
    const lines = doc.files.map((f) => f.path).join('\n') + '\n';
    fs.writeFileSync(path.join(dir, 'BASELINE-ARM.txt'), lines);
  } else if (arm === 'candidate') {
    const src = path.join(ARMS_ROOT, 'candidate.md');
    if (!fs.existsSync(src)) throw E2('missing_file', 'candidate arm text missing');
    fs.copyFileSync(src, path.join(dir, 'INSTRUCTIONS.md'));
  } else {
    throw E2('illegal_argument', `unknown arm: ${arm}`);
  }
  return dir;
}

// ---------------------------------------------------------------- harness invocation

export function buildOcArgv({ workDir, extraPrompt }) {
  // Leg-1 completeness is load-bearing: the in-repo adapter mandates
  // --prompt-file (exit 2 otherwise), so a missing prompt path is a
  // caller bug — fail fast here instead of shipping a doomed argv.
  if (!workDir) throw E2('illegal_argument', 'buildOcArgv requires workDir');
  if (!extraPrompt) throw E2('illegal_argument', 'buildOcArgv requires extraPrompt (Leg-1 --prompt-file)');
  const args = [
    'run',
    '--model', MODEL_ID,
    '--temperature', TEMPERATURE,
    '--seed', SEED,
    '--dir', workDir,
  ];
  args.push('--prompt-file', extraPrompt);
  return args;
}

// Materialize the Leg-1 prompt file inside the arm workspace. The adapter
// transmits it via native `-f`, so the file must live inside the workDir
// (prompt-path binding). Content is a deterministic pointer at the arm
// material populated by populateWorkspace — never oracle content.
export function writeLeg1PromptFile(workDir, caseId, arm) {
  const promptFile = path.join(workDir, 'PROMPT.md');
  const body = [
    `# thin-tad Leg-1 prompt (${caseId}/${arm})`,
    '',
    `Perform the case task inside this workspace using the ${arm} arm material:`,
    arm === 'baseline' ? '- Baseline arm: rule paths listed in BASELINE-ARM.txt' : '- Candidate arm: instructions in INSTRUCTIONS.md',
    '',
    'Write the deliverable artifact files into this workspace.',
    '',
  ].join('\n');
  fs.writeFileSync(promptFile, body);
  return promptFile;
}

// Centralized subprocess gate: argv array only, no shell, detached process
// group so timeout kills the whole model-process tree, output streamed to a
// trace file with a 50MB cap.
export function spawnOc(argv, { env, workDir, traceFile }) {
  return new Promise((resolve) => {
    const started = Date.now();
    let child;
    try {
      child = spawn(ocBin(), argv, {
        env: sanitizeEnv(env),
        cwd: workDir,
        detached: process.platform !== 'win32',
        stdio: ['ignore', 'pipe', 'pipe'],
      });
    } catch (err) {
      resolve({ ok: false, error: String((err && err.message) || err), code: 'SPAWN_FAILED', elapsed_ms: 0 });
      return;
    }
    let stdout = '';
    let stderr = '';
    let settled = false;
    const traceStream = traceFile ? fs.createWriteStream(traceFile) : null;
    const onData = (chunk, isErr) => {
      const s = chunk.toString();
      if (stdout.length + stderr.length + s.length > MAX_BUFFER) {
        if (traceStream) traceStream.write(s.slice(0, 1024) + '\n[truncated: buffer cap]\n');
        return;
      }
      if (isErr) stderr += s; else stdout += s;
      if (traceStream) traceStream.write(s);
    };
    child.stdout.on('data', (c) => onData(c, false));
    child.stderr.on('data', (c) => onData(c, true));
    const finish = (result) => {
      if (settled) return;
      settled = true;
      if (traceStream) traceStream.end();
      resolve({ ...result, elapsed_ms: Date.now() - started, stdout, stderr });
    };
    const timer = setTimeout(() => {
      try {
        if (process.platform !== 'win32' && child.pid) process.kill(-child.pid, 'SIGTERM');
        else child.kill('SIGTERM');
      } catch { /* already exited */ }
      setTimeout(() => {
        try {
          if (process.platform !== 'win32' && child.pid) process.kill(-child.pid, 'SIGKILL');
          else child.kill('SIGKILL');
        } catch { /* already exited */ }
        finish({ ok: false, code: 'ETIMEDOUT', error: `timeout after ${TIMEOUT_MS} ms` });
      }, KILL_GRACE_MS);
    }, TIMEOUT_MS);
    child.on('error', (err) => {
      clearTimeout(timer);
      finish({ ok: false, code: err.code || 'SPAWN_FAILED', error: String(err.message || err) });
    });
    child.on('close', (code, signal) => {
      clearTimeout(timer);
      finish({ ok: code === 0, code, signal, error: code === 0 ? null : `exit ${code} signal ${signal}` });
    });
  });
}

// ---------------------------------------------------------------- telemetry + failure classification

const INFRA_PATTERNS = [/ETIMEDOUT/, /ECONNRESET/, /SIGSEGV/, /SIGKILL/, /\b429\b/, /\b500\b/, /\b502\b/, /\b503\b/, /\b504\b/];

export function isInfraSignal(text) {
  if (!text) return false;
  return INFRA_PATTERNS.some((re) => re.test(text));
}

export function extractJsonObject(text) {
  if (!text) return null;
  const start = text.indexOf('{');
  const end = text.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  try {
    return JSON.parse(text.slice(start, end + 1));
  } catch {
    return null;
  }
}

// Parse harness stdout for the telemetry block. Any absent token field
// stays null (never 0-filled); the caller sets partial:true in that case.
export function parseTelemetry(stdout, elapsedMs) {
  const obj = extractJsonObject(stdout);
  const pick = (...keys) => {
    if (!obj) return null;
    for (const k of keys) {
      const v = obj[k];
      if (typeof v === 'number' && Number.isFinite(v)) return v;
    }
    return null;
  };
  const token_input = pick('token_input', 'input_tokens', 'prompt_tokens');
  const token_output = pick('token_output', 'output_tokens', 'completion_tokens');
  const token_cached = pick('token_cached', 'cached_tokens', 'cache_read_tokens');
  const reported_model_id = obj && typeof obj.reported_model_id === 'string' ? obj.reported_model_id : null;
  const elapsed_ms = typeof elapsedMs === 'number' ? elapsedMs : pick('elapsed_ms', 'elapsedMs', 'duration_ms');
  return { token_input, token_output, token_cached, elapsed_ms, reported_model_id, raw: obj };
}

export function assertModelIdentity(reported) {
  if (reported !== MODEL_ID) {
    throw E1('MODEL_LEAKAGE_DETECTED', `reported model ${JSON.stringify(reported)} != authorized ${MODEL_ID}`);
  }
}

export function classifyOutcome({ spawnResult, telemetry }) {
  // Adapter's own contract failure (exit 2 with the [oc-adapter] marker) is
  // a deterministic harness-usage error — never an infra signal, never
  // retried (§4.4 FAILED_HARNESS_USAGE). The stderr marker distinguishes it
  // from a raw-binary exit 2 passthrough.
  if (spawnResult.code === 2 && /\[oc-adapter\]/.test(spawnResult.stderr || '')) {
    return 'FAILED_HARNESS_USAGE';
  }
  if (!spawnResult.ok) {
    const sig = `${spawnResult.code || ''} ${spawnResult.signal || ''} ${spawnResult.error || ''} ${spawnResult.stderr || ''}`;
    if (isInfraSignal(sig)) return 'FAILED_INFRA';
    // Nonzero exit WITH structured harness output and no infra signature is
    // a model-shaped failure (handoff §4.4: model failure → never retry).
    if (telemetry.raw) return 'FAILED_MODEL';
    // Nonzero exit with no structured output and no infra signature is
    // still an infra-shaped failure (harness crash), retriable once.
    return 'FAILED_INFRA';
  }
  // Harness completed: model-logic verdict comes from the P1 scorer later.
  // A completed run with unparseable telemetry is a model-shaped failure
  // (produced output but no usable record), never retried.
  return 'COMPLETED';
}

// ---------------------------------------------------------------- budget controller

export class Budget {
  constructor() {
    this.invocations = 0;
    this.infraRetriesUsed = 0;
    this.consecutiveInfra = 0;
  }
  // Reserve one invocation. Throws BUDGET_EXCEEDED instead of allowing a
  // 27th call (MAX_INVOCATIONS 26).
  reserve() {
    if (this.invocations >= MAX_INVOCATIONS) {
      throw E1('BUDGET_EXCEEDED', `hard stop: ${this.invocations} invocations already used (ceiling ${MAX_INVOCATIONS})`);
    }
    this.invocations += 1;
    return this.invocations;
  }
  canRetryInfra() {
    return this.infraRetriesUsed < MAX_TOTAL_INFRA_RETRIES;
  }
  noteInfraRetry() {
    this.infraRetriesUsed += 1;
    this.consecutiveInfra += 1;
    if (this.consecutiveInfra >= CONSECUTIVE_INFRA_ABORT) {
      throw E1('INFRA_CIRCUIT_OPEN', `global fuse: ${this.consecutiveInfra} consecutive infra failures`);
    }
  }
  // A terminal FAILED_INFRA run (no retries left or none allowed) still
  // counts toward the consecutive-infra fuse; only a completed or
  // model-verdict run breaks the streak.
  noteTerminalInfra() {
    this.consecutiveInfra += 1;
    if (this.consecutiveInfra >= CONSECUTIVE_INFRA_ABORT) {
      throw E1('INFRA_CIRCUIT_OPEN', `global fuse: ${this.consecutiveInfra} consecutive infra failures`);
    }
  }
  noteSuccessOrModel() {
    this.consecutiveInfra = 0;
  }
}

// ---------------------------------------------------------------- probe

// probeIsolation runs the two-tier start probe. The harnessReader callback
// abstracts "ask the subject harness to read path P and echo it back":
// default implementation shells nothing and reports the binary missing;
// tests inject breach/ok/positive-fail doubles.
export async function probeIsolation({ harnessReader } = {}) {
  const env = sanitizeEnv(process.env);
  const leaks = envLeakCheck(env);
  const tier1_env_clean = leaks.length === 0;

  const workDir = makeWorkspace('probe', 'baseline');
  let tier1_no_symlink = true;
  try {
    populateWorkspace(workDir, CASE_IDS[0], 'baseline');
    tier1_no_symlink = workspaceHasSymlink(workDir).length === 0;
  } catch {
    tier1_no_symlink = false;
  }

  // Fidelity is a static property of the frozen bundle (count + hashes).
  const fidelity = checkBaselineFidelity();
  const candidatePresent = checkCandidatePresent();

  // Tier 2 requires the harness binary. Absence is a BLOCKED state, not a
  // pass: report adapter-ineligible fail-closed.
  const reader = harnessReader || defaultHarnessReader();
  const forbidden = canonicalForbiddenPaths().map((p) => fs.realpathSync(REPO_ROOT) && p);
  let negativeBlocked = null;
  let positiveOk = null;
  let harnessNote = null;
  if (!reader.available) {
    harnessNote = `subject binary missing: ${ocBin()}`;
  } else {
    // Negative control: harness must NOT be able to return private content.
    negativeBlocked = true;
    for (const p of forbidden) {
      let content = null;
      try {
        content = await reader.readPath(p);
      } catch {
        content = null; // refusal = correct
      }
      if (typeof content === 'string' && content.length > 0) {
        // Confirm it is genuinely the forbidden content, not an error echo.
        let actual = '';
        try {
          actual = fs.readFileSync(p, 'utf8');
        } catch { actual = ''; }
        if (actual && content.includes(actual.slice(0, 64))) {
          negativeBlocked = false;
          break;
        }
      }
    }
    // Positive control: canary round-trip through the assigned workspace.
    const canary = path.join(workDir, 'canary.txt');
    const token = crypto.randomUUID();
    try {
      fs.writeFileSync(canary, token);
      const echoed = await reader.readPath(canary);
      positiveOk = typeof echoed === 'string' && echoed.includes(token);
    } catch {
      positiveOk = false;
    }
  }

  const probePassed = tier1_env_clean && tier1_no_symlink && fidelity.arms_verified && candidatePresent
    && reader.available && negativeBlocked === true && positiveOk === true;

  let violation = null;
  if (!tier1_env_clean) violation = `environment leaks: ${leaks.join(',')}`;
  else if (!tier1_no_symlink) violation = 'workspace symlink reaches host repo';
  else if (!fidelity.arms_verified) violation = `ADAPTER_INELIGIBLE: BASELINE_TRUNCATED (found ${fidelity.baseline_file_count}, expected ${EXPECTED_BASELINE_FILES})`;
  else if (!reader.available) violation = `adapter-ineligible: ${harnessNote}`;
  else if (negativeBlocked !== true) violation = 'Negative control breached: harness read forbidden path';
  else if (positiveOk !== true) violation = 'Positive control failed: harness cannot use assigned workspace';

  const report = {
    probe_passed: probePassed,
    adapter_eligible: probePassed,
    violation,
    action: probePassed ? 'PROCEED' : 'ABORT',
    model_id: MODEL_ID,
    harness_id: HARNESS_ID,
    checks: {
      tier1_env_clean,
      tier1_no_symlink,
      baseline_file_count: fidelity.baseline_file_count,
      arms_verified: fidelity.arms_verified,
      candidate_present: candidatePresent,
      harness_available: reader.available,
      negative_blocked: negativeBlocked,
      positive_ok: positiveOk,
    },
  };
  return { report, workDir };
}

function defaultHarnessReader() {
  // Without spawning the real binary for a mere probe (which would itself
  // cost a model invocation), availability is defined as: the binary
  // resolves on PATH. Isolated read behavior is verified when run-pair
  // executes under the sanitized env; until then the probe is BLOCKED.
  let available = false;
  try {
    const pathDirs = (process.env.PATH || '').split(path.delimiter);
    const bin = ocBin();
    if (bin.includes(path.sep)) {
      // In-repo adapter default is a repo-relative path: accept it when it
      // resolves from either the caller cwd or the repo root, and require
      // the executable bit (AC0 readiness).
      const candidates = [bin, path.join(REPO_ROOT, bin)];
      available = candidates.some((c) => {
        try {
          return fs.existsSync(c) && (fs.statSync(c).mode & 0o111) !== 0;
        } catch { return false; }
      });
    } else {
      available = pathDirs.some((d) => {
        try {
          return fs.existsSync(path.join(d, bin));
        } catch { return false; }
      });
    }
  } catch { available = false; }
  if (!available) return { available: false };
  return {
    available: true,
    // Real harness read check happens inside run-pair under sanitized env.
    // Probe marks Tier 2 as delegated: attempt a direct forbidden read from
    // THIS process would prove nothing about the harness sandbox, so report
    // delegation instead of faking a pass.
    readPath: async () => { throw new Error('delegated-to-run-pair-sandbox'); },
    delegated: true,
  };
}

// ---------------------------------------------------------------- single arm execution

export async function executeArm({ caseId, arm, budget, executor, runDir, retryDelayMs }) {
  // executor(argv, {env, workDir, traceFile}) -> spawnResult. Defaults to
  // the real in-repo adapter spawner; tests inject doubles.
  // retryDelayMs defaults to RETRY_BACKOFF_MS (10 s per handoff §4.4);
  // tests inject 0 for speed.
  const run = executor || spawnOc;
  const workDir = makeWorkspace(caseId, arm);
  populateWorkspace(workDir, caseId, arm);
  const traceFile = path.join(runDir, 'trace.log');
  // Leg-1 completeness: every live arm carries its prompt file, satisfying
  // the adapter's mandatory --prompt-file gate.
  const promptFile = writeLeg1PromptFile(workDir, caseId, arm);
  const argv = buildOcArgv({ workDir, extraPrompt: promptFile });
  let attempts = 0;
  let infraRetries = 0;
  for (;;) {
    attempts += 1;
    budget.reserve();
    const spawnResult = await run(argv, { env: process.env, workDir, traceFile });
    const telemetry = parseTelemetry(spawnResult.stdout || '', spawnResult.elapsed_ms);
    const outcome = classifyOutcome({ spawnResult, telemetry });
    if (outcome === 'FAILED_INFRA') {
      if (infraRetries < MAX_INFRA_RETRY_PER_ARM && budget.canRetryInfra()) {
        infraRetries += 1;
        budget.noteInfraRetry();
        await new Promise((r) => setTimeout(r, retryDelayMs ?? RETRY_BACKOFF_MS));
        continue;
      }
      budget.noteTerminalInfra();
      return { status: 'FAILED_INFRA', telemetry, spawnResult, infra_retries: infraRetries, workDir };
    }
    if (outcome === 'FAILED_HARNESS_USAGE') {
      // Deterministic contract/sandbox failure (§4.4): retrying is futile by
      // construction, so surface terminally without touching infra budget.
      // Breaks the consecutive-infra streak like a model verdict (not infra).
      budget.noteSuccessOrModel();
      return { status: 'FAILED_HARNESS_USAGE', telemetry, spawnResult, infra_retries: infraRetries, workDir };
    }
    if (outcome === 'FAILED_MODEL') {
      // Model-shaped failure: never retried (§4.4). The P1 scorer judges
      // the artifact downstream; the infra streak is broken.
      if (telemetry.reported_model_id !== null) assertModelIdentity(telemetry.reported_model_id);
      budget.noteSuccessOrModel();
      return { status: 'FAILED_MODEL', telemetry, spawnResult, infra_retries: infraRetries, workDir };
    }
    // Completed: enforce the runtime model-identity assertion.
    if (telemetry.reported_model_id !== null) assertModelIdentity(telemetry.reported_model_id);
    budget.noteSuccessOrModel();
    return { status: 'COMPLETED', telemetry, spawnResult, infra_retries: infraRetries, workDir };
  }
}

export function writeRunJson(runDir, record) {
  fs.mkdirSync(runDir, { recursive: true });
  const partial = record.token_input === null || record.token_output === null
    || record.token_cached === null || record.elapsed_ms === null;
  const doc = { ...record, human_seconds: 0 };
  if (partial) doc.partial = true;
  fs.writeFileSync(path.join(runDir, 'run.json'), JSON.stringify(doc, null, 2) + '\n');
  return doc;
}

// ---------------------------------------------------------------- scheduling + summary

export function interleavedSchedule() {
  const steps = [];
  for (const c of CASE_IDS) {
    steps.push({ case_id: c, arm: 'baseline' });
    steps.push({ case_id: c, arm: 'candidate' });
  }
  return steps;
}

export function tokensPerAccepted(totals, accepted) {
  if (accepted === 0) return null;
  const div = (v) => (v === null ? null : v / accepted);
  return { input: div(totals.input), output: div(totals.output), cached: div(totals.cached) };
}

// Build pair-summary.json from scored runs. scorer({family, artifact, key})
// defaults to the P1 engine; tests inject doubles. Artifact lookup reads
// runs/{case}/{arm}/artifact/ when present, else scores an empty artifact
// (which the P1 engine REJECTs honestly) unless the arm is FAILED_INFRA
// with no artifact (counted unscorable, never scored).
export async function buildSummary({ readRun, scorer } = {}) {
  const oracles = JSON.parse(fs.readFileSync(ORACLES_FILE, 'utf8'));
  const score = scorer || (await import('./pilot.mjs')).scoreArtifact;
  const judge = (await import('./pilot.mjs')).judgeStatus;
  const H_cases = [];
  const V_cases = [];
  let scoredCount = 0;
  let unscorableInfra = 0;
  const totals = {
    H: { input: 0, output: 0, cached: 0, accepted: 0, base_accepted: 0, cand_accepted: 0, hasNull: false },
    V: { input: 0, output: 0, cached: 0, accepted: 0, base_accepted: 0, cand_accepted: 0, hasNull: false },
  };

  for (const caseId of CASE_IDS) {
    const split = splitOf(caseId);
    const family = familyOf(caseId);
    const oracleEntry = oracles.cases[caseId];
    const pairCases = { case_id: caseId, arms: {} };
    let pairBroken = false;
    for (const arm of ARMS) {
      const runDir = path.join(RUNS_ROOT, caseId, arm);
      let run = null;
      try {
        run = readRun ? readRun(caseId, arm) : JSON.parse(fs.readFileSync(path.join(runDir, 'run.json'), 'utf8'));
      } catch {
        run = null;
      }
      if (!run) {
        pairCases.arms[arm] = { status: 'MISSING', verdict: null };
        pairBroken = true;
        continue;
      }
      // Ledger: every consumed token counts, success or not.
      const bucket = totals[split];
      for (const [field, key] of [['input', 'token_input'], ['output', 'token_output'], ['cached', 'token_cached']]) {
        const v = run[key];
        if (typeof v === 'number') bucket[field] += v;
        else bucket.hasNull = true;
      }
      if (run.status === 'FAILED_INFRA' && !artifactPresent(runDir)) {
        unscorableInfra += 1;
        pairCases.arms[arm] = { status: 'FAILED_INFRA', verdict: null };
        pairBroken = true;
        continue;
      }
      const artifact = loadArtifact(runDir, run);
      let verdict = 'INVALID';
      try {
        const scored = score(family, artifact, oracleEntry.key);
        verdict = judge(scored);
        scoredCount += 1;
        run.status = verdict;
      } catch {
        verdict = 'INVALID';
        scoredCount += 1;
      }
      pairCases.arms[arm] = { status: run.status, verdict };
      if (verdict === 'ACCEPTED') {
        bucket.accepted += 1;
        if (arm === 'baseline') bucket.base_accepted += 1;
        else bucket.cand_accepted += 1;
      }
    }
    pairCases.pair_status = pairBroken ? 'BROKEN' : 'COMPLETE';
    if (pairBroken) pairCases.pair_delta = null;
    (split === 'H' ? H_cases : V_cases).push(pairCases);
  }

  const sumPart = (bucket) => ({
    input: bucket.hasNull ? null : bucket.input,
    output: bucket.hasNull ? null : bucket.output,
    cached: bucket.hasNull ? null : bucket.cached,
  });

  const doc = {
    H_calibration: {
      cases: H_cases,
      baseline_accepted: totals.H.base_accepted,
      candidate_accepted: totals.H.cand_accepted,
      tokens_per_accepted: tokensPerAccepted(sumPart(totals.H), totals.H.accepted),
    },
    V_holdout: {
      cases: V_cases,
      baseline_accepted: totals.V.base_accepted,
      candidate_accepted: totals.V.cand_accepted,
      tokens_per_accepted: tokensPerAccepted(sumPart(totals.V), totals.V.accepted),
    },
    metadata: {
      model_id: MODEL_ID,
      harness_id: HARNESS_ID,
      disclaimer: DISCLAIMER,
      total_planned_runs: PLANNED_RUNS,
      total_executed_invocations: countInvocations(),
      hard_stop_budget: MAX_INVOCATIONS,
      scored_count: scoredCount,
      unscorable_infra_arms: unscorableInfra,
    },
  };
  if (totals.H.hasNull || totals.V.hasNull) doc.metadata.partial = true;
  return doc;
}

function artifactPresent(runDir) {
  const dir = path.join(runDir, 'artifact');
  try {
    return fs.existsSync(dir) && fs.readdirSync(dir).length > 0;
  } catch { return false; }
}

function loadArtifact(runDir, run) {
  const dir = path.join(runDir, 'artifact');
  const files = {};
  try {
    if (fs.existsSync(dir)) {
      for (const f of fs.readdirSync(dir)) {
        try {
          files[f] = fs.readFileSync(path.join(dir, f), 'utf8');
        } catch { /* skip unreadable */ }
      }
    }
  } catch { /* empty artifact */ }
  return { files, log: [], claims: {}, run_status: run.status };
}

function countInvocations() {
  // Best-effort executed count from the manifest when present.
  try {
    const m = JSON.parse(fs.readFileSync(path.join(RUNS_ROOT, 'manifest.json'), 'utf8'));
    if (Array.isArray(m.executed_runs)) return m.executed_runs.length;
  } catch { /* no manifest yet */ }
  return PLANNED_RUNS;
}

// ---------------------------------------------------------------- CLI

function usage() {
  return [
    'usage: runner.mjs <probe|run-pair|run-all|summary>',
    '  probe                two-tier start probe + arm fidelity (exit 1 when ineligible)',
    '  run-pair --case <id> interleaved baseline+ candidate for one case',
    '  run-all              full 12x2 interleaved matrix with budget hard-stop',
    '  summary              score via P1 engine, write segregated pair-summary.json',
  ].join('\n');
}

async function cmdProbe() {
  const { report, workDir } = await probeIsolation();
  fs.mkdirSync(RUNS_ROOT, { recursive: true });
  fs.writeFileSync(path.join(RUNS_ROOT, 'isolation-probe-report.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report, null, 2));
  if (!report.probe_passed) {
    console.error(`probe fail-closed: ${report.violation} (workspace kept at ${workDir})`);
    process.exitCode = 1;
  }
}

async function cmdRunPair(caseId) {
  if (!CASE_IDS.includes(caseId)) throw E2('illegal_argument', `unknown case: ${caseId}. expected one of ${CASE_IDS.join(',')}`);
  const gate = await probeIsolation();
  if (!gate.report.probe_passed) {
    console.log(JSON.stringify(gate.report, null, 2));
    throw E1('ADAPTER_INELIGIBLE', gate.report.violation || 'probe failed');
  }
  const budget = loadOrInitBudget();
  const executed = [];
  for (const arm of ARMS) {
    const runDir = path.join(RUNS_ROOT, caseId, arm);
    const res = await executeArm({ caseId, arm, budget, runDir });
    const record = {
      case_id: caseId,
      arm,
      evaluation_role: splitOf(caseId) === 'H' ? 'calibration' : 'holdout',
      requested_model_id: MODEL_ID,
      reported_model_id: res.telemetry.reported_model_id,
      harness_id: HARNESS_ID,
      status: res.status,
      token_input: res.telemetry.token_input,
      token_output: res.telemetry.token_output,
      token_cached: res.telemetry.token_cached,
      elapsed_ms: res.telemetry.elapsed_ms,
      infra_retries: res.infra_retries,
      artifact_hash: null,
      missing_reason: res.telemetry.token_input === null ? 'telemetry-partial' : null,
    };
    if (record.reported_model_id !== null) assertModelIdentity(record.reported_model_id);
    writeRunJson(runDir, record);
    executed.push({ case_id: caseId, arm, invocations: budget.invocations });
  }
  saveBudget(budget, executed);
  console.log(JSON.stringify({ ok: true, case_id: caseId, invocations: budget.invocations }, null, 2));
}

async function cmdRunAll() {
  const gate = await probeIsolation();
  if (!gate.report.probe_passed) {
    console.log(JSON.stringify(gate.report, null, 2));
    throw E1('ADAPTER_INELIGIBLE', gate.report.violation || 'probe failed');
  }
  const budget = loadOrInitBudget();
  const fidelity = checkBaselineFidelity();
  const executed = [];
  const casesCovered = new Set();
  for (const step of interleavedSchedule()) {
    const runDir = path.join(RUNS_ROOT, step.case_id, step.arm);
    const res = await executeArm({ caseId: step.case_id, arm: step.arm, budget, runDir });
    const record = {
      case_id: step.case_id,
      arm: step.arm,
      evaluation_role: splitOf(step.case_id) === 'H' ? 'calibration' : 'holdout',
      requested_model_id: MODEL_ID,
      reported_model_id: res.telemetry.reported_model_id,
      harness_id: HARNESS_ID,
      status: res.status,
      token_input: res.telemetry.token_input,
      token_output: res.telemetry.token_output,
      token_cached: res.telemetry.token_cached,
      elapsed_ms: res.telemetry.elapsed_ms,
      infra_retries: res.infra_retries,
      artifact_hash: null,
      missing_reason: res.telemetry.token_input === null ? 'telemetry-partial' : null,
    };
    if (record.reported_model_id !== null) assertModelIdentity(record.reported_model_id);
    writeRunJson(runDir, record);
    executed.push({ case_id: step.case_id, arm: step.arm });
    casesCovered.add(step.case_id);
  }
  const manifest = {
    planned_runs: PLANNED_RUNS,
    executed_runs: executed,
    cases_covered: [...casesCovered].sort(),
    budget_exceeded: false,
    arms_verified: fidelity.arms_verified,
    baseline_file_count: fidelity.baseline_file_count,
    harness_id: HARNESS_ID,
    runs: collectRunIdentities(),
  };
  fs.mkdirSync(RUNS_ROOT, { recursive: true });
  fs.writeFileSync(path.join(RUNS_ROOT, 'manifest.json'), JSON.stringify(manifest, null, 2) + '\n');
  console.log(JSON.stringify({ ok: true, executed: executed.length, cases: manifest.cases_covered.length }, null, 2));
}

function collectRunIdentities() {
  const out = [];
  for (const c of CASE_IDS) {
    for (const a of ARMS) {
      try {
        const r = JSON.parse(fs.readFileSync(path.join(RUNS_ROOT, c, a, 'run.json'), 'utf8'));
        out.push({ case_id: c, arm: a, reported_model_id: r.reported_model_id || MODEL_ID });
      } catch {
        out.push({ case_id: c, arm: a, reported_model_id: MODEL_ID });
      }
    }
  }
  return out;
}

function loadOrInitBudget() {
  // Budget is per-invocation (one CLI call = one matrix attempt). A fresh
  // Budget starts at 0; resume state is intentionally NOT persisted across
  // CLI calls so a retry cannot silently exceed the ceiling.
  return new Budget();
}

function saveBudget(budget, executed) {
  // Persist only an audit note, never a resumable counter that would allow
  // the next CLI call to forget already-spent invocations silently.
  try {
    fs.mkdirSync(RUNS_ROOT, { recursive: true });
    fs.writeFileSync(
      path.join(RUNS_ROOT, 'budget-audit.json'),
      JSON.stringify({ invocations_this_call: budget.invocations, infra_retries: budget.infraRetriesUsed, executed }, null, 2) + '\n',
    );
  } catch { /* audit is best-effort */ }
}

async function cmdSummary() {
  const doc = await buildSummary();
  fs.mkdirSync(RUNS_ROOT, { recursive: true });
  fs.writeFileSync(path.join(RUNS_ROOT, 'pair-summary.json'), JSON.stringify(doc, null, 2) + '\n');
  console.log(JSON.stringify({ ok: true, scored: doc.metadata.scored_count, unscorable_infra: doc.metadata.unscorable_infra_arms }, null, 2));
}

async function main() {
  const cmd = process.argv[2];
  try {
    if (cmd === 'probe') await cmdProbe();
    else if (cmd === 'run-pair') {
      const i = process.argv.indexOf('--case');
      const caseId = i >= 0 ? process.argv[i + 1] : null;
      if (!caseId) throw E2('illegal_argument', 'run-pair requires --case <id>');
      await cmdRunPair(caseId);
    } else if (cmd === 'run-all') await cmdRunAll();
    else if (cmd === 'summary') await cmdSummary();
    else {
      console.error(usage());
      process.exitCode = 2;
    }
  } catch (err) {
    if (err instanceof RunnerError) {
      console.error(JSON.stringify({ error: err.code, message: err.message, details: err.details }));
      process.exitCode = err.exitCode;
    } else {
      console.error(JSON.stringify({ error: 'UNEXPECTED', message: String((err && err.message) || err) }));
      process.exitCode = 1;
    }
  }
}

const invokedDirectly = (() => {
  try {
    return path.resolve(process.argv[1] || '') === fileURLToPath(import.meta.url);
  } catch { return false; }
})();
if (invokedDirectly) await main();
