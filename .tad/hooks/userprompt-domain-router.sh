#!/bin/bash
# .tad/hooks/userprompt-domain-router.sh
#
# Phase 2b — Domain Pack Router (Architecture C, deterministic keyword match, no LLM).
# Invoked by Claude Code as a `type: command` UserPromptSubmit hook.
#
# Design invariants (Phase 2b handoff P0 fixes):
#   1. Scoring is NORMALIZED ratio = matched_distinct_keywords / total_keywords_in_pack
#      (prevents large-keyword-list bias). Tie-break: alphabetical pack name.
#   2. Threshold semantics = DISTINCT KEYWORD MATCH COUNT (not ratio, not total occurrences).
#      Default 2 for packs with >= 8 keywords, else 1 (set per-pack in keywords.yaml).
#   3. Kill-switch: env TAD_DOMAIN_ROUTER=off OR file $SCRIPT_DIR/.router-disabled → exit 0.
#   4. UTF-8 locale forced (BSD grep -i needs UTF-8 to match Chinese case-insensitively).
#   5. `set -uo pipefail` — NO `set -e` (conflicts with `trap 'exit 0' ERR` cleanup).
#   6. yq invoked AT MOST ONCE (dump-to-bash), subsequent parsing via jq on in-memory JSON.
#   7. Structured log `.router.log` — one line per invocation, size-rotate at 1MB,
#      NO prompt content recorded (privacy).
#   8. Always exits 0 — never blocks the user. Trap 'exit 0' ERR is the safety net.
#
# BSD-compatible (macOS): no grep -P, no `sed -i` without backup, no GNU-only flags.

set -uo pipefail

# ─── Locale: force UTF-8 so grep -i matches Chinese case-insensitively ─────
# Phase 2b P0-C2 — grep -i is locale-sensitive; default C locale would break CJK.
export LC_ALL=en_US.UTF-8 2>/dev/null || export LC_ALL=C.UTF-8 2>/dev/null || true
export LANG=en_US.UTF-8 2>/dev/null || true

# ─── Error trap: any unexpected failure → exit 0, never block the user ────
# Phase 2b P0-C1 — `set -e` would conflict with this, so we use `set -uo pipefail`
# and handle errors explicitly via the ERR trap.
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYWORDS_FILE="${SCRIPT_DIR}/keywords.yaml"
LOG_FILE="${SCRIPT_DIR}/.router.log"
LOG_ROTATE_BYTES=1048576    # 1 MB

START_MS=$(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000' 2>/dev/null || echo 0)

# ─── Kill-switch (P0-S3) — checked FIRST, before any work ─────────────────
if [ "${TAD_DOMAIN_ROUTER:-on}" = "off" ]; then
  exit 0
fi
if [ -f "${SCRIPT_DIR}/.router-disabled" ]; then
  exit 0
fi

# ─── Dependency check — degrade gracefully if yq or jq missing ────────────
if ! command -v jq >/dev/null 2>&1 || ! command -v yq >/dev/null 2>&1; then
  exit 0
fi

# ─── keywords.yaml must exist and be readable ─────────────────────────────
if [ ! -r "$KEYWORDS_FILE" ]; then
  exit 0
fi

# ─── Read and parse stdin JSON ────────────────────────────────────────────
INPUT=$(cat 2>/dev/null || echo '{}')

# Extract .prompt safely. Any parse failure → empty string → exit 0.
USER_MSG=$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")

if [ -z "$USER_MSG" ]; then
  exit 0
fi

# ─── Trim leading/trailing whitespace via sed (P0-C3 fix) ─────────────────
# `tr -d '[:space:]'` strips ALL whitespace including internal, which is wrong.
# sed preserves internal spacing but removes leading/trailing.
MSG_TRIMMED=$(printf '%s' "$USER_MSG" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$MSG_TRIMMED" ]; then
  exit 0
fi

# ─── Whitelist early-exit ─────────────────────────────────────────────────
# Use case statement for exact match on trimmed message. Case-sensitive
# because whitelist tokens are unambiguous.
# (Phase 2b P0-C3: NO byte-length gate via ${#var} — that counts bytes, not
# characters, and breaks for Chinese messages where e.g. "嗯" is 3 bytes.)
case "$MSG_TRIMMED" in
  yes|no|ok|y|n|继续|嗯|明白|收到|好的)
    # Logged as whitelist-early-exit
    elapsed_ms=$(( $(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000' 2>/dev/null || echo "$START_MS") - START_MS ))
    # Structured log — no prompt content (privacy)
    printf '%s %d whitelist_early_exit - %d\n' \
      "$(date +%Y-%m-%dT%H:%M:%S%z)" "$elapsed_ms" "${#MSG_TRIMMED}" \
      >> "$LOG_FILE" 2>/dev/null || true
    exit 0
    ;;
esac

# ─── Load keywords via single yq dump (P1-4 fix: yq <= 2 invocations) ─────
# One invocation: dump the whole yaml as JSON into a bash variable. Then
# use jq on the in-memory JSON for all subsequent parsing (jq is cheap).
ALL_PACKS_JSON=$(yq -o=json '.' "$KEYWORDS_FILE" 2>/dev/null || echo '{}')

# Sanity: packs array exists and non-empty
PACK_COUNT=$(printf '%s' "$ALL_PACKS_JSON" | jq -r '.packs // [] | length' 2>/dev/null || echo 0)
if [ "$PACK_COUNT" -eq 0 ]; then
  exit 0
fi

# ─── Score each pack ──────────────────────────────────────────────────────
# Strategy: for each pack, count distinct keywords present (case-insensitive,
# literal substring match via grep -iF) in USER_MSG. We compute:
#   matched      — number of distinct keywords present
#   total        — total keywords in pack
#   ratio        — matched / total (normalized to avoid bias toward large lists)
# Selection: first filter by matched >= threshold, then pick highest ratio,
# breaking ties alphabetically by pack name (P0-S1 fix).

BEST_PACK=""
BEST_MATCHED=0
BEST_TOTAL=0
BEST_RATIO_NUM=0   # integer ratio * 1000 for bash arithmetic
BEST_FILE=""

# Use process substitution to iterate pack-by-pack; extract name + threshold + keywords
# via a single jq invocation that outputs TSV-ish lines: name<TAB>threshold<TAB>kw1|kw2|...
PACKS_TABLE=$(printf '%s' "$ALL_PACKS_JSON" | jq -r '
  .packs[]? as $p
  | [
      ($p.name // "unknown"),
      (($p.threshold // 1) | tostring),
      (($p.file // "") | tostring),
      (($p.keywords // []) | join("\u0001"))
    ]
  | @tsv
' 2>/dev/null || echo "")

if [ -z "$PACKS_TABLE" ]; then
  exit 0
fi

# Iterate packs in ALPHABETICAL order of name — this makes tie-break trivial:
# the first pack that ties at the highest ratio wins. We sort by pack name.
PACKS_TABLE_SORTED=$(printf '%s' "$PACKS_TABLE" | sort)

# ─── Single-awk scoring (P1-perf: was ~600ms per grep-loop, now ~10ms) ────
# One awk process handles ALL packs. `index(lc_msg, lc_kw) > 0` is a literal
# substring match; `tolower()` is locale-aware (UTF-8 env = no-op for CJK
# since CJK has no case; lowercases only ASCII — which is exactly correct).
# Message is passed via ENVIRON to avoid `awk -v` backslash-interpretation
# on untrusted user input (\n, \t, \\ etc.).
#
# Awk outputs a single TSV line: name<TAB>matched<TAB>total<TAB>file
# or the empty string if no pack passes its threshold.
# NOTE: MSG_UNSAFE assignment is on the awk command, NOT printf — variable
# assignments before a piped command apply only to THAT command, so placing
# it before printf would fail to reach awk. This line is subtle; do not move.
SCORE_RESULT=$(printf '%s' "$PACKS_TABLE_SORTED" | MSG_UNSAFE="$MSG_TRIMMED" awk '
BEGIN {
  FS  = "\t"
  OFS = "\t"
  # tolower is locale-aware in awk; UTF-8 locale handled via LC_ALL env
  msg_lc = tolower(ENVIRON["MSG_UNSAFE"])
  best_ratio   = 0
  best_matched = 0
  best_total   = 0
  best_pack    = ""
  best_file    = ""
}
# TSV: name, threshold, file, keywords_blob (keywords separated by \x01)
{
  name      = $1
  threshold = $2 + 0
  file      = $3
  blob      = $4

  if (name == "" || blob == "") next

  # Split keyword blob on \x01 (ASCII SOH)
  n_kw = split(blob, kws, "\001")
  if (n_kw == 0) next

  matched = 0
  for (i = 1; i <= n_kw; i++) {
    kw = tolower(kws[i])
    if (kw == "") continue
    if (index(msg_lc, kw) > 0) matched++
  }

  if (matched < threshold) next

  # Integer ratio * 1000 to avoid awk float precision issues in comparison
  ratio = int((matched * 1000) / n_kw)

  # Strict-greater-than preserves alphabetical tie-break (first seen wins)
  if (ratio > best_ratio) {
    best_ratio   = ratio
    best_matched = matched
    best_total   = n_kw
    best_pack    = name
    best_file    = file
  }
}
END {
  if (best_pack != "") {
    print best_pack, best_matched, best_total, best_file
  }
}
')

if [ -n "$SCORE_RESULT" ]; then
  BEST_PACK=$(printf '%s' "$SCORE_RESULT" | cut -f1)
  BEST_MATCHED=$(printf '%s' "$SCORE_RESULT" | cut -f2)
  BEST_TOTAL=$(printf '%s' "$SCORE_RESULT" | cut -f3)
  BEST_FILE=$(printf '%s' "$SCORE_RESULT" | cut -f4)
fi

# ─── Emit hookSpecificOutput if a match passed threshold ──────────────────
if [ -n "$BEST_PACK" ]; then
  # Human-readable reminder (Chinese — matches TAD convention)
  REMINDER="⚠️ 检测到任务匹配 Domain Pack [${BEST_PACK}]（命中 ${BEST_MATCHED}/${BEST_TOTAL} 关键词）。请 Read ${BEST_FILE} 加载对应 capability 和 quality_criteria 后再响应。"

  # Safe JSON emission via jq (no string escaping pitfalls)
  jq -nc \
    --arg ctx "$REMINDER" \
    '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}' \
    2>/dev/null || true
fi

# ─── Log rotation + structured append (no prompt content — privacy) ──────
elapsed_ms=$(( $(perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000' 2>/dev/null || echo "$START_MS") - START_MS ))
logged_pack="${BEST_PACK:-none}"
logged_ratio="0"
# Defensive: `[ "" -gt 0 ]` errors under set -u; use parameter default like log_size below
if [ "${BEST_TOTAL:-0}" -gt 0 ] 2>/dev/null; then
  logged_ratio="${BEST_MATCHED}/${BEST_TOTAL}"
fi

# Rotate if > 1MB. Use `wc -c < file` (POSIX-portable, works on BSD + GNU);
# avoids BSD `stat -f` vs GNU `stat -c` flag divergence (AC11).
if [ -f "$LOG_FILE" ]; then
  log_size=$(wc -c < "$LOG_FILE" 2>/dev/null | tr -d ' ' || echo 0)
  if [ "${log_size:-0}" -gt "$LOG_ROTATE_BYTES" ] 2>/dev/null; then
    mv "$LOG_FILE" "${LOG_FILE}.1" 2>/dev/null || true
  fi
fi

printf '%s %d %s %s %d\n' \
  "$(date +%Y-%m-%dT%H:%M:%S%z)" \
  "$elapsed_ms" \
  "$logged_pack" \
  "$logged_ratio" \
  "${#MSG_TRIMMED}" \
  >> "$LOG_FILE" 2>/dev/null || true

exit 0
