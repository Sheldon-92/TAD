# BOM Management（BOM 管理）

BOM 生成 + 成本估算 + 双供应商策略。流程：select → execute → verify → optimize。

## 1. Select — BOM 格式定义

1. BOM 来源: 从 KiCad 原理图导出基础 BOM
   `kicad-cli sch export bom -o bom-raw.csv <schematic>`
2. BOM 格式定义（标准列）：
   Item（序号）, Reference（元件标号 R1/C1/U1）, Value（标称值 10kΩ/100nF/ESP32-C3）,
   Footprint（封装 0402/0603/QFN-32）, Description（功能描述）, Manufacturer（制造商）,
   MPN（制造商料号）, Supplier_1（主供应商 LCSC）, Supplier_1_PN（主供应商料号）,
   Supplier_2（备选供应商 DigiKey/Mouser）, Supplier_2_PN（备选供应商料号）,
   Unit_Price_1K（1K 数量单价 USD）, Qty（单板用量）, Category（active/passive/connector/mechanical）
3. 数量阶梯: 10pcs（原型）, 100pcs（小批量）, 1Kpcs（量产）

**质量门：BOM 格式必须包含双供应商信息，单供应商 = 风险。**
产出：bom-format.md

## 2. Execute — 构建完整 BOM

1. 导入 KiCad 导出的原始 BOM
2. 合并相同器件（R1,R2,R3 = 10kΩ 0402 × 3）
3. 补充每个器件的：
   - 制造商和 MPN（从元器件选型结果引用）
   - 主供应商料号（LCSC 优先，搜索 lcsc.com）
   - 备选供应商料号（DigiKey/Mouser）
   - 1K 数量单价
4. 分类标注：active（IC/MCU）/ passive（R/C/L）/ connector / mechanical
5. 标注关键器件（长交期、单源、高价值）

**质量门：每个器件必须有至少一个供应商料号。"待定" 不超过总数的 10%。**
产出：bom-complete.csv

## 3. Verify — BOM 验证

1. 完整性检查：
   - 原理图上每个元件都在 BOM 中
   - 每个器件有 MPN（无 MPN 的标注原因）
   - 双供应商覆盖率 ≥80%（关键 IC 必须 100%）
2. 成本汇总：
   - 单板成本 = Σ(单价 × 用量) + PCB 成本估算
   - 分类成本饼图（active vs passive vs connector）
   - 成本 Top 5 器件（关注降本空间）
3. 供应链风险汇总：
   - 单源器件列表（需要寻找替代）
   - 长交期器件列表（>8 周需要提前备货）
   - EOL/NRND 器件列表（需要替代方案）
4. 与元器件选型交叉验证（选型报告中的器件 = BOM 中的器件）

**质量门：BOM 总成本必须基于真实报价，不接受估算超过 ±20% 的数据。**
产出：bom-verification.md

## 4. Optimize — 降本与报告

1. 降本建议：
   - 被动元件统一封装（减少料号种类，如全部用 0402）
   - 多个相同阻值/容值合并为同一料号
   - 替代方案对比（国产替代进口，如果参数满足）
2. 生成 BOM 报告 PDF：完整 BOM 表格 + 成本分布饼图 + 供应链风险矩阵 + 降本建议清单
3. 生成采购清单（按供应商分组）：LCSC 采购清单、DigiKey 采购清单

产出：bom-report.pdf

## Quality Bar（pass/fail）

- BOM 覆盖率 100%（原理图每个元件都有对应条目）
- 双供应商覆盖率 ≥80%（关键 IC = 100%）
- 每个器件有 MPN 和至少一个供应商料号
- 成本估算基于真实报价（标注报价日期和数量阶梯）
- BOM 按类别汇总成本（饼图可视化）
- 编造数据 = FAIL。价格必须来自供应商网站，推测标 [ESTIMATED]。
