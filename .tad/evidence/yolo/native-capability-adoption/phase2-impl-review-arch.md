# Phase 2 Impl Review — Architecture Lens

- **Epic**: EPIC-20260712-native-capability-adoption (Phase 2/4)
- **Handoff**: HANDOFF-20260713-native-capability-adoption-phase2.md
- **Commit**: 8b6f0a5 (`feat(native-capability-adoption): Subagent frontmatter upgrades ... [YOLO Phase 2]`)
- **Reviewer lens**: backend/systems architecture — blast radius, completeness, degradation soundness
- **Worktree**: /Users/sheldonzhao/01-on progress programs/TAD/.claude/worktrees/wf_f91fb5e4-5de-1
- **Verdict**: PASS (DEGRADED-as-designed). 0 P0, 0 P1, 3 P2.

---

## What I independently verified (not just read)

| Check | Command | Result |
|---|---|---|
| AC1 spike 3 verdicts | `grep -cE '^VERDICT-...'` | `3` ✅ |
| AC2 frontmatter lint | `bash fm-lint.sh` | `FM-OK (1 files)` ✅ |
| AC3 boundary VACUOUS branch | memory-def scan | `VACUOUS-PASS (no memory defs)` ✅ (legal only under memory-FAIL, which holds) |
| AC3 anchor present | `grep -c 'MUST NOT store past verdicts'` | `1` in spec-compliance body ✅ |
| AC8 registration | `grep -c '^name: spec-compliance-reviewer'` | `1` ✅ |
| **git_tracked_dirs gate** | `git ls-files .claude/agents/` | `spec-compliance-reviewer.md` tracked ✅ (frontmatter `git_tracked_dirs: [".claude/agents"]` satisfied — Gate 3 would otherwise block) |
| AC10 scope | `git status --porcelain` | only `?? .tad/evidence/traces/2026-07-13.jsonl` (uncommitted); commit itself clean of trace + REGISTRY ✅ |
| Spike verdict sanity | `grep -rl '^memory:\|^skills:' ~/.claude/agents/` | none — no existing agent uses these fields, corroborates inert-field finding ✅ |
| fm-lint name-extraction robustness | multi-colon description simulation | name-only match survives `description: foo: bar` preceding `name:` ✅ |

The commit correctly excludes the auto-emitted trace file and the hook-flipped REGISTRY.yaml. No `~/.claude/agents/` writes (AC7=0). Zero machine-global blast radius this phase.

---

## Architecture assessment

**The degradation is the correct architectural outcome, not a failure to deliver.** The handoff was designed spike-first precisely because `memory`/`skills` frontmatter semantics on CLI 2.1.172 were UNKNOWN. The spike returned memory=FAIL, skills=FAIL, shadowing=PASS, and the implementation followed §4.1 degradation matrix rows 1+2 exactly: shipped the one unconditional deliverable (spec-compliance-reviewer registration, behaviorally verified by an independent spawn), preserved the spike rig as fixtures, and escalated every FAIL branch. This is textbook honest-partial — value kept, automation deferred, nothing silently dropped.

**Spike methodology is sound and multi-angle.** memory-FAIL is established three independent ways (boolean form, path form, filesystem check for a landing point) plus a discriminating re-probe that correctly caught and rejected a false-positive (the agent initially pointed at `.tad/memory/` project auto-memory — the spike distinguished agent-specific memory from session auto-memory rather than accepting the first affirmative). skills-FAIL used a hard tool-ban (`--disallowedTools`) so the negative can't be a "chose not to use it" artifact, and the pack's distinctive quotable content (TruffleHog exit 183, S1-S8 indices) makes the zero-quote result discriminative. This is the anti-Validation-Theater discipline the handoff demanded.

**Blast radius is minimal and correctly bounded.** One new git-tracked file under a brand-new `.claude/agents/` dir; the rest is evidence/fixtures under `.tad/evidence/`. No edits to Blake SKILL / 1_5a (AC9=0), no `~/.claude` writes, no `.gitignore` change (correctly NOT_APPLICABLE — no landing point exists). The decision to ship NO `memory:` key (rather than a dormant/commented one) is architecturally correct: a dead `memory:` key would be config theater AND would flip AC3 out of its sanctioned VACUOUS-PASS branch into a real assertion the inert field can't satisfy. The boundary rules ship in the body prose (dormant, clearly labeled) so they travel with the persona for the day a mechanism exists — right call.

**E3 distribution hazard is correctly surfaced.** The completion report flags that `.claude/agents/` is invisible to BOTH distribution paths (derive-sync-set walks `.tad/*/`; tad.sh `.claude` copy is a hardcoded allow-list). This is exactly the 2026-06-01 silent-omission failure class, and routing it to human decision before next `*publish` (recommend main-repo-only) is the correct handling given deny-list/allow-list history. No action needed this phase — but it MUST NOT be lost before publish.

---

## Findings

### P0 — none

### P1 — none

### P2-1 — fm-lint.sh generalizes but has an unverified-for-scale name-match assumption (T1-deliverable durability)
`fm-lint.sh` is a reusable T1 artifact that will lint `.claude/agents/*.md` on every future phase. It currently lints exactly 1 file. Its `name == filename` rule is correct for TAD's convention, but two latent edges are untested because only one clean file exists today: (a) an agent whose `name:` value legitimately differs from filename would FAIL — fine as a convention enforcer, but no test fixture exercises the FAIL path, so a future regression in the awk/head logic would pass silently on the happy path; (b) the frontmatter block bound assumes a single closing `---` — correct for agent defs but undocumented as an assumption. Recommend (non-blocking): add one intentionally-malformed fixture under the spike dir so the lint's FAIL path is itself proven, converting "0 files fail" from happy-path-only to discriminative.

### P2-2 — AC5 records DEGRADED(0) but success criterion `e2e_required: yes` is now unmet-by-mechanism; Epic must not treat this phase's evidence as satisfying the Epic-level behavioral success bar
The handoff frontmatter sets `e2e_required: yes` and Epic success is explicitly behavioral (RUN2 recall). That bar is now *structurally impossible to meet on 2.1.172* — correctly degraded, correctly escalated (E1). This is not a defect in the implementation. The architectural risk is downstream: when Phase 3/4 or Gate 4 consumes this Epic, the "behavioral success criterion" for the memory feature was never actually demonstrated (it can't be until CLI support lands). Recommend the Epic carry an explicit blocked-until marker so a later phase doesn't inherit a false "behavioral evidence satisfied" assumption from the green AC table. The completion report's E1 is the right place; ensure the Epic doc mirrors it.

### P2-3 — spec-compliance-reviewer persona is TAD-repo-coupled; distribution decision (E3) should also weigh persona portability, not just copy-path plumbing
The new reviewer's body hardcodes repo-specific environment facts (BSD grep, bash 3.2, `npm test` is a stub, evidence under `.tad/evidence/`). E3 frames the distribution question as a plumbing/verifier problem (add copy path + same-granularity verifier if distributed). But the persona content itself is main-repo-specific — shipping it to downstream projects would inject wrong environment assertions. This reinforces E3's main-repo-only recommendation on a second axis (content, not just sync mechanics). No change needed now; just ensure the publish-time human decision considers content portability, not only whether the file *can* be copied.

---

## Bottom line

Architecturally clean, honestly degraded, minimal blast radius, all load-bearing ACs (including the `git_tracked_dirs` Gate-3 requirement) independently verified. The three P2s are forward-looking durability/consumption hazards, none blocking. The spike-first design absorbed the UNKNOWN correctly and the degradation matrix was followed to the letter with full escalation. Recommend Gate 3 PASS.
