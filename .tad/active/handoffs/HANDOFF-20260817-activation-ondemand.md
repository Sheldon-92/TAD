# HANDOFF: 激活按需化 —— 启动扫描从「整读文件」改成「跑命令读输出」

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P3 / 5）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-17 **Rev**: rev1
**配套**（均 commit，AC9 守其哈希）：`*.step0.sh` · `*.pins.tsv`（7 条逐行钉死）

## 1. 目标与实测账

激活时 6 个启动扫描**整读** 7 个文件共 **173,501 B ≈ 43.4K tokens**。改成"跑一条命令、
只读它的输出"后残留约 **840 B ≈ 0.2K**。**这是 Epic 五刀里单笔最大的一块。**

| 被整读的文件 | 字节 |
|---|---|
| `NEXT.md` | **97,369**（占 56%）|
| `.tad/research-notebooks/REGISTRY.yaml` | 42,684 |
| `PROJECT_CONTEXT.md` | 11,871 |
| deps `scan-results` + `REGISTRY` | 14,598 |
| `OBJECTIVES.md` + github `scan-log` | 6,979 |

⚠️ **`.tad/active/session-state.md`（3,235 B）保持整读不变**——它是压缩恢复的安全网，
P2b 地板表判它常驻。**本单不动它。**

## 2. ⚠️ 范围更正：P3 缩回单一动作——只改 7 条读取指令

Epic 上一版把「config 按用途绑定」「知识 `@import` 改索引」并进本单，**实测两条都不成立**：

- **删 5 个死 `@import` 省 0 字节**——它们指向的文件本来就不存在，`@import` 静默跳过。
  真正占地方的是 `principles.md`（25,219 B）。
- **config 按命令绑定不省反增**：STEP 3 现加载 4 个模块，而 `command_module_binding`
  给 `tad-alex` 列了 **5 个**。要省必须改成**按意图加载**——而 **config 里装着纪律**
  （P2a 在 config 里挖出 4 条 P0 级纪律），**把 config 变按需 = 把纪律变按需 = P7 的风险类别**。

**所以合并的轴错了。** 正确的轴是**「这一改会不会让含纪律的内容变成按需」**：
本单**否**（只改指令文本，零纪律内容改变加载时机）→ 低风险；
config / `principles.md` / SKILL 正文**是** → 全部归 P7，同类风险同一刀，出事能定位。

## 3. 改动集

### 3.1 七条逐行钉死：见 `*.pins.tsv`（`ID ⇥ OLD ⇥ NEW`，TAB 分隔）

全部位于 `alex/SKILL.md` 的 STEP 3.4 / 3.5 / 3.5b / 3.8 / 3.9，**每条在 T=0 唯一命中、
NEW 均未出现**（已实测）。改法一律为：把 `Read <整个文件>` 换成 `只跑命令读其输出，禁止整读`。
`.agents/skills/alex/SKILL.md` 镜像同步（实测两侧当前逐字相同）。

⚠️ pins 里的 NEW 含反引号包裹的 shell 命令，**按字面写入，禁止 `eval` 或展开**。

### 3.2 ⚠️ `NEXT.md` 归档**退回杂活**，不在本单

自查发现：pins 应用后激活读的是 `wc -l < NEXT.md` 的**输出**，那一行输出的大小与
`NEXT.md` 有多大**完全无关** → 归档它对激活成本贡献 **0**。原契约却写了条
"阶段 B 测量值须小于阶段 A"的 AC，**不可满足**。
根子是：P4 已移入 P7，**合并不存在了**，为合并准备的"两阶段 + 中间测量"补偿也就没有对象。
**本单缩成单一动作：只改 7 条读取指令。** `NEXT.md` 归档回到杂活清单（它的价值在可读性，不在激活成本）。

## 4. 不做

❌ 不动 `session-state.md` 的整读（压缩恢复安全网）｜❌ 不改 config 加载（P7）｜
❌ 不改 `@import` 与 `principles.md`（P7）｜❌ 不改任何 hook / 代码｜❌ 不归档 `NEXT.md`（见 §3.2）｜
❌ 不删任何扫描步骤——**只改它怎么读**（依赖扫描是唯一有真实事故记录的启动纪律：
停跑 28 天漏掉 `gh` 4 个漏洞含明文 token）｜❌ 不发布

## 5. 写权限（编号即全集；git 只允许只读子命令）

1. `.claude/skills/alex/SKILL.md`｜2. `.agents/skills/alex/SKILL.md`｜3. `.tad/evidence/acceptance-tests/activation-ondemand/`｜
4. `.tad/archive/handoffs/COMPLETION-20260817-activation-ondemand.md`

## 6. Acceptance Criteria

**「红」= `exit ≠ 0` 且末行 `RESULT=FAIL`。** TAB 分隔，禁 `#`/`:` 切分。

| # | AC |
|---|---|
| AC1 | pins 7 条：每条 OLD 计数 **0**、NEW **恰好 1**，两个 alex 文件各查一遍（`grep -cFx`，字面读取禁展开） |
| AC2 | **冻结补集**：两个 alex 文件中除 7 条钉死行外的每一行相对 T0 逐字相同（**含纯增行**，用 `diff` 不用集合差） |
| AC3 | `Read .tad/active/session-state.md (if exists).` 一行**逐字仍在**（压缩恢复安全网未被顺手砍掉） |
| AC4 | **行为负控（本单最要紧的一条）**：把 `scan-results.yaml` 复制一份、注入一条伪造的 `security_advisories:` 条目，跑 pins#2 的新命令，**必须仍然报出该条**；再删掉重跑，计数须回落。原文与两次输出落盘。⚠️ 这条买的是"没把响亮失败换成静默成功"——依赖扫描是唯一有真实事故记录的启动纪律（停跑 28 天漏掉 `gh` 4 个漏洞含明文 token） |
| AC5 | **纪律不流失**：`MUST`／`MANDATORY`／`VIOLATION`／`forbidden`／`不得` 在两个 alex 文件上**逐类**计数 == Step 0 基线 |
| AC6 | **测量落盘**：`measure-after.txt` 存在且含实测「激活时整读字节数」；该值 < `measure-base.txt`，**且降幅 ≥ 150,000 B**（7 源合计 173,501 B，留余量） |
| AC7 | parity：`.claude` 与 `.agents` 的 alex `cmp -s` 逐字相同 |
| AC8 | 围栏：改动集 −(§5 四项 ∪ Step0 基线 ∪ glob `.tad/evidence/{traces,decisions}/*.jsonl`) 为空 |
| AC9 | **契约与两个配套文件均未变**：`git diff --quiet ${T0} -- <三文件>`。**AC 红只能改实现；判定某 AC 不可满足 → 停下退回 Alex** |
| AC10 | **三份负控全红**：(a) 只改一半 pins → AC1 拦 (b) 顺手删掉 session-state 那行 → AC3 拦 (c) 把某条 NEW 的命令改回整读该文件 → AC6 降幅门槛拦。任一为绿 → 停下退回 Alex |

## 7. 环境约束（本机实测）

`grep` 是 ugrep 包装 → 一律 `command grep`；`grep -c` 无命中 exit 1 → 加 `|| true`；
`sort`/`uniq`/`comm` 前必须 `LC_ALL=C`；`for f in $VAR` 在 zsh 下只迭代 1 次 → **显式列出**；
**中文文案里的变量必须写 `${VAR}`**；脚本装 `trap … EXIT` + `DONE=1` 保证任何中止都留下 `RESULT=` 末行；
`ls dir/*.md` 无匹配时 zsh 报错 → 加 `2>/dev/null` 或 `setopt null_glob`。

## 8. Step 0

运行 `*.step0.sh`：冻结 `pins-verified.txt`（7 条 OLD 唯一性实测）· `discipline-baseline.txt`
（两个 alex 文件五类计数）· `measure-base.txt`（改动前激活即付读取字节）· `fence-baseline.txt`，
并断言 pins 每条 OLD 在两个 alex 文件各唯一命中（不符即中止退回 Alex）。

**逐条 AC 单独跑负控**（非整脚本一次）：任一 AC 未实现态即绿 = 永真，**停下退回 Alex**。

## 9. 已知取舍

1. **替换后的命令由 Alex 写死**，未经第二双眼睛校准命令本身是否取到了原步骤需要的全部信息。
   AC4 只覆盖依赖扫描一条（唯一有事故记录的），**其余 5 条的"信息是否够用"未验** —— 明写。
2. **本单不碰 config / 知识 / SKILL 正文**（§2），故激活即付**不会**一次到位降到 SC1 目标；
   预期落点约 **107.7K − 43.2K ≈ 64K**，其余归 P7。
