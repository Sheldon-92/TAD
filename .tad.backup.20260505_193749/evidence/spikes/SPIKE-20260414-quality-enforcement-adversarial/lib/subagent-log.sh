#!/bin/bash
# Sub-agent invocation logger (FR8 + GUARDRAIL 2 from Alex).
#
# Log format:
#   ---
#   timestamp: 2026-04-14T10:48:00Z
#   template: A | B
#   category: sentinel-bypass
#   fixture_count_returned: N     (for Template A)
#   audit_id: "..."               (for Template B)
#   ---
#
#   ## Verbatim Prompt
#
#   ```
#   <full prompt sent to Task tool>
#   ```
#
#   ## Verbatim Response
#
#   ```
#   <full response received from Task tool>
#   ```
#
# Minimum size: 500 bytes (FR8, AC6). Enforced by the caller — this library
# just writes. If the resulting file is < 500 bytes, AC6 fails and the
# Gate 4 `find ... -size +500c` check will catch it.
#
# Usage:
#   source lib/subagent-log.sh
#   write_subagent_log \
#     "sub-agent-invocations/sentinel-bypass-1.log" \
#     "A" \
#     "sentinel-bypass" \
#     "$PROMPT" \
#     "$RESPONSE" \
#     "fixture_count_returned: 9"

write_subagent_log() {
  local log_file="$1"
  local template="$2"       # A or B
  local category="$3"       # for Template A; or "final-scoring" for B
  local prompt="$4"
  local response="$5"
  local extra_meta="${6:-}" # additional YAML lines (fixture_count_returned / audit_id)

  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  {
    printf -- '---\n'
    printf 'timestamp: %s\n' "$ts"
    printf 'template: %s\n' "$template"
    printf 'category: %s\n' "$category"
    if [ -n "$extra_meta" ]; then
      printf '%s\n' "$extra_meta"
    fi
    printf -- '---\n\n'
    printf '## Verbatim Prompt\n\n'
    printf '```\n'
    printf '%s\n' "$prompt"
    printf '```\n\n'
    printf '## Verbatim Response\n\n'
    printf '```\n'
    printf '%s\n' "$response"
    printf '```\n'
  } > "$log_file"
}
