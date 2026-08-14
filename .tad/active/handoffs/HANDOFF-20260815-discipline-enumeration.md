# HANDOFF: 补全纪律清单 —— 把从未扫过的 55 块逐块归宿

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P2a / 6）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-15 **Rev**: rev1
**T0**: 本契约由 Alex 在交单前 commit；Step 0 记下该 commit SHA（见 §8）

## 1. 目标

现有纪律清单 15 条（`discipline-inventory.md`）**不是全集**：它的枚举语料只有 3 个来源
（`CLAUDE.md` / `alex`+`blake` SKILL / lite SKILL），**从未扫过** `gate/SKILL.md`（995 行，
全仓强制条款密度最高）、激活时强制加载的 5 个 `config-*.yaml`、`AGENTS.md`。

本单把**未扫语料的 55 个命名块逐块归宿**，产出补全后的清单。
**不做地板判定**（那是 P2b）——本单只回答"有哪些纪律"，不回答"哪条必须常驻"。

## 2. 为什么按「块」不按「行」

一条纪律是一个**协议块**，不是一行。实测规模：未扫语料强制标记行 **257 行**、命名块 **55 块**。
逐行归宿不可行且粒度错误；逐块归宿可行，再用行级扫描做交叉校验捕捉"块外孤儿"。

⚠️ **词表不得从已知结果反推**（P1a 教训）。本单的宽词表已实测：窄词表 `MUST|MANDATORY|
BLOCKING|VIOLATION|forbidden|不得|必须` 在全语料命中 298，宽词表命中 **593**，
其中 `AGENTS.md` 窄词表命中 **0**、宽词表才捞到那条"禁止代答"。**Step 0 冻结宽词表，不得收窄。**

## 3. 语料（Step 0 冻结为路径清单，实现期不得增删）

| 语料 | 块数 | 块定义 |
|---|---|---|
| `.claude/skills/gate/SKILL.md` | 16 | `^[a-z_]+:` 或 `^#{2,3} ` |
| `.tad/config-cognitive.yaml` | 4 | `^[a-z_]+:` |
| `.tad/config-quality.yaml` | 7 | 同上 |
| `.tad/config-agents.yaml` | 4 | 同上 |
| `.tad/config-platform.yaml` | 2 | 同上 |
| `.tad/config-workflow.yaml` | 11 | 同上 |
| `AGENTS.md` | 11 | `^#{2,3} ` |
| **合计** | **55** | |

⚠️ **具名延期**：已扫过的 137 块（`CLAUDE.md` / `alex` / `blake` / lite）**本单不重新归宿**。
理由：原枚举有过程记录（`enumeration-diff.md`），且 Gate 2 的实测缺口全部落在未扫语料。
**复活条件**：若 P2b 或 P3/P4/P7 在已扫语料里发现未登记的强制纪律，本延期作废，须补做。

## 4. 产物

### 4.1 `.tad/evidence/designs/discipline-inventory/disposition-55.md`

**恰好 55 行**，每行一个块，四列：

| 列 | 取值（闭集） |
|---|---|
| 块 | `路径 ⇥ 行号 ⇥ 块名`（TAB 分隔，逐字取自 Step 0 冻结的 `blocks.txt`） |
| 归宿 | `已有:{纪律名}` ｜ `新增:{纪律名}` ｜ `非纪律` |
| 理由码 | 仅当归宿=非纪律：`R1 能力非强制` ｜ `R2 已由某纪律覆盖` ｜ `R3 描述性非祈使` ｜ `R4 平台适配非质量纪律` ｜ `R5 元数据/索引` |
| 一句话 | 该判定的具体依据，**须含该块内一处可 grep 的原文片段** |

### 4.2 `discipline-inventory.md` 增补

每条 `新增:` 的纪律以**同样的 14 列**并入表体。
⚠️ **既有 15 行逐字不动**（AC5 守）——本单只增不改。

### 4.3 审查候选裁定表 `.tad/evidence/designs/discipline-inventory/gate2-candidates.md`

Gate 2 审查员提出 **4 条 P0 + 6 条 P1** 候选（研究先行 / 技术决策透明 / 平台绑定交互决策 /
六个强制问题 / 结构性 subagent 强制 / subagents_enforcement / 产物证据链 / §9.1 逐行实跑 /
熔断与升级 / Global Skill Exclusion）。**每条必须有裁定：采纳（→ 新增纪律）或驳回（+ 理由）。**
⚠️ **不得照单全收**——审查员的清单是候选不是结论，逐条须自行核对其引用的 `文件:行号` 属实。

## 5. 不做

❌ 不做地板/Layer 判定（P2b）｜❌ 不改既有 15 行｜❌ 不改任何 skill / config / hook / 代码｜
❌ 不重新归宿已扫过的 137 块（§3 具名延期）｜❌ 不发布

## 6. 写权限（编号即全集，未列出即禁止；git 只允许只读子命令）

1. `.tad/evidence/designs/discipline-inventory/disposition-55.md`（新建）｜
2. `.tad/evidence/designs/discipline-inventory/gate2-candidates.md`（新建）｜
3. `.tad/evidence/designs/discipline-inventory/discipline-inventory.md`（**仅在表体追加行**）｜
4. `.tad/evidence/acceptance-tests/discipline-enumeration/`｜
5. `.tad/archive/handoffs/COMPLETION-20260815-discipline-enumeration.md`

## 7. Acceptance Criteria

**「红」= 脚本 `exit ≠ 0` 且末行 `RESULT=FAIL`。**

| # | AC |
|---|---|
| AC1 | `disposition-55.md` 的「块」三列与 Step 0 冻结的 `blocks.txt` **逐字相等且恰好 55 行**（`LC_ALL=C comm -3` 双向差为空）。⚠️ 一律 TAB 分隔，禁用 `#` 或 `:` 切分——块名含两者 |
| AC2 | 「归宿」列每格匹配 `^(已有:.+\|新增:.+\|非纪律)$`；无空格 |
| AC3 | 归宿=`非纪律` 的行，理由码 ∈ `{R1,R2,R3,R4,R5}`；归宿≠非纪律的行理由码为空 |
| AC4 | 每行「一句话」含一段**该块内可 grep 命中的原文片段**（≥12 字节，`command grep -Fq` 于该块行区间内命中）。⚠️ 这条防"凭印象归宿" |
| AC5 | `discipline-inventory.md` 的**既有 15 行逐字未变**（`git show ${T0}:` 取旧表体，与新表体前 15 行 `diff` 零输出） |
| AC6 | 每条 `新增:` 纪律在 `discipline-inventory.md` 表体中恰好出现 1 次，且该行 **14 列全非空** |
| AC7 | **孤儿行检查**：未扫语料中每一个宽词表命中行的行号，必须落在 `blocks.txt` 某块的行区间内。落在所有块之外的行 → 逐行列出并 FAIL |
| AC8 | `gate2-candidates.md` 恰好 10 行（4 P0 + 6 P1），每行含 `采纳` 或 `驳回`；`驳回` 行须有 ≥20 字节理由；每行须复算审查员给的 `文件:行号` 并标 `属实` 或 `不属实` |
| AC9 | **两端负控**：(a) 全判 `非纪律` 的对抗表必须红（AC8 采纳项无对应新增）；(b) 全判 `新增` 的对抗表必须红（AC4 原文片段对不上）。两份对抗表落盘 `negative-controls/` |
| AC10 | 围栏：改动集 − (§6 五项 ∪ Step0 基线 ∪ glob `.tad/evidence/{traces,decisions}/*.jsonl`) 为空 |
| AC11 | **契约未变**：`git -C "$R" diff --quiet ${T0} -- <本契约>`。⚠️ **外部载体 = git 对象库**，Blake 的 git 只读 → 写不到。**AC 红只能改实现；若判定某 AC 不可满足，停下退回 Alex，不得改 AC 或基线**（P1a 教训：AC9 的冻结物在 Blake 可写目录里，改基线再重冻会让它永远全绿） |

## 8. Step 0

```bash
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/discipline-enumeration"; mkdir -p "$EV/negative-controls"
T0=$(git -C "$R" rev-parse --short HEAD); echo "$T0" > "$EV/t0.txt"
git -C "$R" ls-files --error-unmatch .tad/active/handoffs/HANDOFF-20260815-discipline-enumeration.md \
  >/dev/null 2>&1 || { echo "Step 0 失败：契约未被 git 追踪，AC11 无外部载体"; exit 1; }
cat > "$EV/wide-markers.txt" <<'MARK'
MUST|MANDATORY|BLOCKING|VIOLATION|forbidden|Forbidden|MUST NOT|NEVER|never |shall |required|Required|blocking: *true|不得|必须|禁止|严禁|一律|不可|不允许|应当|⚠️
MARK
# ⚠️ 分隔符必须是 TAB，不能用 # —— markdown 块名本身以 ## 开头，用 # 切会得到 4-5 段
# （Alex 自查实测：55 行里 25 行非三段）。同理不能用 : —— YAML 块名含 `name: gate` 这种。
: > "$EV/blocks.txt"
for f in .claude/skills/gate/SKILL.md AGENTS.md; do
  LC_ALL=C command grep -nE '^[a-z_]+:|^#{2,3} ' "$R/$f" \
    | LC_ALL=C awk -v f="$f" '{i=index($0,":"); printf "%s\t%s\t%s\n", f, substr($0,1,i-1), substr($0,i+1)}' >> "$EV/blocks.txt"
done
for f in .tad/config-cognitive.yaml .tad/config-quality.yaml .tad/config-agents.yaml \
         .tad/config-platform.yaml .tad/config-workflow.yaml; do
  LC_ALL=C command grep -nE '^[a-z_]+:' "$R/$f" \
    | LC_ALL=C awk -v f="$f" '{i=index($0,":"); printf "%s\t%s\t%s\n", f, substr($0,1,i-1), substr($0,i+1)}' >> "$EV/blocks.txt"
done
LC_ALL=C awk -F'\t' 'NF!=3{bad++} END{exit (bad+0)>0}' "$EV/blocks.txt" \
  || { echo "Step 0 失败：blocks.txt 存在非三段行"; exit 1; }
N=$(command grep -c . "$EV/blocks.txt")
[ "$N" -eq 55 ] || { echo "Step 0 失败：块数 $N，应 55（语料或块定义已漂移，停下退回 Alex）"; exit 1; }
{ git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
echo "Step 0 OK: T0=$T0, 55 块已冻结"
```

**开工前先跑负控**：未实现状态运行验证脚本，必须 `exit≠0` 且末行 `RESULT=FAIL`。
若此时已 PASS，说明该 AC 永真，**停下退回 Alex**。

## 9. 已知取舍

1. **已扫语料的 137 块未重新归宿**（§3 具名延期，有复活条件）。风险：原枚举过程若也漏了，
   本单不会发现。缓解：AC7 的孤儿检查只覆盖未扫语料，**这一半是明写的盲区**。
2. **块定义是机械的，会切错边界**：`^[a-z_]+:` 抓不到嵌套两层的协议（如 `gate/SKILL.md` 的
   `### Execution Mandate 准入` 已含在 `^#{2,3}` 内，但四层嵌套的 YAML 子键抓不到）。
   AC7 的孤儿检查是这条的兜底——嵌套块里的强制行若落在父块区间内即算已覆盖，**粒度损失明写**。
3. **"是不是纪律"是判断不是测量**。AC2/AC3/AC4 只验形式与原文可追，验不了裁定本身对不对；
   AC9 的两端负控是唯一的判别力来源。
