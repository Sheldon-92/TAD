# Capability Builder Phase 1 — Alex Design Code Review

**Model provenance:** GPT-5 / Codex subagent; read-only review; route limited to the Phase 1 design and specified implementation surfaces.  
**Verdict:** CONDITIONAL PASS  
**P0:** none

## Findings and Resolution

| Severity | Finding | Resolution |
|---|---|---|
| P1 | Behavioral evidence lacked canonical prompt, invocation/model/state provenance, and hashes. | Design §6 and handoff FR6/§4.6/AC5 now require a byte-identical prompt plus a run manifest and reconciled hashes. |
| P1 | Projection API accepted arbitrary source/target paths and did not reject symlink traversal. | Design §5 C4 and handoff §4.3 derive paired paths from project-root + name and add traversal/symlink negative cases. |
| P1 | Existing legacy-pack maintenance behavior was unspecified after replacing `capability-upgrade`. | Design §5 C3 and handoff FR7/§4.2 require a no-write `LEGACY_PACK_OUT_OF_SCOPE` stop. |
| P2 | `skill:` + `pack:` ambiguity was prose-only. | Runner contract and AC4 require deterministic bad-fixture SKIP. |
| P2 | Generic TODO/TBD scan across all resources would reject legitimate content. | Validation checks deliberate scaffold markers in `SKILL.md` only. |

No implementation code was produced by this review.

## Handoff Draft Review

**Verdict:** CONDITIONAL PASS  
**P0:** none

| Severity | Finding | Resolution |
|---|---|---|
| P1 | Commit-only scope proof could miss an unstaged protected-file edit in the known dirty worktree. | Handoff §6.2/AC10 now require start/end protected content manifests in addition to the explicit task commit. |
| P1 | Failure tests did not prove temporary-sibling cleanup. | Handoff §4.3/§8.1/AC3 now require parent inventory equality and zero helper temp residue. |
| P1 | Legacy regression fixture was not pinned and could be a SKIP-only baseline. | Handoff §8.2 pins the academic-research systematic-review fixture and requires a non-SKIP frozen verdict with advisory exit 0. |
| P2 | Distinct helper error classes and `--help` were absent from the detailed contract. | Handoff §4.3/§8.1/AC3 restore and test documented error classes. |
