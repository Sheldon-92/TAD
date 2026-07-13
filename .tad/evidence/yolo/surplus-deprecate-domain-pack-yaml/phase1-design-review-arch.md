# Phase 1 Design Review — Architecture Lens

**Handoff:** HANDOFF-surplus-deprecate-domain-pack-yaml.md
**Reviewer:** Backend / knowledge-system architecture (default lens — no frontend/API-DB/auth files in scope)
**Date:** 2026-07-06
**Scope:** §4.1 classification rule, §4.3 frontmatter schema, §9.1 AC suite, NFR1-3, system-level blast radius
**Verdict:** CONDITIONAL — 1 P0, 2 P1, 4 P2. The migration *pipeline* (mirror via `diff -rq`, archive-immutability, scope fences) is sound and needs no change. The defects are all in the **acceptance layer** and in **system-level blast radius**, not the mechanics.

> Note on prior review: an earlier architecture review (its P0 = "§4.1 omits anti_patterns/quality_criteria/reviewers routing") has already been **integrated** into the current handoff — §4.1 now routes all three and AC13 was added. This re-review verifies the current state and finds the integrated fix (AC13) is itself defective, plus residual systemic gaps.

Ground truth re-verified live: 9 source YAMLs (7,132 lines), precedent pack, README-retired, hook absence, `anti_patterns` block counts (7/pack ×8, 5 for supply-chain) all match the handoff. Registry size does **not**.

---

## P0 — Blocking

### P0-1: AC13 (the anti_patterns SAFETY-survival gate) compares mismatched units and inflates the target — it cannot detect constraint loss
AC13 was added by a prior design-review specifically to enforce the SAFETY lesson "Constraint Rules Are NOT Mechanical" (principles.md 2026-04-04). As written it does not work:

- **Source side** `grep -c 'anti_patterns:'` counts `anti_patterns:` **keys** = one block per capability. Verified: 7 blocks for 8 packs, 5 for supply-chain. Each block holds **multiple** `❌ never / MUST-not` items.
- **Target side** `sed -n '/## Anti-Patterns/,/^## /p' | grep -cE '^\s*[-|]'` counts **markdown table lines**, and it also counts the table **header** (`| Bad | Why |`) and **separator** (`|---|---|`) rows. Verified on a fixture: a 2-data-row table returns **4**.

Two compounding defects:
1. **Unit mismatch**: floor is "7 blocks" but the measured quantity is "N rendered rows." A pack that preserves only 3 of ~7 capability-worth of anti-patterns can still exceed 7 rows and pass, while real constraints are silently dropped.
2. **Chrome inflation**: header + separator give 2 free counts per pack, further lowering the effective bar.

This is exactly the "**A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover SAFETY Loss**" failure (principles.md 2026-06-01), reintroduced inside the very AC meant to prevent it.

**Fix:** count anti-pattern *items* in the same unit on both sides. Source = list items under each `anti_patterns:` block (not the block key). Target = data rows only (strip header + `|---|` separator; or match rows containing a MUST/never/❌ token). Assert `target_items >= source_items` per pack, and record the per-pack **item** baseline (not block count).

---

## P1 — High

### P1-1: Validation theater — quality_criteria and reviewers are routed but have no survival AC; only anti_patterns is gated (and that gate is broken)
§4.1 now routes three rich per-capability sections — verified counts per pack: `anti_patterns=7`, `quality_criteria=7`, `reviewers=7` (supply-chain: 5/5/inline). But the AC suite has a survival check for **only** `anti_patterns` (AC13, itself broken per P0-1). `quality_criteria` (pass/fail acceptance rules) and `reviewers`/`persona` checklists have **no positive AC** — a pack can drop all of them and still pass every green check (AC5's anti-dump grep only looks for `tool_ref:|output_file:|requires_registry:`; the ≤250-line cap is satisfied by a *thinner* file). 12 of 13 ACs are structural (existence, line count, frontmatter keys, `diff`, scope). The handoff names the failure ("漏读源内容 → SKILL.md 空洞 → Gate 3 FAIL") but no AC operationalizes "空洞." This is the project's own "Validation Theater" principle (YOLO audit 2026-05-15: structural checks prove files exist, not that content survived).

**Fix (per "verify presence per-CATEGORY, not a global floor," principles.md 2026-06-01):** add per-pack survival ACs symmetric to a fixed AC13 for `quality_criteria` (each source block traceable to a body rule or reachable `references/quality-criteria.md`) and `reviewers` (a `references/review-checklist.md` exists and is body-reachable). Even a coarse body-scoped constraint-token floor (`grep -ciE 'MUST|never|❌' SKILL.md >= N_from_source`) is better than zero fidelity signal.

### P1-2: Blast radius unanalyzed — the registry is already past the project's own 50-pack saturation threshold, and the handoff's "24 packs" is stale
NFR2 says "24 existing active packs." Verified on disk: `.claude/skills/` holds **48 skill directories** today (packs + control skills), all of whose `description` lines are injected into the skill list at **every session start**. Adding 9 always-listed hw/mobile/supply-chain descriptions — irrelevant to ~99% of TAD self-development sessions — is a permanent system-prompt tax. The project's **own** principles.md (YOLO audit 2026-05-15) flags "Rule Soup / Context Saturation … will choke reasoning at 50+ packs" and mandates a `step4_5` max-2-concurrent-load guardrail. We are already at the threshold and going past it with **zero blast-radius analysis** in the handoff, and the design reasons from a stale count (24) that understates the real registry by 2×.

**Fix:** add a "Registry impact" note: correct the count, confirm the post-migration total is within the discovery budget, keep each `description` tight, and confirm the max-2-concurrent-load guardrail still holds so 9 domain packs never co-load with unrelated packs. Not a blocker to authoring, but must be acknowledged, not silent.

---

## P2 — Medium

### P2-1: AC13 / §4.1 are coupled to a heading string that is mis-cited and case-sensitive — false-FAIL risk under parallel authoring
§4.1 tells Blake to model anti-patterns on "ai-voice-production **L111-125 的 `## Anti-Patterns` MUST-table 形态**." Verified: that pack has **no `## Anti-Patterns` section**; L115 is `## Anti-Skip Table`. The cited precedent does not exist as described. Meanwhile AC13's `sed -n '/## Anti-Patterns/,/^## /p'` requires the **exact, case-sensitive** heading `## Anti-Patterns`, yet **no FR mandates that heading**. With parallel sub-agents (hw×4 / mobile×4 recommended in §10.3), one agent writing `## Anti-patterns` or `## Anti-Patterns to Avoid` yields `got=0` → false LOST on a correct pack.
**Fix:** correct the citation (real analog = `## Anti-Skip Table`); promote the required heading to an explicit FR; make the AC range case-insensitive.

### P2-2: AC5 / AC13 use `\s`, violating the handoff's own NFR3 (masked only by ugrep)
NFR3 requires "no GNU-only flags." `\s` is PCRE/GNU, not POSIX ERE. It works here only because `grep` resolves to **ugrep 7.5.0** (`grep --version` verified). On stock macOS BSD grep `\s` is not the whitespace class. Since `.agents/skills/` exists for **Codex parity** and ACs may re-run in another shell, this is a latent portability defect.
**Fix:** `\s` → `[[:space:]]` (verified equivalent); sweep all ACs.

### P2-3: NFR1 uniform ≤250-line cap collides with SAFETY constraint-preservation on the largest packs
Capabilities per pack range 7→17 (verified: supply-chain-security ~17, hw-enclosure/hw-firmware ~12). A uniform ≤250-line body cap applied to a 12–17-capability pack, once every `anti_patterns`/`quality_criteria` cluster MUST stay body-reachable, is genuinely tight — AC5's cap could pressure Blake to drop constraints to fit, causing the exact loss being guarded against.
**Fix:** flag the 12–17-capability packs as higher-risk; allow body overage when the overage is constraint content (constraints win over the cap), or compress via a tabular MUST-list. Make the NFR1-vs-lesson-2 precedence explicit.

### P2-4: No co-load INTERFACE/precedence for the sibling pack families; §4.3 schema omits it though the precedent carries one
4 mobile packs and 4 hw packs are highly likely to co-load on one task. The precedent the handoff grounds on (ai-voice-production) carries an explicit `> INTERFACE:` block declaring precedence vs sibling packs — but §4.3's frontmatter schema and §4.1's body template require none, despite principles.md 2026-05-15 "Zero Collision Detection." This also softens the §6.1 "packs are independent → parallelize" premise for the sibling families.
**Fix:** require a `> INTERFACE:` line in each pack with ≥1 sibling in this batch; add a brief serial cross-reference pass after parallel drafting. (Minor: FR2's "matching existing pack convention" is imprecise — `web-backend` has no `version:` key while ai-voice-production does; pin the schema to the ai-voice-production shape explicitly.)

---

## Solid (no action)
- Mirror via `diff -rq` per pack (AC4) — correct omission catcher, not presence-only (principles.md 2026-06-01).
- Archive-immutability guard (AC6, pre-impl baseline `0`) and scope-containment fences (AC11/AC12) correctly bound blast radius against the existing packs/hooks.
- Grounding honesty: the missing `phase1-grounding.md` is disclosed and re-derived live.
- Separating format migration from content-quality/research (Intent §1.3) is the right call — prevents the two acceptance standards from cross-contaminating.
