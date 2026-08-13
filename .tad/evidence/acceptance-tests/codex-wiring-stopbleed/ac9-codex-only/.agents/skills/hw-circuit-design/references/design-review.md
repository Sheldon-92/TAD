# Design Review（设计评审）

DRC/ERC 自动检查 + 专家评审清单 + 问题追踪。流程：search → analyze → (anti-pattern scan) → derive → generate。
评审人 persona 清单见 `review-checklist.md`。

## 1. Search — 收集评审材料

1. 原理图文件 (.kicad_sch) + PDF 导出
2. PCB 文件 (.kicad_pcb) + Gerber 导出
3. BOM 文件 (CSV)
4. 元器件选型报告
5. 电源设计报告
6. ERC/DRC 报告（JSON）
7. 设计约束文档

检查文件版本一致性（原理图修改后 BOM/PCB 是否同步更新）。
产出：review-artifacts.md

## 2. Analyze — 自动化检查

1. ERC 检查: `kicad-cli sch erc --output erc-final.json --severity-all <schematic>`
2. DRC 检查: `kicad-cli pcb drc --output drc-final.json <board>`
3. BOM vs 原理图一致性:
   - 原理图元件数量 = BOM 条目数量
   - 原理图值 = BOM 值（10kΩ 不能写成 10K）
4. 网表一致性: PCB 网表 vs 原理图网表（无差异）
5. 设计规则合规: 线宽/间距/过孔全部在制造商能力内

输出自动检查报告（PASS/FAIL 清单）。
**质量门：自动检查结果必须全部附上工具输出。手动伪造 PASS = 严重违规。**
产出：automated-check-report.md

## 2.5 Anti-Pattern Scan（来源: kicad-happy 42-rule EMC checklist + Schemalyzer）

在人工评审前，先做自动化反模式扫描（最高价值活动 — 来源: 研究共识）：

**电容降额检查：**
- 每个陶瓷电容额定电压 ≥ 工作电压×2（50% derating）
- 每个电解电容额定电压 ≥ 工作电压×1.25（80% derating）
- DC bias 效应: X5R/X7R 在工作电压下容值衰减是否仍满足需求

**去耦距离检查（kicad-happy 阈值）：**
- 每个 IC VDD pin 的去耦电容距离 ≤7mm（理想 ≤3mm）
- 大电流 IC（电源芯片）的输入/输出电容距离 ≤5mm

**保护缺失检查：**
- 每个外部连接器有 TVS/ESD（且在连接器和电路之间，不是之后）
- 无浮空输入（每个未使用 GPIO 有上拉/下拉/禁用处理）
- 热焊盘 via 数量: QFN/DFN exposed pad ≥4 个热 via

**信号完整性检查：**
- 差分对 skew < 25ps
- 高速信号间距 ≥ 3× 走线宽度（串扰）
- 高速信号不跨越地平面分割

每个检查标注 PASS/FAIL + 具体位置。
**质量门：检查项必须有数值证据（实际距离、实际电压比），不接受"看起来 OK"。**
产出：anti-pattern-scan.md

## 3. Derive — 4 阶段专家评审

基于自动检查 + 反模式扫描结果，执行 4 阶段专家评审
（来源: Schemalyzer 4-phase review — 架构级→模块级→元器件级→自动检查）：

**阶段 1: 架构级评审**
- 电源方案满足所有模块需求（电压/电流/纹波）
- 功能模块划分合理，信号流向清晰
- 电池保护电路完备（过充/过放/过流/短路）

**阶段 2: 模块级评审**
- 去耦电容完整且就近放置
- ESD 保护覆盖所有外部接口
- 晶振电路负载电容计算正确
- 复位电路可靠（上电延时 + 手动复位）
- 未使用 GPIO 有明确处理（不悬空）

**PCB 评审：**
- 天线净空区满足要求（ESP32: ≥15mm）
- 地平面完整性 >80%
- 高速信号阻抗控制（USB 差分 90Ω ±10%）
- 热设计合理（大电流走线宽度、IC 热焊盘）
- 丝印可读且不被遮挡
- 安装孔/定位孔位置与外壳匹配

**制造评审：**
- 最小线宽/间距在制造商能力内
- Gerber 文件完整（所有层 + 钻孔 + 坐标）
- BOM 中所有器件可采购
- 没有 DNP（Do Not Populate）器件遗留

**可靠性评审：**
- 温度范围覆盖使用场景（-20°C ~ +60°C 典型）
- 湿度/防水考虑（如果是户外设备）
- 震动/跌落考虑（连接器牢固性）

每个检查项标注 PASS/FAIL/NA + 备注。FAIL 项必须有修复建议。
**质量门：评审清单每项必须有明确的 PASS/FAIL 判定，不接受模糊的 'OK'。**
产出：expert-review.md

## 4. Generate — 评审报告

1. 评审总结：
   - 自动检查通过率: X/Y 项
   - 专家评审通过率: X/Y 项
   - 整体评审结论: PASS / CONDITIONAL PASS / FAIL
2. 问题清单（按严重度排序）：
   - CRITICAL: 必须修复才能投产（如电源短路、天线遮挡）
   - MAJOR: 强烈建议修复（如去耦电容过远、单源器件）
   - MINOR: 建议改进（如丝印优化、成本降低）
3. 行动计划：
   - 每个 CRITICAL/MAJOR 问题有责任人和截止日期
   - 修复后需要重新评审的项目标注
4. 导出 PDF 评审报告

产出：design-review-report.pdf

## Quality Bar（pass/fail）

- ERC/DRC 自动检查结果全部附上（不能跳过）
- 专家评审 ≥20 个检查项全部有 PASS/FAIL/NA 判定
- CRITICAL 问题 0 个 = 可以投产；>0 = 阻塞
- 每个 FAIL 项有具体修复建议
- BOM vs 原理图一致性验证通过
- 评审分 4 阶段执行：架构级→模块级→元器件级→自动检查（来源: Schemalyzer 4-phase review methodology）
- 每个 IC 电源引脚有去耦电容、所有外部接口有 ESD 保护、无浮空输入 — 来源: Schemalyzer + kicad-happy 共识
- 编造数据 = FAIL。评审必须基于实际设计文件。
