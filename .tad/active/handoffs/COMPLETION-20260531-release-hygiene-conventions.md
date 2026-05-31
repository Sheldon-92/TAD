---
gate3_verdict: pass
handoff: HANDOFF-20260531-release-hygiene-conventions.md
date: 2026-05-31
agent: Blake
task_type: mixed
---

# COMPLETION: Release Hygiene + Conventions (Debt Bundle 1/2)

## Files Changed (9 + this COMPLETION)

1. `tad.sh` — (a) `TARGET_VERSION="2.19"` → `"2.19.1"` (line 18); (b) added `*) echo "tad.sh: unknown option '$arg' (use --help)" >&2; exit 1 ;;` default arm in arg-parse case; (c) fallback `current_version="${TARGET_VERSION}.0"` → `"${TARGET_VERSION}"` (avoids malformed 4-segment `2.19.1.0`). detect_state glob arms (305-313) NOT touched.
2. `README.md` — current-display bumped: header banner (L3), tree comment (L134), footer (L453) → `2.19.1`. **L354 version-history `v2.19.0` row PRESERVED.**
3. `INSTALLATION_GUIDE.md` — L3, L83, L237, L336 → `2.19.1` (all current/structural).
4. `.claude/skills/tad-help/SKILL.md` — L17 (`Version: v2.19.1`), L221 (`## TAD v2.19.1 Highlights`).
5. `.tad/codex/codex-alex-skill.md` — L3 header comment `TAD v2.19.1` (**`Generated: 2026-05-04` date kept**), L855 greeting → `2.19.1`.
6. `.tad/codex/codex-blake-skill.md` — L3 header comment `TAD v2.19.1` (date kept), L632 greeting → `2.19.1`.
7. `.claude/skills/release-runbook/SKILL.md` — added Phase 2 version-table rows 17 (codex-alex L855 greeting) + 18 (codex-blake L632 greeting), each citing the literal line number.
8. `.claude/skills/alex/SKILL.md` — added `slug_convention` rule to `express_path_protocol`, inserted AFTER `when_NOT_appropriate` (downstream of `required_steps:` and the AR-001-guarded `step2 expert review ... code-reviewer 必选` line). No `forbidden_implementations`/`NOT_via_*`/AR-001 block touched.
9. `.claude/skills/blake/SKILL.md` — mirrored `slug_convention` note inside `exception_express.slug_detection` neighbor (added a `slug_convention:` field). No forbidden/AR-001 block touched.

CHANGELOG.md was NOT edited (confirmed via git diff — empty).

## Layer 1 Self-Check Results

### bash -n
```
$ bash -n tad.sh; echo "exit=$?"
exit=0
```
PASS.

### AC Verification Table

| AC | Method | Expected | Actual | Result |
|----|--------|----------|--------|--------|
| AC1 | `grep -c 'TARGET_VERSION="2.19.1"' tad.sh` | `1` | `1` (bare 2-part `TARGET_VERSION="2.19"$` count = `0`) | PASS |
| AC2 | `bash tad.sh --bogusflag; echo $?` | non-zero + msg | `tad.sh: unknown option '--bogusflag' (use --help)` / `exit=1` | PASS |
| AC3 | `grep -rn '2\.19\.0' README.md INSTALLATION_GUIDE.md tad-help/SKILL.md codex-alex codex-blake` | EXACTLY 1 line (`README.md:354`) | 1 line, `README.md:354` (version-history row) | PASS |
| AC4 | `git diff --name-only CHANGELOG.md` empty; `grep -c '2\.19\.0' CHANGELOG.md`; `grep -n 'v2.19.0.*Observational' README.md` | CHANGELOG unchanged; history row present | git diff empty; CHANGELOG count=1 (`[2.19.0]` intact); README:354 row present | PASS |
| AC5 | `grep -cE '855|632' release-runbook/SKILL.md` | `≥2` | `2` | PASS |
| AC6 | `grep -ci "slug.*express\|express.*slug" alex/SKILL.md` | `≥1` | `6` | PASS |
| AC7 | `bash -n tad.sh; echo $?` | `0` | `0` | PASS |
| AC8 | throwaway dir `.tad/version.txt`=`2.19.1`, exercise `detect_state()` | `current` | `STATE=current` (line 303 exact-equality `[[ "2.19.1" == "2.19.1" ]]` fires before glob arms) | PASS |
| AC9 | `grep -n 'expert review' alex/SKILL.md` — express `step2` phrase intact, not displaced upward | phrase present, not displaced | L2168 `step2 expert review ... code-reviewer 必选` intact inside `required_steps:` (L2161); slug_convention inserted DOWNSTREAM at L2200+ (ref at L2206) — NOT displaced upward | PASS |

### AC8 detail
```
$ echo 2.19.1 > /tmp/tadtest/.tad/version.txt
$ (TARGET_VERSION="2.19.1"; sourced detect_state in /tmp/tadtest)
STATE=current
```
Confirms R2: with the new 3-part `TARGET_VERSION`, downstream `version.txt`=`2.19.1` is exact-matched by `detect_state()` line 303 → `"current"`. Internally consistent (stamp + detect both `2.19.1`).

### AC9 / AR-001 detail
The express `required_steps:` block (alex/SKILL.md L2161) and its AR-001-guarded line `step2 expert review with ≥1 expert (code-reviewer 必选 ...)` at L2168 are unchanged and remain within ~30 lines of the `express_path_protocol:` header (L2133). The new `slug_convention:` was inserted after `when_NOT_appropriate` (L2200+), strictly downstream — it did NOT push the guarded phrase upward. No `forbidden_implementations` / `NOT_via_alex_suggestion` / AR-001 line was edited in either SKILL.

## Escalations
None. The slug_convention insert was placed downstream of `required_steps` per §6 item 8; no STOP condition (forbidden/NOT_via/AR-001 touch) was triggered.

## Out-of-Scope Debts (for Alex at Gate 4 → NEXT.md)
1. `detect_state()` glob arms `2.1*`/`2.2*` (tad.sh ~305-313) will misclassify a 3-part `2.19.x` as `v2.0` on the NEXT version bump (when line 303 exact-match fails). Not introduced by this change.
2. Durable express-tier fix = frontmatter `express: true` marker consumed by layer2-audit (backend-architect P2-1); the slug convention is the cheap fix, not the final one.

## Gate 3 Verdict
**PASS** — all 9 ACs verified with actual command output. `bash -n` exits 0. Historical references (CHANGELOG, README:354, codex Generated dates) preserved per AC4. Layer 2 expert review is handled by the Conductor (Blake sub-agent cannot spawn reviewers).
