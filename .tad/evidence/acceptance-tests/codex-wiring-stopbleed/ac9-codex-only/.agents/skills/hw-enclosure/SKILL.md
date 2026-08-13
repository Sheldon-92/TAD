---
name: hw-enclosure
description: "Hardware enclosure design capability pack. Covers parametric OpenSCAD enclosure modeling, PCB fitting, material selection, assembly design, ergonomics, manufacturing export (STL/STEP), and dimension/assembly documentation. Use for any IoT/embedded device enclosure design, PCB housing, 3D-print enclosure, or enclosure manufacturing prep task."
version: 0.1.0
type: reference-based
keywords: ["enclosure", "外壳", "外壳设计", "case design", "housing", "OpenSCAD", "scad", "STL", "3D printing", "3D 打印", "FDM", "SLA", "injection molding", "注塑", "PCB fitting", "PCB 安装", "snap-fit", "卡扣", "IP65", "防水", "wall thickness", "壁厚", "tolerance", "公差", "装配", "assembly", "人机工程", "ergonomics", "材料选型", "material selection"]
---

# Hardware Enclosure Design Capability Pack

> From PCB dimensions to print-ready enclosure — real tool outputs (STL, PDF, diagrams), not sketches.
> Scope: IoT / embedded device enclosures. FDM/SLA 3D printing primary, injection molding secondary.
> Core deliverable: parametric `.scad` model + STL export + assembly diagrams + dimension drawings. All tolerances, wall thicknesses, and snap-fit parameters derive from manufacturing constraints — never from gut feeling.

---

## Step 0: Pack Prerequisites

- **OpenSCAD** (parametric CAD + STL export) — macOS: `brew install --cask openscad`
- **D2** (assembly/dimension diagrams), **Typst** (PDF documentation)
- Optional: **ADMesh** (STL manifold check), **FreeCAD/CadQuery** (STEP conversion)

---

## Step 1: Context Detection

| User Signal | Load Reference |
|---|---|
| new enclosure, 外壳建模, .scad, OpenSCAD, wall thickness, snap-fit, clamshell, 卡扣, 壳体 | `references/enclosure-design.md` |
| PCB mounting, standoff, 安装柱, connector cutout, 开口, USB-C hole, antenna window, 天线, cable routing | `references/pcb-fitting.md` |
| which material, PLA/PETG/ABS/ASA, 材料选型, outdoor durability, 耐候, cost per unit, injection molding cost | `references/material-selection.md` |
| how to fasten, screws vs snap-fit, 紧固, assembly sequence, 装配顺序, serviceability, 可维修, O-ring, sealing | `references/assembly-design.md` |
| handheld, grip, 握持, button placement, 手感, appearance, 外观, color scheme, form factor | `references/ergonomics.md` |
| export STL/STEP, slicing, 切片, print settings, 打印参数, deliverable package, release files | `references/manufacturing-export.md` |
| dimension drawing, 尺寸图, three-view, 三视图, cross-section, assembly guide PDF, 装配指南, BOM | `references/documentation.md` |
| review a deliverable, 审查, acceptance check, before declaring any capability's output done | `references/review-checklist.md` |

**Multi-signal**: load all matched references. Before declaring ANY deliverable complete, also read its Pass/Fail Criteria section in the matched reference — those are the acceptance rules.

---

## Step 2: Decision Entry Point

**Q1 — What stage is the request?**
- Full enclosure from scratch → `enclosure-design.md` first (constraints → type selection → .scad), then `pcb-fitting.md`
- Existing shell, fit a board into it → `pcb-fitting.md`
- Deciding what to print it in / production cost → `material-selection.md`
- How the parts join / open / seal → `assembly-design.md`
- Handheld or user-facing device shape → ALSO `ergonomics.md`
- Ready to ship files to printer/fab → `manufacturing-export.md` then `documentation.md`

**Q2 — Manufacturing method?** (drives every tolerance and wall number)
- FDM → tolerance 0.2mm, wall ≥1.5mm (absolute min 0.8mm = 2 perimeters), draft 0°
- SLA → tolerance 0.1mm, wall ≥1.0mm, drain holes ≥2mm in closed cavities
- Injection molding → tolerance 0.05mm, wall ≥1.2mm, draft angle ≥1.5°, uniform wall thickness
- CNC → dogbone relief in inner corners (slot = tool diameter + 0.2mm); export STEP not STL

**Q3 — Outdoor / sealed?**
- Outdoor → material must survive UV + temperature (NOT PLA >50°C, NOT ABS long-term UV) → `material-selection.md`
- IP65+ → sealed type: wall ≥2.5mm + O-ring groove → `enclosure-design.md` + `assembly-design.md`

---

## Core Judgment Rules (always apply)

1. **No invented numbers.** Every dimension comes from a datasheet, EDA file, or physical measurement (priority in that order). 编造尺寸/材料参数/人体数据 = FAIL. If the user gives no PCB dimensions, search the board's official drawing.
2. **Enclosure type is a reasoned selection**, not a default: clamshell (general, serviceable) / slide-in (thin, flat PCB, wall ≥1.2mm) / snap-fit (no-screw consumer look, wall ≥2.0mm, ≥2.5mm at snaps) / sealed (IP65+ outdoor, wall ≥2.5mm + O-ring). State why.
3. **Everything parametric.** All dimensions as top-of-file variables overridable via `openscad -D`; bottom shell and lid as separate modules, separately exportable. Magic numbers are forbidden.
4. **Mating surfaces get tolerance** (`lid_inner = shell_outer + 2*tol`; FDM 0.2 / SLA 0.1 / molding 0.05mm). Connector cutouts get manufacturing allowance: width +1.0mm FDM / +0.5mm SLA, height +0.8mm. Cutout position error >±0.5mm = connector won't insert.
5. **Screw boss OD = screw OD × 2.5**; corners get radius ≥2mm (stress concentration); count fastener volume BEFORE finalizing the shell — corner screw clearance is the most common assembly failure.
6. **Render-inspect-iterate is mandatory.** Never deliver without rendering previews (4 camera angles) and a transparent PCB placeholder block to verify clearances (PCB edges ≥1mm, tallest component to lid ≥1.5mm).
7. **Manifold validation is a HARD GATE before STL delivery**: `openscad --render` with zero geometry errors/warnings (plus `admesh --check` if available). Always export with `--render` — F5-preview exports can be non-manifold. Failing this gate forbids delivering the STL.
8. **FDM printability**: overhangs ≤45° or supports; unsupported bridges ≤5mm; horizontal holes as teardrops; first-layer contact ≥20% of footprint.
9. **Material-environment compatibility is a required check**: PLA not outdoors / not >50°C; ABS not in long-term UV (use ASA); PC when transparency/impact needed; rigid seals don't compress. Recommendations need ≥3 candidates scored in a weighted decision matrix with sourced values (`[DATA NEEDED]` when missing, `[ESTIMATED]` for guesses).
10. **Antenna clearance**: metal enclosures need an antenna window (blocking costs 20dB+); the enclosure is NOT the primary EMI shield — solve EMI at PCB level.
11. **Cost honesty**: quote mold cost ($2K-15K threshold) whenever recommending injection molding; include post-processing and labor, not just material; if budget can't support molding, say so and state 3D-printing volume limits.
12. **Format follows process**: STL/3MF for FDM/SLA/SLS, STEP for CNC/molding. OpenSCAD cannot export STEP — convert via FreeCAD or use CadQuery.
13. **Docs must match CAD 100%.** Every dimension in drawings/assembly guide is cross-checked against `.scad` parameter values before delivery.
14. **Human-domain judgment stays human**: appearance style keywords, color scheme, and grip feel are choices to present as options with reasons — engineering numbers (tolerances, wall, clearances) are the agent's to compute.

---

## Quick Rule Index

### Enclosure Design (`references/enclosure-design.md`)
- Constraint gathering checklist (PCB/connectors/battery/environment/method) → §Step 1
- Type selection table + key parameter derivation → §Step 2
- .scad structuring rules (minkowski fillets, boss via difference, $fn discipline) → §Step 3
- 4-angle preview commands, dimension verification, printability optimization (FDM/SLA/CNC) → §Steps 4-6
- Manifold HARD GATE procedure + per-part export commands → §Step 7

### PCB Fitting (`references/pcb-fitting.md`)
- ±0.1mm measurement protocol + connector table format → §Step 1
- Standoff/alignment-pin/edge-slot sizing formulas (M2/M3 numbers) → §Step 2
- Cutout formulas: USB-C 9.5×3.5mm, LED light pipes, button holes, display window steps → §Step 3
- Transparent-placeholder verification checklist + cable routing (bend radius ≥3× diameter) → §Steps 4-5

### Material Selection (`references/material-selection.md`)
- Candidate search queries + supplier list (FDM: Hatchbox/eSUN/Polymaker; fab: JLCPCB/PCBWay) → §Step 1
- Weighted decision matrix template + sourcing rules → §Step 2
- Process match table (FDM/SLA/SLS/molding cost, MOQ, lead time) + stage advice → §Step 3

### Assembly Design (`references/assembly-design.md`)
- Fastening options research (screws+inserts / snap-fit / ultrasonic / adhesive) → §Step 1
- Serviceability tradeoffs (seal vs teardown; consumer ≥20 / industrial ≥100 cycles) → §Step 2
- One-action-per-step sequence rules (pinch force ≤30N, ≤3min hand assembly) → §Step 3
- D2 exploded diagram + fastening detail templates → §Steps 4-5

### Ergonomics (`references/ergonomics.md`)
- ISO 7250 anthropometric anchors (palm width, grip force, thumb reach ≤70mm) → §Step 1
- Form factor rules (edge radius ≥3mm, palm curve R=80-120mm, center of gravity) → §Step 2
- Design language derivation (keywords, colors with rationale, parting line hiding, logo method) → §Step 3

### Manufacturing Export (`references/manufacturing-export.md`)
- Format-by-process table + STEP conversion path → §Step 1
- Per-part export with `--render` + part-selector .scad pattern → §Step 2
- STL bounding-box verification script (stdlib Python) → §Step 3
- Print profile table (every parameter justified) + release/ package layout → §Steps 4-5

### Documentation (`references/documentation.md`)
- Three-view + cross-section drawing requirements (tolerance and scale callouts) → §Steps 1-2
- Typst assembly guide structure (A4 landscape, BOM, per-step figures) → §Step 3
- Compile + .scad-vs-docs consistency verification loop → §Steps 4-5

### Review Checklists (`references/review-checklist.md`)
- 7 expert personas (mechanical/hardware/materials/production/industrial-design/3D-print/tech-writer), one checklist per capability — run AFTER each capability's deliverable, BEFORE calling it done
- End-to-end acceptance sample (ESP32 + E-ink + 18650 outdoor tracker) for self-testing the whole pipeline

---

## Anti-Patterns

### Enclosure Design
- ❌ 硬编码尺寸（magic numbers）→ 必须用变量
- ❌ 忽略公差（配合面无间隙 → 装不进去）
- ❌ 壁厚凭感觉（必须基于制造方式的最小值）
- ❌ 不渲染预览就交付（肉眼检查 = 必须步骤）— 所有成功的 AI-CAD 系统都实现 render-inspect-iterate 循环（来源: MEDA, cad-agent, openscad-agent）
- ❌ 单体建模（底壳+顶盖应该是独立 module，可分别导出 STL）
- ❌ 材料与环境不匹配：PLA 用在室外（UV/热变形）、ABS 长期 UV 暴露（降解）、刚性密封件（压缩不良）— 来源: 多源共识
- ❌ 不计算紧固件占用体积就设计外壳（→ 角落螺丝空间不足是最常见装配失败原因 — 来源: easy-enclosure + NopSCADlib）

### PCB Fitting
- ❌ 安装孔位置靠目测（必须用坐标数据）
- ❌ 连接器开口不加公差（插不进去）
- ❌ 忽略 PCB 背面元器件高度（安装柱高度不够 → 短路）
- ❌ 不验证就交付（必须有透明 PCB 占位块渲染）
- ❌ 忘记天线净空（金属外壳挡天线 → 信号衰减 20dB+）
- ❌ 依赖外壳做 EMI 屏蔽而不在 PCB 层面解决（外壳不是 EMI 一线防护 — 来源: Cadence guidelines）

### Material Selection
- ❌ 不搜索就推荐 PLA（PLA 不耐温、脆，不是万能材料）
- ❌ 忽略后处理成本（打磨、喷漆、攻丝都是钱）
- ❌ 成本只算材料不算人工和模具分摊
- ❌ 推荐注塑但不说模具成本（$2K-$15K 门槛）
- ❌ 材料参数来源混乱（不同测试标准的数据不能直接比较）
- ❌ 壁厚不均匀（注塑导致缩印/翘曲，FDM 导致强度不一致 — 来源: Cadence anti-patterns）

### Assembly Design
- ❌ 只考虑紧固不考虑拆卸（维修时怎么拆？）
- ❌ 卡扣设计没有应力校验（断裂 = 产品报废）
- ❌ 装配顺序不考虑线缆（先盖盖子再接线 = 灾难）
- ❌ 螺丝扭矩不标注（拧过头 = 螺丝柱开裂）
- ❌ 爆炸图没有方向箭头（看图猜装配顺序）

### Ergonomics
- ❌ 外形只看内部元器件不考虑握持（方盒子≠好设计）
- ❌ 圆角凭感觉（必须基于使用场景和制造方式）
- ❌ 按钮位置不考虑单手操作（拇指够不到 = 差体验）
- ❌ 颜色选择无理由（'我觉得好看'不是理由）
- ❌ 忽略分型线（在正面留一条丑线 = 廉价感）

### Manufacturing Export
- ❌ 导出整体 STL 不分零件（无法分别打印/分色）
- ❌ 不用 --render 导出（F5 预览导出的 STL 可能有错误）
- ❌ $fn 过高导致 STL 巨大（$fn=256 → 文件 50MB+）
- ❌ 打印参数照抄网上不适配当前零件
- ❌ 不验证 STL 尺寸（OpenSCAD 单位是 mm，切片软件可能按 inch 理解）

### Documentation
- ❌ 尺寸图不标公差（制造时无法判断精度要求）
- ❌ 装配指南无图（纯文字 = 没人看）
- ❌ 文档尺寸与 .scad 不一致（改了设计忘改文档）
- ❌ BOM 缺少紧固件（螺丝、垫圈、O-ring 容易遗漏）
- ❌ PDF 不含比例尺（无法直接量测）

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "I'll estimate the PCB size" | MUST source dimensions from datasheet/EDA/measurement — invented dimensions are an automatic FAIL |
| "Standard wall thickness is fine" | MUST derive wall from manufacturing method (`enclosure-design.md` §Step 2 table) — FDM/SLA/molding minimums differ |
| "The model looks correct in code" | MUST render previews + transparent PCB placeholder before delivery — render-inspect-iterate is non-negotiable |
| "STL exported without errors, ship it" | MUST pass the manifold HARD GATE (`--render` + zero geometry warnings) in `enclosure-design.md` §Step 7 first |
| "PLA is the obvious material" | MUST run the ≥3-candidate weighted matrix in `material-selection.md` — PLA fails outdoors and >50°C |
| "Docs are basically right" | MUST cross-check every documented dimension against `.scad` parameters (`documentation.md` §Step 5) |
| "Deliverable done, moving on" | MUST run the matching persona checklist in `references/review-checklist.md` before marking any capability complete |
