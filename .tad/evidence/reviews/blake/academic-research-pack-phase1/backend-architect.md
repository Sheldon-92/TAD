# Architecture Review: Academic Research Pack Phase 1

**Reviewer**: backend-architect (Layer 2)
**Date**: 2026-05-27
**Artifacts Reviewed**:
- `.tad/evidence/research/scienceclaw/architecture-analysis.md`
- `.tad/evidence/research/scienceclaw/skill-taxonomy.md`
- `.tad/evidence/research/scienceclaw/tad-mapping-blueprint.md`
**Handoff Reference**: `HANDOFF-20260527-academic-research-pack-phase1.md`

---

## Overall Assessment

The three research documents represent a thorough and well-structured analysis of a large codebase (285 skill directories, 8812 files). The architecture-analysis correctly identifies the clean separation between portable skill content and tightly-coupled runtime infrastructure. The coupling matrix in Section 8 is the most valuable section -- it directly enables Phase 2 design decisions. The taxonomy is comprehensive and the blueprint decisions are generally sound.

**Verdict**: CONDITIONAL PASS -- 0 P0, 4 P1, 5 P2

---

## Findings

### P0 (Blocking)

None identified. The documents meet the handoff ACs and are sufficient for Phase 2 design to proceed.

---

### P1 (Should Fix)

#### P1-1: Confidence Distribution Skew -- 95% of taxonomy rated "low"

**Location**: `skill-taxonomy.md`, all cluster tables

**Issue**: Of 285 skills, the Confidence column shows "high" for approximately 8-10 entries (literature-search, systematic-review, paper-writing, grant-writing, data-analysis, meta-analysis, bioinformatics, food-science, skill-creator, skill-evolution, find-skills). That is roughly 4% "high" and 96% "low". The handoff specified reading 15-20 representative skills in full (Task 2b), yet the taxonomy shows high confidence for fewer than that count.

**Impact**: Phase 2 Alex will design reference file organization based on skill content -- but for 96% of P1 skills, Blake only read metadata (first 10 lines). The Priority and Anti-Slop assignments for "low confidence" P1 skills are based on SKILL.md frontmatter descriptions, not verified content. This means the anti-slop H/M/L ratings are particularly fragile: a skill described as having "PRISMA checklist" in its frontmatter might contain a generic paragraph rather than the actual 27-item checklist.

**Recommendation**: Phase 2 Alex should treat all "low confidence + Priority 1" skills as needing content verification before relying on their anti-slop rating. The deep-read pass should be expanded during Phase 3 content migration, not deferred to Phase 4.

---

#### P1-2: Anti-Slop Score Inflation on Database Skills

**Location**: `skill-taxonomy.md`, Database Cluster (#14-#51)

**Issue**: 12 database skills are rated Priority 1 and most are rated Anti-Slop H. However, the description for these skills (e.g., "Semantic Scholar Graph API with TLDR, citation graphs", "OpenAlex 250M+ works") describes API wrappers with curl templates. API endpoint URLs + query parameters are not "judgment rules with specific thresholds" -- they are reference documentation. The H rating should be reserved for skills that encode decision logic a frontier LLM would not produce from training data alone (per architecture.md "Anti-AI-Slop as Cross-Pack Quality Bar").

Database API templates are useful as executable-references, but their anti-slop value comes from **rate limit numbers, auth patterns, and fallback chains** -- not from the API URL itself. A curl template to `api.semanticscholar.org/graph/v1/paper/search` is easily producible by any frontier model.

**Specific examples where H seems inflated**:
- #14 semantic-scholar: H rating, but the value is the API URL + params (reproducible from docs)
- #22 world-bank-data: H rating, but World Bank Indicators API is well-documented public knowledge
- #24 kegg-pathway: H rating, but KEGG REST API patterns are standard bioinformatics knowledge

**Recommendation**: Re-evaluate database skills' anti-slop scores. The H rating should apply only when the skill contains **specific thresholds, fallback chains, or error-handling logic** beyond standard API documentation. Most database API wrappers should be M (domain-specific, API-specific parameters) rather than H.

---

#### P1-3: Missing Cross-Skill Duplicate Pairs in Taxonomy

**Location**: `skill-taxonomy.md`, multiple clusters

**Issue**: The taxonomy lists several near-duplicate skill pairs without explicitly flagging the duplication relationship or recommending which to prefer:

| Pair | Cluster | Issue |
|------|---------|-------|
| #52 experiment-design / #64 experimental-design | research-workflow | Both P1 and P2 respectively. Same concept, one rated M, one H. No note on which has richer content. |
| #53 hypothesis-generation / #65 hypothesis-gen | research-workflow | Both cover the same topic. Priority 1 vs 2 assignment appears arbitrary without content comparison. |
| #97 meta-analysis / #104 statistics | statistics | meta-analysis is P1/H, statistics is P3/L "umbrella" -- but what does the umbrella contain that meta-analysis doesn't? |
| #156 scikit-learn / #163 scikit-learn-ml | ml-ai | P1 vs P2. "wrapper" label for #163 with no explanation of what it wraps or adds. |
| #161 scanpy / #162 scanpy-singlecell | ml-ai | Both P2/H. Identical domain. No deduplication note. |
| #36 open-targets / #37 opentargets-database | database | Both P2. Identical API, different naming. |

**Impact**: Phase 3 content migration will need to deduplicate these. If the blueprint doesn't flag them now, Phase 3 Blake will spend time re-analyzing pairs that Phase 1 Blake already encountered.

**Recommendation**: Add a "Deduplication Notes" section at the bottom of `skill-taxonomy.md` listing confirmed duplicate pairs with a recommendation (prefer A over B, merge into single reference, etc.).

---

#### P1-4: Blueprint Decision 5 (Alex/Blake Role Mapping) Lacks Boundary Cases

**Location**: `tad-mapping-blueprint.md`, Decision 5

**Issue**: The role mapping table maps ScienceClaw concepts to Alex/Blake cleanly for the happy path. But it does not address three boundary cases that will arise in practice:

1. **Who handles search strategy pivots?** When initial search returns low-quality results and Blake needs to change databases or query strategy mid-session. Is this a Blake decision (tactical) or does it require returning to Alex (strategic)?

2. **Who handles cross-disciplinary research?** When a research question spans multiple domains (e.g., bioinformatics + economics for health economics). The blueprint has domain-natural.md and domain-social.md as separate references -- who decides when to load both?

3. **Who handles the "Quick factual" vs "Literature survey" classification?** Decision 6 says single-session for quick factual, multi-session for surveys. But the user's initial question may be ambiguous ("what do we know about CRISPR off-target effects?" could be either).

**Impact**: Without boundary case rules, Phase 2 Alex will design the pack router without handling these, and they will surface as runtime confusion during Phase 4 behavioral testing.

**Recommendation**: Add a "Boundary Cases" sub-section to Decision 5 with explicit rules for these three scenarios. Suggest: (1) Blake handles tactical pivots within handoff-scoped database list; returns to Alex if pivoting to an unscoped database. (2) Pack router auto-loads both domain references when query terms span domains. (3) Default to "literature survey" unless user explicitly says "quick" or question is purely factual.

---

### P2 (Nice to Fix)

#### P2-1: Architecture Analysis Section 5 (Hook System) is Thin

**Location**: `architecture-analysis.md`, Section 5

**Issue**: The Hook System section is 15 lines covering "frontmatter, config, fire-and-forget, gmail hooks" and declares them "tightly coupled to OpenClaw runtime." This is the thinnest section in the document. While the conclusion (tightly coupled, skip) is likely correct, the section doesn't show enough evidence to justify the coupling claim. Other tightly-coupled sections (Memory, Context Engine) show specific file paths, line numbers, and interface contracts.

**Recommendation**: Add 2-3 specific import paths or function signatures from `src/hooks/` that demonstrate the tight coupling (e.g., "imports from `../channels/`, `../config/`" -- which is stated but not traced to specific files).

---

#### P2-2: Licensing and Legal Risk Not Addressed

**Location**: All three documents

**Issue**: None of the three documents mention the ScienceClaw repository's license. The taxonomy lists at least 4 skills with "COPYRIGHT NOTICE" in the description (#13 search-strategy, #70 deep-research-swarm, #96 knowledge-synthesis, #115 data-visualization-biomedical, #116 data-visualization-expert, #143 computational-pathology-agent, #261 scientific-manuscript). These are correctly marked "skip" in TAD Mapping, but the broader question -- can we legally extract judgment rules from ScienceClaw's SKILL.md files into TAD? -- is not addressed.

**Recommendation**: Add a section to the blueprint noting the repo license (MIT/Apache/proprietary/unlicensed) and whether extraction of judgment rules into a derivative work is permitted. If the license is unclear, flag as a Phase 2 blocker.

---

#### P2-3: Blueprint Terminology Glossary Missing "heartbeat" Explanation

**Location**: `tad-mapping-blueprint.md`, Terminology Glossary

**Issue**: The glossary maps `heartbeat (3600s)` to `context compaction` but does not explain what the heartbeat does in ScienceClaw. Is it a keep-alive ping? A session timeout? A checkpoint save? The mapping to "context compaction" implies it is a session persistence mechanism, but this is not justified.

**Recommendation**: Add a 1-sentence explanation of what the heartbeat does in ScienceClaw (from `SCIENCE.md` or `src/agents/` source code), so the mapping is grounded rather than assumed.

---

#### P2-4: Decision 7 Effort Estimate Missing Risk Multipliers

**Location**: `tad-mapping-blueprint.md`, Decision 7

**Issue**: The effort estimate (6-10 handoffs across 4 phases) is based on "actual source code analysis." However, the 96% low-confidence taxonomy entries mean Phase 3's content migration effort is estimated from metadata, not verified content. The estimate says Phase 3 is "3-5 handoffs, High complexity" but does not account for:
- Deduplication effort (P1-3 above identifies at least 6 duplicate pairs)
- Skills that appear to have content but are actually stubs or COPYRIGHT-only
- Possible need to return to Phase 1 for deeper reads on P1 skills rated low-confidence

**Recommendation**: Add a risk note to Phase 3: "+1-2 handoffs if deduplication or content verification reveals significant gaps in taxonomy accuracy."

---

#### P2-5: Architecture Analysis Claims "0 skills reference plugin-sdk" Without Showing Grep Command

**Location**: `architecture-analysis.md`, Section 8.3

**Issue**: The cross-skill coupling analysis states "0 skills reference plugin-sdk or context-engine" and "37 skills mention memory." These are critical claims that underpin the entire "skills are portable" conclusion. But the document does not show the grep commands used to derive these numbers. Per handoff AC/NFR2, "all claims must cite specific file paths." These claims cite numbers but not the method used to produce them.

This matters because a grep for `plugin-sdk` might miss skills that reference the plugin system by other names (`api.registerTool`, `openclaw`, `extension`, etc.).

**Recommendation**: Add the actual grep commands (or a footnote) showing what patterns were searched. If only `plugin-sdk` was grepped, also grep for `openclaw`, `registerTool`, `extension`, and `api.register` to confirm no skills reference the runtime by alternative identifiers.

---

## Positive Observations

1. **Coupling Matrix (Section 8.1)** is the standout section. Clear 3-column format (subsystem / coupling / migration feasibility) with specific evidence for each rating. This is exactly what Phase 2 Alex needs.

2. **Database Strategy (Blueprint Decision 3)** correctly identifies that ScienceClaw's own pattern (curl-based API wrappers) is the right one for Claude Code. The per-database table with auth, rate limits, and strategy is immediately actionable.

3. **Skill Evolution Decision (Blueprint Decision 4)** correctly identifies that runtime skill generation is architecturally incompatible with Claude Code's stateless sessions. The three-option evaluation and recommendation of proposal-based evolution via existing TAD mechanisms shows genuine architectural judgment rather than naive porting.

4. **Priority 1 ratio at 21%** (60/285) is well within the 30% target and suggests disciplined prioritization rather than "everything is important" inflation.

---

## Summary

| Severity | Count | Items |
|----------|-------|-------|
| P0 | 0 | -- |
| P1 | 4 | Confidence skew, anti-slop inflation on DB skills, missing dedup notes, missing boundary cases |
| P2 | 5 | Thin hook section, no license analysis, glossary gap, effort risk multipliers, grep evidence |

**Gate 3 Recommendation**: CONDITIONAL PASS. P1 items should be addressed before Phase 2 design begins, or explicitly deferred as Phase 2 input with Alex awareness. No P0 blockers.
