# Trajectory Evaluation Rubric

> Phase 1 of Trajectory Eval Harness — scoring dimensions for TAD execution quality.
> Each dimension is 1-5 with anchored rigor descriptions.
> Anchors describe EVIDENCE DEPTH/COVERAGE (rigor), not conclusion direction.
> DRAFT — labels require human confirmation at Gate 4.
>
> **D1/D2 boundary**: D1 assesses whether AC STATUS was TRACKED AND REPORTED (in completion report tables or narrative), regardless of separate evidence files. D2 assesses whether INDEPENDENT EVIDENCE ARTIFACTS (review files, acceptance-test dirs, trace events) exist on disk to corroborate those claims. A trajectory can score D1=5 (all ACs tracked with output in completion) but D2=1 (zero on-disk carrier files). See GS-09 (D1=5, D2=3) and GS-10 (D1=3, D2=1) for examples.

---

### D1: Specification Alignment
> Grounding: gate-canonical-checklist.md Gate 3 "§9.1 Spec Compliance — every row verified"
> Data source: Handoff §9.1 AC table (if present) + Completion report AC claim status + artifact-level inspection of deliverables vs handoff requirements

- **1**: No completion report or AC tracking; deliverables cannot be mapped to handoff requirements; no evidence of requirement-aware implementation
- **2**: Completion exists but AC status is bulk-claimed ("all done") without per-AC breakdown; or ≥2 ACs have no corresponding artifact
- **3**: Per-AC status reported in completion; most ACs have corresponding artifacts, but ≥1 AC's verification command was not actually run or output not recorded
- **4**: All ACs individually tracked with verification output recorded; at most 1 minor gap between claimed status and artifact state
- **5**: All ACs individually verified with recorded command output matching expected values; deviations (if any) explicitly documented with rationale; §9.1 table fully populated

### D2: Verification Rigor
> Grounding: gate-canonical-checklist.md Gate 3 "Evidence files exist — per handoff manifest" + Gate 4 "Quality evidence complete"
> Data source: .tad/evidence/reviews/blake/{slug}/ files (existence + content depth) + .tad/evidence/acceptance-tests/{slug}/ + trace events (gate_result, expert_review_finding types) + completion report verification claims

- **1**: Zero carrier files for verification claims; review may have happened in conversation but left no on-disk artifact; no acceptance tests or trace events
- **2**: ≤1 review file exists but contains generic/boilerplate content (no specific P0/P1 findings); or review file exists but is self-review only (no independent perspective)
- **3**: ≥2 distinct reviewer files exist with some specific findings; but at least one claimed verification outcome is not supported by on-disk evidence (e.g., "security review passed" with no security-auditor file)
- **4**: Review files from ≥2 distinct independent reviewers with specific, actionable findings (P0/P1 enumerated); acceptance-test or trace evidence corroborates review claims
- **5**: Complete evidence chain: ≥2 distinct reviewer files with specific findings + acceptance-test artifacts + trace events with gate_result; any discrepancy between review claims and actual outcomes is reconciled in evidence

### D3: Process Discipline
> Grounding: gate-canonical-checklist.md Gate 2 "Expert review complete (min 2)" + Gate 3 "Code/deliverable complete — all handoff tasks done" + Gate 3 "Git commit done"
> Data source: Completion report process narrative + handoff §9.2 Audit Trail + git log for commit timing + evidence of Layer 1/Layer 2 sequence

- **1**: Implementation started without reading handoff (no evidence of handoff acknowledgment); or significant process steps provably skipped (no Layer 2 at all when required); or implementation without handoff
- **2**: Handoff was read but evidence shows process shortcuts: Layer 2 skipped or self-substituted; or completion report written before implementation finished; or forbidden actions in §10 violated
- **3**: Core process steps followed (handoff read, implementation done, completion written); minor sequence violations (e.g., Layer 2 experts invoked but not in correct priority group order); or one required step done informally
- **4**: All required process steps followed in correct order; Layer 1 before Layer 2; handoff context refresh documented; at most 1 minor process informality
- **5**: Full Ralph Loop followed with documented state: Layer 1 checks enumerated, Layer 2 groups executed in priority order, circuit breaker/escalation thresholds respected; git commit with evidence path check before Gate 3

### D4: Deviation Transparency
> Grounding: gate-canonical-checklist.md Gate 4 "Functional acceptance — §9 AC met AND no open post-implementation blockers (list any)" + honest_partial_protocol
> Data source: Completion report deviations/notes section + gate4_delta field + honest_partial reports + Friction Status table (if present, post-2026-06-10)

- **1**: Completion report omits known deviations; or gate4_delta discrepancies exist that completion did not mention; or issues discovered post-Gate that completion should have flagged
- **2**: Deviations acknowledged but minimized ("minor adjustments") without specifics; or implementation decisions made during execution not documented; or escalation events occurred but not recorded
- **3**: Deviations listed with brief description; implementation decisions documented; but at least one deviation lacks rationale or impact assessment
- **4**: All deviations documented with rationale and impact; implementation decisions include options considered; gate4_delta empty or explicitly accounted for
- **5**: Complete transparency: all deviations documented with rationale, impact, and resolution; honest_partial used when appropriate; Friction Status table present with accurate status for each friction point; zero undisclosed surprises at Gate 4

### D5: Knowledge Capture
> Grounding: gate-canonical-checklist.md Gate 3 "Knowledge Assessment complete — journal or 'no discovery'" + Gate 4 "Knowledge Assessment complete — distillation loop or 'no new discovery'"
> Data source: Completion report KA section (Q1/Q2/Q3 answers) + journal entries in evidence/journal/ + project-knowledge/ updates (if any) + skillify candidate (if generated)

- **1**: No KA section in completion; or KA section exists but all questions unanswered/blank; no evidence of reflection on the execution experience
- **2**: KA section exists with "No" answers but no rationale; or KA filled with generic boilerplate that could apply to any task ("followed the process, no issues")
- **3**: KA answered with task-specific content; Q1 answered with at least one concrete discovery or explicit "no discovery" with specific reasoning; Q2/Q3 addressed
- **4**: KA with concrete, reusable discovery documented; journal entry created with specific artifact references; discovery is variabilizable (not episode-specific)
- **5**: KA yielded actionable knowledge that was or could be promoted to project-knowledge patterns; discovery includes failure_mode; journal entry references specific artifacts and commit hashes; skillify candidate evaluated (if applicable)
