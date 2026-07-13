---
name: YOLO Audit Findings
description: Cross-model (Codex+Gemini) audit of YOLO Epic execution — validation theater, rule soup, anti-slop metrics. Three mandatory improvements identified.
type: project
originSessionId: 46b8eb07-2d08-4480-9ac0-1034935c96f5
---
YOLO mode executed full Epic (5 packs + validation + freeze) in one session. Codex (23/35) and Gemini (24/35) independently audited.

**Why:** First real YOLO Epic — need to know if autonomous execution actually works or just looks impressive.

**How to apply:**

Three mandatory improvements for future YOLO:
1. **Behavioral eval** (Codex): structural checks (install/grep/frontmatter) ≠ quality proof. Each pack needs 3-5 before/after task comparisons before accepted. Use ai-evaluation pack's own rubric.
2. **Collision detection** (Gemini): 13 packs don't know about each other. When ≥2 load, must scan for contradicting rules. step4_5 max_packs=2 guardrail already exists — verify enforcement.
3. **Anti-slop formula** (both): specific threshold from research (n≥550, exit 183, 10-32x token cost) >> generic principle from training data. If a rule could be generated without the research notebook, it's low-value.

Key constraint: 50+ packs = "Rule Soup" (both scored scalability 2/5). Progressive disclosure is the answer, already implemented via step4_5 but needs stress testing.

Strength validated: research-driven build (NotebookLM per pack) produces rules that frontier LLMs don't already know (Anti-Slop 5/5 on best packs).
