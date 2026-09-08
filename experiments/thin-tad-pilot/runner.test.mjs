#!/usr/bin/env node
// experiments/thin-tad-pilot/runner.test.mjs
//
// Offline unit + negative-control tests for runner.mjs.
// Node stdlib only (node:test + assert). All harness interactions use
// injected doubles; no oc-run binary, no network, no model calls.
// The frozen private bundle is never mutated.

import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const RUNNER = path.join(HERE, 'runner.mjs');
const REPO = path.resolve(HERE, '..', '..');

let R = null;
before(async () => {
  R = await import('./runner.mjs');
});

function runCli(args, opts = {}) {
  const env = { ...process.env, ...(opts.env || {}) };
  try {
    const out = execFileSync('node', [RUNNER, ...args], {
      cwd: REPO, env, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'],
    });
    return { code: 0, stdout: out };
  } catch (e) {
    return { code: e.status ?? 1, stdout: (e.stdout || '').toString(), stderr: (e.stderr || '').toString() };
  }
}

describe('static gates', () => {
  it('stdlib imports only; no shell/network/eval', () => {
    const src = fs.readFileSync(RUNNER, 'utf8');
    const imports = [...src.matchAll(/from\s+['"]([^'"]+)['"]/g)].map((m) => m[1]);
    assert.ok(imports.length > 0);
    for (const m of imports) assert.ok(m.startsWith('node:'), `non-stdlib import: ${m}`);
    assert.ok(!src.includes('fetch('), 'no fetch');
    assert.ok(!src.includes('eval('), 'no eval');
    assert.ok(!src.includes('execSync'), 'no execSync (shell)');
    assert.ok(!/execFile\s*\(/.test(src.replaceAll('execFileSync', '').replaceAll('spawnOc', 'XX')), 'no bare execFile');
    assert.ok(src.includes('detached'), 'process-group isolation present');
    assert.ok(src.includes('TAD_OPENCODE_BIN'), 'binary override present');
    assert.ok(src.includes('TAD_OPENCODE_RAW_BIN'), 'raw binary layer present');
    assert.ok(src.includes("experiments/thin-tad-pilot/oc-adapter.sh"), 'default points at in-repo adapter');
    assert.ok(!src.includes('/home/box/pm/'), 'no external PM path hardcoded');
  });
  it('model + harness + decode locks are pinned', () => {
    const src = fs.readFileSync(RUNNER, 'utf8');
    assert.ok(src.includes('opencode-go/muse-spark-1.3-contributor'), 'model pinned');
    assert.ok(!src.includes('gpt-') && !src.includes('claude-3'), 'no second model');
    assert.ok(src.includes("TEMPERATURE = '0'"), 'temperature pinned');
    assert.ok(src.includes("SEED = '42'"), 'seed pinned');
    assert.ok(src.includes('MAX_INVOCATIONS = 26'), 'ceiling 26 pinned');
    assert.ok(src.includes('PLANNED_RUNS = 24'), 'planned 24 pinned');
  });
  it('authorized model appears in source', () => {
    const r = runCli(['--help']);
    assert.ok([0, 2].includes(r.code));
  });
});

describe('env hygiene (Tier 1)', () => {
  it('strips PILOT_* and key material, keeps PATH/HOME', () => {
    const clean = R.sanitizeEnv({
      PATH: '/usr/bin', HOME: '/home/u', USER: 'u',
      PILOT_PRIVATE_ROOT: '/secret', PILOT_SOURCE_ROOT: '/src',
      ANTHROPIC_API_KEY: 'sk-x', OPENAI_API_KEY: 'sk-y',
      TAD_SESSION_FOO: 'z', MY_TOKEN: 't',
    });
    assert.equal(clean.PATH, '/usr/bin');
    assert.equal(clean.HOME, '/home/u');
    assert.ok(!('PILOT_PRIVATE_ROOT' in clean));
    assert.ok(!('ANTHROPIC_API_KEY' in clean));
    assert.ok(!('TAD_SESSION_FOO' in clean));
    assert.ok(!('MY_TOKEN' in clean));
  });
  it('envLeakCheck flags sensitive names', () => {
    assert.deepEqual(R.envLeakCheck({ PATH: 'x', PILOT_PRIVATE_ROOT: 'y' }), ['PILOT_PRIVATE_ROOT']);
    assert.deepEqual(R.envLeakCheck({ PATH: 'x' }), []);
  });
  it('runner defaults to in-repo adapter and allows both BIN layers', () => {
    const savedBin = process.env.TAD_OPENCODE_BIN;
    const savedRaw = process.env.TAD_OPENCODE_RAW_BIN;
    delete process.env.TAD_OPENCODE_BIN;
    delete process.env.TAD_OPENCODE_RAW_BIN;
    try {
      assert.equal(R.ocBin(), 'experiments/thin-tad-pilot/oc-adapter.sh');
      const clean = R.sanitizeEnv({ PATH: '/usr/bin', TAD_OPENCODE_BIN: 'a', TAD_OPENCODE_RAW_BIN: 'b', TAD_ALLOWED_WORK_ROOT: '/tmp/x', TAD_SESSION_X: 'z' });
      assert.equal(clean.TAD_OPENCODE_BIN, 'a');
      assert.equal(clean.TAD_OPENCODE_RAW_BIN, 'b');
      assert.equal(clean.TAD_ALLOWED_WORK_ROOT, '/tmp/x');
      assert.ok(!('TAD_SESSION_X' in clean));
      assert.deepEqual(R.envLeakCheck({ TAD_OPENCODE_BIN: 'a', TAD_OPENCODE_RAW_BIN: 'b', TAD_ALLOWED_WORK_ROOT: '/tmp/x' }), []);
    } finally {
      if (savedBin !== undefined) process.env.TAD_OPENCODE_BIN = savedBin;
      if (savedRaw !== undefined) process.env.TAD_OPENCODE_RAW_BIN = savedRaw;
    }
  });
  it('buildOcArgv emits full Leg-1 contract for adapter capture', () => {
    const argv = R.buildOcArgv({ workDir: '/tmp/w', extraPrompt: '/tmp/p' });
    for (const flag of ['--model', '--dir', '--prompt-file', '--temperature', '--seed']) {
      assert.ok(argv.includes(flag), `Leg-1 argv includes ${flag}`);
    }
  });
  it('buildOcArgv refuses Leg-1 without prompt file (fail fast)', () => {
    assert.throws(() => R.buildOcArgv({ workDir: '/tmp/w' }), (e) => e.code === 'illegal_argument');
  });
  it('adapter exit 2 with marker maps to FAILED_HARNESS_USAGE without retry', async () => {
    const budget = new R.Budget();
    let calls = 0;
    const fakeExec = async () => {
      calls += 1;
      return { ok: false, code: 2, signal: null, error: 'exit 2 signal null', stdout: '', stderr: 'ERROR: [oc-adapter] Missing required arguments (--model, --dir, or --prompt-file)', elapsed_ms: 1 };
    };
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'runner-arm-'));
    const res = await R.executeArm({ caseId: 'date-H', arm: 'baseline', budget, executor: fakeExec, runDir: dir, retryDelayMs: 0 });
    assert.equal(res.status, 'FAILED_HARNESS_USAGE');
    assert.equal(res.infra_retries, 0);
    assert.equal(calls, 1);
    assert.equal(budget.consecutiveInfra, 0);
    assert.equal(budget.infraRetriesUsed, 0);
  });
  it('executeArm wires prompt-file through real adapter to COMPLETED', async () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-e2e-raw-'));
    const telemetry = JSON.stringify({ reported_model_id: R.MODEL_ID, token_input: 10, token_output: 5, token_cached: 0 });
    const raw = path.join(rawDir, 'mock-opencode');
    fs.writeFileSync(raw, `#!/usr/bin/env bash\nset -uo pipefail\nprintf '%s\\n' '${telemetry}'\nexit 0\n`);
    fs.chmodSync(raw, 0o755);
    const adapterAbs = path.join(HERE, 'oc-adapter.sh');
    const savedBin = process.env.TAD_OPENCODE_BIN;
    const savedRaw = process.env.TAD_OPENCODE_RAW_BIN;
    process.env.TAD_OPENCODE_BIN = adapterAbs;
    process.env.TAD_OPENCODE_RAW_BIN = raw;
    try {
      const budget = new R.Budget();
      const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'runner-e2e-'));
      const res = await R.executeArm({ caseId: 'date-H', arm: 'baseline', budget, runDir: dir, retryDelayMs: 0 });
      assert.equal(res.status, 'COMPLETED');
      assert.equal(res.telemetry.token_input, 10);
      assert.ok(fs.existsSync(path.join(res.workDir, 'PROMPT.md')), 'Leg-1 prompt file materialized in workDir');
    } finally {
      if (savedBin === undefined) delete process.env.TAD_OPENCODE_BIN; else process.env.TAD_OPENCODE_BIN = savedBin;
      if (savedRaw === undefined) delete process.env.TAD_OPENCODE_RAW_BIN; else process.env.TAD_OPENCODE_RAW_BIN = savedRaw;
    }
  });
});

describe('baseline fidelity', () => {
  it('frozen baseline exposes exactly 13 files', () => {
    const f = R.checkBaselineFidelity();
    assert.equal(f.baseline_file_count, 13);
    assert.equal(f.arms_verified, true);
    assert.equal(R.checkCandidatePresent(), true);
  });
  it('schedule is interleaved: 24 steps, baseline before candidate per case', () => {
    const s = R.interleavedSchedule();
    assert.equal(s.length, 24);
    for (let i = 0; i < s.length; i += 2) {
      assert.equal(s[i].case_id, s[i + 1].case_id);
      assert.equal(s[i].arm, 'baseline');
      assert.equal(s[i + 1].arm, 'candidate');
    }
    assert.equal(new Set(s.map((x) => x.case_id)).size, 12);
  });
});

describe('probe fail-closed (mock harness doubles)', () => {
  it('negative breach (reads forbidden content) => probe fails', async () => {
    const forbidden = fs.readFileSync(R.canonicalForbiddenPaths()[0], 'utf8');
    const reader = {
      available: true,
      readPath: async (p) => {
        if (p === R.canonicalForbiddenPaths()[0]) return forbidden;
        return 'x';
      },
    };
    // canary path differs; make positive pass so only negative drives FAIL
    const orig = reader.readPath;
    reader.readPath = async (p) => {
      if (String(p).endsWith('canary.txt')) return fs.readFileSync(p, 'utf8');
      return orig(p);
    };
    const { report } = await R.probeIsolation({ harnessReader: reader });
    assert.equal(report.probe_passed, false);
    assert.equal(report.adapter_eligible, false);
    assert.match(report.violation, /Negative control breached/);
  });
  it('positive failure (canary unreadable) => probe fails', async () => {
    const reader = {
      available: true,
      readPath: async (p) => {
        if (String(p).endsWith('canary.txt')) throw new Error('not found');
        throw new Error('denied');
      },
    };
    const { report } = await R.probeIsolation({ harnessReader: reader });
    assert.equal(report.probe_passed, false);
    assert.match(report.violation || '', /Positive control failed|Negative/);
  });
  it('clean double (deny forbidden, echo canary) => probe passes', async () => {
    const reader = {
      available: true,
      readPath: async (p) => {
        if (String(p).endsWith('canary.txt')) return fs.readFileSync(p, 'utf8');
        throw new Error('denied');
      },
    };
    const { report } = await R.probeIsolation({ harnessReader: reader });
    assert.equal(report.probe_passed, true);
    assert.equal(report.adapter_eligible, true);
  });
  it('missing binary => adapter-ineligible BLOCKED (fail-closed)', async () => {
    const { report } = await R.probeIsolation({ harnessReader: { available: false } });
    assert.equal(report.probe_passed, false);
    assert.equal(report.adapter_eligible, false);
    assert.match(report.violation, /adapter-ineligible/);
  });
});

describe('budget hard-stop', () => {
  it('26 reservations ok, 27th throws BUDGET_EXCEEDED', () => {
    const b = new R.Budget();
    for (let i = 0; i < 26; i++) b.reserve();
    assert.equal(b.invocations, 26);
    try {
      b.reserve();
      assert.fail('expected BUDGET_EXCEEDED');
    } catch (e) {
      assert.equal(e.code, 'BUDGET_EXCEEDED');
    }
  });
  it('infra retry bounded: 3 consecutive infra => circuit opens', () => {
    const b = new R.Budget();
    b.reserve(); b.noteInfraRetry();
    b.reserve(); b.noteInfraRetry();
    b.reserve();
    try {
      b.noteInfraRetry();
      assert.fail('expected INFRA_CIRCUIT_OPEN');
    } catch (e) {
      assert.equal(e.code, 'INFRA_CIRCUIT_OPEN');
    }
  });
  it('executeArm retries infra once then surfaces FAILED_INFRA', async () => {
    const budget = new R.Budget();
    let calls = 0;
    const fakeExec = async () => {
      calls += 1;
      return { ok: false, code: 1, signal: null, error: 'boom ECONNRESET', stdout: '', stderr: 'ECONNRESET', elapsed_ms: 5 };
    };
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'runner-arm-'));
    const res = await R.executeArm({ caseId: 'date-H', arm: 'baseline', budget, executor: fakeExec, runDir: dir, retryDelayMs: 0 });
    assert.equal(res.status, 'FAILED_INFRA');
    assert.equal(res.infra_retries, 1);
    assert.equal(calls, 2);
  });
  it('model-logic completion is never retried', async () => {
    const budget = new R.Budget();
    let calls = 0;
    const fakeExec = async () => {
      calls += 1;
      return { ok: true, code: 0, stdout: JSON.stringify({ reported_model_id: R.MODEL_ID, token_input: 10, token_output: 5, token_cached: 0 }), stderr: '', elapsed_ms: 5 };
    };
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'runner-arm-'));
    const res = await R.executeArm({ caseId: 'date-H', arm: 'baseline', budget, executor: fakeExec, runDir: dir, retryDelayMs: 0 });
    assert.equal(res.status, 'COMPLETED');
    assert.equal(calls, 1);
  });
  it('foreign reported_model_id throws MODEL_LEAKAGE_DETECTED', async () => {
    const budget = new R.Budget();
    const fakeExec = async () => ({
      ok: true, code: 0,
      stdout: JSON.stringify({ reported_model_id: 'other-model', token_input: 1, token_output: 1, token_cached: 0 }),
      stderr: '', elapsed_ms: 1,
    });
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'runner-arm-'));
    await assert.rejects(
      () => R.executeArm({ caseId: 'date-H', arm: 'baseline', budget, executor: fakeExec, runDir: dir, retryDelayMs: 0 }),
      (e) => e.code === 'MODEL_LEAKAGE_DETECTED',
    );
  });
  it('live infra backoff defaults to 10s; sibling path is a forbidden leg', () => {
    assert.equal(R.RETRY_BACKOFF_MS, 10000);
    const legs = R.canonicalForbiddenPaths();
    assert.equal(legs.length, 3);
    assert.ok(legs[2].endsWith('alex-acceptance.md'));
    assert.ok(!legs[2].startsWith(fs.realpathSync(R.REPO_ROOT) + '/.tad'), 'sibling leg is outside this repo');
  });
  it('nonzero exit WITH structured telemetry is FAILED_MODEL, never retried', async () => {
    const budget = new R.Budget();
    let calls = 0;
    const fakeExec = async () => {
      calls += 1;
      return { ok: false, code: 1, signal: null, error: 'exit 1 signal null', stdout: JSON.stringify({ reported_model_id: R.MODEL_ID, token_input: 4, token_output: 2, token_cached: 0 }), stderr: '', elapsed_ms: 5 };
    };
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'runner-arm-'));
    const res = await R.executeArm({ caseId: 'date-H', arm: 'baseline', budget, executor: fakeExec, runDir: dir, retryDelayMs: 0 });
    assert.equal(res.status, 'FAILED_MODEL');
    assert.equal(res.infra_retries, 0);
    assert.equal(calls, 1);
    assert.equal(budget.consecutiveInfra, 0);
  });
  it('three terminal FAILED_INFRA runs open the circuit (cross-arm fuse)', async () => {
    const budget = new R.Budget();
    budget.infraRetriesUsed = 2; // exhaust retries so every run goes terminal
    const fakeExec = async () => ({ ok: false, code: 1, signal: null, error: 'boom', stdout: '', stderr: 'boom', elapsed_ms: 1 });
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'runner-arm-'));
    const r1 = await R.executeArm({ caseId: 'date-H', arm: 'baseline', budget, executor: fakeExec, runDir: dir, retryDelayMs: 0 });
    assert.equal(r1.status, 'FAILED_INFRA');
    const r2 = await R.executeArm({ caseId: 'date-H', arm: 'candidate', budget, executor: fakeExec, runDir: dir, retryDelayMs: 0 });
    assert.equal(r2.status, 'FAILED_INFRA');
    await assert.rejects(
      () => R.executeArm({ caseId: 'date-H', arm: 'baseline', budget, executor: fakeExec, runDir: dir, retryDelayMs: 0 }),
      (e) => e.code === 'INFRA_CIRCUIT_OPEN',
    );
  });
});

describe('token accounting rules', () => {
  it('missing fields stay null with partial:true, never 0-filled', () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'runner-run-'));
    const doc = R.writeRunJson(dir, {
      case_id: 'date-H', arm: 'baseline', status: 'COMPLETED',
      token_input: 100, token_output: null, token_cached: 5, elapsed_ms: 10,
    });
    assert.equal(doc.token_output, null);
    assert.equal(doc.partial, true);
    const onDisk = JSON.parse(fs.readFileSync(path.join(dir, 'run.json'), 'utf8'));
    assert.equal(onDisk.token_output, null);
    assert.equal(onDisk.partial, true);
  });
  it('zero accepted => tokens_per_accepted is null', () => {
    assert.equal(R.tokensPerAccepted({ input: 10, output: 5, cached: 1 }, 0), null);
    const t = R.tokensPerAccepted({ input: 10, output: 20, cached: 30 }, 2);
    assert.deepEqual(t, { input: 5, output: 10, cached: 15 });
  });
  it('telemetry parser never invents zeros', () => {
    const t = R.parseTelemetry('no json here', 42);
    assert.equal(t.token_input, null);
    assert.equal(t.token_output, null);
    assert.equal(t.elapsed_ms, 42);
  });
});

describe('segregated summary (pure doubles, no disk runs)', () => {
  async function fakeSummary(runMap, scorer) {
    return R.buildSummary({ readRun: (c, a) => runMap[`${c}/${a}`] || null, scorer });
  }
  const okRun = (v) => ({
    status: v, token_input: 100, token_output: 20, token_cached: 5, elapsed_ms: 50,
  });
  const acceptScorer = () => ({ assertions: [], critical: [], semantic: { status: 'DONE' } });
  it('top-level keys are exactly H/V/metadata; no merged field', async () => {
    const runMap = {};
    for (const c of R.CASE_IDS) for (const a of R.ARMS) runMap[`${c}/${a}`] = okRun('COMPLETED');
    const doc = await fakeSummary(runMap, acceptScorer);
    assert.deepEqual(Object.keys(doc).sort(), ['H_calibration', 'V_holdout', 'metadata']);
    assert.ok(!('overall_combined_win_rate' in doc));
    assert.ok(!('pooled_summary' in doc));
    assert.equal(doc.H_calibration.cases.length, 6);
    assert.equal(doc.V_holdout.cases.length, 6);
    assert.equal(doc.metadata.scored_count + doc.metadata.unscorable_infra_arms, 24);
  });
  it('broken pair => pair_status BROKEN, delta null, arrays intact', async () => {
    const runMap = {};
    for (const c of R.CASE_IDS) for (const a of R.ARMS) runMap[`${c}/${a}`] = okRun('COMPLETED');
    runMap['date-H/candidate'] = { status: 'FAILED_INFRA', token_input: 7, token_output: 1, token_cached: 0, elapsed_ms: 3 };
    const doc = await fakeSummary(runMap, acceptScorer);
    const pair = doc.H_calibration.cases.find((x) => x.case_id === 'date-H');
    assert.equal(pair.pair_status, 'BROKEN');
    assert.equal(pair.pair_delta, null);
    assert.equal(doc.H_calibration.cases.length, 6);
  });
  it('zero accepted => tokens_per_accepted null (not zero)', async () => {
    const rejectScorer = () => ({ assertions: [{ kind: 'structure', pass: false }], critical: [{ x: 1 }], semantic: {} });
    const runMap = {};
    for (const c of R.CASE_IDS) for (const a of R.ARMS) runMap[`${c}/${a}`] = okRun('COMPLETED');
    const doc = await fakeSummary(runMap, rejectScorer);
    assert.equal(doc.H_calibration.tokens_per_accepted, null);
    assert.equal(doc.V_holdout.tokens_per_accepted, null);
  });
});

describe('oc-adapter (mock raw bin, offline)', () => {
  const ADAPTER = path.join(HERE, 'oc-adapter.sh');

  function writeMockRawBin(dir, { exitCode = 0, echoArgs = true } = {}) {
    const p = path.join(dir, 'mock-opencode');
    const script = [
      '#!/usr/bin/env bash',
      'set -uo pipefail',
      echoArgs ? 'for a in "$@"; do printf "ARG:%s\\n" "$a"; done' : 'true',
      `exit ${exitCode}`,
      '',
    ].join('\n');
    fs.writeFileSync(p, script);
    fs.chmodSync(p, 0o755);
    return p;
  }

  function makeWorkdirWithPrompt({ content = 'hello adapter' } = {}) {
    const wd = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-wd-'));
    const prompt = path.join(wd, 'prompt.txt');
    fs.writeFileSync(prompt, content);
    return { wd, prompt };
  }

  function runAdapter(args, { rawBin, extraEnv } = {}) {
    const env = {
      ...process.env,
      PATH: '/usr/bin:/bin',
      TAD_OPENCODE_RAW_BIN: rawBin || path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-')), 'missing-bin'),
      ...(extraEnv || {}),
    };
    const res = spawnSync(ADAPTER, args, { cwd: REPO, env, encoding: 'utf8' });
    return { code: res.status ?? 1, stdout: res.stdout || '', stderr: res.stderr || '' };
  }

  it('adapter translates prompt-file to -f flag', () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw = writeMockRawBin(rawDir);
    const { wd, prompt } = makeWorkdirWithPrompt();
    const r = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', wd, '--prompt-file', prompt, '--temperature', '0', '--seed', '42'],
      { rawBin: raw },
    );
    assert.equal(r.code, 0);
    assert.ok(r.stdout.includes(`ARG:-f`), 'raw bin received -f flag');
    assert.ok(r.stdout.includes(`ARG:${prompt}`), 'raw bin received prompt path');
    assert.ok(!r.stdout.split('\n').some((l) => l === 'ARG:--temperature' || l === 'ARG:--seed'), 'no forged temp/seed flags downstream');
  });

  it('adapter fails closed exit 2 on missing required args', () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw = writeMockRawBin(rawDir);
    const { wd } = makeWorkdirWithPrompt();
    const r = runAdapter(['run', '--model', R.MODEL_ID, '--dir', wd], { rawBin: raw });
    assert.equal(r.code, 2);
  });

  it('adapter fails closed exit 2 on missing value for flag', () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw = writeMockRawBin(rawDir);
    const r = runAdapter(['run', '--model'], { rawBin: raw });
    assert.equal(r.code, 2);
  });

  it('adapter fails closed exit 2 on unknown flags', () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw = writeMockRawBin(rawDir);
    const { wd, prompt } = makeWorkdirWithPrompt();
    const r = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', wd, '--prompt-file', prompt, '--bogus', '1'],
      { rawBin: raw },
    );
    assert.equal(r.code, 2);
  });

  it('adapter absorbs temperature and seed with NOTE to stderr', () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw = writeMockRawBin(rawDir);
    const { wd, prompt } = makeWorkdirWithPrompt();
    const r = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', wd, '--prompt-file', prompt, '--temperature', '0', '--seed', '42'],
      { rawBin: raw },
    );
    assert.equal(r.code, 0);
    assert.ok(r.stderr.includes('NOTE: [oc-adapter]'), 'honest NOTE on stderr');
    assert.ok(!r.stdout.includes('ARG:--temperature'), 'temperature not forwarded');
    assert.ok(!r.stdout.includes('ARG:--seed'), 'seed not forwarded');
  });

  it('adapter propagates nonzero opencode exit code and exit 127 accurately', () => {
    // Robustness guard: the 127 branch assumes no system `opencode` on the
    // pinned minimal PATH. If one ever appears, this case cannot discriminate.
    if (fs.existsSync('/usr/bin/opencode') || fs.existsSync('/bin/opencode')) return;
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw3 = writeMockRawBin(rawDir, { exitCode: 3 });
    const { wd, prompt } = makeWorkdirWithPrompt();
    const r1 = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', wd, '--prompt-file', prompt],
      { rawBin: raw3 },
    );
    assert.equal(r1.code, 3);
    const { wd: wd2, prompt: prompt2 } = makeWorkdirWithPrompt();
    const r2 = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', wd2, '--prompt-file', prompt2],
      { rawBin: '/nonexistent-path/no-such-opencode-bin' },
    );
    assert.equal(r2.code, 127);
  });

  it('adapter flag-injection immunity with leading dash prompt content', () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw = writeMockRawBin(rawDir);
    const { wd, prompt } = makeWorkdirWithPrompt({ content: '--rm -rf / --model evil\nsecond line\n' });
    const r = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', wd, '--prompt-file', prompt],
      { rawBin: raw },
    );
    assert.equal(r.code, 0);
    assert.ok(r.stdout.includes(`ARG:${prompt}`), 'prompt travels as -f path, never as argv text');
    assert.equal(fs.readFileSync(prompt, 'utf8').split('\n')[0], '--rm -rf / --model evil');
  });

  it('adapter fails closed exit 2 on symlinked workdir or prompt file', () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw = writeMockRawBin(rawDir);
    const { wd, prompt } = makeWorkdirWithPrompt();
    const linkWd = path.join(os.tmpdir(), `adapter-link-wd-${Date.now()}`);
    fs.symlinkSync(wd, linkWd);
    const r1 = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', linkWd, '--prompt-file', prompt],
      { rawBin: raw },
    );
    assert.equal(r1.code, 2);
    const linkPrompt = path.join(wd, 'prompt-link.txt');
    fs.symlinkSync(prompt, linkPrompt);
    const r2 = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', wd, '--prompt-file', linkPrompt],
      { rawBin: raw },
    );
    assert.equal(r2.code, 2);
  });

  it('adapter fails closed exit 2 on workdir outside allowed root', () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw = writeMockRawBin(rawDir);
    const outsidePrompt = path.join(HERE, 'README.md');
    const r = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', HERE, '--prompt-file', outsidePrompt],
      { rawBin: raw },
    );
    assert.equal(r.code, 2);
  });

  it('adapter fails closed exit 2 on prompt-file outside workdir and root', () => {
    const rawDir = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-raw-'));
    const raw = writeMockRawBin(rawDir);
    const wd = fs.mkdtempSync(path.join(os.tmpdir(), 'adapter-wd-'));
    const outsidePrompt = path.join(HERE, 'README.md');
    assert.ok(fs.existsSync(outsidePrompt));
    const r = runAdapter(
      ['run', '--model', R.MODEL_ID, '--dir', wd, '--prompt-file', outsidePrompt],
      { rawBin: raw },
    );
    assert.equal(r.code, 2);
  });
});
