#!/usr/bin/env bash
# AC-P1.2 — drift-check.sh 4 subchecks
# Covers: a-unit tests per subcheck, b-grouped output, c-clean PASS,
#         d-4 fixture cases, e-Supersedes advisory (not mv), f-standalone+help,
#         g-backward compat, h-false positive defense, i-portability,
#         j-supersedes real data, k-failure isolation, l-observability

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../../../" && pwd)"
SCRIPT="${REPO_ROOT}/.tad/hooks/lib/drift-check.sh"
FIXTURE_SRC="${REPO_ROOT}/.tad/evidence/completions/phase1-state-consistency/fixtures/drift"

PASS=0
FAIL=0

_pass() { printf '[PASS] %s\n' "$1"; PASS=$((PASS+1)); }
_fail() { printf '[FAIL] %s\n' "$1"; [ -n "${2:-}" ] && printf '      %s\n' "$2"; FAIL=$((FAIL+1)); }

# ── Build throwaway fixture workspace with .tad/active/handoffs + git repo ──
WS=$(mktemp -d -t drift-ws.XXXXXX)
trap 'rm -rf "$WS"' EXIT

(
  cd "$WS"
  mkdir -p .tad/active/handoffs .tad/archive/handoffs .tad/hooks/lib .tad/project-knowledge
  git init -q
  git config user.email test@tad.local
  git config user.name TestBot
  # Copy the config-workflow.yaml stub with drift_check block
  cp "${REPO_ROOT}/.tad/config-workflow.yaml" .tad/config-workflow.yaml 2>/dev/null || true
  # Create empty initial commit
  echo init > README.md
  git add README.md
  git commit -q -m "init"
)

# Helper: install a fixture handoff as HANDOFF-{date}-{slug}.md
_install_fixture() {
  local src_file="$1" dest_slug="$2" dest_date="${3:-20260401}"
  local dest="${WS}/.tad/active/handoffs/HANDOFF-${dest_date}-${dest_slug}.md"
  cp "$src_file" "$dest"
  printf '%s' "$dest"
}

_parse_status() {
  # Extract status for a given subcheck + handoff pattern from stdout JSONL
  local jsonl="$1" subcheck="$2" handoff="$3"
  printf '%s\n' "$jsonl" | jq -rc --arg sc "$subcheck" --arg ho "$handoff" \
    'select(.subcheck==$sc and .handoff==$ho) | .status' 2>/dev/null | head -1
}

# ── AC-P1.2-c: clean active/ → all OK ──
# One well-formed handoff
fx_clean="${WS}/.tad/active/handoffs/HANDOFF-20260401-clean-test.md"
cat > "$fx_clean" <<'EOF'
---
task_type: code
---
# Clean handoff

## 5. Required Evidence Manifest

```yaml
required_evidence:
  completion_report:
    path: .tad/active/handoffs/COMPLETION-20260401-clean-test.md
```
EOF

stdout=$(cd "$WS" && bash "$SCRIPT" check-all 2>/dev/null)
n_drift=$(printf '%s\n' "$stdout" | jq -r 'select(.status=="drift") | .handoff' 2>/dev/null | wc -l | tr -d ' ')
if [ "$n_drift" = "0" ]; then
  _pass "AC-P1.2-c clean active/ → 0 drift"
else
  _fail "AC-P1.2-c clean fixture produced drift" "$(printf '%s' "$stdout" | jq -c 'select(.status=="drift")')"
fi
rm -f "$fx_clean"

# ── AC-P1.2-d.1 + AC-P1.2-a (slug mismatch unit) ──
_install_fixture "${FIXTURE_SRC}/slug-mismatch.md" "phase1-state-consistency" >/dev/null
stdout=$(cd "$WS" && bash "$SCRIPT" check slug_consistency 2>/dev/null)
status=$(_parse_status "$stdout" "slug_consistency" "HANDOFF-20260401-phase1-state-consistency.md")
if [ "$status" = "drift" ]; then
  _pass "AC-P1.2-a/d slug_consistency on fixture → drift"
else
  _fail "AC-P1.2-a/d slug_consistency expected drift, got '$status'" "$stdout"
fi
rm -f "${WS}/.tad/active/handoffs/HANDOFF-20260401-phase1-state-consistency.md"

# ── AC-P1.2-d.2 + AC-P1.2-b (zombie unit) ──
# Setup: put a fake COMPLETION in archive, add a git commit mentioning the slug
cp "${FIXTURE_SRC}/zombie.md" "${WS}/.tad/active/handoffs/HANDOFF-20260401-zombie-fixture.md"
touch "${WS}/.tad/archive/handoffs/COMPLETION-20260401-zombie-fixture.md"
(
  cd "$WS"
  echo zombie > zombie-marker
  git add zombie-marker
  git commit -q -m "feat(zombie-fixture): implement zombie fixture Gate 3"
)
stdout=$(cd "$WS" && bash "$SCRIPT" check zombie_handoffs 2>/dev/null)
status=$(_parse_status "$stdout" "zombie_handoffs" "HANDOFF-20260401-zombie-fixture.md")
if [ "$status" = "drift" ]; then
  _pass "AC-P1.2-b/d zombie with commit+COMPLETION → drift"
else
  _fail "AC-P1.2-b/d zombie expected drift, got '$status'" "$stdout"
fi
rm -f "${WS}/.tad/active/handoffs/HANDOFF-20260401-zombie-fixture.md" \
      "${WS}/.tad/archive/handoffs/COMPLETION-20260401-zombie-fixture.md"

# ── AC-P1.2-h (false-positive defense: short slug "auth") ──
cp "${FIXTURE_SRC}/false-positive-short-slug.md" "${WS}/.tad/active/handoffs/HANDOFF-20260401-auth.md"
(
  cd "$WS"
  # Commits that should NOT match "auth" at word boundary
  echo x > post-auth-work.txt
  git add post-auth-work.txt
  git commit -q -m "chore: post-auth work for user flow"
  echo x > pre-auth-setup.txt
  git add pre-auth-setup.txt
  git commit -q -m "chore: pre-auth setup helper"
)
stdout=$(cd "$WS" && bash "$SCRIPT" check zombie_handoffs 2>/dev/null)
status=$(_parse_status "$stdout" "zombie_handoffs" "HANDOFF-20260401-auth.md")
# Expected: "ok" because \bauth\b doesn't match "post-auth" / "pre-auth"
if [ "$status" = "ok" ]; then
  _pass "AC-P1.2-h short slug 'auth' NOT matched by post-auth/pre-auth (word boundary works)"
else
  _fail "AC-P1.2-h short slug false-positive: status=$status" "$stdout"
fi
rm -f "${WS}/.tad/active/handoffs/HANDOFF-20260401-auth.md"

# ── AC-P1.2-d.3 + AC-P1.2-j (supersedes unit, both formats) ──
# Plain
cp "${FIXTURE_SRC}/supersedes-plain.md" "${WS}/.tad/active/handoffs/HANDOFF-20260424-supersedes-plain.md"
cp "${FIXTURE_SRC}/supersedes-plain.md" "${WS}/.tad/active/handoffs/HANDOFF-20260102-older-handoff.md"
stdout=$(cd "$WS" && bash "$SCRIPT" check supersedes_chains 2>/dev/null)
status=$(_parse_status "$stdout" "supersedes_chains" "HANDOFF-20260424-supersedes-plain.md")
if [ "$status" = "drift" ]; then
  _pass "AC-P1.2-j supersedes plain format → drift (supersedee in active/)"
else
  _fail "AC-P1.2-j supersedes plain expected drift, got '$status'" "$stdout"
fi
# Bold
cp "${FIXTURE_SRC}/supersedes-bold.md" "${WS}/.tad/active/handoffs/HANDOFF-20260424-supersedes-bold.md"
cp "${FIXTURE_SRC}/supersedes-bold.md" "${WS}/.tad/active/handoffs/HANDOFF-20260101-old-handoff.md"
stdout=$(cd "$WS" && bash "$SCRIPT" check supersedes_chains 2>/dev/null)
status=$(_parse_status "$stdout" "supersedes_chains" "HANDOFF-20260424-supersedes-bold.md")
if [ "$status" = "drift" ]; then
  _pass "AC-P1.2-j supersedes bold markdown format → drift"
else
  _fail "AC-P1.2-j supersedes bold expected drift, got '$status'" "$stdout"
fi
# AC-P1.2-e: action is advisory, not an actual mv
action=$(printf '%s\n' "$stdout" | jq -rc \
  --arg ho "HANDOFF-20260424-supersedes-bold.md" \
  'select(.subcheck=="supersedes_chains" and .handoff==$ho) | .suggested_action' 2>/dev/null | head -1)
if printf '%s' "$action" | grep -qi 'archive\|mv\|review'; then
  _pass "AC-P1.2-e supersedes action is advisory text (not auto-executed)"
else
  _fail "AC-P1.2-e expected advisory action, got '$action'"
fi
# Verify nothing actually moved
if [ -f "${WS}/.tad/active/handoffs/HANDOFF-20260101-old-handoff.md" ]; then
  _pass "AC-P1.2-e supersedee still in active/ (not auto-archived)"
else
  _fail "AC-P1.2-e supersedee was moved — this would violate report-only contract"
fi
rm -f "${WS}"/.tad/active/handoffs/HANDOFF-*.md

# ── AC-P1.2-d.4 (ghost task unit) ──
cp "${FIXTURE_SRC}/ghost.md" "${WS}/.tad/active/handoffs/HANDOFF-20260401-housekeeping-stale-cleanup.md"
stdout=$(cd "$WS" && bash "$SCRIPT" check ghost_tasks 2>/dev/null)
status=$(_parse_status "$stdout" "ghost_tasks" "HANDOFF-20260401-housekeeping-stale-cleanup.md")
if [ "$status" = "drift" ]; then
  _pass "AC-P1.2-d ghost housekeeping without grounded_state → drift"
else
  _fail "AC-P1.2-d ghost expected drift, got '$status'" "$stdout"
fi
rm -f "${WS}/.tad/active/handoffs/HANDOFF-20260401-housekeeping-stale-cleanup.md"

# ── AC-P1.2-g (backward compat: pre-manifest-era) ──
cp "${FIXTURE_SRC}/pre-manifest-era.md" "${WS}/.tad/active/handoffs/HANDOFF-20260201-legacy-handoff.md"
stdout=$(cd "$WS" && bash "$SCRIPT" check slug_consistency 2>/dev/null)
status=$(_parse_status "$stdout" "slug_consistency" "HANDOFF-20260201-legacy-handoff.md")
if [ "$status" = "info" ]; then
  _pass "AC-P1.2-g pre-manifest-era handoff → info (NOT drift)"
else
  _fail "AC-P1.2-g pre-manifest-era expected info, got '$status'"
fi
rm -f "${WS}/.tad/active/handoffs/HANDOFF-20260201-legacy-handoff.md"

# ── AC-P1.2-f (--help output + single-subcheck standalone) ──
help_out=$(bash "$SCRIPT" --help 2>&1)
if printf '%s' "$help_out" | grep -q 'drift-check.sh'; then
  _pass "AC-P1.2-f --help emits usage header"
else
  _fail "AC-P1.2-f --help missing usage"
fi
if printf '%s' "$help_out" | grep -q 'check-all'; then
  _pass "AC-P1.2-f --help mentions check-all"
else
  _fail "AC-P1.2-f --help missing check-all"
fi

# ── AC-P1.2-l (observability: stderr status lines) ──
cp "${FIXTURE_SRC}/slug-mismatch.md" "${WS}/.tad/active/handoffs/HANDOFF-20260401-phase1-state-consistency.md"
stderr_log=$(cd "$WS" && bash "$SCRIPT" check-all 2>&1 >/dev/null)
if printf '%s' "$stderr_log" | grep -qE '^\[drift-check\] slug_consistency'; then
  _pass "AC-P1.2-l observability: stderr status line present"
else
  _fail "AC-P1.2-l missing stderr status lines" "$stderr_log"
fi
rm -f "${WS}/.tad/active/handoffs/HANDOFF-20260401-phase1-state-consistency.md"

# ── AC-P1.2-i (portability: shellcheck + no grep -P, no gdate, no EPOCHREALTIME, no gensub) ──
if shellcheck -e SC2155 "$SCRIPT" >/dev/null 2>&1; then
  _pass "AC-P1.2-i shellcheck drift-check.sh PASS"
else
  _fail "AC-P1.2-i shellcheck FAILED" "$(shellcheck -e SC2155 "$SCRIPT" 2>&1 | head -5)"
fi
# Check for forbidden constructs (excluding comment lines)
# Strip shell-style `#` comments first so we only scan executable code.
forbidden=$(grep -nE 'grep -P|grep -oP|gdate|EPOCHREALTIME|gensub\(' "$SCRIPT" \
            | grep -vE '^[[:space:]]*[0-9]+:[[:space:]]*#' || true)
if [ -n "$forbidden" ]; then
  _fail "AC-P1.2-i forbidden construct found in non-comment" "$forbidden"
else
  _pass "AC-P1.2-i no grep -P / gdate / EPOCHREALTIME / awk gensub in executable lines"
fi

# ── AC-P1.2-k (failure isolation: git unavailable but other subchecks continue) ──
# Remove .git from WS temporarily
mv "${WS}/.git" "${WS}/.git.disabled"
cp "${FIXTURE_SRC}/slug-mismatch.md" "${WS}/.tad/active/handoffs/HANDOFF-20260401-phase1-state-consistency.md"
cp "${FIXTURE_SRC}/ghost.md" "${WS}/.tad/active/handoffs/HANDOFF-20260402-housekeeping-stale-cleanup.md"
stdout=$(cd "$WS" && bash "$SCRIPT" check-all 2>/dev/null)
# zombie_handoffs should emit error
zombie_err=$(printf '%s\n' "$stdout" | jq -rc \
  'select(.subcheck=="zombie_handoffs" and .status=="error") | .message' 2>/dev/null | head -1)
if [ -n "$zombie_err" ]; then
  _pass "AC-P1.2-k zombie_handoffs emits error when git unavailable"
else
  _fail "AC-P1.2-k zombie_handoffs should report error without git" "$stdout"
fi
# slug_consistency should still run
slug_ran=$(printf '%s\n' "$stdout" | jq -rc \
  'select(.subcheck=="slug_consistency") | .status' 2>/dev/null | head -1)
if [ -n "$slug_ran" ]; then
  _pass "AC-P1.2-k slug_consistency ran despite git absence (isolation)"
else
  _fail "AC-P1.2-k slug_consistency was killed by git absence"
fi
# ghost_tasks should still run
ghost_ran=$(printf '%s\n' "$stdout" | jq -rc \
  'select(.subcheck=="ghost_tasks") | .status' 2>/dev/null | head -1)
if [ -n "$ghost_ran" ]; then
  _pass "AC-P1.2-k ghost_tasks ran despite git absence (isolation)"
else
  _fail "AC-P1.2-k ghost_tasks was killed by git absence"
fi
mv "${WS}/.git.disabled" "${WS}/.git"
rm -f "${WS}"/.tad/active/handoffs/HANDOFF-*.md

printf '\n== Summary: %d passed, %d failed ==\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
