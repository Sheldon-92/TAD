#!/usr/bin/env bash
# path-guard.sh — HP-1 (protected path) + PT-1 (traversal) + BW-3 (Bash write-path)
# v3-LEAN §1 HP-1/PT-1 + §1 BW-3
# Source from dispatcher. Loads .tad/schemas/protected-paths.yaml once.
# Functions:
#   check_path_protected <path>          → 0 allow | 1 deny (reason on stderr)
#   check_path_traversal <path>          → 0 allow | 1 deny
#   check_bash_write_target <command>    → 0 allow | 1 deny (reason on stderr)

# shellcheck shell=bash
set -uo pipefail

# Assume dep-guard has been sourced + required deps (yq, awk, perl) are present.
: "${PATH_GUARD_LOADED:=0}"
if [[ "$PATH_GUARD_LOADED" == "1" ]]; then return 0 2>/dev/null || exit 0; fi
PATH_GUARD_LOADED=1

PG_SCHEMA="${PG_SCHEMA:-.tad/schemas/protected-paths.yaml}"

# Load globs/exacts/name_patterns + bash_write_protected_prefix + env_injection_patterns
# into arrays ONCE at source time.
_pg_load_schema() {
  if [[ ! -f "$PG_SCHEMA" ]]; then
    # Fail-closed: if schema missing, deny everything (will be caught by dep-guard anyway)
    printf 'PATH_GUARD_ERROR: schema missing: %s\n' "$PG_SCHEMA" >&2
    return 1
  fi
  # Cache expansion — single yq call dumps each list as newline-separated
  PG_GLOBS=$(yq -r '.protected_paths.glob[]?' "$PG_SCHEMA" 2>/dev/null || true)
  PG_EXACTS=$(yq -r '.protected_paths.exact[]?' "$PG_SCHEMA" 2>/dev/null || true)
  PG_NAMEPATS=$(yq -r '.protected_paths.name_pattern[]?' "$PG_SCHEMA" 2>/dev/null || true)
  PG_BASH_PREFIX=$(yq -r '.bash_write_protected_prefix[]?' "$PG_SCHEMA" 2>/dev/null || true)
  PG_GATE_ALLOW=$(yq -r '.gate_verdict_allowlist[]?' "$PG_SCHEMA" 2>/dev/null || true)
  return 0
}
_pg_load_schema || true

# Canonicalize a path (handle ~ expansion + realpath for symlinks + relative→absolute).
# Output goes to stdout. Always succeeds (falls back to input).
_pg_canon() {
  local p="$1"
  # ~ expansion
  case "$p" in
    "~/"*) p="${HOME}/${p#~/}" ;;
    "~") p="${HOME}" ;;
  esac
  # Absolute vs relative
  local abs
  if command -v realpath >/dev/null 2>&1; then
    abs=$(realpath -q "$p" 2>/dev/null || true)
  fi
  if [[ -z "${abs:-}" ]]; then
    # Fallback: python? no. Use pwd for relative.
    if [[ "$p" = /* ]]; then
      abs="$p"
    else
      abs="$(pwd)/$p"
    fi
  fi
  printf '%s\n' "$abs"
}

# Check if canonicalized path matches a glob pattern.
# Glob patterns use ** for recursive, * for single-segment.
_pg_glob_match() {
  local path="$1" pattern="$2"
  # Convert glob to bash extglob/regex-ish
  case "$pattern" in
    "~/"*)
      pattern="${HOME}/${pattern#~/}"
      ;;
  esac
  # Expand ** → any; * → non-slash-any
  local regex
  regex=$(printf '%s' "$pattern" \
    | sed 's|[].[^$()+{}|]|\\&|g' \
    | sed 's|\\\*\\\*|__DOUBLESTAR__|g' \
    | sed 's|\\\*|[^/]*|g' \
    | sed 's|__DOUBLESTAR__|.*|g')
  # Anchor
  [[ "$path" =~ ^${regex}$ ]]
}

# HP-1: check if the target path is in the protected set.
# Also checks gate_verdict_allowlist carve-out (AC17).
# Returns 0 allow, 1 deny with reason on stderr.
check_path_protected() {
  local raw="$1"
  [[ -z "$raw" ]] && return 0
  local path
  path=$(_pg_canon "$raw")
  local repo
  repo=$(pwd)
  local rel="$path"
  if [[ "$path" = "$repo"/* ]]; then
    rel="${path#"$repo"/}"
  fi

  # AC17 carve-out: gate verdict tsv paths are allowed (append-only enforcement
  # happens in writer, not here — this guard only ensures hook doesn't block).
  local pat
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    if _pg_glob_match "$rel" "$pat" || _pg_glob_match "$path" "$pat"; then
      return 0
    fi
  done <<< "$PG_GATE_ALLOW"

  # Globs
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    if _pg_glob_match "$rel" "$pat" || _pg_glob_match "$path" "$pat"; then
      printf 'HP-1: protected path matched glob "%s" → path=%s\n' "$pat" "$path" >&2
      return 1
    fi
  done <<< "$PG_GLOBS"

  # Exact
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    local exp="$pat"
    case "$exp" in "~/"*) exp="${HOME}/${exp#~/}" ;; esac
    if [[ "$path" == "$exp" || "$rel" == "$pat" ]]; then
      printf 'HP-1: protected path matched exact "%s"\n' "$pat" >&2
      return 1
    fi
  done <<< "$PG_EXACTS"

  # Name pattern (basename)
  local base
  base=$(basename -- "$path")
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    # Translate simple * glob on basename
    local re
    re=$(printf '%s' "$pat" | sed 's|[].[^$()+{}|]|\\&|g; s|\\\*|.*|g')
    if [[ "$base" =~ ^${re}$ ]]; then
      printf 'HP-1: protected path matched name pattern "%s" (basename=%s)\n' "$pat" "$base" >&2
      return 1
    fi
  done <<< "$PG_NAMEPATS"

  return 0
}

# PT-1: reject any .. segment in the ORIGINAL path (pre-canonicalization).
# Canonicalization resolves .. away, so we must check the raw string.
check_path_traversal() {
  local raw="$1"
  [[ -z "$raw" ]] && return 0
  # Match /../ or ^../ or /..$ or =..=
  if printf '%s' "$raw" | grep -qE '(^|/)\.\.(/|$)'; then
    printf 'PT-1: path traversal segment (..) in path=%s\n' "$raw" >&2
    return 1
  fi
  return 0
}

# BW-3: extract all write-path targets from a Bash command and check each against
# bash_write_protected_prefix. Covers:
#   >, >>, &>, 2>>, tee, cp, mv, ln, ln -s, rsync, install, sed -i, touch, dd of=,
#   python -c, perl -e, node -e  (all → extract target file).
# Uses a single perl pass to enumerate targets.
check_bash_write_target() {
  local cmd="$1"
  [[ -z "$cmd" ]] && return 0
  [[ -z "$PG_BASH_PREFIX" ]] && return 0

  # Perl extracts candidate target paths (one per line). Strategy: tokenize and
  # look for the recognized operators; emit their argument(s). Conservative —
  # prefer false-positive deny to false-negative allow, since override exists.
  local targets
  targets=$(printf '%s' "$cmd" | perl -CSD -e '
    local $/;
    my $c = <STDIN>;
    my @out;
    # Redirect operators: N>, N>>, &>, N>, >>  → capture next token as target
    # (handle quoted forms)
    while ($c =~ m{(?:^|[\s;&|()])(?:\d*>>?|\&>|\d+>>?)\s*(?:"([^"]+)"|'"'"'([^'"'"']+)'"'"'|(\S+))}g) {
      push @out, ($1 // $2 // $3);
    }
    # tee / tee -a / sed -i / sed -i "" / touch / install -m XX / dd of=
    while ($c =~ m{\btee\b(?:\s+-\S+)*\s+(?:"([^"]+)"|'"'"'([^'"'"']+)'"'"'|(\S+))}g) {
      push @out, ($1 // $2 // $3);
    }
    while ($c =~ m{\bsed\b\s+-i\b(?:\s+[^\s"'"'"'-]?[^\s]+)?\s+(?:"([^"]+)"|'"'"'([^'"'"']+)'"'"'|(\S+))}g) {
      push @out, ($1 // $2 // $3);
    }
    while ($c =~ m{\btouch\b(?:\s+-\S+)*\s+(?:"([^"]+)"|'"'"'([^'"'"']+)'"'"'|(\S+))}g) {
      push @out, ($1 // $2 // $3);
    }
    while ($c =~ m{\bdd\b[^;|&]*\bof=(?:"([^"]+)"|'"'"'([^'"'"']+)'"'"'|(\S+))}g) {
      push @out, ($1 // $2 // $3);
    }
    # cp / mv / git mv / rsync / install / ln (last non-flag arg is target)
    for my $verb (qw(cp mv rsync install ln)) {
      while ($c =~ m{\b(?:git\s+mv|$verb)\b(?:\s+-\S+)*\s+((?:"[^"]+"|'"'"'[^'"'"']+'"'"'|\S+)(?:\s+(?:"[^"]+"|'"'"'[^'"'"']+'"'"'|\S+))*)}g) {
        my $args = $1;
        my @toks;
        while ($args =~ m{"([^"]+)"|'"'"'([^'"'"']+)'"'"'|(\S+)}g) {
          push @toks, ($1 // $2 // $3);
        }
        # Last non-flag token is target
        for (my $i = $#toks; $i >= 0; $i--) {
          next if $toks[$i] =~ /^-/;
          push @out, $toks[$i];
          last;
        }
      }
    }
    # Interpreter write: python -c "...open(...,w)..." etc — too dynamic to reliably
    # parse. Conservative heuristic: any python/perl/node -c/-e command that
    # contains a literal path under .tad/ → flag the literal.
    for my $lang (qw(python python3 perl node)) {
      while ($c =~ m{\b$lang\b\s+-[ceC]\s+(?:"([^"]*(?:\.tad/[^"]*)?)"|'"'"'([^'"'"']*(?:\.tad/[^'"'"']*)?)'"'"')}g) {
        my $code = $1 // $2;
        while ($code =~ m{(\.tad/[\w./-]+)}g) {
          push @out, $1;
        }
      }
    }
    print "$_\n" for @out;
  ')

  [[ -z "$targets" ]] && return 0

  local t canon rel pfx bad=0 hit=""
  while IFS= read -r t; do
    [[ -z "$t" ]] && continue
    # Trim
    t="${t#"${t%%[![:space:]]*}"}"; t="${t%"${t##*[![:space:]]}"}"
    canon=$(_pg_canon "$t")
    local repo; repo=$(pwd)
    rel="${canon#"$repo"/}"
    while IFS= read -r pfx; do
      [[ -z "$pfx" ]] && continue
      if [[ "$rel" == "$pfx"* || "$canon" == *"/$pfx"* ]]; then
        bad=1; hit="$t prefix=$pfx"; break 2
      fi
    done <<< "$PG_BASH_PREFIX"
  done <<< "$targets"

  if [[ "$bad" == "1" ]]; then
    printf 'BW-3: bash write target into protected prefix (%s)\n' "$hit" >&2
    return 1
  fi
  return 0
}
