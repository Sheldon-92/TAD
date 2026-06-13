# Dogfood Judgment: AI Agent Architecture Task

Date: 2026-06-13
Task: Design a multi-agent system ingesting untrusted email + 3rd-party API data, long stateful sessions, >1K sessions/day.

## Verdict: Answer 1 wins, CLEAR margin (won on CORRECT specifics, not verbosity).

## WebSearch verification of key specifics

| Claim | Answer | Verdict |
|-------|--------|---------|
| Code-exec MCP 150K→2K tokens, 98.7% reduction | A1 | CORRECT (Anthropic eng blog; 112-tool prod replication confirmed) |
| CaMeL dual-LLM: privileged planner + quarantined parser w/ ZERO tools, consumes typed values not instructions | A1 (+A2 variant) | CORRECT (DeepMind CaMeL, arXiv 2503.18813; Willison dual-LLM origin) |
| Context editing −84% in 100-turn web-search eval | A1 | CORRECT — exact match to Anthropic published figure (also: memory+editing +39%, editing-alone +29%) |
| Gartner >40% agentic AI projects canceled by end-2027 | A1 (+A2 implied) | CORRECT (Gartner press release 2025-06-25) |
| OWASP LLM01 prompt injection / LLM05 improper output handling / LLM06 excessive agency | A2 | CORRECT mapping for 2025 list |
| LangGraph explicit graph + checkpointing; Temporal event-sourced durable execution; checkpoint after every node/tool call | A2 | CORRECT (LangGraph 1.0 GA Oct 2025; Temporal durable-execution) |
| Presidio (PII), Llama Guard / Lakera / Rebuff / NeMo Guardrails (injection scan), Firecracker/gVisor sandbox | A2 | CORRECT — all real tools, correctly described |

**No verifiably-wrong specific found in EITHER answer.** Both honestly caveat that exact versions/pricing need re-verification. This is the key discriminator: neither answer was penalized on correctness for fabrication.

## Scoring (1-5)

### Answer 1 (used ai-agent-architecture navigator skill — evident from D1-D10 framework, incident #N references, audit-decisions.sh path)
- Correctness: 5 — every checked specific is right; no fabrication.
- Actionability: 5 — explicit build-order, per-decision rationale + cost impact, single load-bearing rule called out.
- Specificity: 5 — quantified ratios (55x, 84%, 40-60% routing, ~14-step Lusser gate), named patterns, threshold formula for gateway trigger.
- Completeness: 5 — all 10 decisions, maps each user property to removed exemptions, cost envelope, disaster mapping to preventing decision.

### Answer 2 (general knowledge / threat-model-first; possibly ai-guardrails + agent-orchestration knowledge)
- Correctness: 5 — all checked specifics right; cleanly scoped OWASP mapping.
- Actionability: 4 — strong end-to-end reference flow diagram, ranked decisions, good caveats; slightly less prescriptive on build sequencing and exact thresholds.
- Specificity: 4 — names real tools and frameworks but fewer verified quantitative anchors; "moderate volume" reframing is a genuinely sharp insight (concurrency > daily count).
- Completeness: 4 — covers threat model, ingestion, runtime, state, tools, guardrails, observability, cost; lighter on idempotency/double-charge, model-routing economics, and testing strategy.

## Rationale

Both answers are unusually strong and factually clean — this is a tie on correctness (5/5 each, no wrong specifics). The decision comes down to actionability + specificity + completeness, and Answer 1 wins on CORRECT, VERIFIED specifics rather than mere verbosity:

1. **Quantified, verifiable anchors that all checked out**: 84% context-editing reduction, 98.7% tool-loading reduction, the Lusser's-law ~14-step compounding-error gate, the gateway-threshold formula. Answer 2 leans on correct-but-qualitative claims.
2. **Decision-by-decision completeness with consequence mapping**: A1 maps each user property (multi-agent / stateful / untrusted / scale) to which exemptions it removes, then ties each disaster to its preventing decision. A2 covers the same ground but omits idempotency/double-charge handling and model-routing economics.
3. **Identical load-bearing insight, both correct**: both nail the single most important rule (untrusted text never reaches a tool-capable agent; parser has zero tools). A1 states it as the CaMeL trifecta-break with the exact mechanism; A2 states it equally well as decision #1. No advantage either way here.

Answer 2's edge: the "1K/day is moderate; the real axis is concurrent long-lived sessions and token throughput" caveat is a genuinely superior framing that A1 lacks, and its honest-caveats section is excellent. This keeps the margin at CLEAR rather than DECISIVE.

Net: A1 wins because it delivered MORE correct specifics with tighter actionability and completeness, and the verbosity was load-bearing (every number checked out), not padding.
