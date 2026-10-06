# Gate 2 Tech Review — TAD 本体收口批（v3.0.1 本体收口批）

- task_id: TASK-20261005-TAD-CLOSEOUT-BATCH
- 评审路: tech（独立会话，与 fit 路不同会话）
- 评审对象: `.tad/active/handoffs/HANDOFF-2026-10-05-tad-closeout-batch.md`
- 对象锚复算: 62,785 字节 / 711 行 / sha256 `b0e5ba0a20271f331f6915b30e36ed7afa83a89021087bfdc95982ed49f96962`，与任务书锚一致
- 评审日期: 2026-10-05
- 评审方法: HANDOFF 全文通读（§1–§12、AC1–AC16、CF-1…CF-5、Phase 0–3、§7 写集/保留集）＋逐项独立抽核（盘面实测、脚本通读、/tmp fixture 实跑、投影物化模拟）；未采信设计自报值
- 结论: **CONDITIONAL**

## 1. 结论摘要

七件的落点、写集与多数判据经独立抽核成立。AC7 与 AC9 经实测互斥，Blake 按现设计实施必在 Gate 3 挂一行（P0，§3.1）。§4.6 指针行文字与 AC10 上限互斥（P1，§3.2）。§4.2 分类表未预置本链流程自产路径，Phase 0 必触发一次可预见的停步（P1，§3.3）。三项均可在 PM 合并裁定＋Alex 增补回填内收敛，不要求设计主体返工，故判 CONDITIONAL。三项条件须在 Blake 开工前销账。

## 2. 逐件核查结果（独立抽核）

**件 1（提交面三层分类）**：AGENTS.md 盘面与设计一致——`git diff --numstat` = 16 增 0 删、全文 184 行、`### File authority order` 在 L80、`### Interaction decisions` 在 L96。AC1 判据命令实跑得哈希 `849ea922ba24d94768d5c2f107d3f6b4ecbb09d19fd12dde3eea0ed99bce7c38`，与设计完工说明所记基线参考值逐字相等，判据命令可实跑、基线已锚。保留集点名抽核命中：`.codex/` 未跟踪在册；`.git/logs/refs/remotes/origin/main.sync-conflict-20261004-225943-L64KYDF` 冻结件在 porcelain 内。分类覆盖缺口见 §3.3。

**件 2（台账口径头注）**：`scan-downstream-versions.sh` printf 块实测顺序为 source-of-truth 行→空行→`# 下游仓版本台账` 标题行，与 §4.3 的插入点描述逐字相符；现台账首 5 行与脚本输出形态一致。AC3 行序断言、AC4 行号断言均可实跑。

**件 3（项目自加槽契约）**：release-runbook 两锚节实测在位且顺序正确——`## Mechanical authority and exit codes` L113、`## Global safety stops` L126，新节插入点成立；`tad.sh` L1224 为 root-file 段起点注释，与 §4.4 引用相符；下游 trading-agent 根 AGENTS.md 实测 172 行、L5 起为 TAD 本体标题，§4.4 的存量实例描述（首 4 行自加段）准确。AC5 awk 判据可实跑。

**件 4（research-methodology 投影补生成）**：pack 本体与 §4.5 清单逐项相符（12 件 CREATE 清单准确）；`^status: ` 在 CAPABILITY.md 恰 1 次、位于 frontmatter 内（L6）；registry 该 pack 行在册。投影同构规则经两样本实测为真：academic-research 与 agent-memory 的 SKILL.md frontmatter 恰为 CAPABILITY.md 去 `status:` 一行（version/type/keywords 均保留）。材料化规则本身可执行；其与 AC7 的冲突见 §3.1。

**件 5（一致性断言）**：`scan-packs.sh` 全文通读——参数解析段、`--packs-dir` 分支、OUTPUT 派生（`$PACKS_DIR/pack-registry.yaml`）、扫描循环（以目录基名得 pack_name）、末行 echo 位置均与 §4.7 描述相符，断言段可按设计植入。在 /tmp 按 §4.7 规格建 fixture 实跑现行未改脚本：exit 0（对照态成立，registry 写进 fixture、真 registry 未触碰）。按设计公式模拟断言：根目录派生 `<fix>/.tad/capability-packs/../..` = `<fix>` 正确；缺投影时点名 pack-b；补齐 SKILL.md 后缺件集为空。AC12 三态判据真能判红判绿。

**件 6（捕获路径唯一化纪律）**：`.tad/tasks/evidence-collection.md` 锚点实测——`### 7. Delivery Evidence` 在 L245、`## Pattern Recognition Protocol` 在 L284，与 §4.8 一致；新节名在现文件 0 命中。AC13 awk 对现文件输出 `ORDER_FAIL`，判据两侧可区分。

**件 7（gate skill Gate 3 计数行）**：Canonical Gate 3 节实测 7 项（`.tad/gates/gate-canonical-checklist.md` L37 起），第 7 项为「Provenance non-empty (advisory)」。gate skill inline 副本（`.agents/skills/gate/SKILL.md` L275–292 注释块）实测 6 项：计数行「Critical Check (6 items)」、MECE 行「6 items check 6 distinct artifacts」、Provenance 行缺失。三处改动定位准确，AC14 可实跑。

**版本面（CF-3 事实基线）**：`.tad/version.txt` 首行 `3.0.0`；AGENTS.md `(v3.0.0)` 标记恰 1 处；`.tad/config.yaml` L3 `version: 3.0.0`；`tad.sh` L26 `TARGET_VERSION="3.0.0"`；`.tad/TAD-VERSION` 内容 `3.0.0`。五面现状与 §4.10 的「只动两处」封顶前提相符，AC15 判据形态成立。

## 3. 问题清单

### 3.1 P0 — AC7 与 AC9 互斥，按现设计实施必挂一行

实测证据（本评审在 /tmp 隔离根完整复演）：

1. 按 §4.5 规则物化投影（复制 pack、CAPABILITY.md 更名 SKILL.md 并删 `status:` 行、去禁入四件）后，`capability-skill.sh validate <root> research-methodology` 退出码 2，报错 `frontmatter contains extra keys (only name+description allowed)`，点名 `keywords:` 与 `type:` 两键。
2. 同一校验对既有投影 academic-research、agent-memory 亦退出 2（同规则、同点名）——现存 26 件投影无一能过此校验。
3. 在模拟投影上再删 `keywords:`/`type:` 两行（即违反 AC9 的「diff 恰删 status 一行」）后，validate 退出 0、verify 输出 `VERIFY PASS`。
4. 该脚本通读确认：`validate_canonical` 硬性规定 frontmatter 只许 `name:`＋`description:` 两键；脚本头的 canonical 定义为 `.agents/skills/<name>`（v3.0.0 起唯一技能源），`project` 子命令已移除（fail-closed tombstone），故手工物化路线本身无误，冲突在判据层。
5. 定点 grep 确认 `capability-skill` 在 tad.sh、publish-protocol、release-runbook、Canonical 清单、`.tad/tasks/` 中零引用——该校验器未接入任何现行活门，其 frontmatter 契约与全仓投影惯例（26/26 保留 keywords/type）已漂移。

即：AC7 要求 validate/verify 双 exit 0，AC9 要求 SKILL.md 与 CAPABILITY.md 的 diff 恰为删 status 一行；满足其一必违反其二。设计步的基线核查只验了负方向（投影缺失→非 0），未验正方向可达性。

可执行修正项（PM 合并裁定二选一，tech 路推荐路线 A）：

- **路线 A（推荐）**：修订 AC7——删除 capability-skill exit 0 要求，替换为可独立实跑的结构判据组：投影目录存在且 SKILL.md 在册；禁入四件（CAPABILITY.md/README.md/CHANGELOG.md/install.sh）零命中；投影树内符号链接 0；SKILL.md frontmatter 中 `name:` 值与目录名相等；正文无 `{{...}}`/`[TODO]`/`[TBD]` 占位符。同时把「capability-skill.sh frontmatter 契约与投影惯例漂移」登记为批外独立事项（批外发现只登记，合红线），不在本批改校验器。
- **路线 B**：修订 §4.5 与 AC9——SKILL.md frontmatter 收敛为 name＋description 两键（值逐字取自 CAPABILITY.md），AC9 改为「frontmatter diff = 删 status/keywords/type 行、正文区 0 diff」。采此路线前须先评估 keywords 缺失对该 skill 触发路由的影响（其 description 含触发短语、且 4b 指针行另有路由面），评估结论入增补。
- 两路线共同要求：修订后 AC7 与 AC9 须经一次 /tmp 模拟物化实跑证明可同时满足，实跑记录入增补。

### 3.2 P1 — §4.6 指针行文字 96 字符，与 AC10 上限 75 互斥（CF-4 纳入 4b 时生效）

实测：§4.6 表格第二列文字长度 96 字符（设计自称 71）；该串确为 registry description 的前缀（截至「with state」）。邻行同列实测：academic-research 70、agent-memory 69、rag-retrieval 70、synthetic-data 69——该表惯例为 66–72 字符硬截断。AC10 判据为 60–75 字符。Blake 照 §4.6 逐字落盘必 FAIL AC10。
修正项：合并裁定中钉死其一——(a) §4.6 第二列改按邻行惯例硬截断至 ≤75 字符的 registry description 前缀（推荐，AC10 不动）；或 (b) 修订 AC10 上限并注明本行例外。不得留待实施步现场决定。

### 3.3 P1 — §4.2 分类表未预置本链流程自产路径，Phase 0 必停步一次

§4.2 规则为「未点名新路径→停步报 PM，不得自行扩大解释」。以下路径在 Phase 0 时点必然已出现、且均未在甲/乙/丙/丁任一层点名：本 HANDOFF 本体（`.tad/active/handoffs/HANDOFF-2026-10-05-tad-closeout-batch.md`、未跟踪）、设计完工说明（`.tad/evidence/completions/2026-10-05-tad-closeout-batch-design-note.md`）、Gate 2 双路 verdict（`.tad/evidence/reviews/2026-10-05-gate2-*.md`）、PM 合并裁定件。实测佐证：设计步基线 porcelain 68 行，本评审实测已 70 行，增量恰为前两件。停步阀本身安全（停步→PM 分类是设计内路径），但属可预见摩擦，不应消耗在已知件上。
修正项：PM 合并裁定或 Alex 增补把上述本链流程件预先点名归丙层（随批提交集），或预授权 Blake 对「本链 task_id 名下流程件」就地分类并在 COMPLETION §2 留痕，二选一钉死。

### 3.4 P2（提示，不作条件）

1. 设计文本数字已漂移：§4.2/§2.2 称 handoffs 删除 11 件，porcelain 实测 12 件；设计步基线 68 行已变 70 行。AC2/AC16 均以 Phase 0 当值为判据，不伤判定；但设计文本中的计数值不得被实施步当逐件清单引用，增补宜注明「计数以 Phase 0 当值为准」。
2. AC13 的 awk 只验新节行号小于 Pattern Recognition 节行号，未验「新节行号大于 §7 节首行号」一分项；§4.8 的文字锚（§7 之后）可人工兜底，Gate 3 评审宜顺手目验插入点。
3. 件 5 断言实现注意：脚本开 `set -u`，pack 名收集变量须先初始化为空串，否则零 pack 或未收集时断言段会以 unbound variable 误红；§7.2 已许变量名微调，此点留实施自检。
4. 件 5 断言的传播面：scan-packs.sh 改后，publish step3c 的 regen 在任何「登记 pack 无投影」的仓（包括下游仓本地新增 pack 的情形）将新出现 exit 1。此为断言的设计语义（缺投影即红），非缺陷；但 CF-5 裁定与批后同步 GM 时宜一并知会，避免下游把新红误读为脚本回归。
5. gate skill inline Gate 3 的 Knowledge Assessment 行带「(BLOCKING - must answer explicitly)」注、Canonical 同项无此注——既存 inline gloss 差异，不在件 7 三改范围内，设计未触碰是对的；仅登记备查。
6. AC15 的「新版号出现面」枚举宜明示豁免证据类文件（HANDOFF/COMPLETION/verdict 必然引述 `3.0.1` 字面），以免 Gate 3 在出现面口径上争议。

## 4. AC1–AC16 逐条 tech 判定

| AC | 判定 | 依据 |
|---|---|---|
| AC1 | 可实跑 | 判据命令实跑得基线哈希，与设计完工说明所记参考值相等 |
| AC2 | 可实跑（附 §3.3 条件） | 以 Phase 0 当值为判据，自校正；分类覆盖缺口须先补 |
| AC3 | 可实跑 | 脚本 printf 块行序实测与断言前提相符 |
| AC4 | 可实跑 | 台账首部形态实测，行号断言前提成立 |
| AC5 | 可实跑 | runbook 两锚节逐字在位 |
| AC6 | 可实跑 | rubric-spawn 文法，六步验证与五判定要素均已枚举落到具体核查面 |
| AC7 | **不可达** | 与 AC9 互斥，见 §3.1（P0） |
| AC8 | 可实跑 | §4.5 的 12 件清单与 pack 本体逐项相符，集合等式判据成立 |
| AC9 | 命令可跑、与 AC7 联立不可达 | 同构规则经样本实测为真；联立问题见 §3.1 |
| AC10 | 判据可跑、§4.6 给定文本必不过 | 见 §3.2（P1） |
| AC11 | 可实跑 | 名＋status 对集合比较对派生噪声免疫，前提（件 4 先行）由 Phase 序保证 |
| AC12 | 可实跑 | fixture 三态已经本评审实跑复演（对照 exit 0／缺件点名／补齐转绿） |
| AC13 | 可实跑（附 §3.4-2 提示） | 锚点行号实测相符，awk 对现文件正确输出 ORDER_FAIL |
| AC14 | 可实跑 | Canonical 7 项与 inline 6 项均以 `- [ ]` 计数实测复核 |
| AC15 | 可实跑（附 §3.4-6 提示） | 五个版本面现状实测与改面封顶前提相符 |
| AC16 | 可实跑 | 以 Phase 0 冻结清单为比较基，判据自洽 |

## 5. 风险面（任务书点名项）

- **脚本改动回归面**：scan-downstream-versions.sh 改动为单行 printf 追加，无行为回归面。scan-packs.sh 改动为尾部断言段＋两行植入，不动 registry 生成逻辑；唯一新行为是缺投影时 exit 1，其传播面见 §3.4-4。capability-skill.sh 本批不改（路线 A 下亦不改），其契约漂移转批外登记。
- **提交步与同步竞态**：Phase 0 冻结清单以开工当值为比较基，Syncthing 在实施窗内新送达的冲突副本会以未点名新路径出现并触发 §4.2 停步阀——该方向是保护性的（宁停勿误提交），可接受；前提是 §3.3 先销账，否则停步会被本链自产件先行触发、掩盖真正的外部新增。

## 6. 评审边界声明

本评审全程仓内只读＋/tmp 隔离实验（fixture 与模拟投影均已清理）；git 仅只读命令；未写评审对象及其他任何仓内文件，本 verdict 为唯一落盘件。

---

## 自报行（Self-report）

- 本文件正文（本节之前）落盘实测: 13,456 字节 / sha256 `8603d496a4fc2c3e66f8be7e76e475d5692ae6a93e242331b27735e754823782`。
- 本节为自报行，不计入上值；校验法: 取本节之前的内容重算字节数与 sha256，应与上值相等（落盘后已按此法自验）。
