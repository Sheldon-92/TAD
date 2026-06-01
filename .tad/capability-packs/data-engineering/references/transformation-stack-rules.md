# Transformation Stack Rules: dbt, DuckDB, Polars, Feature Engineering
<!-- capability: transformation -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| TRN1 | Defend against train-serve skew: one version-controlled transform (dbt) feeds BOTH training and serving | deterministic |
| TRN2 | For medium-scale data, use DuckDB (in-process, vectorized) instead of a Spark cluster | deterministic |
| TRN3 | Use Polars `LazyFrame` for predicate + projection pushdown; prefer it over Pandas for parallelism | deterministic |
| TRN4 | Apply the correct scaling transform: Min-Max for bounded range, Z-score for Gaussian-assuming algorithms | deterministic |
| TRN5 | Register feature tables as governed Feature Views (entity-keyed) to serve both offline training and online inference | deterministic |
| TRN6 | Choose aggregation granularity deliberately — too coarse loses predictive signal, too fine overfits | semi-deterministic |

---

## Rules

### TRN1: dbt as Train-Serve Skew Defense

Train-serve skew occurs when the transformation logic preparing offline training data differs from the logic applied to real-time inference payloads. The result is **silent model degradation**: invalid predictions in production despite high offline validation accuracy.

**Rule**: serve every feature transformation from a single version-controlled source — **dbt** — that compiles and executes models directly within the analytical storage engine, so identical mathematical logic is applied to both the historical batch training table and the low-latency feature table.

**determinismLevel**: deterministic — single-source-of-truth is mandatory, not optional.
> Source: findings.md "Mitigation of Train-Serve Skew" — dbt as a single version-controlled repository feeding both offline training and real-time serving [8].

### TRN2: DuckDB for Medium-Scale, Not Spark

Do not default to a distributed Spark cluster for medium-scale transforms. **DuckDB** is an in-process, serverless analytical (OLAP) database that:

- Uses **vectorized execution**, processing columnar data blocks in CPU cache cycles (unlike row-wise transactional engines).
- Operates within the host process, eliminating network serialization latency.
- Queries millions of rows in local Parquet/CSV/JSON directly from a Python runtime.

It can speed data pipelines **10x and more** versus heavier stacks, deferring or eliminating the need to scale to an expensive cloud warehouse.

**determinismLevel**: deterministic — for medium-scale local data, DuckDB is the correct engine choice.
> Source: findings.md "DuckDB acts as an in-process, serverless analytical database... vectorized execution" [13, 14, 16] and "Speed Up Your Data Pipelines 10x and More" [14].

### TRN3: Polars LazyFrame with Pushdown over Pandas

**Polars** is a Rust DataFrame library built on the Apache Arrow memory spec, multi-threaded across all physical CPU cores by default. **Rule**: prefer Polars over Pandas for non-trivial transforms, and use the **`LazyFrame` API** so Polars compiles a logical execution plan and applies:

- **Predicate pushdown** — filter rows early.
- **Projection pushdown** — select only required columns.

This minimizes memory footprint and CPU overhead versus sequential in-memory execution.

**determinismLevel**: deterministic — lazy evaluation with pushdown is the recommended pattern.
> Source: findings.md "Polars is a high-performance DataFrame library written in Rust... lazy evaluation via the `LazyFrame` API... predicate pushdown... projection pushdown" [12, 13].

### TRN4: Pick the Correct Scaling Transform

When features exist at vastly different scales, many ML algorithms perform poorly. Choose the scaling method by algorithm assumption:

- **Min-Max scaling** maps features to a standardized range (typically 0 to 1):
  `x_scaled = (x − x_min) / (x_max − x_min)`
- **Z-score standardization** centers data around a zero mean with unit variance — highly effective for algorithms assuming a Gaussian distribution:
  `x_standardized = (x − μ) / σ`

Cleaning precedes scaling: isolate/correct errors, fill missing values, deduplicate, and apply outlier detection (statistical profiling to cap or remove extreme values that distort training).

**determinismLevel**: deterministic — the transform follows from the algorithm's distributional assumption.
> Source: findings.md "Normalization and Scaling" with Min-Max and Z-score formulas, plus "Data Cleaning" outlier handling [8].

### TRN5: Register Entity-Keyed Feature Views

As ML architectures mature, integrate dbt pipelines with a feature store (e.g., the Snowflake Feature Store via `snowflake-ml-python`). **Rule**: dbt orchestrates the transformation pipelines; the resulting feature tables are registered as **Feature Views** organized around logical **entity abstractions** (customer, product). This establishes a governed repository feeding both offline training runs and online low-latency inference — the same governed source on both sides closes the train-serve gap (TRN1).

**determinismLevel**: deterministic — entity-keyed Feature Views are the registration pattern.
> Source: findings.md "dbt pipelines are increasingly integrated with modern feature stores, such as the Snowflake Feature Store... registered directly as Feature Views... organized around logical entity abstractions" [8, 10, 11].

### TRN6: Choose Aggregation Granularity Deliberately

High-frequency transactional data (e.g., user clickstreams) must be condensed into structured summaries (e.g., customer-level rolling monthly purchase totals). **Rule**: choosing the level of granularity is crucial — too coarse loses valuable predictive signal; too fine invites overfitting. For feature generation, extract cyclical temporal attributes (hour-of-day) from timestamps, apply categorical encoding (one-hot or text embeddings), and compute interaction terms for non-linear relationships.

**determinismLevel**: semi-deterministic — the right granularity depends on the dataset and model.
> Source: findings.md "Aggregation" and "Feature Generation" [8, 9].

---

## Anti-Patterns

- **Two copies of feature logic** (notebook for training, service code for serving): the canonical train-serve skew failure (TRN1).
- **Spark by reflex** for data that fits a single machine: DuckDB/Polars eliminate cluster latency and cost (TRN2, TRN3).
- **Pandas for large transforms**: single-threaded, eager, no pushdown — Polars LazyFrame parallelizes for free (TRN3).
- **Min-Max on a Gaussian-assuming model**: mismatched scaling distorts convergence — match the transform to the assumption (TRN4).
- **Skipping outlier handling before scaling**: extreme values distort Min-Max ranges and model training (TRN4).
