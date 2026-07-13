# Manufacturing Export（STL/STEP 导出 + 打印参数 + 制造文件包）

## Step 1: Select Export Format（按制造方式选格式）

| 制造方式 | 主格式 | 辅格式 | 用途 |
|---------|-------|-------|------|
| FDM 自制 | STL | 3MF | 切片软件输入 |
| SLA 外发 | STL | - | 服务商通用 |
| SLS/MJF | STL | 3MF | 服务商通用 |
| CNC | STEP | DXF | CAM 编程 |
| 注塑 | STEP | IGES | 模具设计 |

注意：OpenSCAD 不能直接导出 STEP。如果需要 STEP → 导出 STL → 用 FreeCAD 转换（或推荐 CadQuery）。

## Step 2: Export STL（分零件导出）

1. 底壳：`openscad -D 'part="bottom"' -o bottom_shell.stl --render enclosure.scad`
2. 顶盖：`openscad -D 'part="top"' -o top_cover.stl --render enclosure.scad`
3. 附件（按钮帽、装饰件等）：单独导出

导出前在 .scad 中添加零件选择逻辑：
```
part = "all"; // "bottom", "top", "button", "all"
if (part == "bottom" || part == "all") bottom_shell();
if (part == "top" || part == "all") top_cover();
```

⚠️ 必须用 `--render` 标志（CGAL 完整渲染），否则 STL 可能有非流形错误。

## Step 3: Verify STL（质量验证）

1. 文件大小合理性（简单外壳 0.5-5MB，过大说明 `$fn` 过高）
2. 非流形检查（OpenSCAD `--render` 通常无此问题）
3. 尺寸验证：用 Python 读取 STL 边界框确认尺寸
   ```
   python3 -c "
   import struct
   with open('bottom_shell.stl','rb') as f:
     f.read(80); n=struct.unpack('I',f.read(4))[0]
     xs,ys,zs=[],[],[]
     for _ in range(n):
       f.read(12)
       for _ in range(3):
         x,y,z=struct.unpack('fff',f.read(12))
         xs.append(x);ys.append(y);zs.append(z)
       f.read(2)
     print(f'Size: {max(xs)-min(xs):.1f} x {max(ys)-min(ys):.1f} x {max(zs)-min(zs):.1f} mm')
     print(f'Triangles: {n}')
   "
   ```
4. 如果尺寸与设计不符 → 回退检查 .scad

## Step 4: Generate Print Profile（打印参数推荐）

基于材料和零件特征，每个参数给理由：

| 参数 | 底壳 | 顶盖 | 理由 |
|------|------|------|------|
| 层高 | 0.2mm | 0.2mm | 功能件标准 |
| 壁数 | 3 | 3 | 强度需求 |
| 填充率 | 20% | 15% | 底壳承重多 |
| 填充图案 | gyroid | gyroid | 各向同性强度 |
| 支撑 | 需要/不需要 | ... | 基于悬空分析 |
| 打印方向 | 开口朝上 | 开口朝上 | 最少支撑 |
| 床温 | 60°C | 60°C | PETG 标准 |
| 喷嘴温度 | 240°C | 240°C | PETG 标准 |
| 打印速度 | 50mm/s | 50mm/s | 外壳品质优先 |
| 预估时间 | Xh Xm | Xh Xm | 基于体积估算 |
| 预估材料 | Xg | Xg | 基于体积×密度 |

## Step 5: Package Deliverables（制造文件包）

创建 `release/` 目录：
```
release/
├── STL/
│   ├── bottom_shell.stl
│   ├── top_cover.stl
│   └── accessories/
├── SCAD/
│   └── enclosure.scad (参数化源文件)
├── RENDERS/
│   ├── enclosure-iso.png
│   ├── enclosure-front.png
│   └── assembly-exploded.svg
├── PRINT_GUIDE.md (打印参数 + 注意事项)
└── BOM.md (物料清单)
```

## Pass/Fail Criteria

- STL 文件可在 Cura/PrusaSlicer 中打开且无非流形错误
- STL 尺寸与 .scad 设计一致（误差 ≤0.1mm）
- 底壳和顶盖分别导出为独立 STL
- 打印参数有明确理由（不是默认值）
- 制造文件包结构清晰，含 README
- 编造打印时间/材料用量 = FAIL（必须基于体积计算）
