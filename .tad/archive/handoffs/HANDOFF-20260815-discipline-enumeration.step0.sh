#!/usr/bin/env bash
# P2a Step 0 —— 一次冻结全部基线。由 Blake 在动手前运行，不得修改（AC13 守其哈希）。
set -uo pipefail
R="/path/to/TAD"
EV="$R/.tad/evidence/acceptance-tests/discipline-enumeration"; mkdir -p "$EV/negative-controls"
H=".tad/active/handoffs/HANDOFF-20260815-discipline-enumeration.md"
T0=$(git -C "$R" rev-parse --short HEAD); echo "$T0" > "$EV/t0.txt"
git -C "$R" ls-files --error-unmatch "$H" >/dev/null 2>&1 \
  || { echo "Step 0 失败：契约未被 git 追踪，AC13 无外部载体"; exit 1; }
printf '%s\n' 'MUST|MANDATORY|BLOCKING|VIOLATION|forbidden|Forbidden|MUST NOT|NEVER|never |shall |required|Required|blocking: *true|不得|必须|禁止|严禁|一律|不可|不允许|应当|⚠️' > "$EV/wide-markers.txt"
W=$(cat "$EV/wide-markers.txt")

# 逐文件期望块数：漂移时指认是哪个文件，而不是只报总数
cat > "$EV/expected-blocks.tsv" <<'EXP'
.claude/skills/gate/SKILL.md	16
AGENTS.md	11
.tad/config-workflow.yaml	11
.tad/config-quality.yaml	7
.tad/config-execution.yaml	5
.tad/config-cognitive.yaml	4
.tad/config-agents.yaml	4
.tad/config-platform.yaml	2
EXP
: > "$EV/blocks.txt"
while IFS=$'\t' read -r f want; do
  if [ "${f##*.}" = md ]; then RE='^[a-z_]+:|^#{2,3} '; else RE='^[a-z_]+:'; fi
  LC_ALL=C command grep -nE "$RE" "$R/$f" \
    | LC_ALL=C awk -v f="$f" '{i=index($0,":"); printf "%s\t%s\t%s\n", f, substr($0,1,i-1), substr($0,i+1)}' > "$EV/.b"
  got=$(command grep -c . "$EV/.b" || true)
  [ "$got" -eq "$want" ] || { echo "Step 0 失败：${f} 块数 ${got}，应 ${want}（语料漂移，停下退回 Alex）"; exit 1; }
  cat "$EV/.b" >> "$EV/blocks.txt"
done < "$EV/expected-blocks.tsv"
rm -f "$EV/.b"
LC_ALL=C awk -F'\t' 'NF!=3{b++} END{exit (b+0)>0}' "$EV/blocks.txt" || { echo "Step 0 失败：blocks.txt 非三段"; exit 1; }
[ "$(command grep -c . "$EV/blocks.txt")" -eq 60 ] || { echo "Step 0 失败：总块数非 60"; exit 1; }

# ranges.txt：同文件下一块起始行-1；末块 = wc -l（tr -d ' ' 去 macOS 前导空格）
LC_ALL=C awk -F'\t' -v R="$R" '{f[NR]=$1;s[NR]=$2}
  END{for(i=1;i<=NR;i++){ if(i<NR && f[i+1]==f[i]) e=s[i+1]-1;
      else {cmd="wc -l < \""R"/"f[i]"\" | tr -d \" \""; cmd|getline e; close(cmd)}
      printf "%s\t%s\t%s\n", f[i], s[i], e}}' "$EV/blocks.txt" > "$EV/ranges.txt"
LC_ALL=C awk -F'\t' '$3<$2{n++} END{exit (n+0)>0}' "$EV/ranges.txt" || { echo "Step 0 失败：存在非法区间"; exit 1; }

# hits.tsv：每块区间内的宽词表命中数（AC4 分档与 AC7 触发的唯一依据；Blake 不得自报）
LC_ALL=C awk -F'\t' -v R="$R" -v W="$W" '{cmd="sed -n \""$2","$3"p\" \""R"/"$1"\" | LC_ALL=C command grep -cE \x27"W"\x27";
  cmd|getline h; close(cmd); printf "%s\t%s\t%s\n",$1,$2,h}' "$EV/ranges.txt" > "$EV/hits.tsv"

# names.txt：inventory 的 15 个纪律名（AC2 闭集白名单）
sed -n '/^| 纪律 | 来源 |/,/^$/p' "$R/.tad/evidence/designs/discipline-inventory/discipline-inventory.md" \
  | command grep -v '^| 纪律 \|^|---' \
  | LC_ALL=C awk -F'|' 'NF>2{gsub(/^ +| +$/,"",$2); if($2!="")print $2}' | LC_ALL=C sort > "$EV/names.txt"
[ "$(command grep -c . "$EV/names.txt")" -eq 15 ] || { echo "Step 0 失败：纪律名非 15"; exit 1; }

# subkeys.tsv：AC7 期望子键集 —— 仅「自身区间内含窄标记」的子键才算独立强制子项。
# ⚠️ 不过滤 = 1144 条（每块 48 个，逐字列举不可满足）；宽标记过滤 = 151 条；
#    窄标记过滤 = 62 条（24 块，均 2.6 个）。取窄档。
NARROW='MUST|MANDATORY|VIOLATION|BLOCKING|blocking: *true|forbidden'
: > "$EV/subkeys.tsv"
paste "$EV/ranges.txt" <(LC_ALL=C cut -f3 "$EV/hits.tsv") | while IFS=$'\t' read -r f s e h; do
  span=$((e-s+1)); { [ "$span" -gt 60 ] || [ "$h" -ge 10 ]; } || continue
  # ⚠️ 子键区间必须按**缩进**算，不能按"下一个匹配行"算 —— 后者会把父子当兄弟：
  #    `      knowledge_assessment:`(6空格) 的区间被截在 `        blocking: true`(8空格) 之前，
  #    于是有意义的名字被丢、无意义的 `blocking: true` 反被留下（Alex 自查实测）。
  sed -n "${s},${e}p" "$R/$f" | LC_ALL=C awk -v s="$s" '
      {ln=s+NR-1; line=$0
       if (match(line,/^ {2,6}[a-z_][a-z_0-9]*:/)) {
         ind=match(line,/[^ ]/)-1; nm=line; sub(/^ +/,"",nm); sub(/:.*$/,"",nm)
         printf "%s\t%s\t%s\n", ln, ind, nm }
       else if (match(line,/^#### /)) { nm=line; sub(/^#### */,"",nm); printf "%s\t0\t%s\n", ln, nm }
      }' > "$EV/.sk"
  [ -s "$EV/.sk" ] || continue
  LC_ALL=C awk -F'\t' -v e="$e" '{a[NR]=$1;d[NR]=$2;k[NR]=$3}
    END{for(i=1;i<=NR;i++){ en=e; for(j=i+1;j<=NR;j++){ if(d[j]<=d[i]){ en=a[j]-1; break } }
        printf "%s\t%s\t%s\n", a[i], en, k[i]}}' "$EV/.sk" \
  | while IFS=$'\t' read -r ss se key; do
      # ⚠️ 从 ss+1 起算：否则 `blocking: true` 这类键名会**自己满足自己**（键行即标记行），
      #    实测产出 18 条这种噪音键。要求标记出现在键行**之后**，只留真正含强制子内容的键。
      c=$(sed -n "$((ss+1)),${se}p" "$R/$f" | LC_ALL=C command grep -cE "$NARROW" || true)
      [ "$c" -ge 1 ] && printf '%s\t%s\t%s\n' "$f" "$s" "$(printf '%s' "$key" | LC_ALL=C sed 's/^ *//;s/ *$//')" >> "$EV/subkeys.tsv"
    done
done
rm -f "$EV/.sk"

# candidates.tsv：10 条 Gate 2 候选（名称/文件/行号/断言关键词），Alex 已逐条复算属实
cat > "$EV/candidates.tsv" <<'CAND'
研究先行	.tad/config-cognitive.yaml	120	research_first:
技术决策透明	.tad/config-cognitive.yaml	6	Pillar 1: Technical Decision Tran
平台绑定交互决策	.claude/skills/alex/SKILL.md	149	平台绑定交互决策
六个强制问题	.tad/config-quality.yaml	393	mandatory_questions:
结构性subagent强制	.claude/skills/gate/SKILL.md	624	Structural_Subagent_Conditionality:
subagents强制调用	.tad/config-quality.yaml	7	subagents_enforcement:
产物证据链	.claude/skills/blake/SKILL.md	1606	Git commit + evidence ls-check
规格逐行实跑	.claude/skills/gate/SKILL.md	159	SPEC COMPLIANCE VERIFICATION
熔断与升级	.claude/skills/blake/SKILL.md	995	circuit_breaker:
GlobalSkillExclusion	.claude/skills/alex/SKILL.md	490	GLOBAL SKILL EXCLUSION
CAND

{ git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
echo "Step 0 OK: T0=$T0 | 60 块 | 零标记块 $(LC_ALL=C awk -F'\t' '$3==0{n++} END{print n+0}' "$EV/hits.tsv") | 15 名 | 10 候选 | $(command grep -c . "$EV/subkeys.tsv" || true) 强制子键"
