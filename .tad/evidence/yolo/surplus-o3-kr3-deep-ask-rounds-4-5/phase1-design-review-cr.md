# Phase 1 Design Review — code-reviewer lens
**Handoff:** HANDOFF-surplus-o3-kr3-deep-ask-rounds-4-5.md
**Reviewer:** code-reviewer (design/AC-verifiability lens)
**Date:** 2026-07-05
**Verdict:** CONDITIONAL PASS — 0 P0, 2 P1, 4 P2. No blockers; recommend integrating the two P1 clarifications before Blake starts so Gate 3 doesn't hinge on Blake inferring undeclared format tokens.

---

## Verification performed (claims cross-checked against source, not taken on trust)

| Handoff claim | Check | Result |
|---|---|---|
| Notebook id `37cfefa5-…`, 45 sources, dormant, 3 rounds | `REGISTRY.yaml` L54-62 | ✅ exact match |
| `active_notebook = agent-computer-control` (so `-n` mandatory) | `REGISTRY.yaml` L7 | ✅ confirmed — the §10.1 warning is well-grounded |
| Skill `ask` sub-command + `-n`/`--notebook` flag | `SKILL.md` ~L270 | ✅ both `--notebook` and `-n` are valid |
| Preflight auth check command | `SKILL.md` L36-54 | ✅ matches micro-task 1 |
| OBJECTIVES O1/KR3 (L17) + O3/KR3 (L47) | `OBJECTIVES.md` | ✅ text + status 🔄 match |
| All §9.1 greps run under BSD grep (`\|`→`|`, `^### SP[0-9]+`, `Severity:`, round literal) | dry-run on synthetic sample | ✅ all produce expected counts |

The factual/toolchain foundation is solid. Findings below are about requirement↔AC coherence, not correctness of the grounding.

---

## P1 — should fix before Blake starts

### P1-1 — The KR's *defining* property (cross-source, ≥2 sources per SP) is NOT mechanically verified
- **Where:** FR3 point 2 mandates each synthesis point "synthesize across **≥2 sources** (name them)". AC3 only checks `count(^Sources:) ≥ count(^### SP)` — i.e. that *a* `Sources:` line exists per SP. A SP that cites a single source passes AC3.
- **Why it matters:** O3/KR3 is literally *"Cross-source synthesis findings documented."* The one property that distinguishes this deliverable from single-source summarization is the ≥2-source join, and it is the one thing the checklist never asserts. A file that technically passes AC1-AC8 could contain zero genuine cross-source synthesis. This is the exact "validation theater / structural-check-not-quality" failure the project's own principles.md (YOLO Cross-Model Audit 2026-05-15) calls out.
- **Fix:** Either (a) add an AC that asserts each `Sources:` line names ≥2 identifiers (e.g. checks for a delimiter: `awk -F',|;| and ' '/^Sources:/{...}` ≥2 tokens), or (b) explicitly route "≥2 real sources per SP" to the Conductor review step / Gate 4 as a named judgment check, and say so in §9.1 so it isn't silently dropped.

### P1-2 — AC8 requires a literal `Severity:` token that FR3 and the §4.3 data model never mandate
- **Where:** AC8 greps `^…Severity: (High|Medium|Low)`. But FR3 point 3 only says "severity assessment (High/Medium/Low) with rationale", and §4.3 "Machine-checkable invariants" lists the four H2s, SP count, Sources count, round literal, notebook id — **not** the `Severity:` token.
- **Why it matters:** A Blake who implements FR3 faithfully may write "This gap is **High** severity because…" or "Severity assessment: High" and fail AC8's exact-token grep. The requirement layer and the verification layer disagree on the artifact's shape. (Mitigated because §9.1 is declared the "PRIMARY VERIFICATION SOURCE" so Blake will likely read AC8 and comply — but relying on Blake reverse-engineering format from the grep is fragile design.)
- **Fix:** Add to FR3 point 3 / §4.3 the exact required line, e.g. "each TAD Implications section MUST contain a line `Severity: <High|Medium|Low>`". One sentence closes the gap.

---

## P2 — nice to have

### P2-1 — AC7 scope check is not mechanically decidable as written
- `git status --porcelain` (the verification method) will already show untracked noise unrelated to Blake's work: `.tad/evidence/traces/2026-07-04.jsonl` (present at repo start), this very review dir `.tad/evidence/yolo/surplus-o3-kr3-…/`, and `.tad/active/SURPLUS-PLAN-2026-07-05.md`. The AC's "limited to {2 findings + REGISTRY + epic/handoff/completion}" is a human judgment over that output, not a PASS/FAIL command. Suggest scoping to Blake's expected paths, e.g. `git status --porcelain | grep -vE '<allowed-prefixes>'` should be empty, so Gate 3 gets a clean boolean.

### P2-2 — Skill Step 2b auto-refresh can mutate REGISTRY.yaml beyond `last_queried`
- `SKILL.md` Step 2b (auto-refresh stale sources) runs `source list` and may re-sync sources; since the notebook is dormant/`last_refreshed` likely absent, the bootstrap path fires. This can touch `source_count` / source entries, not just `last_queried`. NFR1's exemption names only `last_queried`+`notes`. Recommend broadening the NFR1 exemption to "any REGISTRY.yaml mutation performed by the skill's own ask/refresh bookkeeping" and having AC7 anticipate it, so a legitimate source-refresh doesn't read as scope violation.

### P2-3 — AC6 hard-codes retrieval date `2026-07-05`
- If the ask actually executes on 2026-07-06 (task is queued, est 30 min but could slip), a truthful Provenance date fails AC6 — pressuring Blake to write a false date to pass the grep. Prefer "retrieval date = the actual ask date; AC6 confirms the Provenance date matches the date the ask ran" rather than a frozen literal. Low probability given same-day intent; flagging because it pits AC-passing against honesty.

### P2-4 — `gate4_delta: []` empty despite a real Gate 4 human decision
- §6/§9 define a genuine Gate 4 human-domain question (severity acceptance → O3/KR3 flip). Frontmatter `gate4_delta: []` is defensible for a no-code task but under-records the one acceptance item. Consider listing the severity-acceptance + OBJECTIVES status-flip as the Gate 4 delta for auditability.

---

## What is correct and should be preserved
- Frontmatter is right for a research deliverable: `task_type: research`, `e2e_required: no`, `research_required: yes`, `skip_knowledge_assessment: no`. `git_tracked_dirs: []` is consistent with doc-only output into an already-tracked dir.
- The web-search / deep-research prohibition (§10.1, NFR1, §8.4) is correctly and repeatedly anchored, matching CLAUDE.md §2 research-tool-exclusion.
- honest-partial (NFR2) is correctly wired into §8.4 friction preflight and the completion-evidence list — the design does not force fabrication when coverage is thin.
- The `-n` mandatory-flag warning is load-bearing and verified against `active_notebook`.
- File list is complete for the deliverables (2 create + REGISTRY auto-touch). No missing target files.

## Bottom line
Ship after integrating P1-1 and P1-2 (two-sentence additions). The design is coherent and well-grounded; the only substantive risk is that the checklist can go green without the cross-source synthesis that is the KR's entire point (P1-1).
