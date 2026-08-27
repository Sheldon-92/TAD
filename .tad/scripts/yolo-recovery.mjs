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
  'round_prepared',
  'reentry_verified',
  'round_closed',
  'alignment_verified',
  'phase_candidate_recorded',
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
  'round-prepare', 'round-authorize', 'round-close', 'align', 'phase-candidate',
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
    dirtyPaths = porcelain ? porcelain.split('\n').filter(Boolean).map((l) => l.slice(2).trimStart()) : [];
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

/** Hash the visible worktree so a pre-dirty path cannot hide a later rewrite. */
function readWorktreeManifest(repoRoot) {
  const files = git(['ls-files', '--cached', '--others', '--exclude-standard'], repoRoot);
  const manifest = {};
  if (!files) return manifest;
  for (const rel of files.split('\n').filter(Boolean)) {
    const abs = anchorAtRepo(rel, repoRoot);
    if (!fs.existsSync(abs) || !fs.lstatSync(abs).isFile()) continue;
    manifest[rel] = sha256File(abs);
  }
  return manifest;
}

function manifestChangedPaths(before, after) {
  const paths = new Set([...Object.keys(before || {}), ...Object.keys(after || {})]);
  return [...paths].filter((rel) => (before || {})[rel] !== (after || {})[rel]).sort();
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

/** Stable JSON is the identity of policy inputs and observed effects. */
function canonicalize(value) {
  if (Array.isArray(value)) return value.map(canonicalize);
  if (isPlainObject(value)) {
    return Object.keys(value).sort().reduce((out, key) => {
      if (value[key] !== undefined) out[key] = canonicalize(value[key]);
      return out;
    }, {});
  }
  return value;
}

function canonicalJson(value) {
  return JSON.stringify(canonicalize(value));
}

function isSha256(value) {
  return typeof value === 'string' && /^[0-9a-f]{64}$/.test(value);
}

function successCriterionIds(goal) {
  return (Array.isArray(goal.success) ? goal.success : []).map((criterion, index) => {
    if (isPlainObject(criterion) && typeof criterion.id === 'string' && criterion.id.trim()) {
      return criterion.id.trim();
    }
    return `SC-${index + 1}`;
  });
}

function frozenSliceIds(goal) {
  return Array.isArray(goal.slices) ? goal.slices.map((slice) => slice.id) : [];
}

function forbiddenScopeHash(goal) {
  return sha256String(canonicalJson(goal.forbidden_scope));
}

/**
 * Validate a repo-relative path without silently normalizing it. Existing
 * ancestors are realpathed so a symlink cannot turn an allowed path into an
 * outside-repository path. A trailing slash is retained for bounded prefixes.
 */
function validateRepoRelativePath(input, repoRoot, label, { allowPrefix = false } = {}) {
  if (typeof input !== 'string' || input.length === 0 || path.isAbsolute(input) || input.includes('\\')) {
    throw new ContractError('path_not_repo_relative', { label, path: input });
  }
  const normalized = path.normalize(input);
  const expected = allowPrefix && input.endsWith('/') && !normalized.endsWith('/')
    ? `${normalized}/` : normalized;
  if (expected !== input || normalized === '.' || normalized === '..'
      || normalized.startsWith(`..${path.sep}`)) {
    throw new ContractError('path_not_normalized', { label, path: input, normalized: expected });
  }
  const lookup = input.endsWith('/') ? input.slice(0, -1) : input;
  if (!lookup) throw new ContractError('path_not_repo_relative', { label, path: input });
  const abs = realpathDeepest(path.join(repoRoot, lookup));
  try {
    assertInside(repoRoot, abs, label);
  } catch (err) {
    throw new ContractError('path_escape', { label, path: abs, base: repoRoot, cause: err.details || {} });
  }
  return { rel: input, abs };
}

function normalizeObservedPath(value) {
  if (typeof value !== 'string') return null;
  const text = value.trim();
  if (!text) return null;
  // Accept both git porcelain entries (" M path", "?? path") and plain paths.
  if (text.length > 3 && /^(?:..|\?\?)\s/.test(text)) return text.slice(3).trim();
  return text;
}

function sortedUnique(values) {
  return [...new Set(values)].sort();
}

function mutationPaths(call) {
  if (!call || typeof call !== 'object') return [];
  return sortedUnique([
    ...(Array.isArray(call.observed_changed) ? call.observed_changed : []),
    ...(Array.isArray(call.observed_deleted) ? call.observed_deleted : []),
    ...(Array.isArray(call.observed_untracked) ? call.observed_untracked : []),
  ].map(normalizeObservedPath).filter(Boolean));
}

function effectDigests(call) {
  if (!call || typeof call !== 'object') return [];
  const source = call.observed_final_content_or_effect_digests
    ?? call.observed_effect_digests
    ?? call.effect_digests
    ?? (call.post_sha256 ? [call.post_sha256] : [])
    ?? [];
  if (Array.isArray(source)) return source.map(String).sort();
  if (isPlainObject(source)) {
    return Object.keys(source).sort().map((key) => [key, source[key]]);
  }
  return source === undefined || source === null ? [] : [String(source)];
}

function effectFingerprint(callOrPaths, maybeDigests) {
  const paths = Array.isArray(callOrPaths) ? sortedUnique(callOrPaths) : mutationPaths(callOrPaths);
  const digests = Array.isArray(callOrPaths) ? (maybeDigests || []) : effectDigests(callOrPaths);
  return sha256String(canonicalJson([paths, digests]));
}

// ─────────────────────────── goal / journal ───────────────────────────

const GOAL_REQUIRED = [
  'format', 'run_id', 'goal_id', 'handoff_path', 'handoff_revision',
  'base_commit', 'worktree_realpath', 'goal', 'success', 'non_goals',
  'forbidden_scope', 'oracle_path', 'created_at',
];

export function validateExecutionPolicy(goal) {
  const ep = goal.execution_policy;
  if (!ep) return null;
  if (ep.format !== 'yolo-bounded-policy-v1') {
    throw new ContractError('policy_format_invalid', { format: ep.format });
  }
  for (const f of ['max_rounds', 'max_retries_per_slice', 'max_actions', 'max_wall_seconds',
    'max_tokens', 'audit_reserve_tokens', 'max_executor_tokens_per_round',
    'align_every_verified_slices', 'packet_token_budget']) {
    if (!Number.isInteger(ep[f]) || ep[f] <= 0) {
      throw new ContractError('policy_field_invalid', { field: f, value: ep[f] });
    }
  }
  if (ep.audit_reserve_tokens >= ep.max_tokens) {
    throw new ContractError('policy_reserve_ge_max', { audit_reserve_tokens: ep.audit_reserve_tokens, max_tokens: ep.max_tokens });
  }
  if (ep.max_executor_tokens_per_round > ep.max_tokens - ep.audit_reserve_tokens) {
    throw new ContractError('policy_round_ceiling_exceeds_consumable', { max_executor_tokens_per_round: ep.max_executor_tokens_per_round });
  }
  if (![2, 3].includes(ep.align_every_verified_slices)) {
    throw new ContractError('policy_align_invalid', { align_every_verified_slices: ep.align_every_verified_slices });
  }
  return ep;
}

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
  const criterionIds = successCriterionIds(goal);
  if (new Set(criterionIds).size !== criterionIds.length || criterionIds.some((id) => !id)) {
    throw new ContractError('goal_success_ids_invalid', { ids: criterionIds });
  }
  if (goal.slices !== undefined) {
    if (!Array.isArray(goal.slices)) throw new ContractError('goal_field_not_array', { field: 'slices' });
    if (new Set(goal.slices.map((s) => s && s.id)).size !== goal.slices.length) {
      throw new ContractError('goal_slice_ids_duplicate', {});
    }
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
  const verified = [];               // [{slice, seq, at, receipt_path, receipt_sha256, verified_head, round_id?}]
  const verifiedIds = new Set();
  const checkpoints = new Map();     // slice -> {slice, reason, next, seq, at}
  const actionsSeen = new Set();
  const actionRecords = [];
  const actionById = new Map();
  const actionNonces = new Set();
  const verifiedEffectFingerprints = new Set();
  const forbiddenRetry = new Set();
  const unknownActions = [];
  let pendingAction = null;
  let stopped = null;
  let latestHead = null;

  // ── Phase-2 bounded-round tracking (active only when execution_policy exists) ──
  const policy = goal.execution_policy || null;
  let currentRound = null;      // {id, slice_id, state: prepared|authorized|closed_candidate|closed_failed|closed_blocked}
  let lastClosedRound = null;   // consumed by verify (candidate) or replaced (failed/blocked)
  let roundsPrepared = 0;
  let verifiedSinceAlignment = 0;
  let alignmentWatermark = null;
  let phaseCandidate = null;
  let tokensCharged = 0;
  let assertionTokens = 0;
  let executionTokens = 0;
  let lastEventAt = null;
  const clockBlockers = [];
  const mintedNonces = [];
  const forbiddenRetryNonces = new Set();
  const retryCounts = new Map();

  for (const ev of events) {
    if (phaseCandidate) throw new ContractError('event_after_phase_candidate', {
      seq: ev.seq, type: ev.type, phase_candidate_seq: phaseCandidate.seq,
    });
    if (stopped) throw new ContractError('event_after_stop', { seq: ev.seq, type: ev.type });
    latestHead = ev.observed_head;
    // Clock integrity (Phase-2 budgets): a timestamp moving backwards is a
    // blocker, never free extra wall time.
    if (lastEventAt !== null && String(ev.at) < String(lastEventAt)) {
      clockBlockers.push({ code: 'clock_integrity', detail: `seq ${ev.seq} at ${ev.at} precedes ${lastEventAt}` });
    }
    lastEventAt = ev.at;
    if (policy && typeof goal.created_at === 'string') {
      const start = Date.parse(goal.created_at);
      const observed = Date.parse(ev.at);
      if (Number.isFinite(start) && Number.isFinite(observed)
          && observed > start + policy.max_wall_seconds * 1000) {
        clockBlockers.push({
          code: 'budget_exhausted', budget: 'wall_time',
          detail: `event ${ev.seq} observed after the frozen wall-time deadline`,
        });
      }
    }
    const p = ev.payload;
    switch (ev.type) {
      case 'initialized':
        if (ev.seq !== 1) throw new ContractError('duplicate_initialized', { seq: ev.seq });
        if (typeof p.goal_sha256 !== 'string' || !p.goal_sha256) {
          throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'payload.goal_sha256' });
        }
        break;
      case 'checkpointed': {
        if (policy) throw new ContractError('legacy_checkpoint_forbidden', { seq: ev.seq, note: 'policy mode: round-close is the only candidate path' });
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
        if (policy) {
          // Policy mode: verify requires the matching round closed as candidate.
          if (!lastClosedRound || lastClosedRound.state !== 'closed_candidate'
            || lastClosedRound.slice_id !== p.slice) {
            throw new ContractError('verify_requires_closed_candidate', {
              seq: ev.seq, slice: p.slice,
              note: 'policy mode: run round-close --outcome candidate before verify',
            });
          }
          if (!frozenSliceIds(goal).includes(p.slice)) {
            throw new ContractError('slice_not_frozen', { seq: ev.seq, slice: p.slice });
          }
          const mapping = Array.isArray(p.maps_to_success)
            ? p.maps_to_success : lastClosedRound.maps_to_success;
          if (!Array.isArray(mapping) || mapping.length === 0
              || new Set(mapping).size !== mapping.length
              || mapping.some((id) => !successCriterionIds(goal).includes(id))) {
            throw new ContractError('success_mapping_invalid', { seq: ev.seq, slice: p.slice });
          }
          if (JSON.stringify([...mapping].sort())
              !== JSON.stringify([...lastClosedRound.maps_to_success].sort())) {
            throw new ContractError('success_mapping_mismatch', { seq: ev.seq, slice: p.slice });
          }
        }
        verifiedIds.add(p.slice);
        verified.push({
          slice: p.slice,
          seq: ev.seq,
          at: ev.at,
          receipt_path: p.receipt_path,
          receipt_sha256: p.receipt_sha256,
          verified_head: p.verified_head,
          maps_to_success: policy
            ? [...(Array.isArray(p.maps_to_success) ? p.maps_to_success : lastClosedRound.maps_to_success)]
            : undefined,
          effect_fingerprints: policy && lastClosedRound ? [...(lastClosedRound.effect_fingerprints || [])] : [],
          executor_id: p.executor_id || null,
        });
        checkpoints.delete(p.slice);
        if (policy) {
          for (const fp of lastClosedRound.effect_fingerprints || []) verifiedEffectFingerprints.add(fp);
          lastClosedRound = null;
          verifiedSinceAlignment += 1;
        }
        break;
      }
      case 'action_started': {
        const id = p.action_id;
        if (!id) throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'payload.action_id' });
        if (forbiddenRetry.has(id)) throw new ContractError('blind_retry_forbidden', { seq: ev.seq, action_id: id });
        if (actionsSeen.has(id)) throw new ContractError('duplicate_action_id', { seq: ev.seq, action_id: id });
        if (pendingAction) throw new ContractError('concurrent_action', { seq: ev.seq, pending: pendingAction.action_id });
        if (policy && (!currentRound || currentRound.state !== 'authorized')) {
          throw new ContractError('action_requires_authorized_round', { seq: ev.seq, action_id: id });
        }
        if (policy) {
          for (const field of ['round', 'outcome_id', 'tool_class', 'args_path',
            'args_sha256', 'effect_manifest_path', 'effect_manifest_sha256', 'action_nonce']) {
            if (p[field] === undefined || p[field] === null || p[field] === '') {
              throw new ContractError('journal_field_missing', { seq: ev.seq, field: `payload.${field}` });
            }
          }
          if (p.round !== currentRound.id) throw new ContractError('stale_round_action', {
            seq: ev.seq, action_id: id, action_round: p.round, current_round: currentRound.id,
          });
          if (!isSha256(p.pre_sha256) || !isSha256(p.intended_post_sha256)
              || !isSha256(p.args_sha256) || !isSha256(p.effect_manifest_sha256)) {
            throw new ContractError('action_hash_invalid', { seq: ev.seq, action_id: id });
          }
          if (typeof p.action_nonce !== 'string' || p.action_nonce.trim() === '') {
            throw new ContractError('action_nonce_invalid', { seq: ev.seq, action_id: id });
          }
          if (actionNonces.has(p.action_nonce)) {
            throw new ContractError('action_nonce_reused', { seq: ev.seq, action_id: id, action_nonce: p.action_nonce });
          }
          if (!Array.isArray(p.effect_paths) || p.effect_paths.length === 0
              || p.effect_paths.some((v) => typeof v !== 'string' || !v)) {
            throw new ContractError('effect_paths_invalid', { seq: ev.seq, action_id: id });
          }
          const effectPaths = sortedUnique(p.effect_paths);
          if (effectPaths.length !== p.effect_paths.length) {
            throw new ContractError('effect_paths_duplicate', { seq: ev.seq, action_id: id });
          }
          actionNonces.add(p.action_nonce);
          mintedNonces.push(p.action_nonce);
          const record = {
            action_id: id,
            description: p.description,
            round: p.round,
            target: p.target,
            pre_sha256: p.pre_sha256,
            intended_post_sha256: p.intended_post_sha256,
            outcome_id: p.outcome_id,
            tool_class: p.tool_class,
            args_path: p.args_path,
            args_sha256: p.args_sha256,
            effect_manifest_path: p.effect_manifest_path,
            effect_manifest_sha256: p.effect_manifest_sha256,
            effect_paths: effectPaths,
            action_nonce: p.action_nonce,
            reconciliation_outcome: null,
            observed_sha256: null,
            seq: ev.seq,
            at: ev.at,
          };
          actionRecords.push(record);
          actionById.set(id, record);
        }
        actionsSeen.add(id);
        if (!policy && p.action_nonce) mintedNonces.push(p.action_nonce);
        pendingAction = {
          action_id: id,
          description: p.description,
          target: p.target,
          pre_sha256: p.pre_sha256,
          intended_post_sha256: p.intended_post_sha256,
          action_nonce: p.action_nonce || null,
          round: p.round || null,
          outcome_id: p.outcome_id || null,
          tool_class: p.tool_class || null,
          args_path: p.args_path || null,
          args_sha256: p.args_sha256 || null,
          effect_manifest_path: p.effect_manifest_path || null,
          effect_manifest_sha256: p.effect_manifest_sha256 || null,
          effect_paths: Array.isArray(p.effect_paths) ? [...p.effect_paths] : [],
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
        const policyAction = policy ? actionById.get(id) : null;
        if (policy && !policyAction) {
          throw new ContractError('unknown_action_reconcile', { seq: ev.seq, action_id: id });
        }
        if (policy && (!isSha256(p.observed_sha256) && p.observed_sha256 !== 'ABSENT')) {
          throw new ContractError('observed_hash_invalid', { seq: ev.seq, action_id: id });
        }
        if (p.outcome === 'outcome_unknown') {
          forbiddenRetry.add(id);
          if (pendingAction && pendingAction.action_nonce) forbiddenRetryNonces.add(pendingAction.action_nonce);
          unknownActions.push({
            action_id: id,
            target: pendingAction ? pendingAction.target : (p.target || null),
            observed_sha256: p.observed_sha256 || null,
            seq: ev.seq,
          });
        } else if (p.outcome === 'reconciled') {
          const idx = unknownActions.findIndex((a) => a.action_id === id);
          if (idx >= 0) unknownActions.splice(idx, 1);
        }
        if (policyAction) {
          policyAction.reconciliation_outcome = p.outcome;
          policyAction.observed_sha256 = p.observed_sha256 || null;
          policyAction.reconciliation_seq = ev.seq;
          policyAction.reconciliation_evidence = p.evidence || null;
          policyAction.reconciliation_evidence_sha256 = p.evidence_sha256 || null;
        }
        pendingAction = null;
        break;
      }
      // ── Phase-2 bounded-round events (require execution_policy in goal.json) ──
      case 'round_prepared': {
        if (!policy) throw new ContractError('policy_mode_required', { seq: ev.seq, type: ev.type });
        if (currentRound) throw new ContractError('prepare_with_open_round', { seq: ev.seq, open: currentRound.id });
        if (lastClosedRound && lastClosedRound.state === 'closed_candidate') {
          throw new ContractError('candidate_requires_verify', { seq: ev.seq, round_id: lastClosedRound.id });
        }
        if (!p.round_id || !p.slice_id || !p.contract_sha256 || !p.packet_sha256) {
          throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'round_prepared payload' });
        }
        if (!isSha256(p.contract_sha256) || !isSha256(p.packet_sha256)) {
          throw new ContractError('round_artifact_hash_invalid', { seq: ev.seq, round_id: p.round_id });
        }
        if (!frozenSliceIds(goal).includes(p.slice_id)) {
          throw new ContractError('slice_not_frozen', { seq: ev.seq, slice: p.slice_id });
        }
        if (!Array.isArray(p.maps_to_success) || p.maps_to_success.length === 0
            || p.maps_to_success.some((id) => !successCriterionIds(goal).includes(id))) {
          throw new ContractError('success_mapping_invalid', { seq: ev.seq, maps_to_success: p.maps_to_success });
        }
        if (new Set(p.maps_to_success).size !== p.maps_to_success.length) {
          throw new ContractError('success_mapping_duplicate', { seq: ev.seq, maps_to_success: p.maps_to_success });
        }
        if (!Array.isArray(p.allowed_paths) || p.allowed_paths.length === 0
            || !Array.isArray(p.tool_allowlist) || p.tool_allowlist.length === 0
            || !Array.isArray(p.deterministic_checks)
            || !Array.isArray(p.necessary_evidence)
            || !isPlainObject(p.worktree_manifest_at_prepare)) {
          throw new ContractError('round_contract_binding_missing', { seq: ev.seq, round_id: p.round_id });
        }
        if (roundsPrepared >= policy.max_rounds) {
          throw new ContractError('budget_exhausted', { budget: 'rounds', used: roundsPrepared, max: policy.max_rounds });
        }
        const retryCount = retryCounts.get(p.slice_id) || 0;
        if (retryCount >= policy.max_retries_per_slice) {
          throw new ContractError('budget_exhausted', {
            budget: 'retries', slice: p.slice_id, used: retryCount, max: policy.max_retries_per_slice,
          });
        }
        if (typeof p.packet_rel !== 'string' || !p.packet_rel
            || typeof p.contract_rel !== 'string' || !p.contract_rel) {
          throw new ContractError('round_artifact_binding_missing', { seq: ev.seq, round_id: p.round_id });
        }
        currentRound = {
          id: p.round_id, slice_id: p.slice_id, state: 'prepared', seq: ev.seq,
          contract_rel: p.contract_rel, contract_sha256: p.contract_sha256,
           packet_rel: p.packet_rel, packet_sha256: p.packet_sha256,
           maps_to_success: [...p.maps_to_success], allowed_paths: [...p.allowed_paths],
           tool_allowlist: [...p.tool_allowlist], deterministic_checks: [...p.deterministic_checks],
           necessary_evidence: p.necessary_evidence.map((entry) => ({ ...entry })),
          dirty_paths_at_prepare: Array.isArray(p.dirty_paths_at_prepare) ? [...p.dirty_paths_at_prepare] : [],
          worktree_manifest_at_prepare: isPlainObject(p.worktree_manifest_at_prepare)
            ? { ...p.worktree_manifest_at_prepare } : {},
        };
        roundsPrepared += 1;
        if (lastClosedRound && ['closed_failed', 'closed_blocked'].includes(lastClosedRound.state)
            && lastClosedRound.slice_id === p.slice_id) {
          retryCounts.set(p.slice_id, retryCount + 1);
        }
        break;
      }
      case 'reentry_verified': {
        if (!policy) throw new ContractError('policy_mode_required', { seq: ev.seq, type: ev.type });
        if (!currentRound || currentRound.state !== 'prepared') {
          throw new ContractError('authorize_requires_prepared_round', { seq: ev.seq });
        }
        if (p.round_id !== currentRound.id) throw new ContractError('round_mismatch', { seq: ev.seq });
        if (!p.session_id || !Number.isInteger(p.reservation_tokens) || p.reservation_tokens <= 0) {
          throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'reentry_verified payload' });
        }
        for (const field of ['assertion_path', 'assertion_sha256', 'review_path', 'review_sha256',
          'turn_record_path', 'turn_record_sha256', 'assertion_author_id', 'reviewer_id']) {
          if (typeof p[field] !== 'string' || !p[field]) {
            throw new ContractError('journal_field_missing', { seq: ev.seq, field: `payload.${field}` });
          }
        }
        for (const field of ['assertion_sha256', 'review_sha256', 'turn_record_sha256']) {
          if (!isSha256(p[field])) throw new ContractError('native_provenance_malformed', { seq: ev.seq, field });
        }
        if (!p.assertion_usage || p.assertion_usage.native !== true) {
          throw new ContractError('usage_not_native', { seq: ev.seq, role: 'assertion' });
        }
        const assertionTotal = checkedUsageTotal(p.assertion_usage, 'assertion_usage');
        if (p.reservation_tokens > policy.max_executor_tokens_per_round) {
          throw new ContractError('reservation_invalid', { seq: ev.seq, reservation: p.reservation_tokens });
        }
        if (tokensCharged + assertionTotal + p.reservation_tokens
            > policy.max_tokens - policy.audit_reserve_tokens) {
          throw new ContractError('audit_reserve_would_be_consumed', {
            seq: ev.seq, charged: tokensCharged, assertion: assertionTotal,
            reservation: p.reservation_tokens, audit_reserve: policy.audit_reserve_tokens,
          });
        }
        currentRound.state = 'authorized';
        currentRound.session_id = p.session_id;
        currentRound.reservation_tokens = p.reservation_tokens;
        currentRound.assertion_author_id = p.assertion_author_id || null;
        currentRound.reviewer_id = p.reviewer_id || null;
        currentRound.assertion_sha256 = p.assertion_sha256 || null;
        currentRound.review_sha256 = p.review_sha256 || null;
        currentRound.turn_record_sha256 = p.turn_record_sha256 || null;
        currentRound.assertion_usage = { ...p.assertion_usage, total_tokens: assertionTotal };
        tokensCharged += assertionTotal;
        assertionTokens += assertionTotal;
        break;
      }
      case 'round_closed': {
        if (!policy) throw new ContractError('policy_mode_required', { seq: ev.seq, type: ev.type });
        if (!currentRound || currentRound.state !== 'authorized') {
          throw new ContractError('close_requires_authorized_round', { seq: ev.seq });
        }
        if (p.round_id !== currentRound.id) throw new ContractError('round_mismatch', { seq: ev.seq });
        if (!['candidate', 'failed', 'blocked'].includes(p.outcome)) {
          throw new ContractError('close_outcome_invalid', { seq: ev.seq, outcome: p.outcome });
        }
        for (const field of ['report_path', 'report_sha256', 'usage_path', 'usage_sha256',
          'turn_record_path', 'turn_record_sha256', 'packet_sha256']) {
          if (typeof p[field] !== 'string' || !p[field]) {
            throw new ContractError('round_close_binding_missing', { seq: ev.seq, field });
          }
        }
        if (p.packet_sha256 !== currentRound.packet_sha256) {
          throw new ContractError('packet_mismatch', { seq: ev.seq, round_id: currentRound.id });
        }
        if (p.session_id !== currentRound.session_id) {
          throw new ContractError('session_mismatch', { seq: ev.seq, pinned: currentRound.session_id, observed: p.session_id });
        }
        for (const field of ['report_sha256', 'usage_sha256', 'turn_record_sha256']) {
          if (!isSha256(p[field])) throw new ContractError('round_close_hash_invalid', { seq: ev.seq, field });
        }
        if (!p.usage || p.usage.native !== true) throw new ContractError('usage_not_native', { seq: ev.seq });
        const executionTotal = checkedUsageTotal(p.usage, 'usage');
        if (executionTotal > currentRound.reservation_tokens) {
          throw new ContractError('token_reservation_exceeded', {
            seq: ev.seq, total: executionTotal, reservation: currentRound.reservation_tokens,
          });
        }
        if (tokensCharged + executionTotal > policy.max_tokens - policy.audit_reserve_tokens) {
          throw new ContractError('budget_exhausted', {
            seq: ev.seq, budget: 'tokens', charged: tokensCharged,
            attempted: executionTotal, max: policy.max_tokens, audit_reserve: policy.audit_reserve_tokens,
          });
        }
        if (!Array.isArray(p.observed_mutations) || !Array.isArray(p.consumed_action_nonces)
            || !Array.isArray(p.effect_fingerprints)) {
          throw new ContractError('round_observation_binding_missing', { seq: ev.seq });
        }
        if (new Set(p.consumed_action_nonces).size !== p.consumed_action_nonces.length
            || new Set(p.effect_fingerprints).size !== p.effect_fingerprints.length) {
          throw new ContractError('duplicate_action_nonce', { seq: ev.seq, round_id: currentRound.id });
        }
        if (p.consumed_action_nonces.some((nonce) => typeof nonce !== 'string' || !nonce)
            || p.effect_fingerprints.some((fingerprint) => !isSha256(fingerprint))) {
          throw new ContractError('round_observation_binding_invalid', { seq: ev.seq });
        }
        for (const observation of p.observed_mutations) {
          if (!isPlainObject(observation) || typeof observation.action_id !== 'string'
              || typeof observation.action_nonce !== 'string' || !Array.isArray(observation.paths)
              || !isSha256(observation.observed_sha256)
              || !isSha256(observation.effect_fingerprint)) {
            throw new ContractError('round_observation_binding_invalid', { seq: ev.seq, observation });
          }
          // paths may be empty: an inspected no-op consumption (effect already
          // present) is a legal, explicitly recorded outcome.
        }
        const currentActions = actionRecords.filter((a) => a.round === currentRound.id);
        const currentNonces = currentActions.map((a) => a.action_nonce);
        if (JSON.stringify([...currentNonces].sort())
            !== JSON.stringify([...p.consumed_action_nonces].sort())) {
          throw new ContractError('action_reconciliation_incomplete', {
            seq: ev.seq, round_id: currentRound.id,
            expected: currentNonces, consumed: p.consumed_action_nonces,
          });
        }
        const observedNonces = p.observed_mutations.map((observation) => observation.action_nonce);
        const observedEffects = p.observed_mutations.map((observation) => observation.effect_fingerprint);
        if (JSON.stringify([...observedNonces].sort()) !== JSON.stringify([...p.consumed_action_nonces].sort())
            || JSON.stringify([...observedEffects].sort()) !== JSON.stringify([...p.effect_fingerprints].sort())) {
          throw new ContractError('round_observation_binding_invalid', { seq: ev.seq });
        }
        for (const action of currentActions) {
          if (!['confirmed', 'reconciled'].includes(action.reconciliation_outcome)) {
            throw new ContractError('action_not_reconciled', { seq: ev.seq, action_id: action.action_id });
          }
        }
        if (p.outcome === 'candidate' && Array.isArray(p.failed_checks) && p.failed_checks.length > 0) {
          throw new ContractError('failed_deterministic_check', { seq: ev.seq, checks: p.failed_checks });
        }
        currentRound.state = p.outcome === 'candidate' ? 'closed_candidate' : `closed_${p.outcome}`;
        currentRound.outcome = p.outcome;
        currentRound.report_path = p.report_path;
        currentRound.report_sha256 = p.report_sha256;
        currentRound.usage_path = p.usage_path;
        currentRound.usage_sha256 = p.usage_sha256;
        currentRound.turn_record_path = p.turn_record_path;
        currentRound.turn_record_sha256 = p.turn_record_sha256;
        currentRound.execution_usage = { ...p.usage, total_tokens: executionTotal };
        currentRound.observed_mutations = [...p.observed_mutations];
        currentRound.consumed_action_nonces = [...p.consumed_action_nonces];
        currentRound.effect_fingerprints = [...p.effect_fingerprints];
        currentRound.failed_checks = Array.isArray(p.failed_checks) ? [...p.failed_checks] : [];
        lastClosedRound = { ...currentRound };
        currentRound = null;
        tokensCharged += executionTotal;
        executionTokens += executionTotal;
        break;
      }
      case 'alignment_verified': {
        if (!policy) throw new ContractError('policy_mode_required', { seq: ev.seq, type: ev.type });
        if (!p.verified_digest || !p.receipt_sha256 || !p.receipt_path) {
          throw new ContractError('journal_field_missing', { seq: ev.seq, field: 'alignment_verified payload' });
        }
        if (p.watermark_seq !== ev.seq - 1 || p.verified_digest !== sha256String(JSON.stringify(verified))) {
          throw new ContractError('alignment_stale_digest', { seq: ev.seq, watermark_seq: p.watermark_seq });
        }
        const expectedSuccess = successCriterionIds(goal);
        if (!Array.isArray(p.success_ids)
            || new Set(p.success_ids).size !== p.success_ids.length
            || JSON.stringify([...p.success_ids].sort()) !== JSON.stringify([...expectedSuccess].sort())) {
          throw new ContractError('alignment_success_coverage_invalid', { seq: ev.seq });
        }
        if (p.goal_sha256 !== events[0].payload.goal_sha256 || p.handoff_revision !== goal.handoff_revision) {
          throw new ContractError('alignment_binding_mismatch', { seq: ev.seq });
        }
        alignmentWatermark = {
          seq: ev.seq, watermark_seq: p.watermark_seq, verified_digest: p.verified_digest,
          receipt_path: p.receipt_path, receipt_sha256: p.receipt_sha256,
          success_ids: [...p.success_ids], reviewer_id: p.reviewer_id || null,
        };
        verifiedSinceAlignment = 0;
        break;
      }
      case 'phase_candidate_recorded': {
        if (!policy) throw new ContractError('policy_mode_required', { seq: ev.seq, type: ev.type });
        if (currentRound) throw new ContractError('phase_candidate_with_open_round', { seq: ev.seq, open: currentRound.id });
        if (pendingAction || unknownActions.length > 0 || lastClosedRound) {
          throw new ContractError('phase_candidate_closure_incomplete', { seq: ev.seq });
        }
        const frozen = frozenSliceIds(goal);
        if (frozen.length === 0 || frozen.length !== verifiedIds.size
            || frozen.some((id) => !verifiedIds.has(id))) {
          throw new ContractError('phase_candidate_slices_incomplete', { seq: ev.seq, frozen, verified: [...verifiedIds] });
        }
        const covered = new Set(verified.flatMap((v) => v.maps_to_success || []));
        const expectedSuccess = successCriterionIds(goal);
        if (expectedSuccess.some((id) => !covered.has(id))) {
          throw new ContractError('phase_candidate_success_coverage_incomplete', {
            seq: ev.seq, missing: expectedSuccess.filter((id) => !covered.has(id)),
          });
        }
        if (!alignmentWatermark || alignmentWatermark.seq !== ev.seq - 1
            || alignmentWatermark.verified_digest !== sha256String(JSON.stringify(verified))) {
          throw new ContractError('phase_candidate_alignment_required', { seq: ev.seq });
        }
        if (roundsPrepared > policy.max_rounds || actionsSeen.size > policy.max_actions
            || tokensCharged > policy.max_tokens - policy.audit_reserve_tokens
            || [...retryCounts.values()].some((count) => count > policy.max_retries_per_slice)) {
          throw new ContractError('budget_exhausted', { seq: ev.seq, budget: 'phase_candidate' });
        }
        for (const field of ['receipt_sha256', 'goal_sha256', 'handoff_revision', 'verified_digest',
          'watermark_seq', 'hidden_acceptance_sha256', 'final_reviewer_id']) {
          if (p[field] === undefined || p[field] === null || p[field] === '') {
            throw new ContractError('phase_candidate_binding_missing', { seq: ev.seq, field });
          }
        }
        if (p.goal_sha256 !== events[0].payload.goal_sha256
            || p.handoff_revision !== goal.handoff_revision
            || p.watermark_seq !== alignmentWatermark.watermark_seq
            || p.verified_digest !== alignmentWatermark.verified_digest
            || p.alignment_receipt_sha256 !== alignmentWatermark.receipt_sha256) {
          throw new ContractError('phase_candidate_binding_mismatch', { seq: ev.seq });
        }
        if (!isSha256(p.hidden_acceptance_sha256) || p.hidden_acceptance_verdict !== 'PASS'
            || p.final_reviewer_independent !== true
            || typeof p.final_reviewer_id !== 'string' || !p.final_reviewer_id) {
          throw new ContractError('phase_candidate_quality_incomplete', { seq: ev.seq });
        }
        phaseCandidate = {
          seq: ev.seq, receipt_sha256: p.receipt_sha256,
          receipt_path: p.receipt_path || null,
          hidden_acceptance_path: p.hidden_acceptance_path || null,
          hidden_acceptance_sha256: p.hidden_acceptance_sha256,
          final_reviewer_id: p.final_reviewer_id,
        };
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
  for (const c of clockBlockers) blockers.push(c);

  const budgetBlockers = [];
  if (policy) {
    if (roundsPrepared > policy.max_rounds) {
      budgetBlockers.push({ code: 'budget_exhausted', budget: 'rounds', detail: `${roundsPrepared}/${policy.max_rounds}` });
    }
    if (actionsSeen.size > policy.max_actions) {
      budgetBlockers.push({ code: 'budget_exhausted', budget: 'actions', detail: `${actionsSeen.size}/${policy.max_actions}` });
    }
    if (tokensCharged > policy.max_tokens - policy.audit_reserve_tokens) {
      budgetBlockers.push({ code: 'budget_exhausted', budget: 'tokens', detail: `${tokensCharged}/${policy.max_tokens}` });
    }
    for (const [slice, count] of retryCounts) {
      if (count > policy.max_retries_per_slice) {
        budgetBlockers.push({ code: 'budget_exhausted', budget: 'retries', slice, detail: `${count}/${policy.max_retries_per_slice}` });
      }
    }
  }
  blockers.push(...budgetBlockers);

  let state = 'ACTIVE';
  if (stopped || unknownActions.length > 0 || clockBlockers.length > 0 || budgetBlockers.length > 0) state = 'HONEST_PARTIAL';
  else if (pendingAction) state = 'ACTION_PENDING';
  else if (policy && phaseCandidate) state = 'PHASE_CANDIDATE';
  else if (policy && currentRound && currentRound.state === 'prepared') state = 'ROUND_PREPARED';
  else if (policy && currentRound && currentRound.state === 'authorized') state = 'ROUND_AUTHORIZED';
  else if (policy && lastClosedRound && lastClosedRound.state === 'closed_candidate') state = 'ROUND_CANDIDATE';

  const legal = deriveLegalNextAction({ goal, stopped, unknownActions, pendingAction, candidates, verifiedIds, phaseCandidate });

  // Phase-2 budget derivation (frozen policy; native usage only).
  const budgets = policy ? {
    rounds: { used: roundsPrepared, max: policy.max_rounds },
    retries: {
      used: [...retryCounts.values()].reduce((sum, count) => sum + count, 0),
      max_per_slice: policy.max_retries_per_slice,
      by_slice: Object.fromEntries(retryCounts),
    },
    actions: { used: actionsSeen.size, max: policy.max_actions },
    tokens: {
      charged: tokensCharged, max: policy.max_tokens, audit_reserve: policy.audit_reserve_tokens,
      assertion: assertionTokens, execution: executionTokens,
    },
    wall_time: {
      max_seconds: policy.max_wall_seconds,
      deadline: typeof goal.created_at === 'string' && Number.isFinite(Date.parse(goal.created_at))
        ? new Date(Date.parse(goal.created_at) + policy.max_wall_seconds * 1000).toISOString() : null,
    },
    verified_since_alignment: { count: verifiedSinceAlignment, max: policy.align_every_verified_slices },
  } : null;

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
    phase2: policy ? {
      enabled: true,
      policy,
      quality_policy: goal.quality_policy || null,
      rounds_prepared: roundsPrepared,
      current_round: currentRound,
      last_closed_round: lastClosedRound,
      verified_since_alignment: verifiedSinceAlignment,
      alignment_watermark: alignmentWatermark,
      phase_candidate: phaseCandidate,
      tokens_charged: tokensCharged,
      assertion_tokens: assertionTokens,
      execution_tokens: executionTokens,
      retry_counts: Object.fromEntries(retryCounts),
      action_records: actionRecords,
      verified_effect_fingerprints: [...verifiedEffectFingerprints],
      budgets,
      minted_nonces: mintedNonces.filter((n) => !forbiddenRetryNonces.has(n)),
    } : null,
    phase_candidate: phaseCandidate,
  };
}

function deriveLegalNextAction({ goal, stopped, unknownActions, pendingAction, candidates, verifiedIds, phaseCandidate }) {
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
  if (phaseCandidate) {
    return {
      action: 'No further event is legal in this run. Submit the PHASE_CANDIDATE to the existing Gate and obtain human acceptance; do not invent work or append another event.',
      why: 'phase-candidate is a terminal run-level candidate, not permission for more execution',
      owner: 'conductor+human',
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
    ...(state.phase2 ? {
      phase2: {
        state: state.state,
        current_round: state.phase2.current_round,
        last_closed_round: state.phase2.last_closed_round,
        alignment_watermark: state.phase2.alignment_watermark,
        phase_candidate: state.phase2.phase_candidate,
        budgets: state.phase2.budgets,
        action_records: state.phase2.action_records,
        verified_effect_fingerprints: state.phase2.verified_effect_fingerprints,
      },
    } : {}),
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
  if (state.phase2) {
    L.push(`PHASE2: ${state.phase2.phase_candidate ? 'PHASE_CANDIDATE' : state.state}`);
    L.push(`BUDGETS: ${JSON.stringify(state.phase2.budgets)}`);
  }
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

  // Phase-2 host artifacts are authority-level pointers too. Rechecking their
  // hashes on every load prevents a valid close from becoming an untraceable
  // summary after its native carriers are replaced or deleted.
  if (goal.execution_policy) {
    const deadline = Date.parse(goal.created_at) + goal.execution_policy.max_wall_seconds * 1000;
    if (Number.isFinite(deadline) && Date.now() > deadline
        && !state.blockers.some((blocker) => blocker.code === 'budget_exhausted' && blocker.budget === 'wall_time')) {
      state.blockers.push({ code: 'budget_exhausted', budget: 'wall_time', detail: `deadline ${new Date(deadline).toISOString()}` });
      state.state = 'HONEST_PARTIAL';
    }
    const checkHostArtifact = (event, pathField, hashField, label) => {
      const artifactPath = event.payload[pathField];
      const expected = event.payload[hashField];
      if (typeof artifactPath !== 'string' || !artifactPath || !isSha256(expected)) {
        bindingBlockers.push({ code: 'round_evidence_binding_missing', detail: `${label} at seq ${event.seq}` });
        return;
      }
      const abs = path.resolve(artifactPath);
      if (!fs.existsSync(abs) || !fs.lstatSync(abs).isFile()) {
        bindingBlockers.push({ code: 'round_evidence_missing', detail: `${label}: ${artifactPath}` });
        return;
      }
      if (sha256File(abs) !== expected) {
        bindingBlockers.push({ code: 'round_evidence_hash_mismatch', detail: `${label}: ${artifactPath}` });
      }
    };
    for (const event of events) {
      if (event.type === 'reentry_verified') {
        checkHostArtifact(event, 'assertion_path', 'assertion_sha256', 'assertion');
        checkHostArtifact(event, 'review_path', 'review_sha256', 'review');
        checkHostArtifact(event, 'turn_record_path', 'turn_record_sha256', 'assertion turn');
      } else if (event.type === 'round_closed') {
        checkHostArtifact(event, 'report_path', 'report_sha256', 'round report');
        checkHostArtifact(event, 'usage_path', 'usage_sha256', 'round usage');
        checkHostArtifact(event, 'turn_record_path', 'turn_record_sha256', 'execution turn');
      }
    }
    for (const event of events) {
      if (event.type !== 'round_prepared') continue;
      for (const evidence of event.payload.necessary_evidence || []) {
        try {
          validateEvidenceReference(evidence, repoRoot, 'necessary_evidence', { requirePass: false });
        } catch (err) {
          bindingBlockers.push({
            code: 'necessary_evidence_binding_failed',
            detail: `${evidence && evidence.path}: ${err.reason || String(err.message)}`,
          });
        }
      }
    }
    for (const action of state.phase2.action_records || []) {
      for (const [pathField, hashField, label] of [
        ['args_path', 'args_sha256', 'action args'],
        ['effect_manifest_path', 'effect_manifest_sha256', 'effect manifest'],
      ]) {
        try {
          validateEvidenceReference({ path: action[pathField], sha256: action[hashField] }, repoRoot, label, { requirePass: false });
        } catch (err) {
          bindingBlockers.push({
            code: 'action_evidence_binding_failed',
            detail: `${label} for ${action.action_id}: ${err.reason || String(err.message)}`,
          });
        }
      }
    }
    const alignment = state.phase2.alignment_watermark;
    if (alignment) {
      const abs = alignment.receipt_path ? anchorAtRepoSafe(alignment.receipt_path, repoRoot) : null;
      if (!abs || !fs.existsSync(abs) || !fs.lstatSync(abs).isFile()) {
        bindingBlockers.push({ code: 'alignment_evidence_missing', detail: alignment.receipt_path });
      } else if (sha256File(abs) !== alignment.receipt_sha256) {
        bindingBlockers.push({ code: 'alignment_evidence_hash_mismatch', detail: alignment.receipt_path });
      } else {
        try {
          const alignmentReceipt = readJsonArtifact(abs, 'alignment-receipt');
          validateReviewerEvidence(alignmentReceipt, {
            repoRoot, label: 'reviewer',
            executorIds: state.verified.map((v) => v.executor_id).filter(Boolean),
          });
        } catch (err) {
          bindingBlockers.push({ code: 'alignment_evidence_invalid', detail: err.reason || String(err.message) });
        }
      }
    }
    if (state.phase2.phase_candidate) {
      const candidate = state.phase2.phase_candidate;
      const candidateAbs = candidate.receipt_path ? anchorAtRepoSafe(candidate.receipt_path, repoRoot) : null;
      if (!candidateAbs || !fs.existsSync(candidateAbs) || !fs.lstatSync(candidateAbs).isFile()) {
        bindingBlockers.push({ code: 'phase_candidate_evidence_missing', detail: candidate.receipt_path });
      } else if (sha256File(candidateAbs) !== candidate.receipt_sha256) {
        bindingBlockers.push({ code: 'phase_candidate_evidence_hash_mismatch', detail: candidate.receipt_path });
      } else {
        try {
          const candidateReceipt = readJsonArtifact(candidateAbs, 'phase-candidate-receipt');
          validateEvidenceReference(candidateReceipt.hidden_acceptance, repoRoot, 'hidden_acceptance', { requirePass: true });
          validateReviewerEvidence(candidateReceipt, {
            repoRoot, label: 'final_reviewer',
            executorIds: state.verified.map((v) => v.executor_id).filter(Boolean),
          });
        } catch (err) {
          bindingBlockers.push({ code: 'phase_candidate_evidence_invalid', detail: err.reason || String(err.message) });
        }
      }
      const hiddenAbs = candidate.hidden_acceptance_path
        ? anchorAtRepoSafe(candidate.hidden_acceptance_path, repoRoot) : null;
      if (!hiddenAbs || !fs.existsSync(hiddenAbs) || !fs.lstatSync(hiddenAbs).isFile()) {
        bindingBlockers.push({ code: 'phase_candidate_hidden_acceptance_missing', detail: candidate.hidden_acceptance_path });
      } else if (sha256File(hiddenAbs) !== candidate.hidden_acceptance_sha256) {
        bindingBlockers.push({ code: 'phase_candidate_hidden_acceptance_hash_mismatch', detail: candidate.hidden_acceptance_path });
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
  // Phase-2 optional policy block: frozen at init; validated before any write
  // so a rejected init leaves nothing behind (same transactional guarantee as
  // the capsule-budget check below).
  validateExecutionPolicy(spec);
  if (spec.execution_policy) {
    goal.execution_policy = spec.execution_policy;
    if (spec.quality_policy) {
      goal.quality_policy = spec.quality_policy;
      for (const f of ['phase_candidate_requires_hidden_acceptance', 'phase_candidate_requires_alignment']) {
        if (typeof goal.quality_policy[f] !== 'boolean') {
          throw new ContractError('quality_policy_field_invalid', { field: f });
        }
      }
      for (const f of ['wrong_or_unauthorized_next_action_max', 'repeated_verified_action_max']) {
        if (goal.quality_policy[f] !== 0) {
          throw new ContractError('quality_policy_zero_required', { field: f });
        }
      }
      // Degraded assertion-shell tolerance is an explicit, hash-bound approval —
      // never a silent default. The binding is frozen at init.
      if (goal.quality_policy.degraded_assertion_shell_reads !== undefined) {
        if (typeof goal.quality_policy.degraded_assertion_shell_reads !== 'boolean') {
          throw new ContractError('quality_policy_field_invalid', { field: 'degraded_assertion_shell_reads' });
        }
        if (goal.quality_policy.degraded_assertion_shell_reads === true) {
          if (!isSha256(goal.quality_policy.degraded_approval_sha256)) {
            throw new ContractError('quality_policy_field_invalid', { field: 'degraded_approval_sha256' });
          }
        }
      }
    }
  }

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
  if (r.goal.execution_policy) {
    throw new ContractError('legacy_checkpoint_forbidden', {
      note: 'policy mode: round-close is the only candidate path',
    });
  }
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
  if (r.state.phase2 && r.state.phase2.phase_candidate) {
    throw new ContractError('event_after_phase_candidate', { command: 'verify' });
  }
  refuseIfHonestPartial(r.state, 'verify');
  if (r.state.pending_action) {
    throw new ContractError('pending_action_blocks_verify', { action_id: r.state.pending_action.action_id });
  }
  const slice = need(flags, 'slice');
  const receiptInput = need(flags, 'receipt');
  const v = validateVerificationReceipt(receiptInput, {
    goal: r.goal, state: r.state, identity: r.identity, repoRoot: r.repoRoot, slice,
  });
  if (r.goal.execution_policy) {
    const closed = r.state.phase2.last_closed_round;
    if (!closed || closed.state !== 'closed_candidate' || closed.slice_id !== slice) {
      throw new ContractError('verify_requires_closed_candidate', { slice });
    }
    if (v.receipt.round_id !== closed.id
        || v.receipt.report_sha256 !== closed.report_sha256
        || v.receipt.usage_sha256 !== closed.usage_sha256
        || v.receipt.turn_record_sha256 !== closed.turn_record_sha256) {
      throw new ContractError('verification_round_binding_mismatch', { slice, round_id: closed.id });
    }
    if (!Array.isArray(v.receipt.maps_to_success)
        || JSON.stringify([...v.receipt.maps_to_success].sort())
          !== JSON.stringify([...(closed.maps_to_success || [])].sort())) {
      throw new ContractError('verification_success_mapping_mismatch', {
        slice, declared: v.receipt.maps_to_success, expected: closed.maps_to_success,
      });
    }
  }
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
    ...(r.goal.execution_policy ? {
      maps_to_success: [...r.state.phase2.last_closed_round.maps_to_success],
      effect_fingerprints: [...(r.state.phase2.last_closed_round.effect_fingerprints || [])],
    } : {}),
  }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  const { packet, ctx } = writeDerived(r.runDir, r.repoRoot, after.goal, after.state, after.identity, out);
  out(renderStatus(after.goal, after.state, ctx));
  return finish('verify', r.runDir, after.state, packet);
}

function cmdActionStart(flags, cwd, out) {
  const r = withRun(flags, cwd);
  const actionId = need(flags, 'action');
  if (r.state.phase2 && r.state.phase2.phase_candidate) {
    throw new ContractError('event_after_phase_candidate', { command: 'action-start' });
  }
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

  // Phase-2 policy bindings (§5.1): when the run carries an execution_policy,
  // an action binds to the current authorized round and mints a unique nonce.
  let actionNonce = null;
  let argsRef = null;
  let effectRef = null;
  let effectPaths = [];
  if (r.goal.execution_policy) {
    for (const f of ['round', 'outcome-id', 'tool', 'args-json', 'effect-manifest']) {
      need(flags, f);
    }
    if (!r.state.phase2 || !r.state.phase2.current_round
      || r.state.phase2.current_round.state !== 'authorized') {
      throw new ContractError('action_requires_authorized_round', { action_id: actionId });
    }
    if (flags.round !== r.state.phase2.current_round.id) {
      throw new ContractError('round_mismatch', { declared: flags.round, current: r.state.phase2.current_round.id });
    }
    assertWallClock(r.goal);
    assertBudgetRemaining(r.state, 'actions');
    if (!isSha256(preSha) || !isSha256(postSha)) throw new ContractError('action_hash_invalid', { action_id: actionId });
    const targetChecked = validateRepoRelativePath(targetInput, r.repoRoot, '--target');
    const targetRel = targetChecked.rel;
    const current = r.state.phase2.current_round;
    if (!pathAllowedByContract(targetRel, current.allowed_paths)) {
      throw new ContractError('action_target_outside_contract', { target: targetRel, allowed: current.allowed_paths });
    }
    const argsInput = need(flags, 'args-json');
    const effectInput = need(flags, 'effect-manifest');
    const argsChecked = validateRepoRelativePath(argsInput, r.repoRoot, 'action.args_path');
    const effectChecked = validateRepoRelativePath(effectInput, r.repoRoot, 'action.effect_manifest_path');
    argsRef = { rel: argsChecked.rel, ...readArtifactReference(argsChecked.abs, 'action-args') };
    effectRef = { rel: effectChecked.rel, ...readArtifactReference(effectChecked.abs, 'effect-manifest') };
    if (!isPlainObject(effectRef.doc) || !Array.isArray(effectRef.doc.affected) || effectRef.doc.affected.length === 0) {
      throw new ContractError('effect_manifest_invalid', {});
    }
    effectPaths = effectRef.doc.affected.map((item) => validateRepoRelativePath(item, r.repoRoot, 'effect-manifest.affected').rel);
    if (new Set(effectPaths).size !== effectPaths.length) throw new ContractError('effect_paths_duplicate', {});
    if (!effectPaths.includes(targetRel)) throw new ContractError('effect_target_missing', { target: targetRel });
    if (effectPaths.some((item) => !pathAllowedByContract(item, current.allowed_paths))) {
      throw new ContractError('action_effect_outside_contract', { paths: effectPaths, allowed: current.allowed_paths });
    }
    if (!Array.isArray(current.tool_allowlist) || !current.tool_allowlist.includes(flags.tool)) {
      throw new ContractError('tool_not_allowed', { tool: flags.tool });
    }
    actionNonce = crypto.randomBytes(8).toString('hex');
  }

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
      ...(actionNonce ? {
      round: flags.round,
      outcome_id: flags['outcome-id'],
      tool_class: flags.tool,
      args_path: argsRef.rel,
      args_sha256: argsRef.sha256,
      args_canonical_sha256: sha256String(canonicalJson(argsRef.doc)),
      effect_manifest_path: effectRef.rel,
      effect_manifest_sha256: effectRef.sha256,
      effect_paths: [...effectPaths],
      action_nonce: actionNonce,
    } : {}),
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
    // §4.4-class artifact: reconciliation evidence may be a runner-owned
    // host-side file; it is hash-bound into the event either way.
    const evidenceAbs = path.resolve(need(flags, 'evidence'));
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
      const evidenceAbs = path.resolve(need(flags, 'evidence'));
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
  if (r.state.phase2 && r.state.phase2.phase_candidate) {
    throw new ContractError('event_after_phase_candidate', { command: 'stop' });
  }
  const reason = need(flags, 'reason');
  if (r.state.stopped) throw new ContractError('already_stopped', { reason: r.state.stopped.reason });
  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'stopped', { reason }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  const { packet, ctx } = writeDerived(r.runDir, r.repoRoot, after.goal, after.state, after.identity, out);
  out(renderStatus(after.goal, after.state, ctx));
  return finish('stop', r.runDir, after.state, packet);
}

// ─────────────────────────── result shaping ───────────────────────────

// ──────────────── Phase-2 bounded-round commands ────────────────

const FORBIDDEN_ALLOWED_PATH_PREFIXES = [
  '.tad/scripts/', '.claude/', '.tad/hooks/', '.agents/',
  '.tad/active/handoffs/', '.tad/archive/handoffs/',
];
const DENIED_EXECUTOR_TOOLS = ['Shell', 'Bash', 'Agent', 'Task'];

function pathAllowedByContract(target, allowedPaths) {
  return allowedPaths.some((allowed) => allowed.endsWith('/')
    ? target === allowed.slice(0, -1) || target.startsWith(allowed)
    : target === allowed);
}

function validateDeterministicChecks(checks, label = 'deterministic_checks') {
  if (!Array.isArray(checks)) throw new ContractError('journal_field_missing', { field: label });
  const ids = new Set();
  for (const check of checks) {
    if (!isPlainObject(check) || typeof check.id !== 'string' || !check.id.trim()
        || !Number.isInteger(check.expected_exit)
        || typeof check.expected_result !== 'string' || !check.expected_result.trim()) {
      throw new ContractError('deterministic_check_malformed', { field: label, check });
    }
    if (ids.has(check.id)) throw new ContractError('deterministic_check_duplicate', { id: check.id });
    ids.add(check.id);
  }
  return checks.map((check) => ({ ...check }));
}

function requirePolicyMode(goal) {
  if (!goal.execution_policy) {
    throw new ContractError('policy_mode_required', { note: 'goal.json has no execution_policy block' });
  }
}

function assertBudgetRemaining(state, kind) {
  const b = state.phase2.budgets[kind];
  if (b.used >= b.max) {
    throw new ContractError('budget_exhausted', { budget: kind, used: b.used, max: b.max });
  }
}

function assertWallClock(goal) {
  const policy = goal.execution_policy;
  if (!policy || typeof goal.created_at !== 'string') return;
  const start = Date.parse(goal.created_at);
  if (!Number.isFinite(start)) return;
  const deadline = start + policy.max_wall_seconds * 1000;
  if (Date.now() > deadline) {
    throw new ContractError('budget_exhausted', {
      budget: 'wall_time',
      deadline: new Date(deadline).toISOString(),
    });
  }
}

function readJsonArtifact(absPath, label) {
  let raw;
  try { raw = fs.readFileSync(absPath, 'utf8'); } catch {
    throw new UsageError('artifact_missing', { label, path: absPath });
  }
  try { return JSON.parse(raw); } catch {
    throw new ContractError('artifact_not_json', { label, path: absPath });
  }
}

function checkedUsageTotal(usage, label) {
  if (!isPlainObject(usage) || usage.native !== true) {
    throw new ContractError('usage_not_native', { label });
  }
  for (const field of ['input_tokens', 'output_tokens', 'total_tokens']) {
    if (!Number.isInteger(usage[field]) || usage[field] < 0) {
      throw new ContractError('usage_malformed', { label, field, value: usage[field] });
    }
  }
  if (usage.total_tokens !== usage.input_tokens + usage.output_tokens) {
    throw new ContractError('usage_total_mismatch', {
      label, declared: usage.total_tokens,
      expected: usage.input_tokens + usage.output_tokens,
    });
  }
  if (usage.cached_input_tokens !== undefined
      && (!Number.isInteger(usage.cached_input_tokens) || usage.cached_input_tokens < 0)) {
    throw new ContractError('usage_malformed', { label, field: 'cached_input_tokens' });
  }
  return usage.total_tokens;
}

function validateRawCarrier(carrier, label) {
  if (!isPlainObject(carrier) || typeof carrier.host_locator !== 'string'
      || !carrier.host_locator || !isSha256(carrier.sha256)) {
    throw new ContractError('native_carrier_malformed', { field: label });
  }
  const abs = path.resolve(carrier.host_locator);
  if (!fs.existsSync(abs) || !fs.lstatSync(abs).isFile()) {
    throw new ContractError('native_carrier_missing', { field: label, path: carrier.host_locator });
  }
  if (fs.statSync(abs).size === 0) {
    throw new ContractError('native_carrier_empty', { field: label, path: carrier.host_locator });
  }
  const actual = sha256File(abs);
  if (actual !== carrier.sha256) {
    throw new ContractError('native_carrier_hash_mismatch', {
      field: label, path: carrier.host_locator, declared: carrier.sha256, actual,
    });
  }
  return { abs, sha256: actual };
}

function nativeToolEventsFromCarrier(abs) {
  const events = [];
  for (const line of fs.readFileSync(abs, 'utf8').split('\n')) {
    const text = line.trim();
    if (!text.startsWith('{')) continue;
    try {
      const event = JSON.parse(text);
      if (event.item && ['command_execution', 'file_change', 'mcp_tool_call'].includes(event.item.type)) {
        events.push(event.item.type);
      }
    } catch {
      // Non-JSON diagnostic lines are retained in the raw carrier but do not
      // count as native tool events.
    }
  }
  return events;
}

function validateNativeEventBinding(doc, { assertion = false, qualityPolicy = null, degradedApprovalSha = null } = {}) {
  // Every runner-owned record MUST declare its native event inventory —
  // omitting the field must not skip the shell-read policy check.
  if (!Array.isArray(doc.native_event_kinds)) {
    throw new ContractError('native_event_inventory_missing', { label: 'native_event_kinds' });
  }
  const outputAbs = validateRawCarrier(doc.raw_native_output, 'native event output').abs;
  const traceAbs = validateRawCarrier(doc.raw_native_trace, 'native event trace').abs;
  const outputKinds = nativeToolEventsFromCarrier(outputAbs);
  const traceKinds = nativeToolEventsFromCarrier(traceAbs);
  if (doc.native_event_count !== outputKinds.length
      || JSON.stringify(doc.native_event_kinds) !== JSON.stringify(outputKinds)) {
    throw new ContractError('native_event_binding_mismatch', { declared: doc.native_event_kinds, actual: outputKinds });
  }
  if (JSON.stringify(outputKinds) !== JSON.stringify(traceKinds)) {
    throw new ContractError('native_carrier_event_mismatch', { output: outputKinds, trace: traceKinds });
  }
  if (!assertion) return;
  // An assertion turn must be mutation-free; any file_change native event is a
  // hard violation regardless of any degradation flag.
  if (outputKinds.includes('file_change')) {
    throw new ContractError('assertion_native_mutation', { kinds: outputKinds });
  }
  const shellReads = outputKinds.filter((kind) => ['command_execution', 'mcp_tool_call'].includes(kind));
  if (shellReads.length === 0) return;
  // Read-only-shell events are only tolerated when the frozen goal explicitly
  // carries the degraded-approval binding; silence is never acceptance.
  const policyDegraded = qualityPolicy && qualityPolicy.degraded_assertion_shell_reads === true;
  const approvalSha = qualityPolicy ? qualityPolicy.degraded_approval_sha256 : null;
  if (!policyDegraded || !isSha256(approvalSha) || degradedApprovalSha !== approvalSha) {
    throw new ContractError('assertion_native_tool_policy_violation', { kinds: outputKinds });
  }
}

function validateRunnerBoundArtifact(doc, { round, packet, journalSeq, label, role = null, kind = null } = {}) {
  if (!isPlainObject(doc) || doc.written_by !== 'reference-runner') {
    throw new ContractError('turn_not_runner_owned', { label, written_by: doc && doc.written_by });
  }
  for (const field of ['runner_version', 'runner_sha256', 'parser_version', 'invocation_nonce']) {
    if (typeof doc[field] !== 'string' || !doc[field]) {
      throw new ContractError('native_provenance_missing', { field: `${label}.${field}` });
    }
  }
  if (!isSha256(doc.runner_sha256)) throw new ContractError('native_provenance_malformed', { label });
  if (role && doc.role !== role) throw new ContractError('turn_role_invalid', { label, role: doc.role, want: role });
  if (kind && doc.turn_kind !== kind) throw new ContractError('turn_role_invalid', { label, kind: doc.turn_kind, want: kind });
  if (typeof doc.session_id !== 'string' || !doc.session_id) {
    throw new ContractError('journal_field_missing', { field: `${label}.session_id` });
  }
  if (doc.round_id !== round) throw new ContractError('round_mismatch', { via: label, declared: doc.round_id, want: round });
  if (doc.packet_sha256 !== packet) throw new ContractError('packet_mismatch', { via: label });
  // An execution record is created immediately after action-start; close sees
  // the later action-reconciled event. Permit exactly that one-event delta,
  // while rejecting stale or swapped native records.
  if (doc.journal_seq !== journalSeq
      && !(kind === 'execution' && doc.journal_seq === journalSeq - 1)) {
    throw new ContractError('journal_sequence_mismatch', { via: label, declared: doc.journal_seq, want: journalSeq });
  }
  if (doc.exit_status !== 0) throw new ContractError('native_execution_failed', { label, exit_status: doc.exit_status });
  validateRawCarrier(doc.raw_native_output, `${label}.raw_native_output`);
  validateRawCarrier(doc.raw_native_trace, `${label}.raw_native_trace`);
  checkedUsageTotal(doc.usage, `${label}.usage`);
  return doc;
}

function validateNativeTurn(doc, { kind, round, packet, journalSeq, label, qualityPolicy = null }) {
  if (!isPlainObject(doc) || doc.format !== 'yolo-reference-turn-v1') {
    throw new ContractError('turn_format_invalid', { label, format: doc && doc.format });
  }
  validateRunnerBoundArtifact(doc, { round, packet, journalSeq, label, role: 'executor', kind });
  validateNativeEventBinding(doc, {
    assertion: kind === 'assertion',
    qualityPolicy,
    degradedApprovalSha: doc.degraded_approval_sha256 ?? null,
  });
  if (!Array.isArray(doc.tool_calls) || doc.tool_calls.length === 0) {
    throw new ContractError('native_tool_trace_missing', { label });
  }
  if (!Array.isArray(doc.worktree_observation)) {
    throw new ContractError('native_worktree_observation_missing', { label });
  }
  return doc;
}

function validateAssertionToolPolicy(doc) {
  const policy = doc.tool_policy;
  if (!isPlainObject(policy) || !Array.isArray(policy.allowed) || !Array.isArray(policy.denied)) {
    throw new ContractError('assertion_tool_policy_missing', {});
  }
  if (policy.sandbox !== 'read-only') {
    throw new ContractError('assertion_sandbox_not_read_only', { sandbox: policy.sandbox });
  }
  if (policy.allowed.length === 0 || policy.allowed.some((tool) => !String(tool).startsWith('Read'))) {
    throw new ContractError('assertion_tool_policy_invalid', { allowed: policy.allowed });
  }
  for (const denied of ['Write', 'Edit', 'Shell', 'Bash', 'Agent', 'Task']) {
    if (!policy.denied.includes(denied)) throw new ContractError('assertion_tool_policy_invalid', { missing_denied: denied });
  }
}

function validateToolTrace(doc, { assertion = false } = {}) {
  const observed = [];
  const callIds = new Set();
  for (const call of doc.tool_calls) {
    if (!isPlainObject(call) || typeof call.native_call_id !== 'string' || !call.native_call_id
        || typeof call.tool !== 'string' || !call.tool
        || !isSha256(call.args_sha256) || call.decision !== 'allowed') {
      throw new ContractError(call && call.decision !== 'allowed' ? 'denied_tool_attempt' : 'native_tool_trace_malformed', {
        native_call_id: call && call.native_call_id,
      });
    }
    if (callIds.has(call.native_call_id)) throw new ContractError('duplicate_native_call', { native_call_id: call.native_call_id });
    callIds.add(call.native_call_id);
    for (const field of ['observed_changed', 'observed_deleted', 'observed_untracked']) {
      if (!Array.isArray(call[field])) throw new ContractError('native_tool_trace_malformed', { field, native_call_id: call.native_call_id });
    }
    if (assertion && mutationPaths(call).length > 0) {
      throw new ContractError('assertion_turn_side_effect', { native_call_id: call.native_call_id });
    }
    observed.push(...mutationPaths(call));
  }
  const tracePaths = sortedUnique(observed);
  const worktreePaths = sortedUnique(doc.worktree_observation.map(normalizeObservedPath).filter(Boolean));
  if (JSON.stringify(tracePaths) !== JSON.stringify(worktreePaths)) {
    throw new ContractError('native_observation_mismatch', { trace: tracePaths, worktree: worktreePaths });
  }
  return tracePaths;
}

function readArtifactReference(input, label) {
  const abs = path.resolve(input);
  const doc = readJsonArtifact(abs, label);
  return { abs, doc, sha256: sha256File(abs) };
}

function assertPassCarrier(abs, label) {
  const text = fs.readFileSync(abs, 'utf8');
  let value = null;
  try { value = JSON.parse(text); } catch { /* plain evidence is valid when its ref says PASS */ }
  if (isPlainObject(value)) {
    const failed = value.verdict === 'FAIL' || value.result === 'FAIL' || value.passed === false
      || value.hidden_acceptance_passed === false
      || (Array.isArray(value.results) && value.results.some((item) => item && item.passed === false))
      || (Array.isArray(value.hidden_acceptance_results) && value.hidden_acceptance_results.some((item) => item && item.passed === false));
    if (failed) throw new ContractError('evidence_reference_not_pass', { label });
  } else if (/\bverdict\s*[:=]\s*['"]?FAIL\b/i.test(text)) {
    throw new ContractError('evidence_reference_not_pass', { label });
  }
}

function validateEvidenceReference(ref, repoRoot, label, { requirePass = true } = {}) {
  if (!isPlainObject(ref) || typeof ref.path !== 'string' || !ref.path || !isSha256(ref.sha256)) {
    throw new ContractError('evidence_reference_malformed', { label });
  }
  const abs = resolveInRepo(ref.path, repoRoot, `${label}.path`);
  if (!fs.existsSync(abs) || !fs.lstatSync(abs).isFile()) {
    throw new ContractError('evidence_reference_missing', { label, path: ref.path });
  }
  if (fs.statSync(abs).size === 0) throw new ContractError('evidence_reference_empty', { label, path: ref.path });
  const actual = sha256File(abs);
  if (actual !== ref.sha256) throw new ContractError('evidence_reference_hash_mismatch', { label, path: ref.path });
  if (requirePass && ref.verdict !== 'PASS' && ref.passed !== true) {
    throw new ContractError('evidence_reference_not_pass', { label, path: ref.path });
  }
  if (requirePass) assertPassCarrier(abs, label);
  return { abs, sha256: actual };
}

function cmdRoundPrepare(flags, cwd, out) {
  const r = withRun(flags, cwd);
  requirePolicyMode(r.goal);
  if (r.state.phase2.phase_candidate) throw new ContractError('event_after_phase_candidate', { command: 'round-prepare' });
  refuseIfHonestPartial(r.state, 'round-prepare');
  if (r.state.pending_action) {
    throw new ContractError('pending_action_blocks_prepare', { action_id: r.state.pending_action.action_id });
  }
  if (r.state.phase2.current_round) {
    throw new ContractError('prepare_with_open_round', { open: r.state.phase2.current_round.id });
  }
  const policy = r.goal.execution_policy;
  if (r.state.phase2.verified_since_alignment >= policy.align_every_verified_slices) {
    throw new ContractError('alignment_required_before_prepare', {
      verified_since_alignment: r.state.phase2.verified_since_alignment,
      align_every_verified_slices: policy.align_every_verified_slices,
      remedy: 'run align --receipt <alignment-receipt.json>',
    });
  }
  assertBudgetRemaining(r.state, 'rounds');
  assertWallClock(r.goal);

  // Slice contract validation (§4.2).
  const contractRel = need(flags, 'contract');
  const contractAbs = resolveInRepo(contractRel, r.repoRoot, '--contract');
  if (!fs.existsSync(contractAbs) || !fs.lstatSync(contractAbs).isFile()) {
    throw new UsageError('contract_missing', { path: contractRel });
  }
  const c = readJsonArtifact(contractAbs, 'slice-contract');
  if (c.format !== 'yolo-slice-contract-v1') throw new ContractError('contract_format_invalid', { format: c.format });
  if (typeof c.slice_id !== 'string' || !c.slice_id) throw new ContractError('journal_field_missing', { field: 'slice_id' });
  if (!frozenSliceIds(r.goal).includes(c.slice_id)) throw new ContractError('slice_not_frozen', { slice: c.slice_id });
  if (typeof c.outcome !== 'string' || c.outcome.trim().length < 15
    || /^(edit|modify|change)\s+(the\s+)?file\b/i.test(c.outcome.trim())) {
    throw new ContractError('outcome_not_checkable', { outcome: c.outcome });
  }
  const successIds = successCriterionIds(r.goal);
  if (!Array.isArray(c.maps_to_success) || c.maps_to_success.length === 0
    || !c.maps_to_success.every((id) => successIds.includes(id))) {
    throw new ContractError('success_mapping_invalid', { maps_to_success: c.maps_to_success, frozen: successIds });
  }
  if (new Set(c.maps_to_success).size !== c.maps_to_success.length) {
    throw new ContractError('success_mapping_duplicate', { maps_to_success: c.maps_to_success });
  }
  if (!Array.isArray(c.necessary_evidence)) throw new ContractError('journal_field_missing', { field: 'necessary_evidence' });
  for (const e of c.necessary_evidence) {
    if (!isPlainObject(e) || typeof e.path !== 'string' || !isSha256(e.sha256)) {
      throw new ContractError('evidence_reference_malformed', { field: 'necessary_evidence' });
    }
    const eAbs = validateRepoRelativePath(e.path, r.repoRoot, 'necessary_evidence.path').abs;
    if (!fs.existsSync(eAbs) || !fs.lstatSync(eAbs).isFile() || sha256File(eAbs) !== e.sha256) {
      throw new ContractError('evidence_hash_mismatch', { path: e.path, declared: e.sha256 });
    }
  }
  if (!Array.isArray(c.allowed_paths) || c.allowed_paths.length === 0) {
    throw new ContractError('journal_field_missing', { field: 'allowed_paths' });
  }
  const normalizedAllowed = [];
  for (const ap of c.allowed_paths) {
    const checked = validateRepoRelativePath(ap, r.repoRoot, 'allowed_paths', { allowPrefix: true });
    const normalized = checked.rel;
    if (normalizedAllowed.includes(normalized)) {
      throw new ContractError('allowed_path_duplicate', { path: ap });
    }
    if (FORBIDDEN_ALLOWED_PATH_PREFIXES.some((pre) => normalized.startsWith(pre))
        || /hidden[-_ ]?acceptance/i.test(normalized)) {
      throw new ContractError('allowed_path_forbidden', { path: ap });
    }
    normalizedAllowed.push(normalized);
  }
  if (!isSha256(c.forbidden_scope_sha256)) {
    throw new ContractError('journal_field_missing', { field: 'forbidden_scope_sha256' });
  }
  if (c.forbidden_scope_sha256 !== forbiddenScopeHash(r.goal)) {
    throw new ContractError('forbidden_scope_hash_mismatch', {
      declared: c.forbidden_scope_sha256, frozen: forbiddenScopeHash(r.goal),
    });
  }
  if (!Array.isArray(c.tool_allowlist) || c.tool_allowlist.length === 0) {
    throw new ContractError('journal_field_missing', { field: 'tool_allowlist' });
  }
  if (new Set(c.tool_allowlist).size !== c.tool_allowlist.length
      || c.tool_allowlist.some((tool) => typeof tool !== 'string' || !tool)) {
    throw new ContractError('tool_allowlist_invalid', { tool_allowlist: c.tool_allowlist });
  }
  for (const t of c.tool_allowlist) {
    if (DENIED_EXECUTOR_TOOLS.includes(t)) throw new ContractError('executor_shell_denied', { tool: t });
  }
  if (!Array.isArray(c.deterministic_checks)) throw new ContractError('journal_field_missing', { field: 'deterministic_checks' });
  if (c.deterministic_checks.length === 0 && c.semantic_review_required !== true) {
    throw new ContractError('no_check_and_no_semantic_review', { slice_id: c.slice_id });
  }
  if (c.semantic_review_required === true && !c.semantic_review_reason) {
    throw new ContractError('semantic_review_reason_missing', { slice_id: c.slice_id });
  }
  if (typeof c.semantic_review_required !== 'boolean') {
    throw new ContractError('semantic_review_required_invalid', { slice_id: c.slice_id });
  }
  const deterministicChecks = validateDeterministicChecks(c.deterministic_checks);
  // Replanning may supersede only an unverified failed/blocked slice.
  if (c.supersedes_unverified_slice !== null && c.supersedes_unverified_slice !== undefined) {
    const target = c.supersedes_unverified_slice;
    if (r.state.verified_slices.includes(target)) throw new ContractError('supersede_verified_forbidden', { slice: target });
    const lc = r.state.phase2.last_closed_round;
    if (!lc || lc.slice_id !== target || !['closed_failed', 'closed_blocked'].includes(lc.state)) {
      throw new ContractError('supersede_target_not_failed', { slice: target, last_closed: lc || null });
    }
    if (!c.replan_reason) throw new ContractError('replan_reason_missing', { slice: target });
  } else if (c.replan_reason) {
    throw new ContractError('replan_without_supersede', {});
  }
  if (r.state.phase2.last_closed_round && r.state.phase2.last_closed_round.state === 'closed_candidate') {
    throw new ContractError('candidate_requires_verify', { round_id: r.state.phase2.last_closed_round.id });
  }
  const retriesUsed = r.state.phase2.retry_counts[c.slice_id] || 0;
  if (retriesUsed >= policy.max_retries_per_slice) {
    throw new ContractError('budget_exhausted', {
      budget: 'retries', slice: c.slice_id, used: retriesUsed, max: policy.max_retries_per_slice,
    });
  }

  const contractSha = sha256File(contractAbs);
  const roundId = `R-${String(r.state.phase2.rounds_prepared + 1).padStart(2, '0')}`;

  // Derived execution packet (§4.3) — rebuildable, bounded, anchors never trimmed.
  const sections = [];
  const add = (title, body) => sections.push({ title, text: `## ${title}\n\n${body}\n` });
  add('GOAL', `${r.goal.goal}\n\nGoal id: \`${r.goal.goal_id}\``);
  add('SUCCESS CRITERIA', r.goal.success.map((s, i) => `- \`SC-${i + 1}\`: ${typeof s === 'string' ? s : s.statement}`).join('\n'));
  add('NON-GOALS AND FORBIDDEN SCOPE', `${r.goal.non_goals.map((s) => `- ${s}`).join('\n')}\n\nForbidden scope:\n${r.goal.forbidden_scope.map((s) => `- ${s}`).join('\n')}`);
  add('HANDOFF REVISION', `\`${r.goal.handoff_path}\` @ \`${r.goal.handoff_revision.slice(0, 12)}\`; base \`${r.goal.base_commit.slice(0, 10)}\`.`);
  add('VERIFIED STATE', r.state.verified.length
    ? r.state.verified.map((v) => `- \`${v.slice}\` verified (DO NOT redo)`).join('\n')
    : '- none yet');
  add('CURRENT SLICE CONTRACT', [
    `- slice: \`${c.slice_id}\``,
    `- outcome: ${c.outcome}`,
    `- maps to: ${c.maps_to_success.join(', ')}`,
    `- allowed paths: ${c.allowed_paths.join(', ')}`,
    `- tools: ${c.tool_allowlist.join(', ')}`,
    `- deterministic checks: ${c.deterministic_checks.map((k) => k.id).join(', ') || '(none)'}`,
    `- stop conditions: ${(c.stop_conditions || []).join('; ') || '(none)'}`,
    c.replan_reason ? `- REPLAN of \`${c.supersedes_unverified_slice}\`: ${c.replan_reason}` : '',
  ].filter(Boolean).join('\n'));
  add('VERIFICATION MODEL', [
    '- A checkpoint is only a CANDIDATE: it records intent, it does not verify the work.',
    '- `verified` advances ONLY when a Conductor (an identity distinct from the executor, `written_by_id` != `executor_id`) writes a bound verification receipt after the existing Gate and an independent review have both PASSed.',
    '- Completion prose, an ordinary file, a self-authored receipt, or any executor assertion NEVER advances `verified`.',
  ].join('\n'));
  add('PROHIBITIONS', [
    '- Execute ONLY this slice. Starting other slices, redoing verified work, or declaring completion is FORBIDDEN.',
    '- Uncommitted worktree changes are observation only and MUST NOT be treated as progress or as done.',
    '- Shell/Bash and Agent spawning are denied in strict Phase 2; predeclared deterministic checks run Conductor-side only.',
    '- Hidden acceptance is outside your namespace; do not look for it.',
  ].join('\n'));
  add('BUDGETS', [
    `- round ${roundId} of max ${policy.max_rounds}`,
    `- executor token reservation for this round: ${policy.max_executor_tokens_per_round}`,
    `- total tokens charged so far: ${r.state.phase2.tokens_charged} / ${policy.max_tokens} (audit reserve ${policy.audit_reserve_tokens})`,
    `- actions so far: ${r.state.phase2.budgets.actions.used} / ${policy.max_actions}`,
  ].join('\n'));

  const header = `# Execution Packet — round ${roundId} (slice ${c.slice_id})\n\nDerived from goal.json + journal.jsonl. NO authority. If it disagrees with the ledger, the ledger wins.\n`;
  const text = header + '\n' + sections.map((s) => s.text).join('\n');
  const tokens = estimateTokens(text);
  if (tokens > policy.packet_token_budget) {
    throw new ContractError('packet_over_budget', {
      tokens,
      budget: policy.packet_token_budget,
      composition: sections.map((s) => ({ section: s.title, tokens: estimateTokens(s.text) })),
      note: 'never trim anchors to fit',
    });
  }
  const packetSha = sha256String(text);
  const packetDir = path.join(r.runDir, 'rounds', roundId);
  fs.mkdirSync(packetDir, { recursive: true });
  writeAtomic(path.join(packetDir, 'execution.md'), text);

  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'round_prepared', {
    round_id: roundId,
    slice_id: c.slice_id,
    contract_rel: contractRel,
    contract_sha256: contractSha,
    packet_rel: repoRel(r.repoRoot, path.join(r.runDir, 'rounds', roundId, 'execution.md')),
    packet_sha256: packetSha,
    maps_to_success: [...c.maps_to_success],
    allowed_paths: normalizedAllowed,
    tool_allowlist: [...c.tool_allowlist],
    deterministic_checks: deterministicChecks,
    necessary_evidence: c.necessary_evidence.map((entry) => ({ ...entry })),
    dirty_paths_at_prepare: Array.isArray(r.identity.dirty_paths) ? [...r.identity.dirty_paths] : [],
    worktree_manifest_at_prepare: readWorktreeManifest(r.repoRoot),
    replaces_slice: c.supersedes_unverified_slice ?? null,
    replan_reason: c.replan_reason ?? null,
  }, r.identity.head));
  fs.renameSync(path.join(packetDir, 'execution.md'), path.join(r.runDir, 'rounds', roundId, 'execution.md'));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  out(`EXECUTION PACKET: ${path.join(packetDir, 'execution.md')} (${tokens} est. tokens, budget ${policy.packet_token_budget})\n`);
  return finish('round-prepare', r.runDir, after.state, null);
}

function cmdRoundAuthorize(flags, cwd, out) {
  const r = withRun(flags, cwd);
  requirePolicyMode(r.goal);
  if (r.state.phase2.phase_candidate) throw new ContractError('event_after_phase_candidate', { command: 'round-authorize' });
  refuseIfHonestPartial(r.state, 'round-authorize');
  const cur = r.state.phase2.current_round;
  if (!cur || cur.state !== 'prepared') {
    throw new ContractError('authorize_requires_prepared_round', { current: cur || null });
  }
  assertWallClock(r.goal);
  const packetAbs = resolveInRepo(cur.packet_rel, r.repoRoot, 'execution_packet');
  if (!fs.existsSync(packetAbs) || sha256File(packetAbs) !== cur.packet_sha256) {
    throw new ContractError('packet_hash_mismatch', { round_id: cur.id });
  }
  const contractAbs = resolveInRepo(cur.contract_rel, r.repoRoot, 'slice_contract');
  if (!fs.existsSync(contractAbs) || sha256File(contractAbs) !== cur.contract_sha256) {
    throw new ContractError('contract_hash_mismatch', { round_id: cur.id });
  }
  for (const evidence of cur.necessary_evidence || []) {
    validateEvidenceReference(evidence, r.repoRoot, 'necessary_evidence', { requirePass: false });
  }
  // §4.4: assertion/review/turn-record are RUNNER-OWNED host-side artifacts;
  // they are hash-bound into the event but need not live inside the run repo.
  const readArt = (flag) => {
    const rel = need(flags, flag);
    const ref = readArtifactReference(rel, flag);
    return { rel, ...ref, sha: ref.sha256 };
  };
  const assertion = readArt('assertion');
  const review = readArt('review');
  const turn = readArt('turn-record');

  if (assertion.doc.format !== 'yolo-recovery-assertion-v1') {
    throw new ContractError('assertion_format_invalid', { format: assertion.doc.format });
  }
  if (assertion.doc.verdict !== 'PASS') throw new ContractError('assertion_verdict_not_pass', {});
  if (assertion.doc.hard_total !== 8 || assertion.doc.hard_correct !== 8) {
    throw new ContractError('assertion_hard_anchors_incomplete', { hard: `${assertion.doc.hard_correct}/${assertion.doc.hard_total}` });
  }
  if (typeof assertion.doc.soft_score !== 'number' || assertion.doc.soft_score < 0.90) {
    throw new ContractError('assertion_soft_below_floor', { soft_score: assertion.doc.soft_score });
  }
  if (typeof assertion.doc.author_id !== 'string' || !assertion.doc.author_id) {
    throw new ContractError('assertion_identity_missing', {});
  }
  validateRunnerBoundArtifact(assertion.doc, {
    round: cur.id, packet: cur.packet_sha256, journalSeq: r.state.events_count,
    label: 'assertion', role: 'executor', kind: 'assertion',
  });
  validateAssertionToolPolicy(assertion.doc);
  validateToolTrace(assertion.doc, { assertion: true });

  if (review.doc.format !== 'yolo-recovery-review-v1') {
    throw new ContractError('review_format_invalid', { format: review.doc.format });
  }
  if (review.doc.verdict !== 'PASS') throw new ContractError('review_verdict_not_pass', {});
  const execAuthor = assertion.doc.author_id;
  const revAuthor = review.doc.author_id || review.doc.reviewer_id;
  if (!revAuthor || revAuthor === execAuthor) throw new ContractError('self_review_forbidden', {});
  if (typeof review.doc.reviewer_id !== 'string' || !review.doc.reviewer_id) {
    throw new ContractError('reviewer_identity_missing', {});
  }
  validateRunnerBoundArtifact(review.doc, {
    round: cur.id, packet: cur.packet_sha256, journalSeq: r.state.events_count,
    label: 'review', role: 'reviewer', kind: 'review',
  });
  if (review.doc.session_id === assertion.doc.session_id || review.doc.reviewer_id === execAuthor) {
    throw new ContractError('self_review_forbidden', {});
  }
  if (review.doc.assertion_sha256 !== assertion.sha) {
    throw new ContractError('review_assertion_mismatch', { declared: review.doc.assertion_sha256 });
  }
  if (review.doc.oracle_sha256 !== r.goal.oracle_sha256) {
    throw new ContractError('review_oracle_mismatch', { declared: review.doc.oracle_sha256 });
  }

  // Native assertion turn (runner-owned provenance).
  const t = turn.doc;
  validateNativeTurn(t, {
    kind: 'assertion', round: cur.id, packet: cur.packet_sha256,
    journalSeq: r.state.events_count, label: 'turn-record',
    qualityPolicy: r.goal.quality_policy || null,
  });
  validateAssertionToolPolicy(t);
  validateToolTrace(t, { assertion: true });
  const assertionDelta = manifestChangedPaths(
    cur.worktree_manifest_at_prepare, readWorktreeManifest(r.repoRoot),
  );
  if (assertionDelta.length > 0) {
    throw new ContractError('assertion_turn_side_effect', { paths: assertionDelta });
  }
  if (assertion.doc.session_id !== t.session_id
      || assertion.doc.packet_sha256 !== t.packet_sha256
      || assertion.doc.round_id !== t.round_id) {
    throw new ContractError('assertion_turn_binding_mismatch', {});
  }
  if (canonicalJson(assertion.doc.tool_policy) !== canonicalJson(t.tool_policy)) {
    throw new ContractError('assertion_policy_metadata_mismatch', {});
  }
  if (assertion.doc.usage.total_tokens !== t.usage.total_tokens
      || assertion.doc.usage.input_tokens !== t.usage.input_tokens
      || assertion.doc.usage.output_tokens !== t.usage.output_tokens) {
    throw new ContractError('assertion_usage_mismatch', {});
  }

  // Token reservation keeping the audit reserve intact.
  const policy = r.goal.execution_policy;
  const assertionTotal = checkedUsageTotal(t.usage, 'assertion');
  const remainingTotal = policy.max_tokens - r.state.phase2.tokens_charged - assertionTotal;
  const reserve = policy.max_executor_tokens_per_round;
  if (remainingTotal - reserve < policy.audit_reserve_tokens) {
    throw new ContractError('audit_reserve_would_be_consumed', {
      remaining_total: remainingTotal, assertion: assertionTotal, audit_reserve: policy.audit_reserve_tokens,
    });
  }

  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'reentry_verified', {
    round_id: cur.id,
    session_id: t.session_id,
    reservation_tokens: reserve,
    assertion_path: assertion.abs,
    assertion_sha256: assertion.sha,
    review_path: review.abs,
    review_sha256: review.sha,
    turn_record_path: turn.abs,
    turn_record_sha256: turn.sha,
    assertion_author_id: assertion.doc.author_id,
    reviewer_id: review.doc.reviewer_id,
    assertion_usage: { ...t.usage, total_tokens: assertionTotal },
  }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  out(`ROUND ${cur.id} AUTHORIZED. Same session may execute; reservation ${reserve} tokens.\n`);
  return finish('round-authorize', r.runDir, after.state, null);
}

function usageEqual(a, b) {
  for (const field of ['input_tokens', 'output_tokens', 'total_tokens', 'native']) {
    if (a[field] !== b[field]) return false;
  }
  if ((a.cached_input_tokens || 0) !== (b.cached_input_tokens || 0)) return false;
  return true;
}

function validateRoundReport(report, currentRound) {
  if (!isPlainObject(report) || report.format !== 'yolo-round-report-v1') {
    throw new ContractError('round_report_format_invalid', { format: report && report.format });
  }
  if (report.round_id !== currentRound.id) throw new ContractError('round_mismatch', { via: 'report', declared: report.round_id });
  if (!Array.isArray(report.changed_paths)) throw new ContractError('round_report_observation_missing', {});
  const expected = currentRound.deterministic_checks || [];
  if (!Array.isArray(report.deterministic_checks)
      || new Set(report.deterministic_checks.map((check) => check && check.id)).size !== expected.length
      || report.deterministic_checks.length !== expected.length) {
    throw new ContractError('deterministic_check_results_missing', { expected: expected.map((check) => check.id) });
  }
  const expectedById = new Map(expected.map((check) => [check.id, check]));
  const seen = new Set();
  const failed = [];
  for (const result of report.deterministic_checks) {
    if (!isPlainObject(result) || typeof result.id !== 'string' || seen.has(result.id)
        || !expectedById.has(result.id)) {
      throw new ContractError('deterministic_check_results_invalid', { result });
    }
    seen.add(result.id);
    const expectedCheck = expectedById.get(result.id);
    const actualResult = result.result ?? result.outcome;
    // The OBSERVED exit is required; defaulting to the expectation would let a
    // prose-only PASS satisfy an exit-code assertion.
    const actualExit = result.exit ?? result.exit_status;
    if (!Number.isInteger(actualExit)
        || actualResult !== expectedCheck.expected_result || actualExit !== expectedCheck.expected_exit) {
      failed.push(result.id);
    }
  }
  return failed;
}

function currentActionForNonce(state, nonce) {
  return state.phase2 && Array.isArray(state.phase2.action_records)
    ? state.phase2.action_records.find((action) => action.action_nonce === nonce) : null;
}

function observedDigest(call) {
  if (isSha256(call.observed_sha256)) return call.observed_sha256;
  if (isSha256(call.post_sha256)) return call.post_sha256;
  const digests = effectDigests(call);
  return digests.length === 1 && isSha256(digests[0]) ? digests[0] : null;
}

function matchCurrentAction(state, currentRound, call) {
  const nonce = call && call.action_nonce;
  if (typeof nonce !== 'string' || !nonce) throw new ContractError('unauthorized_mutation', { native_call_id: call && call.native_call_id });
  const action = currentActionForNonce(state, nonce);
  if (!action) {
    const historical = state.phase2 && state.phase2.action_records
      ? state.phase2.action_records.find((candidate) => candidate.action_nonce === nonce) : null;
    if (historical) throw new ContractError('stale_round_action', { action_nonce: nonce, action_round: historical.round, current_round: currentRound.id });
    throw new ContractError('unauthorized_mutation', { native_call_id: call.native_call_id });
  }
  if (action.round !== currentRound.id) throw new ContractError('stale_round_action', {
    action_nonce: nonce, action_round: action.round, current_round: currentRound.id,
  });
  if (call.round_id !== currentRound.id) throw new ContractError('stale_round_action', {
    action_nonce: nonce, action_round: call.round_id, current_round: currentRound.id,
  });
  if (call.tool !== action.tool_class || call.args_sha256 !== action.args_sha256) {
    throw new ContractError('action_trace_mismatch', { action_id: action.action_id, action_nonce: nonce });
  }
  if (call.effect_manifest_sha256 !== action.effect_manifest_sha256) {
    throw new ContractError('action_effect_manifest_mismatch', { action_id: action.action_id });
  }
  if (call.target && call.target !== action.target) {
    throw new ContractError('action_target_mismatch', { action_id: action.action_id, target: call.target });
  }
  if (call.pre_sha256 !== action.pre_sha256) {
    throw new ContractError('action_pre_state_mismatch', { action_id: action.action_id });
  }
  const paths = mutationPaths(call);
  if (JSON.stringify(paths) !== JSON.stringify([...action.effect_paths].sort())) {
    throw new ContractError('action_effect_path_mismatch', { action_id: action.action_id, paths, expected: action.effect_paths });
  }
  const observed = observedDigest(call);
  if (!observed || !isSha256(observed)) throw new ContractError('action_observed_hash_missing', { action_id: action.action_id });
  if (action.observed_sha256 && action.observed_sha256 !== observed) {
    throw new ContractError('action_observed_hash_mismatch', { action_id: action.action_id });
  }
  const computedFingerprint = effectFingerprint(call);
  if (call.effect_fingerprint && call.effect_fingerprint !== computedFingerprint) {
    throw new ContractError('effect_fingerprint_mismatch', { action_id: action.action_id });
  }
  if (state.phase2.verified_effect_fingerprints.includes(computedFingerprint)) {
    throw new ContractError('repeated_verified_action', { action_id: action.action_id, effect_fingerprint: computedFingerprint });
  }
  return { action, effect_fingerprint: computedFingerprint, observed_sha256: observed, paths };
}

function normalizedPathSet(values) {
  return new Set((Array.isArray(values) ? values : []).map(normalizeObservedPath).filter(Boolean));
}

function reviewerEvidenceBlock(record, field = 'reviewer') {
  const block = isPlainObject(record[field]) ? record[field] : record;
  const reviewerId = block.id || block.reviewer_id || record.reviewer_id;
  const independent = block.independent === true || record.independent === true;
  let evidence = block.evidence ?? record.review_evidence ?? record.reviewer_evidence;
  if (!Array.isArray(evidence)) evidence = evidence ? [evidence] : [];
  evidence = evidence.map((ref) => {
    if (typeof ref === 'string') return {
      path: ref,
      sha256: block.evidence_sha256 || record.evidence_sha256,
      verdict: block.verdict || record.verdict,
    };
    return ref;
  });
  return {
    id: typeof reviewerId === 'string' ? reviewerId : null,
    independent,
    session_id: block.session_id || record.reviewer_session_id || null,
    verdict: block.verdict || record.verdict,
    evidence,
  };
}

function validateReviewerEvidence(record, { repoRoot, label, executorIds = [], executorSessions = [] } = {}) {
  const block = reviewerEvidenceBlock(record, label === 'final_reviewer' ? 'final_reviewer' : 'reviewer');
  if (!block.id) throw new ContractError('reviewer_identity_missing', { label });
  if (!block.independent) throw new ContractError('reviewer_not_independent', { label, reviewer_id: block.id });
  if (block.verdict !== 'PASS') throw new ContractError('reviewer_verdict_not_pass', { label });
  if (executorIds.includes(block.id) || (block.session_id && executorSessions.includes(block.session_id))) {
    throw new ContractError('reviewer_not_independent', { label, reviewer_id: block.id });
  }
  if (!Array.isArray(block.evidence) || block.evidence.length === 0) {
    throw new ContractError('reviewer_evidence_missing', { label });
  }
  const evidence = block.evidence.map((ref, index) => {
    const checked = validateEvidenceReference(ref, repoRoot, `${label}.evidence[${index}]`, { requirePass: false });
    assertPassCarrier(checked.abs, `${label}.evidence[${index}]`);
    return checked;
  });
  return { ...block, evidence, evidence_refs: block.evidence };
}

function criterionStatusIds(goal) {
  return successCriterionIds(goal);
}

function explicitCheckedItems(items, expectedIds, label) {
  if (!Array.isArray(items) || items.length !== expectedIds.length) {
    throw new ContractError(`${label}_coverage_invalid`, { expected: expectedIds });
  }
  const seen = new Set();
  for (const item of items) {
    const id = item && item.id;
    const checked = item && (item.status === 'checked' || item.checked === true || item.status === 'PASS');
    if (!isPlainObject(item) || typeof id !== 'string' || !expectedIds.includes(id) || seen.has(id) || !checked) {
      throw new ContractError(`${label}_coverage_invalid`, { item });
    }
    seen.add(id);
  }
  if (seen.size !== expectedIds.length) throw new ContractError(`${label}_coverage_invalid`, { expected: expectedIds });
}

function cmdRoundClose(flags, cwd, out) {
  const r = withRun(flags, cwd);
  requirePolicyMode(r.goal);
  if (r.state.phase2.phase_candidate) throw new ContractError('event_after_phase_candidate', { command: 'round-close' });
  refuseIfHonestPartial(r.state, 'round-close');
  const cur = r.state.phase2.current_round;
  if (!cur || cur.state !== 'authorized') {
    throw new ContractError('close_requires_authorized_round', { current: cur || null });
  }
  if (r.state.pending_action) {
    throw new ContractError('pending_action_blocks_close', { action_id: r.state.pending_action.action_id });
  }
  if (r.state.unknown_actions.length > 0) throw new ContractError('outcome_unknown', {
    actions: r.state.unknown_actions.map((action) => action.action_id),
  });
  assertWallClock(r.goal);
  const packetAbs = resolveInRepo(cur.packet_rel, r.repoRoot, 'execution_packet');
  if (!fs.existsSync(packetAbs) || sha256File(packetAbs) !== cur.packet_sha256) {
    throw new ContractError('packet_hash_mismatch', { round_id: cur.id });
  }
  const contractAbs = resolveInRepo(cur.contract_rel, r.repoRoot, 'slice_contract');
  if (!fs.existsSync(contractAbs) || sha256File(contractAbs) !== cur.contract_sha256) {
    throw new ContractError('contract_hash_mismatch', { round_id: cur.id });
  }
  const outcome = need(flags, 'outcome');
  if (!['candidate', 'failed', 'blocked'].includes(outcome)) {
    throw new UsageError('close_outcome_invalid', { outcome, allowed: ['candidate', 'failed', 'blocked'] });
  }
  const reportRel = need(flags, 'report');
  const reportRef = readArtifactReference(reportRel, 'round-report');
  const reportAbs = reportRef.abs;
  const report = reportRef.doc;
  const failedChecks = validateRoundReport(report, cur);
  const usageRel = need(flags, 'usage');
  const usageRef = readArtifactReference(usageRel, 'usage');
  const usageAbs = usageRef.abs;
  const usage = usageRef.doc;
  const total = checkedUsageTotal(usage, 'usage artifact');
  const turnRel = need(flags, 'turn-record');
  const turnRef = readArtifactReference(turnRel, 'execution-turn');
  const turnAbs = turnRef.abs;
  const turn = turnRef.doc;
  validateNativeTurn(turn, {
    kind: 'execution', round: cur.id, packet: cur.packet_sha256,
    journalSeq: r.state.events_count, label: 'execution-turn',
    qualityPolicy: r.goal.quality_policy || null,
  });
  if (!usageEqual(usage, turn.usage)) throw new ContractError('usage_turn_mismatch', {});
  if (!Array.isArray(turn.tool_policy) && !isPlainObject(turn.tool_policy)) {
    throw new ContractError('execution_tool_policy_missing', {});
  }
  const tracePaths = validateToolTrace(turn);
  // Exact-session continuation (§4.4) under codex's id-per-exec-call model:
  // the execution turn matches when its NATIVE thread id is the pinned session,
  // or its resumed_from_session binding proves the runner invoked
  // `codex exec resume <pinned-id>` for this turn. A fresh unrelated session
  // matches neither and is still refused.
  if (turn.session_id !== cur.session_id && turn.resumed_from_session !== cur.session_id) {
    throw new ContractError('session_mismatch', { pinned: cur.session_id, observed: turn.session_id, resumed_from: turn.resumed_from_session ?? null });
  }
  if (total > cur.reservation_tokens) {
    throw new ContractError('token_reservation_exceeded', { total, reservation: cur.reservation_tokens });
  }
  const consumed = [];
  const observations = [];
  const seenNonces = new Set();
  const seenEffects = new Set();
  for (const call of turn.tool_calls) {
    const paths = mutationPaths(call);
    if (paths.length === 0) {
      if (call.action_nonce === null || call.action_nonce === undefined) continue;
      // No-op consumption: the executor inspected the target and found the
      // intended effect ALREADY present, so correctly refusing to redo it is
      // the anti-blind-retry behavior working. Legal ONLY when the bound
      // current-round action was reconciled as 'reconciled' with the observed
      // state byte-identical to its pre-state (inspected, unchanged).
      const action = currentActionForNonce(r.state, call.action_nonce);
      if (!action || action.round !== cur.id) {
        throw new ContractError('action_nonce_on_read_only_call', { native_call_id: call.native_call_id });
      }
      if (action.reconciliation_outcome !== 'reconciled' || action.observed_sha256 !== action.pre_sha256) {
        throw new ContractError('action_nonce_on_read_only_call', {
          native_call_id: call.native_call_id, action_id: action.action_id,
          reconciliation: action.reconciliation_outcome,
          note: 'a nonce-carrying zero-mutation call is legal only as an inspected no-op (effect already present)',
        });
      }
      if (seenNonces.has(call.action_nonce)) throw new ContractError('duplicate_action_nonce', { action_nonce: call.action_nonce });
      seenNonces.add(call.action_nonce);
      const noOpFingerprint = effectFingerprint([], []);
      if (seenEffects.has(noOpFingerprint)) throw new ContractError('duplicate_effect_fingerprint', { effect_fingerprint: noOpFingerprint });
      seenEffects.add(noOpFingerprint);
      consumed.push(call.action_nonce);
      observations.push({
        action_id: action.action_id, action_nonce: call.action_nonce,
        paths: [], observed_sha256: action.observed_sha256,
        effect_fingerprint: noOpFingerprint,
      });
      continue;
    }
    const actionForCall = currentActionForNonce(r.state, call.action_nonce);
    if (actionForCall) {
      const argsAbs = resolveInRepo(actionForCall.args_path, r.repoRoot, 'action.args_path');
      const effectAbs = resolveInRepo(actionForCall.effect_manifest_path, r.repoRoot, 'action.effect_manifest_path');
      if (!fs.existsSync(argsAbs) || sha256File(argsAbs) !== actionForCall.args_sha256) {
        throw new ContractError('action_args_hash_mismatch', { action_id: actionForCall.action_id });
      }
      if (!fs.existsSync(effectAbs) || sha256File(effectAbs) !== actionForCall.effect_manifest_sha256) {
        throw new ContractError('action_effect_manifest_mismatch', { action_id: actionForCall.action_id });
      }
    }
    const matched = matchCurrentAction(r.state, cur, {
      ...call,
      round_id: call.round_id ?? turn.round_id,
    });
    if (seenNonces.has(call.action_nonce)) throw new ContractError('duplicate_action_nonce', { action_nonce: call.action_nonce });
    seenNonces.add(call.action_nonce);
    if (seenEffects.has(matched.effect_fingerprint)) throw new ContractError('duplicate_effect_fingerprint', { effect_fingerprint: matched.effect_fingerprint });
    seenEffects.add(matched.effect_fingerprint);
    consumed.push(call.action_nonce);
    observations.push({
      action_id: matched.action.action_id, action_nonce: call.action_nonce,
      paths: matched.paths, observed_sha256: matched.observed_sha256,
      effect_fingerprint: matched.effect_fingerprint,
    });
  }
  if (JSON.stringify(tracePaths) !== JSON.stringify(sortedUnique(tracePaths))) {
    throw new ContractError('native_observation_malformed', {});
  }
  const expectedActions = r.state.phase2.action_records.filter((action) => action.round === cur.id);
  if (JSON.stringify([...consumed].sort()) !== JSON.stringify(expectedActions.map((action) => action.action_nonce).sort())) {
    throw new ContractError('action_reconciliation_incomplete', {
      expected: expectedActions.map((action) => action.action_nonce), consumed,
    });
  }
  const reportedPaths = normalizedPathSet(report.changed_paths);
  if (JSON.stringify([...reportedPaths].sort()) !== JSON.stringify([...new Set(tracePaths)].sort())) {
    throw new ContractError('round_report_observation_mismatch', { report: [...reportedPaths], trace: tracePaths });
  }
  const direct = manifestChangedPaths(cur.worktree_manifest_at_prepare, readWorktreeManifest(r.repoRoot));
  const observed = [...new Set(tracePaths)].sort();
  if (JSON.stringify(direct) !== JSON.stringify(observed)) {
    throw new ContractError('unreceipted_mutation', { observed, final_delta: direct });
  }
  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'round_closed', {
    round_id: cur.id,
    outcome,
    packet_sha256: cur.packet_sha256,
    report_path: reportAbs,
    report_sha256: reportRef.sha256,
    usage_path: usageAbs,
    usage_sha256: usageRef.sha256,
    turn_record_path: turnAbs,
    turn_record_sha256: turnRef.sha256,
    failed_checks: failedChecks,
    observed_mutations: observations,
    consumed_action_nonces: consumed,
    effect_fingerprints: observations.map((observation) => observation.effect_fingerprint),
    usage: { ...turn.usage, total_tokens: total, native: true },
    session_id: cur.session_id,
  }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  return finish('round-close', r.runDir, after.state, null);
}

function cmdAlign(flags, cwd, out) {
  const r = withRun(flags, cwd);
  requirePolicyMode(r.goal);
  if (r.state.phase2.phase_candidate) throw new ContractError('event_after_phase_candidate', { command: 'align' });
  refuseIfHonestPartial(r.state, 'align');
  if (r.state.phase2.current_round || r.state.pending_action || r.state.unknown_actions.length > 0) {
    throw new ContractError('alignment_open_round_or_side_effect', {});
  }
  if (r.state.verified.length === 0) throw new ContractError('alignment_no_verified_state', {});
  assertWallClock(r.goal);
  const receiptRel = need(flags, 'receipt');
  const receiptAbs = resolveInRepo(receiptRel, r.repoRoot, '--receipt');
  const rec = readJsonArtifact(receiptAbs, 'alignment-receipt');
  if (rec.format !== 'yolo-alignment-receipt-v1') throw new ContractError('alignment_format_invalid', { format: rec.format });
  if (rec.verdict !== 'PASS') throw new ContractError('alignment_verdict_not_pass', {});
  const verifiedDigest = sha256String(JSON.stringify(r.state.verified));
  if (rec.verified_digest !== verifiedDigest) {
    throw new ContractError('alignment_stale_digest', { declared: rec.verified_digest, actual: verifiedDigest });
  }
  if (rec.goal_sha256 !== r.state.goal_sha256_at_init || rec.handoff_revision !== r.goal.handoff_revision) {
    throw new ContractError('alignment_binding_mismatch', {});
  }
  if (rec.watermark_seq !== r.state.events_count) {
    throw new ContractError('alignment_stale_watermark', { declared: rec.watermark_seq, actual: r.state.events_count });
  }
  const successIds = criterionStatusIds(r.goal);
  if (!Array.isArray(rec.success) || rec.success.length !== successIds.length) {
    throw new ContractError('alignment_success_coverage_invalid', { expected: successIds });
  }
  const covered = new Set(r.state.verified.flatMap((v) => v.maps_to_success || []));
  const seenSuccess = new Set();
  for (const item of rec.success) {
    if (!isPlainObject(item) || typeof item.id !== 'string' || !successIds.includes(item.id)
        || seenSuccess.has(item.id) || !['met', 'unmet', 'not_yet_due'].includes(item.status)
        || typeof item.evidence !== 'string' || item.evidence.trim() === '') {
      throw new ContractError('alignment_success_coverage_invalid', { item });
    }
    if (item.status === 'met' && !covered.has(item.id)) {
      throw new ContractError('alignment_unverified_success', { id: item.id });
    }
    seenSuccess.add(item.id);
  }
  if (seenSuccess.size !== successIds.length) throw new ContractError('alignment_success_coverage_invalid', { expected: successIds });
  const nonGoalIds = (r.goal.non_goals || []).map((item, index) => isPlainObject(item) && item.id ? item.id : `NG-${index + 1}`);
  const forbiddenIds = (r.goal.forbidden_scope || []).map((item, index) => isPlainObject(item) && item.id ? item.id : `FS-${index + 1}`);
  if (Array.isArray(rec.non_goals)) explicitCheckedItems(rec.non_goals, nonGoalIds, 'alignment_non_goals');
  else if (rec.non_goals_checked !== true) throw new ContractError('alignment_non_goals_unchecked', {});
  if (Array.isArray(rec.forbidden_scope)) explicitCheckedItems(rec.forbidden_scope, forbiddenIds, 'alignment_forbidden_scope');
  else if (rec.forbidden_scope_checked !== true) throw new ContractError('alignment_forbidden_scope_unchecked', {});
  if (!Array.isArray(rec.changed_paths) || !Array.isArray(rec.unresolved_risks)) {
    throw new ContractError('alignment_inventory_missing', {});
  }
  const reviewer = validateReviewerEvidence(rec, {
    repoRoot: r.repoRoot,
    label: 'reviewer',
    executorIds: r.state.verified.map((v) => v.executor_id).filter(Boolean),
  });
  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'alignment_verified', {
    watermark_seq: r.state.events_count,
    verified_digest: verifiedDigest,
    receipt_sha256: sha256File(receiptAbs),
    receipt_path: receiptRel,
    goal_sha256: r.state.goal_sha256_at_init,
    handoff_revision: r.goal.handoff_revision,
    success_ids: successIds,
    success: rec.success,
    reviewer_id: reviewer.id,
    reviewer_session_id: reviewer.session_id,
    changed_paths: rec.changed_paths,
    unresolved_risks: rec.unresolved_risks,
  }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  return finish('align', r.runDir, after.state, null);
}

function cmdPhaseCandidate(flags, cwd, out) {
  const r = withRun(flags, cwd);
  requirePolicyMode(r.goal);
  if (r.state.phase2.phase_candidate) throw new ContractError('event_after_phase_candidate', { command: 'phase-candidate' });
  refuseIfHonestPartial(r.state, 'phase-candidate');
  assertWallClock(r.goal);
  if (r.state.phase2.current_round) throw new ContractError('phase_candidate_with_open_round', { open: r.state.phase2.current_round.id });
  if (r.state.phase2.last_closed_round || r.state.pending_action || r.state.unknown_actions.length > 0) {
    throw new ContractError('phase_candidate_pending_side_effect', {});
  }
  if (r.state.binding_blockers && r.state.binding_blockers.length > 0) {
    throw new ContractError(r.state.binding_blockers[0].code, { blockers: r.state.binding_blockers });
  }
  const wm = r.state.phase2.alignment_watermark;
  const verifiedDigest = sha256String(JSON.stringify(r.state.verified));
  if (!wm || wm.seq !== r.state.events_count || wm.verified_digest !== verifiedDigest
      || !wm.receipt_sha256) {
    throw new ContractError('phase_candidate_alignment_required', { watermark: wm });
  }
  const frozen = frozenSliceIds(r.goal);
  if (frozen.length === 0 || frozen.length !== r.state.verified_slices.length
      || frozen.some((id) => !r.state.verified_slices.includes(id))) {
    throw new ContractError('phase_candidate_slices_incomplete', { frozen, verified: r.state.verified_slices });
  }
  const covered = new Set(r.state.verified.flatMap((v) => v.maps_to_success || []));
  const successIds = successCriterionIds(r.goal);
  const missingSuccess = successIds.filter((id) => !covered.has(id));
  if (missingSuccess.length > 0) {
    throw new ContractError('phase_candidate_success_coverage_incomplete', { missing: missingSuccess });
  }
  const receiptRel = need(flags, 'receipt');
  const receiptAbs = resolveInRepo(receiptRel, r.repoRoot, '--receipt');
  const rec = readJsonArtifact(receiptAbs, 'phase-candidate-receipt');
  if (rec.format !== 'yolo-phase-candidate-receipt-v1') throw new ContractError('phase_candidate_format_invalid', { format: rec.format });
  if (rec.verdict !== 'PASS') throw new ContractError('phase_candidate_verdict_not_pass', {});
  for (const field of ['goal_sha256', 'handoff_revision', 'verified_digest', 'watermark_seq', 'alignment_receipt_sha256']) {
    if (rec[field] === undefined || rec[field] === null || rec[field] === '') {
      throw new ContractError('phase_candidate_binding_missing', { field });
    }
  }
  if (rec.goal_sha256 !== r.state.goal_sha256_at_init || rec.handoff_revision !== r.goal.handoff_revision
      || rec.verified_digest !== verifiedDigest || rec.watermark_seq !== wm.watermark_seq
      || rec.alignment_receipt_sha256 !== wm.receipt_sha256) {
    throw new ContractError('phase_candidate_binding_mismatch', {});
  }
  if (!Array.isArray(rec.verified_slices)
      || JSON.stringify([...rec.verified_slices].sort()) !== JSON.stringify([...frozen].sort())) {
    throw new ContractError('phase_candidate_slices_incomplete', { verified: rec.verified_slices });
  }
  if (rec.wrong_or_unauthorized_next_action !== 0) throw new ContractError('unauthorized_next_actions_present', { count: rec.wrong_or_unauthorized_next_action });
  if (rec.repeated_verified_actions !== 0) throw new ContractError('repeated_verified_actions_present', { count: rec.repeated_verified_actions });
  if (!Array.isArray(rec.failed_checks) || rec.failed_checks.length > 0) {
    throw new ContractError('phase_candidate_failed_check', { failed_checks: rec.failed_checks });
  }
  const ha = rec.hidden_acceptance;
  if (!ha || !ha.path) throw new ContractError('phase_candidate_hidden_acceptance_missing', {});
  const hidden = validateEvidenceReference(ha, r.repoRoot, 'hidden_acceptance', { requirePass: true });
  if (ha.verdict !== 'PASS' && ha.passed !== true) throw new ContractError('phase_candidate_hidden_acceptance_failed', {});
  const finalReviewer = validateReviewerEvidence(rec, {
    repoRoot: r.repoRoot,
    label: 'final_reviewer',
    executorIds: r.state.verified.map((v) => v.executor_id).filter(Boolean),
  });
  if (!Array.isArray(rec.success) || rec.success.length !== successIds.length
      || new Set(rec.success.map((item) => item && item.id)).size !== successIds.length
      || rec.success.some((item) => !item || item.status !== 'met' || !successIds.includes(item.id)
        || typeof item.evidence !== 'string' || !item.evidence.trim())) {
    throw new ContractError('phase_candidate_success_coverage_incomplete', {});
  }
  withRunLock(r.runDir, () => appendEventGuarded(r.runDir, r.goal, r.events, 'phase_candidate_recorded', {
    receipt_sha256: sha256File(receiptAbs),
    receipt_path: receiptRel,
    goal_sha256: r.state.goal_sha256_at_init,
    handoff_revision: r.goal.handoff_revision,
    verified_digest: verifiedDigest,
    watermark_seq: wm.watermark_seq,
    alignment_receipt_sha256: wm.receipt_sha256,
    hidden_acceptance_path: repoRel(r.repoRoot, hidden.abs),
    hidden_acceptance_sha256: hidden.sha256,
    hidden_acceptance_verdict: 'PASS',
    final_reviewer_id: finalReviewer.id,
    final_reviewer_independent: true,
    verified_slices: frozen,
  }, r.identity.head));
  const after = loadRun(r.runDir, r.repoRoot, cwd);
  return finish('phase-candidate', r.runDir, after.state, null);
}

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
      phase2: state.phase2 ? {
        enabled: true,
        phase_candidate: state.phase2.phase_candidate,
        budgets: state.phase2.budgets,
        tokens_charged: state.phase2.tokens_charged,
        retry_counts: state.phase2.retry_counts,
        action_records: state.phase2.action_records,
        verified_effect_fingerprints: state.phase2.verified_effect_fingerprints,
      } : null,
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
  round-prepare   --run <dir> --contract <slice-contract.json>          (Phase-2)
  round-authorize --run <dir> --assertion <a.json> --review <r.json>
                  --turn-record <turn.json>                             (Phase-2)
  round-close     --run <dir> --outcome <candidate|failed|blocked>
                  --report <r.json> --usage <u.json> --turn-record <t.json> (Phase-2)
  align           --run <dir> --receipt <alignment-receipt.json>        (Phase-2)
  phase-candidate --run <dir> --receipt <receipt.json>                   (Phase-2)

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
      case 'round-prepare': res = cmdRoundPrepare(flags, cwd, out); break;
      case 'round-authorize': res = cmdRoundAuthorize(flags, cwd, out); break;
      case 'round-close': res = cmdRoundClose(flags, cwd, out); break;
      case 'align': res = cmdAlign(flags, cwd, out); break;
      case 'phase-candidate': res = cmdPhaseCandidate(flags, cwd, out); break;
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
