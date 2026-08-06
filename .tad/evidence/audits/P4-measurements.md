# P4 Measurements（LITE-20260805-2259-p4-measurements 交付物）

> 本报告只含：数字、产生数字的命令、逐字引用、以及 B 段被契约授权且被验证器绑定的清单条目编号判定。
> 不含任何结论、建议、评价或成因分析。结论由人在验收时根据数字作出。

## 口径与命令

### 双口径

每个体量数字同时给 `bytes` 与 `chars` 两列。本仓库正文以中文为主，CJK 一字符 = 3 字节，
两口径相差约 1.85 倍。本报告不解释此差异，只并列两数。

⚠️ macOS/BSD `wc` 的 `-c` 与 `-m` 互斥且不报错（`wc -c -m file` 只输出 chars 一列）。
全部测量分两次调用：`wc -c < file` 取 bytes，`wc -m < file` 取 chars。

⚠️ `~` 在引号与变量中不展开（Bash 工具实跑 zsh 5.9）。取值一律用 `"$HOME/.claude/CLAUDE.md"`；
`~/.claude/CLAUDE.md` 仅用于报告表格显示与附录 C 字面比对。反校验：
`~/.claude/CLAUDE.md` 实测 **927 bytes / 499 chars**，与全局 CLAUDE.md 表行一致。

### 节切分口径（A 段逐节表用）

以行首 `## `（两个井号 + 空格）为节起点。文件开头到第一个 `## ` 之前的内容记为伪节
`__PREAMBLE__`。两个 skill 文件的代码围栏数均为 0（`grep -c '^```'` 实测），
不存在「`## ` 落在代码块内」的歧义，切分完全确定。

**表形状（契约锁死）**：`alex-lite/SKILL.md` 恰 13 个数据行（12 个 `^## ` 节 + `__PREAMBLE__`）
+ 1 合计行；`blake-lite/SKILL.md` 恰 21 个数据行（20 个 `^## ` 节 + `__PREAMBLE__`）+ 1 合计行。
数据行顺序 = 文件出现顺序，`__PREAMBLE__` 在最前。

**canary（契约写死，不符即口径用错）**：

```bash
wc -c < .claude/skills/alex-lite/SKILL.md; wc -m < .claude/skills/alex-lite/SKILL.md
wc -c < .claude/skills/blake-lite/SKILL.md; wc -m < .claude/skills/blake-lite/SKILL.md
zsh .tad/evidence/acceptance-tests/p4-measurements/collect-sections.zsh | grep -E '__PREAMBLE__'
```

| 文件 | `__PREAMBLE__` | 全文 |
|---|---|---|
| `alex-lite/SKILL.md` | 209 bytes / 119 chars | 20846 bytes / 11145 chars |
| `blake-lite/SKILL.md` | 195 bytes / 135 chars | 24298 bytes / 13243 chars |

实测与 canary 完全一致（见 A 段逐节表）。

**标题列提取命令**（契约写死，免验收者自造；32 个节标题均不含 `|` 已核验）：

```bash
awk -F'|' 'NR>2 && $2 !~ /合计/ {gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}' <表片段> \
  | diff - <(grep -n '^## ' <file> | sed 's/^[0-9]*://')
```

### 固定读取量口径（A 段用）

定义 = 一次冷启动 `/alex-lite`（或 `/blake-lite`）从激活到 L2 落盘前必读的文件全集。
构成清单固定为 13 行，一行不得少、不得多；不存在的文件留行并标 `MISSING`（bytes/chars 记 `0`）。
已知缺失集固定为 5 个（`.tad/project-knowledge/` 下 testing / ux / performance / api-integration /
mobile-platform），逐个用 `test -f` 实测并把原始输出作为载体（见 A 段）。

两个合计行（必须都给）：
- `合计-项目内`：排除第 3 项（用户全局 `~/.claude/CLAUDE.md`）后的各行之和
- `合计-实际注入`：全部 13 行之和

分两个合计的理由：用户全局文件是否计入「TAD 的固定读取量」是口径选择，属人域判断，
本单不替人做选择，只把两种口径都摆出来。

**已知不可测量项（诚实留口，不计入合计）**：
SessionStart / PreCompact 等 hook 向上下文注入的文本、harness 自身的 skill 描述与工具 schema、
以及 `<system-reminder>` 类注入。这些无文件载体，本单无法测量。

### 假想任务（B 段用，固定三条）

- **T1**：给 `.tad/hooks/` 新增一个 PostToolUse hook，记录每张 LITE 单的 token 用量；
  同时在 `.claude/settings.json` 注册该 hook。
- **T2**：执行 `*publish`，把 TAD v2.40.0 发布到 GitHub 并同步到下游项目。
- **T3**：为下一批多阶段工作在 `.tad/active/epics/` 创建一个新的 `EPIC-*.md` 协调文件。

### 回算目标（C 段用）

**commit（固定四个）**：`4b29dc2`、`910ab6c`、`d948585`、`88971ec`
**slug（固定四个）**：`lite-pricing-gate-protocol`、`pricing-gate-scan-fix`、
`lite-inventory-pricing-audit`、`cut-routing-machinery`

C 段三张表互不声称对应关系：commit 与 slug 之间不是一一对应
（例：`4b29dc2` 未改动任何 handoff 文件；`d948585` 顺带归档了上一单的 COMPLETION）。
本报告不建立这种对应关系，也不跨表连线。

## A 体量分解

**已知不可测量项（原样列出）**：
SessionStart / PreCompact 等 hook 向上下文注入的文本、harness 自身的 skill 描述与工具 schema、
以及 `<system-reminder>` 类注入。这些无文件载体，本单无法测量。

### alex-lite/SKILL.md 逐节表

```bash
zsh .tad/evidence/acceptance-tests/p4-measurements/collect-sections.zsh
```

| 节标题 | bytes | chars |
|---|---|---|
| __PREAMBLE__ | 209 | 119 |
| ## 身份 | 1071 | 495 |
| ## Lite-First 政策（默认通道，不可妥协） | 727 | 385 |
| ## 共享记忆契约（与 blake-lite 逐字相同） | 1549 | 863 |
| ## L0-pre 命名消歧 | 187 | 103 |
| ## 执行脊柱 | 6889 | 3891 |
| ## Lite Progress（轻量恢复检查点） | 1029 | 621 |
| ## Scope / Risk Router（影响范围与风险） | 598 | 266 |
| ## Knowledge Closeout（验收后知识闭环） | 980 | 568 |
| ## 精髓（不可妥协的四条） | 371 | 193 |
| ## 跨角色请求消歧 | 1096 | 531 |
| ## 约束准入（新增约束前必须定价） | 5108 | 2534 |
| ## Forbidden | 1032 | 576 |
| 合计 | 20846 | 11145 |

### blake-lite/SKILL.md 逐节表

```bash
zsh .tad/evidence/acceptance-tests/p4-measurements/collect-sections.zsh
```

| 节标题 | bytes | chars |
|---|---|---|
| __PREAMBLE__ | 195 | 135 |
| ## 身份 | 116 | 74 |
| ## Lite-First 政策（默认通道，不可妥协） | 727 | 385 |
| ## 共享记忆契约（与 alex-lite 逐字相同） | 1548 | 862 |
| ## L0 读契约 + 准入（⚠️ BLOCKING） | 1573 | 901 |
| ## L0.5 契约审查复查（所有 LITE 单 ⚠️ BLOCKING） | 973 | 565 |
| ## L0.75 有界上下文刷新（⚠️ BLOCKING） | 681 | 371 |
| ## Lite Progress（轻量恢复检查点） | 1018 | 610 |
| ## Scope / Risk Router（影响范围与风险） | 594 | 278 |
| ## L1 实现 | 430 | 206 |
| ## L2 AC 自验 | 682 | 306 |
| ## L3 独立审查（⚠️ MANDATORY——express 教训：小改不等于免审，2026-04-14 一次 15 分钟小改被审出 4 个 P0。此步不可以任何理由跳过） | 2539 | 1329 |
| ## L3.5 Lite Technical Gate（⚠️ BLOCKING） | 1198 | 642 |
| ## Lite Repair Loop（有限修复与熔断） | 659 | 349 |
| ## Honest Partial（诚实部分完成） | 828 | 426 |
| ## 七态状态词 | 351 | 273 |
| ## L4 Completion（append 到 LITE handoff 文件末尾） | 1997 | 1267 |
| ## L5 STOP — 人验收 + 归档 | 810 | 496 |
| ## 跨角色请求消歧 | 1096 | 531 |
| ## 约束准入（新增约束前必须定价） | 5108 | 2534 |
| ## Forbidden | 1175 | 703 |
| 合计 | 24298 | 13243 |

### 固定读取量（alex 侧）

```bash
zsh .tad/evidence/acceptance-tests/p4-measurements/collect-fixed-reads.zsh alex
```

| 路径 | bytes | chars | 来源分类 |
|---|---|---|---|
| .claude/skills/alex-lite/SKILL.md | 20846 | 11145 | skill 本体 |
| CLAUDE.md | 5569 | 3721 | 项目 CLAUDE.md（harness 自动加载） |
| ~/.claude/CLAUDE.md | 927 | 499 | 用户全局 CLAUDE.md（harness 自动加载） |
| .tad/project-knowledge/principles.md | 23637 | 22533 | CLAUDE.md @import |
| .tad/project-knowledge/patterns/_index.md | 2215 | 2193 | CLAUDE.md @import |
| .tad/project-knowledge/testing.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/ux.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/performance.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/api-integration.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/mobile-platform.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/frontend-design.md | 3609 | 3594 | CLAUDE.md @import |
| .tad/brain-index.md | 10478 | 9920 | L1.5 共享知识预检强制读索引 |
| .tad/memory/MEMORY.md | 7949 | 7016 | native auto-memory（CLAUDE.md §7.5 重定向） |
| 合计-项目内 | 74303 | 60122 | 排除第 3 项后的各行之和 |
| 合计-实际注入 | 75230 | 60621 | 全部 13 行之和 |

**MISSING 行载体**（`test -f` 原始输出，5 行全 MISSING，与清单预期一致）：

```bash
for p in .tad/project-knowledge/testing.md .tad/project-knowledge/ux.md \
         .tad/project-knowledge/performance.md .tad/project-knowledge/api-integration.md \
         .tad/project-knowledge/mobile-platform.md; do \
  test -f "$p" && echo "EXISTS $p" || echo "MISSING $p"; done
```

```
MISSING .tad/project-knowledge/testing.md
MISSING .tad/project-knowledge/ux.md
MISSING .tad/project-knowledge/performance.md
MISSING .tad/project-knowledge/api-integration.md
MISSING .tad/project-knowledge/mobile-platform.md
```

**易变行载体**（`.tad/memory/MEMORY.md` 由 native memory 自动写入，附测量时刻快照）：

```bash
md5 -q .tad/memory/MEMORY.md; stat -f '%m %z' .tad/memory/MEMORY.md
```

```
b9e5e270696c042b073619d30847b067
1785805028 7949
```

### 固定读取量（blake 侧）

```bash
zsh .tad/evidence/acceptance-tests/p4-measurements/collect-fixed-reads.zsh blake
```

| 路径 | bytes | chars | 来源分类 |
|---|---|---|---|
| .claude/skills/blake-lite/SKILL.md | 24298 | 13243 | skill 本体 |
| CLAUDE.md | 5569 | 3721 | 项目 CLAUDE.md（harness 自动加载） |
| ~/.claude/CLAUDE.md | 927 | 499 | 用户全局 CLAUDE.md（harness 自动加载） |
| .tad/project-knowledge/principles.md | 23637 | 22533 | CLAUDE.md @import |
| .tad/project-knowledge/patterns/_index.md | 2215 | 2193 | CLAUDE.md @import |
| .tad/project-knowledge/testing.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/ux.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/performance.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/api-integration.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/mobile-platform.md | 0 | 0 | CLAUDE.md @import（MISSING） |
| .tad/project-knowledge/frontend-design.md | 3609 | 3594 | CLAUDE.md @import |
| .tad/brain-index.md | 10478 | 9920 | L1.5 共享知识预检强制读索引 |
| .tad/memory/MEMORY.md | 7949 | 7016 | native auto-memory（CLAUDE.md §7.5 重定向） |
| 合计-项目内 | 77755 | 62220 | 排除第 3 项后的各行之和 |
| 合计-实际注入 | 78682 | 62719 | 全部 13 行之和 |

（blake 侧 MISSING 载体与 MEMORY.md 载体同 alex 侧：缺失集与采样时刻一致，不重复贴。）

## B 领地只读推演

推演口径：只对「路径 vs 清单条文」做文本匹配，不执行假想任务的任何动作。
判定基准 = `.claude/skills/alex-lite/SKILL.md` 的 ESCALATION 区块（实测 7 行；下方逐条引用条目 1/2/3 与兜底句原文，区块全文由上方代码块产出）。

```bash
sed -n '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/p' .claude/skills/alex-lite/SKILL.md
```

### T1：给 `.tad/hooks/` 新增 PostToolUse hook + 在 `.claude/settings.json` 注册

**(a) 路径×条目矩阵**：

```bash
sed -n '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/p' .claude/skills/alex-lite/SKILL.md | grep -F '3. 全局注册面'
```

| 路径 | 命中条目编号 |
|---|---|
| .tad/hooks/<新 hook 文件> | 3 |
| .claude/settings.json | 3 |

**(b) 任务级汇总**：`3`

**(c) 逐字引用（与 (a)(b) 绑定）**：

> 3. 全局注册面：.tad/hooks/、.claude/settings*.json —— 注册后全 session 生效且无回滚验证

命中说明：`.tad/hooks/<新 hook 文件>` 路径落在 `3.` 原文的 `.tad/hooks/` 范围内；
`.claude/settings.json` 落在 `3.` 原文的 `.claude/settings*.json` 范围内（通配 `*` 覆盖无版本后缀的写法）。

### T2：执行 `*publish` 发布到 GitHub 并同步下游

**(a) 路径×条目矩阵**：

```bash
sed -n '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/p' .claude/skills/alex-lite/SKILL.md | grep -F '1. 不可逆操作'
```

| 路径 | 命中条目编号 |
|---|---|
| *publish 执行面（GitHub 发布 + 下游同步操作） | 1 |

**(b) 任务级汇总**：`1`

**(c) 逐字引用（与 (a)(b) 绑定）**：

> 1. 不可逆操作：支付/认证/批量数据删除/生产部署配置/依赖升级(lockfile、版本 pin)/release·publish·sync/破坏性 VCS(force-push、删分支、改历史)

命中说明：`*publish` 操作本身落在 `1.` 原文的 `release·publish·sync` 范围内。

### T3：在 `.tad/active/epics/` 创建新的 EPIC-*.md 协调文件

**(a) 路径×条目矩阵**：

```bash
sed -n '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/p' .claude/skills/alex-lite/SKILL.md | grep -cF '.tad/active/epics'
```

| 路径 | 命中条目编号 |
|---|---|
| .tad/active/epics/EPIC-*.md（新建协调文件） | 未命中 |

**(b) 任务级汇总**：`未命中`

**(c) 逐字引用（未命中：逐条列出 4 条原文 + 各自为何不命中）**：

> 1. 不可逆操作：支付/认证/批量数据删除/生产部署配置/依赖升级(lockfile、版本 pin)/release·publish·sync/破坏性 VCS(force-push、删分支、改历史)

为何不命中：创建 `.tad/active/epics/EPIC-*.md` 不属于支付/认证/批量数据删除/生产部署配置/
依赖升级/release·publish·sync/破坏性 VCS 中的任一操作——路径与条文范围无重叠。

> 2. SAFETY 面：.tad/project-knowledge/principles.md、patterns/ 中标 SAFETY 的条目、patterns/_index.md、本清单自身

为何不命中：SAFETY 面仅指 principles.md、patterns/ 中标 SAFETY 的条目、patterns/_index.md 与本清单
自身四者；`.tad/active/epics/` 不在其列。

> 3. 全局注册面：.tad/hooks/、.claude/settings*.json —— 注册后全 session 生效且无回滚验证

为何不命中：全局注册面仅指 `.tad/hooks/` 与 `.claude/settings*.json` 两处；`.tad/active/epics/` 不在其列。

> 兜底：无法确信影响面 → 停，请人裁定。

为何不命中：创建 EPIC 协调文件的影响面明确（仅被 TAD 流程消费的协调文件，无既有消费方），
不存在「无法确信影响面」的情形。

## C 闸的历史回算

三张表互不连线：不建立 commit ↔ slug 之间的任何对应关系。

### C1 — commit 体量

```bash
for h in 4b29dc2 910ab6c d948585 88971ec; do echo "=== $h ==="; git show --stat --format= "$h" | tail -1; done
```

| 短hash | files changed | insertions | deletions |
|---|---|---|---|
| 4b29dc2 | 27 | 2477 | 0 |
| 910ab6c | 39 | 7342 | 33 |
| d948585 | 29 | 3409 | 6 |
| 88971ec | 28 | 2315 | 568 |

（`4b29dc2` 的 `git show --stat` 末行缺 `deletions(-)` 字段，按契约记 `0`。）

### C2 — 审查载体

```bash
for s in lite-pricing-gate-protocol pricing-gate-scan-fix lite-inventory-pricing-audit cut-routing-machinery; do echo "--- $s ---"; find .tad/evidence/reviews -path "*$s*" -type f; done
```

| slug | reviews 文件数 | 文件路径列表（逐个，换行分隔） |
|---|---|---|
| lite-pricing-gate-protocol | 2 | .tad/evidence/reviews/blake/lite-pricing-gate-protocol/code-reviewer.md<br>.tad/evidence/reviews/blake/lite-pricing-gate-protocol/spec-compliance-reviewer.md |
| pricing-gate-scan-fix | 2 | .tad/evidence/reviews/blake/pricing-gate-scan-fix/code-reviewer.md<br>.tad/evidence/reviews/blake/pricing-gate-scan-fix/spec-compliance-reviewer.md |
| lite-inventory-pricing-audit | 2 | .tad/evidence/reviews/blake/lite-inventory-pricing-audit/code-reviewer.md<br>.tad/evidence/reviews/blake/lite-inventory-pricing-audit/spec-compliance-reviewer.md |
| cut-routing-machinery | 2 | .tad/evidence/reviews/blake/cut-routing-machinery/code-reviewer.md<br>.tad/evidence/reviews/blake/cut-routing-machinery/spec-compliance-reviewer.md |

### C3 — 台账演进

```bash
for h in 4b29dc2 910ab6c d948585 88971ec; do \
  d=$(git show "$h":.tad/evidence/audits/lite-constraint-ledger.md 2>/dev/null); \
  if [ -z "$d" ]; then echo "$h|N/A(file-absent)"; \
  else n=$(printf '%s\n' "$d" | grep -c '^|'); s=$(printf '%s\n' "$d" | grep -c '^|---'); \
       x=$((n - s - 1)); [ "$x" -lt 0 ] && x=0; echo "$h|$x"; fi; done
```

| 短hash | lite-constraint-ledger.md 数据行数 |
|---|---|
| 4b29dc2 | 0 |
| 910ab6c | 0 |
| d948585 | 0 |
| 88971ec | 3 |

## D reviewer 独立性证据

`.tad/archive/handoffs/LITE-*.md` 全部文件（5 个，与 `ls -1 | wc -l` 实测一致）。
三个字段判据均为行首锚定（`^Reviewer:` / `^P0=` / `^关键发现:`）；
任一字段零命中写 `ABSENT`。截断口径 = 超 200 chars（`wc -m`）截断并以 `…[TRUNCATED]` 结尾；
实测四条 `^关键发现:` 行为 148/136/105/140 chars，按 chars 口径一条都不截断。

```bash
ls -1 .tad/archive/handoffs/LITE-*.md
for f in .tad/archive/handoffs/LITE-*.md; do echo "--- $f ---"; echo "Reviewer: $(grep -c '^Reviewer:' "$f")"; echo "P0: $(grep -c '^P0=' "$f")"; echo "关键发现: $(grep -c '^关键发现:' "$f")"; done
```

| 文件名 | ^Reviewer: 行 | model= 子串 | ^P0= 行 | ^关键发现: 行 |
|---|---|---|---|---|
| LITE-20260730-1030-dogfood-throwaway.md | ABSENT | NO | ABSENT | ABSENT |
| LITE-20260730-2015-default-both-platform.md | Reviewer: 独立 Codex reviewer（只读、独立上下文） | NO | P0=0 (fixed), P1=0, P2=0; 已审 AC 条数: 6 | 关键发现: 首轮 reviewer 指出 npx 入口 `bin/tad-install.mjs` 也有独立的 Claude-only 默认值，并指出升级 fixture、隔离 platform override fixture、显式 `both` 与文档覆盖不够具体；已全部补入并通过增量复核。 |
| LITE-20260731-core-closure.md | Reviewer: Erdos（独立 fresh-context contract reviewer） | NO | P0=0 (fixed), P1=0, P2=2; 已审 AC 条数: 11 | 关键发现: 三轮增量复核已闭合 AC9 的角色化结构验证、AC10 的固定场景与路径、Progress 状态持久化、Gate/Repair/PARTIAL 状态转移、AC8 镜像配对语义。P2：行为场景 setup 由实现阶段生成；最终实现需更新本段元数据并保留原始证据。 |
| LITE-20260731-express-lite-capability-complete.md | Reviewer: Averroes (independent fresh-context code-reviewer) | NO | P0=2 (fixed) | 关键发现: 初审发现 Gate 2/§9.1 缺失、HANDOFF 文件名会误路由 full Blake、express 协议例外未显式记录、AC 语义检查不足；以上均已在本 handoff 中修复并留存证据。 |
| LITE-20260801-1121-lite-standard-routing.md | Reviewer: Newton（独立 fresh context） | NO | P0=1, P1=4, P2=1; 已审 AC 条数: 11 | 关键发现: 首轮发现 AC1–AC9 验证过于泛化、AC10 verifier 与 Lite 对象不匹配、AC11 缺少 baseline 载体；已修复并做增量复核。增量复核仍发现 AC10 命令缺少 fail-closed 语义，且 AC6/AC7/AC11 仍有可执行性缺口。 |

**`grep -c` 载体**（每文件三个锚的原始输出；`grep -c` 得 0 即 ABSENT，得 1 即上方逐字行）：

```bash
for f in .tad/archive/handoffs/LITE-*.md; do echo "--- $f ---"; echo "Reviewer: $(grep -c '^Reviewer:' "$f")"; echo "P0: $(grep -c '^P0=' "$f")"; echo "关键发现: $(grep -c '^关键发现:' "$f")"; done
```

```
--- .tad/archive/handoffs/LITE-20260730-1030-dogfood-throwaway.md ---
Reviewer: 0
P0: 0
关键发现: 0
--- .tad/archive/handoffs/LITE-20260730-2015-default-both-platform.md ---
Reviewer: 1
P0: 1
关键发现: 1
--- .tad/archive/handoffs/LITE-20260731-core-closure.md ---
Reviewer: 1
P0: 1
关键发现: 1
--- .tad/archive/handoffs/LITE-20260731-express-lite-capability-complete.md ---
Reviewer: 1
P0: 1
关键发现: 1
--- .tad/archive/handoffs/LITE-20260801-1121-lite-standard-routing.md ---
Reviewer: 1
P0: 1
关键发现: 1
```
