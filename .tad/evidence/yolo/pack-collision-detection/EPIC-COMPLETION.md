# EPIC COMPLETION — Pack Collision Detection
> EPIC-20260531-pack-collision-detection · 2/2 phases · YOLO full-auto · 2026-05-31

## Outcome
TAD now detects when two co-loaded capability packs issue contradicting directives, auto-resolves cross-category collisions by precedence (with a visible log), escalates same-category ties to the human, and surfaces the verdict in both pack-loading consumers. Closes the cross-model-audit "zero collision detection" gap (architecture.md YOLO Audit Findings 2026-05-15).

## Phases
| Phase | Commits | Gate | Reviewers |
|-------|---------|------|-----------|
| P1 — detector engine + data + 3 fixtures | d296374 + 1b714f4 | 3+4 PASS | 2 design + 2 impl, 0 P0 |
| P2 — wire surfacing (Alex step4_5 + Blake 1_5a) | 5d41c20 | 3+4 PASS | 1 code-reviewer, 0 P0 |
| (closeout) | 663f804 | — | — |

## Deliverables (all new files, P1)
- `.tad/scripts/scan-collisions.sh` — grep-seed detector over the canonical `.claude/skills/` tree (2.2s; LC_ALL=C CJK-safe pre-filter; atomic write; BSD-safe; NOT a hook)
- `.tad/scripts/collision-signatures.txt` — 3 @@@-delimited opposing-directive seed signatures
- `.tad/capability-packs/pack-collisions.yaml` — 3 confirmed collisions (registry)
- `.tad/guides/pack-collision-detection.md` — precedence engine + LLM-confirm contract + anti-theater rule
- `.tad/evidence/fixtures/pack-collisions/{inter,contrast,pyramid}.md` — 3 fixtures
- P2: additive `5b` (alex step4_5) + `2.5` (blake 1_5a) surfacing — constraint counts held (132/49)

## The 3 real collisions (hand-re-derived live)
1. **inter-font** (cross-category → AUTO): web-ui-design bans Inter as primary typeface (SKILL.md:93) vs web-frontend loads Inter via next/font (performance.md:215) → performance>style, web-frontend wins, loser quote logged for human spot-check.
2. **contrast-standard** (same-category a11y → ESCALATE): web-ui-design APCA (SKILL.md:454) vs web-frontend/web-testing WCAG 4.5:1 (accessibility.md:45) → precedence can't break a tie → human decides.
3. **testing-pyramid** (same-category correctness → ESCALATE): web-frontend 60%/cut-E2E (testing.md:15) vs web-testing 70%/more-E2E-for-UI (test-strategy-rules.md:25).

## Process highlights
- **Anti-theater paid off on the feature itself**: the scanner's 4th "bonus" candidate (web-ui-design×video-creation) was a FALSE POSITIVE from a CJK `comm` collation bug (missing LC_ALL=C); the feature's own hand-re-derivation discipline caught the bug, which was then fixed.
- **Two YOLO Conductors, one repo, zero conflict**: ran concurrently with the lean-trustworthy Epic (P4/P5). Scoped `git add` + new-files-only (P1) + additive-only (P2) → interleaved commits to main, no collision. The other Alex's Epic completed + archived mid-run, unblocking P2.
- **15+ sub-agents**: 6 scouts → 1 design → 2+2 reviewers → 2 Blake impl → 2+1+1 reviewers/fixes. 0 P0 at every gate after fixes.

## Knowledge captured
- code-quality.md: "`comm -12` set-intersection of CJK keyword lists needs `LC_ALL=C` on BOTH sorts AND the comm" (Blake, Gate 3).
- architecture.md: "Pack Collision Detection is an Orthogonal Axis to Per-Pack Eval; Apply the Anti-Theater Spot-Check to the Detector's OWN Bonus Findings" (Alex, Gate 4).

## Follow-ups (open)
- The surfacing one-liner could be richer (architect P2-B: carry loser quote in escalate form too — currently only auto carries it).
- `confirmed_by`/`drop_rationale` LLM-confirm fields are advisory (single-user enforcement stance) — fine for now.
- The signature seed set covers the 3 known pairs; new packs may introduce new collision classes (licensing/cost categories noted as P2-extensible in the guide).
