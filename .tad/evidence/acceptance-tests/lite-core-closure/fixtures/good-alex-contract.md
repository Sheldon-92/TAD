# GOOD ALEX CONTRACT FIXTURE (hand-written at L2.5, frozen — NOT generated from any SKILL.md)

### **L0 — Applicability and current-state check**

- Input: user request.
- Action: check escalation list.
- Output: channel decision.
- Stop: fatal hit → stop.

### **L1 — Goal anchor**

- Input: requirement context.
- Action: ask at most one anchor question.
- Output: goal anchor.
- Stop: clear → no question.

### **L1.5 — Shared knowledge preflight**

- Input: goal + indexes.
- Action: read index, max 3 patterns.
- Output: knowledge reference list.
- Stop: enough to design → stop.

### **L2 — Design contract**

- Input: goal + knowledge.
- Action: sketch then write LITE file.
- Output: LITE handoff.
- Stop: existing pending LITE → stop.

### **L2.25 — AC dry run**

- Input: all ACs.
- Action: verify each AC runnable.
- Output: AC executability confirmed.
- Stop: unverifiable AC → fix contract.

### **L2.5 — Independent contract review**

- Input: LITE contract.
- Action: spawn fresh-context reviewer.
- Output: Contract Review section.
- Stop: P0 unfixed → stop.

### **L3 — Human decision**

- Input: contract + review.
- Action: present summary, wait.
- Output: human decision.
- Stop: no confirmation → no handoff.
