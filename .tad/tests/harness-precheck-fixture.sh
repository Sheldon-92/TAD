#!/bin/bash
# harness-precheck-fixture.sh — cases and must-fail variants for .tad/scripts/harness-precheck.sh (report-upgrades Phase 5, D4).
#
# Usage: /bin/bash .tad/tests/harness-precheck-fixture.sh [--script <path to harness-precheck.sh>]
# One sandbox from mktemp -d (refusal tests copied from failure-path-fixture.sh lines 92-111), removed by
# its trap. The script under test runs as a copy inside a fake project; each case gets a fresh TMPDIR, cwd
# and HOME inside the sandbox, and a PATH of shims (claude, codex, cursor-agent, opencode, python3, node,
# git) that log their argv. Shim texts: the help and version texts recorded from the real CLIs on one Mac
# on 2026-11-10 (handoff §4.7; claude 2.1.295, cursor-agent 2026.11.05-86047df, opencode 1.18.32), printed
# verbatim; texts marked `unrecorded` (all of codex; every logged-out status wording; the logged-in status
# shapes, identity replaced) are this fixture's own. Planted secrets are built at run time from pieces.
# Output: `CASE <name> PASS|FAIL`, `VARIANT <name> FAILS-AS-EXPECTED|PASSED` (the real script with one
# line removed or replaced must make its paired case fail), `NOTE …`, last line
# `HARNESS-PRECHECK-FIXTURE: PASS|FAIL`. Exit 0 pass, 1 fail, 2 setup error. Takes about three minutes
# (some cases wait for the time bound). No git, no network, no real harness CLI. bash 3.2 / BSD tools.

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
export LC_ALL=C
# the fixture's own tools (rm, mktemp, grep, awk …) run from the system directories only (rework 1, P0-1)
PATH=/usr/bin:/bin:/usr/sbin:/sbin
NL='
'
case "${TMPDIR:-}" in /*) ;; *) TMPDIR=/tmp ;; esac  # a relative or empty TMPDIR is not used (rework 2)
_rd() { # one absolute directory line or nothing (rework 2: CDPATH is cleared above; an answer with a newline is refused)
  local r; r="$(cd -P -- "$1" > /dev/null 2>&1 && pwd -P && printf x)" || return 1
  r="${r%x}"; r="${r%"$NL"}"; case "$r" in /*) ;; *) return 1 ;; esac; case "$r" in *"$NL"*) return 1 ;; esac; printf '%s' "$r"; }
SELF_DIR="$(_rd "$(dirname "$0")")" || { echo "harness-precheck-fixture: cannot resolve its own directory"; exit 2; }
SCRIPT="$SELF_DIR/../scripts/harness-precheck.sh"
while [ $# -gt 0 ]; do
  case "$1" in
    --script) [ $# -ge 2 ] || { echo "harness-precheck-fixture: --script needs a value"; exit 2; }; SCRIPT="$2"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "harness-precheck-fixture: unknown argument: $1"; exit 2 ;;
  esac
done
[ -f "$SCRIPT" ] || { echo "harness-precheck-fixture: script not found: $SCRIPT"; exit 2; }
REPO="$(_rd "$SELF_DIR/../..")" || exit 2

SB=""; SB_MADE=""; SB_T0="$(date +%s)"
# own_pid <pid file>: prints the pid only while it is still the process this fixture's shim started: the file
# holds `<pid> <expected command>` and the process must run exactly that command and be younger than this run
# (rework 2, P1-B: a recorded pid can be reused by an unrelated process before cleanup signals it)
own_pid() {
  local pid want cmd et d h m sec now
  [ -f "$1" ] || return 1
  IFS=' ' read -r pid want < "$1" || [ -n "${pid:-}" ] || return 1
  case "$pid" in ''|*[!0-9]*) return 1 ;; esac
  cmd="$(ps -o command= -p "$pid" 2>/dev/null)" || return 1
  [ -n "$want" ] && [ "$cmd" = "$want" ] || return 1  # FX-OWN-CMD
  et="$(ps -o etime= -p "$pid" 2>/dev/null | tr -d ' ')"; d=0; h=0
  case "$et" in *-*) d="${et%%-*}"; et="${et#*-}" ;; esac
  case "$et" in *:*:*) h="${et%%:*}"; et="${et#*:}" ;; esac
  m="${et%%:*}"; sec="${et#*:}"
  case "$d$h$m$sec" in ''|*[!0-9]*) return 1 ;; esac
  now="$(date +%s)"
  [ $(( now - (10#$d * 86400 + 10#$h * 3600 + 10#$m * 60 + 10#$sec) )) -ge $(( SB_T0 - 2 )) ] || return 1  # FX-OWN-AGE
  printf '%s' "$pid"
}
kill_own() { local p; p="$(own_pid "$1")" && kill "$p" 2>/dev/null; return 0; }
alive_own() { own_pid "$1" > /dev/null; }
cleanup() {
  if [ -n "$SB_MADE" ] && [ "$SB" = "$SB_MADE" ] && [ -d "$SB_MADE" ]; then
    for f in "$SB_MADE"/c*/resp/*/child.pid "$SB_MADE"/c*/resp/*/detached.pid; do kill_own "$f"; done
    chmod -R u+w "$SB_MADE" 2>/dev/null
    rm -rf "$SB_MADE"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP
_td="$(_rd "${TMPDIR:-/tmp}")" || { echo "harness-precheck-fixture: cannot resolve the temp root ${TMPDIR:-/tmp}"; exit 2; }
case "$_td/" in "$REPO/"*) echo "harness-precheck-fixture: refusing temp root $_td: it is inside the repo (nothing created)"; exit 2 ;; esac
_mk="$(mktemp -d "${TMPDIR:-/tmp}/tad-pc.XXXXXX")" || { echo "harness-precheck-fixture: mktemp -d failed"; exit 2; }
SB="$(_rd "$_mk")" || { echo "harness-precheck-fixture: cannot resolve the sandbox"; rmdir "$_mk" 2>/dev/null; exit 2; }
SB_MADE="$SB"
refuse() { echo "harness-precheck-fixture: refusing sandbox $SB: $1"; SB_MADE=""; rmdir "$_mk" 2>/dev/null; exit 2; }
[ -n "$SB" ] || refuse "empty path"
[ "$SB" != "/" ] || refuse "it is /"
[ "$SB" != "$REPO" ] || refuse "it is the repo"
case "$REPO/" in "$SB/"*) refuse "it is an ancestor of the repo" ;; esac
case "$SB/" in "$REPO/"*) refuse "it is inside the repo" ;; esac
case "$SB" in *'"'*|*'$'*|*'`'*|*'\'*|*"'"*) refuse "its path holds a quote, \$, a backtick or a backslash (the shims embed it)" ;; esac
HOME_P=""
if [ -n "${HOME:-}" ] && [ -d "$HOME" ]; then HOME_P="$(_rd "$HOME")" || HOME_P=""; fi
if [ -n "$HOME_P" ]; then
  [ "$SB" != "$HOME_P" ] || refuse "it is \$HOME"
  case "$HOME_P/" in "$SB/"*) refuse "it is an ancestor of \$HOME" ;; esac
fi

PROJ="$SB/proj"; mkdir -p "$PROJ/.tad/scripts" "$PROJ/bin" "$SB/rec" || exit 2
UNDER="$PROJ/.tad/scripts/harness-precheck.sh"; cp "$SCRIPT" "$UNDER" || exit 2
printf '#!/bin/sh\nprintf "%%s\\n" "git $*" >> "%s"\nexit 1\n' "$SB/git.log" > "$SB/git"; chmod +x "$SB/git"; : > "$SB/git.log"
R="$$$(date +%S)"
S1="sk-ant""-oat01-FIXTURE$R"; S2="gh""p_FIXTURE$R"; EM="fixture-user""@""example"".invalid"; ORG="org-FIXTURE$R"
ESC="$(printf '\033')"

# --- recorded texts (§4.7) --------------------------------------------------------------------------
cat > "$SB/rec/claude.help" <<'EOF'
Usage: claude auth [options] [command]

Manage authentication

Options:
  -h, --help        Display help for command

Commands:
  help [command]    display help for command
  login [options]   Sign in to your Anthropic account
  logout            Log out from your Anthropic account
  status [options]  Show authentication status
EOF
# recorded: lines 1-9 and 64-96 of the 96-line `cursor-agent --help`
cat > "$SB/rec/cursor.help" <<'EOF'
Usage: agent [options] [command] [prompt...]

Start the Cursor Agent

Arguments:
  prompt                       Initial prompt for the agent

Options:
  -v, --version                Output the version number
  --skip-worktree-setup        Skip running worktree setup scripts from
                               .cursor/worktrees.json (default: false)
  -h, --help                   Display help for command

Commands:
  persist                      Start or manage a session that survives terminal
                               disconnects
  install-shell-integration    Install shell integration to ~/.zshrc
  uninstall-shell-integration  Remove shell integration from ~/.zshrc
  login                        Authenticate with Cursor. Set NO_OPEN_BROWSER to
                               disable browser opening.
  logout                       Sign out and clear stored authentication
  mcp                          Manage MCP servers
  plugin                       Manage plugins and plugin marketplaces
  worker [options]             Run a self-hosted Cloud Agent worker that
                               connects to Cursor and executes agent tool calls
                               on this machine. Without --pool it is a personal
                               My Machines worker (no Enterprise plan needed);
                               with --pool it joins a team Self-Hosted Pool
                               (Enterprise plan + service account API key).
  status|whoami [options]      View authentication status
  models                       List available models for this account
  team                         View or switch the active team for this account
  bedrock                      Configure AWS Bedrock usage for CLI
  about [options]              Display version, system, and account information
  update [options]             Update Cursor Agent to the latest version
  create-chat                  Create a new empty chat and return its ID
  generate-rule|rule           Generate a new Cursor rule with interactive
                               prompts
  agent [prompt...]            Start the Cursor Agent
  ls                           Resume a chat session
  resume                       Resume the latest chat session
  help [command]               Display help for command
EOF
# recorded with ANSI removed; the shim colours the heading again
cat > "$SB/rec/opencode.help" <<'EOF'
opencode providers

manage AI providers and credentials

Commands:
  opencode auth list               list providers and credentials                      [aliases: ls]
  opencode auth login [url]        log in to a provider
  opencode auth logout [provider]  log out from a configured provider

Options:
  -h, --help        show help                                                              [boolean]
  -v, --version     show version number                                                    [boolean]
      --print-logs  print logs to stderr                                                   [boolean]
      --log-level   log level                   [string] [choices: "DEBUG", "INFO", "WARN", "ERROR"]
      --pure        run without external plugins                                           [boolean]
EOF
# unrecorded (codex is a dangling link on the recording Mac): a help in the claude shape
cat > "$SB/rec/codex.help" <<'EOF'
Usage: codex login [OPTIONS] [COMMAND]

Commands:
  status  Show login status
  help    Print this message or the help of the given subcommand(s)
EOF
sed "s/^Commands:/${ESC}[1mCommands:${ESC}[0m/" "$SB/rec/opencode.help" > "$SB/rec/opencode.help.ansi"

# --- per case -----------------------------------------------------------------------------------------
CN=0; C=""
CLIS="claude codex cursor-agent opencode"
setr() { printf '%s\n' "$3" > "$C/resp/$1/$2"; }   # setr <cli> <version|help|status> <text>
setrc() { printf '%s\n' "$3" > "$C/resp/$1/$2.rc"; }
newc() {
  CN=$((CN + 1)); C="$SB/c$CN"; FAILS=""
  mkdir -p "$C/bin" "$C/log" "$C/home" "$C/tmp" "$C/cwd" || exit 2
  local x
  for x in $CLIS; do
    mkdir -p "$C/resp/$x"
    cat > "$C/bin/$x" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >> "$C/log/$x.log"
d="$C/resp/$x"
case "\$*" in --version) f=version ;; *--help) f=help ;; *) f=status ;; esac
printf 'planted %s %s %s\n' "$S1" "$EM" "$C/home" >&2
if [ -f "\$d/\$f.sleep" ]; then n="\$(cat "\$d/\$f.sleep")"; sleep "\$n" & echo "\$! sleep \$n" > "\$d/child.pid"; sleep "\$n"; fi
if [ -f "\$d/\$f.linger" ]; then n="\$(cat "\$d/\$f.linger")"; sleep "\$n" & echo "\$! sleep \$n" > "\$d/child.pid"; fi
if [ -f "\$d/\$f.instant" ]; then n="\$(cat "\$d/\$f.instant")"; ( sleep "\$n" & echo "\$! sleep \$n" > "\$d/instant.\$!" ) & fi
if [ -f "\$d/\$f.detach" ]; then /usr/bin/perl -e 'use POSIX; POSIX::setsid(); open(F, ">", \$ARGV[0]) or exit 1; print F "\$\$ /bin/sleep \$ARGV[1]\\n"; close F; exec "/bin/sleep", \$ARGV[1];' "\$d/detached.pid" "\$(cat "\$d/\$f.detach")" & i=0; while [ ! -s "\$d/detached.pid" ] && [ \$i -lt 100 ]; do i=\$((i + 1)); sleep 0.05; done; fi
[ -f "\$d/\$f" ] && cat "\$d/\$f"
exit "\$(cat "\$d/\$f.rc" 2>/dev/null || echo 0)"
EOF
    chmod +x "$C/bin/$x"
  done
  cp "$SB/git" "$C/bin/git"
  cp "$SB/rec/claude.help" "$C/resp/claude/help"; cp "$SB/rec/codex.help" "$C/resp/codex/help"
  cp "$SB/rec/cursor.help" "$C/resp/cursor-agent/help"; cp "$SB/rec/opencode.help.ansi" "$C/resp/opencode/help"
  setr claude version "2.1.295 (Claude Code)"; setr cursor-agent version "2026.11.05-86047df"; setr opencode version "1.18.32"
  setr codex version "codex-cli 0.162.1"
  setr claude status "{\"loggedIn\": true, \"authMethod\": \"claude.ai\", \"email\": \"$EM\", \"orgId\": \"$ORG\", \"token\": \"$S1\", \"analyticsDisabled\": false}"
  setr codex status "Logged in using ChatGPT$(printf '\n')account $EM $S2"
  setr cursor-agent status "✓ Logged in as $EM"
  setr opencode status "┌  Credentials ~/.local/share/opencode/auth.json
│
●  OpenCode Go api $S2
│
└  ${ESC}[1m1 credentials${ESC}[0m"
  PCPATH="$C/bin:/usr/bin:/bin"
}
logout_all() {
  setr claude status "{\"loggedIn\": false, \"authMethod\": \"none\", \"analyticsDisabled\": true, \"orgId\": \"$ORG\"}"
  setr codex status "Not logged in"
  setr cursor-agent status "✗ Not logged in"
  setr opencode status "┌  Credentials ~/.local/share/opencode/auth.json
│
└  0 credentials"
}
# pc <args>: run the script under test; OUTF, RC, EL (seconds)
pc() { pcrun /bin/bash ${PCX:-} "${PCSELF:-$UNDER}" "$@"; }
pcrun() {
  local s=$SECONDS
  OUTF="$C/out.$SECONDS.$RANDOM"
  ( cd "${PCCWD:-$C/cwd}" && HOME="$C/home" TMPDIR="$C/tmp" PATH="$PCPATH" /usr/bin/env ${PCENV:+"$PCENV"} ${PCENV2:+"$PCENV2"} "$@" ) > "$OUTF" 2>&1
  RC=$?; EL=$((SECONDS - s))
  cat "$OUTF" >> "$SB/all.out"
}
nf() { FAILS="${FAILS}${FAILS:+; }$1"; }
has() { grep -qxF -- "$1" "$OUTF" || nf "no line '$1'"; }
cnt() { grep -c -- "$1" "$OUTF"; }
ALLP="claude-code,codex,cursor,opencode"

c_logged_in() { newc; pc --platform "$ALLP"
  [ "$RC" = 0 ] || nf "exit $RC"; [ "$(cnt '^PRECHECK-OK ')" = 4 ] || nf "not four OK lines"; has "PRECHECK: ok"; }
c_login_needed() {
  newc; setr claude status "{\"loggedIn\": false, \"authMethod\": \"none\", \"analyticsDisabled\": true}"; pc --platform "$ALLP"
  [ "$RC" = 1 ] || nf "one: exit $RC"; [ "$(cnt '^PRECHECK-LOGIN ')" = 1 ] || nf "one: not one LOGIN line"
  has "PRECHECK-LOGIN claude-code: not logged in — run: claude auth login"; has "PRECHECK: human claude-code"
  newc; setr codex status "Not logged in"; setr cursor-agent status "✗ Not logged in"; pc --platform "$ALLP"
  [ "$RC" = 1 ] || nf "two: exit $RC"; [ "$(cnt '^PRECHECK-LOGIN ')" = 2 ] || nf "two: not two LOGIN lines"
  has "PRECHECK-LOGIN codex: not logged in — run: codex login"; has "PRECHECK-LOGIN cursor: not logged in — run: cursor-agent login"
  newc; logout_all; pc --platform "$ALLP"
  [ "$RC" = 1 ] || nf "four: exit $RC"; [ "$(cnt '^PRECHECK-LOGIN ')" = 4 ] || nf "four: not four LOGIN lines"
  has "PRECHECK-LOGIN opencode: not logged in — run: opencode auth login"; has "PRECHECK: human claude-code,codex,cursor,opencode"
}
c_missing() { newc; rm -f "$C/bin/codex"; pc --platform codex
  [ "$RC" = 1 ] || nf "exit $RC"; has "PRECHECK-MISSING codex: codex not found on PATH — fix: install codex or put it on PATH"; }
c_broken_link() { newc; rm -f "$C/bin/codex"; mkdir -p "$C/home/.local/bin"; ln -s "$C/home/gone/codex" "$C/home/.local/bin/codex"
  PCPATH="$C/home/.local/bin:$C/bin:/usr/bin:/bin"; pc --platform codex
  [ "$RC" = 1 ] || nf "exit $RC"; has "PRECHECK-MISSING codex: codex not found on PATH (~/.local/bin/codex is a link to a missing file) — fix: install codex or put it on PATH"; }
c_unknown() { newc; setr claude status '{"something": 1}'; pc --platform claude-code
  [ "$RC" = 3 ] || nf "exit $RC"; has "PRECHECK-UNKNOWN claude-code: claude auth status --json gave no known state (exit 0) — the first run of that CLI will show it"; has "PRECHECK: other 1 item(s)"; }
c_timeout() { newc; echo 12 > "$C/resp/claude/status.sleep"; PCENV="PRECHECK_TIMEOUT=2" pc --platform claude-code
  [ "$RC" = 3 ] || nf "exit $RC"; [ "$EL" -le 7 ] || nf "took $EL s"
  has "PRECHECK-UNKNOWN claude-code: claude auth status --json gave no known state (timed out after 2 s) — the first run of that CLI will show it"
  sleep 1; alive_own "$C/resp/claude/child.pid" && { nf "the child that held the pipe is still running"; kill_own "$C/resp/claude/child.pid"; }; }
c_total_cap() { newc; echo 12 > "$C/resp/claude/status.sleep"; echo 12 > "$C/resp/cursor-agent/status.sleep"
  PCENV="PRECHECK_TIMEOUT=3" PCENV2="PRECHECK_TOTAL=5" pc --platform claude-code,cursor
  PCENV2=""; [ "$EL" -le 9 ] || nf "took $EL s"; [ "$(cnt '^PRECHECK-UNKNOWN .*(timed out after [0-9]* s)')" = 2 ] || nf "not two timed-out lines"
  # rework 1, F1: the whole-run cap (5 s) leaves the second command less than its 3 s bound
  [ "$EL" -le 7 ] || nf "took $EL s, the cap is 5 s"
  grep -qE '^PRECHECK-UNKNOWN cursor: cursor-agent status gave no known state \(timed out after [12] s\)' "$OUTF" || nf "the second command did not get the time left under the cap: $(grep '^PRECHECK-UNKNOWN cursor' "$OUTF")"; }
c_timeout_child_left() { newc; echo 25 > "$C/resp/claude/status.linger"; PCENV="PRECHECK_TIMEOUT=3" pc --platform claude-code; PCENV=""
  # rework 1, F2: the status command exits at once and leaves a child holding its output
  [ "$EL" -le 8 ] || nf "took $EL s with a 3 s bound"
  sleep 1; alive_own "$C/resp/claude/child.pid" && { nf "the child that held the pipe is still running"; kill_own "$C/resp/claude/child.pid"; }; }
c_cwd_ancestor() { newc; mkdir -p "$C/home/.local/bin"; mv "$C/bin/claude" "$C/home/.local/bin/claude"
  # rework 1, F3: a CLI under the start directory (not equal to it) is found (D1: "equals the start directory")
  PCPATH="$C/home/.local/bin:$C/bin:/usr/bin:/bin"; PCCWD="$C/home" pc --platform claude-code
  has "PRECHECK-OK claude-code: claude 2.1.295, logged in"
  PCCWD="$C/home/.local" pc --platform claude-code; has "PRECHECK-OK claude-code: claude 2.1.295, logged in"
  PCPATH="$C/home/.local/bin:/usr/bin:/bin"; PCCWD="$C/home/.local/bin" pc --platform claude-code
  grep -q '^PRECHECK-MISSING claude-code: claude not found on PATH (~/.local/bin holds one but was skipped' "$OUTF" || nf "the start directory itself was not skipped"; }
c_state_exit_nonzero() { newc; setr claude status '{"loggedIn": true}'; setrc claude status 1; setr codex status "Logged in using ChatGPT"; setrc codex status 1
  # rework 1, P1-2: OK needs exit 0
  pc --platform claude-code,codex
  [ "$RC" = 3 ] || nf "exit $RC"; [ "$(cnt '^PRECHECK-OK ')" = 0 ] || nf "an OK line"
  has "PRECHECK-UNKNOWN claude-code: claude auth status --json gave no known state (exit 1) — the first run of that CLI will show it"
  has "PRECHECK-UNKNOWN codex: codex login status gave no known state (exit 1) — the first run of that CLI will show it"; }
c_state_no_boundary() { newc; setr claude status '{"loggedIn": truex}'; setr codex status "Logged inactive"
  setr opencode status "┌  Credentials ~/.local/share/opencode/auth.json
│
└  08 credentials"
  # rework 1, P1-2: the token must end where the word ends
  pc --platform claude-code,codex,opencode
  [ "$(cnt '^PRECHECK-OK ')" = 0 ] || nf "an OK line: $(grep '^PRECHECK-OK ' "$OUTF" | head -1)"; [ "$(cnt '^PRECHECK-UNKNOWN ')" = 3 ] || nf "not three UNKNOWN lines"; }
c_state_expired() { newc; setr claude status '{"loggedIn": true, "error": "token expired"}'; setr cursor-agent status "Logged in but token expired, run cursor-agent login"
  # rework 1, P1-2: a status text that names an expiry is not reported as fine
  pc --platform claude-code,cursor
  [ "$(cnt '^PRECHECK-OK ')" = 0 ] || nf "an OK line: $(grep '^PRECHECK-OK ' "$OUTF" | head -1)"; [ "$(cnt '^PRECHECK-UNKNOWN ')" = 2 ] || nf "not two UNKNOWN lines"; }
c_help_flood() { newc
  # rework 1, P1-3: a 20000-line help is not parsed (UNKNOWN), and the run stays short
  awk 'BEGIN { print "Commands:"; for (i = 0; i < 20000; i++) print "  persist                      Start or manage a session"; print "  status|whoami [options]      View authentication status" }' > "$C/resp/cursor-agent/help"
  pc --platform cursor
  [ "$EL" -le 10 ] || nf "took $EL s"
  has "PRECHECK-UNKNOWN cursor: cursor-agent status gave no known state (no status subcommand in its help) — the first run of that CLI will show it"; nostatus cursor-agent "status"; }
c_status_flood() { newc
  awk 'BEGIN { for (i = 0; i < 20000; i++) print "  noise line"; print "Logged in as someone" }' > "$C/resp/cursor-agent/status"
  pc --platform cursor
  [ "$EL" -le 10 ] || nf "took $EL s"
  has "PRECHECK-UNKNOWN cursor: cursor-agent status gave no known state (exit 0) — the first run of that CLI will show it"; }
c_utf8_cut() { local h; newc; rm -f "$C/bin/codex"
  # rework 1, P1-4: a printed path cut at 60 bytes never ends inside a UTF-8 character
  h="$C/home/$(printf '%050d' 0 | tr 0 a)云云云云/bin"; mkdir -p "$h"; ln -s "$C/home/gone/codex" "$h/codex"
  PCPATH="$h:$C/bin:/usr/bin:/bin"; pc --platform codex
  grep -q '^PRECHECK-MISSING codex: codex not found on PATH (~/aaaa' "$OUTF" || nf "no MISSING line naming the link"
  iconv -f UTF-8 -t UTF-8 < "$OUTF" > /dev/null 2>&1 || nf "the output is not valid UTF-8"; }
c_env_no_yaml() { newc
  printf '#!/bin/sh\ncase "$*" in *yaml*) echo "ModuleNotFoundError: No module named yaml" >&2; exit 1 ;; esac\necho "Python 3.14.4"\n' > "$C/bin/python3"
  printf '#!/bin/sh\necho v22.0.0\n' > "$C/bin/node"; chmod +x "$C/bin/python3" "$C/bin/node"; pc --env
  [ "$RC" = 3 ] || nf "exit $RC"; grep -q '^PRECHECK-FIX python3: .* has no PyYAML — fix: ' "$OUTF" || nf "no FIX python3 line"
  has "PRECHECK-OK node: v22.0.0"; [ "$(grep -cE '^PRECHECK-(OK|LOGIN|MISSING|UNKNOWN) (claude-code|codex|cursor|opencode):' "$OUTF")" = 0 ] || nf "a harness line"; }
c_env_key_only() { newc; setr opencode status "┌  Credentials ~/.local/share/opencode/auth.json
│
└  0 credentials

┌  Environment
│
●  DashScope DASHSCOPE_API_KEY
└  1 environment variable"; pc --platform opencode
  [ "$RC" = 1 ] || nf "exit $RC"; has "PRECHECK-LOGIN opencode: not logged in (only environment-variable providers, billed per use) — run: opencode auth login"; }
nostatus() { grep -qxF -- "$2" "$C/log/$1.log" 2>/dev/null && nf "status argv '$2' was run"; }
c_unsupported_subcommand() { newc; setr claude help "Commands:
  help [command]    display help for command
  login [options]   Sign in to your Anthropic account"; pc --platform claude-code
  has "PRECHECK-UNKNOWN claude-code: claude auth status --json gave no known state (no status subcommand in its help) — the first run of that CLI will show it"; nostatus claude "auth status --json"; }
c_help_prose_only() { newc; setr claude help "Commands:
  login [options]   Sign in; shows the status of the login
  whoami            Print the status of your account"; pc --platform claude-code
  grep -q '^PRECHECK-UNKNOWN claude-code: .*(no status subcommand in its help)' "$OUTF" || nf "no UNKNOWN line"; nostatus claude "auth status --json"; }
c_help_wrapped_continuation() { newc; setr cursor-agent help "Options:
  status                       an option line that is not a command
Commands:
  login                        Authenticate with Cursor and print the
                               status
  logout                       Sign out"; pc --platform cursor
  grep -q '^PRECHECK-UNKNOWN cursor: .*(no status subcommand in its help)' "$OUTF" || nf "no UNKNOWN line"; nostatus cursor-agent "status"; }
c_hostile_version() { newc; setr claude version "error: cannot read $C/home/.claude/x $S1"; setrc claude version 1; pc --platform claude-code
  has "PRECHECK-OK claude-code: claude version unknown, logged in"; grep -qF -e "$S1" -e "$C/home" "$OUTF" && nf "planted text printed"; }
c_hostile_version_exit0() { newc; setr claude version "1.2.3 $C/home/x $S1 $EM"; pc --platform claude-code
  has "PRECHECK-OK claude-code: claude 1.2.3, logged in"; grep -qF -e "$S1" -e "$EM" -e "/x" "$OUTF" && nf "more than the token printed"; }
c_version_real() { newc; pc --platform "$ALLP"
  has "PRECHECK-OK claude-code: claude 2.1.295, logged in"; has "PRECHECK-OK cursor: cursor-agent 2026.11.05-86047df, logged in"
  has "PRECHECK-OK opencode: opencode 1.18.32, logged in"; has "PRECHECK-OK codex: codex 0.162.1, logged in"; }
help_real() { newc; pc --platform "$1"
  [ "$(grep -cxF -- "$3" "$C/log/$2.log" 2>/dev/null)" = 1 ] || nf "status argv '$3' not logged once"; grep -q "^PRECHECK-OK $1: " "$OUTF" || nf "state not read"; }
c_help_real_claude() { help_real claude-code claude "auth status --json"; }
c_help_real_cursor() { help_real cursor cursor-agent "status"; }
c_help_real_opencode() { help_real opencode opencode "auth list"; }
c_timeout_nondigit() { newc; PCENV="PRECHECK_TIMEOUT=x[\$(touch $C/MARK; echo 0)]"
  pc --platform claude-code; [ ! -e "$C/MARK" ] || { nf "the value ran a command"; return; }
  has "PRECHECK-OK claude-code: claude 2.1.295, logged in"
  echo 25 > "$C/resp/claude/status.sleep"; PCENV="PRECHECK_TIMEOUT=1234567890123456789012345"; pc --platform claude-code
  grep -q '(timed out after 20 s)' "$OUTF" || nf "25 digits: the bound 20 was not used"; PCENV=""; }
c_timeout_leading_zero() { newc; echo 15 > "$C/resp/claude/status.sleep"; PCENV="PRECHECK_TIMEOUT=0009"; pc --platform claude-code; PCENV=""
  grep -q '(timed out after 9 s)' "$OUTF" || nf "0009 not read as 9"; }
c_status_only() { local x a; newc; pc --platform "$ALLP"; logout_all; pc --platform "$ALLP"
  for x in $CLIS; do
    while IFS= read -r a; do
      case "$x:$a" in claude:--version|"claude:auth --help"|"claude:auth status --json"|codex:--version|"codex:login --help"|"codex:login status"|cursor-agent:--version|cursor-agent:--help|cursor-agent:status|opencode:--version|"opencode:auth --help"|"opencode:auth list") ;;
        *) nf "$x ran '$a'" ;; esac
    done < "$C/log/$x.log"
  done; }
PYOK=0; [ -x /usr/bin/python3 ] && (cd / && xcode-select -p) > /dev/null 2>&1 && PYOK=1
c_path_hostile() { newc; local p
  printf '#!/bin/sh\ntouch "%s/MARK"\necho 2.1.295\n' "$SB" > "$PROJ/claude"; chmod +x "$PROJ/claude"
  cp "$PROJ/claude" "$PROJ/bin/claude"; mkdir -p "$C/clean"; cp "$PROJ/claude" "$C/cwd/claude"
  ln -s "$PROJ" "$C/plink"; ln -s "$PROJ/bin/claude" "$C/clean/claude"; rm -f "$C/bin/claude"
  PCPATH="$PROJ::.:$C/plink:$PROJ/bin/..:$C/cwd:$C/clean:$C/bin:/usr/bin:/bin"; pc --platform claude-code
  grep -q '^PRECHECK-MISSING claude-code: claude not found on PATH' "$OUTF" || nf "claude not reported missing"
  if [ "$PYOK" = 1 ]; then
    mkdir -p "$C/py" "$C/pp"; ln -s /usr/bin/python3 "$C/py/python3"
    printf 'open("%s/MARK", "w").write("x")\n' "$SB" > "$C/pp/yaml.py"; cp "$C/pp/yaml.py" "$C/cwd/yaml.py"
    PCPATH="$C/py:/bin"; PCENV="PYTHONPATH=$C/pp"; pc --env; PCENV=""
    grep -q '^PRECHECK-FIX python3: /usr/bin/python3 has no PyYAML' "$OUTF" || nf "the python part did not run as expected: $(head -1 "$OUTF")"
  fi
  [ ! -e "$SB/MARK" ] || nf "a planted executable or module ran"; rm -f "$SB/MARK" "$PROJ/claude" "$PROJ/bin/claude" "$C/cwd/claude"; }
c_no_secret() { local f; newc; : > "$SB/ns.out"
  for f in logged_in login_needed broken_link hostile_version hostile_version_exit0; do CN=$((CN + 5)); ( "c_$f" ) > /dev/null 2>&1; done
  newc; PCX="-x" pc --platform "$ALLP"; PCX=""
  cat "$SB/all.out" >> "$SB/ns.out"
  grep -qF -e "$S1" -e "$S2" -e "$EM" -e "$ORG" "$SB/ns.out" && nf "a planted secret was printed"
  grep -qE "$SB/c[0-9]+/home" "$SB/ns.out" && nf "a sandbox HOME path was printed raw"
  grep -qF -e "@" "$SB/ns.out" && nf "an @ was printed: $(grep -F -m1 "@" "$SB/ns.out" | cut -c1-200)"
  grep -qF '(~/.local/bin/codex is a link to a missing file)' "$SB/ns.out" || nf "the HOME path was not shown as ~"; }
c_no_residue() { local r; newc
  for r in "--platform $ALLP" "--platform claude-code:logout" "--platform claude-code:sleep" "--bogus"; do
    case "$r" in *:logout) logout_all ;; *:sleep) echo 5 > "$C/resp/claude/status.sleep"; PCENV="PRECHECK_TIMEOUT=1" ;; esac
    pc ${r%%:*}; PCENV=""
    [ -z "$(ls -A "$C/tmp")" ] || nf "TMPDIR not empty after '$r'"; [ -z "$(ls -A "$C/cwd")" ] || nf "cwd not empty after '$r'"
  done; }

# --- rework 2: the environment the script inherits (P0 class) and the bound after the CLI exits (P1-A) -----
plant_bin() { # a claude inside the project, on an absolute PATH entry: it must never run
  printf '#!/bin/sh\ntouch "%s/MARK"\ncase "$*" in --version) echo 9.9.9 ;; *--help) printf "Commands:\\n  status  x\\n" ;; *) echo "{\\"loggedIn\\": true}" ;; esac\n' "$SB" > "$PROJ/bin/claude"; chmod +x "$PROJ/bin/claude"; rm -f "$C/bin/claude"; }
c_cdpath_hostile() { local cdp; newc; plant_bin; mkdir -p "$C/other/.tad/scripts" "$C/home/x"
  # started by a relative path from the project root, as the guide says; CDPATH would move or double the root
  for cdp in "$C/other" ".:$C/home" "$C/home:." ; do
    PCPATH="$PROJ/bin:$C/bin:/usr/bin:/bin"; PCCWD="$PROJ"; PCSELF=".tad/scripts/harness-precheck.sh"; PCENV="CDPATH=$cdp"; pc --platform claude-code
    grep -q '^PRECHECK-MISSING claude-code: claude not found on PATH' "$OUTF" || nf "CDPATH=$cdp: not MISSING: $(head -1 "$OUTF")"
    [ ! -e "$SB/MARK" ] || { nf "CDPATH=$cdp: the planted claude ran"; rm -f "$SB/MARK"; }
  done; PCSELF=""; PCENV=""; PCCWD=""; rm -f "$PROJ/bin/claude"; }
c_exported_functions() { local f a=""; newc; plant_bin
  # functions named after tools and builtins the script uses, exported by the caller: none may run
  for f in rm grep sed dirname basename tr cut wc head iconv kill ps cd pwd; do
    a="$a BASH_FUNC_$f%%=() { touch $SB/FMARK-$f; return 0; }"
  done
  PCPATH="$PROJ/bin:$C/bin:/usr/bin:/bin"; PCCWD="$PROJ"
  IFS='|'; set -f; pcrun $(printf '%s' "${a# }" | sed 's/ BASH_FUNC_/|BASH_FUNC_/g') /bin/bash .tad/scripts/harness-precheck.sh --platform claude-code,cursor; set +f; IFS=' 	
'
  grep -q '^PRECHECK-MISSING claude-code: claude not found on PATH' "$OUTF" || nf "claude-code not MISSING: $(head -1 "$OUTF")"
  has "PRECHECK-OK cursor: cursor-agent 2026.11.05-86047df, logged in"
  [ -z "$(ls "$SB" | grep '^FMARK-')" ] || nf "an exported function ran: $(ls "$SB" | grep '^FMARK-' | tr '\n' ' ')"
  [ ! -e "$SB/MARK" ] || nf "the planted claude ran"; rm -f "$SB"/FMARK-* "$SB/MARK" "$PROJ/bin/claude"; PCCWD=""; }
c_env_hostile() { local rc; newc; plant_bin
  # GLOBIGNORE, SHELLOPTS (noglob, errexit, allexport), POSIXLY_CORRECT and a closed stdin are closed by the script
  PCPATH="$PROJ/bin:$C/bin:/usr/bin:/bin"; PCCWD="$PROJ"
  pcrun GLOBIGNORE='*' SHELLOPTS=noglob:errexit:allexport POSIXLY_CORRECT=1 /bin/bash .tad/scripts/harness-precheck.sh --platform claude-code,cursor,opencode <&-
  grep -q '^PRECHECK-MISSING claude-code: claude not found on PATH' "$OUTF" || nf "claude-code not MISSING: $(head -1 "$OUTF")"
  has "PRECHECK-OK cursor: cursor-agent 2026.11.05-86047df, logged in"; has "PRECHECK-OK opencode: opencode 1.18.32, logged in"
  [ ! -e "$SB/MARK" ] || nf "the planted claude ran"; rm -f "$SB/MARK"
  # a closed stdout: the script stops before it runs anything
  : > "$C/log/cursor-agent.log"
  ( cd "$PROJ" && HOME="$C/home" PATH="$PCPATH" /bin/bash .tad/scripts/harness-precheck.sh --platform cursor >&- 2>/dev/null ); rc=$?
  [ "$rc" = 2 ] || nf "closed stdout: exit $rc"; [ ! -s "$C/log/cursor-agent.log" ] || nf "closed stdout: a CLI ran"
  rm -f "$PROJ/bin/claude"; PCCWD=""; }
c_instant_exit_helper() { local i slow=0 left=0 f; newc; echo 8 > "$C/resp/claude/status.instant"
  # the status command forks a helper in the instant it exits (the helper races the group sweep): 20 runs,
  # each within the bound, and no helper left alive afterwards
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    PCENV="PRECHECK_TIMEOUT=2" PCENV2="PRECHECK_TOTAL=3" pc --platform claude-code
    [ "$EL" -le 6 ] || slow=$((slow + 1))
  done; PCENV=""; PCENV2=""
  sleep 1; for f in "$C"/resp/claude/instant.*; do alive_own "$f" && { left=$((left + 1)); kill_own "$f"; }; done
  [ "$slow" = 0 ] || nf "$slow of 20 runs took more than 6 s"; [ "$left" = 0 ] || nf "$left helpers still alive"; }
c_detached_helper() { newc
  [ -x /usr/bin/perl ] || { nf "no /usr/bin/perl here: a helper that leaves its session cannot be made"; return; }
  # the status command starts a helper that leaves its session (setsid) holding the output pipe, then exits
  echo 25 > "$C/resp/claude/status.detach"; PCENV="PRECHECK_TIMEOUT=3" pc --platform claude-code; PCENV=""
  # the run ends when the CLI does, not at the deadline (3 + 5 s) and not when the helper lets go (25 s)
  [ "$EL" -le 4 ] || nf "took $EL s with a 3 s bound"
  has "PRECHECK-OK claude-code: claude 2.1.295, logged in"
  sleep 1; [ -f "$C/resp/claude/detached.pid" ] || nf "the detached helper did not start"
  kill_own "$C/resp/claude/detached.pid"; }

# --- report-upgrades Phase 6: the nesting limit (D5), the no-result count (D5), the usage block (D7), the platform word (D10) ---
# bash_42: the first of an absolute list (no PATH search) that is executable, whose resolved file is a regular file owned
# by the caller or root and not writable by group or other, and whose BASH_VERSINFO, read under an empty environment, is
# at least 4.2; none -> empty, and the cases that need it print `CASE <n> SKIP: no bash >= 4.2`
bash_42() {
  local b f l i m v uid
  uid="$(id -u)"
  for b in /opt/homebrew/bin/bash /usr/local/bin/bash /bin/bash /usr/bin/bash; do
    [ -x "$b" ] || continue
    f="$b"; i=0
    while [ -L "$f" ] && [ "$i" -lt 40 ]; do l="$(readlink "$f")"; case "$l" in /*) f="$l" ;; *) f="$(dirname "$f")/$l" ;; esac; i=$((i + 1)); done
    [ -f "$f" ] && [ ! -L "$f" ] || continue
    set -- $(ls -ldn "$f" 2>/dev/null)
    [ $# -ge 3 ] || continue
    m="$1"; [ "$3" = "$uid" ] || [ "$3" = 0 ] || continue
    case "$m" in -*) ;; *) continue ;; esac
    case "$m" in -????w*|-???????w*) continue ;; esac  # group or other may write it
    v="$(/usr/bin/env -i "$f" -c 'printf "%s %s" "${BASH_VERSINFO[0]}" "${BASH_VERSINFO[1]}"' 2>/dev/null)" || continue
    case "$v" in [0-9]*' '[0-9]*) ;; *) continue ;; esac
    if [ "${v% *}" -gt 4 ] || { [ "${v% *}" = 4 ] && [ "${v#* }" -ge 2 ]; }; then printf '%s' "$f"; return 0; fi
  done
  return 1
}
B42="$(bash_42)" || B42=""
B42CASES="funcnest-cleared no-result-counted env-no-result-counted"
c_funcnest_cleared() { newc; rm -f "$C/bin/codex"; pcrun FUNCNEST=1 "$B42" "$UNDER" --platform codex
  [ "$RC" = 1 ] || nf "exit $RC"; grep -q '^PRECHECK-MISSING codex: ' "$OUTF" || nf "no PRECHECK-MISSING codex line: $(head -1 "$OUTF")"; }
nr_copy() { # the script under test without the three names in its ENV-UNSET line: a check stops at the nesting limit
  sed 's/ FUNCNEST BASH_COMPAT EXECIGNORE  # ENV-UNSET$/  # ENV-UNSET/' "$UNDER" > "$PROJ/.tad/scripts/hp-nr.sh"; }
c_no_result_counted() { newc; nr_copy; pcrun FUNCNEST=1 "$B42" "$PROJ/.tad/scripts/hp-nr.sh" --platform codex
  grep -q 'maximum function nesting level' "$OUTF" || nf "the copy did not stop at the nesting limit (this bash: $B42)"
  [ "$RC" = 3 ] || nf "exit $RC"; has "PRECHECK-UNKNOWN codex: no result (the check printed no line for it)"
  [ "$(tail -1 "$OUTF")" = "PRECHECK: other 1 item(s)" ] || nf "last line: $(tail -1 "$OUTF")"; rm -f "$PROJ/.tad/scripts/hp-nr.sh"; }
c_env_no_result_counted() { newc; nr_copy; pcrun FUNCNEST=1 "$B42" "$PROJ/.tad/scripts/hp-nr.sh" --env
  grep -q 'maximum function nesting level' "$OUTF" || nf "the copy did not stop at the nesting limit (this bash: $B42)"
  [ "$RC" = 3 ] || nf "exit $RC"
  has "PRECHECK-UNKNOWN python3: no result (the check printed no line for it)"; has "PRECHECK-UNKNOWN node: no result (the check printed no line for it)"
  [ "$(tail -1 "$OUTF")" = "PRECHECK: other 2 item(s)" ] || nf "last line: $(tail -1 "$OUTF")"; rm -f "$PROJ/.tad/scripts/hp-nr.sh"; }
c_help_usage() { local f; newc; pc --help
  [ "$RC" = 0 ] || nf "exit $RC"
  case "$(head -1 "$OUTF")" in "# harness-precheck.sh — before a dispatch"*) ;; *) nf "first line: $(head -1 "$OUTF" | cut -c1-80)" ;; esac
  [ "$(grep -vc '^#' "$OUTF")" = 0 ] || nf "a printed line does not begin with #"
  grep -q 'POSIXLY_CORRECT' "$OUTF" && nf "the sanitising block was printed"
  # a control byte planted in a comment line of the block is not printed
  f="$PROJ/.tad/scripts/hp-ctl.sh"; awk -v x="$ESC" 'index($0, "# Not a hook:") == 1 { print "# planted " x "[31mRED" } { print }' "$UNDER" > "$f"
  PCSELF="$f" pc --help; PCSELF=""
  grep -q "$ESC" "$OUTF" && nf "a control byte was printed"; grep -qxF '# planted [31mRED' "$OUTF" || nf "the planted comment line was not printed without its control byte"
  rm -f "$f"; }
c_help_marker_missing() { local f k rc; newc; f="$PROJ/.tad/scripts/hp-help.sh"
  # copies: the end marker renamed; the two marker lines swapped; a line inside the block that does not begin with #
  for k in renamed swapped bare; do
    case "$k" in
      renamed) sed 's/^# Not a hook:/# Not hook:/' "$UNDER" > "$f" ;;
      swapped) awk 'index($0, "# harness-precheck.sh — before a dispatch") == 1 { s = NR } index($0, "# Not a hook:") == 1 { e = NR } { L[NR] = $0 } END { for (i = 1; i <= NR; i++) { if (i == s) print L[e]; else if (i == e) print L[s]; else print L[i] } }' "$UNDER" > "$f" ;;
      bare) awk 'index($0, "# Not a hook:") == 1 { print ": planted, prints nothing when run" } { print }' "$UNDER" > "$f" ;;
    esac
    ( cd "$C/cwd" && HOME="$C/home" TMPDIR="$C/tmp" PATH="$PCPATH" /bin/bash "$f" --help ) > "$C/help.out" 2> "$C/help.err"; rc=$?
    [ "$rc" = 2 ] || nf "$k: exit $rc"
    [ ! -s "$C/help.out" ] || nf "$k: stdout not empty"
    [ "$(cat "$C/help.err")" = "harness-precheck.sh: usage block not found" ] || nf "$k: stderr: $(head -1 "$C/help.err")"
  done; rm -f "$f"; }
c_platform_word_other() { local w x; newc
  # the CLI's own name is not a platform word: usage, exit 2, no CLI run
  for w in cursor-agent claude; do
    pc --platform "$w"
    [ "$RC" = 2 ] || nf "$w: exit $RC"; has "usage: harness-precheck.sh [--platform claude-code,codex,cursor,opencode] [--env]"
  done
  for x in $CLIS; do [ ! -s "$C/log/$x.log" ] || nf "$x ran: $(head -1 "$C/log/$x.log")"; done; }

CASES="logged-in login-needed missing broken-link unknown timeout total-cap timeout-child-left cwd-ancestor state-exit-nonzero state-no-boundary state-expired help-flood status-flood utf8-cut env-no-yaml env-key-only unsupported-subcommand help-prose-only help-wrapped-continuation hostile-version hostile-version-exit0 version-real help-real-claude help-real-cursor help-real-opencode timeout-nondigit timeout-leading-zero status-only path-hostile no-secret no-residue cdpath-hostile exported-functions env-hostile instant-exit-helper detached-helper funcnest-cleared no-result-counted env-no-result-counted help-usage help-marker-missing platform-word-other"
run_case() { local f; f="c_$(printf '%s' "$1" | tr '-' '_')"; "$f"; }
res() { if [ -z "$FAILS" ]; then echo "CASE $1 PASS"; return 0; fi; echo "CASE $1 FAIL"; echo "  $1: $FAILS"; return 1; }
ALL_OK=1
: > "$SB/all.out"
for c in $CASES; do PCENV=""; PCENV2=""; PCX=""; PCCWD=""; PCSELF=""; case " $B42CASES " in *" $c "*) [ -n "$B42" ] || { echo "CASE $c SKIP: no bash >= 4.2"; continue; } ;; esac; run_case "$c"; res "$c" || ALL_OK=0; done
[ ! -s "$SB/git.log" ] && echo "CASE no-git PASS" || { echo "CASE no-git FAIL"; ALL_OK=0; }
[ "$PYOK" = 1 ] || echo "NOTE path-hostile ran without its python part: no usable /usr/bin/python3 here; variant python-no-E not run"

build_variant() { # <out> <marker> <replacement or ''> [<marker 2> <replacement 2>]
  local n src="$SCRIPT" out="$1"; shift
  while [ $# -ge 2 ]; do
    n="$(grep -c "# $1\$" "$src")"
    [ "$n" = 1 ] || { echo "harness-precheck-fixture: marker $1 found $n times" >&2; return 1; }
    M="# $1" RP="$2" awk '{ m=ENVIRON["M"]; if (substr($0, length($0)-length(m)+1) == m) { if (ENVIRON["RP"] != "") print ENVIRON["RP"]; next } print }' "$src" > "$out.next" || return 1
    mv "$out.next" "$out"; src="$out"; shift 2
  done
  /bin/bash -n "$out" 2>/dev/null || { echo "harness-precheck-fixture: variant fails bash -n" >&2; return 1; }
}
variant() { # <name> <case> <marker> <replacement> [<marker 2> <replacement 2>]
  local out name="$1" cs="$2"; shift 2
  build_variant "$SB/v-$name.sh" "$@" || { echo "VARIANT $name PASSED"; echo "  $name: could not be built"; ALL_OK=0; return; }
  cp "$SB/v-$name.sh" "$UNDER"; CN=$((CN + 20)); : > "$SB/all.out"
  out="$(PCENV=""; PCENV2=""; PCX=""; PCCWD=""; PCSELF=""; run_case "$cs"; res "$cs")"
  cp "$SCRIPT" "$UNDER"
  for f in "$SB"/c*/resp/*/child.pid "$SB"/c*/resp/*/detached.pid "$SB"/c*/resp/*/instant.*; do kill_own "$f"; done
  if printf '%s\n' "$out" | grep -qx "CASE $cs FAIL"; then echo "VARIANT $name FAILS-AS-EXPECTED"
  else echo "VARIANT $name PASSED"; echo "  $name: case $cs still passes"; ALL_OK=0; fi
}
variant echo-status no-secret PC-FORGET '  printf "%s\n" "$OUT"; OUT=""'
variant billed-call status-only PC-VERSION-RUN '  RUN_STDOUT_ONLY=1 run_cmd "$FOUND" --version; [ "$cli" = claude ] && run_cmd "$FOUND" -p hi'
variant login-ignored login-needed PC-STATE-USE '  st=OK'
variant state-substring-ci login-needed PC-STATE-LINE '    printf "%s" "$l" | grep -qi "logged in" && ok=1'
variant state-any-true login-needed PC-STATE-JSON '  m="$(printf "%s" "$flat" | grep -q "loggedIn.*true" && echo true || echo false)"'
variant path-naive path-hostile PC-FIND '  FOUND="$(PATH="$USER_PATH" command -v "$cli")"; DANGLING=""; SKIPPED=""; if [ -z "$FOUND" ]; then'
variant path-text path-hostile PC-PATH-RESOLVED '    r="$e"' PC-TARGET-DIR '    fd="$(dirname "$f")"'
variant link-target-unchecked path-hostile PC-LINK-TARGET ''
[ "$PYOK" = 1 ] && variant python-no-E path-hostile PC-PYTHON-E '    run_cmd "$py" -c "import yaml, sys; sys.stdout.write(yaml.__version__)"'
variant no-help-check unsupported-subcommand PC-HELP-CHECK '  if false; then'
variant help-substring help-prose-only PC-HELP-CHECK '  if ! printf "%s" "$OUT" | grep -qw -- "$word"; then'
variant help-first-field-only help-real-opencode PC-HELP-PARENT ''
variant help-any-indented-line help-wrapped-continuation PC-HELP-INDENT ''
variant version-raw-line hostile-version-exit0 PC-VERSION-TOKEN '      if true; then tok="$line"'
variant home-raw no-secret PC-HOME-SHOW '  for h in ""; do'
variant timeout-unvalidated timeout-nondigit PC-TIMEOUT-VALIDATE 'BOUND=$((${PRECHECK_TIMEOUT:-20}))'
variant timeout-octal timeout-leading-zero PC-DECIMAL '  n=$((v))'
# rework 1: pid-only-kill also drops the group sweep after the leader exits (either one kills the child)
variant pid-only-kill timeout PC-PGROUP-KILL '    ( sleep "$LIMIT"; kill -TERM "$p" 2>/dev/null; sleep 1; kill -KILL "$p" 2>/dev/null ) > /dev/null 2>&1 &' PC-GROUP-SWEEP ''
variant keep-file no-residue PC-FORGET '  printf "%s" "$OUT" > "${TMPDIR:-/tmp}/precheck-status.out"; OUT=""'
variant env-counts env-no-yaml PC-FIX-COUNT '      add_human python3'
# rework 1: one must-fail variant per fix
variant total-cap-unbounded total-cap PC-TOTAL-CAP '  left=$BOUND'
variant no-group-sweep timeout-child-left PC-GROUP-SWEEP ''
variant start-under cwd-ancestor PC-START-EQUAL '  if [ -n "$START" ]; then case "$d/" in "$START/"*) return 0 ;; esac; fi'
variant state-rc-ignored state-exit-nonzero PC-STATE-RC ''
variant state-json-unbounded state-no-boundary PC-STATE-JSON '  m="$(printf "%s" "$flat" | grep -oE "\"loggedIn\"[[:space:]]*:[[:space:]]*(true|false)" | sed "s/.*:[[:space:]]*//" | LC_ALL=C sort -u)"'
variant state-line-unbounded state-no-boundary PC-STATE-LINE '    case "$l" in "Not logged in"*) no=1 ;; "Logged in"*) ok=1 ;; esac'
variant credentials-leading-zero state-no-boundary PC-CRED-COUNT '    if [[ "$l" =~ ^([0-9]+)\ credentials?$ ]]; then n="${BASH_REMATCH[1]}"; fi'
variant expired-ignored state-expired PC-STATE-EXPIRED '' PC-STATE-EXPIRED-LINE ''
variant help-uncapped help-flood PC-HELP-CAP ''
variant status-uncapped status-flood PC-STATUS-CAP ''
variant byte-cut utf8-cut PC-UTF8-CUT '  printf "%s" "$p" | cut -c1-60'
# rework 2: one must-fail variant per closure
variant cdpath-kept cdpath-hostile ENV-UNSET '\unset GLOBIGNORE GREP_OPTIONS GREP_COLOR GREP_COLORS CLICOLOR CLICOLOR_FORCE LSCOLORS ENV BASH_XTRACEFD' PC-DIR-ONE-LINE ''
variant functions-kept exported-functions ENV-NO-FUNCS '' ENV-NO-FUNCS-2 ''
# (no noglob variant here: this script expands no glob, so SHELLOPTS=noglob cannot change its result; tad-tmp-fixture has one)
variant root-open cdpath-hostile PC-ROOT-CLOSED '' PC-DIR-ONE-LINE '' ENV-UNSET '\unset GLOBIGNORE'
variant no-group-sweep-instant instant-exit-helper PC-GROUP-SWEEP ''
variant marker-ignored detached-helper PC-READ-MARK '    :'
variant read-unbounded detached-helper PC-READ-BOUND '    IFS= read -r line; rt=$?' PC-READ-MARK '    :'

# report-upgrades Phase 6: one must-fail variant per fix (D5, D7, D10)
if [ -n "$B42" ]; then
  variant funcnest-kept funcnest-cleared ENV-UNSET '\unset CDPATH GLOBIGNORE GREP_OPTIONS GREP_COLOR GREP_COLORS CLICOLOR CLICOLOR_FORCE LSCOLORS ENV BASH_XTRACEFD'
  variant no-result-uncounted no-result-counted PC-NO-RESULT ''
  variant no-result-uncounted env-no-result-counted PC-NO-RESULT ''
else
  for v in funcnest-kept no-result-uncounted; do echo "VARIANT $v SKIP: no bash >= 4.2"; done
fi
variant help-old-range help-usage PC-HELP-CALL "    -h|--help) sed -n '3,21p' \"\$0\"; exit 0 ;;"
variant help-no-guard help-marker-missing PC-HELP-GUARD '' PC-HELP-ORDER ''
variant help-no-order help-marker-missing PC-HELP-ORDER ''
variant help-no-hash help-marker-missing PC-HELP-HASH ''
variant help-no-strip help-usage PC-HELP-STRIP '  printf "%s\n" "$out"'
# the word check is a line without a marker (D10: the script is not changed for it), so this variant replaces its text
pwa_old='claude-code|codex|cursor|opencode) ;; *) IFS="$_old_ifs"; usage ;;'
if [ "$(grep -cF -- "$pwa_old" "$SCRIPT")" = 1 ]; then
  P_OLD="$pwa_old" awk '{ i = index($0, ENVIRON["P_OLD"]); if (i) $0 = substr($0, 1, i - 1) "*) ;;" substr($0, i + length(ENVIRON["P_OLD"])); print }' "$SCRIPT" > "$SB/v-platform-word-any.sh"
  cp "$SB/v-platform-word-any.sh" "$UNDER"; CN=$((CN + 20)); : > "$SB/all.out"
  out="$(PCENV=""; PCENV2=""; PCX=""; PCCWD=""; PCSELF=""; run_case platform-word-other; res platform-word-other)"
  cp "$SCRIPT" "$UNDER"
  if printf '%s\n' "$out" | grep -qx "CASE platform-word-other FAIL"; then echo "VARIANT platform-word-any FAILS-AS-EXPECTED"
  else echo "VARIANT platform-word-any PASSED"; echo "  platform-word-any: case platform-word-other still passes"; ALL_OK=0; fi
else echo "VARIANT platform-word-any PASSED"; echo "  platform-word-any: could not be built (the word check text is not found once)"; ALL_OK=0; fi

if [ "$ALL_OK" = "1" ]; then echo "HARNESS-PRECHECK-FIXTURE: PASS"; exit 0; fi
echo "HARNESS-PRECHECK-FIXTURE: FAIL"; exit 1
