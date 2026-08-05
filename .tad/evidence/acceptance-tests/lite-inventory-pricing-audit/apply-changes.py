#!/usr/bin/env python3
"""P1b-1: apply 5-file change (4 skill regex lines + ledger preamble).

Old regex line (exactly 1 occurrence per file):
    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
New regex line:
    if (match($0, /PROVISIONAL: review-by [0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[[:space:]]*\|?[[:space:]]*$/)) {

Ledger line 6 (exactly 1 occurrence):
    > 存量 34 节的回填审计由 P1b 完成。
replaced by two lines:
    > P1b-2 已完成 7 条 DEEP 约束的载体判定（见 P1b-deep-verdicts.md）；整批回填已取消，
    > 台账随 P2/P3/P5 自然生长——砍除时写该行，新增约束时由闸强制写一行。
"""
import sys

OLD_REGEX = "    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\\|?[[:space:]]*$/)) {"
NEW_REGEX = "    if (match($0, /PROVISIONAL: review-by [0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[[:space:]]*\\|?[[:space:]]*$/)) {"

OLD_LEDGER = "> 存量 34 节的回填审计由 P1b 完成。"
NEW_LEDGER = "> P1b-2 已完成 7 条 DEEP 约束的载体判定（见 P1b-deep-verdicts.md）；整批回填已取消，\n> 台账随 P2/P3/P5 自然生长——砍除时写该行，新增约束时由闸强制写一行。"

FILES = [
    ".claude/skills/alex-lite/SKILL.md",
    ".claude/skills/blake-lite/SKILL.md",
    ".agents/skills/alex-lite/SKILL.md",
    ".agents/skills/blake-lite/SKILL.md",
]

fail = False
for f in FILES:
    with open(f, encoding="utf-8") as fh:
        text = fh.read()
    n = text.count(OLD_REGEX)
    if n != 1:
        print(f"FAIL {f}: old regex line count={n} (expected 1)")
        fail = True
        continue
    with open(f, "w", encoding="utf-8", newline="") as fh:
        fh.write(text.replace(OLD_REGEX, NEW_REGEX, 1))
    print(f"OK   {f}: regex line replaced (1 occurrence)")

ledger = ".tad/evidence/audits/lite-constraint-ledger.md"
with open(ledger, encoding="utf-8") as fh:
    text = fh.read()
n = text.count(OLD_LEDGER)
if n != 1:
    print(f"FAIL {ledger}: old ledger line count={n} (expected 1)")
    fail = True
else:
    with open(ledger, "w", encoding="utf-8", newline="") as fh:
        fh.write(text.replace(OLD_LEDGER, NEW_LEDGER, 1))
    print(f"OK   {ledger}: preamble line replaced (1 occurrence)")

sys.exit(1 if fail else 0)
