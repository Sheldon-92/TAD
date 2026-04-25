#!/bin/bash
# askuser-bench.sh — N=100 latency benchmark for askuser-capture.sh (P5.2 NFR1)
# Target: median <50ms, p95 <100ms (architecture.md 2026-04-07 lesson)
# Methodology: perl Time::HiRes wall-clock, NOT python3 (architecture.md 2026-04-14 lesson)
#
# Output: .tad/evidence/fixtures/phase5/askuser-latency-N100.tsv (iter\tms_wall)
#         .tad/evidence/fixtures/phase5/askuser-latency-summary.md (median/p95)

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
HOOK="$REPO_ROOT/.tad/hooks/lib/askuser-capture.sh"
TSV="$REPO_ROOT/.tad/evidence/fixtures/phase5/askuser-latency-N100.tsv"
SUMMARY="$REPO_ROOT/.tad/evidence/fixtures/phase5/askuser-latency-summary.md"

N="${1:-100}"

# Verify perl Time::HiRes available
if ! perl -MTime::HiRes -e 1 2>/dev/null; then
  echo "ERROR: perl Time::HiRes not available; cannot run latency bench" >&2
  exit 1
fi

# Synthetic envelope (canonical shape per §0 spike confirmation)
ENVELOPE='{
  "session_id":"bench-session",
  "cwd":"'"$REPO_ROOT"'",
  "tool_input":{"questions":[{"question":"bench?","options":[{"label":"X"},{"label":"Y"},{"label":"Z"}],"multiSelect":false}]},
  "tool_response":{"answers":{"bench?":"X"}}
}'

# Pre-warm — first call may include FS cache cold start
printf '%s' "$ENVELOPE" | bash "$HOOK" > /dev/null 2>&1
printf '%s' "$ENVELOPE" | bash "$HOOK" > /dev/null 2>&1

# Reset TSV
echo -e "iter\tms_wall" > "$TSV"

i=0
while [ "$i" -lt "$N" ]; do
  i=$((i + 1))
  ms=$(perl -MTime::HiRes=time -e '
    my $t0 = time();
    system("bash", "'"$HOOK"'");
    my $t1 = time();
    printf "%.3f\n", ($t1 - $t0) * 1000;
  ' 0<<<"$ENVELOPE")
  printf '%d\t%s\n' "$i" "$ms" >> "$TSV"
done

# Compute median + p95 — pipe sorted ms column into awk (BSD awk has no asort)
SUMMARY_LINE=$(awk -F'\t' 'NR>1 {print $2}' "$TSV" | sort -n | awk '
  {n++; a[n]=$1}
  END {
    if (n==0) {print "no data"; exit}
    median = a[int(n*0.5)+1]
    p95 = a[int(n*0.95)+1]
    p99 = a[int(n*0.99)+1]
    printf "median=%.0f p95=%.0f p99=%.0f n=%d\n", median, p95, p99, n
  }
')

cat > "$SUMMARY" <<EOF
# askuser-capture.sh Latency Benchmark (P5.2 NFR1)

**Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Methodology**: perl Time::HiRes wall-clock per call, N=$N
**Target**: median < 50ms AND p95 < 100ms (architecture.md "Hook Performance" 2026-04-07)

## Results

\`\`\`
$SUMMARY_LINE
\`\`\`

Raw data: \`askuser-latency-N100.tsv\` ($N rows + header)

## Verdict

$(awk -F'\t' 'NR>1 {print $2}' "$TSV" | sort -n | awk '
  {n++; a[n]=$1}
  END {
    median = a[int(n*0.5)+1]
    p95 = a[int(n*0.95)+1]
    if (median < 50 && p95 < 100)
      printf "✅ PASS — median=%.0fms (<50) and p95=%.0fms (<100)\n", median, p95
    else
      printf "❌ FAIL — median=%.0fms p95=%.0fms (one or both miss target)\n", median, p95
  }
')

## Caveats

- Dev-host measurement (concurrent processes may inflate); CI dedicated runner would be tighter
- N=$N samples; for production gate use N≥100 (architecture.md "Perf Gate Measurement" 2026-04-14)
EOF

echo "$SUMMARY_LINE"
