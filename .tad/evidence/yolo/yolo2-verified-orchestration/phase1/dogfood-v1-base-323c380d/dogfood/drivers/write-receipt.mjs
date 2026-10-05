#!/usr/bin/env node
/**
 * write-receipt.mjs <worktree> <slice> <gate-rel> <review-rel> <executor-id> <out-rel>
 * Conductor-side receipt writer. Run ONLY after the slice Gate and an
 * independent review have both returned PASS. Paths are worktree-relative.
 */
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const [wt, slice, gateRel, reviewRel, executorId, outRel] = process.argv.slice(2);
const REL = '.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood';
const goal = JSON.parse(fs.readFileSync(path.join(wt, REL, 'run/goal.json'), 'utf8'));
const sha = (rel) => crypto.createHash('sha256').update(fs.readFileSync(path.join(wt, rel))).digest('hex');
const head = execFileSync('git', ['rev-parse', 'HEAD'], { cwd: wt, encoding: 'utf8' }).trim();

const receipt = {
  format: 'yolo-recovery-verification-v1',
  verdict: 'PASS',
  run_id: goal.run_id,
  slice,
  handoff_revision: goal.handoff_revision,
  worktree_realpath: goal.worktree_realpath,
  verified_head: head,
  gate_evidence: [{ path: gateRel, sha256: sha(gateRel), verdict: 'PASS' }],
  review_evidence: [{ path: reviewRel, sha256: sha(reviewRel), independent: true, verdict: 'PASS' }],
  executor_id: executorId,
  written_by: 'conductor',
  written_by_id: 'conductor-blake-t2',
};
fs.mkdirSync(path.dirname(path.join(wt, outRel)), { recursive: true });
fs.writeFileSync(path.join(wt, outRel), JSON.stringify(receipt, null, 2) + '\n');
console.log(outRel);
