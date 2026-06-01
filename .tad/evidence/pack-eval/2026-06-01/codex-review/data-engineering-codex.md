[P0] “legacy YAML eliminated in v1.0”
Why wrong: GX Core still supports File Data Contexts that store metadata/configuration as YAML files. Official docs describe YAML-backed File Data Contexts.
Fix: Say “GX 1.x is Python-first; YAML project configuration still exists for persistent File Data Contexts.” Source: https://docs.greatexpectations.io/docs/core/set_up_a_gx_environment/create_a_data_context/

[P0] `write_disposition="replace"`
Why wrong: This example is inside a rule arguing for raw-history preservation, but `replace` destroys the previous raw table on each run.
Fix: Use append/merge for raw landing, add an incremental cursor, and keep immutable raw history.

[P0] “dlt loads only mutated or appended records through metadata tracking — it does not re-scan the full source each run.”
Why wrong: dlt only does this when incremental loading is configured with a cursor/source strategy. The docs explicitly require choosing a cursor field and passing last values for many sources.
Fix: “dlt supports incremental loading when configured with `dlt.sources.incremental(...)`, cursor fields, and appropriate write disposition.” Source: https://dlthub.com/docs/general-usage/incremental/cursor

[P0] “Over five years, only 10 million of 150 million total records remain active.”
Why wrong: The stated math omits the initial 10M rows. 10M initial + 30M/year * 5 years = 160M total rows, unless the example defines 150M as update rows only.
Fix: Correct the arithmetic or rewrite the example as “150M historical versions plus 10M current rows.”

[P1] “They default to Pandas where Polars would parallelize for free.”
Why wrong: “For free” is slop. Polars can parallelize many operations, but performance depends on query plan, data format, memory pressure, UDFs, joins, and IO.
Fix: Say “Polars often improves non-trivial columnar transforms, especially with lazy plans and pushdown; benchmark on representative workloads.”

[P1] “source citations on every number”
Why wrong: The pack cites opaque `findings.md [n]` labels, not source URLs or bibliographic entries. A loaded capability pack cannot let an agent verify numbers independently.
Fix: Include a `findings.md` bibliography with URLs, dates accessed, and exact claims, or inline source URLs per concrete version/number.

[P1] “mathematically incapable of detecting label corruption (mislabeled classes) or downstream class-distribution imbalance”
Why wrong: Class imbalance over structured labels is exactly count/distribution validation and can be checked by GX/Soda-style rules. Semantic mislabeling is the hard part.
Fix: Split the claim: “Rules can detect declared label distribution anomalies; they generally cannot determine semantic label correctness for unstructured examples without model-assisted review.”

[P1] “Use Soda Core v4 Data Contracts to halt and isolate anomalies”
Why wrong: Soda contracts report failures and can be wired into a pipeline to fail/quarantine, but “halt and isolate” is not automatic unless the orchestration code enforces that behavior.
Fix: “Configure the pipeline to fail the run or quarantine data when Soda contract verification fails.”

[P1] “any analytical query that omits a strict `is_current = true` filter is forced to scan the entire 150-million-row dataset”
Why wrong: Historical/time-travel queries should not use `is_current = true`; they should filter by validity intervals. Optimizers may also prune partitions/indexes without `is_current`.
Fix: “For current-state queries, filter `is_current = true`; for historical joins, use `event_ts BETWEEN valid_from AND valid_to` and partition/index validity fields.”

[P1] “write duplicate surrogate keys if generation logic is not fully idempotent — surrogate-key collisions”
Why wrong: Non-idempotent retries more commonly create duplicate dimension versions with different surrogate keys, not surrogate-key collisions. Collision wording misdiagnoses the failure.
Fix: Require idempotent upsert/merge keyed on business key plus effective timestamp, uniqueness constraints, and deterministic handling of retries.

[P1] “Airflow | `pip install apache-airflow`”
Why wrong: Official Airflow installation is via pip with version pinning and constraint files; the bare command is not the supported reproducible install path.
Fix: Use `pip install "apache-airflow==3.2.2" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-3.2.2/constraints-3.10.txt"` adjusted for Python version. Source: https://airflow.apache.org/docs/apache-airflow/stable/installation/installing-from-pypi.html

[P1] “dbt | `pip install dbt-core`”
Why wrong: `dbt-core` alone is insufficient for real projects because adapters are separate packages.
Fix: Show adapter-specific installs, e.g. `pip install dbt-core dbt-duckdb` or `dbt-postgres`.

[P1] “native, out-of-the-box column-level data lineage”
Why wrong: Dagster has asset lineage, but blanket native column-level lineage is an overclaim. Column-level lineage is integration-dependent, not a universal out-of-the-box Dagster core guarantee.
Fix: Say “asset-level lineage by default; column-level lineage depends on dbt/warehouse metadata integrations and parser support.” Source: https://docs.dagster.io/

[P1] “for production RAG, do not rely on dense-only retrieval; fuse dense + sparse via RRF with k = 60.”
Why wrong: `k=60` is a common RRF default, not a deterministic production constant. Dense-only can be acceptable for some corpora; sparse fusion helps when exact terms matter.
Fix: “Evaluate dense-only, sparse-only, and hybrid retrieval; tune RRF `k` on retrieval metrics such as recall@k/MRR for the corpus.”

[P1] “Embedded model inference gives sub-ms latency but model updates require a full rolling cluster restart”
Why wrong: Embedded inference can support dynamic model loading, side inputs, broadcast state, or versioned local model refresh depending on the stream processor and serving design.
Fix: “Embedded inference can achieve very low latency, but model update mechanics must be designed explicitly; rolling restart is one common approach, not a universal requirement.”

[P1] “move validation, structural shaping, and feature computation earlier — to ingestion-time”
Why wrong: This conflicts with the pack’s ELT/raw-history rule. Computing features at ingestion can bake in irreversible logic and make retraining harder.
Fix: “Shift-left validation/contracts and minimal normalization, while preserving immutable raw data; compute versioned features downstream from raw history unless latency requires streaming features.”

[P2] “High latency if the filter is highly selective (massive subset scans)”
Why wrong: “Highly selective” normally means a small subset, not a massive subset. The sentence confuses selectivity terminology.
Fix: “Pre-filtering can be slow when the filtered subset is large or when the vector index cannot search the filtered subset efficiently.”

VERDICT: FIX-FIRST
