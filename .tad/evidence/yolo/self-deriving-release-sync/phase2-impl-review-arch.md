# Phase 2 Implementation Review — backend-architect (blue-team)

**Subject:** self-deriving-release-sync Epic Phase 2 — tad.sh installer (commits f053f50 + de952b5)
**Reviewer role:** backend-architect (architecture / consistency / disease-recurrence)
**Date:** 2026-06-01
**Scope:** tad.sh (copy_framework_files, derive_target_version, verify_install_complete, verify_denylist_drift, --verify-denylist), COMPLETION P2, EPIC P2 detail block + carry-forwards, derive-sync-set.sh. No edits made.

---

## Verdict: CONDITIONAL PASS

P2 is architecturally sound on the dimension it set out to fix (the **directory** copy-set + version literal + post-install dir self-check + lib/inline drift guard). The drift-check is real, wired into the runbook pre-flight as a HARD BLOCK, and verified live (exit 0, 12 entries match). The dotfile bug is genuinely fixed and the self-check caught it — that is the system working as designed.

BUT P2 does **not fully close the omission disease**: a second hardcoded allow-list survives at the **top-level file** copy (`*.yaml *.md *.txt` extension glob), and it is silently dropping a real git-tracked framework file (`.tad/portable-extract.sh`) — invisible to BOTH the installer self-check AND P1's structural gate, because both verify DIRS only, never top-level files. This is the exact disease class the Epic exists to kill, merely relocated from "dir allow-list" to "file-extension allow-list". One P1 below; not a release-blocker for the committed work but the Epic's "self-sustaining standing guarantee" claim is **not yet true** until it is addressed or explicitly accepted.

---

## 1. Critical (P0)

**None.** No correctness defect that breaks the committed code path. The drift-check works, the deny-list copies are in sync, the dotfile fix is real, version-from-source works with sane fallback.

---

## 2. Recommendations (P1)

### P1-1 — The omission disease is NOT closed: a 2nd hardcoded allow-list at the top-level FILE copy silently drops `portable-extract.sh`

`copy_framework_files()` line 242 copies top-level `.tad/` files via a **hardcoded extension allow-list**:
```
for f in "$src"/.tad/*.yaml "$src"/.tad/*.md "$src"/.tad/*.txt; do
```
This is structurally the same disease as the old 14-dir allow-list — it enumerates by a fixed pattern rather than deriving "everything except deny". Verified consequence:

- `.tad/portable-extract.sh` is **git-tracked** (`git ls-files` confirms) and **referenced in the release-runbook SKILL** → it is a real framework file.
- Its extension `.sh` is NOT in `{yaml, md, txt}` → **the installer never copies it to a fresh machine.**
- `verify_install_complete()` checks **dirs only** (it iterates `derive_framework_dirs`, asserts each dir non-empty) → it has **no awareness of top-level files** → the omission is **silent** (self-check reports 20/20 PASS while a framework file is missing).
- P1's `release-verify.sh structural` ALSO diffs only `--dirs` + `.claude/skills` (release-verify.sh:122-156) → the **release gate is equally blind** to top-level file omissions.

So the precise answer to FOCUS AREA 5 ("is there any remaining hardcoded list that can still go stale?"): **YES — the top-level file-extension allow-list in tad.sh:242, and there is no verification primitive (installer self-check or P1 gate) that would catch a top-level file omission.** A future `.tad/foo.sh` or `.tad/bar.json` framework file would be dropped exactly the way `codex/` used to be dropped.

**Recommended fix (one of):**
- (a) Derive the top-level file set the same way: copy every top-level regular file under `.tad/` MINUS `TAD_TOP_DENY` (and any other main-only files), instead of the extension glob. Mirror this in `derive-sync-set.sh` so there's ONE rule. This is the on-thesis fix.
- (b) At minimum, add `.sh` to the glob AND extend `verify_install_complete` + `release-verify.sh structural` to diff the top-level file set, so a future omission is at least *caught* even if not auto-included.
- If the team decides top-level files are deliberately curated, that decision must be **recorded** (a `TAD_TOP_KEEP` allow-list with a comment "intentionally NOT derived") so it's not silent — but bias-to-sync (deny-list) is more consistent with the Epic thesis.

### P1-2 — `verify_install_complete` is a DIR-completeness check, not a structural diff; it cannot detect partial-dir or stale-content omissions

AC3 says "presence/diff of derived paths". The implementation is presence + **non-empty** only (line 321: `[ -z "$(ls -A …)" ]`). It proves *a* file landed in each dir, not that the dir's **contents match source**. A dir that copied 1 of 50 files passes. The dotfile bug was caught only because that dir went fully empty; a *partial* copy (e.g. `cp -R` interrupted, or a glob that drops some-but-not-all) would pass silently. The installer cannot reuse P1's `diff -rq` structural primitive on a fresh machine (no lib to source — same constraint that forced the inline deny-list), but it CAN compare against the freshly-downloaded `$TAD_SRC` tree which IS present at install time. Recommend upgrading the self-check to `diff -rq "$src/.tad/$dir" ".tad/$dir"` for the non-zero-touch dirs (the source is local during install — this is cheap and closes partial-copy gaps). Lower priority than P1-1 because a full clean `cp -R` is reliable in practice.

### P1-3 — Carry-forward #2 (`TAD_RELEASE_GATE=warn` shadow on first real release) is acknowledged but unverifiable from P2

The COMPLETION correctly notes (Notes/Carry-forwards bullet 3) that the warn-shadow gate is in *publish/*sync (P1 surface), not the installer, so it's out of P2 scope. Agreed — but this means the Epic's "done 2/2" status does **not** discharge carry-forward #2; the **first real release that touches tad.sh must still run `bash tad.sh --verify-denylist` AND use the warn shadow** for the P1 version/structural gates. This is correctly placed in the runbook Phase 1 pre-flight (SKILL line 59, HARD BLOCK conditional). Flagging so the Epic isn't mistaken for "all carry-forwards closed" — #2 is *deferred to first-release*, not *done*.

---

## 3. Suggestions (P2)

### S-1 — `verify_denylist_drift` reconstructs the lib's set via a brittle awk heredoc-extractor instead of sourcing
Lines 199-214: the function greps `ZERO_TOUCH="`/`TRANSIENT="` blocks out of the lib with awk rather than sourcing it. The dead `( set +euo … true )` subshell (lines 201-206) is a no-op vestige and should be deleted for clarity. The awk approach is **fragile to lib formatting** (it hard-codes the two variable names and the quote style); if the lib ever renames `ZERO_TOUCH`/`TRANSIENT` or switches quoting, the drift-check silently extracts an empty/partial set and could report false-sync. Since `--verify-denylist` is repo-only (the lib IS present), it could safely `source` the lib in a subshell and print `"$ZERO_TOUCH"$'\n'"$TRANSIENT"` — coupling to the lib's *interface* (variable names are already coupled) rather than its *byte layout*. Minor: the current code is verified working today; this is hardening against lib-format drift. Note the mild irony — a drift-check that is itself sensitive to a different kind of drift.

### S-2 — The file-count exclusion list (lines 286-288) is a 4th hardcoded copy of (part of) the zero-touch set
`find .tad … -not -path ".tad/active/*" -not -path ".tad/archive/*" -not -path ".tad/evidence/*" -not -path ".tad/project-knowledge/*" -not -path ".tad/pair-testing/*"` hardcodes **5 of the 8** zero-touch dirs (omits `decisions`, `github-registry`, `research-notebooks`). This is cosmetic only — it affects the **displayed file count** (line 289), not what gets copied or verified — so it cannot cause an install defect. But it IS a divergent partial copy of the zero-touch list and will under-count drift over time. Low value to fix; if touched, derive it from `TAD_ZERO_TOUCH`.

### S-3 — `detect_state` banner compares against the stale literal (acknowledged)
The COMPLETION's "detect_state pre-derivation" note is correct and the reasoning (post-download derived version is authoritative for the actual write) is sound. No action — just confirming the reviewer agrees the install-decision is robust to the stale literal.

---

## FOCUS-AREA ANSWERS (explicit)

**1. Does P2 close the disease at the installer, or relocate it? Is --verify-denylist a sufficient guarantee, and is it wired in (not orphan)?**
Partially closes it. For the **directory** copy-set: YES, genuinely closed — deny-list derived, `codex`+4 others auto-included, drift-check guards the inline/lib pair. The drift-check is **NOT an orphan**: it is wired into release-runbook Phase 1 pre-flight as a conditional HARD BLOCK (`SKILL.md:59`) firing whenever a release touches `tad.sh` or `derive-sync-set.sh`, and documented in the dedicated "Release-time drift check (MANDATORY)" section (`SKILL.md:334-344`). Verified live: `bash tad.sh --verify-denylist` → exit 0, "12 entries", and the flipped-temp negative case fails exit 1 naming both sides. For the **top-level file** copy-set: NOT closed — disease relocated to the extension allow-list (P1-1). So `--verify-denylist` is a sufficient guarantee *for the dir deny-list it covers*, but it does not cover the surviving file-extension list, which has no drift/omission guard at all.

**2. Did P2 close ALL three P1 carry-forwards? Anything dropped?**
The P2 carry-forwards were three: (1) tad.sh embed + drift check — **DONE** (inline `TAD_DENY_LIST` + `--verify-denylist` + runbook wiring). (2) version-from-source — **DONE** (`derive_target_version`, unit-tested 9.9.9 ↔ 2.21.0 fallback). (3) post-install self-check — **DONE for dirs**, but **partial** (presence-only, dirs-only; see P1-2, and it does NOT cover top-level files, see P1-1). The OTHER carry-forwards in the EPIC "After P1" block — `TAD_RELEASE_GATE=warn` first-release shadow (#2) and version-scope NEXT.md over-report (#3) — are correctly out of P2 scope (they live in P1's *publish/*sync), but #2 is **deferred, not discharged** (P1-3). Nothing silently dropped; one item (post-install self-check) shipped weaker than the AC wording ("presence/diff") implies.

**3. Is the architecture consistent (P1 mirror of P2), or are there now THREE diverging deny-list copies?**
The deny-list itself exists in exactly **2** copies (lib + tad.sh inline), and they are kept in lockstep by `--verify-denylist` — that is the intended "one is a verified mirror of the other" design and it holds. `verify_install_complete` does NOT introduce a 3rd deny-list copy — it **reuses** `derive_framework_dirs` (the same inline derivation), so it's a consumer, not a copy. Good. HOWEVER there ARE two *additional* partial restatements of the **zero-touch subset** (not the full deny-list): the `find -not -path` count exclusion (5 of 8 dirs, S-2) and the top-level `TAD_TOP_DENY` single-file rule. Neither is load-bearing for copy/verify correctness, but the `find` one is a divergent partial that will rot. Net: the deny-list is consistently 2-copy-verified; the zero-touch concept has minor uncontrolled partial restatements.

**4. Does the dotfile bug reveal a deeper class? Fully fixed by cp -R src/.?**
The dir-content dotfile bug is **fully fixed** by `cp -R "$src/.tad/$dir/." ".tad/$dir/"` (line 265) and the self-check proved it. I scanned all 20 derived framework dirs: `context` is the **only** dotfile-only dir, and it now copies. The `.claude/skills/*` copy (line 273) still uses a bare `cp -r src/*` glob — today no skill dir is dotfile-only at top level, so no live bug, but it is the **same latent class** (a future `.claude/skills/.foo` top-level dotfile, or a dotfile-only skill dir, would be dropped — and `.claude/skills` is the path P1's structural gate DOES check, so it'd be caught there but not by the installer). The **deeper class the dotfile bug points at is not dotfiles — it's "the installer copies by enumeration patterns (glob/extension) rather than by derived set"**, which is precisely the surviving P1-1 top-level-file gap. So: dotfile bug fixed; the *class* it gestures at (pattern-based copy missing things) is still live one layer up.

**5. With P1+P2 done, is the standing guarantee self-sustaining? Any remaining hardcoded list that can go stale?**
Not yet fully self-sustaining. **Remaining hardcoded list: the top-level file-extension allow-list `*.yaml *.md *.txt` (tad.sh:242)** — it is already silently dropping `.tad/portable-extract.sh`, and neither the installer self-check nor P1's `release-verify.sh structural` verifies top-level files, so the omission is **undetected by every gate in the system**. Until that is either derived (deny-list style) or at least brought under a verification primitive, the Epic's thesis ("the rules don't drift; the gate catches any omission regardless") is **not satisfied for top-level files**. Everything below the top level (dirs) IS self-sustaining. Recommend the Epic NOT be marked fully self-closing without a one-line acknowledgement of the top-level-file residual (either fix it, or record it as accepted scope with a `TAD_TOP_KEEP` rationale).

---

## Evidence
- `bash tad.sh --verify-denylist` → exit 0, "12 entries" (live, in-sync); flipped-temp negative path documented in COMPLETION → exit 1 naming both sides.
- `derive-sync-set.sh --dirs` → 20 dirs (agents…workflows incl. codex/capability-packs/context/cross-model/scripts/tests) == COMPLETION's 20/20 self-check.
- Deny-list set equality confirmed: lib (`--zero-touch` ∪ transient) == tad.sh `TAD_DENY_LIST` == 12 sorted entries (active…working).
- `git ls-files .tad/portable-extract.sh` → tracked; referenced in `release-runbook/SKILL.md`; extension `.sh` ∉ `{yaml,md,txt}` glob (tad.sh:242); `verify_install_complete` iterates dirs only (tad.sh:303-334); `release-verify.sh structural` diffs `--dirs` + `.claude/skills` only (release-verify.sh:122-156) → top-level file omission undetected by both gates.
- `context` confirmed only dotfile-only `.tad/` dir; `cp -R src/.` fix at tad.sh:265.
- Commits f053f50 (feat) + de952b5 (epic status) present in `git log`.
