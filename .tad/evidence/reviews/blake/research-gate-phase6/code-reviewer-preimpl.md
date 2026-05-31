# Code Reviewer — research-gate-phase6 (PART A, pre-impl spec review)

Reviewer: code-reviewer (blue-team) | Date: 2026-05-31
Artifact: HANDOFF-20260531-research-gate-phase6.md §4 / §9
Grounded: alex/SKILL.md research_decision_protocol (L2700, step1 L2712) + STEP 3.8 (L178)

---

## P0
None.

## P1

### P1-1 — AC6.4 negative-grep has no defined region → validation theater
§9.1 AC6.4 says "gate region has no `BLOCK|deny|return.*fail`". But the whole SKILL.md
already contains **30** matches for `BLOCK|deny|return.*fail` (verified:
`grep -cE 'BLOCK\|deny\|return.*fail' SKILL.md` = 30). The AC names no line range,
no anchor, and no `sed -n 'A,Bp'` scope. As written Blake will either (a) run it
against the whole file, get 30, and have no way to know if the gate added one, or
(b) eyeball "the region" — neither is reproducible. This is the exact failure class
the project knowledge flags ("AC Verification Drift", "validation-theater").
**Fix:** specify the negative-grep against a delimited region, e.g. require the new
gate to live between two stable anchor comments (`# --- research-gate start ---` …
`# --- research-gate end ---`) and verify `sed -n '/research-gate start/,/research-gate end/p' SKILL.md | grep -cE 'BLOCK|deny|return'` = 0. Without a region the
non-blocking AC cannot actually be checked.

### P1-2 — Double-prompt guard is asserted but not mechanizable
§4 and §10 say "if STEP 3.8 already surfaced the same notebook gap this session, the
gate should not re-nag." This is the right intent, but STEP 3.8 fires at **activation**
(pre-Socratic, L178) and the gate fires inside **\*analyze** (post-Socratic, L2712) —
they are different protocol phases with no shared session flag. There is no specified
mechanism (a `suppress_if` referencing a STEP-3.8-set marker, or a session-state field)
for the gate to know 3.8 already nagged. As written the "don't re-nag" note is prose
the agent may or may not honor. Given STEP 3.8's own `suppress_if` is REGISTRY/OBJECTIVES
driven and the gate's trigger is per-decision external-info classification, the two will
in practice fire on *different* conditions (3.8 = objective-vs-notebook gap; gate =
this-decision needs external info), so true duplication is narrow — but when both DO
point at the same missing notebook, nothing prevents two prompts.
**Fix:** make AC6.1 require an explicit `suppress_if` clause naming the STEP 3.8
interaction (mirror STEP 3.8's `interacts_with` style at L214–221), or downgrade the
"don't double-nag" to an accepted-known-overlap and document why it's acceptable.
Either is fine; silent prose is not.

## P2

### P2-1 — Negative guard (AC6.2) is example-list, not a decision rule
§4/AC6.2 enumerate categories (config, naming, refactor mechanics, download-plugin) and
require "MUST NOT fire" text. That's better than hand-waving, but the classification
boundary is a single criterion — "decidable from the repo itself or pure user
preference." Borderline cases (e.g. "which of two libs already in package.json" — internal;
vs "which lib should we add" — external) will rely on agent judgment. This is acceptable
for a suggestion-only gate (mis-fire cost = one dismissable prompt), but AC6.2 should
require the implementation to state the **single discriminating question** ("can this be
decided from codebase/requirements alone? → no gate") in addition to the example list,
so the rule generalizes beyond the four examples. Concrete-enough to ship; sharpen the rule.

### P2-2 — Gate placement: step1 vs step2_5 overlap with existing notebook check
The handoff offers "step1_identify_decisions (or step2_research entry)". Note that
`step2_5_notebook_check` (L2744, `blocking: false`) ALREADY does a REGISTRY lookup for
a matching notebook. Placing the new gate in step1 means notebook-existence is checked
twice (gate in step1, then step2_5 again). Prefer anchoring the gate at/after step2_5's
REGISTRY read, or have the gate reuse step2_5's result, to avoid a duplicate REGISTRY
scan and keep a single source of truth for "does a notebook exist." Pick ONE placement
in the impl and state it; don't leave the "or" in the shipped code.

### P2-3 — AskUserQuestion option "我已了解，直接设计" is the silent-skip path
The third option lets the user bypass research with no record. Fine for non-blocking
design, but consider whether declining should leave a trace (the project's telemetry
ethos). Not required for this P2 handoff; flag only.

---

## AC verifiability (requested focus #3)
- AC6.4 baselines **all verify** against current main: `DR-20260531`=9, `NOT_via_alex_auto: true`=1, `codex exec --full-auto`=3, `gemini -p`=3. These are sound regression anchors (they prove the SAFETY carve-out and cross-model wiring were NOT touched).
- AC6.4 non-blocking grep is **unsound as written** — see P1-1 (no region).
- AC6.1/AC6.2/AC6.3 §9.1 rows are prose-presence checks ("region contains … text"), inherently semi-manual; acceptable for a prose-protocol handoff but pair each with a literal anchor string the impl must include so the grep is exact rather than judgment.

## Scope discipline (requested focus #5)
AC6.3 deferral is **clearly and redundantly specified** — banner (§ header), AC6.3
"do NOT implement", §10 bullet, §11 row, Blake Instructions, and the *sync row stays
"Planned". This is well-fenced; Blake will not accidentally sync. Good.

## Non-blocking (focus #4)
Intent is stated in 4 places and AC6.4 attempts to verify it — but the verification is
the P1-1 gap. Once a region is defined, non-blocking is adequately specified.

---

## Overall: APPROVE WITH CHANGES
Sound, well-scoped, SAFETY-respecting handoff. No P0. **Resolve P1-1 (define the
grep region for the non-blocking check) and P1-2 (mechanize or explicitly accept the
3.8/gate overlap) before implementation** — both are spec-precision fixes, not redesigns.
P2s are sharpening. Scope/deferral discipline is exemplary.
