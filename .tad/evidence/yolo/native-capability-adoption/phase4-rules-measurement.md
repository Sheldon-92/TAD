# Phase 4 B3 Measurement — `.claude/rules/shell-portability.md`

**Date**: 2026-07-13 | **CLI**: 2.1.172 | **Metrics predefined in handoff §3.1 FR7 / §8 before build**
All runs: headless `claude -p --model claude-sonnet-4-5`, cwd = worktree repo root
(`/Users/sheldonzhao/01-on progress programs/TAD/.claude/worktrees/wf_0019f033-1ce-1`).
Discriminative probe token: `THIN EXCERPT` — verified present ONLY in
`.claude/rules/shell-portability.md` across the whole tree
(`grep -rl "THIN EXCERPT" .` → exactly 1 file), so probe answers cannot be satisfied by
the CLAUDE.md-imported project-knowledge pattern files.

## Fire-test (rule loads when a `.tad/hooks/**` file is read)

Run 1 — content-quote probe:
> Prompt: Read `.tad/hooks/lib/detect-platform.sh`, then: (1) is a rule from
> `.claude/rules/shell-portability.md` in context? (2) quote constraint #5 verbatim.
> Output: "(1) **YES** (2) Constraint #5 verbatim: > Never use `\b` for hyphenated-slug
> matching — BSD grep treats `-` as a word boundary. Use the bracket class
> `(^|[^A-Za-z0-9_-])PATTERN([^A-Za-z0-9_-]|$)`."

The quoted wording is THIS rule file's phrasing (differs from the source pattern entry's
phrasing), proving the harness injected the RULE file, not the source pattern.

Run 2 — discriminative-token probe:
> Prompt: Read `.tad/hooks/lib/detect-platform.sh`, no other files; does context contain
> the exact phrase 'THIN EXCERPT'? → Output: "YES"

**Result: FIRE PASS (real event, in-repo, 2 independent probes — not PENDING)**

## No-fire test (rule stays out when no matching file is read)

Run 1 (discarded as confounded, kept for honesty): probe asked about
"rule loaded from .claude/rules/shell-portability.md" after reading README.md → agent
answered YES but its own reasoning cited `.tad/project-knowledge/patterns/_index.md`
(auto-loaded via CLAUDE.md @import), i.e. it conflated project-knowledge presence with
rules-file presence. Probe design error, not a scoping failure → replaced by the
discriminative-token probe.

Run 2 — discriminative-token probe:
> Prompt: Read `README.md` (root), no other files; does context contain the exact phrase
> 'THIN EXCERPT'? → Output: "NO"

**Result: NO-FIRE PASS (same token, symmetric probe: fire=YES / no-fire=NO)**

## Content parity (5 constraints ↔ source entries)

| # | Rule-file constraint | Source entry (patterns/shell-portability.md) | Parity |
|---|---------------------|-----------------------------------------------|--------|
| 1 | No `grep -P` on macOS → `grep -o`+`sed` | "Hook Shell Portability Rules - 2026-04-03" (1) | OK |
| 2 | grep no-match in `$()` under `set -e` → `\|\| true` | "grep No-Match in Command Substitution Under set -e Triggers ERR Trap - 2026-06-17" | OK |
| 3 | `LC_ALL=C` on comm AND both sorts for CJK | "comm -12 Set-Intersection CJK Needs LC_ALL=C on BOTH sorts AND comm - 2026-05-31" | OK |
| 4 | No `exit` in `$()` helper; exit at call site, GATE markers | "Command Substitution Swallows Gate Markers - 2026-06-09" | OK |
| 5 | No `\b` for hyphenated slugs → bracket class | "Shell Pattern: Word-Boundary Matching for Slugs - 2026-04-24" | OK |

AC12 mechanical check: 5/5 `RULE-OK` (`grep -P`, `LC_ALL=C`, `ERR trap`, `GATE`,
`bracket class`), 0 MISS. Each constraint carries its source entry date inline.

## Context-delta (cost of the rule when it fires)

```
wc -l .claude/rules/shell-portability.md  →  25 lines   (cap 60)
wc -c .claude/rules/shell-portability.md  →  1370 bytes (cap 4096)
```

≈ 1.4 KB (~350 tokens) injected ONLY in sessions that read `.tad/hooks/**` files;
zero cost in all other sessions (no-fire verified above). No-frontmatter rules would
have been an always-on tax — path scoping avoids it.

## Known limitation (from official docs + spike)

Path-scoped rules trigger on file READS, not writes/new-file creation. A session that
creates a brand-new hook file without reading any existing `.tad/hooks/**` file will not
have the rule in context. Mitigation note included in the rule file itself ("read the
target hook file before editing it").
