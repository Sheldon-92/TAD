# TAD Value Proposition

> What TAD has actually delivered, with every claim tied to an on-disk artifact
> you can open and verify. No claim in this document rests on intent alone —
> if a path is cited, the artifact exists in this repository.

---

## The Claim

TAD is a **capability acquisition methodology**: a repeatable way for one human,
working with AI agents and a set of persistent documents (handoffs,
project-knowledge, capability packs, research notebooks), to acquire and compound
working capability in domains they did not previously have.

The mechanism, deflated:

1. **Two agents with enforced separation** — Alex designs, Blake implements, the
   human is the only bridge. The separation exists so that no single context
   reviews its own work.
2. **Persistent documents as the unit of capability** — every task leaves behind
   artifacts (handoff, completion report, distilled knowledge entry) that the next
   task builds on. Capability lives in the documents, not in any one session's
   memory.
3. **Evidence-gated acceptance** — four gates require runnable verification
   commands, not self-assessment. Claims that cannot cite a carrier are downgraded
   or deleted.

The compounding effect is the point: each project completed through TAD makes the
next project in that domain (or an adjacent one) cheaper, because the distilled
knowledge, packs, and research notebooks persist.

## The Evidence

Each entry follows the shape: domain — one-line outcome — on-disk path. Every path
below was verified with `test -e` at the repository root on 2026-07-05.

1. **Cross-domain adoption (breadth)** — 14 downstream projects are registered
   consumers of TAD, spanning food apps, agent labs, fitness tracking, voice
   production, and more. The registry is the live sync target list, not a
   marketing count: `.tad/sync-registry.yaml` (14 registered project entries).

2. **AI voice production (non-code domain)** — a full judgment pack for TTS tool
   selection, voice cloning, audiobook/podcast/dubbing pipelines, distilled from
   real production iterations: `.claude/skills/ai-voice-production/SKILL.md`.

3. **AI podcast production (non-code domain)** — script writing, large-chunk TTS,
   dual-BGM arrangement with envelope-follower ducking, show notes — production
   judgment captured as a reusable pack:
   `.claude/skills/ai-podcast-production/SKILL.md`.

4. **Reading companion (consumer product, stdlib-only)** — EPUB to annotatable
   HTML reading surface with durable highlights that survive regeneration, built
   and reviewed through a 4-phase TAD Epic:
   `.claude/skills/reading-companion/SKILL.md`.

5. **Academic research (non-dev domain)** — PRISMA systematic reviews, citation
   integrity, and literature evaluation methodology, ported and piloted on a real
   study: `.claude/skills/academic-research/SKILL.md`.

6. **Capability pack library (scale)** — 24+ research-grounded capability packs
   (RAG, guardrails, observability, data engineering, ML training, video, and
   more), each built through a plan/upgrade/eval/review pipeline with adversarial
   review: `.claude/skills/` (browse the directory; each pack is a SKILL.md with
   references).

7. **Knowledge compounding (the mechanism itself, working)** — 15 distilled
   methodology principles, each with context, discovery, action, and a required
   failure_mode field, accumulated across epics and audited by humans:
   `.tad/project-knowledge/principles.md`.

8. **Persistent research knowledge base** — source-grounded research findings that
   later work builds on, e.g. the agent-memory-systems study that drove the
   knowledge-recording redesign:
   `.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md`, and
   the wider persistent store at `.tad/evidence/research/` including the
   2026-06-09 repositioning stress-test
   (`.tad/evidence/research/repositioning-3-walls/2026-06-09-ask-findings.md`)
   that adversarially challenged TAD's own differentiators.

What the evidence does NOT show, stated plainly: no multi-user deployment, no
third-party adoption beyond this operator's 14 projects, and no controlled
comparison against alternative methodologies. Those remain directions, not facts.

## What TAD Is Not

- **Not an autonomous coding agent.** TAD does not compete with Devin,
  OpenHands, or Cursor-class products whose pitch is "give the AI a goal, it
  ships the code." TAD's philosophy section argues the opposite: human
  checkpoints become more valuable as AI gets stronger.
- **Not an agent orchestration framework.** TAD is not a LangGraph, CrewAI, or
  AutoGen alternative. It ships no runtime, no graph engine, no message bus. Its
  "infrastructure" is markdown documents, quality gates, and two agent roles.
- **Not limited to software development.** The dev workflow is where TAD started
  and is still the most exercised path, but the evidence above shows the same
  loop producing voice production pipelines, podcast episodes, reading tools,
  and academic research methodology.
- **Not a marketing claim of generality.** Where evidence is single-project or
  single-operator, this document says so.

## Who It Is For

- **A single human who wants to operate beyond their trained domain** — the
  displaced-expert profile: someone with judgment and taste who uses TAD to
  acquire working capability in domains where they lack hands-on training.
- **Agent builders who want compounding, not sessions** — people frustrated that
  each AI session starts from zero. TAD's persistent-document layer is the
  counter-design: handoffs, distilled principles, and packs carry capability
  forward.
- **Anyone who distrusts self-reviewed AI output** — the two-agent separation and
  evidence-gated acceptance exist precisely for users who have been burned by
  "all tests pass" claims.

It is NOT (yet) for teams: TAD is designed and validated as a single-operator
system. Multi-user enforcement was explicitly evaluated and rejected for this
deployment class (see the mechanical-enforcement entry in
`.tad/project-knowledge/principles.md`).
