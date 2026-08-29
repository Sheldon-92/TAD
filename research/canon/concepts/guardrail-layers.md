---
title: Guardrail Layers
what: Layered defense model for LLM output and tool safety
type: concept
citable: false
explores:
  - ai-guardrails
topics:
  - ai-guardrails
  - llm-observability
availability: open
verified_on: 2026-08-28
depth: cited
wiki_page: research/wiki/topics/guardrail-layers.md
raw_refs:
  - path: research/raw/papers/mcp-001.md
    locator: "p.5 / para 2"
    note: "shared paper reused for AC-I"
  - path: research/raw/articles/guardrail-001.md
    locator: "para 2"
    note: "layer taxonomy"
  - path: research/raw/github/guardrail-002.md
    locator: "timestamp 00:01:00"
    note: "open-source guardrail list"
provenance: "https://arxiv.org/abs/2402.00002"
---
Guardrails split into input, reasoning, output, and tool layers.
Each layer has distinct failure modes and verification hooks.
Layering prevents single-point bypass; failure must breach all four.
Composability requires per-layer locator traceability for audit.
