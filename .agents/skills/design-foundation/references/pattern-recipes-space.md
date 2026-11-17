# Pattern Recipes — Space 面板配方（v0 子集 12 条）
<!-- capability: design-foundation -->

> 模式层：52 个源模板中取面板相关的 12 条，收为我们的话的参数/结构规格（不搬模板源码）。
> 每条配方字段固定五项：用途／槽位结构／消费令牌／窄屏行为／不用情形。
> 窄屏总口径见文末「窄屏口径」节；断点常量 `--breakpoint-narrow` = 容器宽 640px（值草案，见 token-values-space.md）。

## Recipe: Top Nav

- 用途：顶部导航应用框（pilot 配方——本子集的字段完备性以本条为样，其余 11 条同模板）。
- 槽位结构：品牌位（左）／主导航条目（中）／主动作＋溢出菜单按钮（右）；高度走 `--size-element-lg`。
- 消费令牌：`--color-bg-container`、`--color-text-primary`、`--spacing-4`、`--shadow-low`、`--font-family-body`。
- 窄屏行为：容器宽低于断点时条目收进溢出菜单（菜单按钮常驻），品牌位＋主动作保留；mega-menu 改全宽纵向堆叠面板；禁止条目横向滚动；条目文字不许词中截断。
- 不用情形：无顶栏需求的沉浸式单页；导航层级深到需要双轴时改用 Shell Nav。

## Recipe: Side Nav

- 用途：单左栏应用框（纵向导航为主轴）。
- 槽位结构：导航列（分组标题＋条目，当前条目以状态环/填充标记）／内容区。
- 消费令牌：`--color-bg-container`、`--color-fill-control`、`--spacing-3`、`--radius-inner`、`--font-family-body`。
- 窄屏行为：低于断点时导航列收为顶部条＋溢出菜单（口径同 Top Nav），内容区占满容器宽。
- 不用情形：顶栏已承载全部一级导航时不用双导航并存。

## Recipe: Shell Nav

- 用途：双轴导航应用框（顶栏＋侧栏并用）。
- 槽位结构：Top Nav 槽位＋Side Nav 槽位组合，内容区居右下；两轴的当前态标记须同口径。
- 消费令牌：同 Top Nav／Side Nav 两条之和，另加 `--shadow-med`（轴交界层级）。
- 窄屏行为：低于断点时侧栏先收（变溢出菜单），顶栏按 Top Nav 窄屏口径再收。
- 不用情形：导航只有一轴时用单轴配方，不预支双轴复杂度。

## Recipe: Analytics Dashboard

- 用途：三段式分析页（头条指标＋图表＋支撑表）。
- 槽位结构：头条指标行（3–5 个指标卡）／主图区／支撑表区，自上而下。
- 消费令牌：`--spacing-6`、`--radius-container`、`--shadow-low`、`--text-display-size`、`--font-family-display`。
- 窄屏行为：低于断点时网格塌为单列，头条指标在前（首屏即答案），图表次之、支撑表最后。
- 不用情形：指标需逐项对比环比时改用 Data Dashboard。

## Recipe: Data Dashboard

- 用途：对比型分析页（火花线＋环比）。
- 槽位结构：指标卡阵列（每卡：现值＋火花线＋环比徽标）／明细表区。
- 消费令牌：`--font-family-mono`（数字对齐）、`--color-status-*`（涨跌不用状态色，用强调色＋箭头符号）、`--spacing-4`。
- 窄屏行为：卡阵列塌为单列；明细表按 Table 共用窄屏口径收列。
- 不用情形：无时间序列数据时不用火花线槽位，改用 Analytics Dashboard。

## Recipe: Project Status Dashboard

- 用途：项目状态页（完成度、时间轴、按负责人进度表、风险清单）。
- 槽位结构：状态头条（总完成度＋四状态计数）／时间轴／按负责人进度表／风险清单。
- 消费令牌：`--color-status-active/blocked/waiting/done`（每状态必配文字标签＋形标记）、`--radius-container`、`--spacing-6`。
- 窄屏行为：头条计数在前；进度表按 Table 共用窄屏口径收列（状态列必显）；时间轴转纵向。
- 不用情形：单一项目详情页不用总览槽位，改走内容页常规排版。

## Recipe: Service Monitoring Dashboard

- 用途：常开监控页（状态色指标块＋时间图＋告警列）。
- 槽位结构：状态指标块行／时间图主区／告警列（右或下）。
- 消费令牌：`--color-status-*`、`--duration-fast`（刷新过渡）、`--font-family-mono`、`--color-bg-page`。
- 窄屏行为：指标块单列；告警列移至时间图下方；不因窄屏丢弃告警槽位。
- 不用情形：非实时数据页不用常开刷新口径。

## Recipe: Filterable Table

- 用途：渐进筛选表＋详情面板。
- 槽位结构：筛选条（渐进展开）／表格主体（列优先级声明）／行选中后详情面板。
- 消费令牌：`--size-element-md`（筛选控件）、`--color-border-default`、`--radius-element`、`--spacing-3`。
- 窄屏行为：按 Table 共用窄屏口径：身份列与状态列必显，可收列移入行展开区；详情面板改全宽抽屉。
- 不用情形：数据量小到无需筛选（≤一屏）时用普通表格，不加筛选条。

## Recipe: Grouped Table

- 用途：分组可折叠表。
- 槽位结构：分组标题行（可折叠，带组内计数）／组内数据行（列优先级声明）。
- 消费令牌：`--color-fill-control`（组标题底）、`--color-border-default`、`--text-heading-size`、`--spacing-2`。
- 窄屏行为：按 Table 共用窄屏口径收列；分组标题行保持整行可点（命中区 ≥44px）。
- 不用情形：分组维度不稳定（组数随筛选剧烈变化）时改用 Filterable Table。

## Recipe: Searchable Table

- 用途：搜索＋逐列筛选表。
- 槽位结构：搜索框／列筛选行／表格主体（列优先级声明）／合计行。
- 消费令牌：`--size-element-md`、`--font-family-mono`（数字列）、`--color-text-secondary`（合计标注）。
- 窄屏行为：按 Table 共用窄屏口径收列；合计行在筛选时须自标「部分」。
- 不用情形：无全文检索需求时用 Filterable Table。

## Recipe: Settings Panels

- 用途：常驻分节设置面板。
- 槽位结构：分节标题＋节内表单行（标签列＋控件列）；保存动作固定于节末或面板末。
- 消费令牌：`--spacing-6`（区间）、`--size-element-md`（控件）、`--radius-container`、`--color-border-default`。
- 窄屏行为：标签列与控件列改上下堆叠；分节不合并、不藏节。
- 不用情形：一次性向导流程不用常驻面板，改走分步页。

## Recipe: Card Grid

- 用途：可搜索卡片网格。
- 槽位结构：搜索/筛选条／卡片网格（卡内：标题＋状态标记＋主指标＋进入动作）。
- 消费令牌：`--radius-container`、`--shadow-low`、`--color-status-*`（卡上状态必配文字标签）、`--spacing-4`。
- 窄屏行为：网格塌为单列；搜索条常驻顶部。
- 不用情形：条目需逐行对比数值时改用表格类配方。

## 窄屏口径（定版）

阈值以**容器宽**计（与 web-ui-design 的 container queries 优先同向），断点常量 640px（值草案）：

- **TopNav 类**：低于断点时导航条目收进溢出菜单（菜单按钮常驻），品牌位＋主动作保留；mega-menu 改全宽纵向堆叠面板；禁止导航条目横向滚动；条目文字不许词中截断。
- **Table 类共用**：每列在配方中声明优先级——身份列（第一列）与状态列为必显，其余为可收；低于断点时可收列移入行展开区（点行展开看全），整表横向滚动不许作主要策略；数字列右对齐在收展前后保持；合计行在筛选时须自标「部分」。
- **Dashboard 类共用**：低于断点时网格塌为单列，头条指标在前（首屏即答案），图表次之、支撑表最后。
