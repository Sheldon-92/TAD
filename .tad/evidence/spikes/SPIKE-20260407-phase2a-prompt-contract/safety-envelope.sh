#!/bin/bash
# Phase 2a safety envelope — sourced by probe runners.
# Per HANDOFF §4.3, trap is crash safety net only. Explicit restore_and_verify
# is called between every probe on the normal path.

set -euo pipefail

SETTINGS=".claude/settings.json"
BACKUP="${SETTINGS}.phase2a-backup-$(date +%s)-$$"  # P1-2 fix: add PID to avoid second-resolution collision on re-source
SPIKE_DIR=".tad/evidence/spikes/SPIKE-20260407-phase2a-prompt-contract"
SENTINEL="/tmp/phase2a-sentinel.log"
OBS_LOG="$SPIKE_DIR/observations.log"
SHA_BEFORE=$(shasum -a 256 "$SETTINGS" | awk '{print $1}')

cp "$SETTINGS" "$BACKUP"
echo "🔒 backup: $BACKUP"
echo "🔒 sha_before: $SHA_BEFORE"

# Crash safety net
trap '
  if [ -f "$BACKUP" ]; then
    cp "$BACKUP" "$SETTINGS" 2>/dev/null || true
    echo "⚠️  TRAP FIRED — attempted emergency restore" >&2
  fi
' EXIT INT TERM

restore_and_verify() {
  cp "$BACKUP" "$SETTINGS"
  local SHA_NOW
  SHA_NOW=$(shasum -a 256 "$SETTINGS" | awk '{print $1}')
  if [ "$SHA_BEFORE" = "$SHA_NOW" ]; then
    printf '  ✅ restore_and_verify OK (%s)\n' "$(date +%T)"
  else
    printf '  ❌ SHA MISMATCH — STOP\n     before: %s\n     after:  %s\n' \
      "$SHA_BEFORE" "$SHA_NOW" >&2
    exit 2
  fi
}

validate_settings() {
  if ! jq . "$SETTINGS" >/dev/null 2>&1; then
    echo "  ❌ settings.json invalid JSON — restoring" >&2
    cp "$BACKUP" "$SETTINGS"
    exit 3
  fi
  printf '  ✅ validate_settings OK\n'
}

reset_sentinel() {
  rm -f "$SENTINEL"
  touch "$SENTINEL"
  printf '  ♻️  sentinel reset\n'
}

install_probe() {
  local probe_name="$1"
  local probe_json="$2"
  # Use python to merge the probe's UserPromptSubmit into settings
  python3 - "$SETTINGS" "$probe_json" <<'PY'
import json, sys
settings_path, probe_path = sys.argv[1], sys.argv[2]
with open(settings_path) as f:
    s = json.load(f)
with open(probe_path) as f:
    probe = json.load(f)
s.setdefault("hooks", {})["UserPromptSubmit"] = probe["UserPromptSubmit"]
with open(settings_path, "w") as f:
    json.dump(s, f, indent=2)
PY
  validate_settings
  printf '  📝 installed %s\n' "$probe_name"
}

run_probe_via_cli() {
  # Spawn claude -p in a CLEAN cwd and measure wall time.
  # Runs in /tmp to minimize CLAUDE.md re-discovery per Phase 1 findings.
  local probe_name="$1"
  local user_msg="$2"
  local t0 t1
  t0=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000')
  local out
  # Use the real project cwd so settings.json is picked up, but send a minimal
  # system prompt to reduce overhead
  out=$(printf '%s' "$user_msg" | claude -p \
    --model claude-sonnet-4-6 \
    --output-format json \
    --no-session-persistence \
    --system-prompt "You are in a Phase 2a hook probe test. If you see any marker string like P1A-FIRED, P2-ENVELOPE-TEST, P3-PERMISSION-TEST, P4-FILTER-PASSED, or SPIKE-TEST-MARKER in your context, respond with exactly: MARKER:<marker_name>. Otherwise respond: MARKER:NONE. One line only." \
    --tools '' 2>&1 || true)
  t1=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000')
  local wall_ms=$((t1 - t0))
  printf '%s' "$out" > "$SPIKE_DIR/out-${probe_name}.json"
  printf '  ⏱  %s wall: %sms\n' "$probe_name" "$wall_ms"

  # Inspect output
  python3 - "$probe_name" "$wall_ms" "$SPIKE_DIR/out-${probe_name}.json" "$SENTINEL" "$OBS_LOG" <<'PY'
import json, sys, os
name, wall_ms, out_path, sentinel_path, obs_path = sys.argv[1:]
try:
    d = json.load(open(out_path))
except Exception as e:
    d = {"error": str(e), "raw": open(out_path).read()[:300]}

sentinel_content = ""
if os.path.exists(sentinel_path):
    sentinel_content = open(sentinel_path).read()

result = d.get("result", "") if isinstance(d, dict) else ""
duration_ms = d.get("duration_ms") if isinstance(d, dict) else None
api_ms = d.get("duration_api_ms") if isinstance(d, dict) else None
is_error = d.get("is_error") if isinstance(d, dict) else None

print(f"  [{name}] wall={wall_ms}ms duration={duration_ms}ms api={api_ms}ms is_error={is_error}")
print(f"  [{name}] result: {repr(result)[:200]}")
print(f"  [{name}] sentinel lines: {sentinel_content.count(chr(10))}")
if sentinel_content.strip():
    # Print first 300 chars of sentinel so we can see payload shape
    preview = sentinel_content[:300].replace(chr(10), " | ")
    print(f"  [{name}] sentinel preview: {preview}")

# Append to observations log
with open(obs_path, "a") as f:
    f.write(f"\n=== {name} ===\n")
    f.write(f"wall_ms: {wall_ms}\n")
    f.write(f"duration_ms: {duration_ms}\n")
    f.write(f"api_ms: {api_ms}\n")
    f.write(f"is_error: {is_error}\n")
    f.write(f"result: {repr(result)}\n")
    f.write(f"sentinel_lines: {sentinel_content.count(chr(10))}\n")
    f.write(f"sentinel_content: {sentinel_content[:1500]}\n")
PY
}
