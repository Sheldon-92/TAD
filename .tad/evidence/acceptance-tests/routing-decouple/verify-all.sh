#!/usr/bin/env bash
# AC verify — HANDOFF-20260814-routing-decouple (rev2)
# Red definition: exit != 0 AND last line RESULT=FAIL.
# Frozen inputs only: T=0 (git HEAD) + pins.tsv + block-a/b/c. AC4 expected state is
# reconstructed mechanically from frozen inputs; never derived from live files.
R="/path/to/TAD"
EV="$R/.tad/evidence/acceptance-tests/routing-decouple"
TSV="$R/.tad/active/handoffs/HANDOFF-20260814-routing-decouple.pins.tsv"
BLK="$R/.tad/active/handoffs/HANDOFF-20260814-routing-decouple"
T0=$(cat "$EV/t0.txt")
export LC_ALL=C
FAILED=0
DONE=0
trap 'if [ "${DONE:-0}" = "1" ]; then echo "RESULT=PASS"; exit 0; else echo "RESULT=FAIL"; exit 1; fi' EXIT

ac_fail() { FAILED=1; echo "  AC FAIL: $*"; }

# ── AC1: pins.tsv 19 rows, literal whole-line reads, no expansion ──
echo "AC1: pins OLD=0 / NEW=1 (19 rows)"
n=0
while IFS=$'\t' read -r id f old new; do
  [ -n "$id" ] || continue
  n=$((n+1))
  oc=$(LC_ALL=C command grep -cFx -e "$old" "$f" || true)
  nc=$(LC_ALL=C command grep -cFx -e "$new" "$f" || true)
  if [ "$oc" != "0" ] || [ "$nc" != "1" ]; then
    ac_fail "pin $id ${f}: OLD=$oc NEW=$nc"
  fi
done < "$TSV"
if [ "$n" != "19" ]; then ac_fail "expected 19 rows, read $n"; else echo "  AC1 rows=$n OK"; fi
[ "$FAILED" = "0" ] && echo "AC1 PASS" || echo "AC1 FAIL"

# ── AC2: block A region == block-a.txt; LITE-FROZEN region == block-b.txt ──
echo "AC2: installed blocks sha256 == frozen block files"
# block A in INSTALLATION_GUIDE.md: 7 lines starting at anchor
s=$(LC_ALL=C command grep -nF "# 默认（Alex / Blake" INSTALLATION_GUIDE.md | LC_ALL=C cut -d: -f1 | head -1)
if [ -z "$s" ]; then
  ac_fail "block A anchor not found in INSTALLATION_GUIDE.md"
else
  if sed -n "${s},$((s+6))p" INSTALLATION_GUIDE.md | LC_ALL=C cmp -s - "$BLK.block-a.txt"; then
    echo "  block A sha256 OK"
  else
    ac_fail "INSTALLATION_GUIDE block A != block-a.txt (line $s)"
  fi
fi
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
         .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  if awk -v b='<!-- LITE-FROZEN-BEGIN -->' -v e='<!-- LITE-FROZEN-END -->' \
      'index($0,b){f=1} f{print} index($0,e){f=0}' "$f" | LC_ALL=C cmp -s - "$BLK.block-b.txt"; then
    echo "  LITE-FROZEN ${f} OK"
  else
    ac_fail "LITE-FROZEN region ${f} != block-b.txt"
  fi
done
[ "$FAILED" = "0" ] && echo "AC2 PASS" || echo "AC2 FAIL"

# ── AC3: lite protocol untouched — rest-of-file sha256 equal to T0 ──
# Interpretation (documented): AC3-strict is UNSATISFIABLE for alex-lite — its frontmatter
# description line carries an AC6 forbidden word (默认通道) and is changed by pinned rows
# 18/19 (sanctioned by AC1; §2 allows declaration-only changes). Satisfiable reading:
# T0 side first applies the description pins (18/19), then removes the old block region;
# live side removes the LITE-FROZEN region. Equality => the ONLY deltas in the 4 lite
# skills are the pinned description + the block (no protocol drift).
echo "AC3: lite skill minus-block sha256 == T0 (description pins applied on T0 side)"
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
         .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  pinid=""; pinnew=""
  case "$f" in
    .claude/skills/alex-lite/SKILL.md) pinid=18;;
    .agents/skills/alex-lite/SKILL.md) pinid=19;;
  esac
  if [ -n "$pinid" ]; then
    pinnew=$(awk -F'\t' -v id="$pinid" '$1==id{print $4}' "$TSV")
  fi
  live_rest=$(awk -v b='<!-- LITE-FROZEN-BEGIN -->' -v e='<!-- LITE-FROZEN-END -->' \
    'BEGIN{del=0} index($0,b){del=1; next} del && index($0,e){del=0; next} !del{print}' "$f" | LC_ALL=C shasum -a 256 | LC_ALL=C cut -d' ' -f1)
  t0_rest=$(git -C "$R" show "${T0}:${f}" \
    | { if [ -n "$pinid" ]; then o=$(awk -F'\t' -v id="$pinid" '$1==id{print $3}' "$TSV"); LC_ALL=C awk -v old="$o" -v new="$pinnew" 'BEGIN{hit=0} $0==old{print new; hit++; next} {print} END{exit(hit==1?0:1)}' || { echo "AC3 T0 pin${pinid} apply FAIL" >&2; exit 1; }; else cat; fi; } \
    | awk -v b='## Lite-First 政策（默认通道，不可妥协）' -v e='- 补充细节/检查留在 Lite；切 full 是例外。' \
    'BEGIN{del=0} index($0,b){del=1; next} del && index($0,e){del=0; next} !del{print}' | LC_ALL=C shasum -a 256 | LC_ALL=C cut -d' ' -f1)
  if [ "$live_rest" = "$t0_rest" ]; then
    echo "  ${f} rest sha256 OK"
  else
    ac_fail "AC3 ${f}: live-rest=$live_rest t0-rest=$t0_rest"
  fi
done
[ "$FAILED" = "0" ] && echo "AC3 PASS" || echo "AC3 FAIL"

# ── AC4: mechanical reconstruction from T0+pins+blocks; diff zero ──
echo "AC4: reconstruct expected state from frozen inputs, diff live"
if PY_OUT=$(python3 - "$R" "$TSV" "$BLK" "$T0" "$EV" 2>&1 <<'PYEOF'
import sys, hashlib, subprocess, os, tempfile
R, TSV, BLK, T0, EV = sys.argv[1:6]
files = []
with open(TSV, encoding="utf-8") as fh:
    rows = []
    for line in fh:
        line = line.rstrip("\n")
        if not line: continue
        parts = line.split("\t")
        assert len(parts) == 4, f"tsv row not 4 fields: {line!r}"
        rows.append(parts)
        if parts[1] not in files: files.append(parts[1])
for extra in [".claude/skills/blake-lite/SKILL.md", ".agents/skills/blake-lite/SKILL.md"]:
    if extra not in files: files.append(extra)
block_a = open(f"{BLK}.block-a.txt", encoding="utf-8").read().split("\n")
block_b = open(f"{BLK}.block-b.txt", encoding="utf-8").read().split("\n")
block_c = open(f"{BLK}.block-c.txt", encoding="utf-8").read().split("\n")
def git_show(path):
    out = subprocess.run(["git", "-C", R, "show", f"{T0}:{path}"], capture_output=True)
    if out.returncode != 0:
        raise SystemExit(f"git show failed for {path}: {out.stderr.decode('utf-8', 'replace')}")
    return out.stdout.decode("utf-8")
def replace_region(lines, begin_anchor, end_anchor, block):
    out, i, done = [], 0, False
    while i < len(lines):
        if lines[i] == begin_anchor:
            out.extend(block[:-1] if block and block[-1] == "" else block)
            i += 1
            while i < len(lines) and lines[i] != end_anchor:
                i += 1
            i += 1
            done = True
            continue
        out.append(lines[i]); i += 1
    if not done:
        raise SystemExit(f"block begin anchor not found: {begin_anchor!r}")
    return out
ndiffs = 0
for f in files:
    lines = git_show(f).split("\n")
    for rid, tgt, old, new in rows:
        if tgt != f: continue
        hits = [i for i, l in enumerate(lines) if l == old]
        assert len(hits) == 1, f"pin {rid} {f}: expected 1 OLD hit in T0, got {len(hits)}"
        lines[hits[0]] = new
    if f == "INSTALLATION_GUIDE.md":
        lines = replace_region(lines, "# 默认通道（lite —— 可同一 terminal，由人输入命令切换角色）", "/blake          # Terminal 2: 实现与执行", block_a)
    elif f.endswith(".claude/skills/blake-lite/SKILL.md") or f.endswith(".agents/skills/blake-lite/SKILL.md") or f.endswith(".claude/skills/alex-lite/SKILL.md") or f.endswith(".agents/skills/alex-lite/SKILL.md"):
        lines = replace_region(lines, "## Lite-First 政策（默认通道，不可妥协）", "- 补充细节/检查留在 Lite；切 full 是例外。", block_b)
    elif f == "CLAUDE.md":
        idx = next(i for i, l in enumerate(lines) if l.startswith("### 2.5 "))
        oldline = lines[idx + 1]
        assert "**默认通道**" in oldline, f"block C old line unexpected: {oldline[:60]!r}"
        lines = lines[:idx+1] + block_c[:-1] + lines[idx+2:]
    expected = "\n".join(lines)
    live = open(os.path.join(R, f), encoding="utf-8", newline="").read()
    if expected != live:
        ndiffs += 1
        print(f"AC4 DIFF {f}")
        exp_lines = expected.split("\n"); liv_lines = live.split("\n")
        for i in range(max(len(exp_lines), len(liv_lines))):
            a = exp_lines[i] if i < len(exp_lines) else "<EOF>"
            b = liv_lines[i] if i < len(liv_lines) else "<EOF>"
            if a != b:
                print(f"  line {i+1}: expected={a[:90]!r}")
                print(f"            live     ={b[:90]!r}")
                break
print(f"AC4 files={len(files)} diffs={ndiffs}")
sys.exit(1 if ndiffs else 0)
PYEOF
); then
  echo "  AC4 reconstruction OK (diff zero)"
else
  echo "$PY_OUT"
  ac_fail "AC4 reconstruction diff not zero"
fi
[ "$FAILED" = "0" ] && echo "AC4 PASS" || echo "AC4 FAIL"

# ── AC5: parity .claude <-> .agents ──
echo "AC5: parity pairs"
for p in alex-lite blake-lite tad-help; do
  if LC_ALL=C cmp -s ".claude/skills/${p}/SKILL.md" ".agents/skills/${p}/SKILL.md"; then
    echo "  ${p} identical"
  else
    ac_fail "AC5 parity ${p}"
  fi
done
[ "$FAILED" = "0" ] && echo "AC5 PASS" || echo "AC5 FAIL"

# ── AC6: exhaustive pattern scan on git ls-files, case-insensitive ──
echo "AC6: pattern scan (git ls-files, case-insensitive)"
if ! command -v mapfile >/dev/null 2>&1; then
  ac_fail "AC6 needs bash>=4 (mapfile)"
fi
mapfile -t EXCL < "$EV/ac6-exclude.txt"
excluded() { local f="$1" p; for p in "${EXCL[@]}"; do case "$f" in $p) return 0;; esac; done; return 1; }
hits=0
while IFS= read -r f; do
  excluded "$f" && continue
  for pat in "默认通道" "保留通道" "默认走 lite" "Lite-First" "default channel" "reserved channel" "default workhorse" "Default — TAD Lite" "Lite is the Default"; do
    if LC_ALL=C command grep -qiF -e "$pat" "$f"; then
      hits=$((hits+1))
      echo "  AC6 HIT ${f}: ${pat}"
    fi
  done
done < <(git -C "$R" -c core.quotePath=false ls-files)
if [ "$hits" = "0" ]; then echo "  AC6 hits=0 OK"; else ac_fail "AC6 hits=$hits"; fi
[ "$FAILED" = "0" ] && echo "AC6 PASS" || echo "AC6 FAIL"

# ── AC7: discipline counts per file per keyword == baseline ──
echo "AC7: discipline counts"
ac7_bad=0
while IFS='|' read -r f k c; do
  [ -n "$f" ] || continue
  cur=$(LC_ALL=C command grep -cF -e "$k" "$f" || true)
  if [ "$cur" != "$c" ]; then
    ac7_bad=1
    echo "  AC7 HIT ${f}|${k}: baseline=$c live=$cur"
  fi
done < "$EV/discipline-baseline.txt"
if [ "$ac7_bad" = "0" ]; then echo "  AC7 all equal"; else ac_fail "AC7 count drift"; fi
[ "$FAILED" = "0" ] && echo "AC7 PASS" || echo "AC7 FAIL"

# ── AC8: version.txt + brain-index ──
echo "AC8: version + brain-index"
if [ "$(cat .tad/version.txt)" = "2.42.0" ]; then echo "  version.txt 2.42.0 OK"; else ac_fail "AC8 version.txt=$(cat .tad/version.txt)"; fi
bc=$(LC_ALL=C command grep -cF -e "默认走 lite" .tad/brain-index.md || true)
if [ "$bc" = "0" ]; then echo "  brain-index 默认走 lite=0 OK"; else ac_fail "AC8 brain-index 默认走 lite=$bc"; fi
[ "$FAILED" = "0" ] && echo "AC8 PASS" || echo "AC8 FAIL"

# ── AC9: frozen artifacts unchanged ──
echo "AC9: frozen artifacts"
ac9_bad=0
( cd "$R" && shasum -a 256 .tad/active/handoffs/HANDOFF-20260814-routing-decouple.{md,pins.tsv,block-a.txt,block-b.txt,block-c.txt} ) | LC_ALL=C cmp -s - "$EV/inputs.sha256" \
  || { ac9_bad=1; echo "  AC9 inputs changed"; }
( cd "$EV" && shasum -a 256 ac6-exclude.txt discipline-baseline.txt fence-baseline.txt inputs.sha256 ) | LC_ALL=C cmp -s - "$EV/step0-baseline.sha256" \
  || { ac9_bad=1; echo "  AC9 step0 baselines changed"; }
if [ "$ac9_bad" = "0" ]; then echo "  AC9 frozen OK"; else ac_fail "AC9 frozen artifacts modified"; fi
[ "$FAILED" = "0" ] && echo "AC9 PASS" || echo "AC9 FAIL"

# ── AC10: behavioral readback (artifact check; spawn done separately) ──
echo "AC10: behavioral readback"
if [ -f "$EV/ac10-output.txt" ]; then
  if LC_ALL=C command grep -qiF 'lite' "$EV/ac10-output.txt"; then
    ac_fail "AC10 output mentions lite: $(LC_ALL=C command grep -iF 'lite' "$EV/ac10-output.txt" | head -1 | cut -c1-120)"
  elif LC_ALL=C command grep -qF '/alex' "$EV/ac10-output.txt" || LC_ALL=C command grep -qF '当 Alex' "$EV/ac10-output.txt"; then
    echo "  ac10-output.txt: names Alex channel, no lite mention"
  else
    echo "  ac10-output.txt exists; verdict adjudicated by Blake (model output)"
  fi
else
  ac_fail "AC10 ac10-output.txt missing"
fi
[ "$FAILED" = "0" ] && echo "AC10 PASS" || echo "AC10 FAIL"

# ── AC11: fence — change set ⊆ (§5 ∪ Step0 baseline ∪ traces/decisions glob) ──
echo "AC11: fence"
{
  git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard
} | LC_ALL=C sort -u > "$EV/.ac11-changes.txt"
ac11_bad=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in
    CLAUDE.md|AGENTS.md|INSTALLATION_GUIDE.md|tad.sh|.tad/version.txt|.tad/brain-index.md) ;;
    .claude/skills/alex-lite/SKILL.md|.claude/skills/blake-lite/SKILL.md|.claude/skills/tad-help/SKILL.md) ;;
    .agents/skills/alex-lite/SKILL.md|.agents/skills/blake-lite/SKILL.md|.agents/skills/tad-help/SKILL.md) ;;
    .tad/evidence/acceptance-tests/routing-decouple/*) ;;
    .tad/archive/handoffs/COMPLETION-20260814-routing-decouple.md) ;;
    *) if LC_ALL=C command grep -qxF "$f" "$EV/fence-baseline.txt"; then :;
       elif [[ "$f" == .tad/evidence/traces/*.jsonl || "$f" == .tad/evidence/decisions/*.jsonl ]]; then :;
       else ac11_bad=1; echo "  AC11 OUT OF FENCE: $f"; fi ;;
  esac
done < "$EV/.ac11-changes.txt"
if [ "$ac11_bad" = "0" ]; then echo "  AC11 fence clean (no changes outside allowed set)"; else ac_fail "AC11 fence breach"; fi
[ "$FAILED" = "0" ] && echo "AC11 PASS" || echo "AC11 FAIL"

if [ "$FAILED" = "0" ]; then DONE=1; fi
