# Research + *discuss: thin user stories vs AC / Gate 3–4

**Date**: 2026-09-14 (session clock 2026-09-13 evening UTC)  
**Channel**: Cursor · model=cursor-grok-4.6-medium  
**Mode**: Alex `*research` (Standard, Local Wiki miss → WebSearch; **no Gemini**, no NotebookLM) + `*discuss`  
**Non-goals (this session)**: no Blake, no handoff, no push/tag/release, no charter/gate rewrite as **locked policy**, do **not** cut Gate 2 dual review or Alex≠Blake.

**Decision question (human via GM → TAD PM)**: Should TAD adjust intake toward thin user stories for early intent alignment, while keeping strict ACs and a Gate3=contract / Gate4=intent-lens split, without fighting TAD or adding ceremony?

**Status**: findings + KEEP/DEFER/REJECT + optional minimal-change **proposal**. **Wait human lock** before any HANDOFF / Blake.

---

## 0. Method

- TAD SSOT read: `.tad/gates/gate-canonical-checklist.md`, `gate-execution-guide.md`, superseded `quality-gate-checklist.md`; `patterns/ac-verification.md`, `patterns/process-tax-cut.md`, `docs/process-tax-cut.md`; `templates/handoff-a-to-b.md` §1.2–1.3 + §9; Alex `my_gates` + `acceptance-protocol.md` step4; Blake Gate 3 / spec-compliance; Socratic Q1–Q5; `docs/pm/intent.md`.
- Local Wiki: `research/canon/_index.md` has **no** story/AC/agile topic (only guardrails/MCP). No new wiki canon ingested (would be extra tax vs requested evidence file).
- External: WebSearch only. **Meathill / nurijanian: skim if findable; unmarked claims = unverified.**
- Pack: `product-thinking` is **frozen** → no auto-load (registry skip).

---

## 1. Current TAD (what already exists)

### 1.1 Intake already has the thin-slice dimensions

Gate 1 (canonical SSOT) is already four independent axes: **Problem / User / Scope+non-goals / AC verifiable**. Socratic Q1 ICP is `[角色]在[场景]中需要[能力]`；Q2 scene+obstacle；Q3b exclusions；Q5 = Alex **drafts ACs**, human confirms. That is the human hypothesis’s upstream “who / situation / desired outcome / non-goals” **without** calling it a user-story wall.

Handoff template already carries:

- §1.2 Why + “成功的样子”
- §1.3 **Intent Statement**: 真正要解决的问题 + **不是要做的** + Blake restates problem / usage / success (human confirms **before** implement)

So a new mandatory “user story file” would **duplicate** Gate 1 + §1.3 (dual SSOT risk).

### 1.2 ACs are already the operational contract

`patterns/ac-verification.md` + process-tax-cut §1 + verify-delta (2026-09-10): landing ACs need a **legal Verification Method** (command | path-check | fixture | rubric-spawn | light-tier N/A). Prose-only Method = Gate 3 row FAIL. Anything not in ACs is effectively optional. G/W/T is **one optional shape** for behavioral rows, not required syntax.

### 1.3 Gate 3 vs Gate 4 today

| Gate | Owner | Canonical job | Hypothesis check |
|------|--------|----------------|------------------|
| 3 | Blake + independent experts | Deliverable complete + **§9.1 every row** + evidence exist/replay + git + KA + provenance | **Mostly consistent** with “verify AC / spec / evidence”. Not “AC-only”: KA/git/provenance stay. **Not** an intent/story checklist. |
| 4 | Alex (+ human) | **Business acceptance**: (1) **recompute landing Methods from disk** (Blake summary ≠ evidence); (2) quality evidence presence; (3) P0/P1 closed; (4) KA | **Not** “intent-only”. Gate 4 **already re-runs ACs**. Adding a **short intent lens** is additive. **Replacing** AC recompute with stories would **fight** verify-delta + `gate4_delta` integrity. |

Alex SKILL `mandatory_review`: Gate 4 v2 = 业务验收; technical review lives in Gate 3. `patterns/gate-design.md` “Gate Responsibility Matrix”: technical experts → G3; business judgment → G4.

### 1.4 Stale wording (do not treat as SSOT)

- `quality-gate-checklist.md`: banner **SUPERSEDED**. Still lists “User Story Complete: As [who] I want [what] so that [why]”. **Do not revive** this as new policy (would bake agile story format + dual Gate 1).
- `gate-execution-guide.md`: still describes Gate 4 as **both agents**, **must call** security/perf/code/ux subagents. That is **v1.x**. Canonical + `acceptance_protocol` already moved technical calls to Gate 3. Any future wording change should **not** copy this guide.

### 1.5 Legacy / archived agile ceremony

`docs/legacy/WORKFLOW_PLAYBOOK.md` and archived `product-management` skills still say PRD + 用户故事 + 验收三件套. That is **not** live full-channel SSOT. Reintroducing it would fight process-tax-cut (“no fourth skip-review checklist”, no heavy ceremony).

---

## 2. Human working hypothesis — verify / refute

1. **Upstream thin slices (WHAT not HOW)** — **KEEP as practice**, already mapped to Gate 1 + Socratic + §1.3. **REJECT as a new mandatory TAD artifact type.**
2. **Alex writes testable ACs; stories are input not AC substitutes** — **KEEP.** Matches Q5 + §9 + tax-cut.
3. **Gate 3 = AC/spec/evidence only** — **KEEP with a wording refinement**: “contract verification”, not “AC rows only” (evidence/git/KA remain). Ban story-as-Gate3-checklist.
4. **Gate 4 = ACs closed + short intent lens; stories not a second long checklist** — **KEEP if** “ACs closed” = **independent recompute** (already). Intent lens = 3–5 sentences vs §1.3 / Gate 1 (right slice? design drift?). **REJECT** if Gate 4 drops AC recompute.
5. **Room for AI: stories = goals/bounds; ACs = verifiable outcomes, not impl fill-in** — **KEEP.** Aligns with tax-cut ban on theater ACs and with nurijanian README’s **implementation-independent** requirement characteristic (**snippet-level only**, see §3).

---

## 3. External skim (unverified unless noted)

### Meathill (Meathill Zhai)

- **Found**: GitHub `meathill`; blog/SF. SegmentFault 远程办公文 (search snippet): 明确需求、**明确验收标准**、测试+CI、交叉 Review. **Not** a “thin user story as intake” doctrine.
- **Not found** (this session): a Meathill essay that TAD should copy as story-format SSOT.
- **Verdict**: **unverified** as a source for TAD format. Compatible at slogan level (需求清晰 ≠ 故事墙).

### nurijanian (George Nurijanian / `gnurio`)

- **Found**: `gnurio/nurijanian-skills` README (WebSearch snippet, **not** fetched body — WebFetch blocked): “Make Requirements Great” 18 characteristics including **testable**, **implementation-independent**, plus PRD/spec/**user stories**/AC as **carriers** of requirements, not one mandated template.
- **Verdict**: **partially verified** (README listing via search). Supports “must have testable, HOW-free requirements”; **does not** require TAD to prescribe story vs PRD vs intent card.

### Generic agile (not TAD-authoritative)

Common split: story = intent/value; AC = pass/fail conditions; GWT optional for behavior; rule-lists for constraints; DoD ≠ per-story AC. Thin vertical slices ≠ sprint ceremony. **Do not** import Gherkin walls or story-point boards.

---

## 4. Answers for PM → GM / human

### Q1 — Thin user stories into TAD as intake, or recommend-practice only?

**Recommend-practice only (KEEP practice / REJECT mandate).**

Worth writing **four fields** into PM/Alex intake habit: who, situation, desired outcome, explicit non-goals. **Not** worth a new `USER-STORY-*.md` type, INVEST boards, or Gate 1 “User Story Complete” revival. Live TAD already has those fields. Mandate would add process tax and a second SSOT next to Gate 1 / §1.3.

### Q2 — Gate3=AC / Gate4=intent-lens vs current semantics? Where wording must change?

**Directionally consistent; wording must not invert verify-delta.**

- Gate 3 today **is** the AC/spec/evidence gate (plus KA/git). Hypothesis is consistent if we **forbid** stories as Gate 3 rows.
- Gate 4 today **is already** “business” **and** **AC recompute**. Hypothesis is consistent as **AC closed (recompute) + short intent lens**. It is **inconsistent** with current SSOT if Gate 4 becomes “intent only.”
- **Must not change (teeth)**: Gate 2 min-2 independent reviews; Alex ≠ Blake; Gate 4 disk recompute of landing Methods.
- **Optional later wording (DEFER, after lock)**: one advisory Gate 4 bullet in **canonical** checklist only — not in superseded files. `gate-execution-guide.md` Gate 4 block is already stale; repair is **hygiene DEFER**, not this knife’s policy.

### Q3 — Prescribe carrier format?

**No.** Prescribe **properties**: testable ACs (legal Method) + **traceable** upstream intent (Gate 1 / §1.3 / PM intent card / thin story — any one). Ban dual SSOT: **§9.1 is the only Gate 3/4 pass/fail table.**

### Q4 — Minimal change proposal (one line each); non-goals

See §6. Non-goals: no full agile ceremony, no dual acceptance checklists, no Gate 2 dual cut, no Alex=Blake.

---

## 5. KEEP / DEFER / REJECT

| ID | Item | Call |
|----|------|------|
| K1 | Stories/slices = **input** to Alex; **§9.1 ACs** = only operational acceptance table | KEEP |
| K2 | Gate 3 verifies AC/spec/evidence (not intent essays) | KEEP |
| K3 | Gate 4 independent AC **recompute** (verify-delta) | KEEP |
| K4 | Gate 2 dual independent reviews + Alex≠Blake | KEEP (untouched) |
| K5 | G/W/T optional for behavioral ACs | KEEP as optional |
| R1 | Mandatory user-story template / story file type in full-channel TAD | REJECT |
| R2 | Stories as second Gate 3 or Gate 4 checklist | REJECT (dual SSOT) |
| R3 | Gate 4 drops AC recompute in favor of “intent-lens only” | REJECT |
| R4 | GWT / INVEST / sprint ceremony as TAD protocol | REJECT |
| R5 | Using superseded `quality-gate-checklist.md` “User Story Complete” as live Gate 1 | REJECT |
| D1 | After human lock: **advisory** Gate 4 “intent lens” one-liner in **canonical** checklist + `acceptance-protocol` step4 after AC table (3 questions: right slice? §1.3 still true? design drift vs non-goals?) — **not** a scored table | DEFER |
| D2 | `docs/pm/intent.md` or `docs/process-tax-cut.md` one paragraph: intake fields + “stories ≠ AC” | DEFER (smallest if lock=recommend-practice) |
| D3 | `handoff-a-to-b.md` §1.3: optional “upstream slice pointer” (path or 4-field paste), still not AC | DEFER |
| D4 | Stale `gate-execution-guide.md` Gate 4 vs canonical — separate hygiene | DEFER |
| D5 | Local Wiki canon on stories vs AC | DEFER (no topic today; not needed to lock) |

---

## 6. Minimal-change proposal (optional; **not** locked)

If human locks **recommend-practice + optional intent lens**, touch **at most**:

1. `docs/pm/intent.md` — one “上游薄切片” bullet: who / situation / outcome / non-goals; clarify WHAT; pointer that Alex still writes §9 ACs.
2. `docs/process-tax-cut.md` — one sentence under AC realism: **intake story ≠ Verification Method**; do not paste stories into §9.1.
3. `.tad/gates/gate-canonical-checklist.md` Gate 4 — **advisory** sub-bullet under Functional acceptance: short intent lens vs §1.3 (not a second table). **Do not** edit superseded checklist as SSOT.
4. `.claude/skills/alex/references/acceptance-protocol.md` step4 — after AC 对照表, 3 intent questions; fail-close still Methods-from-disk.
5. `.tad/templates/handoff-a-to-b.md` §1.3 — optional “upstream intent carrier” (story/PRD/intent card/chat) one pointer field.
6. Mirror the same three lines in `.agents/skills/alex/...` if those files stay in parity (only if a later Blake knife exists).

**Do not** in that knife: `principles.md` Epic, Gate 1 rewrite, Blake Gate 3 protocol expansion, charter, Lite unfreeze.

---

## 7. Claim check (WebSearch / disk)

| Claim | Check | Result |
|-------|--------|--------|
| Canonical Gate 4 requires AC Method recompute | disk `gate-canonical-checklist.md` L56–59 | ✅ |
| Gate 1 already has User/Problem/Scope/AC | same file L7–17 | ✅ |
| Handoff §1.3 Intent + non-goals exists | `handoff-a-to-b.md` L92–108 | ✅ |
| `quality-gate-checklist.md` superseded | file L3–5 | ✅ |
| Meathill authored a thin-story TAD pattern | WebSearch | ⚠️ 未找到可引用正文 |
| nurijanian 18-char includes implementation-independent | GitHub README snippet | ⚠️ 未整页核验 |
| product-thinking frozen | pack-registry.yaml | ✅ |

---

## 8. Stop condition

**Wait human lock** (PM → GM → human). Options to lock (not Alex-chosen):

1. No TAD text change — practice only (use Gate 1 + §1.3 as-is).
2. Recommend-practice paragraph(s) only (D2).
3. D2 + D1/D3 after a **later** docs-only handoff (still Gate 2 dual / Alex≠Blake).

No READY_FOR_BLAKE. No HANDOFF from this session.
