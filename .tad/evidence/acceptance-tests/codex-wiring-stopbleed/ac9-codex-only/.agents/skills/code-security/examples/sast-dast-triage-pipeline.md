---
name: sast-dast-triage-pipeline
description: "Tests Four-Gate fastest-fail-first ordering + Detection≠Remediation + EPSS/KEV/SSVC triage (BOD 26-04 risk-based deadlines, NOT flat 14-day) + tool exit-code semantics (TruffleHog 183)"
pack: code-security
tests_rules:
  - "Cross-Cutting: Four-Gate Pipeline (fastest-fail-first)"
  - "Cross-Cutting: Detection is NOT Remediation (security theater)"
  - "Vulnerability triage: CVSS vs EPSS/KEV/reachability; SSVC outcomes; BOD 26-04 deadlines"
  - "Tool exit codes (TruffleHog 183, Semgrep 1)"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "CVSS"/"scan for
# vulnerabilities". Fastest-fail-first Four-Gate ordering, TruffleHog exit 183, the
# Detection-is-NOT-Remediation theater rule (72% stat), reachability-over-CVSS triage, and
# the time-sensitive corrections (CISA BOD 26-04 3-day/14-day risk-based deadlines replacing
# the obsolete flat 14-day KEV rule; SSVC Act/Attend/Track* outcomes; EPSS ≥0.1 ≈ 88th
# percentile / 65.2% efficiency vs CVSS≥7's 3.96%) are pack-named introductions a no-pack
# agent does not reproduce verbatim.
discriminative_pattern: "[Ff]astest.?[Ff]ail.?[Ff]irst|[Ff]our.?[Gg]ate|exit 183|183 = verified|[Rr]eachability|Detection is NOT Remediation|72%|BOD 26-04|SSVC|Act/Attend|88th percentile|65\\.2%|3.96%|interfile"
min_discriminative: 3
---

# Fixture: SAST/DAST Triage Pipeline Review

## Input Scenario

"We run Semgrep and Nuclei in our pipeline, dump all CRITICAL CVSS findings to the dev channel, and fix them top-down by severity. For anything in the CISA KEV catalog we apply a flat 14-day patch deadline. Set up secret scanning too. Review the security pipeline."

## Expected Markers

When an AI agent processes the Input Scenario with the code-security pack loaded,
the output MUST contain these markers:

1. **Four-Gate fastest-fail-first ordering** [structural]: the agent orders scans pre-commit(<10s) → PR gate → full CI → runtime/DAST by time budget, rather than running everything at once
   grep pattern: `pre.?commit|fastest.?fail.?first|four.?gate|<10s|time budget|diff.?aware|baseline`
2. **Detection ≠ Remediation / triage with owner**: the agent rejects raw dumps and ties findings to a triage plan
   grep pattern: `[Dd]etection (is )?(is )?NOT [Rr]emediation|security theater|triage plan|owner \+ deadline|72%`
3. **EPSS/KEV/reachability over raw CVSS**: severity ≠ risk, quantified — CVSS≥7 = 3.96% efficiency vs EPSS≥0.1 = 65.2%; EPSS 0.10 ≈ 88th percentile; SSVC Act/Attend/Track* outcomes
   grep pattern: `reachability|CVSS .*(not|≠).*risk|dead code|EPSS|88th percentile|3.96%|65.2%|SSVC|Act/Attend`
4. **BOD 26-04 correction** [time-sensitive]: the agent corrects the user's "flat 14-day KEV" rule to CISA BOD 26-04 risk-based tiers (3-day for actively-exploited + automatable + internet-facing; 14-day for partial-control non-automatable), noting BOD 22-01 is revoked
   grep pattern: `BOD 26-04|BOD 22-01|3.?day|risk.?based|revok|supersede`
5. **Tool exit-code semantics**: the pack's specific exit codes
   grep pattern: `exit 183|exit code|TruffleHog 183|verified (leaked )?credential`

## Verification Command

```bash
grep -oE 'pre.?commit|fastest.?fail.?first|four.?gate|<10s|time budget|diff.?aware|Detection is NOT Remediation|security theater|triage plan|owner . deadline|72%|reachability|dead code|exploitability|EPSS|88th percentile|3.96%|65.2%|SSVC|Act/Attend|BOD 26-04|BOD 22-01|risk.?based|exit 183|TruffleHog 183|verified credential|interfile' sast-dast-triage-pipeline-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "Four-Gate fastest-fail-first (pre-commit <10s → PR → CI → runtime)" (the pack's specific pipeline ordering rule)
- ✅ "Detection ≠ Remediation / 72% orgs / security theater" (the pack's named anti-theater rule with the stat)
- ✅ "reachability over CVSS; EPSS≥0.1 = 65.2% efficiency vs CVSS≥7 = 3.96%; EPSS 0.10 ≈ 88th percentile; SSVC Act/Attend/Track*" (the pack's quantified triage rules — exact FIRST.org numbers an LLM does not reproduce)
- ✅ "CISA BOD 26-04 risk-based 3-day/14-day deadlines, BOD 22-01 revoked" (time-sensitive correction; a no-pack agent applies the obsolete flat 14-day rule the user asked for)
- ✅ "TruffleHog exit 183 = verified leaked credential" (the pack's specific exit-code semantics)
- ❌ "scan for vulnerabilities" (generic — any agent says this)
- ❌ "fix the critical ones" (the naive approach the pack corrects)
- ❌ "flat 14-day KEV deadline" (the obsolete rule in the input the pack must correct, not echo)
- ❌ "secret scanning" (in the input)
