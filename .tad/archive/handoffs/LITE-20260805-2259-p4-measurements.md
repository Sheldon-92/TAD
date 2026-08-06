# LITE Handoff: P4 实测 —— 四组机械测量

**Date**: 2026-08-05
**Series**: EPIC-20260804-lite-as-tad-body step 4/6（余下：P5 补齐真缺口、P6 full 退场）
**Revision**: v3（v1 FAIL → v2 CONDITIONAL → v3 PASS，共修 5 P0 + 9 P1 + 7 P2，见 `## Contract Review`）

## 目标（2-3 句，含"为什么"）

本 Epic 的 Success Criteria（SC1 固定读取量、SC2 端到端 token）至今**没有一个真实测量**，
P1–P3 的所有设计都建立在推定之上——这正是 `Measure Before Optimizing` 警告的形态。
本单产出**四组可独立重算的数字与逐字引用**，为随后的 SC1 重设、领地边界确认、
reviewer 独立性裁定提供依据。

**本单只测量，不下结论。** 结论由人在验收时根据数字作出。

## 不做什么

- **不写任何结论、建议、评价、成因分析**。报告只含：数字、产生数字的命令、逐字引用、
  以及 B 段中**被明确授权且被验证器绑定**的清单条目编号判定（见 AC4）。
  「SC1 该定多少」「reviewer 是否真独立」「领地该不该保留」三个判断**不属于本单交付物**。
- 不新增/扩大任何 MUST / MANDATORY / BLOCKING / 禁止 / 不得 条目 → **不触发约束准入闸**，
  不追加 `lite-constraint-ledger.md`。
- 不修改 `.claude/skills/`、`CLAUDE.md`、`.tad/active/epics/`、`.tad/hooks/`、
  `.claude/settings*.json` 中的任何文件。
- 不执行任何 release / publish / sync / git push / git commit。
- 不估算 token 数（无可信 tokenizer；token 由人在验收时读 harness 实际用量）。
- B 段是**只读推演**：只做「路径 vs 清单条文」的文本匹配，不执行假想任务的任何动作。

## 文件清单（创建/修改，逐个路径）

**交付物（创建 1 个）**：
- `.tad/evidence/audits/P4-measurements.md`

**除交付物外**，工作区允许出现的改动**以 AC8 白名单为准**（blake-lite 协议强制产生的
Progress / Completion / review 载体 / journal / AC 证据均在白名单内）。
白名单之外的任何改动均属越权。

---

## 度量口径（不得自行改动；Blake 按此执行）

### 双口径

每一个体量数字必须同时给 `bytes` 与 `chars` 两列。
理由：本仓库正文以中文为主，CJK 一字符 = 3 字节，两个口径相差约 1.85 倍，
而 Epic 的 SC1 写的是「字符」、历史记录用的却是字节。**报告不解释此差异，只并列两数。**

⚠️ **macOS/BSD `wc` 的 `-c` 与 `-m` 互斥且不报错**：`wc -c -m file` 只输出 chars 一列。
**必须分两次调用**：`wc -c < file` 取 bytes，`wc -m < file` 取 chars。禁止合并成一次调用。
（实测：`wc -c -m .claude/skills/alex-lite/SKILL.md` → `11145`，把 chars 冒充成了唯一结果。）

⚠️ **`~` 在引号与变量中不展开——第 3 项必须用 `$HOME` 取值**：
Bash 工具实跑的是 **zsh 5.9**，`p='~/.claude/CLAUDE.md'; test -f "$p"` 实测返回 **MISSING**，
而该文件真实存在。**取值一律写 `"$HOME/.claude/CLAUDE.md"`**（双引号内 `$HOME` 展开）；
`~/.claude/CLAUDE.md` 仅用于报告表格显示与附录 C 的字面比对。
**反校验**：`~/.claude/CLAUDE.md` 实测 **927 bytes / 499 chars**。
该行若标 `MISSING`，即为 `~` 展开口径用错，**不是**文件缺失。

### 节切分口径（A 段用）

以行首 `## `（两个井号 + 空格）为节起点。文件开头到第一个 `## ` 之前的内容记为伪节
`__PREAMBLE__`。已实测：两个 skill 文件的代码围栏数均为 **0**（`grep -c '^```'`），
故不存在「`## ` 落在代码块内」的歧义，切分完全确定。

**表的形状已锁死（不是由 Blake 决定的自由度）**：
- `alex-lite/SKILL.md` 表：**恰 13 个数据行**（12 个 `^## ` 节 + `__PREAMBLE__`），外加 1 个合计行
- `blake-lite/SKILL.md` 表：**恰 21 个数据行**（20 个 `^## ` 节 + `__PREAMBLE__`），外加 1 个合计行
- 数据行顺序 = 文件出现顺序，`__PREAMBLE__` 在最前
- 「节标题」列自第 2 行起必须与 `grep -n '^## ' <file> | sed 's/^[0-9]*://'` 的输出**逐行同序逐字相等**

**已实测的 ground truth（canary，写死；不符即口径用错）**：

| 文件 | `__PREAMBLE__` 行 | 全文 |
|---|---|---|
| `alex-lite/SKILL.md` | **209 bytes / 119 chars** | **20846 bytes / 11145 chars** |
| `blake-lite/SKILL.md` | **195 bytes / 135 chars** | **24298 bytes / 13243 chars** |

⚠️ 该 canary 是为封死「把全文数值压进 `__PREAMBLE__`、其余行填 0」的退化填法——
该填法能同时通过行数、标题、和式三项判据，且配一个 `for i in {1..12}; do echo 0; done`
的命令块还能通过 AC7 人工重跑。有了 canary，它当场冲突，而正确切分零成本通过。

**标题列提取命令（写死，免验收者自造）**——已核验 32 个节标题均不含 `|`：

```bash
awk -F'|' 'NR>2 && $2 !~ /合计/ {gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}' <表片段> \
  | diff - <(grep -n '^## ' <file> | sed 's/^[0-9]*://')
```

### 固定读取量口径（A 段用）

定义 = 一次冷启动 `/alex-lite`（或 `/blake-lite`）从激活到 L2 落盘前**必读**的文件全集。
构成清单固定为下表 **13 行**，一行不得少、不得多；不存在的文件也必须留行并标 `MISSING`（bytes/chars 记 `0`）：

| # | 路径 | 来源分类 |
|---|---|---|
| 1 | `.claude/skills/alex-lite/SKILL.md`（blake 侧换成 `.claude/skills/blake-lite/SKILL.md`） | skill 本体 |
| 2 | `CLAUDE.md` | 项目 CLAUDE.md（harness 自动加载） |
| 3 | `~/.claude/CLAUDE.md` | 用户全局 CLAUDE.md（harness 自动加载） |
| 4 | `.tad/project-knowledge/principles.md` | CLAUDE.md @import |
| 5 | `.tad/project-knowledge/patterns/_index.md` | CLAUDE.md @import |
| 6 | `.tad/project-knowledge/testing.md` | CLAUDE.md @import |
| 7 | `.tad/project-knowledge/ux.md` | CLAUDE.md @import |
| 8 | `.tad/project-knowledge/performance.md` | CLAUDE.md @import |
| 9 | `.tad/project-knowledge/api-integration.md` | CLAUDE.md @import |
| 10 | `.tad/project-knowledge/mobile-platform.md` | CLAUDE.md @import |
| 11 | `.tad/project-knowledge/frontend-design.md` | CLAUDE.md @import |
| 12 | `.tad/brain-index.md` | L1.5 共享知识预检强制读索引 |
| 13 | `.tad/memory/MEMORY.md` | native auto-memory（CLAUDE.md §7.5 重定向） |

**已知缺失集固定为 5 个**（第 6–10 项），Blake 须逐个用 `test -f` 实测并把原始输出作为载体
贴进报告；实测结果与本清单不符时**照实报告并标注差异**，不得静默按本清单填。

**两个合计行（必须都给）**：
- `合计-项目内`：排除第 3 项（用户全局 CLAUDE.md）后的各行之和
- `合计-实际注入`：全部 13 行之和

（分两个合计的理由：用户全局文件是否计入「TAD 的固定读取量」是口径选择，属人域判断，
本单不替人做选择，只把两种口径都摆出来。）

**已知不可测量项（诚实留口，不计入合计，须在报告中原样列出）**：
SessionStart / PreCompact 等 hook 向上下文注入的文本、harness 自身的 skill 描述与工具 schema、
以及 `<system-reminder>` 类注入。这些无文件载体，本单无法测量。

### 假想任务（B 段用，固定三条，不得替换）

- **T1**：给 `.tad/hooks/` 新增一个 PostToolUse hook，记录每张 LITE 单的 token 用量；
  同时在 `.claude/settings.json` 注册该 hook。
- **T2**：执行 `*publish`，把 TAD v2.40.0 发布到 GitHub 并同步到下游项目。
- **T3**：为下一批多阶段工作在 `.tad/active/epics/` 创建一个新的 `EPIC-*.md` 协调文件。

### 回算目标（C 段用）

**commit（固定四个）**：`4b29dc2`、`910ab6c`、`d948585`、`88971ec`
**slug（固定四个）**：`lite-pricing-gate-protocol`、`pricing-gate-scan-fix`、
`lite-inventory-pricing-audit`、`cut-routing-machinery`

⚠️ **C 段的三张表互不声称对应关系**：commit 与 slug 之间**不是**一一对应
（例：`4b29dc2` 未改动任何 handoff 文件；`d948585` 顺带归档了上一单的 COMPLETION）。
建立这种对应关系是判断，不在本单交付范围。Blake **不得**把某个 commit
标注为「某 phase 的 commit」，也不得跨表连线。

---

## AC（每条以 `- AC{n}:` 开头）

- AC1: `.tad/evidence/audits/P4-measurements.md` 存在，且 `grep -c '^## '` 恰为 **5**；
  这 5 个标题按文件出现顺序逐字为：`## 口径与命令`、`## A 体量分解`、`## B 领地只读推演`、
  `## C 闸的历史回算`、`## D reviewer 独立性证据`。
  报告中任何**引用行**若其原文以 `## ` 开头，必须以 `> ` 或 4 空格缩进呈现，
  以免污染本 AC 的计数。
  验证：`grep -n '^## ' <报告>` 输出 5 行且标题逐字匹配。

- AC2: A 段含 `alex-lite/SKILL.md` 与 `blake-lite/SKILL.md` 各一张逐节表
  （列：节标题 | bytes | chars）。**形状按「节切分口径」锁死**：
  - alex 表恰 13 个数据行 + 1 合计行；blake 表恰 21 个数据行 + 1 合计行
  - 首个数据行标题为 `__PREAMBLE__`
  - 其余数据行的标题列与 `grep -n '^## ' <file> | sed 's/^[0-9]*://'` 输出**逐行同序逐字相等**
  - **四个等式全部成立**：两文件各自「各数据行 bytes 之和 == `wc -c` 全文」
    与「各数据行 chars 之和 == `wc -m` 全文」，合计行即该和
  验证：① `awk` 数数据行数 == 13 / 21；② 标题列与 `grep` 输出做逐行 `diff`，得空；
  ③ 按报告给出的切分命令原样重跑，逐行数值一致；④ 四个和式成立。
  ⚠️ 本 AC 的第 ①②条是为堵死「单行退化表」：只锁和式不锁行集时，
  一张 `__PREAMBLE__ | 全文bytes | 全文chars` 的单行表可满足全部和式且经得起人工重跑。

- AC3: A 段含 alex 侧与 blake 侧各一张固定读取量表，每行四列
  （路径 | bytes | chars | 来源分类），行集合与**附录 C** 的纯路径清单
  做 **`LC_ALL=C sort` 后 `comm -3`** 得空（alex 侧比对附录 C-1，blake 侧比对附录 C-2）。
  ⚠️ **collation 必须固定为 `LC_ALL=C`**：实测默认 UTF-8 locale 与 C locale 下
  `~`(0x7E) 与 `C`(0x43) 的相对次序**相反**，`comm` 收到非同序输入其输出未定义
  （可能吐出非空差集 → 假 FAIL，或掩盖真差异）。
  每表含两个合计行（`合计-项目内` / `合计-实际注入`），数值分别等于对应子集各行之和。
  **MISSING 标记须有载体**：每个标 `MISSING` 的行，报告中须附该文件
  `test -f <path> && echo EXISTS || echo MISSING` 的原始输出
  （第 3 项须用 `"$HOME/.claude/CLAUDE.md"`，见「双口径」节的 `~` 警告）；
  标 `MISSING` 的行数与实测缺失数一致（当前预期 **5** 个，实测不符时照实报告并标注差异）。
  **易变行载体**：`.tad/memory/MEMORY.md` 由 native memory 自动写入，执行期可能变化 →
  该行须附测量时刻的 `md5 -q` 与 `stat -f '%m %z'` 输出作载体；
  验收者重跑不一致时以报告内载体为准，不判 Blake 失败。
  「已知不可测量项」段须原样出现在 A 段内。
  验证：`LC_ALL=C sort | comm -3` 得空；`awk` 两次分组求和比对两个合计行；
  逐个 `test -f` 重跑比对（`$HOME` 写法）。

- AC4: B 段含 T1/T2/T3 三个小节，每节给出：
  - **(a) 路径×条目矩阵**：该任务涉及的每个具体路径**单独**判定，
    列为 `路径 | 命中条目编号(1/2/3/兜底/未命中)`。禁止任务级单一结论。
  - **(b) 任务级汇总**：该任务命中的条目编号集合，或 `未命中`。
  - **(c) 逐字引用，与 (a)(b) 绑定**：
    - 声明命中编号 `N` 时，引用中**必须**包含以 `N. ` 开头的那一行原文；
    - 声明 `未命中` 时，**必须**逐条列出 `1.` `2.` `3.` 与兜底句共 4 条原文，
      并对每条给一句「为何不命中」的事实陈述（引用路径 vs 条文范围的对照，非评价）。
  - 每条逐字引用须能在 `.claude/skills/alex-lite/SKILL.md` 的
    `<!-- ESCALATION-LIST-BEGIN -->` 与 `<!-- ESCALATION-LIST-END -->` 之间用 `grep -F` 命中。
  验证：`sed -n '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/p'` 取出区块（实测 7 行），
  对每条引用跑 `grep -Fq` 全部命中；**并检查编号-引用绑定**：
  每个声明的编号 `N`，其对应的 `N. ` 开头原文出现在该小节的引用中。
  ⚠️ 本 AC 的绑定条款是为堵死「三个任务全写兜底 + 全引兜底句」的万能填充
  （该写法在无绑定时可 1 分钟通关并使 B 段归零）。

- AC5: C 段含**三张互不连线的表**：
  - **C1（commit 体量）**：四个目标 commit 各一行，列为
    `短hash | files changed | insertions | deletions`。
    三数取自 `git show --stat --format= <hash> | tail -1`；
    **该行缺 `deletions(-)` 字段时该列记 `0`**（`4b29dc2` 即属此情形），
    缺 `insertions(+)` 同理记 `0`。
  - **C2（审查载体）**：四个目标 slug 各一行，列为
    `slug | reviews 文件数 | 文件路径列表（逐个，换行分隔）`。
    取自 `find .tad/evidence/reviews -path "*<slug>*" -type f`（计数加 `| wc -l`）。
  - **C3（台账演进）**：四个目标 commit 各一行，列为
    `短hash | lite-constraint-ledger.md 数据行数`。
    数据行数 = `git show <hash>:.tad/evidence/audits/lite-constraint-ledger.md |
    grep -c '^|'` 减去 `| grep -c '^|---'` 再减 1（表头行）；
    结果为负时记 `0`。该 commit 下文件不存在时记 `N/A(file-absent)`。
  验证：逐 commit 重跑 `git show --stat`；逐 slug 重跑 `find`；逐 commit 重跑 C3 命令。
  ⚠️ 三表**不得**跨表连线或标注对应关系。

- AC6: D 段列出 `.tad/archive/handoffs/LITE-*.md` 的**全部**文件，
  行数等于 `ls -1 .tad/archive/handoffs/LITE-*.md | wc -l`（当前为 5，以实跑为准）。
  每行给出：文件名 | `^Reviewer:` 行逐字原文 | 该行是否含 `model=` 子串（`YES`/`NO`）|
  `^P0=` 行逐字原文 | `^关键发现:` 行逐字原文。
  - ⚠️ 三个字段的判据均为**行首锚定**（`grep -n '^Reviewer:'` / `'^P0='` / `'^关键发现:'`）——
    「关键发现」一词在正文引文中也会出现（例：`core-closure.md` 第 147 行），
    非行首命中**不得**采用。
  - **截断口径**：超 **200 chars**（`wc -m`，非 bytes）时截断并以 `…[TRUNCATED]` 结尾。
    实测四条 `^关键发现:` 行为 148/136/105/140 chars（254/300/208/264 bytes），
    按 chars 口径**一条都不截断**——若报告出现截断，即口径用错。
  - 每个文件须附三个锚各自的 `grep -c` 原始输出作为载体；`grep -c` 得 N>1 时须列出全部 N 行并编号。
  - 任一字段零命中时写 `ABSENT`。
  - 所有非 `ABSENT`、非截断的逐字引用须能在对应文件内 `grep -F` 命中。
  验证：`ls | wc -l` 比对行数；逐文件重跑三个 `grep -c` 比对载体；逐引用 `grep -Fq`。

- AC7: 报告中**每一张数据表**的正上方有一个 ```bash 代码块，含产生该表全部数值的完整命令
  （可多行；须能在仓库根目录直接粘贴执行，不依赖未定义的 shell 函数或变量；
  注意 Bash 工具实跑的是 **zsh 5.9**，参数展开不分词）。
  验证：验收者逐块原样重跑，输出与表中数值一致。
  ⚠️ 注：本 AC 的验证由验收者手动重跑完成，无自动判据。
  AC2 的行集锁定与 AC3/AC6 的载体要求，正是为了不让本 AC 独自承担全部防线。

- AC8: **采样时刻 = Blake 的 L3.5 技术门**（早于 L5 归档 `mv`，故归档动作不受本 AC 约束）。
  在该时刻跑 `git status --short`，其路径集合中**不属于附录 B 基线**的每一条，
  必须匹配以下白名单之一：
  1. `.tad/evidence/audits/P4-measurements.md` — 本单交付物
  2. `.tad/active/handoffs/` — 本契约自身所在目录（git 对全未跟踪目录折叠显示，
     **不会**打印完整文件路径；基线中已含此行）
  3. `.tad/evidence/reviews/blake/p4-measurements/` — L3 独立审查载体
  4. `.tad/evidence/journal/` — 含 blake-lite 协议强制的 `lite-discoveries.md`
  5. `.tad/evidence/ralph-loops/` — 状态文件
  6. `.tad/evidence/acceptance-tests/p4-measurements/` — AC 证据
  7. `.tad/evidence/traces/*.jsonl`、`.tad/evidence/decisions/*.jsonl`、
     `.tad/active/precompact/`、`.tad/memory/` — 均由 hook 或 native memory 自动写入，
     不受 Blake 控制

  **黑名单（出现任何改动即立即 FAIL）**：`.claude/skills/`、`CLAUDE.md`、
  `.tad/active/epics/`、`.tad/hooks/`、`.claude/settings*.json`、
  `.tad/evidence/audits/lite-constraint-ledger.md`。
  附录 B 中已 dirty 的 5 个 tracked 文件须保持 `M` 状态（不得被 `git checkout` 或 `git add`）。
  **匹配语义**：白名单中**以 `/` 结尾**的条目按**路径前缀**匹配；**不以 `/` 结尾**的按**精确**匹配。
  （必要性：`git status --short` 对 tracked=0 的目录折叠成目录本身
  （`.tad/active/handoffs/`、`precompact/`、新建的 `p4-measurements/`），
  对已有 tracked 文件的目录则打印完整路径
  （`journal/` 21、`ralph-loops/` 34、`traces/` 66、`decisions/` 56、`.tad/memory/` 29）——
  两种形态并存，不定义语义则前者按前缀读、后者按精确读都会误判。）
  验证：`git status --short` 路径集合减去附录 B 基线，余下逐条比照白名单；再跑黑名单检查。
  ⚠️ 本单**禁止** `git add` / `git commit` / `git checkout --` / `git stash` 等任何改变
  索引或工作区状态的 git 写操作（血泪依据见「风险与注意」）。

---

### 附录 B — AC8 基线（**实跑产出**，HEAD = `88971ec`，含本契约文件已存在的状态）

```
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/tracked-after.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/untracked-after.txt
 M .tad/evidence/decisions/2026-08-05.jsonl
 M .tad/research-notebooks/REGISTRY.yaml
?? .tad/active/handoffs/
?? .tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-codex-home/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/
?? .tad/evidence/acceptance-tests/evidence-replayability-check/AC6.txt
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-alex.txt
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-blake.txt
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-tracked-after.sha
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-tracked-after.txt
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-untracked-after.txt
?? .tad/evidence/decisions/2026-08-04.jsonl
?? .tad/evidence/journal/evidence-replayability-check-2026-08-04.md
?? .tad/evidence/ralph-loops/lite-inventory-pricing-audit_state.yaml
?? .tad/evidence/ralph-loops/lite-pricing-gate-protocol_state.yaml
?? .tad/evidence/traces/2026-08-04.jsonl
?? .tad/evidence/traces/2026-08-05.jsonl
?? .tad/memory/feedback_cross-project-tracking-boundary.md
```

（AC8 只比对**路径集合**，不比对文件内容——trace / decisions / memory 类文件内容会自然增长。）

### 附录 C — 固定读取量纯路径清单（供 `sort | comm -3` 直接消费）

**C-1（alex 侧）**：
```
.claude/skills/alex-lite/SKILL.md
CLAUDE.md
~/.claude/CLAUDE.md
.tad/project-knowledge/principles.md
.tad/project-knowledge/patterns/_index.md
.tad/project-knowledge/testing.md
.tad/project-knowledge/ux.md
.tad/project-knowledge/performance.md
.tad/project-knowledge/api-integration.md
.tad/project-knowledge/mobile-platform.md
.tad/project-knowledge/frontend-design.md
.tad/brain-index.md
.tad/memory/MEMORY.md
```

**C-2（blake 侧）**：与 C-1 相同，仅第 1 行换为 `.claude/skills/blake-lite/SKILL.md`。

（比对时两侧均按 **`LC_ALL=C sort`** 排序后 `comm -3`——默认 locale 下 `~` 与 `C` 次序相反。
`~/.claude/CLAUDE.md` 在此**保持字面量**，仅用于比对与表格显示；
**实际取值必须用 `"$HOME/.claude/CLAUDE.md"`**，否则 `test -f` / `wc` 必然失败。
报告表格中的路径写法须与此处逐字一致。）

## 知识引用

- `.tad/project-knowledge/patterns/ac-verification.md` §`Verification Strength Is Bounded by
  the Deliverable's Determinacy` — 交付物含自由文本时任何 AC 都堵不住伪造；本单据此把
  「结论/判断」整体移出执行方 scope。
  ⚠️ **该条 Action 的后半句本单无法照搬**：它建议「对确定部分优先整体字节比对而非 property check」，
  但 A/B/C/D 四段的交付物是**待生成物**，不存在可 md5 的 ground truth。
  本单采用的等价强度替代是：**锁死表的形状**（行数 + 标题逐行逐字 + 顺序），
  只留数值一个自由度，再由 AC7 重跑锁死数值。v1 的失败正是只锁了和式（出口）没锁行集（入口）。
- `.tad/project-knowledge/patterns/gate-design.md` §`Claims Need Carriers` — 只存在于对话里的
  claim 对下游验证器不可见；本单每个数字都必须有 on-disk 载体（报告文件）+ 存在性 AC，
  且 MISSING 标记、`grep -c` 计数均须附原始输出作为载体。
- `.tad/project-knowledge/patterns/gate-design.md` §`Independent Perspective Lives in Clean
  Context`（含 2026-08-05 AMENDED）— fresh-context reviewer 是 lite 砍掉路由机器后仅存的
  质量内核；D 段正是为核验这条内核是否真的在历史单上运转过而设。
- `.tad/project-knowledge/principles.md` §`Measure Before Optimizing` — 先量基线再设计优化；
  本单存在的理由就是补上 Epic 从未测过的基线。**v1 的 P1-5 是本条的现场复发**：
  固定读取清单漏了 `.tad/memory/MEMORY.md`（7,949 bytes）与用户全局 `CLAUDE.md`，
  一份专为定基线而写的契约，基线本身低估约 20%。

## Contract Review (2026-08-05)

Reviewer: code-reviewer subagent (fresh context) | model=claude-opus-5[1m] | route=unknown
首轮 verdict: **FAIL**（v1，P0=4 / P1=6 / P2=4）
增量复核 (2026-08-05): **CONDITIONAL**（v2，P0=1 / P1=3 / P2=3），覆盖 v1→v2 全部变更；
v1 的 4 个 P0 经实地复核**确认闭合**（附录 B 与 reviewer 实跑逐行一致、13/21 行数与和式独立复算成立）
最终 verdict: **PASS**（v3 —— reviewer 列出的 4 条放行条件已全部写入，其 3 条 P2 亦同批带入；
reviewer 明示"以上 4 条写入后即可判 PASS，无需再轮完整复核"）
P0=4(fixed), P1=6(fixed) + 3(v2, fixed), P2=4+3(adopted); 已审 AC 条数: 8

**v1 关键发现（全部实测证据支撑，全部采纳）**：
- **P0-1 / AC2 锁出口未锁入口**：单行 `__PREAMBLE__` 退化表满足全部四个和式，
  且 AC7 人工重跑会**确认其正确** → A 段归零，30 秒。v2 修法：锁行数（13/21）+ 标题逐行 `diff`。
- **P0-2 / AC4 编号与引用不绑定**：三任务全写「兜底」+ 全引兜底句即通关，1 分钟，B 段归零；
  且掩盖了真实缺口——**T3（`.tad/active/epics/`）实为「未命中」任何清单条目**。
  v2 修法：路径×条目矩阵 + 编号-引用强绑定 + 「未命中」须逐条列 4 条原文并说明。
- **P0-3 / AC8 基线未经实跑**：v1 附录 B 系手抄自建档前的输出，缺 `?? .tad/active/handoffs/`
  （git 折叠全未跟踪目录），而白名单写的是完整文件路径 → 对任何执行者必然 FAIL；
  另漏 ` M .tad/evidence/decisions/2026-08-05.jsonl`（tracked 数实为 5 非 4）与
  `?? .tad/memory/feedback_*.md`（未被 gitignore）。v2 修法：实跑取基线 + 白名单改目录 + 补 `.tad/memory/`。
- **P0-4 / 白名单与 blake-lite 协议正面冲突**：协议强制 append 的
  `.tad/evidence/journal/lite-discoveries.md` 不含 `p4-measurements` 串 → 守协议即 FAIL；
  `acceptance-tests/<slug>/` 亦未覆盖。v2 修法：白名单放宽到目录级 + 明确采样时刻为 L3.5。
- **P1-1 / `wc -c -m` 在 BSD 上互斥且静默**（只出 chars）→ bytes 列会被填成 chars 值，
  而两者恰差 1.85 倍，正是本单要澄清的那个差异。v2 修法：口径写死「必须分两次调用」。
- **P1-2 / AC6「200 字符」口径未定**：实测四条 `^关键发现:` 行按 chars 全不截断、
  按 bytes 全截断，两个诚实执行者 100% 分歧。v2 修法：明确 200 chars（`wc -m`）+ 给出实测值反校验。
- **P1-3 / AC3 不校验 MISSING 真伪**（全标 MISSING 可通关）→ v2 要求附 `test -f` 原始输出。
- **P1-4 / `comm -3` 无可消费的清单形式**（口径表首行含中文括号注释）→ v2 新增附录 C 纯路径清单。
- **P1-5 / 固定读取清单漏 2 个 harness 自动加载文件** → v2 扩为 13 行 + 双合计行 + 不可测量项留口。
- **P1-6 / §文件清单「修改 0 个」与 AC8 白名单不一致**（L3 reviewer 会据此误报 scope-violation）
  → v2 改为指向白名单。
- P2-1（`grep -c` 载体）、P2-2（C3 补命令）、P2-4（引用行 `## ` 污染 AC1）均已采纳；
  P2-3 由 P0-2 的绑定条款解决。

**v2 增量复核发现（全部采纳，已写入 v3；数值经 Alex 独立复算确认）**：
- **NEW-P0-A / `~` 在引号与变量中不展开**：`p='~/.claude/CLAUDE.md'; test -f "$p"` 在 zsh 下
  实测返回 `MISSING`，而文件真实存在（927 B / 499 chars）→ v2 为修 P1-5 新加的第 3 行
  执行时归零，**基线再次低估 927 B**，且带一个"照实报告的 MISSING"作掩护，比 v1 的直接遗漏更难发现。
  v3 修法：取值口径写死 `"$HOME/..."`，`~` 仅用于显示与字面比对，并加反校验数值。
- **NEW-P1-B / collation 未固定**：默认 UTF-8 locale 与 `LC_ALL=C` 下 `~`(0x7E) 与 `C`(0x43)
  次序**相反**（已复现），`comm` 收到非同序输入输出未定义 → AC3 假 FAIL 或掩盖真差异。
  v3 修法：统一 `LC_ALL=C sort`。
- **NEW-P1-C / AC2 未锁单行数值**：「全文数值压进 `__PREAMBLE__`、其余 12 行填 0」
  可同时通过行数、标题、和式三项判据，且配 `for i in {1..12}; do echo 0; done` 的命令块
  **还能通过 AC7 人工重跑**。v3 修法：写死 canary（alex 209/119、blake 195/135）+ 两文件全文值。
- **NEW-P1-D / AC4 只锚 T3**：「三任务全写未命中 + 全列 4 条原文」仍逐条合规，
  产出页面自相矛盾却全绿的报告。v3 修法：T1=`3`、T2=`1`、T3=`未命中` 三者同等锚定。
- NEW-P2-E（白名单 `/` 结尾按前缀、否则精确——git 对 tracked=0 目录折叠、
  对有 tracked 文件的目录打印完整路径，两种形态并存）、
  NEW-P2-F（`MEMORY.md` 既被测量又可被 native memory 改写 → 附 `md5`/`stat` 载体）、
  NEW-P2-G（写死标题列提取命令）均已采纳。
- reviewer 同时指出本单「公布答案」与 `ac-verification.md` L234
  *"Never let an AC publish the query whose answer it will accept"* 冲突；
  v3 在「风险与注意」中显式记录该取舍及其**适用边界**（仅当答案独立重算成本近乎为零时成立）。

## 风险与注意

- **caller/consumer 检查结论**：本单只创建 1 个全新 evidence 文件
  （`.tad/evidence/audits/P4-measurements.md`），不修改任何已有文件、不定义任何被引用的符号、
  不改动协议/配置/hook。**已确认该路径当前不存在**（`test -f` 为假），故无既有消费方。
  依 Scope / Risk Router，此类新建-无消费方的改动无需做 grep 消费方采样——
  此处显式记录该判断的依据，而非默认「无下游影响」。

- **口径差异是本单最大发现，也是最大误读风险**：历史记录的 45,144 / 57,837 是**字节**，
  而 Epic SC1 写的是**字符**。两口径差约 1.85 倍。Blake **不得**在报告中挑选或换算口径，
  必须双列并陈；任何一方口径的取舍是验收时的人域判断。

- **git 写操作禁令的血泪依据**：2026-08-05 本 Epic 执行中，一次 `git checkout -- NEXT.md`
  （本意是"还原探针"）**销毁了用户 28 行未提交的工作**，靠一份偶然存在的 `/tmp` 副本才救回。
  本单全程只读，没有任何需要动 git 索引/工作区的理由；AC8 的 git 写操作禁令是硬约束。
  需要临时文件一律用 `/tmp` 下**本单专属**的路径（含 `p4-measurements` slug，避免与其它单碰撞——
  同日曾发生固定 `/tmp` 路径被另一 session 覆盖导致数百条假违规）。

- **AC2 切分方法已实地验证可行**（设计侧空跑）：`grep -n '^## '` 取节起始行号 →
  `sed -n 'a,bp' | wc -c` / `wc -m` 逐节计量 → 和式与整文件 `wc` 精确相等
  （alex-lite 实测 bytes=20846 chars=11145，两侧一致）。
  Blake 可用任何等效方法，但**必须**在报告中给出实际使用的命令并使四个等式与行集约束同时成立。

- **B 段是推演不是实测**：它只能证明「清单会不会拦」，不能证明「拦了之后 lite 还能不能干活」。
  这是用户 2026-08-05 明确选择的范围（选项：只读推演，不真动）。后者留待单独一单。

- **B 段三个任务的预期答案已全部锚定**（依据：`sed` 取出的 7 行 ESCALATION 区块逐字核验）：
  - **T1 预期 = `3`**：`.tad/hooks/<新 hook 文件>` 与 `.claude/settings.json` **两行均**命中条目 3
    （原文含 `.tad/hooks/`、`.claude/settings*.json`）。
  - **T2 预期 = `1`**：条目 1 原文含 `release·publish·sync`。
  - **T3 预期 = `未命中`**：`.tad/active/epics` 在区块内出现次数为 **0**，
    不在条目 1/2/3 任一条文中。这是 P2+P3 砍除路由机器后的真实边界变化，**不是错误**。
  三者与预期不符时，须在报告中显式给出差异论证，**不得静默按实测填**，
  也不得为「凑一个命中」或「全写未命中」而扭曲判定。
  ⚠️ 三个都锚定（而非只锚 T3）的理由：只锚 T3 时，「三任务全写未命中 + 全列 4 条原文」
  仍能逐条满足 AC4 的全部判据，产出一份页面自相矛盾却全绿的报告。

- **本单刻意「公布了答案」，这是有边界的取舍**：缺失集 5 个、`148/136/105/140` chars、
  T1/T2/T3 预期、13/21 行、canary 209/119 与 195/135、区块 7 行、archive 5 个文件——
  这与所引条目 `ac-verification.md` L234 的 *"Never let an AC publish the query whose answer
  it will accept"* 直接冲突。本单认为该取舍成立，**理由是这些量廉价可重跑**：
  公布答案省下的不是伪造者的成本（他本来也能十秒跑出），而是两个诚实执行者的分歧。
  **适用边界：仅当答案的独立重算成本近乎为零时才可这么做**；答案昂贵时公布即等于送分。
  代价是 A 段的 34 行逐节测量成了报告里唯一还需真干活的部分，防线集中于一处——
  canary 正是为此而设。

- **AC7 无自动判据**：命令可重跑性由验收者手动逐块执行确认。这是诚实留口，
  不假装它是机械门。但 v2 已把 AC2 行集、AC3 `test -f` 载体、AC6 `grep -c` 载体
  加为独立机械判据，AC7 不再是唯一防线。

- **本单不产生任何结论**，因此 Gate 之后必然还需要一次人机对话来定 SC1、领地、reviewer 三事。
  这是设计使然（把判断留在人域），不是交付不完整。

## Lite Progress

Phase=admission | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/p4-measurements/ | Next Action=L0.5/L0.75 已过，进 L1
Phase=implement | 改动文件=交付物 P4-measurements.md + 2 采集脚本(证据目录) | 最后 AC=— | 下一动作=L2 AC 自验 | 阻塞/错误类别=无 | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/audits/P4-measurements.md | Next Action=AC1-AC8 逐条自验
Phase=ac | 改动文件=P4-measurements.md（补 4 个矩阵/canary 代码块） | 最后 AC=AC7 全绿 | 下一动作=L3 独立审查 | 阻塞/错误类别=无（验证脚本自身引号/状态机 bug 已就地修） | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/p4-measurements/ac-results.md | Next Action=spawn code-reviewer
Phase=review | 改动文件=reviews/blake/p4-measurements/code-reviewer.md（落盘）+ 交付物 P2-1 措辞 | 最后 AC=AC8 全绿 | 下一动作=L3.5 技术门 | 阻塞/错误类别=无（reviewer 未落盘载体→Blake 补落盘，Claims-Need-Carriers） | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/reviews/blake/p4-measurements/code-reviewer.md | Next Action=L3.5 五项 + L4
Phase=technical-gate | 改动文件=—（无新改动） | 最后 AC=AC8 | 下一动作=L4 Completion | 阻塞/错误类别=无 | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/p4-measurements/ac-results.md + reviews/blake/p4-measurements/code-reviewer.md | Next Action=L4 append + L5 交付

## Completion (2026-08-05)

**Commit**: uncommitted（契约 §不做什么 明令禁 git 写操作；是否 commit 由人验收后决定）
**Model**: harness=claude-code | model=deepseek-v4-flash | route=api.deepseek.com (alias-mapped；`ANTHROPIC_BASE_URL` env 实测；`~/.claude/settings.json` 的 opus[1m] 被 `ANTHROPIC_MODEL` env 覆盖，实际运行模型 = deepseek-v4-flash)

- 上下文刷新：已读 knowledge 路径 = handoff 全文 + `.tad/project-knowledge/patterns/ac-verification.md`（Verification Strength 条目）+ `.tad/project-knowledge/patterns/gate-design.md`（Claims Need Carriers / Independent Perspective + AMENDED 2026-08-05）+ principles.md（CLAUDE.md @import 自动加载）| 关键约束：只测量不下结论；双口径 bytes+chars（`wc -c`/`-m` 分两次调用）；`$HOME` 取值；B 段预期锚定 T1=3/T2=1/T3=未命中；禁 git 写操作 | 成功条件：AC1-AC8 全绿 + reviewer PASS
- 改动文件：`.tad/evidence/audits/P4-measurements.md`（交付物，创建）+ `.tad/evidence/acceptance-tests/p4-measurements/`（collect-sections.zsh / collect-fixed-reads.zsh / ac-results.md，AC8 白名单 6）+ `.tad/evidence/reviews/blake/p4-measurements/code-reviewer.md`（AC8 白名单 3）+ `.tad/evidence/journal/lite-discoveries.md`（append 一行，AC8 白名单 4）+ 本 handoff 的 Lite Progress / Completion（白名单 2）。全部在白名单内，无 [清单外]
- AC 结果（全部 ✅，证据 .tad/evidence/acceptance-tests/p4-measurements/ac-results.md + 本单执行输出）：
  - AC1 ✅ `grep -c '^## '` = 5，标题逐字匹配（L6/81/219/293/342）
  - AC2 ✅ 数据行 13/21；标题 diff 双空；collect-sections.zsh 重跑 diff 0；四和式成立（20846/11145、24298/13243）；canary 209/119、195/135 命中
  - AC3 ✅ 行集两侧 comm -3 空；双合计 == awk 重算（alex 74303/60122、75230/60621；blake 77755/62220、78682/62719）；MISSING 恰 5 且 test -f 载体真实；`$HOME` 反校验 927/499；MEMORY.md 载体 md5 b9e5e270…/stat 1785805028 7949；不可测量项段在 A 段内
  - AC4 ✅ 区块 7 行；6 条引用 grep -F 全 HIT；编号绑定 T1→3. / T2→1. / T3→4 条全列；判定与预期锚定一致
  - AC5 ✅ C1（27/2477/0、39/7342/33、29/3409/6、28/2315/568）、C2（各 2 文件）、C3（0/0/0/3）逐条重跑一致；三表不连线
  - AC6 ✅ 5 文件 = ls 实测；三锚 grep -c 载体与报告一致（dogfood 全 ABSENT）；12 条引用 grep -Fq 全 HIT；关键发现 148/136/105/140 chars 全不截断；model= 全 NO
  - AC7 ✅ 12 张数据表上方代码块全覆盖（awk 检查 12/12 OK）+ 逐块重跑输出与表值一致
  - AC8 ✅ 基线外新增恰 3 条（acceptance-tests/p4-measurements/ 白名单 6 前缀、audits/P4-measurements.md 白名单 1 精确、reviews/blake/p4-measurements/ 白名单 3 前缀）；黑名单干净；基线 5 个 M 保持；全程无 git 写操作
- Reviewer: **PASS** | model=deepseek-v4-flash（fresh-context 独立 spawn，未传 model override），P0=0, P1=0, P2=2。关键发现摘录（执行实证）：「数字全部真实、口径全部正确、B 段判定与契约预期锚定完全一致（T1=3 / T2=1 / T3=未命中）、报告无任何越界的结论/建议/评价语句、AC8 白名单语义执行时完全可判定且无越权」；两个对抗探针（AC2 退化表、AC4 未绑定引用）证实防线有效。P2-1（措辞）已采纳修复；P2-2（标题列模板占位符，契约原文）不采纳记 follow-up。
- Technical Gate: **GATE PASS**（① AC1-AC8 全有原始输出与证据路径 ② reviewer PASS/P0=0/P1=0 ③ friction 无 BLOCKED（classifier 全程可用）④ 改动限于契约清单，caller/consumer 判断依据记录于 handoff §风险与注意 ⑤ Knowledge Assessment = journal captured）
- Knowledge Assessment: journal captured（`.tad/evidence/journal/lite-discoveries.md` 追加 1 行：验证脚本自身三连坑）
- 意外发现：机械验证脚本自身的引号/正则/状态机三连坑（zsh 双引号内反引号被命令替换、awk `|` 未转义被当 alternation、lastnb 变量时序、附录代码块提取须取第一/第二 ``` 之间）——验证工具本身也要 dry-run；已就地修，记 journal。
- follow-up：
  - P2-2（验收者处置）：报告"标题列提取命令"代码块含 `<表片段>`/`<file>` 占位符，字面上不可直接粘贴执行——契约原文写死的验证模板（handoff §节切分口径），非本单实现缺陷；改它即偏离契约。建议 owner=Alex，验收时决定是否在契约修订中处理。
  - 固定读取量减重实测已出（57,837→**blake 侧项目内 62,220 chars / 实际注入 62,719 chars** 等，详见交付物 A 段），SC1 目标 ≤20,000 的差距量化待验收人域判断——本单不结论。
  - D 段：5 个归档 LITE 单中 1 个（dogfood-throwaway，最早的单）三锚全 ABSENT（无 Contract Review 段）——仅记录，判定归验收。

## Reflexion

- P2-1 措辞修复：失败=reviewer 指出"下方逐字引用"暗示完整 7 行区块被引用 / 假设=措辞在上下文中无歧义 / 动作=改为"下方逐条引用条目 1/2/3 与兜底句原文，区块全文由上方代码块产出" / 结果=措辞精确化，AC1-AC7 重跑不受影响（无 ## 行新增、无表格变化）
- 验证脚本自身三连坑（就地修，非交付物缺陷）：失败=附录 C 提取 154 行垃圾、comm 前缀误判、表格覆盖检查 FAIL / 假设=脚本逻辑正确只是命令写法问题 / 动作=状态机取第一/第二 ``` 之间、awk `\|` 转义、lastnb2 双层变量、zsh 单引号包 awk 程序 / 结果=全部验证命令跑通，与 reviewer 独立重跑一致
- reviewer 载体未自动落盘：失败=L3 完成后 git status 无 reviews 载体条目 / 假设=reviewer 会写文件 / 动作=Blake 按其返回报告落盘 .tad/evidence/reviews/blake/p4-measurements/code-reviewer.md（Claims-Need-Carriers）/ 结果=AC8 白名单 3 覆盖，载体齐全
Phase=human-gate | 改动文件=— | 最后 AC=— | 下一动作=等 L5 人验收 | 阻塞/错误类别=无 | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=同上 | Next Action=人验收 → 归档（本单不 commit）
