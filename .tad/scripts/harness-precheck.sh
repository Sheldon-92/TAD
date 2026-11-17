#!/bin/bash
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
# harness-precheck.sh — before a dispatch: is each harness CLI present, which version, logged in? (report-upgrades Phase 5)
#
# Usage: /bin/bash .tad/scripts/harness-precheck.sh [--platform <list>] [--env]
#   <list>   comma list of tad.sh's names: claude-code,codex,cursor,opencode
#   --env    python3 with PyYAML, and node (what the test suite needs)
#   neither, an empty list or an unknown name -> exit 2
# Per platform it runs, each from `/` with stdin /dev/null, in its own process group under a time bound:
#   <cli> --version; the help of the status command's parent; the status command itself:
#   claude auth status --json | codex login status | cursor-agent status | opencode auth list
# The status command is the CLI's own; it may contact its vendor or refresh a stored token. "read-only"
# is what TAD asks for, not a property of the vendor tool. Its output (which can carry an e-mail, an
# organisation id or credential names) is held in a shell variable, matched, and never printed or kept.
# This script writes no file, runs no git, opens no network connection of its own, reads no file under ~.
# (bash itself writes each here-document to a temp file it unlinks at once; only help texts and paths
# pass through one: the status text is parsed without a here-document, rework 2.)
# Lines (verbatim prefixes): PRECHECK-OK, PRECHECK-LOGIN, PRECHECK-MISSING, PRECHECK-UNKNOWN, PRECHECK-FIX;
# last line `PRECHECK: ok` | `PRECHECK: human <platforms>` | `PRECHECK: other <n> item(s)`.
# Exit: 0 all OK; 1 at least one LOGIN or MISSING; 3 otherwise not all OK (UNKNOWN, FIX); 2 usage.
# Time: PRECHECK_TIMEOUT (seconds per command, 1-4 digits, default 20) and PRECHECK_TOTAL (seconds for the
# whole run, default 60); a value that is not 1-4 digits or is 0 gives the default. Run it with a shell
# time limit above PRECHECK_TOTAL plus a few seconds.
# Not a hook: it informs; it blocks nothing. bash 3.2 / BSD tools.

set -u
umask 077
export LC_ALL=C
# The CLIs are looked up on the caller's PATH and run with it; this script's own tools run from the
# system directories only, so a planted `dirname` or `sed` earlier on PATH is never run.
USER_PATH="${PATH:-}"
PATH=/usr/bin:/bin:/usr/sbin:/sbin
NL='
'
ESC="$(printf '\033')"

_num() { # _num <value> <default>: 1-4 digits, read as decimal, not 0
  local v="$1" n
  case "$v" in ''|*[!0-9]*) printf '%s' "$2"; return ;; esac
  [ "${#v}" -le 4 ] || { printf '%s' "$2"; return; }
  n=$((10#$v))  # PC-DECIMAL
  [ "$n" -ge 1 ] || { printf '%s' "$2"; return; }
  printf '%s' "$n"
}
BOUND="$(_num "${PRECHECK_TIMEOUT:-}" 20)"  # PC-TIMEOUT-VALIDATE
CAP="$(_num "${PRECHECK_TOTAL:-}" 60)"

usage() { printf '%s\n' "usage: harness-precheck.sh [--platform claude-code,codex,cursor,opencode] [--env]"; exit 2; }
# help_block (report-upgrades Phase 6, D7): the comment lines from the header line to the `# Not a hook:` line,
# found by those two prefixes, never by line numbers; printed only when each is found once, the header comes
# first and every line between starts with `#`, with control bytes removed; else one line on stderr, exit 2
help_block() {
  local out
  out="$(awk -v s='# harness-precheck.sh — before a dispatch' -v e='# Not a hook:' '
    { L[NR] = $0 }
    index($0, s) == 1 { ns++; sl = NR }
    index($0, e) == 1 { ne++; el = NR }
    END {
      if (ns != 1 || ne != 1) exit 1  # PC-HELP-GUARD
      if (sl >= el) exit 1  # PC-HELP-ORDER
      for (i = sl; i <= el; i++) if (substr(L[i], 1, 1) != "#") exit 1  # PC-HELP-HASH
      for (i = sl; i <= el; i++) print L[i]
    }' "$0" 2>/dev/null)" || { printf '%s\n' "harness-precheck.sh: usage block not found" >&2; exit 2; }
  printf '%s\n' "$out" | tr -d '\000-\011\013-\037\177'  # PC-HELP-STRIP
  exit 0
}
PLAT=""; ENV=0; GOT_P=0
while [ $# -gt 0 ]; do
  case "$1" in
    --platform) [ $# -ge 2 ] || usage; PLAT="$2"; GOT_P=1; shift 2 ;;
    --env) ENV=1; shift ;;
    -h|--help) help_block ;;  # PC-HELP-CALL
    *) usage ;;
  esac
done
[ "$GOT_P" = "1" ] || [ "$ENV" = "1" ] || usage
if [ "$GOT_P" = "1" ]; then
  [ -n "$PLAT" ] || usage
  _old_ifs="$IFS"; IFS=','
  for _p in $PLAT; do case "$_p" in claude-code|codex|cursor|opencode) ;; *) IFS="$_old_ifs"; usage ;; esac; done
  IFS="$_old_ifs"
fi

_resolve_dir() { # one absolute line or nothing: CDPATH is cleared above, `cd` prints nothing, and an answer that is
  # relative, empty or holds a newline is refused (rework 2, P0: a CDPATH made `cd` print a second line)
  local r
  r="$(cd -P -- "$1" > /dev/null 2>&1 && pwd -P && printf x)" || return 1
  r="${r%x}"; r="${r%"$NL"}"
  case "$r" in /*) ;; *) return 1 ;; esac
  case "$r" in *"$NL"*) return 1 ;; esac  # PC-DIR-ONE-LINE
  printf '%s' "$r"
}
_chain() { # follow a link chain (no other tool); prints the final path
  local f="$1" l i=0
  while [ -L "$f" ] && [ "$i" -lt 40 ]; do
    l="$(readlink "$f")"
    case "$l" in /*) f="$l" ;; *) f="$(dirname "$f")/$l" ;; esac
    i=$((i + 1))
  done
  printf '%s' "$f"
}
ROOT="$(_resolve_dir "$(dirname "$(_chain "$0")")/../..")" || ROOT=""
[ -n "$ROOT" ] || { printf '%s\n' "harness-precheck: cannot resolve the project root to one absolute directory; nothing run"; exit 2; }  # PC-ROOT-CLOSED
START="$(_resolve_dir .)" || START=""
[ -n "$START" ] || { printf '%s\n' "harness-precheck: cannot resolve the start directory to one absolute directory; nothing run"; exit 2; }
HOME_RAW="${HOME:-}"; HOME_RAW="${HOME_RAW%/}"
case "$HOME_RAW" in /*) ;; *) HOME_RAW="" ;; esac  # a relative HOME is not used
HOME_P=""; [ -n "$HOME_RAW" ] && HOME_P="$(_resolve_dir "$HOME_RAW")"

show() { # a printed fragment: controls removed, $HOME as ~ at a / boundary, at most 60 characters
  local p h
  p="$(printf '%s' "$1" | tr -d '[:cntrl:]')"
  for h in "$HOME_P" "$HOME_RAW"; do  # PC-HOME-SHOW
    [ -n "$h" ] || continue
    case "$p" in "$h") p="~" ;; "$h"/*) p="~${p#"$h"}" ;; esac
  done
  _utf8_whole "$(printf '%s' "$p" | cut -c1-60)"  # PC-UTF8-CUT
}
_utf8_whole() { # drop bytes that do not form whole UTF-8 characters (a 60-byte cut can split one; rework 1, P1-4)
  if [ -x /usr/bin/iconv ]; then printf '%s' "$1" | iconv -c -f UTF-8 -t UTF-8 2>/dev/null
  else printf '%s' "$1" | tr -d '\200-\377'; fi
}

_excluded() { # a resolved directory that equals or lies under the project root, or equals the start directory (D1)
  local d="$1"
  if [ -n "$ROOT" ]; then case "$d/" in "$ROOT/"*) return 0 ;; esac; fi
  [ -n "$START" ] && [ "$d" = "$START" ] && return 0  # PC-START-EQUAL
  return 1
}

# find_cli <name>: FOUND = the executable (final path of its link chain), DANGLING / SKIPPED = notes
find_cli() {
  local name="$1" e r c f fd rest="$USER_PATH:"
  FOUND=""; DANGLING=""; SKIPPED=""
  while [ -n "$rest" ]; do
    e="${rest%%:*}"; rest="${rest#*:}"
    [ -n "$e" ] || continue
    case "$e" in /*) ;; *) continue ;; esac
    r="$(_resolve_dir "$e")" || continue  # PC-PATH-RESOLVED
    [ -n "$r" ] || continue
    c="$r/$name"
    if _excluded "$r"; then
      if [ -e "$c" ] || [ -L "$c" ]; then _note SKIPPED "$r"; fi
      continue
    fi
    if [ -L "$c" ] && [ ! -e "$c" ]; then _note DANGLING "$c"; continue; fi
    [ -f "$c" ] && [ -x "$c" ] || continue
    f="$(_chain "$c")"
    fd="$(_resolve_dir "$(dirname "$f")")"  # PC-TARGET-DIR
    if [ -z "$fd" ] || _excluded "$fd"; then _note SKIPPED "$r"; continue; fi  # PC-LINK-TARGET
    FOUND="$fd/$(basename "$f")"
    return 0
  done
  return 1
}
_note() { # _note <var> <path>: add a path once
  local cur; eval "cur=\${$1}"
  case "${NL}${cur}${NL}" in *"${NL}$2${NL}"*) return ;; esac
  eval "$1=\${cur:+\$cur\$NL}\$2"
}

# run_cmd <cmd...>: OUT (stdout+stderr unless RUN_STDOUT_ONLY=1), RC, TIMED, LIMIT, OVER (1: more than 4 MB, OUT empty)
# The CLI writes into a pipe that this shell reads line by line (rework 2, P1-A): the read ends at the inner
# shell's end line (a random token), not at the end of the pipe, so a process that keeps the pipe open after
# the CLI exits (a helper forked in the instant of the sweep, or one that left the group) cannot hold the
# run; and every read has a deadline (LIMIT + 5 s). The inner shell sweeps the CLI's group until it is empty,
# and sends its own messages (job notices) to /dev/null. No comment stands inside the process substitution:
# bash 3.2 counts parentheses in comments there.
run_cmd() {
  local left so="${RUN_STDOUT_ONLY:-0}" tok buf="" part="" k=0 sz=0 line dl rt rest
  left=$((CAP - SECONDS))  # PC-TOTAL-CAP
  LIMIT="$BOUND"; [ "$left" -lt "$LIMIT" ] && LIMIT="$left"
  OUT=""; RC=1; TIMED=1; OVER=0
  if [ "$LIMIT" -le 0 ]; then RC=124; LIMIT="$BOUND"; return; fi
  tok="PC-END-$$-$RANDOM$RANDOM$RANDOM"
  dl=$((SECONDS + LIMIT + 5))
  while :; do
    left=$((dl - SECONDS)); [ "$left" -ge 1 ] || break
    line=""
    IFS= read -r -t "$left" line; rt=$?  # PC-READ-BOUND
    case "$line" in "$tok "*) rest="${line#"$tok "}"; RC="${rest%% *}"; TIMED="${rest#* }"; break ;; esac  # PC-READ-MARK
    if [ "$rt" = 0 ]; then line="$line$NL"; elif [ "$rt" = 1 ]; then TIMED=0; fi
    sz=$((sz + ${#line}))
    if [ "$sz" -le 4194304 ]; then
      part="$part$line"; k=$((k + 1))
      [ "$k" -lt 256 ] || { buf="$buf$part"; part=""; k=0; }
    else OVER=1; fi
    [ "$rt" = 0 ] || break
  done < <(
    exec 2>/dev/null
    cd / || exit 97
    set -m
    if [ "$so" = "1" ]; then PATH="$USER_PATH" "$@" < /dev/null 2>/dev/null & else PATH="$USER_PATH" "$@" < /dev/null 2>&1 & fi
    p=$!
    ( sleep "$LIMIT"; kill -TERM -- "-$p" 2>/dev/null; sleep 1; kill -KILL -- "-$p" 2>/dev/null ) > /dev/null 2>&1 &  # PC-PGROUP-KILL
    w=$!
    trap 'kill -KILL -- "-$p" 2>/dev/null; kill -KILL -- "-$w" 2>/dev/null; exit 1' TERM INT HUP
    s=$SECONDS
    wait "$p"; rc=$?
    i=0; while kill -KILL -- "-$p" 2>/dev/null && [ "$i" -lt 40 ]; do i=$((i + 1)); sleep 0.05; done  # PC-GROUP-SWEEP
    t=0; [ $((SECONDS - s)) -ge "$LIMIT" ] && t=1
    kill -KILL -- "-$w" 2>/dev/null
    printf '\n%s %s %s\n' "$tok" "$rc" "$t"
  )
  OUT="$buf$part"; OUT="${OUT%"$NL"}"; buf=""; part=""
  [ "$OVER" = 0 ] || OUT=""
  case "$RC" in ''|*[!0-9]*) RC=1 ;; esac
  case "$TIMED" in 0) ;; *) TIMED=1 ;; esac
}

# _within <text> <n>: the text has at most n lines (a longer help or status text is not parsed: UNKNOWN; rework 1, P1-3)
_within() { [ "$OVER" = 0 ] && [ "$(printf '%s\n' "$1" | wc -l)" -le "$2" ]; }  # rework 2: OUT no longer ends in the CLI's last newline, so n lines pass (P2-1)
strip_ansi() { printf '%s' "$1" | sed "s/${ESC}\\[[0-9;]*m//g"; }

# version_token <text>: the first version-shaped token of the first line that has one, at most 30 characters
version_token() {
  local line tok rest="$1"
  while [ -n "$rest" ]; do
    case "$rest" in *"$NL"*) line="${rest%%"$NL"*}"; rest="${rest#*"$NL"}" ;; *) line="$rest"; rest="" ;; esac
    for tok in $line; do
      if [[ "$tok" =~ ^[vV]?[0-9]+(\.[0-9]+)+([-+][A-Za-z0-9.]+)?$ ]] && [ "${#tok}" -le 30 ]; then  # PC-VERSION-TOKEN
        printf '%s' "$tok"; return 0
      fi
    done
  done
  return 1
}

# help_has <help> <parent words> <word>: the word names an entry of the help's `Commands:` list.
# An entry is a line of that section at the indent of its first entry; a deeper line continues the
# entry above it; the section ends at a blank line or a shallower line. An entry may begin with the
# parent's own words (yargs), carry an alias group `a|b` or end in `[aliases: x, y]`.
help_has() {
  local help="$1" parent="$2" word="$3" line in=0 ind=-1 s n e first al a
  while IFS= read -r line; do
    line="${line%"${line##*[! ]}"}"
    if [ "$in" = "0" ]; then
      [ "$line" = "Commands:" ] && in=1
      continue
    fi
    if [ -z "$line" ]; then [ "$ind" -ge 0 ] && break; continue; fi
    s="${line%%[! ]*}"; n="${#s}"
    [ "$n" -gt 0 ] || break
    [ "$ind" -ge 0 ] || ind="$n"
    [ "$n" -lt "$ind" ] && break
    [ "$n" -gt "$ind" ] && continue  # PC-HELP-INDENT
    e="${line#"$s"}"
    case "$e" in "$parent "*) e="${e#"$parent "}" ;; esac  # PC-HELP-PARENT
    first="${e%% *}"
    al=""
    case "$e" in *"[aliases: "*"]") al="${e##*\[aliases: }"; al="${al%]}" ;; esac
    for a in ${first//|/ } ${al//,/ }; do
      [ "$a" = "$word" ] && return 0
    done
  done <<EOF
$help
EOF
  return 1
}

_clean_lead() { # drop leading blanks and a leading run of non-alphanumeric bytes (marks, box lines); ANSI is stripped by the caller
  local l="$1"
  l="${l#"${l%%[! ]*}"}"
  l="${l#"${l%%[A-Za-z0-9]*}"}"
  printf '%s' "$l"
}
# state_* <output>: prints OK, LOGIN, LOGIN-ENV or UNKNOWN (exact tokens only)
state_claude() {
  local flat m
  flat="$(printf '%s' "$1" | tr '\n' ' ')"
  m="$(printf '%s' "$flat" | grep -oE '"loggedIn"[[:space:]]*:[[:space:]]*(true|false)([,}[:space:]]|$)' | sed -E 's/^.*:[[:space:]]*(true|false).*$/\1/' | LC_ALL=C sort -u)"  # PC-STATE-JSON
  case "$flat" in *[Ee][Xx][Pp][Ii][Rr][Ee][Dd]*) m="" ;; esac  # PC-STATE-EXPIRED
  case "$m" in true) printf OK ;; false) printf LOGIN ;; *) printf UNKNOWN ;; esac
}
state_lines() {
  local line l ok=0 no=0 rest
  rest="$(strip_ansi "$1")"
  while [ -n "$rest" ]; do  # no here-document: the status text never reaches a file (rework 2)
    case "$rest" in *"$NL"*) line="${rest%%"$NL"*}"; rest="${rest#*"$NL"}" ;; *) line="$rest"; rest="" ;; esac
    l="$(_clean_lead "$line")"
    case "$l" in "Not logged in"|"Not logged in"[\ .:]*) no=1 ;; "Logged in"|"Logged in"[\ .:]*) ok=1 ;; esac  # PC-STATE-LINE
    case "$l" in *[Ee][Xx][Pp][Ii][Rr][Ee][Dd]*) no=1; ok=1 ;; esac  # PC-STATE-EXPIRED-LINE
  done
  if [ "$no" = "1" ] && [ "$ok" = "0" ]; then printf LOGIN
  elif [ "$ok" = "1" ] && [ "$no" = "0" ]; then printf OK
  else printf UNKNOWN; fi
}
state_opencode() {
  local line l n="" env=0 rest
  rest="$(strip_ansi "$1")"
  while [ -n "$rest" ]; do
    case "$rest" in *"$NL"*) line="${rest%%"$NL"*}"; rest="${rest#*"$NL"}" ;; *) line="$rest"; rest="" ;; esac
    l="$(_clean_lead "$line")"
    l="${l%"${l##*[! ]}"}"
    if [[ "$l" =~ ^(0|[1-9][0-9]*)\ credentials?$ ]]; then n="${BASH_REMATCH[1]}"; fi  # PC-CRED-COUNT
    [ "$l" = "Environment" ] && env=1
  done
  if [ -z "$n" ]; then printf UNKNOWN
  elif [ "$((10#$n))" -ge 1 ]; then printf OK
  elif [ "$env" = "1" ]; then printf LOGIN-ENV
  else printf LOGIN; fi
}

N_HUMAN=0; N_OTHER=0; HUMAN_LIST=""; DONE=","  # DONE: the items that printed their line (report-upgrades Phase 6, D5)
add_human() { N_HUMAN=$((N_HUMAN + 1)); HUMAN_LIST="${HUMAN_LIST:+$HUMAN_LIST,}$1"; }

check_platform() {
  local pf="$1" cli parent word login ver st miss stcmd
  case "$pf" in
    claude-code) cli=claude; parent="auth"; word=status; login="claude auth login" ;;
    codex) cli=codex; parent="login"; word=status; login="codex login" ;;
    cursor) cli=cursor-agent; parent=""; word=status; login="cursor-agent login" ;;
    opencode) cli=opencode; parent="auth"; word=list; login="opencode auth login" ;;
  esac
  if ! find_cli "$cli"; then  # PC-FIND
    miss="PRECHECK-MISSING $pf: $cli not found on PATH"
    while IFS= read -r d; do [ -n "$d" ] && miss="$miss ($(show "$d") is a link to a missing file)"; done <<EOF
$DANGLING
EOF
    while IFS= read -r d; do [ -n "$d" ] && miss="$miss ($(show "$d") holds one but was skipped: inside the project or the current directory)"; done <<EOF
$SKIPPED
EOF
    printf '%s\n' "$miss — fix: install $cli or put it on PATH"; DONE="$DONE$pf,"
    add_human "$pf"; return
  fi
  RUN_STDOUT_ONLY=1 run_cmd "$FOUND" --version  # PC-VERSION-RUN
  ver="version unknown"
  if [ "$RC" = "0" ] && [ "$TIMED" = "0" ]; then
    ver="$(version_token "$(printf '%s\n' "$OUT" | head -n 50)")" || ver="version unknown"
  fi
  if [ -n "$parent" ]; then run_cmd "$FOUND" "$parent" --help; stcmd="$cli $parent"; else run_cmd "$FOUND" --help; stcmd="$cli"; fi
  case "$pf" in claude-code) stcmd="$stcmd status --json" ;; *) stcmd="$stcmd $word" ;; esac
  if [ "$TIMED" = "1" ]; then printf '%s\n' "PRECHECK-UNKNOWN $pf: $stcmd gave no known state (timed out after $LIMIT s) — the first run of that CLI will show it"; DONE="$DONE$pf,"; N_OTHER=$((N_OTHER + 1)); return; fi
  _within "$OUT" 400 || OUT=""  # PC-HELP-CAP
  if ! help_has "$(strip_ansi "$OUT")" "${parent:+$cli $parent}" "$word"; then  # PC-HELP-CHECK
    printf '%s\n' "PRECHECK-UNKNOWN $pf: $stcmd gave no known state (no status subcommand in its help) — the first run of that CLI will show it"; DONE="$DONE$pf,"
    N_OTHER=$((N_OTHER + 1)); return
  fi
  case "$pf" in
    claude-code) run_cmd "$FOUND" auth status --json ;;
    codex) run_cmd "$FOUND" login status ;;
    cursor) run_cmd "$FOUND" status ;;
    opencode) run_cmd "$FOUND" auth list ;;
  esac
  if [ "$TIMED" = "1" ]; then printf '%s\n' "PRECHECK-UNKNOWN $pf: $stcmd gave no known state (timed out after $LIMIT s) — the first run of that CLI will show it"; DONE="$DONE$pf,"; N_OTHER=$((N_OTHER + 1)); OUT=""; return; fi
  _within "$OUT" 200 || OUT=""  # PC-STATUS-CAP
  case "$pf" in
    claude-code) st="$(state_claude "$OUT")" ;;
    codex|cursor) st="$(state_lines "$OUT")" ;;
    opencode) st="$(state_opencode "$OUT")" ;;
  esac
  [ -n "$st" ] || st=UNKNOWN  # PC-STATE-USE
  if [ "$st" = OK ] && [ "$RC" != 0 ]; then st=UNKNOWN; fi  # PC-STATE-RC
  OUT=""  # PC-FORGET
  case "$st" in
    OK) printf '%s\n' "PRECHECK-OK $pf: $cli $(show "$ver"), logged in"; DONE="$DONE$pf," ;;
    LOGIN) printf '%s\n' "PRECHECK-LOGIN $pf: not logged in — run: $login"; DONE="$DONE$pf,"; add_human "$pf" ;;
    LOGIN-ENV) printf '%s\n' "PRECHECK-LOGIN $pf: not logged in (only environment-variable providers, billed per use) — run: $login"; DONE="$DONE$pf,"; add_human "$pf" ;;
    *) printf '%s\n' "PRECHECK-UNKNOWN $pf: $stcmd gave no known state (exit $RC) — the first run of that CLI will show it"; DONE="$DONE$pf,"; N_OTHER=$((N_OTHER + 1)) ;;
  esac
}

check_env() {
  local py yv pv hint
  if find_cli python3; then
    py="$FOUND"
    run_cmd "$py" -E -c 'import yaml, sys; sys.stdout.write(yaml.__version__)'  # PC-PYTHON-E
    yv="$OUT"
    if [ "$RC" = "0" ] && [ "$TIMED" = "0" ] && [[ "$yv" =~ ^[0-9][0-9A-Za-z.]*$ ]]; then
      RUN_STDOUT_ONLY=0 run_cmd "$py" -E --version
      pv="$(version_token "$OUT")" || pv="version unknown"
      printf '%s\n' "PRECHECK-OK python3: $(show "$py") $(show "$pv"), PyYAML $(show "$yv")"; DONE="${DONE}python3,"
    else
      hint="python3 -m venv <dir> && <dir>/bin/pip install pyyaml==6.0.3, then put <dir>/bin first on PATH"
      if [ "$py" != "/usr/bin/python3" ] && [ -x /usr/bin/python3 ] && (cd / && xcode-select -p) > /dev/null 2>&1; then
        run_cmd /usr/bin/python3 -E -c 'import yaml, sys; sys.stdout.write(yaml.__version__)'
        if [ "$RC" = "0" ] && [[ "$OUT" =~ ^[0-9][0-9A-Za-z.]*$ ]]; then
          hint="put a directory holding a link python3 -> /usr/bin/python3 (PyYAML $(show "$OUT")) first on PATH"
        fi
      fi
      printf '%s\n' "PRECHECK-FIX python3: $(show "$py") has no PyYAML — fix: $hint"; DONE="${DONE}python3,"
      N_OTHER=$((N_OTHER + 1))  # PC-FIX-COUNT
    fi
  else
    printf '%s\n' "PRECHECK-FIX python3: not found on PATH — fix: install Python 3"; DONE="${DONE}python3,"; N_OTHER=$((N_OTHER + 1))
  fi
  if find_cli node; then
    RUN_STDOUT_ONLY=1 run_cmd "$FOUND" --version
    pv="version unknown"; [ "$RC" = "0" ] && { pv="$(version_token "$OUT")" || pv="version unknown"; }
    printf '%s\n' "PRECHECK-OK node: $(show "$pv")"; DONE="${DONE}node,"
  else
    printf '%s\n' "PRECHECK-FIX node: not found on PATH — fix: install Node.js"; DONE="${DONE}node,"; N_OTHER=$((N_OTHER + 1))
  fi
}

if [ "$GOT_P" = "1" ]; then
  _old_ifs="$IFS"; IFS=','; set -- $PLAT; IFS="$_old_ifs"
  for _p in claude-code codex cursor opencode; do
    case ",$PLAT," in *",$_p,"*) check_platform "$_p" ;; esac
  done
fi
[ "$ENV" = "1" ] && check_env
# D5 (report-upgrades Phase 6): every item asked for (the --platform words, split with globbing off, and python3
# and node for --env) that printed no line of its own counts as other. Top-level code only, no function call,
# so a nesting limit (FUNCNEST) that stopped a check above cannot stop this count.
set -f; ASKED=""; if [ "$GOT_P" = "1" ]; then _old_ifs="$IFS"; IFS=','; for _p in $PLAT; do ASKED="$ASKED $_p"; done; IFS="$_old_ifs"; fi
[ "$ENV" = "1" ] && ASKED="$ASKED python3 node"
for _p in $ASKED; do case "$DONE" in *",$_p,"*) ;; *) printf '%s\n' "PRECHECK-UNKNOWN $_p: no result (the check printed no line for it)"; N_OTHER=$((N_OTHER + 1)) ;; esac; done  # PC-NO-RESULT
set +f

if [ "$N_HUMAN" -gt 0 ]; then printf '%s\n' "PRECHECK: human $HUMAN_LIST"; exit 1; fi
if [ "$N_OTHER" -gt 0 ]; then printf '%s\n' "PRECHECK: other $N_OTHER item(s)"; exit 3; fi
printf '%s\n' "PRECHECK: ok"
exit 0
