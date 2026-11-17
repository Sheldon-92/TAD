# Component Conventions — agent 可预测的组件约定
<!-- capability: design-foundation -->

> 约定层规则体：每条处方体＋`check:` 核验标记（mechanical／tool-flagged／judgment）。

## 总原则

1. When 你设计组件 API，do 给能力不给设计护栏（guidance over enforcement）：组件渲染消费方传入的值，设计意见住文档与示例，不在组件内拦截。`check: judgment`
2. When 你定义 prop，do 让每个 prop 独立：一个 prop 不许压掉另一个 prop 的输出；variant 只影响样式，不决定兄弟 prop 是否出现（物理裁剪类除外）。`check: judgment`
3. When 你新增 prop，do 先说出它控制的正交轴名；说不出轴名的，是设计配方不是原语，不进 API。`check: judgment`
4. When 你写 prop 说明，do 只描述组件做什么，不描述某个设计稿怎么排；光学微调归令牌/主题层。`check: judgment`

## 命名与 prop

5. When 你命名组件，do 按解剖式 `<Namespace><Variant><Type><Postfixes>`，仅 Type 必填，不加产品前缀。`check: mechanical`
6. When 你派生组件靶点名，do 由组件名机械派生、kebab 化逐词分开，严禁连写（连写静默失效——主题作者按靶点名写键，错名无错误无警告）；容器以部件命名、共享原语共享名，两例外须注明。`check: mechanical`
7. When 你命名回调，do 用 `on{Verb}{Scope?}`（单义省 Scope）；异步动作 `{verb}Action`；主值变更统一 `onChange`；开/关行为统一 `onOpenChange`；无图层组件不许有可见性 prop。`check: mechanical`
8. When 你命名布尔与方向 prop，do 状态用 `is` 前缀、功能用 `has` 前缀；方向用 `start`/`end` 不用 `left`/`right`；枚举值与令牌名对齐（如 size 的 sm/md/lg ↔ `--size-element-*`）。`check: mechanical`
9. When 你定 prop 必填性，do 行为与结构类 prop 必填，表现类 prop 可选且带安全默认。`check: judgment`

## 组合、状态与判例

10. When 你用 slot，do 遵守三规则：slots 直通不包层、不上提子组件 prop、每 slot 同一契约。`check: judgment`
11. When 你提供行为复用，do 用 hook 不用包装组件；确需组件版时，组件是 hook 的薄壳。`check: judgment`
12. When 你提供样式逃生舱，do 按成文优先级：主题覆盖 ＞ 类名追加 ＞ 内联；优先级须成文且唯一，不另设第二套顺序。`check: judgment`
13. When 你表示状态，do 先成套设计（rest/hover/focus/active/disabled/loading/selected）并先查既有成套表示再新造；**颜色永不单独表意**——每状态必配文字标签＋形状/图标标记（状态四件的非颜色通道见 token-values-space.md）。`check: judgment`
14. **判例：Switch 视觉隐藏 checkbox**。场景：Switch 组件以视觉隐藏的原生 checkbox 承载状态，朴素审计见「无可见输入」易误判为缺交互/不可达。裁定：视觉隐藏原生输入是本系统的批准形态，成立条件三项——(a) 隐藏输入仍可聚焦、可键盘操作且焦点可见（焦点落在可见轨道上呈现）；(b) 可见轨道/滑块的状态呈现由该输入的 `:checked` 单一来源驱动，不另设平行状态；(c) label 关联完整，辅助技术可达。审计标记：审计与清单对此形态打 `visually-hidden-input` 标记并按 (a)(b)(c) 三项核，不以「输入不可见」记缺陷。本判例类推适用于 Checkbox/Radio 的隐藏输入形态。`check: tool-flagged`

## 正本验真与分叉

15. When 你消费 design-foundation 令牌，do 先核该件 tokens.css 文件头的 `pack-version:` 行在盘，并跑 parity 至 PARITY-OK；两项任一不合，该件不称正本。`check: mechanical`
16. When 你在下游装机副本上本地改过 tokens.css，do 认该件为**分叉**而非正本：分叉值只对该仓本地有效，须在该仓文档中显名分叉与改动点；跨仓引用、评审与对账一律以框架仓未改且 parity 净的正本为准，分叉不许以「design-foundation 正本」名义被引用。`check: judgment`
