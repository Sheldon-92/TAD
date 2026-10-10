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

# Codex apply_patch carries the patch text in tool_input.command and has no
# file_path/path field. Only in that case (tool apply_patch, path still empty) the
# touched paths are read out of the patch body. The body is model-written, so it
# is untrusted: text extraction only (never eval'd or spliced into a command),
# relative paths only, no ".." segment, no control characters, at most 20 paths.
# HOOK_FILE_PATHS holds the accepted paths, one per line; HOOK_FILE_PATH is the
# first of them so single-path consumers keep working. Delete File lines are
# skipped: the file is gone, so there is nothing for a post-write step to act on.
HOOK_FILE_PATHS=""

hook_envelope_patch_path_ok() {
  local p="$1"
  [ -n "$p" ] || return 1
  case "$p" in
    /*|~*) return 1 ;;
    ..|../*|*/..|*/../*) return 1 ;;
    *[[:cntrl:]]*) return 1 ;;
  esac
  return 0
}

hook_envelope_patch_lines() {
  # stdin: patch text; stdout: candidate paths, one per line
  grep -E '^\*\*\* (Add File|Update File|Move to): ' 2>/dev/null \
    | sed -E 's/^\*\*\* (Add File|Update File|Move to): //' 2>/dev/null
}

hook_envelope_patch_lines_raw() {
  # No jq: isolate the string value of tool_input.command in the still-escaped
  # JSON, or extract nothing. It is isolated only when "tool_input" and "command"
  # each occur exactly once as keys and no "}" lies between them; headers in
  # tool_response or in a top-level command are therefore never read.
  local n_in n_cmd after before rest
  n_in=$(printf '%s' "$HOOK_STDIN_JSON" | grep -oE '"tool_input"[[:space:]]*:[[:space:]]*\{' 2>/dev/null | wc -l | tr -d ' ')
  n_cmd=$(printf '%s' "$HOOK_STDIN_JSON" | grep -oE '"command"[[:space:]]*:' 2>/dev/null | wc -l | tr -d ' ')
  [ "$n_in" = 1 ] && [ "$n_cmd" = 1 ] || return 0
  after=$(printf '%s' "$HOOK_STDIN_JSON" | sed -E 's/^.*"tool_input"[[:space:]]*:[[:space:]]*\{//' 2>/dev/null)
  before="${after%%\"command\"*}"
  case "$before" in *"}"*) return 0 ;; esac
  rest="${after#*\"command\"}"
  # Escaped backslashes and quotes are neutralised first (\\ -> \x, \" -> \q) so
  # an escaped backslash followed by n is not mistaken for a line break, and the
  # first remaining quote ends the command string. Each escaped newline (\n) then
  # becomes a real line break and header lines are picked as in the jq path. Any
  # other escape left in a path (\t, \r, \uXXXX, \x, \q) leaves a backslash, and
  # such candidates are dropped.
  printf '%s' "$rest" \
    | sed -n -E 's/^[[:space:]]*:[[:space:]]*"/"/p' 2>/dev/null \
    | sed -e 's/^"//' -e 's/\\\\/\\x/g' -e 's/\\"/\\q/g' 2>/dev/null \
    | cut -d'"' -f1 2>/dev/null \
    | sed -e 's/\\n/\
/g' 2>/dev/null \
    | hook_envelope_patch_lines \
    | grep -v '[\\"]' 2>/dev/null
}

hook_envelope_collect_patch_paths() {
  local cmd="" candidates="" line count=0
  # At most 200 header lines are looked at (the 20-path cap counts accepted paths
  # only), so a patch full of rejected headers cannot run the hook out of time.
  if [ "$HOOK_ENVELOPE_HAS_JQ" -eq 1 ]; then
    cmd=$(printf '%s' "$HOOK_STDIN_JSON" | jq -r '(.tool_input.command // empty) | strings' 2>/dev/null || true)
    [ -n "$cmd" ] && candidates=$(printf '%s\n' "$cmd" | hook_envelope_patch_lines | head -n 200)
  else
    candidates=$(hook_envelope_patch_lines_raw | head -n 200)
  fi
  [ -n "$candidates" ] || return 0
  while IFS= read -r line; do
    hook_envelope_patch_path_ok "$line" || continue
    case "
$HOOK_FILE_PATHS
" in
      *"
$line
"*) continue ;;
    esac
    if [ -z "$HOOK_FILE_PATHS" ]; then
      HOOK_FILE_PATHS="$line"
    else
      HOOK_FILE_PATHS="${HOOK_FILE_PATHS}
${line}"
    fi
    count=$((count + 1))
    [ "$count" -ge 20 ] && break
  done <<EOF2
$candidates
EOF2
  return 0
}

# Without jq the generic extraction above reads no "path" key; an explicit
# non-empty file_path/path anywhere in the envelope also keeps the patch body unread.
HOOK_ENVELOPE_EXPLICIT_PATH=0
if [ "$HOOK_ENVELOPE_HAS_JQ" -ne 1 ] && [ -n "$HOOK_STDIN_JSON" ] \
   && printf '%s' "$HOOK_STDIN_JSON" | grep -qE '"(file_)?path"[[:space:]]*:[[:space:]]*"[^"]' 2>/dev/null; then
  HOOK_ENVELOPE_EXPLICIT_PATH=1
fi

if [ "$HOOK_TOOL_NAME" = "apply_patch" ] && [ -z "$HOOK_FILE_PATH" ] && [ "$HOOK_ENVELOPE_EXPLICIT_PATH" -eq 0 ]; then
  hook_envelope_collect_patch_paths || true
  if [ -n "$HOOK_FILE_PATHS" ]; then
    HOOK_FILE_PATH="${HOOK_FILE_PATHS%%
*}"
  fi
fi
