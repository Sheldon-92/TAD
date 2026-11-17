#!/bin/bash
# tad-tmp.sh — make, check, list and remove a dispatch's temporary copies (report-upgrades Phase 5, D20).
#
# Usage:
#   /bin/bash .tad/scripts/tad-tmp.sh new <id>            make <root>/tad-copy-<id>.XXXXXX (mode 700), record it, print it
#   /bin/bash .tad/scripts/tad-tmp.sh check <path>        exit 0 only for a recorded directory or a directory under one
#   /bin/bash .tad/scripts/tad-tmp.sh remove <id> [<path>] remove the id's recorded directories (or only <path>)
#   /bin/bash .tad/scripts/tad-tmp.sh open                list recorded directories that still exist: `open: <path> by <id>`
#
# <id>: ^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$ (else exit 2).
# Temp root: TMPDIR when absolute, an existing writable directory whose resolved path holds only
# [A-Za-z0-9._/-] and is not the project, $HOME, under either or an ancestor of either; else /tmp.
# The record is <root>/tad-copy-<id>.rec, one `made: <path>` line per directory. A record that is a
# link, not a regular file or not owned by the caller is refused. `remove` and `open` scan the current
# root, /tmp and the per-user temp directory (getconf DARWIN_USER_TEMP_DIR, where it exists), so a
# TMPDIR that changed between `new` and `remove` is still found; `remove` with nothing recorded for the
# id prints `not-removed: none — …` and exits 1, never silence.
# An id is not unique (a retried dispatch keeps its id): `new` says when the id's record already lists
# directories, and `remove <id> <path>` removes only that path. A dispatch that wants to remove only
# what it made passes each path `new` printed.
# Output: `removed: <path>` / `not-removed: <path> — <reason>`; paths with $HOME shown as `~`.
# Exit: new/check/open 0 ok, 1 refused or failed; remove 0 all removed, 1 any not-removed; 2 usage.
# No git, no network; writes only in the temp root. bash 3.2 / BSD tools.

# --- environment sanitising (report-upgrades Phase 5, rework 2; ENV-SANITISE) -----------------------------
# This script trusts nothing it inherits; this block runs before any other command. Two inputs act before
# its first line and no script can close them, so they are named here instead: BASH_ENV (the file runs
# before line 1) and SHELLOPTS=xtrace with a PS4 that runs a command (the trace of line 1). Both are the
# caller running code of their own. Signals ignored when the script starts stay ignored (bash cannot reset
# them). The assignment below puts bash in posix mode, where `unset`, `set` and `exec` are found before any
# function of that name, so every inherited (exported) function can be removed; then posix mode is left.
# A third such input: SHELLOPTS=noexec or SHELLOPTS=onecmd (bash then runs no command, or only one): the script prints nothing; read an empty output as not run, never as a result.
POSIXLY_CORRECT=1
\set +e +a +k +x +v -f  # ENV-SET
\unset -f unset set builtin command declare read enable shopt unalias exec eval trap kill wait cd pwd printf echo test type local return exit export source true false 2>/dev/null
for _sz in $(\declare -F); do case "$_sz" in declare|-f|-fx|-fr|-frx) ;; *) \unset -f -- "$_sz" 2>/dev/null ;; esac; done  # ENV-NO-FUNCS
\unalias -a 2>/dev/null
\enable cd pwd printf echo read test '[' kill wait type command builtin local declare shopt unalias trap eval exec set unset export source true false 2>/dev/null
IFS=' 	
'
\unset CDPATH GLOBIGNORE GREP_OPTIONS GREP_COLOR GREP_COLORS CLICOLOR CLICOLOR_FORCE LSCOLORS ENV BASH_XTRACEFD FUNCNEST BASH_COMPAT EXECIGNORE  # ENV-UNSET
\set +o pipefail +C +b +E +T
for _sz in nullglob failglob nocaseglob nocasematch dotglob extglob expand_aliases xpg_echo; do \shopt -u "$_sz" 2>/dev/null; done
\unset POSIXLY_CORRECT _sz
\set +o posix
for _sz in $(\declare -F); do case "$_sz" in declare|-f|-fx|-fr|-frx) ;; *) \unset -f -- "$_sz" 2>/dev/null ;; esac; done  # ENV-NO-FUNCS-2
\set +f  # ENV-GLOB
\unset _sz
\exec 0</dev/null
{ \exec 3>&1; } 2>/dev/null || { printf '%s\n' "${0##*/}: stdout is closed; nothing done" >&2; exit 2; }
\exec 3>&-
# --- end of the sanitising block ---------------------------------------------------------------------------
set -u
umask 077
# This script's own tools (rm, chmod, mktemp, grep, readlink, dirname, getconf, sed, mv, rmdir) run from
# the system directories only: a planted `rm` earlier on the caller's PATH is never run (rework 1, P0-1).
PATH=/usr/bin:/bin:/usr/sbin:/sbin  # TT-PATH-PIN
NL='
'
export LC_ALL=C

_home_show() { # print a path with $HOME as ~ at a / boundary
  local p="$1"
  if [ -n "${HOME_RAW:-}" ]; then
    case "$p" in "$HOME_RAW") p="~" ;; "$HOME_RAW"/*) p="~${p#"$HOME_RAW"}" ;; esac
  fi
  printf '%s' "$p"
}
say() { printf '%s\n' "$1"; }
usage() { say "usage: tad-tmp.sh new <id> | check <path> | remove <id> [<path>] | open"; exit 2; }

_resolve_dir() { # one absolute line or nothing: CDPATH is cleared above, `cd` prints nothing, and an answer that is
  # relative, empty or holds a newline is refused (rework 2, P0: a CDPATH made `cd` print a second line)
  local r
  r="$(cd -P -- "$1" > /dev/null 2>&1 && pwd -P && printf x)" || return 1
  r="${r%x}"; r="${r%"$NL"}"
  case "$r" in /*) ;; *) return 1 ;; esac
  case "$r" in *"$NL"*) return 1 ;; esac  # TT-DIR-ONE-LINE
  printf '%s' "$r"
}

# the script's own path through its link chain (a readlink loop), then two levels up
_self="$0"
while [ -L "$_self" ]; do
  _l="$(readlink "$_self")"
  case "$_l" in /*) _self="$_l" ;; *) _self="$(dirname "$_self")/$_l" ;; esac
done
PROJ="$(_resolve_dir "$(dirname "$_self")/../..")" || PROJ=""
[ -n "$PROJ" ] || { say "tad-tmp: cannot resolve the project root"; exit 2; }
HOME_RAW="${HOME:-}"; HOME_RAW="${HOME_RAW%/}"
case "$HOME_RAW" in /*) ;; *) HOME_RAW="" ;; esac  # a relative HOME is not used (rework 2)
HOME_P=""
[ -n "$HOME_RAW" ] && HOME_P="$(_resolve_dir "$HOME_RAW")"
# the account's home from the user database (tilde expansion of the login name), excluded as well:
# HOME is the caller's word and can be wrong (rework 2)
HOME_DB=""; _u="$(id -un 2>/dev/null)"
case "$_u" in ''|*[!A-Za-z0-9._-]*) ;; *) eval "_h=~$_u"; case "$_h" in /*) HOME_DB="$(_resolve_dir "$_h")" || HOME_DB="" ;; esac ;; esac  # TT-HOME-DB

# _is_or_under <a> <b>: a equals b or lies under it
_is_or_under() { case "$1/" in "$2/"*) return 0 ;; esac; return 1; }
_bad_place() { # the resolved path is the project or HOME, under either, or an ancestor of either
  local r="$1" x
  for x in "$PROJ" "$HOME_P" "$HOME_DB"; do
    [ -n "$x" ] || continue
    _is_or_under "$r" "$x" && return 0
    _is_or_under "$x" "$r" && return 0
  done
  return 1
}
_canonical() { # absolute, only [A-Za-z0-9._/-], no trailing /, no //, /./, /../
  local p="$1"
  case "$p" in /*) ;; *) return 1 ;; esac
  [ "${#p}" -le 1024 ] || return 1  # rework 2, P2-5: a printed entry is at most PATH_MAX long
  case "$p" in *[!A-Za-z0-9._/-]*) return 1 ;; esac
  case "$p" in */) return 1 ;; esac
  case "$p" in *//*|*/./*|*/../*|*/.|*/..) return 1 ;; esac
  return 0
}

temp_root() {
  local t="${TMPDIR:-}" r
  t="${t%/}"
  case "$t" in
    /*)
      if [ -d "$t" ] && [ -w "$t" ]; then
        r="$(_resolve_dir "$t")"
        if [ -n "$r" ] && _canonical "$r" && [ "$r" != "/" ]; then
          _bad_place "$r" && { _resolve_dir /tmp; return 0; }  # TT-ROOT-PLACE
          printf '%s' "$r"; return 0
        fi
      fi ;;
  esac
  _resolve_dir /tmp
}

scan_roots() { # current root, /tmp, the per-user temp dir; resolved, deduplicated, one per line
  local cur r out="" d
  cur="$(temp_root)"
  d="$(getconf DARWIN_USER_TEMP_DIR 2>/dev/null)" || d=""
  for r in "$cur" "$(_resolve_dir /tmp)" "${d:+$(_resolve_dir "$d")}"; do
    [ -n "$r" ] && [ -d "$r" ] || continue
    case "${NL}${out}${NL}" in *"${NL}${r}${NL}"*) continue ;; esac
    out="${out:+$out$NL}$r"
  done
  printf '%s\n' "$out"
}

_valid_id() { # ^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$
  local i="$1"
  [ -n "$i" ] || return 1
  [ "${#i}" -le 64 ] || return 1
  case "$i" in [!A-Za-z0-9]*) return 1 ;; esac
  case "$i" in *[!A-Za-z0-9_-]*) return 1 ;; esac
  return 0
}

_rec_ok() { # a record file we may read or append: not a link, a regular file, owned by the caller
  [ ! -L "$1" ] || return 1   # TT-REC-LINK
  [ -f "$1" ] || return 1
  [ -O "$1" ] || return 1
  return 0
}

# _entry_reason <root> <id> <path>: empty when the recorded path may be acted on, else the reason
_entry_reason() {
  local root="$1" id="$2" p="$3" b par rp
  _canonical "$p" || { printf 'not in canonical form'; return; }
  b="${p##*/}"
  case "$b" in "tad-copy-$id."??????) ;; *) printf 'name is not tad-copy-%s.XXXXXX' "$id"; return ;; esac  # TT-BASENAME
  [ ! -L "$p" ] || { printf 'it is a link'; return; }  # TT-LINK-CHECK
  [ -d "$p" ] || { printf 'not a directory'; return; }
  par="$(_resolve_dir "${p%/*}")"
  [ "$par" = "$root" ] || { printf 'its parent is not the temp root'; return; }  # TT-PARENT-CHECK
  rp="$(_resolve_dir "$p")"
  if [ -z "$rp" ] || _bad_place "$rp" || [ "$rp" = "$root" ]; then printf 'it is the project, HOME, the temp root or an ancestor'; return; fi
}

cmd_new() {
  local id="$1" root d rec n
  _valid_id "$id" || { say "tad-tmp: bad id"; exit 2; }  # TT-ID-CHECK
  root="$(temp_root)"
  [ -n "$root" ] && [ -d "$root" ] && [ -w "$root" ] || { say "tad-tmp: no writable temp root"; exit 1; }
  rec="$root/tad-copy-$id.rec"
  if [ -e "$rec" ] || [ -L "$rec" ]; then
    _rec_ok "$rec" || { say "refused: record $(_home_show "$rec") is a link, not a regular file or not yours; nothing made"; exit 1; }
    n="$(grep -c '^made: ' "$rec" 2>/dev/null)" || n=0
    [ "$n" = "0" ] || say "note: the record of $id already lists $n directory(ies) (an earlier run of this id?); remove $id <path> removes only that path" >&2
  fi
  d="$(mktemp -d "$root/tad-copy-$id.XXXXXX" 2>/dev/null)" || { say "tad-tmp: mktemp failed in $(_home_show "$root"); nothing made"; exit 1; }
  [ -n "$d" ] && [ -d "$d" ] || { say "tad-tmp: mktemp gave no directory; nothing made"; exit 1; }
  chmod 700 "$d" 2>/dev/null
  if [ -e "$rec" ]; then
    printf 'made: %s\n' "$d" >> "$rec" 2>/dev/null
  else
    ( set -C; printf 'made: %s\n' "$d" > "$rec" ) 2>/dev/null
  fi
  if [ $? -ne 0 ] || ! grep -qxF -- "made: $d" "$rec" 2>/dev/null; then
    rmdir "$d" 2>/dev/null
    say "tad-tmp: could not record $(_home_show "$d") in $(_home_show "$rec"); the directory was not kept"
    exit 1
  fi
  say "$d"
}

_records_of() { # all owned record files across the scanned roots: "<root>\t<file>"
  local r f
  while IFS= read -r r; do
    [ -n "$r" ] || continue
    for f in "$r"/tad-copy-*.rec; do
      [ -e "$f" ] || [ -L "$f" ] || continue
      _rec_ok "$f" || continue
      printf '%s\t%s\n' "$r" "$f"
    done
  done <<EOF
$(scan_roots)
EOF
}

cmd_check() {
  local p="$1" rp r f id line q
  [ -n "$p" ] || { say "refused: empty path"; exit 1; }
  _canonical "$p" || { say "refused: not in canonical form"; exit 1; }
  [ ! -L "$p" ] || { say "refused: $(_home_show "$p") is a link"; exit 1; }
  [ -d "$p" ] || { say "refused: $(_home_show "$p") is not a directory"; exit 1; }
  rp="$(_resolve_dir "$p")"  # TT-CHECK-RESOLVE
  [ -n "$rp" ] || { say "refused: cannot resolve"; exit 1; }
  while IFS="$(printf '\t')" read -r r f; do
    [ -n "$f" ] || continue
    id="${f##*/tad-copy-}"; id="${id%.rec}"
    while IFS= read -r line; do
      case "$line" in "made: "*) q="${line#made: }" ;; *) continue ;; esac
      [ -z "$(_entry_reason "$r" "$id" "$q")" ] || continue  # TT-CHECK-VALIDATE
      q="$(_resolve_dir "$q")"
      if _is_or_under "$rp" "$q"; then exit 0; fi
    done < "$f"
  done <<EOF
$(_records_of)
EOF
  say "refused: $(_home_show "$p") is not a recorded directory or under one"
  exit 1
}

cmd_open() {
  local r f id line q
  while IFS="$(printf '\t')" read -r r f; do
    [ -n "$f" ] || continue
    id="${f##*/tad-copy-}"; id="${id%.rec}"
    _valid_id "$id" || continue
    while IFS= read -r line; do
      case "$line" in "made: "*) q="${line#made: }" ;; *) continue ;; esac
      [ -z "$(_entry_reason "$r" "$id" "$q")" ] || continue  # TT-OPEN-VALIDATE
      say "open: $(_home_show "$q") by $id"
    done < "$f"
  done <<EOF
$(_records_of)
EOF
  exit 0
}

_try_remove() { # <root> <id> <path>: prints removed:/not-removed:, returns 0 when removed
  local root="$1" id="$2" p="$3" why rc
  why="$(_entry_reason "$root" "$id" "$p")"
  # a record entry that is not in canonical form is never echoed: it may carry any text (rework 1, P1-1)
  if [ -n "$why" ] && ! _canonical "$p"; then say "not-removed: <entry not in canonical form> — $why"; return 1; fi  # TT-QUIET-ENTRY
  if [ -n "$why" ]; then say "not-removed: $(_home_show "$p") — $why"; return 1; fi
  chmod -R u+w "$p" 2>/dev/null
  rm -rf "$p" 2>/dev/null; rc=$?
  if [ "$rc" -ne 0 ] || [ -e "$p" ] || [ -L "$p" ]; then say "not-removed: $(_home_show "$p") — rm exit $rc"; return 1; fi
  say "removed: $(_home_show "$p")"
  return 0
}

cmd_remove() {
  local id="$1" want="${2:-}" any=0 bad=0 r rec line p keep tmp roots
  _valid_id "$id" || { say "tad-tmp: bad id"; exit 2; }  # TT-ID-CHECK
  if [ "$#" -ge 2 ] && [ -z "$want" ]; then say "not-removed: (empty) — empty path"; exit 1; fi
  roots="$(scan_roots)"
  while IFS= read -r r; do
    [ -n "$r" ] || continue
    rec="$r/tad-copy-$id.rec"
    [ -e "$rec" ] || [ -L "$rec" ] || continue
    if ! _rec_ok "$rec"; then say "not-removed: $(_home_show "$rec") — the record is a link, not a regular file or not yours"; bad=1; any=1; continue; fi
    keep=""
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in "made: "*) p="${line#made: }" ;; *) [ -n "$line" ] && keep="${keep}${line}${NL}"; continue ;; esac
      [ -z "$want" ] || [ "$p" = "$want" ] || { keep="${keep}${line}${NL}"; continue; }  # TT-ONE-PATH
      any=1
      if _try_remove "$r" "$id" "$p"; then :; else bad=1; keep="${keep}${line}${NL}"; fi
    done < "$rec"
    if [ -z "$keep" ]; then
      rm -f "$rec" 2>/dev/null || { say "not-removed: $(_home_show "$rec") — the empty record could not be deleted"; bad=1; }
    else
      tmp="$(mktemp "$rec.XXXXXX" 2>/dev/null)" && printf '%s' "$keep" > "$tmp" && mv -f "$tmp" "$rec" || { say "not-removed: $(_home_show "$rec") — the record could not be rewritten"; bad=1; [ -n "${tmp:-}" ] && rm -f "$tmp" 2>/dev/null; }
    fi
  done <<EOF
$roots
EOF
  if [ -n "$want" ] && [ "$any" = "0" ]; then
    _canonical "$want" || { say "not-removed: <path not in canonical form> — not in the record of $id"; exit 1; }
    say "not-removed: $(_home_show "$want") — not in the record of $id"  # TT-RECORD-CHECK
    exit 1
  fi
  if [ "$any" = "0" ]; then
    say "not-removed: none — no record for $id in $(printf '%s\n' "$roots" | while IFS= read -r r; do [ -n "$r" ] && printf '%s ' "$(_home_show "$r")"; done | sed 's/ $//')"  # TT-NO-RECORD
    exit 1
  fi
  [ "$bad" = "0" ] && exit 0
  exit 1
}

[ $# -ge 1 ] || usage
case "$1" in
  new) [ $# -eq 2 ] || usage; cmd_new "$2" ;;
  check) [ $# -eq 2 ] || usage; cmd_check "$2" ;;
  remove) [ $# -eq 2 ] || [ $# -eq 3 ] || usage; shift; cmd_remove "$@" ;;
  open) [ $# -eq 1 ] || usage; cmd_open ;;
  *) usage ;;
esac
