# Phase 4 Adversarial Review — ai-agent-architecture (anti-slop lens)

- **Reviewer**: subagent (anti-slop lens)
- **Date**: 2026-06-13
- **Files read**: SKILL.md + all 11 references/ + examples/multi-agent-design-decisions.md + .tad/evidence/pack-quality/QUALITY-BAR.md

## Lens

Anti-slop: are the Layer B "specifics" genuinely research-grounded (numbers/thresholds an LLM could NOT emit from training), or generic rules dressed up? Flag vague/restatable rules masquerading as depth, and unsourced numbers.

## meets_bar: TRUE

specN (specific-threshold dedup count over SKILL.md + references/) = **68-70** (this pass: 68 via null-delimited find under LC_ALL=en_US.UTF-8; a prior pass got 70 — within the ±2 dedup drift QUALITY-BAR §2.3 declares bucket-stable) → bucket **≥60 → Layer B 5**. The pack clears the depth bar on a counted sub-dimension, and a reading-based pass confirms the count is not inflated by buzzword density — the matches are load-bearing thresholds, not decoration.

**This pass adds LIVE primary-source verification** (the prior pass explicitly did NOT re-fetch URLs). All three headline numbers verify VERBATIM against the cited Anthropic articles (see Fact-checks FC-LIVE). The self-flagged context-editing percentages are CONFIRMED absent from the cited blog body — honest disclosure stands, but the citation/flag contradiction is now a concrete fix item.

## Findings

### Genuinely research-grounded (clears the 0/2/5 §2.1 "5" anchor — LLM could not emit unprompted)
- **Lusser's-law table (need-an-agent.md / Finding #1)**: 0.95^20≈36%, 0.95^14≈0.488, 0.90^7≈0.478, 0.90^20≈12%, 0.98^20≈67%. I recomputed all five — exact. Crucially it carries a *non-obvious* claim ("real production agents run 85-90%/step, NOT the 95-98% intuition") plus a derived decision rule (">~14 steps at 95% → decompose / insert deterministic checkpoint that resets the product to 1.0"). This is the opposite of restatable — it inverts the naive assumption.
- **Code-execution tool discovery (tool-management.md + Finding #3)**: "150,000 → 2,000 tokens (98.7%)" Google Drive→Salesforce; Cloudflare "2,500 endpoints → 2 tools (99.9%)". Carries source_url (anthropic.com/engineering/code-execution-with-mcp) + retrieval date + an explicit "quote confirmed via WebFetch" note. This is a specific, auditable, recent figure — not generic.
- **Multi-agent 15x economics (coordination-and-state.md + Finding #25)**: "+90.2% vs single Opus 4, ~15x tokens, token usage = ~80% of perf variance (BrowseComp)" → decision rule "default single-agent unless info exceeds one context window." Specific + sourced + actionable.
- **MCP attack surface (permissions-safety.md + Finding #27)**: 1,862 (Jul 2025) → 12,520 services / 8,758 IPs / 56 countries (Apr 28 2026); CVE-2025-54136 (MCPoison), CVE-2025-54135 (CurXecute); "9 of 11 registries accepted malicious packages." Named CVEs + dated scans = high auditability, not restatable.
- **Hermes compression mechanics (context-compression.md)**: anti-thrash "<10% saved over last 2 → skip", "strip tool outputs >200 chars before summarizer = 10x", "50%/85% dual triggers", and the gateway tuning formula `gateway_threshold = 1 - (p99_single_tool_output / context_limit)`. These are concrete, mechanism-level, and the file *correctly caveats* that 50/85 are Hermes-specific for a 200K window and must be retuned at 1M — this is the §A "no time-sensitive failure / give default + escape hatch" discipline done right.
- **Tool token table (tool-management.md / cost-token-economics.md)**: 40 tools = 8K-55K tokens; deferred index ~1K → ~55x; hooks 0 / skills 500-2K / plugins 2K-8K / MCP 8K-55K; SkillTool vs AgentTool ~7x. Concrete tiers tied to a named source (Claude Code #9/#13).

### Honest disclosure (a positive anti-slop signal, not a flag)
- **Finding #26 (+29% / +39% / -84% context-editing)** in both research-findings.md and context-compression.md carries an explicit ⚠️ VERIFICATION FLAG: the percentages came from the announcement *search summary*, not the engineering-blog body (WebFetch confirmed the body lacks them); mechanism + launch date confirmed, percentages pending second-source. This is exactly the auditability behavior QUALITY-BAR §6 / principles 2026-05-15 ("research evidence lacks auditability") asks for. Self-flagging an unverified number is the correct anti-slop move, not a violation.

### Generic-but-correctly-labeled (NOT masquerading as depth)
- The Anthropic "Building Effective Agents" 6-pattern matrix (coordination-and-state.md) and the 5-level complexity ladder (need-an-agent.md) ARE the kind of content a frontier LLM can largely reproduce. However they are openly attributed ("[Source: Anthropic Building Effective Agents]") and serve as the *navigator scaffold*, not as claimed proprietary depth. The pack's depth lives in the threshold-carrying rules layered on top (15x, Lusser, 98.7%, CVEs). So these do not constitute slop-dressed-as-depth.

### Numbers I would still down-weight (minor — not bar-failing)
- **"40-60% cost reduction" model routing** (cost-token-economics.md, also in coordination-and-state.md Routing) is attributed once to "Claude Code #3" and once to "OmniRoute research" — a round-number range with thin, internally-named sourcing. It is plausible and conventional but is closer to the §2.1 "3-4" band (named tool, soft number) than a hard research threshold. Not unsourced, but the weakest specific in the pack.
- **Finding #2 "60% of LLM errors in early 2026 = rate limits from looping agents"** is cited 3x (D6/D7 + research-findings) but its only source is "Agent failure analysis across main research notebook (58 sources)" — no source_url, unlike the 2026-06-13-refreshed findings. It is a striking, decision-driving number (justifies mandatory budget caps) that did NOT get the evidence-refresh treatment #1/#3/#25-29 received. This is the one number I'd ask be re-grounded or down-weighted before treating as fact.
- **Finding #17 "skip retrieval saves 1.44s"** — oddly precise median with only "Entropy-based RAG optimization research, main notebook" as source. Plausible but unauditable; appropriately hedged with when-NOT-to-apply guidance, so low risk.

### Structural note (in-scope for anti-slop "dressed up" check)
- The fixture's `discriminative_pattern` is genuinely pack-unique (D1-D10 IDs, "Architecture Decision Document", "Incident #", "dual-agent") and the Anti-Slop Check section explicitly *excludes* "multi-agent"/"scalable" as input/buzzword. The discriminative gate would not pass a no-pack freeform answer — consistent with QUALITY-BAR §3. specN math reproduced cleanly (70).

## Fact-checks

- Lusser table arithmetic recomputed independently: 0.95^20=0.358, 0.95^14=0.488, 0.90^7=0.478, 0.90^20=0.122, 0.98^20=0.668 — ALL match the pack to 3 decimals.
- specN recomputed under LC_ALL=en_US.UTF-8 over SKILL.md + references/*.md = 70 → Layer B bucket 5 (≥60). (First run returned 0 due to unquoted space-in-path; re-run with cd + quoting gave 70.)
- Finding #3 98.7% and Finding #26 +29/+39/-84% carry source_url + retrieval date; #26 additionally carries a self-flag that the percentages are search-summary-sourced and pending second-source confirmation. I did NOT re-fetch the live URLs (no web access used this pass); the within-pack auditability (URL + date + verification note) is present, which is what the bar requires.
- Weakly-sourced numbers flagged above (Finding #2 60%, "40-60%" routing, Finding #17 1.44s) rely on internal "main notebook" attribution without source_url — they did not get the 2026-06-13 refresh and should be down-weighted, but none is the load-bearing depth claim, so they do not pull the pack below the bar.

### FC-LIVE — primary-source WebFetch verification (added this pass, 2026-06-13)
- **FC1 VERIFIED EXACT** — code-execution 150,000→2,000 tokens / 98.7%. WebFetch of https://www.anthropic.com/engineering/code-execution-with-mcp returns verbatim: "This reduces the token usage from 150,000 tokens to 2,000 tokens—a time and cost saving of 98.7%."
- **FC2 VERIFIED EXACT** — multi-agent. WebFetch of https://www.anthropic.com/engineering/multi-agent-research-system confirms verbatim "use about 15× more tokens than chats", "outperformed single-agent Claude Opus 4 by 90.2%", and "token usage by itself explains 80% of the variance" (BrowseComp). All three present.
- **FC3 VERIFIED (drift-OK)** — LangGraph "~33,900 stars" → live 34.6k. Retrieval-dated figure was accurate; stars only grow, claim sound.
- **FC4 REFUTED-as-sourced (pack self-discloses)** — +29% / +39% / -84% context-editing. WebFetch of https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents confirms NONE of the three numbers appear in the article body. The pack's own ⚠️ VERIFICATION FLAG already says this, so it is honest, not concealed. RESIDUAL FIX: the `source_url:` + `[Source: …]` attached to these numbers points at a URL that does not support them, formatted identically to the verified findings — a skimming reader sees "+29% [Source: anthropic.com/...]" and assumes grounding. Recommend: drop the percentages to a clearly-marked "UNVERIFIED — surfaced by search summary" call-out WITHOUT a `[Source]` that implies grounding, or re-source to the actual changelog. Mechanism + launch date (2026-09-29) are fine; only the three percentages float.

Net: the pack's depth is real and the two biggest anchors (98.7%, 15x/90.2%/80%) are now live-verified verbatim against primary sources. meets_bar holds.
