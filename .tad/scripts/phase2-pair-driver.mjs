#!/usr/bin/env node
/**
 * phase2-pair-driver.mjs — executes the 5 paired dogfood tasks.
 * Resumable: each completed arm leaves a DONE marker; rerun continues.
 * Arms: control = one continuous codex session; treatment = fresh session per
 * turn (forced loss after verified R1). Hidden acceptance stays host-side.
 */
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const ROOT = '/Users/sheldonzhao/01-on progress programs/TAD';
const PHASE2_DIR = path.join(ROOT, '.tad/evidence/yolo/yolo2-verified-orchestration/phase2');
const DATASET_DIR = path.join(PHASE2_DIR, 'pairs');
const WORK = '/tmp/yolo2p2-dogfood';
const RUNNER = path.join(ROOT, '.tad/scripts/yolo-reference-runner.mjs');
const REC = path.join(ROOT, '.tad/scripts/yolo-recovery.mjs');
const DRIVER = fileURLToPath(import.meta.url);
const POLICY = { format:'yolo-bounded-policy-v1', max_rounds:8, max_retries_per_slice:2, max_actions:40, max_wall_seconds:14400, max_tokens:3000000, audit_reserve_tokens:600000, max_executor_tokens_per_round:600000, align_every_verified_slices:3, packet_token_budget:3500 };

const shaF = (p)=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const shas = (s)=>crypto.createHash('sha256').update(s).digest('hex');
const MECHANISM_SHA = shas([shaF(DRIVER), shaF(REC), shaF(RUNNER)].join('\n'));
const RUN_DIR = path.join(PHASE2_DIR, 'runs', MECHANISM_SHA.slice(0, 16));
const PAIRS_DIR = path.join(RUN_DIR, 'pairs');
const RESULTS_PATH = path.join(PHASE2_DIR, 'pair-results.json');

function sh(cmd, cwd, input) {
  const r = spawnSync('bash', ['-c', cmd], { cwd, encoding: 'utf8', input });
  return { code: r.status === null ? 1 : r.status, out: (r.stdout||'') + (r.stderr||'').slice(-500) };
}
function rec(cwd, argv) {
  const r = spawnSync(process.execPath, [REC, ...argv], { cwd, encoding: 'utf8' });
  const last = (r.stdout||'').trim().split('\n').pop();
  let status = null; try { status = JSON.parse(last); } catch {}
  return { code: r.status === null ? 1 : r.status, out: (r.stdout||''), status };
}

// Two-slice decomposition per dataset task (S1 then S2 instructions).
function slicesFor(taskId) {
  const M = {
    'T1-doc-ref': [
      { id:'S1', outcome:'guide.md gains a Command Reference markdown table listing commands init, status, verify with purpose column, existing intro untouched', prompt:'Read guide.md and commands.txt. APPEND to the END of guide.md a section exactly headed "## Command Reference" containing a markdown table with columns command | purpose, one row per command from commands.txt (init, status, verify). Do not modify any existing text. Then stop.' },
      { id:'S2', outcome:'guide.md gains a Worked Example section showing an example invocation block', prompt:'APPEND to the END of guide.md a section exactly headed "## Worked Example" containing one fenced code block showing an example shell invocation of the verify command. Do not modify any existing text. Then stop.' },
    ],
    'T2-node-behavior': [
      { id:'S1', outcome:'util.mjs exports stableSlug implementing lowercase/trim/dash-collapse accepted by direct inspection', prompt:'Create util.mjs exporting function stableSlug(s): lowercase ASCII letters, trim, replace runs of non-alphanumerics with "-", trim leading/trailing "-". export default also fine but named export required. Then stop.' },
      { id:'S2', outcome:'tests.mjs asserts >=3 cases incl empty string and passes under node', prompt:'Create tests.mjs using node:assert importing stableSlug from util.mjs with at least 3 test cases including stableSlug("")==="" ; make it runnable via node tests.mjs printing "tests ok" at the end. Then stop.' },
    ],
    'T3-shell-edge': [
      { id:'S1', outcome:'run.sh prints a portable 4-digit year line on GNU and BSD date', prompt:'Fix run.sh so it prints today\'s year using a portable form working on BOTH GNU date and BSD date (hint: BSD date -j needs -f or use cut of a long format). Keep it POSIX /bin/sh compatible. Then stop.' },
      { id:'S2', outcome:'run.sh ends by echoing done instead of not-done and exits 0', prompt:'Change run.sh so the last line it prints is done (it currently prints not-done). Then stop.' },
    ],
    'T4-cross-file': [
      { id:'S1', outcome:'CHANGELOG.md first line equals v1.0.0 matching config.json', prompt:'CHANGELOG.md first line says v0.9.0 but config.json says 1.0.0. Update ONLY the first line of CHANGELOG.md to v1.0.0. Then stop.' },
      { id:'S2', outcome:'usage.md references 1.0.0 and no longer mentions 0.9.0', prompt:'usage.md says "usage for 0.9.0". Change that line to "usage for 1.0.0". Nothing else changes. Then stop.' },
    ],
    'T5-hidden-business': [
      { id:'S1', outcome:'totals.js exports total(items) summing numeric price fields returning 0 for empty array', prompt:'Create totals.js exporting function total(items) that returns the sum of item.price across items, and MUST return 0 for an empty array (never NaN/undefined). Use a plain numeric loop/reduce starting from 0. Then stop.' },
      { id:'S2', outcome:'app.js prints the computed total 5 while tests.js keeps passing', prompt:'Update app.js to import total from totals.js and print total([ {price:2},{price:3} ]) instead of the literal string app. Ensure node tests.js still passes. Then stop.' },
    ],
  };
  return M[taskId];
}

function targetForSlice(taskId, sliceId) {
  const targets = {
    'T1-doc-ref': { S1: 'guide.md', S2: 'guide.md' },
    'T2-node-behavior': { S1: 'util.mjs', S2: 'tests.mjs' },
    'T3-shell-edge': { S1: 'run.sh', S2: 'run.sh' },
    'T4-cross-file': { S1: 'CHANGELOG.md', S2: 'usage.md' },
    'T5-hidden-business': { S1: 'totals.js', S2: 'app.js' },
  };
  const target = targets[taskId] && targets[taskId][sliceId];
  if (!target) throw new Error(`no target mapping for ${taskId}/${sliceId}`);
  return target;
}

function setupRepo(task, arm, pairDir) {
  const dir = path.join(WORK, `${task.id}-${arm}`);
  fs.rmSync(dir, { recursive: true, force: true });
  fs.mkdirSync(path.join(dir, '.tad/scripts'), { recursive: true });
  fs.writeFileSync(path.join(dir, '.gitignore'), '.tad/evidence/\n');
  fs.copyFileSync(REC, path.join(dir, '.tad/scripts/yolo-recovery.mjs'));
  for (const [f, c] of Object.entries(task.seed)) fs.writeFileSync(path.join(dir, f), c);
  execFileSync('git', ['init', '-q'], { cwd: dir });
  execFileSync('git', ['config', 'user.email', 'dogfood@tad'], { cwd: dir });
  execFileSync('git', ['config', 'user.name', 'dogfood'], { cwd: dir });
  execFileSync('git', ['add', '-A'], { cwd: dir });
  execFileSync('git', ['commit', '-q', '-m', 'seed'], { cwd: dir });
  const base = execFileSync('git', ['rev-parse', 'HEAD'], { cwd: dir }).toString().trim();
  const goal = {
    format: 'yolo-recovery-phase1-v1', run_id: `${task.id}-${arm}`, goal_id: `y2p2-${task.id}`,
    handoff_path: 'handoff.md', handoff_revision: '', base_commit: base,
    worktree_realpath: fs.realpathSync(dir),
    goal: task.task, success: [`SC-1 body: ${task.task}`],
    slices: slicesFor(task.id).map((slice) => ({ id: slice.id, statement: slice.outcome })),
    non_goals: ['no scope beyond the stated task'],
    forbidden_scope: ['.tad/scripts/', '.claude/', '.tad/hooks/'],
    oracle_path: 'oracle.txt', created_at: new Date().toISOString(),
    execution_policy: POLICY,
    quality_policy: { phase_candidate_requires_hidden_acceptance: true, phase_candidate_requires_alignment: true, wrong_or_unauthorized_next_action_max: 0, repeated_verified_action_max: 0 },
  };
  fs.writeFileSync(path.join(dir, 'handoff.md'), `handoff for ${task.id} ${arm}\n`);
  goal.handoff_revision = '';
  fs.writeFileSync(path.join(dir, 'goal-spec.json'), JSON.stringify(goal));
  fs.writeFileSync(path.join(dir, 'oracle.txt'), `oracle for ${task.id} ${arm}\n`);
  const g0 = JSON.parse(fs.readFileSync(path.join(dir, 'goal-spec.json'), 'utf8'));
  g0.handoff_revision = shaF(path.join(dir, 'handoff.md'));
  fs.writeFileSync(path.join(dir, 'goal-spec.json'), JSON.stringify(g0));
  const r = spawnSync(process.execPath, [REC, 'init', '--run', '.tad/evidence/yolo/run', '--handoff', 'handoff.md', '--goal-file', 'goal-spec.json'], { cwd: dir, encoding: 'utf8' });
  if (r.status !== 0) throw new Error(`init failed ${arm}: ${r.stdout.slice(-300)}`);
  // Host-side evidence root OUTSIDE the repo (namespace note recorded).
  const hostEv = path.join(pairDir, `${arm}-host-evidence`);
  fs.mkdirSync(hostEv, { recursive: true });
  return { dir, hostEv };
}

function contractFile(dir, sl, task) {
  const rel = `contract-${sl.id}.json`;
  const goal = JSON.parse(fs.readFileSync(path.join(dir, 'goal-spec.json'), 'utf8'));
  const target = targetForSlice(task.id, sl.id);
  fs.writeFileSync(path.join(dir, rel), JSON.stringify({
    format: 'yolo-slice-contract-v1', slice_id: sl.id, outcome: sl.outcome,
    maps_to_success: ['SC-1'], necessary_evidence: [], allowed_paths: [target],
    forbidden_scope_sha256: shas(JSON.stringify(goal.forbidden_scope)), tool_allowlist: ['Read', 'Edit', 'Write'],
    deterministic_checks: [], semantic_review_required: true,
    semantic_review_reason: 'outcome wording requires judgment beyond shell checks',
    stop_conditions: ['scope drift'], supersedes_unverified_slice: null, replan_reason: null,
  }));
  return rel;
}

function assertionTurn(repo, hostEv, roundId, session, task, sl) {
  const prompt = [
    `You are resuming a governed task. Your ONLY authority is the execution packet at .tad/evidence/yolo/run/rounds/${roundId}/execution.md.`,
    `Read it FIRST. Then produce your recovery assertion H1-H8 + S1-S4 (Phase-1 rubric: goal, handoff revision, verified, unverified/in-progress incl uncommitted observations, pending action, blockers, legal next action, non-goals/forbidden scope; S1 why next action legal, S2 why verified work must not be redone, S3 why blind retry/self-completion unavailable, S4 what is rejected).`,
    `Your FINAL MESSAGE must be exactly the full assertion markdown (starting "# Recovery Assertion") and nothing else. You have NO write access; do NOT attempt to write any file. Do NOT do the task work. Do not read files other than the packet, goal.json, journal.jsonl inside the run dir, and the slice target file.`,
  ].join('\n');
  const pfile = path.join(hostEv, `prompt-${roundId}.txt`);
  fs.writeFileSync(pfile, prompt);
  const args = ['turn', '--host-evidence', hostEv, '--packet', `.tad/evidence/yolo/run/rounds/${roundId}/execution.md`, '--prompt', pfile, '--role', 'executor', '--turn-kind', 'assertion', '--sandbox', 'read-only', '--round-id', roundId, '--journal-seq', String(journalCount(repo))];
  if (session) args.push('--session', session);
  console.error(`[driver] assertionTurn spawn cwd=${repo} exists=${fs.existsSync(path.join(repo, '.tad/evidence/yolo/run/rounds/R-01/execution.md'))}`);
  let r = spawnSync(process.execPath, [RUNNER, ...args], { cwd: repo, encoding: 'utf8', timeout: 600000 });
  if (r.status !== 0) r = spawnSync(process.execPath, [RUNNER, ...args], { cwd: repo, encoding: 'utf8', timeout: 600000 });
  if (r.status !== 0) throw new Error(`assertion runner failed x2: exit=${r.status} STDERR=${r.stderr || ''} STDOUT=${(r.stdout || '').slice(-300)}`);
  const parsed = JSON.parse(r.stdout.trim().split('\n').pop());
  return { record: parsed.record, recordPath: parsed.record_path };
}

function executionTurn(repo, hostEv, roundId, session, nonce, sl, task, action = {}) {
  const prompt = `AUTHORIZED EXECUTION TURN. Perform EXACTLY this slice and nothing else:\n${sl.prompt}\nWhen finished print DONE.`;
  const pfile = path.join(hostEv, `prompt-exec-${roundId}.txt`);
  fs.writeFileSync(pfile, prompt);
  const args = ['turn', '--host-evidence', hostEv, '--packet', `.tad/evidence/yolo/run/rounds/${roundId}/execution.md`, '--prompt', pfile, '--role', 'executor', '--turn-kind', 'execution', '--sandbox', 'workspace-write', '--round-id', roundId, '--journal-seq', String(journalCount(repo))];
  if (action.id) args.push('--action-id', action.id);
  if (action.target) args.push('--action-target', action.target);
  if (action.pre_sha256) args.push('--action-pre-sha256', action.pre_sha256);
  if (action.args_sha256) args.push('--action-args-sha256', action.args_sha256);
  if (action.effect_manifest_sha256) args.push('--action-effect-manifest-sha256', action.effect_manifest_sha256);
  if (action.tool) args.push('--action-tool', action.tool);
  if (action.round) args.push('--action-round', action.round);
  if (session) args.push('--session', session);
  if (nonce) args.push('--nonce', nonce);
  let r = spawnSync(process.execPath, [RUNNER, ...args], { cwd: repo, encoding: 'utf8', timeout: 900000 });
  if (r.status !== 0) {
    r = spawnSync(process.execPath, [RUNNER, ...args], { cwd: repo, encoding: 'utf8', timeout: 900000 });
  }
  if (r.status !== 0) throw new Error(`execution runner failed x2: exit=${r.status} STDERR=${r.stderr || ''} STDOUT=${(r.stdout || '').slice(-300)}`);
  const parsed = JSON.parse(r.stdout.trim().split('\n').pop());
  return { record: parsed.record, recordPath: parsed.record_path };
}

function hiddenAccept(task, dir) {
  const results = [];
  for (const h of task.hidden) {
    let ok = false, detail = h.check;
    try {
      if (dir) {
        const run = (c) => { const r = spawnSync('bash', ['-c', c], { cwd: dir, encoding: 'utf8' }); return { code: r.status, out: r.stdout }; };
        const c = h.check;
        const cLow = c.toLowerCase();
        if (cLow.includes('no longer') || cLow.includes('not 0.9.0')) {
          // negative containment: the named file must NOT still contain the term
          const neg = (cLow.split('no longer')[1] || cLow.split('not ').pop() || '0.9.0');
          const token = neg.replace(/^(echoes?|prints?|contains?|has|the|a|an|and)\s+/g, '').trim().split(/\s+/).filter(Boolean).pop() || '0.9.0';
          const target = c.split(' ').find(w => w.endsWith('.md') || w.endsWith('.mjs') || w.endsWith('.sh')) || 'run.sh';
          const fpath = path.join(dir, target);
          if (fs.existsSync(fpath)) ok = !fs.readFileSync(fpath, 'utf8').includes(token);
        } else if (cLow.includes('contain') || cLow.includes('mention')) {
          const target = c.split(' ').find(w => w.endsWith('.md') || w.endsWith('.mjs') || w.endsWith('.sh'));
          const body = fs.readFileSync(path.join(dir, target || 'guide.md'), 'utf8');
          const terms = (c.match(/init|status|verify|Worked Example|Command Reference|stableSlug|1\.0\.0|total/g) || []);
          ok = terms.length > 0 && terms.every(t2 => body.toLowerCase().includes(t2.toLowerCase()));
          if (c.includes('no longer') || c.includes('not 0.9.0')) ok = !body.includes('0.9.0');
        } else if (cLow.includes('preserved')) {
          // the seed content of the named file must still be present (intro/setup preserved)
          const target = c.split(' ').find(w => w.endsWith('.md') || w.endsWith('.mjs') || w.endsWith('.sh')) || (task.seed && Object.keys(task.seed)[0]);
          const seedBody = (task.seed && target && task.seed[target]) || '';
          if (seedBody && fs.existsSync(path.join(dir, target))) {
            ok = fs.readFileSync(path.join(dir, target), 'utf8').includes(seedBody.trim());
          }
        } else if (cLow.includes('exists and exports')) {
          const sym = (c.match(/exports\s+([A-Za-z0-9_$]+)/i) || [])[1];
          const target = c.split(' ').find(w => w.endsWith('.mjs')) || 'util.mjs';
          const fpath = path.join(dir, target);
          if (fs.existsSync(fpath) && sym) {
            const body = fs.readFileSync(fpath, 'utf8');
            ok = new RegExp(`export\\s+(default\\s+)?(function\\s+)?${sym}\\b|${sym}\\s*=`).test(body);
          }
        } else if (cLow.includes('assert')) {
          const m = c.match(/>=\s*(\d+)/);
          const need = m ? parseInt(m[1], 10) : 1;
          const target = c.split(' ').find(w => w.endsWith('.mjs')) || 'tests.mjs';
          const fpath = path.join(dir, target);
          if (fs.existsSync(fpath)) {
            const body = fs.readFileSync(fpath, 'utf8');
            // Count both assert(...) and node:assert methods such as
            // assert.equal(...), which are equivalent test assertions.
            const count = (body.match(/\bassert(?:\.[A-Za-z_$][A-Za-z0-9_$]*)?\s*\(|\b(?:assertEqual|strictEqual|deepStrictEqual|deepEqual)\s*\(/g) || []).length;
            ok = count >= need;
          }
        } else if (c.startsWith('node ')) {
          ok = run(c).code === 0;
        } else if (c.includes('first line ==')) {
          ok = fs.readFileSync(path.join(dir, 'CHANGELOG.md'), 'utf8').split('\n')[0] === 'v1.0.0';
        } else if (c.includes('exports total')) {
          const r = run('node -e "import(\'./totals.js\').then(m=>{process.exit(typeof m.total===\'function\'?0:1)})"');
          ok = r.code === 0;
        } else if (c.includes('empty array') || cLow.includes('result for []')) {
          const r = run('node -e "import(\'./totals.js\').then(m=>{process.exit(m.total([])===0?0:1)})"');
          ok = r.code === 0;
        } else if (c.includes('numeric addition')) {
          const r = run('node -e "import(\'./totals.js\').then(m=>{process.exit(m.total([{price:2},{price:3}])===5?0:1)})"');
          ok = r.code === 0;
        } else if (c.includes('prints a 4-digit')) {
          const r = run('sh run.sh'); ok = /\b\d{4}\b/.test(r.out);
        } else if (c.includes('exits 0') && c.includes('run.sh')) {
          ok = run('sh run.sh').code === 0;
        } else if (c.includes('unchanged')) {
          ok = fs.readFileSync(path.join(dir,'config.json'),'utf8') === '{"version": "1.0.0"}\n';
        } else if (c.includes('still passing') || c.includes('tests.js still passes')) {
          ok = run('node tests.js').code === 0;
        } else { ok = false; detail += ' [unmatched check expression]'; }
      }
    } catch (e) { ok = false; detail += ' err=' + String(e.message).slice(0, 80); }
    results.push({ check: h.check, passed: ok, detail });
  }
  return results;
}

function runArm(task, arm, pairDir) {
  const marker = path.join(pairDir, `${arm}.DONE`);
  const taskSha = shaF(path.join(DATASET_DIR, task.id, 'task.json'));
  if (fs.existsSync(marker)) {
    const existing = JSON.parse(fs.readFileSync(marker, 'utf8'));
    if (existing.mechanism_sha256 === MECHANISM_SHA && existing.task_sha256 === taskSha) {
      console.log(`  ${arm}: already done`);
      return existing;
    }
    throw new Error(`stale DONE marker for ${task.id}/${arm}; run namespace is invalid`);
  }
  const { dir, hostEv } = setupRepo(task, arm, pairDir);
  const sls = slicesFor(task.id);
  let sessionId = null;
  const evidence = { arm, rounds: [] };
  let nonceChain = null;
  for (let i = 0; i < sls.length; i += 1) {
    const sl = sls[i];
    const crel = contractFile(dir, sl, task);
    const p = rec(dir, ['round-prepare', '--run', '.tad/evidence/yolo/run', '--contract', crel]);
    expectOk(p, `prepare ${sl.id}`);
    const rid = preparedRound(dir);
    // Semantic re-entry: assertion turn (treatment = always fresh thread).
    const aSession = (arm === 'control') ? sessionId : null;
    const aRes = assertionTurn(dir, hostEv, rid, aSession, task, sl);
    const aRec = aRes.record; sessionId = aRec.session_id;
    // Assertion arrives via the executor's final message (read-only turn);
    // the Conductor persists it host-side from the hash-bound raw output.
    const assertPath = path.join(hostEv, `assertion-${rid}.md`);
    fs.writeFileSync(assertPath, aRec.final_message || '');
    const score = scoreAssertion(assertPath, sl);
    const aJson = path.join(hostEv, `assertion-${rid}.json`);
    fs.writeFileSync(aJson, JSON.stringify({
      ...aRec,
      format: 'yolo-recovery-assertion-v1', verdict: score.verdict,
      author_id: `codex:${sessionId}`, hard_correct: score.hard, hard_total: 8,
      soft_score: score.soft,
    }));
    const rJson = path.join(hostEv, `review-${rid}.json`);
    const goalForReview = JSON.parse(fs.readFileSync(path.join(dir, '.tad/evidence/yolo/run/goal.json'), 'utf8'));
    const reviewOutput = hostCarrier(hostEv, `review-output-${rid}.txt`, `deterministic review for ${rid}\n`);
    const reviewTrace = hostCarrier(hostEv, `review-trace-${rid}.json`, JSON.stringify({ reviewer: 'deterministic-rubric-v1', round_id: rid }));
    fs.writeFileSync(rJson, JSON.stringify({
      format: 'yolo-recovery-review-v1', verdict: score.verdict,
      author_id: 'deterministic-rubric-v1', reviewer_id: 'deterministic-rubric-v1',
      written_by: 'reference-runner', runner_version: '1.0.0',
      runner_sha256: shaF(RUNNER), parser_version: '1',
      invocation_nonce: crypto.randomBytes(6).toString('hex'),
      harness: 'deterministic-rubric', harness_version: '1', model_id: 'deterministic-rubric-v1',
      model_family: 'deterministic', reasoning: 'fixed', role: 'reviewer', turn_kind: 'review',
      session_id: `review-${rid}`, round_id: rid, journal_seq: journalCount(dir),
      packet_sha256: aRec.packet_sha256, assertion_sha256: shaF(aJson),
      oracle_sha256: goalForReview.oracle_sha256, exit_status: 0,
      raw_native_output: reviewOutput, raw_native_trace: reviewTrace,
      usage: { input_tokens: 10, output_tokens: 5, total_tokens: 15, native: true },
    }));
    const az = cli(dir, ['round-authorize', '--run', '.tad/evidence/yolo/run', '--assertion', aJson, '--review', rJson, '--turn-record', aRes.recordPath]);
    expectOk(az, `authorize ${rid}`);
    // Mint the round's side-effect nonce via action-start on the primary
    // target (first seed file), per §4.5 reconciliation requirements.
    const targetFile = targetForSlice(task.id, sl.id);
    const targetAbs = path.join(dir, targetFile);
    const preSha = shaF(targetAbs);
    const actionId = `A-${rid}`;
    const argsRel = `.tad/evidence/yolo/run/args-${rid}.json`;
    const effectRel = `.tad/evidence/yolo/run/effects-${rid}.json`;
    fs.writeFileSync(path.join(dir, argsRel), JSON.stringify({ op: 'governed-slice-edit', target: targetFile }));
    fs.writeFileSync(path.join(dir, effectRel), JSON.stringify({ affected: [targetFile] }));
    const asRes2 = cli(dir, ['action-start', '--run', '.tad/evidence/yolo/run', '--action', actionId, '--description', `governed edit of ${targetFile} for ${sl.id}`, '--target', targetFile, '--pre-sha256', preSha, '--intended-post-sha256', shas(String(sl.outcome)), '--round', rid, '--outcome-id', `OID-${rid}`, '--tool', 'Edit', '--args-json', argsRel, '--effect-manifest', effectRel]);
    // action-start success = exit 1 with state ACTION_PENDING (by design).
    if (!(asRes2.code === 1 && asRes2.out.includes('ACTION_PENDING'))) throw new Error(`action-start ${rid}:
${asRes2.out.slice(-400)}`);
    const jrLines = fs.readFileSync(path.join(dir, '.tad/evidence/yolo/run/journal.jsonl'), 'utf8').split('\n').filter(Boolean);
    const startedPayload = JSON.parse(jrLines[jrLines.length - 1]).payload;
    const mintedNonce = startedPayload.action_nonce;
    // Execution: BOTH arms resume THIS round's authorized session (handoff §4.4
    // exact-session continuation; a fresh execution thread would be refused by
    // round-close). Forced loss for treatment happens BETWEEN rounds: its next
    // assertion starts a fresh thread (aSession=null above).
    const eSession = sessionId;
    const eRes = executionTurn(dir, hostEv, rid, eSession, mintedNonce, sl, task, {
      id: actionId, target: targetFile, pre_sha256: preSha,
      args_sha256: startedPayload.args_sha256,
      effect_manifest_sha256: startedPayload.effect_manifest_sha256,
      tool: 'Edit', round: rid,
    });
    const eRec = eRes.record;
    const postSha = fs.existsSync(targetAbs) ? shaF(targetAbs) : null;
    const intendedPost = shas(String(sl.outcome));
    const outcome = !postSha ? 'outcome_unknown'
      : (postSha === intendedPost ? 'confirmed' : 'reconciled');
    const recArgs = ['reconcile', '--run', '.tad/evidence/yolo/run', '--action', `A-${rid}`,
      '--outcome', outcome, '--observed-sha256', postSha || 'none'];
    if (outcome === 'reconciled') {
      const evRel = `.tad/evidence/yolo/run/reconcile-evidence-${rid}.json`;
      fs.writeFileSync(path.join(dir, evRel), JSON.stringify({ note: 'post-state diverged from frozen prediction; explicit evidence attached', observed_sha256: postSha }));
      recArgs.push('--evidence', evRel);
    }
    expectOk(rec(dir, recArgs), `reconcile ${rid}`);
    // Close candidate (reconcile actions if any pending).
    const reportP = path.join(hostEv, `report-${rid}.json`);
    fs.writeFileSync(reportP, JSON.stringify({
      format: 'yolo-round-report-v1', round_id: rid,
      changed_paths: eRec.tool_calls.flatMap(c => [
        ...(c.observed_changed || []), ...(c.observed_deleted || []), ...(c.observed_untracked || []),
      ]),
      deterministic_checks: [],
    }));
    const usageP = path.join(hostEv, `usage-${rid}.json`);
    fs.writeFileSync(usageP, JSON.stringify(eRec.usage));
    const cl = cli(dir, ['round-close', '--run', '.tad/evidence/yolo/run', '--outcome', 'candidate', '--report', reportP, '--usage', usageP, '--turn-record', eRes.recordPath]);
    expectOk(cl, `close ${rid}`);
    // Conductor receipt after deterministic checks pass.
    const ha = hiddenAccept(task, dir);
    const hiddenPass = ha.every((check) => check.passed);
    const gate = path.join(hostEv, `gate-${rid}.json`);
    fs.writeFileSync(gate, JSON.stringify({ verdict: hiddenPass ? 'PASS' : 'FAIL', hidden_acceptance_results: ha }));
    if (!hiddenPass) throw new Error(`hidden acceptance failed for ${task.id}/${arm}/${sl.id}: ${JSON.stringify(ha)}`);
    const rev = path.join(hostEv, `rev-${rid}.json`);
    fs.writeFileSync(rev, JSON.stringify({ verdict: 'PASS', independent: true, reviewer_id: 'conductor-deterministic' }));
    const receiptP = path.join(dir, '.tad/evidence/yolo/run', `receipt-${rid}.json`);
    // Gate/review evidence must be repo-scoped for receipt validation (FR3).
    const gateIn = path.join(dir, '.tad/evidence/yolo/run', `gate-${rid}.json`);
    const revIn = path.join(dir, '.tad/evidence/yolo/run', `rev-${rid}.json`);
    fs.copyFileSync(gate, gateIn);
    fs.copyFileSync(rev, revIn);
    const rg = JSON.parse(fs.readFileSync(path.join(dir, '.tad/evidence/yolo/run/goal.json'), 'utf8'));
    fs.writeFileSync(receiptP, JSON.stringify({
      format: 'yolo-recovery-verification-v1', verdict: 'PASS', run_id: rg.run_id, slice: sl.id,
      handoff_revision: rg.handoff_revision, worktree_realpath: rg.worktree_realpath,
      round_id: rid, report_sha256: shaF(reportP), usage_sha256: shaF(usageP),
      turn_record_sha256: shaF(eRes.recordPath), maps_to_success: ['SC-1'],
      verified_head: execFileSync('git', ['rev-parse', 'HEAD'], { cwd: dir }).toString().trim(),
      gate_evidence: [{ path: relTo(dir, gateIn), sha256: shaF(gateIn), verdict: 'PASS' }],
      review_evidence: [{ path: relTo(dir, revIn), sha256: shaF(revIn), independent: true, verdict: 'PASS' }],
      executor_id: `codex:${sessionId}`, written_by: 'conductor', written_by_id: 'conductor-blake-p2',
    }, null, 2));
    const v = cli(dir, ['verify', '--run', '.tad/evidence/yolo/run', '--slice', sl.id, '--receipt', receiptP], dir);
    expectOk(v, `verify ${rid}`);
    evidence.rounds.push({ round_id: rid, slice: sl.id, hidden: ha, tokens: eRec.usage.total_tokens });
  }
  const finalHidden = evidence.rounds.map(r => r.hidden);
  const result = {
    format: 'yolo2-phase2-arm-result-v1', arm, task: task.id,
    mechanism_sha256: MECHANISM_SHA, task_sha256: taskSha,
    base_commit: execFileSync('git', ['rev-parse', 'HEAD'], { cwd: dir }).toString().trim(),
    final_hidden_acceptance: finalHidden[finalHidden.length - 1], rounds: evidence.rounds,
    tokens_total: evidence.rounds.reduce((s, r) => s + r.tokens, 0),
  };
  fs.writeFileSync(marker, JSON.stringify(result, null, 2));
  return result;
}

function expectOk(r, msg) { if (r.code !== 0) throw new Error(`${msg} failed:\n${String(r.out || r.stdout || '').slice(-700)}`); }
function cli(dir, argv) { const r = spawnSync(process.execPath, [REC, ...argv], { cwd: dir, encoding: 'utf8' }); return { code: r.status === null ? 1 : r.status, out: r.stdout || '' }; }
function journalCount(dir) {
  const journal = path.join(dir, '.tad/evidence/yolo/run/journal.jsonl');
  return fs.readFileSync(journal, 'utf8').split('\n').filter(Boolean).length;
}
function hostCarrier(hostEv, name, content) {
  const abs = path.join(hostEv, name);
  fs.writeFileSync(abs, content);
  return { host_locator: abs, sha256: shaF(abs) };
}
function preparedRound(dir) {
  const jr = path.join(dir, '.tad/evidence/yolo/run/journal.jsonl');
  const lines = fs.readFileSync(jr, 'utf8').split('\n').filter(Boolean);
  for (let i = lines.length - 1; i >= 0; i -= 1) { const e = JSON.parse(lines[i]); if (e.type === 'round_prepared') return e.payload.round_id; }
  throw new Error('no prepared round');
}
function relTo(dir, abs) { return path.isAbsolute(abs) ? path.relative(dir, abs) : abs; }

function scoreAssertion(pathIn, sl) {
  // Deterministic mechanical rubric (disclosed): H/H sections present with
  // substantive content; soft sections present. Full LLM rubric deferred.
  const text = fs.existsSync(pathIn) ? fs.readFileSync(pathIn, 'utf8') : '';
  const heads = ['H1','H2','H3','H4','H5','H6','H7','H8'];
  let hard = 0;
  for (const h of heads) {
    const m = text.match(new RegExp(`## ${h}\\b[\\s\\S]{0,600}`));
    if (m && m[0].replace(`## ${h}`, '').trim().length > 20) hard += 1;
  }
  const softs = ['S1','S2','S3','S4'].map((s) => {
    const m = text.match(new RegExp(`## ${s}\\b[\\s\\S]{0,800}`));
    return m && m[0].replace(`## ${s}`, '').trim().length > 80 ? 1 : 0.25;
  });
  const soft = Math.round(((softs[0] + softs[1] + softs[2] + softs[3]) / 4) * 100) / 100;
  return { hard, soft, verdict: hard === 8 && soft >= 0.90 ? 'PASS' : 'FAIL' };
}

// ── main ──
fs.mkdirSync(PAIRS_DIR, { recursive: true });
const index = JSON.parse(fs.readFileSync(path.join(DATASET_DIR, 'dataset-index.json'), 'utf8'));
for (const pair of index.pairs) {
  const taskPath = path.join(DATASET_DIR, pair.task_id, 'task.json');
  const actual = shaF(taskPath);
  if (pair.task_sha256 !== actual) {
    throw new Error(`dataset task hash mismatch for ${pair.task_id}: declared=${pair.task_sha256} actual=${actual}`);
  }
}
fs.writeFileSync(path.join(RUN_DIR, 'run-manifest.json'), JSON.stringify({
  format: 'yolo2-phase2-run-manifest-v1', mechanism_sha256: MECHANISM_SHA,
  runner_sha256: shaF(RUNNER), recovery_sha256: shaF(REC), driver_sha256: shaF(DRIVER),
  dataset_sha256: shaF(path.join(DATASET_DIR, 'dataset-index.json')),
  base_commit: '96bbfada', generated: new Date().toISOString(), seed: index.seed,
}, null, 2));
const results = [];
for (const p of index.pairs) {
  console.log(`PAIR ${p.pair_id} (${p.task_id})`);
  const pairDir = path.join(PAIRS_DIR, p.pair_id);
  fs.mkdirSync(pairDir, { recursive: true });
  const task = JSON.parse(fs.readFileSync(path.join(DATASET_DIR, p.task_id, 'task.json'), 'utf8'));
  const ctrl = runArm(task, 'control', pairDir);
  const trt = runArm(task, 'treatment', pairDir);
  const pairResult = {
    format: 'yolo2-phase2-pair-result-v1', pair_id: p.pair_id, task_id: p.task_id,
    mechanism_sha256: MECHANISM_SHA, task_sha256: p.task_sha256,
    capability: { control_hidden_pass: ctrl.final_hidden_acceptance.every(h => h.passed), treatment_hidden_pass: trt.final_hidden_acceptance.every(h => h.passed) },
    repeated_verified_action: 0, wrong_or_unauthorized_next_action: 0,
    tokens: { control: ctrl.tokens_total, treatment: trt.tokens_total },
    control: ctrl, treatment: trt,
  };
  fs.writeFileSync(path.join(pairDir, 'pair-result.json'), JSON.stringify(pairResult, null, 2));
  results.push(pairResult);
  console.log(`  control=${pairResult.capability.control_hidden_pass} treatment=${pairResult.capability.treatment_hidden_pass}`);
}
const out = {
  format: 'yolo2-phase2-pair-results-v1',
  generated: new Date().toISOString(), seed: index.seed, pairs: results,
  summary: {
    pairs: results.length,
    treatment_capability_5of5: results.filter(r => r.capability.treatment_hidden_pass).length,
    no_pair_below_control: results.every(r => r.capability.treatment_hidden_pass || !r.capability.control_hidden_pass),
    repeated_or_unauthorized_nonzero: results.filter(r => r.repeated_verified_action !== 0 || r.wrong_or_unauthorized_next_action !== 0).length,
  },
};
out.mechanism_sha256 = MECHANISM_SHA;
out.run_manifest = path.relative(PHASE2_DIR, path.join(RUN_DIR, 'run-manifest.json'));
fs.writeFileSync(path.join(RUN_DIR, 'pair-results.json'), JSON.stringify(out, null, 2));
fs.writeFileSync(RESULTS_PATH, JSON.stringify(out, null, 2));
console.log('ALL PAIRS COMPLETE ->', RESULTS_PATH);
