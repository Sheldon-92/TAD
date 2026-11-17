#!/usr/bin/env node
// check-path-refs.mjs - report references to .tad/... and .claude/... paths that do not exist.
//
// Scans the text files listed by `git ls-files`, pulls out every `.tad/...` and `.claude/...` path
// mention, and prints `DANGLING <file>:<line> <ref>` for each one that points at nothing in the
// tracked tree and is not explained by one of the classes below.
//
//   node .tad/scripts/check-path-refs.mjs [--root <dir>] [--list]
//   node .tad/scripts/check-path-refs.mjs --no-git [--root <dir>] [--list | --files]
//
// Exit: 0 = no un-allowed dangling reference, 1 = at least one, 2 = usage or environment error
// (bad option, --root missing, not inside a git repository; with --no-git also an unsupported
// .gitignore form or a .gitignore line over 1024 characters, a directory seen twice or one that cannot be
// read, a symlinked or otherwise unsafe .gitignore or allow-list, or a file name holding a control
// character).
// --list also prints every classified reference as `<class>\t<file>:<line>\t<ref>`.
// --files (only with --no-git) prints the walked file list, one relative path per line, and exits 0
// without scanning: what a checkout would hold (links as entries, .claude/ kept). See "No-git mode".
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
//
// No-git mode (--no-git; report-upgrades Phase 4, D5). The file list is a walk of --root on disk instead
// of `git ls-files`, and this tool then calls git zero times. Left out of the walk, in this order of
// precedence: (iii) `.git` at any depth, file or directory, never listed and never entered (a nested
// repo's config can hold a remote URL with a token); (ii) the push tool's built-in never-commit list
// and (ii-b) TAD's own credential names (NEVER_COMMIT below; no `!` line of a .gitignore re-includes
// them); (i) every .gitignore of the tree, each scoped to its directory, later and deeper lines winning,
// as git does. Names are matched case-insensitively (git's core.ignorecase on macOS; APFS folds case).
// A directory that is left out is not entered, so nothing below it is read or listed.
// Walk rules: links are never followed (the walk decides from directory entry types, never by a stat
// through an entry; a symlink is listed as one path, as git lists one, and nothing under it); only
// regular files are opened (a FIFO, socket or device entry is listed nowhere); each open is lstat,
// open with O_NOFOLLOW, fstat, and read only when device and inode match the lstat; a regular file with
// more than one link is not opened (it may be a second name for a left-out file) and stays in the
// existence set by name; a directory seen twice by (device, inode) exits 2, a directory on another
// device than the root (a mount point) is not entered; a .gitignore or the allow-list that is a
// symlink, not a regular file, or has more than one link exits 2 (and the allow-list's parent
// directories must be real directories). Only synchronous node:fs calls are used and no child process.
// The guarantee is what it is: this mode never opens a path whose name is on these lists, or one
// reached through a link. The never-open list is a list of names only: nothing looks at a file's
// content to decide whether it holds a key or a password, so a credential under any other name is
// walked and read like any file; nothing is printed from a file's text except the reference itself
// (`DANGLING file:line ref`). Not covered: a writer swapping an intermediate directory during the run.
// The run always ends: matching is bounded (see MAX_RULE_CHARS), and a directory that cannot be read
// (or any other error while walking) ends the run with exit 2 and one `check-path-refs:` line, not a
// stack trace.
// Sets: scan set = the walk minus symlinks, minus .claude/ (as in git mode) and minus multi-link files;
// existence set = scan set + symlink entries + multi-link files + the names of entries left out by
// (ii)/(ii-b) as their parent's listing shows them (name only, nothing below a left-out directory).
// Gitignored paths are not in it, as in git mode.
// Known differences from git mode: files force-added under an ignored path are not listed (this can
// only add a DANGLING, never hide one); global excludes and .git/info/exclude are not read; files under
// a directory left out by name are absent from the existence set; multi-link files are not scanned.
// Supported .gitignore forms: blank, `#` comment, `!` negation, trailing `/`, leading or inner `/`
// (anchored), `*`, `?`, `**/` prefix, `/**` suffix, `/**/` middle; any other form (`[`, `\`) exits 2
// naming `<gitignore>:<line>`, never a silent mis-match.

import { spawnSync } from 'node:child_process';
import { closeSync, constants as FS, existsSync, fstatSync, lstatSync, openSync, readdirSync, readFileSync, statSync } from 'node:fs';
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
  // Records that name paths at a past moment (ideas, tickets, surplus plans): decided by the human on
  // 2026-11-09 in EPIC-20261109-report-upgrades (Phase 4 Q1); the widening is stated in its completion report.
  '.tad/active/ideas/',
  '.tad/active/TICKET-',
  '.tad/active/SURPLUS-PLAN-',
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

// ---------------------------------------------------------------------------------------------------
// No-git mode (--no-git): the walk, its ignore lists and the guarded reads. See the header comment.

// (ii) The push tool's built-in never-commit list, copied from ../gm/bin/yunpush `write_excludes`
// (the heredoc at lines 77-141, as read 2026-11-09), in gitignore grammar so the same matcher applies.
// (ii-b) TAD's own additions: credential names the push tool's name list misses.
// A credential under a name on neither list is walked like any other file.
const NEVER_COMMIT = [
  // (ii) yunpush write_excludes, 2026-11-09
  '*.sync-conflict-*', '.syncthing.*.tmp', '~syncthing~*.tmp', '.stversions/', '.stfolder', '.stignore',
  '.stignore-shared', '.yunpush-local/', '.DS_Store', '._*', 'node_modules/', '.next/', '.venv/', 'venv/',
  '__pycache__/', '*.pyc', '.cache/', 'dist/', 'build/', '.turbo/', '.pytest_cache/', '.git.legacy*/', '.wt/',
  '.worktrees/', '.claude/worktrees/', '.tad/active/precompact/', '.tad/logs/',
  'Cookies', 'Cookies-journal', 'Login Data', 'Login Data-journal', 'Web Data', 'Local State',
  '.chrome-profile*/', '.chrome-admin-run/',
  '.env', '.env.*', '*.pem', '*.key', 'id_rsa*', '.npmrc', 'credentials.json', '*.p12', '.private/',
  '*.zip', '*.tar', '*.tar.gz', '*.tgz', '*.7z', '*.dmg', '*.iso', '*.mp4', '*.mov', '*.mkv', '*.wav',
  '*.epub', '*.mobi', '*.azw3', '*.eml', '*.mbox', '*.pst',
  // (ii-b) TAD's additions (report-upgrades Phase 4, Gate 2 r2 risk P1-1)
  '.netrc', '.git-credentials', '.ssh/', '.aws/', '.gnupg/', '*.p8', '*.pfx', '*.jks', '*.keystore', '*.kdbx',
  // (ii-b) more key and credential names (Phase 4 rework 1, Gate 3 r1 domain P1-2): ssh private keys under
  // their other default names, client credential files and directories of common tools, token files
  'id_ed25519*', 'id_ecdsa*', 'id_dsa*', '*.ppk', '.pgpass', '.htpasswd', '.pypirc', '.docker/', '.kube/',
  '.azure/', '**/.config/gcloud/', '.vault-token', '.s3cfg', '.boto', '.terraformrc', '*.token',
  'service-account*.json', '*.keychain', '*.keychain-db',
];

// Exit by unwinding to the end of the script and setting process.exitCode, not by process.exit(): on the
// maintainer's Mac (Node 24.7, 2026-11-09) process.exit() segfaults the runtime in a share of runs
// (exit status 139 instead of the code asked for), while a natural exit does not. Same codes as before.
class ExitRequest extends Error {
  constructor(code) { super(`exit ${code}`); this.code = code; }
}
function exitNow(code) { throw new ExitRequest(code); }

function noGitFail(msg) {
  console.error(`check-path-refs: ${msg}`);
  exitNow(2);
}

// A printable form of a name (control characters escaped), for messages only.
function shown(s) {
  return JSON.stringify(String(s)).slice(1, -1);
}

// Matching is bounded by construction (rework 1 of Phase 4, Gate 3 r1 domain P1-1): the content of a
// .gitignore and the names in the tree are input the tool does not control, so no regular expression is
// built from a .gitignore line and no backtracking regex runs over a file name or a reference. A pattern is
// compiled to tokens and matched by one left-to-right pass over the subject per token (time at most
// pattern length x subject length, never exponential); a .gitignore line longer than MAX_RULE_CHARS exits 2
// naming the line. Trailing characters are stripped by plain loops (trimEnd below), not by `x+$` regexes.
const MAX_RULE_CHARS = 1024;

// Strip trailing characters that are in `set` (a string), by a loop: linear in the string's length.
function trimEnd(s, set) {
  let e = s.length;
  while (e > 0 && set.includes(s[e - 1])) e--;
  return e === s.length ? s : s.slice(0, e);
}

// gitignore glob -> tokens over a lower-cased path relative to the rule's directory. Tokens: lit (one
// character), one (`?`: one character but '/'), star (`*`, `**` inside a name: any run without '/'),
// any (the trailing `/**`: anything), dirs (the leading `**/` and the middle `/**/`: empty or any string
// that ends with '/').
function globTokens(p) {
  const t = [];
  let i = 0;
  if (p.startsWith('**/')) { t.push({ k: 'dirs' }); i = 3; }
  while (i < p.length) {
    if (p.startsWith('/**/', i)) { t.push({ k: 'lit', c: '/' }, { k: 'dirs' }); i += 4; continue; }
    if (p.startsWith('/**', i) && i + 3 === p.length) { t.push({ k: 'lit', c: '/' }, { k: 'any' }); i += 3; continue; }
    const ch = p[i];
    if (ch === '*') { while (p[i] === '*') i++; t.push({ k: 'star' }); continue; }
    if (ch === '?') { t.push({ k: 'one' }); i++; continue; }
    t.push({ k: 'lit', c: ch.toLowerCase() });
    i++;
  }
  return t;
}

// Does the token list match the whole of `s` (already lower-cased)? One pass over s per token, with one
// reachability row: prev[j] = the tokens so far can match s[0..j).
function globMatch(tokens, s) {
  const n = s.length;
  let prev = new Uint8Array(n + 1);
  let cur = new Uint8Array(n + 1);
  prev[0] = 1;
  for (const tk of tokens) {
    let alive = 0;
    if (tk.k === 'lit' || tk.k === 'one') {
      cur[0] = 0;
      for (let j = 0; j < n; j++) {
        const ok = prev[j] && (tk.k === 'lit' ? s[j] === tk.c : s[j] !== '/');
        cur[j + 1] = ok ? 1 : 0;
        alive |= cur[j + 1];
      }
    } else if (tk.k === 'star' || tk.k === 'any') {
      cur[0] = prev[0];
      alive = cur[0];
      for (let j = 1; j <= n; j++) {
        cur[j] = prev[j] || (cur[j - 1] && (tk.k === 'any' || s[j - 1] !== '/')) ? 1 : 0;
        alive |= cur[j];
      }
    } else { // dirs
      let reach = 0;
      for (let j = 0; j <= n; j++) {
        cur[j] = prev[j] || (j > 0 && reach && s[j - 1] === '/') ? 1 : 0;
        if (prev[j]) reach = 1;
        alive |= cur[j];
      }
    }
    if (!alive) return false;
    const x = prev; prev = cur; cur = x;
  }
  return prev[n] === 1;
}

// Lines of one ignore file -> rules. `where` names the file for errors; `base` is its directory ('' = root).
function compileIgnore(lines, base, where) {
  const rules = [];
  lines.forEach((raw, n) => {
    let line = raw.endsWith('\r') ? raw.slice(0, -1) : raw;
    if (!line.trim() || line.startsWith('#')) return;
    if (line.length > MAX_RULE_CHARS) noGitFail(`${where}:${n + 1}: .gitignore line longer than ${MAX_RULE_CHARS} characters; --no-git refuses it`);
    if (line.includes('[') || line.includes('\\')) noGitFail(`${where}:${n + 1}: unsupported .gitignore form (character class or escape); --no-git cannot match it like git does`);
    line = trimEnd(line, ' ');
    let neg = false;
    if (line.startsWith('!')) { neg = true; line = line.slice(1); }
    let dirOnly = false;
    if (line.endsWith('/')) { dirOnly = true; line = trimEnd(line, '/'); }
    if (!line) return;
    const anchored = line.includes('/');
    if (line.startsWith('/')) line = line.slice(1);
    rules.push({ tokens: globTokens(line), neg, dirOnly, anchored, base, baseLc: base.toLowerCase() });
  });
  return rules;
}

// Last matching rule wins (true = ignored, false = re-included, undefined = no rule matched).
function ruleVerdict(rules, rel, isDir) {
  let v;
  const relLc = rel.toLowerCase();
  for (const r of rules) {
    let sub = relLc;
    if (r.base) {
      if (!relLc.startsWith(`${r.baseLc}/`)) continue;
      sub = relLc.slice(r.baseLc.length + 1);
    }
    if (r.dirOnly && !isDir) continue;
    const subject = r.anchored ? sub : sub.slice(sub.lastIndexOf('/') + 1);
    if (globMatch(r.tokens, subject)) v = !r.neg;
  }
  return v;
}

const NEVER_RULES = compileIgnore(NEVER_COMMIT, '', 'built-in never-commit list');

// Guarded read of one regular file: lstat (regular, one link), open O_RDONLY|O_NOFOLLOW|O_NONBLOCK, fstat,
// read only when device and inode equal the lstat. strict (the tool's own inputs): any failure exits 2;
// otherwise it is one stderr line and null.
function safeRead(abs, rel, strict) {
  const refuse = (why) => {
    if (strict) noGitFail(`not reading ${shown(rel)} (${why})`);
    console.error(`check-path-refs: not reading ${shown(rel)} (${why})`);
    return null;
  };
  let st;
  try { st = lstatSync(abs); } catch (e) { return refuse(`lstat failed: ${e.code || e.message}`); }
  if (st.isSymbolicLink()) return refuse('a symlink');
  if (!st.isFile()) return refuse('not a regular file');
  if (st.nlink > 1) return refuse(`${st.nlink} links`);
  let fd;
  try { fd = openSync(abs, FS.O_RDONLY | FS.O_NOFOLLOW | FS.O_NONBLOCK); } catch (e) { return refuse(`open failed: ${e.code || e.message}`); }
  try {
    const fst = fstatSync(fd);
    if (!fst.isFile() || fst.dev !== st.dev || fst.ino !== st.ino) return refuse('changed between lstat and open');
    return readFileSync(fd);
  } catch (e) {
    if (e instanceof ExitRequest) throw e;
    return refuse(`read failed: ${e.code || e.message}`);
  } finally {
    closeSync(fd);
  }
}

// The allow-list in no-git mode: every parent below the root must be a real directory, the file a
// regular file with one link; absent = no allow-list (as in git mode); anything else exits 2.
function readAllowNoGit() {
  const parts = ALLOWLIST_PATH.split('/');
  let rel = '';
  for (let i = 0; i < parts.length; i++) {
    rel = rel ? `${rel}/${parts[i]}` : parts[i];
    let st;
    try { st = lstatSync(join(root, rel)); } catch (e) {
      if (e.code === 'ENOENT') return null;
      noGitFail(`cannot check ${rel} (${e.code || e.message})`);
    }
    if (st.isSymbolicLink()) noGitFail(`${rel} is a symlink; the allow-list is not read through a link`);
    if (i < parts.length - 1 && !st.isDirectory()) noGitFail(`${rel} is not a directory`);
  }
  return safeRead(join(root, ALLOWLIST_PATH), ALLOWLIST_PATH, true).toString('utf8');
}

// The walk. Returns { files (for --files: regular one-link files + symlinks, .claude/ kept),
// scan (regular one-link files outside .claude/), exist (scan + symlinks + multi-link files + names left
// out by the never-commit list, outside .claude/) }.
function walkNoGit(top) {
  const files = [];
  const scan = [];
  const exist = [];
  const seen = new Set();
  let rootDev;
  try { rootDev = statSync(top).dev; } catch (e) { noGitFail(`cannot read directory . (${e.code || e.message})`); }
  const inClaude = (rel) => rel === '.claude' || rel.startsWith('.claude/');
  const visit = (absDir, relDir, rules) => {
    let st;
    let entries;
    try {
      st = relDir ? lstatSync(absDir) : statSync(absDir);
    } catch (e) {
      noGitFail(`cannot read directory ${shown(relDir || '.')} (${e.code || e.message})`);
    }
    const key = `${st.dev}:${st.ino}`;
    if (seen.has(key)) noGitFail(`directory ${shown(relDir || '.')} was reached twice (device ${st.dev}, inode ${st.ino}); refusing a loop`);
    seen.add(key);
    try {
      entries = readdirSync(absDir, { withFileTypes: true });
    } catch (e) {
      noGitFail(`cannot read directory ${shown(relDir || '.')} (${e.code || e.message})`);
    }
    for (const e of entries) {
      if (/[\u0000-\u001f\u007f]/.test(e.name)) noGitFail(`a file name holds a control character: ${shown(relDir ? `${relDir}/${e.name}` : e.name)}`);
    }
    // This directory's .gitignore (read even when it ignores itself, as git does).
    let here = rules;
    const gi = entries.find((e) => e.name.toLowerCase() === '.gitignore');
    if (gi) {
      const giRel = relDir ? `${relDir}/${gi.name}` : gi.name;
      if (gi.isSymbolicLink()) noGitFail(`${shown(giRel)} is a symlink; a .gitignore is not read through a link`);
      if (!gi.isFile()) noGitFail(`${shown(giRel)} is not a regular file`);
      const text = safeRead(join(absDir, gi.name), giRel, true).toString('utf8');
      here = rules.concat(compileIgnore(text.split('\n'), relDir, giRel));
    }
    for (const e of entries) {
      const rel = relDir ? `${relDir}/${e.name}` : e.name;
      const abs = join(absDir, e.name);
      const isLink = e.isSymbolicLink();
      const isDir = !isLink && e.isDirectory();
      const isFile = !isLink && e.isFile();
      if (e.name.toLowerCase() === '.git') continue; // (iii): never listed, never entered
      if (ruleVerdict(NEVER_RULES, rel, isDir) === true) { // (ii)/(ii-b): name only, never opened
        if (!inClaude(rel)) exist.push(rel);
        continue;
      }
      if (ruleVerdict(here, rel, isDir) === true) continue; // (i)
      if (isLink) { // W-a: one entry, never followed or statted through
        files.push(rel);
        if (!inClaude(rel)) exist.push(rel);
        continue;
      }
      if (isDir) {
        let dst;
        try { dst = lstatSync(abs); } catch (e2) { noGitFail(`cannot read directory ${shown(rel)} (${e2.code || e2.message})`); }
        if (dst.dev !== rootDev) { console.error(`check-path-refs: not entering ${shown(rel)} (another device: a mount point)`); continue; }
        visit(abs, rel, here);
        continue;
      }
      if (!isFile) { console.error(`check-path-refs: not reading ${shown(rel)} (not a regular file)`); continue; } // W-b
      let fst;
      try { fst = lstatSync(abs); } catch (e2) { console.error(`check-path-refs: not reading ${shown(rel)} (lstat failed: ${e2.code || e2.message})`); continue; }
      if (fst.nlink > 1) { // W-e
        console.error(`check-path-refs: not reading ${shown(rel)} (${fst.nlink} links: may be a second name for a left-out file)`);
        if (!inClaude(rel)) exist.push(rel);
        continue;
      }
      files.push(rel);
      if (!inClaude(rel)) { scan.push(rel); exist.push(rel); }
    }
  };
  visit(top, '', []);
  files.sort();
  scan.sort();
  return { files, scan, exist };
}
// ---------------------------------------------------------------------------------------------------

function usage(msg) {
  if (msg) console.error(`check-path-refs: ${msg}`);
  console.error('usage: node .tad/scripts/check-path-refs.mjs [--root <dir>] [--list]');
  console.error('       node .tad/scripts/check-path-refs.mjs --no-git [--root <dir>] [--list | --files]');
  exitNow(2);
}

let root = resolve(HERE, '..', '..');
let list = false;
let noGit = false;
let filesOnly = false;
try {
{
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--root') {
      if (i + 1 >= argv.length) usage('--root needs a directory');
      root = resolve(argv[++i]);
    } else if (argv[i] === '--list') {
      list = true;
    } else if (argv[i] === '--no-git') {
      noGit = true;
    } else if (argv[i] === '--files') {
      filesOnly = true;
    } else {
      usage(`unknown option '${argv[i]}'`);
    }
  }
  if (filesOnly && !noGit) usage('--files needs --no-git');
  if (filesOnly && list) usage('--files and --list do not combine');
}

if (!existsSync(root) || !statSync(root).isDirectory()) usage(`--root '${root}' is not a directory`);

// tracked = the files that are scanned; existList = the names a reference may resolve to.
let tracked;
let existList;
if (noGit) {
  const w = walkNoGit(root);
  if (filesOnly) {
    for (const f of w.files) console.log(f);
    exitNow(0);
  }
  tracked = w.scan;
  existList = w.exist;
} else {
  const inside = spawnSync('git', ['-C', root, 'rev-parse', '--is-inside-work-tree'], { encoding: 'utf8' });
  if (inside.status !== 0 || inside.stdout.trim() !== 'true') {
    console.error(`check-path-refs: '${root}' is not inside a git repository`);
    exitNow(2);
  }
  function gitList(...flags) {
    const r = spawnSync('git', ['-C', root, 'ls-files', '-z', ...flags], { encoding: 'utf8', maxBuffer: 256 * 1024 * 1024 });
    if (r.status !== 0) {
      console.error('check-path-refs: git ls-files failed');
      exitNow(2);
    }
    return r.stdout.split('\0').filter(Boolean);
  }
  const deleted = new Set(gitList('--deleted'));
  tracked = gitList('--cached', '--others', '--exclude-standard').filter((f) => !deleted.has(f) && !f.startsWith('.claude/'));
  existList = tracked;
}

// Tracked files and every directory that is a prefix of one.
const exists = new Set();
for (const f of existList) {
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
const allowText = noGit ? readAllowNoGit() : (existsSync(allowPath) ? readFileSync(allowPath, 'utf8') : null);
if (allowText !== null) {
  allowText.split('\n').forEach((line, i) => {
    if (!line.trim() || line.startsWith('#')) return;
    const cols = line.split('\t');
    if (cols.length < 3 || !cols[0] || !cols[1] || !cols[2].trim()) {
      console.error(`check-path-refs: ${ALLOWLIST_PATH}:${i + 1}: a row needs <file>, <ref> and a reason, separated by tabs`);
      exitNow(2);
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
    let buf;
    if (noGit) {
      buf = safeRead(abs, f, false);
      if (buf === null) continue;
    } else {
      if (lstatSync(abs).isSymbolicLink() || !statSync(abs).isFile()) continue;
      buf = readFileSync(abs);
    }
    if (buf.includes(0)) continue; // NUL byte: binary
    text = buf.toString('utf8');
  } catch {
    continue;
  }
  scanned++;
  const lines = text.split('\n');
  for (let n = 0; n < lines.length; n++) {
    for (const m of lines[n].matchAll(REF_RX)) {
      const ref = trimEnd(m[0], '.,:;)]\'"`'); // loops, not `x+$` regexes (bounded on any line)
      const bare = trimEnd(ref, '/');
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
exitNow(dangling.length ? 1 : 0);
} catch (e) {
  if (e instanceof ExitRequest) {
    process.exitCode = e.code;
  } else if (noGit) {
    // --no-git: an error nothing above expected (a file system error, a too-deep tree) is an environment
    // error: one line and exit 2, as the usage line says, not a stack trace.
    console.error(`check-path-refs: --no-git stopped: ${e && (e.code || e.message) ? `${e.code ? `${e.code} ` : ''}${e.message}` : String(e)}`);
    process.exitCode = 2;
  } else {
    throw e;
  }
}
