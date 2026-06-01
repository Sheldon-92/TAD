# Dimensional Modeling Rules: Star Schema and Slowly Changing Dimensions
<!-- capability: dimensional_modeling -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| DIM1 | Assign the SCD type by attribute behavior — Type 0/1/2/3/4/6, not a blanket choice | deterministic |
| DIM2 | Use SCD Type 2 for AI: row-history with valid_from/valid_to/is_current enables time-travel training context | deterministic |
| DIM3 | Never use SCD Type 1 (overwrite) when historical state is needed — it permanently deletes context | deterministic |
| DIM4 | Always filter SCD Type 2 queries with `is_current = true` or a table-bloat full scan results | deterministic |
| DIM5 | Make surrogate-key generation idempotent — retries/duplicate loads cause key collisions otherwise | semi-deterministic |
| DIM6 | Handle late-arriving records with bitemporal modeling (valid time + transaction time) | semi-deterministic |

---

## Rules

### DIM1: Assign SCD Type by Attribute Behavior

Kimball dimensional modeling organizes data into central **fact tables** (quantitative, event metrics) connected to denormalized **dimension tables** (descriptive attributes). Managing attribute updates over time requires choosing a Slowly Changing Dimension type **per attribute**:

| SCD Type | Behavior | Use When |
|---|---|---|
| Type 0 | Fixed — never updated after creation | Constant attributes (e.g., product launch date) |
| Type 1 | Overwrite old value | Space-efficient; history NOT needed |
| Type 2 | Row history — new row per change (surrogate key, business key, `valid_from`/`valid_to`/`is_current`) | History/time-travel needed (the AI default) |
| Type 3 | Column history — append columns (`current_city`, `previous_city`) | Shallow, fixed-depth history only |
| Type 4 | Mini-dimension — split frequently-changing attrs into a separate low-cardinality table | Prevent main-dimension bloat |
| Type 6 | Hybrid — combines Type 1 + 2 + 3 in one structure | Need both overwrite and row history |

**determinismLevel**: deterministic — attribute behavior dictates the type.
> Source: findings.md "Slowly Changing Dimensions (SCDs)" Type 0/1/2/3/4/6 definitions [30, 31, 32, 33].

### DIM2: SCD Type 2 Is the AI Default (Time-Travel Context)

**Rule**: for AI architectures, prefer SCD **Type 2**. Every update inserts a new row with a unique surrogate key, the natural business key, and metadata fields (`valid_from`, `valid_to`, `is_current`). This is critical because it enables **"time travel" queries that reproduce the precise attribute context that existed when a historical event occurred** — exactly what training on historical state requires.

In document stores (MongoDB), the same pattern uses per-document `validFrom`/`validTo`/`isValid`, wrapping invalidation of the old document and insertion of the new in a transaction for atomic consistency.

**determinismLevel**: deterministic — Type 2 is the recommended pattern for historical AI context.
> Source: findings.md "SCD Type 2: Row history... enables 'time travel' queries" [30, 32, 34] and MongoDB per-document `validFrom`/`validTo`/`isValid` example [30].

### DIM3: Never Use Type 1 When History Matters

SCD **Type 1** overwrites old values directly with updated attributes. While space-efficient, this **permanently deletes historical context**, making it impossible to perform retrospective analysis or train models on historical states. **Rule**: do not assign Type 1 to any attribute whose past values could matter to a model or audit. Type 3 is also schema-fragile and cannot track deep histories — use it only for fixed shallow history.

**determinismLevel**: deterministic.
> Source: findings.md "SCD Type 1: Overwrite... permanently deletes historical context" and "SCD Type 3... schema-fragile and cannot track deep histories" [31, 32, 33].

### DIM4: Always Filter Type 2 Queries with `is_current = true`

SCD Type 2 tables grow continuously. The concrete failure: a customer dimension of **10 million** distinct records with **three updates per entity annually** adds **30 million** new rows each year. Over **five years**, only **10 million** of **150 million** total records remain active. **Rule**: any analytical query that omits a strict `is_current = true` filter is forced to scan the entire 150-million-row dataset, causing severe performance degradation. Always filter to current rows unless you explicitly need history.

**determinismLevel**: deterministic — the filter is mandatory for current-state queries.
> Source: findings.md "Table Bloat" — the 10M / 30M-per-year / 150M-over-5-years example and the `is_current = true` filter requirement [33].

### DIM5: Make Surrogate-Key Generation Idempotent

During high-frequency batch executions, duplicate load runs or task retries **write duplicate surrogate keys if generation logic is not fully idempotent** — surrogate-key collisions. **Rule**: design surrogate-key generation to be idempotent so a retried or duplicated load does not create colliding keys.

**determinismLevel**: semi-deterministic — collisions depend on retry/duplicate-load timing.
> Source: findings.md "Surrogate Key Collisions: During high-frequency batch executions, duplicate load runs or task retries can write duplicate surrogate keys if generation logic is not designed to be fully idempotent" [33].

### DIM6: Bitemporal Modeling for Late-Arriving Records

Standard SCD pipelines assume sequential, chronological ingestion. **Late-arriving transaction logs bypass active row boundaries, corrupting the validity of historical windows.** **Rule**: to resolve this, implement **bitemporal modeling** — track both **valid time** (when the event actually occurred) and **transaction time** (when the record was loaded), alongside a metadata-driven control framework.

**determinismLevel**: semi-deterministic — late arrivals are data-dependent.
> Source: findings.md "Late-Arriving Records... teams implement bitemporal modeling, tracking both valid time... and transaction time" [33].

---

## Anti-Patterns

- **One SCD type for the whole dimension**: type is per-attribute behavior, not a table-wide flag (DIM1).
- **Type 1 on history-relevant attributes**: silently destroys the context models and audits need (DIM3).
- **Type 2 queries without `is_current = true`**: full-table scans of an ever-growing bloated dimension (DIM4).
- **Non-idempotent surrogate keys**: retries and duplicate loads create key collisions (DIM5).
- **Assuming chronological ingestion**: late-arriving records corrupt validity windows without bitemporal modeling (DIM6).
