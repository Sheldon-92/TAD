# Phase 1 Gate Report (YOLO Y7) — Self-Deriving Release/Sync

**Verdict: Gate 3+4 PASS** (Conductor independently re-verified, anti-theater). 2026-06-01.
Commits: 16dbe1a (impl) + 904cec2 (P1 fix).

## AC verification (Conductor re-run, not Blake's word)
| AC | Check | Result |
|----|-------|--------|
| AC1/AC7 set-equality | `diff <(--dirs) <(live ls-minus-deny)` | empty ✅ (membership, NOT pinned count) |
| AC-exclusion (highest stakes) | `--dirs \| grep -cxE <deny>` | **0** ✅ no zero-touch leak → no downstream clobber |
| structure-resilience | `--dirs \| grep -cx codex` | 1 ✅ codex auto-included (literal `codex` 0× in lib) |
| version gate | `version . 2.21.0 2.19.0` | 5 survivors (62→5 post-fix), all genuine NEXT.md history; exit 1 ✅ |
| structural | self==self | exit 0 ✅ |
| AC6 wiring | release-verify in alex SKILL | 4 (publish+sync) ✅; settings.json=0 ✅ |
| AC5 demote | runbook illustrative/DERIVED markers | 4 ✅ |
| bash -n | both libs | clean ✅ |

## Review summary
2 design reviewers (4 P0 → fixed v2) + 2 impl reviewers (0 P0, convergent P1 version-noise → fixed). Both
impl reviewers independently RE-RAN the dogfood (not theater): exclusion safe, omission→exit 1, version
discriminates. Structure-resilience genuinely achieved; DENY_LIST is the sole hardcoded constant (deny-list
fails open-safe vs allow-list fails closed-wrong).

## P2 follow-ups (non-blocking, recorded)
1. NEXT.md/worklog over-reports 5 historical version lines in version-scope — tune exclusion (prefer-false-positive accepted; shadow mode guards first cutover).
2. P2 tad.sh must add a drift check that its inlined deny-list == derive-sync-set.sh's DENY_LIST (curl-fresh-machine can't source the lib).
3. First real release MUST use TAD_RELEASE_GATE=warn (shadow) before flipping to hard-block.
