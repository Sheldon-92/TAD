# AC Verification Patterns (Layer 2)

> Reusable patterns for acceptance criteria design, verification command correctness, and dry-run discipline.

---

### Alex Handoff AC Design Rules - 2026-04-14
- **Discovery**: (1) AC lists become the operational contract — anything not in ACs is effectively optional. Alex MUST explicitly list ALL required evidence files. (2) "≥N triggers" with a concrete list is ambiguous — use "All of A, B, C must PASS" form. (3) When 3 co-mandated ACs are mutually exclusive by construction (byte-preservation + optimization + behavioral invariant), add AC Conflict Matrix sub-step. (4) AC verification commands need pre-ship smoke test — Alex MUST dry-run each on representative existing artifacts before shipping handoff.
- **Action**: Use imperative AC form. Dry-run verification commands. Add AC Conflict Matrix for structural ACs.

### AC Verification Drift Pattern - 2026-04-25 (recurring through 4 phases)
- **Discovery**: Alex specifies AC verification commands without testing them on real artifacts. Failures surface only when Blake runs the literal command. Three sub-patterns: (1) sentinel/marker substring leak, (2) output-shape assumption mismatch (single vs multi-file grep), (3) expert reviewer scope mismatch. Root cause: mental simulation of regex is insufficient. §9.2 "Verified Output" column should be MANDATORY-FILLED by Alex before handoff ships.
- **Action**: Every non-trivial AC verification command MUST be dry-run on a representative existing artifact during handoff drafting. Paste actual command output in §9.2.

### AC Self-Leak from Removal Rationale - 2026-04-27
- **Discovery**: When a grep-substring AC verifies "no occurrence of X" and the impl adds a rationale comment containing X (e.g., handoff slug containing the forbidden word), the comment self-leaks. Fix: reference META artifacts (deprecation.yaml entry, ADR id) not the handoff slug.
- **Action**: Removal rationale pointers must reference META artifacts, never the removed-feature name verbatim.

### Recurring failure: tsc missing type - 2026-05-19
- **Context**: Detected by dream-scanner from v2 trace analysis. Pattern 'tsc: missing type' appeared in ≥2 reflexion_diagnosis events across TAD handoff cycles.
- **Discovery**: TypeScript type-checking failures (missing type declarations) are a recurring root cause of Blake Layer 1 failures. This pattern triggers reflexion cycles that could be avoided with upfront type completeness checks in handoff ACs.
- **Action**: When writing handoff ACs for TypeScript projects, include an explicit AC: "npx tsc --noEmit passes with zero errors before Layer 1." Consider adding type coverage threshold to Gate 3 v2 checklist.

### Behavioral-Fixture Discrimination: Anti-Slop = Threshold/Named-Rule, Not Vocabulary - 2026-05-31
- **Context**: P5 authored 14 behavioral fixtures (1 per installed capability pack) for `pack-eval-runner.sh`. Each fixture greps a captured agent output for "markers" proving the agent APPLIED a pack rule. The anti-gaming risk: a marker a no-pack frontier LLM would also emit makes the fixture validation theater (architecture.md YOLO audit).
- **Discovery**: The reliable discriminator is the SAME as the anti-slop formula (architecture.md "Capability Pack Quality Bar"): a marker is pack-specific iff it is a NAMED rule or a SPECIFIC threshold/number the pack introduces — NOT a domain noun. Concrete contrast that survived spot-check: markers like "self-enhancement bias 10-15%", "TruffleHog exit 183", "ACX RMS -23 to -18 dB", "n=550 a11y / 30-50%", "Four-Gate fastest-fail-first", "Judge ≠ Optimizer", "60-30-10 + 3-level token". NOT "make it secure", "add more tests", "use a TTS tool", or any word from the input scenario. Two fast sanity gates per fixture: (1) every Verification Command MUST be `grep -oE 'a|b|c' {out} | sort -u | wc -l` — NEVER `grep -c` (P4 lint Rule A: grep -c + sort -u | wc -l always returns 1). (2) every fixture needs ≥1 `[structural]` marker (proves the agent produced the rule's OUTPUT SHAPE, e.g. per-photo first_frame/last_frame decomposition or D1-D10 decision IDs, not just mentioned the vocabulary). The list in the Anti-Slop Check is load-bearing: it documents the generic terms deliberately EXCLUDED from the grep pattern.
- **Action**: When authoring a behavioral fixture, pull markers from the pack's specific numbers/named-rules/exit-codes/thresholds, never domain nouns or input words. Use `grep -oE … | sort -u | wc -l`. Require ≥1 [structural] marker that verifies output SHAPE. Self-check each marker: "would an agent WITHOUT this pack emit this?" — if yes, replace it.
- **Grounded in**: .tad/scripts/pack-eval-runner.sh, .claude/skills/*/examples/*.md (16 fixtures), .tad/templates/pack-example-fixture.md, COMPLETION-20260531-tad-lean-trustworthy-phase5.md AC5.3
