#!/usr/bin/env bash
# gen-claude-provenance.sh — regenerate the legacy Claude Code install ledger.
#
# TAD repo only (needs git and the full tag set). Walks every commit reachable
# from HEAD and from the v* tags and records the git blob id of every file TAD
# ever shipped to a downstream project under the Claude Code surfaces:
#   skill         .claude/skills/<n>/** and .agents/skills/<n>/**   key = <n>/<relative path>
#   flat          .claude/skills/<f> (file directly in skills/)      key = <f>
#   settings      .claude/settings.json, .tad/templates/claude/settings.json
#   settings-ws   SHA-1 of a settings blob with ' ', TAB, CR, LF removed
#   md-whole      root CLAUDE.md blobs without the marker line
#   md-head       SHA-1 of the head (up to and including the marker line) of CLAUDE.md blobs that have it
#   workflow      .claude/workflows/<f>                              key = <f>
#   cmd           .claude/commands/<f>                               key = <f>
# Output: .tad/provenance/claude-legacy.tsv (+ MANIFEST.sha1). Re-running on the
# same history gives byte-identical files: the header carries no commit hash.
# The head/stripped-hash commands below MUST stay identical to the ones in
# tad.sh (claude_adopt_md_head_n, claude_adopt_settings_ws_id).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
OUT_DIR="$ROOT/.tad/provenance"
LEDGER="$OUT_DIR/claude-legacy.tsv"
MANIFEST="$OUT_DIR/MANIFEST.sha1"
MARK='<!-- TAD:PROJECT-CONTENT-BELOW -->'
MIN_TAGS=78

die() { echo "gen-claude-provenance: $*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git is required"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || die "not a git work tree: $ROOT"

TAGS="$(git -C "$ROOT" tag -l 'v*')"
n_tags="$(printf '%s\n' "$TAGS" | grep -c . || true)"
[ "${n_tags:-0}" -ge "$MIN_TAGS" ] || die "only ${n_tags:-0} v* tags found (need >= $MIN_TAGS); shallow clone or missing tags"

# SHA-1 tool, same probe order as the installer.
SHA1_TOOL=""
probe_sha1() {
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
probe_sha1 || die "no working SHA-1 tool (shasum, sha1sum, openssl)"
sha1_stdin() {
  local o
  case "$SHA1_TOOL" in
    shasum) o="$(shasum -a 1)" ;;
    sha1sum) o="$(sha1sum)" ;;
    openssl) o="$(openssl sha1)" ;;
  esac
  case "$SHA1_TOOL" in
    openssl) printf '%s\n' "${o##* }" ;;
    *) printf '%s\n' "${o%% *}" ;;
  esac
}

TMP="$(mktemp -d "${TMPDIR:-/tmp}/gen-claude-prov.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT # RM-OK:gen-provenance-tmp

# Every commit reachable from HEAD or any v* tag.
# shellcheck disable=SC2086
git -C "$ROOT" rev-list HEAD $TAGS > "$TMP/commits"

# New (path, blob) pairs per commit and per parent. Union over all commits is
# every blob that ever sat at these paths. Quoted paths (control characters)
# are skipped: they can never be proven by the installer either.
git -C "$ROOT" -c core.quotepath=false diff-tree --stdin -r -m --root --no-renames --no-abbrev \
    -- .claude .agents/skills .tad/templates/claude/settings.json CLAUDE.md < "$TMP/commits" \
  | LC_ALL=C awk -F'\t' '
    /^:/ {
      split($1, m, " "); mode = m[2]; id = m[4]; p = $2
      if (mode != "100644" && mode != "100755") next
      if (id ~ /^0+$/) next
      if (substr(p, 1, 1) == "\"") next
      if (p == ".claude/settings.json" || p == ".tad/templates/claude/settings.json") { print "settings\t" id "\t-"; next }
      if (p == "CLAUDE.md") { print "claudemd\t" id "\t-"; next }
      root = ""
      if (substr(p, 1, 15) == ".claude/skills/") { root = "c"; base = substr(p, 16) }
      else if (substr(p, 1, 15) == ".agents/skills/") { root = "a"; base = substr(p, 16) }
      if (root != "") {
        s = index(base, "/")
        if (s == 0) { if (root == "c") print "flat\t" id "\t" base; next }
        if (s == 1 || s == length(base)) next
        print "skill\t" id "\t" base; next
      }
      if (substr(p, 1, 18) == ".claude/workflows/") { f = substr(p, 19); if (f != "" && index(f, "/") == 0) print "workflow\t" id "\t" f; next }
      if (substr(p, 1, 17) == ".claude/commands/") { f = substr(p, 18); if (f != "" && index(f, "/") == 0) print "cmd\t" id "\t" f; next }
    }' > "$TMP/raw"

# Direct rows (everything except the two derived-hash kinds).
LC_ALL=C grep -v -e '^claudemd	' "$TMP/raw" > "$TMP/rows" || true

# settings-ws: ordinary SHA-1 of the stripped blob, non-empty blobs only.
LC_ALL=C awk -F'\t' '$1 == "settings" { print $2 }' "$TMP/raw" | LC_ALL=C sort -u | while IFS= read -r id; do
  [ -n "$id" ] || continue
  [ "$(git -C "$ROOT" cat-file -s "$id")" -gt 0 ] || continue
  git -C "$ROOT" cat-file blob "$id" | LC_ALL=C tr -d ' \t\r\n' > "$TMP/ws"
  [ -s "$TMP/ws" ] || continue
  printf 'settings-ws\t%s\t-\n' "$(sha1_stdin < "$TMP/ws")"
done >> "$TMP/rows"

# CLAUDE.md: whole-file id when the blob has no marker line, head hash when it has.
LC_ALL=C awk -F'\t' '$1 == "claudemd" { print $2 }' "$TMP/raw" | LC_ALL=C sort -u | while IFS= read -r id; do
  [ -n "$id" ] || continue
  git -C "$ROOT" cat-file blob "$id" > "$TMP/md"
  n="$(LC_ALL=C grep -n -x -F -e "$MARK" -- "$TMP/md" 2>/dev/null | sed -n '1s/:.*//p' || true)"
  case "$n" in
    ''|*[!0-9]*) printf 'md-whole\t%s\t-\n' "$id" ;;
    *) printf 'md-head\t%s\t-\n' "$(head -n "$n" -- "$TMP/md" | sha1_stdin)" ;;
  esac
done >> "$TMP/rows"

LC_ALL=C sort -u "$TMP/rows" > "$TMP/data"
rows="$(wc -l < "$TMP/data" | tr -d ' ')"
mkdir -p "$OUT_DIR"
{ printf '# schema=1 rows=%s\n' "$rows"; cat "$TMP/data"; } > "$TMP/ledger"

# Blob id of the ledger = sha1("blob <size>\0" + content); cross-checked with git.
blob_id() { { printf 'blob %s\0' "$(LC_ALL=C wc -c < "$1" | tr -d ' ')"; cat -- "$1"; } | sha1_stdin; }
lid="$(blob_id "$TMP/ledger")"
gid="$(git -C "$ROOT" hash-object --no-filters "$TMP/ledger")"
[ "$lid" = "$gid" ] || die "blob id mismatch (shell $lid vs git $gid)"

mv -f -- "$TMP/ledger" "$LEDGER"
printf '%s\n' "$lid" > "$MANIFEST"
echo "gen-claude-provenance: $rows rows, ledger blob $lid"
