# Latency & TTFT Profiling Rules
<!-- capability: latency_profiling -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| LP1 | For streaming, measure TTFT + ITL — NOT end-to-end latency | deterministic |
| LP2 | Profile across three layers: application (OTel), kernel (PyTorch), GPU (Nsight) | deterministic |
| LP3 | vLLM: OTel deps ship bundled (else install opentelemetry-sdk/api/exporter-otlp); scrape /metrics every 15 seconds | deterministic |
| LP4 | Separate prefill vs decode spans to isolate compute vs memory bottlenecks | deterministic |
| LP5 | Track time-in-queue as the early indicator of capacity limits | semi-deterministic |

---

## Rules

### LP1: TTFT + ITL, Not End-to-End, for Streaming

In interactive GenAI systems, overall end-to-end latency is a poor indicator of user experience. For streaming applications, responsiveness is determined by the speed of **initial** text delivery, not complete generation.

> A streaming session with 10-second end-to-end latency but **500ms TTFT feels instantaneous**, whereas a non-streaming session with 5-second latency and 4-second TTFT feels frozen.

The relevant metrics are **Time to First Token (TTFT)** and **Inter-Token Latency (ITL)**:

```
User Request
    ▼
[ Compute-Heavy Prefill Phase ] ──► Time to First Token (TTFT)
    ▼
[ Decode ] ──► Inter-Token Latency (ITL)
    ▼
Response Complete ──► End-to-End Latency
```

**Rule**: If an SLO is written against end-to-end latency for a streaming product, it is measuring the wrong thing. Set SLOs on TTFT (perceived responsiveness) and ITL (streaming smoothness). Capture TTFT via the `gen_ai.client.operation.time_to_first_chunk` histogram (client) / `gen_ai.server.time_to_first_token` (server); TTFT is a metric, not a span attribute.

> Source: findings.md "A streaming session with a 10-second end-to-end latency and a 500ms TTFT feels instantaneous, whereas a non-streaming session with a 5-second latency and a 4-second TTFT feels frozen... TTFT and Inter-Token Latency (ITL) critical metrics" [2, 18, 19, 20]

**determinismLevel**: deterministic — a metric-selection rule.

### LP2: Three-Layer Profiling Stack

Analyzing performance anomalies requires deep, multi-layered instrumentation. Each layer answers a different question:

| Layer | Tool | What It Captures |
|-------|------|------------------|
| **Application** | OpenTelemetry | Intercepts streaming chunk payloads to timestamp and compute rolling TTFT and ITL |
| **Kernel** | PyTorch Profiler | CUDA kernel launch overheads, operator execution times, tensor preparation steps |
| **Hardware / GPU** | NVIDIA Nsight Systems | GPU utilization, power draw, VRAM bandwidth; NVTX markers annotate core ops to isolate bottlenecks in multi-node tensor-parallel execution |

**Rule**: A latency regression visible at the application layer (rising TTFT) may originate at the kernel or GPU layer. Do not stop at OTel application metrics for self-hosted inference — drop to PyTorch Profiler for kernel overhead and Nsight Systems for GPU-level signals.

> Source: findings.md "High-Fidelity Profiling Layers... Application Layer: OpenTelemetry... Kernel Layer: PyTorch Profiler... Hardware & GPU Layer: NVIDIA Nsight Systems... NVTX markers" [2, 20]

**determinismLevel**: deterministic — tool-to-layer mapping is fixed.

### LP3: vLLM OpenTelemetry Wiring

To monitor a self-hosted vLLM engine, integrate OTel tracing with Prometheus metric scraping.

```bash
# OTel deps ship bundled with current vLLM; otherwise install them explicitly:
pip install opentelemetry-sdk opentelemetry-api opentelemetry-exporter-otlp
# start server with: --otlp-traces-endpoint <OTel-Collector>
```

The OTel Collector combines trace spans pushed via OTLP with metrics scraped from vLLM's `/metrics` endpoint **every 15 seconds**, then exports the unified stream to a backend (Dash0 / Parseable) over a single OTLP connection.

**Rule**: Rely on vLLM's bundled OTel support (or install `opentelemetry-sdk`/`opentelemetry-api`/`opentelemetry-exporter-otlp` explicitly — there is no `vllm[otel]` extra) rather than a hand-rolled exporter, and scrape `/metrics` on a 15-second interval. vLLM isolates scheduling/queuing/memory metrics in dedicated custom namespaces to bypass spec version conflicts — do not assume they land under the standard `gen_ai.*` namespace.

> Source: findings.md "...metrics scraped from vLLM's /metrics endpoint every 15 seconds" [4, 19]. NOTE: the findings cited a `pip install vllm[otel]` extra — corrected 2026-06-13, no such extra exists; OTel deps ship bundled with current vLLM, else install `opentelemetry-sdk`/`opentelemetry-api`/`opentelemetry-exporter-otlp` explicitly.

**determinismLevel**: deterministic — fixed install command + interval.

### LP4: Separate Prefill vs Decode Spans

To isolate compute bottlenecks from memory bottlenecks, vLLM records prefill and decode durations as **separate** spans, plus per-token inference metrics:

| Metric | Meaning |
|--------|---------|
| `gen_ai.latency.time_in_model_prefill` | Prefill (compute-heavy) duration |
| `gen_ai.latency.time_in_model_decode` | Decode (memory-bound) duration |
| `vllm:time_per_output_token_seconds` | Time-per-output-token histogram |
| `vllm:inter_token_latency_seconds` | Inter-token latency under concurrent load |

**Rule**: A single combined "inference time" span cannot tell you whether to add compute (prefill-bound) or KV-cache memory (decode-bound). Record prefill and decode separately. Rising `time_per_output_token` under load signals decode/memory pressure, not prefill compute.

> Source: findings.md "Spans record prefill duration (gen_ai.latency.time_in_model_prefill) and decode duration (gen_ai.latency.time_in_model_decode) separately to isolate compute bottlenecks from memory bottlenecks... vllm:time_per_output_token_seconds... vllm:inter_token_latency_seconds" [4]

**determinismLevel**: deterministic — fixed metric set.

### LP5: Time-in-Queue as Early Capacity Signal

vLLM tracks scheduling delay before execution begins via `gen_ai.latency.time_in_queue`. This serves as an **early indicator of capacity limits** — queue time rises before TTFT/throughput visibly degrade.

**Rule**: Alert on rising `time_in_queue` and KV-cache pressure *before* user-facing TTFT degrades. By the time TTFT regresses, you are already over capacity. Monitoring scheduling queue depth lets you scale or route traffic preemptively.

> Source: findings.md "Time in Queue (gen_ai.latency.time_in_queue): Tracks scheduling delays before execution begins, serving as an early indicator of capacity limits" [4]

**determinismLevel**: semi-deterministic — depends on live load.

---

## Anti-Patterns

- **End-to-end SLOs for streaming**: Measures total generation, not perceived responsiveness (TTFT) or smoothness (ITL).
- **Application-layer-only profiling**: Misses kernel (PyTorch Profiler) and GPU (Nsight) bottlenecks for self-hosted inference.
- **Hand-rolled vLLM exporters**: Rely on vLLM's bundled OTel support (or install `opentelemetry-sdk`/`opentelemetry-api`/`opentelemetry-exporter-otlp` — no `vllm[otel]` extra exists); scrape `/metrics` every 15s.
- **Combined inference span**: Cannot distinguish prefill-compute from decode-memory bottlenecks — split them.
- **Alerting only on TTFT**: By the time TTFT regresses you are already over capacity; alert on `time_in_queue` first.
