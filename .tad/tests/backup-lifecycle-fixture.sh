#!/bin/bash
# backup-lifecycle-fixture.sh — acceptance cases for the backup lifecycle (update flow Phase 3).
#
# Usage: /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case ledger|classify|salvage|hold|clear|check-clear|caps|foreign|guard|all
#
# Every case runs in a mktemp sandbox with a scratch HOME and TAD_BACKUP_ROOT, `cd <dir> || exit 1`, and never touches a real
# project, ~/.tad-backups or ~/.cache/tad. `caps` and `check-clear` drive the real installer / helper through the existing
# fixtures (installer-data-safety-fixture.sh --case caps, tad-update-fixture.sh --case check-clear) and re-print their lines.
# Prints "  PASS: <case>: <text>" / "  FAIL: <case>: <text>", then VERDICT: PASS|FAIL (rc 0 iff PASS).
set -uo pipefail

FX_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO="$(cd "$FX_DIR/../.." && pwd -P)"
TB="$REPO/.tad/scripts/tad-backups.sh"
LEDGER="$REPO/.tad/provenance/framework-released.tsv"
GATE="$REPO/.tad/hooks/lib/release-verify.sh"
TAB=$'\t'
CASE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --case) CASE="${2:-}"; shift 2 ;;
    --help|-h) sed -n '2,3p' "$0"; exit 0 ;;
    *) echo "fixture: unknown option '$1'" >&2; exit 2 ;;
  esac
done
[ -n "$CASE" ] || { echo "fixture: --case is required" >&2; exit 2; }

PASS=0; FAIL=0
pass() { PASS=$((PASS + 1)); printf '  PASS: %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  FAIL: %s\n' "$1"; }

# ---------------------------------------------------------------- sandbox
SB=""; P=""; G=""; RB=""; ROOT=""
sb_new() {
  SB="$(mktemp -d /tmp/tad-bl.XXXXXX)" || { echo "fixture: mktemp failed" >&2; exit 2; }
  SB="$(cd "$SB" && pwd -P)"
  ROOT="$SB/root"
  mkdir -p "$ROOT" "$SB/home" "$SB/outside"
  chmod 700 "$ROOT"
  export TAD_BACKUP_ROOT="$ROOT" HOME="$SB/home"
}
sb_done() {
  case "$SB" in /private/tmp/tad-bl.*|/tmp/tad-bl.*) [ -d "$SB" ] && rm -rf "$SB" ;; esac
  SB=""
}
# a project plus its backup group and one run backup
mkp() {
  [ -n "$SB" ] || sb_new
  P="$SB/proj-${1:-a}"; G="$ROOT/proj-${1:-a}-grp"; RB="$G/20261022_100000"
  mkdir -p "$P/.tad" "$RB"
  printf 'layout=changed-only\nfiles=0\nbytes=0\nversion=4.0.5\n' > "$RB/manifest.txt"
  printf '%s\n' "$P" > "$RB/origin.txt"
}
tb() { ( cd "$P" && /bin/bash "$TB" "$@" ); }
lifecycle() { ( cd "$P" && /bin/bash "$TB" lifecycle --project "$P" --group-dir "$G" --run-backup "$RB" --ledger "${1:-$LEDGER}" 2>&1 ); }
# digest <dir> [excluded top name] — path+content digest of regular files and links
digest() {
  ( cd "$1" || exit 1
    { find . \( -path "./${2:-.nothing}" \) -prune -o -type f -print | while IFS= read -r f; do printf '%s %s\n' "$f" "$(cksum < "$f")"; done
      find . \( -path "./${2:-.nothing}" \) -prune -o -type l -print | while IFS= read -r l; do printf '%s -> %s\n' "$l" "$(readlink "$l")"; done
    } | LC_ALL=C sort | cksum )
}
filelist() { ( cd "$1" && find . -type f | LC_ALL=C sort ); }
edited_cfg_live() { git -C "$REPO" show v4.0.5:.tad/config.yaml > "$P/.tad/config.yaml"; }
EDIT_LINE='my_team_rule: keep handoffs short'
# scenario: live .tad/config.yaml = a released copy; an older .tad-backup dir and the run backup hold the project's edit
scenario_edited() {
  mkp "${1:-a}"
  edited_cfg_live
  local v
  mkdir -p "$P/.tad-backup"
  for v in 4.0.0-to-4.0.1 4.0.1-to-4.0.2 4.0.2-to-4.0.3 4.0.3-to-4.0.4; do
    mkdir -p "$P/.tad-backup/$v"
    printf 'report %s\n' "$v" > "$P/.tad-backup/$v/MIGRATION-REPORT.tsv"
  done
  mkdir -p "$P/.tad-backup/4.0.0-to-4.0.1/.tad"
  { cat "$P/.tad/config.yaml"; printf '%s\n' "$EDIT_LINE"; } > "$P/.tad-backup/4.0.0-to-4.0.1/.tad/config.yaml"
  mkdir -p "$RB/.tad"
  { cat "$P/.tad/config.yaml"; printf '%s\n' "$EDIT_LINE"; } > "$RB/.tad/config.yaml"
  printf 'my own notes\n' > "$RB/notes"
  lifecycle >/dev/null
}
item_with() { # <name inside payload> -> the item dir holding it
  local d
  for d in "$G"/holding/h*/; do [ -e "${d}payload/$1" ] && { printf '%s' "${d%/}"; return 0; }; done
  return 1
}
mode_of() { stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1" 2>/dev/null; }

# ================================================================ ledger
case_ledger() {
  sb_new
  local C="$SB/clone" a b hid rows tag n=0 miss=0 t
  git clone -q --no-hardlinks "$REPO" "$C" >/dev/null 2>&1 || { fail "ledger: could not clone the repository"; sb_done; return; }
  cp "$REPO/.tad/scripts/gen-framework-provenance.sh" "$C/.tad/scripts/gen-framework-provenance.sh"
  cp "$GATE" "$C/.tad/hooks/lib/release-verify.sh"
  cp "$REPO/.tad/hooks/lib/derive-sync-set.sh" "$C/.tad/hooks/lib/derive-sync-set.sh"
  gc() { ( cd "$C" && git -c user.name=t -c user.email=t@t.invalid -c commit.gpgsign=false "$@" ); }
  ( cd "$C" && /bin/bash .tad/scripts/gen-framework-provenance.sh >/dev/null 2>&1 ) || { fail "ledger: generator failed in the clone"; sb_done; return; }
  a="$(cksum < "$C/.tad/provenance/framework-released.tsv")"
  ( cd "$C" && /bin/bash .tad/scripts/gen-framework-provenance.sh >/dev/null 2>&1 )
  b="$(cksum < "$C/.tad/provenance/framework-released.tsv")"
  if [ "$a" = "$b" ] && [ "$(cat "$C/.tad/provenance/framework-released.sha1")" = "$(git -C "$C" hash-object "$C/.tad/provenance/framework-released.tsv")" ]; then
    pass "ledger: generator is byte-stable"
  else fail "ledger: generator output changed between two runs ($a vs $b)"; fi
  gc add -f .tad/provenance/framework-released.tsv .tad/provenance/framework-released.sha1 >/dev/null 2>&1
  gc commit -q -m "ledger" >/dev/null 2>&1
  mkdir -p "$C/.tad/templates"; printf 'a new framework blob\n' > "$C/.tad/templates/x.md"
  gc add .tad/templates/x.md >/dev/null 2>&1; gc commit -q -m "add x" >/dev/null 2>&1
  b="$( cd "$C" && /bin/bash .tad/hooks/lib/release-verify.sh framework-provenance . 2>&1 )"; n=$?
  if [ "$n" = "1" ] && printf '%s\n' "$b" | grep -qF '.tad/templates/x.md'; then pass "ledger: gate fails on a new framework blob and names it"
  else fail "ledger: gate did not fail naming the new file (rc=$n): $(printf '%s' "$b" | tail -3 | tr '\n' '|')"; fi
  ( cd "$C" && /bin/bash .tad/scripts/gen-framework-provenance.sh >/dev/null 2>&1 )
  gc add -f .tad/provenance/framework-released.tsv .tad/provenance/framework-released.sha1 >/dev/null 2>&1
  gc commit -q -m "regenerate" >/dev/null 2>&1
  b="$( cd "$C" && /bin/bash .tad/hooks/lib/release-verify.sh framework-provenance . 2>&1 )"; n=$?
  if [ "$n" = "0" ] && printf '%s\n' "$b" | tail -1 | grep -qF 'VERDICT: framework-provenance PASS (exit 0)'; then pass "ledger: gate passes after regeneration"
  else fail "ledger: gate did not pass after regeneration (rc=$n): $(printf '%s' "$b" | tail -3 | tr '\n' '|')"; fi
  # every tag's installer heredoc is a row
  while IFS= read -r tag; do
    [ -n "$tag" ] || continue
    hid="$(git -C "$REPO" show "${tag}:tad.sh" 2>/dev/null | sed -n "/<< *'HOOKS_EOF'/,/^ *HOOKS_EOF\$/p" | sed '1d;$d' | git hash-object --stdin)"
    [ "$hid" = "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391" ] && continue
    n=$((n + 1))
    grep -qF -e "$hid" "$C/.tad/provenance/framework-released.tsv" || { miss=$((miss + 1)); echo "    heredoc of $tag not in the ledger"; }
  done <<< "$(git -C "$REPO" tag -l 'v*')"
  if [ "$miss" = "0" ]; then pass "ledger: every tag heredoc is covered"; else fail "ledger: $miss tag heredocs are not in the ledger"; fi
  sb_done
}

# ================================================================ classify
case_classify() {
  sb_new
  mkp c
  local D="$SB/copy" out id lab first want t okc=1
  mkdir -p "$D/.tad-backup/x" "$D/.tad/templates"
  cd "$D" || exit 1
  # (a) a released file
  git -C "$REPO" show v4.0.3:.tad/templates/handoff-a-to-b.md > a.md
  id="$(git hash-object a.md)"
  out="$(/bin/bash "$TB" classify --ledger "$LEDGER" --project "$P" a.md)"
  lab="$(printf '%s' "$out" | cut -f2)"
  if [ "$(printf '%s' "$out" | cut -f1)" = "released" ] && printf '%s' "$lab" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$' && [ "$(git -C "$REPO" rev-parse "${lab}:.tad/templates/handoff-a-to-b.md" 2>/dev/null)" = "$id" ]; then
    pass "classify: released file labelled with its first tag"
  else fail "classify: released file wrong: $out"; fi
  # (b) the generated hooks.json heredoc (first tag whose tad.sh holds it)
  git -C "$REPO" show "v3.0.0:tad.sh" | sed -n "/<< *'HOOKS_EOF'/,/^ *HOOKS_EOF\$/p" | sed '1d;$d' > hooks.json
  id="$(git hash-object hooks.json)"; first=""
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    if [ "$(git -C "$REPO" show "${t}:tad.sh" 2>/dev/null | sed -n "/<< *'HOOKS_EOF'/,/^ *HOOKS_EOF\$/p" | sed '1d;$d' | git hash-object --stdin)" = "$id" ]; then first="$t"; break; fi
  done <<< "$(git -C "$REPO" tag -l 'v*' --sort=version:refname)"
  out="$(/bin/bash "$TB" classify --ledger "$LEDGER" --project "$P" hooks.json)"
  if [ "$(printf '%s' "$out" | cut -f1)" = "released" ] && [ "$(printf '%s' "$out" | cut -f2)" = "gen:${first}:codex-hooks" ]; then
    pass "classify: v3.0.0 hooks.json labelled gen:v3.0.0"
  else fail "classify: v3.0.0 hooks.json wrong (want gen:${first}:codex-hooks): $out"; fi
  # (c) a blob only a main commit carried
  git -C "$REPO" show 165b2a39:AGENTS.md > AGENTS.md.pre-tad.20260101-000000
  out="$(/bin/bash "$TB" classify --ledger "$LEDGER" --project "$P" AGENTS.md.pre-tad.20260101-000000)"
  if [ "$(printf '%s' "$out" | cut -f1)" = "released" ] && printf '%s' "$out" | cut -f2 | grep -q '^main@165b2a39'; then
    pass "classify: main-commit AGENTS.md labelled main@165b2a39"
  else fail "classify: main-commit AGENTS.md wrong: $out"; fi
  # (d) one edited line of a released file, the project's current file at that path being the released copy
  mkdir -p "$P/.tad/templates"
  cp a.md "$P/.tad/templates/handoff-a-to-b.md"
  mkdir -p .tad-backup/y/.tad/templates
  { cat a.md; echo 'one edited line'; } > .tad-backup/y/.tad/templates/handoff-a-to-b.md
  out="$(/bin/bash "$TB" classify --ledger "$LEDGER" --project "$P" .tad-backup/y/.tad/templates/handoff-a-to-b.md)"
  if [ "$(printf '%s' "$out" | cut -f1)" = "edited" ] && [ "$(printf '%s' "$out" | cut -f2)" = "$lab" ]; then
    pass "classify: one edited line of a released file is edited"
  else fail "classify: edited file wrong (want edited $lab): $out"; fi
  # (e) a TAD report
  printf 'x\n' > .tad-backup/x/MIGRATION-REPORT.tsv
  out="$(/bin/bash "$TB" classify --ledger "$LEDGER" --project "$P" .tad-backup/x/MIGRATION-REPORT.tsv)"
  [ "$(printf '%s' "$out" | cut -f1)" = "tad-report" ] && pass "classify: MIGRATION-REPORT.tsv is tad-report" || fail "classify: report wrong: $out"
  # (f) a CLAUDE.md pre-image that is a prefix of the live file
  printf '# my rules\nkeep me\n' > CLAUDE.md.pre-tad.20260101-000000
  { cat CLAUDE.md.pre-tad.20260101-000000; printf '<!-- block -->\n@AGENTS.md\n'; } > "$P/CLAUDE.md"
  out="$(/bin/bash "$TB" classify --ledger "$LEDGER" --project "$P" CLAUDE.md.pre-tad.20260101-000000)"
  [ "$(printf '%s' "$out" | cut -f1)" = "in-project" ] && pass "classify: prefix of the live file is in-project" || fail "classify: prefix wrong: $out"
  # (g) a corrupted .sha1
  mkdir -p "$SB/badledger"; cp "$LEDGER" "$SB/badledger/framework-released.tsv"; printf '%s\n' 0000000000000000000000000000000000000000 > "$SB/badledger/framework-released.sha1"
  out="$(/bin/bash "$TB" classify --ledger "$SB/badledger/framework-released.tsv" --project "$P" a.md hooks.json AGENTS.md.pre-tad.20260101-000000)"
  if [ "$(printf '%s\n' "$out" | cut -f1 | sort -u)" = "unknown" ] && [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" = "3" ]; then
    pass "classify: broken ledger makes every file unknown"
  else fail "classify: broken ledger wrong: $out"; fi
  cd "$FX_DIR" || exit 1
  sb_done
}

# ================================================================ salvage
SECRETS='b3BlbnNzaC1rZXktdjE|AKIAFIXTUREKEY00000|fixtureSecretXYZ123|sk-ant-fixture-0000|BEGIN OPENSSH PRIVATE KEY|'"$EDIT_LINE"
no_content() { # <text> -> 0 when no secret/edit substring appears
  printf '%s\n' "$1" | grep -qE "$SECRETS" && return 1
  printf '%s\n' "$1" | grep -qF -e "$(head -1 "$P/.tad/config.yaml")" && return 1
  return 0
}
case_salvage() {
  sb_new
  scenario_edited a
  local it id out dpath abs before after n dest rcx secrets_ok=1 f ok1=1
  it="$(item_with 4.0.0-to-4.0.1)"; id="${it##*/}"
  abs="$it/payload/4.0.0-to-4.0.1/.tad/config.yaml"
  out="$(tb salvage 2>&1)"
  dpath="$(printf '%s\n' "$out" | sed -n 's/.*\.tad\/config\.yaml (edited [^)]*): +1 -0 lines; diff: \(.*\) (open it yourself)$/\1/p' | head -1)"
  if [ -n "$dpath" ] && printf '%s\n' "$out" | grep -qF "destination: .tad/project-knowledge/salvage/$(date +%Y%m%d)-.tad__config.yaml" \
     && printf '%s\n' "$out" | grep -qF "To absorb: /bin/bash .tad/scripts/tad-backups.sh absorb --from $abs --yes"; then
    pass "salvage: edited entry prints path, class, line counts, diff file and destination"
  else fail "salvage: edited entry wrong: $(printf '%s' "$out" | head -8 | tr '\n' '|')"; fi
  if [ -f "$dpath" ] && [ "$(mode_of "$dpath")" = "600" ] && [ "$(dirname "$dpath")" = "$it/salvage-diff" ] && grep -qxF "+$EDIT_LINE" "$dpath" \
     && [ -f "$G/20261022_100000/salvage-diff/.tad__config.yaml.diff" ] && grep -qxF "+$EDIT_LINE" "$G/20261022_100000/salvage-diff/.tad__config.yaml.diff"; then
    pass "salvage: the diff file sits beside the backup bytes and holds the change"
  else fail "salvage: diff file wrong ($dpath mode=$(mode_of "$dpath" 2>/dev/null))"; fi
  # (d) secret-bearing files that are not TAD files
  mkdir -p "$P/src"; : > "$P/src/empty-counterpart.key"
  printf -- '-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAAB\n-----END OPENSSH PRIVATE KEY-----\n' > "$SB/key.txt"
  # a held item with the secret files: an older .tad-backup dir, held by a second lifecycle run
  mkdir -p "$P/.tad-backup/4.0.0-to-4.0.0/.ssh" "$P/.tad-backup/4.0.0-to-4.0.0/.claude" "$P/.tad-backup/4.0.0-to-4.0.0/src"
  cp "$SB/key.txt" "$P/.tad-backup/4.0.0-to-4.0.0/.ssh/id_rsa"
  cp "$SB/key.txt" "$P/.tad-backup/4.0.0-to-4.0.0/notes"
  printf '{"aws_access_key_id":"AKIAFIXTUREKEY00000","aws_secret_access_key":"fixtureSecretXYZ123"}\n' > "$P/.tad-backup/4.0.0-to-4.0.0/credentials.json"
  printf '{"env":{"ANTHROPIC_API_KEY":"sk-ant-fixture-0000"}}\n' > "$P/.tad-backup/4.0.0-to-4.0.0/.claude/settings.json"
  cp "$SB/key.txt" "$P/.tad-backup/4.0.0-to-4.0.0/src/empty-counterpart.key"
  lifecycle >/dev/null
  local sec; sec="$(item_with 4.0.0-to-4.0.0)"
  before="$(digest "$P")"
  out="$(tb salvage 2>&1)"; rcx="$(printf '%s\n' "$out"; for f in .ssh/id_rsa notes credentials.json .claude/settings.json src/empty-counterpart.key; do tb absorb --from "$sec/payload/4.0.0-to-4.0.0/$f" --yes 2>&1; done)"
  if no_content "$rcx"; then pass "salvage: no file content reaches the output, edited included"; else fail "salvage: file content reached the output"; fi
  if printf '%s\n' "$out" | grep -qF 'id_rsa' && printf '%s\n' "$out" | grep -qF 'credentials.json' && printf '%s\n' "$out" | grep -qF 'empty-counterpart.key'; then ok1=1; else ok1=0; fi
  for f in .ssh/id_rsa notes credentials.json .claude/settings.json src/empty-counterpart.key; do
    tb absorb --from "$sec/payload/4.0.0-to-4.0.0/$f" --yes >/dev/null 2>&1 && { secrets_ok=0; echo "    absorb accepted $f"; }
  done
  after="$(digest "$P")"
  if [ "$secrets_ok" = "1" ] && [ "$ok1" = "1" ] && [ "$before" = "$after" ]; then pass "salvage: a file not from a TAD file is not absorbable"; else fail "salvage: a non-TAD file was absorbable or unlisted (ok1=$ok1 secrets_ok=$secrets_ok)"; fi
  # declining leaves the digest unchanged
  before="$(digest "$P")"; tb salvage >/dev/null 2>&1; tb absorb --from "$abs" >/dev/null 2>&1
  after="$(digest "$P")"
  [ "$before" = "$after" ] && pass "salvage: declining leaves the project digest unchanged" || fail "salvage: the project changed without a yes"
  # absorb writes exactly one file
  filelist "$P" > "$SB/before.lst"
  out="$(tb absorb --from "$abs" --yes 2>&1)"
  filelist "$P" > "$SB/after.lst"
  dest="$P/.tad/project-knowledge/salvage/$(date +%Y%m%d)-.tad__config.yaml"
  n="$(LC_ALL=C comm -13 "$SB/before.lst" "$SB/after.lst" | wc -l | tr -d ' ')"
  if [ "$n" = "1" ] && [ "$(head -n 1 "$dest")" = "from $abs, $(date +%Y-%m-%d)" ] && tail -n +2 "$dest" | cmp -s - "$abs" && [ "$(LC_ALL=C comm -23 "$SB/before.lst" "$SB/after.lst" | wc -l | tr -d ' ')" = "0" ] \
     && no_content "$out"; then
    pass "salvage: absorb writes one file with the source line and nothing else"
  else fail "salvage: absorb result wrong (new files=$n): $out"; fi
  # the absorbed item is clearable; clearing it removes its diff
  local ck tok
  ck="$(tb clearable 2>&1)"; tok="$(printf '%s\n' "$ck" | sed -n 's/^token\t//p')"
  if [ -d "$it/salvage-diff" ] && [ "$(printf '%s\n' "$ck" | sed -n 's/^clear_n\t//p')" -ge 1 ] 2>/dev/null; then
    tb clear --all --token "$tok" --yes >/dev/null 2>&1
    if [ ! -e "$it" ] && [ -d "$sec" ]; then pass "salvage: absorbed item becomes clearable and clearing removes its diff"; else fail "salvage: absorbed item not cleared with its diff (exists=$([ -e "$it" ] && echo y || echo n))"; fi
  else fail "salvage: absorbed item is not clearable: $ck"; fi
  sb_done
  # (f) a symlinked destination is never written through
  scenario_edited b
  abs="$G/20261022_100000/.tad/config.yaml"; dest="$P/.tad/project-knowledge/salvage/$(date +%Y%m%d)-.tad__config.yaml"
  mkdir -p "$P/.tad/project-knowledge/salvage"
  ln -s "$SB/outside/x" "$dest"
  tb absorb --from "$abs" --yes >/dev/null 2>&1
  local f1=0
  [ ! -e "$SB/outside/x" ] && [ -f "$dest.2" ] || f1=1
  rm -f "$dest"; mkdir -p "$SB/outside/d"; ln -s "$SB/outside/d" "$dest"
  tb absorb --from "$abs" --yes >/dev/null 2>&1
  [ -z "$(ls -A "$SB/outside/d")" ] || f1=1
  local sym k
  for k in tad pk salvage; do
    scenario_edited "s$k"
    abs="$G/20261022_100000/.tad/config.yaml"
    mkdir -p "$SB/outside/$k"
    case "$k" in
      tad) mv "$P/.tad" "$P/.tad.real"; ln -s "$SB/outside/$k" "$P/.tad" ;;
      pk) mkdir -p "$P/.tad"; ln -s "$SB/outside/$k" "$P/.tad/project-knowledge" ;;
      salvage) mkdir -p "$P/.tad/project-knowledge"; ln -s "$SB/outside/$k" "$P/.tad/project-knowledge/salvage" ;;
    esac
    tb absorb --from "$abs" --yes >/dev/null 2>&1
    [ -z "$(ls -A "$SB/outside/$k")" ] || { f1=1; echo "    $k: the symlink target gained a file"; }
  done
  if [ "$f1" = "0" ]; then pass "salvage: a symlinked destination is never written through"; else fail "salvage: a symlinked destination was written through or refused wrongly"; fi
  sb_done
  # (g) a symlinked diff dir
  sb_new; mkp d; edited_cfg_live
  mkdir -p "$P/.tad-backup"
  for k in 4.0.0-to-4.0.1 4.0.1-to-4.0.2 4.0.2-to-4.0.3 4.0.3-to-4.0.4; do mkdir -p "$P/.tad-backup/$k"; printf 'r\n' > "$P/.tad-backup/$k/MIGRATION-REPORT.tsv"; done
  mkdir -p "$P/.tad-backup/4.0.0-to-4.0.1/.tad"; { cat "$P/.tad/config.yaml"; printf '%s\n' "$EDIT_LINE"; } > "$P/.tad-backup/4.0.0-to-4.0.1/.tad/config.yaml"
  lifecycle >/dev/null
  it="$(item_with 4.0.0-to-4.0.1)"; mkdir -p "$SB/outside/sd"
  ln -s "$SB/outside/sd" "$it/salvage-diff"
  out="$(tb salvage 2>&1)"
  if printf '%s\n' "$out" | grep -qF 'diff not written' && [ -z "$(ls -A "$SB/outside/sd")" ]; then pass "salvage: a symlinked diff dir is never written through"; else fail "salvage: symlinked diff dir mishandled: $(printf '%s' "$out" | head -4 | tr '\n' '|')"; fi
  sb_done
}

# ================================================================ hold
case_hold() {
  sb_new
  scenario_edited a
  local n_before n_after held a b names bad=0 d name
  # the two newest target versions stay, the older ones sit byte-identical in holding
  if [ -d "$P/.tad-backup/4.0.2-to-4.0.3" ] && [ -d "$P/.tad-backup/4.0.3-to-4.0.4" ] && [ ! -e "$P/.tad-backup/4.0.0-to-4.0.1" ] && [ ! -e "$P/.tad-backup/4.0.1-to-4.0.2" ] \
     && [ "$(cat "$(item_with 4.0.1-to-4.0.2)/payload/4.0.1-to-4.0.2/MIGRATION-REPORT.tsv")" = "report 4.0.1-to-4.0.2" ] \
     && cmp -s "$(item_with 4.0.0-to-4.0.1)/payload/4.0.0-to-4.0.1/.tad/config.yaml" "$RB/.tad/config.yaml"; then
    pass "hold: items leave the project and sit byte-identical in holding"
  else fail "hold: the older dirs are not held as expected: $(ls "$P/.tad-backup" | tr '\n' ' ')"; fi
  # nothing deleted: a second project with the same shape, file counts before and after
  sb_done; sb_new; mkp a; edited_cfg_live
  mkdir -p "$P/.tad-backup"
  for d in 4.0.0-to-4.0.1 4.0.1-to-4.0.2 4.0.2-to-4.0.3 4.0.3-to-4.0.4; do mkdir -p "$P/.tad-backup/$d"; printf 'r %s\n' "$d" > "$P/.tad-backup/$d/MIGRATION-REPORT.tsv"; printf 'r2\n' > "$P/.tad-backup/$d/removed.txt"; done
  n_before="$(( $(find "$P" -type f | wc -l) + $(find "$G" -type f | wc -l) ))"
  lifecycle >/dev/null
  held="$(find "$G/holding" -path '*/payload/*' -type f | wc -l | tr -d ' ')"
  n_after="$(( $(find "$P" -type f | wc -l) + $(find "$G" -type f -not -path '*/holding/*' | wc -l) + held ))"
  a="$(( n_before + 1 ))"   # + the run backup's classes.tsv written by the lifecycle
  b="$(find "$G" -type f -name classes.tsv -not -path '*/holding/*' | wc -l | tr -d ' ')"
  if [ "$held" = "4" ] && [ "$n_after" = "$(( n_before + b ))" ] && [ "$(find "$G/holding" -type f -name deletions.log | wc -l | tr -d ' ')" = "0" ]; then
    pass "hold: nothing deleted"
  else fail "hold: file count not conserved (before=$n_before after=$n_after held=$held classes=$b)"; fi
  for d in "$G"/*; do
    name="${d##*/}"
    case "$name" in holding) continue ;; esac
    printf '%s' "$name" | grep -qE '^[0-9]{8}_[0-9]{6}(\.[0-9]+)?$' || bad=1
  done
  for d in "$G"/holding/*; do
    name="${d##*/}"
    printf '%s' "$name" | grep -qE '^[0-9]{8}_[0-9]{6}(\.[0-9]+)?$' && bad=1
  done
  [ "$bad" = "0" ] && pass "hold: holding names never match the backup pattern" || fail "hold: a name under the group is neither holding nor a backup name"
  sb_done
  # (d) a symlinked .tad-backup is refused
  sb_new; mkp a; edited_cfg_live
  mkdir -p "$SB/outside/tb"
  for d in 4.0.0-to-4.0.1 4.0.1-to-4.0.2 4.0.2-to-4.0.3 4.0.3-to-4.0.4; do mkdir -p "$SB/outside/tb/$d"; printf 'r\n' > "$SB/outside/tb/$d/MIGRATION-REPORT.tsv"; done
  ln -s "$SB/outside/tb" "$P/.tad-backup"
  a="$(digest "$SB/outside")"
  lifecycle >/dev/null
  b="$(digest "$SB/outside")"
  if [ "$a" = "$b" ] && [ "$(ls "$SB/outside/tb" | wc -l | tr -d ' ')" = "4" ] && [ -z "$(find "$G/holding" -path '*/payload/*' 2>/dev/null)" ]; then pass "hold: a symlinked .tad-backup is refused and nothing moves"
  else fail "hold: a symlinked .tad-backup was followed"; fi
  sb_done
  # (e) nothing to hold still leaves a marked holding area that salvage finds
  sb_new; mkp a; edited_cfg_live
  printf 'own\n' > "$RB/notes"
  lifecycle >/dev/null
  if [ -d "$G/holding" ] && [ "$(head -n 1 "$G/holding/.tad-holding")" = "$P" ] && tb salvage 2>&1 | grep -qF 'notes ('; then pass "hold: a run that holds nothing still leaves a marked holding area"
  else fail "hold: a run with nothing to hold left no marked holding area / salvage did not find it"; fi
  sb_done
}

# ================================================================ clear
case_clear() {
  sb_new
  scenario_edited a
  # the 4.0.1-to-4.0.2 item (reports only) is clearable; make a review item too
  local out tok ids before after id n log rc
  mkdir -p "$P/.tad-backup/4.0.0-to-4.0.0"; printf 'mine\n' > "$P/.tad-backup/4.0.0-to-4.0.0/notes"
  lifecycle >/dev/null
  out="$(tb list 2>&1)"
  tok="$(printf '%s\n' "$out" | sed -n 's/^To clear: .*--token \([0-9]*\) --yes$/\1/p')"
  if printf '%s\n' "$out" | grep -qE 'KB' && printf '%s\n' "$out" | grep -qF 'Total:' && [ -n "$tok" ] && printf '%s\n' "$out" | grep -qF 'Not touched:'; then
    pass "clear: list shows items with sizes and a token"
  else fail "clear: list output wrong: $(printf '%s' "$out" | tail -5 | tr '\n' '|')"; fi
  before="$(digest "$G/holding")"
  tb clear --all --token "$tok" >/dev/null 2>&1
  after="$(digest "$G/holding")"
  [ "$before" = "$after" ] && pass "clear: no yes, nothing deleted" || fail "clear: something changed without --yes"
  ids="$(tb clearable | sed -n 's/^clear_n\t//p')"   # the one reports-only item
  tb clear --all --token "$tok" --yes >/dev/null 2>&1; rc=$?
  n="$(ls -d "$G"/holding/h*/ 2>/dev/null | wc -l | tr -d ' ')"
  if [ "$rc" = "0" ] && [ "$ids" = "1" ] && [ "$n" = "2" ] && [ -n "$(item_with 4.0.0-to-4.0.0)" ] && [ -n "$(item_with 4.0.0-to-4.0.1)" ]; then
    pass "clear: yes with the token deletes exactly the listed items"
  else fail "clear: wrong result (rc=$rc clearable=$ids left=$n)"; fi
  log="$G/holding/deletions.log"
  if [ "$(wc -l < "$log" | tr -d ' ')" = "1" ] && [ "$(awk -F'\t' 'NF==6' "$log" | wc -l | tr -d ' ')" = "1" ] && grep -qF "清掉" "$log" && grep -qF "$P/.tad-backup/" "$log"; then
    pass "clear: one log line per item"
  else fail "clear: deletions.log wrong: $(cat "$log" 2>/dev/null | tr '\n' '|')"; fi
  sb_done
  # stale token
  scenario_edited a
  out="$(tb list 2>&1)"; tok="$(printf '%s\n' "$out" | sed -n 's/^To clear: .*--token \([0-9]*\) --yes$/\1/p')"
  mkdir -p "$P/.tad-backup/4.0.0-to-4.0.0"; printf 'r\n' > "$P/.tad-backup/4.0.0-to-4.0.0/MIGRATION-REPORT.tsv"; lifecycle >/dev/null
  before="$(digest "$G/holding")"
  tb clear --all --token "$tok" --yes >/dev/null 2>&1; rc=$?
  after="$(digest "$G/holding")"
  [ "$rc" != "0" ] && [ "$before" = "$after" ] && pass "clear: stale token deletes nothing" || fail "clear: a stale token deleted something (rc=$rc)"
  sb_done
  # (e) incomplete metadata is held for review
  scenario_edited a
  local a1="$G/holding/h20260101-000001" a2="$G/holding/h20260101-000002"
  mkdir -p "$a1/payload/x" "$a2/payload/x"
  printf 'kind\ttad-backup\norigin\t/x\nproject\t%s\nheld\t2026-01-01\n' "$P" > "$a1/item.tsv"; printf 'r\n' > "$a1/payload/x/MIGRATION-REPORT.tsv"
  printf 'kind\ttad-backup\norigin\t/y\nproject\t%s\nheld\t2026-01-01\nbytes\t4\nfiles\t2\nclassified\tx\n' "$P" > "$a2/item.tsv"
  printf 'r\n' > "$a2/payload/x/MIGRATION-REPORT.tsv"; printf 'r\n' > "$a2/payload/x/removed.txt"
  printf 'tad-report\t-\tx/MIGRATION-REPORT.tsv\n' > "$a2/classes.tsv"
  out="$(tb list 2>&1)"; tok="$(printf '%s\n' "$out" | sed -n 's/^To clear: .*--token \([0-9]*\) --yes$/\1/p')"
  tb clear --all --token "$tok" --yes >/dev/null 2>&1
  if [ -d "$a1" ] && [ -d "$a2" ] && printf '%s\n' "$out" | grep -F 'h20260101-000001' | grep -qF 'held for review' && printf '%s\n' "$out" | grep -F 'h20260101-000002' | grep -qF 'held for review'; then
    pass "clear: an item without complete metadata is held for review, not cleared"
  else fail "clear: an incomplete item was cleared or not flagged"; fi
  sb_done
  # (f) a symlinked holding area is refused
  scenario_edited a
  mkdir -p "$SB/outside/fake/h20260101-000009/payload"
  printf '%s\n' "$P" > "$SB/outside/fake/.tad-holding"
  printf 'kind\ttad-backup\norigin\t/z\nproject\t%s\nheld\t2026-01-01\nbytes\t0\nfiles\t0\nclassified\tx\n' "$P" > "$SB/outside/fake/h20260101-000009/item.tsv"
  : > "$SB/outside/fake/h20260101-000009/classes.tsv"
  mv "$G/holding" "$G/holding.real"; ln -s "$SB/outside/fake" "$G/holding"
  before="$(digest "$SB/outside")"
  rc=0
  { tb list; tb clearable; tb clear --all --token 1 --yes; tb clear --id h20260101-000009 --token 1 --yes; tb salvage; tb absorb --from "$SB/outside/fake/h20260101-000009/payload/x" --yes; } >"$SB/refuse.out" 2>&1 || true
  after="$(digest "$SB/outside")"
  if [ "$before" = "$after" ] && [ -d "$SB/outside/fake/h20260101-000009" ] && ! grep -q 'clear_n	[1-9]' "$SB/refuse.out" && ! grep -q 'Cleared h' "$SB/refuse.out"; then pass "clear: a symlinked holding area is refused and nothing is deleted"
  else fail "clear: a symlinked holding area was used"; fi
  sb_done
  # (g) review items stay unless discarded one by one
  scenario_edited a
  mkdir -p "$P/.tad-backup/4.0.0-to-4.0.0"; printf 'mine\n' > "$P/.tad-backup/4.0.0-to-4.0.0/notes"; lifecycle >/dev/null
  local rv; rv="$(item_with 4.0.0-to-4.0.0)"; id="${rv##*/}"
  out="$(tb list 2>&1)"; tok="$(printf '%s\n' "$out" | sed -n 's/^To clear: .*--token \([0-9]*\) --yes$/\1/p')"
  tb clear --all --token "$tok" --yes >/dev/null 2>&1
  local kept=0; [ -d "$rv" ] && kept=1
  out="$(tb salvage 2>&1)"
  local dline; dline="$(printf '%s\n' "$out" | grep -F "clear --id $id " | sed 's/^ *To discard: //')"
  tb ${dline#*tad-backups.sh } >/dev/null 2>&1
  if [ "$kept" = "1" ] && [ -n "$dline" ] && [ ! -e "$rv" ] && grep -F "$id" "$G/holding/deletions.log" | grep -qF 'discard'; then pass "clear: review items stay unless discarded one by one"
  else fail "clear: review item handling wrong (kept=$kept dline=$dline)"; fi
  sb_done
}

# ================================================================ foreign
case_foreign() {
  sb_new
  scenario_edited a
  local before after out tok other rc
  mkdir -p "$SB/other-proj"
  mkdir -p "$ROOT/other-aaaa/20260101_000000" "$ROOT/other-aaaa/holding/h20260101-000000/payload" "$ROOT/gone1-bbbb/20260101_000000" "$ROOT/gone2-cccc/20260101_000000" "$ROOT/noowner-dddd/20260101_000000"
  printf '%s\n' "$SB/other-proj" > "$ROOT/other-aaaa/20260101_000000/origin.txt"; : > "$ROOT/other-aaaa/20260101_000000/manifest.txt"
  printf '%s\n' "$SB/other-proj" > "$ROOT/other-aaaa/holding/.tad-holding"
  printf 'kind\ttad-backup\norigin\t/q\nproject\t%s\nheld\t2026-01-01\nbytes\t0\nfiles\t0\nclassified\tx\n' "$SB/other-proj" > "$ROOT/other-aaaa/holding/h20260101-000000/item.tsv"
  : > "$ROOT/other-aaaa/holding/h20260101-000000/classes.tsv"
  printf '%s\n' /nonexistent/gone1 > "$ROOT/gone1-bbbb/20260101_000000/origin.txt"; : > "$ROOT/gone1-bbbb/20260101_000000/manifest.txt"
  printf '%s\n' /nonexistent/gone2 > "$ROOT/gone2-cccc/20260101_000000/origin.txt"; : > "$ROOT/gone2-cccc/20260101_000000/manifest.txt"
  printf 'bundle bytes\n' > "$ROOT/tad-feat.bundle"
  chmod 700 "$ROOT"
  # the foreign set = everything under the root except this project's group
  foreign_digest() { digest "$ROOT" "$(basename "$G")"; }
  before="$(foreign_digest)"
  lifecycle >/dev/null
  out="$(tb list 2>&1)"; tok="$(printf '%s\n' "$out" | sed -n 's/^To clear: .*--token \([0-9]*\) --yes$/\1/p')"
  tb clear --all --token "$tok" --yes >/dev/null 2>&1
  tb salvage >/dev/null 2>&1
  after="$(foreign_digest)"
  [ "$before" = "$after" ] && pass "foreign: a non-installer file in the root is untouched" || fail "foreign: the root's foreign entries changed"
  [ -f "$ROOT/tad-feat.bundle" ] && [ -d "$ROOT/other-aaaa/holding/h20260101-000000" ] && pass "foreign: another live project's group is untouched" || fail "foreign: another live project's group changed"
  if printf '%s\n' "$out" | grep -qF 'Not touched: 2 backup groups whose project no longer exists' && printf '%s\n' "$out" | grep -qF '1 groups with no known owner' && [ -d "$ROOT/gone1-bbbb" ] && [ -d "$ROOT/gone2-cccc" ]; then
    pass "foreign: orphan groups are listed, not touched"
  else fail "foreign: orphan listing wrong: $(printf '%s' "$out" | grep 'Not touched')"; fi
  rc=0; tb clear --id h20260101-000000 --token 1 --yes >/dev/null 2>&1 || rc=$?
  if [ "$rc" != "0" ] && [ -d "$ROOT/other-aaaa/holding/h20260101-000000" ] && [ "$(foreign_digest)" = "$before" ]; then pass "foreign: clear refuses an item outside this project's holding"
  else fail "foreign: clear touched or accepted a foreign item (rc=$rc)"; fi
  # (e) this project's group dir is a symlink to another live project's group
  sb_done; sb_new
  scenario_edited a
  mkdir -p "$SB/other-proj" "$ROOT/other-aaaa/20260101_000000" "$ROOT/other-aaaa/holding/h20260101-000000/payload"
  printf '%s\n' "$SB/other-proj" > "$ROOT/other-aaaa/20260101_000000/origin.txt"; : > "$ROOT/other-aaaa/20260101_000000/manifest.txt"
  printf '%s\n' "$SB/other-proj" > "$ROOT/other-aaaa/holding/.tad-holding"
  printf 'kind\ttad-backup\norigin\t/q\nproject\t%s\nheld\t2026-01-01\nbytes\t0\nfiles\t0\nclassified\tx\n' "$SB/other-proj" > "$ROOT/other-aaaa/holding/h20260101-000000/item.tsv"
  : > "$ROOT/other-aaaa/holding/h20260101-000000/classes.tsv"
  local real="$SB/real-grp"
  mv "$G" "$real"; ln -s "$ROOT/other-aaaa" "$G"
  before="$(digest "$ROOT/other-aaaa")"
  { tb list; tb clear --all --token 1 --yes; tb absorb --from "$ROOT/other-aaaa/holding/h20260101-000000/payload/x" --yes; tb salvage; tb clearable; } >"$SB/refuse.out" 2>&1 || true
  after="$(digest "$ROOT/other-aaaa")"
  if [ "$before" = "$after" ] && ! grep -q 'Cleared h' "$SB/refuse.out" && ! grep -q 'clear_n	[1-9]' "$SB/refuse.out"; then pass "foreign: a symlinked group is refused"
  else fail "foreign: a symlinked group was used"; fi
  sb_done
}

# ================================================================ guard
case_guard() {
  sb_new
  local g="$SB/g" out rc
  mkdir -p "$g/.tad/scripts"
  cp "$REPO/tad.sh" "$g/tad.sh"; cp "$TB" "$g/.tad/scripts/tad-backups.sh"
  printf '\nzz_unmarked() { rm -rf "$1"; }\n' >> "$g/.tad/scripts/tad-backups.sh"
  out="$(/bin/bash "$GATE" installer-destructive-guard "$g" 2>&1)"; rc=$?
  if [ "$rc" = "1" ] && printf '%s\n' "$out" | grep -qE 'tad-backups\.sh:[0-9]+'; then pass "guard: unmarked rm in tad-backups.sh is refused"
  else fail "guard: unmarked rm in tad-backups.sh not refused (rc=$rc): $(printf '%s' "$out" | tail -3 | tr '\n' '|')"; fi
  out="$(/bin/bash "$GATE" installer-destructive-guard "$REPO" 2>&1)"; rc=$?
  if [ "$rc" = "0" ] && printf '%s\n' "$out" | grep -qF 'tad-backups.sh' && printf '%s\n' "$out" | tail -1 | grep -qF 'VERDICT: installer-destructive-guard PASS (exit 0)'; then pass "guard: repository passes"
  else fail "guard: repository run wrong (rc=$rc): $(printf '%s' "$out" | tail -3 | tr '\n' '|')"; fi
  sb_done
}

# ================================================================ delegated: caps (installer fixture), check-clear (helper fixture)
delegate() { # <script> <case> <prefix>
  local out rc=0 l
  out="$(/bin/bash "$1" --case "$2" 2>&1)" || rc=$?
  while IFS= read -r l; do
    case "$l" in
      "  ✅ $3"*) pass "${l#  ✅ }" ;;
      "  ❌ $3"*) fail "${l#  ❌ }" ;;
      "  PASS: $3"*) pass "${l#  PASS: }" ;;
      "  FAIL: $3"*) fail "${l#  FAIL: }" ;;
    esac
  done <<< "$out"
  if [ "$rc" != "0" ] && [ "$FAIL" = "0" ]; then fail "$3 the delegated run exited $rc: $(printf '%s' "$out" | tail -3 | tr '\n' '|')"; fi
}
case_caps() { delegate "$FX_DIR/installer-data-safety-fixture.sh" caps "caps:"; }
case_check_clear() { delegate "$FX_DIR/tad-update-fixture.sh" check-clear "check-clear:"; }

case "$CASE" in
  ledger) case_ledger ;;
  classify) case_classify ;;
  salvage) case_salvage ;;
  hold) case_hold ;;
  clear) case_clear ;;
  check-clear) case_check_clear ;;
  caps) case_caps ;;
  foreign) case_foreign ;;
  guard) case_guard ;;
  all) case_guard; case_classify; case_hold; case_salvage; case_clear; case_foreign; case_ledger; case_caps; case_check_clear ;;
  *) echo "fixture: unknown case '$CASE'" >&2; exit 2 ;;
esac
echo ""
echo "=== Summary: PASS=$PASS FAIL=$FAIL ==="
if [ "$FAIL" -gt 0 ]; then echo "VERDICT: FAIL"; exit 1; fi
echo "VERDICT: PASS"
exit 0
