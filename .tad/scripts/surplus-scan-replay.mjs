#!/usr/bin/env node
// surplus-scan-replay.mjs — Phase 4 scan-surface replay harness (HANDOFF-20261101-scan-surface §4.4).
//
// Consumes the Rank classification logic VERBATIM from the live workflow: the
// classify-block between the BEGIN/END markers in surplus-scan.workflow.js is
// extracted byte-for-byte, its sha256 is reconciled against the corpus anchor,
// and it is evaluated in an empty node:vm context (the block is dependency-free
// by design, §4.2). No parallel copy of the logic exists anywhere — drift
// between the workflow and this harness is impossible by construction, and any
// edit to the block that is not re-anchored here fails closed.
//
// Usage: node .tad/scripts/surplus-scan-replay.mjs [fixtureDir] [--workflow <path>]
// Defaults: fixtureDir=.tad/scripts/fixtures/surplus-scan-replay
//           workflow=.tad/workflows/claude/surplus-scan.workflow.js
// Exit: 0 = every corpus row matches expected; 1 = mismatches (FAIL line);
//       2 = extraction/integrity failure (EXTRACT-FAIL line, fail-closed).

import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import crypto from 'node:crypto';

const args = process.argv.slice(2);
let fixtureDir = '.tad/scripts/fixtures/surplus-scan-replay';
let workflowPath = '.tad/workflows/claude/surplus-scan.workflow.js';
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--workflow') { workflowPath = args[++i]; }
  else if (!args[i].startsWith('--')) { fixtureDir = args[i]; }
}

function extractFail(why) {
  if (why) process.stderr.write('surplus-scan-replay: ' + why + '\n');
  console.log('REPLAY-RESULT: EXTRACT-FAIL');
  process.exit(2);
}

let corpus, expected, workflowText;
try {
  corpus = JSON.parse(fs.readFileSync(path.join(fixtureDir, 'corpus.json'), 'utf8'));
  expected = JSON.parse(fs.readFileSync(path.join(fixtureDir, 'expected.json'), 'utf8'));
  workflowText = fs.readFileSync(workflowPath, 'utf8');
} catch (e) {
  extractFail('cannot read corpus/expected/workflow: ' + e.message);
}

const lines = workflowText.split('\n');
const beginIdx = lines.findIndex(l => l.startsWith('// === classify-block BEGIN'));
const endIdx = lines.findIndex(l => l.startsWith('// === classify-block END'));
if (beginIdx === -1 || endIdx === -1 || endIdx <= beginIdx) {
  extractFail('classify-block markers missing or malformed in ' + workflowPath);
}
const blockText = lines.slice(beginIdx, endIdx + 1).join('\n');
const blockSha = crypto.createHash('sha256').update(blockText, 'utf8').digest('hex');
if (blockSha !== corpus.classify_block_sha256) {
  extractFail('classify-block sha256 ' + blockSha + ' != corpus anchor ' + corpus.classify_block_sha256);
}

let classifyCandidate;
try {
  const ctx = vm.createContext(Object.create(null));
  vm.runInContext(blockText, ctx);
  classifyCandidate = vm.runInContext('classifyCandidate', ctx);
} catch (e) {
  extractFail('classify-block evaluation failed: ' + e.message);
}
if (typeof classifyCandidate !== 'function') {
  extractFail('classifyCandidate is not a function after extraction');
}

const expectedById = {};
for (const row of expected.rows || []) expectedById[row.id] = row;

let mismatches = 0;
for (const row of corpus.rows || []) {
  const exp = expectedById[row.id];
  let got = null, err = null;
  try { got = classifyCandidate(row); } catch (e) { err = e; }
  const problems = [];
  if (!exp) problems.push('no expected row for id');
  else if (err) problems.push('classifyCandidate threw: ' + err.message);
  else {
    if (got.disposition !== exp.disposition) problems.push('disposition');
    if (Object.prototype.hasOwnProperty.call(exp, 'auto_eligible') && got.auto_eligible !== exp.auto_eligible) problems.push('auto_eligible expected=' + exp.auto_eligible + ' got=' + got.auto_eligible);
    if (Object.prototype.hasOwnProperty.call(exp, 'status_unknown') && got.status_unknown !== exp.status_unknown) problems.push('status_unknown expected=' + exp.status_unknown + ' got=' + got.status_unknown);
    for (const r of exp.reasons_contains || []) if (!got.reasons.includes(r)) problems.push('reasons missing ' + r);
    for (const r of exp.reasons_not_contains || []) if (got.reasons.includes(r)) problems.push('reasons unexpected ' + r);
  }
  const gotDisp = got ? got.disposition : 'ERROR';
  const expDisp = exp ? exp.disposition : 'NONE';
  if (problems.length) {
    mismatches++;
    console.log('ROW ' + row.id + ' expected=' + expDisp + ' got=' + gotDisp + ' MISMATCH ' + problems.join('; '));
  } else {
    console.log('ROW ' + row.id + ' expected=' + expDisp + ' got=' + gotDisp + ' OK');
  }
}

const total = (corpus.rows || []).length;
if (mismatches) {
  console.log('REPLAY-RESULT: FAIL rows=' + total + ' mismatches=' + mismatches);
  process.exit(1);
}
console.log('REPLAY-RESULT: PASS rows=' + total);
process.exit(0);
