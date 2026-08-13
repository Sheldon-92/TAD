#!/usr/bin/env bash
# pfail-calc.sh — Deterministic orchestration arithmetic for the agent-orchestration pack.
#
# Delegates the pack's load-bearing math to code instead of "punting to Claude"
# (Anthropic best-practice S1: deterministic ops belong in scripts, no voodoo constants).
#
# Computes three closed-form quantities the pack reasons about:
#   1. Complexity-Cliff cumulative failure   P(fail) = 1 - (1 - p)^s
#   2. Swarm directed-handoff failure surface  pathways = n(n - 1)   (SUP3)
#   3. Durability trigger band from P(fail)   (0 / 2 / 5 step buckets -> verdict)
#
# Usage:
#   bash scripts/pfail-calc.sh pfail   <s> [p]      # cumulative failure prob (p default 0.01)
#   bash scripts/pfail-calc.sh swarm   <n>          # directed handoff pathways for n peers
#   bash scripts/pfail-calc.sh trigger <s> [p]      # durability verdict for s steps at p
#   bash scripts/pfail-calc.sh selftest             # run the pack's anchor assertions
#
# Anchors (must reproduce the numbers cited in SKILL.md / references):
#   pfail 100 0.01 -> 63.4%   |  pfail 500 0.01 -> 99.3%   |  pfail 50 0.01 -> ~39.5%
#   swarm 4 -> 12  |  swarm 10 -> 90
#
# Output: human-readable line(s); exit 0 on success, 1 on bad usage, 2 on selftest failure.

set -euo pipefail

# ── Dependency preflight ─────────────────────────────────────────────────────
if ! command -v awk >/dev/null 2>&1; then
  echo "✗ awk not available" >&2
  exit 1
fi

usage() {
  cat >&2 <<'EOF'
Usage:
  pfail-calc.sh pfail   <steps> [p]      cumulative P(fail) = 1 - (1-p)^steps   (p default 0.01)
  pfail-calc.sh swarm   <agents>         directed handoff pathways = n(n-1)
  pfail-calc.sh trigger <steps> [p]      durability verdict band for steps at p
  pfail-calc.sh selftest                 verify anchor numbers cited in the pack
EOF
}

is_int()  { case "$1" in (''|*[!0-9]*) return 1;; (*) return 0;; esac; }
is_prob() { awk -v x="$1" 'BEGIN { if (x ~ /^[0-9]*\.?[0-9]+$/ && x+0 >= 0 && x+0 <= 1) exit 0; else exit 1 }'; }

# pfail STEPS P -> prints the percentage (one decimal) on stdout, no trailing text.
calc_pfail() {
  local s="$1" p="$2"
  awk -v s="$s" -v p="$p" 'BEGIN { printf "%.1f", (1 - (1 - p)^s) * 100 }'
}

# swarm N -> prints n(n-1) on stdout.
calc_swarm() {
  local n="$1"
  awk -v n="$n" 'BEGIN { printf "%d", n * (n - 1) }'
}

cmd_pfail() {
  local s="${1:-}" p="${2:-0.01}"
  if ! is_int "$s" || ! is_prob "$p"; then usage; exit 1; fi
  local pct; pct="$(calc_pfail "$s" "$p")"
  echo "P(fail) = 1 - (1 - ${p})^${s} = ${pct}%"
}

cmd_swarm() {
  local n="${1:-}"
  if ! is_int "$n"; then usage; exit 1; fi
  local pathways; pathways="$(calc_swarm "$n")"
  echo "Swarm directed handoff pathways (SUP3) = n(n-1) = ${n}(${n}-1) = ${pathways}"
}

# trigger: map P(fail) to the pack's 0/2/5-step durability bands.
#   < 10%  -> band 0: bare retry acceptable
#   10-40% -> band 2: add application-level checkpointing
#   >= 40% -> band 5: durable / event-sourced execution MANDATORY (above the cliff)
cmd_trigger() {
  local s="${1:-}" p="${2:-0.01}"
  if ! is_int "$s" || ! is_prob "$p"; then usage; exit 1; fi
  local pct; pct="$(calc_pfail "$s" "$p")"
  local band verdict
  band="$(awk -v v="$pct" 'BEGIN { if (v < 10) print 0; else if (v < 40) print 2; else print 5 }')"
  case "$band" in
    0) verdict="band 0 — bare retry acceptable (P(fail) < 10%)";;
    2) verdict="band 2 — add application-level checkpointing (10% <= P(fail) < 40%)";;
    5) verdict="band 5 — DURABLE / event-sourced execution MANDATORY (P(fail) >= 40%, above the cliff)";;
  esac
  echo "steps=${s} p=${p} -> P(fail)=${pct}% -> ${verdict}"
}

cmd_selftest() {
  local fails=0
  check() { # check <label> <got> <want>
    if [ "$2" = "$3" ]; then echo "  ✓ $1 = $2"; else echo "  ✗ $1: got $2, want $3"; fails=$((fails + 1)); fi
  }
  echo "=== pfail-calc selftest (pack anchor numbers) ==="
  check "pfail 100 0.01" "$(calc_pfail 100 0.01)" "63.4"
  check "pfail 500 0.01" "$(calc_pfail 500 0.01)" "99.3"
  check "pfail 50 0.01"  "$(calc_pfail 50 0.01)"  "39.5"
  check "swarm 4"        "$(calc_swarm 4)"        "12"
  check "swarm 10"       "$(calc_swarm 10)"       "90"
  if [ "$fails" -eq 0 ]; then
    echo "ALL ANCHORS PASS"
    return 0
  fi
  echo "SELFTEST FAILED: $fails mismatch(es)" >&2
  return 2
}

main() {
  local sub="${1:-}"
  shift || true
  case "$sub" in
    pfail)    cmd_pfail "$@";;
    swarm)    cmd_swarm "$@";;
    trigger)  cmd_trigger "$@";;
    selftest) cmd_selftest;;
    *)        usage; exit 1;;
  esac
}

main "$@"
