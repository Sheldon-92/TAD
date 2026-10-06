# Gate 2 Tech 评审 — TICKET-20261006-self-review-r3（HANDOFF 设计可实施性）

- 评审席：Alex（Solution Lead 评审面），独立会话，未参与设计，与 fit 评审互不可见
- 评审对象：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-06-self-review-r3.md`（82,771 B，Step 0 绝对路径断言实存、字节数与派发报告一致）
- 风险卡：`.tad/evidence/self-review-r3-20261006/risk-card.md`（4,918 B，ASM-1..3 已读）
- 判据：`.tad/gates/gate-canonical-checklist.md` Gate 2 节＋`.tad/tasks/gate-execution.md` Gate 2 节
- 日期：2026-10-06

## Verdict：CONDITIONAL

设计主体可实施：三组构造、四条承重链（check8 插入结构、列位契约、增量断言算术、实验盲法冻结）均经源码与盘面逐项核对成立；§9.1 基线 P-1..P-5 由本席独立复跑 5/5 逐字对齐。但 §9.1 有两行 AC 的验证命令按文档自述的抽取规则不可执行（F-T1，实测证伪），开工前须以一页设计增补改形并附 dry-run 证据；F-T2 一句聚合粒度增补同轮落字。两项均为 AC 文本/表述级修正，不动任何设计决策。增补落盘后本 verdict 自动转 PASS，不必重审全件。

## 激活自报

- 激活壳：`~/workspace/skills/tad-alex/SKILL.md` 全文已读，按其激活协议在目标仓 $REPO=/home/hatch/workspace/yun-sync/TAD 执行。
- 实际读的原件（逐件路径）：`$REPO/AGENTS.md`；`$REPO/.tad/project-knowledge/principles.md`；`$REPO/.tad/project-knowledge/patterns/_index.md`；patterns 全文 3 条＝`gate-design.md`、`ac-verification.md`、`shell-portability.md`（前两件超工具 100KB 上限读至中段，承重条目均在已读段，与 HANDOFF §1.4 的设计侧卸载登记同形态）；`$REPO/.tad/brain-index.md`（头部＋路由表）；`$REPO/.tad/tasks/gate-execution.md` Gate 2 节；`$REPO/.tad/gates/gate-canonical-checklist.md` Gate 1–3 节（Gate 2 为本步判据）。
- brain-index 路由命中：Patterns 表 Gate Design / AC Verification / Shell Portability 三行，与 _index 选读一致，无额外跨库路由需求。
- 评审读取面（任务书清单全数）：HANDOFF 全文（1,005 行）；风险卡全文；`.tad/hooks/lib/state-surface-check.sh` 全文（437 行）；`.tad/hooks/lib/runtime-freshness-verify.sh` 全文（208 行）；`.tad/runtime-compat/codex.md` 全文；补充件三原文（tech-radar 仓 `consult/tad-sweep/proposal-supplement-3-howto.md`，只读）；R2 基线件抽验（`g5-recall-baseline-result.md`、`g5-recall-run-trace.md` grep 锚＋两源文件实测）。
- 冲突：无任务书与仓内原件的冲突。HANDOFF §1.4/§2.3 已自登记一处任务书↔盘面冲突（R2 基线路径名），以实存件为准，本席复核同意。

## §9.1 基线行复跑对值（P-1..P-5 全跑，任务书要求至少其二）

| 行 | 本席复跑实测 | §9.1 登记值 | 对值 |
|---|---|---|---|
| P-1 | `state-surface-check.sh --repo .` exit 0；check1–7 全 PASS、无 check8 行；check7 INFO age 0d | 同左 | ✅ 逐字一致 |
| P-2 | `git show a1c3dffd^:AGENTS.md \| sed -n '9,16p' \| sha256sum` ＝ `8370d424a387d7608e019f9f0860d26ce2ca8090ab595a20e45d389b62b49f32` | 同左 | ✅ 逐字一致 |
| P-3 | `runtime-freshness-verify.sh . 2026-10-06` exit 1；`Total: 12 entries \| PASS: 10 \| WARN: 1 \| BLOCK: 1`；BLOCK 唯一属 codex context_compaction（stale 64d＋next_review overdue 两行输出、条目计 1）；WARN 唯一属 codex trace_evidence_capture | 同左 | ✅ 逐字一致 |
| P-4 | question sha256 `ba370858…2dc`、expected `761de258…090`，与 R2 结果件自带记录值再比对一致；incidents 计数 25 | 同左 | ✅ 逐字一致 |
| P-5 | `grep -c 'C-12 (no runtime freshness ledger' AGENTS.md` ＝ 1（L178）；两新台账 absent=0 | 同左 | ✅ 逐字一致 |

## 逐面评审结论

### 组 1 · check8 构造（可实施，1 处表述增补见 F-T2）

- **插入结构成立**：state-surface-check.sh 的 `pass()`/`fail()` 在 L65/66，`fail()` 自增全局 `fails`，文件尾汇总段以 `fails` 决定 exit 0/1。check8 块插在 check7 之后、汇总之前即自动继承退出码语义，§4.1.1 的规格与源码形态逐项相符；装载面（release-verify.sh L800 转调）零改的论断属实。
- **锚定抽取有仓内先例**：check6 已用状态式 awk（found 标志＋逐行处理），check5 用 blockquote 段抽取——§4.1.3 的状态式抽取不是新造形态。归一化的承重细节经实证：事故旧块中 `no lifecycle` 与 `hooks**` 分在相邻两行（P-2 块 L14–15 形态），不先归一化模式必漏检；设计已把此点写成实施要点且 neg 树专为此设。
- **豁免遮蔽操作安全**：豁免串含引号/分号，设计指定 awk `index()` 定位切除并明禁 glob 替换与 awk 串相等比较，与 patterns/shell-portability 的本仓实证条目一致。
- **PAIR-1 登记维护成本可接受**：配对登记为脚本内常量＋维护点注释，与 check4 OLD_PAT 的既有维护点同构；新增配对＝改脚本常量＋补 fixture 树，成本线性且全程在 tracked 评审面内。
- **豁免滥用防线与风险相称**：登记一条豁免必须改动发布门脚本本体（git tracked、走同一评审链），且只认归一化后逐字全等、失效豁免只报 INFO 不判绿——「把真事故登记豁免」的成本不低于直接改对文本，且在 diff 中全程可见。三层合取（辖区枚举×锚定抽取×逐字登记）后误伤面与事故面重合的论证成立。
- **五树判别力**：§4.1.4 骨架文件清单与 check0–7 的输入面逐 check 对照齐备（version.txt／NEXT／ROADMAP／DECL 五件／session-state 索引块／principles stub／brain-index Generated 行），check1–7 在每树全绿、退出码可唯一归因 check8 的设计成立；pos/neg/exempt/outside 四树分别判别 PASS、命中、遮蔽、块外不扫四种行为。缺口一处：五分支中「受治锚缺失」无固定树（见 F-T3）。

### 组 2 · 借 4 实验构造（可实施）

- **wing 规则可机械执行**：本席实测 `incidents/_index.md` 恰 25 条 `linked:` 字段，目标集恰为 {L1, ac-verification, gate-design, memory-and-learning, pack-build-rules, pack-evaluation, research-methodology, shell-portability}——与 §4.2.2 枚举行逐一对上，wing 数 8（7 patterns＋principles-linked）的预期有盘面依据，非估计。
- **同口径锚稳固**：R2 结果件原文确认 incidents Recall@3＝4/8（总 26/40、分组在册）、无答案误报 3/5 与 §2.2/§4.2.4 的基线引用一致；题面抽取锚在 R2 题集实测可数（Q33–Q45 行式见 F-T1 的对值探针：正确模式形得 13/13）。
- **槽位竞争保真成立**：§4.2.3 保持三面同序、仅替换第 ③ 面，并明言只看试验面会使 top-3 被 drawer 填满、召回虚高——这是与基线可比性的承重设计，判断正确且不可省。
- **双盲与污染判读机械可判**：builder/runner 独立 spawn＋禁读清单＋读物自签、三件哈希冻结（子集两件＋routing.md）、权威面前后 28 行清单（25 语料＋3 索引面，算术对上 AC-G2-2）——污染的判据是哈希比对与自签矛盾这类机械事实，不靠判读者印象；INVALID 的触发、后果（不得支持立项、批内不许改判据重跑）在 §4.2.4 预登记完备，防事后改判据成立。判据数值（Recall@3 ≥6/8 且误报 ≤3）与补充件三示例值（较基线 +2 题且误报不升）一致，且在本 HANDOFF 落字、双审通过即冻结——「判据先落字后跑数」的改法要求已兑现。

### 组 3 · 校验器扩围与台账（可实施）

- **列位契约逐位对齐源码**：`check_ledger()`（L68 起）以 awk -F'|' 解析 $2=surface、$7=last_verified、$8=volatility、$9=next_review、$12=status，与 MQ3 对照表的 11 列＋行首空位推导逐位一致；表头锚 `^\|[[:space:]]*surface[[:space:]]*\|.*owner` 与 §4.3.1 的要求一致；codex.md 实样（Ledger Version 2、12 行）形态与新台账同构规格相符。
- **显式清单改法与现行结构兼容**：现行枚举就是脚本内显式清单（L10–12 定义＋L27–31 codex 必备守卫＋L42–48 claude retired 跳过＋L187–190 调用区），§4.3.4 的三处改动（2 行定义／2 段守卫／2 行调用）逐处有同形先例；守卫文案 `ERROR: missing ledger <path>`＋`GATE: runtime-freshness exit=2` 与 AC-G3-4 的期望字面（stderr 含 `missing ledger` 且点名 cursor 路径）一致。glob 替代案的否决理由（缺文件静默、草稿自动升门、与 fail-closed 契约相悖）成立，封闭有界集用显式清单是正确方向。
- **安全面交互已核**：SAFETY_SURFACES（L16）含 hooks／ask_user_question_hook／sandbox_approval_permissions／trace_evidence_capture／context_compaction 五个新台账会用到的面；§4.3.2 两行集中这些面的 status 均非 `unknown_current_behavior`（verified／verified_partial／accepted_limitation），故 unknown＋安全面 BLOCK 分支不触发——「不新增 BLOCK」的设计核查属实。
- **双分支增量断言无歧义**：以本席复跑的基线（Total 12｜PASS 10｜WARN 1｜BLOCK 1）为减数，新 19 行（OC 10＋CU 9，行集算术对上）在 TODAY=2026-10-06 下 age=0、next_review 全在未来 → 全 PASS，终值 Total 31｜PASS 29｜WARN 1｜BLOCK 1 可机械复算；BLOCK/WARN 集恒等于预登记残差 {codex context_compaction}／{codex trace_evidence_capture}——正是 patterns/ac-verification「Exit-0 ACs … Use Two-Branch Delta Assertions」的标准形，无第二读法。控制树两跑（缺 cursor／坏日期）的 exit 2 路径经源码核对成立（守卫先于解析、日期格式校验在 L114 附近的分支必响）。时限注记（滑过 2026-11-05 则新行转 BLOCK）已在 §8.4 预登记为停步项，不留凑绿空间。

## Findings

### F-T1（P0 · 支起 CONDITIONAL 条件一）§9.1 两行 AC 的 grep 模式在文档自述抽取规则下不可执行（实测证伪）

§9.1 表首注定「表内 `\|` 为 markdown 转义，抽出执行时还原为 `|`」。此统一规则无法同时满足三行：

| 行 | 字面读法（不还原）实测 | 还原读法实测 | 期望 |
|---|---|---|---|
| AC-G2-1 第一 cmp（题面侧 `^- Q(3[3-9]\|4[0-5])：`，对 R2 题集） | 0 行 | **13 行 ✅** | 13 |
| AC-G2-1 第二 cmp（期望侧 `^\| Q(3[3-9]\|4[0-5]) `，对 R2 期望集） | 0 行 | 52 行（全文件——行首 `\|` 还原成裸 `|` 后，`^|` 成为 alternation，每行命中） | 13 |
| AC-G2-5 计数（同期望侧模式，对期望集代跑） | 0 | 52（全行计数） | 13 |

根因：行首位置需要**字面**管道符、组内位置需要 **alternation** 管道符，两种语义共用一个转义记号时不存在统一还原规则。混合正确形本席已实测存在：`^\| Q(3[3-9]|4[0-5]) ` 在期望集得 13、`^[|] Q(3[3-9]|4[0-5]) ` 亦得 13、AC-G3-2 的还原形在 codex.md 得 12（该行本身无恙）。此为 patterns/ac-verification「Published Commands Must Be Tested as Literal Text」「AC Verification Drift」的标准缺陷形：按字面执行的 Blake 必然在 AC-G2-1 第二 cmp 与 AC-G2-5 上假红（实现正确也过不了），或被迫自行改命令（破坏 AC 契约）。
**条件**：设计增补把 AC-G2-1 第二 cmp 与 AC-G2-5 的模式改成对两种读法免疫的括号类形（`^[|] …`），并附对 R2 两源文件的 dry-run 证据（各得 13）；AC-G3-3 的 Expected 列内 `grep -E '^(BLOCK\|WARN)'` 提示同源，建议同轮规范化（该处为散文提示、非主命令，不单独支起条件）。

### F-T2（P1 · 支起 CONDITIONAL 条件二）check8 的 FAIL 聚合粒度未在设计正文写死

§4.1.3 判读表只写「豁免遮蔽后任一旧文模式命中 → FAIL check8（点名命中的模式字面与 PAIR-1）」，未明言多模式同中时聚合为**一条** FAIL。AC-G1-2 要求 neg 树「FAIL 行恰 1 条」——AC 本身无歧义、实现者照 AC 可达，但设计正文留了一步默会（逐模式 fail() 的实现同样「符合」§4.1.3 字面却必红 AC-G1-2）。
**条件**：增补一句话入 §4.1.3——「check8 每对至多调用一次 fail()，多模式命中时文案并列全部命中模式」。

### F-T3（P2 · 建议，不支起条件）「受治锚缺失」分支的全链实证只挂「可选」

§4.1.3 五分支中该分支的覆盖安排是 §8.3 的「代码评审＋Gate 3 可选加跑一棵临时树」——可选即可能全链无实证，而该分支守护的正是「受治面被删/改名」这一最可能的登记腐坏形态。建议在增补中把临时树跑法升为 Phase 2 必跑一次并将输出记入 COMPLETION（成本：一棵 cp 树＋一次命令）。

### F-T4（P2 · 观察，无需动作）组 1 第 3 层豁免的自指性

豁免登记存放在被检脚本本体之内，属自指构造；本席判其可接受的依据是登记动作本身受 git＋评审链约束、且与 check4 OLD_PAT 维护点先例同构。此点供 PM 裁定参考：若 PM 认为发布门脚本的自指豁免开口过大，§4.1.2 已预置可拆方案（否决第 3 层、保留 1＋2 层），设计不绑死，无需返工。

## 条件汇总（开工前清零）

1. F-T1：AC-G2-1 第二 cmp 与 AC-G2-5 模式改形（`^[|]` 括号类）＋对 R2 两源文件的 dry-run 证据（各 13）落增补件；AC-G3-3 提示行同轮规范化。
2. F-T2：§4.1.3 增补 FAIL 聚合一句。

两项落字并回填 HANDOFF §9.2 Audit Trail 后，本评审转 PASS。F-T3 为建议项，采否由 PM／设计方定，不阻塞。
