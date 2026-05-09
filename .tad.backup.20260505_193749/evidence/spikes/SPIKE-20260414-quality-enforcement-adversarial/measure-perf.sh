#!/bin/bash
# AC7: performance measurement on hardened hooks.
# Threshold: median < 75ms, p95 < 100ms (gated on AC4 PASS).
# Uses perl -MTime::HiRes (Phase 1a lesson: never use python3 for hook timing on macOS).
# N=30 per hook, 3 warm-up discarded.

set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SPIKE=".tad/evidence/spikes/SPIKE-20260414-quality-enforcement-adversarial"
FIX="$SPIKE/test-fixtures-perf"
OUT="$SPIKE/results/performance-comparison.tsv"

mkdir -p "$FIX"

# Representative stdin for each hook (fast-path scenarios matching Phase 1a baselines
# plus the new hardening overhead)
cat > "$FIX/pretool-sentinel-missing.json" <<'EOF'
{"hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"/tmp/msg.txt","content":"Message from Blake here"}}
EOF

cat > "$FIX/override-valid.json" <<'EOF'
{"session_id":"s","transcript_path":"/tmp/t","cwd":"/tmp","permission_mode":"d","hook_event_name":"UserPromptSubmit","prompt":"TAD_OVERRIDE: gate3 ticket=TAD-4521 nonce=deadbeef87654321 legitimate override for scheduled maintenance window"}
EOF

cat > "$FIX/bash-legit.json" <<'EOF'
{"tool_name":"Bash","tool_input":{"command":"echo hello > /tmp/test.txt"}}
EOF

cat > "$FIX/evidence-valid.md" <<'EOF'
# Review Evidence — Handoff Completion

## Files Reviewed
- README.md
- CLAUDE.md
- tad.sh
- LICENSE
- .gitignore

## Findings
Implementation consistent with handoff requirements.

## Verdict
Overall: PASS

Fresh evidence, not recycled.
EOF

echo "hook	run	ms" > "$OUT"

measure() {
  local hook="$1"; local mode="$2"; local input="$3"
  local script="$SPIKE/hardened-${hook}.sh"
  local N=30; local W=3
  for i in $(seq 1 $((N + W))); do
    local t1 t2
    t1=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1e9')
    if [ "$mode" = "stdin" ]; then
      bash "$script" < "$input" >/dev/null 2>&1 || true
    else
      bash "$script" "$input" >/dev/null 2>&1 || true
    fi
    t2=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1e9')
    [ "$i" -le "$W" ] && continue
    python3 -c "print(f'{($t2-$t1)/1e6:.3f}')" | while read ms; do
      printf '%s\t%d\t%s\n' "$hook" "$((i - W))" "$ms" >> "$OUT"
    done
  done
}

echo "[1/4] pretool-interceptor..."
measure "pretool-interceptor" stdin "$FIX/pretool-sentinel-missing.json"
echo "[2/4] override-detector..."
measure "override-detector" stdin "$FIX/override-valid.json"
# Reset nonce between measurements (each valid override would consume)
reset_nonce() {
  cat > .tad/evidence/overrides/nonce-registry.txt <<'EOF'
deadbeef87654321
EOF
  : > .tad/evidence/overrides/nonce-consumed.txt
}
reset_nonce
measure "override-detector" stdin "$FIX/override-valid.json"
echo "[3/4] bash-watcher..."
measure "bash-watcher" stdin "$FIX/bash-legit.json"
echo "[4/4] evidence-validator..."
measure "evidence-validator" arg "$FIX/evidence-valid.md"

echo ""
echo "=== Latency per hook (N=30, perl-timed) ==="
python3 - "$OUT" <<'PY'
import sys, statistics
path = sys.argv[1]
by_hook = {}
for line in open(path).readlines()[1:]:
    p = line.strip().split('\t')
    if len(p) < 3: continue
    hook = p[0]
    try: ms = float(p[2])
    except: continue
    by_hook.setdefault(hook, []).append(ms)
print(f"{'hook':25s} {'median':>10s} {'p95':>10s} {'max':>10s} {'pass?':>10s}")
for hook, vals in sorted(by_hook.items()):
    s = sorted(vals)
    med = statistics.median(s)
    p95 = s[int(len(s)*0.95)] if len(s) > 1 else s[0]
    mx = max(s)
    passed = "✅" if med < 75 and p95 < 100 else "⚠️"
    print(f"{hook:25s} {med:10.3f} {p95:10.3f} {mx:10.3f} {passed:>10s}")
PY
