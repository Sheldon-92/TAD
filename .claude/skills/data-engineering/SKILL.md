---
name: data-engineering
description: Data engineering for AI capability pack. Gives AI agents the judgment rules for AI data pipelines — ETL/ELT ingestion (dlt, schema evolution), local-first transformation stacks (DuckDB, Polars, dbt) and train-serve skew defense, orchestration selection (Airflow 3.2 / Dagster 1.13 / Prefect 3.7), data quality gates (Great Expectations v1.0 / Soda Core v4), dimensional modeling and Slowly Changing Dimensions (SCD Type 0-6), and vector + streaming retrieval (metadata filtering, RRF, Kafka/Flink). Research-grounded rules with source citations. Use for any AI data pipeline, feature engineering, warehouse modeling, RAG context-lake, or real-time inference architecture task.
keywords: ["数据工程", "data engineering", "数据管道", "data pipeline", "ETL", "ELT", "特征工程", "feature engineering", "dbt", "dlt", "DuckDB", "Polars", "数据质量", "data quality", "Great Expectations", "Soda", "编排", "orchestration", "Airflow", "Dagster", "Prefect", "维度建模", "SCD", "slowly changing dimensions", "向量数据库", "vector database", "RAG", "流式处理", "streaming", "Kafka", "Flink", "feature store", "schema evolution"]
type: reference-based
---

**CONSUMES**: User data-pipeline task + source/destination description + optional existing pipeline configs, dbt models, warehouse schemas, or RAG/streaming setup
**PRODUCES**: Applied data-engineering judgment rules + ingestion-pattern decisions (ETL vs ELT) + transformation/feature designs + orchestrator selection + data-quality gate configs + SCD/dimensional model + vector-filtering & streaming-inference architecture

# Data Engineering for AI Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents build data pipelines by reaching for the first tool they remember. They default to Pandas where Polars would parallelize for free. They enforce rigid schemas on raw JSON before storage, discarding the raw history that model retraining needs. They write feature transformations once in a training notebook and again in a serving path — silently introducing train-serve skew. They pick Airflow for a lightweight agentic workflow that Prefect handles better. They run a global vector search and post-filter, then wonder why RAG returns zero results for a tenant. They build SCD Type 2 tables that scan 150M rows because a query forgot `is_current = true`.

This pack embeds the judgment rules that data engineers apply automatically — rules grounded in 2026 tooling research (dlt, DuckDB, Polars, dbt, Airflow 3.2, Dagster 1.13, Prefect 3.7, Great Expectations v1.0 GA, Soda Core v4, Kafka/Flink) with source citations on every number.

**Pack = data-engineering judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Train-Serve Skew is a Silent Killer

> **The transformation logic that prepares offline training data and the logic that prepares real-time inference payloads MUST be the same code, not two copies.** When they diverge, the model produces invalid predictions in production while reporting high validation accuracy offline — silent degradation that no offline test catches. Enforce a single version-controlled transformation source (dbt model compiled into the warehouse, or a registered Feature View) that feeds BOTH the historical batch training table AND the low-latency serving table.

This rule applies to: feature engineering, dbt model design, feature-store registration, and any pipeline where the same feature is computed for both training and serving. It is surfaced here because burying it in one reference file is exactly how skew enters production.
> Source: findings.md "Mitigation of Train-Serve Skew" [8] — dbt as a single version-controlled repository feeding both training tables and real-time serving.

---

## Step 0: Context Detection

When the user mentions data-engineering work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "ingest", "ETL", "ELT", "extract", "load", "connector", "schema evolution", "raw data", "dlt", "数据接入" | `references/ingestion-rules.md` |
| "transform", "feature engineering", "dbt", "DuckDB", "Polars", "normalize", "scaling", "feature store", "特征工程", "转换" | `references/transformation-stack-rules.md` |
| "orchestrate", "schedule", "DAG", "pipeline tool", "Airflow", "Dagster", "Prefect", "asset", "编排", "调度" | `references/orchestration-rules.md` |
| "data quality", "validation", "expectations", "data contract", "drift", "Great Expectations", "Soda", "数据质量", "校验" | `references/data-quality-rules.md` |
| "dimensional model", "star schema", "SCD", "slowly changing dimension", "fact table", "warehouse model", "维度建模", "历史追踪" | `references/dimensional-modeling-rules.md` |
| "vector", "RAG", "metadata filter", "embedding", "streaming", "real-time inference", "Kafka", "Flink", "向量", "流式" | `references/vector-streaming-rules.md` |
| "full pipeline", "complete data architecture", "end-to-end data platform" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's pipeline, config, schema, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix (named tool, CLI command, or threshold from the reference)
4. **Enforce the Train-Serve Skew cross-cutting rule** on every feature-engineering or dbt design
5. **Check determinismLevel annotations** — they tell you how reproducible a decision is:
   - `deterministic`: architectural/classification decision (e.g., ETL-vs-ELT choice, SCD type assignment) — one correct answer given the inputs
   - `semi-deterministic`: config-driven but data-dependent (e.g., schema-evolution behavior, anomaly thresholds)
   - `non-deterministic`: runtime/streaming behavior whose outcome varies (e.g., async-inference latency, graph-islanding under strict filters)

Output format per finding:
```
[P0] Rule ING2 (ingestion): Raw JSON is being schema-enforced and discarded after transform.
→ Switch to ELT: write raw payloads to low-cost storage first, transform in-warehouse. ELT retains full raw history for model retraining; ETL discards it.

[P1] Rule TRN1 (transformation): Feature computed separately in training notebook and serving path.
→ Move the transformation into a single dbt model / registered Feature View feeding both. Train-serve skew causes silent production degradation.
```

---

## Step 2: Output

Produce a structured data-engineering review:

```
## Data Engineering Review: [area reviewed]

### P0 — Blocking (must fix before pipeline goes to production)
- [finding + specific fix]

### P1 — Required (fix before trusting the data)
- [finding + specific fix]

### P2 — Advisory (improves robustness / cost)
- [finding + specific fix]

### Architecture Decision Log
[ingestion pattern chosen, orchestrator chosen, SCD types assigned, filtering strategy — each with the rule that drove it]

### Tool Recommendation
[dlt / DuckDB / Polars / dbt / Airflow|Dagster|Prefect / Great Expectations|Soda based on user context]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "We'll enforce the schema on ingest to keep it clean" | Schema-on-write discards raw history. When you change a feature next quarter you must re-extract historical state — often impossible. ELT keeps raw history for retraining (findings [1,2]). |
| "We'll just spin up Spark" | For medium-scale data, DuckDB (vectorized, in-process) and Polars (multi-threaded, lazy) eliminate cluster sync latency and cost. DuckDB speeds pipelines 10x+ without leaving the Python process (findings [14]). |
| "Same feature logic, I'll write it twice" | That IS train-serve skew. Two copies drift → silent production degradation with high offline accuracy. One version-controlled source feeding both paths (findings [8]). |
| "Post-filter the vector search, it's faster" | Post-filtering risks recall collapse — zero results if none of the top-k global neighbors match the metadata. For tenant isolation use pre-filtering; it guarantees k results if they exist (findings [35]). |
| "Great Expectations checks everything" | Rules-based engines have unstructured-data blind spots: they cannot detect mislabeled classes, class imbalance, or concept drift on images/audio. Pair with AI-driven diagnostics (findings [24]). |
| "Airflow is the standard, use it" | Airflow 3.2 carries a heavy split-component footprint (web server, scheduler, metadata DB, workers, API server). For dynamic agentic workflows, Prefect 3.7's decorator runtime fits better (findings [18,19]). |

---

## Tool Quick Reference

| Tool | Install | Primary Use |
|------|---------|-------------|
| dlt | `pip install dlt` | Connector-free ingestion, schema inference/evolution, incremental load |
| DuckDB | `pip install duckdb` | In-process OLAP, vectorized SQL on local Parquet/CSV/JSON |
| Polars | `pip install polars` | Multi-threaded DataFrames, lazy `LazyFrame` with predicate/projection pushdown |
| dbt | `pip install dbt-core` | Version-controlled SQL/Python transforms; train-serve skew defense |
| Apache Airflow | `pip install apache-airflow` | Multi-team batch retraining; asset-aware (v3.2) |
| Dagster | `pip install dagster` | Software-defined assets, column-level lineage (v1.13) |
| Prefect | `pip install prefect` | Dynamic decorator-based agentic workflows (v3.7) |
| Great Expectations | `pip install great_expectations` | Code-first Python Fluent API validation + Data Docs |
| Soda Core | `pip install soda-core` | Declarative SodaCL YAML checks + data contracts (v4) |
