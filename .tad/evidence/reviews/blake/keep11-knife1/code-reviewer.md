# Code Review — impl commit 63cf6291 (KEEP11 knife 1 CLI/SHA refresh)

- Commit: `63cf6291` — "feat(packs): KEEP11 knife 1 CLI/SHA refresh for code-security + web-deployment (TASK-20260911-KEEP11-KNIFE1)"
- Reviewer: TAD Layer 2 code-reviewer (narrow scope: diff correctness only — no redesign, no UX/perf)
- Date (UTC): 2026-09-11
- Method: `git show 63cf6291 --stat` + full diff read (1742 lines, 41 files), `git grep` on new tree, `cmp` twin checks, live web spot-checks.

## Scope containment

- 41 files changed, all inside exactly three intended roots:
  - `.claude/skills/{code-security,web-deployment}/` (14 files)
  - `.agents/skills/{code-security,web-deployment}/` (14 files)
  - `.tad/capability-packs/{code-security,web-deployment}/` (13 files: 12 references + `web-deployment/CAPABILITY.md`)
- Verified: `git diff 63cf6291^..63cf6291 --name-only` filtered against the three intended dir prefixes returns **CLEAN** (no other paths).
- No hooks/loaders/version files: no match for `.tad/hooks`, `hooks.json`, `find-action-sha`, `verify-deploy`, `REGISTRY`, `VERSION`, `CHANGELOG`, `package.json`, loader. No other packs touched (no `skills/` path outside `code-security|web-deployment|_archived`).
- Out-of-scope residue correctly untouched: `.claude/skills/_archived/security-checklist.md:187` and `.agents/skills/_archived/security-checklist.md:187` still contain `--only-verified` — archived file, not in commit, correctly left alone.

## Diff correctness (frontmatter/SHA/hunks/twins with file:line)

All `file:line` below refer to the NEW tree (`git show 63cf6291:<path>`).

### 1. Banner placement (must NOT be inside YAML frontmatter) — PASS

- `.claude/skills/code-security/SKILL.md`: frontmatter `---` lines 1–6, banner at line **12** (after `# Code Security Capability Pack` at 11). PASS.
- `.claude/skills/web-deployment/SKILL.md`: frontmatter lines 1–6, banner at line **12**. PASS.
- `.agents/skills/code-security/SKILL.md:12`, `.agents/skills/web-deployment/SKILL.md:12` — identical, PASS.
- All 12 reference-file banners sit at line **3**, immediately after the `# Title` + capability comment (lines 1–2), never inside frontmatter (reference files have no frontmatter). PASS.

### 2. SHA replacement limited to intended checkout pair (b4ffde65→692973e3) — PASS

- `git grep b4ffde65 63cf6291 -- .claude/skills .agents/skills .tad/capability-packs` → **NONE** (zero residual).
- New SHA present exactly where expected (6 files): `.claude/skills/web-deployment/SKILL.md:12,77`; `.claude/skills/web-deployment/references/ci-cd-pipeline-rules.md:3,64,183,190,197`; identical mirrors under `.agents/…`; `.tad/capability-packs/web-deployment/CAPABILITY.md:67`; `.tad/capability-packs/web-deployment/references/ci-cd-pipeline-rules.md` (5 hits).
- Companion pin untouched: `actions/setup-node@1e60f620…` appears only as context (3 occurrences in diff), never modified. PASS — no SHA drift beyond the intended pair.
- CI6 wording change (`.claude/skills/web-deployment/references/ci-cd-pipeline-rules.md:14`: `actions/cache@v4` → "pinned to the current v4-line SHA") is a deliberate de-hardcoding consistent with the new "SHAs rot, re-resolve" warning; no concrete SHA introduced. Observation only, not a finding.

### 3. Flag fixes — PASS

- TruffleHog: all 7 executable `--only-verified` occurrences replaced with `--results=verified` (`.claude/skills/code-security/references/secret-detection-rules.md:20,110,126,133,136,139,142` + triage line ~230 area mirrored). Remaining `--only-verified` mentions are historical prose inside the rename banner (lines 5–6) — intentional. `git diff` shows 27 `-`-lines for the flag, all removals; zero executable residuals.
- flyctl: `flyctl certs show` → `flyctl certs check` (`.claude/skills/web-deployment/references/domain-dns-rules.md:54`); remaining `certs show` mentions are historical prose in the banner (line 3). PASS.
- Deadline: fixed calendar date `2026-05-20` → relative wording (`.claude/skills/code-security/references/vulnerability-triage-rules.md:192`). PASS.

### 4. Twin byte-identity — PASS

- `.claude/skills/…` vs `.agents/skills/…`: all **14/14 pairs IDENTICAL** via `cmp` (both SKILL.md + all 12 references + 6/6 code-security + 8/8 web-deployment).
- `.claude/skills/…` references vs `.tad/capability-packs/…` references: all **12/12 IDENTICAL** via `cmp`.
- (First twin-loop attempt reported false DIFFs due to a bad `git show … -` invocation; re-run with clean redirection confirms identical. Noted for transparency.)

### 5. Hunk discipline (no essay rewrites) — PASS with explanation

- Small hunks (banners, version tokens, flag/SHA/deadline swaps, retrieval-date bumps `2026-06-13`→`2026-09-11`) are the knife-1 scope. PASS.
- Large hunks exist ONLY under `.tad/capability-packs/` (e.g. `web-deployment/references/ci-cd-pipeline-rules.md` CI9–CI13 +106 lines; `monitoring-rules.md` MO3/MO8; `code-security/references/sast-rules.md` S3/S4; `vulnerability-triage-rules.md` V1/V7). Measured cause: **SSOT convergence, not new essays** — parent-tree `.claude/.../ci-cd-pipeline-rules.md` already contained 22 matches for `CI9|…|zizmor|upload-artifact@v3` and the S3 baseline phrase, while parent `.tad/…` had 0. Post-commit `.claude` == `.tad` byte-identical, matching the commit message (".claude SSOT mirrored to .agents + capability-packs"). No novel prose invented beyond the refresh.

## Version spot-checks

Web-verified just now; "CONFIRMED" = live source evidence, "UNCONFIRMED" = no supporting source found (flagged below, P1 only — no P0 without counter-evidence per brief).

| Token in pack | Live evidence | Result |
|---|---|---|
| semgrep v1.176.0 (2026-09-01) | PyPI + release-alert (Sep 1 2026) + Homebrew stable 1.176.0 | CONFIRMED |
| nuclei v3.11.1 (2026-08-08) | pkg.go.dev + Docker tags + Kali tracker + whatsnew | CONFIRMED |
| osv-scanner v2.5.1 (2026-08-17) | pkg.go.dev (published Aug 17 2026) + GH releases + Arch | CONFIRMED |
| trivy v0.74.0 (2026-08-14) | GH releases (immutable release Aug 14) + CHANGELOG | CONFIRMED |
| grype v0.118.0 | pkg.go.dev (Aug 27 2026) + snap latest/stable + Docker | CONFIRMED |
| checkov 3.3.16 (2026-08-30) | PyPI (Aug 30 2026) + CHANGELOG `3.3.16 - 2026-08-30` | CONFIRMED |
| zizmor v1.30.0 | PyPI + conda-forge + Arch (Aug 30 2026) + release notes | CONFIRMED |
| trufflehog v3.97.4 | pkg.go.dev (published Sep 3 2026) | CONFIRMED (GH releases page snippet lagged at v3.97.2 — index lag, not counter-evidence) |
| `--only-verified` → `--results=verified` | Upstream `main.go`: `--only-verified` is now `.Hidden()` alias mapping to `results="verified"`; all current docs use `--results=verified` | CONFIRMED directionally (see P1-2 on "GONE" wording) |
| `flyctl certs show` → `certs check` | fly.io docs list `certs` subcommands: add / check / import / list / remove / setup — no `show` | CONFIRMED |
| flyctl v0.4.99 | pkg.go.dev (Sep 3 2026) + AUR 0.4.99-1 + Docker `v0.4.99` | CONFIRMED |
| gitleaks 8.30.1 | release-alert latest v8.30.1 (Mar 12 2026); Debian/Alpine confirm | CONFIRMED |
| vercel 59.10.0 | npm (published Aug 29 2026) + Snyk version history | CONFIRMED existed (now superseded by 59.11.x — benign staleness, no finding) |
| netlify v27.5.2 | NOT found: Snyk lists latest **27.5.0** (Sep 4 2026) with history 27.5.0/27.4.3/27.4.2/… — no 27.5.2 in any source | UNCONFIRMED → P1-1 |

## Findings

**P0: none (0).** No counter-evidence against any blocking claim; frontmatter, SHA scope, flag replacements, and twin identity all measure clean.

**P1 (2, non-blocking):**

- **P1-1 — Unconfirmed version token: Netlify CLI `v27.5.2`.** Main source (Snyk package history, updated Sep 2026) shows latest `27.5.0` with no `27.5.2` in the version list; npm mirrors show older (26.0.2/27.0.1/27.1.1) due to caching. A `27.5.2` released Sep 5–11 cannot be ruled out, so this is not P0, but the token should be re-resolved and either confirmed or corrected to the newest confirmed (`27.5.0`). Affected banners: `.claude|agents/skills/web-deployment/references/domain-dns-rules.md:3`, `platform-selection-rules.md:3` (and `.tad` twins, same lines).
- **P1-2 — Banner overstates TruffleHog rename ("is likewise GONE").** Upstream `main.go` keeps `--only-verified` as a `.Hidden()` alias that maps to `--results=verified`, so old invocations still parse rather than hard-fail. The migration guidance (use `--results=verified`) is correct and all executable occurrences were fixed, so functionality is unaffected — suggest softening to "deprecated/hidden alias — use `--results=verified`" in `secret-detection-rules.md:5-6` (×3 mirrors).

## Verdict

**APPROVE** — commit 63cf6291 is a clean, in-scope knife-1 refresh: banners correctly placed outside frontmatter, SHA swap fully contained to the `b4ffde65→692973e3` checkout pair with zero residuals, both CLI flag fixes verified against upstream, all 14 `.claude`↔`.agents` twins and 12 `.claude`↔`.tad` reference pairs byte-identical, no frozen packs/loaders/hooks/version files touched, and all version tokens confirmed except one unconfirmed Netlify patch number. **P0: 0, P1: 2.** No pack code modified by this review.
