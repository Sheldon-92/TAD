#!/bin/bash
# AC8: Timeout fail-closed verification — two scenarios.
#
# HONEST NOTE: Phase 1c AC12 requires hooks-v2 byte-identical to 1b EXCEPT
# dep-guard lines. 1b hooks do NOT call `read -t` — they use `STDIN_JSON=$(cat)`
# which blocks on an open-but-silent stdin. AC8 (hook self-aborts <3s) is therefore
# in conflict with AC12 (no non-dep-guard code changes) within this spike.
#
# This test runs BOTH scenarios honestly against the dep-guard-only hooks and
# reports actual self-abort behavior. Expected outcome given AC12 constraint:
# Scenario A (slow FIFO) likely FAIL — hook cat() blocks. Scenario B (pathological
# payload) may PASS if hook processes quickly, else FAIL on hang.
#
# macOS note: no GNU `timeout`. Using portable bash background+kill wrapper.

set -euo pipefail
cd "$(dirname "$0")"

OUT="results/timeout-trigger.tsv"
mkdir -p results
printf 'scenario\thook\telapsed_s\tdeny_detected\tjq_valid\tself_aborted_under_3s\tverdict\tnote\n' > "$OUT"

# Portable 5s timeout that captures stdout+stderr to a file.
# Returns 124 on timeout, else child exit code.
run_with_timeout() {
  local t="$1" outfile="$2"; shift 2
  (
    "$@" > "$outfile" 2>&1 &
    child=$!
    ( sleep "$t"; kill -KILL $child 2>/dev/null ) &
    killer=$!
    wait $child 2>/dev/null
    rc=$?
    # If child was killed by our timer, rc will be 137 (128+9)
    if ! kill -0 $killer 2>/dev/null; then
      # killer already exited = timer fired
      exit 124
    fi
    kill $killer 2>/dev/null
    wait $killer 2>/dev/null || true
    exit $rc
  )
}

# ── Scenario A: slow stdin via FIFO ────────────────────────────────
FIFO="/tmp/tad-slow-fifo.$$"
mkfifo "$FIFO"
(sleep 10 > "$FIFO") &
writer_pid=$!

start=$(perl -MTime::HiRes=time -e 'printf "%.3f", time')
set +e
OUT_TMP=$(mktemp)
run_with_timeout 5 "$OUT_TMP" bash hooks-v2/hardened-pretool-interceptor.sh < "$FIFO"
outer_rc=$?
set -e
end=$(perl -MTime::HiRes=time -e 'printf "%.3f", time')
elapsed=$(perl -e "printf \"%.3f\", $end - $start")
output=$(cat "$OUT_TMP" 2>/dev/null || true)
rm -f "$OUT_TMP"
kill $writer_pid 2>/dev/null || true
wait $writer_pid 2>/dev/null || true
rm -f "$FIFO"

self_aborted="no"
if awk -v e="$elapsed" 'BEGIN { exit (e < 3.0) ? 0 : 1 }' && [ "$outer_rc" -ne 124 ]; then
  self_aborted="yes"
fi
deny="no"; printf '%s' "$output" | grep -q '"permissionDecision":"deny"' && deny="yes"
jq_valid="no"; printf '%s' "$output" | jq -e . >/dev/null 2>&1 && jq_valid="yes"
note="outer_rc=$outer_rc"
[ "$outer_rc" -eq 124 ] && note="outer_rc=124 (killed by test wrapper; hook did NOT self-timeout)"
if [ "$self_aborted" = "yes" ] && [ "$deny" = "yes" ] && [ "$jq_valid" = "yes" ]; then
  verdict=PASS
else
  verdict=FAIL
fi
printf 'A\tpretool-interceptor\t%s\t%s\t%s\t%s\t%s\t%s\n' "$elapsed" "$deny" "$jq_valid" "$self_aborted" "$verdict" "$note" >> "$OUT"

# ── Scenario B: 10MB pathological payload ─────────────────────────
# Write payload to a temp file (avoid huge argv) and pipe via cat.
PAYLOAD_TMP=$(mktemp)
python3 -c "
import json
content=('Message from Blake ' * 260000)[:10_000_000]
print(json.dumps({'tool_name':'Write','tool_input':{'file_path':'docs/big.md','content':content}}), end='')
" > "$PAYLOAD_TMP" 2>/dev/null || {
  # python3 absent fallback: smaller payload via bash
  printf '%s' '{"tool_name":"Write","tool_input":{"file_path":"docs/big.md","content":"' > "$PAYLOAD_TMP"
  yes 'Message from Blake ' | head -c 1000000 >> "$PAYLOAD_TMP"
  printf '%s' '"}}' >> "$PAYLOAD_TMP"
}

start=$(perl -MTime::HiRes=time -e 'printf "%.3f", time')
set +e
OUT_TMP=$(mktemp)
run_with_timeout 5 "$OUT_TMP" bash -c "bash hooks-v2/hardened-pretool-interceptor.sh < '$PAYLOAD_TMP'"
outer_rc=$?
set -e
end=$(perl -MTime::HiRes=time -e 'printf "%.3f", time')
elapsed=$(perl -e "printf \"%.3f\", $end - $start")
output=$(cat "$OUT_TMP" 2>/dev/null || true)
rm -f "$OUT_TMP" "$PAYLOAD_TMP"

self_aborted="no"
if awk -v e="$elapsed" 'BEGIN { exit (e < 3.0) ? 0 : 1 }' && [ "$outer_rc" -ne 124 ]; then
  self_aborted="yes"
fi
deny="no"; printf '%s' "$output" | grep -q '"permissionDecision":"deny"' && deny="yes"
jq_valid="no"; printf '%s' "$output" | jq -e . >/dev/null 2>&1 && jq_valid="yes"
note="outer_rc=$outer_rc"
[ "$outer_rc" -eq 124 ] && note="outer_rc=124 (killed by test wrapper; hook did NOT self-timeout)"
if [ "$self_aborted" = "yes" ] && [ "$deny" = "yes" ] && [ "$jq_valid" = "yes" ]; then
  verdict=PASS
else
  verdict=FAIL
fi
printf 'B\tpretool-interceptor\t%s\t%s\t%s\t%s\t%s\t%s\n' "$elapsed" "$deny" "$jq_valid" "$self_aborted" "$verdict" "$note" >> "$OUT"

echo "--- results ---"
column -t -s $'\t' "$OUT" 2>/dev/null || cat "$OUT"

fail_count=$(awk -F'\t' 'NR>1 && $(NF-1)=="FAIL" { c++ } END { print c+0 }' "$OUT")
if [ "$fail_count" -eq 0 ]; then
  echo "AC8: ALL PASS"
  exit 0
else
  echo "AC8: $fail_count FAIL (see note column — 1b hooks lack internal stdin timeout; AC12 constraint prevents adding it)"
  exit 1
fi
