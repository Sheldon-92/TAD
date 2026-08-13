# Design Documentation（设计文档）

原理图文档 + 设计决策记录 + 制造指导。流程：search → analyze → derive → generate。

## 1. Search — 收集设计决策

收集整个设计过程中的所有决策：
1. 元器件选型决策（来自 component-selection）
2. 电源架构决策（来自 power-design）
3. PCB 参数决策（来自 pcb-layout）
4. 接口定义（GPIO 分配、通信协议选择）
5. 设计约束和妥协（[TRADEOFF] 标记的项目）
6. 版本变更历史（如果有迭代）

检查是否有未记录的决策（口头讨论但没写下来的）。
产出：design-decisions-raw.md

## 2. Analyze — 结构化文档组织

1. 设计概述（Design Overview）:
   - 系统框图
   - 功能需求 → 电路实现的映射
   - 关键性能指标（KPI）
2. 模块设计说明（Module Design Notes）:
   - 每个模块: 功能描述 + 电路原理 + 关键参数 + 设计理由
   - 电源模块: 拓扑选择理由 + 效率计算 + 热分析
   - MCU 模块: GPIO 分配表 + 外设配置 + Boot 模式
   - 显示模块: 接口定义 + 刷新时序 + 功耗模式
3. 设计决策记录（Design Decision Records, DDR）:
   - DDR-001: 为什么选 ESP32-C3 不选 S3
   - DDR-002: 为什么用 LDO 不用 DCDC
   - 每条 DDR: 背景 + 选项 + 决策 + 理由 + 影响
4. 已知问题与后续改进（Known Issues & TODO）:
   - 当前版本的已知限制
   - 下一版本计划改进的点

**质量门：文档必须覆盖 WHY（为什么这样设计），不仅是 WHAT（设计了什么）。**
产出：documentation-structure.md

## 3. Derive — 制造指导文档

1. PCB 制造规格：
   - 板层数、板厚、铜厚、表面处理
   - 最小线宽/间距、最小孔径
   - 特殊要求（阻抗控制、板材等级）
2. SMT 贴片要求：
   - 钢网厚度建议（0.12mm 标准）
   - 回流焊温度曲线要求
   - 需要手焊的元件清单（如有）
3. 测试要求：
   - ICT 测试点定义
   - 功能测试流程（上电 → 下载固件 → 自检）
   - 合格标准（电压测量点 + 允许范围）
4. 包装要求（如有）：
   - 外壳装配顺序
   - 标签/铭牌内容

**质量门：制造指导必须具体到可以直接交给工厂，不能有模糊描述。**
产出：manufacturing-guide.md

## 4. Generate — 完整文档包

1. 设计规格书（Design Specification）PDF:
   - 目录、设计概述、模块设计说明（含原理图截图/链接）
   - GPIO 分配表、电源设计说明、设计决策记录
2. 制造文件包（Manufacturing Package）:
   - Gerber 文件 + 钻孔文件
   - BOM (CSV + PDF)
   - 贴片坐标文件
   - 制造指导 PDF
3. 设计文件索引（File Index）:
   - 所有文件清单 + 版本 + 最后更新时间
   - 文件间依赖关系

文档版本号与原理图版本一致。
产出：design-documentation-package/

## Quality Bar（pass/fail）

- 设计规格书覆盖所有模块的功能/电路/参数说明
- 每个关键决策有 DDR（Decision Record）记录
- GPIO 分配表完整且与原理图一致
- 制造指导具体到可交付工厂（PCB 规格 + SMT 要求 + 测试流程）
- 文档版本与设计文件版本一致
- 编造数据 = FAIL。文档内容必须来自实际设计过程。
