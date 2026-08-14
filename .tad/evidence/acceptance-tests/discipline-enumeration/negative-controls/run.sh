#!/usr/bin/env bash
# Per-AC negative controls — every AC must be provably red in an adversarial state.
# Any AC that passes pre-implementation is vacuously true -> stop and return to Alex.
# Usage: bash negative-controls/run.sh ; exit 0 means every negative control caught.
set -u
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/discipline-enumeration"
NC="$EV/negative-controls"
V="$EV/verify-all.sh"
INV="$R/.tad/evidence/designs/discipline-inventory/discipline-inventory.md"
G2="$R/.tad/evidence/designs/discipline-inventory/gate2-candidates.md"
DISP="$EV/disposition-60.md"
export LC_ALL=C
GLOBAL_FAIL=0

expect_red() { # label expected_ac logfile
  local lbl="$1" ac="$2" log="$3"
  if [ ! -f "$log" ]; then echo "NC FAIL: $lbl (log missing)"; GLOBAL_FAIL=1; return; fi
  if ! tail -1 "$log" | LC_ALL=C command grep -q 'RESULT=FAIL'; then
    echo "NC FAIL: $lbl — RESULT=PASS (AC 未实现态即绿 = 永真!)"; GLOBAL_FAIL=1; return; fi
  if ! LC_ALL=C command grep -q "^$ac FAIL" "$log"; then
    echo "NC FAIL: $lbl not intercepted via $ac (guard regression!)"; GLOBAL_FAIL=1; fi
  echo "NC OK: $lbl (red via $ac)"
}

# ensure AC9 adversarial tables exist
python3 "$NC/gen-adversarial.py" >/dev/null

# AC1: empty disposition
: > "$NC/tmp-ac1.tsv"
bash "$V" --negative "$NC/tmp-ac1.tsv" > "$NC/ac1-empty.log" 2>&1
expect_red "AC1 empty disposition" AC1 "$NC/ac1-empty.log"

# AC2: fabricated 已有 name (valid syntax, not in names.txt)
python3 - "$NC/tmp-ac2.tsv" <<'PY'
import sys
rows = [l.rstrip("\n").split("\t") for l in open("/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/discipline-enumeration/negative-controls/all-ondiscipline.tsv", encoding="utf-8")]
for r in rows: r[3] = "已有:胡编纪律"
open(sys.argv[1], "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")
PY
bash "$V" --negative "$NC/tmp-ac2.tsv" > "$NC/ac2-fabname.log" 2>&1
expect_red "AC2 fabricated name" AC2 "$NC/ac2-fabname.log"

# AC3: 非纪律 row without reason code
python3 - "$NC/tmp-ac3.tsv" <<'PY'
import sys
rows = [l.rstrip("\n").split("\t") for l in open("/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/discipline-enumeration/negative-controls/all-ondiscipline.tsv", encoding="utf-8")]
for r in rows: r[3] = "非纪律"; r[4] = ""
open(sys.argv[1], "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")
PY
bash "$V" --negative "$NC/tmp-ac3.tsv" > "$NC/ac3-noreason.log" 2>&1
expect_red "AC3 missing reason code" AC3 "$NC/ac3-noreason.log"

# AC4: sentence without any in-range fragment
python3 - "$NC/tmp-ac4.tsv" <<'PY'
import sys
rows = [l.rstrip("\n").split("\t") for l in open("/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/discipline-enumeration/negative-controls/all-ondiscipline.tsv", encoding="utf-8")]
for r in rows: r[5] = "这一句完全不在块区间内的解释性文本。"
open(sys.argv[1], "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")
PY
bash "$V" --negative "$NC/tmp-ac4.tsv" > "$NC/ac4-nofrag.log" 2>&1
expect_red "AC4 fragment not in range" AC4 "$NC/ac4-nofrag.log"

# AC4b: hit column forged
python3 - "$NC/tmp-ac4b.tsv" <<'PY'
import sys
rows = [l.rstrip("\n").split("\t") for l in open("/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/discipline-enumeration/negative-controls/all-ondiscipline.tsv", encoding="utf-8")]
for r in rows: r[6] = "999"
open(sys.argv[1], "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")
PY
bash "$V" --negative "$NC/tmp-ac4b.tsv" > "$NC/ac4b-forgehit.log" 2>&1
expect_red "AC4b forged hit count" AC4 "$NC/ac4b-forgehit.log"

# AC5: valid disposition with 1 新增 but inventory NOT appended
python3 - "$NC/tmp-ac5.tsv" <<'PY'
import sys
rows = [l.rstrip("\n").split("\t") for l in open("/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/discipline-enumeration/negative-controls/all-ondiscipline.tsv", encoding="utf-8")]
rows[0][3] = "新增:负控试验纪律"
open(sys.argv[1], "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")
PY
bash "$V" --negative "$NC/tmp-ac5.tsv" > "$NC/ac5-noappend.log" 2>&1
expect_red "AC5 新增未追加" AC5 "$NC/ac5-noappend.log"

# AC6: appended inventory row with empty whitelist cell (simulate: check awk independently)
python3 - <<'PY'
import subprocess
r = subprocess.run(["git", "-C", "/Users/sheldonzhao/01-on progress programs/TAD", "show",
  "HEAD:.tad/evidence/designs/discipline-inventory/discipline-inventory.md"],
  capture_output=True, text=True, encoding="utf-8")
txt = r.stdout
line = "| 负控试验纪律 | both | 1次 | 每单 | 1 | 1-留 | - |  | - | 中 | C1 | - | 机械一次 | - |"
txt += line + "\n"
open("/tmp/ac6-inv.md", "w", encoding="utf-8").write(txt)
PY
# unit-level: check ONLY data rows (skip header + separator)
if LC_ALL=C awk -F'|' 'seen && NF>2 {v2=$2;v3=$3;v4=$4;v5=$5;v7=$7;v9=$9
  if(v2 ~ /^ *$|^ *- *$/) print NR":纪律空"; if(v3 ~ /^ *$|^ *- *$/) print NR":来源空"
  if(v4 ~ /^ *$|^ *- *$/) print NR":成本空"; if(v5 ~ /^ *$|^ *- *$/) print NR":频率空"
  if(v7 ~ /^ *$|^ *- *$/) print NR":三类判定空"; if(v9 ~ /^ *$|^ *- *$/) print NR":地板空"}
  ; index($0,"---")>=1{seen=1}' /tmp/ac6-inv.md | LC_ALL=C command grep -q '地板空'; then
  echo "NC OK: AC6 empty whitelist cell caught (unit)"
else
  echo "NC FAIL: AC6 whitelist check is vacuous"; GLOBAL_FAIL=1
fi
# column-count mismatch path (data rows only) — adversarial 3-col row
printf '%s\n' '| a | b | c |' >> /tmp/ac6-inv.md
if LC_ALL=C awk -F'|' 'seen && NF>2 && NF-2 != 14{c++} ; index($0,"---")>=1{seen=1} END{exit !(c>0)}' /tmp/ac6-inv.md; then
  echo "NC OK: AC6 column-count mismatch caught (unit)"
else
  echo "NC FAIL: AC6 column-count check is vacuous"; GLOBAL_FAIL=1
fi

# AC7: forged subkey column
python3 - "$NC/tmp-ac7.tsv" <<'PY'
import sys
rows = [l.rstrip("\n").split("\t") for l in open("/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/discipline-enumeration/negative-controls/all-ondiscipline.tsv", encoding="utf-8")]
for r in rows: r[7] = "伪造子键,另一个伪造"
open(sys.argv[1], "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")
PY
bash "$V" --negative "$NC/tmp-ac7.tsv" > "$NC/ac7-forgesubkey.log" 2>&1
expect_red "AC7 forged subkeys" AC7 "$NC/ac7-forgesubkey.log"

# AC8: gate2-candidates missing
if [ -f "$G2" ]; then mv "$G2" "$NC/tmp-g2.bak"; fi
bash "$V" > "$NC/ac8-missing.log" 2>&1
expect_red "AC8 candidates missing" AC8 "$NC/ac8-missing.log"
[ -f "$NC/tmp-g2.bak" ] && mv "$NC/tmp-g2.bak" "$G2"

# AC9: three adversarial tables (fallback disposition = real one; use tmp copies)
for t in all-ondiscipline all-existing all-new; do
  bash "$V" --negative "$NC/$t.tsv" > "$NC/$t.log" 2>&1
done
expect_red "AC9 all-ondiscipline" AC11 "$NC/all-ondiscipline.log"
expect_red "AC9 all-existing" AC10 "$NC/all-existing.log"
expect_red "AC9 all-new" AC4 "$NC/all-new.log"
# verify interception points are the claimed ones
for pair in "all-ondiscipline AC11" "all-existing AC10" "all-new AC4"; do
  t=${pair%% *}; ac=${pair##* }
  if ! LC_ALL=C command grep -q "^$ac FAIL" "$NC/$t.log"; then
    echo "NC FAIL: AC9 $t not intercepted via $ac (rev1-style hole!)"; GLOBAL_FAIL=1
  fi
done

# AC10: 61 rows on one 已有 (constructed via all-existing fixture + one extra row? rows fixed 60 -> covered by all-existing)
echo "NC OK: AC10 >24 coverage caught (all-existing)"

# AC11: adopted candidate without 新增 (all-ondiscipline + real candidates) — covered above

# AC12: file outside fence
touch "$R/tmp-outside-fence.txt"
bash "$V" > "$NC/ac12-outside.log" 2>&1
expect_red "AC12 outside-fence file" AC12 "$NC/ac12-outside.log"
rm -f "$R/tmp-outside-fence.txt"

# AC13: read-only guard (cannot mutate contract; assert the command itself discriminates)
if git -C "$R" diff --quiet HEAD -- .tad/active/handoffs/HANDOFF-20260815-discipline-enumeration.md; then
  echo "NC OK: AC13 guard green on unchanged contract (read-only, no negative state constructible)"
else
  echo "NC FAIL: AC13 contract already dirty at start"; GLOBAL_FAIL=1
fi

rm -f "$NC"/tmp-ac*.tsv /tmp/ac6-inv.md
if [ "$GLOBAL_FAIL" = "0" ]; then echo "ALL NEGATIVE CONTROLS RED — OK"; else echo "NEGATIVE CONTROL FAILURES PRESENT"; exit 1; fi
