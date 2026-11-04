# TICKET-20261102 — `.codex/hooks.json` 回滚覆盖缺口：弃用删除＋同轮再生文件被回滚步 4 当 run-created 再删（D4-R 后续票）

**Status**: OPEN（后续票，2026-11-02 立；由 EPIC-20261101-v4010-hotfix 收口义务 D4-R 产生）
**Owner**: TAD PM（登记）；实施走本仓 Epic 全链
**来源**: HANDOFF-20261101-installer-atomicity §Post-Implementation Ruling Record（hf-design-4）D4 裁断与 D4-R 残余义务；风险卡 `.tad/evidence/risk-cards/risk-TASK-20261101-HF1.md` A7

## 缺陷面（真缺陷，先在、非 4.0.10 引入）

同一轮运行内四步交错（hf-design-4 D4 定性，盘面证据见 HANDOFF 与 hf-impl-2 记录）：

1. 2.3.0 期弃用条目在运行中删除 `.codex/hooks.json`（字节保全于 `.tad-backup/…-deprecations/`）；
2. 同轮再生该文件，因生成时点文件缺席，被记为 run-created；
3. 运行失败触发回滚：步 2 自快照把该文件装回 live 树；
4. 回滚步 4 随即按 run-created 名单把它再删。

净效果：过两点之后的失败运行丢掉 live 的 `.codex/hooks.json`；字节仅存于弃用备份，可手工恢复、非自动。风险卡 A7 为其可证伪形态：若某次过拷贝阶段的失败运行能让该文件在 live 树逐字节完好且无手工步，A7 被证伪、本票关。

## 为何不在 4.0.10 热修内修（D4 裁断摘要）

修复点落在热修 §9 明列外两域——弃用行为本身、备份/快照子系统的 created-entry 追踪——与 U2 同型处置：命名排除＋立票，不在数据安全热修里顺手改无 fixture 覆盖的邻域。热修内仅把 aw.4 的全树逐字节条款按裁断改为**命名集身份**（差异面 ⊆ {`.tad/brain-index.md`, `.codex/hooks.json`}、集合照打、第三面即 FAIL），使缺口在每次发版运行中保持可见。

## 硬约束（本票落地前持续有效）

**`.codex/hooks.json` 不得移出 aw.4 命名集**——移出即等于宣称全树逐字节身份成立，与本缺陷事实矛盾；命名集收缩只许随本票修复落地、并以其 fixture 证明为准。

## 修复方向（设计输入）

- 候选面（设计步裁）：回滚步 4 的 created-entry 删除须排除「步 2 已自快照恢复」的文件；或弃用删除与再生在同轮发生时，created 记账以运行前快照存在性为准。两面都在备份/快照与弃用子系统内，设计步须先读该两域现状再裁。

## Gate 2 前置（硬条件）

**先有可独立复现「删→再生→恢复→再删」全序列的 fixture**：构造含 2.3.0 弃用条目命中的项目，在拷贝阶段之后注入失败，断言现行行为复现该序列（修复前）／修复后 live 文件逐字节完好（修复后）。fixture 不成立，本票不得进 Gate 2。

## 关联

- 热修链证据根：`.tad/evidence/yolo/v4010-hotfix/`（aw.4 命名集实测：Gate 3 `g3c-aw.4.log`、Gate 4 `p1-gate-report.md` RP1/RP3 对账）。
- brain-index 不在本票射程：其逐字节不可比是生成器内嵌时间戳＋不在回滚域的设计事实，已随 Gate 2 Q2 与 D4 裁断显名排除，非缺陷。
