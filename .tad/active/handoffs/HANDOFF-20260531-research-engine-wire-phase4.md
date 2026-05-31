---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .claude/skills/alex
  - .claude/skills/research-notebook
  - .tad/hooks
  - .tad/research-notebooks
---

# HANDOFF: Research Engine — Wire Triggering + Lifecycle + Dogfood (Phase 4)

**From:** Alex | **To:** Blake | **Date:** 2026-05-31
**Epic:** EPIC-20260504-goal-driven-research.md (Phase 4/6)
**Priority:** P1

## 1. Executive Summary
TAD's deep-research engine has sophisticated machinery — a dynamic question-tree (adaptive seeds) and cross-model adversarial challenge (Codex+Gemini) — that **is essentially never used**: `grep -rl seed_origin .tad/evidence/research/` = **0**, and adversarial-challenge artifacts exist in only **2 of 25** research dirs. Root cause: in `*research-plan` (alex/SKILL.md) these advanced steps sit behind **opt-in AskUserQuestion gates that default to "跳过/skip"** (Phase 0c, 4c, 5b) and per-seed dynamic generation that nobody triggers. This is the same "built-but-not-wired / paper-machine" failure the `trace-instrumentation-fix` just cured, recurring in the research subsystem.

Phase 4 **wires the engine**: replace the per-gate opt-in/skip with a **complexity-adaptive effort-scaling ladder** (borrowed from Anthropic's multi-agent research findings) that decides — by task complexity — whether to run dynamic seeds and adversarial challenge. Plus two hygiene fixes: a **non-blocking SessionStart hook** that recomputes notebook dormant status (today nothing recomputes it, so notebooks will silently go stale), and archiving the `ai-agent-tutorials` empty-shell notebook (1 source).

NOT in scope (Phase 5): persona perspective-seeding, the 5-dim quality rubric. NOT in scope (deferred): CRAG strip-filtering, separate citation pass, coverage mind-map.

## 3. Requirements (from Socratic Inquiry, 8 Q / 2 rounds)
- R1: Advanced research steps must trigger by **task complexity**, not by an opt-in gate that defaults to skip.
- R2: The effort-scaling ladder simultaneously delivers Anthropic's effort-scaling recommendation (depth calibrated to query type).
- R3: User can still override the auto-classification, but the **default is complexity-derived, not "skip"**.
- R4: Notebook dormant status must recompute passively (no command run required) — via a **non-blocking** hook (never fail-closed; aligns with "Mechanical Enforcement Rejected on Single-User CLI" — this only UPDATES derived state, never blocks).
- R5: Empty-shell notebook (`ai-agent-tutorials`, source_count 1) archived.
- R6: Dogfood proves the wired flow actually fires (trace `seed_origin` ≥1) and produces better output than the 2026-05-05 baseline — on the stale `tad-evolution-research` notebook (refreshes the meta-notebook as a bonus).

## 4. Technical Design

### 4.1 Effort-Scaling Ladder (AC4.1) — the core change
In `.claude/skills/alex/SKILL.md` `research_plan_protocol`, add a classification step that runs in `step4` (execution) **per research item, before Phase 0c**, setting two booleans + a persisted record.

**Classification signals (mutually exclusive, ordered — classify as the LOWEST tier whose criteria are met; default to `comparison` when ambiguous, NOT complex)** — per backend-architect P1-1, vague signals collapse everything to "complex":

| Complexity | EXPLICIT trigger (must match to qualify) | `run_dynamic_seeds` | `run_adversarial_challenge` |
|------------|-------------------------------------------|---------------------|------------------------------|
| **simple** | single fact / narrow API or syntax lookup / 1 KR, answer is a lookup not a judgment | **off** | **off** |
| **comparison** (DEFAULT when ambiguous) | research question explicitly compares-and-recommends across ≥2 named options/tools | **on** | off |
| **complex** | spans ≥3 distinct KRs that are themselves ⬚ incomplete, OR explicit landscape/survey scope | **on** | **on** |

**Persist the classification** (backend-architect P1-4, forward-compat for Phase 5): write `research_complexity: simple|comparison|complex` into the findings file frontmatter under a stable key, so Phase 5's persona-seeding + rubric can read it instead of re-deriving.

**Gate rewire — TWO DIFFERENT mechanisms (the experts' core correction):**
- **Dynamic seeds = INTERNAL NotebookLM, no AR-001 constraint → fully auto by complexity.** Gate **Step 2.5 (Adaptive Seed Generation)** + the per-seed `dynamic_ask_protocol` on `run_dynamic_seeds`. ⚠️ **DISAMBIGUATION (backend-architect P0-2):** the ladder gates ONLY **Step 2.5 dynamic/adaptive seeds**. It must NOT gate **Phase 4 Step 1 (baseline seed question tree)** — that is the core deliverable and must run for ALL tiers, else simple-tier research degenerates to just the Phase 3 report.
- **Adversarial challenge = EXTERNAL CLI, governed by AR-001 → auto-run is now sanctioned by `DR-20260531` carve-out (human-approved).** Phase 0c/4c/5b run iff `run_adversarial_challenge`. Classification + the decision ("will run challenge") MUST be displayed and overridable before execution (the DR-20260531 safety condition replaces the keystroke).

**Cross-model SAFETY carve-out implementation (per DR-20260531 — scoped work in THIS handoff):**
⚠️ **Label disambiguation (backend-architect NEW-1):** "AR-001" is overloaded. The target is the **cross-model `NOT_via_alex_auto` constraint**, NOT the `anti_rationalization_registry` AR-001 pattern (which is "express=review-exempt", UNRELATED — leave untouched).
- Amend `cross_model_awareness.forbidden_implementations` **L487/L488** with the narrow conditional exception, citing `DR-20260531`.
- Add the paired "EXCEPT DR-20260531" note to the `anti_rationalization_registry` **must-scan item (~L6185)** — the prose list item, NOT the AR-001 pattern at ~L6187.
- ⚠️ **The `NOT_via_alex_auto: true` anchor (~L482) stays BYTE-IDENTICAL** (NEW-2) — it's a load-bearing audit-grep target; do NOT edit it.
- ⚠️ SAFETY-entry edit explicitly authorized by the human (DR-20260531). These (L487, L488, L6185 prose) are the ONLY forbidden/safety changes permitted; all other forbidden lines stay byte-identical (AC4.5 enforces bidirectionally).

**Preflight ordering (backend-architect P0-2):** Phase 0c caches `codex_available`/`gemini_available` (run once per execution). If `run_adversarial_challenge=off` short-circuits Phase 0c, 4c/5b must NOT read an unset cached var → place the `run_adversarial_challenge` gate BEFORE the cached-var read in 4c/5b, or run preflight regardless and gate only the invocation.

⚠️ This is a **prompt-protocol** change (editing the protocol text Alex follows), NOT a hook. The classification MUST be presented to the user — Alex SUGGESTS, human can override (adaptive_complexity_protocol philosophy + DR-20260531 condition).

### 4.2 Non-Blocking Dormant Recompute Hook (AC4.2)
Grounding finding: dormant status is **already derived at `*list` time** (research-notebook SKILL lifecycle_rules) — but nothing recomputes it passively, so REGISTRY's persisted `status` goes stale. Today (05-31) all 18 are <30d so correctly "active"; they'll cross `dormant_after_days: 30` (config-workflow.yaml:776) in early June with no recompute.

Design: extract the active/dormant recompute into a lib function and call it from a **SessionStart hook** (model: `.tad/hooks/startup-health.sh` — reads stdin JSON, `source != "startup"` → exit, **always exit 0**).
- For each REGISTRY notebook with `status != "archived"`: if `last_queried` older than `dormant_after_days` → set `status: dormant`; else → `active`.
- Threshold read from `.tad/config-workflow.yaml` research_notebook.dormant_after_days (don't hardcode 30).

⚠️ **MUTATION MECHANISM — MANDATORY (code-reviewer P0-1).** REGISTRY.yaml has 18× `status:` at the same indentation across multi-line blocks with rich `notes:`/`sources:`. A naive `sed -i 's/status: active/status: dormant/'` flips ALL 18 or corrupts the file — on EVERY session start. Required:
1. **Structure-aware editor with availability guard**: use `yq` addressing entries by id (`yq '(.notebooks[] | select(.id==$x) | .status) = $s'`). `command -v yq` MUST be guarded — common.sh probes `jq` only, NOT yq. **If `yq` absent → no-op + exit 0** (never block; dormant recompute simply waits for a *list run). Do NOT fall back to line-based sed.
2. **Atomic write**: compute → write `REGISTRY.yaml.tmp` → `mv` over original (atomic same-fs). NEVER edit in place.
3. **Per-entry targeting**: update only the stale entry(ies); the other 17 must stay byte-identical (verified by AC4.6 multi-entry test).
4. **Concurrency (TAD runs dual terminals by design)**: temp+mv makes each write atomic; last-writer-wins can lose an update but next session recomputes — ACCEPTABLE for derived state. State this explicitly; don't add locking.
5. **BSD-safe date (pin the snippet — code-reviewer P1-1):**
   ```
   lq_epoch=$(date -j -f "%Y-%m-%d" "$last_queried" "+%s" 2>/dev/null \
           || date -d "$last_queried" "+%s" 2>/dev/null) || continue   # parse fail → skip
   age_days=$(( ( $(date "+%s") - lq_epoch ) / 86400 ))
   ```
   Handle boundary (define `>` vs `>=` dormant_after_days), future dates, and malformed `last_queried` (→ skip, never crash).
- NEVER fail-closed: any parse error → skip that notebook, `|| true`, exit 0. Updates a derived field only; MUST NOT block session start or any tool call, MUST NOT contain an executable `exit 1` or emit a `"deny"` decision.

### 4.3 Archive Empty Shell (AC4.3)
`ai-agent-tutorials` (notebook_id 037c8e7d…, source_count 1) → set `status: archived` in REGISTRY (user-set archived state per lifecycle rules; do NOT delete the cloud notebook).

### 4.4 Dogfood — split Blake/Alex (AC4.4)
⚠️ `*research-plan` is an **Alex command**. Terminal isolation: Blake implements + provides a reproducible runbook + a mechanical smoke; **Alex executes the full dogfood at Gate 4** (it validates user-facing behavior = Gate 4 v2 business acceptance).
- **Blake (this handoff)**: (a) mechanical smoke — feed 3 sample research items (one per complexity tier) through the classification logic and show it routes to the correct seeds/challenge booleans; (b) write a dogfood runbook: exact steps for Alex to re-run `tad-evolution-research` through the wired `*research-plan`.
- **Alex (Gate 4)**: run the runbook; verify trace shows `seed_origin` ≥1 + adversarial challenge artifacts produced; compare output vs `.tad/evidence/research/2026-05-05-tad-evolution-deep-ask-findings.md`.

## 6. Files to Modify / Create
- `.claude/skills/alex/SKILL.md` — MODIFY `research_plan_protocol` (add classification step + persist `research_complexity` + rewire Phase 0c/4/4c/5b gates) AND amend `forbidden_implementations` L487/L488 + anti_rationalization_registry must-scan item with the `DR-20260531` carve-out (⚠️ SAFETY edit, human-authorized). ~50 lines.
- `.claude/skills/research-notebook/SKILL.md` — MODIFY: extract dormant recompute into a documented lib-callable rule (or reference the new hook). Minimal.
- `.tad/hooks/lib/notebook-lifecycle.sh` — CREATE: recompute function (BSD-safe, exit 0).
- `.tad/hooks/startup-health.sh` OR a new `.tad/hooks/notebook-dormant-sync.sh` — wire the recompute into SessionStart. Prefer a SEPARATE hook file to keep startup-health focused; register in `.claude/settings.json` SessionStart.
- `.tad/research-notebooks/REGISTRY.yaml` — MODIFY: archive `ai-agent-tutorials`.

**Grounded Against** (Alex step1c actual reads, 2026-05-31):
- `.claude/skills/research-notebook/SKILL.md` lifecycle_rules (states/derivation already exist — recompute logic to extract)
- `.tad/config-workflow.yaml:774-779` (dormant_after_days: 30, archive_suggest_after_days: 90)
- `.tad/hooks/startup-health.sh` head (SessionStart pattern: stdin JSON, source-check, always exit 0)
- `.tad/hooks/lib/` (existing lib pattern; common.sh available)
- `.tad/research-notebooks/REGISTRY.yaml` (18 notebooks, ai-agent-tutorials source_count 1)
- `research_plan_protocol` in alex/SKILL.md (current opt-in gates: Phase 0c/4c/5b AskUserQuestion "执行/跳过")

## 9. Acceptance Criteria
- [ ] AC4.1: `research_plan_protocol` has a complexity-classification step setting `run_dynamic_seeds`/`run_adversarial_challenge` + persisting `research_complexity`; signals are mutually-exclusive/ordered, default `comparison` when ambiguous. Classification displayed + overridable (DR-20260531 condition).
- [ ] AC4.1b (gate-audit — backend-architect P0-2): EVERY reference to Phase 0c/4c/5b challenge gating reads `run_adversarial_challenge`; Step 2.5 reads `run_dynamic_seeds`; **Phase 4 Step 1 baseline seed tree is NOT gated** (runs all tiers). Preflight cached-var read survives `run_adversarial_challenge=off`.
- [ ] AC4.2: New SessionStart hook recomputes status (active/dormant) from `last_queried` vs config `dormant_after_days`; non-archived only; structure-aware write (yq + availability guard); atomic temp+mv; always exit 0.
- [ ] AC4.3: `ai-agent-tutorials` status → archived; its `last_queried`/`sources` body PRESERVED (archive ≠ delete).
- [ ] AC4.4 (Blake portion — **PARTIAL by construction at Gate 3**, backend-architect P1-3): documented manual-trace smoke (3 items → printed boolean tuples) + dogfood runbook whose every Bash cmd Blake dry-runs for syntax + path/notebook-id existence. The real `seed_origin ≥1` fire criterion is **Gate-4-deferred** (Alex runs `*research-plan`); COMPLETION gate3_verdict reflects AC4.4 as PARTIAL.
- [ ] AC4.5 (BIDIRECTIONAL line-set diff, NOT count — code-reviewer P0-2 + Q4): (a) FORWARD — every pre-impl forbidden_implementations / NOT_via_alex_auto LINE still present post-impl EXCEPT L487/L488; (b) REVERSE — the only post-impl forbidden lines NOT in baseline are exactly L487/L488 (no silently-added/reworded forbidden lines); (c) POSITIVE — the 2 amended lines each `grep -F 'DR-20260531'`; (d) `NOT_via_alex_auto: true` anchor line byte-identical. Any other forbidden line removed/added/reworded = FAIL.
- [ ] AC4.6 (multi-entry hook test — code-reviewer P0-1): on a TEMP COPY of REGISTRY with 1 stale + several recent `last_queried`, hook flips EXACTLY the stale one to dormant, leaves others byte-identical, file stays valid YAML.

### 9.1 Spec Compliance Checklist (Verification)
| AC | Verification Method (raw cmd) | Type |
|----|-------------------------------|------|
| AC4.1 | `grep -c 'run_dynamic_seeds\|run_adversarial_challenge\|research_complexity' .claude/skills/alex/SKILL.md` ≥ 6 (table + gates + persist) | post-impl |
| AC4.1b | manual: each of Phase 0c/4c/5b sections contains `run_adversarial_challenge`; Step 2.5 contains `run_dynamic_seeds`; Phase 4 Step 1 does NOT | post-impl |
| AC4.2 | `bash -n .tad/hooks/notebook-dormant-sync.sh; echo exit=$?` = 0 | post-impl |
| AC4.2 | hook contains NO executable exit-1: `grep -cE '^[[:space:]]*exit 1' hook` = 0 AND no `"deny"` JSON emission (substring `deny` in a comment is OK — anchor to JSON, code-reviewer P1-3) | post-impl |
| AC4.3 | `awk '/id: "ai-agent-tutorials"/,/source_count/' REGISTRY.yaml \| grep -c 'status: archived'` = 1 | post-impl |
| AC4.5 | pre-impl: `grep -n 'NOT_via_alex_auto\|forbidden_implementations\|MUST NOT' alex/SKILL.md > /tmp/forbidden-baseline.txt`; post-impl: every baseline line still matches EXCEPT the 2 DR-20260531 amendments (`comm`/`grep -F -f` line-set check, not `-c`) | post-impl |
| AC4.6 | temp-copy multi-entry test (above); assert exactly 1 status change via `diff` | post-impl |

### AC Dry-Run Log (Alex step1d, 2026-05-31)
- AC4.5: ✅ pre-impl baseline captured — `grep -c 'NOT_via_alex_auto\|forbidden_implementations' alex/SKILL.md` = **17**. Blake MUST keep ≥17 post-impl (no forbidden block removed).
- AC4.1: ✅ pre-impl baseline — `grep -c 'run_dynamic_seeds\|run_adversarial_challenge'` = **0** (not yet present); post-impl expect ≥4. post-impl-verifiable.
- AC4.3: pre-impl `ai-agent-tutorials` status = active; post-impl expect archived. post-impl-verifiable.
- AC4.2: syntax-only pre-impl (`bash -n`) — hook file not yet created; deferred to Gate 3 Layer 1.

## 10. Important Notes / Anti-Patterns
- ⚠️ **Anti-paper-machine**: the whole point is wiring. If after this Blake/Alex still can't get `seed_origin` to fire in the dogfood, the wiring failed — that's a Gate 4 FAIL, not a "ship anyway."
- ⚠️ **Non-blocking hook is load-bearing**: the dormant hook touches "Mechanical Enforcement Rejected on Single-User CLI" — it is ONLY allowed because it updates derived state and never blocks. Any `exit 1` / deny / permissions.deny = VIOLATION.
- ⚠️ **Terminal isolation**: Blake does NOT run `*research-plan` (Alex command). Blake's dogfood = mechanical smoke + runbook; Alex runs the real dogfood at Gate 4.
- ⚠️ Preserve protocol prose exactly around the gates — research_plan_protocol has many anti-AR-001 / forbidden blocks; the rewire MUST keep them.
- ⚠️ Classification must SUGGEST not FORCE (adaptive_complexity philosophy) — display + allow override (DR-20260531 safety condition).
- ⚠️ **Self-trigger (architecture.md 2026-05-30/31)**: COMPLETION/smoke files will contain tokens like `seed_origin`, `run_dynamic_seeds`, `"deny"`, `exit 1`. Do NOT write the bare strings `exit 1` or `deny` in the hook's COMMENTS (the AC4.2 verifier anchors to executable forms, but paraphrase in comments anyway — "never returns a block decision"). Paraphrase parser-trigger tokens in prose evidence.
- ⚠️ **Concurrency**: SessionStart hook writes REGISTRY.yaml while TAD runs dual terminals (Alex T1 / Blake T2). temp+mv keeps each write atomic; last-writer-wins is acceptable (next session recomputes derived state). No locking.
- ⚠️ **AC4.6 test on a TEMP COPY** of REGISTRY, never the live file (idempotent, re-runnable, doesn't mutate real registry).

## 11. Decision Summary
| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Triggering mechanism | Complexity-adaptive effort-scaling | Fixes 0/2 usage AND delivers Anthropic effort-scaling in one change |
| 2 | Quality gate (Phase 5) | Reuse Codex+Gemini, advisory | (Phase 5) reuse existing challenge infra; non-blocking per single-user CLI |
| 3 | Perspective (Phase 5) | Generate personas | Lightweight, no external corpus needed |
| 4 | Lifecycle mechanism | Non-blocking SessionStart hook | Only updates derived state; doesn't violate anti-mechanical-enforcement |
| 5 | Adoption (Phase 6) | Right-moment trigger, not usage-count | Some projects legitimately don't need research |
| 6 | Scope/rollout | TAD-main first + dogfood, then *sync | Don't push unvalidated changes to 14 projects |
| 7 | Dogfood target | Re-run stale tad-evolution-research | Validates + refreshes the 26-day-stale meta notebook |
| 8 | Deferred mechanisms | CRAG / citation pass / mind-map → future phase | Validate first 3 buckets before adding more |
| 9 | Challenge auto-run vs AR-001 SAFETY | **Option B — carve-out via DR-20260531** (human-authorized) | Dynamic seeds auto-fire (internal); challenge auto-runs only inside *research-plan with displayed+overridable classification |

## Audit Trail (Expert Review — code-reviewer + backend-architect)
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| backend-architect | P0-1: auto-run challenge violates AR-001 NOT_via_alex_auto | §4.1 DR-20260531 carve-out + AC4.5 line-diff; DR-20260531 ADR | Resolved (human chose B) |
| backend-architect | P0-2: gate-rewire not atomic; Step 2.5 vs Phase 4 baseline conflation; preflight ordering | §4.1 disambiguation + AC4.1b gate-audit | Resolved |
| code-reviewer | P0-1: REGISTRY in-place mutation unspecified (sed flips all 18 / corrupts) | §4.2 yq+guard+atomic temp+mv+per-entry + AC4.6 | Resolved |
| code-reviewer | P0-2: AC4.5 count vs "unchanged" contradiction | §9 AC4.5 → line-set diff | Resolved |
| backend-architect | P1-1: signals collapse to "complex" | §4.1 mutually-exclusive ordered, default comparison | Resolved |
| backend-architect | P1-4: Phase 5 must re-derive complexity | §4.1 persist `research_complexity` key | Resolved |
| backend-architect | P1-3: AC4.4 unverifiable at Gate 3 | §9 AC4.4 PARTIAL-by-construction + runbook dry-run | Resolved |
| code-reviewer | P1-1: pin BSD date snippet | §4.2 pinned snippet | Resolved |
| code-reviewer | P1-3: substring-trap in exit/deny grep | §9.1 anchored to `^exit 1` + JSON `"deny"` | Resolved |
| code-reviewer | P2-4: archive must preserve body | §9 AC4.3 preserve sources | Resolved |
| both | P2: self-trigger (handoff tokens in evidence) | §10 paraphrase note | Resolved |

## 12. Project Knowledge (Blake 必读历史教训)
- **Observational > Imperative Trace Emission** (architecture.md 2026-05-30): the paper-machine pattern this Phase fixes; emission/wiring must be structurally reliable not "remember to call."
- **A Parser Feeding a Review Queue Must Propagate VALUE** (architecture.md 2026-05-31): the dream-scanner sibling lesson — built ≠ wired.
- **Mechanical Enforcement Rejected on Single-User CLI** (architecture.md 2026-04-15, SAFETY): the dormant hook is the allowed exception — UPDATES state, never blocks. Keep it non-fail-closed.
- **Hook Shell Portability Rules** (architecture.md 2026-04-03): BSD `date -j`, no `grep -P`, `|| true` on parse paths, exit 0 always.
- **Two-Layer Compact Recovery / SessionStart pattern**: model the hook on startup-health.sh (stdin JSON, source-check, exit 0).

## Required Evidence Manifest
```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/research-engine-wire-phase4/code-reviewer.md
  - .tad/evidence/reviews/blake/research-engine-wire-phase4/backend-architect.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict (pass|fail|partial)
completion: .tad/active/handoffs/COMPLETION-20260531-research-engine-wire-phase4.md
smoke_evidence: .tad/evidence/acceptance-tests/research-engine-wire-phase4/classification-smoke.md
dormant_recompute_smoke: .tad/evidence/acceptance-tests/research-engine-wire-phase4/dormant-recompute-smoke.md
dogfood_runbook: .tad/evidence/acceptance-tests/research-engine-wire-phase4/dogfood-runbook.md
adr: .tad/decisions/DR-20260531-ar001-research-challenge-carveout.md
knowledge_updates: project-knowledge entry if any wiring lesson surfaces
```

## Blake Instructions
- Standard TAD (not express). Socratic done (Alex). Run Layer 1 (`bash -n` on hook; grep ACs) + Layer 2 (≥2 experts: code-reviewer + backend-architect — protocol rewire + shell hook both need review).
- Implement → Gate 3 → write COMPLETION + gate3_verdict marker.
- Do NOT run `*research-plan` (Alex command). Provide the mechanical smoke + dogfood runbook; Alex runs the real dogfood at Gate 4.
- If wiring the gates turns out to require changing a forbidden/NOT_via_alex block → STOP, escalate to Alex (would change a protocol contract).
