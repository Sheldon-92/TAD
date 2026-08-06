#!/usr/bin/env python3
"""P2+P3 fix: §3.2 Reviewer 档位规则 子节删除（apply-changes.py 遗漏，Repair Round 1）.

alex-lite: `### Reviewer 档位规则` 到 `人工拍板后变更回流：` 之前（契约实测 28 行）
blake-lite: `### Reviewer 档位规则` 到 `## L3.5` 之前（契约实测 28 行）
"""
import sys

def read(f): return open(f, encoding="utf-8").read().split("\n")
def write(f, lines): open(f, "w", encoding="utf-8", newline="").write("\n".join(lines))

def del_section(lines, start_anchor, stop_prefix, label):
    hits = [i for i, l in enumerate(lines) if l == start_anchor]
    if len(hits) != 1:
        print(f"FAIL {label}: start 锚命中 {len(hits)} 次: {start_anchor!r}"); sys.exit(1)
    s = hits[0]
    e = None
    for i in range(s+1, len(lines)):
        if lines[i].startswith(stop_prefix):
            e = i; break
    if e is None:
        print(f"FAIL {label}: 找不到终止锚 {stop_prefix!r}"); sys.exit(1)
    removed = e - s
    print(f"OK   {label}: 删除 {removed} 行 [{s+1}..{e}]（期望 28，含尾部空行）")
    del lines[s:e]

for f in (".claude/skills/alex-lite/SKILL.md", ".agents/skills/alex-lite/SKILL.md"):
    lines = read(f)
    del_section(lines, "### Reviewer 档位规则", "人工拍板后变更回流：", f"{f}:ReviewerTier")
    write(f, lines)

for f in (".claude/skills/blake-lite/SKILL.md", ".agents/skills/blake-lite/SKILL.md"):
    lines = read(f)
    del_section(lines, "### Reviewer 档位规则", "## L3.5", f"{f}:ReviewerTier")
    write(f, lines)

print("FIX DONE")
