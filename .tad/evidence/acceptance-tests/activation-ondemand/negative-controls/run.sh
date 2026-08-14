#!/usr/bin/env bash
# AC11 三负控（逐条单独跑）：任一负控为绿 = 该 AC 永真 → 停下退回 Alex
set -uo pipefail
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/activation-ondemand"
NC="$EV/negative-controls"; mkdir -p "$NC"
HB=".tad/active/handoffs/HANDOFF-20260817-activation-ondemand"
A1="$R/.claude/skills/alex/SKILL.md"; A2="$R/.agents/skills/alex/SKILL.md"
T0=$(cat "$EV/t0.txt"); RED=0

# 构造副本（从 T0 取原始文件 + 应用 pins 子集/变体）
mkcopy(){ # outfile python_pins_selector(pid -> new|old|skip) 
  local out="$1"
  SELECTOR="$2" OUT="$out" python3 - <<'PY'
import os, subprocess
R = "/Users/sheldonzhao/01-on progress programs/TAD"
T0 = open(f"{R}/.tad/evidence/acceptance-tests/activation-ondemand/t0.txt").read().strip()
HB = ".tad/active/handoffs/HANDOFF-20260817-activation-ondemand"
pins = []
for l in open(f"{R}/{HB}.pins.tsv", encoding="utf-8"):
    l = l.rstrip("\n")
    if not l.strip(): continue
    id_, old, new = l.split("\t"); pins.append((id_, old, new))
src = subprocess.run(["git", "-C", R, "show", f"{T0}:.claude/skills/alex/SKILL.md"],
                     capture_output=True, text=True).stdout
selector = os.environ["SELECTOR"]
for pid, old, new in pins:
    mode = {"n": new, "o": old, "s": None}[selector]
    if mode is None: continue
    assert src.count(old) == 1, f"pin {pid} old count {src.count(old)}"
    src = src.replace(old, mode)
open(os.environ["OUT"], "w", encoding="utf-8").write(src)
PY
}

ac1_check(){ # file -> 0 if PASS(每 NEW 恰1 / 每 OLD 0)
  local f="$1" bad=0
  while IFS=$'\t' read -r id old new; do
    [ -n "${id:-}" ] || continue
    co=$(LC_ALL=C command grep -cFx -e "$old" "$f" || true)
    cn=$(LC_ALL=C command grep -cFx -e "$new" "$f" || true)
    { [ "$co" -eq 0 ] && [ "$cn" -eq 1 ]; } || bad=$((bad+1))
  done < "$R/$HB.pins.tsv"
  [ "$bad" -eq 0 ]
}

# (a) 只改一半 pins（1-3 应用、4-7 未改）→ AC1 应拦（NEW4-7 计数 0）
mkcopy "$NC/nc-a-half.tsv" "s"
python3 - <<'PY'
import os
R = "/Users/sheldonzhao/01-on progress programs/TAD"
EV = f"{R}/.tad/evidence/acceptance-tests/activation-ondemand"
NC = f"{EV}/negative-controls"
p = f"{NC}/nc-a-half.tsv"
src = open(p, encoding="utf-8").read()
for l in open(f"{R}/.tad/active/handoffs/HANDOFF-20260817-activation-ondemand.pins.tsv", encoding="utf-8"):
    l = l.rstrip("\n")
    if not l.strip(): continue
    pid, old, new = l.split("\t")
    if pid in ("1","2","3") and src.count(old) == 1:
        src = src.replace(old, new)
open(p, "w", encoding="utf-8").write(src)
PY
if ac1_check "$NC/nc-a-half.tsv"; then echo "NC FAIL: AC1 half-pins 未拦（绿 = 永真）"; RED=1
else echo "NC OK: AC1 half-pins (red via AC1)"; fi

# (b) 全应用 + 删掉 session-state 行 → AC3 应拦
mkcopy "$NC/nc-b-noss.tsv" "n"
python3 - <<'PY'
import os
R = "/Users/sheldonzhao/01-on progress programs/TAD"
NC = f"{R}/.tad/evidence/acceptance-tests/activation-ondemand/negative-controls"
p = f"{NC}/nc-b-noss.tsv"
s = open(p, encoding="utf-8").read()
s = s.replace("      Read .tad/active/session-state.md (if exists).\n", "")
assert "session-state.md (if exists)" not in s
open(p, "w", encoding="utf-8").write(s)
PY
if LC_ALL=C command grep -qF "Read .tad/active/session-state.md (if exists)." "$NC/nc-b-noss.tsv"; then echo "NC FAIL: AC3 session-state 未拦"; RED=1
else echo "NC OK: AC3 session-state (red via AC3)"; fi

# (c) 全应用但 pins#6 NEW 改回 Read → AC6 逐源应拦
mkcopy "$NC/nc-c-revert6.tsv" "n"
python3 - <<'PY'
import os
R = "/Users/sheldonzhao/01-on progress programs/TAD"
NC = f"{R}/.tad/evidence/acceptance-tests/activation-ondemand/negative-controls"
p = f"{NC}/nc-c-revert6.tsv"
s = open(p, encoding="utf-8").read()
for l in open(f"{R}/.tad/active/handoffs/HANDOFF-20260817-activation-ondemand.pins.tsv", encoding="utf-8"):
    l = l.rstrip("\n")
    if not l.strip(): continue
    pid, old, new = l.split("\t")
    if pid == "6" and new in s:
        s = s.replace(new, old)
open(p, "w", encoding="utf-8").write(s)
PY
BLKCNT=$(LC_ALL=C awk '/^activation-instructions:/{f=1;next} /^[a-zA-Z_][a-zA-Z0-9_-]*:$/{if(f)exit} f{print}' "$NC/nc-c-revert6.tsv" | LC_ALL=C command grep -cF "Read .tad/github-registry/scan-log.yaml" || true)
if [ "$BLKCNT" -eq 0 ]; then echo "NC FAIL: AC6 scan-log revert 未拦（块内回退仍绿）"; RED=1
else echo "NC OK: AC6 scan-log revert (red via AC6, 块内计数 ${BLKCNT})"; fi

[ "$RED" -eq 0 ] && echo "ALL NEGATIVE CONTROLS RED — OK" || { echo "NEGATIVE CONTROL FAILURES PRESENT"; exit 1; }
