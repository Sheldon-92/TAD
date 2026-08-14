# HANDOFF: 地板表 —— 每条纪律的载体该常驻还是按需

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P2 / 5）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-15 **Rev**: rev1
**T0**: `<Step 0 填入>`

## 1. 目标

产出 `.tad/discipline-floor.md`：**已有的 15 条纪律**，每条标注它的载体
**必须常驻（Layer 0）／可按意图加载（Layer 1）／可按档位加载（Layer 2）**，以及**是否不可降级**。

**本单不改任何代码。** 它是 P3/P4/P7 三刀的判断依据——没有它，那三刀无从判断"这条能不能挪"。

## 2. 输入（既有资产，不得重新发明）

| 资产 | 用途 |
|---|---|
| `.tad/evidence/designs/discipline-inventory/discipline-inventory.md` | **15 条纪律 × 14 列**，含「地板/可缩放/待判」判定。**本单的行集合必须与它逐字相等** |
| `principles.md#L103`「Execution Discipline Content Must Stay in SKILL Body — Circular Trigger Test」 | **Layer 0 的现成判据**：若 `load_when` 触发词定义在被加载物内部，则不加载就永远不触发 → 必须常驻 |
| `.tad/project-knowledge/patterns/_index.md`（2181 bytes 索引 10 个文件） | Layer 0 该长什么样的样本：**放索引不放内容** |

## 3. 产物格式（`.tad/discipline-floor.md`）

### 3.1 主表（15 行，行名与 §2 第一项逐字相等）

| 列 | 取值 | 说明 |
|---|---|---|
| 纪律 | 逐字取自 discipline-inventory | 集合相等，不增不减 |
| 既有判定 | 地板 / 可缩放 / 待判 | 逐字搬运，**本单不得改判** |
| 载体 | `路径#锚点串` | 锚点串须能在该文件 `grep -Fq` 命中 |
| 触发（Layer 0 候选） | 逐字串，或 `—` | 让 agent 知道"这件事存在"的最短文本 |
| 本体 | 路径 | 怎么做的细节，可懒加载 |
| Layer | `0` / `1` / `2` | 触发归 0；本体按意图归 1、按档位归 2 |
| 不可降级 | 是 / 否 | 是 = 任何档位判定都不得使其不加载 |
| 不常驻会怎样 | 一句话 | **必须含具体机制**（文件名或步骤名），不接受"很重要"这类 |

### 3.2 副表：Layer 0 里的非纪律常驻项

身份与角色分离 / 意图路由 / 复杂度判定 / 压缩恢复锚点——四项各一行，同样给出触发串与字节数。
**没有这张副表，Layer 0 就没被穷举，AC4 的字节预算也就无从谈起。**

### 3.3 待判行的处置

`discipline-inventory` 里有 **5 行判为「待判」**（知识评估 / 跨模型审查 / 配对测试 /
Execution Mandate / 约束准入）。本单**不得改判**，但每行必须填「解除待判需要什么」——
一句可执行的条件（例：需要一次非框架任务的实例）。留空 = FAIL。

### 3.4 必须点名的缺口（原 P1a 遗留 L3 的实质）

实测 `.tad/ralph-config/expert-criteria.yaml` 的 security-auditor 触发模式为
`auth|token|password|credential|api.*key|encrypt|decrypt|session|cookie|sql|query|upload|file|exec|eval`
——**不含任何框架路径**。即改 `CLAUDE.md` / skills / hooks / `settings` / `tad.sh`
**在 full 通道同样不触发安全审查**。表中「不可降级」那组必须点名此缺口并给出建议载体。
⚠️ **本单只点名，不改 `expert-criteria.yaml`**（改它属独立单）。

⚠️ 原 L1（契约缺档位段无机械检查）**判为失效**：它约束的是 blake-lite 的档位机制，
lite 已冻结不接新工作。若档位机制日后移入 full，L1 随之复活——本单在表末一行记此判定与复活条件。

## 4. 不做

❌ 不改任何代码、skill、config、hook｜❌ 不改 `expert-criteria.yaml`｜
❌ 不改 `discipline-inventory` 的既有判定｜❌ 不实施任何 Layer 迁移（那是 P3/P4/P7）｜
❌ 不发布

## 5. 写权限（编号即全集，未列出即禁止；git 只允许只读子命令）

1. `.tad/discipline-floor.md`（本单新建）｜2. `.tad/evidence/acceptance-tests/discipline-floor/`｜
3. `.tad/archive/handoffs/COMPLETION-20260815-discipline-floor.md`

## 6. Acceptance Criteria

**「红」= 脚本 `exit ≠ 0` 且末行 `RESULT=FAIL`。**

| # | AC |
|---|---|
| AC1 | 主表行名集合与 `discipline-inventory.md` 的 15 条**逐字相等**（`comm -3` 双向差为空） |
| AC2 | 「既有判定」列逐行与 discipline-inventory 的「地板·可缩放」列**逐字相同**（本单不得改判） |
| AC3 | **载体可验**：每行的 `路径#锚点串`，路径存在且 `command grep -Fq 锚点串 路径` 命中。任一不中 = FAIL |
| AC4 | **Layer 0 字节预算**：主表 + 副表中所有 `Layer=0` 行的**触发串**字节总和 **≤ 8192**。⚠️ 这条是防「全判 Layer 0」——治理疲劳与合规敞口是分级的两个失败端，本 AC 守其中一端 |
| AC5 | **Layer 0 下限**：`Layer=0` 行数 **≥ 5**，且必须包含「角色分离」与「意图路由」。⚠️ 守另一端：防「全判按需」 |
| AC6 | 每个 `Layer=0` 行的「不常驻会怎样」**含至少一个具体载体名**（`.md`/`.yaml`/`.sh` 文件名或带 `L`/`Gate`/`STEP` 前缀的步骤名）。纯形容词 = FAIL |
| AC7 | 每个 `Layer=0` 判定必须在「不常驻会怎样」里**援引循环触发测试**（含字串 `循环触发` 或 `load_when`），或显式写明 `非循环触发·理由：{…}` |
| AC8 | 5 行「待判」各有非空「解除待判需要什么」，且**不得**出现 `TBD`／`待定`／`N/A` |
| AC9 | 「不可降级」组非空，且**至少含**凭据/密钥、对外发布或同步、修改框架自身三类；§3.4 的 `expert-criteria` 缺口被点名（含字串 `expert-criteria`） |
| AC10 | L1 失效判定在文（含字串 `L1` 与 `复活条件`） |
| AC11 | 围栏：改动集 − (§5 三项 ∪ Step0 基线 ∪ glob `.tad/evidence/{traces,decisions}/*.jsonl`) 为空 |
| AC12 | 本契约相对 Step 0 冻结的 `sha256` 未变。⚠️ **AC 红只能改实现**——若你判定某条 AC 本身不可满足，**停下来退回 Alex**，不得自行修订 AC 或基线（P1a 教训：唯一执行者即被约束方时，改基线再重新冻结会让该 AC 永远全绿） |

## 7. 环境约束（本机实测，违反即静默失败）

`grep` 是 ugrep 包装 → 一律 `command grep`；`grep -c` 无命中 exit 1 → 加 `|| true`；
`grep -F` 模式以 `- ` 开头须加 `-e`；`sort`/`uniq`/`comm` 前必须 `LC_ALL=C`（否则中文串判为相等）；
`for f in $VAR` 在 zsh 下只迭代 1 次 → 显式列出；**中文文案里的变量必须写 `${VAR}`**
（`$VAR` 紧跟全角字符会吞掉多字节首字节，`set -u` 下杀脚本）；
脚本装 `trap … EXIT` + `DONE=1`，保证任何中止路径都留下 `RESULT=` 末行（**崩溃 ≠ 红**）；
`awk '/^## X/,/^## /'` 起止同行命中会只吐标题行 → 用 `sed` 两段式取节。

## 8. Step 0

```bash
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/discipline-floor"; mkdir -p "$EV"
T0=$(git -C "$R" rev-parse --short HEAD); echo "$T0" > "$EV/t0.txt"
( cd "$R" && shasum -a 256 .tad/active/handoffs/HANDOFF-20260815-discipline-floor.md ) > "$EV/inputs.sha256"
{ git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
# 冻结 15 条行名（AC1 的比对基准），逐字取自 discipline-inventory 表体第 1 列
sed -n '/^| 纪律 | 来源 |/,/^$/p' "$R/.tad/evidence/designs/discipline-inventory/discipline-inventory.md" \
  | command grep -v '^| 纪律 \|^|---' | LC_ALL=C awk -F'|' 'NF>2{gsub(/^ +| +$/,"",$2); if($2!="")print $2}' \
  | LC_ALL=C sort > "$EV/rows-expected.txt"
[ "$(command grep -c . "$EV/rows-expected.txt")" -eq 15 ] || { echo "Step 0 失败：取到 $(command grep -c . "$EV/rows-expected.txt") 行，应 15"; exit 1; }
echo "Step 0 OK: T0=$T0, 15 行基准已冻结"
```

**开工前先跑负控**：未实现状态运行验证脚本，必须 `exit≠0` 且末行 `RESULT=FAIL`。
若此时已 PASS，说明该 AC 永真，**停下退回 Alex**。

## 9. 已知取舍

1. **这张表是判断，不是测量**。AC3-AC9 只能验"形式齐全、载体真实、两端不塌"，
   **验不了判定本身对不对**——那要等 P3/P4/P7 真去挪的时候才被证伪。刻意接受。
2. **8192 字节的预算是设定值不是实测值**：取自 `patterns/_index.md` 用 2181 bytes 索引 10 个文件的比例外推
   （15+4 行 × 约 150 字节触发串 ≈ 2.9K，留约 2.8 倍余量）。若实现时逼近上限，**说明判定过宽，退回 Alex 重议，不得调高预算**。
3. **副表四项的边界是 Alex 划的**，没有第二双眼睛看过"是不是还有第五项常驻物"。
