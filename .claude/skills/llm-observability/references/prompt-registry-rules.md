# Prompt Registry & Versioning Rules
<!-- capability: prompt_registry -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| PR1 | Decouple prompts from app code into a centralized registry | deterministic |
| PR2 | Pick version identity: sequential (MLflow) vs content-addressable hash (Braintrust) | deterministic |
| PR3 | Templates are immutable; model config (temperature/max_tokens) is mutable | deterministic |
| PR4 | Dual-TTL cache: versions = infinite TTL, aliases = 60-second TTL | deterministic |
| PR5 | Query stable aliases (@production) by URI, not pinned version numbers | deterministic |
| PR6 | Classify prompt changes SEMVER-style (major/minor/patch) before rollout | deterministic |

---

## Rules

### PR1: Decouple Prompts From Application Code

Managing prompts directly in application code ties minor template adjustments to full engineering deployments, slowing testing cycles and adding validation friction. A centralized prompt registry (MLflow, Braintrust, Traceloop) acts as a database that decouples prompt templates from client-side execution.

**Rule**: Hardcoded prompts are an anti-pattern at production scale. Move templates into a registry so non-technical stakeholders can iterate and changes don't require an app redeploy. Application code queries the registry by URI (see PR5).

> Source: findings.md "Managing prompts directly in application code introduces operational risks... Hardcoded prompts tie minor template adjustments to full engineering deployments" [21, 22, 23]

**determinismLevel**: deterministic — an architectural decision.

### PR2: Version Identity — Sequential vs Content-Addressable

Two production paradigms for version identification:

| Paradigm | Example | Form | Property |
|----------|---------|------|----------|
| **A: Sequential numbering** | MLflow | `v1 → v2 → v3` | Human-readable ordering |
| **B: Content-addressable hashing** | Braintrust | `5878bd218351fb8e` (hash of template text) | Identical content → identical ID; guarantees reproducibility, prevents duplicate records |

**Rule**: Content-addressable IDs are a direct hash of the prompt text, so identical content always yields the same ID — preventing duplicate records and keeping historical traces fully reproducible. Choose Paradigm B when reproducibility/dedup matters most; choose Paradigm A (MLflow) when human-readable ordering and an existing MLflow stack matter.

> Source: findings.md "MLflow uses sequential numbering (v1, v2, v3), while Braintrust generates content-addressable cryptographic IDs (e.g., 5878bd218351fb8e) derived directly from the template content... identical content always yields the same ID" [22, 23]

**determinismLevel**: deterministic — a design choice.

### PR3: Immutable Templates, Mutable Configs

In MLflow's registry, template texts are **strictly immutable** — a change requires registering a NEW version (`mlflow.genai.register_prompt`). But the model configurations attached to a version (`model_name`, `temperature`, `max_tokens`) are **mutable** — adjust them with `mlflow.genai.set_prompt_model_config` WITHOUT incrementing the template version.

- Tag versions with metadata: `mlflow.genai.set_prompt_version_tag`
- Deletion safeguard: `MlflowClient().delete_prompt_version` only allows deleting **one version at a time** to prevent accidental data loss.

**Rule**: Never mutate an existing template in place — register a new version so historical traces stay reproducible. Tuning temperature/max_tokens is config, not a template change, so it does not need a new template version.

> Source: findings.md "Template texts are strictly immutable... developers register a new version... mlflow.genai.register_prompt. However, the model configurations... are mutable... mlflow.genai.set_prompt_model_config... delete_prompt_version only allow deleting one version at a time" [22, 23]

**determinismLevel**: deterministic — a registry contract.

### PR4: Dual-TTL Caching Policy

To avoid per-request registry lookups under high throughput, MLflow uses a **dual-TTL** caching policy:

| Prompt reference type | TTL | Why |
|-----------------------|-----|-----|
| **Version-based** (e.g. `v12`) | **Infinite TTL** | Immutable — content can never change |
| **Alias-based** (e.g. `@production`) | **60-second TTL** | Aliases can be promoted to new versions; bounds propagation delay |

**Rule**: Cache immutable versions forever, but cache aliases for only 60 seconds. A single uniform TTL is wrong: caching aliases too long delays rollout propagation; expiring versions wastes lookups on immutable content.

> Source: findings.md "Version-Based Prompts: Because these are immutable, they are cached with an infinite TTL. Alias-Based Prompts: ... cached with a 60-second TTL to balance performance and propagation delay" [23]

**determinismLevel**: deterministic — fixed caching policy.

### PR5: Query Stable Aliases, Not Pinned Versions

For environment staging, assign mutable references (aliases) like `@staging` or `@production`. Application code queries the stable alias by URI while background pipelines update the underlying version:

```
URI Target = "prompts:/qa-assistant/production"
```

**Rule**: Application code should target `prompts:/<name>/production`, NOT `prompts:/<name>/v12`. Pinning a version number in app code reintroduces the redeploy-to-change coupling that PR1 removed. Promote by repointing the alias; the 60-second alias TTL (PR4) propagates it.

> Source: findings.md "versions are assigned mutable references (aliases) like @staging or @production... URI Target = 'prompts:/qa-assistant/production'" [23]

**determinismLevel**: deterministic — a query-pattern rule.

### PR6: SEMVER Change Classification Before Rollout

Before rolling out a prompt change, classify its magnitude SEMVER-style to size the validation/rollout effort:

| Class | Example | Meaning |
|-------|---------|---------|
| **Major (v1.0.0)** | System prompt changes role: legal assistant → creative writer | Complete structure shift |
| **Minor (v1.1.0)** | Adding new rules/constraints, core task unchanged | Additive behavior change |
| **Patch (v1.0.1)** | Fixing typos / formatting, no instruction change | No execution-logic change |

Then run staged rollout: promoted version → run against benchmark datasets → A/B split (e.g. route 10% to new, 90% to control `qa-assistant@v12`) before full rollout. Traceloop supports distinct environment labels (development / staging / production) for progressive rollouts.

**Rule**: A major prompt change MUST go through benchmark validation + canary A/B before full production; a patch may skip A/B. Treating all prompt edits as equal either over-tests typos or under-tests role changes.

> Source: findings.md "Major Changes (v1.0.0): Complete structure shifts... Minor Changes (v1.1.0): Adding new rules... Patch Changes (v1.0.1): Correcting typos... Route 10% → A/B Test ... Route 90% → Control A: qa-assistant@v12" [21, 23, 24, 25]

**determinismLevel**: deterministic — a classification + rollout policy.

---

## Anti-Patterns

- **Hardcoded prompts in app code**: Couples every template tweak to a full redeploy.
- **Mutating templates in place**: Breaks reproducibility of historical traces — register a new version instead.
- **Pinning version numbers in app code**: Reintroduces redeploy coupling; query the `@production` alias instead.
- **Uniform cache TTL**: Caching aliases too long delays rollouts; expiring immutable versions wastes lookups.
- **Treating all prompt edits equally**: A role-changing major edit needs benchmark + canary; a typo patch does not.
