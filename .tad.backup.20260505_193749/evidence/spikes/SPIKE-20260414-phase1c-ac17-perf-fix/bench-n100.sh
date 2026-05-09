#!/bin/bash
# AC5-7: N=100 single-run latency benchmark with per-hook hot-path fixtures.
# Clean measurement (no per-step instrumentation). Each hook gets its own fixture.
# Writes: results/bench-n100.tsv (400 raw samples), results/stats-summary.tsv (p50/p95/p99).

set -euo pipefail
set -o noclobber 2>/dev/null || true
cd "$(dirname "$0")"

OUT="results/bench-n100.tsv"
mkdir -p results
if [ -f "$OUT" ]; then
  mv "$OUT" "${OUT}.bak.$(date +%s)"
fi
printf 'hook\tsample\tlatency_ms\n' > "$OUT"

# Per-hook hot-path fixture + invocation mode
# evidence-validator uses $1 file path; others read stdin JSON
declare -a HOOKS=(pretool-interceptor override-detector evidence-validator bash-watcher)

SPIKE_ABS="$PWD"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"

run_hook() {
  local hook="$1"
  case "$hook" in
    evidence-validator)
      # Run from project root so git ls-files cross-check resolves the fixture's refs.
      (cd "$PROJECT_ROOT" && bash "$SPIKE_ABS/hooks-v2/hardened-${hook}.sh" "$SPIKE_ABS/test-fixtures/validator-handoff.md") > /dev/null 2>&1 || true
      ;;
    pretool-interceptor)
      bash "hooks-v2/hardened-${hook}.sh" < "test-fixtures/pretool-write.json" > /dev/null 2>&1 || true
      ;;
    override-detector)
      bash "hooks-v2/hardened-${hook}.sh" < "test-fixtures/override-env.json" > /dev/null 2>&1 || true
      ;;
    bash-watcher)
      bash "hooks-v2/hardened-${hook}.sh" < "test-fixtures/bash-rm.json" > /dev/null 2>&1 || true
      ;;
  esac
}

for hook in "${HOOKS[@]}"; do
  echo "Running $hook (N=100)..." >&2
  for i in $(seq 1 100); do
    # Two perl spawns per sample add ~14ms overhead (documented in SPIKE-REPORT).
    start=$(perl -MTime::HiRes=time -e 'printf "%.6f\n", time')
    run_hook "$hook"
    end=$(perl -MTime::HiRes=time -e 'printf "%.6f\n", time')
    latency_ms=$(perl -e "printf \"%.2f\n\", ($end - $start) * 1000")
    printf '%s\t%d\t%s\n' "$hook" "$i" "$latency_ms" >> "$OUT"
  done
done

# Compute p50/p95/p99 per hook (BSD awk compatible: use external sort -g)
set +o noclobber 2>/dev/null || true
rm -f results/stats-summary.tsv
printf 'hook\tp50\tp95\tp99\tn\n' > results/stats-summary.tsv
for hook in "${HOOKS[@]}"; do
  awk -F'\t' -v h="$hook" 'NR>1 && $1==h { print $3 }' "$OUT" | sort -g | \
    awk -v h="$hook" 'BEGIN{c=0} {a[++c]=$1} END{
      if (c==0) exit 1
      i50=int(c*0.5); if (i50<1) i50=1
      i95=int(c*0.95); if (i95<1) i95=1
      i99=int(c*0.99); if (i99<1) i99=1
      printf "%s\t%.2f\t%.2f\t%.2f\t%d\n", h, a[i50], a[i95], a[i99], c
    }' >> results/stats-summary.tsv
done
echo
echo "--- stats-summary.tsv ---"
column -t -s $'\t' results/stats-summary.tsv 2>/dev/null || cat results/stats-summary.tsv

# AC6: all hooks p95 < 100ms (blocking)
fail=0
while IFS=$'\t' read -r h p50 p95 p99 n; do
  [ "$h" = "hook" ] && continue
  if awk -v v="$p95" 'BEGIN { exit (v < 100.0) ? 0 : 1 }'; then
    :
  else
    echo "AC6 FAIL: $h p95=$p95 ms >= 100ms"
    fail=$((fail+1))
  fi
done < results/stats-summary.tsv

# AC7: sanity — at least 3 of 4 median < 50ms
below_50=0
while IFS=$'\t' read -r h p50 p95 p99 n; do
  [ "$h" = "hook" ] && continue
  if awk -v v="$p50" 'BEGIN { exit (v < 50.0) ? 0 : 1 }'; then
    below_50=$((below_50+1))
  fi
done < results/stats-summary.tsv

echo
if [ "$fail" -eq 0 ]; then
  echo "AC6: ALL hooks p95 < 100ms PASS"
else
  echo "AC6: $fail hook(s) over threshold"
fi
if [ "$below_50" -ge 3 ]; then
  echo "AC7: $below_50/4 hooks median < 50ms (sanity metric PASS)"
else
  echo "AC7: only $below_50/4 hooks median < 50ms (sanity metric non-blocking)"
fi

exit $((fail > 0 ? 1 : 0))
