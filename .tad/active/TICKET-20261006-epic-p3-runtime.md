# TICKET-20261006-EPIC-P3-RUNTIME — 自优化 Epic Phase 3「运行时适配补全」设计＋实施

- task_id: TASK-20261006-EPIC-P3-RUNTIME
- 状态：OPEN（设计步已派）
- 立票：PM（TAD PM），2026-10-06。依据 Epic `.tad/active/epics/EPIC-20261006-tad-self-optimization.md`（Phase Map 行 3＋Phase 3 件目表）。
- 前置：Phase 2 已收口 v3.1.0（Gate 4 PASS）。本 Phase 收口提议升 **v3.2.0（minor）**，收口按件 1.2/1.3 口径全量分诊。

## 范围（Epic Phase 3 件目表 5 行＋承接 4 件）

1. 件 3.1（P1 承接）：OpenCode hooks 落地——以 P1 批设计为输入施工，让中断点位有机器承接。
2. 件 3.2（P1 承接）：Cursor hooks 核实——核实现状、能落则落，不能落记明边界。
3. 件 3.3（P4 承接）：真机回归基线——三家（Codex/OpenCode/Cursor）各产首份活体基线 transcript，step3f 三家 ADVISORY 随之补齐（归属自 Phase 2 首秀登记）。
4. 件 3.4（C5）：运行时执行适配器声明清单——新运行时接入前置件成文。
5. 件 3.5（F1）：派发卡权限声明先核可声明面——逐通道核权限可声明性再定落文形态，不落空文。
6. **承接 A（Phase 2 裁断）**：件 2.1 首个有效基线跑——借本 Phase 真机隔离面重捕三案（对照＋被测）后复评，回填首跑裁断销账行。
7. **承接 B（Phase 2 评估结论）**：件 2.6 试点——本 Phase 首链即试点宿主：实施中对中间态产物做一次回退还原验证（四维回填：检出/还原/证据/结论），翻负自动降缓。
8. **承接 C（Phase 2 收口输入）**：check4 字面量版本相对性审视——给结论（维持字面＋换版注记，或改相对化），随设计落定。
9. **承接 D（Phase 2 收口输入）**：发版清单加「打 tag」步（或等价断言）——防 v3.0.1/3.0.2 式标签缺位再发。

## 红线

仓外零写；同名文件绝对路径＋Step 0 断言；git 写只在 PM 收口步（含打 tag）；真机回归只在隔离副本/骨架仓跑、不碰下游真实仓；F1 核不出可声明面就如实记边界、不造声明文。

关闭（PM，2026-10-06）：COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-epic-p3-runtime.md`；Gate 3 PASS（SAFETY PASS＋CODE CONDITIONAL 订正核销）；Gate 4 CONDITIONAL（gate4-alex.md）。遗留：Codex PASS 基线补跑（10-10 后）、R-OC-1 残项登记、CF-7 素材（infra 环境清单版本陈旧）转 infra 席。
