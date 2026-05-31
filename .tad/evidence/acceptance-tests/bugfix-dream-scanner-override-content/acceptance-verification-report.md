# Acceptance Verification — bugfix-dream-scanner-override-content

**Date:** 2026-05-31 | **Executor:** Blake
**Method:** Scratch-isolated regenerate run (real 6 override events + 1 synthetic fallback
+ 1 newline-injection event) in a temp `.tad` tree — real `dream-candidates/` NOT polluted.

| AC | Criterion | Result | Evidence |
|----|-----------|--------|----------|
| AC1 | Pass C extracts `.chosen` and `.rationale` from `context \| fromjson` | ✅ PASS | New jq extraction lines present; candidate Discovery/Action populated from real values |
| AC2 | Discovery contains actual `chosen` (+`rationale` when present), NOT old boilerplate; verified against the SPECIFIC new CAND file on the `- **Discovery**:` line | ✅ PASS | `grep -F '观测式为主' <cand> \| grep -c '^- \*\*Discovery\*\*:'` = **1**; old boilerplate ABSENT in that file |
| AC3 | Fallback intact — empty `.chosen`/`.rationale` → old boilerplate, no crash, no empty field | ✅ PASS | Synthetic decision-only event → "Human explicitly overrode agent suggestion for 'SyntheticOnlyDecision'" + "Document the override rationale..."; title falls back to `→ ?`; no empty fields under `set -u` |
| AC4 | `bash -n` passes; BSD-safe (no GNU-only flags); script still `exit 0` | ✅ PASS | `bash -n` OK; only pre-existing `date -d` (BSD-first fallback chain) present, untouched; scratch run `EXIT=0` |
| AC5 | No change to Passes A/B/D, frontmatter schema, or candidate filename format | ✅ PASS | `git diff` confined to Pass C (hunks @184–205); `generate_candidate`/`classify_scope`/frontmatter template/`fname` unchanged |

## Extra hardening verification (Layer 2 residual)
- Newline-injection event `rationale="first line\nsecond line --- type: evil"` → Discovery
  renders as **one** line (`grep -c '^- \*\*Discovery\*\*:'` = 1); embedded `---`/`type:`
  inline, NOT a standalone frontmatter-looking line; metachars `` `$(date)` `` printed
  literally (no execution).

## Notes
- AC2 AC-SELF-LEAK GUARD honored: verified against the specific newly-generated CAND file
  (pinned path), not a global grep of the candidate dir / trace tree.
- All scratch candidates cleaned up; `grep -c 'SyntheticOnly\|11393'` against real
  `dream-candidates/` = 0 (isolation confirmed).
