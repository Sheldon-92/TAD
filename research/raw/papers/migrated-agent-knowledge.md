# Deep Research: How SOTA Agents Accumulate Knowledge / Skill / Workflow

**Date**: 2026-06-22 · **Method**: cloned 4 OSS repos, source-level read by 4 parallel sub-agents
**Decision question**: How should TAD redesign knowledge recording so that what Blake/Alex
write is reusable by a future zero-context agent, not a session diary?
**Repos** (`~/research-clones/agent-knowledge/`): mem0 · letta · awm (agent-workflow-memory) · anthropic-skills

---

## THE CONVERGENT FINDING (all 4 systems agree)

**Capture, Distill, and Maintain are three SEPARATE operations, done at different times by different passes.**
No SOTA system lets the doer write finished knowledge inline at task end. Every one splits it:

| System | Capture (cheap, raw) | Distill (separate pass) | Maintain (rule-driven) |
|---|---|---|---|
| **Mem0** | turn → fact strings (extraction prompt) | separate reconcile call vs top-K existing | MD5 dedup + (legacy) ADD/UPDATE/DELETE/NOOP |
| **Letta** | foreground agent, recall = auto-logged | **sleeptime** background agent, own prompt, batched every N turns | block char-limit + read_only flags |
| **AWM** | agent runs the task | **induction module** abstracts trajectory→workflow | success-only + 2-stage dedup + leak filter |
| **Anthropic Skills** | (authoring) | skill-creator + held-out trigger optimizer | with-baseline eval, lean/prune |

→ This validates our "Blake writes log, Alex distills playbook" — but sharpens it: the distiller is a
**dedicated pass with its own prompt**, runs **after**, re-reads the **whole window since a high-water mark**,
and is told **"be selective — not every observation warrants an edit, but aim for high recall."**

---

## 1. WHAT TO RECORD — the AWM "variabilize-ability" test (operationalizes "delta not journey")

AWM never asks "is this useful?". It asks two **mechanical** questions:
1. **Does it repeat across ≥2 episodes?** (one-off → not a workflow)
2. **Can each concrete token become a `{descriptive-name}` slot while the skeleton stays valid?**

Plus a **symmetric** rule most systems miss — the load-bearing pair of instructions, verbatim:
> "Represent the non-fixed elements (input text, button strings) with descriptive variable names…"
> "**Keep the values of invariant elements**, e.g. id of 'Search'… as they will share and stay invariant across tasks."

(Over-abstraction is as wrong as under-abstraction. `Seattle`→`{origin-city}` BUT `One Way` stays `One Way`.)

Extra filters AWM stacks before a trajectory becomes a workflow:
- **Success-only**: never induce from a failed/partial trajectory (`cum_reward` / autoeval / all-steps-match).
- **2-stage dedup**: by intent-template-id, then by argument-stripped action-signature (`click(id)_fill(id)`).
- **Leak detector** (`filter_workflows`): reject any output still containing literals from the single source
  episode (the un-variabilized tell that abstraction failed).
- Abstraction is **LLM-driven, taught by ONE before/after worked example**, not by rules/regex.

**Steal**: capture-test = "rewrite this with `{slots}` for everything project-specific — does a coherent reusable
skeleton survive?" Yes→pattern. Dissolves entirely into slots→it was a log. Nothing variabilizes→one-time fix.
Only harvest from Gate-passed/accepted work. Reject a "pattern" that still carries source-episode literals.

---

## 2. HOW TO RECORD — the entry schema (Letta block + SkillOps contract + Anthropic selector)

Converged entry shape:
- **label / name** — stable identity (Letta `label`; Anthropic lowercase-hyphen `name`).
- **description-as-selector** — ALL "when to use" lives here, not the body. Anthropic ships a held-out-test
  optimizer for it and says be **"pushy"** against under-triggering: enumerate trigger phrases + synonyms +
  a catch-all, AND a near-miss exclusion. (Letta `description` is rendered separately from `value` and tells
  the agent the block's *purpose*.)
- **bounded value** — Letta `limit` with live `chars_current/chars_limit` so the agent feels condense-pressure.
- **failure_mode** — SkillOps contract `s=(P,O,A,V,F)` makes `F = known failure modes` a first-class field.
  This IS our "write the naive default you're correcting." Make it required → forces delta to surface.
- **validator** — SkillOps `V`; Anthropic: objectively-verifiable outputs get assertions, subjective get
  human judgment ("don't force assertions onto things that need human judgment").
- **read_only / protected flag** — Letta; the auto-distiller is forbidden to touch these (= our SAFETY entries).

Writing-style rules (verbatim, high-leverage):
- **"No relative time"** (Letta sleeptime prompt): "do not write 'today' or 'recently', instead write specific
  dates and times, because the memory is persisted indefinitely." (TAD already converts dates — formalize it.)
- **"Explain why, not musty MUSTs"** (Anthropic skill-creator): "If you find yourself writing ALWAYS or NEVER
  in all caps… that's a yellow flag — reframe and explain the reasoning so the model understands why."
  → direct critique of TAD principles.md style. Reserve hard MUSTs for SAFETY entries only.
- **Self-contained, preserve specifics** (Mem0): no pronouns; "promoted to assistant manager" keeps
  "assistant manager" not "manager"; "completeness beats brevity."
- **Imperative voice**; **inline gotchas at point-of-use** with the correct alternative immediately following.

Body structure (Anthropic, observed across pdf/mcp-builder/webapp-testing):
Overview (+ quality bar + pointers) → fast path / decision tree → work organized by ONE axis (tool|phase|pattern)
→ inline ❌/✅ pitfalls → Quick Reference table (Task→Tool→Command) → Next-Steps pointers.
**Progressive disclosure**: body <500 lines (ToC if a reference >300); depth/variants → `references/`, one file
per variant; **scripts are black-box** ("run `--help` first, DO NOT read source — it pollutes context").

---

## 3. MAINTAIN — cheap, rule-driven, and human-gated for destructive ops

Mem0 classic reconciliation (the design to steal even though Mem0's own OSS retired it):
- Show the LLM the **top-K existing entries** and force **one of {ADD, UPDATE, DELETE, NOOP}** per candidate.
  NOOP is first-class → default is **do nothing**, not append.
- **UPDATE keeps the same ID**, carries `old_memory` (audit trail), "keep the fact with the most information."
- **DELETE reserved for contradiction**, not staleness ("loves pizza" vs "dislikes pizza").
- **UUID→integer remap** before showing the LLM = anti-hallucination (can't invent an ID it wasn't shown).
- **MD5 exact-dup pre-filter** before any LLM call (zero token cost).

SkillOps maintenance (rule-driven, "nearly zero LLM calls at library time"):
- **utility = fraction of recent task calls that successfully used the skill** → low-utility auto-**retire**.
- **redundancy** via body-hash collision → **merge**, keep higher-utility representative.
- **validation-gap** `G(s)=𝟙[V_s=∅]` → flag entries with no validator.
- 5-dim health (utility, redundancy, compatibility, failure-risk, validation-gap) propagated along deps.

**CRITICAL SIGNAL**: Mem0 **retired autonomous LLM UPDATE/DELETE** (too risky) → now ADD-only + hash dedup,
with UPDATE/DELETE only reachable by an explicit human-named ID. → For TAD: auto-distiller may **propose**
UPDATE/DELETE, but **human gates** them (matches "human is the bridge" + "verify before delete" principles).

Letta sleeptime = the maintenance pass model: separate background agent, own persona, fires every N turns
(not per-message), reads everything since `last_processed` high-water mark, precise-edit vs `rethink`
(wholesale) with explicit rules on which to use, uniqueness-enforced edits (error if 0 or >1 match).

---

## 4. THE "STRANGER TEST" (user's idea) vs SOTA

None of the 4 implements the user's exact zero-context-subagent-asks-questions test. The closest analogs:
- AWM **leak detector** (reject if un-variabilized) — structural completeness check.
- Anthropic **with-skill-vs-baseline behavioral eval** + **held-out trigger optimization** (against over/under-fit).
- SkillOps **validator** field requirement.

→ The stranger test is a **novel, correct-shaped** contribution: it's the file-based analog of Anthropic's
"spawn a subagent, run with-skill-vs-baseline." Reposition it as the **completeness gate at the DISTILL step**
(not a per-entry write-time tax), and pair it with **usage-tracking for value/staleness** (SkillOps utility).
Use **Codex** as the stranger when stakes are high (different model prior = stricter than a same-family subagent).
Anti-theater requirement: feed it a deliberately INCOMPLETE entry and confirm it catches the gap — else the gate
is theater (matches TAD's recorded "Validation Theater / rubric gate" failures).

---

## 5. PROPOSED TAD ARCHITECTURE (grounded synthesis)

Three moments, three operations:
```
CAPTURE  (write-time · cheap · doer/Blake)   → raw journal, NO quality bar, append-only
DISTILL  (after success · separate pass/Alex)→ variabilize-test → typed entry (trigger/action/validator/
                                               failure_mode) → stranger test = completeness gate
                                               ←← delta is FORGED here, not at capture
MAINTAIN (periodic · rule-driven · ~0 LLM)   → usage-utility retire · hash-merge dedup · ADD/UPDATE/DELETE/
                                               NOOP reconcile (DELETE/UPDATE human-gated)
```
- **journal vs playbook physically separated** (Mem0 raw-vs-reconciled; Letta recall-vs-archival).
- **Distiller is its own prompt/pass with a high-water mark**, told "be selective, high recall, no relative time."
- **Entry schema** = label + pushy-selector-description + bounded value + required `failure_mode` + `validator`
  + `read_only` for SAFETY.
- **Value filter is usage-measured**, not write-time-judged (retire entries nothing loads).
- **Scaling by reuse-frequency** (user's insight): high-reuse domains (audio/video/content) earn proactive,
  stranger-tested playbooks; one-off dev fixes stay one journal line.

### Open question (Phase 2): JUDGMENT-type knowledge
All 4 systems are executable-skill/workflow shaped. None solves "why was this architecture chosen" knowledge,
whose delta is a *judgment difference* not an *action difference*. Its stranger test must be "give a NEW
scenario, can the reader make the same-quality judgment?" — a different mechanism. Audio (executable) is the
ideal Phase-1 prototype domain; judgment-type is Phase 2.

---

## SOURCES
- Mem0: github.com/mem0ai/mem0 (`mem0/configs/prompts.py`, `mem0/memory/main.py`)
- Letta: github.com/letta-ai/letta (`schemas/block.py`, `function_sets/base.py`, `groups/sleeptime_multi_agent_v4.py`, `prompts/system_prompts/sleeptime_v2.py`)
- AWM: github.com/zorazrw/agent-workflow-memory (`webarena/induce_prompt.py`, `mind2web/prompt/*_abstract.txt`, `*_induction.py`) · arXiv:2409.07429 (ICML 2025)
- Anthropic Skills: github.com/anthropics/skills (`skills/skill-creator/SKILL.md`, `template/`, `skills/{pdf,mcp-builder,webapp-testing}/`)
- SkillOps arXiv:2605.13716 · AutoSkill arXiv:2603.01145 · MUSE-Autoskill arXiv:2605.27366 (from prior web pass)
