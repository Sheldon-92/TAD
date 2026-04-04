# hw-enclosure 迭代记录

## 来自研究的改进

| 来源仓库 | 发现 | 改进了什么 | 改进前 | 改进后 |
|---------|------|-----------|--------|--------|
| NopSCADlib + Protolabs | FDM absolute minimum wall | enclosure_design quality_criteria: 壁厚 | "FDM ≥1.5mm" | "FDM ≥1.5mm / 绝对最小 0.8mm 即 2 perimeters" |
| Cadence PCB enclosure guidelines | Port/hole tolerance spec | enclosure_design quality_criteria: 公差 | "FDM=0.2mm, SLA=0.1mm" | 增加端口/孔洞公差 0.2-0.3mm |
| easy-enclosure | Fastener clearance warning | enclosure_design quality_criteria: 螺丝柱 | "外径 ≥ 螺丝外径×2.5" | 增加"角落螺丝区域留足装配空间" |
| Cadence guidelines | Fillet minimum spec | enclosure_design quality_criteria: 圆角 | "corner_radius ≥2mm" | 增加"圆角最小 0.1mm 保证壳体厚度一致" |
| cad-agent + openscad-agent | Manifold validation as hard gate | enclosure_design quality_criteria: 新增 | 无 | STL 导出前必须通过流形/水密性验证 |
| Protolabs/Hubs DFM rules | FDM overhang + bridge limits | enclosure_design quality_criteria: 新增 | 无 | 悬空 ≤45°, 桥接 ≤5mm |
| MEDA, cad-agent, openscad-agent | Render-inspect-iterate loop | enclosure_design anti_patterns: 增强 | "不渲染预览就交付" | 增加"所有成功 AI-CAD 系统都实现此循环" |
| 多源共识 | Material-environment mismatch | enclosure_design anti_patterns: 新增 | 无 | PLA 室外/ABS UV/刚性密封件 |
| easy-enclosure + NopSCADlib | Fastener volume calculation | enclosure_design anti_patterns: 新增 | 无 | 角落螺丝空间不足是最常见装配失败 |
| NopSCADlib DFM modules | Dogbone + Teardrop patterns | pcb_fitting quality_criteria: 新增 | 无 | CNC 内角 Dogbone, FDM 水平孔 Teardrop |
| Cadence guidelines | EMI enclosure dependency | pcb_fitting anti_patterns: 新增 | 无 | 外壳不是 EMI 一线防护 |
| 多源研究共识 | Material-environment matrix | material_selection quality_criteria: 新增 | 无 | ABS/PLA/PC 环境兼容性矩阵 |
| IEC 60529 + Cadence | Protection rating standards | material_selection quality_criteria: 新增 | 无 | NEMA 1-4X / IP54-IP67 |
| Cadence anti-patterns | Inconsistent wall thickness | material_selection anti_patterns: 新增 | 无 | 壁厚不均匀导致注塑缩印/翘曲 |

### 第二轮改进：工作流 + 步骤 + 工具集成

| 来源仓库 | 发现 | 改进了什么 | 改进前 | 改进后 |
|---------|------|-----------|--------|--------|
| cad-agent + openscad-agent | 流形验证是 STL 导出硬门禁 | enclosure_design: 新增 validate_manifold step | 无（优化后直接交付） | OpenSCAD render 验证 + admesh --check，HARD GATE |
| NopSCADlib | DFM 应该是设计原语不是事后检查表 | enclosure_design: 增强 optimize_printability step | 桥接 ≤10mm, 无 Teardrop/Dogbone | 桥接 ≤5mm, FDM 水平孔 Teardrop, CNC 内角 Dogbone |
| cad-agent + openscad-agent | admesh 工具用于网格验证 | tools-registry: 新增 admesh | 无 | admesh --check 流形验证 + --fix-all 修复 |

## 改动统计
- 新增 quality_criteria: 6
- 新增 anti_patterns: 5
- 新增 steps: 1 (validate_manifold — STL 流形验证硬门禁)
- 新增 tools-registry 条目: 1 (admesh)
- 修改 existing steps: 1 (optimize_printability — DFM 原语增强)
- 修改 existing criteria: 4 (壁厚、公差、螺丝柱、圆角增加来源和细节)
- 修改 existing anti_patterns: 1 (渲染预览增强)
- 涉及 capabilities: enclosure_design, pcb_fitting, material_selection (3 个)
- Git diff hunks: 10
