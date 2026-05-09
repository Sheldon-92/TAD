# §0 Spike Result — AskUserQuestion Envelope Verification

**Date**: 2026-04-25
**AC**: AC-P5.2-f (CR-P0-1)
**Per handoff §3.0**: verify AskUserQuestion stdin envelope shape via `claude -p` probe

---

## Method

1. Created `.tad/evidence/fixtures/phase5/probe-envelope.sh` — dump-stdin script
2. Created `.claude/settings.test.json` — PostToolUse "AskUserQuestion" → probe
3. Invoked: `claude -p --settings <test> --no-session-persistence --tools AskUserQuestion --output-format json --max-budget-usd 1.00 --system-prompt 'Call AskUserQuestion exactly once with question "probe?" + 2 options A/B'`

## Outcome: PARTIAL CONFIRMATION

**What got confirmed** (via stdout JSON `permission_denials[0]`):
- `tool_name`: `"AskUserQuestion"` ✅ (matches handoff hypothesis)
- `tool_use_id`: `"toolu_01BW6BNAxs1NqpnEeW1zrDE3"` (per-call UUID)
- `tool_input.questions[].question`: `"probe?"` ✅ (matches FR2)
- `tool_input.questions[].header`: `"Probe"` (additional field, not in FR2 — non-blocking)
- `tool_input.questions[].options[].label`: `"A"` ✅ (matches FR2)
- `tool_input.questions[].options[].description`: `"Option A"` (additional field — non-blocking)
- `tool_input.questions[].multiSelect`: `false` ✅ (matches FR2)

**What did NOT get confirmed** (limitation of `claude -p` non-interactive mode):
- `tool_response.answers` shape — AskUserQuestion was permission-DENIED (no human to answer in non-interactive mode), so PostToolUse hook never fired with a real `tool_response`.
- Outer envelope wrapper (session_id, transcript_path, cwd, permission_mode, hook_event_name) — same reason.

## Defensive Implementation Plan

Since the spike confirmed `tool_input` shape but couldn't capture full PostToolUse envelope:

1. **Implementation reads `tool_input` defensively** — uses jq path `.tool_input.questions[].question` (confirmed valid) and `.tool_input.questions[].options[].label` (confirmed valid).

2. **For `tool_response.answers`**: Claude Code convention (per architecture.md "UserPromptSubmit Hook Verified" + general PostToolUse pattern) is `.tool_response.answers["<question text>"]` returning the selected label. Implementation will:
   - First attempt: `jq -r '.tool_response.answers[.tool_input.questions[0].question]'`
   - Fallback: scan all `.tool_response.answers[*]` and pick first non-null
   - If absent entirely: `selection: null`, `is_other: false`

3. **Outer envelope fields** (session_id, cwd, etc.) — read via `jq -r '.session_id // ""'` style with default to empty string. These exist in EVERY PostToolUse envelope per Claude Code documented contract (architecture.md "UserPromptSubmit Hook Verified - 2026-04-07" lists them: session_id, transcript_path, cwd, permission_mode, hook_event_name).

## Spike Verdict

✅ **GO with defensive implementation** — `tool_input` paths are concretely verified; `tool_response.answers[<question>]` is highly likely per Claude Code convention but not directly verified. Implementation MUST handle null/missing tool_response gracefully (always exit 0 per Anti-Epic-1).

## Artifacts

- `.tad/evidence/fixtures/phase5/probe-envelope.sh` — probe hook
- `.tad/evidence/fixtures/phase5/claude-spike-result.json` — full claude -p stdout (1232 bytes)
- `.tad/evidence/fixtures/phase5/askuser-envelope-probe.json` — extracted permission_denials[0] entry
- `.claude/settings.test.json` — temporary test settings (will be removed before commit)
