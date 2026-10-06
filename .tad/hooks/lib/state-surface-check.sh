#!/usr/bin/env bash
# state-surface-check.sh — detect-only state-surface consistency check.
#
# TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT, design §2.2 mechanism 2.
# READ-ONLY: this script never writes, edits, or heals anything
# (gate-design: decouple detect-from-heal at release gates).
# Fixing a red line is a separate human/Alex action.
#
# Usage: state-surface-check.sh [--repo <path>]
#   --repo defaults to the repo root derived from this script's location
#   (.tad/hooks/lib/ -> ../../..). Exit 0 = all checks PASS, 1 = any FAIL.
#
# Checks (design §2.2 mechanism 2, scan surface is an explicit file list —
# the list itself is the exclusion contract; CHANGELOG and .tad/archive/
# are never scanned):
#   1. NEXT.md header version line == .tad/version.txt
#   2. ROADMAP.md header "for vX.Y.Z" == .tad/version.txt
#   3. Every current-version declaration in AGENTS.md / README.md /
#      INSTALLATION_GUIDE.md / docs/MULTI-PLATFORM.md / PROJECT_CONTEXT.md
#      == .tad/version.txt. Two pattern families: (a) declaration forms
#      (pattern family Version\*{0,2}:?\*{0,2} ?v?X.Y[.Z], covering the
#      bold-colon form "**Version**: X.Y"); (b) parenthesized forms —
#      "(Version X.Y)" self-anchored anywhere, and bare "(vX.Y)" tokens
#      line-qualified (header lines <= 15, or lines containing
#      "Runtime status") so historical body references stay clean
#      (design delta 2026-10-04, Gate 3 C1).
#   4. "3.1" edition-number forms (AC6 widened pattern) count == 0
#      in the same file list
#   5. session-state.md header multi-chain INDEX BLOCK (the leading
#      blockquote, before the first body heading) — every .tad/*.md path
#      it references exists on disk. Body text is never scanned: it is
#      per-chain historical state by design.
#   6. AGENTS.md Knowledge Ingress unconditional read routes exist. Routes
#      are extracted from AGENTS.md itself (never copied into this script);
#      conditional "If" lines, "Before editing" instruction lines, glob
#      tokens, and directory tokens are excluded.
#   7. .tad/brain-index.md Generated-date freshness. The age is always
#      reported as INFO; older than BRAIN_INDEX_WARN_AGE_DAYS is WARN only,
#      while a missing or unparseable Generated date is FAIL.
#
# bash + grep + sed only; no yaml, no network, no node.

BRAIN_INDEX_WARN_AGE_DAYS=14

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../../.." && pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    *) echo "usage: state-surface-check.sh [--repo <path>]" >&2; exit 2 ;;
  esac
done

VERSION_FILE="$REPO/.tad/version.txt"
if [ ! -f "$VERSION_FILE" ]; then
  echo "FAIL check0: $VERSION_FILE not found"
  exit 1
fi
SSOT="$(head -n 1 "$VERSION_FILE" | tr -d '[:space:]')"

fails=0
pass() { echo "PASS $1: $2"; }
fail() { echo "FAIL $1: $2"; fails=$((fails + 1)); }

# normalize X.Y or X.Y.Z -> X.Y.Z
norm() {
  case "$1" in
    *.*.*) printf '%s' "$1" ;;
    *.*)   printf '%s.0' "$1" ;;
    *)     printf '%s' "$1" ;;
  esac
}

# Convert a validated Gregorian YYYY-MM-DD date to days since 1970-01-01.
# Pure integer arithmetic avoids GNU/BSD `date` conversion differences.
# (Numeric fields only; no string comparison is delegated to awk.)
date_to_days() {
  local y=$((10#$1)) m=$((10#$2)) d=$((10#$3))
  if [ "$m" -le 2 ]; then
    y=$((y - 1))
  fi
  local era=$(( (y >= 0 ? y : y - 399) / 400 ))
  local yoe=$((y - era * 400))
  local mp=$((m > 2 ? m - 3 : m + 9))
  local doy=$(((153 * mp + 2) / 5 + d - 1))
  local doe=$((yoe * 365 + yoe / 4 - yoe / 100 + doy))
  printf '%s' $((era * 146097 + doe - 719468))
}

# ---- Check 1: NEXT.md header version line --------------------------------
NEXT="$REPO/NEXT.md"
if [ ! -f "$NEXT" ]; then
  fail check1 "NEXT.md missing"
else
  line="$(head -n 15 "$NEXT" | grep '当前版本' | head -n 1 || true)"
  ver="$(printf '%s' "$line" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 || true)"
  if [ -n "$ver" ] && [ "$(norm "$ver")" = "$(norm "$SSOT")" ]; then
    pass check1 "NEXT.md header version $ver == version.txt $SSOT"
  else
    fail check1 "NEXT.md header version '${ver:-<none>}' != version.txt $SSOT"
  fi
fi

# ---- Check 2: ROADMAP.md header "for vX.Y.Z" ------------------------------
ROADMAP="$REPO/ROADMAP.md"
if [ ! -f "$ROADMAP" ]; then
  fail check2 "ROADMAP.md missing"
else
  ver="$(head -n 6 "$ROADMAP" | grep -oE 'for v[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 | sed 's/^for v//' || true)"
  if [ -n "$ver" ] && [ "$(norm "$ver")" = "$(norm "$SSOT")" ]; then
    pass check2 "ROADMAP.md header version $ver == version.txt $SSOT"
  else
    fail check2 "ROADMAP.md header version '${ver:-<none>}' != version.txt $SSOT"
  fi
fi

# ---- Checks 3 & 4: version declarations in the state-file list ------------
DECL_FILES="AGENTS.md README.md INSTALLATION_GUIDE.md docs/MULTI-PLATFORM.md PROJECT_CONTEXT.md"
DECL_PAT='Version\*{0,2}:?\*{0,2} ?v?[0-9]+\.[0-9]+(\.[0-9]+)?'
OLD_PAT='(Version|v)\*{0,2}:?\*{0,2} ?3\.1([^0-9]|$)'
# P1 — self-anchored parenthesized declaration: "(Version 9.9)" / "(Version: v9.9)"
PAREN_VER_PAT='\(Version:? ?v?[0-9]+\.[0-9]+(\.[0-9]+)?\)'
# P2 — bare parenthesized token: "(v9.9)" / "(9.9)" (line-qualified, see delta §2)
PAREN_TOKEN_PAT='\(v?[0-9]+\.[0-9]+(\.[0-9]+)?\)'
PAREN_KEYWORD='Runtime status'
PAREN_HEAD_LINES=15

c3_bad=0
for f in $DECL_FILES; do
  p="$REPO/$f"
  if [ ! -f "$p" ]; then
    fail check3 "$f missing"
    c3_bad=1
    continue
  fi
  while IFS= read -r m; do
    [ -n "$m" ] || continue
    ver="$(printf '%s' "$m" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?$' || true)"
    if [ -z "$ver" ] || [ "$(norm "$ver")" != "$(norm "$SSOT")" ]; then
      fail check3 "$f: version declaration '$m' != version.txt $SSOT"
      c3_bad=1
    fi
  done <<EOF
$(grep -oE "$DECL_PAT" "$p" || true)
EOF
done

# P1 pass (delta §1.3): self-anchored "(Version X.Y)" declarations,
# whole file — the "(Version" lead-in is its own anchor.
for f in $DECL_FILES; do
  p="$REPO/$f"
  [ -f "$p" ] || continue
  while IFS= read -r tok; do
    [ -n "$tok" ] || continue
    ver="$(printf '%s' "$tok" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 || true)"
    if [ -z "$ver" ] || [ "$(norm "$ver")" != "$(norm "$SSOT")" ]; then
      fail check3 "$f: parenthesized version declaration '$tok' != version.txt $SSOT"
      c3_bad=1
    fi
  done <<EOF
$(grep -oE "$PAREN_VER_PAT" "$p" || true)
EOF
done

# P2 pass (delta §1.3/§2): bare parenthesized tokens "(vX.Y)", reported
# only on anchored lines (header anchor: line <= PAREN_HEAD_LINES;
# keyword anchor: line contains PAREN_KEYWORD). P2 tokens are space-free
# by construction, so the inner word-split is exact; a token on an
# anchored line is extracted and compared once.
for f in $DECL_FILES; do
  p="$REPO/$f"
  [ -f "$p" ] || continue
  while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    lineno="${entry%%:*}"
    text="${entry#*:}"
    anchored=0
    case "$lineno" in
      ''|*[!0-9]*) ;;
      *) if [ "$lineno" -le "$PAREN_HEAD_LINES" ]; then anchored=1; fi ;;
    esac
    case "$text" in
      *"$PAREN_KEYWORD"*) anchored=1 ;;
    esac
    [ "$anchored" -eq 1 ] || continue
    for tok in $(printf '%s' "$text" | grep -oE "$PAREN_TOKEN_PAT" || true); do
      ver="$(printf '%s' "$tok" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 || true)"
      if [ -z "$ver" ] || [ "$(norm "$ver")" != "$(norm "$SSOT")" ]; then
        fail check3 "$f: parenthesized version declaration '$tok' != version.txt $SSOT"
        c3_bad=1
      fi
    done
  done <<EOF
$(grep -nE "$PAREN_TOKEN_PAT" "$p" || true)
EOF
done
if [ "$c3_bad" -eq 0 ]; then
  pass check3 "all version declarations in state-file list == $SSOT"
fi

c4_count=0
for f in $DECL_FILES; do
  p="$REPO/$f"
  [ -f "$p" ] || continue
  n="$(grep -cE "$OLD_PAT" "$p" || true)"
  c4_count=$((c4_count + n))
done
if [ "$c4_count" -eq 0 ]; then
  pass check4 "no '3.1' edition-number forms in state-file list"
else
  fail check4 "'3.1' edition-number forms remain: $c4_count line(s) in state-file list"
fi

# ---- Check 5: session-state index block path existence --------------------
SS="$REPO/.tad/active/session-state.md"
if [ ! -f "$SS" ]; then
  fail check5 "session-state.md missing"
else
  # Index block = leading blockquote lines (starting with '>'),
  # stopping at the first body heading. Body text is out of scope.
  c5_bad=0
  while IFS= read -r tok; do
    [ -n "$tok" ] || continue
    if [ ! -e "$REPO/$tok" ]; then
      fail check5 "session-state index references missing path: $tok"
      c5_bad=1
    fi
  done <<EOF
$(awk '/^##/{exit} /^>/{print}' "$SS" | grep -oE '`\.tad/[^`]+`' | tr -d '`' | grep -E '\.md$' | sort -u || true)
EOF
  if [ "$c5_bad" -eq 0 ]; then
    pass check5 "session-state index block paths all exist"
  fi
fi

# ---- Check 6: Knowledge Ingress unconditional read routes exist ------------
AGENTS_FILE="$REPO/AGENTS.md"
if [ ! -f "$AGENTS_FILE" ]; then
  fail check6 "AGENTS.md missing"
else
  c6_bad=0
  c6_count=0
  while IFS= read -r tok; do
    [ -n "$tok" ] || continue
    c6_count=$((c6_count + 1))
    case "$tok" in
      *'*'*|*/)
        fail check6 "Knowledge Ingress route is not a concrete file path: $tok"
        c6_bad=1
        continue
        ;;
    esac
    if [ ! -f "$REPO/$tok" ]; then
      fail check6 "Knowledge Ingress route missing on disk: $tok"
      c6_bad=1
    fi
  done <<EOF
$(awk '/^## Knowledge Ingress/{found=1; next} found && /^## /{exit} found{print}' "$AGENTS_FILE" \
  | while IFS= read -r ingress_line; do
      case "$ingress_line" in
        *' If '*|*'Before editing'*) continue ;;
      esac
      printf '%s\n' "$ingress_line" | grep -oE '`\.tad/[^`]+`' | tr -d '`' || true
    done | LC_ALL=C sort -u)
EOF
  if [ "$c6_count" -eq 0 ]; then
    fail check6 "no unconditional Knowledge Ingress routes extracted from AGENTS.md"
  elif [ "$c6_bad" -eq 0 ]; then
    pass check6 "Knowledge Ingress unconditional routes all exist ($c6_count paths)"
  fi
fi

# ---- Check 7: brain-index Generated-date freshness -------------------------
BRAIN_INDEX="$REPO/.tad/brain-index.md"
if [ ! -f "$BRAIN_INDEX" ]; then
  fail check7 "brain-index.md missing; Generated date unavailable"
else
  gen_date="$(head -n 20 "$BRAIN_INDEX" | grep '^Generated:' | head -n 1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1 || true)"
  case "$gen_date" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
      gen_y="${gen_date%%-*}"
      gen_rest="${gen_date#*-}"
      gen_m="${gen_rest%%-*}"
      gen_d="${gen_rest#*-}"
      gen_m_num=$((10#$gen_m))
      gen_d_num=$((10#$gen_d))
      if [ "$gen_m_num" -lt 1 ] || [ "$gen_m_num" -gt 12 ] || [ "$gen_d_num" -lt 1 ] || [ "$gen_d_num" -gt 31 ]; then
        fail check7 "brain-index Generated date is unparseable: $gen_date"
      else
        today_date="$(date +%Y-%m-%d)"
        today_y="${today_date%%-*}"
        today_rest="${today_date#*-}"
        today_m="${today_rest%%-*}"
        today_d="${today_rest#*-}"
        gen_days="$(date_to_days "$gen_y" "$gen_m" "$gen_d")"
        today_days="$(date_to_days "$today_y" "$today_m" "$today_d")"
        brain_age_days=$((today_days - gen_days))
        echo "INFO check7: brain-index generated $gen_date, age ${brain_age_days}d"
        if [ "$brain_age_days" -gt "$BRAIN_INDEX_WARN_AGE_DAYS" ]; then
          echo "WARN check7: brain-index age ${brain_age_days}d exceeds ${BRAIN_INDEX_WARN_AGE_DAYS}d (advisory; not counted as FAIL)"
        fi
      fi
      ;;
    *)
      fail check7 "brain-index Generated date missing or unparseable in first 20 lines"
      ;;
  esac
fi

if [ "$fails" -eq 0 ]; then
  echo "state-surface: PASS (repo: $REPO, version $SSOT)"
  exit 0
else
  echo "state-surface: FAIL ($fails failing item(s), repo: $REPO, version $SSOT)"
  exit 1
fi
