#!/bin/bash
# check-path-refs-nogit-fixture.sh - fixture for `check-path-refs.mjs --no-git` (report-upgrades Phase 4, D6).
#
#   /bin/bash .tad/tests/check-path-refs-nogit-fixture.sh
#
# Builds scratch trees in mktemp -d directories (dummy text only, never a real credential) and checks:
#   1 a planted dangling ref is reported, exit 1          7 refs inside never-open names are not reported and
#   2 the same ref in a .gitignore'd file is not             those paths are not in --files (.private/, .env,
#   3 ... nor in a Syncthing conflict copy                   .PRIVATE/ in a second root, *.key, .ssh/, sub/.git/)
#   4 a `!` re-included path is scanned                    8 links (to ../.private, ../.env, outside the root,
#   5 a `[ab]` .gitignore line exits 2 naming the line       to itself) are one entry each, nothing under them
#   6 a clean tree exits 0                                 9 a FIFO and a hard link to .env are not opened
#  10 `!.env` / `!.private/` re-include neither           11 a symlinked .gitignore exits 2 naming it
#  12 inputs that made the old regex matcher hang (a `a*a*...*b` rule against a long name, a line of
#     200000 spaces, a reference ending in 200000 dots) end within 10 s (rework 1, Gate 3 r1 domain P1-1)
#  13 an unreadable directory ends with exit 2 and one `check-path-refs:` line, no stack trace
# Case 7 also plants more key and credential names (id_ed25519, .ENV.local, .pgpass, .docker/, .kube/,
# service-account.json, a.token; rework 1, Gate 3 r1 domain P1-2): a later edit that drops one from the
# never-open list fails here.
# Witness for 7-10: the tool runs under `node --import <spy>`; the spy wraps the synchronous node:fs calls
# and every child_process call, and logs `<call>\t<path>`. w1: the spy saw the walk (a readdirSync of the
# root and an open of docs/ok.md); w2: no logged call names a forbidden path or a path under one, no child
# process was started, and docs/h.md appears in lstatSync lines only.
# Every tool run has a 30 s watchdog (macOS has no `timeout`). Calls git zero times.
# CHECK_PATH_REFS_TOOL=<file> runs the fixture against another build of the tool (a known-bad walk must FAIL).
# Last line: `RESULT: PASS` or `RESULT: FAIL`. Written for bash 3.2.

set -u
HERE="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "$HERE/../.." && pwd -P)"
TOOL="${CHECK_PATH_REFS_TOOL:-$REPO_ROOT/.tad/scripts/check-path-refs.mjs}"

FAILS=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAILS=$((FAILS + 1)); }

SCR="$(mktemp -d)" || exit 2
SCR="$(cd "$SCR" && pwd -P)"
trap 'rm -rf "$SCR"' EXIT
SPY="$SCR/spy.mjs"
cat > "$SPY" <<'SPYEOF'
import fs from 'node:fs';
import cp from 'node:child_process';
import { syncBuiltinESMExports } from 'node:module';
const log = process.env.SPY_LOG;
const append = fs.appendFileSync.bind(fs);
const note = (call, p) => { if (log) append(log, `${call}\t${typeof p === 'number' ? `fd:${p}` : String(p)}\n`); };
for (const name of ['openSync', 'readFileSync', 'readdirSync', 'opendirSync', 'statSync', 'lstatSync', 'existsSync', 'realpathSync', 'accessSync']) {
  const orig = fs[name];
  fs[name] = function (p, ...rest) { note(name, p); return orig.call(this, p, ...rest); };
}
for (const name of ['spawn', 'spawnSync', 'exec', 'execSync', 'execFile', 'execFileSync', 'fork']) {
  const orig = cp[name];
  cp[name] = function (...args) { note(`child_process.${name}`, args[0]); return orig.apply(this, args); };
}
syncBuiltinESMExports();
SPYEOF

# run_tool <out> <err> <args...>: runs the tool with a 30 s watchdog (WATCH_TICKS x 0.2 s, default 150);
# sets RC (124 = killed by the watchdog). With SPY_LOG set the tool runs under the spy.
run_tool() {
  local out="$1" err="$2"; shift 2
  if [ -n "${SPY_LOG:-}" ]; then
    node --import "$SPY" "$TOOL" "$@" > "$out" 2> "$err" &
  else
    node "$TOOL" "$@" > "$out" 2> "$err" &
  fi
  local pid=$! n=0
  while kill -0 "$pid" 2>/dev/null; do
    n=$((n + 1))
    if [ "$n" -gt "${WATCH_TICKS:-150}" ]; then kill -9 "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; RC=124; return; fi
    sleep 0.2
  done
  wait "$pid"; RC=$?
}

REF='.tad/planted/missing-target.md'
# new_tree: a scratch root holding docs/ok.md (an ordinary file with a reference that exists)
new_tree() {
  local t
  t="$(mktemp -d "$SCR/tree.XXXXXX")" || exit 2
  t="$(cd "$t" && pwd -P)"
  mkdir -p "$t/docs" "$t/.tad"
  printf 'ordinary text, see .tad/real.md for nothing\n' > "$t/docs/ok.md"
  printf 'real\n' > "$t/.tad/real.md"
  printf '%s' "$t"
}
plant() { mkdir -p "$(dirname "$1")"; printf 'planted dummy text: see %s here\n' "$REF" > "$1"; }

# spy_check <tree> <log> <forbidden relative paths...>: w1 and w2
SPY_CALLS=0
spy_check() {
  local t="$1" lg="$2"; shift 2
  local bad="" f n
  n=$(wc -l < "$lg" | tr -d ' ')
  SPY_CALLS=$((SPY_CALLS + n))
  if grep -qxF "$(printf 'readdirSync\t%s' "$t")" "$lg" && grep -qxF "$(printf 'openSync\t%s/docs/ok.md' "$t")" "$lg"; then
    W1_OK=$((W1_OK + 1))
  else
    W1_BAD="$W1_BAD $(basename "$t")"
  fi
  for f in "$@"; do
    if awk -F'\t' -v p="$t/$f" '$2 == p || index($2, p "/") == 1 { found = 1 } END { exit !found }' "$lg"; then
      bad="$bad $f"
      awk -F'\t' -v p="$t/$f" '$2 == p || index($2, p "/") == 1' "$lg" | head -5 | sed 's/^/  offending: /'
    fi
  done
  if grep -q '^child_process\.' "$lg"; then bad="$bad child_process"; grep '^child_process\.' "$lg" | head -3 | sed 's/^/  offending: /'; fi
  if [ -e "$t/docs/h.md" ]; then
    if awk -F'\t' -v p="$t/docs/h.md" '$2 == p && $1 != "lstatSync" { found = 1 } END { exit !found }' "$lg"; then
      bad="$bad docs/h.md(not-lstat)"
      awk -F'\t' -v p="$t/docs/h.md" '$2 == p && $1 != "lstatSync"' "$lg" | head -3 | sed 's/^/  offending: /'
    fi
  fi
  SPY_BAD="$SPY_BAD$bad"
  [ -z "$bad" ]
}
W1_OK=0; W1_BAD=""; SPY_BAD=""

# --- 1: a planted dangling ref is reported, exit 1
T=$(new_tree); plant "$T/a.md"
run_tool "$SCR/o1" "$SCR/e1" --no-git --root "$T"
if [ "$RC" = 1 ] && grep -qxF "DANGLING a.md:1 $REF" "$SCR/o1"; then pass "case 1: planted dangling ref reported, exit 1"; else fail "case 1: rc=$RC out=$(tr '\n' '|' < "$SCR/o1") err=$(tr '\n' '|' < "$SCR/e1")"; fi

# --- 2: the same ref in a .gitignore'd file is not reported
T=$(new_tree); plant "$T/ignored/b.md"; printf 'ignored/\n' > "$T/.gitignore"
run_tool "$SCR/o2" "$SCR/e2" --no-git --root "$T"
if [ "$RC" = 0 ] && ! grep -q DANGLING "$SCR/o2"; then pass "case 2: ref inside a .gitignore'd file not reported"; else fail "case 2: rc=$RC out=$(tr '\n' '|' < "$SCR/o2")"; fi

# --- 3: inside a Syncthing conflict copy, not reported
T=$(new_tree); plant "$T/x.sync-conflict-20260101-000000-ABC.md"
run_tool "$SCR/o3" "$SCR/e3" --no-git --root "$T"
if [ "$RC" = 0 ] && ! grep -q DANGLING "$SCR/o3"; then pass "case 3: ref inside a sync-conflict copy not reported"; else fail "case 3: rc=$RC out=$(tr '\n' '|' < "$SCR/o3")"; fi

# --- 4: a negated path is scanned (dir/* + !dir/keep.md)
T=$(new_tree); plant "$T/dir/keep.md"; plant "$T/dir/other.md"; printf 'dir/*\n!dir/keep.md\n' > "$T/.gitignore"
run_tool "$SCR/o4" "$SCR/e4" --no-git --root "$T"
if [ "$RC" = 1 ] && grep -qxF "DANGLING dir/keep.md:1 $REF" "$SCR/o4" && ! grep -q 'dir/other.md' "$SCR/o4"; then pass "case 4: re-included dir/keep.md scanned, dir/other.md not"; else fail "case 4: rc=$RC out=$(tr '\n' '|' < "$SCR/o4")"; fi

# --- 5: an unsupported .gitignore form exits 2 naming the line
T=$(new_tree); mkdir -p "$T/sub"; printf '# c\nfoo[ab].md\n' > "$T/sub/.gitignore"
run_tool "$SCR/o5" "$SCR/e5" --no-git --root "$T"
if [ "$RC" = 2 ] && grep -qF 'sub/.gitignore:2' "$SCR/e5"; then pass "case 5: [ab] line refused, exit 2 naming sub/.gitignore:2"; else fail "case 5: rc=$RC err=$(tr '\n' '|' < "$SCR/e5")"; fi

# --- 6: a clean tree exits 0
T=$(new_tree)
run_tool "$SCR/o6" "$SCR/e6" --no-git --root "$T"
if [ "$RC" = 0 ] && ! grep -q DANGLING "$SCR/o6" && grep -q '0 dangling' "$SCR/e6"; then pass "case 6: clean tree exits 0"; else fail "case 6: rc=$RC err=$(tr '\n' '|' < "$SCR/e6")"; fi

# --- 7: never-open names (D5 ii, ii-b, iii): not reported, not in --files, not opened
T=$(new_tree)
plant "$T/.private/a.md"; plant "$T/.env"; plant "$T/k/secret.key"; plant "$T/.ssh/c"; plant "$T/sub/.git/config"; plant "$T/sub/fine.md"
C7MORE="keys/id_ed25519 .ENV.local .pgpass .docker .kube svc/service-account.json a.token"
plant "$T/keys/id_ed25519"; plant "$T/.ENV.local"; plant "$T/.pgpass"; plant "$T/.docker/config.json"; plant "$T/.kube/config"
plant "$T/svc/service-account.json"; plant "$T/a.token"
T2=$(new_tree); plant "$T2/.PRIVATE/b.md"
c7=""
for root in "$T" "$T2"; do
  : > "$SCR/spy7"
  SPY_LOG="$SCR/spy7" run_tool "$SCR/o7" "$SCR/e7" --no-git --root "$root"
  r1=$RC
  SPY_LOG="$SCR/spy7" run_tool "$SCR/f7" "$SCR/g7" --no-git --root "$root" --files
  r2=$RC
  if [ "$root" = "$T" ]; then
    # sub/fine.md holds the ref and must be reported: proves the scan ran in this tree
    if [ "$r1" = 1 ] && [ "$(grep -c DANGLING "$SCR/o7")" = 1 ] && grep -qxF "DANGLING sub/fine.md:1 $REF" "$SCR/o7"; then :; else c7="$c7 report(rc=$r1:$(tr '\n' '|' < "$SCR/o7"))"; fi
    if [ "$r2" = 0 ] && ! grep -qiE '^(\.private|\.env|k/secret\.key|\.ssh|sub/\.git|keys/id_ed25519|\.pgpass|\.docker|\.kube|svc/service-account\.json|a\.token)(/|$|\.local$)' "$SCR/f7" && grep -qx 'sub/fine.md' "$SCR/f7"; then :; else c7="$c7 files(rc=$r2:$(tr '\n' '|' < "$SCR/f7"))"; fi
    # shellcheck disable=SC2086
    spy_check "$T" "$SCR/spy7" .private .env k/secret.key .ssh sub/.git $C7MORE || c7="$c7 spy"
  else
    if [ "$r1" = 0 ] && ! grep -q DANGLING "$SCR/o7"; then :; else c7="$c7 report2(rc=$r1)"; fi
    if [ "$r2" = 0 ] && ! grep -qi '^\.private' "$SCR/f7"; then :; else c7="$c7 files2"; fi
    spy_check "$T2" "$SCR/spy7" .PRIVATE .private || c7="$c7 spy2"
  fi
done
if [ -z "$c7" ]; then pass "case 7: .private/, .env, .PRIVATE/, *.key, .ssh/, sub/.git/, id_ed25519, .ENV.local, .pgpass, .docker/, .kube/, service-account.json, *.token neither reported, listed nor opened"; else fail "case 7:$c7"; fi

# --- 8: links are never followed (W-a)
T=$(new_tree); OUT="$(mktemp -d "$SCR/outside.XXXXXX")"; OUT="$(cd "$OUT" && pwd -P)"
plant "$T/.private/a.md"; plant "$T/.env"; plant "$OUT/far.md"
ln -s ../.private "$T/docs/x"; ln -s ../.env "$T/docs/e.md"; ln -s "$OUT" "$T/docs/out"; ln -s . "$T/docs/loop"
: > "$SCR/spy8"
SPY_LOG="$SCR/spy8" run_tool "$SCR/o8" "$SCR/e8" --no-git --root "$T"; r1=$RC
SPY_LOG="$SCR/spy8" run_tool "$SCR/f8" "$SCR/g8" --no-git --root "$T" --files; r2=$RC
c8=""
[ "$r1" = 0 ] && ! grep -q DANGLING "$SCR/o8" || c8="$c8 report(rc=$r1:$(tr '\n' '|' < "$SCR/o8"))"
[ "$r2" = 0 ] || c8="$c8 files-rc=$r2"
for l in docs/x docs/e.md docs/out docs/loop; do
  [ "$(grep -cx "$l" "$SCR/f8")" = 1 ] || c8="$c8 $l-not-one-entry"
  ! grep -q "^$l/" "$SCR/f8" || c8="$c8 $l-has-children"
done
spy_check "$T" "$SCR/spy8" .private .env docs/x docs/e.md docs/out docs/loop || c8="$c8 spy"
if awk -F'\t' -v p="$OUT" '$2 == p || index($2, p "/") == 1 { f = 1 } END { exit !f }' "$SCR/spy8"; then c8="$c8 outside-dir-touched"; SPY_BAD="$SPY_BAD outside-dir"; fi
if [ -z "$c8" ]; then pass "case 8: links to ../.private, ../.env, outside the root and to itself listed as one entry each, not followed, run ended"; else fail "case 8:$c8"; fi

# --- 9: a FIFO and a hard link to .env (W-b, W-e)
T=$(new_tree); plant "$T/.env"; mkfifo "$T/docs/fifo"; ln "$T/.env" "$T/docs/h.md"
: > "$SCR/spy9"
SPY_LOG="$SCR/spy9" run_tool "$SCR/o9" "$SCR/e9" --no-git --root "$T"; r1=$RC
c9=""
[ "$r1" = 0 ] && ! grep -q DANGLING "$SCR/o9" || c9="$c9 report(rc=$r1:$(tr '\n' '|' < "$SCR/o9"))"
grep -q 'docs/h.md' "$SCR/e9" || c9="$c9 stderr-does-not-name-docs/h.md"
spy_check "$T" "$SCR/spy9" .env docs/fifo || c9="$c9 spy"
if [ -z "$c9" ]; then pass "case 9: FIFO and hard link not opened, run ended, stderr names docs/h.md"; else fail "case 9:$c9"; fi

# --- 10: `!.env` and `!.private/` re-include neither (W-f)
T=$(new_tree); plant "$T/.private/a.md"; plant "$T/.env"; printf '!.env\n!.private/\n' > "$T/.gitignore"
: > "$SCR/spy10"
SPY_LOG="$SCR/spy10" run_tool "$SCR/o10" "$SCR/e10" --no-git --root "$T"; r1=$RC
SPY_LOG="$SCR/spy10" run_tool "$SCR/f10" "$SCR/g10" --no-git --root "$T" --files; r2=$RC
c10=""
[ "$r1" = 0 ] && ! grep -q DANGLING "$SCR/o10" || c10="$c10 report(rc=$r1)"
[ "$r2" = 0 ] && ! grep -qE '^(\.env|\.private)' "$SCR/f10" || c10="$c10 files"
spy_check "$T" "$SCR/spy10" .private .env || c10="$c10 spy"
if [ -z "$c10" ]; then pass "case 10: !.env and !.private/ re-include neither"; else fail "case 10:$c10"; fi

# --- 11: a .gitignore that is a symlink exits 2 naming it (W-h)
T=$(new_tree); printf 'nothing/\n' > "$T/real-ignore"; ln -s ../real-ignore "$T/docs/.gitignore"
run_tool "$SCR/o11" "$SCR/e11" --no-git --root "$T"
if [ "$RC" = 2 ] && grep -qF 'docs/.gitignore' "$SCR/e11"; then pass "case 11: symlinked docs/.gitignore refused, exit 2 naming it"; else fail "case 11: rc=$RC err=$(tr '\n' '|' < "$SCR/e11")"; fi

# --- 12: inputs that hang a backtracking matcher end within 10 s (WATCH_TICKS=50) with the right result
c12=""
T=$(new_tree); printf 'a*a*a*a*a*a*a*a*a*a*a*a*b\n' > "$T/.gitignore"
printf 'x\n' > "$T/docs/$(printf '%0200d' 0 | tr 0 a)"
plant "$T/c.md"
WATCH_TICKS=50 run_tool "$SCR/o12" "$SCR/e12" --no-git --root "$T"
[ "$RC" = 1 ] && grep -qxF "DANGLING c.md:1 $REF" "$SCR/o12" || c12="$c12 wildcard-rule(rc=$RC)"
T=$(new_tree); { printf '%200000s' ''; printf 'x\n'; } > "$T/.gitignore"
WATCH_TICKS=50 run_tool "$SCR/o12b" "$SCR/e12b" --no-git --root "$T"
[ "$RC" = 2 ] && grep -qF '.gitignore:1: .gitignore line longer than 1024 characters' "$SCR/e12b" || c12="$c12 long-line(rc=$RC)"
T=$(new_tree); { printf 'see .tad/'; printf '%200000s' '' | tr ' ' '.'; printf 'x here\n'; } > "$T/docs/dots.md"
WATCH_TICKS=50 run_tool "$SCR/o12c" "$SCR/e12c" --no-git --root "$T"
[ "$RC" = 0 ] && grep -q '0 dangling' "$SCR/e12c" || c12="$c12 dotted-ref(rc=$RC)"
if [ -z "$c12" ]; then pass "case 12: a*...*b rule on a 200-char name, a 200000-space line and a 200000-dot reference all end within 10 s (exit 1, 2, 0)"; else fail "case 12:$c12 (124 = still running after 10 s)"; fi

# --- 13: an unreadable directory: exit 2, one check-path-refs line, no stack trace
T=$(new_tree); mkdir "$T/locked"; chmod 000 "$T/locked"
run_tool "$SCR/o13" "$SCR/e13" --no-git --root "$T"
chmod 755 "$T/locked"
if [ "$RC" = 2 ] && grep -qxF 'check-path-refs: cannot read directory locked (EACCES)' "$SCR/e13" && ! grep -q '^    at ' "$SCR/e13"; then pass "case 13: unreadable directory ends with exit 2 and one message naming it, no stack trace"; else fail "case 13: rc=$RC err=$(head -3 "$SCR/e13" | tr '\n' '|')"; fi

# --- witness summary (cases 7-10: five spy-watched trees)
if [ "$W1_OK" = 5 ] && [ -z "$W1_BAD" ]; then pass "w1: the spy saw the walk (readdirSync of each root and an open of docs/ok.md in 5 trees)"; else fail "w1: spy did not see the walk in:$W1_BAD (ok=$W1_OK of 5)"; fi
if [ -z "$SPY_BAD" ] && [ "$SPY_CALLS" -gt 0 ]; then pass "no excluded path opened ($SPY_CALLS calls logged)"; else fail "excluded path touched:$SPY_BAD ($SPY_CALLS calls logged)"; fi

if [ "$FAILS" = 0 ]; then echo "RESULT: PASS"; exit 0; fi
echo "RESULT: FAIL ($FAILS)"
exit 1
