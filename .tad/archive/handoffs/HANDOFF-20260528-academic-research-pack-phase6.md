---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/capability-packs/academic-research", ".claude/skills/academic-research"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Academic Research Pack — Phase 6: Python CV Quantitative Analysis Tools

**From:** Alex | **To:** Blake | **Date:** 2026-05-28
**Epic:** EPIC-20260527-academic-research-pack.md (Phase 6/7)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
A Python toolkit (`scripts/image-analysis.py`) for quantitative image analysis in academic research. Five capabilities: (1) edge/contour extraction → SVG export, (2) color histogram analysis, (3) SIFT/ORB feature matching for cross-image similarity, (4) Fourier transform for repeating pattern frequency detection, (5) feature vector extraction for statistical clustering. Plus a reference file documenting when and how to use each tool.

### 1.2 Why
Phase 5 gave the pack qualitative image analysis methodology (Claude vision). This Phase adds the quantitative layer — precise measurements, numerical similarity scores, and exportable vector data. The user's ornamental pattern research specifically needs: line abstraction (edge→SVG), cross-artifact similarity scoring (SIFT matching), and repeating pattern frequency analysis (Fourier).

### 1.3 Intent Statement
**不是要做的**:
- ❌ NOT a full computer vision pipeline — targeted tools for research, not a CV framework
- ❌ NOT training ML models — using established CV algorithms (Canny, SIFT, FFT)
- ❌ NOT replacing Claude vision — complementing it (Claude = what to analyze, Python = how to measure)

---

## 📚 Project Knowledge

**⚠️ Blake 必须注意**:
1. **包安装安全原则** (global CLAUDE.md) — 永远用虚拟环境安装依赖。`uv` preferred over `pip`.
2. **Hook Shell Portability** (architecture.md) — Scripts must work on macOS (Darwin). No Linux-only dependencies.

---

## 2. Technical Design

### 2.1 Python Script: `scripts/image-analysis.py`

Single entry point with subcommands (same pattern as academic-search.sh):

```bash
# Edge extraction → SVG contour lines
python3 scripts/image-analysis.py edges input.jpg --output edges.svg --threshold 100

# Color histogram analysis
python3 scripts/image-analysis.py colors input.jpg --output colors.json --bins 32

# Cross-image SIFT/ORB matching
python3 scripts/image-analysis.py match image1.jpg image2.jpg --output match-result.json --method orb

# Fourier frequency analysis (repeating patterns)
python3 scripts/image-analysis.py frequency input.jpg --output frequency.json

# Feature vector extraction (for clustering)
python3 scripts/image-analysis.py features input.jpg --output features.json
```

### 2.2 Output Formats

Each subcommand produces structured, research-citable output:

| Subcommand | Output Format | Key Fields |
|-----------|---------------|-----------|
| `edges` | SVG file | Contour paths as `<path d="..."/>`, dimensions preserved, scale metadata |
| `colors` | JSON | `{histogram: [{bin_start, bin_end, count}...], dominant_colors: [{hex, percentage}...]}` |
| `match` | JSON | `{matches: N, good_matches: N, similarity_score: 0.0-1.0, matched_keypoints: [{x1,y1,x2,y2}...]}` |
| `frequency` | JSON | `{dominant_frequencies: [{freq_x, freq_y, magnitude, period_px}...], power_spectrum_path: "..."}` |
| `features` | JSON | `{dimensions: N, vector: [...], method: "orb/sift", keypoint_count: N}` |

### 2.3 Dependencies

```
opencv-python-headless>=4.8  # headless = no GUI dependency (server-safe)
numpy>=1.24
scikit-image>=0.21
Pillow>=10.0
```

⚠️ Install in venv: `uv venv .venv && uv pip install -r requirements.txt` or `python3 -m venv .venv && .venv/bin/pip install -r requirements.txt`

### 2.4 Reference File: `quantitative-analysis.md`

New reference file documenting:
- When to use each tool (decision matrix: "If you need X → use subcommand Y")
- How to interpret outputs (what does similarity_score 0.7 mean? what frequency range indicates repeating patterns?)
- Integration with qualitative analysis (Claude vision identifies motif → Python measures it)
- Limitations and caveats (SIFT patent status, ORB as free alternative, edge detection sensitivity to image quality)
- Example research workflows (ornamental pattern comparison end-to-end, food ingredient color analysis)

---

## 3. Implementation Steps

### Task 1: Create requirements.txt + venv setup script (10 min)
1. Write `.tad/capability-packs/academic-research/scripts/requirements.txt`
2. Write `.tad/capability-packs/academic-research/scripts/setup-cv.sh`:
   - Creates venv at `.academic-research-cv-venv/` in user's home
   - Installs dependencies via `uv pip` (fallback to `pip`)
   - Validates import works: `python3 -c "import cv2; print(cv2.__version__)"`
   - Prints success message with activation instructions

### Task 2: Write image-analysis.py (40 min)
1. Implement 5 subcommands using argparse
2. Each subcommand: validate input file exists + path safety check (`os.path.realpath(path)` must not contain `..` after resolution; reject symlinks pointing outside script's parent directory), process, write structured output
3. `edges`: Canny edge detection → findContours → convert to SVG path data → write .svg
4. `colors`: Convert to HSV → calcHist → find dominant colors via k-means → write .json
5. `match`: Detect ORB keypoints → BFMatcher → ratio test → compute similarity score → write .json
6. `frequency`: Convert to grayscale → FFT2 → find peaks in magnitude spectrum → write .json
7. `features`: Extract ORB descriptors → flatten to feature vector → write .json
8. Include `--help` for each subcommand with usage examples
9. All numeric outputs with consistent precision (4 decimal places for scores, integers for pixel coordinates)

### Task 3: Write quantitative-analysis.md (20 min)
1. Decision matrix: when to use each subcommand
2. Output interpretation guide with concrete thresholds:
   - similarity_score: >0.7 = strong match, 0.4-0.7 = partial, <0.4 = distinct
   - dominant_frequency period: <50px = fine texture, 50-200px = medium pattern, >200px = large motif
3. Integration examples with Phase 5 qualitative workflow
4. Limitations section

### Task 4: Update pack + re-install (10 min)
1. Add quantitative-analysis.md to references/
2. Update CAPABILITY.md: add to Quick Rule Index + Step 1 (quantitative analysis signals)
3. Update install.sh: copy scripts/image-analysis.py + scripts/requirements.txt + scripts/setup-cv.sh
4. Re-run install.sh, verify 18 total reference files

---

## 4. Files to Create/Modify

| # | File | Action |
|---|------|--------|
| 1 | .tad/capability-packs/academic-research/scripts/image-analysis.py | CREATE |
| 2 | .tad/capability-packs/academic-research/scripts/requirements.txt | CREATE |
| 3 | .tad/capability-packs/academic-research/scripts/setup-cv.sh | CREATE |
| 4 | .tad/capability-packs/academic-research/references/quantitative-analysis.md | CREATE |
| 5 | .tad/capability-packs/academic-research/CAPABILITY.md | MODIFY |
| 6 | .tad/capability-packs/academic-research/install.sh | MODIFY |
| 7 | .claude/skills/academic-research/ (via re-install) | MODIFY |

---

## 9. Acceptance Criteria

| # | Requirement | Verification |
|---|------------|-------------|
| AC1 | image-analysis.py exists | `test -f .tad/capability-packs/academic-research/scripts/image-analysis.py` |
| AC2 | 5 subcommands implemented | `python3 .tad/capability-packs/academic-research/scripts/image-analysis.py --help 2>&1 \| grep -oE 'edges\|colors\|match\|frequency\|features' \| sort -u \| wc -l` = 5 |
| AC3 | setup-cv.sh creates venv + installs deps | `bash .tad/capability-packs/academic-research/scripts/setup-cv.sh 2>&1 \| tail -1` contains "success" or "installed" |
| AC4 | edges subcommand produces SVG | Test with any .jpg/png: output file ends in .svg and contains `<path` |
| AC5 | match subcommand produces similarity_score | Test with 2 images: output JSON contains `similarity_score` field |
| AC6 | quantitative-analysis.md has decision matrix | `grep -c 'edges\|colors\|match\|frequency\|features' .tad/capability-packs/academic-research/references/quantitative-analysis.md` ≥ 10 |
| AC7 | Interpretation thresholds documented | `grep -cE '0\.[0-9]+.*match\|period.*px\|dominant' .tad/capability-packs/academic-research/references/quantitative-analysis.md` ≥ 3 |
| AC8 | 18 total reference files | `ls .claude/skills/academic-research/references/*.md \| wc -l` = 18 |
| AC9 | No hardcoded paths in Python script | `grep -c '/Users/\|/home/' .tad/capability-packs/academic-research/scripts/image-analysis.py` = 0 |
| AC10 | requirements.txt has pinned versions | `grep -cE '>=\|==' .tad/capability-packs/academic-research/scripts/requirements.txt` ≥ 3 |
| AC11 | Path traversal protection | `grep -c 'realpath\|abspath' .tad/capability-packs/academic-research/scripts/image-analysis.py` ≥ 1 |

---

## 10. Important Notes

### 10.1 ORB over SIFT
Use ORB (Oriented FAST and Rotated BRIEF) as the default feature detector, not SIFT. SIFT was patented until 2020 and some OpenCV builds don't include it. ORB is free, fast, and sufficient for ornamental pattern matching. Offer SIFT as `--method sift` option if available.

### 10.2 Headless OpenCV
Use `opencv-python-headless` (not `opencv-python`) to avoid X11/GUI dependencies. The scripts produce file output, not visual displays.

### 10.3 Test Images
For AC4/AC5 testing, Blake can use any available image file or generate a test pattern:
```python
# Generate a simple test pattern
from PIL import Image, ImageDraw
img = Image.new('RGB', (200, 200), 'white')
draw = ImageDraw.Draw(img)
for i in range(0, 200, 20):
    draw.line([(i, 0), (i, 200)], fill='black', width=2)
img.save('/tmp/test-pattern.png')
```

### 10.4 Sub-Agent Suggestions
- code-reviewer: verify Python code quality, error handling, arg validation
- security-auditor: verify no path traversal in file I/O

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Language | Python (not bash) | CV libraries are Python-native; bash would need subprocess wrappers |
| 2 | Feature detector | ORB default, SIFT optional | Patent-free, broadly compatible, sufficient for pattern research |
| 3 | OpenCV variant | headless | No GUI needed; avoids X11 dependency on servers/CI |
| 4 | Venv approach | Separate venv via setup-cv.sh | Per global CLAUDE.md: never pollute global env; user runs setup once |
| 5 | Output format | JSON (structured) + SVG (edges) | Machine-readable for downstream analysis; SVG preserves vector paths |
