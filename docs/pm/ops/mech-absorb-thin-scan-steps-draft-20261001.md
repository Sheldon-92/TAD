# DRAFT / 未定稿 · mech-absorb 薄扫步骤纸

> **状态：** 草稿，需人类定稿后才可作为 PM 操作约定引用。两份 Oct-1 扫描是 worked examples，不构成后续派活授权。
> **范围：** PM 可操作的 discuss-only 薄扫；不改 TAD Gate、SKILL、模板或配置，不替代正式设计、Gate 或实现流程。

## 目的与产物

按顺序完成一次缺口扫描、组合筛选，再只推荐一个下一刀候选。推荐不是派活或实现授权。

- **缺口扫描**：比较人指定的来源与 TAD 当前载体，列出已吸收、部分吸收、未吸收及证据边界。
- **组合筛选**：只使用缺口扫描结果，按本次组合目标筛选 yes / defer / hand-GM。
- **单一建议**：点名一个候选及范围；若无可建议项，写明 HOLD 原因和解锁人。不得裸写 WAIT。

## 开跑前：锁定范围、模型与顺序

1. 只有人明确点名这次 mech-absorb 薄扫，且指定目标、来源、组合目标、输出目录和 discuss-only 边界，才开跑。先写非空 restate；人确认理解正确后再继续。
2. PM 先把完整 open-run card 发给人类的 1:1 对话，内容至少含项目、任务名、角色、通道与完整模型 ID、环境、目的、restate 路径、stamp 路径、证据目录及硬停止条件。**先发全文，再记 stamp，再启动 Codex / 包装器。** Stamp 只能记录已实际发送的卡片及其时间；不得把盘上卡片写成已发送证明。
3. 按人给的临时 Codex 锁执行，不把它固化为长期默认。2026-10-01 两刀所用参考锁为：Alex discuss / research = `gpt-6.1-sol`；Blake / Review = `gpt-6-luna` + `CODEX_EFFORT=max`。核对共享路由 `/home/box/云同步/grok-cloud/docs/model-routing.md` 和临时偏好 `/home/box/云同步/gm/ops/codex-prefer-temp-2026-10-01.md`；该临时偏好预计 2026-10-03 日终复检。**新刀开跑前重查锁和额度，已开跑的刀不切模型**。锁过期、冲突或不可用时停下，交人确认，不自行换模。
4. 确认没有把讨论请求扩大成吸收实现、Gate 判定、发布或外仓写入。字段不齐、restate 与卡片不一致或人未确认时，不启动。

## 第一步：缺口扫描

1. 只检查本刀点名的 PM / TAD 载体和对照来源；记录检查范围、来源、证据限制。`未发现` 只对实际检查范围成立，不外推为全仓或运行时不存在。
2. 把每个相关机制分为 yes / partial / no（已吸收 / 部分吸收 / 未吸收），写清现有载体、具体缺口及候选承载路径。扫描只记录缺口，不创建或修改吸收内容。
3. 写出 `STATUS.md`、`GAPS.md`、`RECOMMEND.md`：STATUS 记录讨论范围和 Verdict；GAPS 逐项给证据；RECOMMEND 最多点名一个下一刀候选。Verdict 只描述本次讨论扫描结果，不是 Gate PASS。

## 第二步：组合筛选

1. 以 GAPS 为输入；不重跑缺口搜索、不把建议载体误当写入授权。
2. 结合本次人指定的组合目标，逐项标为 `yes`、`defer` 或 `hand-GM`，并写理由和建议载体。`yes` 仅表示建议进入候选吸收刀；本薄扫不落地 yes 项。
3. 写出 `STATUS.md`、`FILTER.md`、`RECOMMEND.md`。RECOMMEND 只能点名一个候选，并收窄到 FILTER 中的 yes 项；defer 与 hand-GM 不并入该候选。

## 收口与停止

- 最终只留一个 `next_knife_candidate`，注明“推荐，不等于派活”；若无合适候选，写 `HOLD`、具体原因和解锁人。状态写 `continue: no`，不得留下本刀“在途”指针。
- 将 PM 的 `now.md` 与对应 segment-status 更新为已闭合，并指向候选或 HOLD；历史证据和历史 Verdict 保留，不因后续任务重写。
- 在写完规定证据三件套后停止。不得实施 FILTER yes 项、建 HANDOFF、开 Gate 2、声称 Gate 3/4 通过，或把讨论结果当吸收完成。
- 如果任务范围、模型锁、来源可读性或候选授权发生变化，停止当前扫描并记录缺口；需要新的人类点名才能另开刀。
- 不 release、tag、push 或 Publish；不写 gm / grok-cloud；不写外部脑；不借本步骤纸改写 TAD Gate 或通用 SKILL。

## Worked examples

- 缺口扫描：`.tad/evidence/pm/2026-10-01-mech-absorb-scan/`（`STATUS.md`、`GAPS.md`、`RECOMMEND.md`）
- 组合筛选：`.tad/evidence/pm/2026-10-01-mech-notes-portfolio-scan/`（`STATUS.md`、`FILTER.md`、`RECOMMEND.md`）
