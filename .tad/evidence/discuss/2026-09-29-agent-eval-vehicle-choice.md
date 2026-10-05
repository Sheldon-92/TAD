# Discuss：把 Claude eval/hillclimb 方法收进 TAD 的载体选择

**Date:** 2026-09-29  
**Mode:** Alex `*discuss`（研究 / 载体选择，不实现）  
**Channel+model:** cursor / Grok 4.7  
**Status:** discuss record only — **not** a handoff, **not** READY_FOR_BLAKE, **not** a design doc  
**Locks:** NO Gate 2 · NO product / docs / templates / SKILL / principles / patterns edits · NO git push  
**Verdict:** PASS

**人锁 A：** 只选「怎样吸收」——skill，或 capability pack，或既有 L2 pattern，或 hybrid。吸收对象是评测建造与爬坡的**方法**，让用 TAD 设计/调 agent 的人能跟着做。方法缺口已在前一份 discuss 定过；本文件不重开「要不要吸收」。

**Pack pointers（未按包加载 `references/`）：**

- `ai-evaluation` — 评测设计、回归、判别性、负对照（registry `status: active`）。Path: `.agents/skills/ai-evaluation/SKILL.md`。Do not load unless escalated.
- `agent-skill-evolution` — 自演化的 held-out 门（磁盘上有 SKILL；`pack-registry.yaml` 的 `name:` 列表里没有这一行，loader 不会按关键词自动指针）。Path: `.agents/skills/agent-skill-evolution/SKILL.md`。Do not load unless escalated.

**本席读到的边界：** 两份 pack 只读到开篇身份句，未读 `references/`。`ai-evaluation` 开篇写明「Pack = evaluation judgment. Your workflow system = process constraints. No overlap.」`agent-skill-evolution` 开篇写明「Pack = self-evolution judgment」且 CONSUMES 行把 held-out set 当作自演化输入；交叉规则标题是「No Gate = No Evolution」。

**Local Wiki：** `research/canon/_index.md` 无 hillclimb / eval / 评测命中。本讨论不建 notebook。

**被拒草稿（非权威）：** `docs/pm/ops/agent-tune-eval-hooks-draft-20260929.md` 在盘上。人已拒绝用草稿旁路。本文件不把它当依据，不摘其条文。

**源（引文只来自这些锚）：**

| 角色 | 路径 | 锚 |
|------|------|----|
| 前讨论 | `.tad/evidence/discuss/2026-09-29-claude-eval-hillclimb-vs-tad.md` | 「一句话判断」「对 TAD 的可选吸收」表、「建议下一步」 |
| 雷达 | `/home/box/云同步/tech-radar/claude-eval-hillclimb/README.md` | 「一句话」「适合 / 不适合」「风险/存疑」「运用建议」 |
| 雷达深度 | 同目录 `2026-09-29-depth-brief.md` | 「核心判断」「对技术雷达的关联建议」第 3、5 点 |
| L1 | `.tad/project-knowledge/principles.md` | 文首；「YOLO Epic Execution… Validation Theater」 |
| 知识分层 | `.tad/project-knowledge/README.md` | 「Three-Layer Model」「Knowledge Promotion Decision Rule」 |
| L2 评测 | `.tad/project-knowledge/patterns/pack-evaluation.md` | 「Behavioral-Eval Gate Must Run on SEPARATE Discriminative Field」 |
| L2 门 | `.tad/project-knowledge/patterns/gate-design.md` | 文首；「Gate 4 Verification Integrity」 |
| L2 索引 | `.tad/project-knowledge/patterns/_index.md` | Pack Evaluation / Gate Design 两行 |
| Pack 惯例 | `.tad/project-knowledge/patterns/pack-build-rules.md` | 「Skill File vs MCP Tool Boundary」「Pack Loader Thin On-Demand」「Skill Authoring Habits」 |
| 流程 skill | `.agents/skills/alex/SKILL.md` `experiment_path_protocol`；`.agents/skills/alex/references/experiment-path-protocol.md` 文首 | 已有 eval-loop 档位 |
| 讨论体例 | `.tad/evidence/discuss/2026-09-22-epic-phase-vs-human-habit.md` | 头部锁、只记录不交接 |

---

## 1. 目标复述

前一份 discuss（Verdict PASS）已经把可吸收的方法收成五条，并写明默认不改文件。与本刀相关的句子是：

- 效果收口的标题只来自**未参与本轮修改**的对照面；训练面涨、对照面不动，记过拟合并回滚该轮。
- 宣布改进成立之前先有噪声地板；地板大于愿行动的最小提升，分数差不合作改进。
- 一轮一个变量；失败样例不写进正在被优化、且会漏进模型上下文的那份说明。
- 改 prompt / skill / 工具描述 / grader 之前，先问 task、harness、metrics、grader、这套题能否检出这次要的变化。

雷达口径与此同向、且划清了边界：`README.md`「适合」写「可迁原则，不必绑 Claude Code」；「风险/存疑」第 5 点写「原则可迁，命令不可当通用标准」。`2026-09-29-depth-brief.md`「关联建议」第 5 点写「方法可迁、命令可不迁」；第 3 点把可交指针收成「噪声地板 + held-out + 不贴失败进 prompt」。

前讨论「建议下一步」第 1 条：人若说「先记原则、不改门」，把表第 1–2 行交给下一次人点名的 **L2** 讨论，仍不编辑 `principles.md`。第 5 条写明爬坡不是 TAD 新档位，也不把 hillclimb 收成 `*experiment` 的别名。

本刀要定的是：这些方法句在 TAD 里住哪一类载体，用 TAD 设计或调 agent 的人才能在该载体的加载规则下碰到它们。不住 PM 草稿，不新开 slash 命令。

---

## 2. 候选载体（skill / capability pack / L2 pattern / hybrid）对照 TAD 惯例的利弊

TAD 里「skill」有两类，不能并成一个选项。

- **流程 skill**（人敲命令的编排器）：`.agents/skills/` 下的 `alex`、`blake`、`gate`、`tad`、`tad-*`、`capability-builder`、`dependency-ops`、`release-runbook` 等。`pack-build-rules.md`「Skill Authoring Habits」D1：user-invoked orchestrator 与 model-invoked / keyword-recruited 分开；禁止把 `/alex`、`/blake` 包成又一层 Skill 调用。
- **Capability pack**（判断包）：registry 里 `type: reference-based` 的那一组。`ai-evaluation` 在册且 `status: active`。加载规则在「Pack Loader Thin On-Demand」：关键词最多宣布 2 个指针，正文只在人点名或记录在案的失败重试时才读。

`*experiment` 已经是评测环的流程档位。`experiment-path-protocol.md` 文首：OPRO / A-B / benchmark / prompt tuning / eval-loop；并写明起草时要读 `ai-evaluation`。新的 hillclimb 命令会和这条已有档位叠在一起。

| 载体 | 跟哪条惯例对齐 | 对「设计/调 agent 的人能跟着做」 | 代价 |
|------|----------------|----------------------------------|------|
| **新 skill（流程命令）** | 流程 skill 的职责是人敲的编排器（D1）。前讨论「不可照搬」第 1 点与表第 5 行：不把 `/claude-api hillclimb` 写成 TAD 档位，也不把 hillclimb 收成 `*experiment` 别名。 | 人必须记住一条新命令才碰得到方法。设计 agent 的日常会话不会自动走到这条命令。 | 新 slash 面；与 `*experiment` 双轨；命令不可迁这一条被打破。 |
| **新 capability pack** | 「Knowledge Promotion Decision Rule」：pack 只收 ≥2 个项目的独立证据，或带许可证核对的行业标准原文搬入。单项目句子留在 project-knowledge。L1「Validation Theater」同时警告 pack 数量 × 规则会撑爆上下文，并要求 step4_5 最多 2 个 pack。 | 关键词能把「在做评测」的人指到包上。 | `ai-evaluation` 已覆盖评测设计 / 回归 / 判别性 / 负对照。再开一包是第二本评测手册。`agent-skill-evolution` 的关键词是自演化 / SkillOpt，不是普通调 prompt；且不在 `pack-registry.yaml`，自动指针不会指到它。 |
| **只改既有 `ai-evaluation` 正文** | 「Skill File vs MCP」：判断留在 skill（拿掉工具名仍有价值 → 是判断）。该包开篇：Pack = judgment，workflow = process constraints，两边不重叠。 | `*experiment` 会加载这个包，调参路径看得到判断句。 | 关键词命中只给指针，不读正文。普通「帮我设计一个 agent」的会话在未 escalate 时看不到包内句子。把一轮一改、停止预算、人批 harness 写进包，等于把流程约束塞进判断包，和它自己的分界相反。也和前讨论「不替换 `ai-evaluation`」相反。 |
| **只追加既有 L2** | 「Three-Layer Model」：可复用的一类问题 → L2；按需由 `_index.md` 命中再读全文。L1 只在「从根本上改变 TAD 怎么工作」且走 Epic 时才改。前讨论表第 1–2 行已指定 L2（`pack-evaluation.md` 或 `gate-design.md`），不升 L1。 | Alex 激活会读 `_index.md`，命中后 Blake 会读全文。句子短，不依赖人去 escalate 一个包。 | 今日索引行是「Anti-slop metrics, cross-model review, discriminative behavioral eval gates…」。没有噪声地板、held-out、一轮一改这些检索词时，调 agent 的会话可能命中 `ai-evaluation` 指针，却打不开这份 pattern。`gate-design.md` 的索引行是门的职责与验证完整性；把爬坡轮次写进去，读起来像在改门，而前讨论表第 3–4 行写明不改 Gate 清单、不新编号。 |
| **hybrid** | 判断句的邻居是已有 pack；流程约束与「未 escalate 也要碰得到」落在 L2。两边用交叉引用连上，不新开第三处全文。 | 设计会话靠 L2 索引命中；评测会话在人加载 `ai-evaluation` 时看到同一句的指针，而不是另一套爬坡手册。 | 下一刀要同时改 pattern 与索引行；pack 侧只在核实 `references/` 确无同句之后加引用，避免双份正文。 |

`pack-evaluation.md`「Behavioral-Eval Gate…」已经规定：PASS 只数能分开的标记，无 pack 的 CONTROL 必须 FAIL。那是「门能不能分开两类输出」。前讨论「缺口」第 1 点写明：这还不是「同一套题重跑的抖动有多大、小于抖动的涨分不许当改进」，也还不是「标题只许用未参与本轮修改的对照面」。所以既有 L2 是对的家，句子本身还没写上。

L1「Validation Theater」已经写了结构检查不证明行为变好。三层分类第 1 问：这条规则是否超越任何具体代码库并从根本上改变 TAD 怎么工作。噪声地板与 held-out 标题是评测这一类问题的复用句，不改变四道门的分工，因此停在 L2。`principles.md` 文首：L1 修改走 Epic。

---

## 3. 推荐 + 理由

**推荐载体：hybrid。方法句的家是既有 L2 文件 `.tad/project-knowledge/patterns/pack-evaluation.md`（追加一条，不新开 pattern 文件）。`ai-evaluation` 不改成爬坡工作流；仅当下一刀读完其 `references/` 确认没有同句时，加一句指向该 L2 条目的交叉引用。**

理由，按已读惯例：

1. **前讨论已经把家指到 L2，并排除了命令与换包。** 「可选吸收」表第 1–2 行：可做一条 L2，不升 L1，不改 SKILL，不改 Gate 清单模板。「建议下一步」第 1 条把这两行交给 L2 讨论。「不可照搬」第 5 点：不把 claude-api eval 收成评测 SSOT，也不替换 `ai-evaluation`。
2. **文件选 `pack-evaluation.md`，不选 `gate-design.md` 当主家。** 新句子和判别性字段、负对照、Validation Theater 是同一类「分数不要自我欺骗」。`gate-design.md` 文首是门架构与验证完整性；「Gate 4 Verification Integrity」管的是从原始证据重算。爬坡轮次写进该文件，会变成门条文。前讨论表第 4 行禁止新 Gate 编号。
3. **纯 L2 覆盖不到「人正在谈评测、但索引词没命中」的会话。** 该会话的招聘面是 `ai-evaluation` 的 keywords（registry：评估 / evaluation / eval / regression / A/B / rubric）。Loader 只发指针。混合的第二半是：包被 escalate 或 `*experiment` 加载时，用一句话指回 L2，不在包里再写一套一轮一改。这守住该包开篇的 judgment / process 分界，也守住「Pack Loader Thin On-Demand」的指针默认。
4. **新 skill 与新 pack 都不做。** 新 skill 是新命令。新 pack 冲撞「不把单点建议提前升成 pack」的推广规则，并和已有 `ai-evaluation` 抢同一个关键词。`agent-skill-evolution` 保持自演化 held-out 门的邻居身份，不迁居、不补注册。
5. **方法句保持短。** 雷达深度简报「核心判断」：护城河在纪律，不在独占评测科学。L2 条目写纪律（噪声地板、held-out 标题、一轮一变、失败不贴进被优化说明、五问 audit 的形状）。不复制 `shared/evals/*.md`，不引入 `/claude-api`、`--approve-harness`、AskUserQuestion 这些名字（前讨论「不可照搬」第 2 点）。

这不是 PARTIAL：载体已定，pack 正文是否已有同句是下一刀的核对项，不改变家在 L2。

---

## 4. 本刀不改什么

- 不改 `principles.md`、`patterns/*.md`、`_index.md`、任何 SKILL、`.tad/templates`、`.tad/gates`、产品文档、`docs/pm/**`。
- 不跑 Gate 2，不写 handoff，不标 READY_FOR_BLAKE，不把本文件当设计文。
- 不把 `docs/pm/ops/agent-tune-eval-hooks-draft-20260929.md` 升成制度。
- 不新开 hillclimb slash、不改 `*experiment` 的别名、不在本仓跑 hillclimb。
- 不加载 `ai-evaluation` / `agent-skill-evolution` 的 `references/`。
- 不 git push。
- 前讨论表第 3–5 行（PM 拒假绿半句、门 2 五行问答、默认关闭的开跑卡）仍留在人另点名的 PM 刀，不并进本载体。

---

## 5. 若人采纳推荐：下一刀大纲（*analyze 范围）

人锁之后才进入 `*analyze`。范围只做 hybrid 的落地设计，仍不在本文件里改 pattern。

1. **写一条 L2。** 只追加 `patterns/pack-evaluation.md`。条目覆盖：噪声地板先于宣布改进；标题数字只来自未参与本轮修改的对照面；一轮一个变量；失败样例不写入被优化且会进上下文的说明；task / harness / metrics / grader / 能否检出本次变化，这五行是证据形状，不是新门编号。`failure_mode` 沿用该文件已有的「无负对照即剧场」句式，并写明「见过的题上变绿」与「结构绿冒充行为绿」是两句。
2. **改索引一行。** `patterns/_index.md` 的 Pack Evaluation 钩子补上检索词（噪声地板、held-out、一轮一改），使 Blake 的关键词匹配能打开该文件。不新开 pattern 文件。
3. **核对 pack，再决定是否一句交叉引用。** 人点名加载 `ai-evaluation` 之后，只查 `references/` 里有没有噪声地板、held-out 标题、一轮一变的同句。没有则在包内加一句「流程约束见 L2 `pack-evaluation` 该条目」，不搬指南，不加 subcommand。已有同句则 pack 零编辑。
4. **明确不在这刀里的面。** 不改 `principles.md`；不把句子写入 `gate-design.md`；不编辑 `agent-skill-evolution`；不把它补进 `pack-registry.yaml`；不改 `*experiment` 协议；不改 PM 文案；不采纳被拒草稿。
5. **验收仍是后话。** `*analyze` 的产出若要变成 Blake 的改动，另走人锁的设计与交接。本讨论不预开 Gate 2。
