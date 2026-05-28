# ScienceClaw Skill Taxonomy

> Phase 1 of Academic Research Pack Epic
> Source: /tmp/scienceclaw-study/skills/ (285 directories verified)
> Analysis date: 2026-05-28

## Summary Statistics

| Metric | Value |
|--------|-------|
| Total skill directories | 285 |
| Skills with SKILL.md | 285 |
| Skills with scripts/ | 42 |
| Skills with references/ | 38 |
| Skills referencing runtime deps | 37 (memory text mentions, 0 actual imports) |

### Distribution by Cluster

| Cluster | Count | Priority 1 | Priority 2 | Priority 3 |
|---------|-------|-----------|-----------|-----------|
| literature | 13 | 5 | 5 | 3 |
| database | 38 | 12 | 16 | 10 |
| research-workflow | 21 | 8 | 8 | 5 |
| writing | 17 | 6 | 7 | 4 |
| analysis | 8 | 4 | 3 | 1 |
| statistics | 8 | 4 | 3 | 1 |
| visualization | 13 | 3 | 6 | 4 |
| computation | 21 | 3 | 8 | 10 |
| domain-natural | 30 | 6 | 14 | 10 |
| domain-social | 8 | 2 | 4 | 2 |
| ml-ai | 15 | 2 | 7 | 6 |
| scienceclaw-core | 14 | 3 | 5 | 6 |
| utility | 79 | 2 | 4 | 73 |
| **Total** | **285** | **60** | **90** | **135** |

**Priority 1 ratio: 60/285 = 21%** (within the ≤30% target)

---

## Complete Taxonomy Table

### Legend
- **Priority**: 1 (must-have) / 2 (important) / 3 (nice-to-have)
- **Anti-Slop**: H (specific thresholds/numbers) / M (domain-specific, no hard numbers) / L (generic knowledge)
- **TAD Mapping**: judgment-rule / executable-reference / skip
- **Runtime Deps**: none / memory / mcp:{name} / code-execution / cross-skill:{name} / science-evolution
- **Confidence**: high (deep-read) / low (metadata-only)

---

### Literature Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 1 | literature-search | literature | Multi-database search orchestrating Semantic Scholar, OpenAlex, arXiv, PubMed, CrossRef | 1 | H | judgment-rule | none | high |
| 2 | systematic-review | literature | PRISMA 2020 systematic review pipeline: protocol→search→screen→extract→synthesize→report | 1 | H | judgment-rule | none | high |
| 3 | citation-analysis | literature | Citation networks, bibliometric indicators, research fronts, h-index | 1 | M | judgment-rule | none | low |
| 4 | literature-review | literature | Comprehensive multi-database literature reviews | 1 | M | judgment-rule | none | low |
| 5 | paper-analysis | literature | Read, summarize, critically analyze scientific papers | 1 | M | judgment-rule | none | low |
| 6 | academic-deep-research | literature | Transparent research with APA 7th citations, evidence hierarchy | 2 | H | judgment-rule | memory | low |
| 7 | citation-management | literature | Search Google Scholar/PubMed, extract metadata, generate BibTeX | 2 | M | executable-reference | none | low |
| 8 | crossref-search | literature | CrossRef API for DOI resolution, citation counts, metadata | 2 | M | executable-reference | none | low |
| 9 | lit-synthesizer | literature | PubMed/bioRxiv search, LLM summarize, citation graphs | 2 | M | judgment-rule | none | low |
| 10 | academic-literature-search | literature | Academic literature search and citation management | 2 | L | skip | none | low |
| 11 | dblp-search | literature | CS bibliography via DBLP API | 3 | M | executable-reference | none | low |
| 12 | literature | literature | Literature search and review (umbrella) | 3 | L | skip | none | low |
| 13 | search-strategy | literature | COPYRIGHT NOTICE — limited metadata | 3 | L | skip | none | low |

### Database Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 14 | semantic-scholar | database | Semantic Scholar Graph API with TLDR, citation graphs | 1 | H | executable-reference | none | low |
| 15 | openalex-database | database | 250M+ works via OpenAlex API, powerful filtering | 1 | H | executable-reference | none | low |
| 16 | pubmed-search | database | PubMed/MEDLINE via NCBI E-utilities, MeSH terms | 1 | H | executable-reference | none | low |
| 17 | arxiv-search | database | arXiv preprints via Atom API | 1 | M | executable-reference | none | low |
| 18 | uniprot-protein | database | UniProt REST API for protein data | 1 | H | executable-reference | none | low |
| 19 | chembl-drug | database | ChEMBL REST API for drug-target interactions, IC50, Ki | 1 | H | executable-reference | none | low |
| 20 | ncbi-entrez | database | NCBI E-utilities for GenBank, Gene, SNP, ClinVar | 1 | H | executable-reference | none | low |
| 21 | pdb-structure | database | RCSB PDB API for 3D protein structures | 1 | M | executable-reference | none | low |
| 22 | world-bank-data | database | World Bank Indicators API for development data | 1 | H | executable-reference | none | low |
| 23 | clinicaltrials-database | database | ClinicalTrials.gov API v2 | 1 | H | executable-reference | none | low |
| 24 | kegg-pathway | database | KEGG REST API for pathways, genes, compounds | 1 | H | executable-reference | none | low |
| 25 | gene-database | database | NCBI Gene via E-utilities/Datasets API | 1 | H | executable-reference | none | low |
| 26 | openalex-search | database | OpenAlex for author, institution, concept data | 2 | M | executable-reference | none | low |
| 27 | arxiv-database | database | arXiv Atom API with scripts | 2 | M | executable-reference | none | low |
| 28 | pubmed-database | database | Direct REST access to PubMed with advanced queries | 2 | H | executable-reference | none | low |
| 29 | chembl-database | database | ChEMBL with scripts | 2 | H | executable-reference | none | low |
| 30 | uniprot-database | database | UniProt with scripts | 2 | H | executable-reference | none | low |
| 31 | pdb-database | database | RCSB PDB with references | 2 | M | executable-reference | none | low |
| 32 | string-database | database | STRING API for protein-protein interactions | 2 | H | executable-reference | none | low |
| 33 | ensembl-database | database | Ensembl genome REST API | 2 | M | executable-reference | none | low |
| 34 | reactome-database | database | Reactome REST API for pathway analysis | 2 | M | executable-reference | none | low |
| 35 | clinvar-database | database | NCBI ClinVar for variant pathogenicity | 2 | H | executable-reference | none | low |
| 36 | open-targets | database | Open Targets GraphQL for gene-drug-disease | 2 | M | executable-reference | none | low |
| 37 | opentargets-database | database | Open Targets Platform detailed | 2 | M | executable-reference | none | low |
| 38 | pubchem-compound | database | PubChem PUG REST for 110M+ compounds | 2 | H | executable-reference | none | low |
| 39 | pubchem-database | database | PubChem with scripts | 2 | H | executable-reference | none | low |
| 40 | ssrn-econpapers | database | SSRN + RePEc/IDEAS for social science papers | 2 | M | executable-reference | none | low |
| 41 | legal-search | database | CourtListener + Harvard Case Law + EUR-Lex | 2 | M | executable-reference | none | low |
| 42 | geo-database | database | NCBI GEO for gene expression datasets | 2 | M | executable-reference | none | low |
| 43 | biorxiv-search | database | bioRxiv semantic search via Valyu | 3 | L | skip | none | low |
| 44 | clinical-trials-search | database | ClinicalTrials.gov via Valyu semantic | 3 | L | skip | none | low |
| 45 | drug-discovery-search | database | ChEMBL + DrugBank + FDA via Valyu | 3 | L | skip | none | low |
| 46 | gnomad-database | database | gnomAD for population allele frequencies | 3 | H | executable-reference | none | low |
| 47 | kegg-database | database | KEGG direct REST | 3 | M | executable-reference | none | low |
| 48 | census-data | database | US Census Bureau API | 3 | M | executable-reference | none | low |
| 49 | wikidata-knowledge | database | Wikidata SPARQL queries | 3 | M | executable-reference | none | low |
| 50 | wikipedia-search | database | Wikipedia MediaWiki API | 3 | L | skip | none | low |
| 51 | copernicus-climate | database | Copernicus Climate Data Store for ERA5 | 3 | M | executable-reference | none | low |

### Research Workflow Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 52 | experiment-design | research-workflow | Sample size, randomization, controls, study protocols | 1 | H | judgment-rule | none | low |
| 53 | hypothesis-generation | research-workflow | Structured hypothesis formulation from observations | 1 | M | judgment-rule | none | low |
| 54 | peer-review | research-workflow | Structured peer review following journal criteria | 1 | M | judgment-rule | none | low |
| 55 | deep-research | research-workflow | Autonomous multi-step deep research | 1 | M | judgment-rule | none | low |
| 56 | scholar-evaluation | research-workflow | ScholarEval framework for research quality assessment | 1 | H | judgment-rule | none | low |
| 57 | research-ethics | research-workflow | IRB protocol, informed consent, data management plans | 1 | M | judgment-rule | none | low |
| 58 | reproducibility | research-workflow | Pre-registration, open data, replication study design | 1 | M | judgment-rule | none | low |
| 59 | fact-verification | research-workflow | Verify scientific claims against evidence | 1 | M | judgment-rule | none | low |
| 60 | scientific-critical-thinking | research-workflow | GRADE evidence grading, Cochrane Risk of Bias | 2 | H | judgment-rule | none | low |
| 61 | scientific-brainstorming | research-workflow | Creative research ideation, interdisciplinary connections | 2 | L | judgment-rule | none | low |
| 62 | scientific-problem-selection | research-workflow | Research problem selection with references | 2 | M | judgment-rule | none | low |
| 63 | creative-thinking-for-research | research-workflow | Cognitive science frameworks for CS/AI research | 2 | M | judgment-rule | none | low |
| 64 | experimental-design | research-workflow | Design experiments with power analysis | 2 | H | judgment-rule | none | low |
| 65 | hypothesis-gen | research-workflow | Hypothesis generation workflow | 2 | M | judgment-rule | none | low |
| 66 | research-reflection | research-workflow | Post-task reflection and lesson storage | 2 | M | judgment-rule | science-evolution | low |
| 67 | research-grants | research-workflow | NSF/NIH/DOE/DARPA/Taiwan NSTC proposals | 2 | H | judgment-rule | none | low |
| 68 | asreview-screening | research-workflow | ASReview active learning for paper screening | 3 | H | executable-reference | code-execution | low |
| 69 | brainstorming | research-workflow | Pre-creative-work brainstorming | 3 | L | skip | none | low |
| 70 | deep-research-swarm | research-workflow | COPYRIGHT NOTICE | 3 | L | skip | none | low |
| 71 | research-lookup | research-workflow | Parallel Chat API web search | 3 | L | skip | none | low |
| 72 | reproducibility-checklist | research-workflow | Open science best practices checklist | 3 | L | skip | none | low |

### Writing Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 73 | scientific-writing | writing | Paper writing, LaTeX, abstracts, review responses | 1 | M | judgment-rule | none | low |
| 74 | paper-writing | writing | IMRaD structure with proper citations | 1 | H | judgment-rule | none | high |
| 75 | latex-writing | writing | LaTeX formatting for journals (Nature/Science/IEEE/ACM) | 1 | H | executable-reference | none | low |
| 76 | grant-writing | writing | NIH/NSF/ERC grant proposals with specific aims | 1 | H | judgment-rule | none | high |
| 77 | review-writing | writing | Academic review methodology | 1 | M | judgment-rule | none | low |
| 78 | science-communication | writing | Making research accessible | 1 | M | judgment-rule | none | low |
| 79 | article-writing | writing | Long-form content in distinctive voice | 2 | M | judgment-rule | none | low |
| 80 | venue-templates | writing | LaTeX templates for 25+ venues with scripts | 2 | H | executable-reference | none | low |
| 81 | latex-posters | writing | Research posters with beamerposter/tikzposter | 2 | M | executable-reference | none | low |
| 82 | protocol-writing | writing | Reproducible lab protocols and SOPs | 2 | M | judgment-rule | none | low |
| 83 | markdown-mermaid-writing | writing | Markdown + Mermaid diagrams with references | 2 | M | executable-reference | none | low |
| 84 | patent-drafting | writing | IP protection for research | 2 | M | judgment-rule | none | low |
| 85 | regulatory-submission | writing | FDA/EMA dossier structure | 3 | M | judgment-rule | none | low |
| 86 | regulatory-drafting | writing | Regulatory document drafting | 3 | M | judgment-rule | none | low |
| 87 | pptx-generation | writing | Academic presentations | 3 | L | skip | none | low |
| 88 | writing | writing | Academic writing (umbrella) | 3 | L | skip | none | low |

### Analysis Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 89 | data-analysis | analysis | Data cleaning, EDA, statistical testing with pandas/scipy | 1 | H | judgment-rule | code-execution | high |
| 90 | exploratory-data-analysis | analysis | EDA on 200+ file formats | 1 | H | judgment-rule | code-execution | low |
| 91 | data-extractor | analysis | Extract data from figure images (26+ plot types) | 1 | H | executable-reference | none | low |
| 92 | information-extraction | analysis | Entity/relation extraction from scientific docs | 1 | M | judgment-rule | none | low |
| 93 | data-stats-analysis | analysis | Statistical tests with scipy/statsmodels | 2 | M | executable-reference | code-execution | low |
| 94 | data-transform | analysis | Data cleaning/reshaping with pandas/numpy | 2 | M | executable-reference | code-execution | low |
| 95 | knowledge-discovery | analysis | Pattern discovery, knowledge graphs | 2 | M | judgment-rule | none | low |
| 96 | knowledge-synthesis | analysis | COPYRIGHT NOTICE | 3 | L | skip | none | low |

### Statistics Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 97 | meta-analysis | statistics | DerSimonian-Laird random-effects, forest/funnel plots, I² | 1 | H | judgment-rule | code-execution | high |
| 98 | statistical-testing | statistics | Hypothesis testing, Bayesian, survival, time series | 1 | H | judgment-rule | code-execution | low |
| 99 | biostatistics | statistics | Survival analysis, KM, Cox regression, longitudinal | 1 | H | judgment-rule | code-execution | low |
| 100 | statistical-analysis | statistics | Guided test selection with APA reporting | 1 | H | judgment-rule | code-execution | low |
| 101 | statsmodels | statistics | OLS, GLM, ARIMA with diagnostics | 2 | H | executable-reference | code-execution | low |
| 102 | statsmodels-stats | statistics | Regression, hypothesis testing, time series | 2 | M | executable-reference | code-execution | low |
| 103 | scipy-analysis | statistics | SciPy + NumPy for computing and stats | 2 | M | executable-reference | code-execution | low |
| 104 | statistics | statistics | Statistical analysis and QC (umbrella) | 3 | L | skip | none | low |

### Visualization Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 105 | scientific-visualization | visualization | Publication-ready figures, multi-panel, significance annotations | 1 | H | judgment-rule | code-execution | low |
| 106 | matplotlib | visualization | Full customization plotting | 1 | H | executable-reference | code-execution | low |
| 107 | visualization | visualization | Publication-quality plots with matplotlib/seaborn/plotly | 1 | M | judgment-rule | code-execution | low |
| 108 | seaborn | visualization | Statistical visualization with pandas integration | 2 | M | executable-reference | code-execution | low |
| 109 | plotly | visualization | Interactive charts for dashboards | 2 | M | executable-reference | code-execution | low |
| 110 | data-viz-plots | visualization | Matplotlib/seaborn plots | 2 | M | executable-reference | code-execution | low |
| 111 | matplotlib-viz | visualization | Matplotlib wrapper | 2 | L | skip | code-execution | low |
| 112 | scientific-schematics | visualization | AI-generated scientific diagrams via Nano Banana | 2 | M | executable-reference | none | low |
| 113 | scientific-slides | visualization | Presentation slides for research talks | 2 | M | executable-reference | none | low |
| 114 | scientific-diagram-generation | visualization | Scientific diagram generation | 3 | L | skip | none | low |
| 115 | data-visualization-biomedical | visualization | COPYRIGHT NOTICE | 3 | L | skip | none | low |
| 116 | data-visualization-expert | visualization | COPYRIGHT NOTICE | 3 | L | skip | none | low |
| 117 | infographics | visualization | Professional infographics via AI | 3 | L | skip | none | low |

### Domain — Natural Sciences

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 118 | bioinformatics | domain-natural | Pathway enrichment, GO, PPI, multi-omics | 1 | H | judgment-rule | code-execution | high |
| 119 | chemistry | domain-natural | Chemistry and drug discovery | 1 | M | judgment-rule | none | low |
| 120 | food-science | domain-natural | Nutrition, food chemistry, HACCP, sensory evaluation | 1 | H | judgment-rule | none | high |
| 121 | epidemiology | domain-natural | SIR/SEIR modeling, outbreak investigation | 1 | H | judgment-rule | code-execution | low |
| 122 | genome-analysis | domain-natural | Gene expression, BLAST, GWAS, variant calling | 1 | H | judgment-rule | code-execution | low |
| 123 | clinical-trial | domain-natural | RCT design, sample size, CONSORT reporting | 1 | H | judgment-rule | none | low |
| 124 | environmental-science | domain-natural | Temperature trends, pollution, ecological modeling | 2 | M | judgment-rule | code-execution | low |
| 125 | neuroscience | domain-natural | fMRI, EEG, neural circuits, cognitive experiments | 2 | M | judgment-rule | code-execution | low |
| 126 | materials-science | domain-natural | Crystal structures, phase diagrams, properties | 2 | M | judgment-rule | code-execution | low |
| 127 | drug-discovery | domain-natural | Target ID, virtual screening, ADMET | 2 | M | judgment-rule | code-execution | low |
| 128 | drug-discovery-pipeline | domain-natural | End-to-end drug discovery workflow | 2 | M | judgment-rule | code-execution | low |
| 129 | protein-structure | domain-natural | 3D structures, homology modeling, docking | 2 | M | judgment-rule | code-execution | low |
| 130 | physics-solver | domain-natural | Classical mechanics, E&M, QM, optics | 2 | M | judgment-rule | code-execution | low |
| 131 | chemistry-tools | domain-natural | Computational chemistry, molecular structures | 2 | M | executable-reference | code-execution | low |
| 132 | energy-systems | domain-natural | Renewable energy, grid modeling, storage | 2 | M | judgment-rule | none | low |
| 133 | signal-processing | domain-natural | Spectral analysis, FFT, filtering | 2 | M | judgment-rule | code-execution | low |
| 134 | genomics-analysis | domain-natural | Gene→expression→pathway enrichment workflow | 2 | M | judgment-rule | code-execution | low |
| 135 | molecular-dynamics | domain-natural | OpenMM + MDAnalysis simulations | 2 | H | executable-reference | code-execution | low |
| 136 | materials-screening | domain-natural | Database→filter→stability→ranking workflow | 2 | M | judgment-rule | code-execution | low |
| 137 | phylogenetics | domain-natural | MAFFT, IQ-TREE 2, FastTree | 2 | H | executable-reference | code-execution | low |
| 138 | astronomy-cosmology | domain-natural | Telescope data, celestial mechanics | 3 | M | judgment-rule | code-execution | low |
| 139 | astropy-astronomy | domain-natural | Astropy for coordinates, FITS, cosmology | 3 | M | executable-reference | code-execution | low |
| 140 | biopython-bio | domain-natural | Biopython sequences, BLAST, PDB | 3 | M | executable-reference | code-execution | low |
| 141 | biopython | domain-natural | Biopython toolkit | 3 | M | executable-reference | code-execution | low |
| 142 | clinical | domain-natural | Clinical research (umbrella) | 3 | L | skip | none | low |
| 143 | computational-pathology-agent | domain-natural | COPYRIGHT NOTICE | 3 | L | skip | none | low |
| 144 | fluidsim | domain-natural | CFD with Navier-Stokes, shallow water | 3 | H | executable-reference | code-execution | low |
| 145 | quantum-computing | domain-natural | Quantum circuits, error correction | 3 | M | judgment-rule | code-execution | low |
| 146 | protein-structure-prediction | domain-natural | AlphaFold predictions | 3 | M | judgment-rule | none | low |
| 147 | medical-qa | domain-natural | Medical QA with biomedical knowledge bases | 3 | M | judgment-rule | none | low |

### Domain — Social Sciences

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 148 | economics-analysis | domain-social | Econometrics, causal inference, game theory | 1 | H | judgment-rule | code-execution | low |
| 149 | social-science-analysis | domain-social | Survey design, qualitative analysis, mixed methods | 1 | H | judgment-rule | code-execution | low |
| 150 | social-science-research | domain-social | Multi-phase social science research workflow | 2 | M | judgment-rule | code-execution | low |
| 151 | psychology-research | domain-social | Mental health, cognitive science, behavioral studies | 2 | M | judgment-rule | code-execution | low |
| 152 | education-research | domain-social | Pedagogical methods, learning analytics | 2 | M | judgment-rule | code-execution | low |
| 153 | political-science | domain-social | Political data, policy impact analysis | 2 | M | judgment-rule | code-execution | low |
| 154 | legal-analysis | domain-social | Contract analysis, legal research frameworks | 3 | M | judgment-rule | none | low |
| 155 | linguistics-analysis | domain-social | Language structures, typological features | 3 | M | judgment-rule | none | low |

### ML/AI Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 156 | scikit-learn | ml-ai | Classification, regression, clustering, evaluation | 1 | H | executable-reference | code-execution | low |
| 157 | ml-pipeline | ml-ai | Full ML pipeline: preprocess→train→evaluate→interpret | 1 | M | judgment-rule | code-execution | low |
| 158 | nlp-analysis | ml-ai | Text mining, sentiment, topic modeling, NER | 2 | M | judgment-rule | code-execution | low |
| 159 | spacy-nlp | ml-ai | spaCy NER, POS, dependency parsing | 2 | M | executable-reference | code-execution | low |
| 160 | networkx | ml-ai | Graph/network analysis | 2 | M | executable-reference | code-execution | low |
| 161 | scanpy | ml-ai | scRNA-seq pipeline | 2 | H | executable-reference | code-execution | low |
| 162 | scanpy-singlecell | ml-ai | Single-cell analysis with scanpy/anndata | 2 | H | executable-reference | code-execution | low |
| 163 | scikit-learn-ml | ml-ai | scikit-learn wrapper | 2 | M | executable-reference | code-execution | low |
| 164 | transformers-inference | ml-ai | HuggingFace for inference tasks | 3 | M | executable-reference | code-execution | low |
| 165 | nltk-linguistics | ml-ai | NLTK for tokenization, POS, corpus | 3 | M | executable-reference | code-execution | low |
| 166 | networkx-social | ml-ai | Social network analysis with NetworkX | 3 | M | executable-reference | code-execution | low |
| 167 | polars | ml-ai | Fast DataFrame library | 3 | M | executable-reference | code-execution | low |
| 168 | scikit-bio | ml-ai | Biological data: diversity, ordination, PERMANOVA | 3 | H | executable-reference | code-execution | low |
| 169 | scikit-survival | ml-ai | Survival analysis with scikit-survival | 3 | H | executable-reference | code-execution | low |
| 170 | geopandas | ml-ai | Geospatial vector data | 3 | M | executable-reference | code-execution | low |

### Computation Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 171 | code-execution | computation | Scientific Python execution with verification | 1 | M | judgment-rule | code-execution | low |
| 172 | math-computation | computation | Symbolic + numerical: SymPy, NumPy, SciPy | 1 | M | judgment-rule | code-execution | low |
| 173 | sympy | computation | Symbolic math: equations, calculus, proofs | 1 | H | executable-reference | code-execution | low |
| 174 | parameter-optimization | computation | DOE, sensitivity analysis, optimizer selection | 2 | H | executable-reference | code-execution | low |
| 175 | convergence-study | computation | Richardson extrapolation, GCI for solution verification | 2 | H | executable-reference | code-execution | low |
| 176 | linear-solvers | computation | Direct/iterative methods for Ax=b | 2 | H | executable-reference | code-execution | low |
| 177 | nonlinear-solvers | computation | Newton, BFGS, Anderson for f(x)=0 | 2 | H | executable-reference | code-execution | low |
| 178 | numerical-integration | computation | Time integration for ODE/PDE | 2 | H | executable-reference | code-execution | low |
| 179 | numerical-stability | computation | CFL, Fourier criteria for PDE stability | 2 | H | executable-reference | code-execution | low |
| 180 | simulation-orchestrator | computation | Multi-simulation campaigns, parameter sweeps | 2 | M | executable-reference | code-execution | low |
| 181 | simulation-validator | computation | Pre/post-run validation, NaN detection | 2 | M | executable-reference | code-execution | low |
| 182 | sympy-math | computation | SymPy wrapper | 3 | M | executable-reference | code-execution | low |
| 183 | mesh-generation | computation | Grid resolution, aspect ratios, adaptive mesh | 3 | H | executable-reference | code-execution | low |
| 184 | performance-profiling | computation | Bottleneck analysis, scaling, memory estimation | 3 | M | executable-reference | code-execution | low |
| 185 | post-processing | computation | Simulation output extraction and visualization | 3 | M | executable-reference | code-execution | low |
| 186 | time-stepping | computation | Time-step policies, CFL coupling | 3 | H | executable-reference | code-execution | low |
| 187 | code-science | computation | Reproducible research, HPC, research software eng | 3 | L | judgment-rule | none | low |
| 188 | lean4-prover | computation | Lean 4 formal theorem proving | 3 | M | executable-reference | code-execution | low |
| 189 | rdkit | computation | Cheminformatics: SMILES, fingerprints, similarity | 3 | H | executable-reference | code-execution | low |
| 190 | rdkit-chemistry | computation | RDKit wrapper | 3 | M | executable-reference | code-execution | low |
| 191 | pymatgen-materials | computation | Crystal structures, phase diagrams with pymatgen | 3 | H | executable-reference | code-execution | low |

### ScienceClaw Core Cluster

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 192 | scienceclaw-qa | scienceclaw-core | Evidence-based scientific QA across disciplines | 1 | M | judgment-rule | none | low |
| 193 | scienceclaw-verification | scienceclaw-core | Verify claims, check calculations, fact-check citations | 1 | M | judgment-rule | none | low |
| 194 | scienceclaw-ie | scienceclaw-core | Extract entities, relations, data from scientific text | 1 | M | judgment-rule | none | low |
| 195 | scienceclaw-reasoning | scienceclaw-core | Multi-step scientific reasoning, causal inference | 2 | M | judgment-rule | none | low |
| 196 | scienceclaw-retrieval | scienceclaw-core | Retrieve from databases, literature, knowledge bases | 2 | M | judgment-rule | none | low |
| 197 | scienceclaw-summarization | scienceclaw-core | Summarize papers, datasets, experimental results | 2 | M | judgment-rule | none | low |
| 198 | scienceclaw-discovery | scienceclaw-core | Research gaps, cross-disciplinary synthesis | 2 | M | judgment-rule | none | low |
| 199 | scienceclaw-classification | scienceclaw-core | Classify by discipline, methodology, quality | 3 | L | skip | none | low |
| 200 | scienceclaw-generation | scienceclaw-core | Generate hypotheses, experiment designs, drafts | 3 | L | skip | none | low |
| 201 | scienceclaw-prediction | scienceclaw-core | Predict properties, trends, outcomes | 3 | L | skip | none | low |
| 202 | skill-creator | scienceclaw-core | Create/edit/audit AgentSkills | 3 | M | skip | none | high |
| 203 | skill-evolution | scienceclaw-core | VOYAGER-style pattern library | 3 | H | skip | science-evolution | high |
| 204 | find-skills | scienceclaw-core | Discover skills via npx skills | 3 | L | skip | none | high |
| 205 | clawhub | scienceclaw-core | ClawHub CLI for skill management | 3 | L | skip | none | low |

### Utility Cluster (Non-Science — Priority 3 unless noted)

| # | Skill Name | Cluster | Description | Priority | Anti-Slop | TAD Mapping | Runtime Deps | Confidence |
|---|-----------|---------|-------------|----------|-----------|-------------|-------------|------------|
| 206 | pdf | utility | PDF reading, editing, manipulation | 1 | M | executable-reference | none | low |
| 207 | docx | utility | Word document manipulation | 1 | M | executable-reference | none | low |
| 208 | xlsx | utility | Spreadsheet manipulation | 2 | M | executable-reference | none | low |
| 209 | pptx | utility | Presentation manipulation | 2 | M | executable-reference | none | low |
| 210 | github | utility | GitHub operations via gh CLI | 2 | M | skip | none | low |
| 211 | summarize | utility | Summarize URLs, podcasts, local files | 2 | L | skip | none | low |
| 212 | 1password | utility | 1Password CLI | 3 | L | skip | none | low |
| 213 | apple-notes | utility | Apple Notes via memo CLI | 3 | L | skip | none | low |
| 214 | apple-reminders | utility | Apple Reminders via remindctl | 3 | L | skip | none | low |
| 215 | bear-notes | utility | Bear notes via grizzly CLI | 3 | L | skip | none | low |
| 216 | blogwatcher | utility | RSS/Atom feed monitor | 3 | L | skip | none | low |
| 217 | blucli | utility | BluOS speaker control | 3 | L | skip | none | low |
| 218 | bluebubbles | utility | iMessage via BlueBubbles | 3 | L | skip | none | low |
| 219 | camsnap | utility | RTSP/ONVIF camera capture | 3 | L | skip | none | low |
| 220 | canvas | utility | Canvas (empty skill) | 3 | L | skip | none | low |
| 221 | coding-agent | utility | Delegate to Codex/Claude/Pi agents | 3 | L | skip | none | low |
| 222 | discord | utility | Discord operations | 3 | L | skip | none | low |
| 223 | docx-official | utility | Official docx with scripts | 3 | M | skip | none | low |
| 224 | eightctl | utility | Eight Sleep pod control | 3 | L | skip | none | low |
| 225 | gemini | utility | Gemini CLI for Q&A | 3 | L | skip | none | low |
| 226 | generate-image | utility | AI image generation (FLUX/Nano Banana) | 3 | L | skip | none | low |
| 227 | gh-issues | utility | GitHub issues auto-fix | 3 | L | skip | none | low |
| 228 | gifgrep | utility | GIF search/download | 3 | L | skip | none | low |
| 229 | gog | utility | Google Workspace CLI | 3 | L | skip | none | low |
| 230 | goplaces | utility | Google Places API | 3 | L | skip | none | low |
| 231 | geopandas-spatial | utility | Geospatial + climate with geopandas/xarray | 3 | M | executable-reference | code-execution | low |
| 232 | geospatial-analysis | utility | GIS, spatial statistics, remote sensing | 3 | M | judgment-rule | code-execution | low |
| 233 | healthcheck | utility | Host security hardening | 3 | L | skip | none | low |
| 234 | himalaya | utility | Email via IMAP/SMTP | 3 | L | skip | none | low |
| 235 | imsg | utility | iMessage CLI | 3 | L | skip | none | low |
| 236 | mcporter | utility | MCP server management | 3 | L | skip | none | low |
| 237 | model-usage | utility | Model usage stats | 3 | L | skip | none | low |
| 238 | nano-banana-pro | utility | Gemini image generation | 3 | L | skip | none | low |
| 239 | nano-pdf | utility | PDF editing via CLI | 3 | L | skip | none | low |
| 240 | notion | utility | Notion API | 3 | L | skip | none | low |
| 241 | obsidian | utility | Obsidian vault management | 3 | L | skip | none | low |
| 242 | open-notebook | utility | Open-source NotebookLM alternative | 3 | M | skip | none | low |
| 243 | openai-image-gen | utility | OpenAI image batch generation | 3 | L | skip | none | low |
| 244 | openai-whisper | utility | Local speech-to-text | 3 | L | skip | none | low |
| 245 | openai-whisper-api | utility | OpenAI Whisper API | 3 | L | skip | none | low |
| 246 | openhue | utility | Philips Hue control | 3 | L | skip | none | low |
| 247 | oracle | utility | Oracle CLI | 3 | L | skip | none | low |
| 248 | ordercli | utility | Foodora order CLI | 3 | L | skip | none | low |
| 249 | parallel-web | utility | Parallel Chat API web search | 3 | L | skip | none | low |
| 250 | patent-analysis | utility | Patent landscape analysis | 3 | M | judgment-rule | none | low |
| 251 | pdf-anthropic | utility | PDF with Anthropic vision | 3 | M | skip | none | low |
| 252 | pdf-processing | utility | Basic PDF extraction | 3 | L | skip | none | low |
| 253 | pdf-processing-pro | utility | Production PDF processing | 3 | M | skip | none | low |
| 254 | peekaboo | utility | macOS UI automation | 3 | L | skip | none | low |
| 255 | perplexity-search | utility | Perplexity AI search | 3 | L | skip | none | low |
| 256 | pptx-official | utility | Official pptx with scripts | 3 | M | skip | none | low |
| 257 | profile-report | utility | Profile reporting | 3 | L | skip | none | low |
| 258 | sag | utility | ElevenLabs TTS | 3 | L | skip | none | low |
| 259 | scientific-classification | utility | Classification across astronomy/bio/social | 3 | M | judgment-rule | none | low |
| 260 | scientific-generation | utility | Scientific code/protocol generation | 3 | L | skip | none | low |
| 261 | scientific-manuscript | utility | COPYRIGHT NOTICE | 3 | L | skip | none | low |
| 262 | scientific-prediction | utility | Property/indicator prediction | 3 | M | judgment-rule | code-execution | low |
| 263 | scientific-retrieval | utility | Retrieve from archives | 3 | L | skip | none | low |
| 264 | scientific-summarization | utility | Summarize scientific text | 3 | L | skip | none | low |
| 265 | session-logs | utility | Session log search with jq | 3 | L | skip | none | low |
| 266 | sherpa-onnx-tts | utility | Local TTS | 3 | L | skip | none | low |
| 267 | slack | utility | Slack control | 3 | L | skip | none | low |
| 268 | songsee | utility | Audio spectrogram generation | 3 | L | skip | none | low |
| 269 | sonoscli | utility | Sonos speaker control | 3 | L | skip | none | low |
| 270 | spotify-player | utility | Spotify playback | 3 | L | skip | none | low |
| 271 | systematic-debugging | utility | Debugging methodology | 3 | M | skip | none | low |
| 272 | test-driven-development | utility | TDD methodology | 3 | M | skip | none | low |
| 273 | things-mac | utility | Things 3 task management | 3 | L | skip | none | low |
| 274 | tmux | utility | tmux session control | 3 | L | skip | none | low |
| 275 | trello | utility | Trello board management | 3 | L | skip | none | low |
| 276 | video-frames | utility | Video frame extraction | 3 | L | skip | none | low |
| 277 | voice-call | utility | Voice call plugin | 3 | L | skip | none | low |
| 278 | wacli | utility | WhatsApp CLI | 3 | L | skip | none | low |
| 279 | weather | utility | Weather via wttr.in | 3 | L | skip | none | low |
| 280 | xlsx-official | utility | Official xlsx | 3 | M | skip | none | low |
| 281 | xurl | utility | X/Twitter API CLI | 3 | L | skip | none | low |
| 282 | multi-search-engine | utility | 17 search engines (8 CN + 9 global) | 3 | M | skip | none | low |
| 283 | materials-project | database | Materials Project API v3 for crystal structures, band gaps | 2 | H | executable-reference | code-execution | low |
| 284 | research-literature | writing | COPYRIGHT NOTICE — research literature skill | 3 | L | skip | none | low |
| 285 | scientific-reasoning | scienceclaw-core | Mathematical/physical reasoning with formal proofs | 2 | M | judgment-rule | none | low |

---

## Anti-Slop Analysis

### Priority 1 Skills by Anti-Slop Score

| Score | Count | % of P1 | Examples |
|-------|-------|---------|---------|
| H | 35 | 58% | literature-search (PRISMA checklist), meta-analysis (DerSimonian-Laird formula), bioinformatics (FDR < 0.05 threshold) |
| M | 25 | 42% | paper-analysis, hypothesis-generation, food-science (HACCP 7 principles), peer-review |
| L | 0 | 0% | — (all P1 skills have domain-specific content) |

**58% of P1 skills rated H** — exceeds the ≥50% target from AC10.

---

## Deduplication Notes for Phase 3

The following near-duplicate pairs should be resolved in Phase 3 (choose one or merge):

| Pair | Recommendation |
|------|---------------|
| experiment-design / experimental-design | Merge: both cover sample size + controls; one has more detail |
| hypothesis-gen / hypothesis-generation | Merge: nearly identical scope |
| statsmodels / statsmodels-stats | Keep statsmodels (richer); skip statsmodels-stats |
| scanpy / scanpy-singlecell | Merge: scanpy is more general; singlecell adds minor details |
| networkx / networkx-social | Keep networkx (general); merge social-specific content |
| literature-search / academic-literature-search / literature | Keep literature-search (richest); skip umbrella versions |
| openalex-database / openalex-search | Merge: same API, different focus |
| chembl-database / chembl-drug | Merge: same API, different depth |
| pubmed-database / pubmed-search | Merge: same E-utilities API |
| uniprot-database / uniprot-protein | Merge: same REST API |
| scikit-learn / scikit-learn-ml | Keep scikit-learn (richer) |
| sympy / sympy-math | Keep sympy (richer) |
