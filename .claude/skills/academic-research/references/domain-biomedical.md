# Biomedical Domain Judgment Rules

Extracted from ScienceClaw biomedical and life science skills.
Rules with specific thresholds, parameters, and protocol standards only.

---

## 1. Differential Expression Analysis

**R-BIO-001: Default DE Thresholds**
- Adjusted p-value: padj < 0.05 (BH-FDR correction)
- Fold-change: |log2FC| > 1 (2-fold change)
- These are defaults; adjustable per study context
- MUST apply multiple testing correction (BH-FDR or equivalent)

> Source: skills/bioinformatics/SKILL.md

**R-BIO-002: Tool Selection by Data Type**
- Count data (RNA-seq): DESeq2 or edgeR
- Normalized data: limma-voom
- Proteomics: limma with appropriate normalization
- Ranked gene lists (no arbitrary cutoff): GSEA

> Source: skills/bioinformatics/SKILL.md

**R-BIO-003: Enrichment Reporting Requirements**
- Each enriched term must include: gene ratio, p-value, adjusted p-value, gene members
- Handle redundant GO terms via semantic similarity (REVIGO)
- Background gene set must be appropriate for the analysis
- Cross-validate results across databases or methods

> Source: skills/bioinformatics/SKILL.md

---

## 2. Network Analysis

**R-BIO-010: PPI Network Confidence**
- STRING confidence score > 0.7 for high-confidence interactions
- Hub genes: identified by degree centrality
- Bottleneck nodes: identified by betweenness centrality
- Module detection: MCODE or Louvain clustering
- Always overlay expression data on network

> Source: skills/bioinformatics/SKILL.md

---

## 3. Single-Cell RNA-seq Pipeline

**R-BIO-020: scRNA-seq QC Filters**
- Filter on: genes/cell, UMI/cell, mitochondrial %
- Document all thresholds applied
- Normalization: scran or SCTransform
- Dimensionality reduction: PCA then UMAP
- Clustering: Leiden or Louvain algorithm
- Cell type annotation: SingleR, scType, or marker genes
- Trajectory inference: Monocle3 or Slingshot
- Batch effects: assess and correct if present

> Source: skills/bioinformatics/SKILL.md

---

## 4. Genomics Analysis

**R-BIO-030: Reference Genome Standards**
- Always state genome build explicitly (e.g., GRCh38 for human, GRCm39 for mouse)
- All gene identifiers must use standard nomenclature (HGNC symbols for human)
- Report coordinates in standard notation: chr:start-end, 1-based

> Source: skills/genome-analysis/SKILL.md

**R-BIO-031: Aligner Selection**
- Short-read DNA: BWA-MEM2
- RNA-seq: STAR
- Long reads: minimap2
- De novo assembly: SPAdes (short), Flye or hifiasm (long)

> Source: skills/genome-analysis/SKILL.md

**R-BIO-032: Variant Calling**
- Variant callers: GATK HaplotypeCaller or DeepVariant
- Transcript quantification: featureCounts or Salmon
- GWAS: use mixed models (BOLT-LMM, SAIGE) for population structure
- Multiple testing: Bonferroni for GWAS, BH-FDR for DE
- Annotation: VEP or ANNOVAR
- Clinical interpretation: ClinVar + gnomAD

> Source: skills/genome-analysis/SKILL.md

**R-BIO-033: QC Metrics to Report**
- Mapping rate, duplication rate, coverage depth
- Effect sizes alongside p-values (always)
- Exact tool versions and parameters for reproducibility

> Source: skills/genome-analysis/SKILL.md

---

## 5. Clinical Trial Design

**R-BIO-040: Trial Phase Definitions**
- Phase I: safety and dose-finding
- Phase II: efficacy signal
- Phase III: confirmatory (pivotal)
- Phase IV: post-market surveillance

> Source: skills/clinical-trial/SKILL.md

**R-BIO-041: Sample Size Calculation Parameters**
- Alpha: 0.05 (two-sided, typical)
- Power: 80-90%
- Must specify: expected effect size, dropout rate
- Formula depends on endpoint type (continuous, binary, time-to-event)
- Report as table: assumptions, formula, per-arm N, total N

> Source: skills/clinical-trial/SKILL.md

**R-BIO-042: Reporting Guidelines**
- RCT: CONSORT checklist + flow diagram
- Observational: STROBE
- Protocol: SPIRIT
- Flow diagram must include all participant numbers at each stage

> Source: skills/clinical-trial/SKILL.md

**R-BIO-043: Design Requirements**
- PICO defined (Population, Intervention, Comparator, Outcome)
- Primary endpoint: clinically meaningful, with MCID specified
- Randomization method: simple, block, stratified, or minimization
- Blinding level: open-label, single, double, or triple
- Interim analysis: pre-specify boundaries using alpha-spending function (O'Brien-Fleming or Lan-DeMets)
- Analysis populations: ITT and per-protocol both defined
- Regulatory alignment noted (FDA / EMA / ICH)

> Source: skills/clinical-trial/SKILL.md

---

## 6. Epidemiological Modeling

**R-BIO-050: SIR/SEIR Model Requirements**
- Must specify: transmission rate (beta), recovery rate (gamma), latent period (for SEIR)
- Estimate R0 from early epidemic growth rate or next-generation matrix
- Sensitivity analysis on key parameters is mandatory
- Compartmental model diagrams must show parameter definitions and values

> Source: skills/epidemiology/SKILL.md

**R-BIO-051: Epidemiological Measures**
- Incidence rate: person-time denominator required
- Prevalence: specify point or period
- All estimates must include 95% confidence intervals
- Report BOTH absolute and relative measures
- Case definition must be explicitly stated (confirmed, probable, suspected)

> Source: skills/epidemiology/SKILL.md

**R-BIO-052: Causal Inference in Epi**
- Draw DAG to identify confounders and colliders BEFORE analysis
- Regression selection: logistic for OR, Poisson/negative binomial for rates, Cox for time-to-event
- Epidemic curves: use onset date, not report date when possible
- Geographic maps: use rates (not raw counts) with appropriate denominators
- Discuss Hill's criteria for causation assessment

> Source: skills/epidemiology/SKILL.md

---

## 7. Food Science (HACCP)

**R-BIO-060: HACCP 7 Principles**
1. Hazard analysis (biological, chemical, physical)
2. Identify critical control points (CCPs)
3. Establish critical limits for each CCP
4. Establish monitoring procedures
5. Establish corrective actions
6. Verification procedures
7. Record-keeping and documentation

> Source: skills/food-science/SKILL.md

**R-BIO-061: Hazard Categories**
- Biological: Salmonella, Listeria, E. coli O157:H7
- Chemical: pesticides, mycotoxins, heavy metals, allergens
- Physical: foreign objects
- All three categories must be covered in HACCP analysis

> Source: skills/food-science/SKILL.md

**R-BIO-062: Thermal Processing Parameters**
- D-value: time to reduce population by 90% at given temperature
- z-value: temperature change to achieve 10x change in D-value
- F0: equivalent minutes at 121.1 C (sterilization reference)
- Target: most resistant pathogen of concern
- Model degradation kinetics: zero or first order

> Source: skills/food-science/SKILL.md

**R-BIO-063: Sensory Evaluation Design**
- Discrimination tests: triangle, duo-trio
- Descriptive: QDA (Quantitative Descriptive Analysis), CATA (Check-All-That-Apply)
- Affective: hedonic scale, preference ranking
- Specify: panel type (trained vs. consumer), replicates, serving conditions

> Source: skills/food-science/SKILL.md

**R-BIO-064: Shelf Life Estimation**
- Monitor quality indicators over time (microbial counts, chemical markers, sensory scores)
- Accelerated testing: Arrhenius equation for temperature-dependent reactions
- Report with confidence intervals
- Specify conditions: temperature, humidity, packaging

> Source: skills/food-science/SKILL.md

---

## 8. Drug Discovery Pipeline

**R-BIO-070: Lipinski Rule of Five (Drug-Likeness)**
- Molecular weight <= 500 Da
- LogP <= 5
- H-bond donors <= 5
- H-bond acceptors <= 10
- Additional: Veber rules (rotatable bonds, TPSA)
- PAINS filter to remove frequent hitters

> Source: skills/drug-discovery/SKILL.md, skills/chemistry/SKILL.md

**R-BIO-071: Activity Thresholds**
- Early screening cutoff: IC50 < 1 uM
- Report IC50/EC50/Ki with assay conditions and confidence intervals
- QSAR validation: cross-validation + external test set + applicability domain
- Docking results: binding energy in kcal/mol with key interactions listed

> Source: skills/drug-discovery/SKILL.md, skills/drug-discovery-pipeline/SKILL.md

**R-BIO-072: ADMET Prediction Checklist**
- Absorption: Caco-2 permeability, LogP
- Distribution: plasma protein binding, volume of distribution
- Metabolism: CYP inhibition/induction
- Excretion: clearance
- Toxicity: hERG liability, hepatotoxicity, AMES mutagenicity
- Tools: SwissADME, pkCSM, ADMETlab
- Must include confidence levels or applicability domain

> Source: skills/drug-discovery/SKILL.md

**R-BIO-073: PK Parameters to Report**
- Cmax, Tmax, AUC, half-life (t1/2), bioavailability, clearance
- All with units and species specified (human vs. preclinical)
- PD modeling: Emax model, Hill equation for dose-response

> Source: skills/drug-discovery/SKILL.md

**R-BIO-074: Compound Ranking (Multi-Parameter Optimization)**
- Potency: pIC50 or pKi against target
- Selectivity: activity ratio vs. off-targets
- Drug-likeness: QED score
- Synthetic accessibility: SA score
- Novelty: Tanimoto distance from known drugs
- Output: ranked table of top 10-20 candidates with rationale

> Source: skills/drug-discovery-pipeline/SKILL.md

---

## 9. Protein Structure Analysis

**R-BIO-080: Structure Quality Metrics**
- Experimental: check resolution, R-free, completeness
- AlphaFold predictions: evaluate pLDDT per-residue confidence + PAE matrix
- Structural comparison: report RMSD (Angstroms) and TM-score
- Binding site detection: fpocket, SiteMap, or DoGSiteScorer

> Source: skills/protein-structure/SKILL.md

**R-BIO-081: Docking Protocol**
- Tools: AutoDock Vina, GNINA, or Glide
- Define grid box around binding site
- Report: binding energy (kcal/mol), key interactions (H-bonds, hydrophobic, pi-stacking)
- Validate against known co-crystal structures when available
- Distinguish biological assembly vs. asymmetric unit

> Source: skills/protein-structure/SKILL.md

---

## 10. Neuroscience Imaging

**R-BIO-090: fMRI Standards**
- Specify: TR, voxel size, field strength
- Preprocessing: slice timing, motion correction, normalization (MNI/Talairach), smoothing
- Analysis: GLM for activation, ICA for connectivity, MVPA for decoding
- Multiple comparison correction: cluster-level FWE
- Report: MNI coordinates (x,y,z), cluster size, peak t/z-value
- Atlas labels: AAL, Desikan-Killiany, or Schaefer

> Source: skills/neuroscience/SKILL.md

**R-BIO-091: EEG Standards**
- Preprocessing: bandpass filtering, ICA artifact rejection (eye blinks, muscle), re-referencing
- Analysis: ERP (N1, P3, N400 with latency + amplitude), time-frequency decomposition
- Frequency bands: delta, theta, alpha, beta, gamma
- Multiple comparison correction: permutation-based
- Report effect sizes; use Bayesian approaches when frequentist results are ambiguous

> Source: skills/neuroscience/SKILL.md

---

## 11. Bioinformatics Visualization Standards

**R-BIO-095: Required Plot Types by Analysis**
- DE analysis: volcano plot (with thresholds at padj<0.05, |log2FC|>1)
- Expression clustering: heatmap with hierarchical dendrogram + annotation bars
- Enrichment: dot plots (gene ratio vs. term, dot size = count, color = padj)
- Networks: node color = expression, node size = degree, module highlighting
- Single-cell: UMAP/tSNE with cluster labels + cell type annotations
- Multi-omics: circos plots for cross-layer relationships

> Source: skills/bioinformatics/SKILL.md
