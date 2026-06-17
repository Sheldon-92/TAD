# Backend Architect Review: HANDOFF-20260617-agent-skill-evolution-pack

**Reviewer lens:** data flow, type extensions, storage patterns, API contracts, system architecture, state management
**Scope read:** SS3 (ACs), SS4 (Technical Design), SS6 (Risks), SS7 (Scope), SS10 (Files to Create), SS11 (Decisions). IDEA file for rule content verification.
**Date:** 2026-06-17

---

## Critical Issues (P0)

### P0-1: Rule Count Arithmetic Inconsistency -- Multiple Locations Contradict

The handoff states "22 rules" in multiple places but the actual enumerated rules total **26** across the 6 base references:
- AD: 4 + TL: 4 + ES: 4 + VG: 4 + OC: 7 + MT: 3 = **26** (not 22)
- With the 7th reference (SI1-SI3): **29 total**

Affected locations with the wrong "22" count:
- SS4.1 SKILL.md body template: "Quick Rule Index (all 22+3 rules)" -- should be "26+3" or "all 29 rules"
- AC5: "Quick Rule Index 表列出全部 22 条规则 (AD1-4, TL1-4, ES1-4, VG1-4, OC1-7, MT1-3)" -- the parenthetical enumerates 26 items, not 22
- IDEA file header: "Rule Summary (22 rules across 6 references)" -- enumerates 26
- FR1: "Quick Rule Index (22 rules)" -- should be 26 (or 29 if SI included in index)

**Impact:** Blake will either (a) implement only 22 rules and leave 4 undiscoverable missing ones, or (b) implement the parenthetical enumeration (all 29) and fail AC5's explicit count assertion of "22". The AC is internally contradictory -- the numerical literal disagrees with the exhaustive rule-ID enumeration in the same sentence. This is the kind of spec ambiguity that causes rework.

**Fix:** Correct all "22" references to "26" (6 base references) or "29" (all 7 references including SI). Align AC5 count expectation with the actual rule IDs listed in the parenthetical. Decide whether SI1-SI3 belong in the Quick Rule Index or not, and state it unambiguously.

---

## Recommendations (P1)

### P1-1: .agents/ Sync Scope Understated -- Only SKILL.md Listed, Full Mirror Required

SS10 (Files to Create) lists only `.agents/skills/agent-skill-evolution/SKILL.md` with action "Sync" for Codex parity. However, verified via `diff -rq` of rag-retrieval and agent-memory: the established project pattern is a **full directory mirror** -- `.agents/skills/{pack}/` is byte-identical to `.claude/skills/{pack}/` across all subdirectories (references/, examples/, scripts/, LICENSE).

AC14 says ".agents/skills/agent-skill-evolution/SKILL.md 与 .claude/ 版本一致" -- this only checks SKILL.md, missing the 7 reference files, 1 fixture, and 1 script that the Codex edition also needs.

**Impact:** Blake will sync only SKILL.md. The `platform-skills` byte-symmetry gate (documented in pack-build-rules.md "Sync That Mirrors Skills" entry, known to have caught the v2.30.0 21-pack downgrade) will FAIL on the next release sync for this pack.

**Fix:** Change SS10 `.agents/` entry from "Sync" (single file) to "Sync (full directory mirror: cp -R)". Update AC14 verification to `diff -rq .claude/skills/agent-skill-evolution/ .agents/skills/agent-skill-evolution/`.

### P1-2: AC11 Threshold of >=10 Specifics Is Low for 29 Rules

AC11 requires ">= 10 specific numbers/thresholds" across all references. With 29 rules across 7 reference files (~100-150 lines each), that is ~0.34 specifics per rule -- well below the anti-slop quality bar established in pack-evaluation patterns ("specific threshold from research > generic principle from training data"). For context:
- rag-retrieval (6 refs, 20 rules): carries ~20+ specific numbers
- The handoff's own FR2 table lists 12 specific values as "Layer B depth" examples in just the summary

**Fix:** Raise AC11 floor to >= 20, or add a per-reference minimum (e.g., each reference file must contain >= 2 specific numbers from the research source).

### P1-3: IDEA File Rule Count Diverges from Handoff

The IDEA file's "Pack Structure" section (lines 47-59) shows only 6 references (no skillopt-sleep-integration.md). The IDEA's "Rule Summary" header says "22 rules across 6 references." The handoff adds a 7th reference (SI1-SI3) in SS4.2 but doesn't note the IDEA is superseded on structure.

**Impact:** Blake may reference the IDEA for rule content and only build 6 references, requiring rework when AC9 (`ls references/ | wc -l` expecting 7) fails.

**Fix:** Either update the IDEA file to reflect 7 references + 29 rules, or add a clear note in the handoff that the IDEA's structure section is superseded.

---

## Suggestions (P2)

### P2-1: LICENSE File Not Listed in SS10

Gold-standard packs (rag-retrieval, web-backend, agent-memory, agent-orchestration, etc.) include a LICENSE file (Apache 2.0). SS10 does not list creating one. Not blocking, but inconsistent with the established 11/24 pack artifact set.

### P2-2: Fixture Naming Convention

SS10 lists the fixture as `examples/self-improving-agent.md`. Some existing packs use `{pack-name}-fixture.md` (agent-memory-fixture.md, agent-orchestration-fixture.md). Consider `agent-skill-evolution-fixture.md` for grep discoverability, though this is not enforced.

### P2-3: gate-check.sh Exit Code Semantics

SS4.4 specifies PASS/PARTIAL/FAIL return values but does not define numeric exit codes. The gold-standard `rag-config-lint.sh` uses: exit 0 (PASS), exit 1 (P0 FAIL), exit 2 (P1 only). Recommend aligning exit codes for script interoperability (CI/CD, pack-eval-runner.sh).

### P2-4: No SKILL.md Version Field in Frontmatter Design

The SS4.1 frontmatter template shows `name`, `description`, `keywords`, `type` but no `version`. Gold-standard packs include `**Version**: 0.1.0` in the body. Minor -- Blake will likely include from template.

---

## Overall Assessment: CONDITIONAL PASS

The handoff demonstrates strong architectural judgment: reference-based pack type correctly chosen, coherent rule taxonomy with zero keyword overlap against 7 existing agent packs (verified via grep), proper CONSUMES/PRODUCES interface contract, discriminative fixture with `discriminative_pattern`/`min_discriminative` frontmatter, and a deterministic gate-check.sh script design. The decision to create a standalone pack rather than scatter rules across 6 existing packs is well-justified by the rag-retrieval analogy.

**One P0 blocks:** the rule count arithmetic is internally contradictory (says "22" everywhere but enumerates 26+3=29), which will cause AC5 verification failure regardless of how Blake interprets it. This is a documentation error, not an architectural flaw -- easy to fix.

The `.agents/` sync scope understatement (P1-1) is the most architecturally significant recommendation, as it creates a guaranteed platform-skills symmetry gate failure on the next release cycle.

**Verdict: CONDITIONAL PASS** -- fix P0-1 (rule count arithmetic) before handing to Blake. P1-1 (.agents full mirror) and P1-2 (AC11 threshold) should also be addressed.
