---
gate: 3
handoff: .tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
date: 2026-09-09
channel: opencode
model: opencode-go/muse-spark-1.3-contributor
layer1: 19/19 §9.1 rows PASS (AC1.1-AC8.3)
layer2:
  spec_compliance: .tad/evidence/reviews/2026-09-09-gate3-layer2-spec-compliance-knowledge-seam.md (PASS, P0:0 P1:0 P2:1)
  code_review: .tad/evidence/reviews/2026-09-09-gate3-layer2-code-review-knowledge-seam.md (PASS, P0:0 P1:0 P2:5)
  test_runner: .tad/evidence/reviews/2026-09-09-gate3-layer2-test-runner-knowledge-seam.md (PASS, 19/19)
verdict: PASS
human_locked: ["Option A pure isolation (only README.md on new installs)", "quarantine opt-in only, no auto on update"]
---

# Gate 3 Evidence — HANDOFF-20260908-knowledge-seam-isolation

Layer 1 = Blake self-check executing every §9.1 row literally (2026-09-09).
Two handoff-literal forms were unrunnable on this installer generation and were
executed in semantically identical adapted form (recorded as Implementation
Decisions in the COMPLETION report; all three Layer 2 reviewers confirmed
intent-preserving):
- D1: `bash tad.sh --source . --platform both --yes "$TMPD"` → positional
  target unsupported (`unknown option`); used `(cd "$TMPD" && bash
  "$SRC/tad.sh" --source "$SRC" --platform both --yes)` (installer targets cwd).
- D2: unconditional `[ "$skill_name" = "local" ] && continue` fails every fresh
  install (post-install self-check requires `local/` seeds → rollback); scoped
  to existing target trees only.
- D3: `--quarantine-pk` dispatch resolves the script via the tad.sh script dir
  (AC fixtures run with cwd=$TMPD where `.tad/hooks/` does not exist).

## Top-File Denylist Probe Output

```
$ grep -F "brain-index.md" .tad/hooks/lib/derive-sync-set.sh
brain-index.md"
$ TMPF=$(mktemp) && sed '/^main$/d' tad.sh > "$TMPF" && bash -c 'source "$0" >/dev/null 2>&1; derive_framework_top_files . | { grep -Fx "brain-index.md" && exit 1 || true; } && derive_framework_top_files . | { grep -Fx "sync-registry.yaml" && exit 1 || true; } && derive_framework_top_files . | grep -Fxq "version.txt"' "$TMPF"; RC=$?; rm -f "$TMPF"; echo "RC=$RC"
RC=0
$ bash tad.sh --verify-denylist
✓ --verify-denylist: tad.sh inlined DENY_LIST == derive-sync-set.sh (17 entries)
RC=0
```

Consumer (tad.sh derive_framework_top_files, post code-review P2-1 `-e` hardening):

```
printf '%s\n' "$TAD_TOP_DENY" | grep -Fxq -e "$bn" && continue
```

## Fresh Install Simulation Log

Isolated `(cd "$TMPD" && bash "$SRC/tad.sh" --source "$SRC" --platform both --yes)`:

```
pk root:
README.md
incidents
patterns
patterns md: 0, incidents md: 0
top-file brain-index: absent-ok
local seeds: .claude/skills/local (_example.md _index.md), .agents/skills/local (_example.md _index.md)
```

Install self-check green (no MISSING lines, no rollback). Only `README.md` at
pk root; `patterns/` + `incidents/` exist and contain zero `*.md`; no
`.tad/brain-index.md` leaked to target.

## Brain Index Generation Full Output

```
$ bash .tad/hooks/lib/brain-index-gen.sh
brain-index.md generated: 278 lines at /home/box/云同步/TAD/.tad/brain-index.md
RC=0
$ [ $(grep -A 55 "## Archived Handoffs" .tad/brain-index.md | grep -c "HANDOFF-") -ge 50 ] && grep -A 55 "## Archived Handoffs" .tad/brain-index.md | grep "HANDOFF-" | { grep -qE '\|\s*\||\(see file\)' && exit 1 || true; } && echo AC3.2-PASS
AC3.2-PASS
```

50 archived rows at the `head -50` cap, zero empty cells, zero `(see file)` fallbacks.

## Quarantine Fixture Test & Idempotency Run

Positive path (polluted fixture: byte-identical `principles.md` +
`patterns/shell-portability.md`, plus `README.md` "seed readme" + `custom.md` "user file"):

```
$ (cd "$TMPD" && bash "$SRC/tad.sh" --quarantine-pk)
User-modified knowledge preserved: custom.md
2 files quarantined → $TMPD/.tad/archive/quarantine-framework-pk-20260909-001631
```

Post-checks: `README.md` byte-identical (`seed readme`); `custom.md` preserved;
`principles.md` moved; archive dir contains `quarantine-framework-pk-…/` with
`MANIFEST.md` (| Original File | Sha256 | Action | Reason | Timestamp | rows).
Captured manifest: `.tad/evidence/fixtures/quarantine-test-manifest.md`.

Idempotency (clean tree, OLDPWD-preconditioned shell):

```
$ OUT=$(cd "$TMPD" && bash "$OLDPWD/tad.sh" --quarantine-pk 2>&1); echo "$OUT" | grep -F "0 files quarantined" && test ! -d "$TMPD/.tad/archive"
0 files quarantined
AC4.4-PASS (no archive dir created, exit 0)
```

## Project Skill Protection Output

AC5.1 (bare / single-quoted / double-quoted `ownership: project-owned` + `local/keep.txt` survive re-sync): PASS.
Ownership branch on a real 2.40.0→2.44.3 upgrade (target-planted customized framework skills):

```
ℹ   → Preserving project skill tree: local
ℹ   → Preserving project-owned skill: web-backend
ℹ   → Preserving project-owned skill: gate
ℹ   → Preserving project skill tree: local
primary preserved / secondary preserved → OWNERSHIP-BRANCH-PASS
```

## Dual Platform Parity Check

```
$ bash .tad/hooks/lib/release-verify.sh parity .
  ✅ .claude/skills <-> .agents/skills byte-identical
VERDICT: parity PASS (exit 0)
RC=0
```

## Doctor / Freshness (WARN-only)

```
$ bash tad.sh --doctor
✓ brain-index.md is fresh (newer than project-knowledge)   # RC=0
$ touch -t 202001010000 .tad/brain-index.md && bash tad.sh --doctor
⚠ ⚠️ brain-index.md is older than project-knowledge (... is newer; run bash .tad/hooks/lib/brain-index-gen.sh to refresh)   # RC=0
```

Advisory warning printed, exit 0 in both paths (live file backup-guarded and restored).

## Negative Invariants (AC8)

- AC8.1: `sed -n '/"update")/,/;;/p' tad.sh | grep -F "quarantine-framework-pk"` → empty (rc=1).
- AC8.2: `grep -rn "brain-index" .tad/gates/ .tad/hooks/pre-gate-check.sh .tad/hooks/pre-accept-check.sh | grep -i "block"` → empty (rc=1).
- AC8.3: `ls .tad/project-knowledge/framework-principles.md` → No such file or directory.

## Code-review P2 dispositions (3 applied, 2 deferred to Alex)

- Applied: `grep -Fxq -e "$bn"` (dash-leading basename safety); `--help` synopsis lists `--doctor`/`--quarantine-pk`; quarantine MANIFEST header is append-guarded (same-second re-run cannot truncate).
- Deferred (no impl change): `--verify-denylist` TOP_DENY coverage + `find -quit` portability note → follow-up design input for Alex (recorded in COMPLETION).

## Friction Status

| # | Item | Status | Detail |
|---|------|--------|--------|
| 1 | Handoff-literal positional install form unrunnable | EQUIVALENT_SUBSTITUTE | cd-form install, same assertions; 3/3 Layer 2 confirm intent-preserving |
| 2 | Handoff-literal unconditional local/ skip breaks fresh install | EQUIVALENT_SUBSTITUTE | Scoped skip; self-check green + AC5.1 + upgrade-branch proof |
| 3 | $OLDPWD unset in fresh non-interactive shells (AC4.3/4.4) | EQUIVALENT_SUBSTITUTE | Preconditioned `export OLDPWD="$PWD"`; same command text otherwise |
| 4 | Expert reviewers (subagents) | READY | 3/3 independent reviews PASS, reports on disk |
| 5 | External CLI / network | NOT_APPLICABLE_WITH_REASON | Zero external calls; all fixtures local under /tmp |

No BLOCKED rows. Gate 3 PASS.

## Knowledge Distillation

```yaml
knowledge_distillation:
  attempted: false
  entries_distilled: 0
  brain_index_refreshed: true
  reason: "Pure isolation/quarantine installer change; no new reusable project pattern survived the variabilize test (findings are task-episode specific: installer CLI shapes, self-check coupling). Soft brain-index regen ran as a side effect of AC3.1."
```
