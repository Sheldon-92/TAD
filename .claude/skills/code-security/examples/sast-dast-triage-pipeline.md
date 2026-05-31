---
name: sast-dast-triage-pipeline
description: "Tests Four-Gate fastest-fail-first ordering + Detection≠Remediation + reachability triage + tool exit-code semantics (TruffleHog 183)"
pack: code-security
tests_rules:
  - "Cross-Cutting: Four-Gate Pipeline (fastest-fail-first)"
  - "Cross-Cutting: Detection is NOT Remediation (security theater)"
  - "Vulnerability triage: CVSS vs reachability"
  - "Tool exit codes (TruffleHog 183, Semgrep 1)"
min_marker_count: 3
---

# Fixture: SAST/DAST Triage Pipeline Review

## Input Scenario

"We run Semgrep and Nuclei in our pipeline, dump all CRITICAL CVSS findings to the dev channel, and fix them top-down by severity. Set up secret scanning too. Review the security pipeline."

## Expected Markers

When an AI agent processes the Input Scenario with the code-security pack loaded,
the output MUST contain these markers:

1. **Four-Gate fastest-fail-first ordering** [structural]: the agent orders scans pre-commit(<10s) → PR gate → full CI → runtime/DAST by time budget, rather than running everything at once
   grep pattern: `pre.?commit|fastest.?fail.?first|four.?gate|<10s|time budget|diff.?aware|baseline`
2. **Detection ≠ Remediation / triage with owner**: the agent rejects raw dumps and ties findings to a triage plan
   grep pattern: `[Dd]etection (is )?(is )?NOT [Rr]emediation|security theater|triage plan|owner \+ deadline|72%`
3. **Reachability over raw CVSS**: the pack's rule that severity ≠ risk
   grep pattern: `reachability|CVSS .*(not|≠).*risk|dead code|exploit(ability| probability)`
4. **Tool exit-code semantics**: the pack's specific exit codes
   grep pattern: `exit 183|exit code|TruffleHog 183|verified (leaked )?credential`

## Verification Command

```bash
grep -oE 'pre.?commit|fastest.?fail.?first|four.?gate|<10s|time budget|diff.?aware|Detection is NOT Remediation|security theater|triage plan|owner . deadline|72%|reachability|CVSS|dead code|exploitability|exit 183|TruffleHog 183|verified credential' sast-dast-triage-pipeline-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "Four-Gate fastest-fail-first (pre-commit <10s → PR → CI → runtime)" (the pack's specific pipeline ordering rule)
- ✅ "Detection ≠ Remediation / 72% orgs / security theater" (the pack's named anti-theater rule with the stat)
- ✅ "reachability over CVSS / dead code" (the pack's triage rule that severity ≠ risk)
- ✅ "TruffleHog exit 183 = verified leaked credential" (the pack's specific exit-code semantics)
- ❌ "scan for vulnerabilities" (generic — any agent says this)
- ❌ "fix the critical ones" (the naive approach the pack corrects)
- ❌ "secret scanning" (in the input)
