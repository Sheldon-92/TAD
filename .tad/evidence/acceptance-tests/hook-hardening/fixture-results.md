# Hook Hardening — Layer 1 Fixture Results

**Handoff:** HANDOFF-20260531-hook-hardening.md
**Date:** 2026-05-31
**Files changed:** `.tad/hooks/lib/dream-scanner.sh`, `.tad/hooks/post-write-sync.sh`

> Self-trigger discipline (architecture.md 2026-05-30): priority labels are paraphrased
> in prose below (e.g. "P-zero-dash-one") so the now-tightened expert_finding parser does
> NOT self-count. Literal labels appear only inside throwaway `/tmp` fixture INPUT files,
> which the parser does not scan.

---

## AC4 — `bash -n` syntax check (both files)

```
$ bash -n .tad/hooks/lib/dream-scanner.sh; echo "dream-scanner: $?"
dream-scanner: 0
$ bash -n .tad/hooks/post-write-sync.sh; echo "post-write-sync: $?"
post-write-sync: 0
```

Result: PASS — both exit 0. No `set -e` introduced; both retain `set -uo pipefail`.

---

## AC1 — Malformed-context fixture (bug(a) fromjson guard)

Ran dream-scanner inside a throwaway working dir (`/tmp/dream-fixture.XXXXXX/.tad/evidence/traces/`),
NEVER against real `.tad/evidence/traces/`. Fixture had 3 events:
- a `decision_point` (actor human-overridden) with `context:"not-json"` (malformed) — should be skipped
- a `reflexion_diagnosis` with `context:"not-json"` (malformed) — should be skipped
- one VALID control `decision_point` with proper JSON context — should emit 1 candidate

```
--- running scanner in throwaway dir ---
Dream scan complete: 1 new candidates
EXIT=0
--- candidates emitted ---
CAND-2026-05-31-15573401.md
--- candidate contents ---
source_events: ["decision_point human_overridden slug=good-dp"]
scope_tag: project
### Human override: Real decision → Option A — 2026-05-31
```

Result: PASS — the 2 malformed-context events produced **0 junk candidates**; only the
1 valid control event emitted a candidate; scanner exit 0. Before the fix, the malformed
`decision_point` would have set `decision=""` (fromjson errors → empty, not "unknown"),
the old `[ "$decision" = "unknown" ] && continue` guard would NOT fire, and an empty-decision
junk candidate would be emitted. The new `try fromjson catch null` + `|| [ -z "$decision" ]`
empty-guard skips it.

---

## AC2 — classify_scope framework via decision text (bug(b))

Sourced `classify_scope()` extracted from dream-scanner.sh and called it directly:

```
=== AC2: file='' slug='trace-instrumentation-fix' decision='改用观测式发射机制' ===
result: framework (expect framework)
=== AC2 variant: slug='some-random-slug' decision='改用发射机制' (no slug keyword) ===
result: framework (expect framework via decision_text)
=== sanity: slug='trace-instrumentation-fix' decision='generic decision' ===
result: framework (expect framework via slug keyword)
```

Result: PASS — framework signal recovered both via the slug keyword (`trace`) and via the
TAD-specific decision-text token (the Chinese emission phrase).

---

## AC2b — classify_scope generic-word pruning (bug(b) guard)

```
=== AC2b: file='' slug='some-project-feature' decision='data sync between services' ===
result: project (expect project — proves sync pruning)
=== AC2b variant: decision='update DB schema' ===
result: project (expect project — proves schema pruning)
```

Result: PASS — generic words `sync` and `schema` do NOT trigger framework (per
backend-architect P1-2: over-classifying to framework fans out cross-project in *evolve,
worse than under-classifying). Only TAD-specific tokens classify framework.

---

## AC3 — expert_finding heading-only count (bug(d))

Fixture `/tmp/review-fixture.md` contained all three forms for the priority-zero class:
a numbered-heading finding (`### `-prefixed with `-1` id suffix), a pipe-delimited table
cell, and a prose "no issues" mention. Plus a numbered priority-one heading, and a
colon-no-number priority-zero header (accepted recall gap — must NOT count).

```
P-0 count = 1
P-1 count = 1
P-2 count = 0
matched line: 3:### P0-1 Critical heading finding   (the numbered heading only)
```

Cross-checked on system BSD grep (`/usr/bin/grep` — BSD grep 2.6.0-FreeBSD):
```
BSD /usr/bin/grep P-0 = 1
BSD /usr/bin/grep P-1 = 1
BSD /usr/bin/grep P-2 = 0
```

Result: PASS — the priority-zero class counts exactly 1 (the numbered heading). The table
cell, the prose mention, and the colon-no-number section header are all excluded. New regex
`^#+[[:space:]]*P${n}-[0-9]` is POSIX-ERE, identical on BSD and GNU grep, no `grep -P`.

---

## Summary

| AC | Description | Result |
|----|-------------|--------|
| AC1 | Malformed-context (decision_point + reflexion_diagnosis) → 0 junk, exit 0 | PASS |
| AC2 | Framework via slug keyword + decision text | PASS |
| AC2b | Generic sync/schema pruned → project | PASS |
| AC3 | expert_finding counts numbered heading only (cell/prose excluded) | PASS |
| AC4 | `bash -n` both files exit 0 | PASS |

All Layer 1 ACs PASS. No emission code (trace-writer.sh / record_trace) touched.
No `set -e` added. No dedup/duplicate_of/status_override code (bug(c) dropped).
