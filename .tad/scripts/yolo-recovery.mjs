#!/usr/bin/env node
/**
 * yolo-recovery.mjs — TAD YOLO 2.0 Phase 1 opt-in recovery recorder.
 *
 * Purpose (Phase 1 scope only):
 *   Freeze the goal of ONE real YOLO run, record the few facts recovery needs,
 *   derive a bounded recovery packet, and refuse to advance "verified" progress
 *   unless a Conductor-authored, tightly-bound PASS receipt says so.
 *
 * This is NOT: a workflow engine, a Gate, a general verifier, a sandbox, or a
 * cross-harness adapter. It never reads chat history, compact summaries or
 * .tad/active/session-state.md.
 *
 * Authority order (highest first):
 *   1. approved handoff revision + immutable goal.json
 *   2. fully parseable journal.jsonl + its evidence pointers
 *   3. rebuildable checkpoint.json
 *   4. recovery.md / session-state / PreCompact snapshots — navigation only
 *
 * Exit contract:
 *   0 = PASS, 1 = contract failure (honest_partial), 2 = usage/input error.
 *   The LAST line of stdout is always a single-line JSON status object.
 *
 * Runtime: Node built-ins only. See .tad/guides/yolo-recovery.md for the
 * derived minimum Node version (computed from the APIs actually used here).
 */

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

// ─────────────────────────── constants ───────────────────────────

export const GOAL_FORMAT = 'yolo-recovery-phase1-v1';
export const RECEIPT_FORMAT = 'yolo-recovery-verification-v1';
export const CHECKPOINT_FORMAT = 'yolo-recovery-checkpoint-v1';
export const STATUS_FORMAT = 'yolo-recovery-status-v1';

export const EVENT_TYPES = [
  'initialized',
  'checkpointed',
  'verified',
  'action_started',
  'action_reconciled',
  'stopped',
];
export const CHECKPOINT_REASONS = ['before-compact', 'before-stop', 'candidate'];
export const RECONCILE_OUTCOMES = ['confirmed', 'outcome_unknown', 'reconciled'];

const RUN_ROOT_REL = path.join('.tad', 'evidence', 'yolo');
export const CAPSULE_TOKEN_BUDGET = 2500;

/** Labels that MUST appear in both `status` output and recovery.md (MQ4 / AC9). */
export const REQUIRED_LABELS = [
  'GOAL',
  'HANDOFF REVISION',
  'VERIFIED',
  'UNVERIFIED',
  'BLOCKED',
  'OUTCOME_UNKNOWN',
  'PENDING ACTION',
  'LEGAL NEXT ACTION',
  'OWNER',
  'RESUME COMMAND',
];

const COMMANDS = [
  'init', 'status', 'checkpoint', 'verify',
  'action-start', 'reconcile', 'resume', 'stop',
];

// ─────────────────────────── errors ───────────────────────────

export class UsageError extends Error {
  constructor(reason, details = {}) {
    super(reason);
    this.kind = 'usage';
    this.reason = reason;
    this.details = details;
  }
}
export class ContractError extends Error {
  constructor(reason, details = {}) {
    super(reason);
    this.kind = 'contract';
    this.reason = reason;
    this.details = details;
  }
}

// ─────────────────────────── small helpers ───────────────────────────

export function sha256File(p) {
  return crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
}
export function sha256String(s) {
  return crypto.createHash('sha256').update(s).digest('hex');
}

/**
 * Token estimate. ASCII ~4 chars/token; non-ASCII (CJK) counted as ~1 token per
 * character, which is deliberately conservative — we would rather report
 * over-budget too early than smuggle an oversized capsule through.
 */
export function estimateTokens(text) {
  let ascii = 0;
  let wide = 0;
  for (const ch of text) {
    if (ch.codePointAt(0) < 128) ascii += 1;
    else wide += 1;
  }
  return Math.ceil(ascii / 4) + wide;
}

function isPlainObject(v) {
  return v !== null && typeof v === 'object' && !Array.isArray(v);
}

function nowIso() {
  return new Date().toISOString();
}

/** Resolve a path, following symlinks on the deepest EXISTING ancestor. */
export function realpathDeepest(p) {
  let cur = path.resolve(p);
  const tail = [];
  // Bounded: filesystem depth is finite and each iteration strips one segment.
  for (let i = 0; i < 4096; i += 1) {
    if (fs.existsSync(cur)) break;
    const parent = path.dirname(cur);
    if (parent === cur) break;
    tail.unshift(path.basename(cur));
    cur = parent;
  }
  const real = fs.existsSync(cur) ? fs.realpathSync(cur) : cur;
  return tail.length ? path.join(real, ...tail) : real;
}

/** Throw unless `target` is strictly inside `base`. */
export function assertInside(base, target, label) {
  const rel = path.relative(base, target);
  if (rel === '' || rel.startsWith('..') || path.isAbsolute(rel)) {
    throw new UsageError('path_escape', { label, path: target, base });
  }
  return target;
}

// ─────────────────────────── git identity ───────────────────────────

function git(args, cwd) {
  try {
    return execFileSync('git', args, { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
  } catch (err) {
    throw new ContractError('git_unavailable', { args, message: String(err && err.message).slice(0, 200) });
  }
}

/** Real worktree root + current HEAD + a dirty-file count (observation only). */
export function readGitIdentity(cwd) {
  const root = git(['rev-parse', '--show-toplevel'], cwd);
  const head = git(['rev-parse', 'HEAD'], cwd);
  // Observation only — must never be able to fail a command (security MEDIUM-5).
  let dirtyPaths = [];
  try {
    const porcelain = git(['status', '--porcelain'], cwd);
    dirtyPaths = porcelain ? porcelain.split('\n').filter(Boolean).map((l) => l.slice(3)) : [];
  } catch {
    dirtyPaths = null;
  }
  return {
    worktree_realpath: fs.realpathSync(root),
    head,
    dirty_paths: dirtyPaths,
    dirty_count: dirtyPaths === null ? null : dirtyPaths.length,
  };
}

// ─────────────────────────── path scope ───────────────────────────

/**
 * Anchor a relative path at the REPO ROOT, not at process.cwd().
 * Security review HIGH-2: every documented path (the guide's commands, the goal
 * spec's `oracle_path`, a receipt's `gate_evidence[].path`) is repo-relative,
 * but `path.resolve` anchors at cwd. Agent harnesses change cwd freely, so a
 * subdirectory cwd silently bound a run to a DIFFERENT handoff file that the
 * human never approved — with exit 0 and no warning.
 */
function anchorAtRepo(input, repoRoot) {
  return path.isAbsolute(input) ? input : path.join(repoRoot, input);
}

/** Anchor-and-resolve that returns null instead of throwing on an escape. */
function anchorAtRepoSafe(input, repoRoot) {
  try {
    const target = realpathDeepest(anchorAtRepo(input, repoRoot));
    return assertInside(repoRoot, target, 'recorded_path');
  } catch {
    return null;
  }
}

export function resolveRunDir(input, repoRoot) {
  if (!input) throw new UsageError('missing_flag', { flag: '--run' });
  const base = realpathDeepest(path.join(repoRoot, RUN_ROOT_REL));
  const target = realpathDeepest(anchorAtRepo(input, repoRoot));
  return assertInside(base, target, 'run_dir');
}

/** Resolve any referenced path and require it inside the repo worktree. */
export function resolveInRepo(input, repoRoot, label) {
  if (!input) throw new UsageError('missing_flag', { flag: label });
  const target = realpathDeepest(anchorAtRepo(input, repoRoot));
  return assertInside(repoRoot, target, label);
}

function repoRel(repoRoot, abs) {
  return path.relative(repoRoot, abs);
}

// ─────────────────────────── goal / journal ───────────────────────────

const GOAL_REQUIRED = [
  'format', 'run_id', 'goal_id', 'handoff_path', 'handoff_revision',
  'base_commit', 'worktree_realpath', 'goal', 'success', 'non_goals',
  'forbidden_scope', 'oracle_path', 'created_at',
];

export function readGoal(runDir) {
  const file = path.join(runDir, 'goal.json');
  if (!fs.existsSync(file)) throw new ContractError('goal_missing', { path: file });
  let goal;
  try {
    goal = JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (err) {
    throw new ContractError('goal_corrupt', { path: file, message: String(err.message).slice(0, 200) });
  }
  if (!isPlainObject(goal)) throw new ContractError('goal_corrupt', { path: file });
  if (goal.format !== GOAL_FORMAT) {
    throw new ContractError('goal_format_unknown', { got: goal.format, want: GOAL_FORMAT });
  }
  for (const key of GOAL_REQUIRED) {
    if (goal[key] === undefined || goal[key] === null || goal[key] === '') {
      throw new ContractError('goal_field_missing', { field: key });
    }
  }
  for (const key of ['success', 'non_goals', 'forbidden_scope']) {
    if (!Array.isArray(goal[key])) throw new ContractError('goal_field_not_array', { field: key });
  }
  if (goal.slices !== undefined) {
    if (!Array.isArray(goal.slices)) throw new ContractError('goal_field_not_array', { field: 'slices' });
    for (const s of goal.slices) {
      if (!isPlainObject(s) || !s.id || !s.statement) {
        throw new ContractError('goal_slice_malformed', { slice: s });
      }
    }
  }
  return { goal, sha256: sha256File(file), path: file };
}

export function readJournal(runDir) {
  const file = path.join(runDir, 'journal.jsonl');
  if (!fs.existsSync(file)) throw new ContractError('journal_missing', { path: file });
  const raw = fs.readFileSync(file, 'utf8');
  if (raw.length === 0) throw new ContractError('journal_empty', { path: file });
  // A kill mid-append leaves a line with no trailing newline: that is corruption,
  // never something to silently truncate and continue from.
  if (!raw.endsWith('\n')) throw new ContractError('journal_partial_line', { path: file });
  const lines = raw.split('\n');
  lines.pop();
  const events = [];
  lines.forEach((line, idx) => {
    if (line.trim() === '') throw new ContractError('journal_blank_line', { line: idx + 1 });
    let ev;
    try {
      ev = JSON.parse(line);
    } catch (err) {
      throw new ContractError('journal_corrupt', { line: idx + 1, message: String(err.message).slice(0, 200) });
    }
    if (!isPlainObject(ev)) throw new ContractError('journal_corrupt', { line: idx + 1 });
    if (ev.seq !== idx + 1) throw new ContractError('journal_seq_broken', { line: idx + 1, seq: ev.seq });
    if (!EVENT_TYPES.includes(ev.type)) throw new ContractError('unknown_event_type', { line: idx + 1, type: ev.type });
    if (typeof ev.at !== 'string' || !ev.at) throw new ContractError('journal_field_missing', { line: idx + 1, field: 'at' });
    if (typeof ev.observed_head !== 'string' || !ev.observed_head) {
      throw new ContractError('journal_field_missing', { line: idx + 1, field: 'observed_head' });
    }
    if (!isPlainObject(ev.payload)) throw new ContractError('journal_field_missing', { line: idx + 1, field: 'payload' });
    events.push(ev);
  });
  if (events.length === 0) throw new ContractError('journal_empty', { path: file });
  if (events[0].type !== 'initialized') throw new ContractError('journal_first_event_invalid', { type: events[0].type });
  return events;
}

// ─────────────────────────── reducer (pure) ───────────────────────────

/**
 * Pure reduction of (immutable goal, journal events) -> run state.
 * Throws ContractError on any internally inconsistent history.
 */
export function reduceRun(goal, events) {
  const verified = [];               // [{slice, seq, at, receipt_path, receipt_sha256, verified_head}]
  const verifiedIds = new Set();
  const checkpoints = new Map();     // slice -> {slice, reason, next, seq, at}
  const actionsSeen = new Set();
  const forbiddenRetry = new Set();
  const unknownActions = [];
  let pendingAction = null;
  let stopped = null;
  let latestHead = null;

  for (const ev of events) {
    if (stopped) throw new ContractError('event_after_stop', { seq: ev.seq, type: ev.type });
    latestHead = ev.observed_head;
    const p = ev.payload;
    switch (ev.type) {
      case 'initialized':
        if (ev.seq !== 1) throw new ContractError('duplicate_initialized', { seq: ev.seq });
        if (typeof p.goal_sha256 !== 'string' || !p.goal_sha256) {
          throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'payload.goal_sha256' });
        }
        break;
      case 'checkpointed': {
        if (!p.slice) throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'payload.slice' });
        if (!CHECKPOINT_REASONS.includes(p.reason)) {
          throw new ContractError('checkpoint_reason_invalid', { seq: ev.seq, reason: p.reason });
        }
        if (verifiedIds.has(p.slice)) {
          // Otherwise the packet advises repeating work that is already verified.
          throw new ContractError('checkpoint_after_verified', { seq: ev.seq, slice: p.slice });
        }
        checkpoints.set(p.slice, { slice: p.slice, reason: p.reason, next: p.next || '', seq: ev.seq, at: ev.at });
        break;
      }
      case 'verified': {
        if (!p.slice) throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'payload.slice' });
        if (verifiedIds.has(p.slice)) throw new ContractError('duplicate_verified_slice', { seq: ev.seq, slice: p.slice });
        verifiedIds.add(p.slice);
        verified.push({
          slice: p.slice,
          seq: ev.seq,
          at: ev.at,
          receipt_path: p.receipt_path,
          receipt_sha256: p.receipt_sha256,
          verified_head: p.verified_head,
        });
        checkpoints.delete(p.slice);
        break;
      }
      case 'action_started': {
        const id = p.action_id;
        if (!id) throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'payload.action_id' });
        if (forbiddenRetry.has(id)) throw new ContractError('blind_retry_forbidden', { seq: ev.seq, action_id: id });
        if (actionsSeen.has(id)) throw new ContractError('duplicate_action_id', { seq: ev.seq, action_id: id });
        if (pendingAction) throw new ContractError('concurrent_action', { seq: ev.seq, pending: pendingAction.action_id });
        actionsSeen.add(id);
        pendingAction = {
          action_id: id,
          description: p.description,
          target: p.target,
          pre_sha256: p.pre_sha256,
          intended_post_sha256: p.intended_post_sha256,
          seq: ev.seq,
          at: ev.at,
        };
        break;
      }
      case 'action_reconciled': {
        const id = p.action_id;
        const resolvesUnknown = unknownActions.some((a) => a.action_id === id);
        if (!resolvesUnknown && (!pendingAction || pendingAction.action_id !== id)) {
          throw new ContractError('unknown_action_reconcile', { seq: ev.seq, action_id: id });
        }
        if (resolvesUnknown && p.outcome !== 'reconciled') {
          throw new ContractError('unknown_outcome_needs_reconciled', { seq: ev.seq, action_id: id, outcome: p.outcome });
        }
        if (!RECONCILE_OUTCOMES.includes(p.outcome)) {
          throw new ContractError('reconcile_outcome_invalid', { seq: ev.seq, outcome: p.outcome });
        }
        if (p.outcome === 'outcome_unknown') {
          forbiddenRetry.add(id);
          unknownActions.push({
            action_id: id,
            target: pendingAction.target,
            observed_sha256: p.observed_sha256 || null,
            seq: ev.seq,
          });
        } else if (p.outcome === 'reconciled') {
          const idx = unknownActions.findIndex((a) => a.action_id === id);
          if (idx >= 0) unknownActions.splice(idx, 1);
        }
        pendingAction = null;
        break;
      }
      case 'stopped':
        if (!p.reason) throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'payload.reason' });
        stopped = { reason: p.reason, seq: ev.seq, at: ev.at };
        break;
      default:
        throw new ContractError('unknown_event_type', { seq: ev.seq, type: ev.type });
    }
  }

  const candidates = [...checkpoints.values()].sort((a, b) => a.seq - b.seq);

  const blockers = [];
  if (stopped) blockers.push({ code: 'stopped', detail: stopped.reason });
  for (const a of unknownActions) {
    blockers.push({ code: 'outcome_unknown', detail: `action ${a.action_id} on ${a.target}` });
  }

  let state = 'ACTIVE';
  if (stopped || unknownActions.length > 0) state = 'HONEST_PARTIAL';
  else if (pendingAction) state = 'ACTION_PENDING';

  const legal = deriveLegalNextAction({ goal, stopped, unknownActions, pendingAction, candidates, verifiedIds });

  return {
    run_id: goal.run_id,
    goal_id: goal.goal_id,
    handoff_path: goal.handoff_path,
    handoff_revision: goal.handoff_revision,
    base_commit: goal.base_commit,
    worktree_realpath: goal.worktree_realpath,
    state,
    verified,
    verified_slices: [...verifiedIds],
    candidate_slices: candidates,
    pending_action: pendingAction,
    unknown_actions: unknownActions,
    forbidden_retry_actions: [...forbiddenRetry],
    stopped,
    blockers,
    legal_next_action: legal,
    latest_observed_head: latestHead,
    events_count: events.length,
    goal_sha256_at_init: events[0].payload.goal_sha256,
  };
}

function deriveLegalNextAction({ goal, stopped, unknownActions, pendingAction, candidates, verifiedIds }) {
  if (stopped) {
    return {
      action: 'Do NOT continue. This run is closed. Resolve the recorded stop reason with the human and open a NEW run from a known commit. No further event may be recorded here.',
      why: `run was explicitly stopped: ${stopped.reason}`,
      owner: 'conductor+human',
    };
  }
  if (unknownActions.length > 0) {
    const a = unknownActions[0];
    return {
      action: `Reconcile action ${a.action_id} with explicit evidence: reconcile --action ${a.action_id} --outcome reconciled --evidence <path> --observed-sha256 <sha>`,
      why: `the outcome of action ${a.action_id} on ${a.target} is UNKNOWN; re-running the same action id is FORBIDDEN (it could double-apply a side effect)`,
      owner: 'conductor',
    };
  }
  if (pendingAction) {
    return {
      action: `Inspect ${pendingAction.target} on disk, compare its sha256 against pre/intended-post, then run reconcile --action ${pendingAction.action_id} --outcome <confirmed|outcome_unknown|reconciled>`,
      why: 'a side effect was started but never reconciled; real file state must be read before anything else happens',
      owner: 'executor',
    };
  }
  if (candidates.length > 0) {
    const c = candidates[0];
    return {
      action: `Slice ${c.slice} is a CANDIDATE only. Obtain a Conductor PASS receipt (existing Gate/reviewer must pass first), then run verify --slice ${c.slice} --receipt <receipt.json>`,
      why: 'a checkpoint records intent, not verified progress; only a bound Conductor receipt may advance verified state',
      owner: 'conductor',
    };
  }
  const slices = Array.isArray(goal.slices) ? goal.slices : null;
  if (slices) {
    const next = slices.find((s) => !verifiedIds.has(s.id));
    if (next) {
      return {
        action: `Start slice ${next.id}: ${next.statement}`,
        why: 'all recorded slices before it are verified; this is the first unverified slice in the frozen plan',
        owner: 'executor',
      };
    }
    return {
      action: 'All frozen slices are verified. Run the handoff-level acceptance and hand back to the Conductor; do NOT invent extra scope.',
      why: 'the frozen slice plan is exhausted and nothing is pending',
      owner: 'conductor',
    };
  }
  return {
    action: 'No slice plan was frozen in goal.json. The Conductor must choose the next slice from the frozen success criteria before any work continues.',
    why: 'goal.slices is absent, so the next legal action cannot be derived mechanically',
    owner: 'conductor',
  };
}

// ─────────────────────────── derived artifacts ───────────────────────────

/** Deterministic (timestamp-free) checkpoint body. */
export function semanticCheckpoint(state) {
  return {
    format: CHECKPOINT_FORMAT,
    run_id: state.run_id,
    goal_id: state.goal_id,
    handoff_path: state.handoff_path,
    handoff_revision: state.handoff_revision,
    base_commit: state.base_commit,
    worktree_realpath: state.worktree_realpath,
    state: state.state,
    events_count: state.events_count,
    latest_observed_head: state.latest_observed_head,
    verified: state.verified,
    candidate_slices: state.candidate_slices,
    pending_action: state.pending_action,
    unknown_actions: state.unknown_actions,
    forbidden_retry_actions: state.forbidden_retry_actions,
    stopped: state.stopped,
    blockers: state.blockers,
    legal_next_action: state.legal_next_action,
  };
}

export function writeAtomic(target, content) {
  const dir = path.dirname(target);
  const tmp = path.join(dir, `.${path.basename(target)}.tmp-${process.pid}-${crypto.randomBytes(4).toString('hex')}`);
  try {
    fs.writeFileSync(tmp, content);
    fs.renameSync(tmp, target);
  } catch (err) {
    try { if (fs.existsSync(tmp)) fs.unlinkSync(tmp); } catch { /* best effort */ }
    throw new ContractError('atomic_write_failed', { target, message: String(err && err.message).slice(0, 200) });
  }
}

function fmtList(items, empty) {
  if (!items || items.length === 0) return empty;
  return items.join('\n');
}

function resumeCommand(repoRoot, runDir) {
  const scriptAbs = fileURLToPath(import.meta.url);
  const rel = path.relative(repoRoot, scriptAbs);
  const script = rel.startsWith('..') ? scriptAbs : rel;
  return `node ${script} resume --run ${runDir}`;
}

export function renderStatus(goal, state, ctx) {
  const L = [];
  L.push('════════ YOLO RECOVERY STATUS (Phase 1, opt-in) ════════');
  L.push(`RUN: ${state.run_id}   STATE: ${state.state}`);
  L.push(`RUN DIR: ${ctx.runDir}`);
  L.push('');
  L.push(`GOAL: ${goal.goal}`);
  L.push(`HANDOFF REVISION: ${goal.handoff_path} @ sha256 ${goal.handoff_revision}`);
  L.push(`WORKTREE: ${goal.worktree_realpath}  (base ${goal.base_commit} → latest observed ${state.latest_observed_head})`);
  L.push('');
  L.push('VERIFIED:');
  L.push(fmtList(state.verified.map((v) => `  - ${v.slice}  (receipt ${v.receipt_path}, head ${v.verified_head})`), '  (none)'));
  L.push('UNVERIFIED:');
  L.push(fmtList(state.candidate_slices.map((c) => `  - ${c.slice}  (checkpoint candidate, reason=${c.reason}, next="${c.next}")`), '  (none)'));
  if (ctx.dirty_count !== undefined) {
    L.push(`  working tree observation: ${ctx.dirty_count} uncommitted path(s) — observation only, never authority`);
  }
  L.push('BLOCKED:');
  L.push(fmtList(state.blockers.map((b) => `  - ${b.code}: ${b.detail}`), '  (none)'));
  L.push('OUTCOME_UNKNOWN:');
  L.push(fmtList(state.unknown_actions.map((a) => `  - ${a.action_id} on ${a.target} — retrying this action id is FORBIDDEN`), '  (none)'));
  L.push('PENDING ACTION:');
  L.push(state.pending_action
    ? `  - ${state.pending_action.action_id}: ${state.pending_action.description} → ${state.pending_action.target}`
    : '  (none)');
  L.push('');
  L.push(`LEGAL NEXT ACTION: ${state.legal_next_action.action}`);
  L.push(`  WHY: ${state.legal_next_action.why}`);
  L.push(`OWNER: ${state.legal_next_action.owner}`);
  L.push(`RESUME COMMAND: ${ctx.resumeCommand}`);
  L.push('════════════════════════════════════════════════════════');
  return L.join('\n') + '\n';
}

export function renderRecovery(goal, state, ctx) {
  const sections = [];
  const add = (title, body) => sections.push({ title, text: `## ${title}\n\n${body}\n` });

  const header = `# Recovery Packet — run ${state.run_id}

Derived from goal.json + journal.jsonl at ${nowIso()}.
This file has NO authority. If it disagrees with goal.json/journal.jsonl, the
journal wins and this file must be rebuilt. Do not treat it, session-state.md,
or a compact summary as progress truth.
`;

  add('GOAL', `${goal.goal}\n\nGoal id: \`${goal.goal_id}\``);
  add('SUCCESS CRITERIA', goal.success.map((s, i) => `${i + 1}. ${typeof s === 'string' ? s : s.statement}`).join('\n'));
  add('NON-GOALS', goal.non_goals.map((s) => `- ${s}`).join('\n'));
  add('FORBIDDEN SCOPE', goal.forbidden_scope.map((s) => `- ${s}`).join('\n'));
  add('HANDOFF REVISION', `\`${goal.handoff_path}\` @ sha256 \`${goal.handoff_revision}\`\nBase commit \`${goal.base_commit}\`; worktree \`${goal.worktree_realpath}\`; latest observed HEAD \`${state.latest_observed_head}\`.`);
  add('VERIFIED', state.verified.length
    ? state.verified.map((v) => `- \`${v.slice}\` — receipt \`${v.receipt_path}\` (sha256 ${v.receipt_sha256}), verified at HEAD \`${v.verified_head}\`. DO NOT redo this work.`).join('\n')
    : '- (none) — nothing has been verified yet.');
  add('UNVERIFIED', [
    state.candidate_slices.length
      ? state.candidate_slices.map((c) => `- \`${c.slice}\` — checkpoint candidate only (reason=${c.reason}). Intent recorded: "${c.next}". NOT verified progress.`).join('\n')
      : '- (no checkpoint candidates)',
    `- working tree observation: ${ctx.dirty_count} uncommitted path(s) in the frozen worktree (observation, not authority).`,
  ].join('\n'));
  add('BLOCKED', state.blockers.length
    ? state.blockers.map((b) => `- **${b.code}** — ${b.detail}`).join('\n')
    : '- (none)');
  add('OUTCOME_UNKNOWN', state.unknown_actions.length
    ? state.unknown_actions.map((a) => `- action \`${a.action_id}\` on \`${a.target}\`: outcome unknown. Re-running this action id is **FORBIDDEN**; it must be reconciled with explicit evidence.`).join('\n')
    : '- (none)');
  add('PENDING ACTION', state.pending_action
    ? `- \`${state.pending_action.action_id}\`: ${state.pending_action.description}\n  target \`${state.pending_action.target}\`\n  pre sha256 \`${state.pending_action.pre_sha256}\`\n  intended post sha256 \`${state.pending_action.intended_post_sha256}\`\n  Read the real file before deciding anything: a hash equal to \`intended_post_sha256\` means the action DID land (outcome \`confirmed\`); equal to \`pre_sha256\` means it never landed (\`reconciled\`); any other hash means \`outcome_unknown\`.`
    : '- (none)');
  add('LEGAL NEXT ACTION', `${state.legal_next_action.action}\n\n**WHY:** ${state.legal_next_action.why}`);
  add('OWNER', state.legal_next_action.owner);
  add('RESUME COMMAND', `\`\`\`\n${ctx.resumeCommand}\n\`\`\``);
  add('AUTHORITY ORDER', [
    '1. approved handoff revision + immutable `goal.json`',
    '2. fully parseable `journal.jsonl` + its evidence pointers',
    '3. rebuildable `checkpoint.json`',
    '4. this packet / `session-state.md` / PreCompact snapshots — navigation only',
  ].join('\n'));
  add('VERIFICATION MODEL', [
    '- A checkpoint is only a CANDIDATE: it records intent, it does not verify the work.',
    '- `verified` advances ONLY when a Conductor (an identity distinct from the executor, `written_by_id` != `executor_id`) writes a bound verification receipt after the existing Gate and an independent review have both PASSed.',
    '- Completion prose, an ordinary file, a self-authored receipt, or any executor assertion NEVER advances `verified`.',
    '- Until a validated receipt names the slice, that slice stays unverified — even if the work appears done.',
  ].join('\n'));
  const prohibitions = [
    ...(ctx.dirty_count > 0
      ? ['- Uncommitted worktree changes are observation only and MUST NOT be treated as progress or as done; inspect them before continuing — do not silently discard them.']
      : []),
    ...(state.pending_action
      ? [`- While action \`${state.pending_action.action_id}\` is pending, NO slice progress may be recorded and the action MUST NOT be blindly re-applied: the patch may already be on disk, so re-applying it risks double-applying the side effect (a duplicated or corrupted target that matches no recorded hash). Read the real file and reconcile it first.`]
      : []),
    ...(state.unknown_actions.length
      ? ['- Actions with `outcome_unknown` MUST NOT be re-run with the same action id.']
      : []),
    ['- Completion prose, a self-authored receipt, or any executor assertion NEVER advances `verified` (see VERIFICATION MODEL).'],
  ].flat();
  add('PROHIBITIONS', prohibitions.join('\n'));

  const text = header + '\n' + sections.map((s) => s.text).join('\n');
  const composition = sections.map((s) => ({ section: s.title, tokens: estimateTokens(s.text) }));
  composition.unshift({ section: '(header)', tokens: estimateTokens(header) });
  return { text, composition, tokens: estimateTokens(text) };
}

// ─────────────────────────── journal append ───────────────────────────

/**
 * Structural guarantee (arch review P0-1): NO command may append an event that
 * `reduceRun` would later reject. The candidate is reduced in memory first; if
 * that throws, nothing is written. Without this, a single mis-ordered command
 * makes the journal — the level-2 authority, which the guide forbids hand-
 * repairing — permanently unreducible, leaving no legal next action at all.
 */
function appendEventGuarded(runDir, goal, events, type, payload, observedHead) {
  const candidate = {
    seq: events.length + 1,
    type,
    at: nowIso(),
    observed_head: observedHead,
    payload,
  };
  try {
    reduceRun(goal, events.concat([candidate]));
  } catch (err) {
    throw new ContractError('event_would_corrupt_journal', {
      type,
      would_fail_with: err.reason || String(err.message).slice(0, 120),
      detail: err.details || {},
      note: 'refused before writing; the journal is unchanged',
    });
  }
  return appendEvent(runDir, candidate.seq, type, payload, observedHead);
}

/**
 * Exclusive run lock (arch review P2-2). The line-count check below fails closed
 * only when it fires; two writers can both pass it and produce a duplicate seq,
 * which is an unrepairable ledger. An O_EXCL lockfile is the cheaper guarantee.
 */
function withRunLock(runDir, fn) {
  const lock = path.join(runDir, '.run.lock');
  let fd;
  try {
    fd = fs.openSync(lock, 'wx');
  } catch (err) {
    if (err && err.code === 'EEXIST') {
      throw new ContractError('run_locked', {
        lock,
        note: 'another writer holds this run, or a previous command died. If you are certain no other process is running, delete the lock file and retry.',
      });
    }
    throw err;
  }
  try {
    fs.writeSync(fd, String(process.pid));
    return fn();
  } finally {
    try { fs.closeSync(fd); } catch { /* ignore */ }
    try { fs.unlinkSync(lock); } catch { /* ignore */ }
  }
}

function appendEvent(runDir, expectedSeq, type, payload, observedHead) {
  const file = path.join(runDir, 'journal.jsonl');
  // Single-writer contract: re-read and fail closed if someone else advanced it.
  if (fs.existsSync(file)) {
    const raw = fs.readFileSync(file, 'utf8');
    const count = raw.length === 0 ? 0 : raw.split('\n').filter((l) => l.trim() !== '').length;
    if (count !== expectedSeq - 1) {
      throw new ContractError('concurrent_writer_detected', { expected_events: expectedSeq - 1, found_events: count });
    }
  } else if (expectedSeq !== 1) {
    throw new ContractError('journal_missing', { path: file });
  }
  const ev = { seq: expectedSeq, type, at: nowIso(), observed_head: observedHead, payload };
  fs.appendFileSync(file, JSON.stringify(ev) + '\n');
  return ev;
}

// ─────────────────────────── run loading ───────────────────────────

function loadRun(runDir, repoRoot, cwd) {
  const identity = readGitIdentity(cwd);
  const { goal, sha256: goalSha } = readGoal(runDir);

  const events = readJournal(runDir);
  if (events[0].payload.goal_sha256 !== goalSha) {
    throw new ContractError('goal_mutated', { frozen: events[0].payload.goal_sha256, current: goalSha });
  }

  const state = reduceRun(goal, events);

  // ── Binding checks ───────────────────────────────────────────────────────
  // Architecture review P0-2: these used to THROW, which routed every binding
  // failure to one outcome — total lockout. A normal handoff amendment (TAD
  // writes §9.2 rows into the handoff DURING the work this ledger is meant to
  // survive) made `status` AND `stop` impossible, so the run could never be
  // closed honestly. They are now BLOCKERS: the run is honest_partial, every
  // command still exits non-zero and no progress may be recorded, but the
  // operator keeps a way to see the state and to close the run truthfully.
  const bindingBlockers = [];

  if (goal.worktree_realpath !== identity.worktree_realpath) {
    bindingBlockers.push({
      code: 'worktree_identity_mismatch',
      detail: `frozen ${goal.worktree_realpath}, currently running in ${identity.worktree_realpath}`,
    });
  }

  // The run owns its own authority: handoff-frozen.md is the byte copy taken at
  // init, so the run no longer depends on an external mutable file to be usable.
  const frozenHandoff = path.join(runDir, 'handoff-frozen.md');
  if (fs.existsSync(frozenHandoff) && sha256File(frozenHandoff) !== goal.handoff_revision) {
    throw new ContractError('handoff_frozen_tampered', {
      path: frozenHandoff,
      note: "the run's own frozen copy of the approved handoff no longer matches goal.json",
    });
  }
  const handoffAbs = anchorAtRepoSafe(goal.handoff_path, repoRoot);
  if (!handoffAbs || !fs.existsSync(handoffAbs)) {
    bindingBlockers.push({ code: 'handoff_missing', detail: goal.handoff_path });
  } else if (sha256File(handoffAbs) !== goal.handoff_revision) {
    bindingBlockers.push({
      code: 'handoff_revision_drift',
      detail: `${goal.handoff_path} no longer matches the revision this run was authorised under`,
    });
  }

  // Authority level 2 includes the journal's EVIDENCE POINTERS. A verified slice
  // whose receipt vanished, changed, or no longer reads as a bound Conductor
  // receipt is not verified progress any more (security HIGH-1, code P1-2).
  for (const v of state.verified) {
    const rAbs = v.receipt_path ? anchorAtRepoSafe(v.receipt_path, repoRoot) : null;
    if (!rAbs || !fs.existsSync(rAbs) || !fs.lstatSync(rAbs).isFile()) {
      bindingBlockers.push({ code: 'verified_evidence_missing', detail: `slice ${v.slice}: ${v.receipt_path}` });
      continue;
    }
    if (sha256File(rAbs) !== v.receipt_sha256) {
      bindingBlockers.push({ code: 'verified_evidence_hash_mismatch', detail: `slice ${v.slice}: ${v.receipt_path}` });
      continue;
    }
    let rec = null;
    try { rec = JSON.parse(fs.readFileSync(rAbs, 'utf8')); } catch { rec = null; }
    if (!isPlainObject(rec) || rec.format !== RECEIPT_FORMAT || rec.verdict !== 'PASS'
        || rec.run_id !== goal.run_id || rec.slice !== v.slice
        || rec.written_by !== 'conductor' || rec.written_by_id === rec.executor_id) {
      bindingBlockers.push({
        code: 'verified_evidence_not_a_bound_receipt',
        detail: `slice ${v.slice}: ${v.receipt_path} no longer reads as a bound Conductor PASS receipt`,
      });
      continue;
    }
    // Security review finding 1: the receipt binds to gate/review EVIDENCE
    // files by hash. If those files are deleted or edited AFTER verify, the
    // verified claim loses its carrier — FR5 requires missing/tampered
    // evidence to fail closed on every later load, not just at verify time.
    const boundEvidence = [
      ...(Array.isArray(rec.gate_evidence) ? rec.gate_evidence : []),
      ...(Array.isArray(rec.review_evidence) ? rec.review_evidence : []),
    ];
    for (const ev of boundEvidence) {
      const eAbs = ev && typeof ev.path === 'string' ? anchorAtRepoSafe(ev.path, repoRoot) : null;
      if (!eAbs || !fs.existsSync(eAbs) || !fs.lstatSync(eAbs).isFile()) {
        bindingBlockers.push({ code: 'verified_evidence_missing', detail: `slice ${v.slice}: ${ev && ev.path}` });
        continue;
      }
      if (typeof ev.sha256 === 'string' && sha256File(eAbs) !== ev.sha256) {
        bindingBlockers.push({ code: 'verified_evidence_hash_mismatch', detail: `slice ${v.slice}: ${ev.path}` });
      }
    }
  }

  state.binding_blockers = bindingBlockers;
  if (bindingBlockers.length > 0) {
    state.blockers = state.blockers.concat(bindingBlockers);
    state.state = 'HONEST_PARTIAL';
    if (!state.stopped) {
      state.legal_next_action = {
        action: 'Binding failed. Inspect the named artifact with `status --run <dir>`. If the change was legitimate, restore the artifact; if it was not, close the run with `stop --run <dir> --reason "<why>"`. No progress may be recorded until the binding holds again.',
        why: `binding blockers: ${bindingBlockers.map((b) => b.code).join(', ')}`,
        owner: 'conductor+human',
      };
    }
  }

  return { identity, goal, goalSha, events, state };
}

function writeDerived(runDir, repoRoot, goal, state, identity, out) {
  const cp = semanticCheckpoint(state);
  // Report (never silently repair) a derived file that disagreed with the
  // journal before we overwrite it — otherwise the forensic signal that someone
  // edited a derived file is erased by the next mutating command.
  let derivedConflict = null;
  const cpPath = path.join(runDir, 'checkpoint.json');
  if (fs.existsSync(cpPath)) {
    try {
      const { generated_at: _ig, ...body } = JSON.parse(fs.readFileSync(cpPath, 'utf8'));
      if (JSON.stringify(body) !== JSON.stringify(cp)) derivedConflict = 'checkpoint.json';
    } catch {
      derivedConflict = 'checkpoint.json (unparseable)';
    }
  }
  writeAtomic(cpPath,
    JSON.stringify({ ...cp, generated_at: nowIso() }, null, 2) + '\n');

  const ctx = {
    runDir,
    dirty_count: identity.dirty_count,
    resumeCommand: resumeCommand(repoRoot, runDir),
  };
  const packet = renderRecovery(goal, state, ctx);
  writeAtomic(path.join(runDir, 'recovery.md'), packet.text);
  if (derivedConflict && typeof out === 'function') {
    out(`!! WARNING: ${derivedConflict} disagreed with the journal and has been rebuilt from it.\n`
      + '   The journal is authority, so nothing was lost — but a derived file does not change on its own.\n'
      + '   Someone or something edited it. Investigate before trusting this run.\n');
  }
  return { packet, ctx, derivedConflict };
}

// ─────────────────────────── receipt validation ───────────────────────────

const RECEIPT_REQUIRED = [
  'format', 'verdict', 'run_id', 'slice', 'handoff_revision', 'worktree_realpath',
  'verified_head', 'gate_evidence', 'review_evidence', 'executor_id',
  'written_by', 'written_by_id',
];

/**
 * A receipt is NOT a Gate and NOT a semantic verifier. It is a binding record
 * that the EXISTING Gate/reviewer already passed. This function checks binding,
 * shape, evidence existence and hash — nothing about semantic correctness.
 */
export function validateVerificationReceipt(receiptPathInput, { goal, state, identity, repoRoot, slice }) {
  void state;
  const abs = resolveInRepo(receiptPathInput, repoRoot, '--receipt');
  if (!fs.existsSync(abs)) throw new ContractError('receipt_missing', { path: receiptPathInput });
  const st = fs.lstatSync(abs);
  if (!st.isFile()) throw new ContractError('receipt_not_regular_file', { path: receiptPathInput });

  let receipt;
  try {
    receipt = JSON.parse(fs.readFileSync(abs, 'utf8'));
  } catch (err) {
    // A completion report, a log, or any ordinary prose file lands here.
    throw new ContractError('receipt_not_json', { path: receiptPathInput, message: String(err.message).slice(0, 120) });
  }
  if (!isPlainObject(receipt)) throw new ContractError('receipt_not_json', { path: receiptPathInput });
  if (receipt.format !== RECEIPT_FORMAT) {
    throw new ContractError('receipt_format_unknown', { got: receipt.format, want: RECEIPT_FORMAT });
  }
  for (const key of RECEIPT_REQUIRED) {
    if (receipt[key] === undefined || receipt[key] === null || receipt[key] === '') {
      throw new ContractError('receipt_field_missing', { field: key });
    }
  }
  if (receipt.verdict !== 'PASS') throw new ContractError('receipt_verdict_not_pass', { verdict: receipt.verdict });
  if (receipt.run_id !== goal.run_id) throw new ContractError('receipt_run_mismatch', { got: receipt.run_id, want: goal.run_id });
  if (receipt.slice !== slice) throw new ContractError('receipt_slice_mismatch', { got: receipt.slice, want: slice });
  if (receipt.handoff_revision !== goal.handoff_revision) {
    throw new ContractError('receipt_handoff_revision_mismatch', { got: receipt.handoff_revision, want: goal.handoff_revision });
  }
  if (receipt.worktree_realpath !== goal.worktree_realpath) {
    throw new ContractError('receipt_worktree_mismatch', { got: receipt.worktree_realpath, want: goal.worktree_realpath });
  }
  // Architecture review P1-3: exact-HEAD equality made the natural TAD order
  // (commit the Gate + reviewer reports, THEN verify) fail, whose only "repair"
  // was editing the receipt to assert verification at a tree that was never
  // gated. Accept the gated commit or any ancestor of the current HEAD; the
  // delta is recorded in the journal rather than refused.
  if (receipt.verified_head !== identity.head) {
    let isAncestor = false;
    try {
      execFileSync('git', ['merge-base', '--is-ancestor', receipt.verified_head, identity.head],
        { cwd: repoRoot, stdio: 'ignore' });
      isAncestor = true;
    } catch { isAncestor = false; }
    if (!isAncestor) {
      throw new ContractError('receipt_head_not_ancestor', {
        gated_head: receipt.verified_head,
        current_head: identity.head,
        note: 'the gated commit is not an ancestor of the current HEAD, so the receipt does not describe this history',
      });
    }
  }
  if (receipt.written_by !== 'conductor') {
    throw new ContractError('receipt_author_role_invalid', { written_by: receipt.written_by });
  }
  // Security MEDIUM-4: bound and typed, so `written_by_id != executor_id` cannot
  // be satisfied by two values of different types or by unbounded junk.
  for (const key of ['executor_id', 'written_by_id']) {
    const v = receipt[key];
    if (typeof v !== 'string' || v.trim().length === 0 || v.length > 200) {
      throw new ContractError('receipt_identity_malformed', { field: key });
    }
  }
  if (receipt.written_by_id.trim() === receipt.executor_id.trim()) {
    throw new ContractError('receipt_self_authored', { id: receipt.executor_id });
  }
  if (state.verified_slices.includes(slice)) {
    throw new ContractError('duplicate_verified_slice', { slice });
  }

  const checkEvidence = (list, label, requireIndependent) => {
    if (!Array.isArray(list) || list.length === 0) {
      throw new ContractError('receipt_evidence_empty', { field: label });
    }
    let sawIndependent = false;
    for (const e of list) {
      if (!isPlainObject(e) || typeof e.path !== 'string' || !e.path
          || typeof e.sha256 !== 'string' || !/^[0-9a-f]{64}$/.test(e.sha256)) {
        throw new ContractError('receipt_evidence_malformed', { field: label, entry: e });
      }
      if (e.verdict !== 'PASS') throw new ContractError('receipt_evidence_not_pass', { field: label, path: e.path, verdict: e.verdict });
      const evAbs = resolveInRepo(e.path, repoRoot, `${label}.path`);
      if (!fs.existsSync(evAbs) || !fs.lstatSync(evAbs).isFile()) {
        throw new ContractError('receipt_evidence_missing', { field: label, path: e.path });
      }
      // Security MEDIUM-3: an empty file must not stand in for "Gate PASS".
      if (fs.statSync(evAbs).size === 0) {
        throw new ContractError('receipt_evidence_empty_file', { field: label, path: e.path });
      }
      const actual = sha256File(evAbs);
      if (actual !== e.sha256) {
        throw new ContractError('receipt_evidence_hash_mismatch', { field: label, path: e.path, declared: e.sha256, actual });
      }
      if (e.independent === true) sawIndependent = true;
    }
    if (requireIndependent && !sawIndependent) {
      throw new ContractError('receipt_no_independent_review', { field: label });
    }
  };
  checkEvidence(receipt.gate_evidence, 'gate_evidence', false);
  checkEvidence(receipt.review_evidence, 'review_evidence', true);

  return { receipt, abs, sha256: sha256File(abs), repoRelPath: repoRel(repoRoot, abs) };
}

// ─────────────────────────── arg parsing ───────────────────────────

export function parseArgs(argv) {
  const flags = {};
  const positional = [];
  for (let i = 0; i < argv.length; i += 1) {
    const tok = argv[i];
    if (tok.startsWith('--')) {
      const name = tok.slice(2);
      const next = argv[i + 1];
      if (next === undefined || next.startsWith('--')) {
        flags[name] = true;
      } else {
        flags[name] = next;
        i += 1;
      }
    } else {
      positional.push(tok);
    }
  }
  return { flags, positional };
}

function need(flags, name) {
  const v = flags[name];
  if (v === undefined || v === true || v === '') throw new UsageError('missing_flag', { flag: `--${name}` });
  return String(v);
}

// ─────────────────────────── commands ───────────────────────────

function cmdInit(flags, cwd, out) {
  const identity = readGitIdentity(cwd);
  const repoRoot = identity.worktree_realpath;
  const runDir = resolveRunDir(need(flags, 'run'), repoRoot);
  const handoffAbs = resolveInRepo(need(flags, 'handoff'), repoRoot, '--handoff');
  const goalFileAbs = resolveInRepo(need(flags, 'goal-file'), repoRoot, '--goal-file');

  if (fs.existsSync(path.join(runDir, 'goal.json'))) {
    throw new ContractError('run_already_initialized', { run_dir: runDir });
  }
  if (!fs.existsSync(handoffAbs)) throw new ContractError('handoff_missing', { path: need(flags, 'handoff') });
  if (!fs.existsSync(goalFileAbs)) throw new ContractError('goal_file_missing', { path: need(flags, 'goal-file') });

  let spec;
  try {
    spec = JSON.parse(fs.readFileSync(goalFileAbs, 'utf8'));
  } catch (err) {
    throw new UsageError('goal_file_not_json', { message: String(err.message).slice(0, 200) });
  }
  for (const key of ['run_id', 'goal_id', 'base_commit', 'goal', 'success', 'non_goals', 'forbidden_scope', 'oracle_path']) {
    if (spec[key] === undefined || spec[key] === null || spec[key] === '') {
      throw new UsageError('goal_file_field_missing', { field: key });
    }
  }
  if (identity.head !== spec.base_commit) {
    throw new ContractError('base_commit_mismatch', { declared: spec.base_commit, head: identity.head });
  }
  const oracleAbs = resolveInRepo(spec.oracle_path, repoRoot, 'oracle_path');
  if (!fs.existsSync(oracleAbs)) throw new ContractError('oracle_missing', { path: spec.oracle_path });

  const goal = {
    format: GOAL_FORMAT,
    run_id: String(spec.run_id),
    goal_id: String(spec.goal_id),
    handoff_path: repoRel(repoRoot, handoffAbs),
    handoff_revision: sha256File(handoffAbs),
    base_commit: identity.head,
    worktree_realpath: identity.worktree_realpath,
    goal: String(spec.goal),
    success: spec.success,
    non_goals: spec.non_goals,
    forbidden_scope: spec.forbidden_scope,
    slices: Array.isArray(spec.slices) ? spec.slices : undefined,
    oracle_path: repoRel(repoRoot, oracleAbs),
    oracle_sha256: sha256File(oracleAbs),
    created_at: nowIso(),
  };
  if (goal.slices === undefined) delete goal.slices;

  // The capsule budget is a property of the FROZEN GOAL TEXT, so it is knowable
  // BEFORE the first write (arch P1-1). Checking it afterwards made init a
  // one-way trap: the error's own remedy ("shorten the goal") is forbidden by
  // goal immutability, and `resume` — the fresh-context entry point — stayed
  // permanently dead.
  const previewEvents = [{
    seq: 1, type: 'initialized', at: nowIso(), observed_head: identity.head,
    payload: { goal_sha256: '0'.repeat(64) },
  }];
  const previewCtx = {
    runDir, dirty_count: identity.dirty_count, resumeCommand: resumeCommand(repoRoot, runDir),
  };
  const preview = renderRecovery(goal, reduceRun(goal, previewEvents), previewCtx);
  if (preview.tokens > CAPSULE_TOKEN_BUDGET) {
    throw new ContractError('capsule_over_budget', {
      tokens: preview.tokens,
      budget: CAPSULE_TOKEN_BUDGET,
      composition: preview.composition,
      note: 'NOTHING was written. Shorten the goal/success text in the goal SPEC and re-run init. Hard anchors are never dropped to make a capsule fit.',
    });
  }

  // Transactional (arch P1-2): init leaves either a complete run or nothing.
  // A half-written run dir used to be permanently unusable — `init` refused
  // (run_already_initialized) and everything else refused (journal_missing).
  const dirExisted = fs.existsSync(runDir);
  const created = [];
  try {
    fs.mkdirSync(runDir, { recursive: true });
    const goalPath = path.join(runDir, 'goal.json');
    writeAtomic(goalPath, JSON.stringify(goal, null, 2) + '\n');
    created.push(goalPath);
    // The run owns its authority: a byte copy of the approved handoff, so a
    // later amendment of the live file cannot make this run unusable (P0-2).
    const frozenPath = path.join(runDir, 'handoff-frozen.md');
    fs.copyFileSync(handoffAbs, frozenPath);
    created.push(frozenPath);
    appendEvent(runDir, 1, 'initialized',
      { goal_sha256: sha256File(goalPath), base_commit: goal.base_commit }, identity.head);
    created.push(path.join(runDir, 'journal.jsonl'));

    const loaded = loadRun(runDir, repoRoot, cwd);
    const { packet, ctx } = writeDerived(runDir, repoRoot, loaded.goal, loaded.state, loaded.identity, out);
    created.push(path.join(runDir, 'checkpoint.json'), path.join(runDir, 'recovery.md'));
    out(renderStatus(loaded.goal, loaded.state, ctx));
    return finish('init', runDir, loaded.state, packet);
  } catch (err) {
    for (const f of created.reverse()) {
      try { fs.rmSync(f, { force: true }); } catch { /* best effort */ }
    }
    if (!dirExisted) {
      try { fs.rmSync(runDir, { recursive: true, force: true }); } catch { /* best effort */ }
    }
    throw err;
  }
}

function withRun(flags, cwd) {
  const identity0 = readGitIdentity(cwd);
  const repoRoot = identity0.worktree_realpath;
  const runDir = resolveRunDir(need(flags, 'run'), repoRoot);
  const loaded = loadRun(runDir, repoRoot, cwd);
  return { repoRoot, runDir, ...loaded };
}

function refuseIfHonestPartial(state, command) {
  if (state.state === 'HONEST_PARTIAL') {
    // Name the ACTUAL blocker. A generic 'run_in_honest_partial' hides which of
    // handoff drift / relocated worktree / missing evidence / unknown outcome is
    // in the way, and the operator's next move differs for each.
    throw new ContractError(state.blockers[0] ? state.blockers[0].code : 'run_in_honest_partial', {
      command,
      blockers: state.blockers,
      required: state.legal_next_action.action,
    });
  }
}

function cmdStatus(flags, cwd, out) {
  const r = withRun(flags, cwd);
  const ctx = {
    runDir: r.runDir,
    dirty_count: r.identity.dirty_count,
    resumeCommand: resumeCommand(r.repoRoot, r.runDir),
  };
  out(renderStatus(r.goal, r.state, ctx));
  return finish('status', r.runDir, r.state, null);
}

function cmdCheckpoint(flags, cwd, out) {
  const r = withRun(flags, cwd);
  refuseIfHonestPartial(r.state, 'checkpoint');
  if (r.state.pending_action) {
    throw new ContractError('pending_action_blocks_checkpoint', { action_id: r.state.pending_action.action_id });
  }
  const slice = need(flags, 'slice');
  const reason = need(flags, 'reason');
  const next = need(flags, 'next');
  if (!CHECKPOINT_REASONS.includes(reason)) {
    throw new UsageError('checkpoint_reason_invalid', { reason, allowed: CHECKPOINT_REASONS });
  }
  if (r.state.verified_slices.includes(slice)) {
    throw new ContractError('slice_already_verified', { slice });
  }
  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'checkpointed',
    { slice, reason, next }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  const { packet, ctx } = writeDerived(r.runDir, r.repoRoot, after.goal, after.state, after.identity, out);
  out(renderStatus(after.goal, after.state, ctx));
  return finish('checkpoint', r.runDir, after.state, packet);
}

function cmdVerify(flags, cwd, out) {
  const r = withRun(flags, cwd);
  refuseIfHonestPartial(r.state, 'verify');
  if (r.state.pending_action) {
    throw new ContractError('pending_action_blocks_verify', { action_id: r.state.pending_action.action_id });
  }
  const slice = need(flags, 'slice');
  const receiptInput = need(flags, 'receipt');
  const v = validateVerificationReceipt(receiptInput, {
    goal: r.goal, state: r.state, identity: r.identity, repoRoot: r.repoRoot, slice,
  });
  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'verified', {
    slice,
    receipt_path: v.repoRelPath,
    receipt_sha256: v.sha256,
    verified_head: v.receipt.verified_head,
    // Arch P1-3 "too weak": a commit id says nothing about a dirty tree, so
    // record what was actually observed at verify time instead of implying it.
    observed_head_at_verify: r.identity.head,
    dirty_paths_at_verify: r.identity.dirty_paths,
    gate_evidence: v.receipt.gate_evidence.map((e) => e.path),
    review_evidence: v.receipt.review_evidence.map((e) => e.path),
    written_by_id: v.receipt.written_by_id,
    executor_id: v.receipt.executor_id,
  }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  const { packet, ctx } = writeDerived(r.runDir, r.repoRoot, after.goal, after.state, after.identity, out);
  out(renderStatus(after.goal, after.state, ctx));
  return finish('verify', r.runDir, after.state, packet);
}

function cmdActionStart(flags, cwd, out) {
  const r = withRun(flags, cwd);
  const actionId = need(flags, 'action');
  // The blind-retry guard is checked BEFORE the generic honest_partial guard so
  // the operator sees the reason that names the real hazard (double-applying a
  // side effect) rather than the generic "run is blocked".
  if (r.state.forbidden_retry_actions.includes(actionId)) {
    throw new ContractError('blind_retry_forbidden', { action_id: actionId });
  }
  refuseIfHonestPartial(r.state, 'action-start');
  const description = need(flags, 'description');
  const targetInput = need(flags, 'target');
  const preSha = need(flags, 'pre-sha256');
  const postSha = need(flags, 'intended-post-sha256');

  if (r.state.pending_action) {
    throw new ContractError('concurrent_action', { pending: r.state.pending_action.action_id });
  }
  const targetAbs = resolveInRepo(targetInput, r.repoRoot, '--target');
  if (!fs.existsSync(targetAbs) || !fs.lstatSync(targetAbs).isFile()) {
    throw new ContractError('action_target_missing', { path: targetInput });
  }
  const actual = sha256File(targetAbs);
  if (actual !== preSha) {
    throw new ContractError('pre_state_mismatch', { path: targetInput, declared: preSha, actual });
  }
  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'action_started', {
    action_id: actionId,
    description,
    target: repoRel(r.repoRoot, targetAbs),
    pre_sha256: preSha,
    intended_post_sha256: postSha,
  }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  const { packet, ctx } = writeDerived(r.runDir, r.repoRoot, after.goal, after.state, after.identity, out);
  out(renderStatus(after.goal, after.state, ctx));
  return finish('action-start', r.runDir, after.state, packet);
}

function cmdReconcile(flags, cwd, out) {
  const r = withRun(flags, cwd);
  // Reconcile is deliberately NOT blocked by honest_partial — clearing an
  // outcome_unknown is its purpose. But a stopped run is closed, and appending
  // after `stopped` would make the journal unreducible forever (arch P0-1).
  if (r.state.stopped) {
    throw new ContractError('run_stopped', {
      reason: r.state.stopped.reason,
      note: 'this run is closed; open a NEW run from a known commit. Nothing further may be recorded here.',
    });
  }
  if (r.state.binding_blockers && r.state.binding_blockers.length > 0) {
    throw new ContractError(r.state.binding_blockers[0].code, {
      command: 'reconcile',
      blockers: r.state.binding_blockers,
      required: r.state.legal_next_action.action,
    });
  }
  const actionId = need(flags, 'action');
  const outcome = need(flags, 'outcome');
  if (!RECONCILE_OUTCOMES.includes(outcome)) {
    throw new UsageError('reconcile_outcome_invalid', { outcome, allowed: RECONCILE_OUTCOMES });
  }

  const unknown = r.state.unknown_actions.find((a) => a.action_id === actionId);
  if (!r.state.pending_action && !unknown) {
    throw new ContractError('unknown_action_reconcile', { action_id: actionId });
  }
  if (r.state.pending_action && r.state.pending_action.action_id !== actionId) {
    throw new ContractError('unknown_action_reconcile', { action_id: actionId, pending: r.state.pending_action.action_id });
  }

  let payload;
  if (unknown) {
    // Resolving a previously-unknown outcome: explicit evidence is mandatory.
    if (outcome !== 'reconciled') {
      throw new ContractError('unknown_outcome_needs_reconciled', { action_id: actionId, outcome });
    }
    const evidenceAbs = resolveInRepo(need(flags, 'evidence'), r.repoRoot, '--evidence');
    if (!fs.existsSync(evidenceAbs) || !fs.lstatSync(evidenceAbs).isFile()) {
      throw new ContractError('reconcile_evidence_missing', { path: flags.evidence });
    }
    const targetAbs = path.resolve(r.repoRoot, unknown.target);
    const observedDeclared = need(flags, 'observed-sha256');
    const observedActual = fs.existsSync(targetAbs) ? sha256File(targetAbs) : 'ABSENT';
    if (observedDeclared !== observedActual) {
      throw new ContractError('observed_sha_mismatch', { declared: observedDeclared, actual: observedActual });
    }
    payload = {
      action_id: actionId,
      outcome: 'reconciled',
      evidence: repoRel(r.repoRoot, evidenceAbs),
      evidence_sha256: sha256File(evidenceAbs),
      observed_sha256: observedActual,
      resolves: 'outcome_unknown',
    };
  } else {
    const pending = r.state.pending_action;
    const targetAbs = path.resolve(r.repoRoot, pending.target);
    const observedActual = fs.existsSync(targetAbs) ? sha256File(targetAbs) : 'ABSENT';
    if (flags['observed-sha256'] && String(flags['observed-sha256']) !== observedActual) {
      throw new ContractError('observed_sha_mismatch', { declared: String(flags['observed-sha256']), actual: observedActual });
    }
    if (outcome === 'confirmed') {
      if (observedActual !== pending.intended_post_sha256) {
        throw new ContractError('confirmed_requires_intended_post', {
          actual: observedActual, intended_post: pending.intended_post_sha256,
        });
      }
      payload = { action_id: actionId, outcome, observed_sha256: observedActual };
    } else if (outcome === 'outcome_unknown') {
      if (observedActual === pending.intended_post_sha256) {
        throw new ContractError('outcome_is_actually_confirmed', { actual: observedActual });
      }
      if (observedActual === pending.pre_sha256) {
        throw new ContractError('outcome_is_actually_untouched', {
          actual: observedActual,
          hint: 'target is byte-identical to pre-state; classify with explicit evidence via --outcome reconciled',
        });
      }
      payload = { action_id: actionId, outcome, observed_sha256: observedActual };
    } else {
      const evidenceAbs = resolveInRepo(need(flags, 'evidence'), r.repoRoot, '--evidence');
      if (!fs.existsSync(evidenceAbs) || !fs.lstatSync(evidenceAbs).isFile()) {
        throw new ContractError('reconcile_evidence_missing', { path: flags.evidence });
      }
      need(flags, 'observed-sha256');
      payload = {
        action_id: actionId,
        outcome: 'reconciled',
        evidence: repoRel(r.repoRoot, evidenceAbs),
        evidence_sha256: sha256File(evidenceAbs),
        observed_sha256: observedActual,
      };
    }
  }

  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'action_reconciled', payload, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  const { packet, ctx } = writeDerived(r.runDir, r.repoRoot, after.goal, after.state, after.identity, out);
  out(renderStatus(after.goal, after.state, ctx));
  return finish('reconcile', r.runDir, after.state, packet);
}

function cmdResume(flags, cwd, out) {
  const r = withRun(flags, cwd);
  const cpPath = path.join(r.runDir, 'checkpoint.json');
  const rebuild = flags['rebuild-derived'] === true || flags['rebuild-derived'] === 'true';
  const expected = semanticCheckpoint(r.state);
  if (fs.existsSync(cpPath) && !rebuild) {
    let existing;
    try {
      existing = JSON.parse(fs.readFileSync(cpPath, 'utf8'));
    } catch {
      throw new ContractError('checkpoint_corrupt', { path: cpPath, remedy: 'resume --rebuild-derived' });
    }
    const { generated_at: _ignored, ...body } = existing;
    if (JSON.stringify(body) !== JSON.stringify(expected)) {
      // Journal is authority; a derived file that disagrees is never silently
      // overwritten — the human/Conductor must acknowledge with --rebuild-derived.
      throw new ContractError('derived_state_conflict', {
        path: cpPath,
        remedy: 'inspect the difference, then re-run with resume --rebuild-derived to rebuild derived files from the journal',
      });
    }
  }
  const { packet, ctx } = writeDerived(r.runDir, r.repoRoot, r.goal, r.state, r.identity, out);
  out(renderStatus(r.goal, r.state, ctx));
  out(`RECOVERY PACKET: ${path.join(r.runDir, 'recovery.md')} (${packet.tokens} est. tokens, budget ${CAPSULE_TOKEN_BUDGET})\n`);
  return finish('resume', r.runDir, r.state, packet);
}

function cmdStop(flags, cwd, out) {
  const r = withRun(flags, cwd);
  const reason = need(flags, 'reason');
  if (r.state.stopped) throw new ContractError('already_stopped', { reason: r.state.stopped.reason });
  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'stopped', { reason }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  const { packet, ctx } = writeDerived(r.runDir, r.repoRoot, after.goal, after.state, after.identity, out);
  out(renderStatus(after.goal, after.state, ctx));
  return finish('stop', r.runDir, after.state, packet);
}

// ─────────────────────────── result shaping ───────────────────────────

function finish(command, runDir, state, packet) {
  if (packet && packet.tokens > CAPSULE_TOKEN_BUDGET) {
    // Report composition and stop. Hard anchors are never trimmed to fit.
    throw new ContractError('capsule_over_budget', {
      tokens: packet.tokens,
      budget: CAPSULE_TOKEN_BUDGET,
      composition: packet.composition,
      note: 'recovery.md was written in full; shorten the frozen goal/success text instead of dropping anchors',
    });
  }
  // FR5 counts an UNRESOLVED side effect as honest_partial. The state label stays
  // ACTION_PENDING (per the §4.4 state machine) but the exit code must not be 0,
  // or a script will happily march past an unreconciled real-world change.
  const honest = state.state === 'HONEST_PARTIAL' || state.state === 'ACTION_PENDING';
  return {
    exitCode: honest ? 1 : 0,
    status: {
      format: STATUS_FORMAT,
      command,
      result: honest ? 'HONEST_PARTIAL' : 'PASS',
      run_dir: runDir,
      state: state.state,
      reason: honest
        ? (state.blockers[0] ? state.blockers[0].code
          : (state.pending_action ? 'unreconciled_side_effect' : 'honest_partial'))
        : null,
      verified_slices: state.verified_slices,
      unverified_slices: state.candidate_slices.map((c) => c.slice),
      blockers: state.blockers,
      legal_next_action: state.legal_next_action,
      capsule_tokens: packet ? packet.tokens : null,
    },
  };
}

function errorResult(command, err) {
  const usage = err instanceof UsageError || err.kind === 'usage';
  return {
    exitCode: usage ? 2 : 1,
    status: {
      format: STATUS_FORMAT,
      command: command || null,
      result: usage ? 'USAGE_ERROR' : 'HONEST_PARTIAL',
      run_dir: null,
      state: usage ? 'USAGE_ERROR' : 'HONEST_PARTIAL',
      reason: err.reason || 'unexpected_error',
      details: err.details || { message: String(err && err.message).slice(0, 300) },
    },
  };
}

const USAGE = `yolo-recovery.mjs — TAD YOLO 2.0 Phase 1 recovery recorder (opt-in, experimental)

  init         --run <dir> --handoff <path> --goal-file <frozen-json>
  status       --run <dir>
  checkpoint   --run <dir> --slice <id> --reason <before-compact|before-stop|candidate> --next <text>
  verify       --run <dir> --slice <id> --receipt <verification-receipt.json>
  action-start --run <dir> --action <id> --description <text> --target <repo-path>
               --pre-sha256 <sha> --intended-post-sha256 <sha>
  reconcile    --run <dir> --action <id> --outcome <confirmed|outcome_unknown|reconciled>
               [--evidence <path>] [--observed-sha256 <sha>]
  resume       --run <dir> [--rebuild-derived]
  stop         --run <dir> --reason <text>

Exit: 0 PASS | 1 contract failure (honest_partial) | 2 usage/input error.
Last stdout line is always a single-line JSON status object.
`;

export function runCli(argv, options = {}) {
  const cwd = options.cwd || process.cwd();
  const chunks = [];
  const out = (s) => chunks.push(s);
  const command = argv[0];
  let res;
  try {
    if (!command || command === '--help' || command === '-h' || command === 'help') {
      out(USAGE);
      return { exitCode: 2, stdout: chunks.join('') + JSON.stringify({ format: STATUS_FORMAT, command: null, result: 'USAGE_ERROR', reason: 'no_command' }) + '\n' };
    }
    if (!COMMANDS.includes(command)) throw new UsageError('unknown_command', { command, allowed: COMMANDS });
    const { flags } = parseArgs(argv.slice(1));
    switch (command) {
      case 'init': res = cmdInit(flags, cwd, out); break;
      case 'status': res = cmdStatus(flags, cwd, out); break;
      case 'checkpoint': res = cmdCheckpoint(flags, cwd, out); break;
      case 'verify': res = cmdVerify(flags, cwd, out); break;
      case 'action-start': res = cmdActionStart(flags, cwd, out); break;
      case 'reconcile': res = cmdReconcile(flags, cwd, out); break;
      case 'resume': res = cmdResume(flags, cwd, out); break;
      case 'stop': res = cmdStop(flags, cwd, out); break;
      default: throw new UsageError('unknown_command', { command });
    }
  } catch (err) {
    res = errorResult(command, err);
    out(`\n!! ${res.status.result}: ${res.status.reason}\n${JSON.stringify(res.status.details || {}, null, 2)}\n`);
  }
  return { exitCode: res.exitCode, stdout: chunks.join('') + JSON.stringify(res.status) + '\n' };
}

// ─────────────────────────── entrypoint ───────────────────────────

const invokedDirectly = process.argv[1] && fs.existsSync(process.argv[1])
  && fs.realpathSync(process.argv[1]) === fileURLToPath(import.meta.url);

if (invokedDirectly) {
  const { exitCode, stdout } = runCli(process.argv.slice(2));
  process.stdout.write(stdout);
  process.exit(exitCode);
}
