# Phase 1 Design Review — code-reviewer lens

**Handoff:** `.tad/active/handoffs/HANDOFF-surplus-local-skill-capture.md` (v3.1.0)
**Reviewer:** code-reviewer (YOLO Epic Phase 1 design review)
**Date:** 2026-07-05
**Verdict:** CONDITIONAL PASS — no blockers; 2 P1 coverage gaps should be closed before Gate 3 relies on §9.1 as the sole verifier.

---

## Scope of review
File-list completeness · AC verifiability · frontmatter correctness · design coherence (requirements ↔ technical design ↔ ACs). Isolation claims were independently re-grounded against the live repo.

## Independent grounding (re-verified, not taken on faith)

| Claim in handoff | My check | Result |
|---|---|---|
| tad.sh copies only skill DIRS, `local/` dir would be copied if present (§2.2, MQ2) | `sed -n '804p' tad.sh` | ✅ `for skill_dir in "$src"/.claude/skills/*/` confirmed |
| tad.sh copy is **additive per-dir `cp -r`, no mirror-delete** (basis for AC6 "never overwritten by install") | grep for `rm -rf .../skills`, `rsync --delete` in copy block | ✅ none — target-side `local/` survives reinstall. Claim holds. |
| derive-sync-set.sh never touches `.claude/skills` | `grep -c skills derive-sync-set.sh` | ✅ `0` |
| release-verify FR7 tolerance present | `grep -c local-skill release-verify.sh` | ✅ `7`; L193-217 treats `Only in $TGT` as INFO |
| `.gitignore` does not yet ignore local/ | `grep -c '^\.claude/skills/local/$'` | ✅ `0` |
| 0 tracked files under local/ (AC10 premise) | `git ls-files` | ✅ `0` |
| Working frontmatter = name/description/trigger (AC1) | `head surplus/SKILL.md` | ✅ all 3 keys present |
| Flat `.md` under skills/ not loaded (deviation rationale) | `doc-organization.md` exists but absent from live skill list | ✅ confirmed — directory-form pivot is justified |

**Grounding is accurate.** The §2.2/§7.3 evidence matches reality; the Epic-literal `save-skill.md` → directory-form correction is correct and necessary (a flat file would never trigger).

---

## Findings

### P0 (blocking) — none

The design is coherent and complete for its scope. Every grep-target AC string is specified **verbatim** in §4.2 (I mapped each AC → spec line: AC2→"MUST NOT write any file before the user confirms the draft", AC3→"OVERWRITE GUARD", AC5→"MUST NOT be auto-invoked", AC6→"local: true" + "never synced"). The isolation model is grounded at all three distribution surfaces. Frontmatter metadata is fully and correctly filled. No data-loss, correctness, or scope-safety blocker.

### P1 (should fix)

**P1-1 — FR1 flow completeness has no verifier; the "nothing-capturable → STOP" edge is an orphaned test.**
§9.1 is declared *"PRIMARY VERIFICATION SOURCE — Gate 3 executes each row."* Yet AC1–AC14 verify only: frontmatter keys, four isolated constraint strings, path/kebab literals, line count, and isolation. **No AC confirms Step 1 (Scan, incl. "if nothing capturable → say so and STOP") or Step 6 (Report) exist.** §8.3 lists the nothing-capturable case as "文本验证" but there is **no corresponding §9.1 row** — so per the handoff's own rule (Gate 3 executes §9.1 rows), that check will never run. A SKILL.md missing the Scan-stop guard and the Report step would pass all 14 ACs. This is the "coverage gate blind to must-cover content" pattern from principles.md (2026-06-01). *Fix:* add AC rows grepping for the Step 1 stop semantics (e.g. `grep -c 'nothing capturable'` or an equivalent anchor Blake must include verbatim) and a Step 6 report anchor.

**P1-2 — Fixture "schema validation" is validation theater; AC13 does not check the schema.**
§8.2 states the fixture "验证 … schema、index 行格式" and lists the required body sections (`When to use / When NOT to use / Steps / Example / Gotchas`). But AC13 only greps `local: true` + `_example` in the index. A fixture missing every body section still passes. This is exactly the "13/13 installed proves file ops, not functional quality" trap from principles.md (2026-05-15 YOLO audit). *Fix:* extend AC13 to assert the five `## ` section headers are present in `_example.md` (e.g. `grep -cE '^## (When to use|When NOT to use|Steps|Example|Gotchas)$'` → `5`).

### P2 (nice to have)

**P2-1 — AC4 verifies a regex-literal appears in prose.** `grep -c '\[a-z0-9-\]+'` proves the string `[a-z0-9-]+` is somewhere in the body, not that the kebab-case rule is actually explained. Weak proxy; can pass while the rule is opaque. Acceptable as a smoke alarm, but note it is not a real semantic check.

**P2-2 — AC14 scope-exclusion regex is over-broad (false-negative surface).** The exclusion alternation contains bare `COMPLETION` (matches *any* completion file) and `EPHEMERAL-surplus` (matches *any* surplus epic). If Blake accidentally modified a **sibling** surplus epic or an unrelated completion, AC14 would not flag it. Tighten to the specific filenames for this task (`COMPLETION-…-local-skill-capture`, `EPHEMERAL-surplus-local-skill-capture`).

**P2-3 — Two documented behaviors have no AC.** FR7 "SKILL.md documents the load path (read index → match → Read file)" and the Step-6 "local-only reminder" are specified in §4.2 but unverified. Low risk; add anchors only if cheap.

**P2-4 — §10.2 release-verify sync-mode SRC-side caveat is correct but should be surfaced in the shipped SKILL.md.** If sync mode ever runs with a *dirty TAD working copy* as SRC, an untracked `local/` shows as `Only in $SRC/.claude/skills: local` → FR7 only tolerates the `$TGT` side → `real_diffs` FAIL. The handoff correctly rules this out of scope (pull-based distribution uses a clean clone as SRC), but a one-line note in the shipped `save-skill/SKILL.md` body would save a future maintainer the surprise.

---

## Dimension verdicts

- **File-list completeness:** ✅ Complete. All four touched paths listed (create: save-skill/SKILL.md, local/_example.md, local/_index.md; modify: .gitignore). Isolation is verify-only — correctly does **not** add distribution-surface edits (NFR3 enforced by AC11/AC14). No missing file.
- **AC verifiability:** ⚠️ Mostly strong — 14/14 rows are runnable commands with expected outputs, and every grep target is pinned verbatim in the spec. Gap: flow-completeness + fixture-schema not covered (P1-1, P1-2).
- **Frontmatter correctness:** ✅ `task_type: mixed`, `e2e_required: no` (justified — interactive confirm loop is human-only, deferred to Gate 4 per §8.4), `research_required: no`, `git_tracked_dirs: [".claude/skills/save-skill"]` correctly lists the tracked dir and **deliberately excludes** the gitignored `local/` with an explanatory note. All fields filled and correct.
- **Design coherence:** ✅ Strong. Requirements ↔ design ↔ ACs align; the directory-form deviation is grounded; the skillify/T1 SAFETY boundary (§10.1) is correctly distinguished (user-explicit sanctioned handoff path vs. unattended materialization); the gitignore-at-git-source isolation is the most-upstream cut and defensible.

## Recommendation
Proceed to implement. Close **P1-1** and **P1-2** by adding two AC rows (flow-step anchors + fixture section-header check) so Gate 3's §9.1 execution actually covers FR1 flow and the fixture schema, rather than only isolated constraint strings.
