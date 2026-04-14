#!/bin/bash
# AC9: empirically verify "exit 0 + stdout deny JSON" blocks Write tool call
# under Claude Code 2.1.92+ (this system: 2.1.107).
#
# Strategy:
#   1. Set up a temp dir + temp settings.json with a PreToolUse Write hook
#      that emits exit 0 + stdout deny JSON.
#   2. Use `claude -p` with --settings pointing at the temp settings.
#   3. Ask Claude to Write a file.
#   4. Observe: did the Write happen? (file exists = fail-OPEN = CONTRACT BROKEN)
#                                      (file missing = fail-CLOSED = CONTRACT HOLDS)
#
# Output: results/exit-code-contract.tsv
# Verdict: PASS only if contract holds (Write blocked).

set -euo pipefail
cd "$(dirname "$0")"

OUT="results/exit-code-contract.tsv"
mkdir -p results
printf 'trial\thook_mode\tfile_created\tclaude_output_excerpt\tverdict\n' > "$OUT"

if ! command -v claude >/dev/null 2>&1; then
  printf '1\tN/A\tN/A\tclaude CLI not found\tSKIP\n' >> "$OUT"
  echo "AC9 SKIP: claude CLI unavailable"
  exit 2
fi

# Build a temp workspace + settings
TMPWS=$(mktemp -d)
trap 'rm -rf "$TMPWS"' EXIT

# Hook script: exit 0 + stdout deny JSON
HOOK_SH="$TMPWS/deny-hook.sh"
cat > "$HOOK_SH" <<'EOF'
#!/bin/bash
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"TAD test: exit-0-stdout-deny contract verification"}}'
exit 0
EOF
chmod +x "$HOOK_SH"

# Settings with Write-matcher PreToolUse hook
SETTINGS="$TMPWS/settings.json"
cat > "$SETTINGS" <<EOF
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {"type": "command", "command": "bash '$HOOK_SH'"}
        ]
      }
    ]
  }
}
EOF

TARGET_FILE="$TMPWS/canary.txt"

# Trial 1: ask claude to Write the canary file; with deny hook active, Write should NOT succeed
PROMPT="Please use the Write tool to create a file at $TARGET_FILE with content 'blocked?'."

# Use `--settings <file>` flag to load hook config WITHOUT disturbing auth.
# (CLAUDE_CONFIG_DIR env breaks login — claude can't find credentials.)

# Run claude with a 30s timeout as safety net
set +e
# macOS lacks GNU timeout; use bash background+kill.
(
  cd "$TMPWS"
  # IMPORTANT: do NOT use --permission-mode bypassPermissions — per 2026-03-31
  # architecture.md knowledge, bypassPermissions overrides ALL denies including hooks.
  # Use --permission-mode default (hooks fully active) and --settings to inject the
  # test hook without disturbing user auth.
  printf '%s\n' "$PROMPT" | claude -p --no-session-persistence --permission-mode default --settings "$SETTINGS" --allowed-tools Write > "$TMPWS/claude-out.txt" 2>&1 &
  cpid=$!
  ( sleep 60; kill -KILL $cpid 2>/dev/null ) &
  killer=$!
  wait $cpid 2>/dev/null
  if kill -0 $killer 2>/dev/null; then kill $killer 2>/dev/null; fi
)
rc=$?
output=$(cat "$TMPWS/claude-out.txt" 2>/dev/null || echo "(no output)")
set -e

# Check: did the file get created?
if [ -f "$TARGET_FILE" ]; then
  file_created="yes"
else
  file_created="no"
fi

# Truncate output for TSV
excerpt=$(printf '%s' "$output" | tr '\n' ' ' | head -c 300 | sed 's/\t/ /g')

# Verdict logic:
#   file_created=no → contract holds → PASS
#   file_created=yes → contract broken → FAIL (Phase 1c §4.1 design void)
if [ "$file_created" = "no" ]; then
  verdict=PASS
else
  verdict=FAIL
fi

printf '1\texit0-stdout-deny\t%s\t%s\t%s\n' "$file_created" "$excerpt" "$verdict" >> "$OUT"

echo "--- results ---"
cat "$OUT"
echo "--- raw claude output (first 500 bytes) ---"
printf '%s' "$output" | head -c 500
echo

if [ "$verdict" = "PASS" ]; then
  echo "AC9 PASS: exit 0 + stdout deny JSON contract confirmed under Claude Code $(claude --version 2>&1 | head -1)"
  exit 0
else
  echo "AC9 FAIL: contract broken — Write succeeded despite deny hook. §4.1 design is VOID."
  exit 1
fi
