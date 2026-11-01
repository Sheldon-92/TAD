#!/usr/bin/env bash
# hook-timeout-test.sh — conformance + behavioral test for hook timeout config.
#
# Background: IDEA-20260403-hook-timeout-config (OpenHarness carries a
# `timeout_seconds` field per hook). Claude Code's native spelling of the same
# concept is the per-handler `timeout` field in settings.json — "seconds
# before canceling" (Claude Code hooks reference). TAD's rule, by handler
# type: command / http / prompt = 30s, agent = 60s. An explicit field on every
# handler is what stops a hung hook script from blocking the session forever:
# without it the harness default is 600s for command/http handlers.
#
# Part A (conformance; always runs): parse a settings file (default: the
#   framework template .tad/templates/claude/settings.json — tad.sh copies it
#   to a project's .claude/settings.json and verify_install cmp()s the
#   installed file against it, so the template is the single source) and
#   assert EVERY handler carries a numeric `timeout` equal to the per-type
#   rule. Zero handlers found = FAIL (vacuous-test guard).
#
# Part B (behavioral; runs only when a `claude` binary is present): scratch
#   project whose SessionStart has (1) a hanging command hook `sleep 300`
#   with timeout=2 (test-scale value so the test stays fast; the shipped
#   value is asserted in Part A) and (2) a fast hook writing a marker file.
#   Asserts the run finishes far below 300s (the hanging hook was cut off)
#   and the marker exists (execution continued past the timed-out hook).
#   Whether the harness also prints a timeout warning is captured and
#   reported, not asserted — warning surfacing differs by mode (interactive
#   vs -p). If no `claude` binary exists, Part B prints NOT-RUN with the
#   probe result; it never simulates the harness (a reimplemented runner
#   would validate a copy, not the real enforcement — detect-state-test.sh /
#   tad-backup-test.sh precedent).
#
# Usage:
#   bash hook-timeout-test.sh [settings-file]
# Exit codes: 0 = every part that ran passed; 1 = a check failed;
#             2 = fixture/tool error; 3 = PARTIAL (Part B not run).
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/../../.."
SETTINGS_FILE="${1:-$REPO_ROOT/.tad/templates/claude/settings.json}"

fail_count=0
note() { printf '%s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*"; fail_count=$((fail_count + 1)); }

# ---------------------------------------------------------------- Part A ----
note "== Part A: timeout conformance — $SETTINGS_FILE"
if [ ! -f "$SETTINGS_FILE" ]; then
    note "FATAL: settings file not found: $SETTINGS_FILE" >&2
    exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
    note "FATAL: jq is required for Part A and was not found on PATH" >&2
    exit 2
fi
if ! jq -e . "$SETTINGS_FILE" >/dev/null 2>&1; then
    fail "settings file is not valid JSON"
else
    # One TSV row per handler: event <TAB> type <TAB> timeout (or "MISSING").
    rows="$(jq -r '
      (.hooks // {}) | to_entries[] | .key as $ev | .value[] | .hooks[] |
      [ $ev, (.type // "command"), (if has("timeout") then (.timeout | tostring) else "MISSING" end) ]
      | join("\t")' "$SETTINGS_FILE" || true)"
    if [ -z "$rows" ]; then
        fail "no hook handlers found — conformance would be vacuous"
    fi
    handler_count=0
    # Explicit list iteration via here-string; fields are ASCII, TAB-separated.
    while IFS="$(printf '\t')" read -r ev htype htimeout; do
        [ -z "$ev" ] && continue
        handler_count=$((handler_count + 1))
        case "$htype" in
            command|http|prompt) expected=30 ;;
            agent)               expected=60 ;;
            *)                   expected="" ;;
        esac
        if [ -z "$expected" ]; then
            note "SKIP: $ev type=$htype — no TAD timeout rule for this type"
        elif [ "$htimeout" = "MISSING" ]; then
            fail "$ev type=$htype has NO timeout field (harness default would apply)"
        elif [ "$htimeout" = "$expected" ]; then
            note "PASS: $ev type=$htype timeout=${htimeout}s (rule: ${expected}s)"
        else
            fail "$ev type=$htype timeout=${htimeout}s, expected ${expected}s"
        fi
    done <<EOF_ROWS
$rows
EOF_ROWS
    note "Part A: $handler_count handler(s) checked"
fi

# ---------------------------------------------------------------- Part B ----
part_b_status="not-run"
note "== Part B: behavioral cutoff (requires the Claude Code harness)"
if command -v claude >/dev/null 2>&1; then
    SCRATCH="$(mktemp -d)"
    trap 'rm -rf "$SCRATCH"' EXIT
    mkdir -p "$SCRATCH/.claude"
    cat > "$SCRATCH/.claude/settings.json" <<EOF_JSON
{
  "hooks": {
    "SessionStart": [
      { "matcher": "", "hooks": [ { "type": "command", "command": "sleep 300", "timeout": 2 } ] },
      { "matcher": "", "hooks": [ { "type": "command", "command": "touch \"$SCRATCH/HOOK_CONTINUED_MARKER\"", "timeout": 30 } ] }
    ]
  }
}
EOF_JSON
    # Portable outer guard (shell-portability pattern: gtimeout -> timeout).
    GUARD=""
    if command -v gtimeout >/dev/null 2>&1; then GUARD="gtimeout 90";
    elif command -v timeout >/dev/null 2>&1; then GUARD="timeout 90"; fi
    start_s="$(perl -MTime::HiRes=time -e 'print time' 2>/dev/null || date +%s)"
    ( cd "$SCRATCH" && $GUARD claude -p "reply with the single word: ok" > claude-out.log 2>&1 )
    run_rc=$?
    end_s="$(perl -MTime::HiRes=time -e 'print time' 2>/dev/null || date +%s)"
    elapsed="$(perl -e 'printf "%.1f", $ARGV[1] - $ARGV[0]' "$start_s" "$end_s" 2>/dev/null || echo "unknown")"
    note "Part B: claude run rc=$run_rc elapsed=${elapsed}s (hanging hook sleeps 300s; outer guard 90s)"
    if [ "$run_rc" = "124" ]; then
        fail "run hit the 90s outer guard — hanging hook was NOT cut off by its timeout=2"
    elif [ -f "$SCRATCH/HOOK_CONTINUED_MARKER" ]; then
        note "PASS: fast hook after the hanging one executed (marker written) — session continued"
        part_b_status="pass"
    else
        fail "continuation marker missing — cannot show execution continued past the timed-out hook (see $SCRATCH/claude-out.log while it lasts)"
    fi
    if grep -qi "timed out\|timeout" "$SCRATCH/claude-out.log" 2>/dev/null; then
        note "Part B: harness printed a timeout warning in this mode"
    else
        note "Part B: no timeout warning text captured in this mode (cutoff is the asserted behavior)"
    fi
    rm -rf "$SCRATCH"
    trap - EXIT
else
    note "NOT-RUN: no 'claude' binary on PATH (Part B needs the real harness; nothing is simulated)"
fi

# ---------------------------------------------------------------- verdict ---
if [ "$fail_count" -gt 0 ]; then
    note "RESULT: FAIL ($fail_count failing check(s))"
    exit 1
fi
if [ "$part_b_status" = "not-run" ]; then
    note "RESULT: PARTIAL — Part A passed; Part B not run (see above)"
    exit 3
fi
note "RESULT: PASS"
exit 0
