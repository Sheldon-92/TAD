#!/usr/bin/env bash
# quality-checker.sh — shared check_write orchestrator (v3-LEAN §2.3)
# AC19: env-var signature (avoid positional empty-string ambiguity).
# Required env vars:
#   TAD_ROLE          alex | blake | system
#   TAD_TOOL_NAME     Write | Edit | MultiEdit | NotebookEdit | Bash | Task
#   TAD_TARGET_FILE   absolute path OR "" (for Bash)
#   TAD_CONTENT       concatenated content (MultiEdit edits[].new_string OR Bash command OR Task.prompt)
#   TAD_HANDOFF_SLUG  derived slug OR ""
#   TAD_SESSION_ID    session id (from stdin JSON or env)
# Optional:
#   TAD_HANDOFF_PATH  resolved handoff file (for KG-001 freshness)
#
# Stdout: nothing on allow; deny JSON written to stdout by dispatcher.
# Return: 0 allow | 1 deny (reason on stderr).

# shellcheck shell=bash
set -uo pipefail

: "${QUALITY_CHECKER_LOADED:=0}"
if [[ "$QUALITY_CHECKER_LOADED" == "1" ]]; then return 0 2>/dev/null || exit 0; fi
QUALITY_CHECKER_LOADED=1

# Assumes dispatcher sourced path-guard, content-scanner, sentinel-detect,
# evidence-validator, override-verify.

# LEAK_DETECTED sentinel (AC6.d / AC16.e): if present, deny all writes until
# OV-1 gate=emergency override.
_qc_leak_check() {
  if [[ -f ".tad/state/LEAK_DETECTED" ]]; then
    printf 'LEAK_DETECTED: .tad/state/LEAK_DETECTED present (historical secret commit). Require OV-1 gate=emergency to clear.\n' >&2
    return 1
  fi
  return 0
}

check_write() {
  local role="${TAD_ROLE:-system}"
  local tool="${TAD_TOOL_NAME:-}"
  local target="${TAD_TARGET_FILE:-}"
  local content="${TAD_CONTENT:-}"
  local slug="${TAD_HANDOFF_SLUG:-}"
  local handoff_path="${TAD_HANDOFF_PATH:-}"

  # 0. LEAK_DETECTED check (strongest deny)
  if ! _qc_leak_check; then return 1; fi

  # 1. Path traversal (PT-1) — Write-family only
  case "$tool" in
    Write|Edit|MultiEdit|NotebookEdit)
      if ! check_path_traversal "$target"; then return 1; fi
      ;;
  esac

  # 2. Protected path (HP-1) — Write-family
  case "$tool" in
    Write|Edit|MultiEdit|NotebookEdit)
      if ! check_path_protected "$target"; then return 1; fi
      ;;
  esac

  # 3. Bash write-path (BW-3) — Bash only
  if [[ "$tool" == "Bash" ]]; then
    if ! check_bash_write_target "$content"; then return 1; fi
  fi

  # 4. Env injection (HP-2) — content
  if [[ -n "$content" ]]; then
    if ! scan_env_injection "$content"; then return 1; fi
  fi

  # 5. OV-2 fake override — content
  if [[ -n "$content" ]]; then
    if ! scan_fake_override "$content"; then return 1; fi
  fi

  # 6. Sentinel detection (AW-2/BW-1) — Write-family content
  #    Primary match + path context → require evidence manifest
  case "$tool" in
    Write|Edit|MultiEdit|NotebookEdit)
      local sent_status=0
      detect_sentinel_in_content "$role" "$content" "$target" || sent_status=$?
      case "$sent_status" in
        0) : ;; # no sentinel
        2) : ;; # secondary-only, LOG-ONLY (allowed)
        1)
          # Primary: must satisfy manifest.
          local manifest_id
          case "$role" in
            alex)  manifest_id="alex_handoff_ready" ;;
            blake) manifest_id="blake_completion_ready" ;;
            *)
              printf 'SENTINEL_ROLE_INDETERMINATE: cannot match role=%s\n' "$role" >&2
              return 1
              ;;
          esac
          # Bootstrap exception (AW-1): if .tad/state/secret.key missing → LOG-ONLY
          if [[ ! -f ".tad/state/secret.key" ]]; then
            printf 'BOOTSTRAP_LOG_ONLY: secret.key absent, %s sentinel allowed with warning\n' "$role" >&2
            return 0
          fi
          if ! validate_manifest "$manifest_id" "$slug" "$handoff_path"; then
            return 1
          fi
          ;;
      esac
      ;;
  esac

  return 0
}
