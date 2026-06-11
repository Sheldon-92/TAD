#!/usr/bin/env bash
# harvest-scan.sh — Read-only scan of registered projects' skillify candidates.
# Derives project list from sync-registry.yaml (never hardcodes paths).
# Outputs per-project table + cross-project collision section.
# STRICTLY READ-ONLY: this script contains NO mutation commands.
# Exit 0 always (reporting tool, not a gate).
set -euo pipefail

ROOT="${1:-.}"
REGISTRY="$ROOT/.tad/sync-registry.yaml"

if [ ! -f "$REGISTRY" ]; then
  echo "ERROR: sync-registry.yaml not found at $REGISTRY" >&2
  exit 0
fi

# Extract project paths from sync-registry.yaml (awk, no yq dependency)
extract_paths() {
  awk '/^  - path:/ { gsub(/^  - path: *"?|"? *$/, ""); print }' "$REGISTRY"
}

# Extract frontmatter field from a SCAND file (awk-based, tolerates missing fields)
fm_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    /^---$/ { hdr++; next }
    hdr == 1 && $0 ~ "^"f":" { sub(/^[^:]+: */, ""); gsub(/^ *"|" *$/, ""); print; exit }
    hdr >= 2 { exit }
  ' "$file" 2>/dev/null
}

echo "=========================================="
echo " TAD Harvest Scanner (read-only)"
echo "=========================================="
echo ""

total_projects=0
total_candidates=0
declare -a all_slugs=()

while IFS= read -r proj_path; do
  [ -z "$proj_path" ] && continue
  proj_name="$(basename "$proj_path")"
  scand_dir="$proj_path/.tad/active/skillify-candidates"

  if [ ! -d "$scand_dir" ]; then
    continue
  fi

  candidates=()
  while IFS= read -r -d '' f; do
    candidates+=("$f")
  done < <(find "$scand_dir" -maxdepth 1 -name 'SCAND-*.md' -print0 2>/dev/null)

  [ ${#candidates[@]} -eq 0 ] && continue

  total_projects=$((total_projects + 1))
  echo "── $proj_name ──"
  printf '%-35s %-12s %-10s %-4s %s\n' "Slug" "Type" "Status" "Tier" "Age(d)"
  printf '%-35s %-12s %-10s %-4s %s\n' "---" "---" "---" "---" "---"

  for f in "${candidates[@]}"; do
    bn="$(basename "$f" .md)"
    slug="$(fm_field "$f" "name")"
    [ -z "$slug" ] && slug="$bn"
    ctype="$(fm_field "$f" "type")"
    [ -z "$ctype" ] && ctype="-"
    status="$(fm_field "$f" "status")"
    [ -z "$status" ] && status="-"
    tier="$(fm_field "$f" "tier")"
    [ -z "$tier" ] && tier="-"

    # Age from filename date (SCAND-YYYYMMDD-... or SCAND-YYYY-MM-DD-...)
    fdate="$(echo "$bn" | grep -oE '[0-9]{4}-?[0-9]{2}-?[0-9]{2}' | head -1 | tr -d '-' || true)"
    if [ -n "$fdate" ]; then
      fdate_fmt="${fdate:0:4}-${fdate:4:2}-${fdate:6:2}"
      fepoch="$(date -j -f "%Y-%m-%d" "$fdate_fmt" "+%s" 2>/dev/null || echo "")"
      if [ -n "$fepoch" ]; then
        now="$(date "+%s")"
        age_days="$(( (now - fepoch) / 86400 ))"
      else
        age_days="-"
      fi
    else
      age_days="-"
    fi

    printf '%-35s %-12s %-10s %-4s %s\n' "$slug" "$ctype" "$status" "$tier" "$age_days"
    all_slugs+=("$proj_name:$slug")
    total_candidates=$((total_candidates + 1))
  done
  echo ""
done < <(extract_paths)

echo "=========================================="
echo "SUMMARY: $total_candidates candidates across $total_projects projects"
echo ""

# Cross-project collision detection (T3 graduation signal)
echo "COLLISIONS (same slug in ≥2 projects → T3 graduation signal):"
if [ ${#all_slugs[@]} -eq 0 ]; then
  echo "  (none — no candidates found)"
else
  # Extract slugs, find duplicates
  collisions="$(printf '%s\n' "${all_slugs[@]}" | awk -F: '{print $2}' | LC_ALL=C sort | uniq -d)"
  if [ -z "$collisions" ]; then
    echo "  (none)"
  else
    while IFS= read -r dup; do
      echo "  ⚠️  $dup found in:"
      printf '%s\n' "${all_slugs[@]}" | grep ":${dup}$" | awk -F: '{print "    - "$1}' | LC_ALL=C sort -u
    done <<< "$collisions"
  fi
fi
echo ""
