# Roadmap

> Strategic direction for TAD. Updated 2026-09-02 for v2.43.0.
> See [PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md) for current state and
> [NEXT.md](./NEXT.md) for the tactical queue.

---

## Current direction

### Stable foundation

- **Full TAD is the default path.** Alex owns requirements and acceptance; Blake owns implementation and technical verification.
- **Codex is a first-class runtime.** Claude Code and Codex share the same durable `.tad/` project state and mirrored skills.
- **TAD Lite is frozen, not removed.** Existing Lite workflows remain available when explicitly invoked, but new framework work targets Full TAD.
- **Quality remains evidence-based.** Four gates, the Ralph Loop, independent review, and honest partial outcomes remain the default safeguards.

Primary references: [README](./README.md), [project context](./PROJECT_CONTEXT.md), [Gate protocol](./.agents/skills/gate/SKILL.md), and [Blake protocol](./.agents/skills/blake/SKILL.md).

### Recently delivered

| Capability | Status | Product boundary |
|---|---|---|
| YOLO 2.0 verified orchestration | Complete, opt-in | Codex fresh/resume is proven. Claude Code, OpenCode, and DeepSeek adapters are experimental and qualify on first real use. Default-on remains deferred. |
| Local Wiki research | Complete | File-is-truth research, stdlib FTS5 retrieval, and native rendered-page capture are accepted. Public YouTube captions remain experimental; Whisper/vector retrieval wait for measured need. |
| Capability Builder `create` | Phase 1 complete | Projects can create, validate, project, and behaviorally prove locally owned Agent Skills. Evolution and packaging remain separate phases. |
| v2.43.0 release | Published | Full-default framework release containing YOLO2, Local Wiki capture, and Capability Builder Phase 1. See [CHANGELOG](./CHANGELOG.md). |

## Active and parked work

### Capability Builder v1

**Status:** Phase 1 of 4 complete; later phases parked.

[Phase 1](./.tad/active/epics/EPIC-20260831-capability-builder-v1.md) delivered the independently useful `create` path. Phase 2 `evolve` starts only after a real failure, correction, regression, external change, or explicit new requirement. Phase 3 packaging and Phase 4 Voice Studio dogfood remain downstream of that signal-driven work.

### Framework health repair

**Status:** Active backlog; execute only from a current, explicitly accepted scope.

The repository still carries older framework-health follow-ups and verifier hygiene work. Before starting any item, revalidate it against current code because several historical “urgent” entries were already fixed when re-audited. The authoritative tactical queue is [NEXT.md](./NEXT.md).

## Revisit when evidence appears

- **YOLO2 default-on:** reconsider only after a new human-authorized real-work evaluation demonstrates enough reliability and acceptable cost.
- **Experimental harnesses:** qualify Claude Code, OpenCode, and DeepSeek with a minimal harmless probe on first actual use; one adapter failure must not block the verified Codex core.
- **Capability evolution:** add `evolve` only when a concrete regression fixture or explicit new requirement exists.
- **Local Wiki media retrieval:** add audio download/Whisper or persisted/vector retrieval only when current text and FTS5 paths show a measured gap.
- **Remaining capability-pack evals:** expand behavioral evaluation as real projects exercise the packs, rather than creating a speculative all-pack campaign.

## Maintenance rule

This file is a strategic view, not a historical ledger. Completed implementation detail belongs in [CHANGELOG.md](./CHANGELOG.md) and `PROJECT_CONTEXT.md`; actionable work belongs in `NEXT.md`. Keep links limited to files shipped in the public repository so the GitHub roadmap remains navigable.
