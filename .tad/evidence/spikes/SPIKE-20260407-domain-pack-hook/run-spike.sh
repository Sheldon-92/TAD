#!/bin/bash
# SPIKE-20260407 — Domain Pack Hook Spike runner
#
# Purpose: validate UserPromptSubmit hook + Haiku-4.5 classification accuracy.
# Per HANDOFF-20260407-domain-pack-hook-spike Component 4.
#
# IMPORTANT — proxy mode:
#   The handoff §4.2 specifies Path B uses `curl https://api.anthropic.com/v1/messages`
#   with $ANTHROPIC_API_KEY. In this spike's environment that key is not set.
#   Per human decision (see SPIKE-REPORT §2 Mechanism Findings), Path B is
#   executed via `claude -p --model claude-haiku-4-5-20251001 --output-format json`
#   which uses the active OAuth session. Caveats:
#     - Latency includes claude CLI process spawn overhead (~300-500ms)
#     - Cost figures come from OAuth tier accounting, not raw per-token API price
#     - The same Haiku-4.5 model is invoked, so accuracy is canonical
#   Direct curl mode is preserved as `--mode curl` for the future-when-key-is-set.
#
# BSD-compatibility: macOS BSD bash, no GNU-only flags.
# Hard timebox: 4.5h (HARD_CAP_SECONDS).
#
# AC coverage: AC9 (settings restore), AC10 (BSD compat), AC11 (timebox).

set -euo pipefail

# ─── Configuration ──────────────────────────────────────────────────────────
SPIKE_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SPIKE_DIR/../../../.." && pwd)"
SETTINGS_FILE="$PROJECT_ROOT/.claude/settings.json"
BACKUP_FILE="${SETTINGS_FILE}.spike-backup-$(date +%s)"
SENTINEL_LOG="/tmp/tad-spike-userprompt-fired.log"
RESULTS_JSON="$SPIKE_DIR/results.json"
TEST_CASES="$SPIKE_DIR/test-cases.yaml"
PROMPT_TEMPLATE="$SPIKE_DIR/haiku-prompt-template.md"
HOOK_SNIPPET="$SPIKE_DIR/hook-poc-snippet.json"

START_TIME=$(date +%s)
HARD_CAP_SECONDS=$((4 * 3600 + 1800))  # 4.5 hours

MODE="${1:-proxy}"   # proxy | curl | path-a-install | path-a-restore | metrics-only

# ─── Safety: backup + trap restore (AC9) ────────────────────────────────────
backup_settings() {
  if [ -f "$SETTINGS_FILE" ]; then
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    printf '✅ settings.json backed up to %s\n' "$BACKUP_FILE"
  else
    printf '⚠️  no existing settings.json — skipping backup\n'
  fi
}

restore_settings() {
  if [ -f "$BACKUP_FILE" ]; then
    if cp "$BACKUP_FILE" "$SETTINGS_FILE"; then
      printf '✅ settings.json RESTORED from %s\n' "$BACKUP_FILE"
      # AC9 verification: byte-identical check via diff (not grep)
      if diff -q "$SETTINGS_FILE" "$BACKUP_FILE" >/dev/null 2>&1; then
        printf '✅ AC9 PASS: settings.json byte-identical to backup\n'
      else
        printf '❌ AC9 FAIL: diff between settings.json and backup is non-empty\n'
        return 1
      fi
    else
      printf '❌ RESTORE FAILED — manual cleanup needed: %s\n' "$BACKUP_FILE" >&2
      return 1
    fi
  fi
}

# trap is set ONLY for modes that touch settings.json
# (proxy mode never touches settings.json — safe to skip backup)

# ─── Timebox check (AC11) ───────────────────────────────────────────────────
check_timebox() {
  local elapsed=$(($(date +%s) - START_TIME))
  if [ "$elapsed" -gt "$HARD_CAP_SECONDS" ]; then
    printf '❌ Timebox exceeded (%ss > %ss) — aborting\n' "$elapsed" "$HARD_CAP_SECONDS" >&2
    exit 2
  fi
}

# ─── Dependency check ──────────────────────────────────────────────────────
check_deps() {
  local missing=0
  for cmd in jq python3 perl claude; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      printf '❌ missing dependency: %s\n' "$cmd" >&2
      missing=1
    fi
  done
  if [ "$missing" -ne 0 ]; then
    exit 3
  fi
}

# ─── Read test cases ────────────────────────────────────────────────────────
# python3 is the BSD-portable YAML parser (no yq dep on macOS by default)
load_cases() {
  python3 -c "
import yaml, json
with open('$TEST_CASES') as f:
    d = yaml.safe_load(f)
print(json.dumps(d['test_cases']))
"
}

# ─── Build classification prompt for one case ───────────────────────────────
build_prompt() {
  local message="$1"
  # Substitute {user_message} into the template's prompt section.
  # python3 used to avoid sed escaping hell with arbitrary user content.
  python3 -c "
import sys
msg = sys.argv[1]
# Hard-coded prompt body (kept in sync with haiku-prompt-template.md)
template = '''You are a strict classifier for AI development assistant tasks. Given a user message, decide which capabilities (if any) it relates to.

Available capabilities:
- pack: web-frontend
  capability: component_development
  description: Building reusable UI components in React/Vue/Angular, including state management, props design, lifecycle handling, component composition, and UI element creation (buttons, forms, modals, lists, etc.).

User message: \"{msg}\"

Match guidelines:
- match if user primary intent is producing runnable component code/markup
- discussions ABOUT components without intent to build = no match
- tasks where component work is >50% of effort (e.g. login page) = match
- short affirmation/chat messages (thanks, ok, yes) = no match, return empty matched_packs
- vague topics (performance optimization) that do not pin to component_development = no match

CRITICAL OUTPUT FORMAT:
- entire response must be parseable by jq
- first character MUST be {{, last MUST be }}
- NO markdown code fences (no triple-backtick json)
- NO text before {{ or after }}
- NO preamble
- maximum 80 tokens output, keep reason to <= 12 words

Schema:
{{\"matched_packs\":[{{\"pack\":\"web-frontend\",\"capability\":\"component_development\",\"confidence\":0.0-1.0,\"reason\":\"<= 12 words\"}}],\"matched_recipes\":[]}}

If no match: {{\"matched_packs\":[],\"matched_recipes\":[]}}'''
print(template.format(msg=msg))
" "$message"
}

# ─── Path B (proxy mode): call Haiku via `claude -p` ────────────────────────
run_path_b_proxy() {
  local message="$1"
  local prompt
  prompt=$(build_prompt "$message")

  local wall_start
  wall_start=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000')

  # claude -p with strict JSON output. Use a clean tempdir as cwd to minimize
  # CLAUDE.md auto-discovery overhead. --tools '' disables all tools so the
  # model only does inference, no skill loading or sub-agents.
  local raw
  raw=$(printf '%s' "$prompt" | (cd /tmp && claude -p \
    --model claude-haiku-4-5-20251001 \
    --output-format json \
    --no-session-persistence \
    --setting-sources user \
    --system-prompt "You output JSON only. No prose, no markdown fences." \
    --tools '' 2>&1)) || true

  local wall_end
  wall_end=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000')
  local wall_ms=$((wall_end - wall_start))

  # Parse the claude -p envelope. Robust against non-JSON error output.
  printf '%s' "$raw" | python3 -c "
import sys, json
raw = sys.stdin.read()
try:
    d = json.loads(raw)
except Exception as e:
    print(json.dumps({'parse_envelope_ok': False, 'raw_error': str(e), 'raw': raw[:500]}))
    sys.exit(0)
result_text = d.get('result', '')
# Strip code fences if present (handle the smoke-test failure mode)
import re
fenced = re.match(r'^\s*\`\`\`(?:json)?\s*\n(.*)\n\`\`\`\s*$', result_text, re.DOTALL)
if fenced:
    cleaned = fenced.group(1)
else:
    cleaned = result_text.strip()
parse_ok = True
matched = None
try:
    matched = json.loads(cleaned)
    if not isinstance(matched, dict) or 'matched_packs' not in matched:
        parse_ok = False
except Exception:
    parse_ok = False
out = {
    'parse_envelope_ok': True,
    'parse_ok': parse_ok,
    'wall_ms_external': $wall_ms,
    'duration_ms': d.get('duration_ms'),
    'duration_api_ms': d.get('duration_api_ms'),
    'cost_usd': d.get('total_cost_usd'),
    'input_tokens': d.get('usage', {}).get('input_tokens'),
    'output_tokens': d.get('usage', {}).get('output_tokens'),
    'cache_read': d.get('usage', {}).get('cache_read_input_tokens'),
    'cache_creation': d.get('usage', {}).get('cache_creation_input_tokens'),
    'raw_result_text': result_text,
    'parsed_envelope': matched,
}
print(json.dumps(out, ensure_ascii=False))
"
}

# ─── Path B (curl mode): canonical direct API ───────────────────────────────
# Preserved for future use when ANTHROPIC_API_KEY is available.
run_path_b_curl() {
  local message="$1"
  if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    printf '{"error":"ANTHROPIC_API_KEY not set"}'
    return 1
  fi
  local prompt
  prompt=$(build_prompt "$message")
  local payload
  payload=$(python3 -c "
import json, sys
prompt = sys.argv[1]
print(json.dumps({
    'model': 'claude-haiku-4-5-20251001',
    'max_tokens': 200,
    'messages': [{'role': 'user', 'content': prompt}]
}))
" "$prompt")
  local wall_start
  wall_start=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000')
  local raw
  raw=$(curl -sS https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "$payload")
  local wall_end
  wall_end=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000')
  printf '%s' "$raw" | python3 -c "
import sys, json
d = json.loads(sys.stdin.read())
text = d.get('content', [{}])[0].get('text', '')
print(json.dumps({
    'wall_ms_external': $((wall_end - wall_start)),
    'duration_ms': $((wall_end - wall_start)),
    'duration_api_ms': $((wall_end - wall_start)),
    'cost_usd': None,  # would compute from usage if needed
    'input_tokens': d.get('usage', {}).get('input_tokens'),
    'output_tokens': d.get('usage', {}).get('output_tokens'),
    'raw_result_text': text,
}))
"
}

# ─── Mode dispatch ─────────────────────────────────────────────────────────
case "$MODE" in
  proxy)
    check_deps
    check_timebox
    printf '🚀 Spike Path B in proxy mode (claude -p) — running 18 cases\n'
    printf '%s\n' "----"
    cases_json=$(load_cases)
    total=$(printf '%s' "$cases_json" | jq 'length')
    printf 'Loaded %s cases\n' "$total"
    # Note: actual loop driven by external orchestrator (this script's
    # `single` mode is called per-case to enable parallelism + checkpoint).
    printf '\nTo run a single case: %s single <message>\n' "$0"
    ;;

  single)
    # P0-2 fix: hot-path modes must enforce timebox + deps too
    check_deps
    check_timebox
    shift
    msg="${1:?usage: $0 single <message>}"
    run_path_b_proxy "$msg"
    ;;

  curl-single)
    # P0-2 fix: hot-path modes must enforce timebox + deps too
    check_deps
    check_timebox
    shift
    msg="${1:?usage: $0 curl-single <message>}"
    run_path_b_curl "$msg"
    ;;

  path-a-install)
    # P0-3 fix: refuse to install if a previous spike-backup is still present
    # (otherwise a double-install would capture the already-modified state as
    #  the "original" and silently corrupt the byte-identical guarantee).
    existing_backup=$(ls "${SETTINGS_FILE}".spike-backup-* 2>/dev/null | head -1 || true)
    if [ -n "$existing_backup" ]; then
      printf '❌ un-restored backup exists: %s\n' "$existing_backup" >&2
      printf '   run `%s path-a-restore` first, or remove it manually\n' "$0" >&2
      exit 6
    fi
    # Merge UserPromptSubmit hook into settings.json
    backup_settings
    trap 'restore_settings || true' EXIT INT TERM
    python3 -c "
import json
with open('$SETTINGS_FILE') as f:
    s = json.load(f)
with open('$HOOK_SNIPPET') as f:
    snippet = json.load(f)
s.setdefault('hooks', {})['UserPromptSubmit'] = snippet['UserPromptSubmit']
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(s, f, indent=2)
print('✅ UserPromptSubmit hook installed in', '$SETTINGS_FILE')
"
    rm -f "$SENTINEL_LOG"
    printf '🧪 Now manually start a NEW claude session and type a test message.\n'
    printf '   Then run: %s path-a-restore\n' "$0"
    printf '   Backup file: %s\n' "$BACKUP_FILE"
    # Disable trap so backup persists for the manual phase
    trap - EXIT INT TERM
    ;;

  path-a-restore)
    # Find the most-recent backup file (don't rely on this script's $BACKUP_FILE timestamp)
    latest=$(ls -t "$SETTINGS_FILE".spike-backup-* 2>/dev/null | head -1 || true)
    if [ -z "$latest" ]; then
      printf '❌ no backup file found at %s.spike-backup-*\n' "$SETTINGS_FILE" >&2
      exit 4
    fi
    printf '🔁 restoring from %s\n' "$latest"
    cp "$latest" "$SETTINGS_FILE"
    if diff -q "$SETTINGS_FILE" "$latest" >/dev/null 2>&1; then
      printf '✅ AC9 PASS: byte-identical restore\n'
      printf 'Sentinel log status:\n'
      if [ -f "$SENTINEL_LOG" ]; then
        wc -l "$SENTINEL_LOG"
        cat "$SENTINEL_LOG"
      else
        printf '⚠️  sentinel log absent — possible silent ignore\n'
      fi
    else
      printf '❌ AC9 FAIL\n'
      exit 5
    fi
    ;;

  *)
    printf 'usage: %s {proxy|single <msg>|curl-single <msg>|path-a-install|path-a-restore}\n' "$0" >&2
    exit 1
    ;;
esac

check_timebox
