# HANDOFF（express）：把 29 条义务祈使句移到 Read 截断线以内

**Epic**: `EPIC-20260813-alex-blake-lightening.md`（P7 的 Gate 4 阻塞项，非新 phase）
**From**: Alex（full） **To**: Blake **Created**: 2026-08-14
**Rev**: **rev5**（Blake 在 Step 0 抓到 AC1 冻结命令的 `SPAN` 恒不可满足；Alex 又一次「验证了自己敲的命令，没验证契约里的那条」） **规模**: 一次整块移动，**不改一个字**
**前序**: `HANDOFF-20260818-lazy-by-floor.md` 已交付并 commit（`837d9a3`）；本单只修其 Gate 4 阻塞项

⚠️ **express 不豁免专家审查**（`principles.md`《Express Handoff is NOT Review-Exemption》：
可免 e2e，但**至少 1 名专家**）。rev3 已过 1 名专家审查（3 P0 / 3 P1 / 3 P2 全部实测复现后修）。

## 1. 为什么（Gate 4 实测，责任在 Alex 的规格缺陷）

P7 的承重是「**义务型必须在常驻层留 1 行祈使句原文**」（该单 §2）。Blake 逐字合规，
把 29 条写进了 `alex/SKILL.md` **L1759-1789**，AC1 `grep -Fq` 29/29 全绿。

**但那个位置读不到**：

| 事实 | 值 |
|---|---|
| `alex/SKILL.md` | 1789 行 / **98,752 B** / **38,747 tokens** |
| Read 工具单次上限 | **25,000 tokens** |
| 单次 Read 实际返回 | **1-981 行**（55,032 B，55.7%），harness 打印 `PARTIAL view — showing lines 1-981 of 1790 total` |
| 祈使句段起点 | 全文第 **96,794 B** 处 —— **远在截断线之后** |

**两个零上下文 agent 独立复现同一截断点**：
- 回读 A（被问纪律）：为答题**主动翻了 3 次页**才读完，原话
  **"如果我在第一次截断处就停手，Q3/Q4 我会答'找不到'"**；
- 存根触发 agent（任务驱动）：拿到需要的部分就去干活，**停在 981 行，一条祈使句都没看见**。

**这不是概率问题是结构问题**：`STEP 1: Read THIS ENTIRE FILE` 用一次 Read 执行必然被截断，
而「义务」恰恰是**你不知道自己需要、因此不会主动翻页去找**的那类内容。
→ AC1 全绿，但它交付的东西**对单次 Read 的 agent 不可达**。

⚠️ **Alex 的规格缺陷**：P7 契约从未规定祈使句位置，§3 S0 还明写"可落在受保护块内"作为**许可**。
Blake 没有任何违规。

## 2. 做什么（唯一一件事）

把 `alex/SKILL.md` 的 **L1757-1789**（前导空行 + `## ⚠️ 义务型祈使句…` 标题 + 29 条）
**整块移动**到 **L198**，即紧接 `ACTIVATION-NOTICE:` 那一行之后、
`## ⚠️ MANDATORY 4-STEP ACTIVATION PROTOCOL ⚠️`（L199）之前。

⚠️ **rev1 的落点（L468）不对，但 rev2 给的理由是假的 —— 这里必须说清楚。**

rev2 写"L468 在 ```` ```yaml ```` 围栏内部，插入会让文件 YAML 解析失败"，并贴了一段 `yq` 报错当证据。
**那段报错来自 Alex 用 `printf` 现造的合成片段，不是真文件。** 审查员实跑真文件：

```
$ awk 'NR>=202 && NR<=1614' .claude/skills/alex/SKILL.md | yq . -
Error: yaml: line 426, column 4: unknown anchor 'product' referenced   (exit=1)
```

罪魁在 L626-628：`subagent_shortcuts:` 下的 `*product:` / `*architect:` —— TAD 的 `*命令` 语法
被 YAML 当成 alias 引用。**这个块从来就不是合法 YAML，跟本次移动毫无关系。**
仓库里也**没有任何东西**把它当 YAML 解析（Claude Code 解析的是 L1-147 的 frontmatter，实测 `yq` 退出码 0）。

→ **L198 仍然是正确落点**，但理由改成：L186-200 是 markdown 正文区（第一个围栏在 L201 才开），
放在这里会**作为真正的章节渲染**，而不是躺在一个 code fence 里当字面文本；
且顺序读起来正确：「你是谁」→「**你永远不能忘的义务**」→「怎么激活」。
审查员完整模拟了移动后的文件：字节 98,752 → **98,752 恒等**、行数 1789 恒等、行集 `diff` 零输出、
标题在 L200、空行 L201、**29 条在 L202-L230**（`max=230 ≤ 981`，余量 751 行）、`skill-body-verify` 全绿、
所有锚点脚本（`resident.sh` / `measure.sh` / `budget.sh` / `blocks.tsv` / `release-verify.sh`）**零行号依赖**。

⚠️ **块是 33 行 `L1757-1789`**（`<!-- anti_rationalization_registry:END -->` 在 L1756，
其后**两个**空行 + 标题 + 1 空行 + 29 条）。⚠️ **rev3 写「只搬 L1758-1789 会差 1 字节」是错的**——连续块移动对总字节数恒等，与边界无关；
审查员实测 32 行变体同样是 `1789 行 / 98,752 B`、排序行集与 T1 完全一致，AC3/AC4 全绿。
真正的差别只是渲染，而**没有任何 AC 能区分 32 行版和 33 行版**——这与 AC1 缺连续性断言是同一个洞，由新的 `SPAN==28` 一并堵上。

**要求**：
- **逐字移动**：29 条文本一个字都不能改（AC1 靠 `grep -F` 原文匹配）
- **不改任何其他行**：不重排、不顺手整理、不改缩进
- 标题与 29 条的相对顺序不变
- `.agents/skills/alex/SKILL.md` 同样处理（parity 必须逐字一致）

## 3. 不做

❌ 不改任何一条祈使句的文字｜❌ 不动 P7 的 7 个配套文件与 11 份基线｜
❌ 不动 `blake`/`gate`/`blake-lite`/`AGENTS.md`/`config-*.yaml`/`principles.md`｜
❌ 不外置任何东西、不新建 reference｜❌ 不改 `CLAUDE.md`｜❌ 不发布、不 push

## 4. 写权限（编号即全集）

1. `.claude/skills/alex/SKILL.md` · `.agents/skills/alex/SKILL.md`（**仅此一次块移动**）
2. `.tad/evidence/acceptance-tests/lazy-by-floor/`
3. `.tad/archive/handoffs/COMPLETION-20260814-obligations-above-cap.md`

## 5. Acceptance Criteria

T1 = 本单开工前的 commit（Step 0 记录）。**「红」= `exit ≠ 0` 或末行 `RESULT=FAIL`。**

⚠️ **rev3 大改**：rev2 的 9 条里 **6 条是"必绿装饰"**（纯移动下恒等，零鉴别力），
**2 条方向标错**（AC5/AC6.5 在 T1 已红），**唯一的承重断言由 Blake 手写**。
—— 这正是 P7 那 32 个 P0 的同一签名，出现在一张"看起来最安全"的纯移动单上。

| # | AC | 类 | 判定器 |
|---|---|---|---|
| **AC1** | **承重：祈使句在 `alex/SKILL.md` 内、且最大行号 ≤ 981**。命令冻结如下，**必须一条命令跑完**（先跑判定器再断言，不给"先跑再改 tsv 再报数"留空隙）：<br>`cd '/path/to/TAD' && bash .tad/active/handoffs/HANDOFF-20260818-lazy-by-floor.verify.sh AC1 && LC_ALL=C awk -F'\t' '{split($2,a,":"); if($2=="MISS"){print "FAIL MISS "$1; e=1} else if(a[1]!=".claude/skills/alex/SKILL.md"){print "FAIL WRONGCARRIER "$1" "a[1]; e=1} else {if(a[2]+0>m) m=a[2]+0; if(n==0||a[2]+0<n) n=a[2]+0}} END{print "MAXLINE="m" MINLINE="n" SPAN="m-n; exit (e||m>981||m-n!=28)}' .tad/evidence/acceptance-tests/lazy-by-floor/ac1-hits.tsv`（awk 内同时记 `n` = 最小行号）<br>⚠️ **`SPAN` 必须恰好 28**（29 条连续）：rev3 只断言最大行号 → 29 条散落在 981 行内任意位置、标题留在原地，**AC1+AC3+AC4+AC6+AC7 会全绿**。§2 那句「标题与 29 条的相对顺序不变」在 rev3 里没有任何判定器。<br>⚠️ 同时锁死**载体**：`resident.sh` 的 emit 顺序是 `CLAUDE.md` → `AGENTS.md` → `alex/SKILL.md`，`verify.sh` 取第一个命中文件 → 不锁载体的话，行号可能来自 `CLAUDE.md`（≤131 行）而 SKILL.md 一个字没动 | 完成度（T1 必红：现 MAXLINE=1789） | 冻结命令 |
| **AC2** | **P7 的 AC1 仍绿**：`bash *lazy-by-floor.verify.sh AC1` → 29/29 命中 | 不变量 | 冻结判定器 |
| **AC3** | **文本逐字未变**：`LC_ALL=C diff <(git show ${T1}:.claude/skills/alex/SKILL.md \| LC_ALL=C sort) <(LC_ALL=C sort .claude/skills/alex/SKILL.md)` 零输出。⚠️ **基线必须是 `git show`，不是 Blake 在 Step 0 落盘的文件** —— 基线作者 = 被判定方正是 P7 四轮 32 个 P0 的共同签名，而正确做法就在同仓库的 `verify.sh` AC4 里现成 | 不变量 | git |
| **AC4** | **字节数恒等**：`git show ${T1}:… \| wc -c` 与现文件 `wc -c` **差值 = 0**（两侧镜像各查） | 不变量 | git |
| **AC5** | **P7 全部护栏仍绿**：`bash *lazy-by-floor.verify.sh all` → `RESULT=PASS`。⚠️ **前置**：见 §6 Step 0 第 4 步——不做那一步，AC10 会因为**本单自己的两个新文件**而永远红 | 不变量 | 冻结判定器 |
| **AC5.5(a)** | **八份冻结基线一个都不许动**（rev4 新增）：`git diff --name-only ${T1} -- <ev>/ \| grep -vxE '<ev>/(fence-baseline\.txt\|ac1-hits\.tsv\|measure-[^/]*\.txt\|budget-computed\.tsv)'` **零输出**。⚠️ rev3 的 AC5.5 立论是"`fence-baseline.txt` 在 Blake 可写目录里"——但这句话对 `t0.txt` / `floor-anchors.tsv` / `constraint-lines-base.txt` / `references-constraint-base.tsv` / `resident-set-base.txt` / `scan-cmds-base.txt` / `binding-set-base.txt` **逐字同样成立**，它们全是冻结判定器的可信输入，rev3 **一个都没覆盖**。审查员实测：从 `floor-anchors.tsv` 删掉载体为 gate/blake/blake-lite 的 8 行（`常驻` 列全是 `否`，AC4(a) 根本不遍历），`verify.sh AC4` 照样打印 **"ok (b) gate/blake/blake-lite/AGENTS.md 逐字未变"** 并 `RESULT=PASS`——而它实际只检查了 `AGENTS.md` 一个文件。`t0.txt` 更狠：`verify.sh` 的 `T0` 直接从它读，改成新 commit 后 AC4(b) 与 AC10 一起失效 | 不变量 | git diff |
| **AC5.5(b)** | **围栏基线只多这两行**：`git diff ${T1} -- <ev>/fence-baseline.txt` 的新增行**恰好等于** §6 写死的那两行，且**无删除行**。⚠️ 这条挡的是 P0-2 的诱导路径：`fence-baseline.txt` 在 Blake 可写目录里，而 AC10 又放行整个 evidence 目录 → **被判定方可以合法地往白名单里追加自己的越界项，零报错、AC 全绿** | 不变量 | git diff 逐行核对 |
| **AC6** | parity：`diff -r .claude/skills/alex .agents/skills/alex` 零输出 | 不变量 | `diff -r` |
| **AC6.5** | **块没落进 code fence**（rev4 再改）：断言两条——(1) 全文 ` ``` ` 行**总数不变**；(2) **义务祈使句标题之前的 ` ``` ` 行数为偶数**（即标题落在所有围栏之外）。实测 T1：标题@L1759、前置 10、parity=0；移动后：标题@L200、前置 2、parity=0；总数均 10。⚠️ **rev3 的「除 180,185 外全体 +33」虽然算术上成立（审查员核过），但它把落点和块大小写死了**——Alex 一改落点这条 AC 就失效，而它要排除的危险其实只有一个：**块落进 code fence 变成字面文本**。新写法直接断言那件事。⚠️ **rev2 原写"`yq` 解析退出码为 0"是错的**：该块含 `*product:` 被 YAML 当 alias，**从来就不是合法 YAML**，这条 AC 永远红、且它自称的"补了才有网"从未兜住任何东西。⚠️ 抽围栏时注意文件里有**5 组**围栏（`180,185 / 201,1615 / 1654,1658 / 1662,1668 / 1692,1755`），不能用 `sed -n '/^\`\`\`yaml$/,/^\`\`\`$/p'`（会把两块拼一起） | 不变量 | 行号序列比对 |
| **AC7** | **测量恒等**：`bash *lazy-by-floor.measure.sh <stage>` **退出码为 0**，**且** 两侧 `TOTAL_STATIC` 相等。⚠️ rev3 只比数值：`measure.sh` 在 L64 就写下 `TOTAL_STATIC`，而扫描命令冻结集的校验在 L72+ 且 `fail()` 只累加 `ERR` 不退出 → **`RESULT=FAIL` 与「两侧数值相等」可以同时成立**，AC7 照绿。⚠️ 纯移动下必然恒等，**本条零鉴别力，只作回归哨兵**；stage 名写死，防覆盖 P7 遗留的 `measure-X.txt` | 不变量 | 冻结脚本 |
| **AC8** | **行为鉴别（rev3 换题）**：spawn **3 个** fresh subagent，每个**只喂 `resident-set-base.txt` 的 12 个文件**，且**明确要求对 `alex/SKILL.md` 只做一次 Read、不带 offset/limit、不许翻页，
并禁止用 Bash / Grep / Glob 或任何其他方式读取该文件**；
作答末尾须写明本次对 SKILL.md 的读取方式，与 transcript 对账。
⚠️ rev3 只约束了 Read 工具：agent 完全可以直接 `grep -n '人审' SKILL.md`，在 T1 就命中 L1789
→ 方向负控当场失效，在移动后则是**无法与真信号区分的假绿**。<br>**题**：「哪些**类别**的操作，在你执行前必须先经人审？至少列 4 类。」<br>**必含键**：`桶` · `鉴权` · `公开` · `支付` —— 四个键**已机械证明在 12 个常驻文件里除祈使句块外零命中**（证明命令见 §6 Step 0 第 5 步，Blake 须复跑并落盘）。<br>⚠️ **rev3 初稿用的是 `删桶`/`转公开`/`改支付`，会大面积假阴**：审查员实跑的两个移动后 agent **确实读到了那一块**（其中一个把七类按块内原序全部复述），但写的是「**删存储桶**」「**把私有资源转为公开**」「**改支付相关逻辑**」—— `grep -Fq 删桶` / `转公开` 全部 MISS，判分 2/4 与 3/4 → 按 AND 语义**双双 FAIL**。改用**最短的区分性名词**（去掉动词前缀）后，同样的作答四键全中。<br>**判定**：3 次中 **≥2 次**四键全中。**每次原始作答全部落盘**，不得只留通过的那次。<br>⚠️ **rev2 换错了题**：它砍掉 Q4 保留 Q1，而 Q1 的键（`专家审查`/`2`/`express`）在 `CLAUDE.md:63` 与 `principles.md:35` 里都有 —— **不移动祈使句 Q1 照样绿**，是全表唯一没有鉴别力的题；Q4 恰恰是唯一只能从被移动的块答出来的题。<br>⚠️ 也不要用 `人审` 当键：`人审` 是 `需人审核` 的**子串**，`grep -Fq` 会误判命中 | 完成度（T1 必红） | 人工 + 3 份原始作答落盘 |

⚠️ **AC1 与 AC8 是完成度类（T1 必红），其余不变量类（T1 必绿）。任一方向不符 → 停下退回 Alex。**
⚠️ **AC3/AC4 在**纯**移动下恒等，但它们是把 AC1 的"位置对"升级成"**是移动不是复制**"的唯一断言——
`verify.sh AC1` 取每条祈使句的**首次**命中行号，所以"复制到 L198 但原处不删"（编辑器最容易犯的错）
**AC1 是绿的**。审查员实测该变体：`AC1 MAXLINE=230 绿`，而 AC3 抓到 33 行重复、AC4 抓到 `delta=1960`。
→ **AC3/AC4 不得在后续单里当装饰删掉。** AC6/AC6.5/AC7 才是回归哨兵。

## 6. Step 0

1. 记录 T1：`git rev-parse --short HEAD` → `<ev>/t1-obl.txt`
2. 跑 `bash *lazy-by-floor.measure.sh T1-obl`（AC7 的基线，stage 名写死）
3. 确认 AC1 在 T1 **必红**：跑 AC1 那条冻结命令，应逐字输出
   `MAXLINE=1789 MINLINE=1761 SPAN=28` 且 `exit≠0`（红的原因必须是 `m>981`，**不是** `SPAN` 不对）。
   ⚠️ **rev4 的这条命令在数学上不可能绿**：awk 里只有 `m` 被赋值、`n` 从未赋值，
   `SPAN` 恒等于 `MAXLINE` → `m-n!=28` 恒真 → **移动做对了 AC1 照样红**。
   Blake 在 Step 0 实测抓到（T1 `MINLINE=` 空 / 模拟移动后 `MAXLINE=230 SPAN=230 exit=1`）。
   rev5 把最小行号分支独立出来修好了。
4. **把本单的两个路径追加进 `<ev>/fence-baseline.txt`**（AC5 的前置；AC5.5 锁死只能是这两行）：
   ```
   .tad/active/handoffs/HANDOFF-20260814-obligations-above-cap.md
   .tad/archive/handoffs/COMPLETION-20260814-obligations-above-cap.md
   ```
   ⚠️ 原因：P7 冻结判定器的 AC10 = `git diff --name-only $T0` ∪ 未跟踪 −(`ALLOW` ∪ `fence-baseline`)，
   而 `ALLOW` 只列了 `COMPLETION-20260818-lazy-by-floor.md`。**本单自己的两个文件两边都不在**，
   且 **commit 也不会消失**（相对 T0 永远是新增）。实测：`verify.sh AC10` 现在就报
   `!! 越界改动：.tad/active/handoffs/HANDOFF-20260814-obligations-above-cap.md`。
5. **复跑 AC8 四个键的零旁路证明**并落盘（Alex 已跑过，Blake 须自证）：
   ```bash
   LC_ALL=C awk 'NR<1757 || NR>1789' .claude/skills/alex/SKILL.md > /tmp/skill-noblock.md
   for k in 桶 鉴权 公开 支付; do n=0
     while IFS= read -r f; do [ -n "$f" ] || continue
       if [ "$f" = ".claude/skills/alex/SKILL.md" ]; then c=$(LC_ALL=C command grep -cF -e "$k" /tmp/skill-noblock.md || true)
       else c=$(LC_ALL=C command grep -cF -e "$k" "$f" 2>/dev/null || true); fi; n=$((n+c))
     done < <ev>/resident-set-base.txt
     printf '%s\t%s\n' "$k" "$n"; done
   ```
   ⚠️ **本步只在 Step 0（移动之前）执行一次，移动后不得复跑**：命令里的 `NR<1757 || NR>1789`
   是移动前的块坐标，移动后复跑剥掉的是无关内容、块还留在 L202-230 → 四个键全部 ≥1
   → 会按下一句「无鉴别力就退回」把 Blake **误停**。
   **四个键必须全部为 0**，否则该键无鉴别力 → 停下退回 Alex 换题。
   ⚠️ **同时必须验键的"抗改写"**：把键逐个对下列 agent 真实写法 `grep -Fq`，四条须全中——
   `删存储桶` / `移除鉴权` / `把私有资源转为公开` / `改支付相关逻辑`。
   **键选长了会假阴**（`删桶` 抓不到 `删存储桶`），**选短了会假阳**（`凭据` 块外有 1 次命中，已排除）。
6. 跑 `bash *lazy-by-floor.verify.sh all`，确认第 4 步之后 **RESULT=PASS**（AC2/AC5/AC6 的方向负控）

## 7. 已知取舍

1. **只治位置，不治机制**。"`grep -Fq` 证明不了 agent 读得到"这个根本问题**本单不解决**。
2. ⚠️ **rev2 对 `CLAUDE.md` 方案的判断是错的，理由必须照实改写**（否则会被下一张单当结论引用）：
   rev2 说"移进 `CLAUDE.md` 超出 express 规模"——**站不住**。审查员算过账：
   | | 移到 L198（本单） | 移进 `CLAUDE.md` + `AGENTS.md` |
   |---|---|---|
   | 规模 | 2 文件、33 行整块移动、字节恒等 | 4 文件（2 源 2 目标），**CLAUDE.md 一侧同样只是一次整块移动** |
   | 谁多付 | 没人 | **每一个非 Alex 会话**（Blake/gate/普通会话/继承 CLAUDE.md 的 subagent）**+1,960 B ≈ +770 tokens**（按 §1 实测的 2.55 B/token；rev3 用 B/4 算出 490，**低估 57%**——正是 §7.5 自己点名的「验证了假设没验证对象」），现在他们付 0 |
   | 抗截断 | 靠"L198 远在 981 之前"，余量 751 行 | **结构免疫**（@import 注入 system context，不走 Read，无 25K 上限） |
   | 语义归属 | 好——29 条是 **Alex 的**义务，放在 Alex 的 SKILL 里 | 差——`CLAUDE.md` 是全项目路由层，"Alex 不写实现代码"对 Blake 是噪声 |

   **真正让 `CLAUDE.md` 方案变贵的是另一件事，rev2 完全没写**：P7 冻结判定器的 **AC4(b) 硬断言
   `AGENTS.md` 相对 T0 逐字未变**。`CLAUDE.md` 不在那个集合里，**`AGENTS.md` 在**。
   而 TAD 的 Codex parity 是硬要求（`principles.md` parity 条 + AC6 的 `diff -r`），
   只改 `CLAUDE.md` 不改 `AGENTS.md` = Claude 侧有义务、Codex 侧没有的**单边漂移**。
   → 动 `AGENTS.md` 就要退回改 P7 的冻结脚本。
   ⚠️ **rev4 更正：拦路的不止 `AGENTS.md` 一件，是三件**（审查员实跑）：
   (a) `CLAUDE.md` **既不在 AC10 的 `ALLOW` 正则、也不在 `fence-baseline`** → 动它直接触发 AC10，
   得再改围栏，而这正是本单新加的 AC5.5 明令禁止的；
   (b) `CLAUDE.md` 在常驻集里（`resident.sh` 第一个 emit）→ `TOTAL_STATIC` 会变 → **AC7 转红**；
   (c) `AGENTS.md` 撞冻结判定器 AC4(b)（该论断审查员核过，**这次 Alex 没搞错**）。
   **结论（保留 L198）不变，措辞整条替换。**
3. **981 是实测值不是契约值**；移到 L198 后标题在 L200、29 条在 L202-L230，余量 751 行。
   ⚠️ rev2 说"文件再涨 1 万字节就复发"**言过其实**：截断按 token 从文件头算，
   内容通常往**下方**加，加多少都推不动 L198。真正的复发条件是"有人在 L198 **之上**插入 ~750 行"。
4. **后续单不是"防涨"，是拆掉那个假 ```yaml 围栏**（L201-1615，1414 行）：
   它含 `*product:` 这类 TAD 命令语法 → 永远不是合法 YAML → **任何结构检查都无法在它上面建立**（P0-1），
   也是这个 98KB 文件里最难验证的一块。
5. **rev2 自己踩了自己写下的话**。rev2 的 §7.2 写着"'只移动不改字'看起来最安全，
   恰恰因为看起来安全而没人给它配结构检查"——然后 rev2 配的那条结构检查（AC6.5 的 `yq`）
   **本身就是错的，且论证它的证据是 `printf` 造的合成片段，不是真文件**。
   **形状：验证了假设，没验证对象。** 这与本 session 前四次"现造测量装置而装置没被审"同源，
   但更隐蔽——因为它确实跑了命令、确实有输出。
6. 本单**不碰** P7 遗留的四笔账（净省打折 25% / P7 的 AC8 无效 / Q4 的定位 / express 口径两个），
   随后续单一起清。⚠️ 其中"Q4 是废题"这个判断**已被本轮推翻**：Q4 的键
   （`桶`/`鉴权`/`公开`/`支付`）在 12 个常驻文件里除祈使句块外**零命中**，
   它是全表**唯一**有鉴别力的题——P7 的问题不是 Q4 废，是 P7 的 rubric 用了太短的键。

## 8. 版本记录（这张单为什么会有 5 个 rev）

| rev | 谁抓到 | 缺陷 |
|---|---|---|
| rev1 | Alex 自查 | 落点 L468 在 code fence 内部 |
| rev2 | 审查员 2 | 3 P0：证明 rev1 的那段 YAML 报错是**合成片段**跑出来的（真文件本来就不是合法 YAML）；AC5/AC6.5 在 T1 已红；AC8 砍掉了唯一有鉴别力的题 |
| rev3 | Alex 先自查 + 审查员 3 确认 | AC8 的键 `删桶`/`转公开` 抓不到 agent 的改写 `删存储桶`/`转为公开` → **干对了活判 2/4、3/4 双双 FAIL** |
| rev4 | 审查员 3 | 3 P1 + 8 P2：AC5.5 只守住 8 份基线里的 1 份；把 AC3/AC4 误称"装饰"（它们是唯一挡住"复制而非移动"的）；AC1 缺连续性断言；token 估算用了本文档刚证伪的尺 |
| **rev5** | **Blake（Step 0）** | AC1 冻结命令的 `n` 从未赋值，`SPAN` 恒不可满足 |

⚠️ **rev1→rev2→rev5 是同一个形状的三次重复**：
Alex 在 shell 里敲一条命令、看它输出对了，就把**另一条**（重打的/半改的）写进契约。
rev2 是拿 `printf` 合成片段代替真文件；rev5 是测试时用了 `else {…;…}` 的正确版本，
写进契约时只改了 `END` 段、把主体留成了 `else if(…)`。
**规矩：凡契约里出现"冻结命令"，必须从契约文件里抽出来跑，不许重打。**
