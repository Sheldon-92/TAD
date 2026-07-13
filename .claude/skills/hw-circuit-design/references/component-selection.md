# Component Selection（元器件选型）

选择核心元器件 + 替代方案 + 供应链风险评估。流程：search → analyze → derive → generate。

## 1. Search — 收集候选元器件

基于功能需求，搜索每个功能模块的候选元器件：

1. MCU: 搜索符合 GPIO/外设/功耗/封装要求的芯片（ESP32-C3/S3 系列优先）
2. 显示: 搜索显示模块（E-ink 型号、OLED 型号、驱动 IC）
3. 电源: 搜索 LDO/DCDC/充电 IC（输入输出电压、电流、静态功耗）
4. 传感器/通信: 搜索项目需要的传感器和通信模块
5. 被动元件: 搜索关键被动元件（晶振、ESD 保护、滤波电容）

**每个类别至少找 3 个候选器件。**
来源：乐鑫官方文档、LCSC、DigiKey、Mouser、厂商 datasheet。
产出：component-candidates.md

## 2. Analyze — 候选对比

对每个功能模块的候选元器件做对比分析表：

| 参数 | 候选A | 候选B | 候选C |
|------|-------|-------|-------|
| 型号 / 关键规格 / 封装 / 单价(1K) / 供货状态 / 功耗(active/sleep) | ... | ... | ... |

重点评估维度：
1. 电气兼容性：电压/电平/接口是否匹配
2. 功耗：active 和 sleep 模式电流
3. 封装：是否适合目标 PCB 尺寸和手焊/回流焊
4. 供应链：LCSC 有货 > 仅 DigiKey > 仅厂商直供
5. 社区支持：是否有 Arduino/ESP-IDF 驱动库

数据必须来自 datasheet，推测标注 [INFERRED]。
**质量门：每个参数必须注明出处（datasheet 页码或 URL）。编造数据 = FAIL。**
产出：component-analysis.md

## 3. Derive — 选型决策

1. 每个功能模块选择 primary + backup 器件
2. Primary 选择理由（必须引用具体参数数据）
3. Backup 器件的 pin-compatible 程度（完全兼容 / 需改 PCB / 需改软件）
4. 标注供应链风险：
   - LOW: 多供应商 + LCSC/DigiKey 都有 + 非停产
   - MEDIUM: 单供应商 或 仅一个渠道有货
   - HIGH: 停产预警 / 长交期(>12周) / 仅厂商直供
5. 关键设计约束记录（如 ESP32-C3 的 GPIO 数量限制、E-ink 刷新时序要求）

如果找不到满足所有要求的器件 → 诚实标注 [TRADEOFF] 并说明妥协了什么。
**质量门：选型决策必须有数据支撑。"我觉得这个好" = FAIL。**
产出：component-selection.md

## 4. Generate — 选型报告

1. 选型总览表（所有选定器件 + backup）
2. 供应链风险矩阵图（D2 可视化）
3. 关键器件 datasheet 链接汇总
4. 设计约束与注意事项清单
5. 初步成本估算（基于 1K 数量单价）

产出：component-selection-report.pdf

## Quality Bar（pass/fail）

- 每个功能模块至少 3 个候选器件对比
- 每个选定器件有 primary + backup（pin-compatible 程度标注）
- 参数数据来自 datasheet，有页码或 URL 引用
- 供应链风险评估（LOW/MEDIUM/HIGH）+ 至少一个非 LCSC 渠道
- 功耗数据包含 active 和 sleep 模式
- 电容降额：陶瓷电容额定电压 ≥ 工作电压×2（50% derating），电解电容 ≥ 工作电压×1.25（80% derating）— 来源: kicad-happy
- 晶振精度标注：ESP32 要求 ±10ppm，温度范围内仍满足 — 来源: Espressif HW Design Guidelines
- 编造数据 = FAIL。推测标注 [INFERRED]，缺失标注 [NOT FOUND]
