# Data Quality Rules: Great Expectations, Soda Core, AI-Driven Validation
<!-- capability: data_quality -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| DQ1 | Gate raw ingestion with a quality engine — unvalidated data degrades models AND introduces security vulnerabilities | deterministic |
| DQ2 | Choose by author: Great Expectations 1.18.1 (code-first Python) vs Soda Core 4.7.0 (declarative SodaCL YAML for non-engineers) | deterministic |
| DQ3 | Use Soda Core 4.x Data Contracts to halt and isolate anomalies before schema drift breaks downstream ML | deterministic |
| DQ4 | Rules-based engines are blind to unstructured data, label corruption, and concept drift — pair with AI-driven diagnostics | deterministic |
| DQ5 | Adopt the dual-defense pattern: rules-based format gate (GX/Soda) + AI-driven dataset/label/drift diagnostics | deterministic |
| DQ6 | Use Soda Core built-in statistical anomaly detection for volumetric spikes/drops without manual thresholds | semi-deterministic |

---

## Rules

### DQ1: Gate Ingestion — Unvalidated Data Is a Security Risk

Unvalidated data ingested into downstream AI applications degrades model performance **and introduces security vulnerabilities**. **Rule**: strict data quality is a hard requirement in production — place a validation gate between raw ingestion and any downstream AI consumer. Do not let raw data reach a model unvalidated.

**determinismLevel**: deterministic — a quality gate is mandatory.
> Source: findings.md "Unvalidated data ingested into downstream AI applications degrades model performance and introduces security vulnerabilities" [23, 24, 25, 26].

### DQ2: Choose Engine by Author Persona

Match the validation engine to who writes and maintains the checks:

| Engine | Version (verified 2026-06-13) | Interface | Best Author / Deployment |
|---|---|---|---|
| Great Expectations (GX Core) | **1.18.1** (released **2026-06-11**; Python **3.10–3.13**; Apache-2.0) | Code-first **Python Fluent API** (GX 1.x is Python-first; YAML still backs persistent File Data Contexts via `great_expectations.yml`) | Engineers; source-ingestion gating + MLOps preprocessing |
| Soda Core | **4.7.0** (released **2026-04-17**) | Declarative **SodaCL** (human-readable YAML) | Non-engineering stakeholders (PMs, risk analysts); continuous monitoring |

GX compiles validation results into visual, interactive HTML reports — **Data Docs** — a self-updating, auditable data dictionary hostable on cloud storage to meet compliance requirements. Trade-off: GX has high development/maintenance overhead and can degrade performance on broad expectation checks over large Spark datasets. (Pin these exact versions in your lock file; the prior "v1.0 GA" / "v4" anchors are stale.)

**determinismLevel**: deterministic — author persona selects the engine.
> Source: PyPI great-expectations 1.18.1 (2026-06-11, Py 3.10–3.13, Apache-2.0) — https://pypi.org/project/great-expectations/ (retrieved 2026-06-13); PyPI soda-core 4.7.0 (2026-04-17) — https://pypi.org/project/soda-core/ (retrieved 2026-06-13). GX 1.x retains YAML for persistent File Data Contexts — https://docs.greatexpectations.io/docs/core/set_up_a_gx_environment/create_a_data_context/ (retrieved 2026-06-13). Originally findings.md [24, 25, 26].

### DQ3: Soda v4 Data Contracts Halt Drift at the Boundary

Soda Core 4.x (current **4.7.0**, 2026-04-17)'s key advancement is **Data Contracts as a first-class feature**: upstream providers and downstream consumers formalize data schemas and quality metrics as a programmatic agreement. **Rule**: when ML systems break on schema drift, install a data contract so the pipeline **halts and isolates anomalies before** the drift reaches downstream consumers — rather than discovering it from degraded model output.

**determinismLevel**: deterministic.
> Source: findings.md "The platform's key evolutionary advancement in version 4 is the integration of Data Contracts as a first-class feature... pipelines halt and isolate anomalies before schema drift breaks downstream ML systems" [23, 24].

### DQ4: Know the Blind Spots of Rules-Based Engines

GX and Soda excel at schema structure, null ratios, and value-range checks on **structured** data — but for AI preparation they have hard limits:

- **Unstructured-data blind spots**: cannot analyze imagery, audio, or spatial point clouds; cannot detect visual artifacts, audio noise, or spatial distortions.
- **No class-imbalance / label diagnosis**: mathematically incapable of detecting label corruption (mislabeled classes) or downstream class-distribution imbalance that injects bias.
- **Weak post-serving drift detection**: struggle with gradual concept drift where inputs stay structurally correct but the statistical distribution shifts, invalidating predictions over time.

**Rule**: do not claim "GX checks everything." These three gaps require a different tool class.

**determinismLevel**: deterministic — the limitations are intrinsic to rules-based engines.
> Source: findings.md "The Limitations of Rules-Based Quality Monitoring" [23, 24].

### DQ5: Dual-Defense Quality Pattern

**Rule**: combine two layers — a rules-based **format gate** (GX or Soda) as the baseline, plus specialized **AI-driven diagnostics** (e.g., DataClinic) to assess dataset quality, verify label health, evaluate training fitness, and detect concept/covariate drift and label corruption. Rules-based alone is insufficient for AI; AI-driven alone skips cheap structural checks. Use both.

| Layer | Tool Class | Covers |
|---|---|---|
| Format gate | Great Expectations / Soda Core | schema, nulls, value ranges (structured) |
| AI-driven diagnostics | ML model-driven (e.g., DataClinic) | imagery/audio/point clouds, label corruption, class imbalance, concept/covariate drift |

**determinismLevel**: deterministic — the dual-defense architecture is the recommended pattern.
> Source: findings.md "modern data architectures employ a dual-defense quality pattern, combining rules-based validation (GX or Soda)... with specialized AI-driven diagnostics (such as DataClinic)" [24].

### DQ6: Soda Built-in Statistical Anomaly Detection

Soda Core features **built-in statistical anomaly detection** that automatically identifies volumetric spikes or drops **without requiring manual thresholds**. **Rule**: for volume monitoring, prefer Soda's automatic anomaly detection over hand-set thresholds that go stale.

**determinismLevel**: semi-deterministic — anomaly flags depend on the incoming data distribution.
> Source: findings.md "Soda Core features built-in statistical anomaly detection, allowing it to automatically identify volumetric spikes or drops without requiring manual thresholds" [25].

---

## Anti-Patterns

- **"GX checks everything"**: it cannot see unstructured data, label corruption, class imbalance, or concept drift (DQ4).
- **No data contract**: schema drift reaches the model silently; v4 contracts halt it at the boundary (DQ3).
- **Manual volume thresholds**: go stale; Soda's statistical anomaly detection adapts (DQ6).
- **Single-layer quality**: rules-based OR AI-driven alone is insufficient — use the dual-defense pattern (DQ5).
- **Choosing GX for non-engineer authors**: SodaCL's declarative YAML lets PMs/risk analysts maintain checks (DQ2).

---

## Sources (URL + retrieval date)

| Ref | Source | URL | Retrieved |
|-----|--------|-----|-----------|
| DQ2 | PyPI — great-expectations 1.18.1 (2026-06-11, Py 3.10–3.13) | https://pypi.org/project/great-expectations/ | 2026-06-13 |
| DQ2/DQ3 | PyPI — soda-core 4.7.0 (2026-04-17) | https://pypi.org/project/soda-core/ | 2026-06-13 |
| DQ2 | GX — File Data Context (YAML persistence) | https://docs.greatexpectations.io/docs/core/set_up_a_gx_environment/create_a_data_context/ | 2026-06-13 |
