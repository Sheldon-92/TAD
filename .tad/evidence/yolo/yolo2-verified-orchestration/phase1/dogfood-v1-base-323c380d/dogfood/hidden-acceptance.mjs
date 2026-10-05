#!/usr/bin/env node
/**
 * HIDDEN acceptance for the Phase 1 dogfood guide-maintenance task.
 * Frozen before any run; never copied into a treatment/control worktree and
 * never shown to an executing or recovering context.
 *
 *   node hidden-acceptance.mjs <worktree> <base-commit>
 *
 * exit 0 = PASS, 1 = FAIL. Prints one line per check.
 */
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const [wt, base] = process.argv.slice(2);
if (!wt || !base) { console.log('usage: hidden-acceptance.mjs <worktree> <base-commit>'); process.exit(1); }

const guidePath = path.join(wt, '.tad/guides/yolo-recovery.md');
const cliPath = path.join(wt, '.tad/scripts/yolo-recovery.mjs');
const results = [];
const check = (name, ok, detail = '') => { results.push({ name, ok, detail }); };

if (!fs.existsSync(guidePath)) {
  console.log('FAIL guide-exists');
  process.exit(1);
}
const guide = fs.readFileSync(guidePath, 'utf8');
const cli = fs.readFileSync(cliPath, 'utf8');

// 1. the three required sections, with exact headings
const H10 = '## 10. Command Reference';
const H11 = '## 11. Troubleshooting';
const H12 = '## 12. Worked Example';
check('s1-heading', guide.includes(H10));
check('s2-heading', guide.includes(H11));
check('s3-heading', guide.includes(H12));

function sectionOf(startMarker, endMarkers) {
  const i = guide.indexOf(startMarker);
  if (i < 0) return '';
  let end = guide.length;
  for (const m of endMarkers) {
    const j = guide.indexOf(m, i + startMarker.length);
    if (j >= 0 && j < end) end = j;
  }
  return guide.slice(i, end);
}
const sec10 = sectionOf(H10, [H11, H12]);
const sec11 = sectionOf(H11, [H12]);
const sec12 = sectionOf(H12, []);

// 2. every command is documented in the command reference
const COMMANDS = ['init', 'status', 'checkpoint', 'verify', 'action-start', 'reconcile', 'resume', 'stop'];
const missingCmds = COMMANDS.filter((c) => !sec10.includes(c));
check('s1-all-commands', missingCmds.length === 0, `missing: ${missingCmds.join(',')}`);
check('s1-exit-codes', /\b0\b/.test(sec10) && /\b1\b/.test(sec10) && /\b2\b/.test(sec10));

// 3. troubleshooting quotes REAL reason strings that exist in the CLI source
const realReasons = new Set();
for (const m of cli.matchAll(/(?:Contract|Usage)Error\('([a-z0-9_]+)'/g)) realReasons.add(m[1]);
const quoted = new Set();
for (const m of sec11.matchAll(/\b([a-z][a-z0-9]*(?:_[a-z0-9]+)+)\b/g)) {
  if (realReasons.has(m[1])) quoted.add(m[1]);
}
// "Invented" means the token appears NOWHERE in the CLI source. Field names,
// enum values and reason strings are all legitimate to quote; a token the
// source never defines is fabrication. (v2, see instrument-amendments.md.)
const invented = new Set();
for (const m of sec11.matchAll(/`([a-z][a-z0-9]*(?:_[a-z0-9]+)+)`/g)) {
  if (!cli.includes(m[1])) invented.add(m[1]);
}
check('s2-real-reasons', quoted.size >= 8, `found ${quoted.size} real reason strings (need >=8)`);
check('s2-no-invented-reasons', invented.size === 0, `invented: ${[...invented].join(',')}`);

// 4. worked example is actually a transcript
check('s3-transcript', ['init', 'checkpoint', 'verify', 'resume'].every((c) => sec12.includes(c)));

// 5. existing content preserved (the load-bearing warning must survive)
check('preserved-warning', guide.includes('written_by_id != executor_id')
  && guide.includes('process-integrity boundary'));
check('preserved-authority-order', guide.includes('Authority order'));
check('no-truncation', guide.length > 9000, `guide length ${guide.length}`);

// 6. balanced code fences
const fences = (guide.match(/^```/gm) || []).length;
check('balanced-fences', fences % 2 === 0, `${fences} fence lines`);

// 7. scope: only the guide changed since the frozen base commit
let changed = [];
try {
  changed = execFileSync('git', ['diff', '--name-only', base], { cwd: wt, encoding: 'utf8' })
    .split('\n').filter(Boolean);
} catch (err) { changed = ['<git failed>']; }
const offScope = changed.filter((p) => p !== '.tad/guides/yolo-recovery.md' && !p.startsWith('.tad/evidence/'));
check('scope-respected', offScope.length === 0, `off-scope: ${offScope.join(',')}`);

let failed = 0;
for (const r of results) {
  if (!r.ok) failed += 1;
  console.log(`${r.ok ? 'PASS' : 'FAIL'} ${r.name}${r.detail ? '  — ' + r.detail : ''}`);
}
console.log(`HIDDEN_ACCEPTANCE=${failed === 0 ? 'PASS' : 'FAIL'} (${results.length - failed}/${results.length})`);
process.exit(failed === 0 ? 0 : 1);
