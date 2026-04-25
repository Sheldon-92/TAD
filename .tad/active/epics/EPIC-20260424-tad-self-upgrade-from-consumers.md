# Epic: TAD Self-Upgrade from Cross-Project Learning

**Epic ID**: EPIC-20260424-tad-self-upgrade-from-consumers
**Created**: 2026-04-24
**Last Updated**: 2026-04-24 (Phase ordering revised — see Notes)
**Owner**: Alex
**Evidence reference**: `.tad/evidence/learnings/HARVEST-20260424-cross-project.md`

---

## Objective

根据 4 个高活跃消费者项目（menu-snap / my-openclaw-agents / toy / Next Guest）真实使用 TAD 的反馈数据，把 20+ 条可执行提案和 9 条 TAD 假设审视系统化落地为 TAD 框架升级。主线是 **直接优化本次收集到的真实 pattern**（Phase 1-4），次线是让下一次跨项目学习可以自动化（Phase 5），再下一层是假设级重设计（Phase 6，v3 候选）。

## Success Criteria

- [ ] 4 个消费者项目反复出现的 drift 模式（Supersedes / Ghost / Zombie / Slug）在 TAD 工具层被防住，不再靠用户人工发现
- [ ] Alex 基于 stale knowledge 写 handoff 的情况（toy OPRO Qwen 事故类）通过 grounding 机制被阻止
- [ ] Next Guest / my-openclaw 用户"手动绕开 Socratic 仪式"的 workaround 被 `*express` 路径正式化取代
- [ ] toy OPRO 类实验任务有专属 `*experiment` mode，不再塞进 handoff-implementation 模型
- [ ] 2 个新 Domain Pack 发布（`cost-observability`, `agent-runtime-security`）+ 3 个现有 pack 扩展
- [ ] Phase 5 完成后 `*evolve` 可观察到 3 个新信号维度（gate4_delta / user-choice / cancellation reason），降低未来跨项目学习对手动 harvest 的依赖
- [ ] 所有 20+ 提案达成 disposition: accepted (shipped) / deferred (NEXT.md 或 ideas/) / rejected (理由记录)
- [ ] Phase 6 决策门：Phase 1-5 完成后，基于实际数据决定是否开启 v3 重设计（独立 Epic）

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | State Consistency Mechanical Checks | ✅ Done | [HANDOFF-20260424-phase1-state-consistency.md](../../archive/handoffs/HANDOFF-20260424-phase1-state-consistency.md) | 4 smoke-alarm 检查 + Audit Trail template + 5 个 task 33 ACs all PASS (Gate 4 2026-04-24, commit 08e9e74) |
| 2 | Grounding & Anti-Stale-Knowledge | ✅ Done | [HANDOFF-20260424-phase2-grounding.md](../../archive/handoffs/HANDOFF-20260424-phase2-grounding.md) | grounded_in + Revalidated schema + stale-knowledge-check.sh (282 lines) + Alex step1c grounding pass — 28 ACs all PASS, alarm fatigue defended, prompt-level enforcement only (Gate 4 2026-04-24, commit 0b2e25d) |
| 3 | New Paths for Real Usage Patterns | ✅ Done | [HANDOFF-20260424-phase3-new-paths.md](../../archive/handoffs/HANDOFF-20260424-phase3-new-paths.md) | *express + *experiment + skip_knowledge_assessment 三路径正式化 — 32 ACs all PASS, AR-001 mechanical anchor 加上, Gate AUGMENT not REPLACE 修复, symmetric forbidden_implementations 5/5/5 (Gate 4 2026-04-25, commit ff96bd5) |
| 4 | Domain Pack Expansion | ✅ Done | [HANDOFF-20260425-phase4-domain-pack-expansion.md](../../archive/handoffs/HANDOFF-20260425-phase4-domain-pack-expansion.md) | 8 Domain Pack YAML 扩展 21 items + 1 README + 2 architecture.md entries — 包含 Google DESIGN.md spec 集成（Apache 2.0 verified）+ Anthropic Anti-AI-Slop 哲学（Apache 2.0 verified）。P4.1 deferred + P4.2 redirected per pretriage (Gate 4 2026-04-25, commits d2a73a1 + 93fcb50) |
| 5 | Evolve Data Capture Infrastructure | ✅ Done | [HANDOFF-20260425-phase5-evolve-data-capture.md](../../archive/handoffs/HANDOFF-20260425-phase5-evolve-data-capture.md) | gate4_delta + AskUserQuestion capture hook + *cancel command + per-handoff trace + 4 P4 inject — 27/29 ACs hard-PASS, 2 deferred (need runtime *cancel), 1 INTENT-PASS LITERAL-FAIL (handoff bug), 1 PARTIAL (P5.2-d perf dev-host caveat per architecture.md 2026-04-14). 3 gate4_delta entries logged (meta-trifecta dogfood). 1 Alex KA entry on recurring AC-verification-command pattern (Phase 6 input). Gate 4 PASS 2026-04-25, commit d578707 |
| 6 | Assumption Re-Design (v3 candidate) | ⬚ Planned | — | Alex/Blake 边界 / Gate 3/4 分工 / Pack 分类学 / Express vs anti-rationalization 审计 |

### Phase Dependencies

- **Phase 1 / 2 / 3 / 4 / 5 全部互相独立**（不共享文件，不依赖对方产出）——可按任意顺序或并行推进
- **Phase 6 依赖 Phase 1-5 执行后的实际使用数据**——假设级重设计需要经验证据，不是纸面推演
- **推荐顺序：Phase 1 → 2 → 3 → 4 → 5 → 6**（按直接优化价值 ROI 排序）
- 也可以并行启动多个独立 Phase，但每个 Phase handoff 是 Blake 单独执行

### Derived Status

Status computed from Phase Map:
- All ⬚ → **Planning**
- Any 🔄 or ✅ → **In Progress**
- All ✅ → **Complete**

Current: **Planning**. Phase 1 handoff is the next step.

---

## Item Inventory (20+ proposals with disposition tracking)

### Phase 1: State Consistency Mechanical Checks

> 主题：「localized 机械检查」——避开 Epic 1 (2026-04-15 取消) 的 dogfood paradox，只对文件系统状态一致性做硬检查，不碰 Claude 行为。**最快止血，直接防 4 drift 模式复发。**

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P1.1 | Blake Gate 3 self-check: `git ls-files <prod-dirs> \| wc -l > 0` | toy: 38 untracked production files (arch.md 2026-04-22) | pending | One-line assertion, 加到 Blake Gate 3 v2 Layer 1 |
| P1.2 | `/tad-maintain` CHECK 扩展为 drift detector — 4 个 subcheck | 见下表 4 drift 模式证据 | pending | 把 `/tad-maintain` 从 cleanup 升级成主动扫描 |
| P1.2.a | — slug 一致性: handoff filename slug == Required Evidence Manifest paths | menu-snap code-quality.md:9 + toy layer2-audit FN 2x in 8d | pending | |
| P1.2.b | — Zombie handoff: git log --grep 找到 implementing commit 但 active/ 未清 | menu-snap code-quality.md:36 | pending | |
| P1.2.c | — Supersedes 链自动归档: grep "Supersedes:" field 提议归档链中旧条目 | Next Guest 3 handoffs 同一天互相 supersede | pending | |
| P1.2.d | — Ghost task 预检: housekeeping/sync/rsync/cleanup slug 强制 repo state 读取 | toy arch.md 2026-04-24 | pending | |
| P1.3 | `layer2-audit.sh` slug 宽松化: 尝试截断变体匹配 evidence dir | toy: `loop-mpr121-da7280` vs `-integration` FN | pending | |
| P1.4 | `userprompt-domain-router.sh` 过滤: user-event-only + 阈值 ≥3 keywords | 本 session dogfood (2/14 命中 on task-notification) | pending | 这是 hook 自己的 bug，dogfood 直击 |
| P1.5 | handoff template 加 **Expert Review Audit Trail 4-column table** 作为默认格式（reviewer / issue / resolution-section / status） | toy 自发演化格式，比自由文本更可审计 | pending | 从 Icebox Z.2 升级 — 纯模板改动，低风险高一致性收益 |

### Phase 2: Grounding & Anti-Stale-Knowledge

> 主题：防止 Alex 基于**过期 knowledge** 或 **想当然的代码认知**写 handoff。toy OPRO 事故（Qwen Plus vs qwen3-omni-flash 打错 model）是最贵的一次教训。

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P2.1 | Knowledge entry `grounded_in` frontmatter + `stale-knowledge-check.sh` | toy OPRO (knowledge 写于 2026-04-07，代码 2026-04-11-14 migrated，Alex 4-21 还 cite) | pending | Entry schema: `grounded_in: ["path/to/file.py:SYMBOL"]`。Check: 如果被引用文件 mtime > entry date → ⚠️ STALE |
| P2.2 | Alex `handoff_creation_protocol.step0_5` 加 grounding pass: 列出 handoff 将修改的文件，Read 每个头 50 行，输出 "Grounded Against: {paths}" | menu-snap aspirational Socratic (code-quality.md:15) + toy Ghost Task | pending | 阻止"我以为代码长这样"类 spec |

### Phase 3: New Paths for Real Usage Patterns

> 主题：承认用户已经在 _手动绕开_ 当前 TAD 的部分仪式（Next Guest 3 次 annotate `skip Socratic, skip epic review`；toy OPRO 塞进 implementation 模型）。把这些绕路正式化成一等路径，同时保留安全底线（review 不能跳）。

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P3.1 | 正式化 `*express` 路径: 保留 ≥1 expert review + Gate 2 frontmatter 校验 + Gate 3 self-check；允许跳过 Socratic / Epic assessment / Knowledge Assessment | Next Guest × 3, my-openclaw × 1 | pending | 必须与 anti_rationalization_registry AR-001 "express = review-exempt" 保持一致（review 仍必做） |
| P3.2 | 新增 `*experiment` mode: OPRO / A-B test / benchmark / prompt tuning 类任务。专属 Gate: 控制变量清晰 / self-enhancement 已 mitigate / baseline 成立 / 可重现 | toy OPRO handoff + Claude-Sonnet-both-judge-and-optimizer self-enhancement | pending | 跟 ai-evaluation Domain Pack 关系：Domain Pack 是工具推荐，`*experiment` 是 workflow |
| P3.3 | handoff frontmatter `skip_knowledge_assessment: yes\|no` | Next Guest 70% capture rate (12/17)；trivial CSS/copy 合理跳过 | pending | 默认 no；trivial 任务 Alex 可声明 yes |

### Phase 4: Domain Pack Expansion

> 主题：新涌现的横切 category 补空白。cost-observability (menu-snap 已有完整 blueprint) 和 agent-runtime-security (my-openclaw 13 条实战) 都是真实需求。

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P4.1 | 新 Pack: `cost-observability` | menu-snap full blueprint (4-layer model + billing-snapshot.sh + cost-report.sh + gemini-logger.ts + MTD playbook) + IDEA-20260419 已 filed | pending | Capabilities: billing_collection / cost_attribution / optimization_roi_analysis / cost_discipline_cadence |
| P4.2 | 新 Pack: `agent-runtime-security`（或扩展 ai-agent-architecture） | my-openclaw 13 security entries | pending | 创建前需评估 vs paused Security Chain Epic Phase 2 的 overlap |
| P4.3 | 扩展 `ai-prompt-engineering`: **(A) 新增正向 capability `cross_model_prompt_optimization`** — LLM-as-Judge + LLM-as-Optimizer + cross-model generator 的完整工程模式（OPRO loop）。包含 workflow（judge/optimizer/generator 三角色分工）、tools（Anthropic SDK / OpenAI SDK / promptfoo / DSPy）、quality_criteria（generator 必须与生产一致 / judge ≠ optimizer 防 self-enhancement / rubric 至少 2 轮迭代 / holdout 验证）、anti-patterns（model mismatch / same-judge-and-optimizer / rubric 一次定稿）。**(B)** 加 cross-section pollution anti-pattern + capability declaration pattern + 15K char routing-drift limit | (A) toy HANDOFF-20260421-prompt-tuning-design + COMPLETION-20260421 实操提炼；(B) toy 2026-04-22 + my-openclaw | pending | (A) 是**正向主力**：完整 capability 定义，让下一个 LLM 产品项目可 follow；(B) 是 3 个散 anti-pattern/criteria 条目 |
| P4.4 | 扩展 `ai-agent-architecture`: **(A) 正向 capabilities** — Explicit Anti-Pattern Lists in System Prompt（counter LLM hallucination, my-openclaw 实战 × 3 entries）+ Capability Declaration in System Prompt（counter LLM self-awareness gap）+ Fast-Path Safety Layering（performance-tiered safety, toy security）+ Bilingual Blocklist as Minimum（multilingual moderation baseline）。**(B) anti-patterns / criteria** — fail-closed toolset + safety state persistence + prompt-level vs script-level enforcement | (A) my-openclaw code-quality × 3 + toy security.md 2026-04-11；(B) my-openclaw + toy | pending | (A) 4 个正向可复用 capability 是主力；(B) 3 个 anti-pattern/criteria |
| P4.5 | 扩展 `ai-evaluation`: `determinismLevel` 元数据 + mocks-hide-shape anti-pattern + self-enhancement (同 judge + optimizer) 警示 | menu-snap + toy OPRO | pending | |
| P4.6 | project-knowledge README.md: add `cost-observability.md` as 11th category + correct `frontend-design.md` description ("event-triggered, populated when running /playground, not continuous") | menu-snap + Next Guest | pending | 小 doc 更新 |
| P4.7 | 扩展 `ai-tool-integration`: **Parallel CLI Prefetch** capability（background subshell + `wait` + per-agent tmp files，58% 速度提升的通用 bash 模式）+ **Claude Vision OOM Prevention** 规则（对话历史里存 text placeholder，绝不存 base64 字节） | my-openclaw code-quality.md | pending | 2 个正向可复用 capability，都是实战提炼 |
| P4.8 | 扩展 `code-security`: **safe_fetch 7-Layer SSRF Defense Architecture** 作为 reference implementation（scheme → DNS → pin → redirect → body size → content-type → response scan） | my-openclaw security.md 多条 | pending | 完整 7 层防御模板，任何需要服务端 fetch 用户 URL 的场景都可对照 |
| P4.9 | 扩展 `web-deployment`: **"Dashboard-Only" Ops CLI-Resolvable** 思维模式 capability（默认假设 SaaS 的"只能在 dashboard 操作"通常可 REST API / psql / CLI 绕过，给 handoff action item 节省人工操作环节） + **Binary Verify Secrets via `od -c`**（防 shell pipe trailing-newline 注入） | menu-snap arch.md:165 + Next Guest arch.md:66 | pending | 2 个正向工程态度 + 工具规则 |
| P4.10 | 扩展 `web-backend`: **UUID-Scoped Pub/Sub Channel Names** pattern（任何 pub/sub 客户端在 StrictMode / 多订阅者场景下防 topic-sharing silent event loss） | Next Guest arch.md:9 | pending | 通用 pub/sub 工程规则 |
| P4.11 | 扩展 `web-ui-design` 或 `/playground` 文档: **Design Iteration as ADR** pattern（playground 产出作为 design decision ADR：positioning + palette + reference images + iteration log） + **Warm Palette Learning** heuristic（"warm" 不等于 earth tones — 设计词汇解读规则） | Next Guest frontend-design.md × 4 entries | pending | 让 /playground 输出从 "临时设计稿" 升级为 "架构决策记录" |
| P4.12 | 新增 capability（放在 `ai-prompt-engineering` 或 `ai-agent-architecture`）: **"Model Reads, Human Verifies" Pattern** — 不可靠 AI 过滤场景下，让 model 返回**全部**条目+分类标签，human 勾选确认。消除 silent-drop 类错误 | Next Guest arch.md:31 | pending | 正向架构范式 — OCR / LLM 提取 / 分类任务通用 |

### Phase 5: Evolve Data Capture Infrastructure

> 主题：补齐 5 个数据采集缺口中的其他 3 个（P2.1 的 `grounded_in` 已在 Phase 2 做）。让未来 `*evolve` 能自动分析，不用再像 2026-04-24 这样手动 harvest 30 分钟。**本次数据已收集到，此 Phase 的价值在 N 次未来 evolve 里兑现。**

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P5.1 | Handoff frontmatter `gate4_delta` + Alex *accept 时强制填写 | toy OPRO + menu-snap SDK cast — 但 TAD 没有结构化采集过 | pending | Schema: `[{field, alex_said, actual, caught_by}]`。Hook 检查必填 |
| P5.2 | AskUserQuestion capture hook → `.tad/evidence/decisions/*.jsonl` | Data gap #4 | pending | 隐私考虑：只存 options/user-choice，不存 free-text "Other" 内容（或脱敏） |
| P5.3 | `*cancel` command + cancel reason frontmatter + 归档路径 | toy 2026-04-11 experiment-qwen3-omni handoff 被 Z1 migration 静默抛弃 | pending | Cancel reason taxonomy: pivoted / obsolete / superseded / scope-change |
| P5.4 | **Per-Handoff Trace Subdir** 约定标准化 + `trace-digest.sh` for Gate 4 smoke alarm | toy 自发形成的 trace 目录布局，正是 2026-04-15 Epic 1 取消后决定走的"监督层"方向所需的 substrate | pending | 从 Icebox Z.3 升级 — 给 trace 采集加"per-handoff 归口"，让 Gate 4 能扫"该 handoff 是否跳了关键步骤" |

### Phase 6: Assumption Re-Design (v3 candidate)

> 主题：基于 Phase 1-5 实际使用数据，重审 TAD 最核心的假设。可能变成独立 v3 Epic。

| ID | Item | Evidence | Disposition | Notes |
|----|------|----------|-------------|-------|
| P6.1 | 重审"Alex 不写代码"边界 + Blake→Alex feedback 机制 | Assumption C + menu-snap/my-openclaw/toy/Next-Guest 全 4 证据 Blake 反向教育 Alex。**正向反证据（toy arch.md 2026-04-22）**：Alex 12 pre-handoff P0 + Blake 8 Gate 3 Layer 2 P0 = **20 unique 零重叠** — 独立验证两轮 review 是 load-bearing，压缩到一轮会漏一半 P0 类型 | pending | 必须权衡：Blake 反向教育 vs 双轮 review 各找不同 P0 类 — 不是简单合并 |
| P6.2 | Gate 3/4 分工重设计（承认 technical verification 也在 Gate 4） | Assumption D 全 4 项目证据。**正向锚点（menu-snap arch.md:42）**：Staging Smoke as Gate 4 Prerequisite — 当 handoff 触及外部 SDK 响应 shape 时，mocks-only + coverage-only 验收应当**禁止**，必须 staging smoke。这条是 Gate 4 需要正式接管 technical 的具体 capability 之一 | pending | 可能产出：Gate 4 "technical verification matrix" 定义哪些 task_type 必须 staging smoke |
| P6.3 | Domain Pack 分类学审视（横切 vs 垂直维度） | Assumption H + Phase 4.1/4.2 新 pack 涌现 | pending | 21 packs 潜在重组 |
| P6.4 | `*express` path 与 anti_rationalization_registry 一致性审计 | Post-P3.1 delivery | pending | 防 AR-001 regression |
| P6.5 | Phase N / N+1a / N+1b 切分协议规范化 | toy M9 模式 | pending | 加到 handoff_creation_protocol.step2b |
| P6.6 | Cross-project knowledge capture rate 健康阈值 | Next Guest 70% + 需跨项目验证 | pending | 加指标到 `/tad-maintain` 或 `*status` |
| P6.7 | **Partial Gate 4 Acceptance Pattern** 正式化 — 当 handoff 的某些 AC 依赖 external blocker（compliance 审批 / 硬件到货 / 第三方 API）时，允许 accept with partial + explicit roadmap for 剩余 AC | toy arch.md 2026-04-23 + Next Guest compliance lesson | pending | 跟 P6.5 (Phase N+1a/b) 互补：P6.5 是 handoff 拆分，P6.7 是 Gate 4 接受度调整 |
| P6.8 | **Compliance Handoff Scheduling Protocol** — compliance/regulatory 类 handoff 的 Gate 4 验收强制安排在外部 meeting / deadline **≥1 business day 之前**；Gate 4 作为 legitimate spec-revision checkpoint（发现问题还能改） | Next Guest arch.md:16 | pending | 加到 `handoff_creation_protocol`：当 slug/title 含 compliance/regulatory/audit 关键词时触发 scheduling 检查 |

### Icebox (remaining items — defer to Phase 6 scope review)

| ID | Item | Evidence | Disposition |
|----|------|----------|-------------|
| Z.1 | SKILL.md char-count AC (12-15K upper bound) | my-openclaw AGENTS.md bloat; Alex SKILL 未实测 | defer-to-P6 (前置：需先测量 Alex SKILL 实际 char count) |

> Z.2 (Expert Review Audit Trail table) upgraded to P1.5 — 纯模板改动可即刻做。
> Z.3 (trace-digest) upgraded to P5.4 — 配合 Phase 5 trace infrastructure 一起做。

---

## Context for Next Phase

### Completed Work Summary
- Epic created 2026-04-24 from full-context cross-project harvest session (see HARVEST evidence file)
- Phase ordering revised same day — moved state-consistency checks to Phase 1 (was Phase 2), demoted evolve infrastructure to Phase 5 (was Phase 1), because Epic's primary goal is "directly optimize current data" not "enhance future evolve"
- **Phase 4 ✅ DONE 2026-04-25** (commits d2a73a1 + 93fcb50 per BA-P0-2 README LAST sequencing)
  - 21 surgical YAML edits across 8 Domain Packs + 1 README + 2 architecture.md entries
  - **P4.1 cost-observability deferred** (~2-3 months per IDEA-20260419 自身建议) → Phase 4.5 candidate
  - **P4.2 agent-runtime-security redirected** to Security Chain Epic Phase 2 ai-security pack (paused, awaiting real-project audit validation)
  - **DESIGN.md spec integration delivered** (Google Labs Apache 2.0, 2026-04-21) — TAD 走在 Anthropic Issue #1008 之前；新 capability `design_system_documentation` (75-85 lines) in web-ui-design pack
  - **Anti-AI-Slop philosophy delivered** (Anthropic frontend-design Apache 2.0 verified) — verbatim lift with attribution; 2 quality_criteria + 6 anti_patterns added
  - **safe_fetch 7-Layer SSRF reference impl** in code-security + boundary cross-link to ai-security pack (BA-P1-4)
  - **2 new architecture.md entries**: "DESIGN.md Spec Integration as a Type A Capability" + "Anti-AI-Slop Philosophy as a Cross-Pack Quality Bar" — both use P2 Grounded in + Revalidated format (meta-trifecta dogfood)
  - **Process deviations noted** (acceptable):
    1. Blake 没 extract Alex pre-handoff reviews to evidence/reviews/alex/ (P3 same pattern); Alex retroactively extracted from handoff §10 Audit Trail (substance preserved)
    2. AC-G1 `fail-closed` literal grep on architecture.md returns 36 pre-existing legitimate hits — Blake correctly verified via PART 2 diff that Phase 4 added 0 new hook references
    3. Blake P4.4.4 self-caught regression: accidentally deleted 6 pre-existing safety_design.anti_patterns; restored before Gate 3
  - **Over-specific items deferred to Phase 5** (per 2026-04-25 user-Alex strategic review):
    - P4.10 UUID-Scoped Pub/Sub: add `applies_when: [supabase_realtime, react_strictmode]` specificity tag
    - P4.11.3 Design Iteration as ADR: re-anchor to /playground integration (already partial via consume_playground_input)
    - P4.11.4 Warm Palette Rule: 🚩 over-fitting from single Next Guest case — move from Domain Pack to project-knowledge/frontend-design.md
    - **Meta-rule**: "Domain Pack item 必须 ≥2 项目证据;单项目证据进 project-knowledge 不进 Pack" — codify in Phase 6 assumption redesign
- **Phase 3 ✅ DONE 2026-04-25** (commit ff96bd5)
  - 3 tasks delivered: P3.1 *express path (≤3 files + ≥1 review + Audit Trail preserved + AR-001 mechanical SKILL grep anchor) / P3.2 *experiment mode (Gate AUGMENT-not-REPLACE + ai-evaluation pack auto-load + 5 experiment-validity checks) / P3.3 skip_knowledge_assessment frontmatter + Blake override unskip safety net
  - 32/32 ACs satisfied (handoff §4 said "29" — doc-only arithmetic typo, all 32 PASS per Blake self-review + Alex Gate 4 raw count)
  - **CR-P0-4 AR-001 mechanical anchor delivered**: SKILL-text grep `grep -A 30 'express_path_protocol:' | grep -c 'expert review.*code-reviewer'` returns ≥1 (verified 2 by Alex). 防 anti-rationalization 现在有机械验证，不只靠自律
  - **BA-P0-2 AUGMENT not REPLACE delivered**: gate3/4_focus_AUGMENTATION semantics; experiment harness 仍需 build/test/lint，5+4 实验有效性检查是附加。防 "harness syntax error 但 Gate 3 PASS" 类硅
  - **BA-P0-3 symmetric forbidden_implementations delivered**: 5/5/5 across P3.1/P3.2/P3.3。Anti-Epic-1 attack-surface 对称防御
  - **CR-P0-1 anchor canonical fix**: Blake 发现 spec 用 "## Knowledge Updates" 但 canonical (template + 10+ archived completions) 是 "## Knowledge Assessment" → 全替换。1 个 template comment line 14 漏改由 Alex Gate 4 补 (commit pending)
  - 1 new architecture.md entry "Path Layering: Three Defenses Against Single-Path AR-001 Drift" (line 403)
  - **Gate 4 process deviations noted (acceptable):**
    1. Blake deferred backend-architect for HIS Layer 2 (covered by code-reviewer 结构审查; Layer 2 audit PASS at 3 artifacts)
    2. Blake didn't extract Alex pre-handoff reviews to evidence/reviews/alex/ (P1+P2 precedent had this); Alex extracted retroactively in Gate 4 (substance preserved in handoff §10 Audit Trail, 21 rows)
- **Phase 2 ✅ DONE 2026-04-24** (commit 0b2e25d)
  - 2 tasks delivered: P2.1 stale-knowledge-check.sh (282 lines BSD-portable) + Grounded in/Revalidated schema in README + Alex step0_5 #9 advisory invocation; P2.2 Alex SKILL step1c grounding pass (renamed from step0_5b post-CR-P0-1) + handoff template §7.3 Grounded Against placeholder
  - 28/28 ACs satisfied; 55/55 mechanical assertions; real-corpus 47 INFO / 0 ERROR / exit 0 (independently re-derived by Alex Gate 4)
  - **BA-P0-2 alarm fatigue defense delivered**: Revalidated bullet + max(entry_date, revalidated_date) baseline; without this Phase 2 would have collapsed to zero value in 3 months
  - **BA-P0-1 enforcement clarity delivered**: step1c is prompt-level Alex SKILL discipline (mirrors anti_rationalization_registry); forbidden_implementations explicit; Anti-Epic-1 grep verified clean
  - **CR-P0-1 chicken-and-egg resolved**: step0_5b → renamed step1c (placed between step1b and step2 so §6 already exists when grounding fires)
  - 1 new architecture.md entry "Revalidated State Defeats Alarm Fatigue" — meta-trifecta dogfood (uses Grounded in + Revalidated, captures 2 BSD shell traps Blake hit during impl)
  - Phase 2 commit independent of Phase 1 archive moves (verified)
- **Phase 1 ✅ DONE 2026-04-24** (commit 08e9e74)
  - 5 tasks delivered: P1.1 git-tracked Gate 3 check / P1.2 drift-check.sh 393-line tool with 4 subchecks / P1.3 layer2-audit slug truncation / P1.4 router event filter (threshold descoped) / P1.5 handoff template Audit Trail + Supersedes field
  - 33/33 ACs satisfied; 60/60 fixture tests; Phase 2b 30/30 regression preserved
  - Anti-Epic-1 verified clean (zero new fail-closed patterns)
  - Perf: p95=118ms < 200ms budget (raw-TSV recomputed by Alex Gate 4 — matches Blake's report)
  - 2 Knowledge entries added to architecture.md (word-boundary slug matching + drift-check allowlist for shared paths)
  - 2 judgment calls accepted: gate3-git-tracked-check.sh helper script (non-mandated, useful reference impl); drift-check allowlist for `.tad/project-knowledge/`, NEXT.md, etc. (necessary to avoid false positives on cross-handoff shared resources)

### Decisions Made So Far
1. **Single Epic, 6 phases** — Phase 6 flagged as v3 Epic candidate
2. **Phase 1 = State Consistency** (highest ROI direct fix, 4 drift modes + 1 hook bug)
3. **Phase 5 = Evolve Infrastructure** (retained but demoted — it serves future, not current data)
4. **Phase 6 = Assumption Redesign** (requires P1-5 execution data before opening)
5. **Phases 1-5 are mutually independent** — any order OK, parallelism OK
6. **All 20+ proposals retained** with disposition tracking

### Known Issues / Carry-forward
1. **P3.2 `*experiment` scope uncertain** — may need sub-Epic if scope grows (experimental methodology review is a non-trivial design)
2. **P4.2 scope ambiguous** — "new pack vs extend ai-agent-architecture" + potential overlap with paused Security Chain Epic Phase 2 scope. Socratic during Phase 4 handoff drafting.
3. **Z.1 needs measurement first** — claim is from my-openclaw's AGENTS.md; verify against TAD's Alex SKILL before deciding.
4. **Phase 6 is ~2-3 weeks** — likely splits off as independent v3 Epic after Phase 5 accept
5. **Security Domain Pack Chain Epic** (EPIC-20260403) currently paused at Phase 1+0 — evaluate interaction with P4.2 before starting it

### Next Phase Launch Memo (compact-survival)

**Read this first if resuming after compact:** `.tad/evidence/learnings/PHASE5-PREP-20260425.md`

This persists 4 things conversation compact would lose:
1. Phase 4 ROI 自评 (21 items 哪些 useful / 哪些 over-specific)
2. Phase 5 Socratic Q1-Q5 边界决策草案 + Recommended options
3. Process gray zones 3 项 (Alex review extract / Domain Pack 证据规则 / yq vs flat grep) — Phase 6 input
4. User preferences carried forward (auto mode / "自己决定" 倾向 / Recommended-default pattern)

### Next Phase Scope — Phase 5: Evolve Data Capture Infrastructure (8 items: 4 native + 4 inject)

**Native (per Epic Phase Map):**
- P5.1 gate4_delta frontmatter
- P5.2 AskUserQuestion capture hook
- P5.3 *cancel command + reason taxonomy
- P5.4 per-handoff trace subdir + trace-digest.sh

**Inject from Phase 4 strategic review (2026-04-25):**
- P5.5 P4.10 UUID Pub/Sub specificity tag
- P5.6 P4.11.3 Design Iteration ADR re-anchor to /playground
- P5.7 P4.11.4 Warm Palette demote to project-knowledge (over-fit fix)
- P5.8 Codify "Domain Pack item ≥2 项目证据" rule (Phase 6 input)

### Original Phase 1 Scope (kept for archive reference — Phase 1 done)

**What Phase 1 handoff should cover (4 sub-items, all mechanical shell-level changes):**

1. **P1.1 — Blake Gate 3 self-check 加 `git ls-files` 断言**
   - 改动：Blake SKILL.md Gate 3 v2 Layer 1 self-check 段落
   - 逻辑：对 handoff 声明的 production 目录（从 frontmatter 或 implicit scan），跑 `git ls-files <dir>` — wc = 0 → FAIL
   - 边界情况：新项目、纯文档 handoff、generated files 目录（node_modules 等）如何排除

2. **P1.2 — `/tad-maintain` CHECK 扩展为 drift detector**（4 个 subcheck）
   - 改动：`.claude/skills/tad-maintain/SKILL.md`（新 drift detection section）+ 可能新增 `.tad/hooks/lib/drift-*.sh` 工具脚本
   - Subcheck a (slug consistency): 解析 active handoff 的 Required Evidence Manifest，grep 每个 path 的 slug，对比 handoff filename slug
   - Subcheck b (zombie detection): `git log --grep <handoff-slug>` 找 implementing commits，如果有 commits 但 active/ 里还在 → 提议 retrospective *accept
   - Subcheck c (supersedes auto-archive): grep `Supersedes:` field，提议归档被 supersede 的旧 handoff
   - Subcheck d (ghost task precheck): 对 slug 匹配 housekeeping/sync/rsync/cleanup 的 handoff，强制要求 Alex 在 step0_5 读 `git status` / ls 相关目录

3. **P1.3 — layer2-audit.sh slug 宽松化**
   - 改动：`.tad/hooks/lib/layer2-audit.sh`
   - 逻辑：当 strict slug 找不到 evidence dir 时，尝试去掉最后一段 `-xxx` 的变体（e.g., `loop-mpr121-da7280-integration` → `loop-mpr121-da7280`）
   - 新 fixture 覆盖 truncation case

4. **P1.4 — userprompt-domain-router.sh 修复**
   - 改动：`.tad/hooks/userprompt-domain-router.sh`
   - 两个修改：
     - 过滤 event source：从 stdin 的 JSON envelope 检查是否是真实 user prompt（不是 task-notification / subagent-output 等系统事件）
     - 阈值从 ≥2 提升到 ≥3 keywords（reduce false positive）
   - Regression test: 本 session 的 2/14 命中 case 应该不再触发

**Expected Phase 1 acceptance criteria:**
- 4 个 subcheck 在一个测试 handoff 上产生正确 drift 报告（slug / zombie / supersedes / ghost）
- `git ls-files` Gate 3 check 在一个已知未 commit 场景上正确 FAIL
- `layer2-audit.sh` truncation fixture exit 0（原 fixture 继续 exit 1 for 真正 missing case）
- `userprompt-domain-router.sh` 在 task-notification 事件上**不触发**，在真实 user prompt 弱匹配（2/14）上**不触发**，在真实 user prompt 强匹配（≥3）上**触发**

---

## Notes

### Why Phase ordering was revised (2026-04-24, same-day pivot)

Initial draft put "Data Capture Infrastructure" (grounded_in / gate4_delta / AskUserQuestion capture / *cancel) at Phase 1 with rationale "can't improve what you don't measure". User challenged: "Epic 是增强 evolve 还是根据本次数据做优化?"

Honest answer: ~85% of 20+ proposals are **direct optimization from current data** (not dependent on evolve capture). Putting evolve infrastructure first would delay the direct ROI by 1-2 weeks. Evolve is a TAD feature among many — not this Epic's main mission.

Revised ordering prioritizes direct fix ROI:
1. **State Consistency (P1)** — 4 drift modes + hook bug, all today's evidence
2. **Grounding (P2)** — toy OPRO prevention, today's evidence
3. **New Paths (P3)** — Next Guest / toy user needs, today's evidence
4. **Domain Pack (P4)** — menu-snap blueprint, today's evidence
5. **Evolve Infrastructure (P5)** — future-facing, retained but moved after direct fixes
6. **Assumption Redesign (P6)** — requires Phase 1-5 execution data

P2.1 (`grounded_in`, originally bundled with other data-capture items) was separated because it's primarily direct optimization (prevents toy OPRO recurrence) not future-evolve support.

### Why "single Epic" not multiple

User chose single Epic to keep context centralized and `*status` scannable. Phase 6 flagged as v3 candidate; will split off after Phase 5 execution if redesign is warranted.

### Active Epic count after revision

- EPIC-20260403-security-domain-pack-chain (paused at Phase 1+0)
- EPIC-20260424-tad-self-upgrade-from-consumers (this — Planning)
- 1 slot remaining (max 3)

### Subagent approach for future `*evolve`

This harvest used 4 parallel `general-purpose` subagents (Explore agent failed sandbox). Document in Phase 5 or Alex SKILL: **cross-project scanning must use `general-purpose`, not `Explore`**.

### Pivots and adjustments

- **2026-04-24**: Phase ordering revised (see "Why Phase ordering was revised" above). No items added or removed; only their phase grouping changed. All original 20+ proposals retained.
- **2026-04-24 (later same day)**: P4.3 scope expanded. User pointed out that toy's OPRO实践 (using Claude Sonnet as judge+optimizer to tune Qwen prompts) was only captured as anti-patterns in the original P4.3 — but the positive methodology itself (LLM-as-Judge + LLM-as-Optimizer + cross-model generator, aka OPRO pattern) is a reusable engineering pattern that deserves a first-class Domain Pack capability. P4.3 now splits into (A) new `cross_model_prompt_optimization` capability [primary, positive methodology] + (B) the original 3 anti-pattern/criteria extensions [secondary]. This catches a blind spot where cross-project learning defaulted to capturing failures instead of successes.
- **2026-04-24 (evening)**: User called out the systemic version of the same blind spot — "你就再去回过头再扫描一下有没有这几个项目做得好的能够形成pattern的，然后被你遗漏了". Re-scanned the same 4 subagent reports with positive-pattern lens (no new subagent runs, same source data). Surfaced 23 additional patterns (7 framework-level + 16 domain-pack-level). Epic updated: new items P4.7-P4.12 added (ai-tool-integration / code-security / web-deployment / web-backend / web-ui-design / new Model-Reads-Human-Verifies capability); P4.4 description expanded with 4 positive capabilities; P1.5 (Expert Review Audit Trail table) upgraded from Icebox Z.2; P5.4 (per-handoff trace subdir + trace-digest) upgraded from Icebox Z.3; P6.1 / P6.2 gained positive evidence anchors (Dual-Gate Non-Overlap / Staging Smoke Prerequisite); P6.7 (Partial Gate 4 Acceptance) + P6.8 (Compliance Handoff Scheduling) added. Full inventory in HARVEST-20260424.md "Positive Patterns Catalog (Round 2)" section. Total proposals: 20+ (R1) + 23 (R2) = 43+. Round 1 vs Round 2 positive:negative ratio moved from ~1:5 to ~1:1. Meta-lesson for future `*evolve` / harvest work: default to paired extraction (what went wrong + remedy AND what worked + reusable asset) — to be encoded in Phase 5 evolve infrastructure or Alex SKILL.
