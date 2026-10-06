# 件 2.8 同病扫描补扫记录 — G2 按 §4.8 规定集全量补跑（2026-10-06）

- 性质：Gate 3 共同 P1（AC24）关闭件。PM 裁断 `.tad/evidence/pm/2026-10-06-epic-p2-gate3-ruling.md` 取 (b) 补跑，本记录即补跑产物；首轮扫描记录 `seat-name-scan.md` 不动，本件为其覆盖面补全。
- 执行：Blake（Gate 3 条件补扫步），2026-10-06。

## 原执行集 vs 规定集

- **原执行集（首轮，窄集）**：`.tad/templates/`、`.tad/installer.sh`、`tad.sh`、`.agents/skills/{tad,alex,blake,gate-execution}/SKILL.md`、`.tad/TAD-POINTER.md`、`.tad/brain-index.md`、`AGENTS.md`。其 G2 输出 126 行、逐行判读全 LEGIT（`2.8-scan-g2.txt`／`2.8-g2-verdicts.md`），数字对其实际执行集属实，但该集只是下述规定集的子集。
- **规定集（§4.8 写死）**：`.tad/templates/`、`.tad/tasks/`、`.tad/gates/`、`.tad/project-knowledge/`、`.tad/scripts/`、`.tad/hooks/`、`.agents/skills/` 七树全文件，加顶层件 `tad.sh`、`AGENTS.md`、`.tad/*.md`、`.tad/config.yaml`；排除 `.tad/evidence/`、`.tad/archive/`、`.tad/active/`。本席按此构造文件清单（find 七树 -type f ＋顶层件，sort -u）＝ **754 文件**，与 CODE 路评审独立构造的 754 文件逐值相同。
- **行数差**：规定集全量重跑 G2（`grep -HnE '^#{1,3} .*— '` 逐字口径）＝ **1,098 行**，与 CODE 路复跑逐值相同；原执行集 126 行经集合校验**完整包含**于 1,098 行中（comm 差集外行数＝0）；**补扫集＝1,098 − 126＝972 行**，与 PM 裁断「残量约 972 行」逐值对上（SAFETY 路「约 967 行」为其约数口径）。补扫原始输出：`2.8-rescan-g2.txt`。

## 补扫集构成（972 行／330 文件）

| 来源面 | 行数 |
|---|---|
| `.agents/skills/` | 692 |
| `.tad/hooks/` | 141 |
| `.tad/project-knowledge/` | 101 |
| `.tad/scripts/` | 35 |
| 顶层件（AGENTS.md 等） | 2 |
| `.tad/gates/` | 1 |

（`.tad/templates/` 与 `.tad/tasks/` 的 G2 行已全数落在首轮 126 行内，补扫集为 0。）

## 判读方法（§4.8 写死规则逐行适用，非 token 预扫代替）

DISEASE ⇔ 三条全立：①文件∈传播面 S（补扫集全行自动成立）；②名 token 指某个具体席位或项目（框架名 TAD 本身、流程符号、框架角色通名不算）；③位置为自指位且以该名自称。三条缺一即 LEGIT。执行上逐行三层过：种子/席名 token 筛（G3 种子组＋本生态席位/项目名录扩展）→ 符号筛（标题与后缀的 emoji/符号构成）→ 后缀专名短语全量清单人工过目（796 个去重短语逐个定性）；程序辅助归类后每行落入一个判读类别，类别即该行判读依据；另随机抽核 54 行回读原文复核分类（DESC 兜底类抽 30 行，无一藏名）。

## 判读汇总：LEGIT 972／DISEASE 0

| 类别 | 行数 | 判读依据要旨 |
|---|---|---|
| DESC 描述性后缀 | 747 | 步骤/功能/主题说明，无具体席位/项目名 token |
| SYM 符号伴随 | 60 | ⚠✅❌🔒✓→≠≥≈═─∪∩ 等警示/状态/排版符号伴随描述后缀，符号非名 token |
| LEVEL 等级/状态 | 58 | Blocking／MANDATORY／Required／P0–P3 等级词后缀 |
| EXT 外部专名指涉 | 47 | 第三方产品/框架/机构名（Europeana、LangGraph、Claude、GitHub 等）在标题中作讨论对象被指涉，文件不以其自称 |
| ROLE 职能模板名 | 21 | skill 角色面职能通名（QA 主管、Mobile Security Reviewer、Database Query Helper 等） |
| DATE 日期/版本 | 21 | 日期、版本号、编号后缀 |
| FRAME 框架自述/通名 | 13 | TAD 自述、Alex/Blake 框架角色通名、YOLO 框架运行模式名 |
| REF 具体名指涉（边界行） | 2 | 见下点名段 |
| WORKTAG 归属标注 | 2 | 本链自产脚本头注的 Epic P2 件号标注 |
| EXTNAME 人名指涉 | 1 | 见下点名段 |

逐行附表：`2.8-rescan-g2-verdicts.md`（972 行逐行在列、逐行带类别依据）。

## 边界行点名（三行，逐行判读依据）

- `.agents/skills/alex/references/research-plan-protocol.md:11` 与 `:13`（REF）：具体项目名 LOCAL-WIKI/local_wiki 出现于更新注记与扩展节标题。两行主语均为本协议的 Deep 研究流程，local_wiki 是被采用的外部规范源/路由对接方（"uses local_wiki canon loop"、"canon loop for Deep via local_wiki primary"），属**指涉**而非本文件**自称**——规则三不立，LEGIT。此为全补扫集中唯一带本生态具体项目名的行组，已逐行读上下文坐实。
- `.agents/skills/ai-podcast-production/references/script-writing.md:53`（EXTNAME）："Reference Style — Xu Zhiqiang (Kan Lixiang) Method"，人名是播客写作参考风格的来源人物，非席位名/项目名、非自称——规则二不立，LEGIT。
- `.tad/scripts/interrupt-resume-check.sh:2`、`.tad/scripts/regression-replay.sh:2`（WORKTAG）：本链自产脚本头注，破折号后为功能描述＋「（Epic P2 件 2.3／2.1）」归属标注，非以他项目名自称，LEGIT。

## 旁证（本席本次于规定集全量实跑）

- G1 `grep -F '📐 TAD'`：**0 行**。
- G3 种子组 `grep -iE 'menu[- ]?tales|fidara|grok[- ]?cloud|musecloud'`：**0 行**。

## 结论

补扫集 972 行逐行判读 **全 LEGIT、无额外 DISEASE**，不触发停步、写集不扩展。合并首轮 126 行：§4.8 规定集 G2 全量 1,098 行判读至此完成，AC24 字面（按规定集执行＋逐行判读）满足；连同 G1/G3 全集 0 行，件 2.8「POINTER 之外无第二处同病」的结论在全规定集上成立。COMPLETION 的 AC24 行已按裁断以可见追记更正（指针见追记）。
