# Interface Index — design-foundation 清单（一行一件）
<!-- capability: design-foundation -->

## 令牌组（9，正本 `../tokens/tokens.css`，镜像 `../tokens/tokens.json`）

- group: color — 语义颜色（含状态四件），全 light-dark() 成对
- group: spacing — 4px 网格间距
- group: size — 固定高元素三档
- group: radius — 圆角五档（同心公式派生）
- group: shadow — 外阴影三档绑堆叠序
- group: duration — 动效三带
- group: ease — 单一缓动
- group: font — 三字体栈（结构定版）
- group: text — 字阶/行高/字重

## 配方（12，全文 `pattern-recipes-space.md`）

- Recipe: Top Nav
- Recipe: Side Nav
- Recipe: Shell Nav
- Recipe: Analytics Dashboard
- Recipe: Data Dashboard
- Recipe: Project Status Dashboard
- Recipe: Service Monitoring Dashboard
- Recipe: Filterable Table
- Recipe: Grouped Table
- Recipe: Searchable Table
- Recipe: Settings Panels
- Recipe: Card Grid

## 约定条目

- conventions: 条目 1–16（全文 `component-conventions-rules.md`；含判例 14 Switch 视觉隐藏 checkbox、验真 15、正本分叉 16）

## 判别力 fixture

- fixture: `../examples/panel-status-build.md`（带包/不带包双半边判别，pack-eval-runner 判定）

## 参考源钉版

- reference-source: Astryx 0.7.x（设计锚 0.7.12，2026-11-08）；跟版只在包复审时议
