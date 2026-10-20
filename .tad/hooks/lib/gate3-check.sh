#!/bin/bash
# gate3-check.sh — Gate 3 AC re-run and real_path coverage (review-redesign Phase 3).
# Advisory CLI, NEVER a hook: do not register it in settings, hooks.json or any
# plugin. No `set -e` on purpose.
#
# SECURITY: `rerun` EXECUTES command lines read from a handoff file (untrusted input).
# It never decides whether a command is safe by reading its text (two text filters
# were tried and both leaked; see .tad/evidence/yolo/review-redesign/phase3-premise.md).
# The barrier is the environment: every row runs inside an OS sandbox (macOS
# sandbox-exec, Linux bwrap) around a disposable copy of the repo. The sandbox denies
# all network, all writes outside the copy and every read under the caller's $HOME; the
# environment is cleared (env -i), HOME and TMPDIR are inside the copy, the copy has
# no remote. A start-up probe proves the denials before any row runs. No sandbox tool,
# or a failed probe: every scriptable row is recorded not-run and nothing is executed
# (there is no flag or variable that runs a row outside the sandbox). The copy is
# deleted on exit.
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
# resolve the handoff and --out before anything changes directory
case "$handoff" in /*) ;; *) handoff="$PWD/$handoff" ;; esac
if [ -n "$out" ]; then case "$out" in /*) ;; *) out="$PWD/$out" ;; esac; fi
uname_s=$(uname -s)

BOX=""; work=""; probe_dir=""
cleanup() {
  # only script-made paths are removed, never following symlinks
  for d in "$BOX" "$probe_dir"; do
    case "$d" in
      */gate3-box.??????|*/gate3-probe.??????)
        if [ -d "$d" ] && [ ! -L "$d" ]; then
          [ "$uname_s" = Darwin ] && chflags -R nouchg "$d" >/dev/null 2>&1
          chmod -R u+rwX "$d" >/dev/null 2>&1
          rm -rf "$d"
        fi ;;
    esac
  done
  [ -n "$work" ] && [ -d "$work" ] && rm -rf "$work"
}
trap cleanup EXIT
trap 'exit 1' INT TERM HUP

real_dir() { (cd "$1" 2>/dev/null && pwd -P); }

caller_home=""
if [ -n "${HOME:-}" ]; then
  caller_home=$(real_dir "$HOME")
  [ "$caller_home" = "/" ] && caller_home=""
fi

# A scratch dir that is not under the caller's HOME (the sandbox denies reads there).
# $1 = name prefix. Prints the resolved path.
mkscratch() {
  local base d
  base="${TMPDIR:-/tmp}"; base="${base%/}"
  d=$(mktemp -d "$base/$1.XXXXXX" 2>/dev/null) || return 1
  d=$(real_dir "$d") || return 1
  if [ -n "$caller_home" ]; then
    case "$d/" in
      "$caller_home"/*)
        rm -rf "$d"
        d=$(mktemp -d "/tmp/$1.XXXXXX" 2>/dev/null) || return 1
        d=$(real_dir "$d") || return 1 ;;
    esac
  fi
  printf '%s\n' "$d"
}

work=$(mktemp -d)

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

ncmd=$(grep -c "${US}CMD${US}" "$work/rows.txt")
have_perl=0; command -v perl >/dev/null 2>&1 && have_perl=1

# ---- sandbox tool
sbtool=none
if [ "$uname_s" = Darwin ] && [ -x /usr/bin/sandbox-exec ]; then sbtool=sandbox-exec
elif command -v bwrap >/dev/null 2>&1; then sbtool=bwrap
fi

# ---- the box: a disposable copy of the repo (history + the working tree as it is)
box_reason=""
build_box() {
  local f lst
  BOX=$(mkscratch gate3-box) || { box_reason="no scratch dir"; BOX=""; return 1; }
  mkdir -p "$BOX/home" "$BOX/tmp" "$BOX/bin" || { box_reason="cannot create the box"; return 1; }
  if ! GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null git clone --no-local --no-hardlinks --template= --quiet "$root" "$BOX/repo" > "$BOX/clone.log" 2>&1; then
    box_reason="git clone of the repo failed"; return 1
  fi
  git -C "$BOX/repo" remote remove origin > /dev/null 2>&1
  lst="$BOX/overlay.lst"
  # every modified, untracked and ignored path of the working tree (deleted ones skipped),
  # minus .git, .worktrees/ and node_modules/
  ( cd "$root" || exit 1
    git ls-files -z -m -o | while IFS= read -r -d '' f; do
      case "$f" in
        .worktrees/*|.git/*|*/.git/*|node_modules/*|*/node_modules/*|*/) continue ;;
      esac
      if [ -e "$f" ] || [ -L "$f" ]; then printf '%s\0' "$f"; fi
    done ) > "$lst"
  if [ -s "$lst" ]; then
    COPYFILE_DISABLE=1 tar -C "$root" -cf - --null -T "$lst" 2>> "$BOX/clone.log" | tar -C "$BOX/repo" -xf - 2>> "$BOX/clone.log"
  fi
  # deletions in the working tree are applied in the copy
  ( cd "$root" && git ls-files -z -d ) | while IFS= read -r -d '' f; do rm -f -- "$BOX/repo/$f"; done
  if [ "$uname_s" = Darwin ]; then
    printf '#!/bin/bash\nexec /usr/bin/mktemp -p "$TMPDIR" "$@"\n' > "$BOX/bin/mktemp"
    chmod +x "$BOX/bin/mktemp"
  fi
  return 0
}

# ---- sandbox command and cleared environment (arrays, used by runrow and the probe)
sbx=(); envv=(); tmo=()
setup_exec() {
  local safepath="" d oldifs q
  oldifs=$IFS; IFS=:; set -f
  for d in $PATH; do
    [ -n "$d" ] || continue
    if [ -n "$caller_home" ]; then
      case "$d/" in "$caller_home"/*) continue ;; esac
    fi
    safepath="$safepath:$d"
  done
  set +f; IFS=$oldifs
  safepath="${safepath#:}:/usr/bin:/bin"
  envv=(/usr/bin/env -i "PATH=$BOX/bin:$safepath" "HOME=$BOX/home" "TMPDIR=$BOX/tmp" "LANG=${LANG:-C}" "LC_ALL=${LC_ALL:-}" GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0)
  if [ "$sbtool" = sandbox-exec ]; then
    {
      echo '(version 1)'
      echo '(allow default)'
      echo '(deny network*)'
      echo '(deny mach-lookup)'
      echo '(deny appleevent-send)'
      echo '(deny file-write*)'
      q=$(printf '%s' "$BOX" | sed 's/[\\"]/\\&/g')
      echo "(allow file-write* (subpath \"$q\") (literal \"/dev/null\") (literal \"/dev/tty\") (literal \"/dev/dtracehelper\"))"
      if [ -n "$caller_home" ]; then
        q=$(printf '%s' "$caller_home" | sed 's/[\\"]/\\&/g')
        echo "(deny file-read* (subpath \"$q\"))"
      fi
    } > "$BOX/profile.sb"
    sbx=(/usr/bin/sandbox-exec -f "$BOX/profile.sb")
  else
    sbx=(bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp)
    [ -n "$caller_home" ] && sbx=("${sbx[@]}" --tmpfs "$caller_home")
    sbx=("${sbx[@]}" --bind "$BOX" "$BOX" --unshare-all --die-with-parent --new-session --chdir "$BOX/repo")
  fi
  [ "$have_perl" -eq 1 ] && tmo=(perl -e 'alarm shift; exec @ARGV' 300)
}

# runrow <command> <output file>: one row, inside the sandbox, cwd = the copy
runrow() {
  ( cd "$BOX/repo" 2>/dev/null && "${tmo[@]}" "${sbx[@]}" "${envv[@]}" bash -c "$1" ) > "$2" 2>&1 < /dev/null
}

# probe: the denials must be observed before any row runs. Sets probe_state.
probe_state="ok"
probe() {
  local fails=""
  probe_dir=$(mkscratch gate3-probe) || { probe_state="failed p0"; return 1; }
  # p1: a write outside the box must fail and leave no file
  ( cd "$BOX/repo" && "${sbx[@]}" "${envv[@]}" bash -c 'echo x > "$1/p1"' _ "$probe_dir" ) > /dev/null 2>&1 < /dev/null
  [ $? -ne 0 ] && [ ! -e "$probe_dir/p1" ] || fails="$fails p1"
  # p2: the caller's HOME must not be listable
  if [ -n "$caller_home" ]; then
    ( cd "$BOX/repo" && "${sbx[@]}" "${envv[@]}" bash -c 'ls "$1"' _ "$caller_home" ) > /dev/null 2>&1 < /dev/null
    [ $? -ne 0 ] || fails="$fails p2"
  fi
  # p3: no outward connection (on an offline host this fails anyway: nothing can go outward)
  ( cd "$BOX/repo" && "${tmo[@]}" "${sbx[@]}" "${envv[@]}" bash -c 'exec 3<>/dev/tcp/1.1.1.1/53' ) > /dev/null 2>&1 < /dev/null
  [ $? -ne 0 ] || fails="$fails p3"
  # p4: a write inside the box must work
  ( cd "$BOX/repo" && "${sbx[@]}" "${envv[@]}" bash -c 'touch "$1/.gate3-probe"' _ "$BOX/repo" ) > /dev/null 2>&1 < /dev/null
  if [ $? -eq 0 ] && [ -e "$BOX/repo/.gate3-probe" ]; then rm -f "$BOX/repo/.gate3-probe"; else fails="$fails p4"; fi
  if [ -n "$fails" ]; then probe_state="failed${fails}"; return 1; fi
  return 0
}

# ---- decide whether rows can run
notrun_reason=""
if [ "$ncmd" -eq 0 ]; then
  probe_state="not-needed (no commands)"
elif [ "$sbtool" = none ]; then
  notrun_reason="no sandbox (sandbox-exec or bwrap) on $uname_s"
  probe_state="not-run"
else
  if build_box; then
    setup_exec
    if ! probe; then
      notrun_reason="sandbox probe failed (${probe_state#failed }"; notrun_reason="${notrun_reason})"
    fi
  else
    notrun_reason="could not build the box ($box_reason)"
    probe_state="not-run"
  fi
fi

if [ -n "$BOX" ] && [ -d "$BOX/repo" ]; then
  sha=$(git -C "$BOX/repo" rev-parse --short HEAD 2>/dev/null)
else
  sha=$(git -C "$root" rev-parse --short HEAD 2>/dev/null)
fi

{
  [ -n "$rid" ] && echo "dispatch_id: $rid"
  echo "# AC re-run: $handoff @ $sha"
  echo "# box: ${BOX:-none} (removed on exit)"
  echo "sandbox: $sbtool probe: $probe_state"
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
  if [ -n "$notrun_reason" ]; then
    printf '| %s | not-run: %s — run by hand | %s |\n' "$name" "$notrun_reason" "$shown" >> "$work/table.txt"
    continue
  fi
  runrow "$payload" "$BOX/o.txt"
  ec=$?
  printf '| %s | %s | %s |\n' "$name" "$ec" "$shown" >> "$work/table.txt"
  { echo; echo "### $name"; echo '```'; head -40 "$BOX/o.txt"; echo '```'; } >> "$work/detail.txt"
done < "$work/rows.txt"

if [ -n "$out" ]; then
  cat "$work/head.txt" "$work/table.txt" "$work/detail.txt" > "$out"
else
  cat "$work/head.txt" "$work/table.txt" "$work/detail.txt"
fi
exit 0
