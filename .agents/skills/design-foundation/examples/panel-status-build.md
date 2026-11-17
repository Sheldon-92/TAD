---
name: panel-status-build
description: "Tests design-foundation canon application for a project status panel: CJK font-stack structure, the four status tokens with non-color channels, light-dark() paired colors, the concentric radius formula, and table column-priority narrow-width handling"
pack: design-foundation
tests_rules:
  - "中文字体栈结构定版（三段构成、CJK 按平台具名列全、禁止未具名回退）"
  - "状态令牌四件（--color-status-active/blocked/waiting/done）＋颜色非唯一通道（文字标签＋形标记）"
  - "颜色令牌以 light-dark() 成对给出"
  - "同心圆角公式 r_inner = r_outer − gap（calc() 派生）"
  - "表格列优先级窄屏口径（身份列与状态列必显、可收列移入行展开区）"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY markers this pack mints — its own status/font token names and its
# r_inner formula notation. Platform font names (PingFang SC / Microsoft YaHei / ...), the
# standard CSS function light-dark(), and generic words are NEVER discriminative: a no-pack
# session produces them from a standard stack. They are verified as application evidence via
# the [structural] Expected Markers below, not via the runner count.
discriminative_pattern: "--color-status-(active|blocked|waiting|done)|--font-family-(body|display|mono)|r_inner"
min_discriminative: 4
---

# Fixture: Panel Status Build

## Input Scenario

"给项目执行状态做一个面板页：顶部导航、一个带状态列的项目表格、几个指标卡和一个设置区。基础的颜色、间距、字号用 CSS 变量统一管理，手机窄屏上也要能正常看。"

## Expected Markers

When an AI agent processes the Input Scenario with this pack loaded,
the output MUST contain these markers (grep-verifiable):

1. **:root token block across the group prefixes** [structural]: the output defines its CSS variables in a `:root` block spanning at least 6 of the pack's 9 group prefixes (color/spacing/size/radius/shadow/duration/ease/font/text) — verifies the token architecture was applied, not just mentioned
   grep pattern: `:root|--color-|--spacing-|--radius-|--font-|--text-`
2. **Table narrow-width handling** [structural]: the output contains a table narrow-width section that declares column priorities (identity + status columns always visible) and moves collapsible columns into a row-expansion area instead of relying on whole-table horizontal scrolling
   grep pattern: `列优先级|行展开|column priorit|row expan`
3. **CJK font stack named coverage**: the font stacks name at least 2 of the CJK platform fonts as an explicit coverage segment
   grep pattern: `PingFang SC|Microsoft YaHei|Noto Sans CJK SC`
4. **Status expressed via the four status tokens with text labels** [structural]: statuses are expressed with the pack's four status token names, each status also carrying its text label （在做/卡住/等你/做完） — color never carries status alone
   grep pattern: `--color-status-(active|blocked|waiting|done)`

## Verification Command

```bash
grep -oE '--color-status-(active|blocked|waiting|done)|--font-family-(body|display|mono)|r_inner' {output_file} | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

Formal verdict: `pack-eval-runner.sh` single-fixture form against this fixture — the
runner's verdict text (`→ PASS` / `→ FAIL`) is the criterion; its exit code is advisory (always 0).

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "--color-status-active/blocked/waiting/done" (this pack's minted status token names — a no-pack output would have to invent the identical variable names to hit them)
- ✅ "--font-family-body/display/mono" (this pack's minted font token names)
- ✅ "r_inner" (this pack's concentric-formula notation)
- ❌ "PingFang SC / Microsoft YaHei" (platform font names — any standard CJK stack produces them; application evidence only, not discriminative)
- ❌ "light-dark()" (a standard CSS function; application evidence only)
- ❌ "面板/导航/表格" (words from the input scenario itself)
