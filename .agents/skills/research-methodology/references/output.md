# Research Output Reference

## Purpose
Detailed protocols for CAPABILITY.md Phase 5 (OUTPUT). Load this file when entering the OUTPUT phase.

---

## 1. QCE Output Format Specification (FR7)

QCE = Question-Claim-Evidence. This is an **analytical** structure, not a summary.

### Key Distinction
- **Summary** (descriptive): "X framework uses approach Y. Z tools are available."
- **QCE** (analytical): "X framework's approach Y is superior for [context] because [evidence]. This view is contested by [contradicting evidence]."

The claim must be **arguable** — someone reasonable could disagree with it.

### Full QCE Template

```markdown
# Research Report: {research_question}

Session: {session_id}
Date: {date}
Sources: {total T1} T1 / {total T2} T2 / {total T3} T3 ({notebook_id if FULL MODE})
Mode: {FULL / DEGRADED}

---

## Question: {root research question}

### Claim 1: {analytical statement — must be arguable, not descriptive}

**Evidence:**
- [{source title}]({url}): "{exact quote or specific citation}" — supports claim because [reasoning]
- [{source title}]({url}): "{exact quote}" — corroborates via [angle]

**Contradictory evidence:**
- [{source}]: "{quote}" — argues [counter-position] because [reasoning]
- [OR: "No contradicting evidence found in sources — claim may represent consensus, or sources are insufficiently diverse."]

**Confidence:** high / medium / low
- high: ≥3 T1 sources agree, no contradicting evidence in sources
- medium: ≥2 T1 sources agree OR contradicting evidence exists but is minority view
- low: only T2/T3 sources, OR contradicting evidence is equally strong, OR claim depends on assumptions not in sources

---

### Claim 2: ...

[Repeat structure for each major claim from the ask loop]

---

## Synthesis

{1-2 paragraphs integrating all claims into a coherent recommendation or understanding.
Must reference specific claims by number. Must acknowledge the most important uncertainty.}

---

## Extracted ACs

{Actionable acceptance criteria derived from the research findings. Each AC should be
implementable and verifiable.}

- **AC1**: {concrete, measurable criterion} [Source: Claim {N}]
- **AC2**: {concrete, measurable criterion} [Source: Claim {N}]
- **AC3**: ...

---

## Research Gaps

{Things the research could not answer, even after REFINE attempts. These should be
logged in the dead-end registry.}

- Gap 1: {question} — Reason: {why not found} — Recommendation: {next step or "accept as unknown"}
```

---

## 2. AC Extraction Rules

Acceptance Criteria from research should be:

**Concrete**: Specifies a measurable outcome, not a direction
- ❌ "The system should handle errors gracefully"
- ✅ "The system must return HTTP 422 with error code and message when input fails validation"

**Source-linked**: Every AC traces back to a specific claim
- Format: `AC1: [requirement] [Source: Claim {N}]`
- If AC is derived from multiple claims: `[Sources: Claims 2, 4]`

**Implementation-ready**: The implementing team can write a test against it

**Scoped**: Clearly bounded to what the research covers
- If a gap exists, don't invent an AC to cover it — note the gap

---

## 3. Dead-End Registry Update (Phase 5)

After generating QCE report, scan for entries to add to `.research/dead-ends.yaml`:

**Add when:**
- A claim has confidence=low AND zero supporting evidence (only contradicting)
- A research gap persisted through all REFINE attempts
- A PIVOT decision was made (old angle is now a dead end)

**Do NOT add when:**
- Claim has confidence=low but ≥1 weak supporting source (low confidence, not dead end)
- Gap exists but was not actively researched (may not be a dead end, just not covered)

**Format** (append to `.research/dead-ends.yaml`):
```yaml
  - id: "DE-{N}"
    question: "{the specific question that failed}"
    scope: "exact"  # exact for specific tool questions; fuzzy for approach/methodology questions
    reason: "{why this is a dead end}"
    contradicting_evidence: "{what was found that refutes it, if anything}"
    recorded_at: "{today ISO date}"
    session_id: "{session_id}"
    ttl_days: 90
    overridable: true
```

---

## 4. Session Archive Protocol

After GATE H3 approval:

1. Create session directory: `.research/sessions/{session_id}/`
2. Move files:
   - `.research/research-state.yaml` → `.research/sessions/{session_id}/research-state.yaml`
   - QCE report → `.research/sessions/{session_id}/report.md`
   - Extracted ACs → `.research/sessions/{session_id}/acs.md`
3. Update state: `phase: complete` (in archived copy)
4. `.research/research-state.yaml` is now gone — next session creates fresh

---

## 5. OUTPUT Quality Checklist

Before presenting GATE H3:
- [ ] Every claim is arguable (not just descriptive)
- [ ] Every claim has ≥1 evidence item with source citation
- [ ] Every claim has a contradictory evidence section (even if "none found")
- [ ] Every claim has a confidence rating (high/medium/low)
- [ ] ACs are concrete, measurable, and source-linked
- [ ] Research gaps are documented (not silently omitted)
- [ ] Dead-end registry updated for low-confidence/gap entries
- [ ] Session state: `output.qce_report_path` and `output.extracted_acs_path` filled
