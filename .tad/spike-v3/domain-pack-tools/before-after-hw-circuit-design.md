# hw-circuit-design 迭代记录

## 来自研究的改进

| 来源仓库 | 发现 | 改进了什么 | 改进前 | 改进后 |
|---------|------|-----------|--------|--------|
| kicad-happy (127★) | 42-rule EMC checklist with quantified thresholds | component_selection quality_criteria: 电容降额规则 | 无降额标准 | 陶瓷电容 50% derating, 电解 80% derating |
| Espressif HW Design Guidelines | ESP32 crystal accuracy spec | component_selection quality_criteria: 晶振精度 | 无晶振要求 | ±10ppm 温度范围内 |
| kicad-happy | Decoupling distance threshold | pcb_layout quality_criteria: 去耦距离 | ≤3mm | ≤7mm (理想 ≤3mm) — 更务实的阈值 |
| kicad-happy | Differential pair skew spec | pcb_layout quality_criteria: 新增差分对偏差 | 无 | < 25ps |
| JAK Services PCB review | Crosstalk spacing rule | pcb_layout quality_criteria: 新增串扰间距 | 无 | ≥ 3× 走线宽度 |
| Schemalyzer review guide | ESD/TVS placement rule | pcb_layout anti_patterns: 新增 | 无 | TVS 必须在连接器和电路之间 |
| kicad-happy thermal check | Thermal via count | pcb_layout anti_patterns: 新增 | 无 | QFN exposed pad 需要 ≥4 via |
| 多 PCB review repo 共识 | Ground plane split warning | pcb_layout anti_patterns: 增强 | "地平面被走线割裂 = EMI 问题" | 增加"高速信号绝不能跨越地平面分割" |
| Schemalyzer | 4-phase review methodology | design_review quality_criteria: 新增 | 无 | 架构级→模块级→元器件级→自动检查 4 阶段 |
| Schemalyzer + kicad-happy | Universal pin protection rules | design_review quality_criteria: 新增 | 无 | 每个 IC 电源引脚去耦 + 外部接口 ESD + 无浮空输入 |
| Schemalyzer | ERC suppression anti-pattern | design_review anti_patterns: 新增 | 无 | 压制 ERC 警告不调查 = 隐藏错误 |
| Schemalyzer Rule of 10 | Error cost multiplier | design_review anti_patterns: 新增 | 无 | 原理图 1x → 布局 10x → 打样 100x → 量产 1000x |
| kicad-happy | Capacitor derating anti-pattern | component_selection anti_patterns: 新增 | 无 | DC bias 效应导致实际容值下降 |
| Espressif guidelines | Component lifecycle warning | component_selection anti_patterns: 新增 | 无 | 忽略 Active/NRND/EOL 状态 = 量产断供 |

### 第二轮改进：工作流 + 步骤

| 来源仓库 | 发现 | 改进了什么 | 改进前 | 改进后 |
|---------|------|-----------|--------|--------|
| kicad-happy + Schemalyzer | 自动化反模式检测是最高价值活动 | design_review: 新增 scan_anti_patterns step | 无（直接人工评审） | 人工评审前先做自动反模式扫描（电容降额/去耦距离/保护缺失/信号完整性 4 类检查） |
| Schemalyzer 4-phase review | 分阶段评审优于平铺检查清单 | design_review: 重构 derive_expert_review step | 单一检查清单 | 4 阶段结构（架构级→模块级→元器件级→自动检查） |

## 改动统计
- 新增 quality_criteria: 8
- 新增 anti_patterns: 6
- 新增 steps: 1 (scan_anti_patterns — 反模式自动扫描)
- 修改 existing steps: 1 (derive_expert_review — 重构为 4 阶段)
- 修改 existing criteria: 2 (去耦距离更新, 地平面 anti-pattern 增强)
- 涉及 capabilities: component_selection, pcb_layout, design_review (3 个)
- Git diff hunks: 14
