---
task_type: yaml
e2e_required: no
research_required: no
---

# Handoff Document for Agent B (Blake)
## Gate Loop Circuit Breaker + Evidence Replayability + Handoff Size Gate

**Created**: 2026-08-04
**Version**: v4（Gate 2 R3 后修订 — 三轮 17 个 P0 全部处置；FR1 改为 boundary-append 基底）
**Author**: Alex (Solution Lead)
**Channel**: full TAD
**Priority**: P1
**Gate 2 Status**: ⬚ R4 PENDING（G2 已被人工放行 1 次，见 §Gate Rounds）

---

## Gate Rounds（阶段边界日志 — 只追加，不重写）

> ⚠️ 本段是本单**自身**的熔断计数，同时是 FR1 载体格式的 dogfood。
> Gate 3 的 fresh reviewer **MUST 跳过本段**（读它会产生 preview anchoring）。

<!-- GATE-ROUNDS-BEGIN -->
schema: boundary-append v1
G{n} = 表格中该 Gate 下 verdict ∉ {PASS, RUNNING, HUMAN-GRANTED-CONTINUE} 的行数
TOTAL_ROUNDS = 表格中 verdict ∉ {RUNNING, HUMAN-GRANTED-CONTINUE} 的行数
GRANT = verdict == HUMAN-GRANTED-CONTINUE 的行数（per-handoff，上限 2）
当前：G2=1/3 (grant#1 后)  G3=0/3  G4=0/3  TOTAL_ROUNDS=4  GRANT=1/2
⚠️ 本块的公式已被 R4 双方独立证伪（见 §8）——上面这些数字与公式对不上，
   本身就是 P0-1 的活证据。修法待定。
<!-- GATE-ROUNDS-END -->

| 时间 | Gate | verdict | 类别 | 记录者 |
|------|------|---------|------|--------|
| 2026-08-04T15:30Z | G2 | FAIL | reviewer P0×6 | Alex |
| 2026-08-04T17:10Z | G2 | FAIL | reviewer P0×6 | Alex |
| 2026-08-04T19:40Z | G2 | FAIL | reviewer P0×5 | Alex |
| 2026-08-04T19:46Z | ALL | HUMAN-GRANTED-CONTINUE | 人原话逐字："行使 grant，直接开第 4 轮"；hook 交叉键 ts=2026-08-04T19:46:32Z slug=gate-loop-circuit-breaker | Alex |
| 2026-08-04T20:30Z | G2 | FAIL | reviewer P0×6（code-reviewer FAIL / bug-hunter FAIL） | Alex |

---

## 1. Task Overview

### 1.1 What We're Building

给 TAD **full 通道**补三道闸：

| FR | 名称 | 一句话 |
|----|------|--------|
| FR1 | **无进展熔断** | 阶段边界日志 + 派生计数；任一 Gate 连续 3 轮未过、或 TOTAL_ROUNDS ≥ 6 → 停下交人 |
| FR2 | **证据可重放性** | Gate 3 检测不可重放证据 → 首次 WARN，同一单第 2 次 → BLOCKING |
| FR3 | **Handoff 体量闸** | 生成时超 80KB 或 20 AC → 提示拆分/降 Lite（不硬拒） |

### 1.2 Why — 事故实证

2026-08-02～04，阅读助手（**Codex** + full TAD）在 Gate 3 上原地空转七轮：

```
000b34d 09:24 | 7bfd325 09:41 | 6f345e8 09:46 | 83f6c88 09:50
b3cf2a4 12:27 | b617ce4 12:34 | 8e3b504 12:37     ← 全部 474+/474-
```

跨项目实测：阅读助手 **13/42 = 31%** 的 commit 是证据重采；voice-studio 2/111；其余 27 个项目为 0。

**三个根因 → 三个 FR：**

1. **循环任务从未进入 Ralph Loop 状态机**（→ FR1）
   ⚠️ **证据更正（v3 起）**：v1/v2 曾引用 `consecutive_same_error: 0` 论证「error-shaped 计数器归零」——**该断言错误**。那份 state 属于 `TASK-20260803-003`（另一个成功任务）。实测 `ls ralph-loops/` 仅此一个文件；真正循环 7 轮的 `reader-voice-companion` **根本没有 state 文件**。
   **修正后的根因**：不存在任何计数器。

2. **证据不可重放**（→ FR2）。证据 JSON 含随机 `request_id`/`database_generation`/`collected_at`/`commit`，叠加 `max_age_minutes: 15` 新鲜度策略 → 改一行就全量重采 → 每字节都变 → reviewer 无法 diff 只能重读全文。`fadd18f` 只改 `verify-scope.py` 一行，下一条就重采 474 行。

3. **契约体量爆炸**（→ FR3）。出事那张 = 107,650 字节 / 27 AC，5 名 reviewer 各读全文。

### 1.3 ⚠️ Gate 2 三轮暴露的设计基底问题（v4 的核心修订）

**R3-A：FR1 前三版都数不到它自己引用的那次事故。**

| 事实 | 后果 |
|---|---|
| 循环任务无 ralph state，状态机从未启用 | Layer 2 `on_failure` 整个不执行 → 主写点死 |
| 那 7 轮全部发生在 Gate 3 判定之前 | 从未进入 `gate/SKILL.md` Gate 3 段 → v3 的幂等对账兜底也死 |

v1 挂 Gate 3 段（被打掉）→ v2 挪 `on_failure`（被打掉）→ v3 加幂等对账（兜底点还是 Gate 段，仍被打掉）。**三版都在同一条链上找落点，而事故不走这条链。**

**根因：没有真正移植 lite。** 实测 `blake-lite/SKILL.md` L160–166 逐字：

```
在 LITE handoff 内追加 `## Lite Progress` 段，只在阶段边界更新：
admission（准入后）、implement（实现后）、ac（AC 自验后）、
review（独立审查后）、technical-gate（技术门后）、human-gate（人工门后）。
每个边界先追加 Progress，再进入下一阶段。
```

lite 的写入触发器是**阶段边界枚举**，覆盖整条生命周期，**与成败无关**（`verdict=RUNNING` 也写）。前三版移植的是**计数器的样子**（`repair_round=0/3`），不是**让计数器可靠的那个机制**（boundary-append）。

**v4 的基底改为 boundary-append**（§3.1.2）。三层可达性保障：
- (i) **阶段边界枚举**写入，与成败无关；
- (ii) **每次回复前自检**级的兜底补记（`compact_recovery_self_check` 是 blake 全文件唯一的"每回复"级指令）；
- (iii) **所有计数皆为派生量** —— 没有任何"计数器数字"需要被信任，只有"表格行是否追加"这一个单调动作需要被信任。

**R3-B：v3 自创的「跨信道佐证」会污染项目唯一的机械决策信道。**

v3 要求 grant 的人原话「同时写入 `.tad/evidence/decisions/*.jsonl`」。实测该文件是 **`askuser-capture.sh`（PostToolUse hook）独占的机械日志**，`.claude/settings.json` 与 `.codex/hooks.json` 双侧注册；其 NFR3 隐私边界逐字：

```bash
if [ "$IS_OTHER" = true ]; then SELECTION="<other>"; fi   # NOT the user's free-text
```

两个分支都坏：人真说了原话 → jsonl 记 `<other>` → 「两处不一致」永真 → grant 永远非法 → **R1 的硬死锁复活**；人只点选项 → `selection` 是 **agent 自己写的 label** → 比对 agent 文本 vs agent 文本 → **伪造成本增量 0**。二阶后果更糟：教 agent 手写 hook 独占日志 → 该信道对所有下游用途（审计、蒸馏）一次性失信。且 Codex 走「编号纯文本 + STOP」不调工具 → hook 永不匹配 → v3 的 B8 会把 Codex 上的 3/3 变成**永久砖化**。

**v4 改为读侧断言**（§3.1.5）：agent **禁止写**该目录；grant 合法性由 hook 落盘行的存在证明。**本单自身已实证该修法可行**——本次 grant 的 hook 行 `ts=2026-08-04T19:46:32Z slug=gate-loop-circuit-breaker`，由 hook 独立写入，Alex 未触碰该文件。

### 1.4 Intent

不是让 Gate 更严——是让 Gate **在磨不动的时候停下来问人**。事故的真 blocker 是「人去装一下扩展、点一下」，三个半小时却花在自动化证据上打转（对应 principles.md「AI/Human Judgment Domain Awareness」）。

---

## 2. Grounding（Alex 逐条实测；R3 两位专家独立复核通过）

| # | 文件 | 行 | 逐字 |
|---|------|-----|------|
| G1 | `blake/SKILL.md` | 958–962 | Layer 2 `on_failure`（内容 959–961）→ `on_success` 962。⚠️ **L910–915 是 Layer 1 同名块，不得误改** |
| G2 | `blake/SKILL.md` | 998–999 | `  circuit_breaker:` / `    trigger: "consecutive_same_error >= 3"` |
| G3 | `blake/SKILL.md` | 1207 | `mandatory:`（唯一顶格；块尾 L1220，下一顶格 key L1228 `execution_checklist:`） |
| G4 | `blake/SKILL.md` | 1067–1068 | `    compact_recovery_self_check: |` / `      ⚠️ 每次回复前自检：…` ← **全文件唯一「每回复」级指令，v4 的可达性兜底落点** |
| G5 | `blake/SKILL.md` | 802 | `# NOTE: When worktree active, ALL steps run INSIDE .worktrees/tad-{task-id}/ directory.` |
| G6 | `blake/SKILL.md` | 920 / 1759 / 2086 | 三处 `max 5 rounds`（L2086 在「Ralph Loop Rules」速查表，是**独立行为指令**） |
| G7 | `alex/SKILL.md` | 341 | `  - STEP 3.7: Session State Check`；**全文无 `compact_recovery_self_check`**（实测 0） |
| G8 | `handoff-creation-protocol.md` | 136–145 | `step1: Draft Creation`，`content:` 清单在 L140；下一个 `^    step1` 是 L185 `step1_ac_generation` |
| G9 | `handoff-creation-protocol.md` | 259 / 268 | `step1b: Frontmatter Validation` / `step1c: Grounding Pass` |
| G10 | `handoff-creation-protocol.md` | 624–628 | `step5: Gate 2 Check` / `step6: Ready for Implementation` |
| G11 | `acceptance-protocol.md` | 14–15 | `step2:` / `step3: "执行 Gate 4 v2: 业务验收"` |
| G12 | `gate/SKILL.md` | 78 / 103 / **409** / 571 / 776 / 909 | `^## Gate [0-9]:` 命中 63/78/103/571；**L409 `## Rubric Evaluation Protocol` 是独立通用段**（自述 `UNIVERSAL Gate section`，无 rubric AC 时 inert）；571 之后 `^## ` = 776（Gate 4 自身）/909/943/970 |
| G13 | `gate/SKILL.md` | 272–277 | L276 `# MECE: verified 2026-06-23 — 5 items check 5 distinct artifacts`；L277 `Critical Check (5 items):` |
| G14 | `gate-canonical-checklist.md` | 31–43 | L33 `# MECE: verified 2026-07-03 — 6 items check 6 distinct artifacts`；L43 `Why CE: … 六个独立 artifact。` |
| G15 | `blake-lite/SKILL.md` | 160–166 / 282–291 | boundary-append 枚举（**v4 的参照基底**）/ Lite Repair Loop。⚠️ **只读，不得修改**。注意：lite **无 grant 通道**（到顶即终态） |
| G16 | `askuser-capture.sh` + `settings.json` L74–79 + `.codex/hooks.json` L21–24 | — | decisions jsonl 是 **hook 独占**；NFR3 抹除 free-text；Codex 侧 matcher 永不匹配 |

**结构事实**：canonical-first 纪律（`gate/SKILL.md` 是 canonical 的 inline 镜像，注释明写「Edit canonical FIRST」）｜既存 MECE drift（canonical 6 / 镜像 5，非本单引入，**不得顺手修正**）｜`.tad/active/handoffs/` **未被 git 跟踪**（worktree 内不存在）｜镜像单向 `release-verify.sh parity --fix .`，**不得直接编辑 `.agents/`**｜新增全是约束规则，**必须留 SKILL body**｜三个 SKILL 的 front matter 极小，改动全在 **body 内嵌 YAML 块**｜`ruby -ryaml` 可用，**`python3 -c 'import yaml'` 失败（无 PyYAML）**。

---

## 3. Design

### 3.1 FR1 — 无进展熔断（boundary-append 基底）

#### 3.1.1 人已拍板（不得自行更改）

| 决策 | 取值 |
|---|---|
| 无进展口径 | **严格计数**：一轮结束 Gate 未 PASS 就计一行，不看 finding 数、不听解释 |
| 阈值 N | **3**（2026-08-04 复核维持；实测 14 个健康任务中 2 个打到 3 轮，知情后仍选 3）→ 同步改掉 blake 三处 `max 5 rounds`（改动 1b） |
| 熔断动作 | **停下来交给人** |
| 覆盖 | Gate 2 + 3 + 4 全盖 |
| grant | **上限 2，per-handoff**；必须经真实人类回合 |

#### 3.1.2 ⚠️ 载体：阶段边界追加（v4 基底，替换 v1–v3 的「失败边写点」）

**写入触发器 = 阶段边界枚举，与成败无关**（照抄 lite G15）：

| 边界 | 谁写 | 典型 verdict |
|---|---|---|
| `design`（handoff 草稿写盘后） | Alex | RUNNING |
| `review-batch`（每批专家评审结束） | Alex | PASS / FAIL |
| `gate2` | Alex | PASS / FAIL |
| `implement`（实现阶段结束） | Blake | RUNNING |
| `ac`（AC 自验结束） | Blake | PASS / FAIL |
| `layer2`（每批 reviewer 结束） | Blake | PASS / FAIL |
| `gate3` | Blake | PASS / FAIL / PARTIAL |
| `gate4` | Alex | PASS / FAIL / PARTIAL |

**每个边界先追加一行，再进入下一阶段。**

**在途行协议**（替换 v3 的 attempt-id 幂等对账 —— R3 安全 P0-2：时间戳与 verdict 两个分量都在 agent 手里，保守派生 → 零计数逃逸；两条路径派生时刻不同 → 必然双计数，把 R1 P0-4 请了回来）：

```
进入一个边界「之前」：追加一行，verdict = RUNNING
该边界结束后：就地把该行 verdict 由 RUNNING 改为终态
  —— 这是表格中唯一允许的原地修改，且只能 RUNNING→终态，不得反向、不得改其他列
若进入边界时该 Gate 已存在尾部 RUNNING 行 → 只填 verdict，不新增行
```

轮次由**行数**派生（位置派生，agent 无自由度）；「本轮是否已记」变成「是否存在尾部 RUNNING 行」这个**可观测的文件状态**，而非需要 agent 诚实派生的字符串。双计数与零计数同时结构性消失。

**⚠️ 可达性兜底（改动 1c）**：`blake/SKILL.md` 的 `compact_recovery_self_check`（G4，L1067）是全文件唯一的「每次回复前」级指令。追加第二问：

```
⚠️ 每次回复前自检（第 2 问）：自上一次写 ## Gate Rounds 以来，
我是否又完成了一次「改动 → 重跑验证 → 仍未过」的完整往返？
是 → 先补记一行（verdict 可为 RUNNING），再继续本回合。
```

这是唯一**不依赖 Ralph Loop 是否启用、也不依赖是否进入 Gate 段**的写入路径，直接对治 §1.3 R3-A。

#### 3.1.3 所有计数皆为派生量

```
G{n}         = 表格中该 Gate 下 verdict ∉ {PASS, RUNNING, HUMAN-GRANTED-CONTINUE} 的行数
TOTAL_ROUNDS = 表格中 verdict ∉ {RUNNING, HUMAN-GRANTED-CONTINUE} 的行数
GRANT        = verdict == HUMAN-GRANTED-CONTINUE 的行数（per-handoff）
```

- **PASS 不归零**（同一 handoff 内单调不减）。理由：v2 的「PASS 归零」被两位专家从两侧打掉——① 2/3 时把 PARTIAL 写成 PASS 是最省事的清零路，撞 `honest_partial_protocol`；② G4 打回 → G3 因上次 PASS 归零 → 永远累计不到 3。
- **⚠️ 跨 Gate 兜底闸**：`TOTAL_ROUNDS >= 6` → 无论各 Gate 计数如何，输出熔断报告并停止。
  理由（R3 安全 P1-5）：路由表按**协议位置**决定记哪个 Gate，而「我在哪个协议位置」是 agent 自述的。同一批未解决 finding 重新框成「Gate 4 前置项」→ 记 G4（0/3）；再框成「契约不清回 Gate 2」→ 记 G2。三个 Gate 各 3 轮 = 9 轮，叠加 grant = 27 轮，**比事故本身（7 轮）大 4 倍，且全程不需要说谎**。TOTAL_ROUNDS 天然不区分 Gate，一行文本把 27 压回 6。

#### 3.1.4 骨架

（示例缩进 2 格，避免 `^## ` grep 误判为顶级段落）

```markdown
  ## Gate Rounds（阶段边界日志 — 只追加，不重写）

  <!-- GATE-ROUNDS-BEGIN -->
  schema: boundary-append v1
  G{n} / TOTAL_ROUNDS / GRANT 皆为派生量（定义见 gate/SKILL.md）
  当前：G2=0/3  G3=0/3  G4=0/3  TOTAL_ROUNDS=0  GRANT=0/2
  <!-- GATE-ROUNDS-END -->

  | 时间 | Gate | verdict | 类别 | 记录者 |
  |------|------|---------|------|--------|
```

**「类别」列只写机械类别**（`AC5 FAIL` / `reviewer P0×2` / `evidence missing` / `human evidence pending`），不写细节 —— 防 preview anchoring（principles.md 已点名的已知危害）。仅此不足，故改动 7 第 5 项要求 reviewer **整段跳过**。

**写入纪律**：写前必须重新 Read 该段。⚠️ **拆行/追加本身不消除竞态**——真实收益是「追加是单调的，比『读旧值+1 写回』少一个可被覆盖的中间态」。唯一保护是写前重读（纯自律，符合 L1「Mechanical Enforcement Rejected on Single-User CLI」）。

**worktree 路径纪律**：`.tad/active/handoffs/` 未被 git 跟踪，worktree 内不存在。路径**永远解析主工作树绝对路径**，不随 cwd 改变。

#### 3.1.5 熔断报告与人工授权续跑

**熔断报告模板**（必须逐字写入 `gate/SKILL.md` 一处，三 Gate 共享）：

```
⚠️ NO-PROGRESS CIRCUIT BREAKER — {Gate {N} 连续 3 轮未通过 | TOTAL_ROUNDS 已达 6（跨 Gate 兜底）}

已烧轮次：{G{n}}/3      本 handoff 总轮次：{TOTAL_ROUNDS}      已放行：{GRANT}/2
每轮未过类别：
  轮 1: {类别}   轮 2: {类别}   轮 3: {类别}
错是否重样：{是 — 疑似同一根因未解 | 否 — 疑似契约/验证器问题或人域 blocker}

以下判断属人域，给选项不给结论：
  ① 契约问题（回 Alex 重新拆单）② 验证器/证据管道问题 ③ 环境问题
  ④ 人域 blocker（人执行 X 后才能继续）⑤ 都不是
各选项的支持证据：{逐条列出机械事实，不下结论}

⛔ 已停止。等待人裁定。不得自行开始下一轮。
```

⚠️ 「判断/建议」改为 shortlist 而非 agent 结论（R3 安全 P2-5 + principles.md「AI/Human Judgment Domain Awareness」：给人选择题不给验证题，否则制造 rubber stamp）。agent 只提供「错是否重样」这个机械事实。

**⚠️ HUMAN-GRANTED CONTINUE（唯一合法出口）**

lite **没有**这个通道（G15：到顶即终态，回 /alex-lite 改契约）。故 grant 是本单**新发明**，§1.5 的「不是发明是移植」在此不成立，按新机制标准加约束：

```
grant 合法的充要条件（全部满足）：
1. 经 AskUserQuestion 取得；无该工具的 harness → 输出编号选项后停止本回合，
   等人的下一条输入（按各 role-SKILL「平台绑定交互决策」条款）。
   MUST NOT 在没有收到人类消息的同一回合内自行写入 grant 行。
2. 【读侧断言】`.tad/evidence/decisions/{date}.jsonl` 中存在一条 **hook 落盘**的记录：
   slug == 本 handoff slug、ts 在本回合窗口内。grant 行 MUST 引用该 ts 作为交叉键。
   ⚠️ agent MUST NOT 以任何方式写入该目录（mandatory: no_decision_log_write）。
   人原话**不写入** jsonl（不得破坏 NFR3 隐私边界）：表格记原话，jsonl 证明
   「这一回合确实发生过一次真实的 AskUserQuestion 往返」。
3. 【无 hook 的 harness（如 Codex）】hook 不落盘 → 佐证改为：表格记录人原话 +
   逐字标注 `evidence-channel: transcript-only (no hook)`，并在 Completion 中列为
   `UNVERIFIED-BY-EXECUTION`。⚠️ **不得**因缺 jsonl 而硬停（否则 Codex 上 3/3 = 永久砖化）。
4. GRANT 上限 2，**per-handoff**（不是 per-Gate）。grant 行的 Gate 列写 `ALL`。
   grant#3 请求 = 硬停止，只能回 Alex 重新拆单（对齐 lite）。
5. grant 使各 Gate 计数归零，但 **TOTAL_ROUNDS 不减**（grant 行不计入）。
   grant#2 起，熔断报告首行必须打印「⚠️ 本单已被人工放行 {n} 次 —— 强烈建议回 Alex 重新拆单」。
```

#### 3.1.6 防重置（四处，缺一不可）

- **(a) 违规条款** — `mandatory:` 五条（改动 3）
- **(b) 压缩恢复条款** — blake 挂 `compact_recovery_self_check`（**改动 1c**）；alex 侧无对应块，**新建**对称块（**改动 8**）
- **(c) 单调性** — 表格行数只增；RUNNING→终态是唯一原地修改。规则逐字写入 `gate/SKILL.md`（改动 7）**与** blake `on_failure` 相邻处（**改动 1c**）
- **(d) worktree 路径纪律** — 改动 9

#### 3.1.7 逐点改动

**改动 1 — `blake/SKILL.md` L958–961 Layer 2 `on_failure`**（⚠️ L910 是 Layer 1，不得误改）

```yaml
        on_failure:
          - "Increment layer2_rounds"
          - "Append a boundary row (layer2) to the MAIN-WORKTREE handoff's ## Gate Rounds with a MECHANICAL category only; the section is reviewer-invisible — BLOCKING"
          - "Monotonic guard: rows are append-only; the ONLY in-place edit allowed is RUNNING→terminal verdict. 新值 < 旧值 或反向改写 → 停止并报告"
          - "If derived G3 reaches 3/3 OR TOTAL_ROUNDS reaches 6 → emit the NO-PROGRESS CIRCUIT BREAKER report and STOP"
          - "Check escalation threshold (same category 3x → escalate to Alex)"
          - "If G3 < 3/3: Fix issues and restart from Layer 1"
```

⚠️ **回边必须条件化**：v2 的写法是「无条件回边 + 跨两项的否定」，LLM 逐条执行时否定绑定极脆——正是本单要防的失效。lite L277 把回边**本身**条件化，v4 与之对齐。

**改动 1b — `blake/SKILL.md` L920 / L1759 / L2086 三处 `max 5 rounds` 同步**

L2086 在速查表里，是**独立行为指令**，与新熔断器逐字对立。三处改为：
```
920:  description: "Expert Review Loop (max 3 rounds — no-progress breaker, see ## Gate Rounds)"
1759: layer2: "Expert Review (max 3 rounds — no-progress breaker; legacy escalation @ 3 same-category)"
2086: - **Layer 2 fail?** → Fix, restart from Layer 1 —— 仅当 G3 < 3/3（no-progress breaker）
```

**改动 1c — `blake/SKILL.md` `compact_recovery_self_check`（G4，L1067）**（v4 新增，补 R3 spec-compliance P0-2 指出的缺口）

块内追加：§3.1.2 的「每次回复前自检第 2 问」全文 + `不得重置 ## Gate Rounds 计数逃避熔断`。

**改动 2 — `blake/SKILL.md` L998–999 circuit_breaker**（原 trigger 行逐字保留）
```yaml
    trigger: "consecutive_same_error >= 3"
    trigger_no_progress: "handoff ## Gate Rounds 派生 G3 >= 3 或 TOTAL_ROUNDS >= 6（严格计数，与错是否相同无关）"
```

**改动 3 — `blake/SKILL.md` `mandatory:` 块追加五条**
```yaml
  no_progress_breaker: "MUST stop and escalate to human when derived G{n} reaches 3 or TOTAL_ROUNDS reaches 6 — 严格计数，不看错是否相同"
  no_counter_reset: "MUST NOT reset ## Gate Rounds counters to evade the circuit breaker (含压缩/中断恢复后) — 唯一例外是满足 §3.1.5 五项条件的 HUMAN-GRANTED-CONTINUE 行"
  no_verdict_upgrade: "一次边界判定的 verdict 一经写入 ## Gate Rounds 即为终态。MUST NOT 改写已记录的 verdict（RUNNING→终态 除外）。判定有争议 → 新增一行，不得改旧行。⚠️ 计数为 2/3 时判 PASS，MUST 在 Completion 单列一节说明依据并注明『本判定发生在熔断前一轮』——不构成禁止，构成留痕"
  no_gate_reattribution: "MUST NOT 通过把同一批未解决 finding 重新归类到另一个 Gate 来获得新的 3 轮预算。任一 Gate 达 3/3 后，其未解决 finding 在本 handoff 内 MUST 继续记在原 Gate，除非有 HUMAN-GRANTED-CONTINUE 行显式改判归属"
  no_decision_log_write: "MUST NOT 以任何方式写入 .tad/evidence/decisions/ —— 该目录是 askuser-capture.sh hook 独占的机械日志，agent 写入会使其对所有下游用途失信"
```

⚠️ `no_verdict_upgrade` 由 v3 的**意图限定**（`in order to …`，agent 自陈动机即可豁免）改为**状态限定**（可外部判定）。

**改动 4 — `handoff-creation-protocol.md` step5「Gate 2 Check」（G10）**：判定后追加 review-batch / gate2 边界行；派生 G2 达 3 或 TOTAL_ROUNDS 达 6 → 熔断报告并停止。

**改动 5 — `handoff-creation-protocol.md` step1 的 `content:` 清单（G8，L140）**：追加一项 `"## Gate Rounds 段骨架（MANDATORY — 含 GATE-ROUNDS-BEGIN/END、schema 行、四个派生量定义、表头）"`。⚠️ 必须在 **step1**（Gate 2 轮次发生在 step2–step5，载体须先于它们存在）。

**改动 6 — `acceptance-protocol.md`（G11）**：step2 前读 `## Gate Rounds`，G4≥3 或 TOTAL_ROUNDS≥6 → 熔断报告不进 step3；step3 后追加 gate4 边界行。

**改动 7 — `gate/SKILL.md` Gate 2/3/4 三段（G12）**，各加「⚠️ NO-PROGRESS COUNTER（BLOCKING）」**五项**：
1. 进入时读主工作树 handoff 的 `## Gate Rounds`，派生计数达阈值 → 熔断报告并停止；
2. **本段追加 gate{n} 边界行**（在途行协议：先 RUNNING、判定后填终态）；若已存在尾部 RUNNING 行则只填 verdict，不新增；
3. 单调性：只追加；唯一原地修改是 RUNNING→终态；反向或改其他列 → 停止并报告；
4. 路径永远解析主工作树绝对路径；
5. **reviewer 可见性**：
   ```
   Gate 3 的 fresh reviewer 在阅读 handoff 时 MUST 跳过 `## Gate Rounds` 段
   （BEGIN/END 块与其后的表格）：该段是熔断计数，不是需求；读它会产生
   preview anchoring，使后几轮 finding 趋同于前几轮，污染熔断报告
   「错是否重样」这一核心诊断栏。
   ```

另在 `gate/SKILL.md` **一处**逐字写入 §3.1.5 的熔断报告模板与 grant 五项条件、以及三个派生量定义。
⚠️ 模板中的 `## Gate Rounds` 示例必须**缩进**（代码围栏挡不住 `^## ` 的 grep）。
⚠️ 引用「平台绑定交互决策」时必须逐字标注宿主文件（该 clause 在 `gate/SKILL.md` 中不存在，实测 0 命中；11 个 skill 各有副本）。

**改动 8 — `alex/SKILL.md` STEP 3.7 之后（G7）新建**对称块：
```yaml
    compact_recovery_self_check: |
      ⚠️ 每次回复前自检：我知道当前工作模式 + 正在处理的 handoff/草稿吗？
      压缩/中断后：先读 handoff 的 ## Gate Rounds 段，从记录的行继续——
      不得重置计数逃避熔断。
```

**改动 9 — `blake/SKILL.md` L802 NOTE 相邻处（G5）**：`## Gate Rounds` 的路径例外——永远解析主工作树绝对路径。

### 3.2 FR2 — 证据可重放性

**强度**：先烟雾报警，同一单第 2 次 BLOCKING（遵循 L1「Mechanical Enforcement Rejected on Single-User CLI」）。

**两级判定**（v1 的纯启发式测的是「改动幅度」不是「确定性」；误报：minified 单行 JSON 恒 100%、schema 升级、换 formatter、golden 有意重生成、首次从空重建；漏报：2500 行里只有 `collected_at`+3 个 `request_id` 变 = 0.16% 却闭环成立）：

```
(1) 首选（精确）：若 handoff 的 Required Evidence Manifest 为该证据声明了重生成命令
    → 在 scratch 连跑两次并 cmp。非 0 diff = 命中（不确定性已证实）。
(2) 退回（启发式，仅当无可重跑命令时）：
    改动比 = (ins+del) / (2 × 文件总行数) > 50% 且 |ins-del| / max(ins,del) <= 0.10
```

**WARN 文案**（首次，不拦）：
```
⚠️ EVIDENCE REPLAYABILITY WARNING
{file}: {n}+/{n}- （判据：{cmp 双跑非 0 diff | 启发式 {pct}%}）
证据可能含不确定性内容（随机 ID / 时间戳 / commit SHA），每次重跑全变。
后果：reviewer 无法 diff 只能重读全文；任何改动都触发全量重采。
建议：把不确定性字段移出证据体或固定种子，使重跑产生 0 diff。
⚠️ 同时检查：该证据是否配有 max_age / freshness 策略？
   不可重放 + 新鲜度过期是同一个闭环的两半，二者必须一起修。
本单已记 1 次（EVIDENCE_REPLAY_WARN=1）。同一单再次出现 → Gate 3 BLOCKING。
```

**改动 10 — `gate-canonical-checklist.md` Gate 3（G14）— 必须最先**：追加第 7 条 `- [ ] Evidence replayability (smoke alarm; BLOCKING on 2nd occurrence) — 证据重采未呈不可重放形态. Why ME: 证据管道确定性`；**同时**改 L33（`6 items`→`7 items`）**和** L43（`六个`→`七个独立 artifact`）。

**改动 11 — `gate/SKILL.md` Gate 3 镜像（G13）— canonical 之后的独立 commit**：同步该项；**同时**改 L276（`5 items`→`6 items`）**和** L277（`Critical Check (5 items):`→`(6 items):`）。⚠️ 不得顺手修正既存 drift。

**改动 12 — `gate/SKILL.md` Gate 3 新增判定块**：「⚠️ EVIDENCE REPLAYABILITY CHECK」含两级判据、容差公式、WARN 全文、`EVIDENCE_REPLAY_WARN` 读写规则（记在 `## Gate Rounds` 骨架内，单调不减）。

### 3.3 FR3 — Handoff 体量闸

**阈值 80KB 或 20 AC**（实测：出事那张 107KB/27AC；menu-snap 64KB、全屋智能 62KB、合规ai 52KB 都跑完了；其余 <40KB）。**提示，不硬拒。**

**改动 13 — `handoff-creation-protocol.md` step1b 之后、step1c 之前（G9，L266/268 之间）**

⚠️ 必须在**任何 reviewer 被 spawn 之前**：v1 挂 step6，那时 step2/step3 的专家评审已按全文付过费 → 「坚持原样」成为唯一理性选项，闸门等于不存在。

```
step1b_size_gate:
  name: "Handoff Size Gate"
  trigger: "After step1b frontmatter validation, BEFORE step1c grounding and step2 expert review"
  action: |
    自测 wc -c 与 AC 行数。超 80KB 或超 20 AC（任一）→ 向人输出：
      ⚠️ HANDOFF SIZE GATE
      本 handoff：{bytes} 字节 / {n} 个 AC（阈值 80KB / 20 AC）
      参考：Gate 2 有 min 2 名、Gate 3 有 N 名 reviewer，每名都是 fresh session 读全文，
      成本 ≈ reviewer 数 × 本文件体量 × 轮数。
      建议：① 拆成多张单或 Epic 分阶段 ② 降 Lite 通道 ③ 坚持原样
    → AskUserQuestion 三选一（无 AskUserQuestion 的 harness：编号纯文本选项 + 停下等人输入，
      按各 role-SKILL「平台绑定交互决策」条款——引用时标注宿主文件）
    人选"坚持原样" → 在 handoff §10 记录人原话后继续，不再重复提示。
```
⚠️ SAFETY-gated 调用点，必须拿到人的真实回答，不得自答。

---

## 4. 文件清单

### 4.1 修改（6 个，全在 `.claude/` 侧）

| 文件 | 改动 |
|------|------|
| `.tad/gates/gate-canonical-checklist.md` | 10（**必须最先，独立 commit**） |
| `.claude/skills/gate/SKILL.md` | 7、11、12 |
| `.claude/skills/blake/SKILL.md` | 1、1b、**1c**、2、3、9 |
| `.claude/skills/alex/SKILL.md` | 8 |
| `.claude/skills/alex/references/handoff-creation-protocol.md` | 4、5、13 |
| `.claude/skills/alex/references/acceptance-protocol.md` | 6 |

### 4.2 镜像（自动）
`bash .tad/hooks/lib/release-verify.sh parity --fix .`

### 4.3 禁改（Non-Goals）

- ❌ `blake-lite/SKILL.md`、`alex-lite/SKILL.md` — 参照系，只读
- ❌ `.agents/` 下任何文件的直接编辑
- ❌ canonical vs 镜像的既存 MECE drift（各 +1，保留 drift）
- ❌ `.tad/evidence/decisions/` 的任何写入（改动 3 的 `no_decision_log_write`）
- ❌ 阅读助手项目的任何文件 — 跨项目边界（人已裁定 2026-08-03）
- ❌ **完整行**逐字保留：`trigger: "consecutive_same_error >= 3"`、`"Increment layer2_rounds"`
- ⚠️ **子串**保留（允许条件化前缀，已显式登记）：`Fix issues and restart from Layer 1`
- ⚠️ 显式登记的改动（AC19d 行集 diff 的可解释集合）：`max 5 rounds` ×3
- ❌ 任何 hook 文件、lite ESCALATION-LIST sentinel 块

---

## 6. 预注册降级分支

| # | 触发 | 处置 |
|---|------|------|
| B1 | Gate 2 段是纯 yaml 围栏（L78–102），插入形态与 3/4 不同 | 围栏内以 yaml 键插入；不可行 → 停，报告人 |
| B2 | canonical 与镜像既存 drift 导致同步冲突 | 只同步新增项，drift 原样保留并在 Completion 记录 |
| B3 | AC15 自测超阈值 | 停，报告人 — 阈值可能定错，由人裁定 |
| B4 | parity `--fix` 后仍不一致 | 停，报告人；不得手改 `.agents/` |
| B5 | `ruby -ryaml` 不可用 | ⚠️ **`python3 -c 'import yaml'` 本机实测失败（无 PyYAML），不是退路**。无 ruby → 标 `UNVERIFIED-BY-EXECUTION` 报告人 |
| B6 | worktree 内找不到主工作树 handoff | 停，报告人；不得在 worktree 内新建 |
| B7 | AC17 双臂无法构造 | 停，报告人。不得以其他 AC 全绿替代，**不得**退化为 Blake 自模拟 |
| B8 | 无 hook 的 harness 上无法取得 decisions 交叉键 | ⚠️ **不硬停**：按 §3.1.5 第 3 项走 `transcript-only` 分支 + `UNVERIFIED-BY-EXECUTION` |
| B9 | `max 5 rounds` 某处上下文表明非 Layer 2 预算 | 停，报告人；只改确属者，逐条说明 |

---

## 7. Blake 执行纪律

1. **canonical FIRST** — 改动 10 先于 11，**两个独立 commit**（AC12c 验证）。
2. **边界追加，不是失败边写点** — 前三版都栽在这里。每实现一个改动点，回看 `blake-lite/SKILL.md` L160–166 确认是**阶段边界枚举**语义；Completion 逐条列对应关系。
   ⚠️ **grant 通道在 lite 无对照**（lite 到顶即终态），比对时跳过，**不得为求等价去动 lite**。
3. **约束内容留 body**，不得抽进 references/。
4. **禁 `rg`**；Gate 3 段止于 L409 前、Gate 4 段止于 L909 前。
5. **不改 lite**；**不写 `.tad/evidence/decisions/`**。
6. **Layer 2 至少 3 名 distinct reviewer**：一名专核 full/lite 机制等价性，一名专跑 AC17（须 fresh 上下文）。
7. **本单自身遵守本单规则** —— Gate 3 若达 3/3 或 TOTAL_ROUNDS 达 6，停下交人。

---

## 8. Expert Review Status

| 轮 | Reviewer | verdict | P0 |
|---|---|---|---|
| R1 | code-reviewer / backend-architect | CONDITIONAL / **FAIL** | 6 |
| R2 | test-runner（新）/ backend-architect（复核） | **FAIL** / CONDITIONAL | 6 |
| R3 | spec-compliance-reviewer（新）/ security-auditor（新） | CONDITIONAL / **FAIL** | 5 |
| — | 人工放行 GRANT#1（见 §Gate Rounds） | — | — |
| R4 | ⬚ PENDING | — | — |

**R3 五个 P0 的 v4 处置**：

| P0 | 来源 | 处置 |
|---|---|---|
| 事故形态下两条 +1 路径**都**不触发 | 安全 P0-1 | **基底改 boundary-append**（§3.1.2）+ 改动 1c 每回复级兜底 + 所有计数派生化 + AC1(f) |
| attempt-id 由 agent 派生 → 零计数逃逸 + 必然双计数 | 安全 P0-2 | **在途行协议**（RUNNING→终态，位置派生）替换幂等对账；AC2/AC8(a) |
| 跨信道佐证会污染 hook 独占信道；Codex 上必砖化 | 安全 P0-3 | **读侧断言 + `no_decision_log_write` + transcript-only 分支**；B8 改不硬停；AC7/AC19。**本单自身已实证可行**（hook ts=19:46:32Z） |
| AC 清单不在模板规定的 §9.1，Gate 3 reviewer 读不到 | spec P0-1 | **AC 节重编号为 §9 / §9.1**，加 `PRIMARY VERIFICATION SOURCE` 标题 |
| §3.1.6(b)(c) blake 侧无改动号，AC9(d) 转引不成立 | spec P0-2 | **改动 1c 新增**；AC9(a)(c) 改为实测双落点 |

**R3 主要 P1/P2**：`no_verdict_upgrade` 意图限定→状态限定+留痕（安全 P1-4）｜`no_gate_reattribution` + **`TOTAL_ROUNDS ≥ 6` 跨 Gate 兜底闸**，27 轮压回 6（安全 P1-5）｜AC17 fixture 移出工作树 + 两臂对称 + 全部试验须报告 + (d) 改判据（安全 P1-6 + spec P1-2）｜Gate 3 段吞掉 162 行 Rubric（安全 P1-7）｜grant 作用域钉死 per-handoff（安全 P2-8）｜平台条款悬空引用需标宿主（安全 P2-9）｜§9.2 补规避/遗漏区分与证伪指标（安全 P2-10）｜AC9(a) 锁定提取命令（spec P1-1）｜AC18(c) 示例字面量更正（spec P2-1）｜AC2 改分量检查（spec P2-2）。

**AC 预算**：v3 的 AC12+AC13 合并为 AC12；腾出的格位给 AC19（decisions 零污染）。总数仍 ≤20。

**Overall**: ⬚ Gate 2 未通过 — 尚不可交付 Blake。

---

## 9. Acceptance Criteria

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

> ⚠️ 本节即 Gate 3 的 spec-compliance-reviewer 唯一验证源。
> 全部用 `grep -F`（禁 `rg`）。`grep -Fxq` 仅用于完整行；片段用 `-Fq`。`comm` 前 `LC_ALL=C sort`。
> Gate 段分割：起始 `^## Gate [0-9]:`；**Gate 3 段止于 L409 前一行、Gate 4 段止于 L909 前一行**（见 AC2）。

**AC0 — 基线**：实现前记录 pre-edit commit SHA 到 `.tad/evidence/acceptance-tests/gate-loop-circuit-breaker/baseline.md`。

**AC1 — 边界写入 + 回边条件化 + 速查表同步（核心）**：
- (a) `blake/SKILL.md` 命中 `Append a boundary row (layer2)`，且**行号落在 Layer 2 块内**。
  ⚠️ 行号锚定，**不得用 sed range**（`^        on_failure:` 两处，range 会拼接两块，插进 Layer 1 也假 PASS）：
  `ln=$(grep -nF 'Append a boundary row (layer2)' <f>|cut -d: -f1)`，断言落在含 `Increment layer2_rounds` 的行与其后首个 `^        on_success:` 之间（实测 959→962）；
  **负向断言**：不得落在含 `Increment layer1_retries` 的行与其后首个 `^        on_success:` 之间（实测 911→915）
- (b) `handoff-creation-protocol.md` step5 区间（`^    step5:`→`^    step6:`）内命中 `gate2` 边界写入
- (c) `acceptance-protocol.md` 命中 `gate4` 边界写入
- (d) 完整行存活：`grep -Fq '"Increment layer2_rounds"'`、`grep -Fq 'trigger: "consecutive_same_error >= 3"'`；子串存活：`grep -Fq 'Fix issues and restart from Layer 1'`（**不含**前导引号）
- (e) `grep -Fq 'If G3 < 3/3: Fix issues and restart from Layer 1'` 且 `grep -cF 'max 5 rounds'` == **0**（实测 baseline=3）且 L2086 项命中 `仅当 G3 < 3/3`
- (f) **可达性兜底**：`blake/SKILL.md` 的 `compact_recovery_self_check` 块内命中 `每次回复前自检（第 2 问）` 与 `补记一行`
  ⚠️ 锁定提取（v3 的「下一个同缩进 key」实测会拉到 L1102，跨 3 个无关小节）：
  `awk '/^    compact_recovery_self_check: \|/{s=1;print;next} s&&/^  [A-Za-z#]/{exit} s' <f>`

**AC2 — 三 Gate 五项 + 分段边界**：`gate/SKILL.md` 切出 Gate 2/3/4，**每段各自**命中 `NO-PROGRESS COUNTER`、`边界行`、`RUNNING`。
⚠️ **Gate 3 段 = 103–408**（止于 `^## Rubric Evaluation Protocol` 前一行，实测 L409）。不得延伸到 571——会吞掉 162 行 Rubric 通用段（占 35%），且该段在无 rubric AC 时 inert，写进去 `/gate` 读不到。
⚠️ **Gate 4 段 = 571–908**（止于 `^## Gate 4 — Rubric-Based` 前一行，实测 L909）。不得用「其后第一个 `^## `」——那是 L776 `## ⚠️ Gate 4 Subagent Requirement`，是 Gate 4 自身内容，会腰斩。
另：命中改动 7 第 5 项（**分量检查**：`跳过` + `preview anchoring` + `` `## Gate Rounds` `` 三者均命中，非整句精确匹配）。
**判别性**：只加一段 FAIL；某段写了非边界协议的计数指令 FAIL。

**AC3 — circuit_breaker 双 trigger**：同时命中 `trigger: "consecutive_same_error >= 3"`（`grep -Fxq` 含前导空格）与 `trigger_no_progress:`；后者内容含 `TOTAL_ROUNDS >= 6`。

**AC4 — mandatory 五条款**：`sed -n '/^mandatory:/,/^execution_checklist:/p' .claude/skills/blake/SKILL.md`（实测精确落在 1207–1228）区间内命中 `no_progress_breaker:`、`no_counter_reset:`、`no_verdict_upgrade:`、`no_gate_reattribution:`、`no_decision_log_write:` 五个 key；且 `no_verdict_upgrade` 值命中 `即为终态` 与 `本判定发生在熔断前一轮`（**状态限定**，非 `in order to` 意图限定）。

**AC5 — 载体骨架在 step1 的 `content:` 清单内**：命中 `GATE-ROUNDS-BEGIN` 的行落在 `^      content:`（L140）到下一个 `^    step1`（L185）之间（实测精确排除 step1a/step1b）。
同时验证骨架含 `schema: boundary-append v1`、三个派生量定义、表头 `| 时间 | Gate | verdict |`；且**不得**出现 `TOTAL_ROUNDS=0` 之外的存储式计数写法。
**判别性**：写在 step6 / step1a / step1_ac_generation 均 FAIL。

**AC6 — 熔断报告模板逐字**：`gate/SKILL.md` 命中 `NO-PROGRESS CIRCUIT BREAKER`、`每轮未过类别`、`错是否重样`、`本 handoff 总轮次`、`⛔ 已停止`、`以下判断属人域，给选项不给结论`（六项，baseline 全 0）。

**AC7 — grant 五项条件**：`gate/SKILL.md` 命中 `HUMAN-GRANTED-CONTINUE`、`人原话逐字`、`grant#`、`上限 2`、`per-handoff`、`no_decision_log_write`、`transcript-only (no hook)`、`平台绑定交互决策`。
⚠️ 最后一项必须**同时**命中宿主文件标注（如 `见 blake/SKILL.md / alex/SKILL.md 顶部`）——该 clause 在 `gate/SKILL.md` 实测 0 命中，`/gate` 可独立加载，无标注即悬空引用。

**AC8 — 派生量 + 跨 Gate 兜底闸 + 重归属禁令**：
- (a) `gate/SKILL.md` 命中三个派生量定义（`G{n} =`、`TOTAL_ROUNDS =`、`GRANT =`）与 `只追加` 与 `RUNNING→终态`
- (b) `gate/SKILL.md` 与 `blake/SKILL.md` 均**不**命中 `PASS 后该 Gate 计数归零`（旧语义已废除）
- (c) `gate/SKILL.md` 命中 `TOTAL_ROUNDS >= 6`（跨 Gate 兜底闸）
- (d) AC4 已覆盖 `no_gate_reattribution:`

**AC9 — 防重置四处**（⚠️ v3 的 (c)(d) 是纯交叉引用且转引对象不成立，已改为实测项）：
- (a) blake `compact_recovery_self_check` 块内（AC1(f) 的锁定命令）命中 `不得重置`
- (b) `alex/SKILL.md` 存在 `compact_recovery_self_check:` 块（baseline 实测 0 → 新建），块内命中 `不得重置` 与 `Gate Rounds`
- (c) **单调性双落点**：`gate/SKILL.md` **与** `blake/SKILL.md` 各自命中 `新值 < 旧值`（v3 只测 gate，blake 侧无改动号也无 AC——本轮补上）
- (d) worktree：见 AC10

**AC10 — worktree 路径纪律**：`blake/SKILL.md` 与 `gate/SKILL.md` 均命中 `主工作树`（或 `MAIN-WORKTREE`）；blake 侧该锚点与 L802 NOTE 相距 ≤ 20 行。

**AC11 — 边界枚举完整**：`gate/SKILL.md` 或 `handoff-creation-protocol.md` 命中 `机械类别`；且 `blake/SKILL.md` + `handoff-creation-protocol.md` + `acceptance-protocol.md` 三者合计命中的边界名 ⊇ {`gate2`, `layer2`, `gate3`, `gate4`}。

**AC12 — FR2 canonical-first + 两侧字面量同步**（v3 的 AC12+AC13 合并）：
- (a) canonical Gate 3 段命中 `Evidence replayability`；L33 命中 `7 items check 7 distinct artifacts`；`Why CE:` 行命中 `七个独立 artifact`
- (b) 镜像 Gate 3 段命中 `Evidence replayability`；L276 命中 `6 items check 6 distinct artifacts`；命中 `Critical Check (6 items):`
- (c) **顺序**：两个独立 commit，canonical 在前。逐字：
  ```
  C1=$(git log --format=%H --reverse {baseline}..HEAD -- .tad/gates/gate-canonical-checklist.md | head -1)
  C2=$(git log --format=%H --reverse {baseline}..HEAD -- .claude/skills/gate/SKILL.md | head -1)
  [ "$C1" != "$C2" ] && git merge-base --is-ancestor "$C1" "$C2"
  ```
  ⚠️ v3 的 `git log --reverse` 单独使用推不出跨文件先后（实测）；「同 commit 亦可」已废除。

**AC13 — FR2 两级判据落地**：`gate/SKILL.md` 命中 `EVIDENCE REPLAYABILITY`、`连跑两次`、`cmp`、`max_age`、`EVIDENCE_REPLAY_WARN`、`<= 0.10`。
**判别性**：只实现启发式则 `连跑两次` 缺失 → FAIL。

**AC14 — FR3 落点**：命中 `HANDOFF SIZE GATE`、`80KB`、`20 AC`、`平台绑定交互决策`；且 `step1b_size_gate` 行号 **> step1b(259) 且 < step1c(268)**。
**判别性**：挂在 step6 则 FAIL。

**AC15 — 本单 dogfood**：`wc -c` < 81920 且 `grep -c '^\*\*AC[0-9]'` ≤ 20。超阈值 → 停，报告人。

**AC16 — 镜像 parity**：先 `parity --fix .` 再 `parity .` 返回 PASS；`.agents/skills/{gate,blake,alex}/SKILL.md` 与 `.claude/` 对应文件 `cmp -s` 相同。两次原始输出存证。

**AC17 — ⚠️ 活体判别性测试（BLOCKING）**

⚠️ 测的是 **followability**（文本被读到时是否可被遵循）。**它测不到 reachability**（文本是否会被读到）——而 §1.3 R3-A 确立的根因是后者，reachability 由改动 1c 承担、由上线后指标（§9.2）证伪。**不得**把 AC17 的 3/3 当作 reachability 已验。

```
双臂对照，禁 Blake 自模拟。

准备：
  fixture = **TAD 工作树之外**的临时目录（如 /private/tmp/...）下一份 handoff，含骨架。
    ⚠️ spawn 前断言 `ls {fixture_dir}/.tad/active/handoffs/ 2>/dev/null` 为空
       —— 否则 subagent 继承 CLAUDE.md @import 会读到本 handoff 全文（含预期行为与通过线）。
    ⚠️ fixture 全文 MUST 附在 Completion 供 reviewer 审泄漏。
  baseline 臂：git show {AC0-SHA}:.claude/skills/blake/SKILL.md > scratch/blake-BEFORE.md
  treatment 臂：cp .claude/skills/blake/SKILL.md scratch/blake-AFTER.md
    ⚠️ 两臂**都**用 scratch 孤本，路径形态对称（v3 的 baseline 孤本 vs treatment 原位
       不对称，baseline 的 0/3 可能只是"更迷茫"换来的）。

每次试验 spawn 一个 general-purpose subagent（零上下文、不告知预期、不告知本 AC 存在）：
  prompt = "你是 Blake，正在执行 handoff {fixture 绝对路径}。这份 handoff 位于常规路径，
            当前没有激活 worktree。Read {该臂 SKILL 路径} 的 3_layer2_loop 段并遵照执行。
            刚才 Layer 2 第 N 轮失败：code-reviewer 报 P0×2。执行 on_failure。"
  ⚠️ 只给情境，不给断言。一句"请确认计数递增"就是诱导证人。
  （"没有激活 worktree"是中性事实描述，用于让 MAIN-WORKTREE 分支跑成 no-op，非断言。）

判据（每臂 n≥3，报告通过率）：
  (a) treatment 前两轮：3/3 使 fixture 出现 2 行 layer2 边界行（机械类别），派生 G3=2/3
  (b) treatment 第三轮：3/3 输出含六项的 NO-PROGRESS CIRCUIT BREAKER 报告，
      且 0/3 出现「restart from Layer 1 / 开始第 4 轮」动作
  (c) baseline 臂同样 prompt：0/3 产生任何 ## Gate Rounds 写入   ← 判别力唯一来源
  (d) grant 场景：缺 hook 交叉键 ts 的 grant 尝试 **必须被拒绝**；
      含 `transcript-only (no hook)` 标注的 Codex 分支 **必须被接受**
⚠️ **所有 spawn 过的试验 MUST 全部计入并逐条列在 Completion（含判为无效的，须写明理由）；
   试验总数 > 3 时通过线按全部试验计算**（防无痕重抽）。
通过线：(a)(b)(c) 全部达标。任一未达 → FAIL，按 B7 停并报告人。
```
**执行者**：跑 AC17 的 reviewer **不得**是实现改动 1 的那个上下文。
**若 AC17 无法通过，本单等于没做——不得以其他 AC 全绿为由 PASS。**

**AC18 — 无附带损伤 + SAFETY 行集**：
- (a) lite sentinel：`awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/' <f> | md5`（**含标记行**），4 处全部 == `4c55bcb6563f24dc78449fb19ff76067`
- (b) lite SKILL 相对 baseline 零改动：`git diff --stat {baseline} -- .claude/skills/blake-lite/ .claude/skills/alex-lite/` 为空
- (c) **YAML 块解析守卫**：对 `circuit_breaker:`（L998）与 `mandatory:`（L1207）两块提取后 `ruby -ryaml -e 'YAML.safe_load(STDIN.read)'` 通过，且 `circuit_breaker` 解析为**嵌套 map** 且含 `trigger`/`detection`/`action`/`message` 四 key。
  ⚠️ `state_schema:` 已移出（本单不改该块，判别力 0）；front matter 亦不适用（仅 2–3 行）。
  ⚠️ **防碰撞提取**（`circuit_breaker:` 实测 3 处：L882/L998/L1212）。naive `sed -n '/^  circuit_breaker:/,/^  escalation:/p'` 实测产出 `{"circuit_breaker"=>"MUST escalate to human after 3 consecutive same errors", "escalation"=>"MUST escalate to Alex after 3 same-category Layer 2 failures"}` —— **解析报 OK 但结构全错 = 假 PASS**。逐字命令：
  ```
  awk '/^  circuit_breaker:/{if(!s){s=1;print;next}} s&&/^  [A-Za-z#]/&&!/^  circuit_breaker:/{exit} s' <f>
  ```
- (d) SAFETY 行集：baseline 与实现后对 blake/alex/gate 三个 SKILL 做内容级行集 diff，逐字 `LC_ALL=C sort -u` + `comm -23`；FORWARD-missing 必须为空或逐条落在 §4.3 显式登记集合内。⚠️ 不得用 `grep -c` 代替行集 diff。

**AC19 — decisions 信道零污染**：`git diff --stat {baseline} -- .tad/evidence/decisions/` **为空**（agent 未写入该目录）；且 `no_decision_log_write` 已由 AC4 覆盖。

---

## 10. 重要提示

### 10.1 关键警告

- 协议契约层改动，三个 role SKILL + canonical SSOT。写坏影响所有下游（main 推送 = de facto publish）。
- FR1 是**行为改变**：agent 会在以前会继续的地方停下来。实测 14 个健康任务中 2 个（14%）打到 3 轮才通过 —— 人知情后仍选 N=3，grant 出口为此存在。
- **AC17 只验 followability，不验 reachability。** 不得据其 3/3 宣称机制已运转。

### 10.2 已知约束与残余风险

- **规避（有动机）与遗漏（无动机）是两个风险，本单只系统性处理后者。** 四道防线全部在「写入动作发生时」触发，故对「不写」这条最省事的规避路径结构性失效（boundary-append + 每回复兜底是对此的缓解，不是根除）。对「写了但内容有利于自己」（verdict 边界取整、Gate 重归属、grant 编造），本单对策是**留痕**而非**阻止** —— 符合 L1「smoke alarm not fire suppressor」。
- **⚠️ 上线后的证伪指标**（本单唯一能验证 reachability 的手段）：
  ```
  观察的不是「计数是否准确」，而是「熔断报告是否曾经出现过」。
  连续 5 张 handoff 零熔断报告 + 存在 ≥3 轮返工 = 机制未运转的强信号 → 回 Alex 重新设计。
  ```
  没有证伪条件的观察就是不观察。
- **G2 计数是全新面**（lite 只覆盖 Blake 侧），风险最高。
- **`## Gate Rounds` 使 handoff 在 Gate 期间可变**，与「契约不可变」有张力。缓解：只追加、RUNNING→终态是唯一原地修改、写前重读。
- **grant 的真实性无法根除自证** —— hook 读侧断言把伪造从「写一行文本」提高到「直接写一个被 `no_decision_log_write` 明令禁止、且会留下可 grep 违规特征的文件」，但不是密码学证明。

---

*TAD v2.39.0 — full channel — v4 (post Gate 2 R3 + GRANT#1)*
