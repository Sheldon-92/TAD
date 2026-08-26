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

function main() {
  const argv = process.argv.slice(2);
  if (argv[0] !== 'turn') {
    console.log(JSON.stringify({ format: 'yolo-reference-runner-error', reason: 'usage', note: 'turn subcommand required' }));
    process.exit(2);
  }
  const flags = {};
  for (let i = 1; i < argv.length; i += 2) flags[argv[i].replace(/^--/, '')] = argv[i + 1];
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

  // Session continuation: codex resumes a native thread via the `resume`
  // subcommand (verified by magic-word probe). Fresh turns omit --session.
  const args = flags.session
    ? ['exec', 'resume', flags.session, '--json', '--skip-git-repo-check', '--sandbox', sandbox]
    : ['exec', '--json', '--skip-git-repo-check', '--sandbox', sandbox];
  args.push(userText.length ? userText : 'Proceed.');
  const t0 = Date.now();
  const res = spawnSync('codex', args, { encoding: 'utf8', timeout: 30 * 60 * 1000, cwd: path.dirname(packetAbs) });
  const elapsedMs = Date.now() - t0;

  // Raw artifacts land host-side with content hashes bound into the record.
  const rawOutRel = `${stamp}-${invocationNonce}-raw-output.txt`;
  const rawTraceRel = `${stamp}-${invocationNonce}-raw-trace.jsonl`;
  fs.writeFileSync(path.join(hostRoot, rawOutRel), res.stdout || '');
  fs.writeFileSync(path.join(hostRoot, rawTraceRel), JSON.stringify({ cmd: args.join(' '), exit: res.status, stderr: (res.stderr || '').slice(-4000), elapsed_ms: elapsedMs }, null, 2));

  const events = parseEvents(res.stdout || '');
  const threadStarted = events.find((e) => e.type === 'thread.started');
  const turnCompleted = events.find((e) => e.type === 'turn.completed');
  const agentMessages = events.filter((e) => e.type === 'item.completed' && e.item && e.item.type === 'agent_message');
  const finalMessage = agentMessages.length ? agentMessages[agentMessages.length - 1].item.text : '';
  const usage = turnCompleted && turnCompleted.usage ? {
    input_tokens: turnCompleted.usage.input_tokens || 0,
    output_tokens: turnCompleted.usage.output_tokens || 0,
    total_tokens: (turnCompleted.usage.input_tokens || 0) + (turnCompleted.usage.output_tokens || 0),
    cached_input_tokens: turnCompleted.usage.cached_input_tokens || 0,
    native: true,
  } : { input_tokens: 0, output_tokens: 0, total_tokens: 0, native: false };

  // Tool policy: assertion turns run under read-only sandbox; every observed
  // filesystem mutation in an assertion turn must be empty (checked via git).
  let changed = [];
  try {
    changed = execFileSync('git', ['status', '--porcelain'], { cwd: path.dirname(packetAbs), encoding: 'utf8' })
      .split('\n').filter(Boolean);
  } catch { /* not a repo or git unavailable — recorded as-is */ }

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
    // codex exec-resume natively continues a thread but assigns a NEW thread id
    // per exec call. Continuity is therefore proven two ways: session_id is the
    // native id of THIS run, resumed_from_session is the exact --session arg
    // the runner passed to `codex exec resume` (null on fresh turns). Consumers
    // (round-close) accept either match against the pinned session.
    session_id: threadStarted ? threadStarted.thread_id : null,
    resumed_from_session: flags.session || null,
    turn_kind: turnKind,
    round_id: flags['round-id'] || null,
    packet_sha256: packetSha,
    raw_native_output: { host_locator: path.join(hostRoot, rawOutRel), sha256: sha256File(path.join(hostRoot, rawOutRel)) },
    raw_native_trace: { host_locator: path.join(hostRoot, rawTraceRel), sha256: sha256String(JSON.stringify({ cmd: args.join(' '), exit: res.status })) },
    tool_policy: {
      allowed: turnKind === 'assertion' ? ['Read'] : ['Read', 'Edit', 'Write'],
      denied: turnKind === 'assertion' ? ['Write', 'Edit', 'Shell', 'Agent'] : ['Shell', 'Agent'],
      sandbox,
    },
    tool_calls: [{
      native_call_id: 'final',
      tool: 'codex-exec',
      args_sha256: sha256String(args.join(' ')),
      decision: 'allowed',
      action_nonce: nonce,
      pre_manifest_sha256: null,
      post_manifest_sha256: changed.length ? sha256String(changed.join('\n')) : null,
      // Only TRACKED modifications/deletions count as mutations by this turn.
      // Untracked entries are pre-existing setup inputs recorded as worktree
      // observation. In read-only assertion turns nothing can mutate, so all
      // three observed lists are empty by construction.
      observed_changed: turnKind === 'assertion' ? [] : changed.filter((l) => !l.startsWith('??')),
      observed_deleted: turnKind === 'assertion' ? [] : changed.filter((l) => l.startsWith(' D ') || l.startsWith('D ')),
      observed_untracked: turnKind === 'assertion' ? [] : changed.filter((l) => l.startsWith('??')).map((l) => l.slice(3)),
      worktree_observation: changed,
    }],
    usage,
    exit_status: res.status,
    final_message: finalMessage.slice(0, 4000),
  };

  const recRel = `${stamp}-${invocationNonce}-record.json`;
  fs.writeFileSync(path.join(hostRoot, recRel), JSON.stringify(record, null, 2));
  console.log(JSON.stringify({ format: 'yolo-reference-runner-result-v1', record_path: path.join(hostRoot, recRel), record }));
}

main();
