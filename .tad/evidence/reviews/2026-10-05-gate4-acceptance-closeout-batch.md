# Gate 4 验收 — 本体收口批 v3.0.1（TASK-20261005-TAD-CLOSEOUT-BATCH）

- 验收者：Alex（Solution Lead），独立会话；性质：可执行性终判（非复审）——按 Canonical Gate 4 清单自盘面复算，实施者总结不作证据。
- 判据链：票 `TICKET-20261005-tad-closeout-batch.md`（七件＋红线）；Gate 2 合并裁定（CONDITIONAL PASS→增补全销转 PASS）；CF-3 裁定（采甲案）；Gate 3 双 verdict 均 PASS（CODE 正文 8,607 B／sha256 `921e9e24…`；SAFETY 正文 6,494 B／sha256 `141ea77d…`）；COMPLETION（18,387 B／sha256 `a645bf0a…`）与实施说明（5,344 B／`d4c9626e…`）、证据目录 `.tad/evidence/closeout-batch-20261005/`（11 件捕获，本验收逐件点名在盘）。
- **结论：PASS**（P0＝0／P1＝0；无 gate4_delta 条目）。

## ① 七件逐件对票（本验收盘上复算值）

1. **C1 提交件——就绪**：仓根 `AGENTS.md` L80 起「File authority order」节在盘；节域哈希经 Gate 3 CODE 路复算与 Phase 0 基线全等（`849ea922…`），本验收确认节在盘且文件对 HEAD 的 hunk 构成经 SAFETY 路集合级核清（标记行／C1 +16／指针行 +1，恰 3 hunk）。随本批提交入 main 的条件已齐，GM S8 条件 C1 的销账只差 PM 提交动作本身。
2. **台账口径头注——落且无漂移**：`.tad/evidence/pm/downstream-versions.md` L4 头注在盘（本验收亲读原文），标题 L6，行序合判据；头注由生成脚本 printf 落面、台账经 Phase 3 重跑生成（总数 53、TAD 行 3.0.1），非手改；锚短语与判断输入 1 全对应（SAFETY 路逐短语比对无漂移），口径＝版本扫描不含 goal 型仓。
3. **项目自加槽契约——成文且可照行**：release-runbook 内 `PROJECT-SLOT:BEGIN/END` 标记对在盘（本验收 grep 实测 L138/L140）；条文五要素（槽定义／覆盖前提取备份／回贴＋逐字比对判据／无槽存量逐案留痕／trading-agent 首段于下次对齐逐字迁槽）经 CODE 路 rubric 逐项判齐；与草案逐字 diff 为空（双审同证）。存量仓的实际迁移按条文口径在下次对齐执行，本批义务（立条文＋定迁移口径）已尽。
4. **research-methodology 投影——补齐且装载点位真实**：`.agents/skills/research-methodology/` 本验收 find 实测恰 12 件（SKILL.md＋references 5＋checklists 1＋scripts 2＋LICENSE＋LICENSE-ATTRIBUTION.md＋CONVENTIONS.md）；11 件与 pack 本体 sha256 逐件全等、SKILL.md 恰删 `status: frozen` 一行派生（CODE 路复算）；装载点位＝`AGENTS.md` L152 指针行在盘（本验收亲见整行，第二列 70 字符硬截断与 §4.6 给定逐字相等经双审同证）——投影有行可达、非孤岛。
5. **登记↔投影断言——装上且判红判绿已实证**：`scan-packs.sh` 断言段在盘（本验收 grep 实测：`pack_names` 收集 L141/L147、断言循环 L208、点名报错 L212）；fixture 三态经 CODE 路自建 fixture 独立复现（对照 exit 0／缺件 exit 1 点名 pack-b／补齐 exit 0），真实树正控 exit 0；断言单向（登记⊆投影）、无树 NOTE 跳过，误伤面经 SAFETY 路核清。
6. **S5 第五件（捕获纪律）——成文**：`.tad/tasks/evidence-collection.md` L284「Capture Path Discipline（捕获路径唯一化纪律）」节在盘（本验收亲见节题与 `mktemp`、`Cross-check before citing` 两锚）；与 §4.8 草案逐字 diff 为空（双审同证）。
7. **gate skill 计数行——对齐**：`.agents/skills/gate/SKILL.md` L280 `Critical Check (7 items):`、L290 Provenance 行在盘（本验收 grep 实测）；内联副本与 Canonical Gate 3 同为 7 项（CODE 路行集计数同证）。

**版本面一致性（本验收独立复算）**：`.tad/version.txt` 首行 `3.0.1`、`AGENTS.md` 标记 `(v3.0.1)`＝1／`(v3.0.0)`＝0、`.tad/TAD-VERSION`＝`3.0.1`、`config.yaml` `version: 3.0.1`、`tad.sh` `TARGET_VERSION="3.0.1"`、`package.json` `3.0.1`、registry 本验收亲见 2026-10-05 重生成态、台账 TAD 行 3.0.1——各机器面同值。扩面 12 文件 16 行经 CODE 路逐行实测改后值全对；类 A 168 件一件未动、豁免 3 件未动经 SAFETY 路集合级实证（191→173 恰消失 18 条授权面）。

## ② 提交就绪——清楚，可照行

- **提交面构成**：本验收 porcelain 抽核——本批面（release-runbook、pack-registry、downstream-versions、scan-downstream-versions.sh、scan-packs.sh、evidence-collection、version.txt 为 M；research-methodology 投影目录为 ?? 新建；AGENTS.md、gate SKILL、alex/blake SKILL、扩面各件的本批 hunk 在授权面内）与保留集隔离清楚：NEXT.md 的 M 为基线既存（mtime 早于本批实施、SAFETY 路实证），docs/pm 五件、`.tad/TAD-POINTER.md` 等丙层件未被本批触碰；`.gitignore` 无 diff、SC3 三件例外面未动（SAFETY 路核清）。
- **仅剩动作**：`NEXT.md:10` 与 `ROADMAP.md:3` 两行版本断言回填——CF-3 裁定 3 已点名行号、定性（随 release commit 由 PM 回填，NEXT.md 仅限该行）与归属（PM 收口），本验收亲读两行原文，均为单行可照行回填，无歧义；连同提交＋推送（票面定为 PM 收口动作、沿 R1 经 grokbox 路径），构成提交前仅剩的 PM 机械步，不属实施缺口、不构成验收条件。

## ③ 遗留登记——三条齐

实施说明「遗留登记句」节三条全数在册、各带指针正本：① 校验器漂移（`capability-skill.sh` 键集契约漂移、未被规程引用；指针 HANDOFF §4.5 末段，Gate 2 合并裁定 3 定批外）；② 版本口径恒久修订（「封顶两处」口径作废、恒久修订待另批；指针 CF-3 裁定 5/6）；③ minor/major 升版时 168 件史述面处置未定、须另行立项（指针分诊件 §3＋裁定 6）。三条均明确要求转录入本批完事卡遗留节——完事卡为 PM 关链件，登记义务已在实施面尽到，转录归 PM 关链时照行。

## ④ Canonical Gate 4 清单逐项复核

- **Functional acceptance**：§9.1 AC1–AC16 经 Gate 3 CODE 路逐条原样实跑全 PASS，本验收对七件落点与版本面另行盘上抽核复算（见 ①），无未决的实施后阻塞；仅剩 PM 收口机械步（②）不属阻塞。**自报不符句判读（gate4_delta）**：本验收复算未发现自报与盘上不符条目，gate4_delta 为空。实施者两处主动披露（AC11「25 对非 26」口径注记、AC1 首算口径误读当场自纠）经双审独立判读均为口径差／已纠正事项，与盘面一致，不构成自报不实；CODE 路 P2-1（COMPLETION 的 AC8 行填报口径与判据命令面错位、实质值经 AC7 行覆盖且复算成立）属填报对应瑕疵、非数值不符，记为非关闭注记。
- **Quality evidence complete**：Code review 证据在册（Gate 3 CODE verdict）；Security review 证据在册（Gate 3 SAFETY verdict，本批为文档／脚本／配置面，双审构成即本仓 Gate 3 定式）；Performance／UX 不适用（无运行时性能面、无 UI）。
- **Subagent issues resolved**：Gate 2 双路条件（fit C1/C2、tech P0/P1）经 PM 合并裁定＋增补 A1–A4 定点核全销；CF-3 停步经分诊＋PM 裁定关闭；Gate 3 双路 P0＝0／P1＝0，P2 注记（CODE 3 条、SAFETY 2 条）均为非关闭条件且各有判读去向（填报口径、尾随空行、设计口径订正建议、porcelain 时点值、check5 批前既存引用登记建议），无一悬置无主。
- **Knowledge Assessment complete**：COMPLETION §7 在册两条新发现（哈希判据作用域口径、登记面目录数≠登记数口径），Phase 0 遗留观察的处置闭环已注明。

## 结论

七件逐件对票成立、版本各机器面一致、提交面与保留集隔离清楚、回填口径明确可照行、遗留三条登记齐、双审结论与实施自报一致且经本验收复算无 delta。**Gate 4：PASS。** 后续 PM 收口动作（NEXT/ROADMAP 两行回填→提交→推送→批号＋哈希同步 GM→COMPLETION 回填 gate3/gate4 结论与票据关链）按票面与裁定照行即可；human CHECK 记「CHECK 待人」为既定留痕，不属本验收条件。
- 自报行：本 verdict 正文 8,294 B／sha256 `6202d1428ba4d49f33d5ba7483741b3fbf880f9f19f4292a32bc8440f5748baf`（自报行不计入正文，复算法：对本行之前全部字节计算）。
