# Phase 3 Adversarial Review — llm-observability — Correctness Lens

- **Lens**: correctness
- **Reviewer**: subagent (Opus 4.8)
- **Date**: 2026-06-13
- **meets_bar**: TRUE (clears both layers; only non-blocking nits found)

## Verdict

The upgraded `llm-observability` SKILL.md + references + script + fixture genuinely
clears the dual-layer Quality Bar. Attempts to refute it surfaced only minor cosmetic /
labeling nits, none of which break correctness or actionability.

## What I tried to refute, and the result

### Layer A (structure) — PASS, verified empirically
- A1 frontmatter: `name: llm-observability` (17 chars ≤64, lowercase/hyphen, no "anthropic"/"claude"); `description` 620 chars ≤1024, third-person, states what+when. PASS.
- A2 progressive disclosure: 7 aux files (6 references + 1 script). PASS.
- A3 body discipline: SKILL.md = **146 lines** (≪ 550). PASS, with large margin.
- A4 routing/steps: 4 `## Step N` headers + a Context-Detection signal→reference table. PASS.
- A5 contract: CONSUMES/PRODUCES present (line 8-9). PASS.
- A6 anti-skip: dedicated "Anti-Skip Table" with 6 excuse→counter rows. PASS.
- A7 navigation: Step-0 routing table + Tool Quick Reference + per-reference "Quick Rule Index". PASS.
- A8 fixture: 1 `examples/*.md`. PASS.
- A9 eval-wired: fixture has `discriminative_pattern` + `min_discriminative: 3`. PASS.
- A10 script: `scripts/otel-conformance-check.sh` executable, POSIX, no Windows paths. PASS.
- Soft constraints: references one level deep (no nested dirs); each ref >100 lines carries a "Quick Rule Index" TOC; dated/sourced rot-warnings on pricing & versions ("verify against live pricing", "re-verify before quoting"). PASS.

### Layer B (depth) — PASS, bucket 5
- specN (counted sub-dimension) = **69** → ≥60 bucket → Layer B 5. Independently recomputed.
- B1 specificity: carries research-landed thresholds an LLM can't restate cold — z>4 over 7-day window, 80/90/100% budget tiers, [1.5,3.0]× margin caps, STS 600 RPS, dual-TTL (∞ / 60s), Wasserstein-on-PCA-95%, exact `ExplicitBucketBoundaries` arrays, v1.37 floor.
- B2 tool freshness: named CLIs + versions + usage (`pip install vllm[otel]`, scrape /metrics every 15s, OTLP `/api/public/otel`, `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental`).
- B3 operationalized criteria: P0/P1/P2 output format + determinismLevel annotations + a runnable deterministic checker.
- B4 anti-patterns: each reference ends with a production-failure anti-pattern list (per-request STS throttle, KS-test blindness, proxy can't see in-app spans, binary 100% cutoff causes outage).

### Behavioral gate readiness — PASS
- Fixture `discriminative_pattern` is anti-slop: 12 pack-unique markers available in SKILL+refs; the embedded no-pack negative control scores **0** (< min 3 ⇒ correctly FAILs). I re-ran both: control=0, pack-text=12. The fixture author explicitly excluded commodity markers (raw token counter, TTFT, HTTP 429) that a no-pack engineer scored 4/4 on — exactly the self-leak defense the bar demands.

### Script correctness — PASS, tested
Ran `otel-conformance-check.sh` against 3 inputs:
- Full-good telemetry → 4/4 PASS, exit 0.
- All-bad (precomputed `cost`, Counter instrument, missing attrs) → 4 FAIL, exit 4.
- Empty stdin → usage error, exit 64.
- C4 edge (text mentions both "Counter" and "Histogram") → conservatively FAILs C4. Acceptable: a P0 gate erring toward FAIL on ambiguous instrument typing is the safe direction.
Exit-code contract in header matches behavior. C1–C4 map cleanly to OT1/OT2/OT3+xcut/OT5.

## fact_checks (version-sensitive claims verified against live source per QUALITY-BAR §6)

1. **`gen_ai.client.token.usage` is a Histogram** — CONFIRMED against semantic-conventions-genai repo (gen-ai-metrics.md). Pack's OT5 instrument typing correct.
2. **token.usage ExplicitBucketBoundaries `[1,4,16,...,67108864]`** — CONFIRMED byte-for-byte against spec.
3. **operation.duration buckets `[0.01,0.02,...,81.92]`** — CONFIRMED.
4. **`gen_ai.server.time_to_first_token` buckets `[0.001,0.005,...,10.0]`** — CONFIRMED; the pack's table correctly attributes the fine sub-second buckets to the SERVER metric.
5. **Both client + server TTFT metrics exist** — CONFIRMED: `gen_ai.client.operation.time_to_first_chunk` (client) AND `gen_ai.server.time_to_first_token` (server). Pack names both correctly (OT5 table line 99 lists the client metric; bucket table line 111 lists the server metric).
6. **`gen_ai.provider.name` supersedes legacy `gen_ai.system`** — consistent with OT6; live spec page redirected to the genai repo (could not re-verify the supersession on the moved page, but the named-fallback-chain pattern matches Apache SkyWalking cited behavior; non-blocking).

## Non-blocking findings (do NOT sink the bar)

- **N1 (cosmetic, prose over-generalization)**: otel-semconv-rules.md L114 says "TTFT/ITL use finer sub-second boundaries." True for the SERVER `time_to_first_token`, but the CLIENT-side `gen_ai.client.operation.time_to_first_chunk` actually uses the COARSE power-of-two duration buckets per spec. The bucket TABLE is correct (it only lists the server metric); only the explanatory note slightly overstates. Suggest narrowing the note to "server-side TTFT". Not a correctness break — no wrong array is pinned.
- **N2 (labeling nuance)**: CA3 is tagged `deterministic` in the index while it bundles the emit-raw-counters cross-cutting rule (architectural, deterministic) — fine. But the SKILL Step-1 example output labels a CA3 violation `[P0]` while the determinismLevel guidance lists `deterministic` rules as architectural facts; the severity/determinism axes are orthogonal and the pack does not conflate them. No fix required; noted for completeness.
- **N3**: `gen_ai.usage.input_tokens` "(including cache)" (OT3 L63) coexists with separate `cache_read.input_tokens` (L65). This matches provider conventions (input total is inclusive; cache_read is a breakdown) and the rule text is internally consistent. No issue.

## Conclusion

I could not refute the bar. All version-sensitive numeric/API claims that I spot-checked
against the live OTel GenAI semconv repo are correct to the digit. Structure, depth, and
behavioral-gate wiring all clear. The two cosmetic nits (N1 prose scope, N2 axis labeling)
are advisory polish, not correctness defects. **meets_bar = TRUE.**
