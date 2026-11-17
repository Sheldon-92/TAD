# Token Architecture Rules — 三层架构与定版参数法
<!-- capability: design-foundation -->

> 令牌层的规则体（规范正文）。本件只存**方法**（参数法与架构纪律）；
> 一切值级数字只住 `token-values-space.md`（值草案），本件需引值处只写「取值见值草案」。

## 三层架构

1. When 你新增或引用令牌，do 先定它在哪一层：色板原语（编号色阶，只供映射）→ 语义令牌（组件实际消费的 CSS 自定义属性）→ 组件靶点（由组件名机械派生的稳定名）；组件不得直引原语。`check: judgment`
2. When 你给语义令牌命名，do 按「元素是什么」命名（角色/用途），不按明暗或色相命名；语义层固定 9 组前缀：`--color-*`、`--spacing-*`、`--size-*`、`--radius-*`、`--shadow-*`、`--duration-*`、`--ease-*`、`--font-*`、`--text-*`，组外新前缀先走包复审。`check: mechanical`
3. When 你派生组件靶点名，do 由组件名机械派生、kebab 化且逐词分开；严禁连写——主题作者按靶点名写键，连写错名静默失效、无错误无警告。`check: mechanical`

## 定版参数法（借方法，值自定）

4. When 你定间距，do 用 4px 网格、光学微调只许 2px 半步，并让间距随分组层级单调增大（label→input ＜ 组内 ＜ 组间 ＜ 区间），关系层级由间距表达。`check: judgment`
5. When 你定固定高元素尺寸，do 走 size 三档；可变高元素走 density（内边距）；两者协同至同一垂直韵律；交互命中区不低于值草案注明的下限。`check: judgment`
6. When 你定嵌套圆角，do 按同心公式 `r_inner = r_outer − gap` 由 calc() 派生内层值，不逐个手填；圆角按角色分档（inner／element／container／page／full）。`check: mechanical`
7. When 你定阴影，do 只用外阴影三档且与堆叠序绑定（base ＜ dropdown ＜ sticky ＜ overlay/modal ＜ toast ＜ tooltip）；状态环是独立 inset 族，不算海拔。`check: judgment`
8. When 你定字阶，do 用几何级数（ratio 1.2，base 取值见值草案）并以角色暴露（标题 1–6、body/large/label/code/supporting、display 1–3）；字重只用四档分工；行高吸附 4px 网格，正文行长留在 65–75ch 方法带。`check: judgment`
9. When 你定动效，do 按视觉分量分三带（微交互／进出场／持续大动效，取值见值草案）、全包统一单一缓动、只动画 transform 与 opacity；`prefers-reduced-motion` 时长塌缩为 0s。`check: judgment`
10. When 你给颜色令牌赋值，do 全部以 CSS `light-dark(浅值, 深值)` 成对给出；页面级背景令牌只许应用外壳消费，组件不直引页面背景。`check: mechanical`

## 维护规则（随包常驻，与 SKILL.md 跨切规则第一条同文互指）

11. When 你改动 tokens.css 中任何令牌值，do 同批重生成 tokens.json 并跑 `tools/check-token-parity.sh`，PARITY-OK 才许称改完；parity 红着不许收口该改动。`check: mechanical`
12. When 包复审开局，do 先复跑 parity 与 AC13 的编译器实跑各一遍，结果记入复审记录，再议跟版/改值。`check: mechanical`
