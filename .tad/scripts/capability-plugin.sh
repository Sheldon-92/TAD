#!/usr/bin/env bash
# capability-plugin.sh — one-Skill/one-Plugin validate / package / verify
# BSD/macOS-safe. No grep -P. Advisory-friendly exit classes (mirror capability-skill.sh).
# Concurrency boundary: cooperative local invocations serialized via atomic
# per-plugin directory lock (mkdir). Hostile filesystem mutation out of scope.
set -uo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<'USAGE'
capability-plugin.sh — one-Skill/one-Plugin validate / package / verify

Usage:
  capability-plugin.sh validate <project-root> <skill-name> <plugin-dir>
  capability-plugin.sh package  <project-root> <skill-name> <plugin-dir>
  capability-plugin.sh verify   <project-root> <skill-name> <plugin-dir>
  capability-plugin.sh --help | -h

  <project-root>  path to the sandbox project root holding canonical Skill
                  (physical resolution; canonical = <root>/.agents/skills/<name>)
  <skill-name>    normalized skill name: ^[a-z0-9]+(-[a-z0-9]+)*$
  <plugin-dir>    caller-selected BUT constrained: must resolve INSIDE the TAD
                  repo root AND inside .tad/evidence/ sandbox for this handoff
                  (prefix proof via case on resolved paths; no nesting).

Paths derived/constrained, never free:
  canonical  = <root>/.agents/skills/<name>
  generated  = <plugin-dir>/skills/<name>/
  manifest   = <plugin-dir>/.codex-plugin/plugin.json (from template)

Exit codes (stable, mirror capability-skill.sh):
  0  success
  1  usage error (wrong args, unknown command)
  2  invalid canonical / path (validation failed, traversal, symlink, frontmatter, forbidden artifact, containment, basename, nesting, template)
  3  divergent target (generated exists and differs; no overwrite) or lock contention
  4  I/O failure (copy failure, parent unavailable, temp cleanup)

Behavior:
  validate — fails non-zero unless canonical valid AND plugin-dir contained AND
             (absent OR already valid); never modifies.
  package  — validates first; absent target → temp sibling copy+verify+rename;
             identical target → no-op; divergent → exit 3 without mutation;
             failed package leaves canonical+projection digest-identical.
  verify   — validates canonical, then byte-compares canonical vs generated +
             manifest {name,version,skills:[name]} + exactly-one-subtree; never modifies.

Notes:
  - Rejects non-normalized names, traversal, absolute names, path escape, symlink
    path chains, symlinks anywhere in canonical/template/generated trees,
    mismatched frontmatter/directory name, dash-leading plugin basename.
  - Placeholder scan: SKILL.md must not contain {{...}}, [TODO], [TBD].
  - Forbidden root artifacts: CAPABILITY.md, README.md, CHANGELOG.md, install.sh.
  - Forbidden install roots (explicit): $HOME/.codex, $HOME/.config, marketplaces —
    constrained by construction to in-repo sandbox; probed by test ! -e.
  - Template: .tad/templates/openai-plugin/ (.codex-plugin/plugin.json).
  - BSD/macOS-safe; no grep -P. Digest pinned shasum -a 256 → sha256sum fallback.
  - Concurrency: cooperative packaging serialized via per-plugin lock.

USAGE
}

# --- helpers ---

err() { printf '%s\n' "$*" >&2; }

# Validate skill-name normalized
is_normalized_name() {
  case "$1" in
    "" ) return 1 ;;
  esac
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

# Resolve repo root from script location (two levels up from .tad/scripts).
resolve_repo_root() {
  _here="$(cd "$(dirname "$0")" 2>/dev/null && pwd -P 2>/dev/null)" || return 1
  _repo="$(cd "$_here/../.." 2>/dev/null && pwd -P 2>/dev/null)" || return 1
  if [ -z "$_repo" ]; then return 1; fi
  printf '%s' "$_repo"
  return 0
}

# Get device:inode for ownership proof (BSD macOS stat -f, fallback Linux stat -c)
get_inode() {
  _p="$1"
  if [ ! -e "$_p" ]; then
    printf ''
    return 1
  fi
  if stat -f '%d:%i' "$_p" 2>/dev/null | grep -qE '^[0-9]+:[0-9]+$'; then
    stat -f '%d:%i' "$_p" 2>/dev/null
    return 0
  fi
  if stat -c '%d:%i' "$_p" 2>/dev/null | grep -qE '^[0-9]+:[0-9]+$'; then
    stat -c '%d:%i' "$_p" 2>/dev/null
    return 0
  fi
  ls -di "$_p" 2>/dev/null | awk '{print $1}' || printf ''
  return 0
}

# Check symlink in path chain for .agents/skills parents (canonical side).
check_canonical_chain() {
  _root="$1"
  for _rel in ".agents" ".agents/skills"; do
    _p="$_root/$_rel"
    if [ -e "$_p" ] && [ -L "$_p" ]; then
      err "ERROR: symlink in canonical path chain: $_p (refuse to write through link)"
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
        err "ERROR: symlink in canonical chain component: $_cur"
        return 1
      fi
      if [ "$_rest" = "" ]; then break; fi
    done
  done
  return 0
}

# Check symlinks anywhere inside a tree.
has_symlink_in_tree() {
  _dir="$1"
  if [ ! -d "$_dir" ]; then return 1; fi
  if find "$_dir" -type l 2>/dev/null | grep -q .; then
    return 0
  else
    return 1
  fi
}

# Check no symlink in resolved plugin-dir parent chain (walk to repo root).
# Args: <resolved_plugin> <resolved_repo>
check_plugin_chain() {
  _plug="$1"; _repo="$2"
  _cur="$_plug"
  while [ "$_cur" != "/" ] && [ -n "$_cur" ]; do
    if [ -e "$_cur" ] && [ -L "$_cur" ]; then
      err "ERROR: symlink in plugin path chain: $_cur"
      return 1
    fi
    # Stop when we reach repo root (prefix proof guarantees inside).
    if [ "$_cur" = "$_repo" ]; then break; fi
    # Also stop if outside repo (should not happen; containment rejects first).
    case "$_cur/" in "$_repo"/*) ;; *) break ;; esac
    _cur="$(dirname "$_cur")"
  done
  return 0
}

# Validate canonical SKILL.md (same contract as capability-skill.sh).
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

# Resolve + contain plugin-dir.
# Sets: RESOLVED_PLUGIN, RESOLVED_REPO, PLUGIN_PARENT, PLUGIN_BASE.
# Containment (mandatory):
#   physical resolve; inside repo root AND inside .tad/evidence sandbox;
#   slash-terminated case prefix proof (equality via empty-*, root.evil fails);
#   symlink-chain rejection; traversal/absolute/slash on skill; basename normalized;
#   no-nesting inside another plugin; forbidden roots explicit.
derive_plugin_paths() {
  _root_in="$1"
  _name="$2"
  _plug_in="$3"

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
  _repo="$(resolve_repo_root)" || { err "ERROR: cannot resolve repo root"; return 2; }

  CANONICAL="$_root/.agents/skills/$_name"
  case "$CANONICAL" in
    "$_root"/*) ;;
    *) err "ERROR: canonical path escapes project root"; return 2 ;;
  esac
  if ! check_canonical_chain "$_root"; then
    return 2
  fi

  # Resolve plugin-dir physically (parent must exist or be creatable under repo).
  # If plugin-dir exists (file/dir/link): resolve via cd+pwd -P on it (if dir) or
  # its parent + basename. If absent: resolve parent, append basename.
  _plug_resolved=""
  if [ -e "$_plug_in" ] || [ -L "$_plug_in" ]; then
    if [ -d "$_plug_in" ] && [ ! -L "$_plug_in" ]; then
      _plug_resolved="$(cd "$_plug_in" 2>/dev/null && pwd -P 2>/dev/null)" || { err "ERROR: cannot resolve plugin-dir: $_plug_in"; return 2; }
    else
      # File, symlink, or other: resolve parent + basename (no traversal via basename).
      _pparent="$(dirname "$_plug_in")"
      _pbase="$(basename "$_plug_in")"
      if [ ! -d "$_pparent" ]; then
        err "ERROR: plugin parent not a directory: $_pparent"
        return 2
      fi
      _pres="$(cd "$_pparent" 2>/dev/null && pwd -P 2>/dev/null)" || { err "ERROR: cannot resolve plugin parent"; return 2; }
      _plug_resolved="$_pres/$_pbase"
    fi
  else
    _pparent="$(dirname "$_plug_in")"
    _pbase="$(basename "$_plug_in")"
    if [ -z "$_pbase" ]; then err "ERROR: empty plugin basename"; return 2; fi
    if [ ! -d "$_pparent" ]; then
      # Parent may be creatable only if its own parent exists inside repo; refuse deep create.
      err "ERROR: plugin parent not a directory (refuse deep create): $_pparent"
      return 2
    fi
    _pres="$(cd "$_pparent" 2>/dev/null && pwd -P 2>/dev/null)" || { err "ERROR: cannot resolve plugin parent"; return 2; }
    _plug_resolved="$_pres/$_pbase"
  fi
  if [ -z "$_plug_resolved" ]; then err "ERROR: empty resolved plugin-dir"; return 2; fi

  # Basename normalized (rejects dash-leading "-plugin", traversal, etc.).
  _plug_base="$(basename "$_plug_resolved")"
  if ! is_normalized_name "$_plug_base"; then
    err "ERROR: plugin-dir basename not normalized '$_plug_base' (must match ^[a-z0-9]+(-[a-z0-9]+)*\$)"
    return 2
  fi
  case "$_plug_base" in
    /*) err "ERROR: absolute plugin basename"; return 2 ;;
    *".."* ) err "ERROR: traversal in plugin basename"; return 2 ;;
    */* ) err "ERROR: slash in plugin basename"; return 2 ;;
  esac

  # Containment: inside repo root (slash-terminated case prefix proof).
  # Exact proof: case "$resolved_child/" in "$resolved_root"/*) ;; *) reject ;; esac
  # Slash on BOTH sides (child trailing /, pattern root + / + *); equality via
  # empty-* (child==root -> child/ == root/ matches root/*); root.evil sibling
  # fails by construction (root.evil/ does not start with root/).
  resolved_child="$_plug_resolved"
  resolved_root="$_repo"
  case "$resolved_child/" in "$resolved_root"/*) ;; *) err "ERROR: plugin-dir escapes repo root"; return 2 ;; esac

  # Containment: inside .tad/evidence sandbox for this handoff.
  resolved_child="$_plug_resolved"
  resolved_root="$_repo/.tad/evidence"
  case "$resolved_child/" in "$resolved_root"/*) ;; *) err "ERROR: plugin-dir outside .tad/evidence sandbox (constrained by construction)"; return 2 ;; esac

  # Forbidden roots explicit (defense in depth; already excluded by above).
  if [ -n "${HOME:-}" ]; then
    resolved_child="$_plug_resolved"
    resolved_root="$HOME/.codex"
    case "$resolved_child/" in "$resolved_root"/*) err "ERROR: plugin-dir inside forbidden \$HOME/.codex"; return 2 ;; *) ;; esac
    resolved_root="$HOME/.config"
    case "$resolved_child/" in "$resolved_root"/*) err "ERROR: plugin-dir inside forbidden \$HOME/.config"; return 2 ;; *) ;; esac
  fi

  # Symlink-chain rejection for plugin path (parents + self if exists).
  if ! check_plugin_chain "$_plug_resolved" "$_repo"; then
    return 2
  fi
  if [ -e "$_plug_resolved" ] && [ -L "$_plug_resolved" ]; then
    err "ERROR: plugin-dir is a symlink: $_plug_resolved"
    return 2
  fi
  if [ -d "$_plug_resolved" ] && has_symlink_in_tree "$_plug_resolved"; then
    err "ERROR: symlink inside existing plugin tree"
    return 2
  fi

  # No-nesting: plugin-dir must not be inside another plugin (ancestor with
  # .codex-plugin/plugin.json), and must not contain nested plugin markers beyond
  # its own single manifest (checked at verify). Prevents sandbox-template/-plugin
  # confusion and nested installs.
  _anc="$(dirname "$_plug_resolved")"
  while [ -n "$_anc" ] && [ "$_anc" != "/" ]; do
    case "$_anc/" in "$_repo"/*) ;; *) break ;; esac
    if [ "$_anc" = "$_repo" ]; then break; fi
    if [ -e "$_anc/.codex-plugin/plugin.json" ]; then
      err "ERROR: plugin-dir nested inside another plugin: $_anc (refuse nesting)"
      return 2
    fi
    # Stop at evidence root's parent? Continue to repo root for full chain.
    if [ "$_anc" = "$_repo/.tad/evidence" ] || [ "$_anc" = "$_repo/.tad" ]; then
      # Still continue to repo (no plugin markers expected above evidence, but check).
      :
    fi
    _next="$(dirname "$_anc")"
    if [ "$_next" = "$_anc" ]; then break; fi
    _anc="$_next"
  done

  RESOLVED_PLUGIN="$_plug_resolved"
  RESOLVED_REPO="$_repo"
  RESOLVED_ROOT="$_root"
  PLUGIN_PARENT="$(dirname "$_plug_resolved")"
  PLUGIN_BASE="$_plug_base"
  return 0
}

# Validate template tree (framework source, read-only).
validate_template() {
  _repo="$1"
  _tpl="$_repo/.tad/templates/openai-plugin"
  if [ ! -d "$_tpl" ]; then
    err "ERROR: template missing: $_tpl"
    return 2
  fi
  if [ -L "$_tpl" ]; then
    err "ERROR: template is a symlink"
    return 2
  fi
  if has_symlink_in_tree "$_tpl"; then
    err "ERROR: symlink inside template tree"
    return 2
  fi
  if [ ! -f "$_tpl/.codex-plugin/plugin.json" ]; then
    err "ERROR: template manifest missing: $_tpl/.codex-plugin/plugin.json"
    return 2
  fi
  if [ -L "$_tpl/.codex-plugin/plugin.json" ]; then
    err "ERROR: template manifest is a symlink"
    return 2
  fi
  # Template manifest must be non-empty valid JSON (python3, baseline).
  if [ ! -s "$_tpl/.codex-plugin/plugin.json" ]; then
    err "ERROR: template manifest empty"
    return 2
  fi
  if ! python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$_tpl/.codex-plugin/plugin.json" 2>/dev/null; then
    err "ERROR: template manifest invalid JSON"
    return 2
  fi
  return 0
}

# Validate plugin manifest for a skill (python3 JSON assert).
validate_manifest() {
  _plug="$1"; _name="$2"
  _mf="$_plug/.codex-plugin/plugin.json"
  if [ ! -f "$_mf" ]; then
    err "ERROR: manifest missing: $_mf"
    return 2
  fi
  if [ -L "$_mf" ]; then
    err "ERROR: manifest is a symlink"
    return 2
  fi
  if [ ! -s "$_mf" ]; then
    err "ERROR: manifest empty (corrupt)"
    return 2
  fi
  if ! python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d.get("skills")==[sys.argv[2]], d' "$_mf" "$_name" 2>/dev/null; then
    err "ERROR: manifest skills != [$_name] (project-owned; check $_mf)"
    return 2
  fi
  if ! python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d.get("name")==sys.argv[2], d' "$_mf" "$_name" 2>/dev/null; then
    err "ERROR: manifest name != $_name"
    return 2
  fi
  return 0
}

do_validate() {
  if [ $# -ne 3 ]; then err "ERROR: validate requires <project-root> <skill-name> <plugin-dir>"; usage >&2; return 1; fi
  derive_plugin_paths "$1" "$2" "$3" || return $?
  validate_canonical "$CANONICAL" "$2" || return 2
  validate_template "$RESOLVED_REPO" || return 2
  # If plugin exists, it must already be valid (manifest + one subtree + identical).
  if [ -e "$RESOLVED_PLUGIN" ]; then
    if [ ! -d "$RESOLVED_PLUGIN" ]; then
      err "ERROR: plugin path exists but not a directory"
      return 2
    fi
    validate_manifest "$RESOLVED_PLUGIN" "$2" || return 2
    _gen="$RESOLVED_PLUGIN/skills/$2"
    if [ ! -d "$_gen" ]; then
      err "ERROR: generated skill missing: $_gen"
      return 2
    fi
    _cnt="$(find "$RESOLVED_PLUGIN/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | LC_ALL=C sort | wc -l | tr -d '[:space:]')"
    if [ "$_cnt" != "1" ]; then
      err "ERROR: plugin skills must contain exactly one subtree (found $_cnt)"
      return 2
    fi
  fi
  printf 'VALID: %s -> %s\n' "$CANONICAL" "$RESOLVED_PLUGIN"
  return 0
}

do_verify() {
  if [ $# -ne 3 ]; then err "ERROR: verify requires <project-root> <skill-name> <plugin-dir>"; usage >&2; return 1; fi
  derive_plugin_paths "$1" "$2" "$3" || return $?
  validate_canonical "$CANONICAL" "$2" || return 2
  if [ ! -d "$RESOLVED_PLUGIN" ]; then
    err "ERROR: plugin missing: $RESOLVED_PLUGIN"
    return 3
  fi
  if [ -L "$RESOLVED_PLUGIN" ]; then
    err "ERROR: plugin is a symlink"
    return 2
  fi
  if has_symlink_in_tree "$RESOLVED_PLUGIN"; then
    err "ERROR: symlink inside plugin tree"
    return 2
  fi
  validate_manifest "$RESOLVED_PLUGIN" "$2" || return 2
  _gen="$RESOLVED_PLUGIN/skills/$2"
  if [ ! -d "$_gen" ]; then
    err "ERROR: generated skill missing: $_gen"
    return 3
  fi
  _cnt="$(find "$RESOLVED_PLUGIN/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | LC_ALL=C sort | wc -l | tr -d '[:space:]')"
  if [ "$_cnt" != "1" ]; then
    err "ERROR: plugin skills must contain exactly one subtree (found $_cnt)"
    return 2
  fi
  _out="$(diff -rq "$CANONICAL" "$_gen" 2>&1)" || true
  if [ -z "$_out" ]; then
    printf 'VERIFY PASS: %s <-> %s byte-identical\n' "$CANONICAL" "$_gen"
    return 0
  else
    err "ERROR: generated differs from canonical:"
    printf '%s\n' "$_out" | sed 's/^/  /' >&2 | head -20
    return 3
  fi
}

do_package() {
  if [ $# -ne 3 ]; then err "ERROR: package requires <project-root> <skill-name> <plugin-dir>"; usage >&2; return 1; fi
  derive_plugin_paths "$1" "$2" "$3" || return $?
  _skill_name="$2"

  _tmp=""
  LOCK_DIR=""
  LOCK_ID=""
  _published_by_this_invocation=0
  _published_inode=""

  # Named temp+lock cleanup (separate from user-tree rollback below; no shared rm line).
  cleanup_plugin_tmp() {
    if [ -n "${_tmp:-}" ] && [ -d "$_tmp" ]; then
      case "$_tmp" in
        "$PLUGIN_PARENT/.tmp."*)
          rm -rf "$_tmp" 2>/dev/null || true
          ;;
      esac
      _tmp=""
    fi
    if [ -n "${LOCK_DIR:-}" ] && [ -n "${LOCK_ID:-}" ] && [ -d "$LOCK_DIR" ]; then
      cur_id="$(get_inode "$LOCK_DIR" 2>/dev/null || echo "")"
      if [ "$cur_id" = "$LOCK_ID" ] && [ -n "$cur_id" ]; then
        rmdir "$LOCK_DIR" 2>/dev/null || true
      fi
    fi
  }

  if ! validate_canonical "$CANONICAL" "$_skill_name"; then
    return 2
  fi
  validate_template "$RESOLVED_REPO" || return 2

  # Parent must exist (refuse deep create; P3/P4 parents pre-exist via evidence setup).
  if [ ! -d "$PLUGIN_PARENT" ]; then
    err "ERROR: plugin parent not a directory: $PLUGIN_PARENT"
    return 4
  fi
  if [ -L "$PLUGIN_PARENT" ]; then
    err "ERROR: plugin parent is a symlink"
    return 2
  fi

  # Acquire per-plugin lock (cooperative).
  LOCK_DIR="$PLUGIN_PARENT/.lock.${PLUGIN_BASE}"
  if ! check_plugin_chain "$RESOLVED_PLUGIN" "$RESOLVED_REPO"; then
    return 2
  fi
  if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    err "ERROR: lock exists for $PLUGIN_BASE (contention), refusing to proceed"
    return 3
  fi
  LOCK_ID="$(get_inode "$LOCK_DIR" 2>/dev/null || echo "")"
  trap 'cleanup_plugin_tmp' EXIT
  trap 'cleanup_plugin_tmp; exit 4' INT TERM HUP

  if ! check_plugin_chain "$RESOLVED_PLUGIN" "$RESOLVED_REPO"; then
    err "ERROR: plugin chain became symlinked after lock"
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 2
  fi

  # Target exists → identical no-op or divergent refuse (under lock).
  if [ -e "$RESOLVED_PLUGIN" ]; then
    if [ ! -d "$RESOLVED_PLUGIN" ] || [ -L "$RESOLVED_PLUGIN" ]; then
      err "ERROR: plugin path exists but not a clean directory"
      cleanup_plugin_tmp
      trap - EXIT INT TERM HUP
      return 2
    fi
    if has_symlink_in_tree "$RESOLVED_PLUGIN"; then
      err "ERROR: symlink inside existing plugin tree"
      cleanup_plugin_tmp
      trap - EXIT INT TERM HUP
      return 2
    fi
    # Existing must validate (manifest may be corrupt → P4 atomicity refuses).
    if ! validate_manifest "$RESOLVED_PLUGIN" "$_skill_name"; then
      cleanup_plugin_tmp
      trap - EXIT INT TERM HUP
      return 2
    fi
    _gen_existing="$RESOLVED_PLUGIN/skills/$_skill_name"
    if [ ! -d "$_gen_existing" ]; then
      err "ERROR: existing plugin missing generated skill"
      cleanup_plugin_tmp
      trap - EXIT INT TERM HUP
      return 2
    fi
    _dout="$(diff -rq "$CANONICAL" "$_gen_existing" 2>&1)" || true
    if [ -z "$_dout" ]; then
      cleanup_plugin_tmp
      trap - EXIT INT TERM HUP
      printf 'PACKAGE NO-OP: target already byte-identical\n'
      return 0
    else
      err "ERROR: divergent plugin exists, refusing to overwrite:"
      printf '%s\n' "$_dout" | sed 's/^/  /' >&2 | head -20
      cleanup_plugin_tmp
      trap - EXIT INT TERM HUP
      return 3
    fi
  fi

  # Absent target → sibling temp build + verify + rename.
  _tmp="$(mktemp -d "$PLUGIN_PARENT/.tmp.${PLUGIN_BASE}.XXXXXX" 2>/dev/null)" || {
    err "ERROR: cannot create temp sibling in $PLUGIN_PARENT"
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 4
  }
  # Empty-var + parent-prefix guards live inside cleanup_plugin_tmp; temp is sibling.
  if ! mkdir -p "$_tmp/skills" "$_tmp/.codex-plugin" 2>/dev/null; then
    err "ERROR: cannot scaffold temp plugin layout"
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 4
  fi
  if ! cp -R "$CANONICAL/." "$_tmp/skills/$_skill_name/" 2>/dev/null; then
    # cp -R to non-existent dest creates it on BSD; ensure parent then retry once.
    mkdir -p "$_tmp/skills/$_skill_name" 2>/dev/null || true
    if ! cp -R "$CANONICAL/." "$_tmp/skills/$_skill_name/" 2>/dev/null; then
      err "ERROR: copy failed to temp sibling"
      cleanup_plugin_tmp
      trap - EXIT INT TERM HUP
      return 4
    fi
  fi
  # Manifest from template values (name/version/skills) but pinned to this skill.
  # Read template version (fallback 0.1.0), write minimal manifest.
  _tpl_ver="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("version","0.1.0"))' "$RESOLVED_REPO/.tad/templates/openai-plugin/.codex-plugin/plugin.json" 2>/dev/null || printf '0.1.0')"
  if ! python3 -c 'import json,sys; json.dump({"name":sys.argv[1],"version":sys.argv[2],"skills":[sys.argv[1]]}, open(sys.argv[3],"w"), indent=2)' "$_skill_name" "$_tpl_ver" "$_tmp/.codex-plugin/plugin.json" 2>/dev/null; then
    err "ERROR: cannot write temp manifest"
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 4
  fi
  # Verify temp before publish.
  if ! python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d.get("skills")==[sys.argv[2]], d' "$_tmp/.codex-plugin/plugin.json" "$_skill_name" 2>/dev/null; then
    err "ERROR: temp manifest invalid after write"
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 4
  fi
  _vout="$(diff -rq "$CANONICAL" "$_tmp/skills/$_skill_name" 2>&1)" || true
  if [ -n "$_vout" ]; then
    err "ERROR: verify failed after copy to temp"
    printf '%s\n' "$_vout" | sed 's/^/  /' >&2
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 4
  fi
  if [ -e "$RESOLVED_PLUGIN" ]; then
    err "ERROR: target appeared before publish (contention), refusing to overwrite"
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 3
  fi
  if ! check_plugin_chain "$RESOLVED_PLUGIN" "$RESOLVED_REPO"; then
    err "ERROR: plugin chain became symlinked before publish"
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 2
  fi
  if ! mv "$_tmp" "$RESOLVED_PLUGIN" 2>/dev/null; then
    err "ERROR: rename temp to plugin failed"
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 4
  fi
  _published_by_this_invocation=1
  _published_inode="$(get_inode "$RESOLVED_PLUGIN" 2>/dev/null || echo "")"
  _tmp=""
  _fout="$(diff -rq "$CANONICAL" "$RESOLVED_PLUGIN/skills/$_skill_name" 2>&1)" || true
  if [ -n "$_fout" ]; then
    err "ERROR: final verify after rename failed"
    printf '%s\n' "$_fout" | sed 's/^/  /' >&2
    if [ "$_published_by_this_invocation" -eq 1 ] && [ -n "$LOCK_ID" ] && [ -d "$LOCK_DIR" ]; then
      cur_lock_id="$(get_inode "$LOCK_DIR" 2>/dev/null || echo "")"
      cur_plug_id="$(get_inode "$RESOLVED_PLUGIN" 2>/dev/null || echo "")"
      if [ "$cur_lock_id" = "$LOCK_ID" ] && [ "$cur_plug_id" = "$_published_inode" ] && [ -n "$cur_lock_id" ] && [ -n "$cur_plug_id" ]; then
        [ -n "$RESOLVED_PLUGIN" ] || return 4
        case "$RESOLVED_PLUGIN/" in "$RESOLVED_REPO"/*) ;; *) err "refuse rollback outside repo"; return 4;; esac
        rm -rf "$RESOLVED_PLUGIN" 2>/dev/null || true
      else
        err "ERROR: ownership cannot be proven for rollback, refusing to delete"
        cleanup_plugin_tmp
        trap - EXIT INT TERM HUP
        return 4
      fi
    fi
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 4
  fi
  if ! validate_manifest "$RESOLVED_PLUGIN" "$_skill_name"; then
    # Rollback own publish on manifest failure (ownership proven).
    if [ "$_published_by_this_invocation" -eq 1 ] && [ -n "$LOCK_ID" ] && [ -d "$LOCK_DIR" ]; then
      cur_lock_id="$(get_inode "$LOCK_DIR" 2>/dev/null || echo "")"
      cur_plug_id="$(get_inode "$RESOLVED_PLUGIN" 2>/dev/null || echo "")"
      if [ "$cur_lock_id" = "$LOCK_ID" ] && [ "$cur_plug_id" = "$_published_inode" ] && [ -n "$cur_lock_id" ] && [ -n "$cur_plug_id" ]; then
        [ -n "$RESOLVED_PLUGIN" ] || return 4
        case "$RESOLVED_PLUGIN/" in "$RESOLVED_REPO"/*) ;; *) err "refuse rollback outside repo"; return 4;; esac
        rm -rf "$RESOLVED_PLUGIN" 2>/dev/null || true
      fi
    fi
    cleanup_plugin_tmp
    trap - EXIT INT TERM HUP
    return 2
  fi
  cleanup_plugin_tmp
  trap - EXIT INT TERM HUP
  printf 'PACKAGED: %s -> %s\n' "$CANONICAL" "$RESOLVED_PLUGIN"
  return 0
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
    package)
      shift
      do_package "$@"
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
