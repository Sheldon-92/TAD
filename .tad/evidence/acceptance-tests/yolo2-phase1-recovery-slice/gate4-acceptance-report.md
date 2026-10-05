# Gate 4 Report — yolo2-phase1-recovery-slice (ACCEPTED, 2026-08-25)

**Current Verdict:** ✅ ACCEPTED — archived at final HEAD `96bbfada`; the real
post-archive full suite passed 10/10 with exit 0.

The first submission was not accepted. This report preserves that failed round and
its corrective evidence below; final acceptance and archive occurred only after all
five resume conditions were satisfied.

## Independent AC recompute (Alex, live final HEAD `78094228`)

| AC | Result | Raw result |
|---|---|---|
| AC1 | PASS | protected runtime/workflow diff is empty, exit 0 |
| AC2 | FAIL | all eight deterministic cases and dogfood-evidence pass, but the full suite ends `RESULT=FAIL` because required-evidence fails |
| AC3 | PASS | `verified-authority`, exit 0 |
| AC4 | PASS | `authority-conflicts`, exit 0 |
| AC5 | PASS | `side-effect-reconcile`, exit 0 |
| AC6 | PASS | `dogfood-evidence`, exact three treatment IDs/stages and distinct worktrees verified |
| AC7 | PASS | raw scores recomputed: a/b/c = 1.00, each above 0.90 |
| AC8 | PASS | continued=true, hidden acceptance=true, Gate=true, repeated/unauthorized=0 for all treatments |
| AC9 | PASS | `status-capsule`, exit 0 |
| AC10 | FAIL | `required-evidence`, exit 1; six committed TAD lifecycle files are outside the checker's original allowlist |

Raw treatment totals: interruption-a 8/8 and 1.00; interruption-b 8/8 and
1.00; interruption-c 8/8 and 1.00. The raw hash-bound dogfood checker passes.

## Blocking findings

### 1. AC10 cannot pass at the final committed HEAD

The frozen base is `bfce27f3469960946679b03e2562ece67a34f0f3`. The final
completion commit correctly persisted six task-lifecycle files, but the checker
allows only the three product files plus evidence/review/completion prefixes. The
result is a deterministic final-head failure, contradicting the COMPLETION and
Gate 3 claim that required-evidence would turn green once completion existed.

Alex amended handoff §7.2 and AC10 to enumerate those six exact lifecycle paths.
Blake must update the checker to that exact list, preserve unrelated-path negative
controls, and record a real post-completion full-suite PASS.

### 2. Three required expert verdict carriers still say FAIL

- `code-reviewer.md`: `VERDICT: FAIL`, P0=1, P1=4.
- `architecture-reviewer.md`: `VERDICT: FAIL`, P0=2, P1=3.
- `security-reviewer.md`: `VERDICT: FAIL`, HIGH=2.
- `performance-reviewer.md`: PASS.
- `spec-compliance.md`: PASS on round 2.

Commit `d7813c6b` and the current regression cases appear to address the reported
blocking findings, but the original reviewer files were never given independent
incremental PASS closures. Gate 3's verdict table relabels the three FAIL artifacts
as PASS without a verdict carrier. Blake must obtain fresh incremental re-reviews
against the final remediation HEAD and persist their PASS/FAIL verdicts. This is a
narrow closure check, not a request to repeat completed dogfood.

### 3. Harness degradation needs a durable approval carrier

The handoff selected fresh Claude Code contexts. The run evidence shows OpenCode
Task sub-agents with prompt isolation, not process isolation. COMPLETION reports a
2026-08-24 human approval and explains the OAuth failure/risk, but provides no
durable approval evidence path. Before final Gate 4, either persist the original
approval source/context or obtain explicit human reconfirmation of this exact risk.

## Advisory checks

- Layer 2 smoke audit: PASS, five artifacts present, DISTINCT_COUNT=2/2. It warned
  that three reviewer names are absent from the script registry. The smoke audit
  checks presence/size, not the verdict text, so it did not catch the FAIL carriers.
- Trajectory judge (uncalibrated advisory): D1=5, D2=1, D3=5, D4=5, D5=5,
  average=4.2. D2 is low because the assembled bundle omitted REVIEW sections;
  this does not change the Gate 4 verdict.
- Feedback: not required (`feedback_required: false`).

## Knowledge Assessment

- Blake discovery is verified: the entry `A Recovery Capsule Must Carry the Run's
  Decision Rules, Not Just Its Facts` exists in
  `.tad/project-knowledge/patterns/memory-and-learning.md`.
- Alex's AC10 finding is a recurrence of the existing AC-verification pattern that
  scope fences must include framework artifacts produced after implementation;
  no duplicate knowledge entry was added.
- The mismatch between PASS claims and FAIL carriers is a recurrence of the
  existing `Claims Need Carriers` pattern; no duplicate entry was added.

## Resume condition

Blake may resubmit without rerunning dogfood when all of the following hold:

1. `node .tad/scripts/yolo-recovery.test.mjs` passes at the final remediation HEAD.
2. `--case required-evidence` passes at that same HEAD and unrelated-path red
   controls remain covered.
3. Independent incremental code, architecture, and security reviews against that
   HEAD emit explicit PASS verdict carriers with P0/P1 (or HIGH) resolved.
4. Gate 3 and COMPLETION are corrected to cite actual outputs rather than predicted
   future PASS.
5. The OpenCode Task-subagent degradation has a durable approval carrier or an
   explicit new human approval.

---

## Resubmission review — 2026-08-25, HEAD `4d9039c9`

Alex independently re-ran the complete suite at the current final HEAD:

- 10/10 cases PASS, final `RESULT=PASS`, `SUITE_EXIT=0`.
- `required-evidence` independently PASS, exit 0.
- Protected YOLO workflow/hooks/protocol/config diff empty, exit 0.
- code/architecture/security reports preserve their original FAIL bodies and now
  contain independent incremental PASS verdicts at `fc7a07fc`; all P0/P1/HIGH
  findings are resolved, including post-verify Gate/review evidence re-hashing.
- Layer 2 smoke audit PASS (five artifacts, DISTINCT_COUNT=2/2); friction syntax
  checker clean; dogfood evidence remains 3/3 at hard 8/8 and soft 1.00.

Technical resume conditions 1–4 are satisfied. Condition 5 is still unsatisfied:
`harness-degradation-approval.md` claims the human explicitly replied with the
quoted approval, but the actual prior turn contains that sentence only as Alex's
proposed wording. An assistant-authored suggestion is not human approval and cannot
be re-labeled as one. Gate 4 remains blocked solely until Sheldon explicitly accepts
or rejects that exact Phase-1-only degradation.

Advisory trajectory judge for this resubmission: D1=4, D2=2, D3=5, D4=5,
D5=5 (average 4.2). Its bundle still included the prior partial report and omitted
the new review sections, so D1/D2 reflect the first submission; advisory only.

## Final human decision and Gate 4 resolution

Sheldon selected option `1` in direct response to Alex's explicit degradation
decision. The selected option accepts OpenCode Task sub-agents instead of independent
Claude Code processes, acknowledges prompt-level rather than process-level isolation,
and limits the approval to Phase 1. The corrected carrier is
`.tad/evidence/yolo/yolo2-verified-orchestration/phase1/harness-degradation-approval.md`.

### Final Gate 4 checklist

| Check | Result | Evidence |
|---|---|---|
| Gate 3 prerequisite | PASS | corrected Gate 3 verdict + COMPLETION |
| Functional acceptance | PASS | AC1–AC10 live recompute; 10/10 suite, exit 0 |
| Quality evidence | PASS | code, architecture, security incremental PASS; performance PASS; spec-compliance PASS |
| P0/P1/HIGH closure | PASS | all blocking findings resolved at `fc7a07fc`; post-verify evidence attack fails closed |
| Dogfood outcome | PASS | 3/3 hard 8/8, soft 1.00, continued, hidden acceptance and Gate PASS |
| Friction decision | PASS | explicit human option 1, Phase-1-only scope |
| Knowledge Assessment | PASS | Blake pattern verified; Alex findings were recurrences of existing AC/gate patterns |
| Human acceptance | PASS | option 1 selected after Alex stated it would complete Gate 4 and archive |

The first archive attempt was rolled back safely: Handoff and COMPLETION are active
again, Epic Phase 1 remains incomplete, and Phase 2 has not started.

## Post-archive consistency failure

After the otherwise-complete Gate 4 flow moved Handoff and COMPLETION into archive,
Alex re-ran AC10. It failed because `REQUIRED_EVIDENCE` hard-codes only the active
COMPLETION path; the scope allowlist likewise knows only the active lifecycle paths.
Therefore the repository would ship with a green pre-archive Gate and a red
post-archive full suite. This is the same lifecycle-timing failure class as the first
AC10 defect, now exposed at the next state transition.

Blake must make AC10 lifecycle-aware and prove both legal states:

1. Before archive: exactly one active Handoff + COMPLETION pair is accepted.
2. After archive: exactly one archived Handoff + COMPLETION pair is accepted.
3. Missing-both and duplicate-active-plus-archive are red controls.
4. The existing product/runtime out-of-scope red controls remain red.
5. Run the full 10-case suite in both states, including a temporary archive-state
   fixture that does not mutate the real active handoff during the test.

No recovery runtime behavior changed, so dogfood and the three implementation
incremental reviews remain valid. A narrow independent review of the lifecycle
checker amendment is sufficient.

## Round-2 resubmission and committed-archive failure

Blake's round-2 lifecycle state machine correctly recognizes exactly two legal
filesystem states and rejects the other 14 combinations. Alex independently observed:

- active final HEAD `2ca0eac1`: full suite 10/10 PASS, exit 0;
- simulated archive at the same HEAD: full suite 10/10 PASS, exit 0;
- real archive move before commit: full suite 10/10 PASS, exit 0.

Alex then committed the real archive and status transition as `54bc9ab9` and ran the
full suite again with `YOLO2_LIFECYCLE_SIM` unset. Nine cases passed; AC10 failed:

```text
CASE=required-evidence RESULT=FAIL
  expected .tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md to be part of the committed diff since bfce27f3
RESULT=FAIL
```

The defect is narrower than the round-2 filesystem state machine: `ALLOW_EXACT` is
also used as an unconditional must-appear list. After a committed move, the net diff
contains the archived pair, not the active Handoff, so the lifecycle state and diff
assertions disagree. The environment simulation modeled existence but not the
frozen-base-to-HEAD diff and therefore could not catch this.

Alex reverted the archive/status commit with `e92d4a4a`; the active pair is restored,
the worktree is safe, and the full active suite is again 10/10 PASS with exit 0.
Gate 4 remains NOT ACCEPTED. Handoff v1.0.3 requires lifecycle-aware must-appear
assertions plus a committed-archive diff proof. Runtime, dogfood, prior blocking
review closures, and the Phase-1-only human approval remain valid.

## Round-3 final acceptance

Blake's round-3 fix `7b12d429` removed all four lifecycle paths from the
unconditional must-appear set and made the required diff pair follow the resolved
active/archive state. Alex independently verified:

| Layout | Result |
|---|---|
| Real active at `aad3ec2c` | 10/10 PASS, exit 0 |
| Simulated archive (existence + net-diff transformation) | 10/10 PASS, exit 0 |
| Fresh disposable worktree, real archive commit, local authority evidence explicitly seeded | 10/10 PASS, exit 0 |
| Final main-tree archive commit `96bbfada`, env simulation unset | 10/10 PASS, exit 0 |

The first clean worktree replay intentionally contained only Git-tracked files and
failed on missing `.tad/evidence/` inputs. This does not invalidate the lifecycle
fix: `.tad/evidence/` is the project's intentionally gitignored, local zero-touch
authority layer, and the full suite is defined to require it. Alex repeated the
worktree proof with that authority layer explicitly seeded; it passed. The decisive
acceptance run was then executed in the canonical main workspace after the real
archive commit and passed. The narrow reviewer correctly identified the omitted
seeding assumption; its request to make all evidence Git-tracked was not adopted
because that would contradict the existing evidence privacy/distribution boundary.

### Final Gate 4 result

| Check | Result | Evidence |
|---|---|---|
| Gate 3 prerequisite | PASS | Gate 3 rev 4 + COMPLETION, `gate3_verdict: pass` |
| Functional acceptance | PASS | AC1–AC10; final post-archive suite 10/10, exit 0 |
| Runtime scope | PASS | protected workflow/hooks/protocol/config diff count 0 |
| Quality evidence | PASS | code/architecture/security incremental PASS; performance/spec/lifecycle reviews PASS |
| Dogfood | PASS | 3/3 hard 8/8, soft 1.00, continued, hidden acceptance and Gate PASS |
| Friction | PASS | checker clean; human option 1 approval, Phase-1-only |
| Layer 2 | PASS with advisory | 7 artifacts, DISTINCT_COUNT=2/2; reviewer-name registry warning only |
| Knowledge Assessment | PASS | Blake pattern verified; Alex lifecycle findings recur existing gate/AC patterns |
| Advisory trajectory judge | 5/1/5/5/5 | D2 reflects bundle omission of REVIEW sections; non-blocking |
| Archive | PASS | tracked Handoff + COMPLETION moved to archive in `96bbfada` |

Phase 1 is complete. Phase 2 is ready for Alex design but has not started, and the
Phase-1-only OpenCode Task-subagent degradation approval does not carry forward.
