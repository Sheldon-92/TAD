# Code Review — Phase 3 New Paths (Blake-side)

**Reviewer:** code-reviewer
**Scope:** Phase 3 protocol-layer changes (no runtime code)
**Date:** 2026-04-24
**Files reviewed:**
- `/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/alex/SKILL.md` (lines 300-498, 983-1158, 2298-2398)
- `/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/blake/SKILL.md` (lines 1152-1201)
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/templates/handoff-a-to-b.md` (lines 1-19)
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/config-workflow.yaml` (lines 649-705)
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/templates/completion-report.md` (cross-checked, lines 140-156)

---

## P0 Issues

### P0-1 — Override-marker anchor mismatched with canonical completion-report template (DEAD MARKER)

**Severity:** P0 — silently breaks the entire P3.3 override safety net.

**Evidence:**
- Alex `acceptance_protocol.step7.pre_check` (Alex SKILL.md:2321) and Blake `completion_knowledge_override.override_marker_anchor` (Blake SKILL.md:1168) both anchor on **`## Knowledge Updates`**.
- Canonical template `/Users/sheldonzhao/01-on progress programs/TAD/.tad/templates/completion-report.md:142` uses **`## 📖 Knowledge Assessment (MANDATORY — Gate 3 BLOCKING)`**.
- All 10 archived completion reports under `.tad/archive/handoffs/COMPLETION-*.md` use literal `## Knowledge Assessment` (verified by grep). Zero use `## Knowledge Updates`.
- Result: when Blake writes a correctly-formatted override marker as the first non-blank line under the section he actually owns (`## Knowledge Assessment`), Alex's `step7.pre_check` step 2 ("Locate `## Knowledge Updates` section header") will NOT find the section and will fall through to `branch_1_skip_no_override` — silently skipping KA. This is exactly the menu-snap SDK shape cast bug failure mode the safety net was designed to prevent.

**Why expert review missed it:** the v2 review focused on intra-handoff consistency (anchor used identically in both SKILLs); cross-check against `templates/completion-report.md` was not part of the grounding pass.

**Recommended fix (pick one, apply consistently to BOTH Alex and Blake SKILLs):**
- (a) Change anchor everywhere to `## Knowledge Assessment` (matches existing template + 10 archived reports; zero migration cost). Update Alex SKILL:2321 and Blake SKILL:1168 + every "Knowledge Updates" string in the P3.3 block.
- (b) Add a new dedicated `## Knowledge Updates` section to `templates/completion-report.md` placed ABOVE `## 📖 Knowledge Assessment`, and document the relationship (Updates = override marker zone; Assessment = the actual KA table). Higher migration cost, two sections to keep aligned.

Recommendation: **(a)**. The current `## Knowledge Assessment` section header already serves as "the KA zone" — overload the override marker into its first non-blank line. Cleaner, single source of truth, no template churn.

---

### P0-2 — Override marker emission protocol is silent on WHERE Blake writes it relative to the existing KA Yes/No content

**Severity:** P0 (depends on P0-1 fix landing).

`completion_knowledge_override.override_marker_format` (Blake SKILL:1171-1184) says "First non-blank line under `## Knowledge Updates` section" — but the existing `## 📖 Knowledge Assessment` template body starts with `**是否有新发现？** ✅ Yes / ❌ No` (completion-report.md:144). If P0-1 is fixed via option (a) and Blake follows the override format literally, the override marker REPLACES the Yes/No header — losing the existing KA structural contract. If Blake instead inserts ABOVE the Yes/No line, it satisfies "first non-blank line" but moves the boilerplate. Protocol must specify.

**Recommended fix:** add to `override_marker_format` an explicit "insertion location" note: `Override marker is inserted AS A NEW LINE between the section header and the existing **是否有新发现？** line. Existing template body remains intact below.` Pair with an Alex grep adjustment: line-anchored search within first ~5 lines after the section header (not strictly the first non-blank line) so a future template tweak doesn't break the match.

---

## P1 Issues

### P1-1 — `path_transitions.forbidden` "any → any" entry is structurally ambiguous

Alex SKILL.md:495-497:
```yaml
- from: "any"
  to: "any (other than listed allowed)"
  reason: "Default deny — only the explicitly listed allowed transitions are permitted."
```

A future Alex implementing `mechanism: AskUserQuestion to confirm` would have to special-case the literal string `any (other than listed allowed)`. Recommend reformatting as a separate `default: deny` field at the matrix level, leaving `forbidden:` as a list of explicit pairs only. Current form works because no enforcement code reads it, but it's a footgun the moment someone tries.

### P1-2 — `branch_1_skip_no_override` sets `A_verify_blake_claims: SKIP` — contradicts handoff §3 task description

Handoff §3 P3.3.b text says branch_1 is `A_verify_blake_claims: REQUIRED` (still verify Gate 3 claims even when KA is skipped). Implemented Alex SKILL.md:2331 reads `A_verify_blake_claims: SKIP` with comment "nothing to verify (Blake had no KA obligation)". The implemented semantics may actually be correct (Blake had no KA to verify under skip), but it diverges from the handoff spec without an Audit Trail entry justifying the change. Either:
- (a) Restore `REQUIRED` to match handoff §3 (and the handoff's branch_1 acceptance_report mentions "Layer 2 + raw recompute still ran" — implying claims verification is part of step7 even under skip), OR
- (b) Add an Audit Trail row in §10 explaining the deviation (Blake-side simplification: A=SKIP because there are no KA claims to verify; B=REQUIRED still covers quantitative AC re-derivation).

Recommendation: (b). Implementation read makes more semantic sense, but document the spec deviation.

### P1-3 — `experiment_path_protocol.required_steps` step5 (Gate 2) and step7 (Blake message) are missing

Compare to `express_path_protocol.required_steps` (Alex SKILL.md:1018-1026) which lists all 9 mandatory steps. `experiment_path_protocol.required_steps` (Alex SKILL.md:1098-1102) only lists 4 items and ends abruptly at step2 expert review. Standard TAD step5 (Gate 2 check), step7 (Blake message), Gate 3 v2, Gate 4 v2 are implied by "Standard TAD steps … DO follow" but not enumerated. Future Alex reading this list literally could conclude *experiment skips Gate 2.

**Recommended fix:** mirror express_path_protocol's enumeration style — list all 9 required Standard TAD steps explicitly, with the 4 experiment-specific additions called out.

---

## P2 Issues

### P2-1 — Alex SKILL.md:2331 comment style inconsistency

`A_verify_blake_claims: SKIP   # nothing to verify (Blake had no KA obligation)` uses inline `#` comment after a YAML scalar. Other branches use the `acceptance_report_text:` block form. Cosmetic only; pick one style for the trio of branches.

### P2-2 — Anti-Epic-1 grep pattern in §5 anchors on `^[^#]*` but YAML uses `#` for inline comments too

The handoff §5 grep `^[^#]*\*express[^|]*hook` is meant to skip comment lines, but YAML files have `key: value  # comment` lines where `# comment` is mid-line. The current anchor handles full-line comments but a malicious/accidental `*express hook` mention BEFORE a `#` would still match. Low risk because no such mention exists today (verified: 0 hits). Documenting for future hardening.

### P2-3 — `*express never appears as Recommended` rule is in 4 places

`config-workflow.yaml:692-704` (priority_note + intentional ordering), `config-workflow.yaml:655-658` (signal_words intentionally empty), `alex/SKILL.md:354-361` (step3 7-mode display exception), `alex/SKILL.md:992-1000` (NOT_via_alex_suggestion). All four agree — but four sources of truth means a future edit that touches one will likely miss the others. Suggest a single canonical statement (in `express_path_protocol.trigger.NOT_via_alex_suggestion`) and the other three sites become `# See express_path_protocol.trigger.NOT_via_alex_suggestion` cross-references. Not blocking; pure DRY.

---

## Mechanical Verifications Run

| Check | Command | Result |
|-------|---------|--------|
| AR-001 anchor (AC-P3.1-h) | `grep -A 30 'express_path_protocol:' alex/SKILL.md \| grep -c 'expert review.*code-reviewer\|code-reviewer.*expert review'` | **2** (≥1 PASS) |
| Anti-Epic-1 grep (§5) | full pattern from handoff §5 against settings.json + .tad/hooks/*.sh + .tad/hooks/lib/*.sh | **0 hits** PASS |
| Anti-Epic-1 file scan | `ls .tad/hooks/ .tad/hooks/lib/ \| grep -E '^(express\|experiment\|skip_knowledge\|knowledge_assessment)'` | **0 matches** PASS |
| Forbidden_implementations symmetry | Count list items in 3 blocks | express=5 ✅, experiment=5 ✅, skip_KA (Alex.step7)=5 ✅, skip_KA (Blake)=5 ✅. **Symmetric.** |
| `## Knowledge Updates` in template | `grep '^## Knowledge' templates/completion-report.md` | **0 hits — section does not exist** ⚠️ See P0-1 |

---

## Overall Verdict

**CONDITIONAL PASS — P0-1 + P0-2 must be fixed before Gate 3 sign-off.**

Strengths:
- All non-negotiable constraints from the handoff brief are satisfied: STRICT prompt-level (zero hooks, zero settings.json mutations, zero new hook files), AR-001 anchor passes mechanical grep with margin (2 not 1), AUGMENT-not-REPLACE semantics explicit and well-defended (gate3/4_focus_AUGMENTATION blocks), forbidden_implementations symmetric across all 3 paths (5+5+5 items), Intent Router *express never-Recommended defense is layered in 4 places (defense-in-depth even if redundant), path_transitions matrix complete with explicit forbidden analyze→express/experiment.
- Backward compatibility for absent `skip_knowledge_assessment` field is correctly handled (Alex SKILL.md:2313: "field ABSENT → treat as no").
- Layer 2 audit decoupling note (Alex SKILL.md:2304-2308) preempts the obvious AR-001-style "skip_KA implies skip Layer 2" rationalization.
- Domain Pack auto-load contract for *experiment is explicit with WARN fallback and an `on_load_announcement` literal string for fixture grep — addresses the "router-mode keyword loader gap" cleanly.

P0 blockers:
- **P0-1** is the show-stopper. The override marker anchor `## Knowledge Updates` does not match the actual completion-report template section header `## 📖 Knowledge Assessment` nor any of 10 archived precedents. As written, the safety net is functionally dead — the menu-snap SDK shape cast bug failure mode is unprotected. Recommend fix option (a): change anchor to `## Knowledge Assessment` everywhere (Alex SKILL.md:2321, Blake SKILL.md:1168, plus every `Knowledge Updates` mention in the P3.3 block). Re-run AC-P3.3-h fixture against the corrected anchor.
- **P0-2** clarifies the insertion-location ambiguity introduced by the P0-1 fix.

P1s are spec-divergence (P1-2) and protocol-completeness gaps (P1-3) that risk future mis-interpretation but don't break the current implementation. P2s are cosmetic / DRY.

Once P0-1 + P0-2 are addressed (estimated ~15 min total: edit 2 SKILL files + add insertion-location note + re-grep), Phase 3 is ready for Gate 3 v2.
