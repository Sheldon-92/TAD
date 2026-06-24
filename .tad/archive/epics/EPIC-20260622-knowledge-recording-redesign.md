# Epic: Knowledge Recording Redesign — Capture / Distill / Maintain

**Epic ID**: EPIC-20260622-knowledge-recording-redesign
**Created**: 2026-06-22
**Owner**: Alex

---

## Objective
Redesign how TAD records knowledge so that what gets written is reusable by a future
zero-context agent, not a session diary. Replace "doer writes finished knowledge at task
end" (which loses to the curse of knowledge) with a three-moment model — **Capture** (doer
writes raw journal), **Distill** (a structural stranger forges a typed entry, unfillable
fields become questions routed back across the bridge), **Maintain** (cheap rule-driven
dedup/retire/reconcile). Grounded in source-level study of Mem0, Letta, AWM, and Anthropic
Skills (see `.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md`).

## Success Criteria
- [ ] A typed playbook-entry schema exists (label + selector-description + bounded value + **required failure_mode** + validator + read_only) with writing rules (variabilize test, keep-invariants-literal, no-relative-time, explain-why-not-musty-MUSTs).
- [ ] Gate 3 KA produces a raw JOURNAL; Gate 4 / *accept runs the **gap-driven cross-bridge distillation loop** (Alex-as-stranger → unfillable fields → questions to Blake → finalize).
- [ ] Maintenance is rule-driven & cheap: hash-dedup, usage-utility retire, ADD/UPDATE/DELETE/NOOP reconcile with DELETE/UPDATE human-gated; a lint enforces schema softly (reminder, not fail-closed).
- [ ] TAD's OWN project-knowledge is migrated to the new schema as the worked reference implementation, and the full loop is validated end-to-end on real TAD knowledge.
- [ ] No 5th knowledge location created — journal=`evidence/`, playbook=`project-knowledge/`; mechanism ships to downstream via pull-based `*publish`, NOT an in-Epic 14-project migration.

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Foundation: schema + writing rules + L1 principle | ✅ Done | HANDOFF-20260622-knowledge-redesign-p1-foundation.md | Typed entry schema, writing-rules doc, before/after variabilize exemplar, entry template, 1 new L1 principle |
| 2 | Capture/Distill cross-bridge loop | ✅ Done | HANDOFF-20260622-knowledge-redesign-p2-distill-loop.md | Rewired Gate 3 KA (journal) + Gate 4/*accept KA (stranger distill + gap hand-back); journal↔playbook physical split |
| 3 | Maintain: dedup/retire/reconcile + lint | ✅ Done | HANDOFF-20260622-knowledge-redesign-p3-maintain.md | Rule-driven maintenance protocol + soft lint + ADD/UPDATE/DELETE/NOOP reconciliation (human-gated mutation) |
| 4 | Dogfood + reference migration on this repo | ✅ Done | HANDOFF-20260622-knowledge-redesign-p4-dogfood.md | TAD's own knowledge migrated to new schema; end-to-end loop validated; ready for `*publish` |

### Phase Dependencies
All phases are sequential: P1 → P2 → P3 → P4. P1 is the contract everything depends on.
P4 validates P1+P2+P3 together on real knowledge (the mechanism's own "stranger test").

### Derived Status
- **Status**: Planning (all ⬚)
- **Progress**: 0 / 4

---

## Phase Details

### Phase 1: Foundation — schema + writing rules + L1 principle

**Status:** ✅ Done
**Execution:** manual
**Handoff:** HANDOFF-20260622-knowledge-redesign-p1-foundation.md (Gate 4 ✅ PASS, 10/10 AC)

#### Scope
Define the typed playbook-entry schema and the writing rules that make an entry reusable,
plus add ONE L1 principle capturing the core inversion. This is documentation/spec + one
principle entry only. NOT in scope: rewiring any Gate KA (P2), building maintenance/lint
(P3), or migrating existing knowledge (P4). No behavioral change to Blake/Alex execution
yet — this phase only establishes the contract later phases consume.

#### Input
- Research findings: `.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md`
- Existing knowledge structure: `.tad/project-knowledge/` (principles.md, patterns/, _index.md)
- Existing templates dir: `.tad/templates/`

#### Output
- `.tad/templates/playbook-entry-schema.md` — the typed entry contract (label, selector-description, bounded value, **required failure_mode**, validator, read_only) with field semantics.
- `.tad/templates/knowledge-writing-rules.md` — variabilize test (with the symmetric "keep invariants literal" rule), no-relative-time, explain-why-not-musty-MUSTs, imperative voice, self-contained.
- A before/after **variabilize exemplar** (one worked example, AWM-style: concrete trajectory → variabilized entry) embedded in the writing-rules doc.
- `.tad/templates/playbook-entry-template.md` — fill-in template.
- ONE new entry in `.tad/project-knowledge/principles.md`: "Knowledge Is Forged at Distill, Not Captured" (doer writes journal; a structural stranger distills; terminal isolation = the stranger firewall). Tagged ⚠️ SAFETY (methodology-core).

#### Acceptance Criteria
- [ ] `playbook-entry-schema.md` exists and defines all 6 fields with semantics; `failure_mode` is explicitly marked REQUIRED with the rationale (it forces the delta to surface).
- [ ] `knowledge-writing-rules.md` contains the variabilize test AND the symmetric keep-invariants-literal rule (both halves, per AWM), plus a concrete before/after exemplar.
- [ ] The new L1 principle is added to principles.md, follows existing principle format, is tagged SAFETY, and keeps principles.md ≤15 entries (consolidate or justify if it would exceed).
- [ ] A `grep` check confirms the writing-rules doc warns against all-caps MUST/NEVER for non-SAFETY entries (Anthropic "yellow flag" rule).
- [ ] No Gate/SKILL execution logic is modified in this phase (verify: `git diff` touches only templates/ + principles.md).

#### Files Likely Affected
- `.tad/templates/playbook-entry-schema.md` (CREATE)
- `.tad/templates/knowledge-writing-rules.md` (CREATE)
- `.tad/templates/playbook-entry-template.md` (CREATE)
- `.tad/project-knowledge/principles.md` (MODIFY — add 1 L1 entry)

#### Dependencies
None (can execute independently — it is the foundation).

#### Notes
- Risk: principles.md is at 14 entries; cap is 15. Adding 1 = 15 (at limit). If the new
  principle pushes a borderline existing entry to look like L2, flag for consolidation — do
  NOT silently exceed 15.
- The schema must NOT become a tax on one-off knowledge: it applies ONLY to entries that pass
  the variabilize test into the playbook. One-off stuff stays raw journal and never sees the schema.

### Phase 2: Capture/Distill cross-bridge loop

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Rewire the Knowledge Assessment so capture and distill are separated across the terminal
bridge. Blake's Gate 3 KA writes a RAW JOURNAL (what happened, append-only) instead of
finished knowledge. Alex's Gate 4 / *accept KA runs the distillation loop: attempt a typed
entry from the journal as a structural stranger; any unfillable schema field becomes a
specific question routed back to Blake (Terminal 2) via the human bridge; Blake answers
(appends to journal); Alex finalizes the entry. Define journal physical home = `evidence/`,
playbook = `project-knowledge/`. NOT in scope: maintenance/dedup/retire (P3), the lint (P3),
migrating existing knowledge (P4).

#### Input
- P1 schema + writing rules + template + L1 principle.
- Current KA protocols: `.claude/skills/blake/SKILL.md` (Gate 3 KA), `.claude/skills/gate/SKILL.md`, `.claude/skills/alex/SKILL.md` (post_review_knowledge / *accept / acceptance-protocol).

#### Output
- Modified Blake Gate 3 KA: emits a raw journal entry to `evidence/` (location + format defined), explicitly NOT a finished playbook entry.
- Modified Alex Gate 4/*accept KA: the gap-driven distillation loop protocol (stranger distill → unfillable-field questions → Blake hand-back → finalize to `project-knowledge/`).
- Defined hand-back format: how Alex's unfillable-field questions are surfaced to the human for relay to Blake, and how Blake's answers re-enter.
- High-stakes escalation: when to spawn Codex as a stricter stranger (vs Alex-as-stranger default).

#### Acceptance Criteria
- [ ] Blake Gate 3 KA no longer instructs writing finished Context/Discovery/Action knowledge; it instructs writing a raw journal to a defined `evidence/` path. Verified by reading the modified SKILL section.
- [ ] Alex Gate 4/*accept KA contains the distillation loop with an explicit step: "for each unfillable schema field, emit a question for Blake" — and a finalize step writing to `project-knowledge/`.
- [ ] The loop protocol names the human bridge explicitly (no Alex→Blake direct call — respects terminal isolation L1).
- [ ] A dry-run walkthrough (documented in completion evidence) traces one real past example (e.g. the audio "swell 40% not 80%" case) through journal→stranger-distill→gap-question→answer→entry, showing the failure_mode field would have surfaced the gap.
- [ ] Codex-stranger escalation criteria are written (which entries warrant it).

#### Files Likely Affected
- `.claude/skills/blake/SKILL.md` (MODIFY — Gate 3 KA section)
- `.claude/skills/alex/SKILL.md` (MODIFY — post_review_knowledge / acceptance KA)
- `.claude/skills/alex/references/acceptance-protocol.md` (MODIFY — distillation loop)
- `.claude/skills/gate/SKILL.md` (MODIFY — KA references)

#### Dependencies
Phase 1

#### Notes
- This is the heart of the Epic and touches SAFETY-tagged KA constraints. Expert review must
  include verifying that BLOCKING KA rules (rule 5: Gate must include Knowledge Assessment)
  are preserved, not weakened — we are changing the FORM of KA, not removing it.
- Watch the circular-trigger trap (principles.md L1): the distillation loop trigger must be
  defined where the agent will actually see it (Gate 4 body), not buried in a reference whose
  load_when depends on knowing the loop exists.

### Phase 3: Maintain — dedup/retire/reconcile + lint

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Build the cheap, rule-driven maintenance layer. Mechanical pre-filters (MD5/normalized-hash
exact-dup; usage-utility retire signal). LLM reconciliation only for semantic near-dup /
contradiction, emitting one of ADD/UPDATE/DELETE/NOOP against top-K shown existing entries,
with UUID→stable-slug anti-hallucination, and DELETE/UPDATE applied only after human gate. A
soft lint (reminder, NOT fail-closed) checks: failure_mode present, no relative time, no
all-caps MUST on non-SAFETY, stranger-test-run before a playbook entry is accepted. NOT in
scope: migrating existing knowledge (P4). Honors L1 "Mechanical Enforcement Rejected on
Single-User CLI" — everything here is advisory/human-gated, no fail-closed hook.

#### Input
- P1 schema; P2 journal/playbook split + distillation loop.
- Mem0/SkillOps mechanisms from research (ADD/UPDATE/DELETE/NOOP, utility-fraction retire, hash-merge).
- Existing patterns/_index.md keyword-match retrieval (the lexical candidate-selection substrate).

#### Output
- A maintenance protocol (possibly an Alex `*distill` / `*knowledge-maintain` command, or folded into *accept) defining: pre-filter hash-dedup → candidate retrieval via _index keywords → ADD/UPDATE/DELETE/NOOP reconciliation → human gate for DELETE/UPDATE.
- A soft lint script (`.tad/hooks/lib/knowledge-lint.sh` or similar) that REPORTS violations, never blocks.
- Usage-tracking signal definition for retire (how "did a recent task use this entry" is approximated in a file-based system — e.g. _index load tracking or grep-on-accept).

#### Acceptance Criteria
- [ ] Reconciliation protocol shows top-K existing entries to the LLM and forces one of {ADD,UPDATE,DELETE,NOOP}; NOOP is first-class (default = do nothing, not append).
- [ ] DELETE and UPDATE are documented as human-gated (a proposal requiring confirmation), never auto-applied — verified against L1 verify-before-delete + reject-mechanical-enforcement.
- [ ] The lint script runs read-only, exits 0 always (reports, never blocks), and detects at least: missing failure_mode, relative-time words, all-caps MUST on non-SAFETY entries.
- [ ] A discriminative self-check: feed the lint a deliberately incomplete entry (missing failure_mode) and confirm it flags it; feed a complete one and confirm it passes (anti-theater).
- [ ] Hash-dedup pre-filter is specified and demonstrated to catch a byte-identical re-add with zero LLM calls.

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` (MODIFY — add *distill/maintain command or extend *accept)
- `.claude/skills/alex/references/` (CREATE — maintenance protocol reference)
- `.tad/hooks/lib/knowledge-lint.sh` (CREATE — soft, read-only lint)

#### Dependencies
Phase 2

#### Notes
- The reconciliation candidate-selection substrate is weaker than Mem0's embeddings (TAD has
  only keyword/_index lexical match). Accept this limit; do not promise semantic dedup the
  file substrate can't deliver (research LIMIT note). Over-ADD is the failure mode to watch.
- "Usage utility" in a file-based system is the hardest mechanic to approximate honestly —
  if it can't be measured cleanly, log that limitation rather than fake a metric.

### Phase 4: Dogfood + reference migration on this repo

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Migrate TAD's OWN project-knowledge to the new schema as the worked reference implementation,
and validate the full Capture/Distill/Maintain loop end-to-end on real TAD knowledge. Rewrite
principles.md non-SAFETY entries to strip musty MUSTs / add reasoning, add failure_mode where
missing, convert patterns to typed entries, and set up the journal/playbook split for this
repo. NOT in scope: migrating the 14 downstream projects (they pull via `*publish` after this
Epic). This phase IS the mechanism's own stranger test — if migrating real knowledge is
painful or surfaces schema gaps, fix the schema (feedback to P1 artifacts).

#### Input
- P1 schema/rules/template; P2 loop; P3 maintenance+lint.
- TAD's existing knowledge: principles.md (14 entries), patterns/ (9 files), category files, incidents/.

#### Output
- Migrated `.tad/project-knowledge/` conforming to the new schema (reference implementation).
- principles.md: non-SAFETY entries reworded (reasoning over MUSTs), failure_mode added where applicable, SAFETY entries left intact (read_only honored).
- patterns/ entries converted to typed format with selector-descriptions in _index.md.
- End-to-end validation evidence: one real new piece of knowledge taken through journal→distill→gap-handback→entry→lint→reconcile, documented.
- A short migration report noting any schema gaps found and fed back to P1 docs.

#### Acceptance Criteria
- [ ] principles.md SAFETY entries are byte-preserved (read_only honored — verify via diff that ⚠️ SAFETY entries' constraint text is unchanged unless explicitly amended with rationale).
- [ ] At least one full loop is demonstrated end-to-end on a real new knowledge item, with the gap-handback step actually exercised (a field that required a question).
- [ ] The lint runs clean (reports zero unexplained violations) over the migrated knowledge, OR every remaining violation is explicitly justified.
- [ ] Migration report lists schema gaps found (or states none) and any P1-doc fixes applied.
- [ ] No downstream project files are touched (verify: git diff stays within this repo) — downstream is pull-based, post-Epic.

#### Files Likely Affected
- `.tad/project-knowledge/principles.md` (MODIFY)
- `.tad/project-knowledge/patterns/*.md` + `_index.md` (MODIFY)
- `.tad/project-knowledge/{architecture,code-quality,security,frontend-design}.md` (MODIFY)
- `.tad/evidence/` (CREATE — journal location bootstrap + validation evidence)

#### Dependencies
Phase 3 (and transitively P1, P2)

#### Notes
- Migrating SAFETY entries is the highest-risk action in the Epic — these are load-bearing
  methodology constraints. Default to PRESERVE; only reword with explicit per-entry rationale
  and human confirmation. The `grep -c` SAFETY-count lessons (principles.md) apply: use
  line-set diff, not just a count, to prove nothing load-bearing was dropped.
- After P4 accept: a separate `*publish` ships the mechanism; downstream 14 projects pull. That
  publish is post-Epic, not a phase here.

---

## Context for Next Phase
{Alex updates this section after each *accept.}

### Completed Work Summary
- Phase 1: schema (6 fields, failure_mode REQUIRED) + writing rules (5 rules, variabilize test + guards, SAFETY exception) + template + L1 principle "Knowledge Is Forged at Distill, Not Captured" added to principles.md (14→15, SAFETY-tagged). 10/10 AC, git 74e9aed.
- Phase 2: Gate 3 KA → journal (evidence/journal/); Gate 4 KA → distillation_loop (7-step reference, blocking:false, step7.C unchanged as blocking safety net); gate/SKILL.md synced to accept journal paths; dry-run walkthrough with swell-40% case. 14/14 AC, git 7794627.
- Phase 3: Maintenance protocol (6-step: hash-dedup→lexical candidate→4-way reconcile→human gate with reject paths→usage-utility→lint) + soft lint script (3 checks, exit 0 always, discriminative self-check PASS) + usage log + *knowledge-maintain command. Lint found 8 pre-schema entries missing failure_mode (P4 scope). 12/12 AC, git 90dfcc8.
- Phase 4: 110 entries across 12 files migrated (0 UNRESOLVABLE). E2E distillation loop first live run: failure_mode gap detected by stranger → question → Blake answer ("fabrication > omission") → entry finalized → lint 0 WARN → ADD reconcile. Schema validated: failure_mode universally applicable. 10/10 AC, git 335e035.

### Decisions Made So Far
- Scope = mechanism-first + this-repo reference migration; downstream via pull-based publish (NOT in-Epic).
- Physical home = refactor existing (journal=evidence/, playbook=project-knowledge/); no 5th location.
- Distiller = gap-driven cross-bridge loop (Blake journal → Alex-as-stranger distill → unfillable-field questions → Blake answers → Alex finalizes); Codex-stranger only for high-stakes.
- Enforcement = soft (reminder + lint + human gate); DELETE/UPDATE human-gated; honors L1 "Mechanical Enforcement Rejected on Single-User CLI".
- Entry schema = label + pushy selector-description + bounded value + REQUIRED failure_mode + validator + read_only(SAFETY).

### Known Issues / Carry-forward
- principles.md at 14/15 entries — adding P1's L1 principle hits the cap; watch for consolidation need.
- File substrate has no embeddings — reconciliation candidate-selection is lexical only (weaker than Mem0); over-ADD is the watch.
- "Usage utility" retire metric may not be cleanly measurable on files — log honestly if so.

### Next Phase Scope
Phase 4: Dogfood — migrate TAD's own project-knowledge to the new schema (principles.md non-SAFETY entries reword, patterns/ convert to typed format, category files add failure_mode). Run the full capture→distill→maintain loop end-to-end on one real new knowledge item. Lint clean pass. Migration report.

---

## Notes
- Grounded in `.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md` (source-level study of Mem0, Letta, AWM, Anthropic Skills).
- Judgment-type knowledge (architecture-rationale, whose delta is a judgment-difference not an action-difference) is explicitly OUT of scope — a Phase-2 follow-up Epic. This Epic covers executable/pattern knowledge, the type all 4 studied systems handle.
