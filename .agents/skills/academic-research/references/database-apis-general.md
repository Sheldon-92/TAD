# General Academic Databases -- Academic Research Reference
> Consolidated from 10 ScienceClaw skills.

## Quick Reference
| Database | Base URL | Auth | Rate Limit | Source Skill |
|----------|---------|------|-----------|-------------|
| Semantic Scholar | `api.semanticscholar.org/graph/v1` | Optional API key (free) | 100 req/5min (no key); 1/s sustained, 10/s burst (key) | semantic-scholar |
| OpenAlex | `api.openalex.org` | None (email for polite pool) | 1 req/s default; 10 req/s with mailto | openalex-database |
| PubMed | `eutils.ncbi.nlm.nih.gov/entrez/eutils/` | Optional NCBI API key | 3 req/s (no key); 10 req/s (key) | pubmed-search |
| arXiv | `export.arxiv.org/api/` | None | ~1 req/3s recommended | arxiv-search |
| World Bank | `api.worldbank.org/v2/` | None | No official limit | world-bank-data |
| CrossRef | `api.crossref.org` | None (email for polite pool) | 1 req/s default; 50 req/s with mailto | crossref-search |
| OpenAlex (search) | `api.openalex.org` | None | 10 req/s (no mailto) to 100 req/s (mailto) | openalex-search |
| SSRN/RePEc | HTML scraping / CrossRef API | None | Varies | ssrn-econpapers |
| CourtListener | `courtlistener.com/api/rest/v4/` | None (register for higher) | Not specified | legal-search |
| DBLP | `dblp.org/search/` | None | No official limit | dblp-search |

## Detailed API Templates

### Semantic Scholar
**200M+ papers, citation graphs, author profiles, recommendations.**

```bash
# Paper search (basic)
curl -s "https://api.semanticscholar.org/graph/v1/paper/search?query=machine+learning+drug+discovery&limit=5&fields=title,authors,year,abstract,citationCount,url"

# Bulk search (up to 10M results, token-based pagination)
curl -s "https://api.semanticscholar.org/graph/v1/paper/search/bulk?query=CRISPR+gene+editing&fields=title,year,citationCount"

# Lookup by DOI / arXiv / PMID
curl -s "https://api.semanticscholar.org/graph/v1/paper/DOI:10.1038/s41586-021-03819-2?fields=title,abstract,authors,year,citationCount"
curl -s "https://api.semanticscholar.org/graph/v1/paper/ARXIV:2301.07041?fields=title,abstract,year"
curl -s "https://api.semanticscholar.org/graph/v1/paper/PMID:34265844?fields=title,abstract,year"

# Citation graph (citing / cited-by)
curl -s "https://api.semanticscholar.org/graph/v1/paper/ARXIV:2301.07041/citations?fields=title,year,citationCount&limit=20"
curl -s "https://api.semanticscholar.org/graph/v1/paper/ARXIV:2301.07041/references?fields=title,year,citationCount&limit=20"

# Author search + papers
curl -s "https://api.semanticscholar.org/graph/v1/author/search?query=yann+lecun&fields=name,hIndex,paperCount,citationCount"
curl -s "https://api.semanticscholar.org/graph/v1/author/1688681/papers?fields=title,year,citationCount&limit=20"

# Recommendations (single-paper)
curl -s "https://api.semanticscholar.org/recommendations/v1/papers/forpaper/ARXIV:2301.07041?fields=title,year,citationCount&limit=10"
```

**Key params:** `query=`, `limit=` (max 100), `offset=`, `fields=`, `year=` (e.g. `2020-2024`), `fieldsOfStudy=`, `minCitationCount=`.
**Key fields:** `paperId`, `title`, `abstract`, `year`, `citationCount`, `influentialCitationCount`, `isOpenAccess`, `openAccessPdf`, `tldr`, `externalIds`.
**Auth:** `curl -s -H "x-api-key: ${S2_API_KEY}" ...` -- Register free at semanticscholar.org.
> Source: skills/semantic-scholar/SKILL.md

### OpenAlex
**240M+ works, completely open, no API key.**

```bash
# Search works
curl -s "https://api.openalex.org/works?search=CRISPR+gene+editing&per_page=5&mailto=user@example.com"

# Filter by year + open access + citations
curl -s "https://api.openalex.org/works?filter=publication_year:2023-2024,cited_by_count:>100,open_access.is_oa:true&sort=cited_by_count:desc&per_page=10"

# Lookup by DOI
curl -s "https://api.openalex.org/works/doi:10.1038/s41586-024-07000-0"

# Author search (two-step: name -> ID -> works)
curl -s "https://api.openalex.org/authors?search=Yoshua+Bengio&per_page=5"
curl -s "https://api.openalex.org/works?filter=authorships.author.id:A5023888391&per_page=200"

# Institution search
curl -s "https://api.openalex.org/institutions?search=MIT&per_page=5"

# Group-by (trends)
curl -s "https://api.openalex.org/works?filter=authorships.author.id:A5023888391&group_by=publication_year"

# Cursor-based pagination (unlimited)
curl -s "https://api.openalex.org/works?search=climate&per_page=100&cursor=*"
```

**Filter syntax:** `publication_year:>2020`, `is_oa:true`, `cited_by_count:>100`. OR: `id1|id2`. AND within: `id1+id2`. Negation: `!paratext`.
**Entity types:** W (works), A (authors), I (institutions), C (concepts).
**External IDs:** DOI, ORCID (`https://orcid.org/...`), ROR, ISSN.
> Source: skills/openalex-database/SKILL.md, skills/openalex-search/SKILL.md

### PubMed (NCBI E-utilities)
**36M+ biomedical citations. Two-step: esearch -> efetch.**

```bash
# Step 1: Search (returns PMIDs)
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=COVID-19+vaccine+efficacy&retmax=10&retmode=json"

# Step 2: Fetch abstracts by PMID
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=39142890,39088712&retmode=xml&rettype=abstract"

# Combined two-step
PMIDS=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=QUERY&retmax=5&retmode=json" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(','.join(d['esearchresult']['idlist']))")
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${PMIDS}&retmode=xml&rettype=abstract"
```

**Query syntax:** Boolean `AND`, `OR`, `NOT`. Field tags: `[ti]` title, `[tiab]` title/abstract, `[au]` author, `[mesh]` MeSH heading, `[majr]` MeSH major topic, `[pt]` publication type, `[dp]` date, `[jour]` journal.
**MeSH example:** `"Breast Neoplasms"[mesh] AND "Drug Therapy"[mesh]`
**Auth:** Append `&api_key=${NCBI_API_KEY}` for 10 req/s. Register at ncbi.nlm.nih.gov/account/settings/.
> Source: skills/pubmed-search/SKILL.md

### arXiv
**Preprints: physics, math, CS, q-bio, q-fin, stats, econ. Returns Atom XML.**

```bash
# Search
curl -s "http://export.arxiv.org/api/query?search_query=all:transformer+attention&start=0&max_results=5"

# Field-specific search with boolean
curl -s "http://export.arxiv.org/api/query?search_query=au:bengio+AND+cat:cs.LG+AND+ti:attention&max_results=10"

# Direct lookup by ID
curl -s "http://export.arxiv.org/api/query?id_list=2301.07041,2302.13971"

# Latest papers in a category
curl -s "http://export.arxiv.org/api/query?search_query=cat:cs.AI&start=0&max_results=25&sortBy=submittedDate&sortOrder=descending"
```

**Field prefixes:** `ti:` title, `au:` author, `abs:` abstract, `cat:` category, `all:` all.
**Key categories:** `cs.AI`, `cs.CL` (NLP), `cs.CV`, `cs.LG` (ML), `cs.CR`, `q-bio`, `q-fin`, `stat.ML`.
**PDF access:** Replace `/abs/` with `/pdf/` in the paper URL.
> Source: skills/arxiv-search/SKILL.md

### World Bank
**Development indicators by country/year. Response: `[metadata, data]` array.**

```bash
# GDP for a country (date range)
curl -s "https://api.worldbank.org/v2/country/US/indicator/NY.GDP.MKTP.CD?format=json&date=2015:2023&per_page=50"

# Multiple countries
curl -s "https://api.worldbank.org/v2/country/US;CN;IN/indicator/NY.GDP.MKTP.CD?format=json&date=2020:2023"

# Most recent non-null value
curl -s "https://api.worldbank.org/v2/country/US/indicator/NY.GDP.MKTP.CD?format=json&mrnev=1"

# All countries metadata
curl -s "https://api.worldbank.org/v2/country?format=json&per_page=300"

# Topics and indicators
curl -s "https://api.worldbank.org/v2/topic/4/indicator?format=json&per_page=100"
```

**Common indicators:** `NY.GDP.MKTP.CD` (GDP), `NY.GDP.PCAP.CD` (GDP/capita), `SP.POP.TOTL` (population), `SP.DYN.LE00.IN` (life expectancy), `SI.POV.DDAY` (poverty), `EN.ATM.CO2E.PC` (CO2/capita).
**Date formats:** `date=2023` (single), `date=2015:2023` (range), `date=2015;2018;2023` (list).
**Country codes:** ISO 3166-1 alpha-2. Income levels: HIC, UMC, LMC, LIC.
> Source: skills/world-bank-data/SKILL.md

### CrossRef
**DOI resolution, citation metadata, journal/funder lookup.**

```bash
# Resolve DOI
curl -s "https://api.crossref.org/works/10.1038/nature12373"

# Search works
curl -s "https://api.crossref.org/works?query=machine+learning+protein+folding&rows=5&mailto=user@example.com"

# Filter by date + type + sort by citations
curl -s "https://api.crossref.org/works?query=CRISPR&filter=from-pub-date:2023-01-01,type:journal-article&rows=10&sort=is-referenced-by-count&order=desc&mailto=user@example.com"

# Journal lookup by ISSN
curl -s "https://api.crossref.org/journals/0028-0836/works?rows=5&sort=published&order=desc"

# Funder search
curl -s "https://api.crossref.org/funders/100000002/works?rows=5&sort=is-referenced-by-count&order=desc"

# Reference list for a paper
curl -s "https://api.crossref.org/works/10.1038/nature12373" | python3 -c "import sys,json; refs=json.load(sys.stdin)['message'].get('reference',[]); [print(r.get('DOI','no DOI')) for r in refs[:10]]"
```

**Filters:** `type:journal-article`, `from-pub-date:YYYY-MM-DD`, `has-abstract:true`, `funder:ID`.
**Sorting:** `sort=published|is-referenced-by-count|relevance`, `order=asc|desc`.
**Pagination:** `rows=N` (max 1000), `offset=N`, `cursor=*` for deep paging.
> Source: skills/crossref-search/SKILL.md

### SSRN / RePEc / Social Science
**Working papers in economics, finance, law, political science.**

```bash
# CrossRef with subject filter (most reliable)
curl -s "https://api.crossref.org/works?query=behavioral+economics+nudge&filter=subject:social-science&rows=10&sort=relevance"

# RePEc IDEAS search (HTML scraping)
curl -s "https://ideas.repec.org/cgi-bin/htsearch?q=trade+tariffs+welfare&cmd=Search%21&dt=range&db=2020-01-01"

# SSRN search (HTML scraping, no public API)
curl -s "https://papers.ssrn.com/sol3/results.cfm?RequestTimeout=50000000&txtKey_Words=climate+finance+risk" -H "User-Agent: Mozilla/5.0"

# Semantic Scholar with social science field filter
curl -s "https://api.semanticscholar.org/graph/v1/paper/search?query=causal+inference+social+policy&fieldsOfStudy=Economics,Sociology,Political+Science&fields=title,year,authors,citationCount,externalIds&limit=10"
```

**Key journal ISSNs:** AER: `0002-8282`, QJE: `0033-5533`, JPE: `0022-3808`, Econometrica: `0012-9682`.
**S2 social science fields:** `Economics`, `Sociology`, `Political Science`, `Business`, `Psychology`, `Law`.
> Source: skills/ssrn-econpapers/SKILL.md

### CourtListener / Harvard Case Law / EUR-Lex
**US + EU case law and regulations.**

```bash
# CourtListener: search opinions
curl -s "https://www.courtlistener.com/api/rest/v4/search/?q=qualified+immunity&type=o&order_by=score+desc"

# Filter by court + date
curl -s "https://www.courtlistener.com/api/rest/v4/search/?q=free+speech&type=o&court=scotus&filed_after=2020-01-01&order_by=dateFiled+desc"

# Harvard Case Law: search by citation
curl -s "https://api.case.law/v1/cases/?cite=410+U.S.+113"

# Harvard Case Law: search by keyword + jurisdiction
curl -s "https://api.case.law/v1/cases/?search=eminent+domain&jurisdiction=cal&decision_date_min=2010-01-01&page_size=10"
```

**Court codes:** `scotus`, `ca1`-`ca11`, `cafc`, `cadc`, `nyd`, `cand`.
**Search types:** `type=o` (opinions), `type=r` (dockets).
> Source: skills/legal-search/SKILL.md

### DBLP
**CS bibliography. No API key. JSON or XML.**

```bash
# Search publications
curl -s "https://dblp.org/search/publ/api?q=attention+is+all+you+need&format=json&h=5"

# Search authors
curl -s "https://dblp.org/search/author/api?q=Yoshua+Bengio&format=json&h=5"

# Author publication list (by PID)
curl -s "https://dblp.org/pid/b/YoshuaBengio.xml?format=json"

# Pagination: h = results per page, f = first result index
curl -s "https://dblp.org/search/publ/api?q=graph+neural+network&format=json&h=20&f=0"
```

> Source: skills/dblp-search/SKILL.md

## Cross-Reference Patterns

| From | To | Method |
|------|-----|--------|
| DOI | S2 paper | `api.semanticscholar.org/graph/v1/paper/DOI:{doi}` |
| arXiv ID | S2 paper | `api.semanticscholar.org/graph/v1/paper/ARXIV:{id}` |
| PMID | S2 paper | `api.semanticscholar.org/graph/v1/paper/PMID:{pmid}` |
| DOI | OpenAlex work | `api.openalex.org/works/doi:{doi}` |
| ORCID | OpenAlex author | `api.openalex.org/authors/https://orcid.org/{orcid}` |
| ROR | OpenAlex institution | `api.openalex.org/institutions/https://ror.org/{ror}` |
| ISSN | OpenAlex source | `api.openalex.org/sources/issn:{issn}` |
| DOI | CrossRef metadata | `api.crossref.org/works/{doi}` |
| ISSN | CrossRef journal | `api.crossref.org/journals/{issn}` |
| PubMed PMID | efetch record | `eutils...efetch.fcgi?db=pubmed&id={pmid}` |
| Gene symbol | S2 field filter | `fieldsOfStudy=Medicine` on S2 search |
| S2 paper `externalIds` | DOI, PMID, arXiv | Parse `externalIds` field from S2 response |

**Recommended discovery chain:** Semantic Scholar (broad search) -> DOI -> CrossRef (metadata) -> OpenAlex (OA links, institution data).

---

## Europeana — Cultural Heritage Database

50M+ digital objects from European museums, libraries, and archives. Useful for cultural artifact research, art history, and pattern analysis.

**Base URL**: `https://api.europeana.eu/record/v2/search.json`
**Auth**: API key required (free: https://pro.europeana.eu/page/get-api). No demo key available.
**Rate Limit**: 100 req/min with key.

```bash
curl -s "https://api.europeana.eu/record/v2/search.json?wskey=${EUROPEANA_API_KEY}&query=$(printf '%s' 'ornamental pattern' | jq -sRr @uri)&rows=10"
```

**Key response fields**: `items[].title`, `items[].dcCreator`, `items[].year`, `items[].dataProvider`, `items[].guid` (permalink), `items[].edmPreview` (thumbnail URL).

**Use for**: art/design pattern research, cultural heritage analysis, historical artifact discovery.

> Source: Europeana Search API documentation (https://pro.europeana.eu/page/search)
