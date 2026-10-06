#!/usr/bin/env bash
# knowledge-usage-count.sh — D35 usage log one-command recount.
#
# Source of the rule: .tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md §20 —
# key items are Gate verdicts / design artifacts / COMPLETIONs / PM rulings;
# the direct-read re-review triggers when the log reaches 50 lines AND any key
# item is cited across >= 5 distinct chains.
# Load point: PM periodic review invokes this script manually against
# .tad/evidence/knowledge-usage-log.jsonl (default path; an explicit log path
# may be passed as $1 for fixture checks).
#
# Key-item classification (priority order, path-based; templates never count):
#   1. PM ruling   : under .tad/evidence/pm/ and basename contains "ruling"
#   2. COMPLETION  : basename contains "COMPLETION"
#   3. Gate verdict: path contains /reviews/, or basename contains "verdict"/"critic"
#   4. Design      : path contains /designs/, or basename starts "HANDOFF-",
#                    or basename contains "decision-brief"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="${1:-$SCRIPT_DIR/../evidence/knowledge-usage-log.jsonl}"

python3 - "$LOG" <<'PYEOF'
import json, sys, collections, os

path = sys.argv[1]
rows = []
with open(path, encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if line:
            rows.append(json.loads(line))

total = len(rows)
usage = [r for r in rows if r.get('type') != 'genesis']
chains_all = {r.get('chain') for r in usage if r.get('chain')}

mentions = collections.Counter()
item_chains = collections.defaultdict(set)
for r in usage:
    for k in r.get('knowledge', []):
        mentions[k] += 1
        item_chains[k].add(r.get('chain'))

def classify(p):
    base = os.path.basename(p)
    if '/templates/' in p:
        return None
    if p.startswith('.tad/evidence/pm/') and 'ruling' in base:
        return 'pm-ruling'
    if 'COMPLETION' in base:
        return 'completion'
    if '/reviews/' in p or 'verdict' in base or 'critic' in base:
        return 'gate-verdict'
    if '/designs/' in p or base.startswith('HANDOFF-') or 'decision-brief' in base:
        return 'design'
    return None

key = collections.defaultdict(list)
for item in mentions:
    cls = classify(item)
    if cls:
        key[cls].append(item)

global_max = max((len(item_chains[k]) for k in mentions), default=0)
key_max = 0
for items in key.values():
    for item in items:
        key_max = max(key_max, len(item_chains[item]))

print(f'log: {path}')
print(f'total lines: {total}')
print(f'usage lines: {len(usage)}')
print(f'chains: {len(chains_all)}')
print(f'distinct knowledge items: {len(mentions)}')
print('per-item (mentions / chains):')
for item, c in mentions.most_common():
    print(f'  {c} / {len(item_chains[item])}  {item}')
print('key items by class:')
for cls in ('gate-verdict', 'design', 'completion', 'pm-ruling'):
    items = key.get(cls, [])
    print(f'  {cls}: {len(items)}')
    for item in sorted(items):
        print(f'    {mentions[item]} / {len(item_chains[item])}  {item}')
met = total >= 50 and key_max >= 5
verdict = 'MET' if met else 'NOT MET'
print(f'TRIGGER: {verdict} (lines {total}/50, max cross-chain {global_max}/5)')
print(f'  basis: key-item max cross-chain {key_max}/5; global max cross-chain {global_max}/5')
PYEOF
