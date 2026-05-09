#!/usr/bin/env bash
# userprompt-override.sh — UserPromptSubmit OV-1 handler (v3-LEAN §6)
# Matches: ^TAD_OVERRIDE: <gate> <reason>$  (line-start strict)
# Side effects: allocate nonce (idempotent), append to override-log.jsonl
# Stdout: additionalContext acknowledging nonce + reason (no blocking)
#
# Fail-closed: if inputs invalid → silent no-op (allow), since OV-1 is a privilege
# GRANT — failing closed here means "no grant", which is the safe default.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "${SCRIPT_DIR}/lib/dep-guard.sh"

require_dep jq
require_dep perl
require_dep openssl

set -uo pipefail
_uo_nop() { printf '%s\n' '{}'; exit 0; }
trap _uo_nop ERR

# 2s stdin read + 1MB cap
INPUT=$(perl -CSD -e '
  eval {
    local $SIG{ALRM} = sub { die "TIMEOUT\n" };
    alarm(2);
    my $buf = ""; my $n = 0;
    while (my $r = sysread(STDIN, my $chunk, 65536)) {
      $buf .= $chunk; $n += $r;
      if ($n > 1048576) { exit 2 }
    }
    alarm(0);
    print $buf;
  };
  if ($@ && $@ =~ /TIMEOUT/) { exit 3 }
') || _uo_nop

prompt=$(printf '%s' "$INPUT" | jq -r '.prompt // ""' 2>/dev/null || echo "")
session_id=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || echo "")

[[ -z "$prompt" || -z "$session_id" ]] && _uo_nop

# Source override-verify
. "${SCRIPT_DIR}/lib/override-verify.sh"

# Try to parse OV-1
gr=$(validate_override_prompt "$prompt" 2>/dev/null || true)
if [[ -z "$gr" ]]; then
  # Not an OV-1 prompt — no-op
  _uo_nop
fi

gate="${gr%%$'\t'*}"
reason="${gr#*$'\t'}"

# Allocate or retrieve nonce (idempotent)
nonce=$(allocate_nonce "$gate" "$session_id" || echo "")
if [[ -z "$nonce" ]]; then
  _uo_nop
fi

# Append override log (plain JSONL, chmod 600)
append_override_log "$gate" "$reason" "$nonce" "$session_id" 2>/dev/null || true

# Emit additionalContext to inform Claude Code that a nonce is armed.
# This is guidance to the model, not an enforcement grant on its own.
# Actual enforcement happens in quality-enforcement.sh (checks + consumes nonce).
msg="TAD_OVERRIDE armed: gate=${gate} nonce=${nonce}. Single-use, 1h TTL, same-session only."
esc=$(printf '%s' "$msg" | perl -CSD -e 'local $/; my $s = <STDIN>; $s =~ s/\\/\\\\/g; $s =~ s/"/\\"/g; $s =~ s/\n/\\n/g; print $s')
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$esc"
exit 0
