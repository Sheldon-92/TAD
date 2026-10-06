# 件 2.8 同病扫描记录 — 席名/项目名硬编码（传播源侧）

## 本病与已治件

- 本病：发布源模板在自指位置硬编码具体席名，刷新覆写致各席本地更正恒回退。已治件：`.tad/TAD-POINTER.md` 首行 `# TAD 常驻指针 — 📐 TAD` → `# TAD 常驻指针`（改前快照 `2.8-pointer-before.md`；改后第 2 行起与基线 diff 为空、全文 diff 仅首行）。
- 扫描目的：在同一传播面内查是否还有第二处同病（额外 DISEASE 命中即停步报 PM，不在本链扩写集——本记录结论见末节）。

## 扫描集 S（传播源侧，§4.8 定稿）

`.tad/templates/`、`.tad/installer.sh`、`tad.sh`、`.agents/skills/tad/SKILL.md`、`.agents/skills/alex/SKILL.md`、`.agents/skills/blake/SKILL.md`、`.agents/skills/gate-execution/SKILL.md`、`.tad/TAD-POINTER.md`、`.tad/brain-index.md`、`AGENTS.md`。

## 三组 grep（§4.8 逐字口径）

- G1：`grep -rnF '📐 TAD' S`（本病原串）
- G2：`grep -rnE '^#{1,3} .*— ' S`（标题带破折号后缀的行＝席名/项目名最常见的藏身位）
- G3：`grep -rniE 'menu[- ]?tales|fidara|grok[- ]?cloud|musecloud' S`（已知他项目名种子组）

执行注记（诚实记录）：本席首轮扫描误以转述口径分组（G2 取 PM-seat 字面、G3 取 📐 文件面），产出与 §4.8 逐字定义不符；已在落记录前自查抓出并按上方原文三组重跑，以下结果全部出自重跑（原始输出 `2.8-scan-g1.txt`／`2.8-scan-g2.txt`／`2.8-scan-g3.txt`；首轮中间件 `2.8-scan-g2-files.txt` 留存备查、不作判读依据）。另 G3 为种子级词表、非全集：判读规则兜底——凡具体席名/项目名出现在自指位置者，纵未被种子组命中、经判读亦按同病论；本轮以 G2 标题面＋G1 原串面承担兜底，未见漏网形态。

## 结果与逐行判读

- **G1：0 行。** POINTER 修复后，本病原串在整个 S 集绝迹（修复前唯一命中即 POINTER 首行，基线在案）。
- **G3：0 行。** S 集内无任何他项目名（种子组全表）。
- **G2：126 行，逐行判读全 LEGIT、DISEASE 0 行。** 命中全为标题/注释行的描述性破折号后缀，四类：① 模板件的等级/说明/占位后缀（如 `### P0 — Blocking`、`# Surplus Plan — {DATE}`）；② tad.sh 函数与段落注释的功能说明后缀；③ alex/blake skill 的协议标题后缀（协议名/日期/警示）；④ AGENTS.md 的框架自述标题（`# TAD Framework — Codex Agent Roles`，框架通名、对任何安装都正确）与适用范围注。无一行在自指位置携带具体席名或项目名。逐行判读附表：`2.8-g2-verdicts.md`（126 行全列、逐行带类目标注）。

## 结论

- 额外 DISEASE 命中：**无**。不触发停步，本链写集不扩展。
- 本病在传播源侧的存量即 POINTER 一处，已治；S 集其余面干净。
