# EPHEMERAL Epic: gate-roi-measurement

> Ephemeral surplus Epic — single phase, auto-executed, archive on completion.
> [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved this needs-you task via *surplus review.]

## Goal

Prove or falsify TAD's core quality claim. The 2026-06-09 repositioning stress-test (O1/KR2)
named "gate-ROI unproven" as an explicit gap: TAD positions itself as a quality framework,
but no measurement exists that Gates catch real defects. Analyze ≥20 historical handoffs
(gate events from `.tad/evidence/traces/*.jsonl` + archived COMPLETION/gate reports in
`.tad/archive/handoffs/`) to classify Gate-caught defects by severity and counterfactual
impact, then issue a verdict: gates net-positive / net-neutral / net-negative vs a
no-gate baseline.

## Ground Truth (2026-07-05)

- `.tad/evidence/traces/` = 57 daily jsonl files with `handoff_created` / gate-related events.
- `.tad/archive/handoffs/` = 486 files, including 184 `COMPLETION-*` reports (P0/P1 fix logs,
  gate outcomes) — the defect CONTENT lives here; traces provide the event timeline.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | measure-and-verdict | Active |

## Phase 1 Scope

- Sample ≥20 handoffs that went through Gate 3 and/or Gate 4 (evidence-backed, not recalled).
- Classify each Gate-caught defect: severity (P0/P1/P2), gate that caught it, counterfactual
  impact if shipped (broken-ship / silent-degradation / cosmetic / none).
- Compute the verdict + go/no-go recommendation on investing in mechanical gate enforcement.
- Single deliverable: `.tad/evidence/research/gate-roi-measurement-2026-07.md`.

## Out of Scope

- Changing any gate protocol, SKILL, or hook code.
- Re-running historical gates; this is archival analysis only.

## Handoff

`.tad/active/handoffs/HANDOFF-surplus-gate-roi-measurement.md`
