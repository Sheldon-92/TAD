> # 🛑 BLOCKED — 不要执行本单（2026-08-15，Alex 自判，用户裁定"记录下来"）
>
> **三轮专家审查、共 18 个 P0，每轮都找出新的一批。停下的理由不是"改不完"，是结构问题：**
>
> **S0 要改的文件，正是验证 S0 的机器要测量的文件。** 往 `gate/SKILL.md` 插一个锚 →
> 地板表记录的「载体文件字节总和」就变 → 地板表必须重新生成 → 但它不在写权限里。
> 两条路都坏：真做成不写文件，地板表**静默过时**；照现在写文件，**围栏判红**。
> **AC 再写第四版也解不开这个结。**
>
> **正确做法：S0 的三项拆成三张各自独立的小单**，每张只碰一个文件，
> 验证器与被验证物就不在同一个改动里。三项各自独立有价值，捆一起才产生死结。
>
> **优先做第 ①，它跟英文化毫无关系，是个真 bug**：见 `NEXT.md`。
>
> ⚠️ **本单的调研成果仍然有效**（范围实测、路由面冲突的裁定、13 类归属），重做时直接引用，别重新量。

---

# HANDOFF: 先修被中文字面量绑架的纪律，再谈英文化

**From**: Alex（full） **To**: Blake **Created**: 2026-08-15
**Rev**: **rev3**（复审 4 个阻塞项；其中一条指出 rev2 的 S0.1 **会让 Gate 3 更脆**）
**血统**: rev1 被 13 个 P0 打回 → rev2 重划。rev1 被两位专家共 **13 个 P0** 打回，其中一条不是契约缺陷，
是**用户要求本身的内部冲突**（见 §1.2）。rev2 拆成 S0/S1/S2，**S0 与翻译无关但必须先做**。

**用户裁定（2026-08-15）**：
① 产物统一英文，对话跟随用户 ② 那 34 个包的**中文路由关键词保留**（选项 A）

## 1. 病

### 1.1 纪律被中文字面量绑架，而且现在就在漏

**不是"翻译会打断检查链"，是检查链已经靠中文字面量维系**。三处实测：

| 位置 | 现状 | 后果 |
|---|---|---|
| `.tad/hooks/pre-gate-check.sh:192` | `grep 'Gate 3.*结果\|Gate 3.*Result'` | 这是 **Gate 3 FAIL 唯一的 BLOCK 路径**（`.claude/settings.json:59` 注册的活 hook）。模板里那句话改成 `Verdict` / 小写 `result` → **拦截静默失效** |
| `.tad/hooks/pre-gate-check.sh:164` | `grep '是否有新发现\|New discoveries'`（大小写敏感） | 规则 5 的 Knowledge Assessment 检测锚点，同病 |
| `.tad/hooks/lib/skill-body-verify.sh:55-56` | `grep -cE 'MUST\|MANDATORY\|VIOLATION'` ≥ **70** | 唯一的**内容级**闸。`blake/SKILL.md` 现为英文 84 / 中文 25。**翻译后计数 → ~109，余量 14 → 39** —— 翻完可静默删掉 39 条真约束而闸依然绿，判别力降到 1/2.8 |

⚠️ **这三条不翻译也该修。** 它们现在就是漏的。

### 1.2 用户的两个要求在「路由面」上对撞 —— 已裁定

34 个 SKILL 的 frontmatter `keywords:` 是**中英混排**（`["学术","academic","论文","paper"]`），
`save-skill` 的触发串直接是 `把这个存成 skill`。**这些不是文案，是路由数据**——
用户说「帮我查文献」靠 `文献` 命中 `academic-research`。

**翻掉 = 破坏「agent 可以跟随用户用中文」这件事本身。**
→ **用户裁定：保留中文关键词（选项 A）。** 它们现已是双语形态，不构成"没统一成英文"。

## 2. 范围（实测，逐类归属，rev1 漏了 4 类）

| 类别 | 文件 | 汉字 | 处置 |
|---|---|---|---|
| `.tad/hooks/`（**活 hook**） | 5 | 256 | **S0 修锚点**（不是翻译） |
| 根目录 —— `README` `ROADMAP` `INSTALLATION_GUIDE` `PROJECT_CONTEXT` | 4 | — | **S2 翻** |
| 根目录 —— **`CLAUDE.md` / `AGENTS.md`** | 2 | — | ⚠️ **只加 S1 那一段，正文不翻**。它们是地板表 6 项的载体（`gen-floor.py` 逐字断言 `- Alex does not write implementation code…` / `### Post-compact recovery` / `## Role Switching`），翻正文 = 直接打断载体断言。rev2 的 §2 与 §5 对这两个文件说了两遍相反的话 |
| 根目录 —— 其余 3 个 | 3 | 4,457（9 个合计） | **S2 翻** |
| `docs/`（不含 archive/legacy） | 4 | 5,119 | **S2 翻** |
| `.tad/capability-packs/` 的**说明文字** | 49 | 3,785 | **S2 翻**（⚠️ `keywords:` 不翻，见 §1.2） |
| `.tad/project-knowledge/` | 11 | 10,997 | **S2 翻**（⚠️ 单独一批：它是 `CLAUDE.md` §7 的 @import，每 session 常驻） |
| `.tad/` 其它（config/templates/guides/schemas） | 85 | 43,594 | **S2 翻** |
| `.claude/skills/` + `.agents/skills/` | 354 | 204,752 | ⚠️ **本单不翻**，见 §5 |
| `.tad/active/`（在飞 handoff / Epic / session-state） | 66 | 23,944 | **不翻**（在飞记录） |
| `.tad/memory/` | 19 | 5,035 | **不翻**（`CLAUDE.md` §7.5：native 管辖，TAD 侧只读） |
| `.tad/decisions/` + `.tad/tasks/` | 11 | 2,991 | **不翻**（记录） |
| `tad-work/` + `scripts/archive/` | 13 | 15,953 | **不翻**（工作区与归档脚本） |
| `.tad/evidence/` + `.tad/archive/` + `docs/{archive,legacy}/` | 1,719 | 1,229,216 | **不翻**（历史记录，翻译 = 篡改记录） |

**S2 实际翻译面 = 158 文件 / 67,952 汉字**（根目录 + docs + packs 说明 + knowledge + `.tad` 其它）。

## 3. 三刀，S0 与翻译无关

### S0 —— 修被中文绑架的纪律（**不翻译任何东西**）

1. **Gate 3 / KA 的检测改成 fail-closed —— ⚠️ rev3 更正了这一条的方向**

   **rev2 写的是「把中文 grep 换成注释锚」。那是错的，会让 Gate 3 比现在更脆。**
   实测 `pre-gate-check.sh` L191-203：外层 `if [ -n "$GATE3_RESULT" ]` **没有 `else`** ——
   **串找不到 = 零输出、零警告、不拦截。今天就已经是 fail-open 且完全静默的。**
   换成注释锚**失败方向一个字节没变**，而注释锚在任何渲染视图里不可见
   → **误删概率上升、被发现概率下降、后果相同。净效果比现状差。**

   **rev3 的三条，缺一不可**：
   (a) **加分支不是换分支**：hook 改成 `新锚 OR 中文原句 OR 英文 Result` 的**并集**。
       今天这条纪律有中文/英文两个独立分支——**那正是「靠重复守住」的一个实例，不许减少。**
   (b) **补 `else` 分支 fail-closed**：completion 文件存在但三种形式**全都没命中**
       → `HAS_BLOCK=1`。**这才是这一条真正要修的东西**，与语言无关。
   (c) 注释锚**只作位置标记不携带判定**（不写 `<!-- …:FAIL -->`），
       避免制造「散文与锚两个真值源」这种今天不存在的新 bug。
2. **`SAFETY_FLOOR` 改成**行集 diff**，⚠️ rev3 更正：不是「按类别存在性」**

   rev2 说改成「按类别存在性」。**那是把 rev1 的分母问题搬了家**——类别清单由 Blake 定，
   且「每类 ≥1 即绿」比计数底线**更弱**（84 条删到剩 1 条照样过）。

   **正确做法已经在仓库里，不要新造**：`HANDOFF-20260818-lazy-by-floor.verify.sh` 的 `acref()`
   ——它比**行集**不是计数、**中英双语**（对翻译稀释天然免疫）、已冻结，
   注释里就写着「等量替换瞒得过计数底线」。
   **S0.2 = 把 `acref` 的行集基线搬进 `skill-body-verify.sh`**，T0 落基线。
   这样分母是**外生**的（= T0 的行集），不存在"谁定义类别"的问题。
3. ⚠️ **已由 Alex 在 rev2 前完成**：34 个脚本的根路径从 `/path/to/TAD` 占位符改回
   `git rev-parse --show-toplevel` 推导。**这是 Alex 脱敏时打断的**——六个判定器
   （`gen-floor.py`/`budget.sh`/`resident.sh`/`verify.sh`/`step0.sh`/`measure.sh`）当时全部跑不动。
   Blake 须在 Step 0 复验它们**现在都能跑**，跑不动即 `GATE FAIL`。
4. **`gen-floor.py` 加 `--check` 干跑**（只跑 self-check、不写文件）。现状是无条件覆写产物，
   使「先跑再比 diff」只能证明"跑完等于跑完"。

### S1 —— 立语言规则（**不翻译任何东西**）

在 `CLAUDE.md` 与 `AGENTS.md` 各加一段，两侧逐字一致：

> **Artifact language is English. Conversation language follows the user.**
> Everything written to disk — handoffs, completion reports, knowledge entries, commit
> messages, code comments, evidence — is English. Replies in the terminal mirror the
> language the user writes in. These are two separate settings; neither implies the other.
> **Exception: routing data stays as-is.** SKILL/pack `keywords`, trigger phrases and
> anything a matcher greps literally are routing surface, not prose — translating them
> would break the ability to drive TAD in Chinese, which the first rule explicitly preserves.

### S2 —— 翻对外面孔（**158 文件**，本单只做前两批）

批次（每批独立 commit + 独立跑闸）：`docs`(4) → 根目录(9) → **本单到此为止**。
其余（packs 说明 49 / project-knowledge 11 / `.tad` 其它 85）**另开单**，
因为 project-knowledge 是每 session 常驻上下文、风险等级不同。

## 4. 不做

❌ **不翻 `.claude/skills/` 与 `.agents/skills/`**（354 文件 / 20 万汉字 = 64% 的量）——
两位审查员一致判断：**"96% 的风险换一个未验证的收益"**。等有已知的英文读者再动。｜
❌ 不翻任何 `keywords:` / trigger / 被 matcher 逐字 grep 的串（§1.2 用户裁定）｜
❌ 不翻 evidence / archive / active / memory / decisions / tasks / tad-work（记录类）｜
❌ **不翻 `CLAUDE.md` / `AGENTS.md` 正文**（只加 S1 那一段，见 §2）｜❌ 不改任何 YAML 键名、命令名、skill 名、文件名｜❌ 不发布不 push

## 5. 写权限（编号即全集）

1. `.tad/hooks/pre-gate-check.sh` · `.tad/hooks/lib/skill-body-verify.sh`（**仅 S0 的锚点与 floor**）
2. `.tad/templates/*.md` · `.claude/skills/{alex,blake,gate}/SKILL.md` · `.agents/` 对应镜像（**仅插入 S0 的注释锚**）
3. `.tad/evidence/acceptance-tests/discipline-floor/gen-floor.py`（**仅加 `--check`**）
4. `CLAUDE.md` · `AGENTS.md`（**仅 S1 的那一段**）
5. `docs/*.md`（不含 archive/legacy）· 根目录 `README.md` `ROADMAP.md` `INSTALLATION_GUIDE.md` `PROJECT_CONTEXT.md`（**S2 前两批**）
6. `.tad/evidence/acceptance-tests/english-unification/`（新建）
7. `.tad/archive/handoffs/COMPLETION-20260815-english-unification.md`

## 6. Acceptance Criteria

T0 = 开工前 commit（**本契约须先 `git add`**）。**不变量类 T0 必绿 / 完成度类 T0 必红。**

| # | AC | 类 |
|---|---|---|
| **AC1** | **S0 的 hook 锚点已换且 hook 仍工作**：`pre-gate-check.sh` 中 `Gate 3.*结果` 与 `是否有新发现` 的 grep **已不再是唯一判据**（新标记 `grep -Fq` 命中）；且**冒烟**：造一份含 `Gate 3 ... FAIL` 的临时 completion 喂给 hook，确认仍 `HAS_BLOCK=1`；再造一份改写措辞的，确认**仍然拦截**。两次原始输出落盘 | 完成度 |
| **AC2** | **SAFETY 改为行集 diff**：`skill-body-verify.sh` 用 T0 冻结的**约束行集**（`acref` 口径，中英双语正则）做 `comm -23`，丢失即 FAIL；不再依赖任何计数或类别清单。负控：**随机删掉 1 条**约束行 → 必须 FAIL（旧的全局计数写法在删 39 条内都不红；「按类别存在性」在删到每类剩 1 条时也不红） | 完成度 |
| **AC3** | **六个判定器逐个 exit 0**：`gen-floor.py --check` · `budget.sh` · `resident.sh` · **`verify.sh all`** · `measure.sh smoke`（`step0.sh` 拒绝重跑属正常，单列）。⚠️ **rev3 两处更正**：(a) rev2 只要求「能跑 + 落盘 exit 码」——`gen-floor.py --check` 退出 1 打印 `anchor not in carrier` **完全满足字面要求**，而它是唯一能抓到「英文地板锚被删」的 AC；(b) rev2 点的是 `verify.sh AC13`（skill-body-verify 的壳），**漏掉了 `ac1()`——29 条义务祈使句的冻结判定器**，其分母是外生的 `obligations.tsv`。改点 `all` | 完成度 |
| **AC4** | **S1 规则两侧逐字一致且非空**：`grep -c 'Artifact language' CLAUDE.md AGENTS.md` **两侧各 ≥1**（前置断言，防空对空）；再 `diff <(sed -n '/Artifact language/,/neither implies the other/p' CLAUDE.md) <(同 AGENTS.md)` 零输出。⚠️ rev1 的写法在两边都为空时 `diff` 也是 exit 0 | 完成度 |
| **AC5** | **S1/S0 阶段不得翻译任何东西**：全仓活文件的**逐文件汉字数**与 T0 完全一致（除 §5 第 6 项新目录）。基线 Step 0 落盘。⚠️ 这是 rev1 完全缺失的一条——S1 最核心的约束此前零验证器 | 不变量 |
| **AC6** | **S2 只动了批次内文件**：`docs` 与根目录两批各自 commit；每个 commit 的改动集 ⊆ 该批文件清单；且**批内文件的汉字数只减不增**，批外文件汉字数**逐文件不变**；⚠️ **并且批内每文件非空白字节数 ≥ T0 × 0.8** —— 否则「把中文整段删掉不翻译」完美满足「只减不增」，没有任何 AC 要求英文被补上 | 完成度 |
| **AC7** | **路由面未被翻译**（用户裁定 A）：34 个含中文 `keywords:` 的 SKILL + `pack-registry.yaml`，其 `keywords:` **以及 `description:` / `trigger:`** 行相对 T0 **逐字未变**（`git diff ${T0} -- <清单> \| grep -cE '^[+-].*(keywords|description|trigger):'` = 0）。⚠️ rev3 扩了范围：**harness 选 skill 用的是 `description:` 不是 `keywords:`**，而 `save-skill` 的中文触发串（`把这个存成 skill`）正在 `description:` 里 | 不变量 |
| **AC8** | **六闸全绿，且新旧两版 `skill-body-verify.sh` 都绿**（⚠️ rev3：S0.2 让 Blake **重写**这个闸，而 AC8/AC3 都断言它绿 —— 闸与被闸的东西同作者同 commit，是自证。Step 0 须把 T0 版冻结到 `<ev>/skill-body-verify.T0.sh`，两版都跑都绿）。完整命令行写死：`bash .tad/hooks/lib/release-verify.sh parity "$R"` · `… version "$R" 2.42.0 2.41.0` · `… version-sweep "$R" 2.42.0` · `… migration "$R"` · `bash "$R/tad.sh" --verify-denylist` · `bash "$R/.tad/hooks/lib/skill-body-verify.sh"`。⚠️ `version` 不给第三个参数是恒真 no-op；`$R` 必须是绝对路径（传 `.` 返回 exit 2） | 不变量 |
| **AC9** | parity：`diff -rq -x local .claude/skills .agents/skills` 零输出。⚠️ **rev1 漏了 `-x local`**：`.claude/skills/local/` 是 save-skill 的机器本地目录、gitignored、从不镜像，裸 `diff -r` 在 T0 就 exit 1 —— Blake 第一条 AC 就会被挡住 | 不变量 |
| **AC10** | **行为验证（带负控）**：同一任务跑两次 fresh subagent —— (a) **不含**新规则的上下文、(b) **含**新规则。任务写死：「用中文问它，让它写一份 **COMPLETION 报告**到 `<ev>/english-unification/probe-<n>.md`」。⚠️ rev3 换了体裁：rev2 用「知识条目」，而 `project-knowledge/` 现在**本来就以英文为主** → (a) 也会得到汉字 0 → 「无差异」→ 按 §8.4 误判「规则未生效」。COMPLETION 的 baseline 确实是中文（每份都写着 `**是否有新发现？**`）。**隔离机制也须写死**：`CLAUDE.md` 是每 session 自动 @import 的，在本仓 spawn 的 subagent 必然带着规则 —— (a) 必须换 cwd 或另起进程，做不到就如实记 `BLOCKED` 退回 Alex，不许即兴。机械判据：产物文件**汉字数 = 0**、终端回复**汉字数 > 0**。**(a) 与 (b) 的产物必须有差异**，否则该规则未被证明起作用。两次原始作答与两个计数全部落盘 | 完成度 |
| **AC11** | 围栏：改动集 −(§5 七项 ∪ `T0-dirty.txt` ∪ `.tad/evidence/{traces,decisions}/*.jsonl` ∪ `session-state.md`) 为空 | 不变量 |
| **AC12** | **契约未变**：`git diff --quiet ${T0} -- <本文件>` | 不变量 |

## 7. Step 0

1. `git add` 本契约 → commit → 记 T0；`git status --porcelain > <ev>/T0-dirty.txt` 并提交（AC11 的分母，防事后声称"T0 就有"）
1b. **冻结 T0 版的闸与基线**（AC2/AC8 的外生分母，防自证）：
    `cp .tad/hooks/lib/skill-body-verify.sh <ev>/skill-body-verify.T0.sh`；
    并按 `verify.sh` 的 `acref()` 口径落盘 `alex`/`blake` 两份 SKILL 的**约束行集**基线
    （`grep -hiE 'MUST|MANDATORY|VIOLATION|BLOCKING|forbidden|NEVER|不得|必须|禁止'` → 去首尾空白 → `LC_ALL=C sort`）。
    ⚠️ **行集基线由本步骤从 T0 现算并提交，之后不得重算**——它是 AC2 的分母，重算就等于分母由被判定方定。
2. **落盘逐文件汉字数基线**（AC5/AC6 用）：活文件（排除 evidence/archive/docs-archive/docs-legacy）逐个 `文件 ⇥ 汉字数`
3. **复算 §1.1 的三条与 §2 的分类**——⚠️ **Alex 在 §3 的耦合清单上已经错过两次**
   （第一次漏了整个 `.tad/hooks/`；第二次说 `tad.sh` 只有 1 行中文，实为 **11 行、全是注释、代码里 0 处**）。
   **不要信本契约的表，自己扫一遍活文件里所有被机械消费的中文串**，多出的写进 COMPLETION
4. 落盘 AC7 的 34 个 SKILL + registry 的 `keywords` 行基线
5. **逐条 AC 跑方向负控**：不变量类 T0 必绿、完成度类 T0 必红，任一不符 → 停下退回 Alex

## 7.5 环境约束（本机实测，今天踩过的）

⚠️ **`grep -c '[一-龥]'` 在本机不可靠** —— 同一个 `tad.sh`，它返回 **158**，而真实含中文行数是 **11**
（字符类在此 locale 下按字节匹配）。**统计汉字一律用 Python 的 `re.compile(r'[一-鿿]')`**，
本契约所有汉字数字都是这么量的。
⚠️ 其余：`grep` 是 ugrep 包装 → `command grep`；`grep -c` 无命中 exit 1 → `|| true`；
`sort/uniq/comm` 前 `LC_ALL=C`；`$VAR` 紧跟特殊字符要写 `${VAR}`（zsh 会把 `$C:r` 当修饰符吃掉）；
**读退出码不要隔着管道**（`cmd | tail` 的 `$?` 是 `tail` 的）。

## 8. 已知取舍

1. **本单 64% 的量不做**（`skills` 354 文件）。两位审查员一致：收益是**推测的、可延后的**，
   代价是**已证实的、一次性的**。**等有已知的英文读者再动。**
2. **S0 与英文化无关，但排在最前**。它修的是「纪律现在就靠中文字面量维系」这件事——
   Gate 3 的拦截、KA 的检测、唯一的内容级闸。**不做英文化也该做 S0。**
3. **仓库会长期是「产品英文 / 记录中文 / 路由中英混排」的混合状态。这是刻意的。**
4. **AC10 是本单唯一无法用 grep 证明的东西**，所以它带负控。若 (a)(b) 无差异，
   结论是「规则未被证明起作用」，**不是「规则失败」**——记进 COMPLETION，退回 Alex 重新设计规则措辞。
5. ⚠️ **翻译质量不设 AC**。S2 若发现某段中文的意思在英文里无法逐字对应（尤其纪律条文），
   **停下退回 Alex** —— 那是设计问题不是翻译问题。
