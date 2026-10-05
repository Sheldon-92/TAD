# Design: Framework-Health Close-out A — Installer Data-Safety Remainder

**Design ID**: `DESIGN-20260903-framework-health-phase2-remainder`
**Epic**: `.tad/active/epics/EPIC-20260816-framework-health-repair.md` (Phase 2 remainder; 1b + re-slim ride track B)
**Execution**: single handoff, YOLO (human mandate 2026-09-03: A→B split; gates intact)
**Requires**: NOTHING from track B. Enables: publish-ban release (Epic hard constraint 1).

## 0. Socratic record (5 rounds; R2 human, rest self-answered from evidence)

- **R1 signal/scope** — Q: Phase 2 还剩什么? A (measured 2026-09-03, not assumed): F-01/F-02/F-03 DONE; F-34 fixed-by-construction but untested; F-05 RED (`merge_claude_md:1538/1558` unchanged shape); F-06/F-07/F-08 UNKNOWN (v2431 reworked the region — line numbers dead); FR-1 RED (no `--source`, two "将来支持" comments); FR-5 RED (no guard); AC2.5 OPEN (no check in `release-verify.sh`, ~15 bare `rm -rf` in current `tad.sh`); SC3 REGRESSED (tarball 9.39 MB > 8 MB; 112 tracked evidence + 22 archive, Local-Wiki/YOLO2 commits post-Phase-4).
- **R2 depth/mandate (HUMAN 2026-09-03)**: A→B split confirmed. A = installer remainder (measure-first, red-first). B = 1b + re-slim.
- **R3 interface latitude** — Q: `--source` flag vs env? A: Epic permits either; handoff mandates the FLAG (`tad.sh --source <dir>`) with behavior pinned by AC2.1 (offline full run rc=0); env alias allowed only as a bonus, never a substitute.
- **R4 risk order** — Q: why A before B? A: Epic dependency + risk (B's re-slim needs A's confirmation that no runtime reads evidence; installer deletions are the P0).
- **R5 done-definition** — Q: what flips the ledger? A: Phase-2 table rows FR-1/FR-5/AC2.5 → DONE + AC2.1–2.12 green on current tree + SC1/SC4/SC5 certified; SC2/SC3 ride track B.

## 1. Gate 1 — Requirements Clarity: PASS

Signal: Epic Phase-2 remainder + fresh red-measurements (above). No-signal exits N/A (this is a defect-closure track; every item has an audit red baseline — Blake must RE-PROVE red on the CURRENT tree before fixing; anything already green is recorded pre-proven, not re-implemented). ACs: 14 (AC2.1–2.12 + R1 scope + R2 red-proof), each literal + runnable (§6), dry-run §7.

## 2. Mandatory Questions

### MQ1 — Historical Code Search (before designing — violation otherwise)
- Audit `F-33/F-34/F-05..F-08` (§3, `AUDIT-20260816-framework-health.md:311-386`) + Epic Phase-2 ACs (`:287-309`).
- Current `tad.sh` (2301 lines): `rollback_on_failure:1474-1495` (`rm -rf .tad` RELATIVE at `:1478` + relative `mv` at `:1479` + relative `BACKUP_PATH` at `:221-236` — cwd-sensitive, in-code comment at `:1303` admits it); EXIT trap `:1518` (2 sites, 1 line, guarded ✓); `merge_claude_md:1523-` (`cp→CLAUDE.md.bak:1538`, `rm -f:1558,1551/1554/1556`, pack-meta `rm -f:574/599`, opencode `rm -f:1744` + `rmdir:1745-1746` — adjudicate all); download `1933-1935` (`curl|tar` into cwd, `TAD_SRC=TAD-main` — F-07 shape intact; probe at `:1788`, pinned branch `:1787-1794`, `--release-ref` at `:101`); install `_archived` guard `:2091` ✓ vs migrate `:2159` `mkdir -p` + `mv||true` (`:2095`,`:2184` — F-08 shape intact); `rm -rf` sites `:1478,:1490,:1518,:1639,:1643,:1647,:1652,:1662,:1669,:1680,:1685` (8 in the tmp block) + `find -delete :1391-1393` + `:1956`,`:2270` (audit line numbers dead — v2431 rewrote the region); FR-1b comments (`:1937,:1953-1954,:2267-2268`) literally contain `rm -rf` (check MUST exclude them — see AC2.5).
- `upgrade-acceptance.sh` Check 3 (`:156-214`): parses `files:` lists (方案C: 3 TAD-owned paths) + regenerated-exemption; `removed_from_this_list:` structurally excluded by awk scoping (verified by reading, NOT assumed) — F-34 fixed-by-construction, zero direction tests.
- `deprecation.yaml`: 方案C + owner-tagged removed list — classification decision CLOSED, file UNTOUCHED by this handoff.
- `release-verify.sh`: NO destructive-guard check exists (grep verified) — AC2.5 check is new construction (STABLE-contract header note required).
- No installer-level `--source` handling (red-proof: `grep -n -- '--source)' tad.sh` empty pre-fix; `grep -cn 'TAD_SOURCE_DIR' tad.sh` → 0 pre-fix). NOTE: `tad.sh:1219` passes `--source "$src"` to the migration ENGINE — the claim is precisely "no `--source)` arg-parse case", not "string absent".

### MQ2 — Existing Function Verification
- `do_backup`/`guarded_remove` (migration-engine path, `:1283-1385` call sites) — reuse, don't rewrite (Epic hard constraint 3).
- `merge_claude_md` contract, `call_migration_engine`, `verify_denylist_drift`, `derive-sync-set --dirs/--zero-touch` disjointness — read, reused as regression anchors (AC2.12).

### MQ3 — Data Flow Completeness
- FR-1: `--source <dir>` (extracted-tree layout: `tad.sh`, `.tad/`, `.claude/`, `.agents/`) → skip curl → `TAD_SRC_DOWNLOADED=0` → rollback/trap NEVER remove user-supplied source (FR-1b comments already scope cleanup to downloaded-only — pin with test).
- Sandbox suite (new `.tad/tests/installer-data-safety-fixture.sh`): mktemp project → plant user files → run installer offline → assert presence + byte-identity + backups; 3 platforms × full matrix.
- AC2.5 check (`release-verify.sh installer-destructive-guard`): every `rm -rf`/`rm -f`/`find -delete` site carries same-line `# RM-OK:<id>`, each id unique; appendix justifies each id Blake writes.

### MQ4 — Visual Hierarchy
N/A — CLI + verdict text only.

### MQ5 — Failure Handling (R2 security-audit hardened — message/coverage discretion REMOVED)
- Red-first MANDATORY (Epic hard constraint 2): each AC2.x starts with a red probe on the unmodified tree, logged; fix only reds; greens recorded pre-proven with the passing command output.
- Rollback coverage MUST extend (F-06; "rewrite the message instead" is REJECTED — disclosed loss is still loss): snapshot-then-restore EVERY surface mutated after `NEED_ROLLBACK=1` — at minimum `CLAUDE.md` + its timestamped backup, `.claude/skills/` trees, root files, `.codex/hooks.json`, `.tad/version.txt` — verified by byte-identity after forced-ERR rollback. The message then enumerates restored surfaces; message-only is permitted SOLELY for surfaces the installer provably never mutates.
- Rollback atomicity: copy-back + verify + only-then-remove (or `mv`-or-die with backup preserved in place + explicit failed-state message); ENOSPC fault-injection in AC2.8 (disk-full lesson).
- `rm -rf .tad` absolutized (operate on captured absolute `$TARGET`, never cwd-relative) + `/`-refusal + non-empty + containment-under-root; `BACKUP_PATH` absolutized at capture; BOTH `:1478`-class rm AND `:1479`-class `mv` sides covered.
- `mv … || true` evidence swallowing: scoped STRICTLY to the two `_archived` loops; `:1393` (`find … || true`, ERR-trap suppression by design) and `|| engine_rc=$?` capture EXCLUDED and named; empty-glob no-op distinguished from real `mv` failure; note `set -e`+ERR interaction (newly-loud failure fires rollback — which after this handoff restores everything per coverage rule).

### MQ6 — Research Priority
In-repo only (audit + Epic + current tree). No external research; no NotebookLM.

## 3. Technical Design

### 3.1 FR-1 `--source <dir>` (`tad.sh` MODIFY)
- Flag `--source <dir>` (+ `TAD_SOURCE_DIR` env fills ONLY when flag absent — flag wins, documented; never silent env override).
- **Trust boundary (explicit)**: `--source` = fully-trusted local tree. Never point at unreviewed checkouts: the installer `bash`/`source`s engine scripts from it. Document in `--help` + handoff.
- **Validation ordering (all at arg-parse, before probe, download, trap-arm side effects, backup, and first `bash`/`source` of anything under it)**: exists + directory + leaf-not-symlink + physically resolved (`cd && pwd -P`) + contains the 4 sentinels (`tad.sh`, `.tad/`, `.claude/`, `.agents/`) + DISJOINT from TARGET both directions (source ≠ target after resolution; neither contains the other — covers `--source .`, symlink/`..` aliases, target-inside-source self-nesting; APFS case-aliases compared case-normalised, residual documented).
- `--source` BYPASSES `probe_remote_version` (same as pinned branch, `tad.sh:1787-1794`) and runs `derive_target_version <resolved-source>` post-validation/pre-state-gate; `--source` × `--release-ref`/any pinned-download mode mutually exclusive (usage error if combined).
- Skip curl/tar entirely; `TAD_SRC=<resolved dir>`, `TAD_SRC_DOWNLOADED=0`; cleanup via the SINGLE `cleanup_source_tree` chokepoint (new; the ONLY rm-site allowed to reference `TAD_SRC`, keyed on the flag — AC asserts no other `rm` names `TAD_SRC`); EXIT-trap/rollback paths stay inert for user-supplied dirs (regression test: source tree byte-identical after run incl. failed run).
- `TMPDIR` validated wherever `mktemp` is adjudicated (absolute + existing + writable, else fail-closed to `/tmp`); removal targets must carry the expected mktemp prefix + non-empty + is-directory (applies to installer AND fixture temp dirs).

### 3.2 Sandbox suite (CREATE `.tad/tests/installer-data-safety-fixture.sh`, `--case` per AC)
Matrix (`--yes` on EVERY sandbox installer invocation — bare runs exit 0 with zero mutations): `--platform claude-code/codex/both` × cases AC2.2 (user `.codex/config.toml`, `.codex/prompts/mine.md`, `.gemini/settings.json`, own `AGENTS.md`/`GEMINI.md`/`CLAUDE.md` → `diff -r` empty), AC2.4 (marker-less CLAUDE.md preserved + timestamped backup), AC2.9 (user `CLAUDE.md.bak` survives — implies F-05 namespaced backups), AC2.10 (user `TAD-main/` dir survives + malicious-tar zero-escape), AC2.3 (×3 platforms), AC2.11 (migrate twice → 2nd timestamped dir, determinism asserted), AC2.6 (version-floor, both directions pinned), AC2.8 (forced ERR → full coverage restore + ENOSPC case). All OFFLINE via `--source` (AC2.1: full run rc=0 + empty curl-shim log). Fixture safety: snapshots/reference trees live in a SIBLING dir OUTSIDE the sandbox target; fixture preflight refuses if resolved TARGET escapes the mktemp root, equals `/`, or equals the repo; fixture's own cleanup uses guarded removal, never bare `rm -rf`.

### 3.3 Fixes (only for red-proven items)
- **F-05**: namespaced timestamped backups via `backup_existing()` scheme; pre-existing user same-name file never overwritten/deleted on success path.
- **F-06**: coverage-extension mandate per MQ5 (snapshot+restore all post-NEED_ROLLBACK surfaces; `rm`+`mv` absolutized; atomic copy-back-verify-remove).
- **F-07**: BOTH extract paths (unpinned `curl|tar` AND pinned) to `mktemp -d`: validate member listing BEFORE extraction (reject absolute + `..` members — tar-slip), single-root discovery, move into place; post-extract existence assertion + ERR cleanup. Malicious-tar fixture (absolute + `..` members → zero writes outside target).
- **F-08**: migrate `_archived` PINNED to unique-timestamp-suffix (skip-if-exists WRONG per audit; accumulation accepted, rotation out of scope); rerun determinism asserted. `|| true` purge scoped per MQ5.
- **F-34**: direction regression test (user `.codex/` + `AGENTS.md` present → Check 3 PASS) + parser test (a `removed_from_this_list` entry never flags). No parser refactor unless red.
- **AC2.5**: per-site adjudication (§3.4 table Blake fills) + `installer-destructive-guard` check (widened scope per R2: `rm -rf`/`rm -f`/`find -delete` same-line markers; `cp`/`mv` behavioral via suite).

### 3.4 rm/destructive adjudication (Blake verifies each on current tree; table is START, not verdict)
Scope rule (honest split): MECHANICAL check covers `rm -rf` + `rm -f` + `find -delete` + `rmdir` (enumerable verbs); `cp`/`mv`-onto-user-destination vectors are covered BEHAVIORALLY by the sandbox suite (AC2.2/2.4/2.9/2.10 assert user-file byte-identity). The check alone is NEVER presented as the data-safety gate.
Marker scheme (game-resistant): `# RM-OK:<id>` on the SAME line as the destructive call (trailing), ONE marker PER SITE (multi-site lines carry N markers), each id used exactly once; appendix justifies each id. Same-line binding defeats paste-above gaming.
Comment/string exclusion (REQUIRED, not optional): the check MUST NOT trip on FR-1b comment lines (`:1937,:1953-1954,:2267-2268`) or other prose mentions. Method: fixed-string exclusion patterns BAKED INTO the check (each exclusion a reviewed literal, listed in the appendix); Gate 3 verifies no exclusion covers a real call (mutation probe: insert an unmarked `rm -rf` in a sandbox copy → check fails).

| Site | Current shape | Required disposition |
|---|---|---|
| `:1478` `rm -rf .tad` + `:1479` `mv $BACKUP_PATH .tad` (rollback) | relative both sides; `BACKUP_PATH` relative (`:221-236`) | absolute captured root for rm AND mv; `BACKUP_PATH` absolutized at capture; `/`-refusal + non-empty + containment |
| `:1391-1393` `find … -depth -delete` | unexamined | adjudicate (scope of deletion + guards) + marker |
| `rm -f` sites `:1551,:1554,:1556` (merge tmp), `:574,:599` (pack-meta), `:1744` + `rmdir :1745-1746` (opencode) | unexamined | adjudicate each (tmp-owned? user-visible?); markers required uniformly |
| `:1490` `rm -rf $TAD_SRC` (rollback) | flag+non-empty+dir guarded | migrate into `cleanup_source_tree` chokepoint + `# RM-OK` |
| `:1518` trap rms (2 sites, 1 line) | `-n`/`-d`/flag guarded | keep + per-site `# RM-OK` on the line |
| `:1639,:1643,:1647,:1652,:1662,:1669,:1680,:1685` `rm -rf $tmp_root` ×8 | failure exits | prove mktemp-owned + TMPDIR-validated + prefix/empty/dir guards each |
| `:1956`,`:2270` `rm -rf $TAD_SRC` | post-extract cleanup | migrate into `cleanup_source_tree`; prove downloaded-only (FR-1b) |
| `rm -f CLAUDE.md.bak` (`:1558`) | F-05 destroyer | removed by namespacing fix (no marker — site must DISAPPEAR) |
| any NEW sites FR-1/coverage-extension adds | — | same bar, no exceptions |

### 3.5 Friction Preflight (§8.4)
| Point | Step | Fix path | Substitute | Gate impact |
|---|---|---|---|---|
| Installer-risky edits | red probe BEFORE every fix, logged | local mktemp sandbox | none — "fix then test" rejected per Epic | missing red log blocks Gate 3 |
| Network in sandbox ACs | AC2.1 asserts zero-network (curl-shim fail-closed) | local `--source` | none | network touch fails AC2.1 |
| macOS/BSD `cp/tar/date` | sandbox runs on this macOS host; timestamp format BSD-safe | local | GNU-only evidence not equivalent | blocks Gate 3 |
| Reviewer availability | 2 independent pre-handoff | subagents | never self-review | <2 blocks Gate 2 |
| AC portability | baseline tools, `grep -F -e`, `LC_ALL=C`, no `rg`, zsh-safe | smoke both shells | none | blocks Gate 3 |

## 4. Acceptance Criteria (14; every line dry-run for parse at design time)

- [ ] **AC2.1 (FR-1)**: `bash tad.sh --source <local-tree> --platform both --yes` in `mktemp -d` sandbox → rc=0 with a fail-closed `curl()` shell-function export (+ PATH shim belt-and-braces) whose invocation log is asserted EMPTY (any invocation = FAIL, not just rc); positive-install proof (`.tad/version.txt` exists and equals the source tree's version — `--yes`-less runs exit 0 with ZERO mutations per `tad.sh:1914-1923`, so rc alone is vacuous); source tree `diff -r` identical after (incl. after a forced-failure run); `--source` == target (post-resolution) → usage error + zero mutations (pre/post snapshot).
- [ ] **AC2.2**: red probe MANDATORY (log carries `git rev-parse HEAD` + `git status --porcelain` proving unmodified tree + failing assertion output); outcome EITHER red log (then fix) OR pre-proven-green output (then keep + regression-guard) — no log = Gate 3 FAIL. Green case: planted user files → post-install `diff -r snapshot` empty.
- [ ] **AC2.3**: AC2.2 suite × `--platform claude-code/codex/both` — 3/3 green.
- [ ] **AC2.4**: marker-less custom `CLAUDE.md` → content preserved + timestamped backup exists (NOT bare `.bak`).
- [ ] **AC2.5**: `bash .tad/hooks/lib/release-verify.sh installer-destructive-guard .` → exit 0 (every `rm -rf`/`rm -f`/`find -delete` site carries same-line `# RM-OK:<id>`, each id unique + justified in appendix; `cp`/`mv` vectors covered behaviorally by AC2.2/2.4/2.9/2.10 — stated explicitly).
- [ ] **AC2.6 (version-floor semantics; Epic premise CORRECTED — no upper-bound mechanism exists: `version_le(dep,current)` at `:1346` is a floor, higher current qualifies MORE entries)**: (a) current=`2.2.0` sandbox → `2.3.0` deprecation entries inert (assert zero deletion-attempt log lines + files intact); (b) current=`2.3.1`, target=`2.43.1` (fixture version, read from `.tad/version.txt` at run time — pin the READ, not the literal) → entries apply ONLY to the 3 listed TAD-owned paths (`.codex/hooks.json`, `.tad/templates/AGENTS.md.template`, `.tad/templates/GEMINI.md.template`) (user files untouched, `diff -r` empty). Both directions pinned with exact versions + log predicates.
- [ ] **AC2.7 (F-34)**: user `.codex/` + `AGENTS.md` present → `upgrade-acceptance.sh` Check 3 PASS; parser adversarial fixtures (reordered sections, `removed_from_this_list` before `files:`, extra versions) never flag.
- [ ] **AC2.8 (F-06)**: forced ERR mid-install (pinned mechanism: exported `cp()` fault shim failing on the Nth call, N chosen past `NEED_ROLLBACK=1` at the first skills-copy call — deterministic, macOS-safe) → every post-NEED_ROLLBACK surface byte-identical after rollback (CLAUDE.md, skills, root files, hooks.json, version.txt); message enumerates coverage; `rm`+`mv` absolutized (discriminating test via sed-extracted `rollback_on_failure` in a subshell under a FOREIGN cwd with absolute BACKUP_PATH → target restored, foreign cwd untouched; pre-fix shape fails it); ENOSPC injection (pinned mechanism: `ulimit -f` in the sandboxed restore subshell; if macOS balks, documented substitution + reviewer sign-off, never silent) → backup preserved + explicit failed-state message.
- [ ] **AC2.9 (F-05)**: pre-existing user `CLAUDE.md.bak` → survives with identical bytes; new backups namespaced+timestamped.
- [ ] **AC2.10 (F-07)**: pre-existing user `TAD-main/` dir → survives identical; extraction provably in temp dir (pre-create sentinel in project root + SENTINELS in sandbox PARENT, all asserted byte-identical after — zero writes outside target); malicious-tar fixture (absolute + `..` + symlink/hardlink members with escaping `->` targets, validated via `tar -tvzf`) → rejected pre-extraction, zero outside writes.
- [ ] **AC2.11 (F-08)**: migrate twice → 2nd run creates 2nd timestamped `_archived` dir via the `backup_existing`-style increment loop (REUSE `:221-227`/`MIGRATE_BACKUP_DIR :2132-2138` pattern, no reinvention), zero overwrites; same-second double-migrate test passes; "determinism" means "both runs succeed, zero overwrites, two dirs". Archive-move failure via `chmod -w` parent → fails loudly with message (scoped `|| true` purge per MQ5).
- [ ] **AC2.12**: `derive-sync-set.sh --dirs` ∩ `--zero-touch` = ∅ + `tad.sh --verify-denylist` PASS (post-change regression anchors).
- [ ] **R1 scope**: `git status` shows ONLY `tad.sh` (DENY_LIST block under mirrored-edit rule: both files or neither; pre-existing drift → escalate-don't-widen, NO authorised remediation in this handoff, AC2.12 tripwire), `.tad/tests/installer-data-safety-fixture.sh`, `.tad/tests/fixtures/` (generated adversarial YAML + sentinels allowlist), `.tad/tests/upgrade-acceptance.sh` UNTOUCHED unless red (AC2.7 direction/parser tests live in the fixture suite — the verifier judging AC2.7 must not be graded by its own edits), `.tad/hooks/lib/release-verify.sh` (ADD `installer-destructive-guard` subcommand + STABLE-contract header note + usage line ONLY); `deprecation.yaml`, migration-engine, Phase-3 files, skills, gates untouched.
- [ ] **R2 red-proof**: red logs for every fixed item archived under `.tad/evidence/acceptance-tests/installer-data-safety/`; each red-log header embeds `git rev-parse HEAD` + `git status --porcelain` (unmodified tree proof) + the failing assertion output (hand-written or wrong-reason failures don't count); green-kept items carry their passing outputs. No red log = no fix = Gate 3 FAIL for that item.

Design-time dry-run (2026-09-03): all commands parse; referenced files/lines verified present (`tad.sh:1474-1518/1523/1933/2091/2159`, Check 3 `:156-214`, `deprecation.yaml` 方案C, no `--source`, no rm-guard check); new paths are CREATE items. Sandbox suite does not exist yet — expected.

## 5. Files Likely Affected

- `tad.sh` (MODIFY: `--source`, extract-to-temp, `.bak` namespacing, rollback absolutization+message, `_archived` migrate guard, `mv` loudness, `# RM-OK` markers)
- `.tad/tests/installer-data-safety-fixture.sh` (CREATE, `--case` per AC)
- `.tad/tests/upgrade-acceptance.sh` (CONDITIONAL-MODIFY: AC2.7 direction/parser tests live in the fixture suite; this verifier file touched ONLY if AC2.7 red-proven against the current tree)
- `.tad/hooks/lib/release-verify.sh` (MODIFY: ADD `installer-destructive-guard` subcommand + STABLE-contract header note + usage line ONLY)
- Explicitly NOT touched: `deprecation.yaml`, Phase-3 artifacts (`sync-v2.8.4.sh` etc.), skills, gates, hooks/* (except the one new subcommand), evidence/archive index, downstream projects (none — sync retired).

## 6. Knowledge Assessment (distill candidate)

"Red-first is load-bearing on installer-risky edits: audit line numbers died within 18 days (v2431 rewrote the region) — ACs must re-prove red on the CURRENT tree, never inherit old reds." Grounded in §3.4 seed vs audit `:1319` citations. Distill decision at Gate 4.
