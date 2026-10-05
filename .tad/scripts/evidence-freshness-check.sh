#!/usr/bin/env bash
# evidence-freshness-check.sh — 证据新鲜度看守（载体裁定二参数；本链 Phase 5 / C5）
# 自包含复算四锚（与 S1 summary 复跑序列同口径），读分支尖龄，按阈值判定，
# 向 evidence-freshness-log.md 追加一行；超阈值 stdout 明示 ALARM 且退出码非零。
set -u
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT" || exit 1
LOG=".tad/evidence/pm/evidence-freshness-log.md"
BRANCH="maintainer-evidence"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
find .tad/evidence .tad/archive -type f -print0 > "$TMP/A0.bin"
git ls-tree -r -z "$BRANCH" > "$TMP/B0.bin"

ANCHORS="$(PYTHONDONTWRITEBYTECODE=1 A_BIN="$TMP/A0.bin" B_BIN="$TMP/B0.bin" python3 - <<'EOF'
import subprocess, collections, os
A=[p.decode('utf-8') for p in open(os.environ['A_BIN'],'rb').read().split(b'\0') if p]
EXCL={'.tad/evidence/research/maintainer-evidence-revival/inventory-manifest.jsonl',
      '.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md'}
raw=open(os.environ['B_BIN'],'rb').read().split(b'\0')
gitlinks=[]
B={}
for e in raw:
    if not e: continue
    meta,pb=e.split(b'\t',1); mode,typ,sha=meta.decode().split(' '); p=pb.decode('utf-8')
    if mode=='160000': gitlinks.append(p.rstrip('/')+'/')
    if typ=='blob' and p.startswith(('.tad/evidence/','.tad/archive/')): B[p]=sha
def embedded(p):
    if '.git' in p.split('/'): return True
    return any(p.startswith(g) for g in gitlinks)
A=[p for p in A if p not in EXCL and not embedded(p)]
As,Bs=set(A),set(B); inter=sorted(As&Bs); c=collections.Counter()
for i in range(0,len(inter),400):
    ch=inter[i:i+400]
    out=subprocess.run(['git','hash-object','--']+ch,capture_output=True).stdout.decode().split()
    for p,s in zip(ch,out): c['carried' if s==B[p] else 'stale-content']+=1
print('TOTAL_NOCARRIER=%d'%(len(As-Bs))); print('TOTAL_STALE=%d'%c['stale-content'])
print('TOTAL_CARRIED=%d'%c['carried']); print('TOTAL_BRANCH_ONLY=%d'%(len(Bs-As)))
EOF
)" || { echo "anchor recompute failed" >&2; exit 1; }

NOCARRIER="$(printf '%s\n' "$ANCHORS" | sed -n 's/^TOTAL_NOCARRIER=//p')"
STALE="$(printf '%s\n' "$ANCHORS" | sed -n 's/^TOTAL_STALE=//p')"
CARRIED="$(printf '%s\n' "$ANCHORS" | sed -n 's/^TOTAL_CARRIED=//p')"
BRANCH_ONLY="$(printf '%s\n' "$ANCHORS" | sed -n 's/^TOTAL_BRANCH_ONLY=//p')"

TIP_EPOCH="$(git log -1 --format=%ct "$BRANCH")"
NOW_EPOCH="$(date +%s)"
TIP_AGE_DAYS=$(( (NOW_EPOCH - TIP_EPOCH) / 86400 ))
TIP_SHA="$(git rev-parse "$BRANCH")"

VERDICT="OK"
if [ "$NOCARRIER" -gt 100 ] || [ "$TIP_AGE_DAYS" -gt 21 ]; then
  VERDICT="ALARM"
fi

TS="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
LINE="$TS NOCARRIER=$NOCARRIER STALE=$STALE CARRIED=$CARRIED BRANCH_ONLY=$BRANCH_ONLY TIP_AGE_DAYS=$TIP_AGE_DAYS TIP=$TIP_SHA VERDICT=$VERDICT"
echo "$LINE" >> "$LOG"
echo "$LINE"
if [ "$VERDICT" = "ALARM" ]; then
  echo "ALARM evidence-freshness: NOCARRIER=$NOCARRIER TIP_AGE_DAYS=$TIP_AGE_DAYS"
  exit 2
fi
exit 0
