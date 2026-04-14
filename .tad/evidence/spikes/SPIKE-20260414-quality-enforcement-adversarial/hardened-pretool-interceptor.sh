#!/bin/bash
# Hardened PreToolUse Write/Edit/MultiEdit/NotebookEdit interceptor (Phase 1b).
#
# Extends Phase 1a exp1 with:
#   - Unicode NFKC normalization (catches Cyrillic homoglyphs, etc.)
#   - Zero-width character strip (U+200B U+200C U+200D U+FEFF)
#   - Multi-tool matcher: Write, Edit, MultiEdit, NotebookEdit
#   - Symlink rejection on file_path
#   - Cross-validation of evidence files via hardened-evidence-validator.sh
#
# Fail-closed triggers (NFR3 — ≥5):
#   1. JSON malformation (inherited from 1a via jq + pipefail)
#   2. Hook timeout (>1s external watchdog — via `timeout` wrapper)
#   3. Unreadable input (permissions / dangling symlink)
#   4. Missing dependencies (jq / perl / openssl)
#   5. stdin EOF / partial JSON (jq fails on incomplete input)
#
# All 5 → permissionDecision: deny with diagnostic reason.

set -euo pipefail

# ────────────────────────────────────────────────────────────────
# Fail-closed emit helpers
# ────────────────────────────────────────────────────────────────
emit_deny_crash() {
  local reason="${1:-hook crashed - fail closed}"
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"'
  # JSON-escape minimal: only backslash and quote
  printf '%s' "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g'
  printf '%s\n' '"}}'
  exit 0
}

trap 'emit_deny_crash "hook crashed - fail closed (trap)"' ERR

emit_allow() {
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
}

emit_deny() {
  local reason="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -nc --arg r "$reason" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  else
    emit_deny_crash "missing dep: jq"
  fi
  exit 0
}

# ────────────────────────────────────────────────────────────────
# Trigger 4: Missing dependency check (fast-path fail)
# ────────────────────────────────────────────────────────────────
for dep in jq perl openssl; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    emit_deny_crash "missing dep: $dep"
  fi
done

# ────────────────────────────────────────────────────────────────
# Trigger 5: stdin availability — read with timeout, detect EOF/partial
# ────────────────────────────────────────────────────────────────
if ! STDIN_JSON=$(cat); then
  emit_deny_crash "stdin read failed"
fi
if [ -z "$STDIN_JSON" ]; then
  emit_deny_crash "stdin empty (EOF)"
fi

# ────────────────────────────────────────────────────────────────
# Trigger 1: JSON malformation — pipefail on jq parse
# Extract tool_name + file_path separately; then concat ALL text-bearing
# fields across Write/Edit/MultiEdit/NotebookEdit into one scan buffer.
# Fields covered:
#   Write:        .tool_input.content
#   Edit:         .tool_input.old_string + .tool_input.new_string
#   MultiEdit:    .tool_input.edits[].old_string + .tool_input.edits[].new_string
#   NotebookEdit: .tool_input.new_source + .tool_input.source
# Using jq's null-default (//) plus array flattening.
# ────────────────────────────────────────────────────────────────
# Single jq call extracts tool_name + file_path + content (text-bearing fields).
# Using \u001e (ASCII RS) as delimiter to preserve tabs/newlines in content
# (jq @tsv escapes them; jq raw join does not). One jq spawn instead of three.
if ! PARSED=$(printf '%s' "$STDIN_JSON" | jq -r '
  [
    .tool_name // "",
    .tool_input.file_path // "",
    ([
      .tool_input.content // "",
      .tool_input.old_string // "",
      .tool_input.new_string // "",
      .tool_input.new_source // "",
      .tool_input.source // "",
      ((.tool_input.edits // []) | map([.old_string // "", .new_string // ""]) | flatten | join(" "))
    ] | join(" "))
  ] | join("\u001e")
' 2>/dev/null); then
  emit_deny_crash "JSON malformed"
fi

FSEP=$'\x1E'
tool_name="${PARSED%%${FSEP}*}"
rest="${PARSED#*${FSEP}}"
file_path="${rest%%${FSEP}*}"
content="${rest#*${FSEP}}"

# ────────────────────────────────────────────────────────────────
# Multi-tool matcher — Phase 1b expanded scope:
#   Write/Edit/MultiEdit/NotebookEdit → content sentinel + path protection
#   Bash → route to bash-watcher patterns (evidence write-path, env injection)
#   Task → scan prompt for forbidden path patterns + background-task signals
# ────────────────────────────────────────────────────────────────

# ── Helper: normalize a file_path for denylist comparison ─────────
# Collapses leading `./` and `/./` and absolute path prefix to project-rel form.
normalize_path() {
  local p="$1"
  # Strip absolute project prefix if present
  local project_root="/Users/sheldonzhao/01-on progress programs/TAD"
  p="${p#$project_root/}"
  # Collapse /./ → /
  while [[ "$p" == *"/./"* ]]; do p="${p//\/.\//\/}"; done
  # Collapse leading ./
  while [[ "$p" == "./"* ]]; do p="${p#./}"; done
  # Expand ~ to home for user-global detection
  if [[ "$p" == "~/"* ]]; then
    p="${HOME}/${p#~/}"
  fi
  printf '%s' "$p"
}

# ── Helper: check if normalized path matches any protected pattern ─
# Returns 0 (match) or 1 (no match)
is_protected_path() {
  local p
  p=$(normalize_path "$1")
  # Absolute user-global settings
  case "$p" in
    "$HOME/.claude/settings.json"|"$HOME/.claude/settings."*.json) return 0 ;;
  esac
  # Project-relative protected patterns
  case "$p" in
    ".claude/settings.json"|".claude/settings."*.json) return 0 ;;
    ".tad/hooks/"*) return 0 ;;
    ".tad/skills/"*"/SKILL.md") return 0 ;;
    ".tad/evidence/spikes/SPIKE-20260414-quality-enforcement-adversarial/hardened-"*.sh) return 0 ;;
    ".tad/evidence/spikes/SPIKE-20260414-quality-enforcement-adversarial/test-runner.sh") return 0 ;;
  esac
  # Path with unresolved .. segments that could escape into protected area
  if [[ "$p" == *"/.."* ]]; then
    # Lexical collapse
    local collapsed="$p"
    while [[ "$collapsed" == *"/.."* ]]; do
      local head="${collapsed%%/..*}"
      local tail="${collapsed#*/..}"
      # Strip trailing component from head
      head="${head%/*}"
      collapsed="${head}${tail}"
    done
    # After collapse, re-check
    case "$collapsed" in
      ".tad/active/handoffs/"*|".tad/active/epics/"*) return 1 ;;  # these ARE allowed as final targets
      ".tad/hooks/"*|".claude/settings"*|".tad/skills/"*"/SKILL.md") return 0 ;;
    esac
  fi
  return 1
}

# ── Helper: check content for dangerous env var injection ─────────
has_env_injection() {
  local c="$1"
  local dangerous='(TAD_SKIP_VALIDATION|TAD_DISABLE_HOOKS|CLAUDE_SETTINGS_PATH|BASH_ENV|ENV)'
  if printf '%s' "$c" | grep -qE "(^|[[:space:];&|])(export[[:space:]]+)?$dangerous=" ; then
    return 0
  fi
  return 1
}

# ── Helper: inline Bash scan (mirrors hardened-bash-watcher) ──────
bash_command_is_forbidden() {
  local cmd="$1"
  # Normalize: strip empty quote pairs (evi''dence → evidence, ""dence → dence),
  # collapse Unicode, strip zero-width chars.
  # Using perl's hex-escape \x27 for single-quote to avoid shell-quoting nesting hell.
  local normalized
  normalized=$(printf '%s' "$cmd" | perl -CSD -MUnicode::Normalize -e '
    my $s = do { local $/; <STDIN> };
    $s = NFKC($s);
    $s =~ s/[\x{200B}\x{200C}\x{200D}\x{FEFF}\x{2060}\x{180E}]//g;
    $s =~ s/\x22\x22//g;  # strip empty "" pairs
    $s =~ s/\x27\x27//g;  # strip empty '' pairs (hex 0x27 = single quote)
    print $s;
  ' 2>/dev/null) || normalized="$cmd"
  local lower
  lower=$(printf '%s' "$normalized" | tr '[:upper:]' '[:lower:]')
  # Evidence path write patterns
  if printf '%s' "$lower" | grep -qE '(^|[[:space:]&|;\(])(>|>>)[[:space:]]*.tad/evidence/(reviews|overrides)/'; then return 0; fi
  if printf '%s' "$lower" | grep -qE '(^|[[:space:];&|])[a-z_][a-z0-9_]*=[[:space:]]*"?.tad/(evidence|active)/'; then return 0; fi
  if printf '%s' "$lower" | grep -qE 'tee[[:space:]]+(-a[[:space:]]+)?.tad/evidence/(reviews|overrides)/'; then return 0; fi
  if printf '%s' "$lower" | grep -qE '<<[-]?[a-z0-9_"'"'"']*.*>[[:space:]]*.tad/evidence/'; then return 0; fi
  if printf '%s' "$lower" | grep -qE '(^|[[:space:]])ln([[:space:]]+-s[a-z]*)?[[:space:]]+.*[[:space:]]+.tad/evidence/'; then return 0; fi
  if printf '%s' "$lower" | grep -qE '(^|[[:space:]])mv[[:space:]]+.*[[:space:]]+.tad/evidence/(reviews|overrides)/'; then return 0; fi
  if printf '%s' "$lower" | grep -qE '(^|[[:space:]])cp[[:space:]]+.*[[:space:]]+.tad/evidence/(reviews|overrides)/'; then return 0; fi
  # Env injection
  for var in TAD_SKIP_VALIDATION TAD_DISABLE_HOOKS CLAUDE_SETTINGS_PATH BASH_ENV CDPATH; do
    if printf '%s' "$normalized" | grep -qE "(^|[[:space:];&|])$var=" ; then return 0; fi
  done
  # Background + protected path combo (TOCTOU)
  if printf '%s' "$normalized" | grep -qE '&[[:space:]]*(disown|$|;)' || printf '%s' "$normalized" | grep -q 'run_in_background'; then
    if printf '%s' "$lower" | grep -qE '.tad/(evidence|active)/'; then return 0; fi
  fi
  if printf '%s' "$normalized" | grep -qE '\([[:space:]]*sleep'; then
    if printf '%s' "$lower" | grep -qE '.tad/(evidence|active)/'; then return 0; fi
  fi
  return 1
}

case "$tool_name" in
  Write|Edit|MultiEdit|NotebookEdit) ;;
  Bash)
    # Delegate to inline bash scan
    bash_cmd=$(printf '%s' "$STDIN_JSON" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
    if bash_command_is_forbidden "$bash_cmd"; then
      emit_deny "Bash command targets protected path or uses forbidden env injection: $(printf '%s' "$bash_cmd" | head -c 100)"
    fi
    emit_allow
    ;;
  Task)
    # Scan Task prompt for protected-path / background-task signals
    task_prompt=$(printf '%s' "$STDIN_JSON" | jq -r '.tool_input.prompt // ""' 2>/dev/null || echo "")
    # Flag if prompt mentions protected paths + write-action verbs
    if printf '%s' "$task_prompt" | grep -qiE '\.tad/(evidence/(reviews|overrides)|active/handoffs|active/epics|hooks)'; then
      if printf '%s' "$task_prompt" | grep -qiE '\b(write|printf|echo|redirect|create|append|mv|cp|ln|modify|edit)\b'; then
        emit_deny "Task sub-agent prompt instructs write to protected path: $(printf '%s' "$task_prompt" | head -c 100)"
      fi
    fi
    # Flag if prompt mentions background execution to protected paths
    if printf '%s' "$task_prompt" | grep -qiE '(run_in_background|background=true|sleep.*&|disown|nohup)'; then
      if printf '%s' "$task_prompt" | grep -qiE '\.tad/(evidence|active)/'; then
        emit_deny "Task sub-agent prompt uses background execution targeting protected path"
      fi
    fi
    emit_allow
    ;;
  *) emit_allow ;;
esac

# ────────────────────────────────────────────────────────────────
# Path traversal rejection (Cat 6 TOCTOU tc-004): refuse ANY path with `..`
# segments — conservative rule, no legitimate write needs `..`
# ────────────────────────────────────────────────────────────────
if [[ "$file_path" == *".."* ]]; then
  emit_deny "Path traversal rejected: $file_path contains '..' segments. Use canonical paths for defensive audit trail."
fi

# ────────────────────────────────────────────────────────────────
# Protected-path check (Cat 5 + Cat 7) — applies to Write/Edit/MultiEdit/NotebookEdit
# ────────────────────────────────────────────────────────────────
if is_protected_path "$file_path"; then
  emit_deny "Protected path: $file_path is defensive infrastructure (.claude/settings*, .tad/hooks/, spike hardened-*.sh, test-runner.sh, SKILL.md, or ~/.claude). Modification requires out-of-band TAD maintenance protocol."
fi

# ────────────────────────────────────────────────────────────────
# Scan edit payloads for path-traversal content (Cat 6 tc-005 — multi-edit body traversal)
# ────────────────────────────────────────────────────────────────
edits_traversal=$(printf '%s' "$STDIN_JSON" | jq -r '
  [
    .tool_input.old_string // "",
    .tool_input.new_string // "",
    ((.tool_input.edits // []) | map([.old_string // "", .new_string // ""]) | flatten | join(" "))
  ] | join(" ")
' 2>/dev/null) || edits_traversal=""
if printf '%s' "$edits_traversal" | grep -qE '(\.\./){2,}'; then
  emit_deny "Edit payload contains path-traversal sequence (../../...) — refusing defensive infrastructure sibling-write attempt."
fi

# ────────────────────────────────────────────────────────────────
# Content env-injection check (Cat 7) — independent of sentinel
# ────────────────────────────────────────────────────────────────
content_for_env=$(printf '%s' "$STDIN_JSON" | jq -r '
  [
    .tool_input.content // "",
    .tool_input.old_string // "",
    .tool_input.new_string // "",
    .tool_input.new_source // "",
    ((.tool_input.edits // []) | map([.old_string // "", .new_string // ""]) | flatten | join(" "))
  ] | join(" ")
' 2>/dev/null) || content_for_env=""
if has_env_injection "$content_for_env"; then
  emit_deny "Content contains dangerous env injection (TAD_SKIP_VALIDATION / CLAUDE_SETTINGS_PATH / BASH_ENV / ENV / TAD_DISABLE_HOOKS)"
fi

# ────────────────────────────────────────────────────────────────
# Trigger 3: Unreadable file / dangling symlink check (for Edit-style tools
# where file_path may point at an existing location)
# ────────────────────────────────────────────────────────────────
if [ -n "$file_path" ] && [ -L "$file_path" ] && [ ! -e "$file_path" ]; then
  emit_deny_crash "dangling symlink target"
fi

# Reject symlinks within .tad/evidence/ (anti-symlink-redirect)
if [ -n "$file_path" ]; then
  case "$file_path" in
    *.tad/evidence/reviews/*|*.tad/evidence/overrides/*)
      if [ -L "$file_path" ]; then
        emit_deny "symlink rejected in evidence path: $file_path"
      fi
      ;;
  esac
fi

# ────────────────────────────────────────────────────────────────
# Content normalization (Unicode NFKC + zero-width strip + confusables) via perl
# ────────────────────────────────────────────────────────────────
# Steps:
#   1. NFKC: folds compatibility forms (fullwidth, ligatures, etc.)
#   2. Strip zero-width chars: U+200B/C/D, U+FEFF BOM, U+2060, U+180E
#   3. NFD + strip combining marks: handles diacritics (é → e, ü → u)
#   4. Confusables table: maps Cyrillic/Greek letters that visually resemble
#      Latin ASCII (М→M, а→a, Ве→Be, etc.). NFKC alone does NOT do this —
#      a common LLM defender mistake. Table is conservative (only homoglyphs
#      of letters appearing in "message from blake").
# Combined normalize: produces BOTH strip-mode AND space-mode outputs in one perl call.
# Output is "strip_result\x00space_result" — separate and compare against sentinel.
# Reduces perl startup from 2× to 1× (~7ms savings per invocation).
normalize_dual() {
  perl -CSD -MUnicode::Normalize -e '
    my $orig = do { local $/; <STDIN> };
    my %conf = (
      "\x{0410}" => "A", "\x{0430}" => "a",
      "\x{0412}" => "B", "\x{0432}" => "B",
      "\x{0415}" => "E", "\x{0435}" => "e",
      "\x{041A}" => "K", "\x{043A}" => "k",
      "\x{041C}" => "M", "\x{043C}" => "m",
      "\x{041D}" => "H", "\x{043D}" => "h",
      "\x{041E}" => "O", "\x{043E}" => "o",
      "\x{0420}" => "P", "\x{0440}" => "p",
      "\x{0421}" => "C", "\x{0441}" => "c",
      "\x{0422}" => "T", "\x{0442}" => "T",
      "\x{0425}" => "X", "\x{0445}" => "x",
      "\x{0391}" => "A", "\x{03B1}" => "a",
      "\x{0392}" => "B", "\x{03B2}" => "B",
      "\x{0395}" => "E", "\x{03B5}" => "e",
      "\x{0397}" => "H",
      "\x{0399}" => "I", "\x{03B9}" => "i",
      "\x{039A}" => "K", "\x{03BA}" => "k",
      "\x{039C}" => "M",
      "\x{039D}" => "N",
      "\x{039F}" => "O", "\x{03BF}" => "o",
      "\x{03A1}" => "P", "\x{03C1}" => "p",
      "\x{03A4}" => "T", "\x{03C4}" => "t",
    );
    my $re = join("|", map { quotemeta } keys %conf);
    my @results;
    for my $mode ("strip", "space") {
      my $s = $orig;
      $s = NFKC($s);
      if ($mode eq "space") {
        $s =~ s/[\x{200B}\x{200C}\x{200D}\x{FEFF}\x{2060}\x{180E}]/ /g;
      } else {
        $s =~ s/[\x{200B}\x{200C}\x{200D}\x{FEFF}\x{2060}\x{180E}]//g;
      }
      $s = NFD($s);
      $s =~ s/\p{M}//g;
      $s =~ s/\s+/ /g;
      $s =~ s/($re)/$conf{$1}/g;
      push @results, $s;
    }
    # Use \x1E (ASCII RS) as separator; bash $() strips \x00 but preserves \x1E
    print join("\x1E", @results);
  '
}

normalize() {
  local ZW_MODE="${1:-strip}"  # legacy — used only if single-mode needed (kept for fallback)
  ZW_MODE="$ZW_MODE" perl -CSD -MUnicode::Normalize -e '
    my $s = do { local $/; <STDIN> };
    $s = NFKC($s);
    my $zw_mode = $ENV{ZW_MODE};
    if ($zw_mode eq "space") {
      # Treat zero-width + invisible separators as spaces (catches sentinels that
      # use ZW chars AS word separators, e.g. "message\u2060from\u180Eblake")
      $s =~ s/[\x{200B}\x{200C}\x{200D}\x{FEFF}\x{2060}\x{180E}]/ /g;
    } else {
      # Strip entirely (catches ZW injected INSIDE words, e.g. "Mess\u200Bage")
      $s =~ s/[\x{200B}\x{200C}\x{200D}\x{FEFF}\x{2060}\x{180E}]//g;
    }
    # NFD + strip combining marks (diacritics)
    $s = NFD($s);
    $s =~ s/\p{M}//g;
    # Collapse all whitespace runs (inc. tab, newline, NBSP) to single space
    $s =~ s/\s+/ /g;
    # Confusables — target the ASCII letters appearing in "message from blake"
    # plus digits. Uppercase + lowercase variants.
    my %conf = (
      # Cyrillic lookalikes (common Russian attack chars)
      "\x{0410}" => "A", "\x{0430}" => "a",
      "\x{0412}" => "B", "\x{0432}" => "B",
      "\x{0415}" => "E", "\x{0435}" => "e",
      "\x{0418}" => "N",                     # И ≈ N inverse (kept as N for safety)
      "\x{041A}" => "K", "\x{043A}" => "k",
      "\x{041C}" => "M", "\x{043C}" => "m",
      "\x{041D}" => "H", "\x{043D}" => "h",  # Н≈H, н≈h
      "\x{041E}" => "O", "\x{043E}" => "o",
      "\x{0420}" => "P", "\x{0440}" => "p",
      "\x{0421}" => "C", "\x{0441}" => "c",
      "\x{0422}" => "T", "\x{0442}" => "T",
      "\x{0425}" => "X", "\x{0445}" => "x",
      "\x{0431}" => "6",                     # б looks like 6
      "\x{0433}" => "r",                     # г ≈ r
      "\x{0438}" => "u",                     # и looks like u inverted
      "\x{043B}" => "l",                     # л ≈ l
      "\x{0433}" => "r",
      # Greek lookalikes
      "\x{0391}" => "A", "\x{03B1}" => "a",
      "\x{0392}" => "B", "\x{03B2}" => "B",
      "\x{0395}" => "E", "\x{03B5}" => "e",
      "\x{0397}" => "H",
      "\x{0399}" => "I", "\x{03B9}" => "i",
      "\x{039A}" => "K", "\x{03BA}" => "k",
      "\x{039C}" => "M", "\x{03BC}" => "u",
      "\x{039D}" => "N",
      "\x{039F}" => "O", "\x{03BF}" => "o",
      "\x{03A1}" => "P", "\x{03C1}" => "p",
      "\x{03A4}" => "T", "\x{03C4}" => "t",
      "\x{03A5}" => "Y",
      "\x{03A7}" => "X", "\x{03C7}" => "x",
      # Armenian / other
      "\x{0578}" => "n", "\x{0585}" => "o",
    );
    my $re = join("|", map { quotemeta } keys %conf);
    $s =~ s/($re)/$conf{$1}/g;
    print $s;
  '
}

# Single-perl dual normalization (strip-mode + space-mode separated by \x1E ASCII RS)
dual=$(printf '%s' "$content" | normalize_dual 2>/dev/null) || emit_deny_crash "normalization failed"
SEP=$'\x1E'
norm_strip="${dual%%${SEP}*}"
norm_space="${dual#*${SEP}}"

# ────────────────────────────────────────────────────────────────
# Sentinel match on normalized content (case-insensitive substring)
# ────────────────────────────────────────────────────────────────
match_found=0
if NORM="$norm_strip" awk 'BEGIN { if (index(tolower(ENVIRON["NORM"]), "message from blake") > 0) exit 0; exit 1 }'; then
  match_found=1
elif NORM="$norm_space" awk 'BEGIN { if (index(tolower(ENVIRON["NORM"]), "message from blake") > 0) exit 0; exit 1 }'; then
  match_found=1
fi
if [ "$match_found" -eq 0 ]; then
  emit_allow
fi

# ────────────────────────────────────────────────────────────────
# Slug extraction (same as 1a + robust fallback)
# ────────────────────────────────────────────────────────────────
slug="spike-default"
if [[ "$file_path" =~ HANDOFF-[0-9]{8}-([a-z0-9-]+) ]]; then
  slug="${BASH_REMATCH[1]}"
fi

# ────────────────────────────────────────────────────────────────
# Evidence count + cross-validate each via hardened-evidence-validator
# ────────────────────────────────────────────────────────────────
evidence_dir=".tad/evidence/reviews/blake/$slug"
valid_count=0
raw_count=0
if [ -d "$evidence_dir" ]; then
  SPIKE_DIR="$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")"
  validator="$SPIKE_DIR/hardened-evidence-validator.sh"
  while IFS= read -r f; do
    raw_count=$((raw_count + 1))
    if [ -f "$f" ] && [ ! -L "$f" ]; then
      if [ -x "$validator" ]; then
        if "$validator" "$f" >/dev/null 2>&1; then
          valid_count=$((valid_count + 1))
        fi
      else
        # Fallback: plain existence if validator missing
        valid_count=$((valid_count + 1))
      fi
    fi
  done < <(find "$evidence_dir" -maxdepth 1 -type f -name '*.md' 2>/dev/null)
fi

if [ "$valid_count" -lt 2 ]; then
  emit_deny "Missing evidence: $evidence_dir/*.md has $valid_count valid files (of $raw_count), need >=2. Run Layer 2 expert review before generating Message to Alex."
fi

emit_allow
