# TICKET-20261005 — 本体收口批（v3.0.1 候选）

- 状态：**CLOSED**（2026-10-05 全链收口：Gate 2 双审 CONDITIONAL 经 PM 合并裁定＋增补核销 PASS；实施中 CF-3 停步经分诊＋PM 甲案裁定关闭；Gate 3 双审 PASS；Gate 4 PASS。批名转正「v3.0.1 本体收口批」，版本已升 3.0.1，提交与推送为 PM 收口动作、哈希见完事卡）
- task_id：TASK-20261005-TAD-CLOSEOUT-BATCH
- 性质：本体收口批——批内各件均为已判断/已定性事项的落地，不新开判断；走完整 TAD 链（Alex 设计→Gate 2 双审→Blake 实施→Gate 3 双审→Alex Gate 4→PM 提交推送）。

## 批内清单（7 件）

1. **C1 提交件**：仓根 `AGENTS.md`「File authority order」节（+16 行，D 线课程判断落地链 C3 项、已全链 PASS）现为工作区未提交改动，随本批提交入 main；GM S8 总核条件 C1 即指此件。
2. **台账口径头注**（GM 输入 1 落地）：本仓 `.tad/evidence/pm/downstream-versions.md` 加口径头注——版本扫描不含 goal 型仓（轻量装、无版本面）。
3. **项目自加槽契约**（GM 输入 2 落地）：发布/同步规程立条文——下游仓根文件中的项目自加内容以标记保留区（项目自加槽）保全，发布同步不许静默吞；现存实例（trading-agent 首段）迁移口径在设计中定明。
4. **research-methodology 投影补生成**（GM 输入 4 落地之一）：为该 pack 补生成 `.agents/skills/` 投影（现 26 pack 中唯一缺投影者）。
5. **登记↔投影一致性断言**（GM 输入 4 落地之二）：pack 扫描加断言——registry 登记与 `.agents/skills/` 投影缺一即红。
6. **S5 第五件**（/tmp 同名捕获串台事件）：多席同波次捕获输出到 /tmp 固定名互相覆写、证据串台；本体侧处置（捕获路径唯一化纪律的规程落点）由设计步定明并落地。
7. **gate skill 计数行修正**（D 线遗留）：`.agents/skills/gate/SKILL.md` Gate 3 节计数行（现作 6 项）与 Canonical Gate 3（7 项）对齐修正。

## 版本口径

- 本批是否升版（候选 v3.0.1）与批名，由设计步提议、PM 裁定、Gate 4 前定稿；版本号只写 `.tad/version.txt` 一处。
- 提交与推送为 PM 收口动作（沿 R1 路径：经 grokbox gh 登录态推送），提交完成即向 GM 同步批号＋哈希，供其发 12 仓刷新对齐令。

## 红线

- 只改本票清单内文件；仓外禁写；同名文件一律绝对路径＋Step 0 断言。
- 不动 `.gitignore`、不动 SC3；版本口径不许别处复述版本号。
- 批外新发现只登记报 PM，不许顺手扩批。
