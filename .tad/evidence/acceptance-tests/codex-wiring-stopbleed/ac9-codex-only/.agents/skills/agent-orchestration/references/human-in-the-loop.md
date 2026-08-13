# Human-in-the-Loop Rules
<!-- capability: human_in_the_loop -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| HIL1 | Insert a human checkpoint BEFORE high-risk tool calls (DB writes, outbound comms, shell) | deterministic |
| HIL2 | LangGraph: configure interrupts via `interrupt_on`; runtime halts, persists state to the checkpointer | semi-deterministic |
| HIL3 | LangGraph resume: re-invoke with a `Command` + `thread_id`; 4 decision types approve/edit/reject/respond | deterministic |
| HIL4 | `edit` conservatively — large arg changes make the model re-evaluate and re-call tools | non-deterministic |
| HIL5 | CrewAI: `@human_feedback` decorator + dynamic self-loop via `@listen(or_(...))` revision loop | deterministic |
| HIL6 | CrewAI: store feedback lessons in memory with `source="hitl"` so they auto-append to future system prompts | semi-deterministic |

---

## Rules

### HIL1: Gate High-Risk Actions Before Execution

Production agentic workflows require human review points BEFORE high-risk operations: database writes, sending outbound communications, running terminal commands.

**Rule**: A human checkpoint must intercept the tool call *before* it executes the side effect — not after. Retrofitting HITL after side effects ship is too late. Identify every irreversible/side-effecting tool and put an interrupt in front of it.

> Source: findings.md "Human-in-the-Loop Integrations and Revision Loops" [1,4,13,26]

**determinismLevel**: deterministic — gating policy is a design decision.

### HIL2: LangGraph Interrupt Mechanics

LangGraph implements HITL natively through its persistence layer:

- Configure interrupts on target nodes/tools via the `interrupt_on` parameter.
- During the `after_model` execution hook, the LangGraph middleware checks whether any proposed tool call matches the interrupt criteria.
- On a match, the runtime immediately halts, marks the thread as interrupted, and **persists the current state snapshot to the checkpointer** (this is why HITL requires a checkpointer, not in-memory state).

**Rule**: LangGraph HITL is impossible without a configured checkpointer — the interrupt persists the snapshot there. Pair `interrupt_on` with a durable checkpointer (Postgres in production, per FS7).

> Source: findings.md "LangGraph Interruption and the Command Interface" [4,13,26]

**determinismLevel**: semi-deterministic — whether an interrupt fires depends on the model's proposed tool call.

### HIL3: The Four Resume Decision Types

To resume a paused LangGraph thread, re-invoke the graph with a `Command` object and the matching `thread_id`. The reviewer chooses one of four built-in decision types:

| Decision | Effect |
|----------|--------|
| `approve` | The proposed tool call executes exactly as the model generated it |
| `edit` | The proposed tool arguments are modified by the human before execution (e.g. change a DB update payload) |
| `reject` | Execution is blocked; the rejected call synthesizes a tool/rejection message (a `ToolMessage`) carrying the reviewer's feedback into the conversation, guiding self-correction |
| `respond` | Tool execution is skipped entirely; the reviewer's text is returned to the model as the direct tool result (useful for mocks/placeholders) |

**Rule**: Choose the decision type by intent — `reject` to redirect the model, `respond` to substitute a result without running the tool, `edit` to fix the payload, `approve` to pass through. Do not collapse all four into a binary approve/deny.

> Source: findings.md "LangGraph Interruption and the Command Interface" [13,17]

**determinismLevel**: deterministic — the four decision types are a fixed API.

### HIL4: Edit Conservatively

When using the `edit` decision to modify tool arguments, make changes conservatively. Significant modifications may cause the model to re-evaluate its approach and execute tools multiple times.

**Rule**: Prefer minimal payload corrections over large rewrites in an `edit`. If the change is large, expect (and account for) the model re-calling tools — a small edit keeps execution predictable.

> Source: findings.md "LangGraph Interruption" edit caveat [13]

**determinismLevel**: non-deterministic — model re-evaluation depends on the magnitude of the edit.

### HIL5: CrewAI Feedback Loop via Listener Self-Loop

CrewAI manages human feedback with the `@human_feedback` decorator, which pauses flow execution and displays intermediate results. For revision workflows, build a dynamic self-loop rather than a static graph edge:

```python
@listen(or_("trigger_event", "revision_outcome"))
def revise(...):
    ...
```

- The model parses unstructured human feedback and maps it to a structured output (e.g. `needs_revision`), which re-triggers the listener method, creating an automated revision loop that continues until the output matches the human's criteria.

**Rule**: For iterate-until-approved flows in CrewAI, use `@listen(or_(...))` self-loops keyed to a structured feedback outcome — not a fixed number of passes.

> Source: findings.md "CrewAI Feedback Loops and Enterprise Delivery" [27,28]

**determinismLevel**: deterministic — the loop construct is a fixed pattern.

### HIL6: Persist HITL Lessons to Memory (source="hitl")

CrewAI extracts generalized lessons from human feedback and stores them in memory with a `source="hitl"` attribute. On subsequent turns, these lessons are retrieved and automatically appended to the model's system instructions to prevent repeating the same mistakes.

For enterprise, CrewAI Enterprise shifts review from a terminal UI to an email-first, webhook-driven flow: a reply-to email with a cryptographically signed auth token is generated at the review point; the reviewer replies with feedback; the platform validates the signed token, maps the sender, injects feedback into the running flow state, and resumes — no dashboard login.

**Rule**: Capture HITL corrections as durable lessons tagged `source="hitl"` so feedback compounds across runs instead of being discarded after one revision.

> Source: findings.md "CrewAI Feedback Loops and Enterprise Delivery" [27,28]

**determinismLevel**: semi-deterministic — which lessons retrieve depends on the runtime context.

---

## Anti-Patterns

- **Approval after side effects**: gating a DB write *after* it ran defeats the purpose. Interrupt before execution (HIL1).
- **No checkpointer with LangGraph HITL**: the interrupt persists the snapshot to the checkpointer — in-memory-only state cannot resume.
- **Binary approve/deny only**: collapsing the four decision types loses `respond` (mock result) and `edit` (payload fix).
- **Aggressive edits**: large argument rewrites make the model re-call tools unpredictably.
- **Throwaway feedback**: not persisting HITL lessons (`source="hitl"`) means the agent repeats the same mistake next run.
