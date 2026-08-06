# Lite 约束定价台账

> 由 Epic `EPIC-20260804-lite-as-tad-body` P1a 建立。
> 新增约束的定价规则见 alex-lite / blake-lite 的「约束准入」节。
> append-only：不删除历史行。状态列可就地转移为终态；处置理由另追加一行并带上原期限。
> P1b-2 已完成 7 条 DEEP 约束的载体判定（见 P1b-deep-verdicts.md）；整批回填已取消，
> 台账随 P2/P3/P5 自然生长——砍除时写该行，新增约束时由闸强制写一行。

| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |
|---|---|---|---|---|---|---|---|
| 2026-08-05 | alex-lite | ### Reviewer 档位规则 | 生产关键单 reviewer 须强档；alias-mapped 时三选一 | 每单 1 次档位判定 + alias 环境下 1 轮人机往返 | flash 审 flash 系统性盲区：只读审查 GATE PASS 而执行探针盲审 FAIL P0×1+P1×6 `flash 审 flash` | .tad/evidence/research/2026-08-02-model-diversity-audit-results.md | SUPERSEDED |
| 2026-08-05 | blake-lite | ### Reviewer 档位规则 | 生产关键单 reviewer 须强档；alias-mapped 时三选一 | 每单 1 次档位判定 + alias 环境下 1 轮人机往返 | flash 审 flash 系统性盲区：只读审查 GATE PASS 而执行探针盲审 FAIL P0×1+P1×6 `flash 审 flash` | .tad/evidence/research/2026-08-02-model-diversity-audit-results.md | SUPERSEDED |
| 2026-08-05 | 两侧 | 处置说明 | 上两行已由 HANDOFF-20260805-cut-routing-machinery 整节删除 | — | 用户 2026-08-04 裁定「兼容各种模型和 harness，不用非要调用强档」；载体真实存在，删是知情取舍不是无依据 | .tad/archive/handoffs/HANDOFF-20260805-cut-routing-machinery.md | SUPERSEDED |
