# Phase 4 Adversarial Review — ai-evaluation (lens: fact-api)

**Reviewer**: Claude Opus 4.8 (fact-api lens; replaces cross-model review)
**Date**: 2026-06-13
**Target**: `.claude/skills/ai-evaluation/` (SKILL.md v0.1.0 + 7 references + 1 fixture + 1 script)
**Lens**: fact-api — hunt wrong class names, deprecated/renamed APIs, wrong metric types, wrong constants/versions. Every version-sensitive claim WebSearched against current primary documentation.

---

## lens
fact-api

## meets_bar
**false**

One P0-class factual error (OWASP Top 10 for LLM 2025 ID mapping is wrong — uses obsolete pre-2025 numbering against a list the pack explicitly labels "2025") plus one unsupported quantitative claim (deepteam "23 single-turn attacks" contradicts BOTH primary sources). The OWASP error is squarely in this lens's kill-zone: a wrong, authoritative-looking constant that an agent will copy into a security report. Everything else verified clean and was notably accurate, but a security-eval pack that mis-numbers the OWASP LLM Top 10 does not clear the fact-api bar.

---

## findings

### [P0] adversarial-rules.md ADV6 — OWASP Top 10 for LLM 2025 mapping is factually wrong (obsolete numbering)
Line 130 maps:
- "Insecure Output (LLM02)" — WRONG. LLM02:2025 = **Sensitive Information Disclosure**. Improper/Insecure Output Handling is **LLM05:2025**.
- "Supply Chain (LLM05)" — WRONG. Supply Chain is **LLM03:2025**, not LLM05.
- "Excessive Agency (LLM08)" — WRONG. Excessive Agency is **LLM06:2025**, not LLM08. LLM08:2025 = Vector and Embedding Weaknesses.
- "Prompt Injection (LLM01)" — correct.

These are the pre-2025 (2023/2024) OWASP codes, yet the pack header on the same page (line 29) explicitly claims alignment with "OWASP Top 10 for LLMs 2025". This is the exact failure class the pack itself warns against (a confident, copy-pasteable constant that is wrong). Cross-cutting impact: the pack's whole premise is that agents copy these mappings into compliance/security reports — a wrong code ships straight into an audit artifact.
→ FIX: `Prompt Injection (LLM01), Sensitive Information Disclosure (LLM02), Improper Output Handling (LLM05), Excessive Agency (LLM06)`; or drop the parenthetical codes and link the official list. Verify against https://genai.owasp.org/llm-top-10/ (LLM01 Prompt Injection, LLM02 Sensitive Information Disclosure, LLM03 Supply Chain, LLM04 Data and Model Poisoning, LLM05 Improper Output Handling, LLM06 Excessive Agency, LLM07 System Prompt Leakage, LLM08 Vector and Embedding Weaknesses, LLM09 Misinformation, LLM10 Unbounded Consumption).

### [P1] deepteam single-turn attack count "23" is unsupported by every primary source
SKILL.md L123, adversarial-rules.md ADV1/ADV2 Quick-Index claim "23 single-turn". Primary sources on 2026-06-13:
- Official docs (trydeepteam.com/docs/red-teaming-adversarial-attacks): **14 single-turn**.
- GitHub README: lists **22 named** single-turn attacks; the headline figure is "**20+** research-backed adversarial attack methods" (single + multi COMBINED).
No source states 23. The pack's "23 single-turn + 5 multi-turn" = 28 also overshoots the README's "20+" combined framing. The named single-turn list in ADV2 (lines 66-71) matches the README's 22 entries, so "23" appears to be a miscount of its own list.
→ FIX: state "22 single-turn (per README) / 14 in the docs taxonomy" and "5 multi-turn", or use the README's own framing "20+ research-backed attack methods (single + multi)". Do not assert a count no source backs.

### [P2] deepeval "50+ metrics" not corroborated by current docs
SKILL.md L122 + benchmark-rules.md B1 say deepeval has "50+ metrics". Could not confirm "50+" against current deepeval docs (docs emphasize a curated metric set, not a headline count). Not load-bearing (it is a parenthetical "why" cell), but it is an unverifiable specific.
→ FIX: drop the number or say "40+ metrics incl. G-Eval, DAG, Task Completion, RAG metrics" only if confirmed against deepeval.com/docs/metrics-introduction at release time.

### [P2] "deepteam 50+ vulns" vs a secondary source's "80+" — pack is CORRECT, flagged to prevent a wrong "fix"
Help Net Security (2025-11-26) wrote "more than 80 vulnerability types". The pack's "50+" MATCHES the official README ("50+ ready-to-use vulnerabilities"), so the pack correctly preferred the primary source — flagged only so a future editor does NOT "correct" 50+ to 80+ off the news article. No change needed; keep 50+.

---

## fact_checks

1. **deepteam v1.0.4, "first stable, released 2025-11-12"** (SKILL.md L123, adversarial-rules.md ADV1) — **VERIFIED CORRECT**. GitHub releases page shows v1.0.4 on November 12 labeled "First Stable Release". (A web-search snippet that claimed "v1.0.0 stable on 2025-11-26" was the search engine conflating the announcement blog date; the primary releases page confirms the pack's v1.0.4 / Nov 12.) Source: https://github.com/confident-ai/deepteam/releases

2. **deepteam "50+ vulnerability types"** (SKILL.md L123, ADV1/ADV3) — **VERIFIED CORRECT**. README: "50+ ready-to-use vulnerabilities". Source: https://github.com/confident-ai/deepteam/blob/main/README.md

3. **deepteam "5 multi-turn attacks: Linear, Tree, Crescendo, Sequential, Bad Likert Judge"** (ADV2) — **VERIFIED CORRECT**. Both README and trydeepteam docs list exactly these 5. Sources: README; https://www.trydeepteam.com/docs/red-teaming-adversarial-attacks

4. **deepteam "23 single-turn attacks"** (SKILL.md L123, ADV1/ADV2) — **FALSE / UNSUPPORTED**. Docs: 14. README: 22 named, "20+" combined headline. No source = 23. Sources: trydeepteam docs (14); README (22 named). [→ finding P1]

5. **deepteam framework alignments: "OWASP Top 10 for LLMs 2025 + OWASP Top 10 for Agents 2026 + NIST AI RMF + MITRE ATLAS + BeaverTails + Aegis"** (ADV1) — **VERIFIED CORRECT**. README lists all six. Source: README.

6. **ADV6 OWASP LLM 2025 code mapping (LLM02 Insecure Output, LLM05 Supply Chain, LLM08 Excessive Agency)** — **FALSE**. Official 2025: LLM02=Sensitive Information Disclosure, LLM03=Supply Chain, LLM05=Improper Output Handling, LLM06=Excessive Agency, LLM08=Vector and Embedding Weaknesses. Sources: https://genai.owasp.org/llm-top-10/ , https://owasp.org/www-project-top-10-for-large-language-model-applications/ [→ finding P0]

7. **MT-Bench: GPT-4 judge ">80% agreement, matching inter-human rate"; three failure modes "position, verbosity, self-enhancement"; arXiv:2306.05685** (SKILL.md L31-33, AB3, fixture) — **VERIFIED CORRECT** on all three sub-claims (>80% agreement = same as human-human; biases = position/verbosity/self-enhancement; arXiv id correct). Source: https://arxiv.org/abs/2306.05685

8. **G-Eval: "Spearman 0.514 with humans on summarization, SOTA at publication; arXiv:2303.16634"** (human-eval-protocol.md HE6, fixture) — **VERIFIED CORRECT**. G-Eval (GPT-4) = 0.514 Spearman on SummEval summarization, arXiv id correct. ("drops to 0.500 without CoT" is a finer sub-claim, plausible, not independently re-verified — headline 0.514 confirmed.) Source: https://arxiv.org/abs/2303.16634

9. **promptfoo llm-rubric/g-eval contract: scores normalized 0.0-1.0; pass iff grader.pass===true AND score>=threshold; with NO threshold passes on grader.pass alone; `{pass:true, score:0}` silently passes** (benchmark-rules.md B4, eval-config-lint.sh) — **VERIFIED CORRECT, verbatim**, including the exact `{pass:true, score:0}` example. Source: https://www.promptfoo.dev/docs/configuration/expected-outputs/model-graded/llm-rubric/

10. **deepeval API surface: `from deepeval.test_case import LLMTestCase`; `from deepeval.metrics import TaskCompletionMetric`; `from deepeval import assert_test`; `TaskCompletionMetric(threshold=...)`** (pipeline-rules.md PL5) — **VERIFIED CORRECT**. All class/function names and import paths match current deepeval docs. Source: https://deepeval.com/docs/metrics-task-completion , https://deepeval.com/docs/evaluation-unit-testing-in-ci-cd

11. **deepeval "50+ metrics"** (SKILL.md L122, B1) — **UNVERIFIED**. Current docs do not headline a 50+ count. [→ finding P2]

12. **promptfoo redteam plugin/strategy names (prompt-injection, jailbreak, pii:direct, excessive-agency, rbac, bola, bfla; strategies basic/crescendo/jailbreak:tree)** (adversarial-rules.md ADV1) — **PLAUSIBLE, consistent with promptfoo redteam taxonomy**; not exhaustively re-verified field-by-field, but no renamed/deprecated plugin spotted. Low risk.

13. **OWASP Top 10 for Agents 2026** (ADV1, ADV6) — **EXISTS / consistent**. trydeepteam hosts an "OWASP Top 10 for Agents 2026" framework doc; referenced consistently. BOLA/BFLA framing is standard. No error.

14. **Statistical claims (McNemar continuity-corrected for paired binary; Benjamini-Hochberg FDR; Benjamini-Yekutieli under dependence; Wilson CI; Krippendorff alpha bands 0.8/0.667; ICC(2,1)>0.92 / ICC(2,K)>0.97)** (ab-testing-rules.md, human-eval-protocol.md) — **CORRECT as standard methodology** (textbook-stable, not version-sensitive APIs). alpha=0.8 reliable / 0.667 tentative are Krippendorff's canonical cut-points. No factual error.

---

## Verdict rationale
The pack is, on the whole, unusually well-sourced for the fact-api lens: 11 of 14 version-sensitive checks passed against primary docs, including subtle ones (promptfoo's exact pass/threshold contract, the deepeval import paths, both arXiv ids, the deepteam v1.0.4 release date that even a web snippet got wrong). But the lens bar is "no factual/API errors that ship into output," and the OWASP LLM 2025 mis-numbering (P0) is exactly that — an authoritative-looking constant, wrong, in the security-critical reference, contradicting the page's own "2025" claim. Combined with the unsupported "23 single-turn" count (P1), **meets_bar = false** pending those two corrections (both are one-line edits).
