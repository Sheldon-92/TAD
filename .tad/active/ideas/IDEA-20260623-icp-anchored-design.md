# IDEA: ICP-Anchored Design in *design Flow

**Created**: 2026-06-23
**Source**: AI Tinkerers #32 — Inhabited-design by Shimin Zhang
**Status**: promoted
**Promoted To**: Epic phase (Community Pattern Adoption — 2026-06-23)
**Scope**: small (add step to *design protocol)

## What

Add an "Ideal Customer Profile" (ICP) definition step to TAD's *design flow. Before designing, explicitly define WHO the design is for — a specific named user persona with concrete context, not an abstract "user."

## Why

Inhabited-design's key insight: anchoring design to a specific named user prevents drift into "generic slop." The adversarial critique asks "would THIS person actually use this?" which is more concrete than TAD's current requirement elicitation (which asks "what do you need?" but not "who specifically are you?").

## How it might work

1. In *design protocol, after Socratic inquiry, add: "Define the ICP — who is the primary user? Name, role, context, what they care about"
2. ICP becomes a test anchor for design decisions: "Would [ICP name] understand/use/value this?"
3. For TAD itself: ICP = "Solo developer using Claude Code who builds AI agents and wants to ship faster without sacrificing quality"
4. Could integrate with Feedback Collector — the ICP informs what dimensions to evaluate

## Evidence

- Inhabited-design demo description in AI Tinkerers #32
- Shimin Zhang's claude_icp.md artifact (not publicly available but concept is clear)
- Decision brief: .tad/evidence/research/agent-orchestration-patterns/2026-06-23-decision-brief-community-orchestration.md

## Risk

- Adding another step to *design could slow down the flow
- For internal tools / framework work, ICP might feel forced
- Keep it lightweight: 2-3 sentences, not a full persona document
