#!/usr/bin/env bash
# scan-collisions.sh — GREP-SEED candidate detector for cross-pack directive collisions.
#
# STAGE 1 of a hybrid two-stage detector (see .tad/guides/pack-collision-detection.md).
# For each pack PAIR sharing >=1 keyword, grep curated opposing-directive signatures.
# When BOTH sides hit, emit a CANDIDATE collision (both-side file:line + quote) to a
# staging file. STAGE 2 (LLM-CONFIRM, a documented agent procedure — NOT code here)
# confirms each candidate is a true opposing directive and writes pack-collisions.yaml.
#
# ⚠️ This is a CLI TOOL invoked manually / by an agent procedure — it is NOT a registered
#    hook. It MUST NOT be added to .claude/settings.json. The fail-fast strict-mode
#    set below is correct here (no-fail-closed-hook rule does NOT apply to non-hook tools).
#
# ⚠️ Anti-validation-theater: "N candidates found" is NOT acceptance. Every emitted
#    candidate's two file:line MUST be hand-re-derived against live packs (count != signal,
#    architecture.md 2026-05-30). The grep-seed half is deliberately dumb; the confirm
#    half is where false positives (co-mentions) get dropped.
#
# Canonical tree: scans the runtime-loaded `.claude/skills/` tree (where contradictions
#    AND the P2 surfacing consumers live), NOT `.tad/capability-packs/` (a *sync source copy).
#
# BSD-safe only (macOS): no `grep -P`, no `\d`, no `.*?`, no `readlink -f`. Use grep -E/-o + sed.
#
# Usage: bash .tad/scripts/scan-collisions.sh [--skills-dir=PATH]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAD_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$TAD_DIR/.." && pwd)"

# Scan target = runtime-loaded tree (NOT $TAD_DIR/capability-packs). The mirror of
# scan-packs.sh is about CONVENTIONS (set -e, arg-parse-before-OUTPUT, anchored awk,
# BSD-safe), not the literal directory.
SKILLS_DIR="$REPO_ROOT/.claude/skills"

# Curated opposing-directive signatures (topic|A-side -E regex|B-side -E regex).
SIGNATURES_FILE="$SCRIPT_DIR/collision-signatures.txt"

# Parse arguments BEFORE computing OUTPUT (OUTPUT does not depend on SKILLS_DIR here,
# but we keep arg-parse-before-derive convention; --help must exit cleanly).
for arg in "$@"; do
  case "$arg" in
    --skills-dir=*) SKILLS_DIR="${arg#--skills-dir=}" ;;
    --help|-h)
      echo "Usage: bash scan-collisions.sh [--skills-dir=PATH]"
      echo "  --skills-dir=PATH  Override skills directory (default: .claude/skills/)"
      echo ""
      echo "GREP-SEED candidate detector. For each pack pair sharing >=1 keyword,"
      echo "greps curated opposing-directive signatures and emits CANDIDATE collisions to:"
      echo "  .tad/evidence/yolo/pack-collision-detection/pack-collisions.candidates.yaml"
      echo ""
      echo "STAGE 1 of a hybrid detector. STAGE 2 (LLM-confirm) is a documented agent"
      echo "procedure (see .tad/guides/pack-collision-detection.md), NOT part of this script."
      echo "NOT a registered hook — do not add to .claude/settings.json."
      exit 0
      ;;
  esac
done

# OUTPUT (staging) — evidence dir, NOT inside .tad/capability-packs/ (avoids polluting
# the auto-generated registry space).
OUTPUT_DIR="$TAD_DIR/evidence/yolo/pack-collision-detection"
OUTPUT="$OUTPUT_DIR/pack-collisions.candidates.yaml"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "ERROR: Skills directory not found: $SKILLS_DIR" >&2
  exit 1
fi
if [ ! -f "$SIGNATURES_FILE" ]; then
  echo "ERROR: Signatures file not found: $SIGNATURES_FILE" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ── Helpers ──────────────────────────────────────────────────────────────────

# Extract keywords array from SKILL.md frontmatter (single-line flow form only).
# Anchored awk (BSD-safe), mirrors scan-packs.sh extract_keywords.
extract_keywords() {
  local file="$1"
  awk '/^---$/{if(++n==2) exit} n==1 && /^keywords: /' "$file" \
    | sed 's/^keywords: *//' \
    | head -1
}

# Normalize a keywords flow-form line into one keyword per line (lowercased, trimmed).
# BSD-safe: strip brackets/quotes, split on comma via tr, trim, lowercase.
keywords_to_lines() {
  local kw="$1"
  echo "$kw" \
    | sed 's/^\[//; s/\]$//' \
    | tr ',' '\n' \
    | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^"//; s/"$//' \
    | sed "s/^'//; s/'$//" \
    | sed '/^$/d' \
    | tr '[:upper:]' '[:lower:]'
}

# First match of an -E regex across a pack's *.md tree → "relpath:line:text" (or empty).
# PERF (architect P1-B): ONE `grep -rnE --include='*.md'` recurses the pack dir itself —
# far fewer process spawns than a per-file shell loop (was O(pairs²×sigs×files) → >90s).
# grep -rn yields "abspath:line:text". We then:
#   (1) drop excluded basenames (CHANGELOG.md / LICENSE* / README.md) — same exclusion the
#       old pack_files() find did, applied to grep's output paths,
#   (2) take the FIRST surviving hit (grep walks the tree in a stable order; head -1),
#   (3) rewrite the absolute path to repo-relative.
# BSD-safe: grep -rnE only (no -P), sed for path/exclusion filtering.
first_match() {
  local dir="$1"
  local pattern="$2"
  local hit
  # -I skips binary; --include limits to *.md; -E for BSD-safe extended regex.
  hit="$(grep -rInE --include='*.md' "$pattern" "$dir" 2>/dev/null \
    | grep -vE '/(CHANGELOG\.md|LICENSE[^/]*|README\.md):' \
    | head -1 || true)"
  [ -n "$hit" ] || return 1
  # hit is "abspath:line:text" → rewrite leading abspath to repo-relative.
  printf '%s\n' "${hit#$REPO_ROOT/}"
  return 0
}

# Flatten a string to a single line (no CR/LF), for safe YAML scalar embedding.
flatten() {
  printf '%s' "$1" | tr -d '\r' | tr '\n' ' ' | sed 's/[[:space:]]\{2,\}/ /g'
}

# ── Enumerate packs + keyword sets ───────────────────────────────────────────

PACK_NAMES=()
PACK_DIRS=()
PACK_KW=()  # parallel array: newline-joined lowercased keywords per pack

for skill_md in "$SKILLS_DIR"/*/SKILL.md; do
  [ -f "$skill_md" ] || continue
  pdir="$(dirname "$skill_md")"
  pname="$(basename "$pdir")"
  kw_raw="$(extract_keywords "$skill_md")"
  [ -n "$kw_raw" ] || continue   # skip packs with no keywords (cannot pair)
  kw_lines="$(keywords_to_lines "$kw_raw")"
  [ -n "$kw_lines" ] || continue
  PACK_NAMES+=("$pname")
  PACK_DIRS+=("$pdir")
  PACK_KW+=("$kw_lines")
done

# ── Read signatures ──────────────────────────────────────────────────────────
# Format per line: topic@@@A-side-regex@@@B-side-regex   (# comments and blanks ignored)
# Field delimiter is `@@@` (NOT `|`) so `|` stays free for -E regex alternation inside
# each side (e.g. an A-side `family=Inter|Inter.*next/font`).

TOPICS=()
A_REGEX=()
B_REGEX=()
while IFS= read -r sigline || [ -n "$sigline" ]; do
  case "$sigline" in
    ''|'#'*) continue ;;
  esac
  topic="${sigline%%@@@*}"
  rest="${sigline#*@@@}"
  a_re="${rest%%@@@*}"
  b_re="${rest#*@@@}"
  [ -n "$topic" ] && [ -n "$a_re" ] && [ -n "$b_re" ] || continue
  TOPICS+=("$topic")
  A_REGEX+=("$a_re")
  B_REGEX+=("$b_re")
done < "$SIGNATURES_FILE"

# ── Write candidates ─────────────────────────────────────────────────────────
# Atomic write (CR P2-2): build the whole staging file in a TEMP file, then `mv` into
# place on success. Under strict mode (errexit/nounset/pipefail), a denied/interrupted append must NEVER
# leave a truncated header-only $OUTPUT that a later reader misreads as "0 = clean".
TMP_OUTPUT="$(mktemp "${OUTPUT}.XXXXXX")"
trap 'rm -f "$TMP_OUTPUT"' EXIT

cat > "$TMP_OUTPUT" <<'HEADER'
# Auto-generated by scan-collisions.sh — STAGING candidates (do not edit manually).
# STAGE 1 grep-seed output. Each entry is a CANDIDATE; STAGE 2 (LLM-confirm, see
# .tad/guides/pack-collision-detection.md) must open both file:line refs, confirm a
# true opposing directive (not a co-mention), assign category, and write the
# confirmed row into .tad/capability-packs/pack-collisions.yaml.
# ⚠️ "N candidates found" is NOT acceptance — hand-re-derive every file:line.
candidates:
HEADER

n_pack="${#PACK_NAMES[@]}"
n_sig="${#TOPICS[@]}"
candidate_count=0
# Dedup (CR P2-1): each distinct collision must appear ONCE. Key = pack_a|pack_b|topic|a_ref|b_ref.
# (The grep -rnE rewrite already collapses per-file repeats; this guards remaining
# cross-orientation / re-hit duplicates so the staging file is 1 row per distinct collision.)
SEEN_KEYS=""

i=0
while [ "$i" -lt "$n_pack" ]; do
  j=$((i + 1))
  while [ "$j" -lt "$n_pack" ]; do
    # Shared-keyword pre-filter (BSD-safe set intersection via comm).
    # NOTE: this is a presence test, not a unique-match COUNT — we use comm, never
    # `grep -c | sort -u | wc -l` (that always returns 1, code-quality.md 2026-05-27).
    # ⚠️ LC_ALL=C on BOTH sorts AND comm: comm requires byte (C-locale) collation, but
    # the ambient locale (en_US.UTF-8) sorts CJK keywords differently → a phantom
    # intersection (e.g. 设计 spuriously "shared" by web-ui-design × video-creation).
    # Force byte collation everywhere so the intersection is byte-exact (CR P1-1).
    shared="$(LC_ALL=C comm -12 \
      <(printf '%s\n' "${PACK_KW[$i]}" | LC_ALL=C sort -u) \
      <(printf '%s\n' "${PACK_KW[$j]}" | LC_ALL=C sort -u))"
    if [ -n "$shared" ]; then
      # Pair qualifies — run each signature in BOTH orientations (A in pack_i / B in pack_j,
      # and A in pack_j / B in pack_i) so directive order doesn't matter.
      s=0
      while [ "$s" -lt "$n_sig" ]; do
        topic="${TOPICS[$s]}"
        a_re="${A_REGEX[$s]}"
        b_re="${B_REGEX[$s]}"

        # Orientation 1: A-side in pack_i, B-side in pack_j
        if a_hit="$(first_match "${PACK_DIRS[$i]}" "$a_re")" \
           && b_hit="$(first_match "${PACK_DIRS[$j]}" "$b_re")"; then
          pa="${PACK_NAMES[$i]}"; pb="${PACK_NAMES[$j]}"
        # Orientation 2: A-side in pack_j, B-side in pack_i
        elif a_hit="$(first_match "${PACK_DIRS[$j]}" "$a_re")" \
             && b_hit="$(first_match "${PACK_DIRS[$i]}" "$b_re")"; then
          pa="${PACK_NAMES[$j]}"; pb="${PACK_NAMES[$i]}"
        else
          s=$((s + 1)); continue
        fi

        # a_hit / b_hit are "relpath:line:text" → split into ref (relpath:line) + quote (text).
        a_ref="$(printf '%s' "$a_hit" | sed -E 's/^([^:]+:[0-9]+):.*/\1/')"
        a_quote="$(flatten "$(printf '%s' "$a_hit" | sed -E 's/^[^:]+:[0-9]+://')")"
        b_ref="$(printf '%s' "$b_hit" | sed -E 's/^([^:]+:[0-9]+):.*/\1/')"
        b_quote="$(flatten "$(printf '%s' "$b_hit" | sed -E 's/^[^:]+:[0-9]+://')")"

        # Dedup (CR P2-1): skip if this distinct collision was already emitted.
        dedup_key="${pa}|${pb}|${topic}|${a_ref}|${b_ref}"
        case "$SEEN_KEYS" in
          *"<<<${dedup_key}>>>"*) s=$((s + 1)); continue ;;
        esac
        SEEN_KEYS="${SEEN_KEYS}<<<${dedup_key}>>>"

        # Escape double quotes for YAML scalar safety.
        a_quote="${a_quote//\"/\\\"}"
        b_quote="${b_quote//\"/\\\"}"

        cat >> "$TMP_OUTPUT" <<CAND_EOF
  - pack_a: "${pa}"
    pack_b: "${pb}"
    topic: "${topic}"
    a_ref: "${a_ref}"
    a_quote: "${a_quote}"
    b_ref: "${b_ref}"
    b_quote: "${b_quote}"
CAND_EOF
        candidate_count=$((candidate_count + 1))
        s=$((s + 1))
      done
    fi
    j=$((j + 1))
  done
  i=$((i + 1))
done

# Atomic commit (CR P2-2): the full staging file is built — move it into place. Only now
# does $OUTPUT change; any earlier failure left the prior $OUTPUT untouched, never a
# truncated half-file. Clear the EXIT trap so the temp isn't rm'd after a successful mv.
mv "$TMP_OUTPUT" "$OUTPUT"
trap - EXIT

echo "scan-collisions.sh: scanned $n_pack packs x $n_sig signatures → $candidate_count candidate(s) → $OUTPUT" >&2
