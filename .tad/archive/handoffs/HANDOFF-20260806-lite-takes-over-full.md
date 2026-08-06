# HANDOFF: 修复 alex-lite 写权限条款的自相矛盾

**Date**: 2026-08-06
**Revision**: **v3**（v1 FAIL → v2 CONDITIONAL/PASS → v3。累计修 5 P0 + 4 P1，见 §7）
**Epic**: `.tad/active/epics/EPIC-20260804-lite-as-tad-body.md` — Phase 5a
**From**: Alex (Terminal 1, full) → **To**: Blake (Terminal 2)

---

## 1. 目标

`alex-lite` 的 Forbidden 有一条「修改 LITE 契约之外的任何文件」，
与**同一文件内**的两个协议节直接矛盾：

| 协议节 | 原文要求 | 位置 |
|---|---|---|
| 约束准入 | 「必须先在 `.tad/evidence/audits/lite-constraint-ledger.md` 追加一行」 | alex-lite L240 |
| Knowledge Closeout | 「这是成品知识写入 `.tad/project-knowledge/` 的唯一入口」 | alex-lite L203 |

例外条款只豁免了「无界加载」那条，**没有豁免本条**。

**这不是理论问题，是每张 lite 单都在踩的**：2026-08-05 P4 执行中已撞两次——
蒸馏知识时写了 `project-knowledge/`（当时误判为显式例外）；
验收后要更新 Epic 被挡住，被迫启动 full 通道（固定读取量 221K vs lite 62K，3.56 倍）。

本单**只修这一条**，改动限于 1 个文件、1 节、**1 处**。

---

## 2. 不做什么

**v1 曾计划放宽 7 条，v2 砍到 2 处，v3 砍到 1 处。** 以下全部**不动**：

- ❌ `除设计期契约 reviewer 外不得 spawn 任何 subagent` —— security-auditor 实证：
  subagent 不加载 alex-lite 的 Forbidden、不读安全停清单、拥有 All tools，而
  `settings.local.json` 已预授权 `Bash(git push:*)`、`permissions.deny` 为空、
  Write/Edit hook 默认全 ALLOW → 放宽即等于开一条零弹窗的绕过通道。
- ❌ `无界加载…任何 references/` —— `.claude/skills/alex/references/` 是
  **364 KB / 30 个 full 协议正文**。放开等于「不许看目录，但可以看目录指向的全部正文」。
- ❌ `git commit 或 push`（blake 侧）—— 授权链无闭环；且实测安全停清单第 1 条只枚举
  `force-push / 删分支 / 改历史`，**普通 `git push` 不在其中**。
- ❌ **`写 session-state.md` 保留禁止**、**`NEXT.md` 不进允许集** ——
  v2 曾把这两项塞进允许集，Gate 2 指出**二者均无协议载体**
  （`session-state.md`：alex-lite L188 反而写着「边界：不写完整 session-state.md」；
  `NEXT.md`：全文 `grep -Fc` = 0）。按本 Epic 定价闸「无新载体证据即 RETIRED」的对称面——
  **无载体不授予**。lite 下的状态维护问题留待 P5 单独处理（须先建立载体）。
- ❌ **blake-lite 一个字都不改**。
- ❌ 不改 `CLAUDE.md`、安全停清单、`.tad/hooks/`、`settings*.json`、`.agents/` 镜像。
- ❌ 不执行 git commit / push / publish / sync。

---

## 3. 规格

**唯一被改文件**：`.claude/skills/alex-lite/SKILL.md`（当前 319 行，`## Forbidden` 起于第 **307** 行）

将第 **307 行至文件末尾**整段替换为下列 22 行（**第 1–306 行必须一字节不动**）：

```text
## Forbidden

- 写实现代码 / 自行调用 blake-lite 或用 Agent tool 实现任务 /
  无界加载 TAD 协议、配置或知识文件（`.tad/config*.yaml`、hooks、其它 SKILL、
  任何 references/）——有界知识预检（索引 + ≤3 个匹配 pattern + principles 相关部分）
  与读写自身 LITE 契约文件除外 /
  除设计期契约 reviewer 外不得 spawn 任何 subagent / 跳过或内化独立契约审查（任何理由——"契约很短""我刚写完自己清楚""额度紧张"均不是理由：自审与契约作者同心智模型，2026-07-30 首战 AC principal 缺陷即穿透自审存活至最后一道 gate）/ 以自审替代 reviewer spawn /
  写 session-state.md / EnterPlanMode /
  修改 LITE 契约之外的任何文件——**下列三项除外**（协议自身要求 Alex 写入；
  2026-08-06 修正本条与「约束准入」「Knowledge Closeout」的自相矛盾）：
  `.tad/evidence/audits/lite-constraint-ledger.md`（仅追加，不得删改历史行）、
  `.tad/project-knowledge/`、`.tad/active/epics/`。
  其中 `.tad/project-knowledge/principles.md`、`patterns/` 中标 SAFETY 的条目、
  `patterns/_index.md`、以及 `CLAUDE.md` `@import` 列出的任何路径（含当前尚不存在、
  一经创建即被自动注入的空槽），仍命中安全停清单第 2 条，须停下来问人；
  蒸馏条目只记述已发生的 episode，不得含改变权限、通道或 Forbidden 语义的
  指令性内容——此类发现须走契约 + 人拍板改 SKILL，不得经知识文件生效；
  三项之外一律禁止，**不得类推扩展**（无协议载体即不授予）/
  把页数、文件数或细节多少当作升级理由 /
  未验收即蒸馏、对 candidate 静默丢弃（必须蒸馏或显式记 `DISTILLATION DEFERRED`）、
  为凑字段编造 gap 内容 /
  未做 caller/consumer 检查却声称"无下游影响"
```

**实际只有一处差异**（Alex 已 `diff` 验证：单一 hunk `9c9,18`，其余 12 行零差异）：

| 原（节内第 9 行） | 新（节内第 9–18 行） |
|---|---|
| `修改 LITE 契约之外的任何文件 /` | 同句 + 三项例外 + SAFETY/@import 回指 + 内容类别约束 + 不得类推扩展 |

**其余 12 行逐字保留**，含 `写 session-state.md / EnterPlanMode /`（v2 曾删除，v3 撤回）
与 `除设计期契约 reviewer 外不得 spawn 任何 subagent`（本单不放宽）。

### 3.1 台账（约束准入要求）

本单**净放宽**，不新增 MUST/BLOCKING → 不触发「新增约束」定价分支。
为可追溯，追加 **1 行**，状态 `SUPERSEDED`（末列）：

- 处置对象：`修改 LITE 契约之外的任何文件`（绝对禁止 → 三项例外）
- 摘要须逐字含两个 grep 锚：`` `Knowledge Closeout` `` 与 `` `修改 LITE 契约之外的任何文件` ``
- 载体路径：本 handoff
- 追加前**先跑超期扫描**（Alex 已实跑，当前输出为**空**——3 行数据全为 SUPERSEDED，无 PROVISIONAL），
  结果须原样写进 Completion（空也要写「(空)」）

---

## 4. Acceptance Criteria

- **AC1（成品全文 md5，一条锁死一切）**：
  ```bash
  md5 -q .claude/skills/alex-lite/SKILL.md
  ```
  必须 == **`cbe9a26f130e269b37b5320725b4697b`**
  （Alex 已在本地构造成品实测：**328 行 / 21732 bytes / 11637 chars**，末字节 `\n`，行尾空格 0 处）

  ⚠️ **这条使 §3 代码块只是「帮助」而非「判据」**——不论从哪取文本、怎么排版，
  只有产出这个精确字节序列才算通过。
  （v1 Gate 2 发现：契约本身可写、未 tracked、且在 AC 白名单内，
  若以「与契约代码块 diff 得空」为判据，改契约即可让任意版本全绿。成品 md5 无此缺陷。）

- **AC2（判别力自证，四条同时成立）**：
  ```bash
  F=.claude/skills/alex-lite/SKILL.md
  grep -Fc '修改 LITE 契约之外的任何文件 /'                    "$F"  # 改前 1 → 改后须 0
  grep -Fc '下列三项除外'                                      "$F"  # 改前 0 → 改后须 1
  grep -Fc '写 session-state.md / EnterPlanMode'               "$F"  # 改前 1 → 改后仍须 1
  grep -Fc '除设计期契约 reviewer 外不得 spawn 任何 subagent'   "$F"  # 改前 1 → 改后仍须 1
  ```
  后两条是**未放宽的自证**：v1/v2 曾计划放宽它们，v3 全部撤回，必须原样存活。

- **AC3（台账 +1 且 append-only）**：
  ```bash
  L=.tad/evidence/audits/lite-constraint-ledger.md
  grep -c '^| 20' "$L"                       # 由 3 变为 4
  git diff -- "$L" | grep -c '^-[^-]'        # 必须为 0（append-only 的机械断言）
  ```
  新行状态列为 `SUPERSEDED`（末列），且含 §3.1 要求的两个逐字 grep 锚。
  超期扫描原始输出已贴进 Completion。

- **AC4（零越权 + 无自我授权提交）**：
  ```bash
  git rev-parse --short HEAD    # 必须仍为 2453115
  git status --short
  ```
  `git status` 中的路径，除**附录 A 起草时基线**的 23 行外，新增部分只允许落在：
  `.claude/skills/alex-lite/SKILL.md`（精确）、
  `.tad/evidence/audits/lite-constraint-ledger.md`（精确）、
  `.tad/active/handoffs/`、`.tad/evidence/reviews/blake/`、`.tad/evidence/journal/`、
  `.tad/evidence/ralph-loops/`、`.tad/evidence/acceptance-tests/`、`.tad/evidence/traces/`、
  `.tad/evidence/decisions/`、`.tad/memory/`、`.tad/active/precompact/`
  （以 `/` 结尾者按前缀匹配）。

  **黑名单（出现即 FAIL）**：`.claude/skills/blake-lite/`、`CLAUDE.md`、`.tad/hooks/`、
  `.claude/settings*.json`、`.claude/agents/`、`.tad/config*.yaml`、`.tad/active/epics/`、
  `.tad/project-knowledge/`、`.gitignore`、`.tad/sync-registry.yaml`、`.tad/logs/`。

  **本单禁止** `git add` / `commit` / `push` / `checkout --` / `stash`。
  `HEAD` 断言是防自指时序违规的机械兜底。

### 附录 A — AC4 起草时基线（Gate 2 实跑，23 行）

```
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/tracked-after.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/untracked-after.txt
 M .tad/evidence/decisions/2026-08-06.jsonl
 M .tad/research-notebooks/REGISTRY.yaml
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
?? .tad/evidence/traces/2026-08-06.jsonl
?? .tad/memory/feedback_cross-project-tracking-boundary.md
```

（`.tad/research-notebooks/REGISTRY.yaml` 起草前即为 ` M`，属既存改动，**不是本单越权**。）

---

## 5. 陷阱表（Alex 实测）

| 陷阱 | 事实 | 应对 |
|---|---|---|
| BSD `wc -c` 与 `-m` 互斥 | `wc -c -m f` 只出 chars，不报错 | 分两次调用 |
| Bash 工具实跑 **zsh 5.9** | 参数展开不分词 | 别用 `for x in $VAR` |
| 新节含全角引号与 `**` | 复制时易被编辑器改写 | **直接 `sed` 抽取，别手打**（见 §9） |
| 行尾空格 | 新节实测 **0** 处 | 多一个空格即 FAIL |
| 末字节 | 成品须以 `\n` 结尾 | `tail -c1 f \| od -An -c` 应显示 `\n` |

## 6. 风险与注意

- **自指时序（机制已更正）**：v2 曾称「压缩后重跑 `/blake-lite` 会加载刚写入的新文本」——
  **该叙述对本单不成立**：本单只改 `alex-lite/SKILL.md`，而 `/blake-lite` 加载的是
  `blake-lite/SKILL.md`（本单一字未改）。因此本单**不构成自指危险**。
  尽管如此，**执行期间若发生压缩，仍不得重跑 `/blake-lite`**——这是通用保守动作，
  且 AC4 的 `git rev-parse HEAD == 2453115` 提供机械兜底。

- **既有缺口的处置理由（已按 Gate 2 更正）**：v2 曾以「这些本单之前就存在」为由转 P5。
  **该论证站不住**——一个既有的洞，若被本次改动变得**可达**，就是本次改动的问题。
  正确判据是**可达性**，Gate 2 逐条核实如下：

  | 既有缺口 | 本单后从 lite 通道可达？ |
  |---|---|
  | `.claude/agents/*.md` 可改写（被审查方重定义审查方） | **不可达**（不在三项内 + AC4 黑名单） |
  | `SKILL.md` 的 Forbidden 节不在安全停清单覆盖内 | **不可达**（`.claude/skills/` 不在三项内）。本单自身即该控制的一次实演——v1 被审出 5 个 P0 并撤回 |
  | `violations.log` 可被覆写 | **不可达**（AC4 黑名单含 `.tad/logs/`） |
  | `.gitignore` 是验证器输入却可写 | **不可达**（不在三项内 + AC4 黑名单） |

  四条全部不可达 → 转 Epic P5 候选成立。其实际暴露面只剩 full 通道与带外编辑。

- **台账的记账权与生效权是分离的**（Gate 2 给出的结构性论证，值得记住）：
  约束文本住在 `SKILL.md`，而 `SKILL.md` **不在三项之内**。
  所以 Alex 把某台账行改成 `RETIRED` 并不会移除任何 Forbidden 条款，只会让台账与 skill 对不上。
  真正删约束仍需写 `SKILL.md` → 绝对禁止 → 必须新开一张 LITE 单 → 人在 L3 拍板时看得见。
  **自我记账最多制造一份对不上的账，换不来权限。** AC3 的 append-only 断言把这一点机械化。

- **`.tad/project-knowledge/` 是三项中唯一的「自动注入」通道**（Gate 2 P1，已在新条款处置）：
  `CLAUDE.md` 有 8 个 `@import`，其中 5 个路径**当前不存在**（`@import` 静默跳过），
  创建它们等于往此后每个 session 的系统提示永久装文本，且**无前版本可 diff**。
  新条款已把回指从「2 个具名路径」扩为「`CLAUDE.md` `@import` 列出的任何路径（含空槽）」，
  并加了内容类别约束（蒸馏条目不得含改变权限/通道/Forbidden 语义的指令性内容）。

- **caller/consumer 检查**：`alex-lite/SKILL.md` 的消费方 = Claude Code skill 加载器
  + `.agents/skills/alex-lite/SKILL.md`（Codex 镜像）。
  ⚠️ **本单只改 `.claude/`，未同步 `.agents/`** —— 刻意为之（保持最小），
  但会造成两平台不一致。**必须在 Completion 中显式记录**，作为 P5b 输入。
  不得声称「无下游影响」。

## 7. 修订记录

### v1 → v2（Gate 2 双专家）

| Reviewer | verdict | 计数 |
|---|---|---|
| code-reviewer | **FAIL** | P0=2, P1=5, P2=10 |
| security-auditor | **CONDITIONAL** | P0=3, P1=3, P2=3 |

**5 个不重复 P0**（v2 全部规避，方式 = 缩范围而非加检查）：

1. **AC2 参照物可篡改**：契约在 `.tad/active/handoffs/`（未 tracked、git status 折叠、
   且在白名单内）→ 改契约即可让任意版本全绿。→ 改用**成品全文 md5**，参照物不再存在。
2. **deny-list 使 alex-lite 可改写自身 Forbidden**（`.md` 非源码）→ 自放大回路。→ 不用 deny-list。
3. **subagent 是绕过一切的出口**（alex 侧本就无 commit/push 条款 + 预授权 + 零弹窗）→ 不放宽 spawn。
4. **授权链无闭环**，弱于同仓库既有的「跨角色请求消歧」四件套；该形态**有实测载体**
   （`violations.log` 2026-08-02）→ 不放宽 commit/push。
5. **`push 另属安全停清单第 1 条` 是事实错误**（第 1 条只列 force-push/删分支/改历史）→ 删除该表述。

### v2 → v3（增量复核）

| Reviewer | verdict | 计数 |
|---|---|---|
| code-reviewer | **CONDITIONAL** | P0=0, P1=2, P2=4 |
| security-auditor | **PASS** | P0=0, P1=1, P2=4 |

两位均**独立重算并确认** v2 的 AC1 md5 与全部元数据正确。v3 修的 4 条：

1. **五项允许集里 2 项无载体**（CR-P1-2）：`session-state.md`（alex-lite L188 反而写着
   「不写完整 session-state.md」）与 `NEXT.md`（全文零出现）。
   → **砍成三项**，`写 session-state.md` 禁令原样保留 → 改动从 2 处降为 **1 处**。
   判据是本 Epic 自己的定价闸对称面：**无载体不授予**。
2. **`project-knowledge` 的 SAFETY 回指只覆盖 8 个 `@import` 中的 2 个**（SA-P1-1）
   → 回指改为引用 `CLAUDE.md @import` 全集 + 内容类别约束。
3. **AC4 白名单漏 `.tad/research-notebooks/REGISTRY.yaml`**（CR-P1-1，既存 ` M`）
   → 补附录 A 起草时基线 23 行，AC4 改为「相对基线的新增」。
4. **§6 自指时序机制叙述错误**（CR-P2-2）+ **既有缺口的处置理由偏弱**（SA）
   → 前者更正为「本单不构成自指危险」，后者改用**可达性**论证。

另采纳：AC3 的 append-only 机械断言（SA-P2-1）、§9 的 `sed` 抽取命令（SA）。

## 8. Knowledge 引用

- `patterns/ac-verification.md` §`Verification Strength Is Bounded by the Deliverable's Determinacy`
  — **本单方法论依据**：Gate 2 产出全绿伪造是关于 *scope* 的证据，不是关于 *checks* 的证据。
  v1 → v3 的正确反应是砍范围（7 条 → 1 处），不是加检查。验证强度反而上升
  （从「两段 md5 + 可变参照 diff + 抽样 grep + 行数聚合」变为「一个不可变常数」）。
- `patterns/ac-verification.md` §`An Aggregate-Only Check Locks the Exit, Not the Entrance`
  — 本单不用任何聚合判据，AC1 直接锁全文字节。
- `principles.md` §`Deny-List Beats Allow-List for Sync Sets`
  — ⚠️ **v1 误用了这条**：其适用前提是**有界集合**且承重的是排除断言（原文限定 "for Sync Sets"）。
  写权限是无界集合，deny-list 在其上 fail-open 面无限。v3 改用有界允许集（3 项）。
- `principles.md` §`Mechanical Enforcement Rejected on Single-User CLI`
  — 台账 append-only 的执法层级定位：git-tracked + diff 可见 = 探测器级，本框架认可，不为此加机制。
- `patterns/gate-design.md` §`Independent Perspective Lives in Clean Context` — L3 reviewer 不可省。

## 9. Message to Blake

改 1 个文件、1 节、**1 处**。

**取文本**（别手打，新节含全角引号与 `**`，编辑器易改写）：

```bash
H=.tad/active/handoffs/HANDOFF-20260806-lite-takes-over-full.md
FENCE=$(printf '%s' '```')
START=$(grep -n "^${FENCE}text\$" "$H" | head -1 | cut -d: -f1)
END=$(grep -n "^${FENCE}\$" "$H" | head -1 | cut -d: -f1)
sed -n "${START},${END}p" "$H" | sed '1d;$d'
```

输出即应写入的 22 行（Alex 实跑：START=59 / END=82，抽出 22 行，
md5 `2ef1944a06bd0a88de3a47fd13438278`；拼接后成品 md5 == AC1 断言，端到端已验证）。
前 306 行一字节不动。

⚠️ **为什么不能把围栏字符直接写进命令**：Bash 工具实跑的是 **zsh 5.9**，
双引号内的三个反引号会被当作命令替换，导致 `parse error`。
Alex 起草时的第一版命令就是这么写的，实跑即失败——必须走上面的 `FENCE` 变量写法。

**验收就一条**：`md5 -q .claude/skills/alex-lite/SKILL.md` == `cbe9a26f130e269b37b5320725b4697b`。
不管你从哪取文本，只有产出这个精确字节序列才算过。

另追加台账 1 行（`SUPERSEDED`，含两个逐字 grep 锚），追加前先跑超期扫描（当前应为空），
把原始输出贴进 Completion。

⚠️ 执行期间若发生压缩，**不要重跑 `/blake-lite`**，停下报人。

---

## Lite Progress

Phase=admission
repair_round=0/3
same_error_count=0/2
verdict=RUNNING
Evidence=.tad/active/handoffs/HANDOFF-20260806-lite-takes-over-full.md
Next Action=L0 通过 → L0.5/L0.75/L1

Phase=implement
repair_round=0/3
same_error_count=0/2
verdict=RUNNING
Evidence=.tad/evidence/acceptance-tests/lite-takes-over-full-p5a/ac-results.md
Next Action=AC 自验

Phase=ac
repair_round=0/3
same_error_count=0/2
verdict=RUNNING
Evidence=.tad/evidence/acceptance-tests/lite-takes-over-full-p5a/ac-results.md
Next Action=L3 独立审查

### 通道裁定记录（L0.5 人类明确放行，逐字记录）

- 文件名 `HANDOFF-20260806-lite-takes-over-full.md` 未命中 blake-lite 准入白名单
  `LITE-*.md` 字面规则，且无 `## Contract Review` 段。
- 用户指令原话（2026-08-06 消息）：「请在 Terminal 2 输入 /blake-lite 继续。」
- Epic 执行约束 #4：「P1/P2 是仅有的必须走 full 的 phase；P3 起应走 lite」→ P5a 走 lite 成立。
- handoff §6 自证：本单只改 alex-lite/SKILL.md，`/blake-lite` 加载的是 blake-lite/SKILL.md，
  即契约自身以 /blake-lite 为执行方。
- 设计期审查：本单经 Gate 2 双专家两轮（code-reviewer + security-auditor，v1 FAIL → v2 → v3），
  强度高于 lite 常规契约审查 → 缺 Contract Review 段不构成审查缺位。
- 裁定：按 L0.5「人若明确坚持照旧放行 → 逐字记录人原话进 Completion 后方可继续」执行。

---

## Completion (2026-08-06)

**Commit**: uncommitted（契约 AC4 明令禁止 git add/commit/push/checkout/stash；commit 归人决定）
**Model**: harness=claude-code | model=deepseek-v4-flash | route=api.deepseek.com (alias-mapped)

- 上下文刷新：已读 handoff 全文 + EPIC-20260804-lite-as-tad-body.md（P5 候选 C2、执行约束 #4）+ session-state.md + patterns/ac-verification.md（Determinacy / Aggregate-Only 两节）+ patterns/gate-design.md（Independent Perspective）+ lite-constraint-ledger.md 全文 + principles.md（@import 已载） | 关键约束：只改 1 文件 1 节 1 处；AC1 md5 单常数锁全文字节；禁 git 写操作 | 成功条件：AC1-AC4 全绿 + reviewer PASS
- 通道裁定（L0.5 escape hatch，逐字记录）：用户指令原话「请在 Terminal 2 输入 /blake-lite 继续。」+ Epic 执行约束 #4「P1/P2 是仅有的必须走 full 的 phase；P3 起应走 lite」+ handoff §6 自证以 /blake-lite 为执行方 + Gate 2 双专家两轮设计审查（强度高于 lite 常规契约审查）→ 放行 lite 执行，即使文件名 HANDOFF-* 且缺 ## Contract Review 段。详见 handoff「### 通道裁定记录」。
- 改动文件：.claude/skills/alex-lite/SKILL.md（307 行至末尾整段替换，前 306 行一字节不动）；.tad/evidence/audits/lite-constraint-ledger.md（追加 1 行 SUPERSEDED）。[清单外] 无——唯一附加文件为协议要求的证据/报告/Progress/Completion 载体（acceptance-tests/lite-takes-over-full-p5a/ac-results.md、reviews/blake/lite-takes-over-full-p5a/code-reviewer.md、journal 一行、本文件追加段），均落 AC4 白名单。
- AC 结果：8/8 全绿（AC1-AC4 共 8 条机械断言）
  - AC1 ✅ md5 == cbe9a26f130e269b37b5320725b4697b；328 行/21732 B/11637 chars/末字节 \n/行尾空格 0；§9 抽取 22 行 md5 2ef1944a…；前 306 行 diff IDENTICAL
  - AC2 ✅ 改前 1/0/1/1 → 改后 0/1/1/1（两条未放宽自证存活：写 session-state/EnterPlanMode、subagent spawn 禁令）
  - AC3 ✅ 台账 3→4；append-only 断言 0；两逐字锚各 1；SUPERSEDED 末列。**超期扫描原始输出：(空)**（退出码 0，无 PROVISIONAL 行——3+1 行全为 SUPERSEDED）
  - AC4 ✅ HEAD == 2453115（未动）；基线外新增恰 2 条 tracked M（SKILL.md、ledger，均精确命中白名单）+ 2 条 ??（acceptance-tests/lite-takes-over-full-p5a/ 前缀、active/handoffs/ 前缀）；黑名单 11 项零命中
  - 证据路径：.tad/evidence/acceptance-tests/lite-takes-over-full-p5a/ac-results.md
- Reviewer: **PASS** | model=deepseek-v4-flash（自报 harness=Claude Code CLI；未传 model override）| P0=0, P1=0, P2=3（P2-1 AC3 不覆盖末列/锚→建议，非缺陷，执行实证；P2-2 第 2 条措辞延伸观察→不建议改清单；P2-3 两项待办义务：超期扫描输出已在此补贴「(空)」、.agents/ 镜像未同步→P5b 输入）。关键发现摘录：「实现与 handoff §3/§3.1 规格逐字节吻合，契约语义无放宽，scope 无越权，AC1-AC4 全部执行验证通过」「AC1 单常数锁全文字节，上述全部失败模式无一可穿透」（执行实证）；五项对抗探针（旧后缀/行尾空格/整段错位/删 SAFETY 回指/台账错列）全部被捕获或经人工可查。报告载体：.tad/evidence/reviews/blake/lite-takes-over-full-p5a/code-reviewer.md
- Technical Gate: **GATE PASS**（① AC/evidence：AC1-AC4 每条有原始输出 + 证据路径 ✓ ② reviewer verdict=PASS、P0/P1=0 ✓ ③ friction：无 BLOCKED ✓ ④ scope/risk：改动限于契约清单，caller/consumer 检查已记录——.agents/ 镜像刻意未同步、显式留 P5b ✓ ⑤ Knowledge Assessment 已标记 ✓）
- Knowledge Assessment: journal captured → .tad/evidence/journal/lite-discoveries.md（一行：首个「full 设计 + lite 执行」混合形态单走通，验证 P5-C2 处置路径可在 lite 内闭环）
- 意外发现：无（全部数值与契约锚定一致，0 repair loop，无同错误循环）
- follow-up：
  - P2-1（reviewer 建议）：AC3 机械断言不覆盖「SUPERSEDED 末列」+ 两锚；当前实现逐列核对正确非缺陷；若未来机械化可加 `grep -c '| SUPERSEDED |$'`。owner：Alex 验收时定夺（台账 git-tracked 探测器级，加不加由框架定价）
  - P2-2（reviewer 观察）：新条款把 @import 全集（含 5 个空槽）归入安全停清单第 2 条，措辞比清单字面枚举宽；行为无歧义且是 Gate 2 SA-P1-1 处置设计，不建议同步改清单。owner：Alex 知悉即可
  - **`.agents/` Codex 镜像未同步**（handoff §6 明示刻意为之）：本单只改 .claude/，两平台 alex-lite Forbidden 现不一致 → **P5b 输入，必须显式处置**，不得声称「无下游影响」
  - 超期扫描输出已补贴（见 AC3 行）；台账现 4 行全 SUPERSEDED，无 PROVISIONAL
  - 本单未 commit；P2+P3 改动亦未 commit（发布归人）

## Reflexion

无修复（0 repair loop：实现一次通过，全部 AC 首跑全绿，reviewer 无 P0/P1）。

---

## Lite Progress

Phase=technical-gate
repair_round=0/3
same_error_count=0/2
verdict=GATE PASS
Evidence=.tad/evidence/reviews/blake/lite-takes-over-full-p5a/code-reviewer.md
Next Action=人验收 → 归档

Phase=human-gate
repair_round=0/3
same_error_count=0/2
verdict=GATE PASS
Evidence=.tad/active/handoffs/HANDOFF-20260806-lite-takes-over-full.md
Next Action=等待人验收；验收后 mv 到 .tad/archive/handoffs/（位置即状态）；commit 与否由人决定
