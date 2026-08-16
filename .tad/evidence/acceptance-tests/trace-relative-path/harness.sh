#!/usr/bin/env bash
# Harness for HANDOFF-20260816-trace-relative-path AC suite.
# Source this file from AC scripts (or run bash script.sh explicitly).
# Patterns: mk_sandbox / emit come verbatim from handoff §4 (test-runner verified).

# mk_sandbox DIRNAME   -> prints physical sandbox root (cwd-safe, git init'd)
# emit LIB CWD ABSFILE [nojq] -> runs record_trace in a subshell, prints last jsonl line
#
# P0 notes (handoff §4):
#  - pwd -P is load-bearing: mktemp -d gives /var/..., git rev-parse gives
#    /private/var/... — divergence makes a correct patch look wrong.
#  - HAS_JQ latches at source time (common.sh:6-9); PATH surgery cannot
#    change it, so AC5 must set HAS_JQ=false AFTER sourcing.

mk_sandbox() {
  local box; box=$(mktemp -d); box=$(cd "$box" && pwd -P)   # pwd -P is key
  mkdir -p "$box/$1/.tad/evidence"
  ( cd "$box/$1" && git init -q . )
  # Pre-flight: if the top-level resolves differently than the sandbox, the whole suite is meaningless
  [ "$( cd "$box/$1" && git rev-parse --show-toplevel )" = "$box/$1" ] \
    || { echo "SANDBOX INVALID (symlink divergence)" >&2; exit 1; }
  printf '%s' "$box/$1"
}

emit() {                            # $1=lib $2=cwd $3=abs_file [$4=nojq]
  rm -rf "$2/.tad/evidence/traces"
  ( cd "$2"; source "$1"; [ -n "${4:-}" ] && HAS_JQ=false; record_trace "evidence_created" "$3" )
  tail -1 "$2"/.tad/evidence/traces/*.jsonl
}