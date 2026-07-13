# Phase 3 Design Review — Code-Review Lens

**Handoff**: HANDOFF-20260713-native-capability-adoption-phase3.md
**Reviewer**: code-reviewer (Conductor-orchestrated, handoff-review workflow)
**Date**: 2026-07-13
**Focus**: file-list completeness, AC verifiability, frontmatter correctness, design coherence
**Verification**: all baseline claims independently re-run against source files (not paper-checked)

---

## Summary

Strong handoff. Spike-gated two-branch design is coherent, the single-writer boundary is
crisp, and the core success signal (`last_scan: null` → date) is genuinely behavioral, not
structural — directly answering the Phase 2 Validation-Theater lesson. Frontmatter is complete
and correct. File list is complete. All 13 ACs are mechanically runnable, and I independently
re-verified every AC1-AC3/AC8/AC10 baseline (all match the handoff's recorded outputs). Baselines
confirmed live: SKILL 567 lines; today-guard at L343; `non-interactive|headless` count = 0;
`last_scan: null` = 1; spike dir ABSENT; both `.agents` mirrors byte-identical; scan-log.yaml and
evidence/spikes both git-TRACKED (git_tracked_dirs smoke-alarm satisfiable).

No P0. Two P1s (both about a verifier's discriminative power, not correctness) and four P2s.
Recommend PASS-with-fixes: none block implementation; the P1 fixes tighten Gate-3 rigor.

---

## Verified Baselines (independent re-run)

| Claim | Handoff | My re-run | Match |
|-------|---------|-----------|-------|
| SKILL.md line count | 567 | 567 | ✅ |
| `last_scan: null` count | 1 | 1 | ✅ |
| today-guard line | L343 | L343 | ✅ |
| `non-interactive\|headless` count | 0 | 0 | ✅ |
| spike dir | ABSENT | ABSENT | ✅ |
| research-github mirror | IDENTICAL | IDENTICAL | ✅ |
| alex mirror | (implied) | IDENTICAL | ✅ |
| STEP 3.9 null-skip line | L374 | L374 | ✅ |
| suppress_if line | L398 | L398 | ✅ |
| inline routine prompt block | L465-484 | L466-487 (±1) | ✅ close |
| AC5 baseline (`gh search repos` in Setup→EOF) | (0 target) | **1 today** | ✅ discriminative |

The FR2 defect claim is real and verified: the Setup routine prompt (L466-487) inlines the scan
logic AND writes scan-log.yaml with no merge step (L478 "Write results to..." + full schema),
which contradicts the protocol's own Step 4 MERGE-write (L370-388). Rewriting it to delegate is
the correct fix, and it eliminates the drift the handoff describes.

---

## P0 — Blocking

None.

---

## P1 — Should Fix

### P1-1: AC4 verifies the guard TEXT exists, not that the branch FIRES — the load-bearing behavior lives only in AC9(ii)

AC4 is `grep -c 'non-interactive' >= 2` + `grep -c 'Already scanned today' >= 1`. That proves the
headless branch text was *added* and the interactive text was *retained* — a pure structural check.
The actual FR1 requirement — "headless context never calls AskUserQuestion" — is **only** exercised
by the spike's judgment (ii) ("scan 协议被解析且 headless 未触发任何交互 prompt") and the same-day
re-run edge case (§8.3). If the spike returns `Verdict: FAIL(i)` (gh auth invisible), the probe may
exit before ever reaching Step 1b, so the guard's non-prompting behavior would ship **completely
unverified** while AC4 still passes green.

Why it matters: this is the exact Validation-Theater pattern the handoff cites — AC4's green can
co-exist with a guard that has never actually run headlessly. The FR1 trigger is also purely
prompt-text-driven (the LLM fires the branch because it reads "non-interactive mode" in its own
context — there is no deterministic env signal), which makes the behavioral proof the *only* real
verification.

Recommendation: Add an AC (or extend AC9) that requires the **same-day headless re-run** discriminative
test (§8.3) to be logged in spike-evidence.md with the literal log-and-exit line, EVEN on the PASS
branch, and mark it `NOT_APPLICABLE_WITH_REASON: spike halted at (i)/(ii)` when the probe never
reached Step 1b. Right now §8.3's same-day test is described but not pinned to any AC row, so Gate 3
can skip it. Make the guard's non-prompting behavior a first-class AC, not prose.

### P1-2: AC9 PASS-branch expects `last_scan: null == 0`, but micro-task 7 (fixture removal) edits scan-log.yaml AFTER the flip — no guard that the real `last_scan` survives the cleanup

Sequence: MT5 spike flips `last_scan` null→2026-07-13 and writes real results; MT7 hand-removes the
`fake-rejected-fixture` entry. AC9 (`grep -c 'last_scan: null' == 0`) and AC7 (`grep -c 'fake-rejected-fixture'
== 0`) are both checked, but nothing asserts that MT7's edit **preserved** the flipped date and the
real scan results. A sloppy fixture removal (e.g., reverting the file, or editing `last_scan` back)
would leave AC7 green while silently corrupting the very behavioral evidence AC9 depends on — and
because AC9 only checks "not null", a stale/wrong date would still pass.

Recommendation: Add a positive assertion that after MT7, `last_scan` equals today's date
(`grep -c "last_scan: $(date +%F)" == 1`) AND that the spike-evidence before/after excerpt (§8.6)
captures the scan-log state *post-cleanup*, not just post-probe. Alternatively, order the evidence
capture to snapshot scan-log.yaml immediately after MT5 (before any hand-edit) so the behavioral
proof is frozen independently of the cleanup step.

---

## P2 — Nice to Have

### P2-1: AC5 `sed '/Setup: Scheduled Routine/,$p'` ranges to EOF — captures 4 unrelated sections

The sed range runs from L460 to EOF (L567), sweeping in Cross-Registry Sync Contract, Anti-Patterns,
Usage Examples, Quick Reference. Today those sections contain zero `gh search repos` (verified), so
AC5 is discriminative *now*. But if Blake (or a future edit) adds a `gh search repos` usage example
below the Setup section, AC5 would false-FAIL even after FR2 is done correctly. Bound the range to the
Setup section only, e.g. `sed -n '/## Setup: Scheduled Routine/,/^## Cross-Registry Sync Contract/p'`.

### P2-2: AC13 scope filter is over-loose — substring `alex` / `scan-log` can mask stray files

`grep -v -e 'research-github' -e 'alex' -e 'scan-log' -e 'cron-github-scan'` excludes any path that
merely *contains* those substrings anywhere. A stray `.tad/github-registry/some-alex-note.yaml` would
be silently allowed. Low practical risk (the four expected files are the only realistic churn), and
REGISTRY.yaml changes ARE still caught (verified) and double-covered by AC8. Consider anchoring to
basenames or exact paths for a cleaner scope gate. Noting, not blocking.

### P2-3: `claude -p` probe auth may not represent a true detached cloud routine — state the assumption

The probe is launched from Blake's already-authenticated terminal, so it inherits the interactive
session's env/keychain. A PASS(i) therefore proves "a locally-spawned headless process sees gh auth"
— which is *not* identical to "a scheduled cloud routine sees keychain auth". The grounding already
scopes `claude -p` as EQUIVALENT_SUBSTITUTE for gh-auth/skill-resolution and routes cron-fires-at-all
to the Conductor's +5min one-shot, and FR5/Friction-Preflight carry this honestly — so this is not a
gap in the design, only a gap in how the assumption is stated. Recommend spike-evidence.md explicitly
note "probe inherits interactive-session auth; true cloud-cron keychain access confirmed only by the
Conductor one-shot" so a PASS is not over-read.

### P2-4: FR4 AC11 checks the Chinese string `从未扫描` literally — brittle to wording drift

AC11 `grep -c '从未扫描'` hard-codes the exact nudge phrasing. If Blake writes an equivalent nudge
with slightly different wording (e.g. "尚未扫描过"), the AC false-FAILs a correct implementation. This
is FAIL-branch-only and conditional, so impact is bounded, but consider matching on the stable token
(the emoji `📡` + `*research-github scan`) rather than exact prose.

---

## Frontmatter Assessment

| Field | Value | Verdict |
|-------|-------|---------|
| task_type | mixed | ✅ correct (SKILL edits + headless spike) |
| e2e_required | yes | ✅ correct — the spike headless probe IS the behavioral e2e |
| research_required | no | ✅ correct — DR-20260712 + phase3-grounding.md exist |
| git_tracked_dirs | [spikes/cron-github-scan-2026-07] | ✅ satisfiable (dir is git-tracked, verified) |
| skip_knowledge_assessment | no | ✅ correct — spike verdict is exactly an assessable finding |
| gate4_delta | [] | ✅ acceptable (no downstream contract change) |

Frontmatter is complete and internally consistent. No missing fields.

---

## File-List Completeness

Complete. §7.2 correctly lists all five touched files including both `.agents` mirrors and the
data file scan-log.yaml (flagged as data-not-code). Cross-checked against FR1-FR5: every FR maps to
a listed file. The FAIL-branch-only files (alex/SKILL.md + its mirror) are correctly marked conditional.
No unlisted file is implied by any requirement. The `.agents/skills/alex/SKILL.md` mirror exists and
is currently byte-identical (verified), so the FAIL-branch AC10 cmp is satisfiable.

---

## Design Coherence

Requirements ↔ technical design ↔ ACs are tightly aligned:
- FR1 (headless guard) ↔ §4.2 Step 1b spec ↔ AC4 (+ spike ii) — coherent, see P1-1 on verification depth.
- FR2 (delegate prompt) ↔ verified real defect (L466-487 inline + no-merge) ↔ AC5/AC6 — coherent and discriminative.
- FR3 (spike) ↔ §4.3 fixture discrimination ↔ AC7/AC9 — the rejected-fixture-with-null-previous is a
  genuinely discriminative merge-write probe (GC rule only deletes `first_seen < previous last_scan`;
  previous=null ⇒ must preserve). Well-designed, see P1-2 on cleanup ordering.
- FR5 (Conductor boundary) ↔ grounding "sub-agent limitation" ↔ AC12 — coherent; substitution boundary
  honestly stated.
- honest_partial discipline: NOT_APPLICABLE_WITH_REASON usage on unreached branches is correct and
  matches gate-design.md — no paper-green risk.

The spike-FAIL-is-legal framing (not a cancel) is correctly propagated from the Epic through §1.3,
§10.1, and the branch-conditional ACs.

---

## Verdict

**PASS with recommended fixes.** No P0. The two P1s harden Gate-3 discrimination (behavioral-guard
proof + cleanup-preservation assertion) but do not block Blake from starting. P2s are polish.
