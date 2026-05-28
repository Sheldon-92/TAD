# Academic Research Capability Pack

Teaches AI agents HOW to do academic research — depth enforcement, citation integrity, quality scoring, and self-evaluation.

## Installation

### For Claude Code (default)

```bash
bash install.sh
```

This copies CAPABILITY.md → SKILL.md, all reference files, and scripts to `.claude/skills/academic-research/`.

### For other agents

```bash
bash install.sh --agent claude-code --target /path/to/skills/dir
```

### CV Tools Setup (optional)

The `image-analysis.py` script requires OpenCV. Run the setup script once:

```bash
bash scripts/setup-cv.sh
```

This creates a virtual environment at `~/.academic-research-cv-venv/` with opencv-python-headless, numpy, scikit-image, and Pillow.

## Capabilities

### 18 Reference Files

| Category | References | Coverage |
|----------|-----------|----------|
| **Protocol** (5) | research-protocol, zero-hallucination, scholar-eval, reflexion-cycle, fallback-chains | Methodology, citation integrity, quality scoring |
| **Domain** (3) | domain-biomedical, domain-physical, domain-social | Field-specific judgment rules |
| **Database** (2) | database-apis-general, database-apis-life-sciences | API templates for 20+ academic databases |
| **Skills** (5) | literature-search, statistics, writing, visualization, experiment-design | Research task execution |
| **Multimodal** (2) | multimodal-research, pattern-extraction | Image analysis methodology, ornamental pattern comparison |
| **Quantitative** (1) | quantitative-analysis | CV tool decision matrix and output interpretation |

### Scripts

| Script | Purpose |
|--------|---------|
| `academic-search.sh` | Query academic databases (Semantic Scholar, OpenAlex, PubMed, arXiv, Europeana, USDA) |
| `image-analysis.py` | Quantitative CV tools (edges, colors, match, frequency, features) |
| `setup-cv.sh` | One-time venv setup for image-analysis.py |
| `requirements.txt` | Python dependencies for CV tools |

## Usage Examples

### Example 1: Literature Survey (Pilot Test)

This pack was validated with a cross-cultural soy sauce usage study:

```
Research question: "How do soy sauce usage patterns differ across Chinese, Japanese, and Thai cuisines?"
Tier: Literature survey (20-40 tool calls)
Protocol: 6-phase research-protocol.md

Results:
- 17 tool calls across Semantic Scholar, OpenAlex, USDA FoodData, WebSearch
- 11 verified references (5 peer-reviewed papers, 3 USDA database entries, 3 web sources)
- ScholarEval score: 0.626 (Minor Revision threshold met)
- Report: .tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md
```

### Example 2: Database Query

```bash
bash scripts/academic-search.sh semantic-scholar "CRISPR gene therapy" --limit 10
bash scripts/academic-search.sh usda-food "quinoa" --limit 5
bash scripts/academic-search.sh openalex "machine learning drug discovery" --limit 10
```

### Example 3: Image Analysis

```bash
# Extract contour lines from artifact photo
~/.academic-research-cv-venv/bin/python3 scripts/image-analysis.py edges artifact.jpg --output contours.svg

# Compare two artifacts visually
~/.academic-research-cv-venv/bin/python3 scripts/image-analysis.py match bowl_A.jpg bowl_B.jpg --output similarity.json
```

## Activation Keywords

The pack auto-activates on these keywords in user messages:

学术, academic, 论文, paper, 文献, literature, meta-analysis, 元分析, PRISMA, systematic review, 系统性综述, PubMed, 文献综述, 学术研究, 科研

## Limitations

### Identified During Pilot Testing (2026-05-28)

1. **USDA coverage gaps**: FoodData Central indexes US-market products. Thai, Indonesian, and other Southeast Asian food items may lack specific entries. The pack's fallback-chains.md handles this via WebSearch fallback, but web sources are less authoritative than primary food composition databases.

2. **ScholarEval calibration**: The 0.60 threshold for "Minor Revision" may be too lenient for a literature survey tier (pilot scored 0.626). The rubric was designed for publication-quality research; its calibration for AI-agent-produced surveys is untested.

3. **Citation chain depth**: Forward citation analysis via Semantic Scholar API returns only the most recent citing papers (sorted by recency, not relevance). For highly-cited papers (>200 citations), the returned set may miss the most relevant citing works.

4. **Multimodal reference files (Phase 5) untested in pilot**: The pilot test exercised database queries and literature synthesis but did not test multimodal-research.md or pattern-extraction.md in practice. These references need their own pilot validation.

5. **CV tool threshold calibration**: similarity_score thresholds (0.7/0.4) and frequency period ranges (<50/50-200/>200 px) in quantitative-analysis.md are general benchmarks. Per-corpus calibration guidance exists in the reference but was not tested with real artifact images.

6. **No Chinese-language database support**: Semantic Scholar and OpenAlex index primarily English-language papers. Chinese food science literature (e.g., in CNKI/Wanfang) is underrepresented, creating a systematic bias when researching Chinese culinary topics.

7. **Single-session context dependency**: The zero-hallucination rule requires all citations to come from tool results in the current session. Long research tasks that span multiple sessions lose citation provenance. The pack does not yet have a mechanism for persisting verified citations across sessions.

## Architecture

- **Type**: Reference-based capability pack
- **Pack version**: 0.1.0
- **Source**: 86 ScienceClaw skills consolidated into 18 reference files (Phases 1-6)
- **CONSUMES**: Research question + optional domain constraints
- **PRODUCES**: Evidence-grounded research report + methodology section + citation audit trail
