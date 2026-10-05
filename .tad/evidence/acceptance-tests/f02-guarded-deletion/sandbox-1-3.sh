#!/usr/bin/env bash
# F-02 sandbox scenarios 1-3: extract apply_deprecations from tad.sh and run it
# against a constructed target project.
#
# Per handoff §8.1: scenarios 1-3 may use the extraction approach, BUT must extract
# the source statement and every helper along with it — otherwise the sandbox runs a
# different function than the real installer (五版全败 lesson #1).
#
# Scenario 4 (mixed manifest through the REAL install path with ERR trap armed) is a
# separate script — extraction cannot see the `set -e` + trap interaction by construction.
set -uo pipefail

REPO="$1"          # path to the TAD repo containing the modified tad.sh
SB=$(mktemp -d)    # sandbox root — must NOT contain spaces (handoff §8.1)
case "$SB" in *" "*) echo "SANDBOX PATH HAS SPACES — abort"; exit 1;; esac

PROJ="$SB/proj"        # simulated target project
SRC="$SB/src"          # simulated install source
OUTSIDE="$SB/outside"  # user data OUTSIDE the project (symlink target)

mkdir -p "$PROJ" "$SRC" "$OUTSIDE"

# --- build the "source" tree (what the installer would install from) --------
mkdir -p "$SRC/.tad/hooks/lib"
cp "$REPO/.tad/hooks/lib/migration-engine.sh" "$SRC/.tad/hooks/lib/"
cp "$REPO/.tad/hooks/lib/derive-sync-set.sh"  "$SRC/.tad/hooks/lib/"
# derive-sync-set.sh needs the real repo layout to emit the zero-touch list
mkdir -p "$SRC/.tad/project-knowledge" "$SRC/.tad/memory" "$SRC/.tad/active" \
         "$SRC/.tad/evidence" "$SRC/.tad/decisions"
echo "2.42.0" > "$SRC/.tad/version.txt"

# --- extract the real helpers + apply_deprecations from tad.sh -------------
EXTRACT="$SB/extracted.sh"
{
  echo '#!/usr/bin/env bash'
  echo 'set -uo pipefail'
  # Color vars — log_* helpers reference them; omitting these makes every scenario
  # die with "BLUE: unbound variable" and the guards never run, which would show up
  # as a FALSE GREEN on AC-4/AC-5 (file survives because the script crashed, not
  # because the guard held). 五版全败 lesson #1: extract EVERY dependency.
  sed -n '10,15p' "$REPO/tad.sh"
  # log helpers (real ones from tad.sh)
  sed -n '/^log_info()/,/^}/p'    "$REPO/tad.sh"
  sed -n '/^log_warn()/,/^}/p'    "$REPO/tad.sh"
  sed -n '/^log_success()/,/^}/p' "$REPO/tad.sh"
  sed -n '/^log_error()/,/^}/p'   "$REPO/tad.sh"
  # version_le (tad.sh's own; engine overrides it after source — that is expected)
  sed -n '/^version_le()/,/^}/p'  "$REPO/tad.sh"
  # the function under test, extracted verbatim
  sed -n '/^apply_deprecations()/,/^}/p' "$REPO/tad.sh"
  echo 'apply_deprecations "$1"'
} > "$EXTRACT"

run_scenario() {
  local name="$1" manifest_entry="$2"
  cat > "$SRC/.tad/deprecation.yaml" <<YAML
deprecations:
  "2.0.0":
    date: "2026-01-01"
    description: "sandbox fixture"
    files:
      - "$manifest_entry"
YAML
  local out rc
  out=$( cd "$PROJ" && bash "$EXTRACT" "$SRC" 2>&1 ); rc=$?
  printf '%s\n' "$out"
  echo "SCENARIO_RC=$rc"
  # Discrimination self-check: a crashed run must NOT be read as "the guard held".
  # If the function did not reach its summary line, any "file survived" verdict below
  # is meaningless — fail loudly instead.
  if ! printf '%s' "$out" | grep -q 'deprecated file'; then
    echo "SCENARIO_INVALID: apply_deprecations did not reach its summary line — verdict below is NOT trustworthy"
    return 1
  fi
  return 0
}

echo "############ SCENARIO 1: normal deprecated file MUST be deleted ############"
mkdir -p "$PROJ/.tad/templates"
echo "stale" > "$PROJ/.tad/templates/x.template"
run_scenario "normal" ".tad/templates/x.template"
if [ -e "$PROJ/.tad/templates/x.template" ]; then
  echo "AC-3 FAIL: normal deprecated file survived (NFR4 broken)"
else
  echo "AC-3 PASS: normal deprecated file deleted"
fi

echo
echo "############ SCENARIO 2: symlinked dir → outside file MUST survive ############"
echo "USER DATA" > "$OUTSIDE/precious.md"
rm -rf "$PROJ/.tad/domains"
ln -s "$OUTSIDE" "$PROJ/.tad/domains"
run_scenario "symlink" ".tad/domains/precious.md"
if [ -e "$OUTSIDE/precious.md" ]; then
  echo "AC-4 PASS: outside-project file survived (containment guard held)"
else
  echo "AC-4 FAIL: outside-project user data was DELETED"
fi

echo
echo "############ SCENARIO 3: zero-touch subtree MUST survive ############"
mkdir -p "$PROJ/.tad/memory"
echo "user memory" > "$PROJ/.tad/memory/note.md"
run_scenario "zero-touch" ".tad/memory"
if [ -e "$PROJ/.tad/memory/note.md" ]; then
  echo "AC-5 PASS: zero-touch subtree survived"
else
  echo "AC-5 FAIL: zero-touch subtree was DELETED"
fi

echo
echo "############ AC-1b / AC-1b2: guard functions must come FROM the engine ############"
cat > "$SB/probe.sh" <<'PROBE'
#!/usr/bin/env bash
source "$1/.tad/hooks/lib/migration-engine.sh"
shopt -s extdebug
for fn in guarded_remove check_containment check_zero_touch do_backup; do
  # NOTE: cut -d' ' -f3- (not awk $3) — repo paths may contain spaces
  src=$(declare -F "$fn" | cut -d' ' -f3-)
  printf '%s <- %s\n' "$fn" "$src"
done
PROBE
bash "$SB/probe.sh" "$SRC"

echo
echo "SANDBOX=$SB"