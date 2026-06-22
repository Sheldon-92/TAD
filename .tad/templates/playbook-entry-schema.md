# Playbook Entry Schema — Typed Entry Contract

> Defines the 6 fields every playbook entry must have.
> Grounded in: SkillOps `s=(P,O,A,V,F)`, Letta block model, Anthropic selector design.
> Source: `.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md`

---

## Fields

| Field | Required | Semantics | Rationale |
|-------|----------|-----------|-----------|
| `label` | Yes | Stable identity (kebab-case slug); doubles as filename stem and anchor. | Letta block `label` / Anthropic `name` — every entry needs a unique, human-readable, machine-stable key. |
| `selector` | Yes | "When to use" trigger description: enumerate trigger keywords + synonyms + one catch-all. **Must include a near-miss exclusion** ("when NOT to trigger") to block shared-keyword false matches. All when-to-use lives here, never in the body. | Anthropic description-as-selector — "pushy" against under-triggering; near-miss exclusion blocks over-triggering. Both directions are load-bearing (research findings §2/§4). |
| `value` | Yes | Bounded body text, self-contained (no pronouns/references to external context). Preserve concrete values; do not generalize away specifics. **"Bounded" is mechanical: the entry declares an explicit character budget** (following Letta `limit` + live `chars_current/chars_limit`), creating compression pressure the author can see. Concrete char-limit values may be set in this doc or deferred to a subsequent phase. | Letta bounded value (a visible number, not an adjective); Mem0 self-contained — future readers have zero context beyond the entry itself. |
| `failure_mode` | **Yes (REQUIRED)** | The error default this entry corrects: "what would a naive agent do without this knowledge, and why is that wrong?" | SkillOps `F` (known failure modes as first-class field). This is the forced function that surfaces the delta — if the distiller cannot fill this field from the journal, the gap becomes a specific question routed back to the doer. An entry with no `failure_mode` has not modeled the reader's starting point and is not qualified. |
| `validator` | Yes | How to verify "this entry was followed correctly": an executable check (objective — grep, script, assertion) or a human-judgment criterion (subjective — "the reader can answer X"). | SkillOps `V`; Anthropic "assert on objective outputs, use human judgment for subjective ones." |
| `read_only` | No (default: false) | When `true`, marks the entry as SAFETY / load-bearing — automated maintenance (distiller, reconciler, lint) is forbidden to modify it. | Letta `read_only` flag; corresponds to TAD's `⚠️ SAFETY ENTRY` marker. |

---

## Notes for Phase 2

1. **Circular-trigger constraint**: `selector` and `failure_mode` must appear inline with the entry body (not extracted to a `references/` file). If they are moved to a reference, the agent does not know the trigger exists, so the entry never activates — the circular-trigger failure mode documented in principles.md ("Execution Discipline Content Must Stay in SKILL Body", 2026-06-09).

2. **Distiller definition (P2 consumes this)**: The distiller is a **dedicated pass with its own prompt**, running **after** the task completes. It **re-reads the entire unprocessed window from a high-water mark** and is instructed: "**be selective — not every observation warrants an edit, but aim for high recall.**" It is NOT "just a stranger reading the entry" — it is an independent agent with its own instructions, temporal scope, and quality bar. In TAD, the distiller is Alex-by-default (terminal isolation makes Alex a genuine structural stranger to Blake's execution context) or Codex for high-stakes entries (different model prior = stricter stranger). Grounding: Letta sleeptime agent (separate persona, batched every N turns, high-water mark); AWM induction module (separate abstraction pass from execution); research findings §1/§5.
