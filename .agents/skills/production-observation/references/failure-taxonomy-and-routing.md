# Failure Taxonomy & Routing — The Feedback Path Back Into TAD

Classification is not bookkeeping. The class *is* the routing decision: once the divergence point is classed, the destination follows mechanically. This is what turns a weekly conversation into an improvement loop instead of a ritual.

## 1. The classes

| Class | Signature (at the divergence point) | Example |
|-------|--------------------------------------|---------|
| **F1 Capability miss** | The agent needed a tool, data source, or knowledge it does not have; it improvised or failed around the gap | User asks for a refund status; agent has no orders API and guesses from the chat text |
| **F2 Reasoning slip** | Everything needed was present; the agent reasoned, planned, or sequenced wrongly | Correct data retrieved, then the agent compares the wrong two fields and answers confidently |
| **F3 Instruction defect** | The prompt/spec/config is ambiguous, stale, or self-contradictory; the agent followed a defensible reading of a defective instruction | Prompt says "be concise" and "always explain fully"; the agent alternates randomly |
| **F4 Tool/integration failure** | A tool, API, or integration malfunctioned, returned malformed data, or timed out | Payment API returns an undocumented error shape; agent retries the identical call 9 times |
| **F5 Human-domain mismatch** | The output was technically competent and still wrong in taste, direction, or perception — a call only a human can make | Summary is accurate, complete, and in a tone the audience finds insulting |
| **F6 Environment drift** | The world changed under a correct design: API versioned, data schema moved, user population or behavior shifted | Carrier renames a status code; the agent's mapping silently points at nothing |
| **NEW** | Fits none of the above after a genuine attempt | Gets named in-session: a short name + one-line signature + the exemplar trace id |

The starter set is deliberately small. A class earns its place by recurring; a class that never fires in a quarter is a merge candidate, not a trophy.

## 2. Routing table (class → destination)

Every finding takes exactly one route. "Route" means a real artifact in the destination system with an id — a sentence in the session record is not a route.

| Class | Route | Artifact |
|-------|-------|----------|
| F1 | New handoff (design gap — the capability must be designed in) | Handoff via the normal Alex design path, citing trace ids as its evidence |
| F2 | Eval-case candidate first, then handoff if the class recurs | Case filed to the trajectory-eval harness (trace id + divergence point + expected behavior); recurrence promotes it to a handoff |
| F3 | Spec/prompt fix through the normal change path | *express or a handoff per change size — with review; never an in-session edit |
| F4 | *bug path | Bug item with the trace's tool-call chain attached |
| F5 | Design change: add or move a human choice point | Handoff to the designer side; the fix is structural (where the human gets asked), not a prompt tweak |
| F6 | Handoff + watch-list amendment | Handoff for the adaptation; the drifted source is added to watch-list §1 for that agent so the next drift is sampled deliberately |
| NEW | Knowledge candidate + taxonomy watch | Distilled via the knowledge lifecycle (capture now, distill by a stranger); the class name enters the record's watch list, and its second occurrence promotes it into §1 |

No-action is a disposition, not a route: it requires a one-line reason in the record (user error with correct agent recovery, expected behavior misread by the reviewer, duplicate of an already-routed finding — with the route's id).

## 3. Escalation thresholds

A finding waits for the weekly rhythm only while it is small. Any of these opens its work item the same day:

- **Severity**: any single instance involving money moved wrongly, data destroyed or leaked, a commitment made to a user that the operator must now break, or a safety-relevant output.
- **Frequency**: the same class fires **≥3 times in one session's sample**, or in **two consecutive sessions** at any count.
- **Silent wrongness**: an F2/F5 found in the *random-success* stratum — the run reported success. Silent wrongness outranks loud failure at equal count, because nothing else in the system would ever have surfaced it.

## 4. Closing the loop with the automated leg

The human leg discovers; the automated leg must absorb. Conversion rule:

- Every routed F2 and F3 finding is also filed as an **eval-case candidate** (trace id, divergence point, the behavior that should have happened). When the trajectory-eval harness adopts it, the class becomes regression-guarded — the human leg never has to find it twice.
- A class whose eval-case candidates keep being rejected by the eval leg as unrepresentable is itself a finding: it marks a behavior the current eval format cannot express, and routes to the eval harness's owner as an F1 *about the harness*.

## 5. Taxonomy maintenance

- New classes enter §1 only via a NEW that recurred (second occurrence) or a severity escalation — one strange trace names a candidate, not a class.
- Class definitions are changed in the open: the session record that motivates the change cites the trace ids. A taxonomy edited without exemplar traces drifts into astrology within a quarter.
- Merges and splits are normal. What is not normal is a residual bucket: if "miscellaneous/NEW" exceeds ~20% of a session's findings twice running, the taxonomy — not the agents — is the failing component, and fixing it is the next session's first agenda item.
