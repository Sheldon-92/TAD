# Assembly Design（装配方式设计）

紧固方式 + 装配顺序 + 可维修性。Mixed 型：分析 + D2 图。

## Step 1: Search Fastening（紧固方式调研）

1. 螺丝紧固：M2/M3 自攻螺丝 + 铜螺母嵌件（塑料外壳标准方案）
2. 卡扣（snap-fit）：悬臂梁卡扣 / 环形卡扣 / 扭转卡扣
3. 超声波焊接：一次性密封方案（不可拆）
4. 胶粘：结构胶 / 双面胶 / UV胶

搜索每种方式的：保持力 (N)、循环次数、工具需求、单件时间、适用壁厚、材料兼容性、防水能力。

参考搜索词：
- `"snap fit design" 3D printed enclosure cantilever beam`
- `"plastic enclosure fastening" screws vs snap-fit vs ultrasonic`
- `"heat-set insert" 3D print M2 M3 specification`
- `"IP65 enclosure sealing" gasket O-ring design`

## Step 2: Analyze Serviceability（可维修性分析）

1. 电池可更换性：需要几步？需要工具吗？
2. PCB 可接触性：调试/固件更新是否需要拆壳？
3. 密封 vs 可拆卸权衡：
   - IP65 要求 O-ring + 螺丝（可拆但复杂）
   - 超声波焊接（密封好但不可维修）
   - 卡扣 + 密封垫圈（折中方案）
4. 拆装循环次数：消费级 ≥20 次，工业级 ≥100 次
5. 工具需求：无工具 > 通用工具 > 专用工具

决策依据：产品定位（一次性 vs 长寿命）、维修频率、目标成本。
质量要求：每个决策必须说明权衡（tradeoff），不能只推荐一种方案。

## Step 3: Derive Assembly Sequence（装配顺序）

必须考虑人机工程：

1. 列出所有零件清单（BOM 简表）：`| # | 零件 | 数量 | 材料 | 来源 |`
2. 装配顺序（每步≤1个动作）：
   - Step 1: 将 X 放入 Y（方向：从上往下）
   - Step 2: 插入 Z（施力方向：水平推入）
3. 每步标注：
   - 施力方向和大小（捏合力 ≤30N 手指可操作）
   - 对齐特征（导槽/定位销/倒角引导）
   - 不可逆操作警告（⚠️ 超声波焊接后不可拆）
4. 估算总装配时间（目标：手工 ≤3分钟，流水线 ≤30秒）

## Step 4: Generate Assembly Diagram（D2 装配爆炸图）

1. 每个零件一个节点，按装配顺序从下到上排列
2. 用箭头标注装配方向和紧固方式
3. 标注关键尺寸（螺丝长度、卡扣间隙）
4. 用颜色区分：壳体(蓝)、PCB(绿)、紧固件(红)、附件(灰)

示例 D2 结构：
```
direction: down
bottom_shell: "底壳" { style.fill: "#4A90D9" }
pcb: "PCB + 电池" { style.fill: "#7BC67E" }
top_cover: "顶盖" { style.fill: "#4A90D9" }
screws: "M2×6 螺丝 ×4" { style.fill: "#E74C3C" }
bottom_shell -> pcb: "放入（从上往下）" { style.stroke-dash: 5 }
pcb -> top_cover: "扣合" { style.stroke-dash: 5 }
top_cover -> screws: "拧紧 0.3Nm"
```

## Step 5: Generate Fastening Detail（D2 紧固细节图）

1. 螺丝柱截面图（含尺寸标注）
2. 卡扣截面图（含悬臂长度、偏转量、应力）
3. 密封结构截面图（O-ring 槽尺寸、压缩比）

每个细节图标注关键尺寸 ±公差。

## Pass/Fail Criteria

- 装配步骤每步 ≤1 个动作，有施力方向标注
- 总装配时间估算 ≤3 分钟（手工）
- 捏合力 ≤30N（手指可操作）
- 拆装循环次数满足产品定位（消费≥20，工业≥100）
- 有爆炸图 + 紧固细节图
- 编造紧固参数 = FAIL（卡扣应力必须有计算或参考值）
