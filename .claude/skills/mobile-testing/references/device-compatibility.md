# Device Compatibility Testing

多设备多版本兼容性测试 — 屏幕尺寸、OS 版本、设备特性。

## Step 1: Research the Device Matrix

搜索目标市场的设备分布数据（web search）：
1. iOS 版本分布（Apple 官方 + StatCounter）
2. 目标地区的 iPhone 型号分布
3. 屏幕尺寸分布（SE/Mini/标准/Plus/Pro Max）

Example queries: `"iOS version" market share distribution 2026`, `"iPhone model" market share {目标地区} 2026`.

## Step 2: Define the Minimum Test Matrix

定义最小测试矩阵（参考 senaiverse 8 设备规则），表格列: 设备 | 屏幕 | OS 版本 | 为什么测。

iOS 最小矩阵（4 台）：
- iPhone SE 3 (4.7"): 最小屏幕，测布局压缩
- iPhone 15 (6.1"): 主流尺寸，基准设备
- iPhone 16 Pro Max (6.9"): 最大屏幕，测布局拉伸
- iPad mini (8.3"): 平板适配（如果支持）

OS 版本覆盖: 当前版本 + 前一个大版本（如 iOS 18 + iOS 17）。
Quality bar: 最小矩阵 ≥ 4 台设备，每台有"为什么测这台"的理由。

## Step 3: Execute Compatibility Tests

在模拟器上逐设备测试：
1. 用 `simctl` 启动每个设备模拟器
2. 安装 App → 运行核心流程 → 截图
3. 检查: 布局溢出、文字截断、触控目标、Safe Area
4. 每个设备截图保存为 `{device-name}.png`

如无法运行模拟器 → 生成兼容性检查清单 + 手动测试脚本。

## Step 4: Report

综合为设备兼容性报告（PDF），含矩阵表 + 截图对比 + 问题清单。

## Quality Criteria (pass/fail)

- 测试矩阵 ≥ 4 台设备（覆盖最小/主流/最大屏幕）
- 覆盖当前 OS + 前一个大版本
- 每台设备有截图证据
- 布局溢出/截断问题 = 0
- Fabricated compatibility results = FAIL
