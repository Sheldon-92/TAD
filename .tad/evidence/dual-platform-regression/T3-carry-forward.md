# T3 Carry-Forward Verification

verdict: PASS

## Carry-Forward Results

| Item | Status | gap_classification | Notes | Evidence |
|------|--------|--------------------|-------|----------|
| CF1 `ask_user_question` hook on Codex | needs_fix | adapter_bug | `.codex/hooks.json` wires a PostToolUse matcher for `ask_user_question`, but an actual Codex probe returned `request_user_input is unavailable in Default mode` and ended with `TOOL_UNAVAILABLE`. The hook path is configured but not exercised in this runtime mode. | `.codex/hooks.json`, `CF1-ask-user-question-run.txt`, `CF1-ask-user-question-last.txt` |
| CF2 custom agent structural validity | structurally_valid | accepted_limitation | All three `.toml.draft` agent files parse as valid TOML. They were intentionally not copied to `.codex/agents/` because activation still depends on Phase 5 acceptance. | TOML parse check output, draft files under `.tad/evidence/designs/codex-runtime-candidates/agents/` |
| CF3 draft `config.toml` structural validity | valid | none | `config.toml.draft` parses as valid TOML. | TOML parse check output, `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft` |
| CF4 Layer 2 evidence completeness | present | none | Phase 4 review evidence exists: `spec-compliance-review.md`, `code-review.md`, `code-review-r2.md`, `code-review-r3.md`. | `.tad/evidence/reviews/blake/runtime-freshness-loop/` |
| CF5 `skills.config` schema | supported | none | Current Codex manual documents `[[skills.config]]` in config and also lists `skills.config` as a valid inherited key for custom agents. | Local Codex manual outline and config sections |
| CF6 `model_provider` field | supported_user_only | accepted_limitation | Current Codex manual supports `model_provider` in user config, but project-local `.codex/config.toml` explicitly ignores `model_provider`. For TAD's draft project config, this key cannot be activated at project scope. | Local Codex manual project-config restrictions + provider section |
| CF7 agent output constraints | not_supported | deferred | Current custom-agent schema documents required fields plus inherited config keys, but no per-agent output-constraint field. The CLI supports `--output-schema` at invocation time, not in agent TOML. | Local Codex manual custom-agent schema + `codex exec --help` |
| CF8 agent runtime quality | quality_acceptable | none | T1 produced a structured handoff, bounded implementation, review artifacts, and a passing independent rerun. The quality chain is usable even though git-backed completion inside the carrier sandbox was partial. | `T1-full-cycle-v0.137.0.md`, carrier evidence dir |

## Phase 2 P2 Doc-Level Spot-Check

Spot-checked `docs/MULTI-PLATFORM.md` for the doc-level follow-through items that Phase 3 was supposed to resolve.

- First-class dual-runtime positioning: present
- Draft-only activation boundary: present
- Activation criteria: present
- Runtime freshness layer: present
- `ask_user_question` unknown gap: present

Result: PASS

## Conclusion

The carry-forward set passed with two real caveats:

1. `ask_user_question` remains an adapter bug in current Codex exec behavior.
2. `model_provider` is not activatable from project-local `.codex/config.toml`, so the draft config must keep provider selection at user scope.
