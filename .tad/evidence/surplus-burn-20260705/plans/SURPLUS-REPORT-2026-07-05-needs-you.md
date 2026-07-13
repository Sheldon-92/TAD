# Surplus Report — 2026-07-05-needs-you

## Summary
- Executed: 1 tasks
- Failed: 2 tasks (skipped, honest_partial)
- Skipped (budget): 0 tasks
- Needs You: 0 SAFETY tasks (not executed)
- Not eligible: 0 tasks
- Total budget spent: ~666K tokens

## Executed Tasks
| # | Task | Tokens | Evidence |
|---|------|--------|----------|
| 1 | o3-kr3-deep-ask-rounds-4-5 | ~240K | .tad/active/handoffs/COMPLETION-surplus-o3-kr3-deep-ask-rounds-4-5.md |

## Failed Tasks (skipped)
| # | Task | Error | Tokens Wasted |
|---|------|-------|---------------|
| 1 | gate-roi-measurement | design review found 2 P0(s) | ~140K |
| 2 | pack-behavioral-examples-scaffold | design review found 1 P0(s) | ~199K |

## 🔒 Needs You (SAFETY — not auto-executed)
(none)

---

## Alex Verification Addendum (2026-07-05, post-run manual audit)

The workflow's self-reported counts above are misleading. Ground-truth after manual verification:

| Task | Workflow said | Actual state |
|------|--------------|--------------|
| o3-kr3-deep-ask-rounds-4-5 | executed | ✅ REAL DELIVERABLES — both findings files written in worktree wf_9ed0ec8a-f42-9 (4 SPs + 4 Sources each, spot-check PASS). Impl-review "FAIL — never performed" was a FALSE NEGATIVE: reviewers ran against main repo and could not see the isolated worktree. Files merged to .tad/evidence/research/ by Alex. REGISTRY bookkeeping (37cfefa5 last_queried) deferred until main burn completes. |
| gate-roi-measurement | failed (2 P0) | ✋ Correctly stopped at design gate. P0 = AC7 read-only scope guard structurally fails a correct impl (pre-existing untracked traces pollute git status). Fix = baseline-diff AC. RERUNNABLE after AC fix. |
| pack-behavioral-examples-scaffold | failed (1 P0) | ✋ Correctly stopped at design gate. P0 = file list omits .agents/ Codex-mirror byte-parity targets + missing release-verify.sh parity AC. RERUNNABLE after AC fix. |

Additional findings:
1. **Unsanctioned main-repo mutation**: REGISTRY.yaml litellm notebook (7804448b) flipped active→dormant by a concurrent agent — semantically valid lifecycle bookkeeping (last_queried 2026-06-04, >30d stale) and exactly the Step 2b auto-refresh mutation design-review P2-2 predicted. KEPT, flagged for human awareness.
2. **surplus-execute success-criterion gap**: yolo-epic returned no error/stop_reason for o3-kr3 despite impl_review_p0_count=2, so the workflow counted it "executed" without checking review verdicts. Known lesson re-confirmed: never trust sub-agent self-report; conductor must verify.
3. **Worktree visibility**: yolo-epic implement step runs in worktree isolation but impl reviewers inspect main repo → structural false-FAIL for any worktree-isolated task. Needs a fix in yolo-epic (pass worktree path to reviewers).
