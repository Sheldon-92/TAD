---
reviewer: code-reviewer
handoff: HANDOFF-20260531-hook-hardening.md
commit: b37d41b
date: 2026-05-31
verdict: PASS
---

# Code Review — Hook Hardening (Debt Bundle H2)

> Self-trigger discipline (architecture.md 2026-05-30 "Parser Self-Trigger"): all
> priority-class labels are PARAPHRASED in prose here (e.g. "P-zero-dash-one") so the
> very `emit_expert_findings` parser under review does NOT self-count this file. Literal
> tokens appear only inside fenced fixture INPUT below, which the parser scans for
> heading-form labels only — and none of those fences are review-file headings.

Adversarial review. Every claim in the completion report was re-derived from the
committed files (commit b37d41b) and re-run independently — the report was NOT trusted.

---

## 1. Critical (P-zero)

**None.** No critical defect with a concrete reproduction was found. All four bugs in
scope (a, b, d, and the c-non-reintroduction guarantee) were verified correct against the
committed source and via live execution of the real scanner.

---

## 2. Recommendations (P-one)

### P-one-dash-1 — `*emission*` substring token can over-match (LOW likelihood, accepted)

The bug(b) decision-text case uses `*emission*` as a TAD framework signal. Being a bare
substring glob, it matches any decision text containing the letters "emission" — including
a hypothetical non-framework decision about, e.g., carbon "emission" reporting. This would
mis-classify such an event as `framework` and fan it out cross-project in *evolve.

- **Likelihood:** very low — decision_point events in this repo are TAD-internal.
- **Backend-architect P-one-dash-2 (cited in COMPLETION) already weighed the tradeoff:**
  over-classifying to framework is the deliberately-chosen lesser evil vs. under-classifying.
- **Why not P-zero:** no reproduction exists in real trace data; the residual is documented
  and accepted in COMPLETION §"Known Limitation". Recommendation only: if a future false
  positive appears, tighten to a word-boundary form (e.g. anchor with a leading space or the
  compound `*"emission mechanism"*`).

This is a recommendation, not a blocker.

---

## 3. Suggestions (P-two)

### P-two-dash-1 — Pass D does not pass the 3rd `classify_scope` arg

Pass D (reflexion) calls `classify_scope "$match_file" "$slug"` (2 args). This is CORRECT —
reflexion_diagnosis events carry no `decision` field, so there is nothing to pass. Noting it
only to pre-empt a future reviewer mistaking it for an omission. No change needed.

### P-two-dash-2 — `*"trace schema"*` is a substring glob

`*"trace schema"*` would match an embedded substring (e.g. `Xtrace schemaY`). Harmless given
TAD-internal inputs; left as-is is fine. Mentioned for completeness.

### P-two-dash-3 — Guard relies on shell `||`/`&&` equal-precedence left-assoc

`[ "$decision" = "unknown" ] || [ -z "$decision" ] && continue` parses as
`([A] || [B]) && continue`. Verified to skip on both "unknown" and empty, keep on real value.
Correct, but a reviewer unfamiliar with the equal-precedence rule could misread it. An
explicit grouped form `{ [ ... ] || [ ... ]; } && continue` would be marginally clearer.
Not worth a change.

---

## 4. Verification Log (re-run, not trusted from report)

### bug(a) — try-guarded fromjson (dream-scanner.sh)

Confirmed at Pass C (`decision`/`chosen`/`rationale`, ~lines 190-192) and Pass D
(`confidence`/`revised_approach`, ~lines 229/232) — all use
`(.context | (try fromjson catch null) | .field?) // "default"` with `2>/dev/null`.

Independent jq tests (all exit 0):
```
$ echo '{"context":"not-json"}' | jq -r '(.context | (try fromjson catch null) | .decision?) // "unknown"'
unknown
$ echo '{"context":"not-json"}' | jq -r '(.context | (try fromjson catch null) | .confidence?) // "low"'
low
$ echo '{"context":"not-json"}' | jq -r '(.context | (try fromjson catch null) | .revised_approach?) // "unknown"'
unknown
$ echo '{"context":"{\"decision\":\"Real Choice\"}"}' | jq -r '(.context | (try fromjson catch null) | .decision?) // "unknown"'
Real Choice
$ echo '{"slug":"x"}'  (missing context) -> unknown
```

Empty/unknown guard precedence (independently exercised):
```
decision='unknown' -> CONTINUE (skipped)
decision=''        -> CONTINUE (skipped)
decision='Real'    -> KEPT (emitted)
```

**E2E against the REAL scanner** (throwaway `/tmp` trace dir, correct schema:
`ts` + `actor_tag:"human_overridden"`): 2 malformed-context events (a decision_point AND a
reflexion_diagnosis, both `context:"not-json"`) → **0 junk candidates**; 1 valid control
event → **exactly 1 candidate** with rationale propagated; **scanner exit 0**.
```
Dream scan complete: 1 new candidates
SCANNER EXIT=0
1 candidates ; body contains "human chose: Option A. Rationale: because reasons"
```

### bug(b) — classify_scope 3rd arg + TAD-specific keywords

Sourced the function and exercised every path:
```
slug 'trace'                -> framework
decision '改用观测式发射机制'  -> framework
decision 'emission'         -> framework
decision 'trace schema'     -> framework
file .tad/hooks/x.sh        -> framework
decision 'data sync ...'    -> project   (generic sync NOT a pattern)
decision 'update DB schema' -> project   (bare schema NOT a pattern)
empty all                   -> project
```
Confirmed `sync` and bare `schema` appear ONLY in the comment and the compound
`"trace schema"` token — never as standalone framework patterns. Pass C call site updated to
`classify_scope "$file" "$slug" "$decision"` (line 194). Verified.

### bug(d) — heading-only expert_finding regex (post-write-sync.sh ~line 162)

Old heading-OR-cell alternation `(^#+...P${n}...|\|...P${n}...)` was **REMOVED**, replaced by
heading-only `^#+[[:space:]]*P${n}-[0-9]`. The ~lines 160-161 comment was rewritten (no stale
cell description). On a fixture containing a numbered heading, a pipe table cell, a prose
"no issues" mention, a bare `### P0`, and a colon-no-number `## P0:` header:
```
GNU grep:  P-zero=1  P-one=1  P-two=1
BSD grep:  P-zero=1  P-one=1  P-two=1   (/usr/bin/grep)
matched line for P-zero: only "### P0-1 ..."  (heading with dash-number)
```
Table cell, prose, bare-no-dash heading, and colon-no-number header are all excluded.
POSIX-ERE — identical on BSD and GNU; no `grep -P`.

### Contract — no fail-closed

- `dream-scanner.sh`: retains `set -uo pipefail`; **no `set -e`**. `bash -n` exit 0.
- `post-write-sync.sh`: explicit safety comment "MUST NEVER fail-closed. No `set -e`";
  parent revision also had no top-level `set` line — **none introduced**. `bash -n` exit 0.
- Malformed-event E2E: scanner exit **0**.

### bug(c) — NOT reintroduced

`git show b37d41b | grep '^+' | grep -iE 'duplicate_of|status_override|dedup'` → matches
appear ONLY in COMPLETION.md prose (documenting that c was dropped). **No hook code** added
any dedup / `duplicate_of` / `status_override` logic.

### Scope — no creep

`git show b37d41b --stat` → exactly 4 files: `dream-scanner.sh`, `post-write-sync.sh`,
`COMPLETION-...md`, `fixture-results.md`. The two hooks are the only code touched; no emission
code (`trace-writer.sh` / `record_trace`) modified. Matches handoff §9.1 ACs exactly.

---

## 5. Overall

**PASS.**

All four in-scope bugs (a, b, d) are implemented correctly and the c-non-reintroduction
guarantee holds. Every AC was independently re-derived and re-run — including a full E2E of
the real scanner against malformed events (0 junk, exit 0) and BSD-grep confirmation of the
heading-only regex. The contract (advisory, never fail-closed, no `set -e`) is preserved.
Scope is clean (4 files, no creep). The only findings are one accepted-risk recommendation
(`*emission*` substring breadth, already weighed by backend-architect and documented) and
three cosmetic suggestions. None block acceptance.
