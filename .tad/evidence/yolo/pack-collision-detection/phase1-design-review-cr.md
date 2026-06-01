# Phase 1 Design Review (code-reviewer / blue-team pre-impl gate)

**Handoff**: HANDOFF-20260531-pack-collision-detection-phase1.md
**Reviewer**: code-reviewer (pre-implementation design review)
**Date**: 2026-05-31
**Scope**: §6 (Implementation Steps), §9.1 (AC1–AC8), §10 (Important Notes), grounding file, scan-packs.sh mirror.

---

## Overall Verdict: CONDITIONAL PASS

The design is implementable and the bash conventions are sound. There is **1 P0** — a broken AC verification command that, run literally, fails a correct implementation (a documented recurring TAD failure class). Fixable with a one-token edit. Everything else (BSD-safety, scan-packs mirror, heredoc-as-data treatment, anti-theater guard) is correct.

- **P0 count: 1**
- P1 count: 1
- P2 count: 2

---

## P0 (Blocking)

### P0-1 — AC7 verification command uses `\|` (literal pipe), will FAIL a correct guide
**Location**: HANDOFF §9.1, AC7 row (handoff:465).

AC7's Verification Method is:
```
grep -niE 'cli tool\|not a hook\|非 ?hook' .tad/guides/pack-collision-detection.md  ≥1
```
In `grep -E`, `\|` is an **escaped literal pipe character**, NOT alternation. So this regex matches the literal 9-char string `cli tool|not a hook|非 hook` — which will never appear in the guide. Empirically reproduced:

```
$ grep -niE 'cli tool\|not a hook\|非 ?hook' file   → exit 1 (no match)   [WRONG]
$ grep -niE 'cli tool|not a hook|非 ?hook'  file   → matches, exit 0     [CORRECT]
```

This is exactly the recurring failure documented in code-quality.md "AC Verification Command Bug" (2026-05-27): a literal AC command that returns the wrong result regardless of actual content. If Blake (or Gate 4) runs the escaped form verbatim, a perfectly correct guide fails AC7 — and worse, a hand-"fixed" guess could mask it.

**Proof it is an un-escaping artifact, not intent**: the SIBLING command AC6 in the same checklist (handoff:464) uses **bare** `|` inside `grep -niE 'not (acceptance|sufficient)|count.{0,4}signal|hand-re-derive'` and works correctly (reproduced: exit 0). The two ACs are internally inconsistent — AC6 proves the author's intent is alternation, so AC7's `\|` is an accidental markdown-pipe-escape that leaked into the command text. The handoff does **NOT** make the un-escaping explicit anywhere (no note telling Blake to convert `\|`→`|` before running), so Blake will run the escaped form literally.

**Fix**: In AC7, change `'cli tool\|not a hook\|非 ?hook'` → `'cli tool|not a hook|非 ?hook'` (drop both backslashes). Match AC6's bare-`|` style. Optionally add a one-line pre-impl note (mirroring §9.1's existing AC1 note) that AC verification commands use ERE alternation `|`, not `\|`.

---

## P1 (Should-fix)

### P1-1 — AC2/AC3 "shared keyword" pre-filter is unverified against live registry; risk the 3 known pairs don't actually share a keyword
**Location**: §4.2 (handoff:213, 223), §6 step 2 (handoff:360), FR2 (handoff:165), AC2 (handoff:460).

The whole detector is gated on a PRE-FILTER: "only scan pack pairs sharing ≥1 keyword." AC2 requires candidates for all 3 known pairs (ui-design×frontend, ui-design×frontend/testing, frontend×testing). But the handoff never verifies that those specific pairs actually share ≥1 keyword in `pack-registry.yaml`. If, e.g., web-ui-design and web-frontend share no literal keyword token, the pre-filter silently skips the pair → zero candidate → AC2 fails, and the failure looks like a signature problem (red herring). scan-packs.sh keyword extraction is single-line flow-form `["a","b"]` — keyword tokens are exact strings, no stemming. This is a load-bearing assumption left unproven.

**Recommendation**: Blake's first step should be a dry-run: extract keywords for the 3 pairs from the live registry and confirm each pair shares ≥1 token BEFORE writing signatures. If a target pair shares no keyword, the pre-filter design needs a fallback (e.g., also pair on description-token overlap, or whitelist the known pairs) — escalate to Alex rather than silently under-detect. (Cheap to verify now; expensive to misdiagnose post-impl.)

---

## P2 (Nice-to-have)

### P2-1 — AC3 schema mismatch: checklist asks for flat `category_a`/`category_b`; §4.3 example nests `category` under `a_says`/`b_says`
**Location**: AC3 (handoff:461) lists `category_a,category_b`; §4.3 schema (handoff:250, 262, 263) nests `category:` inside `a_says:`/`b_says:`. Minor, but Blake "without guessing" (FOCUS 5) hits a fork. Pick one (the nested §4.3 form is cleaner and is what the worked example uses) and make AC3 reference the same shape.

### P2-2 — candidates.yaml staging-file lifecycle is ambiguous (gitignore vs evidence vs Gate-3 git-tracked-dir)
**Location**: §7.1 note (handoff:420) says "may be gitignored or kept as evidence." But frontmatter `git_tracked_dirs` (handoff:8) includes `.tad/capability-packs`, and OUTPUT lands at `$PACKS_DIR/pack-collisions.candidates.yaml` (handoff:355) — i.e., inside a git-tracked dir. "may be gitignored" + "must be git-tracked" is an unresolved tension. Recommend: write the staging file to `.tad/evidence/yolo/pack-collision-detection/` (evidence, not the packs dir) so it doesn't pollute the auto-generated capability-packs registry space and the lifecycle is unambiguous.

---

## Confirmed CLEAN (focus areas that passed)

- **FOCUS 1 (AC7 \|)**: real bug — see P0-1. Reproduced both forms.
- **FOCUS 2 (other AC commands)**:
  - AC1 `grep -c 'set -euo pipefail' … ==1`: single-file `grep -c` returns one line count; no `sort -u | wc -l` trap. **CLEAN** (reproduced: 1).
  - AC4 `grep -c 'performance' … >0`: line-count >0, no trap. **CLEAN** (reproduced: 2>0).
  - AC5 `grep -F '⚙️ resolved:'` / `grep -F '⚠️ unresolved:'`: `-F` literal-string match on the emoji formats — correct, no regex/escaping hazard. **CLEAN** (both reproduced exit 0).
  - AC6 `grep -niE 'not (acceptance|sufficient)|count.{0,4}signal|hand-re-derive'`: bare `|` alternation, correct. **CLEAN** (reproduced exit 0). (This is the counter-evidence proving AC7's `\|` is a typo.)
  - AC7 settings.json `grep -c 'scan-collisions' … ==0`: single-file count, correct. **CLEAN.**
  - AC8 `git diff --name-only` + `git status --short PATH` empty: correct (clean path prints nothing). **CLEAN.**
  - **No `grep -c … | sort -u | wc -l` traps anywhere.** No `-oc` flag combos. No single-file output-shape mis-assumptions.
- **FOCUS 3 (BSD-safe + scan-packs mirror)**: §4.2/§6 mandate `set -euo pipefail`, `SCRIPT_DIR/TAD_DIR/PACKS_DIR` derivation, arg-parse-BEFORE-OUTPUT-derive, anchored awk frontmatter `awk '/^---$/{if(++n==2) exit} n==1 && /^keywords: /'`, single-line flow-form keywords — all match scan-packs.sh:14-30,61. NFR1 (handoff:175) + §10.2 + self-check step 8 explicitly forbid `grep -P`, `\d`, `.*?`, `readlink -f`. **CLEAN — faithful mirror.**
- **FOCUS 4 (heredoc sink)**: §4.2(A) handoff:216 and §6 step 3 handoff:365 correctly classify `cat > "$OUTPUT" <<EOF` as a **file-write (data) sink, NOT interpreter injection**, and mandate newline-flattening (`tr`/`sed`/`gsub`) of matched quotes — exactly per code-quality.md "Heredoc injection depends on the SINK" (2026-05-31). NFR/notes forbid interpreter heredoc on file content. **No heredoc-injection P0 raised** (correctly). **CLEAN.**
- **Anti-validation-theater guard**: AC2/AC3/AC6 marked ⚠️hand-re-derive; §10.1 + FR9 + §9.1 header all state "N collisions found is NOT acceptance." Correctly applies architecture.md 2026-05-30. **CLEAN.**
- **Parser self-trigger defense**: signatures in `.tad/scripts/` (not scanned pack dirs), fixtures in `.tad/evidence/fixtures/` — §10.1 handoff:496, step 4 handoff:370. **CLEAN.**
- **Concurrency safety**: P1 is new-files-only; `pack-registry.yaml` READ-ONLY; zero SKILL edits; worktree isolation. **CLEAN.**

---

## Bottom line
Ship after fixing **P0-1** (AC7 `\|` → `|`). Strongly recommend resolving **P1-1** (dry-run the keyword pre-filter against the 3 target pairs) before Blake writes signatures, to avoid a post-impl red-herring. P2s are polish.
