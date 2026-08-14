#!/usr/bin/env python3
# Generate AC15 adversarial main tables from frozen inputs.
# (a) "legal" all-0 table: 27 rows Layer=0 + 3 可缩放 rows Layer=1, anchors = unrelated
#     mandatory lines from ONE carrier file -> must be caught by AC4 (key mismatch) and AC6 (dispersion).
# (b) all Layer=2 -> AC3
# (c) trigger strings all "MUST" -> AC5 (no anchor containment)
import subprocess, sys
R = "/Users/sheldonzhao/01-on progress programs/TAD"
EV = f"{R}/.tad/evidence/acceptance-tests/discipline-floor"
NC = f"{EV}/negative-controls"
def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, encoding="utf-8").stdout
verdicts = [l.rstrip("\n").split("\t") for l in open(f"{EV}/verdicts.tsv", encoding="utf-8")]
assert len(verdicts) == 30

def base_row(v, cyc, layer, basis, anchor, trig, undecide):
    return [v[0], v[1], v[2], v[3], cyc, ".claude/skills/gate/SKILL.md", anchor, trig, layer, basis, "否", undecide]

# (a) 27 rows Layer 0 (7 地板 + 20 待判-as-循环), 3 可缩放 rows Layer 1.
# rev1 攻击形状: 每条纪律配一个"同一文件的无关强制行"锚点 (30 个不同行) —
# 行本身是真实强制行 (命中宽词表), 但与各自纪律的判别词不匹配 -> AC4 拦;
# 30 行全指同一载体文件 -> AC6 拦.
A_LINES = [
 "### 必须执行 Gate 的时机", "### ⚠️ 强制规则", "## Gate Detection and Execution",
 "## Gate 1: Requirements Clarity (Alex) - Optional Quick Check",
 "## Gate 2: Design Completeness (Alex) - **MANDATORY** 🔴",
 "## Gate 3: Implementation Quality (Blake) - **MANDATORY** 🔴",
 "## Rubric Evaluation Protocol",
 "## Gate 4: Integration Verification (Blake + Alex) - **MANDATORY** 🔴",
 "## ⚠️ Gate 4 Subagent Requirement (CRITICAL)",
 "## Gate 4 — Rubric-Based Handoffs",
 "## Interactive Gate Execution", "## Violation Handling",
 "# ⚠️ PREREQUISITE CHECK (BLOCKING)", "# ⚠️ FRICTION STATUS VERIFICATION (BLOCKING)",
 "# ⚠️ §9.1 SPEC COMPLIANCE VERIFICATION (BLOCKING)", "# ⚠️ §9.1 EMPTY GUARD (BLOCKING)",
 "# ⚠️ RISK TRANSLATION CHECK (Cognitive Firewall)", "# ⚠️ GIT COMMIT VERIFICATION CHECK (BLOCKING)",
 "# ⚠️ judge ≠ producer (BLOCKING)", "# ⚠️ RUBRIC + THRESHOLD RESOLUTION (BLOCKING)",
 "# ⚠️ REQUIRED JUDGE SUBAGENT (BLOCKING)", "# ⚠️ VERDICT MAPPING",
 "# ⚠️ RUBRIC-LANE PREREQUISITE (BLOCKING)", "# ⚠️ GATE VIOLATION DETECTED ⚠️",
 "# ⚠️ KNOWLEDGE ASSESSMENT (BLOCKING - Part of Gate 4)",
 "# ⚠️ TASK-TYPE CONDITIONALITY (BLOCKING for code/mixed)",
 "# Universal Violation Recovery Protocol (applies to all gates)",
 "## Gate 4 Subagent Requirement (CRITICAL)",
 "# ⚠️ REQUIRED SUBAGENT CALLS (BLOCKING)", "# ⚠️ DECISION COMPLIANCE CHECK",
]
T = "### ⚠️ 强制规则 5"
rows_a = []
for i, v in enumerate(verdicts):
    A = A_LINES[i % len(A_LINES)]
    if v[1] == "可缩放":
        rows_a.append(base_row(v, "否", "1", "既有判定", A, T, "可缩放非常驻，按需加载触发由命令显式发生"))
    elif v[1] == "待判":
        rows_a.append(base_row(v, "是", "0", "待判默认", A, T, f"{v[0]} 触发依赖本体，循环加载，常驻 fail-safe"))
    else:
        rows_a.append(base_row(v, "否", "0", "既有判定", A, T, "常驻既定，无解除待判需求"))
open(f"{NC}/nc-a-allzero.tsv", "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows_a) + "\n")

# (b) all Layer=2
rows_b = []
for v in verdicts:
    rows_b.append(base_row(v, "否", "2", "既有判定", A, T, "-"))
open(f"{NC}/nc-b-all2.tsv", "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows_b) + "\n")

# (c) trigger = "MUST" (no anchor)
rows_c = []
for v in verdicts:
    rows_c.append(base_row(v, "否", "0", "既有判定", A, "MUST MUST MUST MUST", "-"))
open(f"{NC}/nc-c-trigmust.tsv", "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows_c) + "\n")
print("generated 3 adversarial tables")
