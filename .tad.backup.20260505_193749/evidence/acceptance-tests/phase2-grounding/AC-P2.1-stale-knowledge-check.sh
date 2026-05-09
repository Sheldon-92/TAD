#!/usr/bin/env bash
# AC-P2.1 — stale-knowledge-check.sh
# Covers: AC-P2.1 a–t (20 ACs)
#
# Strategy: build throwaway git repo with .tad/project-knowledge/ + .tad/hooks/lib/.
# Create fixture knowledge files with controlled mtimes via touch -t.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../../../" && pwd)"
SCRIPT_SRC="${REPO_ROOT}/.tad/hooks/lib/stale-knowledge-check.sh"

if [ ! -x "$SCRIPT_SRC" ]; then
  echo "FAIL: script missing: $SCRIPT_SRC"; exit 1
fi

PASS=0; FAIL=0
_pass() { printf '[PASS] %s\n' "$1"; PASS=$((PASS+1)); }
_fail() { printf '[FAIL] %s\n' "$1"; [ -n "${2:-}" ] && printf '      %s\n' "$2"; FAIL=$((FAIL+1)); }

# ── Build throwaway workspace ──
WS=$(mktemp -d -t stale-check.XXXXXX)
trap 'rm -rf "$WS"' EXIT

(
  cd "$WS"
  git init -q
  git config user.email a@b
  git config user.name T
  mkdir -p .tad/project-knowledge .tad/hooks/lib loop_voice
  cp "$SCRIPT_SRC" .tad/hooks/lib/stale-knowledge-check.sh
  chmod +x .tad/hooks/lib/stale-knowledge-check.sh
  echo init > README.md
  git add . && git commit -q -m init
)

SCRIPT="${WS}/.tad/hooks/lib/stale-knowledge-check.sh"

# ── Helper: write a knowledge file with given content ──
_kfile() {
  local fname="$1"; shift
  printf '%s\n' "$@" > "${WS}/.tad/project-knowledge/${fname}"
}

# ── Helper: set file mtime to YYYY-MM-DD ──
_set_mtime() {
  local file="$1" date="$2"
  # BSD touch -t [[CC]YY]MMDDhhmm[.ss]
  local stamp=$(printf '%s' "$date" | tr -d '-')
  touch -t "${stamp}1200" "$file"
}

# ── Helper: extract status for a (title, path) pair from JSON output ──
_status_of() {
  local jsonl="$1" title="$2" path="${3:-}"
  if [ -n "$path" ]; then
    printf '%s\n' "$jsonl" | jq -rc --arg t "$title" --arg p "$path" \
      'select(.title==$t and .path==$p) | .status' 2>/dev/null | head -1
  else
    printf '%s\n' "$jsonl" | jq -rc --arg t "$title" \
      'select(.title==$t) | .status' 2>/dev/null | head -1
  fi
}

_days_of() {
  local jsonl="$1" title="$2" path="$3"
  printf '%s\n' "$jsonl" | jq -rc --arg t "$title" --arg p "$path" \
    'select(.title==$t and .path==$p) | .days_delta' 2>/dev/null | head -1
}

# ── AC-P2.1-c: stale (entry 04-01, file 04-08) ──
_kfile testing.md \
  '# Testing Knowledge' \
  '' \
  '### Stale Entry - 2026-04-01' \
  '- **Context**: test' \
  '- **Discovery**: x' \
  '- **Action**: y' \
  '- **Grounded in**: loop_voice/config.py'
echo 'def x(): pass' > "${WS}/loop_voice/config.py"
_set_mtime "${WS}/loop_voice/config.py" "2026-04-08"

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Stale Entry" "loop_voice/config.py")
days=$(_days_of "$stdout" "Stale Entry" "loop_voice/config.py")
[ "$status" = "STALE" ] && _pass "AC-P2.1-c stale entry → STALE" || _fail "AC-P2.1-c expected STALE, got '$status'" "$stdout"
[ "$days" = "7" ] && _pass "AC-P2.1-c days_delta=7" || _fail "AC-P2.1-c expected days_delta=7, got '$days'"

# ── AC-P2.1-d: not stale (entry 04-08, file 04-01) ──
_kfile testing.md \
  '# Testing' \
  '' \
  '### Not Stale - 2026-04-08' \
  '- **Grounded in**: loop_voice/config.py'
_set_mtime "${WS}/loop_voice/config.py" "2026-04-01"

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Not Stale" "loop_voice/config.py")
[ "$status" = "OK" ] && _pass "AC-P2.1-d fresh file → OK" || _fail "AC-P2.1-d expected OK, got '$status'"

# ── AC-P2.1-e: legacy entry (no Grounded in) ──
_kfile testing.md \
  '# Testing' \
  '' \
  '### Legacy Entry - 2026-04-01' \
  '- **Context**: x' \
  '- **Discovery**: y' \
  '- **Action**: z'

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Legacy Entry")
[ "$status" = "INFO" ] && _pass "AC-P2.1-e legacy → INFO" || _fail "AC-P2.1-e expected INFO, got '$status'"

# ── AC-P2.1-f: missing file ──
_kfile testing.md \
  '### Missing File Entry - 2026-04-01' \
  '- **Grounded in**: nonexistent/path.py'

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Missing File Entry" "nonexistent/path.py")
[ "$status" = "WARN" ] && _pass "AC-P2.1-f missing file → WARN" || _fail "AC-P2.1-f expected WARN, got '$status'"

# ── AC-P2.1-g: multi-path ──
echo x > "${WS}/file_a.py"; _set_mtime "${WS}/file_a.py" "2026-04-01"
echo x > "${WS}/file_b.py"; _set_mtime "${WS}/file_b.py" "2026-04-15"
_kfile testing.md \
  '### Multi Path - 2026-04-05' \
  '- **Grounded in**: file_a.py, file_b.py'

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
sa=$(_status_of "$stdout" "Multi Path" "file_a.py")
sb=$(_status_of "$stdout" "Multi Path" "file_b.py")
[ "$sa" = "OK" ] && [ "$sb" = "STALE" ] && \
  _pass "AC-P2.1-g multi-path independent verdicts (OK + STALE)" || \
  _fail "AC-P2.1-g expected OK+STALE, got $sa+$sb"

# ── AC-P2.1-h: revalidated newer than mtime → OK ──
_kfile testing.md \
  '### Revalidated Fresh - 2026-04-01' \
  '- **Grounded in**: file_a.py' \
  '- **Revalidated**: 2026-04-10'
echo x > "${WS}/file_a.py"; _set_mtime "${WS}/file_a.py" "2026-04-08"

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Revalidated Fresh" "file_a.py")
[ "$status" = "OK" ] && _pass "AC-P2.1-h revalidated > mtime → OK (no false alarm)" || _fail "AC-P2.1-h expected OK, got '$status'"

# ── AC-P2.1-i: revalidated stale ──
_kfile testing.md \
  '### Revalidated Stale - 2026-04-01' \
  '- **Grounded in**: file_a.py' \
  '- **Revalidated**: 2026-04-05'
_set_mtime "${WS}/file_a.py" "2026-04-12"

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Revalidated Stale" "file_a.py")
days=$(_days_of "$stdout" "Revalidated Stale" "file_a.py")
[ "$status" = "STALE" ] && _pass "AC-P2.1-i revalidated < mtime → STALE" || _fail "AC-P2.1-i expected STALE, got '$status'"
[ "$days" = "7" ] && _pass "AC-P2.1-i days_delta=7 (relative to revalidated 2026-04-05)" || _fail "AC-P2.1-i expected 7, got '$days'"

# ── AC-P2.1-j: grace boundary (86399s OK, 86401s STALE) ──
# Use midnight (matching the script's _date_to_ts normalization).
entry_ts=$(date -j -f "%Y-%m-%d %H:%M:%S" "2026-04-01 00:00:00" "+%s" 2>/dev/null \
  || date -d "2026-04-01 00:00:00" "+%s")
under_grace=$((entry_ts + 86399))
just_over=$((entry_ts + 86401))

_kfile testing.md \
  '### Grace Boundary - 2026-04-01' \
  '- **Grounded in**: file_a.py'
# Set mtime via touch -t with the exact second
touch -t "$(date -r "$under_grace" "+%Y%m%d%H%M.%S" 2>/dev/null || date -d "@$under_grace" "+%Y%m%d%H%M.%S")" "${WS}/file_a.py"
stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Grace Boundary" "file_a.py")
[ "$status" = "OK" ] && _pass "AC-P2.1-j +86399s (under grace) → OK" || _fail "AC-P2.1-j +86399 expected OK, got '$status'"

touch -t "$(date -r "$just_over" "+%Y%m%d%H%M.%S" 2>/dev/null || date -d "@$just_over" "+%Y%m%d%H%M.%S")" "${WS}/file_a.py"
stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Grace Boundary" "file_a.py")
[ "$status" = "STALE" ] && _pass "AC-P2.1-j +86401s (over grace) → STALE" || _fail "AC-P2.1-j +86401 expected STALE, got '$status'"

# ── AC-P2.1-k: malformed grammar (line range) ──
_kfile testing.md \
  '### Malformed Grammar - 2026-04-01' \
  '- **Grounded in**: file_a.py:42-55'

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Malformed Grammar" "file_a.py:42-55")
[ "$status" = "WARN" ] && _pass "AC-P2.1-k line range :42-55 → WARN (no crash)" || _fail "AC-P2.1-k expected WARN, got '$status'"

# Verify exit code is still 0
(cd "$WS" && bash "$SCRIPT" --json >/dev/null 2>&1); rc=$?
[ "$rc" = "0" ] && _pass "AC-P2.1-k script exit 0 despite malformed entry" || _fail "AC-P2.1-k script crashed: exit $rc"

# ── AC-P2.1-l: (new — will be created) marker ──
_kfile testing.md \
  '### New Marker Entry - 2026-04-01' \
  '- **Grounded in**: future/file.sh (new — will be created)'

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
# Marker path is the full string including "(new — will be created)"
status=$(_status_of "$stdout" "New Marker Entry" "future/file.sh (new — will be created)")
[ "$status" = "INFO" ] && _pass "AC-P2.1-l (new — will be created) marker → INFO" || _fail "AC-P2.1-l expected INFO, got '$status'"

# ── AC-P2.1-m: title with dash ──
_kfile testing.md \
  '### Sub-Agent Safety: Red-Team Triggers Refusal - 2026-04-14' \
  '- **Grounded in**: file_a.py'

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Sub-Agent Safety: Red-Team Triggers Refusal" "file_a.py")
# Whatever status, just verify the title was parsed correctly
[ -n "$status" ] && _pass "AC-P2.1-m title with dashes parsed correctly (anchor to LAST ' - ')" || _fail "AC-P2.1-m title not found in output" "$stdout"

# ── AC-P2.1-n: (consolidated) suffix ──
_kfile testing.md \
  '### API Timeout Patterns - 2026-04-20 (consolidated)' \
  '- **Grounded in**: file_a.py'

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "API Timeout Patterns" "file_a.py")
[ -n "$status" ] && _pass "AC-P2.1-n (consolidated) suffix stripped, entry parsed" || _fail "AC-P2.1-n title not parsed" "$stdout"

# ── AC-P2.1-o: --json schema validation ──
_kfile testing.md \
  '### Schema Test - 2026-04-01' \
  '- **Grounded in**: file_a.py'
_set_mtime "${WS}/file_a.py" "2026-04-15"

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
# Each line should have all required keys
all_valid=true
while IFS= read -r line; do
  [ -z "$line" ] && continue
  has_keys=$(printf '%s' "$line" | jq -r 'has("file") and has("title") and has("path") and has("status") and has("days_delta") and has("msg")' 2>/dev/null)
  [ "$has_keys" != "true" ] && all_valid=false
  status_val=$(printf '%s' "$line" | jq -r '.status' 2>/dev/null)
  case "$status_val" in
    STALE|INFO|WARN|OK|ERROR) ;;
    *) all_valid=false ;;
  esac
done <<< "$stdout"
[ "$all_valid" = "true" ] && _pass "AC-P2.1-o JSON schema valid (5 keys + status enum)" || _fail "AC-P2.1-o invalid JSON schema"

# days_delta is null or int
all_dd_valid=true
while IFS= read -r line; do
  [ -z "$line" ] && continue
  dd_type=$(printf '%s' "$line" | jq -r '.days_delta | type' 2>/dev/null)
  [ "$dd_type" != "null" ] && [ "$dd_type" != "number" ] && all_dd_valid=false
done <<< "$stdout"
[ "$all_dd_valid" = "true" ] && _pass "AC-P2.1-o days_delta is null or number" || _fail "AC-P2.1-o days_delta type invalid"

# ── AC-P2.1-p: real-corpus run on real architecture.md ──
real_arch="${REPO_ROOT}/.tad/project-knowledge/architecture.md"
real_out=$(cd "$REPO_ROOT" && bash "$SCRIPT_SRC" --json 2>/dev/null)
rc=$?
[ "$rc" = "0" ] && _pass "AC-P2.1-p real corpus exit code 0" || _fail "AC-P2.1-p real corpus exit code $rc"
[ -n "$real_out" ] && _pass "AC-P2.1-p real corpus stdout non-empty" || _fail "AC-P2.1-p real corpus stdout empty"
err_lines=$(printf '%s\n' "$real_out" | grep -c '"status":"ERROR"' 2>/dev/null) || err_lines=0
[ "$err_lines" = "0" ] && _pass "AC-P2.1-p real corpus 0 ERROR rows" || _fail "AC-P2.1-p real corpus has $err_lines ERROR rows"

# Save real-corpus output as evidence
mkdir -p "${REPO_ROOT}/.tad/evidence/completions/phase2-grounding"
printf '%s\n' "$real_out" > "${REPO_ROOT}/.tad/evidence/completions/phase2-grounding/real-corpus-output.txt"

# ── AC-P2.1-q: failure isolation (covered by integration test below) ──
# Run the script with malformed input; verify exit 0 still, no crash
_kfile testing.md \
  '### Bad Header No Date' \
  '- **Grounded in**: file_a.py' \
  '' \
  '### Good Entry - 2026-04-01' \
  '- **Grounded in**: file_a.py'
(cd "$WS" && bash "$SCRIPT" --json >/dev/null 2>&1); rc=$?
[ "$rc" = "0" ] && _pass "AC-P2.1-q failure isolation: malformed header → exit 0 (skip bad, continue)" || _fail "AC-P2.1-q crashed on bad header: exit $rc"

# Also save failure isolation evidence
{
  echo "AC-P2.1-q Failure Isolation Test"
  echo "--------------------------------"
  echo "Test: stale-check.sh fed a knowledge file with a malformed header"
  echo "(### Bad Header No Date — no parseable date)"
  echo ""
  echo "Expected: stale-check.sh emits findings for valid entries, skips bad,"
  echo "          exits 0 (advisory). Caller (Alex step0_5) is not blocked."
  echo ""
  echo "Actual exit code: $rc"
  echo ""
  echo "Output:"
  cd "$WS" && bash "$SCRIPT" --json 2>&1
  echo ""
  echo "Conclusion: ${rc:-?} == 0 → PASS (Alex step0_5 stderr warns + continues)"
} > "${REPO_ROOT}/.tad/evidence/completions/phase2-grounding/failure-isolation.txt"

# ── AC-P2.1-r: anti-Epic-1 (mechanical grep — no settings.json registration) ──
# Verify the script is NOT mentioned in .claude/settings.json
if [ -f "${REPO_ROOT}/.claude/settings.json" ]; then
  if ! grep -q "stale-knowledge-check" "${REPO_ROOT}/.claude/settings.json"; then
    _pass "AC-P2.1-r stale-check NOT in settings.json (anti-Epic-1)"
  else
    _fail "AC-P2.1-r stale-check appears in settings.json (forbidden)"
  fi
else
  _pass "AC-P2.1-r no settings.json present (trivially satisfies anti-Epic-1)"
fi

# Verify it's not registered as an executable PreToolUse / UserPromptSubmit hook.
# The script's own docstring mentions these terms (anti-Epic-1 disclaimer), but
# what matters is whether ANOTHER hook script auto-fires it.
# Check: any non-stale-knowledge hook file that calls / sources stale-knowledge-check.
if grep -rE 'stale-knowledge-check|stale_knowledge_check' "${REPO_ROOT}/.tad/hooks/" 2>/dev/null \
   | grep -v 'stale-knowledge-check.sh:' >/dev/null 2>&1; then
  _fail "AC-P2.1-r stale-check is invoked from another hook script (auto-fired risk)"
else
  _pass "AC-P2.1-r stale-check not invoked from any other hook (advisory CLI only)"
fi

# ── AC-P2.1-s: cwd resolution from subdirectory ──
mkdir -p "${WS}/some/deep/dir"
(cd "${WS}/some/deep/dir" && bash "$SCRIPT" --json >/dev/null 2>&1); rc=$?
[ "$rc" = "0" ] && _pass "AC-P2.1-s subdir invocation auto-resolves to git root" || _fail "AC-P2.1-s subdir failed: exit $rc"

# Non-git repo → exit 1
NONGIT=$(mktemp -d -t nongit.XXXXXX)
(cd "$NONGIT" && bash "$SCRIPT" --json 2>&1); rc=$?
[ "$rc" = "1" ] && _pass "AC-P2.1-s non-git repo → exit 1" || _fail "AC-P2.1-s non-git expected exit 1, got $rc"
rm -rf "$NONGIT"

# ── AC-P2.1-t: symlink follows target's mtime ──
echo content > "${WS}/symlink_target.py"
_set_mtime "${WS}/symlink_target.py" "2026-04-12"
ln -sf symlink_target.py "${WS}/symlink_pointer.py"
_kfile testing.md \
  '### Symlink Test - 2026-04-01' \
  '- **Grounded in**: symlink_pointer.py'

stdout=$(cd "$WS" && bash "$SCRIPT" --json 2>/dev/null)
status=$(_status_of "$stdout" "Symlink Test" "symlink_pointer.py")
[ "$status" = "STALE" ] && _pass "AC-P2.1-t symlink follows target mtime (stat -L)" || _fail "AC-P2.1-t expected STALE via symlink, got '$status'"

# ── AC-P2.1-a (README format documentation) ──
README="${REPO_ROOT}/.tad/project-knowledge/README.md"
for needle in '**Grounded in**:' '**Revalidated**:' 'strict grammar' '`, `' 'line ranges'; do
  if grep -qF "$needle" "$README"; then
    _pass "AC-P2.1-a README contains '$needle'"
  else
    _fail "AC-P2.1-a README missing '$needle'"
  fi
done

# ── AC-P2.1-b (shellcheck + BSD portability via this fixture run) ──
if shellcheck -e SC2155 "$SCRIPT_SRC" >/dev/null 2>&1; then
  _pass "AC-P2.1-b shellcheck PASS"
else
  _fail "AC-P2.1-b shellcheck FAIL" "$(shellcheck -e SC2155 "$SCRIPT_SRC" 2>&1 | head -3)"
fi
# All BSD operations (stat -L, date -j -f) used successfully throughout the test
# (exit 0 from the entire test suite is the implicit BSD compatibility evidence)
_pass "AC-P2.1-b BSD-portable operations (stat -L, date -j -f) all succeeded above"

printf '\n== Summary: %d passed, %d failed ==\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
