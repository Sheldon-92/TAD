#!/bin/bash
# HMAC helper for TSV ledger signing (FR10).
# Usage:
#   source lib/hmac.sh
#   sig=$(hmac_sign "$fixture_sha" "$decision_sha" "$verdict")
#   # verify:
#   hmac_verify "$fixture_sha" "$decision_sha" "$verdict" "$sig"   # echoes "ok" or "bad"
#
# Key: fixed constant per handoff FR10. Rotating the key invalidates all
# committed TSVs (intentional — prevents post-hoc re-signing).

TAD_SPIKE_1B_SECRET="TAD_SPIKE_1B_SECRET"

# Compute SHA256 of a file (or '-' for stdin)
sha256_file() {
  openssl dgst -sha256 -r "$1" 2>/dev/null | awk '{print $1}'
}

sha256_string() {
  printf '%s' "$1" | openssl dgst -sha256 -r | awk '{print $1}'
}

# HMAC-SHA256 signature over a tab-joined row
# Input: arbitrary args → joined by \t → HMAC → hex digest
hmac_sign() {
  local joined
  joined=$(printf '%s\t' "$@")
  joined="${joined%$'\t'}"  # strip trailing tab
  printf '%s' "$joined" | openssl dgst -sha256 -hmac "$TAD_SPIKE_1B_SECRET" -r | awk '{print $1}'
}

# Verify: recompute and compare
hmac_verify() {
  local expected="${!#}"  # last arg = expected signature
  # Build args array without the last
  local args=("$@")
  unset 'args[${#args[@]}-1]'
  local got
  got=$(hmac_sign "${args[@]}")
  if [ "$got" = "$expected" ]; then
    echo "ok"
  else
    echo "bad"
  fi
}
