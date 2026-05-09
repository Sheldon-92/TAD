#!/usr/bin/env bash
# quality-enforcement.sh — PreToolUse dispatcher (v3-LEAN §2.2)
# Handles: Write, Edit, MultiEdit, NotebookEdit, Bash, Task
# Routes to: path-guard → content-scanner → sentinel-detect → evidence-validator
# Bootstrap: first-run .tad/state/ creation + gitignore + historical secret scan
#
# Fail-closed contract (AC16):
#   - Missing jq/yq/perl/awk/openssl/git  → hardcoded deny JSON + exit 0
#   - stdin read > 2s                     → hardcoded deny + exit 0
#   - stdin > 1 MB                        → deny "payload_too_large" + exit 0
#   - Any uncaught error (set -e + trap)  → hardcoded deny + exit 0
#   - LEAK_DETECTED sentinel present      → deny until OV-1 gate=emergency
#
# Exit: always 0 (per Claude Code permission-gate contract).
# Stdout: either allow JSON (`{}`) or deny JSON.

# AC16.a: source dep-guard on first line (after shebang). dep-guard is responsible
# for PATH pin + hardcoded deny on missing dep.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# shellcheck source=lib/dep-guard.sh
. "${SCRIPT_DIR}/lib/dep-guard.sh"

# Required dependencies (jq is already present via dep-guard default; add the rest)
require_dep jq
require_dep yq
require_dep perl
require_dep awk
require_dep openssl
require_dep git

# AC16.d: set -euo + trap ERR → hardcoded deny on uncaught error
set -uo pipefail
_qe_hardcoded_deny() {
  # SECURITY: hardcoded body, no interpolation (AC16)
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"TAD enforcement hit an internal error. Contact TAD maintainer or retry with TAD_OVERRIDE in next prompt."}}'
  exit 0
}
trap _qe_hardcoded_deny ERR

_qe_deny() {
  local reason="$1"
  # Escape double-quote + backslash + newline
  local esc
  esc=$(printf '%s' "$reason" | perl -CSD -e 'local $/; my $s = <STDIN>; $s =~ s/\\/\\\\/g; $s =~ s/"/\\"/g; $s =~ s/\n/\\n/g; $s =~ s/\t/ /g; print $s')
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$esc"
  exit 0
}
_qe_allow() { printf '%s\n' '{}'; exit 0; }

# AC16.b+c: stdin read with 2s timeout + 1MB cap
# Use perl alarm to enforce deadline + head -c for size cap.
INPUT=$(perl -CSD -e '
  eval {
    local $SIG{ALRM} = sub { die "TIMEOUT\n" };
    alarm(2);
    my $buf = "";
    my $n = 0;
    while (my $r = sysread(STDIN, my $chunk, 65536)) {
      $buf .= $chunk;
      $n += $r;
      if ($n > 1048576) { print STDERR "PAYLOAD_TOO_LARGE\n"; exit 2 }
    }
    alarm(0);
    print $buf;
  };
  if ($@ && $@ =~ /TIMEOUT/) { print STDERR "TIMEOUT\n"; exit 3 }
' 2>/tmp/.tad-qe.err)
_qe_stdin_status=$?
case "$_qe_stdin_status" in
  0) : ;;
  2) _qe_deny "stdin payload_too_large (>1MB)" ;;
  3) _qe_deny "stdin read timeout (>2s)" ;;
  *) _qe_deny "stdin read error" ;;
esac

# Parse JSON
tool_name=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null || echo "")
session_id=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || echo "")
file_path=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")
transcript_path=$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")

# Extract content based on tool_name.
content=""
case "$tool_name" in
  Write)
    content=$(printf '%s' "$INPUT" | jq -r '.tool_input.content // ""' 2>/dev/null || echo "")
    ;;
  Edit)
    content=$(printf '%s' "$INPUT" | jq -r '.tool_input.new_string // ""' 2>/dev/null || echo "")
    ;;
  MultiEdit)
    # AC19: dispatcher concatenates edits[].new_string with \n
    content=$(printf '%s' "$INPUT" | jq -r '.tool_input.edits[]?.new_string // empty' 2>/dev/null | perl -e 'local $/; my $s = <STDIN>; $s =~ s/\n$//; print $s')
    ;;
  NotebookEdit)
    content=$(printf '%s' "$INPUT" | jq -r '.tool_input.new_source // ""' 2>/dev/null || echo "")
    ;;
  Bash)
    content=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
    # Also concat description for OV-2 scan
    local_desc=$(printf '%s' "$INPUT" | jq -r '.tool_input.description // ""' 2>/dev/null || echo "")
    content="${content}
${local_desc}"
    ;;
  Task)
    content=$(printf '%s' "$INPUT" | jq -r '.tool_input.prompt // ""' 2>/dev/null || echo "")
    ;;
  *)
    # Other tools — no gating surface
    _qe_allow
    ;;
esac

# Bootstrap (AC6): first-run → state dir + gitignore + openssl key + historical scan.
# Order: (a) mkdir 700 (b) gitignore append (c) openssl atomic (d) git log scan.
_qe_bootstrap() {
  # (a) state dir
  [[ -d ".tad/state" ]] || mkdir -p .tad/state
  chmod 700 .tad/state 2>/dev/null || true

  # (b) gitignore FIRST (ensure .tad/state/ is ignored before secret.key exists)
  if [[ -f ".gitignore" ]]; then
    if ! grep -qxF '.tad/state/' .gitignore 2>/dev/null; then
      printf '\n# TAD quality-enforcement state (Phase 3)\n.tad/state/\n' >> .gitignore
    fi
  else
    printf '# TAD quality-enforcement state (Phase 3)\n.tad/state/\n' > .gitignore
  fi

  # (c) secret.key atomic
  if [[ ! -f ".tad/state/secret.key" ]]; then
    ( umask 077; openssl rand -base64 32 > .tad/state/secret.key.tmp 2>/dev/null )
    if [[ -s ".tad/state/secret.key.tmp" ]]; then
      mv .tad/state/secret.key.tmp .tad/state/secret.key
      chmod 600 .tad/state/secret.key 2>/dev/null || true
    else
      rm -f .tad/state/secret.key.tmp
      printf 'BOOTSTRAP_ERROR: openssl rand failed\n' >&2
      _qe_deny "bootstrap openssl failed"
    fi
  fi

  # (d) historical commit scan for secret.key
  if git rev-parse --git-dir >/dev/null 2>&1; then
    if git log --all --oneline -- .tad/state/secret.key 2>/dev/null | grep -q '.'; then
      # Historical commit → persistent LEAK_DETECTED
      ( umask 077; printf 'secret.key was historically committed; rotate and investigate.\nDetected: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > .tad/state/LEAK_DETECTED )
      chmod 600 .tad/state/LEAK_DETECTED 2>/dev/null || true
      _qe_deny "LEAK_DETECTED: .tad/state/secret.key found in git history. Rotate + investigate. Require OV-1 gate=emergency to clear."
    fi
  fi
}
_qe_bootstrap

# LEAK_DETECTED sentinel check (AC16.e)
if [[ -f ".tad/state/LEAK_DETECTED" ]]; then
  _qe_deny "LEAK_DETECTED sentinel present — require OV-1 gate=emergency and manual clearance"
fi

# Derive handoff_slug (§2.4)
_qe_derive_slug() {
  local path="${file_path:-}"
  [[ -z "$path" ]] && { echo ""; return; }
  local slug=""
  if [[ "$path" =~ \.tad/active/handoffs/(HANDOFF|COMPLETION)-[0-9]{8}-([A-Za-z0-9_.-]+)\.md ]]; then
    slug="${BASH_REMATCH[2]}"
  elif [[ "$path" =~ \.tad/evidence/reviews/(alex|blake)/([A-Za-z0-9_.-]+)/ ]]; then
    slug="${BASH_REMATCH[2]}"
  elif [[ "$path" =~ \.tad/evidence/spikes/SPIKE-[0-9]{8}-([A-Za-z0-9_.-]+)/ ]]; then
    slug="${BASH_REMATCH[1]}"
  elif [[ "$path" =~ \.tad/evidence/gates/([A-Za-z0-9_.-]+)/gate[234]-verdict\.tsv ]]; then
    slug="${BASH_REMATCH[1]}"
  fi
  echo "$slug"
}
handoff_slug=$(_qe_derive_slug)

# If slug derived, validate the HANDOFF file exists in active or archive
handoff_path=""
if [[ -n "$handoff_slug" ]]; then
  for candidate in \
    ".tad/active/handoffs/HANDOFF-"*"-${handoff_slug}.md" \
    ".tad/archive/handoffs/HANDOFF-"*"-${handoff_slug}.md"; do
    if [[ -f "$candidate" ]]; then
      handoff_path="$candidate"
      break
    fi
  done
fi

# Derive role (§2.5) — read last 100 lines of transcript JSONL for Skill tool_use
_qe_derive_role() {
  local tp="${transcript_path:-}"
  [[ -z "$tp" || ! -f "$tp" ]] && { echo "system"; return; }
  # Last 100 lines, look for recent Skill use
  local last
  last=$(tail -n 100 "$tp" 2>/dev/null | perl -CSD -ne '
    if (/"name"\s*:\s*"Skill"/ && /"skill"\s*:\s*"(alex|blake|tad-alex|tad-blake)"/) {
      my $s = $1; $s =~ s/^tad-//; $last = $s;
    }
    END { print $last // "" }
  ')
  if [[ "$last" == "alex" || "$last" == "blake" ]]; then
    echo "$last"
  else
    echo "system"
  fi
}
role=$(_qe_derive_role)

# Source lib modules
# shellcheck source=lib/path-guard.sh
. "${SCRIPT_DIR}/lib/path-guard.sh"
# shellcheck source=lib/content-scanner.sh
. "${SCRIPT_DIR}/lib/content-scanner.sh"
# shellcheck source=lib/sentinel-detect.sh
. "${SCRIPT_DIR}/lib/sentinel-detect.sh"
# shellcheck source=lib/evidence-validator.sh
. "${SCRIPT_DIR}/lib/evidence-validator.sh"
# shellcheck source=lib/quality-checker.sh
. "${SCRIPT_DIR}/lib/quality-checker.sh"

# Export env vars for check_write (AC19)
export TAD_ROLE="$role"
export TAD_TOOL_NAME="$tool_name"
export TAD_TARGET_FILE="$file_path"
export TAD_CONTENT="$content"
export TAD_HANDOFF_SLUG="$handoff_slug"
export TAD_SESSION_ID="$session_id"
export TAD_HANDOFF_PATH="$handoff_path"

# Short-circuit ordering: path-guard → content-scanner → sentinel-detect → evidence-validator
# (each returns early; total work capped). quality-checker orchestrates.
reason=$( { check_write; } 2>&1 >/dev/null )
status=$?

if (( status != 0 )); then
  _qe_deny "TAD quality enforcement denied this tool use. Details: ${reason}"
fi

_qe_allow
