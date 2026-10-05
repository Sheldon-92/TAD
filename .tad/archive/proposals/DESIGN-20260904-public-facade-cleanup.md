# DESIGN-20260904-public-facade-cleanup (Express)

**Date:** 2026-09-04 · **Author:** Alex · **Path:** Express (human-picked)
**Task ID:** TASK-20260904-FACADE · **Gate 1:** PASS (single Socratic round sufficed — all 5 Qs answered decisively)

## 0. Human decisions (locked, 2026-09-04)

| # | Decision | Value |
|---|----------|-------|
| D1 | Release story | Create **both** missing Release objects: v2.44.0 (bundle) + v2.44.1 (patch, becomes Latest). Old Releases untouched |
| D2 | README headline | Patch-honest: 2.44.1 headline names the PM Bridge patch; bundle narrative moves to body/section |
| D3 | Naming canon | Hybrid (c): `Triangle Agent Development — Two-Agent Quality Framework` everywhere in scope |
| D4 | Old Releases | No edit / hide / delete. Only the two missing Releases are written |
| D5 | Scope | README.md + package.json + GitHub repo metadata + Release objects only. NO config.yaml / CLAUDE.md / AGENTS.md / hooks / templates / Gate logic |
| D6 | Path | Express. 2 expert reviewers pre-handoff (not exempt). No e2e. Blake does build/test-equivalent (gh read-only verifies + grep gates) |

**Hard constraints:** backward-compatible only; Gate semantics untouched; PM Bridge behavior untouched (advisory-only template section stays byte-identical).

## 1. Problem (verified)

- P1: tags `v2.44.0` (peeled `40cf3234`) + `v2.44.1` (peeled `83e835d8`) exist on `origin`, but `gh release view v2.44.0/v2.44.1` → "release not found". `gh release list` Latest = v2.43.0 (title `TAD v2.43.0 — Verified Orchestration, Capability Builder, and Local Wiki Capture`, published 2026-09-02). Public facade understates the tree by 2 releases.
- P2: `README.md:3` on v2.44.1 reads `**Version 2.44.1 - Verified Orchestration, Capability Builder, and Local Wiki Capture**` — the 2.43.0/2.44.0 bundle story. Actual 2.44.1 delta (CHANGELOG `[2.44.1]`): optional PM Bridge on completion template only. `git diff v2.44.0..v2.44.1 -- README.md` = version-number bump only.
- P3: naming split — README `# TAD Method - Triangle Agent Development` vs `gh repo view` desc `TAD Method — Two-Agent Quality Framework…` vs `package.json` desc `Triangle Agent Development - Two-Agent Quality Framework…`.
- P4 (non-problem, recorded): older Releases are NOT empty (spot-checked v2.31.1/v2.32.0/v2.35.0/v2.40.0/v2.42.0 — all have bodies). Noise shape = ~12 Releases stamped same minute 2026-08-15. Per D4: leave untouched.

## 2. MQ1–MQ6 (evidence)

- **MQ1 (historical):** searched, not built. Prior art: `COMPLETION-20260904-publish-v2440-bundle-FINAL.md` (v2.44.0 bundle publish precedent), `release-runbook` skill (`publish-ops.md` = detect/write separation). Reuse: `gh release create` pattern + detect-only verify. Decision: follow prior-art shape (Release per tag, notes link CHANGELOG section), no new mechanism.
- **MQ2 (functions):** externals invoked: `gh release view/create/edit` (verified: `gh 2.46.0` at `/usr/bin/gh`), `gh repo view/edit`, `git ls-remote --tags`, `git rev-parse`. No repo-internal functions called. README/package.json edits are literal text replacements below.
- **MQ3 (data flow):** N/A — no backend/frontend data. Only derived strings (Release body cites CHANGELOG section + tag SHA).
- **MQ4 (visual):** README headline is user-visible. States: old (bundle story on patch version) vs new (patch-honest + bundle pointer). Distinguish: version number + patch noun (`PM Bridge`) in headline; bundle story retained in `## Version history`/body, not deleted.
- **MQ5 (state sync):** sources of truth — tags (immutable, already on origin) > Release objects (derived, to create) > README/package.json text (derived, to edit). Sync rule: Release `tagName` MUST equal existing tag; `--target` MUST equal peeled SHA; README/package version MUST equal `.tad/version.txt` (`2.44.1`, verified `cat`). No new state introduced.
- **MQ6 (research):** `gh help release create` + `gh help repo edit` are the only APIs used; flags below dry-ran read-only (`view`, `ls-remote`). No newer alternative (GitHub Releases is the single facade surface).

## 3. Changes (exact, Express scope)

### FR1 — README.md (4 edits)
- R1a headline `**Version 2.44.1 - …**` →
  `**Version 2.44.1 — Optional PM Bridge (patch on the v2.44.0 bundle)**`
- R1b after headline insert one pointer line:
  `> v2.44.0 bundle: Capability Builder Evolve + Packaging, Installer Data-Safety (+ v2.43.1 trio) — see [CHANGELOG](CHANGELOG.md#2440---2026-09-04). This patch adds only the optional completion-template PM Bridge — see [CHANGELOG](CHANGELOG.md#2441---2026-09-04).`
- R1c (naming, hybrid): ensure the philosophy section carries the full hybrid once: `Triangle Agent Development (Two-Agent Quality Framework)` — minimal single-line touch, no prose rewrite.
- R1d footer (`**Welcome to TAD v2.44.1 - …**`, :504) → patch-honest mirror of R1a:
  `**Welcome to TAD v2.44.1 — Optional PM Bridge (patch on the v2.44.0 bundle)**`
- H1 carve-out (explicit): `# TAD Method - Triangle Agent Development` (:1) stays UNCHANGED — short brand title; hybrid-c canon is enforced at first body mention (R1c) + package.json + repo desc. Rationale: H1 is a brand mark, not a descriptive sentence; forcing the parenthetical into the H1 buys zero disambiguation (S-P1-5 waived for H1, fixed for footer).
- Verify anchors: CHANGELOG headers are `## [2.44.1] - 2026-09-04` / `## [2.44.0] - 2026-09-04` → GitHub auto-anchors `#2441---2026-09-04` / `#2440---2026-09-04`. Blake MUST confirm anchors resolve before commit (AC2).

### FR2 — package.json (1 edit)
- `description`: `Triangle Agent Development - Two-Agent Quality Framework for AI-assisted development` — already hybrid-correct. Blake verifies byte-equality; edit only if drifted. (Canon string pinned in AC3.)

### FR3 — GitHub repo metadata (gh, reversible)
- `gh repo edit --description "TAD Method — Triangle Agent Development (Two-Agent Quality Framework): Design (Alex) + Execute (Blake) + 4-Gate quality system + 25 capability packs."` (hybrid-c, ≤350 chars).
- Homepage/topics unchanged. Old Releases untouched (D4).

### FR4 — Two missing Releases (gh, additive only, DRAFT-FIRST — R-P0-1)
Per Release, two steps: (1) create as **draft**, (2) human confirms draft renders, (3) publish via `gh release edit <tag> --draft=false`. Blake MUST NOT publish live on first write. Mandate carries this sequence, not just titles.
- `gh release create v2.44.0 --target 40cf3234ade45a5ef1fdf0afc729b2537347a1ca --verify-tag --draft --title "TAD v2.44.0 — Capability Builder Evolve + Packaging, Installer Data-Safety (+ v2.43.1 trio)" --notes-file <body-v2440.md>` (body: 3 CHANGELOG-faithful bullets + link `#2440---2026-09-04` + pointer "patch v2.44.1 follows"). NO `--latest` flag (stays non-Latest). Title wording fixed per S-P0-1: "Verified Orchestration" is the v2.43.0 story (`grep -c` in CHANGELOG == 0) and MUST NOT headline v2.44.0.
- `gh release create v2.44.1 --target 83e835d8dfcdd78465d2757253d38001e308b5a5 --verify-tag --draft --latest --title "TAD v2.44.1 — Optional PM Bridge (patch)" --notes-file <body-v2441.md>` (body: PM Bridge advisory-only paragraph + no-migration notes + link `#2441---2026-09-04`). `--latest` explicit (R-P1-4); creation ORDER: v2.44.0 first, v2.44.1 second, so Latest lands on v2.44.1 deterministically.
- Preconditions (BLOCKING): `git ls-remote` peeled SHAs match the full SHAs above; `gh release view` confirms absence for BOTH tags (no overwrite path exercised); bodies contain no secrets; each body bullet cites its CHANGELOG subsection.

## 4. Non-goals (explicit)
- No Gate/hook/handoff-template/evidence-path edits. No PM Bridge template change. No old-Release edits/deletes. No config.yaml/CLAUDE.md/AGENTS.md sweep (separate design single if wanted).

## 5. ACs (runnable, dry-ran by Alex — see §7)
- AC1: `gh release view v2.44.0 --json tagName,targetCommitish` → target == `40cf3234…`; v2.44.1 target == `83e835d8…`.
- AC2: README headline grep == R1a string; CHANGELOG anchors: local `grep -c '^## \[2\.44' CHANGELOG.md` == 2 AND human click-through of both anchors on the DRAFT v2.44.1 Release page (draft-first renders notes with links — R-P1-2/S-P1-2 resolution check); fallback trigger: if either anchor 404s at draft review, Blake replaces that link with the bare section link before publish.
- AC3: `node -e "console.log(require('./package.json').description)"` MUST still equal the canon hybrid string post-run (drift-guard; passes today by design — S-P1-1); `gh repo view --json description` MUST contain both `Triangle` and `Two-Agent` (change-proof; fails today).
- AC4: `gh release list` shows v2.44.1 Latest; `v2.43.0` Release body byte-identical pre/post: Blake re-captures `gh release view v2.43.0 --json body -q .body | sha256sum` immediately pre-write and embeds pre+post hashes in completion evidence (reviewer baseline 2026-09-04: `d3af1fff…1b0c6c`; Blake's own pre-hash governs — R-P1-6).
- AC5: zero-touch scoped to this single's pathspec (tree is dirty from sibling tracks — R-P0-3): `git status --porcelain -- README.md package.json` shows at most those two files; `git diff --name-only | grep -cE 'tad/templates/completion-report|(^|/)gate[^/]*|(^|/)hook' ` == 0 (no Gate/hook/template/PM-Bridge-template writes).
- AC6 (rewritten — R-P0-4/S-P0-2/S-P1-4): stale pattern is `2.44.1 - Verified Orchestration` (present 2× today: :3 and :504 — verified). Post-change `grep -rn '2\.44\.1 - Verified Orchestration' README.md` == 0 AND `grep -c 'Optional PM Bridge' README.md` ≥ 2 (headline R1a + footer R1d + pointer R1b = 3 expected).
- AC7 (new — R-P1-1): post-change `grep -c 'Two-Agent Quality Framework' README.md` ≥ 1 (pre-change value 0 — verified non-theater).

## 6. Risks
- R1 `gh release create` is public-write (irreversible-ish; deletable but noisy). Mitigation: precondition checks + `--draft` first, human confirms draft renders, then publish. Mandate carries exact tag/target/title.
- R2 GitHub anchor slug mismatch → dead links. Mitigation: AC2 anchor check; fallback: link `#changelog` section without anchor.
- R3 Concurrent-terminal index riders (known repo shape: shared index, other tracks active). Mitigation: pathspec-scoped commits (`git commit -- README.md package.json`).

## 7. AC dry-run (Alex, pre-handoff — all read-only)
```
$ gh release view v2.44.0 --json tagName  → "release not found" (absence confirmed, create path legal)
$ gh release view v2.44.1 --json tagName  → "release not found" (absence confirmed, create path legal)
$ git ls-remote --tags origin | grep -E '2\.44\.[01]' → both tags + peeled SHAs present
$ head -3 README.md → bundle headline on 2.44.1 (P2 confirmed)
$ node -e "console.log(require('./package.json').description)" → hybrid already (FR2 = verify-only likely)
$ grep -c '^## \[2\.44' CHANGELOG.md → 2 (both sections exist as Release-body sources)
```
All AC commands are `view/list/grep/cat` (read-only) except the writes: 2 file edits + 1 repo-edit + 2 draft-creates + 2 draft-publishes (publish step executes ONLY after human draft-render approval — R-P0-1).

## 8. Friction preflight (§8.4)
- Requires: `gh` auth (`gh auth status`), network to api.github.com, human approval for public writes (mandate). If `gh` unauthed → BLOCKED (Blake stops, no downgrade to "edit files only and call it done" — that would ship half the facade).
- Reviewers: 2 pre-handoff (this file's §9). Express does NOT exempt review.

## 9. Expert review (record)
- R1 release-ops: `.tad/evidence/reviews/alex/public-facade-cleanup/release-reviewer.md` — CONDITIONAL (4 P0 + 6 P1).
- R2 spec-compliance: `…/spec-compliance.md` — CONDITIONAL (2 P0 + 6 P1).
- Re-review (P0-only): `…/rereview-p0.md` — **PASS** (all 6 P0 fixes verified; cosmetic L84 fixed at sign-off).
- Gate 2: PASS (see HANDOFF-20260904-public-facade-cleanup.md §Gate 2).
