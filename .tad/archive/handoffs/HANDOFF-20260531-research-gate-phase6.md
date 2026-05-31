---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .claude/skills/alex
---

# HANDOFF: Research-Gate Strengthening (Epic goal-driven-research Phase 6/6 — PART A only)

**From:** Alex | **To:** Blake | **Date:** 2026-05-31
**Epic:** EPIC-20260504-goal-driven-research.md (Phase 6/6)
**Priority:** P2
**⚠️ SCOPE: research-gate ONLY (AC6.1/AC6.2). `*sync` rollout (AC6.3) is DEFERRED by explicit human decision — do NOT sync.**

## 1. Executive Summary
The *discuss audit found research adoption is **3/14 projects** — not because the engine is bad, but because **nothing prompts the user to research at the decision moment**. Existing gates fire elsewhere: STEP 3.8 at activation (objective-alignment scan), research_decision_protocol "research before designing." The gap: inside *analyze, when a technical decision genuinely **depends on external information the agent doesn't have**, there's no active nudge to create a notebook / run *research-plan.

Phase 6 Part A strengthens the *analyze research-gate: **right-moment trigger, NOT usage-count**. When a decision is classified as external-info-dependent AND no relevant notebook exists → actively suggest research. Critically, a **negative guard** ensures config/preference/internal-only decisions do NOT trigger (the audit showed some projects legitimately don't need research — a download-plugin doesn't need market research).

## 4. Technical Design
In `.claude/skills/alex/SKILL.md` `research_decision_protocol`, add a **research-gate** at the **TAIL of `step1_identify_decisions`** (explicit placement — backend-architect P2; runs after decisions are identified, before step2_research). Wrap the new block in stable anchor comments `<!-- research-gate:BEGIN -->` / `<!-- research-gate:END -->` (so AC verification can scope greps — code-reviewer P1-1).

**Classification — DEFAULT-SAFE decidability test (NOT an example list — both reviewers P1):**
The single discriminating rule: **"Is this decision decidable from the repo + requirements alone?"**
- YES (or ambiguous) → **NO gate** (default silent). Covers config values, naming, code style, refactor mechanics, pure preference.
- NO — it provably turns on a fact absent from repo+requirements (which library/vendor, what production systems do for X, current best approach, competitive/market/domain landscape) → eligible to trigger.
Ambiguity defaults to NO-gate (default-safe, mirrors Phase 4 effort-scaling "default to the lower tier").

**De-dup mechanism (backend-architect P0 — a DEFINED session-memory flag, not prose):**
Introduce a conversation-memory set `declined_research_domains` (session-scoped). The gate:
1. Before firing, check: is this decision's domain already in `declined_research_domains` OR did STEP 3.8 / `research_notebook_awareness` already surface a notebook-gap for this domain THIS session? → if yes, **do NOT re-prompt** (silent).
2. On user decline, ADD the domain to `declined_research_domains`.
Add a one-line cross-reference in STEP 3.8 and `research_notebook_awareness` sub-step 4: "on decline, append the domain to `declined_research_domains` (honored by research_decision_protocol research-gate)." This makes the four nudge sites share one declined-list — the dedup is mechanizable, not aspirational.

**REGISTRY lookup (both reviewers P1):** REUSE `step2_5_notebook_check`'s REGISTRY result rather than a second independent scan; cross-reference it in-text (avoid divergent lookups).

When eligible AND no relevant notebook exists (per the reused step2_5 lookup) AND domain not in declined-list → AskUserQuestion:
"决策 '{decision}' 依赖外部信息，当前没有相关 notebook。要先研究吗？"
Options: "创建 notebook + *research-plan (Recommended)" / "WebSearch 够了" / "我已了解，直接设计".
- SUGGESTION only (Alex suggests, human decides) — MUST NOT block design if declined.
- Right-moment = at decision-identification inside *analyze, not a blanket activation nudge.
- **Decline-write (backend-architect N2):** BOTH non-create options ("WebSearch 够了" AND "我已了解，直接设计") count as notebook-decline for this domain → write to `declined_research_domains` (so a WebSearch choice doesn't re-prompt the same domain).
- ⚠️ **Self-leak wording (code-reviewer NEW-2):** write the gate's non-blocking/dedup logic with NEUTRAL verbs ("skip", "stay silent", "suggestion only") — do NOT use `block`/`deny`/`return fail` in the gate prose, or AC6.4's scoped grep false-fails on its own documentation.

## 6. Files to Modify
- `.claude/skills/alex/SKILL.md` — MODIFY: (a) `research_decision_protocol` step1 tail — add research-gate (anchor-commented) + default-safe decidability test + de-dup check + reuse step2_5 REGISTRY result; (b) STEP 3.8 + `research_notebook_awareness` sub-step 4 — one-line each: append declined domain to `declined_research_domains`. ~30 lines total.

**Grounded Against** (Alex step1c, 2026-05-31, post-Phase-5 main):
- `.claude/skills/alex/SKILL.md:2700` research_decision_protocol, `:2712` step1_identify_decisions
- `:178` STEP 3.8 (activation-time objective scan — the existing nudge the gate complements, NOT duplicates)
- `:885` research_notebook_awareness (*discuss — different entry point)

## 9. Acceptance Criteria
- [ ] AC6.1: research-gate (anchor-commented `<!-- research-gate:BEGIN/END -->`) at step1 tail; when a decision fails the decidability test AND no relevant notebook exists, suggests create-notebook/*research-plan via AskUserQuestion (suggestion, non-blocking).
- [ ] AC6.2: DEFAULT-SAFE guard — the contract is the decidability test ("decidable from repo+requirements alone → no gate; ambiguous → no gate"), NOT just an example list. Default silent; fires only on provable external-info dependence.
- [ ] AC6.3 (DEFERRED — do NOT implement): *sync rollout to 14 projects. Leave Phase 6 sync as Planned.
- [ ] AC6.4: no SAFETY/carve-out edit — `grep -c 'DR-20260531' .claude/skills/alex/SKILL.md` = 9, `NOT_via_alex_auto: true` = 1, `codex exec --full-auto`=3, `gemini -p`=3 (unchanged); no new hook; gate region (between anchors) has no block/deny.
- [ ] AC6.5 (de-dup — backend-architect P0): `declined_research_domains` session-memory set defined; gate checks it (+ STEP 3.8 / research_notebook_awareness prior-surface) before firing and writes on decline; STEP 3.8 + research_notebook_awareness sub-step 4 each append to it. No double-prompt for the same domain in one *discuss→*analyze session.

### 9.1 Spec Compliance Checklist
| AC | Verification (raw cmd) — baselines DR=9, anchor=1, codex/gemini=3/3 | Type |
|----|------------------------|------|
| AC6.1 | `grep -c 'research-gate:BEGIN' SKILL.md`=1; gate region (sed `/research-gate:BEGIN/,/research-gate:END/`) contains AskUserQuestion + "依赖外部信息" | post-impl |
| AC6.2 | literal (code-reviewer NEW-1): `sed -n '/research-gate:BEGIN/,/research-gate:END/p' SKILL.md \| grep -c 'decidable from'` ≥1 AND "ambiguous" appears in region | post-impl |
| AC6.3 | Phase 6 map row sync still ⬚/deferred; `grep -c '\*sync' ` in gate region = 0 | post-impl |
| AC6.4 | `grep -c 'DR-20260531' SKILL.md`=9 AND `NOT_via_alex_auto: true`=1 AND `codex exec --full-auto`=3 AND `gemini -p`=3; gate region: `sed -n '/research-gate:BEGIN/,/research-gate:END/p' SKILL.md \| grep -cE 'BLOCK\|deny\|return.*fail'`=0 (SCOPED — code-reviewer P1-1) | post-impl |
| AC6.5 | region-scoped (backend-architect N1 — avoid prose-mention self-match): gate region (`sed /research-gate:BEGIN/,/research-gate:END/`) has ≥2 `declined_research_domains` (real read+write mechanism, not doc) AND ≥1 append at STEP 3.8 or research_notebook_awareness. Blake spot-verifies the matches are mechanism sites, not rationale comments | post-impl |

## 10. Important Notes
- ⚠️ **Right-moment, not usage-count** (user decision): the goal is to prompt the projects that SHOULD research, NOT to maximize a usage number. The negative guard (AC6.2) is as important as the trigger (AC6.1).
- ⚠️ **Non-blocking**: Alex suggests, human decides — declining MUST proceed to design.
- ⚠️ **Do NOT duplicate STEP 3.8**: the gate fires at decision-identification inside *analyze; STEP 3.8 fires at activation. Complement, don't double-prompt — if STEP 3.8 already surfaced the same notebook gap this session, the gate should not re-nag.
- ⚠️ **No SAFETY edit** (AC6.4): this is unrelated to the cross-model carve-out; leave it untouched.
- ⚠️ **`*sync` is DEFERRED** — do not run it, do not add it. AC6.3 stays Planned for explicit human authorization later.

## 11. Decision Summary
| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Adoption metric | Right-moment trigger, not usage-count | Some projects legitimately don't need research (audit finding) |
| 2 | Gate placement | research_decision_protocol decision-identification | Fires when a decision actually needs external info, inside *analyze |
| 3 | sync rollout | DEFERRED (human decision) | Outward-facing op to 14 projects; explicit authorization required |

## Audit Trail (Expert Review — code-reviewer + backend-architect)
| Reviewer | Issue | Resolution | Status |
|----------|-------|-----------|--------|
| backend-architect | P0: de-dup under-specified, 4 nudge sites, *discuss→*analyze double-prompt | §4 `declined_research_domains` session-memory flag shared across sites + AC6.5 | Resolved |
| code-reviewer | P1-1: AC6.4 non-blocking grep no region (theater) | §4 anchor comments + §9.1 AC6.4 scoped `sed` grep | Resolved |
| code-reviewer | P1-2: double-prompt guard not mechanizable | same as backend-architect P0 (declined-list) | Resolved |
| both | P1: negative guard example-list not default-safe | §4 + AC6.2 decidability-test contract, ambiguous→no-gate | Resolved |
| both | P1: gate REGISTRY check duplicates step2_5_notebook_check | §4 reuse step2_5 result + cross-ref | Resolved |
| backend-architect | P2: step1-vs-step2 placement ambiguity | §4 explicit step1-tail | Resolved |
| code-reviewer | P2: silent-skip option no trace; AC6.4 baselines verified (DR=9,3/3,1) | noted; baselines confirmed | Acknowledged |

## 12. Project Knowledge (Blake 必读)
- **Cognitive Firewall: Embed Into Existing Flows** (architecture.md 2026-02-06): insert the gate into the existing research_decision_protocol, don't create a standalone command.
- **Mechanical Enforcement Rejected on Single-User CLI** (architecture.md 2026-04-15): the gate is a SUGGESTION, never a block.
- the *discuss audit (this session): 3/14 adoption; root cause = no decision-moment nudge; fix = right-moment trigger + negative guard.

## Required Evidence Manifest
```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/research-gate-phase6/code-reviewer.md
  - .tad/evidence/reviews/blake/research-gate-phase6/backend-architect.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict
completion: .tad/active/handoffs/COMPLETION-20260531-research-gate-phase6.md
knowledge_updates: project-knowledge entry if a gate-design lesson surfaces
```

## Blake Instructions
- Standard TAD. Socratic done (Alex, folded from the *discuss audit + Round-1/2 answers). Layer 1 (grep ACs) + Layer 2 (≥2: code-reviewer + backend-architect).
- Implement research-gate ONLY. Do NOT implement/run *sync (AC6.3 deferred). Do NOT touch SAFETY/carve-out.
- Gate 3 → COMPLETION + gate3_verdict. If implementation needs a hook or SAFETY edit → STOP, escalate (out of scope).
