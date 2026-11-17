#!/bin/bash
# component-health-check.sh — SessionStart component integrity check.
# Upstreamed 2026-11-06 from the Sober Creator repo into this framework
# source repo (TASK-20261106-004, HANDOFF-20261106-sp2-row4-self-test-agent
# §4.2 C2); built downstream 2026-10-31, this repo is now the source copy.
#
# TASK-20261031-002. Detect-only: this script never writes, edits, or heals
# anything (detect/heal decoupled, same precedent as state-surface-check.sh).
# It verifies framework component integrity at Alex/Blake startup: hook
# scripts exist and are syntactically sound, config version agrees at three
# points, config modules are complete, templates are present and unaltered.
# The primary existence/content oracle is the project-owned baseline
# (.tad/project-knowledge/component-health-baseline.txt, path + sha256);
# live derivation (wiring references, config module index, consumer template
# references) is the second source. Missing/unreadable derivation sources or
# baseline produce UNVERIFIABLE lines (counted as problems) — never a silent
# smaller set, never a fake OK.
#
# Self-contained: sources NO repo file, reads no stdin, writes no file, so it
# still runs when the lib files it checks are damaged.
#
# Usage: component-health-check.sh [--root <dir>] [--line]
#   --root defaults to the repo root derived from this script's location
#   (.tad/hooks/lib/ -> ../../..).
# Exit: 0 = all green; 1 = problems found (incl. UNVERIFIABLE);
#       2 = usage error or internal error (reason on stderr).
#
# CONTRACT (consumed output = API; hook-contracts pattern — changing this
# grammar is a BREAKING change, semver-major):
#   Full form:
#     TAD component health — root: <abs path>
#     <one line per problem, prefix in the closed set:
#       MISSING <relpath> | EMPTY <relpath> |
#       SYNTAX <relpath>: <first bash -n error line> |
#       MODIFIED <relpath> | UNLISTED <relpath> |
#       VERSION MISMATCH config.yaml=<a> version.txt=<b> TAD-VERSION=<c> |
#       UNPARSEABLE <relpath> |
#       UNVERIFIABLE <face>: <reason>   (counted as a problem) |
#       SKIPPED <face>: <reason>       (not counted)>
#     COMPONENTS: OK (scripts=<n> templates=<m> version=<v> wired=<a> refs=<b>)
#     or: COMPONENTS: PROBLEMS <k>
#   --line form (exactly one line, consumed by startup-health.sh):
#     Components: OK (v<version.txt value>)
#     or: Components: <k> PROBLEMS: <name1>, <name2>, <name3>[, +<n> more] — run .tad/hooks/lib/component-health-check.sh for detail
#     (at most 3 names, deduped by file path: several problem lines for
#      one file take one name slot, while k counts problem lines; basename
#      by default, parent-dir/basename when two selected names share a
#      basename; VERSION problems are named "version-mismatch", baseline
#      UNVERIFIABLE is "baseline-unverifiable" — face-level names are
#      items of their own and never merge with a file name)
#
# Hash toolchain (D12): sha256sum if present, else shasum -a 256 (same
# portable chain as quarantine-framework-pk.sh); outputs are isomorphic.
# The whole baseline is hashed in ONE batched invocation.
# TAD_COMPONENT_CHECK_HASH=off forces the no-tool degradation leg (tests).
# TAD_COMPONENT_CHECK_YAML=off forces the config-parse leg to SKIPPED (tests).

set -u
exec </dev/null

# ---------- argument parsing ----------
ROOT=""
LINE_MODE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --root)
      if [ $# -lt 2 ]; then
        echo "component-health-check: --root requires a value" >&2
        exit 2
      fi
      ROOT="$2"
      shift 2
      ;;
    --line)
      LINE_MODE=1
      shift
      ;;
    *)
      echo "component-health-check: unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$ROOT" ]; then
  _SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  ROOT="$(cd "$_SCRIPT_DIR/../../.." && pwd)"
else
  if [ ! -d "$ROOT" ]; then
    echo "component-health-check: root does not exist: $ROOT" >&2
    exit 2
  fi
  ROOT="$(cd "$ROOT" && pwd)"
fi

if [ ! -d "$ROOT/.tad" ]; then
  echo "component-health-check: no .tad directory under root: $ROOT" >&2
  exit 2
fi

# ---------- hash toolchain (probe once) ----------
HASH_KIND="none"
if [ "${TAD_COMPONENT_CHECK_HASH:-}" = "off" ]; then
  HASH_KIND="off"
elif command -v sha256sum >/dev/null 2>&1; then
  HASH_KIND="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
  HASH_KIND="shasum"
fi

# ---------- helpers ----------
# _set_diff A B -> lines present in A but not in B (A/B: newline-joined,
# already sorted; membership via one awk pass, order of A preserved).
_set_diff() {
  awk 'NR==FNR { seen[$0]=1; next } !($0 in seen)' \
    <(printf '%s' "$2") <(printf '%s' "$1")
}

# ---------- problem collection ----------
# Per-face buckets (newline-joined). Face order C1..C6 is output order.
P1=""; P2=""; P3=""; P4=""; P5=""; P6=""
SKIP_LINES=""

# ---------- baseline load (component C) ----------
BASELINE_REL=".tad/project-knowledge/component-health-baseline.txt"
BASELINE_ABS="$ROOT/$BASELINE_REL"
BASELINE_STATE="ok"          # ok | absent | not-regular | empty
BASELINE_PATHS=""            # sorted relpaths of valid entries
B_HOOKS=""; B_TEMPLATES=""; B_CONFIGMODS=""
MOD2=""; MOD3=""; MOD4=""; MOD5=""   # MODIFIED lines per face from baseline pass

if [ ! -e "$BASELINE_ABS" ] && [ ! -L "$BASELINE_ABS" ]; then
  BASELINE_STATE="absent"
elif [ ! -f "$BASELINE_ABS" ]; then
  BASELINE_STATE="not-regular"
else
  _valid="$(grep -E '^[0-9a-f]{64} [ *]' "$BASELINE_ABS" 2>/dev/null || true)"
  if [ -z "$_valid" ]; then
    BASELINE_STATE="empty"
  else
    _paths_raw=""
    _hash_args=()
    while IFS= read -r _line; do
      [ -n "$_line" ] || continue
      _rel="${_line:66}"
      _paths_raw="${_paths_raw}$_rel
"
      if [ -f "$ROOT/$_rel" ]; then
        _hash_args[${#_hash_args[@]}]="$ROOT/$_rel"
      fi
    done <<EOF_BASELINE
$_valid
EOF_BASELINE
    BASELINE_PATHS="$(printf '%s' "$_paths_raw" | LC_ALL=C sort)"
    B_HOOKS="$(printf '%s\n' "$BASELINE_PATHS" | grep -E '^\.tad/hooks/.*\.sh$' || true)"
    B_TEMPLATES="$(printf '%s\n' "$BASELINE_PATHS" | grep -E '^\.tad/templates/' || true)"
    B_CONFIGMODS="$(printf '%s\n' "$BASELINE_PATHS" | grep -E '^\.tad/config-[A-Za-z0-9_-]+\.yaml$' || true)"
    if [ "$HASH_KIND" != "none" ] && [ "$HASH_KIND" != "off" ] && [ ${#_hash_args[@]} -gt 0 ]; then
      # One batched hash invocation for the whole baseline; the compare is
      # a single awk pass (paths sliced by column, never field-split).
      case "$HASH_KIND" in
        sha256sum) _computed="$(sha256sum "${_hash_args[@]}" | sed "s#  $ROOT/#  #")" ;;
        shasum) _computed="$(shasum -a 256 "${_hash_args[@]}" | sed "s#  $ROOT/#  #")" ;;
      esac
      _mods="$(awk '
        NR==FNR { h[substr($0,67)] = substr($0,1,64); next }
        { p = substr($0,67); e = substr($0,1,64)
          if ((p in h) && h[p] != e) {
            if (p ~ /^\.tad\/templates\//) f = "F5"
            else if (p == ".tad/config.yaml" || p ~ /^\.tad\/config-[A-Za-z0-9_-]+\.yaml$/) f = "F4"
            else if (p == ".tad/version.txt" || p == ".tad/TAD-VERSION") f = "F3"
            else f = "F2"
            print f " MODIFIED " p
          } }
      ' <(printf '%s' "$_computed") <(printf '%s' "$_valid"))"
      if [ -n "$_mods" ]; then
        while IFS= read -r _m; do
          # A present-but-zero-byte file is reported by its face's EMPTY (or
          # MISSING, for version points) line; the MODIFIED line for the same
          # path is subsumed and dropped (AC8: exactly one problem line for
          # an emptied template).
          _mpath="${_m#* MODIFIED }"
          if [ -f "$ROOT/$_mpath" ] && [ ! -s "$ROOT/$_mpath" ]; then
            continue
          fi
          case "$_m" in
            'F2 '*) MOD2="${MOD2}${_m#F2 }
" ;;
            'F3 '*) MOD3="${MOD3}${_m#F3 }
" ;;
            'F4 '*) MOD4="${MOD4}${_m#F4 }
" ;;
            'F5 '*) MOD5="${MOD5}${_m#F5 }
" ;;
          esac
        done <<EOF_MODS
$_mods
EOF_MODS
      fi
    fi
  fi
fi

# Baseline-level UNVERIFIABLE lines (attributed to the C2 bucket: the first
# face that consumes the baseline; global dedupe keeps exactly one copy).
if [ "$BASELINE_STATE" = "absent" ]; then
  P2="${P2}UNVERIFIABLE baseline: absent
"
elif [ "$BASELINE_STATE" = "not-regular" ]; then
  P2="${P2}UNVERIFIABLE baseline: not a regular file
"
elif [ "$BASELINE_STATE" = "empty" ]; then
  P2="${P2}UNVERIFIABLE baseline: no valid entries
"
elif [ "$HASH_KIND" = "none" ] || [ "$HASH_KIND" = "off" ]; then
  P2="${P2}UNVERIFIABLE baseline: no sha256 tool
"
fi
BASELINE_OK=0
[ "$BASELINE_STATE" = "ok" ] && BASELINE_OK=1

# ---------- C1: wiring reference integrity ----------
WIRED=""
_wiring_args=()
for _wf in .claude/settings.json .codex/hooks.json .cursor/hooks.json .opencode/plugins/tad-hooks.ts; do
  if [ -f "$ROOT/$_wf" ]; then
    _wiring_args[${#_wiring_args[@]}]="$ROOT/$_wf"
  else
    P1="${P1}UNVERIFIABLE wiring: $_wf absent
"
  fi
done
if [ -f "$ROOT/.claude/settings.local.json" ]; then
  _wiring_args[${#_wiring_args[@]}]="$ROOT/.claude/settings.local.json"
fi
if [ ${#_wiring_args[@]} -gt 0 ]; then
  # Single grep process over explicit regular files only (anti-hang rules).
  WIRED="$(grep -hoE '\.tad/hooks/[A-Za-z0-9_./-]+\.sh' "${_wiring_args[@]}" </dev/null 2>/dev/null | LC_ALL=C sort -u || true)"
fi
WIRED_N=0
if [ -n "$WIRED" ]; then
  WIRED_N="$(printf '%s\n' "$WIRED" | wc -l | tr -d ' ')"
  while IFS= read -r _p; do
    [ -n "$_p" ] || continue
    if [ ! -f "$ROOT/$_p" ]; then
      P1="${P1}MISSING $_p
"
    fi
  done <<EOF_WIRED
$WIRED
EOF_WIRED
fi

# ---------- C2: hook script soundness ----------
PRESENT_HOOKS=""
if [ -d "$ROOT/.tad/hooks" ]; then
  PRESENT_HOOKS="$(find "$ROOT/.tad/hooks" -type f -name '*.sh' -print0 2>/dev/null | while IFS= read -r -d '' _f; do printf '%s\n' "${_f#$ROOT/}"; done | LC_ALL=C sort)"
fi
SCRIPTS_N=0
if [ -n "$PRESENT_HOOKS" ]; then
  SCRIPTS_N="$(printf '%s\n' "$PRESENT_HOOKS" | wc -l | tr -d ' ')"
fi
if [ "$BASELINE_OK" -eq 1 ]; then
  while IFS= read -r _p; do
    [ -n "$_p" ] || continue
    P2="${P2}MISSING $_p
"
  done <<EOF_C2MISS
$(_set_diff "$B_HOOKS" "$PRESENT_HOOKS")
EOF_C2MISS
  if [ -n "$PRESENT_HOOKS" ]; then
    while IFS= read -r _p; do
      [ -n "$_p" ] || continue
      P2="${P2}UNLISTED $_p
"
    done <<EOF_C2UNL
$(_set_diff "$PRESENT_HOOKS" "$B_HOOKS")
EOF_C2UNL
  fi
fi
if [ -n "$PRESENT_HOOKS" ]; then
  # Soundness sweep over every present script (no whitelist).
  while IFS= read -r _p; do
    [ -n "$_p" ] || continue
    if [ ! -s "$ROOT/$_p" ]; then
      P2="${P2}EMPTY $_p
"
    fi
    _err="$(bash -n "$ROOT/$_p" 2>&1 || true)"
    if [ -n "$_err" ]; then
      P2="${P2}SYNTAX $_p: ${_err%%$'\n'*}
"
    fi
  done <<EOF_C2SCAN
$PRESENT_HOOKS
EOF_C2SCAN
fi
P2="${P2}${MOD2}"

# ---------- C3: version three-point consistency ----------
_cfg_ver=""
if [ -f "$ROOT/.tad/config.yaml" ]; then
  _cfg_ver="$(sed -n 's/^version:[[:space:]]*//p' "$ROOT/.tad/config.yaml" | head -1)"
  case "$_cfg_ver" in
    *' #'*) _cfg_ver="${_cfg_ver%%' #'*}" ;;
  esac
  _cfg_ver="$(printf '%s' "$_cfg_ver" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  case "$_cfg_ver" in
    \"*\") _cfg_ver="${_cfg_ver#\"}"; _cfg_ver="${_cfg_ver%\"}" ;;
    \'*\') _cfg_ver="${_cfg_ver#\'}"; _cfg_ver="${_cfg_ver%\'}" ;;
  esac
fi
_vt_ver=""
if [ -f "$ROOT/.tad/version.txt" ]; then
  _vt_ver="$(tr -d '[:space:]' < "$ROOT/.tad/version.txt")"
fi
_tv_ver=""
if [ -f "$ROOT/.tad/TAD-VERSION" ]; then
  _tv_ver="$(tr -d '[:space:]' < "$ROOT/.tad/TAD-VERSION")"
fi
[ -n "$_cfg_ver" ] || P3="${P3}MISSING .tad/config.yaml
"
[ -n "$_vt_ver" ] || P3="${P3}MISSING .tad/version.txt
"
[ -n "$_tv_ver" ] || P3="${P3}MISSING .tad/TAD-VERSION
"
if [ -n "$_cfg_ver" ] && [ -n "$_vt_ver" ] && [ -n "$_tv_ver" ]; then
  if [ "$_cfg_ver" != "$_vt_ver" ] || [ "$_vt_ver" != "$_tv_ver" ]; then
    P3="${P3}VERSION MISMATCH config.yaml=$_cfg_ver version.txt=$_vt_ver TAD-VERSION=$_tv_ver
"
  fi
fi
P3="${P3}${MOD3}"
VERSION_V="$_vt_ver"

# ---------- C4: config structure and modules ----------
CONFIG_FILES=""   # present config files (relpaths) for the parse leg
if [ -f "$ROOT/.tad/config.yaml" ]; then
  CONFIG_FILES=".tad/config.yaml"
  if [ ! -s "$ROOT/.tad/config.yaml" ]; then
    P4="${P4}EMPTY .tad/config.yaml
"
  fi
fi
MODS_DERIVED=""
if [ -f "$ROOT/.tad/config.yaml" ]; then
  MODS_DERIVED="$(grep -oE '\.tad/config-[A-Za-z0-9_-]+\.yaml' "$ROOT/.tad/config.yaml" </dev/null 2>/dev/null | LC_ALL=C sort -u || true)"
else
  P4="${P4}UNVERIFIABLE config-modules: .tad/config.yaml absent
"
fi
# Expected modules = derived ∪ baseline-listed.
_MODS_ALL="$(printf '%s\n%s\n' "$MODS_DERIVED" "$B_CONFIGMODS" | sed '/^$/d' | LC_ALL=C sort -u || true)"
if [ -n "$_MODS_ALL" ]; then
  while IFS= read -r _p; do
    [ -n "$_p" ] || continue
    if [ ! -f "$ROOT/$_p" ]; then
      P4="${P4}MISSING $_p
"
    elif [ ! -s "$ROOT/$_p" ]; then
      P4="${P4}EMPTY $_p
"
    else
      CONFIG_FILES="${CONFIG_FILES}
$_p"
    fi
  done <<EOF_C4
$_MODS_ALL
EOF_C4
fi
P4="${P4}${MOD4}"
# Parse leg (single python3 call for the whole set; degradable, D6).
if [ "${TAD_COMPONENT_CHECK_YAML:-}" = "off" ]; then
  SKIP_LINES="${SKIP_LINES}SKIPPED config-parse: disabled (TAD_COMPONENT_CHECK_YAML=off)
"
elif [ -n "$CONFIG_FILES" ]; then
  _py_args=()
  while IFS= read -r _p; do
    [ -n "$_p" ] || continue
    _py_args[${#_py_args[@]}]="$ROOT/$_p"
  done <<EOF_C4ARGS
$CONFIG_FILES
EOF_C4ARGS
  if command -v python3 >/dev/null 2>&1; then
    # Exit 3 from the snippet = PyYAML not importable -> degrade to the
    # yq / SKIPPED leg instead of a second probe process.
    _bad="$(python3 - "${_py_args[@]}" <<'PYEOF'
import sys
try:
    import yaml
except Exception:
    sys.exit(3)
# CSafeLoader is the C accelerator of the same SafeLoader class that
# yaml.safe_load uses — identical safe-load semantics, lower latency.
_loader = getattr(yaml, "CSafeLoader", None)
for p in sys.argv[1:]:
    try:
        with open(p, "r") as fh:
            if _loader is not None:
                yaml.load(fh, Loader=_loader)
            else:
                yaml.safe_load(fh)
    except Exception:
        print(p)
PYEOF
)"
    _py_rc=$?
  else
    _bad=""
    _py_rc=3
  fi
  if [ "$_py_rc" -eq 3 ]; then
    if command -v yq >/dev/null 2>&1; then
      while IFS= read -r _p; do
        [ -n "$_p" ] || continue
        if ! yq '.' "$ROOT/$_p" >/dev/null 2>&1; then
          P4="${P4}UNPARSEABLE $_p
"
        fi
      done <<EOF_C4YQ
$CONFIG_FILES
EOF_C4YQ
    else
      SKIP_LINES="${SKIP_LINES}SKIPPED config-parse: no YAML parser available
"
    fi
  elif [ -n "$_bad" ]; then
    while IFS= read -r _p; do
      [ -n "$_p" ] || continue
      P4="${P4}UNPARSEABLE ${_p#$ROOT/}
"
    done <<EOF_C4BAD
$_bad
EOF_C4BAD
  fi
fi

# ---------- C5: template presence and soundness ----------
PRESENT_TEMPLATES=""
if [ -d "$ROOT/.tad/templates" ]; then
  PRESENT_TEMPLATES="$(find "$ROOT/.tad/templates" -type f -print0 2>/dev/null | while IFS= read -r -d '' _f; do printf '%s\n' "${_f#$ROOT/}"; done | LC_ALL=C sort)"
fi
TEMPLATES_N=0
if [ -n "$PRESENT_TEMPLATES" ]; then
  TEMPLATES_N="$(printf '%s\n' "$PRESENT_TEMPLATES" | wc -l | tr -d ' ')"
fi
if [ "$BASELINE_OK" -eq 1 ]; then
  while IFS= read -r _p; do
    [ -n "$_p" ] || continue
    P5="${P5}MISSING $_p
"
  done <<EOF_C5MISS
$(_set_diff "$B_TEMPLATES" "$PRESENT_TEMPLATES")
EOF_C5MISS
  if [ -n "$PRESENT_TEMPLATES" ]; then
    while IFS= read -r _p; do
      [ -n "$_p" ] || continue
      P5="${P5}UNLISTED $_p
"
    done <<EOF_C5UNL
$(_set_diff "$PRESENT_TEMPLATES" "$B_TEMPLATES")
EOF_C5UNL
  fi
fi
if [ -n "$PRESENT_TEMPLATES" ]; then
  while IFS= read -r _p; do
    [ -n "$_p" ] || continue
    if [ ! -s "$ROOT/$_p" ]; then
      P5="${P5}EMPTY $_p
"
    fi
  done <<EOF_C5SCAN
$PRESENT_TEMPLATES
EOF_C5SCAN
fi
P5="${P5}${MOD5}"

# ---------- C6: template reference integrity ----------
REFS=""
# Per-root presence checks (absent/non-regular roots are loud, D10); the
# enumeration itself is one find pass over the surviving roots.
_c6_roots=()
for _root in AGENTS.md .tad/gates .tad/tasks .agents/skills .tad/hooks .tad/scripts .tad/workflows .tad/project-knowledge; do
  if [ -f "$ROOT/$_root" ] || [ -d "$ROOT/$_root" ]; then
    _c6_roots[${#_c6_roots[@]}]="$ROOT/$_root"
  elif [ -e "$ROOT/$_root" ] || [ -L "$ROOT/$_root" ]; then
    P6="${P6}UNVERIFIABLE source: $_root not a regular file
"
  else
    P6="${P6}UNVERIFIABLE source: $_root absent
"
  fi
done
if [ ${#_c6_roots[@]} -gt 0 ]; then
  # One find pass, two branches: non-regular entries are -print'ed (stream
  # lines start with the absolute root), regular files are fed to a single
  # batched grep (stream lines are template tokens). The baseline itself is
  # excluded by -path so derivation cannot copy the baseline table.
  _c6_mix="$(find "${_c6_roots[@]}" \( ! -type d ! -xtype f -print \) -o \( -xtype f ! -path "$BASELINE_ABS" -exec grep -hoE '\.tad/templates/[A-Za-z0-9_./*-]+' {} + \) </dev/null 2>/dev/null || true)"
  _raw_refs=""
  if [ -n "$_c6_mix" ]; then
    while IFS= read -r _l; do
      case "$_l" in
        "$ROOT"/*)
          P6="${P6}UNVERIFIABLE source: ${_l#$ROOT/} not a regular file
" ;;
        .tad/templates/*)
          _raw_refs="${_raw_refs}$_l
" ;;
      esac
    done <<EOF_C6MIX
$_c6_mix
EOF_C6MIX
  fi
  if [ -n "$_raw_refs" ]; then
    REFS="$(printf '%s' "$_raw_refs" | sed -e 's#[./]*$##' | grep -v '\*' | while IFS= read -r _t; do
      case "$_t" in
        *.md|*.yaml|*.yml|*.json|*.txt|*.toml|*.sh|*.ts|*.js) printf '%s\n' "$_t" ;;
        *) if [ -d "$ROOT/$_t" ]; then printf '%s\n' "$_t"; fi ;;
      esac
    done | grep -v -F -x '.tad/templates/local/chain-manifest-template.md' | LC_ALL=C sort -u || true)"
  fi
fi
REFS_N=0
if [ -n "$REFS" ]; then
  REFS_N="$(printf '%s\n' "$REFS" | wc -l | tr -d ' ')"
  while IFS= read -r _p; do
    [ -n "$_p" ] || continue
    if [ ! -e "$ROOT/$_p" ] && [ ! -L "$ROOT/$_p" ]; then
      P6="${P6}MISSING $_p
"
    fi
  done <<EOF_C6
$REFS
EOF_C6
fi

# ---------- assembly ----------
_face_sorted() {
  if [ -n "$1" ]; then
    printf '%s' "$1" | LC_ALL=C sort
  fi
}
ALL_PROBLEMS="$(_face_sorted "$P1")
$(_face_sorted "$P2")
$(_face_sorted "$P3")
$(_face_sorted "$P4")
$(_face_sorted "$P5")
$(_face_sorted "$P6")"
UNIQ_PROBLEMS=""
if [ -n "$ALL_PROBLEMS" ]; then
  UNIQ_PROBLEMS="$(printf '%s\n' "$ALL_PROBLEMS" | sed '/^$/d' | awk '!seen[$0]++')"
fi
K=0
if [ -n "$UNIQ_PROBLEMS" ]; then
  K="$(printf '%s\n' "$UNIQ_PROBLEMS" | wc -l | tr -d ' ')"
fi

if [ "$LINE_MODE" -eq 1 ]; then
  if [ "$K" -eq 0 ]; then
    printf 'Components: OK (v%s)\n' "$VERSION_V"
    exit 0
  fi
  # Build the named items in output order, deduped by file path (HANDOFF
  # §4.2, Gate 3 ruling on domain P1-2): several problem lines for one file
  # take ONE name slot; k still counts problem lines. The face-level names
  # (version-mismatch / baseline-unverifiable) are items of their own and
  # never merge with a file name, even when they share a source file.
  _names=""
  _paths=""
  _keys=""
  while IFS= read -r _line; do
    [ -n "$_line" ] || continue
    case "$_line" in
      'VERSION MISMATCH '*)
        _key="face:version-mismatch"; _nm="version-mismatch"; _tok="-" ;;
      'UNVERIFIABLE baseline'*)
        _key="face:baseline-unverifiable"; _nm="baseline-unverifiable"; _tok="-" ;;
      *)
        _tok=""
        for _w in $_line; do
          case "$_w" in
            */*) _tok="$_w"; break ;;
          esac
        done
        _tok="${_tok%:}"
        _key="path:$_tok"; _nm="$(basename "$_tok")" ;;
    esac
    if ! printf '%s' "$_keys" | grep -q -F -x -- "$_key"; then
      _keys="${_keys}${_key}
"
      _names="${_names}${_nm}
"
      _paths="${_paths}${_tok}
"
    fi
  done <<EOF_NAMES
$UNIQ_PROBLEMS
EOF_NAMES
  _items=0
  if [ -n "$_names" ]; then
    _items="$(printf '%s' "$_names" | wc -l | tr -d ' ')"
  fi
  _shown_names="$(printf '%s\n' "$_names" | head -n 3)"
  _shown_paths="$(printf '%s\n' "$_paths" | head -n 3)"
  _disp=""
  _i=0
  while IFS= read -r _nm; do
    [ -n "$_nm" ] || continue
    _i=$((_i + 1))
    _pth="$(printf '%s\n' "$_shown_paths" | sed -n "${_i}p")"
    _dup=0
    if [ "$_pth" != "-" ]; then
      _dups="$(printf '%s\n' "$_shown_names" | grep -c -F -x "$_nm" || true)"
      if [ "${_dups:-0}" -gt 1 ]; then
        _dup=1
      fi
    fi
    if [ "$_dup" -eq 1 ]; then
      _disp="${_disp}, $(basename "$(dirname "$_pth")")/$(basename "$_pth")"
    else
      _disp="${_disp}, $_nm"
    fi
  done <<EOF_DISP
$_shown_names
EOF_DISP
  _disp="${_disp#, }"
  if [ "$_items" -gt 3 ]; then
    _disp="${_disp}, +$((_items - 3)) more"
  fi
  printf 'Components: %s PROBLEMS: %s — run .tad/hooks/lib/component-health-check.sh for detail\n' "$K" "$_disp"
  exit 1
fi

printf 'TAD component health — root: %s\n' "$ROOT"
if [ -n "$UNIQ_PROBLEMS" ]; then
  printf '%s\n' "$UNIQ_PROBLEMS"
fi
if [ -n "$SKIP_LINES" ]; then
  printf '%s' "$SKIP_LINES" | LC_ALL=C sort
fi
if [ "$K" -eq 0 ]; then
  printf 'COMPONENTS: OK (scripts=%s templates=%s version=%s wired=%s refs=%s)\n' "$SCRIPTS_N" "$TEMPLATES_N" "$VERSION_V" "$WIRED_N" "$REFS_N"
  exit 0
fi
printf 'COMPONENTS: PROBLEMS %s\n' "$K"
exit 1
