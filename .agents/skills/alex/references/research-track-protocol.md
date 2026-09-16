# Research Track Protocol — RG1–RG4 gate wrapper over the *research --deep engine
# Wrapper (gates) lives here; engine = references/research-plan-protocol.md (Phase 0-5).
# Owner: Alex. Research Track is Alex-owned; NOT Build Gate 3. No Blake route.
# Called by: research_unified_protocol.deep_execution (alex/SKILL.md repoints here).
# Fallback chain: local_wiki → websearch (SSOT config-workflow.yaml fallback_chains.research); NotebookLM layer deprecated 2.44.6.

research_track_protocol:
  description: "RG1–RG4 gate wrapper for *research --deep. Binds existing research-plan phases; adds Charter/Critic/Verdict+Sources contracts only."
  trigger: "When *research --deep or *research charter is invoked, Read this reference and follow it verbatim. RG1 charter runs before Phase 0."
  rg1_charter: "Before Phase 0: write RESEARCH-CHARTER.md from .tad/templates/research-charter.md (问题 not 题目; depth line; scope-out; source strategy; search.py existing-research check). Await human charter_authorization."
  rg2_plan: "After RG1 authorize: RG2 = research-plan Phase 0 plan + step2/step3 confirmation + Phase 0class effort tier + Phase 0c plan-challenge. Artifact: RESEARCH-PLAN.md (question tree ≥3; round budget; stop rule; source priority; 0c result)."
  rounds: "Engine phase (not a gate): research-plan Phase 4 / 4b / 2.5 + saturation. Artifacts: ROUND-n.md + {date}-ask-findings.md. Stop = charter answered OR Local Wiki 3-signal saturation OR budget exhausted."
  rg3_critic: "After findings saved: independent-session Critic over findings (covers Phase 4c / 5b). Critic required for all Deep. Same-session self-review is NEVER valid → DEGRADED_WITH_APPROVAL, RG3 does not PASS. Artifact: CRITIC-REVIEW.md from .tad/templates/research-critic-review.md."
  rg4_synthesis: "After RG3: RG4 = research-plan Phase 5 + decision brief. Artifacts: VERDICT.md (verdict-first ≤3 句) + SOURCES.md (每条结论→来源→检索日期) + Local Wiki canon/wiki landing (lint.sh PASS) + human CHECK."
  critic_independence: "Critic runs in a different session with the findings/action challenge prompt + quality rubric; cross-model Codex/Gemini is optional augmentation under the DR-20260531 display+override carve-out."
  landing: "Process artifacts → .tad/evidence/research/<slug>/ (gitignored, local only). Durable knowledge → research/ Local Wiki (tracked; generate.py sole index writer). Published docs/research/<topic>/ optional on first use only. Do NOT write docs/pm/."
  verdict_contract: "Verdict-first: 结论第一句 ≤3 句；provenance 见 SOURCES.md. RG4 verdict is referenced by the next handoff's Research Findings section (existing carrier); no new wiring."
  forbidden:
    - "No new agent identity: no critic skill file, no AGENTS role row."
    - "No Blake route: research never goes through Blake / Gate 3 / Ralph Loop."
    - "No auto external CLI beyond the DR-20260531 carve-out."
    - "No frozen-pack revival: research-methodology pack stays frozen; dead-end schema reused as pattern only."
  human_decision_points:
    - charter_authorization: "RG1 — human authorizes the charter (right question? right depth line?)."
    - close_shortlist: "Rounds close — human consulted once at close (收 / 再深一轮 / 转向)."
    - material_pivot: "Material pivot — decision served or scope changes."
    note: "Engine step3-confirm and Phase 0class display+override are reused confirmations, not RG decisions; this track adds exactly the 3 decisions above."
