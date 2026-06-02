# Phase 1 Implementation Review — Self-Deriving Release/Sync (backend-architect, blue-team)

- **Commit:** 16dbe1a
- **Reviewer:** backend-architect (architecture / structure-resilience focus)
- **Scope:** derive-sync-set.sh, release-verify.sh, COMPLETION, HANDOFF §4.1, SKILL diffs (alex + release-runbook). No edits made.
- **Method:** read all required files + RAN the gates (omission test, exclusion test, version-discrimination test, embeddability pipeline, real-world OLD=2.19.0 dry run) to distinguish proof from theater.

---

## Verdict up front: CONDITIONAL PASS

The structure-resilience thesis is genuinely achieved — DENY_LIST is the SOLE hardcoded list, no pinned count, no duplicated deny-list, no `== capability-packs` special-case in consumers. The dogfood is NOT theater (I re-ran the omission and version-discrimination tests independently and they exit 1 / discriminate correctly). The blocker on a clean PASS is a **forward-risk false-positive load** in the version gate's grep scope (P1) that the shadow-mode note mitigates but does not eliminate.

---

## 1. Critical (P0)

**None.** No structure-resilience regression, no reintroduced hardcoded list, no source-consistency hole, no theater in the load-bearing dogfood.

Each FOCUS AREA confirmed by execution:

- **F1 (structure-resilience / sole hardcoded list):** PASS. DENY_LIST (`ZERO_TOUCH` 8 + `TRANSIENT` 4 = 12) lives only in `derive-sync-set.sh`. Verified the cat-C marker `spike-v3` appears in exactly one file (the lib). No `wc -l == N`, no `-eq 20`, no pinned dir count anywhere in either lib. The deny-list header (lines 5-8, 42-45) correctly explains WHY deny-not-allow is the safe direction (bias-to-sync: a new framework dir auto-included with zero edits; the escape hatch is adding to the ONE constant). `codex` literal count in the lib = 0 (SC2) yet `codex` IS in the derived `--dirs` output — the anti-omission property the whole Epic exists for.
- **F2 (three-gate composition):** PASS, implemented as designed. publish = step3b (codex parity) + step3c (version zero-stale) + scan-packs regen; structural is sync-only. The "no publish-time source-consistency hole" rationale is stated verbatim in both the lib CONTRACT header and runbook (matches HANDOFF §4.1 / cr-P0-2 resolution). step3c is correctly inserted after step3b, before step4; sync `d2.` correctly inserted after `d.` (copy), before `e.` (registry update) — i.e. the structural gate runs AFTER the verbatim `cp -R`, which is the only point byte-identity is the right test.
- **F5 (dogfood sufficiency):** PASS — genuinely runs, not asserts. I independently reproduced:
  - **Omission test:** built a target missing `.tad/tests`, ran `structural` → `exit 1`, output NAMED `.tad/tests DIFF: ... No such file or directory`. Real gate, real failure.
  - **Version discrimination:** planted a CHANGELOG history-table row (`| **v9.9.9** | ... |`), a README prose line, a `scripts/foo.sh` assignment, and a zero-touch `active/note.md`. Result: scripts assignment + README prose REPORTED, CHANGELOG row IGNORED, `active/` excluded → `exit 1`, 2 survivors. Location-precision (file-allowlist AND on-line table-row regex) is real, not shape-only.
  - **Structural self==self:** `exit 0` (SC3 confirmed; an earlier `exit 1` I saw was a shell-chaining artifact of my own command, not the gate).

---

## 2. Recommendations (P1)

**P1-1 — Version gate scans gitignored / ephemeral trees → large phantom false-positive load on first real release.**
Ran the REAL scenario: `release-verify.sh version "$PWD" 2.21.0 2.19.0` → **62 "stale" survivors**. Breakdown:
- ~40 hits are inside `.claude/worktrees/agent-*/` — these are **gitignored ephemeral worktree copies** (confirmed `git check-ignore .claude/worktrees` → ignored; 5 worktree dirs present). The grep walks the raw filesystem; `--exclude-dir` only covers `.git` + the 8 zero-touch basenames, NOT `.claude/worktrees`. Any machine that has run parallel/worktree work will get dozens of phantom hits.
- The rest are **legitimate historical prose**: `NEXT.md` ("Release v2.19.0 PUBLISHED — DONE 2026-05-30"), `INSTALLATION_GUIDE.md` prose, `README.md` non-table lines, `PROJECT_CONTEXT.md`. None of these are bumpable stragglers; they are intentional history. NEXT.md isn't even in the 3-file allow-list.

This is exactly why the gate's hard-block on minor+ would, on a real first cutover WITHOUT shadow mode, BLOCK a legitimate release with ~62 mostly-noise survivors. The `TAD_RELEASE_GATE=warn` note (P1-2 below) is the saving grace — but the SCOPE design has a real gap. Recommend (P2-scope or a quick P1 follow-up): (a) add `--exclude-dir` for gitignored ephemeral trees (`.claude/worktrees`, `node_modules`, etc.) or scope the grep to `git ls-files` instead of raw FS walk; (b) broaden the historical-exclusion contract beyond table-rows — e.g. add `NEXT.md` to the allow-list and/or recognize "DONE/PUBLISHED vX.Y.Z" changelog-prose lines, OR document that the operator must eyeball-triage prose survivors. As-is, the gate's signal-to-noise on a real release is poor enough that an operator could rubber-stamp through real stragglers buried in 60 phantoms.

**P1-2 — Shadow mode (`TAD_RELEASE_GATE=warn`) is present and correct, but is PURELY agent-honored, not mechanical.**
Confirmed `TAD_RELEASE_GATE` is referenced 0× in both libs and only in SKILL prose (alex 2×, runbook). This is consistent with the single-user-CLI soft-reminder model (architecture.md 2026-04-15), so it's a deliberate design choice — flagging it as a residual: the shadow downgrade depends on the agent reading the env var and branching, not on the lib. Given P1-1's 62-survivor reality, the shadow-mode-first-cutover instruction is not optional polish — it is the de-facto required path for the first real release. Recommend the runbook elevate it from a "note" to a MUST for the first minor+ cutover (it currently reads as advisory). The instruction to UNSET after one cutover is correct (ship-detector-in-shadow-then-gate).

**P1-3 — Embeddability contract (NFR4/P2) is documented but unverified against the real consumer.**
The lib header (lines 28-35) clearly marks the EMBEDDABLE-VERBATIM block (DENY_LIST constant + `ls -d | sed | grep -vxE | sort` pipeline) vs REPO-CONTEXT-ONLY (`--report` sibling-dir classification). I confirmed the inline pipeline works standalone (ran the `grep -vxE` derivation with a hand-pasted DENY_RE → correct output). That's good. But: P2 (`tad.sh` on a curl-fresh machine) will INLINE a second copy of the DENY_LIST, and there is no test/assertion that the inlined copy stays in sync with the lib's constant. The header says "never a 2nd copy" but the embeddable path is by definition a 2nd copy. Recommend P2 add a drift check (e.g. a release-time assertion that `tad.sh`'s inlined DENY_RE == the lib's derived DENY_RE) so the embeddable copy can't silently diverge — otherwise the Epic's own "no stale list" thesis is reintroduced at the installer layer.

---

## 3. Suggestions (P2)

- **S1 — COMPLETION SC1 footnote honesty is good, but the SC1 reference command shipped fragile.** §5 note ¹ correctly documents that the handoff's SC1 reference recompute (`s,.tad/,,`) is fragile on relative paths and that the LIB is robust. The lib's own normalization (`s|.*/\.tad/||;s|/$||`) is correct. This is a handoff-spec bug, not an impl bug — fine to leave, but future re-verification should use `--dirs` itself or `ls -d ./.tad/*/` as the canonical reference (as Blake recommends in §8). No action needed on the impl.
- **S2 — `head -4` on diff output truncates large drifts.** `structural` prints `head -4` of each dir's `diff -rq`. For a dir with many differing files only the first 4 are named; the operator sees "DIFF" + count but not the full list. Acceptable for a smoke-alarm gate (the count + first-4 + exit 1 is enough to STOP), but note it if anyone expects the gate to be the full diff report.
- **S3 — `--report` is emitted unconditionally (AC8 verified: `grep -c 'derive-sync-set.sh --report'` = 2, once per protocol gate, before the exit branch).** Good — a newly-included dir is auditable every run. Suggest the report also be tee'd to `.tad/evidence/releases/` at release time so the audited synced-set is captured per release (currently it goes to stdout only; the per-release script destination is documented but the report itself isn't persisted).
- **S4 — Forward worst-failure mode (F6):** the worst case is a real straggler (e.g. `tad.sh`/`config.yaml` live-assignment — the exact historical disease) being buried among the 62 phantom survivors and rubber-stamped through under shadow mode. Guarded partially (the gate DOES name it file:line and DOES re-report on re-run), but the noise floor undermines the signal. P1-1's scope fix is the real mitigation; until then the operator MUST grep the survivor list for non-prose / non-worktree paths specifically. Recommend the runbook add: "on the first cutover, filter survivors to exclude `.claude/worktrees/` and known-prose files before triage."

---

## 4. Overall: CONDITIONAL PASS

The implementation faithfully delivers the v2-reviewed design and genuinely achieves structure-resilience — DENY_LIST is the sole hardcoded datum with a correct why-deny header, the three-gate composition matches §4.1 with no source-consistency hole, and the load-bearing dogfood is real (independently re-run: omission → exit 1 + named path; version → discriminates history-row vs straggler; structural self==self → exit 0). No P0.

The CONDITIONAL is for the **version gate's raw-filesystem grep scope (P1-1)**: a real `OLD=2.19.0` dry run yields 62 survivors dominated by gitignored `.claude/worktrees/` copies and legitimate historical prose (NEXT.md/INSTALL/README), which would hard-block a real minor release on noise. The `TAD_RELEASE_GATE=warn` shadow mode (P1-2) is present, correct, and is effectively the required first-cutover path — so the design degrades safely rather than catastrophically. Recommend, before the first real hard-gated release: scope the version grep to tracked files (or exclude `.claude/worktrees`) and broaden the historical-prose exclusion, and (P2) add a drift assertion for the embeddable DENY_LIST copy so the no-stale-list thesis isn't reintroduced in `tad.sh`.
