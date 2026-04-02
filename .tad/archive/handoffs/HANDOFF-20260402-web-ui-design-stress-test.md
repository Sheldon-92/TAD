# Mini-Handoff: Web UI Design Domain Pack — 压力测试

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Type:** Quality Stress Test

---

## 目的

Todo App 测试太简单，没有暴露分析层的真实深度。用一个复杂场景重新测试。

## 测试议题

**"一个面向独立开发者的 SaaS 项目管理工具"**

为什么这个议题够复杂：
- **信息架构复杂**：项目列表 → 看板 → 时间线 → 设置 → 团队 → 计费，至少 6 个一级页面
- **多种用户角色**：Owner / Admin / Member / Viewer，权限不同导致 UI 不同
- **交互复杂**：拖拽排序、实时协作、键盘快捷键、批量操作
- **竞品多**：Linear, Jira, Notion, Asana, Tractive — 搜索能找到大量真实设计参考
- **响应式挑战**：看板在手机上怎么展示？时间线在小屏怎么交互？
- **视觉差异化**：市场已有大量工具，视觉风格需要有理由地做差异化

## 执行方式

用 Agent tool spawn 测试 agent，逐个 capability 执行。读取 `.tad/domains/web-ui-design.yaml`，按 steps 走。

### 重点检查这些"深度陷阱"

| Capability | Todo App 没测到的 | 这次必须出现的 |
|-----------|-----------------|--------------|
| information_architecture | 只有一个列表页 | 6+ 页面的站点地图 + 导航层级决策（为什么用侧边栏不用顶栏？） |
| wireframing | 一个页面一种布局 | 多页面不同布局 + 3 方案对比必须有实质差异（不是颜色不同） |
| visual_design | "蓝色+白色"无需思考 | 必须分析竞品视觉风格后做差异化选择（为什么选这个色系？） |
| interaction_design | 简单的增删改查 | 拖拽、实时协作、快捷键、批量操作的状态图 |
| responsive_design | Todo App 本身就简单 | 看板→手机端怎么变？时间线→小屏怎么交互？ |
| design_system | 只需要几个组件 | 10+ 组件的完整清单（Button/Card/Modal/Toast/Table/Sidebar/...） |
| usability_review | pa11y 够用 | 多角色权限下的 UI 差异审查 + 认知负荷评估 |

### 质量评估标准

| # | 维度 | PASS | FAIL |
|---|------|------|------|
| 1 | 信息架构有决策推导 | "选侧边栏因为竞品分析发现 Linear/Notion 都用侧边栏且用户习惯已形成" | "用侧边栏" |
| 2 | 线框图方案有实质差异 | 3 个方案在布局结构/信息层级/交互模式上不同 | 3 个方案只是颜色/字体不同 |
| 3 | 视觉设计有竞品依据 | "Linear 用紫色、Notion 用黑白、Asana 用橙色 → 我们选深蓝绿差异化" | 凭空选色 |
| 4 | 交互设计覆盖复杂场景 | 有拖拽状态图（idle→hover→drag→drop→reorder）| 只写"支持拖拽" |
| 5 | 响应式有断点决策 | "看板在 <768px 变为垂直列表，因为横向滑动 column 测试 PPI 不合理" | "手机端适配" |
| 6 | 组件清单 ≥10 个 | 每个组件有变体（Primary/Secondary/Ghost）和使用场景 | 只列组件名 |
| 7 | 可用性审查发现真问题 | "Owner 和 Viewer 看到同样的操作按钮但点击后 Viewer 报错 → 应该隐藏" | "界面清晰" |

### 执行完汇总

```markdown
## 压力测试结果

| # | 维度 | 结果 | 证据 |
|---|------|------|------|
| 1 | IA 决策推导 | PASS/FAIL | {具体说明} |
| 2 | 方案实质差异 | PASS/FAIL | ... |
| 3 | 视觉竞品依据 | PASS/FAIL | ... |
| 4 | 交互复杂场景 | PASS/FAIL | ... |
| 5 | 响应式断点 | PASS/FAIL | ... |
| 6 | 组件 ≥10 | PASS/FAIL | ... |
| 7 | 可用性真问题 | PASS/FAIL | ... |

总分: X/7
```

**≥5/7 = pack 深度合格。<5/7 = 需要迭代加深分析步骤。**

### 清理

测试完删除 `.tad/active/research/saas-pm-tool/`。

---

## AC

- [ ] 7 个 capability 全部执行
- [ ] 产出文件 ≥ Todo App 测试（20 个）
- [ ] 压力测试 ≥5/7 PASS
- [ ] 汇总报告完整
