# Capability Builder Phase 1 — Alex Design Architecture Review

**Model provenance:** harness=codex; model=GPT-5 (self-reported); route=unknown.  
**Verdict:** CONDITIONAL PASS  
**P0:** none

## Findings and Resolution

| Severity | Finding | Resolution |
|---|---|---|
| P1 | A `skill:` fixture without `## Verification Command` would SKIP before the discriminative assertion. | Design §5 C5 and handoff §4.5 require the compatible section; missing section is an invalid fixture and cannot satisfy behavior AC. |
| P1 | Dual `skill:`/`pack:` fields lacked runner-layer defense. | Runner contract and AC4 require mechanical conflict detection and bad-fixture SKIP. |
| P2 | Arbitrary projection paths and symlink semantics were underspecified. | Project-root/name paired API, containment rules, and symlink negative cases were added. |

The reviewer found no TAD-core boundary violation: Evolve, Plugin, DSH, retirement, `tad.sh`, roles, Gates, and legacy pack content remain outside Phase 1.

## Handoff Draft Review

**Verdict:** CONDITIONAL PASS  
**P0:** none

| Severity | Finding | Resolution |
|---|---|---|
| P1 | First projection in a Codex-only project did not define absent `.claude/skills` behavior. | Handoff §4.3 and §8.1 permit safe parent creation after containment checks and require cleanup on failure. |
| P1 | Preserving legacy deep-research content intact was not acceptance-enforced. | Handoff §6.1 and AC6 require pre-change SHA-256 equality with the preserved reference. |
| P2 | Global parity repair could be mistaken for project reverse projection. | Handoff §4.6 states only the new helper owns `.agents → .claude`; release verifier remains untouched. |
