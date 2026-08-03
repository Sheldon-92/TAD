#!/bin/bash
# TAD hook envelope normalizer.
#
# This file is intentionally self-contained. Source it BEFORE common.sh: it owns
# only HOOK_* variables and never writes HAS_JQ or STDIN_JSON. The small amount of
# duplicated JSON extraction is deliberate: manual gate paths need a low-dependency,
# fail-open reader even when common.sh is unavailable.
#
# Empty input and TTY input are first-class manual/no-envelope paths. The TTY guard
# is before cat so an interactive shell can never block waiting for hook JSON.

HOOK_STDIN_JSON=""
HOOK_ENVELOPE_HAS_INPUT=0
HOOK_ENVELOPE_TTY=0
HOOK_ENVELOPE_HAS_JQ=0

if [ -t 0 ]; then
  HOOK_ENVELOPE_TTY=1
else
  HOOK_STDIN_JSON=$(cat 2>/dev/null || true)
  if [ -n "$HOOK_STDIN_JSON" ]; then
    HOOK_ENVELOPE_HAS_INPUT=1
  fi
fi

if command -v jq >/dev/null 2>&1; then
  HOOK_ENVELOPE_HAS_JQ=1
fi

hook_envelope_grep_field() {
  local key="$1"
  printf '%s' "$HOOK_STDIN_JSON" \
    | grep -o "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" 2>/dev/null \
    | head -1 \
    | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/'
}

hook_envelope_value() {
  local expression="$1"
  local fallback_key="$2"
  local value=""
  if [ "$HOOK_ENVELOPE_HAS_JQ" -eq 1 ] && [ -n "$HOOK_STDIN_JSON" ]; then
    value=$(printf '%s' "$HOOK_STDIN_JSON" | jq -r "$expression" 2>/dev/null || true)
    [ "$value" = "null" ] && value=""
  fi
  if [ -z "$value" ]; then
    value=$(hook_envelope_grep_field "$fallback_key")
  fi
  printf '%s' "$value"
}

# A caller may provide the event name in an environment variable when the
# platform does not put it in the JSON body. Never synthesize HOOK_SOURCE:
# absent/unsupported platform fields must remain empty for fail-open consumers.
if [ -z "${HOOK_EVENT:-}" ]; then
  HOOK_EVENT=$(hook_envelope_value \
    '(.hook_event_name // .event // .event_name // .event_type // empty) | strings' \
    "hook_event_name")
fi
HOOK_SOURCE=$(hook_envelope_value \
  '(.source // .hook_source // .context_source // empty) | strings' \
  "source")
HOOK_TOOL_NAME=$(hook_envelope_value \
  '(.tool_name // .tool // .name // empty) | strings' \
  "tool_name")
HOOK_FILE_PATH=$(hook_envelope_value \
  '(.tool_input.file_path // .tool_input.path // .file_path // .path // empty) | strings' \
  "file_path")
HOOK_SKILL=$(hook_envelope_value \
  '(.tool_input.skill // .skill // empty) | strings' \
  "skill")
HOOK_SKILL_ARGS=$(hook_envelope_value \
  '(.tool_input.args // .skill_args // empty) | tostring' \
  "args")
HOOK_SESSION_ID=$(hook_envelope_value \
  '(.session_id // .conversation_id // .thread_id // empty) | strings' \
  "session_id")
HOOK_CWD=$(hook_envelope_value \
  '(.cwd // .working_directory // .hook_cwd // empty) | strings' \
  "cwd")
