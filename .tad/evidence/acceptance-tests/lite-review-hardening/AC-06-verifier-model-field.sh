#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 1
n=$(grep -A3 'required_fields=' .tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh | grep -c '\bmodel\b' || true)
[ "$n" -ge 1 ] || { echo "FAIL: required_fields model count=$n"; exit 1; }
echo 'PASS: AC6 verifier required_fields includes model'
