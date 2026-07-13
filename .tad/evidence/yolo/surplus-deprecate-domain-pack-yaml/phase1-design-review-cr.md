# Phase 1 Design Review — code-reviewer lens

**Handoff:** `.tad/active/handoffs/HANDOFF-surplus-deprecate-domain-pack-yaml.md`
**Reviewer:** code-reviewer (YOLO Epic Phase 1 design review)
**Date:** 2026-07-05
**Verdict:** CONDITIONAL — 1 P0 must be fixed before implementation.

---

## Scope of review

Focus areas: file-list completeness, AC verifiability, frontmatter correctness,
design coherence. All ground-truth claims in the handoff were re-verified live on
disk (results below). The handoff is unusually well-grounded: every numeric baseline
it asserts (9 YAMLs / 7,132 lines, `.tad/domains/` = README-only, domain-router hook
absent, CHANGELOG `domain-router`=3, README anchors=0, anti_patterns blocks 8×7 +
supply-chain×5, ai-voice-production precedent 125-line SKILL + 7 references) matches
reality. Frontmatter (`task_type: mixed`, `e2e_required: no`, `research_required: no`,
`git_tracked_dirs`, `skip_knowledge_assessment: no`) is filled and appropriate for a
content-migration task. File list (§7) is complete for the deliverables.

The problem is concentrated in **verification quality of the SAFETY-critical ACs**, not
in the design direction, which is sound.

---

## P0 — Blocking

### P0-1: AC13 (anti-pattern preservation) is non-discriminative — compares block-count to item-count

AC13 is explicitly presented as the resolved fix for a prior design-review P0
("anti_patterns 约束存活 … design-review P0 修复 … per principles.md 2026-06-01"), and
it is the load-bearing mechanical guard for the SAFETY principle that constraint rules
(MUST/never/anti-patterns) must survive distillation (principles.md 2026-04-04 SAFETY).
As written it does not work.

The command sets the required floor from:
```
src=$(grep -c 'anti_patterns:' "$y")      # counts anti_patterns BLOCKS (one per capability)
```
and compares it to `got` = count of markdown list rows in the SKILL.md `## Anti-Patterns`
section. The two sides count different populations. Measured on disk:

| pack | AC13 `src` (blocks) | actual anti-pattern ITEMS in YAML |
|------|--------------------|-----------------------------------|
| hw-circuit-design | 7 | 45 |
| hw-enclosure | 7 | 39 |
| hw-firmware | 7 | 49 |
| hw-testing | 7 | 41 |
| mobile-development | 7 | 31 |
| mobile-release | 7 | 25 |
| mobile-testing | 7 | 28 |
| mobile-ui-design | 7 | 33 |
| supply-chain-security | 5 | 15 |

Consequence: Blake can migrate **7 of ~45** anti-patterns per pack and AC13 still reads
PASS (7 ≥ 7). The floor only catches near-total omission (<7 rows); it cannot distinguish
faithful migration from ~85% loss. This is exactly the count-floor / validation-theater
failure the project's own knowledge base flags as P0-class ("A coverage gate's global-count
floor cannot detect must-cover SAFETY loss when legit stripping also lowers the count",
principles.md 2026-06-01; YOLO audit "Validation Theater"). Worse, it is presented as a
*resolved* P0, so in YOLO mode it manufactures false confidence at the Conductor gate.

**Fix:** derive `src` from the true per-pack item count, not the block count, e.g.
```
src=$(awk '/anti_patterns:/{f=1;next} f&&/^[[:space:]]*-/{c++;next} f&&/^[[:space:]]*[a-zA-Z_]+:/{f=0} END{print c+0}' "$y")
```
(expected 45/39/49/41/31/25/28/33/15). Ideally scope per-capability rather than a single
per-pack total (principles.md: verify presence per-category within the must-cover scope,
never a single global tally). Note this fix interacts with NFR1 — see P1-2.

---

## P1 — Should fix

### P1-1: No AC verifies the non-circular reference-reachability requirement

FR3 and §4.1 require every `references/*.md` file to be reachable from a non-circular
pointer in the SKILL.md body, and the handoff cites this as load-bearing (Project-Knowledge
教训 3 → principles.md 2026-06-09 SAFETY, "Execution Discipline Content Must Stay in SKILL
Body — Circular Trigger Test"). But §9.1 has **no AC** for it: AC2 only checks
`references/ ≥1 file exists`; nothing checks that each reference is pointed to from the body.
A pack with orphan reference files (content that never loads) passes every current AC.

**Fix:** add a per-reference pointer-presence AC, e.g. for each `references/X.md` assert the
body mentions it:
```
for p in $PACKS; do for r in .claude/skills/$p/references/*.md; do b=$(basename "$r");
  grep -q "$b" ".claude/skills/$p/SKILL.md" || echo "ORPHAN $p/$b"; done; done
```

### P1-2: Latent FR3 ↔ NFR1 conflict, masked by the broken AC13

FR3 mandates "constraint rules → SKILL.md body, never reference-only"; combined with the
corrected AC13 (P0-1), hw-firmware would need ~49 anti-pattern rows in the body, plus
judgment rules + frontmatter + reference pointers, against NFR1's ≤250-line cap. Today the
tension is hidden because AC13 only demands 7 rows. Once AC13 is fixed the two requirements
can collide for the large hw packs. The design needs an explicit resolution rule — e.g.
allow anti-patterns as a compact one-line-per-item body table and state that the 250-line
cap counts prose only, or relax the cap for packs whose source exceeds a threshold. Decide
this now so Blake isn't forced to choose between two "MUST"s mid-implementation.

### P1-3: Distill-vs-dump / hollow-SKILL.md has no mechanical floor

The friction preflight itself names the risk "漏读源内容 → SKILL.md 空洞 → Gate 3 FAIL",
but no AC catches a hollow stub: AC1 is `test -s` (any non-empty file passes, incl. a
5-line stub) and AC5 only checks the *upper* bound (≤250 lines) + absence of mechanism keys.
There is no lower bound and no "each capability represented" check, so genuine distillation
quality rests entirely on Conductor content review with zero mechanical backstop.

**Fix:** add a cheap floor — per pack assert SKILL.md body ≥ N lines (precedent packs run
~125) AND that each source `capabilities.*` name (or its distilled heading) appears in
SKILL.md + references, so every capability is provably represented.

---

## P2 — Nice to have

- **P2-1 (portability):** AC13 uses `\s` (`^\s*[-\|]`). NFR3 mandates BSD-portable, no
  GNU-only flags. It works here only because this box runs `ugrep 7.5.0`, not BSD grep; on
  stock macOS `/usr/bin/grep` (BSD) `\s` is not guaranteed. Use `[[:space:]]` per the
  shell-portability pattern the handoff already cites.
- **P2-2:** AC5's mechanism-key scan (`tool_ref:`/`output_file:`/`requires_registry:`) only
  inspects SKILL.md. MQ3 says these keys are dropped entirely (not migrated anywhere); a
  `references/*.md` file could still carry a raw `tool_ref:` from a step-detail dump and no
  AC would catch it. Extend the scan to `references/` if "drop everywhere" is the intent.
- **P2-3:** FR6 asks for "a new version heading (Keep a Changelog style)" but 10.2 puts the
  framework `version.txt` bump out of scope. A real `## [x.y.z]` heading without a matching
  version.txt bump creates heading/version drift, and AC7's `awk n==1` assumes the first
  `## ` block is this entry. Clarify whether the entry belongs under `## [Unreleased]` or a
  concrete version.
- **P2-4:** The `git_tracked_dirs: [".claude/skills", ".agents/skills"]` Gate-3 guard is a
  no-op for this task — the existing 24 packs already satisfy "≥1 git-tracked file", so it
  passes even if the 9 new packs are never `git add`ed. Not a bug, but adds no protection
  here; AC1–AC4 check filesystem presence, not tracking.

---

## What is solid (no action needed)

- Every ground-truth claim verified true on disk (source count/lines, dead domains dir,
  absent hook, precedent format, all baselines for AC6/7/8/9/10/13).
- File-to-create / file-to-modify lists are complete for the stated deliverables; evidence
  and COMPLETION paths are correctly exempted in AC12.
- Frontmatter fields all present and correct for a content-migration task
  (`e2e_required: no`, `research_required: no`, `task_type: mixed` all justified).
- AC4 uses `diff -rq` (not presence-only) for the mirror — correctly applies the
  "diff -r is the universal omission catcher" lesson (principles.md 2026-06-01).
- AC7/AC8 are genuinely discriminative (anchored to measured baselines + latest-version
  section), a real improvement over global greps.
- Design direction (distill judgment → body, step detail → references, mirror last, archive
  untouched) is coherent and matches cited precedent and principles.

---

## Verification evidence (run 2026-07-05, repo root)

```
source YAMLs: 9 ; wc -l total: 7132
.tad/domains/: README-retired.md only
hooks domain-router: 0 (grep exit 1)
CHANGELOG domain-router baseline: 3 ; latest-section 'retir': 0
README-retired mobile-development anchor: 0 ; migration-complete anchor: 0
ai-voice-production SKILL.md: 125 lines ; references/: 7 files
anti_patterns blocks: hw-* =7 each, mobile-* =7 each, supply-chain-security =5
anti_patterns ITEMS: 45/39/49/41 (hw) 31/25/28/33 (mobile) 15 (supply-chain)
grep flavor on this box: ugrep 7.5.0 (NOT BSD grep — masks the \s portability issue)
```
