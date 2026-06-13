# Orchestration Rules: Airflow, Dagster, Prefect
<!-- capability: orchestration -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| ORC1 | Match the orchestrator to the workload: Airflow=multi-team batch, Dagster=asset/dbt-heavy, Prefect=agentic/dynamic | deterministic |
| ORC2 | Do not default to Airflow — its split-component footprint demands dedicated platform engineering | deterministic |
| ORC3 | For asset/lineage-centric pipelines use Dagster software-defined assets (native column-level lineage) | deterministic |
| ORC4 | For agentic workflows with unknown execution paths use Prefect decorators (`@flow`/`@task`/`@materialize`) | deterministic |
| ORC5 | Prefer asset-aware orchestration (Airflow 3 assets, Dagster assets, Prefect `@materialize`) over pure task-scheduling | deterministic |

---

## Rules

### ORC1: Match Orchestrator to Workload

When selecting a Python orchestrator, choose by best-fit AI workload — do not pick by familiarity:

| Orchestrator | Version | Primary Philosophy | Infra Overhead | Best-Fit AI Workload |
|---|---|---|---|---|
| Apache Airflow | v3.x (3.2.2 docs; GA Apr 2025) | Task-centric + asset-aware + event-driven scheduling | **High** (web server, scheduler, metadata DB, workers, API server, DAG processor) | Massive, multi-team batch retraining; streaming-triggered AI pipelines (event-driven scheduling) |
| Dagster | v1.13 | Asset-centric; software-defined assets as first-class citizens | **Medium** (code locations + daemon instances) | Complex dbt-heavy transforms + asset tracking |
| Prefect | v3.7 | Dynamic, developer-first Python decorators | **Low** (dynamic runtime workers + simplified Postgres) | Flexible agentic workflows, dynamic low-latency API interactions |

**determinismLevel**: deterministic — given the workload profile, the orchestrator choice follows.
> Source: findings.md "Orchestration in the Age of Intelligent Agents" comparison table [18, 19]; Airflow 3 versions/capabilities https://www.astronomer.io/blog/introducing-apache-airflow-3-1/ (retrieved 2026-06-13).

### ORC2: Don't Default to Airflow

**Airflow 3.x** (3.2.2 docs; GA **April 2025**; **80,000+ orgs**, **30M+ monthly downloads**) added **DAG versioning**, **event-driven scheduling** (assets can trigger DAGs from external events — relevant to streaming-triggered AI pipelines), **DAG bundles** (git / local / external source backends), **human-in-the-loop** operators, a **React UI**, plus a **Common AI Provider** with native LLM operators and integrations with 20+ foundational model providers.

But its **split-component architecture** (web server, scheduler, metadata database, workers, dedicated API server, DAG processor) carries a heavy operational footprint, frequently requiring dedicated platform engineering resources to scale and maintain. **Rule**: reserve Airflow for massive multi-team batch pipelines (or event-driven streaming triggers) where that footprint is justified — do not impose it on a lightweight or dynamic single-team workflow; the version anchor moved (3.2.2 docs), but the "don't default to Airflow" rule stands.

**determinismLevel**: deterministic.
> Source: Astronomer — Apache Airflow 3 (DAG versioning, event-driven scheduling, DAG bundles, HITL, React UI; 80,000+ orgs / 30M+ monthly downloads; GA April 2025) — https://www.astronomer.io/blog/introducing-apache-airflow-3-1/ and https://www.astronomer.io/blog/apache-airflow-3-2-release/ (retrieved 2026-06-13). Originally findings.md [19, 20, 21].

### ORC3: Dagster Software-Defined Assets for Lineage

Dagster models the actual data products (a database table, an ML model, a vector store) as first-class, stateful **software-defined assets** rather than abstract execution steps. This provides **native, out-of-the-box column-level data lineage**, automatic metadata cataloging, and partitioned execution tracking.

v1.13 introduced **Components and the `dg` CLI**, reducing bootstrap boilerplate. For AI engineering, autonomous agents can read the live asset graph and execute targeted backfills; Dagster also ships **Compass** (a Slack-native AI assistant for troubleshooting failed pipelines) and integrates with Claude Code. **Rule**: choose Dagster for dbt-heavy, lineage-critical pipelines.

**determinismLevel**: deterministic.
> Source: findings.md "Dagster (Version 1.13)" — software-defined assets, native column-level lineage, Components + `dg` CLI, Compass [18, 19, 20, 21, 22].

### ORC4: Prefect Decorators for Agentic, Dynamic Workflows

Prefect is a lightweight, developer-first platform that eliminates rigid DAG declarations — engineers write standard dynamic Python using simple decorators (`@flow`, `@task`) to declare dependencies on the fly. **Rule**: choose Prefect when the execution path cannot be known in advance and must adapt to LLM outputs, user prompts, or shifting external APIs — i.e., agentic workflows.

Prefect 3.7 added the **`@materialize` asset layer** with built-in asset checks and lineage tracking, closing the gap with asset-centric orchestrators while keeping its flexible dynamic runtime.

**determinismLevel**: deterministic — the dynamic-path requirement selects Prefect.
> Source: findings.md "Prefect (Version 3.7)" — decorator-based, `@materialize` asset layer, ideal for agentic workflows [18, 19, 21].

### ORC5: Prefer Asset-Aware over Pure Task-Scheduling

Orchestration has evolved from simple cron-scheduling to managing complex dependencies across AI, ELT, and streaming. All three orchestrators now expose an asset/lineage layer (Airflow 3 asset-aware scheduling + OpenLineage provider; Dagster native assets; Prefect `@materialize`). **Rule**: model pipelines around the data assets they produce, not just abstract execution steps — this is what gives agents a live asset graph to reason over and backfill.

**determinismLevel**: deterministic.
> Source: findings.md "Data orchestration has evolved from a simple cron-scheduling model to a core operational layer" and the lineage-tracking row of the comparison table [18, 19].

---

## Anti-Patterns

- **Airflow by default**: its heavy split-component footprint is overkill for dynamic or single-team workloads (ORC2).
- **Pure task-scheduling for AI pipelines**: without asset awareness you lose lineage, cataloging, and the agent-readable asset graph (ORC5).
- **Rigid DAGs for agentic paths**: when the execution path adapts to LLM output, Prefect's dynamic decorators fit; a static DAG cannot (ORC4).
- **Ignoring lineage**: for dbt-heavy work, Dagster's native column-level lineage is the differentiator (ORC3).
- **Hand-rolling a cron poller for streaming triggers**: Airflow 3.x event-driven scheduling lets assets trigger DAGs from external events natively (ORC2).

---

## Sources (URL + retrieval date)

| Ref | Source | URL | Retrieved |
|-----|--------|-----|-----------|
| ORC1/ORC2 | Astronomer — Introducing Apache Airflow 3 | https://www.astronomer.io/blog/introducing-apache-airflow-3-1/ | 2026-06-13 |
| ORC1/ORC2 | Astronomer — Apache Airflow 3.2 release | https://www.astronomer.io/blog/apache-airflow-3-2-release/ | 2026-06-13 |
