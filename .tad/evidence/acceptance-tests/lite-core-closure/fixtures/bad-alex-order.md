# BAD ALEX FIXTURE — marker words kept, L2.25/L2.5 order swapped, Stop lines removed

### **L0 — Applicability and current-state check**

- Input: user request.
- Action: check escalation list.
- Output: channel decision.

### **L1 — Goal anchor**

- Input: requirement context.
- Action: ask at most one anchor question.
- Output: goal anchor.

### **L1.5 — Shared knowledge preflight**

- Input: goal + indexes.
- Action: read index, max 3 patterns.
- Output: knowledge reference list.

### **L2 — Design contract**

- Input: goal + knowledge.
- Action: sketch then write LITE file.
- Output: LITE handoff.

### **L2.5 — Independent contract review**

- Input: LITE contract.
- Action: spawn fresh-context reviewer.
- Output: Contract Review section.

### **L2.25 — AC dry run**

- Input: all ACs.
- Action: verify each AC runnable.
- Output: AC executability confirmed.

### **L3 — Human decision**

- Input: contract + review.
- Action: present summary, wait.
- Output: human decision.
