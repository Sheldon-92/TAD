# Epic: TAD Dual-Platform Native Runtime Architecture

**Epic ID**: EPIC-20260609-dual-platform-native-runtime-architecture
**Created**: 2026-06-09
**Owner**: Alex
**Status**: Complete
**Promoted from**: IDEA-20260609-codex-native-runtime-hardening

---

## Objective

Upgrade TAD's platform architecture so Claude Code and Codex are both treated as first-class native runtimes, not as a lowest-common-denominator SKILL loader. Define the shared TAD protocol layer, the platform-specific adapter layer, and the verification strategy needed to use each runtime's native strengths without fragmenting Alex/Blake behavior.

This Epic is a follow-up to `EPIC-20260609-skill-body-reference-boundary`. It must not delay the P0 body/reference quality-chain fix.

## Success Criteria

- [x] Architecture decision document defines common TAD protocol vs Claude Code adapter vs Codex adapter
- [x] Claude Code and Codex capability matrix is updated with native primitives, gaps, and required fallbacks
- [x] Codex project configuration policy is designed for `.codex/config.toml` without committing user-owned secrets/auth
- [x] Codex custom-agent strategy is evaluated for reviewer/expert roles currently represented by skills
- [x] Claude Code compatibility is explicitly preserved: skills, hooks/workflows, compact behavior, and existing sync semantics remain valid
- [x] Runtime freshness loop tracks Codex feature/config drift and forces re-verification before release/sync
- [x] Regression harness covers `$alex activation → handoff → $blake implementation → Gate 3 → Gate 4 → trace/evidence` (CONDITIONAL_GO: ask_user_question adapter gap open)
- [x] Documentation removes stale "Codex as specialized executor" framing and records the new dual-runtime architecture

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Architecture Decisions | ✅ Done | .tad/archive/handoffs/HANDOFF-20260609-dual-platform-runtime-architecture-phase1.md | Dual-platform architecture decision document + capability matrix |
| 2 | Codex Native Runtime Policy | ✅ Done | .tad/archive/handoffs/HANDOFF-20260609-codex-native-runtime-policy.md | `.codex/config.toml` policy + `.codex/agents/` evaluation |
| 3 | Adapter & Docs Upgrade | ✅ Done | .tad/archive/handoffs/HANDOFF-20260609-dual-platform-docs-upgrade.md | Updated multi-platform docs + protocol/adapter boundary rules |
| 4 | Runtime Freshness Loop | ✅ Done | .tad/archive/handoffs/HANDOFF-20260609-runtime-freshness-loop.md | Codex/Claude Code compatibility ledger + drift-check release gate |
| 5 | Regression & Acceptance | ✅ Done | .tad/archive/handoffs/HANDOFF-20260609-dual-platform-regression-phase5.md | n=1 fresh + waiver dual-platform regression evidence + Gate 4 CONDITIONAL_GO |

### Phase Dependencies

All phases are sequential: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5.

### Derived Status

Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Architecture Decisions

**Status:** ✅ Done
**Execution:** Blake handoff
**Completed:** 2026-06-09. Gate 4 PASS. Commit `892ace6`.

#### Scope

Produce a dual-platform architecture decision document. Separate what belongs in the TAD protocol body from what belongs in platform adapters. Compare Claude Code and Codex across role activation, skill loading, hooks, custom agents/subagents, tool permissions, MCP, review flows, cloud execution, context compaction, trace/evidence, and release sync.

NOT in scope: modifying runtime files. This phase is design-only.

#### Input

- Current `AGENTS.md`
- `.agents/skills/alex/SKILL.md`
- `.agents/skills/blake/SKILL.md`
- `.claude/skills/alex/SKILL.md`
- `.claude/skills/blake/SKILL.md`
- `.tad/codex/README.md`
- `docs/MULTI-PLATFORM.md`
- Phase 3 evidence from `EPIC-20260609-skill-body-reference-boundary`

#### Output

- `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`
- Capability matrix: Claude Code native / Codex native / shared TAD protocol / fallback behavior
- Decision list for protocol vs adapter placement

#### Acceptance Criteria

- [x] Every architecture decision states whether it belongs to shared TAD protocol, Claude Code adapter, Codex adapter, or documentation only
- [x] Capability matrix includes at minimum: skills, hooks, agents/subagents, MCP, permission model, review, cloud/offload, compact/resume, evidence trace
- [x] Phase explicitly verifies current Codex behavior against local Codex docs/config or official OpenAI docs before making configuration claims
- [x] No platform is treated as subordinate; where parity is impossible, the fallback is explicit and tested
- [x] Human confirms the proposed boundary before Phase 2 begins

#### Files Likely Affected

- `.tad/evidence/designs/dual-platform-native-runtime-architecture.md` (CREATE)

#### Dependencies

Should start after `EPIC-20260609-skill-body-reference-boundary` reaches Phase 3 acceptance, so this architecture upgrade builds on a repaired quality chain.

---

### Phase 2: Codex Native Runtime Policy

**Status:** ✅ Done
**Execution:** Blake handoff
**Completed:** 2026-06-09. Gate 4 PASS. Commit `4f03d7e`.

#### Scope

Design and, if accepted, implement the Codex-native runtime layer for TAD projects. Cover project-level `.codex/config.toml`, hooks enablement, sandbox/approval/profile policy, strict config behavior, MCP registration rules, and `.codex/agents/` candidates.

NOT in scope: storing user credentials, auth tokens, personal profile defaults, or machine-specific secrets in the project repository.

#### Input

- Phase 1 architecture decision document
- Current `.codex/` project state
- Current `.agents/skills/` and `.claude/skills/` role files
- Codex CLI local docs/config behavior and current official OpenAI Codex docs if local evidence is insufficient

#### Output

- Draft or implemented `.codex/config.toml` policy
- `.codex/agents/` evaluation report
- Candidate agent specs for `code-reviewer`, `backend-architect`, `testing-reviewer`, and optional Blake execution agent
- Security note documenting project-owned vs user-owned settings

#### Acceptance Criteria

- [x] Project-owned settings are separated from user-owned settings
- [x] No secrets, tokens, account IDs, or personal machine paths are committed
- [x] Sandbox and approval defaults match TAD's quality/safety model
- [x] Hooks strategy is compatible with existing Gate pre-checks
- [x] Custom-agent recommendation includes a clear keep/migrate/defer decision for each reviewer role
- [x] If `.codex/agents/` is adopted, prompts are minimal, role-specific, and do not fork core TAD protocol

#### Files Likely Affected

- `.codex/config.toml` (CREATE or MODIFY, if approved)
- `.codex/agents/*.md` (CREATE, if approved)
- `.tad/evidence/designs/codex-native-runtime-policy.md` (CREATE)

#### Dependencies

Phase 1 complete and human-confirmed. Use `.tad/evidence/designs/dual-platform-native-runtime-architecture.md` as the input boundary document.

---

### Phase 3: Adapter & Docs Upgrade

**Status:** ✅ Done
**Execution:** Blake handoff
**Completed:** 2026-06-09. Gate 4 PASS. Commit `862bf1e` plus Gate 4 evidence correction.

#### Scope

Update TAD documentation and adapter boundaries so both platforms are described accurately. Replace stale language that frames Codex as only a specialized executor. Document how shared SKILL protocol, Claude Code runtime behavior, and Codex runtime behavior interact during design, implementation, review, gates, release, and sync.

NOT in scope: expanding unrelated TAD product scope or adding a third platform.

#### Input

- Phase 1 architecture decision document
- Phase 2 Codex runtime policy
- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`
- `AGENTS.md`
- Any generated Codex config/agent files

#### Output

- Updated `docs/MULTI-PLATFORM.md`
- Updated `.tad/codex/README.md`
- Updated platform adapter notes in `AGENTS.md` or equivalent project docs, if needed
- Migration notes for downstream projects

#### Acceptance Criteria

- [x] Docs state Codex and Claude Code are both first-class TAD runtimes
- [x] Shared protocol vs platform adapter boundary is explicit
- [x] Claude Code behavior is not regressed or rewritten as Codex-only
- [x] Codex-specific setup does not imply user-level config should be committed
- [x] Downstream sync impact is documented before release

#### Files Likely Affected

- `docs/MULTI-PLATFORM.md` (MODIFY)
- `.tad/codex/README.md` (MODIFY)
- `AGENTS.md` (MODIFY, if needed)
- `.tad/evidence/designs/dual-platform-docs-upgrade.md` (CREATE)

#### Dependencies

Phase 2 complete and Gate 4 accepted. Use `.tad/evidence/designs/codex-native-runtime-policy.md` and `.tad/evidence/designs/codex-runtime-candidates/` as inputs.

---

### Phase 4: Runtime Freshness Loop

**Status:** ✅ Done
**Execution:** Alex design → Blake implementation handoff
**Completed:** 2026-06-09. Gate 4 PASS after R3 and Alex acceptance fix. Commits `23f4604`, `949cb9f`, `26ec62d` plus local Gate 4 marker fix.

#### Scope

Create a standing mechanism for keeping TAD's Codex and Claude Code adapter knowledge current as the runtimes evolve. Track runtime versions, documentation freshness, config schema assumptions, native feature availability, and regression status. Make freshness verification a release/sync gate instead of relying on memory.

NOT in scope: automatically adopting every new Codex feature. New features must still pass architecture review before changing TAD protocol or adapters.

#### Input

- Phase 1 capability matrix
- Phase 2 Codex runtime policy
- Phase 3 platform documentation
- Local Codex CLI behavior and config docs available in the current environment
- Current official OpenAI Codex docs when local evidence is stale or insufficient
- Claude Code runtime notes already used by TAD

#### Output

- `.tad/runtime-compat/codex.md` compatibility ledger
- `.tad/runtime-compat/claude-code.md` compatibility ledger
- Release freshness checklist or script integrated into TAD release verification
- Drift response policy: update docs, update adapter, add regression, or record accepted limitation

#### Acceptance Criteria

- [x] Ledger records `last_verified`, runtime version/source, doc source, owner, next review date, and volatility level for every platform-specific claim
- [x] Codex feature/config claims are re-verified before TAD release or downstream sync
- [x] Codex CLI version/config drift triggers at least one smoke regression or an explicit "no affected surface" note
- [x] Volatile Codex details stay in runtime compatibility docs or adapter docs, not buried inside invariant Alex/Blake protocol text
- [x] Execution-discipline rules remain in SKILL body even if platform-specific instructions move to adapter docs
- [x] Drift response creates a tracked issue/idea/handoff when a runtime update changes TAD behavior
- [x] Freshness check fails closed for unknown Codex config/agent/hook behavior that would affect safety or quality gates

#### Files Likely Affected

- `.tad/runtime-compat/codex.md` (CREATED)
- `.tad/runtime-compat/claude-code.md` (CREATED)
- `.tad/hooks/lib/runtime-freshness-verify.sh` (CREATED)
- `.tad/hooks/lib/release-verify.sh` (MODIFIED)

#### Dependencies

Phase 3 complete and Gate 4 accepted. Use `docs/MULTI-PLATFORM.md`, `.tad/codex/README.md`, `AGENTS.md`, and `.tad/evidence/designs/dual-platform-docs-upgrade.md` as Phase 4 inputs.

#### Notes

- Treat runtime freshness like dependency management: verify, record, test, then adopt.
- Suggested triggers: before every TAD release, before `*sync` to downstream projects, after Codex CLI/config changes, after official Codex documentation changes, and on a monthly/quarterly maintenance cadence.
- Suggested ledger fields: surface, current behavior, source, `last_verified`, runtime version, owner, volatility, next review, regression required, fallback behavior.
- The rule is not "always chase latest"; the rule is "know when latest changed, decide deliberately, and prove TAD still works."

---

### Phase 5: Regression & Acceptance

**Status:** ✅ Done
**Execution:** Blake implementation + Alex acceptance
**Completed:** 2026-06-09. Gate 4 CONDITIONAL_GO accepted.

#### Scope

Run repeatable dual-platform regression to prove the architecture works in practice. The core path is `$alex activation → handoff → $blake implementation → Gate 3 → Gate 4 → trace/evidence`, executed on Codex and cross-checked against Claude Code behavior where feasible.

NOT in scope: claiming platform parity without evidence.

#### Input

- Phase 2 runtime/config outputs
- Phase 3 documentation updates
- Phase 4 runtime freshness loop
- Existing Gate 3 / Gate 4 protocol
- Test project(s) selected for low-risk dogfood

#### Output

- `.tad/evidence/codex-regression/` reports
- `.tad/evidence/dual-platform-regression/` reports
- Acceptance summary with pass/fail matrix
- Follow-up backlog for any platform-specific gaps

#### Acceptance Criteria

- [ ] Codex full-cycle regression passes end-to-end at least once
- [ ] n=3 stability run is completed or explicitly waived with rationale
- [ ] Claude Code compatibility check passes for role activation, handoff, Gate 3/Gate 4 semantics, and compact-sensitive behavior
- [ ] Runtime freshness ledger is current at the time of acceptance
- [ ] Trace/evidence artifacts are present and linked from the acceptance report
- [ ] Any platform gap is classified as protocol bug, adapter bug, documentation bug, or accepted limitation
- [ ] Alex Gate 4 acceptance explicitly decides release readiness

#### Files Likely Affected

- `.tad/evidence/codex-regression/` (CREATE)
- `.tad/evidence/dual-platform-regression/` (CREATE)
- `CHANGELOG.md` (MODIFY, if released)
- `version.txt` (MODIFY, if released)

#### Dependencies

Phase 4 complete.

---

## Context for Next Phase

Start Phase 1 only after the P0 SKILL body/reference boundary Epic has restored the quality chain. The first design question is not "how do we make Codex imitate Claude Code?" but "which parts of TAD are invariant protocol, and which parts should be native adapters for Claude Code and Codex?"

### Phase 1 Accepted — 2026-06-09

Gate 4 verdict: PASS.

Accepted artifact:
- `.tad/evidence/designs/dual-platform-native-runtime-architecture.md`

Key accepted boundary:
- Shared TAD protocol owns Alex/Blake identity, Gates 1-4, handoff discipline, Layer 2 semantics, Ralph Loop, completion/evidence, knowledge assessment, execution discipline, honest_partial, and compact recovery expectations.
- Claude Code adapter owns Claude-specific execution mechanics: Skill tool, Agent tool, hooks/settings, workflows, compact mechanics, and MCP wiring.
- Codex adapter owns Codex-specific execution mechanics: `AGENTS.md` project instructions, `.agents/skills/`, `.codex/config.toml`, `.codex/agents/`, Codex hooks, MCP config, sandbox/approval profiles, subagents, plugins, and Cloud/offload.
- Runtime freshness layer owns compatibility ledgers, `last_verified`, volatility, recheck triggers, fail-closed behavior, and drift response.

Carry-forward:
- Phase 2 must not fork Alex/Blake into Codex custom agents; custom agents should be narrow reviewer/expert roles only.
- Phase 2 must verify Codex `ask_user_question` equivalent or approve conversational fallback for Socratic inquiry.
- Phase 3 must correct the 14 P2 line-reference inaccuracies before rewriting docs.
- Phase 4 must track Claude Code freshness too; it is lower-volatility, not "not applicable."

### Phase 2 Accepted — 2026-06-09

Gate 4 verdict: PASS.

Accepted artifacts:
- `.tad/evidence/designs/codex-native-runtime-policy.md`
- `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/spec-compliance-reviewer.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/code-reviewer.toml.draft`
- `.tad/evidence/designs/codex-runtime-candidates/agents/test-runner.toml.draft`

Accepted strategy:
- Project config may recommend `model = "gpt-5.5"`, `model_reasoning_effort = "high"`, `sandbox_mode = "workspace-write"`, `approval_policy = "on-request"`, and cached web search; model names and config keys were re-verified against the current Codex manual on 2026-06-09.
- Project config must not include API keys, OAuth tokens, bearer tokens, account IDs, personal machine paths, personal profile defaults, or cloud secrets.
- `.codex/hooks.json` remains the hook source of truth for now; do not duplicate hooks into `config.toml`.
- Custom-agent drafts are approved only for narrow reviewer roles: spec-compliance-reviewer, code-reviewer, and test-runner.
- Alex and Blake remain `keep_skill_only`; do not fork their role protocols into `.codex/agents/*.toml`.

Carry-forward:
- The draft files are **not active runtime config**. Do not copy them into `.codex/` until Phase 3 docs, Phase 4 freshness ledger, Phase 5 regression, and explicit Human approval are complete.
- Phase 5 must verify whether Codex fires the `ask_user_question` hook matcher. If not, implement an alternate evidence-capture path.
- Phase 5 must empirically test whether custom agents inherit skill visibility sufficiently for TAD review tasks.
- Layer 2 evidence has a process blemish: the final one-line P1 fix was present in the artifact and commit, but no R3 spot-check file was created. Treat this as non-blocking for Phase 2; require complete post-fix review evidence in later phases.
- 8 P2 review items remain non-blocking and should feed Phase 4/5 verification, especially `skills.config` schema, `model_provider`, output constraints, and agent runtime quality.

### Phase 3 Accepted — 2026-06-09

Gate 4 verdict: PASS.

Accepted docs:
- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`
- `AGENTS.md`
- `.tad/evidence/designs/dual-platform-docs-upgrade.md`

Accepted documentation state:
- `docs/MULTI-PLATFORM.md` is now the current dual-platform runtime guide.
- Codex and Claude Code are documented as first-class TAD runtimes.
- Gemini remains an external specialized tool only.
- Shared protocol vs Claude Code adapter vs Codex adapter boundaries are documented.
- Codex native config/agents are documented as draft-only, not active.
- Activation criteria are documented: Phase 3 docs, Phase 4 freshness ledger, Phase 5 regression, Human approval, no P0 quality-chain failure, and secrets audit.

Carry-forward:
- Phase 4 must implement runtime compatibility ledgers using the docs as source inputs.
- Phase 5 must verify `ask_user_question` hook behavior, custom-agent review quality, and full-cycle Codex regression.
- Gate 4 corrected a stale version reference in the docs-upgrade evidence artifact after Blake's commit; include this in any later commit.
- Layer 2 review evidence has a process blemish: the R1 P1 fixes are present in docs, but no separate R2 review file was created. Treat as non-blocking for Phase 3; require explicit post-fix review evidence in Phase 4/5.

### Phase 4 Accepted — 2026-06-09

Gate 4 verdict: PASS (after R3 evidence fix and Alex acceptance correction).

Accepted artifacts:
- `.tad/runtime-compat/codex.md` (12-surface compatibility ledger)
- `.tad/runtime-compat/claude-code.md` (9-surface compatibility ledger)
- `.tad/hooks/lib/runtime-freshness-verify.sh` (verifier script)
- `.tad/hooks/lib/release-verify.sh` (modified — freshness mode added)

Accepted behavior:
- Both ledgers track `last_verified`, runtime version, source, volatility, next review, regression required, and fallback behavior.
- Freshness verifier exits 0 (PASS), 1 (BLOCK), or 2 (malformed). Fixture-tested all three paths.
- `ask_user_question_hook` recorded as `accepted_limitation` with conversational fallback + `regression_required=yes`.
- Release gate integrated via `release-verify.sh freshness` mode.

Carry-forward:
- Full-cycle Codex regression (activation test for draft config/agents).
- `ask_user_question_hook` verification on Codex.
- Custom-agent review quality parity test.
- n≥1 end-to-end: `$alex → handoff → $blake → Gate 3 → Gate 4 → evidence` on Codex.
- 5 P2 code-reviewer items (unquoted var, no WARN for non-safety unknown, fragile header detection, space-separated safety list, skill_loading volatility) — non-blocking.

### Phase 5 Accepted — 2026-06-09

Gate 4 verdict: CONDITIONAL_GO (accepted by human).

Accepted artifacts:
- `.tad/evidence/codex-regression/T1-full-cycle-v0.137.0.md` (Codex full-cycle on 0.138.0)
- `.tad/evidence/dual-platform-regression/T2-claude-code-compat.md` (6 surfaces + 2 behavioral checks)
- `.tad/evidence/dual-platform-regression/T3-carry-forward.md` (8 items CF1-CF8)
- `.tad/evidence/dual-platform-regression/T4-freshness-check.md` (21/21 PASS)
- `.tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md` (release recommendation)
- `.tad/evidence/acceptance-tests/TASK-20260609-005/` (8 AC scripts + verification report)

Accepted findings:
- 8/8 ACs pass (Alex independent recompute confirmed).
- 5 gaps classified: 1 adapter_bug (CF1 ask_user_question), 2 accepted_limitation (git index.lock, model_provider), 1 deferred (CF7 output constraints), 1 process_blemish (version pin 0.137→0.138).
- Spec-compliance reviewer FAIL on sandbox boundary (workspace-write vs evidence-rooted) accepted as adapter limitation — Codex has no directory-scoped sandbox mode.
- n=3 waiver accepted (n=1 fresh 06-09 + n=1 prior 06-07).

CONDITIONAL_GO condition:
- CF1 `ask_user_question` remains an adapter_bug: `request_user_input is unavailable in Default mode`. Codex decision-capture parity is not yet closed. Does not block core Alex→Blake execution chain.

---

## Notes

- User explicitly requested that TAD's next overall architecture upgrade account for both Claude Code and Codex systems.
- This Epic generalizes the earlier `Codex Native Runtime Hardening` idea into a dual-platform architecture upgrade.
- `EPIC-20260609-skill-body-reference-boundary` remains the P0 blocker. This Epic is P1 and should not interrupt the current body/reference audit and repair.
