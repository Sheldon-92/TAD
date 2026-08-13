# Schematic Design（原理图设计）

原理图绘制 + 模块化设计 + 电气规则检查。流程：select → execute → verify → optimize。

## 1. Select — 设计方案

1. 工具选择：KiCad 8+（推荐，开源免费）
2. 模块化划分：将电路按功能拆分为独立模块
   - 电源模块（充电 + 稳压 + 电池管理）
   - MCU 核心模块（MCU + 晶振 + 复位 + 下载口）
   - 显示模块（E-ink/OLED + 驱动 + 连接器）
   - 传感器/通信模块
   - 连接器/接口模块（USB、排针、测试点）
3. 层次原理图 vs 单页：>50 个元件推荐层次原理图
4. 网络标签命名规范：
   - 电源网络: VCC_3V3, VBUS_5V, VBAT, GND
   - 信号网络: SPI_MOSI, I2C_SDA, UART_TX
   - 大写 + 下划线，有意义的缩写

**质量门：模块划分必须基于功能和电气隔离原则，不是随意分组。**
产出：schematic-plan.md

## 2. Execute — 创建原理图

按模块创建原理图（每个模块一个 sheet 或区域）：

**电源模块必须包含：**
- USB 输入保护（ESD + 过流）
- 充电 IC 外围电路（参考 datasheet 典型应用）
- LDO/DCDC 输入输出电容（按 datasheet 推荐值）
- 电池接口 + 保护（如有）
- 电源指示 LED（充电状态）

**MCU 模块必须包含：**
- 去耦电容（每个 VDD pin 100nF + 共用 10uF）
- 晶振电路（负载电容按 datasheet 计算）
- 复位电路（RC 延时 + 按键）
- Boot/下载模式选择（ESP32: GPIO0 + EN）
- 未使用 GPIO 处理（内部上拉/下拉或外部拉低）

**显示模块必须包含：**
- FPC/排线连接器
- 驱动 IC 外围（如果显示模块不集成）
- 电平转换（如果需要）

**每个模块边界处必须有：**
- 测试点（关键电压/信号）
- 连接器或网络标签（模块间接口明确）

关键参数标注在原理图上（电阻值、电容值、电压标注）。
**质量门：每个 IC 的外围电路必须参考 datasheet 典型应用电路。自创电路 = 风险。**
产出：{project}.kicad_sch

## 3. Verify — ERC 检查

1. `kicad-cli sch erc --output erc-report.json --severity-all <schematic>`
2. 分析 ERC 报告：
   - ERROR: 必须全部修复（未连接 pin、短路、电源冲突）
   - WARNING: 逐条评估（未使用 pin 如果有意为之可标注 no-connect）
   - 目标: 0 ERROR, WARNING 全部评估
3. 手动检查项（ERC 检不出的）：
   - 去耦电容是否就近放置（原理图中标注位置要求）
   - 电源网络是否有正确的电压标注
   - 所有连接器 pin 定义是否与实物匹配
   - 晶振负载电容计算是否正确

**质量门：ERC 0 ERROR 是最低要求。WARNING 必须逐条有处理决策（fix/waive+理由）。**
产出：erc-report.json

## 4. Optimize — 优化与导出

1. 添加设计备注（关键计算过程、datasheet 参考页码）
2. 检查 BOM 一致性（原理图值 vs 实际采购型号）
3. 添加版本信息和修订记录（title block）
4. 导出 PDF 供评审：`kicad-cli sch export pdf -o schematic.pdf <schematic>`
5. 导出网表供 PCB：`kicad-cli sch export netlist -o netlist.xml <schematic>`
6. 生成模块连接框图（D2 可视化模块间信号流）

产出：schematic.pdf

## Quality Bar（pass/fail）

- 模块化设计：每个功能模块独立且接口明确
- ERC: 0 ERROR, 所有 WARNING 有处理记录
- 每个 IC 去耦电容完整（按 datasheet 推荐）
- 所有 GPIO 分配有记录（哪个 pin 连哪个功能）
- 关键信号有测试点
- 网络标签命名一致（大写 + 下划线）
- 编造数据 = FAIL。电阻/电容值必须有计算或 datasheet 依据。
