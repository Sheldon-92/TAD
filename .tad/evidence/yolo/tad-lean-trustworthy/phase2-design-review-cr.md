# Phase 2 Design Review — code-reviewer (YOLO Y4)

Verdict: **CONDITIONAL PASS**. Set logic + BSD-safety + advisory contract correct. 2 P0 (AC theater) must fix.

## P0
- **P0-1 AC2.5 idempotency is theater + "14 entries byte-stable" is FALSE.** Verified: a fresh scan REORDERS
  (academic-research committed-last → alpha-first), changes `synced_from_version` (2.15.1→2.19.1, a non-date line),
  and DROPS academic-research consumes/produces → "Not specified" (its CAPABILITY.md has no `**CONSUMES**:` line).
  AC2.5 (scan twice→diff) passes trivially (both runs churned) while hiding the committed→fresh degradation.
  FIX: AC2.5 = line-SET diff (comm) of COMMITTED vs post-scan; enumerate expected delta (reorder + synced_from_version
  + 2 adds + date); restore CONSUMES/PRODUCES to any pack CAPABILITY.md that would degrade to "Not specified"
  (at least academic-research) before re-scan, OR explicitly accept+document the loss.
- **P0-2 AC2.3 revert `git checkout pack-registry.yaml` destroys FR2** (reverts to committed 14-pack). FIX: inject
  bogus `- name: "zzz-fake"` then remove via targeted sed (NOT git checkout), OR re-run scan-packs after checkout.

## P1
- P1-1 forbidden_implementations precedent wrong: no `.tad/hooks/*.sh` has that block; post-write-sync.sh:8 is a
  SAFETY *comment*. FIX: cite `post-write-sync.sh:6-11` SAFETY-comment STYLE; AC2.4 substring grep = deliberate marker.
- P1-2 Set B must gate on `[ -f "$d/SKILL.md" ]` (not bare dir glob) — `.claude/skills/_archived/` would slip in. Add _archived negative test to §8.3.

## P2
- P2-1 Set C gate on `[ -f "$d/CAPABILITY.md" ]` (mirror scan-packs exactly).
- keywords verbatim copy confirmed safe (single-line flow form extracts correctly).

Live spot-checks: AC2.1/AC2.2 commands sound (no grep-c|sort-u|wc-l antipattern, no literal \| in grep -E). last_scanned date correct. No fail-closed path.
