# HANDOFF: 把 TAD 统一成英文（产品面），并把「输出语言」和「对话语言」分开

**From**: Alex（full） **To**: Blake **Created**: 2026-08-15 **Rev**: rev1
**用户裁定（2026-08-15）**：「整个项目统一成英文；但模型可以随用户使用中文或英文回答。」

## 1. 这不是翻译工作，先说清楚它是什么

**要分开的是两件事**：
- **产物语言** —— 仓库里的文件、agent 写出的 handoff/COMPLETION/知识条目：**一律英文**
- **对话语言** —— agent 在终端里跟人说话：**跟随用户**（用户说中文就说中文）

现在这两件事在框架里**没有任何地方被区分过**，所以下一个 session 写出来的东西还会是中文。
**规则先立，翻译才有意义**——否则是往漏水的桶里倒水。

## 2. 范围（实测，不是估的）

| 范围 | 文件 | 汉字 | 做不做 |
|---|---|---|---|
| `.claude/skills/` + `.agents/skills/`（含 references） | 354 | 204,752 | **做** |
| `.tad/` 其它（config / templates / guides / hooks / schemas…） | 198 | 90,231 | **做** |
| `.tad/project-knowledge/` | 11 | 10,997 | **做** |
| `.tad/capability-packs/` | 49 | 3,785 | **做** |
| 根目录（README / CLAUDE.md / AGENTS.md / ROADMAP…） | 9 | 4,457 | **做** |
| `docs/`（不含 archive/legacy） | 4 | 5,119 | **做** |
| **产品面合计** | **625** | **319,341** | |
| `.tad/evidence/` + `.tad/archive/` + `docs/{archive,legacy}/` | 1,719 | 1,229,216 | **不做** |

⚠️ **历史记录不翻译**：那些 handoff、Gate 报告、agent 原始作答是**当时用那个语言发生的**，
翻译过去等于篡改记录。它们也占 79% 的工作量。**归档就是归档。**

## 3. 承重：锚点与检查器必须同步移动

⚠️ **Alex 在给用户的初判里把这个风险说过头了，这里更正**，免得 Blake 按错误的前提干活。

初判说「几十个脚本靠 grep 中文串工作，翻译会打断检查链」。**实测：那些脚本全在
`.tad/evidence/` 与 `.tad/archive/`——是冻结的工单产物，不是运行中的框架。**

**活的运行时里，真正的中文机械耦合只有这些**（Blake 须逐条复算确认，别信这张表）：

| # | 位置 | 中文串的角色 | 谁消费它 |
|---|---|---|---|
| 1 | `.tad/discipline-floor.md` | 30 条纪律的**锚点串/触发串**，26/30 含中文 | `.tad/discipline-floor-budget.md`（唯一活消费者）；`gen-floor.py`（evidence 侧，生成它） |
| 2 | `alex/SKILL.md` L200-230 | **29 条常驻义务祈使句**，全中文 | 无活脚本 grep；但它是本 Epic 的承重交付 |
| 3 | `alex/SKILL.md` L422 等 | `禁止整读` —— P3 启动扫描的约束句 | `measure.sh`（archive 侧）靠它抽命令 |
| 4 | `gate/SKILL.md` L168 | `step2: "对每一行，实际执行其 Verification Method…"` | 地板表登记它为 `AC可执行性检查` 的锚点 |
| 5 | `tad.sh:52` | 一句中文注释 | 无（纯注释） |

**规矩（本单的核心约束）**：
> **改一个锚点串，必须在同一个 commit 里改完它的所有消费者。**
> 每改一处，落盘一行 `锚点原文 ⇥ 新文 ⇥ 消费者清单 ⇥ 该消费者的验证命令与输出`。

⚠️ 这条不是形式要求。本仓库**今天已经栽过两次同一个坑**：
`gen-floor.py` 的锚点在 P3 改了产物没改生成器（生成器从此报错没人发现）；
`measure.sh` 的路径在归档后失效（唯一测激活成本的脚本死了一周没人发现）。
**两次都不报错，只是安静地不再工作。**

## 4. 分两刀，第一刀不翻译

### S1 —— 立规则 + 把机械锚点换成语言无关的标识符（**不翻任何文案**）

1. **在 `CLAUDE.md` 与 `AGENTS.md` 各加一条**，措辞两侧逐字一致：
   > **Artifact language is English. Conversation language follows the user.**
   > Everything written to disk — handoffs, completion reports, knowledge entries, commit
   > messages, code comments, evidence — is English. Replies in the terminal mirror the
   > language the user is writing in. These are two separate settings; neither implies the other.
2. **把 §3 表里 1–4 的中文锚点换成语言无关的标识符**（照 P7 的做法：
   `data_leak` / `forced_review` 这类 YAML 键名、或稳定的英文标记行），
   **每换一个，同一 commit 内改完消费者并落盘验证输出**。
3. 29 条祈使句**这一刀只换载体不换语言**——它们是 Epic 承重，翻译放 S2。

### S2 —— 翻译产品面文案（625 文件）

按目录分批，每批**独立 commit + 独立跑闸**：
`docs`(4) → 根目录(9) → `capability-packs`(49) → `project-knowledge`(11) → `.tad` 其它(198) → `skills`(354)

⚠️ **`skills` 放最后**：它是 354 个文件、20 万汉字，且两侧镜像必须逐字一致。

## 5. 不做

❌ 不翻 `.tad/evidence/` · `.tad/archive/` · `docs/archive/` · `docs/legacy/`（历史记录）｜
❌ 不改任何 YAML 键名、命令名、skill 名、文件名（只改**值与散文**）｜
❌ 不动 `.tad/migrations/` 已有清单｜❌ 不发布不 push｜
❌ **不在 S1 里翻译任何文案**（先立规则和锚点，否则边翻边漏）

## 6. 写权限

S1：`CLAUDE.md`、`AGENTS.md`、`.tad/discipline-floor.md`、`.tad/discipline-floor-budget.md`、
`.claude/skills/**`、`.agents/skills/**`、`.tad/evidence/acceptance-tests/english-unification/`（新建）。
S2 另行按批次开权限（**每批开工前回来找 Alex**，不要一次要全部）。

## 7. Acceptance Criteria（S1）

T0 = 开工前 commit。**不变量类 T0 必绿 / 完成度类 T0 必红。任一方向不符 → 停下退回 Alex。**

| # | AC | 类 |
|---|---|---|
| **AC1** | **语言规则两侧逐字一致**：`CLAUDE.md` 与 `AGENTS.md` 中该段落 `diff` 零输出；且段落里同时出现 `Artifact language` 与 `Conversation language` 两个短语 | 完成度 |
| **AC2** | **锚点-消费者同步表**：`english-unification/anchor-moves.tsv`，每行 `旧锚点 ⇥ 新锚点 ⇥ 消费者路径 ⇥ 验证命令 ⇥ 命令输出`。**行数 = §3 表里实际改动的锚点数**，且**每个消费者的验证命令必须在 COMPLETION 里贴出真实输出** | 完成度 |
| **AC3** | **无孤儿锚点**：对 `anchor-moves.tsv` 里每个**旧**锚点，全仓 `git ls-files` 内除 `.tad/{evidence,archive}/` 外命中数 = **0**；对每个**新**锚点，命中数 ≥ 2（本体 + 至少一个消费者） | 完成度 |
| **AC4** | **地板表仍自洽**：`gen-floor.py` 干跑 exit=0（它会断言每个锚点在其载体里存在）；重跑后 `discipline-floor.md` 与手上版本 `diff` 零输出 | 完成度 |
| **AC5** | **六个闸全绿**：`release-verify.sh` 的 parity / version / version-sweep / migration + `tad.sh --verify-denylist` + `skill-body-verify.sh` | 不变量 |
| **AC6** | **29 条祈使句未被翻译也未被移动**（S1 不碰它们）：`verify.sh AC1` 式断言——29 条在 `alex/SKILL.md` 内 `grep -F` 全中，`SPAN` 仍 = 28 | 不变量 |
| **AC7** | parity：`diff -r .claude/skills .agents/skills` 零输出 | 不变量 |
| **AC8** | **行为验证**：spawn 1 个 fresh subagent，**用英文**提一个需要写产物的小任务，确认它 (a) **用英文写产物**、(b) 若改用中文提问则**用中文回复但仍用英文写产物**。两次原始作答落盘 | 完成度 |
| **AC9** | 围栏：改动集 −(§6 写权限 ∪ T0 既有脏文件 ∪ `.tad/evidence/{traces,decisions}/*.jsonl` ∪ `session-state.md`) 为空 | 不变量 |
| **AC10** | **契约未变**：`git diff --quiet ${T0} -- <本文件>`（T0 须已 `git add` 本文件） | 不变量 |

## 8. Step 0

1. `git add` 本契约 → commit → 记 T0
2. **复算 §3 那张表**——Alex 已经在这上面说错过一次，**不要信它**。
   用 `git ls-files` 排除 `.tad/{evidence,archive}/` 和 `docs/{archive,legacy}/` 后，
   自己找出所有「活文件里的中文机械锚点」，与 §3 比对，**多出或少掉的都写进 COMPLETION**
3. 落盘 AC3 的旧锚点命中基线、AC6 的 29 条祈使句行号基线
4. **逐条 AC 跑方向负控**

## 9. 已知取舍

1. **S1 完全不产生可见的语言变化**——它换的是锚点和规则。看起来"什么都没发生"是正常的。
   **抵抗把 S2 提前做掉的冲动**：先翻译再动锚点，等于在检查链失明的状态下改 625 个文件。
2. **历史记录保持中文**，仓库会长期处于「产品英文 / 记录中文」的混合状态。**这是刻意的。**
3. **AC8 是模型输出**，可复现性弱于其余 AC。它买的是「规则真的改变了行为」，
   而这是本单唯一无法用 grep 证明的东西。
4. ⚠️ **翻译质量本单不设 AC**。S2 时若发现某段中文的意思在英文里无法逐字对应
   （尤其是纪律条文与反合理化登记），**停下退回 Alex**——那是设计问题不是翻译问题。
