#!/bin/bash
# tad-backups.sh — backup lifecycle for one project (TAD update flow, Phase 3).
#
# Commands (all offline; no byte of any backed-up file is ever printed):
#   classify  [--ledger <f>] [--project <dir>] <file>...   one line per file: <class><TAB><label|-><TAB><path>
#   lifecycle --project <dir> --group-dir <dir> --run-backup <dir> --ledger <f> [--legacy-group <dir>]
#                                                          installer step: holding area, caps, stored classes
#   list      [--project <dir>]                            held items, sizes, review flags, the To clear line
#   clearable [--project <dir>] [--token <t> --ids-out <f>]  machine keys for the check screen
#   clear     [--project <dir>] (--all --token <t> | --ids-file <f> --how <h> | --id <id> --token <t>) [--yes]
#   salvage   [--project <dir>]                            files the project edited inside TAD files (diff to a local file)
#   absorb    [--project <dir>] --from <abs path> [--yes]  copy one `edited` backup file into the salvage dir under project-knowledge
#
# Classes (first match wins): released | tad-report | regenerated | in-project | edited | differs | unknown.
# Safety structure (handoff Phase 3 section 4.7): every path is reached only when its physical path (pwd -P) EQUALS
# the string built from the resolved base; nothing is created, moved, written or removed before the parent of its
# target has passed that check; missing directories are made one level at a time under an anchored parent.
# Deletion only of a held item that is still in the set that made its token. Bash 3.2 and BSD/GNU userland.
set -u

TAB=$'\t'
NL=$'\n'
IDRE='^h[0-9]{8}-[0-9]{6}(\.[0-9]+)?$'
BKRE='^[0-9]{8}_[0-9]{6}(\.[0-9]+)?$'

warn() { printf 'tad-backups: %s\n' "$*" >&2; }
die() { warn "$*"; exit 2; }

# ---------------------------------------------------------------- small helpers
# remove one temp file this script made itself (the only non-item removal)
rmtmp() { [ -n "${1:-}" ] || return 0; rm -f -- "$1"; } # RM-OK:backups-tmp-file

SHA1_TOOL=""
probe_sha1() {
  [ -z "$SHA1_TOOL" ] || return 0
  local t
  for t in shasum sha1sum openssl; do
    case "$t" in
      shasum) command -v shasum >/dev/null 2>&1 || continue; [ "$(printf abc | shasum -a 1 2>/dev/null | cut -d' ' -f1)" = "a9993e364706816aba3e25717850c26c9cd0d89d" ] && { SHA1_TOOL=shasum; return 0; } ;;
      sha1sum) command -v sha1sum >/dev/null 2>&1 || continue; [ "$(printf abc | sha1sum 2>/dev/null | cut -d' ' -f1)" = "a9993e364706816aba3e25717850c26c9cd0d89d" ] && { SHA1_TOOL=sha1sum; return 0; } ;;
      openssl) command -v openssl >/dev/null 2>&1 || continue; [ "$(printf abc | openssl sha1 2>/dev/null | awk '{print $NF}')" = "a9993e364706816aba3e25717850c26c9cd0d89d" ] && { SHA1_TOOL=openssl; return 0; } ;;
    esac
  done
  return 1
}
# blob_id <file> — git blob id, same formula as the installer's claude_blob_id
blob_id() {
  local f="$1" sz o
  [ -f "$f" ] || return 1
  probe_sha1 || return 1
  sz=$(LC_ALL=C wc -c < "$f" | tr -d ' ') || return 1
  case "$SHA1_TOOL" in
    shasum) o="$({ printf 'blob %s\0' "$sz"; cat -- "$f"; } | shasum -a 1)"; printf '%s' "${o%% *}" ;;
    sha1sum) o="$({ printf 'blob %s\0' "$sz"; cat -- "$f"; } | sha1sum)"; printf '%s' "${o%% *}" ;;
    openssl) o="$({ printf 'blob %s\0' "$sz"; cat -- "$f"; } | openssl sha1)"; printf '%s' "${o##* }" ;;
  esac
}
file_cksum() { cksum < "$1" 2>/dev/null | cut -d' ' -f1; }
size_of() { LC_ALL=C wc -c < "$1" 2>/dev/null | tr -d ' '; }
# sum of the sizes of regular files under <dir> (exact)
bytes_of_dir() {
  local s=0 n rest
  while read -r n rest; do
    case "$n" in ''|*[!0-9]*) continue ;; esac
    s=$((s + n))
  done <<< "$(find "$1" -type f -exec wc -c {} + 2>/dev/null | { grep -v ' total$' || true; })"
  printf '%s' "$s"
}
human_kb() { printf '%s KB' "$(( ($1 + 1023) / 1024 ))"; }
# kv_get <file> <key> — value of the first "key<TAB>value" line
kv_get() {
  local _k _v
  [ -f "$1" ] || return 1
  while IFS="$TAB" read -r _k _v; do
    if [ "$_k" = "$2" ]; then printf '%s' "$_v"; return 0; fi
  done < "$1"
  return 1
}
is_num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac; }
# append one line to a file this script owns; a symlink is never written through
append_line() {
  if [ -L "$1" ]; then warn "refused: $1 is a symlink"; return 1; fi
  printf '%s\n' "$2" >> "$1"
}

# ---------------------------------------------------------------- anchors (section 4.7)
# anchor <expected physical path> — rc 0 only when pwd -P of the dir EQUALS the string
anchor() {
  local p="$1" got
  got="$(cd "$p" 2>/dev/null && pwd -P)" || { warn "refused: $p (not a directory)"; return 1; }
  if [ "$got" != "$p" ]; then warn "refused: $p resolves to $got"; return 1; fi
  return 0
}
anchor_quiet() {
  local got
  got="$(cd "$1" 2>/dev/null && pwd -P)" || return 1
  [ "$got" = "$1" ]
}
# mkdir_at <anchored parent> <plain name> — make the dir one level under an anchored parent when missing, anchor it
mkdir_at() {
  local parent="$1" name="$2" d
  case "$name" in ''|.|..|*/*) warn "refused: bad directory name '$name'"; return 1 ;; esac
  anchor "$parent" || return 1
  d="$parent/$name"
  if [ -L "$d" ]; then warn "refused: $d is a symlink"; return 1; fi
  if [ ! -e "$d" ]; then
    mkdir "$d" || { warn "cannot create $d"; return 1; }
    chmod 700 "$d" 2>/dev/null || true
  fi
  anchor "$d"
}

ROOT_PHYS=""
PROJECT_PHYS=""
GROUP=""
GROUP_DIR=""
HOLD=""
resolve_root() {
  local r="${TAD_BACKUP_ROOT:-${HOME:-}/.tad-backups}"
  [ -n "$r" ] || return 1
  ROOT_PHYS="$(cd "$r" 2>/dev/null && pwd -P)" || return 1
  [ -n "$ROOT_PHYS" ] && [ "$ROOT_PHYS" != "/" ]
}
resolve_project() {
  PROJECT_PHYS="$(cd "${1:-.}" 2>/dev/null && pwd -P)" || die "cannot resolve the project directory: ${1:-.}"
}
# physical path of <path> built from its parent's physical path (the entry itself is not followed)
phys_entry() {
  local d b p
  d="$(dirname "$1")"; b="$(basename "$1")"
  p="$(cd "$d" 2>/dev/null && pwd -P)" || return 1
  printf '%s/%s' "$p" "$b"
}

# holding_ok <group dir> — quiet: holding/ is a real dir, its marker a regular file naming this project
holding_ok() {
  local h="$1/holding"
  [ -L "$h" ] && return 1
  [ -d "$h" ] || return 1
  anchor_quiet "$h" || return 1
  [ -f "$h/.tad-holding" ] && [ ! -L "$h/.tad-holding" ] || return 1
  [ "$(head -n 1 "$h/.tad-holding" 2>/dev/null)" = "$PROJECT_PHYS" ]
}
# find_group — the one direct child of the backup root that passes the holding anchor for this project
find_group() {
  local d name n=0 names=""
  GROUP=""; GROUP_DIR=""; HOLD=""
  resolve_root || { echo "No holding area for this project"; return 1; }
  for d in "$ROOT_PHYS"/*/; do
    [ -d "$d" ] || continue
    name="${d%/}"; name="${name##*/}"
    if holding_ok "$ROOT_PHYS/$name"; then
      n=$((n + 1)); names="$names $name"
      GROUP="$name"
    fi
  done
  if [ "$n" -eq 0 ]; then GROUP=""; echo "No holding area for this project"; return 1; fi
  if [ "$n" -gt 1 ]; then GROUP=""; warn "refused: more than one backup group names this project:$names"; return 1; fi
  GROUP_DIR="$ROOT_PHYS/$GROUP"
  HOLD="$GROUP_DIR/holding"
  return 0
}

# ---------------------------------------------------------------- ledger and classification
LEDGER_FILE=""
LEDGER_OK=0
LEDGER_ID="unknown"
load_ledger() {
  LEDGER_OK=0; LEDGER_FILE=""; LEDGER_ID="unknown"
  local f="${1:-}" side hdr n rows want have
  [ -n "$f" ] && [ -f "$f" ] && [ ! -L "$f" ] || return 0
  side="${f%.tsv}.sha1"
  [ -f "$side" ] || return 0
  hdr="$(head -n 1 "$f" 2>/dev/null)"
  n="$(printf '%s' "$hdr" | sed -n 's/^# schema=1 rows=\([0-9][0-9]*\)$/\1/p')"
  [ -n "$n" ] || return 0
  rows="$(grep -vc '^#' "$f" 2>/dev/null | tr -d ' ')"
  [ "$n" = "$rows" ] || return 0
  want="$(tr -d ' \t\r\n' < "$side")"
  have="$(blob_id "$f" 2>/dev/null)" || return 0
  [ -n "$have" ] && [ "$have" = "$want" ] || return 0
  LEDGER_FILE="$f"; LEDGER_OK=1; LEDGER_ID="$have"
}
# ledger_label <blob id> — the row's label, rc 1 when no row
ledger_label() {
  local l
  [ "$LEDGER_OK" = "1" ] || return 1
  l="$(grep -F -e "$1$TAB" "$LEDGER_FILE" 2>/dev/null | head -n 1 | cut -f2-)"
  [ -n "$l" ] || return 1
  printf '%s' "$l"
}
# The backup index files that sit at the top of a backup dir, and the two TAD report names
is_index_name() {
  case "$1" in
    manifest.txt|origin.txt|pre-top.txt|pre-tree.txt|pre-surface.tsv|changes.tsv|update-report.tsv|not-backed-up.txt|classes.tsv|MIGRATION-REPORT.tsv|removed.txt) return 0 ;;
  esac
  return 1
}
# classify_one <backup file> <project-relative path> <path relative to the backup dir top, or empty>
# prints "<class><TAB><label>"
classify_one() {
  local file="$1" rel="$2" top="$3" id lab pf sb sp bad=0
  if [ -L "$file" ]; then
    if [ "$LEDGER_OK" = "1" ]; then printf 'differs\t-\n'; else printf 'unknown\t-\n'; fi
    return 0
  fi
  id=""
  if [ "$LEDGER_OK" = "1" ]; then
    id="$(blob_id "$file" 2>/dev/null)" || id=""
    if [ -n "$id" ] && lab="$(ledger_label "$id")"; then printf 'released\t%s\n' "$lab"; return 0; fi
  fi
  if [ -n "$top" ]; then
    case "$top" in
      */*) case "$top" in salvage-diff/*) printf 'tad-report\t-\n'; return 0 ;; esac ;;
      *) if is_index_name "$top"; then printf 'tad-report\t-\n'; return 0; fi ;;
    esac
  fi
  case "$rel" in
    .tad/brain-index.md) printf 'regenerated\t-\n'; return 0 ;;
    .agents/skills/*/.tad-pack-meta.yaml)
      sb="${rel#.agents/skills/}"
      case "${sb%/.tad-pack-meta.yaml}" in */*) ;; *) printf 'regenerated\t-\n'; return 0 ;; esac ;;
  esac
  pf="$PROJECT_PHYS/$rel"
  if [ -f "$pf" ] && [ ! -L "$pf" ]; then
    sb="$(size_of "$file")"; sp="$(size_of "$pf")"
    if is_num "$sb" && is_num "$sp" && [ "$sp" -ge "$sb" ]; then
      if head -c "$sb" "$pf" 2>/dev/null | cmp -s - "$file"; then printf 'in-project\t-\n'; return 0; fi
    fi
    if [ "$LEDGER_OK" = "1" ] && [ -s "$pf" ]; then
      id="$(blob_id "$pf" 2>/dev/null)" || id=""
      if [ -n "$id" ] && lab="$(ledger_label "$id")"; then printf 'edited\t%s\n' "$lab"; return 0; fi
    fi
  fi
  if [ "$LEDGER_OK" = "1" ]; then printf 'differs\t-\n'; else printf 'unknown\t-\n'; fi
  return 0
}
# logical_paths <kind> <path inside payload or backup> -> sets LP_REL and LP_TOP
LP_REL=""; LP_TOP=""
logical_paths() {
  local kind="$1" pic="$2"
  case "$kind" in
    pre-tad) LP_REL="${pic%%.pre-tad.*}"; LP_TOP="" ;;
    run) LP_REL="$pic"; LP_TOP="$pic" ;;
    *) case "$pic" in */*) LP_REL="${pic#*/}"; LP_TOP="$LP_REL" ;; *) LP_REL="$pic"; LP_TOP="" ;; esac ;;
  esac
}

# write_rows <dir whose files are classified> <kind> <out file> — classes rows; prints the file count
# (every regular file and link; a path holding a newline or TAB is counted, not listed)
write_rows() {
  local base="$1" kind="$2" out="$3" f pic cl lab total=0 weird=0 lst
  : > "$out" || return 1
  lst="$(mktemp "${TMPDIR:-/tmp}/tad-bk-list.XXXXXX")" || return 1
  find "$base" \( -type f -o -type l \) ! -path "*${NL}*" ! -path "*${TAB}*" -print 2>/dev/null | LC_ALL=C sort > "$lst"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    pic="${f#"$base"/}"
    case "$pic" in classes.tsv) [ "$kind" = "run" ] && continue ;; esac
    logical_paths "$kind" "$pic"
    IFS="$TAB" read -r cl lab <<< "$(classify_one "$f" "$LP_REL" "$LP_TOP")"
    printf '%s\t%s\t%s\n' "$cl" "${lab:--}" "$pic" >> "$out"
    total=$((total + 1))
  done < "$lst"
  rmtmp "$lst"
  weird="$(find "$base" \( -type f -o -type l \) \( -path "*${NL}*" -o -path "*${TAB}*" \) -print 2>/dev/null | wc -l | tr -d ' ')"
  [ -z "$weird" ] || total=$((total + weird))
  printf '%s' "$total"
}

# ---------------------------------------------------------------- holding items
# item_line <id> <mode: set|any> — "<id> <bytes> <cksum of classes.tsv>" when the item is a member of the mode's set
ABS_LIST=""
load_absorbed() {
  ABS_LIST=""
  local a b c
  if [ -f "$HOLD/absorbed.tsv" ] && [ ! -L "$HOLD/absorbed.tsv" ]; then
    while IFS="$TAB" read -r a b c; do
      [ -n "$b" ] && ABS_LIST="$ABS_LIST$NL$b"
    done < "$HOLD/absorbed.tsv"
  fi
  ABS_LIST="$ABS_LIST$NL"
}
item_line() {
  local id="$1" mode="$2" it last files bytes proj cl lab p allowed=0 total sc
  it="$HOLD/$id"
  printf '%s' "$id" | grep -Eq "$IDRE" || return 1
  anchor_quiet "$it" || return 1
  [ -f "$it/item.tsv" ] && [ ! -L "$it/item.tsv" ] || return 1
  last="$(tail -n 1 "$it/item.tsv" | cut -f1)"
  [ "$last" = "classified" ] || return 1
  proj="$(kv_get "$it/item.tsv" project)" || return 1
  [ "$proj" = "$PROJECT_PHYS" ] || return 1
  files="$(kv_get "$it/item.tsv" files)" || return 1
  bytes="$(kv_get "$it/item.tsv" bytes)" || return 1
  is_num "$files" && is_num "$bytes" || return 1
  [ -f "$it/classes.tsv" ] && [ ! -L "$it/classes.tsv" ] || return 1
  sc="$(file_cksum "$it/classes.tsv")"
  if [ "$mode" = "any" ]; then printf '%s %s %s' "$id" "$bytes" "$sc"; return 0; fi
  while IFS="$TAB" read -r cl lab p; do
    case "$cl" in
      released|tad-report|regenerated|in-project) allowed=$((allowed + 1)) ;;
      edited) case "$ABS_LIST" in *"$NL$it/payload/$p$NL"*) allowed=$((allowed + 1)) ;; esac ;;
    esac
  done < "$it/classes.tsv"
  [ "$allowed" = "$files" ] || return 1
  printf '%s %s %s' "$id" "$bytes" "$sc"
}
item_ids() { # sorted item ids that match the id pattern (no anchoring: callers anchor per item)
  local d name
  for d in "$HOLD"/*/; do
    [ -d "$d" ] || continue
    name="${d%/}"; name="${name##*/}"
    printf '%s' "$name" | grep -Eq "$IDRE" || continue
    printf '%s\n' "$name"
  done | LC_ALL=C sort
}
CLEAR_LINES=""; CLEAR_N=0; CLEAR_BYTES=0; REVIEW_IDS=""; REVIEW_N=0; TOKEN=""
clearable_set() {
  local id ln b
  CLEAR_LINES=""; CLEAR_N=0; CLEAR_BYTES=0; REVIEW_IDS=""; REVIEW_N=0
  load_absorbed
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    if ln="$(item_line "$id" set)"; then
      CLEAR_LINES="${CLEAR_LINES:+$CLEAR_LINES$NL}$ln"
      CLEAR_N=$((CLEAR_N + 1))
      b="$(printf '%s' "$ln" | cut -d' ' -f2)"
      CLEAR_BYTES=$((CLEAR_BYTES + b))
    else
      REVIEW_IDS="${REVIEW_IDS:+$REVIEW_IDS$NL}$id"
      REVIEW_N=$((REVIEW_N + 1))
    fi
  done <<< "$(item_ids)"
  TOKEN="$(token_of "$CLEAR_LINES")"
}
token_of() { printf '%s\n' "$1" | LC_ALL=C sort | cksum | cut -d' ' -f1; }

# ---------------------------------------------------------------- holding: create, hold, classify
ensure_holding() { # needs GROUP_DIR (anchored) and PROJECT_PHYS
  local t
  mkdir_at "$GROUP_DIR" holding || return 1
  HOLD="$GROUP_DIR/holding"
  if [ -L "$HOLD/.tad-holding" ]; then warn "refused: $HOLD/.tad-holding is a symlink"; return 1; fi
  if [ "$(head -n 1 "$HOLD/.tad-holding" 2>/dev/null)" != "$PROJECT_PHYS" ]; then
    t="$(mktemp "$HOLD/.marker.XXXXXX")" || return 1
    printf '%s\n' "$PROJECT_PHYS" > "$t" && mv -f "$t" "$HOLD/.tad-holding" || { rmtmp "$t"; return 1; }
  fi
  return 0
}
alloc_item() { # creates $HOLD/<id> (a plain mkdir: an existing entry is never reused) and prints the id
  local base id n=0
  base="h$(date +%Y%m%d-%H%M%S)"; id="$base"
  while ! mkdir "$HOLD/$id" 2>/dev/null; do
    n=$((n + 1))
    [ "$n" -le 99 ] || return 1
    id="$base.$n"
  done
  chmod 700 "$HOLD/$id" 2>/dev/null || true
  anchor_quiet "$HOLD/$id" || return 1
  printf '%s' "$id"
}
HELD_N=0; HELD_TRACKED=0
CLASSIFIED_N=0
# hold_move <kind> <anchored parent dir> <entry name> <path relative to the project root, for the git count>
hold_move() {
  local kind="$1" sp="$2" name="$3" prel="$4" src id it tr=0
  anchor "$sp" || return 1
  src="$sp/$name"
  if [ -L "$src" ]; then warn "refused: $src is a symlink"; return 1; fi
  [ -e "$src" ] || return 1
  id="$(alloc_item)" || { warn "cannot create a holding item"; return 1; }
  it="$HOLD/$id"
  printf 'kind\t%s\norigin\t%s\nproject\t%s\nheld\t%s\n' "$kind" "$src" "$PROJECT_PHYS" "$(date +%Y-%m-%d)" > "$it/item.tsv" || return 1
  mkdir_at "$it" payload || return 1
  if [ -n "$prel" ] && command -v git >/dev/null 2>&1 && git -C "$PROJECT_PHYS" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    tr="$(git -C "$PROJECT_PHYS" ls-files -- "$prel" 2>/dev/null | wc -l | tr -d ' ')"
    is_num "$tr" || tr=0
  fi
  if mv "$src" "$it/payload/$name"; then
    HELD_N=$((HELD_N + 1)); HELD_TRACKED=$((HELD_TRACKED + tr))
  else
    warn "could not move $src into the holding area; it stays where it is"
    return 1
  fi
  return 0
}
ver_key() { # X.Y.Z -> zero-padded sortable key
  local v="$1" a b c
  IFS=. read -r a b c <<< "$v"
  printf '%06d%06d%06d' "$((10#${a:-0}))" "$((10#${b:-0}))" "$((10#${c:-0}))"
}
hold_tad_backup_dirs() { # D7 (a)
  local tb="$PROJECT_PHYS/.tad-backup" d name to keys="" k1 k2 re
  [ -e "$tb" ] || [ -L "$tb" ] || return 0
  anchor "$tb" || return 0
  re='^[0-9]+\.[0-9]+\.[0-9]+-to-([0-9]+\.[0-9]+\.[0-9]+)(-deprecations)?$'
  for d in "$tb"/*/; do
    [ -d "$d" ] || continue
    name="${d%/}"; name="${name##*/}"
    [[ "$name" =~ $re ]] || continue
    keys="$keys$(ver_key "${BASH_REMATCH[1]}")$NL"
  done
  keys="$(printf '%s' "$keys" | LC_ALL=C sort -u | LC_ALL=C sort -r)"
  k1="$(printf '%s\n' "$keys" | sed -n 1p)"; k2="$(printf '%s\n' "$keys" | sed -n 2p)"
  for d in "$tb"/*/; do
    [ -d "$d" ] || continue
    name="${d%/}"; name="${name##*/}"
    [[ "$name" =~ $re ]] || continue
    to="$(ver_key "${BASH_REMATCH[1]}")"
    if [ "$to" = "$k1" ] || [ "$to" = "$k2" ]; then continue; fi
    hold_move tad-backup "$tb" "$name" ".tad-backup/$name" || true
  done
}
hold_pre_tad_files() { # D7 (b)
  local f name lst cur="" n=0 base key re='^(.+)\.pre-tad\.([0-9]{8}-[0-9]{6})(\.([0-9]+))?$' sfx
  lst="$(mktemp "${TMPDIR:-/tmp}/tad-bk-pre.XXXXXX")" || return 0
  for f in "$PROJECT_PHYS"/*.pre-tad.*; do
    [ -f "$f" ] && [ ! -L "$f" ] || continue
    name="${f##*/}"
    [[ "$name" =~ $re ]] || continue
    sfx="${BASH_REMATCH[4]:-0}"
    printf '%s\t%s%012d\t%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "$((10#$sfx))" "$name" >> "$lst"
  done
  LC_ALL=C sort -t "$TAB" -k1,1 -k2,2r "$lst" > "$lst.s"
  while IFS="$TAB" read -r base key name; do
    if [ "$base" != "$cur" ]; then cur="$base"; n=0; fi
    n=$((n + 1))
    [ "$n" -gt 2 ] || continue
    hold_move pre-tad "$PROJECT_PHYS" "$name" "$name" || true
  done < "$lst.s"
  rmtmp "$lst"; rmtmp "$lst.s"
}
hold_legacy_group() { # D7 (d)
  local lg="$1" lgp d name org
  [ -n "$lg" ] || return 0
  lgp="$(phys_entry "$lg")" || return 0
  [ "$(dirname "$lgp")" = "$ROOT_PHYS" ] || { warn "legacy group is not directly under the backup root: refused"; return 0; }
  [ "$lgp" != "$GROUP_DIR" ] || return 0
  anchor "$lgp" || return 0
  for d in "$lgp"/*/; do
    [ -d "$d" ] || continue
    name="${d%/}"; name="${name##*/}"
    printf '%s' "$name" | grep -Eq "$BKRE" || continue
    [ -f "$lgp/$name/manifest.txt" ] && [ -f "$lgp/$name/origin.txt" ] || continue
    org="$(head -n 1 "$lgp/$name/origin.txt" 2>/dev/null)"
    [ "$org" = "$PROJECT_PHYS" ] || continue
    hold_move legacy-backup "$lgp" "$name" "" || true
  done
}
# classify_item <id> — D6/D8: bytes and files from payload/, then classes.tsv, then the classified line last
classify_item() {
  local id="$1" it kind files bytes tmp
  it="$HOLD/$id"
  anchor_quiet "$it" || return 1
  [ -f "$it/item.tsv" ] && [ ! -L "$it/item.tsv" ] || return 1
  [ "$(tail -n 1 "$it/item.tsv" | cut -f1)" != "classified" ] || return 0
  [ "$(kv_get "$it/item.tsv" project)" = "$PROJECT_PHYS" ] || return 1
  kind="$(kv_get "$it/item.tsv" kind)" || return 1
  [ -d "$it/payload" ] && anchor_quiet "$it/payload" || return 1
  tmp="$(mktemp "$it/.classes.XXXXXX")" || return 1
  files="$(write_rows "$it/payload" "$kind" "$tmp")" || { rmtmp "$tmp"; return 1; }
  bytes="$(bytes_of_dir "$it/payload")"
  append_line "$it/item.tsv" "bytes$TAB$bytes" || { rmtmp "$tmp"; return 1; }
  append_line "$it/item.tsv" "files$TAB$files" || { rmtmp "$tmp"; return 1; }
  mv -f "$tmp" "$it/classes.tsv" || { rmtmp "$tmp"; return 1; }
  append_line "$it/item.tsv" "classified${TAB}$LEDGER_ID" || return 1
  CLASSIFIED_N=$((CLASSIFIED_N + 1))
  return 0
}

# ---------------------------------------------------------------- commands
usage() {
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//' >&2
}

A_PROJECT=""; A_GROUPDIR=""; A_RUNBK=""; A_LEDGER=""; A_LEGACY=""; A_ALL=0; A_IDSFILE=""; A_IDSOUT=""
A_ID=""; A_TOKEN=""; A_HOW=""; A_YES=0; A_FROM=""; A_FILES=""
parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --project) A_PROJECT="${2:-}"; shift 2 ;;
      --group-dir) A_GROUPDIR="${2:-}"; shift 2 ;;
      --run-backup) A_RUNBK="${2:-}"; shift 2 ;;
      --ledger) A_LEDGER="${2:-}"; shift 2 ;;
      --legacy-group) A_LEGACY="${2:-}"; shift 2 ;;
      --all) A_ALL=1; shift ;;
      --ids-file) A_IDSFILE="${2:-}"; shift 2 ;;
      --ids-out) A_IDSOUT="${2:-}"; shift 2 ;;
      --id) A_ID="${2:-}"; shift 2 ;;
      --token) A_TOKEN="${2:-}"; shift 2 ;;
      --how) A_HOW="${2:-}"; shift 2 ;;
      --yes) A_YES=1; shift ;;
      --from) A_FROM="${2:-}"; shift 2 ;;
      --) shift; while [ $# -gt 0 ]; do A_FILES="$A_FILES$1$NL"; shift; done ;;
      -*) die "unknown option '$1'" ;;
      *) A_FILES="$A_FILES$1$NL"; shift ;;
    esac
  done
}

cmd_classify() {
  local p rel top rest
  resolve_project "$A_PROJECT"
  load_ledger "$A_LEDGER"
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    rel="${p#./}"; top=""
    case "$rel" in
      */.tad-backup/*) rel=".tad-backup/${rel#*.tad-backup/}" ;;
    esac
    case "$rel" in
      .tad-backup/*/*) rest="${rel#.tad-backup/}"; rest="${rest#*/}"; rel="$rest"; top="$rest" ;;
      *.pre-tad.[0-9]*) rel="${rel%%.pre-tad.*}" ;;
      [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]/*) rest="${rel#*/}"; rel="$rest"; top="$rest" ;;
    esac
    IFS="$TAB" read -r cl lab <<< "$(classify_one "$p" "$rel" "$top")"
    printf '%s\t%s\t%s\n' "$cl" "${lab:--}" "$p"
  done <<< "$A_FILES"
}

cmd_lifecycle() {
  local gp rbp rb moved review items bytes id rows cnt=0 b ln
  [ -n "$A_GROUPDIR" ] && [ -n "$A_RUNBK" ] || die "lifecycle needs --group-dir and --run-backup"
  resolve_project "$A_PROJECT"
  resolve_root || { warn "backup root cannot be resolved; lifecycle skipped"; return 0; }
  load_ledger "$A_LEDGER"
  gp="$(phys_entry "$A_GROUPDIR")" || { warn "group dir cannot be resolved; lifecycle skipped"; return 0; }
  if [ "$(dirname "$gp")" != "$ROOT_PHYS" ]; then warn "refused: group dir is not directly under the backup root"; return 0; fi
  anchor "$gp" || return 0
  GROUP_DIR="$gp"; GROUP="${gp##*/}"
  ensure_holding || { warn "holding area not available; lifecycle skipped"; return 0; }
  # the run's own backup: classes.tsv (anchor <root_phys>/<group>/<ts>)
  rbp="$(phys_entry "$A_RUNBK")" || rbp=""
  if [ -n "$rbp" ] && [ "$(dirname "$rbp")" = "$GROUP_DIR" ] && anchor "$rbp"; then
    rb="$(mktemp "$GROUP_DIR/.classes.XXXXXX")" || rb=""
    if [ -n "$rb" ]; then
      if write_rows "$rbp" run "$rb" >/dev/null; then mv -f "$rb" "$rbp/classes.tsv" || rmtmp "$rb"; else rmtmp "$rb"; fi
    fi
  else
    warn "run backup not anchored under the group; its classes were not stored"
  fi
  hold_tad_backup_dirs
  hold_pre_tad_files
  hold_legacy_group "$A_LEGACY"
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    classify_item "$id" || true
  done <<< "$(item_ids)"
  clearable_set
  items="$(item_ids | grep -c . || true)"
  bytes=0
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    if ln="$(item_line "$id" any)"; then b="$(printf '%s' "$ln" | cut -d' ' -f2)"; bytes=$((bytes + b)); fi
  done <<< "$(item_ids)"
  moved="$CLASSIFIED_N"
  [ "$HELD_N" -le "$moved" ] || moved="$HELD_N"
  printf 'holding_path%s%s\n' "$TAB" "$HOLD"
  printf 'holding_items%s%s\n' "$TAB" "$(printf '%s' "$items" | tr -d ' ')"
  printf 'holding_bytes%s%s\n' "$TAB" "$bytes"
  printf 'holding_moved%s%s\n' "$TAB" "$moved"
  printf 'holding_review%s%s\n' "$TAB" "$REVIEW_N"
  printf 'holding_git_tracked%s%s\n' "$TAB" "$HELD_TRACKED"
  printf 'holding_held%s%s\n' "$TAB" "$HELD_N"
  return 0
}

class_summary() { # <classes.tsv>
  cut -f1 "$1" 2>/dev/null | LC_ALL=C sort | LC_ALL=C uniq -c | sed 's/^ *\([0-9][0-9]*\) \(.*\)$/\2 \1/' | tr '\n' ',' | sed 's/,$//; s/,/, /g'
}
foreign_summary() {
  local d name o orphans=0 unknown=0 osize=0 others=0 names="" f has alive b
  for d in "$ROOT_PHYS"/*; do
    [ -e "$d" ] || [ -L "$d" ] || continue
    name="${d##*/}"
    if [ -d "$d" ] && [ ! -L "$d" ]; then
      [ "$name" != "$GROUP" ] || continue
      has=0; alive=0
      for f in "$d"/*/origin.txt; do
        [ -f "$f" ] || continue
        [ -f "$(dirname "$f")/manifest.txt" ] || continue
        has=1
        o="$(head -n 1 "$f" 2>/dev/null)"
        if [ -n "$o" ] && [ -e "$o" ]; then alive=1; fi
      done
      if [ "$has" = "0" ]; then unknown=$((unknown + 1))
      elif [ "$alive" = "0" ]; then orphans=$((orphans + 1)); b="$(bytes_of_dir "$d")"; osize=$((osize + b)); fi
    else
      others=$((others + 1))
      if [ "$others" -le 5 ]; then names="${names:+$names, }$name"; fi
    fi
  done
  printf 'Not touched: %s backup groups whose project no longer exists (%s); %s other entries not written by TAD (%s); %s groups with no known owner\n' "$orphans" "$(human_kb "$osize")" "$others" "${names:--}" "$unknown"
}

cmd_list() {
  local id it kind org bytes files rev ln total=0 n=0
  resolve_project "$A_PROJECT"
  find_group || return 1
  clearable_set
  echo "Held backups for $PROJECT_PHYS (holding area: $HOLD)"
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    it="$HOLD/$id"
    anchor_quiet "$it" || { echo "  $id  (refused: not a real directory)"; continue; }
    kind="$(kv_get "$it/item.tsv" kind || echo '?')"
    org="$(kv_get "$it/item.tsv" origin || echo '?')"
    bytes="$(kv_get "$it/item.tsv" bytes || echo 0)"
    files="$(kv_get "$it/item.tsv" files || echo '?')"
    rev=""
    case "$NL$REVIEW_IDS$NL" in *"$NL$id$NL"*) rev="  [held for review]" ;; esac
    if [ -f "$it/classes.tsv" ]; then ln="$(class_summary "$it/classes.tsv")"; else ln="not classified"; fi
    echo "  $id  $kind  $org  $(human_kb "${bytes:-0}")  ${files} files  ${ln:--}$rev"
    is_num "$bytes" && total=$((total + bytes))
    n=$((n + 1))
  done <<< "$(item_ids)"
  echo "Total: $n held items ($(human_kb "$total"))"
  echo "Will clear: $CLEAR_N ($(human_kb "$CLEAR_BYTES")); held for review: $REVIEW_N"
  foreign_summary
  if [ "$CLEAR_N" -gt 0 ]; then
    echo "To clear: /bin/bash .tad/scripts/tad-backups.sh clear --all --token $TOKEN --yes"
  else
    echo "Nothing is cleared by a yes: no held item is proven to be TAD's own files, its reports, or copies already absorbed."
  fi
  if [ "$REVIEW_N" -gt 0 ]; then echo "Review items are never cleared by --all: say \"看备份\" to see them."; fi
  return 0
}

cmd_clearable() {
  resolve_project "$A_PROJECT"
  if ! find_group >/dev/null 2>&1; then
    printf 'clear_n%s0\nclear_bytes%s0\nreview_n%s0\ntoken%s-\n' "$TAB" "$TAB" "$TAB" "$TAB"
    return 0
  fi
  clearable_set
  if [ -n "$A_TOKEN" ]; then
    if [ "$A_TOKEN" != "$TOKEN" ]; then echo "mismatch"; return 1; fi
    if [ -n "$A_IDSOUT" ]; then
      if [ -L "$A_IDSOUT" ]; then warn "refused: $A_IDSOUT is a symlink"; return 1; fi
      printf '%s\n' "$CLEAR_LINES" > "$A_IDSOUT" || return 1
    fi
    echo "ok"
    return 0
  fi
  printf 'clear_n%s%s\nclear_bytes%s%s\nreview_n%s%s\ntoken%s%s\n' "$TAB" "$CLEAR_N" "$TAB" "$CLEAR_BYTES" "$TAB" "$REVIEW_N" "$TAB" "$TOKEN"
  return 0
}

# clear_item <id> <expected line> <how> <mode: set|any>
CLEARED_N=0; SKIPPED_N=0
clear_item() {
  local id="$1" want="$2" how="$3" mode="$4" it cur origin bytes files
  it="$HOLD/$id"
  printf '%s' "$id" | grep -Eq "$IDRE" || { warn "skipped $id: not an item id"; SKIPPED_N=$((SKIPPED_N + 1)); return 0; }
  anchor "$it" || { SKIPPED_N=$((SKIPPED_N + 1)); return 0; }
  cur="$(item_line "$id" "$mode")" || { warn "skipped $id: no longer in the set that was listed"; SKIPPED_N=$((SKIPPED_N + 1)); return 0; }
  if [ "$cur" != "$want" ]; then warn "skipped $id: changed since it was listed"; SKIPPED_N=$((SKIPPED_N + 1)); return 0; fi
  origin="$(kv_get "$it/item.tsv" origin || echo '?')"
  bytes="$(kv_get "$it/item.tsv" bytes || echo 0)"
  files="$(kv_get "$it/item.tsv" files || echo 0)"
  if rm -rf -- "$it"; then # RM-OK:backups-clear-item
    CLEARED_N=$((CLEARED_N + 1))
    append_line "$HOLD/deletions.log" "$(date +%Y-%m-%dT%H:%M:%S)$TAB$id$TAB$origin$TAB$bytes$TAB$files$TAB$how" || warn "deletions.log not written for $id"
    echo "Cleared $id ($origin, $(human_kb "$bytes"))"
  else
    warn "could not remove $it"
    SKIPPED_N=$((SKIPPED_N + 1))
  fi
}
cmd_clear() {
  local ln id how
  resolve_project "$A_PROJECT"
  find_group || return 1
  if [ "$A_ALL" = "1" ]; then
    [ -n "$A_TOKEN" ] || die "clear --all needs --token (run list first)"
    clearable_set
    if [ "$A_TOKEN" != "$TOKEN" ]; then echo "Held backups changed since the list: nothing cleared"; return 3; fi
    how="${A_HOW:-清掉}"
    if [ "$A_YES" != "1" ]; then echo "No --yes: nothing deleted ($CLEAR_N items would be cleared)"; return 0; fi
    while IFS= read -r ln; do
      [ -n "$ln" ] || continue
      id="${ln%% *}"
      clear_item "$id" "$ln" "$how" set
    done <<< "$CLEAR_LINES"
  elif [ -n "$A_IDSFILE" ]; then
    how="${A_HOW:-upgrade}"
    [ -f "$A_IDSFILE" ] || die "ids file not found: $A_IDSFILE"
    if [ "$A_YES" != "1" ]; then echo "No --yes: nothing deleted"; return 0; fi
    clearable_set
    while IFS= read -r ln; do
      [ -n "$ln" ] || continue
      id="${ln%% *}"
      clear_item "$id" "$ln" "$how" set
    done < "$A_IDSFILE"
  elif [ -n "$A_ID" ]; then
    [ -n "$A_TOKEN" ] || die "clear --id needs --token (the To discard line of salvage)"
    load_absorbed
    ln="$(item_line "$A_ID" any)" || { echo "Held item $A_ID is not available for discard (unclassified or not this project's)"; return 1; }
    if [ "$(token_of "$ln")" != "$A_TOKEN" ]; then echo "Held item $A_ID changed since it was listed: nothing cleared"; return 3; fi
    if [ "$A_YES" != "1" ]; then echo "No --yes: nothing deleted"; return 0; fi
    clear_item "$A_ID" "$ln" "${A_HOW:-discard}" any
  else
    die "clear needs --all --token <t>, --ids-file <f>, or --id <id> --token <t>"
  fi
  echo "Cleared: $CLEARED_N; skipped: $SKIPPED_N"
  [ "$SKIPPED_N" -eq 0 ]
}

# ---- salvage
# write_diff <container dir (anchored)> <flat name> <project file> <backup file> — prints "<a> <r> <diff path>" or fails
write_diff() {
  local cdir="$1" flat="$2" pf="$3" bf="$4" sd tmp dest a r
  mkdir_at "$cdir" salvage-diff || return 1
  sd="$cdir/salvage-diff"
  dest="$sd/$flat.diff"
  if [ -d "$dest" ]; then warn "refused: $dest is a directory"; return 1; fi
  tmp="$(mktemp "$sd/.diff.XXXXXX")" || return 1
  LC_ALL=C diff -u "$pf" "$bf" > "$tmp" 2>/dev/null
  a="$(grep -c '^+' "$tmp" 2>/dev/null || true)"; r="$(grep -c '^-' "$tmp" 2>/dev/null || true)"
  a=$((${a:-0} - 1)); r=$((${r:-0} - 1))
  [ "$a" -ge 0 ] || a=0
  [ "$r" -ge 0 ] || r=0
  mv -f "$tmp" "$dest" || { rmtmp "$tmp"; return 1; }
  printf '%s %s %s' "$a" "$r" "$dest"
}
flat_name() { printf '%s' "$1" | sed 's|/|__|g'; }
# salvage_container <label> <container dir> <classes.tsv> <kind> <payload base> <is item 0|1> <item id>
salvage_container() {
  local label="$1" cdir="$2" cls="$3" kind="$4" pbase="$5" isitem="$6" id="$7"
  local cl lab p abs rel flat pf out a r dpath sz shown=0 ln
  [ -f "$cls" ] && [ ! -L "$cls" ] || return 0
  while IFS="$TAB" read -r cl lab p; do
    case "$cl" in edited|differs|unknown) ;; *) continue ;; esac
    abs="$pbase/$p"
    case "$ABS_LIST" in *"$NL$abs$NL"*) continue ;; esac
    if [ "$shown" = "0" ]; then echo "$label"; shown=1; fi
    logical_paths "$kind" "$p"; rel="$LP_REL"; flat="$(flat_name "$rel")"
    pf="$PROJECT_PHYS/$rel"
    if [ "$cl" = "edited" ] && [ -f "$pf" ] && [ ! -L "$pf" ] && [ -f "$abs" ] && [ ! -L "$abs" ]; then
      if out="$(write_diff "$cdir" "$flat" "$pf" "$abs")"; then
        a="${out%% *}"; r="${out#* }"; r="${r%% *}"; dpath="${out#* * }"
        echo "  $rel (edited $lab): +$a -$r lines; diff: $dpath (open it yourself)"
        echo "    destination: .tad/project-knowledge/salvage/$(date +%Y%m%d)-$flat"
        echo "    To absorb: /bin/bash .tad/scripts/tad-backups.sh absorb --from $abs --yes"
      else
        echo "  $rel (edited $lab): diff not written: $cdir refused"
      fi
    else
      sz="$(size_of "$abs")"
      echo "  $rel (${sz:-?} B, $cl): no released TAD file to compare with at this path — not shown, not absorbable; open it yourself: $abs"
    fi
  done < "$cls"
  if [ "$shown" = "1" ] && [ "$isitem" = "1" ]; then
    ln="$(item_line "$id" any 2>/dev/null)" || ln=""
    if [ -n "$ln" ]; then echo "  To discard: /bin/bash .tad/scripts/tad-backups.sh clear --id $id --token $(token_of "$ln") --yes"; fi
  fi
  return 0
}
cmd_salvage() {
  local id it kind org d name any=0
  resolve_project "$A_PROJECT"
  find_group || return 1
  load_absorbed
  echo "Files the project edited or added inside TAD files (no file content is shown; diffs are written to local files):"
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    it="$HOLD/$id"
    anchor_quiet "$it" || continue
    kind="$(kv_get "$it/item.tsv" kind || echo '')"
    org="$(kv_get "$it/item.tsv" origin || echo '?')"
    [ "$(tail -n 1 "$it/item.tsv" 2>/dev/null | cut -f1)" = "classified" ] || { echo "Held $id ($org): not classified yet; it stays held until the next update classifies it"; continue; }
    salvage_container "Held $id ($org)" "$it" "$it/classes.tsv" "$kind" "$it/payload" 1 "$id"
  done <<< "$(item_ids)"
  for d in "$GROUP_DIR"/*/; do
    [ -d "$d" ] || continue
    name="${d%/}"; name="${name##*/}"
    printf '%s' "$name" | grep -Eq "$BKRE" || continue
    anchor_quiet "$GROUP_DIR/$name" || continue
    [ -f "$GROUP_DIR/$name/classes.tsv" ] || continue
    salvage_container "Backup $GROUP_DIR/$name" "$GROUP_DIR/$name" "$GROUP_DIR/$name/classes.tsv" run "$GROUP_DIR/$name" 0 ""
  done
  return 0
}

# ---- absorb
cmd_absorb() {
  local abs rest cont id inner pic kind cls cl lab p found=0 pf rel flat tmp dest n=1 salv pk pexp
  [ -n "$A_FROM" ] || die "absorb needs --from <abs path>"
  resolve_project "$A_PROJECT"
  find_group || return 1
  case "$A_FROM" in /*) ;; *) die "--from must be an absolute path" ;; esac
  abs="$(phys_entry "$A_FROM")" || { echo "Refused: $A_FROM cannot be resolved"; return 1; }
  # reached only through this group's holding anchor or this group's backups
  case "$abs" in
    "$HOLD"/*)
      rest="${abs#"$HOLD"/}"; id="${rest%%/*}"; inner="${rest#*/}"
      printf '%s' "$id" | grep -Eq "$IDRE" || { echo "Refused: not a held item path"; return 1; }
      case "$inner" in payload/*) pic="${inner#payload/}" ;; *) echo "Refused: not inside a held item's payload"; return 1 ;; esac
      cont="$HOLD/$id"; anchor "$cont" || return 1
      kind="$(kv_get "$cont/item.tsv" kind || echo '')"
      [ "$(kv_get "$cont/item.tsv" project || echo '')" = "$PROJECT_PHYS" ] || { echo "Refused: item belongs to another project"; return 1; }
      cls="$cont/classes.tsv"
      ;;
    "$GROUP_DIR"/*)
      rest="${abs#"$GROUP_DIR"/}"; id="${rest%%/*}"; pic="${rest#*/}"
      printf '%s' "$id" | grep -Eq "$BKRE" || { echo "Refused: not a backup of this group"; return 1; }
      cont="$GROUP_DIR/$id"; anchor "$cont" || return 1
      kind="run"; cls="$cont/classes.tsv"
      ;;
    *) echo "Refused: $abs is not inside this project's holding area or backups"; return 1 ;;
  esac
  [ "$pic" != "$rest" ] || { echo "Refused: not a file path"; return 1; }
  [ -f "$cls" ] && [ ! -L "$cls" ] || { echo "Refused: no stored classes for this backup"; return 1; }
  while IFS="$TAB" read -r cl lab p; do
    if [ "$p" = "$pic" ] && [ "$cl" = "edited" ]; then found=1; break; fi
  done < "$cls"
  [ "$found" = "1" ] || { echo "Refused: only a file stored as edited (a TAD file the project changed) can be absorbed"; return 1; }
  [ -f "$abs" ] && [ ! -L "$abs" ] || { echo "Refused: $abs is not a regular file"; return 1; }
  # the file's parent must be the real directory under the anchored container (no symlinked subdirectory)
  case "$cont" in
    "$HOLD"/*) pexp="$cont/payload" ;;
    *) pexp="$cont" ;;
  esac
  case "$pic" in */*) pexp="$pexp/$(dirname "$pic")" ;; esac
  anchor "$pexp" || { echo "Refused: $abs is reached through a symlinked directory"; return 1; }
  if [ "$A_YES" != "1" ]; then echo "No --yes: nothing written"; return 0; fi
  logical_paths "$kind" "$pic"; rel="$LP_REL"; flat="$(flat_name "$rel")"
  anchor "$PROJECT_PHYS/.tad" || { echo "Refused: the project's .tad is not a real directory"; return 1; }
  mkdir_at "$PROJECT_PHYS/.tad" project-knowledge || return 1
  pk="$PROJECT_PHYS/.tad/project-knowledge"
  mkdir_at "$pk" salvage || return 1
  salv="$pk/salvage"
  tmp="$(mktemp "$salv/.absorb.XXXXXX")" || return 1
  { printf 'from %s, %s\n' "$abs" "$(date +%Y-%m-%d)"; cat -- "$abs"; } > "$tmp" || { rmtmp "$tmp"; return 1; }
  dest="$salv/$(date +%Y%m%d)-$flat"
  while ! ln -n "$tmp" "$dest" 2>/dev/null; do
    n=$((n + 1))
    if [ "$n" -gt 9 ]; then rmtmp "$tmp"; echo "Refused: no free destination name"; return 1; fi
    dest="$salv/$(date +%Y%m%d)-$flat.$n"
  done
  rmtmp "$tmp"
  append_line "$HOLD/absorbed.tsv" "$(date +%Y-%m-%d)$TAB$abs$TAB$dest" || warn "absorbed.tsv not written"
  echo "Absorbed into ${dest#"$PROJECT_PHYS"/}"
  return 0
}

# ---------------------------------------------------------------- dispatch
CMD="${1:-}"
[ $# -eq 0 ] || shift
case "$CMD" in
  classify|lifecycle|list|clearable|clear|salvage|absorb) parse_args "$@" ;;
  -h|--help|help|'') usage; exit 2 ;;
  *) warn "unknown command '$CMD'"; usage; exit 2 ;;
esac
case "$CMD" in
  classify) cmd_classify ;;
  lifecycle) cmd_lifecycle ;;
  list) cmd_list ;;
  clearable) cmd_clearable ;;
  clear) cmd_clear ;;
  salvage) cmd_salvage ;;
  absorb) cmd_absorb ;;
esac
exit $?
