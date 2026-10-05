# Alex Independent Verification — YOLO2 Phase 3 Codex P3-R1

**Date:** 2026-09-01  
**Verifier:** Alex  
**Scope:** Codex only; no Claude Code, OpenCode, or DeepSeek calls  
**Frozen tuple:** `/opt/homebrew/bin/codex`, `codex-cli 0.151.0`, model `gpt-5.6-luna`  
**Mandate:** at most 3 calls / 20K tokens / 10 minutes / zero retries

## Result

**Codex native capability: PASS.** Two live calls completed in 16.6 seconds with no
retry. The second call resumed the exact native thread and recovered the bounded
semantic state without receiving the packet or nonce again.

Native thread ID:

`01a05e6e-8931-75d0-86bf-76464333124c`

Fresh response:

```json
{"goal":"prove Codex can restore bounded semantic progress","verified_slice":"local deterministic safety complete","blocker":"live Codex validation pending","legal_next_action":"resume and restate state","recovery_nonce":"P3R1-NATIVE-RESUME-7f31c2"}
```

Native-resume response, without repeating the packet/nonce:

```json
{"prior_goal":"prove Codex can restore bounded semantic progress","prior_verified_slice":"local deterministic safety complete","prior_blocker":"live Codex validation pending","prior_legal_next_action":"resume and restate state","prior_recovery_nonce":"P3R1-NATIVE-RESUME-7f31c2"}
```

The resumed thread ID matched the fresh thread ID exactly.

## Adapter integration findings

The Codex runtime supports the required behavior, but commit
`b9e04f126160861a93b8d6c8f669746b3441a8c2` cannot yet claim the adapter itself is
`strict`:

1. `cmdTurn()` validates `--packet` by hash but does not inject `packetContent` into
   the Codex invocation; it sends only the separate prompt text.
2. `cmdTurn()` records `--session` as metadata but `buildArgv()` never constructs
   `codex exec resume <session-id>`, so the adapter does not perform native resume.
3. The deterministic test creates a Codex `strict` placeholder explicitly marked
   “no provider call yet”; that carrier is synthetic and cannot be the trust source.

## Acceptance disposition

- Codex executable/model/native fresh+resume capability: **PASS**.
- Shared-state adapter wiring at `b9e04f1`: **NEEDS TWO FOCUSED FIXES**.
- No additional provider call is required after those deterministic wiring fixes;
  the live runtime behavior is already demonstrated here.
- Experimental adapters remain unverified and non-blocking under P3-R1.

Native token usage was not emitted by the CLI JSONL. Invocation and wall ceilings
were directly observed; the two prompts/responses were bounded and no retry occurred.
