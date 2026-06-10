# Pattern Extraction — Visual Pattern Comparison Workflow

Specialized methodology for identifying, classifying, and comparing ornamental patterns across artifacts and cultures. Covers motif identification, line abstraction, cross-cultural comparison frameworks, and domain vocabulary.

> Source: Pattern terminology from Getty Art & Architecture Thesaurus (AAT). Classification framework adapted from Owen Jones, *The Grammar of Ornament* (1856) geometric typology and Washburn & Crowe symmetry analysis methodology. Cross-cultural comparison dimensions from material culture studies conventions. Adapted for AI agent context per tad-mapping-blueprint.md.
>
> **Cross-reference**: For general image analysis methodology (observation protocol, measurement fallbacks, image citation), see [multimodal-research.md](multimodal-research.md). This file specializes the general framework for ornamental pattern studies.

---

## Quick Reference Table

| Rule | Threshold / Requirement | Context |
|------|------------------------|---------|
| Motif identification minimum | ≥ 3 independent instances before declaring a "repeating element" | All pattern analysis |
| Line abstraction levels | 3 levels: raw trace → simplified contour → geometric primitive | Morphological comparison |
| Cross-cultural comparison features | ≥ 5 dimensions in feature matrix | Comparative studies |
| Similarity scoring | Structural + Stylistic scored independently (0-5 scale each) | Pattern matching |
| Provenance chain | 5 documented steps (artifact → analysis) | Every analyzed pattern |
| Vocabulary precision | Use specific terms from §3 glossary; avoid generic "design" or "decoration" | All written output |
| Feature matrix minimum | Rows ≥ features, columns ≥ artifacts; ≥ 3×3 for publishable comparison | Research output |
| Pattern repeat unit | Identify the smallest tile that reconstructs the full pattern via translation/rotation/reflection | Geometric analysis |

---

## 1. Motif Identification Protocol

### 1.1 Isolation Process

| Step | Action | Output |
|------|--------|--------|
| 1. Survey | Scan full artifact surface; record overall composition layout | Sketch or annotated photograph showing zones |
| 2. Segment | Divide surface into zones (border, field, medallion, spandrel, frieze) | Zone map with labels |
| 3. Isolate | Within each zone, identify repeated elements (≥ 3 instances = "motif") | Numbered motif inventory |
| 4. Classify | Assign each motif to geometric category per §2 | Classification table |
| 5. Measure | Record proportions of each motif relative to zone dimensions | Proportional measurements with ±10% qualifier |

### 1.2 Geometric Classification

Classify each isolated motif by its dominant geometry:

| Category | Defining Property | Examples |
|----------|------------------|----------|
| **Curvilinear** | Dominant curved lines; no straight edges | Spiral, scroll, tendril, S-curve, volute |
| **Rectilinear** | Dominant straight lines; angular intersections | Fret, key pattern, zigzag, chevron, stepped pyramid |
| **Radial** | Elements arranged around a central point | Rosette, star, wheel, sunburst, mandala |
| **Interlacing** | Lines crossing over/under each other in regular rhythm | Guilloche, knot, braid, Celtic interlace, chain |
| **Naturalistic** | Abstracted from organic forms (plant, animal) | Palmette, lotus, acanthus, arabesque, Tree of Life |
| **Composite** | Combines ≥ 2 categories above | Interlaced arabesque, scrolling palmette border |

**Rule**: A motif may belong to multiple categories. Record the PRIMARY category (dominant visual property) and up to 2 secondary categories.

---

## 2. Line Abstraction Methodology

Three progressive levels of abstraction, each serving a different analytical purpose.

### 2.1 Three Levels

| Level | Method | Purpose | Output |
|-------|--------|---------|--------|
| **L1: Raw trace** | Trace visible contours from photograph (freehand or vector tracing) | Document exactly what is visible | SVG or annotated image |
| **L2: Simplified contour** | Remove texture/damage; retain proportional relationships | Enable comparison across media/condition states | Clean line drawing |
| **L3: Geometric primitive** | Reduce to circles, arcs, straight lines, symmetry axes | Reveal underlying geometric construction | Geometric diagram with measurements |

### 2.2 Abstraction Rules

| Rule | Detail |
|------|--------|
| L1 → L2 threshold | Remove features < 5% of motif total area (noise/damage vs. intentional) |
| L2 → L3 threshold | Replace curves with best-fit arcs (R² ≥ 0.95); straighten lines within 3° of axis |
| Symmetry detection | Test for: reflection (bilateral), rotation (N-fold), translation (repeat), glide reflection |
| Symmetry tolerance | Allow ±5% dimensional deviation for handmade artifacts; ±1% for machine-produced |
| Documentation | Retain ALL three levels; do NOT discard L1 when producing L3 |

### 2.3 Repeat Unit Identification

The **repeat unit** is the smallest tile that reconstructs the full pattern through symmetry operations.

| Symmetry Type | Repeat Unit | Reconstruction |
|--------------|-------------|---------------|
| Translation only | Single tile | Shift in x and/or y |
| Rotation (N-fold) | 1/N of full circle | Rotate by 360°/N |
| Reflection | Half of symmetric element | Mirror across axis |
| Glide reflection | Single tile | Mirror + translate |
| Wallpaper group | Fundamental domain | Combination of the above (17 possible groups) |

---

## 3. Domain Vocabulary — Ornamental Pattern Terminology

### 3.1 Essential Pattern Terms

Use these specific terms instead of generic descriptions. Each term has a precise morphological definition.

| Term | Morphological Definition | Cultural Associations |
|------|------------------------|----------------------|
| **Guilloche** | Two or more interlaced bands forming a continuous chain of overlapping circles or loops | Greco-Roman architecture, Islamic metalwork, banknote security printing |
| **Arabesque** | Continuously flowing vegetal scroll with bifurcating stems; rhythmic, infinitely extensible | Islamic art (biomorphic type); Renaissance European adaptation |
| **Interlace** | Lines or bands that pass alternately over and under each other in regular sequence | Celtic, Norse, Islamic, Coptic, Lombardic — independent invention across cultures |
| **Palmette** | Fan-shaped stylized leaf or flower with radiating lobes from a single base | Ancient Egyptian, Greek anthemion, Sasanian, Mughal |
| **Meander** | Continuous line forming a series of right-angle turns (Greek key); may be single or double | Greek, Roman, Chinese (huiwen 回纹), Mesoamerican (stepped fret) |
| **Rosette** | Circular motif with petals or lobes radiating from a center point | Near Eastern (earliest ~3000 BCE), Gothic tracery, Mughal jali |

### 3.2 Extended Vocabulary

| Term | Definition |
|------|-----------|
| Acanthus | Spiny-leafed plant motif with deeply cut, curling lobes |
| Anthemion | Alternating palmette-and-lotus band |
| Cartouche | Framed panel (oval, rectangular, or scroll-edged) containing inscription or motif |
| Chevron | V-shaped or zigzag band |
| Diaper | All-over repeat of small identical motifs in grid or diamond arrangement |
| Egg-and-dart | Alternating ovoid and pointed element molding |
| Fret | Angular interlocking or meander pattern (see meander) |
| Grotesque | Fantastical composition of human, animal, and vegetal forms (Renaissance revival of Roman wall painting) |
| Lunette | Half-moon or semicircular decorative field |
| Ogee | S-curved (double-curved) arch or molding profile |
| Rinceau | Undulating vegetal scroll; continuous vine or tendril band |
| Trefoil / Quatrefoil | 3-lobed / 4-lobed symmetrical form |
| Volute | Spiral scroll, typically at column capital (Ionic, Corinthian) |

---

## 4. Cross-Cultural Comparison Framework

### 4.1 Feature Matrix Dimensions

For comparing patterns across cultures/periods, construct a matrix with these minimum 5 dimensions:

| Dimension | What to Record | How to Compare |
|-----------|---------------|---------------|
| **Motif type** | Classification per §1.2 (curvilinear, rectilinear, radial, interlacing, naturalistic, composite) | Same category = structural parallel |
| **Culture / period** | Source culture + date range (e.g., "Sassanian, 3rd-7th c. CE") | Temporal overlap enables contact hypothesis |
| **Material / technique** | Substrate (ceramic, textile, metal, stone) + production method (carved, woven, cast, painted) | Same technique may produce convergent forms |
| **Geometric construction** | Symmetry group + repeat unit proportions (from L3 abstraction) | Identical construction = strongest structural parallel |
| **Compositional role** | Position on artifact (border, field, medallion) + scale relative to surface | Same role across cultures suggests functional convention |

### 4.2 Comparison Feature Matrix Template

| Feature | Artifact A | Artifact B | Artifact C | Comparison |
|---------|-----------|-----------|-----------|-----------|
| Motif type | [§1.2 category] | [§1.2 category] | [§1.2 category] | Same / Related / Different |
| Culture + date | [culture, period] | [culture, period] | [culture, period] | [temporal overlap?] |
| Material + technique | [substrate + method] | [substrate + method] | [substrate + method] | Same / Different |
| Symmetry group | [wallpaper group or simpler] | [wallpaper group or simpler] | [wallpaper group or simpler] | Same / Related / Different |
| Repeat unit ratio (h:w) | [N:M ±5%] | [N:M ±5%] | [N:M ±5%] | ΔRatio |
| Compositional role | [border/field/medallion] | [border/field/medallion] | [border/field/medallion] | Same / Different |
| L3 overlay (A↔B) | [% area overlap] | [% area overlap] | — | Pairwise score |
| L3 overlay (A↔C) | [% area overlap] | — | [% area overlap] | Pairwise score |
| L3 overlay (B↔C) | — | [% area overlap] | [% area overlap] | Pairwise score |

**L3 overlay measurement method**: Superimpose L3 geometric primitives of two artifacts at matching scale. Measure overlap area using: (a) ImageJ/FIJI polygon selection + area measurement, (b) GIMP/Inkscape manual tracing + area calculation, or (c) visual estimation with qualifier "±15% estimated overlap." If no tool access, record as qualitative: "high / moderate / low overlap" and note "precise overlay requires vector tool access."

### 4.3 Similarity Scoring

Score structural and stylistic similarity independently on a 0-5 scale. Scores are cumulative — assign the HIGHEST score whose criteria are fully met.

| Score | Structural Similarity (cumulative) | Stylistic Similarity (cumulative) |
|-------|----------------------|---------------------|
| 0 | No shared geometric features from §4.1 dimensions | No visual resemblance to a non-specialist viewer |
| 1 | 1 shared §4.1 feature, BUT different symmetry group | Same broad geometric category only (e.g., both curvilinear) |
| 2 | 2-3 shared §4.1 features, BUT different symmetry group | Similar proportions or spatial density |
| 3 | Same symmetry group AND same repeat unit type (subsumes shared features) | Recognizably similar aesthetic; a researcher would group them for comparison |
| 4 | Score 3 AND similar repeat unit proportions (ΔRatio ≤ 10%) | Could be mistaken for same tradition by a non-specialist |
| 5 | Score 4 AND L3 geometric overlay ≥ 90% area (per §4.2 measurement method) | Indistinguishable without provenance data |

**Disambiguation**: If a pair shares 3 features INCLUDING the same symmetry group, assign Score 3 (not Score 2). The symmetry group match is the decisive criterion separating Scores 2 and 3.

**Critical rule**: High similarity score (4-5) does NOT prove historical connection. Independent invention, convergent evolution from shared material constraints, and intermediary transmission all produce high similarity without direct contact. Any claim of connection requires textual/archaeological evidence beyond visual analysis.

---

## 5. Provenance and Distortion Chain

Every pattern analyzed for research must document its provenance chain:

| Step | Document | Distortion Risk |
|------|----------|----------------|
| 1. Original artifact | Location, date, material, dimensions, condition | Physical degradation alters visible pattern |
| 2. Collection context | Museum/collection, accession #, excavation report | Decontextualization from original architectural/functional setting |
| 3. Photography | Photographer, date, lighting, angle, lens | Perspective distortion, color shift, shadow occlusion |
| 4. Digital reproduction | Scan resolution, file format, color profile | Compression artifacts, gamut mapping |
| 5. Analysis processing | Cropping, tracing, abstraction level | Each abstraction step is an interpretation — document decisions |

---

## 6. Research Output Formats

### 6.1 Comparison Plate

Side-by-side image grid with:
- Consistent scale (indicate if not possible)
- Same orientation (or state rotation applied)
- Feature annotations (numbered, referencing feature matrix)
- Caption with full provenance for each image

### 6.2 Feature Extraction Table

Tabular format per §4.2 template. Publish as supplementary material if > 10 artifacts.

### 6.3 Similarity Dendrogram

Hierarchical clustering visualization based on feature matrix distances. State:
- Distance metric used (Euclidean on normalized features, Jaccard for categorical)
- Clustering method (UPGMA, Ward's)
- Number of features included
- Bootstrap support values if applicable (≥ 70% for reliable branches)

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | Correct Alternative |
|-------------|-------------|-------------------|
| "This pattern shows clear Islamic influence" | Unsubstantiated historical claim from visual data alone | "Structural similarity score 4/5 with [specific artifact]; historical contact documented in [citation]" |
| "The design is a meander" (when actually a spiral scroll) | Wrong term — meander is specifically right-angle turns | Use §3 glossary definitions precisely; "continuous spiral scroll (rinceau)" |
| Comparing a 3000 BCE seal impression with a 15th CE textile | Missing temporal and material context | Feature matrix must include culture/period and material/technique columns; state the 4500-year gap explicitly |
| "Palmette motifs are found worldwide, suggesting universal human aesthetic" | Unfalsifiable generalization | "Palmette appears independently in [list cultures with dates]; convergent development from fan-shaped leaf abstraction is one hypothesis (see [citation])" |
| Tracing only L3 (geometric) without retaining L1 (raw) | Discards evidence of handmade variation | Retain all 3 abstraction levels per §2.2 documentation rule |
| Reporting similarity score without stating which features were compared | Non-reproducible result | "Structural similarity 3/5 based on: motif type (match), symmetry group (match), repeat ratio (similar), material (different), role (match)" |
