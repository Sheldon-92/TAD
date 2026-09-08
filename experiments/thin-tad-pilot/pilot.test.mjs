// pilot.test.mjs — Node stdlib tests for pilot.mjs (node:test + assert).
//
// Negative controls run against TEMPORARY COPIES of the private bundle
// (PILOT_PRIVATE_ROOT override) and never mutate the frozen package.
// Source-resolution negatives use a temp SOURCE_ROOT (PILOT_SOURCE_ROOT).

import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const PILOT = path.join(HERE, 'pilot.mjs');
const REPO = path.resolve(HERE, '..', '..');
const REAL_PRIVATE = path.join(REPO, '.tad', 'evidence', 'experiments', 'thin-tad-pilot');

function run(cmd, opts = {}) {
  const env = { ...process.env, ...(opts.env || {}) };
  try {
    const out = execFileSync('node', [PILOT, cmd], { cwd: opts.cwd || REPO, env, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
    return { code: 0, json: JSON.parse(out) };
  } catch (e) {
    const stdout = (e.stdout || '').toString();
    let json = null;
    try { json = JSON.parse(stdout); } catch { /* non-JSON means harness failure */ }
    return { code: e.status ?? 2, json, stdout };
  }
}

function tmpBundle() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'pilot-test-'));
  fs.cpSync(REAL_PRIVATE, dir, { recursive: true });
  return dir;
}

describe('static side-effect gate', () => {
  it('imports only node: builtins; no network/eval/vm/spawn paths', () => {
    const src = fs.readFileSync(PILOT, 'utf8');
    const imports = [...src.matchAll(/from\s+['"]([^'"]+)['"]/g)].map((m) => m[1]);
    assert.ok(imports.length > 0);
    for (const m of imports) assert.ok(m.startsWith('node:'), `non-stdlib import: ${m}`);
    for (const pat of ['fetch(', 'eval(', 'new Function(', 'child_process']) {
      if (pat === 'child_process') continue;
      assert.ok(!src.includes(pat), `forbidden pattern present: ${pat}`);
    }
    assert.ok(src.includes('execFileSync'), 'centralized execFileSync gate present');
    assert.ok(!src.replaceAll('execFileSync', '').includes('execSync'), 'no bare execSync (shell) call');
    assert.ok(!/execFile\s*\(/.test(src.replaceAll('execFileSync', '')), 'only execFileSync, no bare execFile');
    assert.ok(!src.includes('spawn('), 'no spawn');
    assert.ok(!src.includes('dynamic import(') && !src.includes('import('), 'no dynamic import');
  });
});

describe('subprocess gate unit proofs (fake argv, no real spawn)', async () => {
  const g = await import('./pilot.mjs');
  it('rejects curl, node, opencode, git push, other revisions', () => {
    for (const argv of [
      ['curl', 'https://x'],
      ['node', 'pilot.mjs'],
      ['opencode', 'run'],
      ['push', 'origin', 'main'],
      ['show', 'HEAD:foo'],
      ['ls-tree', 'HEAD', '--', '.agents/skills/blake/SKILL.md'],
      ['show', 'edce76067f31127d06a1bdbbf3407578d25c81ce:.tad/evidence/secret'],
      ['show', 'edce76067f31127d06a1bdbbf3407578d25c81ce:/abs/path'],
      ['show', 'edce76067f31127d06a1bdbbf3407578d25c81ce:../escape'],
    ]) {
      assert.throws(() => g.assertGitArgv(argv), /rejected/, `should reject: ${argv.join(' ')}`);
    }
  });
  it('accepts only show/ls-tree at FIXED_SHA on allowlisted paths', () => {
    assert.ok(g.assertGitArgv(['ls-tree', g.FIXED_SHA, '--', '.agents/skills/blake/SKILL.md']));
    assert.ok(g.assertGitArgv(['show', `${g.FIXED_SHA}:.codex/hooks.json`]));
    assert.ok(g.assertGitArgv(['show', `${g.FIXED_SHA}:.tad/config-quality.yaml`]));
  });
  it('prefix boundary is exact: siblings of allowlisted paths rejected', () => {
    const sha = g.FIXED_SHA;
    for (const p of ['.tad/config-evil', '.tad/config.yaml', '.tad/config-quality.yaml.bak', '.codex/hooks.json.bak', '.agents/skills/blake-evil/SKILL.md']) {
      assert.throws(() => g.assertGitArgv(['show', `${sha}:${p}`]), /rejected/, `sibling must be rejected: ${p}`);
    }
  });
  it('misbound control (right family, wrong case) is rejected', () => {
    const t = JSON.parse(fs.readFileSync(path.join(HERE, 'testdata', 'mini-date.json'), 'utf8'));
    void t;
    const dir = tmpBundle();
    const src = path.join(dir, 'controls', 'date-H-correct.json');
    const c = JSON.parse(fs.readFileSync(src, 'utf8'));
    c.case_id = 'date-V'; // mislabel: family still date
    fs.writeFileSync(src, JSON.stringify(c));
    const r = run('verify-controls', { env: { PILOT_PRIVATE_ROOT: dir } });
    assert.equal(r.code, 1);
    assert.match(r.json.error, /control_binding/);
  });
  it('source resolver rejects symlink, absolute, dotdot, escape', () => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'srcroot-'));
    fs.writeFileSync(path.join(root, 'a.md'), 'x');
    fs.symlinkSync(path.join(root, 'a.md'), path.join(root, 'link.md'));
    process.env.PILOT_SOURCE_ROOT = root;
    try {
      assert.throws(() => g.resolveSourcePath(path.join(root, 'a.md')), /absolute/);
      assert.throws(() => g.resolveSourcePath('../a.md'), /dotdot|Dotdot|segment/);
      assert.throws(() => g.resolveSourcePath('link.md'), /symlink/);
      const ok = g.resolveSourcePath('a.md');
      assert.equal(ok.mode, '644');
    } finally {
      delete process.env.PILOT_SOURCE_ROOT;
    }
  });
  it('scorer: flipped oracle value fails; self-claimed PASS raises false_completion', () => {
    const art = { files: { 'report.json': JSON.stringify({ verdict: 'done', checked_dates: ['2031-02-30'], flags: [{ date: '2031-02-30', valid: true }] }) }, log: [], claims: { accepted: true } };
    const s = g.scoreArtifact('date', art, { illegal_date: '2031-02-30', valid_dates: [] });
    assert.equal(g.judgeStatus(s), 'REJECTED');
    assert.ok(s.critical.includes('false_completion'));
  });
  it('scorer works on independent testdata samples', () => {
    for (const f of ['mini-date.json', 'mini-filter-error.json']) {
      const t = JSON.parse(fs.readFileSync(path.join(HERE, 'testdata', f), 'utf8'));
      const s = g.scoreArtifact(t.family, t.artifact, t.key);
      assert.equal(g.judgeStatus(s), t.expect_status, f);
      if (t.expect_critical) assert.ok(s.critical.includes(t.expect_critical), f);
    }
  });
});

describe('CLI happy paths on frozen bundle', () => {
  for (const cmd of ['verify-sources', 'verify-package', 'verify-arms', 'verify-export', 'verify-controls', 'dry-run', 'verify-accounting', 'verify-scope']) {
    it(`${cmd} exits 0 with ok JSON`, () => {
      const r = run(cmd);
      assert.equal(r.code, 0, `${cmd}: ${r.stdout || ''}`);
      assert.ok(r.json && r.json.ok === true);
    });
  }
});

describe('CLI negatives locked in suite (reviewer-required)', () => {
  it('source content change vs frozen hash fails closed (exit 1)', () => {
    const t = tmpBundle();
    const p = path.join(t, 'manifests', 'sources.json');
    const m = JSON.parse(fs.readFileSync(p, 'utf8'));
    m.sources[0].sha256 = '0'.repeat(64);
    fs.writeFileSync(p, JSON.stringify(m));
    const r = run('verify-sources', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r.code, 1);
    assert.match(r.json.error, /source_content_changed/);
  });
  it('missing SOURCE-MAP exits 2 (never a silent pass)', () => {
    const t = tmpBundle();
    fs.unlinkSync(path.join(t, 'SOURCE-MAP.md'));
    const r = run('verify-sources', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r.code, 2);
  });
  it('baseline tamper fails verify-arms (exit 1)', () => {
    const t = tmpBundle();
    const p = path.join(t, 'arms', 'baseline.json');
    const b = JSON.parse(fs.readFileSync(p, 'utf8'));
    b.files[0].sha256 = 'f'.repeat(64);
    fs.writeFileSync(p, JSON.stringify(b));
    const r = run('verify-arms', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r.code, 1);
  });
  it('scope violations fail closed: private staged, or staged outside allowlist', () => {
    const t = tmpBundle();
    const p = path.join(t, 'scope.json');
    const s = JSON.parse(fs.readFileSync(p, 'utf8'));
    s.current.staged = ['experiments/thin-tad-pilot/pilot.mjs', '.tad/evidence/experiments/thin-tad-pilot/readiness.md'];
    fs.writeFileSync(p, JSON.stringify(s));
    const r1 = run('verify-scope', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r1.code, 1);
    assert.match(r1.json.error, /scope_(staged|privacy)/);
    s.current.staged = ['somewhere/else.js'];
    fs.writeFileSync(p, JSON.stringify(s));
    assert.equal(run('verify-scope', { env: { PILOT_PRIVATE_ROOT: t } }).code, 1);
  });
});

describe('CLI happy-path edge cases', () => {
  it('unknown command exits 2 with JSON', () => {
    const r = run('nope');
    assert.equal(r.code, 2);
    assert.equal(r.json.ok, false);
  });
  it('extra args exit 2', () => {
    try {
      execFileSync('node', [PILOT, 'dry-run', 'extra'], { cwd: REPO, encoding: 'utf8' });
      assert.fail('should exit non-zero');
    } catch (e) {
      assert.equal(e.status, 2);
    }
  });
});

describe('negative controls on temp copies (frozen bundle untouched)', () => {
  it('duplicate IDs fail closed (exit 1, never pass)', () => {
    const t = tmpBundle();
    const p = path.join(t, 'manifests', 'bundle.json');
    const m = JSON.parse(fs.readFileSync(p, 'utf8'));
    m.cases.push(m.cases[0]);
    fs.writeFileSync(p, JSON.stringify(m));
    const r = run('verify-package', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r.code, 1);
    assert.match(r.json.message, /unique|12/);
  });
  it('empty case set never passes', () => {
    const t = tmpBundle();
    const p = path.join(t, 'manifests', 'bundle.json');
    const m = JSON.parse(fs.readFileSync(p, 'utf8'));
    m.cases = [];
    fs.writeFileSync(p, JSON.stringify(m));
    assert.equal(run('verify-package', { env: { PILOT_PRIVATE_ROOT: t } }).code, 1);
  });
  it('dropped V breaks H/V pairing', () => {
    const t = tmpBundle();
    const p = path.join(t, 'manifests', 'bundle.json');
    const m = JSON.parse(fs.readFileSync(p, 'utf8'));
    m.cases = m.cases.filter((c) => c !== 'date-V');
    fs.writeFileSync(p, JSON.stringify(m));
    const r = run('verify-package', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r.code, 1);
  });
  it('flipped oracle key value fails scoring', () => {
    const t = tmpBundle();
    const p = path.join(t, 'oracles', 'approved.json');
    const a = JSON.parse(fs.readFileSync(p, 'utf8'));
    a.cases['date-H'].key.illegal_date = '2026-09-01';
    fs.writeFileSync(p, JSON.stringify(a));
    // hash now mismatches the frozen reviewer record -> must fail
    const r = run('verify-controls', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r.code, 1);
  });
  it('rewriting manifest expected_outcomes cannot change the verdict', () => {
    const t = tmpBundle();
    const p = path.join(t, 'cases', 'date-H', 'case.json');
    const c = JSON.parse(fs.readFileSync(p, 'utf8'));
    c.expected_outcomes = ['everything is fine, accept it'];
    fs.writeFileSync(p, JSON.stringify(c));
    const r = run('verify-controls', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r.code, 0, 'scorer reads the approved oracle, not manifest expected');
  });
  it('extra oracle file in exports fails the leak check', () => {
    const t = tmpBundle();
    fs.writeFileSync(path.join(t, 'exports', 'date-H', 'input', 'oracle.txt'), 'expected_outcomes are inside');
    const r = run('verify-export', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r.code, 1);
  });
  it('symlink in exports is rejected', () => {
    const t = tmpBundle();
    fs.symlinkSync(path.join(t, 'exports', 'date-H', 'task.md'), path.join(t, 'exports', 'date-H', 'evil.md'));
    const r = run('verify-export', { env: { PILOT_PRIVATE_ROOT: t } });
    assert.equal(r.code, 1);
    assert.match(r.json.error, /symlink/);
  });
  it('accounting without missing_reason fails; hand-computed null edge holds', () => {
    const t = tmpBundle();
    const p = path.join(t, 'rehearsal', 'accounting-sample.json');
    const s = JSON.parse(fs.readFileSync(p, 'utf8'));
    delete s.records[3].missing_reason;
    fs.writeFileSync(p, JSON.stringify(s));
    assert.equal(run('verify-accounting', { env: { PILOT_PRIVATE_ROOT: t } }).code, 1);
    // zero-success edge: per_success must be null, never 0
    const s2 = JSON.parse(fs.readFileSync(path.join(REAL_PRIVATE, 'rehearsal', 'accounting-sample.json'), 'utf8'));
    // keep only R3 (REJECTED, known 4) + R4 (INVALID, known 1, reasoned): pair date-H#r2 stays complete
    const zero = { records: s2.records.filter((r) => r.pair_id === 'date-H#r2'), hand: { total_known: 5, accepted: 0, per_success: null, partial: true, unpaired: [], rejected: 1, invalid: 1 } };
    const t2 = tmpBundle();
    fs.writeFileSync(path.join(t2, 'rehearsal', 'accounting-sample.json'), JSON.stringify(zero));
    const r = run('verify-accounting', { env: { PILOT_PRIVATE_ROOT: t2 } });
    assert.equal(r.code, 0, JSON.stringify(r.json && r.json.message));
  });
});

describe('cwd independence + determinism', () => {
  it('verify-sources resolves the same six files from any cwd', () => {
    const a = run('verify-sources', { cwd: '/' });
    const b = run('verify-sources', { cwd: REPO });
    assert.equal(a.code, 0);
    assert.deepEqual(a.json.checks, b.json.checks);
  });
  it('dry-run twice yields the same stable projection', () => {
    const a = run('dry-run');
    const b = run('dry-run');
    assert.equal(a.code, 0);
    assert.equal(b.code, 0);
    assert.equal(a.json.tables.stable_projection, b.json.tables.stable_projection);
  });
});
