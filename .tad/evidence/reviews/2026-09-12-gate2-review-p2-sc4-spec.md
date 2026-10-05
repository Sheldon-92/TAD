---
gate: 2
handoff: HANDOFF-20260912-p2-sc4-process-tax-cut-wire.md
reviewer: Gate 2 Reviewer (Spec & Pathspec) — independent; not Alex
date: 2026-09-12
verdict: PASS
counts:
  P0: 0
  P1: 0
  P2: 2
---

# Gate 2 Review — Spec & Pathspec

**Handoff:** `.tad/active/handoffs/HANDOFF-20260912-p2-sc4-process-tax-cut-wire.md`  
**Design:** `.tad/evidence/designs/2026-09-12-p2-sc4-process-tax-cut-wire.md`  
**Role:** independent Spec & Pathspec reviewer. Not Alex. Not Blake. No implement. No publish/bump/tag. NO Gemini.

**State:** Judge: independent sub-agent; producer identity not provided.

**Tree snapshot (this review):** `git status --short` shows this-knife tracked mods plus untracked create-set, plus a large pre-existing dirty rider set. `git diff --stat --` on §7 **tracked** paths: 8 files, 53 insertions, 1 deletion. Untracked §7 creates (`docs/process-tax-cut.md`, `patterns/process-tax-cut.md`, Epic, this handoff) do not appear in `git diff --stat` (expected; they are `??`). Design path is gitignored-local (handoff §7.1: do not force into commit).

---

## Per-check table

| ID | Check | Result | Notes |
|----|-------|--------|-------|
| C1 | §9.1 Methods legal (command/path-check) not prose-only; post-impl rows 12–13 exist | **PASS** | Rows 1–13 Methods are backtick commands (`grep`/`test`/`awk`/`git diff-tree`/`git show`). Grammar block states LEGAL vs ILLEGAL. Rows 12–13 present, typed `post-impl-verifiable`, Verified Output `(post-impl)`. Rows 1–11 pre-impl with Alex step1d HIT notes. |
| C2 | Pathspec §7 vs landed files; hunk rule for `_index.md` and `ac-verification.md` explicit and sufficient | **PASS** | Landed WT matches §7.1/§7.2. Mixed-file hunk rules name include/exclude text. See C2 body. |
| C3 | Out-of-scope held: no SKILL/hooks, no publish, no historical handoff wholesale rewrite | **PASS** | §7 contains none of those classes. MQ/Design Out + §7.3 riders. Implementation = pathspec commit only. |
| C4 | AC9 residual grep does not self-leak into templates | **PASS** | Exact ban strings absent under `.tad/templates` and `.tad/tasks`. Examples remain in SSOT/pattern only (in-scope). |
| C5 | Dirty-tree adjudicate: no P0 on listed pre-existing dirt unless whole-tree fence | **PASS** | No whole-tree fence. Riders labeled FALSE_POSITIVE with pointers. |
| C6 | Teeth: dual review + Alex≠Blake not cut | **PASS** | MQ/Intent/Epic/Design/pattern/template Gate 2 + §9.2 + release Gate Criteria + handoff-creation all keep dual disk review and role switch. |

---

## C1 — §9.1 Method legality

Landing Methods (rows 1–11) and post-impl Methods (12–13) are commands, not prose-only cells.

| # | Type | Method kind | Legal? |
|---|------|-------------|--------|
| 1 | pre-impl | `grep -F` path | yes |
| 2 | pre-impl | `grep -F` path | yes |
| 3 | pre-impl | `test -f && grep -cE` | yes |
| 4 | pre-impl | `grep -F` path | yes |
| 5 | pre-impl | section-scoped `awk` \| `grep -F` | yes |
| 6 | pre-impl | section-scoped `awk` \| `grep -F` | yes |
| 7 | pre-impl | `grep -F` path | yes |
| 8 | pre-impl | `grep -F` path | yes |
| 9 | pre-impl | `grep -RInE` templates+tasks; `echo EXIT:$?` | yes |
| 10 | pre-impl | `grep -F` path | yes |
| 11 | pre-impl | `grep -F` path | yes |
| 12 | **post-impl** | `git diff-tree --no-commit-id --name-only -r HEAD` | yes |
| 13 | **post-impl** | `git show HEAD -- …ac-verification.md \| grep -cF` | yes |

**AC realism note in the handoff is applied correctly:** 12–13 cannot PASS on unmodified HEAD (no this-knife commit); 1–11 are intended to PASS on the landed WT. That is the right failure mode, not theater.

No C1 P0/P1.

---

## C2 — Pathspec vs landed; hunk rules

### §7 vs disk

| §7 path | On disk | git | In commit set? |
|---------|---------|-----|----------------|
| `patterns/process-tax-cut.md` | yes (Layer-2 + three `## 1)`/`## 2)`/`## 3)` headings + SSOT cite) | `??` | yes (7.1 + 7.2.11) |
| `HANDOFF-20260912-p2-sc4-process-tax-cut-wire.md` | yes | `??` | yes |
| `designs/2026-09-12-p2-sc4-process-tax-cut-wire.md` | yes | gitignored | **no** (explicit) |
| `docs/process-tax-cut.md` | yes | `??` | yes (7.2.1) |
| Epic `EPIC-20260912-p2-process-tax-cut.md` | yes; SC4 `[x]` | `??` | yes (7.2.2) |
| `patterns/_index.md` | Process Tax Cut bullet + AC Verification suffix | `M` | yes *(hunk)* |
| `patterns/ac-verification.md` | 2026-09-12 entry at head; 2026-09-10 entries below | `M` mixed | yes *(hunk only 2026-09-12)* |
| `templates/handoff-a-to-b.md` | Gate 2 disk-only + §9.1 AC realism + §9.2 disk completeness | `M` | yes |
| `templates/acceptance-verification-guide.md` | AC realism block in first 20 lines | `M` | yes |
| `spec-compliance-format.md` | Layer 2 dirty-tree adjudicate section | `M` | yes |
| `git-workflow-format.md` | Red Flag: pathspec vs dirty-tree P0 | `M` | yes |
| `release-handoff.md` | Gate Criteria Gate 2 = dual files on disk | `M` | yes |
| `tasks/handoff-creation.md` | Process Gate 2 disk-only in first 20 lines | `M` | yes |

`git diff --stat --` on those tracked §7 paths: `_index.md` 3 lines; `ac-verification.md` 19 lines (see hunk split below); six template/task files +45 net. Untracked creates are the rest of the commit set via `git add --`, not `git add -A`.

### Hunk rules — explicit and sufficient

**`_index.md` (step 2):** include only (a) AC Verification suffix `, AC realism, vacuous AC` and (b) the new `Process Tax Cut` bullet. Current `git diff` is a single hunk that is exactly those two edits. No foreign ticket in this file’s WT delta. Rule is explicit; whole-file add would coincidentally be clean **today**, but the hunk instruction still matches the mixed-file policy.

**`ac-verification.md` (step 3 + AC13):** include only heading `### Process tax-cut: AC realism — 2026-09-12`. Leave unstaged the two **2026-09-10** entries (confirmed present below the first 20 lines: “Gitignored fixtures…” and “Pathspec-in-scope files…”). WT `git diff` is two hunks: (1) +5 lines at file head = this knife; (2) +14 lines at EOF = both 2026-09-10 entries as one contiguous insert. Leaving hunk (2) unstaged implements the rule. Whole-file `git add` would fail AC13 (`grep -cF -- 'Gitignored fixtures can PASS Gate 4'` expected 0). Sufficient to prevent the known mixed-ticket failure.

**P2-1:** AC13 fingerprints only the first 2026-09-10 token. The two 2026-09-10 entries share one hunk, so staging one without the other is not the default `add -p` grain. Residual: a split-hunk error that staged only the second 2026-09-10 entry would not trip AC13. Not P0: the written leave-unstaged rule names **both** entries.

**P2-2:** Steps say “Hunk-stage” without naming `git add -p` vs `git apply --cached`. The 2026-09-10 pattern (unstaged, correctly) documents the latter. Blake can execute from the named include/exclude strings. Not P0.

No C2 P0.

---

## C3 — Out-of-scope held

Contract Out / §7.3 / Design Out: GM P0/P1, KEEP11, publish/bump/tag, SKILL/hooks, L1 `principles.md`, wholesale historical handoffs, absorbing dirty NEXT / brain-index / 2026-09-10 ac-verification.

§7 pathspec has **zero** `.claude/skills`, `.tad/hooks`, release-runbook publish, tag/bump, or historical `HANDOFF-*`/`COMPLETION-*` rewrite targets. Mode: docs-only; Blake = pathspec-only commit; no push/tag/bump/release. v2.44.5 called out as a separate active handoff — do not absorb.

C3 **PASS**. Historical handoff `M`/`D`/`??` in `git status` are **not** this delta (see C5).

---

## C4 — AC9 residual grep / template self-leak

AC9 Method (unescaped):  
`grep -RInE -- 'blocked until user runs /gate 2|READY_FOR_BLAKE only after human Gate 2 command' .tad/templates .tad/tasks`

Independent replay: **no matches** in `.tad/templates` or `.tad/tasks`. Expected `EXIT:1` (no content).

Ban *examples* of those exact strings live in `docs/process-tax-cut.md` §3 and `patterns/process-tax-cut.md` §3 — AC9 Expected Evidence explicitly allows that and forbids them as dispatch text in templates. Handoff-a-to-b Gate 2 uses allowed wording (“Do **not** write a dispatch lock that waits for a human chat string `/gate 2`”) without embedding the banned literals. `test-brief-template.md` “wait for human feedback” is a different string; out of AC9.

C4 **PASS**. No template self-leak of the AC9 needles.

---

## C5 — Dirty-tree adjudicate (FALSE_POSITIVE)

This contract **does not** claim a clean whole-tree fence. §7.3 lists dirty riders. Applying `docs/process-tax-cut.md` §2 / spec-compliance-format Layer 2 block:

| path / class | P0 vs FALSE_POSITIVE | pointer |
|--------------|----------------------|---------|
| `NEXT.md` | FALSE_POSITIVE | §7.3; Design Out “pre-existing dirty NEXT” |
| `PROJECT_CONTEXT.md` | FALSE_POSITIVE | §7.3 |
| `docs/pm/now.md` | FALSE_POSITIVE | §7.3 |
| `.tad/brain-index.md` | FALSE_POSITIVE | §7.3 |
| `HANDOFF-20260911-release-v2445.md` + COMPLETION twin (`??`) | FALSE_POSITIVE | §7.3 “publish v2.44.5 handoff”; Notes “Do not absorb v2.44.5” |
| leftover twins (`HANDOFF/COMPLETION-20260908-knowledge-seam*`, `*-20260910-verify-delta*` M/D; other `??` release 2443/2444) | FALSE_POSITIVE | §7.3 leftover twins |
| `.tad/eval/judge/bundles/*` | FALSE_POSITIVE | §7.3 |
| 2026-09-10 `ac-verification.md` entries (WT hunk 2) | FALSE_POSITIVE | §7.3; FR7; step 3; AC13 |
| `session-state.md` (named in §7.3; not required in this status slice) | FALSE_POSITIVE | §7.3 |

**Do not raise P0** on those classes. In-delta dirt would be a §7 path with an unspecified extra hunk; `_index.md` has none; `ac-verification.md` extra hunk is the labeled 2026-09-10 rider.

C5 **PASS**.

---

## C6 — Teeth not cut

| Surface | Dual independent Gate 2 | Alex ≠ Blake |
|---------|-------------------------|--------------|
| Handoff MQ / Intent | “dual Gate 2 reviews; Alex ≠ Blake”; “Not: cut dual review; not merge Alex/Blake” | held |
| Handoff §9.2 | two named independent reviewers; “Dual files on disk = process Gate 2” | human `当 Blake` for switch |
| Epic teeth table | min 2 independent review files | fresh Blake; no `-c` onto other role |
| Design Teeth | dual independent review stays | Alex ≠ Blake stays |
| `patterns/process-tax-cut.md` | min 2 stay; does not skip review | Alex ≠ Blake stays |
| `handoff-a-to-b.md` Gate 2 | dual artifacts under `.tad/evidence/reviews/` | Human still says `当 Blake` |
| `release-handoff.md` Gate Criteria | two independent review files on disk | Role switch still `当 Blake` |
| `handoff-creation.md` | dual independent reviews on disk | role switch = `当 Blake` |
| spec-compliance-format | adjudication is not a skip of the second reviewer | — |

Layer 2 still required (tax = adjudicate, not skip). C6 **PASS**.

---

## Findings

### P0

None.

### P1

None.

### P2

1. **P2-1** AC13 unique-token is only `Gitignored fixtures can PASS Gate 4`. The second 2026-09-10 entry is co-hunked today; a future split could evade AC13. Optional Blake/follow-up: second `-cF` on `Pathspec-in-scope files can still carry a foreign hunk`. Does not block Gate 2.
2. **P2-2** Hunk-stage HOW is unnamed (`add -p` vs `git apply --cached`). Include/exclude strings are enough. Does not block Gate 2.

---

## Verdict

**PASS** (P0=0). Spec completeness, Method legality, pathspec, hunk rules, out-of-scope, AC9 non-leak, dirty-tree adjudication, and teeth all hold. Promote to READY_FOR_BLAKE when the paired load-surface Gate 2 review is also PASS with P0=0. Blake: pathspec-only commit; hunk-stage mixed files; no push/tag/bump.

verdict: PASS
