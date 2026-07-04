# Version-Sweep Acceptance Evaluation

**Date:** 2026-07-04
**Handoff:** HANDOFF-20260704-release-version-sweep.md
**Mode tested:** `release-verify.sh version-sweep <repo> <ver>`

---

## Results

| AC | Test | Result | Evidence |
|----|------|--------|----------|
| AC1 | Layer 1 detects stale version | PASS | `sed PROJECT_CONTEXT.md 2.33→2.30` → FAIL + exit 1 |
| AC2 | Layer 1 all PASS → exit 0 | PASS | Normal run → 12 verified, exit 0 |
| AC3 | Layer 2 exclusion rules | PASS | 0 hits from archive/, evidence/, skills/*/references/ |
| AC4 | Layer 2 doesn't affect exit code | PASS | 459 advisory hits + Layer 1 PASS → exit 0 |
| AC5 | IP address not misreported | PASS | `10.2.30.1` correctly filtered, `127.0.0.1` N/A (no 2.X.Y) |
| AC6 | publish-protocol step3c2 | PASS | step3c2 present, ALWAYS blocking |
| AC7 | Existing version mode unchanged | PASS | `version` mode exit 0 (no-old) and exit 1 (with old) |
| AC8 | Parity .claude == .agents | PASS | `diff` confirms identical for publish-protocol + release-runbook |
| AC9 | usage() + CONTRACT updated | PASS | usage includes version-sweep, CONTRACT has 7 mentions |

**Verdict:** 9/9 PASS

---

## Code Review Findings (Resolved)

| Severity | Issue | Resolution |
|----------|-------|-----------|
| P0 | Unescaped regex dots in `$VER` | Fixed: `VER_RE="${VER//./\\.}"` used in patterns |
| P1 | No format validation on `$VER` | Fixed: semver regex check, exit 2 on bad input |
| P1 | Layer 2 grep lacks left-anchor | Fixed: `(^|[^0-9])2\.` prevents `12.33.0` match |
| P1 | Unbounded `$l2_output` memory | Fixed: cap accumulation at 20 entries |
| P2 | Unicode typo in comment | Fixed |
