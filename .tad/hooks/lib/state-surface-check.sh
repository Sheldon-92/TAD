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
#   8. Keyword-conflict assertion on registered governed-surface pairs.
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
# check4 maintenance point (Epic P3, inherited-item C anchor 1): OLD_PAT below is
# a MINOR-release maintenance point — on a minor bump, change its row number to
# the new major\.minor([^0-9.]|$) form; patch bumps leave it unchanged. It is
# written in escaped form, so version-literal scans cannot see it: verify it by
# hand at every minor closeout per publish-ops §3.1 (incl. the paired controls).
OLD_PAT='(Version|v)\*{0,2}:?\*{0,2} ?3\.1([^0-9.]|$)'
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

# ---- Check 8: keyword-conflict assertion on registered surface pairs -----
# Registered governed-surface pairs (MAINTENANCE POINT: one block per
# pair; adding a pair = add its constants here + a fixture tree).
# Three-layer false-positive defence: (1) jurisdiction is this explicit
# pair registry only — nothing outside a registered pair is scanned;
# (2) the governed side is compared only inside its anchored block, so
# historical sections of the same file are never scanned; (3) verbatim
# exemptions registered per pair are masked out of the normalized block
# before matching (exact literals only, no regex).
#
# PAIR-1:
#   governed surface : AGENTS.md blockquote block anchored at the
#                      "> **Runtime status" line
#   fact source      : same file, "## Known Gaps" section, first line
#                      starting "- **P2 " and naming "Hook adapters";
#                      the fact holds iff that line contains "(implemented"
#   stale patterns   : literals from the 2026-10-06 incident header text
#   exemption        : registered 2026-10-06 — an in-block correction
#                      note legitimately quoting the superseded wording
C8_PAIR1_STALE_1='no lifecycle hooks'
C8_PAIR1_STALE_2='the **hook-enabled** runtime'
C8_PAIR1_STALE_3='currently get skills + routing + packs'
C8_PAIR1_EXEMPT_1='had "no lifecycle hooks"; superseded by Epic Phase 3'

C8_FILE="$REPO/AGENTS.md"
if [ ! -f "$C8_FILE" ]; then
  fail check8 "PAIR-1 governed surface anchor missing: AGENTS.md not found"
else
  # Governed block extraction (stateful awk): from the anchor line,
  # collect the consecutive blockquote lines; stop at the first
  # non-blockquote line. No range-pattern extraction — the extraction
  # boundary must match the governed location exactly.
  c8_block="$(awk '
    /^> \*\*Runtime status/ { inblock=1 }
    inblock && /^>/ { print; next }
    inblock { exit }
  ' "$C8_FILE")"
  if [ -z "$c8_block" ]; then
    fail check8 "PAIR-1 governed surface anchor missing in AGENTS.md (Runtime status block not found)"
  else
    # Fact source line (stateful awk over the Known Gaps section).
    c8_fact="$(awk '
      index($0, "## Known Gaps") == 1 { insec=1; next }
      insec && /^## / { exit }
      insec && index($0, "- **P2 ") == 1 && index($0, "Hook adapters") > 0 { print; exit }
    ' "$C8_FILE")"
    if [ -z "$c8_fact" ]; then
      fail check8 "PAIR-1 fact-source anchor missing in AGENTS.md (Known Gaps P2 bullet not found)"
    elif ! printf '%s' "$c8_fact" | grep -Fq -e '(implemented'; then
      pass check8 "PAIR-1 fact source does not assert implementation; governed wording is not a contradiction"
      echo "INFO check8: PAIR-1 fact pattern '(implemented' absent from fact-source line; stale-pattern scan skipped"
    else
      # Normalize the governed block: strip the leading ">" plus at most
      # one space per line, join lines with a single space, collapse
      # space runs — a stale phrase wrapped across blockquote lines
      # (the incident text wraps "no lifecycle" / "hooks**" across two
      # lines) must still match after normalization.
      c8_text="$(printf '%s\n' "$c8_block" | sed 's/^> \{0,1\}//' | tr '\n' ' ' | tr -s ' ')"
      # Registration hygiene: a registered exemption that no longer
      # appears in the block is reported as INFO only, never a FAIL.
      if ! printf '%s' "$c8_text" | grep -Fq -e "$C8_PAIR1_EXEMPT_1"; then
        echo "INFO check8: PAIR-1 registered exemption not present in governed block (registration hygiene)"
      fi
      # Mask registered verbatim exemptions before matching: locate
      # with awk index() (the only string operation verified safe in
      # this repo's CJK context) and cut the literal out. Never use
      # awk string equality or shell glob substitution here — the
      # exemption literal contains quotes and punctuation.
      c8_masked="$(printf '%s' "$c8_text" | C8_EXEMPT="$C8_PAIR1_EXEMPT_1" awk '
        { buf = buf $0 }
        END {
          ex = ENVIRON["C8_EXEMPT"]
          while ((i = index(buf, ex)) > 0) {
            buf = substr(buf, 1, i - 1) substr(buf, i + length(ex))
          }
          print buf
        }')"
      # Aggregate verdict: at most one fail() call per pair, naming
      # every stale pattern hit in the one message.
      c8_hits=""
      for c8_pat in "$C8_PAIR1_STALE_1" "$C8_PAIR1_STALE_2" "$C8_PAIR1_STALE_3"; do
        if printf '%s' "$c8_masked" | grep -Fq -e "$c8_pat"; then
          c8_hits="${c8_hits:+$c8_hits; }'$c8_pat'"
        fi
      done
      if [ -n "$c8_hits" ]; then
        fail check8 "PAIR-1 stale pattern(s) in governed block contradict fact source: $c8_hits"
      else
        pass check8 "PAIR-1 governed block carries no stale pattern contradicting the fact source"
      fi
    fi
  fi
fi

if [ "$fails" -eq 0 ]; then
  echo "state-surface: PASS (repo: $REPO, version $SSOT)"
  exit 0
else
  echo "state-surface: FAIL ($fails failing item(s), repo: $REPO, version $SSOT)"
  exit 1
fi
