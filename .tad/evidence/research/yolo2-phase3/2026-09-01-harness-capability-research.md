# YOLO2 Phase 3 — Harness Capability Research

**Date:** 2026-09-01  
**Decision:** how to share verified progress and recovery semantics across Claude Code,
Codex, OpenCode, and the user's DeepSeek path without treating chat history as authority.

## Repository findings

- `.tad/scripts/yolo-recovery.mjs` already owns the canonical local state:
  immutable `goal.json`, append-only `journal.jsonl`, derived `checkpoint.json`, and
  bounded `recovery.md`.
- `.tad/scripts/yolo-reference-runner.mjs` is Codex-specific. It launches
  `codex exec`, binds native JSONL events and worktree deltas, and records the
  native session ID. It is useful prior art, not a multi-harness contract.
- `.tad/scripts/phase2-pair-driver.mjs` invokes OpenCode or Claude only as a
  blinded judge. That path does not prove start/resume/re-entry behavior.
- The current reducer is already a single canonical writer. Phase 3 should keep
  adapters observational and prevent them from directly advancing `verified`.

## Local capability inventory

| Target identity | Local observation | Design consequence |
|---|---|---|
| Claude Code | `2.1.239`; print JSON/stream-JSON, JSON Schema, resume, tool and permission flags | native CLI adapter is feasible; capabilities still require live probes |
| Codex | `codex-cli 0.151.0`; `exec`, JSONL, output schema, sandbox, exact-session resume | generalize the proven Phase-2 runner contract without rewriting its evidence |
| OpenCode | `1.18.25`; JSON events, session resume/fork, explicit model, permission environment, ACP server | native CLI adapter is feasible; ACP remains an optional future transport |
| DeepSeek target | no standalone `deepseek` executable; `DEEPSEEK_API_KEY` is present and OpenCode enumerates `deepseek/*` models | model it as `runtime=opencode`, `provider=deepseek`, explicit model; never claim a separate runtime |

No credential values were read or recorded.

## Primary sources

- Claude Code CLI reference: <https://code.claude.com/docs/en/cli-usage>
- OpenAI Codex CLI reference: <https://developers.openai.com/codex/cli/reference/>
- OpenCode CLI reference: <https://opencode.ai/docs/cli/>
- DeepSeek JSON output guide: <https://api-docs.deepseek.com/guides/json_mode/>
- DeepSeek chat/tool API: <https://api-docs.deepseek.com/api/create-chat-completion/>
- Agent Client Protocol overview: <https://github.com/agentclientprotocol/agent-client-protocol/blob/main/docs/protocol/v1/overview.mdx>
- lite-harness SDK: <https://github.com/LiteLLM-Labs/lite-harness/blob/main/src/sdk/README.md>
- Existing TAD long-horizon research:
  `.tad/evidence/research/longhorizon-harness/2026-08-24-raw-web-research.md`

## Option comparison

| Option | Coverage now | Advantages | Blocking limitations |
|---|---|---|---|
| Native CLI adapters behind one TAD contract | all four target identities | preserves installed runtimes, existing sessions, sandboxes, and Phase-2 evidence model | per-runtime parsers and probes are required |
| ACP-first | OpenCode directly; others uncertain | negotiated capabilities and standard session lifecycle | not a common installed transport for Claude Code and Codex here |
| Unified SDK replacement | partial | one programming interface in theory | lite-harness is preview and currently documents Claude/OpenAI SDK harnesses, not this four-target set; replacing CLIs changes the product boundary |
| Shared transcript/session database | technically custom | apparent continuity | violates the stated exclusion, leaks platform-specific internals, and does not establish verified progress |

## Decision implication

Use native CLI adapters behind a small TAD-owned semantic contract. The shared
object is the verified run state and recovery assertion, not the native session or
chat transcript. ACP may later become an implementation detail for a profile only
after its live probe proves equivalent behavior.

