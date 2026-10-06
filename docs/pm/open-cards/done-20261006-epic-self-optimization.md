# 完事卡 — 自优化 Epic EPIC-20261006 总收口（TAD PM，2026-10-06）

- 结论：**Epic 四段全链收口、统一发版 v3.2.0 完成**。Phase 1（v3.0.2）／Phase 2（v3.1.0）先行发布作基线；Phase 3＋Phase 4＋tad.sh 备份修复按用户发版顺序口径冻结发布、于本日一次并版 v3.2.0（发版提交 `bc4a8137`、tag `v3.2.0`）。
- Phase 3 终态：Gate 4 CONDITIONAL——条件 2 (ii) 经常设口径裁定销账（Phase 4 下链复核终值 0.7% 不翻负）；条件 1 Codex 真机基线补跑排 2026-10-10（厂商配额），落地自动升 PASS。
- Phase 4 终态：Gate 4 PASS 无条件。仓 530M→440M（对 R1 基线净降 81M 逐项归因）；(a′) 三目录已删、candidate (b) 级冻结留待 PM 后续另裁；brain-index 生成器编码根因修复＋周期成文＋刷新路径接线落地。
- tad.sh 备份修复：Gate 4 PASS 无条件、GM 验盘通过、限定解冻已裁定；本版 tad.sh 终锚以发版提交为准（接线＋RM-OK 标记去重后）。
- 发版校验：version 分诊后豁免外 stale 0；migration PASS；installer-destructive-guard PASS（两重复标记 id 已定点去重）；state-surface PASS；freshness（runtime 台账）BLOCK 具名豁免——归开放票 TASK-20260916-CODEX-LEDGER-REVERIFY，不得空改日期关闭。
- 终裁三项：CF-7 裁定关闭不回造 hop；driftcheck (b) 11 件转下一轮自查批；step3f Codex 明示豁免（OC/Cursor PASS 在册）。
- 挂账总清点：Codex 补跑（10-10）；candidate 冻结目录去向；git pack 历史（不重写、长期议题）；node_modules 同步排除建议（转 GM/infra）；gc 预检新项与备份刀 R1–R3（转自查批）；CF-7 素材（infra environments.md Cursor 版本行）经 GM 转交。
- human CHECK 记「CHECK 待人」。
