# LITE Handoff: `.agents/` 镜像补齐 P5a + P5b

**Date**: 2026-08-06
**Series**: EPIC-20260804-lite-as-tad-body step 5c-1/2（余下：`*deps` 知识缺口单独评估）

## 目标（2-3 句，含"为什么"）

P5a 与 P5b 只改了 `.claude/skills/` 侧，Codex 平台的 `.agents/` 镜像**落后 1–2 代**——
两平台的 lite agent 现在受**不同的 Forbidden 约束**。用户 2026-08-06 裁定「保持一致」。

本单把两个 lite skill 字节复制到 `.agents/`，使两侧完全一致。
同步后 Codex 侧 lite agent 立即获得 P5a + P5b 的全部放开（写 Epic/台账/知识、
自由 spawn、人授权后 commit·push）——**这是用户明确要的**，非副作用。

## 不做什么

- ❌ **不整树 rsync**。`.agents/skills/` 下有 **62 个条目**（`.claude/skills/` 为 63，
  多出的是 gitignored 的 `local/`），本单只碰 2 个具名文件。
  依 `release-sync.md` 的事故记录：整树镜像会把源侧按契约 gitignore 的
  `.claude/skills/local/`（`*save-skill` 私有产物）复制到目的侧。
  ⚠️ **git 可见性层面该风险已被两道缓解闭合**（Gate 2 实测更正——原契约称"那里没有
  ignore 规则"是错的）：`.gitignore:16` 已忽略 `.agents/skills/local/`；
  `.tad/hooks/lib/release-verify.sh:681` 的 parity 已带 `--exclude=/local/`。
  **剩余风险是私有内容在公开仓工作区落盘**——它对 `git status` 不可见，
  由 **AC6 的 `diff -rq`** 捕获，AC4 捕获不到。本单不触碰任何其它路径。
- ❌ 不改 `.claude/` 侧任何文件（本单是**单向** `.claude/` → `.agents/`）。
- ❌ 不动 `.agents/skills/{alex,blake}/`（full 侧）或其余 60 个条目。
- ❌ 不搬 `*deps` 的操作知识（真缺口，但属独立议题，见「风险与注意」）。
- ❌ 不执行 git commit / push / publish / sync。
- ❌ 不新增任何 MUST / 禁止条目 → **不触发约束准入闸**，不追加台账。

## 文件清单（创建/修改，逐个路径）

**修改 2 个**（均为 git-tracked，已确认）：
- `.agents/skills/alex-lite/SKILL.md`（319 行 → 334 行）
- `.agents/skills/blake-lite/SKILL.md`（371 行 → 378 行）

**创建 0 个。** 除上述 2 个 + 本契约 + 常规证据载体外，工作区不得出现其它改动。

### 同步方式

逐文件复制，**不用 rsync、不用 `cp -r`、不用通配符**：

```bash
cp .claude/skills/alex-lite/SKILL.md  .agents/skills/alex-lite/SKILL.md
cp .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md
```

## AC（每条以 `- AC{n}:` 开头）

- AC1: `md5 -q .agents/skills/alex-lite/SKILL.md` == **`1a6bc26c010dba163a69c1fea40e6c82`**
  （改前为 `e3d67da7a5f5aaa5d6405b10bf70de09`，即 P5a 之前的版本）

- AC2: `md5 -q .agents/skills/blake-lite/SKILL.md` == **`b9a0c096b5fd4436b0a288dee713d55e`**
  （改前为 `092c4e7c36853289b1fc2ad596368de0`，即 P5b 之前的版本）

- AC3（**反向污染检查**）：`.claude/` 侧两文件 md5 **必须不变**——
  `md5 -q .claude/skills/alex-lite/SKILL.md` == `1a6bc26c010dba163a69c1fea40e6c82`
  且 `md5 -q .claude/skills/blake-lite/SKILL.md` == `b9a0c096b5fd4436b0a288dee713d55e`。
  本单是单向同步；若 `.claude/` 侧也变了，说明方向搞反或用了双向工具 → FAIL。

- AC4（git 层范围检查）：`git status --short .agents/` 的输出**恰好 2 行**，
  且两行分别指向 `.agents/skills/alex-lite/SKILL.md` 与 `.agents/skills/blake-lite/SKILL.md`。
  （起草时该命令输出为**空**，已实测。）
  ⚠️ **本条不是整树同步的否证**（Gate 2 P0-1 证伪）：`diff -rq` 显示整棵树里
  只有这 2 个文件不同，其余 59 个已逐字节一致 → 整树 rsync **在构造上也只产生 2 行**；
  且裸 rsync 新建的 `.agents/skills/local/` 被 `.gitignore:16` 忽略、同样不进 `git status`。
  真正的否证是 **AC6**。本条保留仅作 git 层的冗余确认。

- AC6（**整树同步与 local/ 泄漏的真否证 —— 本单最强判据**）：
  在**仓库根**执行：
  ```bash
  diff -rq .claude/skills .agents/skills
  ```
  输出必须**恰好 1 行**，且逐字为 `Only in .claude/skills: local`。
  - 起草时该命令输出 **3 行**（2 行 `…SKILL.md differ` + 上述 1 行），已实测 → 判别力 3→1 真实存在
  - 多出 `…differ` 行 → 有 skill 未同步或被误改
  - 少了 `Only in .claude/skills: local` 那行 → **`.agents/skills/local/` 被创建了**
    （整树 rsync 的特征，且该目录被 gitignore、`git status` 看不见）
  - 附加断言：`test ! -e .agents/skills/local && echo CLEAN`

- AC5（零越权）：`git rev-parse --short HEAD` 仍为 **`05e2822`**。
  `git status --short` 相对**附录 A 起草时基线（22 行）**的新增部分，只允许落在：
  上述 2 个 `.agents/` 文件（精确）、`.tad/active/handoffs/`、`.tad/archive/handoffs/`、
  `.tad/evidence/{reviews,journal,ralph-loops,acceptance-tests,traces,decisions}/`、
  `.tad/memory/`、`.tad/active/precompact/`（以 `/` 结尾者按前缀匹配）。
  **黑名单（出现即 FAIL；下述起草时既有项除外）**：`.claude/`（任何路径，
  **例外：`.claude/settings.local.json.bak-20260806-082549` —— 起草时已存在且未被 gitignore，
  Gate 2 实测确认，不构成命中**）、`CLAUDE.md`、`.tad/hooks/`、
  `.tad/config*.yaml`、`.tad/project-knowledge/`、`.gitignore`、`.tad/sync-registry.yaml`、
  `.tad/logs/`、`.agents/` 下除上述 2 个文件外的任何路径。
  **本单禁止** `git add` / `commit` / `push` / `checkout --` / `stash`。

### 附录 A — AC5 起草时基线（实测，HEAD=`05e2822`，22 行）

```
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

## 知识引用

- `.tad/project-knowledge/patterns/release-sync.md` §`A Mirror/Parity --fix That Copies a
  Tree Wholesale Destroys the Source's Gitignore Semantics` — 整树镜像会把源侧
  gitignored 的子树复制到目的侧。
  ⚠️ **引用更正（Gate 2 P1-2）**：该条目原文带有 mitigation 半句（`.agents/skills/local/`
  已加进 `.gitignore`），本契约 v1 转述时漏掉了它，导致把"那里没有 ignore 规则"当成现状。
  实测：`.gitignore:16` 与 `release-verify.sh:681` 的 `--exclude=/local/` 已闭合 git 可见性，
  **剩余风险只是私有内容在公开仓工作区落盘**。本单据此禁止整树同步、改为 2 个具名文件逐一 `cp`，
  并用 **AC6 的 `diff -rq`** 否证整树行为（v1 曾以为 AC4 能做到，Gate 2 证伪）。
  （附带：该知识条目自身的「ROOT FIX STILL OPEN」表述也已过时——`release-verify.sh:681`
  已带 `--exclude=/local/`。属独立议题，本单不改知识文件。）
- `.tad/project-knowledge/patterns/ac-verification.md` §`Verification Strength Is Bounded by
  the Deliverable's Determinacy` — 交付物是确定文本 → AC1/AC2 用成品全文 md5，零伪造面。
- `.tad/project-knowledge/patterns/ac-verification.md` §`Replacing a Path-Agnostic Prohibition
  with a Path-Specific Glob Silently Halves Its Coverage`（2026-08-06 本 Epic 蒸馏）—
  AC5 黑名单写 `.claude/`（整个前缀）而非某个具体文件，避免同类收窄。

## Contract Review (2026-08-06)

Reviewer: code-reviewer subagent (fresh context) | model=claude-opus-5[1m] | route=unknown
首轮 verdict: **CONDITIONAL**（P0=2, P1=2, P2=2）
增量复核 verdict: **CONDITIONAL**（首轮 6 条全部确认关闭；新增 P0-3 / P1-3 / P2-3）
最终 verdict: **PASS**（reviewer 明示「改完 P0-3 与 P1-3 即可直接 PASS，无需再送审——
两处都是纯文本替换，无需重新核验数值」；两处已改并实测验证）
P0=3(fixed), P1=3(fixed), P2=3(2 adopted, 1 已知取舍); 已审 AC 条数: 6

**关键发现**：

- **P0-1｜AC4 零判别力（v1 的核心缺陷）**：reviewer 未尝试绕过，而是**先测 AC4 的前提**——
  `diff -rq` 显示整棵树里只有本单要改的 2 个文件不同，其余 59 个已逐字节一致
  → 整树 rsync **在构造上也只产生 2 行** `git status`；且裸 rsync 新建的
  `.agents/skills/local/` 被 `.gitignore:16` 忽略、同样不进 status。
  **AC4 对它声称要防的两件事都是零判别力。**
  → 新增 **AC6**（`diff -rq` 恰好 1 行）。实测判别力：正确执行 3→1，裸 rsync 3→**0**（"Only in" 行消失），机械可分。
  AC6 残余盲区（reviewer 已列，接受）：`parity --fix` 的终态与 `cp` 逐字节相同故检测不到（**但无危害**，AC 是状态判据）；
  `rsync` 后手工 `rm -rf` 可洗掉（需蓄意两步，单人 CLI 按 SAFETY 原则用软禁令即可）。
  ⚠️ 准确表述是「否证任何**留下痕迹**的整树同步」，不是「否证任何整树同步」。

- **P1-2｜引用知识条目时漏读 mitigation**：v1 称"目的侧没有 ignore 规则"是**错的**——
  `release-sync.md` 原文自带 mitigation 半句，且实测 `.gitignore:16` 与
  `release-verify.sh:681` 的 `--exclude=/local/` 早已闭合 git 可见性。
  基于错误理由设计的 AC4 因此落空，而真正的剩余风险（私有内容在工作区落盘、
  `git status` 不可见）反倒无人管。已重写 §2 理由并交由 AC6 覆盖。

- **P0-2｜AC5 在 t=0 即 FAIL**：`.claude/settings.local.json.bak-20260806-082549`
  （Alex 本 session 自己造的备份，未被 gitignore）命中黑名单 `.claude/` 任何路径。
  **与上一单同款缺陷。** 已加具名例外 + 附录 A 落盘 22 行基线（reviewer 逐行比对确认一致）。

- **P0-3｜AC6 写法绕过 blake-lite 的机械 AC 计数器**：`blake-lite:71` 规定
  `grep -cE '^- ?AC[0-9]'`，而 `- **AC6（` 的前导 `**` 使其不匹配 → 实跑得 5 而非 6，
  且违反本契约 §AC 自己写的「每条以 `- AC{n}:` 开头」。已把加粗移入括号，实测计数 = 6。

- **P1-3｜删了错误主张却漏了一处复述**：AC4 已如实降级，但「风险与注意」仍写着
  「AC4 机械保证」。已改为 AC6，实测残留 0。

**已知取舍（未改）**：AC6 块排在 AC5 之前（顺序 1/2/3/4/6/5）。reviewer 判定重排为可选；
机械计数只看数量已通过，移动整块有引入错误的风险，故保留现状。Blake 请按**编号**而非位置执行。

## 风险与注意

- **两侧无平台特有内容（完整 diff，非抽样 —— Gate 2 P2-2 要求换掉原来的弱论证）**：
  `diff .claude/skills/{s}/SKILL.md .agents/skills/{s}/SKILL.md` 显示 `.agents` 侧独有行
  仅 **alex 6 行 / blake 5 行**，全部是 P5a/P5b 之前版本的同一批 Forbidden 条款
  （无界加载、spawn、session-state、改文件范围），**无一行含 codex/AGENTS.md 平台特有内容**。
  （旧论证「前 60 行一致 + 关键词命中数 5/3」不够：60 行之外未覆盖，且 5/3 仅在
  `grep -ciE` 下成立，`grep -cE` 得 2/2 —— 原契约未写出所用命令，可复现性有缺口。）
  故字节复制不会覆盖掉平台特有逻辑。

- **同步的实际后果（用户已知情裁定）**：Codex 侧 lite agent 立即获得
  写 `.tad/active/epics/`、`.tad/project-knowledge/`、台账、`session-state.md` 的权限，
  以及自由 spawn 与人授权后 commit·push。P5a/P5b 契约 §6 记录的暴露面
  （spawn 无机械阻断、授权链自判）**同样适用于 Codex 侧**，且 Codex 侧的
  权限配置与 Claude Code 不同——本单未评估 Codex 的 `permissions` 等价物。

- **caller/consumer 检查**：`.agents/skills/*/SKILL.md` 的消费方 = Codex 的 skill 加载器。
  已确认两文件 git-tracked（`git ls-files` 命中）。`.agents/` 下另有 60 个条目，
  本单一个不碰，**由 AC6 机械保证**（AC4 仅 git 层冗余确认，其局限见 AC4 条文）。**未做「Codex 加载器是否对 334/378 行有长度限制」的验证**——
  不得声称"无下游影响"；若 Codex 侧加载异常，回退方式是 `git checkout` 这两个文件。

- **`*deps` 是本 Epic 剩下的真缺口**（本单不解）：调查发现
  `*publish` 的操作知识在 `release-runbook` skill（26,370 chars）、
  `*research` 在 `.tad/guides/tool-quick-reference-alex.md`（11,270 chars）——
  **两者都已在 P5b 放开的读取白名单内，lite 不需要"搬流程"即可执行**。
  但 `*deps` 的知识在 full alex 的 `references/deps-protocol.md`，
  而该路径被 P5b **明确排除**（full 协议正文 291K）。
  → 需单独决定：把 deps 操作要点摘进 `.tad/guides/`，还是放弃 lite 侧的 `*deps`。

- **本单不改 `.claude/` 侧**，故不存在「改了协议又立刻按新协议行事」的自指问题。
  执行期间若发生压缩，仍不得重跑 `/blake-lite`（通用保守动作）。

---

## Lite Progress

- Phase=admission | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/agents-mirror-parity/ac-results.md | Next Action=实现 2 条 cp
- L0 准入：LITE-*.md 白名单命中；L0.5 机械检查全过（最终 verdict PASS / Reviewer 非空 / P0=3(fixed) / 已审 AC 条数 6==机械计数 6，契约内联写法数值一致）；安全停清单三项未命中（cp 到 git-tracked 路径可回退，非不可逆/非 SAFETY 面/非注册面）
- L0.75：知识引用全文已读（release-sync.md §A 含 mitigation 半句、ac-verification.md 两条目 L231-237/L254-260）；实测 .gitignore:16=.agents/skills/local/、release-verify.sh:681 带 --exclude=/local/（ROOT FIX 已闭合，知识条目表述过时属实）；基线预检全过（HEAD=05e2822、.agents status 0 行、改前 md5 e3d67da7/092c4e7c、AC6 起草时 3 行、local 不存在）
- Phase=implement | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/agents-mirror-parity/ac-results.md | Next Action=AC 自验
- 两条逐文件 cp 完成（未用 rsync/cp -r/通配符）；md5 立即命中目标（1a6bc26c / b9a0c096）
- Phase=ac | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/agents-mirror-parity/ac-results.md | Next Action=L3 独立审查
- 结果：AC1–AC6 全部首跑 PASS（AC6 核心判据：diff -rq 恰好 1 行逐字 Only in .claude/skills: local + local CLEAN；AC3 反向污染无；AC5 基线新增除证据载体外恰 2 个）；0 repair loop；注：diff 退出码 1 截断 && 链已改为逐条单跑
- Phase=review | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/reviews/blake/agents-mirror-parity/code-reviewer.md | Next Action=L3.5 Technical Gate → L4 Completion
- L3 reviewer: PASS | model=deepseek-v4-flash | P0=0 P1=0 P2=3（双向探针实证 AC6 判别力；cmp 字节一致；改前 md5 与 HEAD 复算吻合；机械计数 6==6）；3 条 P2 已全部就地修复（ac-results.md 措辞 + Progress 前缀/Evidence 字段）
- Phase=technical-gate | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/agents-mirror-parity/ac-results.md + .tad/evidence/reviews/blake/agents-mirror-parity/code-reviewer.md | Next Action=L4 Completion → 人验收

---

## Completion (2026-08-06)

**Commit**: uncommitted（本单零 git 写操作；commit 归人决定）
**Model**: harness=claude-code | model=deepseek-v4-flash | route=api.deepseek.com (alias-mapped)

- 上下文刷新：已读契约全文、release-sync.md 全文（§A 条目含 mitigation 半句——本次读全文未只读标题）、ac-verification.md 两条目全文（L231-237 Verification Strength / L254-260 Path-Agnostic Prohibition）；实测 `.gitignore:16`=.agents/skills/local/、`release-verify.sh:681` 带 --exclude=/local/（ROOT FIX 已闭合，知识条目表述过时属实）；关键约束：2 条逐文件 cp（不用 rsync/cp -r/通配符）、单向 .claude→.agents、AC 按编号执行（顺序 1/2/3/4/6/5）、禁任何 git 写操作；成功条件：AC1-AC6 全绿 + reviewer PASS + Technical Gate PASS
- 改动文件：
  - .agents/skills/alex-lite/SKILL.md（319→334 行，cp 自 .claude 侧，md5 1a6bc26c…）
  - .agents/skills/blake-lite/SKILL.md（371→378 行，cp 自 .claude 侧，md5 b9a0c096…）
  - [清单外：白名单证据载体] .tad/evidence/acceptance-tests/agents-mirror-parity/ac-results.md（新建）
  - [清单外：白名单证据载体] .tad/evidence/reviews/blake/agents-mirror-parity/code-reviewer.md（新建）
  - [清单外：白名单证据载体] 本契约自身（Lite Progress 5 边界 + Completion + Reflexion）
- AC 结果：AC1-AC6 全部 ✅ 首跑通过（0 repair loop），原始输出 → .tad/evidence/acceptance-tests/agents-mirror-parity/ac-results.md（reviewer 独立重跑 + 双向探针逐字一致）
  - AC1 ✅ md5=1a6bc26c010dba163a69c1fea40e6c82（改前 e3d67da7…）
  - AC2 ✅ md5=b9a0c096b5fd4436b0a288dee713d55e（改前 092c4e7c…）
  - AC3 ✅ .claude/ 侧两文件 md5 不变（单向成立）
  - AC4 ✅ git status --short .agents/ 恰好 2 行（冗余确认）
  - AC6 ✅ diff -rq 恰好 1 行逐字 `Only in .claude/skills: local` + `test ! -e .agents/skills/local` → CLEAN（核心判据）
  - AC5 ✅ HEAD=05e2822 / 基线新增除证据载体外恰 2 个（白名单精确命中）/ 黑名单零命中
  - 注：diff 退出码 1 属预期，&& 链首跑被截断后已改为逐条单跑（Gate 2 P2-3 同族陷阱）
- Reviewer: PASS | model=deepseek-v4-flash, P0=0, P1=0, P2=3 | 摘录：AC1-AC6 逐条执行实证 PASS；双向探针（Probe A 未同步→differ 行出现 / Probe B 创建 local/→Only-in 行消失）实证 AC6 判别力真实；cmp 两侧字节一致（ALEX-IDENTICAL/BLAKE-IDENTICAL）；改前 md5 从 HEAD 独立复算与契约记载逐字一致（纯同步非夹带）；机械计数 6==6（P0-3 修复有效）；无新增 MUST 未过闸（执行实证）
- Technical Gate: **GATE PASS**
  1. AC/evidence：6 条 AC 全部有原始输出与证据路径（自验 + reviewer 双份）✅
  2. reviewer verdict：PASS，P0=0 P1=0 ✅
  3. friction：无 BLOCKED ✅
  4. scope/risk：改动限于契约 2 个具名文件；caller/consumer 检查——消费方 = Codex skill 加载器，两文件 git-tracked 可回退；「未做 Codex 加载器长度限制验证」已诚实声明（不得声称无下游影响）✅
  5. Knowledge Assessment：journal captured → .tad/evidence/journal/lite-discoveries.md 追加 1 行 ✅
- Knowledge Assessment: journal captured（.tad/evidence/journal/lite-discoveries.md 2026-08-06 行：Progress 前缀污染 + AC6 判别力实证）
- 意外发现：P2-2 揭示 Lite Progress 行以「- AC」开头会污染全文 AC 机械计数（协议命令靠 awk 范围限定不受影响，全文扫描会误计）——已修复并记 journal
- follow-up：
  - ✅ **P5b follow-up 关闭**：`.agents/` 镜像已同步（本单即 5c-1/2），两平台 alex-lite/blake-lite Forbidden 现完全一致（diff -rq 仅剩 local 行）
  - 余下：`*deps` 知识缺口单独评估（5c-2/2）——知识在 full alex 的 references/deps-protocol.md（被 P5b 明确排除），需决定：摘要点进 `.tad/guides/` 或放弃 lite 侧 *deps | owner=Alex-Lite
  - Codex 加载器对 334/378 行的长度限制未验证（契约已声明）；若 Codex 侧加载异常，回退 = git checkout 两文件 | owner=Alex-Lite
  - 知识条目 release-sync.md「ROOT FIX STILL OPEN」表述过时（release-verify.sh:681 已闭合）——独立议题，未改知识文件 | owner=Alex-Lite
  - P2-1/P2-2/P2-3 已全部就地修复（ac-results.md 措辞 + Progress 前缀/Evidence 字段）
  - 本单 + P5a/P5b 工作区改动均未 commit（发布归人）
- 显式声明（AC5 结构性盲区）：本单**未触碰** `.claude/settings.local.json`（gitignore 盲区，AC5 验不出）与 `.tad/logs/violations.log`；全部写操作仅限 2 个 .agents/ 文件 + 白名单证据载体

## Reflexion

无修复（3 条 P2 措辞建议已就地采纳，非错误循环）。
- Phase=human-gate | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/agents-mirror-parity/ac-results.md + .tad/evidence/reviews/blake/agents-mirror-parity/code-reviewer.md | Next Action=人验收（L5）→ 验收后 mv 到 .tad/archive/handoffs/
