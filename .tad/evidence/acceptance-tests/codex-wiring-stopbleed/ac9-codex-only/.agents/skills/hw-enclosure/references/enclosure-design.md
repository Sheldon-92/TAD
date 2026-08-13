# Parametric Enclosure Design (OpenSCAD)

参数化 3D 外壳建模 — 从需求到可打印的 .scad + STL。核心交付物是参数化 `enclosure.scad` 源文件。

## Step 1: Gather Constraints（收集硬件约束）

所有数值必须有来源，不接受凭感觉：

1. PCB 尺寸：长×宽×高（含最高元器件），安装孔位置和直径
2. 连接器位置：USB/天线/按钮/LED 的 XYZ 坐标 + 朝向 + 开口尺寸
3. 电池尺寸：型号、长×宽×高、固定方式
4. 工作环境：室内/室外、温度范围、IP 等级要求
5. 制造方式：FDM/SLA/注塑 → 决定最小壁厚和公差

如果用户未提供 PCB 尺寸 → 搜索该开发板的官方尺寸图。产出记录到约束文档（如 `enclosure-constraints.md`）。

## Step 2: Select Enclosure Type（外壳类型选型）

必须给出选型理由：

| 类型 | 适用场景 | 壁厚 | 分模方式 |
|------|---------|------|---------|
| 上下壳体 (clamshell) | 通用，维修方便 | ≥1.5mm FDM / ≥1.0mm SLA | 水平分模 |
| 滑入式 (slide-in) | 薄型设备，扁平 PCB | ≥1.2mm | 侧面滑入 |
| 卡扣式 (snap-fit) | 无螺丝外观，消费级 | ≥2.0mm（卡扣处 ≥2.5mm）| 卡扣+导槽 |
| 防水密封 (sealed) | IP65+，户外 | ≥2.5mm + 密封槽 | O-ring 压缩 |

决定关键参数：
- `wall_thickness`: mm（基于制造方式 + 结构强度）
- `corner_radius`: mm（≥2mm 减少应力集中）
- `tolerance`: mm（FDM=0.2, SLA=0.1, 注塑=0.05）
- `draft_angle`: deg（注塑 ≥1.5°，3D 打印=0°）
- `screw_boss_od`: mm（螺丝外径×2.5 经验值）

## Step 3: Generate .scad（生成参数化模型）

1. 文件顶部声明所有参数变量（方便 `-D` 覆盖）
2. 使用 `module` 封装每个子组件（底壳、顶盖、螺丝柱、通风孔）
3. 关键设计规则：
   - 所有内角用 `minkowski()` 做圆角（减少应力集中）
   - 螺丝柱用 `difference()` 从壳体长出来，不是独立粘贴
   - 配合面加 tolerance 变量（`lid_inner = shell_outer + 2*tol`）
   - 通风孔用 `for()` 循环阵列，间距≥1.5mm（FDM 可打印）
   - `$fn=32` 预览，`$fn=64` 导出
4. 底壳和顶盖分别作为 module，可独立导出

⚠️ 所有尺寸必须来自 Step 1 的实际数据。

## Step 4: Render Preview（渲染预览，4 视角）

```
openscad -o enclosure-front.png --camera=0,0,0,55,0,25,200 --imgsize=1024,768 enclosure.scad
openscad -o enclosure-top.png --camera=0,0,0,90,0,0,200 --imgsize=1024,768 enclosure.scad
openscad -o enclosure-iso.png --camera=0,0,0,45,0,45,200 --imgsize=1024,768 enclosure.scad
openscad -o enclosure-section.png --camera=0,0,0,55,0,25,200 --imgsize=1024,768 --render enclosure.scad
```

确认：壁厚均匀、无穿模、螺丝柱位置正确、连接器开口对齐。

## Step 5: Verify Dimensions（验证关键尺寸）

人工检查 + 脚本计算：
1. 内腔是否能容纳 PCB + 电池 + 线缆（每边至少 1mm 间隙）
2. 连接器开口是否对齐（位置偏差 ≤0.5mm）
3. 壁厚是否满足最小值（grep wall 变量 vs 实际 difference）
4. 总外形尺寸是否符合用户要求
5. 预估打印时间和材料用量（基于体积）

如果发现尺寸错误 → 修改 .scad 参数 → 重新渲染。

## Step 6: Optimize Printability（打印友好性优化）

**FDM 优化**：
- 悬空角度 ≤45° 或添加支撑结构
- 首层接触面积 ≥ 总底面积 20%（防翘曲）
- 薄壁方向与打印层方向一致（强度最大化）
- 桥接距离 ≤5mm（来源: Protolabs/Hubs DFM — 原值 10mm 过于宽松）
- 水平孔使用 Teardrop 形状（来源: NopSCADlib Teardrops module — 圆孔 FDM 顶部塌陷）

**SLA 优化**：
- 排水孔（封闭腔体必须有 ≥2mm 孔）
- 支撑点避开外观面

**CNC 优化**（来源: NopSCADlib Dogbones module）：
- 内角使用 Dogbone 减压槽（CNC 无法铣出尖内角）
- 槽宽 = 刀具直径 + 0.2mm 余量

**通用**：
- 消除尖角（应力集中 → 开裂）
- 配合面倒角 0.5mm（引导装配）

## Step 7: Validate Manifold（流形验证 — HARD GATE）

STL 导出前强制流形验证（non-manifold = 3D 打印失败第一因。来源: cad-agent + openscad-agent 共识）：

1. OpenSCAD 渲染模式验证：
   ```
   openscad -o /dev/null --render enclosure.scad 2>&1 | grep -i "error\|warning"
   ```
   如果有 geometry 警告 → 修复后重新渲染
2. 如果有 ADMesh 工具：
   ```
   admesh --check enclosure.stl
   ```
   检查项: Degenerate facets = 0, Edges fixed = 0, Facets reversed = 0
3. 人工检查：在 OpenSCAD 预览模式 (F5) 查看是否有穿模/自交
4. 最终导出：
   ```
   openscad -o enclosure-bottom.stl -D 'part="bottom"' enclosure.scad
   openscad -o enclosure-top.stl -D 'part="top"' enclosure.scad
   ```

⚠️ 此步骤是 HARD GATE — 验证不通过禁止交付 STL。

## Pass/Fail Criteria

- 所有尺寸参数化（顶部变量声明，可通过 `-D` 覆盖）
- 壁厚满足制造最小值（FDM ≥1.5mm / 绝对最小 0.8mm 即 2 perimeters, SLA ≥1.0mm, 注塑 ≥1.2mm）— 来源: NopSCADlib + Protolabs
- 配合面公差正确（FDM=0.2mm, SLA=0.1mm），端口/孔洞公差 0.2-0.3mm — 来源: Cadence PCB enclosure guidelines
- 螺丝柱外径 ≥ 螺丝外径×2.5，角落螺丝区域留足装配空间 — 来源: easy-enclosure fastener clearance warning
- 所有内角有圆角（corner_radius ≥2mm），圆角最小 0.1mm 保证壳体厚度一致 — 来源: Cadence guidelines
- STL 导出前必须通过流形/水密性验证（non-manifold geometry = 3D 打印失败第一因）
- FDM 悬空角度 ≤45°、无支撑桥接跨度 ≤5mm — 来源: Protolabs/Hubs DFM rules
- .scad 文件可直接 `openscad -o output.stl` 编译无错误
- 编造尺寸 = FAIL。PCB 数据必须来自数据手册或实测
