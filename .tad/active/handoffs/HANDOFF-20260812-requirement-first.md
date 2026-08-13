# HANDOFF: 摸清需求 —— 不管哪个模式都要做

**Epic**: `EPIC-20260812-discipline-weight-separation.md`（Phase 2b / 6）
**From**: Alex（full 通道）
**To**: Blake
**Created**: 2026-08-12
**Rev**: **rev3**（Gate 2 两专家并行：授权 3 P0 + AC 6 P0，全部修复）
**T0**: `d225585`

---

## 1. 目标（用户 2026-08-12 原话）

> **「摸清楚需求，不管是什么模式都需要的。」**

用户 2026-08-12 的两次裁定：
- 「**不够，轻模式也要问**」（问"只改路由够不够"时）
- 「**两个都改**」（问"改路由还是改 lite"时）

所以本单做**两件事**，缺一不可：

1. **lite 每单开工先问一道目标题**（不管任务大小）
2. **改路由规则**：大项目 / 改框架自身 / 对外发布这几类活，由**人**定用哪个模式

## 2. 为什么

2026-08-12 出过一次事：用户说「假设我们让 lite 取代 full」，agent 把假设当开工，
做了 6 个阶段的工作还发了一个版本出去。

事后查清两层原因：
- **近因**：lite 的规则明写「不问是常态」，且判断"上下文清不清楚"的是 agent 自己
- **远因**：那件工作本来该走 full（full 开新项目**本来就会问**，
  见 `.claude/skills/alex/references/adaptive-complexity-protocol.md#L123`），
  是路由规则 `CLAUDE.md#L49`「文件数、协议密度、**是否触及协议契约均不构成升级理由**」
  把它塞进了没有这道问句的通道

⚠️ 那条路由规则**出自被终止的那个 Epic 自己**（2026-08-06「lite 接管 full」）——
**造成事故的规则，是事故那条线自己写的。**

## 3. 环境约束（违反会让验证静默失效）

| 约束 | 后果 |
|---|---|
| `sort`/`uniq` 前必须 `LC_ALL=C` | 中文枚举**静默错数**（`printf '高\n中\n高\n' \| sort \| uniq -c` → `3 高`） |
| 禁用 `awk` 做 CJK 比较 | `("建议"=="成本")` → `1`，静默定错列 |
| 禁用 `awk '/^## X/,/^## /'` 提取小节 | 起止同行命中，只吐标题行 |
| `grep` 是 ugrep 包装 | 用 `command grep` |
| `-E` 下 `\|` 是字面竖线 | 正则退化为常量 → 永真 PASS |
| `grep -c` 无命中 exit 1 | 后加 `\|\| true` |
| `grep -vE ''` 空模式吞掉一切 | 用前断言 `[ -n "$P" ]` |
| `$PIPESTATUS` 在 zsh 下为空 | zsh 用 `$pipestatus` |
| `git show "":path` 静默读 index | 先 `rev-parse --verify` |

## 4. 知识引用（逐字标题 + 行号，已核实）

| 条目 | 位置 | 用途 |
|---|---|---|
| `AI/Human Judgment Domain Awareness — Agent 应自觉判断域归属` | `principles.md#L128` | 给人**选择题**不给**验证题**（"对不对？"必出橡皮图章） |
| `In a Capability-Retirement Inventory, "Not Needed" Is a Judgment, Not a Carrier — the Loss Concentrates in the Rows Exempted From Naming One` | `patterns/handoff-design.md#L167` | 强制「不是这个意思」选项 |
| `Count the Copies Before Editing a Rule — a Rule That Lives in N Places Is Unchanged Until All N Change` | `patterns/handoff-design.md#L29x` | 路由规则住 3 处 + 2 镜像 = **5 个文件** |
| `"Run X" Is Not a Criterion Until X's Failure Signal Is Defined` | `patterns/ac-verification.md#L343` | §8「红」必须有载体 |
| `When Every Lower-Level Gate Passes Correctly, Suspect the Level Above` | `patterns/gate-design.md#L27x` | 本单为什么同时改两层 |

## 5. 范围与写权限

### 5.1 只允许写这 8 个位置（编号即全集）

1. `CLAUDE.md`（**仅 §6.1 表中 R1 那一整行**）
2. `.claude/skills/alex-lite/SKILL.md`
3. `.claude/skills/blake-lite/SKILL.md`
4. `.agents/skills/alex-lite/SKILL.md`
5. `.agents/skills/blake-lite/SKILL.md`
6. `.tad/evidence/acceptance-tests/requirement-first/`（本单新建）
7. `.tad/archive/handoffs/COMPLETION-20260812-requirement-first.md`
8. `.tad/evidence/journal/lite-discoveries.md`（仅追加）

**明确禁止**（下列为对高危项的**冗余提醒**；边界以上方 8 项 allow-list 为准，**未列出 ≠ 允许**）：`.claude/agents/`、`.claude/settings*.json`、`.tad/hooks/`、
`.tad/project-knowledge/`、`.tad/active/epics/`、`.tad/active/session-state.md`、
`.gitignore`、**本契约自身**、full 通道任何 skill（`alex`/`blake`/`gate`）。

**git 只允许只读子命令**：`diff` / `show` / `ls-files` / `status` / `rev-parse` / `cat-file` / `log`。

### 5.2 改动性质：**逐行替换**，不是纯增行

⚠️ 上一单用的「零删除」守卫**这单用不了**——路由规则必须改既有行。
代之以 **§6.1 的逐行钉死表**：每处给出**旧文逐字 + 新文逐字**，
AC 逐条验「旧文消失 且 新文出现 且 出现次数 == 1」。
**表外的任何行不得改动**——由 **AC13 冻结补集**保证（AC5 只管"多删"，管不了"偷加"：
纯增行的 `deleted` 是 0，删除预算纹丝不动。Gate 2 实测：一份同时改 L49 与偷加 `@import` 的
恶意版本可通过 rev1 的 AC1/AC2/AC5 全部三条）。

### 5.3 不做

- ❌ 不动 full 通道（Epic Non-Goals）
- ❌ 不改 `<!-- ESCALATION-LIST-BEGIN/END -->` 闭集
- ❌ 不改 `alex-lite` `## 身份` 节 L17-19「Lite 的真人决策点只有…」
  （本单新增的问句属「初始 contract」决策点，**不新增第四类**；若实现中认为冲突 →
  停下报告人，不得自行改那三行）
- ❌ 不改上一单刚加的「Epic Objective 闸」（它管 Epic 层，本单管每单层，两者并存）

---

## 6. 设计

### 6.0 逐字串定义（**5 处必须完全一致**，AC 按这些串验）

```
OLDC_LINE = `/alex-lite` → `/blake-lite`：**默认通道**。文件数、协议密度、是否触及协议契约均不构成升级理由；

NEWC_LINE = `/alex-lite` → `/blake-lite`：**默认通道**。页数、文件数、知识量不构成升级理由；但**创建 Epic / 多阶段任务 / 修改框架自身 / 对外发布或同步**四类，**通道由人裁定**，agent 只评估给建议，不得按"lite 是默认"自行继续，**边界存疑一律按命中处理**；

OLDS  = - 页数、文件数、协议密度或知识量不触发 full；需细节用 linked appendix。

NEWS1 = - 页数、文件数或知识量不触发 full；需细节用 linked appendix。

NEWS2 = - ⚠️ **创建 Epic / 多阶段任务 / 修改框架自身 / 对外发布或同步**四类，**通道由人裁定**——agent 只评估给建议，不得按"lite 是默认"自行继续，**边界存疑一律按命中处理**。「修改框架自身」含 `CLAUDE.md`、`.claude/` 与 `.agents/` 下的 skills 与 agents、hooks、settings、`.tad/project-knowledge/`、`.gitignore`、`AGENTS.md`、`tad.sh`——**非穷举，未列出者按命中处理**。
```

⚠️ **`通道由人裁定` 这五个字在 5 个文件中各出现恰好 1 次**——rev1 的 `CLAUDE.md` 写的是
「由人裁定用哪个通道」、SKILL 写的是「通道由人裁定」，**措辞分裂导致 AC 抓不到 `CLAUDE.md`**
（Gate 2 P0-2 实测：Blake 只把 L49 改成「页数、文件数、知识量不构成升级理由；」就能过全部旧 AC，
**四类授权一个字都不用写**）。

⚠️ **`修改框架自身` 的范围**：rev1 的括号只列 `CLAUDE.md、skills、hooks、settings`，
把 `.tad/project-knowledge/`（lite 本来就有写权限、且 `principles.md` 每 session 自动注入）、
`.claude/agents/`（被审查方重定义审查方）、`.gitignore`（验证器自身的输入）漏在外面
——**这几条正是 `principles.md` 2026-08-06 AMENDED 段逐字点名的高危路径**（Gate 2 P1-2）。

### 6.1 路由规则：逐行钉死表（5 个文件）

| # | 文件 | 旧文（整行，须消失） | 新文（整行，须出现 1 次） |
|---|---|---|---|
| R1 | `CLAUDE.md` | `OLDC_LINE` | `NEWC_LINE` |
| R2 | `.claude/skills/alex-lite/SKILL.md` | `OLDS` | `NEWS1` + `NEWS2`（**两行**） |
| R3 | `.claude/skills/blake-lite/SKILL.md` | `OLDS` | `NEWS1` + `NEWS2` |
| R4 | `.agents/skills/alex-lite/SKILL.md` | `OLDS` | `NEWS1` + `NEWS2` |
| R5 | `.agents/skills/blake-lite/SKILL.md` | `OLDS` | `NEWS1` + `NEWS2` |

已核实：`OLDC_LINE` 在 T=0 的 `CLAUDE.md` 中 `grep -cxF` == **1**；`OLDS` 在四个 SKILL 中各 == **1**。

### 6.2 lite 每单目标题（加在 `alex-lite` 的 L1 之后、L1.5 之前）

**插入块必须被哨兵包裹**（沿用仓库既有的 `<!-- ESCALATION-LIST-BEGIN/END -->` 惯例），
否则 AC13 的补集冻结无法把它与"偷加的行"区分开：

```
<!-- GOALQ-L1A-BEGIN -->
### **L1a — 目标题（⚠️ BLOCKING，每单必跑，无 agent 裁量）**

- Input: 用户需求原文。
- Action: 在进 L1.5 之前，列出对**本单目标**的全部读法，用 AskUserQuestion
  （无该工具的 harness → 编号纯文本并停下等输入）让**用户选一个**。
- **选项规则**：
  1. **≥2 个选项**
  2. 每个选项的**产出物**必须实质不同；仅措辞不同不算
  3. **必须恰好有一个 `[不是这个意思]` 选项**
  4. **不得由 Alex 自选**，不得折叠成默认值
  5. **不得隐藏 Alex 想到过的读法**
- **成本控制**：目标明确的单写 2 个选项即可（本读法 + `[不是这个意思]`），用户两秒即过；
  **读法越多说明需求越模糊，成本与模糊度成正比是本设计的意图**。
- **通道裁定**：同时判定本单是否命中「四类」（创建 Epic / 多阶段任务 / 修改框架自身 /
  对外发布或同步），**边界存疑一律按命中处理**；结果逐字记入 `## 目标题` 段的 `通道:` 行。
- Output: LITE 契约新增 `## 目标题` 段（格式见下）。
- **Stop**: 用户已选 → 进 L1.5。
  ⚠️ 本步**不因"上下文已清楚"跳过**——L1 的「不问是常态」仅适用于目标锚的追问，
  **不覆盖 L1a**。判定权在 agent 手里就等于没有这一步。
- **与「真人决策点只有三类」的关系**：本步是**第一类（初始 contract）的组成部分**，
  不构成第四类决策点——`## 身份` 节 L17-19 的枚举按此理解。
<!-- GOALQ-L1A-END -->
```

⚠️ 最后一条是必需的（Gate 2 P1-3）：**契约会被归档，SKILL 是未来 agent 唯一读到的文本**。
不写进去，未来 agent 可以援引「真人决策点只有三类」论证 L1a 不是决策点、可以省。
这样写**不动 L17-19 一个字**，删除预算与锚都不受影响。

`## 目标题` 段格式（逐字钉死，L0.5 机械查）：

```markdown
## 目标题

- [A] {读法 A}｜产出：{交付物}
- [B] [不是这个意思] 你要的是别的
用户选择: A
通道: lite（四类命中: 无）
```

⚠️ `通道:` 行是**分类结果的载体**——没有它，事后无法区分「评估过、判定未命中」与「根本没评估」。

### 6.3 blake-lite L0.5 追加（同样用哨兵包裹）

追加的清单条目（散文，放在哨兵块内）：

```
<!-- GOALQ-CHECK-BEGIN -->
- **目标题检查**：LITE 契约须含 `## 目标题` 段，按下方代码块逐字核验。
- 任一不满足 → 停："契约缺目标题，退回 /alex-lite"
<!-- GOALQ-CHECK-END -->
```

⚠️ **下面这段从代码块复制，不要从上面的块复制。**

```bash
# blake-lite L0.5 · 目标题检查（$f = 当前 LITE 契约）
sec=$(sed -n '/^## 目标题[[:space:]]*$/,$p' "$f" | sed -n '1p;2,${/^## /q;p;}')
[ -n "$sec" ] || { echo "GATE FAIL / BLOCK: 契约缺 ## 目标题"; exit 1; }
o=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cE '^- \[[A-Z]\] ' || true)
n=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cF '[不是这个意思]' || true)
p=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cE '^用户选择: [A-Z]$' || true)
c=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cE '^通道: (lite|full)（四类命中: .+）$' || true)
ltr=$(printf '%s\n' "$sec" | LC_ALL=C command grep -oE '^用户选择: [A-Z]$' | LC_ALL=C command grep -oE '[A-Z]$')
i=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cE "^- \[${ltr:-@}\] " || true)
# 选中的那条不得是「不是这个意思」——选它意味着需求没摸清，应回去重问
w=$(printf '%s\n' "$sec" | LC_ALL=C command grep -E "^- \[${ltr:-@}\] " | LC_ALL=C command grep -cF '[不是这个意思]' || true)
[ "$o" -ge 2 ] && [ "$n" -eq 1 ] && [ "$p" -eq 1 ] && [ "$c" -eq 1 ] && [ "$i" -eq 1 ] && [ "$w" -eq 0 ] \
  || { echo "GATE FAIL / BLOCK: 目标题不合格 (opts=$o null=$n pick=$p chan=$c inset=$i wrong=$w)"; exit 1; }
```

⚠️ **不得用 `awk '/^## 目标题/,/^## /'`** —— 起止同行命中，只吐标题行，对合格契约恒判 0 选项。
（`通道:` 行用全角括号 `（）`，无正则含义，避开 `-E` 下的竖线陷阱。）

---

### 7.0 Step 0（Blake 动手前第一件事，只跑一次，输出即证据）

```bash
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/requirement-first"; mkdir -p "$EV/fixtures"
T0=d225585
# (1) 围栏基线
{ git -C "$R" -c core.quotePath=false diff --name-only "$T0" -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
[ -s "$EV/fence-baseline.txt" ] || { echo "Step 0 失败：围栏基线为空"; exit 1; }
# (2) 高权限脏路径断言（基线里已脏的路径，围栏对其永久失明）
HIGHAUTH='^(CLAUDE\.md|\.gitignore|AGENTS\.md|tad\.sh)$|^\.claude/(agents|workflows)/|^\.claude/settings|^\.tad/(project-knowledge|hooks|logs)/|^\.claude/skills/(alex|blake|gate)/|^\.agents/skills/(alex|blake|gate)/'
BAD=$(LC_ALL=C command grep -E "$HIGHAUTH" "$EV/fence-baseline.txt" | command grep -vF '.bak-' || true)
[ -z "$BAD" ] || { printf '%s\n' "$BAD"; echo "Step 0 失败：基线含高权限脏路径"; exit 1; }
# (3) 契约指纹（本契约在 T0 为 untracked，git show 取不到）
( cd "$R" && shasum -a 256 .tad/active/handoffs/HANDOFF-20260812-requirement-first.md ) > "$EV/handoff.sha256"
# (4) 把 §6.3 代码块**逐字**落成 $EV/goal-check.sh（首行加 f="$1"），**不得改写**
# (5) 造 6 份 fixture 到 $EV/fixtures/：
#     good-mid / good-last / bad-no-null / bad-two-null / bad-letter-oob / bad-chose-null
echo "Step 0 OK: baseline=$(wc -l < "$EV/fence-baseline.txt") lines"
```

---

## 7. Acceptance Criteria

**「红」的唯一定义**：验证脚本 `exit ≠ 0` 且末行 `RESULT=FAIL`。

| # | AC | 判据 |
|---|---|---|
| **AC13** | **冻结补集（本单最重要的一条）**：5 个文件中，**除钉死表旧/新行与两个哨兵块以外的每一行**，相对 T=0 逐字相同——**含纯增行** | V13 补集串相等。⚠️ 没有这条，「删一行 + 加一行」这条路根本不用走：**纯增行的 `deleted` 是 0**，AC5 预算纹丝不动 |
| **AC1** | 五处逐行替换落实：`OLDC_LINE`/`OLDS` 计数 **0**；`通道由人裁定` 在**全部 5 个文件**各计数 **1** | `grep -cF -e`（⚠️ `OLDS` 以 `- ` 开头，不加 `-e` 报 `invalid option`，实测） |
| **AC2** | `协议密度` 在 5 个文件全部为 **0**；`文件数` 全部 ≥1 | 逐文件计数 |
| **AC3** | §6.3 检查有**真判别力**：6 份 fixture（good-mid / good-last / bad-no-null / bad-two-null / bad-letter-oob / **bad-chose-null**）跑 §6.3 **原文命令** | 2 good exit0；4 bad exit1 **且报错点名违反项**。⚠️ Blake **不得改**该命令 |
| **AC4** | L1a 六条内容逐字在文（五条选项规则 + `是**第一类（初始 contract）的组成部分**`），且每串在 T=0 计数 **须为 0** | 双向断言，防判据永真 |
| **AC5** | `deleted` 总数 == **5**（钉死表旧文行数） | 与 AC13 互补：AC5 管"多删"，AC13 管"偷加" |
| **AC6** | parity：两对文件 `cmp -s` 逐字相同 | exit 0 ×2 |
| **AC7** | `ESCALATION-LIST` 区间与 T=0 逐字相同，**且基线区间 ≥3 行** | 空对空会假通过 |
| **AC8** | L17-19「真人决策点只有…」锚逐字未变 | `grep -Fxq` |
| **AC9** | 上一单的「Epic Objective 闸」节未被改动 | 该节相对 T=0 逐字相同 |
| **AC10** | full 未被碰 | `git diff --name-only $T0 -- <full 六路径>` = 0 |
| **AC11** | 围栏（增量式）：收工残留减 Step 0 基线、减 hook 自动写两条后为空；**且 Step 0 基线中不得含高权限脏路径** | `comm -13`，判据是**行数 0**；基线断言见 V11b |
| **AC12** | 本契约相对 **Step 0 冻结的 sha256** 逐字未变 | ⚠️ 不能用 `git show $T0:契约`——**本契约不在 T=0 里**（实测 `fatal: exists on disk, but not in`），那样 AC12 恒 FAIL，而 Blake 最省事的修法就是动 AC12 本身 |

---

## 8. 验证脚本

```bash
set -uo pipefail
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/requirement-first"
CP=".tad/active/handoffs/HANDOFF-20260812-requirement-first.md"
T0=d225585
FAIL=0; fail(){ echo "GATE FAIL: $*"; FAIL=1; }
git -C "$R" rev-parse --verify --quiet "$T0^{commit}" >/dev/null || { echo "RESULT=FAIL (T0 无效)"; exit 1; }
mkdir -p "$EV"

# ===== 逐字串（与 §6.0 一致；改这里必须同步改 §6.0）=====
OLDC_LINE='`/alex-lite` → `/blake-lite`：**默认通道**。文件数、协议密度、是否触及协议契约均不构成升级理由；'
NEWC_LINE='`/alex-lite` → `/blake-lite`：**默认通道**。页数、文件数、知识量不构成升级理由；但**创建 Epic / 多阶段任务 / 修改框架自身 / 对外发布或同步**四类，**通道由人裁定**，agent 只评估给建议，不得按"lite 是默认"自行继续，**边界存疑一律按命中处理**；'
OLDS='- 页数、文件数、协议密度或知识量不触发 full；需细节用 linked appendix。'
NEWS1='- 页数、文件数或知识量不触发 full；需细节用 linked appendix。'
SKILLS=".claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md"

# V1 AC1 旧文消失 + 新文唯一（含 CLAUDE.md）
[ "$(command grep -cF -e "$OLDC_LINE" "$R/CLAUDE.md" || true)" -eq 0 ] || fail "AC1 CLAUDE.md 旧行仍在"
for f in $SKILLS; do
  [ "$(command grep -cF -e "$OLDS" "$R/$f" || true)" -eq 0 ] || fail "AC1 旧行仍在: $f"
  # ⚠️ 新文**第一行**必须整行存在——AC13 的补集冻结对"漏写第一行"是瞎的（实测 PASS）
  [ "$(command grep -cFx -e "$NEWS1" "$R/$f" || true)" -eq 1 ] || fail "AC1 新文第1行缺失/重复: $f"
done
for f in CLAUDE.md $SKILLS; do
  [ "$(command grep -cF -e '通道由人裁定' "$R/$f" || true)" -eq 1 ] || fail "AC1 新文缺失或重复: $f"
done

# V2 AC2 关键词增删
for f in CLAUDE.md $SKILLS; do
  [ "$(command grep -cF -e '协议密度' "$R/$f" || true)" -eq 0 ] || fail "AC2 「协议密度」未删净: $f"
  [ "$(command grep -cF -e '文件数'   "$R/$f" || true)" -ge 1 ] || fail "AC2 「文件数」被误删: $f"
done

# V13 AC13 冻结补集（**本单最重要**：含纯增行）
[ "$(git -C "$R" show "$T0:CLAUDE.md" | command grep -cxF -e "$OLDC_LINE" || true)" -eq 1 ] || fail "AC13 基线旧行未唯一命中"
[ "$(command grep -cxF -e "$NEWC_LINE" "$R/CLAUDE.md" || true)" -eq 1 ] || fail "AC13 新行未唯一出现"
b=$(git -C "$R" show "$T0:CLAUDE.md" | command grep -vxF -e "$OLDC_LINE")
n=$(command grep -vxF -e "$NEWC_LINE" "$R/CLAUDE.md")
[ "$b" = "$n" ] || fail "AC13 CLAUDE.md 在钉死行之外发生改动（含纯增行）"
NEWS2=$(command grep -m1 -F -e '「修改框架自身」含' "$R/.claude/skills/alex-lite/SKILL.md" || true)
[ -n "$NEWS2" ] || fail "AC13 取不到 NEWS2（新行缺失）"
for f in $SKILLS; do
  for m in GOALQ-L1A GOALQ-CHECK; do
    bg=$(command grep -cxF -e "<!-- $m-BEGIN -->" "$R/$f" || true)
    en=$(command grep -cxF -e "<!-- $m-END -->"   "$R/$f" || true)
    [ "$bg" -eq "$en" ] && [ "$bg" -le 1 ] || fail "AC13 哨兵 $m 不成对/重复: $f"
  done
  b=$(git -C "$R" show "$T0:$f" | command grep -vxF -e "$OLDS")
  n=$(sed -e '/^<!-- GOALQ-L1A-BEGIN -->$/,/^<!-- GOALQ-L1A-END -->$/d' \
          -e '/^<!-- GOALQ-CHECK-BEGIN -->$/,/^<!-- GOALQ-CHECK-END -->$/d' "$R/$f" \
       | command grep -vxF -e "$NEWS1" -e "$NEWS2")
  [ "$b" = "$n" ] || fail "AC13 $f 在哨兵块与钉死行之外发生改动（含纯增行）"
done

# V3 AC3 目标题检查的真判别力（6 fixture；goal-check.sh 由 Step 0 逐字落盘）
[ -s "$EV/goal-check.sh" ] || fail "AC3 缺 goal-check.sh（Step 0 未跑）"
for x in good-mid good-last; do
  zsh "$EV/goal-check.sh" "$EV/fixtures/$x.md" > "$EV/ac3-$x.out" 2>&1 \
    || fail "AC3 $x 应 exit0"
done
for pair in 'bad-no-null:null=0' 'bad-two-null:null=2' 'bad-letter-oob:inset=0' 'bad-chose-null:wrong=1'; do
  x=${pair%%:*}; key=${pair#*:}
  zsh "$EV/goal-check.sh" "$EV/fixtures/$x.md" > "$EV/ac3-$x.out" 2>&1 && fail "AC3 $x 应 exit1"
  command grep -qF -e "$key" "$EV/ac3-$x.out" || fail "AC3 $x 未点名违反项（缺 $key）"
done
# AC3 反向：blake-lite 里真的落了这套检查的每个承重要素（防私改成弱检查）
for s in "grep -cF '[不是这个意思]'" "grep -cE '^用户选择: [A-Z]\$'" '"$o" -ge 2' '"$n" -eq 1' '"$w" -eq 0'; do
  [ "$(command grep -cF -e "$s" "$R/.claude/skills/blake-lite/SKILL.md" || true)" -ge 1 ] \
    || fail "AC3 blake-lite 缺检查要素: $s"
done

# V4 AC4 L1a 条款（⚠️ 必须按节切片：同名串在 Epic Objective 闸里已存在，实测 T0 各命中 1 次）
for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md; do
  L1A=$(sed -n '/^### \*\*L1a — 目标题/,$p' "$R/$f" | sed -n '1p;2,${/^### /q;p;}')
  [ -n "$L1A" ] || { fail "AC4 取不到 L1a 节: $f"; continue; }
  for s in '**≥2 个选项**' '仅措辞不同不算' '必须恰好有一个 `[不是这个意思]` 选项' \
           '**不得由 Alex 自选**' '**不得隐藏 Alex 想到过的读法**' '不覆盖 L1a' \
           '是**第一类（初始 contract）的组成部分**'; do
    [ "$(printf '%s\n' "$L1A" | command grep -cF -e "$s" || true)" -ge 1 ] || fail "AC4 缺串「$s」: $f"
  done
done
# AC4 反向：T=0 侧同一切片必须为 0 行 → 证明本判据非永真
[ "$(git -C "$R" show "$T0:.claude/skills/alex-lite/SKILL.md" \
     | sed -n '/^### \*\*L1a — 目标题/,$p' | wc -l | tr -d ' ')" -eq 0 ] \
  || fail "AC4 判据永真：L1a 节在 T=0 已存在"

# V5 AC5 删除预算
read -r ADDED DELETED <<<"$(git -C "$R" diff --numstat "$T0" -- CLAUDE.md $SKILLS \
  | LC_ALL=C awk '{a+=$1;d+=$2} END{print a+0,d+0}')"
echo "added=$ADDED deleted=$DELETED"
[ "$DELETED" -eq 5 ] || fail "AC5 删除行数 $DELETED != 5"

# V6 AC6 parity
cmp -s "$R/.claude/skills/alex-lite/SKILL.md"  "$R/.agents/skills/alex-lite/SKILL.md"  || fail "parity alex"
cmp -s "$R/.claude/skills/blake-lite/SKILL.md" "$R/.agents/skills/blake-lite/SKILL.md" || fail "parity blake"

# V7 AC7 闭集未改
for f in alex-lite blake-lite; do
  base=$(git -C "$R" show "$T0:.claude/skills/$f/SKILL.md" | awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/')
  now=$(awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/' "$R/.claude/skills/$f/SKILL.md")
  [ "$(printf '%s\n' "$base" | command grep -c . || true)" -ge 3 ] || fail "AC7 基线区间过短"
  [ "$base" = "$now" ] || fail "AC7 闭集被改: $f"
done

# V8 AC8 决策点锚
command grep -Fxq 'Execution Mandate、下方闭集中的实质边界变化、最终业务验收。命令、工具、exit、retry、' \
  "$R/.claude/skills/alex-lite/SKILL.md" || fail "AC8 决策点锚被改"

# V9 AC9 上一单的 Epic 闸未被改
b=$(git -C "$R" show "$T0:.claude/skills/alex-lite/SKILL.md" | sed -n '/^## Epic Objective 闸/,$p' | sed -n '1p;2,${/^## /q;p;}')
n=$(sed -n '/^## Epic Objective 闸/,$p' "$R/.claude/skills/alex-lite/SKILL.md" | sed -n '1p;2,${/^## /q;p;}')
[ "$(printf '%s\n' "$b" | command grep -c . || true)" -ge 5 ] || fail "AC9 基线取不到 Epic 闸节"
[ "$b" = "$n" ] || fail "AC9 Epic Objective 闸被改动"

# V10 AC10 full 未被碰
[ "$(git -C "$R" diff --name-only "$T0" -- \
   .claude/skills/alex .claude/skills/blake .claude/skills/gate \
   .agents/skills/alex .agents/skills/blake .agents/skills/gate | wc -l)" -eq 0 ] || fail "full 被改"

# V11 AC11 围栏（Step 0 已冻结 fence-baseline.txt）
ALLOW='^CLAUDE\.md$|^\.claude/skills/(alex|blake)-lite/SKILL\.md$|^\.agents/skills/(alex|blake)-lite/SKILL\.md$|^\.tad/evidence/acceptance-tests/requirement-first/|^\.tad/archive/handoffs/COMPLETION-20260812-requirement-first\.md$|^\.tad/evidence/journal/lite-discoveries\.md$'
HOOK='^\.tad/evidence/(traces|decisions)/[0-9]{4}-[0-9]{2}-[0-9]{2}\.jsonl$'
[ -n "$ALLOW" ] && [ -n "$HOOK" ] || fail "ALLOW/HOOK 为空（空模式吞掉一切）"
{ git -C "$R" -c core.quotePath=false diff --name-only "$T0" -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-now.txt"
[ -s "$EV/fence-baseline.txt" ] || fail "AC11 基线缺失（Step 0 未跑）——comm 会静默吞掉一切"
LEFT=$(LC_ALL=C comm -13 "$EV/fence-baseline.txt" "$EV/fence-now.txt" | command grep -vE "$ALLOW" | command grep -vE "$HOOK" || true)
[ -z "$LEFT" ] || { printf '%s\n' "$LEFT"; fail "围栏残留"; }

# V12 AC12 契约未被改（sha256，Step 0 冻结）
[ -s "$EV/contract.sha256" ] || fail "AC12 基线 sha 为空（空对空假通过）"
[ "$(shasum -a 256 "$R/$CP" | LC_ALL=C awk '{print $1}')" = "$(cat "$EV/contract.sha256")" ] || fail "契约被改"

[ "$FAIL" -eq 0 ] && { echo "RESULT=PASS"; exit 0; } || { echo "RESULT=FAIL"; exit 1; }
```

**Step 0（Blake 读完契约、动任何文件之前，按顺序跑）**：
```bash
mkdir -p "$EV"
shasum -a 256 "$R/$CP" | LC_ALL=C awk '{print $1}' > "$EV/contract.sha256"
{ git -C "$R" -c core.quotePath=false diff --name-only "$T0" -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
# V11b 基线不得含高权限脏路径（否则围栏对其永久失明）
HIGHAUTH='^(CLAUDE\.md|\.gitignore|AGENTS\.md|tad\.sh)$|^\.claude/(agents|workflows)/|^\.claude/settings|^\.tad/(project-knowledge|hooks|logs)/|^\.claude/skills/(alex|blake|gate)/|^\.agents/skills/(alex|blake|gate)/'
BAD=$(LC_ALL=C command grep -E "$HIGHAUTH" "$EV/fence-baseline.txt" | command grep -vF '.bak-' || true)
[ -z "$BAD" ] || { printf '%s\n' "$BAD"; echo "RESULT=FAIL (基线含高权限脏路径，围栏对其失明)"; exit 1; }
echo "Step 0 OK: baseline=$(wc -l < "$EV/fence-baseline.txt") lines"
```

---

## 9. 已知取舍

1. **每单一问会不会变成闭眼选 A** —— 会有这个风险。减缓：明确的单只列 2 个选项（两秒过），
   选项数与模糊度成正比。**但长期是否退化本单无法证明**，交实际使用观察。
2. **选项公正性无机械载体** —— 闸能强制"必须列选项"，管不了"选项写得公不公道"
   （"我想做的 + 一个稻草人"格式上完全合规）。唯一防线是独立契约审查的人工判断。
3. **因果效力未证** —— 本单不做行为回放实验（有效设计需 ≈16 次 agent 调用，
   与用户的 credit 约束冲突）。**明写没买这个证明。**
4. **新增 BLOCKING 未走 lite 的「约束准入」台账** —— 台账归 alex-lite 管辖，
   full 通道的 Blake 不代写；连同上一单欠的 2 处，交后续 lite 单一并补。
