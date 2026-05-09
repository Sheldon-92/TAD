#!/usr/bin/env bash
# AC-P1.4 — userprompt-domain-router.sh event filter
# Covers: AC-P1.4-a (real user prompt still matches), -b/c/d (system-injected skipped),
#         -e (dogfood fixture), -g (latency), -h (literal tag edge case)
# AC-P1.4-f (30-case regression) → run via separate run-phase2b-tests.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../../../" && pwd)"
HOOK="${REPO_ROOT}/.tad/hooks/userprompt-domain-router.sh"
FIXTURE_DIR="${REPO_ROOT}/.tad/evidence/completions/phase1-state-consistency/fixtures/p1.4"

if [ ! -x "$HOOK" ]; then
  echo "FAIL: hook not executable: $HOOK"
  exit 1
fi

PASS=0
FAIL=0

# Invoke hook with a prompt string. Returns stdout (JSON or empty), stderr, rc.
_invoke_hook() {
  local prompt="$1"
  local stdout_file stderr_file rc
  stdout_file=$(mktemp); stderr_file=$(mktemp)
  # Build JSON envelope matching Claude Code's UserPromptSubmit format
  local json
  json=$(jq -n --arg p "$prompt" '{session_id:"test",transcript_path:"/tmp/t",cwd:"/tmp",permission_mode:"default",hook_event_name:"UserPromptSubmit",prompt:$p}')
  printf '%s' "$json" | bash "$HOOK" >"$stdout_file" 2>"$stderr_file"
  rc=$?
  # Echo stdout for caller to inspect
  cat "$stdout_file"
  rm -f "$stdout_file" "$stderr_file"
  return "$rc"
}

_assert_match() {
  local name="$1" prompt_file="$2"
  # P0-B fix (CR review 2026-04-27): file uses $REPO_ROOT (defined at line 9 of this script),
  # NOT $SCRIPT_DIR. Verified: `grep -n REPO_ROOT AC-P1.4-router-event-filter.sh` line 9.
  local out log="${REPO_ROOT}/.tad/hooks/.router.log"

  # Capture pre-invoke log line count.
  # P0-C fix (CR review 2026-04-27): `wc -l < missing 2>/dev/null | tr -d ' ' || echo 0`
  # produces empty string not "0" because `tr` succeeds on empty stdin so `||` never fires.
  # Use parameter expansion fallback `${var:-0}` AFTER assignment.
  local pre_count post_count
  pre_count=$(wc -l < "$log" 2>/dev/null | tr -d ' ')
  pre_count="${pre_count:-0}"

  out=$(_invoke_hook "$(cat "$prompt_file")")

  # passive mode (2.8.4): hook never emits stdout context — read .router.log instead
  post_count=$(wc -l < "$log" 2>/dev/null | tr -d ' ')
  post_count="${post_count:-0}"

  local last_pack
  if [ "$post_count" -gt "$pre_count" ]; then
    last_pack=$(tail -1 "$log" 2>/dev/null | awk '{print $3}')
  else
    last_pack="NO_LOG_DELTA"
  fi
  if [ -n "$last_pack" ] && [ "$last_pack" != "none" ] && [ "$last_pack" != "NO_LOG_DELTA" ] && [ "$last_pack" != "whitelist_early_exit" ]; then
    printf '[PASS] %s (hook scored pack: %s)\n' "$name" "$last_pack"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] %s (expected non-none pack, got: %s)\n' "$name" "$last_pack"
    FAIL=$((FAIL + 1))
  fi
}

_assert_skip() {
  local name="$1" prompt_file="$2"
  local out
  out=$(_invoke_hook "$(cat "$prompt_file")")
  if [ -z "$out" ]; then
    printf '[PASS] %s (hook skipped, stdout empty)\n' "$name"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] %s (expected empty stdout, got: %q)\n' "$name" "$out"
    FAIL=$((FAIL + 1))
  fi
}

# ── AC-P1.4-a: real user prompt triggers keyword match (web-deployment) ──
_assert_match "AC-P1.4-a real Vercel prompt → hook matches" \
  "${FIXTURE_DIR}/real-user-vercel.txt"

# ── AC-P1.4-b: <task-notification> Vercel content → skip ──
_assert_skip "AC-P1.4-b task-notification Vercel → filtered" \
  "${FIXTURE_DIR}/task-notification-vercel.txt"

# ── AC-P1.4-c: <system-reminder> → skip ──
_assert_skip "AC-P1.4-c system-reminder → filtered" \
  "${FIXTURE_DIR}/system-reminder.txt"

# ── AC-P1.4-d: <function_results> → skip ──
_assert_skip "AC-P1.4-d function_results → filtered" \
  "${FIXTURE_DIR}/function-results.txt"

# ── AC-P1.4-e: dogfood fixture — ai-tool-integration task-notification ──
_assert_skip "AC-P1.4-e dogfood task-notification ai-tool-integration → filtered" \
  "${FIXTURE_DIR}/task-notification-aitool.txt"

# ── AC-P1.4-h: literal <task-notification> tag inside user prompt (silent skip, acceptable) ──
edge_prompt='我想问这个 <task-notification> tag 在 hook 里是什么意思'
out=$(_invoke_hook "$edge_prompt")
if [ -z "$out" ]; then
  printf '[PASS] AC-P1.4-h literal tag string → silent skip (documented Decision #7)\n'
  PASS=$((PASS + 1))
else
  printf '[FAIL] AC-P1.4-h unexpected output: %q\n' "$out"
  FAIL=$((FAIL + 1))
fi

# ── AC-P1.4-g: latency measurement (N≥30, p95 < 200ms) ──
# Single perl process loops N invocations, timing each hook call end-to-end.
# Hook stdout discarded (we measure latency, not content).
echo
echo "== AC-P1.4-g latency benchmark (N=30) =="
N=30
PERF_TSV="${REPO_ROOT}/.tad/evidence/completions/phase1-state-consistency/perf-P1.4-router.tsv"

# Build JSON envelope once (ammortize)
prompt_content=$(cat "${FIXTURE_DIR}/real-user-vercel.txt")
envelope_file=$(mktemp)
jq -n --arg p "$prompt_content" '{session_id:"test",prompt:$p}' > "$envelope_file"

# Header
printf 'iteration\telapsed_ms\n' > "$PERF_TSV"

# Single perl process runs N iterations.
# Hook stdout redirected to /dev/null via fork+exec (measure latency, not content).
perl -MTime::HiRes=time -e '
  my ($hook, $json_file, $n) = @ARGV;
  open(my $jf, "<", $json_file) or die;
  my $json_body = do { local $/; <$jf> };
  close $jf;
  for my $i (1..$n) {
    my $t0 = time();
    # Fork child, redirect its stdout+stderr to /dev/null, then exec hook
    my $pid = open(my $fh, "|-");
    die "fork failed: $!" unless defined $pid;
    if ($pid == 0) {
      open(STDOUT, ">", "/dev/null") or exit(1);
      open(STDERR, ">", "/dev/null") or exit(1);
      exec("bash", $hook) or exit(127);
    }
    print $fh $json_body;
    close $fh;
    my $elapsed_ms = (time() - $t0) * 1000;
    printf STDOUT "%d\t%.3f\n", $i, $elapsed_ms;
  }
' -- "$HOOK" "$envelope_file" "$N" >> "$PERF_TSV"
rm -f "$envelope_file"

# Compute p50, p95 via awk + sort
sorted=$(awk 'NR>1 {print $2}' "$PERF_TSV" | sort -n)
count=$(printf '%s\n' "$sorted" | wc -l | tr -d ' ')
if [ "$count" -ge 30 ]; then
  p50_idx=$(( (count * 50 + 99) / 100 ))
  p95_idx=$(( (count * 95 + 99) / 100 ))
  p50=$(printf '%s\n' "$sorted" | sed -n "${p50_idx}p")
  p95=$(printf '%s\n' "$sorted" | sed -n "${p95_idx}p")
  max=$(printf '%s\n' "$sorted" | tail -1)
  printf '  N=%d  p50=%sms  p95=%sms  max=%sms\n' "$count" "$p50" "$p95" "$max"

  # AC gate: p95 < 200ms
  p95_int=${p95%.*}
  if [ "$p95_int" -lt 200 ]; then
    printf '[PASS] AC-P1.4-g p95 latency < 200ms (%sms)\n' "$p95"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] AC-P1.4-g p95 latency %sms exceeds 200ms\n' "$p95"
    FAIL=$((FAIL + 1))
  fi
else
  printf '[FAIL] AC-P1.4-g only %d samples collected (expected ≥30)\n' "$count"
  FAIL=$((FAIL + 1))
fi

printf '\n== Summary: %d passed, %d failed ==\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
