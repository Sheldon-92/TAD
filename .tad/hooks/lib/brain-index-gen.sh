#!/usr/bin/env bash
# brain-index-gen.sh — Generate .tad/brain-index.md from .tad/ + CLAUDE.md
# Zero external dependencies. Output is a markdown file readable by an agent in one pass.
set -euo pipefail

TAD_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
TAD_DIR="$TAD_ROOT/.tad"
OUT="$TAD_DIR/brain-index.md"
CLAUDE_MD="$TAD_ROOT/CLAUDE.md"

escape_pipe() { sed 's/|/\\|/g'; }
first_sentence() { head -1 | sed 's/[[:space:]]*$//' | cut -c1-120 | escape_pipe; }
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
      current_title=$(echo "$line" | sed 's/^### //' | sed 's/ *[-—] *\(inception\|AMENDED \)\{0,1\}[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]$//' | escape_pipe)
      kw=$(slug_keywords "$current_title")
      got_summary=""
    elif [[ -n "$current_title" && -z "$got_summary" ]]; then
      # Capture first substantive line as summary
      if [[ "$line" =~ ^-\ \*\*(Discovery|Context|Action)\*\*: ]]; then
        summary=$(echo "$line" | sed 's/^- \*\*[^*]*\*\*: //' | cut -c1-120 | escape_pipe)
        echo "| $current_title | $kw | $summary |"
        file_count=$((file_count + 1))
        got_summary="yes"
      elif [[ "$line" =~ ^-\ \*\*failure_mode\*\*: ]]; then
        summary=$(echo "$line" | sed 's/^- \*\*failure_mode\*\*: //' | cut -c1-120 | escape_pipe)
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
    summary=$(grep -m1 '^## \|^### ' "$file" 2>/dev/null | sed 's/^#* //' | cut -c1-120 | escape_pipe)
    [ -z "$summary" ] && summary=$(sed -n '/^[^#>@!-]/p' "$file" 2>/dev/null | head -1 | cut -c1-120 | escape_pipe)
    kw=$(slug_keywords "${fname%.md}")
    echo "| $fname | $kw | $summary |"
    file_count=$((file_count + 1))
  done
echo ""

# ═══════════════════════════════════════
# §4 CLAUDE.md Sections
# ═══════════════════════════════════════
if [ -f "$CLAUDE_MD" ]; then
  echo "## CLAUDE.md Sections"
  echo "| Section | Keywords | Summary |"
  echo "|---------|----------|---------|"
  while IFS= read -r line; do
    if [[ "$line" =~ ^##\  ]]; then
      section=$(echo "$line" | sed 's/^## //' | escape_pipe)
      kw=$(slug_keywords "$section")
      # grab next non-empty line as summary
      summary=""
    elif [[ -n "${section:-}" && -z "${summary:-}" && -n "$line" && ! "$line" =~ ^# ]]; then
      summary=$(echo "$line" | cut -c1-120 | escape_pipe)
      echo "| $section | $kw | $summary |"
      file_count=$((file_count + 1))
      section=""
    fi
  done < "$CLAUDE_MD"
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
      task_type=$(grep '^task_type:' "$file" 2>/dev/null | head -1 | sed 's/task_type: *//' || echo "unknown")
      # Get first line of §1.1
      summary=$(sed -n '/^### 1.1/,/^###/{/^### 1.1/d;/^###/d;/^$/d;p;}' "$file" 2>/dev/null | head -1 | cut -c1-120 | escape_pipe)
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
      summary=$(grep -m1 '^[^#>|!-]' "$file" 2>/dev/null | head -1 | cut -c1-120 | escape_pipe)
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
  find "$ARCHIVE_DIR" -name "HANDOFF-*.md" -o -name "handoff-*.md" 2>/dev/null | sort -r | head -50 | \
    while IFS= read -r file; do
      fname=$(basename "$file")
      task_type=$(grep -m1 '^task_type:' "$file" 2>/dev/null | sed 's/task_type: *//;s/ *#.*//' | tr -d '[:space:]')
      [ -z "$task_type" ] && task_type="unknown"
      task_type=$(echo "$task_type" | escape_pipe)
      summary=$(grep -m1 '^# ' "$file" 2>/dev/null | sed 's/^# //' | cut -c1-120 | escape_pipe)
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
      summary=$(grep -m1 '^# \|^## ' "$file" 2>/dev/null | sed 's/^#* //' | cut -c1-120 | escape_pipe)
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
    contains=$(grep '^ *- ' "$file" 2>/dev/null | head -5 | tr '\n' ',' | sed 's/^ *- //g;s/,$//' | cut -c1-120 | escape_pipe)
    echo "| $fname | $contains |"
    file_count=$((file_count + 1))
  done
echo ""

# ═══════════════════════════════════════
# §11 Skills (SKILL.md files)
# ═══════════════════════════════════════
SKILLS_DIR="$TAD_ROOT/.claude/skills"
if [ -d "$SKILLS_DIR" ]; then
  echo "## Skills"
  echo "| Skill | Summary |"
  echo "|-------|---------|"
  find "$SKILLS_DIR" -name "SKILL.md" -print0 2>/dev/null | sort -z | \
    while IFS= read -r -d '' file; do
      skill_name=$(echo "$file" | sed "s|$SKILLS_DIR/||" | sed 's|/SKILL.md||')
      summary=$(grep -m1 '^[^#>|!-]' "$file" 2>/dev/null | head -1 | cut -c1-80 | escape_pipe)
      echo "| $skill_name | $summary |"
      file_count=$((file_count + 1))
    done
  echo ""
fi

echo "---"
echo "Total indexed entries: (see above tables)"

} > "$OUT"

lines=$(wc -l < "$OUT")
echo "brain-index.md generated: $lines lines at $OUT"
