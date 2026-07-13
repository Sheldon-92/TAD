# Code Review — memory-redirect-capture-layer (TASK-20260712-001)

**Reviewer:** code-reviewer (Blake-tier, second perspective)
**Date:** 2026-07-12
**Scope:** narrow — memory-redirect.sh, deny-list edits (lib + tad.sh), .gitignore, CLAUDE.md, distillation-loop-protocol.md (+ .agents mirror), release-runbook SKILL.md (+ .agents mirror), 8 AC scripts, sensitivity report. Handoff §6/§9.1/§10 conformance.

## VERDICT: PASS

P0 = 0 | P1 = 0 | P2 = 6 (≤10). Pass criteria met.

---

## What was verified live (not paper)

- `bash tad.sh --verify-denylist` → exit 0, "tad.sh inlined DENY_LIST == derive-sync-set.sh (16 entries)". Set-equality drift gate holds after adding `memory` to BOTH lists.
- All 8 automated ACs run green: AC1 (permissions deep-equal, autoMemoryDirectory=absolute path ending `.tad/memory`), AC2 (0 missing-from-target, old dir=36 untouched), AC3 (lib=1 tadsh=1 gate_exit=0 dirs=0), AC4 (deletions=0 steps=7 newsection=1), AC5 (additive both docs), AC6 (both mirrors byte-identical via `cmp`), AC7 (syntax/status/idempotent-enable/revert-roundtrip), AC10 (36 rows, 7 SENSITIVE ignored, 0 user_* tracked, 0 credential hits).
- Blast radius confirmed clean: `release-verify.sh` and `migration-engine.sh` both read `derive-sync-set.sh --zero-touch` as sole authority (`migration-engine.sh:135`, `release-verify.sh:126`) — they inherit `memory` with zero edits, exactly as handoff T2d claims. `harvest-scan.sh`'s `skillify-candidates` reference is a path literal, not a deny-list — correctly untouched.
- `derive-sync-set.sh --dirs` uses `ls -d .tad/*/` (filesystem walk), so `.tad/memory/` (currently untracked on disk) is enumerated but correctly excluded by the deny-list regex → protected regardless of git-tracked status.
- §10 constraints honored: settings.json NOT touched (only settings.local.json gained exactly 1 key via jq merge; permissions byte-identical to the pre-change baseline snapshot); no hooks registered anywhere; `.tad/memory/` written only by the one-time migration cp.
- gitignore isolation genuinely works: `git add -n .tad/memory/` stages exactly the 29 SAFE files and excludes all 7 SENSITIVE (via `user_*` + 6 per-file entries). Direct credential grep over those 29 SAFE files returns zero hits — the property is real, not just the vacuous-set artifact noted in P2-1.

---

## P0 — none

## P1 — none

---

## P2 (6)

**P2-1 — AC10 credential/user_* assertions are vacuous in the current pre-commit state.**
`AC-10-sensitivity-isolation.sh` (credential check + `user_*`-tracked check) both iterate `git ls-files .tad/memory`, which is currently empty (`.tad/memory/` is `?? untracked` — T7 `git add`+commit hasn't run). `xargs grep` on empty stdin runs grep with no file args → 0 hits trivially; the `user_*` count is 0 trivially. The assertions only bite AFTER SAFE files are staged. I re-ran the credential grep directly against the 29 would-be-staged SAFE files and it is genuinely clean, and `git check-ignore` (the other half of AC10) is independent of staging and does hold — so isolation is truly enforced. Fix: in AC10, assert `git ls-files .tad/memory | wc -l -ge 1` (or run against `git add -n` output) so the credential check cannot pass on an empty set.
File: `.tad/evidence/acceptance-tests/TASK-20260712-001/AC-10-sensitivity-isolation.sh:16-18`.

**P2-2 — `--enable` no-settings-file branch writes a permissions-less settings.local.json.**
`memory-redirect.sh:37` else-branch emits `{ "autoMemoryDirectory": ... }` only. Correct for a truly absent file (no data loss — guard is `[ -f ... ]`), but a downstream project that later relies on this file existing gets one with no `permissions` block. Non-defect here (main repo has the file); fix for downstream robustness: seed `{"permissions":{"allow":[]},"autoMemoryDirectory":...}` or document that the else-branch is greenfield-only.
File: `.tad/hooks/lib/memory-redirect.sh:36-38`.

**P2-3 — migration cp copies MEMORY.md into the target, then relies on gitignore to hide it.**
`memory-redirect.sh:40` `cp -n "$OLD_DIR"/*.md` includes `MEMORY.md`. It lands in `.tad/memory/MEMORY.md` (confirmed on disk) and is correctly gitignored, but the native runtime also owns/regenerates MEMORY.md in the target dir — copying the stale one in is harmless-but-redundant and briefly duplicates the ledger. Consider `! -name MEMORY.md` on the copy, matching the distillation scan's own exclusion.
File: `.tad/hooks/lib/memory-redirect.sh:40`.

**P2-4 — AC6 masks a real global-parity failure as "out of scope."**
`AC-06-agents-parity.sh` `cmp`s the two handoff-touched mirrors (byte-identical — good) but then runs `release-verify.sh parity`, captures exit=1, and unconditionally `exit 0` with a "concurrent workstream drift is out of handoff scope" note. The scoped assertion is legitimate, but swallowing a non-zero global-parity exit means a genuine parity regression introduced by THIS change would not fail the AC. Acceptable for this handoff (the two files it touches are proven identical), but the runbook gotcha (line 12) tells operators `--verify-denylist` must be green pre-release without an equivalent parity gate. Recommend surfacing the global exit as a WARN with the specific drifting paths listed, so a reviewer can confirm none are memory-related.
File: `.tad/evidence/acceptance-tests/TASK-20260712-001/AC-06-agents-parity.sh:6-8`.

**P2-5 — AC3 clause B grep pattern is loosely anchored.**
`grep -cx 'memory\|memory"'` inside the `sed`-extracted `TAD_ZERO_TOUCH` block returns 1 (correct today). The alternation `memory"` guards the last-line-with-trailing-quote case, but `-x` (whole-line) plus the `sed` range end `/"$/` means the closing `memory"` line is the block terminator — it works, but is fragile if the block is ever reordered so `memory` is not last. Minor; a `grep -c '^memory"\?$'` would be equally terse and order-independent.
File: `.tad/evidence/acceptance-tests/TASK-20260712-001/AC-03-safety-end-to-end.sh:5`.

**P2-6 — `.gitignore` per-file SENSITIVE entries are unanchored basenames.**
Entries like `.tad/memory/reference_claude-code-source.md` are exact paths (good), but `.tad/memory/user_*` plus 6 explicit files hard-code the current triage. If a future migrated memory is SENSITIVE but doesn't match `user_*` and isn't hand-added, it would be tracked. The runbook gotcha (line 12) does mandate a pre-`*publish` re-scan, which is the compensating control — so this is an accepted residual, not a defect. Flagged only so the human Gate-4 reviewer knows the ignore list is a point-in-time snapshot, consistent with the report's own "Gate 4 human review item" caveat.
File: `.gitignore:63-69`, `.tad/evidence/memory-migration-sensitivity-report.md:11`.

---

## Handoff conformance notes

- AC4 additive check passes with `## Step` count = 7 preserved and exactly 1 new `## Second Capture Source` section; `comm` deletion side = 0. alex/SKILL.md body untouched (circular-trigger principle respected — new section lives in references/, triggered by the already-known `*accept` event, non-circular). Correct.
- Distillation section's READ-ONLY contract (never edit/delete `.tad/memory/`) is consistent with the script's only-write-being-one-time-cp; cursor lives in `.tad/evidence/` not the memory dir. Contract coherent.
- D1 revision ("selective git, not all-in") is correctly flagged in the handoff as a Gate-4 human-confirm item (public-repo sensitivity). The sensitivity report's 7-SENSITIVE / 29-SAFE split and its "verify before *publish" caveat are the right posture for a public repo; final SENSITIVE/SAFE adjudication is a human-domain call per project principles (AI/Human Judgment Domain Awareness) and is correctly deferred to Gate 4, not asserted as machine-final.
- `set -euo pipefail`, consistent quoting of the space-containing `$ROOT`/`$OLD_DIR`/`$TARGET_DIR`, `mktemp`+`mv` atomic-ish jq writes, and idempotent `. + {autoMemoryDirectory}` merge / `del(...)` revert are all sound. `--revert` on absent file exits 0 cleanly; `--enable` with no old dir warns and proceeds redirect-only.
