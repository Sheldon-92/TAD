# Code Review: LDR POC Phase 1 — Gate 4 Rework (Library-scoped supplemental round)

**Reviewer**: code-reviewer
**Date**: 2026-07-02
**Scope**: POC-REPORT.md (updated), ab-judge-verdict-lib.md, ab-judge-input-manifest-lib.txt, ab-mapping-lib.md, .mcp.json, lib answer files
**Handoff reference**: HANDOFF-20260701-ldr-poc-phase1.md (sections 6, 9)

---

## Summary

The Gate 4 rework adds a Library-scoped supplemental A/B round that directly addresses the gap Alex identified during Gate 4: Blake's Round 1 tested only `quick_research` (open web mode), while the decisive Library-scoped mode (via `search_tool=collection_{id}`) was never tested. Round 2 corrects this. The updated POC report integrates both rounds, updates the Root Cause Analysis, and recalculates Gate-A using the Library-scoped numbers. The work is sound — no critical or important issues found.

---

## Verification Results (Mechanical)

| Check | Command | Result |
|-------|---------|--------|
| R11 Verdict line | `grep -cE '^Verdict: (PASS\|FAIL)$'` | 1 = V-OK |
| R11 Gate-A line | `grep -cE '^Gate-A citation-resolution: [0-9]+%...'` | 1 = GA-OK |
| R11 Gate-B line | `grep -cE '^Gate-B MCP chain: (PASS\|FAIL)$'` | 1 = GB-OK |
| R9 Verdict rows | `grep -c 'System [AB]'` on verdict-lib.md | 27 (>>6, per-citation detail) |
| R10 Manifest isolation | `grep -c 'mapping'` on manifest-lib.txt | 0 (mapping excluded) |
| R10 Manifest exists | `test -s` | MANIFEST-OK |
| Sanitization | `grep -rliE 'NotebookLM\|Local Deep Research'` on lib answer files | 0 hits (clean) |
| Secret scan (R14-scope) | sk-ant/sk-or/Bearer/api_key patterns on 5 new/modified files | 0 hits (scan-exit=1) |

All mechanical checks PASS.

---

## Independent Recompute: Gate-A Pooled Citation-Resolution

**Mapping** (ab-mapping-lib.md):
- Q1: System A = ldr-lib, System B = nbm
- Q2: System A = nbm, System B = ldr-lib
- Q3: System A = ldr-lib, System B = nbm

**Applied to judge verdict** (ab-judge-verdict-lib.md):

| Question | LDR-lib resolved/total | NotebookLM resolved/total |
|----------|----------------------|--------------------------|
| Q1 | 1/4 (System A) | 0/4 (System B) |
| Q2 | 2/4 (System B) | 0/25 (System A) |
| Q3 | 0/5 (System A) | 2/22 (System B) |
| **Pooled** | **(1+2+0)/(4+4+5) = 3/13 = 23.1%** | (0+0+2)/(4+25+22) = 2/51 = 3.9% |

**POC report states**: "LDR pooled = 3/13 = 23%" -- CORRECT (truncated from 23.08%).
**Zero-citation rule**: LDR has 4, 4, 5 citations per question -- all >= 1, rule not triggered.
**Gate-A verdict**: 23% < 80% threshold -- FAIL is correct.

---

## A/B Protocol Validity (Supplemental Round)

| Protocol element | Round 1 | Round 2 (lib) | Consistency |
|-----------------|---------|---------------|-------------|
| Source set | 5 MCP sources | Same 5 (manifest confirms) | OK |
| Questions | 3 fixed | Same 3 (manifest confirms) | OK |
| Separate judge | Yes | Yes (POC report: "separate judges per round") | OK |
| Separate mapping | ab-mapping.md (N,L,N) | ab-mapping-lib.md (L,N,L) | Different patterns |
| Separate manifest | ab-judge-input-manifest.txt | ab-judge-input-manifest-lib.txt | OK |
| Mapping excluded from judge input | Confirmed | Confirmed (grep=0) | OK |
| System identity sanitized | Checked | Checked (grep=0 hits) | OK |
| Separate raw answer files | ldr-q{1..3}-raw.md | ldr-lib-q{1..3}-raw.md | OK |
| Separate anonymized files | q{1..3}-system{A,B}.md | lib-q{1..3}-system{A,B}.md | OK |

The supplemental round follows the same blind isolation standards as Round 1.

---

## Root Cause Analysis Review

The updated Root Cause Analysis correctly:

1. **Acknowledges the Gate 4 finding**: "Blake's initial root cause ('no Library-scoped API') was wrong" -- honest correction.
2. **Identifies the actual limitation**: LLM synthesis step does not constrain citations to collection sources, even in Library-scoped mode.
3. **Separates architectural from model-specific factors**: qwen3.7-max language/format behavior vs LDR citation-constraint architecture.
4. **Notes NotebookLM's poor performance too**: 4% pooled, driven by CLI format omitting URL bibliographies -- fair observation that reduces the baseline's discriminative usefulness.
5. **Correctly frames Phase 2 implications**: LLM swap test + citation format enforcement, neither guaranteed to reach 80%.

---

## .mcp.json Review

- STDIO-only configuration (no `url` field) -- compliant
- API key via `${LDR_API_KEY}` environment variable reference -- no literal secret
- Data directory points to repo-external `~/.tad-ldr-data` -- compliant
- Host binding: `127.0.0.1` -- loopback only
- Absolute path to venv binary -- correct for STDIO MCP

---

## Findings

### P0 (Critical): None

### P1 (Important): None

### P2 (Suggestions)

**P2-1: Round 2 mapping is exact complement of Round 1**
Round 1: (N, L, N); Round 2: (L, N, L). Exact complement has 12.5% probability with 3 binary choices -- within normal variance and does not violate the randomness requirement. Neither pattern is predictable (not all-same or strictly alternating). No action needed.

**P2-2: Evidence tree listing shows .mcp.json inside ldr-poc/ tree**
POC-REPORT.md line 151 lists `.mcp.json (repo root, project-scoped STDIO registration)` as the last entry in the `ldr-poc/` directory tree. The parenthetical annotation clarifies its actual location, but the visual tree structure could mislead a fast reader. Cosmetic only.

**P2-3: NotebookLM baseline scored lower than LDR in Round 2**
NotebookLM pooled = 4% vs LDR pooled = 23%. The "baseline" system scored worse than the test system, which is an unusual A/B outcome. The report correctly explains this (NotebookLM CLI omits URL reference lists), but it means neither system produced a strong citation-resolution score. The discriminative power of this round is limited -- both systems FAIL the 80% bar by a wide margin, which actually makes the FAIL verdict more robust (it's not a close call).

---

## Positive Observations

1. **Honest correction of prior error**: The Root Cause Analysis explicitly states "Blake's initial root cause was wrong" rather than rationalizing. This is exactly the right epistemic posture for a POC.

2. **Per-citation traceability**: The judge verdict contains 27 "System [AB]" entries -- far beyond the minimum 6 rows. Every citation is individually traced to a ground truth source with explicit resolved/unresolved reasoning. This is exemplary evidence quality.

3. **Content accuracy finding is valuable**: Both systems achieved 100% content accuracy with 0 hallucinated citations. The 23% citation-resolution score is a format/traceability gap, not a factual accuracy gap. This nuance is critical for Phase 2 decision-making and is clearly communicated.

4. **Cost well within budget**: < $0.10 actual vs $2 NFR1 ceiling.

---

## Verdict

**PASS**

The Gate 4 rework is complete and correct. The Library-scoped supplemental round follows identical blind isolation standards, the pooled computation (3/13 = 23%) is independently verified, the three verdict lines are format-compliant per R11, and no secrets are present in any new file. The updated Root Cause Analysis accurately reflects what changed vs Round 1. The POC report is ready for Gate 4 acceptance.
