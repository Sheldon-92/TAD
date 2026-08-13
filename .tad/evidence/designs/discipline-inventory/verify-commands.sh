# Phase 1b 本单敲过的 shell 命令清单（AC9 V7 扫描对象）
# 说明：本单所有含 sort/uniq 的命令均带 LC_ALL=C 前缀。

# Step 0 记录起点
git -C "$R" diff --name-only "$T0"
md5 -q "$R/.tad/active/handoffs/HANDOFF-20260812-discipline-inventory-columns.md" > "$D/contract-t0.md5"
: > "$D/verify-commands.sh"

# Step 1 推导封存
md5 -q "$D/derivation-t1.md" > "$D/derivation-t1.md5"

# Step 2/3 防线关系封存 + 源文件移出
md5 -q "$D/defense-graph-blake.md" > "$D/graph-blake-pre-review.md5"
cp "$D/discipline-provenance.md" "$TMP/formB.md"

# §6.3 抽取 costs.md（只含 行号+纪律+成本 三列）
/usr/bin/python3 - "$D/discipline-inventory.md" "$TMP/costs.md" <<'PY'
import sys
ls=[l for l in open(sys.argv[1],encoding='utf-8').read().splitlines() if l.startswith('|')]
h=[c.strip() for c in ls[0].strip().strip('|').split('|')]
i,j=h.index('纪律'),h.index('成本')
out=["| 行号 | 纪律 | 成本 |","|---|---|---|"]
for n,l in enumerate(ls[2:],1):
    c=[x.strip() for x in l.strip().strip('|').split('|')]
    out.append(f"| D{n:02d} | {c[i]} | {c[j]} |")
open(sys.argv[2],'w',encoding='utf-8').write("\n".join(out)+"\n")
PY

# 新子命令
/usr/bin/python3 "$D/verify.py" severity
/usr/bin/python3 "$D/verify.py" criterion
/usr/bin/python3 "$D/verify.py" cost-tier
/usr/bin/python3 "$D/verify.py" graph
/usr/bin/python3 "$D/verify.py" falsifier
/usr/bin/python3 "$D/verify.py" blindspot-1b

# AC11 零改动围栏（sort 带 LC_ALL=C）
{ git -C "$R" diff --name-only "$T0" -- .; git -C "$R" ls-files --others --exclude-standard; } | LC_ALL=C sort -u | command grep -E "$F" > "$TMP/fence-now.txt"
