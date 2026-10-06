#!/usr/bin/env bash
# brain-index-gen.sh — Generate .tad/brain-index.md from .tad/ + AGENTS.md
# Zero external dependencies. Output is a markdown file readable by an agent in one pass.
# Encoding contract: output is UTF-8; every truncation/suffix-strip is character-safe
# (never splits a multi-byte character) in ANY locale, including LC_ALL=C.
# Load points: tad.sh (initial install + refresh paths) and the release closeout
# step in publish-protocol (see .agents/skills/alex/references/publish-protocol.md).
set -euo pipefail

TAD_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
TAD_DIR="$TAD_ROOT/.tad"
OUT="$TAD_DIR/brain-index.md"
AGENTS_MD="$TAD_ROOT/AGENTS.md"

escape_pipe() { sed 's/|/\\|/g'; }
# utcut N — truncate stdin to at most N bytes WITHOUT splitting a UTF-8
# character: byte-cap first, then drop an incomplete trailing multi-byte
# sequence if the cap landed mid-character. Raw-byte operation via perl
# (an existing in-repo tool), so the result is identical in any locale —
# GNU/BSD `cut -c` counts bytes under LC_ALL=C/POSIX and split characters.
utcut() {
  perl -e '
    my $n = $ARGV[0];
    local $/;
    my $s = <STDIN>;
    $s = "" unless defined $s;
    $s =~ s/\n\z//;
    $s = substr($s, 0, $n) if length($s) > $n;
    $s =~ s/(?:[\xC0-\xDF]|[\xE0-\xEF][\x80-\xBF]?|[\xF0-\xF7][\x80-\xBF]{0,2})\z//;
    print $s;
  ' "$1"
}
# utstrip_title — strip a trailing date suffix (" - YYYY-MM-DD",
# " — AMENDED YYYY-MM-DD", " — inception"-style forms carry no date and are
# kept) from a title line, byte-safely: the em-dash is matched as its full
# UTF-8 byte sequence, never as a byte class (a [-—] class under a POSIX
# locale matches individual bytes and splits the character).
utstrip_title() {
  perl -pe 's/ *(?:-|\xe2\x80\x94) *(?:inception|AMENDED )?[0-9]{4}-[0-9]{2}-[0-9]{2}$//'
}
first_sentence() { head -1 | sed 's/[[:space:]]*$//' | utcut 120 | escape_pipe; }
slug_keywords() { echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/ /g' | tr -s ' '; }

file_count=0

{
echo "# TAD Brain Index"
echo "Generated: $(date '+%Y-%m-%d %H:%M')"
echo ""

# ═══════════════════════════════════════
# §1 Principles
# ═══════════════════════════════════════
PRINCIPLES="$TAD_DIR/project-knowledge/principles.md"
if [ -f "$PRINCIPLES" ]; then
  echo "## Principles"
  echo "| Entry | Keywords | Summary |"
  echo "|-------|----------|---------|"
  current_title=""
  got_summary=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^###\  ]]; then
      # Emit previous entry if summary wasn't captured yet
      if [[ -n "$current_title" && -z "$got_summary" ]]; then
        echo "| $current_title | $kw | (see file for details) |"
        file_count=$((file_count + 1))
      fi
      current_title=$(echo "$line" | sed 's/^### //' | utstrip_title | escape_pipe)
      kw=$(slug_keywords "$current_title")
      got_summary=""
    elif [[ -n "$current_title" && -z "$got_summary" ]]; then
      # Capture first substantive line as summary
      if [[ "$line" =~ ^-\ \*\*(Discovery|Context|Action)\*\*: ]]; then
        summary=$(echo "$line" | sed 's/^- \*\*[^*]*\*\*: //' | utcut 120 | escape_pipe)
        echo "| $current_title | $kw | $summary |"
        file_count=$((file_count + 1))
        got_summary="yes"
      elif [[ "$line" =~ ^-\ \*\*failure_mode\*\*: ]]; then
        summary=$(echo "$line" | sed 's/^- \*\*failure_mode\*\*: //' | utcut 120 | escape_pipe)
        echo "| $current_title | $kw | $summary |"
        file_count=$((file_count + 1))
        got_summary="yes"
      fi
    fi
  done < "$PRINCIPLES"
  # Emit last entry if pending
  if [[ -n "$current_title" && -z "$got_summary" ]]; then
    echo "| $current_title | $kw | (see file for details) |"
    file_count=$((file_count + 1))
  fi
  echo ""
fi

# ═══════════════════════════════════════
# §2 Patterns (reuse _index.md)
# ═══════════════════════════════════════
PATTERNS_INDEX="$TAD_DIR/project-knowledge/patterns/_index.md"
if [ -f "$PATTERNS_INDEX" ]; then
  echo "## Patterns"
  echo "| File | Keywords | Summary |"
  echo "|------|----------|---------|"
  while IFS= read -r line; do
    if [[ "$line" =~ ^-\ \[ ]]; then
      fname=$(echo "$line" | sed 's/^- \[\([^]]*\)\].*/\1/' | escape_pipe)
      hook=$(echo "$line" | sed 's/^[^—]*— //' | escape_pipe)
      kw=$(echo "$hook" | tr ',' '\n' | head -5 | tr '\n' ',' | sed 's/,$//')
      echo "| $fname | $kw | $hook |"
      file_count=$((file_count + 1))
    fi
  done < "$PATTERNS_INDEX"
  echo ""
fi

# ═══════════════════════════════════════
# §3 Project Knowledge (non-pattern files)
# ═══════════════════════════════════════
echo "## Project Knowledge"
echo "| File | Keywords | Summary |"
echo "|------|----------|---------|"
find "$TAD_DIR/project-knowledge" -maxdepth 1 -name "*.md" -not -name "README.md" -print0 2>/dev/null | sort -z | \
  while IFS= read -r -d '' file; do
    fname=$(basename "$file")
    summary=$({ grep -m1 '^## \|^### ' "$file" 2>/dev/null || true; } | sed 's/^#* //' | utcut 120 | escape_pipe)
    [ -z "$summary" ] && summary=$(sed -n '/^[^#>@!-]/p' "$file" 2>/dev/null | head -1 | utcut 120 | escape_pipe)
    kw=$(slug_keywords "${fname%.md}")
    echo "| $fname | $kw | $summary |"
    file_count=$((file_count + 1))
  done
echo ""

# ═══════════════════════════════════════
# §4 AGENTS.md Sections
# ═══════════════════════════════════════
if [ -f "$AGENTS_MD" ]; then
  echo "## AGENTS.md Sections"
  echo "| Section | Keywords | Summary |"
  echo "|---------|----------|---------|"
  while IFS= read -r line; do
    if [[ "$line" =~ ^##\  ]]; then
      section=$(echo "$line" | sed 's/^## //' | escape_pipe)
      kw=$(slug_keywords "$section")
      # grab next non-empty line as summary
      summary=""
    elif [[ -n "${section:-}" && -z "${summary:-}" && -n "$line" && ! "$line" =~ ^# ]]; then
      summary=$(echo "$line" | utcut 120 | escape_pipe)
      echo "| $section | $kw | $summary |"
      file_count=$((file_count + 1))
      section=""
    fi
  done < "$AGENTS_MD"
  echo ""
fi

# ═══════════════════════════════════════
# §5 Active Handoffs
# ═══════════════════════════════════════
ACTIVE_DIR="$TAD_DIR/active/handoffs"
if [ -d "$ACTIVE_DIR" ]; then
  echo "## Active Handoffs"
  echo "| File | Task Type | Summary |"
  echo "|------|-----------|---------|"
  find "$ACTIVE_DIR" -name "HANDOFF-*.md" -print0 2>/dev/null | sort -z | \
    while IFS= read -r -d '' file; do
      fname=$(basename "$file")
      task_type=$({ grep -m1 '^task_type:' "$file" 2>/dev/null || true; } | sed 's/task_type: *//' | tr -d '[:space:]')
      task_type="${task_type:-unknown}"
      # Get first line of §1.1
      summary=$(sed -n '/^### 1.1/,/^###/{/^### 1.1/d;/^###/d;/^$/d;p;}' "$file" 2>/dev/null | head -1 | utcut 120 | escape_pipe)
      echo "| $fname | $task_type | $summary |"
      file_count=$((file_count + 1))
    done
  echo ""
fi

# ═══════════════════════════════════════
# §6 Active Epics
# ═══════════════════════════════════════
EPIC_DIR="$TAD_DIR/active/epics"
if [ -d "$EPIC_DIR" ]; then
  echo "## Active Epics"
  echo "| File | Summary |"
  echo "|------|---------|"
  find "$EPIC_DIR" \( -name "EPIC-*.md" -o -name "epic-*.md" \) -print0 2>/dev/null | sort -z | \
    while IFS= read -r -d '' file; do
      fname=$(basename "$file")
      summary=$({ grep -m1 '^[^#>|!-]' "$file" 2>/dev/null || true; } | head -1 | utcut 120 | escape_pipe)
      echo "| $fname | $summary |"
      file_count=$((file_count + 1))
    done
  echo ""
fi

# ═══════════════════════════════════════
# §7 Archived Handoffs (last 50 by name = date-sorted)
# ═══════════════════════════════════════
ARCHIVE_DIR="$TAD_DIR/archive/handoffs"
if [ -d "$ARCHIVE_DIR" ]; then
  echo "## Archived Handoffs (recent 50)"
  echo "| File | Task Type | Summary |"
  echo "|------|-----------|---------|"
  find "$ARCHIVE_DIR" \( -name "HANDOFF-*.md" -o -name "handoff-*.md" \) 2>/dev/null | sort -r | head -50 | \
    while IFS= read -r file; do
      fname=$(basename "$file")
      task_type=$({ grep -m1 '^task_type:' "$file" 2>/dev/null || true; } | sed 's/task_type: *//;s/ *#.*//' | tr -d '[:space:]')
      [ -z "$task_type" ] && task_type="unknown"
      task_type=$(echo "$task_type" | escape_pipe)
      summary=$({ grep -m1 '^# ' "$file" 2>/dev/null || true; } | sed 's/^# //' | utcut 120 | escape_pipe)
      [ -z "$summary" ] && summary=$(basename "$file" .md | sed 's/^[Hh][Aa][Nn][Dd][Oo][Ff][Ff]-//' | escape_pipe)
      echo "| $fname | $task_type | $summary |"
      file_count=$((file_count + 1))
    done
  echo ""
fi

# ═══════════════════════════════════════
# §8 Evidence (directory-level index)
# ═══════════════════════════════════════
echo "## Evidence Directories"
echo "| Directory | Files | Topic |"
echo "|-----------|-------|-------|"
find "$TAD_DIR/evidence" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z | \
  while IFS= read -r -d '' dir; do
    dirname=$(basename "$dir")
    count=$(find "$dir" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    topic=$(slug_keywords "$dirname" | sed 's/^ *//')
    echo "| evidence/$dirname/ | $count | $topic |"
    file_count=$((file_count + 1))
  done
echo ""

# ═══════════════════════════════════════
# §9 Decision Records
# ═══════════════════════════════════════
DECISIONS_DIR="$TAD_DIR/decisions"
if [ -d "$DECISIONS_DIR" ]; then
  echo "## Decision Records"
  echo "| File | Summary |"
  echo "|------|---------|"
  find "$DECISIONS_DIR" -name "*.md" -print0 2>/dev/null | sort -z | \
    while IFS= read -r -d '' file; do
      fname=$(basename "$file")
      summary=$({ grep -m1 '^# \|^## ' "$file" 2>/dev/null || true; } | sed 's/^#* //' | utcut 120 | escape_pipe)
      echo "| $fname | $summary |"
      file_count=$((file_count + 1))
    done
  echo ""
fi

# ═══════════════════════════════════════
# §10 Config files
# ═══════════════════════════════════════
echo "## Config Files"
echo "| File | Contains |"
echo "|------|---------|"
find "$TAD_DIR" -maxdepth 1 -name "config*.yaml" -print0 2>/dev/null | sort -z | \
  while IFS= read -r -d '' file; do
    fname=$(basename "$file")
    contains=$({ grep '^ *- ' "$file" 2>/dev/null || true; } | head -5 | tr '\n' ',' | sed 's/^ *- //g;s/,$//' | utcut 120 | escape_pipe)
    echo "| $fname | $contains |"
    file_count=$((file_count + 1))
  done
echo ""

# ═══════════════════════════════════════
# §11 Skills (SKILL.md files)
# ═══════════════════════════════════════
if [ -d "$TAD_ROOT/.agents/skills" ]; then
  SKILLS_DIR="$TAD_ROOT/.agents/skills"
else
  SKILLS_DIR=""
fi
if [ -n "$SKILLS_DIR" ]; then
  echo "## Skills"
  echo "| Skill | Summary |"
  echo "|-------|---------|"
  find "$SKILLS_DIR" -name "SKILL.md" -print0 2>/dev/null | sort -z | \
    while IFS= read -r -d '' file; do
      skill_name=$(echo "$file" | sed "s|$SKILLS_DIR/||" | sed 's|/SKILL.md||')
      summary=$({ grep -m1 '^[^#>|!-]' "$file" 2>/dev/null || true; } | head -1 | utcut 80 | escape_pipe)
      echo "| $skill_name | $summary |"
      file_count=$((file_count + 1))
  done
  echo ""
else
  echo "## Skills"
  echo "(no skills tree found)"
  echo ""
fi

echo "---"
echo "Total indexed entries: (see above tables)"

} > "$OUT"

lines=$(wc -l < "$OUT")
echo "brain-index.md generated: $lines lines at $OUT"
