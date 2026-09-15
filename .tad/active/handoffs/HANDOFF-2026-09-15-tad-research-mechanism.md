---
task_id: TASK-20260915-TAD-RESEARCH-MECHANISM
task_type: doc-only
express: false
skip_knowledge_assessment: no
e2e_required: no
research_required: no
status: READY_FOR_GATE2
feedback_required: false
git_tracked_dirs: []
gate4_delta: []
---

# HANDOFF-2026-09-15-tad-research-mechanism

**Task ID**: `TASK-20260915-TAD-RESEARCH-MECHANISM`
**From:** Alex (Terminal 1) **To:** Blake (Terminal 2)
**Created**: 2026-09-15
**Status**: READY_FOR_GATE2 (design only — Blake lands the mechanism files; **no research is executed by Blake**)
**Epic:** N/A
**Mode**: docs/protocol-only. No push / tag / bump / release.
**Design pointer**: `.tad/evidence/research/2026-09-15-tad-research-mechanism-v01-draft.md` (user direction, critically absorbed — not the spec)
**Channel**: Alex ≠ Blake. Dual Gate 2 on disk. Draft reviewers run via explicit subagent prompting (Codex TAD custom agents not yet active).

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-09-15 (Alex design; dual disk reviews recorded §9.2)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Research Track = gate wrapper over the existing `*research --deep` engine. No second pipeline; single deep trigger owner. |
| Components Specified | ✅ | §6.1/§6.2 paste blocks: RG SSOT, 2 templates, 1 reference, `deep_execution` repoint, config block. |
| Functions Verified | ✅ | N/A (no code). MQ2 not triggered. All paths cited exist at HEAD (Grounded Against §6.4). |
| Data Flow Mapped | ✅ | charter → plan → rounds → critic → verdict+sources → Local Wiki canon/wiki. §4.2. |

**Process Gate 2 = dual reviews on disk.** Do **not** wait for a human to type `/gate 2`. Human still says `当 Blake` for role switch.

**Alex确认**: 本 handoff 是设计权威。Blake 只落地文件、不重设计、不跑研究、不碰 Blake/Gate 3/Ralph Loop。

---

## MQ (human lock)

1. **User**: TAD 框架的 Alex（研究/设计侧），不是终端产品用户。
2. **Problem**: TAD 有 9 个研究入口但缺少一条**对标 Build Gate 1-4 的一等 Research 轨道**，产出物薄到"决策人还要自己复核一遍"。根因不是没有引擎（`*research --deep` 已很厚），而是引擎没有正式的门禁与产出契约。
3. **Scope**: 只加一层 **RG1–RG4 门禁契约 + Charter/Critic/Verdict/Sources 契约**，绑定现有 `*research --deep`。
4. **Out**: 不新建研究引擎；不建第二套流水线；不引入新 agent 身份（无 critic skill / 无 AGENTS role 行）；不改 Blake/Gate 3/Ralph Loop；不改 `research/` Local Wiki 脚本；不碰 frozen pack；不发布。
5. **Success**: 决策人拿到 `VERDICT.md` + `SOURCES.md`，看完能直接行动，不必亲手重验。
6. **Teeth**: RG SSOT；dual Gate 2；Alex ≠ Blake。

**Gate 1**: problem / ICP / scope / verifiable ACs — PASS (§9.1 + this lock)。

### MQ evidence

| MQ | Triggered? | Evidence |
|----|------------|----------|
| MQ1 historical | yes | Surveyed all 9 research entries + templates + DR-20260531 (see §4.3 mapping). Reuse `research-plan-protocol` phases, `research-challenge-prompt`, `research-quality-rubric`, `research-decision-brief`. |
| MQ2 functions | no | Docs/protocol only. |
| MQ3 data flow | no | No backend/frontend fields; §4.2 artifact flow only. |
| MQ4 visual | no | No UI states. |
| MQ5 state sync | no | Single SSOT (gate checklist + reference); no duplicated state files. |
| MQ6 research | yes | `.tad/evidence/research/2026-09-15-tad-research-mechanism-v01-draft.md` + repo survey. Options: (A) new pipeline; (B) gate wrapper over existing deep engine; (C) no-op. Human direction = v0.1 draft; Alex chose **B** (fuse). |

---

## 1. Task Overview

### 1.1 What We're Building

TAD 的**一等 Research 轨道**：在现有 `*research --deep` 引擎之上，加一层对标 Build Gate 1-4 的
**RG1–RG4 门禁契约**，并补齐三件真正缺失的产出物——**Charter**（立项）、**Critic Review**（独立对抗）、
**Verdict + Sources**（结论先行 + 可追溯 provenance）。

### 1.2 Why

Research 不缺引擎（`research-plan-protocol.md` 59KB，已有 Phase 0-5、effort-scaling、Codex/Gemini
对抗、rubric、saturation、AC 提取）。缺的是：**入口无契约（"题目" 冒充 "问题"）**、**对抗评审默认跳过且无本地独立路径**、
**终稿无"结论先行 + provenance"契约**。结果就是"研究薄"——决策人不敢直接行动。

### 1.3 Intent Statement

**真正要解决的问题**：让每一次 `*research --deep` 有明确的立项门、对抗门、综合门，且产出可被决策人直接消费。

**不是要做的（避免误解）**：
- ❌ 不是新建第二套研究流水线（v0.1 的 R0–R4 与现有 Phase 0-5 有 ~80% 重叠，本设计拒绝 fork）。
- ❌ 不是引入新 agent 角色 `Critic`（不建 skill、不加 AGENTS role）。
- ❌ 不是让 Blake 参与研究或走 Gate 3/Ralph Loop。
- ❌ 不是重做 Local Wiki / 不碰 `research/` 脚本 / 不碰 frozen pack。

**Blake请确认理解**：这是把设计好的 RG 契约 paste 进 §6.1/§6.2 的文件；不执行研究；不改引擎算法。

---

## 📚 Project Knowledge

**Loaded this knife:** `principles.md`；`patterns/_index.md` → `research-methodology.md`,
`gate-design.md`, `ac-verification.md`, `handoff-design.md`。

### Research Findings (Local Wiki)

Topic: TAD research mechanism consolidation | Local Wiki: `research/canon/_index.md` (2 entries — guardrail-layers, mcp-prompt-injection; **not this topic**) | NotebookLM: unavailable for this repo topic.
Key carriers: `principles.md:103` (execution discipline stays in SKILL body — circular-trigger test);
`patterns/research-methodology.md` (Local Wiki three-layer, Iron Rule, Upstream Entry Pointer Cleanliness);
`DR-20260531` (adversarial-challenge carve-out with display+override).

### ⚠️ Blake 必须注意的历史教训

1. **Execution Discipline Content Must Stay in SKILL Body** (`principles.md`) — the RG routing entry must be a body pointer, not only a reference; otherwise the trigger never fires.
2. **Upstream Entry Pointer Cleanliness** (`patterns/research-methodology.md`) — **one** body trigger owner per `*research --deep`. Do **not** add a second protocol competing with `deep_execution`; repoint the existing entry (Reviewer B P0-1).
3. **Rewiring a Gate's Prose Can Trip a `grep -c` SAFETY Count** (`principles.md`) — do NOT reword `NOT_via_alex_auto: true` / `forbidden_implementations` lines; AC8/AC14 use exact-line anchors.
4. **AI/Human Judgment Domain** (`principles.md`) — do NOT make every research round a human question (rubber stamp). Human owns the 3 RG decisions only; existing engine confirmations are reused unchanged.
5. **Never Hand-Write What an Existing Tool Already Does** (`principles.md`) — reuse `generate.py` for wiki indexes; reuse `search.py` for existing-research checks; reuse the `findings` challenge variant + rubric for the Critic; do not hand-maintain links.
6. **Two-Agent + Four-Gate** (`principles.md`) — research stays Alex-side; do not route through Blake Gate 3.
7. **`grep` 证明"在文件里"，不证明"agent 读得到"** (NEXT.md 判断依据) — keep the RG SSOT ≤ 80 lines; cite it from body.

Pack pointers (not loaded): `academic-research` (active), `research-methodology` (frozen). Do not escalate.

---

## 2. Background

### 2.1 Previous Work — the 9 existing research entries (survey)

| # | Mechanism | Where | Role today |
|---|-----------|-------|-----------|
| 1 | `*research` unified (Quick/Standard/Deep) | `alex/SKILL.md` → `research_unified_protocol` | Entry router; Local Wiki primary, NotebookLM fallback, WebSearch degrade |
| 2 | `research_plan_protocol` (Deep engine) | `alex/references/research-plan-protocol.md` | Phase 0→0class→0c→1→2→3→4/4b/2.5→4c/4b-rubric→4.5→5/5b |
| 3 | `research_decision_protocol` | `alex/references/research-decision-protocol.md` | Design-flow landscape search + Decision Record (`blocking:true`) |
| 4 | `*research status` | `alex/references/research-review-protocol.md` | Portfolio review (Local Wiki health + notebooks) |
| 5 | `research-challenge-prompt.md` | `.tad/templates/` | 3 variants (plan/findings/actions), INSUFFICIENT/ADEQUATE/STRONG |
| 6 | `research-quality-rubric.md` | `.tad/templates/` | 4 scored dims + efficiency advisory; hybrid floor |
| 7 | `research-methodology` pack (frozen) | `.tad/capability-packs/` | 5-phase duplicate of #2 (frozen) — **do not revive**; its dead-end registry / anti-hallucination model are pattern-referenced only |
| 8 | `academic-research` pack / skill | `.tad/capability-packs/` + `.agents/skills/` | Academic-specialized (PRISMA/ScholarEval) — keep |
| 9 | `research-github` + `research-notebook` skills | `.agents/skills/` | Source discovery (canon shim) + NotebookLM CRUD (ask step3_5) |

Also: `research/` Local Wiki toolchain (`search.py`, `ingest.sh`, `lint.sh`, `generate.py`, `wiki/log.md`) and
`research_review_protocol` (`*research status`).

### 2.2 Current State vs Target

- **Have**: a thick Deep engine, Local Wiki Iron Rule, adversarial prompt, rubric, decision-brief, saturation.
- **Missing**: (a) a mandatory **Charter** front-door ("问题 not 题目"), (b) an **availability-independent Critic**
  (today's challenge is Codex/Gemini-only and defaults off below `complex`), (c) a **Verdict+Sources**
  output contract ("决策人可直接行动"), (d) a single **RG SSOT** like `gate-canonical-checklist.md`.
- **Target**: `*research --deep` becomes TAD's Research Track; RG1–RG4 bind to existing phases; only 3 new artifacts.

### 2.3 Dependencies

None at runtime. Files: existing `research-plan-protocol.md`, templates, `config-workflow.yaml`. No new deps.

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: New SSOT `.tad/gates/research-gate-canonical-checklist.md` defining **RG1 Charter Clarity / RG2 Plan Adequacy / RG3 Adversarial Review / RG4 Synthesis & Provenance**, in the same ME/CE style as `gate-canonical-checklist.md`. It is a **sibling** of the Build SSOT (Build untouched). RG checklist items live here **once**; the reference/procedure cites them, never duplicates them.
- **FR2**: New charter template `.tad/templates/research-charter.md` with fields: 决策问题 (a question, not a topic) / 服务哪个决策 / 够深验收线 (verifiable) / 明确不查 / Source 策略 / 轮次预算 / 授权.
- **FR3**: New critic template `.tad/templates/research-critic-review.md` with the 3 duties: **source 抽查** / **反例搜寻** / **缺口分析**. It **reuses/extends** the `findings` variant of `research-challenge-prompt.md` + `research-quality-rubric.md` (no parallel rubric), and adds the independence statement + verdict.
- **FR4**: New reference `.agents/skills/alex/references/research-track-protocol.md` (+ `.claude` mirror) that **wraps** (does not replace) `research-plan-protocol.md`. Boundary (fixed — see §4.1):
  - **RG1** = charter front-door, runs **before** Phase 0.
  - **RG2** = `research-plan` **Phase 0 plan + step2/3 confirmation + Phase 0class effort tier + Phase 0c plan-challenge**.
  - **Rounds** = Phase 4 / 4b / 2.5 (+ saturation).
  - **RG3** = Critic over saved findings (covers Phase 4c / 5b; cross-model optional).
  - **RG4** = Phase 5 + Verdict/Sources + Local Wiki landing.
- **FR5**: The **existing** `deep_execution` body entry in `.agents/skills/alex/SKILL.md` (+ `.claude` mirror) is **repointed** to `research-track-protocol.md` (wrapper → engine). **No second body protocol is added** (single trigger owner). A thin non-circular `load_when` is retained.
- **FR6**: `research-plan-protocol.md` (+ `.claude` mirror) gains a ≤10-line header cross-reference to the RG wrapper. **No restructuring; SAFETY anchors byte-preserved (AC14).**
- **FR7**: `.tad/config-workflow.yaml` gains a **top-level** `research_track:` block (round budget default 3; saturation signals; **critic required for all Deep**; landing paths).
- **FR8**: `.tad/templates/research-decision-brief.md` gains a verdict-first line + `SOURCES.md` pointer. The Standard path (`research_unified_protocol.standard_execution`) is unchanged and remains reconciled via the shared template.
- **FR9**: **No new agent identity**: no `critic` skill file, no AGENTS role row, no Blake changes. Frozen `research-methodology` pack untouched (git diff empty). Its **dead-end registry schema** is reused as a *pattern* for RG1's repeat-research guard without reviving the pack.

### 3.2 Non-Functional Requirements

- **NFR1**: Dual-platform mirrors byte-identical (`cmp` = 0).
- **NFR2**: RG SSOT ≤ 80 lines (Read-window safety).
- **NFR3**: No new external dependency, no auto CLI invocation beyond the existing DR-20260531 carve-out.
- **NFR4**: Every new body protocol block has a **non-circular** trigger (principles.md:103).
- **NFR5**: Exactly **one** body entry owns the `*research --deep` trigger (`research_track_protocol` via the repointed `deep_execution`).

---

## 4. Technical Design

### 4.1 Architecture Overview

```
*research --deep  (single body owner: deep_execution → research-track-protocol.md)
   │
   ▼
[RG1 Charter]      ── human authorize ──▶ RESEARCH-CHARTER.md   (before Phase 0)
   │
   ▼
[RG2 Plan]  = research-plan Phase 0 plan + step2/3 + Phase 0class + Phase 0c (plan-challenge)
   │
   ▼
[Rounds]    = research-plan Phase 4 / 4b / 2.5 (+ saturation) ──▶ ROUND-n.md, *-ask-findings.md
   │
   ▼
[RG3 Critic] = independent session over findings (covers Phase 4c / 5b) ──▶ CRITIC-REVIEW.md
   │             (cross-model Codex/Gemini optional, DR-20260531)
   ▼
[RG4 Synthesis] = Phase 5 + decision brief ──▶ VERDICT.md + SOURCES.md + Local Wiki canon/wiki (lint PASS)
   │
   ▼
human CHECK (accept the decision, not the prose)
```

**Design rule**: `research-track-protocol.md` is the **gate wrapper**; `research-plan-protocol.md` stays the **engine**.
RG2/Rounds are *bindings to existing steps*, not re-implementations. **Phase 0c runs inside RG2** (it challenges the
plan); RG3 covers the findings/actions challenges (4c/5b).

### 4.2 Data / Artifact Flow

| RG | Owner | Trigger | Artifact | Reuses |
|----|-------|---------|----------|--------|
| RG1 | Alex + human | before Phase 0 | `RESEARCH-CHARTER.md` | Q1 decision point, `research-decision-protocol`, `search.py`, dead-end schema (pattern) |
| RG2 | Alex | after RG1 authorize | `RESEARCH-PLAN.md` | Phase 0, step2/3, Phase 0class, Phase 0c |
| Rounds | Alex (mechanical stop) | per round | `ROUND-n.md` + `{date}-ask-findings.md` | Phase 4/4b/2.5, saturation, `wiki/log.md` |
| RG3 | Critic (independent session) + optional Codex/Gemini | after findings saved | `CRITIC-REVIEW.md` + `challenge-*.md` | `research-challenge-prompt.md` (findings/actions), `research-quality-rubric.md`, DR-20260531 |
| RG4 | Alex + human CHECK | after RG3 | `VERDICT.md` + `SOURCES.md` + Local Wiki pages | Phase 5, `research-decision-brief.md`, Local Wiki |

**Landing norms (repo-habit-aligned, authoritative):**
- **Process artifacts** → `.tad/evidence/research/<slug>/` (existing habit). ⚠️ **`.tad/evidence/` is gitignored** (`.gitignore:126`) — these are local working artifacts, not versioned. That is consistent with every existing `.tad/evidence/research/*` run.
- **Durable knowledge** → `research/` Local Wiki (**tracked**): `canon/{type}/{slug}.md` + `wiki/...`; `lint.sh` PASS; `generate.py` sole index writer. **This is the versioned carrier of the verdict.**
- **Optional human-facing published report** → `docs/research/<topic>/` (tracked; new surface, **created on first use only**; **not required by RG4** and **not in the commit set/ACs**). Never conflate with `.tad/evidence/` process artifacts.
- **Do NOT write** `docs/pm/` (single-writer: VM side only).

### 4.3 Fusion Mapping Table (v0.1 draft → existing mechanism → disposition)

| v0.1 draft element | Existing TAD mechanism | Disposition |
|---|---|---|
| R0 Charter (问题 not 题目 / decision served / depth line / scope-out / source strategy) | `research_decision_protocol` step1b (Q1 decision point) + `research-plan` Phase 0 success criteria + `search.py` existing-research check | **Enhance** → new `research-charter.md` artifact + RG1 (front-door, before Phase 0) |
| R1 Plan (decomposition / assumptions / source strategy / round budget) | `research-plan` Phase 0 plan + step2 + step3 confirmation + Phase 0class + Phase 0c | **Reuse (bind)** → RG2; artifact `RESEARCH-PLAN.md`. Phase 0c plan-challenge stays engine-native. |
| R2 Rounds (per-round brief + memo + continue/stop) | `research-plan` Phase 4 ask + 4b CRAG + 2.5 adaptive seeds; saturation (Q3 / Local Wiki 3-signal) | **Reuse + thin add** → `ROUND-n.md` memo; stop = mechanical saturation. R2 is **demoted to a non-gate engine phase**, not a fifth gate. |
| R3 Adversarial (source spot-check / counter-evidence / gap analysis) | Phase 4c/5b + `research-challenge-prompt.md` + `research-quality-rubric.md` | **Enhance** → add native independent **Critic** path (required all Deep); keep Codex/Gemini optional under DR-20260531 |
| R4 Synthesis (verdict-first / confidence + unknowns / linked wiki / SOURCES provenance) | Phase 5 + `research-decision-brief.md` + Local Wiki canon/wiki (`raw_refs` + `provenance`) | **Enhance** → add `VERDICT.md` + `SOURCES.md`; verdict-first rule; Local Wiki is the "linked wiki" layer |
| Critic as separate role/session | none (only cross-model CLI; defaults off below `complex`) | **New** → named **protocol**, not a new agent identity; independent session required; **required for all Deep** |
| v0.1 §5 "Research as Build Phase 0" (verdict feeds Alex Gate 1/2) | `research-plan` step6 Research→Action Bridge + handoff §📚 Research Findings | **Reuse** → RG4 verdict is referenced by the next handoff's §📚 Research Findings (existing carrier); no new wiring |
| Depth hard rules (双源 / source 分级 / 最强反例 / provenance / verdict-first) | rubric D1–D4 + tier table + Iron Rule + QCE "contradictory evidence" | **Reuse** → encode as RG1 acceptance line + RG3 duties + RG4 checklists; no new rubric |
| Dead-end / repeat-research guard (v0.1 implicit) | frozen pack's `.research/dead-ends.yaml` schema | **Reuse as pattern** → RG1 checks `search.py` + a Local-Wiki-log note; do **not** revive the pack |
| `docs/research/<topic>/` layout | `.tad/evidence/research/<slug>/` (process, gitignored) + `research/` (durable, tracked) | **Align** → process local, durable tracked; `docs/research/` optional published only |
| 5 gates R0–R4 | Build Gate 1–4 SSOT pattern (`gate-canonical-checklist.md`) | **Reuse pattern** → RG1–RG4 SSOT; 4 gates not 5 (Rounds is engine phase, not a gate) |

### 4.4 Answers to the v0.1 three open questions

**Q1 — Does Critic need an independent role name?**
**Recommendation: No new agent identity; yes a named protocol + artifact.**
- No `critic` skill, no AGENTS role row, no new persona. Rationale: TAD role-switching is human-triggered and
  adding a third identity requires harness wiring (skill, routing) with no quality gain.
- Independence is achieved by **different session + adversarial prompt + different context/sample**, not by a new name.
  This is a **PROTOCOL** (`research_critic` duty inside `research_track_protocol`) with a fixed output artifact `CRITIC-REVIEW.md`.
- **Same-session self-review is NEVER a valid Critic** → mark `DEGRADED_WITH_APPROVAL`; RG3 does not PASS.
- Cross-model Codex/Gemini remains an *optional augmentation* under the existing DR-20260531 display+override carve-out.
- Precedent: same-harness / different-session reviewers were accepted as valid evidence **within the bounded
  yolo2 Phase 2 scope** (DR-20260827). That DR explicitly does **not** auto-carry to later phases — cite it as an
  **analogy**, not as authority. If the research path relies on this equivalence beyond analogy, record a
  research-scoped decision before RG3 PASS is claimed.

**Q2 — R2 per-round "继续/收": does the human join every round?**
**Recommendation: No. The RG track adds exactly 3 human decision points.**
1. **RG1 charter authorization** (is this the right question / is the depth line right) — human.
2. **Rounds close/deepen shortlist** (收 / 再深一轮 / 转向), consulted **once at close** — human.
3. **Material pivot** (decision served or scope changes) — human.
- Per-round "继续" is decided by **Alex mechanically**: continue while saturation signals are unmet; stop when
  charter answered OR Local Wiki 3-signal saturation (no new topics / `lint.sh` stable / 0 new locators for 2 asks)
  OR round budget exhausted.
- **Reused (not new) engine confirmations**: `research-plan` step3 "user confirm plan" and Phase 0class
  display+override already exist and are retained unchanged. They are **confirmations**, not part of the 3 RG
  decisions. This handoff does not add or remove them.
- Rationale: per-round "对不对" is a *verification question* → Rubber Stamp Effect (`principles.md`). TAD already
  has deterministic saturation; spending human attention per round buys nothing.

**Q3 — Wiki page link maintenance: manual or semi-auto?**
**Recommendation: Semi-auto; reuse `generate.py` as the sole index/link writer.**
- Structural links (topic hubs, per-canon pages, clusters) are **auto-generated**: `_topics.yaml` + `_clusters.yaml`
  → `research/scripts/generate.py --emit all` → `canon/_index.md` + `wiki/index.md` + `wiki/topics/_clusters.md`.
- **Never hand-edit generated indexes** (existing constitution rule; `Never Hand-Write…` principle).
- `lint.sh` enforces the **Iron Rule** (`raw_refs` + locator = citation carriers). It does **not** verify wiki↔wiki
  prose cross-ref correctness — so prose cross-refs are authored minimally by Alex and remain **soft/unverified**.
- Net: humans do **not** maintain links; the machine generates structural links; the human only approves the Verdict.

---

## 5. Implementation Steps (Blake)

1. `git status` vs §6.1+§6.2. Do **not** `git add -A`.
2. Land the 4 new files (§6.1) with the content points below; RG SSOT ≤ 80 lines.
3. Apply the 4 modify hunks (§6.2). For dual-platform files: edit `.agents/...`, then `cp` to `.claude/...`, then `cmp` must be 0.
4. For `research-plan-protocol.md`: **only** add the ≤10-line header cross-reference. Do **not** reword `NOT_via_alex_auto` / `forbidden_implementations` / anti-rationalization / `DR-20260531` lines.
5. `git add --` the §6.2 + §6.1 tracked paths + this handoff. Do not add `docs/pm/`, `NEXT.md`, `PROJECT_CONTEXT.md`, design pointer if untracked.
6. Commit subject must contain `TASK-20260915-TAD-RESEARCH-MECHANISM`. Prove `git diff-tree --name-only -r HEAD` ⊆ §6.1+§6.2 (AC12).
7. Completion report. No push/tag/release.

### 6.1 Create

| Path | Content points |
|------|----------------|
| `.tad/gates/research-gate-canonical-checklist.md` | SSOT. Headers `## RG1: Research Charter Clarity` / `## RG2: Plan Adequacy` / `## RG3: Adversarial Review` / `## RG4: Synthesis & Provenance`. Each: Owner / When / checklist items with Why ME + Why CE. **RG1** (before Phase 0): problem-not-topic; depth acceptance line; scope-out; source strategy; existing-research check (reuse `search.py`, note prior dead-ends). **RG2** (before sourcing): question tree ≥3 decision-anchored; round budget; stop rule; source priority; Phase 0c plan-challenge result. **RG3** (after findings): source spot-check; strongest counter-evidence; charter gap analysis; verdict PASS/CONDITIONAL/FAIL; independence carrier. **RG4** (after RG3): verdict-first; confidence + unknowns; counter-case section; provenance table; Local Wiki `lint.sh` PASS; human CHECK. Note "Research Track is Alex-owned; NOT Build Gate 3". Cross-ref templates by name only (no item duplication). |
| `.tad/templates/research-charter.md` | Fields: `**决策问题**:` (must be a question, not a topic), `**服务哪个决策**:`, `**够深验收线**:` (verifiable), `**明确不查**:`, `**Source 策略**:`, `**轮次预算**:` (default 3), `**已有研究检查**:` (search.py hits / dead-ends), `**授权**:` (human name/date). Short guidance line each; mirror `research-decision-brief.md` tone. |
| `.tad/templates/research-critic-review.md` | Header: independence statement (session id / model / "not the author"). Sections: `## Source 抽查` (table: claim / source / source-actually-says / verdict); `## 反例搜寻` (strongest counter-evidence); `## 缺口分析` (charter questions unanswered); `## Ratings` (INSUFFICIENT/ADEQUATE/STRONG — **reuse `research-challenge-prompt.md` `findings` variant**); `## Quality Rubric` (**cite `research-quality-rubric.md`**, 4 dims — no new rubric); `## Verdict` PASS/CONDITIONAL/FAIL; `## 未解决弱点`. |
| `.agents/skills/alex/references/research-track-protocol.md` (+ `cp` to `.claude/...`) | Protocol key `research_track_protocol:` — description / trigger (`*research --deep`, `*research charter`); RG1→RG4 bindings to `research-plan-protocol.md` phases (explicit step names, no re-implementation; Phase 0c inside RG2); structured `human_decision_points:` block with **exactly 3** entries (`charter_authorization` / `close_shortlist` / `material_pivot`), and a note that engine step3-confirm + 0class-override are reused confirmations; Critic independence rule + DEGRADED rule + **Critic required for all Deep**; cross-model optional (DR-20260531); landing norms (§4.2, incl. `.tad/evidence/` gitignored, durable = `research/`); verdict-first + SOURCES contract; containment list key **`forbidden:`** (NOT `forbidden_implementations`) stating: no new role, no Blake route, no auto external CLI beyond carve-out, no frozen-pack revival. |

### 6.2 Modify (commit set)

1. `.agents/skills/alex/SKILL.md` + `.claude/skills/alex/SKILL.md` (byte-identical):
   - **Repoint the existing `deep_execution` entry** (currently `reference: "references/research-plan-protocol.md"`) to `reference: "references/research-track-protocol.md"` and extend its `load_when` to the RG wrapper. The wrapper then routes to the engine. **Do NOT add a second `research_track_protocol:` body block** — that would create two owners of the `*research --deep` trigger (Reviewer B P0-1). If a distinct key is desired, it must be the **only** body key whose `load_when` names `*research --deep`.
   - Add `charter` to the `*research` command surface + `research` intent explicit commands.
   - Add RG SSOT pointer next to `my_gates` (`.tad/gates/research-gate-canonical-checklist.md`).
   - **Do not add a `forbidden_implementations:` key** in this hunk. **Do not touch** `cross_model_awareness`, `NOT_via_alex_auto: true`, existing `forbidden_implementations` entries, or `anti_rationalization_registry`.
2. `.agents/skills/alex/references/research-plan-protocol.md` + `.claude/skills/alex/references/research-plan-protocol.md`:
   - Insert a ≤10-line header cross-reference: "RG wrapper: see research-track-protocol.md. RG1 charter runs before Phase 0; RG2 = Phase 0 + step2/3 + Phase 0class + Phase 0c; Rounds = Phase 4/4b/2.5; RG3 = Critic over findings (Phase 4c/5b); RG4 = Phase 5 (Verdict+Sources). DR-20260531 unchanged; SAFETY anchors byte-preserved."
   - No other edits.
3. `.tad/config-workflow.yaml`: add a **top-level** `research_track:` block: `enabled: true`, `round_budget_default: 3`, `saturation_signals: [no_new_topics, lint_stable, zero_new_locators_x2]`, `critic_required: all_deep`, `cross_model_challenge_tier_gate: phase_0class`, `critic_independent_session: required`, `landing: {process: ".tad/evidence/research", durable: "research/", published_optional: "docs/research"}`.
4. `.tad/templates/research-decision-brief.md`: add one line above the title block — "**Verdict-first**: 结论第一句 ≤3 句；provenance 见 SOURCES.md（每条结论→来源→检索日期）。"

### 6.3 Out of commit

`docs/pm/**` (single-writer), `NEXT.md`, `PROJECT_CONTEXT.md`, `.tad/brain-index.md`, V6 design pointer (if gitignored),
the optional `docs/research/**` published surface (first use only), `research/**` scripts, `.tad/capability-packs/**`,
`.claude/skills/blake/**`, `.agents/skills/blake/**`, `gate-canonical-checklist.md`, `routing-contract.yaml`, `.tad/config-cognitive.yaml`.

### 6.4 Grounded Against (Alex step1c 2026-09-15)

- `.agents/skills/alex/SKILL.md` (research_unified_protocol, deep_execution, cross_model_awareness, anti_rationalization_registry)
- `.agents/skills/alex/references/research-plan-protocol.md` (Phase 0/0class/0c/4/4b/2.5/4c/5/5b)
- `.tad/templates/research-challenge-prompt.md`, `.tad/templates/research-quality-rubric.md`, `.tad/templates/research-decision-brief.md`
- `.tad/gates/gate-canonical-checklist.md` (SSOT pattern)
- `research/CLAUDE.md`, `research/canon/README.md` (Iron Rule, `generate.py`, `search.py`)
- `.tad/decisions/DR-20260531-ar001-research-challenge-carveout.md`
- `.agents/skills/research-notebook/SKILL.md` (ask step3_5), `.agents/skills/research-github/SKILL.md` (canon shim)
- new files in §6.1 (new — Blake creates)

LSP/graph: skipped (`task_type: doc-only`).

---

## 7. Required Evidence Manifest

```yaml
required_evidence_manifest:
  handoff_id: "HANDOFF-2026-09-15-tad-research-mechanism"
  evidence_files:
    - path: ".tad/active/handoffs/HANDOFF-2026-09-15-tad-research-mechanism.md"
      description: "this handoff (design authority)"
    - path: ".tad/evidence/reviews/2026-09-15-gate2-review-research-mechanism-spec.md"
      description: "Gate 2 Reviewer A — spec/pathspec/AC realism (to be written at human-triggered Gate 2)"
    - path: ".tad/evidence/reviews/2026-09-15-gate2-review-research-mechanism-scope.md"
      description: "Gate 2 Reviewer B — fusion/scope/no-new-role (to be written at human-triggered Gate 2)"
    - path: ".tad/active/handoffs/COMPLETION-2026-09-15-tad-research-mechanism.md"
      description: "Blake completion after pathspec commit"
    - path: ".tad/evidence/reviews/gate3-evidence-tad-research-mechanism.md"
      description: "Blake Gate 3 Layer 1 replay of §9.1"
```

> ⚠️ Gate 2 dual-review evidence files are **not** written by this design turn (constraint: only the HANDOFF file may be touched).
> The two in-conversation review outcomes are recorded in §9.2; the on-disk carriers are the human-triggered Gate 2 step.

---

## 8. Friction / Notes

### 8.4 Friction Preflight

None. Docs-only; `grep`/`awk`/`python3`/`git`/`cmp` present. No new deps, no auth, reviewers spawn as Task.

### 8.5 feedback_required: false

---

## 9. Acceptance Criteria

### AC realism (copy)

- Every landing AC has exactly one legal Verification Method: command | path-check | fixture | rubric-spawn | light-tier N/A+one-line reason.
- Dry-run on live baseline before Gate 2 lock. Post-impl rows must fail **for the right reason** on unmodified tree.
- Known-GOOD must PASS; known-BAD must FAIL.

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| 1 | RG SSOT exists | post-impl-verifiable | `test -f .tad/gates/research-gate-canonical-checklist.md` | exit 0 | (post-impl — baseline: absent, exit 1) |
| 2 | RG SSOT defines RG1–RG4 | post-impl-verifiable | `grep -cE '^## RG[1-4]:' .tad/gates/research-gate-canonical-checklist.md` | 4 | (post-impl — baseline 0) |
| 3 | RG SSOT ≤ 80 lines | post-impl-verifiable | `test "$(wc -l < .tad/gates/research-gate-canonical-checklist.md)" -le 80` | exit 0 | (post-impl — baseline file absent) |
| 4 | Charter template exists + required tokens | post-impl-verifiable | `python3 -c "import pathlib; t=pathlib.Path('.tad/templates/research-charter.md').read_text(); need=['决策问题','够深验收线','明确不查','Source 策略','已有研究检查']; print(sum(x in t for x in need)); raise SystemExit(0 if all(x in t for x in need) else 1)"` | exit 0; printed 5 | (post-impl — baseline exit 1) |
| 5 | Critic template has 3 duties + reuse pointers | post-impl-verifiable | `python3 -c "import pathlib; t=pathlib.Path('.tad/templates/research-critic-review.md').read_text(); need=['Source 抽查','反例搜寻','缺口分析','research-challenge-prompt.md','research-quality-rubric.md']; print(sum(x in t for x in need)); raise SystemExit(0 if all(x in t for x in need) else 1)"` | exit 0; printed 5 | (post-impl — baseline exit 1) |
| 6 | Research-track reference exists in BOTH platforms, byte-identical | post-impl-verifiable | `cmp .agents/skills/alex/references/research-track-protocol.md .claude/skills/alex/references/research-track-protocol.md` | exit 0 | (post-impl — baseline: absent) |
| 7 | RG wrapper is reachable from body with non-circular trigger, no duplicate owner | post-impl-verifiable | `python3 -c "import pathlib,re; t=pathlib.Path('.agents/skills/alex/SKILL.md').read_text(); n=t.count('*research --deep'); owners=[m.group(0) for m in re.finditer(r'research_track_protocol:|deep_execution:', t)]; refs=t.count('references/research-track-protocol.md'); print('owners=',owners,'deep=',n,'refs=',refs); raise SystemExit(0 if (refs>=1 and n>=1) else 1)"` | exit 0; refs ≥1; the `*research --deep` trigger appears in exactly one body protocol owner | (post-impl — baseline: refs=0; deep_execution references engine directly) |
| 8 | SAFETY anchors preserved in SKILL.md (exact-line, body-scoped) | pre-impl-verifiable | `python3 -c "import pathlib; t=pathlib.Path('.agents/skills/alex/SKILL.md').read_text(); print(t.count('NOT_via_alex_auto: true'), t.count('DR-20260531'), t.count('forbidden_implementations'), t.count('anti_rationalization_registry')); raise SystemExit(0 if (t.count('NOT_via_alex_auto: true')==1 and t.count('DR-20260531')>=3 and t.count('forbidden_implementations')==4 and t.count('anti_rationalization_registry')>=1) else 1)"` | exit 0; printed `1 3 4 5` (baseline) | `1 3 4 5` (baseline 2026-09-15) |
| 9 | Config has top-level research_track block | post-impl-verifiable | `grep -cE '^research_track:' .tad/config-workflow.yaml` | 1 | (post-impl — baseline 0) |
| 10 | Decision brief is verdict-first + SOURCES pointer | post-impl-verifiable | `python3 -c "import pathlib; t=pathlib.Path('.tad/templates/research-decision-brief.md').read_text(); raise SystemExit(0 if ('Verdict-first' in t and 'SOURCES.md' in t) else 1)"` | exit 0 | (post-impl — baseline exit 1) |
| 11 | No new agent identity / frozen pack untouched | post-impl-verifiable | `python3 -c "import subprocess; names=[l for l in subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r','HEAD'],text=True).splitlines() if l]; subj=subprocess.check_output(['git','log','-1','--format=%s'],text=True); bad=('capability-packs/','/blake/','AGENTS.md','routing-contract.yaml'); hits=[l for l in names if any(b in l for b in bad)]; print('HITS='+repr(hits)); raise SystemExit(0 if 'TASK-20260915-TAD-RESEARCH-MECHANISM' in subj and not hits else 1)"` | exit 0; HITS=[] | (post-impl — baseline HEAD not this knife, exit 1) |
| 12 | This-knife commit pathspec == expected set | post-impl-verifiable | `python3 -c "import subprocess; exp={'.tad/gates/research-gate-canonical-checklist.md','.tad/templates/research-charter.md','.tad/templates/research-critic-review.md','.tad/templates/research-decision-brief.md','.tad/config-workflow.yaml','.agents/skills/alex/SKILL.md','.claude/skills/alex/SKILL.md','.agents/skills/alex/references/research-track-protocol.md','.claude/skills/alex/references/research-track-protocol.md','.agents/skills/alex/references/research-plan-protocol.md','.claude/skills/alex/references/research-plan-protocol.md','.tad/active/handoffs/HANDOFF-2026-09-15-tad-research-mechanism.md'}; names=set(l for l in subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r','HEAD'],text=True).splitlines() if l); subj=subprocess.check_output(['git','log','-1','--format=%s'],text=True); miss=sorted(exp-names); extra=sorted(names-exp); print('SUBJ='+subj.strip()); print('MISSING='+repr(miss)); print('EXTRA='+repr(extra)); raise SystemExit(0 if ('TASK-20260915-TAD-RESEARCH-MECHANISM' in subj and not miss and not extra) else 1)"` | exit 0; MISSING=[]; EXTRA=[] | (post-impl — baseline HEAD not this knife, exit 1) |
| 13 | Exactly 3 RG human decision points, structured | post-impl-verifiable | `python3 -c "import pathlib,re; t=pathlib.Path('.agents/skills/alex/references/research-track-protocol.md').read_text(); m=re.search(r'human_decision_points:(.*?)(?=\n[A-Za-z_]+:|\Z)', t, re.S); blk=m.group(1) if m else ''; need=['charter_authorization','close_shortlist','material_pivot']; print(sum(x in blk for x in need), len([l for l in blk.splitlines() if l.strip().startswith('-')])); raise SystemExit(0 if all(x in blk for x in need) else 1)"` | exit 0; printed `3 3` | (post-impl — baseline: file absent) |
| 14 | research-plan-protocol SAFETY anchors preserved (both mirrors) | pre-impl-verifiable | `python3 -c "import pathlib; a=pathlib.Path('.agents/skills/alex/references/research-plan-protocol.md').read_text(); b=pathlib.Path('.claude/skills/alex/references/research-plan-protocol.md').read_text(); ok=(a.count('DR-20260531')>=7 and a.count('run_adversarial_challenge')>=15 and a.count('NOT_via_alex_auto')>=3 and a==b); print(a.count('DR-20260531'), a.count('run_adversarial_challenge'), a.count('NOT_via_alex_auto'), a==b); raise SystemExit(0 if ok else 1)"` | exit 0; printed `7 15 3 True` | `7 15 3 True` (baseline 2026-09-15) |

### Verification Method grammar

LEGAL: command in backticks | path-check | fixture | rubric-spawn | light N/A.
ILLEGAL: prose-only.

## AC Dry-Run Log (Alex step1d 2026-09-15)

- AC1–7, 9–10, 13: post-impl; baselines absent/exit 1 (right fail: files not yet created).
- AC8 / AC14: pre-impl; baselines `1 3 4 5` and `7 15 3 True` → **PASS on unmodified tree** (known-GOOD SAFETY anchors).
- AC11–12: post-impl; baseline HEAD subject is not this knife → exit 1 (right fail: not this knife). AC12 now checks **both** directions (missing + extra), so a commit that drops an artifact fails.
- Advisory: all Methods are grep/python/cmp/test — `verify-ac-commands.sh` clean.

## 9.2 Expert Review Status

> Dual files on disk = process Gate 2. Not a human `/gate 2` lock.
> **This design turn** (constraint: only the HANDOFF file may be written) ran the two reviews in-conversation.
> Their R1 findings were integrated into this revision; on-disk carriers are produced at the human-triggered Gate 2.

### Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| Reviewer A (Spec/pathspec) | P0: RG1/RG2 Phase 0 ownership self-contradictory | FR4/§4.1/§4.2/§4.3 fixed: RG1 before Phase 0; RG2 = Phase 0+step2/3+0class+0c | CLOSED |
| Reviewer A | P1: `critic_required_for:[complex]` re-creates the gap | §6.2.3 → `critic_required: all_deep`; cross-model remains tier-gated | CLOSED |
| Reviewer A | P1: AC13 near-vacuous token grep | AC13 → structured `human_decision_points:` 3-entry assertion | CLOSED |
| Reviewer A | P1: "§7" mis-cited as commit allow-list; orphan §7.3 | Steps/AC12/§6 title now cite §6.1+§6.2; §7.3 → §6.4 | CLOSED |
| Reviewer A | P1: FR6 anchor unprotected (no AC on protocol file) | AC14 added (both mirrors, DR/run_adversarial/NOT_via counts) | CLOSED |
| Reviewer A | P2: AC7/AC8/AC12 precision | AC7 block-scoped; AC8 adds anti_rationalization; AC12 both-direction set | CLOSED |
| Reviewer B (Fusion/scope) | P0: duplicate `*research --deep` body owner (fusion loophole) | §6.2.1 repoints existing `deep_execution`; no second block; AC7 asserts single owner | CLOSED |
| Reviewer B | P1: `critic_required_for:[complex]` contradicts mandatory RG3 | Same fix as Reviewer A P1 | CLOSED |
| Reviewer B | P1: "3 human decision points" inaccurate (step3/0class are interactions) | §4.4 Q2 distinguishes 3 RG decisions vs reused engine confirmations | CLOSED |
| Reviewer B | P1: DR-20260827 scope-mis-cited as authority | §4.4 Q1 softens to bounded analogy + research-scoped decision requirement | CLOSED |
| Reviewer B | P2: unaccounted mechanisms (dead-end, search.py, standard loop, config SSOT) | §4.3 rows + FR9 + §4.2/§6.3 add dead-end pattern, `search.py`, Standard reconciliation, config SSOT note | CLOSED |
| Reviewer B | P2: `.tad/evidence/` gitignored → process artifacts not versioned | §4.2 makes explicit; durable carrier = tracked `research/` | CLOSED |
| Reviewer B | P2: `forbidden` vs `forbidden_implementations` key trap | §6.1 pins key `forbidden:`; §6.2.1 forbids adding a `forbidden_implementations:` key | CLOSED |

### Experts Selected

1. **Gate 2 Reviewer A — Spec & pathspec** — AC realism, pathspec, SAFETY anchors, dual-mirror. R1 CONDITIONAL (P0×0 in AC harness; 1 P0 + 4 P1 + 5 P2) → **R2 integration CLOSED**.
2. **Gate 2 Reviewer B — Fusion & scope** — no-fork, no-new-role, no Blake route, v0.1 questions. R1 CONDITIONAL (1 P0 + 3 P1 + 8 P2) → **R2 integration CLOSED**.

**Gate 2 结果**: ✅ PASS in-conversation (P0=0 post-integration). ⚠️ On-disk dual carriers still required at human-triggered Gate 2.

---

## 10. Notes

- Do **not** revive the frozen `research-methodology` pack (reuse its dead-end schema as a pattern only).
- Do **not** add a `critic` skill/role; Critic = protocol duty + artifact only.
- Do **not** add a second `*research --deep` body owner; repoint `deep_execution` instead.
- Do **not** route research through Blake/Gate 3/Ralph Loop.
- `gate-canonical-checklist.md` (Build) is untouched; RG SSOT is a **sibling**, not a replacement.
- If RG detail must split, split **procedure** into `research-track-protocol.md`; **never duplicate checklist items** out of the SSOT (single-location rule).
- `.tad/config-cognitive.yaml` (`research_first` / `depth_rules`) remains the design-flow research authority and is unchanged; `research_track:` is the Deep-track config in `config-workflow.yaml`.

## 11. Decision Summary

| Decision | Choice | Source |
|----------|--------|--------|
| Mechanism shape | Gate wrapper over existing `*research --deep` (fuse, not fork) | Survey §2.1 + MQ6 |
| Deep trigger ownership | One body owner: repointed `deep_execution` → RG wrapper | Reviewer B P0-1 |
| Gate boundary | RG1 before Phase 0; RG2 = Phase 0+step2/3+0class+0c; Rounds = engine phase; RG3 = Critic; RG4 = Phase 5 | Reviewer A P0 |
| Number of gates | RG1–RG4 (Rounds demoted to engine phase, not a gate) | v0.1 R0–R4 critical absorption |
| Critic | Named protocol + `CRITIC-REVIEW.md`; no new agent identity; independent session required; **required all Deep** | v0.1 Q1 + Reviewer P1 |
| Human per round | No — 3 RG decisions; engine step3/0class confirmations reused | v0.1 Q2 + Rubber Stamp Effect |
| Wiki links | Semi-auto via `generate.py` + `_clusters.yaml`; lint enforces carriers only | v0.1 Q3 |
| Landing | process `.tad/evidence/research/<slug>/` (gitignored); durable `research/` (tracked); `docs/research/` optional published | repo habit + Reviewer B P2 |
| Cross-model | Optional augmentation under DR-20260531 (display+override) | DR-20260531 |
| Reviewer independence | Same-harness different-session = bounded analogy (DR-20260827), not authority | Reviewer B P1 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-09-15
**Version**: 3.1
