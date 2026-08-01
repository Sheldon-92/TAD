# GOOD BLAKE CONTRACT FIXTURE (hand-written at L2.5, frozen — NOT generated from any SKILL.md)

## Lite Progress

Fields (fixed enum):

  Phase=admission|implement|ac|review|technical-gate|human-gate
  repair_round=0/3..3/3
  same_error_count=0/2..2/2
  verdict=RUNNING|GATE PASS|GATE FAIL/BLOCK|PARTIAL-GO
  Evidence=<path>
  Next Action=<one line>

## Lite Technical Gate

Checklist: AC/evidence, reviewer verdict, friction, scope/risk, Knowledge Assessment.
没有证据不得声称 PASS。结果只能是 GATE PASS、GATE FAIL/BLOCK 或 PARTIAL-GO。
状态转移固定：失败且可在原范围修复 → Repair Loop；修复后重跑受影响 AC 与 reviewer，再回本 Gate。

## Lite Repair Loop

最多 3 轮修复。同类错误连续 2 次仍未改变结果 → 停止并报告 GATE FAIL/BLOCK。
恢复时沿用计数，不得重置。

## Honest Partial

PARTIAL-GO 仅当：至少一条 AC 已通过，且 AC 互相冲突或存在明确的人/外部系统选择。
不用于：普通实现失败、缺证据、缺权限、reviewer 不可用。
禁止把冲突 AC 静默改写成 PASS。
