#!/usr/bin/env bash
set -euo pipefail
python3 research/scripts/search.py eval --dataset research/eval/retrieval-queries.json --json | python3 -c '
import json, sys
p=json.load(sys.stdin); assert p["passed"] and p["recall_at_5"]==1.0 and p["mrr"]>=0.75 and all("rank" in x for x in p["results"])
'
echo 'AC4 PASS'

