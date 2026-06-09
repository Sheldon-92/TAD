# Code Review: Phase 2 Codex Native Runtime Policy

**Reviewer**: code-reviewer (TAD Layer 2 Group 1)
**Date**: 2026-06-09
**Handoff**: HANDOFF-20260609-codex-native-runtime-policy.md
**Artifacts reviewed**:
- `.tad/evidence/designs/codex-native-runtime-policy.md`
- `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/spec-compliance-reviewer.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/code-reviewer.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/test-runner.toml.draft`

---

## Summary

The Phase 2 artifacts are well-structured, comprehensive, and demonstrate strong security discipline. The policy document covers all 15 required sections, the boundary matrix includes all 14 required surfaces, all 8 role decisions are present, and Alex/Blake are correctly designated `keep_skill_only`. No secrets, credentials, or account-specific values appear in any draft file. All 4 TOML drafts parse successfully via `tomllib`. No active runtime files (`.codex/config.toml`, `.codex/agents/`) were created. The protocol-fork risk is well-managed: agent `developer_instructions` are minimal and do not duplicate SKILL.md content.

---

## Findings

| # | Severity | Location | Finding | Recommendation |
|---|----------|----------|---------|----------------|
| 1 | P2 | policy.md L18 | **Session-local path in YAML summary**. `manual_source` contains `/tmp/claude-501/openai-docs-cache/codex-manual.md` which is a session-local temp path. While `/tmp/` is not a personal home directory and contains no secrets, it is not reproducible across machines or sessions. If this doc is shared or revisited later, the path is meaningless. | Change to a description rather than a path: `manual_source: "local cache via fetch-codex-manual.mjs (11935 lines, codex-cli 0.137.0)"`. Or add a note that this path is session-ephemeral and the reproducible fetch command is the one listed. |
| 2 | P1 | policy.md L66 vs L318 | **Sandbox boundary matrix contradicts Risk section**. The boundary matrix row for "Sandbox filesystem" marks User-Owned as "no" (red X). However, Risk #4 (L318) states: "If user has stricter global sandbox, project config's `workspace-write` may be overridden. Codex uses highest-precedence config." This means users CAN and DO override sandbox at the user level. The boundary matrix should reflect this reality. | Change the Sandbox filesystem row User-Owned column from "no" to "yes (stricter override)" or "yes (Override)" to match the model/reasoning/approval rows. Update the Rationale to note: "Project sets baseline; user can apply stricter sandbox via `~/.codex/config.toml`." |
| 3 | P2 | policy.md L107 | **`web_search = "cached"` not in `[features]` table**. In the Config Policy summary table (L107), `web_search` is listed as a standalone setting. In the draft `config.toml.draft` (L48), `web_search = "cached"` appears OUTSIDE the `[features]` table, at the top level. This is syntactically valid TOML (it is a root-level key), and the TOML parses without error. However, whether Codex reads `web_search` as a root-level key vs under `[features]` is a Codex schema question. If Codex expects it under `[features]`, the setting would be silently ignored. | Mark `web_search` placement as `unknown_current_behavior` for Phase 5 verification. Optionally move it under `[features]` in the draft to reduce risk, with a comment noting the uncertainty. |
| 4 | P2 | policy.md L127, L146 | **Unverified Codex manual line reference**. L127 cites "Codex manual L2111" for auto-protection of `.git` and `.codex` in workspace-write mode. L146 references `pre-accept-check.sh` and `pre-gate-check.sh` as TAD gate pre-checks. The Codex manual line number is from the locally fetched manual and may shift across Codex versions. | Add `(codex-cli 0.137.0)` version qualifier to the line reference so future readers know which version the claim applies to. This is not a factual correctness issue (Phase 1 verified the behavior), but a freshness hygiene issue for Phase 4 ledger. |
| 5 | P2 | config.toml.draft L31-36 | **Skills config section references undocumented TOML schema**. The commented-out `[[skills.config]]` block with `path` and `enabled` fields is presented as a valid Codex config pattern. Whether Codex supports `[[skills.config]]` in `config.toml` is not verified. | Add a comment: `# Schema unverified — check Codex docs before enabling`. Or mark with `unknown_current_behavior` in the policy doc's Config Policy section. |
| 6 | P2 | agents/*.toml.draft | **Agent drafts lack `model_provider` field**. All three agent drafts specify `model = "gpt-5.5"` (or `"gpt-5.4-mini"`) but do not specify `model_provider`. If Codex supports provider routing in agent config, the absence may cause unexpected behavior. If Codex does not support it at the agent level, no issue. | Note as `unknown_current_behavior` for Phase 5. If Codex agent TOML supports `model_provider`, consider whether to add it. |
| 7 | P1 | policy.md L161, L169 | **`askuser-capture.sh` risk understated for quality chain**. Policy L161 marks the hook status as "Working (unknown_current_behavior on Codex)" and L169 says "TAD loses decision capture but not quality chain." However, `askuser-capture.sh` captures structured decisions that feed into evidence trails. If the hook silently never fires, decision provenance is lost for the entire Codex platform, which IS a quality chain gap (evidence completeness), not merely a convenience loss. The policy correctly marks it `unknown_current_behavior` but the impact assessment is too optimistic. | Upgrade the impact statement from "not quality chain" to "partial quality chain impact: evidence completeness for decision provenance." Keep the priority as low (Phase 5 verify) since there is no data loss risk, but the impact framing should be accurate. |
| 8 | P2 | policy.md, section "Custom Agents Evaluation" | **No explicit output_format or max_tokens guidance for custom agents**. The three agent drafts define `model` and `model_reasoning_effort` but do not specify output constraints. A custom agent running `gpt-5.5` with `high` reasoning could produce very long outputs that exceed useful review scope, especially for spec-compliance which should be a structured checklist. | Consider adding `# max output guidance: structured checklist, <=500 lines` as a comment in each agent draft. Not blocking since Phase 5 regression will reveal any output quality issues. |
| 9 | P2 | policy.md L104 | **`memories = false` rationale could be stronger**. The policy says "TAD uses its own knowledge system, not Codex memories." This is correct but does not address the risk: if `memories` is later enabled (by user override at global level), Codex memories could accumulate stale TAD knowledge that conflicts with the current SKILL.md state, creating a silent protocol drift channel. | Add a sentence to the rationale: "Additionally, Codex memories could accumulate stale TAD knowledge that conflicts with evolving SKILL.md content, creating a silent protocol drift risk." |
| 10 | P2 | policy.md L105-106 | **`max_threads = 6` and `max_depth = 1` lack source verification**. These are presented as Codex defaults but whether 6 and 1 are actual Codex defaults or TAD-chosen values is unclear. The phrasing "Default; sufficient for TAD Layer 2" implies these ARE Codex defaults, but if they are TAD recommendations, the column should say so. | Clarify whether these are Codex defaults or TAD recommendations. If TAD-chosen, change "Default" to "TAD recommended" in the Rationale column. |

---

## Positive Observations

1. **Protocol-fork discipline is excellent**. Alex/Blake are `keep_skill_only` with clear justification. Agent `developer_instructions` are minimal (7-10 lines each) and reference TAD criteria conceptually without duplicating SKILL content. This is exactly the right approach.

2. **Security boundary is comprehensive**. The boundary matrix, MQ4 forbidden-content list, Security Review section, and activation criteria #6 (grep audit) form a multi-layered defense against secrets leaking into project config.

3. **Activation criteria are well-designed**. The 6-point activation gate (Phase 3 docs, Phase 4 ledger, Phase 5 regression, human approval, no P0 failures, no secrets) prevents premature adoption. The "what happens if criteria fail" section provides clear fallback paths.

4. **`unknown_current_behavior` discipline is consistently applied**. Three unknowns are explicitly labeled and assigned to future phases rather than guessed.

5. **Draft file hygiene is strong**. All drafts include clear "DRAFT ONLY" headers, all parse as valid TOML, all live exclusively under `.tad/evidence/designs/`, and no active runtime files were created.

---

## Counts

| Severity | Count | Blocking? |
|----------|-------|-----------|
| P0 | 0 | -- |
| P1 | 2 | Yes |
| P2 | 8 | No |

---

## Verdict: FAIL

P0 = 0, P1 = 2. Both P1 findings must be addressed before acceptance:

1. **P1 #2**: Fix the sandbox boundary matrix row to reflect that users CAN override sandbox at the user level (currently marked "no" but Risk #4 contradicts this).
2. **P1 #7**: Correct the `askuser-capture.sh` impact assessment from "not quality chain" to "partial quality chain impact" for evidence completeness.

After these two fixes, the artifacts can be re-reviewed for PASS.
