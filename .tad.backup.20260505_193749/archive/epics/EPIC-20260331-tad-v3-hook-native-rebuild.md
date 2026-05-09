# Epic: TAD v3.0 — Hook-Native Architecture Rebuild

**Epic ID**: EPIC-20260331-tad-v3-hook-native-rebuild
**Created**: 2026-03-31
**Owner**: Alex

---

## Objective

Rebuild TAD from a prompt-engineering framework into a Claude Code native extension. Replace prompt-based constraints with Hook enforcement, decompose monolithic agent files into composable per-mode Skills, and shift mechanical work from LLM to framework layer (hooks, settings, shell scripts). This is the largest TAD upgrade since inception — a philosophical shift from "tell the model what to do" to "declare what should happen and let the framework enforce it."

## Success Criteria
- [ ] CLAUDE.md reduced to <50 lines (pure router, no rules)
- [ ] Alex split into 5+ independent Skills (per-mode: analyze, bug, discuss, idea, learn)
- [ ] Blake split into 2+ independent Skills (develop, release)
- [ ] ≥10 TAD rules enforced via Hooks (not prompt)
- [ ] PostToolUse hooks auto-execute ≥5 workflow side-effects (NEXT.md update, Linear sync, etc.)
- [ ] Startup time measurably faster (Hook-based health check vs in-context)
- [ ] Expert review runs in true parallel (multiple Agent calls in one message)
- [ ] Context footprint reduced ≥20% vs current TAD v2.6
- [ ] Full TAD workflow (analyze → handoff → develop → gate → accept) works end-to-end with new architecture
- [ ] No regression in existing TAD capabilities

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | Mechanism Spike | ✅ Done | HANDOFF-20260331-tad-v3-mechanism-spike.md | 5/7 mechanisms PASS + 3c deep test. Hooks = primary enforcement |
| 1 | Architecture Blueprint | ✅ Done | .tad/spike-v3/ARCHITECTURE-v3.md | 5-layer architecture, hook scripts, skill reduction plan (2528→800) |
| 2 | Hook Infrastructure | ✅ Done | HANDOFF-20260331-tad-v3-hook-infrastructure.md | settings.json native + 2 hooks + lib (74+54+46 lines) |
| 3 | Skill Decomposition | ✅ Done | HANDOFF-20260331-tad-v3-skill-decomposition.md | Alex 2528→570 (78%), Blake 1052→283 (73%). Judgment-only residual. |
| 4 | Quality & Performance | ✅ Done | HANDOFF-20260331-tad-v3-quality-performance.md | CLAUDE.md 155→69, PreToolUse hook, 76% context reduction |
| 5 | Integration & Validation | ✅ Done | HANDOFF-20260331-tad-v3-integration-validation.md | Version 2.6→2.7.0, CHANGELOG, 11 files updated, zero dangling refs |

### Phase Dependencies
- Phase 0 → Phase 1 (spike findings inform architecture design)
- Phase 1 → Phase 2, 3 (blueprint must be approved before implementation)
- Phase 2 → Phase 4 (hook infrastructure needed for quality hooks)
- Phase 3 → Phase 4 (skills must exist before adding advanced hooks)
- Phase 2 + 3 + 4 → Phase 5 (all implementation done before integration test)
- Phase 2 and Phase 3 are potentially parallel (independent deliverables)

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Context for Next Phase

### Research Findings (Pre-Epic)
Deep analysis of Claude Code leaked source (2026-03-31) revealed:
- **Hook system**: 26 events, 4 types (command/prompt/agent/http), can modify tool inputs, set permissions, inject context
- **Skill system**: `context: inline|fork`, `allowedTools`, `model` override, per-skill hooks in frontmatter
- **Context assembly**: CLAUDE.md wrapped in OVERRIDE instruction, cache boundary mechanism, 1% skill listing budget
- **Coordinator mode**: Parallel workers, task notifications, context inheritance via createSubagentContext()
- **Design philosophy**: Declarative > imperative, framework responsibility > model responsibility, composition > inheritance

### Key Design Principles for v3.0
1. **Declarative**: Rules declared in hooks/settings, not prompted
2. **Composable**: Per-mode skills with own hooks/tools, not monolithic agent files
3. **Framework-first**: Mechanical work in shell scripts/hooks, judgment work in LLM
4. **CLI-first tools**: Shell commands via BashTool default, MCP only for stateful/remote
5. **Intelligent gating**: Prompt hooks (Haiku) for context-aware permission decisions, not blanket allow/deny

### Completed Work Summary
- Phase 0: Mechanism Spike — 8 experiments. 5 mechanisms PASS, 2 FAIL. Hooks = primary enforcement.
- Phase 1: Architecture Blueprint — 5-layer design approved. Skills stay as 2, hooks do enforcement.
- Phase 2: Hook Infrastructure — settings.json native format, 2 hook scripts + 1 lib. AC 10/10 PASS.
- Phase 3: Skill Decomposition — Alex 2528→570 (78%), Blake 1052→283 (73%). Total 2727 lines removed.

### Decisions Made So Far
- Complete rebuild (not incremental) — user explicitly chose this
- Alex's "no code" rule is NOT a hard constraint — context-dependent (prompt hook, not allowedTools block)
- PostToolUse automation is higher priority than PreToolUse blocking
- CLI-first tool integration (MCP only when stateful/remote needed)
- **Hook event keys: PascalCase** (PostToolUse, PreToolUse, SessionStart)
- **additionalContext injects as `<system-reminder>`** (system-level authority)
- **Tool restriction: two-layer** — permissions.deny for hard removal + PreToolUse prompt hooks for intelligent gating
- **Enforcement priority: deny > hooks > allow** (hooks CANNOT override deny)
- **TAD v3.0 must NOT use bypassPermissions mode**
- **allowed-tools unreliable** — don't depend on it
- **Per-skill hooks not implemented** — use global hooks with matcher/if patterns

### Known Issues / Carry-forward
- Hook execution environment is shell-based — complex logic needs CLI wrapper or jq/yq
- Per-skill hooks not implemented in v2.1.88 — may arrive in future versions
- allowed-tools "auto-approval" hypothesis unconfirmed (couldn't test outside bypass mode)
- TAD currently has 8 registered sync projects — migration must not break them
- All spike evidence retained in .tad/spike-v3/

### Next Phase Scope
Phase 4: Quality & Performance — Add PreToolUse prompt hooks for intelligent gating, implement parallel expert review in handoff creation, optimize context budget. Build on Phase 2 hooks + Phase 3 slimmed skills.

---

## Notes
- Source reference: `/Users/sheldonzhao/01-on progress programs/claude-code-leaked/src/`
- Discovery note: `/Users/sheldonzhao/01-on progress programs/thoughts/discoveries/2026-03-31-claude-code-source-map-leak.md`
- This Epic supersedes Direction 1 from the initial discussion — expanded from "Hook optimization" to "complete rebuild"
