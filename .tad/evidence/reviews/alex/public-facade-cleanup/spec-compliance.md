# Spec-Compliance Review (Gate 2 pre-handoff, R1 of 2) — DESIGN-20260904-public-facade-cleanup

- **Design:** `.tad/active/designs/DESIGN-20260904-public-facade-cleanup.md` (88 lines, Express)
- **Reviewer:** independent spec-compliance reviewer (fresh context, not design author)
- **Date:** 2026-09-04 · **Verdict:** CONDITIONAL — 2 P0 fixes + R2 reviewer required before Gate 2 PASS
- **Contracts checked:** D1–D6 human decisions (task turn) · hard constraints (backward-compat only; no Gate-semantics / no PM-Bridge-behavior change) · TAD principles (Express still needs expert review; ACs runnable; claims need on-disk carriers)

## Decision-fidelity table (D1–D6 × carried-faithfully?)

| # | Human decision | In FR1–FR4? | Faithful? |
|---|---|---|---|
| D1 | Both missing Releases: v2.44.0 (bundle) + v2.44.1 (patch → Latest); old untouched | FR4 (two `gh release create` + preconditions §FR4/§7) | YES |
| D2 | README patch-honest headline; bundle → body/section | FR1 R1a+R1b | YES (headline), PARTIAL (footer line 504 keeps stale bundle string — see S-P1-5) |
| D3 | Naming hybrid-c `Triangle Agent Development — Two-Agent Quality Framework` everywhere in scope | FR1 R1c, FR2 canon pin, FR3 repo desc | PARTIAL — H1 (`# TAD Method - Triangle Agent Development`, README:1) and footer (README:504) left outside canon — see S-P1-5 |
| D4 | Old Releases untouched (no edit/hide/delete) | FR3 ("Old Releases untouched"), FR4 additive-only, Non-goals, AC4 hash-compare | YES |
| D5 | Scope README+package+repo-meta+Releases only; NO config/CLAUDE/AGENTS/hooks/templates/Gate | FR1–FR4 + Non-goals + AC5 | YES — no scope creep (see §Scope) |
| D6 | Express path; 2 expert reviewers pre-handoff; no e2e | §0 D6, §8.4/§9 (this report = R1; R2 pending) | YES as designed; Gate 2 PASS blocked until R2 lands (S-P1-6) |

Hard constraints: HONORED — Non-goals + AC5 list Gate/hook/template/PM-Bridge-template as zero-touch; PM-Bridge advisory-only claim verified on disk (`.tad/templates/completion-report.md:281-285` reads ADVISORY-ONLY, Friction Status sole authority).

## Scope-creep grep

Searched DESIGN for out-of-scope paths (`config.yaml|CLAUDE.md|AGENTS.md|hooks?/|templates/|INSTALLATION|docs/|tad.sh|bin/`): every hit is an EXCLUSION/non-goal/AC5-guard or a read-only reference (`.tad/version.txt` read for version pin; `CHANGELOG.md` link target, not edited; `.tad/templates/completion-report.md` appears only in AC5's must-NOT-appear list). No FR writes outside {README.md, package.json, `gh repo` meta, Release objects}. **No scope creep.**

## Findings

### S-P0-1 — FR4 v2.44.0 Release title misrepresents CHANGELOG content (must retitle)
- Evidence: FR4 title `TAD v2.44.0 — Verified Orchestration + Capability Builder Evolve/Package + Installer Data-Safety`. `grep -c "Verified Orchestration" CHANGELOG.md` = **0**. `sed -n '/## \[2.44.0\]/,/## \[2.43.1\]/p'` lists only: Capability Builder Phase 2 evolve + Phase 3 packaging; installer data-safety remainder; v2.43.1 trio included. "Verified Orchestration" is the **v2.43.0** story (v2.43.0 CHANGELOG: "YOLO2 verified orchestration…"; current Latest Release title `TAD v2.43.0 — Verified Orchestration, Capability Builder, and Local Wiki Capture`). Repeating it on v2.44.0 recreates the exact bundle-story confusion D2 exists to kill.
- Fix: retitle to CHANGELOG-faithful wording, e.g. `TAD v2.44.0 — Capability Builder Evolve + Packaging, Installer Data-Safety (+ v2.43.1 trio)`. v2.44.1 title (`Optional PM Bridge (patch)`) is faithful — matches `[2.44.1]` section (completion-template optional PM Bridge, advisory-only) — KEEP.
- Bodies are not yet on disk (Blake writes `body-v2440/2441.md`); mandate must require each body bullet to cite its CHANGELOG subsection.

### S-P0-2 — AC6 stale-narrative pattern can never match (theater AC, must fix pattern + cover footer)
- Evidence: AC6 uses `grep -rn '2\.44\.0 - Verified Orchestration' README.md`. Actual stale strings on disk are `Version 2.44.1 - Verified Orchestration…` (README:3) and `Welcome to TAD v2.44.1 - Verified Orchestration…` (README:504) — verified: the `2.44.0 - Verified` grep exits 1 **today** (already "0 matches"), so AC6-clause-1 PASSES on the broken tree. `git diff v2.44.0..v2.44.1 -- README.md` confirms the bug was a pure version-bump (3 spots: :3, :188, :504).
- Fix: pattern must be `2\.44\.1 - Verified Orchestration` (expect ≥1 today → 0 post-change), and FR1 must also cover the footer (:504), not just the headline — see S-P1-5.

### S-P1-1 — AC3 package.json half passes today (vacuous as change-proof)
- Evidence: `node -e "console.log(require('./package.json').description)"` already equals the canon hybrid string today. The `gh repo view` half correctly FAILs today (desc `TAD Method — Two-Agent Quality Framework…` lacks `Triangle` — verified via `gh repo view`). Fix: reword AC3-package-half as drift-guard ("must still equal canon post-run"), keep repo-desc half as the change-proof.

### S-P1-2 — AC2 anchor check never touches GitHub rendering
- Evidence: AC2 verifies anchors via local `grep -c '^## \[2.44'` (=2, confirmed) + "anchor pattern check". Slug derivation (`[2.44.1] - 2026-09-04` → `#2441---2026-09-04`) is correct by GitHub's algorithm, but nothing in AC2 resolves the URL. Fix: add `curl -sIL https://github.com/<owner>/<repo>/blob/main/CHANGELOG.md#2441---2026-09-04` (or draft-Release preview render) to AC2; keep R2 fallback (bare `#changelog` link).

### S-P1-3 — AC5 false-fails on the real (dirty) tree
- Evidence: `git status --short` today shows many pre-existing modifications (concurrent-terminal riders, e.g. deleted skill refs, research files) — AC5 as written ("shows ONLY README.md package.json") fails regardless of Blake's discipline. Fix: scope to pathspec — `git status --porcelain -- README.md package.json` plus a negative guard `git diff --name-only | grep -cE 'tad/templates/completion-report|gate|hook' == 0`.

### S-P1-4 — AC6 second clause passes today (vacuous)
- Evidence: `grep -c '2\.44\.1' README.md` = 3 today (lines 3, 188, 504), so `≥ 2` passes pre-change. Fix: tie the count to the NEW pointer line (e.g. `grep -c 'PM Bridge' README.md ≥ 2` post-change, or assert pointer-line presence verbatim).

### S-P1-5 — FR1 leaves footer (:504) and H1 (:1) outside D2/D3
- Evidence: R1a/R1b fix headline + insert pointer, but README:504 `Welcome to TAD v2.44.1 - Verified Orchestration…` keeps the stale bundle narrative (D2 partial), and README:1 `# TAD Method - Triangle Agent Development` lacks the `Two-Agent Quality Framework` half of hybrid-c (D3 partial). Fix: extend FR1 with R1d footer rewrite (patch-honest, mirror headline) and either bring H1 to canon or record an explicit D3-carve-out for H1 with rationale.

### S-P1-6 — R2 reviewer still pending (process gate, not a design defect)
- Evidence: `.tad/evidence/reviews/alex/public-facade-cleanup/` did not exist before this review; this file is R1. Per DESIGN §9 + Express principle (`.tad/project-knowledge/principles.md`: "Express … MUST NOT skip expert review"), Gate 2 PASS requires the second review + P0 re-verification.

## MQ1–MQ6 evidence check

- MQ1 ✓ — prior art on disk: `.tad/archive/handoffs/COMPLETION-20260904-publish-v2440-bundle-FINAL.md` exists; `release-runbook/references/publish-ops.md` exists. "Follow prior-art shape, no new mechanism" is a sound reuse claim.
- MQ2 ✓ — `gh 2.46.0` at `/usr/bin/gh` verified; externals list is complete for the 4 writes; no repo-internal functions claimed.
- MQ3 ✓ — N/A correctly claimed (derived Release strings only).
- MQ4 ✓ — old vs new headline states + distinguish rule (version + `PM Bridge` noun; bundle retained in body) stated; carriers are README:3 + new pointer line.
- MQ5 ✓ — tag SHAs verified against origin (`v2.44.0^{}` = `40cf3234…`, `v2.44.1^{}` = `83e835d8…`, matches DESIGN); `gh release view v2.44.0/v2.44.1` → "release not found" (create-path legal); `.tad/version.txt` = `2.44.1`; Latest today = v2.43.0 (facade 2-behind claim holds).
- MQ6 ⚠ — acceptable judgment with thin evidence (`gh help` only, no citations); no newer alternative exists for Release objects — pass with note.

## AC runnability (FAIL-today / PASS-after)

| AC | Today | After | Ruling |
|---|---|---|---|
| AC1 release targets | FAIL (not found) | PASS | runnable ✓ |
| AC2 headline+anchors | FAIL (bundle headline) / anchors local-only | PASS | runnable, weaken anchor half → S-P1-2 |
| AC3 package+repo-desc | package half PASSES today | PASS | half-theater → S-P1-1 |
| AC4 Latest + v2.43.0 untouched (hash `f05bbaff…` recorded) | FAIL (Latest=v2.43.0) | PASS | runnable ✓ |
| AC5 zero-touch | false-FAIL (dirty tree) | PASS iff scoped | needs pathspec → S-P1-3 |
| AC6 honesty grep | PASSES today (wrong pattern) | PASS | theater → S-P0-2; count vacuous → S-P1-4 |

## Gate-2 conditions

1. Fix S-P0-1 (retitle v2.44.0 Release) and S-P0-2 (AC6 pattern + footer coverage; extend FR1 R1d).
2. Disposition S-P1-1…S-P1-5 (reword AC2/AC3/AC5/AC6; H1 carve-out or fix).
3. Land R2 expert review; re-verify P0s before Gate 2 PASS. No handoff to Blake until then.
