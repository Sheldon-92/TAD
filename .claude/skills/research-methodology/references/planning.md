# Research Planning Reference

## Purpose
Detailed protocols for CAPABILITY.md Phase 1 (PLAN). Load this file when entering the PLAN phase.

---

## 1. Problem Tree Decomposition

Transform a research question into a structured problem tree. A problem tree has:
- **Root question**: the top-level research goal
- **Branch questions**: 3-5 independent sub-questions that, answered together, answer the root
- **Leaf questions**: specific factual lookups that answer each branch (optional for complex topics)

### Decomposition Heuristics

**WHEN to go deep (use Deep Research pipeline):**
- Multi-hop reasoning required (answer to Q2 depends on answer to Q1)
- Synthesis across ≥3 independent domains needed
- Decision has long-term consequences (architecture choice, vendor selection, methodology)
- "Why X behaves this way" + "what alternatives exist" + "which is best for our context"

**WHEN to use Quick Search instead:**
- Single fact lookup ("what is the current price of X")
- Single source sufficient ("what does the Anthropic API docs say about Y")
- Answer is time-invariant (established mathematical fact, stable API behavior)

### Decomposition Template

```
Root: "How should we approach [TOPIC] for [CONTEXT]?"

Branch 1 (Landscape): "What exists today in [TOPIC]?"
  → What frameworks/tools/approaches are available?
  → What are their adoption levels and maturity?

Branch 2 (Quality): "What makes [TOPIC] work well or fail?"
  → What are the success factors?
  → What are the most common failure modes?
  → What does empirical evidence say about tradeoffs?

Branch 3 (Fit): "How does [TOPIC] fit our specific constraints?"
  → What are our specific requirements / context?
  → Which options satisfy our constraints?
  → What are the integration costs?

Branch 4 (Synthesis): "What should we actually do?"
  → Recommendation with explicit rationale
  → Risks and mitigations
  → Success criteria for our implementation
```

---

## 2. Source Strategy Selection

### GitHub-First (Default)
Best for: tools, frameworks, libraries, agent architectures, CLI tools, protocol specs

1. Search awesome-lists: `site:github.com awesome [topic]`
2. Add top-3 awesome-list repos to notebook
3. From each awesome-list, identify top 5-10 tools/frameworks
4. Add each tool's main repo to notebook (README + key docs)
5. Add company repos (if topic relates to established vendor): official repos, sample apps
6. Add documentation sites: official docs, tutorials
7. Add articles/papers: only after GitHub sources exhausted

Priority matrix:
```
T1 (authoritative): official repo README, paper PDFs, spec docs
T2 (high-quality): established blogs (Anthropic, Google, a16z), conference proceedings
T3 (supporting): community blogs, tutorials, forum posts
```

### Academic-First (Alternative)
Best for: methodology questions, theoretical foundations, empirical studies

1. Search arXiv: `site:arxiv.org [topic]`
2. Search Semantic Scholar: `site:semanticscholar.org [topic]`
3. Add key papers to notebook
4. From citations, add foundational works

### Market-First (Alternative)
Best for: competitive analysis, vendor selection, pricing, adoption trends

1. Search G2, ProductHunt, Crunchbase for category
2. Add vendor documentation
3. Add analyst reports (Gartner, Forrester summaries)

---

## 3. Success Criteria Definition

Success criteria answer: "How will we know the research is complete?"

Good success criteria format:
```
能回答以下决策树：
1. [Branch 1 question]? → Yes/No/It depends
2. [Branch 2 question]? → [specific answer format]
3. [Branch 3 question]? → [specific answer format]
4. Deliverable: [QCE report + extracted ACs / recommendation doc / etc.]
```

Anti-patterns:
- ❌ "Research is complete when I feel satisfied" (subjective)
- ❌ "Find everything about X" (infinite)
- ❌ "Read all the papers" (activity, not outcome)

---

## 4. Dead-End Registry Check Protocol

Before finalizing the problem tree, check `.research/dead-ends.yaml`:

```bash
# Check if registry exists
if [ ! -f .research/dead-ends.yaml ]; then
  # No dead ends recorded yet — skip check
  exit 0
fi

# For each sub-question in proposed tree, agent must:
# 1. Read all entries in dead_ends[]
# 2. For each entry, check scope:
#    - scope: exact → match only if question text is identical
#    - scope: fuzzy → match if semantically similar (LLM judgment)
# 3. Calculate if entry is expired: today > (recorded_at + ttl_days)
# 4. If match AND not expired:
#    - overridable: true → AskUserQuestion (see CAPABILITY.md §Phase 1, step 4)
#    - overridable: false → remove question from tree, note in plan summary
```

---

## 5. PLAN Phase Checklist

Before proceeding to GATE H1:
- [ ] Root question clearly defined (not just a topic, but an answerable question)
- [ ] ≥3 branch questions, each independently answerable
- [ ] Source strategy selected (GitHub-First / Academic-First / Market-First)
- [ ] Success criteria written as verifiable decision tree
- [ ] Dead-end registry checked, conflicts noted
- [ ] research-state.yaml initialized with question_tree populated
