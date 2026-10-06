# TICKET-20261006-tadsh-backup-fix — tad.sh 备份面收窄与落点迁移

项目：TAD 本体（安装器缺陷修复，GM 工单 2026-10-06）
Status: CLOSED — 2026-10-06 全链收口（Gate 4 PASS 无条件）
开票：2026-10-06（PM；来源：Home GM 证据件 gm/mechanism-updates/2026-10-06-tad-backup-disk-findings.md，经 Muse GM 工单转达）

## 缺陷（已坐实）

`tad.sh` Phase 2 `backup_existing()`（约 L481–501）每次安装/升级 `cp -R .tad .tad.backup.<时间>` 整份复制含 evidence（数据面占绝大部分，框架仅约 15M），备份落项目根同步盘内、从不清仓；两天三轮刷新滚至约 150 份，grokbox 盘一夜 67%→78%。

## 修复要求（GM 验收口径，四条全收）

1. 备份面收窄：只备框架与配置面，排除 `.tad/evidence`、`.tad/archive` 及同类数据面；备份体量回 MB 级。
2. 落点移出同步盘：默认 `~/.tad-backups/<仓名>/<时间戳>/`（本机本地），不再落项目根。
3. 自动保留策略：每仓最近 2 份，写新份时自动清旧。
4. rollback 读新落点、功能不退化；与 Phase 3 承接 B 已转常设的回退还原机制同口径（分子分母与验证法对齐，不另立第二套）。

## 约束

- **冻结令在效**：本链修复经 GM 验盘解冻前，不得对真实项目仓跑 tad.sh 安装/升级；隔离测试仓演练不在此限，产物备份不得落任何真实项目仓。
- sequencing：不单独发版，修复随 Epic 最终版统一发布；但修复完成先报 GM 验盘，验过由 GM 解冻（解冻不等发版）。
- 旧备份 150 份清理：等用户点头后 GM 统一组织，本链不碰。

## 流程

- full 档：Alex 设计（HANDOFF）→ Gate 2 双审 → Blake 实施 → Gate 3 双审 → Alex Gate 4 → PM 收口报 GM 验盘。
- 与 Phase 4 的边界：Phase 4 件 4.1 只做本仓体量分诊；安装器备份行为归本票，互不重叠。
