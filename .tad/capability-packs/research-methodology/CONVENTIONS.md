# Research Methodology Conventions

> Decision heuristics and conventions for using the Research Methodology Capability Pack.
> An agent that has internalized these conventions can make better judgment calls without
> constantly asking the user.

---

## 1. When to Use This Pack vs Quick Search

**Use this pack when:**
- The question requires synthesis across ≥3 independent sources
- Multi-hop reasoning required (answer to Q2 depends on Q1)
- Decision has long-term consequences (choosing a methodology, architectural approach)
- User says "研究一下", "深入了解", "调研", "landscape", "对比"
- Research will be reused (results should be documented in a notebook for future reference)

**Use Quick Search (WebSearch only) when:**
- Single fact lookup with known authoritative source
- Syntax/API question for a specific library version
- Answer needed in < 2 minutes (pack requires ≥30 minutes minimum)
- Question is about TAD framework itself (read project files, not web search)

---

## 2. Problem Tree Construction Heuristics

**Depth convention:**
- Root question: 1 (always)
- Branch questions: 3-5 (always; fewer = insufficient coverage; more = scope creep)
- Leaf questions: 0-3 per branch (optional; add when branch question is too vague)

**Branch coverage convention:**
A well-formed problem tree always includes:
1. **Landscape branch**: "What exists?"
2. **Quality branch**: "What works well/fails and why?"
3. **Fit branch**: "What's right for our context?"

Adding a 4th "synthesis" branch is optional but recommended for architecture decisions.

**Question framing:**
- Branch questions are analytical: "What determines X?" not "What is X?"
- Leaf questions are specific: "What is the default timeout in {tool}?"
- Root question is actionable: "What should we use for X?" not "Tell me about X"

---

## 3. Source Volume Guidelines

| Research Type | Minimum Sources | Target Sources | Notes |
|---------------|-----------------|----------------|-------|
| Quick landscape | 15 | 25 | New topics with few resources |
| Standard research | 25 | 40 | Most research tasks |
| Deep research | 40 | 70 | Architecture decisions, methodology selection |
| Systematic review | 70 | 100 | Academic-style, framework evaluations |

Source-to-ask ratio: aim for 1 ask round per 5-8 sources. Too many sources per ask = NotebookLM response quality drops.

---

## 4. Saturation vs Convergence Convention

**Saturation** (true stop signal):
- New finding rate = 0 for ≥2 consecutive rounds
- Means: the knowledge base has been exhausted on this question
- Action: stop, move to OUTPUT

**Convergence** (quality signal):
- New finding rate ≤ 1 for ≥3 consecutive rounds
- Means: still finding things, but yield is low
- Action: AskUserQuestion — let user decide based on research importance

**Early exit** (pragmatic):
- User explicitly says "enough, write the report"
- Round budget reached (10 rounds)
- Session is stale (> 7 days without update)

**Do NOT exit early when:**
- Only 1-2 rounds completed (minimum 3 rounds for meaningful saturation signal)
- Total findings < 3 (premature stop despite zero rate)
- REFINE was just applied (give it one more round)

---

## 5. PIVOT vs REFINE Decision Heuristics

**Quick test for PIVOT vs REFINE:**

| Signal | REFINE | PIVOT |
|--------|--------|-------|
| Some findings, but gap on specifics | ✅ | |
| Zero findings on entire topic | | ✅ |
| Wrong tool, approach doesn't exist | | ✅ |
| Tool exists but docs missing | ✅ | |
| 2+ REFINEs failed | | ✅ |

**REFINE heuristic**: "The information probably exists, we just haven't found the right source yet."
**PIVOT heuristic**: "This research angle has hit a wall — the question itself may be wrong."

**Max REFINE = 3 per question** — after 3 failed REFINEs, always ask user before continuing.

---

## 6. Confidence Rating Convention

Apply these criteria consistently across all QCE claims:

**High confidence:**
- ≥3 T1 sources support the claim
- No contradicting evidence found in any source
- Claim is about established/stable fact (not emerging practice)

**Medium confidence:**
- 2 T1 sources OR ≥3 T2 sources support the claim
- Contradicting evidence exists but is minority view (< 30% of sources disagree)
- Claim is about current best practice (may evolve)
- One strong T1 source + multiple T2/T3 corroborate

**Low confidence:**
- Only T2/T3 sources support the claim
- Contradicting evidence is equally strong (split opinion)
- Claim depends on assumptions not supported by sources
- Sources are ≥18 months old for fast-moving topics (AI/ML, cloud tooling)

**DO NOT cite with confidence if:**
- Only source is a blog post without methodology description
- Source appears to be sponsored/promotional content
- Claim requires synthesis beyond what any source states directly

---

## 7. Dead-End Registry Conventions

**When to add (any of these):**
- PIVOT decision was made (old angle is dead end)
- Claim confidence = low AND zero supporting evidence after full ANALYZE phase
- Same question was asked twice in different sessions with same zero result

**When NOT to add:**
- Low confidence but some supporting evidence exists (low confidence ≠ dead end)
- Topic was just not researched yet (absence ≠ dead end)
- Highly time-sensitive question (may be available next month)

**TTL conventions:**
- 90 days default: tool/framework availability questions (ecosystem changes fast)
- 365 days: fundamental methodology questions (slow to change)
- 30 days: pricing/API availability questions (most volatile)

**Overridable=false (use sparingly):**
- Only when the question has been proven impossible in principle (e.g., "CLI tool for X" when X is fundamentally GUI-only)
- Default is overridable=true — let users override with confirmation

---

## 8. NotebookLM Usage Conventions

**Always:**
- Use absolute path: `$HOME/.tad-notebooklm-venv/bin/notebooklm`
- Use `-n {notebook_id}` flag for all commands (stateless)
- Update research-state.yaml after each significant operation

**Never:**
- Use bare `notebooklm` command (venv not activated in agent context)
- Use `notebooklm use {id}` then `notebooklm ask` in a loop (stateful — leaks state)
- Add sources without checking budget (100 source cap)
- Run `--mode deep` without user confirmation (takes 3+ minutes, adds 60-100 sources)

**Error recovery:**
- Rate limit (429): sleep 2s, retry once, then AskUserQuestion
- Auth expired: announce "NotebookLM 会话已过期，请重新运行 setup-notebooklm.sh", switch to DEGRADED MODE
- Timeout: treat as DEGRADED MODE for this session, continue

---

## 9. State File Discipline

**Update after every phase transition** — not just at the end.

**Atomic updates**: write the complete state file each time, not partial patches. A corrupted partial write is worse than a slightly stale complete file.

**Never manually edit state file during active research** — agent owns the state, human owns the decisions at gates.

**On session start, always read state file first** — even if you believe this is a fresh session, check to prevent concurrent session conflicts.
