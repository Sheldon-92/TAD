# Layer 2 — Scope / Hunk Review — TASK-20260912-P2-SC4-TAX-CUT-WIRE

- **Handoff:** `.tad/active/handoffs/HANDOFF-20260912-p2-sc4-process-tax-cut-wire.md` (§5 + §7)
- **Impl commit:** `86c89917c4e1731a9068e83ecfad22df5e0e804e`
- **Reviewer:** scope-hunk-reviewer (Layer 2 — independent; not Alex, not Blake-implementer)
- **Date:** 2026-09-12
- **Method:** `git diff-tree` / `git show` / `git check-ignore` / `git status --short` / `git tag --points-at`, all re-run independently. Read-only; no files modified by this review.

## 1. File set — `git diff-tree --no-commit-id --name-only -r 86c89917` (12) vs §7.1/§7.2

| # | Path in commit | §7 ref | Match |
|---|---------------|--------|-------|
| 1 | `docs/process-tax-cut.md` | §7.2-1 | YES |
| 2 | `.tad/active/epics/EPIC-20260912-p2-process-tax-cut.md` | §7.2-2 | YES |
| 3 | `.tad/project-knowledge/patterns/_index.md` (hunk) | §7.2-3 | YES |
| 4 | `.tad/project-knowledge/patterns/ac-verification.md` (hunk) | §7.2-4 | YES |
| 5 | `.tad/templates/handoff-a-to-b.md` | §7.2-5 | YES |
| 6 | `.tad/templates/acceptance-verification-guide.md` | §7.2-6 | YES |
| 7 | `.tad/templates/output-formats/spec-compliance-format.md` | §7.2-7 | YES |
| 8 | `.tad/templates/output-formats/git-workflow-format.md` | §7.2-8 | YES |
| 9 | `.tad/templates/release-handoff.md` | §7.2-9 | YES |
| 10 | `.tad/tasks/handoff-creation.md` | §7.2-10 | YES |
| 11 | `.tad/project-knowledge/patterns/process-tax-cut.md` | §7.1-create + §7.2-11 | YES |
| 12 | `.tad/active/handoffs/HANDOFF-20260912-p2-sc4-process-tax-cut-wire.md` | §7.1-create + §7.2-12 | YES |

Count = 12, no more, no fewer. §7.1 third entry (design file) is gitignored-local and correctly excluded. **PASS.**

## 2. Hunk verdicts

| Check | Evidence | Verdict |
|-------|----------|---------|
| `_index.md` = exactly the 2-line change | `git show` stat 2 ins / 1 del; diff = AC Verification suffix `, AC realism, vacuous AC` (1 mod line) + new `Process Tax Cut` bullet (1 add line); no other hunks | PASS |
| `ac-verification.md` = only the +5-line 2026-09-12 head entry | `git show` stat 5 ins / 0 del; hunk = `### Process tax-cut: AC realism — 2026-09-12` + 3 body lines + blank; commit-hunk `grep -cE 'Gitignored fixtures can PASS Gate 4\|Pathspec-in-scope files can still carry a foreign hunk'` = 0 (no 2026-09-10 entries) | PASS |
| Design file gitignored + absent | `git check-ignore -v .tad/evidence/designs/2026-09-12-p2-sc4-process-tax-cut-wire.md` → `.gitignore:126:.tad/evidence/` (exit 0); `diff-tree \| grep evidence/designs` = 0 matches | PASS |
| §7.3 riders NOT in commit | `NEXT.md`, `PROJECT_CONTEXT.md`, `docs/pm/now.md`, `.tad/brain-index.md`, `session-state.md`, `judge/bundles/*`, publish v2443/44/45 handoffs each ABSENT from `diff-tree`; `grep -E 'v2443\|v2444\|v2445\|publish'` on commit names = no hits | PASS |

## 3. Dirty-tree adjudication — `git status --short` vs `docs/process-tax-cut.md` §2

No whole-tree fence contracted (§5 = pathspec-only; §7.3 = named riders). Outside-pathspec dirt → FALSE_POSITIVE (pre-existing) + pointer, not P0.

| Worktree path | Status | Adjudication | Pointer |
|---------------|--------|--------------|---------|
| `.tad/active/handoffs/COMPLETION-20260908-knowledge-seam-isolation.md` | M | FALSE_POSITIVE (pre-existing) | §7.3 leftover twins; §2 rules 1+2 |
| `.tad/active/handoffs/COMPLETION-20260910-verify-delta.md` | D | FALSE_POSITIVE (pre-existing) | §7.3 leftover twins; §2 rule 2 |
| `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md` | M | FALSE_POSITIVE (pre-existing) | §7.3 leftover twins; §2 rule 2 |
| `.tad/active/handoffs/HANDOFF-20260910-verify-delta.md` | D | FALSE_POSITIVE (pre-existing) | §7.3 leftover twins; §2 rule 2 |
| `.tad/brain-index.md` | M | FALSE_POSITIVE (pre-existing) | §7.3 named rider; §2 rule 2 |
| `.tad/project-knowledge/patterns/ac-verification.md` | M (unstaged remainder) | FALSE_POSITIVE — CONTRACTED remainder, not defect | §5 step 3 + §7.3 (2026-09-10 entries ordered unstaged) |
| `NEXT.md` | M | FALSE_POSITIVE (pre-existing) | §7.3 named rider; §2 rule 2 |
| `PROJECT_CONTEXT.md` | M | FALSE_POSITIVE (pre-existing) | §7.3 named rider; §2 rule 2 |
| `docs/pm/now.md` | M | FALSE_POSITIVE (pre-existing) | §7.3 named rider; §2 rule 2 |
| `?? COMPLETION-20260908-publish-v2443.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 publish v2443; §2 rule 2 |
| `?? COMPLETION-20260909-publish-v2444.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 publish v2444; §2 rule 2 |
| `?? COMPLETION-20260911-publish-v2445.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 publish v2445; §2 rule 2 |
| `?? COMPLETION-20260912-p2-sc4-process-tax-cut-wire.md` | ?? | Outside commit pathspec; post-commit report (not absorbed) | §7 commit set closed at 12; §2 rule 1 |
| `?? HANDOFF-20260908-release-v2443.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 publish v2443 handoff; §2 rule 2 |
| `?? HANDOFF-20260909-release-v2444.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 publish v2444 handoff; §2 rule 2 |
| `?? HANDOFF-20260911-release-v2445.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 publish v2445 handoff; §2 rule 2 |
| `?? .tad/eval/judge/bundles/keep11-knife1-cli-refresh.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 judge bundles; §2 rule 2 |
| `?? .tad/eval/judge/bundles/keep11-knife1.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 judge bundles; §2 rule 2 |
| `?? .tad/eval/judge/bundles/pack-freeze-inventory.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 judge bundles; §2 rule 2 |
| `?? .tad/eval/judge/bundles/pack-loader-thin-ondemand.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 judge bundles; §2 rule 2 |
| `?? .tad/eval/judge/bundles/verify-delta.md` | ?? | FALSE_POSITIVE (pre-existing) | §7.3 judge bundles; §2 rule 2 |

`session-state.md` exists on disk, is clean in this status slice, and is absent from the commit — no finding. No in-delta dirt (no §7 path carries an unspecified extra hunk).

## 4. Push / tag / release

| Check | Evidence | Verdict |
|-------|----------|---------|
| `git tag --points-at 86c89917` | empty (no output) | PASS — no tag |
| `git status -sb` | `## main...origin/main [ahead 1]` | PASS — 1 unpushed, correct per no-push charter |
| `git log origin/main..HEAD --oneline` | only `86c89917` (1 commit) | PASS — no extra commits |
| Bump/release in commit | `--stat` 12 files only; no version/package/tag files | PASS — no bump/release/push |

## Findings

- P0: 0.
- P1: 0.
- P2: 0.

## Verdict

**PASS** — file set exact (12/12 §7), hunks exact, riders excluded, design gitignored-absent, no push/tag. P0=0, P1=0, P2=0.
