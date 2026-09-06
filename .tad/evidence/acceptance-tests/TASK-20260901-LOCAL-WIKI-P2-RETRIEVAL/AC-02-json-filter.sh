#!/usr/bin/env bash
set -euo pipefail
python3 research/scripts/search.py query "agent memory vector database" --scope raw --json | python3 -c '
import json, math, sys
p=json.load(sys.stdin); r=p["results"]; assert r
required={"path","layer","heading","start_line","end_line","snippet","score"}
assert all(set(x)==required and x["layer"]=="raw" and math.isfinite(x["score"]) and x["start_line"]>=1 and x["end_line"]>=x["start_line"] for x in r)
'
echo 'AC2 PASS'
