#!/bin/bash
# Read JSON input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Side effect: append to a log file
echo "[$TIMESTAMP] Tool used: $TOOL_NAME" >> .tad/spike-v3/exp1-command-hook/tool-log.txt

# Also dump the full input for analysis
echo "--- [$TIMESTAMP] Full Input ---" >> .tad/spike-v3/exp1-command-hook/stdin-dump.txt
echo "$INPUT" >> .tad/spike-v3/exp1-command-hook/stdin-dump.txt

# Output JSON with additionalContext
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Hook executed: logged $TOOL_NAME to tool-log.txt"
  }
}
EOF
exit 0
