# AC7 branch-β pre-registered escalation list

Registered before the isolated branch-β verifier simulation on 2026-08-03.
This list is a test contract, not a request to weaken the runtime verifier.

| platform | surface | escalation owner | reason |
|---|---|---|---|
| codex | `ask_user_question_hook` | human / Alex | Codex has no exact AskUserQuestion equivalent; if future evidence cannot reverify the retained best-effort mapping, report the evidence-completeness gap for human disposition. |

No other Codex safety/high surface is permitted to appear in the branch-β
BLOCK set. A branch-β nonzero result is classified as `honest_partial` in the
Completion report; the shipped ledger must remain unchanged by the simulation.
