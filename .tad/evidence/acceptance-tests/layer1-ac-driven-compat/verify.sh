#!/bin/bash
# verify.sh — LITE-20260810-1820-layer1-ac-driven-compat AC1-AC16, AC18, AC19 verifier
# 依据：LITE-20260810-1820-layer1-ac-driven-compat.md §AC（revision 5 定稿）
# 卫生约束（AC17 由 Blake L2 自验在脚本外部执行，见 results.txt）：
#   本脚本不含进程替换语法（集合运算一律走 mktemp 中间文件）；不含非基线工具调用；定长匹配一律 grep -e + 显式 exit code。
# 兼容性：本机 /bin/bash 3.2.57（最差解析器）、/usr/bin/grep BSD 2.6.0、LC_ALL=C 排序。

set -u

PASS=0
FAIL=0
PENDING=0
TMP=""

cleanup() {
  [ -n "$TMP" ] && rm -rf "$TMP"
}
trap cleanup EXIT
TMP=$(mktemp -d /tmp/layer1-ac1.XXXXXX) || { echo "FATAL: mktemp failed"; exit 2; }

ac_pass() { PASS=$((PASS + 1)); echo "AC$1: PASS $2"; }
ac_fail() { FAIL=$((FAIL + 1)); echo "AC$1: FAIL $2"; }
ac_pend() { PENDING=$((PENDING + 1)); echo "AC$1: PENDING $2"; }

# 块截取（契约 §AC 共用方法）：从 ^      <key>: 行到下一个 ^      [0-9a-z_]+: 行之前
block_of() {
  local f="$1" key="$2" s e
  s=$(grep -n "^      ${key}:" "$f" | cut -d: -f1)
  [ -n "$s" ] || { echo "BLOCK NOT FOUND: ${key} in ${f}" >&2; return 1; }
  e=$(awk -v s="$s" 'NR>s && /^      [0-9a-z_]+:/{print NR; exit}' "$f")
  [ -n "$e" ] || e=$(wc -l < "$f")
  sed -n "${s},$((e - 1))p" "$f"
}

grep_c() {  # $1=file-or-dash  $2=pattern  → 输出计数；exit 2 = grep 用法错
  grep -c -e "$2" "$1"
}

# 文件清单（契约 §文件清单 12 项 + 契约自身含 Completion，target_scope pathspec）
cat > "$TMP/manifest.txt" <<'M_EOF'
.claude/skills/blake/SKILL.md
.agents/skills/blake/SKILL.md
.tad/config-execution.yaml
.tad/ralph-config/loop-config.yaml
README.md
docs/RALPH-LOOP.md
.tad/project-knowledge/patterns/shell-portability.md
.tad/evidence/audits/lite-constraint-ledger.md
.tad/evidence/acceptance-tests/layer1-ac-driven-compat/verify.sh
.tad/evidence/acceptance-tests/layer1-ac-driven-compat/results.txt
.tad/evidence/acceptance-tests/layer1-ac-driven-compat/scope-baseline.txt
.tad/evidence/reviews/blake/layer1-ac-driven-compat/
.tad/active/handoffs/LITE-20260810-1820-layer1-ac-driven-compat.md
M_EOF

# 目录项（清单内以 / 结尾的行，去尾斜杠）用于前缀匹配
grep -E '/$' "$TMP/manifest.txt" | sed 's:/*$::' > "$TMP/manifest.dirs"

in_manifest() {  # $1=path → 精确或目录前缀命中
  local p="$1" d
  grep -Fxq -e "$p" "$TMP/manifest.txt" && return 0
  while IFS= read -r d; do
    case "$p" in "$d"/*) return 0;; esac
  done < "$TMP/manifest.dirs"
  return 1
}

BASELINE="$PWD/.tad/evidence/acceptance-tests/layer1-ac-driven-compat/scope-baseline.txt"
[ -f "$BASELINE" ] || { echo "FATAL: scope-baseline.txt missing"; exit 2; }

# ============ AC1-AC4 / AC6 / AC11 / AC12 / AC13 / AC15 / AC19: 两棵树 ============
for tree in .claude .agents; do
  f="$tree/skills/blake/SKILL.md"

  blk=$(block_of "$f" 2_layer1_loop) || { ac_fail 1 "block missing in ${f}"; continue; }

  # AC1（缺席）：块内无 npm /npx
  n1=$(printf '%s\n' "$blk" | grep -c 'npm \|npx '); rc=$?
  if [ "$rc" -eq 2 ]; then ac_fail 1 "grep usage error in ${f}"; else
    [ "$n1" -eq 0 ] && ac_pass 1 "${f} npm/npx=0" || ac_fail 1 "${f} npm/npx=${n1} (expect 0)"
  fi

  # AC2（正向）：§9.1 + Spec Compliance Checklist
  n2a=$(printf '%s\n' "$blk" | grep -cF '§9.1'); rca=$?
  n2b=$(printf '%s\n' "$blk" | grep -cF 'Spec Compliance Checklist'); rcb=$?
  if [ "$rca" -eq 2 ] || [ "$rcb" -eq 2 ]; then ac_fail 2 "grep usage error in ${f}"; else
    [ "$n2a" -ge 1 ] && [ "$n2b" -ge 1 ] && ac_pass 2 "${f} §9.1=${n2a} checklist=${n2b}" \
      || ac_fail 2 "${f} §9.1=${n2a} checklist=${n2b} (expect both >=1)"
  fi

  # AC3（正向，覆盖 D2）：零命令 + completion report
  n3a=$(printf '%s\n' "$blk" | grep -cF '零命令'); rca=$?
  n3b=$(printf '%s\n' "$blk" | grep -cF 'completion report'); rcb=$?
  if [ "$rca" -eq 2 ] || [ "$rcb" -eq 2 ]; then ac_fail 3 "grep usage error in ${f}"; else
    [ "$n3a" -ge 1 ] && [ "$n3b" -ge 1 ] && ac_pass 3 "${f} 零命令=${n3a} completion=${n3b}" \
      || ac_fail 3 "${f} 零命令=${n3a} completion=${n3b} (expect both >=1)"
  fi

  # AC4（正向，覆盖 D1 优先级）：loop-config.yaml + 先后关系
  n4a=$(printf '%s\n' "$blk" | grep -cF 'loop-config.yaml'); rca=$?
  n4b=$(printf '%s\n' "$blk" | grep -cE '优先|precedence|仅在'); rcb=$?
  if [ "$rca" -eq 2 ] || [ "$rcb" -eq 2 ]; then ac_fail 4 "grep usage error in ${f}"; else
    [ "$n4a" -ge 1 ] && [ "$n4b" -ge 1 ] && ac_pass 4 "${f} loop-config=${n4a} precedence=${n4b}" \
      || ac_fail 4 "${f} loop-config=${n4a} precedence=${n4b} (expect both >=1)"
  fi

  # AC5（缺席，全文，rev5 无条件）
  n5=$(grep_c "$f" 'npm run build\|npm test\|npm run lint\|npx tsc --noEmit'); rc=$?
  if [ "$rc" -eq 2 ]; then ac_fail 5 "grep usage error in ${f}"; else
    [ "$n5" -eq 0 ] && ac_pass 5 "${f} full-text=0" || ac_fail 5 "${f} full-text=${n5} (expect 0)"
  fi

  # AC6（不变量保护）：ANTI-RATIONALIZATION 语义串每棵树 2 处
  n6=$(grep_c "$f" 'test-runner subagent 额外检查覆盖率和测试质量'); rc=$?
  if [ "$rc" -eq 2 ]; then ac_fail 6 "grep usage error in ${f}"; else
    [ "$n6" -eq 2 ] && ac_pass 6 "${f} invariant=${n6}" || ac_fail 6 "${f} invariant=${n6} (expect 2)"
  fi

  # AC11 缺席半（blake/SKILL.md 两棵树）
  n11=$(grep_c "$f" 'import yaml'); rc=$?
  if [ "$rc" -eq 2 ]; then ac_fail 11 "grep usage error in ${f}"; else
    [ "$n11" -eq 0 ] && ac_pass 11 "${f} import-yaml=0" || ac_fail 11 "${f} import-yaml=${n11} (expect 0)"
  fi

  # AC12（②e）：1_5_context_refresh 块
  cblk=$(block_of "$f" 1_5_context_refresh) || { ac_fail 12 "block missing in ${f}"; continue; }
  n12a=$(printf '%s\n' "$cblk" | grep -c 'full content'); rca=$?
  if [ "$rca" -eq 2 ]; then ac_fail 12 "grep usage error in ${f}"; continue; fi
  dups=$(printf '%s\n' "$cblk" | grep -o '^[[:space:]]*[0-9]\{1,\}\.' | tr -d ' ' | LC_ALL=C sort | uniq -d)
  n12b=$(printf '%s\n' "$cblk" | grep -cF '§6'); rcb=$?
  n12c=$(printf '%s\n' "$cblk" | grep -cF '§9'); rcc=$?
  if [ "$rcb" -eq 2 ] || [ "$rcc" -eq 2 ]; then ac_fail 12 "grep usage error in ${f}"; continue; fi
  if [ "$n12a" -eq 0 ] && [ -z "$dups" ] && [ "$n12b" -ge 1 ] && [ "$n12c" -ge 1 ]; then
    ac_pass 12 "${f} full-content=0 dup-steps=none §6=${n12b} §9=${n12c}"
  else
    ac_fail 12 "${f} full-content=${n12a} dup-steps=${dups:-none} §6=${n12b} §9=${n12c}"
  fi

  # AC13（结构守卫）：frontmatter 真实解析器 PASS
  if sed -n '2,/^---$/p' "$f" | ruby -ryaml -e 'YAML.safe_load($stdin.read); puts "PASS"' >/dev/null 2>&1; then
    ac_pass 13 "${f} frontmatter parse PASS"
  else
    ac_fail 13 "${f} frontmatter parse FAIL"
  fi

  # AC19（框图正向配对）：开框/闭框配对单调 + Layer 1 区域内 §9.1
  grep -n '┌.*┐' "$f" | cut -d: -f1 > "$TMP/open"
  grep -n '└.*┘' "$f" | cut -d: -f1 > "$TMP/close"
  no=$(wc -l < "$TMP/open")
  nc=$(wc -l < "$TMP/close")
  if [ "$no" -ne "$nc" ]; then
    ac_fail 19 "${f} open=${no} close=${nc} (must be equal)"
    continue
  fi
  if [ "$no" -eq 0 ]; then
    ac_fail 19 "${f} no diagram found"
    continue
  fi
  if paste -d' ' "$TMP/open" "$TMP/close" | awk '{ if ($1 >= $2) exit 1; if (prev >= $1) exit 1; prev = $2 }'; then
    :
  else
    ac_fail 19 "${f} open/close not strictly monotonic (open[i]<close[i]<open[i+1])"
    continue
  fi
  # 找到含 Layer 1: Self-Check 的区域并断言
  paste -d' ' "$TMP/open" "$TMP/close" > "$TMP/pairs"
  target=""
  while IFS=' ' read -r o c; do
    if sed -n "${o},${c}p" "$f" | grep -qF -e 'Layer 1: Self-Check'; then target="${o},${c}"; break; fi
  done < "$TMP/pairs"
  if [ -z "$target" ]; then
    ac_fail 19 "${f} no region contains Layer 1: Self-Check"
    continue
  fi
  o=${target%,*}
  c=${target#*,}
  n19a=$(sed -n "${o},${c}p" "$f" | grep -cF -e 'Layer 1: Self-Check'); rca=$?
  n19b=$(sed -n "${o},${c}p" "$f" | grep -cF -e '§9.1'); rcb=$?
  if [ "$rca" -eq 2 ] || [ "$rcb" -eq 2 ]; then ac_fail 19 "grep usage error in ${f}"; continue; fi
  [ "$n19a" -eq 1 ] && [ "$n19b" -ge 1 ] && ac_pass 19 "${f} region=[${target}] L1=${n19a} §9.1=${n19b}" \
    || ac_fail 19 "${f} region=[${target}] L1=${n19a} §9.1=${n19b} (expect 1 / >=1)"
done

# ============ AC15（镜像）============
if cmp -s .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md; then
  ac_pass 15 "trees byte-identical"
else
  ac_fail 15 "trees differ"
fi

# ============ AC7（loop-config.yaml 解析 + 键齐全 + 无 npm/npx）============
if ruby -ryaml -e 'd=YAML.safe_load(File.read(ARGV[0])); cs=d["ralph_loop"]["layer1"]["commands"]; abort("FAIL nil") if cs.nil?; cs.each{|c| abort("FAIL npm/npx") if c["command"] =~ /\bnpm\b|\bnpx\b/; %w[name command timeout required].each{|k| abort("FAIL missing #{k}") unless c.key?(k)}}; puts "PASS n=#{cs.size}"' .tad/ralph-config/loop-config.yaml >/dev/null 2>&1; then
  n7=$(ruby -ryaml -e 'd=YAML.safe_load(File.read(ARGV[0])); puts d["ralph_loop"]["layer1"]["commands"].size' .tad/ralph-config/loop-config.yaml)
  ac_pass 7 "loop-config.yaml parse PASS n=${n7}"
else
  ac_fail 7 "loop-config.yaml parse FAIL (nil commands / npm-npx / missing key)"
fi

# ============ AC8（config-execution.yaml：缺席 + 正向 + 解析）============
n8a=$(grep_c .tad/config-execution.yaml 'Layer 1: Self-Check (build, test, lint, tsc)'); rca=$?
n8b=$(grep_c .tad/config-execution.yaml '§9.1'); rcb=$?
if [ "$rca" -eq 2 ] || [ "$rcb" -eq 2 ]; then ac_fail 8 "grep usage error"; else
  if ruby -ryaml -e 'YAML.safe_load(File.read(ARGV[0])); puts "PASS"' .tad/config-execution.yaml >/dev/null 2>&1; then
    [ "$n8a" -eq 0 ] && [ "$n8b" -ge 1 ] && ac_pass 8 "config-execution absent=0 §9.1=${n8b} parse=PASS" \
      || ac_fail 8 "config-execution absent=${n8a} §9.1=${n8b} parse=PASS (expect 0 / >=1)"
  else
    ac_fail 8 "config-execution.yaml YAML parse FAIL"
  fi
fi

# ============ AC9（README.md Layer 1 小节：缺席 + 正向）============
rblk=$(sed -n '/^\*\*Layer 1 (Self-Check):\*\*/,/^\*\*Layer 2/p' README.md)
n9a=$(printf '%s\n' "$rblk" | grep -c 'build, test, lint, tsc'); rca=$?
n9b=$(printf '%s\n' "$rblk" | grep -cF '§9.1'); rcb=$?
if [ "$rca" -eq 2 ] || [ "$rcb" -eq 2 ]; then ac_fail 9 "grep usage error"; else
  [ "$n9a" -eq 0 ] && [ "$n9b" -ge 1 ] && ac_pass 9 "README section absent=0 §9.1=${n9b}" \
    || ac_fail 9 "README section absent=${n9a} §9.1=${n9b} (expect 0 / >=1)"
fi

# ============ AC10（docs/RALPH-LOOP.md Layer 1 节：缺席 + 正向）============
lblk=$(sed -n '/^## Layer 1: Self-Check$/,/^## Layer 2/p' docs/RALPH-LOOP.md)
n10a=$(printf '%s\n' "$lblk" | grep -c 'npm run build\|npm test\|npm run lint\|npx tsc --noEmit'); rca=$?
n10b=$(printf '%s\n' "$lblk" | grep -cF '§9.1'); rcb=$?
if [ "$rca" -eq 2 ] || [ "$rcb" -eq 2 ]; then ac_fail 10 "grep usage error"; else
  [ "$n10a" -eq 0 ] && [ "$n10b" -ge 1 ] && ac_pass 10 "RALPH-LOOP section absent=0 §9.1=${n10b}" \
    || ac_fail 10 "RALPH-LOOP section absent=${n10a} §9.1=${n10b} (expect 0 / >=1)"
fi

# ============ AC11 fixture 半（发布命令字面复制 × 合法/损坏两分支）============
FIX="$TMP/fix"
mkdir -p "$FIX"
# 形式 1（blake/SKILL.md :1247 发布）：ruby -ryaml -e 'YAML.safe_load(File.read(ARGV[0]))' "$f"
printf 'name: valid\nnested:\n  key: value\n' > "$FIX/valid1.yaml"
printf 'name: [unclosed\n' > "$FIX/bad1.yaml"
ruby -ryaml -e 'YAML.safe_load(File.read(ARGV[0]))' "$FIX/valid1.yaml" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 0 ] && a11ok=1 || a11ok=0
ruby -ryaml -e 'YAML.safe_load(File.read(ARGV[0]))' "$FIX/bad1.yaml" >/dev/null 2>&1; rc=$?
[ "$rc" -ne 0 ] && a11bad=1 || a11bad=0
# 形式 2（shell-portability.md :72 发布）：... .split("---")[1])' SKILL.md
printf -- '---\nname: valid\n---\nbody text\n' > "$FIX/SKILL.md"
printf -- '---\nname: [unclosed\n---\n' > "$FIX/bad2.md"
( cd "$FIX" && ruby -ryaml -e 'YAML.safe_load(File.read(ARGV[0]).split("---")[1])' SKILL.md ) >/dev/null 2>&1; rc=$?
[ "$rc" -eq 0 ] && a11ok2=1 || a11ok2=0
( cd "$FIX" && ruby -ryaml -e 'YAML.safe_load(File.read(ARGV[0]).split("---")[1])' bad2.md ) >/dev/null 2>&1; rc=$?
[ "$rc" -ne 0 ] && a11bad2=1 || a11bad2=0
if [ "$a11ok" -eq 1 ] && [ "$a11bad" -eq 1 ] && [ "$a11ok2" -eq 1 ] && [ "$a11bad2" -eq 1 ]; then
  ac_pass 11 "fixtures: form1 valid=0 bad!=0; form2 valid=0 bad!=0"
else
  ac_fail 11 "fixtures ok=${a11ok}/${a11ok2} bad=${a11bad}/${a11bad2} (expect 1/1/1/1)"
fi

# ============ AC11 缺席半（shell-portability.md）============
n11s=$(grep_c .tad/project-knowledge/patterns/shell-portability.md 'import yaml'); rc=$?
if [ "$rc" -eq 2 ]; then ac_fail 11 "grep usage error on shell-portability"; else
  [ "$n11s" -eq 0 ] && ac_pass 11 "shell-portability import-yaml=0" || ac_fail 11 "shell-portability import-yaml=${n11s} (expect 0)"
fi

# ============ AC18（shell-portability.md 条目其余四行逐字不变）============
L70='- **Context**: Codex CLI `$` skill mechanism parses YAML frontmatter of `.agents/skills/*/SKILL.md` on activation. Two packs (ai-agent-architecture, web-ui-design) had unquoted `description` fields containing colons (e.g., `Two modes: /design`). Claude Code'"'"'s skill loader is lenient and ignores parse errors; Codex'"'"'s loader fails on them.'
L71='- **Discovery**: YAML `description: value with colons: inside` is ambiguous — the parser may interpret the second colon as a nested key. Claude Code never surfaced this because its skill loader either doesn'"'"'t parse `description` or tolerates errors. Codex'"'"'s `$` mechanism parses frontmatter strictly and reports errors on activation. The fix is trivial (wrap in double quotes) but the root cause is that SKILL.md frontmatter was never validated against a strict YAML parser.'
L73='- **Grounded in**: .tad/evidence/dogfood/codex-unification-dogfood.md Finding 2, .claude/skills/ai-agent-architecture/SKILL.md, .claude/skills/web-ui-design/SKILL.md'
L74='- **failure_mode**: Naive default: write YAML description fields with unquoted colons (e.g., description: Two modes: /design). Why wrong: YAML parsers may interpret the second colon as a nested key; lenient parsers (Claude Code) hide the error, but strict parsers (Codex) fail on activation.'
a18ok=1
for spec in "70:$L70" "71:$L71" "73:$L73" "74:$L74"; do
  ln=${spec%%:*}
  line=${spec#*:}
  if grep -Fxq -e "$line" .tad/project-knowledge/patterns/shell-portability.md; then
    :
  else
    a18ok=0
    ac_fail 18 "line ${ln} missing or changed"
  fi
done
[ "$a18ok" -eq 1 ] && ac_pass 18 "shell-portability :70/:71/:73/:74 verbatim"

# ============ AC14（范围围栏：新增路径 ⊆ 清单；已脏路径摘要一致）============
# 第一半：新增路径
awk '/^# ---- paths/{on=1; next} /^# ---- digests/{on=0} on && !/^#/{print}' "$BASELINE" > "$TMP/base.paths"
git status --porcelain=v1 -uall | sed 's/^...//' | LC_ALL=C sort -u > "$TMP/now.paths"
LC_ALL=C comm -13 "$TMP/base.paths" "$TMP/now.paths" > "$TMP/new.paths"
LC_ALL=C sort -u "$TMP/manifest.txt" > "$TMP/manifest.sorted"
a14ok=1
while IFS= read -r p; do
  in_manifest "$p" || { a14ok=0; echo "  out-of-scope new path: ${p}"; }
done < "$TMP/new.paths"
# 第二半：不在清单内的已脏路径摘要前后一致
git status --porcelain=v1 -uall | sed 's/^...//' | LC_ALL=C sort -u | while IFS= read -r p; do
  [ -f "$p" ] && shasum -a 256 "$p"
done > "$TMP/now.digests"
awk '/^[0-9a-f]{64}  /{print}' "$BASELINE" > "$TMP/base.digests"
while IFS= read -r line; do
  sha=$(printf '%s\n' "$line" | cut -d' ' -f1)
  p=$(printf '%s\n' "$line" | cut -d' ' -f3-)
  in_manifest "$p" && continue
  case "$p" in .tad/evidence/traces/*) continue;; esac   # 框架 hook 遥测自动追加，非越界编辑（L3 reviewer 实证）
  # P0 修复：grep -F 模式下 $ 是字面量非行尾锚（BSD 2.6.0 与 ugrep 均 rc=1）→ 改用 awk index + 行尾后缀精确匹配
  bsha=$(awk -v p="$p" 'index($0, "  " p) > 0 && substr($0, length($0) - length(p) + 1) == p {print $1; exit}' "$TMP/base.digests")
  [ -n "$bsha" ] || continue   # 基线无此路径（新增路径已由第一半覆盖）
  if [ "$sha" != "$bsha" ]; then
    a14ok=0
    echo "  dirty path digest changed: ${p}"
  fi
done < "$TMP/now.digests"
if [ "$a14ok" -eq 1 ]; then
  ac_pass 14 "no out-of-scope paths; dirty digests unchanged"
else
  ac_fail 14 "scope fence violation(s) listed above"
fi

# ============ AC16（提交纪律：需在 L3 后提交再跑）============
BASE_SHA=$(grep '^# base_sha:' "$BASELINE" | cut -d' ' -f3)
TIP_SHA=$(git rev-parse HEAD 2>/dev/null)
if git rev-list "$BASE_SHA..$TIP_SHA" | grep -q . 2>/dev/null; then
  a16ok=1
  if git merge-base --is-ancestor "$BASE_SHA" "$TIP_SHA"; then :; else a16ok=0; echo "  base not ancestor of tip"; fi
  if [ "$(git rev-list --merges "$BASE_SHA..$TIP_SHA" | wc -l | tr -d ' ')" -eq 0 ]; then :; else a16ok=0; echo "  merge commits present"; fi
  git diff --name-only "$BASE_SHA..$TIP_SHA" | LC_ALL=C sort -u > "$TMP/commit.files"
  while IFS= read -r cf; do
    in_manifest "$cf" || { a16ok=0; echo "  commit file out of scope: ${cf}"; }
  done < "$TMP/commit.files"
  if [ "$a16ok" -eq 1 ]; then
    ac_pass 16 "base=${BASE_SHA} tip=${TIP_SHA} append-only, no merges, files in scope"
  else
    ac_fail 16 "commit discipline violation(s) above"
  fi
else
  ac_pend 16 "提交未发生（action scoped-local-commit-after-gate 在 L3 后执行；提交后重跑本脚本得 PASS）"
fi

# ============ 汇总 ============
echo "===== SUMMARY: PASS=${PASS} FAIL=${FAIL} PENDING=${PENDING} ====="
[ "$FAIL" -eq 0 ]
