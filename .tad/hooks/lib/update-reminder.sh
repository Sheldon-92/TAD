#!/bin/bash
# TAD update reminder — sourced by startup-health.sh on the session-start path.
# Exposes one function, update_reminder_line: prints one reminder line or nothing, returns 0 always.
# It only reads a version number and writes two small stamps in the user's cache dir (outside every
# project). It never downloads or runs anything and never starts an update: the human does that.
#
# Rules (EPIC-20261022-tad-update-flow, Phase 2, decisions D6-D11):
#   - acts only on a call whose envelope names a session (HOOK_SESSION_ID); a call that names none
#     (a manual run, the OpenCode session.created side-effect call) fetches, prints and stamps nothing
#   - off switch: the file .tad/active/update-reminder.off (any content)
#   - local version = first line of .tad/version.txt; remote version = the same raw URL the update
#     helper reads; both must be strict MAJOR.MINOR.PATCH, compared numerically
#   - one network call per 24 h per user (the slot is used up before the call, a failed or slow call
#     also counts); the remote value comes from update-check.tsv, fresh or cached
#   - one line per 24 h per project (reminded/<cksum of the physical project path>, written only
#     together with the line)
#   - the fetch is a background curl with fds on files, waited for in 0.1 s steps up to 1.6 s,
#     then TERM, up to 0.3 s grace, KILL (macOS has no timeout command); temp files come from mktemp
#     in the cache dir; the cache location is used only when absolute (else the default chain)

UPDATE_REMINDER_URL="https://raw.githubusercontent.com/Sheldon-92/TAD/main/.tad/version.txt"
UPDATE_REMINDER_DAY=86400

# _ur_semver <string> — succeeds when the string is MAJOR.MINOR.PATCH, digits only
_ur_semver() {
  case "$1" in
    ''|*[!0-9.]*|.*|*.|*..*) return 1 ;;
  esac
  case "$1" in
    *.*.*.*) return 1 ;;
    *.*.*) return 0 ;;
  esac
  return 1
}

# _ur_gt <a> <b> — succeeds when version a is newer than version b (both already validated)
_ur_gt() {
  local _a="$1" _b="$2" _i _x _y
  local IFS=.
  local -a _A _B
  _A=($_a)
  _B=($_b)
  for _i in 0 1 2; do
    _x="${_A[$_i]:-0}"
    _y="${_B[$_i]:-0}"
    if [ "$((10#$_x))" -gt "$((10#$_y))" ]; then return 0; fi
    if [ "$((10#$_x))" -lt "$((10#$_y))" ]; then return 1; fi
  done
  return 1
}

# _ur_tsv_value <file> <key> — second field of the first line whose first field is key
_ur_tsv_value() {
  local _t=$'\t'
  [ -f "$1" ] || return 0
  sed -n "s/^$2${_t}//p" "$1" 2>/dev/null | head -n 1 | tr -d '[:space:]'
}

# _ur_write_check <file> <checked_at> <remote or empty> — rewrite update-check.tsv atomically
_ur_write_check() {
  local _f="$1" _tmp
  _tmp="$(mktemp "$(dirname "$1")/check.XXXXXX" 2>/dev/null)" || return 1
  {
    printf 'checked_at\t%s\n' "$2"
    if [ -n "$3" ]; then printf 'remote\t%s\n' "$3"; fi
  } > "$_tmp" 2>/dev/null || { rm -f "$_tmp" 2>/dev/null; return 1; }
  mv -f "$_tmp" "$_f" 2>/dev/null || { rm -f "$_tmp" 2>/dev/null; return 1; }
  return 0
}

# _ur_fetch_remote <cache dir> — print the remote version text (empty on any failure).
# Hard bound: wait up to 1.6 s, then TERM, up to 0.3 s of grace, then KILL; never an unbounded wait.
_ur_fetch_remote() {
  local _cdir="$1" _out _err _pid _i=0 _body
  command -v curl >/dev/null 2>&1 || return 0
  _out="$(mktemp "$_cdir/fetch.XXXXXX" 2>/dev/null)" || return 0
  _err="$(mktemp "$_cdir/fetch.XXXXXX" 2>/dev/null)" || { rm -f "$_out" 2>/dev/null; return 0; }
  curl -fsS --connect-timeout 2 --max-time 2 "$UPDATE_REMINDER_URL" >"$_out" 2>"$_err" </dev/null &
  _pid=$!
  while [ "$_i" -lt 16 ]; do
    kill -0 "$_pid" 2>/dev/null || break
    sleep 0.1
    _i=$((_i + 1))
  done
  if kill -0 "$_pid" 2>/dev/null; then
    kill "$_pid" 2>/dev/null
    _i=0
    while [ "$_i" -lt 3 ] && kill -0 "$_pid" 2>/dev/null; do
      sleep 0.1
      _i=$((_i + 1))
    done
    if kill -0 "$_pid" 2>/dev/null; then kill -9 "$_pid" 2>/dev/null; fi
    kill -0 "$_pid" 2>/dev/null || { wait "$_pid"; } 2>/dev/null
    rm -f "$_out" "$_err" 2>/dev/null
    return 0
  fi
  { wait "$_pid"; } 2>/dev/null
  _body="$(head -n 1 "$_out" 2>/dev/null | tr -d '[:space:]')"
  rm -f "$_out" "$_err" 2>/dev/null
  printf '%s' "$_body"
  return 0
}

update_reminder_line() {
  local _local _remote _cdir _chk _now _checked _stamp _id _last _fresh
  # A call that names no session cannot deliver a line: do nothing at all.
  [ -n "${HOOK_SESSION_ID:-}" ] || return 0
  # Off switch (also a symlink or a dangling link counts as "present").
  if [ -e ".tad/active/update-reminder.off" ] || [ -L ".tad/active/update-reminder.off" ]; then return 0; fi
  _local="$(head -n 1 .tad/version.txt 2>/dev/null | tr -d '[:space:]')"
  _ur_semver "$_local" || return 0
  # Only an absolute cache location is accepted; a relative one would land inside the project.
  _cdir=""
  case "${TAD_CACHE_DIR:-}" in /*) _cdir="$TAD_CACHE_DIR" ;; esac
  if [ -z "$_cdir" ]; then
    case "${XDG_CACHE_HOME:-}" in /*) _cdir="$XDG_CACHE_HOME/tad" ;; esac
  fi
  if [ -z "$_cdir" ]; then
    case "${HOME:-}" in /*) _cdir="$HOME/.cache/tad" ;; esac
  fi
  [ -n "$_cdir" ] || return 0
  mkdir -p "$_cdir/reminded" 2>/dev/null || return 0
  [ -d "$_cdir" ] && [ -w "$_cdir" ] && [ -w "$_cdir/reminded" ] || return 0
  _chk="$_cdir/update-check.tsv"
  _now="$(date +%s 2>/dev/null)"
  case "$_now" in ''|*[!0-9]*) return 0 ;; esac
  _checked="$(_ur_tsv_value "$_chk" checked_at)"
  _remote="$(_ur_tsv_value "$_chk" remote)"
  _fresh=0
  case "$_checked" in
    ''|*[!0-9]*) ;;
    *) if [ "$_checked" -le "$_now" ] && [ "$((_now - _checked))" -lt "$UPDATE_REMINDER_DAY" ]; then _fresh=1; fi ;;
  esac
  if [ "$_fresh" = "0" ]; then
    # Use up the day's network slot first; no write, no network.
    _ur_semver "$_remote" || _remote=""
    _ur_write_check "$_chk" "$_now" "$_remote" || return 0
    _stamp="$(_ur_fetch_remote "$_cdir")"
    if _ur_semver "$_stamp"; then
      _remote="$_stamp"
      _ur_write_check "$_chk" "$_now" "$_remote" || return 0
    fi
  fi
  _ur_semver "$_remote" || return 0
  _ur_gt "$_remote" "$_local" || return 0
  _id="$(printf '%s' "$(pwd -P 2>/dev/null)" | cksum 2>/dev/null | cut -d' ' -f1)"
  case "$_id" in ''|*[!0-9]*) return 0 ;; esac
  _last="$(head -n 1 "$_cdir/reminded/$_id" 2>/dev/null | tr -d '[:space:]')"
  case "$_last" in
    ''|*[!0-9]*) ;;
    *) if [ "$_last" -le "$_now" ] && [ "$((_now - _last))" -lt "$UPDATE_REMINDER_DAY" ]; then return 0; fi ;;
  esac
  printf '%s\n' "$_now" > "$_cdir/reminded/$_id" 2>/dev/null || return 0
  printf "TAD update: %s is available (this project: %s). Tell the human once in your first reply: 说'升级 TAD'即可." "$_remote" "$_local"
  return 0
}
