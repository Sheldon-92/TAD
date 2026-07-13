# Human-AI Pair Testing (4D Protocol, Mobile)

4D Protocol 人机协作测试 — AI 分析截图 + 人类判断手感。

## Step 1: Prepare the Session

1. App 在模拟器或真机上运行
2. `simctl` 或真机截图工具就绪
3. 确定焦点: 新功能/变更页面/高风险流程
4. 人类决定: 先探索什么

移动端特有 round 类型（参考 Maestro Skill 研究）：
- **手势交互 round**: 滑动/长按/下拉的感觉
- **网络状态 round**: 弱网/离线时的行为
- **状态转换 round**: 前后台切换、旋转、中断（来电）
- **键盘交互 round**: 键盘弹出时布局变化

## Step 2: Discover

AI 分析 + 人类操作：
1. 人类操作 App，AI 分析截图
2. 截图: `simctl io booted screenshot round-{N}.png`
3. AI 检查: 布局问题、对齐、溢出、截断、触控目标
4. 人类检查: 动画手感、手势流畅度、响应速度"体感"

## Step 3: Discuss + Decide

每个发现当场决定: **Fix Now / Fix Later / Won't Fix**。
移动端特有判断: "这个动画卡顿是 1 帧还是持续的？人类说了算。"
严重度由人类决定 — 不是 AI 单独判断。

## Step 4: Deliver

生成测试报告: 发现 + 截图 + 决策 + 修复建议。

## Quality Criteria (pass/fail)

- 每轮有截图证据
- 严重度由人类决定（不是 AI 单独判断）
- Fix Now 有即时 handoff
- 覆盖移动端特有场景（手势/网络/状态转换）
- Fabricated findings or screenshots = FAIL
