# PCB Layout（PCB 布局与布线）

PCB 布局布线 + 设计规则 + 制造要求。流程：select → execute → verify → optimize。

## 1. Select — 确定 PCB 参数

1. 板层数：
   - 2 层: 简单设计、成本优先（ESP32 模组方案可用）
   - 4 层: 复杂设计、EMC 要求高（ESP32 芯片方案推荐）
2. 板厚: 1.6mm（标准）/ 0.8mm（紧凑）/ 1.0mm（折中）
3. 最小线宽/间距: 6mil/6mil（标准）/ 4mil/4mil（精细，成本+30%）
4. 过孔: 0.3mm 钻孔 / 0.6mm 焊盘（标准）
5. 表面处理: HASL（便宜）/ ENIG（平整，适合 BGA/FPC）
6. 板框尺寸: 基于外壳和连接器位置确定
7. 铜厚: 1oz（标准信号）/ 2oz（大电流 >1A）

设计规则基于目标制造商能力（嘉立创 / PCBWAY）。输出 DRC 规则文件。
**质量门：PCB 参数必须基于制造商能力规格，不是随意选。**
产出：pcb-parameters.md

## 2. Execute — 布局布线

**布局优先级（先放后连线）：**
1. 连接器位置（USB、FPC、排针 — 由外壳决定）
2. 关键 IC 位置（MCU 居中，电源 IC 靠近输入）
3. 去耦电容紧贴对应 IC 的 VDD pin（越近越好）
4. 晶振紧贴 MCU，走线尽量短
5. 大电流路径要宽走线（电源 >20mil，信号 8-10mil）

**布线规则：**
- 电源走线: ≥20mil (0.5mm)，大电流 ≥40mil (1mm)
- 信号走线: 8-10mil (0.2-0.25mm)
- 差分对: USB D+/D- 等阻抗匹配（90Ω ±10%）
- 地平面: 尽量完整，避免割裂（特别是 MCU 和晶振下方）
- 禁止走线从晶振下方穿过
- 电源和信号走线不要平行长距离

**分区原则：**
- 模拟区（传感器）和数字区（MCU）分开
- 电源区靠近输入连接器
- 高频区（天线、晶振）远离噪声源
- ESP32 天线区域下方禁止铺铜和走线

**质量门：布局必须遵循信号完整性和电源完整性原则。随意摆放 = EMC 风险。**
产出：{project}.kicad_pcb

## 3. Verify — DRC 检查

1. `kicad-cli pcb drc --output drc-report.json <board.kicad_pcb>`
2. 检查项目：
   - 线宽违规（信号线 < 最小线宽）
   - 间距违规（走线间距 < 最小间距）
   - 未连接网络（ratsnest）
   - 过孔违规（孔径/焊盘不符合规则）
   - 焊盘间距违规（元件太近无法焊接）
3. 手动检查（DRC 检不出的）：
   - 天线净空区是否满足（ESP32 天线 15mm 范围无铺铜）
   - 去耦电容是否真的在 IC 旁边（不仅原理图上连着）
   - FPC 连接器方向和 pin 序是否正确
   - 安装孔位置是否与外壳匹配
4. 目标: 0 DRC 违规

**质量门：DRC 0 violation 是最低要求。天线净空和去耦电容位置必须人工复查。**
产出：drc-report.json

## 4. Optimize — 制造优化

1. 铜皮填充（copper pour）: GND 铺铜覆盖空白区域
2. 丝印优化：元件标号可读、不被焊盘遮挡、方向统一
3. 添加丝印信息: 项目名、版本号、日期、生产商 logo 区域
4. 坐标原点设置: 左下角对齐制造要求
5. 导出制造文件：
   - Gerber: `kicad-cli pcb export gerbers -o gerber/ <board>`
   - 钻孔: `kicad-cli pcb export drill -o gerber/ <board>`
   - 贴片坐标: `kicad-cli pcb export pos -o pick-place.csv <board>`
6. 生成 3D 渲染预览（如果有 3D 模型）
7. 制造商 DFM 检查提交（嘉立创/PCBWAY 在线 DFM）

产出：gerber/

## Quality Bar（pass/fail）

- DRC: 0 violation（线宽、间距、连接性全部通过）
- 去耦电容距离 IC VDD pin ≤7mm（理想 ≤3mm）— 来源: kicad-happy 42-rule EMC checklist
- 电源走线宽度 ≥20mil，大电流 ≥40mil
- ESP32 天线区域 15mm 范围内无铺铜和走线
- 差分对偏差 (skew) < 25ps — 来源: kicad-happy
- 串扰间距：高速信号间距 ≥ 3× 走线宽度 — 来源: JAK Services PCB review
- 地平面完整性 >80%（无大面积割裂）
- Gerber 文件完整（铜层 + 阻焊 + 丝印 + 钻孔 + 坐标）
- 编造数据 = FAIL。线宽计算必须基于电流和铜厚。
