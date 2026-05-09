# Code Review — Phase 2 Grounding (Blake → Alex)

**Reviewer**: code-reviewer (senior code review specialist)
**Date**: 2026-04-24
**Scope**: TAD Phase 2 — stale-knowledge-check.sh + Alex step1c grounding + README/template updates
**Files reviewed**:
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/hooks/lib/stale-knowledge-check.sh` (282 lines, NEW)
- `/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/alex/SKILL.md` (+63 lines, step0_5 #9 + step1c)
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/project-knowledge/README.md` (+47 lines)
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/templates/handoff-a-to-b.md` (+18 lines, §7.3)
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/phase2-grounding/AC-P2.{1,2}*.sh`

---

## Summary

Phase 2 delivers a **prompt-level-only** knowledge-staleness detector with a complementary Alex-protocol "grounding pass." The Anti-Epic-1 hard constraint is **cleanly satisfied** — no hook registration, no settings.json delta, no auto-firing. Shellcheck is clean on the main script (exit 0 with 0.11.0). Both AC scripts pass end-to-end (34/34 + 21/21). Code quality is good: BSD/GNU portability shims, midnight normalization, alarm-fatigue defense via `max(entry, revalidated)`, and a well-reasoned subshell-safe path validator return contract. Edge cases (titles with dashes, `(consolidated)` suffix, symlinks, grace boundary, malformed grammar, failure isolation) are empirically verified.

---

## Verdict: **PASS**

**Counts**: P0 = 0 · P1 = 0 · P2 = 6 (well under ≤10).

---

## Findings

### 🔴 P0 — None

Anti-Epic-1 check results (load-bearing):
- `git diff HEAD -- .claude/settings.json` is empty. Last touched commit `6015ee9` (Epic 1 Phase 2b, weeks ago) — unrelated.
- `grep -rE 'stale-knowledge-check|step1c|grounded_against'` in `.tad/hooks/*.sh` and `lib/*.sh` (excluding stale-knowledge-check.sh's own docstring) returns 0 hits.
- `forbidden_implementations` in SKILL.md:1633–1639 explicitly enumerates PreToolUse hook, UserPromptSubmit hook, auto-fired script, deny exit code, tool blocking — matches the spec verbatim.
- Script itself exits 0 on every code path (`exit 0` at line 284 unconditional, advisory-by-design); even `jq`/git-root preflight failures only exit 1 internally — never auto-blocks a caller.

### 🟡 P1 — None

### 🟢 P2 — Suggestions (6 total, non-blocking)

**P2-1 — `_date_to_ts` accepts rollover dates silently.** (`stale-knowledge-check.sh:90-94`)
BSD `date -j -f "%Y-%m-%d %H:%M:%S" "9999-99-99 00:00:00"` succeeds with rollover math, producing a far-future epoch that inverts into an 18262-day-delta STALE. Because the parse regex for entry headers at line 183 requires `[0-9]{4}-[0-9]{2}-[0-9]{2}` the attack surface is small (only `Revalidated:` fields could reach here with a weird-but-2-digit value like `2026-13-45`). Suggest either:
- Tighten `_date_to_ts` to reject ts==0 *and* validate `MM∈01..12 && DD∈01..31` before `date -j -f`, or
- Accept the status quo and note "malformed dates may produce spurious STALE — not a correctness concern because entries are human-authored."

**P2-2 — Non-YYYY-MM-DD entry header silently drops the entry.** (`stale-knowledge-check.sh:183`)
An entry like `### X - 2026-4-1` (single-digit month/day) produces **zero output** — the regex fails, `T` stays empty, and the entry is invisible to the checker. No WARN/ERROR surfaces, so a malformed knowledge entry disappears with no operator signal. Suggest emitting an `INFO` ("unparseable header, skipped") or documenting that knowledge-file lint is out-of-scope for this tool and covered by `knowledge-audit` skill instead.

**P2-3 — `paths_blob` split uses perl but could use awk with no dependency delta.** (`stale-knowledge-check.sh:231-234`)
The script already requires `awk`, `jq`, and now `perl` for a trivial `split(/, /)`. `awk -v RS=', ' '...'` or a bash `IFS=' ' read -a arr <<< "${grounded//, /$'\n'}"` eliminates the perl dependency. Not a real issue on macOS (perl ships), but reduces the portability surface.

**P2-4 — Arithmetic test redirecting stderr is odd shellcheck-legal but misleading.** (`stale-knowledge-check.sh:261, 266`)
The `[ "$m" -eq 0 ] 2>/dev/null` / `[ "$m" -gt ... ] 2>/dev/null` pattern suppresses stderr on integer compare failures. Because `_file_mtime` always prints a number or falls back to `0` via `|| echo 0`, these comparisons cannot fail lexically. The `2>/dev/null` is defensive overkill that hides a real bug if `$m` ever contains non-numeric content. Consider dropping the redirect, or adding a validator (`[[ "$m" =~ ^[0-9]+$ ]] || m=0`) and letting `[` errors surface.

**P2-5 — `_emit` INFO case has a fallthrough hole.** (`stale-knowledge-check.sh:69-70`)
In non-JSON mode, `case "$status"` handles STALE/WARN/ERROR/OK/INFO. If an unexpected status (typo) ever reaches `_emit`, the case silently emits nothing. Suggest `*) printf '[%s] %s — %s\n' "$status" "$title" "$msg" ;;` as a safety default.

**P2-6 — AC-P2.2 test: arithmetic line 122 emits `arithmetic syntax error` to stderr during the PASS run.** (`AC-P2.2-grounding-pass.sh:121-122`)
The `$((hits + hook_matches))` fails when `hook_matches` gets the literal fallback "0\n0" on an already-zero count from `wc -l | tr -d ' ' || echo 0` race. Cosmetic — the test still passes. Replace `|| echo 0` with `; hook_matches=${hook_matches:-0}` or just trust `wc -l` (never fails on empty input).

---

## Positive Notes (reinforce)

1. **Subshell-safe return contract via `"STATUS\tSTRIPPED_PATH"` stdout** (lines 129–164) — correctly avoids the classic "side effect in subshell" trap. Comment at 124–128 documents intent clearly.
2. **Midnight normalization** (lines 88–94) — explicit, documented, and defends against BSD `date -j -f` partial-format wall-clock leakage. Exactly the right fix.
3. **Alarm-fatigue defense** via `baseline = max(entry_ts, revalidated_ts)` (lines 212–221) — the right primitive, and AC-P2.1-h/i prove both directions.
4. **BSD/GNU detection runs once at startup** (lines 83–94), not per-invocation. Clean.
5. **Failure isolation** (lines 280–283) — per-file processing wrapped in `|| _emit ... ERROR`, script still exits 0. Advisory contract upheld.
6. **`forbidden_implementations` in SKILL.md:1633** reads like a protocol clause, not prose — greppable, enforceable in future reviews.
7. **Test fixtures cover** the exact bug classes that killed Epic 1 (hook deps, PATH, fail-closed). Dogfood on real corpus (AC-P2.1-p) confirms 0 ERROR rows on production knowledge files.

---

## Recommended Next Steps

1. Address P2-1 and P2-2 together in a 5-line patch: add a `_valid_date()` regex guard before `_date_to_ts` and emit an INFO when a header fails to parse. Lowers the "silent miss" risk.
2. P2-3/P2-4/P2-5/P2-6 are polish — can defer to Phase 3 or leave.
3. Recommend Blake commit the untracked script (`git status` shows `?? .tad/hooks/lib/stale-knowledge-check.sh`) before Gate 4.

**Gate 3 recommendation**: PASS. No blockers.
