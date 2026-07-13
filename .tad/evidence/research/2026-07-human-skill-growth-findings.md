# Human Skill Growth — Deep-Ask Findings (O3/KR3 round 5 of 5)

> Notebook: TAD Evolution Research (`37cfefa5-52b3-4a8a-a8e3-a83f32150759`), 45 sources
> Date: 2026-07-05
> Bookkeeping: O3/KR3 round 5 of 5
> Open-question provenance: 2026-06-09 ask-findings GAP-2 (L130) — "NO evidence of
> permanent INDEPENDENT human skill growth"

## Question

**Round 5 of 5** against notebook `37cfefa5-52b3-4a8a-a8e3-a83f32150759`:

> Is there evidence that humans using AI-agent workflows gain permanent, independently
> exercisable skill — or only AI-augmented output that evaporates without the tool?
> What conditions (deliberate practice, explanation prompts, judgment-domain routing)
> differentiate the two outcomes?

## Synthesis Points

### SP1 — The corpus contains ZERO tool-removed measurements of permanent skill gain; GAP-2 stands confirmed, now with a sharper shape

Direct probe result (refinement ask): **no source measures independently exercisable
skill after removing the AI tool.** Every "capability expansion" claim in the corpus is
augmentation-dependent: the 2026 Agentic Coding Trends Report documents AI flattening
the learning curve into de-facto full-stack breadth with "tighter feedback loops and
faster learning" — but that breadth exists because AI fills the knowledge gap in real
time; nothing shows it surviving tool removal. The sharper shape the corpus adds to
GAP-2: the causality runs BACKWARD from the naive hope. Anthropic engineers state that
effective oversight requires already "knowing what the right answer should look like" —
taste forged by doing software engineering "the hard way" — and the METR RCT found
experienced developers were 19% SLOWER with AI, spending their independent skill on
trajectory review and rejecting over half of AI suggestions. Independent skill is the
*precondition* for safe AI use, not its demonstrated product.

Sources: 2026 Agentic Coding Trends Report - Anthropic; Knowledge Activation: AI Skills as the Institutional Knowledge Primitive for Agentic Software Development; Measuring AI agent autonomy in practice \ Anthropic

### SP2 — The observable maturity signature is judgment reallocation, not knowledge accumulation: auto-approve MORE and interrupt MORE

Cross-source synthesis: what measurably grows with AI-workflow experience is *where
humans spend judgment*. Anthropic's autonomy telemetry shows novices (<50 sessions)
step-approving nearly everything (high overhead, review fatigue), while veterans (>750
sessions) enable auto-approve on >40% of actions — yet their interrupt rate RISES from
5% to 9%: they stop micro-managing routine steps and instead cut in precisely when the
agent derails. Read together with the Trends Report's oversight finding (humans must
know what right looks like), the corpus's honest answer to "what skill grows?" is: a
monitoring/redirection intuition — a real, trained discrimination skill — but one
exercised *inside* the tool loop; the corpus never tests whether it transfers outside
it.

Sources: Measuring AI agent autonomy in practice \ Anthropic; 2026 Agentic Coding Trends Report - Anthropic

### SP3 — Three architectural conditions differentiate internalization from evaporation: judgment-domain routing, transparent reasoning traces, atomized institutional knowledge

Cross-source synthesis of the conditions the corpus DOES support: (a) **judgment-domain
routing** — route easy-to-verify, well-defined, low-stakes rote tasks (unit tests,
boilerplate, scripts) to the agent while keeping high-abstraction, high-stakes,
taste/context decisions (architecture, decoupling) with the human; ceding architecture
to the agent and rubber-stamping output is the cognitive-atrophy path; (b)
**transparency-by-design** — ReAct-style Thought/Action/Observation traces and forced
plan transparency before execution turn every agent decision into a reviewable teaching
case; a black-box agent that emits only final artifacts guarantees the human learns
nothing ("knows that, not why"); (c) **atomic knowledge activation** — converting tacit
tribal knowledge (architecture red-lines, incident post-mortems) into Atomic Knowledge
Units / AI Skills counters Szulanski's knowledge stickiness: humans commanding agents
along these golden paths internalize institutional best practice at the moment of use,
compressing months of social absorption — the corpus's strongest (though still
output-side, not tool-removed) internalization mechanism.

Sources: 2026 Agentic Coding Trends Report - Anthropic; Knowledge Activation: AI Skills as the Institutional Knowledge Primitive for Agentic Software Development; Why LLM agents break when you give them tools (and what to do about it) - DEV Community; AI Agent Systems: Architectures, Applications, and Evaluation

### SP4 — Without the SP3 conditions, the default trajectory is dependence: non-experts cannot detect "almost right but unusable" output

Cross-source synthesis of the failure branch: absent hard-won verification skill,
non-experts facing complex problems cannot independently validate AI output that is
"almost right but actually unusable," producing either over-trust or a blind
guess-fail-correct-retry loop; the METR result shows even experts pay a 19% speed tax
to run the verification that catches this — a cost non-experts cannot pay at all
because the discrimination skill doesn't exist yet. Combined with SP1's backward
causality, the corpus implies a bootstrapping problem the sources leave unsolved: AI
workflows *consume* independent skill for safety but are not shown to *produce* it —
so a workflow that never routes deliberate practice back to the human (SP3a-c) trends
toward capability that evaporates with the subscription.

Sources: Knowledge Activation: AI Skills as the Institutional Knowledge Primitive for Agentic Software Development; 2026 Agentic Coding Trends Report - Anthropic

## TAD Implications

Maps to O1/KR3 capability gap: **TAD cannot currently claim, nor measure, that it grows
its human's independent skill** — the corpus confirms nobody in the field has such a
measurement (SP1), and TAD has no tool-off checkpoint of its own.

Severity: Medium
Rationale: the risk (evaporating augmentation + rubber-stamp oversight) is real and
directly relevant to TAD's human-as-bridge design, but TAD already implements the
corpus's three differentiating conditions better than baseline: judgment-domain routing
is codified as an L1 principle (2026-07-03 — choice-questions for the human domain,
AI-domain self-judgment), handoffs carry Human 学习点 / plain-language explanations
(transparency condition), and project-knowledge entries are AKU-like typed atoms.
Medium rather than High because the missing piece is *measurement* (does the human
grow?) rather than *mechanism* (TAD's mechanisms align with SP3); Medium rather than
Low because SP1's backward causality means TAD's safety model quietly assumes a human
verification skill it never verifies or trains deliberately.

Follow-up candidates (proposals only — NOT executed in this task):
1. Add a lightweight "tool-off checkpoint" to `*learn` / Gate 4: periodically ask the
   human to answer a judgment question unaided BEFORE showing the AI's analysis
   (counters Preview Anchoring / Rubber Stamp Effect already noted in principles.md,
   and creates the corpus's missing tool-removed measurement locally).
2. Track an interrupt-rate-style metric over Gate 4 decisions (accept-as-is vs adjust
   vs reject) as a proxy for whether the human's discrimination is deepening or
   rubber-stamping is creeping in.

## Provenance

- Notebook: `37cfefa5-52b3-4a8a-a8e3-a83f32150759` (registry id `tad-evolution-research`), 45 sources
- Retrieval date: 2026-07-05
- Tool: notebooklm CLI, version 0.3.4 (`~/.tad-notebooklm-venv/bin/notebooklm`), invoked
  per the research-notebook skill `ask` protocol with explicit `-n` notebook targeting
- Rounds: 1 primary ask + 1 refinement ask (source-title mapping + explicit permanence
  probe), conversation `d7a16d4d-9e9b-40d3-a2d1-060d2d9fa02b`
- Caveats:
  - SP1 is a negative-coverage finding: "no evidence in this 45-source corpus" — a
    corpus-scoped claim, not proof that no such study exists anywhere (UNVERIFIED
    beyond corpus; the corpus was curated 2026-05).
  - The METR 19% RCT figure is cited as relayed by the Knowledge Activation source,
    not from the METR paper directly (the paper itself is not a notebook source).
  - SP2's session-count thresholds (<50 / >750, 40% auto-approve, 5%→9% interrupt)
    are Anthropic telemetry observations, correlational not causal.
