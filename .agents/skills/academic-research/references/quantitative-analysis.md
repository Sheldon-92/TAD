# Quantitative Image Analysis — Tool Selection and Interpretation Guide

Decision matrix and interpretation rules for the `image-analysis.py` toolkit. Covers when to use each subcommand, how to interpret numeric outputs, and integration with qualitative analysis (Phase 5 multimodal-research.md).

> Source: OpenCV documentation (cv2.Canny, cv2.ORB_create, cv2.calcHist, numpy.fft), scikit-image feature extraction conventions. Thresholds are empirical starting points — calibrate per corpus.
>
> **Cross-reference**: For qualitative image analysis methodology (observation protocol, measurement fallbacks), see [multimodal-research.md](multimodal-research.md). For ornamental pattern vocabulary and comparison framework, see [pattern-extraction.md](pattern-extraction.md). This file covers the quantitative measurement layer.

---

## Quick Reference Table

| Rule | Threshold / Requirement | Context |
|------|------------------------|---------|
| Tool decision | Use decision matrix below — qualitative first, quantitative to confirm | All image tasks |
| Similarity strong match | similarity_score > 0.7 (ORB/SIFT) | Cross-image matching |
| Similarity partial match | similarity_score 0.4–0.7 | Cross-image matching |
| Similarity distinct | similarity_score < 0.4 | Cross-image matching |
| Fine texture period | dominant frequency period < 50 px | Fourier analysis |
| Medium pattern period | dominant frequency period 50–200 px | Fourier analysis |
| Large motif period | dominant frequency period > 200 px | Fourier analysis |
| Minimum keypoints for reliable match | ≥ 50 keypoints per image | Feature matching |
| Edge threshold range | 50–200 (lower = more edges, higher = fewer) | Canny edge detection |
| Color histogram bins | 16–64 (fewer = coarser grouping, more = finer) | Color analysis |
| Feature vector comparison | Cosine similarity on mean descriptor vectors | Clustering |

---

## 1. Decision Matrix: When to Use Each Subcommand

| Research Question | Subcommand | Input | Output | Next Step |
|------------------|-----------|-------|--------|-----------|
| "What are the contour lines of this pattern?" | `edges` | Single image | SVG with contour paths | Import SVG into vector editor for L2/L3 abstraction (pattern-extraction.md §2) |
| "What colors dominate this artifact?" | `colors` | Single image | JSON: histogram + dominant colors (hex) | Compare hex values across artifacts using multimodal-research.md §5 feature matrix |
| "How similar are these two artifacts visually?" | `match` | Two images | JSON: similarity_score (0.0–1.0) | Map to pattern-extraction.md §4.3 structural similarity (score > 0.7 ≈ Score 4-5) |
| "Does this textile have a repeating pattern? What's the repeat unit size?" | `frequency` | Single image | JSON: dominant frequencies + period in pixels | Period < 50 px = fine texture, 50-200 = medium, > 200 = large motif |
| "I need to cluster 20 artifacts by visual similarity" | `features` | Each image separately | JSON: feature vector per image | Compute pairwise cosine similarity → hierarchical clustering (pattern-extraction.md §6.3) |

### Subcommand Combination Workflows

| Workflow | Steps | Use Case |
|----------|-------|----------|
| Ornamental pattern comparison | 1. `edges` both artifacts → SVG 2. `match` both → similarity_score 3. `frequency` each → period comparison | Cross-cultural motif study |
| Color palette analysis | 1. `colors` each artifact → dominant hex 2. Compare hex across artifacts | Material/pigment identification |
| Collection clustering | 1. `features` all images → vectors 2. Compute pairwise cosine similarity 3. Hierarchical clustering | Museum collection organization |

---

## 2. Output Interpretation Guide

### 2.1 `edges` Output (SVG)

| Output Element | Meaning | Research Use |
|---------------|---------|-------------|
| `<path d="..."/>` | Individual contour boundary | One continuous edge in the image |
| Contour count | Number of distinct boundaries found | More contours = more complex image; filter by minimum path length for significant features |
| Threshold parameter | Canny edge sensitivity | Lower (50) captures weak edges + noise; higher (200) captures only strong edges |

**Calibration**: Start at threshold 100. If too many noise contours → increase to 150–200. If significant edges are missing → decrease to 50–80. Document the threshold used — it affects reproducibility.

### 2.2 `colors` Output (JSON)

| Field | Meaning | Research Use |
|-------|---------|-------------|
| `dominant_colors[].hex` | K-means cluster center as hex | Direct comparison with multimodal-research.md §2.1 color recording |
| `dominant_colors[].percentage` | Area coverage of this color | Quantifies "approximately 35%" claims from qualitative observation |
| `histogram` | Per-channel distribution (HSV) | Hue histogram reveals color palette breadth; narrow peaks = limited palette |

**Calibration**: Use bins=32 (default) for general analysis. Use bins=16 for coarse color grouping (e.g., "warm vs cool"). Use bins=64 for fine discrimination (e.g., distinguishing similar earth tones).

### 2.3 `match` Output (JSON)

| Field | Meaning | Interpretation |
|-------|---------|---------------|
| `similarity_score` | Ratio of good matches to total possible keypoints | > 0.7 = strong match (same design or very close variant) |
| | | 0.4–0.7 = partial match (shared features, different execution) |
| | | < 0.4 = distinct (low visual correspondence) |
| `good_matches` | Keypoint pairs passing Lowe's ratio test (0.75) | Raw count; compare relative to `keypoints1`/`keypoints2` |
| `matched_keypoints[]` | Spatial coordinates of matched features | Visualize to check if matches cluster in one region or spread evenly |

**Caveats**:
- **Minimum keypoints**: If either image has < 50 keypoints, the score is unreliable — report as "insufficient keypoints for reliable matching."
- **Scale sensitivity**: ORB is partially scale-invariant but performs best when images are within 2× size difference. Resize to similar dimensions before matching.
- **Threshold calibration**: 0.7/0.4 are starting points derived from general CV benchmarks. For a specific artifact corpus, establish your own thresholds by matching known-similar and known-distinct pairs, then finding the discrimination boundary.

### 2.4 `frequency` Output (JSON)

| Field | Meaning | Interpretation |
|-------|---------|---------------|
| `dominant_frequencies[].period_px` | Spatial period in pixels | Size of the repeating unit in the image |
| | | < 50 px = fine texture (weave, grain, stipple) |
| | | 50–200 px = medium pattern (small motifs, borders) |
| | | > 200 px = large motif (medallions, main field design) |
| `dominant_frequencies[].magnitude` | Signal strength | Higher = more regular/prominent repetition |
| `power_spectrum_path` | Grayscale visualization of frequency domain | Bright spots away from center = strong periodic patterns |

**Caveats**:
- Period in pixels depends on image resolution — convert to physical units using known scale (pixels/mm from calibration).
- Non-periodic images (portraits, landscapes) will show diffuse spectra with no dominant peaks. This is expected, not an error.
- Edge artifacts: strong edges at image borders create frequency artifacts. Crop to the pattern region before analysis.

### 2.5 `features` Output (JSON)

| Field | Meaning | Research Use |
|-------|---------|-------------|
| `vector` | Mean ORB/SIFT descriptor | Input for pairwise cosine similarity computation |
| `dimensions` | Vector length (ORB: 32, SIFT: 128) | Must match across images for valid comparison |
| `keypoint_count` | Detected features | < 10 keypoints = insufficient data; > 500 = rich texture |

**Clustering workflow**: Extract features for all images → build NxN cosine similarity matrix → apply hierarchical clustering (Ward's method) → produce dendrogram per pattern-extraction.md §6.3.

---

## 3. Integration with Qualitative Analysis

| Phase | Qualitative (Phase 5) | Quantitative (Phase 6) | Integration |
|-------|----------------------|----------------------|-------------|
| Observation | Structured description (multimodal-research.md §2) | — | Start with qualitative observation always |
| Color | "Dominant color: #8B6914" (visual estimate) | `colors` → exact hex + percentage | Quantitative confirms or corrects visual estimate |
| Similarity | Similarity Score 0–5 (pattern-extraction.md §4.3) | `match` → similarity_score 0.0–1.0 | Map: >0.7 ≈ Score 4-5, 0.4-0.7 ≈ Score 2-3, <0.4 ≈ Score 0-1 |
| Pattern repeat | "Motif repeats ~12 times across border" (visual count) | `frequency` → period in px | Quantitative measures period precisely; visual count confirms |
| Contour | L1 raw trace (pattern-extraction.md §2.1) | `edges` → SVG | SVG provides reproducible starting point for L2/L3 abstraction |
| Clustering | "These 3 artifacts look similar" (subjective grouping) | `features` → cosine similarity matrix | Quantitative supports or challenges qualitative grouping |

**Rule**: Always do qualitative analysis first (Phase 5 methodology). Use quantitative tools to confirm, refine, or challenge qualitative observations. Never skip qualitative observation and go straight to quantitative — numbers without context are meaningless.

---

## 4. Limitations

| Limitation | Impact | Mitigation |
|-----------|--------|------------|
| ORB is not fully rotation-invariant | May miss matches if images are rotated > 30° | Pre-rotate images to similar orientation, or use SIFT (if available) |
| SIFT may not be available | `opencv-python-headless` may lack SIFT (patent expired but some builds exclude it) | Script auto-falls back to ORB with warning |
| Color analysis assumes uniform lighting | Museum photography with even lighting works well; field photos may skew colors | Note lighting conditions per multimodal-research.md §2.1 "Capture conditions" |
| Frequency analysis assumes periodicity | Non-periodic images produce diffuse spectra (not an error) | Only apply to images where repetition is expected |
| Feature vectors are method-dependent | ORB vectors and SIFT vectors are NOT comparable | Always use the same method across a comparison set |
| Similarity thresholds are approximate | 0.7/0.4 are general benchmarks, not calibrated per domain | Establish corpus-specific thresholds using known-pair calibration |

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | Correct Alternative |
|-------------|-------------|-------------------|
| Running `match` without qualitative observation first | Numbers without context — 0.65 similarity means nothing without knowing what features matched | Complete multimodal-research.md §2 observation for both images first |
| Using similarity_score > 0.7 as proof of historical connection | Feature matching measures visual correspondence, not historical relationship | "Quantitative similarity_score 0.72 (ORB, 847 keypoints); historical connection requires textual evidence per pattern-extraction.md §4.3 critical rule" |
| Comparing ORB features against SIFT features | Different descriptor spaces; cosine similarity is meaningless across methods | Use the same --method for all images in a comparison set |
| Reporting frequency period in pixels without scale | Pixels are resolution-dependent; 100px could be 1mm or 10cm | Convert to physical units using known calibration or state "resolution-dependent" |
| Running `edges` with default threshold on all images | Threshold 100 is a starting point, not universal | Calibrate per image: test 50/100/150/200, document which threshold captured the target features |
| Clustering < 5 images with `features` | Too few points for meaningful clustering structure | Use pairwise `match` for small sets (< 10); `features` clustering for ≥ 10 images |
