#!/bin/bash
# gate3-check.sh — Gate 3 AC re-run and real_path coverage (review-redesign Phase 3).
# Advisory CLI, NEVER a hook: do not register it in settings, hooks.json or any
# plugin. No `set -e` on purpose.
#
# SECURITY: `rerun` EXECUTES command lines read from a handoff file — the same
# commands a reviewer runs by hand, no wider trust. A handoff's §9.1 commands must
# be read-only (scratch writes only through `mktemp -d`). The rerun never executes an
# outward or destructive command: only commands on a read-only allowlist run (see
# GUARD below); everything else is recorded as not-run with the reason.
#
# Usage:
#   gate3-check.sh rerun <handoff> [--out <file>] [--id <dispatch_id>]
#       exit 0 always (it records; judging is the reviewer's), 2 on usage.
#   gate3-check.sh paths <handoff> <verdict-file>
#       prints COVERED <ID> run | COVERED <ID> not-run | BLOCKED <ID> | MISSING <ID>
#       exit 0 when no MISSING (BLOCKED lines allowed: the verdict rule caps them),
#       1 on any MISSING or when the handoff has no real_paths, 2 on usage.

usage() {
  echo "Usage: gate3-check.sh rerun <handoff> [--out <file>] [--id <dispatch_id>]" >&2
  echo "       gate3-check.sh paths <handoff> <verdict-file>" >&2
  exit 2
}

[ $# -ge 2 ] || usage
cmd="$1"; shift
handoff="$1"; shift
[ -f "$handoff" ] && [ -r "$handoff" ] || usage

# GUARD: allowlist of read-only commands. `rerun` executes a row only when this awk
# program parses the whole command line and every command in it (pipes, ; && ||, loops,
# functions, $( ), backticks, <( ) included) is on the allowlist with safe arguments, and
# every output redirect goes to /dev/null or to a $T made by `T=$(mktemp -d)`. Anything
# it cannot parse or does not know is refused and recorded as not-run with the reason.
# This replaces a deny regex: a deny list misses spellings, an allowlist cannot.
IFS= read -r -d '' GUARD <<'GUARD_EOF' || true
# Read-only allowlist guard: reads one shell command line from ENVIRON["P"].
# Prints "OK", or "REFUSE <reason>". Anything it cannot parse is refused.
function refuse(why) {
  gsub(/[|\n\r]/, " ", why)
  if (length(why) > 90) why = substr(why, 1, 90)
  print "REFUSE " why
  exit 0
}
function newlevel() {
  lv++
  CP[lv] = 1; CMD[lv] = ""; NA[lv] = 0; INW[lv] = 0; W[lv] = ""; WX[lv] = 0
  FORHDR[lv] = 0; FORN[lv] = 0; FORBAD[lv] = 0; CASEST[lv] = 0; PAT[lv] = 0; DBK[lv] = 0; REDIR[lv] = 0; CMDPFX[lv] = 0
}
function startw() { if (!INW[lv]) { INW[lv] = 1; WS[lv] = i; W[lv] = "" } }
function addc(ch) { startw(); W[lv] = W[lv] ch }
function expand(s,   out, p, rest, nm, q) {
  out = ""
  while ((p = index(s, "$")) > 0) {
    out = out substr(s, 1, p - 1); rest = substr(s, p + 1)
    if (substr(rest, 1, 1) == "{") {
      q = index(rest, "}")
      if (q == 0) { out = out "\001"; s = ""; break }
      nm = substr(rest, 2, q - 2); s = substr(rest, q + 1)
    } else if (match(rest, /^[A-Za-z_][A-Za-z0-9_]*/)) {
      nm = substr(rest, 1, RLENGTH); s = substr(rest, RLENGTH + 1)
    } else { out = out "\001"; s = substr(rest, 2); continue }
    if (nm ~ /^[A-Za-z_][A-Za-z0-9_]*$/ && (nm in VAR)) out = out VAR[nm]; else out = out "\001"
  }
  out = out s
  gsub(/\003/, "$", out)
  return out
}
function badvar(nm) {
  return (nm ~ /^(PATH|IFS|BASH_ENV|ENV|SHELL|PS4|PROMPT_COMMAND|PAGER|EDITOR|VISUAL|CDPATH|HOME|SHELLOPTS|BASHOPTS)$/ || nm ~ /^(GIT_|LD_|DYLD_)/)
}
function dollar(indq,   c2, c3, depth, k, ch, body, nm) {
  c2 = substr(P, i + 1, 1)
  if (c2 == "(") {
    startw(); WX[lv] = 1
    c3 = substr(P, i + 2, 1)
    if (c3 == "(") {
      depth = 0; k = i + 1
      while (k <= n) { ch = substr(P, k, 1); if (ch == "(") depth++; else if (ch == ")") { depth--; if (depth == 0) break } k++ }
      if (k > n) refuse("unbalanced arithmetic expansion")
      body = substr(P, i + 3, k - i - 3)
      if (index(body, "$(") > 0 || index(body, "`") > 0) refuse("command substitution inside arithmetic")
      i = k + 1; W[lv] = W[lv] "\004"; return
    }
    i += 2
    parse_seq(")")
    W[lv] = W[lv] "\001"; return
  }
  if (c2 == "{") {
    depth = 1; k = i + 2
    while (k <= n) { ch = substr(P, k, 1); if (ch == "{") depth++; else if (ch == "}") { depth--; if (depth == 0) break } k++ }
    if (k > n) refuse("unbalanced parameter expansion")
    body = substr(P, i + 2, k - i - 2)
    if (index(body, "$(") > 0 || index(body, "`") > 0 || index(body, "'") > 0 || index(body, "\"") > 0) refuse("complex parameter expansion")
    startw(); WX[lv] = 1
    W[lv] = W[lv] "${" body "}"; i = k + 1; return
  }
  if (c2 == "'" && !indq) refuse("ANSI-C quoting")
  if (match(substr(P, i + 1), /^([A-Za-z_][A-Za-z0-9_]*|[0-9@*#?$!-])/)) {
    nm = substr(P, i + 1, RLENGTH)
    startw(); WX[lv] = 1
    W[lv] = W[lv] "$" nm; i += 1 + RLENGTH; return
  }
  addc("\003"); i++
}
function parse_dq(   c, nx) {
  startw()
  while (i <= n) {
    c = substr(P, i, 1)
    if (c == "\"") { i++; return }
    if (c == "\\") {
      nx = substr(P, i + 1, 1)
      if (nx == "$") { addc("\003"); i += 2 }
      else if (nx == "\"" || nx == "\\" || nx == "`") { addc(nx); i += 2 }
      else if (nx == "\n") { i += 2 }
      else { addc("\\"); i++ }
      continue
    }
    if (c == "$") { dollar(1); continue }
    if (c == "`") { startw(); WX[lv] = 1; i++; parse_seq("`"); W[lv] = W[lv] "\001"; continue }
    addc(c); i++
  }
  refuse("unbalanced double quote")
}
function chkredir(w, raw,   ex) {
  if (REDIR[lv] == 2) return
  ex = expand(w)
  if (ex == "/dev/null" || ex == "/dev/stderr" || ex == "/dev/stdout") return
  if (raw ~ /^"?\$\(mktemp( -d)?\)"?$/) return
  if (TSET && index(ex, "\002/") == 1 && ex !~ /\001/ && ex !~ /\.\./) return
  refuse("redirect target outside the scratch dir: " ex)
}
function endword(   w, raw, nm, val, ex) {
  if (!INW[lv]) return
  w = W[lv]; raw = substr(P, WS[lv], i - WS[lv])
  INW[lv] = 0; W[lv] = ""; WX[lv] = 0
  if (REDIR[lv]) { chkredir(w, raw); REDIR[lv] = 0; return }
  if (DBK[lv]) { if (w == "]]") DBK[lv] = 0; return }
  if (PAT[lv]) { if (w == "esac") { PAT[lv] = 0; CASEST[lv] = 0; CP[lv] = 0 } return }
  if (CASEST[lv] == 1) { CASEST[lv] = 2; return }
  if (CASEST[lv] == 2) { if (w == "in") { CASEST[lv] = 3; PAT[lv] = 1 } return }
  if (FORHDR[lv]) {
    FORN[lv]++
    if (FORN[lv] == 1) FORVAR[lv] = w
    else if (FORN[lv] > 2) { ex = expand(w); if (ex ~ /\001/ || ex ~ /\.\./ || ex ~ /^\//) FORBAD[lv] = 1 }
    return
  }
  if (CMD[lv] == "" && CP[lv]) {
    if (w == "if" || w == "elif" || w == "while" || w == "until" || w == "then" || w == "else" || w == "do" || w == "{" || w == "!") return
    if (w == "fi" || w == "done" || w == "}") { CP[lv] = 0; return }
    if (w == "for") { FORHDR[lv] = 1; CP[lv] = 0; return }
    if (w == "case") { CASEST[lv] = 1; CP[lv] = 0; return }
    if (w == "command") { CMDPFX[lv] = 1; return }
    if (CMDPFX[lv] && (w == "-v" || w == "-V")) { CMD[lv] = ":"; CP[lv] = 0; CMDPFX[lv] = 0; return }
    if (w ~ /^[A-Za-z_][A-Za-z0-9_]*=/) {
      nm = substr(w, 1, index(w, "=") - 1)
      if (badvar(nm)) refuse("assignment to " nm)
      if (nm == "T") {
        if (raw !~ /^T="?\$\(mktemp -d\)"?$/) refuse("T may only be assigned $(mktemp -d)")
        TSET = 1; VAR["T"] = "\002"; return
      }
      ex = expand(substr(w, index(w, "=") + 1))
      VAR[nm] = ex
      return
    }
    ex = expand(w)
    if (ex ~ /[\001\002\004]/ || ex ~ /\//) refuse("command word is not a plain name: " raw)
    if (!(ex in ALLOW) && !(ex in FN)) refuse("not on the read-only allowlist: " ex)
    CMD[lv] = ex; NA[lv] = 0; CP[lv] = 0; CMDPFX[lv] = 0
    if (ex == "[[") DBK[lv] = 1
    return
  }
  NA[lv]++; A[lv, NA[lv]] = expand(w)
}
function endfor() {
  if (FORHDR[lv]) {
    if (FORVAR[lv] ~ /^[A-Za-z_][A-Za-z0-9_]*$/) VAR[FORVAR[lv]] = (FORBAD[lv] ? "\001" : "\004")
    FORHDR[lv] = 0; FORN[lv] = 0; FORBAD[lv] = 0; CP[lv] = 1
  }
}
function endcmd() {
  endword()
  if (REDIR[lv]) refuse("redirect without a target")
  if (CMD[lv] != "") chk()
  CMD[lv] = ""; NA[lv] = 0; CP[lv] = 1; CMDPFX[lv] = 0
}
function joinargs(   k, s) { s = ""; for (k = 1; k <= NA[lv]; k++) s = s " " A[lv, k]; return s }
function chk(   c, k, a, first, all, tgt) {
  c = CMD[lv]
  if (c == "git") {
    if (NA[lv] == 0) refuse("git without a subcommand")
    first = A[lv, 1]
    if (!(first in GITOK)) refuse("git " first " is not a read-only subcommand")
    for (k = 1; k <= NA[lv]; k++) { a = A[lv, k]; if (a ~ /^--(output|ext-diff|open-files-in-pager|exec)/ || a == "-O") refuse("git option " a) }
  } else if (c == "bash" || c == "sh") {
    if (NA[lv] == 0) refuse(c " without a script")
    if (A[lv, 1] != "-n") {
      tgt = A[lv, 1]
      if (tgt ~ /^-/) refuse(c " option " tgt)
      if (tgt ~ /[\001\002\004]/ || tgt !~ /^(\.\/)?\.(tad|agents)\/[A-Za-z0-9_.\/-]+\.sh$/ || tgt ~ /\.\./) refuse(c " runs only a repo .tad/.agents script, not " tgt)
    }
  } else if (c == "awk" || c == "gawk" || c == "mawk" || c == "nawk") {
    all = joinargs()
    for (k = 1; k <= NA[lv]; k++) if (A[lv, k] ~ /^-[fiE]/ || A[lv, k] ~ /^--(file|include|source)/) refuse("awk option " A[lv, k])
    if (all ~ /system[ \t]*\(/ || all ~ /\|[ \t]*getline/ || all ~ /\|&/ || all ~ /\|[ \t]*"/ || all ~ /(print|printf)[^;}]*>/ || all ~ /close[ \t]*\(/) refuse("awk program can run a command or write a file")
  } else if (c == "sed") {
    for (k = 1; k <= NA[lv]; k++) {
      a = A[lv, k]
      if (a ~ /^-[A-Za-z]*[ifs]/ && a !~ /^-[A-Za-z]*e/ && a ~ /^-/) refuse("sed option " a)
      if (a ~ /^--(in-place|file|sandbox)/) refuse("sed option " a)
      if (a ~ /(^|[\/;{}!$0-9,])[ \t]*[wW][ \t]+[^ \t]/ || a ~ /(^|[\/;{}!$0-9,])[ \t]*e([ \t]|$)/ || a ~ /\/[gpiImM0-9]*[weW]([ \t;}]|$)/) refuse("sed script can run a command or write a file")
    }
  } else if (c == "sort") {
    for (k = 1; k <= NA[lv]; k++) if (A[lv, k] ~ /^-[A-Za-z]*o/ || A[lv, k] ~ /^--output/) refuse("sort -o writes a file")
  } else if (c == "uniq") {
    first = 0
    for (k = 1; k <= NA[lv]; k++) if (A[lv, k] !~ /^-/) first++
    if (first > 1) refuse("uniq with an output file")
  } else if (c == "find") {
    for (k = 1; k <= NA[lv]; k++) if (A[lv, k] ~ /^-(exec|execdir|ok|okdir|delete|fprint|fprint0|fprintf|fls)$/) refuse("find " A[lv, k])
  } else if (c == "ruby") {
    for (k = 1; k <= NA[lv]; k++) {
      a = A[lv, k]
      if (a == "-ryaml" || a == "-e") continue
      if (a !~ /^YAML\.load_file\('[^']*'\)(; *print '[^']*')?$/) refuse("ruby is only allowed to YAML.load_file")
    }
  } else if (c == "mktemp") {
    for (k = 1; k <= NA[lv]; k++) if (A[lv, k] != "-d" && A[lv, k] != "-t") refuse("mktemp argument " A[lv, k])
  } else if (c == "mkdir" || c == "touch") {
    for (k = 1; k <= NA[lv]; k++) {
      a = A[lv, k]
      if (a == "-p") continue
      if (!(TSET && index(a, "\002/") == 1 && a !~ /\001/ && a !~ /\.\./)) refuse(c " outside the scratch dir: " a)
    }
  } else if (c == "export" || c == "unset") {
    for (k = 1; k <= NA[lv]; k++) { a = A[lv, k]; sub(/=.*/, "", a); if (badvar(a)) refuse(c " of " a) }
  } else if (c == "date") {
    for (k = 1; k <= NA[lv]; k++) if (A[lv, k] ~ /^(-s|--set)/) refuse("date sets the clock")
  }
}
function parse_seq(closer,   c, c2, d) {
  newlevel()
  while (i <= n) {
    c = substr(P, i, 1)
    if (DBK[lv] && (c == "&" || c == "|" || c == "(" || c == ")" || c == "<" || c == ">")) { endword(); i++; continue }
    if (c == " " || c == "\t") { endword(); i++; continue }
    if (c == "\n") { endword(); endfor(); endcmd(); i++; continue }
    if (c == "#" && !INW[lv]) { while (i <= n && substr(P, i, 1) != "\n") i++; continue }
    if (c == "'") {
      startw(); d = index(substr(P, i + 1), "'")
      if (d == 0) refuse("unbalanced single quote")
      c2 = substr(P, i + 1, d - 1); gsub(/\$/, "\003", c2)
      W[lv] = W[lv] c2; i += d + 1; continue
    }
    if (c == "\"") { i++; parse_dq(); continue }
    if (c == "\\") {
      c2 = substr(P, i + 1, 1)
      if (c2 == "\n") { i += 2; continue }
      if (c2 == "$") c2 = "\003"
      addc(c2); i += 2; continue
    }
    if (c == "$") { dollar(0); continue }
    if (c == "`") {
      if (closer == "`") { endcmd(); i++; lv--; return }
      startw(); WX[lv] = 1; i++; parse_seq("`"); W[lv] = W[lv] "\001"; continue
    }
    if (c == "<") {
      c2 = substr(P, i + 1, 1)
      if (c2 == "(") { startw(); WX[lv] = 1; i += 2; parse_seq(")"); W[lv] = W[lv] "\001"; continue }
      if (INW[lv] && W[lv] ~ /^[0-9]+$/ && WS[lv] + length(W[lv]) == i) { INW[lv] = 0; W[lv] = "" } else endword()
      if (c2 == "<" && substr(P, i + 2, 1) == "<") { REDIR[lv] = 2; i += 3; continue }
      if (c2 == "<") refuse("here-document")
      if (c2 == "&") refuse("input fd duplication")
      REDIR[lv] = 2; i++; continue
    }
    if (c == ">") {
      c2 = substr(P, i + 1, 1)
      if (c2 == "(") refuse("output process substitution")
      if (INW[lv] && W[lv] ~ /^[0-9]+$/ && WS[lv] + length(W[lv]) == i) { INW[lv] = 0; W[lv] = "" } else endword()
      if (c2 == "&") {
        if (match(substr(P, i + 2), /^([0-9]+|-)/)) { i += 2 + RLENGTH; continue }
        refuse("redirect to a named fd or file via >&")
      }
      if (c2 == ">" || c2 == "|") i++
      REDIR[lv] = 1; i++; continue
    }
    if (c == "&") {
      c2 = substr(P, i + 1, 1)
      if (c2 == "&") { endcmd(); i += 2; continue }
      if (c2 == ">") { endword(); i++; if (substr(P, i + 1, 1) == ">") i++; REDIR[lv] = 1; i++; continue }
      refuse("background job")
    }
    if (c == "|") {
      c2 = substr(P, i + 1, 1)
      if (PAT[lv]) { endword(); i++; continue }
      if (c2 == "&") refuse("|& pipe")
      endcmd(); i++; if (c2 == "|") i++
      continue
    }
    if (c == ";") {
      c2 = substr(P, i + 1, 1)
      if (c2 == "&") refuse(";& in case")
      if (c2 == ";") { endcmd(); PAT[lv] = 1; CP[lv] = 0; i += 2; continue }
      endword(); endfor()
      endcmd(); i++; continue
    }
    if (c == "(") {
      if (INW[lv] && CP[lv] && CMD[lv] == "" && substr(P, i + 1, 1) == ")" && W[lv] ~ /^[A-Za-z_][A-Za-z0-9_]*$/) {
        FN[W[lv]] = 1; INW[lv] = 0; W[lv] = ""; WX[lv] = 0; i += 2; continue
      }
      if (INW[lv] || !CP[lv] || CMD[lv] != "") refuse("unexpected (")
      if (substr(P, i + 1, 1) == "(") refuse("arithmetic command")
      i++; parse_seq(")"); CP[lv] = 0; continue
    }
    if (c == ")") {
      if (PAT[lv]) { endword(); PAT[lv] = 0; CP[lv] = 1; i++; continue }
      if (closer == ")") { endcmd(); i++; lv--; return }
      refuse("unbalanced )")
    }
    addc(c); i++
  }
  if (closer != "") refuse("unbalanced " closer)
  endcmd()
  lv--
}
BEGIN {
  split("echo printf cat head tail wc grep egrep fgrep awk gawk mawk nawk sed tr cut sort uniq comm diff cmp ls stat basename dirname pwd date seq expr sha1sum shasum md5sum md5 cksum jq true false : test [ [[ git bash sh ruby shellcheck mktemp mkdir touch find cd export unset read exit sleep nl rev realpath readlink printenv type", al, " ")
  for (k in al) ALLOW[al[k]] = 1
  split("show log diff rev-parse ls-files status grep check-ignore cat-file rev-list ls-tree describe show-ref diff-tree blame shortlog merge-base name-rev check-attr for-each-ref count-objects", gl, " ")
  for (k in gl) GITOK[gl[k]] = 1
  P = ENVIRON["P"]; n = length(P); i = 1; lv = 0; TSET = 0
  parse_seq("")
  print "OK"
}
GUARD_EOF

# ---------------------------------------------------------------- paths
if [ "$cmd" = paths ]; then
  [ $# -eq 1 ] || usage
  vf="$1"
  [ -f "$vf" ] && [ -r "$vf" ] || usage
  ids=$(awk '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    /^real_paths:/ { on = 1; next }
    on && /^[^[:space:]-]/ { on = 0 }
    on && /^[[:space:]]*- id:/ { sub(/^[[:space:]]*- id:[[:space:]]*/, ""); gsub(/["'\'']/, ""); sub(/[[:space:]].*$/, ""); print }
  ' "$handoff")
  if [ -z "$ids" ]; then
    echo "MISSING real_paths"
    exit 1
  fi
  secof() { # heading-regex -> section body of the verdict file
    H="$1" awk 'BEGIN{h=ENVIRON["H"]} !on { if ($0 ~ h) on = 1; next } /^## / { exit } { print }' "$vf"
  }
  rp=$(secof '^## Real paths')
  nr=$(secof '^## Not run')
  bl=$(secof '^## Blocked')
  rc=0
  for id in $ids; do
    pat="(^|[^A-Za-z0-9_-])${id}([^A-Za-z0-9_-]|\$)"
    last=$(printf '%s\n' "$rp" | command grep -E "^\\| *${id} *\\|" | head -1 | sed -E 's/[[:space:]]*\|[[:space:]]*$//; s/.*\|//; s/^[[:space:]]+//; s/[[:space:]]+$//')
    if [ -n "$last" ]; then
      echo "COVERED $id run"
    elif printf '%s\n' "$nr" | command grep -E -- "$pat" | command grep -q 'not-run:'; then
      echo "COVERED $id not-run"
    elif printf '%s\n' "$bl" | command grep -Eq -- "$pat"; then
      echo "BLOCKED $id"
    else
      echo "MISSING $id"
      rc=1
    fi
  done
  exit $rc
fi

# ---------------------------------------------------------------- rerun
[ "$cmd" = rerun ] || usage
out=""; rid=""
while [ $# -gt 0 ]; do
  case "$1" in
    --out) [ $# -ge 2 ] || usage; out="$2"; shift 2 ;;
    --id)  [ $# -ge 2 ] || usage; rid="$2"; shift 2 ;;
    *) usage ;;
  esac
done

root=$(git rev-parse --show-toplevel 2>/dev/null)
[ -n "$root" ] || { echo "gate3-check.sh: not inside a git work tree" >&2; exit 2; }
# resolve the handoff and --out before changing directory
case "$handoff" in /*) ;; *) handoff="$PWD/$handoff" ;; esac
if [ -n "$out" ]; then case "$out" in /*) ;; *) out="$PWD/$out" ;; esac; fi
sha=$(git -C "$root" rev-parse --short HEAD 2>/dev/null)

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Parse the §9.1 region into records: name<US>kind<US>payload  (kind: CMD | NS)
US=$(printf '\037')
S="$US" awk '
  function trim(x) { sub(/^[[:space:]]+/, "", x); sub(/[[:space:]]+$/, "", x); return x }
  BEGIN { us = ENVIRON["S"]; on = 0; fence = 0; nrows = 0; nb = 0 }
  !on { if ($0 ~ /^## 9\.1/) on = 1; next }
  /^## / { exit }
  /^```/ { fence = !fence; if (fence) { nb++; benv[nb] = "" } ; next }
  fence {
    if (match($0, /^[A-Za-z][A-Za-z0-9]*:[ \t]/)) {
      id = substr($0, 1, index($0, ":") - 1)
      rest = substr($0, index($0, ":") + 1); sub(/^[ \t]+/, "", rest)
      if (id == "ENV") { benv[nb] = rest }
      else if (!(id in idcmd)) { idcmd[id] = rest; idblk[id] = nb }
    }
    next
  }
  /^\|/ && !hdr && index($0, "Verification Method") {
    t = $0; gsub(/\\\|/, "\001", t); n = split(t, c, "|")
    for (i = 1; i <= n; i++) if (trim(c[i]) == "Verification Method") hdr = i
    next
  }
  /^\| *AC/ {
    if (!hdr) next
    t = $0; gsub(/\\\|/, "\001", t); n = split(t, c, "|")
    first = trim(c[2]); name = first
    if (match(first, /AC[0-9]+/)) name = substr(first, RSTART, RLENGTH)
    cell = trim(c[hdr + 0])
    nrows++; rname[nrows] = name; rcell[nrows] = cell
  }
  END {
    for (r = 1; r <= nrows; r++) {
      cell = rcell[r]; name = rname[r]
      if (cell ~ /^`[^`]*`$/) {
        cmd = substr(cell, 2, length(cell) - 2); gsub(/\001/, "|", cmd)
        printf "%s%sCMD%s%s\n", name, us, us, cmd
      } else if (cell ~ /^[A-Za-z][A-Za-z0-9]*(, *[A-Za-z][A-Za-z0-9]*)*$/) {
        m = split(cell, ids, /, */)
        for (k = 1; k <= m; k++) {
          id = ids[k]
          if (id in idcmd) {
            cmd = idcmd[id]; e = benv[idblk[id]]
            if (e != "") cmd = e "; " cmd
            printf "%s/%s%sCMD%s%s\n", name, id, us, us, cmd
          } else printf "%s/%s%sNS%s\n", name, id, us, us
        }
      } else printf "%s%sNS%s\n", name, us, us
    }
  }
' "$handoff" > "$work/rows.txt"

have_perl=0; command -v perl >/dev/null 2>&1 && have_perl=1

{
  [ -n "$rid" ] && echo "dispatch_id: $rid"
  echo "# AC re-run: $handoff @ $sha"
  [ "$have_perl" -eq 0 ] && echo "# note: perl absent, commands ran without a timeout"
  echo
  echo "| row | exit | command |"
  echo "|---|---|---|"
} > "$work/head.txt"
: > "$work/table.txt"
: > "$work/detail.txt"

while IFS= read -r line; do
  name="${line%%"$US"*}"
  rest="${line#*"$US"}"
  kind="${rest%%"$US"*}"
  payload="${rest#*"$US"}"
  if [ "$kind" = NS ]; then
    printf '| %s | not-scriptable |  |\n' "$name" >> "$work/table.txt"
    continue
  fi
  shown=$(printf '%s' "$payload" | sed 's/|/\\|/g')
  gv=$(P="$payload" awk "$GUARD" 2>&1 < /dev/null)
  case "$gv" in
    OK) ;;
    *)
      why=${gv#REFUSE }
      [ "$gv" = "$why" ] && why="guard failed: $gv"
      why=$(printf '%s' "$why" | tr '|\n' '  ' | cut -c1-120)
      printf '| %s | not-run: %s (read-only allowlist) — run by hand | %s |\n' "$name" "$why" "$shown" >> "$work/table.txt"
      continue
      ;;
  esac
  if [ "$have_perl" -eq 1 ]; then
    (cd "$root" && perl -e 'alarm shift; exec @ARGV' 300 bash -c "$payload") > "$work/o.txt" 2>&1 < /dev/null
  else
    (cd "$root" && bash -c "$payload") > "$work/o.txt" 2>&1 < /dev/null
  fi
  ec=$?
  printf '| %s | %s | %s |\n' "$name" "$ec" "$shown" >> "$work/table.txt"
  { echo; echo "### $name"; echo '```'; head -40 "$work/o.txt"; echo '```'; } >> "$work/detail.txt"
done < "$work/rows.txt"

if [ -n "$out" ]; then
  cat "$work/head.txt" "$work/table.txt" "$work/detail.txt" > "$out"
else
  cat "$work/head.txt" "$work/table.txt" "$work/detail.txt"
fi
exit 0
