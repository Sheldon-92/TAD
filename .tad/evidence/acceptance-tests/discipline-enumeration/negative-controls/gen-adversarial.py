#!/usr/bin/env python3
# Generate AC9 adversarial disposition tables (negative-controls/) from frozen inputs.
# Each table is realistic in every column EXCEPT the single dimension the claimed
# guard is supposed to catch, so the interception point stays unambiguous.
import sys, subprocess, re
import subprocess as _sp
R = _sp.run(["git","rev-parse","--show-toplevel"],capture_output=True,text=True).stdout.strip()
EV = f"{R}/.tad/evidence/acceptance-tests/discipline-enumeration"
NC = f"{EV}/negative-controls"
WIDE = open(f"{EV}/wide-markers.txt", encoding="utf-8").read().rstrip("\n")
marker_re = re.compile(r"(?i)(?:" + WIDE + r")")

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, encoding="utf-8").stdout

def block_text(f, s, e):
    return run(f'sed -n "{s},{e}p" "{R}/{f}"')

blocks = [l.rstrip("\n").split("\t") for l in open(f"{EV}/blocks.txt", encoding="utf-8")]
ranges = [l.rstrip("\n").split("\t") for l in open(f"{EV}/ranges.txt", encoding="utf-8")]
hits = [l.rstrip("\n").split("\t") for l in open(f"{EV}/hits.tsv", encoding="utf-8")]
subkeys = {}
for l in open(f"{EV}/subkeys.tsv", encoding="utf-8"):
    f, s, k = l.rstrip("\n").split("\t")
    subkeys.setdefault((f, s), []).append(k)

def sentence_for(f, s, e):
    text = block_text(f, s, e).split("\n")
    # prefer a line that hits the wide markers (satisfies AC4(b)); else first non-empty
    for ln in text:
        if marker_re.search(ln) and len(ln) >= 12:
            return ln.strip()[:80]
    for ln in text:
        if len(ln.strip()) >= 12:
            return ln.strip()[:80]
    return text[0].strip()[:40] if text else "-"

def skey_list(f, s):
    return ",".join(dict.fromkeys(subkeys.get((f, s), []))) or "-"

def base_rows():
    out = []
    for i in range(60):
        f, s, e = ranges[i]
        out.append([blocks[i][0], blocks[i][1], blocks[i][2],
                    "", "", sentence_for(f, s, e), hits[i][2], skey_list(f, s)])
    return out

# (a) all 非纪律 — AC11 must catch (adopted candidate without matching 新增)
rows = base_rows()
codes = ["R1", "R2", "R3", "R4", "R5"]
for i, r in enumerate(rows):
    r[3] = "非纪律"; r[4] = codes[i % 5]
open(f"{NC}/all-ondiscipline.tsv", "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")

# (b) all 已有:需求澄清 — AC10 must catch (>24 rows on one discipline)
rows = base_rows()
for r in rows:
    r[3] = "已有:需求澄清"; r[4] = ""
open(f"{NC}/all-existing.tsv", "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")

# (c) all 新增 — AC4 must catch (hits=0 blocks lack the 零标记 reason marker)
rows = base_rows()
for i, r in enumerate(rows):
    r[3] = f"新增:伪造纪律{i+1}"; r[4] = ""
open(f"{NC}/all-new.tsv", "w", encoding="utf-8").write("\n".join("\t".join(r) for r in rows) + "\n")
print("generated 3 adversarial tables")
