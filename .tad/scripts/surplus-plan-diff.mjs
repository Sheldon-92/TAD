#!/usr/bin/env node
// surplus-plan-diff.mjs — Phase 4 scan-surface plan diff (HANDOFF-20261101-scan-surface §4.3).
//
// Compares two SURPLUS-PLAN sidecars row by row and prints a markdown
// "qualification flip" alarm section to stdout. The surplus SKILL appends the
// section to the freshly persisted plan (SKILL --plan persist step); this
// script itself writes nothing.
//
// Usage: node .tad/scripts/surplus-plan-diff.mjs <prev.json|NONE> <new.json>
//   prev = the literal NONE, or a missing file  -> no-baseline section, exit 0
//   new missing / either input unparseable     -> stderr note, exit 2
// Compared fields: auto_eligible, risk_tag, status_unknown (a missing
// status_unknown on an older sidecar reads as false). Rows are matched by
// normalized title （规格钉死： lowercase, trim, whitespace runs collapsed —
// the same rule as the workflow's normTitle, independently implemented here).

import fs from 'node:fs';

const [, , prevArg, newArg] = process.argv;

function die(why) {
  process.stderr.write('surplus-plan-diff: ' + why + '\n');
  process.exit(2);
}

if (!prevArg || !newArg) die('usage: surplus-plan-diff.mjs <prev.json|NONE> <new.json>');

function readSidecar(p, role) {
  let text;
  try { text = fs.readFileSync(p, 'utf8'); }
  catch (e) { die(role + ' sidecar unreadable (' + p + '): ' + e.message); }
  try { return JSON.parse(text); }
  catch (e) { die(role + ' sidecar is not valid JSON (' + p + '): ' + e.message); }
}

const newSidecar = readSidecar(newArg, 'new');

function normTitle(t) { return String(t || '').toLowerCase().trim().replace(/\s+/g, ' '); }
function rowsOf(sc) { return (sc && Array.isArray(sc.rows)) ? sc.rows : []; }
function esc(s) { return String(s == null ? '' : s).replace(/\|/g, '\\|').replace(/\n/g, ' '); }
function boolStr(v) { return v === true ? 'true' : 'false'; }

const newRows = rowsOf(newSidecar);

if (prevArg === 'NONE' || !fs.existsSync(prevArg)) {
  console.log('## 资格翻转告警：无上轮基线');
  console.log('flips: 0, added: 0, removed: 0');
  process.exit(0);
}

const prevSidecar = readSidecar(prevArg, 'prev');
const prevRows = rowsOf(prevSidecar);

const prevByKey = new Map();
for (const r of prevRows) prevByKey.set(normTitle(r.title) || normTitle(r.id), r);

const FIELDS = [
  { name: 'auto_eligible', get: r => boolStr(r.auto_eligible) },
  { name: 'risk_tag', get: r => String(r.risk_tag == null ? '' : r.risk_tag) },
  { name: 'status_unknown', get: r => boolStr(r.status_unknown) }
];

let flips = 0, added = 0, removed = 0;
const lines = [];
const seen = new Set();

for (const nr of newRows) {
  const key = normTitle(nr.title) || normTitle(nr.id);
  seen.add(key);
  const pr = prevByKey.get(key);
  if (!pr) {
    added++;
    lines.push('| ' + esc(nr.title) + ' | （新增） | — | — |');
    continue;
  }
  for (const f of FIELDS) {
    const pv = f.get(pr), nv = f.get(nr);
    if (pv !== nv) {
      flips++;
      lines.push('| ' + esc(nr.title) + ' | ' + f.name + ' | ' + pv + ' | ' + nv + ' |');
    }
  }
}
for (const pr of prevRows) {
  const key = normTitle(pr.title) || normTitle(pr.id);
  if (!seen.has(key)) {
    removed++;
    lines.push('| ' + esc(pr.title) + ' | （消失） | — | — |');
  }
}

console.log('## ⚠ 资格翻转告警（vs 上轮）');
console.log('| Task | 字段 | 上轮 | 本轮 |');
console.log('|------|------|------|------|');
for (const l of lines) console.log(l);
console.log('flips: ' + flips + ', added: ' + added + ', removed: ' + removed);
process.exit(0);
