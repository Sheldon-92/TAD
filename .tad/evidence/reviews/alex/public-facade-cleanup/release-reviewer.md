# Gate-2 Pre-Handoff Review — DESIGN-20260904-public-facade-cleanup

- **Reviewer:** independent release-operations expert (fresh context, not the design author)
- **Date:** 2026-09-04 · **Scope:** `.tad/active/designs/DESIGN-20260904-public-facade-cleanup.md` (88-line Express design, Alex author)
- **Method:** on-disk evidence only; every design claim re-executed in `/home/box/云同步/TAD`
- **Verdict:** **CONDITIONAL** — 4 × P0 (must fix before Gate 2 PASS / handoff), 6 × P1 (fix or explicitly waive)

## Verified baseline (all commands re-run by reviewer)

- Tags on origin exist; peeled SHAs match design: `git ls-remote --tags origin | grep -E '2\.44\.[01]'`
  → `b9ac39c8… refs/tags/v2.44.0`, `40cf3234… refs/tags/v2.44.0^{}`, `962d32a5… refs/tags/v2.44.1`, `83e835d8… refs/tags/v2.44.1^{}`.
  `git rev-list -n 1 v2.44.0` = `40cf3234ade45a5ef1fdf0afc729b2537347a1ca`; `git rev-list -n 1 v2.44.1` = `83e835d8dfcdd78465d2757253d38001e308b5a5` (= HEAD). Design SHAs are the **peeled commit** SHAs — correct objects for `--target`, but see R-P0-2 (short form).
- Both Release objects absent: `gh release view v2.44.0 --json tagName` → `release not found` (exit 1); same for `v2.44.1`. `gh release list --limit 5` Latest = `v2.43.0` (2026-09-02).
- `head -5 README.md` line 3 = `**Version 2.44.1 - Verified Orchestration, Capability Builder, and Local Wiki Capture**` (bundle story on patch — P2 confirmed).
- `node -e "console.log(require('./package.json').description)"` = `Triangle Agent Development - Two-Agent Quality Framework for AI-assisted development` (byte-verified via `JSON.stringify`; FR2 = verify-only, correct).
- `grep -n '^## \[2\.44' CHANGELOG.md` → lines 10 (`[2.44.1]`) and 28 (`[2.44.0]`) — both sections exist.
- `git diff v2.44.0..v2.44.1 --stat` = 8 files (`completion-report.md` +18, `version.txt`, `CHANGELOG.md` +18, `README.md` version bumps only, 3× `docs/pm/`, `package.json`); README hunk = version-number bumps only — design's "version-number bump only" claim accurate.
- Toolchain: `gh 2.46.0` at `/usr/bin/gh` (matches MQ2); `gh auth status` = logged in as `Sheldon-92` (preflight satisfiable); `gh repo view --json description` = `TAD Method — Two-Agent Quality Framework for AI-assisted development. Design (Alex) + Execute (Blake) + 4-Gate quality system + 25 capability packs.` (contains `Two-Agent`, lacks `Triangle` — FR3 change is real, non-theater).
- Anchor-slug precedent: live `v2.43.0` Release body links `CHANGELOG.md#2430---2026-09-02` — same slug shape as proposed `#2440/#2441---2026-09-04`, so anchors are plausible.
- Untouched-proof baseline captured by reviewer: `gh release view v2.43.0 --json body -q .body | sha256sum` = `d3af1fff4c860a7a670d4ecb46ef01794532204ee6d7ef04a49c59119d1b0c6c` (design omits this — see R-P1-6; Blake must re-capture pre-write and compare post).

## P0 findings (must fix before Gate 2 PASS)

### R-P0-1 — FR4 commands omit the `--draft` gate promised in §6 R1 (irreversible-write hazard)
- Evidence: DESIGN lines 53–54 (`gh release create v2.44.0 …`, `gh release create v2.44.1 …` — no `--draft`) vs line 69 ("Mitigation: precondition checks + `--draft` first, human confirms draft renders, then publish").
- A Blake following FR4 literally publishes immediately; §7 line 81's "draft-first" parenthetical is then false. `gh release create -d/--draft` exists (verified in `gh help release create`).
- Fix: rewrite FR4 as two-step per Release — `gh release create <tag> --target <FULL-SHA> --verify-tag --draft --title … --notes-file …`, human confirms draft renders, then `gh release edit <tag> --draft=false`. Mandate must carry the draft-then-publish sequence, not just titles.

### R-P0-2 — FR4 pins 8-char short SHAs; `gh` documents `--target` as "branch or full commit SHA"
- Evidence: DESIGN lines 53–54 (`--target 40cf3234`, `--target 83e835d8`) vs `gh help release create` FLAGS (`--target branch … Target branch or full commit SHA`); full SHAs verified above (`40cf3234ade45a5ef1fdf0afc729b2537347a1ca`, `83e835d8dfcdd78465d2757253d38001e308b5a5`).
- Fix: use full 40-char peeled SHAs AND add `--verify-tag` (aborts if the tag is missing remotely — exactly the "no overwrite path" precondition on line 55, enforced by the tool instead of by eyeball).

### R-P0-3 — AC5's bare `git status --short` is unrunnable: the tree is already dirty from unrelated tracks
- Evidence: DESIGN line 65 vs `git status --short` (reviewer run): dozens of pre-existing ` D` entries (e.g. `.agents/skills/…`, `.tad/active/research/…/.env.example`) from other active tracks — the "shared index" shape §6 R1/R3 already acknowledges. Bare `git status --short shows ONLY README.md package.json` FAILS before Blake touches anything, through no fault of his.
- Fix: scope the AC with pathspecs — `git status --short -- README.md package.json` and `git diff --stat -- README.md package.json` (+ keep the `no *gate*/*hook*/completion-report.md` negative grep). This matches R3's own pathspec-commit mitigation (line 71).

### R-P0-4 — AC6 is fully vacuous as written (both clauses already pass pre-change; stale pattern names the wrong version)
- Evidence: DESIGN line 66 vs reviewer runs: `grep -rn '2\.44\.0 - Verified Orchestration' README.md` → no match (exit 1, already "0" pre-change, because the stale headline carries **2.44.1**, README line 3); `grep -c '2\.44\.1' README.md` → `3` (already ≥ 2 pre-change).
- The meaningful stale string is `2.44.1 - Verified Orchestration` (present 2×: lines 3 and 504). As written, AC6 passes with zero work — acceptance theater.
- Fix: `grep -rn '2\.44\.1 - Verified Orchestration' README.md` == 0 post-change AND `grep -c 'Optional PM Bridge' README.md` ≥ 1 (pointer-line proof) or equivalent R1a/R1b positive greps. AC2's headline grep stays the primary gate.

## P1 findings (fix or explicitly waive with rationale)

### R-P1-1 — R1c (README hybrid naming) has no AC
- Evidence: DESIGN lines 42 (R1c) vs lines 61–66 (AC1–AC6 — none greps README for the hybrid); reviewer `grep -n 'Triangle\|Two-Agent' README.md` → title line 1 + `Triangle Model` ×2 only; philosophy paragraph (lines 10–28) carries **no** `Two-Agent Quality Framework` — so R1c is a real edit with zero verification.
- Fix: add AC — post-change `grep -c 'Two-Agent Quality Framework' README.md` ≥ 1 (pre-change value 0, verified → non-theater).

### R-P1-2 — AC2 "anchor pattern check" is local-grep only; no true resolution check, fallback trigger undefined
- Evidence: DESIGN lines 43, 62. Local `grep -c` cannot prove a GitHub-rendered anchor resolves; R2's fallback ("link `#changelog` section without anchor", line 70) has no trigger condition.
- Fix: define the check — e.g. fetch rendered HTML or `gh api repos/{owner}/{repo}/contents/CHANGELOG.md` is not rendering; simplest honest gate: slug recomputed from heading text per GitHub slugger rules + post-publish click-through by human before closing the handoff. State which one Blake must do.

### R-P1-3 — §7 dry-run confirms only v2.44.0 absence, not v2.44.1
- Evidence: DESIGN lines 74–80 list `gh release view v2.44.0` only, while §1 line 21 claims both return "release not found". Reviewer confirmed both absent — claim true, but the dry-run log is incomplete as the handoff's own evidence.
- Fix: append the v2.44.1 `release not found` line to §7 (or the handoff's pre-write re-verify step).

### R-P1-4 — Latest-pin is left to GitHub automatics; creation order/flags unspecified
- Evidence: DESIGN line 54 ("Creates Latest=v2.44.1 automatically (highest semver tag)"); `gh help release create` shows `--latest` ("Mark this release as Latest (default [automatic based on date and version])"). Creating v2.44.0 first could transiently mark *it* Latest.
- Fix: mandate order (v2.44.0 then v2.44.1) and pass explicit `--latest` semantics on the v2.44.1 create (and default off on v2.44.0), then AC4 asserts Latest == v2.44.1 (already does).

### R-P1-5 — Proposed v2.44.0 title leads with "Verified Orchestration", untraceable to CHANGELOG [2.44.0] bullets
- Evidence: DESIGN line 53 title vs CHANGELOG lines 28–44 (`[2.44.0]`: Capability Builder evolve/package + Installer data-safety + v2.43.1 trio; no orchestration bullet — "Verified Orchestration" is the v2.43.0 headline per the live v2.43.0 Release title).
- The v2.43.0..v2.44.0 bundle diff is large (45 files, +5259/−216, incl. `tad.sh` +1109), so orchestration work may exist below the CHANGELOG bullets — but the handoff cites CHANGELOG as the notes source (MQ2/FR4), so the title should reconcile: either cite the orchestration evidence or retitle to the [2.44.0] bullets (+ trio). Patch-honesty (D2) cuts both ways.

### R-P1-6 — AC4's pre/post hash compare has no recorded pre-hash baseline in the design
- Evidence: DESIGN line 64 ("hash compare recorded pre/post") records no hash. Reviewer baseline: `d3af1fff…1b0c6c` (see above), but Blake must re-capture `gh release view v2.43.0 --json body` immediately pre-write (bodies are mutable by anyone with access) and embed both hashes in the completion evidence.
- Fix: one line in the handoff — "record pre-hash <value> at <time>; post-compare must equal".

## What the design gets right (explicit confirmations for (a)–(d))

- (a) Tag/target SHAs correct: peeled SHAs `40cf3234…`/`83e835d8…` verified via `git rev-list -n 1` and `ls-remote ^{}` (note: bare `git rev-parse v2.44.0` returns the annotated-tag object `b9ac39c8…`, so the handoff must keep saying "peeled commit SHA" — it does via MQ5, line 32).
- (b) Mechanism right: with tags already on origin, `gh release create <tag> --target <commit>` is the correct additive-only path (no overwrite/edit/delete commands anywhere in FR4; `--verify-tag` addition recommended, not a mechanism change). Draft-first mitigation is sound — it is just missing from the FR4 commands (R-P0-1).
- (c) README proposal is patch-honest: R1a headline names version + patch noun (`Optional PM Bridge`) + bundle pointer; R1b retains (not deletes) the bundle narrative; anchors match GitHub slugger output with live precedent (v2.43.0 body). R1c is additive single-line touch. Canon hybrid string (D3) byte-matches `package.json` today.
- (d) Scope discipline holds: FR1–FR4 touch only README / package.json-verify / repo metadata / two Release creates; §4 non-goals explicitly exclude Gate/hook/handoff-template/evidence-path/PM-Bridge-template/config/CLAUDE.md/AGENTS.md; no old-Release edit/delete path exists in the plan; `git diff v2.44.0..v2.44.1 --stat` confirms the *prior* patch itself left Gate/hook semantics alone (template +18 advisory-only lines, docs/pm trio).

## Re-check of the 6 dry-run claims in DESIGN §7

1. `gh release view v2.44.0` → "release not found": **CONFIRMED** (exit 1; reviewer also confirms v2.44.1 absent).
2. `ls-remote` tags + peeled SHAs present: **CONFIRMED** (values match to the full 40 chars).
3. `head -3 README.md` → bundle headline on 2.44.1: **CONFIRMED** (line 3, exact string).
4. `node … package.json description` → hybrid already: **CONFIRMED** (byte-equal; FR2 verify-only justified).
5. `grep -c '^## \[2\.44' CHANGELOG.md` → 2: **CONFIRMED** (lines 10, 28).
6. "All AC commands read-only except the 4 writes (…draft-first)": **PARTIALLY INACCURATE** — the read-only characterization holds, but the parenthetical "draft-first" is aspirational: FR4 contains no `--draft` (see R-P0-1), and the write count is 4–5 depending on whether FR2/package.json drifts.

## Handoff condition

Gate 2 PASS requires: R-P0-1 → FR4 draft-then-publish sequence with exact flags; R-P0-2 → full SHAs + `--verify-tag`; R-P0-3 → pathspec-scoped AC5; R-P0-4 → rewritten AC6 with the `2.44.1` stale pattern + positive pointer grep. P1s may be fixed or waived with one-line rationale each; R-P1-5 (title honesty) and R-P1-1 (R1c AC) are strongly recommended. Re-review of the four P0 edits only — no new full review needed.
