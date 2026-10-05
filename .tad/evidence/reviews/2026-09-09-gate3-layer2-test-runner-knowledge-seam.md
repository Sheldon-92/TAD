---
gate: 3
handoff: HANDOFF-20260908-knowledge-seam-isolation
reviewer: Layer 2 Group 2 test-runner (independent; did NOT author implementation)
date: 2026-09-09
verdict: PASS
counts:
  pass: 19
  fail: 0
  rows: 19
---

# Gate 3 Layer 2 Test-Runner Report — Knowledge Seam Isolation

**Handoff**: `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md` §9.1 (AC1.1–AC8.3, 19 rows)
**Method**: Re-executed every verification command in isolated `mktemp -d` fixtures under `/tmp` (auto-removed after run).
Live workspace was NOT modified: the only live-tree write was `brain-index-gen.sh` output, backed up to
`/tmp/brain-index-backup.md` before the run and restored byte-identical after
(`sha256 15c1c0c8…` both sides; the remaining `M` flag is Blake's pre-existing implementation edit).
**Interface adaptations applied** (per task brief, not treated as failures):
- `tad.sh` installs into CWD (no positional target arg): all install-form rows use
  `(cd "$TMPD" && bash "$SRC/tad.sh" --source "$SRC" --platform both --yes)`, asserting identical post-conditions.
- `export OLDPWD` / explicit `SRC` capture used instead of relying on `$OLDPWD`.
- `tad.sh --doctor` stale/fresh probes run against temp installs, never against the live tree.

## Per-row results

| # | Row | Result | Evidence |
|---|-----|--------|----------|
| AC1.1 | `derive-sync-set.sh` declares `brain-index.md` in `TOP_DENY` | PASS | `grep -F` hit in `TOP_DENY` block |
| AC1.2 | `tad.sh` declares `brain-index.md` in `TAD_TOP_DENY` | PASS | `grep -F` hit in `TAD_TOP_DENY` block (+ freshness-advisory block present) |
| AC1.3 | `derive_framework_top_files` uses set membership | PASS | `printf '%s\n' "$TAD_TOP_DENY" \| grep -Fxq -e "$bn" && continue` |
| AC1.4 | Behavioral top-file probe (main-free loader) | PASS | rc=0: `brain-index.md` excluded, `sync-registry.yaml` excluded, `version.txt` included |
| AC1.5 | `tad.sh --verify-denylist` | PASS | rc=0, "inlined DENY_LIST == derive-sync-set.sh (17 entries)" |
| AC2.1 | Clean install Option A structure (adapted cwd-install) | PASS | only `README.md` at pk root (+2 subdirs), 0 `*.md` under `patterns/`/`incidents/`, `brain-index.md` absent |
| AC3.1 | `brain-index-gen.sh` runs to completion | PASS | rc=0, "278 lines", no pipefail crash |
| AC3.2 | Archived-handoffs cap + complete fields | PASS | 50 `HANDOFF-` rows (= head-50 cap), no `\|\s*\|` empty cells, 0 `(see file)` fallbacks |
| AC4.1 | `--help` documents `--quarantine-pk` | PASS | usage line + description line matched |
| AC4.2 | Quarantine script executable + syntax | PASS | `-x` OK, `bash -n` OK |
| AC4.3 | Fixture: README + custom preserved | PASS | rc=0, both files intact, "User-modified knowledge preserved: custom.md" |
| AC4.4 | Idempotency on clean tree | PASS | "0 files quarantined", no `.tad/archive` created, rc=0 |
| AC5.1 | Project-owned preservation, 3 quoting forms (adapted) | PASS | c1 bare / c2 single / c3 double + `local/keep.txt` survive re-sync; ownership branch proven via real-upgrade (below) with "Preserving project-owned skill" logged |
| AC6.1 | Distillation Step 6 soft trigger, both trees | PASS | `brain-index-gen.sh … \|\| true` in Step 6 range of both `distillation-loop-protocol.md` + both `acceptance-protocol.md` |
| AC6.2 | Doctor/maintain WARN-only (temp installs) | PASS | fresh: rc=0 "is fresh"; stale (touch 20200101): rc=0 + "⚠️ brain-index.md is older than project-knowledge"; `tad-maintain` Step 1.6 advisory in both trees |
| AC7.1 | Dual-platform parity | PASS | `release-verify.sh parity .` rc=0, byte-identical |
| AC8.1 | `tad.sh update` never calls quarantine | PASS | `sed -n '/"update")/,/;;/p' … grep` empty (rc=1) |
| AC8.2 | Gate 3/4 never blocks on freshness | PASS | `grep -rn brain-index .tad/gates/ pre-gate-check pre-accept-check \| grep -i block` empty |
| AC8.3 | Zero `framework-principles.md` / provenance machinery | PASS | `ls` → No such file; `grep -rl provenance` over `tad.sh`+quarantine+derive → empty |

## Supplemental probes (all PASS)

1. **Fresh-install self-check green**: post-install log shows
   "✓ Self-check passed: 88 derived paths (diff-clean) + 22 top-level files present (platform: both)".
2. **Real-upgrade ownership branch**: temp target downgraded to `2.40.0`, planted `ownership: project-owned`
   `SKILL.md` in `.claude/skills/web-backend` + `.agents/skills/gate`; re-sync upgraded to `2.44.3`,
   both files preserved byte-identical (`diff` clean), log contains "→ Preserving project-owned skill: web-backend/gate".
   Repeated with single-quoted (`gate`) and double-quoted (`web-backend`) forms after re-downgrade: both preserved
   byte-identical with the same log lines. (Note: a same-version re-sync short-circuits with "Already v2.44.3",
   so the branch requires the version-downgrade trigger — expected installer behavior, not a defect.)
3. **Quarantine positive path**: fixture with byte-identical `patterns/shell-portability.md` (hash matches inlined
   manifest `36dd2879…`), locally-modified `principles.md`, seed `README.md`. Result: rc=0,
   "1 files quarantined → .tad/archive/quarantine-framework-pk-20260909-003216",
   identical file moved under `patterns/` in archive, `MANIFEST.md` row matches schema
   `\| Original File \| Sha256 \| Action \| Reason \| Timestamp \|`, README in place,
   modified file kept with "User-modified knowledge preserved: principles.md".
4. **Quarantine 2nd-run idempotency**: re-run on cleaned fixture → "0 files quarantined", archive dir count 1→1, rc=0.
5. **Doctor matrix**: fresh-index rc=0 + "is fresh", 0 "older" warnings; stale-index rc=0 + exactly the advisory warning;
   pk-only install (no index) rc=0 + skip advisory. All WARN-only, never blocking.

## Runner note (non-finding)

`brain-index-gen.sh` resolves `TAD_ROOT` from its own script path (`dirname $0/../../..`), not from CWD —
invoking the SRC copy while cwd is a temp dir regenerates the **source tree's** index. Observing this mid-run,
I restored the live file byte-identical (hash-verified). Recommend future test-runners copy the script tree
into the fixture if a hermetic generation probe is needed. No implementation change implied.

## Tally

- Evaluated: 19/19 §9.1 rows. **Pass: 19. Fail: 0.** Supplemental probes: 5/5 pass.
- No P0/P1 defects found. Nothing contradicts the Group 0 / Group 1 PASS.

VERDICT: PASS
