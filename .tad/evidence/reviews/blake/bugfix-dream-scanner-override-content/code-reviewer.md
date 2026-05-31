# Layer 2 — code-reviewer (Pass C fix: dream-scanner override content)

**Handoff:** HANDOFF-20260531-bugfix-dream-scanner-override-content.md
**Slug:** bugfix-dream-scanner-override-content
**Reviewer:** code-reviewer sub-agent (express bugfix → ≥1 expert per AR-001 / handoff Type line)
**File under review:** `.tad/hooks/lib/dream-scanner.sh` (Pass C only, ~lines 178–210)
**Date:** 2026-05-31

## Round 1 — Verdict: FAIL (P0 raised, later withdrawn)

code-reviewer raised a P0: the unquoted heredoc `<<CAND_EOF` in `generate_candidate`
would re-expand command-substitution / `$VAR` present in the *values* of `$discovery`/
`$title`/`$action`, enabling command injection from human-authored trace text, and that
routing the new free-form `.chosen`/`.rationale` fields through that sink worsened it.
Plus P1: malformed-context junk candidate + missing `2>/dev/null` on the new jq sub-shells.

## Empirical refutation (Blake)

Shell expansion is **not recursive**. An unquoted heredoc expands the **literal template
text** once (its own `${discovery}` token); the substituted value is inserted verbatim and
never re-scanned for `$(...)`, backticks, `$VAR`, or the delimiter. Verified:

- Test 1: `chosen='use \`id\` command'`, `rationale='prefer $(whoami) over $HOME; cost ~$5'`,
  `decision='shell vs $(date)'` → all emitted **verbatim**, nothing executed, `$HOME` not
  substituted. → P0 claim #1 (command exec) and #2 ($VAR leak) do not hold.
- Test 2: a literal `CAND_EOF` line inside the value did **not** terminate the heredoc
  (terminator matches input lines only, not expanded values). → P0 claim #3 does not hold.

**Genuine residual:** `jq -r` renders a JSON `\n` as a real newline → multi-line Discovery
bullet (structural/cosmetic; a stray line could *look* like frontmatter). Real but minor,
and it concerns the two fields this change adds.

## Hardening applied (in-scope, Pass C only)

```bash
chosen=$(echo "$event_json" | jq -r '((.context | fromjson | .chosen) // "") | gsub("\n";" ")' 2>/dev/null)
rationale=$(echo "$event_json" | jq -r '((.context | fromjson | .rationale) // "") | gsub("\n";" ")' 2>/dev/null)
```

`gsub("\n";" ")` flattens embedded newlines **inside jq** before the value reaches the sink;
`2>/dev/null` matches the stderr-quiet convention of Passes A/B/D. Verified with a
newline-injection event: Discovery renders as ONE line, metachars stay literal, no injected
`---`/`type:` line appears in the body.

## Scope decisions (reviewer concurred)

- Did NOT rewrite `generate_candidate` to a quoted-delimiter sink — premise refuted; the
  rewrite would touch Passes A/B/D and violate AC5 + "Pass C only".
- Did NOT touch line 183 (`decision=`) malformed-context behavior — pre-existing, analogous
  to the explicitly-deferred P1-2. Restated as a tracked follow-up, not a blocker.

## Round 2 — Verdict: **PASS**

> "I withdraw P0 entirely... There is no command-injection path. **Verdict: PASS** for the
> Pass-C change as scoped. ... Ship it."

- P0: none (withdrawn — empirically refuted)
- P1: none for the scoped change (newline residual hardened; stderr quieted). One pre-existing
  P1 deferred to follow-up by design.
- P2: none material.
- Arg order into `generate_candidate` matches signature `(signal_type, title, discovery,
  action, evidence, scope_tag, confidence)`; no GNU-only construct (`gsub` is jq, not shell).

## Pre-existing follow-up (NOT a blocker, out of this handoff's scope)

Line 183 `(.context | fromjson | .decision) // "unknown"` does not catch a `fromjson`
*error* — malformed/missing context yields `""` (not `"unknown"`), so the
`[ "$decision" = "unknown" ]` guard misses it and a low-value candidate is generated.
Pre-existing; fold into the Pass C dedup/scope follow-up handoff.
