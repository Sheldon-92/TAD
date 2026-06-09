# Code Review (Design Artifact)
## Date: 2026-06-09
## Reviewer: code-reviewer (sub-agent)

## Scope

Reviewed `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/designs/dual-platform-native-runtime-architecture.md` (390 lines) against handoff `HANDOFF-20260609-dual-platform-runtime-architecture-phase1.md` sections 6 and 9.

Cross-referenced live project files: `AGENTS.md`, `docs/MULTI-PLATFORM.md`, `.tad/codex/README.md`.

## Findings

| # | Severity | Location | Finding | Recommendation |
|---|----------|----------|---------|----------------|
| 1 | P2 | Current State Inventory, Stale Conflicts table, row 1 | Line reference inaccuracy: design says `docs/MULTI-PLATFORM.md` **L3** contains the "specialized execution tools" claim. Actual file has this at **L7** (the blockquote). L3 is the `**Version 2.8.0**` heading. | Correct to L7. Minor inaccuracy, but line-number citations are load-bearing for Phase 3 doc rewrites -- wrong line numbers waste editor time. |
| 2 | P2 | Current State Inventory, Stale Conflicts table, row 2 | Line reference inaccuracy: design says `docs/MULTI-PLATFORM.md` **L12-15** for the Architecture table showing "Specialized Executor." Actual table rows are **L13-17** (L13 is header, L14 is separator, L15-17 are data rows). | Correct to L13-17. |
| 3 | P2 | Current State Inventory, Stale Conflicts table, row 4 | Line reference inaccuracy: design says `docs/MULTI-PLATFORM.md` **L18-25** for "When to Use Codex/Gemini." The section header is at L19, table is L21-24. L25 is blank. L18 is also blank. Close but imprecise. | Correct to L19-24. |
| 4 | P2 | Current State Inventory, Stale Conflicts table, row 5 | Line reference inaccuracy: design says `docs/MULTI-PLATFORM.md` **L27-33** for "Human copies Handoff content" workflow. The section header is at L26, content is L28-32. L33 is blank. | Correct to L26-32. |
| 5 | P2 | Current State Inventory, Stale Conflicts table, row 6 | Design says `AGENTS.md` **L68-69** claims "parallel reviewers, auto-hooks are sequential / manual on Codex." L68 actually says "Use `codex exec resume --last` to continue multi-turn TAD workflows" and L69 says "Parallel expert review: run sequential sessions (same SKILL protocol)." The same claim also appears at L11 in the blockquote header. The stale claim exists but the line reference is partially misaligned -- L69 is about the sequential workaround, while the original framing is L11. | Recommend citing both L11 (original framing) and L69 (implementation guidance) for completeness. |
| 6 | P2 | Where Current Docs Agree table, row 4 | Design says AGENTS.md **L71** confirms "Skills installed to `.agents/skills/` on Codex." L71 actually says "Gate pre-checks (`pre-accept-check.sh`, `pre-gate-check.sh`): run manually before *accept / /gate." The `.agents/skills/` paths are in the capability packs table (L46-58), not L71. | Correct line reference. The claim is true (AGENTS.md does reference `.agents/skills/`) but the cited line is wrong. |
| 7 | P2 | Where Current Docs Agree table, row 3 | Design says `.tad/codex/README.md` **L1** contains "unified SKILL.md." Actual L1 is the title "# TAD Codex Adapter -- Migration Notice." The unified SKILL.md claim is at **L3**. | Correct to L3. |
| 8 | P2 | Where Current Docs Agree table, rows 3-5 | `.tad/codex/README.md` line refs: L9-10 (correct: L9 says "installed to `.agents/skills/`"), L14 (should be L14 for AGENTS.md triggers -- actually correct), L15 (hooks, correct). L19-27 range is close but L19 is the "## Files Removed" header, actual content is L20-27. | Minor: L19-27 is close enough for section range, but L1 should be L3. |
| 9 | P1 | YAML Summary, L28-29 | `human_override` and `codex_version_verified` fields are present in the YAML but are NOT defined in the handoff's required YAML schema (section 4.3). The handoff schema specifies: epic, phase, artifact_type, generated, status, platforms, source_policy, outputs, phase_2_ready, blocked_by. Extra fields are not harmful but the `human_override` field records a process decision ("Human selected this handoff during Blake activation, constituting explicit override") that arguably belongs in a process log or completion report, not the design artifact's metadata. This blurs artifact scope. | Move `human_override` rationale to the completion report. Keep `codex_version_verified` as it directly supports source_policy. |
| 10 | P1 | Capability Matrix, "Runtime freshness / drift detection" row, Claude Code Native column | States "not_applicable (Claude Code behavior is current by definition -- it's the development platform)." This contradicts D7 which explicitly creates `.tad/runtime-compat/claude-code.md` as a compatibility ledger and says "Claude Code ledger is lighter (less volatile) but still tracks compact behavior, Skill tool behavior, Agent tool behavior, and hook contract." If Claude Code freshness is truly N/A, D7's Claude Code ledger is unnecessary. If D7 is correct, the matrix cell is wrong. | Resolve contradiction: change matrix cell from "not_applicable" to "Tracked via `.tad/runtime-compat/claude-code.md` (lighter than Codex; tracks compact/Skill tool/Agent tool/hook behavior)" to align with D7. |
| 11 | P1 | Source Verification Log, V20 | `ask_user_question` is marked `unknown_current_behavior` which is honest. However, the Risks section (Risk #5, L363) says "TAD uses `AskUserQuestion` for interactive decisions" without clarifying which platform. On Claude Code, `AskUserQuestion` is a known tool. The risk should clarify that the gap is Codex-specific and explain what happens if Codex lacks an equivalent (does Socratic inquiry degrade to non-interactive?). | Expand Risk #5 to specify the Codex-only scope and describe the degraded behavior: Codex's conversational model may support asking questions in the chat flow, but lacks a discrete tool-call equivalent. Phase 2 should test whether Codex's conversational asking is functionally sufficient for TAD's Socratic protocol. |
| 12 | P1 | Capability Matrix, "Subagents / custom agents" row, Fallback column | States "Sequential expert review sessions on Codex (current workaround per AGENTS.md L68)." But AGENTS.md L68 says "Use `codex exec resume --last` to continue multi-turn TAD workflows" -- it is L69 that discusses "Parallel expert review: run sequential sessions." | Correct the AGENTS.md line reference from L68 to L69. Although P2 severity for a line number, this one feeds directly into the fallback strategy description, making it P1 because a Phase 2 implementer looking up L68 would find the wrong guidance. |
| 13 | P2 | Capability Matrix, "Hooks" row | Lists 10 Codex hook events inline: "PreToolUse/PostToolUse/SessionStart/PreCompact/PostCompact/UserPromptSubmit/SubagentStart/SubagentStop/PermissionRequest/Stop." This matches the V3 verification. However, Claude Code hook events are described only as "PreToolUse/PostToolUse/SessionStart etc." The asymmetric detail level makes it hard to assess hook parity at a glance. | Either enumerate both platforms' hook events or add a note "Claude Code hook events include: [list] -- see `.claude/settings.json` for full set." |
| 14 | P2 | D1, Protocol Invariants list | Lists "honest_partial protocol" and "post-compact recovery" as protocol invariants. These are important, but the matrix capability row for "Context compaction / resume" assigns Proposed Owner as "shared_protocol (session-state.md recovery), platform adapters (compact mechanics)." This is consistent. However, honest_partial is not mentioned anywhere in the capability matrix rows -- it has no surface entry. | Consider adding a "Protocol self-enforcement" or "Execution discipline" surface row to the matrix, or note that honest_partial is a cross-cutting concern covered by the "Reference/progressive loading" row's P0 fix. |
| 15 | P2 | Runtime Freshness Loop, Trigger #4 | States "After official Codex documentation changes: Re-verify affected surfaces." This trigger is aspirational -- there is no mechanism defined for detecting when Codex documentation changes. Unlike trigger #3 (CLI version bump, which is observable via `codex --version`), doc changes have no automated signal. | Add a concrete detection mechanism: either (a) subscribe to OpenAI changelog/RSS, (b) diff the local manual on each `fetch-codex-manual.mjs` run, or (c) acknowledge this trigger is manual/best-effort and not fail-closed. |
| 16 | P2 | Size / Maintenance Impact table | Claims "This architecture document ~500 lines, one-time." Actual document is 390 lines. Minor, but inflated estimates can set wrong expectations. | Correct to ~390 lines. |
| 17 | P2 | D8, Full-Cycle Regression Harness | States "n=3 stability recommended" without justification. Why 3 and not 1 or 5? For a manual regression test that takes significant time, n=3 may be aspirational. | Add brief rationale (e.g., "n=3 catches non-deterministic failures from model temperature/reasoning variation") or mark as "recommended, minimum n=1 required." |
| 18 | P1 | Capability Matrix, "Workflows" row, Proposed Owner | Assigns "claude_code_adapter (workflow scripts), codex_adapter (subagent-driven orchestration)" but the Shared TAD Protocol column says "Orchestration patterns: Ralph Loop, parallel execution, YOLO Conductor." This means the PATTERNS (Ralph Loop steps, parallel execution protocol, YOLO phases) are shared protocol, but neither the matrix nor D1 explicitly lists them as protocol invariants. D1 lists "Ralph Loop structure" as invariant, but D2 also lists it as execution-discipline content. The Ralph Loop is thus claimed by D1 (invariant), D2 (execution-discipline), and the matrix (shared protocol column) -- consistent but the Proposed Owner column only shows adapters, not the shared_protocol layer for the pattern definitions. | Add "shared_protocol (orchestration pattern semantics)" to the Proposed Owner column alongside the adapter entries, matching the Shared TAD Protocol column content. |
| 19 | P2 | Executive Decision, Layer 2 description | States "Platform Adapters -- native capabilities of each runtime, implemented using platform-native primitives: Claude Code (hooks, workflows, subagents, MCP, Skill tool) and Codex (AGENTS.md, `.agents/skills/`, `.codex/config.toml`, `.codex/agents/`, hooks, MCP, subagents, plugins)." Lists AGENTS.md as a Codex adapter primitive. But AGENTS.md also serves as the Codex equivalent of CLAUDE.md -- it is the project instruction surface, which arguably carries shared protocol content (role definitions, routing rules). Calling it purely a "platform adapter primitive" may confuse Phase 2 about what can and cannot be changed in AGENTS.md. | Add a clarifying note that AGENTS.md is the Codex project-instruction surface and its content includes both protocol routing (shared) and platform-specific guidance (adapter). Changes to AGENTS.md protocol content require the same TAD Epic process as CLAUDE.md changes. |

## Positive Observations

1. **Source verification discipline is exemplary.** The V1-V20 log with explicit source routes, line numbers from the Codex manual, and honest `verified_partial` / `unknown_current_behavior` classifications follows NFR2 rigorously.

2. **The protocol-vs-adapter boundary in D1-D2 is clearly drawn** and directly addresses the v2.7/v2.26 quality-chain failure history. The "circular trigger" discriminant is a strong design heuristic.

3. **D4 correctly prevents persona forking** by limiting Codex custom agents to narrow reviewer roles while keeping SKILL.md as the authoritative persona source.

4. **The fail-closed rules in the Runtime Freshness Loop are well-designed** -- they correctly block adoption of unverified safety-affecting features and require full-cycle regression before accepting Codex-native replacements for TAD quality mechanisms.

5. **D10 (deferred scope) is appropriately conservative** and each deferral has a clear rationale, preventing scope creep.

6. **The stale-doc inventory is thorough** and correctly identifies the dominant framing conflict in `docs/MULTI-PLATFORM.md`.

## Summary

- P0: 0 findings
- P1: 4 findings (#9, #10, #11, #12, #18)
- P2: 14 findings (#1-8, #13-17, #19)

## P1 Detail

- **#9**: YAML schema has extra process-decision fields not in the handoff spec. Low severity but scope blurring.
- **#10**: Internal contradiction between the capability matrix ("Claude Code freshness = N/A") and D7 (which creates a Claude Code compatibility ledger). Must be resolved to avoid Phase 2 confusion about whether to create the Claude Code ledger.
- **#11**: V20/Risk #5 `ask_user_question` gap is honest but under-specified for Phase 2 action. Socratic protocol degradation path is not described.
- **#12 + #18**: Line reference errors and missing shared_protocol owner attribution in matrix rows that directly feed Phase 2 implementation decisions.

## Verdict: FAIL

(PASS requires P0=0, P1=0. Five P1 findings require resolution before Gate 3 acceptance.)

### Required Fixes for P1 Closure

1. (#9) Remove `human_override` from YAML summary or move to completion report.
2. (#10) Align matrix "Runtime freshness" Claude Code column with D7's Claude Code ledger scope.
3. (#11) Expand Risk #5 with Codex-specific scope and Socratic degradation path.
4. (#12) Correct AGENTS.md L68 to L69 in Subagents fallback cell.
5. (#18) Add shared_protocol to Workflows row Proposed Owner column.
