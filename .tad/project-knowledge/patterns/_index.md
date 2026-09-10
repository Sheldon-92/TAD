# Knowledge Patterns Index (Layer 2)

> One-line summary per pattern file. Blake's 1_5_context_refresh matches task keywords
> against this index, then loads only the matched pattern files.
> Format: `- [title](filename.md) — one-line hook (max 120 chars)`

---

- [Gate Design](gate-design.md) — Gate responsibility, honest_partial, verification integrity, claims-need-carriers, expert review, YOLO mode, rubric gates, quality gate, Gate 3, Gate 4, blocking, PASS/FAIL
- [Handoff Design](handoff-design.md) — Protocol state machines, lifecycle, scope estimation, worktree grounding, registry state, handoff creation, Epic phase, express, archive, completion report
- [Shell Portability](shell-portability.md) — macOS/BSD compat, grep/awk/jq patterns, heredoc security, CJK locale, env-var convention, bash script, sed, comm, sort, diff, md5
- [AC Verification](ac-verification.md) — AC design, dry-run, extraction-boundary invariants, behavioral fixtures, self-leak prevention, verification commands
- [Capability Ownership](capability-ownership.md) — Internalized capability vs hidden runtime dependency; require positive behavior plus absence proof
- [Hook Contracts](hook-contracts.md) — Hook events, sub-agent safety classifier, array membership, router.log output contract, PreToolUse, PostToolUse, SessionStart, settings.json
- [Pack Build Rules](pack-build-rules.md) — Pack architecture, pointer default, freeze skip, escalate gates, status durable, skill-vs-MCP boundary
- [Pack Evaluation](pack-evaluation.md) — Anti-slop metrics, cross-model review, discriminative behavioral eval gates, dogfood, blind A/B, pack quality, WebSearch fact-check
- [Research Methodology](research-methodology.md) — Local Wiki primary, NotebookLM fallback, cross-model orchestration, source quality, deep research, *research
- [Memory and Learning](memory-and-learning.md) — Staleness detection, compact recovery, trace emission, parser value propagation, knowledge assessment, journal, distillation, reflexion
- [Release & Sync](release-sync.md) — Mirror/parity hazards, gitignore semantics don't survive mirroring, --fix exclusion sets, deny-list at every granularity, privacy leak, parity, rsync
