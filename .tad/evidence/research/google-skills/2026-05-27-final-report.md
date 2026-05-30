# google/skills — Deep Research Final Report

**Date:** 2026-05-27
**Notebook:** NotebookLM `6669167a-15ff-4b1f-8676-8876bc676445`
**Repo:** github.com/google/skills (10,785★, Apache 2.0)
**Total sources:** 50 (all status: ready)
**Methodology:** *research-plan-style flow with all 3 challenge layers (0c + 4c + 5b)

---

## TL;DR

`google/skills` is Google's official Agent Skills repository for Google Cloud products. It has 24 skills under `skills/cloud/`, each a directory containing at least a `SKILL.md` (mandatory) and optionally `references/*.md`, `scripts/*.py|sh`, and `assets/*.yaml`. The repo is **synced from Google's internal monorepo via Copybara** — public CI is absent, but internal CI quality gates likely exist (just not visible).

**Critical finding (refined after challenge):** Patterns we initially identified as "Google standards" (Tier R/M/D safety, Phase 0 env init, Workflow Decision Trees) actually appear in only **13-17% of skills**, concentrated in the `agent-platform-*` cluster. They are **emerging conventions, not enforced repo-wide standards**.

**Only 1 AC survived adversarial review as STRONG: minimum SKILL.md frontmatter is `name` + `description` (100% coverage)**. All other patterns are WEAK (6 ACs) or UNSUPPORTED (6 ACs) at the evidence-strength level demanded by Codex/Gemini critics.

---

## Repository Facts (no adversarial dispute)

- **Structure:** 24 skill directories under `skills/cloud/` (only category — no workspace/AI/consumer)
- **Total files:** 122 (106 .md, 7 .py, 5 .yaml assets, 2 requirements.txt, 1 .sh)
- **No public CI:** No `.github/workflows/`, no test files
- **Internal source:** Confirmed Copybara sync (contributor `cloud-ix-copybara`)
- **License:** Apache 2.0
- **Public contributions:** NOT accepted ("repository does not accept external pull requests" per CONTRIBUTING.md)
- **Skill registry runtime:** REAL — REST API at `https://{region}-aiplatform.googleapis.com/v1beta1/projects/{project}/locations/{location}/skills` with PATCH/updateMask support and revisions endpoint

## Pattern Coverage Statistics (whole-repo)

| Pattern | Coverage | Skills |
|---------|----------|--------|
| SKILL.md frontmatter `name` + `description` | **24/24 (100%)** | All |
| `references/` directory | ~14/24 (58%) | 6 basics + 6 agent-platform + others |
| `scripts/` directory | ~6/24 (25%) | agent-platform-* + deploy |
| `assets/` directory | 1/24 (4%) | gke-basics only |
| Tier R/M/D safety classification | **4/24 (17%)** | agent-platform-* cluster |
| Phase 0 environment initialization | **4/24 (17%)** | agent-platform-* cluster |
| Workflow Decision Trees with STOP/Yield | **3/24 (13%)** | agent-platform-tuning, *-tuning-management, *-rag |
| SDK Deprecation Bans (strict) | 2/24 (8%) | gemini-api, gemini-interactions-api |
| Developer Knowledge MCP fallback | 7/24 (29%) | 6 basics + gemini-api |
| Singular `reference/` typo | 1/24 | google-cloud-recipe-onboarding |

## What's Distinctive (cross-vendor)

1. **MCP-NEUTRAL with Gemini-first marketing:** Skills work in Claude Code + Codex + Gemini CLI (explicit mentions across 3+ skills). The tools (`execute_sql`, `deploy_service_from_image`, GKE's 23 structured tools) are **abstracted skill-specific tools, not thin gcloud wrappers**.
2. **One Google-hosted remote MCP server documented:** `https://alloydb.REGION.rep.googleapis.com/mcp` — managed service pattern.
3. **Universal Developer Knowledge MCP retrieval fallback:** Cross-skill RAG mechanism (`search_documents`, `get_document`) — implementation NOT public.
4. **Script-as-Headless-API design intent:** Scripts execute without interactive confirms; safety contract lives at SKILL.md / AI-agent layer (3 skills explicitly enforce "NEVER pre-emptively execute" before yielding).
5. **One real architectural defect:** `agent-platform-skill-registry/scripts/skill_registry_ops.py` has destructive `requests.delete()` but the corresponding SKILL.md has NO Tier D / typed-confirm directives — violates Google's own script-as-headless-API contract.

## Actionable Items for TAD (Adversarially Reviewed)

### Adopt (STRONG evidence)
- **AC1 — Minimum SKILL.md Frontmatter:** Require `name` + `description`. TAD already complies. Document as cross-vendor compatible minimum (Anthropic + Google + TAD all use these two fields).

### Consider (WEAK evidence — implement when applicable)
- **AC3 — Python Script I/O Contract** (WEAK): For TAD pack scripts: argparse + env var fallback + ADC-style auth + sys.exit(1) on missing input. Caveat: based on only 4 scripts.
- **AC5 — MCP-Neutral Compatibility Statement** (WEAK): Explicitly state Claude Code + Codex + Gemini CLI compatibility for any TAD pack surfacing tools. Caveat: 3/24 coverage; risk of "false compatibility" if not actually tested in all 3 environments.
- **AC6 — Tier R/M/D Safety** (WEAK): For TAD packs orchestrating destructive operations. Caveat: 17% coverage in Google; consider only when destructive ops are a primary concern.
- **AC9 — Explicit SDK/Tool Deprecation Bans** (WEAK): Use negative constraints ("DO NOT use X") to overcome LLM training bias. Caveat: 2-9/24 coverage; mechanism unverified empirically.
- **AC10 — Related Skills text refs** (WEAK): Cross-pack references via body text. Caveat: TAD's CONSUMES/PRODUCES is structurally stronger; don't downgrade.
- **AC12 — Avoid governance-gap defect** (WEAK): Every TAD pack with destructive scripts MUST govern via SKILL.md. Caveat: based on 1 observed defect; principle is sound but not statistical.

### Defer or Avoid (UNSUPPORTED)
- **AC2 — Optional frontmatter fields:** Only 1-2/24 skills use `license` / `version` / `compatibility`. Not enough evidence for TAD adoption.
- **AC4 — updateMask atomic PATCH:** Only 1 script demonstrates this. Pattern is sound architecturally, but research doesn't support generalizing.
- **AC7 — Phase 0 env init section:** 17% coverage with inconsistent naming. Adopt "env check before operations" principle, not specific "Phase 0" naming.
- **AC8 — Decision Trees with STOP/Yield:** 13% coverage. TAD's Socratic Inquiry already serves this purpose. Avoid duplicate mechanism.
- **AC11 — Knowledge MCP retrieval fallback:** Implementation not public. TAD's `*research-notebook` is a functional analog without needing new infra.
- **AC13 — AVOID centralized auth_handler:** Absence-of-evidence ≠ evidence-of-absence. Possibly a Copybara artifact, not architectural choice. Don't conclude TAD should/shouldn't have shared auth based on this.

## TAD ↔ Google Comparison Matrix

| Dimension | TAD Capability Pack | Google Skill | Verdict |
|-----------|---------------------|--------------|---------|
| Metadata format | `name` + `description` + custom | `name` + `description` + (optional) | **COMPATIBLE minimum** |
| Loading flow | install.sh → filesystem + pack-registry.yaml | Copy + REST API register | **TAD = filesystem-only; Google = registry-backed** |
| State management | Optional session.json | Stateless (state in GCP resources) | **Mostly compatible** |
| Script execution | Per-pack | Per-skill scripts/ | **Compatible** |
| Security model | Gate 4 + project-knowledge + cognitive firewall | Tier R/M/D in SKILL.md (17% only) + agent-layer | **TAD covers more, more consistently** |
| Templating | install.sh per pack | Agent-prompt-driven generate-skill.md | **Different approaches** |
| Versioning | Pack version in pack-registry.yaml | `/revisions/{id}` runtime endpoint | **TAD = file-based; Google = runtime** |

## Top 3 Borrowable Patterns (Q9 deliverable — post-adversarial)

After conservative review, only AC1 is fully supported. The "top 3" candidates from Phase 4 (Tier R/M/D, Phase 0, Decision Trees) were marked WEAK or UNSUPPORTED.

If we still must pick 3 for experimental adoption with low cost:
1. **AC1 (STRONG):** Already aligned — formalize as cross-vendor compatible minimum
2. **AC9 (WEAK):** Explicit deprecation bans — low cost, applicable when target tools have legacy versions
3. **AC12 (WEAK):** Avoid the governance-gap defect — defensive principle, no new mechanism needed (TAD already does this via Gate 4)

## Top 2 to Avoid

1. **AC12 / Anti-pattern equivalent:** Don't ship destructive scripts without SKILL.md-level governance contract
2. **AC13 ANTI-pattern caution:** Don't conclude "Google doesn't have X → TAD shouldn't have X". Absence-of-evidence reasoning.

---

## Out-of-Scope Limitations (Honestly Documented)

What this research CANNOT answer (would require empirical data):

1. **Real-world bypass rates** of Google's prompt-only safety (Tier D typed-confirm) when an agent encounters destructive commands
2. **Token cost / context window pressure** when loading large SKILL.md + 6 references files
3. **Cross-vendor execution validation** — whether skills actually run successfully in Claude Code, Codex, AND Gemini CLI (only documentation compatibility verified)
4. **Internal Google CI quality gates** — Copybara contributor proves internal source exists, but internal CI details are not public
5. **Adoption rate of these patterns** in third-party Google product wrappers (Google doesn't accept external PRs to this repo)

For TAD evolution decisions, treat all WEAK/UNSUPPORTED ACs as **hypotheses to validate via small TAD pilots**, not as proven best practices.

---

## Research Process Audit Trail

| Phase | Output | Status |
|-------|--------|--------|
| Phase 0 (plan) | `2026-05-27-research-plan.md` (v1 → v2 after challenge) | ✅ |
| Phase 0c | `challenge-plan-{codex,gemini}.md` | Codex INSUFFICIENT, Gemini ADEQUATE; refined 9→13 questions |
| Phase 1 (sourcing) | 50 sources added to NotebookLM | ✅ |
| Phase 2 (curate) | All 50 sources `ready`, no errors, no dups | ✅ |
| Phase 3 (baseline) | `2026-05-27-baseline-report.md` (NotebookLM briefing doc) | ✅ |
| Phase 4 (seeds) | `2026-05-27-ask-findings.md` (3 original + 1 adaptive seed) | ✅ |
| Phase 4c r1 | `challenge-findings-r1-{codex,gemini}.md` | BOTH INSUFFICIENT |
| Phase 4c r2 | `challenge-findings-r2-{codex,gemini}.md` + 2 re-asks | BOTH INSUFFICIENT (MAX rounds); unresolved weaknesses documented |
| Phase 4.5 (papers) | SKIPPED | No academic sources in corpus |
| Phase 5 (extract) | `2026-05-27-extracted-acs.md` (13 ACs) | ✅ |
| Phase 5b | `challenge-actions-{codex,gemini}.md` | Both ADEQUATE; per-AC ratings applied via conservative merge |
| Challenge log | `challenge-log.md` | ✅ all 4 rounds logged |

**Total research time:** ~75 minutes
**Estimated NotebookLM CLI calls:** ~75 (sourcing, asks, re-asks)
**Cross-model challenge invocations:** 8 (4 Codex + 4 Gemini)

---

## File Inventory

```
.tad/evidence/research/google-skills/
├── 2026-05-27-research-plan.md            # Phase 0 (v2 after challenge)
├── 2026-05-27-baseline-report.md          # Phase 3 (NotebookLM briefing doc)
├── 2026-05-27-ask-findings.md             # Phase 4 findings + Phase 4c re-asks + unresolved weaknesses
├── 2026-05-27-extracted-acs.md            # Phase 5 actionable items (unlabeled draft)
├── 2026-05-27-final-report.md             # THIS FILE — consolidated + labeled
├── challenge-plan-codex.md                # Phase 0c
├── challenge-plan-gemini.md               # Phase 0c
├── challenge-findings-r1-codex.md         # Phase 4c round 1
├── challenge-findings-r1-gemini.md        # Phase 4c round 1
├── challenge-findings-r2-codex.md         # Phase 4c round 2
├── challenge-findings-r2-gemini.md        # Phase 4c round 2
├── challenge-actions-codex.md             # Phase 5b
├── challenge-actions-gemini.md            # Phase 5b
└── challenge-log.md                       # Audit trail across all challenge rounds
```
