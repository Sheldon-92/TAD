# EPHEMERAL Epic: Pack Behavioral Examples Scaffold

> Surplus-generated ephemeral Epic. Single phase, auto-executed.
> Authorization: HUMAN-AUTHORIZED 2026-07-05 via *surplus review.

## Goal

Close the "validation theater" P0 from the cross-model YOLO audit (Codex + Gemini,
codified in principles.md / YOLO Audit Findings): "13/13 installed" confirms file
operations, not behavioral quality. Apply the proven html-anything `examples/`
pattern — each pack ships ground-truth input/output fixtures — so pack quality
becomes mechanically checkable instead of presence-only.

## Source

- IDEA-20260527-pack-behavioral-examples (promoted but absent from backlog)
- O2/KR1 behavioral eval upgrade direction (rank #3, 2026-05-14 prioritization matrix)
- html-anything example.html ground-truth fixture pattern (proven evidence)

## Phase 1/1: examples-scaffold-and-eval

**Scope (one line):** Add 2 input/expected fixture pairs to `examples/fixtures/` in 3
pilot packs (ai-agent-architecture, web-frontend, code-security), ship
`.tad/hooks/lib/pack-eval.sh` that validates fixture structure and checks candidate
outputs against expected markers, and add the Gate 3 checklist item
"examples/ present and passing pack-eval.sh" for new packs in gate/SKILL.md.

**Out of scope:** Rolling fixtures out to the other 21 packs; wiring pack-eval.sh
into release-verify.sh; live agent-execution eval (fixtures are marker-checked,
not agent-replayed).

**Status:** Active
**Handoff:** .tad/active/handoffs/HANDOFF-surplus-pack-behavioral-examples-scaffold.md
