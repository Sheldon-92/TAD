#!/usr/bin/env bash
# F-02 sandbox scenario 4: MIXED manifest through the REAL install path.
#
# Why this cannot use the extraction approach (handoff §8.1):
#   `set -euo pipefail` (tad.sh:7) + `trap 'rollback_on_failure' ERR` (tad.sh:~1310)
#   only exist in the real installer. P0-2 ("one refused entry destroys the whole
#   install") is INVISIBLE by construction in an extracted harness.
#
# Network bypass: tad.sh sets TAD_SRC only AFTER `curl … | tar -xz`, and this repo has
# no --source mode yet (F-33). We front a `curl` stub on PATH that emits a local tarball
# (handoff §8.1 recipe, verified by Alex).
set -uo pipefail

REPO="$1"
SB=$(mktemp -d)
case "$SB" in *" "*) echo "SANDBOX PATH HAS SPACES — abort"; exit 1;; esac

# 1) stage the modified source as a tarball whose top dir is TAD-main (tad.sh hardcodes it)
#    NOTE: must include the root files the installer copies (CLAUDE.md / AGENTS.md / …).
#    Omitting them makes the install fail LATER for an unrelated reason and muddies the
#    exit-code assertion (①), even though apply_deprecations itself behaved correctly.
mkdir -p "$SB/stage/TAD-main"
( cd "$REPO" && tar -cf - \
    tad.sh CLAUDE.md AGENTS.md README.md \
    .tad .claude/skills 2>/dev/null ) \
  | ( cd "$SB/stage/TAD-main" && tar -xf - )
# drop the repo's own working state from the staged source (not part of a release payload)
rm -rf "$SB/stage/TAD-main/.tad/active" "$SB/stage/TAD-main/.tad/evidence" \
       "$SB/stage/TAD-main/.tad/memory" "$SB/stage/TAD-main/.tad/logs" 2>/dev/null || true

# 2) MIXED manifest: one refused entry (.tad/memory = zero-touch) + one normal entry
cat > "$SB/stage/TAD-main/.tad/deprecation.yaml" <<'YAML'
deprecations:
  "2.0.0":
    date: "2026-01-01"
    description: "mixed manifest fixture (F-02 scenario 4)"
    files:
      - ".tad/memory"
      - ".tad/templates/x.template"
YAML

( cd "$SB/stage" && tar -czf "$SB/src.tgz" TAD-main )

# 3) curl stub — ignores all args, emits the tarball on stdout
mkdir -p "$SB/bin"
cat > "$SB/bin/curl" <<'STUB'
#!/bin/bash
cat "$TAD_STUB_TARBALL"
STUB
chmod +x "$SB/bin/curl"

# 4) target project with BOTH a zero-touch subtree and a normal deprecated file
#    version.txt MUST be an OLDER version — with an equal version the installer
#    short-circuits at "Already vX / Nothing to do" and apply_deprecations never runs.
mkdir -p "$SB/proj/.tad/memory" "$SB/proj/.tad/templates"
echo "USER MEMORY — must survive" > "$SB/proj/.tad/memory/note.md"
echo "stale template — must be deleted" > "$SB/proj/.tad/templates/x.template"
echo "2.40.0" > "$SB/proj/.tad/version.txt"

# 5) run the REAL installer (set -euo pipefail + ERR trap both armed)
cd "$SB/proj"
export TAD_STUB_TARBALL="$SB/src.tgz"
export PATH="$SB/bin:$PATH"

set +e
bash "$SB/stage/TAD-main/tad.sh" --yes > "$SB/install.log" 2>&1
INSTALL_RC=$?
set -e

echo "==================== SCENARIO 4 RESULTS ===================="
echo "① exit code            : $INSTALL_RC   (expected 0)"

# Discrimination self-check FIRST: if apply_deprecations never ran (e.g. the installer
# short-circuited at "Already vX / Nothing to do"), every verdict below is vacuous.
if ! grep -q 'Applying deprecations' "$SB/install.log"; then
  echo "SCENARIO_INVALID: apply_deprecations never ran — verdicts below are vacuous"
  echo "   (check install.log: version short-circuit? download failure?)"
  sed 's/\x1b\[[0-9;]*m//g' "$SB/install.log" | tail -25
  echo "SANDBOX=$SB"
  exit 1
fi
echo "   apply_deprecations reached: YES"

if grep -qE 'refused|ABORT' "$SB/install.log"; then
  echo "② refusal recorded     : YES"
  grep -E 'refused|ABORT' "$SB/install.log" | sed 's/^/      /'
else
  echo "② refusal recorded     : NO  ← AC-6 fails"
fi

if [ -e "$SB/proj/.tad/templates/x.template" ]; then
  echo "③ normal file deleted  : NO  ← AC-6 fails (NFR4 broken)"
else
  echo "③ normal file deleted  : YES"
fi

if [ -e "$SB/proj/.tad/memory/note.md" ]; then
  echo "④ zero-touch survived  : YES"
else
  echo "④ zero-touch survived  : NO  ← guard failed"
fi

echo "   deleted count line   : $(grep -E 'Removed [0-9]+ deprecated|No deprecated files' "$SB/install.log" | tail -1 | sed 's/\x1b\[[0-9;]*m//g')"
echo
echo "install log tail:"
sed 's/\x1b\[[0-9;]*m//g' "$SB/install.log" | tail -25
echo
echo "SANDBOX=$SB"