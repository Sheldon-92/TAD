# Backend-Architect Review — Hook Hardening (Debt Bundle H2)

**Reviewer:** backend-architect
**Date:** 2026-05-31
**Commit:** b37d41b
**Spec:** HANDOFF-20260531-hook-hardening.md (§10 fail-closed contract, §4.2 classify_scope)
**Files reviewed:** `.tad/hooks/lib/dream-scanner.sh`, `.tad/hooks/post-write-sync.sh`, COMPLETION, fixture-results.md
**Method:** verified against the actual diff (`git show b37d41b`) + independent empirical reproduction in throwaway `/tmp` dirs (NOT against real telemetry).

---

## 1. Critical (priority-zero)

None.

Every critical axis was independently reproduced and holds:

### Fail-closed contract preserved — empirically confirmed
`dream-scanner.sh` line 7 retains `set -uo pipefail` (no `set -e`). `post-write-sync.sh` line 8 retains the safety comment and has no `set -e`. I copied the real scanner into a throwaway dir with a fixture carrying TWO malformed-context events (a human-overridden `decision_point` AND a `reflexion_diagnosis`, both `context:"not-json"`) plus one valid control. Result: scanner printed `1 new candidates`, emitted exit 0, and produced ZERO junk candidates from the malformed events. The advisory contract (malformed input → exit 0, no junk) is intact.

### The new try-guarded paths cannot propagate a non-zero exit
- `(try fromjson catch null)` keeps jq's own exit at 0 even on unparseable context; each jq call also carries `2>/dev/null` and a `// "default"` fallback. No jq invocation can return non-zero from a parse failure.
- The compound guard `[ "$decision" = "unknown" ] || [ -z "$decision" ] && continue` was reproduced in a standalone `set -uo pipefail` while-loop across inputs `unknown` / empty / real: `unknown` and empty are skipped, `real` is processed, loop exits 0. Bash evaluates this as `([A] || [B]) && continue`; the only outcomes are "continue" (skip) or a successful test, neither of which leaves a script-fatal status. Even if the trailing test in a final iteration were false, there is no `set -e`, so a non-zero `$?` is inert — and the script ends with an explicit `exit 0` (line 276).
- The `classify_scope` 3rd-arg path returns via `echo ...; return` or the terminal `echo "project"`; all arms return 0. The `${3:-}` default means `set -u` cannot fire on a 2-arg call (Pass D lines 150/171/234 still call with 2 args — safe by the default-expansion).

### classify_scope generic-word pruning confirmed
The added keywords are TAD-specific. I verified `sync` and `schema` as bare decision-text words are NOT present and resolve to `project`: `data sync between services` → project, `update DB schema` → project, `sync user data` → project. The §11 #4 decision (TAD-specific only, no `sync`/`schema`) is implemented faithfully and the AC2b guard is real.

---

## 2. Recommendations (priority-one)

### classify_scope slug globs are substring matches → false-framework on genuine project slugs (residual risk)
The slug case uses glob substring patterns: `*hook*|*trace*|*evolve*|*dream*|*registry*`. These fire on any slug CONTAINING the token, not on the token as a word. I reproduced concrete project-scoped collisions that the current code mis-classifies as framework:

| project slug (decision text) | resolves to | matched glob |
|------------------------------|-------------|--------------|
| `webhook-handler` (handle stripe webhook) | framework | `*hook*` (web**hook**) |
| `trace-user-activity` (log user events) | framework | `*trace*` |
| `registry-of-products` (product catalog) | framework | `*registry*` |
| `evolved-ui-layout` (new layout) | framework | `*evolve*` (**evolve**d) |

`webhook` matching `*hook*` is the most plausible real-world collision (any project with a webhook feature). This is the inverse of the failure the §11 #4 / backend-architect P1-2 decision guarded against: that decision correctly pruned generic DECISION-TEXT words but left the SLUG globs as unbounded substrings. Direction of error matters here — per the same P1-2 rationale, over-classifying to framework fans out a project candidate cross-project in *evolve, which is the worse direction.

Why this is a recommendation and not a critical finding: (a) it does NOT violate the fail-closed contract (still exit 0, still a candidate, just a wrong scope_tag); (b) bug(b) is explicitly documented as a PARTIAL heuristic (see §3), and scope_tag feeds a HUMAN-reviewed queue, not an automated cross-project write — a reviewer can correct a mis-tag; (c) the spec's AC set did not require word-boundary slug matching, so this is not a spec-compliance miss. It is a known sharp edge worth tracking.

Suggested future hardening (NEXT.md, not this handoff): anchor the slug globs to token boundaries the way the codebase already does for slugs elsewhere (architecture.md 2026-04-24 "Word-Boundary Matching for Slugs" — bracket-class `(^|[^A-Za-z0-9_-])PATTERN([^A-Za-z0-9_-]|$)`, NOT `\b`). At minimum, `hook` is the highest-collision token.

### decision-text `*emission*` glob fires on generic environmental domain text
`*emission*` matches `carbon emission report` / `reduce CO2 emission` → framework. Lower real-world probability than `webhook` (a TAD telemetry override is unlikely to use the literal word in an unrelated sense within this repo), but it is the same unbounded-substring class. Same suggested mitigation; same human-queue mitigation applies.

---

## 3. Suggestions (priority-two)

### bug(b) residual class is documented but the slug-substring collision is not enumerated
The COMPLETION's Known Limitation correctly describes the UNRECOVERABLE-class (empty file + no slug keyword + generic decision text → under-classified to project). It does not mention the OPPOSITE residual (a project slug containing a TAD substring → over-classified to framework). Consider adding one line to the limitation so the next reader knows both directions of the heuristic's error.

### Pass D omits the decision-text arg (acceptable, noting for completeness)
Pass D's `classify_scope "$match_file" "$slug"` (line 234) does not pass a decision text, so reflexion insights rely only on file/slug signals. This is consistent with the spec (only Pass C gained the 3rd arg) and harmless given the `${3:-}` default — noting only so a future reader does not mistake it for an oversight.

---

## 4. Verification of the remaining required axes

- **bug(b) honesty (priority-three on the checklist):** PASS. COMPLETION §"Known Limitation" states bug(b) is a "PARTIAL heuristic, NOT a full fix", explicitly says "Framework scope is NOT fully fixed", names the unrecoverable class, and points the proper fix at the emission side as OUT OF SCOPE. No "fully fixed" claim exists.
- **Scope discipline:** PASS. `git show b37d41b --stat` shows neither `trace-writer.sh` nor `record_trace` in the changed set — emission untouched. `generate_candidate` body is unmodified. No `dedup` / `duplicate_of` / `status_override` text was added (bug(c) correctly DROPPED per §11 #1). Grep of the diff for those tokens returns nothing.
- **bug(d) heading-only regex:** PASS. Independently ran `^#+[[:space:]]*P${n}-[0-9]` on a fixture containing a numbered heading, a pipe table cell, a colon-no-number header, a bare header, and prose, using system BSD `/usr/bin/grep`: priority-zero=1 (heading only), priority-one=1, priority-two=0. Cell/prose/colon-header/bare-header all excluded as designed. The `|| true` on `trace_expert_finding` and `count=0` fallback preserve the never-fail contract.
- **Self-trigger discipline:** PASS. `fixture-results.md` lives under `.tad/evidence/acceptance-tests/hook-hardening/`, NOT under `reviews/blake/<slug>/` where the expert_finding parser scans — so its literal label tokens cannot self-count. COMPLETION paraphrases labels in prose.
- **Scope creep:** PASS. Exactly 4 files: the 2 hook files + COMPLETION + fixture-results.md. No tangential edits. `git status` clean — nothing uncommitted on the hook files.

---

## 5. Overall: CONDITIONAL PASS

The implementation is faithful to the spec on every load-bearing axis. The never-fail-closed contract is empirically verified end-to-end (malformed input → 0 junk, exit 0); no try-guarded path or the classify_scope 3rd-arg path can propagate a fatal status; scope discipline is clean (emission untouched, no dedup); bug(b) is documented honestly as partial; bug(d) is correct and BSD-safe.

The single substantive finding is a recommendation, not a blocker: the classify_scope slug globs (and the `emission` decision-text glob) are unbounded substring matches that false-classify genuine project slugs like `webhook-handler` / `trace-user-activity` as framework. This does not break the advisory contract and feeds a human-reviewed queue, so it is acceptable for H2 — but it should be tracked in NEXT.md for word-boundary hardening (architecture.md 2026-04-24 pattern), and the COMPLETION's limitation note should acknowledge the over-classification direction, not only the under-classification one.

**Priority-zero (critical) count: 0.**
