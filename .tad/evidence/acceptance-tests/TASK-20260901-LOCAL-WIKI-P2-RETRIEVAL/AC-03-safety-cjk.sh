#!/usr/bin/env bash
set -euo pipefail
python3 -m unittest research.tests.test_search
echo 'AC3 PASS'
