# Code Review — HANDOFF-20260601-release-v2.21.0 (DRAFT)

**Reviewer:** code-reviewer (blue-team, pre-handoff Alex review)
**Date:** 2026-06-01
**Artifact:** `.tad/active/handoffs/HANDOFF-20260601-release-v2.21.0.md`
**Scope:** Routine minor release (v2.20.0 → v2.21.0), version-string bump SOP + Codex parity gate dogfood.
**Verdict:** **CONDITIONAL PASS** (2 P1, 0 P0 — both P1 are completeness/verifiability gaps, fixable in-handoff)

---

## Method

All findings re-derived from primary sources, not the handoff's self-report:
- Ran the AC1 grep literally; ran the codex parity check on both live editions (exit 0/0); inspected `tad.sh` `TARGET_VERSION` semantics; traced `TARGET_VERSION` git history to validate the "stale-since-v2.20.0" claim; confirmed every CHANGELOG "Fixed/Added" claim against the actual files.

---

## 1. Critical (P0)

**None.** This is a faithful, low-risk routine release. The version bump is mechanical, the parity gate is real and currently green, the CHANGELOG does not overclaim, and the tad.sh straggler fix is correctly diagnosed.

---

## 2. Recommendations (P1)

### P1-1 — Completeness gap: README.md + INSTALLATION_GUIDE.md + tad-help carry version strings the AC1 grep does NOT cover

The handoff's 19-item bump list (§6 Step 1) **is complete** vs the runbook's 18 items + tad.sh — verified item-by-item against the runbook table (rows 1–18). No runbook location was dropped. ✅

**But the AC1 verification command only greps 3 of the ~7 files that hold version strings:**

```
grep -rhoE 'v?2\.(19|20|21)\.[0-9]+' .tad/version.txt .tad/config.yaml tad.sh | sort -u
```

This covers items 1–4 + 19 (version.txt, config.yaml, tad.sh) but **silently omits** README.md (items 5–8), INSTALLATION_GUIDE.md (items 9–12), tad-help/SKILL.md (items 13–14), and the codex editions (items 15–18). A stale `2.20.0` left in README footer or the INSTALLATION_GUIDE upgrade line would **pass AC1 as written** — exactly the class of "stale string in a file not in the checklist" bug the runbook's own "Known past bug" (config.yaml stuck at 2.8.0) warns about.

The runbook's straggler grep (Phase 2, lines 104–109) covers all of these files; Step 2 of the handoff *does* invoke "the runbook's straggler grep" in prose, but **AC1's machine-checkable command is the narrowed 3-file version**, and per the project's own "AC lists become the operational contract" rule, the narrow command is what will actually be verified.

**Fix:** Make AC1's §9.1 command the full runbook straggler-grep file set (add README.md, INSTALLATION_GUIDE.md, `.claude/skills/tad-help/SKILL.md`, both codex editions), OR add a second AC row that runs the runbook straggler grep verbatim and asserts "only 2.21.0 remains." The current 3-file grep is fine as a *tad.sh-drift* spot check but is insufficient as the AC1 completeness gate.

### P1-2 — Stale line numbers in the runbook will mislead Blake (items 17–18)

The runbook (rows 17–18) and the handoff (via "runbook 18 items") point Blake at the codex greeting lines using **stale line numbers**: runbook says alex L855 / blake L632. Actual current lines are **alex L1084 / blake L715** (verified). The editions grew since the runbook was written. Line-number targeting for an edit Blake will perform by hand is a foot-gun (he could edit the wrong line or conclude the anchor is missing).

This is a runbook defect inherited by the handoff, but the handoff is the active contract. **Fix:** in §6 Step 1, replace the L-number anchors for items 17–18 with the literal greeting string (`(TAD vX.Y.Z — Codex Edition)` / `I'm Alex…` / `I'm Blake…`) so Blake greps for content, not line numbers. (Project knowledge already prefers content-anchored over line-anchored edits.) Optionally fold the "runbook line numbers are stale" note into §10.3's existing "runbook should add tad.sh as item 19" follow-up.

---

## 3. Suggestions (P2)

### P2-1 — Focus-area #2 (parity-after-bump) is correctly handled — confirmed empirically
I ran the parity check on the *current* (pre-bump) editions: both exit 0. The gate counts (a) per-must-cover-owner SAFETY-constraint bodies (`forbidden_implementations` 12/6, `anti_rationalization_registry`, `NOT_via_alex_auto`, `honest_partial`), (b) section coverage, (c) capability markers. **None of these signals live in the L3 header comment or the greeting line** — items 15–18 touch only those two regions. So §10.1's reasoning ("comment/greeting region, not a must-cover owner body, so it should stay parity") is **correct, not hand-waving**. The "re-run gate AFTER the bump" requirement (Step 4 / AC3) is the right belt-and-suspenders and should stay. No change needed — calling it out as verified.

### P2-2 — CHANGELOG (§5) is accurate; no overclaim found
Each claim checks out against primary sources:
- `codex-parity-check.sh` + `parity-criterion.md` — both exist at the stated stable path. ✅
- `regen-codex-editions.sh` — exists; described as "human-invoked, atomic regeneration command." This describes the command's **design/contract**, not a claim that it was live-run. The codex `token_revoked` deferral of the live regen does **not** contradict any CHANGELOG sentence — there is no "proven via live run" wording to retract. ✅ (No overclaim.)
- `layer2-audit.sh` now recognizes `spec-compliance` — confirmed in `KNOWN_REVIEWERS_LIST` (line 32). ✅
- tad.sh `TARGET_VERSION` stale at 2.19.1 — confirmed: at the v2.20.0 release commit (218e998) the value was already `2.19.1`. The "missed in v2.20.0" framing is accurate. ✅

Minor wording nit: the "decouple" item is described under the regen bullet ("separate, human-invoked … keeps unreviewed LLM-generated content out of tagged releases") — accurate but the word "decouple" from the review brief never appears verbatim; fine as-is.

### P2-3 — AC1 grep ERE alternation is valid as written
Focus-area #4: `'v?2\.(19|20|21)\.[0-9]+'` under `grep -rhoE` (note the `-E`) — the `(19|20|21)` alternation is valid **ERE**, not BRE (BRE would need `\(\|\)`). Dry-ran it: matches `2.19.1`, `2.20.0`, `v2.20.0` correctly, exit 0. ✅ The command is runnable and correct *for the 3 files it targets* (see P1-1 for the scope concern, which is orthogonal to the regex validity).

### P2-4 — tad.sh TARGET_VERSION bump 2.19.1 → 2.21.0 is SAFE (focus-area #5)
`TARGET_VERSION` is **not** an intentional pin — it is the version the installer *claims to install*, used in: `detect_state()` (`ver == TARGET_VERSION` → "current"), the upgrade banners (`Target: v${TARGET_VERSION}`), and the post-install `echo "$TARGET_VERSION" > .tad/version.txt` writes (lines 538/583/693). If it stays at 2.19.1 while the framework ships 2.21.0, every fresh/upgrade install would write `2.19.1` into downstream `.tad/version.txt` — a real correctness bug. Bumping to 2.21.0 is exactly right; this is the *fix*, not a risk. The prefix globs in `detect_state` (`2.1*`/`2.2*`) are for detecting *old* installs and are unaffected by the TARGET value. **No uncertainty — the bump is safe and necessary.**

### P2-5 — `last_updated` is already 2026-06-01
config.yaml line 5 is already `last_updated: 2026-06-01` (set during the v2.20.0 same-day work). Step 1 item 4 instructs setting it to 2026-06-01 — a no-op today, but harmless and correct to keep in the list for date-correctness on any later cut.

---

## 4. Overall

**CONDITIONAL PASS.**

The handoff is well-scoped, correctly diagnoses the tad.sh straggler, faithfully describes what shipped, and the parity-after-bump subtlety is handled correctly (empirically confirmed: the gate is blind to header/greeting regions, so the bump cannot drop a must-cover owner). No P0.

**Before handoff ships, address the two P1s:**
1. **P1-1** — widen AC1's §9.1 verification command to the full runbook straggler-grep file set (or add a second AC running it verbatim). The current 3-file grep would not catch a stale string in README / INSTALLATION_GUIDE / tad-help / codex editions — the highest-probability failure mode for this exact task.
2. **P1-2** — replace the stale L855/L632 line-number anchors (items 17–18) with content/string anchors; the editions are now at L1084/L715.

Both are 5-minute edits to the handoff text. With them applied, this is a clean PASS for a routine release.
