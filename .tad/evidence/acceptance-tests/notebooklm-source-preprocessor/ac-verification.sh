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

# AC1: add-smart in SKILL.md
check_ge "AC1" "add-smart exists in SKILL.md" "$(grep -c 'add-smart' .claude/skills/research-notebook/SKILL.md)" 1

# AC2: source-preprocessor.sh executable
check "AC2" "source-preprocessor.sh executable" "$(test -x .tad/cross-model/source-preprocessor.sh && echo PASS || echo FAIL)" "PASS"

# AC3: 4 handler scripts
check "AC3" "4 handler scripts exist" "$(ls .tad/cross-model/handlers/*.sh | wc -l | tr -d ' ')" "4"

# AC4: API key path in x-handler.sh
check_ge "AC4" "API key path in x-handler.sh" "$(grep -c 'openclaw/workspace/data/twitterapi.key' .tad/cross-model/handlers/x-handler.sh)" 1

# AC5: yt-dlp in bilibili-handler.sh
check_ge "AC5" "yt-dlp referenced in bilibili-handler.sh" "$(grep -c 'yt-dlp' .tad/cross-model/handlers/bilibili-handler.sh)" 1

# AC6: verify_import_quality in SKILL.md
check_ge "AC6" "verify_import_quality in SKILL.md" "$(grep -c 'verify_import_quality' .claude/skills/research-notebook/SKILL.md)" 1

# AC7: preprocessed path in SKILL.md
check_ge "AC7" "preprocessed path in SKILL.md" "$(grep -c 'preprocessed' .claude/skills/research-notebook/SKILL.md)" 1

# AC8: timeout 30 in source-preprocessor.sh
check_ge "AC8" "timeout 30 / timeout_seconds in source-preprocessor.sh" "$(grep -c 'timeout 30\|timeout_seconds' .tad/cross-model/source-preprocessor.sh)" 1

# AC9: metadata header fields in x-handler.sh
check_ge "AC9" "source:/original_url:/extracted_at: in x-handler.sh" "$(grep -c 'source:\|original_url:\|extracted_at:' .tad/cross-model/handlers/x-handler.sh)" 3

# AC10: shebang in all 5 files
for f in .tad/cross-model/source-preprocessor.sh .tad/cross-model/handlers/*.sh; do
  has_shebang=$(head -1 "$f" | grep -c '#!/usr/bin/env bash' || true)
  check "AC10-$(basename $f)" "shebang in $f" "$has_shebang" "1"
done

# AC11: URL type detection (functional test)
detected=$(echo 'https://x.com/user/status/12345' | bash .tad/cross-model/source-preprocessor.sh detect)
check "AC11" "URL type detection — x.com/status/ → x_tweet" "$detected" "x_tweet"

# AC12: URL validation rejects metacharacters
set +e
echo 'https://evil.com/$(whoami)' | bash .tad/cross-model/source-preprocessor.sh validate 2>/dev/null
ac12_exit=$?
set -e
check "AC12" "validate rejects metacharacters (exit 1)" "$ac12_exit" "1"

# AC13: scholar-handler arxiv → exit 10 + PDF URL on stdout
set +e
scholar_out=$(bash .tad/cross-model/handlers/scholar-handler.sh arxiv 'https://arxiv.org/abs/2401.13178' /tmp/tad-test-out 2>/dev/null)
scholar_exit=$?
set -e
check "AC13-exit" "scholar-handler arxiv exit 10" "$scholar_exit" "10"
pdf_in_stdout=$(echo "$scholar_out" | grep -c 'arxiv.org/pdf' || true)
check_ge "AC13-stdout" "scholar-handler arxiv stdout contains arxiv.org/pdf" "$pdf_in_stdout" 1

# AC14: QUALITY labels in SKILL.md
check_ge "AC14" "QUALITY:HIGH/LOW/NONE in SKILL.md" "$(grep -c 'QUALITY:HIGH\|QUALITY:LOW\|QUALITY:NONE' .claude/skills/research-notebook/SKILL.md)" 1

# AC15: 30s wait in SKILL.md
check_ge "AC15" "sleep 30 or Wait 30s in SKILL.md" "$(grep -cE '(sleep 30|Wait 30)' .claude/skills/research-notebook/SKILL.md)" 1

# AC16: source add with -n flag in add-smart section
in_section=$(awk '/add-smart/,/^---$/' .claude/skills/research-notebook/SKILL.md | grep -c 'source add.*-n' || true)
check_ge "AC16" "source add -n in add-smart section" "$in_section" 1

echo ""
echo "=== Summary: $PASS PASS, $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && echo "✅ ALL ACs PASS" || echo "❌ $FAIL AC(s) FAILED"
exit $FAIL
