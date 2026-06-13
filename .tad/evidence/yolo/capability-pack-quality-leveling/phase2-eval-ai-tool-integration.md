# Phase 2 Behavioral Discriminative Eval — ai-tool-integration

**Pack**: ai-tool-integration (v0.1.0)
**Fixture**: `.claude/skills/ai-tool-integration/examples/cli-vs-mcp-decision.md`
**Date**: 2026-06-13
**Method**: discriminative behavioral eval — with-pack answer vs control (generalist, no pack), scored by the fixture's `discriminative_pattern`.

---

## Fixture parameters

- **discriminative_pattern**: `Inner Loop|Outer Loop|98\.7%|17x|readOnlyHint|destructiveHint|idempotentHint|tool poisoning|rug.?pull|MCPoison|registerTool`
- **min_discriminative**: 3
- **Scoring command** (per fixture): `grep -oE PATTERN | sort -u | wc -l`

## Scenario (from fixture Input Scenario)

> "We want to wrap our internal `git` and `curl` operations plus a destructive `delete_records` API, plus a third-party `analytics` MCP server we found online, as one MCP server so our agent can call them. The tutorial we copied uses `server.tool(name, desc, schema, handler)`. Review the plan."

---

## WITH-PACK answer (SKILL.md rules applied)

Applied Rule 1 (Inner/Outer Loop test + 98.7%/17x token cost → git/curl stay CLI), Rule 2 (Read/Write server separation + separate IAM/blast radius for `delete_records`), tool-annotation audit (readOnlyHint/destructiveHint/idempotentHint, untrusted-from-3rd-party caveat), X7 tool-poisoning/rug-pull/MCPoison + pin+hash for the untrusted analytics server, and the deprecated 4-arg `server.tool` → `registerTool` (SDK v1.29.0) correction with P0/P1 severity tags.

## CONTROL answer (generalist, NO pack)

Generic MCP-server review: handle errors, add a confirmation for the destructive delete, sanitize git/curl inputs (command injection), trust/update the 3rd-party server, use env vars for secrets, keep the tutorial's 4-arg `server.tool` signature, add rate limiting + logging, test before deploy. Sound generalist advice but names none of the pack-specific markers.

---

## Discriminative scoring (case-sensitive `grep -oE`, matching fixture command)

### WITH-PACK matched markers (9 unique)
```
17x
98.7%
destructiveHint
idempotentHint
MCPoison
Outer Loop
readOnlyHint
registerTool
rug-pull
```
**with_pack_disc = 9**

### CONTROL matched markers (0 unique)
**control_disc = 0**

(A case-insensitive run yields with-pack = 12, control = 0 — same verdict; the case-sensitive count above follows the fixture's literal `grep -oE` command.)

---

## Gate result

| Criterion | Threshold | Actual | Pass |
|-----------|-----------|--------|------|
| with-pack disc ≥ min_discriminative | ≥ 3 | 9 | ✅ |
| control disc < min_discriminative | < 3 | 0 | ✅ |

**discriminative_pass = TRUE**

The pack produces 9 pack-specific markers a no-pack generalist names zero of. The discriminative gate cleanly separates pack behavior from baseline: the generalist correctly handles the destructive delete and command-injection but never reaches the Inner/Outer Loop token-cost decision, the measured 98.7%/17x figures, the camelCase MCP annotation hints, the MCPoison/rug-pull supply-chain risk on the untrusted 3rd-party server, or the deprecated-`server.tool`→`registerTool` API correction.
