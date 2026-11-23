#!/bin/bash
# release-verify-fixture.sh — fixture for two release-verify.sh rules (TAD 4.0.13):
#   notes       the `release-notes <repo_root> <version>` gate (installer reader pattern);
#   structural  the one tolerated target-only line `.tad/migrations/genesis.yaml`.
# No git. Temp root from mktemp -d, removed by name at the end.
#
# Usage: release-verify-fixture.sh [--case notes|structural|all]   (default all)
# Output: one `PASS <case>: <what>` / `FAIL <case>: <what>` line per case, last line
# `RELEASE-VERIFY-FIXTURE: PASS <n>/<n>` (else `RELEASE-VERIFY-FIXTURE: FAIL <k>/<n>`);
# exit 0 only when every case passes, 2 on usage.

here="$(cd "$(dirname "$0")" && pwd)"
RV="$(cd "$here/../hooks/lib" 2>/dev/null && pwd)/release-verify.sh"
[ -f "$RV" ] || { echo "RELEASE-VERIFY-FIXTURE: FAIL no script at $RV"; exit 1; }

which_case="all"
if [ $# -gt 0 ]; then
  [ "$1" = "--case" ] && [ $# -eq 2 ] || { echo "Usage: release-verify-fixture.sh [--case notes|structural|all]" >&2; exit 2; }
  which_case="$2"
fi
case "$which_case" in notes|structural|all) ;; *) echo "Usage: release-verify-fixture.sh [--case notes|structural|all]" >&2; exit 2 ;; esac

T="$(mktemp -d "${TMPDIR:-/tmp}/rvfx.XXXXXX")" || { echo "RELEASE-VERIFY-FIXTURE: FAIL mktemp"; exit 1; }
n=0; k=0
pass() { n=$((n + 1)); echo "PASS $1: $2"; }
fail() { n=$((n + 1)); k=$((k + 1)); echo "FAIL $1: $2"; }

# a repo root with a tad.sh holding the reader's _bre line (or not) and a CHANGELOG
mkrepo() { # $1 = dir, $2 = with-bre|no-bre ; CHANGELOG body from stdin
  mkdir -p "$1"
  if [ "$2" = with-bre ]; then
    printf '%s\n' '#!/bin/bash' 'capture_release_notes() {' "    _bre='^-[[:space:]]+\\*\\*([^*]+)\\*\\*'" '}' > "$1/tad.sh"
  else
    printf '%s\n' '#!/bin/bash' 'capture_release_notes() { :; }' > "$1/tad.sh"
  fi
  cat > "$1/CHANGELOG.md"
}

notes_cases() {
  mkrepo "$T/n1" with-bre <<'EOF'
# Changelog

## [9.0.1] - 2026-01-02
- plain bullet one
- plain bullet two

## [9.0.0] - 2026-01-01
- **Old lead** older text
EOF
  out="$(/bin/bash "$RV" release-notes "$T/n1" 9.0.1 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && [ "$out" = "RELEASE-NOTES: 9.0.1 0 lines the installer reads (pattern from tad.sh _bre)" ]; then
    pass notes-plain "plain bullets only: exit 1 and the 0-lines text"
  else fail notes-plain "rc=$rc out=$out"; fi

  mkrepo "$T/n2" with-bre <<'EOF'
## [9.0.1] - 2026-01-02
- **Lead** text the installer prints
- plain bullet

## [9.0.0] - 2026-01-01
- plain
EOF
  out="$(/bin/bash "$RV" release-notes "$T/n2" 9.0.1 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ] && [ "$out" = "RELEASE-NOTES: 9.0.1 1 line(s) the installer reads" ]; then
    pass notes-lead "one lead bullet: exit 0, 1 line"
  else fail notes-lead "rc=$rc out=$out"; fi

  out="$(/bin/bash "$RV" release-notes "$T/n2" 9.0.2 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && [ "$out" = "RELEASE-NOTES: 9.0.2 no section" ]; then
    pass notes-nosection "no section: exit 1"
  else fail notes-nosection "rc=$rc out=$out"; fi

  mkrepo "$T/n4" no-bre <<'EOF'
## [9.0.1] - 2026-01-02
- **Lead** text
EOF
  /bin/bash "$RV" release-notes "$T/n4" 9.0.1 >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq 2 ]; then pass notes-nobre "tad.sh without _bre=: exit 2"
  else fail notes-nobre "rc=$rc"; fi
}

structural_cases() {
  S="$T/src"
  mkdir -p "$S/.tad/migrations" "$S/.tad/hooks" "$S/.tad/capability-packs" "$S/.agents/skills/s"
  printf 'a: 1\n' > "$S/.tad/migrations/a.yaml"
  printf '#!/bin/bash\necho h\n' > "$S/.tad/hooks/h.sh"
  printf 'packs: []\n' > "$S/.tad/capability-packs/pack-registry.yaml"
  printf '# s\n' > "$S/.agents/skills/s/SKILL.md"

  t1="$T/t1"; cp -R "$S" "$t1"; printf 'genesis: 1\n' > "$t1/.tad/migrations/genesis.yaml"
  out="$(/bin/bash "$RV" structural "$S" "$t1" 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -qF 'target-only genesis anchor: .tad/migrations/genesis.yaml'; then
    pass structural-genesis "target-only genesis.yaml: exit 0 with the info line"
  else fail structural-genesis "rc=$rc"; fi

  t2="$T/t2"; cp -R "$t1" "$t2"; rm -f "$t2/.tad/hooks/h.sh"
  out="$(/bin/bash "$RV" structural "$S" "$t2" 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -qF 'h.sh'; then
    pass structural-omission "deleted h.sh: exit 1 naming it"
  else fail structural-omission "rc=$rc"; fi

  t3="$T/t3"; cp -R "$t1" "$t3"; printf 'o: 1\n' > "$t3/.tad/migrations/other.yaml"
  out="$(/bin/bash "$RV" structural "$S" "$t3" 2>&1)"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -qF 'other.yaml'; then
    pass structural-other "target-only other.yaml in migrations: exit 1 naming it"
  else fail structural-other "rc=$rc"; fi
}

case "$which_case" in
  notes) notes_cases ;;
  structural) structural_cases ;;
  all) notes_cases; structural_cases ;;
esac

case "$T" in */rvfx.*) rm -rf "$T" ;; esac

if [ "$k" -eq 0 ]; then echo "RELEASE-VERIFY-FIXTURE: PASS $n/$n"; exit 0; fi
echo "RELEASE-VERIFY-FIXTURE: FAIL $k/$n"; exit 1
