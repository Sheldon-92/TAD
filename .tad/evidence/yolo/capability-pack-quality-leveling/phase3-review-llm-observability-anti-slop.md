# Phase 3 Review — llm-observability — Anti-Slop Lens

- **Lens**: anti-slop (Layer B depth: are "specifics" research-grounded numbers/thresholds an LLM could NOT emit from training, or generic rules dressed up?)
- **Reviewer**: subagent (Opus 4.8)
- **Date**: 2026-06-13
- **meets_bar**: TRUE

---

## Verdict

The pack genuinely clears the anti-slop bar. specN = 69 → Layer B bucket 5 (≥60→5).
The large majority of "specifics" are load-bearing, non-restatable numbers tied to a named
source with a retrieval date, and three independently fact-checked numbers (STS 600 RPS, two
OTel `ExplicitBucketBoundaries` arrays, Datadog v1.37 floor) all verified correct against live
primary docs. The discriminative fixture is properly anti-slop hardened — it documents a real
negative-control false-PASS (no-pack engineer scored 4/4 on commodity markers) and deliberately
strips commodity markers (raw counter / TTFT / HTTP 429) out of the `discriminative_pattern`,
keeping only pack-unique mechanisms. This is exactly the discipline the QUALITY-BAR §4 demands.

A handful of rules are weaker (restatable or borderline-commodity) and a couple of numbers are
presented as harder than they are, but none are dressed-up-generic masquerading as depth, and
all are explicitly flagged as dated/verify-live. Findings below are improvement notes, not bar
failures.

---

## Findings

### Genuinely research-grounded specifics (NOT LLM-emittable from training)

- **OTel `ExplicitBucketBoundaries` arrays (OT5)** — the strongest depth signal in the pack. The exact
  14-element token-usage array `[1,4,16,...,67108864]` and the power-of-two duration array
  `[0.01,...,81.92]` are spec-defined advisory buckets no LLM reproduces from memory. FACT-CHECKED:
  both match the OTel GenAI semconv repo byte-for-byte. The accompanying insight (duration = power-of-two,
  TTFT/ITL = finer sub-second because first-token latency lives in tens-of-ms) is real engineering
  reasoning, not filler.
- **STS 600 RPS shared quota + 1-hour AssumeRole cache TTL (CA7)** — FACT-CHECKED correct against AWS
  IAM/STS quota docs (600 req/s/account/Region, shared across STS APIs). The pack also self-documents a
  source correction (findings.md said 500/sec; corrected to 600) — that's the opposite of slop.
- **`OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental` + ≥ v1.37 floor (OT1)** — the env-var value
  and the v1.37 floor (tied to Datadog's "v1.37 and up" Dec-2025 support) are precise, sourced, and
  FACT-CHECKED. An LLM would not reliably produce the exact opt-in token nor the version floor.
- **`OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` as a separate PII gate (OT4)** — naming the
  *distinct* second env var (separate from OT1) and the events→span-attributes migration is genuine
  freshness knowledge, not commodity "be careful with PII."
- **z-score runaway kill switch: z>4 over 7-day window, 10-min rolling spend (CA6)** — concrete formula
  + threshold + window + the action contract (pause first, don't alert-only). Not restatable.
- **MLflow dual-TTL cache: versions = infinite TTL, aliases = 60-second TTL (PR4)** — specific, sourced,
  with the *why* (alias promotion propagation bound). The MLflow URI alias-vs-slash distinction (PR5)
  is also corrected from a wrong source form (`/production` slash → `@production`), again anti-slop.
- **Wasserstein-on-PCA(95% var) NOT KS-test for embedding drift (OE3)** — names the specific wrong tool
  (univariate KS blind to multivariate shift) and the specific right method. Pack-unique.
- **vLLM `pip install vllm[otel]`, scrape `/metrics` every 15s, prefill/decode split spans, time-in-queue
  as leading indicator (LP3/LP4/LP5)** — concrete commands, intervals, and named metrics
  (`gen_ai.latency.time_in_model_prefill/decode`, `vllm:time_per_output_token_seconds`).

### Weaker rules (restatable / borderline-commodity) — flagged, not bar-failing

- **F1 — CA2 output:input multiplier table is the softest "number" claim.** The 2x–6x band and the
  per-model $/1M figures (GPT-5.4 $2.50/$15, Claude Opus $5/$25, etc.) are (a) for unreleased/future model
  names and (b) explicitly labeled "dated anchors that will rot — compute from live pricing." This is
  honest, but the *rule itself* ("output tokens cost more than input; reduce output first") IS restatable
  by a frontier LLM with no research. The depth here is the instruction to compute the exact multiplier
  live, not the numbers — so the numbers are illustrative, not load-bearing. Acceptable because clearly
  marked, but it is the closest thing to "generic rule with numbers bolted on."
- **F2 — TR3 (reconstruct parent-child span tree, not flat logs) and PR1 (decouple prompts from code)**
  are essentially commodity LLMOps principles a senior engineer states unprompted. They carry no
  research-derived threshold. They earn their place as scaffolding/context, not as depth, and the pack's
  own fixture correctly classifies this whole family (raw-counter / TTFT / HTTP 429) as commodity and
  excludes them from the discriminative gate.
- **F3 — OE2 groundedness = supported/total claims (0.0–1.0)** is a real RAG-eval formula but is by now
  widely enough known to be near-restatable; the genuine depth is "enumerate claims, set explicit
  threshold, not binary" rather than the ratio itself.

### Unsourced / weakly-sourced numbers

- **F4 — CA5 margin caps `[1.5,3.0]× contracted` and `[2.0,3.0]× expected peak`** trace only to
  "findings.md [10]" with no external URL. These ranges read plausible but are the least independently
  verifiable numbers in the pack (no primary source, no retrieval date — unlike CA7/OT1/OT5 which carry
  live URLs). Correctly tagged `semi-deterministic` (tunable range), which softens the risk, but per
  QUALITY-BAR §5 / principles "Research evidence lacks auditability," these should get a real source URL.
- **F5 — LP3 "scrape /metrics every 15 seconds" and PR4 "60-second TTL"** are sourced only to findings.md.
  They are specific and plausible (15s is a conventional Prometheus scrape default) but the 15s figure in
  particular is a deployment convention, not a hard vLLM requirement — presenting it as a fixed
  `determinismLevel: deterministic` rule slightly overstates its rigidity.
- **F6 — Tracing-platform pricing table (TR1/TR4: LangSmith $39/seat, Langfuse $29/$199, Helicone $79)**
  is explicitly dated/verify-live and sourced to SigNoz + Confident AI roundups (secondary aggregators,
  not vendor pages). Fine as dated anchors; would be stronger citing vendor pricing pages directly. Not a
  depth concern — pricing is inherently rot-prone and labeled as such.

### Structural anti-slop strengths

- The fixture (`examples/llm-observability-fixture.md`) is a model of anti-slop discipline: it splits a
  COMMODITY marker set (kept human-facing only) from a DISCRIMINATIVE set (pack-unique mechanisms only),
  documents the real false-PASS that motivated the split (no-pack control scored 4/4 commodity → false
  PASS), and ships an executable negative-control proof expecting 0 hits. `min_discriminative: 3` against
  a pattern of pack-unique tokens. This is precisely QUALITY-BAR §3/§4 + the 2026-05-31 "separate
  discriminative field" principle, applied correctly.
- Cross-cutting rule (emit raw counters, never pre-multiplied cost) is surfaced in SKILL body, not buried —
  matches the cross-cutting-rule placement convention.
- `determinismLevel` annotations correctly separate fixed schema facts from tunable ranges from
  live-distribution signals — this is the kind of operationalization QUALITY-BAR B3 rewards.

---

## fact_checks

- **OTel `gen_ai.client.token.usage` bucket array** `[1,4,16,64,256,1024,4096,16384,65536,262144,1048576,4194304,16777216,67108864]` — VERIFIED exact match against OpenTelemetry semantic-conventions-genai repo (gen-ai-metrics.md). Instrument = Histogram CONFIRMED.
- **OTel `gen_ai.client.operation.duration` bucket array** `[0.01,0.02,0.04,0.08,0.16,0.32,0.64,1.28,2.56,5.12,10.24,20.48,40.96,81.92]` — VERIFIED exact match. (TTFT / time_per_output_token arrays not present in fetched excerpt; not falsified, and the two verifiable arrays match byte-for-byte, corroborating the source.)
- **AWS STS 600 req/s/account/Region, shared across STS APIs (AssumeRole counts toward it)** — VERIFIED against AWS IAM/STS quotas docs via search. Pack's self-correction (500→600) is the accurate value.
- **Datadog LLM Observability supports OTel GenAI semconv "v1.37 and up" (Dec 2025)** — VERIFIED via Datadog blog (datadoghq.com/blog/llm-otel-semantic-convention). The v1.37 version floor (OT1) is correctly sourced.
- **specN recompute** — 69 unique specific-threshold matches over SKILL.md + references/ (QUALITY-BAR §2.3 alternation) → Layer B bucket 5 (≥60→5). Consistent with claimed depth.
- **CA5 margin caps `[1.5,3.0]×` / `[2.0,3.0]×`** — NOT independently verifiable (findings.md-only, no external URL). Flagged F4; tagged semi-deterministic so risk is bounded.
- **CA2 model pricing table** — NOT verified against live pricing; explicitly self-labeled as dated anchors to recompute live. Honest, not slop, but illustrative rather than load-bearing.
