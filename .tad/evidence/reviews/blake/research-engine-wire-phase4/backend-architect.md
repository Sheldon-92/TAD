# backend-architect Review — research-engine-wire-phase4 (commit 92bbfc3)

**Artifact**: `.claude/skills/alex/SKILL.md` (cross_model_awareness SAFETY entry + Phase 0class/0c/4c/5b gate rewire)
**Type**: Post-impl Layer 2 review of a ⚠️ SAFETY-entry change (AR-001 cross-model carve-out per DR-20260531)
**Reviewer framing**: Blue-team — verify the carve-out is exactly as narrow as the ADR sanctions and that no path lets the external CLI auto-invoke silently.

---

## Overall: PASS

The carve-out is implemented exactly to the DR-20260531 specification: narrow (one protocol, one use), display+overridable preserved, the mechanical anchor byte-identical, the unrelated AR-001 "express=review-exempt" pattern untouched, and no scope creep in `forbidden_implementations`. The gate rewire reads `run_adversarial_challenge` at all three challenge sites; the preflight-ordering and baseline-tree-not-gated fixes (my prior P0-2) are correctly applied. I find no P0 and no P1. Two P2 observations are documentation-robustness, not correctness.

---

## Verification performed (re-derived from primary evidence)

| Check | Method | Result |
|-------|--------|--------|
| Anchor byte-identity | `grep -Fxq` full-line on L482 | EXACT MATCH (`  NOT_via_alex_auto: true  # Alex NEVER auto-invokes external CLI — suggest or delegate only`) |
| forbidden_implementations entry count | `sed -n '484,490p' \| grep -c 'MUST NOT'` | 6 (== baseline 6; no addition, no deletion) |
| AC4.5 forward line-set diff | `comm -23` baseline-text vs current | Exactly {2 amended forbidden + 1 amended must-scan + gate-prose rewordings} — no other forbidden line missing |
| express=review-exempt (unrelated AR-001) | grep L2117/L6251/L6258 | Untouched verbatim |
| Phase 0class precedes 0c | line order 1174 < 1213 | Confirmed (0class runs BEFORE 0c) |
| run_adversarial_challenge read at all 3 gates | grep L1219/1551/1652 | Confirmed |
| Phase 4 Step 1 baseline tree NOT gated | L1360-1362 | Confirmed "runs for ALL tiers… NOT gated by run_dynamic_seeds" |
| Step 2.5 gated on run_dynamic_seeds | L1494-1497 | Confirmed |
| research_complexity persisted + read by Phase 5 | L1210 / L1539 / L1541 | Confirmed |

---

## 1. SAFETY carve-out correctness — PASS

- **Narrowness (ADR condition 1: one protocol, one use)**: L487 amendment names the exception as "the *research-plan Phase 0c/4c/5b adversarial-challenge step" and closes with "every other protocol step stays forbidden." L488 amendment limits the AskUserQuestion-default exception to "inside *research-plan the complexity ladder" and re-asserts "suggesting codex/gemini as a general default Recommended task tool anywhere else stays forbidden." This matches DR conditions 1 + 4 (scope + internal-vs-external-unchanged-elsewhere) verbatim in intent.
- **Display + overridable (ADR conditions 2 + 3)**: both amended lines carry "ONLY when … displayed … and remain overridable" / "shown and overridable." The mechanism is implemented at L1193-1206 (Phase 0class Step 2: explicit display block + AskUserQuestion with four override options incl. "改为 simple" which turns the challenge off). The "display+override replaces the per-gate keystroke" wording matches DR §38.
- **Nothing else changed in forbidden_implementations**: line-set diff proves the only baseline forbidden lines absent verbatim are L487 and L488 (both reappear in amended form citing DR-20260531). L485/L486/L489/L490 are byte-identical. Entry count holds at 6.
- **Anchor byte-identical**: `grep -Fxq` on the full L482 line returns match — the audit-grep target is preserved exactly. The DR explicitly mandated this line "stays byte-identical, NOT amended" — upheld.
- **Unrelated AR-001 left untouched**: the `anti_rationalization_registry` pattern id AR-001 "express = review-exempt" (L6250-6258) and its sibling mention (L2117) are unchanged. The DR §14 disambiguation warned about this overload; the implementation correctly amended only the must-scan list item (L6248, the cross-model item) and left the express-exempt pattern alone.

## 2. Gate rewire — PASS

- **All three gates read `run_adversarial_challenge`**: Phase 0c L1219, Phase 4c L1551, Phase 5b L1652 each gate on `iff run_adversarial_challenge`. Off → skip to the correct successor (0c→Phase 1; 4c→Phase 4.5; 5b→Step 2 display-as-is).
- **Step 2.5 gated, baseline tree NOT gated**: L1494-1497 gates Step 2.5 (adaptive seed generation) on `run_dynamic_seeds`; L1360-1367 explicitly exempts the Phase 4 Step 1 baseline seed tree from gating and runs it for all tiers (simple still gets single-ask baseline). This is the correct asymmetry — gating the baseline tree off would have degenerated simple-tier research to just the Phase 3 report (my prior P0-2 disambiguation), and the comment cites it.
- **Preflight cached-var ordering (my prior P0-2)**: Phase 0c Step 2 (L1225-1228) runs the `command -v codex/gemini` preflight ALWAYS — "regardless of run_adversarial_challenge" — and caches `codex_available`/`gemini_available`. Phase 4c (L1554-1555) and Phase 5b (L1655-1656) consume those cached vars and both note they are safe "even when Phase 0c challenge was gated off." The ordering is correct: Step 1 gate at L1222 explicitly runs "Step 2 preflight FIRST (always), THEN" evaluates the skip. So when the Phase 0c challenge is gated off, 4c/5b never read an unset var. No use-before-set hazard found.
- **Internal-only path correctly unconstrained**: Step 2.5 comment (L1496) correctly states it is "INTERNAL NotebookLM only (no external CLI, no AR-001 constraint) → fully auto by complexity, no keystroke." This is consistent with DR §43 (dynamic seeds need no carve-out).

## 3. Classification step — PASS

- **Mutually exclusive + ordered**: L1179 "Mutually exclusive + ORDERED — classify as the LOWEST tier whose EXPLICIT trigger is met." Table L1182-1186 has three disjoint tiers with explicit triggers.
- **Default `comparison`**: L1180 + L1185 set `comparison` as the default when ambiguous, explicitly NOT `complex` (cites my prior P1-1: vague signals must not collapse to complex). Correct — the safer default routes ambiguity to challenge-OFF (`comparison` → `run_adversarial_challenge` off).
- **Display + overridable present**: L1193-1206, unconditional for every tier (no early return skips the display — verified by scanning L1174-1212; the only `→ off` lines are inside the override-option menu, not an early exit). Satisfies DR conditions 2+3.
- **Persisted for Phase 5**: L1208-1211 records final (post-override) tier; L1536-1541 writes `research_complexity` frontmatter; L1541 confirms Phase 5 reads it instead of re-deriving. Forward-compat (my prior P1-4) satisfied.

## 4. Can the challenge auto-invoke WITHOUT display+override (silently)? — NO

I traced every entry into each challenge site:

- **Phase 0class is unconditional and precedes 0c** (L1174 "runs per research item, BEFORE Phase 0c"). There is no branch that reaches 0c/4c/5b without first executing 0class Step 2's display+AskUserQuestion. So `run_adversarial_challenge` is never consumed before it has been displayed and made overridable.
- **No tier sets the challenge on silently**: only `complex` sets `run_adversarial_challenge=on` (L1190), and `complex` still passes through the same Step 2 display+override. The user can flip it off via "改为 simple/comparison" before any invocation.
- **Phase 4c re-challenge loop (MAX_CHALLENGE_ROUNDS:2)**: the On-FAIL loop-back (L1598-1601) re-enters at Step 2 *within* the section already authorized by the Step 1 gate (L1550). It cannot resurrect a challenge that was gated off — if `run_adversarial_challenge==off`, Step 1 skips to Phase 4.5 before the loop is ever reached. The loop is bounded and continues an already-displayed-and-authorized invocation; it is not a fresh silent invocation.
- **Both-models-missing path**: L1229 WARNs and skips — degrades safe.

Conclusion: there is no code path that auto-invokes codex/gemini without first passing through the Phase 0class display+override. The carve-out's safety condition holds.

---

## Findings

### P0
None.

### P1
None.

### P2

- **P2-1 (doc robustness): the safety property "0class always precedes any gate" is enforced only by document ordering + a `BEFORE Phase 0c` note (L1174), not by a precondition check inside the gates.** If a future edit reorders phases or adds a new entry into 0c/4c/5b, an agent could read `run_adversarial_challenge` before 0class set+displayed it. Cheap hardening: add to each gate step a one-line precondition assertion ("PRECONDITION: run_adversarial_challenge was set AND displayed in Phase 0class; if unset → run 0class first"). This converts the invariant from positional to explicit, matching the project's own "Sufficiency Check Must Precede the Step It Influences" (2026-05-14) and "Step Insertion Requires Predecessor Transition Arrow Audit" (2026-05-14) lessons. Not blocking — current ordering is correct.

- **P2-2 (consistency): `forbidden_implementations` L487/L488 say the carve-out covers "Phase 0c/4c/5b", but the gate-step labels at L1218/1550/1651 phrase the same constraint as "now satisfied via DR-20260531 carve-out".** Both are true, but a reader auditing L487 for the literal phases relies on prose enumeration that must stay in sync with the three gate headers. If a fourth challenge site is ever added it must be added to BOTH the L487 enumeration AND a new gate header — currently nothing mechanically links them. Recommend a CONTRACT-style note near L484 listing the three sanctioned line numbers/phases so the enumeration has a single maintenance anchor. (Aligns with the `.router.log` 5-Tuple "consumed contract" lesson.) Not blocking.

---

## Notes for Gate 3 / Gate 4

- The AC4.5 line-SET diff (not `grep -c` count) is the correct verifier here and it passes; the count metric alone would mislead because three ordinary gate-PROSE labels legitimately changed per the handoff mandate. This matches the 2026-05-31 knowledge entry already recorded.
- `git status` of the worktree shows the SAFETY-entry change is committed as 92bbfc3 with the human-authored DR present — provenance chain (DR → forbidden amendment → must-scan amendment → gate rewire) is intact and greppable via `DR-20260531`.
