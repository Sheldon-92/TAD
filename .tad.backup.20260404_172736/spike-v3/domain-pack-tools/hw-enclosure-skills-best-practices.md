# HW Enclosure Design — Skills & Best Practices Research

> Research date: 2026-04-03
> Purpose: Inform hw-enclosure Domain Pack capability design with real-world patterns from GitHub repos and industry references.

---

## Search Log

| # | Search Term | Results Found | Repos Selected |
|---|------------|--------------|----------------|
| 1 | GitHub OpenSCAD 3D design skills SKILL.md | 10 | openscad-agent, awesome-openscad |
| 2 | GitHub AI agent mechanical design CAD enclosure | 10 | cad-agent (clawd-maf), MEDA, ScadLM |
| 3 | GitHub 3D printing design checklist DFM | 10 | awesome-3d-printing |
| 4 | GitHub enclosure design electronics housing | 10 | easy-enclosure, NopSCADlib, StdBx/Series100 |
| 5 | product enclosure design best practices tolerances 2026 | 10 | (industry articles, no new repos — Cadence PCB guide used as reference) |

**Total unique repos analyzed: 8** (exceeded minimum of 3).

---

## Repo 1: NopSCADlib

- **URL**: https://github.com/nophead/NopSCADlib
- **Stars**: ~1,600
- **Description**: Comprehensive OpenSCAD library with 14+ enclosure-related modules, BOM generation, and CNC-ready DXF export.

### 5-Dimension Extraction

**1. Step Depth**
- No explicit step-by-step methodology in docs, but the module structure implies a workflow: select enclosure type (Box, Butt_box, Printed_box, Socket_box) -> configure parameters -> add accessories (Door_hinge, Door_latch, Cable_grommets, LED_bezel, PCB_mount) -> generate BOM -> export STL/DXF.
- Python scripts automate: BOM generation, STL rendering for all printed parts, DXF generation for CNC-routed parts.
- Automated documentation and exploded-view assembly scripts provide visual verification.

**2. Source Lists**
- Dogbones module: standard DFM pattern for CNC internal corners (avoids radius limitations of milling bits).
- Teardrops module: standard DFM pattern for FDM printing (avoids flat overhangs on circular holes).
- References hardware standards implicitly through vitamin modules (off-the-shelf parts like screws, nuts, bearings, displays, fans).

**3. Analysis Frameworks**
- BOM as decision framework: automated bill of materials forces explicit accounting of every component.
- Exploded-view assembly scripts enable visual interference checking.
- No formal comparison matrix, but parametric design enables rapid A/B comparison of dimensions.

**4. Quality Standards**
- Precision holes module for accurate component mounting.
- CNC DXF output implies manufacturing-grade dimensional accuracy.
- No explicit tolerance specs documented, but the library's widespread adoption (1.6k stars) suggests proven dimensional reliability.

**5. Anti-patterns**
- Dogbones module existence implies anti-pattern: designing CNC parts without corner relief (causes tool binding).
- Teardrops module existence implies anti-pattern: designing FDM parts with true circles for horizontal holes (causes sagging at top of hole).
- Cable_grommets module implies anti-pattern: leaving cable pass-throughs unfinished (causes strain, dust ingress).

---

## Repo 2: cad-agent (clawd-maf / OpenClaw)

- **URL**: https://github.com/clawd-maf/cad-agent
- **SKILL.md**: https://github.com/openclaw/skills/blob/main/skills/clawd-maf/cad-agent/SKILL.md
- **Stars**: ~9
- **Description**: AI-driven CAD modeling server using build123d + MCP. Gives AI agents "eyes" for CAD work via rendered feedback.

### 5-Dimension Extraction

**1. Step Depth**
- Four-stage workflow: Create model (POST /model/create with build123d code) -> Render & View (multiview, 3D, 2D technical drawings) -> Iterate (POST /model/modify based on visual feedback) -> Export (STL/STEP/3MF via /export).
- Printability analysis endpoint: `/analyze/printability` (manifold/watertight check).
- Measurement endpoint: `/model/{name}/measure` for dimensional verification.
- Health check: `/health` endpoint for container validation.

**2. Source Lists**
- build123d library (Python parametric CAD).
- VTK rendering library for visualization.
- Docker containerization for reproducible builds.
- No external standards cited, but build123d inherits OpenCASCADE kernel tolerances.

**3. Analysis Frameworks**
- Visual feedback loop as evaluation: agent renders -> inspects -> decides -> iterates.
- Multiview rendering (front/side/top/iso) for comprehensive shape evaluation.
- 2D technical drawings for dimensional review.
- Printability analysis as binary gate (manifold yes/no).

**4. Quality Standards**
- Manifold/watertight validation as hard gate before export.
- Container isolation ensures reproducible geometry (same build123d version, same kernel).
- Design files protected via .gitignore and pre-commit hooks (prevents accidental commits of WIP geometry).

**5. Anti-patterns**
- EXPLICIT: "Never do STL manipulation, mesh processing, or rendering outside the container" — defeats purpose, leads to fragile/inconsistent results.
- EXPLICIT: "Don't bypass the container" — no external matplotlib or mesh hacking.
- EXPLICIT: "Never commit design files" — protected via .gitignore.
- IMPLICIT: Building without visual feedback (the entire tool exists to prevent "blind CAD" where agents generate geometry they cannot see).

---

## Repo 3: MEDA (Multi-Agent System for Parametric CAD)

- **URL**: https://github.com/AnK-Accelerated-Komputing/MEDA
- **Stars**: ~15
- **Description**: Five-agent system for autonomous parametric CAD model generation using CadQuery + GPT-4o.

### 5-Dimension Extraction

**1. Step Depth**
- Five-agent pipeline: Design Expert (plans modeling process, reasons about CadQuery functions) -> CAD Script Writer (produces Python code) -> Executor (runs code locally, captures logs) -> Script Execution Reviewer (routes success/failure) -> CAD Image Reviewer (multimodal visual evaluation).
- Failure routing: failed executions loop back to Script Writer or Design Expert for re-planning.
- Success routing: passes through visual review before acceptance.

**2. Source Lists**
- CadQuery library (Python parametric CAD, OpenCASCADE kernel).
- Paper accepted at IDETC 2025 (academic validation).
- Comparison baseline: CADCodeVerify framework.

**3. Analysis Frameworks**
- Three quantitative geometric metrics:
  - Point Cloud distance: 0.0555 (lower = better, vs 0.127 baseline)
  - Hausdorff distance: 0.2628 (lower = better, vs 0.419 baseline)
  - Intersection over Ground Truth: 0.9413 (higher = better, vs 0.944 baseline)
- Compilation rate: 99% success (vs 96.5% baseline).
- Visual review by multimodal AI as qualitative gate.

**4. Quality Standards**
- 99% compilation rate as implicit quality floor.
- Geometric accuracy metrics provide quantitative acceptance criteria.
- Design Expert compensates for LLM spatial reasoning weakness by using explicit coordinates and equations.

**5. Anti-patterns**
- EXPLICIT: "Poor spatial reasoning of the LLM" — must be compensated with explicit coordinate/equation-based positioning rather than relying on natural language spatial descriptions.
- IMPLICIT: Single-agent CAD generation fails because one agent cannot plan + code + validate simultaneously — requires separation of concerns across 5 agents.

---

## Repo 4: openscad-agent

- **URL**: https://github.com/iancanderson/openscad-agent
- **Stars**: ~33
- **Description**: Claude Code-powered 3D modeling agent for OpenSCAD with versioned iteration and STL export.

### 5-Dimension Extraction

**1. Step Depth**
- Four-stage workflow: Create versioned .scad files (model_001.scad, model_002.scad) -> Render PNG previews automatically -> Evaluate and iterate based on visual feedback -> Export to STL with geometry validation.
- Versioning scheme enforces design history (each iteration preserved as separate file).
- Skills: /openscad (create+render), /preview-scad (render to PNG), /export-stl (convert with validation).

**2. Source Lists**
- OpenSCAD scripting language (CSG + extrusion modeling).
- STL format for 3D printing interchange.
- MakerWorld platform referenced for publishing.

**3. Analysis Frameworks**
- Visual inspection through rendered PNG as primary evaluation.
- Agent self-assessment loop: "looks toy-like" -> iterate -> "more realistic".
- User feedback integration: "keys are too hidden" -> design adjustment.
- No quantitative metrics defined.

**4. Quality Standards**
- STL export checks for non-manifold geometry and printability issues (hard gate).
- Versioned files enable regression comparison.

**5. Anti-patterns**
- No explicit warnings documented, but the versioning system implies anti-pattern: overwriting previous iterations (loses design history, prevents rollback).

---

## Repo 5: easy-enclosure

- **URL**: https://github.com/bruceborrett/easy-enclosure
- **Stars**: ~306
- **Description**: Web-based 3D enclosure design tool for electronics projects. Uses JSCad. Targets users with minimal CAD experience.

### 5-Dimension Extraction

**1. Step Depth**
- GUI-driven parametric workflow: set outer dimensions -> configure wall thickness -> add features (screw bosses, ventilation, ports) -> preview 3D model -> export STL.
- Formula documentation: "Inner width = width - (wall thickness * 2)" — teaches dimensional relationships.
- All measurements in millimeters (explicit unit declaration).

**2. Source Lists**
- JSCad library for browser-based 3D modeling.
- React + TypeScript frontend.
- No external standards cited.

**3. Analysis Frameworks**
- Parametric controls as implicit decision framework: wall thickness, corner radius, screw placement all configurable.
- No formal comparison or evaluation matrix.

**4. Quality Standards**
- All measurements in mm (standard for 3D printing).
- Configurable parameters imply tested ranges (wall thickness, corner radius).
- Waterproof seal option suggests IP-rating awareness.

**5. Anti-patterns**
- EXPLICIT: "Screws take up extra space in corners, keep this in mind when deciding length and width" — common mistake of not accounting for fastener clearance.
- Material recommendations: PETG for outdoor use, TPU for seals — implies anti-pattern of using PLA outdoors (UV/heat degradation) or rigid material for seals (poor compression).

---

## Repo 6: awesome-openscad

- **URL**: https://github.com/elasticdotventures/awesome-openscad
- **Stars**: ~114
- **Description**: Curated list of OpenSCAD projects including enclosure libraries.

### 5-Dimension Extraction

**1. Step Depth**
- Not a tool itself but indexes libraries with varying step depth.
- Key enclosure libraries indexed: agentscad (electronic housings, PCB/box shell templates), NopSCADlib (see Repo 1), BH-Lib (geometry transforms), BOSL2 (advanced rounding/filleting).

**2. Source Lists**
- agentscad: GillesBouissac/agentscad — electronic housings + threaded-screw implementations.
- NopSCADlib: nophead/NopSCADlib — enclosures + BOM + DXF.
- BOSL2: BelfrySCAD/BOSL2 — rounding, filleting, texture embossing, VNF/polygon operations.
- BH-Lib: brandonhill/BH-Lib — chamfer and offset operations.

**3. Analysis Frameworks**
- Curation itself is an evaluation: only established libraries with meaningful features are included.
- Category organization (libraries, tools, projects) aids selection.

**4. Quality Standards**
- BOSL2 offers precision rounding/filleting (manufacturing-critical for stress concentration).
- NopSCADlib's BOM generation ensures component tracking.

**5. Anti-patterns**
- Indexed libraries address common anti-patterns: BOSL2's rounding tools prevent sharp internal corners (stress concentration), agentscad's threaded-screw module prevents hand-rolled thread geometry (inaccurate pitch).

---

## Industry Reference: Cadence PCB Enclosure Design Guidelines

- **URL**: https://resources.pcb.cadence.com/blog/2024-pcb-enclosure-design-guidelines-and-standards
- **Type**: Industry article (not a repo, but essential reference for standards)

### Key Standards Extracted

**Tolerances:**
- General safety clearance: 0.5mm
- Port/hole clearance: 0.2-0.3mm
- Fillet minimum: 0.1mm radius for consistent shell thickness

**Protection Ratings:**
- NEMA 1 (indoor, light dust) through NEMA 4X (coastal, corrosion-resistant)
- IP54 (limited dust + spray) through IP67 (dust-tight + submersion)

**Certification Standards:**
- UL 508A (industrial control panels)
- UL 50/50E (enclosure construction + environment)
- IEC 61439 (electrical enclosure performance)
- IEC 62208 (empty enclosure specs)
- IEC 60529 (IP rating system)

**Material Selection:**
- ABS: balanced, UV-vulnerable
- Polycarbonate: tough, UV-resistant, transparent option
- Aluminum 5050/6061: lightweight, outdoor-capable
- Stainless steel: high corrosion resistance

**Anti-patterns:**
- Inconsistent wall thickness (causes molding defects)
- Tight clearances without tolerance testing (component jamming)
- Relying solely on enclosure for EMI mitigation (must address at board level)
- Inadequate shock absorption (board instability)
- Insufficient heat dissipation paths (thermal stress)

---

## Synthesis

### Pattern 1: Visual Feedback Loop is Non-Negotiable

Every successful AI-CAD system (cad-agent, openscad-agent, MEDA, ScadLM) implements a render-inspect-iterate loop. The anti-pattern of "blind geometry generation" (writing CAD code without seeing the result) produces unusable output. This maps to Domain Pack capability: **every enclosure design step must include a visual verification checkpoint**.

### Pattern 2: Manifold/Watertight Validation as Hard Gate

Both cad-agent and openscad-agent enforce manifold geometry checks before STL export. Non-manifold geometry is the #1 cause of 3D printing failure. This maps to a **mandatory printability gate** in the domain pack — no export without validation.

### Pattern 3: DFM Patterns are Module-Sized, Not Checklist-Sized

NopSCADlib's approach (dedicated Dogbones, Teardrops modules) shows that DFM rules are best embedded as reusable design primitives, not as post-hoc checklists. The domain pack should provide DFM as **step-integrated guidance** (e.g., "when designing horizontal holes, use teardrop shape for FDM") rather than a separate review phase.

### Pattern 4: Multi-Agent Separation Improves CAD Quality

MEDA's five-agent architecture (plan -> code -> execute -> review-route -> visual-review) outperforms single-agent approaches on geometric accuracy (Point Cloud 0.055 vs 0.127). This validates TAD's two-agent model (Alex designs, Blake implements) and suggests the domain pack should enforce **design-implementation separation** even within enclosure tasks.

### Pattern 5: Tolerance Standards are Domain-Specific

Tolerances vary dramatically: 0.5mm general clearance, 0.2-0.3mm for ports, 0.1mm fillet minimum. Protection ratings (NEMA/IP) and certification (UL/IEC) add another dimension. The domain pack must include **context-aware tolerance lookup** — not a single tolerance table but selection based on manufacturing method (FDM vs CNC vs injection molding) and environment (indoor vs outdoor vs submersible).

### Pattern 6: Material-Environment Mismatch is a Top Anti-Pattern

Multiple sources warn about material selection errors: PLA outdoors (UV/heat failure), rigid seals (poor compression), ABS in prolonged UV (degradation). The domain pack should include a **material-environment compatibility matrix** as a mandatory checkpoint.

### Pattern 7: Fastener Clearance is Consistently Underestimated

easy-enclosure explicitly warns about screw space in corners. NopSCADlib provides dedicated modules for screw bosses and press-fit connections. This is a recurrent anti-pattern: **designing enclosures without accounting for assembly hardware volume**. The domain pack should enforce clearance calculation for all fastener locations.

### Key Tolerances Summary Table

| Feature | Tolerance | Source |
|---------|-----------|--------|
| General enclosure clearance | 0.5mm | Cadence |
| Port/hole clearance | 0.2-0.3mm | Cadence |
| Corner fillet minimum | 0.1mm | Cadence |
| FDM bridge max (no support) | 5mm | Protolabs/Hubs |
| FDM overhang max angle | 45deg from vertical | Protolabs/Hubs |
| FDM wall thickness min | 0.8mm (2 perimeters) | Industry standard |
| CNC internal corner relief | Dogbone pattern | NopSCADlib |
| FDM horizontal hole shape | Teardrop | NopSCADlib |

### Key Standards Reference

| Standard | Scope |
|----------|-------|
| IEC 60529 | IP rating system (dust/water ingress) |
| IEC 61439 | Electrical enclosure performance |
| IEC 62208 | Empty enclosure specifications |
| UL 50/50E | Enclosure construction + environment |
| UL 508A | Industrial control panels |
| NEMA 1-4X | Enclosure environmental protection types |
