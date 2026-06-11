# Epic: Pack System Unification

**Epic ID**: EPIC-20260611-pack-system-unification
**Created**: 2026-06-11
**Owner**: Alex
**Idea**: .tad/active/ideas/IDEA-20260610-pack-system-unification.md

---

## Objective

Unify TAD pack distribution around one runtime format and two symmetric platform targets. When this Epic is complete, YAML Domain Packs are retired as an active mechanism, Capability Pack installs are single-sourced from prebuilt SKILL.md content, and Claude Code `.claude/skills` plus Codex `.agents/skills` parity is verified at the granularity where installs and sync actually write files.

## Success Criteria

- [x] `.tad/domains/` is no longer an active runtime/sync mechanism; its content is archived with a migrate-on-demand policy and no SessionStart injection tax.
- [x] Capability Pack install output is idempotent and does not generate content that differs from prebuilt SKILL.md files.
- [x] `.claude/skills` and `.agents/skills` are byte-symmetric for framework-owned packs after sync/install, with documented local-skill exceptions.
- [x] Release/sync documentation and verification no longer assume two live pack systems.

---

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Domain YAML content policy | Archive as-is + add T2 skill-library notes for toy-proven hw content | Preserves evidence without bulk-migrating near-zero-use YAML into a new live tax. |
| supply-chain-security treatment | Preserve as T2 reference, migrate on real demand | Security motivation is real, but a production pack needs an actual use case and validation path. |
| Downstream removal | Try migration manifest first; fallback to deprecation entry if directory deletion is unsupported | Good dogfood for Upgrade Lifecycle, but this Epic must not block on unfinished lifecycle phases. |
| Phase 1 scope | Medium: retire Domain Packs + clean runtime references and docs | Removes the current tax without prematurely adding new standing checks. |

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Domain Pack Retirement | ✅ Done | `.tad/archive/handoffs/HANDOFF-20260611-pack-system-unification-phase1.md` | YAML Domain Packs archived; runtime/doc references cleaned; migration/deprecation path prepared |
| 2 | Install Single-Sourcing | ✅ Done | `.tad/archive/handoffs/HANDOFF-20260611-pack-system-unification-phase2.md` | Transforming installers converted to idempotent copy; ml-training gains prebuilt SKILL.md |
| 3 | Platform Symmetry Verification | ✅ Done | `.tad/archive/handoffs/HANDOFF-20260611-pack-system-unification-phase3.md` | Sync/install verification checks `.claude/skills` vs `.agents/skills` with FR7 local-skill exemptions |

### Phase Dependencies

All phases are sequential. Phase 1 removes the obsolete active pack system; Phase 2 normalizes Capability Pack install semantics; Phase 3 adds the verification layer once the write behavior is stable.

### Derived Status

Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ -> Planning | If any 🔄 or ✅ -> In Progress | If all ✅ -> Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Domain Pack Retirement

**Status:** ✅ Done
**Execution:** Gate 4 PASS 2026-06-11 (`0d965bb` + `0f6a7d7`)

#### Scope

Retire YAML Domain Packs as an active TAD mechanism. This phase archives the 9 active YAML packs and 2 domain-pack docs, removes SessionStart/domain-router/runtime references, and updates release/sync documentation so `.tad/domains/` is not treated as a live framework directory. This phase does not change Capability Pack installer behavior and does not add a new standing verification hook.

#### Input

- Idea evidence in `.tad/active/ideas/IDEA-20260610-pack-system-unification.md`
- Existing `.tad/domains/` directory with 9 YAML packs and 2 supporting docs
- Existing `.tad/archive/domains/` directory
- Existing domain router and keyword artifacts under `.tad/hooks/`
- Existing sync/release references in Alex/Blake skills, release runbook, README, and `tad.sh`

#### Output

- Domain YAML files and domain-pack docs moved or copied into `.tad/archive/domains/` with clear archival metadata.
- Runtime injections and router references removed or marked retired.
- T2 skill-library references added only for toy-proven hw content and supply-chain-security.
- Migration manifest path attempted for downstream `.tad/domains/` removal, with deprecation fallback documented if directory deletion is unsupported.
- Project docs updated to describe SKILL.md Capability Packs as the only active pack format.

#### Acceptance Criteria

- [ ] `find .tad/domains -maxdepth 1 -type f` returns no active Domain Pack YAML files after Phase 1, or `.tad/domains/` is removed from the active sync set with every remaining file explicitly marked archived/retired.
- [ ] `rg -n "Domain Pack|\\.tad/domains|userprompt-domain-router|keywords.yaml" .tad/hooks .agents/skills .claude/skills README.md docs tad.sh` shows no live-runtime instructions; historical/archive/evidence mentions are either excluded or explicitly marked historical.
- [ ] `.tad/skill-library/` contains short T2 reference notes for toy-proven hw content and supply-chain-security, each pointing to archived source files and stating migrate-on-demand criteria.
- [ ] Release/sync surfaces no longer list `.tad/domains/` as a full-refresh active directory unless a migration/deprecation path explicitly needs it for removal.
- [ ] A migration-manifest or deprecation entry describes downstream removal behavior for `.tad/domains/`, including fallback if manifest directory deletion is unsupported.
- [ ] No Capability Pack installer files are modified in Phase 1 except documentation references that clarify they are out of scope.

#### Files Likely Affected

- `.tad/domains/*` (MOVE / ARCHIVE)
- `.tad/archive/domains/` (CREATE / MODIFY)
- `.tad/hooks/startup-health.sh` (MODIFY)
- `.tad/hooks/userprompt-domain-router.sh` (DELETE / ARCHIVE / RETIRE)
- `.tad/hooks/keywords.yaml` (DELETE / ARCHIVE / RETIRE)
- `.tad/hooks/generate-keywords.sh` (DELETE / ARCHIVE / RETIRE)
- `.tad/hooks/lib/derive-sync-set.sh` (MODIFY)
- `.tad/deprecations.yaml` or `.tad/migrations/*.yaml` (CREATE / MODIFY)
- `.claude/skills/release-runbook/SKILL.md` (MODIFY)
- `.claude/skills/alex/references/design-protocol.md` (MODIFY)
- `.claude/skills/alex/references/discuss-path-protocol.md` (MODIFY)
- `.claude/skills/alex/references/handoff-creation-protocol.md` (MODIFY)
- `.claude/skills/blake/SKILL.md` (MODIFY)
- `.agents/skills/alex/references/design-protocol.md` (MODIFY)
- `.agents/skills/alex/references/discuss-path-protocol.md` (MODIFY)
- `.agents/skills/alex/references/handoff-creation-protocol.md` (MODIFY)
- `.agents/skills/blake/SKILL.md` (MODIFY)
- `README.md` (MODIFY)
- `.tad/project-knowledge/README.md` (MODIFY)
- `.tad/skill-library/_index.md` (MODIFY)
- `.tad/skill-library/{slug}.md` (CREATE)

#### Dependencies

None.

#### Notes

Blake preserved historical evidence under `.tad/evidence/` and `.tad/archive/`; this phase only retired active runtime surfaces. Anchor-map evidence captured intentional removal, historical retention, and deferral rationale.

### Phase 2: Install Single-Sourcing

**Status:** ✅ Done
**Execution:** Gate 4 PASS 2026-06-11 (`554aef6` + `5210d32`)

#### Scope

Normalize Capability Pack installers so install output is byte-identical to prebuilt SKILL.md content. This phase eliminates install-time transformation for the six measured transform packs and gives `ml-training` a prebuilt SKILL.md output. This phase does not add cross-project sync verification; it makes the install behavior simple enough for Phase 3 to verify.

#### Input

- Phase 1 retirement output
- v2.29.0 sync evidence showing six transformed packs plus missing `ml-training`
- Existing Capability Pack source directories under `.tad/capability-packs/`
- Existing `.claude/skills/` and `.agents/skills/` generated pack outputs

#### Output

- The six transform packs have prebuilt SKILL.md files equal to installer output.
- `ml-training` has prebuilt SKILL.md in both `.claude/skills/ml-training/` and `.agents/skills/ml-training/`.
- Installers become idempotent copy/setup wrappers and do not synthesize divergent SKILL content.
- The two installers that reject `--force` accept it as a no-op.

#### Acceptance Criteria

- [ ] For `academic-research`, `ai-agent-architecture`, `ai-voice-production`, `video-creation`, `web-frontend`, and `web-ui-design`, running the installer does not change the committed SKILL.md content except for expected metadata-free copy behavior.
- [ ] `.claude/skills/ml-training/SKILL.md` and `.agents/skills/ml-training/SKILL.md` exist and match `.tad/capability-packs/ml-training/CAPABILITY.md` under the chosen single-source rule.
- [ ] Every `.tad/capability-packs/*/install.sh` either accepts `--force` or documents why the flag is not applicable; `academic-research` and `research-methodology` no longer fail on `--force`.
- [ ] No installer hardcodes `.claude/skills` as the only platform output without either mirroring to `.agents/skills` or delegating to a shared platform-aware install helper.
- [ ] Structural verification distinguishes framework-owned pack files from local-skill exceptions using the FR7 local-skill model.

#### Files Likely Affected

- `.tad/capability-packs/*/install.sh` (MODIFY)
- `.tad/capability-packs/{academic-research,ai-agent-architecture,ai-voice-production,video-creation,web-frontend,web-ui-design,ml-training}/CAPABILITY.md` (MODIFY if needed)
- `.claude/skills/{academic-research,ai-agent-architecture,ai-voice-production,video-creation,web-frontend,web-ui-design,ml-training}/SKILL.md` (CREATE / MODIFY)
- `.agents/skills/{academic-research,ai-agent-architecture,ai-voice-production,video-creation,web-frontend,web-ui-design,ml-training}/SKILL.md` (CREATE / MODIFY)
- `.tad/hooks/lib/release-verify.sh` (MODIFY if single-source verification belongs there)

#### Dependencies

Phase 1.

#### Notes

Phase 2 avoided broad pack-content rewrites. Seven target packs now have prebuilt source `SKILL.md` files, matching Claude/Codex installed outputs, and installers copy that source rather than synthesizing from `CAPABILITY.md`. `research-methodology` was flag-only and still has remaining single-source cleanup deferred outside Phase 2.

### Phase 3: Platform Symmetry Verification

**Status:** ✅ Done
**Execution:** Gate 4 PASS 2026-06-11 (`4c64e19` + `c87efb4`)

#### Scope

Add verification at the same granularity where sync and install write pack files. This phase wires post-sync/post-install checks so `.claude/skills` and `.agents/skills` stay symmetric for framework-owned packs, while preserving explicit local-skill exceptions.

#### Input

- Phase 2 single-sourced install behavior
- Existing FR7 local-skill model validated during v2.29.0 sync
- Existing release/sync verification scripts and runbook flow

#### Output

- A post-sync verification check that compares `.claude/skills` and `.agents/skills` for framework-owned packs.
- Clear exemption behavior for local skills and downstream project-specific additions.
- Release/sync runbook and protocol updates requiring this check before declaring sync success.
- Evidence from at least one local run against master and one representative downstream project fixture/log.

#### Acceptance Criteria

- [x] A verification command detects byte drift between framework-owned `.claude/skills/{pack}` and `.agents/skills/{pack}`.
- [x] The same command reports known local-skill additions as INFO, not FAIL, following the FR7 model.
- [x] `*sync` / release runbook instructions include the new symmetry check at the correct post-install point.
- [x] The check passes on master after Phase 2 and fails on an injected drift fixture.
- [x] Documentation states that SKILL.md Capability Packs are the only active pack system for both Claude Code and Codex.

#### Files Likely Affected

- `.tad/hooks/lib/release-verify.sh` (MODIFY)
- `.claude/skills/alex/references/sync-protocol.md` (MODIFY)
- `.agents/skills/alex/references/sync-protocol.md` (MODIFY)
- `.claude/skills/release-runbook/SKILL.md` (MODIFY)
- `.tad/templates/` or `.tad/schemas/` verification docs if needed (MODIFY)
- `docs/MULTI-PLATFORM.md` (MODIFY)
- `.tad/codex/README.md` (MODIFY)

#### Dependencies

Phase 2.

#### Notes

Blake added `release-verify.sh platform-skills <source_root> <target_root>`, deriving 46 framework-owned skills from the source tree. Gate 4 accepted a documented AC9 historical false positive in `docs/HISTORY.md` and a stale review-artifact P1 summary because independent post-fix evidence verified both P1 dispositions.

---

## Context for Next Phase

### Completed Work Summary

- Phase 1 accepted 2026-06-11. YAML Domain Packs are retired as an active mechanism; `.tad/domains/` now contains only a retired README, while the 9 YAML packs and 2 guide docs are archived under `.tad/archive/domains/2026-06-11-domain-pack-retirement/`.
- SessionStart Domain Pack injection, domain router references, post-write-sync Domain Pack handling, and `domain_pack_trace` protocol references were removed or rewritten to Capability Pack-only language.
- Two T2 skill-library archive references were created for toy-proven hardware content and supply-chain-security. Downstream cleanup is represented by `.tad/deprecation.yaml` v2.30.0.
- Phase 2 accepted 2026-06-11. Seven target Capability Packs now use prebuilt source `SKILL.md` files and produce byte-identical `.claude/skills` and `.agents/skills` outputs; `ml-training` now has installed SKILL files for both platforms.
- Phase 3 accepted 2026-06-11. `platform-skills` verifies framework-owned Claude/Codex skill symmetry after sync/install while reporting target-only local skills as INFO.

### Decisions Made So Far

- Retire Domain Packs by measurement, with archive-first preservation.
- Use T2 skill-library notes for toy-proven hw content and supply-chain-security.
- Try migration manifest for downstream `.tad/domains/` removal, but allow deprecation fallback.
- For Phase 1, deprecation entry was accepted as the substitute for migration manifest because directory deletion support remains tied to unfinished Upgrade Lifecycle phases.
- For Phase 2, `research-methodology` was accepted as flag-only scope; its remaining `CAPABILITY.md -> SKILL.md` copy behavior is deferred outside the seven-pack single-source target set.

### Known Issues / Carry-forward

- Upgrade Lifecycle Phase 3-6 is unfinished, so manifest-driven directory deletion remains a future improvement; Phase 1 used deprecation.yaml for downstream cleanup.
- `codex-tad-bundle/.tad/domains/` was removed locally but is gitignored; it will regenerate on next bundle creation.
- Gate 4 noted two non-blocking evidence hygiene issues: thin AC output capture and a stale completion-report body line saying Gate 3 was pending despite `gate3_verdict: pass`.
- Phase 2 Gate 4 found optional installer probes using unbounded `npx` can hang under restricted network; shell-portability knowledge was updated.
- `research-methodology` still routes Codex to `.claude/skills` and copies `CAPABILITY.md` as `SKILL.md`; resolve or explicitly classify it in Phase 3/follow-up if the standing verifier covers all packs.

### Completion

Epic complete 2026-06-11. Gate 4 reports:

- `.tad/evidence/acceptance-tests/pack-system-unification-phase1/gate4-acceptance-report.md`
- `.tad/evidence/acceptance-tests/pack-system-unification-phase2/gate4-acceptance-report.md`
- `.tad/evidence/acceptance-tests/pack-system-unification-phase3/gate4-acceptance-report.md`

---

## Notes

Promoted from `IDEA-20260610-pack-system-unification` on 2026-06-11 via Standard TAD.
