---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs:
  - .tad/hooks
skip_knowledge_assessment: no
gate4_delta:
  - field: "AC4 (expert_review_finding observation)"
    alex_said: "observational expert_finding emission would cleanly reflect P0/P1/P2 counts"
    actual: "parser self-triggered on review PROSE quoting '| P0 |' → emitted a false '1 P0' event for code-reviewer (0 real P0s); P2 counts also inflated"
    caught_by: "Blake dogfood + Alex Gate 4 raw-recompute of 2026-05-30.jsonl"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Terminal 1) | **To:** Blake (Terminal 2)
**Date:** 2026-05-30 | **Priority:** P1
**Slug:** trace-instrumentation-fix

> **v2 (post expert review)** — code-reviewer (FAIL→fixed) + backend-architect (COND-PASS→fixed).
> 10 P0 (8 distinct) integrated. See §9.2 Audit Trail. Key pivot: gate_result observation
> now parses a **Blake-written machine-readable marker**, not COMPLETION prose (both
> reviewers: prose-parsing is fragile coupling; `gate3-verdict.md` only 2/76 → not reliable).

---

## 🔴 Gate 2: Design Completeness (Alex必填)

### Gate 2 检查结果
- ✅ Expert review complete (code-reviewer + backend-architect)
- ✅ All 8 distinct P0 issues resolved (§9.2)
- ✅ Implementation details sufficient
- ✅ AC dry-run log present with REAL output (§6.7)
- ✅ Grounded Against present (§6.5)

---

## 1. Task Overview

### 1.1 What We're Building
修复 v2 trace 仪表系统,让决策级事件在**真实工作流**中可靠触发,并修复 `handoff_created`
6 倍过度触发。机制:**观测式为主**——hook(`post-write-sync.sh`)解析 agent 写的产物。
关键:可靠的 gate/reflexion 信号靠 **Blake 写稳定的机器可读标记**(不是解析散文)。

### 1.2 Why We're Building It
`*evolve`(2026-05-30 跑)发现:Auto-Evolve Epic 建了分析引擎 + 发射库,但从没把发射接进
热路径。代码层证据:全库只有 1 个命令式 trace 调用点(Blake reflexion),其余 5 个 helper
是死代码;真实环境 gate/expert/decision 触发 0 次;`handoff_created` 过度触发 6 倍
(1795/300)。修完后下一次 `*evolve` 才第一次有真数据。

### 1.3 Intent Statement
让自进化数据层从"纸面机器"变实际运转。**绝不依赖 agent 记得手动调用**(reflexion 唯一调用点
只触发 1 次已证明命令式不可靠),**绝不引入 fail-closed hook**(单用户 CLI 拒绝机械强制),
**绝不造假事件**(解析不到 = 静默跳过)。

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 2：历史经验摘录（⚠️ Blake 必须注意的历史教训）

| 教训 | 来源 | 为何与本任务相关 |
|------|------|-----------------|
| **`.router.log` 5-Tuple = load-bearing hook output contract** | architecture.md | trace 被 dream-scanner / *optimize / *evolve 消费。新事件**必须复用现有 trace-writer.sh helper**(格式自动匹配旧 328 条),不改 schema。被消费的产物要有稳定契约 → 这就是 gate verdict 用结构化标记而非散文的原因。`tail -1` 并发隐患同样适用于去重 grep。 |
| **Mechanical Enforcement Rejected (单用户 CLI)** | architecture.md ⚠️SAFETY | hook **绝不 fail-closed**。所有解析块包 `\|\| true`,绝不 block Write/Edit/Read,绝不返回 deny。`post-write-sync.sh` 当前无 `set -e`,新增代码也不得引入。 |
| **Hook Shell Portability** | architecture.md | **无 `grep -P`、无 `.*?` lazy(BSD 不支持)、无 `\d`(用 `[0-9]`)**。用 `grep -oE`+`sed`;单 awk 进程;`ENVIRON["VAR"]` 传用户内容;`$()` 吞 `\x00` 用 `\x1E`。 |
| **Double-Parse for String-Encoded JSON** | architecture.md | reflexion/decision 的 context 是 JSON 字符串 → **单遍 `jq '.context \| fromjson \| .field'`**;两步会失败。`record_trace` 的 `jq -nc` 输出**紧凑无空格**:真实格式是 `"type":"handoff_created"`(无冒号后空格)。所有 grep 必须匹配无空格形式。 |
| **Bash `read` IFS 折叠空字段** | architecture.md (2026-05-20) | §11 表格解析**必须用 `awk -F'\|'`**(保留空字段),不用 `IFS='\|' read`。 |
| **Layer 2 Audit Canonical Reviewer Name Drift** | architecture.md (2026-05-27) | review 文件真实命名是 `code-reviewer.md` / `backend-architect.md`(canonical sub-agent 名),不是 `code-review.md`。reviewer-from-basename 必须映射 canonical 名。 |
| **Bash heredoc 注入 via 未校验 args** | code-quality.md | 解析出的 slug/verdict/cell 进入 grep/awk 前先校验 + 截断。slug:`^(HANDOFF\|COMPLETION)-[0-9]{8}-(.+)\.md$` group 2(BSD-safe)。 |
| **Source Import: False Success / validation theater** | architecture.md | 验收别只看"文件存在"——AC8 必须 grep 出**非合成**真实事件。AC2/AC7 不能是"改前改后都 PASS"的空 AC。 |
| **AC Verification Drift(4 次复发)** | architecture.md | §9.1 每条命令必须 dry-run 真实产物并贴真实输出(§6.7)。脑内模拟正则不可靠。 |

### Blake 确认
- [ ] 我已读上述教训,特别是:hook 绝不 fail-closed + 复用 helper 不改 schema + 无空格 grep + BSD 正则(无 `.*?`/`\d`)

---

## 2. Background Context

### 2.1 Previous Work
Auto-Evolve Epic 建了:`common.sh::record_trace()`(写 `traces/{date}.jsonl`,TRACE_* env-var)、
`trace-writer.sh`(6 helper,5 个死代码)、`post-write-sync.sh`(观测式发 handoff_created/task_completed/evidence_created)、`*optimize`/`*evolve`(9 指标分析)。

### 2.2 Current State (case arm 顺序 — CR-P0-1 关键)
`post-write-sync.sh` 的 case(first-match-wins):
- `*.tad/active/handoffs/HANDOFF-*.md)` → handoff_created(line ~62,**每次写都发 → 6 倍**)
- `*.tad/active/handoffs/COMPLETION-*.md)` → task_completed + Gate 3 强制提醒(line ~67)
- `*.tad/active/playground/...` / ralph state(line ~80)
- domain pack arms
- `*.tad/evidence/traces/*` 递归 guard(line ~102,跳过 trace 自身写入)
- `*.tad/evidence/*)` → evidence_created(line ~106,**会先匹配 reviews/blake 路径**)

### 2.3 Dependencies & Consumers (BA-P0-1 修正)
- 改:`common.sh`(只读)、`trace-writer.sh`(复用 helper)
- **真实消费者**(只读,验证不破坏):`dream-scanner.sh`(读 `traces/{date}.jsonl`;Pass A 按 what_failed 分组、Pass C 依赖 `actor_tag=human_overridden`、用 `context\|fromjson`)+ `*optimize`/`*evolve`(alex SKILL)
- **`trace-digest.sh` 不是本变更的消费者**:它读 `traces/per-handoff/{slug}/` 的 step_start/step_end 事件(不同目录、不同类型)。本任务不写那些。AC10 只覆盖 dream-scanner。

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 — handoff_created 去重**:发射前 grep 今天 `traces/{date}.jsonl` 是否已有该 **normalized slug**
  (`(HANDOFF|COMPLETION)-[0-9]{8}-(.+)\.md` group 2)的 handoff_created,有则跳过。
  grep 用无空格格式 `'"type":"handoff_created"'`。⚠️ 已知 TOCTOU:并行 Write 可能各自 grep 不到都发射;
  单用户 CLI 低概率,**接受风险**(文档记录,不引入锁)。

- **FR2 — gate_result 观测(MVP=Gate 3),改用机器可读标记**:
  - Blake 在 COMPLETION 报告 frontmatter 写 `gate3_verdict: pass|fail|partial`(稳定契约,见 FR2b)。
  - hook 在 COMPLETION arm 解析该 frontmatter 行(BSD-safe:`grep -E '^gate3_verdict:'` + 提取值),
    归一为 pass/fail/partial,调 `trace_gate_result 3 <verdict> "Gate 3" <slug> blake`。
  - **不解析散文**(COMPLETION 散文格式历史上五花八门;且会误匹配模板里 `PASS / PARTIAL / FAIL` 三连菜单行)。
  - frontmatter 无 `gate3_verdict:` → 静默跳过(老 COMPLETION 向后兼容)。

- **FR2b — Blake 写 gate3_verdict 标记(⚠️ 时序关键,re-review P1-A)**:
  - ⚠️ **顺序契约**:`*complete` 写 COMPLETION 在 `/gate 3` **之前**,此时 verdict 尚不存在。
    因此 Blake 必须在 **Gate 3 产出判定之后**,作为 Gate 3 **post-step** Edit COMPLETION frontmatter,
    写/更新 `gate3_verdict: <verdict>`(值 ∈ {pass, fail, partial},与 §Gate 3 v2 结果一致)。
    **不得**在初始 COMPLETION-write 时猜填(否则是未验证的占位)。
  - 该 post-step 的 Edit 本身是对 COMPLETION-*.md 的写入 → 重新触发 post-write-sync 的 COMPLETION arm
    → hook 此时解析到 marker → 发射 gate_result(时序正确:verdict 已知)。
  - ⚠️ **连带去重**(避免 COMPLETION 被多次写导致 task_completed/gate_result 重复发):
    FR1 的去重机制**推广**到 task_completed 和 gate_result —— 每 (slug, type, day) 只发 1 次
    (gate_result 额外允许 verdict 变化时更新:若已存在该 slug 当天 gate_result 但 outcome 不同,
    则发新事件覆盖语义;相同则跳过)。
  - COMPLETION 模板 frontmatter 加 `gate3_verdict:` 字段 + 上述时序说明。

- **FR3 — expert_review_finding 观测**:
  - 新 case arm 必须**插在 `*.tad/evidence/traces/*` guard(line ~105)之后、`*.tad/evidence/*)`(line ~106)之前**
    (first-match-wins);arm 内解析后**仍发 evidence_created**(或显式 fall-through),保留现有行为。
  - 匹配 `*.tad/evidence/reviews/blake/*/*.md)`。reviewer 从 basename 推断,映射 **canonical 名**:
    `code-reviewer.md→code-reviewer`、`backend-architect.md→backend-architect`、`*-review.md→`去 `-review` 后缀,
    **其余一律 basename 去 `.md` 原样用**(default arm,re-review P2-C — 映射必须 total,
    覆盖 security-auditor.md / ux-expert-reviewer.md 等)。跳过 `gate3-verdict.md`(Blake verdict,非外部 review)。
  - 计数:对文件里出现的**每个优先级**(P0/P1/P2),用 finding-label 锚点(如 `^#+ *P0` 或表格单元 `\| *P0\b`)
    `grep -cE`(**不带 `-o`**,数行不数 match)算该级 finding 数。每个非零优先级发 **1 个事件**:
    `trace_expert_finding <reviewer> P<n> "<count> P<n> findings" <slug>`(count 进 context,outcome=P<n>)。
    散文里的 "no P0 issues" 不应误计(锚点而非裸 `P0`)。
  - 解析不到任何 finding → 静默跳过(Express 无 review = 真没 finding,正确)。

- **FR4 — decision_point 观测**:写 HANDOFF 时解析 §11 Decision Summary 表格。
  - 用 `awk -F'|'`(保留空字段)。标准 §11 列序:`| # | Decision | Options | Chosen | Rationale |`
    → **decision=$3, chosen=$5, rationale=$6**(每个 `gsub` 去首尾空白)。跳过表头行 + 分隔行(`^\|[-: |]+\|$`)。
  - **override 检测(BA-P0-2)**:若 rationale 含 override 标记(`用户选`/`user chose`/`human override`/`人类决策`)
    → `TRACE_ACTOR=human_overridden`,否则默认 `agent_inferred`。
    经由 `trace_decision_point <decision> <chosen> <rationale> <slug> <actor>`。
    ⚠️ **局限**(文档记录):§11 表只能检测显式标记的 override;无标记的 override 会记为 agent_inferred,
    会稀释 `*evolve` step8 的 override 率。这是 MVP 已知边界。
  - 无 §11 表格 → 静默跳过。

- **FR5 — reflexion_diagnosis 观测化(去掉命令式 → 纯观测)**:
  - **删除** blake/SKILL.md:1310-1311 的命令式 `trace_reflexion_diagnosis` 调用(handoff 自身论点:命令式不可靠;
    保留它会与观测式双发,污染 dream-scanner Pass A 的"≥2 同 what_failed → recurring"判定)。
  - Blake 在 COMPLETION 加结构化 `## Reflexion History` 小节(每次 reflexion 一块:
    `what_failed:` / `root_cause_hypothesis:` / `revised_approach:` / `confidence:`)。
  - hook 解析 COMPLETION 时,对每块调 `trace_reflexion_diagnosis`。
  - **去重(BA-P1-4)**:按 `(slug, what_failed, day)` 去重——发射前 grep 今天 trace 是否已有同 slug 同 what_failed
    的 reflexion_diagnosis(`context|fromjson|.what_failed` 比对),有则跳过。

- **FR6 — Schema 兼容 + 修真实分析器 bug(BA-P0-3/P0-4 修正)**:
  - ⚠️ **premise 更正**:gate_result 分析器**本来就对**(alex SKILL:4883 从 context 提取 gate 编号,outcome 读顶层)。
    **不存在**"从 context 取 outcome"的错误文本。不要去"修"正确的解析器。
  - **真实 bug**:alex SKILL:4907 `Count P0 findings per slug (outcome=P0 in context)` 自相矛盾。
    改为:`outcome=P{n}` 顶层读取 + count 在 context(匹配 FR3 发射格式)。
  - **N=0 gate skip guard(BA-P1-3)**:`*optimize` step6 + `*evolve` step6 输出 gate pass rate 时,
    **跳过 N=0 的 gate**(MVP 只发 Gate 3 → Gate 2/4 无数据,否则会误报 "Gate 2 pass rate 0% ⚠️")。
    并在输出注明 "gate pass rate 当前仅反映 Gate 3"。
  - 确认 reflexion/decision 用 `context|fromjson`(已对),gate_result/expert_finding 用 outcome 顶层(澄清写明)。

### 3.2 Non-Functional Requirements
- **NFR1** hook 绝不 fail-closed(所有解析块 `|| true`,不 block,不 deny)。SAFETY 约束。
- **NFR2** 不改 trace schema,不迁移 328 条旧事件。新事件复用 helper。
- **NFR3** macOS BSD 兼容(无 `grep -P`/`.*?`/`\d`)。
- **NFR4** 解析值在进 `trace_*` 前**校验 + 截断**:slug 用 BSD-safe 正则校验;verdict 用 allowlist `(pass|fail|partial)`;
  所有 cell `tr -d '\n' | cut -c1-200`。

### 3.3 Optimization Target
无。

---

## 5. Files to Modify / Create

1. **`.tad/hooks/post-write-sync.sh`** (MODIFY) — FR1 去重 + FR2 gate marker 解析(COMPLETION arm)+
   FR3 reviews arm(插在 traces guard 后、evidence arm 前,保留 evidence_created)+ FR4 §11 解析(HANDOFF arm)+
   FR5 reflexion 块解析(COMPLETION arm)+ NFR4 校验/截断
2. **`.tad/hooks/lib/trace-writer.sh`** (MODIFY, 可能) — 仅当需要去重 helper / actor 透传微调
3. **`.claude/skills/blake/SKILL.md`** (MODIFY) — 删 1310-1311 命令式 reflexion 调用(FR5);
   completion_protocol 加"写 gate3_verdict frontmatter"(FR2b)+"写 ## Reflexion History 小节"(FR5)
4. **`.tad/templates/completion-report.md`** (MODIFY) — frontmatter 加 `gate3_verdict:` 字段(FR2b)+
   加 `## Reflexion History` 模板小节(FR5)
5. **`.claude/skills/alex/SKILL.md`** (MODIFY) — `*optimize`/`*evolve` step6 N=0 gate skip + step9 line 4907 修正 +
   澄清 gate_result/expert 读 outcome 顶层(FR6)
6. **`.tad/evidence/reviews/blake/trace-instrumentation-fix/`** (CREATE) — Blake Layer 2 review 产物
   (`code-reviewer.md` + `backend-architect.md`,canonical 命名)

### 6.5 Grounded Against (Alex step1c 实际 Read)
- `.tad/hooks/lib/trace-writer.sh`(全文,2026-05-30)— 6 helper 签名;trace_decision_point 第 5 参数 actor
- `.tad/hooks/lib/common.sh`(record_trace 60-186,2026-05-30)— TRACE_* + `jq -nc` 紧凑无空格 + context 截断 200/2048,outcome/slug/agent **不截断** → FR NFR4 需自行截断
- `.tad/hooks/post-write-sync.sh`(case arms 62/67/102/106,2026-05-30)— 发射点 + arm 顺序确认
- `.claude/skills/blake/SKILL.md`(reflexion 1298-1311 + completion 1395/1506-1730,2026-05-30)— 命令式调用点 + gate3-verdict 排除规则
- `.tad/templates/completion-report.md`(section 55 多 verdict 菜单行 + frontmatter,2026-05-30)— FR2 不解析散文的原因
- `.claude/skills/alex/SKILL.md`(4882-4909, 5126-5133,2026-05-30)— gate_result 分析器**已对**;4907 行真实 bug
- `.tad/hooks/lib/dream-scanner.sh`(Pass A/C 127-218,2026-05-30)— 消费者字段:what_failed 分组、actor_tag=human_overridden
- `.tad/hooks/lib/trace-digest.sh`(42,2026-05-30)— 读 per-handoff/ step 事件,**非本变更消费者**
- LSP: N/A(shell + markdown)

### 6.7 AC Dry-Run Log (Alex step1d 实跑 @ 2026-05-30, 真实输出)
- **AC2**(call sites 排除定义文件): raw `grep -rl 'trace_gate_result\|trace_expert_finding\|trace_decision_point' .tad/hooks/ .claude/skills/ | grep -v 'lib/trace-writer.sh'` → **当前输出空(0 call sites,确认死代码)**;实现后应 ≥1。
- **AC1**(无空格 + slug-scoped): `grep '"type":"handoff_created"' f | grep -c '"slug":"foo"'` → 双写 raw=**2**;去重后应=1。无空格格式确认(真实 trace `"type":"handoff_created"`)。
- **AC5**(§11 awk 解析): `awk -F'|'` 在本 handoff §11 跑通,正确提取 decision=$3/chosen=$5/rationale=$6(列序已确认)。
- **override 检测**: `grep -c '用户选' 本handoff` = **1**(§11 row 2 含标记,可检测)。
- **slug BSD 正则**: `sed -E 's/^(HANDOFF|COMPLETION)-[0-9]{8}-(.+)\.md$/\2/'` → `trace-instrumentation-fix`(无 `\d`,通过)。
- **AC3/AC4/AC6/AC8**: post-impl(需 Blake 真实产物),已语法校验。AC8 是 dogfood,Blake Gate 3 时实跑。

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | 要求 | Verification Method | Type | Verified Output |
|-----|------|--------------------|------|-----------------|
| AC1 | handoff_created 去重 | 同 slug 当天写 HANDOFF 两次,`grep '"type":"handoff_created"' traces/{date}.jsonl \| grep -c '"slug":"<slug>"'` = 1 | post-impl | 双写 raw=2(已验证) |
| AC2 | 死代码激活(call site 存在) | `grep -rl 'trace_gate_result\|trace_expert_finding\|trace_decision_point' .tad/hooks/ .claude/skills/ \| grep -v 'lib/trace-writer.sh'` ≥1 | pre-impl=空 | 当前空,实现后≥1 |
| AC3 | gate_result 观测(标记) | COMPLETION frontmatter 含 `gate3_verdict: pass` → trace 出现 gate_result outcome=pass slug=该slug | post-impl | (Blake Gate 3) |
| AC4 | expert_finding 观测 | 写 reviews/blake/{slug}/code-reviewer.md(含 P0 finding) → trace 出现 expert_review_finding outcome=P0 agent=code-reviewer | post-impl | (Blake Gate 3) |
| AC5 | decision_point 观测 + override | 写含 §11 表(rationale 有"用户选")的 HANDOFF → trace 出现 decision_point,该行 actor_tag=human_overridden | post-impl | awk 解析已验证 |
| AC6 | reflexion 观测化 + 命令式已删 | `grep -c 'trace_reflexion_diagnosis' .claude/skills/blake/SKILL.md` = 0 AND COMPLETION 模板 `grep -c 'Reflexion History'` = 1 | pre-impl(实现后) | (Blake Gate 3) |
| AC7 | 分析器 schema 修正 | alex SKILL step9 不再含自相矛盾 `outcome=P0 in context`(改为 outcome 顶层);step6 含 N=0 skip guard 描述 | pre-impl grep | (Blake Gate 3) |
| AC8 | **真实跨 session 验证**(meta) | Blake 跑完本 handoff Gate 3 后,`grep '"slug":"trace-instrumentation-fix"' traces/{date}.jsonl \| grep '"type":"gate_result"'` ≥1,且 outcome ∈ {pass,fail,partial}、actor_tag="agent_inferred"(P2-B:trace_gate_result 硬编码,断言期望值而非仅非空) | post-impl dogfood | (Blake Gate 3) |
| AC9 | hook 绝不 fail-closed | `bash -n post-write-sync.sh` PASS;喂畸形 COMPLETION(嵌入 `\|`、换行、非 UTF8 字节)→ hook exit 0 + 输出有效 JSON | post-impl | (Blake Gate 3) |
| AC10 | dream-scanner 不破坏 | 发出每种新事件后 `bash .tad/hooks/lib/dream-scanner.sh` exit 0,fromjson 路径不报错 | post-impl | (Blake Gate 3) |

### 9.2 Expert Review Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1 FR3 case arm 不可达(evidence/* 先匹配) | FR3 明确插入位置(traces guard 后/evidence arm 前)+ 保留 evidence_created | Resolved |
| code-reviewer | P0-2 AC2 dry-run 错(返回定义文件) | AC2 加 `grep -v lib/trace-writer.sh`;§6.7 实跑确认空 | Resolved |
| code-reviewer | P0-3 AC1/AC8 grep 多空格(真实无空格) | 全部改 `'"type":"..."'` 无空格;§6.7 验证 | Resolved |
| code-reviewer | P0-4 FR2 正则匹配模板菜单行 + BSD 无 `.*?` | FR2 改解析 frontmatter 标记(非散文),排除菜单行 | Resolved |
| code-reviewer | P0-5 无注入/截断守卫;`\d` PCRE 无效 | NFR4 校验+截断;slug 用 `[0-9]{8}` BSD-safe | Resolved |
| backend-architect | P0-1 trace-digest 非消费者;AC10 假测试 | §2.3 修正消费者模型;AC10 只覆盖 dream-scanner | Resolved |
| backend-architect | P0-2 decision_point 无法产生 human_overridden | FR4 加 override 标记检测;文档记录局限 | Resolved |
| backend-architect | P0-3 expert_finding outcome 语义三方冲突 + 计数未定义 | FR3 定契约(每级 1 事件,count 进 context);FR6 修 4907 | Resolved |
| backend-architect | P0-4 gate_result schema premise 错(分析器本来对) | FR6 更正 premise;不修正确解析器;只修真实 4907 bug | Resolved |
| backend-architect | P0-5/P1-3 gate_num 硬编码 + N=0 误报 | FR2 Gate 3 标记;FR6 加 N=0 skip guard | Resolved |
| both | P1 reflexion 双发风险 | FR5 删命令式调用 → 纯观测 + (slug,what_failed,day) 去重 | Resolved |
| code-reviewer (re-review) | **P1-A 新** gate3_verdict 时序矛盾(verdict 在 Gate 3 前写,但 verdict 那时不存在) | FR2b 改:Gate 3 post-step Edit 写 marker;Edit 重触发 hook;task_completed/gate_result 推广去重 | Resolved |
| code-reviewer (re-review) | P2-B AC8 actor_tag≠"" 恒真(trace_gate_result 硬编码) | AC8 改断言 actor_tag="agent_inferred" | Resolved |
| code-reviewer (re-review) | P2-C FR3 reviewer 映射不 total | FR3 加 default arm(其余 basename 原样) | Resolved |

---

## 10. Important Notes

### 10.1 关键约束
- ⚠️ hook 绝不 fail-closed(NFR1)= SAFETY = 违反即 VIOLATION。
- ⚠️ 不改 trace schema(NFR2)。复用 trace-writer.sh helper。
- ⚠️ 观测式优先;唯一 agent 主动产物是 Blake 写的 **gate3_verdict 标记 + Reflexion History 块**(文本,hook 解析)。
- ⚠️ BSD 正则:无 `.*?`、无 `\d`、无 `grep -P`。每条 §9.1 命令 Blake 必须真实 dry-run 贴输出。

### 10.2 Dogfood(AC8)
本 handoff 实现后,Blake 写 `gate3_verdict: pass` 到自己的 COMPLETION → 应产生第一个非合成
gate_result 事件(slug=trace-instrumentation-fix)。这是自举的最佳证明。

### 10.3 Sub-Agent 建议
Layer 2:code-reviewer(shell 安全 + 解析正确)+ backend-architect(hook 契约 + 消费者兼容)。
review 文件用 canonical 名 `code-reviewer.md` / `backend-architect.md`。

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/trace-instrumentation-fix/code-reviewer.md
  - .tad/evidence/reviews/blake/trace-instrumentation-fix/backend-architect.md
gate_verdicts:
  - (COMPLETION frontmatter gate3_verdict + §Gate 3 v2 结果)
completion:
  - .tad/active/handoffs/COMPLETION-20260530-trace-instrumentation-fix.md
knowledge_updates:
  - (likely architecture.md: "Observational > imperative emission; stable marker contract for consumed artifacts")
```

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | 发射机制 | 观测式 / agent 主动 / 混合 | 观测式为主 | 用户选;reflexion 唯一命令式调用只触发 1 次,证明命令式不可靠 |
| 2 | gate/reflexion 信号源 | 解析散文 / 结构化标记 | 结构化标记(Blake 写) | 两位审查员:散文脆弱;gate3-verdict.md 仅 2/76;`.router.log` 教训=被消费产物要稳定契约 |
| 3 | Schema 不一致 | 改分析器 / 统一迁移 / 暂不管 | 改分析器兼容(且更正:分析器本来基本对) | 用户选;避免 breaking change;真实 bug 只在 4907 行 |
| 4 | Gate 观测范围 | 仅 Gate 3 / 含 Alex 侧 | MVP 仅 Gate 3 + N=0 skip guard | 用户选;Gate 3 标记可靠;guard 防 *evolve 误报 Gate 2/4 0% |
| 5 | reflexion 可观测 | Blake 写块→解析 / agent 主动 / 暂不做 | Blake 写块→解析,**删命令式** | 用户选;删命令式避免双发污染 dream-scanner |
| 6 | 降级策略 | 静默跳过 / 发 unknown | 静默跳过 | 用户选;不造假事件 |
| 7 | 去重粒度 | 每天 / 永久 / 仅首次 | 每 slug 每天一次 | 用户选;PostToolUse 难分 create/edit;TOCTOU 接受 |

---

## Blake Instructions
- 完整 TAD 流程:读 handoff → Ralph Loop(Layer 1:`bash -n` 语法 + 真实触发测试,无 tsc)
  → Layer 2(code-reviewer + backend-architect,P0=0,canonical 命名)→ *complete 写 COMPLETION → /gate 3
- §9.1 每条命令**必须真实 dry-run** 贴 §9.2/COMPLETION(AC Verification Drift 已复发 4 次)
- AC8 是 dogfood:你写 `gate3_verdict: pass` → 自己 Gate 3 产生第一个真实 gate_result
- AC9 fault-injection:故意喂畸形 COMPLETION 验证 hook 不 fail-closed
- 任何不确定 → escalate,不自己改设计
