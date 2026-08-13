# Firmware Documentation (固件文档)

> 引脚映射图、API 文档、数据流图、硬件接线图。Type A/Mixed: search → analyze → derive → generate.

## 1. Search — 收集文档素材

1. **从代码提取**:
   - config.h → 引脚定义表
   - 所有 .h 文件 → 公开函数列表
   - setup() → 初始化顺序
   - loop() → 主循环数据流
2. **从硬件参考**:
   - MCU datasheet 引脚图
   - 外设模块原理图
   - I2C/SPI 地址汇总
3. **从设计文档**:
   - 架构设计文档 → 架构概览
   - 低功耗设计文档 → 功耗预算
   - 通信设计文档 → 通信协议

## 2. Analyze — 确定文档结构

**引脚映射表**（从 config.h 自动生成）:

| GPIO | 板标记 | 功能 | 接口 | 外设 | 备注 |
|------|--------|------|------|------|------|
| 1 | D0 | Touch | — | 触摸按钮 0 | threshold>80000 |
| 5 | D4 | SDA | I2C | OLED + Haptic | 400kHz |
| 6 | D5 | SCL | I2C | OLED + Haptic | 400kHz |

**API 文档**（每个 .h 文件）:
- 函数签名 + 参数说明 + 返回值
- 调用前提条件（init 是否成功）
- 线程安全性（是否可从多个 task 调用）

**数据流图**:
- 传感器 → 数据处理 → 显示/传输
- 唤醒 → 采集 → 发送 → 睡眠（周期图）
- 用户操作 → 状态机转换 → UI 响应

## 3. Derive — 用 D2 生成图表

1. **引脚映射图**: MCU 中心，外设环绕，连线标注 GPIO 号
   ```d2
   mcu: ESP32-S3 {
     shape: rectangle
   }
   oled: SH1106 OLED {
     shape: rectangle
   }
   mcu -> oled: "I2C (SDA=GPIO5, SCL=GPIO6)\nAddr: 0x3C"
   ```
2. **数据流图**: 从输入到输出的完整数据路径
3. **状态机图**: 所有状态 + 转换条件
4. **电源状态图**: Active ↔ Sleep 转换 + 唤醒源

命令: `d2 input.d2 output.svg`

## 4. Generate — 生成最终文档

1. **README.md**: 项目概览 + 快速开始
   - 硬件清单（含购买链接如有）
   - 接线说明
   - 编译上传步骤
   - 简要使用说明
2. **Pin Map PDF**: Typst 生成引脚映射表 PDF
   `typst compile pin-map.typ pin-map.pdf`
3. **API Reference**: 每个模块的函数文档
4. **Architecture Diagram Set**: 所有 D2 图 → SVG

文档维护规则:
- config.h 变更 → 引脚映射表必须同步更新
- 新增 .h 文件 → API 文档必须补充
- 版本号变更 → README 和 CHANGELOG 更新

Pass/fail: see `quality-criteria.md` §Firmware Documentation. Reviewer checklist: see `review-checklist.md` §技术文档工程师.
