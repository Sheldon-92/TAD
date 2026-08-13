# Review Compliance — Prevent Rejection BEFORE Submission (CORE VALUE)

App Store review guideline compliance check. Four layers: search → analyze → derive → generate. Outputs go to `.tad/active/release/{project}/` (guidelines-research.md, compliance-checklist.md, compliance-fix-plan.md, compliance-report.pdf).

## Layer 1: Search — Gather Current Guidelines

1. Read official guidelines: developer.apple.com/app-store/review/guidelines/
2. Search "App Store rejection reasons 2026" for current common issues
3. Check if app uses AI (new 2026 requirement: must disclose)
4. Check if app has IAP/subscriptions (strict pricing transparency rules)

**Quality bar: must reference actual Apple guideline numbers, not generic advice.**

## Layer 2: Analyze — Check THIS App Against Guidelines

Run compliance checklist (from theapplaunchpad 2026 research). Mark each: PASS / FAIL / N/A. For FAIL, note the specific issue.

| # | Check | Guideline | Status | Notes |
|---|-------|-----------|--------|-------|
| 1 | App doesn't crash on launch or normal use | 2.1 | ? | |
| 2 | Privacy labels match actual data collection | 5.1.1 | ? | |
| 3 | Screenshots show actual app features | 2.3.1 | ? | |
| 4 | All links work (privacy policy, terms, support) | 2.1 | ? | |
| 5 | IAP pricing/terms clearly displayed | 3.1.1 | ? | |
| 6 | No excessive performance issues | 2.1 | ? | |
| 7 | Privacy policy accessible via link | 5.1.1 | ? | |
| 8 | AI features disclosed (if applicable) | 5.6.4 | ? | |
| 9 | Accessibility: Dynamic Type + Dark Mode | 2.1 | ? | |
| 10 | Built with latest Xcode + supports current iOS | 2.1 | ? | |

**Quality bar: each check must reference the specific Apple guideline number.**

## Layer 3: Derive — Prioritize Fixes

For each FAIL item:

1. Severity: blocking (will be rejected) vs warning (might be rejected)
2. Fix effort: quick (< 1 hour) vs significant (> 1 day)
3. Priority: blocking + quick first
4. If app has login → must provide demo account for Apple reviewer

Output: prioritized fix list with estimated effort. If all PASS → output "✅ Ready for submission".

**Quality bar: fix plan must be actionable (specific code/config changes), not vague advice.**

## Layer 4: Generate — Compliance Report

1. Executive summary: READY / NOT READY
2. Checklist table with all 10 items + status
3. Fix plan (if any items failed)
4. Apple reviewer notes (demo account, special instructions)

Generate as PDF for stakeholder review.

**Quality bar: all guideline numbers must be accurate. No fabricated compliance statuses.**

## Quality Criteria (pass/fail)

- All 10 checklist items evaluated with specific Apple guideline numbers
- Each FAIL has specific fix plan (not "fix the bug")
- Demo account provided if app has login
- AI disclosure checked (2026 requirement)
- Fabricated compliance statuses or invented guideline numbers = FAIL
