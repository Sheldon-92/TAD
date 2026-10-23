#!/usr/bin/env bash
# update-reminder-fixture.sh — fast fixture for the session-start update reminder
# (EPIC-20261022-tad-update-flow, Phase 2).
#
# Usage: bash .tad/tests/update-reminder-fixture.sh --case <name>|all
#   --case versions        newer remote -> one line with both versions; equal/older/malformed -> none; numeric compare
#   --case silent-bounded  a failing and a 10 s mock: rc 0, no line, wall time <= baseline + 3 s
#   --case once-a-day      one network call and one line per 24 h; stamps outside the project
#   --case off-switch      the off file means no call and no line, and it survives an upgrade
#   --case delivery        the line reaches the Claude-shaped and the Cursor-shaped output; a call naming no session does nothing
#   --case no-tad          no .tad -> rc 0 and the existing message
#   --case reminder-only   no session-start file names the updater or the installer
#   --emit-mock-curl <dir> <remote-version>   write a mock curl into <dir> (real-path runs) and print the dir
#
# No real network: a mock curl first on PATH answers the version URL. Every run uses a scratch project, a
# scratch TAD_CACHE_DIR, a scratch HOME and a scratch TAD_BACKUP_ROOT. The mock counts calls in
# MOCK_COUNT_FILE and can sleep (MOCK_SLEEP) or fail (MOCK_FAIL).
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
HOOK="$REPO_ROOT/.tad/hooks/startup-health.sh"
CURSOR_SHIM="$REPO_ROOT/.tad/hooks/lib/cursor-session-start.sh"
LINE_TAIL="说'升级 TAD'即可"

write_mock_curl() {
    local dir="$1" ver="$2"
    mkdir -p "$dir"
    cat > "$dir/curl" <<'MOCKEOF'
#!/bin/bash
D="$(cd "$(dirname "$0")" && pwd)"
printf '%s\n' "$*" >> "${MOCK_COUNT_FILE:-$D/count}"
if [ -n "${MOCK_SLEEP:-}" ]; then sleep "$MOCK_SLEEP"; fi
if [ -n "${MOCK_FAIL:-}" ]; then exit 22; fi
cat "${MOCK_REMOTE_FILE:-$D/remote-version}"
MOCKEOF
    chmod +x "$dir/curl"
    printf '%s\n' "$ver" > "$dir/remote-version"
}

if [ "${1:-}" = "--emit-mock-curl" ]; then
    [ $# -ge 3 ] || { echo "update-reminder-fixture: --emit-mock-curl <dir> <remote-version>" >&2; exit 2; }
    write_mock_curl "$2" "$3"
    echo "$2"
    exit 0
fi

CASE=""
while [ $# -gt 0 ]; do
    case "$1" in
        --case) CASE="${2:-}"; shift 2 ;;
        --help|-h) sed -n '2,15p' "$0"; exit 0 ;;
        *) echo "update-reminder-fixture: unknown option '$1'" >&2; exit 2 ;;
    esac
done
[ -n "$CASE" ] || { echo "update-reminder-fixture: --case is required" >&2; exit 2; }

PASS=0 FAIL=0
ok()  { PASS=$((PASS + 1)); echo "  PASS: $1"; }
bad() { FAIL=$((FAIL + 1)); echo "  FAIL: $1"; }

SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT
export HOME="$SANDBOX/home"
export TAD_BACKUP_ROOT="$SANDBOX/backup-root"
mkdir -p "$HOME"
MOCK="$SANDBOX/mockbin"
write_mock_curl "$MOCK" "9.9.9"

# new_project <local version> — a scratch git project holding only .tad/version.txt; prints its dir
# (mktemp, not a counter: the function runs inside $(...) so a counter would not advance)
new_project() {
    local d
    d="$(mktemp -d "$SANDBOX/proj.XXXXXX")"
    mkdir -p "$d/.tad/active"
    printf '%s\n' "$1" > "$d/.tad/version.txt"
    ( cd "$d" && git init -q . && git add -A && git -c user.name=t -c user.email=t@example.invalid commit -q -m init ) >/dev/null 2>&1
    printf '%s' "$d"
}
new_cache() { mktemp -d "$SANDBOX/cache.XXXXXX" | tr -d '\n'; }

ENV_SESSION='{"hook_event_name":"SessionStart","source":"startup","session_id":"sess-1"}'
ENV_NOSESSION='{"hook_event_name":"SessionStart","source":"startup","cwd":"/x"}'

# run_hook <project> <cache> <count file> <remote version> <envelope> [shim] — prints the hook stdout
run_hook() {
    local proj="$1" cache="$2" cnt="$3" rv="$4" env="$5" script="${6:-$HOOK}"
    printf '%s\n' "$rv" > "$MOCK/remote-version"
    ( cd "$proj" && printf '%s' "$env" | PATH="$MOCK:$PATH" TAD_CACHE_DIR="$cache" MOCK_COUNT_FILE="$cnt" bash "$script" 2>/dev/null )
}
# ctx_of <hook stdout> — the decoded additionalContext (Claude shape) or additional_context (Cursor shape)
ctx_of() {
    printf '%s' "$1" | jq -r '(.hookSpecificOutput.additionalContext // .additional_context // empty)' 2>/dev/null
}
count_of() { if [ -f "$1" ]; then wc -l < "$1" | tr -d ' '; else printf '0'; fi; }
lines_with() { printf '%s\n' "$1" | grep -c 'TAD update:' || true; }
now_ms() { perl -MTime::HiRes=time -e 'printf "%d", time * 1000'; }

command -v jq >/dev/null 2>&1 || { echo "update-reminder-fixture: jq is required"; exit 2; }

case_versions() {
    echo "== versions: newer shows one line; equal, older, malformed show none =="
    local p c cnt out ctx
    # newer remote
    p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.v1"
    out="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_SESSION")"; ctx="$(ctx_of "$out")"
    if [ "$(lines_with "$ctx")" = "1" ] && printf '%s' "$ctx" | grep -qF '4.0.7' && printf '%s' "$ctx" | grep -qF '4.0.6' \
       && printf '%s' "$ctx" | grep -qF "$LINE_TAIL" && printf '%s\n' "$ctx" | head -1 | grep -q '^TAD v'; then
        ok "newer remote: exactly one line with both versions and the sentence, after the summary line"
    else
        bad "newer remote: ctx=[$ctx]"
    fi
    # equal, older, malformed
    local rv
    for rv in 4.0.6 4.0.5 "<html>404</html>" "v4.0.7" "4.0" ""; do
        p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.v2"; rm -f "$cnt"
        out="$(run_hook "$p" "$c" "$cnt" "$rv" "$ENV_SESSION")"; ctx="$(ctx_of "$out")"
        if [ "$(lines_with "$ctx")" = "0" ] && [ -n "$ctx" ]; then
            ok "remote '$rv' vs 4.0.6: no reminder line"
        else
            bad "remote '$rv' vs 4.0.6: ctx=[$ctx]"
        fi
    done
    # numeric compare
    p="$(new_project 4.0.9)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.v3"
    out="$(run_hook "$p" "$c" "$cnt" 4.0.10 "$ENV_SESSION")"; ctx="$(ctx_of "$out")"
    if [ "$(lines_with "$ctx")" = "1" ]; then ok "4.0.10 is newer than 4.0.9 (numeric compare)"; else bad "4.0.10 vs 4.0.9: ctx=[$ctx]"; fi
    p="$(new_project 4.0.10)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.v4"
    out="$(run_hook "$p" "$c" "$cnt" 4.0.9 "$ENV_SESSION")"; ctx="$(ctx_of "$out")"
    if [ "$(lines_with "$ctx")" = "0" ]; then ok "4.0.9 is not newer than 4.0.10"; else bad "4.0.9 vs 4.0.10: ctx=[$ctx]"; fi
    # malformed local version
    p="$(new_project 'junk')"; c="$(new_cache)"; cnt="$SANDBOX/cnt.v5"
    out="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_SESSION")"; ctx="$(ctx_of "$out")"
    if [ "$(lines_with "$ctx")" = "0" ]; then ok "malformed local version: no line"; else bad "malformed local: ctx=[$ctx]"; fi
}

case_silent_bounded() {
    echo "== silent-bounded: a failing and a slow mock stay silent and within 3 s of the baseline =="
    local p c cnt out ctx t0 t1 base failw slow rc
    # baseline: the same project with the switch on (no network, no line)
    p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.s0"; : > "$p/.tad/active/update-reminder.off"
    t0="$(now_ms)"; out="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_SESSION")"; rc=$?; t1="$(now_ms)"; base=$((t1 - t0))
    [ "$rc" = "0" ] || bad "baseline rc=$rc"
    # failing mock
    p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.s1"
    t0="$(now_ms)"; out="$( cd "$p" && printf '%s' "$ENV_SESSION" | PATH="$MOCK:$PATH" TAD_CACHE_DIR="$c" MOCK_COUNT_FILE="$cnt" MOCK_FAIL=1 bash "$HOOK" 2>/dev/null )"; rc=$?; t1="$(now_ms)"; failw=$((t1 - t0))
    ctx="$(ctx_of "$out")"
    if [ "$rc" = "0" ] && [ -n "$ctx" ] && [ "$(lines_with "$ctx")" = "0" ] && [ "$failw" -le $((base + 3000)) ]; then
        ok "failing mock: rc 0, no line, wall ${failw} ms (baseline ${base} ms)"
    else
        bad "failing mock: rc=$rc ctx=[$ctx] wall=${failw} ms baseline=${base} ms"
    fi
    # 10 s mock
    p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.s2"
    t0="$(now_ms)"; out="$( cd "$p" && printf '%s' "$ENV_SESSION" | PATH="$MOCK:$PATH" TAD_CACHE_DIR="$c" MOCK_COUNT_FILE="$cnt" MOCK_SLEEP=10 bash "$HOOK" 2>/dev/null )"; rc=$?; t1="$(now_ms)"; slow=$((t1 - t0))
    ctx="$(ctx_of "$out")"
    if [ "$rc" = "0" ] && [ -n "$ctx" ] && [ "$(lines_with "$ctx")" = "0" ] && [ "$slow" -le $((base + 3000)) ]; then
        ok "10 s mock: rc 0, no line, wall ${slow} ms (baseline ${base} ms)"
    else
        bad "10 s mock: rc=$rc ctx=[$ctx] wall=${slow} ms baseline=${base} ms"
    fi
    echo "  wall times: baseline ${base} ms, failing ${failw} ms, 10 s mock ${slow} ms"
    # unwritable cache dir: no network, no line
    p="$(new_project 4.0.6)"; cnt="$SANDBOX/cnt.s3"
    : > "$SANDBOX/not-a-dir"
    out="$(run_hook "$p" "$SANDBOX/not-a-dir/cache" "$cnt" 4.0.7 "$ENV_SESSION")"; ctx="$(ctx_of "$out")"
    if [ "$(count_of "$cnt")" = "0" ] && [ "$(lines_with "$ctx")" = "0" ] && [ -n "$ctx" ]; then
        ok "unwritable cache dir: no network call, no line"
    else
        bad "unwritable cache dir: count=$(count_of "$cnt") ctx=[$ctx]"
    fi
}

case_once_a_day() {
    echo "== once-a-day: one call and one line per 24 h; stamps live outside the project =="
    local p c cnt out1 out2 ctx1 ctx2 now old
    p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.d1"
    out1="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_SESSION")"; ctx1="$(ctx_of "$out1")"
    out2="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_SESSION")"; ctx2="$(ctx_of "$out2")"
    if [ "$(count_of "$cnt")" = "1" ] && [ "$(lines_with "$ctx1")" = "1" ] && [ "$(lines_with "$ctx2")" = "0" ]; then
        ok "two runs: mock count 1, one line in the first run, none in the second"
    else
        bad "two runs: count=$(count_of "$cnt") first=$(lines_with "$ctx1") second=$(lines_with "$ctx2")"
    fi
    # another project the same day: the cached remote is used, no new call, its own line
    local p2
    p2="$(new_project 4.0.6)"
    out2="$(run_hook "$p2" "$c" "$cnt" 4.0.7 "$ENV_SESSION")"; ctx2="$(ctx_of "$out2")"
    if [ "$(count_of "$cnt")" = "1" ] && [ "$(lines_with "$ctx2")" = "1" ]; then
        ok "second project, same day: cached remote used (count 1), its own line"
    else
        bad "second project: count=$(count_of "$cnt") lines=$(lines_with "$ctx2")"
    fi
    # backdate both stamps by one day
    now="$(date +%s)"; old=$((now - 86400))
    printf 'checked_at\t%s\nremote\t4.0.7\n' "$old" > "$c/update-check.tsv"
    printf '%s\n' "$old" > "$c/reminded/$(printf '%s' "$(cd "$p" && pwd -P)" | cksum | cut -d' ' -f1)"
    out1="$(run_hook "$p" "$c" "$cnt" 4.0.8 "$ENV_SESSION")"; ctx1="$(ctx_of "$out1")"
    if [ "$(count_of "$cnt")" = "2" ] && [ "$(lines_with "$ctx1")" = "1" ] && printf '%s' "$ctx1" | grep -qF '4.0.8'; then
        ok "stamps 86400 s old: count 2 and a line with the new remote"
    else
        bad "backdated: count=$(count_of "$cnt") ctx=[$ctx1]"
    fi
    if [ -z "$(cd "$p" && git status --porcelain)" ] && [ -z "$(cd "$p2" && git status --porcelain)" ]; then
        ok "the project trees gained no file"
    else
        bad "project tree changed: $(cd "$p" && git status --porcelain | tr '\n' '|')"
    fi
    if [ -f "$c/update-check.tsv" ] && [ -d "$c/reminded" ]; then ok "stamps are in the cache dir"; else bad "cache stamps missing"; fi
}

case_off_switch() {
    echo "== off-switch: no call and no line, also after an upgrade =="
    local p c cnt out ctx rc
    p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.o1"
    : > "$p/.tad/active/update-reminder.off"
    out="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_SESSION")"; ctx="$(ctx_of "$out")"
    if [ "$(count_of "$cnt")" = "0" ] && [ "$(lines_with "$ctx")" = "0" ] && [ -n "$ctx" ] && [ ! -e "$c/reminded" ] && [ ! -e "$c/update-check.tsv" ]; then
        ok "switch on: count 0, no line, no stamp written"
    else
        bad "switch on: count=$(count_of "$cnt") ctx=[$ctx] cache=$(ls "$c" 2>/dev/null | tr '\n' ' ')"
    fi
    # a real install, the switch, then an upgrade with the installer from this tree
    local q="$SANDBOX/up" ver old
    mkdir -p "$q"
    ver="$(head -1 "$REPO_ROOT/.tad/version.txt" | tr -d '[:space:]')"
    ( cd "$q" && git init -q . && /bin/bash "$REPO_ROOT/tad.sh" --source "$REPO_ROOT" --platform codex --yes ) >"$SANDBOX/up1.log" 2>&1; rc=$?
    if [ "$rc" != "0" ] || [ ! -f "$q/.tad/version.txt" ]; then
        bad "off-switch: could not install into the scratch project (rc=$rc): $(tail -3 "$SANDBOX/up1.log" | tr '\n' '|')"
        return 0
    fi
    : > "$q/.tad/active/update-reminder.off"
    old="$(ls "$REPO_ROOT"/.tad/migrations/*-to-"$ver".yaml 2>/dev/null | head -1 | xargs -n1 basename 2>/dev/null | cut -d- -f1)"
    [ -n "$old" ] || old="4.0.5"
    printf '%s\n' "$old" > "$q/.tad/version.txt"
    ( cd "$q" && /bin/bash "$REPO_ROOT/tad.sh" --source "$REPO_ROOT" --platform codex --yes ) >"$SANDBOX/up2.log" 2>&1; rc=$?
    if [ "$rc" = "0" ] && [ "$(head -1 "$q/.tad/version.txt" | tr -d '[:space:]')" = "$ver" ] && [ -f "$q/.tad/active/update-reminder.off" ]; then
        ok "the upgrade ran (rc 0, $old -> $ver) and the off file is still there"
    else
        bad "upgrade rc=$rc version=$(cat "$q/.tad/version.txt") switch=$([ -f "$q/.tad/active/update-reminder.off" ] && echo present || echo gone): $(tail -3 "$SANDBOX/up2.log" | tr '\n' '|')"
    fi
    cnt="$SANDBOX/cnt.o2"; c="$(new_cache)"
    printf '%s\n' "9.9.9" > "$MOCK/remote-version"
    out="$( cd "$q" && printf '%s' "$ENV_SESSION" | PATH="$MOCK:$PATH" TAD_CACHE_DIR="$c" MOCK_COUNT_FILE="$cnt" bash "$q/.tad/hooks/startup-health.sh" 2>/dev/null )"; ctx="$(ctx_of "$out")"
    if [ "$(count_of "$cnt")" = "0" ] && [ "$(lines_with "$ctx")" = "0" ] && [ -n "$ctx" ]; then
        ok "after the upgrade the installed hook still honours the switch (count 0, no line)"
    else
        bad "after the upgrade: count=$(count_of "$cnt") ctx=[$ctx]"
    fi
}

case_delivery() {
    echo "== delivery: the line reaches Claude- and Cursor-shaped output; a call naming no session does nothing =="
    local p c cnt out ctx
    p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.l1"
    out="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_SESSION")"
    if printf '%s' "$out" | jq -e '.hookSpecificOutput.additionalContext | contains("TAD update: 4.0.7")' >/dev/null 2>&1; then
        ok "startup-health JSON additionalContext carries the line"
    else
        bad "startup-health output: $out"
    fi
    p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.l2"
    out="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_SESSION" "$CURSOR_SHIM")"
    if printf '%s' "$out" | jq -e '.additional_context | contains("TAD update: 4.0.7")' >/dev/null 2>&1; then
        ok "cursor-session-start.sh additional_context carries the line"
    else
        bad "cursor shim output: $out"
    fi
    # the OpenCode envelope exactly as tad-hooks.ts builds it: no session id
    p="$(new_project 4.0.6)"; c="$(new_cache)"; cnt="$SANDBOX/cnt.l3"
    out="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_NOSESSION")"; ctx="$(ctx_of "$out")"
    if [ "$(count_of "$cnt")" = "0" ] && [ "$(lines_with "$ctx")" = "0" ] && [ -n "$ctx" ] \
       && [ -z "$(ls "$c/reminded" 2>/dev/null)" ] && [ ! -e "$c/update-check.tsv" ]; then
        ok "no session named: mock count 0, no line, no reminded/ file, no check stamp"
    else
        bad "no session named: count=$(count_of "$cnt") ctx=[$ctx] reminded=$(ls "$c/reminded" 2>/dev/null | tr '\n' ' ')"
    fi
    out="$(run_hook "$p" "$c" "$cnt" 4.0.7 "$ENV_SESSION")"; ctx="$(ctx_of "$out")"
    if [ "$(lines_with "$ctx")" = "1" ] && [ "$(count_of "$cnt")" = "1" ]; then
        ok "a following session-named call the same day still prints the line"
    else
        bad "following call: count=$(count_of "$cnt") ctx=[$ctx]"
    fi
}

case_no_tad() {
    echo "== no-tad: no .tad directory keeps the existing message =="
    local d="$SANDBOX/notad" c cnt out ctx rc
    mkdir -p "$d"; c="$(new_cache)"; cnt="$SANDBOX/cnt.n1"
    out="$( cd "$d" && printf '%s' "$ENV_SESSION" | PATH="$MOCK:$PATH" TAD_CACHE_DIR="$c" MOCK_COUNT_FILE="$cnt" bash "$HOOK" 2>/dev/null )"; rc=$?
    ctx="$(ctx_of "$out")"
    if [ "$rc" = "0" ] && [ "$ctx" = "TAD not initialized in this project." ] && [ "$(count_of "$cnt")" = "0" ]; then
        ok "no .tad: rc 0, the existing message, no network call"
    else
        bad "no .tad: rc=$rc ctx=[$ctx] count=$(count_of "$cnt")"
    fi
}

case_reminder_only() {
    echo "== reminder-only: the session-start files never name the updater or the installer =="
    local hits
    if [ ! -f "$REPO_ROOT/.tad/hooks/lib/update-reminder.sh" ]; then bad "update-reminder.sh missing"; return 0; fi
    hits="$(cat "$REPO_ROOT/.tad/hooks/startup-health.sh" "$REPO_ROOT/.tad/hooks/lib/update-reminder.sh" "$REPO_ROOT/.tad/hooks/lib/cursor-session-start.sh" "$REPO_ROOT/.opencode/plugins/tad-hooks.ts" \
        | grep -E 'tad-update\.sh|tad\.sh' | grep -vcE '^[[:space:]]*(#|//)' || true)"
    if [ "$hits" = "0" ]; then ok "no non-comment line names tad-update.sh or tad.sh"; else bad "$hits non-comment line(s) name the updater or installer"; fi
}

case "$CASE" in
    versions) case_versions ;;
    silent-bounded) case_silent_bounded ;;
    once-a-day) case_once_a_day ;;
    off-switch) case_off_switch ;;
    delivery) case_delivery ;;
    no-tad) case_no_tad ;;
    reminder-only) case_reminder_only ;;
    all) case_versions; case_silent_bounded; case_once_a_day; case_off_switch; case_delivery; case_no_tad; case_reminder_only ;;
    *) echo "update-reminder-fixture: unknown --case '$CASE'" >&2; exit 2 ;;
esac

echo ""
echo "=== Summary ==="
echo "  PASS: $PASS  FAIL: $FAIL"
if [ "$FAIL" -gt 0 ]; then
    echo "VERDICT: FAIL"
    exit 1
fi
echo "VERDICT: PASS"
