#!/bin/bash
# gate3-deny-proof.sh — proves `gate3-check.sh rerun` never runs an outward or
# destructive command. Everything happens in a scratch directory: a scratch git repo,
# a scratch bare remote, a scratch victim dir and a canary file. The real repo is
# never the cwd of a fixture command.
# Usage: bash gate3-deny-proof.sh [path/to/gate3-check.sh]
# Prints one summary line per check; exit 0 only when every check holds.
here="$(cd "$(dirname "$0")" && pwd)"
g3="${1:-$here/../../../../hooks/lib/gate3-check.sh}"
g3="$(cd "$(dirname "$g3")" && pwd)/$(basename "$g3")"
[ -f "$g3" ] || { echo "no gate3-check.sh at $g3" >&2; exit 2; }

W=$(mktemp -d) || exit 2
trap 'rm -rf "$W"' EXIT
git init -q "$W/repo" && git init -q --bare "$W/remote.git" || exit 2
V="$W/victim"; R="$W/remote.git"; C="$W/repo/canary.txt"
mkdir -p "$V" "$W/repo/.tad/hooks/lib"
echo keep > "$V/keep.txt"
echo base > "$C"
echo 'echo ran-repo-script' > "$W/repo/.tad/hooks/lib/hello.sh"
(
  cd "$W/repo" || exit 2
  git config user.email t@example.invalid; git config user.name t
  git remote add origin "$R"
  git add -A && git commit -q -m base && git branch -M main
) || exit 2
canary_sum=$(cksum < "$C")
head_sha=$(git -C "$W/repo" rev-parse HEAD)
files_before=$(cd "$W" && find . -path ./repo/.git -prune -o -type f -print | LC_ALL=C sort)

mkhandoff() { # <commands-file> <out-handoff>
  local n=0 line
  {
    echo "---"; echo "dispatch_id: proof"; echo "---"
    echo "## 9.1 Spec Compliance Checklist"
    echo "| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence |"
    echo "|---|---|---|---|---|"
    while IFS= read -r line || [ -n "$line" ]; do n=$((n+1)); echo "| AC$n | x | post-impl | R$n | x |"; done < "$1"
    echo; echo '```'
    n=0
    while IFS= read -r line || [ -n "$line" ]; do
      n=$((n+1))
      line=${line//@W@/$W}; line=${line//@V@/$V}; line=${line//@R@/$R}; line=${line//@C@/$C}
      printf 'R%s: %s\n' "$n" "$line"
    done < "$1"
    echo '```'
  } > "$2"
}

fail=0
run() { (cd "$W/repo" && bash "$g3" rerun "$1" --out "$2" --id proof >/dev/null 2>&1); }

mkhandoff "$here/gate3-deny-commands.txt" "$W/h-deny.md"
mkhandoff "$here/gate3-allow-commands.txt" "$W/h-allow.md"
run "$W/h-deny.md" "$W/o-deny.md"
run "$W/h-allow.md" "$W/o-allow.md"

nd=$(wc -l < "$here/gate3-deny-commands.txt" | tr -d ' ')
na=$(wc -l < "$here/gate3-allow-commands.txt" | tr -d ' ')
refused=$(grep -c '^| AC[0-9]*/R[0-9]* | not-run: ' "$W/o-deny.md")
ran_deny=$(grep -c '^| AC[0-9]*/R[0-9]* | [0-9][0-9]* |' "$W/o-deny.md")
ran_allow=$(grep -c '^| AC[0-9]*/R[0-9]* | [0-9][0-9]* |' "$W/o-allow.md")
echo "deny fixtures: $refused/$nd refused as not-run, $ran_deny executed"
echo "allow controls: $ran_allow/$na executed"
[ "$refused" -eq "$nd" ] && [ "$ran_deny" -eq 0 ] || { fail=1; echo "FAIL: some deny fixture was not refused:"; grep -v '^| AC[0-9]*/R[0-9]* | not-run: ' "$W/o-deny.md" | grep '^| AC' | cut -c1-160; }
[ "$ran_allow" -eq "$na" ] || { fail=1; echo "FAIL: a read-only control was refused:"; grep '^| AC[0-9]*/R[0-9]* | not-run: ' "$W/o-allow.md" | cut -c1-200; }

# side effects: nothing outward, nothing destroyed, nothing written
refs=$(git --git-dir="$R" for-each-ref | wc -l | tr -d ' ')
tags=$(git -C "$W/repo" tag | wc -l | tr -d ' ')
branches=$(git -C "$W/repo" branch --format='%(refname:short)' | tr '\n' ' ')
echo "remote refs: $refs; local tags: $tags; branches: $branches; HEAD unchanged: $([ "$(git -C "$W/repo" rev-parse HEAD)" = "$head_sha" ] && echo yes || echo NO)"
[ "$refs" -eq 0 ] && [ "$tags" -eq 0 ] && [ "$branches" = "main " ] && [ "$(git -C "$W/repo" rev-parse HEAD)" = "$head_sha" ] || { fail=1; echo "FAIL: git state changed"; }
[ -f "$V/keep.txt" ] && [ "$(cat "$V/keep.txt")" = keep ] && echo "victim dir intact: yes" || { fail=1; echo "FAIL: victim dir changed"; }
[ "$(cksum < "$C")" = "$canary_sum" ] && echo "canary unchanged: yes" || { fail=1; echo "FAIL: canary changed"; }
files_after=$(cd "$W" && find . -path ./repo/.git -prune -o -type f -print | LC_ALL=C sort)
extra=$(printf '%s\n' "$files_after" | grep -v -e '^./h-' -e '^./o-' | LC_ALL=C comm -13 <(printf '%s\n' "$files_before") - | tr '\n' ' ')
gone=$(printf '%s\n' "$files_after" | LC_ALL=C comm -23 <(printf '%s\n' "$files_before") - | tr '\n' ' ')
echo "new files: ${extra:-none}; removed files: ${gone:-none}"
[ -z "$extra" ] && [ -z "$gone" ] || { fail=1; echo "FAIL: a command wrote or removed a file"; }
[ "$fail" -eq 0 ] && echo "PROOF PASS" || echo "PROOF FAIL"
exit $fail
