# Phase 4 Adversarial Review — ai-agent-architecture (fact-api lens)

- **lens**: fact-api (factual / API / version correctness; replaces cross-model review)
- **meets_bar**: true
- **Reviewed**: 2026-06-13
- **Files read**: SKILL.md + all 11 references/ + examples/multi-agent-design-decisions.md + scripts/audit-decisions.sh + QUALITY-BAR.md

---

## Verdict

The pack clears the fact-api bar. I web-verified 11 falsifiable, version-sensitive claims against
current primary/primary-adjacent documentation. **10 of 11 are correct.** The lone factual error is a
wrong YEAR on the context-editing API launch date (states `2026-09-29`; actual is `2025-09-29`,
co-launched with Sonnet 4.5). It is an off-by-one-year typo — the mechanism, co-launch model, and all
associated percentages are correct — so it does not undermine the pack's technical reliability, but it
should be fixed (it is internally impossible: 2026-09-29 is in the future relative to the pack's own
2026-06-13 retrieval date).

No wrong class names, no deprecated/renamed APIs, no wrong metric types, no swapped CVE identifiers.
The two MCP CVEs (a classic swap-risk) are mapped CORRECTLY. The model names (Sonnet 4.5, Opus 4.6,
Opus 4 / Sonnet 4) are all real and used accurately.

---

## findings

### F1 (P1, factual) — Wrong YEAR on context-editing launch date (2 occurrences)
`references/context-compression.md` L63 and `references/research-findings.md` L152 both state the
Anthropic context-editing API "launched **2026**-09-29 alongside Sonnet 4.5." Verified actual date:
**2025-09-29** (Sonnet 4.5 launch day). The stated date is in the FUTURE relative to the pack's own
retrieval date (2026-06-13), so it is self-evidently wrong. Fix: `2026-09-29` -> `2025-09-29` in both
files.

### F2 (P2, stale-flag / not a fact error) — VERIFICATION FLAG on +29%/+39%/-84% is now resolvable and should be cleared
`context-compression.md` L75-78 and `research-findings.md` L157-160 carry a VERIFICATION FLAG saying
the +29% / +39% / -84% context-editing figures came from a "SEARCH SUMMARY, not the engineering-blog
body" and are "pending second-source confirmation." I confirmed all three figures against multiple
independent sources reporting Anthropic's stated internal testing (context editing alone +29%; +memory
tool +39%; -84% token consumption in a 100-turn web-search eval). The numbers are CORRECT. The flag is
now stale fear, not an open risk — clear it or downgrade it to a cited-confirmation note. (Not a fact
error; the pack is conservatively correct here.)

### F3 (P2, citation hygiene) — Gartner finding cited to a secondary blog, not the primary press release
`research-findings.md` Finding #28 and `production-disasters.md` L151 attribute the "Gartner >40%
agentic-AI projects canceled by 2027" claim to `zartis.com`. The CLAIM is correct and is Gartner's
(verified: Gartner press release 2025-06-25, poll of 3,400+ orgs). But the `source_url` points at a
third-party blog rather than the primary Gartner newsroom URL
(gartner.com/.../2025-06-25-gartner-predicts-over-40-percent...). Per QUALITY-BAR section 5 (source URL +
retrieval date auditability) and principles 2026-05-15 ("research evidence lacks auditability"), swap to
the primary source. Fact is sound; provenance is weak.

### F4 (info, no action) — All other version-sensitive specifics verified correct
No further factual defects found across the 11 references. Specifically clean: tool-token overhead
ranges, the deferred-loading tiers, Lusser's-law math (0.95^20 ~= 0.358, 0.95^14 ~= 0.488 — arithmetic
checks out), the dual-agent/lethal-trifecta security model, and the JSONL/observability tooling list
(Langfuse, Arize Phoenix, Helicone, AgentOps, OpenLLMetry — all real, correctly described).

---

## fact_checks

1. **MCPoison = CVE-2025-54136, CurXecute = CVE-2025-54135** (permissions-safety.md L133, research-findings.md #27) — VERIFIED CORRECT. Tenable/Check Point/AIM Security confirm: MCPoison (CVE-2025-54136, Check Point, disclosed Aug 5 2025, persistent RCE via post-approval MCP config swap); CurXecute (CVE-2025-54135, AIM Security, disclosed Aug 1 2025, indirect-prompt-injection RCE). Names<->numbers NOT swapped. Tool-poisoning characterization accurate.
2. **LangGraph 1.0 GA October 2025** (coordination-and-state.md L37, observability.md L38, research-findings.md #29) — VERIFIED CORRECT. GA = Oct 22 2025, zero breaking changes, durable execution / resume-from-checkpoint. Accurate.
3. **LangGraph ~33,900 GitHub stars, 34.5M monthly downloads** (same locations) — VERIFIED CORRECT. Current: ~34.5k stars, 34.5M monthly PyPI downloads. Within rounding.
4. **Context-editing API "launched 2026-09-29 alongside Sonnet 4.5"** (context-compression.md L63, research-findings.md #26) — ERROR (F1): year wrong. Sonnet 4.5 + context-editing/memory tool launched **2025**-09-29. Day/month/co-launch-model all correct; only the year is wrong.
5. **Context editing payoffs +29% / +39% / -84%** (context-compression.md L67-72, research-findings.md #26) — VERIFIED CORRECT against Anthropic's stated internal testing (context editing alone +29%; + memory tool +39%; -84% tokens in 100-turn web-search eval). The pack's own "pending confirmation" flag is now stale (F2).
6. **Claude Opus 4.6 productized automatic server-side compaction at context-window limit** (context-compression.md L63, research-findings.md #26) — VERIFIED CORRECT. Opus 4.6 (released Feb 5 2026) introduced 1M-context + automatic server-side compaction near the window limit. Model name real, feature accurate.
7. **Code execution with MCP: 150,000 -> 2,000 tokens (98.7% reduction)** (tool-management.md L63, research-findings.md #3) — VERIFIED CORRECT against the primary Anthropic engineering article (Google Drive->Salesforce workflow, ~98.7%).
8. **Cloudflare: 2,500 API endpoints -> 2 tools, ~99.9% reduction** (tool-management.md L64, research-findings.md #3) — VERIFIED CORRECT. Cloudflare Code Mode: 2,500+ endpoints, search()+execute() (~2 tools / ~1,000 tokens), from ~1.17M tokens ~= 99.9%.
9. **Multi-agent research system beat single-agent Opus 4 by 90.2%, ~15x tokens, token usage ~=80% of BrowseComp variance** (coordination-and-state.md L29-31, research-findings.md #25) — VERIFIED CORRECT. Anthropic: lead Opus 4 + Sonnet 4 subagents beat single-agent Opus 4 by 90.2%; ~15x tokens vs chat; token usage explains ~80% of variance on BrowseComp.
10. **Gartner: >40% agentic-AI projects canceled by end of 2027 (June 2025)** (research-findings.md #28, production-disasters.md L151) — CLAIM VERIFIED CORRECT (Gartner press release 2025-06-25). Citation hygiene weak — sourced to zartis.com not the primary Gartner URL (F3).
11. **Censys MCP scan: 1,862 unauthenticated (July 2025) -> 12,520 services / 8,758 IPs / 56 countries (April 28 2026)** (permissions-safety.md L132, research-findings.md #27) — VERIFIED CORRECT against the Censys blog (12,520 / 8,758 / 56 countries / 425 ASes as of 2026-04-28; 1,862 prior-scan figure consistent).

---

## Structural sanity (secondary to lens, for context)
- SKILL.md body = 192 lines (well under the 550 threshold).
- scripts/audit-decisions.sh present + executable (A10 satisfied).
- examples fixture carries `discriminative_pattern` + `min_discriminative` = 3 (A9 eval-ready, pack-specific markers, generic buzzwords excluded).
- specN = 68 (Layer B bucket >=60 -> 5): dense research-grounded thresholds, not LLM-restatable generics.
