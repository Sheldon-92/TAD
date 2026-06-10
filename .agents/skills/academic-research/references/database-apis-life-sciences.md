# Life Science Databases -- Academic Research Reference
> Consolidated from 14 ScienceClaw skills.

## Quick Reference
| Database | Base URL | Auth | Rate Limit | Source Skill |
|----------|---------|------|-----------|-------------|
| UniProt | `rest.uniprot.org` | None | Reasonable use | uniprot-protein |
| ChEMBL | `www.ebi.ac.uk/chembl/api/data` | None | 1 req/s | chembl-drug |
| NCBI Entrez | `eutils.ncbi.nlm.nih.gov/entrez/eutils` | Optional API key | 3 req/s (no key); 10 req/s (key) | ncbi-entrez |
| RCSB PDB | `data.rcsb.org` / `search.rcsb.org` | None | Reasonable use | pdb-structure |
| ClinicalTrials | `clinicaltrials.gov/api/v2` | None | ~50 req/min | clinicaltrials-database |
| KEGG | `rest.kegg.jp` | None | Reasonable use | kegg-pathway |
| NCBI Gene | `eutils...` + `api.ncbi.nlm.nih.gov/datasets/v2` | Optional API key | 3-5 req/s (no key); 10 req/s (key) | gene-database |
| STRING | `string-db.org/api` | None | 1 req/s | string-database |
| Ensembl | `rest.ensembl.org` | None | 15 req/s | ensembl-database |
| ClinVar | `eutils...` (db=clinvar) | Optional API key | 3 req/s (no key); 10 req/s (key) | clinvar-database |
| PubChem | `pubchem.ncbi.nlm.nih.gov/rest/pug` | None | 5 req/s | pubchem-compound |
| Reactome | `reactome.org/ContentService` + `AnalysisService` | None | Reasonable use | reactome-database |
| GEO | `eutils...` (db=gds) + FTP | Optional API key | 3 req/s (no key); 10 req/s (key) | geo-database |
| Open Targets | `api.platform.opentargets.org/api/v4/graphql` | None | 10 req/s | open-targets |

## Detailed API Templates

### UniProt (Proteins)
**Protein sequences, function annotations, cross-references. No auth.**

```bash
# Search human insulin proteins (reviewed/Swiss-Prot)
curl -s "https://rest.uniprot.org/uniprotkb/search?query=insulin+AND+organism_id:9606+AND+reviewed:true&format=json&size=5"

# Exact gene name match
curl -s "https://rest.uniprot.org/uniprotkb/search?query=gene_exact:TP53+AND+organism_id:9606&format=json"

# Single entry by accession
curl -s "https://rest.uniprot.org/uniprotkb/P04637?format=json"

# FASTA sequence
curl -s "https://rest.uniprot.org/uniprotkb/P69905.fasta"

# TSV with selected fields
curl -s "https://rest.uniprot.org/uniprotkb/search?query=accession:P04637&format=tsv&fields=accession,gene_names,protein_name,organism_name,length,go_p"

# Batch retrieve
curl -s "https://rest.uniprot.org/uniprotkb/search?query=accession:P04637+OR+accession:P69905+OR+accession:P00533&format=tsv&fields=accession,gene_names,protein_name,length"
```

**Query fields:** `gene_exact:BRCA1`, `organism_id:9606` (human), `ec:3.4.21.5`, `go:0006915`, `keyword:Phosphoprotein`, `reviewed:true`, `length:[100 TO 500]`, `structure_3d:true`.
**Organism IDs:** human=9606, mouse=10090, rat=10116, E.coli=83333, yeast=559292.
> Source: skills/uniprot-protein/SKILL.md

### ChEMBL (Drugs & Bioactivity)
**Drug-target interactions, IC50/Ki data, ADMET, approved drugs.**

```bash
# Molecule by ChEMBL ID
curl -s "https://www.ebi.ac.uk/chembl/api/data/molecule/CHEMBL25.json"

# Search by name
curl -s "https://www.ebi.ac.uk/chembl/api/data/molecule/search.json?q=imatinib"

# Target by gene name
curl -s "https://www.ebi.ac.uk/chembl/api/data/target/search.json?q=EGFR"

# Target by UniProt accession
curl -s "https://www.ebi.ac.uk/chembl/api/data/target.json?target_components__accession=P00533"

# Bioactivity: IC50 for a molecule against targets
curl -s "https://www.ebi.ac.uk/chembl/api/data/activity.json?molecule_chembl_id=CHEMBL941&standard_type=IC50&limit=10"

# Potent hits (pChEMBL >= 6 means activity <= 1 uM)
curl -s "https://www.ebi.ac.uk/chembl/api/data/activity.json?target_chembl_id=CHEMBL2034&pchembl_value__gte=6&limit=20"

# Mechanism of action
curl -s "https://www.ebi.ac.uk/chembl/api/data/mechanism.json?molecule_chembl_id=CHEMBL941"

# Approved drugs only (max_phase=4)
curl -s "https://www.ebi.ac.uk/chembl/api/data/molecule.json?max_phase=4&limit=20"

# Drug indications
curl -s "https://www.ebi.ac.uk/chembl/api/data/drug_indication.json?molecule_chembl_id=CHEMBL941&limit=10"
```

**Clinical phases:** 4=approved, 3=Phase III, 2=Phase II, 1=Phase I.
**Potency filter:** `pchembl_value__gte=5` (10 uM), `pchembl_value__gte=6` (1 uM).
**Image URL:** `https://www.ebi.ac.uk/chembl/api/data/image/CHEMBL25.svg`
> Source: skills/chembl-drug/SKILL.md

### NCBI Entrez (Genes, SNPs, Sequences)
**Gene, SNP, ClinVar, Nucleotide, Protein, OMIM via E-utilities.**

```bash
# Search gene
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=gene&term=TP53[Gene]+AND+Homo+sapiens[Organism]&retmode=json"

# Fetch gene summary
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=gene&id=7157&retmode=json"

# Fetch nucleotide FASTA
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=NM_000546.6&rettype=fasta&retmode=text"

# Fetch SNP record
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=snp&id=rs1042522&retmode=json"

# Cross-database linking: gene -> SNPs
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=gene&db=snp&id=7157&retmode=json"

# Gene -> ClinVar
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=gene&db=clinvar&id=672&retmode=json"

# Gene -> PubMed
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=gene&db=pubmed&id=7157&retmode=json"
```

**Operations:** `esearch` (search->IDs), `efetch` (IDs->records), `esummary` (IDs->summaries), `elink` (cross-db links), `einfo` (db metadata).
**Auth:** `&api_key=$NCBI_API_KEY` for 10 req/s.
> Source: skills/ncbi-entrez/SKILL.md

### RCSB PDB (3D Structures)
**Protein structures: X-ray, cryo-EM, NMR. Three APIs.**

```bash
# Metadata by PDB ID
curl -s "https://data.rcsb.org/rest/v1/core/entry/6VYB"

# Text search (POST)
curl -s -X POST "https://search.rcsb.org/rcsbsearch/v2/query" \
  -H "Content-Type: application/json" \
  -d '{"query":{"type":"terminal","service":"full_text","parameters":{"value":"insulin receptor"}},"return_type":"entry","request_options":{"paginate":{"start":0,"rows":10}}}'

# Sequence similarity search (POST)
curl -s -X POST "https://search.rcsb.org/rcsbsearch/v2/query" \
  -H "Content-Type: application/json" \
  -d '{"query":{"type":"terminal","service":"sequence","parameters":{"evalue_cutoff":0.001,"identity_cutoff":0.9,"sequence_type":"protein","value":"MVLSPADKTNVKAAWGKVGAHAGEYGAEALERMFLSFPTTKTYFPHFDLSH"}},"return_type":"polymer_entity","request_options":{"paginate":{"start":0,"rows":10}}}'

# Download structure files
curl -s "https://files.rcsb.org/download/1HBB.cif" -o 1HBB.cif

# GraphQL for specific fields
curl -s -X POST "https://data.rcsb.org/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ entry(entry_id: \"1HBB\") { rcsb_entry_info { resolution_combined experimental_method } struct { title } } }"}'
```

**PDB IDs:** 4 chars (e.g., 1HBB). File formats: `.pdb` (legacy), `.cif` (modern, preferred).
> Source: skills/pdb-structure/SKILL.md

### ClinicalTrials.gov
**API v2. Max page: 1000. ~50 req/min.**

```bash
# Search by condition + status
curl -s "https://clinicaltrials.gov/api/v2/studies?query.cond=breast+cancer&filter.overallStatus=RECRUITING&pageSize=10"

# By intervention / location / sponsor
curl -s "https://clinicaltrials.gov/api/v2/studies?query.intr=Pembrolizumab&filter.overallStatus=RECRUITING&pageSize=50"

# Retrieve single trial
curl -s "https://clinicaltrials.gov/api/v2/studies/NCT04852770"
```

**Query params:** `query.cond`, `query.intr`, `query.locn`, `query.spons`, `filter.overallStatus`, `pageSize`, `pageToken`, `sort`.
**Status:** `RECRUITING`, `NOT_YET_RECRUITING`, `ACTIVE_NOT_RECRUITING`, `COMPLETED`, `TERMINATED`, `WITHDRAWN`.
> Source: skills/clinicaltrials-database/SKILL.md

### KEGG (Pathways)
**Metabolic/signaling pathways, gene-pathway links, ID conversion. Tab-separated output.**

```bash
# Search pathways
curl -s "https://rest.kegg.jp/find/pathway/apoptosis"

# Search genes
curl -s "https://rest.kegg.jp/find/genes/brca1"

# Get pathway details
curl -s "https://rest.kegg.jp/get/hsa04210"

# Genes in a pathway
curl -s "https://rest.kegg.jp/link/hsa/hsa04210"

# Pathways for a gene
curl -s "https://rest.kegg.jp/link/pathway/hsa:7157"

# Diseases linked to a gene
curl -s "https://rest.kegg.jp/link/disease/hsa:672"

# ID conversion: KEGG -> NCBI Gene
curl -s "https://rest.kegg.jp/conv/ncbi-geneid/hsa:7157"

# ID conversion: UniProt -> KEGG
curl -s "https://rest.kegg.jp/conv/hsa/uniprot:P04637"

# ID conversion: KEGG compound -> PubChem
curl -s "https://rest.kegg.jp/conv/pubchem/compound:C00031"

# Pathway image
curl -s "https://rest.kegg.jp/get/hsa04210/image" -o apoptosis.png
```

**Operations:** `/list` (enumerate), `/find` (search), `/get` (details), `/link` (cross-ref), `/conv` (ID conversion).
**Organism codes:** `hsa` (human), `mmu` (mouse), `rno` (rat), `dme` (fly), `sce` (yeast), `eco` (E. coli).
**Gene ID format:** `hsa:7157` (organism:gene_id). Pathway: `hsa04210` (organism+number).
> Source: skills/kegg-pathway/SKILL.md

### STRING (Protein-Protein Interactions)
**59M proteins, 20B+ interactions. Base: `https://string-db.org/api/{format}/{method}`.**

Key endpoints: `get_string_ids` (map names), `network` (PPI), `interaction_partners`, `enrichment` (GO/KEGG/Pfam), `ppi_enrichment` (network significance), `homology`.
Params: `identifiers=TP53%0dBRCA1` (newline-separated), `species=9606`, `required_score=400`, `network_type=functional|physical`.
**Thresholds:** 150 low, 400 medium (default), 700 high, 900 highest. Species: human=9606, mouse=10090, rat=10116.
> Source: skills/string-database/SKILL.md

### Ensembl (Genomics)
**250+ species. All requests need `-H "Content-Type: application/json"`.**

```bash
# Gene lookup by symbol / Ensembl ID
curl -s "https://rest.ensembl.org/lookup/symbol/homo_sapiens/BRCA2" -H "Content-Type: application/json"
curl -s "https://rest.ensembl.org/lookup/id/ENSG00000139618?expand=1" -H "Content-Type: application/json"

# Sequence / Region features / Variant / VEP / Orthologs
curl -s "https://rest.ensembl.org/sequence/id/ENSG00000139618" -H "Content-Type: application/json"
curl -s "https://rest.ensembl.org/overlap/region/human/7:140424943-140624564?feature=gene" -H "Content-Type: application/json"
curl -s "https://rest.ensembl.org/variation/human/rs699" -H "Content-Type: application/json"
curl -s "https://rest.ensembl.org/vep/human/hgvs/ENST00000380152.7:c.803C%3ET" -H "Content-Type: application/json"
curl -s "https://rest.ensembl.org/homology/id/ENSG00000139618?target_species=mouse" -H "Content-Type: application/json"
```

**GRCh37:** Use `https://grch37.rest.ensembl.org`. Rate: 15 req/s max.
> Source: skills/ensembl-database/SKILL.md

### ClinVar (Clinical Variants)
**Variant-disease relationships. Uses NCBI E-utilities (db=clinvar).**

```bash
# Search pathogenic variants
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=clinvar&term=BRCA1[gene]+AND+pathogenic[CLNSIG]&retmode=json"

# Fetch record
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=clinvar&id=37653&rettype=clinvarset&retmode=xml"
```

**Classifications (ACMG/AMP):** Pathogenic, Likely Pathogenic, VUS, Likely Benign, Benign.
**Review stars:** 4 (practice guideline) > 3 (expert panel) > 2 (multiple submitters) > 1 (single).
**Bulk FTP:** `ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/` -- XML, VCF (GRCh37/38), tab-delimited.
> Source: skills/clinvar-database/SKILL.md

### PubChem (Compounds)
**110M+ compounds. Properties, similarity search, bioactivity.**

```bash
# Lookup by name / CID / SMILES
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/aspirin/JSON"
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/2244/JSON"
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/smiles/CC(=O)OC1=CC=CC=C1C(=O)O/JSON"

# Properties (Lipinski) -- multiple compounds
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/2244,3672,2519/property/MolecularWeight,XLogP,HBondDonorCount,HBondAcceptorCount,TPSA/JSON"

# Similarity search (Tanimoto >= 90%)
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastsimilarity_2d/cid/2244/cids/JSON?Threshold=90&MaxRecords=10"

# Substructure search
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastsubstructure/smiles/c1ccccc1C(=O)O/cids/JSON?MaxRecords=10"

# Bioactivity + Pharmacology
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/2244/assaysummary/JSON"
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/2244/JSON?heading=Pharmacology+and+Biochemistry"
```

**Properties:** MolecularWeight, MolecularFormula, CanonicalSMILES, InChIKey, XLogP, TPSA, HBondDonorCount, HBondAcceptorCount, RotatableBondCount.
**URL patterns:** `.../compound/{namespace}/{id}/{operation}/{format}`. Namespaces: `name`, `cid`, `smiles`, `inchikey`.
> Source: skills/pubchem-compound/SKILL.md

### Reactome (Pathways)
**2,825+ human pathways. Content + Analysis services.**

```bash
# Pathway details
curl -s "https://reactome.org/ContentService/data/query/R-HSA-69278"

# Participating molecules in pathway
curl -s "https://reactome.org/ContentService/data/event/R-HSA-69278/participatingPhysicalEntities"

# Overrepresentation analysis (POST gene list)
curl -s -X POST "https://reactome.org/AnalysisService/identifiers/" \
  -H "Content-Type: text/plain" \
  -d "TP53
BRCA1
EGFR
MYC"

# Retrieve analysis by token (valid 7 days)
curl -s "https://reactome.org/AnalysisService/token/{TOKEN}"

# Species projection (map to human pathways)
curl -s -X POST "https://reactome.org/AnalysisService/identifiers/projection/" \
  -H "Content-Type: text/plain" -d "gene_list"

# Visualization URL
# https://reactome.org/PathwayBrowser/#R-HSA-69278&DTAB=AN&ANALYSIS={TOKEN}
```

**Accepted IDs:** UniProt (P04637), gene symbols (TP53), Ensembl (ENSG00000141510), EntrezGene (7157), ChEBI.
**Pathway ID format:** `R-HSA-69278` (R=Reactome, HSA=human, number).
> Source: skills/reactome-database/SKILL.md

### GEO (Gene Expression)
**264K+ studies, 8M+ samples. Via E-utilities + GEOparse + FTP.**

```bash
# Search GEO datasets via E-utilities
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=gds&term=breast+cancer+AND+Homo+sapiens&retmax=20&retmode=json"

# Download series matrix (FTP)
wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE123nnn/GSE123456/matrix/GSE123456_series_matrix.txt.gz

# Download SOFT format
wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE123nnn/GSE123456/soft/GSE123456_family.soft.gz
```

**Accession types:** GSE (series/experiment), GSM (sample), GPL (platform), GDS (curated dataset).
**FTP path pattern:** `ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE{nnn}nnn/GSE{full}/`
**Python:** `GEOparse.get_GEO(geo="GSE123456")` is the recommended access method.
> Source: skills/geo-database/SKILL.md

### Open Targets (Gene-Drug-Disease)
**GraphQL API. All requests: POST to `https://api.platform.opentargets.org/api/v4/graphql`.**

```bash
# Search target by gene symbol -> get Ensembl ID
curl -s -X POST https://api.platform.opentargets.org/api/v4/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"query { search(queryString: \"BRAF\", entityNames: [\"target\"], page: {size: 5, index: 0}) { hits { id name } } }"}'

# Disease associations for a target (Ensembl ID required)
curl -s -X POST https://api.platform.opentargets.org/api/v4/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"query { target(ensemblId: \"ENSG00000157764\") { approvedSymbol associatedDiseases(page: {size: 10, index: 0}) { rows { disease { id name } score } } } }"}'

# Targets for a disease (EFO ID required)
curl -s -X POST https://api.platform.opentargets.org/api/v4/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"query { disease(efoId: \"EFO_0000616\") { name associatedTargets(page: {size: 10, index: 0}) { rows { target { approvedSymbol } score } } } }"}'
```

**IDs:** Targets=Ensembl (ENSG...), Diseases=EFO (EFO_...), Drugs=ChEMBL (CHEMBL...).
**Evidence types:** genetic_association, known_drug, affected_pathway, somatic_mutation, literature, rna_expression, animal_model. Scores 0-1; >0.5 = strong.
> Source: skills/open-targets/SKILL.md

## Cross-Reference Patterns

| From | To | Method |
|------|-----|--------|
| Gene symbol | UniProt accession | UniProt search: `gene_exact:{symbol}+AND+organism_id:9606+AND+reviewed:true` |
| UniProt accession | PDB structures | UniProt entry `structure_3d:true` field, or PDB search by sequence |
| UniProt accession | ChEMBL target | `chembl/api/data/target.json?target_components__accession={uniprot}` |
| UniProt accession | KEGG gene | `rest.kegg.jp/conv/hsa/uniprot:{accession}` |
| Gene ID (NCBI) | KEGG gene | `rest.kegg.jp/conv/hsa/ncbi-geneid:{id}` |
| Gene ID (NCBI) | SNPs | `elink.fcgi?dbfrom=gene&db=snp&id={gene_id}` |
| Gene ID (NCBI) | ClinVar | `elink.fcgi?dbfrom=gene&db=clinvar&id={gene_id}` |
| Gene ID (NCBI) | PubMed | `elink.fcgi?dbfrom=gene&db=pubmed&id={gene_id}` |
| KEGG compound | PubChem CID | `rest.kegg.jp/conv/pubchem/compound:{kegg_id}` |
| KEGG gene | Pathways | `rest.kegg.jp/link/pathway/{kegg_gene_id}` |
| Ensembl gene ID | Open Targets | Direct: `target(ensemblId: "ENSG...")` |
| ChEMBL drug ID | Open Targets | Direct: `drug(chemblId: "CHEMBL...")` |
| Gene symbol | Ensembl ID | `rest.ensembl.org/lookup/symbol/homo_sapiens/{symbol}` |
| Gene symbol | STRING interactions | `string_map_ids('{symbol}', species=9606)` then `string_network()` |
| Gene list | Reactome pathways | POST to `AnalysisService/identifiers/` |
| Gene list | STRING enrichment | `string_enrichment(gene_list, species=9606)` |

**Common research chains:**
- **Drug target validation:** Gene symbol -> UniProt -> ChEMBL (bioactivity) -> Open Targets (disease evidence) -> ClinicalTrials.gov
- **Variant interpretation:** Gene -> NCBI Entrez (SNPs) -> ClinVar (pathogenicity) -> Ensembl VEP (functional prediction)
- **Pathway analysis:** Gene list -> KEGG/Reactome (pathway mapping) -> STRING (PPI network + enrichment)
- **Structure-function:** Gene -> UniProt (protein) -> PDB (3D structure) -> ChEMBL (binding data)

---

## USDA FoodData Central — Food Composition Database

400K+ food items with nutrient data. Covers branded, survey (FNDDS), foundation, and SR Legacy foods.

**Base URL**: `https://api.nal.usda.gov/fdc/v1/foods/search`
**Auth**: API key required. `DEMO_KEY` works for testing (30 req/hr). Free registered key: 3,600 req/hr.
**Rate Limit**: 30 req/hr (DEMO_KEY) / 3,600 req/hr (registered).

```bash
curl -s "https://api.nal.usda.gov/fdc/v1/foods/search?api_key=${USDA_API_KEY:-DEMO_KEY}&query=$(printf '%s' 'sesame paste' | jq -sRr @uri)&pageSize=10"
```

**Key response fields**: `foods[].description`, `foods[].fdcId`, `foods[].dataType`, `foods[].brandOwner`, `foods[].foodNutrients[]` (nutrientName, value, unitName).

**Data types**: `Foundation` (research-grade), `SR Legacy` (USDA standard reference), `Survey (FNDDS)` (dietary survey), `Branded` (commercial products).

**Use for**: food science research, nutritional analysis, dietary survey data, food composition comparison.

> Source: USDA FoodData Central API documentation (https://fdc.nal.usda.gov/api-guide.html)
