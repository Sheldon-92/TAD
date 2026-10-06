# Gate 4 终判 — Epic Phase 3「运行时适配补全」（TASK-20261006-EPIC-P3-RUNTIME）

- **评审者**：Alex（Solution Lead），独立会话；未参与本链设计定稿后的实施与 Gate 3 双审。
- **判据正本**：`.tad/gates/gate-canonical-checklist.md` Gate 4 节（复算口径：自报不是证据，逐项以盘面重算为准）；HANDOFF §9.1（AC1–AC33）。
- **对象锚（本席复算）**：HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-epic-p3-runtime.md` sha256 `2c77e39f…35b64` ✔；COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-epic-p3-runtime.md` 23,506 B／sha256 `ed881639…` ✔（含承接 A 追记与 Gate 3 订正追记的终态）；Gate 3 CODE＝CONDITIONAL（P1×2，订正追记在盘）、SAFETY＝PASS；PM 裁断三份在盘（design-rulings D-1–D-5、three-escalations-ruling 三节、p2-first-run-ruling 含销账行）。
- **Human visual check**：CHECK 待人（本席不自报视觉 PASS；注册表三家 hooks 面与 transcript 已备人眼抽查）。

## 总判：**CONDITIONAL**

实施实质全项成立、无任何 AC 判 FAIL、无实施返工项；但两件在册事项未终局，构成本判的两个条件（见文末）：① 件 3.3 Codex PASS 基线未取得（厂商配额，PM 已裁挂账不阻门，本席同意，补跑义务未落地）；② 承接 B (ii) 工时维按写死判据**数据不足、无法诚实终判**（AC21「Gate 4 前必须终值在盘」未满足，且非执行方之过——判据本身未指定分子口径、分母从未仪器化）。两条件均为收口/后续动作，不需本链返工。

---

## 一、Gate 4 Canonical 四项复核

| 项 | 结论 | 复算依据 |
|---|---|---|
| Functional acceptance（§9 AC met＋无未决阻塞） | CONDITIONAL | AC1–AC33 经 Gate 3 双审独立复核无一行 FAIL，本席抽重承重行复算全等（见第二节）；未终局者仅 AC16 的 Codex 分项（部分成立、归属在案）与 AC21 的 (ii) 终值（数据不足） |
| Quality evidence complete | ✔ | Code review＝gate3-code.md 在盘；Security review＝gate3-safety.md 在盘（越界/fail-open/inert/负证据六面）；Performance review＝N/A（本链无性能敏感面：hooks 均为 fail-open 副作用脚本，唯一计时实数＝试点稳态周期 8 s 已在盘）；UX review＝N/A（无 UI） |
| Subagent issues resolved | ✔（附 delta 2） | Gate 3 CODE 两 P1 已由 COMPLETION 订正追记执行（编号映射 §1、trace 记述勘正 §2、插件字节注记 §3、gate3_verdict 回填 §4），PM 已核销；SAFETY P1＝0。两路 P2 共 8 条均为记录形态改进项，去向见第四节 |
| Knowledge Assessment complete | ✔（附注） | COMPLETION KA 节三条新发现均已落证据面（opencode 无头 stdin 阻塞→Phase 0 记录；原生 spawn 裸跑对照不可得→scores.md 附注；安装器「装上≠置入」两条腿→试点记录分诊 2）；正式蒸馏入 patterns/ops-knowledge 属 PM 收口后续（发现 1 的 ops-knowledge 落点在 Blake 写集外，已点名），不阻本门 |

## 二、逐件终判（编号＝HANDOFF §9.1；COMPLETION §3 编号映射以其订正追记 §1 为准）

| 件 | 终判 | 终判依据（盘面复算/双审互证） |
|---|---|---|
| 3.1 OpenCode hooks（AC1–AC7） | **PASS** | 插件在盘（5,708 B／sha16 `7c165c01…`，CODE 路复算与自报全等）；投影三路、漂移红控、rollback、fail-open 负控均经 CODE 路自跑/对盘复核。AC3 括注（trace 归 startup-health）与 AC8「四条目」两处字面出入，CODE 路已判「设计字面错、实施对」的可接受形态差——本席复核源码口径（startup-health 不写 trace、trace 由 post-write-sync 产生）后**同意该判读**；HANDOFF 勘误注记列收口事项（第四节） |
| 3.2 Cursor hooks（AC8–AC13） | **PASS** | hooks.json 三条目实落与 §4.2 形态正本一致（第四条目按 R-CU-1 设计缺席）；两垫片三态＋故障注入经 CODE 路 /tmp 整树副本自跑复现（转码对位、垃圾/空/exit 1 恒 `{}`＋exit 0）；OC-2 分支 A 以正向触发证据成立，非日志空白推断 |
| 3.3 三家真机基线（AC14–AC16） | **部分成立** | OpenCode PASS、Cursor PASS 两份基线成件且逐点位触发归属在盘（CODE 路逐项对位 raw 日志）；Codex FAIL——归因厂商账号配额（一手报文在 `live-regression/raw/p2-codex-session.log`：用量上限、retry after 2026-10-10 10:24 AM、失败点在首次模型调用前），非机制失败。AC16 以「三份成件＋归属在案」计部分成立，Codex PASS 基线为在册欠账（条件 1） |
| 3.4 C5 适配器声明清单（AC23–AC25） | **PASS** | 清单六维齐＋义务句 grep 命中＋_index 恰 +1 行；三实例逐维有值、版本＝OC-6 复测值、残项格带编号；AGENTS.md diff 仅 Known Gaps 两行（SAFETY 路 git diff 复算），关闭项有落形态指针、残项逐项点名 |
| 3.5 F1 权限声明（AC26–AC27） | **PASS** | 核查表五行逐行带证据指针（判断正本行号本席抽核在位）；两样例 inert 经机器面复算（tad.sh 及 hooks 对 `runtime-permission-examples` 引用 0 命中；仓内无启用件，D-4 主案未被僭越）；样例字段集 ⊆ 文档确证集 |
| 承接 A 件 2.1 基线跑（AC17–AC19） | **PASS，销账成立** | 本席独立复算：运行目录 scores.md（4,449 B／sha256 `fef5487b…`）机械值块逐案 verdict PASS×3＋整轮 verdict PASS；样本集三件 control.md 现盘 sha256 ＝`ec5d4bdf…`／`227e1182…`／`f49c13c6…`，与裁断授权后的替换记录逐值全等；首跑裁断件现 9 行、sha256 `0ca68988…`，尾行（第 9 行）即销账行，含运行目录指针＋整轮 PASS＋命中数（判别 5/7/6、must_not 全 0、对照 0/1/0），其余行未动。程序正当性经 SAFETY 路核过（停步→PM 裁断授权→替换→同 runner 复评→回填，无先行后奏；放宽通过线未发生，判分锚零改）。**件 2.1 首个有效基线跑自此真成立，Phase 2 遗留前置销清。** 注记：首轮 INVALID 的 scores 原件被复评覆写、数值仅以散文保全（SAFETY P2-4），证据链完整但强度低一档，不影响销账成立 |
| 承接 B 件 2.6 试点（AC20–AC22） | **试点成立（三维实证）；(ii) 维数据不足未判** | AC20 PASS：16 路径比对面 apply→复合 rollback→after 与 before 逐行全等（两清单 sha 同为 `1888e01d…`，CODE 路 grokbox 亲跑 diff 0 行）。(i) 不翻负（试验完成、真排除，附带刻画两条为增量产出）；(iii) 不翻负（重叠约六至七成与评估预估对位，增量价值＝回退后状态等值断言，本维翻负须 PM 点名——记录在盘待 PM 收口一并判读，本席意见：无点名理由）；(iv) 不翻负（差异 0、过程异常 3 条全分诊）。(ii) 见第三节专判。AC22 结论行与四维状态逻辑对位（含翻负自动改判规则），其「(ii) 待确认」限定如实 |
| 承接 C check4 审视（AC28–AC29） | **PASS** | state-surface-check.sh diff 仅 +5 注释行（设计字面三行、实落五行覆盖三要点，CODE 路判形态差，本席同意）；check4 正负控经 CODE 路 /tmp fixture 自跑复现（裸 `Version 3.1`→FAIL／全号 `3.1.0`→PASS），与 P2 裁定「维持字面量＋换版注记」口径一致。§10 收口时 OLD_PAT 改值（3.1→3.2）为首次执行点，归 PM 收口 |
| 承接 D 发版 tag 步（AC30–AC31） | **PASS** | step4「Push only」grep 0 命中、两选项＋来历注记在盘；step5 tag 断言三要素（本地在位／远端在位／指向发版提交）＋RED 处置句在盘；publish-ops §6 镜像指针在盘。其首次实地适用在本 Epic 统一发版收口步 |
| 全批封口（AC32–AC33） | **PASS** | 本席复算：`.tad/version.txt` 内容 `3.1.0`、sha256 `b2f44d3b…` 与 Phase 0 基线锚逐字全等；git HEAD 仍为 `7e407b7c`（本链零提交）；git status 82 行（M 15／D 12／?? 55）的构成与 SAFETY 路逐项归因一致，无写集外变更。**版本冻结合规**：本链零升版、零 git 写，与用户 sequencing 口径（Epic 全完后统一发布）一致 |

## 三、承接 B (ii) 工时维专判：数据不足

写死判据（§4.5）：成本比＝试点墙钟 ÷ Gate 3 双审总工时，>20% 翻负；分子分母须双实数。本席以本链可观测记录复算，结论是**两端都无法诚实单值化**：

- **分子（试点墙钟）有两实数且无指定口径**：脚本化稳态周期 8 s（起止时戳 2026-10-06T12:28:31Z→12:28:39Z 在盘）与首次含两轮诊断迭代＋面校正的总投入约 25 分钟（pilot.log 先行轮次留痕）。两值相差约 187 倍，§4.5 只写「试点执行墙钟实测记录」，未指定取何者——试点记录本身明示「两口径均已在盘，不预判」，处置正确。
- **分母（双审总工时）从未仪器化**：两份 Gate 3 verdict 均无派发/起止时点。可观测界仅有：被审对象终态（scores.md 复评）落盘 12:37:45Z、评审目录生成约 12:41Z、SAFETY 件 12:42:12Z、CODE 件 12:47:38Z。故双审总工时只能界定在「两路并行、合计不超过约 20 分钟」的上限内，无实测值。
- **两口径结论相反**：以稳态 8 s 为分子，对任何与可观测记录相容的分母（两路独立实质评审，合计 <40 s 不构成可信读法）比值均 <20%，**不翻负**；以首次约 25 分钟为分子，对可观测上限内的任何分母比值均 >20%，**翻负**。判据未指定口径 ⇒ 任取其一都是替设计补口径，本席不为之。**(ii) 终判：数据不足，不判翻负、亦不判通过。**

连带终定：(i)(iii)(iv) 三自动/点名维均不翻负，自动降级条款（任一自动维翻负→『采』降『缓』）**未触发**，试点结论行「维持『采』」维持有效；但本试点不构成四维完整验证，§4.5「收口前回填终值」的未竟部分如实记入条件 2。

**Alex 建议（供 PM 裁）**：
1. **转常设：建议裁准，附一次复核**。理由：(ii) 维要测的是该环的**经常性成本**；25 分钟由试点自身的两轮校正构成（骨架基线探针残留污染、安装器合并面 resolve=local 刻画）——均为一次性建设/认知成本，且已分别沉淀为 ASM-2 实证与试点记录分诊 2 的知识，不随常设运行重复发生。常设形态的单次成本即脚本化稳态周期（8 s 量级），对 Gate 3 工时的占比在任何可信读法下远低于 20%。以判据的仪器化缺陷（分子未指定＋分母未留时点）否决一个三维实证成立、经常成本可忽略的机制，是拿测量之误罚机制本身。
2. 裁准时请 PM 一并把口径写死入后续判据：分子＝脚本化稳态周期（首次校正投入单列记录、不入比值）；分母＝Gate 评审派发与 verdict 落盘时点差（派发记录须留时点）。下一次适用链按新口径实测回填一次 (ii) 终值作复核；若复核 >20%，常设资格自动回炉报 PM。
3. 若 PM 不欲在本链裁口径，则备案为：试点维持「成立（三维）」、『采』不转常设，待下一次适用链补测 (ii) 后再判——本席不推荐此案，理由同 1。

## 四、残项清单与去向（逐项判读）

| 残项 | 本席判读 | 去向/归属 |
|---|---|---|
| Codex step3f PASS 基线欠账 | **同意 PM 裁断（挂账不阻门）**：归因有一手厂商报文、失败在任何工具使用之前、非机制失败；且 AGENTS.md Known Gaps P4 行已把「step3f 自 v3.2.0 起三家 HARD」与「Codex 基线 outstanding」写在同一行内，HARD 表述未掩盖欠账 | 条件 1：2026-10-10 配额恢复后 PM 派补跑，回填 codex transcript＋字段表＋step3f 登记；若统一发版收口的 step3f 实跑先于补跑落地，发版记录须如实再记 Codex 欠账，不得报三家全 PASS |
| R-OC-1（OpenCode 启动注入无对等面） | **接受为残项**（与 PM D-2 裁断一致）：已三面登记（AGENTS.md Known Gaps P2 行、3.4 清单残项总册、OpenCode 实例），归属明确；实施未以 chat.message 硬凑假对等面，处置正确。副作用对等＋compacting 部分对等为诚实边界 | 长期残项，归适配面；OpenCode 出现 SessionStart 注入面或新运行时接入（按 3.4 清单立实例）时复核 |
| R-OC-2／R-CU-1（两家提问捕获无面） | 接受：均以正向实测（工具名册探针／文档确证）成立、非日志空白推断，已登记总册与实例 | 同 R-OC-1 口径，随运行时能力面变化复核 |
| R-CU-2（Cursor CLI 不触发 hooks） | **未成立、关闭**：OC-2 分支 A 以实触发证据成立；成立条件已记总册与 Cursor 实例，备未来复核 | 无后续动作 |
| CF-7 素材（infra 环境清单版本陈旧：Cursor 二进制自更新致在册版本与 OC-6 实测不符） | 素材已在 COMPLETION §5-⑤ 落盘，路由正确（清单属 infra 席管辖，不在本链写集，本链未径改成立）。注：此 CF-7 为本 HANDOFF 的冲突预检编号（infra 清单面），与 Epic 层旧 CF-7（hop 历史缺口）非同一件，勿混 | PM 收口时转 infra 席更新环境清单；本门不阻 |
| Gate 3 两路 P2 记录项（插件 7 B 差成因未考／原始日志仅存 grokbox／首轮 scores 被覆写／ASM-3 §0.1 字面窄于执行面／Phase 0 status 快照只存 /tmp 已失） | 均属记录形态，均已在 COMPLETION 追记或评审件内如实留痕，无一掩盖实质结论；「成因未考」按未知记未知，本席接受 | PM 收口注记：① grokbox `p3-probe-logs/` 原始日志随收口补同步抄入仓；② 后续链 status 快照直接落证据记录件内文；③ HANDOFF AC3 括注勘误注记随收口回写 |
| session-state 索引行未更新 | Blake 未动属守纪（不在 §7 写集）；PM three-escalations §三已认领 | PM 收口补记 |

## 五、gate4_delta（复算与自报/条件字面的出入，如实记）

1. **AC21 终值缺位**：COMPLETION §3 其 AC21 自报「PASS (self，(ii) 中间态)」已明示限定，非自报不实；但 §9.1 AC21 写死「Gate 4 前必须终值在盘」，终值不在盘且按现判据不可诚实计算（第三节）——本行终判以「数据不足」记，不随自报 PASS。
2. **Gate 3 CODE 条件 1 的落点偏差**：条件字面要求 P1-2(b)（骨架 handoff_created trace 载体已佚的声明）落 Phase 1 验证件尾；本席复查该文件尾无此追记（其 §4 第 33–34 行旧记述仍在），声明实际落在 COMPLETION 订正追记 §2(b)，内容齐备（载体已佚＋结论改以存活证据为据）且 PM 已核销。判：实质满足、落点与条件字面不符，记 delta 不判 FAIL；建议 PM 收口时在 Phase 1 验证件尾补一行指针指向 COMPLETION 追记 §2(b)，把字面条件闭环。
3. 其余承重自报（COMPLETION §4 字节/sha 全表、试点清单全等、control 替换 sha、销账行、版本锚）经 Gate 3 双审与本席抽算**逐值全等**，无自报与盘上不符行，证据否决条款不触发。

## 六、转 PASS 的条件（均非实施返工）

1. **Codex 基线补跑落地**：2026-10-10 配额恢复后补跑取得 Codex step3f 结论并回填 transcript／字段表／step3f 登记（PASS 则本条件销；仍 FAIL 则按归因续挂并报 PM）。
2. **(ii) 维终判**：PM 按第三节建议裁定分子口径（或另行指定），(ii) 终值与试点结论终定随裁断落盘；裁定前试点结论以本判第三节的终定口径为准（成立三维＋(ii) 未判＋『采』维持不降级）。

两条件销账后，本链 Gate 4 自动升 PASS，无须重审其余各行。链收口（迁档、session-state 索引、Epic Phase Map 回写、统一发版）归 PM 收口步，按用户 sequencing 口径在本 Epic 全完后统一发布，本门不预判发版形态。

- 本评审文件字节/sha：以落盘后外部复算为准，数值随交付回执给出（自报口径：本席落盘后实测）。
