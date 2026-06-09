# Spec Compliance Review: Codex Native Runtime Policy (Phase 2)

**Reviewer**: spec-compliance-reviewer (Claude Opus 4.6)
**Date**: 2026-06-09
**Handoff**: HANDOFF-20260609-codex-native-runtime-policy.md
**Section**: 9.1 Spec Compliance Checklist (18 ACs)

---

## AC Verification Table

| AC# | Criterion | Status | Evidence |
|-----|-----------|--------|----------|
| 1 | Policy doc exists at `.tad/evidence/designs/codex-native-runtime-policy.md` | SATISFIED | File exists (325 lines, created 2026-06-09). Path matches handoff requirement exactly. |
| 2 | Policy doc contains all 15 required sections | SATISFIED | Title `# Codex Native Runtime Policy` (1) + 14 `##` sections = 15 total. All match handoff 4.2 list: YAML Summary, Source Refresh, Current Project State, Project-Owned vs User-Owned Boundary, Config Policy, Sandbox / Approval / Profile Policy, Hooks Policy, MCP Policy, Custom Agents Evaluation, Draft Candidate Files, Security Review, Activation Criteria, Phase 3 and Phase 4 Inputs, Risks and Unknowns. |
| 3 | YAML Summary declares `active_runtime_changes: false` | SATISFIED | Line 15: `active_runtime_changes: false`. Additionally `active_config_written: false` and `active_agents_written: false` on lines 24-25. |
| 4 | Current Codex source refreshed or official fallback used | SATISFIED | Source Refresh section (line 31-33): manual fetched 2026-06-09 via `fetch-codex-manual.mjs`, Codex CLI 0.137.0, 11935 lines. Explicit provenance with date, method, and version. |
| 5 | Current `.codex/` project state recorded before edits | SATISFIED | Current Project State section (lines 47-57): table shows `.codex/hooks.json` exists (4 hooks), `config.toml` does not exist, `agents/` does not exist. Also records AGENTS.md, `.agents/skills/`, and trust status. |
| 6 | Project-owned vs user-owned matrix covers all required surfaces | SATISFIED | Boundary matrix (lines 62-77) contains exactly 14 rows covering all surfaces required by handoff 4.4: model defaults, reasoning effort, sandbox filesystem, network permissions, approval policy, MCP server definitions, MCP credentials/env, hooks, custom agents, rules, secrets/tokens, user profile defaults, machine-specific paths, cloud environment vars. Each row has Project-Owned?, User-Owned?, Commit to Repo?, Rationale, and Example columns. |
| 7 | Config policy excludes secrets/auth/account IDs/personal paths | SATISFIED | Config Policy "What Is NOT in Project Config" section (lines 109-115) explicitly excludes provider config, network domain rules, log directory, personality/TUI, cloud/remote. MQ4 answer (lines 79-85) lists forbidden content: API keys, OAuth tokens, bearer tokens, session tokens, account IDs, email addresses, personal paths, cloud secrets. Draft config.toml.draft grep confirms: only comment references to forbidden items (lines 51-53 are `# - ...` instructions), zero actual secrets or personal paths. |
| 8 | Sandbox/approval/profile policy aligns with TAD quality/safety needs | SATISFIED | Sandbox section (lines 119-147): `workspace-write` (allows TAD evidence+code writes without full-access risk), `approval_policy = "on-request"` (not `never`), notes `.git`/`.codex` auto-protected. Optional stricter profile documented. Gate pre-check compatibility addressed (bash scripts work under workspace-write + on-request). |
| 9 | Hooks policy assesses current `.codex/hooks.json` | SATISFIED | Hooks Policy section (lines 150-174): 4-row table documenting each hook (startup-health.sh, notebook-dormant-sync.sh, post-write-sync.sh, askuser-capture.sh) with event, purpose, and status. 5 numbered policy decisions covering: hooks.json as source of truth, trust review, timeouts, failure mode (citing principles.md), and `ask_user_question` matcher unknown behavior. |
| 10 | MCP policy separates server definitions from credentials/env | SATISFIED | MCP Policy section (lines 177-195): Credential Separation subsection (lines 188-191) explicitly separates definitions (command, args, URL = project-safe) from `bearer_token_env_var`, `env` secrets, and OAuth tokens (must be in user config). Table categorizes no-auth MCP as project-scoped, auth-required as user-scoped. |
| 11 | Custom-agent evaluation includes all 8 required roles | SATISFIED | Custom Agents Evaluation section (lines 199-224): Role Decisions table covers all 8 roles from handoff 4.5: spec-compliance-reviewer (migrate_draft), code-reviewer (migrate_draft), test-runner (migrate_draft), security-auditor (defer), performance-optimizer (defer), backend-architect (defer), Blake (keep_skill_only), Alex (keep_skill_only). Each has decision + rationale. |
| 12 | Blake and Alex remain `keep_skill_only` | SATISFIED | Role Decisions table explicitly marks Blake as `keep_skill_only` ("Blake's persona, Ralph Loop, execution checklist, completion protocol are all SKILL-body content. Duplicating into TOML `developer_instructions` would fork the protocol.") and Alex as `keep_skill_only` ("Alex's Socratic inquiry, expert review, handoff creation, gate protocols are all SKILL-body content. Same fork risk."). No contrary P1 justification attempted. |
| 13 | Draft candidate config exists under evidence path only | SATISFIED | File exists at `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft` (1879 bytes). Header comment: `# DRAFT ONLY -- not active Codex runtime config`. Not in `.codex/`. |
| 14 | Draft custom-agent files exist under evidence path only | SATISFIED | Three files under `.tad/evidence/designs/codex-runtime-candidates/agents/`: `spec-compliance-reviewer.toml.draft` (1070 bytes), `code-reviewer.toml.draft` (1235 bytes), `test-runner.toml.draft` (1035 bytes). All have `# DRAFT ONLY` headers. None in `.codex/agents/`. |
| 15 | No active `.codex/config.toml` or `.codex/agents/*` files created | SATISFIED | `ls .codex/`: only `hooks.json` exists (pre-existing). `config.toml` does not exist. `agents/` directory does not exist. Verified via filesystem check. |
| 16 | No SKILL, docs, hooks, or AGENTS files modified | SATISFIED | `git diff --name-only HEAD` shows changes only in `.tad.backup.*` (old backup directories, not active files) and new `.tad/evidence/` files. No modifications to any `.agents/skills/*/SKILL.md`, `AGENTS.md`, `.codex/hooks.json`, or `docs/` files. Staged changes confirm the same. |
| 17 | Draft TOML parses or parser-unavailable fallback documented | PARTIALLY_SATISFIED | All 4 TOML files parse successfully via `tomllib`. However, `web_search = "cached"` (config.toml.draft line 48) is placed AFTER the `[agents]` table header (line 26), so TOML assigns it to `agents.web_search` instead of the intended top-level scope. The policy doc's Config Policy table (line 107) describes `web_search` as a top-level setting alongside `model` and `sandbox_mode`, but the draft TOML structurally places it under `[agents]`. This is a minor structural misplacement -- the file parses, but the parsed key path does not match the documented intent. |
| 18 | Activation criteria define what must be true before active runtime config may be written | SATISFIED | Activation Criteria section (lines 273-288): 6 numbered criteria (Phase 3 docs, Phase 4 ledger, Phase 5 regression n>=1, human approval, no P0 quality-chain failures, no secrets in committed files). Includes failure recovery subsection ("What Happens If Activation Criteria Fail") with specific remediation for regression failure, secrets found, and human decline. |

---

## Summary

| Status | Count |
|--------|-------|
| SATISFIED | 17 |
| PARTIALLY_SATISFIED | 1 |
| NOT_SATISFIED | 0 |

### PARTIALLY_SATISFIED Detail

**AC17** (Draft TOML parses): The `web_search = "cached"` key in `config.toml.draft` is syntactically valid TOML but lands under `agents.web_search` due to its placement after the `[agents]` table header. The intent per the policy doc is top-level. Fix: move `web_search = "cached"` above the first `[table]` header (before line 19 `[features]`), or place it in its own `[web]` table if Codex expects that. This does not block acceptance -- the file parses, and the correct placement can be fixed when copying to `.codex/` in Phase 5.

---

## Verdict: **PASS**

NOT_SATISFIED = 0. PARTIALLY_SATISFIED = 1 (within <= 3 threshold).

The Phase 2 deliverables satisfy all 18 acceptance criteria from handoff 9.1. The single PARTIALLY_SATISFIED item (AC17: TOML key scope misplacement) is a minor draft quality issue that does not affect policy correctness and can be corrected in Phase 5 activation.
