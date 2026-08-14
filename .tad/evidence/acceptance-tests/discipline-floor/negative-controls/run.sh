#!/usr/bin/env bash
# Per-AC negative controls — every AC must be provably red in an adversarial state.
set -u
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/discipline-floor"
NC="$EV/negative-controls"
V="$EV/verify-all.sh"
MAIN="$R/.tad/discipline-floor.md"
export LC_ALL=C
GLOBAL_FAIL=0

expect_red() { # label claimed_ac logfile
  local lbl="$1" ac="$2" log="$3"
  if [ ! -f "$log" ]; then echo "NC FAIL: $lbl (log missing)"; GLOBAL_FAIL=1; return; fi
  if ! tail -1 "$log" | LC_ALL=C command grep -q 'RESULT=FAIL'; then
    echo "NC FAIL: $lbl — RESULT=PASS (未实现态即绿 = 永真!)"; GLOBAL_FAIL=1; return; fi
  if ! LC_ALL=C command grep -q "^$ac FAIL" "$log"; then
    echo "NC FAIL: $lbl not intercepted via $ac (guard regression!)"; GLOBAL_FAIL=1; return; fi
  echo "NC OK: $lbl (red via $ac)"
}

python3 "$NC/gen-adversarial.py" >/dev/null

# helper: build fixture from the REAL product (all-green baseline) and mutate ONE dimension.
# real rows are read from .tad/discipline-floor.md (main table only), then python mutates.
mkfix() { # outfile python_snippet_operating_on rows
  local out="$1" snippet="$2"
  OUT="$out" python3 - <<PY
import os
R = "/Users/sheldonzhao/01-on progress programs/TAD"
MAIN = f"{R}/.tad/discipline-floor.md"
rows = []
for l in open(MAIN, encoding="utf-8"):
    l = l.rstrip("\n")
    if not l or l.startswith("#") or l.startswith("|"): continue
    p = l.split("\t")
    if len(p) >= 12 and p[0] != "纪律": rows.append(p[:12])
$snippet
open(os.environ["OUT"], "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")
PY
}

# AC1: empty main table
: > "$NC/tmp-ac1.tsv"
bash "$V" --negative "$NC/tmp-ac1.tsv" > "$NC/ac1-empty.log" 2>&1
expect_red "AC1 empty table" AC1 "$NC/ac1-empty.log"

# AC2: bad 循环? value
mkfix "$NC/tmp-ac2.tsv" 'for r in rows: r[4] = "也许"'
bash "$V" --negative "$NC/tmp-ac2.tsv" > "$NC/ac2-badcyc.log" 2>&1
expect_red "AC2 bad 循环?" AC2 "$NC/ac2-badcyc.log"

# AC3: 地板 → Layer 1
mkfix "$NC/tmp-ac3.tsv" 'for r in rows: r[8] = "1"'
bash "$V" --negative "$NC/tmp-ac3.tsv" > "$NC/ac3-layer1.log" 2>&1
expect_red "AC3 地板→Layer1" AC3 "$NC/ac3-layer1.log"

# AC4: anchor not matching discriminator
mkfix "$NC/tmp-ac4.tsv" 'for r in rows: r[6] = "## Gate Detection and Execution"'
# 注: 该锚点在 gate/SKILL.md 存在但不匹配任何纪律判别词 → 触发判别词分支 (非"不在载体")
bash "$V" --negative "$NC/tmp-ac4.tsv" > "$NC/ac4-badanchor.log" 2>&1
expect_red "AC4 anchor no key match" AC4 "$NC/ac4-badanchor.log"

# AC5: trigger without anchor
mkfix "$NC/tmp-ac5.tsv" 'for r in rows: r[7] = "MUST MUST MUST MUST"'
bash "$V" --negative "$NC/tmp-ac5.tsv" > "$NC/ac5-notrig.log" 2>&1
expect_red "AC5 trigger no anchor" AC5 "$NC/ac5-notrig.log"

# AC6: single carrier for all 30 rows (dispersion check)
mkfix "$NC/tmp-ac6.tsv" 'for r in rows: r[5] = ".claude/skills/gate/SKILL.md"'
bash "$V" --negative "$NC/tmp-ac6.tsv" > "$NC/ac6-singlecarrier.log" 2>&1
expect_red "AC6 single carrier" AC6 "$NC/ac6-singlecarrier.log"

# AC7: real main rows + subtable whose first row duplicates a REAL main (carrier,anchor)
python3 - <<'PY'
import os
R = "/Users/sheldonzhao/01-on progress programs/TAD"
EV = f"{R}/.tad/evidence/acceptance-tests/discipline-floor"
NC = f"{EV}/negative-controls"
main_rows = []
for l in open(f"{R}/.tad/discipline-floor.md", encoding="utf-8"):
    l = l.rstrip("\n")
    if not l or l.startswith("#") or l.startswith("|"): continue
    p = l.split("\t")
    if len(p) >= 12 and p[0] != "纪律": main_rows.append(p[:12])
# duplicate the FIRST main row's (carrier,anchor) into the subtable
m0 = main_rows[0]
sub = "## 副表\n重复项\t" + m0[5] + "\t" + m0[6] + "\t" + m0[7] + "\n"
open(f"{NC}/tmp-ac7.tsv", "w", encoding="utf-8").write("\n".join("\t".join(r) for r in main_rows) + "\n" + sub)
PY
bash "$V" --negative "$NC/tmp-ac7.tsv" > "$NC/ac7-dupe.log" 2>&1
expect_red "AC7 main/sub dup" AC7 "$NC/ac7-dupe.log"

# AC8: real main rows + subtable missing Forbidden (keeps 反合理化, drops Forbidden row)
python3 - <<'PY'
import os
R = "/Users/sheldonzhao/01-on progress programs/TAD"
EV = f"{R}/.tad/evidence/acceptance-tests/discipline-floor"
NC = f"{EV}/negative-controls"
main_rows = []
for l in open(f"{R}/.tad/discipline-floor.md", encoding="utf-8"):
    l = l.rstrip("\n")
    if not l or l.startswith("#") or l.startswith("|"): continue
    p = l.split("\t")
    if len(p) >= 12 and p[0] != "纪律": main_rows.append(p[:12])
real_sub = []
in_sub = False
for l in open(f"{R}/.tad/discipline-floor.md", encoding="utf-8"):
    l = l.rstrip("\n")
    if l.startswith("## 副表"): in_sub = True; continue
    if in_sub and l.startswith("## "): break
    if in_sub and l.strip() and not l.startswith("#"):
        p = l.split("\t")
        if len(p) >= 4 and p[0] != "项": real_sub.append(p[:4])
# adversarial subtable: only rows whose item does NOT contain Forbidden
sub = "## 副表\n项\t载体\t锚点串\t触发串\n" + "\n".join("\t".join(r) for r in real_sub if "Forbidden" not in r[0]) + "\n"
open(f"{NC}/tmp-ac8.tsv", "w", encoding="utf-8").write("\n".join("\t".join(r) for r in main_rows) + "\n" + sub)
PY
bash "$V" --negative "$NC/tmp-ac8.tsv" > "$NC/ac8-noforbidden.log" 2>&1
expect_red "AC8 no Forbidden" AC8 "$NC/ac8-noforbidden.log"

# AC9: 解除待判 = TBD
mkfix "$NC/tmp-ac9.tsv" 'for r in rows: r[11] = "TBD"'
bash "$V" --negative "$NC/tmp-ac9.tsv" > "$NC/ac9-tbd.log" 2>&1
expect_red "AC9 TBD" AC9 "$NC/ac9-tbd.log"

# AC10: missing R6 token
mkfix "$NC/tmp-ac10.tsv" ''
python3 - <<'PY'
R = "/Users/sheldonzhao/01-on progress programs/TAD"
EV = f"{R}/.tad/evidence/acceptance-tests/discipline-floor"
NC = f"{EV}/negative-controls"
# real main rows + sections WITHOUT the R6 token
open(f"{NC}/tmp-ac10.tsv", "a", encoding="utf-8").write("\n## 清单缺口\n凭据与修改框架自身缺口说明（引用 CLAUDE.md:50）。\n## 承接单\nexpert-criteria expert-criteria-wiring 实测 100/200 = 50%。\n")
PY
bash "$V" --negative "$NC/tmp-ac10.tsv" > "$NC/ac10-nor6.log" 2>&1
expect_red "AC10 no R6" AC10 "$NC/ac10-nor6.log"

# AC11: contains 4557
mkfix "$NC/tmp-ac11.tsv" ''
python3 - <<'PY'
R = "/Users/sheldonzhao/01-on progress programs/TAD"
EV = f"{R}/.tad/evidence/acceptance-tests/discipline-floor"
NC = f"{EV}/negative-controls"
open(f"{NC}/tmp-ac11.tsv", "a", encoding="utf-8").write("\n## 承接单\nexpert-criteria security 触发 4557 分母实测。\n")
PY
bash "$V" --negative "$NC/tmp-ac11.tsv" > "$NC/ac11-4557.log" 2>&1
expect_red "AC11 4557" AC11 "$NC/ac11-4557.log"

# AC13: file outside fence
touch "$R/tmp-outside-fence.txt"
bash "$V" > "$NC/ac13-outside.log" 2>&1
expect_red "AC13 outside fence" AC13 "$NC/ac13-outside.log"
rm -f "$R/tmp-outside-fence.txt"

# AC12/AC14 guarded: AC12 read-only; AC14 needs real product (checked in final verify)

# AC15: three adversarial tables
bash "$V" --negative "$NC/nc-a-allzero.tsv" > "$NC/ac15a.log" 2>&1
expect_red "AC15a 27x0+3x1 legal-ish" AC4 "$NC/ac15a.log"
bash "$V" --negative "$NC/nc-b-all2.tsv" > "$NC/ac15b.log" 2>&1
expect_red "AC15b all Layer2" AC3 "$NC/ac15b.log"
bash "$V" --negative "$NC/nc-c-trigmust.tsv" > "$NC/ac15c.log" 2>&1
expect_red "AC15c trigger MUST" AC5 "$NC/ac15c.log"
# AC15a also via AC6 (dispersion)
if ! LC_ALL=C command grep -q '^AC6 FAIL' "$NC/ac15a.log"; then
  echo "NC FAIL: AC15a not intercepted via AC6 (dispersion guard regression)"; GLOBAL_FAIL=1
else
  echo "NC OK: AC15a also red via AC6"
fi

rm -f "$NC"/tmp-ac*.tsv "$NC"/tmp-ac*.md
if [ "$GLOBAL_FAIL" = "0" ]; then echo "ALL NEGATIVE CONTROLS RED — OK"; else echo "NEGATIVE CONTROL FAILURES PRESENT"; exit 1; fi
