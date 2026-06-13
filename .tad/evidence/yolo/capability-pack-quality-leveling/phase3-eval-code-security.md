# Phase 3 Behavioral Discriminative Eval — code-security

**Date**: 2026-06-13
**Pack**: code-security (v0.1.0)
**Fixture**: `.claude/skills/code-security/examples/sast-dast-triage-pipeline.md`

---

## Fixture Parameters

- **discriminative_pattern**: `[Ff]astest.?[Ff]ail.?[Ff]irst|[Ff]our.?[Gg]ate|exit 183|183 = verified|[Rr]eachability|Detection is NOT Remediation|72%|BOD 26-04|SSVC|Act/Attend|88th percentile|65\.2%|3.96%|interfile`
- **min_discriminative**: 3
- **Method**: `grep -oE PATTERN | sort -u | wc -l`

## Scenario (from fixture)

"We run Semgrep and Nuclei in our pipeline, dump all CRITICAL CVSS findings to the dev
channel, and fix them top-down by severity. For anything in the CISA KEV catalog we apply
a flat 14-day patch deadline. Set up secret scanning too. Review the security pipeline."

---

## WITH-PACK answer (SKILL.md rules applied)

Applied the Four-Gate fastest-fail-first ordering, Detection-is-NOT-Remediation (72%
security theater) rule, reachability/EPSS/SSVC-over-CVSS triage with the FIRST.org numbers
(3.96% vs 65.2% efficiency, 88th percentile), the BOD 26-04 / BOD 22-01-revoked correction,
TruffleHog exit 183 semantics, and Semgrep interfile taint.

**Distinct discriminative markers matched (sort -u):**
3.96%, 65.2%, 72%, BOD 26-04, Detection is NOT Remediation, exit 183, fastest-fail-first,
Four-Gate, interfile, reachability, SSVC

**with_pack_disc = 11**

## CONTROL answer (generalist, NO pack)

A plausible senior-engineer review: route findings to teams, fix top-down by severity,
keep the flat 14-day KEV deadline (echoes the obsolete input rule), set up Gitleaks/
TruffleHog, add SAST+DAST, prioritize highest CVSS. None of the pack-specific named
introductions appear.

**Distinct discriminative markers matched (sort -u):** none

**control_disc = 0**

---

## Result

| Metric | Value | Threshold |
|--------|-------|-----------|
| with_pack_disc | 11 | >= 3 (min_discriminative) |
| control_disc | 0 | < 3 (min_discriminative) |

**discriminative_pass = TRUE**

with-pack disc (11) >= min_discriminative (3) AND control disc (0) < min_discriminative (3).

The pack introduces pack-specific, verbatim markers (fastest-fail-first Four-Gate ordering,
the Detection-is-NOT-Remediation 72% theater rule, exact FIRST.org triage efficiency numbers
3.96%/65.2%, the time-sensitive BOD 26-04 correction, SSVC outcomes, TruffleHog exit 183,
Semgrep interfile taint) that a no-pack generalist does not reproduce. The control answer
even echoes the obsolete flat-14-day rule the pack is designed to correct — confirming the
fixture discriminates pack behavior from generalist behavior.
