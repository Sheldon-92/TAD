#!/usr/bin/env node
/**
 * yolo-reference-runner.mjs — Phase-2 reference-harness runner (codex).
 *
 * Owns native turn records per Handoff §4.4: spawns `codex exec`, captures the
 * JSON event stream (thread id, agent message, native usage), binds runner
 * provenance + invocation nonce + packet hash, and writes the record plus raw
 * artifacts into a host-side evidence root. NOT a universal adapter.
 *
 * Usage:
 *   node yolo-reference-runner.mjs turn --host-evidence <dir> --packet <execution.md>
 *        --prompt <prompt.txt> --role executor --turn-kind assertion
 *        [--session <thread-id>] [--nonce <action-nonce>] [--sandbox read-only|workspace-write]
 */
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const RUNNER_VERSION = '1.0.0';
const RUNNER_SHA256 = crypto.createHash('sha256').update(fs.readFileSync(HERE + '/yolo-reference-runner.mjs')).digest('hex');

function sha256File(p) { return crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex'); }
function sha256String(s) { return crypto.createHash('sha256').update(s).digest('hex'); }

function codexVersion() {
  try {
    return execFileSync('codex', ['--version'], { encoding: 'utf8' }).trim();
  } catch { return 'unknown'; }
}

function parseEvents(raw) {
  const events = [];
  for (const line of raw.split('\n')) {
    const s = line.trim();
    if (!s.startsWith('{')) continue;
    try { events.push(JSON.parse(s)); } catch { /* non-JSON noise line */ }
  }
  return events;
}

function gitOutput(repoRoot, args) {
  try {
    return execFileSync('git', args, { cwd: repoRoot, encoding: 'utf8' });
  } catch {
    return '';
  }
}

function worktreeManifest(repoRoot) {
  const files = gitOutput(repoRoot, ['ls-files', '--cached', '--others', '--exclude-standard'])
    .split('\n').filter(Boolean);
  const manifest = {};
  for (const rel of files) {
    const abs = path.join(repoRoot, rel);
    if (fs.existsSync(abs) && fs.lstatSync(abs).isFile()) manifest[rel] = sha256File(abs);
  }
  return manifest;
}

function statusMap(repoRoot) {
  const map = {};
  for (const line of gitOutput(repoRoot, ['status', '--porcelain', '--untracked-files=all']).split('\n').filter(Boolean)) {
    map[line.slice(3)] = line.slice(0, 2);
  }
  return map;
}

function changedPaths(before, after) {
  return [...new Set([...Object.keys(before), ...Object.keys(after)])]
    .filter((rel) => before[rel] !== after[rel]).sort();
}

function classifyChanges(paths, beforeStatus, afterStatus, beforeManifest, afterManifest) {
  const changed = [];
  const deleted = [];
  const untracked = [];
  for (const rel of paths) {
    const status = afterStatus[rel] || '';
    if (!afterManifest[rel] || status.includes('D')) deleted.push(rel);
    else if (status === '??' && beforeStatus[rel] !== '??') untracked.push(rel);
    else changed.push(rel);
  }
  return { changed, deleted, untracked };
}

function isSha256(value) {
  return typeof value === 'string' && /^[0-9a-f]{64}$/.test(value);
}

function main() {
  const argv = process.argv.slice(2);
  if (argv[0] !== 'turn') {
    console.log(JSON.stringify({ format: 'yolo-reference-runner-error', reason: 'usage', note: 'turn subcommand required' }));
    process.exit(2);
  }
  const flags = {};
  for (let i = 1; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) continue;
    const name = token.replace(/^--/, '');
    const next = argv[i + 1];
    if (next === undefined || next.startsWith('--')) flags[name] = true;
    else { flags[name] = next; i += 1; }
  }
  for (const f of ['host-evidence', 'packet', 'prompt']) {
    if (!flags[f]) { console.log(JSON.stringify({ format: 'yolo-reference-runner-error', reason: 'missing_flag', flag: f })); process.exit(2); }
  }
  const role = flags.role || 'executor';
  const turnKind = flags['turn-kind'] || 'assertion';
  const sandbox = flags.sandbox || (turnKind === 'assertion' ? 'read-only' : 'workspace-write');
  const nonce = flags.nonce || null;
  const hostRoot = path.resolve(flags['host-evidence']);
  const packetAbs = path.resolve(flags.packet);
  const promptAbs = path.resolve(flags.prompt);
  const packetSha = (() => {
    try { return sha256File(packetAbs); } catch (e) {
      console.error(`RUNNER DEBUG: cwd=${process.cwd()} packetAbs=${packetAbs} err=${e.message}`);
      throw e;
    }
  })();

  // Host-side evidence root is created by the Conductor; executors never see it.
  fs.mkdirSync(hostRoot, { recursive: true });
  const invocationNonce = crypto.randomBytes(8).toString('hex');
  const stamp = new Date().toISOString().replace(/[:.]/g, '-');

  // Build the user message: packet reference + task prompt. The runner never
  // injects prior transcripts; the packet is the only context carrier.
  const userText = fs.readFileSync(promptAbs, 'utf8');

  // codex's workspace-write sandbox restricts writes to the cwd SUBTREE. The
  // packet lives deep inside .tad/evidence/..., but the slice targets (guide.md,
  // util.mjs, ...) live at the repo ROOT — spawning codex from the packet dir
  // makes those targets "outside the writable sandbox" and the write is blocked.
  // So run codex (and the git side-effect probe) from the repo root instead.
  const repoRoot = (() => {
    try {
      return execFileSync('git', ['rev-parse', '--show-toplevel'], { cwd: path.dirname(packetAbs), encoding: 'utf8' }).trim();
    } catch { return path.dirname(packetAbs); }
  })();

  // Session continuation: `exec resume` has no --sandbox option, but accepts a
  // sandbox_mode config override. This keeps assertion and execution turns in
  // the same native session while applying the intended mode to each turn.
  const args = flags.session
    ? ['exec', 'resume', flags.session, '--json', '--skip-git-repo-check', '-c', `sandbox_mode="${sandbox}"`]
    : ['exec', '--json', '--skip-git-repo-check', '--sandbox', sandbox];
  args.push(userText.length ? userText : 'Proceed.');
  const preManifest = worktreeManifest(repoRoot);
  const preStatus = statusMap(repoRoot);
  const t0 = Date.now();
  const res = spawnSync('codex', args, { encoding: 'utf8', timeout: 30 * 60 * 1000, cwd: repoRoot });
  const elapsedMs = Date.now() - t0;

  const postManifest = worktreeManifest(repoRoot);
  const postStatus = statusMap(repoRoot);
  const delta = changedPaths(preManifest, postManifest);
  const classified = classifyChanges(delta, preStatus, postStatus, preManifest, postManifest);
  const actionTarget = flags['action-target'] || null;
  const targetAbs = actionTarget
    ? (path.isAbsolute(actionTarget) ? actionTarget : path.join(repoRoot, actionTarget)) : null;
  const observedSha = targetAbs && fs.existsSync(targetAbs) && fs.lstatSync(targetAbs).isFile()
    ? sha256File(targetAbs) : (targetAbs ? '0'.repeat(64) : null);
  const observedPaths = [...new Set([...classified.changed, ...classified.deleted, ...classified.untracked])].sort();
  const effectFingerprint = observedPaths.length && isSha256(observedSha)
    ? sha256String(JSON.stringify([observedPaths, [observedSha]])) : null;

  // Raw artifacts land host-side with content hashes bound into the record.
  const rawOutRel = `${stamp}-${invocationNonce}-raw-output.txt`;
  const rawTraceRel = `${stamp}-${invocationNonce}-raw-trace.jsonl`;
  // Preserve the exact native JSONL stream in both raw carriers. Invocation
  // metadata is bound separately below; the trace must remain independently
  // parseable instead of being reduced to a summary object.
  const rawTrace = res.stdout || '';
  fs.writeFileSync(path.join(hostRoot, rawOutRel), res.stdout || '');
  fs.writeFileSync(path.join(hostRoot, rawTraceRel), rawTrace);

  const events = parseEvents(res.stdout || '');
  const threadStarted = events.find((e) => e.type === 'thread.started');
  const turnCompleted = events.find((e) => e.type === 'turn.completed');
  const agentMessages = events.filter((e) => e.type === 'item.completed' && e.item && e.item.type === 'agent_message');
  const finalMessage = agentMessages.length ? agentMessages[agentMessages.length - 1].item.text : '';
  const nativeToolEvents = events
    .filter((event) => event.item && ['command_execution', 'file_change', 'mcp_tool_call'].includes(event.item.type))
    .map((event) => ({
      event_type: event.type,
      item_type: event.item.type,
      item_id: event.item.id || null,
      command_sha256: typeof event.item.command === 'string' ? sha256String(event.item.command) : null,
      paths: Array.isArray(event.item.changes) ? event.item.changes.map((change) => change.path).filter(Boolean) : [],
    }));
  const usage = turnCompleted && turnCompleted.usage ? {
    input_tokens: turnCompleted.usage.input_tokens || 0,
    output_tokens: turnCompleted.usage.output_tokens || 0,
    total_tokens: (turnCompleted.usage.input_tokens || 0) + (turnCompleted.usage.output_tokens || 0),
    cached_input_tokens: turnCompleted.usage.cached_input_tokens || 0,
    native: true,
  } : { input_tokens: 0, output_tokens: 0, total_tokens: 0, native: false };

  const record = {
    format: 'yolo-reference-turn-v1',
    written_by: 'reference-runner',
    runner_version: RUNNER_VERSION,
    runner_sha256: RUNNER_SHA256,
    parser_version: '1',
    invocation_nonce: invocationNonce,
    harness: 'codex',
    harness_version: codexVersion(),
    model_id: flags.model || 'codex-default',
    model_family: 'gpt',
    reasoning: flags.reasoning || 'balanced',
    role,
    session_id: threadStarted ? threadStarted.thread_id : null,
    resumed_from_session: flags.session || null,
    turn_kind: turnKind,
    round_id: flags['round-id'] || null,
    journal_seq: flags['journal-seq'] === undefined ? null : Number(flags['journal-seq']),
    packet_sha256: packetSha,
    invocation: { cmd: args, exit: res.status, stderr: (res.stderr || '').slice(-4000), elapsed_ms: elapsedMs },
    native_event_count: nativeToolEvents.length,
    native_event_kinds: nativeToolEvents.map((event) => event.item_type),
    native_tool_events: nativeToolEvents,
    native_policy_violation: turnKind === 'assertion'
      && nativeToolEvents.some((event) => ['command_execution', 'file_change', 'mcp_tool_call'].includes(event.item_type)),
    pre_manifest: preManifest,
    post_manifest: postManifest,
    raw_native_output: { host_locator: path.join(hostRoot, rawOutRel), sha256: sha256File(path.join(hostRoot, rawOutRel)) },
    raw_native_trace: { host_locator: path.join(hostRoot, rawTraceRel), sha256: sha256File(path.join(hostRoot, rawTraceRel)) },
    tool_policy: {
      allowed: turnKind === 'assertion' ? ['Read'] : ['Read', 'Edit', 'Write'],
      denied: turnKind === 'assertion' ? ['Write', 'Edit', 'Shell', 'Bash', 'Agent', 'Task'] : ['Shell', 'Bash', 'Agent', 'Task'],
      sandbox,
    },
    worktree_observation: observedPaths,
    tool_calls: [{
      native_call_id: 'final',
      tool: flags['action-tool'] || (turnKind === 'assertion' ? 'Read' : 'codex-exec'),
      args_sha256: flags['action-args-sha256'] || sha256String(args.join(' ')),
      invocation_args_sha256: sha256String(args.join(' ')),
      decision: 'allowed',
      action_nonce: nonce,
      action_id: flags['action-id'] || null,
      round_id: flags['action-round'] || flags['round-id'] || null,
      target: actionTarget,
      pre_sha256: flags['action-pre-sha256'] || null,
      post_sha256: observedSha,
      observed_sha256: observedSha,
      effect_manifest_sha256: flags['action-effect-manifest-sha256'] || null,
      effect_paths: observedPaths,
      effect_fingerprint: effectFingerprint,
      pre_manifest_sha256: sha256String(JSON.stringify(preManifest)),
      post_manifest_sha256: sha256String(JSON.stringify(postManifest)),
      observed_changed: classified.changed,
      observed_deleted: classified.deleted,
      observed_untracked: classified.untracked,
      worktree_observation: observedPaths,
    }],
    usage,
    exit_status: res.status,
    // The assertion scorer consumes this field. Keep the complete bounded
    // response; 4,000 chars can truncate S4 while the packet budget permits
    // substantially more, turning a valid assertion into a false FAIL.
    final_message: finalMessage.slice(0, 16000),
  };

  const recRel = `${stamp}-${invocationNonce}-record.json`;
  fs.writeFileSync(path.join(hostRoot, recRel), JSON.stringify(record, null, 2));
  console.log(JSON.stringify({ format: 'yolo-reference-runner-result-v1', record_path: path.join(hostRoot, recRel), record }));
  process.exit(res.status === 0 ? 0 : 1);
}

main();
