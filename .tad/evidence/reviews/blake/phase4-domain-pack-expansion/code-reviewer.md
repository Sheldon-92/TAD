# Code Review — Phase 4 Domain Pack Expansion

**Reviewer:** code-reviewer (Blake Layer 2)
**Date:** 2026-04-25
**Scope:** YAML-LAYER change across 9 Domain Pack files + 1 Epic backref + 1 architecture.md (≥2 entries). README.md modification deferred per BA-P0-2 sequencing.
**Handoff:** `.tad/active/handoffs/HANDOFF-20260425-phase4-domain-pack-expansion.md`

---

## Summary

Phase 4 lands 21 surgical content items + 1 new Type A capability (DESIGN.md) + 1 new "design_iteration_decisions" capability + 2 architecture.md learning entries + 1 Epic backref. All 8 modified YAML packs parse cleanly under `yaml.safe_load`. All 21 keyword greps PASS. AC-G1 anti-Epic-1 grep verifies clean via diff-based interpretation (0 newly introduced mechanical-enforcement lines; pre-existing historical entries in `architecture.md` are not Phase 4 introductions).

Net diff: **+394 / -8 = 386 net lines** across 10 files (within the 290-300 estimate's tolerance, well below the 400-line escalation threshold).

**Overall verdict: CONDITIONAL PASS — 1 P0 (data-loss regression in `safety_design.anti_patterns`) must be fixed before commit. 1 P1 + 3 P2 noted.**

---

## Three-Pass Analysis

### Pass 1 — Architecture
- New top-level capabilities (`design_system_documentation`, `design_iteration_decisions`) follow the Type A step-model (search → analyze → derive → generate) per the 2026-04-02 architecture.md learning. `design_system_documentation` is well-formed (description / type / steps / quality_criteria / anti_patterns / reviewers / references).
- `code-security.yaml` introduces a new `reference_implementations:` field as sibling to `dast_scan.steps`. This is a novel schema field (not in HOW-TO-CREATE-DOMAIN-PACK.md template), but the handoff §3 P4.8 explicitly authorizes it ("→ `dast_scan` 或新 step"). Schema-wise it parses cleanly and grep-AC criteria all hit. **Recommendation noted under P2** to either codify this field in the pack template or convert future similar additions to a step.
- Epic backref in `EPIC-20260403-security-domain-pack-chain.md §Phase 2` is well-placed and concise (10 lines), boundary correctly stated.
- Cross-link integrity verified bidirectionally:
  - `ai-prompt-engineering.yaml` step 5b → `ai-agent-architecture.yaml reliability_design.steps` (P4.4.2)
  - `ai-agent-architecture.yaml` step `cross_link_capability_declaration` → `ai-prompt-engineering.yaml system_prompt_design.steps.derive_prompt_architecture` step 5b (literal text matches handoff §10 CR-P2-3 specification verbatim)

### Pass 2 — Implementation
- All 21 grep AC items verified present (`keyword-grep.txt` corroborates).
- Per-pack YAML parse PASS for all 8 modified packs (`yaml-parse-results.txt` corroborates).
- BA-P0-1 critical guard: `consume_playground_input` step contains the literal "**不修改** /playground 任何 output" sentence + reference to `.claude/skills/playground/SKILL.md` standalone command. Read-only consumption boundary preserved.
- BA-P1-1 fold: P4.4.5 `Model Reads, Human Verifies` correctly placed inside `safety_design.steps[]`, NOT a new capability. Verified via `yq` → `safety_design.steps` count = 8 (includes this new step).
- BA-P0-3 license verification: `license-check.md` exists, references both repos with Apache 2.0 confirmation. Inline YAML attribution comments present in `web-ui-design.yaml` (Source: Anthropic skills/frontend-design/SKILL.md, Apache 2.0, retrieved 2026-04-25). Both Apache-2.0 attribution requirements satisfied.

### Pass 3 — Quality
- Knowledge entries: 2 new entries in `architecture.md` (DESIGN.md spec integration + Anti-AI-Slop philosophy). Both use the **Grounded in:** + **Revalidated:** format per Phase 2 protocol. AC-G4 met (≥2; 1 must be DESIGN.md topic — confirmed).
- Inline P4.x anchor comments make the additions traceable from grep alone (e.g., `# P4.4.4 (2026-04-25): Bilingual Blocklist as minimum.`). Good auditability.

---

## P0 — Critical Issues (MUST FIX before commit)

### P0-1: `safety_design.anti_patterns` block deleted (data-loss regression, NOT in handoff scope)

**File:** `.tad/domains/ai-agent-architecture.yaml`
**Location:** Lines 729-734 (pre-Phase-4) → REMOVED in current working tree
**Diff evidence:** `git diff HEAD .tad/domains/ai-agent-architecture.yaml | grep '^-[^-]'` returns 7 deleted lines:
```
-    anti_patterns:
-      - "❌ 'Please don't be harmful' in prompt（LLM-only safety 不可靠）"
-      - "❌ 无 budget limit（无限循环 = 无限成本）"
-      - "❌ Safety 作为事后添加（必须从设计阶段开始）"
-      - "❌ 只测 happy path（必须做对抗测试）"
-      - "❌ Fail-open 降级（安全检查挂了就放行 = 最危险的模式）"
-      - "❌ 无 circuit breaker（3 次同错还在重试 = 浪费 + 风险）"
```

**What the handoff actually said** (§3 P4.4 #4):
> **Pattern: Bilingual Blocklist as Minimum** → `safety_design.quality_criteria`

The handoff instructed adding ONE quality_criteria entry. It did NOT instruct removing the entire `anti_patterns:` block. The implementation co-mingled the two operations: when adding the Bilingual Blocklist line to `quality_criteria` at the bottom of that block, the surrounding `anti_patterns:` section got silently deleted.

**Verification (`python` yaml.safe_load):**
```python
sd = caps['safety_design']
print('safety_design has anti_patterns?:', 'anti_patterns' in sd)
# → False
```

`safety_design` is the only capability in `ai-agent-architecture.yaml` (out of 9 total) that no longer has an `anti_patterns:` block. The other 8 all still do. This is a regression, not a design choice.

**Impact:**
1. **Functional regression** — six pre-existing safety design anti-patterns disappear. Future agent-runtime safety design audits using this pack will not see "❌ Fail-open 降级" or "❌ 无 circuit breaker" — exactly the foundational anti-patterns the pack was designed to surface. This is real loss-of-knowledge.
2. **Audit trail violation** — handoff promised "Add 5 items"; implementation added 5 + DELETED 6. Net change is -1 anti-pattern, +5 elsewhere. Gate 4 verification scoped to "additions" misses the deletion.
3. **AC-G1 false-positive avoidance** — there's an irony here: the deleted "❌ Fail-open 降级" anti-pattern is one of the lines that would have continued to be a positive Phase-4 carryover, *not* a mechanical-enforcement keyword. Nothing in AC-G1 motivates this deletion.

**Required fix:**
Restore the `anti_patterns:` block to `safety_design` between `quality_criteria:` and `reviewers:`. Add the 6 original entries verbatim. Decide where the Bilingual Blocklist belongs — handoff §3 says `safety_design.quality_criteria` (current placement is correct). Do NOT move the Bilingual Blocklist itself.

```yaml
    quality_criteria:
      - "三轨威胁模型..."
      ...
      - "编造安全机制 = FAIL"
      # P4.4.4 (2026-04-25): Bilingual Blocklist as minimum.
      - |
        Pattern: Bilingual Blocklist as Minimum — ...

    anti_patterns:        # ← RESTORE
      - "❌ 'Please don't be harmful' in prompt（LLM-only safety 不可靠）"
      - "❌ 无 budget limit（无限循环 = 无限成本）"
      - "❌ Safety 作为事后添加（必须从设计阶段开始）"
      - "❌ 只测 happy path（必须做对抗测试）"
      - "❌ Fail-open 降级（安全检查挂了就放行 = 最危险的模式）"
      - "❌ 无 circuit breaker（3 次同错还在重试 = 浪费 + 风险）"

    reviewers:
      ...
```

After fix: rerun `yq eval '.' .tad/domains/ai-agent-architecture.yaml > /dev/null && echo OK` and re-spot-check `git diff HEAD --stat .tad/domains/ai-agent-architecture.yaml` — expect ≈ +94 / -1 (only the trailing blank-line change), instead of +87 / -7.

**Severity rationale:** This is the same failure mode as the *Verify Before Delete* MEMORY entry — a "delete during edit" silent regression. The user has explicit prior feedback against this pattern. Must fix before commit.

---

## P1 — Important Issues (Should Fix)

### P1-1: `design_iteration_decisions` capability is incomplete (missing quality_criteria + anti_patterns + reviewers)

**File:** `.tad/domains/web-ui-design.yaml`
**Location:** Lines 802-839 (the new capability)
**Evidence:**
```python
did = caps['design_iteration_decisions']
list(did.keys())
# → ['description', 'type', 'steps']
```

This new capability has only 3 fields — `description / type / steps`. It is missing `quality_criteria`, `anti_patterns`, and `reviewers` blocks that every other Type A capability in the pack carries. Every other capability in `web-ui-design.yaml` (8 of them) has all 4-5 of those blocks.

**Impact:** Future agents consuming this pack via `yq '.capabilities.design_iteration_decisions.quality_criteria'` will get null. Any pack-driven gate that scans `quality_criteria` across all capabilities silently skips this one. The capability is structurally a stub, not production-ready.

**Recommendation:** Either:
1. **Preferred:** add at least 2-3 quality criteria + 2-3 anti-patterns + 1 reviewer persona to make this a complete capability, OR
2. **Alternative:** fold the two steps (`record_design_iteration_adr`, `warm_palette_interpretation`) into existing capabilities (`design_system` or `visual_design`) the same way P4.4.5 was folded into `safety_design`. The handoff §3 P4.11.3 / P4.11.4 says "(unchanged from v1)" but this is the first implementation of those items, so v1 ≠ "already exists" — there is no prior version that defines its placement. Folding is consistent with the BA-P1-1 ceremony principle ("one pattern doesn't justify a new capability").

This is P1 not P0 because YAML parses cleanly and the grep AC passes. But it's a structural inconsistency that future readers will hit.

---

## P2 — Suggestions

### P2-1: `reference_implementations:` is a novel schema field; document it

**File:** `.tad/domains/code-security.yaml`
**Location:** Lines 346-371

The new `reference_implementations:` field added under `dast_scan` is a one-off. No other Domain Pack uses this field. The handoff §3 P4.8 authorized "→ `dast_scan` 或新 step" so this is in-scope, but for ecosystem consistency consider:
- Either codify `reference_implementations:` in `.tad/domains/HOW-TO-CREATE-DOMAIN-PACK.md` so future packs can adopt it
- Or convert the 7-Layer SSRF reference into a `step` with `id: reference_safe_fetch_7_layer_ssrf` and the layer list in the `action:` block

Not blocking. Future Phase 5/6 design item.

### P2-2: `boundary` text stored as YAML string with `# ` prefix (not a YAML comment)

**File:** `.tad/domains/code-security.yaml`
**Location:** Line 369-371 (boundary block scalar)

The handoff §3 P4.8 shows the boundary as YAML *comments* (literal `# Boundary: ...` lines). The implementation stores it as a string value within `reference_implementations[0].boundary:` field. The first chars of the string are `# Boundary:` so it grep-matches both required keywords (BA-P1-4 PASS), but functionally these are different YAML constructs:
- True YAML comments are stripped on parse and never reach the consumer.
- String values with `#` prefix DO reach the consumer (as content).

The implementation is actually MORE useful — the boundary text becomes machine-readable. But the comment-style `# ` prefix at the start of every line is now noise (it's not a comment, it's just text). Consider dropping the `# ` prefix in a follow-up:

```yaml
        boundary: |
          Boundary: Agent-runtime SSRF (LLM-controlled URL fetching) belongs to
          ai-security pack (Security Chain EPIC-20260403 Phase 2). This capability
          covers the deterministic server-side fetcher only.
```

Not blocking. Stylistic.

### P2-3: Anti-AI-slop content is "verbatim with Chinese gloss appended", not pure verbatim

**File:** `.tad/domains/web-ui-design.yaml`
**Location:** Lines 296-313 (visual_design.quality_criteria + anti_patterns)

The Anthropic frontend-design SKILL.md content is lifted with added Chinese hint suffixes like `→ 选 distinctive 字体`, `→ 选有人格的 palette`. These hints are NOT in the original Anthropic source — they're Alex's translation gloss to make the content more usable for Chinese-speaking users.

**License-wise:** This is fully permitted under Apache 2.0 §4 (modifications allowed with attribution preserved). The `license-check.md` evidence file correctly notes this: *"Modifications (translation to Chinese for `Bold aesthetic direction committed`, etc.) are permitted under Apache 2.0 §4 (modifications)"*.

**Stylistically:** The handoff §3 / Decision #11 calls this "verbatim lift" + "Verbatim attribution required (not paraphrase)". The current implementation is a hybrid — verbatim English + Chinese gloss. Recommend updating the inline attribution comment from:
```yaml
# Source: Anthropic skills/frontend-design/SKILL.md, Apache 2.0, retrieved 2026-04-25.
```
to:
```yaml
# Source: Anthropic skills/frontend-design/SKILL.md (Apache 2.0, retrieved 2026-04-25)
# Modified per Apache 2.0 §4: translated arrows + Chinese guidance suffixes appended to original anti-patterns.
```

This makes the modification explicit per Apache 2.0 §4(b) which requires marking modifications. Optional, not blocking — current attribution is legally sufficient.

### P2-4: `architecture.md` Phase 4 entries are excellent

Acknowledging good practice. Both new entries use the **Grounded in:** + **Revalidated:** format introduced by Phase 2, cross-reference 4-6 distinct file:section anchors each, and explicitly cite prior architecture.md learnings (Standalone Agent Command Pattern, Type A/B/Mixed, Tool Availability Boundaries). The "Anti-AI-Slop Philosophy as a Cross-Pack Quality Bar" entry's *Cross-pack applicability* sub-section is a particularly strong instance of the "abstract the pattern" reflex the project knowledge layer is supposed to encourage.

---

## AC-G1 Two-Part Verification — Confirmed Correct

User asked specifically about whether the two-part literal+diff interpretation is right. **Yes, the diff-based interpretation is correct, and the evidence file (`anti-epic1-grep.txt`) documents it well.**

Confirming logic:
1. **Literal interpretation** of AC-G1 ("0 hits across full file scope") is **unsatisfiable** because `architecture.md` contains 36 pre-existing hits in historical learning entries from Epic 1a/b/c spikes (2026-04-07 through 2026-04-15, all dating *before* Phase 4 even started). Those entries are legitimate, valuable knowledge — deleting them would erase Epic 1's learnings.
2. **AC-G1 INTENT**, per handoff §10 audit trail and §3 task descriptions, is to verify Phase 4 introduces **no new** mechanical-enforcement patterns into Domain Packs or knowledge files. The diff-based check (`git diff HEAD ... | grep '^+' | grep -E '<patterns>'`) achieves exactly that.
3. The diff-based check returns 0 hits. ✅
4. Phase 4 is purely YAML content + 1 markdown knowledge entry — no settings.json, no hooks, no shell scripts. Verified by checking the working tree: 8 YAML files + 1 Epic .md + 1 architecture.md, no `.claude/settings.json`, no `.tad/hooks/*.sh` modifications.

**The handoff AC-G1 wording itself has a latent bug** (literal grep can never pass on architecture.md), but the evidence file's two-part documentation handles it transparently and correctly. Recommend Alex tighten the AC wording in future similar handoffs to scope the literal grep to **only files added/modified by this handoff** — i.e., `git diff HEAD --name-only | xargs grep -E ...` rather than `grep -rE ... .tad/domains/*.yaml .tad/project-knowledge/*.md`. This is a Phase 5/6 handoff-template improvement, not a Phase 4 blocker.

---

## Cross-Link Integrity Audit

| Link Direction | From | To | Status |
|----------------|------|----|----|
| P4.3.2 → P4.4.2 | `ai-prompt-engineering.yaml:68` ("ai-agent-architecture.yaml `reliability_design.steps` (P4.4.2)") | `ai-agent-architecture.yaml:131-145` (`cross_link_capability_declaration` step) | ✅ Verified bidirectional |
| P4.4.2 → P4.3.2 | `ai-agent-architecture.yaml:136` ("ai-prompt-engineering.yaml `system_prompt_design.steps.derive_prompt_architecture` step 5b for prompt-side implementation.") | `ai-prompt-engineering.yaml:62-68` (step 5b) | ✅ Verified bidirectional, literal text matches handoff CR-P2-3 spec |
| P4.8 → EPIC-20260403 | `code-security.yaml:371` ("ai-security pack (Security Chain EPIC-20260403 Phase 2)") | `EPIC-20260403...md:71` ("#### Phase 2 ai-security scope notes (P4.8 backref, 2026-04-25)") | ✅ Verified bidirectional |
| P4.11.1 references | `web-ui-design.yaml:786-797` (3 URLs: Google Labs design.md repo + spec + Anthropic SKILL.md) | All 3 URLs match handoff §3 P4.11.1.references block | ✅ All present, license_verified field present for both repos |

---

## Scope Budget

| Metric | Value | Limit | Status |
|--------|-------|-------|--------|
| Total + lines | 394 | n/a | — |
| Total - lines | 8 | 0 (post-fix) | ⚠️ 7 are P0-1 unintended deletions |
| Net lines | 386 | 290-300 estimate | Within tolerance |
| Hard escalation threshold | 386 | 400 | ✅ Below threshold |
| Files modified | 10 | 11 (incl. README.md, deferred) | Per BA-P0-2 sequencing, README modification correctly deferred |

---

## AC Verification Summary

| AC | Status | Notes |
|----|--------|-------|
| AC-{P4.x}-a × 8 (YAML parse) | ✅ PASS | All 8 modified packs `yaml.safe_load` clean |
| AC-{P4.x}-b × 21 (keyword grep) | ✅ PASS | All 21 items present per `keyword-grep.txt` |
| AC-G1 (anti-Epic-1 diff-based) | ✅ PASS | 0 newly-introduced mechanical-enforcement lines |
| AC-G2 (21 specific greps) | ✅ PASS | Same as above |
| AC-G3 (dogfood) | ✅ PASS | handoff frontmatter `skip_knowledge_assessment: no`, §6 Grounded Against present |
| AC-G4 (≥2 architecture.md entries) | ✅ PASS | 2 entries, 1 is "DESIGN.md spec integration", both use Grounded in / Revalidated format |
| AC-G5 (license verification) | ✅ PASS | Both repos verified Apache 2.0 in `license-check.md` |
| AC-P4.6-c (README LAST) | ⏸ DEFERRED | Per BA-P0-2, only after AC-P4.11 PASS. Current state (0 README hits) is expected. |

---

## Final Verdict

**CONDITIONAL PASS — fix P0-1 before commit.**

After P0-1 fix (restore `safety_design.anti_patterns` block in `ai-agent-architecture.yaml`):
- Re-run `python3 -c "import yaml; yaml.safe_load(open('.tad/domains/ai-agent-architecture.yaml'))"` to confirm parse still clean
- Re-run `git diff HEAD --shortstat .tad/domains/ai-agent-architecture.yaml` to confirm `-` count drops to 0 or 1 (only the trailing blank-line shift)
- Update `keyword-grep.txt` to spot-check that none of the 21 grep ACs were tied to the removed `anti_patterns:` block (they aren't — confirmed via re-reading §4.5)
- Then proceed to Gate 3.

P1-1 (`design_iteration_decisions` incomplete) and P2-1/2/3 are noted for follow-up but do not block Gate 3. Recommend Alex's Gate 4 review acknowledge P1-1 explicitly so it doesn't silently ship as a "complete" capability.

**P0 issues:** 1 (data loss in safety_design.anti_patterns)
**P1 issues:** 1 (incomplete capability structure)
**P2 issues:** 3 (novel schema field, comment-style string, modification marking)

Architecture, cross-link integrity, license attribution, AC-G1 verification approach, scope budget, and dogfood meta-trifecta all check out. The work is one targeted restoration away from clean Gate 3.
