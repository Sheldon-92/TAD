#!/usr/bin/env bash
# capability-skill.sh — project-owned Agent Skill validate / project / verify
# BSD/macOS-safe. No grep -P. Advisory-friendly exit classes.
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
  canonical  = <root>/.agents/skills/<name>
  projection = <root>/.claude/skills/<name>

Exit codes (stable):
  0  success
  1  usage error (wrong args, unknown command)
  2  invalid canonical / path (validation failed, traversal, symlink, frontmatter, forbidden artifact)
  3  divergent target (projection exists and differs; no overwrite) or lock contention
  4  I/O failure (copy failure, parent unavailable, temp cleanup)

Behavior:
  validate — fails non-zero unless canonical is a directory with valid SKILL.md
  project  — validates first; absent target → temp sibling copy+verify+rename;
             identical target → no-op; divergent → exit 3 without mutation;
             may create missing .claude/skills parents only after containment/symlink checks
  verify   — validates canonical, then byte-compares canonical vs projection; never modifies

Notes:
  - Rejects non-normalized names, traversal, absolute names, path escape, symlink path chains,
    symlinks anywhere in canonical tree, mismatched frontmatter/directory name.
  - Placeholder scan: SKILL.md must not contain {{...}}, [TODO], [TBD].
  - Forbidden root artifacts: CAPABILITY.md, README.md, CHANGELOG.md, install.sh.
  - BSD/macOS-safe; no grep -P.

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

# Check symlink in path chain for .agents/skills and .claude/skills parents
# Args: <resolved_root>
check_path_chain_symlinks() {
  _root="$1"
  for _rel in ".agents" ".agents/skills" ".claude" ".claude/skills"; do
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
  PROJECTION="$_root/.claude/skills/$_name"
  PARENT_CLAUDE_SKILLS="$_root/.claude/skills"
  PARENT_AGENTS_SKILLS="$_root/.agents/skills"

  case "$CANONICAL" in
    "$_root"/*) ;;
    *) err "ERROR: canonical path escapes project root"; return 2 ;;
  esac
  case "$PROJECTION" in
    "$_root"/*) ;;
    *) err "ERROR: projection path escapes project root"; return 2 ;;
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
  if [ ! -d "$PROJECTION" ]; then
    err "ERROR: projection missing: $PROJECTION"
    return 3
  fi
  if [ -L "$PROJECTION" ]; then
    err "ERROR: projection is a symlink: $PROJECTION"
    return 2
  fi
  if find "$PROJECTION" -type l 2>/dev/null | grep -q .; then
    err "ERROR: symlink inside projection tree"
    return 2
  fi
  if [ ! -f "$PROJECTION/SKILL.md" ]; then
    err "ERROR: projection missing SKILL.md"
    return 3
  fi
  _out="$(diff -rq "$CANONICAL" "$PROJECTION" 2>&1)" || true
  if [ -z "$_out" ]; then
    printf 'VERIFY PASS: %s <-> %s byte-identical\n' "$CANONICAL" "$PROJECTION"
    return 0
  else
    err "ERROR: projection differs from canonical:"
    printf '%s\n' "$_out" | sed 's/^/  /' >&2 | head -20
    return 3
  fi
}

do_project() {
  if [ $# -ne 2 ]; then err "ERROR: project requires <project-root> <skill-name>"; usage >&2; return 1; fi
  derive_paths "$1" "$2" || return $?
  _skill_name="$2"

  CREATED_CLAUDE_DIR=0
  CREATED_SKILLS_DIR=0
  _tmp=""
  LOCK_DIR=""
  LOCK_ID=""
  _published_by_this_invocation=0
  _published_inode=""

  # Cleanup handler for lock and temp owned by this invocation
  cleanup_project_resources() {
    # Remove temp if we created it and it still exists and is inside expected parent
    if [ -n "${_tmp:-}" ] && [ -d "$_tmp" ]; then
      case "$_tmp" in
        "$_claude_skills_dir/.tmp."* | "$PARENT_CLAUDE_SKILLS/.tmp."*)
          rm -rf "$_tmp" 2>/dev/null || true
          ;;
      esac
    fi
    # Remove lock only if we own it
    if [ -n "${LOCK_DIR:-}" ] && [ -n "${LOCK_ID:-}" ] && [ -d "$LOCK_DIR" ]; then
      cur_id="$(get_inode "$LOCK_DIR" 2>/dev/null || echo "")"
      if [ "$cur_id" = "$LOCK_ID" ] && [ -n "$cur_id" ]; then
        rmdir "$LOCK_DIR" 2>/dev/null || true
      fi
    fi
  }

  # Validate first; fail without touching target
  if ! validate_canonical "$CANONICAL" "$_skill_name"; then
    return 2
  fi

  _root_dir="$(resolve_root "$1")" || return 2
  _claude_dir="$_root_dir/.claude"
  _claude_skills_dir="$_root_dir/.claude/skills"

  _claude_existed=0
  _skills_existed=0
  [ -d "$_claude_dir" ] && _claude_existed=1
  [ -d "$_claude_skills_dir" ] && _skills_existed=1
  _projection_existed_before=0
  [ -e "$PROJECTION" ] && _projection_existed_before=1

  if [ "$_claude_existed" -eq 0 ]; then
    if ! mkdir -p "$_claude_dir" 2>/dev/null; then
      err "ERROR: cannot create .claude directory: $_claude_dir"
      return 4
    fi
    CREATED_CLAUDE_DIR=1
  fi
  if [ "$_skills_existed" -eq 0 ]; then
    if ! mkdir -p "$_claude_skills_dir" 2>/dev/null; then
      err "ERROR: cannot create .claude/skills directory"
      if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -d "$_claude_dir" ]; then
        rmdir "$_claude_dir" 2>/dev/null || true
      fi
      return 4
    fi
    CREATED_SKILLS_DIR=1
  fi

  if [ -L "$_claude_dir" ] || [ -L "$_claude_skills_dir" ]; then
    err "ERROR: created path is a symlink (race)"
    if [ "$CREATED_SKILLS_DIR" -eq 1 ]; then rmdir "$_claude_skills_dir" 2>/dev/null || true; fi
    if [ "$CREATED_CLAUDE_DIR" -eq 1 ]; then rmdir "$_claude_dir" 2>/dev/null || true; fi
    return 2
  fi

  # Acquire per-skill lock (cooperative concurrency, P1-2)
  # Lock path derived from project root + normalized skill name, not caller-specified
  LOCK_DIR="$_claude_skills_dir/.lock.${_skill_name}"
  # Re-check path chain before lock acquisition
  if ! check_path_chain_symlinks "$_root_dir"; then
    if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null)" ]; then
      rmdir "$_claude_skills_dir" 2>/dev/null || true
      if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_dir" 2>/dev/null)" ]; then
        rmdir "$_claude_dir" 2>/dev/null || true
      fi
    fi
    return 2
  fi
  if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    err "ERROR: lock exists for $_skill_name (contention), refusing to proceed"
    # Do not modify canonical/projection; clean up empty parents we created if they remain empty
    if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null)" ]; then
      rmdir "$_claude_skills_dir" 2>/dev/null || true
      if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_dir" 2>/dev/null)" ]; then
        rmdir "$_claude_dir" 2>/dev/null || true
      fi
    fi
    return 3
  fi
  LOCK_ID="$(get_inode "$LOCK_DIR" 2>/dev/null || echo "")"
  # Ensure lock cleanup on exit, but only if we own it
  trap 'cleanup_project_resources' EXIT
  trap 'cleanup_project_resources; exit 4' INT TERM HUP

  # Re-check path chain and target after lock acquisition (fail-closed)
  if ! check_path_chain_symlinks "$_root_dir"; then
    err "ERROR: path chain became symlinked after lock acquisition"
    cleanup_project_resources
    trap - EXIT INT TERM HUP
    return 2
  fi

  # Target state handling — now under lock
  if [ ! -e "$PROJECTION" ]; then
    _tmp="$(mktemp -d "$_claude_skills_dir/.tmp.${_skill_name}.XXXXXX" 2>/dev/null)" || {
      err "ERROR: cannot create temp sibling in $_claude_skills_dir"
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      if [ "$CREATED_SKILLS_DIR" -eq 1 ]; then rmdir "$_claude_skills_dir" 2>/dev/null || true; fi
      if [ "$CREATED_CLAUDE_DIR" -eq 1 ]; then rmdir "$_claude_dir" 2>/dev/null || true; fi
      return 4
    }
    if ! cp -R "$CANONICAL/." "$_tmp/" 2>/dev/null; then
      err "ERROR: copy failed to temp sibling"
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null | grep -v "^\.lock")" ]; then
        if [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null | grep -v "^\.lock")" ]; then
          # Only empty besides lock; lock still held, so not empty yet
          true
        fi
      fi
      return 4
    fi
    _vout="$(diff -rq "$CANONICAL" "$_tmp" 2>&1)" || true
    if [ -n "$_vout" ]; then
      err "ERROR: verify failed after copy to temp"
      printf '%s\n' "$_vout" | sed 's/^/  /' >&2
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      return 4
    fi
    # Re-check target absence after holding lock (contention check)
    if [ -e "$PROJECTION" ]; then
      err "ERROR: target appeared before publish (contention), refusing to overwrite"
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      return 3
    fi
    # Re-check path chain again before publish
    if ! check_path_chain_symlinks "$_root_dir"; then
      err "ERROR: path chain became symlinked before publish"
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      return 2
    fi
    if ! mv "$_tmp" "$PROJECTION" 2>/dev/null; then
      err "ERROR: rename temp to projection failed"
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      return 4
    fi
    # Mark published and record ownership token (device:inode)
    _published_by_this_invocation=1
    _published_inode="$(get_inode "$PROJECTION" 2>/dev/null || echo "")"
    _tmp=""  # Clear temp so cleanup handler does not try to remove it again (now moved)
    # Final verify byte identity — rollback on failure with ownership proof (P1-3)
    _fout="$(diff -rq "$CANONICAL" "$PROJECTION" 2>&1)" || true
    if [ -n "$_fout" ]; then
      err "ERROR: final verify after rename failed"
      printf '%s\n' "$_fout" | sed 's/^/  /' >&2
      # Rollback only if we published and still own lock and projection is still ours
      if [ "$_published_by_this_invocation" -eq 1 ] && [ -n "$LOCK_ID" ] && [ -d "$LOCK_DIR" ]; then
        cur_lock_id="$(get_inode "$LOCK_DIR" 2>/dev/null || echo "")"
        cur_proj_id="$(get_inode "$PROJECTION" 2>/dev/null || echo "")"
        if [ "$cur_lock_id" = "$LOCK_ID" ] && [ "$cur_proj_id" = "$_published_inode" ] && [ -n "$cur_lock_id" ] && [ -n "$cur_proj_id" ]; then
          rm -rf "$PROJECTION" 2>/dev/null || true
          if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null | grep -v "^\.lock")" ]; then
            # Only lock remains; after we release lock, parent may become empty
            true
          fi
        else
          err "ERROR: ownership cannot be proven for rollback, refusing to delete (lock or projection changed)"
          cleanup_project_resources
          trap - EXIT INT TERM HUP
          return 4
        fi
      fi
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      return 4
    fi
    # Success: release lock and clear trap
    cleanup_project_resources
    trap - EXIT INT TERM HUP
    # Remove lock after successful publish (cleanup handler already does, but ensure)
    # Lock already removed by cleanup_project_resources
    printf 'PROJECTED: %s -> %s\n' "$CANONICAL" "$PROJECTION"
    return 0
  else
    # Target exists → check divergent (under lock)
    if [ -L "$PROJECTION" ]; then
      err "ERROR: projection is a symlink, refusing"
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      return 2
    fi
    _dout="$(diff -rq "$CANONICAL" "$PROJECTION" 2>&1)" || true
    if [ -z "$_dout" ]; then
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      printf 'PROJECT NO-OP: target already byte-identical\n'
      return 0
    else
      err "ERROR: divergent target exists, refusing to overwrite:"
      printf '%s\n' "$_dout" | sed 's/^/  /' >&2 | head -20
      cleanup_project_resources
      trap - EXIT INT TERM HUP
      return 3
    fi
  fi
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
