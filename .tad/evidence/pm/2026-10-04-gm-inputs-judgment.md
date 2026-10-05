# 本体判断 — GM 上报四件输入（2026-10-04）

- 判断人：📐 TAD PM；输入正本：`yun-sync/gm/.tad/evidence/reports/2026-10-tad-pm-inputs.md`＋输入 4（2026-10-04 经 Main 追加）
- 方法：四件均 PM 亲查盘面后判断，非转述。

## 输入 1：下游版本扫描不含 goal 型仓

- 事实：yun-sync 下仅 `gemma-4`、`llc-formation` 两仓有 `.tad/`，且都只有 `active` 与 `project-knowledge` 两目录，**无 `version.txt`、无 TAD-VERSION**——轻量装、无版本面。
- 判断：**扫描器不扩。** 无版本面的仓扩进来只会读到空缺，制造假缺失。
- 处置：台账（`.tad/evidence/pm/downstream-versions.md`）加一行口径头注——覆盖范围为 yun-sync 席位仓；goal 型仓为轻量装、无版本面、不在口径内——随下个本体收口批落盘，消除「总数 53」的误读面。
- 边界：goal 型仓该不该带版本面是安装形态问题；GM 若要纳入版本治理，先提安装形态变更，本席再定本体口径。

## 输入 2：根 AGENTS.md 自加首段（trading-agent）

- 事实：PM 全文 diff 实测——trading-agent 根 AGENTS.md＝TAD 本体源 168 行＋文件首 4 行项目入口段（指引先读 PROJECT_GUIDE.md），其余逐字相同；内存管理一仓不成立（GM 复核一致）。全网仅此一仓此形态。
- 判断：**发布同步不许静默吞掉项目自加内容**——这是本体契约问题，不是下游保管问题。
- 处置：下个本体收口批给根 AGENTS.md 定「项目自加槽」契约（带标记的保留区，发布同步时保留槽内内容），落地时 trading-agent 现首段迁入槽内。在此之前，GM 现行做法（逐案留痕、重装前备份自加段）正确，照行。

## 输入 3：买卖仓 AGENTS.md 代际不一致

- 事实：PM 全文 diff 实测——买卖仓根 AGENTS.md 与 TAD 本体源**逐字一致**（同为 168 行、零差异），文件 mtime 为今日 B1B 同版重装时点。
- 判断：GM 观察在当时成立；成因＝旧装只更新了版本号面、入口件未随同重装。**今日 B1B 重装已消除，抽查项可关。**
- 本体侧并入既有口径：版本面与入口件必须同批更新（与 R1 第一批防再过期机制同向）；后续抽查以整件 diff 为准。本体无新增处置。

## 输入 4：research-methodology pack 投影缺失（买卖 apply warning）

- 事实：PM 亲查——`.tad/capability-packs/` 共 26 件，registry 登记齐全；其中 13 件 frozen，12 件在 `.agents/skills/` 均有投影，**唯独 research-methodology 缺**；该 pack 本体完整（CAPABILITY.md、references、checklists、scripts、install.sh 俱全）。
- 判断：**「frozen 不投影」的假设不成立**——其余 frozen 件全部有投影。定性为本体发布源**单件漏生成**；同时存在检测缺口：现行检查无「登记↔投影」一致性断言，漏件可长期静默。
- 处置：列入下个本体收口批两件——① 补生成 research-methodology 的 skills 投影；② 在 pack 扫描加一致性断言（registry 登记每件必须有 `.agents/skills/` 投影，缺即红）。
- 对推广：GM 下游处置（原样保留、自检 PASS、无功能影响）正确，本件**不阻塞** B1B 推广；投影补齐后，下游随下次重装自然带入。
