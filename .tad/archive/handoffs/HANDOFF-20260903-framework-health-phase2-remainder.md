# Handoff: Framework-Health Close-out A — Installer Data-Safety Remainder

**Handoff**: `.tad/active/handoffs/HANDOFF-20260903-framework-health-phase2-remainder.md`
**Epic**: `.tad/active/epics/EPIC-20260816-framework-health-repair.md` (Phase 2 remainder ONLY; 1b + re-slim ride track B)
**Design**: `.tad/active/designs/DESIGN-20260903-framework-health-phase2-remainder.md` (rationale; THIS handoff wins on execution conflicts)
**Task ID**: `TASK-20260903-FWHEALTH-A`
**Mode**: YOLO (human mandate 2026-09-03: A→B split; gates/reviews/red-first NOT skipped)
**Execution Mandate**: FR-1 + FR-5 + F-05/F-06/F-07/F-08 + F-34 + AC2.5 + AC2.1–2.12 + R1 + R2 (14 ACs §9.1). Nothing else.

## 🔴 Gate 2: Design Completeness — ✅ PASS (Alex, 2026-09-03)

- Gate 1 PASS: 5-round Socratic record in design §0 (R2 human depth/mandate; rest self-answered from measured evidence per Epic's line-436 lesson).
- Security audit R1 FAIL (6 P0 + 11 P1) → ALL integrated into design (rollback coverage-extension, source trust/disjointness/ordering, absolutization, widened guard scope, tar-slip pinning, + 11 P1s). Code review R1 FAIL (3 P0 + 8 P1) → ALL integrated. Code R2 CONDITIONAL PASS (N1–N4 patched in design; N5–N7 ride as §11 appendix items). 0 P0 open. 2 distinct reviewers, zero self-review.
- MQ1–MQ6 evidenced (design §2; line-cites independently re-verified). Knowledge Assessment present (design §6). Friction preflight present (design §3.5). 14/14 ACs literal + design dry-run. No implementation started (Alex created only the design doc).

## 📋 Handoff Checklist

- [ ] This handoff is Blake's ONLY instruction source (design = rationale backup)
- [ ] YOLO: no pauses for non-critical confirmations; STOP + report on P0 surprise, scope-creep pressure, or red-that-won't-reproduce

## 1. Task Overview

### 1.1 What We Are Building
Close Epic Phase 2's remaining rows against the CURRENT tree (audit line numbers are dead — v2431 rewrote the region; every item RE-PROVES red first): `--source` offline mode (FR-1) + owner-aware acceptance (FR-5) + five installer defect fixes (F-05/06/07/08 + F-34 direction test) + machine-checked destructive-operation guard (AC2.5) + full sandbox matrix (AC2.1–2.12) + scope fence (R1) + red-log archive (R2).

### 1.2 Why
P0 installer defects delete user data; the publish ban (Epic hard constraint 1) lifts ONLY when Phase 2 passes Gate 4. F-01/F-02/F-03 are DONE; this handoff finishes the rest without re-litigating them.

### 1.3 Intent Statement
Prove each defect red on today's tree, fix reds minimally by reusing `do_backup`/`guarded_remove`/migration-engine (never rewrite guards), and leave machine-checked + behavioral proof that user-owned bytes survive installs.

## 📚 Project Knowledge

### Files Read by Alex (Blake: re-read, don't trust my line numbers — tree moves)
- Audit `F-33/F-34/F-05..F-08` (`AUDIT-20260816-framework-health.md:311-386`) + Epic Phase-2 ACs (`EPIC:287-309`) + Epic hard constraints (`EPIC:147-152`)
- `tad.sh` (2301 lines): rollback `:1474-1495`, trap `:1518`, `merge_claude_md:1523-` (`.bak:1538/1551/1554/1556/1558`), pack-meta `rm -f:574/599`, opencode `rm -f/rmdir:1744-1746`, download `:1932-1935`, probe `:1788` vs pinned `:1787-1794`, `--release-ref:101`, `_archived :2091/:2159` + `mv||true :2095/:2184`, `find -delete :1391-1393`, rm sites `:1478,:1490,:1518(×2),:1639,:1643,:1647,:1652,:1662,:1669,:1680,:1685,:1956,:2270`, FR-1b comments `:1937,:1953-1954,:2267-2268`, `derive_target_version:33`, `backup_existing:218-238`, `MIGRATE_BACKUP_DIR:2132-2138`, DENY_LIST `:274-283`
- `upgrade-acceptance.sh` Check 3 (`:158-217`), `.tad/deprecation.yaml` (方案C — READ ONLY, fenced), `release-verify.sh` STABLE header (`:1-2`)
- `.tad/project-knowledge/patterns/shell-portability.md` (timeout chain, heredoc sinks, rm-chokepoint, `grep -F`+anchors, zsh traps, `comm` locale, `~`-in-variables)

### Blake Must Remember
- `--yes`-less installer runs exit 0 with ZERO mutations (`tad.sh:1914-1923`) — rc-alone assertions are VACUOUS. Every sandbox AC needs `--yes` + a positive-install proof.
- No `gtimeout`/`timeout` on the dev host; `/usr/bin/perl` present (verified 2026-09-03). AC scripts: baseline tools, `grep -F -e`, `LC_ALL=C`, no `rg`, no `for x in $VAR`, smoke `bash` + `zsh`.
- This host's `grep` is ugrep — dash-leading patterns need `-e`; `-F` disables `^`/`$` anchors.
- `git ls-files` scoping for repo-wide greps (raw FS walks pick up `.worktrees/` + `progress/` + other tracks' dirt).

## 2. Background Context

### 2.1 Existing Assets to Reuse (NEVER rewrite)
`do_backup`/`guarded_remove`, `backup_existing()` timestamp scheme (`:221-227`), `MIGRATE_BACKUP_DIR` increment pattern (`:2132-2138`), migration-engine gate chain, `derive_target_version`, `verify_denylist_drift`, `derive-sync-set` disjointness, `merge_claude_md` contract (fix around it, not instead of it).

### 2.2 Current vs Target
- Current: no `--source`; `.bak` clobbering; rollback restores `.tad`-only with relative paths + overbroad message; cwd-extract; migrate `_archived` clobbers + silent `mv`; Check-3 direction correct-by-construction but untested; zero machine-checked rm guard.
- Target: §4 + §9.1. Nothing else.

### 2.3 Dependencies
None (Phase 1 DONE per ledger). Track B needs THIS track's "no runtime reads evidence" confirmation — record it in COMPLETION.

## 3. Requirements

### 3.1 Functional Requirements
- FR-1: `tad.sh --source <dir>` offline installs (trust boundary + validation ordering + disjointness + probe bypass + `derive_target_version` + `--release-ref` exclusion + flag-beats-env + `cleanup_source_tree` chokepoint + TMPDIR validation) — design §3.1.
- FR-5: owner-aware acceptance — user-owned paths asserted present + byte-identical post-install (sandbox suite).
- F-05: namespaced timestamped backups; pre-existing user same-name file survives.
- F-06: snapshot+restore ALL post-`NEED_ROLLBACK` surfaces (list in design MQ5); absolutized rm+mv+BACKUP_PATH; atomic copy-back-verify-remove; message enumerates coverage.
- F-07: temp-dir extraction for BOTH paths; tar-slip member validation (`tar -tvzf`, absolute/`..`/escaping-link rejection); malicious-tar fixture.
- F-08: migrate `_archived` unique-timestamp-suffix via reused increment loop; determinism defined + tested.
- F-34: Check-3 direction regression test + adversarial parser fixtures (tests live in the NEW fixture suite; verifier file untouched unless red-proven).
- AC2.5: `installer-destructive-guard` subcommand (widened scope + same-line markers + baked-in comment exclusions + mutation probe).

### 3.2 Non-Functional Requirements
- Portability: BSD/macOS-safe; tamper-evident logs; deterministic fixtures (same-second collision test included).
- Red-first: EVERY fix carries a pre-fix red log (HEAD + status + failing assertion); no log = Gate 3 FAIL for that item.
- Atomicity: failed runs leave user bytes intact (proven, not asserted).

### 3.3 Conflict Matrix
- Speed vs red-first: red-first wins (Epic hard constraint 2). YOLO never skips it.
- Message-vs-coverage: coverage wins (R2 P0-1 — disclosed loss is still loss).
- Reuse-vs-rewrite: reuse wins (Epic hard constraint 3 — audit §6 red lines).

## 4. Technical Design (implementation view; rationale in design §§3.1–3.5)

### 4.1 Architecture
No new daemons/formats/registries. One flag, one fixture suite, one guard subcommand, surgical installer fixes. DENY_LIST mirrored-edit rule (both files or neither; drift → escalate, never widen here).

### 4.2 FR-1 `--source`
Design §3.1 EXACTLY (trust note in `--help`; validation at arg-parse before probe/download/trap-arm/backup/first-exec; disjointness case-normalised; probe bypass + derive; mutual exclusion; single chokepoint; TMPDIR validation). Fixture stages a PRUNED source copy (4 sentinels + `version.txt`) — NEVER the live repo.

### 4.3 Sandbox suite (CREATE `.tad/tests/installer-data-safety-fixture.sh` + `.tad/tests/fixtures/` allowlist)
`--case` per AC2.x; `--yes` + positive-install proof on EVERY invocation; `curl()` function-export shim + empty-log assertion; snapshots in SIBLING dir outside target; preflight containment (TARGET inside mktemp root, ≠ `/`, ≠ repo); guarded fixture cleanup.

### 4.4 Fixes (ONLY red-proven items; §3.3 + §3.4 of design)
F-05 namespacing (old `.bak` site must DISAPPEAR, not gain a marker) / F-06 coverage+absolutization+atomicity / F-07 temp+tar-slip / F-08 increment-loop / F-34 tests-first / AC2.5 guard + markers + exclusions.

### 4.5 State and Evidence Flow
Red logs + green outputs + digests + manifests under `.tad/evidence/acceptance-tests/installer-data-safety/` (gitignored — local truth; Gate reads files, not `git status`).

## 5. Mandatory Questions (answered — design §2; not re-asked)

MQ1 search ✓ (R2-corrected counts) / MQ2 reuse list ✓ / MQ3 flows ✓ / MQ4 N/A / MQ5 hardened ✓ / MQ6 in-repo only ✓.

## 6. Out-of-Scope (STOP conditions)

`deprecation.yaml` edits; migration-engine behavior changes; Phase-3 files; skills/gates/hooks (beyond the ONE new subcommand + header note); evidence/archive index surgery (track B); DENY_LIST remediation (escalate only); downstream projects; `filter-repo`/history rewrite; upper-bound version semantics invention (AC2.6 tests the floor that EXISTS). Needing any → STOP + report.

## 7. Files (closed world)

MODIFY: `tad.sh`; `.tad/hooks/lib/release-verify.sh` (ADD subcommand + header + usage ONLY).
CREATE: `.tad/tests/installer-data-safety-fixture.sh`; `.tad/tests/fixtures/` (adversarial YAML + sentinels ONLY).
CONDITIONAL-MODIFY: `.tad/tests/upgrade-acceptance.sh` (ONLY if AC2.7 red-proven on current tree).
FENCED (any diff = FAIL): everything else, named in R1 (design §4 R1 line).

## 8. Bound Paths

- Sandbox: `mktemp -d` per case (`$SANDBOX/target`, `$SANDBOX/../snapshots` sibling).
- Pruned source: `$SANDBOX/source` (4 sentinels + `version.txt` copied from tree, never the live repo).
- Evidence: `.tad/evidence/acceptance-tests/installer-data-safety/`.
- Fixture allowlist: `.tad/tests/fixtures/`.

## 9. Acceptance Criteria (literal)

### 9.1 Runnable checks (design §4 lines duplicated here as the execution contract)
- [ ] **AC2.1**: `bash tad.sh --source $SANDBOX/source --platform both --yes` → rc=0 AND `curl`-shim log empty AND `.tad/version.txt` == source version AND source `diff -r` identical (incl. post-failure); `--source` == target → usage error + zero mutations.
- [ ] **AC2.2**: red probe with HEAD+status header; then user-file matrix → `diff -r` empty (red-log OR pre-proven-green + regression guard).
- [ ] **AC2.3**: AC2.2 × 3 platforms.
- [ ] **AC2.4**: marker-less `CLAUDE.md` preserved + timestamped (non-`.bak`) backup.
- [ ] **AC2.5**: `installer-destructive-guard` exit 0 (same-line per-site markers, unique ids + appendix; baked-in comment exclusions; mutation probe fails it on demand).
- [ ] **AC2.6**: current=`2.2.0` → 2.3.0 entries inert (zero attempt-logs + intact); current=`2.3.1` + target=`2.43.1` → only the 3 TAD-owned paths touched.
- [ ] **AC2.7**: user `.codex/`+`AGENTS.md` → Check 3 PASS; adversarial YAML battery green.
- [ ] **AC2.8**: `cp()`-shim forced ERR → all surfaces byte-identical + message enumerates; sed-extracted rollback under foreign cwd restores target only; `ulimit -f` ENOSPC → backup preserved + explicit message.
- [ ] **AC2.9**: user `CLAUDE.md.bak` byte-identical; new backups namespaced+timestamped.
- [ ] **AC2.10**: user `TAD-main/` identical; root+parent sentinels identical; malicious tar → rejected pre-extraction, zero outside writes.
- [ ] **AC2.11**: double migrate → two timestamped dirs, zero overwrites (incl. same-second run); `chmod -w` move failure → loud non-zero.
- [ ] **AC2.12**: `--dirs` ∩ `--zero-touch` = ∅ + `--verify-denylist` PASS.
- [ ] **R1**: `git status` matches §7 fence exactly (fixtures allowlist included; NOTHING else).
- [ ] **R2**: red logs (+HEAD/status headers) for every fixed item; green outputs for kept items; missing = Gate 3 FAIL.

### 9.2 Expert Review Status (Gate 2)
security-auditor R1 FAIL (6 P0 + 11 P1, all integrated) ; code-reviewer R1 FAIL (3 P0 + 8 P1, all integrated) → R2 CONDITIONAL PASS (N1–N4 patched in design; N5–N7 below). 0 P0 open.

## 10. Ralph Loop + Gate 3 Notes

- Order: FR-1 first (all sandbox ACs need it) → red probes → reds-only fixes → guard subcommand → full sweep.
- Gate 3 needs Layer 2 (2 reviewers; one MUST re-prove the §3.5 security pins + red-log bindings) + `bash -n` + COMPLETION + evidence. Then back to Alex for Gate 4 (distill decision on design §6 candidate).
- AC scripts smoke-run under `bash` AND `zsh` before Gate-3-ready.

## 11. Blake-Adjudicated Appendix Items (R2 N5–N7; reviewer sign-off required, no human needed)

- **N5**: pin the `->` link-target parse predicate from `tar -tvzf` output + resolve-against-target containment assertion (AC2.10).
- **N6**: enumerate the sentinel allowlist (exact names/bytes) under `.tad/tests/fixtures/`.
- **N3-carry**: AC2.6b already pins the 3 paths + version-read (design); keep.
- **Do NOT**: invent upper-bound version semantics; weaken any guard to pass; grade own edits (AC2.7 tests stay in the fixture suite).

## 12. Do NOT

Touch §7-fenced files. Run installer outside mktemp sandboxes. Point `--source` at the live repo. Ship `SKIP` as `PASS`. Publish/tag/sync (ban stands until THIS track passes Gate 4).
