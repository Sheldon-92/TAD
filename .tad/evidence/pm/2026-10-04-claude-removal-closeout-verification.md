# PM 核定记录 — claude-removal 链 Gate 4 遗留项闭合核定

- 日期：2026-10-04
- 核定人：📐 TAD PM（盘面逐项亲验）
- 对象链：TASK-20260915-CLAUDE-REMOVAL；Gate 4 件 `.tad/evidence/reviews/2026-09-15-gate4-acceptance-claude-removal.md`（结论 CONDITIONAL；§3 列遗留 R1 两处＋AC20 判据三处；§7 给出闭合裁决 G4D-1/2/3 与升级判据）
- 背景：2026-10-04 自家欠账普查发现本链停在 Gate 4 CONDITIONAL、无 COMPLETION、status 仍挂开工表述；PM 先如实回写状态，今逐项核定遗留是否已在链外闭合。

## 逐项核定（盘面证据）

| 遗留项 | Gate 4 出处 | 现盘面 | 判定 |
|---|---|---|---|
| R1(a) `.claude/settings.local.json.bak-*` 忽略规则未恢复 | §3.1 | `.gitignore:11` 现有 `.claude/settings.local.json.bak-*` 一行 | ✅ 已闭合 |
| R1(b) `.tad/memory/reference_claude-code-source.md` 忽略行被删、去留无决策 | §3.2 | 文件仍在盘（1,316 B）；`git check-ignore -v` 命中 `.gitignore:69`，即「保留文件＋恢复忽略」已执行 | ✅ 已闭合 |
| AC20 判据同步 ①：HANDOFF S7 删除清单去掉 `:78` 并注例外 | §7.4-① | HANDOFF 第 507 行 S7 现表述为 `(:7,10,13,19,20)`＋「`:78` 例外——按 R1 返工恢复，不删（Gate 4 裁决 §7.1；以 R1 为准）」 | ✅ 已同步 |
| AC20 判据同步 ②：§6.3 V-P1 第二条命令改 carve-out 形态 | §7.3 | HANDOFF §6.3 第二条命令现带全部 carve-out `--exclude`（parity-criterion／skills-config／4 个 fixture），注释逐项在册 | ✅ 已同步 |
| AC20 判据同步 ③：AC20 行期望列同步 carve-out 清单 | §7.4-③ | HANDOFF 第 683 行 AC20 期望列已带 carve-out 清单与 `config-workflow.yaml:279` 改写说明 | ✅ 已同步 |
| AC20 字面转绿（终验） | §7 末段 | §6.3 第二条命令**原样实跑**（2026-10-04，PM 亲跑）：**0 命中**（Gate 4 当时基线 159） | ✅ 转绿 |

## 核定结论

- Gate 4 §3 全部遗留项已于链外闭合（由 Gate 4 §7 裁决驱动的 out-of-band 闭合，后续会话执行、本次盘面全验属实）。
- 按 Gate 4 件 §7 自带判据（「R1 完全闭合＋AC20 字面转绿 → Gate 4 由 CONDITIONAL 升 PASS」），**本链 Gate 4 升 PASS、链收口成立**。
- 收口动作：补写 COMPLETION（迟补、如实标注依据本核定记录，不冒充当日件）；HANDOFF status 回写 CLOSED；HANDOFF 主件＋两子件＋COMPLETION 一并迁 `.tad/archive/handoffs/`。
