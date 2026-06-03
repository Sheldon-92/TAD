# Workflow Pattern Adaptation — Measurement Results

> Date: 2026-06-03
> Context: *discuss session — 4 workflow patterns from Thariq article evaluated for TAD adoption
> Method: 9-agent workflow (4 researcher + 4 challenger + 1 synthesizer) → challenger pushback → manual measurement
> Source article: .tad/evidence/research/2026-06-03-dynamic-workflows-thariq.md

---

## Background

Thariq (Anthropic) published 6 composable workflow patterns. We evaluated 4 for TAD adoption:
1. Rule Adherence (per-AC verifier + skeptic)
2. Tournament (competitive design exploration)
3. Quarantine (reader/actor isolation)
4. Token Budget Control

The 9-agent research workflow recommended "measure before building" for all 4. This file records the measurements.

---

## Measurement 1: Rule Adherence — Spec-Compliance Reviewer False-Negative Rate

**Corpus:** 22 spec-compliance review files in `.tad/evidence/reviews/blake/*/`

### FAIL/PARTIAL counts per review

| Handoff Slug | FAIL/PARTIAL mentions |
|---|---|
| phase1-state-consistency | 7 |
| ai-voice-production-pack | 6 |
| phase2-grounding | 5 |
| video-creation-ai-asset-generation | 4 |
| capability-pack-research-methodology | 4 |
| capability-pack-product-thinking | 3 |
| codex-parity-phase2-catchup | 3 |
| cross-model-phase0-spikes | 3 |
| research-director-phase2 | 3 |
| tad-universal-spike | 3 |
| vimax-pattern-upgrade-video-creation | 2 |
| academic-research-pack-phase6 | 2 |
| pack-behavioral-examples | 2 |
| goal-driven-phase1 | 2 |
| codex-phase1-build | 2 |
| capability-pack-web-ui-design | 1 |
| academic-research-pack-phase7 | 1 |
| research-pipeline-iterative-enrichment | 1 |
| academic-research-pack-phase5 | 1 |
| codex-parity-phase3-releasegate | 0 |
| academic-research-pack-phase3 | 0 |
| academic-research-pack-phase2 | 0 |

**Summary:** 19/22 reviews found issues (not rubber-stamping). 3/22 clean passes.

### Real false-negative incidents found

**Incident 1: scoring-rubrics-need-methodology-review (2026-05-28)**
- code-reviewer MISSED 2 P0 in pattern-extraction.md scoring rubric
- UX-expert-reviewer caught: overlapping score definitions + undefined terms
- Root cause: code-reviewer checks structural consistency, not methodology
- This is a **different-expertise blind spot**, not context contamination per se
- Source: `.tad/project-knowledge/incidents/2026-05/scoring-rubrics-need-methodology-review.md`

**Incident 2: section-9-1-region-marker (2026-05-31)**
- Spec-compliance linter used wrong heading depth (`## 9.1` vs actual `### 9.1`)
- Scanned empty region → reported clean (false-negative that looks like success)
- Root cause: assumption about markdown structure, not context contamination
- Source: `.tad/project-knowledge/incidents/2026-05/section-9-1-region-marker.md`

### Verdict

**Problem exists but root cause is nuanced.** Neither incident is pure "context contamination from previous AC polluting the reviewer." Both are about reviewer expertise gaps (code-reviewer can't catch methodology issues) and tooling assumptions (wrong heading depth). Per-AC verifier with independent context WOULD help with the first case (methodology expert per rubric-related AC). Skeptic agent would help filter the second (catch linter false-negatives).

---

## Measurement 2: Token Budget — YOLO Execution Cost

**Corpus:** 14 YOLO gate reports across 5 Epics

### Sub-agent density per phase

| Epic | Phase | Reviewer mentions | P0 mentions |
|---|---|---|---|
| nondev-execution-track | phase1 | ~3 | 5 |
| nondev-execution-track | phase2 | ~3 | 7 |
| nondev-execution-track | phase4 | ~0 | 1 |
| pack-collision-detection | phase1 | ~4 | 3 |
| pack-collision-detection | phase2 | ~0 | 0 |
| self-deriving-release-sync | phase1 | ~2 | 2 |
| self-deriving-release-sync | phase2 | ~2 | 2 |
| tad-lean-trustworthy | phase1 | ~5 | 1 |
| tad-lean-trustworthy | phase2 | ~3 | 0 |
| tad-lean-trustworthy | phase3 | ~2 | 0 |
| tad-lean-trustworthy | phase4 | ~4 | 0 |
| tad-lean-trustworthy | phase5 | ~2 | 0 |
| debt-bundle | h1 | — | — |
| debt-bundle | h2 | — | — |

### Token consumption data

**Trace JSONL files: 0 lines.** No quantitative token data exists for any YOLO execution. We know YOLO runs many sub-agents per phase but have zero measurement of actual token cost per phase or per Epic.

### Verdict

**Blind spot confirmed.** YOLO has no cost observability. The value of adding phase-cost reporting is validated — currently flying blind on the highest-token-cost workflow TAD has.

---

## Measurement 3: Tournament — No Historical Data

TAD has never used competitive design exploration. Zero Playground sessions with multiple competing approaches exist. **Cannot measure — needs experiment.**

---

## Measurement 4: Quarantine — Zero Injection/Contamination Incidents

**Grep across 25 incidents:** 0 incidents reference injection, contamination, untrusted content, or prompt injection from external sources.

**Current mitigations already in place:**
- NotebookLM CLI isolates external URL content from Alex's prompt context
- Human handoff review breaks any injection chain between research and implementation

### Verdict

**Not urgent for current TAD use case (framework dev tool).** Becomes relevant when TAD processes genuinely untrusted content in non-dev scenarios without human checkpoint.

---

## Summary Decision Table

| Pattern | Measurement Result | Problem Real? | Next Step |
|---|---|---|---|
| Rule Adherence | 2 incidents: reviewer expertise gap + linter false-negative | YES | Design per-AC verifier experiment |
| Tournament | No data (TAD never did competitive exploration) | UNKNOWN | Design experiment to test value |
| Quarantine | 0 incidents, mitigations exist | NOT YET | Document pattern for future non-dev |
| Token Budget | 0 token data in traces, YOLO cost invisible | YES (blind spot) | Add phase-cost observation |

## User Direction (2026-06-03)

User's priority differs from workflow research recommendation:
- **Tournament: user sees high value** (workflow ranked it #4/defer — user wants to experiment)
- **Rule Adherence: user agrees it's worth pursuing** (workflow ranked it #3/measure-first — measurement confirms problem exists)
- Quarantine and Token Budget: user unsure but open

Next: design Tournament experiment, then Rule Adherence adaptation.
