# Research Analysis Reference

## Purpose
Detailed protocols for CAPABILITY.md Phase 4 (ANALYZE). Load this file when entering the ANALYZE phase.

---

## 1. Baseline Report

Start ANALYZE with a topic overview:

**FULL MODE:**
```bash
# notebooklm_bin is defined in CAPABILITY.md §0.1 — use that value
"$notebooklm_bin" summary --topics -n {notebook_id}
```
Purpose: Orient to the knowledge base before targeted asking. Not the deliverable — the deliverable is the ask loop output.

**DEGRADED MODE:**
Summarize the WebSearch results collected in Phase 2 in context. Identify gaps before asking.

---

## 2. Ask Loop Protocol

Execute one ask round per sub-question in the problem tree. Use the `-n {notebook_id}` flag — never use `notebooklm use`.

**FULL MODE:**
```bash
"$notebooklm_bin" ask -n {notebook_id} "{sub_question}"
```

**Ask question construction guidelines:**
- Frame as analytical question, not lookup question
  - ❌ "What is PIVOT/REFINE?" (lookup)
  - ✅ "What conditions should trigger a PIVOT vs REFINE decision in research workflows, and what evidence supports each choice?" (analytical)
- Include your research context: "In the context of AI agent research pipelines..."
- Ask for contradictory evidence explicitly: "...and what evidence contradicts the mainstream view?"

**After each ask round:**
1. Extract `### Claim:` blocks from response
2. Run novelty judgment (see quality-control.md §4)
3. Update `analyze.new_findings_per_round[]`
4. Run: `bash scripts/saturation-check.sh .research/research-state.yaml`
5. Apply CRAG gap detection (§3 below)
6. Apply PIVOT/REFINE decision (§4 below)

---

## 3. CRAG Gap Detection

CRAG (Corrective Retrieval-Augmented Generation) signals: the knowledge base lacks information on this sub-question.

**Gap signals to detect in NotebookLM response:**
- "sources do not contain information about"
- "not mentioned in the provided sources"
- "I couldn't find specific information about"
- "based on general knowledge" (not from sources)
- Response is shorter than 200 words for a complex question

**When gap detected:**
- Flag: update `analyze.gaps[]` in state file with `{question, round, signal}`
- Apply PIVOT/REFINE decision tree (§4)

**When no gap detected:**
- Claim has ≥1 supporting citation → normal finding
- Add to cumulative claim list for saturation tracking

---

## 4. PIVOT/REFINE Decision Tree (FR12)

When a gap signal persists after an ask round:

```
Gap detected?
├── NO → Next question (continue loop)
└── YES → Check: does REFINE apply?
    │
    ├── REFINE applies when:
    │   - ≥1 new finding returned in this round (partial information exists)
    │   - AND gap is specific (not entire topic missing)
    │   - AND refine_count for this question < 3
    │   → Action: add targeted sources → re-ask same question
    │   → Update state: refines[{round, reason}]
    │
    └── PIVOT applies when:
        - 2 consecutive REFINE attempts on this question returned 0 net new sources
        - AND gap persists
        - AND question has been active for ≥3 rounds
        → Action: AskUserQuestion (see below)
        → On PIVOT: record in dead-end registry → switch to alternative angle
```

**REFINE execution:**
1. Identify missing information type (specific tool, metric, methodology)
2. Execute targeted GitHub or WebSearch for that specific gap
3. Add found sources to notebook: `"$notebooklm_bin" source add -n {id} "{targeted_url}"`
4. Re-ask the same question: `"$notebooklm_bin" ask -n {id} "{question}"`
5. Increment `refine_count` for this question
6. Maximum 3 REFINEs per question — after 3, treat as PIVOT candidate
7. **Session PIVOT limit**: maximum 3 PIVOTs total across all questions per session (check `len(analyze.pivots) >= 3`). After 3 PIVOTs, stop and proceed to OUTPUT with gaps documented.
8. **ask_rounds accounting**: every `notebooklm ask` call — initial ask, REFINE re-ask, PIVOT new-angle ask — increments `analyze.ask_rounds`. The 10-round budget is the absolute upper bound; if reached mid-REFINE/PIVOT, escalate immediately to user via AskUserQuestion.

**PIVOT confirmation:**
```
AskUserQuestion:
  question: "这个研究角度连续 2 次补源失败：'{question}'。如何处理？"
  options:
    - "换方向 (PIVOT): 研究替代角度"
    - "接受现有结果 (不再追问)"
    - "继续补源 (再试一次)"
```

**On PIVOT:**
1. Record abandoned angle in dead-end registry:
   ```yaml
   - id: "DE-{N}"
     question: "{the question that failed}"
     scope: "fuzzy"
     reason: "2 consecutive REFINE attempts found no additional sources"
     contradicting_evidence: "{any partial findings from failed rounds}"
     recorded_at: "{today}"
     session_id: "{session_id}"
     ttl_days: 90
     overridable: true
   ```
2. Update state: `analyze.pivots[{round, old_angle, new_angle}]`
3. Formulate alternative angle and add to ask loop

---

## 5. Saturation Stop Protocol

`saturation-check.sh` outputs: `SATURATED {N}` / `DIMINISHING {N}` / `CONTINUE {N}`

**SATURATED** (rate = 0 for ≥2 rounds AND total findings ≥3):
- Stop ask loop immediately
- Update state: `analyze.saturation_reached: true`
- Announce: "研究已达饱和 ({N} 轮零新发现)。进入 OUTPUT 阶段。"
- Proceed to Phase 5

**DIMINISHING** (rate ≤ 1 for ≥3 rounds):
- Present AskUserQuestion: "研究收敛中 (连续3轮新发现≤1)。继续还是进入 OUTPUT？"
- Options: "继续深入" / "进入 OUTPUT"

**CONTINUE**: proceed to next question in problem tree.

**Round budget**: After ask_rounds reaches 10:
- AskUserQuestion: "已完成 10 轮问答（预算上限）。继续（需确认）还是进入 OUTPUT？"

---

## 6. DEGRADED MODE Analysis

Without NotebookLM:
1. For each sub-question, run WebSearch (3 queries minimum)
2. WebFetch top 2-3 results per query
3. Synthesize findings in context — agent performs cross-source analysis
4. Anti-hallucination (Layer 2): every evidence claim must include exact quote: `"..." — [source URL]`
5. Gap detection: if WebSearch returns < 3 results for a question → flag as data gap
6. No saturation tracking (no ask rounds to count) — proceed after all questions addressed

---

## 7. ANALYZE Phase Checklist

Before updating state to `phase: output`:
- [ ] Baseline report generated
- [ ] All problem tree sub-questions addressed (at least one ask round per question)
- [ ] Saturation reached OR round budget hit OR user confirmed early exit
- [ ] new_findings_per_round[] updated in state file
- [ ] All gaps documented in state file
- [ ] PIVOT/REFINE decisions recorded in state file
- [ ] No question exceeds 3 REFINE attempts without PIVOT decision
