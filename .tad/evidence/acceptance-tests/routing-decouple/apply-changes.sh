#!/usr/bin/env bash
# Apply — HANDOFF-20260814-routing-decouple (rev2)
# Literal whole-line replacement. NO eval, NO shell expansion of tsv content.
# Each replacement asserts its precondition (exactly 1 hit) before writing.
R="/path/to/TAD"
TSV="$R/.tad/active/handoffs/HANDOFF-20260814-routing-decouple.pins.tsv"
BLK="$R/.tad/active/handoffs/HANDOFF-20260814-routing-decouple"
export LC_ALL=C
FAILED=0

replace_pin() { # file old new label
  local f="$1" o="$2" n="$3" lbl="$4" tmp
  tmp=$(mktemp)
  LC_ALL=C awk -v o="$o" -v n="$n" 'BEGIN{hit=0} $0==o{print n; hit++; next} {print} END{if(hit!=1) exit 1}' "$f" > "$tmp"
  if [ $? -ne 0 ]; then echo "APPLY FAIL: ${lbl} (old hit != 1)"; rm -f "$tmp"; FAILED=1; return 1; fi
  chmod --reference="$f" "$tmp" || chmod 644 "$tmp"
  mv "$tmp" "$f" || { rm -f "$tmp"; echo "APPLY FAIL: ${lbl} (mv)"; FAILED=1; return 1; }
  echo "  applied ${lbl}"
}

apply_block() { # file begin end blockfile label
  local f="$1" b="$2" e="$3" bf="$4" lbl="$5" tmp
  tmp=$(mktemp)
  LC_ALL=C awk -v b="$b" -v e="$e" -v blk="$bf" '
    BEGIN { n=0; hit=0; end_hit=0
            while (1) { rc = (getline l < blk); if (rc <= 0) { if (rc < 0) exit 2; break } repl[n++]=l } }
    $0==b { for (i=0;i<n;i++) print repl[i]; del=1; hit=1; next }
    del { if ($0==e) { del=0; end_hit=1; next } next }
    { print }
    END { if (hit!=1 || end_hit!=1) exit 1 }
  ' "$f" > "$tmp"
  if [ $? -ne 0 ]; then echo "APPLY FAIL: ${lbl} (anchor/block error)"; rm -f "$tmp"; FAILED=1; return 1; fi
  chmod --reference="$f" "$tmp" || chmod 644 "$tmp"
  mv "$tmp" "$f" || { rm -f "$tmp"; echo "APPLY FAIL: ${lbl} (mv)"; FAILED=1; return 1; }
  echo "  applied ${lbl}"
}

apply_block_c() { # CLAUDE.md: replace the single line after the "### 2.5 " heading with block-c.txt
  local f="$1" tmp
  tmp=$(mktemp)
  LC_ALL=C awk -v blk="$BLK.block-c.txt" '
    BEGIN { n=0; while ((getline l < blk) > 0) repl[n++]=l; done=0 }
    done==0 && index($0,"### 2.5 ")==1 {
      print; getline
      if (index($0,"**默认通道**") == 0) exit 3
      for (i=0;i<n;i++) print repl[i]; done=1; next
    }
    { print }
    END { if (done!=1) exit 1 }
  ' "$f" > "$tmp"
  if [ $? -ne 0 ]; then echo "APPLY FAIL: block C (2.5 heading/line assertion)"; rm -f "$tmp"; FAILED=1; return 1; fi
  chmod --reference="$f" "$tmp" || chmod 644 "$tmp"
  mv "$tmp" "$f" || { rm -f "$tmp"; echo "APPLY FAIL: block C (mv)"; FAILED=1; return 1; }
  echo "  applied block C (CLAUDE.md 2.5)"
}

echo "== pins (19) =="
while IFS=$'\t' read -r id f old new; do
  [ -n "$id" ] || continue
  replace_pin "$R/$f" "$old" "$new" "pin ${id} ${f}"
done < "$TSV"

echo "== blocks =="
apply_block "$R/INSTALLATION_GUIDE.md" \
  "# 默认通道（lite —— 可同一 terminal，由人输入命令切换角色）" \
  "/blake          # Terminal 2: 实现与执行" \
  "$BLK.block-a.txt" "block A INSTALLATION_GUIDE.md"
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
         .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  apply_block "$R/$f" \
    "## Lite-First 政策（默认通道，不可妥协）" \
    "- 补充细节/检查留在 Lite；切 full 是例外。" \
    "$BLK.block-b.txt" "block B ${f}"
done
apply_block_c "$R/CLAUDE.md"

echo "== derived =="
printf '2.42.0\n' > "$R/.tad/version.txt"
echo "  version.txt -> 2.42.0"
if [ -x "$R/.tad/hooks/lib/brain-index-gen.sh" ]; then
  bash "$R/.tad/hooks/lib/brain-index-gen.sh" && echo "  brain-index regenerated" || { echo "brain-index-gen FAIL"; FAILED=1; }
else
  echo "brain-index-gen.sh missing"; FAILED=1
fi

if [ "$FAILED" = "0" ]; then echo "APPLY OK"; else echo "APPLY FAILED"; exit 1; fi
