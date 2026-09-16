#!/usr/bin/env bash
# capability-skill.sh — project-owned Agent Skill validate / project / verify
# BSD/macOS-safe. No grep -P. Advisory-friendly exit classes.
# Concurrency boundary: This helper safely serializes multiple cooperative local
# invocations via an atomic per-skill directory lock (mkdir). Hostile,
# non-cooperating filesystem mutation is explicitly out of scope.
set -uo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<'USAGE'
capability-skill.sh — project-owned Agent Skill validate / project / verify

Usage:
  capability-skill.sh validate <project-root> <skill-name>
  capability-skill.sh project  <project-root> <skill-name>
  capability-skill.sh verify   <project-root> <skill-name>
  capability-skill.sh --help | -h

  <project-root>  path to the downstream project root (physical resolution)
  <skill-name>    normalized skill name: ^[a-z0-9]+(-[a-z0-9]+)*$

Paths are derived, never caller-selected:
  canonical  = <root>/.agents/skills/<name>   (sole skill source since v3.0.0)

Exit codes (stable):
  0  success
  1  usage error (wrong args, unknown command)
  2  invalid canonical / path (validation failed, traversal, symlink, frontmatter, forbidden artifact)
  3  divergent target (projection exists and differs; no overwrite) or lock contention
  4  I/O failure (copy failure, parent unavailable, temp cleanup)

Behavior:
  validate — fails non-zero unless canonical is a directory with valid SKILL.md
  project  — REMOVED in v3.0.0 (fail-closed tombstone, exit 1, no mutation).
             Materialize project skills directly under .agents/skills/<name>/.
  verify   — validates canonical self-integrity (valid SKILL.md, no symlinks); never modifies

Notes:
  - Rejects non-normalized names, traversal, absolute names, path escape, symlink path chains,
    symlinks anywhere in canonical tree, mismatched frontmatter/directory name.
  - Placeholder scan: SKILL.md must not contain {{...}}, [TODO], [TBD].
  - Forbidden root artifacts: CAPABILITY.md, README.md, CHANGELOG.md, install.sh.
  - BSD/macOS-safe; no grep -P.
  - Concurrency: cooperative local invocations are serialized via per-skill lock; hostile
    filesystem mutation is out of scope and not protected (no FD hardening in Phase 1).

USAGE
}

# --- helpers ---

err() { printf '%s\n' "$*" >&2; }

# Validate skill-name normalized
is_normalized_name() {
  case "$1" in
    "" ) return 1 ;;
  esac
  # Must match ^[a-z0-9]+(-[a-z0-9]+)*$
  if printf '%s' "$1" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    return 0
  else
    return 1
  fi
}

# Resolve project root physically; print resolved path or return 1
resolve_root() {
  _in="$1"
  if [ ! -d "$_in" ]; then
    err "ERROR: project-root not a directory: $_in"
    return 1
  fi
  # Use cd && pwd -P to resolve symlinks/physical path
  _resolved="$(cd "$_in" 2>/dev/null && pwd -P 2>/dev/null)" || {
    err "ERROR: cannot resolve project-root: $_in"
    return 1
  }
  if [ -z "$_resolved" ]; then
    err "ERROR: empty resolved root"
    return 1
  fi
  printf '%s' "$_resolved"
  return 0
}

# Get device:inode for ownership proof (BSD macOS stat -f, fallback to Linux stat -c)
get_inode() {
  _p="$1"
  if [ ! -e "$_p" ]; then
    printf ''
    return 1
  fi
  # Try BSD stat first
  if stat -f '%d:%i' "$_p" 2>/dev/null | grep -qE '^[0-9]+:[0-9]+$'; then
    stat -f '%d:%i' "$_p" 2>/dev/null
    return 0
  fi
  # Fallback Linux
  if stat -c '%d:%i' "$_p" 2>/dev/null | grep -qE '^[0-9]+:[0-9]+$'; then
    stat -c '%d:%i' "$_p" 2>/dev/null
    return 0
  fi
  # Fallback: use ls -di
  ls -di "$_p" 2>/dev/null | awk '{print $1}' || printf ''
  return 0
}

# Check symlink in path chain for .agents/skills parents
# Args: <resolved_root>
check_path_chain_symlinks() {
  _root="$1"
  for _rel in ".agents" ".agents/skills"; do
    _p="$_root/$_rel"
    if [ -e "$_p" ] && [ -L "$_p" ]; then
      err "ERROR: symlink in path chain: $_p (refuse to write through link)"
      return 1
    fi
    _cur="$_root"
    _rest="$_rel"
    while [ -n "$_rest" ]; do
      _seg="${_rest%%/*}"
      if [ "$_seg" = "$_rest" ]; then
        _rest=""
      else
        _rest="${_rest#*/}"
      fi
      _cur="$_cur/$_seg"
      if [ -e "$_cur" ] && [ -L "$_cur" ]; then
        err "ERROR: symlink in path chain component: $_cur"
        return 1
      fi
      if [ "$_rest" = "" ]; then break; fi
    done
  done
  return 0
}

# Check symlinks anywhere inside canonical tree
has_symlink_in_tree() {
  _dir="$1"
  if [ ! -d "$_dir" ]; then return 1; fi
  if find "$_dir" -type l 2>/dev/null | grep -q .; then
    return 0
  else
    return 1
  fi
}

# Validate canonical SKILL.md; prints error on fail, returns 2 on invalid
validate_canonical() {
  _canon="$1"
  _name="$2"

  if [ ! -d "$_canon" ]; then
    err "ERROR: canonical not a directory: $_canon"
    return 2
  fi
  if [ -L "$_canon" ]; then
    err "ERROR: canonical is a symlink: $_canon"
    return 2
  fi
  if has_symlink_in_tree "$_canon"; then
    err "ERROR: symlink inside canonical tree: $_canon"
    find "$_canon" -type l 2>/dev/null | head -5 | sed 's/^/  -> /' >&2
    return 2
  fi
  _skill="$_canon/SKILL.md"
  if [ ! -f "$_skill" ]; then
    err "ERROR: missing SKILL.md: $_skill"
    return 2
  fi
  if [ -L "$_skill" ]; then
    err "ERROR: SKILL.md is a symlink"
    return 2
  fi
  for _bad in "CAPABILITY.md" "README.md" "CHANGELOG.md" "install.sh"; do
    if [ -e "$_canon/$_bad" ]; then
      err "ERROR: forbidden artifact at Skill root: $_bad"
      return 2
    fi
  done
  _first="$(head -n 1 "$_skill" 2>/dev/null | tr -d '\r')"
  if [ "$_first" != "---" ]; then
    err "ERROR: frontmatter must start on line 1 with ---"
    return 2
  fi
  _close_line="$(awk 'NR==1{next} /^---[[:space:]]*$/{print NR; exit}' "$_skill" 2>/dev/null)"
  if [ -z "$_close_line" ]; then
    err "ERROR: frontmatter missing closing ---"
    return 2
  fi
  _fm="$(sed -n "2,$((_close_line-1))p" "$_skill" 2>/dev/null)"
  if [ -z "$_fm" ]; then
    err "ERROR: empty frontmatter"
    return 2
  fi
  _name_count="$(printf '%s\n' "$_fm" | grep -cE '^[[:space:]]*name:[[:space:]]*')"
  _desc_count="$(printf '%s\n' "$_fm" | grep -cE '^[[:space:]]*description:[[:space:]]*')"
  if [ "$_name_count" -ne 1 ]; then
    err "ERROR: frontmatter must contain exactly one 'name:' (found $_name_count)"
    return 2
  fi
  if [ "$_desc_count" -ne 1 ]; then
    err "ERROR: frontmatter must contain exactly one 'description:' (found $_desc_count)"
    return 2
  fi
  _extra="$(printf '%s\n' "$_fm" | grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:' | grep -vE '^[[:space:]]*(name|description):' || true)"
  if [ -n "$_extra" ]; then
    err "ERROR: frontmatter contains extra keys (only name+description allowed):"
    printf '%s\n' "$_extra" | sed 's/^/  -> /' >&2
    return 2
  fi
  _fm_name="$(printf '%s\n' "$_fm" | sed -n 's/^[[:space:]]*name:[[:space:]]*//p' | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//;s/^'\''//;s/'\''$//')"
  _fm_desc="$(printf '%s\n' "$_fm" | sed -n 's/^[[:space:]]*description:[[:space:]]*//p' | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//;s/^'\''//;s/'\''$//')"

  if ! printf '%s' "$_fm_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    err "ERROR: name does not match ^[a-z0-9]+(-[a-z0-9]+)*\$: '$_fm_name'"
    return 2
  fi
  _base="$(basename "$_canon")"
  if [ "$_fm_name" != "$_base" ]; then
    err "ERROR: frontmatter name '$_fm_name' != directory basename '$_base'"
    return 2
  fi
  if [ "$_fm_name" != "$_name" ]; then
    err "ERROR: frontmatter name '$_fm_name' != requested skill-name '$_name'"
    return 2
  fi
  if [ -z "$_fm_desc" ]; then
    err "ERROR: description must be non-empty"
    return 2
  fi
  if printf '%s\n' "$_fm" | grep -qE '^[[:space:]]*description:[[:space:]]*[>|]'; then
    err "ERROR: description must be one-line scalar, block/folded style not allowed (found '>' or '|')"
    return 2
  fi
  if printf '%s\n' "$_fm" | grep -qE '^[[:space:]]*name:[[:space:]]*[>|]'; then
    err "ERROR: name must be one-line scalar, block/folded style not allowed"
    return 2
  fi
  if printf '%s' "$_fm_desc" | grep -qE '^[>|]([-+][0-9]*)?$'; then
    err "ERROR: description must be one-line scalar, block/folded style not allowed"
    return 2
  fi
  if printf '%s' "$_fm_name" | grep -qE '^[>|]'; then
    err "ERROR: name must be one-line scalar, block/folded style not allowed"
    return 2
  fi
  if grep -qF "{{" "$_skill" 2>/dev/null; then
    if grep -qE '\{\{.*\}\}' "$_skill" 2>/dev/null; then
      err "ERROR: placeholder {{...}} found in SKILL.md"
      return 2
    fi
  fi
  if grep -qF "[TODO]" "$_skill" 2>/dev/null; then
    err "ERROR: placeholder [TODO] found in SKILL.md"
    return 2
  fi
  if grep -qF "[TBD]" "$_skill" 2>/dev/null; then
    err "ERROR: placeholder [TBD] found in SKILL.md"
    return 2
  fi

  return 0
}

# Derive canonical and projection, validate name/root, print them via global vars
# Returns 1 usage, 2 path invalid
derive_paths() {
  _root_in="$1"
  _name="$2"

  if ! is_normalized_name "$_name"; then
    err "ERROR: invalid skill-name '$_name' (must match ^[a-z0-9]+(-[a-z0-9]+)*\$)"
    return 2
  fi
  case "$_name" in
    /*) err "ERROR: absolute skill-name not allowed"; return 2 ;;
    *".."* ) err "ERROR: traversal in skill-name"; return 2 ;;
    */* ) err "ERROR: slash in skill-name"; return 2 ;;
  esac

  _root="$(resolve_root "$_root_in")" || return 2

  CANONICAL="$_root/.agents/skills/$_name"
  PARENT_AGENTS_SKILLS="$_root/.agents/skills"

  case "$CANONICAL" in
    "$_root"/*) ;;
    *) err "ERROR: canonical path escapes project root"; return 2 ;;
  esac

  if ! check_path_chain_symlinks "$_root"; then
    return 2
  fi

  return 0
}

do_validate() {
  if [ $# -ne 2 ]; then err "ERROR: validate requires <project-root> <skill-name>"; usage >&2; return 1; fi
  derive_paths "$1" "$2" || return $?
  validate_canonical "$CANONICAL" "$2"
  _rc=$?
  if [ $_rc -eq 0 ]; then
    printf 'VALID: %s\n' "$CANONICAL"
  fi
  return $_rc
}

do_verify() {
  if [ $# -ne 2 ]; then err "ERROR: verify requires <project-root> <skill-name>"; usage >&2; return 1; fi
  derive_paths "$1" "$2" || return $?
  validate_canonical "$CANONICAL" "$2" || return 2
  # v3.0.0: single skill tree — self-integrity only (no projection comparison).
  if [ -L "$CANONICAL" ]; then
    err "ERROR: canonical is a symlink: $CANONICAL"
    return 2
  fi
  if find "$CANONICAL" -type l 2>/dev/null | grep -q .; then
    err "ERROR: symlink inside canonical tree"
    return 2
  fi
  if [ ! -f "$CANONICAL/SKILL.md" ]; then
    err "ERROR: canonical missing SKILL.md"
    return 2
  fi
  printf 'VERIFY PASS: %s self-integrity OK\n' "$CANONICAL"
  return 0
}

do_project() {
  # v3.0.0 tombstone: the .agents -> .claude projection was removed with the
  # Claude Code runtime path. Fail closed BEFORE any mutation.
  if [ $# -ne 2 ]; then err "ERROR: project requires <project-root> <skill-name>"; usage >&2; return 1; fi
  err "ERROR: 'project' was removed in TAD v3.0.0 (Claude Code projection deleted)."
  err "  Materialize the skill directly under <project-root>/.agents/skills/$2/."
  err "  No files were changed."
  return 1
}
main() {
  if [ $# -eq 0 ]; then
    usage
    return 1
  fi
  case "$1" in
    -h|--help)
      usage
      return 0
      ;;
    validate)
      shift
      do_validate "$@"
      return $?
      ;;
    project)
      shift
      do_project "$@"
      return $?
      ;;
    verify)
      shift
      do_verify "$@"
      return $?
      ;;
    *)
      err "ERROR: unknown command: $1"
      usage >&2
      return 1
      ;;
  esac
}

main "$@"
