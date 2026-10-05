# P0 Re-review — DESIGN-20260904-public-facade-cleanup (v2)

- **Reviewer:** independent re-reviewer (fresh context, not design author)
- **Date:** 2026-09-04 · **Scope:** verify ONLY the 4+2 P0 fixes in design v2 (94 lines)
- **Method:** full DESIGN re-read + on-disk spot-checks in `/home/box/云同步/TAD`
- **Prior reports:** `release-reviewer.md` (R-P0-1..4, R-P1-1..6) · `spec-compliance.md` (S-P0-1..2, S-P1-1..6)
- **Verdict:** **PASS** — all 6 P0 claims fixed + P1 dispositions sane, no new scope creep. Gate 2 may proceed.

## 1. R-P0-1 (draft-then-publish) — PASS
- DESIGN §FR4 (L55–58): both creates carry `--draft`; step (3) `gh release edit <tag> --draft=false` executes only after human draft-render approval; "Blake MUST NOT publish live on first write."
- §7 L87 restates: publish step executes ONLY after human approval. No `gh release create` without `--draft` remains in the file.
- Evidence: `grep -n 'release create' DESIGN` → both lines contain `--draft`; `grep -n 'draft=false'` → present.

## 2. R-P0-2 (full SHAs + --verify-tag) — PASS
- DESIGN L57–58 pins `40cf3234ade45a5ef1fdf0afc729b2537347a1ca` + `83e835d8dfcdd78465d2757253d38001e308b5a5`, each with `--verify-tag`.
- On-disk: `git rev-list -n 1 v2.44.0` = `40cf3234…7a1ca` ✓; `git rev-list -n 1 v2.44.1` = `83e835d8…0b5a5` ✓ (byte-equal to design).
- Preconditions (L59) require `git ls-remote` peeled-SHA match + absence confirm for BOTH tags.

## 3. R-P0-3 / S-P1-3 (AC5 pathspec-scoped) — PASS
- DESIGN L69: `git status --porcelain -- README.md package.json` (at most those two) + negative `git diff --name-only | grep -cE '…'` guard. No bare `git status --short` remains.
- On-disk sanity: scoped status returns empty (clean for this single's pathspec) while unscoped `git diff --name-only` shows sibling-track riders — exactly the dirty-tree shape that motivated the fix; the scoped AC is runnable where the bare form was not.

## 4. R-P0-4 / S-P0-2 / S-P1-4 (AC6 rewritten + footer R1d) — PASS
- DESIGN L70: stale pattern `2\.44\.1 - Verified Orchestration` post-change == 0 AND `grep -c 'Optional PM Bridge' README.md` ≥ 2.
- Fails-today confirmed: `grep -rn '2\.44\.1 - Verified Orchestration' README.md` → 2 hits (lines 3, 504); `grep -c 'Optional PM Bridge' README.md` → 0. Both clauses are non-theater.
- FR1 R1d (L43–44) rewrites footer :504 to patch-honest mirror of R1a — S-P0-2 footer coverage closed.

## 5. S-P0-1 / R-P1-5 (v2.44.0 title honesty) — PASS
- DESIGN L57 title: `TAD v2.44.0 — Capability Builder Evolve + Packaging, Installer Data-Safety (+ v2.43.1 trio)` — no "Verified Orchestration".
- Honesty basis confirmed: `grep -c 'Verified Orchestration' CHANGELOG.md` == 0 (exit 1). Bodies must cite CHANGELOG subsections (L59).

## 6. P1 dispositions — SANE (all PASS)
- **AC3 split (S-P1-1):** L67 package half = drift-guard ("MUST still equal", passes today by design) + repo-desc half = change-proof (`Triangle`+`Two-Agent`, fails today). Correct labeling.
- **AC2 render check (R-P1-2/S-P1-2):** L66 = local grep (== 2, headers L10/L28 verified on disk) AND human click-through of both anchors on the DRAFT v2.44.1 page; fallback trigger explicit (either anchor 404s at draft review → bare section link before publish). Sane — draft-render replaces the proposed curl.
- **Order + --latest (R-P1-4):** L58 v2.44.0 no `--latest`, v2.44.1 `--latest` explicit, order v2.44.0→v2.44.1; AC4 asserts Latest == v2.44.1. Closed.
- **Pre-hash duty (R-P1-6):** L68 Blake re-captures `… | sha256sum` immediately pre-write, embeds pre+post; reviewer baseline `d3af1fff…1b0c6c` explicitly non-governing. Closed.
- **H1 carve-out (S-P1-5):** L45 keeps H1 unchanged with rationale (brand mark, zero disambiguation gain); footer fixed via R1d. Explicit waive-with-rationale — acceptable.
- **AC7 for R1c (R-P1-1):** L71 `grep -c 'Two-Agent Quality Framework' README.md` ≥ 1; pre-change 0 confirmed on disk today (count 0). Non-theater.
- **Bonus:** R-P1-3 (§7 v2.44.1 absence line) fixed — L80–81 log both `release not found` lines.

## 7. No NEW scope creep — PASS
- v2 edits add only: `--draft`/`--draft=false` flags, full SHAs, `--verify-tag`, `--latest`/order, R1d footer (README-internal), AC7 (README grep), reworded ACs. Still only {README.md, package.json-verify, `gh repo` meta, 2 Release objects}.
- §4 non-goals intact (no Gate/hook/template/evidence/config/CLAUDE.md/AGENTS.md); D1–D6 table untouched; PM Bridge advisory-only constraint retained.

## Residuals / non-blocking notes
- None blocking. Minor: AC5's negative segment `(^|/)gate[^/]*` is slightly broad (any path segment starting with "gate") — acceptable as a conservative tripwire; do not weaken it.
- `node -e …` line in §7 (L84) has a pasted artifact (`Charlotte…unconstrained`) — cosmetic, the AC3 command in L67 is correct; suggest one-char cleanup at Gate 2 sign-off, not a re-review trigger.

## Overall
**PASS** — 6/6 P0 fixes verified with on-disk evidence; P1s sanely disposed; no scope creep. **Gate 2 may proceed** (pending the standing R2-process requirement already satisfied by the two-review rule: spec-compliance = R1, release-reviewer = R2, this file = P0 re-verification).
