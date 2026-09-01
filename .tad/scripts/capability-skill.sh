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
  3  divergent target (projection exists and differs; no overwrite)
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

# Check symlink in path chain for .agents/skills and .claude/skills parents
# Args: <resolved_root>
check_path_chain_symlinks() {
  _root="$1"
  # Check each component from root down to .agents, .agents/skills, .claude, .claude/skills if they exist
  for _rel in ".agents" ".agents/skills" ".claude" ".claude/skills"; do
    _p="$_root/$_rel"
    if [ -e "$_p" ] && [ -L "$_p" ]; then
      err "ERROR: symlink in path chain: $_p (refuse to write through link)"
      return 1
    fi
    # Also check intermediate if path exists partially: need to walk components
    # For deeper safety, check each parent directory of _p that exists is not a symlink
    # Walk from root to leaf: split _rel by /
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
      # If segment doesn't exist yet, loop will still check but -e false so continue
      # Need to also handle case where _cur exists but is symlink even if _p doesn't exist
      # Already handled
      if [ "$_rest" = "" ]; then break; fi
    done
  done
  return 0
}

# Check symlinks anywhere inside canonical tree
has_symlink_in_tree() {
  _dir="$1"
  if [ ! -d "$_dir" ]; then return 1; fi
  # find -type l
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
  # Single check for forbidden root artifacts
  for _bad in "CAPABILITY.md" "README.md" "CHANGELOG.md" "install.sh"; do
    if [ -e "$_canon/$_bad" ]; then
      err "ERROR: forbidden artifact at Skill root: $_bad"
      return 2
    fi
  done
  # Frontmatter must start at line 1 with ---
  _first="$(head -n 1 "$_skill" 2>/dev/null | tr -d '\r')"
  if [ "$_first" != "---" ]; then
    err "ERROR: frontmatter must start on line 1 with ---"
    return 2
  fi
  # Find closing fence
  _close_line="$(awk 'NR==1{next} /^---[[:space:]]*$/{print NR; exit}' "$_skill" 2>/dev/null)"
  if [ -z "$_close_line" ]; then
    err "ERROR: frontmatter missing closing ---"
    return 2
  fi
  # Extract frontmatter block (lines 2 to close-1)
  _fm="$(sed -n "2,$((_close_line-1))p" "$_skill" 2>/dev/null)"
  if [ -z "$_fm" ]; then
    err "ERROR: empty frontmatter"
    return 2
  fi
  # Must contain exactly one name and one description, each once
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
  # Ensure no extra frontmatter keys beyond name and description
  # Allowed keys are exactly name and description (one-line scalars)
  _extra="$(printf '%s\n' "$_fm" | grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:' | grep -vE '^[[:space:]]*(name|description):' || true)"
  if [ -n "$_extra" ]; then
    err "ERROR: frontmatter contains extra keys (only name+description allowed):"
    printf '%s\n' "$_extra" | sed 's/^/  -> /' >&2
    return 2
  fi
  # Extract name and description values
  _fm_name="$(printf '%s\n' "$_fm" | sed -n 's/^[[:space:]]*name:[[:space:]]*//p' | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//;s/^'\''//;s/'\''$//')"
  _fm_desc="$(printf '%s\n' "$_fm" | sed -n 's/^[[:space:]]*description:[[:space:]]*//p' | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//;s/^'\''//;s/'\''$//')"

  # Validate name format
  if ! printf '%s' "$_fm_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    err "ERROR: name does not match ^[a-z0-9]+(-[a-z0-9]+)*\$: '$_fm_name'"
    return 2
  fi
  # Must match directory basename
  _base="$(basename "$_canon")"
  if [ "$_fm_name" != "$_base" ]; then
    err "ERROR: frontmatter name '$_fm_name' != directory basename '$_base'"
    return 2
  fi
  # Also must match requested skill-name (if different, error)
  if [ "$_fm_name" != "$_name" ]; then
    err "ERROR: frontmatter name '$_fm_name' != requested skill-name '$_name'"
    return 2
  fi
  # description non-empty
  if [ -z "$_fm_desc" ]; then
    err "ERROR: description must be non-empty"
    return 2
  fi
  # Reject block/folded scalar (P1-3): Phase 1 requires one-line scalar frontmatter
  if printf '%s\n' "$_fm" | grep -qE '^[[:space:]]*description:[[:space:]]*[>|]'; then
    err "ERROR: description must be one-line scalar, block/folded style not allowed (found '>' or '|')"
    return 2
  fi
  if printf '%s\n' "$_fm" | grep -qE '^[[:space:]]*name:[[:space:]]*[>|]'; then
    err "ERROR: name must be one-line scalar, block/folded style not allowed"
    return 2
  fi
  # Also reject values that are exactly > / | / >- etc even if not caught by line prefix due to quotes stripping
  if printf '%s' "$_fm_desc" | grep -qE '^[>|]([-+][0-9]*)?$'; then
    err "ERROR: description must be one-line scalar, block/folded style not allowed"
    return 2
  fi
  if printf '%s' "$_fm_name" | grep -qE '^[>|]'; then
    err "ERROR: name must be one-line scalar, block/folded style not allowed"
    return 2
  fi
  # Placeholder markers in SKILL.md
  if grep -qF "{{" "$_skill" 2>/dev/null; then
    # Need to check for {{...}} pattern (contains closing }})
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

  # Normalized name check first (rejects slash, absolute, traversal)
  if ! is_normalized_name "$_name"; then
    err "ERROR: invalid skill-name '$_name' (must match ^[a-z0-9]+(-[a-z0-9]+)*\$)"
    return 2
  fi
  # Reject absolute name (already covered but explicit)
  case "$_name" in
    /*) err "ERROR: absolute skill-name not allowed"; return 2 ;;
    *".."* ) err "ERROR: traversal in skill-name"; return 2 ;;
    */* ) err "ERROR: slash in skill-name"; return 2 ;;
  esac

  _root="$(resolve_root "$_root_in")" || return 2

  # Containment: derived paths must be inside root (ensure name didn't escape via symlink? name already normalized so safe)
  CANONICAL="$_root/.agents/skills/$_name"
  PROJECTION="$_root/.claude/skills/$_name"
  PARENT_CLAUDE_SKILLS="$_root/.claude/skills"
  PARENT_AGENTS_SKILLS="$_root/.agents/skills"

  # Ensure derived paths still prefix with root (defense against weird root)
  case "$CANONICAL" in
    "$_root"/*) ;;
    *) err "ERROR: canonical path escapes project root"; return 2 ;;
  esac
  case "$PROJECTION" in
    "$_root"/*) ;;
    *) err "ERROR: projection path escapes project root"; return 2 ;;
  esac

  # Symlink path chain checks (before any creation)
  if ! check_path_chain_symlinks "$_root"; then
    return 2
  fi

  return 0
}

do_validate() {
  if [ $# -ne 2 ]; then err "ERROR: validate requires <project-root> <skill-name>"; usage >&2; return 1; fi
  derive_paths "$1" "$2" || return $?
  # validate_canonical expects canonical and name
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
  # First validate canonical
  validate_canonical "$CANONICAL" "$2" || return 2
  # Then check projection exists and is byte-identical
  if [ ! -d "$PROJECTION" ]; then
    err "ERROR: projection missing: $PROJECTION"
    return 3
  fi
  if [ -L "$PROJECTION" ]; then
    err "ERROR: projection is a symlink: $PROJECTION"
    return 2
  fi
  # Check projection not a symlink tree? find inside?
  if find "$PROJECTION" -type l 2>/dev/null | grep -q .; then
    err "ERROR: symlink inside projection tree"
    return 2
  fi
  if [ ! -f "$PROJECTION/SKILL.md" ]; then
    err "ERROR: projection missing SKILL.md"
    return 3
  fi
  # Compare byte-identical
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
  # Record which parent dirs we create so we can clean up only those on failure
  CREATED_CLAUDE_DIR=0
  CREATED_SKILLS_DIR=0
  NEED_CLEANUP_PARENTS=""

  # Validate first; fail without touching target
  if ! validate_canonical "$CANONICAL" "$_skill_name"; then
    return 2
  fi

  # Handle missing .claude and .claude/skills parents: create only after checks
  # Need to decide if they existed before
  _root="$CANONICAL"
  # Extract root again (already derived)
  _root_dir="$(resolve_root "$1")" || return 2
  _claude_dir="$_root_dir/.claude"
  _claude_skills_dir="$_root_dir/.claude/skills"

  _claude_existed=0
  _skills_existed=0
  [ -d "$_claude_dir" ] && _claude_existed=1
  [ -d "$_claude_skills_dir" ] && _skills_existed=1
  # Track whether projection existed before for rollback on post-publish failure (P1-2)
  _projection_existed_before=0
  [ -e "$PROJECTION" ] && _projection_existed_before=1

  # If parents missing, create after containment/symlink checks (already done)
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
      # cleanup claude if we created it and it's empty
      if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -d "$_claude_dir" ]; then
        rmdir "$_claude_dir" 2>/dev/null || true
      fi
      return 4
    fi
    CREATED_SKILLS_DIR=1
  fi

  # Re-check symlink chain after creation (new dirs shouldn't be symlinks)
  if [ -L "$_claude_dir" ] || [ -L "$_claude_skills_dir" ]; then
    err "ERROR: created path is a symlink (race)"
    # cleanup
    if [ "$CREATED_SKILLS_DIR" -eq 1 ]; then rmdir "$_claude_skills_dir" 2>/dev/null || true; fi
    if [ "$CREATED_CLAUDE_DIR" -eq 1 ]; then rmdir "$_claude_dir" 2>/dev/null || true; fi
    return 2
  fi

  # Target state handling
  if [ ! -e "$PROJECTION" ]; then
    # Absent → create via temp sibling
    # Create temp sibling dir inside parent
    _tmp="$(mktemp -d "$_claude_skills_dir/.tmp.${_skill_name}.XXXXXX" 2>/dev/null)" || {
      err "ERROR: cannot create temp sibling in $_claude_skills_dir"
      # cleanup parents if empty
      if [ "$CREATED_SKILLS_DIR" -eq 1 ]; then rmdir "$_claude_skills_dir" 2>/dev/null || true; fi
      if [ "$CREATED_CLAUDE_DIR" -eq 1 ]; then rmdir "$_claude_dir" 2>/dev/null || true; fi
      return 4
    }
    # Copy
    if ! cp -R "$CANONICAL/." "$_tmp/" 2>/dev/null; then
      err "ERROR: copy failed to temp sibling"
      rm -rf "$_tmp" 2>/dev/null || true
      # cleanup parents if empty
      if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null | grep -v "^\.tmp\.")" ]; then
        # only empty aside from our tmp which is removed, check empty
        if [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null)" ]; then
          rmdir "$_claude_skills_dir" 2>/dev/null || true
          if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_dir" 2>/dev/null)" ]; then
            rmdir "$_claude_dir" 2>/dev/null || true
          fi
        fi
      elif [ "$CREATED_SKILLS_DIR" -eq 1 ]; then
        # check if parent now empty aside from dotfiles
        true
      fi
      return 4
    fi
    # Verify copy
    _vout="$(diff -rq "$CANONICAL" "$_tmp" 2>&1)" || true
    if [ -n "$_vout" ]; then
      err "ERROR: verify failed after copy to temp"
      printf '%s\n' "$_vout" | sed 's/^/  /' >&2
      rm -rf "$_tmp" 2>/dev/null || true
      # cleanup empty parents we created
      if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null)" ]; then
        rmdir "$_claude_skills_dir" 2>/dev/null || true
        if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_dir" 2>/dev/null)" ]; then
          rmdir "$_claude_dir" 2>/dev/null || true
        fi
      fi
      return 4
    fi
    # Re-check containment and target absence at publication (P1-4 fail-closed)
    # Test hook for deterministic contention testing
    if [ -n "${CAPABILITY_SKILL_TEST_RACE:-}" ]; then
      eval "$CAPABILITY_SKILL_TEST_RACE" 2>/dev/null || true
    fi
    if ! check_path_chain_symlinks "$_root_dir"; then
      err "ERROR: path chain became symlinked before publish (race)"
      rm -rf "$_tmp" 2>/dev/null || true
      if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null)" ]; then
        rmdir "$_claude_skills_dir" 2>/dev/null || true
        if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_dir" 2>/dev/null)" ]; then
          rmdir "$_claude_dir" 2>/dev/null || true
        fi
      fi
      return 4
    fi
    if [ -e "$PROJECTION" ]; then
      err "ERROR: target appeared before publish (contention), refusing to overwrite"
      rm -rf "$_tmp" 2>/dev/null || true
      if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null)" ]; then
        rmdir "$_claude_skills_dir" 2>/dev/null || true
        if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_dir" 2>/dev/null)" ]; then
          rmdir "$_claude_dir" 2>/dev/null || true
        fi
      fi
      return 3
    fi
    # Rename into place (atomic)
    if ! mv "$_tmp" "$PROJECTION" 2>/dev/null; then
      err "ERROR: rename temp to projection failed"
      rm -rf "$_tmp" 2>/dev/null || true
      if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null)" ]; then
        rmdir "$_claude_skills_dir" 2>/dev/null || true
        if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_dir" 2>/dev/null)" ]; then
          rmdir "$_claude_dir" 2>/dev/null || true
        fi
      fi
      return 4
    fi
    # Test hook for deterministic final-verify failure (P1-2 regression test)
    if [ -n "${CAPABILITY_SKILL_TEST_AFTER_PUBLISH:-}" ]; then
      eval "$CAPABILITY_SKILL_TEST_AFTER_PUBLISH" 2>/dev/null || true
    fi
    # Final verify byte identity — rollback on failure to preserve pre-call absent state (P1-2)
    _fout="$(diff -rq "$CANONICAL" "$PROJECTION" 2>&1)" || true
    if [ -n "$_fout" ]; then
      err "ERROR: final verify after rename failed"
      printf '%s\n' "$_fout" | sed 's/^/  /' >&2
      # Rollback published projection if it did not exist before this invocation
      if [ "$_projection_existed_before" -eq 0 ]; then
        rm -rf "$PROJECTION" 2>/dev/null || true
        # Clean empty parents we created
        if [ "$CREATED_SKILLS_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_skills_dir" 2>/dev/null)" ]; then
          rmdir "$_claude_skills_dir" 2>/dev/null || true
          if [ "$CREATED_CLAUDE_DIR" -eq 1 ] && [ -z "$(ls -A "$_claude_dir" 2>/dev/null)" ]; then
            rmdir "$_claude_dir" 2>/dev/null || true
          fi
        fi
      fi
      return 4
    fi
    printf 'PROJECTED: %s -> %s\n' "$CANONICAL" "$PROJECTION"
    return 0
  else
    # Target exists → check divergent
    if [ -L "$PROJECTION" ]; then
      err "ERROR: projection is a symlink, refusing"
      # cleanup parents if we created them and projection is divergent? no, projection existed before, so parents existed. But if we created parents for a new repo, projection shouldn't have existed. So no cleanup need for symlink case beyond temp check already done. Just ensure no temp residue (none created)
      # On failure, if we created empty parent dirs and target already existed, parents weren't newly created (since target exists implies parent existed). So nothing to clean regarding parents we created path would not have happened because target exists implies parent existed. But for safety handle created parents that are now non-empty? Do not remove pre-existing. Only remove empty parents we created if we created them and failure occurred and no target existed before? For divergent case with pre-existing target, we shouldn't remove anything.
      # Since _claude_existed or _skills_existed would have been 1 if target existed, they wouldn't be 1. So no creation.
      return 2
    fi
    _dout="$(diff -rq "$CANONICAL" "$PROJECTION" 2>&1)" || true
    if [ -z "$_dout" ]; then
      printf 'PROJECT NO-OP: target already byte-identical\n'
      return 0
    else
      err "ERROR: divergent target exists, refusing to overwrite:"
      printf '%s\n' "$_dout" | sed 's/^/  /' >&2 | head -20
      # Per P1-1: do not touch any pre-existing .tmp paths; this invocation created no temp, so no cleanup.
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
