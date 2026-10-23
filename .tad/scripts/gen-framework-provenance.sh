#!/usr/bin/env bash
# gen-framework-provenance.sh — regenerate the release-file ledger.
#
# TAD repo only (needs git and the full tag set). Records the git blob id of every file TAD ever
# released or generated, with the first release that carried it:
#   <blob id><TAB><label>      one row per id, LC_ALL=C sorted, header "# schema=1 rows=<n>"
# Selection: every path in every commit reachable from HEAD or a v* tag, under .tad/ (minus the
# dirs derive-sync-set.sh --zero-touch and --transient print, and minus .tad/sync-registry.yaml and
# .tad/brain-index.md) and under .agents/skills/, .claude/, .codex/, .opencode/, .cursor/, plus
# AGENTS.md and CLAUDE.md. Regular files only (mode 100644/100755), unquoted paths.
# Label: the first v* tag, in version order, whose tree holds the blob in the selection; else
# main@<12 hex of the earliest commit that added it>.
# Generated rows: the HOOKS_EOF heredoc of tad.sh (what the installer writes to .codex/hooks.json) at
# every tag and at HEAD -> gen:<tag>:codex-hooks (gen:HEAD:codex-hooks only when no tag has it),
# added only when the id has no row yet.
# Byte identity only, no whitespace rule, path-agnostic (see .tad/provenance/README.md).
# Output: .tad/provenance/framework-released.tsv and framework-released.sha1 (the ledger's blob id).
# The same history gives byte-identical files: the header carries no commit hash.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
OUT_DIR="$ROOT/.tad/provenance"
LEDGER="$OUT_DIR/framework-released.tsv"
MANIFEST="$OUT_DIR/framework-released.sha1"
DERIVE="$ROOT/.tad/hooks/lib/derive-sync-set.sh"
MIN_TAGS=78

die() { echo "gen-framework-provenance: $*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git is required"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || die "not a git work tree: $ROOT"
[ -f "$DERIVE" ] || die "derive-sync-set.sh not found: $DERIVE"

TAGS="$(git -C "$ROOT" tag -l 'v*' --sort=version:refname)"
n_tags="$(printf '%s\n' "$TAGS" | grep -c . || true)"
[ "${n_tags:-0}" -ge "$MIN_TAGS" ] || die "only ${n_tags:-0} v* tags found (need >= $MIN_TAGS); shallow clone or missing tags"

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

TMP="$(mktemp -d "${TMPDIR:-/tmp}/gen-framework-prov.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT # RM-OK:gen-framework-provenance-tmp

# Deny dirs under .tad/ (zero-touch + transient), one per line, as the one authoritative source prints them.
{ bash "$DERIVE" --zero-touch "$ROOT"; bash "$DERIVE" --transient "$ROOT"; } > "$TMP/deny"
[ -s "$TMP/deny" ] || die "derive-sync-set.sh printed no deny dirs"

# Selection filter shared by both walks (reads "path" in $2, "id" in $1 of tab rows on stdin).
# Array membership only (never == on paths: awk compares CJK strings wrongly on macOS).
SEL_AWK='
function keep(p,   rest, s, first) {
  if (substr(p, 1, 1) == "\"") return 0
  if (p in exact) return 1
  if (substr(p, 1, 15) == ".agents/skills/") return 1
  if (substr(p, 1, 8) == ".claude/" || substr(p, 1, 7) == ".codex/" || substr(p, 1, 10) == ".opencode/" || substr(p, 1, 8) == ".cursor/") return 1
  if (substr(p, 1, 5) == ".tad/") {
    rest = substr(p, 6)
    if (rest in topdeny) return 0
    s = index(rest, "/")
    if (s == 0) return 1
    first = substr(rest, 1, s - 1)
    if (first in deny) return 0
    return 1
  }
  return 0
}
BEGIN {
  exact["AGENTS.md"] = 1; exact["CLAUDE.md"] = 1
  topdeny["sync-registry.yaml"] = 1; topdeny["brain-index.md"] = 1
  while ((getline line < denyfile) > 0) deny[line] = 1
  close(denyfile)
}'
PATHSPEC=".tad .agents/skills .claude .codex .opencode .cursor AGENTS.md CLAUDE.md"

# 1. Earliest commit per blob (oldest first, first occurrence wins).
# shellcheck disable=SC2086
git -C "$ROOT" rev-list --reverse HEAD $TAGS > "$TMP/commits"
# shellcheck disable=SC2086
git -C "$ROOT" -c core.quotepath=false diff-tree --stdin -r -m --root --no-renames --no-abbrev -- $PATHSPEC < "$TMP/commits" \
  | LC_ALL=C awk -F'\t' -v denyfile="$TMP/deny" "$SEL_AWK"'
    !/^:/ { split($0, h, " "); commit = substr(h[1], 1, 12); next }
    /^:/ {
      split($1, m, " "); mode = m[2]; id = m[4]; p = $2
      if (mode != "100644" && mode != "100755") next
      if (id ~ /^0+$/) next
      if (!keep(p)) next
      if (!(id in seen)) { seen[id] = 1; print id "\t" commit }
    }' > "$TMP/by-commit"

# 2. First tag, in version order, per blob.
: > "$TMP/by-tag-raw"
while IFS= read -r tag; do
  [ -n "$tag" ] || continue
  # shellcheck disable=SC2086
  git -C "$ROOT" -c core.quotepath=false ls-tree -r --full-tree "$tag" -- $PATHSPEC \
    | LC_ALL=C awk -F'\t' -v denyfile="$TMP/deny" -v tag="$tag" "$SEL_AWK"'
      {
        split($1, m, " "); mode = m[1]; id = m[3]; p = $2
        if (mode != "100644" && mode != "100755") next
        if (!keep(p)) next
        print id "\t" tag
      }' >> "$TMP/by-tag-raw"
done <<< "$TAGS"
LC_ALL=C awk -F'\t' '!(($1) in seen) { seen[$1] = 1; print }' "$TMP/by-tag-raw" > "$TMP/by-tag"

# 3. Join: tag label when a tag holds it, else main@<earliest commit>.
LC_ALL=C awk -F'\t' '
  FNR == NR { tagof[$1] = $2; next }
  { id = $1; if (id in tagof) { print id "\t" tagof[id]; done[id] = 1 } else { print id "\tmain@" $2; done[id] = 1 } }
  END { }' "$TMP/by-tag" "$TMP/by-commit" > "$TMP/rows"
# Blobs held by a tag but absent from the walk (cannot happen with the same pathspec; kept as a seatbelt).
LC_ALL=C awk -F'\t' 'FNR == NR { have[$1] = 1; next } !($1 in have) { print $1 "\t" $2 }' "$TMP/rows" "$TMP/by-tag" >> "$TMP/rows"

# 4. Generated rows: the HOOKS_EOF heredoc at every tag and at HEAD.
blob_id() { { printf 'blob %s\0' "$(LC_ALL=C wc -c < "$1" | tr -d ' ')"; cat -- "$1"; } | sha1_stdin; }
heredoc_id() {
  git -C "$ROOT" show "$1:tad.sh" 2>/dev/null | sed -n "/<< *'HOOKS_EOF'/,/^ *HOOKS_EOF\$/p" | sed '1d;$d' > "$TMP/hk" || true
  [ -s "$TMP/hk" ] || return 1
  blob_id "$TMP/hk"
}
LC_ALL=C cut -f1 "$TMP/rows" | LC_ALL=C sort -u > "$TMP/have"
add_gen() {
  local id="$1" label="$2"
  grep -qxF -e "$id" "$TMP/have" && return 0
  printf '%s\t%s\n' "$id" "$label" >> "$TMP/rows"
  printf '%s\n' "$id" >> "$TMP/have"
}
while IFS= read -r tag; do
  [ -n "$tag" ] || continue
  hid="$(heredoc_id "$tag" || true)"
  [ -n "$hid" ] || continue
  add_gen "$hid" "gen:$tag:codex-hooks"
done <<< "$TAGS"
hid="$(heredoc_id HEAD || true)"
[ -z "$hid" ] || add_gen "$hid" "gen:HEAD:codex-hooks"

LC_ALL=C sort -u "$TMP/rows" > "$TMP/data"
# One row per id: a duplicate id with two labels would be a generator bug.
dups="$(LC_ALL=C cut -f1 "$TMP/data" | LC_ALL=C uniq -d || true)"
[ -z "$dups" ] || die "an id has two labels: $(printf '%s' "$dups" | head -n 1)"
rows="$(wc -l < "$TMP/data" | tr -d ' ')"
mkdir -p "$OUT_DIR"
{ printf '# schema=1 rows=%s\n' "$rows"; cat "$TMP/data"; } > "$TMP/ledger"

lid="$(blob_id "$TMP/ledger")"
gid="$(git -C "$ROOT" hash-object --no-filters "$TMP/ledger")"
[ "$lid" = "$gid" ] || die "blob id mismatch (shell $lid vs git $gid)"

mv -f -- "$TMP/ledger" "$LEDGER"
printf '%s\n' "$lid" > "$MANIFEST"
echo "gen-framework-provenance: $rows rows, ledger blob $lid"
