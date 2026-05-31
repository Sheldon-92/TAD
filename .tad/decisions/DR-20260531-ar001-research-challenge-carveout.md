# DR-20260531: AR-001 Carve-Out for Auto-Running Adversarial Challenge Inside *research-plan

**Status**: Accepted (human-authorized 2026-05-31)
**Touches**: ⚠️ SAFETY entry — `alex/SKILL.md` cross_model_awareness.forbidden_implementations (L487-L488) + anti_rationalization_registry must-scan list
**Epic**: EPIC-20260504-goal-driven-research Phase 4
**Decided by**: Human (explicit), via Alex *analyze Socratic + expert review

## ⚠️ Label Disambiguation (read first)
"AR-001" is **overloaded** in `alex/SKILL.md`. This DR concerns the **cross-model SAFETY constraint**:
- `cross_model_awareness.NOT_via_alex_auto: true` mechanical anchor (~L482) — **stays byte-identical, NOT amended**.
- `cross_model_awareness.forbidden_implementations` L487/L488 — **the two lines amended** by this carve-out.
- `anti_rationalization_registry` must-scan item (~L6185, "auto-invoking external CLI…") — gains an "EXCEPT DR-20260531" note.

This DR does **NOT** touch the `anti_rationalization_registry` pattern *also* labeled **AR-001** (~L6187, "express = review-exempt") — that is an UNRELATED constraint about skipping expert review and is unaffected.

## Context
The deep-research engine's Codex+Gemini adversarial challenge is used in only 2 of 25 research dirs. Root cause: in `*research-plan`, the challenge sits behind opt-in AskUserQuestion gates (Phase 0c/4c/5b) that default to "跳过/skip", so it almost never runs. Phase 4 introduces a complexity-adaptive effort-scaling ladder to wire it.

backend-architect review (P0-1) flagged that auto-running the challenge contradicts the active AR-001 SAFETY constraint:
- `forbidden_implementations` L487: "MUST NOT auto-invoke codex/gemini from any Alex protocol step"
- L488: "MUST NOT use AskUserQuestion to suggest codex/gemini as a default Recommended option"
- anti_rationalization_registry must-scan: "auto-invoking external CLI (codex/gemini) without user confirmation (NOT_via_alex_auto)"

The original intent of AR-001: Alex must NEVER silently invoke external CLI; a human keystroke is the confirmation. The challenge gate's keystroke IS that mechanism.

## Options Considered
- **A — Scope-split**: ladder auto-fires dynamic seeds (internal, unconstrained) only; challenge keeps the human keystroke, classification merely pre-highlights "执行" for complex items. No SAFETY change.
- **B — Carve-out (CHOSEN)**: amend AR-001 with a narrow exception allowing challenge auto-run inside `*research-plan` when the classification is displayed and overridable.
- **C — Conservative**: wire dynamic seeds only; leave challenge triggering unchanged.

## Decision
**Option B.** Add a narrow, conditional carve-out to AR-001. The challenge MAY auto-run inside `*research-plan` **only when ALL of these hold**:
1. **Scope**: the invocation is the `*research-plan` Phase 0c/4c/5b adversarial-challenge step — NOT any other Alex protocol step, NOT suggesting codex/gemini as a general task tool.
2. **Displayed**: the complexity classification AND the resulting decision ("will run adversarial challenge") are shown to the user before the challenge runs.
3. **Overridable**: the user can turn the challenge off (a single explicit action) before it executes; the classification is a SUGGESTION, not a lock.
4. **Internal-vs-external unchanged elsewhere**: every OTHER external-CLI invocation path (hooks, settings.json, other protocol steps, suggesting codex/gemini as a default Recommended task tool) remains forbidden exactly as before.

The "display + overridable" pair REPLACES the per-gate keystroke as the human-confirmation mechanism for this one sanctioned path. Net safety posture: the human still sees and can veto every external-CLI invocation; what changes is the default (was: skip; now: run-for-complex-unless-vetoed).

## Why this is safe
- The carve-out is **narrow** (one named protocol, one named use).
- Human visibility + veto is preserved (NOT_via_alex_auto's actual purpose — no SILENT invocation — is upheld).
- Dynamic seeds (the bigger 0-usage gap) need no carve-out at all (internal NotebookLM).
- All other forbidden_implementations lines remain byte-identical and enforced.

## Implementation (Phase 4)
- Amend `forbidden_implementations` L487/L488 with the conditional exception, citing `DR-20260531`.
- Add a paired note to anti_rationalization_registry: the must-scan item gains "EXCEPT the DR-20260531 *research-plan carve-out (display+overridable)".
- AC4.5 upgraded from line-count to line-set diff: every pre-impl forbidden line must still be present EXCEPT the two sanctioned amendments, which must reference `DR-20260531`. Unauthorized removal of any other forbidden line = FAIL.

## Revisit / Rollback
If usage data later shows the auto-run causes unwanted cost/latency or any silent-invocation incident, revert to Option A (re-add the keystroke). The carve-out text is greppable (`DR-20260531`) for clean removal.
