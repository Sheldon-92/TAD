# Research Quality Control Reference

## Purpose
Detailed protocols for CAPABILITY.md Phase 3 (CURATE) and ongoing quality monitoring. Load this file when entering the CURATE phase or checking saturation.

---

## 1. Source Tier Classification

### Tier Criteria

**Tier 1 (T1 — Authoritative)**
URL patterns that qualify:
- `arxiv.org/abs/` — arXiv papers
- `doi.org/` — DOI-resolved academic papers
- `github.com/{owner}/{repo}` where repo has ≥500 stars OR is official vendor repo
- `docs.{tool}.com` — official documentation sites
- `research.google.com`, `ai.meta.com/research`, `anthropic.com/research` — major lab research
- Official spec documents (RFC, W3C, ISO)
- Conference proceedings: NeurIPS, ICML, ACL, ICLR, EMNLP

**Tier 2 (T2 — High-Quality Industry)**
URL patterns that qualify:
- `engineering.{company}.com` — major tech company engineering blogs
- `{company}.ai/blog` — AI company technical blogs
- GitHub repos with ≥100 stars (not in T1)
- `medium.com/@{author}` where author is verifiably an industry expert
- Conference talks from major industry conferences (KubeCon, re:Invent)
- Preprint servers: SSRN for business/legal topics

**Tier 3 (T3 — Community)**
URL patterns that qualify:
- Personal blogs, tutorials, Medium posts (not expert-verified)
- Reddit, Hacker News, Stack Overflow
- GitHub repos with < 100 stars
- Forum discussions

### Classification Process

For each source:
1. Extract URL
2. Match against T1 patterns first → if match, T1
3. Match against T2 patterns → if match, T2
4. Default → T3

Update state file after classification:
```yaml
curate:
  tier1_count: {N}
  tier2_count: {N}
  tier3_count: {N}
  tier1_ratio: {tier1_count / (tier1_count + tier2_count + tier3_count)}
```

---

## 2. Source Quality Threshold

**Minimum quality for research confidence:**
- T1 ratio ≥ 0.30 (at least 30% of sources are authoritative)
- `scripts/source-quality.sh` enforces this

If T1 ratio < 0.30 after CURATE:
1. Identify gaps: which sub-questions have only T3 sources?
2. Present to user at GATE H2 with specific recommendations
3. Options: (a) add targeted T1 sources and re-curate, (b) proceed with confidence=low on affected claims

---

## 3. Error Cleanup Protocol (FULL MODE — NotebookLM)

After batch source import, some sources fail to process:

```bash
# notebooklm_bin is defined in CAPABILITY.md §0.1 — do NOT redefine here

# List all sources and check status
"$notebooklm_bin" source list -n {notebook_id}

# For each source with status != "ready":
# (typically: processing_failed, error, timeout)
"$notebooklm_bin" source delete -n {notebook_id} {source_id} --yes
```

**Deduplication**: Same URL added multiple times → keep one, delete duplicates. The NotebookLM import process sometimes adds the same URL twice from different batch runs.

Rate limiting during cleanup: add 0.5s delay between delete calls:
```bash
"$notebooklm_bin" source delete -n {notebook_id} {source_id} --yes
sleep 0.5
```

---

## 4. Saturation Detection Algorithm (FR4)

This section defines the algorithm implemented by `scripts/saturation-check.sh`.

**Finding Unit**: One `### Claim:` block in ask output = one finding.

**Novelty Judgment**: A finding is "new" if NO prior round's claim list contains a semantically equivalent statement. Use this LLM prompt to judge:
```
Is the following claim semantically equivalent to any claim in the prior list?
New claim: "{claim_text}"
Prior claims: {prior_claims_list}
Answer: YES (if semantically equivalent) or NO (if genuinely new insight).
```

**Counting Algorithm** (per ask round):
1. Extract all `### Claim:` blocks from the ask response
2. Compare each claim against cumulative claim list from all prior rounds
3. Count claims where LLM judgment = NO → this is `new_count`
4. Append `new_count` to `analyze.new_findings_per_round[]` in state file
5. Add all new claims to cumulative list for next round's comparison

**Stop Conditions:**
- **SATURATED**: rate = 0 for ≥2 consecutive rounds AND total findings ≥3
- **DIMINISHING**: rate ≤ 1 for ≥3 consecutive rounds (trigger secondary signal)
- **CONTINUE**: all other cases

**Secondary signal** (when DIMINISHING): AskUserQuestion "研究收敛中 (连续3轮新发现≤1)。继续深入还是进入 OUTPUT？"

**Minimum threshold**: total findings < 3 → do NOT declare SATURATED even if recent rate = 0 (prevents premature stop on bad first questions).

`scripts/saturation-check.sh` reads `new_findings_per_round` array from state file and outputs one of:
- `SATURATED {latest_count}` — exit 0
- `DIMINISHING {latest_count}` — exit 0
- `CONTINUE {latest_count}` — exit 0

---

## 5. Anti-Hallucination Layers (All Four)

**Layer 1: URL Existence**
- FULL MODE: NotebookLM source add validates URL returns content — failed sources are auto-marked error
- DEGRADED MODE: WebFetch each URL, confirm HTTP 200 before citing

**Layer 2: Citation Traceability**
- FULL MODE: NotebookLM `ask` responses include citations natively — every claim has source reference
- DEGRADED MODE: Agent must include exact quote from source (not paraphrased summary) for each evidence claim

**Layer 3: QCE Structure with Contradictory Evidence**
- Required structure forces agent to actively look for and report contradicting evidence
- If no contradicting evidence found → explicitly state "No contradicting evidence found in sources" (not just omit)
- Confidence cannot be "high" if only one source supports the claim

**Layer 4: Dead-End Registry**
- Prevents citing findings previously identified as low-confidence or refuted
- Check registry at Phase 5 OUTPUT before finalizing QCE report
- Auto-add to registry: any claim with confidence=low AND zero supporting evidence

---

## 6. CURATE Phase Checklist

Before updating state to `phase: analyze`:
- [ ] Error sources cleaned (FULL MODE)
- [ ] Duplicates removed (FULL MODE)
- [ ] Tier classification complete (all sources scored)
- [ ] source-quality.sh run: exit 0 = proceed; exit 1 = recommend enrichment
- [ ] State updated: tier counts + tier1_ratio
- [ ] GATE H2 presented and approved
