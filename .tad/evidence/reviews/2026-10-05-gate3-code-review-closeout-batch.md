# Gate 3 CODE Review — 本体收口批 v3.0.1（TASK-20261005-TAD-CLOSEOUT-BATCH）

- 评审路：CODE（独立会话，与实施者不同会话）
- 结论：**PASS**
- 问题计数：P0＝0／P1＝0／P2＝3（均非关闭条件，见文末）
- 评审对象锚：HANDOFF 66,327 B／sha256 `dabaf3298234e72855e03874090c18525cb8d0a2095216ba8744c20c40af242e`（开审复算全等）；COMPLETION 18,387 B；判据链＝票＋HANDOFF §9.1（Gate 2 修订后文本）＋PM 裁定两件（Gate 2 合并裁定、CF-3 裁定甲案）。
- 审法：AC1–AC16 逐条原样实跑复算，与实施者自报逐值比对；证据否决子款已行使——全部关键自报值（哈希、计数、行号、集合、退出码）经重算与盘面相符，无一行触发否决。

## AC 逐条复算结果

| AC | 本审复算值 | 与自报比对 | 判 |
|---|---|---|---|
| AC1 | 节域提取命令原样实跑 ＝ `849ea922ba24d94768d5c2f107d3f6b4ecbb09d19fd12dde3eea0ed99bce7c38` | 与 Phase 0 基线、Phase 3 复算、设计参考值四方全等 | PASS |
| AC2 | 基线捕获 `git-status-baseline.txt` 实测 72 行；COMPLETION §3 分类表行号覆盖 1–72，甲层 2 行、乙层同文件分 hunk 注明、丙层其余，无未点名行 | 相符 | PASS |
| AC3 | `grep -n '覆盖口径'` 恰 1 命中 L93；source-of-truth printf L92 ＜ 93 ＜ 台账标题 printf L95；`bash -n` 通过 | 相符（L93／L92／L95 逐值一致） | PASS |
| AC4 | 头注全串台账内恰 1 命中 L4，标题 `# 下游仓版本台账` L6（4＜6）；台账总数 53、TAD 行 3.0.1；生成器 Phase 3 捕获 exit 0 | 相符 | PASS |
| AC5 | awk 行序 `ORDER_OK`（113＜126＜172）；`PROJECT-SLOT:BEGIN`／`END` 各 1；落盘节与 §4.4 草案抽取比对：45 内容行逐字全等（尾随节间分隔空行 1，见 P2-2） | 相符 | PASS |
| AC6 | rubric 逐要素核对（本审独立判读）：槽定义（标记对）／覆盖前提取备份／回贴＋byte-identical 逐字比对判据／无槽存量逐案留痕（Record it per case）／trading-agent L1–4 于 next alignment 逐字迁槽（executed by the sync side, not by this contract）——五要素逐项在册，关键词探针各恰 1 命中；条文与 §4.4 草案逐字同（同 AC5 比对） | 五要素齐备 | PASS |
| AC7（修订版） | 七项逐项实跑：① 目录＋SKILL.md 在册；② 文件集恰 §4.5 清单 12 件（find 全量枚举比对）；③ 禁入四件 0；④ 符号链接 0；⑤ frontmatter `name: research-methodology`；⑥ `{{`／`[TODO]`／`[TBD]` 各 0；⑦ 非 SKILL 11 件与 pack 本体逐件 sha256 全等（双侧 find＋sha256sum diff 为空） | 全相符 | PASS |
| AC8 | 按 §9.1 命令面复算：文件集集合相等＋11 件哈希全等＋forbidden 0（与 AC7 ②③⑦ 同值，已独立跑出）；另 COMPLETION 该行所报 status 清理面复核：投影内 `^status: ` 零命中属实 | 实质判据成立；自报行口径错位见 P2-1 | PASS |
| AC9 | `diff CAPABILITY.md SKILL.md` 输出恰一行 `6d5 < status: frozen`，无其他增删 | 逐字相符 | PASS |
| AC10 | `grep -c '^| research-methodology |'` ＝1（L152）；第二列长度实测 70 ∈[60,75]；python 校验：为 pack-registry.yaml 中 research-methodology description 的真前缀，且与 §4.6 给定 70 字符逐字相等 | 相符 | PASS |
| AC11 | 真实树等价重跑（/tmp 镜像：CAPABILITY.md 全量拷贝＋skills 符号链接，仓内零写入）exit 0；镜像重生成 registry 的「包名＋status」集合与基线证据 25 对 diff 为空（SET_OK）；仓内现行 registry 同法抽取亦 25 对、全等；Phase 3 捕获 exit 0 在册。计数口径独立判读见下节 | 实质判据（exit 0＋SET_OK）成立 | PASS |
| AC12 | 本审自建 fixture（§4.7 规格，独立 mktemp）三态原样复现：对照（HEAD 版脚本，git show 提取）exit 0／负态（现行脚本、pack-b 缺投影）exit 1 且 stderr 点名 `pack-b`／正态（补齐）exit 0；与证据目录三件捕获逐行一致 | 相符 | PASS |
| AC13 | awk 行序：§7 节首（`### 7. Delivery Evidence` L245）＜ Capture Path Discipline L284 ＜ Pattern Recognition L304，ORDER_OK；`mktemp` ＝1、`Cross-check before citing` ＝1；落盘节与 §4.8 草案 19 内容行逐字全等（尾随分隔空行 1，同 P2-2） | 相符 | PASS |
| AC14 | ① `Critical Check (7 items)` ＝1、`6 items check 6 distinct artifacts` ＝0；② `Provenance non-empty` ＝1（L290）；③ 行集计数：gate SKILL 内联 Critical Check 列表 7 项、Canonical Gate 3 列表 7 项，两边同为 7 | 相符 | PASS |
| AC15 | `version.txt` 首行 3.0.1；AGENTS.md `(v3.0.1)` ＝1、`(v3.0.0)` ＝0；**扩面 12 文件 16 行逐行实测改后值全对**：config.yaml L1/L3、TAD-VERSION 整行、tad.sh L26、package.json L3、README L3/L190、INSTALLATION_GUIDE L3/L55、PROJECT_CONTEXT L4/L6、MULTI-PLATFORM L3、tad-help L17、alex L50、blake L166、CODEX-USER-GUIDE L58；派生面 registry `synced_from_version: "3.0.1"`、台账 TAD 行 3.0.1。参考核查判读见下节 | 逐值全等 | PASS |
| AC16 | Phase 0 基线 72 行与本审当值 porcelain 比对：基线行**零消失**（comm 差集为空）；增量 22 行 ＝ 写集/扩面/生成面 18（version.txt、release-runbook、evidence-collection、scan-downstream、scan-packs、pack-registry、downstream-versions、config.yaml、TAD-VERSION、tad.sh、package.json、README、INSTALLATION_GUIDE、PROJECT_CONTEXT、MULTI-PLATFORM、CODEX-USER-GUIDE、tad-help、blake）＋新建投影目录 1＋PM 本链开跑卡 3（其中 2 张 COMPLETION 已点名披露，＋Gate 3 开跑卡 1 张为 COMPLETION 后落盘的本链过程件）；AGENTS.md 对 HEAD 恰 3 hunk（标记行替换／C1 节 +16／指针行 +1），gate SKILL、alex SKILL 变化面与 §5 落点表一致。封顶未破 | 相符 | PASS |

## 两处口径注记的独立判读

1. **AC11 计数（25 对 vs 设计文 26）**：本审实测——`.tad/capability-packs/` 子目录 26 个，其中 `agent-computer-interface/` 仅含 `install.sh`、无 CAPABILITY.md，不在 scan-packs 登记面内（批前既存盘面）；登记面实数 25，与基线证据、现行 registry、镜像重跑三方一致；该目录投影实存于 `.agents/skills/agent-computer-interface/`，不受件 5 单向断言约束。实施者在 COMPLETION §6/§7 已注明口径（目录数≠登记数）并附盘面归因；按 Canonical E 维口径——注明口径后重算成立，不构成自报不符。AC11 以其实质判据（正控 exit 0＋重跑前后集合相等）判 PASS；「26 对」系 HANDOFF 设计文本的口径差，归设计面注记（P2-3），非实施缺陷。
2. **state-surface check5（AC15 参考核查）**：捕获四项 FAIL 指向 `.tad/active/session-state.md` 索引引用的四个已迁档件；本审实测四件均实存于 `.tad/archive/handoffs/`（含 EPIC-20260816-framework-health 子夹），迁档为 2026-10-04 B 线动作、早于本批；本批 porcelain 中 session-state 无变化、写集不含之。归因「批前既存引用」属实，与版本面无关，不影响 AC15。另 check1/check2 FAIL（NEXT.md／ROADMAP.md 头部版次）属 CF-3 裁定 3 点名的 PM 收口回填面，本步按裁定不碰，属设计内状态；check3/check4 PASS 与盘面一致。

## P2 注记（非关闭条件）

- **P2-1**：COMPLETION §6 的 AC8 行所报实测口径（投影内 status 清理面）与 §9.1 AC8 命令面（集合相等＋哈希＋forbidden）错位；该行应报之值已由其 AC7 行 ②③⑦ 覆盖且经本审复算成立，故不构成数值不符，但自报行与判据行的一一对应关系受损。建议后续 COMPLETION 的 AC 逐项严格按 §9.1 原文逐行填报。
- **P2-2**：件 3／件 6 落盘节较 §4 草案各多一尾随空行（节间分隔，Markdown 常规格式）；COMPLETION §5 的 +46／+20 行数计数已含此行、与盘面一致，内容行逐字全等。严格「diff 为空」口径下属一空行之差，记录在案，不影响 AC5/AC13 判据（行序＋锚点）成立。
- **P2-3**：HANDOFF §9.1 AC11 方法文「各 26 对」与登记面实数（25 对）口径不符，源在设计文本按目录数计；建议随后续批次订正设计口径表述（批外事项，不在本链处置）。

## 结论

AC1–AC16 全部经独立复算成立，实施自报关键值逐值与盘面相符，证据否决未触发；扩面、C1 节、版本面、投影、断言、条文六面均与裁定及设计给定逐字/逐值对齐。**Gate 3 CODE 路：PASS。**
- 自报行：本 verdict 正文 8,607 B／sha256 `921e9e240f842c76f214a5834d61a7a05938f409cd2b45e6c40dadc5aef99f0c`（自报行不计入正文，复算法：对本行之前全部字节计算）。
