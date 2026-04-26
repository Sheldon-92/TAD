# backend-architect Review — HANDOFF-20260425-phase6a-process-quality-foundation

**Reviewer:** backend-architect (sub-agent, parallel to code-reviewer)
**Date:** 2026-04-25
**Scope:** Cross-system architectural consistency for P6-A
**Subsystems verified:**
- (a) Alex SKILL `handoff_creation_protocol.workflow` — step1d insertion
- (b) Blake SKILL `gate3_v2.layer2_expert_review` — hard_requirement_distinct_reviewers
- (c) `.tad/templates/handoff-a-to-b.md` §9.2 dual-column
- (d) `.tad/hooks/lib/layer2-audit.sh` reviewer-name detection upgrade

---

## 1. P0 (Blocking — must fix before Blake starts)

### [P0-1] hard_requirement_distinct_reviewers `forbidden_implementations` is asymmetric (4 items vs the 5+ baseline of every sibling AR-001 defense)

**Where:** §3.1 FR3 (handoff lines 311–317), Blake SKILL after install
**Why blocks Blake:** Phase 3 Path Layering (architecture.md 2026-04-24) established that **every** prompt-level enforcement block guarding an AR-001 attack surface must replicate the same `forbidden_implementations` shape across siblings. Verified actual baselines on disk:
  - Alex SKILL `step1c.forbidden_implementations` → **6 items** (alex/SKILL.md:1876–1882)
  - Alex SKILL `express_path_protocol.forbidden_implementations` → **5 items** (alex/SKILL.md:1036–1041)
  - Blake SKILL `completion_knowledge_override.forbidden_implementations` (P3.3 skip_KA) → **5 items** (blake/SKILL.md:1206–1211)
  - **FR3 in this handoff → 4 items** (the only odd-one-out)
  - **FR1 step1d in this handoff → 5 items** ✅ matches baseline

The Path Layering knowledge entry literal text: *"a 'but skip_KA is just a frontmatter field, surely it doesn't need the same defense' rationalization is exactly what creates the next disaster path"*. The same logic applies here: a future Alex/Blake may rationalize "Layer 2 reviewer-count is just an audit script concern, surely it doesn't need the full 5-item defense." The asymmetry creates exactly the hole Phase 3 BA-P0-3 closed.

**Specific gap:** the FR3 list is missing a 5th item explicitly forbidding `permissions.deny` registration (separate from `settings.json` inclusion — these are two distinct attack surfaces; settings.json may register a hook that returns 0 vs. a deny-exit hook vs. a `permissions.deny` array entry). Both step1d and skip_KA list these as distinct items.

**Fix:** Bring FR3 to 5 items, mirroring P3.3:
```yaml
forbidden_implementations:
  - "MUST NOT register PreToolUse / PostToolUse / UserPromptSubmit hook to count reviewers"
  - "MUST NOT add to .claude/settings.json"
  - "MUST NOT return deny exit code from any wrapping script that counts reviewers"
  - "MUST NOT couple Layer 2 reviewer count to step4c audit script — Blake invokes the sub-agents based on judgment, audit is downstream advisory"
  - "Anti-AR-001: 'this task is simple, code-reviewer covers it' is forbidden interpretation for non-*express paths — must add ≥1 domain expert by task fit"
```

---

### [P0-2] Reviewer-whitelist drift surface — 2 separate sources of truth with no cross-reference

**Where:**
- Blake SKILL `hard_requirement_distinct_reviewers` enumerates **4 domain experts** (FR3 §3.1 lines 298–302): backend-architect, security-auditor, performance-optimizer, ux-expert-reviewer
- layer2-audit.sh `KNOWN_REVIEWERS` enumerates **8 names** (FR4 §4.3 line 440): code-reviewer, backend-architect, security-auditor, performance-optimizer, ux-expert-reviewer, api-designer, data-analyst, bug-hunter

**Why blocks Blake:** these two lists serve overlapping purposes (both gate "is this artifact a valid Layer 2 reviewer?") and **will silently drift** unless the relationship is named. Concrete failure scenario:
  - Future handoff legitimately uses `api-designer` as Layer 2 reviewer (allowed by audit script's KNOWN_REVIEWERS)
  - Blake SKILL's hard_requirement_distinct_reviewers domain-expert list says only 4 names — does `api-designer` satisfy "≥1 domain expert"?
  - Blake reads SKILL strictly → invokes `api-designer` plus `backend-architect` to be safe (over-invocation)
  - OR Blake reads SKILL liberally → invokes only `code-reviewer + api-designer`, audit PASSes (counts as distinct), but Blake SKILL strict rule was technically violated
  - Either way: drift symptom is *invisible* until someone re-reads both files side-by-side. This is the exact failure mode of Phase 4 P4.11.1's "Read-only consumption requires explicit contract" lesson (architecture.md 2026-04-25).

**Fix:** in **Blake SKILL** `hard_requirement_distinct_reviewers`, change the 4-name enumeration to a **superset reference** with explicit relationship to the audit script's whitelist:
```yaml
rule: |
  Layer 2 MUST invoke ≥2 DISTINCT sub-agents:
  - code-reviewer (REQUIRED — every Layer 2 round)
  - PLUS ≥1 from layer2-audit.sh's KNOWN_REVIEWERS whitelist
    (currently: backend-architect, security-auditor, performance-optimizer,
    ux-expert-reviewer, api-designer, data-analyst, bug-hunter; extensible
    per .tad/hooks/lib/layer2-audit.sh KNOWN_REVIEWERS array — Blake adds
    new sub-agent types there at first use)
  - Choose by task fit (architecture/security/perf/UX) — see below
extension_protocol: |
  When a new sub-agent type is used as Layer 2 reviewer for the first time:
  add the name to layer2-audit.sh KNOWN_REVIEWERS array (single source of
  truth). Blake SKILL only references the array, never enumerates names.
```

This makes the audit script the **canonical list**, the Blake SKILL the **judgment guide**, and prevents drift by structural design (Aggregation Layer pattern, architecture.md 2026-02-16).

---

### [P0-3] FR4 mentions `task_type: express` frontmatter, but template forbids that value

**Where:** §3.1 FR4 line 335 ("Express path detection: ... handoff frontmatter `task_type: express`")
**Why blocks Blake:** the template `.tad/templates/handoff-a-to-b.md` line 3 declares the legal `task_type` enum: `code | yaml | research | e2e | mixed`. **`express` is NOT in this set.** Alex SKILL `step1b.frontmatter Validation` rule (alex/SKILL.md:1830–1834) literally says `task_type: must be one of: code, yaml, research, e2e, mixed` and `frontmatter 字段缺失或值非法 = VIOLATION — 不能继续 step2`.

If Blake implements the audit script to detect `task_type: express` from frontmatter, the detection branch will **never fire** because no valid handoff can ever have that frontmatter value — frontmatter validation in Alex SKILL step1b would block the handoff before it ships. This is dead code.

**How express paths are actually identified** in the codebase (verified via grep):
  1. Filename slug — `*express*` substring in HANDOFF-YYYYMMDD-{slug}.md (loose, but used by Alex express_path_protocol.scope_constraints)
  2. Path-state lifecycle — Alex SKILL Intent Router routes `*express` activation_word to express_path_protocol; **no frontmatter field**
  3. Required-steps text — `expert review with ≥1 expert (code-reviewer 必选)` in alex/SKILL.md:1022

There is **no frontmatter `task_type: express` mechanism today**. Adding it to layer2-audit.sh detection would either (a) require a template/schema change that's out of P6-A scope, or (b) silently never match.

**Fix:** Replace FR4's express detection with the only mechanism that works today:
```
Express path detection (filename slug only, best-effort):
  if [[ "$slug" == *express* ]]; then is_express=1; fi
Document explicitly: "Frontmatter field NOT used — task_type enum
(code|yaml|research|e2e|mixed) does not include 'express'; express
is a path-state, not a frontmatter classification."
```
Also strike "OR handoff frontmatter `task_type: express`" from §3.1 FR4 line 335.

---

### [P0-4] AC-P6A-2-b enumerates exactly 4 names; if P0-2 fix is taken, AC must change

**Where:** §9.1 AC-P6A-2-b (line 647) and §9.2 AC table row 4 (line 682)
**Why blocks Blake:** AC-P6A-2-b says "block enumerates 4 domain experts (backend-architect, security-auditor, performance-optimizer, ux-expert-reviewer)". §9.2 row 4 verification command:
```
grep -A 20 'hard_requirement_distinct_reviewers' .claude/skills/blake/SKILL.md \
  | grep -cE 'backend-architect|security-auditor|performance-optimizer|ux-expert-reviewer'
```
Expected: **= 4**.

If Blake adopts the P0-2 fix (reference KNOWN_REVIEWERS instead of inline enumeration), the SKILL block will **not** literally contain all four hyphenated names on consecutive lines — and AC-P6A-2-b will FAIL even though the architectural intent is satisfied. This is exactly the AC drift pattern the handoff is meant to prevent (P5 self-dogfood failure: AC text says one thing, post-impl reality is another).

**Fix:** change AC-P6A-2-b + §9.2 row 4 to verify the canonical-source pattern:
```
AC-P6A-2-b: hard_requirement_distinct_reviewers block references the audit
  script's whitelist with the literal phrase "KNOWN_REVIEWERS" (or equivalent
  pointer to layer2-audit.sh as canonical source). Forbids inline enumeration.
Verification: grep -c 'KNOWN_REVIEWERS\|layer2-audit\.sh' \
  .claude/skills/blake/SKILL.md ≥ 1
```
This makes AC-P6A-2-b verify the **structural single-source-of-truth invariant**, not the **textual presence of 4 names**.

---

### [P0-5] Self-dogfood circularity not actually resolvable — concern §5 raises a real ordering issue, but §10.1 only handwaves it

**Where:** §10.1 "Self-dogfood Layer 2" warning (line 746) + §6.2 Stage D (line 537–539)
**Why blocks Blake:** the handoff's §10.1 says "本 handoff 自身的 Layer 2 必须调 ≥2 distinct sub-agents". §6.2 Stage D step 7 says "Run `layer2-audit.sh phase6a-process-quality-foundation` after Layer 2 reviews land — should PASS with ≥2 distinct reviewers". The concern from the review prompt: **does this handoff's Layer 2 audit run on the OLD audit script (counting files only) or the NEW one (counting names)?**

This isn't just an academic ordering question — it determines whether AC-P6A-4-a/b can pass. Walking through the actual call graph:
  1. Stage A → micro-tasks 1, 3 (SKILL edits) — no audit runs yet
  2. Stage B → micro-task 4 (`layer2-audit.sh` enhancement) — script changes
  3. Stage D step 7 — runs the **enhanced** audit on this very handoff
  4. Layer 2 reviewers (code-reviewer + backend-architect, this artifact and the parallel one) were created by Blake **after** Stage A but the artifact filenames must conform to the new whitelist

What's missing: **§6.2 Stage D does not order "Layer 2 reviewer artifacts created" relative to "audit run".** If Blake runs Stage D step 7 before Layer 2 sub-agents complete and write their .md files, the audit will FAIL (no artifacts in dir) — not because the rule failed, but because of stale ordering.

**Fix:** add explicit ordering to §6.2 Stage D:
```
Stage D (sequential verification):
  D.1 Run all fixtures (FR5 + FR6)
  D.2 Run §9.2 AC verification commands (use this handoff's own §9.2 as smoke)
  D.3 Layer 2 sub-agent invocations (code-reviewer + backend-architect)
      — artifacts land in .tad/evidence/reviews/blake/phase6a-process-quality-foundation/
  D.4 Run `bash layer2-audit.sh phase6a-process-quality-foundation`
      — expected: PASS with 2 distinct reviewers (code-reviewer + backend-architect)
  D.5 Run integration test on Phase 5 slug — expected: WARN (retroactive demo)
```
And document: "D.4 uses the **new** audit script (post-FR4). Self-dogfood is mechanically valid because by D.4 the new script is on disk and the new SKILL rule (FR3) was already satisfied during D.3 by Blake's sub-agent invocations — so 'rule installed' precedes 'audit checks rule installed correctly'. The audit is downstream advisory of Blake's actual choice."

This collapses the chicken-and-egg into a clear linear sequence and makes the resolution mechanically inspectable.

---

## 2. P1 (Should fix — non-blocking but improves robustness)

### [P1-1] step1d "exemption_pre_phase6" exemption logic ambiguity

**Where:** §3.1 FR1 lines 247–249 (step1d.exemption_pre_phase6)
**Discussion:** the exemption text says "filename date < 2026-04-25 OR no §9.2 dual columns". This is an **OR**, which means a handoff drafted *after* 2026-04-25 that happens to lack dual columns (because Alex forgot or the template wasn't yet synced to consumer projects) auto-exempts itself from step1d. That's the wrong direction — post-phase-6 missing dual columns is *exactly* the drift we want to catch.

**Fix:** make it AND, not OR:
```
exemption_pre_phase6: |
  Pre-Phase-6 handoffs are exempt only when BOTH conditions hold:
    (a) filename date < 2026-04-25
    AND (b) §9.2 has no Verification Type / Verified Output columns
  If filename date ≥ 2026-04-25 but §9.2 lacks dual columns:
    NOT exempt — Alex must update §9.2 to dual-column format AND run step1d
    (template was supposed to be updated before drafting; this catches drift)
```

### [P1-2] §6.6 "step2: block start" insertion ambiguity

**Where:** §6.6 row 1 "step1d: block insert AFTER step1c block end / BEFORE step2 block start"
**Discussion:** verified via grep — Alex SKILL has **15 distinct `step2:` keys** across many protocols (lines 337, 522, 680, 721, 778, 833, 875, 950, 1232, 1392, 1638, 1884, 2625, 2742, plus nested ones at 3398, 3485). The relevant `step2:` for `handoff_creation_protocol.workflow` is at **line 1884**. Without that line number anchor, Blake could insert step1d adjacent to the wrong step2.

**Fix:** in §6.6, change row 1 "Insert BEFORE" to:
```
"step2: at line ~1884 (the one inside handoff_creation_protocol.workflow,
sibling to step1c at ~1836). Verify by grepping the surrounding context
shows 'Expert Selection' as the step2 name."
```

### [P1-3] AC-P6A-1-b says ≥4 items in forbidden_implementations, but baseline is 5

**Where:** §9.1 AC-P6A-1-b (line 642) — "forbidden_implementations list with ≥4 items (mirrors step1c symmetric defense)"
**Discussion:** I verified step1c on disk has **6 items** (alex/SKILL.md:1876–1882), and FR1's step1d block as written has **5 items**. AC-P6A-1-b says "≥4" — that's lower than both. The symmetric-defense lesson (Phase 3 Path Layering) requires **the same number** as siblings, not "at least 4". The baseline across siblings (express, experiment, skip_KA) is **5**.

**Fix:** change AC-P6A-1-b to:
```
AC-P6A-1-b: step1d block contains forbidden_implementations: list with
  EXACTLY 5 items (matching express_path_protocol / completion_knowledge_override
  baseline; symmetric-defense per Phase 3 P3.1/P3.2/P3.3).
Verification: grep -A 50 'step1d:' .claude/skills/alex/SKILL.md \
  | awk '/forbidden_implementations:/,/^  [a-z]/' \
  | grep -cE '^\s*-\s*"' \
  → = 5
```
(awk range pattern bounded to next sibling key prevents over-counting.)

### [P1-4] Phase 6 sub-handoff promotion criterion absent

**Where:** §1.1 + §1.3 + Epic Phase Map note in frontmatter (handoff line 26)
**Discussion:** the handoff calls itself "P6-A — sub-handoff A of N" but never says **what triggers a new Phase 6 sub-handoff vs. promoting to Phase 7**. The review prompt explicitly flagged this. Without the criterion, future Alex sessions will have no rule for whether P6.4 / P6.7 / P6.8 land as P6-B, P6-C... or as Phase 7 / 8 / 9.

**Fix:** add one sentence to §1.3 Intent Statement:
```
Sub-handoff promotion criterion: a P6-X is created when the work targets
process discipline gray zones inside Phase 6's "assumption redesign" scope.
A new Phase number is created only when the work targets a new architectural
assumption (e.g., "Alex/Blake separation itself"). Sub-handoffs of Phase 6
share the same Epic record; new phases get new Epic records.
```

### [P1-5] FR4 backward-compat WARN exit code

**Where:** §3.1 FR4 line 337 ("Backward compat: existing exit codes preserved (0 PASS, 1 FAIL, 2 invalid-slug). Add WARN as exit 0 + stderr message (advisory).")
**Discussion:** verified actual layer2-audit.sh exit semantics (lines 30, 42, 84, 115, 126, 135): exit 0 = PASS, exit 1 = FAIL (multiple paths), exit 2 = usage/slug-invalid. Currently **PASS exits silently to stderr**; lines 113–114 in script: `# PASS: stdout only, stderr MUST be empty`. The "WARN as exit 0 + stderr message" plan **breaks the existing PASS-stderr-empty invariant** that downstream consumers (gate3-verdict generators, future CI parsers) might rely on.

**Fix:** Add to FR4 explicit acknowledgment:
```
WARN semantics (NEW — be aware of invariant change):
  - Existing PASS contract: exit 0, stdout has the message, stderr is empty
  - NEW WARN contract: exit 0, stdout has "Layer 2 audit WARN: ...",
    stderr has advisory hint; consumers grepping `2>/dev/null` get same
    user-facing signal but lose the WARN context — document this trade-off
  - Alternative considered: WARN as exit 3 (new code) — REJECTED because
    AC-P6A-4-d says exit code semantics preserved (still 0/1/2). Choose
    consistency over richness.
Verification: grep -cE '^[ \t]*exit (0|1|2)' .tad/hooks/lib/layer2-audit.sh
  must show only 0/1/2 after enhancement (no exit 3 introduced).
```

---

## 3. P2 (Nice to have — defer if time-constrained)

### [P2-1] Whitelist `feedback-integration` filtering rationale

**Where:** §3.1 FR4 (substitution exclusion list) and §4.3 SUBSTITUTIONS bash array
**Discussion:** `feedback-integration.md` is filtered as "synthesis doc, not a review." That's correct, but Phase 5 acceptance evidence shows feedback-integration.md is itself produced by Alex during expert-review-integration step — it's a *cross-reviewer aggregation*. If a future handoff produces a feedback-integration.md authored by a third-party sub-agent (not Blake/Alex), the filter would still drop it, possibly wrong. Nice-to-have: rename the variable `SYNTHESIS_FILES` to `SUBSTITUTION_HEURISTICS` and document the heuristic as "filename-based filter, not authorship-based" so future readers understand the limitation.

### [P2-2] §6.7 AC Dry-Run Log says "0 pre-impl-verifiable" but Verified Output column shows AC-G1 + AC-G2 ran

**Where:** §6.7 line 593 ("**Result**: 2/2 pre-impl-verifiable ACs PASS")
**Discussion:** §6.7 table says AC-G1 and AC-G2 are pre-impl-verifiable and ran. But the summary says "**No AC drift caught at draft time** (because all new content is post-impl)" — slight tension. AC-G1 was actually a useful smoke (`jq '.permissions.deny | length' → 0`). Worth re-phrasing summary to: "**Step1d prevented zero drift this round because 8/10 ACs are post-impl. Of the 2 pre-impl ACs, both verified clean — adversarial value of step1d will appear when handoffs have proportionally more pre-impl ACs.**" Frames step1d's value better.

### [P2-3] AC-P6A-4-c expected stderr message format underspecified

**Where:** §9.1 AC-P6A-4-c line 658
**Discussion:** "verify via stderr message listing only valid reviewer names" — but what's the expected literal? Without a regex anchor, Blake might satisfy this via "found: code-reviewer" (correctly excluding self-review), but a future maintainer can't tell what message shape is canonical. Add a literal example to the AC for grep verifiability.

---

## 4. Overall Assessment

**Verdict: CONDITIONAL PASS**

The handoff is well-structured, properly grounded (§6.5), correctly identifies the 2 gray zones and matches them to the right intervention layers, respects Anti-Epic-1 throughout (verified: zero hooks, zero permissions.deny, advisory CLI preserved), and self-dogfoods the new mechanism. The 5 P0 issues are **architectural integrity gaps**, not design flaws — fix them and the handoff is ready to ship.

The handoff's strongest point: **scoping discipline.** Resisting the temptation to do P6.1–P6.8 in one mega-handoff and instead carving out "process quality first, assumption redesign next" matches the Minimal Viable Cross-Cutting Enhancement pattern (architecture.md 2026-02-19). Decision row 4 ("Only Gray Zones") is the right call.

The handoff's weakest point: **the asymmetry between the FR1 step1d block (5-item forbidden, follows precedent) and the FR3 hard_requirement_distinct_reviewers block (4-item forbidden + duplicated reviewer-name list with no canonical source pointer)**. P0-1 + P0-2 + P0-4 are the same root cause — FR3 was drafted with less discipline than FR1. Fixing them together is one coordinated edit.

**Required to upgrade to PASS:**
- Fix all 5 P0 issues
- Re-run §9.2 AC verification commands after AC text changes from P0-4 (because the grep regex changes too)
- Update §11.2 Decision row to reflect P0-2 resolution: "Reviewer whitelist: canonical source = layer2-audit.sh KNOWN_REVIEWERS array; SKILL references the array, never enumerates inline"

**Recommended (not blocking):**
- Adopt P1 fixes for documentation clarity
- P2 items can be addressed in P6-B if scope allows

**Self-dogfood verdict:** This very review (parallel to code-reviewer.md) satisfies the new ≥2-distinct-reviewer rule that FR3 installs. The chicken-and-egg dissolves once P0-5 ordering fix is applied — Layer 2 sub-agents (code-reviewer + backend-architect) write artifacts BEFORE Stage D.4 audit, so the audit script sees the artifacts and reports PASS.

---

**File:** /Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/reviews/alex/phase6a-process-quality-foundation/backend-architect.md
