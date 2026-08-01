#!/usr/bin/env bash
# verify-structure.sh — role-branched structural verifier for Lite skill contracts.
# Usage: verify-structure.sh --role alex|blake <file>
# exit 0 = structure satisfied; exit 1 = violated; exit 2 = usage error.
# NOT a keyword grep: alex branch checks anchored heading ORDER + per-stage
# Input/Action/Output/Stop sequence; blake branch checks Progress field enums,
# Gate/Partial exclusivity rules, and the Repair->rerun->Gate state chain order.
set -u

role="" file=""
while [ $# -gt 0 ]; do
  case "$1" in
    --role) role="$2"; shift 2 ;;
    *) file="$1"; shift ;;
  esac
done
[ -n "$role" ] && [ -n "$file" ] || { echo "usage: $0 --role alex|blake <file>" >&2; exit 2; }
[ -f "$file" ] || { echo "missing file: $file" >&2; exit 2; }
# assert input non-empty (no vacuous pass on empty input)
[ -s "$file" ] || { echo "FAIL: empty input" >&2; exit 1; }

case "$role" in
  alex)
    python3 - "$file" << 'PYEOF'
import pathlib, re, sys
s = pathlib.Path(sys.argv[1]).read_text()
stages = ["L0", "L1", "L1.5", "L2", "L2.25", "L2.5", "L3"]
try:
    starts = [s.index("**" + x + " —") for x in stages]
except ValueError as e:
    print("FAIL: missing anchored stage heading:", e); sys.exit(1)
if not (len(set(starts)) == 7 and starts == sorted(starts)):
    print("FAIL: stage headings not unique or not strictly ordered"); sys.exit(1)
ends = starts[1:] + [len(s)]
blocks = [s[a:b] for a, b in zip(starts, ends)]
pat = re.compile(r"(?is)(input|输入).*?(action|动作).*?(output|输出).*?(stop|停止)")
for name, b in zip(stages, blocks):
    if not pat.search(b):
        print(f"FAIL: stage {name} lacks Input->Action->Output->Stop sequence"); sys.exit(1)
print("PASS: alex structure (7 stages ordered, each with input/action/output/stop)")
PYEOF
    ;;
  blake)
    python3 - "$file" << 'PYEOF'
import pathlib, re, sys
s = pathlib.Path(sys.argv[1]).read_text()
fails = []
# 1. Progress field enums (fixed)
for pat in [r"Phase=admission\|implement\|ac\|review\|technical-gate\|human-gate",
            r"repair_round=0/3", r"same_error_count=0/2",
            r"verdict=RUNNING\|GATE PASS\|GATE FAIL/BLOCK\|PARTIAL-GO",
            r"Evidence=", r"Next Action="]:
    if not re.search(pat, s):
        fails.append("missing Progress field: " + pat)
# 2. Gate/Partial exclusivity
if not re.search(r"(没有证据不得|无证据不得).{0,20}PASS", s):
    fails.append("missing no-evidence-no-PASS rule")
if not (re.search(r"PARTIAL-GO", s) and re.search(r"至少一条 AC 已通过", s)
        and re.search(r"不用于", s)):
    fails.append("missing PARTIAL-GO trigger conditions / exclusion")
if not re.search(r"静默改写.{0,10}PASS|改写成 PASS", s):
    fails.append("missing no-silent-PASS-rewrite bar")
# 3. Repair -> rerun AC/reviewer -> back to Gate state chain (ordered)
m = re.search(r"Repair Loop.{0,300}重跑受影响 AC.{0,300}再回本 Gate", s, re.S)
if not m:
    fails.append("missing Repair->rerun->Gate state chain (ordered)")
if not re.search(r"连续 2 次", s) or not re.search(r"最多 3 轮", s):
    fails.append("missing repair bounds (3 rounds / 2 consecutive same errors)")
if fails:
    for f in fails: print("FAIL:", f)
    sys.exit(1)
print("PASS: blake structure (Progress fields, Gate/Partial exclusivity, repair chain)")
PYEOF
    ;;
  *) echo "unknown role: $role" >&2; exit 2 ;;
esac
