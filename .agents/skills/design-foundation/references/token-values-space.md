# Token Values — v0 Space 值草案
<!-- capability: design-foundation -->

> **状态：v0 定版值 — 2026-11-08 经 Gate 4 用户亲验通过（值照草案定版）；升常设规范未定，待下一个 Space 试点后另行决定。**
> 本件是 v0 全部值级数字的唯一住所（规则体只存方法，见 `token-architecture-rules.md`）。
> 值的正本载体是 `../tokens/tokens.css`；本件逐组列草案值与派生依据，两面须同值（parity 守 CSS/JSON 两面，本件与 CSS 的一致由评审抽核）。

## color（全部 light-dark() 成对；中性带色相 250、强调带色相 235，OKLCH 自建）

| 令牌 | 草案值 | 派生依据 |
|---|---|---|
| `--color-bg-page` | light-dark(oklch(0.985 0.002 250), oklch(0.16 0.008 250)) | 页面级背景，只许应用外壳消费 |
| `--color-bg-container` | light-dark(oklch(1 0 0), oklch(0.20 0.008 250)) | 容器底（中性四角色之二） |
| `--color-fill-control` | light-dark(oklch(0.955 0.004 250), oklch(0.26 0.010 250)) | 自包含元素填充（中性四角色之一） |
| `--color-track-subtle` | light-dark(oklch(0.92 0.005 250), oklch(0.30 0.010 250)) | 细轨道（中性四角色之三） |
| `--color-overlay-interactive` | light-dark(oklch(0.30 0.02 250 / 0.08), oklch(0.90 0.01 250 / 0.12)) | 交互叠加（中性四角色之四，半透明） |
| `--color-text-primary` | light-dark(oklch(0.24 0.01 250), oklch(0.93 0.005 250)) | 正文对页面背景按 WCAG AA 口径（小样阶段核） |
| `--color-text-secondary` | light-dark(oklch(0.45 0.012 250), oklch(0.72 0.008 250)) | 次级文字，与主文字拉开一档明度 |
| `--color-text-disabled` | light-dark(oklch(0.65 0.008 250), oklch(0.50 0.008 250)) | 禁用态，低彩度 |
| `--color-border-default` | light-dark(oklch(0.88 0.005 250), oklch(0.32 0.010 250)) | 常规分隔/描边 |
| `--color-border-strong` | light-dark(oklch(0.72 0.008 250), oklch(0.45 0.012 250)) | 强分隔（焦点邻接/表头） |
| `--color-accent-primary` | light-dark(oklch(0.55 0.14 235), oklch(0.70 0.12 235)) | 强调色一带（面板/数据语境），与状态四色分色相/彩度可辨 |
| `--color-accent-hover` | light-dark(oklch(0.48 0.15 235), oklch(0.76 0.11 235)) | 强调色悬停变体 |
| `--color-focus-ring` | light-dark(oklch(0.60 0.16 235), oklch(0.75 0.13 235)) | 焦点环，与强调同带、高彩度 |
| `--color-status-active` | light-dark(oklch(0.60 0.15 150), oklch(0.72 0.13 150)) | 状态「在做」绿带 |
| `--color-status-blocked` | light-dark(oklch(0.55 0.19 25), oklch(0.68 0.16 25)) | 状态「卡住」红带 |
| `--color-status-waiting` | light-dark(oklch(0.68 0.15 75), oklch(0.76 0.13 75)) | 状态「等你」琥珀带 |
| `--color-status-done` | light-dark(oklch(0.52 0.015 250), oklch(0.68 0.012 250)) | 状态「做完」低彩度中性，以低彩度与前三者及强调色区分 |

## 状态四件的非颜色通道（与上行成套，缺一不可）

| 状态令牌 | 文字标签 | 形状/图标标记（草案形态） |
|---|---|---|
| `--color-status-active` | 在做 | 半环 ◐ |
| `--color-status-blocked` | 卡住 | 方块 ■ |
| `--color-status-waiting` | 等你 | 铃形标记（文本面用「铃」字形符号或点+标签） |
| `--color-status-done` | 做完 | 勾 ✓ |

## spacing / size / radius / shadow / duration / ease

| 令牌 | 草案值 | 派生依据 |
|---|---|---|
| `--spacing-1` … `--spacing-12` | 4 / 8 / 12 / 16 / 24 / 32 / 48 px | 4px 网格，随分组层级单调增大 |
| `--size-element-sm/md/lg` | 28 / 36 / 44 px | 固定高元素三档，与 spacing 同韵律 |
| 交互命中区下限 | 44px | 与 `--size-element-lg` 对齐（草案） |
| `--radius-element` | 10px | 元素档基准（外层） |
| `--radius-inner` | calc(var(--radius-element) - 4px) | 同心公式 r_inner = r_outer − gap，gap 取 `--spacing-1` |
| `--radius-container` | 14px | 容器档 = element + gap |
| `--radius-page` | 20px | 页面档 |
| `--radius-full` | 999px | 全圆档 |
| `--shadow-low/med/high` | 见 tokens.css | 外阴影三档绑堆叠序 base/dropdown 起、sticky、overlay/modal |
| `--duration-fast/medium/slow` | 120 / 220 / 360 ms | 视觉分量三带：微交互／进出场／持续大动效 |
| `--ease-standard` | cubic-bezier(0.2, 0, 0, 1) | 全包统一单一缓动 |

## text（字阶 base 14 × ratio 1.2 几何级数）

| 令牌 | 草案值 | 派生依据 |
|---|---|---|
| `--text-supporting-size` | 12px | base 下探一档（辅助文字） |
| `--text-body-size` | 14px | 字阶 base |
| `--text-body-large-size` | 17px | 14 × 1.2 ≈ 17 |
| `--text-heading-size` | 20px | 17 × 1.2 ≈ 20 |
| `--text-title-size` | 24px | 20 × 1.2 ≈ 24 |
| `--text-display-size` | 35px | 24 × 1.2² ≈ 35 |
| `--text-body-line-height` | 24px | 行高吸附 4px 网格；正文行高比 24/14 ≈ 1.7，覆盖下方 CJK 下限 |
| `--text-weight-regular/medium/semibold/bold` | 400 / 500 / 600 / 700 | 字重四档分工 |

**行高口径（本件内定，取代任何外引）**：正文行高的一般目标为 1.5；CJK 正文行高下限为 1.6（CJK 字形需要大于 Latin 的行距）；两者并存时**以语言段取大者**。本草案 `--text-body-line-height: 24px` 对 14px 正文即 ≈1.7，两口径同时满足。

## 字体栈（结构定版／取值草案）

结构（定版）：每栈三段——Latin 段具名选定一款＋具名后备 → CJK 段按平台具名列全（`"PingFang SC"`、`"Hiragino Sans GB"`、`"Microsoft YaHei"`、`"Noto Sans CJK SC"`、`"Source Han Sans SC"`）→ 通用族名殿后。**字体栈每个区段具名；禁止以未具名的系统回退充当中文方案**——参考源字体无中文字形、「中文走系统回退」在本包是明令排除项，不是默认。

取值（草案，待 Gate 4 亲验）：

| 令牌 | Latin 选定（草案） | 选型依据 |
|---|---|---|
| `--font-family-body` | "Fira Sans" ＋后备 "Liberation Sans" | 开源人文无衬线，数据/面板语境可读性好，非平台默认脸 |
| `--font-family-display` | "Space Grotesk" ＋后备 "Fira Sans" | 几何感标题脸，与正文拉开角色 |
| `--font-family-mono` | "JetBrains Mono" ＋后备 "IBM Plex Mono"，CJK 等宽后备 "Noto Sans Mono CJK SC" | 等宽数字对齐（表格/指标） |

与 web-ui-design Anti-Slop Rule 1 的关系（映射结论，HANDOFF §4.6 第 7 面）：Rule 1 禁的是以 Inter/Roboto/Arial/system-ui 作**未具名的 Latin 主字体**；本包要求的是 **CJK 区段具名覆盖**，且 Latin 段同样具名选定（非 Rule 1 名单）。两者不冲突：具名 CJK 段是覆盖义务，不是把 system-ui 当主字体。

## 窄屏断点常量

`--breakpoint-narrow`（配方常量，非 CSS 变量）：容器宽 **640px**（草案）——低于此值按 `pattern-recipes-space.md` 窄屏口径收列/收菜单。
