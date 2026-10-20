#!/bin/bash
# gate3-sandbox-proof.sh — proves `gate3-check.sh rerun` leaves no side effect outside
# its box (re-plan p3-y6-replan-1; threat rows: gate3-threat-handoff.md).
# Everything happens in scratch directories made here (a scratch git repo standing in for
# the "real" repo, a scratch bare remote, a victim dir, a canary dir, a fake HOME holding a
# canary secret). The real repository, the real HOME and every real remote are never named
# by a row and never the cwd of one.
# Usage: bash gate3-sandbox-proof.sh [path/to/gate3-check.sh [path/to/gate3-threat-handoff.md]]
# Prints one summary line per check, then PROOF PASS, PROOF FAIL: <reason> or
# PROOF NOT-RUN: no sandbox on <uname -s>. Exit 0 on PASS or NOT-RUN, 1 on FAIL, 2 on
# a setup error (nothing was run).
here="$(cd "$(dirname "$0")" && pwd)"
g3="${1:-$here/../../../../hooks/lib/gate3-check.sh}"
g3="$(cd "$(dirname "$g3")" && pwd)/$(basename "$g3")"
threat="${2:-$here/gate3-threat-handoff.md}"
[ -f "$g3" ] && [ -f "$threat" ] || { echo "missing gate3-check.sh or the threat handoff" >&2; exit 2; }

uname_s=$(uname -s)
if ! { [ "$uname_s" = Darwin ] && [ -x /usr/bin/sandbox-exec ]; } && ! command -v bwrap >/dev/null 2>&1; then
  echo "PROOF NOT-RUN: no sandbox on $uname_s"
  exit 0
fi

REALHOME="${HOME:-}"
tadroot=$(git -C "$here" rev-parse --show-toplevel 2>/dev/null)

rdir() { (cd "$1" 2>/dev/null && pwd -P); }
mkroot() { # a scratch root outside the caller's HOME
  local d
  d=$(mktemp -d "${TMPDIR:-/tmp}/g3proof.XXXXXX" 2>/dev/null) || return 1
  d=$(rdir "$d") || return 1
  if [ -n "$REALHOME" ]; then
    case "$d/" in "$(rdir "$REALHOME")"/*) rm -rf "$d"; d=$(rdir "$(mktemp -d /tmp/g3proof.XXXXXX)") || return 1 ;; esac
  fi
  printf '%s\n' "$d"
}

ROOT=$(mkroot) || exit 2
CTL=$(mkroot) || exit 2
cleanup() {
  for d in "$ROOT" "$CTL"; do
    case "$d" in */g3proof.??????) chmod -R u+rwX "$d" >/dev/null 2>&1; rm -rf "$d" ;; esac
  done
}
trap cleanup EXIT
trap 'exit 1' INT TERM HUP

SECRET="G3CANARY-$$-$(date +%s)"

# setup_scratch <dir>: real repo (one pushed commit, one unpushed), bare remote, victim,
# canary dir, fake HOME with a secret, tmp, meta, out
setup_scratch() {
  local r="$1"
  mkdir -p "$r/victim" "$r/canary" "$r/fakehome/.ssh" "$r/tmp" "$r/meta" "$r/out" || return 1
  echo keep > "$r/victim/keep.txt"; echo keep > "$r/victim/f.txt"
  printf '%s\n' "$SECRET" > "$r/fakehome/.ssh/id_gate3_canary"
  (
    export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
    git init -q -b main "$r/real" 2>/dev/null || { git init -q "$r/real" && git -C "$r/real" checkout -q -b main; }
    git init -q --bare "$r/remote.git" || exit 1
    cd "$r/real" || exit 1
    git config user.email t@example.invalid; git config user.name t
    printf 'alpha beta gamma\n' > README.md; echo base > f.txt; echo base > canary.txt
    mkdir -p .tad/hooks/lib; echo 'echo ran-repo-script' > .tad/hooks/lib/hello.sh
    git add -A && git commit -q -m base || exit 1
    git remote add origin "$r/remote.git" && git push -q origin main 2>/dev/null || exit 1
    echo second > second.txt && git add second.txt && git commit -q -m second || exit 1
  ) || return 1
}

# snap <scratch root>: every path, mode, file checksum and symlink target below it
if stat -f '%Sp %N' / >/dev/null 2>&1; then STATF=(stat -f '%Sp %N'); else STATF=(stat -c '%A %n'); fi
snap() {
  (
    cd "$1" || exit 1
    P=(-path ./meta -o -path ./out -o -path ./tmp -o -path ./real/.git/index)
    find . \( "${P[@]}" \) -prune -o -print | LC_ALL=C sort
    find . \( "${P[@]}" \) -prune -o -print0 | xargs -0 "${STATF[@]}" 2>/dev/null | LC_ALL=C sort
    find . \( "${P[@]}" \) -prune -o -type f -exec cksum {} + 2>/dev/null | LC_ALL=C sort
    find . \( "${P[@]}" \) -prune -o -type l -exec sh -c 'for l; do printf "%s -> %s\n" "$l" "$(readlink "$l")"; done' _ {} + | LC_ALL=C sort
  )
}

setup_scratch "$ROOT" || { echo "scratch setup failed" >&2; exit 2; }
REAL="$ROOT/real"; REMOTE="$ROOT/remote.git"; VICTIM="$ROOT/victim"; CANARY="$ROOT/canary"; FAKEHOME="$ROOT/fakehome"

subst() { # <file in> <file out> <scratch root>
  sed "s|@REAL@|$3/real|g; s|@REMOTE@|$3/remote.git|g; s|@VICTIM@|$3/victim|g; s|@CANARY@|$3/canary|g; s|@FAKEHOME@|$3/fakehome|g" "$1" > "$2"
}
subst "$threat" "$ROOT/meta/threat.md" "$ROOT"
# nothing runs unless every substituted path is scratch and nothing real is named
for p in "$REAL" "$REMOTE" "$VICTIM" "$CANARY" "$FAKEHOME"; do
  case "$p" in "$ROOT"/*) ;; *) echo "path $p is not under the scratch root" >&2; exit 2 ;; esac
done
if grep -qE '@(REAL|REMOTE|VICTIM|CANARY|FAKEHOME)@' "$ROOT/meta/threat.md"; then echo "unsubstituted placeholder" >&2; exit 2; fi
if [ -n "$REALHOME" ] && [ "$REALHOME" != / ] && grep -qF -- "$REALHOME" "$ROOT/meta/threat.md"; then echo "a row names the real HOME" >&2; exit 2; fi
if [ -n "$tadroot" ] && grep -qF -- "$tadroot" "$ROOT/meta/threat.md"; then echo "a row names the real repo" >&2; exit 2; fi

nrows=$(grep -c '^| AC' "$ROOT/meta/threat.md")

snap "$ROOT" > "$ROOT/meta/before.txt"
tad_before=""
[ -n "$tadroot" ] && tad_before="$(git -C "$tadroot" rev-parse HEAD) $(git -C "$tadroot" for-each-ref | cksum)"

OUTF="$ROOT/out/rerun.md"
( cd "$REAL" && HOME="$FAKEHOME" bash "$g3" rerun "$ROOT/meta/threat.md" --out "$OUTF" --id proof ) > "$ROOT/meta/run.log" 2>&1 < /dev/null

snap "$ROOT" > "$ROOT/meta/after.txt"
tad_after=""
[ -n "$tadroot" ] && tad_after="$(git -C "$tadroot" rev-parse HEAD) $(git -C "$tadroot" for-each-ref | cksum)"

fail=""
note() { [ -n "$fail" ] || fail="$1"; }

[ -f "$OUTF" ] || { echo "PROOF FAIL: rerun wrote no output"; exit 1; }
sbline=$(grep -a -m1 '^sandbox: ' "$OUTF")
tool=$(printf '%s' "$sbline" | sed 's/^sandbox: \([^ ]*\).*/\1/')
echo "sandbox: $tool"

ran=$(grep -acE '^\| AC[0-9]+/R[0-9]+ \| [0-9]+ \|' "$OUTF")
notrun=$(grep -acE '^\| AC[0-9]+(/R[0-9]+)? \| not-run' "$OUTF")
echo "threat rows: $ran ran, $notrun not-run"
[ "$notrun" -eq 0 ] && [ "$ran" -eq "$nrows" ] || note "rows: $ran ran of $nrows, $notrun not-run ($sbline)"

diff "$ROOT/meta/before.txt" "$ROOT/meta/after.txt" > "$ROOT/meta/diff.txt"
neff=$(grep -c '^[<>]' "$ROOT/meta/diff.txt")
list=$(grep '^[<>]' "$ROOT/meta/diff.txt" | head -5 | tr '\n' ' ' | cut -c1-200)
echo "outside effects: $neff $list"
[ "$neff" -eq 0 ] || note "outside effects: $list"

nsec=$(grep -acF -- "$SECRET" "$OUTF")
echo "secret in out file: $nsec"
[ "$nsec" -eq 0 ] || note "the canary secret reached the output"

boxp=$(sed -n 's/^# box: \(.*\) (removed on exit)$/\1/p' "$OUTF" | head -1)
if [ -n "$boxp" ] && [ "$boxp" != none ] && [ ! -e "$boxp" ]; then echo "box removed: yes"; else echo "box removed: no"; note "box not removed: $boxp"; fi

if [ -n "$tadroot" ]; then
  [ "$tad_before" = "$tad_after" ] && echo "real repo refs: unchanged" || { echo "real repo refs: CHANGED"; note "the real repo's HEAD or refs changed"; }
fi

# control: the same filesystem rows (flagged ctl), one fresh scratch setup each, plain bash
# without any sandbox; each must change something, proving the rows are live
US=$(printf '\037')
awk -v us="$US" '
  /^\| AC[0-9]+ \|/ { n = split($0, c, "|"); if (c[3] ~ / ctl/) { r = c[5]; gsub(/ /, "", r); want[r] = 1 } next }
  /^R[0-9]+: / { id = substr($0, 1, index($0, ":") - 1); if (id in want) { print id us substr($0, index($0, ":") + 2) } }
' "$threat" > "$CTL/rows.txt"
k=0; nctl=0; noeff=""
while IFS= read -r line; do
  [ -n "$line" ] || continue
  rid="${line%%"$US"*}"; rcmd="${line#*"$US"}"
  nctl=$((nctl+1))
  d="$CTL/$nctl"
  setup_scratch "$d" || { note "control setup failed"; continue; }
  c=$(printf '%s' "$rcmd" | sed "s|@REAL@|$d/real|g; s|@REMOTE@|$d/remote.git|g; s|@VICTIM@|$d/victim|g; s|@CANARY@|$d/canary|g; s|@FAKEHOME@|$d/fakehome|g")
  snap "$d" > "$d/meta/before.txt"
  if command -v perl >/dev/null 2>&1; then
    ( cd "$d/real" && HOME="$d/fakehome" TMPDIR="$d/tmp" GIT_CONFIG_GLOBAL=/dev/null perl -e 'alarm shift; exec @ARGV' 60 bash -c "$c" ) > /dev/null 2>&1 < /dev/null
  else
    ( cd "$d/real" && HOME="$d/fakehome" TMPDIR="$d/tmp" GIT_CONFIG_GLOBAL=/dev/null bash -c "$c" ) > /dev/null 2>&1 < /dev/null
  fi
  snap "$d" > "$d/meta/after.txt"
  if cmp -s "$d/meta/before.txt" "$d/meta/after.txt"; then noeff="$noeff $rid"; else k=$((k+1)); fi
done < "$CTL/rows.txt"
echo "control: $k/$nctl filesystem rows had an effect without the sandbox"
[ -z "$noeff" ] || echo "control rows without an effect: $noeff"
[ "$nctl" -gt 0 ] && [ "$k" -eq "$nctl" ] || note "control: $k/$nctl rows were live without the sandbox"
# control read: the canary secret is readable without the sandbox
ctlread=$(cat "$FAKEHOME/.ssh/id_gate3_canary" 2>/dev/null)
[ "$ctlread" = "$SECRET" ] && echo "control read: secret readable without the sandbox" || note "control read failed"

if [ -z "$fail" ]; then echo "PROOF PASS"; exit 0; fi
echo "PROOF FAIL: $fail"
exit 1
