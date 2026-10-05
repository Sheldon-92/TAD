# Layer 2 — Reviewer A (independent, spec-compliance)

Model: harness=claude-code | model=claude-opus-5 | route=host

**Verdict: PASS — NOT_SATISFIED = 0, PARTIALLY_SATISFIED = 1 (AC-7 as-written only)**

All §7 ACs re-run independently, no prior claim trusted:

| AC | Raw | Expected | Verdict |
|---|---|---|---|
| AC-1 | 0 | 0 | ✅ |
| AC-2 | 0 | 0 | ✅ |
| AC-3 (.claude + .agents) | 0 / 0 | 0 | ✅ |
| AC-3b (both) | 1 / 1 | ≥1 | ✅ |
| AC-4 (both) | 0 / 0 | 0 | ✅ |
| AC-5 | 0 | 0 | ✅ |
| AC-6 | exit=0 ×3, stderr_ERROR=0 | 0, no ERROR | ✅ |
| AC-7 | 3 | as-written 0; per-ruling 3 | ⚠️ |
| AC-N1 | 0 | 0 | ✅ |
| AC-N2 (both) | 8 / 8 | ≥1 | ✅ |
| AC-N2b (both) | 1 / 1 | 1 | ✅ |
| AC-N3 | 1 | 1 | ✅ |
| AC-N4 | 1 | 1 | ✅ |
| AC-N5 | exit=0 | 0 | ✅ |
| AC-N6 | 0 | 0 | ✅ |

## AC-7 verdict — explicit separation

**As-written:** expected 0, actual 3 → FAIL as-written.
**Per human ruling (2026-08-22):** the 3 hits are EXACTLY the ruled history files,
enumerated verbatim, no extras:
- `.tad/config.yaml:342` — v2.4.0 changelog line
- `.tad/migrations/2.42.0-to-2.42.0.yaml:9` — completed 2026-08-15 privacy migration
- `.tad/project-knowledge/patterns/ac-verification.md:668` — incident narrative

Required sub-checks: value-proposition.md `sync-registry` count = 0 ✅;
harvest-scan.sh count = 0 ✅. Baseline corroborated independently at `0566ee4d`:
13 → 3, eliminations exactly the 6 protocol files + 2 sync-ops + harvest-scan +
value-proposition.

**The gap is a defect in the AC's exclusion regex, not the implementation.**
Alex's addendum (pending) extends the regex; Blake did not edit source to make
the number go down (would brush NFR3).

## §4.2 comment placement — exact byte range

Comment occupies the exact range the 3 registration blocks vacated (L1537–1540),
between same anchors (`publish_protocol:` above, `# TAD Brain Protocol` below).
Both mirrors identical. ✅

## §4.1 deletion order — verified

Registry untracked (.gitignore:79, untracked since c2885b3c) → deletion invisible
to git diff; AC-1 (`ls`) = 0 confirmed it's gone. FR-6 disposition (harvest exit 0)
verified against the real post-deletion state → ordering invariant upheld
(hard-prohibition #5). Reviewer notes git cannot cryptographically prove
intra-worktree sequencing for an untracked file; substantive invariant holds.

## NFRs — all four verified

NFR1 tad.sh untouched (diffs empty, :245 intact) ✅ ｜ NFR2 derive-sync-set
untouched (TOP_DENY = 1) ✅ ｜ NFR3 history preserved (DR file present, decisions/
CHANGELOG untouched in diff) ✅ ｜ NFR4 *publish alive (×8, publish-protocol 10623B
both sides) ✅

## FR-7/FR-8 supplementary

sync-ops.md 194→14 lines, byte-identical mirrors (810B each). Correct per §4.4:
6 live referrers exist; deleting would dangle them and risk *publish.
No dangling refs to the 3 deleted protocol files — only the intentional
`git show 0566ee4d:` history pointers inside the retirement comment.
§4.3 branch choice confirmed: 方案 A mandatory (live caller at SKILL.md:1365);
stub prints the required "跨项目 harvest 已失效" notice.

## Result

**NOT_SATISFIED: 0 ｜ PARTIALLY_SATISFIED: 1 (AC-7 as-written) ｜ FULLY: 19/20
(20/20 under human ruling) ｜ Overall: PASS**