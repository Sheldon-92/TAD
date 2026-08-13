f="$1"
# blake-lite L0.5 · 目标题检查（$f = 当前 LITE 契约）
sec=$(sed -n '/^## 目标题[[:space:]]*$/,$p' "$f" | sed -n '1p;2,${/^## /q;p;}')
[ -n "$sec" ] || { echo "GATE FAIL / BLOCK: 契约缺 ## 目标题"; exit 1; }
o=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cE '^- \[[A-Z]\] ' || true)
n=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cF '[不是这个意思]' || true)
p=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cE '^用户选择: [A-Z]$' || true)
c=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cE '^通道: (lite|full)（四类命中: .+）$' || true)
ltr=$(printf '%s\n' "$sec" | LC_ALL=C command grep -oE '^用户选择: [A-Z]$' | LC_ALL=C command grep -oE '[A-Z]$')
i=$(printf '%s\n' "$sec" | LC_ALL=C command grep -cE "^- \[${ltr:-@}\] " || true)
# 选中的那条不得是「不是这个意思」——选它意味着需求没摸清，应回去重问
w=$(printf '%s\n' "$sec" | LC_ALL=C command grep -E "^- \[${ltr:-@}\] " | LC_ALL=C command grep -cF '[不是这个意思]' || true)
[ "$o" -ge 2 ] && [ "$n" -eq 1 ] && [ "$p" -eq 1 ] && [ "$c" -eq 1 ] && [ "$i" -eq 1 ] && [ "$w" -eq 0 ] \
  || { echo "GATE FAIL / BLOCK: 目标题不合格 (opts=$o null=$n pick=$p chan=$c inset=$i wrong=$w)"; exit 1; }
