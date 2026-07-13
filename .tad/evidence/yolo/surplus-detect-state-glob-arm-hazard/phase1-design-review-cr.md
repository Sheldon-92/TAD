# Phase 1 Design Review — code-reviewer lens

**Handoff:** `.tad/active/handoffs/HANDOFF-surplus-detect-state-glob-arm-hazard.md`
**Reviewer:** code-reviewer (bash quoting / `set -e` / BSD-portability / AC verifiability)
**Date:** 2026-07-05
**Verdict:** CONDITIONAL — 1 P1 must be fixed before Gate 3; design is otherwise sound and ground-truth-accurate.

> Note: this file previously held the 2026-07-02 review of the superseded dot-bounded-glob design. That approach was replaced by the `_tad_ver_cmp` refactor now live in main; this review targets the current fixture-only handoff.

---

## Ground-Truth Verification (I re-ran the handoff's own evidence)

| Claim | Command | Result | Match |
|---|---|---|---|
| 0 order-sensitive 2.x glob arms | `grep -cE '^[[:space:]]*2\.[0-9]+\*\)' tad.sh` | `0` | ✅ |
| `TARGET_VERSION="2.33.0"` | `grep -m1 '^TARGET_VERSION='` | `2.33.0` | ✅ |
| Function line numbers | `grep -nE '^_tad_ver_cmp\(\)|^detect_state\(\)'` | 1330 / 1343 | ✅ |
| tad.sh syntax valid | `bash -n tad.sh` | OK | ✅ |
| Extraction range safe (single col-0 `}` per func) | `sed -n '1330,1373p' \| grep -nE '^\}'` | braces only at 1341 & 1373 | ✅ |

The `detect_state` logic matches §2.2 exactly: same-major-older returns `upgrade` **before** the cross-major `case`, so a 2.x input structurally cannot reach the v1.x arms under the current code. The redesign genuinely eliminated the hazard class; the task is correctly scoped as "pin behavior," not "fix." Frontmatter (`task_type: code`, `e2e_required: no`, `research_required: no`, `git_tracked_dirs: [".tad/tests"]`, `skip_knowledge_assessment: no`) is all correct for this task shape.

---

## P0 (Blocking) — none

---

## P1 (Should fix before Gate 3)

### P1-1 — AC8 second sub-check produces a false FAIL in the real repo state
AC8 (§9.1) verifies scope discipline with:
```
git status --porcelain | grep -v 'detect-state-fixture.sh\|phase1-fixture-run.txt\|HANDOFF-surplus\|COMPLETION' | wc -l   # expected 0
```
I ran this **now, before any implementation**, and it returns **9**, because the working tree already contains unrelated untracked/modified paths the grep filter does not exclude:
`SURPLUS-PLAN-2026-07-05.{md,json}`, `EPHEMERAL-surplus-*.md` (×2), `.tad/active/handoffs/`, `.tad/evidence/traces/2026-07-0{4,5}.jsonl`, `.tad/evidence/decisions/2026-07-05.jsonl`, and ` M .tad/research-notebooks/REGISTRY.yaml`. In addition, this review and the other Conductor design-review artifacts land in `.tad/evidence/yolo/surplus-detect-state-glob-arm-hazard/`, which the filter also does not exclude.

Consequence: Gate 3 reports AC8 FAIL regardless of Blake's correctness — exactly the "false-red trains the operator to ignore the gate" failure mode the project's own principles warn against. The FIRST sub-check of AC8 (`git diff --stat -- tad.sh | wc -l` == 0) already fully proves the load-bearing "tad.sh untouched" claim.

**Fix (pick one):**
- Drop the brittle `git status --porcelain` sub-check; keep only `git diff --stat -- tad.sh` (sufficient for tad.sh-untouched); or
- Restrict the scope check to **tracked** production files only, ignoring untracked evidence/plan/trace artifacts that are legitimately present and outside Blake's control (e.g. `git diff --name-only | grep -vxc 'tad.sh'` == 0 for the tracked surface), and stop diffing `git status --porcelain` wholesale.

---

## P2 (Nice to have)

### P2-1 — AC3 is a compound row and drops the handoff's own `|| true` discipline
AC3 chains four independent assertions (exit code, PASS count, hazard-case count, `current` count) in one command, none carrying `|| true`. Lesson 1 (📚) and sibling ACs (AC1/AC4/AC5/AC6 all append `|| true`) establish the convention; AC3 is inconsistent. `grep -c 'current'` returns exit 1 on zero matches — if the Gate 3 runner executes the row under `set -e`, a legitimately-zero intermediate grep aborts the row, and a single FAIL is hard to attribute to a specific sub-check. Split AC3 into AC3a–AC3d, or at minimum append `|| true` to each grep as the rest of the table does.

### P2-2 — The negative self-check (discriminative power) is required evidence but not an AC
The fixture's entire value is that it goes RED on regression. That is captured as a Phase-1 「完成证据」 item and a Human审查问题 (§6.1 step 2, §8.6), but no numbered AC pins it, so a mechanical gate cannot confirm it happened. Given the project's explicit "structural PASS ≠ behavioral quality" stance, consider an AC that greps the completion report for the recorded red→green flip (expected-vs-actual FAIL line + exit 1), making the discriminative-power proof first-class rather than prose-only.

### P2-3 — `.tad/tests/detect-state-fixture.sh` git-tracking requires an explicit `git add`
AC2 (`git ls-files ... | wc -l` == 1) only passes once the new file is staged, but no micro-task tells Blake to `git add` it (a fresh untracked file returns 0 from `git ls-files`). Add an explicit "stage the fixture" step so AC2 isn't a surprise FAIL.

### P2-4 — §7.1 "Files to Create" omits the completion report referenced by AC8
AC8's exclusion filter names `COMPLETION`, implying a completion-report artifact, but §7.1/§7.2 don't list it. Minor doc-completeness gap; list it so the produced-file set is exhaustive.

### P2-5 — `eval "$(grep -m1 '^TARGET_VERSION=' tad.sh)"` is acceptable but avoidable
`eval` on a grepped line from a trusted repo file is safe here, and `-m1` is BSD/macOS-portable (satisfies NFR1). A non-eval parse (`... | sed 's/.*="\([^"]*\)".*/\1/'`) removes the eval surface at no cost. Optional hardening.

---

## What is solid (keep as-is)
- **No-source / sed-extraction decision** correctly avoids the unguarded `main` at EOF; extraction range verified to terminate at the right col-0 `}` for both functions.
- **NFR2 bash guard** (`[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"`) is the right defense for the empirically-found zsh `local -a A=($1)` word-split hazard (lesson 4); AC5 verifies its presence.
- **FR6 evergreen expectation** (`upgrade` iff `tmaj==2` else `old`) matches the code's cross-major fall-through and survives a future 3.x bump — I traced 2.19.1 under hypothetical target-major 3 → `*) old`, consistent with FR6.
- **Fail-safe undecidable input** (`abc → old`, lesson 2) and never-downgrade (`9.9.9 → current`) both trace correctly through the live body.
- Full FR3 case matrix reproduces against the current `detect_state`. File list (fixture + run evidence) is complete for the production surface.

---

## Recommendation
CONDITIONAL PASS. Fix **P1-1** (mandatory — it false-FAILs today). Fold in P2-1 and P2-2 given the project's anti-validation-theater posture. Remaining P2s are polish. No tad.sh change warranted; FR1 pre-verification holds (0 arms).
