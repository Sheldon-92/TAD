# Phase 1 Impl Review — Self-Deriving Release/Sync (code-reviewer, blue-team)

**Scope:** `.tad/hooks/lib/derive-sync-set.sh`, `.tad/hooks/lib/release-verify.sh`,
COMPLETION-20260601-self-deriving-release-sync-phase1.md, alex/SKILL.md + release-runbook/SKILL.md diffs (commit 16dbe1a).
**Date:** 2026-06-01 · **Verdict:** CONDITIONAL PASS

The LOAD-BEARING safety property — *no zero-touch dir can leak into the SYNC set* — **holds and is
independently verified**. The derivation, the `-x` whole-line matching, the single-source registry-only
rule, the exit-code contract, and the "not a settings.json hook" wiring are all correct. The conditions are
two version-mode practical defects (grep scope contamination + table-cell false-negative) and one
warn-mode semantic that softens fail-closed more than the FOCUS-4 intent reads.

---

## Independent re-run of the exclusion proof (FOCUS 6 — REQUIRED)

```
$ bash .tad/hooks/lib/derive-sync-set.sh --dirs \
    | grep -cxE '(active|archive|evidence|project-knowledge|pair-testing|decisions|github-registry|research-notebooks|working|spike-v3|reports|checklists)'
0
```
**Got: `0`. PASS.** No deny-list / zero-touch dir leaks into `--dirs`. Derived set = 20 framework dirs
(agents capability-packs codex context cross-model data domains gates guides hooks ralph-config references
schemas scripts skills sub-agents tasks templates tests workflows). `codex` is present (auto-included) and
the literal word `codex` appears 0× in the lib (SC2 confirmed). DENY_RE built bare-pipe, no stray `.`:
`active|archive|checklists|decisions|evidence|github-registry|pair-testing|project-knowledge|reports|research-notebooks|spike-v3|working`.

---

## 1. CRITICAL (P0)

**None.** The load-bearing exclusion safety property is intact. Traced every documented failure mode and
none can leak a zero-touch dir:

- **`-x` present** (whole-line): verified `active-extra`, `activex`, `xactive` all SURVIVE the deny filter;
  only exact `active`/`archive` are removed. A partial-name framework dir is NOT wrongly excluded.
- **No stray `.` / regex metachars** in the alternation: every DENY member is a literal ASCII basename;
  `-E` alternation is bare-pipe (`paste -sd '|'`), no `\|`, no `.` wildcards.
- **Leading `./` normalization**: `sed 's|.*/\.tad/||;s|/$||'` correctly reduces both `./.tad/active/` and a
  no-`/.tad/` line to `active`. The lib globs `"$ROOT"/.tad/*/` (always a `/` precedes `.tad`), so the
  greedy `.*/\.tad/` strip is reliable.
- **Empty glob** (`/tmp/...nonexistent`): `ls 2>/dev/null` yields nothing → empty output, no leak.
- **Bias-to-sync direction is the safe default for the OTHER risk** (omission): a NEW dir defaults to SYNC,
  which can only over-sync (copies framework content) — it can never clobber target data, because target
  data lives exclusively under the zero-touch set, which is hard-denied.

---

## 2. RECOMMENDATIONS (P1)

### P1-1 — `version` grep scope contaminated by non-framework working-tree trees (71/81 noise on real run)
`release-verify.sh version` scopes via `grep -rnF "$OLD" "$REPO" --exclude-dir=.git --exclude-dir=<8 zero-touch basenames>`.
`--exclude-dir` matches a **basename anywhere** in the tree, so `.tad/active` is removed — but top-level
sibling trees are NOT: `.tad.backup.*/`, `.claude/worktrees/`, `codex-tad-bundle/`. Real run:

```
$ bash .tad/hooks/lib/release-verify.sh version "$PWD" "2.21.0" "2.8.0"
VERDICT: version FAIL — 81 stale ref(s) (exit 1)
# of which 71 are .tad.backup.* / .claude/worktrees / codex-tad-bundle noise
```

88% of the reported stragglers are from backup snapshots and worktrees (`.claude/worktrees` and
`codex-tad-bundle` are even gitignored, but `grep -rn` scans the working tree regardless of git). On a real
minor+ bump this either (a) HARD-BLOCKS on un-actionable noise, or (b) trains the operator to ignore the
gate (alarm fatigue) — the exact failure this Phase exists to kill, re-emerging on the version axis.
**Recommend** excluding `.tad.backup.*`, `.claude/worktrees`, and any non-framework top-level tree — e.g.
`--exclude-dir='.tad.backup.*' --exclude-dir=worktrees --exclude-dir=codex-tad-bundle`, or scope grep to the
git-tracked set (`git grep -nF "$OLD" -- . ':!docs'` / `git ls-files | xargs grep`). At minimum, exclude
the backup glob — it is pure release-time poison. (This is the same "allowlist shared/junk trees" lesson as
drift-check, architecture.md 2026-04-24.)

### P1-2 — `version` table-cell exclusion is a genuine FALSE-NEGATIVE vector for live refs in allowlist files
The Version Exclusion Contract ignores any `$OLD` hit that is BOTH (a) basename ∈ {README/INSTALLATION_GUIDE/CHANGELOG}.md
AND (b) line matches the history-row regex. But a **live, must-bump** ref placed inside a markdown TABLE
ROW of one of those three files is silently excluded:

```
$ printf '%s' '| Install | `pip install tad==9.9.9` |' | grep -qE '^[[:space:]]*\|.*v?[0-9]+\.[0-9]+\.[0-9]+.*\|' && echo EXCLUDED
EXCLUDED
```

README.md routinely carries install snippets / version badges in tables. If a real bump target lives in such
a row, the gate passes it as "historical" and ships a stale ref — the precise class (README version) the
gate is meant to catch. The discrimination is "table-row-shaped in an allowlist file", not "provably a
historical-changelog entry". **Recommend** tightening: anchor the allowlist exclusion to the actual history
SECTION (e.g. only lines under a `## Version History` / `## Changelog` heading), or only allow the
date-bearing row form, or scope the exclusion to CHANGELOG.md alone (history tables rarely live in README's
install section). Document the residual risk in the SKILL if left as-is.

### P1-3 — `TAD_RELEASE_GATE=warn` downgrades exit 2 (wiring error) too, contradicting fail-closed intent (FOCUS 4)
Both gate steps branch as `exit 1 OR 2 AND minor+ → if warn: downgrade to WARN+proceed; else HARD BLOCK`,
with a trailing `Fail-CLOSED: exit 2 is treated as FAIL`. Because warn applies to the *combined* `1 or 2`
predicate, a usage/wiring bug (exit 2 — bad flag, missing lib, path typo) is downgraded to warn-and-proceed
exactly like a real drift when `TAD_RELEASE_GATE=warn` is set. FOCUS-4 asks warn to "downgrade only
block→warn, **not mask exit 2 usage errors**" — as written, warn DOES mask exit 2. During the documented
first-cutover shadow run (precisely when warn is on AND the wiring is least battle-tested), a typo in the
gate invocation would emit a warn line and proceed silently, defeating the shadow-mode validation.
**Recommend** splitting the branch: `exit 2 → always FAIL/BLOCK (warn does NOT apply — it is a wiring bug,
not drift)`; `exit 1 AND minor+ → warn downgrades`. The verdict echo (`GATE: ... exit=<n>`) already
distinguishes them; the branch should too. (If the intent really is "shadow mode tolerates everything,"
state that explicitly and drop the contradicting `Fail-CLOSED` line — but the safer reading is to keep exit
2 hard.)

---

## 3. SUGGESTIONS (P2)

- **P2-1 — `--dirs` exits non-zero in the degenerate all-denied tree.** With `set -euo pipefail`, if
  `grep -vxE` finds zero survivors (every `.tad/` dir is in DENY) it exits 1 → the pipeline (and script)
  exit 1. Reproduced on a synthetic `.tad/{active,evidence}`-only tree (`EXIT=1`; `--report` also `EXIT=1`).
  Unreachable in practice (TAD always has ≥1 framework dir; normal `--dirs` exits 0, verified), and stdout
  is already fully flushed so DATA is correct — only the exit code is wrong, and structural consumes via
  process-substitution where the exit code is ignored. Harmless today, but the header promises "Exit: 0
  normal … never exit 1". Cheap fix: `{ grep -vxE "$DENY_RE" || true; }` in `emit_dirs`.

- **P2-2 — `version` reports legit historical prose in `docs/` as stale.** `docs/MULTI-PLATFORM.md` /
  `docs/HISTORY.md` carry immutable historical version mentions in prose (not tables, not in the 3-file
  allowlist) → reported. These are real "is this a bump target?" cases but mostly immutable records that
  will recur every release. Consider an allowlist entry for `docs/HISTORY.md` (or a `<!-- version-frozen -->`
  marker convention) so the operator isn't re-triaging the same historical lines each release.

- **P2-3 — Doc/lib consistency nit:** the lib header says "DENY_LIST = … 12 dirs" and `--report` labels A/C;
  the embeddable-pipeline comment is accurate. No action needed, just confirming the count (8 zero-touch + 4
  transient = 12) matches the code.

---

## Verification ledger (what I re-ran, not read)

| Check | Result |
|-------|--------|
| FOCUS-6 exclusion proof | **0** (PASS) |
| `-x` whole-line (active-extra/activex/xactive survive) | PASS |
| DENY_RE has no stray `.`/`\|` | PASS (bare-pipe literals) |
| Leading-`./` + no-`/.tad/` sed normalization | PASS (both → `active`) |
| empty glob safe | PASS (no leak) |
| registry-only single-source (READ from `--registry-only`, not hardcoded in consumer) | PASS (release-verify.sh:77; REGISTRY_ONLY defined only in derive lib) |
| per-release→evidence/releases re-implemented in consumers? | NO — only in derive `--report` note + SKILL docs (advisory; evidence is zero-touch so auto-excluded) |
| version regex discriminates (history-row excl / straggler report) | PASS for the dogfood cases; FALSE-NEG on table-cell in allowlist file (P1-2) |
| exit-code contract 0/1/2 both libs (structural self==self=0, version no-old=0, bogus=2, derive --bogus=2) | PASS |
| version grep scope on real tree | **71/81 noise** (P1-1) |
| warn downgrades exit 2 too | YES (P1-3) |
| SC8 release-verify NOT in settings.json / no hook registration | **0** (PASS) |
| SC7 both protocols wired (publish=version, sync=structural) | PASS |
| `# NOT a settings.json hook` comment in both steps | PASS |
| SC2 literal `codex`=0 in derive lib, yet codex auto-synced | PASS (0 / in-set) |
| file:line:content colon parsing (URL with `:8080` in content) | PASS (robust `%%:*` / `#*:`) |

---

## OVERALL: CONDITIONAL PASS

The safety-critical property (zero-touch never leaks → no downstream clobber) is correct and independently
proven; the single-source-of-truth architecture is clean (registry-only, zero-touch, deny-list all read from
the one lib); exit codes and SKILL wiring are correct and it is correctly NOT a settings.json hook.

Conditions before relying on the version gate for a real minor+ release:
1. **P1-1** (scope contamination — at minimum exclude `.tad.backup.*`; the 88% noise rate makes the gate
   un-actionable as-is). This is the strongest condition — it directly undermines the gate's purpose.
2. **P1-3** (warn must not mask exit 2 wiring errors during the very shadow run that validates the wiring).
3. **P1-2** (table-cell false-negative — at least document the residual risk; ideally tighten the
   history-section anchor).

The `structural` gate and the derivation lib are ready as-is. The `version` gate needs P1-1 before it can
HARD-BLOCK a real release without producing 70+ false positives. None of these touch the load-bearing
exclusion safety, so no P0.
