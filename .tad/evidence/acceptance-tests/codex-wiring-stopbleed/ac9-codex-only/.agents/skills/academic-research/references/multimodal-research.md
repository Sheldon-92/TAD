# Multimodal Research — Image Analysis Methodology

Rules for systematic image analysis in academic research. Covers documentation photography, cross-image comparison, image-to-text extraction, and citation of visual evidence. Every rule specifies WHAT to measure and HOW to record it.

> Source: Methodology derived from digital art history imaging standards (AIC photodocumentation guidelines), conservation science measurement protocols, and museum cataloguing practice (CIDOC-CRM, CCO). Adapted for AI agent context per tad-mapping-blueprint.md.
>
> **Cross-reference**: For ornamental pattern / motif-specific analysis, defer to [pattern-extraction.md](pattern-extraction.md) — its 0-5 similarity scoring and cross-cultural feature matrix supersede the general comparison framework in §5 below.

---

## Quick Reference Table

| Rule | Threshold / Requirement | Context |
|------|------------------------|---------|
| Observation-before-interpretation | Complete structured description BEFORE any analysis | All image tasks |
| Color recording (artifacts) | Hex value + nearest Munsell notation (if reference available) | Material culture, archaeology |
| Color recording (biology/food) | Hex value + RAL/Pantone if industry-standard | Food science, biology |
| Dimension recording | mm relative to known reference object; state scale if no reference | All measured images |
| Spatial relationships | Compass directions (N/S/E/W) + percentage of total area | Layout description |
| Resolution minimum for detail claims | ≥ 300 DPI for sub-mm features; ≥ 72 DPI for gross morphology | All images |
| Insufficient resolution protocol | State "insufficient resolution for this detail" — do NOT infer | Absolute rule |
| Cross-image comparison minimum | ≥ 3 shared features in feature matrix | Comparative studies |
| Image citation fields | 6 mandatory fields (see §4) | Every image reference |
| Confidence qualifier threshold | Any measurement from image without calibration → add "±N%" qualifier | Uncalibrated images |

---

## 1. When to Use Image Analysis in Research

| Research Context | Image Role | Example |
|-----------------|-----------|---------|
| Documentation | Primary evidence — record current state of artifact/specimen | Museum collection photography, field specimen |
| Comparison | Analytical tool — identify similarities/differences across items | Cross-cultural motif comparison, morphological taxonomy |
| Evidence | Supporting data — visual confirmation of a textual claim | Histological staining results, plating presentation |
| Quantification | Measurement source — extract numeric data from visual information | Particle size distribution, leaf area measurement |
| Communication | Output — present findings visually to readers | Comparison plates, annotated diagrams |

---

## 2. Structured Image Description Protocol

For EVERY image analyzed in a research context, complete this checklist BEFORE interpreting. Record each field; write "not determinable" for fields that cannot be assessed.

### 2.1 Observation Checklist (mandatory before interpretation)

| Field | How to Record | Example |
|-------|-------------|---------|
| **Subject identification** | What the image depicts (object type, specimen ID if known) | "Ceramic bowl, accession #BM-1985.0401.1" |
| **Dimensions** | In mm with reference object; if no reference: relative proportions with ±10% qualifier | "Height ~45mm (relative to 10cm ruler in frame, ±5%)" |
| **Color** | Hex value from dominant regions; Munsell if artifact context and chart accessible | "Body: #C4A882; Glaze: #2B5F3A (approx. 5GY 4/6)" |
| **Spatial layout** | Compass directions + percentage of total area per region | "Central motif occupies ~35% of surface; border band along N and S edges, ~10% each" |
| **Material/texture** | Observable surface qualities only — do NOT infer composition | "Matte finish with visible granular texture; hairline crack SW quadrant" |
| **Condition** | Damage, wear, restoration visible in the image | "Chip on rim (NE, ~8mm); surface abrasion across center" |
| **Capture conditions** | Lighting, angle, background, visible color reference | "Diffuse overhead lighting; 45° angle; neutral gray background; no color checker" |

### 2.2 Measurement Fallback Rules

| Situation | Action |
|-----------|--------|
| Calibrated reference in frame (ruler, color checker) | Extract measurements directly; record calibration source |
| Known object of standard size in frame | Estimate proportionally; add ±5% qualifier |
| No reference object | Record as relative proportions only ("approximately 1/3 of total height"); add ±10% qualifier |
| Insufficient resolution for claimed detail | State: "insufficient resolution for this detail at current magnification" — do NOT estimate |
| Tool limitation (no pixel-measurement access) | Record relative proportions with confidence qualifier; state: "precise measurement requires manual tool access" |

**Absolute rule**: Claude vision CANNOT reliably extract absolute mm measurements or exact Munsell codes from photographs. When precise values are needed, record relative proportions and flag for manual verification. Do NOT output fabricated precise measurements.

---

## 3. Image-to-Text Extraction Rules

### 3.1 Objectivity Protocol

| Phase | What to Do | What NOT to Do |
|-------|-----------|---------------|
| **Describe** | Record observable features (shape, color hex, spatial position, texture) | Do not attribute meaning, function, or cultural significance |
| **Measure** | Record dimensions, proportions, counts of repeated elements | Do not estimate measurements you cannot derive from the image |
| **Compare** | Note structural similarities to other described images using feature matrix | Do not claim influence, derivation, or chronological relationship from visual similarity alone |
| **Interpret** | State interpretation SEPARATELY, citing supporting literature | Do not embed interpretation into description |

### 3.2 Description Quality Thresholds

| Quality Metric | Minimum Threshold |
|---------------|-------------------|
| Observable features per image | ≥ 5 distinct features recorded |
| Numeric values (dimensions, proportions, counts) | ≥ 2 per image |
| "Not determinable" fields acknowledged | Every field attempted; gaps explicit |
| Interpretation separated from observation | 0 interpretive words in observation section |

Interpretive words to exclude from observation: "beautiful", "crude", "influenced by", "derived from", "symbolic of", "represents", "typical of", "obviously", "clearly intended".

---

## 4. Image Citation Rules

### 4.1 Mandatory Citation Fields

Every image used as research evidence requires ALL 6 fields:

| Field | Content | Example |
|-------|---------|---------|
| **Source institution** | Museum, archive, collection, or photographer | "British Museum, Department of Asia" |
| **Accession/ID** | Unique identifier from the holding institution | "1985,0401.1" |
| **Capture information** | Photographer (if known), date, conditions | "Museum photography dept., 2019; diffuse lighting, neutral background" |
| **Resolution** | DPI or pixel dimensions | "4000×3000 px (300 DPI at 34×25cm)" |
| **License/rights** | Usage rights applicable to this reproduction | "CC BY-NC-SA 4.0" or "© British Museum, used with permission" |
| **Reproduction chain** | Steps from original to your analysis | "Original artifact → museum photograph → digital scan → cropped for analysis" |

### 4.2 Provenance Chain Distortion Awareness

Each step in the reproduction chain introduces potential distortion:

| Step | Distortion Risk | Mitigation |
|------|----------------|------------|
| Artifact → photograph | Lighting alters apparent color; angle distorts proportions | Record lighting conditions; use color checker |
| Photograph → digital scan | Compression artifacts; color profile mismatch | Use TIFF/PNG; embed ICC profile |
| Digital → cropped/resized | Resolution loss; aspect ratio change | Record original dimensions; avoid upscaling |
| Screen display → analysis | Monitor calibration varies; gamma differences | Note: analysis performed on [calibrated/uncalibrated] display |

State the full chain in methods. If any step is unknown, write: "Reproduction chain: [known steps]; intermediate processing unknown."

---

## 5. Cross-Image Comparison Methodology

### 5.1 Feature Matrix Approach

For comparing ≥ 2 images, construct a feature matrix with rows = features and columns = images.

**Minimum requirements:**
- ≥ 3 shared features per comparison (below 3, comparison is inconclusive)
- Same observation protocol applied to ALL images (asymmetric description invalidates comparison)
- Features must be independently observable (not derived from each other)

### 5.2 Feature Matrix Template

| Feature | Image A | Image B | Image C | Match Type |
|---------|---------|---------|---------|-----------|
| Overall shape | [describe] | [describe] | [describe] | Exact / Similar / Different |
| Dominant color (hex) | #XXXXXX | #XXXXXX | #XXXXXX | ΔE value if computable |
| Surface texture | [describe] | [describe] | [describe] | Exact / Similar / Different |
| Spatial organization | [describe] | [describe] | [describe] | Exact / Similar / Different |
| Repeated element count | N | N | N | ±N difference |
| [domain-specific feature] | ... | ... | ... | ... |

### 5.3 Similarity Scoring

| Similarity Type | Definition | Valid Inference |
|----------------|-----------|----------------|
| **Structural** | Same geometry at different scales | Shared design principle or manufacturing technique |
| **Stylistic** | Same visual aesthetic with different geometry | Shared cultural context (requires literature support) |
| **Chromatic** | Color palette overlap (ΔE ≤ 5 for perceptual match) | Same materials/pigments (requires material analysis confirmation) |
| **Compositional** | Same spatial arrangement of elements | Shared layout conventions (requires comparative examples) |

**Critical rule**: Visual similarity alone NEVER proves historical connection, influence, or derivation. Any such claim requires supporting textual evidence (cite both the image source AND corroborating literature).

---

## 6. Integration with Text-Based Research

| Integration Pattern | How |
|--------------------|-----|
| Image supports textual claim | Cite image with full provenance; describe specific feature that supports the claim |
| Image contradicts textual source | Note discrepancy explicitly; do NOT silently favor one over the other |
| Multiple images corroborate pattern | Use feature matrix to show systematic comparison; state N of M images showing the pattern |
| Image analysis generates new hypothesis | State as hypothesis, not finding; cite image evidence + note absence of textual confirmation |

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | Correct Alternative |
|-------------|-------------|-------------------|
| "The pattern is beautiful and intricate" | Aesthetic judgment, not observation | "The pattern consists of 12 radial elements, each ~15mm long, arranged at 30° intervals" |
| "The color is warm brown" | Vague, non-reproducible | "Dominant color: #8B6914 (dark goldenrod); secondary: #C4A882 (tan)" |
| "This is clearly influenced by Byzantine art" | Unsupported interpretive claim in observation | "Structural similarity to [specific artifact, accession #]: shared interlace pattern geometry. See [citation] for historical context." |
| "The artifact measures approximately 15cm" | Precision claim without calibration reference | "Height approximately 1.5× the width; absolute measurement requires physical access or calibrated reference in frame" |
| Citing "museum website" without accession number | Insufficient for academic provenance | Full 6-field citation per §4.1 |
| Describing only center of image | Incomplete observation → biased comparison | Complete spatial description per §2.1 (all quadrants + percentage coverage) |
