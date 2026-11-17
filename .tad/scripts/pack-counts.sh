#!/bin/bash
# pack-counts.sh - generate (and check) the capability-pack counts in INSTALLATION_GUIDE.md.
#
# Maintainer tool: the guide exists in the TAD source tree only; in a downstream project
# `--check` stops with exit 2 because the guide is missing.
#
#   bash .tad/scripts/pack-counts.sh            print the block that goes between the two PACK-COUNTS markers
#   bash .tad/scripts/pack-counts.sh --phrase   print the one-line count phrase used in running text
#   bash .tad/scripts/pack-counts.sh --check    exit 0 only if (1) the text between the markers equals the
#                                               generated block and (2) every line outside the block that
#                                               states a pack count contains the full count phrase
#   Options: --registry <file>  --categories <file>  --doc <file>
#     defaults: ../capability-packs/pack-registry.yaml, ./pack-categories.tsv, ../../INSTALLATION_GUIDE.md
#     (relative to this script)
#
# Exit codes: 0 ok | 1 stale (STALE block / STALE line on stderr) | 2 input error (PACK-COUNTS-ERROR on stderr)
#
# Workflow: edit the pack's CAPABILITY.md, run scan-packs.sh (regenerates the registry), run this script,
# paste its output between the markers and `--phrase` output into the count sentences, then run `--check`.
#
# Written for bash 3.2 and BSD tools. Does not call git. No awk string comparison (macOS awk treats any two
# CJK strings as equal): grouping and comparison use bash tests and grep -Fx. Sorting, where used, is LC_ALL=C.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
REGISTRY="$SCRIPT_DIR/../capability-packs/pack-registry.yaml"
CATEGORIES="$SCRIPT_DIR/pack-categories.tsv"
DOC="$SCRIPT_DIR/../../INSTALLATION_GUIDE.md"
MODE="block"

die() { echo "PACK-COUNTS-ERROR: $1" >&2; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --check) MODE="check"; shift ;;
    --phrase) MODE="phrase"; shift ;;
    --registry) [ $# -ge 2 ] || die "--registry needs a value"; REGISTRY="$2"; shift 2 ;;
    --categories) [ $# -ge 2 ] || die "--categories needs a value"; CATEGORIES="$2"; shift 2 ;;
    --doc) [ $# -ge 2 ] || die "--doc needs a value"; DOC="$2"; shift 2 ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    *) die "unknown option $1" ;;
  esac
done

[ -r "$REGISTRY" ] || die "cannot read registry $REGISTRY"
[ -r "$CATEGORIES" ] || die "cannot read categories $CATEGORIES"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/pack-counts.XXXXXX")" || die "mktemp failed"
trap 'rm -rf "$WORK"' EXIT

# --- registry: "name<TAB>status" per pack, in registry order -------------------------------------
sed -n -E 's/^  - name: "([^"]*)"[[:space:]]*$/N \1/p; s/^    status: "([^"]*)"[[:space:]]*$/S \1/p' "$REGISTRY" > "$WORK/raw"
: > "$WORK/packs"
cur=""
while IFS= read -r line; do
  kind="${line%% *}"
  val="${line#* }"
  if [ "$kind" = "N" ]; then
    [ -z "$cur" ] || die "no status for $cur"
    cur="$val"
  else
    [ -n "$cur" ] || die "status without a pack name"
    case "$val" in
      active|frozen) printf '%s\t%s\n' "$cur" "$val" >> "$WORK/packs" ;;
      *) die "status of $cur is '$val', expected active or frozen" ;;
    esac
    cur=""
  fi
done < "$WORK/raw"
[ -z "$cur" ] || die "no status for $cur"
total=$(wc -l < "$WORK/packs" | tr -d ' ')
[ "$total" -gt 0 ] || die "no packs found in $REGISTRY"
# an entry the parser did not recognise (other quotes, odd indentation, a trailing comment) must not vanish silently
starts=$(grep -c -E '^[[:space:]]*-[[:space:]]+name:' "$REGISTRY")
[ "$starts" -eq "$total" ] || die "registry has $starts entry-start lines but $total entries were recognised"
dup=$(cut -f1 "$WORK/packs" | LC_ALL=C sort | uniq -d | head -n 1)
[ -z "$dup" ] || die "duplicate $dup"
n_active=$(grep -c "	active$" "$WORK/packs")
n_frozen=$(grep -c "	frozen$" "$WORK/packs")

PHRASE="$total 个 capability packs（$n_active 个 active、$n_frozen 个 frozen）"

if [ "$MODE" = "phrase" ]; then
  printf '%s\n' "$PHRASE"
  exit 0
fi

# --- categories: "name<TAB>category", comments and blank lines skipped -----------------------------
grep -v -e '^#' -e '^[[:space:]]*$' "$CATEGORIES" > "$WORK/cats" || true
cut -f1 "$WORK/packs" > "$WORK/reg-names"
cut -f1 "$WORK/cats" > "$WORK/cat-names"
while IFS= read -r n; do
  grep -Fxq -- "$n" "$WORK/cat-names" || die "uncategorized $n"
done < "$WORK/reg-names"
while IFS= read -r n; do
  grep -Fxq -- "$n" "$WORK/reg-names" || die "stale category $n"
done < "$WORK/cat-names"

# category order = first appearance in the categories file (bash string tests, not awk)
: > "$WORK/cat-order"
while IFS="	" read -r n c; do
  grep -Fxq -- "$c" "$WORK/cat-order" || printf '%s\n' "$c" >> "$WORK/cat-order"
done < "$WORK/cats"

category_of() {
  local n c
  while IFS="	" read -r n c; do
    if [ "$n" = "$1" ]; then printf '%s' "$c"; return 0; fi
  done < "$WORK/cats"
  return 1
}

# --- build the block ---------------------------------------------------------------------------------
: > "$WORK/pack-cat"
while IFS="	" read -r n s; do
  printf '%s\t%s\t%s\n' "$n" "$s" "$(category_of "$n")" >> "$WORK/pack-cat"
done < "$WORK/packs"

{
  printf 'TAD 包含 %s，每个提供特定领域的判断规则。frozen 的 pack 同样会安装，只是不参与关键词自动匹配（见 `AGENTS.md` 的 Capability Packs 一节）。\n' "$PHRASE"
  printf '\n'
  printf '| 类别 | active | frozen |\n'
  printf '|------|--------|--------|\n'
  while IFS= read -r cat; do
    act=""; fro=""
    while IFS="	" read -r n s c; do
      [ "$c" = "$cat" ] || continue
      if [ "$s" = "active" ]; then act="${act:+$act, }$n"; else fro="${fro:+$fro, }$n"; fi
    done < "$WORK/pack-cat"
    printf '| %s | %s | %s |\n' "$cat" "${act:-—}" "${fro:-—}"
  done < "$WORK/cat-order"
} > "$WORK/block"

if [ "$MODE" = "block" ]; then
  cat "$WORK/block"
  exit 0
fi

# --- check ---------------------------------------------------------------------------------------------
[ -r "$DOC" ] || die "cannot read document $DOC"
BEGIN_RX='^<!-- PACK-COUNTS:BEGIN '
END_RX='^<!-- PACK-COUNTS:END -->$'
nb=$(grep -c -e "$BEGIN_RX" "$DOC")
ne=$(grep -c -e "$END_RX" "$DOC")
[ "$nb" -eq 1 ] && [ "$ne" -eq 1 ] || die "markers"
lb=$(grep -n -e "$BEGIN_RX" "$DOC" | cut -d: -f1)
le=$(grep -n -e "$END_RX" "$DOC" | cut -d: -f1)
[ "$lb" -lt "$le" ] || die "markers"

rc=0
sed -n "$((lb + 1)),$((le - 1))p" "$DOC" > "$WORK/doc-block"
if ! cmp -s "$WORK/block" "$WORK/doc-block"; then
  echo "PACK-COUNTS: STALE block" >&2
  diff "$WORK/doc-block" "$WORK/block" >&2
  rc=1
fi

# every line outside the block (markers included) that states a pack count must carry the whole phrase
LC_ALL=C grep -n -E '[0-9]+ ?(个)? ?(capability )?packs' "$DOC" > "$WORK/count-lines" || true
while IFS= read -r hit; do
  ln="${hit%%:*}"
  text="${hit#*:}"
  if [ "$ln" -ge "$lb" ] && [ "$ln" -le "$le" ]; then continue; fi
  case "$text" in
    *"$PHRASE"*) ;;
    *) echo "PACK-COUNTS: STALE line $ln: $text" >&2; rc=1 ;;
  esac
done < "$WORK/count-lines"

exit "$rc"
