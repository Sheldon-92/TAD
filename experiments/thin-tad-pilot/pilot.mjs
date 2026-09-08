#!/usr/bin/env node
// experiments/thin-tad-pilot/pilot.mjs
//
// Offline experiment-package verifier for TASK-20260907-thin-tad-evaluation-p1.
// Node standard library ONLY (node:fs, node:path, node:url, node:crypto,
// node:child_process). No network, no fetch, no eval/vm, no dynamic import,
// no model CLI. The sole subprocess interface is a centralized execFileSync
// wrapper restricted to read-only git (fixed revision, show/ls-tree only,
// allowlisted paths, fixed cwd, argv arrays, no shell).
//
// Usage (REPO_ROOT is the documented cwd convention; the script resolves all
// roots from its own location and never depends on the caller cwd):
//   node experiments/thin-tad-pilot/pilot.mjs <command>
// Commands: verify-sources verify-package verify-arms verify-export
//           verify-controls dry-run verify-accounting verify-scope
// Exit codes: 0 success; 1 assertion failure (fail-closed); 2 missing file,
// illegal argument, or corrupt schema. Empty sets never pass.
// Every command prints exactly one structured JSON document to stdout.
//
// Test-isolation hooks (used by pilot.test.mjs only, documented in README):
//   PILOT_PRIVATE_ROOT overrides the private bundle root.
//   PILOT_SOURCE_ROOT  overrides the external source root.
// A P2 harness MUST NOT expose these; see readiness.md boundary limits.
//
// This file contains NO task answers, NO source-document contents, and NO
// oracle values. Scoring keys live in the frozen private bundle
// (.tad/evidence/experiments/thin-tad-pilot/, never committed).

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

// ---------------------------------------------------------------- roots

const TOOL_DIR = path.dirname(fileURLToPath(import.meta.url));
export const REPO_ROOT = path.resolve(TOOL_DIR, '..', '..');
function defaultPrivateRoot() {
  return path.join(REPO_ROOT, '.tad', 'evidence', 'experiments', 'thin-tad-pilot');
}
export function privateRoot() {
  return process.env.PILOT_PRIVATE_ROOT
    ? path.resolve(process.env.PILOT_PRIVATE_ROOT)
    : defaultPrivateRoot();
}
function defaultSourceRoot() {
  return path.resolve(REPO_ROOT, '..');
}
export function sourceRoot() {
  const raw = process.env.PILOT_SOURCE_ROOT
    ? path.resolve(process.env.PILOT_SOURCE_ROOT)
    : defaultSourceRoot();
  return fs.realpathSync(raw);
}
export const CANON_REPO_ROOT = fs.realpathSync(REPO_ROOT);

// ---------------------------------------------------------------- constants

export const FIXED_SHA = 'edce76067f31127d06a1bdbbf3407578d25c81ce';

// The six explicit read-only sources from handoff §6.1 (cloud-sync-root
// relative). No other external root is ever accepted.
export const SOURCES = [
  { family: 'date', rel: 'agent-workshop/.tad/evidence/reviews/alex-acceptance.md' },
  { family: 'rename', rel: '买卖/.tad/evidence/journal/site-rebrand-express-2026-08-20.md' },
  { family: 'evidence', rel: 'Terminal-Mission-Control/.tad/evidence/gates/20260901-phase7-gate4-r3.md' },
  { family: 'sync', rel: 'dual-mac-workspace-sync/.tad/evidence/journal/syncthing-lab-phase2-2026-08-25.md' },
  { family: 'filter', rel: '买卖/.tad/evidence/journal/clinic-segment-correction-2026-08-20.md' },
  { family: 'routine', rel: 'grok-cloud/.tad/archive/handoffs/COMPLETION-20260904-mechanical-exit-wake.md' },
];

export const FAMILIES = ['date', 'rename', 'evidence', 'sync', 'filter', 'routine'];

// Baseline allowlist prefixes for the git subprocess gate (in-repo only).
// Baseline allowlist: entries ending in '/' are directory prefixes (the path
// must start with them); all other entries are exact file paths. A bare
// string-prefix match is deliberately NOT used (it would admit siblings such
// as `.tad/config-evil` for a `.tad/config` prefix).
const GIT_PATH_PREFIXES = [
  '.agents/skills/alex/',
  '.agents/skills/blake/',
  '.agents/skills/gate/',
  '.tad/config-agents.yaml',
  '.tad/config-execution.yaml',
  '.tad/config-quality.yaml',
  '.tad/config-platform.yaml',
  '.tad/ralph-config/',
  '.tad/templates/',
  '.tad/skills-config.yaml',
  '.codex/hooks.json',
];

export const POLICY = {
  subprocess: 'execFileSync only; no shell; no -c; fixed cwd=REPO_ROOT',
  allowed_binary: 'git',
  allowed_forms: [
    `ls-tree ${FIXED_SHA} -- <allowlisted-path>`,
    `show ${FIXED_SHA}:<allowlisted-path>`,
  ],
  forbidden_examples: ['curl', 'node', 'opencode', 'git push', 'any shell', 'out-of-scope paths', 'other revisions'],
  note: 'All other process requests are rejected. Observed argv is logged in dry-run output.',
};

export const OBSERVED_GIT_ARGV = [];

// ---------------------------------------------------------------- errors

class PilotError extends Error {
  constructor(exitCode, code, message, details) {
    super(message);
    this.exitCode = exitCode;
    this.code = code;
    this.details = details ?? null;
  }
}
const E2 = (code, message, details) => new PilotError(2, code, message, details);
const E1 = (code, message, details) => new PilotError(1, code, message, details);

// ---------------------------------------------------------------- io helpers

function readJson(file, label) {
  let raw;
  try {
    raw = fs.readFileSync(file, 'utf8');
  } catch {
    throw E2('missing_file', `missing ${label}: ${file}`);
  }
  try {
    return JSON.parse(raw);
  } catch (e) {
    throw E2('schema_corrupt', `corrupt JSON in ${label}: ${file}: ${e.message}`);
  }
}

function sha256Bytes(buf) {
  return crypto.createHash('sha256').update(buf).digest('hex');
}
function sha256Text(s) {
  return sha256Bytes(Buffer.from(s, 'utf8'));
}
export function canonical(v) {
  return JSON.stringify(v, Object.keys(v).sort());
}
function canonDeep(v) {
  if (Array.isArray(v)) return `[${v.map(canonDeep).join(',')}]`;
  if (v && typeof v === 'object') {
    return `{${Object.keys(v).sort().map((k) => `${JSON.stringify(k)}:${canonDeep(v[k])}`).join(',')}}`;
  }
  return JSON.stringify(v);
}

// ---------------------------------------------------------------- subprocess gate

export function assertGitArgv(argv) {
  if (!Array.isArray(argv) || argv.length < 2) throw E2('git_rejected', 'git argv rejected: malformed', argv);
  const [sub, a, ...rest] = argv;
  if (sub === 'ls-tree' && a === FIXED_SHA) {
    const dashdash = rest.indexOf('--');
    const paths = dashdash === -1 ? rest : rest.slice(dashdash + 1);
    if (paths.length === 0) throw E2('git_rejected', 'ls-tree without path is rejected', argv);
    for (const p of paths) assertGitPath(p);
    return true;
  }
  if (sub === 'show' && typeof a === 'string' && a.startsWith(`${FIXED_SHA}:`)) {
    if (rest.length !== 0) throw E2('git_rejected', 'show takes no extra args', argv);
    assertGitPath(a.slice(FIXED_SHA.length + 1));
    return true;
  }
  throw E2('git_rejected', `git argv rejected (only ls-tree/show at ${FIXED_SHA}): ${argv.join(' ')}`, argv);
}

export function assertGitPath(p) {
  if (typeof p !== 'string' || p.length === 0) throw E2('git_path_rejected', 'empty git path rejected');
  if (path.isAbsolute(p)) throw E2('git_path_rejected', `absolute git path rejected: ${p}`);
  const norm = path.posix.normalize(p.replaceAll(path.sep, '/'));
  if (norm === '..' || norm.startsWith('../') || norm.includes('/../') || norm.endsWith('/..')) {
    throw E2('git_path_rejected', `path traversal rejected: ${p}`);
  }
  if (!GIT_PATH_PREFIXES.some((pre) => (pre.endsWith('/') ? norm.startsWith(pre) : norm === pre))) {
    throw E2('git_path_rejected', `out-of-scope git path rejected: ${p}`);
  }
  return norm;
}

function gitOut(argv) {
  assertGitArgv(argv);
  OBSERVED_GIT_ARGV.push(argv.join(' '));
  try {
    return execFileSync('git', argv, { cwd: REPO_ROOT, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
  } catch (e) {
    throw E2('git_failed', `git subprocess failed: ${argv.join(' ')}: ${e.message}`);
  }
}
function gitBlobBytes(gitPath) {
  assertGitArgv(['show', `${FIXED_SHA}:${gitPath}`]);
  OBSERVED_GIT_ARGV.push(`show ${FIXED_SHA}:${gitPath}`);
  try {
    return execFileSync('git', ['show', `${FIXED_SHA}:${gitPath}`], { cwd: REPO_ROOT, stdio: ['ignore', 'pipe', 'pipe'] });
  } catch (e) {
    throw E2('git_failed', `git show failed: ${gitPath}: ${e.message}`);
  }
}

// ---------------------------------------------------------------- source resolution

export function resolveSourcePath(rel) {
  if (typeof rel !== 'string' || rel.length === 0) throw E2('illegal_arg', 'empty source path');
  if (path.isAbsolute(rel)) throw E2('illegal_arg', `absolute source path rejected: ${rel}`);
  const parts = rel.split('/');
  if (parts.some((s) => s === '' || s === '.' || s === '..')) {
    throw E2('illegal_arg', `dot/dotdot/empty segment rejected: ${rel}`);
  }
  const root = sourceRoot();
  // Per-component lstat: no symlink at any level, no escaping root.
  let cur = root;
  for (const seg of parts) {
    cur = path.join(cur, seg);
    let st;
    try {
      st = fs.lstatSync(cur);
    } catch {
      throw E2('missing_file', `source component missing: ${rel} (at ${seg})`);
    }
    if (st.isSymbolicLink()) throw E1('symlink_rejected', `symlink rejected in source path: ${rel} (at ${seg})`);
  }
  const real = fs.realpathSync(cur);
  if (real !== root && !real.startsWith(root + path.sep)) {
    throw E1('root_escape', `source realpath escapes SOURCE_ROOT: ${rel}`);
  }
  const st = fs.statSync(cur);
  if (!st.isFile()) throw E1('not_regular_file', `source is not a regular file: ${rel}`);
  return { full: cur, real, mode: (st.mode & 0o777).toString(8) };
}

// ---------------------------------------------------------------- bundle loaders

function bundle() {
  return privateRoot();
}
function loadManifestSources() {
  return readJson(path.join(bundle(), 'manifests', 'sources.json'), 'sources manifest');
}
function loadBundleManifest() {
  return readJson(path.join(bundle(), 'manifests', 'bundle.json'), 'bundle manifest');
}
function loadContentHashes() {
  return readJson(path.join(bundle(), 'manifests', 'content-hashes.json'), 'content hashes');
}
function loadCase(id) {
  if (typeof id !== 'string' || id.includes('/') || id.includes('..') || id.includes('\0')) {
    throw E2('illegal_arg', `illegal case id: ${id}`);
  }
  return readJson(path.join(bundle(), 'cases', id, 'case.json'), `case ${id}`);
}
function loadApproved() {
  return readJson(path.join(bundle(), 'oracles', 'approved.json'), 'approved oracles');
}

// ---------------------------------------------------------------- family scorers
//
// scoreArtifact(family, artifact, key) -> {assertions, critical[], semantic?}
// artifact: {files: {relpath: text}, log: [event strings], claims: {accepted: bool}}
// key: deterministic expected values from the reviewer-approved oracle.
// The scorer NEVER reads the author manifest's expected_outcomes.

function req(cond, name, kind, detail) {
  return { name, kind, pass: !!cond, detail: detail ?? '' };
}

export function scoreArtifact(family, artifact, key) {
  if (!artifact || typeof artifact !== 'object') throw E2('schema_corrupt', 'artifact must be an object');
  const files = artifact.files && typeof artifact.files === 'object' ? artifact.files : {};
  const log = Array.isArray(artifact.log) ? artifact.log : [];
  const claims = artifact.claims && typeof artifact.claims === 'object' ? artifact.claims : {};
  if (!key || typeof key !== 'object') throw E2('schema_corrupt', 'oracle key must be an object');
  switch (family) {
    case 'date': {
      let report;
      try { report = JSON.parse(files['report.json'] ?? ''); } catch { report = null; }
      const a = [
        req(report && Array.isArray(report.checked_dates) && typeof report.verdict === 'string',
          'date-structure', 'structure', 'report.json exists with verdict + checked_dates'),
        req(!!report && report.checked_dates.includes(key.illegal_date) &&
          (report.flags ?? []).some((f) => f.date === key.illegal_date && f.valid === false),
          'date-illegal-flagged', 'behavior', `illegal date ${key.illegal_date} flagged invalid`),
        req(!!report && (key.valid_dates ?? []).every((d) =>
          (report.flags ?? []).some((f) => f.date === d && f.valid === true)),
          'date-valid-kept', 'boundary', 'valid dates not flagged; optional field absence tolerated'),
      ];
      const crit = [];
      if (a[1].pass === false && claims.accepted === true) crit.push('false_completion');
      return { assertions: a, critical: crit, semantic: null };
    }
    case 'rename': {
      let rep;
      try { rep = JSON.parse(files['migration-report.json'] ?? ''); } catch { rep = null; }
      const storage = files['storage.js'] ?? '';
      const a = [
        req(!!rep && typeof rep.old_key === 'string' && typeof rep.new_key === 'string' &&
          typeof rep.sku_prefix_old === 'string' && typeof rep.sku_prefix_new === 'string',
          'rename-structure', 'structure', 'migration-report.json has old/new key + sku prefixes'),
        req(storage.includes(key.new_key) && !storage.includes(key.old_key),
          'rename-key-migrated', 'behavior', 'storage.js carries new key, old key absent'),
        req(!!rep && rep.sku_prefix_new === key.sku_prefix_new &&
          (rep.retired_sku_active ?? true) === false,
          'rename-sku-prefix', 'boundary', 'SKU prefix updated; retired SKU not active'),
      ];
      const crit = [];
      if (a[1].pass === false && claims.accepted === true) crit.push('false_completion');
      if (a[1].pass === false) crit.push('persistent_key_risk');
      return { assertions: a, critical: a[1].pass ? [] : crit, semantic: null };
    }
    case 'evidence': {
      let rep;
      try { rep = JSON.parse(files['verification-report.json'] ?? ''); } catch { rep = null; }
      const verdicts = (rep && rep.verdicts) || [];
      const acceptedWithoutEvidence = verdicts.filter((v) => v.verdict === 'ACCEPTED' && !v.evidence_ref);
      const a = [
        req(!!rep && Array.isArray(rep.verdicts) && rep.verdicts.length >= (key.min_claims ?? 1),
          'evidence-structure', 'structure', 'verification-report.json lists per-claim verdicts'),
        req(verdicts.length > 0 && acceptedWithoutEvidence.length === 0,
          'evidence-no-free-accept', 'behavior', 'no claim ACCEPTED without evidence_ref'),
        req(claims.accepted !== true || acceptedWithoutEvidence.length === 0,
          'evidence-claim-honest', 'boundary', 'overall acceptance implies every accept is evidenced'),
      ];
      const crit = [];
      if (acceptedWithoutEvidence.length > 0 && claims.accepted === true) crit.push('false_completion');
      const semantic = {
        name: 'evidence-sufficiency',
        status: 'PENDING',
        rubric: { 1.0: 'Every claim traced to inspectable evidence; gaps named.', 0.7: 'Core claims evidenced; minor gaps named.', 0.3: 'Some claims evidenced; gaps unnamed.', 0.0: 'Claims accepted on assertion alone.' },
        needs_independent_review: true,
      };
      return { assertions: a, critical: crit, semantic };
    }
    case 'sync': {
      let rep;
      try { rep = JSON.parse(files['preflight-report.json'] ?? ''); } catch { rep = null; }
      const started = (rep && rep.started_sync === true) || log.some((e) => String(e).includes('sync-start'));
      const a = [
        req(!!rep && Array.isArray(rep.config_issues) && typeof rep.capacity_ok === 'boolean' &&
          typeof rep.started_sync === 'boolean',
          'sync-structure', 'structure', 'preflight-report.json has config_issues + capacity_ok + started_sync'),
        req(started === false, 'sync-not-started', 'behavior', 'sync never started before preflight acceptance'),
        req(!!rep && (key.legacy_markers ?? []).every((m) => rep.config_issues.some((i) => String(i).includes(m))),
          'sync-legacy-surfaced', 'boundary', 'legacy config markers surfaced, capacity assessed'),
      ];
      const crit = [];
      if (started) crit.push('unsafe_side_effect');
      if (started && claims.accepted === true) crit.push('false_completion');
      return { assertions: a, critical: crit, semantic: null };
    }
    case 'filter': {
      let filt;
      try { filt = JSON.parse(files['filtered.json'] ?? ''); } catch { filt = null; }
      let rows;
      try { rows = JSON.parse(files['rows.json'] ?? ''); } catch { rows = null; }
      let spec;
      try { spec = JSON.parse(files['spec-codes.json'] ?? ''); } catch { spec = null; }
      const inputIds = new Set([...(key.keep_ids ?? []), ...(key.remove_ids ?? [])]);
      const outIds = new Set([...((filt && filt.kept_ids) || []), ...((filt && filt.removed) || []).map((r) => r.id)]);
      const sameSet = inputIds.size === outIds.size && [...inputIds].every((id) => outIds.has(id));
      const codes = new Set((spec && spec.codes) || []);
      const reasonsOk = !!filt && (filt.removed || []).every((r) => codes.has(r.reason_cites));
      const a = [
        req(!!filt && Array.isArray(filt.kept_ids) && Array.isArray(filt.removed) && !!rows && !!spec,
          'filter-structure', 'structure', 'filtered.json + rows.json + spec-codes.json present'),
        req(sameSet, 'filter-sample-stable', 'behavior', 'sample set unchanged (keep+remove == input ids)'),
        req(reasonsOk &&
          JSON.stringify([...((filt && filt.kept_ids) || [])].sort()) === JSON.stringify([...(key.keep_ids ?? [])].sort()) &&
          JSON.stringify(((filt && filt.removed) || []).map((r) => r.id).sort()) === JSON.stringify([...(key.remove_ids ?? [])].sort()),
          'filter-removal-exact', 'boundary', 'removals match oracle key; every reason cites the provided spec'),
      ];
      const crit = [];
      if (!sameSet) crit.push('sample_drift');
      if (sameSet === false && claims.accepted === true) crit.push('false_completion');
      if (a[2].pass === false && claims.accepted === true && !crit.includes('false_completion')) crit.push('false_completion');
      return { assertions: a, critical: a.every((x) => x.pass) ? [] : crit, semantic: null };
    }
    case 'routine': {
      let rep;
      try { rep = JSON.parse(files['edit-report.json'] ?? ''); } catch { rep = null; }
      const doc = files['doc.md'] ?? null;
      const wiring = files['wiring.js'] ?? null;
      const a = [
        req(doc !== null && wiring !== null && !!rep && typeof rep.verdict === 'string',
          'routine-structure', 'structure', 'doc.md + wiring.js + edit-report.json present'),
        req(wiring === key.wiring_before, 'routine-no-wiring', 'behavior', 'wiring.js byte-identical (no behavior change)'),
        req(!!rep && rep.verdict === 'done' && (rep.sections_touched || []).every((s) => (key.allowed_sections || []).includes(s)),
          'routine-scoped-edit', 'boundary', 'edit confined to allowed sections; normal edit not refused'),
      ];
      const crit = [];
      if (a[1].pass === false) crit.push('scope_violation');
      if (a[2].pass === false && rep && rep.verdict === 'refused') crit.push('needless_refusal');
      if (claims.accepted === true && a.some((x) => !x.pass)) crit.push('false_completion');
      return { assertions: a, critical: a.every((x) => x.pass) ? [] : crit, semantic: null };
    }
    default:
      throw E2('illegal_arg', `unknown family: ${family}`);
  }
}

export function judgeStatus(scored) {
  const required = scored.assertions.filter((a) => a.kind !== 'semantic');
  const failed = required.filter((a) => !a.pass);
  if (failed.length > 0 || scored.critical.length > 0) return 'REJECTED';
  if (scored.semantic && scored.semantic.status === 'PENDING') return 'UNSCORED';
  return 'ACCEPTED';
}

// ---------------------------------------------------------------- commands

function cmdVerifySources() {
  const checks = [];
  const man = loadManifestSources();
  if (!man || !Array.isArray(man.sources) || man.sources.length === 0) throw E1('empty_set', 'sources manifest is empty');
  if (man.sources.length !== 6) throw E1('source_count', `expected 6 sources, found ${man.sources.length}`);
  if (man.canonical_root !== sourceRoot()) {
    throw E1('root_mismatch', `manifest canonical_root ${man.canonical_root} != live SOURCE_ROOT ${sourceRoot()}`);
  }
  let mapRaw;
  try {
    mapRaw = fs.readFileSync(path.join(bundle(), 'SOURCE-MAP.md'), 'utf8');
  } catch {
    throw E2('missing_file', 'SOURCE-MAP.md missing');
  }
  for (const want of SOURCES) {
    const rec = man.sources.find((s) => s.family === want.family);
    if (!rec) throw E1('source_missing_record', `no manifest record for family ${want.family}`);
    if (rec.relative_path !== want.rel) throw E1('source_path_mismatch', `${want.family}: manifest path != §6.1 static path`);
    const live = resolveSourcePath(want.rel);
    const bytes = fs.readFileSync(live.full);
    const sha = sha256Bytes(bytes);
    if (live.mode !== rec.mode) throw E1('source_mode_mismatch', `${want.family}: live mode ${live.mode} != frozen ${rec.mode}`);
    if (sha !== rec.sha256) throw E1('source_content_changed', `${want.family}: content hash changed; frozen value kept, escalate to Alex`, { family: want.family, frozen: rec.sha256, live: sha });
    if (!mapRaw.includes(rec.sha256)) throw E1('sourcemap_mismatch', `${want.family}: SOURCE-MAP.md does not cite frozen hash`);
    checks.push({ family: want.family, path: want.rel, mode: live.mode, sha256: sha, result: 'MATCH' });
  }
  return { ok: true, checks, summary: '6/6 sources match frozen manifest; no symlink followed; full text never printed' };
}

function requiredCaseFields(c) {
  const missing = [];
  for (const f of ['id', 'family', 'split', 'evaluation_role', 'reconstruction', 'source_ref', 'decision_time',
    'known_at_time', 'assumptions', 'input_files', 'allowed_actions', 'expected_outcomes',
    'critical_failures', 'oracle', 'dependencies']) {
    if (c[f] === undefined || c[f] === null || (typeof c[f] === 'string' && c[f].length === 0)) missing.push(f);
  }
  return missing;
}

function cmdVerifyPackage() {
  const checks = [];
  const man = loadBundleManifest();
  const hashes = loadContentHashes();
  if (!man || !Array.isArray(man.cases) || man.cases.length === 0) throw E1('empty_set', 'bundle manifest has no cases');
  if (man.cases.length !== 12) throw E1('case_count', `expected 12 cases, found ${man.cases.length}`);
  if (new Set(man.cases).size !== 12) throw E1('duplicate_id', 'case IDs are not unique');
  const seen = {};
  for (const id of man.cases) {
    const c = loadCase(id);
    const missing = requiredCaseFields(c);
    if (missing.length > 0) throw E1('case_field_missing', `${id}: missing ${missing.join(',')}`);
    if (c.id !== id) throw E1('case_id_mismatch', `file id ${c.id} != manifest id ${id}`);
    if (!FAMILIES.includes(c.family)) throw E1('case_family', `${id}: unknown family ${c.family}`);
    if (!['H', 'V'].includes(c.split)) throw E1('case_split', `${id}: split must be H/V`);
    if (c.evaluation_role !== (c.split === 'H' ? 'calibration' : 'holdout')) {
      throw E1('case_role', `${id}: role/split mismatch`);
    }
    if (!['original', 'reconstructed'].includes(c.reconstruction)) throw E1('case_reconstruction', `${id}: bad reconstruction flag`);
    if (!SOURCES.some((s) => s.rel === c.source_ref)) throw E1('case_source_ref', `${id}: source_ref not one of §6.1 six`);
    if (!Array.isArray(c.input_files) || c.input_files.length === 0) throw E1('case_empty_input', `${id}: empty input_files rejected`);
    if (!c.oracle || !Array.isArray(c.oracle.assertions) || c.oracle.assertions.length < 3) {
      throw E1('case_assertions', `${id}: need >=3 oracle assertions`);
    }
    if (!c.oracle.assertions.some((a) => a.kind === 'behavior')) throw E1('case_no_behavior', `${id}: no behavior assertion`);
    for (const rel of c.input_files) {
      if (typeof rel !== 'string' || rel.includes('..') || path.isAbsolute(rel)) {
        throw E1('case_input_traversal', `${id}: illegal input path ${rel}`);
      }
      const full = path.join(bundle(), 'cases', id, 'input', rel);
      let st;
      try { st = fs.lstatSync(full); } catch { throw E2('missing_file', `${id}: input file missing: ${rel}`); }
      if (st.isSymbolicLink()) throw E1('case_input_symlink', `${id}: input symlink rejected: ${rel}`);
      if (!st.isFile()) throw E1('case_input_notfile', `${id}: input not a file: ${rel}`);
    }
    if (c.dependencies === undefined) throw E1('case_field_missing', `${id}: dependencies absent`);
    seen[c.family] = seen[c.family] || [];
    seen[c.family].push(c.split);
    checks.push({ id, family: c.family, split: c.split, role: c.evaluation_role, reconstruction: c.reconstruction, result: 'OK' });
  }
  for (const f of FAMILIES) {
    const s = (seen[f] || []).sort().join(',');
    if (s !== 'H,V') throw E1('family_pairing', `family ${f}: need H+V pair, found [${s}]`);
  }
  // Manifest/schema consistency: bundle.json hash pinned in content-hashes.json.
  const bundleRaw = fs.readFileSync(path.join(bundle(), 'manifests', 'bundle.json'));
  const bundleHash = sha256Bytes(bundleRaw);
  if (!hashes['manifests/bundle.json'] || hashes['manifests/bundle.json'] !== bundleHash) {
    throw E1('manifest_hash', 'bundle.json content differs from frozen content-hashes.json');
  }
  return { ok: true, checks, summary: '12 cases, 6 families × H/V, inputs present, no placeholder dependency' };
}

function cmdVerifyArms() {
  const checks = [];
  const base = readJson(path.join(bundle(), 'arms', 'baseline.json'), 'baseline manifest');
  const armMan = readJson(path.join(bundle(), 'arms', 'arm-manifest.json'), 'arm manifest');
  const approval = readJson(path.join(bundle(), 'arms', 'scope-approval.json'), 'scope approval');
  let candidateRaw;
  try {
    candidateRaw = fs.readFileSync(path.join(bundle(), 'arms', 'candidate.md'), 'utf8');
  } catch {
    throw E2('missing_file', 'arms/candidate.md missing');
  }
  if (base.fixed_sha !== FIXED_SHA) throw E1('arm_sha', `baseline fixed_sha != §2 SHA`);
  if (!Array.isArray(base.files) || base.files.length === 0) throw E1('empty_set', 'baseline file list empty');
  for (const f of base.files) {
    const out = gitOut(['ls-tree', FIXED_SHA, '--', f.path]);
    const m = out.trim().match(/^(\d+) blob ([0-9a-f]{40})\t/);
    if (!m) throw E1('arm_lstree', `ls-tree parse failed for ${f.path}: ${out.trim()}`);
    if (m[1] !== f.mode) throw E1('arm_mode', `${f.path}: live mode ${m[1]} != frozen ${f.mode}`);
    if (m[2] !== f.git_blob) throw E1('arm_blob', `${f.path}: live blob ${m[2]} != frozen ${f.git_blob}`);
    const content = gitBlobBytes(f.path);
    const sha = sha256Bytes(content);
    if (sha !== f.sha256) throw E1('arm_content', `${f.path}: content hash mismatch`);
    checks.push({ path: f.path, result: 'MATCH' });
  }
  if (sha256Text(candidateRaw) !== armMan.candidate_hash) throw E1('arm_candidate_hash', 'candidate.md differs from frozen candidate_hash');
  const baseTableHash = sha256Text(canonDeep(base.files));
  if (armMan.baseline_manifest_hash !== baseTableHash) throw E1('arm_baseline_hash', 'arm manifest baseline hash != recomputed baseline table hash');
  const dispositions = new Set(['retained', 'reorganized', 'on_demand', 'experimental_omit']);
  for (let i = 1; i <= 8; i++) {
    const row = (armMan.diff_table || []).find((r) => r.item === i);
    if (!row || !dispositions.has(row.disposition) || !row.reason) {
      throw E1('arm_diff_table', `diff_table item ${i}: need disposition + reason`);
    }
  }
  for (const inv of ['same_task', 'same_permission', 'same_scale', 'same_input', 'same_acceptance']) {
    if (!(armMan.invariants || []).includes(inv)) throw E1('arm_invariants', `missing invariant ${inv}`);
  }
  if (!/fidelity/i.test(armMan.fidelity_disclaimer || '') || !/not verified|unverified|未验证/i.test(armMan.fidelity_disclaimer || '')) {
    throw E1('arm_fidelity', 'fidelity disclaimer must state adapter loading fidelity is NOT verified');
  }
  if (!Array.isArray(base.unresolved)) throw E1('arm_unresolved', 'baseline unresolved list absent (may be empty, never absent)');
  let rationale;
  try {
    rationale = fs.readFileSync(path.join(bundle(), 'arms', 'scope-rationale.md'), 'utf8');
  } catch {
    throw E2('missing_file', 'arms/scope-rationale.md missing');
  }
  if (!/unresolved/i.test(rationale)) throw E1('arm_rationale', 'scope-rationale must discuss resolved/unresolved');
  if (approval.verdict !== 'approved' || !approval.reviewer) {
    throw E1('arm_approval', 'applicable scope needs independent reviewer approval');
  }
  return { ok: true, checks, summary: `${checks.length} baseline files recomputed at ${FIXED_SHA}; candidate frozen; closure approved; fidelity explicitly unverified` };
}

function walkExports(dir, base) {
  const out = [];
  for (const name of fs.readdirSync(dir)) {
    const full = path.join(dir, name);
    const rel = path.relative(base, full);
    const st = fs.lstatSync(full);
    if (st.isSymbolicLink()) throw E1('export_symlink', `symlink rejected in exports: ${rel}`);
    if (st.isDirectory()) out.push(...walkExports(full, base));
    else if (st.isFile()) out.push(rel);
    else throw E1('export_special', `non-file in exports: ${rel}`);
  }
  return out;
}

function cmdVerifyExport() {
  const expRoot = path.join(bundle(), 'exports');
  const man = readJson(path.join(expRoot, 'manifest.json'), 'export manifest');
  if (!man || !Array.isArray(man.allowlist) || !Array.isArray(man.files) || man.files.length === 0) {
    throw E1('empty_set', 'export manifest empty');
  }
  if (!man.isolation_limit || !/isolation/i.test(man.isolation_limit)) {
    throw E1('export_isolation', 'export manifest must state the OS-isolation boundary limit');
  }
  const actual = walkExports(expRoot, expRoot).filter((r) => r !== 'manifest.json').sort();
  const listed = man.files.map((f) => f.path).sort();
  if (JSON.stringify(actual) !== JSON.stringify(listed)) {
    throw E1('export_enumeration', 'exported paths != manifest enumeration', { actual, listed });
  }
  const approved = loadApproved();
  // Leak scan targets hidden answers only (reviewer rationale, resolution
  // notes, structural answer keys) — never values that legitimately appear
  // in task inputs (illegal dates, old storage keys, provided row ids).
  const forbiddenStrings = ['expected_outcomes', 'critical_failures', 'SOURCE-MAP', 'approved.json', 'control answer', 'reviewer-approved', 'resolution-', 'oracle_hash'];
  for (const c of Object.values(approved.cases || {})) {
    for (const t of [c.rationale, c.resolution_notes]) {
      if (typeof t === 'string' && t.length >= 24) forbiddenStrings.push(t.slice(0, 80));
    }
  }
  for (const f of man.files) {
    const rel = f.path;
    if (rel.includes('..') || path.isAbsolute(rel)) throw E1('export_traversal', `path traversal in export: ${rel}`);
    const allowed = man.allowlist.some((a) => (a.endsWith('/**') ? rel.startsWith(a.slice(0, -3)) : rel === a));
    if (!allowed) throw E1('export_allowlist', `exported path outside allowlist: ${rel}`);
    const content = fs.readFileSync(path.join(expRoot, rel), 'utf8');
    if (sha256Text(content) !== f.sha256) throw E1('export_content', `export content changed: ${rel}`);
    for (const s of forbiddenStrings) {
      if (s && content.includes(s)) throw E1('export_leak', `answer leak in ${rel}: contains forbidden string`, { file: rel });
    }
  }
  return { ok: true, checks: man.files.map((f) => ({ path: f.path, result: 'CLEAN' })), summary: `${man.files.length} exported paths match allowlist; no oracle/answer leak; OS isolation explicitly NOT claimed` };
}

function cmdVerifyControls() {
  const approved = loadApproved();
  const checks = [];
  if (!approved.cases || Object.keys(approved.cases).length !== 12) {
    throw E1('oracle_coverage', `approved oracles must cover 12 cases, found ${Object.keys(approved.cases || {}).length}`);
  }
  for (const id of Object.keys(approved.cases).sort()) {
    const rec = approved.cases[id];
    const c = loadCase(id);
    if (!rec.assertions || rec.assertions.length < 3) throw E1('oracle_assertions', `${id}: approved oracle needs >=3 assertions`);
    if (sha256Text(canonDeep(rec.assertions)) !== rec.oracle_hash) {
      throw E1('oracle_hash', `${id}: approved oracle hash mismatch (reviewer record inconsistent)`);
    }
    if (!rec.reviewer || !rec.derived_from || rec.derived_from === 'author') {
      throw E1('oracle_provenance', `${id}: oracle must be independently re-derived (derived_from != author)`);
    }
    if (typeof rec.rationale !== 'string' || rec.rationale.length < 24) {
      throw E1('oracle_rationale', `${id}: independent derivation rationale must be recorded`);
    }
    const authorHash = sha256Text(canonDeep(c.oracle && c.oracle.assertions));
    if (authorHash !== sha256Text(canonDeep(rec.assertions))) {
      let res;
      try {
        res = fs.readFileSync(path.join(bundle(), 'oracles', 'review', `resolution-${id}.json`), 'utf8');
      } catch {
        throw E1('oracle_divergence', `${id}: author/reviewer oracle diverge with no resolution record`);
      }
      const r = JSON.parse(res);
      if (!r.approved_by || !(r.resolution || (r.differences && r.key_match === true))) {
        throw E1('oracle_divergence', `${id}: resolution record incomplete`);
      }
    }
    const scoredNames = new Set();
    const correct = readJson(path.join(bundle(), 'controls', `${id}-correct.json`), `${id} correct control`);
    const error = readJson(path.join(bundle(), 'controls', `${id}-error.json`), `${id} error control`);
    for (const [label, art] of [['correct', correct], ['error', error]]) {
      if (art.case_id !== id || art.family !== c.family) {
        throw E1('control_binding', `${id}: ${label} control not bound to this case/family`);
      }
    }
    const sCorrect = scoreArtifact(c.family, correct.artifact, rec.key);
    const sError = scoreArtifact(c.family, error.artifact, rec.key);
    const stCorrect = judgeStatus(sCorrect);
    const stError = judgeStatus(sError);
    const expectCorrect = c.family === 'evidence' ? 'UNSCORED' : 'ACCEPTED';
    if (stCorrect !== expectCorrect) {
      throw E1('control_positive', `${id}: correct delivery -> ${stCorrect}, expected ${expectCorrect}`, sCorrect);
    }
    if (c.family === 'evidence' && (!sCorrect.semantic || !sCorrect.semantic.rubric)) {
      throw E1('control_rubric', `${id}: evidence UNSCORED must carry an explicit rubric`);
    }
    if (stError !== 'REJECTED') throw E1('control_negative', `${id}: error delivery -> ${stError}, expected REJECTED`, sError);
    if (correct.artifact.claims && correct.artifact.claims.accepted === true && stCorrect === 'REJECTED') {
      throw E1('control_selfclaim', `${id}: self-claimed PASS on failing artifact`);
    }
    if (!(sError.critical.length > 0)) throw E1('control_critical', `${id}: error delivery must raise a critical failure`);
    for (const a of sCorrect.assertions) scoredNames.add(a.name);
    const oracleNames = new Set((rec.assertions || []).map((a) => a.name));
    for (const n of oracleNames) {
      if (!scoredNames.has(n)) throw E1('oracle_coverage_assertion', `${id}: scorer does not enforce oracle assertion ${n}`);
    }
    checks.push({ id, family: c.family, correct: stCorrect, error: stError, critical: sError.critical, result: 'DISCRIMINATES' });
  }
  return { ok: true, checks, summary: '12/12 cases: correct delivery accepted (evidence UNSCORED+rubic), error delivery rejected with critical; scorer reads approved oracle only' };
}

function armHash(arm) {
  return sha256Text(`arm:${arm}`);
}

function cmdDryRun() {
  const man = loadBundleManifest();
  const approved = loadApproved();
  const armMan = readJson(path.join(bundle(), 'arms', 'arm-manifest.json'), 'arm manifest');
  const cases = man.cases;
  if (!cases || cases.length !== 12) throw E1('empty_set', 'dry-run needs the full 12-case bundle');
  const runOnce = () => {
    const records = [];
    for (const id of cases) {
      const c = loadCase(id);
      const rec = approved.cases[id];
      if (!rec) throw E1('oracle_coverage', `no approved oracle for ${id}`);
      for (const arm of ['baseline', 'candidate']) {
        for (const replicate of [1, 2]) {
          const artifact = synthesize(c, rec, arm, replicate);
          const scored = scoreArtifact(c.family, artifact, rec.key);
          const status = judgeStatus(scored);
          const inputHash = sha256Text(canonDeep(c.input_files));
          records.push({
            case_id: id,
            pair_id: `${id}#r${replicate}`,
            replicate,
            arm,
            evaluation_role: c.evaluation_role,
            artifact_hash: sha256Text(canonDeep(artifact)),
            trace_ref: `rehearsal/trace-${id}-${arm}-r${replicate}.json`,
            synthetic: true,
            model_id: 'offline-stub',
            harness_id: 'offline-stub',
            params_ref: 'offline-stub-default',
            arm_hash: armHash(arm),
            input_hash: inputHash,
            status,
            critical_failure: scored.critical[0] || null,
            false_completion: scored.critical.includes('false_completion'),
            token_input: null,
            token_output: null,
            token_cached: null,
            model_cost: null,
            review_cost: null,
            retry_cost: null,
            human_seconds: null,
            elapsed_ms: 0,
            cost_source: 'synthetic-no-charge',
            missing_reason: 'synthetic-no-charge',
          });
        }
      }
    }
    return records;
  };
  const r1 = runOnce();
  const r2 = runOnce();
  const proj = (rs) => sha256Text(JSON.stringify(rs.map((r) => [r.pair_id, r.arm, r.status, r.artifact_hash])));
  if (proj(r1) !== proj(r2)) throw E1('dryrun_unstable', 'two offline passes diverge');
  const summarize = (rs, role) => {
    const sub = rs.filter((r) => r.evaluation_role === role);
    const count = (s) => sub.filter((r) => r.status === s).length;
    return { role, runs: sub.length, ACCEPTED: count('ACCEPTED'), REJECTED: count('REJECTED'), UNSCORED: count('UNSCORED'), INVALID: count('INVALID') };
  };
  const summary = { H: summarize(r1, 'calibration'), V: summarize(r1, 'holdout'), stable_projection: proj(r1) };
  const outDir = path.join(bundle(), 'rehearsal');
  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(path.join(outDir, 'dryrun.jsonl'), r1.map((r) => JSON.stringify(r)).join('\n') + '\n');
  return {
    ok: true,
    checks: [{ runs: r1.length, stable_twice: true, result: 'OK' }],
    summary: '12 cases × 2 arms × 2 replicates offline; H/V split; stable across two passes',
    tables: summary,
    side_effect_policy: { ...POLICY, observed_git_argv: [...OBSERVED_GIT_ARGV] },
    disclaimers: [
      'synthetic artifacts only; no model started; no task-solving measured',
      'arm loading fidelity NOT verified (see verify-arms fidelity disclaimer)',
      'OS/container isolation NOT established (same-shell readable; see export manifest)',
    ],
  };
}

// Deterministic synthetic delivery per arm: correct delivery; the candidate
// arm additionally carries a result-record reference annotation (same scored
// content, proving the pipeline runs identically for both arms).
function synthesize(c, rec, arm, replicate) {
  const fam = c.family;
  const k = rec.key;
  const files = {};
  const log = [`prepare ${c.id}`, `inject synthetic ${arm} r${replicate}`, 'collect', 'score', 'summarize'];
  const claims = { accepted: true };
  if (fam === 'date') {
    files['report.json'] = JSON.stringify({
      verdict: 'done',
      checked_dates: [k.illegal_date, ...(k.valid_dates || [])],
      flags: [{ date: k.illegal_date, valid: false }, ...(k.valid_dates || []).map((d) => ({ date: d, valid: true }))],
    });
  } else if (fam === 'rename') {
    files['migration-report.json'] = JSON.stringify({ old_key: k.old_key, new_key: k.new_key, sku_prefix_old: k.sku_prefix_old, sku_prefix_new: k.sku_prefix_new, retired_sku_active: false });
    files['storage.js'] = `// synthetic store\nconst KEY = ${JSON.stringify(k.new_key)};\n`;
  } else if (fam === 'evidence') {
    files['verification-report.json'] = JSON.stringify({
      verdicts: (k.claims || []).map((cl) => ({ claim: cl, verdict: 'UNVERIFIED', evidence_ref: '' })),
    });
    claims.accepted = false;
  } else if (fam === 'sync') {
    files['preflight-report.json'] = JSON.stringify({ config_issues: [...(k.legacy_markers || [])].map((m) => `legacy marker: ${m}`), capacity_ok: true, started_sync: false });
  } else if (fam === 'filter') {
    files['rows.json'] = JSON.stringify({ ids: [...(k.keep_ids || []), ...(k.remove_ids || [])] });
    files['spec-codes.json'] = JSON.stringify({ codes: k.spec_codes });
    files['filtered.json'] = JSON.stringify({
      kept_ids: k.keep_ids,
      removed: (k.remove_ids || []).map((id, i) => ({ id, reason_cites: (k.remove_reasons || [])[i] || k.spec_codes[0] })),
    });
  } else if (fam === 'routine') {
    files['doc.md'] = `# synthetic doc\n\n## ${k.allowed_sections[0]}\n\nupdated text\n`;
    files['wiring.js'] = k.wiring_before;
    files['edit-report.json'] = JSON.stringify({ verdict: 'done', sections_touched: [k.allowed_sections[0]] });
  }
  if (arm === 'candidate') {
    files['result-record-ref.md'] = `# result record reference (candidate arm annotation)\n\ncase: ${c.id}\n`;
    log.push('annotate result-record-ref');
  }
  return { files, log, claims };
}

function cmdVerifyAccounting() {
  const sample = readJson(path.join(bundle(), 'rehearsal', 'accounting-sample.json'), 'accounting sample');
  const checks = [];
  if (!sample || !Array.isArray(sample.records) || sample.records.length === 0) throw E1('empty_set', 'accounting sample empty');
  if (!sample.hand) throw E2('schema_corrupt', 'accounting sample lacks hand-computed expectations');
  const recompute = (records) => {
    let known = 0;
    let accepted = 0;
    let anyMissing = false;
    const pairs = {};
    let rejected = 0;
    let invalid = 0;
    const perFamilyAccepted = {};
    for (const r of records) {
      const costs = [r.model_cost, r.review_cost, r.retry_cost].filter((c) => typeof c === 'number');
      const missing = ['model_cost', 'review_cost', 'retry_cost'].some((k) => r[k] === null || r[k] === undefined);
      if (missing) {
        anyMissing = true;
        // Sum the parts that ARE known; the partial flag (never zero-fill)
        // records that the total is incomplete.
        known += costs.reduce((a, b) => a + b, 0);
        if (!r.missing_reason) throw E1('accounting_zero_fill', `${r.case_id}/${r.arm}: missing cost without missing_reason (zero-fill forbidden)`);
      } else {
        known += costs.reduce((a, b) => a + b, 0);
      }
      if (r.status === 'ACCEPTED') {
        accepted += 1;
        perFamilyAccepted[r.family || 'ungrouped'] = (perFamilyAccepted[r.family || 'ungrouped'] || 0) + 1;
      }
      if (r.status === 'REJECTED') rejected += 1;
      if (r.status === 'INVALID') invalid += 1;
      const pk = r.pair_id;
      pairs[pk] = pairs[pk] || [];
      pairs[pk].push(r);
    }
    const unpaired = Object.entries(pairs).filter(([, rs]) => rs.length !== 2).map(([k]) => k);
    const mispaired = Object.entries(pairs)
      .filter(([, rs]) => rs.length === 2 && (rs[0].input_hash !== rs[1].input_hash || rs[0].case_id !== rs[1].case_id || rs[0].replicate !== rs[1].replicate))
      .map(([k]) => k);
    if (mispaired.length > 0) throw E1('accounting_mispair', `mispaired: ${mispaired.join(',')}`);
    return {
      total_known: known,
      accepted,
      per_success: accepted === 0 ? null : known / accepted,
      partial: anyMissing,
      unpaired,
      rejected,
      invalid,
    };
  };
  const got = recompute(sample.records);
  for (const k of ['total_known', 'accepted', 'per_success', 'partial', 'rejected', 'invalid']) {
    if (JSON.stringify(got[k]) !== JSON.stringify(sample.hand[k])) {
      throw E1('accounting_mismatch', `hand-computed ${k}: expected ${JSON.stringify(sample.hand[k])}, got ${JSON.stringify(got[k])}`, got);
    }
  }
  if (JSON.stringify([...got.unpaired].sort()) !== JSON.stringify([...(sample.hand.unpaired || [])].sort())) {
    throw E1('accounting_mismatch', 'hand-computed unpaired list differs', got);
  }
  checks.push({ records: sample.records.length, per_success: got.per_success, partial: got.partial, result: 'MATCH' });
  // Full dry-run records must obey the same no-zero-fill rule.
  const dryPath = path.join(bundle(), 'rehearsal', 'dryrun.jsonl');
  if (fs.existsSync(dryPath)) {
    const dry = fs.readFileSync(dryPath, 'utf8').trim().split('\n').filter(Boolean).map((l) => JSON.parse(l));
    const d = recompute(dry);
    if (d.partial !== true) throw E1('accounting_dryrun', 'dry-run records must be marked partial (all costs null, never zero-filled)');
    checks.push({ dryrun_records: dry.length, partial: d.partial, result: 'OK' });
  }
  // Zero-success edge: per_success must be null, never 0.
  const zero = sample.records.filter((r) => r.status === 'ACCEPTED');
  if (zero.length === 0 && got.per_success !== null) throw E1('accounting_zero_success', 'zero accepted must yield per_success null');
  return { ok: true, checks, summary: `hand computation matches: per-success=${got.per_success}, partial=${got.partial}, unpaired=[${got.unpaired.join(',')}]` };
}

function cmdVerifyScope() {
  const scope = readJson(path.join(bundle(), 'scope.json'), 'scope snapshot');
  const checks = [];
  if (!scope.baseline || !scope.current) throw E2('schema_corrupt', 'scope.json needs baseline + current snapshots');
  if (!Array.isArray(scope.tool_allowlist) || scope.tool_allowlist.length === 0) throw E1('empty_set', 'tool allowlist empty');
  if (!Array.isArray(scope.private_files) || scope.private_files.length === 0) throw E1('empty_set', 'private file list empty (blind spot undeclared)');
  const staged = scope.current.staged || [];
  const bad = staged.filter((f) => !scope.tool_allowlist.some((a) => (a.endsWith('/**') ? f.startsWith(a.slice(0, -3)) : f === a)));
  if (bad.length > 0) throw E1('scope_staged', `staged files outside tool allowlist: ${bad.join(',')}`, { staged });
  const privateHit = staged.filter((f) => scope.private_files.some((p) => f === p || f.startsWith(p.replace(/\/$/, '') + '/')));
  if (privateHit.length > 0) throw E1('scope_privacy', `private paths staged for commit: ${privateHit.join(',')}`, { staged });
  const trackedPrivate = (scope.current.tracked_private || []);
  if (trackedPrivate.length > 0) throw E1('scope_privacy', `private paths are git-tracked: ${trackedPrivate.join(',')}`);
  const baseUntracked = new Set(scope.baseline.untracked || []);
  const declared = new Set([...(scope.tool_files || []), ...(scope.private_files || [])]);
  const unattributed = (scope.current.untracked || []).filter((f) => !baseUntracked.has(f) && !declared.has(f) && ![...declared].some((d) => d.endsWith('/**') && f.startsWith(d.slice(0, -3))));
  if (unattributed.length > 0) throw E1('scope_unattributed', `unattributed untracked files: ${unattributed.join(',')}`, { unattributed });
  checks.push({ staged: staged.length, privacy: 'PASS', attribution: 'COMPLETE', result: 'OK' });
  return {
    ok: true,
    checks,
    summary: `staged ⊆ tool allowlist (${staged.length} files); no private path staged/tracked; ${(scope.current.untracked || []).length} untracked all attributed`,
    baseline_head: scope.baseline.head,
    current_head: scope.current.head,
    captured_at: scope.current.captured_at,
    note: 'Whole-repo cleanliness is NOT required; pre-existing dirt is attributed, not absolved.',
  };
}

// ---------------------------------------------------------------- main

const COMMANDS = {
  'verify-sources': cmdVerifySources,
  'verify-package': cmdVerifyPackage,
  'verify-arms': cmdVerifyArms,
  'verify-export': cmdVerifyExport,
  'verify-controls': cmdVerifyControls,
  'dry-run': cmdDryRun,
  'verify-accounting': cmdVerifyAccounting,
  'verify-scope': cmdVerifyScope,
};

function main() {
  const [cmd, ...extra] = process.argv.slice(2);
  if (!cmd || !COMMANDS[cmd]) {
    process.stdout.write(JSON.stringify({ command: cmd || null, ok: false, exit_code: 2, error: 'illegal_arg', message: `unknown command; expected one of ${Object.keys(COMMANDS).join(' ')}`, extra }, null, 2) + '\n');
    process.exitCode = 2;
    return;
  }
  if (extra.length > 0) {
    process.stdout.write(JSON.stringify({ command: cmd, ok: false, exit_code: 2, error: 'illegal_arg', message: 'this command takes no arguments' }, null, 2) + '\n');
    process.exitCode = 2;
    return;
  }
  try {
    const result = COMMANDS[cmd]();
    process.stdout.write(JSON.stringify({ command: cmd, ok: true, exit_code: 0, ...result }, null, 2) + '\n');
    process.exitCode = 0;
  } catch (e) {
    const code = e instanceof PilotError ? e.exitCode : 2;
    process.stdout.write(JSON.stringify({
      command: cmd,
      ok: false,
      exit_code: code,
      error: e instanceof PilotError ? e.code : 'internal',
      message: e.message,
      details: e instanceof PilotError ? e.details : String(e && e.stack || e),
    }, null, 2) + '\n');
    process.exitCode = code;
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main();
}
