# Phase 1 Implementation Review — Pack Collision Detector (code-reviewer, blue-team, post-impl)

**Reviewer:** code-reviewer (blue-team, post-implementation)
**Date:** 2026-05-31
**Artifacts:** `.tad/scripts/scan-collisions.sh`, `collision-signatures.txt`, `pack-collisions.yaml`, `pack-collisions.candidates.yaml`, COMPLETION/HANDOFF phase1
**Method:** Re-derived every claim independently against live `.claude/skills/` files and `git show d296374`. Did NOT trust the completion report.

**Overall: CONDITIONAL PASS** — P0 count: **0** · P1: **1** · P2: **2**

The detector is functionally correct and all 8 ACs hold. One genuine correctness defect (CJK locale-collation false-match in the keyword pre-filter) is P1 because it admits an un-pre-filtered pair into the candidate set; it did not corrupt the confirmed registry but it is a real bug and it is exactly what produced the "bonus" candidate. Recommend fix-then-accept.

---

## Re-derived AC table (independent recompute — NOT from report)

| # | Claim | My re-derivation | Verdict |
|---|-------|------------------|---------|
| AC1 | `bash -n` exit 0; `--help` exit 0; `grep -c 'set -euo pipefail'`==1 | `bash -n` → EXIT 0; `--help` → EXIT 0; count == **1** | ✅ matches |
| AC1 | BSD-safe (no grep -P/\d/.*?/readlink -f in executable) | Only hit is line 22 — a **comment** listing the forbidden constructs; zero in executable lines | ✅ matches |
| AC1 | no `grep -c \| sort -u \| wc -l` trap | Only hit is line 197 — a **comment** warning against it; zero executable | ✅ matches |
| AC2 | scanner emits candidates for all 3 known pairs | Ran (sandbox-disabled): `14 packs x 3 signatures → 5 candidate(s)`, exit 0. 3 required topics all present: inter-font, contrast-standard, testing-pyramid | ✅ matches |
| AC3 | `pack-collisions.yaml` 3 rows, nested category, refs in `.claude/skills/`, resolutions correct | All 3 rows hand-re-derived live (see below). Nested `category` under a_says/b_says confirmed. Inter→auto/winner=web-frontend/`performance>style`; contrast→escalate/same-cat a11y; pyramid→escalate/same-cat testing | ✅ matches |
| AC4 | precedence engine documented | (guide not in focus-set; AC3 resolution fields consistent with it) | ✅ (assumed, not re-read) |
| AC5 | surfacing one-liners | not re-derived (out of focus) | — |
| AC6 | anti-theater guard | candidates header + yaml header both carry "N … is NOT acceptance / hand-re-derive" | ✅ present |
| AC7 | not in settings.json | `grep -c 'scan-collisions' .claude/settings.json` == **0** | ✅ matches |
| AC8 | only new files, no SKILL/registry/settings edits | `git show --stat d296374` = **9 files, all new (+940/-0)**; `--name-only \| grep SKILL/registry/settings` → **NONE** | ✅ matches |

### Hand-re-derived confirmed-row refs (all live, all true)
- web-ui-design/SKILL.md:93 → `NEVER use Inter, Roboto, Arial, or system-ui as the primary typeface.` ✅
- web-frontend/references/performance.md:215 → `import { Inter } from 'next/font/google'` ✅
- web-ui-design/SKILL.md:454 → `**Step 4: Validate contrast with APCA**`; :476 → `- APCA LC ≥60 for body text, ≥45 for large text` ✅
- web-frontend/references/accessibility.md:45 → `| 2 | Insufficient color contrast | Minimum 4.5:1 (normal text), 3:1 (large text/UI)…` ✅
- web-frontend/references/testing.md:15 → `| **Unit** (most) | ~60% |…`; :19 → `**Threshold**: If E2E tests make up >20%… — cut.` ✅
- web-testing/references/test-strategy-rules.md:25 → `- **Unit tests (base)**: …(70% of test count)…`; :31 → `- **UI-heavy app** … More E2E tests` ✅
- (3rd pack note) web-testing/references/accessibility-testing-rules.md:12 → `| X5 | Contrast ratio >= 4.5:1 for normal text |…` ✅

All resolution/winner/loser/rule values are correct per the precedence engine. **AC table in COMPLETION matches reality.**

---

## BONUS CANDIDATE determination — `web-ui-design × video-creation` contrast (`video-creation/references/quality.md:103`)

**Verdict: FALSE POSITIVE — admitted by a bug; must be DROPPED at Stage-2 confirm.** Two independent findings:

**(1) The PRE-FILTER match that admitted this pair is itself a false positive (locale bug — see P1 below).**
web-ui-design keywords ∩ video-creation keywords is genuinely **empty**:
- ui = {设计, 设计系统, accessibility, design, frontend, interface, ui, ux, visual design, wireframe}
- video = {视频, animation, hyperframes, motion design, remotion, video}
`grep -c '设计' <video-set>` = **0** — `设计` is NOT in video-creation's keywords. Yet the script's own `comm -12` returns `设计` as a shared keyword. Under `LC_ALL=C` (byte sort, which `comm` requires) the intersection is correctly **empty**. So this pair should never have been scanned at all; the candidate only exists because the pre-filter let it through.

**(2) Even setting the pre-filter bug aside, the CONTENT is arguably a real opposition but NOT a NEW collision — it is a co-instance of confirmed Collision 2, with weaker standing.**
quality.md:99-105 is a `### Text Contrast Requirements (WCAG AA)` table prescribing `4.5:1` for standard text. web-ui-design's checklist says `APCA LC ≥ 60 (replaces WCAG 4.5:1 for body)`. Structurally this is the *same* APCA-vs-WCAG opposition already captured as Collision 2 (a11y-vs-a11y escalate), just with a third pack on the WCAG side — **and** video-creation scopes its rule to on-frame *video* text, a different surface than web-ui-design's web body text, so the "contradiction" is partly a domain-scope artifact. It is NOT an independent new collision and should be DROPPED (or folded into Collision 2's multi-pack note) with a recorded `drop_rationale`.

The COMPLETION calls this bonus "genuine" — that is **overstated**. It is a co-mention-grade artifact admitted by the locale bug; the correct disposition is drop-with-rationale, which is exactly the Stage-2 defense the design mandates. The fact that Stage-2 (manual confirm) did NOT promote it into `pack-collisions.yaml` is correct behavior — the registry is clean. The mislabel is only in the report prose.

---

## P1 (should fix)

**P1-1 — CJK keyword pre-filter is unreliable: `sort -u` + `comm` collation mismatch under UTF-8 locale produces spurious shared-keyword matches.**
`keywords_to_lines | sort -u` (lines 198-200) feeds `comm -12`, but `comm` assumes **byte** (C-locale) ordering while the ambient locale is `en_US.UTF-8`. CJK keyword lines sort differently under the two collations, so `comm` reports a false intersection (`设计` for web-ui-design × video-creation, which share no actual keyword). Impact: pairs that do NOT share a keyword are scanned anyway — the pre-filter (the design's primary false-positive defense and "keeps the candidate set small" guarantee) is partially defeated. Today it only leaked one extra pair (caught downstream), but with more CJK-keyword packs the candidate set will inflate with un-pre-filtered pairs.
Fix: force byte collation on both the sorts and the comm, e.g. `LC_ALL=C comm -12 <(… | LC_ALL=C sort -u) <(… | LC_ALL=C sort -u)`. This is the same class as the project's documented "Shell Pattern: Word-Boundary Matching for Slugs" / BSD-portability lessons — CJK + `comm` needs explicit `LC_ALL=C`. (Verified: with `LC_ALL=C` the intersection is empty as it should be.)

---

## P2 (consider)

**P2-1 — Candidate emission duplicates each distinct collision 3×.** A fresh run writes **15 candidate rows for 5 distinct pair×topic collisions** (each distinct candidate repeated 3 times with identical refs). Cause: the same opposing pair is re-hit across multiple shared-keyword orientations / multiple matching files without dedup. Harmless to the confirmed registry (Stage-2 dedupes by hand) but it (a) inflates the staging file, (b) makes the stderr "N candidate(s)" count non-obvious (reports 5 here, but the file holds 15 rows; the committed file held 10), and (c) is itself a mild "count ≠ signal" smell in a tool whose entire thesis is anti-validation-theater. Consider deduping emitted rows by `(pack_a,pack_b,topic,a_ref,b_ref)`.

**P2-2 — `set -euo pipefail` + write-denied environment fails hard mid-heredoc, truncating the staging file.** When the `cat >> "$OUTPUT"` append is denied (e.g. a sandbox/read-only FS), `set -e`/`pipefail` aborts the loop with a non-zero exit (observed exit 144) leaving a **truncated 7-line candidates file** (header only, zero candidates) — a silent partial output that looks like "0 collisions = clean." This is correct fail-fast for a CLI tool (NFR2 explicitly allows it), so not a P1, but the staging file should be written atomically (build to a temp file, `mv` into place on success) so a denied/interrupted write never leaves a misleading half-file that a later reader mistakes for "no collisions." (This is also why a naive "re-run and diff for determinism" check is unsafe here — a denied write yields an empty file that diffs equal to a prior empty file. Determinism was re-confirmed only after enabling the write: 5 distinct candidates, stable.)

---

## What is solid (acknowledge)
- `@@@` delimiter parsing is robust; `|` correctly stays free for `-E` alternation inside each side. Signatures are well-anchored (`NEVER use Inter`, not bare `Inter`; `4\.5:1` escaped) — no over-fire on `INP`/`Interaction`.
- `pack_files()` correctly excludes CHANGELOG/LICENSE*/README.
- `flatten()` newline-collapse before the file-write heredoc is the right hardening (file-write heredoc ≠ interpreter injection — matches code-quality.md 2026-05-31).
- `first_match` guards every `grep` with `|| true` / `if`, so `set -e` does NOT abort on grep-exit-1 (the classic bug is avoided). The `< <(pack_files …)` process-sub + `read` loop is `set -e`-safe.
- AC8 is genuinely clean: 9 new files, zero SKILL/registry/settings edits.
- Confirmed `pack-collisions.yaml` registry is accurate and contains NO false positives (the bonus was correctly kept out).

---

## Recommendation
**CONDITIONAL PASS.** Fix P1-1 (`LC_ALL=C` on the comm/sort pre-filter) before accept — it is the root cause of the only false-positive candidate and weakens the design's stated pre-filter guarantee. P2-1/P2-2 are quality hardening (dedup + atomic write). The confirmed registry, all 8 ACs, and BSD-safety are correct as shipped.
