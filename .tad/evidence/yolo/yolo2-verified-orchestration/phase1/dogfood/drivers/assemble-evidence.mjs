#!/usr/bin/env node
/**
 * assemble-evidence.mjs <dogfood-dir>
 *
 * Builds the machine-readable dogfood evidence from artifacts already on disk:
 *   <dogfood>/<id>/meta.json      (conductor-supplied identities + stage)
 *   <dogfood>/<id>/assertion.md   (written by the fresh recovering context)
 *   <dogfood>/<id>/review.md      (written by the independent reviewer)
 *   <dogfood>/<id>/continuation.md
 *   <dogfood>/<id>/gate.md
 *   <dogfood>/<id>/receipt.json
 *   <dogfood>/<id>/fresh-prompt.txt
 *   <dogfood>/<id>/run/           (archived copy of the live run directory)
 *   <dogfood>/oracle-<id>.md      (frozen before the run, never in a worktree)
 *
 * Scores are PARSED OUT OF the raw review markdown, never supplied by hand, so
 * the index cannot disagree with the report it points at.
 * Emits <id>/run-evidence.json, control/control-evidence.json and
 * recovery-scores.json.
 */
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const dog = path.resolve(process.argv[2] || '.');
const IDS = ['interruption-a', 'interruption-b', 'interruption-c'];

const ref = (rel) => {
  const abs = path.join(dog, rel);
  if (!fs.existsSync(abs)) throw new Error(`missing artifact: ${rel}`);
  return { path: rel, sha256: crypto.createHash('sha256').update(fs.readFileSync(abs)).digest('hex') };
};
// A run that honestly stopped has no continuation/gate/receipt. Record the
// absence as null rather than inventing an artifact; the Gate-3 checker then
// fails on that run for the true reason instead of on a missing file.
const refOrNull = (rel) => (fs.existsSync(path.join(dog, rel)) ? ref(rel) : null);
const readMeta = (id) => JSON.parse(fs.readFileSync(path.join(dog, id, 'meta.json'), 'utf8'));

function parseReview(id) {
  const text = fs.readFileSync(path.join(dog, id, 'review.md'), 'utf8');
  const grab = (re, label) => {
    const m = text.match(re);
    if (!m) throw new Error(`${id}/review.md: cannot parse ${label}`);
    return m[1];
  };
  return {
    hard_correct: Number(grab(/hard_correct:\s*(\d+)/i, 'hard_correct')),
    hard_total: Number(grab(/hard_total:\s*(\d+)/i, 'hard_total')),
    soft_score: Number(grab(/soft_score:\s*([0-9.]+)/i, 'soft_score')),
    verdict: grab(/verdict:\s*(PASS|FAIL)/i, 'verdict').toUpperCase(),
    assertion_sha256: grab(/assertion_sha256:\s*([0-9a-f]{64})/i, 'assertion_sha256'),
    oracle_sha256: grab(/oracle_sha256:\s*([0-9a-f]{64})/i, 'oracle_sha256'),
  };
}

function gateVerdict(id) {
  const abs = path.join(dog, id, 'gate.md');
  if (!fs.existsSync(abs)) return 'ABSENT';
  const text = fs.readFileSync(abs, 'utf8');
  const m = text.match(/GATE_VERDICT:\s*(PASS|FAIL)/i);
  if (!m) throw new Error(`${id}/gate.md: no GATE_VERDICT anchor`);
  return m[1].toUpperCase();
}

const runs = IDS.map((id) => {
  const meta = readMeta(id);
  const rv = parseReview(id);
  const assertion = ref(`${id}/assertion.md`);
  const oracle = ref(`oracle-${id}.md`);
  const review = ref(`${id}/review.md`);
  const continuation = refOrNull(`${id}/continuation.md`);
  const gate = refOrNull(`${id}/gate.md`);
  const receipt = refOrNull(`${id}/receipt.json`);
  const prompt = ref(`${id}/fresh-prompt.txt`);
  if (rv.assertion_sha256 !== assertion.sha256) {
    throw new Error(`${id}: reviewer quoted assertion sha ${rv.assertion_sha256.slice(0, 12)} but the file hashes to ${assertion.sha256.slice(0, 12)}`);
  }
  if (rv.oracle_sha256 !== oracle.sha256) {
    throw new Error(`${id}: reviewer quoted oracle sha ${rv.oracle_sha256.slice(0, 12)} but the file hashes to ${oracle.sha256.slice(0, 12)}`);
  }
  const env = {
    format: 'yolo-recovery-dogfood-evidence-v1',
    run_id: id,
    interruption_stage: meta.interruption_stage,
    base_commit: meta.base_commit,
    input_sha256: meta.input_sha256,
    worktree_realpath: meta.worktree_realpath,
    fresh_session: {
      session_id: meta.session_id,
      prior_transcript_provided: false,
      prompt_path: prompt.path,
      prompt_sha256: prompt.sha256,
    },
    assertion: { ...assertion, author_id: meta.assertion_author_id },
    oracle: { ...oracle, frozen_before_run: true },
    review: {
      ...review,
      author_id: meta.review_author_id,
      independent: true,
      assertion_sha256: assertion.sha256,
      oracle_sha256: oracle.sha256,
      hard_total: rv.hard_total,
      hard_correct: rv.hard_correct,
      soft_score: rv.soft_score,
      verdict: rv.verdict,
    },
    continuation: continuation ? { ...continuation, repeated_verified_slice: meta.repeated_verified_slice } : null,
    gate: gate ? { ...gate, verdict: gateVerdict(id) } : null,
    receipt,
  };
  fs.writeFileSync(path.join(dog, id, 'run-evidence.json'), JSON.stringify(env, null, 2) + '\n');
  const envRef = ref(`${id}/run-evidence.json`);
  return {
    id,
    interruption_stage: meta.interruption_stage,
    run_dir: `${id}/run`,
    base_commit: meta.base_commit,
    input_sha256: meta.input_sha256,
    worktree_realpath: meta.worktree_realpath,
    assertion, oracle, continuation,
    gate: gate ? { ...gate, verdict: env.gate.verdict } : null,
    receipt,
    evidence_envelope: envRef,
    hard_total: rv.hard_total,
    hard_correct: rv.hard_correct,
    soft_score: rv.soft_score,
    wrong_or_unauthorized_next_action: meta.wrong_or_unauthorized_next_action,
    repeated_verified_slice: meta.repeated_verified_slice,
    continued: meta.continued,
    hidden_acceptance_passed: meta.hidden_acceptance_passed,
    gate_passed: !!env.gate && env.gate.verdict === 'PASS',
    reviewer: { independent: true, evidence: review.path },
  };
});

const cMeta = readMeta('control');
const cReport = ref('control.md');
const cHidden = ref('control/hidden-acceptance.txt');
const cGate = ref('control/gate.md');
const cEnv = {
  format: 'yolo-recovery-dogfood-evidence-v1',
  run_id: 'control',
  base_commit: cMeta.base_commit,
  input_sha256: cMeta.input_sha256,
  worktree_realpath: cMeta.worktree_realpath,
  report: cReport,
  hidden_acceptance: cHidden,
  gate: { ...cGate, verdict: gateVerdict('control') },
};
fs.writeFileSync(path.join(dog, 'control/control-evidence.json'), JSON.stringify(cEnv, null, 2) + '\n');

const doc = {
  format: 'yolo-recovery-dogfood-scores-v1',
  note: 'Index only. Every claim here must be re-derived from the raw files it points at; see yolo-recovery.test.mjs --case dogfood-evidence.',
  control: {
    base_commit: cMeta.base_commit,
    input_sha256: cMeta.input_sha256,
    worktree_realpath: cMeta.worktree_realpath,
    report: cReport,
    hidden_acceptance: cHidden,
    gate: { ...cGate, verdict: cEnv.gate.verdict },
    evidence_envelope: ref('control/control-evidence.json'),
  },
  runs,
};
fs.writeFileSync(path.join(dog, 'recovery-scores.json'), JSON.stringify(doc, null, 2) + '\n');
console.log('wrote recovery-scores.json');
for (const r of runs) {
  console.log(`  ${r.id}: hard ${r.hard_correct}/${r.hard_total}, soft ${r.soft_score}, gate ${r.gate ? r.gate.verdict : 'ABSENT'}, continued ${r.continued}`);
}
