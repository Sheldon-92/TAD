# HANDOFF: 路由脱钩（行为侧）—— 默认改回 Alex/Blake，lite 冻结为实验

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P1a / 7）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-14
**Rev**: **rev2** —— Gate 2 三专家并行（AC 判别力 / 授权边界+静默失败 / 穷举），**共 11 个 P0**，全部修在本 rev
**T0**: `<Step 0 填入>` **配套数据文件**（均由 AC9 冻结哈希）: `*.pins.tsv`（19 条单行钉死）· `*.block-a.txt` · `*.block-b.txt` · `*.block-c.txt`

## 1. 目标与切分

把「默认走 lite」从**会改变行为、或用户会照着敲**的载体里拿掉，默认改回 `/alex` `/blake` `/gate`；
lite 标为**已冻结的实验**——不接新工作，**显式调用时完全可用**。

**rev1 只覆盖 7 个文件是错的**（Gate 2 穷举审查实测）。最严重的遗漏是 **`tad.sh`**——
rev1 拿"`INSTALLATION_GUIDE.md` 在误导新项目"当立项理由，却漏掉了**每次安装真正在跑、
并逐字打印 `Default channel` 指向 lite** 的那个脚本。同类遗漏还有 `/tad-help`（用户问"用哪个通道"
的产品内答案）。

**本单 = P1a（行为侧）。** 纯版本横幅（`README.md` 9 处、`PROJECT_CONTEXT.md`、
`docs/MULTI-PLATFORM.md`、`.tad/config.yaml` 首行，全是 `Version 2.41.0 - Lite is the Default Channel`
这一形态）划归 **P1b**，随发版统一重写——**不是遗漏，是具名延期**（AC6 排除集会点名它们）。

## 2. ⚠️ 冻结 ≠ 停用

Epic 明写 lite **冻结保留作对照物**，参照物被改动过就不再是参照物。因此 `/alex-lite` `/blake-lite`
被**显式调用**时其协议必须逐字照旧，已存在的 `LITE-*.md` 照旧跑完；本单**只改"我是默认通道"
这类声明，不动任何执行协议**——AC3 用整文件哈希守死这条。

## 3. 改动集

### 3.1 单行钉死：见 `*.pins.tsv`（19 条，4 列 `ID⇥FILE⇥OLD⇥NEW`）

覆盖 `CLAUDE.md`×8 · `AGENTS.md`×3 · `INSTALLATION_GUIDE.md`×1 · `tad.sh`×3 ·
`tad-help`×2（两套镜像）· `alex-lite` description×2（两套镜像）。

⚠️ **该文件必须按字面读取，禁止 `eval` 或任何形式的展开**——第 13-15 条含 `${CYAN}` `${NC}`，
它们是 `tad.sh` 的源码字面量，展开即损坏。用 `while IFS=$'\t' read -r id f old new` + `grep -Fx`。
⚠️ 19 条已实测：OLD 在目标文件各唯一命中 1 次、NEW 各 0 次，且 OLD/NEW 全集内无撞车
（替换顺序不影响结果）。

### 3.2 / 3.3 块替换：新块内容在**独立文件**里，不在本契约

| 块 | 目标 | 旧块（T=0 逐字，实测各唯一命中 1 次） | 新块文件 |
|---|---|---|---|
| A | `INSTALLATION_GUIDE.md` L57-63 | 那 7 行（`# 默认通道（lite …）` 起至 `/blake  # Terminal 2: 实现与执行` 止） | `*.block-a.txt`（7 行） |
| B | 4 个 lite skill | `## Lite-First 政策（默认通道，不可妥协）` + 其后 5 条 bullet | `*.block-b.txt`（8 行，含哨兵） |

⚠️ **块 A 是整块替换不是逐行**：默认块必须排在前面（新用户复制第一段），逐行替换会让新旧字符串互撞。
⚠️ **块 B 内一个字节都不许自由发挥**——rev1 的块是 AC 豁免区，往里加一句不含关键词的话可以 12 条全绿。
AC2 对文件哈希断言。rev1 声称两条 bullet"逐字搬运"是**错的**，rev2 不再声称，改为**可解释的差异**
（已实测）：第 4 条 bullet 逐字相同；第 3 条与旧块的差异**恰好**是删除子串 `按"lite 是默认"`；
被删的另 3 条 bullet **零纪律关键词**（`MUST/MANDATORY/VIOLATION/forbidden/不得` 各 0）。

### 3.4 块替换 C —— `CLAUDE.md` §2.5 那条长行（1 行 → 2 行）

旧文 = `### 2.5` 标题之后那一整行（`` `/alex-lite` → `/blake-lite`：**默认通道**。…`` 起至行尾），
T=0 唯一命中。新文见 `*.block-c.txt`（2 行）。

⚠️ 新文**必须含「不得」**——`CLAUDE.md` 的 `不得` 在 T=0 实测计 3（第 22/49/52 行），旧行是其中一条；
rev1 的新文一个都没有 → AC7 必红。（`principles.md` 2026-05-31：改写引用了约束的散文时，
保留约束名，计数才稳、引用才真。）

### 3.5 派生物与版本

- `.tad/brain-index.md` 第 50-51 行**逐字复制**了被删的旧路由文本 → 跑
  `bash .tad/hooks/lib/brain-index-gen.sh` 重新生成
- `.tad/version.txt`：`2.41.0` → `2.42.0`

## 4. 不做（每条都是裁定，不是遗漏）

- ❌ **不发布**（`*publish` 是对外动作，交付后由人单独决定）
- ❌ **不改 `.tad/routing-contract.yaml`** —— 实测它自述 `policy for route decisions across
  Alex-Lite and Blake-Lite`，管的是 lite **内部**深度档位，且无任何活代码读它。属 §2 冻结范围。
- ❌ **不给 full 补「修改框架自身须由人裁定」的门** —— **用户 2026-08-14 明确裁定"不加"**。
  ⚠️ **已知代价（写在这里，不假装没有）**：该规则实测只活在 `CLAUDE.md §2.5` 与两个 lite skill，
  三个 full skill 各 0 次命中。本单把 §2.5 限定到"在飞单"之后，**默认路径上不再有这条门**，
  而 `CLAUDE.md:43` 的「跳过 TAD：……文档更新……」使同类编辑可自判为可跳过。
  即本单净效果是**少了一条纪律**，与 Epic Objective「纪律一条不减」相悖。已记入 Epic 风险表。
- ❌ 不改 lite 的任何执行协议 ❌ 不删 lite skill 文件 ❌ 不动 full 的任何 skill
- ❌ 不做 P1b 版本横幅（见 §1）

## 5. 写权限（编号即全集，未列出即禁止；git 只允许只读子命令）

1. `CLAUDE.md`｜2. `AGENTS.md`｜3. `INSTALLATION_GUIDE.md`｜4. `tad.sh`｜5. `.tad/version.txt`｜
6. `.tad/brain-index.md`｜7. `.claude/skills/{alex-lite,blake-lite,tad-help}/SKILL.md`｜
8. `.agents/skills/{alex-lite,blake-lite,tad-help}/SKILL.md`｜
9. `.tad/evidence/acceptance-tests/routing-decouple/`｜10. `.tad/archive/handoffs/COMPLETION-20260814-routing-decouple.md`

## 6. Acceptance Criteria

**「红」= 脚本 `exit ≠ 0` 且末行 `RESULT=FAIL`。**
**扫描域**：除 AC6 另有定义外，一律 = §5 第 1-8 项列出的 11 个文件。

| # | AC |
|---|---|
| AC1 | pins.tsv 19 条：每条 OLD 计数 **0**、NEW **恰好 1**（`grep -cFx`，字面读取禁展开） |
| AC2 | 块替换 A/B：`INSTALLATION_GUIDE.md` 新块、4 个 skill 的 `LITE-FROZEN` 区间，各自 `sha256` **等于 Step 0 从本契约冻结的期望值**（块内零自由发挥） |
| AC3 | **lite 协议未动**：4 个 lite skill 各自「整文件减去哨兵块区间」的 `sha256` == T0「整文件减去旧块区间」的 `sha256` |
| AC4 | **重建比对（吃掉 AC1/AC2 的自由度）**：把 T=0 的每个文件取出到临时目录，**只施加** pins.tsv 的 19 条替换 + block-a/b/c 三个块替换，得到"期望态"；`diff 期望态 线上文件` 必须**零输出**。⚠️ 期望态由**冻结输入机械重建**，不是被验方产出的 diff 文件（否则自证）；`diff` 而非集合差——集合差看不见"重复插入一行已存在的行"和空行 |
| AC5 | parity：`alex-lite` / `blake-lite` / `tad-help` 三对 `.claude` ↔ `.agents` 各 `cmp -s` 相同 |
| AC6 | **穷举**：模式集（**大小写不敏感**）`默认通道｜保留通道｜默认走 lite｜Lite-First｜default channel｜reserved channel｜default workhorse｜Default — TAD Lite｜Lite is the Default` 在 `git ls-files` 全集上计数 **0**；排除集 = Step 0 冻结的 `$EV/ac6-exclude.txt`（含 `.tad/archive/**`、`.tad/evidence/**`、`CHANGELOG.md`、`.tad/active/handoffs/**`、`.tad/active/epics/**`、`.tad/project-knowledge/**`，及 P1b 四文件）。**排除集实现期不得扩大**（AC9 守） |
| AC7 | **纪律不流失**：`MUST｜MANDATORY｜VIOLATION｜forbidden｜不得` 在 **6 个文件**（`CLAUDE.md`、`AGENTS.md`、4 个 lite skill **含 `.agents` 镜像**）上**逐类**计数 == Step 0 基线 |
| AC8 | `.tad/version.txt` == `2.42.0`；`brain-index.md` 中 `默认走 lite` 计数 0 |
| AC9 | **Step 0 冻结物未被改**：`$EV/{ac6-exclude.txt,discipline-baseline.txt,fence-baseline.txt}` 与 `inputs.sha256` 所列五个输入文件的 `sha256` 全部未变。**AC 红只能改实现，不得改基线或 AC** |
| AC10 | **行为回读**：spawn 1 个 fresh subagent，**只喂改后的 `CLAUDE.md` + `AGENTS.md`**，问「用户说『帮我加个新功能，涉及 5 个文件』，该走哪条通道？」——必须答 `/alex`，且**不得**把 lite 列为可选项。原文落盘 |
| AC11 | 围栏（集合包含）：`改动集 − (§5 十项 ∪ Step0 基线 ∪ glob '.tad/evidence/{traces,decisions}/*.jsonl')` 为空 |

## 7. 环境约束（本机实测，违反即静默失败）

`grep` 是 ugrep 包装 → 一律 `command grep`；`grep -c` 无命中 exit 1 → 加 `|| true`；
`grep -F` 模式以 `- ` 开头须加 `-e`；`sort`/`uniq` 前必须 `LC_ALL=C`；
`for f in $VAR` 在 zsh 下只迭代 1 次 → 显式列出；**中文文案里的变量必须写 `${VAR}`**
（`$VAR` 紧跟全角字符会吞掉多字节首字节，`set -u` 下杀脚本）；
脚本装 `trap … EXIT` + `DONE=1`，保证任何中止路径都留下 `RESULT=` 末行（**崩溃 ≠ 红**）；
hook 每日写 `traces/decisions/<date>.jsonl`，**跨午夜会从 2 个变 4 个** → 用 glob 不用定数。

## 8. Step 0（动手前，一次冻结全部基线）

```bash
R="/Users/sheldonzhao/01-on progress programs/TAD"; EV="$R/.tad/evidence/acceptance-tests/routing-decouple"
mkdir -p "$EV"; T0=$(git -C "$R" rev-parse --short HEAD); echo "$T0" > "$EV/t0.txt"
( cd "$R" && shasum -a 256 .tad/active/handoffs/HANDOFF-20260814-routing-decouple.{md,pins.tsv,block-a.txt,block-b.txt,block-c.txt} ) > "$EV/inputs.sha256"
{ git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
for f in CLAUDE.md AGENTS.md .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
         .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  for k in MUST MANDATORY VIOLATION forbidden 不得; do
    echo "${f}|${k}|$(LC_ALL=C command grep -cF -e "$k" "$R/$f" || true)"
  done
done > "$EV/discipline-baseline.txt"
# 另需冻结：$EV/ac6-exclude.txt（AC6 排除集，路径清单——冻结后不得扩大）
# AC4 无需冻结 diff：期望态由 T=0 + pins.tsv + block-a/b/c 机械重建
echo "Step 0 OK: T0=$T0"
```

**开工前必须先跑负控**：未实现状态下运行验证脚本，必须 `exit≠0` 且末行 `RESULT=FAIL`；
若此时已 PASS，说明该 AC 永真，**停下改 AC 而不是继续**。

## 9. 已知取舍

1. **少了一条纪律**（§4 第 3 条），用户裁定，已记入 Epic 风险表。
2. **P1b 未做**：README / PROJECT_CONTEXT / MULTI-PLATFORM / config.yaml 的版本横幅仍写
   "Lite is the Default Channel"，直到 P1b 或发版。AC6 排除集**点名**它们，不是默默漏掉。
3. **AC10 的判定是模型输出**，不是机械断言——它买的是"消费者视角"，代价是可复现性弱于其余 AC。
