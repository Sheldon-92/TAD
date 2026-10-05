# COMPLETION — TASK-20260911-KEEP11-KNIFE1 (Blake)

**Handoff:** `.tad/active/handoffs/HANDOFF-20260911-keep11-knife1-cli-refresh.md`
**Impl commit:** `63cf6291` (41 files, allow-prefix only, local — no push/tag)
**Date:** 2026-09-11 · **Role:** Blake · **Channel:** opencode
**Gate 3 verdict:** ✅ PASS (P0=0 across 3 Layer-2 reviews)

## What was built

KEEP11 Knife 1: CLI/SHA freshness refresh of `code-security` + `web-deployment` only.
14 dated `Verified against` banners, tool-table version bumps, 2 command-string fixes
(rename class), checkout SHA re-pin, CI6 wording fix, triage deadline fix, retrieval-date
bumps. `.claude` SSOT mirrored byte-identical to `.agents` twins + capability-packs refs.

## Acceptance evidence (handoff §9.1 methods, all exit 0)

| AC | Result | Evidence |
|----|--------|----------|
| AC1 banners ≥2026-09-11 | OK | `missing [] stale []` |
| AC2 claude/agents parity | OK | `drift []` |
| AC3 rotten SHA gone + live SHA present | OK | `old_sha []`, live `692973e3d937129bcbf40652eb9f2f61becf3332` (= `find-action-sha.sh` stdout) |
| AC4 CI6 no `@v4` | OK | `CI6_ok` |
| AC5 `2026-05-20` gone | OK | `stale_deadline []` |
| AC6 pathspec | OK | `extra []`, 41 files ⊆ 6 allow prefixes |
| AC7 forbidden | OK | `forbidden []` |
| AC8 inventory | OK | `inventory_bytes 5691`, names gitleaks + checkout, ABSENT + PATH/http present |
| AC9 cap-pack parity | OK | `cappack_drift []` |

Supporting evidence: `.tad/evidence/acceptance-tests/keep11-knife1/cli-inventory.md`
(evidence only, NOT in impl commit), `find-action-sha.sh` stdout
(`692973e3…` + `uses: actions/checkout@692973e3… # v4.1.7`).

## Command-string fixes (rename class, §4.1 step 3)

1. **TruffleHog `--only-verified` → `--results=verified`** (9 occurrences,
   secret-detection-rules.md ×3 trees). Upstream v3.92.3→v3.97.x docs only document
   `--results=`; `--only-verified` is v3.67-era. Same landmine class as the gitleaks 8.x miss.
2. **`flyctl certs show` → `flyctl certs check`** (domain-dns-rules.md ×3 trees).
   Upstream subcommands are add/check/import/list/remove/setup — no `show`.
3. Verified unchanged (docs-pinned, no edit): `semgrep ci/scan`, `nuclei -u/-update-templates/-as`,
   `checkov -d/-f/--framework/--skip-check`, `trivy fs/image`, `grype <img>/sbom:`,
   `osv-scanner scan source|image`, `gh attestation verify --repo/--owner`
   (https://cli.github.com/manual/gh_attestation_verify), `vercel rollback`
   (https://vercel.com/docs/cli/rollback), `fly deploy/certs/releases`, `zizmor <path>`,
   `gitleaks git/dir/stdin`, `certbot --nginx/renew --dry-run`.

## Version bumps (all from official releases/docs, none from memory)

semgrep v1.163.0→**v1.176.0** (2026-09-01) · nuclei v3.8.0→**v3.11.1** (2026-08-08) ·
osv-scanner v2.3.5→**v2.5.1** (2026-08-17) · banners pin gitleaks **8.30.1**,
trufflehog **v3.97.4**, checkov **3.3.16**, grype **v0.118.0**, trivy **v0.74.0**,
zizmor **v1.30.0**, vercel **59.10.0**, netlify **v27.5.2** (resolved feed-vs-changelog
conflict via github.com/netlify/cli releases page), flyctl **v0.4.99**,
git **2.47.3** (measured), checkout v4.1.7@**692973e3** (live).

## Layer 2 reviews (all PASS-grade, P0=0 — files on disk)

- spec-compliance-reviewer: PASS, P0=0/P1=0 (all 9 ACs re-run green, pathspec + hunk-class clean)
- code-reviewer: APPROVE, P0=0 (frontmatter intact, SHA pair exact, twins identical; versions independently confirmed; 2 P1 advisories: netlify token re-resolve, banner wording)
- security-auditor: CONDITIONAL PASS, P0=0 (no live scans, SHA practice safe with re-resolve caveat, no secrets; 1 P1 advisory: pre-existing SAST `@v4` example synced via FR7 lockstep — next knife)
- Gate 3 verdict: `.tad/evidence/reviews/blake/keep11-knife1/gate3-verdict.md` — PASS (P1s carried, no new impl commit per PM charter: no real P0)

Reviewer P1 notes (non-blocking, recorded for future knives — NOT this-knife defects):
- Pre-existing `actions/checkout@v4` + unpinned `semgrep/semgrep` image in sast-rules.md
  workflow example (present in parent commit; out of FR5 scope which covers the CI6 index only).
- Pre-existing unpinned install verbs (`brew/pip install`, `go install @latest`) across tool tables.
- `_archived/security-checklist.md` still has `--only-verified` (archived = frozen, correctly untouched).

## Implementation Decisions (made during execution)

| # | Decision | Chosen | Escalated? |
|---|----------|--------|------------|
| 1 | TruffleHog flag rename in scope? | Yes — rename class per §4.1 step 3 + §4.2 command lines | No (handoff-authorized) |
| 2 | `flyctl certs show` fix | `certs check` (matches "shows DNS status" comment + upstream) | No |
| 3 | Netlify version conflict (v27.4.2 feed vs 21.4.1 changelog) | v27.5.2 from releases/latest page | No (evidence-recorded) |
| 4 | setup-node/env-config OIDC SHAs, gitleaks pre-commit rev | Leave (FR4 = checkout only; noted in inventory) | No |
| 5 | No Gemini, no installs of scanners | Docs-pin EQUIVALENT_SUBSTITUTE per §8.4 | No (handoff-authorized) |

## Friction Status

| Friction Point | Status | Evidence / Rationale |
|----------------|--------|----------------------|
| Scanner CLIs ABSENT on host | EQUIVALENT_SUBSTITUTE | Official docs URL per tool in cli-inventory.md + banners; no brew/pip installs (per §8.4 default) |
| `git ls-remote` network for SHA | READY | Live output `692973e3…` recorded; matches Alex step1d |
| Host gh 2.46.0 lacks `attestation` | EQUIVALENT_SUBSTITUTE | Docs-pin https://cli.github.com/manual/gh_attestation_verify in banner; command text verified against manual |
| No Gemini (human lock) | NOT_APPLICABLE_WITH_REASON | CLI/docs used as primary fact check per MQ6 |
| Layer 2 reviewers | READY | 3 independent subagent reviews, all PASS P0=0 |
| Dirty unrelated worktree state | NOT_APPLICABLE_WITH_REASON | Pre-existing dirt excluded from impl commit via explicit `git add` (AC6 `extra []` proves) |

## Scope discipline

- Impl commit ⊆ §7.2 pathspec (AC6 verified). No frozen 14, other KEEP 9, loaders,
  experiment-path, version/tag, NEXT.md, handoff, verify.py, or inventory in commit.
- CI2 `@v4` anti-pattern preserved as WRONG example; `examples/cicd-sha-pin-oidc.md` untouched.
- No push/tag. Gate 4 (human acceptance) pending — not this session.

## Paths

- Impl: 41 files under `.claude/skills/{code-security,web-deployment}/`,
  `.agents/skills/{code-security,web-deployment}/`,
  `.tad/capability-packs/{code-security,web-deployment}/` (commit `63cf6291`)
- Evidence: `.tad/evidence/acceptance-tests/keep11-knife1/{verify.py,cli-inventory.md}`
- Layer 2 reviews (Blake): `.tad/evidence/reviews/blake/keep11-knife1/spec-compliance-reviewer.md`,
  `.tad/evidence/reviews/blake/keep11-knife1/code-reviewer.md`,
  `.tad/evidence/reviews/blake/keep11-knife1/security-auditor.md`,
  `.tad/evidence/reviews/blake/keep11-knife1/gate3-verdict.md`
- Gate-2 carriers: `.tad/evidence/reviews/2026-09-11-gate2-keep11-knife1-{code,security}.md`

## Knowledge Assessment

**是否有新发现？** ❌ No

**如果 No：**
- **原因**: Routine CLI/SHA freshness refresh only — version bumps, dated banners, and checkout SHA re-pin are ephemeral and fail the variabilize test; two command-string renames (TruffleHog `--results=`, `flyctl certs check`) are pack-content fixes already landed in the packs themselves, not reusable TAD methodology. No new journal or project-knowledge entry warranted.
