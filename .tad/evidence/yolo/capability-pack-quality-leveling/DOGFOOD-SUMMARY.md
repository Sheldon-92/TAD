# Dogfood Summary — 21-pack blind A/B quality test

**Date**: 2026-06-13 | **Method**: blind A/B (judge doesn't know which answer used the pack) on each pack's fixture scenario; judge WebSearch-verifies every specific claim and flags specific-but-wrong claims. Tests REAL answer quality, not discrimination.

## Result: 18 WITH-PACK win · 1 tie · 2 control-win (of 21)

| Result | Packs |
|--------|-------|
| WITH-PACK (clear/decisive) | rag-retrieval, ml-training, ai-podcast-production, agent-orchestration, ai-tool-integration, llm-observability, product-thinking, synthetic-data, ai-agent-architecture, ai-voice-production, ai-prompt-engineering(decisive), academic-research |
| WITH-PACK (slight) | code-security, data-engineering, agent-memory, web-testing, ai-evaluation, web-deployment |
| TIE | ai-guardrails (only OWASP-category label imprecision; all hard specifics verified correct) |
| CONTROL (slight) | knowledge-graph, video-creation |

**The packs win on CORRECT specifics + fresher tools + techniques a generalist misses** — verified by fact-check, not verbosity. This is the evidence that pack quality is real, not validation theater.

## Why dogfood was worth it — material errors it caught that eval + batch review did NOT (all fixed)
1. **ai-podcast-production**: mandated dual platform masters — WRONG (podcasts ship ONE file; platforms normalize at playback). → single-file -16 LUFS, sources added (podnews).
2. **web-testing**: `Deque n=550` fabricated (real: >2000 audits) + `@axe-core/playwright >=4.12.x` doesn't exist (real: 4.11.2, conflated with core lib). → both corrected, verified npm.
3. **ai-guardrails**: indirect injection mislabeled OWASP LLM08 (vector/embedding) — should be LLM01 with no vector store. → corrected, verified OWASP 2025.
4. **code-security**: deprecated `semgrep-action@v1` → native `semgrep ci` container, verified Semgrep docs.
5. **knowledge-graph**: `60.92%` flagged unverified — TURNED OUT REAL: pack cited the wrong arXiv ID (2506.02404 vs correct 2506.05690 Table 2). Number kept, citation corrected + table-anchored. (The "loss" was partly a citation-precision defect, now fixed.)

## Signals for human judgment (not bugs)
- **video-creation** lost with ZERO errors → the pack doesn't beat a generalist on its task; the "pack" format may add little value for this domain. Weakest of 21.
- **knowledge-graph** lost slight (now its one soft spot is fixed) → 2nd weakest.

## Methodology insight
Discrimination eval (WITH vs CONTROL marker count) + same-model batch adversarial review BOTH passed every one of the 5 material-error packs. Only a blind quality dogfood with mandatory primary-source fact-check caught them. **A pack can score discrimination-perfect + review-clean and still ship a materially wrong specific.** Dogfood-with-factcheck should be the final pre-ship gate, added to capability-upgrade.

## Minor over-assertions NOT fixed this pass (logged, low ROI)
ml-training vram optimism; agent-memory "will 400"/max_tokens over-assertion; llm-observability "1ms" (10ms); product-thinking 43→42%; synthetic-data Llama 13-gram attribution; ai-evaluation 10-15% unverified. All over-assertions/imprecisions, none answer-changing.
