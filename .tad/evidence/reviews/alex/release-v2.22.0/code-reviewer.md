# Code Review — HANDOFF-20260601-release-v2.22.0 (FIRST self-deriving release)

Reviewer: code-reviewer (blue-team)
Date: 2026-06-01
Scope: handoff draft + release-verify.sh `version` gate + release-runbook SKILL. Live-verified against current pre-bump repo state.
Verdict: **CONDITIONAL PASS** — one real ambiguity (release-runbook historical prose) that, if Blake follows §6 Step 1 literally, produces an incorrect bump or a "framework file still stale" AC1 puzzle. Plus 2 sync-distribution facts the handoff understates.

---

## Live ground truth (what I actually ran)

`git ls-files | xargs grep -l '2\.21\.0'` → 28 tracked files. After excluding zero-touch evidence/archive/decisions/traces/reviews and the doc-history files, the gate (`TAD_RELEASE_GATE=warn release-verify version . 2.22.0 2.21.0`) reports **39 STALE refs / exit 1** across these files:

FRAMEWORK version strings (must bump):
- `.tad/version.txt:1`
- `.tad/config.yaml:1` (comment) + `:3` (version) — note: `last_updated` is NOT a 2.21.0 hit, it's a date; the handoff's "version + comment + last_updated" is fine but only 2 lines actually carry 2.21.0
- `README.md:3, :134, :454`
- `INSTALLATION_GUIDE.md:3, :83, :237, :336`
- `.claude/skills/tad-help/SKILL.md:17, :221`
- `.tad/codex/codex-alex-skill.md:3` (header) + `:1084` (greeting)
- `.tad/codex/codex-blake-skill.md:3` (header) + `:715` (greeting)
- `tad.sh:22` (`TARGET_VERSION="2.21.0"`)

NOT framework version strings (the leave-alones / historical):
- `.tad/sync-registry.yaml` — 14 × `last_synced_version: "2.21.0"` (sync state) ✅ correct leave-alone
- `.tad/scripts/sync-v2.21.0.sh` — 5 refs (historical per-release script) — leave-alone, BUT see P1-1
- `.claude/skills/release-runbook/SKILL.md:310, :313, :316` — **historical prose, NOT covered by the handoff's leave-alone list** — see P0-1

**AC1 verification command — confirmed WORKS.** `... | grep -oE 'STALE: [^:]+' | grep -vE 'sync-registry|sync-v2.21.0.sh|NEXT.md' | sort -u` currently returns exactly the 9 framework files above (pre-bump), exit 0. Post-bump it should be empty. The pipe is correct (see P2-1 for one cosmetic caveat). NEXT.md is tracked but carries ZERO 2.21.0 refs, so the `NEXT.md` exclusion term is a harmless no-op for THIS release.

---

## 1. Critical (P0)

### P0-1 — `release-runbook/SKILL.md` 2.21.0 refs are HISTORICAL PROSE, but §6 Step 1 tells Blake to bump them → wrong bump OR a phantom AC1 failure

§6 Step 1 (line 72) instructs: bump `.claude/skills/release-runbook/SKILL.md` **"(any vX.Y.Z self-refs)"**. The actual three 2.21.0 hits in that file are:

```
310: ### Critical gotcha: tad.sh historically missed directories — FIXED in 2.21.0+ (self-deriving)
313: By 2.21.0 it had silently drifted to omit `codex cross-model context tests scripts capability-packs` ...
316: **2.21.0 fix (Epic self-deriving-release-sync P2):** ...
```

These are NOT the runbook's own version self-reference — they are a **historical gotcha narrative** describing the v2.21.0 self-deriving fix. Bumping them to "2.22.0" would FALSIFY the record (the fix shipped in 2.21.0, not 2.22.0). This is the exact "AC Self-Leak from Removal Rationale" / historical-prose class the project knows well.

The trap: AC1's command does NOT exclude release-runbook. So Blake faces a forced error:
- If Blake bumps them → CHANGELOG/history lie (the 2.21.0 fix is now mislabeled 2.22.0), and the SKILL's `release-runbook` self-narrative is corrupted.
- If Blake correctly LEAVES them → AC1's pipe still lists `release-runbook/SKILL.md` as a "framework file still at 2.21.0" → AC1 reads as FAIL even though the right thing was done.

**Required fix (handoff edit, Alex):** Recognize release-runbook 310/313/316 as a THIRD intentional leave-alone (historical prose). Two coherent options:
- (a) Add `release-runbook` to AC1's exclusion alternation: `grep -vE 'sync-registry|sync-v2.21.0.sh|NEXT.md|release-runbook'`, and change §6 Step 1 line 72 from "any vX.Y.Z self-refs" to "NONE — the only 2.21.0 refs are historical gotcha prose; LEAVE them" (the runbook has no live version self-string today). Also add a §2 / §10.2 bullet documenting it.
- (b) Keep AC1 as-is but require Blake to confirm the 3 release-runbook hits are the historical-prose leave-alones in the COMPLETION (so the residual AC1 line is explained, not a miss).

Option (a) is cleaner — it makes AC1 truly "empty == done" without operator interpretation. As written, the handoff's own AC1 "Expected: empty" is **unachievable** without bumping historical prose, which is wrong.

> The handoff's §6 Step 1 actually contains its own contradiction with §2's prefer-false-positive philosophy: it both (i) names only 2 leave-alones and (ii) tells Blake to bump release-runbook self-refs that don't exist as live strings — only historical ones do.

---

## 2. Recommendations (P1)

### P1-1 — `sync-v2.21.0.sh` lives in `.tad/scripts/`, which is a SYNCED framework dir (not zero-touch) → it ships to all 14 downstream projects

I confirmed `derive-sync-set.sh --zero-touch` returns: `active archive decisions evidence github-registry pair-testing project-knowledge research-notebooks`. **`scripts` is NOT in that list** — so `.tad/scripts/` is a full-refresh synced framework dir. That means `sync-v2.21.0.sh` (a one-off historical per-release script) gets `cp -R`'d into every downstream project on the next `*sync`, and its internal `2.21.0` refs will then trip the `structural`/`version` gates in those targets too.

The handoff (§2) already flags the *right* remedy as optional: "optionally move it to `.tad/evidence/releases/` which is zero-touch ... out of scope if risky." Given that (a) the runbook Phase 5 explicitly mandates per-release scripts go to `.tad/evidence/releases/`, and (b) leaving it in `scripts/` means distributing a stale-versioned dead script to 14 projects, I recommend **promoting this from "optional / out of scope" to a P1 action in THIS release**: `git mv .tad/scripts/sync-v2.21.0.sh .tad/evidence/releases/`. It is low-risk (the script is not referenced by any live code path — it was a one-shot) and it removes a recurring future-gate false-positive AND a distribution-of-cruft problem. At minimum, the handoff should state the consequence ("it will be synced to downstream") so the "leave it" decision is informed, not silent.

### P1-2 — Codex greeting line numbers in the runbook table are stale (855/632 vs actual 1084/715) — handoff handles it, but make the COMPLETION assert content-grep was used

§6 Step 1 correctly says "grep by content, NOT line number" and §10.3 reinforces it. Good — because the runbook table (lines 126–127) says greetings are at 855/632, but they're actually at **1084 (alex)** and **715 (blake)**. The handoff's guidance is right; just ensure AC5/COMPLETION records that the bump was located by `grep -n 'TAD v2.21.0'`, so a future reader doesn't trust the stale table. No handoff change strictly required; this is a "the guidance is load-bearing, confirm it was followed" note.

### P1-3 — AC1 "Verified (step1d)" cell and the dry-run log under-report the count and don't mention the release-runbook ambiguity

§9.1 AC1 row says "pre-impl: currently lists framework files (the bump targets)"; the dry-run log says "it reports 39 framework refs = the bump targets." That 39 is the TOTAL stale count (incl. 14 sync-registry + 5 sync-v2.21.0.sh + 3 release-runbook historical), NOT 39 framework refs. The actual framework-version-string count is ~17 lines across 9 files. Mislabeling all 39 as "bump targets" is exactly the kind of imprecise dry-run that the project's "AC Verification Drift" lessons warn against — and it masks the release-runbook-prose question (P0-1). Tighten the dry-run log to the 9-file / ~17-line framework set and call out the 3 non-bumpable classes.

---

## 3. Suggestions (P2)

### P2-1 — AC1 `grep -oE 'STALE: [^:]+'` is correct but truncates at the first `:` — fine for file-level dedup, just know it drops line numbers

`STALE: [^:]+` captures `STALE: <filepath>` and stops at the first colon (the `:line:` separator). Since no framework file path contains a colon, this cleanly yields one line per file, and `sort -u` dedups multi-hit files (README, config, INSTALLATION_GUIDE, codex each hit multiple times → collapse to one). This is intended behavior and works. Only caveat: it reports files, not the specific stale lines — fine for the "is any framework file still stale?" question AC1 asks. No change needed.

### P2-2 — Shadow-gate invocation is correct; exit 1 is EXPECTED and not a failure

I verified `TAD_RELEASE_GATE=warn release-verify version . 2.22.0 2.21.0` returns **exit 1** (drift) pre-bump, and even post-bump it will return exit 1 as long as the 2 (really 3, per P0-1) leave-alones survive. That is BY DESIGN: the script always exits 1 on any surviving stale ref. The warn-mode downgrade lives in the CONSUMER (alex/SKILL.md publish gate-step lines 5266–5282), which branches: exit 1 + minor + `TAD_RELEASE_GATE=warn` → WARN + proceed; exit 2 → always hard-block. So the script returning exit 1 does NOT stop the release in shadow mode — the SKILL gate-step lets it proceed. The handoff's Step 2 "paste the full output ... exit:$?" is the right capture. Suggestion: the handoff could note explicitly that "exit 1 is expected post-bump (the leave-alones), NOT a failure — only a FRAMEWORK file in the output is a real miss," so Blake doesn't misread the non-zero exit. §6 Step 2 line 81 implies this but doesn't say "exit 1 is normal here."

### P2-3 — CHANGELOG (§5) accuracy — solid, one minor scope check

The §5 CHANGELOG is accurate and not overclaiming: it correctly describes derive-sync-set.sh (deny-list SoT), release-verify.sh (structural + version, exit 0/1/2, shadow mode), the wired publish/sync gate, and tad.sh self-derivation + `--verify-denylist`. The "Notes" line ("first release that USES the new mechanism") is true. One nit: the bullet says the gate is "wired into `*publish` (version) + `*sync` (structural)" — confirmed accurate against alex/SKILL.md (5266 version on publish, 5468 structural on sync). No overclaim. The "`.tad/codex/` was frozen for a month; `tad.sh` stuck at an old version" examples are consistent with the runbook's documented gotchas. PASS on §5.

### P2-4 — AC3 `tad.sh --verify-denylist` not re-run live by me (out of declared reads), but the handoff claims pre-impl exit 0 / "12 entries"

The dry-run log asserts AC3 passed (exit 0, 12 entries). I did not re-run it (it wasn't in my read scope and isn't a 2.21.0-bump concern). Flagging only that Blake's COMPLETION must show the ACTUAL post-bump exit (bumping `tad.sh:22` TARGET_VERSION does not touch the inlined DENY_LIST, so `--verify-denylist` should remain 0 — but verify, don't assume).

---

## 4. Overall: CONDITIONAL PASS

The core mechanism is sound and the handoff is mostly well-formed: the grep-derived bump set matches reality, the 2 named leave-alones (sync-registry, sync-v2.21.0.sh) are correctly classified, the AC1 pipe works, and the shadow-mode gate invocation + exit semantics are right (exit 1 is expected; the SKILL consumer downgrades it).

**Blocking before handoff ships (P0-1):** the release-runbook SKILL's 3 historical-prose 2.21.0 refs are a THIRD de-facto leave-alone that §6 Step 1 mislabels as bumpable "self-refs" and that AC1's exclusion list omits. As written, AC1's "Expected: empty" is unachievable without falsifying history. Fix by adding `release-runbook` to the AC1 exclusion + correcting §6 Step 1 to "LEAVE (historical prose)".

**Strongly recommended (P1-1):** `git mv .tad/scripts/sync-v2.21.0.sh .tad/evidence/releases/` this release — `scripts/` is a synced framework dir, so leaving it ships a stale one-off script to 14 downstream projects and seeds future gate false-positives. If kept, document the sync consequence so the decision is informed.

No security issues. No data-loss risk (no push/tag in scope). The CHANGELOG is accurate with no overclaim.
