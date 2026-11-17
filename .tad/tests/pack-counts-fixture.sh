#!/bin/bash
# pack-counts-fixture.sh - nine cases for .tad/scripts/pack-counts.sh --check.
#
#   bash .tad/tests/pack-counts-fixture.sh
#
# Copies the real registry, categories file and INSTALLATION_GUIDE.md into its own mktemp directory, breaks one
# thing per case, runs `pack-counts.sh --check` on the copies and asserts BOTH the exit code and the first
# stderr line (a non-zero exit alone could come from some other error). Touches nothing in the project; does
# not call git. Last line: `PACK-COUNTS-FIXTURE: PASS` or `PACK-COUNTS-FIXTURE: FAIL`.
# Maintainer fixture: it needs INSTALLATION_GUIDE.md, which downstream projects do not have.
# Written for bash 3.2 and BSD tools (perl is used for in-place text edits; macOS ships it).

set -u

HERE="$(cd "$(dirname "$0")" && pwd -P)"
REPO="$(cd "$HERE/../.." && pwd -P)"
SCRIPT="$REPO/.tad/scripts/pack-counts.sh"
REG="$REPO/.tad/capability-packs/pack-registry.yaml"
CAT="$REPO/.tad/scripts/pack-categories.tsv"
DOC="$REPO/INSTALLATION_GUIDE.md"

for f in "$SCRIPT" "$REG" "$CAT" "$DOC"; do
  [ -r "$f" ] || { echo "FAIL setup: cannot read $f"; echo "PACK-COUNTS-FIXTURE: FAIL"; exit 1; }
done

W="$(mktemp -d "${TMPDIR:-/tmp}/pack-counts-fixture.XXXXXX")" || exit 1
trap 'rm -rf "$W"' EXIT

FAILS=0

# run_case <name> <expected exit> <expected first stderr line prefix>   (inputs are $W/reg $W/cat $W/doc)
run_case() {
  local name="$1" want_rc="$2" want_err="$3" rc first
  /bin/bash "$SCRIPT" --check --registry "$W/reg" --categories "$W/cat" --doc "$W/doc" > "$W/out" 2> "$W/err"
  rc=$?
  first="$(head -n 1 "$W/err")"
  if [ "$rc" -eq "$want_rc" ] && { [ "$want_rc" -ne 0 ] || [ ! -s "$W/err" ]; }; then
    case "$first" in
      "$want_err"*) echo "PASS $name"; return 0 ;;
    esac
  fi
  echo "FAIL $name: exit=$rc stderr=$first"
  FAILS=$((FAILS + 1))
}

fresh() { cp "$REG" "$W/reg"; cp "$CAT" "$W/cat"; cp "$DOC" "$W/doc"; }
add_pack_to_registry() { printf '  - name: "zz-new-pack"\n    status: "active"\n' >> "$W/reg"; }

# real: unchanged inputs are consistent
fresh
run_case real 0 ""

# status-flip: one active pack becomes frozen in the registry; the guide is now stale
fresh
perl -0pi -e 's/status: "active"/status: "frozen"/' "$W/reg"
run_case status-flip 1 "PACK-COUNTS: STALE block"

# add-pack: a pack is added to registry and categories; the guide is now stale
fresh
add_pack_to_registry
printf 'zz-new-pack\t安全\n' >> "$W/cat"
run_case add-pack 1 "PACK-COUNTS: STALE block"

# outside-phrase (structural counter-example): the block is right, a count sentence outside it is wrong
fresh
# the wrong sentence is built from the generator's own phrase for these inputs, so the case follows the registry
P="$(/bin/bash "$SCRIPT" --phrase --registry "$W/reg" --categories "$W/cat")"
N="${P%% *}"
OLD="${P}。无需" NEW="$((N + 1)) 个 packs。无需" perl -pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/' "$W/doc"
want_line="$(grep -n -F "$((N + 1)) 个 packs。无需" "$W/doc" | head -n 1 | cut -d: -f1)"
run_case outside-phrase 1 "PACK-COUNTS: STALE line ${want_line:-?}:"

# uncategorized: a pack in the registry that the categories file does not know
fresh
add_pack_to_registry
run_case uncategorized 2 "PACK-COUNTS-ERROR: uncategorized zz-new-pack"

# stale-category: a name in the categories file that the registry does not have
fresh
printf 'zz-ghost-pack\t安全\n' >> "$W/cat"
run_case stale-category 2 "PACK-COUNTS-ERROR: stale category zz-ghost-pack"

# no-markers: the END marker is gone
fresh
grep -v '^<!-- PACK-COUNTS:END -->$' "$DOC" > "$W/doc"
run_case no-markers 2 "PACK-COUNTS-ERROR: markers"

# malformed-entry: an entry-start line the parser does not recognise (single quotes) must stop it, not vanish
fresh
printf "  - name: 'zz-sneaky-pack'\n    status: 'active'\n" >> "$W/reg"
run_case malformed-entry 2 "PACK-COUNTS-ERROR: registry has"

# duplicate-name: the same pack name twice in the registry
fresh
dupname="$(sed -n -E 's/^  - name: "([^"]*)"[[:space:]]*$/\1/p' "$REG" | head -n 1)"
printf '  - name: "%s"\n    status: "active"\n' "$dupname" >> "$W/reg"
run_case duplicate-name 2 "PACK-COUNTS-ERROR: duplicate $dupname"

if [ "$FAILS" -eq 0 ]; then
  echo "PACK-COUNTS-FIXTURE: PASS"
  exit 0
fi
echo "PACK-COUNTS-FIXTURE: FAIL"
exit 1
