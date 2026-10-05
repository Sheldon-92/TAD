#!/usr/bin/env bash
# F-02 P1 fix verification (code-reviewer round-1 findings):
#   P1-1: unreadable zero-touch authority must degrade to warn+skip, NOT kill the install
#   P1-2: "."/".." entries must be refused BEFORE do_backup cp -a's a whole tree
#   NFR4 regression: the one legitimate trailing-slash entry (.tad/codex/schemas/) must
#                    still be deletable — i.e. the narrow traversal screen must NOT have
#                    imported validate_path's allow-list / trailing-slash rules.
set -uo pipefail

REPO="$1"
SB=$(mktemp -d); case "$SB" in *" "*) echo "SANDBOX HAS SPACES"; exit 1;; esac
PROJ="$SB/proj"; SRC="$SB/src"
mkdir -p "$PROJ" "$SRC/.tad/hooks/lib"
cp "$REPO/.tad/hooks/lib/migration-engine.sh" "$SRC/.tad/hooks/lib/"
cp "$REPO/.tad/hooks/lib/derive-sync-set.sh"  "$SRC/.tad/hooks/lib/"
mkdir -p "$SRC/.tad/project-knowledge" "$SRC/.tad/memory" "$SRC/.tad/active" \
         "$SRC/.tad/evidence" "$SRC/.tad/decisions"
echo "2.42.0" > "$SRC/.tad/version.txt"

EXTRACT="$SB/extracted.sh"
{
  echo '#!/usr/bin/env bash'
  echo 'set -euo pipefail'          # ERR-trap-adjacent: same strictness as installer
  sed -n '10,15p' "$REPO/tad.sh"
  for fn in log_info log_warn log_success log_error version_le apply_deprecations; do
    sed -n "/^${fn}()/,/^}/p" "$REPO/tad.sh"
  done
  echo 'apply_deprecations "$1"; echo "EXTRACT_RC=$?"'
} > "$EXTRACT"

manifest() {
  cat > "$SRC/.tad/deprecation.yaml" <<YAML
deprecations:
  "2.0.0":
    date: "2026-01-01"
    description: "P1 fixture"
    files:
$(for e in "$@"; do printf '      - "%s"\n' "$e"; done)
YAML
}

echo "########## P1-1: unreadable zero-touch authority ##########"
# Break the authority the way a corrupted/absent install would
mv "$SRC/.tad/hooks/lib/derive-sync-set.sh" "$SRC/.tad/hooks/lib/derive-sync-set.sh.bak"
mkdir -p "$PROJ/.tad/templates"; echo x > "$PROJ/.tad/templates/x.template"
manifest ".tad/templates/x.template"
OUT=$( cd "$PROJ" && bash "$EXTRACT" "$SRC" 2>&1 ); RC=$?
printf '%s\n' "$OUT" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/^/    /'
echo "    harness_rc=$RC"
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q 'authority unavailable'; then
  echo "P1-1 PASS: degraded to warn+skip, installer survived (rc=0)"
else
  echo "P1-1 FAIL: expected rc=0 + warn, got rc=$RC"
fi
if [ -e "$PROJ/.tad/templates/x.template" ]; then
  echo "P1-1 fail-closed OK: nothing deleted without authority"
else
  echo "P1-1 FAIL: deleted a file with no zero-touch authority (fail-OPEN)"
fi
mv "$SRC/.tad/hooks/lib/derive-sync-set.sh.bak" "$SRC/.tad/hooks/lib/derive-sync-set.sh"

echo
echo "########## P1-2: traversal entries refused before do_backup ##########"
rm -rf "$PROJ/.tad-backup"
manifest ".." "." ".tad/templates/x.template"
OUT=$( cd "$PROJ" && bash "$EXTRACT" "$SRC" 2>&1 ); RC=$?
printf '%s\n' "$OUT" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/^/    /'
echo "    harness_rc=$RC"
if printf '%s' "$OUT" | grep -q 'REJECT: path traversal'; then
  echo "P1-2 PASS: traversal entries rejected"
else
  echo "P1-2 FAIL: no traversal rejection seen"
fi
# The whole point: no giant tree got copied into the backup area
BK_ENTRIES=$(find "$PROJ/.tad-backup" -mindepth 1 2>/dev/null | wc -l | tr -d ' ')
echo "    .tad-backup entries: $BK_ENTRIES"
if [ "$BK_ENTRIES" -lt 20 ]; then
  echo "P1-2 PASS: no whole-tree cp -a into backup area"
else
  echo "P1-2 FAIL: backup area blew up ($BK_ENTRIES entries)"
fi
if [ -e "$PROJ/.tad/templates/x.template" ]; then
  echo "P1-2 FAIL: normal entry in same manifest was not deleted (loop did not continue)"
else
  echo "P1-2 PASS: loop continued, normal entry still deleted"
fi

echo
echo "########## NFR4 regression: trailing-slash entry must still delete ##########"
rm -rf "$PROJ/.tad-backup"
mkdir -p "$PROJ/.tad/codex/schemas"; echo s > "$PROJ/.tad/codex/schemas/a.json"
manifest ".tad/codex/schemas/"
OUT=$( cd "$PROJ" && bash "$EXTRACT" "$SRC" 2>&1 ); RC=$?
printf '%s\n' "$OUT" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/^/    /'
if [ -e "$PROJ/.tad/codex/schemas" ]; then
  echo "NFR4 FAIL: legitimate trailing-slash entry was NOT deleted (allow-list leaked in)"
else
  echo "NFR4 PASS: trailing-slash entry still deletable"
fi

echo
echo "########## P1-2b: ./-family (self-reference) must be refused too ##########"
# Reviewer round-2 finding: "./" escaped the first case pattern and made do_backup do a
# RECURSIVE self-copy (target incl. .tad-backup copied into its own backup area, nesting
# until the path was too long), after which every later entry failed "backup already exists".
rm -rf "$PROJ/.tad-backup"
mkdir -p "$PROJ/.tad/templates"; echo x > "$PROJ/.tad/templates/x.template"
manifest "./" "a/./" ".//" ".tad/templates/x.template"
OUT=$( cd "$PROJ" && bash "$EXTRACT" "$SRC" 2>&1 ); RC=$?
printf '%s\n' "$OUT" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/^/    /'
if [ "$(printf '%s' "$OUT" | grep -c 'traversal or self-reference')" -ge 1 ]; then
  echo "P1-2b PASS: ./-family rejected"
else
  echo "P1-2b FAIL: ./-family not rejected"
fi
NEST=$(find "$PROJ/.tad-backup" -mindepth 2 -name '.tad-backup' 2>/dev/null | wc -l | tr -d ' ')
echo "    nested .tad-backup inside backup area: $NEST (expect 0)"
[ "$NEST" -eq 0 ] && echo "P1-2b PASS: no recursive self-copy" || echo "P1-2b FAIL: recursive self-copy happened"
[ -e "$PROJ/.tad/templates/x.template" ] && echo "P1-2b FAIL: normal entry not deleted" \
  || echo "P1-2b PASS: normal entry still deleted (run not poisoned)"

echo
echo "########## P1-3: refused entry must NOT leave a copy in .tad-backup ##########"
# Independent-verifier finding: guards saved the ORIGINAL .tad/memory, but do_backup had
# already cp -a'd a COPY into .tad-backup/ — which the target project does not necessarily
# gitignore (only ".tad.backup.*/" dot-form is ignored, not ".tad-backup/").
rm -rf "$PROJ/.tad-backup"
mkdir -p "$PROJ/.tad/memory"; echo "USER SECRET" > "$PROJ/.tad/memory/note.md"
mkdir -p "$PROJ/.tad/templates"; echo x > "$PROJ/.tad/templates/x.template"
manifest ".tad/memory" ".tad/templates/x.template"
OUT=$( cd "$PROJ" && bash "$EXTRACT" "$SRC" 2>&1 ); RC=$?
printf '%s\n' "$OUT" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/^/    /'
[ -f "$PROJ/.tad/memory/note.md" ] && echo "P1-3 PASS: original user data survived" \
  || echo "P1-3 FAIL: original user data deleted"
if find "$PROJ/.tad-backup" -name 'note.md' 2>/dev/null | grep -q .; then
  echo "P1-3 FAIL: refused entry left a COPY in .tad-backup (leak)"
else
  echo "P1-3 PASS: refused entry's backup copy rolled back"
fi
if find "$PROJ/.tad-backup" -name 'x.template' 2>/dev/null | grep -q .; then
  echo "P1-3 PASS: accepted entry's backup retained (recoverable)"
else
  echo "P1-3 FAIL: accepted entry's backup missing"
fi

echo
echo "SANDBOX=$SB"