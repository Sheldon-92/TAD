# Visualization Judgment Rules

Extracted from ScienceClaw scientific visualization skills.
Rules with specific thresholds, hex codes, and numeric standards only.

---

## 1. Resolution and Format Requirements

**R-VIZ-001: Raster DPI by Content Type**
- Photographs / microscopy: 300-600 DPI
- Line art (graphs, plots): 600-1200 DPI or vector format
- Presentations / web: 150 DPI
- Screen / notebook: 72-100 DPI
- Minimum submission threshold: 300 DPI for all journal figures

> Source: skills/scientific-visualization/SKILL.md

**R-VIZ-002: File Format Selection**
- Vector preferred for all plots: PDF, EPS, SVG
- Raster fallback: TIFF or PNG only
- NEVER use JPEG for scientific data (lossy compression creates artifacts)
- RGB for digital display, CMYK conversion for print

> Source: skills/scientific-visualization/SKILL.md

**R-VIZ-003: Plotly Static Export**
- `fig.write_image('figure.png', scale=3)` yields ~300 DPI equivalent
- Requires kaleido package for static image export

> Source: skills/plotly/SKILL.md

---

## 2. Journal Figure Dimensions

**R-VIZ-010: Column Width by Publisher**

| Journal   | Single column | Double column | Min font |
|-----------|--------------|---------------|----------|
| Nature    | 89 mm (3.5 in) | 183 mm (7.2 in) | 5 pt    |
| Science   | 85 mm         | 174 mm        | 6 pt     |
| Cell      | 85 mm         | 178 mm        | -        |
| PNAS      | 87 mm         | 178 mm        | 6 pt     |
| IEEE      | 3.5 in (89 mm)| 7.16 in       | 8 pt     |
| Elsevier  | 90 mm         | 190 mm        | 6 pt     |

> Source: skills/scientific-visualization/SKILL.md, skills/visualization/SKILL.md

**R-VIZ-011: Figure Size Implementation**
```python
# Nature single-column
fig, ax = plt.subplots(figsize=(3.5, 2.5))  # 89mm ~ 3.5in
# Science single-column
fig, ax = plt.subplots(figsize=(2.17, 2.5))  # 55mm ~ 2.17in
```

> Source: skills/scientific-visualization/SKILL.md

---

## 3. Typography Standards

**R-VIZ-020: Font Size Minimums at Final Print Size**
- Axis labels: 7-9 pt
- Tick labels: 6-8 pt
- Panel labels: 8-12 pt (bold)
- Absolute minimum readable: 6 pt at final size
- Sentence case for labels: "Time (hours)" not "TIME (HOURS)"
- Always include units in parentheses

> Source: skills/scientific-visualization/SKILL.md

**R-VIZ-021: Font Family**
- Sans-serif only: Arial, Helvetica, Calibri
- Implementation:
```python
mpl.rcParams['font.family'] = 'sans-serif'
mpl.rcParams['font.sans-serif'] = ['Arial', 'Helvetica']
mpl.rcParams['font.size'] = 8
mpl.rcParams['axes.labelsize'] = 9
mpl.rcParams['xtick.labelsize'] = 7
mpl.rcParams['ytick.labelsize'] = 7
```

> Source: skills/scientific-visualization/SKILL.md

---

## 4. Colorblind-Safe Palettes

**R-VIZ-030: Okabe-Ito Palette (Primary Recommendation)**
Distinguishable by all types of color vision deficiency:
```python
okabe_ito = [
    '#E69F00',  # orange
    '#56B4E9',  # sky blue
    '#009E73',  # bluish green
    '#F0E442',  # yellow
    '#0072B2',  # blue
    '#D55E00',  # vermillion
    '#CC79A7',  # reddish purple
    '#000000',  # black
]
```

> Source: skills/scientific-visualization/SKILL.md

**R-VIZ-031: Colormap Selection Rules**
- Sequential data: `viridis`, `plasma`, `cividis` (perceptually uniform)
- Diverging data (centered): `RdBu_r`, `PuOr`, `BrBG` (colorblind-safe)
- NEVER use: `jet`, `rainbow` (not perceptually uniform)
- Avoid: red-green diverging maps (~8% of males cannot distinguish)
- Always test figures in grayscale

> Source: skills/scientific-visualization/SKILL.md, skills/seaborn/SKILL.md

**R-VIZ-032: Seaborn Palette Mapping**
- Categorical: `"colorblind"` (default recommendation), `"deep"`, `"muted"`
- Sequential heatmaps: `"rocket"`, `"mako"` (wide luminance range)
- Diverging: `"vlag"` (blue-red), `"icefire"` (blue-orange)

> Source: skills/seaborn/SKILL.md

---

## 5. Statistical Plot Conventions

**R-VIZ-040: Volcano Plot Thresholds**
- Significance line: padj < 0.05 (`ax.axhline(-np.log10(0.05))`)
- Fold-change lines: |log2FC| > 1 (`ax.axvline(-1)`, `ax.axvline(1)`)
- Color coding: red = up-regulated (padj<0.05 AND log2FC>1), blue = down-regulated (padj<0.05 AND log2FC<-1), grey = not significant

> Source: skills/visualization/SKILL.md, skills/data-viz-plots/SKILL.md

**R-VIZ-041: Error Bar Reporting**
- MUST specify type in figure caption: SD, SEM, or CI
- Default recommendation: 95% CI (`errorbar=('ci', 95)` in seaborn)
- Always report sample size (n) in figure or caption
- Show individual data points when feasible (box + strip overlay)

> Source: skills/scientific-visualization/SKILL.md

**R-VIZ-042: Significance Markers**
- Standard notation: * p<0.05, ** p<0.01, *** p<0.001
- Always include n in figure or caption

> Source: skills/scientific-visualization/SKILL.md

**R-VIZ-043: Heatmap Conventions**
- Correlation matrices: mask upper triangle, use `RdBu_r` centered at 0
- Annotate cells with `fmt='.2f'`
- Set `square=True` for correlation heatmaps
- Clustered heatmaps: Ward's method + Euclidean metric, z-score normalization

> Source: skills/scientific-visualization/SKILL.md, skills/seaborn/SKILL.md

---

## 6. Multi-Panel Figure Rules

**R-VIZ-050: Panel Labels**
- Bold uppercase letters: A, B, C (most journals)
- Nature exception: lowercase a, b, c
- Position: `ax.text(-0.15, 1.05, 'A', transform=ax.transAxes, fontsize=10, fontweight='bold')`
- Use `GridSpec` for flexible layouts, not nested subplots

> Source: skills/scientific-visualization/SKILL.md

**R-VIZ-051: Consistency Requirements**
- Same font family and sizes across all panels
- Same color coding for same variables across panels
- Adequate white space: `hspace=0.4, wspace=0.4` as starting point
- Align panels along edges

> Source: skills/scientific-visualization/SKILL.md

---

## 7. Chart Selection Rules

**R-VIZ-060: Data Type to Plot Type Mapping**
| Data relationship | Recommended plot |
|---|---|
| Continuous x, continuous y | scatterplot, lineplot, regplot |
| Continuous x, categorical y | violinplot, boxplot, stripplot |
| Single continuous variable | histplot, kdeplot, ecdfplot |
| Matrix / correlation | heatmap, clustermap |
| Pairwise relationships | pairplot, jointplot |
| Time series with groups | lineplot with hue + CI bands |
| Group comparisons | box + strip overlay |

> Source: skills/seaborn/SKILL.md

**R-VIZ-061: Seaborn Function Level Selection**
- Axes-level (`scatterplot`, `boxplot`, `heatmap`): use when building custom multi-panel layouts with `ax=` parameter
- Figure-level (`relplot`, `catplot`, `displot`): use for automatic faceting via `col`/`row`, sizing via `height`/`aspect`

> Source: skills/seaborn/SKILL.md

---

## 8. Schematic Quality Thresholds

**R-VIZ-070: Document-Type Quality Scoring**
| Document type | Quality threshold (out of 10) |
|---|---|
| Journal (Nature, Science) | 8.5 |
| Conference paper | 8.0 |
| Thesis / dissertation | 8.0 |
| Grant proposal | 8.0 |
| Preprint (arXiv, bioRxiv) | 7.5 |
| Technical report | 7.5 |
| Poster | 7.0 |
| Presentation / slides | 6.5 |

> Source: skills/scientific-schematics/SKILL.md

**R-VIZ-071: Schematic Quality Rubric (5 dimensions, 0-2 each)**
1. Scientific accuracy (correct concepts, notation, relationships)
2. Clarity and readability (hierarchy, easy to understand)
3. Label quality (complete, readable, consistent)
4. Layout and composition (logical flow, balanced, no overlaps)
5. Professional appearance (publication-ready)

> Source: skills/scientific-schematics/SKILL.md

**R-VIZ-072: Schematic Technical Minimums**
- Line weights: minimum 0.5 pt, typical 1-2 pt
- Text: minimum 7-8 pt at final size
- Labels: minimum 10 pt for diagram text
- Resolution: 300+ DPI for raster, vector preferred

> Source: skills/scientific-schematics/SKILL.md

---

## 9. Publication Checklist

**R-VIZ-080: Pre-Submission Verification**
- [ ] Resolution >= 300 DPI (line art >= 600 DPI)
- [ ] File format: vector for plots, TIFF/PNG for images
- [ ] Figure size matches journal column width
- [ ] All text readable at final size (>= 6 pt)
- [ ] Colors are colorblind-friendly (tested with simulator)
- [ ] Figure works in grayscale
- [ ] All axes labeled with units in parentheses
- [ ] Error bars present with type specified in caption
- [ ] Panel labels present, bold, consistent
- [ ] No chart junk: no 3D effects, unnecessary gridlines, shadows
- [ ] Fonts consistent across all manuscript figures
- [ ] Statistical significance clearly marked
- [ ] Bar charts start at zero unless scientifically justified
- [ ] Legend clear and complete

> Source: skills/scientific-visualization/SKILL.md

---

## 10. Anti-Patterns

**R-VIZ-090: Prohibited Practices**
1. JPEG for scientific graphs (lossy artifacts)
2. `jet` or `rainbow` colormaps (perceptually non-uniform)
3. Red-green only encoding (8% male color blindness)
4. 3D effects on 2D data (distorts perception)
5. Truncated y-axis on bar charts without justification
6. Missing error bars on statistical summaries
7. Missing units on axis labels
8. Inconsistent styling across figures in same manuscript
9. Relying on color alone without redundant encoding (markers, line styles)

> Source: skills/scientific-visualization/SKILL.md, skills/matplotlib/SKILL.md
