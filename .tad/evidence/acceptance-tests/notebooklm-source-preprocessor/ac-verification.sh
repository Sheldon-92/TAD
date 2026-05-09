#!/usr/bin/env bash
# Acceptance Verification — TASK-20260509-001 NotebookLM Source Preprocessor Pipeline
# Run from project root: bash .tad/evidence/acceptance-tests/notebooklm-source-preprocessor/ac-verification.sh

set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

PASS=0
FAIL=0

check() {
  local id="$1" desc="$2" actual="$3" expected="$4"
  if [ "$actual" = "$expected" ]; then
    echo "✅ $id PASS: $desc"
    PASS=$((PASS+1))
  else
    echo "❌ $id FAIL: $desc (got: '$actual', want: '$expected')"
    FAIL=$((FAIL+1))
  fi
}

check_ge() {
  local id="$1" desc="$2" actual="$3" min="$4"
  if [ "${actual:-0}" -ge "$min" ] 2>/dev/null; then
    echo "✅ $id PASS: $desc ($actual ≥ $min)"
    PASS=$((PASS+1))
  else
    echo "❌ $id FAIL: $desc (got: '$actual', want ≥ $min)"
    FAIL=$((FAIL+1))
  fi
}

# ── Original AC1-AC16 ────────────────────────────────────────────────────────

check_ge "AC1" "add-smart exists in SKILL.md" "$(grep -c 'add-smart' .claude/skills/research-notebook/SKILL.md)" 1
check "AC2" "source-preprocessor.sh executable" "$(test -x .tad/cross-model/source-preprocessor.sh && echo PASS || echo FAIL)" "PASS"
check "AC3" "4 handler scripts exist" "$(ls .tad/cross-model/handlers/*.sh | wc -l | tr -d ' ')" "4"
check_ge "AC4" "API key path in x-handler.sh" "$(grep -c 'openclaw/workspace/data/twitterapi.key' .tad/cross-model/handlers/x-handler.sh)" 1
check_ge "AC5" "yt-dlp in bilibili-handler.sh" "$(grep -c 'yt-dlp' .tad/cross-model/handlers/bilibili-handler.sh)" 1
check_ge "AC6" "verify_import_quality in SKILL.md" "$(grep -c 'verify_import_quality' .claude/skills/research-notebook/SKILL.md)" 1
check_ge "AC7" "preprocessed path in SKILL.md" "$(grep -c 'preprocessed' .claude/skills/research-notebook/SKILL.md)" 1
check_ge "AC8" "timeout_seconds in source-preprocessor.sh" "$(grep -c 'timeout 30\|timeout_seconds' .tad/cross-model/source-preprocessor.sh)" 1
check_ge "AC9" "source:/original_url:/extracted_at: in x-handler.sh" "$(grep -c 'source:\|original_url:\|extracted_at:' .tad/cross-model/handlers/x-handler.sh)" 3

for f in .tad/cross-model/source-preprocessor.sh .tad/cross-model/handlers/*.sh; do
  has_shebang=$(head -1 "$f" | grep -c '#!/usr/bin/env bash' || true)
  check "AC10-$(basename "$f")" "shebang in $f" "$has_shebang" "1"
done

detected=$(echo 'https://x.com/user/status/12345' | bash .tad/cross-model/source-preprocessor.sh detect)
check "AC11" "detect x.com/status/ → x_tweet" "$detected" "x_tweet"

set +e
echo 'https://evil.com/$(whoami)' | bash .tad/cross-model/source-preprocessor.sh validate 2>/dev/null
ac12_exit=$?
set -e
check "AC12" "validate rejects metacharacters (exit 1)" "$ac12_exit" "1"

set +e
scholar_out=$(bash .tad/cross-model/handlers/scholar-handler.sh arxiv 'https://arxiv.org/abs/2401.13178' /tmp/tad-test-out 2>/dev/null)
scholar_exit=$?
set -e
check "AC13-exit" "scholar-handler arxiv exit 10" "$scholar_exit" "10"
pdf_in_stdout=$(echo "$scholar_out" | grep -c 'arxiv.org/pdf' || true)
check_ge "AC13-stdout" "scholar-handler arxiv stdout contains arxiv.org/pdf" "$pdf_in_stdout" 1

check_ge "AC14" "QUALITY:HIGH/LOW/NONE in SKILL.md" "$(grep -c 'QUALITY:HIGH\|QUALITY:LOW\|QUALITY:NONE' .claude/skills/research-notebook/SKILL.md)" 1
check_ge "AC15" "sleep 30 or Wait 30s in SKILL.md" "$(grep -cE '(sleep 30|Wait 30)' .claude/skills/research-notebook/SKILL.md)" 1
in_section=$(awk '/add-smart/,/^---$/' .claude/skills/research-notebook/SKILL.md | grep -c 'source add.*-n' || true)
check_ge "AC16" "source add -n in add-smart section" "$in_section" 1

# ── Extended tests (test-runner P0/P1 coverage) ────────────────────────────

# P0-3 fix: all 10 detect types
check "AC17a" "detect x_article"   "$(echo 'https://x.com/user/articles/12345' | bash .tad/cross-model/source-preprocessor.sh detect)" "x_article"
check "AC17b" "detect bilibili BV" "$(echo 'https://www.bilibili.com/video/BV1abc123' | bash .tad/cross-model/source-preprocessor.sh detect)" "bilibili"
check "AC17c" "detect b23.tv"      "$(echo 'https://b23.tv/abc123' | bash .tad/cross-model/source-preprocessor.sh detect)" "bilibili"
check "AC17d" "detect arxiv_pdf"   "$(echo 'https://arxiv.org/pdf/2401.12345' | bash .tad/cross-model/source-preprocessor.sh detect)" "arxiv_pdf"
check "AC17e" "detect arxiv_abs"   "$(echo 'https://arxiv.org/abs/2401.12345' | bash .tad/cross-model/source-preprocessor.sh detect)" "arxiv_abs"
check "AC17f" "detect scholar S2"  "$(echo 'https://www.semanticscholar.org/paper/abc123' | bash .tad/cross-model/source-preprocessor.sh detect)" "scholar"
check "AC17g" "detect google scholar" "$(echo 'https://scholar.google.com/scholar?q=foo' | bash .tad/cross-model/source-preprocessor.sh detect)" "scholar"
check "AC17h" "detect substack"    "$(echo 'https://foo.substack.com/p/article' | bash .tad/cross-model/source-preprocessor.sh detect)" "substack"
check "AC17i" "detect medium"      "$(echo 'https://medium.com/@author/article' | bash .tad/cross-model/source-preprocessor.sh detect)" "medium"
check "AC17j" "detect generic_web" "$(echo 'https://example.com/blog/post' | bash .tad/cross-model/source-preprocessor.sh detect)" "generic_web"

# P1-1: URL normalization
check "AC18a" "normalize twitter.com → x_tweet"  "$(echo 'https://twitter.com/user/status/12345' | bash .tad/cross-model/source-preprocessor.sh detect)" "x_tweet"
check "AC18b" "normalize mobile.twitter.com → x_tweet" "$(echo 'https://mobile.twitter.com/user/status/12345' | bash .tad/cross-model/source-preprocessor.sh detect)" "x_tweet"
check "AC18c" "normalize m.bilibili.com → bilibili" "$(echo 'https://m.bilibili.com/video/BV1abc123' | bash .tad/cross-model/source-preprocessor.sh detect)" "bilibili"
# UTM strip preserves real params
norm_result=$(echo 'https://x.com/user/status/12345?utm_source=foo&id=42' | bash .tad/cross-model/source-preprocessor.sh detect)
check "AC18d" "UTM strip preserves type detection" "$norm_result" "x_tweet"

# P0-2: dispatch subcommand (no API calls — tests routing + exit codes)
set +e
dispatch_out=$(bash .tad/cross-model/source-preprocessor.sh dispatch 'https://arxiv.org/pdf/2401.12345' test_nb /tmp/tad-dispatch-test 2>/dev/null)
dispatch_exit=$?
set -e
check "AC19a-exit" "dispatch arxiv_pdf → exit 10" "$dispatch_exit" "10"
pdf_present=$(echo "$dispatch_out" | grep -c 'arxiv.org/pdf' || true)
check_ge "AC19a-stdout" "dispatch arxiv_pdf stdout contains PDF URL" "$pdf_present" 1

set +e
dispatch_generic_out=$(bash .tad/cross-model/source-preprocessor.sh dispatch 'https://example.com/blog/post' test_nb /tmp/tad-dispatch-test 2>/dev/null)
dispatch_generic_exit=$?
set -e
check "AC19b-exit" "dispatch generic_web → exit 10 (direct URL)" "$dispatch_generic_exit" "10"
url_present=$(echo "$dispatch_generic_out" | grep -c 'example.com' || true)
check_ge "AC19b-stdout" "dispatch generic_web stdout contains normalized URL" "$url_present" 1

# dispatch invalid URL → exit 1
set +e
bash .tad/cross-model/source-preprocessor.sh dispatch 'https://evil.com/$(rm -rf)' test_nb /tmp 2>/dev/null
dispatch_invalid_exit=$?
set -e
check "AC19c" "dispatch invalid URL → exit 1" "$dispatch_invalid_exit" "1"

# P0-1 fix: curl -- arg order (x-handler.sh dep-missing path uses exit 2, not exit 3)
# Test: remove API key temporarily → should exit 2 (dep-missing), not 3 (curl crash)
set +e
NO_KEY_FILE="$(mktemp)"
rm -f "$NO_KEY_FILE"  # ensure it doesn't exist
KEY_FILE_ORIG="$HOME/.openclaw/workspace/data/twitterapi.key"
# Override KEY_FILE by temporarily renaming (if exists)
if [ -f "$KEY_FILE_ORIG" ]; then
  mv "$KEY_FILE_ORIG" "${KEY_FILE_ORIG}.bak_actest"
fi
bash .tad/cross-model/handlers/x-handler.sh tweet 'https://x.com/user/status/12345' /tmp/tad-test-x 2>/dev/null
x_missing_key_exit=$?
if [ -f "${KEY_FILE_ORIG}.bak_actest" ]; then
  mv "${KEY_FILE_ORIG}.bak_actest" "$KEY_FILE_ORIG"
fi
set -e
check "AC20" "x-handler missing key → exit 2 (not 3)" "$x_missing_key_exit" "2"

echo ""
echo "=== Summary: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && echo "✅ ALL ACs PASS" || echo "❌ $FAIL AC(s) FAILED"
exit $FAIL
