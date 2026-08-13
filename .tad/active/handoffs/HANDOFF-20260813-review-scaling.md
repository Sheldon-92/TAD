# HANDOFF: lite 审查分档 —— 多人各审一面、只审一轮、按碰到的文件自动加

**Epic**: `EPIC-20260812-discipline-weight-separation.md`（Phase 4a / 6）
**From**: Alex（full 通道）
**To**: Blake
**Created**: 2026-08-13
**Rev**: **rev3**（Gate 2 两专家并行：授权 4 P0 + AC 5 P0；**分档依据整体重设计**，见 §7.2）
**T0**: `47918da`

---

## 1. 目标（用户 2026-08-13 原话）

> **「我想增开门禁和审查环节跟 alex 和 blake 对齐，但是肯定不能什么任务都是顶配的 reviewer。」**

拆成两单，**本单只做审查**（门禁那单紧接着做）。理由：今天实测契约越大缺陷越多
（Phase 1b 21 个 P0 / Phase 2 13 个 / Phase 2b 9 个），而审查这块今天有最硬的实证。

## 2. 为什么：lite 缺的恰好是今天最高产的两个视角

**今天三轮审查的实证分布**（本 session，Phase 1b/2/2b 三单）：

| 审查维度 | 抓到 P0 | lite 有吗 |
|---|---|---|
| **AC 判别力 / 命令可执行性** | **19** | ❌ 没有 |
| **授权边界 / 自放大回路** | **9** | ❌ 没有 |
| 拍板可用性 / 长期失效 | 3 | ❌ 没有 |
| Alex 自查（闭集门禁） | 10 | ❌ 没有 |

**lite 现有的唯一 reviewer 覆盖**：`(1) spec 符合性 (2) 代码质量 (3) 执行验证义务`
——**上表前两行一条都不覆盖**，而它们合计 28 个 P0。

**lite 现在的形态**（原文，逐行）：
```
L209  spawn 1 个 code-reviewer subagent            ← 只有一个
L230  P0 修复 → 追加同 reviewer 增量复核             ← 同一人反复看
L253  修复后重跑受影响 AC 与 reviewer，再回本 Gate     ← 循环回本 Gate
```
= **1 个审查员 × 反复多轮**，与用户 2026-08-12 的三条要求相反
（增加 reviewer 数、各审不同维度；修完不再重复 review；门禁显性化）。

## 3. full 是怎么做到"不顶配"的（本单照搬其形状）

实测 `.tad/ralph-config/expert-criteria.yaml` 与 `blake/SKILL.md`：
- **固定跑**：spec-compliance-reviewer / code-reviewer / test-runner
- **条件跑**：security-auditor（`conditional: true`，pattern
  `auth|token|password|credential|api.*key|encrypt|decrypt|session|cookie|sql|query|upload|file|exec|eval`）
- **条件跑**：performance-optimizer（pattern `database|query|cache|batch|loop|sort|search|O\(n`）
- **硬规矩**（`blake/SKILL.md#L922`）：express / spike / infra 单**不豁免审查**，
  至少 1 个专家，**安全相关至少 2 个**

→ **full 的分档不靠人每单挑，靠机器看内容自动决定。** 本单沿用该形状，
但触发依据从「代码里有什么词」扩展到「**这单碰了哪些文件**」——
因为 lite 的单经常不是代码（写文档、改规则、发版本），而今天出事的那件工作恰好是这类。

## 4. 环境约束

| 约束 | 后果 |
|---|---|
| `for f in $VAR` 在 zsh 下**只迭代 1 次**（bash 是 N 次） | 循环型验证静默只查第一个；**一律显式列出或用数组** |
| `grep -F` 模式以 `- ` 开头必须加 `-e` | 否则 `invalid option` |
| 禁用 `awk '/^## X/,/^## /'` 提取小节 | 起止同行命中，只吐标题行 |
| `sort`/`uniq` 前必须 `LC_ALL=C` | 中文枚举静默错数 |
| `grep -c` 无命中 exit 1 | 后加 `\|\| true` |
| `grep -vE ''` 空模式吞掉一切 | 用前断言 `[ -n "$P" ]` |
| `git show "":path` 静默读 index | 先 `rev-parse --verify` |
| `grep` 是 ugrep 包装 | 用 `command grep` |
| **zsh 下 `path` / `cdpath` / `manpath` / `argv` / `status` 是特殊变量** | 赋值 `path=x` **即刻毁掉 `PATH`**，此后全部外部命令 `command not found`；且 `[ "$a" = "$b" ]` 两侧同时变空 → **静默变绿**。Gate 2 实测：rev2 的 AC5 因此永真、其下游 8 条 AC 全部假红 |

## 5. 知识引用（逐字标题，已核实命中）

| 条目 | 位置 | 用途 |
|---|---|---|
| `Express Handoff is NOT Review-Exemption` | `principles.md#L33` | 小单不豁免审查；底座 reviewer 每单必跑 |
| `A Fix Is a Defect Source — Budget a Gate for Fix-Induced Defects, Not Only for Re-Checking the Original` | `patterns/ac-verification.md` | 修复门禁必须单独查"修复之间是否互斥" |
| `"Run X" Is Not a Criterion Until X's Failure Signal Is Defined — a Print-Only Verifier Gives Every AC a Green With No Red` | `patterns/ac-verification.md` | AC 判别力视角的核心问法 |
| `Deny-List Beats Allow-List for Sync Sets`（2026-08-06 AMENDED 段） | `principles.md` | 授权边界视角的核心问法（自放大回路） |
| `Count the Copies Before Editing a Rule` | `patterns/handoff-design.md` | 本单只改 blake-lite + 其镜像 = 2 个文件，已数过 |

## 6. 范围与写权限

### 6.1 只允许写这 5 个位置（编号即全集，未列出即禁止）

1. `.claude/skills/blake-lite/SKILL.md`
2. `.agents/skills/blake-lite/SKILL.md`
3. `.tad/evidence/acceptance-tests/review-scaling/`（本单新建）
4. `.tad/archive/handoffs/COMPLETION-20260813-review-scaling.md`
5. `.tad/evidence/journal/lite-discoveries.md`（仅追加）
6. `.tad/evidence/audits/lite-constraint-ledger.md`（**仅追加**）——本单新增 ≥4 条 BLOCKING/不得，
   blake-lite 自己的「约束准入」节要求**新增之前**先往该台账追加定价行（每单成本/挡什么失败模式/载体路径），
   且追加前先跑超期扫描。⚠️ Gate 2 P1-4：rev1 未把它列进 allow-list → Blake 想付费即越权、不付费即绕闸

**git 只允许只读子命令**：`diff` / `show` / `ls-files` / `status` / `rev-parse` / `cat-file` / `log`。

### 6.2 不做

- ❌ 不动 `alex-lite`（本单只改执行侧；设计侧审查是门禁那单的事）
- ❌ 不动 full 通道任何文件
- ❌ 不改 `<!-- ESCALATION-LIST-BEGIN/END -->` 闭集
- ❌ 不改 L3.5 Technical Gate 的**五项判据**与**三态**（状态转移行按 §7.1 R4 单行替换，除此之外该节冻结）
- ❌ **不新增真人决策点**——分档全部由机器按规则判定，不问人

---

## 7. 设计

### 7.1 逐行替换表（旧文整行须消失，新文整行须出现恰好 1 次）

| # | 旧文（整行，T=0 各唯一命中 1 次，已核实） |
|---|---|
| R1 | `spawn 1 个 code-reviewer subagent（Agent tool），prompt：` |
| R2 | `P0 修复若改动了 reviewer 未见过的文件 → 追加同 reviewer 增量复核（只给 fix 部分，` |
| R3 | `mandate 内 reviewer/gate 缺陷由 Blake 有界修复、重跑受影响 AC 并增量复核，无逐 repair 请示。` |
| **R4** | `修复后重跑受影响 AC 与 reviewer，再回本 Gate。` ⚠️ **Gate 2 P0-1**：不删它，交付后文件里会同时存在「不再 spawn reviewer」与「重跑 reviewer 再回本 Gate」，运行时由被约束方自选，**默认选省事的那条** |

R1 → 替换为 `REVIEWER-FANOUT` 哨兵块（§7.2）的第一行引导句。
R2/R3 → 替换为 `REPAIR-GATE` 哨兵块（§7.4）。
R4 → 替换为**恰好一行**：`修复后按「修复门禁」单轮验完，再回本 Gate；不得追加复核轮次。`

⚠️ R2 的下一行 `成本 ≈1/5 首轮）。` 一并删除
（它是 R2 的续行）。**AC5/AC6 的删除预算按 5 行 × 2 文件 = 10 计。**

### 7.2 审查扇出表（插入 `<!-- REVIEWER-FANOUT-BEGIN/END -->` 哨兵块）

```
<!-- REVIEWER-FANOUT-BEGIN -->
### 审查扇出（按档位，机器按自报值执行）

**底座（每单必跑，不可跳过——`principles.md#L33` express 不豁免）**：
1 个 `code-reviewer`，prompt **沿用本块正下方那段缩进模板**
（`"Read {LITE handoff 路径}…"` 起至 `…verdict PASS/CONDITIONAL/FAIL"` 止），**逐字不改**。

#### 档位三问（Alex 在契约里自报，Blake 按自报值扇出）

契约必须含 `## 档位` 段，格式逐字：
```
## 档位
新建判断: {n}（逐个列出；判断=无法从已有内容机械复算的取舍。投影不算）
产物是否成为判据: {是|否}（产物会不会被后续的单/agent 当成依据或基线）
失败是否可见: {是|否}（做错了会不会报错。填错一个格子、闸不触发 = 不可见）
→ 档位: {轻|中|重}，加派 {0|1|2}
```

| 三问命中数 | 档位 | 加派 |
|---|---|---|
| 0（无新判断 + 产物非判据 + 失败可见） | **轻** | **0**，只有底座 |
| 1 | **中** | **1** |
| 2–3 | **重** | **2** |

**加派谁**（按命中的那条决定；同时命中多条按此表顺序取前 2，**加派上限 2**）：

| 命中的信号 | 加派 | 该 reviewer 只答这一个问题 |
|---|---|---|
| 新建判断 ≥1 | `code-reviewer`（第 2 个，独立 spawn） | **这些新判断有没有被独立复算过？** 逐个重推，与契约给的值 diff |
| 产物成为判据/基线 | `code-reviewer`（第 3 个，独立 spawn） | **哪条 AC 是永真的？** 产物不存在时命令会不会静默通过？"红"有没有机械载体？ |
| 失败不可见 | `security-auditor` | **静默失败的路径在哪？** 负控够不够？有没有把响亮失败换成静默成功？ |

**兜底（不占加派上限，命中即强制加）**：改动集命中
`.tad/hooks/` / `.claude/settings*` / `.claude/agents/` / `.gitignore`，
或 mandate 含 `publish`/`sync`/`push`，或改动内容涉及凭据/密钥
→ 强制加 `security-auditor`，只问「**这次授权会不会让下次不再需要人？**」
⚠️ 该路径表**非穷举，存疑按命中**；它是**兜底不是分档**——不参与三问计数。

#### 为什么不按"碰了哪些文件"分档（Gate 2 实测）

按文件路径分档在本仓库**恒真**：实测最近 **13 份 lite 单，"碰框架文件" 13/13 命中、
"AC ≥5 条" 13/13 命中**；且安全/性能词表被写进本文件后会**自匹配**
（F4 词表 12/13 个词、F5 词表 7/7 个词就在本块内）。
结果是每单 4 个 reviewer = **永远顶配**，与「不能什么任务都是顶配」直接冲突。

三问之所以有效，是因为它**与改动规模正交**（`patterns/handoff-design.md`
「Change Size Does Not Predict Verification Cost」）。本 session 实测对账：

| 单 | 新建判断 | 产物是判据 | 失败可见 | 实际抓到 P0 |
|---|---|---|---|---|
| 纪律表补五列 | 2 | 是 | 否 | **21** |
| Epic 目标闸 | 1 | 是 | 否 | **13** |
| 每单必问 + 路由 | 1 | 是 | 否 | **9** |
| 本单（审查分档） | 1 | 是 | 否 | **9** |

四单全部命中 3/3 → 重档；实际 P0 全在 9–21 区间。**判据与结果对得上。**

#### 自报值防伪

⚠️ **自报值必须被底座 reviewer 核**：底座 reviewer 的 prompt 追加一句
「核对 `## 档位` 段的自报值：契约里若存在无法机械复算的取舍而 `新建判断` 报 0，
或产物是规则/判据/基线而 `产物是否成为判据` 报否 → **报 P0 tier-underreport**」。
——自报值是**落盘的书面件**，报低了会被抓，因此不是自由心证。

**扇出结果必须落盘**：Completion 的 `Reviewer:` 行逐个列出
`{类型}({维度}): {verdict} P0={n}`，其后附两行：
`档位判定: 新建判断={n} 产物是判据={是|否} 失败可见={是|否} → {轻|中|重} 加派={n}`
`兜底判定: {命中原因|未命中}`
每个加派 reviewer 行后再追加 `问题原文: "{逐字复制自上表第 3 列，不得改写}"`
——**没有这几行，无法区分"评估过判定未命中"与"根本没评估"，也无法区分"派了但给了钝化的题面"**。

⚠️ **每个加派 reviewer 的 prompt 必须写明「只审这一个维度，其他维度有别人负责」**——
本 session 实测：维度不分开时 reviewer 会集中在最容易的那个（正确性），
高产维度（AC 判别力 19 个 P0 / 授权边界 9 个）反而没人看。
⚠️ **同一 reviewer 类型被多条命中时按维度分别 spawn**，prompt 互不合并。
<!-- REVIEWER-FANOUT-END -->
```

### 7.3 一轮，不复审

底座与全部加派 reviewer **在同一轮 spawn**，各自独立返回。**本单删除"追加同 reviewer 增量复核"**。
依据：用户 2026-08-12「review 修改了以后不应该再重复的 review……对抗性的它会一直找问题」；
以及本 session 实测——Phase 4 三轮 9 个 P0 中 **5 个是修复自己造的**。

### 7.4 修复门禁取代复核循环（插入 `<!-- REPAIR-GATE-BEGIN/END -->` 哨兵块）

```
<!-- REPAIR-GATE-BEGIN -->
### 修复门禁（取代增量复核；闭集判据，单轮独立执行，查完就完）

P0 修复后 spawn **1 个 fresh `code-reviewer`**（不复用首轮 reviewer，**不由 Blake 自查**
——Forbidden「以自审、自我复核替代 subagent spawn」对本节同样有效），
输入只给 fix diff + 下列 5 条闭集判据，**只跑这一轮**，返回后不得再 spawn 任何 reviewer、
不得回到 L3：

1. **修复文本在位**：每个 P0 的修复内容逐条 `grep -F -e` 确认真的写进了文件
2. **新命令能跑**：修复引入的任何命令 `bash -n` 通过，且在产物缺失时**会红不会静默通过**
3. **修复之间不互斥**：逐条检查本轮各修复是否产生新的作用域重叠或矛盾
   ——⚠️ 本 session 三次栽在这里（V7 挪对象后变成"文件不存在也绿"；
   要求复核某列同时禁止复核者读该列所在目录；回填锚点打破自指不动点）
4. **没有把响亮失败换成静默成功**：修复前会红的场景，修复后仍会红
5. **数字断言有来源**：修复中写下的任何计数/行数/阈值，均为实测所得而非凭印象
   ——⚠️ 本 session 实测：Alex 凭印象写「须 27」，实际 26

⚠️ **闭集 ≠ 自审**：本节与开放式复审的区别在**判据闭不闭集**（查完就完 vs 一直找问题），
不在谁来跑。用户 2026-08-12 反对的是"对抗性 reviewer 一直找问题"的循环，
不是"有第二双眼睛"。

**结果必须落盘**：Completion 追加一行
`修复门禁: 执行者={subagent 类型} 1={PASS|FAIL} 2=… 3=… 4=… 5=… 证据={路径}`
——没有这一行，无法区分"查过且全过"与"根本没查"。
任一不过 → `GATE FAIL / BLOCK`。**5 条全过即结束，不得追加轮次。**
<!-- REPAIR-GATE-END -->
```

---

## 8. Acceptance Criteria

**「红」的唯一定义**：验证脚本 `exit ≠ 0` 且末行 `RESULT=FAIL`。

| # | AC | 判据 |
|---|---|---|
| **AC1** | R1/R2/R3 三行旧文**消失**（各计数 0）；R2 续行 `成本 ≈1/5 首轮）。` 一并消失 | `grep -cFx -e`（⚠️ 以 `- ` 开头的模式必须加 `-e`）|
| **AC2** | 两个哨兵块成对存在且各恰好 1 次（`REVIEWER-FANOUT` / `REPAIR-GATE`），两个文件都要 | `grep -cxF` |
| **AC3** | 扇出表 F1–F5 五条触发条件**逐条在文**，且每条在 T=0 计数**须为 0**（否则判据永真） | 双向断言 |
| **AC4** | 修复门禁 5 条判据逐条在文，T=0 计数须为 0 | 双向断言 |
| **AC5** | **冻结补集**：两个文件中除 R1/R2/R3 + 续行 + 两个哨兵块以外的每一行，相对 T=0 逐字相同（**含纯增行**） | ⚠️ 没有这条，"偷加一行"不受任何约束 |
| **AC6** | 删除行数**恰好 10**（4 旧文 + 1 续行，×2 个文件）；**且新增行数恰好等于两个哨兵块的行数 ×2** | `--numstat` 双侧断言。⚠️ rev1 只断言 `deleted`、`added` 只 echo → 哨兵块内可无限夹带 |
| **AC7** | **判别力实测**：造 4 份 fixture 契约（`t0-light` 三问全 0 / `t1-judgment` 只新建判断 / `t1-criterion` 只产物是判据 / `t3-heavy` 三问全中），每份产出 `fanout-{x}.out`，**首行固定** `ROSTER=code-reviewer[,…]`（`LC_ALL=C` 排序去重） | 逐份 `ROSTER` 行**逐字等于**期望名单；且 `t0-light` 的名单与其余三份**两两不等**。⚠️ 只验"该加的加了"是半边，**必须验"轻档真的只有底座"**；`grep -qF '只有底座'` 这类"含某几个字"判据一律不接受（把那四个字打进文件就能过） |
| **AC8** | parity：两文件 `cmp -s` 逐字相同 | exit 0 |
| **AC9** | L3.5 **五项判据与三态**未被改动（R4 那一行按 §7.1 合法替换，比对时两侧各排除对应行） | 见 §9 |
| **AC13** | 修复门禁**载体格式**在文：`修复门禁: 执行者=` 与 `不由 Blake 自查` 两串在文，T=0 计数须为 0 | 双向断言 |
| **AC14** | **哨兵块内容逐字等于契约 §7.2/§7.4**（2 文件 × 2 块 = 4 处） | 与契约正文 `diff`；契约由 AC12 锁 sha。⚠️ 没有这条，AC5 把块内整段排除 → **块内是零约束区**，可塞进"本节豁免 Forbidden"而全部 AC 不红 |
| **AC15** | 台账相对 T=0 **恰好新增 2 行**（扇出 / 修复门禁各一），三格齐全；Completion 记录本次超期扫描结果 | `--numstat` + `grep` |
| **AC10** | `alex-lite` / full 通道 **零改动** | `git diff --name-only $T0 --` 对应路径 = 0 |
| **AC11** | 围栏（增量式）：收工残留减 Step 0 基线、减 hook 自动写两条后为空 | `comm -13`，判据是**行数 0** |
| **AC12** | 本契约相对 Step 0 冻结的 sha256 未变 | ⚠️ 本契约在 T=0 未被追踪，不能用 `git show $T0:` |

---

## 9. Step 0 与验证脚本

**Step 0（动手前第一件事）**
```bash
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/review-scaling"; mkdir -p "$EV/fixtures"
T0=47918da
git -C "$R" rev-parse --verify --quiet "$T0^{commit}" >/dev/null || { echo "RESULT=FAIL (T0 无效)"; exit 1; }
( cd "$R" && shasum -a 256 .tad/active/handoffs/HANDOFF-20260813-review-scaling.md ) > "$EV/handoff.sha256"
{ git -C "$R" -c core.quotePath=false diff --name-only "$T0" -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
[ -s "$EV/fence-baseline.txt" ] || { echo "Step 0 失败：基线为空"; exit 1; }
echo "Step 0 OK: baseline=$(wc -l < "$EV/fence-baseline.txt") lines"
```

**验证脚本**
```bash
set -uo pipefail
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/review-scaling"
T0=47918da
B1="$R/.claude/skills/blake-lite/SKILL.md"; B2="$R/.agents/skills/blake-lite/SKILL.md"
P1=".claude/skills/blake-lite/SKILL.md";    P2=".agents/skills/blake-lite/SKILL.md"
FAIL=0; fail(){ echo "GATE FAIL: $*"; FAIL=1; }
git -C "$R" rev-parse --verify --quiet "$T0^{commit}" >/dev/null || { echo "RESULT=FAIL (T0 无效)"; exit 1; }

R1='spawn 1 个 code-reviewer subagent（Agent tool），prompt：'
R2='P0 修复若改动了 reviewer 未见过的文件 → 追加同 reviewer 增量复核（只给 fix 部分，'
R2B='成本 ≈1/5 首轮）。'
R3='mandate 内 reviewer/gate 缺陷由 Blake 有界修复、重跑受影响 AC 并增量复核，无逐 repair 请示。'
R4='修复后重跑受影响 AC 与 reviewer，再回本 Gate。'
R4N='修复后按「修复门禁」单轮验完，再回本 Gate；不得追加复核轮次。'
HH="$R/.tad/active/handoffs/HANDOFF-20260813-review-scaling.md"

# AC1 旧文消失（⚠️ 显式列出两个文件，不用 for f in $VAR —— zsh 下只迭代 1 次）
for f in "$B1" "$B2"; do
  for s in "$R1" "$R2" "$R2B" "$R3" "$R4"; do
    [ "$(command grep -cFx -e "$s" "$f" || true)" -eq 0 ] || fail "AC1 旧文仍在: $f :: $s"
  done
  [ "$(command grep -cFx -e "$R4N" "$f" || true)" -eq 1 ] || fail "AC1 R4 新行缺失/重复: $f"
done

# AC2 哨兵成对
for f in "$B1" "$B2"; do
  for m in REVIEWER-FANOUT REPAIR-GATE; do
    b=$(command grep -cxF -e "<!-- $m-BEGIN -->" "$f" || true)
    e=$(command grep -cxF -e "<!-- $m-END -->"   "$f" || true)
    [ "$b" -eq 1 ] && [ "$e" -eq 1 ] || fail "AC2 哨兵 $m 不成对/重复: $f (b=$b e=$e)"
  done
done

# AC3/AC4 条款在文 + T=0 计数须为 0（防永真）
check_new(){ # $1=活文件 $2=T0路径 $3=串
  b=$(git -C "$R" show "$T0:$2" | command grep -cF -e "$3" || true)
  [ "$b" -eq 0 ] || fail "判据永真（T=0 已命中 $b 次）: $3"
  [ "$(command grep -cF -e "$3" "$1" || true)" -ge 1 ] || fail "缺条款: $3"
}
for s in '审查扇出（机器判定，不问人）' '只审这一个维度，其他维度有别人负责' \
         '扇出判定: F1=' '哪条 AC 是永真的' '这次授权会不会让下次不再需要人' \
         '修复之间不互斥' '没有把响亮失败换成静默成功' '数字断言有来源' \
         '5 条全过即结束，不得追加轮次' '修复门禁: 执行者=' '不由 Blake 自查' \
         'F1 的路径表非穷举' '收窄 F1 的单必然自命中 F1' '问题原文:' \
         '新建判断' '产物是否成为判据' '失败是否可见' '加派上限 2 个' \
         '修复文本在位' '新命令能跑' '自报值必须被底座 reviewer 核'; do
  check_new "$B1" "$P1" "$s"
done

# AC5 冻结补集（含纯增行）
for pair in "$B1|$P1" "$B2|$P2"; do
  live="${pair%%|*}"; pth="${pair##*|}"   # ⚠️ 禁用 path/argv/cdpath/manpath/status —— zsh 下是特殊变量
  base=$(git -C "$R" show "$T0:$pth" | command grep -vxF -e "$R1" -e "$R2" -e "$R2B" -e "$R3" -e "$R4")
  now=$(sed -e '/^<!-- REVIEWER-FANOUT-BEGIN -->$/,/^<!-- REVIEWER-FANOUT-END -->$/d' \
            -e '/^<!-- REPAIR-GATE-BEGIN -->$/,/^<!-- REPAIR-GATE-END -->$/d' "$live" \
       | command grep -vxF -e "$R4N")
  [ "$base" = "$now" ] || fail "AC5 $pth 在钉死行与哨兵块之外发生改动（含纯增行）"
done

# AC6 删除预算恰好 10
read -r ADDED DELETED <<<"$(git -C "$R" diff --numstat "$T0" -- "$P1" "$P2" \
  | LC_ALL=C awk '{a+=$1;d+=$2} END{print a+0,d+0}')"
echo "added=$ADDED deleted=$DELETED"
[ "$DELETED" -eq 10 ] || fail "AC6 删除行数 $DELETED != 10"
WANT=$(( $(sed -n '/^<!-- REVIEWER-FANOUT-BEGIN -->$/,/^<!-- REVIEWER-FANOUT-END -->$/p' "$HH" | wc -l) \
       + $(sed -n '/^<!-- REPAIR-GATE-BEGIN -->$/,/^<!-- REPAIR-GATE-END -->$/p' "$HH" | wc -l) + 1 ))
[ "$ADDED" -eq $(( WANT * 2 )) ] || fail "AC6 新增行数 $ADDED != $(( WANT * 2 ))（块外或块内有夹带）"

# AC7 扇出判别力（6 fixture，Step 0 已造）
[ -d "$EV/fixtures" ] || fail "AC7 缺 fixtures 目录"
for x in f1-framework f2-publish f3-manyac f4-secret f5-perf f6-none; do
  [ -s "$EV/fanout-$x.out" ] || fail "AC7 缺 $x 判定输出"
done
command grep -qF '只有底座' "$EV/fanout-f6-none.out" || fail "AC7 f6（全不命中）应只有底座"

# AC8 parity
cmp -s "$B1" "$B2" || fail "parity blake-lite"

# AC9 L3.5 未改
b=$(git -C "$R" show "$T0:$P1" | sed -n '/^## L3.5 /,$p' | sed -n '1p;2,${/^## /q;p;}' | command grep -vxF -e "$R4")
n=$(sed -n '/^## L3.5 /,$p' "$B1" | sed -n '1p;2,${/^## /q;p;}' | command grep -vxF -e "$R4N")
[ "$(printf '%s\n' "$b" | command grep -c . || true)" -ge 5 ] || fail "AC9 基线取不到 L3.5 节"
[ "$b" = "$n" ] || fail "AC9 L3.5 被改动"

# AC10 alex-lite / full 零改动
[ "$(git -C "$R" diff --name-only "$T0" -- \
   .claude/skills/alex-lite .agents/skills/alex-lite \
   .claude/skills/alex .claude/skills/blake .claude/skills/gate \
   .agents/skills/alex .agents/skills/blake .agents/skills/gate | wc -l)" -eq 0 ] || fail "AC10 越界改动"

# AC14 哨兵块内容 == 契约逐字（契约 sha 已由 AC12 锁定）
for m in REVIEWER-FANOUT REPAIR-GATE; do
  want=$(sed -n "/^<!-- $m-BEGIN -->\$/,/^<!-- $m-END -->\$/p" "$HH")
  [ -n "$want" ] || fail "AC14 契约中取不到 $m 块"
  for f in "$B1" "$B2"; do
    got=$(sed -n "/^<!-- $m-BEGIN -->\$/,/^<!-- $m-END -->\$/p" "$f")
    [ "$want" = "$got" ] || fail "AC14 $m 块内容与契约不逐字相同: $f"
  done
done

# AC15 台账恰好新增 2 行
LED='.tad/evidence/audits/lite-constraint-ledger.md'
read -r LA LD <<<"$(git -C "$R" diff --numstat "$T0" -- "$LED" | LC_ALL=C awk '{print $1+0,$2+0}')"
[ "${LA:-0}" -eq 2 ] && [ "${LD:-0}" -eq 0 ] || fail "AC15 台账新增=$LA 删除=$LD（应 2/0）"

# AC11 围栏
ALLOW='^\.claude/skills/blake-lite/SKILL\.md$|^\.agents/skills/blake-lite/SKILL\.md$|^\.tad/evidence/acceptance-tests/review-scaling/|^\.tad/archive/handoffs/COMPLETION-20260813-review-scaling\.md$|^\.tad/evidence/journal/lite-discoveries\.md$'
HOOK='^\.tad/evidence/(traces|decisions)/[0-9]{4}-[0-9]{2}-[0-9]{2}\.jsonl$'
[ -n "$ALLOW" ] && [ -n "$HOOK" ] || fail "ALLOW/HOOK 为空"
[ -s "$EV/fence-baseline.txt" ] || fail "AC11 基线缺失（Step 0 未跑）"
{ git -C "$R" -c core.quotePath=false diff --name-only "$T0" -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-now.txt"
LEFT=$(LC_ALL=C comm -13 "$EV/fence-baseline.txt" "$EV/fence-now.txt" | command grep -vE "$ALLOW" | command grep -vE "$HOOK" || true)
[ -z "$LEFT" ] || { printf '%s\n' "$LEFT"; fail "围栏残留"; }

# AC12 契约未被改
[ -s "$EV/handoff.sha256" ] || fail "AC12 基线 sha 缺失"
( cd "$R" && shasum -a 256 -c "$EV/handoff.sha256" ) >/dev/null 2>&1 || fail "契约被改"

[ "$FAIL" -eq 0 ] && { echo "RESULT=PASS"; exit 0; } || { echo "RESULT=FAIL"; exit 1; }
```

---

## 10. 已知取舍

1. **扇出规则本身没有独立复核**：F1–F5 的边界由 Alex 单方设定，没有第二双眼睛看过
   「这五条够不够、会不会漏」。缓解：AC7 的第 6 份 fixture（全不命中）至少能验
   「不该加的没加」，但验不了「该有第 6 条规则」。
2. **只改执行侧**：设计侧（alex-lite）的审查与门禁归下一单，本单交付后 lite 仍是
   「设计期 1 个 reviewer」。
3. **因果效力未证**（连续第四单）：没有实验证明"多视角比单视角在 lite 上真的抓得更多"
   ——本单的依据是 **full 通道上今天的实测**（28 个 P0 来自 lite 没有的两个维度），
   属**跨通道类比**，不是 lite 上的直接证据。**明写没买。**
4. **AC7 的 fixture 由 Blake 自造**：判别力验证的输入来自被验方。
