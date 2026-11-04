# TICKET-20261102 — migrate 用户数据救援拷贝原子化（U2 后续票）

**Status**: OPEN（后续票，2026-11-02 立；由 EPIC-20261101-v4010-hotfix 收口义务 R3 产生）
**Owner**: TAD PM（登记）；实施走本仓 Epic 全链
**来源**: HANDOFF-20261101-installer-atomicity §S0 Ruling Record（hf-design-3）R2/R3；风险卡 `.tad/evidence/risk-cards/risk-TASK-20261101-HF1.md` A6

## 缺陷面

`tad.sh` migrate 支的用户数据救援拷贝四点（S0 清扫编号 L6982/6985/6988/6991；终态行号以 Gate 3 安全面 AC7 普查为准）：

- 形态为普通 `cp … 2>/dev/null || true`——吞错＋非原子；两源布局顺序合并写入同一目的地 `.tad/active/handoffs/` 等项目所有目录，互覆盖。
- 残余缺陷（R2 定性）：救援拷贝撞写失败时，救回的 `.tad/active/` 树可能**静默不完整**——不报错、不留痕，运行照常收尾。
- 为何不是「毁唯一副本」级：源 `$MIGRATE_BACKUP_DIR` 是救援前以唯一名（撞名递增）做的全量 `cp -R` 副本，运行内不删改、收尾打印路径；失败后可按名手工补救。此定性由风险卡 A6 以可证伪形态承载，Gate 3 已代码读复核成立。

## 为何不在 4.0.10 热修内修（R2 四理由，摘要；全文见 HANDOFF S0 Ruling Record R2）

1. 目的地是项目所有用户数据，纳入即超出热修 Epic 第 1 项「框架面写入」的范围（扩围）。
2. 失效形与热修主缺陷（毁唯一副本）异种：源副本全量在盘且路径点名，残余是静默不完整。
3. 转换非机械：glob＋悬空符号链接、两布局顺序合并、glob 跳点文件 vs 树助手 `find` 含点文件——每处 delta 都需 fixture 覆盖，而热修链的 fixture 不能行使 migrate 路径，转换不可验。
4. 暴露面仅 ACTION=migrate；4.0.10 解禁波走 upgrade 支，不经此四点。

## 修复方向（设计输入）

- 四点改 fail-stop 或验真救援：任一拷贝失败须在首个失败点停步并点名，或拷贝后按清单逐件验真（源/目的地对账），不许静默收尾。
- 形态优先复用仓内既有原子助手（`atomic_install_file`/`atomic_install_tree`，4.0.10 已落），但其语义差（glob、悬空链接、顺序合并、点文件）须在设计步逐条对账，不许机械套用。

## Gate 2 前置（硬条件）

**先有能独立复现 migrate 路径的 fixture**：可构造旧布局项目、行使 ACTION=migrate 全程（含救援拷贝四点）、并在任一拷贝点注入写失败、断言「停步点名或验真拦截」与「源副本完好」。fixture 不成立，本票不得进 Gate 2。

## 关联

- 热修链证据根：`.tad/evidence/yolo/v4010-hotfix/`（S0 清扫报告 `p1-s0-sweep-report.md`、Gate 3 安全面 `p1-gate3-safety.md` A6 复核与 AC7 列名）。
- 在链见证：COMPLETION-20261101-installer-atomicity AC7 行按名列此四点为 excluded-by-ruling——本票落地前该列名口径不变。
