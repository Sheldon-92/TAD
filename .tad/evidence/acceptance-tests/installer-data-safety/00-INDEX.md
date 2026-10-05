# Evidence Index — installer-data-safety (A-track)

Canonical per-case green logs (read these; ignore superseded files below):

| AC | Canonical log | Result |
|---|---|---|
| AC2.1 | `green-sweep-20260903.log` lines 4–12 | 9/9 (offline rc=0, curl-empty, version, source-identical, ==target reject) |
| AC2.2/2.3 | `green-sweep-20260903.log` lines 13–43 | user matrix ×3 platforms |
| AC2.4 | `green-sweep-20260903.log` lines 44–48 | timestamped backup preserves marker-less bytes |
| AC2.5 | `green-ac2.5.log` | 5/5 (guard + same-line + unique + 2 mutations) |
| AC2.6 | `green-ac2.6-full.log` | 10/10 (2.6a inert + 2.6b user-untouched + stale-removed) |
| AC2.7 | `green-part2-fast.log` ac2.7 block | 5/5 (direction + negative control + 2 adversarial YAMLs) |
| AC2.8 | `green-ac2.8-fixround.log` | 9/9 (rollback byte-identity + foreign-cwd + ENOSPC + truncation-atomicity) |
| AC2.9 | `green-part2-fast.log` ac2.9 block | 5/5 (user .bak + namespaced backups) |
| AC2.10 | `green-ac2.10-full-14.log` | 14/14 (members + links + hardlinks + sentinels) |
| AC2.11 | `green-part2-slow.log` ac2.11 block | 7/7 (same-second + loud failure + integration) |
| AC2.12 | `green-ac2.12.log` (2/2) + `probe-ac2.12-derive-denylist.log` | disjoint + denylist |
| R1 | fence report in COMPLETION (commit scope ⊆ §7; verifier untouched) | attribution, see COMPLETION |
| R2 | `red-*.log` (8) + `probe-*.log` (3), all HEAD+STATUS headers | red-first archive |

Red logs (pre-fix proof, all with HEAD + `git status` headers):

| Log | Proves |
|---|---|
| `red-ac2.1-fR1-no-source-flag.log` | no `--source` case pre-fix |
| `red-ac2.2-blocked-by-fr1.log`, `red-ac2.3-blocked-by-fr1.log` | sandbox matrix blocked pre-FR-1 |
| `red-ac2.4-ac2.9-f05-bare-bak.log` | bare-`.bak` clobber shape |
| `red-ac2.5-no-guard.log` | no machine guard pre-fix |
| `red-ac2.6a-deprecation-floor-clobber.log` | floor semantics observation |
| `red-ac2.8-f06-rollback-coverage.log` | `.tad`-only + relative-path rollback |
| `red-ac2.10-f07-cwd-extract-tarslip.log` | cwd extract + unvalidated members |
| `red-ac2.11-f08-archived-skip.log` | skip-if-exists + silent `mv` |
| `red-fixround-p0-rollback.log` | fix-round: sibling wipe drift + truncation loss on f61c1892 tree |

Adjudications: `rm-ok-appendix.md` (26 ids + 3 exclusions + N5/N6/N3 + fix-round P0/P1 log).
Allowlists: `fixtures-allowlist.sha256` (2 adversarial YAMLs).

SUPERSEDED (kept for audit trail, do NOT cite as pass evidence):
- `green-sweep-20260903.log` beyond line 48 (truncated mid-2.6a, no Summary — superseded by per-case logs above)
- `green-part2-slow.log` ac2.10 9-line block (superseded by `green-ac2.10-full-14.log`)
- `green-ac2.10-n5-rerun.log` (12 lines, missing hardlink pair — superseded by full-14)
- `guard-demo.txt` (E1-era guard probe, unrelated track residue if present)
