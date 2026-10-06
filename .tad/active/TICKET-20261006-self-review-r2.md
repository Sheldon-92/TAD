# TICKET-20261006-self-review-r2 — PM 自查批 R2（存量清账＋记忆层小件）

Status: CLOSED — 2026-10-06 全链收口（Gate 4 CONDITIONAL 经回归重放补跑整轮 PASS 销账转 PASS；组 2 C 类补测与开放票关票随 2026-10-10 补测小单） — 2026-10-06 立项（用户当面批准「按计划走」）
Owner: TAD PM ｜ 设计: Alex ｜ 实施: Blake

## 来源与范围

Epic EPIC-20261006 总收口转入＋记忆层提案判断（`.tad/evidence/pm/2026-10-06-memory-proposal-judgment.md`）采纳项。自查批性质：存量逐件定活/死、小件成批落地，不升版（批内若有必须升版的改动，攒到下一版本点统一处理，报 PM 裁）。

## 输入清单（七组，设计步逐组给处置法与判据）

1. **driftcheck (b) 11 件**：P1 遗留（清单以 `docs/pm/open-cards/done-20261006-epic-p1-clearance.md` 与 driftcheck 证据件为准，设计步 Step 0 先重构清单）；逐件复跑定活/死，活者逐件定案、死者批量销账。
2. **runtime-compat 台账复核**：开放票 TASK-20260916-CODEX-LEDGER-REVERIFY 辖区；release-verify freshness 现 BLOCK（12 条目 64 天未复核）。逐条以当前运行时实测复核，不得空改日期。
3. **备份修复刀残项 R1–R3**：R1 tad.sh L1744 另一处 `diff -rq` 同病灶换链接安全探针；R2 清新建顶层粒度一格（嵌套新建 registry 文件残留）；R3 `.tad-migrate-backup.*` 救援备份另行评估。
4. **gc 预检新项**：含 `git gc` 的链，设计预检新增「.git/refs loose 件预检」一条（P4 SAFETY P2-1 归口）。
5. **记忆借 1 测量实验**：以 project-knowledge＋brain-index 为语料建标准问题集，现行路由跑 Recall@k 与压缩比基线，两数落盘；只量不改。
6. **记忆借 2＋借 5 模板小件**：patterns／incidents 条目加来源型置信维（实测／转述／推断、低置信引用警示）；handoff／session-state 增「卸载记录」节。
7. **记忆借 3 一页设计**：自动捕获的体量设计（捕获面／上限／保留策略／入权威人工裁决），只出设计、不落地。

## 纪律

- 完整 TAD 链：Alex 设计→Gate 2 双审→Blake 实施→Gate 3 双审→Alex Gate 4。
- 版本冻结（批内不 bump）；git 写由 PM 在收口点执行。
- 组 2 与开放票 TASK-20260916-CODEX-LEDGER-REVERIFY 的关系在设计步写明（本批承接其实作，票不预先关闭）。
