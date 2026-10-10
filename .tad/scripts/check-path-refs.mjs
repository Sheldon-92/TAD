#!/usr/bin/env node
// check-path-refs.mjs - report references to .tad/... and .claude/... paths that do not exist.
//
// Scans the text files listed by `git ls-files`, pulls out every `.tad/...` and `.claude/...` path
// mention, and prints `DANGLING <file>:<line> <ref>` for each one that points at nothing in the
// tracked tree and is not explained by one of the classes below.
//
//   node .tad/scripts/check-path-refs.mjs [--root <dir>] [--list]
//
// Exit: 0 = no un-allowed dangling reference, 1 = at least one, 2 = usage or environment error
// (bad option, --root missing, not inside a git repository).
// --list also prints every classified reference as `<class>\t<file>:<line>\t<ref>`.
//
// Existence is judged against git's file list, never the file system: this checkout has untracked and
// ignored local files (an untracked .claude/, ignored evidence), and a result that depends on them
// cannot be reproduced in a clean clone. The list is the tracked files plus new files that are not
// ignored (so the result is the same before and after a pending commit), minus files deleted from the
// work tree, and never anything under .claude/. A ref exists when it equals a listed file or is a
// directory prefix of one.
//
// Known misses (not fixed on purpose; the matching is a port of the prototype): a path is not found when the
// ".tad/" or ".claude/" is glued to a preceding path character, a "*", "<", ">" or "|", a CJK letter or
// other letter/digit, a "./" prefix, or a "$VAR/" prefix. Such a mention is skipped silently, not
// reported.
//
// Ported from the Phase 5 grounding prototype (phase5-grounding.md, A.1); Node built-ins only.

import { spawnSync } from 'node:child_process';
import { existsSync, lstatSync, readFileSync, statSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));

// Whole files that are skipped: records whose job is to name removed, foreign or historical paths,
// plus this tool's own two files (the allow-list names dangling refs by design). Entries ending in "/"
// or "-" are prefixes; the others are exact paths. Do not widen this list without a decision: a ref
// that is dangling and correct belongs in the allow-list file with a reason instead.
const SKIP_FILES = [
  // Never scanned (the prototype's own exclusions): ignored local lanes that happen to hold a few
  // force-added files, and directories that are not content.
  '.tad/archive/',
  '.tad/evidence/',
  'node_modules/',
  '.git/',
  '.claude/',
  'CHANGELOG.md',
  'docs/archive/',
  'docs/legacy/',
  'docs/HISTORY.md',
  'docs/MIGRATION-',
  'docs/releases/',
  'docs/pm/',
  '.tad/spike-v3/',
  'scripts/archive/',
  'tad-work/archive/',
  '.agents/skills/_archived/',
  '.tad/deprecation.yaml',
  '.tad/migrations/',
  '.tad/tests/',
  '.tad/eval/',
  '.tad/decisions/',
  '.tad/memory/',
  '.tad/CHANGELOG.md',
  '.tad/manifest.yaml',
  'experiments/',
  '.tad/active/handoffs/',
  '.tad/active/designs/',
  '.tad/active/requirements/',
  '.tad/active/epics/',
  '.tad/project-knowledge/incidents/',
  '.tad/project-knowledge/patterns/',
  '.tad/scripts/check-path-refs.mjs',
  '.tad/scripts/path-refs-allowlist.txt',
];
const SKIP_FILE_RX = [/^\.tad\/scripts\/[^/]*\.test\.mjs$/];

const ALLOWLIST_PATH = '.tad/scripts/path-refs-allowlist.txt';

// Binary or non-text files, by extension.
const BINARY_EXT = new Set([
  'png', 'jpg', 'jpeg', 'gif', 'webp', 'ico', 'bmp', 'tiff', 'svgz', 'pdf', 'zip', 'gz', 'tgz', 'tar', 'bz2', 'xz',
  '7z', 'woff', 'woff2', 'ttf', 'otf', 'eot', 'mp3', 'mp4', 'mov', 'wav', 'ogg', 'webm', 'epub', 'xlsx', 'docx',
  'pptx', 'jar', 'wasm', 'so', 'dylib', 'db', 'sqlite', 'bin', 'class', 'pyc',
]);

// A path mention: .claude/ or .tad/ not glued to a preceding path character, then path characters
// (placeholder characters included so a templated path is captured whole and classified as a template).
const REF_RX = /(?<![\p{L}\p{N}_/.\-~$}])(\.claude|\.tad)\/([A-Za-z0-9_.\-/<>*{}$@~[\]|]*)/gu;

// (iii) placeholders: the text is a pattern, not a path.
const TEMPLATE_RX = /[<>*{}$[\]|]|\.\.\.|YYYY|NNN|XXX|\bNN\b/;

// (ii) install targets: paths that exist only inside a downstream project, never in this repo.
const CLAUDE_TARGET_RX = /^\.claude\/(skills|agents|commands|workflows|rules|settings(\.local)?\.json|CLAUDE\.md|hooks)(\/|$)|^\.claude\/?$/;

// (ii-b) directories a downstream project (or the maintainer's ignored local lanes) creates at run
// time. Only lanes with no committed content are listed on purpose: .tad/context, .tad/working and
// .tad/pair-testing hold tracked files here, so a stale ref into them must still be reported. A
// reference under one of these is exempt only when it is not an existing tracked path (checked first).
const RUNTIME_RX = /^\.tad\/(evidence|logs|learnings|reports|handovers|docs|archive|research-notebooks\/archived|active\/(skillify-candidates|dream-candidates|precompact|tasks))(\/|$)/;

function usage(msg) {
  if (msg) console.error(`check-path-refs: ${msg}`);
  console.error('usage: node .tad/scripts/check-path-refs.mjs [--root <dir>] [--list]');
  process.exit(2);
}

let root = resolve(HERE, '..', '..');
let list = false;
{
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--root') {
      if (i + 1 >= argv.length) usage('--root needs a directory');
      root = resolve(argv[++i]);
    } else if (argv[i] === '--list') {
      list = true;
    } else {
      usage(`unknown option '${argv[i]}'`);
    }
  }
}

if (!existsSync(root) || !statSync(root).isDirectory()) usage(`--root '${root}' is not a directory`);

const inside = spawnSync('git', ['-C', root, 'rev-parse', '--is-inside-work-tree'], { encoding: 'utf8' });
if (inside.status !== 0 || inside.stdout.trim() !== 'true') {
  console.error(`check-path-refs: '${root}' is not inside a git repository`);
  process.exit(2);
}
function gitList(...flags) {
  const r = spawnSync('git', ['-C', root, 'ls-files', '-z', ...flags], { encoding: 'utf8', maxBuffer: 256 * 1024 * 1024 });
  if (r.status !== 0) {
    console.error('check-path-refs: git ls-files failed');
    process.exit(2);
  }
  return r.stdout.split('\0').filter(Boolean);
}
const deleted = new Set(gitList('--deleted'));
const tracked = gitList('--cached', '--others', '--exclude-standard').filter((f) => !deleted.has(f) && !f.startsWith('.claude/'));

// Tracked files and every directory that is a prefix of one.
const exists = new Set();
for (const f of tracked) {
  exists.add(f);
  let d = f;
  while (d.includes('/')) {
    d = d.slice(0, d.lastIndexOf('/'));
    exists.add(d);
  }
}

function skippedFile(f) {
  for (const s of SKIP_FILES) {
    if (s.endsWith('/') || s.endsWith('-')) { if (f.startsWith(s)) return true; }
    else if (f === s) return true;
  }
  return SKIP_FILE_RX.some((rx) => rx.test(f));
}

// Allow-list: `<file>\t<ref>\t<reason>`, exact (file, ref) equality, '#' starts a comment.
const allow = new Map();
const allowPath = join(root, ALLOWLIST_PATH);
if (existsSync(allowPath)) {
  readFileSync(allowPath, 'utf8').split('\n').forEach((line, i) => {
    if (!line.trim() || line.startsWith('#')) return;
    const cols = line.split('\t');
    if (cols.length < 3 || !cols[0] || !cols[1] || !cols[2].trim()) {
      console.error(`check-path-refs: ${ALLOWLIST_PATH}:${i + 1}: a row needs <file>, <ref> and a reason, separated by tabs`);
      process.exit(2);
    }
    allow.set(`${cols[0]}\t${cols[1]}`, { line: i + 1, used: false });
  });
}

const rows = [];
let scanned = 0;
for (const f of tracked) {
  if (skippedFile(f)) continue;
  const dot = f.lastIndexOf('.');
  if (dot > f.lastIndexOf('/') && BINARY_EXT.has(f.slice(dot + 1).toLowerCase())) continue;
  const abs = join(root, f);
  let text;
  try {
    if (lstatSync(abs).isSymbolicLink() || !statSync(abs).isFile()) continue;
    const buf = readFileSync(abs);
    if (buf.includes(0)) continue; // NUL byte: binary
    text = buf.toString('utf8');
  } catch {
    continue;
  }
  scanned++;
  const lines = text.split('\n');
  for (let n = 0; n < lines.length; n++) {
    for (const m of lines[n].matchAll(REF_RX)) {
      const ref = m[0].replace(/[.,:;)\]'"`]+$/, '');
      const bare = ref.replace(/\/+$/, '');
      let cls;
      if (exists.has(bare)) cls = 'exists';
      else if (TEMPLATE_RX.test(ref)) cls = 'template';
      else if (CLAUDE_TARGET_RX.test(ref)) cls = 'install-target';
      else if (RUNTIME_RX.test(ref)) cls = 'runtime';
      else if (allow.has(`${f}\t${ref}`)) { cls = 'allowed'; allow.get(`${f}\t${ref}`).used = true; }
      else cls = 'dangling';
      rows.push({ cls, file: f, line: n + 1, ref });
    }
  }
}

if (list) for (const r of rows) console.log(`${r.cls}\t${r.file}:${r.line}\t${r.ref}`);

const dangling = rows.filter((r) => r.cls === 'dangling');
for (const r of dangling) console.log(`DANGLING ${r.file}:${r.line} ${r.ref}`);

for (const [key, v] of allow) {
  if (!v.used) {
    const [file, ref] = key.split('\t');
    console.error(`STALE-ALLOW ${ALLOWLIST_PATH}:${v.line} ${file} ${ref} (matches no reference)`);
  }
}

console.error(`check-path-refs: ${scanned} files, ${rows.length} references, ${dangling.length} dangling, ${rows.filter((r) => r.cls === 'allowed').length} allowed`);
process.exit(dangling.length ? 1 : 0);
