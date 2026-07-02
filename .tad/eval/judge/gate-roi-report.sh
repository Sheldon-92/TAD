#!/usr/bin/env bash
set -euo pipefail

# Gate ROI Report — 30-day window summary
# Read-only: writes only the report file, zero side effects.
# BSD-safe: uses find (not globstar), date -v (macOS).

DAYS=30
while [ $# -gt 0 ]; do
  case "$1" in
    --days) DAYS="$2"; shift 2 ;;
    --days=*) DAYS="${1#*=}"; shift ;;
    *) echo "Usage: gate-roi-report.sh [--days N]" >&2; exit 1 ;;
  esac
done

if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
  echo "ERROR: --days must be a positive integer" >&2; exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TODAY=$(date +%Y-%m-%d)
CUTOFF=$(date -v-${DAYS}d +%Y-%m-%d 2>/dev/null || date -d "-${DAYS} days" +%Y-%m-%d 2>/dev/null)
REPORT_DIR="$ROOT/evidence/eval"
REPORT="$REPORT_DIR/gate-roi-${TODAY}.md"

mkdir -p "$REPORT_DIR"

# Helper: extract YYYY-MM-DD from HANDOFF-YYYYMMDD-slug.md filename
hf_date() {
  basename "$1" | grep -oE '^HANDOFF-[0-9]{8}' | sed 's/HANDOFF-//' | sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/'
}

# Helper: check if date is in window [CUTOFF, TODAY]
in_window() {
  local d="$1"
  [[ -n "$d" ]] && [[ "$d" > "$CUTOFF" || "$d" == "$CUTOFF" ]] && [[ "$d" < "$TODAY" || "$d" == "$TODAY" ]]
}

{
echo "# Gate ROI Report"
echo ""
echo "Generated: ${TODAY} | Window: ${CUTOFF} to ${TODAY} (${DAYS} days)"
echo ""

# ═══════════════════════════════════════════════════════════
# Section 1: Gates Run
# ═══════════════════════════════════════════════════════════
echo "## 1. Gates Run"
echo ""

TRACE_DIR="$ROOT/evidence/traces"
GATE_EVENTS_FILE=$(mktemp)
trap "rm -f '$GATE_EVENTS_FILE'" EXIT

if [ -d "$TRACE_DIR" ]; then
  find "$TRACE_DIR" -name '*.jsonl' -not -name 'test-fixtures.jsonl' -print0 2>/dev/null | \
    xargs -0 grep -H '"type":"gate_result"' 2>/dev/null | while IFS= read -r line; do
      # Strip filename prefix from grep output (file.jsonl:{"ts":...})
      JSON="${line#*:}"
      TS=$(echo "$JSON" | jq -r '.ts // empty' 2>/dev/null)
      TS_DATE="${TS:0:10}"
      if in_window "$TS_DATE"; then
        echo "$JSON"
      fi
    done > "$GATE_EVENTS_FILE" || true
fi

GATE_EVENT_COUNT=$(wc -l < "$GATE_EVENTS_FILE" | tr -d ' ')

if [ "$GATE_EVENT_COUNT" -eq 0 ]; then
  echo "N/A — no gate_result events in window."
else
  echo "Total gate_result events: ${GATE_EVENT_COUNT}"
  echo ""
  echo "| Gate | pass | partial | fail |"
  echo "|------|------|---------|------|"
  jq -r '[(.context | capture("Gate (?<g>[0-9]+)") // {g:"unknown"}).g, .outcome] | @tsv' < "$GATE_EVENTS_FILE" 2>/dev/null | \
    awk -F'\t' '{
      gate[$1]++
      combo[$1 "\t" $2]++
    }
    END {
      for (g in gate) {
        printf "| Gate %s | %d | %d | %d |\n", g, combo[g "\tpass"]+0, combo[g "\tpartial"]+0, combo[g "\tfail"]+0
      }
    }' | sort
fi

echo ""
echo '```'
echo "复算命令: grep '\"type\":\"gate_result\"' .tad/evidence/traces/*.jsonl | jq -r '[(.context|capture(\"Gate (?<g>[0-9]+)\") // {g:\"?\"}).g, .outcome] | @tsv' | sort | uniq -c"
echo '```'
echo ""

# ═══════════════════════════════════════════════════════════
# Section 2: Caught Pre-Ship
# ═══════════════════════════════════════════════════════════
echo "## 2. Caught Pre-Ship"
echo ""

# 2a: Review findings (P0/P1 count)
REVIEW_DIR="$ROOT/evidence/reviews/blake"
FINDING_COUNT=0
FINDING_NONUM_FILES=0
if [ -d "$REVIEW_DIR" ]; then
  while IFS= read -r slug_dir; do
    SLUG_NAME=$(basename "$slug_dir")
    # Find handoff with this slug to determine date (active-first, archive fallback)
    HF_FILE=$(ls "$ROOT/active/handoffs/HANDOFF-"*"-${SLUG_NAME}.md" 2>/dev/null | head -1 || true)
    if [ -z "$HF_FILE" ]; then
      HF_FILE=$(ls "$ROOT/archive/handoffs/HANDOFF-"*"-${SLUG_NAME}.md" 2>/dev/null | head -1 || true)
    fi
    if [ -z "$HF_FILE" ]; then continue; fi
    HF_DATE=$(hf_date "$HF_FILE")
    if ! in_window "$HF_DATE"; then continue; fi

    while IFS= read -r rf; do
      [ -f "$rf" ] || continue
      FINDINGS=$({ grep -oE 'P[01]-[0-9]+' "$rf" 2>/dev/null || true; } | sort -u | wc -l | tr -d ' ')
      if [ "$FINDINGS" -gt 0 ]; then
        FINDING_COUNT=$((FINDING_COUNT + FINDINGS))
      else
        HAS_P0=$(grep -ciE '\bP0\b' "$rf" 2>/dev/null) || true
        HAS_P1=$(grep -ciE '\bP1\b' "$rf" 2>/dev/null) || true
        if [ "$HAS_P0" -gt 0 ] || [ "$HAS_P1" -gt 0 ]; then
          FINDING_NONUM_FILES=$((FINDING_NONUM_FILES + 1))
        fi
      fi
    done < <(find "$slug_dir" -maxdepth 1 -name '*.md' -type f 2>/dev/null)
  done < <(find "$REVIEW_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
fi

echo "### 2a. Review Findings (P0/P1)"
echo ""
echo "Numbered findings (P0-N/P1-N, deduplicated): **${FINDING_COUNT}**"
if [ "$FINDING_NONUM_FILES" -gt 0 ]; then
  echo "Files with unnumbered P0/P1 mentions: **${FINDING_NONUM_FILES}** (per-file-per-level count — structural lower bound)"
fi
echo ""

# 2b: Gate 4 late interceptions (non-empty gate4_delta)
echo "### 2b. Gate 4 Late Interceptions"
echo ""
G4_DELTA_COUNT=0
ARCHIVE_DIR="$ROOT/archive/handoffs"
if [ -d "$ARCHIVE_DIR" ]; then
  while IFS= read -r hf; do
    HF_DATE=$(hf_date "$hf")
    if ! in_window "$HF_DATE"; then continue; fi
    HAS_DELTA=$(awk '/^gate4_delta:/{g=1;next} g && /^  -/{found=1} g && /^[^ ]/{exit} END{if(found)print "yes"}' "$hf")
    if [ "$HAS_DELTA" = "yes" ]; then
      G4_DELTA_COUNT=$((G4_DELTA_COUNT + 1))
    fi
  done < <(find "$ARCHIVE_DIR" -name 'HANDOFF-*.md' -not -name 'COMPLETION-*' 2>/dev/null)
fi
echo "Handoffs with non-empty gate4_delta: **${G4_DELTA_COUNT}**"
echo ""
echo "> Note: gate4_delta entries are Gate 4 **interceptions** (gaps Alex caught at acceptance), not escapes. Structural lower bound — unnumbered review findings are counted per-file, compressing the true finding count."
echo ""

echo '```'
echo "复算命令: for f in .tad/archive/handoffs/HANDOFF-*.md; do awk '/^gate4_delta:/{g=1;next} g && /^  -/{found=1} g && /^[^ ]/{exit} END{if(found)print FILENAME}' \"\$f\"; done | wc -l"
echo '```'
echo ""

# ═══════════════════════════════════════════════════════════
# Section 3: Escaped Post-Ship
# ═══════════════════════════════════════════════════════════
echo "## 3. Escaped Post-Ship"
echo ""

ESCAPE_COUNT=0
ACCEPTED_COUNT=0
if [ -d "$ARCHIVE_DIR" ]; then
  while IFS= read -r hf; do
    HF_DATE=$(hf_date "$hf")
    if ! in_window "$HF_DATE"; then continue; fi
    ACCEPTED_COUNT=$((ACCEPTED_COUNT + 1))
    BN=$(basename "$hf")
    if echo "$BN" | grep -qE '^HANDOFF-[0-9]{8}-(bugfix|fix)-'; then
      ESCAPE_COUNT=$((ESCAPE_COUNT + 1))
    fi
  done < <(find "$ARCHIVE_DIR" -name 'HANDOFF-*.md' -not -name 'COMPLETION-*' 2>/dev/null)
fi

if [ "$ACCEPTED_COUNT" -gt 0 ]; then
  RATE_PCT=$(awk "BEGIN {printf \"%.1f\", ($ESCAPE_COUNT / $ACCEPTED_COUNT) * 100}")
  echo "escape rate = ${ESCAPE_COUNT} / ${ACCEPTED_COUNT} = ${RATE_PCT}%"
else
  echo "escape rate = 0 / 0 = N/A (no accepted handoffs in window)"
fi
echo ""
echo "> **Lower bound**: escape count only captures handoffs explicitly prefixed \`bugfix-\`/\`fix-\`. Silent fixes (folded into feature handoffs or direct commits) are invisible to this metric. The true escape rate is at least this high, likely higher."
echo ""

echo '```'
echo "复算命令: ls .tad/archive/handoffs/HANDOFF-*.md | grep -cE '(bugfix|fix)-'"
echo '```'
echo ""

# ═══════════════════════════════════════════════════════════
# Section 4: Judge Score Trend
# ═══════════════════════════════════════════════════════════
echo "## 4. Judge Score Trend"
echo ""

JUDGE_DIR="$ROOT/evidence/acceptance-tests"
JUDGE_DATA=""
JUDGE_COUNT=0
if [ -d "$JUDGE_DIR" ]; then
  while IFS= read -r jf; do
    [ -f "$jf" ] || continue
    SLUG_FROM_PATH=$(echo "$jf" | sed "s|${JUDGE_DIR}/||" | cut -d'/' -f1)
    SCORES=$(jq -r '[.D1.score,.D2.score,.D3.score,.D4.score,.D5.score] | @csv' "$jf" 2>/dev/null || true)
    if [ -n "$SCORES" ]; then
      JUDGE_DATA="${JUDGE_DATA}${SLUG_FROM_PATH},${SCORES}"$'\n'
      JUDGE_COUNT=$((JUDGE_COUNT + 1))
    fi
  done < <(find "$JUDGE_DIR" -name 'trajectory-judge.json' 2>/dev/null)
fi

if [ "$JUDGE_COUNT" -lt 3 ]; then
  echo "insufficient data (n=${JUDGE_COUNT}) — accumulating"
elif [ "$JUDGE_COUNT" -lt 10 ]; then
  echo "| Slug | D1 | D2 | D3 | D4 | D5 |"
  echo "|------|----|----|----|----|-----|"
  echo -n "$JUDGE_DATA" | while IFS=',' read -r slug d1 d2 d3 d4 d5; do
    [ -z "$slug" ] && continue
    echo "| ${slug} | ${d1} | ${d2} | ${d3} | ${d4} | ${d5} |"
  done
else
  echo "| Dimension | Mean | Min | Max |"
  echo "|-----------|------|-----|-----|"
  echo -n "$JUDGE_DATA" | awk -F',' '
    NF>=6 {
      for (i=2; i<=6; i++) {
        d=i-1
        if ($i ~ /^[0-9]+$/) {
          v=$i+0
          sum[d]+=v; n[d]++
          if (!(d in mn) || v<mn[d]) mn[d]=v
          if (!(d in mx) || v>mx[d]) mx[d]=v
        }
      }
    }
    END {
      for (d=1; d<=5; d++) {
        if (n[d]>0) printf "| D%d | %.1f | %s | %s |\n", d, sum[d]/n[d], mn[d], mx[d]
      }
    }'
fi

echo ""
echo '```'
echo "复算命令: find .tad/evidence/acceptance-tests -name trajectory-judge.json -exec jq -r '[.D1.score,.D2.score,.D3.score,.D4.score,.D5.score] | @csv' {} \\;"
echo '```'
echo ""

# ═══════════════════════════════════════════════════════════
# Section 5: Per-Gate Attribution
# ═══════════════════════════════════════════════════════════
echo "## 5. Per-Gate Attribution"
echo ""

if [ "$GATE_EVENT_COUNT" -eq 0 ]; then
  echo "N/A — no gate_result events in window."
else
  echo "| Gate | pass | partial | fail | total |"
  echo "|------|------|---------|------|-------|"
  jq -r '[(.context | capture("Gate (?<g>[0-9]+)") // {g:"unknown"}).g, .outcome] | @tsv' < "$GATE_EVENTS_FILE" 2>/dev/null | \
    awk -F'\t' '{
      gate[$1]++
      combo[$1 "\t" $2]++
    }
    END {
      for (g in gate) {
        printf "| Gate %s | %d | %d | %d | %d |\n", g, combo[g "\tpass"]+0, combo[g "\tpartial"]+0, combo[g "\tfail"]+0, gate[g]
      }
    }' | sort
fi

echo ""
echo '```'
echo "复算命令: grep '\"type\":\"gate_result\"' .tad/evidence/traces/*.jsonl | jq -r '[(.context|capture(\"Gate (?<g>[0-9]+)\") // {g:\"?\"}).g, .outcome] | @tsv' | awk -F'\\t' '{print \$1, \$2}' | sort | uniq -c"
echo '```'
echo ""

} > "$REPORT"

echo "ROI report written: $REPORT"
cat "$REPORT"
