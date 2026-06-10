# Ingestion Rules: ETL vs ELT and dlt
<!-- capability: ingestion -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| ING1 | For AI/ML workloads, default to ELT (Extract → Load raw → Transform in-warehouse), not ETL | deterministic |
| ING2 | Never schema-enforce-and-discard raw payloads — ELT preserves raw history for retraining | deterministic |
| ING3 | Use ETL (schema-on-write) only when pre-storage masking/governance is required (HIPAA/PCI) or for IoT protocol conversion | deterministic |
| ING4 | Use dlt for connector-free ingestion with automatic schema inference + evolution | deterministic |
| ING5 | Audit dlt ingestion via the `_dlt_loads` metadata table — verify `status` per `load_id` | semi-deterministic |
| ING6 | Declare explicit column data-type hints; configure incremental load with a cursor field so only mutated/appended records load | semi-deterministic |

---

## Rules

### ING1: Default to ELT for AI/ML

When choosing an ingestion paradigm for an AI/ML pipeline, default to **ELT** (Extract → Load raw → Transform). ELT writes raw, semi-structured, and unstructured data directly into low-cost storage (S3, GCS, raw staging tables), then transforms inside the warehouse compute layer.

ELT is the preferred paradigm for ML because deep neural networks, NLP, and computer vision rely on unstructured inputs (raw JSON, text, image binaries, audio) — enforcing a rigid relational schema before ingestion is structurally impractical.

| Architectural Vector | Traditional ETL | Modern ELT |
|---|---|---|
| Execution Order | Extract → Transform (staging) → Load | Extract → Load (raw storage) → Transform |
| Transformation Location | Dedicated staging server / middleware | Directly in the lakehouse / warehouse |
| Schema Binding | Schema-on-write (strict pre-storage) | Schema-on-read (flexible runtime parse) |
| AI/ML Lifecycle Fit | Poor — no raw preservation | High — retains full raw history for retraining |

**determinismLevel**: deterministic — given an AI/ML target with unstructured data, ELT is the correct architectural choice.
> Source: findings.md "The Ingestion Paradigm" table + "For machine learning and artificial intelligence applications, ELT is the preferred paradigm" [1, 2, 3, 4, 5].

### ING2: Never Schema-Enforce-and-Discard Raw Data

In traditional ETL, raw data is typically discarded after transformation to save space. **Rule**: if the transformation logic must change to build a new model feature, you would have to re-extract historical state from source systems — complex and often impossible.

ELT solves this by maintaining a **permanent historical archive of raw data**, allowing pipelines to be re-run with updated processing logic on identical historical inputs. For any iterative feature-engineering project (i.e., all of them), preserve raw.

**determinismLevel**: deterministic — raw preservation is mandatory for feature iteration.
> Source: findings.md "In a traditional ETL process, raw data is typically discarded after transformation... ELT solves this by maintaining a permanent historical archive of raw data" [1, 2].

### ING3: When ETL Is Still Correct

ETL (schema-on-write) is the right choice in exactly these cases — do not over-apply ELT:

- **Pre-storage governance**: sensitive fields requiring masking BEFORE storage — HIPAA-regulated medical records, PCI-compliant financial profiles — must be validated, structured, and normalized to a rigid target schema first.
- **IoT / edge protocol conversion**: raw payloads arriving in complex proprietary protocols must be immediately converted to standard tabular formats to preserve storage efficiency.

**determinismLevel**: deterministic — these constraints force ETL.
> Source: findings.md "Traditional ETL Pipelines" — schema-on-write optimized for HIPAA/PCI masking and IoT protocol conversion [1, 3, 4, 5].

### ING4: Use dlt for Connector-Free Ingestion with Schema Evolution

The Data Load Tool (**dlt**) is an open-source Python library for connector-free ingestion from arbitrary sources (REST APIs, SQL databases, dynamic Python generators) into analytical destinations. Use it when:

- You need automatic **schema inference and evolution** — dlt dynamically adjusts downstream tables as upstream source structures shift, ensuring pipeline resilience.
- You ingest deeply nested JSON — dlt automates normalization of nested structures.

Define a resource with explicit column hints:
```python
@dlt.resource(
    table_name="eod_prices_raw",
    write_disposition="append",  # raw landing preserves history; never "replace" (it destroys the prior raw table each run, violating ING2)
    primary_key=("ticker", "date"),
    columns={
        "ticker": {"data_type": "text"},
        "date": {"data_type": "date"},
        "close_price": {"data_type": "double"},
        "volume": {"data_type": "bigint"},
    },
)
def yfinance_eod_prices(tickers, start_date, end_date):
    # Pair with dlt.sources.incremental("date") for cursor-based incremental load (see ING6)
    yield [...]

pipeline = dlt.pipeline(
    pipeline_name="financial_extract",
    destination=dlt.destinations.duckdb("./financial_etl_dlt.duckdb"),
    dataset_name="raw",
)
load_info = pipeline.run(yfinance_eod_prices(...))
```

**determinismLevel**: deterministic — dlt is the tool selection for schema-evolving ingestion.
> Source: findings.md "In-Process and Local-First Modern Data Stacks: dlt..." [13, 15, 16] and the dlt resource code example [16].

### ING5: Audit Ingestion via the `_dlt_loads` Metadata Table

dlt handles incremental loading through systematic metadata tracking, writing to load-logging tables such as `_dlt_loads`. **Rule**: after every ingestion run, audit pipeline health by querying this table — do not assume success from a non-error exit.

```sql
-- Audit ingestion batch metadata and verify pipeline completion statuses
SELECT load_id, schema_name, status, inserted_at
FROM raw._dlt_loads
ORDER BY inserted_at DESC
LIMIT 5;
```
Check that the latest `load_id` shows a successful `status`. Inspect physical tables via `information_schema.tables WHERE table_schema = 'raw'`.

**determinismLevel**: semi-deterministic — the audit query is fixed; the load contents vary per run.
> Source: findings.md DuckDB metadata-auditing SQL queries against `raw._dlt_loads` and `information_schema.tables` [16].

### ING6: Configure Incremental Load with a Cursor

dlt loads only mutated or appended records **when incremental loading is explicitly configured** — it is not automatic. You must choose a cursor field (e.g., `updated_at`/`date`) via `dlt.sources.incremental(...)` and pair it with an appropriate `write_disposition` (`append` or `merge`); without this, the resource re-scans the full source each run. **Rule**: for high-volume sources, configure cursor-based incremental load rather than full-refresh, and declare explicit `data_type` hints so schema inference does not silently widen a column type on a single anomalous row.

```python
@dlt.resource(write_disposition="merge", primary_key="id")
def events(cursor=dlt.sources.incremental("updated_at")):
    # dlt tracks the last cursor value and skips records older than it on the next run
    yield from fetch_since(cursor.last_value)
```

**determinismLevel**: semi-deterministic — incremental behavior depends on cursor configuration and source mutation state.
> Source: findings.md "handles incremental loading through systematic metadata tracking... loading only mutated or appended records" [13, 16, 17]; dlt incremental loading requires a configured cursor field — https://dlthub.com/docs/general-usage/incremental/cursor

---

## Anti-Patterns

- **Schema-on-write for unstructured AI data**: enforcing relational schemas on raw JSON/images/audio before ingestion is structurally impractical and discards raw history.
- **Trusting exit code over `_dlt_loads`**: a clean process exit is not proof of a successful, complete load — query the load log.
- **Re-extracting history to change a feature**: the symptom of having discarded raw data. ELT prevents this.
- **Hand-writing connectors**: dlt's connector-free ingestion + schema evolution replaces brittle bespoke extractors.
