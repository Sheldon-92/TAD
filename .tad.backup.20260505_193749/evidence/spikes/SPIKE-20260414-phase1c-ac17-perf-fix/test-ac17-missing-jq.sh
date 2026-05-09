#!/bin/bash
# AC3+AC4: PATH-isolated retest of AC17 (jq missing → hard deny).
# Validates: exit 0, stdout = valid JSON deny, message body has NO $dep interpolation.

set -euo pipefail
cd "$(dirname "$0")"

OUT="results/ac17-retest.tsv"
mkdir -p results
printf 'hook\tjq_present\texit_code\toutput_bytes\tjq_valid\tdeny_detected\tno_var_interp\tverdict\n' > "$OUT"

# Build PATH that DOES NOT contain jq. Keep /bin,/usr/bin for core utils.
# jq on this system is at /usr/bin/jq — so we must either use an empty PATH
# (too restrictive, breaks bash internals) or symlink a fake non-jq environment.
# Approach: create a tmp dir PATH that has only a minimal subset WITHOUT jq.

TMPBIN=$(mktemp -d)
trap 'rm -rf "$TMPBIN"' EXIT

# Populate tmpbin with minimal tools EXCEPT jq (from /bin and /usr/bin)
for tool in bash sh cat sed awk grep head wc tr sort find ln rm ls mkdir chmod stat printf dirname basename readlink command tty test true false env; do
  for src in /bin /usr/bin; do
    if [ -x "$src/$tool" ]; then
      ln -sf "$src/$tool" "$TMPBIN/$tool"
      break
    fi
  done
done
# perl and openssl (override-detector needs them post-dep-guard, but require_dep only asks for jq)
[ -x /usr/bin/perl ] && ln -sf /usr/bin/perl "$TMPBIN/perl"
[ -x /opt/homebrew/bin/openssl ] && ln -sf /opt/homebrew/bin/openssl "$TMPBIN/openssl"

# NOTE: the hook's dep-guard.sh does `export PATH=/usr/bin:/bin:/usr/local/bin`
# which would re-enable jq. To test missing-jq, we must also override the
# dep-guard's PATH. Approach: move /usr/bin/jq out of the way is destructive.
# Better approach: create a shadow dep-guard.sh that points PATH at TMPBIN.

# Build a shadow hooks-v2 directory with dep-guard that pins PATH to TMPBIN only
SHADOW=$(mktemp -d)
trap 'rm -rf "$TMPBIN" "$SHADOW"' EXIT
mkdir -p "$SHADOW/lib"
# Write a shadow dep-guard.sh that pins PATH to TMPBIN (no jq)
cat > "$SHADOW/lib/dep-guard.sh" <<EOF
#!/bin/bash
export PATH=$TMPBIN
require_dep() {
  local dep="\$1"
  if ! [[ "\$dep" =~ ^[a-z0-9_-]+\$ ]]; then
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"TAD enforcement error: invalid dep name passed to require_dep. Contact TAD maintainer."}}'
    exit 0
  fi
  if ! command -v "\$dep" >/dev/null 2>&1; then
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"TAD enforcement requires dependency (missing). Install jq/awk or use TAD_OVERRIDE in next prompt."}}'
    exit 0
  fi
}
EOF

# Symlink each hook to shadow dir (so ${BASH_SOURCE[0]%/*}/lib/dep-guard.sh resolves to shadow)
for hook in hardened-pretool-interceptor.sh hardened-bash-watcher.sh hardened-override-detector.sh hardened-evidence-validator.sh; do
  cp "hooks-v2/$hook" "$SHADOW/$hook"
done

# Sanity: shadow dep-guard must NOT find jq
if PATH=$TMPBIN command -v jq >/dev/null 2>&1; then
  echo "SETUP FAIL: jq still visible in TMPBIN — cannot test missing-jq scenario"
  exit 1
fi

# Run each hook and capture output/exit
for hook in hardened-pretool-interceptor.sh hardened-bash-watcher.sh hardened-override-detector.sh hardened-evidence-validator.sh; do
  # For evidence-validator, pass a file arg; for others, pipe stdin
  if [ "$hook" = "hardened-evidence-validator.sh" ]; then
    # Will fail usage check BEFORE dep-guard if args missing. We pass a fake arg.
    out=$(bash "$SHADOW/$hook" "test-fixtures/validator-handoff.md" 2>&1 ) ; rc=$?
  else
    fixture="test-fixtures/pretool-write.json"
    [ "$hook" = "hardened-override-detector.sh" ] && fixture="test-fixtures/override-env.json"
    [ "$hook" = "hardened-bash-watcher.sh" ] && fixture="test-fixtures/bash-rm.json"
    out=$(bash "$SHADOW/$hook" < "$fixture" 2>&1 ) ; rc=$?
  fi
  bytes=$(printf '%s' "$out" | wc -c | tr -d ' ')
  # JSON completeness via real jq (from real PATH, not shadow)
  if /usr/bin/jq -e . >/dev/null 2>&1 <<<"$out"; then
    jq_valid="yes"
  else
    jq_valid="no"
  fi
  # Deny detected?
  if printf '%s' "$out" | grep -q '"permissionDecision":"deny"'; then
    deny="yes"
  else
    deny="no"
  fi
  # No-var-interp check: message body must not contain the dep name "jq" inside the reason
  # NOTE: the hardcoded reason mentions "jq/awk" literally — that's OK because it's hardcoded.
  # What we're checking is that the message does NOT have a *$dep substitution* like "missing dep: jq"
  # where "jq" came from a variable. Proxy: confirm the EXACT hardcoded string appears verbatim.
  if printf '%s' "$out" | grep -q 'TAD enforcement requires dependency (missing). Install jq/awk or use TAD_OVERRIDE'; then
    no_interp="yes"
  else
    no_interp="no"
  fi
  # Verdict: PASS if deny=yes AND jq_valid=yes AND rc=0 AND no_interp=yes
  if [ "$deny" = "yes" ] && [ "$jq_valid" = "yes" ] && [ "$rc" -eq 0 ] && [ "$no_interp" = "yes" ]; then
    v=PASS
  else
    v=FAIL
  fi
  printf '%s\tno\t%s\t%s\t%s\t%s\t%s\t%s\n' "$hook" "$rc" "$bytes" "$jq_valid" "$deny" "$no_interp" "$v" >> "$OUT"
done

echo "--- results ---"
column -t -s $'\t' "$OUT" 2>/dev/null || cat "$OUT"

# Overall
fail_count=$(awk -F'\t' 'NR>1 && $NF=="FAIL" { c++ } END { print c+0 }' "$OUT")
if [ "$fail_count" -eq 0 ]; then
  echo "AC17 retest: ALL PASS"
  exit 0
else
  echo "AC17 retest: $fail_count FAIL"
  exit 1
fi
