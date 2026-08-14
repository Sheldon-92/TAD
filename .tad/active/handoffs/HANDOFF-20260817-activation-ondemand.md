# HANDOFF: 激活按需化 —— 启动扫描从「整读文件」改成「跑命令读输出」

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P3 / 5）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-17 **Rev**: **rev3**
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
| AC2 | **冻结补集**：`diff <(git show ${T0}:<path>) <path>` 后，按下述管道过滤须**残余 0 行**——⚠️ 排除必须带 `-x`，否则模式文件里的空行会匹配所有行、本条静默全绿（审查员实测）：<br>`diff … \| grep -vE '^[0-9]+(,[0-9]+)?[acd][0-9]+(,[0-9]+)?$' \| grep -vx -e '---' \| sed -e 's/^< //' -e 's/^> //' \| grep -vxF -f olds.txt \| grep -vxF -f news.txt` |
| AC3 | `Read .tad/active/session-state.md (if exists).` 一行**逐字仍在**（压缩恢复安全网未被顺手砍掉） |
| AC4 | **行为负控**：把 `scan-results.yaml` 复制一份，把 `gh` 那条的 `security_advisories: []` 逐字替换为 `security_advisories:` + 次行 `      - id: "GHSA-FAKE-0001"`，跑 pins#2 命令 → 输出**须含 `adv=YES`**；改回 `[]` 重跑 → **须含 `adv=none`**。两次输出与注入 diff 全部落盘。⚠️ rev1 的命令数的是**键行**，而仓库现有 6 条全是 `[]` → 恒定输出 `adv=6` = **永久假警报**，且对真实告警全盲；rev1 的 AC4 只比 delta，对此完全无感 |
| AC5 | **纪律不流失**：五类计数 == Step 0 基线。⚠️ 明记：本单 14 个 OLD/NEW 串一个五类词都不含，故本条**按构造不可能红**，判别力由 AC2 承担，此处仅作防未来漂移的冗余保险 |
| AC6 | **逐源断言，限定在激活块内**：先机械取激活块——`awk` 从 `^activation-instructions:` 起、到**下一个顶格键**前一行止（实测 L202..L469，**不得硬编码行号**）；在该切片内，**8 个源**（`NEXT.md` `PROJECT_CONTEXT.md` 研究 `REGISTRY.yaml` deps `scan-results.yaml` deps `REGISTRY.yaml` `OBJECTIVES.md` github `scan-log.yaml` `ROADMAP.md`）各自的 `Read <该文件>` 计数 **== 0**，两个 alex 文件都要查。⚠️ **rev2 写成全文件断言是错的**：`alex/SKILL.md:890` 的 `Read .tad/research-notebooks/REGISTRY.yaml` 属 `research_unified_protocol` 的 `1_find_notebook`（顶层键 L825），只在 `*research` 被显式调用时跑，**不在激活路径上**，且 T0 即存在。全文件断言使本条**对一个正确的实现必红**。⚠️ 同时补一条**反向断言**：该激活块切片的行数须 ≥200（防"把整块删掉"这种让断言空真的做法） |
| AC7 | **命令可跑**：把 7 条 NEW 里反引号内的命令逐条抽出实跑，落盘各自输出与 exit code。断言：全部 `exit 0`、输出非空（pins#3 用真实依赖名替换 `{上一步输出的依赖名}`）。⚠️ rev1 无此条，实测 rev1 的 pins#3 按字面跑输出 **0 行** |
| AC8 | parity：`.claude` 与 `.agents` 的 alex `cmp -s` 逐字相同 |
| AC9 | 围栏：改动集 −(§5 四项 ∪ Step0 基线 ∪ glob `.tad/evidence/{traces,decisions}/*.jsonl`) 为空 |
| AC10 | **契约与两个配套文件均未变**：`git diff --quiet ${T0} -- <三文件>`。**AC 红只能改实现；判定某 AC 不可满足 → 停下退回 Alex**。⚠️ **rev3 的 T0 已变**（Alex 修 AC6 后重新 commit）——须**重跑 Step 0** 取新 T0，勿沿用 rev2 的 |
| AC11 | **三份负控全红**：(a) 只改一半 pins → AC1 拦 (b) 顺手删掉 session-state 那行 → AC3 拦 (c) **把 pins#6 的 NEW 改回 `Read .tad/github-registry/scan-log.yaml`** → **AC6 逐源断言拦**（rev1 此处用总量门槛，该源仅 1,950 B，回退后仍绿）。任一为绿 → 停下退回 Alex |

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

1. **7 条命令已由 Gate 2 第二位审查员逐条实跑校准**（原 rev1 有 4 条不够用：文档健康缺僵尸检测三字段、
   依赖扫描缺 changelog 且 `adv` 恒假、依赖详情无锚匹配取到别的依赖、研究图景取到 dormant 的 topic 且多数一行注释）。
   替换后实跑合计 **6,892 B**（基线 173,501 B，降幅 166,609 B）。**pins#7（ROADMAP）信息有损但有界**：
   全仓对它只有该一处引用、无机械消费者。
2. ⚠️ **存量 bug（非本单造成，须另开单）**：STEP 3.5b 的 Path 2 正则是 `/CVE-\d{4}-\d+/`，
   而本单 §4 引用的那起事故（漏掉 `gh` 4 个漏洞）用的是 **GHSA 编号不是 CVE**——**原正则本来就抓不到**。
   本单的替代命令已把 `GHSA-` 并入判定，但**原步骤正文里的那条正则未改**（不在写权限内）。
3. **本单不碰 config / 知识 / SKILL 正文**（§2），故激活即付**不会**一次到位降到 SC1 目标；
   预期落点约 **107.7K − 43.2K ≈ 64K**，其余归 P7。


## 10. rev2 → rev3 修订记录（2026-08-17）

**Blake 在 AC6 处停下退回，未自行修改——契约那条"判定某 AC 不可满足 → 停下退回 Alex"第一次生效。**

**他报的属实（Alex 独立核实）**：`alex/SKILL.md:890` 的 `Read .tad/research-notebooks/REGISTRY.yaml`
位于 `research_unified_protocol`（顶层键 L825）的 `1_find_notebook`，是 `*research` 流程、
不在激活路径；T0 即存在，非本单造成。**激活块（L202..L469）内 8 个源命中全部为 0**
——即 7 条 pins 已正确应用，**红的是断言范围，不是实现**。

**Alex 裁定：收窄 AC6 到激活块**（机械取块，不硬编码行号），并补反向断言防空真。

**未采纳的两个选项**：
- 扩 pins 到 8 条 → 会改动研究流程，那里需要 registry 做任意用户话题的语义匹配，
  pins#4 的 active 列表未必够，**超出本单目的且引入未验证风险**。
- 记为已知例外 → 例外清单是东西藏起来的地方，收窄范围更真也更可查。

**责任归属**：AC6 的范围写错是 **Alex 的缺陷**，两位 Gate 2 审查员均未捕获
（他们审的是"总量门槛不可复算"，修法给的是逐源断言，**范围维度无人审**）。
