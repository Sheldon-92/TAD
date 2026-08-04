#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

fail=0
acceptance=".claude/skills/alex/references/acceptance-protocol.md"
config=".tad/config-agents.yaml"
readme=".tad/eval/judge/README.md"

if [ "$(grep -F -c -e "Spawn fresh Sonnet judge" "$acceptance" || true)" -ne 0 ]; then
  echo "FAIL AC10a: legacy Sonnet judge wording remains"
  fail=1
fi
if [ "$(grep -F -c -e "uncalibrated-judge" "$acceptance" || true)" -ne 1 ]; then
  echo "FAIL AC10a: acceptance protocol uncalibrated-judge marker count is not 1"
  fail=1
fi
if ! grep -Fq -e "NEVER provide golden set" "$acceptance"; then
  echo "FAIL AC10a: paths-only golden-set safety wording was lost"
  fail=1
fi

if [ "$(grep -F -c -e "teammate_model: \"sonnet\"" "$config" || true)" -ne 1 ]; then
  echo "FAIL AC10b: teammate_model value changed or disappeared"
  fail=1
fi
if [ "$(grep -F -c -e "capability-tier: mid" "$config" || true)" -ne 1 ]; then
  echo "FAIL AC10b: capability-tier mid comment missing"
  fail=1
fi
if [ "$(grep -F -c -e "# Teammates use Sonnet" "$config" || true)" -ne 0 ]; then
  echo "FAIL AC10b: legacy Teammates use Sonnet comment remains"
  fail=1
fi

if [ "$(grep -F -c -e "uncalibrated-judge" "$readme" || true)" -ne 1 ]; then
  echo "FAIL AC10c: evaluator README uncalibrated-judge marker count is not 1"
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "AC10 PASS: judge calibration is expressed as a capability tier with uncalibrated advisory marking"
