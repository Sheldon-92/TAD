#!/bin/bash
# test-runner.sh — One-click driver for Phase 1a spike.
#
# Runs:
#   (a) exp3 on 3 evidence fixtures
#   (b) exp2 on 3 override fixtures
#   (c) exp1 on 4 pretool fixtures (30 runs each + 3 warm-up)
#   (d) exp1 per-step latency breakdown (30 runs on match-missing, CHECKPOINTs enabled)
#   (e) exp1 fail-closed test (malformed stdin)
#
# Must be run from project root (TAD/). Uses relative paths throughout.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"
SPIKE=".tad/evidence/spikes/SPIKE-20260413-quality-enforcement"
RESULTS="$SPIKE/results"
FIX="$SPIKE/test-fixtures"

mkdir -p "$RESULTS"
# Clear previous results
: > "$RESULTS/exp1-latencies-ms.tsv"
: > "$RESULTS/exp1-decisions.tsv"
: > "$RESULTS/exp2-override.log"
: > "$RESULTS/exp3-validation-output.tsv"
: > "$RESULTS/failclosed-test-output.tsv"

# ───────────────────────────────────────────────────────
# (a) exp3 — evidence validator on 3 fixtures
# ───────────────────────────────────────────────────────
echo "[1/5] Running exp3 on 3 fixtures..."
{
  printf 'fixture\texit\tstderr\n'
  for f in fake-empty-review.md fake-missing-keyword.md fake-valid-review.md; do
    stderr=$(bash "$SPIKE/exp3-evidence-validator.sh" "$FIX/$f" 2>&1 >/dev/null) && exit_code=0 || exit_code=$?
    # escape tabs/newlines in stderr
    stderr_esc=$(printf '%s' "$stderr" | tr '\t\n' '  ')
    printf '%s\t%s\t%s\n' "$f" "$exit_code" "$stderr_esc"
  done
} > "$RESULTS/exp3-validation-output.tsv"

# ───────────────────────────────────────────────────────
# (b) exp2 — override detector on 3 fixtures
#     Reset log, run 3 fixtures, capture log changes.
# ───────────────────────────────────────────────────────
echo "[2/5] Running exp2 on 3 fixtures..."
mkdir -p .tad/evidence/overrides
: > .tad/evidence/overrides/spike-test.log
{
  printf 'fixture\texit\tlog_lines_after\n'
  for f in minimal-stdin-override-valid.json minimal-stdin-override-too-short.json minimal-stdin-override-not-present.json; do
    bash "$SPIKE/exp2-override-detector.sh" < "$FIX/$f" >/dev/null
    ec=$?
    lines=$(wc -l < .tad/evidence/overrides/spike-test.log | tr -d ' ')
    printf '%s\t%s\t%s\n' "$f" "$ec" "$lines"
  done
  echo "--- log content ---"
  cat .tad/evidence/overrides/spike-test.log
} > "$RESULTS/exp2-override.log"

# ───────────────────────────────────────────────────────
# (c) exp1 — decisions on 4 fixtures (functional correctness)
#     Seed evidence for the match-ok scenario first.
# ───────────────────────────────────────────────────────
echo "[3/5] Running exp1 decisions on 4 fixtures..."
# Seed spike-default dir (match-ok fixture has file_path without HANDOFF-, uses default slug)
mkdir -p .tad/evidence/reviews/blake/spike-default
cp "$FIX/seed-evidence/"*.md .tad/evidence/reviews/blake/spike-default/
# Ensure quality-enforcement-spike dir is empty (match-missing fixture uses this slug)
rm -rf .tad/evidence/reviews/blake/quality-enforcement-spike

{
  printf 'fixture\tdecision\treason_excerpt\n'
  for f in minimal-stdin-pretool-match-missing.json minimal-stdin-pretool-match-ok.json minimal-stdin-pretool-no-match.json minimal-stdin-pretool-malformed.json; do
    out=$(bash "$SPIKE/exp1-pretool-interceptor.sh" < "$FIX/$f" 2>/dev/null || true)
    decision=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "unknown"' 2>/dev/null || echo "unknown")
    reason=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null || echo "")
    reason_exc=$(printf '%s' "$reason" | head -c 80 | tr '\t\n' '  ')
    printf '%s\t%s\t%s\n' "$f" "$decision" "$reason_exc"
  done
} > "$RESULTS/exp1-decisions.tsv"

# ───────────────────────────────────────────────────────
# (d) exp1 — per-step latency (N=30 + 3 warm-up)
#     Using match-missing fixture (exercises full path: jq → awk → slug → find → deny)
# ───────────────────────────────────────────────────────
echo "[4/5] Running exp1 latency benchmark (3 warm-up + 30 measurements)..."
LAT_TMP=$(mktemp)
WARMUP=3
N=30

# Header — two sets of total: _instrumented (with CHECKPOINTs, includes perl overhead)
# and _uninstrumented (clean production latency, measured externally via perl wrapper)
printf 'run\ttotal_instr_ms\ttotal_clean_ms\tjq_ms\tawk_ms\tslug_ms\tfind_ms\tpostfind_ms\n' > "$RESULTS/exp1-latencies-ms.tsv"

for i in $(seq 1 $((WARMUP + N))); do
  : > "$LAT_TMP"
  # Run 1: instrumented (with CHECKPOINTs) — for per-step breakdown
  TAD_SPIKE_LATENCY_LOG="$LAT_TMP" bash "$SPIKE/exp1-pretool-interceptor.sh" < "$FIX/minimal-stdin-pretool-match-missing.json" >/dev/null

  # Run 2: UNINSTRUMENTED — for true production latency
  # Measure externally via perl wrapper (~7ms overhead, subtracted conceptually)
  clean_ns=$(perl -MTime::HiRes=time -e '
    my $t1 = time();
    system("bash", $ARGV[0]) == 0 or die;
    my $t2 = time();
    printf "%d\n", ($t2-$t1)*1e9;
  ' -- "$SPIKE/exp1-pretool-interceptor.sh" < "$FIX/minimal-stdin-pretool-match-missing.json" 2>/dev/null | tail -1)
  # The line above runs the hook twice via perl system() and measures. But perl's system()
  # uses exec/fork — overhead similar to bash call. Let's simplify:
  t1=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1e9')
  bash "$SPIKE/exp1-pretool-interceptor.sh" < "$FIX/minimal-stdin-pretool-match-missing.json" >/dev/null
  t2=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1e9')
  clean_ns=$((t2 - t1))
  clean_ms=$(python3 -c "print(f'{$clean_ns/1e6:.3f}')")

  if [ "$i" -le "$WARMUP" ]; then continue; fi
  run_num=$((i - WARMUP))

  # Parse checkpoint ns timestamps into per-step ms via python (portable, no bc)
  CLEAN_MS="$clean_ms" python3 - "$LAT_TMP" <<'PY' >> "$RESULTS/exp1-latencies-ms.tsv"
import sys
path = sys.argv[1]
cp = {}
with open(path) as f:
  for line in f:
    parts = line.strip().split('\t')
    if len(parts) == 2:
      cp[parts[0]] = int(parts[1])
# Compute deltas in ms
def ms(a, b):
  if a in cp and b in cp:
    return f"{(cp[b]-cp[a])/1e6:.3f}"
  return "NA"
start = cp.get('start')
# Find the terminal checkpoint
end_keys = ['end_allow_tool', 'end_allow_nomatch', 'end_deny', 'end_allow_ok']
end = next((cp[k] for k in end_keys if k in cp), None)
total = f"{(end-start)/1e6:.3f}" if start and end else "NA"
jq_ms = ms('start', 'jq_done')
awk_ms = ms('jq_done', 'awk_match') if 'awk_match' in cp else "NA"
slug_ms = ms('awk_match', 'slug_done') if 'slug_done' in cp else "NA"
find_ms = ms('slug_done', 'find_done') if 'find_done' in cp else "NA"
postfind_ms = ms('find_done', end_keys[2]) if 'end_deny' in cp else "NA"
# run number will be appended externally
import os
run = os.environ.get('RUN_NUM', '?')
clean = os.environ.get('CLEAN_MS', 'NA')
print(f"{run}\t{total}\t{clean}\t{jq_ms}\t{awk_ms}\t{slug_ms}\t{find_ms}\t{postfind_ms}")
PY
done

# Post-process: we didn't pass RUN_NUM env. Fix by renumbering sequentially.
# Actually the loop above passes via env? No — we didn't export. Let me renumber externally.
python3 - "$RESULTS/exp1-latencies-ms.tsv" <<'PY'
import sys
path = sys.argv[1]
with open(path) as f:
  lines = f.readlines()
header = lines[0]
data = lines[1:]
out = [header]
for i, line in enumerate(data, 1):
  parts = line.rstrip('\n').split('\t')
  parts[0] = str(i)
  out.append('\t'.join(parts) + '\n')
with open(path, 'w') as f:
  f.writelines(out)
PY

rm -f "$LAT_TMP"

# ───────────────────────────────────────────────────────
# (e) exp1 fail-closed test (malformed stdin)
# ───────────────────────────────────────────────────────
echo "[5/5] Running fail-closed test..."
{
  printf 'fixture\tdecision\treason\n'
  out=$(bash "$SPIKE/exp1-pretool-interceptor.sh" < "$FIX/minimal-stdin-pretool-malformed.json" 2>/dev/null || true)
  decision=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "unknown"' 2>/dev/null || echo "unknown")
  reason=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null || echo "")
  printf '%s\t%s\t%s\n' "minimal-stdin-pretool-malformed.json" "$decision" "$reason"
} > "$RESULTS/failclosed-test-output.tsv"

# ───────────────────────────────────────────────────────
# Summary: median + p95 + max
# ───────────────────────────────────────────────────────
echo ""
echo "=== Latency Summary (exp1 match-missing, N=$N) ==="
python3 - "$RESULTS/exp1-latencies-ms.tsv" <<'PY'
import sys, statistics
path = sys.argv[1]
with open(path) as f:
  lines = f.readlines()[1:]
instr=[]; clean=[]; jq_vals=[]; awk_vals=[]; slug_vals=[]; find_vals=[]; post_vals=[]
for l in lines:
  p = l.strip().split('\t')
  if len(p) < 8: continue
  try:
    instr.append(float(p[1]))
    if p[2]!='NA': clean.append(float(p[2]))
    jq_vals.append(float(p[3]))
    if p[4]!='NA': awk_vals.append(float(p[4]))
    if p[5]!='NA': slug_vals.append(float(p[5]))
    if p[6]!='NA': find_vals.append(float(p[6]))
    if p[7]!='NA': post_vals.append(float(p[7]))
  except: pass
def stats(name, vals):
  if not vals:
    print(f"  {name}: no data")
    return
  s = sorted(vals)
  med = statistics.median(s)
  p95 = s[int(len(s)*0.95)] if len(s)>1 else s[0]
  mx = max(s)
  print(f"  {name:18s} median={med:7.3f} ms  p95={p95:7.3f} ms  max={mx:7.3f} ms  (n={len(vals)})")
print("--- CLEAN (uninstrumented, production latency) ---")
stats("TOTAL_clean", clean)
print("--- Per-step (instrumented, includes ~7ms/checkpoint perl overhead) ---")
stats("jq", jq_vals)
stats("awk", awk_vals)
stats("slug", slug_vals)
stats("find", find_vals)
stats("postfind", post_vals)
stats("TOTAL_instr", instr)
PY

echo ""
echo "=== Cleanup ==="
rm -rf .tad/evidence/reviews/blake/spike-default
echo "Done. Results in $RESULTS/"
ls -la "$RESULTS/"
