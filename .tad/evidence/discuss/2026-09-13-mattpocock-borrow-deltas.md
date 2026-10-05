# Discuss: thin deltas from mattpocock/skills into upstream TAD

**Date:** 2026-09-13  
**Mode:** Alex `*discuss` (Cursor / cursor-grok-4.6-medium)  
**Status:** discuss record only — **not** a handoff, **not** READY_FOR_BLAKE  
**Channel locks (this session):** NO Gemini · NO Blake · NO implement · NO push/tag/release · **NO wholesale import** of `mattpocock/skills`

**Human goal:** Decide which **thin authoring habits** (if any) to borrow. Human already heard PM lean: **only authoring habits**; top four candidates named below. **Do not cut Gate 2 dual review or Alex ≠ Blake.**

**Primary source:** `.tad/evidence/research/2026-09-13-mattpocock-skills-deep.md` (§8 thin deltas, §8.1 do-not-import, discuss verdict). Repo pin in that note: `mattpocock/skills` @ `3cca18b`.

**Pack pointers (not loaded):**  
- `ai-agent-architecture` — agent/skill load and invocation design. Path: `.claude/skills/ai-agent-architecture/SKILL.md`. Do not load unless escalated.  
- `ai-prompt-engineering` — skill/prompt authoring mechanics. Path: `.claude/skills/ai-prompt-engineering/SKILL.md`. Do not load unless escalated.

**Local Wiki:** no prior canon on this topic (research note). NotebookLM unavailable. This discuss does **not** open a new notebook.

---

## Verdict (Alex, for human lock)

mattpocock/skills is a **skill catalog + interview primitive**, not a two-agent gate OS. TAD should **not** adopt the catalog, `/implement`, tracker SSOT, or unbounded grilling. The honest leftover is **naming habits we mostly already practice**, so a future pack/skill author does not cargo-cult Matt’s main flow.

On disk today:

| Surface | Already have | Gap |
|---------|--------------|-----|
| Pack loader (`pack-build-rules.md` ### Pack Loader Thin On-Demand, 2026-09-10) | Pointer max-2, freeze skip, human-named / failure-retry escalate | Load **budget**, not Matt’s user-invoked vs model-invoked **skill class** |
| `DR-20260712` 裁决 4 | Adopted `disable-model-invocation: true` for low-frequency packs as **常规维护** | **Not applied:** no `disable-model-invocation` in `capability-packs/**/CAPABILITY.md` (grep 0) |
| Process tax-cut (`docs/process-tax-cut.md` + `patterns/process-tax-cut.md`) | Gate 2 = dual **disk** reviews; Alex ≠ Blake **teeth** | Unrelated to Matt; **must not** be relaxed to “soft setup” |
| Capability-builder create | Minimal tree, progressive `references/`, Alex never authors downstream Skill while active | No invocation-class field; no hard/soft setup pointer rule |
| Skillify template | When / Steps / Anti-patterns / description | No user- vs model-invoked; no “don’t restate `--help`” |
| L1 principles | Never Hand-Write What an Existing Tool Already Does; AI/Human Judgment Domain; Two-Agent + Four-Gate | Authoring checklists do not **cite** these when writing SKILL.md |
| Alex SKILL | Human decides tech; Socratic; `plain_language_rules`; friction = never skip | No named “facts vs decisions wait-gate”; listener re-pitch is already plain-language, not a skill |

**Recommended if human says go:** one **docs-only** knife — a short L2 entry on `pack-build-rules.md` (plus `_index.md` hook words). Optionally 4 bullets on the skillify template. **Do not** touch role SKILL bodies, gates, process-tax-cut teeth, or KEEP packs.

---

## KEEP / DEFER / REJECT

Legend: **KEEP** = worth writing as TAD-native prose if human locks a knife. **DEFER** = true idea, wrong now (or already owned elsewhere). **REJECT** = conflicts with TAD product or §8.1.

| ID | Candidate | Verdict | Why | If kept, land (doc path only) | Gate / role conflict |
|----|-----------|---------|-----|-------------------------------|----------------------|
| D1 | **User-invoked vs model-invoked split** (human #1) | **KEEP** (name + cite; do not rewrite loaders) | TAD already splits **human command** (`/alex`, `/blake`, `$capability-builder`) vs **model-recruited packs** (keyword → pointer → escalate). Matt’s extra precision: orchestrators stay human-fired; discipline skills stay Skill-tool-called; **never** user-invoked → user-invoked. DR-20260712 already said use `disable-model-invocation` for infrequent packs — **habit unpublished in L2**. | `.tad/project-knowledge/patterns/pack-build-rules.md` (new ###); optional one line `.tad/templates/skillify-candidate-template.md`; **not** `alex/SKILL.md` / `blake/SKILL.md` bodies | Must **not** recast Alex↔Blake as composable slash-skills. Must **not** let a pack “Call Skill blake”. Gate 2 dual reviewers stay **roles**, not model-invoked sub-skills inside `/implement`. |
| D2 | **Hard vs soft setup pointers** (human #2; ADR 0001 analogue) | **KEEP** (one paragraph, anti-cargo-cult) | TAD **already** has the opposite failure: friction protocol + handoff §8.4 — missing tools are **never a skip**. Gap is the other pole: **soft** skills (`*discuss`, tax-cut paste, pack pointer) should **not** each say “run setup X if missing.” Only load-bearing setup (e.g. `tad.sh` install, research CLI when `*research` is the task) earns a “run X if missing” line. | Same L2 entry in `pack-build-rules.md`; optional cross-link `docs/process-tax-cut.md` **pointer only** (“this guide is copy, not a setup gate”) | **Forbidden:** labeling Gate 2 dual review or Alex≠Blake as “soft.” Those are **teeth**, not setup nags. Friction protocol stays: hard deps still BLOCK, not “token-light skip.” |
| D3 | **Facts vs decisions** (human #3) | **DEFER** as new text; **KEEP** only as a **one-sentence cite** if bundled | Already L1: AI/Human Judgment Domain (choices not rubber-stamp); Alex “重要技术决策必须由人拍板”; Adaptive Complexity = human depth. Matt’s grilling wait-gate is the **same job** as Socratic + Gate 1. A second interview OS would compete. | If bundled: one sentence in the L2 entry citing `principles.md` ### AI/Human Judgment Domain. **Do not** amend L1 (Epic). **Do not** add a `grilling` skill. | Unbounded grilling (#44-class) vs 3–5 Socratic + Gate 1. Agent answering its own Gate-1/L3 decisions = existing anti-pattern (`不得自选`). |
| D4 | **Docs-as-environment-cache** (human #4) | **KEEP** (cite, don’t import 11 KB) | Byte-identical spirit of L1 **Never Hand-Write What an Existing Tool Already Does**. Gap: skillify / pack-build / capability-builder do not tell authors “SKILL.md is a **cache** of `package.json` / `--help` / live CLI, not a second SSOT.” v2.7 lesson still applies: **constraint rules are not restatable junk.** | `pack-build-rules.md` ### (same knife); optional skillify Anti-Patterns bullet | Must **not** slim MUST/MANDATORY out of SKILL bodies (Judgment-Only Skill Files). Must **not** delete Gate checklists because “the script already knows.” |
| D5 | wait-what / listener re-pitch (research §8 rank 3) | **REJECT** as a TAD skill; **DEFER** as teaching | Maps to existing `plain_language_rules` in alex SKILL. A global always-on skill is context tax. | None now. If ever: a sentence in `*discuss` protocol — **later ticket**, not this knife | New user-invoked skill ≠ process tax-cut. |
| D6 | Phase-boundary menu (continue / clear / temp-dir handoff / compact) (research §8 rank 6) | **REJECT** as product; **DEFER** as *learn* hygiene | TAD already has compact recovery §4.5 + terminal isolation. Matt’s OS-temp **handoff** is **not** Gate-2 HANDOFF. Teaching the menu is fine; shipping it as TAD handoff is not. | None | Temp-dir compact ≠ Blake’s only info. |
| D7 | Apply `disable-model-invocation` across KEEP packs (DR-20260712 leftover) | **DEFER** | Real maintenance, **not** a borrow-from-Matt knife. Needs per-pack triage (which 11 are user-invoked vs keyword-recruited). Loader already pointer-default; frontmatter change is a **different pathspec** and KEEP11-adjacent risk. | Later: pack CAPABILITY.md frontmatter + registry note — **not** this discuss’s knife | Must not freeze/unfreeze; must not absorb into v2.44.5 publish. |
| D8 | `/ask-matt` router analogue for TAD commands | **REJECT** | TAD already has `*help` + intent router + human as bridge. A second index skill would lie when commands drift (Matt’s own ask-matt re-sync warning). | — | Two-agent routing is human-triggered (`当 Alex` / `当 Blake`), not a skill-tool graph. |
| D9 | Thin orchestrator wrappers (`grill-me` = one Skill-tool call) | **REJECT** | Cute for a catalog. TAD role SKILLs **must** keep circular-trigger body (Execution Discipline Content Must Stay in SKILL Body). Wrapping `/alex` into 157 bytes would recreate v2.7. | — | — |
| D10 | Tracker / wayfinder / triage / to-tickets as TAD SSOT | **REJECT** | `.tad/` files are SSOT. Epic = one Active phase. | — | Conflicts with handoff contract + Epic. |
| D11 | `/implement` + auto-commit + self code-review | **REJECT** | Designer-implements-accepts is the Two-Agent **failure_mode**. | — | Alex ≠ Blake; Gate 3 Layer 2 independent. |
| D12 | Import writing-for-agents SKILL / plugin / skills.sh | **REJECT** | §8.1. Attribution of **ideas** in L2 is enough. | — | Distribution is `tad.sh`, not subscribe-to-Matt. |

---

## Recommended “one knife” (if human says go)

**Name:** `TASK-…-skill-authoring-habits` (docs-only)  
**Shape:** pathspec-sized; **docs-only preferred**; no role SKILL rewrite; no gate rewrite; no pack freeze roster; no publish.

**In:**

1. `.tad/project-knowledge/patterns/pack-build-rules.md` — one new `###` (≤ ~40 lines) covering **D1 + D2 + D4**:
   - Name **user-invoked orchestrator** vs **model-invoked / keyword-recruited discipline**.
   - Point at existing loader: pointer ≠ load; escalate gates unchanged.
   - Point at DR-20260712 裁决 4 as **still-open maintenance**, not as work in this knife.
   - Hard pointer = only if the skill **cannot function** without that setup; soft = omit nag.
   - Docs cache the environment; constraints stay in SKILL body.
   - `failure_mode`: cargo-cult Matt’s grill→spec→implement as TAD; treat Gate 2 as skippable setup.
2. `.tad/project-knowledge/patterns/_index.md` — extend the Pack Build Rules hook (stay ≤120 chars) with e.g. `invocation-split, hard-vs-soft setup, docs-cache-env`.

**Optional same knife (still docs):** `.tad/templates/skillify-candidate-template.md` — four bullets under Proposed Skill Outline: invocation class; hard vs soft setup; don’t restate CLI SSOT; decisions vs facts (cite L1, don’t copy grilling).

**Out of this knife:** dual-platform alex/blake SKILL, `docs/process-tax-cut.md` body, capability-builder protocols, KEEP pack bodies, `disable-model-invocation` apply, L1 `principles.md`.

**AC sketch (for a later `*analyze`, not now):** grep new heading exists; `_index.md` hook ≤120 and contains the new tokens; `git diff --stat` only the pathspec; **zero** hits changing Gate 2 dual / Alex≠Blake sentences in process-tax-cut files.

---

## Explicit non-goals

- Wholesale copy of `mattpocock/skills`, plugin, marketplace pin, or `npx skills add`.
- Replacing TAD default path (`/alex` `/blake` `/gate`) with `/ask-matt` / grill → `/implement`.
- Cutting or “softening” **Gate 2 dual independent disk reviews** or **Alex ≠ Blake**.
- Unbounded grilling instead of Socratic 3–5 + Gate 1.
- Issue-tracker / Linear / wayfinder as TAD state.
- Auto-commit implement path; concurrent `implement-spec` swarm.
- Importing `CONTEXT.md` over `.tad/project-knowledge/`.
- Research-without-Iron-Rule; Gemini; Blake; push/tag/release; KEEP11 knives; v2.44.5 absorb.
- Registering hooks / git-guardrails (Alex must not write hooks; Mechanical Enforcement Rejected).
- House style (no em-dashes), newsletter, teach/wizard/writing-beats.
- Amending L1 principles in this knife (Epic if ever).
- Starting a handoff from this file without human lock + `*analyze`.

---

## READY_FOR_HUMAN_LOCK (max 3)

Plain language — **you** pick; Alex will not start a handoff or Blake from this discuss.

**Q1. One knife scope?**  
1. **Docs-only L2** — `pack-build-rules.md` + `_index.md` hook only (D1+D2+D4).  
2. **Same + skillify template** four bullets.  
3. **None** — record the verdict, no knife (research + this file are enough).

**Q2. Facts vs decisions (D3)?**  
1. **Leave it** — L1 + Socratic already own it; do not mention in the knife.  
2. **One citing sentence** in the L2 entry (no new interview protocol).

**Q3. The old DR-20260712 pack frontmatter work (`disable-model-invocation` triage)?**  
1. **Stay deferred** — separate maintenance, not this knife.  
2. **Mention as a follow-up sentence** in the L2 entry only (still no pack file edits).  
3. **Promote to its own later ticket** (still not this knife; still not v2.44.5).

---

## Health (this activation; not the delta)

- **Mode:** Alex `*discuss`. Prior `session-state.md` is COMPLETE (P2 SC4 Gate 4); not a resume of that task.
- **Pending `HANDOFF-*` filenames (unread):** `HANDOFF-20260911-release-v2445.md`, `HANDOFF-20260909-release-v2444.md`, `HANDOFF-20260908-knowledge-seam-isolation.md`, `HANDOFF-20260908-release-v2443.md`. Ages from filenames <14d — no zombie prompt. v2.44.5 publish is a **separate** in-flight handoff; **do not absorb**.
- **Knowledge:** layered `patterns/` present. This discuss does not distill a new L1.
- **Do not** update NEXT.md until you pick Q1 (discuss exit capture is optional).
