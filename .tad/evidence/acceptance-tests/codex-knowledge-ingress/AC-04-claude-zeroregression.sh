#!/bin/bash
# AC-04 — same-basename, same-date, frozen-.tad baseline/after comparison.
# The only registered normalizations are ts, Hook Last Touched, and snapshot
# filename. Trace dedup is intentionally compared as an observable behavior.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
BASELINE_REF=$(sed -n 's/^Repository HEAD before product edits: `\([0-9a-f][0-9a-f]*\)`.*/\1/p' \
  "$ROOT/.tad/evidence/acceptance-tests/codex-knowledge-ingress/baseline.md")
case "$BASELINE_REF" in
  [0-9a-f][0-9a-f][0-9a-f][0-9a-f]*) ;;
  *) echo 'BLOCK: immutable baseline commit is missing from baseline.md' >&2; exit 1 ;;
esac
git -C "$ROOT" cat-file -e "$BASELINE_REF^{commit}"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac4.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
BASE="$TMP/base/case"
AFTER="$TMP/after/case"

copy_file() {
  local mode="$1" rel="$2" target="$3"
  if [ "$mode" = baseline ]; then
    git -C "$ROOT" show "$BASELINE_REF:$rel" > "$target"
  else
    cp "$ROOT/$rel" "$target"
  fi
}

make_tree() {
  local mode="$1" tree="$2"
  mkdir -p "$tree/.tad/hooks/lib" "$tree/.tad/active/handoffs" \
    "$tree/.tad/active/epics" "$tree/.tad/evidence/ralph-loops" \
    "$tree/.tad/evidence/traces"
  for rel in \
    .tad/hooks/startup-health.sh \
    .tad/hooks/notebook-dormant-sync.sh \
    .tad/hooks/post-write-sync.sh \
    .tad/hooks/pre-gate-check.sh \
    .tad/hooks/pre-accept-check.sh \
    .tad/hooks/lib/askuser-capture.sh \
    .tad/hooks/lib/common.sh \
    .tad/hooks/lib/trace-writer.sh \
    .tad/hooks/lib/notebook-lifecycle.sh; do
    copy_file "$mode" "$rel" "$tree/$rel"
  done
  if [ "$mode" = after ]; then
    cp "$ROOT/.tad/hooks/lib/hook-envelope.sh" "$tree/.tad/hooks/lib/hook-envelope.sh"
  fi
  printf 'version: "2.39.0"\n' > "$tree/.tad/config.yaml"
  printf '%s\n' '# frozen completion fixture' > "$tree/.tad/active/handoffs/COMPLETION-20260803-fixture.md"
  printf '%s\n' 'Hook Last Touched: 2026-01-01T00:00:00Z' 'Last File Written: frozen.md' \
    > "$tree/.tad/active/session-state.md"
  printf '%s\n' 'frozen evidence' > "$tree/.tad/evidence/frozen.md"
  printf '%s\n' '# fixture handoff' > "$tree/.tad/active/handoffs/HANDOFF-20260803-fixture.md"
}

make_tree baseline "$BASE"
make_tree after "$AFTER"
[ "$(basename "$BASE")" = "$(basename "$AFTER")" ]
DAY_BEFORE=$(date +%F)

run_script() {
  local label="$1" tree="$2" script="$3" input="$4"
  local in_file="$TMP/${label}.input"
  printf '%s' "$input" > "$in_file"
  set +e
  (cd "$tree" && /bin/bash ".tad/hooks/$script" < "$in_file") \
    > "$TMP/${label}.stdout" 2> "$TMP/${label}.stderr"
  printf '%s\n' "$?" > "$TMP/${label}.rc"
  set -e
}

MATRIX=(
  'startup|startup-health.sh|{"source":"startup"}'
  'notebook|notebook-dormant-sync.sh|{}'
  'postwrite|post-write-sync.sh|{"tool_input":{"file_path":"README.md"}}'
  'pregate|pre-gate-check.sh|{"tool_name":"Other"}'
  'preaccept|pre-accept-check.sh|{"tool_name":"Other"}'
  'askuser|lib/askuser-capture.sh|'
)
for row in "${MATRIX[@]}"; do
  IFS='|' read -r name script input <<EOF
$row
EOF
  run_script "base-$name" "$BASE" "$script" "$input"
  run_script "after-$name" "$AFTER" "$script" "$input"
  cmp "$TMP/base-$name.stdout" "$TMP/after-$name.stdout"
  cmp "$TMP/base-$name.stderr" "$TMP/after-$name.stderr"
  cmp "$TMP/base-$name.rc" "$TMP/after-$name.rc"
  [ "$(cat "$TMP/base-$name.rc")" -eq 0 ]
done

run_write_twice() {
  local label="$1" tree="$2"
  local input='{"tool_input":{"file_path":".tad/active/handoffs/HANDOFF-20260803-fixture.md"}}'
  run_script "${label}-first" "$tree" post-write-sync.sh "$input"
  [ "$(cat "$TMP/${label}-first.rc")" -eq 0 ]
  local trace="$tree/.tad/evidence/traces/$(date +%F).jsonl"
  local first=0 second=0
  [ -f "$trace" ] && first=$(wc -l < "$trace" | tr -d ' ')
  run_script "${label}-second" "$tree" post-write-sync.sh "$input"
  [ "$(cat "$TMP/${label}-second.rc")" -eq 0 ]
  [ -f "$trace" ] && second=$(wc -l < "$trace" | tr -d ' ')
  printf '%s\n' "$first" > "$TMP/${label}-first-lines"
  printf '%s\n' "$second" > "$TMP/${label}-second-lines"
  [ $((second - first)) -eq 0 ]
}
run_write_twice base-trace "$BASE"
run_write_twice after-trace "$AFTER"

normalize_outputs() {
  local tree="$1" out="$2"
  : > "$out"
  find "$tree/.tad/active" "$tree/.tad/evidence" -type f -print 2>/dev/null \
    | LC_ALL=C sort \
    | while IFS= read -r file; do
        rel="${file#"$tree/"}"
        printf 'FILE:%s\n' "$rel"
        # Pre-registered filter only: ts, Hook Last Touched, snapshot filename.
        sed -E \
          -e 's/"ts":"[^"]*"/"ts":"<ts>"/g' \
          -e 's/^Hook Last Touched: .*/Hook Last Touched: <timestamp>/' \
          -e 's/snapshot-[0-9]{8}-[0-9]{6}-[^ ]+\.md/snapshot-<filename>.md/g' \
          "$file"
      done >> "$out"
}
DAY_AFTER=$(date +%F)
[ "$DAY_BEFORE" = "$DAY_AFTER" ] || { echo 'BLOCK: baseline/after crossed date boundary' >&2; exit 1; }
normalize_outputs "$BASE" "$TMP/base.normalized"
normalize_outputs "$AFTER" "$TMP/after.normalized"
cmp "$TMP/base.normalized" "$TMP/after.normalized"

printf '%s\n' 'AC-04 PASS: frozen same-basename Claude behavior matches; both second trace runs add 0 lines.'
