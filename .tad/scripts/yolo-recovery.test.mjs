#!/usr/bin/env node
/**
 * yolo-recovery.test.mjs — deterministic contract suite for the Phase 1
 * recovery recorder, plus the raw-evidence checkers Gate 3 consumes.
 *
 * Usage:
 *   node .tad/scripts/yolo-recovery.test.mjs            # all cases
 *   node .tad/scripts/yolo-recovery.test.mjs --case X   # one case
 *
 * Every case prints `CASE=<name> RESULT=PASS|FAIL`; the suite ends with
 * `RESULT=PASS` (exit 0) or `RESULT=FAIL` (exit 1).
 *
 * Design rule (ac-verification "Run X is not a criterion unless X has a red
 * state"): every negative fixture below asserts a SPECIFIC non-zero exit code
 * AND a specific machine-readable reason, so a silently-passing CLI fails here.
 */

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawnSync, execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

import {
  writeAtomic, REQUIRED_LABELS, CAPSULE_TOKEN_BUDGET, reduceRun, renderRecovery,
} from './yolo-recovery.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(HERE, '..', '..');
const CLI = path.join(HERE, 'yolo-recovery.mjs');
const PHASE1 = path.join(REPO_ROOT, '.tad/evidence/yolo/yolo2-verified-orchestration/phase1');

const TMP_DIRS = [];

// ───────────────────────── assertion helpers ─────────────────────────

class CaseFail extends Error {}
function expect(cond, msg) { if (!cond) throw new CaseFail(msg); }
function expectExit(res, code, msg) {
  expect(res.code === code,
    `${msg}: exit=${res.code} want=${code} reason=${res.status ? res.status.reason : 'n/a'}`);
}
function expectReason(res, reason, msg) {
  expect(res.status && res.status.reason === reason,
    `${msg}: reason=${res.status ? res.status.reason : 'n/a'} want=${reason}`);
}
/** Negative control: non-zero exit AND the expected machine-readable reason. */
function expectRed(res, code, reason, msg) {
  expectExit(res, code, msg);
  expectReason(res, reason, msg);
}

function sha256(file) {
  return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
}

// ───────────────────────── process helpers ─────────────────────────

function cli(args, cwd) {
  const r = spawnSync(process.execPath, [CLI, ...args], { cwd, encoding: 'utf8' });
  const text = r.stdout || '';
  const lines = text.trim().split('\n');
  let status = null;
  try { status = JSON.parse(lines[lines.length - 1]); } catch { /* leave null */ }
  return { code: r.status, out: text, err: r.stderr || '', status };
}

function git(args, cwd) {
  return execFileSync('git', args, { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
}

function tmpDir(prefix) {
  const d = fs.realpathSync(fs.mkdtempSync(path.join(fs.realpathSync(os.tmpdir()), prefix)));
  TMP_DIRS.push(d);
  return d;
}

function cleanupTmp() {
  for (const d of TMP_DIRS) {
    try { fs.chmodSync(d, 0o755); } catch { /* ignore */ }
    try { fs.rmSync(d, { recursive: true, force: true }); } catch { /* ignore */ }
  }
}

// ───────────────────────── repo fixture ─────────────────────────

function makeRepo() {
  const dir = tmpDir('yolo-rec-repo-');
  git(['init', '-q'], dir);
  git(['config', 'user.email', 'fixture@example.invalid'], dir);
  git(['config', 'user.name', 'Fixture'], dir);
  git(['config', 'commit.gpgsign', 'false'], dir);
  fs.mkdirSync(path.join(dir, 'docs'), { recursive: true });
  fs.writeFileSync(path.join(dir, 'docs/handoff.md'), '# fixture handoff\n\nApproved.\n');
  fs.mkdirSync(path.join(dir, '.tad/evidence/yolo'), { recursive: true });
  fs.writeFileSync(path.join(dir, '.tad/evidence/yolo/oracle.md'), '# frozen oracle\n');
  fs.mkdirSync(path.join(dir, 'work'), { recursive: true });
  fs.writeFileSync(path.join(dir, 'work/guide.md'), 'PARAGRAPH ONE\n');
  git(['add', '-A'], dir);
  git(['commit', '-q', '-m', 'fixture base'], dir);
  return { dir, head: git(['rev-parse', 'HEAD'], dir) };
}

const RUN_REL = '.tad/evidence/yolo/run-1';

function writeGoalSpec(repo, over = {}) {
  const spec = {
    run_id: 'run-1',
    goal_id: 'goal-1',
    base_commit: repo.head,
    goal: 'Maintain the reference guide without touching runtime config.',
    success: ['S1 command reference added', 'S2 troubleshooting added'],
    non_goals: ['do not modify the live workflow'],
    forbidden_scope: ['.claude/workflows/'],
    oracle_path: '.tad/evidence/yolo/oracle.md',
    slices: [
      { id: 'S1', statement: 'add command reference' },
      { id: 'S2', statement: 'add troubleshooting' },
    ],
    ...over,
  };
  const rel = '.tad/evidence/yolo/goal-spec.json';
  fs.writeFileSync(path.join(repo.dir, rel), JSON.stringify(spec, null, 2));
  return rel;
}

function initRun(repo, specRel = null, runRel = RUN_REL) {
  const spec = specRel || writeGoalSpec(repo);
  return cli(['init', '--run', runRel, '--handoff', 'docs/handoff.md', '--goal-file', spec], repo.dir);
}

function makeEvidenceFile(repo, name, body) {
  const rel = `.tad/evidence/yolo/ev-${name}.md`;
  fs.writeFileSync(path.join(repo.dir, rel), body);
  return { path: rel, sha256: sha256(path.join(repo.dir, rel)) };
}

function makeReceipt(repo, { slice = 'S1', tag = '', over = {}, runRel = RUN_REL } = {}) {
  const goal = JSON.parse(fs.readFileSync(path.join(repo.dir, runRel, 'goal.json'), 'utf8'));
  const gate = makeEvidenceFile(repo, `gate-${slice}${tag}`, `Gate verdict: PASS for ${slice}\n`);
  const review = makeEvidenceFile(repo, `review-${slice}${tag}`, `Independent review: PASS for ${slice}\n`);
  const receipt = {
    format: 'yolo-recovery-verification-v1',
    verdict: 'PASS',
    run_id: goal.run_id,
    slice,
    handoff_revision: goal.handoff_revision,
    worktree_realpath: goal.worktree_realpath,
    verified_head: git(['rev-parse', 'HEAD'], repo.dir),
    gate_evidence: [{ ...gate, verdict: 'PASS' }],
    review_evidence: [{ ...review, verdict: 'PASS', independent: true }],
    executor_id: 'executor-fresh-1',
    written_by: 'conductor',
    written_by_id: 'conductor-1',
    ...over,
  };
  const rel = `.tad/evidence/yolo/receipt-${slice}${tag}.json`;
  fs.writeFileSync(path.join(repo.dir, rel), JSON.stringify(receipt, null, 2));
  return rel;
}

function readJournalEvents(repo, runRel = RUN_REL) {
  const raw = fs.readFileSync(path.join(repo.dir, runRel, 'journal.jsonl'), 'utf8');
  return raw.split('\n').filter(Boolean).map((l) => JSON.parse(l));
}

// ═════════════════════════ CASE: path-guard ═════════════════════════

function casePathGuard() {
  const repo = makeRepo();
  const spec = writeGoalSpec(repo);

  expectRed(cli(['init', '--run', 'other/run', '--handoff', 'docs/handoff.md', '--goal-file', spec], repo.dir),
    2, 'path_escape', 'run dir outside .tad/evidence/yolo must be refused');

  expectRed(cli(['init', '--run', '.tad/evidence/yolo/../../../escape', '--handoff', 'docs/handoff.md', '--goal-file', spec], repo.dir),
    2, 'path_escape', 'dot-dot escape must be refused');

  expectRed(cli(['init', '--run', '.tad/evidence/yolo', '--handoff', 'docs/handoff.md', '--goal-file', spec], repo.dir),
    2, 'path_escape', 'run dir equal to the scope root must be refused');

  const outside = tmpDir('yolo-rec-outside-');
  fs.mkdirSync(path.join(outside, 'runs'), { recursive: true });
  fs.symlinkSync(outside, path.join(repo.dir, '.tad/evidence/yolo/escape-link'));
  expectRed(cli(['init', '--run', '.tad/evidence/yolo/escape-link/runs/r', '--handoff', 'docs/handoff.md', '--goal-file', spec], repo.dir),
    2, 'path_escape', 'symlink escape must be refused');

  expectExit(initRun(repo, spec), 0, 'in-scope run dir must initialize');

  fs.writeFileSync(path.join(outside, 'receipt.json'), '{}');
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', path.join(outside, 'receipt.json')], repo.dir),
    2, 'path_escape', 'receipt outside the repo must be refused');
}

// ═════════════════════════ CASE: lifecycle-e2e ═════════════════════════

function caseLifecycleE2e() {
  const repo = makeRepo();
  expectExit(initRun(repo), 0, 'init must pass');
  const runAbs = path.join(repo.dir, RUN_REL);
  for (const f of ['goal.json', 'journal.jsonl', 'checkpoint.json', 'recovery.md']) {
    expect(fs.existsSync(path.join(runAbs, f)), `init must create ${f}`);
  }

  expectExit(cli(['status', '--run', RUN_REL], repo.dir), 0, 'status must pass');

  expectExit(cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'candidate', '--next', 'get receipt'], repo.dir),
    0, 'checkpoint must pass');
  const afterCp = cli(['status', '--run', RUN_REL], repo.dir);
  expect(afterCp.status.unverified_slices.includes('S1'), 'checkpointed slice must be UNVERIFIED, not verified');
  expect(afterCp.status.verified_slices.length === 0, 'checkpoint must never advance verified state');

  const receipt = makeReceipt(repo, { slice: 'S1' });
  const v = cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', receipt], repo.dir);
  expectExit(v, 0, 'bound conductor receipt must verify');
  expect(v.status.verified_slices.includes('S1'), 'verify must advance verified state');
  expect(!v.status.unverified_slices.includes('S1'), 'verified slice must leave the unverified list');

  const r1 = cli(['resume', '--run', RUN_REL], repo.dir);
  expectExit(r1, 0, 'resume must pass');
  const cp1 = JSON.parse(fs.readFileSync(path.join(runAbs, 'checkpoint.json'), 'utf8'));
  const r2 = cli(['resume', '--run', RUN_REL], repo.dir);
  expectExit(r2, 0, 'second resume must pass');
  const cp2 = JSON.parse(fs.readFileSync(path.join(runAbs, 'checkpoint.json'), 'utf8'));
  delete cp1.generated_at; delete cp2.generated_at;
  expect(JSON.stringify(cp1) === JSON.stringify(cp2),
    'rebuilding the checkpoint twice must be byte-stable apart from generated_at');

  expect(r1.status.legal_next_action.action.includes('S2'),
    `legal next action must point at the next frozen slice, got: ${r1.status.legal_next_action.action}`);

  const stopped = cli(['stop', '--run', RUN_REL, '--reason', 'human paused the run'], repo.dir);
  expectRed(stopped, 1, 'stopped', 'stop must yield a recoverable honest_partial');
  expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'stopped', 'status after stop stays honest_partial');
  expectRed(cli(['checkpoint', '--run', RUN_REL, '--slice', 'S2', '--reason', 'candidate', '--next', 'x'], repo.dir),
    1, 'stopped', 'no work may continue after stop');
}

// ═════════════════════════ CASE: verified-authority ═════════════════════════

function caseVerifiedAuthority() {
  const repo = makeRepo();
  expectExit(initRun(repo), 0, 'init');
  cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'candidate', '--next', 'await receipt'], repo.dir);

  // 1. An ordinary file is not a receipt.
  fs.writeFileSync(path.join(repo.dir, '.tad/evidence/yolo/plain.txt'), 'the work looks done\n');
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', '.tad/evidence/yolo/plain.txt'], repo.dir),
    1, 'receipt_not_json', 'a plain file must not advance verified');

  // 2. Completion prose is not a receipt.
  fs.writeFileSync(path.join(repo.dir, '.tad/evidence/yolo/COMPLETION.md'),
    '# COMPLETION\n\nlayer1_passed=true\ncompletion_written=true\nAll ACs PASS.\n');
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', '.tad/evidence/yolo/COMPLETION.md'], repo.dir),
    1, 'receipt_not_json', 'completion prose must not advance verified');

  // 3. Self-authored receipt (executor wrote its own PASS).
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt',
    makeReceipt(repo, { slice: 'S1', tag: '-self', over: { written_by_id: 'executor-fresh-1' } })], repo.dir),
    1, 'receipt_self_authored', 'executor-authored receipt must be refused');

  // 4. Wrong author role.
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt',
    makeReceipt(repo, { slice: 'S1', tag: '-role', over: { written_by: 'executor' } })], repo.dir),
    1, 'receipt_author_role_invalid', 'non-conductor author must be refused');

  // 5-9. Binding mismatches.
  const mismatches = [
    ['-run', { run_id: 'some-other-run' }, 'receipt_run_mismatch'],
    ['-slice', { slice: 'S9' }, 'receipt_slice_mismatch'],
    ['-rev', { handoff_revision: 'f'.repeat(64) }, 'receipt_handoff_revision_mismatch'],
    ['-wt', { worktree_realpath: '/tmp/not-this-worktree' }, 'receipt_worktree_mismatch'],
    ['-head', { verified_head: '0'.repeat(40) }, 'receipt_head_not_ancestor'],
    ['-verdict', { verdict: 'FAIL' }, 'receipt_verdict_not_pass'],
  ];
  for (const [tag, over, reason] of mismatches) {
    const rel = makeReceipt(repo, { slice: 'S1', tag, over });
    expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', rel], repo.dir),
      1, reason, `receipt with ${tag} must be refused`);
  }

  // 10. Evidence hash tampered after the receipt was written.
  const relHash = makeReceipt(repo, { slice: 'S1', tag: '-hash' });
  const rH = JSON.parse(fs.readFileSync(path.join(repo.dir, relHash), 'utf8'));
  fs.writeFileSync(path.join(repo.dir, rH.gate_evidence[0].path), 'tampered gate evidence\n');
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', relHash], repo.dir),
    1, 'receipt_evidence_hash_mismatch', 'tampered gate evidence must be refused');

  // 11. Missing evidence file.
  const relMiss = makeReceipt(repo, { slice: 'S1', tag: '-miss' });
  const rM = JSON.parse(fs.readFileSync(path.join(repo.dir, relMiss), 'utf8'));
  fs.unlinkSync(path.join(repo.dir, rM.review_evidence[0].path));
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', relMiss], repo.dir),
    1, 'receipt_evidence_missing', 'missing review evidence must be refused');

  // 12. No independent reviewer.
  const relDep = makeReceipt(repo, { slice: 'S1', tag: '-dep' });
  const rD = JSON.parse(fs.readFileSync(path.join(repo.dir, relDep), 'utf8'));
  rD.review_evidence[0].independent = false;
  fs.writeFileSync(path.join(repo.dir, relDep), JSON.stringify(rD, null, 2));
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', relDep], repo.dir),
    1, 'receipt_no_independent_review', 'a receipt without an independent reviewer must be refused');

  // 13. Empty evidence arrays.
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt',
    makeReceipt(repo, { slice: 'S1', tag: '-empty', over: { gate_evidence: [] } })], repo.dir),
    1, 'receipt_evidence_empty', 'a receipt with no gate evidence must be refused');

  expect(readJournalEvents(repo).every((e) => e.type !== 'verified'),
    'no rejected receipt may have written a verified event');

  // 14. The one correctly bound receipt is accepted.
  const good = makeReceipt(repo, { slice: 'S1', tag: '-good' });
  expectExit(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', good], repo.dir), 0,
    'a correctly bound conductor receipt must be accepted');

  // 15. Re-verifying the same slice is refused (no repeated verified work).
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt',
    makeReceipt(repo, { slice: 'S1', tag: '-dup' })], repo.dir),
    1, 'duplicate_verified_slice', 'a slice must not be verified twice');

  // 16. goal.json is immutable: any edit invalidates the run.
  const goalPath = path.join(repo.dir, RUN_REL, 'goal.json');
  const goal = JSON.parse(fs.readFileSync(goalPath, 'utf8'));
  goal.goal = 'a different goal someone slipped in later';
  fs.writeFileSync(goalPath, JSON.stringify(goal, null, 2) + '\n');
  expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'goal_mutated',
    'mutating goal.json must fail closed');
}

// ═════════════════════════ CASE: authority-conflicts ═════════════════════════

function caseAuthorityConflicts() {
  // (a) corrupt journal line
  {
    const repo = makeRepo();
    initRun(repo);
    fs.appendFileSync(path.join(repo.dir, RUN_REL, 'journal.jsonl'), '{not json at all}\n');
    expectRed(cli(['resume', '--run', RUN_REL], repo.dir), 1, 'journal_corrupt', 'corrupt journal must fail closed');
  }
  // (b) partial final JSONL line (the kill signature)
  {
    const repo = makeRepo();
    initRun(repo);
    fs.appendFileSync(path.join(repo.dir, RUN_REL, 'journal.jsonl'), '{"seq":2,"type":"checkpo');
    expectRed(cli(['resume', '--run', RUN_REL], repo.dir), 1, 'journal_partial_line',
      'a half-written final line must never be silently truncated');
  }
  // (c) unknown event type
  {
    const repo = makeRepo();
    initRun(repo);
    fs.appendFileSync(path.join(repo.dir, RUN_REL, 'journal.jsonl'),
      JSON.stringify({ seq: 2, type: 'completed', at: 'x', observed_head: 'y', payload: {} }) + '\n');
    expectRed(cli(['resume', '--run', RUN_REL], repo.dir), 1, 'unknown_event_type', 'unknown event types must fail closed');
  }
  // (d) seq gap
  {
    const repo = makeRepo();
    initRun(repo);
    fs.appendFileSync(path.join(repo.dir, RUN_REL, 'journal.jsonl'),
      JSON.stringify({ seq: 7, type: 'checkpointed', at: 'x', observed_head: 'y', payload: { slice: 'S1', reason: 'candidate', next: 'z' } }) + '\n');
    expectRed(cli(['resume', '--run', RUN_REL], repo.dir), 1, 'journal_seq_broken', 'a seq gap must fail closed');
  }
  // (e) stale derived checkpoint, and the explicit repair path
  {
    const repo = makeRepo();
    initRun(repo);
    cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'candidate', '--next', 'a'], repo.dir);
    const cpPath = path.join(repo.dir, RUN_REL, 'checkpoint.json');
    const cp = JSON.parse(fs.readFileSync(cpPath, 'utf8'));
    cp.verified = [{ slice: 'S1', seq: 99, at: 'forged', receipt_path: 'nope', receipt_sha256: 'nope', verified_head: 'nope' }];
    fs.writeFileSync(cpPath, JSON.stringify(cp, null, 2));
    expectRed(cli(['resume', '--run', RUN_REL], repo.dir), 1, 'derived_state_conflict',
      'a derived file that disagrees with the journal must not be silently overwritten');
    const repaired = cli(['resume', '--run', RUN_REL, '--rebuild-derived'], repo.dir);
    expectExit(repaired, 0, 'explicit rebuild must repair derived state');
    expect(repaired.status.verified_slices.length === 0,
      'the forged derived claim must not survive the rebuild');
  }
  // (f) handoff revision drift
  {
    const repo = makeRepo();
    initRun(repo);
    fs.appendFileSync(path.join(repo.dir, 'docs/handoff.md'), '\nsomeone edited the approved handoff\n');
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'handoff_revision_drift', 'handoff drift must fail closed');
  }
  // (g) handoff deleted
  {
    const repo = makeRepo();
    initRun(repo);
    fs.unlinkSync(path.join(repo.dir, 'docs/handoff.md'));
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'handoff_missing', 'a missing handoff must fail closed');
  }
  // (h) worktree identity mismatch — provoked by RELOCATING the worktree, which
  // is the real-world trigger (restore from backup, different mount, migration).
  {
    const repo = makeRepo();
    initRun(repo);
    const moved = path.join(tmpDir('yolo-rec-moved-'), 'relocated');
    fs.cpSync(repo.dir, moved, { recursive: true });
    const res = cli(['status', '--run', RUN_REL], moved);
    expectRed(res, 1, 'worktree_identity_mismatch',
      'a relocated worktree must be reported');
    expect(res.out.includes('GOAL:'),
      'status must still RENDER under a binding failure — a lockout leaves no way to close the run');
    const stopped = cli(['stop', '--run', RUN_REL, '--reason', 'worktree was relocated'], moved);
    expectExit(stopped, 1, 'stop must remain available under a binding failure');
    expect(readJournalEvents({ dir: moved }).some((e) => e.type === 'stopped'),
      'stop must actually record the truth even when the binding is broken');
  }
  // (i) verified evidence deleted after the fact
  {
    const repo = makeRepo();
    initRun(repo);
    const rel = makeReceipt(repo, { slice: 'S1' });
    expectExit(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', rel], repo.dir), 0, 'verify');
    fs.unlinkSync(path.join(repo.dir, rel));
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'verified_evidence_missing',
      'verified progress whose receipt vanished must fail closed');
  }
  // (j) verified receipt edited after the fact
  {
    const repo = makeRepo();
    initRun(repo);
    const rel = makeReceipt(repo, { slice: 'S1' });
    expectExit(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', rel], repo.dir), 0, 'verify');
    fs.appendFileSync(path.join(repo.dir, rel), '\n');
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'verified_evidence_hash_mismatch',
      'a mutated receipt must invalidate the verified claim');
  }
  // (j2) gate/review evidence destroyed AFTER verify — the receipt itself is
  // intact, so only the post-verify bound-evidence re-check catches this.
  {
    const repo = makeRepo();
    initRun(repo);
    const rel = makeReceipt(repo, { slice: 'S1' });
    expectExit(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', rel], repo.dir), 0, 'verify');
    fs.unlinkSync(path.join(repo.dir, '.tad/evidence/yolo/ev-gate-S1.md'));
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'verified_evidence_missing',
      'verified progress whose gate evidence vanished must fail closed');
  }
  // (j3) gate/review evidence tampered AFTER verify
  {
    const repo = makeRepo();
    initRun(repo);
    const rel = makeReceipt(repo, { slice: 'S1' });
    expectExit(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', rel], repo.dir), 0, 'verify');
    fs.appendFileSync(path.join(repo.dir, '.tad/evidence/yolo/ev-review-S1.md'), 'tampered\n');
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'verified_evidence_hash_mismatch',
      'verified progress whose review evidence was edited must fail closed');
  }
  // (k) events after stop
  {
    const repo = makeRepo();
    initRun(repo);
    cli(['stop', '--run', RUN_REL, '--reason', 'paused'], repo.dir);
    fs.appendFileSync(path.join(repo.dir, RUN_REL, 'journal.jsonl'),
      JSON.stringify({ seq: 3, type: 'checkpointed', at: 'x', observed_head: 'y', payload: { slice: 'S2', reason: 'candidate', next: 'z' } }) + '\n');
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'event_after_stop', 'no event may follow a stop');
  }
  // (l) double init
  {
    const repo = makeRepo();
    const spec = writeGoalSpec(repo);
    expectExit(initRun(repo, spec), 0, 'first init');
    expectRed(initRun(repo, spec), 1, 'run_already_initialized', 'init must never overwrite an existing run');
  }
  // (m) base commit mismatch
  {
    const repo = makeRepo();
    const spec = writeGoalSpec(repo, { base_commit: '0'.repeat(40) });
    expectRed(initRun(repo, spec), 1, 'base_commit_mismatch', 'init must prove HEAD equals the declared base commit');
  }
  // (n) missing frozen oracle
  {
    const repo = makeRepo();
    const spec = writeGoalSpec(repo, { oracle_path: '.tad/evidence/yolo/nope.md' });
    expectRed(initRun(repo, spec), 1, 'oracle_missing', 'init must require the frozen oracle to exist');
  }
  // (o) concurrent writer detection
  {
    const repo = makeRepo();
    initRun(repo);
    const jp = path.join(repo.dir, RUN_REL, 'journal.jsonl');
    const goalSha = JSON.parse(fs.readFileSync(jp, 'utf8').split('\n')[0]).payload.goal_sha256;
    // Simulate a second writer appending between our read and our append by
    // making the on-disk count disagree with what the CLI just reduced.
    const original = fs.readFileSync(jp, 'utf8');
    fs.writeFileSync(jp, original + original.replace('"seq":1', '"seq":2'));
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'duplicate_initialized',
      'a second initialized event must fail closed');
    void goalSha;
  }
  // (p) unknown command / missing flags
  {
    const repo = makeRepo();
    initRun(repo);
    expectRed(cli(['frobnicate', '--run', RUN_REL], repo.dir), 2, 'unknown_command', 'unknown command is a usage error');
    expectRed(cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'candidate'], repo.dir),
      2, 'missing_flag', 'a missing required flag is a usage error');
    expectRed(cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'verified', '--next', 'x'], repo.dir),
      2, 'checkpoint_reason_invalid', 'checkpoint must not accept a self-declared verified reason');
  }
}

// ═════════════════════════ CASE: side-effect-reconcile ═════════════════════════

function caseSideEffectReconcile() {
  const repo = makeRepo();
  initRun(repo);
  const targetAbs = path.join(repo.dir, 'work/guide.md');
  const preSha = sha256(targetAbs);
  const postBody = 'PARAGRAPH ONE (patched)\n';
  const postSha = crypto.createHash('sha256').update(postBody).digest('hex');

  // Structured hash arguments are mandatory.
  expectRed(cli(['action-start', '--run', RUN_REL, '--action', 'A1', '--description', 'patch',
    '--target', 'work/guide.md', '--pre-sha256', preSha], repo.dir),
    2, 'missing_flag', 'action-start without --intended-post-sha256 is a usage error');

  // Declared pre-state must match reality.
  expectRed(cli(['action-start', '--run', RUN_REL, '--action', 'A1', '--description', 'patch',
    '--target', 'work/guide.md', '--pre-sha256', 'a'.repeat(64), '--intended-post-sha256', postSha], repo.dir),
    1, 'pre_state_mismatch', 'a wrong declared pre-state must fail closed');

  const start = ['action-start', '--run', RUN_REL, '--action', 'A1', '--description', 'patch frozen paragraph',
    '--target', 'work/guide.md', '--pre-sha256', preSha, '--intended-post-sha256', postSha];
  // FR5: an UNRESOLVED side effect is honest_partial and must not exit 0, or a
  // script marches straight past a real-world change nobody has reconciled.
  expectRed(cli(start, repo.dir), 1, 'unreconciled_side_effect',
    'a started-but-unreconciled side effect must not report success');
  expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'unreconciled_side_effect',
    'status must keep reporting the unreconciled side effect');

  expectRed(cli(['action-start', '--run', RUN_REL, '--action', 'A2', '--description', 'other',
    '--target', 'work/guide.md', '--pre-sha256', preSha, '--intended-post-sha256', postSha], repo.dir),
    1, 'concurrent_action', 'a second action while one is pending must fail closed');

  // Untouched target cannot be claimed as confirmed.
  expectRed(cli(['reconcile', '--run', RUN_REL, '--action', 'A1', '--outcome', 'confirmed'], repo.dir),
    1, 'confirmed_requires_intended_post', 'confirmed must require the exact intended post hash');

  fs.writeFileSync(targetAbs, postBody);
  // ...and once the real file matches, outcome_unknown is not available either.
  expectRed(cli(['reconcile', '--run', RUN_REL, '--action', 'A1', '--outcome', 'outcome_unknown'], repo.dir),
    1, 'outcome_is_actually_confirmed', 'a matching post hash must be classified as confirmed');
  expectExit(cli(['reconcile', '--run', RUN_REL, '--action', 'A1', '--outcome', 'confirmed'], repo.dir),
    0, 'confirmed reconcile must pass');

  // Second action lands in a third state -> outcome_unknown.
  const pre2 = sha256(targetAbs);
  const intended2 = crypto.createHash('sha256').update('PARAGRAPH ONE (patched twice)\n').digest('hex');
  expectRed(cli(['action-start', '--run', RUN_REL, '--action', 'A2', '--description', 'second patch',
    '--target', 'work/guide.md', '--pre-sha256', pre2, '--intended-post-sha256', intended2], repo.dir),
    1, 'unreconciled_side_effect', 'second action-start opens another unreconciled side effect');
  fs.writeFileSync(targetAbs, 'PARAGRAPH ONE (something else entirely)\n');
  const unknown = cli(['reconcile', '--run', RUN_REL, '--action', 'A2', '--outcome', 'outcome_unknown'], repo.dir);
  expectRed(unknown, 1, 'outcome_unknown', 'an unknown outcome must yield honest_partial');

  // No blind retry of the same action id, and no other work while unknown.
  expectRed(cli(['action-start', '--run', RUN_REL, '--action', 'A2', '--description', 'retry',
    '--target', 'work/guide.md', '--pre-sha256', sha256(targetAbs), '--intended-post-sha256', intended2], repo.dir),
    1, 'blind_retry_forbidden', 'retrying an unknown-outcome action id must be forbidden');
  expectRed(cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'candidate', '--next', 'x'], repo.dir),
    1, 'outcome_unknown', 'no progress may be recorded while an outcome is unknown');
  expectRed(cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', makeReceipt(repo, { slice: 'S1' })], repo.dir),
    1, 'outcome_unknown', 'verify must be blocked while an outcome is unknown');

  // Resolution requires explicit evidence and the real observed hash.
  const ev = makeEvidenceFile(repo, 'reconcile-A2', 'Human inspected the file and the downstream system.\n');
  expectRed(cli(['reconcile', '--run', RUN_REL, '--action', 'A2', '--outcome', 'confirmed',
    '--evidence', ev.path, '--observed-sha256', sha256(targetAbs)], repo.dir),
    1, 'unknown_outcome_needs_reconciled', 'an unknown outcome may only be closed as reconciled');
  expectRed(cli(['reconcile', '--run', RUN_REL, '--action', 'A2', '--outcome', 'reconciled',
    '--evidence', ev.path, '--observed-sha256', 'b'.repeat(64)], repo.dir),
    1, 'observed_sha_mismatch', 'reconciliation must quote the real observed hash');
  expectExit(cli(['reconcile', '--run', RUN_REL, '--action', 'A2', '--outcome', 'reconciled',
    '--evidence', ev.path, '--observed-sha256', sha256(targetAbs)], repo.dir),
    0, 'evidence-backed reconciliation must clear honest_partial');
  expectExit(cli(['status', '--run', RUN_REL], repo.dir), 0, 'run must be usable again after reconciliation');

  expectRed(cli(['reconcile', '--run', RUN_REL, '--action', 'A9', '--outcome', 'confirmed'], repo.dir),
    1, 'unknown_action_reconcile', 'reconciling an unknown action id must fail closed');
}

// ═════════════════════════ CASE: status-capsule ═════════════════════════

function caseStatusCapsule() {
  const repo = makeRepo();
  expectExit(initRun(repo), 0, 'init');
  cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'before-compact', '--next', 'obtain receipt'], repo.dir);
  const st = cli(['status', '--run', RUN_REL], repo.dir);
  expectExit(st, 0, 'status');
  for (const label of REQUIRED_LABELS) {
    expect(st.out.includes(label), `status output must contain the label ${label}`);
  }
  const packet = fs.readFileSync(path.join(repo.dir, RUN_REL, 'recovery.md'), 'utf8');
  for (const label of REQUIRED_LABELS) {
    expect(packet.includes(label), `recovery packet must contain the label ${label}`);
  }
  expect(packet.includes('NON-GOALS') && packet.includes('FORBIDDEN SCOPE'),
    'recovery packet must keep non-goals and forbidden scope');
  expect(packet.includes('VERIFICATION MODEL'),
    'recovery packet must carry the verification model section');
  expect(/CANDIDATE/.test(packet) && /written_by_id/.test(packet) && /NEVER advances `verified`/.test(packet),
    'verification model must state: checkpoint=candidate, conductor-distinct receipt advances, self-assertion never advances');
  expect(packet.includes('PROHIBITIONS'),
    'recovery packet must carry the PROHIBITIONS section');
  expect(/MUST NOT be treated as progress or as done/.test(packet),
    'with uncommitted work present, the packet must forbid treating it as progress');
  const resume = cli(['resume', '--run', RUN_REL], repo.dir);
  expect(resume.status.capsule_tokens > 0 && resume.status.capsule_tokens <= CAPSULE_TOKEN_BUDGET,
    `capsule must fit the ${CAPSULE_TOKEN_BUDGET} token budget, got ${resume.status.capsule_tokens}`);

  // Over-budget: report composition and stop, without trimming hard anchors.
  const repo2 = makeRepo();
  const fat = Array.from({ length: 400 }, (_, i) => `criterion ${i}: ${'x'.repeat(120)}`);
  const spec2 = writeGoalSpec(repo2, { success: fat });
  const over = initRun(repo2, spec2);
  expectRed(over, 1, 'capsule_over_budget', 'an oversized capsule must stop instead of silently shipping');
  expect(over.out.includes('composition'), 'over-budget failure must report the capsule composition');
  // Transactional: the budget is checked BEFORE the first write, so a rejected
  // init leaves nothing behind and the run-dir name stays usable.
  expect(!fs.existsSync(path.join(repo2.dir, RUN_REL, 'goal.json')),
    'a rejected init must leave no half-written run behind');
  expectExit(initRun(repo2, writeGoalSpec(repo2)), 0,
    'the run dir name must still be usable after a rolled-back init');

  // The anchors-never-trimmed property, asserted directly on the renderer.
  const fatGoal = {
    format: 'yolo-recovery-phase1-v1', run_id: 'r', goal_id: 'g', handoff_path: 'h.md',
    handoff_revision: 'a'.repeat(64), base_commit: 'b'.repeat(40), worktree_realpath: '/w',
    goal: 'a goal', success: fat, non_goals: ['do not touch prod'],
    forbidden_scope: ['.claude/'], oracle_path: 'o.md', created_at: 'now',
  };
  const fatState = reduceRun(fatGoal, [{
    seq: 1, type: 'initialized', at: 'now', observed_head: 'b'.repeat(40),
    payload: { goal_sha256: '0'.repeat(64) },
  }]);
  const fatPacket = renderRecovery(fatGoal, fatState,
    { runDir: '/w/run', dirty_count: 0, resumeCommand: 'x' });
  expect(fatPacket.tokens > CAPSULE_TOKEN_BUDGET, 'the over-budget fixture must really exceed the budget');
  for (const label of REQUIRED_LABELS) {
    expect(fatPacket.text.includes(label),
      `an over-budget packet must still carry the hard anchor ${label} — never trim anchors to fit`);
  }
}

// ═════════════════════════ CASE: atomic-write ═════════════════════════

function caseAtomicWrite() {
  if (typeof process.getuid === 'function' && process.getuid() === 0) {
    throw new CaseFail('refusing to run the atomic-write fault test as root (chmod would not deny)');
  }
  const dir = tmpDir('yolo-rec-atomic-');
  const target = path.join(dir, 'checkpoint.json');
  writeAtomic(target, '{"v":1}\n');
  const before = sha256(target);
  expect(fs.readdirSync(dir).length === 1, 'atomic write must leave no temp file behind');

  fs.chmodSync(dir, 0o555);
  let threw = null;
  try { writeAtomic(target, '{"v":2}\n'); } catch (err) { threw = err; }
  fs.chmodSync(dir, 0o755);
  expect(threw !== null, 'a failed atomic write must throw');
  expect(threw.reason === 'atomic_write_failed', `expected atomic_write_failed, got ${threw && threw.reason}`);
  expect(sha256(target) === before, 'a failed atomic write must leave the previous authority state intact');
  expect(fs.readdirSync(dir).length === 1, 'a failed atomic write must not leave a half-written temp file');
}


// ═════════════════════════ CASE: binding-and-closure ═════════════════════════
// Regression cases for the Layer 2 findings: every one of these was a state the
// tool could reach with NO legal next action at all.

function caseBindingAndClosure() {
  // 1. No command may append an event the reducer would reject (arch/code P0-1).
  //    Previously: reconcile after stop WROTE the event, then every command —
  //    status, stop, resume — died on event_after_stop forever.
  {
    const repo = makeRepo();
    initRun(repo);
    const targetAbs = path.join(repo.dir, 'work/guide.md');
    const pre = sha256(targetAbs);
    const post = crypto.createHash('sha256').update('changed\n').digest('hex');
    cli(['action-start', '--run', RUN_REL, '--action', 'A1', '--description', 'p',
      '--target', 'work/guide.md', '--pre-sha256', pre, '--intended-post-sha256', post], repo.dir);
    fs.writeFileSync(targetAbs, 'something else\n');
    cli(['reconcile', '--run', RUN_REL, '--action', 'A1', '--outcome', 'outcome_unknown'], repo.dir);
    const before = readJournalEvents(repo).length;
    cli(['stop', '--run', RUN_REL, '--reason', 'giving up'], repo.dir);
    const afterStop = readJournalEvents(repo).length;
    expect(afterStop === before + 1, 'stop must record exactly one event');

    const ev = makeEvidenceFile(repo, 'late', 'inspected afterwards\n');
    const res = cli(['reconcile', '--run', RUN_REL, '--action', 'A1', '--outcome', 'reconciled',
      '--evidence', ev.path, '--observed-sha256', sha256(targetAbs)], repo.dir);
    expectRed(res, 1, 'run_stopped', 'reconcile after stop must be refused');
    expect(readJournalEvents(repo).length === afterStop,
      'a refused command must not have written anything to the journal');
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'stopped',
      'the ledger must still be readable after a refused reconcile');
  }

  // 2. A handoff amendment must not lock the operator out (arch P0-2).
  {
    const repo = makeRepo();
    initRun(repo);
    fs.appendFileSync(path.join(repo.dir, 'docs/handoff.md'), '\n## 9.2 Expert Review Status: added during the work\n');
    const st = cli(['status', '--run', RUN_REL], repo.dir);
    expectRed(st, 1, 'handoff_revision_drift', 'drift must be reported');
    expect(st.out.includes('GOAL:') && st.out.includes('LEGAL NEXT ACTION'),
      'status must still render the run under drift');
    expectRed(cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'candidate', '--next', 'x'], repo.dir),
      1, 'handoff_revision_drift', 'no progress may be recorded under drift');
    const stopped = cli(['stop', '--run', RUN_REL, '--reason', 'handoff was amended mid-run'], repo.dir);
    expectExit(stopped, 1, 'stop must remain possible under drift');
    expect(readJournalEvents(repo).some((e) => e.type === 'stopped'),
      'the run must be closable honestly even when the handoff drifted');
  }

  // 3. The run owns its authority: init freezes a copy of the approved handoff.
  {
    const repo = makeRepo();
    initRun(repo);
    const frozen = path.join(repo.dir, RUN_REL, 'handoff-frozen.md');
    expect(fs.existsSync(frozen), 'init must freeze a copy of the approved handoff into the run');
    expect(sha256(frozen) === sha256(path.join(repo.dir, 'docs/handoff.md')),
      'the frozen copy must be byte-identical to the approved handoff');
    fs.appendFileSync(frozen, 'tampered\n');
    expectRed(cli(['status', '--run', RUN_REL], repo.dir), 1, 'handoff_frozen_tampered',
      "tampering with the run's own frozen authority must be fatal, not a blocker");
  }

  // 4. Verify accepts the gated commit or any ancestor of HEAD (arch P1-3).
  //    Committing the Gate and reviewer reports before verifying is the natural
  //    TAD order; exact-HEAD equality made it fail.
  {
    const repo = makeRepo();
    initRun(repo);
    const receipt = makeReceipt(repo, { slice: 'S1' });
    fs.writeFileSync(path.join(repo.dir, 'work/extra.md'), 'gate report committed after the receipt\n');
    git(['add', '-A'], repo.dir);
    git(['commit', '-q', '-m', 'commit the gate evidence'], repo.dir);
    const res = cli(['verify', '--run', RUN_REL, '--slice', 'S1', '--receipt', receipt], repo.dir);
    expectExit(res, 0, 'a receipt gated at an ancestor commit must still verify');
    const verified = readJournalEvents(repo).find((e) => e.type === 'verified');
    expect(verified.payload.observed_head_at_verify === git(['rev-parse', 'HEAD'], repo.dir),
      'the verified event must record the head actually observed at verify time');
    expect(Array.isArray(verified.payload.dirty_paths_at_verify),
      'the verified event must record whether the tree was dirty, not imply it was clean');
  }

  // 5. Repo-relative paths must anchor at the REPO ROOT, not at cwd (security HIGH-2).
  {
    const repo = makeRepo();
    fs.mkdirSync(path.join(repo.dir, 'sub/docs'), { recursive: true });
    fs.writeFileSync(path.join(repo.dir, 'sub/docs/handoff.md'), '# DECOY handoff nobody approved\n');
    const spec = writeGoalSpec(repo);
    const res = cli(['init', '--run', path.join(repo.dir, RUN_REL), '--handoff', 'docs/handoff.md',
      '--goal-file', spec], path.join(repo.dir, 'sub'));
    expectExit(res, 0, 'init from a subdirectory must work');
    const goal = JSON.parse(fs.readFileSync(path.join(repo.dir, RUN_REL, 'goal.json'), 'utf8'));
    expect(goal.handoff_path === 'docs/handoff.md',
      `a documented relative path must bind to the APPROVED handoff, got ${goal.handoff_path}`);
    expect(goal.handoff_revision === sha256(path.join(repo.dir, 'docs/handoff.md')),
      'the frozen revision must be the approved handoff, not a same-named decoy under cwd');
  }

  // 6. An exclusive lock prevents the duplicate-seq race that permanently
  //    destroys a ledger (arch P2-2).
  {
    const repo = makeRepo();
    initRun(repo);
    fs.writeFileSync(path.join(repo.dir, RUN_REL, '.run.lock'), '99999');
    expectRed(cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'candidate', '--next', 'x'], repo.dir),
      1, 'run_locked', 'a held lock must block a second writer');
    fs.unlinkSync(path.join(repo.dir, RUN_REL, '.run.lock'));
    expectExit(cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'candidate', '--next', 'x'], repo.dir),
      0, 'releasing the lock must restore normal operation');
    expect(!fs.existsSync(path.join(repo.dir, RUN_REL, '.run.lock')),
      'the lock must be released after a successful command');
  }

  // 7. A derived-file edit is reported by EVERY command, not only resume (P2-1).
  {
    const repo = makeRepo();
    initRun(repo);
    const cpPath = path.join(repo.dir, RUN_REL, 'checkpoint.json');
    const cp = JSON.parse(fs.readFileSync(cpPath, 'utf8'));
    cp.verified = [{ slice: 'S1', seq: 99, at: 'forged', receipt_path: 'x', receipt_sha256: 'x', verified_head: 'x' }];
    fs.writeFileSync(cpPath, JSON.stringify(cp, null, 2));
    const res = cli(['checkpoint', '--run', RUN_REL, '--slice', 'S1', '--reason', 'candidate', '--next', 'x'], repo.dir);
    expectExit(res, 0, 'the journal remains authority, so the command still succeeds');
    expect(/WARNING/.test(res.out) && /checkpoint\.json/.test(res.out),
      'a silently-repaired derived file must still be reported, not erased');
  }
}

// ═════════════════════════ dogfood evidence checker ═════════════════════════

const EXPECTED_RUNS = [
  { id: 'interruption-a', interruption_stage: 'after-verified-slice' },
  { id: 'interruption-b', interruption_stage: 'after-action-started' },
  { id: 'interruption-c', interruption_stage: 'before-recovery-packet' },
];
const SOFT_FLOOR = 0.90;

function hashRef(errors, baseDir, ref, label) {
  if (!ref || typeof ref !== 'object' || !ref.path || !ref.sha256) {
    errors.push(`${label}: missing {path, sha256}`);
    return null;
  }
  const abs = path.resolve(baseDir, ref.path);
  if (!fs.existsSync(abs) || !fs.statSync(abs).isFile()) {
    errors.push(`${label}: raw file does not exist (${ref.path}) — a summary JSON alone is never evidence`);
    return null;
  }
  if (fs.statSync(abs).size === 0) { errors.push(`${label}: raw file is empty (${ref.path})`); return null; }
  const actual = sha256(abs);
  if (actual !== ref.sha256) {
    errors.push(`${label}: sha256 mismatch for ${ref.path} (declared ${ref.sha256.slice(0, 12)}…, actual ${actual.slice(0, 12)}…)`);
    return null;
  }
  return abs;
}

/**
 * Gate-3-consumed checker. It NEVER trusts recovery-scores.json on its own:
 * every claim must be backed by a raw file that exists, hashes correctly and
 * carries the verdict anchor. Returns a list of human-readable errors.
 */
export function checkDogfoodEvidence(scoresPath) {
  const errors = [];
  if (!fs.existsSync(scoresPath)) return [`recovery-scores.json not found at ${scoresPath}`];
  const baseDir = path.dirname(scoresPath);
  let doc;
  try { doc = JSON.parse(fs.readFileSync(scoresPath, 'utf8')); }
  catch (err) { return [`recovery-scores.json is not parseable: ${err.message}`]; }

  if (!Array.isArray(doc.runs)) return ['recovery-scores.json has no runs array'];
  if (doc.runs.length !== EXPECTED_RUNS.length) {
    errors.push(`expected exactly ${EXPECTED_RUNS.length} treatment runs, found ${doc.runs.length}`);
  }
  const ids = doc.runs.map((r) => r && r.id);
  for (const exp of EXPECTED_RUNS) {
    if (!ids.includes(exp.id)) errors.push(`missing required treatment run ${exp.id}`);
  }
  if (new Set(ids).size !== ids.length) errors.push('treatment run ids are not unique (duplicated treatment)');
  const runDirs = doc.runs.map((r) => r && r.run_dir);
  if (new Set(runDirs).size !== runDirs.length) errors.push('treatment run_dir values are not unique');
  const worktrees = doc.runs.map((r) => r && r.worktree_realpath);
  if (new Set(worktrees).size !== worktrees.length) errors.push('treatment worktrees are not unique (runs were not isolated)');

  const control = doc.control;
  if (!control) {
    errors.push('control run is missing — the dogfood baseline cannot be established');
  } else {
    if (worktrees.includes(control.worktree_realpath)) errors.push('control shares a worktree with a treatment run');
    hashRef(errors, baseDir, control.report, 'control.report');
    hashRef(errors, baseDir, control.hidden_acceptance, 'control.hidden_acceptance');
    const g = hashRef(errors, baseDir, control.gate, 'control.gate');
    if (g && control.gate.verdict !== 'PASS') errors.push('control.gate verdict is not PASS');
    if (control.evidence_envelope) {
      const abs = hashRef(errors, baseDir, control.evidence_envelope, 'control.evidence_envelope');
      if (abs) {
        let env;
        try { env = JSON.parse(fs.readFileSync(abs, 'utf8')); } catch { env = null; }
        if (!env) errors.push('control-evidence.json is not parseable');
        else {
          if (env.base_commit !== control.base_commit) errors.push('control envelope base_commit disagrees with the score index');
          if (env.input_sha256 !== control.input_sha256) errors.push('control envelope input_sha256 disagrees with the score index');
          if (env.worktree_realpath !== control.worktree_realpath) errors.push('control envelope worktree disagrees with the score index');
        }
      }
    } else {
      errors.push('control.evidence_envelope (control-evidence.json) is missing');
    }
  }

  for (const run of doc.runs) {
    if (!run || !run.id) { errors.push('a run entry has no id'); continue; }
    const tag = run.id;
    const expected = EXPECTED_RUNS.find((e) => e.id === tag);
    if (expected && run.interruption_stage !== expected.interruption_stage) {
      errors.push(`${tag}: interruption_stage is "${run.interruption_stage}", expected "${expected.interruption_stage}"`);
    }
    if (control) {
      if (run.base_commit !== control.base_commit) errors.push(`${tag}: base_commit differs from control (not the same starting point)`);
      if (run.input_sha256 !== control.input_sha256) errors.push(`${tag}: input_sha256 differs from control (not the same input)`);
    }
    if (!run.run_dir || !fs.existsSync(path.resolve(baseDir, run.run_dir))) {
      errors.push(`${tag}: run_dir does not exist (${run.run_dir})`);
    } else {
      for (const f of ['goal.json', 'journal.jsonl']) {
        if (!fs.existsSync(path.resolve(baseDir, run.run_dir, f))) errors.push(`${tag}: archived run is missing ${f}`);
      }
    }

    const assertionAbs = hashRef(errors, baseDir, run.assertion, `${tag}.assertion`);
    const oracleAbs = hashRef(errors, baseDir, run.oracle, `${tag}.oracle`);
    hashRef(errors, baseDir, run.continuation, `${tag}.continuation`);
    const gateAbs = hashRef(errors, baseDir, run.gate, `${tag}.gate`);
    const receiptAbs = hashRef(errors, baseDir, run.receipt, `${tag}.receipt`);

    if (gateAbs) {
      if (run.gate.verdict !== 'PASS') errors.push(`${tag}: gate verdict is not PASS`);
      const gateText = fs.readFileSync(gateAbs, 'utf8');
      if (!/PASS/.test(gateText)) errors.push(`${tag}: gate evidence file carries no PASS anchor`);
    }
    if (receiptAbs) {
      let rec = null;
      try { rec = JSON.parse(fs.readFileSync(receiptAbs, 'utf8')); } catch { /* handled below */ }
      if (!rec) errors.push(`${tag}: receipt is not parseable JSON`);
      else {
        if (rec.verdict !== 'PASS') errors.push(`${tag}: receipt verdict is not PASS`);
        if (rec.written_by !== 'conductor') errors.push(`${tag}: receipt was not written by the conductor`);
        if (rec.written_by_id === rec.executor_id) errors.push(`${tag}: receipt is self-authored by the executor`);
      }
    }

    if (typeof run.hard_total !== 'number' || run.hard_total <= 0) {
      errors.push(`${tag}: hard_total must be a positive number`);
    } else if (run.hard_correct !== run.hard_total) {
      errors.push(`${tag}: hard anchors ${run.hard_correct}/${run.hard_total} — hard anchors must be 100%`);
    }
    if (typeof run.soft_score !== 'number' || run.soft_score < SOFT_FLOOR) {
      errors.push(`${tag}: soft_score ${run.soft_score} is below the ${SOFT_FLOOR} floor`);
    }
    if (run.wrong_or_unauthorized_next_action !== 0) errors.push(`${tag}: wrong_or_unauthorized_next_action must be 0`);
    if (run.repeated_verified_slice !== 0) errors.push(`${tag}: repeated_verified_slice must be 0`);
    if (run.continued !== true) errors.push(`${tag}: the run did not actually continue`);
    if (run.hidden_acceptance_passed !== true) errors.push(`${tag}: hidden acceptance did not pass`);
    if (run.gate_passed !== true) errors.push(`${tag}: gate did not pass`);
    if (!run.reviewer || run.reviewer.independent !== true) errors.push(`${tag}: reviewer was not independent`);

    // Machine-readable envelope: markdown grep is never the authority.
    const envRef = run.evidence_envelope;
    const envAbs = hashRef(errors, baseDir, envRef, `${tag}.evidence_envelope`);
    if (!envAbs) { errors.push(`${tag}: run-evidence.json is missing or unverifiable`); continue; }
    let env = null;
    try { env = JSON.parse(fs.readFileSync(envAbs, 'utf8')); } catch { /* handled */ }
    if (!env) { errors.push(`${tag}: run-evidence.json is not parseable`); continue; }
    if (env.format !== 'yolo-recovery-dogfood-evidence-v1') errors.push(`${tag}: envelope format is wrong`);
    if (env.run_id !== run.id) errors.push(`${tag}: envelope run_id disagrees with the index`);
    if (env.interruption_stage !== run.interruption_stage) errors.push(`${tag}: envelope stage disagrees with the index`);
    if (env.base_commit !== run.base_commit) errors.push(`${tag}: envelope base_commit disagrees with the index`);
    if (env.input_sha256 !== run.input_sha256) errors.push(`${tag}: envelope input_sha256 disagrees with the index`);
    if (env.worktree_realpath !== run.worktree_realpath) errors.push(`${tag}: envelope worktree disagrees with the index`);
    if (!env.fresh_session || env.fresh_session.prior_transcript_provided !== false) {
      errors.push(`${tag}: envelope does not record that the recovering context got NO prior transcript`);
    }
    hashRef(errors, baseDir, env.fresh_session && env.fresh_session.prompt_path
      ? { path: env.fresh_session.prompt_path, sha256: env.fresh_session.prompt_sha256 }
      : null, `${tag}.fresh_session.prompt`);
    if (!env.oracle || env.oracle.frozen_before_run !== true) errors.push(`${tag}: oracle was not frozen before the run`);
    if (assertionAbs && env.assertion && env.assertion.sha256 !== run.assertion.sha256) {
      errors.push(`${tag}: envelope assertion hash disagrees with the index`);
    }
    if (oracleAbs && env.oracle && env.oracle.sha256 !== run.oracle.sha256) {
      errors.push(`${tag}: envelope oracle hash disagrees with the index`);
    }
    const rev = env.review;
    if (!rev) errors.push(`${tag}: envelope has no review block`);
    else {
      hashRef(errors, baseDir, { path: rev.path, sha256: rev.sha256 }, `${tag}.review`);
      if (rev.independent !== true) errors.push(`${tag}: envelope review is not independent`);
      if (rev.verdict !== 'PASS') errors.push(`${tag}: envelope review verdict is not PASS`);
      if (env.assertion && rev.assertion_sha256 !== env.assertion.sha256) {
        errors.push(`${tag}: review is not bound to the assertion it scored`);
      }
      if (env.oracle && rev.oracle_sha256 !== env.oracle.sha256) {
        errors.push(`${tag}: review is not bound to the frozen oracle`);
      }
      if (env.assertion && rev.author_id === env.assertion.author_id) {
        errors.push(`${tag}: the reviewer is the author of the assertion (self-scoring)`);
      }
      if (rev.hard_total !== run.hard_total || rev.hard_correct !== run.hard_correct) {
        errors.push(`${tag}: review hard score disagrees with the index`);
      }
      if (rev.soft_score !== run.soft_score) errors.push(`${tag}: review soft score disagrees with the index`);
    }
  }
  return errors;
}

// ── synthetic dogfood fixture (valid by construction, then tampered) ──

function buildDogfoodFixture(dir) {
  const BASE = 'a'.repeat(40);
  const INPUT = 'b'.repeat(64);
  const write = (rel, body) => {
    const abs = path.join(dir, rel);
    fs.mkdirSync(path.dirname(abs), { recursive: true });
    fs.writeFileSync(abs, body);
    return { path: rel, sha256: sha256(abs) };
  };
  const runs = EXPECTED_RUNS.map((exp, i) => {
    const id = exp.id;
    const assertion = write(`${id}/assertion.md`, `# assertion for ${id}\nall anchors\n`);
    const oracle = write(`${id}/oracle.md`, `# frozen oracle for ${id}\n`);
    const continuation = write(`${id}/continuation.md`, `# continuation log ${id}\n`);
    const gate = write(`${id}/gate.md`, `Gate verdict: PASS for ${id}\n`);
    const review = write(`${id}/review.md`, `Independent review of ${id}: PASS\n`);
    const prompt = write(`${id}/fresh-prompt.txt`, `Only the run path is given for ${id}.\n`);
    const receiptBody = JSON.stringify({
      format: 'yolo-recovery-verification-v1', verdict: 'PASS', run_id: id, slice: 'S1',
      executor_id: `executor-${id}`, written_by: 'conductor', written_by_id: 'conductor-1',
    }, null, 2);
    const receipt = write(`${id}/receipt.json`, receiptBody);
    write(`${id}/run/goal.json`, '{"format":"yolo-recovery-phase1-v1"}\n');
    write(`${id}/run/journal.jsonl`, '{"seq":1}\n');
    write(`${id}.md`, `# ${id} report\n`);
    const env = {
      format: 'yolo-recovery-dogfood-evidence-v1',
      run_id: id,
      interruption_stage: exp.interruption_stage,
      base_commit: BASE,
      input_sha256: INPUT,
      worktree_realpath: `/tmp/wt-${id}`,
      fresh_session: {
        session_id: `sess-${id}`, prior_transcript_provided: false,
        prompt_path: prompt.path, prompt_sha256: prompt.sha256,
      },
      assertion: { ...assertion, author_id: `fresh-agent-${id}` },
      oracle: { ...oracle, frozen_before_run: true },
      review: {
        ...review, author_id: `reviewer-${i}`, independent: true,
        assertion_sha256: assertion.sha256, oracle_sha256: oracle.sha256,
        hard_total: 8, hard_correct: 8, soft_score: 0.95, verdict: 'PASS',
      },
      continuation: { ...continuation, repeated_verified_slice: 0 },
      gate: { ...gate, verdict: 'PASS' },
      receipt,
    };
    const envRef = write(`${id}/run-evidence.json`, JSON.stringify(env, null, 2));
    return {
      id,
      interruption_stage: exp.interruption_stage,
      run_dir: `${id}/run`,
      base_commit: BASE,
      input_sha256: INPUT,
      worktree_realpath: `/tmp/wt-${id}`,
      assertion, oracle, continuation,
      gate: { ...gate, verdict: 'PASS' },
      receipt,
      evidence_envelope: envRef,
      hard_total: 8, hard_correct: 8, soft_score: 0.95,
      wrong_or_unauthorized_next_action: 0,
      repeated_verified_slice: 0,
      continued: true,
      hidden_acceptance_passed: true,
      gate_passed: true,
      reviewer: { independent: true, evidence: review.path },
    };
  });

  const cReport = write('control.md', '# control report\n');
  const cHidden = write('control/hidden-acceptance.txt', 'hidden acceptance: PASS\n');
  const cGate = write('control/gate.md', 'Gate verdict: PASS for control\n');
  const cEnvRef = write('control/control-evidence.json', JSON.stringify({
    format: 'yolo-recovery-dogfood-evidence-v1',
    run_id: 'control', base_commit: BASE, input_sha256: INPUT,
    worktree_realpath: '/tmp/wt-control',
    gate: { ...cGate, verdict: 'PASS' },
  }, null, 2));

  const doc = {
    control: {
      base_commit: BASE, input_sha256: INPUT, worktree_realpath: '/tmp/wt-control',
      report: cReport, hidden_acceptance: cHidden, gate: { ...cGate, verdict: 'PASS' },
      evidence_envelope: cEnvRef,
    },
    runs,
  };
  const scores = path.join(dir, 'recovery-scores.json');
  fs.writeFileSync(scores, JSON.stringify(doc, null, 2));
  return scores;
}

function tamper(mutate) {
  const dir = tmpDir('yolo-rec-dogfood-');
  const scores = buildDogfoodFixture(dir);
  const doc = JSON.parse(fs.readFileSync(scores, 'utf8'));
  mutate(doc, dir);
  fs.writeFileSync(scores, JSON.stringify(doc, null, 2));
  return checkDogfoodEvidence(scores);
}

function caseDogfoodEvidence() {
  // 0. The synthetic fixture is valid by construction — the checker must accept it.
  const cleanDir = tmpDir('yolo-rec-dogfood-');
  const cleanScores = buildDogfoodFixture(cleanDir);
  const cleanErrors = checkDogfoodEvidence(cleanScores);
  expect(cleanErrors.length === 0, `checker must accept a well-formed fixture, got: ${cleanErrors.join(' | ')}`);

  // 1..n. Every negative control must turn the checker red.
  const negatives = [
    ['summary-only forgery (raw files deleted)', (doc, dir) => {
      fs.rmSync(path.join(dir, 'interruption-a/assertion.md'));
    }],
    ['hash mismatch', (doc, dir) => {
      fs.appendFileSync(path.join(dir, 'interruption-b/review.md'), 'tampered\n');
    }],
    ['duplicated treatment', (doc) => { doc.runs[2] = JSON.parse(JSON.stringify(doc.runs[1])); }],
    ['missing control', (doc) => { delete doc.control; }],
    ['control baseline drift', (doc) => { doc.control.base_commit = 'z'.repeat(40); }],
    ['different input than control', (doc) => { doc.runs[0].input_sha256 = 'c'.repeat(64); }],
    ['shared worktree between treatments', (doc) => { doc.runs[1].worktree_realpath = doc.runs[0].worktree_realpath; }],
    ['wrong interruption stage', (doc) => { doc.runs[0].interruption_stage = 'after-action-started'; }],
    ['hard anchors below 100%', (doc) => { doc.runs[0].hard_correct = 7; }],
    ['zero hard anchors', (doc) => { doc.runs[1].hard_total = 0; doc.runs[1].hard_correct = 0; }],
    ['soft score below floor', (doc) => { doc.runs[2].soft_score = 0.89; }],
    ['repeated verified slice', (doc) => { doc.runs[0].repeated_verified_slice = 1; }],
    ['unauthorized next action', (doc) => { doc.runs[1].wrong_or_unauthorized_next_action = 1; }],
    ['run did not continue', (doc) => { doc.runs[2].continued = false; }],
    ['hidden acceptance failed', (doc) => { doc.runs[0].hidden_acceptance_passed = false; }],
    ['gate not PASS', (doc) => { doc.runs[1].gate.verdict = 'FAIL'; }],
    ['non-independent reviewer', (doc) => { doc.runs[0].reviewer.independent = false; }],
    ['missing run-evidence envelope', (doc) => { delete doc.runs[0].evidence_envelope; }],
    ['envelope index disagreement', (doc, dir) => {
      const p = path.join(dir, 'interruption-c/run-evidence.json');
      const env = JSON.parse(fs.readFileSync(p, 'utf8'));
      env.base_commit = 'd'.repeat(40);
      fs.writeFileSync(p, JSON.stringify(env, null, 2));
      doc.runs[2].evidence_envelope.sha256 = sha256(p);
    }],
    ['reviewer is the assertion author', (doc, dir) => {
      const p = path.join(dir, 'interruption-a/run-evidence.json');
      const env = JSON.parse(fs.readFileSync(p, 'utf8'));
      env.review.author_id = env.assertion.author_id;
      fs.writeFileSync(p, JSON.stringify(env, null, 2));
      doc.runs[0].evidence_envelope.sha256 = sha256(p);
    }],
    ['review not bound to the oracle', (doc, dir) => {
      const p = path.join(dir, 'interruption-b/run-evidence.json');
      const env = JSON.parse(fs.readFileSync(p, 'utf8'));
      env.review.oracle_sha256 = 'e'.repeat(64);
      fs.writeFileSync(p, JSON.stringify(env, null, 2));
      doc.runs[1].evidence_envelope.sha256 = sha256(p);
    }],
    ['prior transcript was provided', (doc, dir) => {
      const p = path.join(dir, 'interruption-c/run-evidence.json');
      const env = JSON.parse(fs.readFileSync(p, 'utf8'));
      env.fresh_session.prior_transcript_provided = true;
      fs.writeFileSync(p, JSON.stringify(env, null, 2));
      doc.runs[2].evidence_envelope.sha256 = sha256(p);
    }],
    ['oracle not frozen before the run', (doc, dir) => {
      const p = path.join(dir, 'interruption-a/run-evidence.json');
      const env = JSON.parse(fs.readFileSync(p, 'utf8'));
      env.oracle.frozen_before_run = false;
      fs.writeFileSync(p, JSON.stringify(env, null, 2));
      doc.runs[0].evidence_envelope.sha256 = sha256(p);
    }],
    ['archived run directory removed', (doc, dir) => {
      fs.rmSync(path.join(dir, 'interruption-b/run'), { recursive: true, force: true });
    }],
    ['self-authored per-run receipt', (doc, dir) => {
      const p = path.join(dir, 'interruption-a/receipt.json');
      const rec = JSON.parse(fs.readFileSync(p, 'utf8'));
      rec.written_by_id = rec.executor_id;
      fs.writeFileSync(p, JSON.stringify(rec, null, 2));
      doc.runs[0].receipt.sha256 = sha256(p);
    }],
    ['only two treatments', (doc) => { doc.runs.pop(); }],
  ];
  for (const [name, mutate] of negatives) {
    const errs = tamper(mutate);
    expect(errs.length > 0, `negative control "${name}" must turn the dogfood checker red`);
  }

  // Final: the REAL Phase 1 evidence must pass the same checker.
  const realScores = path.join(PHASE1, 'dogfood', 'recovery-scores.json');
  const realErrors = checkDogfoodEvidence(realScores);
  expect(realErrors.length === 0,
    `real dogfood evidence must satisfy the checker:\n  - ${realErrors.join('\n  - ')}`);
}

// ═════════════════════════ CASE: required-evidence ═════════════════════════

const ALLOW_EXACT = [
  '.tad/scripts/yolo-recovery.mjs',
  '.tad/scripts/yolo-recovery.test.mjs',
  '.tad/guides/yolo-recovery.md',
  // Gate 4 corrective amendment (2026-08-25): TAD lifecycle artifacts the
  // design/completion/knowledge-capture flow itself must persist. Exact paths
  // only — this must never grow into a product/runtime scope expansion.
  '.tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md',
  '.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md',
  '.tad/decisions/DR-20260824-yolo2-orchestration-kernel.md',
  '.tad/decisions/DR-20260824-yolo2-vertical-slice-first.md',
  '.tad/project-knowledge/patterns/memory-and-learning.md',
  'NEXT.md',
  // Added after the fact with disclosure: Alex's own Gate 4 amendment commit
  // 276f6ac9 updates PROJECT_CONTEXT.md as part of this task's gate flow
  // (project status lifecycle doc, not product code). Flagged for the
  // independent checker review.
  'PROJECT_CONTEXT.md',
];
// Gate 4 lifecycle amendment round 2: the post-*accept archive locations are
// legal diff members ONLY while the archived lifecycle state is the real one.
// They are deliberately NOT in ALLOW_EXACT (which asserts must-appear); a
// change touching them without the archived pair actually existing stays red.
const ALLOW_LIFECYCLE_ARCHIVE = [
  '.tad/archive/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md',
  '.tad/archive/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md',
];
const ALLOW_PREFIX = [
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/',
  '.tad/evidence/reviews/blake/yolo2-phase1/',
  '.tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md',
];

/** Pure lifecycle state machine (Gate 4 round 2). Exactly one matching
 *  Handoff/COMPLETION pair is valid: both active, or both archived. Missing,
 *  split, duplicated, or half-present pairs fail with machine-readable codes
 *  so fixtures can drive every state without touching real files. */
export function checkLifecyclePair(exists) {
  const P = {
    handoff: {
      active: '.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md',
      archived: '.tad/archive/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md',
    },
    completion: {
      active: '.tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md',
      archived: '.tad/archive/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md',
    },
  };
  const ah = !!exists(P.handoff.active);
  const arh = !!exists(P.handoff.archived);
  const ac = !!exists(P.completion.active);
  const arc = !!exists(P.completion.archived);
  const shape = JSON.stringify({ handoff_active: ah, handoff_archived: arh, completion_active: ac, completion_archived: arc });
  if ((ah && arh) || (ac && arc)) {
    return { state: 'duplicate', errors: [`lifecycle_duplicate: a Handoff/COMPLETION copy exists in BOTH .tad/active/handoffs/ and .tad/archive/handoffs/ ${shape}`] };
  }
  if (!ah && !arh && !ac && !arc) {
    return { state: 'absent', errors: ['lifecycle_absent: neither an active nor an archived Handoff/COMPLETION pair exists'] };
  }
  const handoffSide = ah ? 'active' : (arh ? 'archived' : null);
  const completionSide = ac ? 'active' : (arc ? 'archived' : null);
  if (handoffSide === null || completionSide === null) {
    return { state: 'incomplete', errors: [`lifecycle_incomplete: only one file of the pair exists (handoff=${handoffSide ?? 'missing'}, completion=${completionSide ?? 'missing'})`] };
  }
  if (handoffSide !== completionSide) {
    return { state: 'split', errors: [`lifecycle_split: the pair is split across directories (handoff=${handoffSide}, completion=${completionSide})`] };
  }
  return { state: handoffSide, errors: [] };
}

/** Pure allowlist comparison so the rule itself has a red state. */
export function offAllowlist(paths) {
  return paths.filter((p) => !ALLOW_EXACT.includes(p)
    && !ALLOW_PREFIX.some((pre) => p.startsWith(pre))
    && !ALLOW_LIFECYCLE_ARCHIVE.includes(p));
}

const REQUIRED_EVIDENCE = [
  '.tad/evidence/reviews/blake/yolo2-phase1/code-reviewer.md',
  '.tad/evidence/reviews/blake/yolo2-phase1/architecture-reviewer.md',
  '.tad/evidence/reviews/blake/yolo2-phase1/security-reviewer.md',
  '.tad/evidence/reviews/blake/yolo2-phase1/performance-reviewer.md',
  '.tad/evidence/reviews/blake/yolo2-phase1/spec-compliance.md',
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/gate3-verdict.md',
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/capsule-budget.md',
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/deterministic-fixtures.txt',
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/knowledge-assessment.md',
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/control.md',
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/interruption-a.md',
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/interruption-b.md',
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/interruption-c.md',
  '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/recovery-scores.json',
  // NOTE: the Handoff/COMPLETION pair is intentionally NOT listed here — it is
  // resolved through the lifecycle state machine below (Gate 4 round 2).
];

/** Exhaustive fixture for the pure state machine: every one of the 16
 *  existence combinations must classify exactly as the amendment requires.
 *  Combo order: [handoff_active, handoff_archived, completion_active,
 *  completion_archived]. `null` = invalid (must fail), otherwise the required
 *  state string. */
const LIFECYCLE_COMBOS = [
  ['0000', 'lifecycle_absent'],
  ['1000', 'lifecycle_incomplete'], ['0100', 'lifecycle_incomplete'],
  ['0010', 'lifecycle_incomplete'], ['0001', 'lifecycle_incomplete'],
  ['1100', 'lifecycle_duplicate'], ['0011', 'lifecycle_duplicate'],
  ['1110', 'lifecycle_duplicate'], ['1101', 'lifecycle_duplicate'],
  ['1011', 'lifecycle_duplicate'], ['0111', 'lifecycle_duplicate'],
  ['1111', 'lifecycle_duplicate'],
  ['1001', 'lifecycle_split'], ['0110', 'lifecycle_split'],
  ['1010', 'active'], ['0101', 'archived'],
];

function caseRequiredEvidence() {
  // Negative control for the allowlist rule itself.
  expect(offAllowlist(['.tad/scripts/yolo-recovery.mjs']).length === 0, 'allowlisted path must be accepted');
  expect(offAllowlist(['.claude/workflows/yolo-epic.workflow.js']).length === 1,
    'an out-of-scope path must be reported');
  expect(offAllowlist(['.tad/hooks/precompact-session-snapshot.sh']).length === 1,
    'touching hooks must be reported');
  expect(offAllowlist(['.agents/skills/alex/references/yolo-execution-protocol.md']).length === 1,
    'touching the YOLO execution protocol must be reported');
  expect(offAllowlist(['.tad/config.yaml']).length === 1,
    'touching config must be reported');
  // The archive locations are legal diff members only as a pair-state
  // consequence; the paths themselves must never satisfy must-appear.
  expect(ALLOW_EXACT.includes('.tad/archive/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md') === false,
    'archive paths must not carry a must-appear assertion');

  // Exhaustive pure-machine fixture: all 16 existence combinations.
  for (const [combo, expected] of LIFECYCLE_COMBOS) {
    const r = checkLifecyclePair((p) => {
      if (p === '.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md') return combo[0] === '1';
      if (p === '.tad/archive/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md') return combo[1] === '1';
      if (p === '.tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md') return combo[2] === '1';
      if (p === '.tad/archive/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md') return combo[3] === '1';
      throw new Error(`fixture asked about an unknown path: ${p}`);
    });
    const valid = expected === 'active' || expected === 'archived';
    if (valid) {
      expect(r.errors.length === 0 && r.state === expected,
        `combo ${combo} must resolve to state "${expected}", got ${JSON.stringify(r)}`);
    } else {
      expect(r.errors.length === 1 && r.errors[0].startsWith(expected),
        `combo ${combo} must fail as "${expected}", got ${JSON.stringify(r)}`);
    }
  }

  const basePath = path.join(PHASE1, 'base-commit.txt');
  expect(fs.existsSync(basePath), `frozen base commit file missing: ${basePath}`);
  const base = fs.readFileSync(basePath, 'utf8').trim();
  expect(/^[0-9a-f]{40}$/.test(base), `frozen base commit is not a sha: ${base}`);

  // ── Lifecycle resolution (Gate 4 round 2) ────────────────────────────────
  // YOLO2_LIFECYCLE_SIM=archive simulates the post-*accept layout WITHOUT
  // touching real files: the archive copies are reported present and their
  // content size is taken from the active counterpart (an accept-archive is a
  // move, so content is identical by construction). Real runs leave the env
  // unset and read the filesystem directly.
  const SIM_ARCHIVE = process.env.YOLO2_LIFECYCLE_SIM === 'archive';
  const ACTIVE_PAIR = {
    '.tad/archive/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md':
      '.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md',
    '.tad/archive/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md':
      '.tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md',
  };
  const lifecycleExists = (rel) => {
    if (SIM_ARCHIVE && ACTIVE_PAIR[rel]) return false; // active copy gone after the move
    if (SIM_ARCHIVE && ALLOW_LIFECYCLE_ARCHIVE.includes(rel)) return true;
    return fs.existsSync(path.join(REPO_ROOT, rel));
  };
  const lifecycle = checkLifecyclePair(lifecycleExists);
  expect(lifecycle.errors.length === 0,
    `task lifecycle is not in a valid state:\n  - ${lifecycle.errors.join('\n  - ')}`);

  const missing = REQUIRED_EVIDENCE.filter((rel) => {
    const abs = path.join(REPO_ROOT, rel);
    return !fs.existsSync(abs) || fs.statSync(abs).size === 0;
  });
  // The resolved pair files must exist and be non-empty. Under the simulated
  // archive state the content size comes from the active counterpart (move
  // semantics); under the real archived state these are ordinary disk reads.
  const pairPaths = {
    handoff: lifecycle.state === 'archived'
      ? '.tad/archive/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md'
      : '.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md',
    completion: lifecycle.state === 'archived'
      ? '.tad/archive/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md'
      : '.tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md',
  };
  for (const rel of Object.values(pairPaths)) {
    let ok;
    if (SIM_ARCHIVE && ALLOW_LIFECYCLE_ARCHIVE.includes(rel)) {
      ok = fs.existsSync(path.join(REPO_ROOT, ACTIVE_PAIR[rel]))
        && fs.statSync(path.join(REPO_ROOT, ACTIVE_PAIR[rel])).size > 0;
    } else {
      ok = fs.existsSync(path.join(REPO_ROOT, rel)) && fs.statSync(path.join(REPO_ROOT, rel)).size > 0;
    }
    if (!ok) missing.push(rel);
  }
  expect(missing.length === 0, `required evidence missing or empty:\n  - ${missing.join('\n  - ')}`);

  const changed = git(['diff', '--name-only', `${base}..HEAD`], REPO_ROOT).split('\n').filter(Boolean);
  const off = offAllowlist(changed);
  expect(off.length === 0, `committed changes outside the declared scope:\n  - ${off.join('\n  - ')}`);
  for (const rel of ALLOW_EXACT) {
    expect(changed.includes(rel), `expected ${rel} to be part of the committed diff since ${base.slice(0, 8)}`);
  }
}

// ═════════════════════════ runner ═════════════════════════

const CASES = {
  'path-guard': casePathGuard,
  'lifecycle-e2e': caseLifecycleE2e,
  'verified-authority': caseVerifiedAuthority,
  'authority-conflicts': caseAuthorityConflicts,
  'side-effect-reconcile': caseSideEffectReconcile,
  'status-capsule': caseStatusCapsule,
  'atomic-write': caseAtomicWrite,
  'binding-and-closure': caseBindingAndClosure,
  'dogfood-evidence': caseDogfoodEvidence,
  'required-evidence': caseRequiredEvidence,
};

function main() {
  const argv = process.argv.slice(2);
  let only = null;
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === '--case') only = argv[i + 1];
  }
  const names = only ? [only] : Object.keys(CASES);
  if (only && !CASES[only]) {
    process.stdout.write(`CASE=${only} RESULT=FAIL  unknown case\nRESULT=FAIL\n`);
    return 1;
  }
  let failed = 0;
  for (const name of names) {
    try {
      CASES[name]();
      process.stdout.write(`CASE=${name} RESULT=PASS\n`);
    } catch (err) {
      failed += 1;
      const detail = err instanceof CaseFail ? err.message : `${err.name}: ${err.message}`;
      process.stdout.write(`CASE=${name} RESULT=FAIL\n  ${detail}\n`);
      if (!(err instanceof CaseFail) && process.env.YOLO_REC_TEST_TRACE) {
        process.stdout.write(`${err.stack}\n`);
      }
    }
  }
  process.stdout.write(`RESULT=${failed === 0 ? 'PASS' : 'FAIL'}\n`);
  return failed === 0 ? 0 : 1;
}

let exitCode = 1;
try {
  exitCode = main();
} finally {
  cleanupTmp();
}
process.exit(exitCode);
