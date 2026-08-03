#!/bin/bash
# AC-03 — normalized envelope fixture matrix, jq fallback, and TTY guard.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
ENVELOPE="$ROOT/.tad/hooks/lib/hook-envelope.sh"
ASKUSER="$ROOT/.tad/hooks/lib/askuser-capture.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac3.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/claude-startup.json" <<'EOF'
{"hook_event_name":"SessionStart","source":"startup","session_id":"claude-start","cwd":"/tmp/fixture"}
EOF
cat > "$TMP/claude-resume.json" <<'EOF'
{"hook_event_name":"SessionStart","source":"resume","session_id":"claude-resume","cwd":"/tmp/fixture"}
EOF
cat > "$TMP/claude-compact.json" <<'EOF'
{"hook_event_name":"SessionStart","source":"compact","session_id":"claude-compact","cwd":"/tmp/fixture"}
EOF
cat > "$TMP/claude-post-write.json" <<'EOF'
{"hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":".tad/active/handoffs/HANDOFF-fixture.md"},"session_id":"claude-write","cwd":"/tmp/fixture"}
EOF
cat > "$TMP/codex-no-delivery.json" <<'EOF'
{}
EOF
: > "$TMP/empty.json"

probe() {
  local fixture="$1"
  /bin/bash -c 'source "$1"; printf "%s|%s|%s|%s|%s\n" "$HOOK_EVENT" "$HOOK_SOURCE" "$HOOK_TOOL_NAME" "$HOOK_FILE_PATH" "$HOOK_ENVELOPE_HAS_INPUT"' _ "$ENVELOPE" < "$fixture"
}

STARTUP=$(probe "$TMP/claude-startup.json")
RESUME=$(probe "$TMP/claude-resume.json")
COMPACT=$(probe "$TMP/claude-compact.json")
WRITE=$(probe "$TMP/claude-post-write.json")
CODEX=$(probe "$TMP/codex-no-delivery.json")
EMPTY=$(probe "$TMP/empty.json")
[ "$STARTUP" = 'SessionStart|startup|||1' ] || { echo "unexpected startup shape: $STARTUP" >&2; exit 1; }
[ "$RESUME" = 'SessionStart|resume|||1' ] || { echo "unexpected resume shape: $RESUME" >&2; exit 1; }
[ "$COMPACT" = 'SessionStart|compact|||1' ] || { echo "unexpected compact shape: $COMPACT" >&2; exit 1; }
[ "$WRITE" = 'PostToolUse||Write|.tad/active/handoffs/HANDOFF-fixture.md|1' ] || { echo "unexpected write shape: $WRITE" >&2; exit 1; }
[ "$CODEX" = '||||1' ] || { echo "unexpected no-delivery shape: $CODEX" >&2; exit 1; }
[ "$EMPTY" = '||||0' ] || { echo "unexpected empty shape: $EMPTY" >&2; exit 1; }

# TTY simulation: script allocates a pseudo-terminal; the [ -t 0] branch must
# return immediately without waiting for stdin.
TTY_RESULT=$(script -q /dev/null /bin/bash -c "source '$ENVELOPE'; printf '%s' \"\$HOOK_ENVELOPE_HAS_INPUT\"" 2>/dev/null | tr -cd '0')
[ "$TTY_RESULT" = "0" ] || { echo "TTY guard failed: $TTY_RESULT" >&2; exit 1; }

# With jq hidden, the common path keeps its naive grep fallback, while askuser
# keeps its separate warn-and-skip behavior for nested question arrays.
NO_JQ_BIN="$TMP/no-jq-bin"
mkdir -p "$NO_JQ_BIN"
for utility in cat dirname grep head sed; do
  ln -s "$(command -v "$utility")" "$NO_JQ_BIN/$utility"
done
COMMON_VALUE=$(printf '%s' '{"tool_input":{"file_path":"/tmp/fallback.md"}}' \
  | PATH="$NO_JQ_BIN" /bin/bash -c "source '$ROOT/.tad/hooks/lib/common.sh'; read_stdin_json; get_json_field '.tool_input.file_path'")
[ "$COMMON_VALUE" = '/tmp/fallback.md' ] || { echo "common fallback failed: $COMMON_VALUE" >&2; exit 1; }
set +e
ASK_ERR=$(printf '%s' '{"session_id":"s","cwd":"/tmp","tool_input":{"questions":[]}}' \
  | PATH="$NO_JQ_BIN" /bin/bash "$ASKUSER" 2>&1 >/dev/null)
ASK_RC=$?
set -e
[ "$ASK_RC" -eq 0 ]
printf '%s\n' "$ASK_ERR" | grep -F -q -e 'jq not available; skipping capture'

printf '%s\n' 'AC-03 PASS: Claude fixtures, honest Codex empty shape, empty input, jq fallbacks, and TTY guard verified.'
