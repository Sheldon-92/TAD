#!/usr/bin/env node
/**
 * slice-check.mjs <worktree> <S1|S2|S3>
 * Deterministic per-slice Gate for the dogfood guide-maintenance task.
 * Lives only in the main repo; never copied into a run worktree.
 * exit 0 = PASS, 1 = FAIL. Its stdout is the gate evidence file.
 */
import fs from 'node:fs';
import path from 'node:path';

const [wt, slice] = process.argv.slice(2);
const guide = fs.readFileSync(path.join(wt, '.tad/guides/yolo-recovery.md'), 'utf8');
const cli = fs.readFileSync(path.join(wt, '.tad/scripts/yolo-recovery.mjs'), 'utf8');
const COMMANDS = ['init', 'status', 'checkpoint', 'verify', 'action-start', 'reconcile', 'resume', 'stop'];

const H = { S1: '## 10. Command Reference', S2: '## 11. Troubleshooting', S3: '## 12. Worked Example' };
const NEXT = { S1: ['## 11. Troubleshooting', '## 12. Worked Example'], S2: ['## 12. Worked Example'], S3: [] };

function section(marker, ends) {
  const i = guide.indexOf(marker);
  if (i < 0) return null;
  let end = guide.length;
  for (const m of ends) { const j = guide.indexOf(m, i + marker.length); if (j >= 0 && j < end) end = j; }
  return guide.slice(i, end);
}

const out = [];
let failed = 0;
const check = (name, ok, detail = '') => { if (!ok) failed += 1; out.push(`${ok ? 'PASS' : 'FAIL'} ${name}${detail ? '  — ' + detail : ''}`); };

const sec = section(H[slice], NEXT[slice]);
check(`${slice}-heading-present`, sec !== null, `expected heading "${H[slice]}"`);

if (sec) {
  if (slice === 'S1') {
    const missing = COMMANDS.filter((c) => !sec.includes(c));
    check('S1-documents-every-command', missing.length === 0, `missing: ${missing.join(',')}`);
    check('S1-has-table', /\|.*\|/.test(sec) && /---/.test(sec));
    check('S1-mentions-exit-codes', /\b0\b/.test(sec) && /\b1\b/.test(sec) && /\b2\b/.test(sec));
  } else if (slice === 'S2') {
    const real = new Set();
    for (const m of cli.matchAll(/(?:Contract|Usage)Error\('([a-z0-9_]+)'/g)) real.add(m[1]);
    const quoted = new Set();
    for (const m of sec.matchAll(/\b([a-z][a-z0-9]*(?:_[a-z0-9]+)+)\b/g)) if (real.has(m[1])) quoted.add(m[1]);
    // "Invented" means the token appears NOWHERE in the CLI source. Field names,
    // enum values and reason strings are all legitimate to quote; a token the
    // source never defines is fabrication. (v2, see instrument-amendments.md.)
    const invented = new Set();
    for (const m of sec.matchAll(/`([a-z][a-z0-9]*(?:_[a-z0-9]+)+)`/g)) if (!cli.includes(m[1])) invented.add(m[1]);
    check('S2-quotes-real-reasons', quoted.size >= 8, `${quoted.size} real reason strings`);
    check('S2-invents-nothing', invented.size === 0, `invented: ${[...invented].join(',')}`);
    check('S2-has-table', /\|.*\|/.test(sec) && /---/.test(sec));
  } else {
    check('S3-is-a-transcript', ['init', 'checkpoint', 'verify', 'resume'].every((c) => sec.includes(c)));
    check('S3-has-code-fence', /```/.test(sec));
  }
}
check('existing-content-preserved', guide.includes('written_by_id != executor_id') && guide.includes('Authority order'));

console.log(`# Gate evidence — slice ${slice} — worktree ${wt}`);
console.log(out.join('\n'));
console.log(`GATE_VERDICT=${failed === 0 ? 'PASS' : 'FAIL'} (${out.length - failed}/${out.length})`);
process.exit(failed === 0 ? 0 : 1);
