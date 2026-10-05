# Gate 4 Acceptance — TAD v2.43.1 backup repair + `/tad-update`

**Handoff**: `HANDOFF-20260902-tad-update-v2431.md` (archived)
**Completion**: `COMPLETION-20260902-tad-update-v2431.md` (archived)
**Task ID**: `TASK-20260902-TAD-UPDATE-V2431`
**Gate-4 reviewer**: Alex (Solution Lead) | **Date**: 2026-09-03 | **Mode**: YOLO (human pre-authorized; gates NOT skipped)
**Verdict**: ✅ **PASS** (implementation accepted) — publication **BLOCKED** (see §5)

## 1. Independent recompute (Alex, this host, macOS)

| Case (AC) | Result | Note |
|---|---|---|
| backup (AC1–2) | 6/6 PASS | dangling-symlink `cp -r` negative control reproduced on BSD cp |
| states (AC3) | 13/13 PASS | |
| consent (AC4) | 9/9 PASS | no-TTY decline/no-mutation paths |
| download-safety (AC5) | 16/16 PASS | fail-closed paths |
| opencode-preservation (AC8) | 10/10 PASS | slow (~3–8 min); earlier stall was runtime, not hang |
| full-upgrade (AC9) | 8/8 PASS | disposable 2.43.0→2.43.1 project |
| release-gates (AC10) | **5/7 FAIL → 7/7 PASS after §2 fix** | Gate-4 finding, bounded fix, re-verified on accepted SHA |
| remote-release (AC14) | SKIP by design | post-publication only |

Total: **69/69 assertions PASS** on accepted commit `8b8c7877` (matches Blake's 69/69 claim after fix).

## 2. Gate-4 finding + bounded fix (no gate weakened, no product touched)

- **Finding**: AC10 red on recompute — `release-verify.sh version` flagged `.tad/tests/tad-update-fixture.sh:33` (`OLD_VERSION` default literal `2.43.0`). The gate is correct (fails toward false-positive by design); Blake's Gate-3 7/7 evidence was stale (fixture edited after last green run). E2 lesson recorded.
- **Fix** (`8b8c7877`, test-tooling only, 19+/1-): OLD default derived from `.tad/migrations/*-to-<current>.yaml` (single source of truth, exactly-one-match guard, `--old-version` override intact). `release-verify.sh`, product files, other tests untouched. Zero `2.43.0` literals in fixture (grep verified).
- **Re-verified by Alex**: release-gates 7/7 + full-upgrade 8/8 + direct version-gate exit 0, all on `8b8c7877`.

## 3. Business acceptance (requirement alignment)

- macOS dangling-symlink backup repair: shipped (`cp -R` + unique destinations + pre-mutation backups). ✅
- One shared updater for Claude Code / Codex / updater-only OpenCode: shipped, single helper, pinned contract. ✅
- Boundary kept: OpenCode is updater-only (no full TAD platform); no push/tag/release happened pre-Gate-4. ✅
- Layer 2: spec-compliance / code-reviewer / test-runner reports on disk, all PASS, 0 P0. Security/performance N/A per protocol triggers. ✅
- Knowledge Assessment: 4 shell-portability patterns landed (`6ebb5457`, docs-only delta verified). ✅
- Scope: `ef8734f0` (30 files, declared) + `6ebb5457` (KA docs) + `8b8c7877` (Gate-4 fixture fix). `visual-code-bridge.md` traced to human docs commit `2af31d1e` (pre-existing base, not Blake scope creep). Version-banner bumps declared. ✅

## 4. Accepted SHA

**`8b8c7877`** (local only, NOT pushed). AC14 publication MUST use exactly this SHA if/when authorized.

## 5. Publication: ❌ BLOCKED (not overridden by blanket YOLO)

- `EPIC-20260816-framework-health-repair.md:63,79` — Phase 2 is the Epic's only unclosed part and the ban reads verbatim: Phase 2 未全部收口前禁止 `*publish`/`*sync`. Still active 2026-09-03.
- push/tag/GitHub-Release are irreversible outward writes; TAD requires the override to NAME this ban. "YOLO, no instructions needed" does not name it — SAFETY needs exact scope, not a blanket prompt.
- **Unblock (exactly one of)**: (a) human writes "override framework-health publish ban for v2.43.1 @ 8b8c7877"; then run AC14 remote-release case + publish exact SHA + verify remotes; (b) framework-health Phase 2 closes, ban lifts, re-confirm.

## 6. Knowledge Assessment (Gate-4 distill decision)

- Candidate from this track: "Gate-3 evidence goes stale when the fixture is edited after the last green run — acceptance tooling needs a re-run-on-dirty rule." Verdict: **journal only** (one-off process note for this release; variabilize test fails — no reusable mechanism proposed). No new pattern entry.
- Prior 4 patterns (Blake KA) stand as documented.
