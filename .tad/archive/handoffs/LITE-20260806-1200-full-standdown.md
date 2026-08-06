# LITE Handoff: full 退场 —— 路由层降级（Epic P6）

**Date**: 2026-08-06
**Revision**: **v2**（v1 经 L2.5 审查 CONDITIONAL：3 P0 + 4 P1 + 3 P2，全部采纳，见 Contract Review）
**Series**: EPIC-20260804-lite-as-tad-body step 6/6（**本 Epic 最后一单**）

## 目标（2-3 句，含"为什么"）

本 Epic 的目标是「lite 成为 TAD 本体，full 退场」。P5a–P5c 已把 full 独占的能力交给 lite，
2026-08-06 的 P5c-1 更是**全程在 lite 内完成**（含 Epic 回填）——证明 lite 能独立承担完整流程。

本单做最后一步：**把 `CLAUDE.md` 的路由层从「full 是主路径」改为「lite 是默认、full 是保留通道」**。
四处纯增量改动，**三个 full skill 文件一字节不动**——兑现 P6-AC4 的「归档而非删除、可回滚」。

## 不做什么

- ❌ **不移动/不删除 full skills**（`.claude/skills/{alex,blake,gate}/`，合计 252,649 chars（`wc -m`）
  + 32 个 references）。物理归档会破坏 `tad.sh` 安装流程，且需同步改 `README.md` /
  `INSTALLATION_GUIDE.md` / `ROADMAP.md` / `CHANGELOG.md`——那些是**发布物**，
  属安全停清单第 1 条（release·publish·sync），应在下次 `*publish` 时一并处理。
- ❌ **不删 `CLAUDE.md` 任何现有内容**。四处均为「原文保留 + 追加」或「标题加后缀」。
- ❌ 不改 `CLAUDE.md` 第 90 行（`## 7. Project Knowledge`）及其后——@import 链与 §7.5 一字节不动。
- ❌ 不改任何 skill 文件、`.tad/hooks/`、`settings*.json`、`.agents/`。
- ❌ 不执行 git commit / push / publish / sync。
- ❌ 不新增任何 MUST / 禁止条目 → **不触发约束准入闸**，不追加台账。

## 文件清单（创建/修改，逐个路径）

**修改 1 个**：`CLAUDE.md`（**110 行 → 123 行**；改后 md5 见 AC7）

**创建 0 个。**

## 四处改动（逐字 old → new）

⚠️ **旧串比对必须用 `grep -Fx`（全行精确）**，不能用 `-F`——改动 3 的新标题**包含**旧串作为前缀，
`-F` 子串匹配下改后仍得 1（L2.5 实测），会使 AC1 与 AC2 互相否定。

### 改动 1 — 第 3 行

old：
```
> 路由层：什么时候做什么。执行协议在 /alex, /blake, /gate, /tad-maintain。
```
new（2 行）：
```
> 路由层：什么时候做什么。**默认通道 = lite（§2.5）**；full（`/alex`, `/blake`, `/gate`）
> 自 2026-08-06 起为**保留通道**，仅在 lite 无等价物时使用。执行协议在各自 skill 文件内。
```

### 改动 2 — 第 7 行

old：
```
读取 `.tad/active/handoffs/` → 必须调用 /blake → 必须过 Gate 3 + Gate 4。
```
new（2 行）：
```
⚠️ 本节只管 full 的 `HANDOFF-*.md`。**新工作默认走 lite（§2.5），不产生 `HANDOFF-*.md`。**
读取 `.tad/active/handoffs/` 中的 `HANDOFF-*.md` → 必须调用 /blake → 必须过 Gate 3 + Gate 4。
```

### 改动 3 — 第 12 行

old：
```
## 2. 使用场景
```
new（11 行）：
```
## 2. 使用场景（full —— 保留通道）

⚠️ **默认走 lite（§2.5）**。下表为 full 通道，**仅在 lite 无等价物时使用**。
2026-08-06 实测：`*publish` / `*sync` / `*research` 的操作知识 lite 已可按需读取
（`release-runbook` skill、`.tad/guides/tool-quick-reference-alex.md`），用普通 LITE 单即可完成
——但 `*publish` / `*sync` 仍受安全停清单第 1 条约束（需人授权），
且工具编排文档单次 ≤2 个文件，不能一张单同时吃 publish + research 两套知识。
lite **已知**无等价物：`*tournament`（竞赛式设计）、`*deps` 系列（操作协议在 full
`references/` 内，lite 读取权限明确排除）、`*knowledge-maintain`（去重 / lint / 退役规程），
以及 full Alex 启动时的自动扫描（依赖演进 / 研究图景 / 僵尸 handoff 提示）。
⚠️ **本清单非穷举**：遇到未列出的 full 命令，先停下来问人。
```

### 改动 4 — 第 85 行

old：
```
| 苏格拉底、专家审查、Epic、配对测试 | `/alex` |
```
new（2 行）：
```
| **lite 全流程（默认通道）** | **`/alex-lite`, `/blake-lite`** |
| 苏格拉底、专家审查、Epic、配对测试 | `/alex`（保留通道） |
```

## AC（每条以 `- AC{n}:` 开头）

- AC7（**成品全文 md5 —— 本单最强判据**）：`md5 -q CLAUDE.md` ==
  **`3f3e7e393674bbc08430d31c4be10042`**（**123 行 / 6877 bytes / 4486 chars**）。
  Alex 已用上述四处 old→new 在内存中精确重放算得该值。
  ⚠️ v1 曾以「四处分散、手工重建易错」为由不写死 md5 —— L2.5 指出这与所引条目的
  AMENDED 边界相反（*"publish only when the answer is cheap to recompute"*），本单答案正是
  cheap to recompute（四次字符串替换）。**已更正为写死。**

- AC8（**change-shape 三断言 —— 补 AC7 之不足**）：
  ```bash
  git diff HEAD --numstat -- CLAUDE.md            # 逐字 == "17	4	CLAUDE.md"（制表符分隔）
  git diff HEAD -U0 -- CLAUDE.md | grep -c '^@@'  # == 4
  wc -l < CLAUDE.md                               # == 123
  ```
  ⚠️ **必须用 `git diff HEAD`（对比 HEAD commit）而非 `git diff`（对比 index）**：
  后者在文件被误 `git add` 后输出变空 → 假 FAIL，与 AC7 的 md5 给出矛盾结论
  （`ac-verification.md` §`Verification Commands That Read the Git Index Are Vacuous Before
  Staging`）。HEAD 已由 AC6 钉死为 `3f4732c`，两条 AC 因此互相加固。
  ⚠️ **必须用 `-U0`**：L2.5 实测默认 `-U3` 下第 3/7/12 行三处改动因 context 连锁**合并成 1 个
  hunk**，总数只得 **2** —— 判别力直接减半（不是 4 vs 3，是 4 vs 2）。
  ⚠️ 为什么必须有这三条：md5 不符只告诉你「不一样」，这三个数告诉你**差在哪个维度**
  （行数 / 改动处数 / 增删比）。L2.5 实证：仅靠 AC1–AC6，一份删掉约 50 行
  （§1 禁止条款、§2 命令表、**§2.5 正文**、规则 1–5、**§4.5 整节**）的交付可六条全绿。

- AC1: 四个**旧串**用 **`grep -Fxc`（全行精确）** 均为 **0**：
  ```bash
  grep -Fxc '> 路由层：什么时候做什么。执行协议在 /alex, /blake, /gate, /tad-maintain。' CLAUDE.md
  grep -Fxc '读取 `.tad/active/handoffs/` → 必须调用 /blake → 必须过 Gate 3 + Gate 4。' CLAUDE.md
  grep -Fxc '## 2. 使用场景' CLAUDE.md
  grep -Fxc '| 苏格拉底、专家审查、Epic、配对测试 | `/alex` |' CLAUDE.md
  ```
  改前实测各为 1。**第 3 条必须用 `-x`**（见上方警告）。

- AC2: 四个**新串首行**用 `grep -Fxc` 均为 **1**：
  ```bash
  grep -Fxc '> 路由层：什么时候做什么。**默认通道 = lite（§2.5）**；full（`/alex`, `/blake`, `/gate`）' CLAUDE.md
  grep -Fxc '⚠️ 本节只管 full 的 `HANDOFF-*.md`。**新工作默认走 lite（§2.5），不产生 `HANDOFF-*.md`。**' CLAUDE.md
  grep -Fxc '## 2. 使用场景（full —— 保留通道）' CLAUDE.md
  grep -Fxc '| **lite 全流程（默认通道）** | **`/alex-lite`, `/blake-lite`** |' CLAUDE.md
  ```
  改前实测各为 0。

- AC3（**§7 之后一字节不动**）：
  ```bash
  S=$(grep -n '^## 7\. Project Knowledge' CLAUDE.md | cut -d: -f1)
  sed -n "${S},\$p" CLAUDE.md | md5 -q
  ```
  == **`ccf18298b96e2b6348c1346d39bff38e`**（21 行，改前实测同值）。

- AC4（**章节结构不变**）：`grep -c '^## ' CLAUDE.md` == **9**，`grep -c '^### ' CLAUDE.md` == **1**
  （Alex L2.25 空跑实测；v1 曾凭记忆写 11，已更正）。

- AC5（**未改内容存活 —— 诊断锚，非独立判据**）：下列 **9** 条各 `grep -Fc` ≥1。
  ⚠️ 锚不得以 `-` 开头（`grep -F` 会当选项，L2.25 实测报 `invalid option`）。
  ⚠️ v1 只有 5 条且落在第 33/42/49/53/88 行，§1（1–32）、§2.5 正文（34–38）、§4.5（59–75）
  **零覆盖**；第 33 行还是拿**小节标题**当锚——正是 `ac-verification.md`
  §`A Positive Existence Anchor Only Protects the Region It Physically Sits In` 点名的反模式。
  v2 补的 4 条**正文**锚为下表第 **1、2、4、8** 行（分别堵 §1、§2 表、§2.5 正文、§4.5）。
  ⚠️ **下列 9 行须逐字照抄，行首不得添加任何标注字符**——v2 初版曾在 block 内给这 4 行加
  `★ ` 前缀作「新增」标记，实测导致 `grep -Fc` 全为 **0**（L2.5 P1-A）。
  **同一条 AC 的上一行正写着「锚不得以 `-` 开头」，紧接着就给锚加了新的行首字符**——
  根因是这 4 条新锚**没有走 L2.25 空跑**（跑了的话 4 个 0 不可能不被发现）。
  ```
  禁止：读取后直接实现、跳过 Gate、不通过 Blake 改代码。
  | `/blake` | 有 handoff → 实现；常规发布 |
  ### 2.5 Lite 通道（默认通道）
  方向互斥：full `/blake`、`/alex` 一律忽略 `LITE-*.md`；`/blake-lite` 只接受 `LITE-*.md`。
  规则 0: Handoff 前必须苏格拉底提问 (⚠️ BLOCKING)
  规则 0-5 适用于 full 通道；Lite 通道的等价约束见 §2.5 与 lite skills 内置条款。
  Alex = Terminal 1, Blake = Terminal 2。**人类是唯一信息桥梁。**
  **Layer 0（机械快照，自动）**：每次压缩前 PreCompact hook 写 `.tad/active/precompact/snapshot-*.md`
  | 文档维护、Handoff 清理 | `/tad-maintain` |
  ```

- AC6（零越权）：`git rev-parse --short HEAD` 仍为 **`3f4732c`**。
  `git status --short` 相对**附录 A 基线（23 行）**的新增部分，只允许落在：
  `CLAUDE.md`（精确）、`.tad/active/handoffs/`、`.tad/archive/handoffs/`、
  **`.tad/active/epics/`**、**`.tad/active/session-state.md`**、
  **`.tad/evidence/audits/lite-constraint-ledger.md`**、
  `.tad/evidence/{reviews,journal,ralph-loops,acceptance-tests,traces,decisions}/`、
  `.tad/memory/`、`.tad/active/precompact/`（以 `/` 结尾者按前缀匹配）。
  ⚠️ **加粗三项是 v2 补的**：`alex-lite/SKILL.md` 的四项写权限例外授权 Alex 写它们，
  而本单是 Epic 最后一单、收尾必然写 Epic 文件 —— v1 的名单是从上一单原样抄来的，
  照协议做事会直接撞 AC（L2.5 P0-3）。

  **黑名单（出现即 FAIL；起草时既有项除外）**：`.claude/skills/`、`.agents/`、`.tad/hooks/`、
  `.claude/settings.json`、`.claude/agents/`、`.tad/config*.yaml`、`.gitignore`、
  `.tad/sync-registry.yaml`、`.tad/logs/`、`README.md`、`INSTALLATION_GUIDE.md`、
  `tad.sh`、`ROADMAP.md`、`CHANGELOG.md`、
  **`.tad/project-knowledge/`（仅 Blake 侧禁止 —— `blake-lite` Forbidden 本就禁写它；
  Alex-Lite 验收后 Knowledge Closeout 的蒸馏写入不构成命中）**。
  ⚠️ `.claude/settings.local.json.bak-20260806-082549` 起草时已存在且未被 gitignore，不构成命中。
  **本单禁止** `git add` / `commit` / `push` / `checkout --` / `stash`。

### 附录 A — AC6 起草时基线（**实跑** `git status --short | LC_ALL=C sort`，HEAD=`3f4732c`，**23 行**）

```
 M .tad/active/epics/EPIC-20260804-lite-as-tad-body.md
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/tracked-after.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/untracked-after.txt
 M .tad/research-notebooks/REGISTRY.yaml
?? .claude/settings.local.json.bak-20260806-082549
?? .tad/active/handoffs/
?? .tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-codex-home/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/
?? .tad/evidence/acceptance-tests/evidence-replayability-check/AC6.txt
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-alex.txt
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-blake.txt
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-tracked-after.sha
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-tracked-after.txt
?? .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/g4-untracked-after.txt
?? .tad/evidence/decisions/2026-08-04.jsonl
?? .tad/evidence/journal/evidence-replayability-check-2026-08-04.md
?? .tad/evidence/ralph-loops/lite-inventory-pricing-audit_state.yaml
?? .tad/evidence/ralph-loops/lite-pricing-gate-protocol_state.yaml
?? .tad/evidence/traces/2026-08-04.jsonl
?? .tad/memory/feedback_cross-project-tracking-boundary.md
```

⚠️ v1 的附录 A 漏抄了第 1 行（`.tad/active/epics/…`，起草时已 dirty），且标 21/22 行 ——
**实测 23 行**，AC6 在 t=0 即会 FAIL。**这是连续第三单栽在同一个坑**（L2.5 P0-2）。

**回滚基线**：改前 `md5 -q CLAUDE.md` == `258fca6d9a0578e988763b6aadf2be86`，
且 `git show 3f4732c:CLAUDE.md | md5 -q` 同值 → 基线可从 HEAD 无损取回，回滚 = `git checkout CLAUDE.md`。

## 知识引用

- `ac-verification.md` §`Verification Strength Is Bounded by the Deliverable's Determinacy`
  （含 2026-08-06 AMENDED）— Action 原文是 *"md5 of a bounded region **+ a change-shape
  assertion**"*。⚠️ **v1 只取了前半句**（且连 md5 都没写死），L2.5 指出后半句才是补全。
  v2 的 AC7（md5）+ AC8（numstat / hunk / 行数）合起来才是该条的完整落地。
  AMENDED 段的边界（*cheap to recompute 就该公布*）也支持写死 md5。
- `ac-verification.md` §`A Positive Existence Anchor Only Protects the Region It Physically
  Sits In` — ⚠️ **v1 漏引了这条，而它直接命中本单**：5 条锚里有 1 条是小节标题、
  三大区域零覆盖。v2 的 AC5 补 4 条正文锚即依此条。
- `ac-verification.md` §`Before Trusting a Guard, Measure Whether Its Trigger Condition Can
  Even Occur` — AC3/AC4 的值均取自 L2.25 空跑实测（**9 / 1**，非 v1 凭记忆写的 11）。
- `handoff-design.md` §`A Change That Makes a Dormant Defect Reachable Owns That Defect` —
  本单降级 full 路由后，5 个发布物中仍指向 full 的表述**会开始与 `CLAUDE.md` 不一致**。
  该不一致由本单造成，故在「风险与注意」显式记录并指定归属，不以「那些文件不是本单改的」搪塞。

## Contract Review (2026-08-06)

Reviewer: code-reviewer subagent (fresh context) | model=claude-opus-5[1m] | route=unknown
首轮 verdict: **CONDITIONAL**（P0=3, P1=4, P2=3）
增量复核 verdict: **CONDITIONAL**（P0=**0** —— v1 三个 P0 逐条实测确认闭合；新增 P1-A / P2-A / P2-B）
最终 verdict: **PASS**（reviewer 明示「删掉 AC5 block 里 4 个 `★ ` 前缀即为 PASS，无需再审」；
已删并实测 9 条锚各命中 1，`★` 前缀数 0。P2-A 一并采纳；P2-B 按 reviewer 建议不在本单动）
P0=3(fixed), P1=5(fixed), P2=3(2 adopted, 1 deferred); 已审 AC 条数: **8**

**增量复核的独立重算**：reviewer 用 `python3` 从**契约文件本身**正则抽出 8 个 fenced block
逐块重放（与 Alex 只共享契约文本、不共享中间产物），四项精确吻合——
md5 `3f3e7e393674bbc08430d31c4be10042` / 123 行 / 6877 bytes / 4486 chars；
AC8 三值亦吻合；附录 A 与实跑 `git status --short` 做**双向集合差**，两侧均为空。

**关键发现（全部采纳）**：

- **P0-1｜AC1#3 数学上不可满足**：`grep -F` 子串匹配下，新标题 `## 2. 使用场景（full —— 保留通道）`
  **包含**旧串 `## 2. 使用场景`，改后仍得 1，而 AC1 要求 0 → 与 AC2#3 互相否定，Blake 怎么做都过不了。
  Alex 独立复现：全行精确=0 / 子串=1。→ 四条统一改 `grep -Fxc`。
- **P0-2｜AC6 在 t=0 即 FAIL**：附录 A 漏抄 `.tad/active/epics/…`（**Alex 本人当天改的**，
  mtime 比契约还早一小时），实测 **23 行**而非 21/22。**连续第三单同一个坑。**
- **P0-3｜AC6 名单从上一单原样抄来，与 lite 协议自身的写权限矛盾**：黑名单含
  `.tad/project-knowledge/`（Knowledge Closeout 规定那是蒸馏唯一入口），白名单缺
  `.tad/active/epics/`（本单是 Epic 最后一单，收尾必写）→ **照协议做事会撞 AC**。
- **P1-1｜缺 change-shape 断言，六条 AC 挡不住掏空 50 行**：reviewer 构造的路径不需要任何
  绕过技巧——删 §1 禁止条款、§2 命令表、§2.5 正文、规则 1–5、§4.5 整节，AC1–AC6 全绿。
  根因是 AC5 锚点分布（33/42/49/53/88）留下三大零覆盖区，且含一条**小节标题锚**。
- **P1-3｜「lite 无等价物只有 2 项」与本 Epic 上一单自己的记录冲突**：
  `LITE-20260806-1000-agents-mirror-parity.md:28` 白纸黑字写着 `*deps` 是「**真缺口**」——
  20 小时前、同一个 Epic、同一个 Alex。而这句话正要写进 `CLAUDE.md` 长期存在。
  另 `*knowledge-maintain`（110 行机械规程）同样在被排除的 `references/` 内。
  → v2 补进清单，并加「本清单非穷举，遇未列出的先停下问人」。
- **P1-4｜知识引用段残留 v1 的「11」**，与 AC4 的「9」自相矛盾 —— 而那条引用的正文主题
  正是「guard 的值必须实测」。→ 已改。
- **P2-1｜写进 `CLAUDE.md` 的两个字数一个是字节一个是字符**（26,370 `wc -c` vs 11,270 `wc -m`）
  → v2 **直接删掉字数**，不在路由层文件里留易腐的数字。
- **P2-2｜改动 3 措辞与 lite 两条硬约束张力**：`*publish`/`*sync` 仍受安全停清单第 1 条约束；
  工具编排文档单次 ≤2 个文件，「一张单同时干 publish + research」不可同时满足 → 已在新文本写明。
- **P2-3｜行数「由实现决定」实为完全确定** → 已钉死 110 → 123。

**增量复核新增（v2 → v3）**：

- **P1-A｜AC5 的 4 条新锚照抄即得 0 —— 本条 AC 自己警告过的同一类错误**：
  v2 在 fenced block **内部**给 4 条新锚加了 `★ ` 作「新增」标注，实测 `grep -Fc` 全为 **0**，
  而且**恰好是 v2 新补的那 4 条**（原 5 条全 ok）。
  ⚠️ **同一条 AC 的上一行正写着「锚不得以 `-` 开头（grep -F 会当选项）」**——记录了
  「锚的行首字符会毁掉 grep」，紧接着就给锚加了新的行首字符。
  **根因：这 4 条新锚没有走 L2.25 空跑**（跑了的话 4 个 0 不可能不被发现）。
  → 已删前缀，标注挪到 block 外；实测 9 条各命中 1、`★` 前缀数 0。
  **reviewer 建议将此蒸馏为知识：修复 guard 时新增的 guard，必须和原 guard 走同一道空跑——
  修复动作不自动继承被修复对象的验证。**

- **P2-A｜`git diff --numstat` 对 index 敏感** → 改用 `git diff HEAD --numstat`。
  文件若被误 `git add`，前者输出变空 → 假 FAIL，且与 AC7 的 md5 给出矛盾结论
  （`ac-verification.md` §`Verification Commands That Read the Git Index Are Vacuous Before Staging`）。
  同时把 hunk 注释改为实测值：**`-U0` 得 4；默认 `-U3` 因 context 连锁只得 2**
  （reviewer 更正了自己 v1 报告里「会合并成 3」的说法——实为 2，判别力减半而非小差别）。

- **P2-B｜8 条 AC 中 6 条用 `- AC7（` 而非模板要求的 `- AC{n}:`** —— reviewer 已确认
  **无任何机械 parser 依赖该格式**（`alex-lite:112` 只是模板说明），且前几单归档契约写法相同。
  按其建议**不在本单改**（改模板会碰 skill 文件，违反本单「不改任何 skill 文件」），记录归下次。

## 风险与注意

- 🔴 **本单造成的文档不一致（归属已指定）**：改后 `CLAUDE.md` 说 full 是保留通道，而
  `README.md` / `INSTALLATION_GUIDE.md` / `ROADMAP.md` / `CHANGELOG.md` / `tad.sh`
  仍把 `/alex` `/blake` `/gate` 描述为主路径。**这个不一致由本单造成**（改前两者一致）。
  → 归属：**下次 `*publish` 时一并同步**（那时本就要动发布物，属安全停清单第 1 条、需人授权）。
  不得声称「那些文件不是本单改的所以无关」。

- **full 仍完全可用**：三个 skill 文件一字节未动，`/alex` `/blake` `/gate` 照常工作。
  本单只改「推荐哪条路」，不改「哪条路存在」。**回滚 = `git checkout CLAUDE.md`。**

- **caller/consumer 检查**：`CLAUDE.md` 的消费方 = Claude Code 每 session 自动注入
  + Codex 侧的 `AGENTS.md`。⚠️ 本单**不改** `AGENTS.md`，故 Codex 侧路由描述将与
  Claude Code 侧不一致——与第一条同源，同归下次 publish。
  已实测第 90 行起的 @import 链不受影响（AC3 锚定）。

- **自指**：`CLAUDE.md` 每 session 自动注入，改它影响**下一个** session 的路由认知
  （当前 session 已加载旧版）。执行期间若压缩，不得重跑 `/blake-lite` → 停下报人。
  AC6 的 `HEAD == 3f4732c` 是机械兜底。

---

## Lite Progress

- Phase=admission | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/full-standdown/ac-results.md | Next Action=实现 4 处改动
- L0 准入：LITE-*.md 白名单命中；L0.5 机械检查全过（最终 verdict PASS / Reviewer 非空 / P0=3(fixed) / 已审 AC 条数 8==机械计数 8）；安全停清单三项未命中（CLAUDE.md 改动非不可逆[git checkout 可回滚]/非 SAFETY 面/非注册面）
- L0.75：知识引用（ac-verification.md 三条目 + handoff-design.md 一条目）契约内已含关键内容；基线预检全过（HEAD=3f4732c、110 行、改前 md5 258fca6d==HEAD 版、§7 md5 ccf18298、## 9/### 1、AC1 改前 1×4、AC2 改前 0×4、附录 A 23 行含 epics 行）
- Phase=implement | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/full-standdown/ac-results.md | Next Action=AC 自验
- 四处 Edit 完成（old→new 逐字；改动 3 标题替换 + 10 行说明插入）
- Phase=ac | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/full-standdown/ac-results.md | Next Action=L3 独立审查
- 结果：AC7/AC8/AC1–AC6 全部首跑 PASS（md5 3f3e7e39 全维度命中；numstat 17→4 逐字；hunk -U0=4；旧串 0×4 新串 1×4；§7 锚不变；9 锚全命中；AC6 基线新增恰 1 项）；0 repair loop
- Phase=review | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/reviews/blake/full-standdown/code-reviewer.md | Next Action=L3.5 Technical Gate → L4 Completion
- L3 reviewer: PASS | model=deepseek-v4-flash | P0=0 P1=0 P2=3（8 条 AC 逐字重跑全绿；四处改动逐字落地含改动 3 的 11 行；§7 锚不动；回滚基线 git show 与契约一致；语义声明逐一对证成立；新文本零 MUST）；P2-3 采纳（ac-results.md 补时点注记），P2-1/P2-2 记录归维护

---

## Completion (2026-08-06)

**Commit**: uncommitted（本单零 git 写操作；commit 归人决定）
**Model**: harness=claude-code | model=deepseek-v4-flash | route=api.deepseek.com (alias-mapped)

- 上下文刷新：已读 CLAUDE.md 全文（110 行）、契约全文（含 Contract Review 8 条 AC + 知识引用）；基线预检全绿（HEAD=3f4732c、改前 md5 258fca6d==HEAD 版[回滚基线可无损取回]、§7 md5 ccf18298、## 9/### 1、AC1 改前 1×4、AC2 改前 0×4、附录 A 23 行含 epics 行）；关键约束：四处 old→new 逐字、§7 之后一字节不动、禁任何 git 写操作、AC 按编号执行；成功条件：AC7/AC8/AC1-AC6 全绿 + reviewer PASS + Technical Gate PASS
- 改动文件：
  - CLAUDE.md（110→123 行，四处纯增量：路由层说明/Handoff 规则限定 HANDOFF-*.md/§2 标题+9 行保留通道说明/§6 表 lite 默认行；md5 3f3e7e39…）
  - [清单外：白名单证据载体] .tad/evidence/acceptance-tests/full-standdown/ac-results.md（新建）
  - [清单外：白名单证据载体] .tad/evidence/reviews/blake/full-standdown/code-reviewer.md（新建）
  - [清单外：白名单证据载体] 本契约自身（Lite Progress 5 边界 + Completion + Reflexion）
- AC 结果：AC7/AC8/AC1-AC6 全部 ✅ 首跑通过（0 repair loop），原始输出 → .tad/evidence/acceptance-tests/full-standdown/ac-results.md（reviewer 独立重跑逐字一致）
  - AC7 ✅ md5=3f3e7e393674bbc08430d31c4be10042 / 123 行 / 6877 B / 4486 chars（最强判据）
  - AC8 ✅ numstat 17→4 逐字 / hunk(-U0)=4 / 123 行（-U3 实测只得 2，契约警告成立）
  - AC1 ✅ 旧串 0×4（-Fxc 全行精确）| AC2 ✅ 新串 1×4 | AC3 ✅ §7 锚 ccf18298 不变（21 行）
  - AC4 ✅ ## 9 / ### 1 | AC5 ✅ 9 锚全命中、★ 残留 0 | AC6 ✅ HEAD=3f4732c / 基线新增恰 1 项（CLAUDE.md）/ 黑名单 0
- Reviewer: PASS | model=deepseek-v4-flash, P0=0, P1=0, P2=3 | 摘录：8 条 AC 逐字重跑全绿；四处改动逐字落地（AC2 只覆盖首行，reviewer 补齐验证其余 8 行新文本，改动 3 精确 11 行）；§7 @import 链一字节未动；回滚基线 git show 3f4732c:CLAUDE.md=110 行/258fca6d 与契约一致；语义声明逐一与 skill 内容对证（安全停清单第 1 条/≤2 文件/*deps/*knowledge-maintain/*tournament/自动扫描/release-runbook）；新文本零 MUST/禁止 token（不触发约束准入闸成立）（执行实证）
- Technical Gate: **GATE PASS**
  1. AC/evidence：8 条 AC 全部有原始输出与证据路径（自验 + reviewer 双份）✅
  2. reviewer verdict：PASS，P0=0 P1=0 ✅
  3. friction：无 BLOCKED ✅
  4. scope/risk：改动限于 CLAUDE.md 一处；caller/consumer 检查——消费方 = Claude Code 每 session 自动注入 + Codex AGENTS.md（本单未改，路由不一致归下次 publish）；§7 @import 链 AC3 锚定 ✅
  5. Knowledge Assessment：journal captured → .tad/evidence/journal/lite-discoveries.md 追加 1 行 ✅
- Knowledge Assessment: journal captured（.tad/evidence/journal/lite-discoveries.md 2026-08-06 行：-U0 hunk 连锁 + -Fxc 全行精确）
- 意外发现：reviewer 实证 `-U3` 因 context 连锁把 4 处改动合并成 2 个 hunk（判别力减半）——契约警告成立并已记 journal
- follow-up：
  - 🔴 **本单造成的文档不一致（归属已指定，不得声称无关）**：改后 CLAUDE.md 说 full 是保留通道，而 README.md / INSTALLATION_GUIDE.md / ROADMAP.md / CHANGELOG.md / tad.sh 仍把 /alex /blake /gate 描述为主路径 → **下次 *publish 时一并同步**（届时本要动发布物，属安全停清单第 1 条需人授权）| owner=Alex-Lite
  - AGENTS.md（Codex 侧）路由描述未同步 → 与上条同源，同归下次 publish | owner=Alex-Lite
  - P2-1（Lite Progress 说明行格式游离）→ 记录归下次维护 | owner=Alex-Lite
  - P2-2（§6 协议位置表 /blake、/gate 行未标「保留通道」，契约逐字指定实现无偏差）→ 归下次维护 | owner=Alex-Lite
  - 回滚 = git checkout CLAUDE.md（基线 258fca6d 从 HEAD 无损取回）
  - 本单是 Epic 最后一单（P6 6/6）；Epic 收尾（EPIC 文件状态更新）归 Alex 侧验收后处理
  - 本单 + P5a/P5b/P5c 工作区改动均未 commit（发布归人）
- 显式声明（AC6 结构性盲区）：本单**未触碰** `.claude/settings.local.json` 与 `.tad/logs/violations.log`；全部写操作仅限 CLAUDE.md + 白名单证据载体

## Reflexion

无修复。
- Phase=technical-gate | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/full-standdown/ac-results.md + .tad/evidence/reviews/blake/full-standdown/code-reviewer.md | Next Action=人验收（L5）→ 验收后 mv 到 .tad/archive/handoffs/
- Phase=human-gate | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=同上 | Next Action=人验收 → 归档（Epic 收尾归 Alex 侧）
