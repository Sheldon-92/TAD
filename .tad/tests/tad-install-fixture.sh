#!/bin/bash
# tad-install-fixture.sh - behaviour test for bin/tad-install.mjs (the `npx` entry point).
#
# bin/tad-install.mjs finds tad.sh one directory above its own location, so the test copies the
# installer and .tad/platform-codes.yaml into a throw-away tree next to a fake tad.sh that only records
# the arguments it receives. Nothing is installed, nothing touches the network, the repo copy of
# bin/tad-install.mjs is not modified.
#
#   bash .tad/tests/tad-install-fixture.sh
# Last line: TAD-INSTALL-FIXTURE: PASS | FAIL.  Written for bash 3.2.

HERE="$(cd "$(dirname "$0")" && pwd -P)"
REPO="$(cd "$HERE/../.." && pwd -P)"

FAILS=0
ok()  { echo "ok $1"; }
bad() { echo "FAIL $1"; FAILS=$((FAILS + 1)); }

T="$(mktemp -d)" || exit 2
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/.tad" "$T/work"
cp "$REPO/bin/tad-install.mjs" "$T/bin/tad-install.mjs"
cp "$REPO/.tad/platform-codes.yaml" "$T/.tad/platform-codes.yaml"
# Fake tad.sh: one received argument per line.
cat > "$T/tad.sh" <<'FAKE'
#!/bin/bash
: > "$(dirname "$0")/args.out"
for a in "$@"; do printf '%s\n' "$a" >> "$(dirname "$0")/args.out"; done
exit 0
FAKE

# run_install <args...>: runs the copied installer from an empty working directory.
# Sets RC, ERR (stderr text), GOT (arguments the fake tad.sh received, space-joined; empty if not called).
run_install() {
  rm -f "$T/args.out"
  ( cd "$T/work" && node "$T/bin/tad-install.mjs" "$@" > "$T/stdout.txt" 2> "$T/stderr.txt" )
  RC=$?
  ERR="$(cat "$T/stderr.txt")"
  GOT=""
  [ -f "$T/args.out" ] && GOT="$(tr '\n' ' ' < "$T/args.out" | sed 's/ $//')"
}

# Accepted platforms are passed through unchanged, followed by --yes.
for p in claude-code codex opencode cursor; do
  run_install --platform "$p"
  if [ "$RC" = 0 ] && [ "$GOT" = "$(printf '%s' "--platform $p --yes")" ]; then
    ok "--platform $p is passed to tad.sh unchanged ($GOT)"
  else
    bad "--platform $p: rc=$RC, tad.sh received '$GOT'"
  fi
done

# The retired dual-tree value is refused before tad.sh is called, and the message points at the two
# values it names today.
run_install --platform both
if [ "$RC" != 0 ] && [ -z "$GOT" ]; then ok "--platform both is rejected (rc=$RC) and tad.sh is not called"; else bad "--platform both: rc=$RC, tad.sh received '$GOT'"; fi
case "$ERR" in
  *codex*claude-code*|*claude-code*codex*) ok "--platform both: stderr names codex and claude-code" ;;
  *) bad "--platform both: stderr is '$ERR'" ;;
esac

# A comma list is not a platform: refused, and the message lists every valid value.
run_install --platform claude-code,codex
if [ "$RC" != 0 ] && [ -z "$GOT" ]; then ok "--platform claude-code,codex is rejected (rc=$RC) and tad.sh is not called"; else bad "--platform claude-code,codex: rc=$RC, tad.sh received '$GOT'"; fi
all4=1
for v in codex opencode cursor claude-code; do
  case "$ERR" in *"$v"*) ;; *) all4=0 ;; esac
done
[ "$all4" = 1 ] && ok "--platform claude-code,codex: stderr lists codex, opencode, cursor, claude-code" || bad "--platform claude-code,codex: stderr is '$ERR'"

# Current behaviour without --platform: install for codex (bin/tad-install.mjs: `argPlatform || 'codex'`).
run_install
if [ "$RC" = 0 ] && [ "$GOT" = "--platform codex --yes" ]; then
  ok "no --platform defaults to codex ($GOT)"
else
  bad "no --platform: rc=$RC, tad.sh received '$GOT'"
fi

# --force is forwarded after --yes.
run_install --platform cursor --force
if [ "$RC" = 0 ] && [ "$GOT" = "--platform cursor --yes --force" ]; then ok "--force is forwarded ($GOT)"; else bad "--force: rc=$RC, tad.sh received '$GOT'"; fi

# A failing tad.sh makes the installer fail with the same non-zero status.
printf '#!/bin/bash\nexit 7\n' > "$T/tad.sh"
run_install --platform codex
[ "$RC" = 7 ] && ok "tad.sh failure status is propagated (rc=7)" || bad "tad.sh exit 7 became rc=$RC"

if [ "$FAILS" = 0 ]; then echo "TAD-INSTALL-FIXTURE: PASS"; exit 0; fi
echo "TAD-INSTALL-FIXTURE: FAIL"
exit 1
