# Research Quality Checklist

> Per-session quality checklist. Run before generating the QCE report (Phase 5) and before GATE H3.
> An agent should self-check each item. If any item fails, resolve before proceeding.

---

## Phase Completion Checks

### Phase 1 — PLAN ✓
- [ ] Root question is actionable (answerable with "we should do X because Y", not just "X exists")
- [ ] ≥3 branch questions defined, each independently answerable
- [ ] Success criteria defined as verifiable decision tree
- [ ] Dead-end registry checked for each branch question
- [ ] research-state.yaml initialized with question_tree populated
- [ ] GATE H1 approved by user

### Phase 2 — SOURCE ✓
- [ ] GitHub-First order followed (awesome-lists → repos → docs → articles)
- [ ] ≥15 sources added (FULL MODE) or ≥9 WebSearch results (DEGRADED MODE)
- [ ] Source budget within limits (< 100 sources)
- [ ] State: source.total_added updated

### Phase 3 — CURATE ✓
- [ ] Error sources identified and cleaned (FULL MODE)
- [ ] Duplicate sources removed (FULL MODE)
- [ ] All sources tier-classified (T1/T2/T3)
- [ ] source-quality.sh run (exit code recorded)
- [ ] T1 ratio ≥ 0.30 OR user explicitly approved lower ratio at GATE H2
- [ ] State: tier counts + tier1_ratio updated
- [ ] GATE H2 approved by user

### Phase 4 — ANALYZE ✓
- [ ] Baseline report generated
- [ ] All problem tree sub-questions addressed (≥1 ask round each)
- [ ] Saturation check run after every round
- [ ] Saturation reached OR budget hit OR user confirmed early exit
- [ ] PIVOT/REFINE decisions recorded in state file
- [ ] No question exceeded 3 REFINEs without PIVOT decision or user confirmation
- [ ] State: ask_rounds, new_findings_per_round, saturation_reached updated

---

## Output Quality Checks (Before GATE H3)

### Claims Quality
- [ ] Every claim is analytical (arguable) — not just descriptive
- [ ] Every claim has ≥1 evidence item with source URL and specific citation
- [ ] Every claim has a "Contradictory evidence" section (even if "none found")
- [ ] Every claim has a confidence rating (high/medium/low) with explicit reasoning

### Anti-Hallucination Check
- [ ] Layer 1: All cited URLs were successfully added to notebook OR verified via WebFetch
- [ ] Layer 2: Every evidence item includes specific citation (quote or specific section reference)
- [ ] Layer 3: QCE structure enforced — no claim lacks contradictory evidence section
- [ ] Layer 4: Claims with confidence=low + zero evidence added to dead-end registry

### AC Quality
- [ ] Each AC is concrete and measurable (not directional)
- [ ] Each AC links back to a specific claim number
- [ ] ACs collectively cover the "Extracted ACs" section in QCE
- [ ] No AC invented for areas the research didn't cover (gaps → gap section, not ACs)

### Completeness
- [ ] Research gaps explicitly documented (not silently omitted)
- [ ] Synthesis paragraph integrates major claims and acknowledges key uncertainty
- [ ] Session artifacts: report.md and acs.md saved to correct paths
- [ ] Dead-end registry updated for this session's dead ends
- [ ] State: output.qce_report_path, output.extracted_acs_path, gate_h3 updated

---

## Quality Failure Actions

| Failure | Action |
|---------|--------|
| T1 ratio < 0.30 | Present at GATE H2 with specific T1 source recommendations |
| Claim has no supporting evidence | Change confidence to low OR remove claim |
| Claim cited URL is not in notebook | Remove citation, add "[not verified]" to claim |
| Research gap not documented | Add to "Research Gaps" section |
| AC not traceable to claim | Add claim source OR remove AC |
| Saturation not reached but exit requested | Note "early exit by user" in synthesis section |

---

## Quick Confidence Audit

For each claim, run this mental check:
```
1. Can I point to ≥1 specific sentence from a specific source?
   → NO: lower confidence or remove claim
2. Is the claim my interpretation or what the source says?
   → MY INTERPRETATION: lower confidence, add "in the author's view" qualifier
3. Would a domain expert agree this is arguable?
   → LIKELY DISAGREE: reframe as "in context X, Y is preferable because Z"
4. Did I look for contradicting evidence, or just evidence that confirms?
   → ONLY CONFIRMING: add note "searched for contradicting evidence; none found in sources"
```
