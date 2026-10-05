# Discuss：Anthropic claude-api eval/hillclimb 方法 vs TAD + thin-PM 门 2/3/4

**Date:** 2026-09-29  
**Mode:** Alex `*discuss`（研究对照，不出 handoff、不实现）  
**Channel+model:** cursor-run / grok-4.7-medium  
**Status:** discuss only  
**Locks:** NO Gate 2 · NO product / docs / templates / SKILL edits · NO git push  
**Verdict:** PASS

**对照对象：** 开源 `claude-api` skill 里的评测建造与爬坡**方法**（Apache-2.0 指南 + 报告/runner 脚手架）。Claude Code 的 `/claude-api` 触发器、toolchain、捆绑安装路径不在吸收范围内。

**Pack pointer（未加载）：** `ai-evaluation` — 评测设计、回归、判别性门、负对照。Path: `.agents/skills/ai-evaluation/SKILL.md`。Do not load unless escalated.

**源（本席已读；引文只来自这些段落）：**

| 角色 | 路径 | 用到的锚 |
|------|------|----------|
| 雷达 SSOT | `/home/box/云同步/tech-radar/claude-eval-hillclimb/README.md` | 「一句话」「开源定位」「关键事实」「适合 / 不适合」「风险/存疑」「运用建议」 |
| 雷达深度 | 同目录 `2026-09-29-depth-brief.md` | 「核心判断」§1–§5、「对技术雷达的关联建议」 |
| 雷达指针 | 同目录 `2026-09-29-oss-artifacts.md` | 「定位结论」「已核对可拉取的文件」「缺口」 |
| PM 操作 | `/home/box/云同步/grok-cloud/docs/pm/human-operating.md` | §3.4、§3.12、§3.13 |
| PM 岗位 | `/home/box/云同步/grok-cloud/docs/pm-charter.md` | §1 Conductor、§1.5、§2 节点验收、§3.1 原则第 2/4/5 点 |
| TAD 运维 | `/home/box/云同步/TAD/docs/pm/ops-knowledge.md` | 「盘⇄私有脑 · 一次双写（2026-09-21）」 |
| TAD 原则/模式（任务命中后加读） | `.tad/project-knowledge/principles.md`「YOLO Epic Execution… Validation Theater」；`.tad/project-knowledge/patterns/gate-design.md`「Gate 4 Verification Integrity」「honest_partial_protocol」「Non-Dev Execution Track…」；`patterns/pack-evaluation.md`「Behavioral-Eval Gate Must Run on SEPARATE Discriminative Field」 | 见各节 |
| 讨论体例 | `.tad/evidence/discuss/2026-09-22-epic-phase-vs-human-habit.md` | 头部锁、只记录不交接 |

**源缺口（不降为 PARTIAL）：** 任务点名的 `2026-09-29-oss-pointers.md` 在该目录不存在（目录内为 `README.md`、`2026-09-29-depth-brief.md`、`2026-09-29-oss-artifacts.md`、`2026-09-29-first-entry.md`）。指针表以 `2026-09-29-oss-artifacts.md` 为准。上游 `shared/evals/*.md` 正文本席未打开；Step 4.5 停滞分类等句不引自未读文件。方法要点只采用雷达已蒸馏的句子。

---

## 一句话判断

他们把「评测要能检出你要的变化、人签收输入与 grader、爬坡看 held-out 的 test delta、涨分落在噪声里就不合、改 harness 须人批」写成可安装工作流；我们已有同向的拒假绿、独立审、KA、双写、human-look 与「结构检查 ≠ 行为变好」，但这些刀写在**门与证据**上，没有写成「一轮一改、先量噪声地板、headline 只报未参与训练的对照面」的爬坡清单。可吸收的是这几条原则进 PM 文案或一条 L2 模式；不吸收 Claude Code 命令、不在本仓跑 hillclimb。

---

## 已对齐（我们已有）

1. **防自我欺骗是默认纪律，不是附加博客。**  
   雷达 `2026-09-29-depth-brief.md` §4 结论：战略差异点是「防自我欺骗」写进默认工作流（audit、噪声地板、test 作 headline、禁止把失败贴进可泄漏面）。  
   我们侧同向：`human-operating.md` §3.12 第 4 点「拒假绿：文件在、闸勾了但结果发不出 / 对不上你要的效果 → 不得报 PASS」；同段「『流程跑完』≠ 过门」。`pm-charter.md` §3.1 第 5 点复述同一句，并写「禁止『仅本地静态 PASS』冒充可交付」。TAD L1 `principles.md`「YOLO Epic Execution」把 Validation Theater 定义为：结构检查证明文件在，不证明行为变好。

2. **人签收「测什么 / 怎样判对」，agent 不自己把题和尺子定死。**  
   雷达 `README.md`「关键事实」：输入与 grading 签收。`2026-09-29-depth-brief.md` §3：AskUserQuestion、输入/grading/plan 签收；「仍以人的 eval 定义为绳」。  
   我们侧：`pm-charter.md` §1 Conductor「管结果合同」；§3.1 第 5 点门 4「对照门1（已批准结果合同 / 本 phase 效果）写是/否 + 一句」。`human-operating.md` §3.12 第 1–2 点：经理对照人已确认的要求先过，不行打回，不把「好不好」甩给人。门 4 拍板权在 PM 或人（同节第 4 点）。

3. **独立的第二双眼睛，本人勾选不算过。**  
   雷达 `README.md`「风险/存疑」第 4 点：LLM-as-judge 仍可能漂移，指南要求抽查。深度简报 §5：裁判漂移 / reward hacking，执行靠人。  
   我们侧：`human-operating.md` §3.13 第 1、6 点：过程 Gate 2 = ≥2 独立专家审、证据落盘、P0 清零；PM 只查盘不代跑。`pm-charter.md` §3.1 第 2、4 点：Alex 自己填 PASS 不算；Gate 3 无证据不报 PASS、不送 Gate 4。`gate-design.md`「Non-Dev Execution Track」：judge ≠ producer，fresh judge，门必须能 FAIL 才不算剧场。

4. **用原始证据重算，不信摘要标题。**  
   雷达深度简报 §5「厂家数字外推」：博客内部基准不等于你的流量。`README.md`「关键事实」把客服 1/5、66%→88% 标成厂家自报、非本仓复测。  
   我们侧：`gate-design.md`「Gate 4 Verification Integrity」：从原始证据重算关键数字，跑 Blake 跑过的同一命令，查 `git status`，不读摘要就验收。`pack-evaluation.md`「Blind-Judge…」：汇总前把裁判每一行对回输入文件。

5. **改「测量装置」本身要人批，不能为了过线悄悄加只对题集有用的工具。**  
   雷达 `README.md`「关键事实」：禁止未审批的 `--approve-harness`。深度简报 §5：harness 为过 eval 加只对题集有用的工具，指南警告、执行靠人。  
   我们侧相近的是收口闸，不是同名开关：`human-operating.md` §3.12 第 5 点，正式交付发「请看这 / 观感」必须 `pm-human-look-check.sh` 退出 0（门 3 盘证 + 门 4 是/否一句 + 双写两勾或「本刀无项目记忆」+ KA）；手打 1:1 不算合规。`pm-charter.md` §3.1：PM 不准另开一场去代跑 Gate 2 / Layer 2。

6. **知识与记忆要落盘勾选，不能只写在会话里。**  
   `human-operating.md` §3.12：制度/机制刀的门 3/门 4 证据卡须含 Knowledge Assessment 勾选或显式「无新发现」；要留的项目记忆须盘⇄私有脑双写两勾，只写脑不写盘不算资产。`docs/pm/ops-knowledge.md`「盘⇄私有脑 · 一次双写」：收口/门 4 结论先落盘，再改私有脑；冲突以盘为准。  
   这与他们的 hillclimb/v2 schema、lite 报告（`README.md` 报告脚手架行；`oss-artifacts.md` SCHEMA / `build-report-lite.mjs`）同属「状态要有载体」。载体不同：他们是 eval 报告 schema，我们是门证据卡 + 双写。

7. **诚实的非 PASS 是合法出口。**  
   `gate-design.md`「honest_partial_protocol」：环境死锁用 PARTIAL，禁止静默 PASS。`human-operating.md` §3.12：独立审 FAIL / PARTIAL → PM 继续咬到 P1 关掉或诚实 BLOCKED；禁止降范围换绿票。开跑周知 / 红灯 / 诚实 BLOCKED 不走 human-look 闸（同节第 5 点）。

---

## 缺口/启发（他们强、我们弱或未写成刀）

下列都是雷达已写明、我们门文案里没有同句的方法。缺的是**刀的句子**，不是「我们完全没防假绿」。

1. **噪声地板先于「这分值得合」。**  
   `README.md`「关键事实」：hillclimb 前证明噪声地板 ≤ 愿行动的最小提升。深度简报「关联建议」第 3 点把「噪声地板 + held-out + 不贴失败进 prompt」列为可交指针。  
   TAD 有「先测量再优化」（`principles.md` Measure Before Optimizing）和判别性负对照（`pack-evaluation.md`：无 pack 的 CONTROL 必须 FAIL）。这是「门能不能分开两类输出」，不是「同一套题重跑的分数抖动有多大、小于抖动的涨分不许当改进」。PM 门 4 的「是/否 + 一句」没有这条数量门槛。

2. **headline 只看没参与本轮修改的 test / held-out。**  
   `README.md` 爬坡指南行：train/val/test；最终看 test delta。同页关键事实：train 涨、test 不动视为过拟合并且回滚。深度简报 §2：爬坡必须 held-out。  
   我们的门 2/3/4 查的是设计双审、实现自检、独立审、结果合同是否对得上。没有「本轮用来改 prompt/skill 的失败样本」和「收口时唯一允许当标题的对照面」的分栏。Validation Theater 禁的是结构绿冒充行为绿，还没禁「在见过的题上变绿」。

3. **一轮只改一处，再读 delta。**  
   `README.md` 爬坡指南行写明「一轮一改」。  
   我们有 phase 串行（`pm-charter.md` §1 前「多阶段默认 phase 串行」；§2 派活「默认按 phase 串行」）和「Gate FAIL 先根因再返工、禁按 finding 打补丁」（`pm-charter.md` §3.1）。那是阶段与返工纪律。一次 Blake 提交里仍可以同时改 prompt、工具描述和 grader，门 4 没有「本轮只允许一个变量」的句子。

4. **audit：task / harness / metrics / grader / 能否检出你要的变化。**  
   `README.md` 健康清单行与关键事实：audit 进入建造与爬坡，五块是 task、harness、metrics、grader、「能否检出你要的变化」。`oss-artifacts.md` 把 `eval-audit.md` 标成已核对可拉取。  
   我们最近的同构物是 `pack-evaluation.md` 的 discriminative field（PASS 只数能分开的标记，混进通用词就会假绿）和 `gate-design.md`「门必须能 FAIL」。它们停在 pack/非代码交付的历史刀上，没有写进 PM 门 2 或门 4 的站立清单。新一轮改 prompt/skill 时，没人被要求先答「这套题能不能检出这次想要的变化」。

5. **失败案例不得贴进正在被优化、且会泄漏到模型上下文的那份说明。**  
   深度简报「关联建议」第 3 点与 §4：不把失败贴进可泄漏面。  
   PM 有相邻但不同的句子：`pm-charter.md` §3.1「搬运：传指针，不传载荷」；§2 派活 prompt 只给角色、Follow TAD、人的目标。那是防 PM 取代 TAD，不是防「把失败样例写进被爬坡的 prompt/skill」。`pack-evaluation.md` 的脱敏是盲评去指纹，也不是这条。

6. **停滞时先分类再烧下一轮。**  
   任务单提到 hillclimb Step 4.5 停滞分类。雷达蒸馏只写到「指南用预算/停止条件约束，但不能消灭账单」（深度简报 §5「成本」），**没有** Step 4.5 的分类表。本讨论不补写未读分类。启发只保留：多轮 × 多模型很贵，停止条件要在开爬前写明。我们 L3 已把「大额花费」列为人拍（`pm-charter.md` §1.5「必须先问人」；`human-operating.md` §3.12 第 6 点「要人的拦下」含花钱）。缺的是爬坡场景下的停止分类句，不是「花钱不用问人」。

7. **`docs/pm/ops-knowledge.md` 本身几乎没有拒假绿刀。**  
   该文件的 Gate 相关只有双写约定（收口/门 4 先落盘）。拒假绿、KA、human-look 的操作句在 grok-cloud 的 `human-operating.md` §3.12 与 `pm-charter.md` §3.1，不在 TAD 仓这份 ops 笔记里。TAD 仓内的假绿语言在 L1/L2 模式（Validation Theater、discriminative gate、honest_partial），和 PM 操作层是两套账。

---

## 不可照搬

1. **触发器与安装面。** `README.md`「一句话」与「开源定位」：Claude Code 用 `/claude-api build-eval` 与 `/claude-api hillclimb` 触发；其它环境的文档口径是 `npx skills add` 或 plugin。`oss-artifacts.md`：这两条不是独立 CLI 二进制，而是 `SKILL.md` Subcommands 命中后去 Read 指南。`README.md`「风险/存疑」第 5 点：栈绑 Anthropic / Claude Code；原则可迁，命令不可当通用标准。深度简报 §1：开放工件、封闭体验面。组合主路径是 Cursor / OpenCode / Codex + thin-PM，不把这些 slash 命令写成 TAD 档位。

2. **AskUserQuestion、会话允许列表、`--approve-harness` 这个开关名。** 深度简报 §3：人在环的自动迭代；runner 可后台跑，安全边界是会话允许列表。我们的人闸是 L3、过程 Gate 2 双审落盘、human-look helper（`human-operating.md` §3.12–§3.13）。不把他们的交互工具名写进 Alex SKILL。

3. **整段 hillclimb 当今日执行。** 深度简报「关联建议」第 4 点：不建议现在跑一轮正式 hillclimb（未确认且烧钱）。`README.md`「不适合」：不当跨厂商评测平台；无生产样例又不愿手写题就不适合；业务漏斗不走这条刀。`pm-charter.md` §1.5：凭证与大额花费是 L3。讨论记录不授权开跑。

4. **厂家数字与未公开的完整报告器。** `README.md`「关键事实」与「风险/存疑」第 1–2 点：博客数字非本仓复测；`build-report.mjs` 公开树 404，能力以 lite + 指南为准。`oss-artifacts.md`「缺口」同句。不把 66%→88% 或成本降至 1/5 写进我们的验收阈值。

5. **评测科学与第三方产品位。** 深度简报「核心判断」：有限后劲；护城河在纪律与脚手架，不在独占评测科学；Promptfoo / LangSmith / OpenAI Evals / DSPy / skill-creator 已在其它栈。不把 claude-api eval 收成 TAD 的评测 SSOT，也不替换 `ai-evaluation` pack（本讨论未加载该 pack）。

6. **「人随便 yes」的自动化。** 深度简报 §5「假绿 2.0」：人若随便 yes，或题集不代表生产，自动化只是更快地优化错目标。这和我们「禁止代答、禁止把选项收成默认值」（`pm-charter.md` §3.1）同向。照搬访谈脚本而不保留拒签，会把假绿加速器装进门 4。

---

## 对 TAD 的可选吸收

最多五条。分层。**默认全都不改文件**；下面只标「若人点名开刀，刀落在哪一层」。本讨论不执行。

| # | 层 | 可写进去的一句 | 改 TAD 上游？ | 只改 PM 层？ |
|---|----|----------------|---------------|--------------|
| 1 | 原则清单 | 效果收口的标题数字只来自**未参与本轮修改**的对照面；训练面上涨、对照面不动，记过拟合并回滚该轮，不报 PASS。 | 可做一条 **L2**（`patterns/gate-design.md` 或 `pack-evaluation.md`），**不升 L1**。L1 已有 Validation Theater，升格要 Epic（`principles.md` 文首）。 | 可同时在 PM 用更短的人话，但原则句若要约束 Alex/Blake，家在 TAD 模式层。 |
| 2 | 原则清单 | 宣布「改进成立」之前，先有噪声地板：地板大于愿行动的最小提升，则本轮分数差不合作改进。 | 同上，**L2 可选**，不改 SKILL、不改 Gate 清单模板。 | PM 门 4 文案可引这句，而不把测量脚本放进 TAD。 |
| 3 | 门禁文案 | 在拒假绿旁加半句：文件在、闸勾了、甚至独立审 PASS，若题集就是本轮改 prompt 时见过的失败，仍不得把该分当门 4 标题。 | **不改** TAD SKILL / `.tad/templates` / `.tad/gates`。`human-operating.md` §3.12 已写明「本刀不改 TAD 上游 SKILL / 模板」。 | **只改 PM**：`human-operating.md` §3.12 与 `pm-charter.md` §3.1 第 5 点各加同一句（两处已在互引，避免只改一处）。 |
| 4 | 门禁文案 | 改 prompt / skill / 工具描述 / grader 的刀，门 2 证据里用五行问答留下 audit：task、harness、metrics、grader、这套题能否检出本轮要的变化。缺一行 → 过程 Gate 2 不放行实现。 | **不改** gate SKILL 的六项清单。 | **只改 PM** 查盘口径（§3.13 第 1 点旁注）。五行是人读的证据形状，不是新 Gate 编号（§3.12 第 3 点已禁止另发明 Gate 编号）。 |
| 5 | 可选流程钩 | 若人另点名「对某一份 prompt/skill 做有界爬坡」：开跑卡写预算与停止条件；每轮一个变量；harness/grader 变更单独要人批；失败样例不写进被优化的那份说明，只留证据路径。跑完仍走现有门 3/门 4，不新开验收 Agent。 | **不改** TAD 流程档位（`pm-charter.md` §1.5「只选 TAD 已有档位」）。不把 hillclimb 收成 `*experiment` 的别名。 | **只改 PM** 可选钩：写在该项目 `docs/pm/` 的开跑约定或 ops 笔记，默认关闭。花费越过常规则仍是 L3。 |

第 5 条是流程钩，不是今日任务。雷达「关联建议」第 3 点已写：可交指针，不代派、不改对方仓。

---

## 建议下一步（讨论级）

等人点名再开刀。本文件不是设计、不是 handoff、不是 Gate 2 输入。

1. **若人说「先记原则、不改门」：** 只把上表第 1–2 行交给下一次人点名的 L2 模式讨论。仍不编辑 `principles.md`。  
2. **若人说「只补 PM 拒假绿」：** 上表第 3 行（必要时加第 4 行）改 grok-cloud 的 `human-operating.md` §3.12 与 `pm-charter.md` §3.1，两处同句。不碰 TAD SKILL、模板、Gate 清单。改完走该仓自己的文档线，不在本讨论里代跑。  
3. **若人说「拿一个真实 prompt 试爬坡」：** 先有生产样例与人签收的输入/grader（雷达 `README.md`「适合」），并单独立项预算。未点名前不做。  
4. **继续盯雷达，不盯推文：** `README.md`「盯着的事项」——`build-report.mjs` 是否公开、`shared/evals/` 大改、第三方复现。点名文件仍是 `2026-09-29-oss-artifacts.md` 那张路径表。  
5. **`ai-evaluation` pack：** 关键词命中，本讨论未读正文。只有人点名加载或写下失败重试并点名该 pack，才打开 SKILL。

**本席未做：** Gate 2、产品/文档/模板/SKILL 编辑、git push、上游指南全文摘抄、hillclimb 试跑。
