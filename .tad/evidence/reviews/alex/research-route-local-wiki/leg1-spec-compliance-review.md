# Gate 2 Leg-1 Spec-Compliance Review

**Design under review:** `.tad/active/handoffs/HANDOFF-20260908-research-route-local-wiki.md` (v1.0, Ready-for-Gate2, 431 lines, full read)
**Lens:** DESIGN COMPLETENESS + SPEC VERIFIABILITY (not code style, not implementation)
**Pattern skimmed:** `.tad/project-knowledge/patterns/gate-design.md` §"Claims Need Carriers" (lines 97–101): every completion/review claim needs an on-disk carrier + existence AC; smoke alarms must fail CLOSED on zero carriers. This review's carrier is its own verbatim persisted output (per task instruction).
**Independence statement:** No knowledge of any prior review; all evidence below was re-derived by running the commands myself on 2026-09-08.
**Harness:** OpenCode (charter §3.7 compliant — Gate 2 dual-review executed inside OpenCode, not Cursor).
**Provenance:** Independent subagent session `ses_f7d967a75ffecEeXhvbiib85Ar`, output persisted verbatim by Alex. Judge ≠ producer (reviewer did not author the handoff).

---

## Verdict

**CONDITIONAL — do NOT pass Gate 2 until P0-1 and P0-2 are fixed in the handoff text.**

- **P0 (blocks Gate 2): 2** — each is a design defect that causes a false gate (false-FAIL or false-PASS) or wrong implementation scope.
- **P1 (should fix before Blake): 5** — wrong file counts, missing mirror, untestable clauses, under-covering verification rows.
- **P2 (observation): 4** — triage items and brittleness notes, Blake-tolerable.

---

## Findings

### P0 — Gate-blocking

**P0-1 — ROW-06 already FAILS pre-implementation (false-FAIL gate).**
- ROW-06 as written (`Handoff §6:393`): `git status --porcelain docs/pm/ docs/pm-charter.md` expects empty output.
- Actual pre-impl output (ran myself):
  ```
  M docs/pm/intent.md
  M docs/pm/now.md
  ```
- Second defect in the same row: `docs/pm-charter.md` **does not exist in this repo** (`ls` → `No such file or directory`). `git status --porcelain` on a nonexistent path silently ignores it, so the "charter untouched" clause for that path is vacuously true and unverifiable by this command.
- **Consequence for Blake:** even with byte-perfect compliance (Blake touches nothing under `docs/pm/`), the gate still FAILs because of pre-existing dirty worktree state unrelated to this task. Blake cannot distinguish "my change broke the charter" from "the tree was already dirty." This is a textbook false-FAIL gate.
- **Exact fix required:** re-baseline ROW-06 before Blake starts. One of: (a) commit/stash the pre-existing `docs/pm/intent.md` + `docs/pm/now.md` modifications and record the clean HEAD hash in the handoff; or (b) rewrite ROW-06 as a diff-scoped check (e.g. `git diff --name-only <baseline-sha> -- docs/pm/` expects empty, or exclude the two known pre-dirty files by name); AND (c) drop the nonexistent `docs/pm-charter.md` path from the command or replace with `test ! -e docs/pm-charter.md` documentation of its absence. AC8 (`Handoff:378-380`) must be updated to match whichever formulation is chosen.

**P0-2 — §5 "Cat 5" mislabeled AND drops `learn-path-protocol.md` (false-PASS gap).**
- §5 lists (`Handoff:375`): `research-plan-protocol.md`, `handoff-creation-protocol.md`, `discuss-path-protocol.md`, `research-decision-protocol.md`, `research-review-protocol.md` — **5 files, labeled "Cat 5" instead of "AC 5"**.
- But §2 inventory (`Handoff:121`) and §4 (`Handoff:269-272`, File 15 & 16) both include a **6th protocol: `learn-path-protocol.md`** (Step 3_5 quiz/flashcards). It has a full implementation spec but **no acceptance criterion and no §6 verification row**.
- Consequence: Blake could skip `learn-path-protocol.md` entirely and every AC/ROW would still pass — a false-PASS by under-specification.
- **Exact fix required:** rename "Cat 5" → "AC 5" and append `learn-path-protocol.md` (Local Wiki quiz/flashcards generation, NotebookLM as backup) to the AC text, plus add a ROW (e.g. `grep -n "search.py\|Local Wiki" .../learn-path-protocol.md` on both mirrors) to §6.

### P1 — Should fix before Blake

**P1-1 — "26 files" claim vs 28 numbered file-instances (count mismatch).**
- Handoff claims "6 大类别、26 个核心文件" (`Handoff:115`), "26 个文件" (`Handoff:58`), "26 files" (`Handoff:416, 429`).
- §4 `^#### File` headers number **File 1 through File 28 = 28 file-instances** (`grep -c "^#### File"` = 16 headers, highest number 28). **Claimed 26, specified 28 — off by exactly 2.**
- **Fix:** change all "26" → "28" (or state the counting rule if two entries are intentionally informational-only — currently File 2 `research/CLAUDE.md` looks already-compliant, which may be the source of the 26-vs-28 confusion; either way the handoff must say so explicitly).

**P1-2 — File 27 & 28 omits the `.agents` mirror of `research-github` (parity-rule violation).**
- `Handoff:359-361` lists `.tad/capability-packs/academic-research/CAPABILITY.md` + `.claude/skills/research-github/SKILL.md` but no `.agents/skills/research-github/SKILL.md`.
- The mirror **exists** and is currently identical (`diff -q` exit 0). The handoff's own §1 knowledge rule (`Handoff:105-107`, Platform Parity: every `.claude/skills/` change must be 1:1 mirrored to `.agents/skills/`) therefore requires the mirror to be in scope. True path count is 29 if the mirror is added, which interacts with P1-1 — fix both together and state the final number.
- Related sub-gap: File 27&28 spec has **no line-anchored edits** for the still-stale frontmatter: `research-github/SKILL.md:3` (`description: …create deep-research notebooks…`) and `:11` (`then create deep-research NotebookLM notebooks`). These two lines will survive Blake's as-written spec. **Fix:** add explicit old→new replacements for lines 3/11 (description + usage pointer) in File 27&28, applied to both mirrors.

**P1-3 — ROW-05 under-covers AC7 (2 files diffed, 12 claimed).**
- AC7 (`Handoff:377`): "`.claude/skills/` 与 `.agents/skills/` 对应的 **12 个**核心技能与引用文件保持 100% 对齐."
- ROW-05 (`Handoff:392`) diffs only **2 pairs**: alex SKILL.md + blake SKILL.md. The remaining ~10 mirrored pairs (6 alex reference protocols, notebooklm-access.md, legacy-pack-research.md, academic-research SKILL.md, research-github SKILL.md) have no diff row.
- Pre-impl state: the two diffed pairs pass (`diff -u` exit 0), and research-github mirror also passes — so no current drift, but the gate as written certifies "12-file parity" on a 2-file sample. **Fix:** extend ROW-05 with `diff -q -r` (or explicit per-pair `diff -u`) over all mirrored pairs, or narrow AC7's "12" to the exact pair list ROW-05 checks.

**P1-4 — AC1's "`AGENTS.md` 保持对齐" clause is untestable (no carrier, no row).**
- AC1 (`Handoff:367`) requires `CLAUDE.md:44` rewrite AND "`AGENTS.md` 保持对齐" — but §6 has no AGENTS.md row, and spot-check shows **AGENTS.md contains no "NotebookLM"/research-default text at all** (`grep -n "NotebookLM\|research"` → only generic capability-pack rows). There is nothing to align and no command that could FAIL. Per Claims-Need-Carriers, an AC with no verification method is theater.
- **Fix:** either (a) delete the AGENTS.md clause from AC1, or (b) define what "对齐" means mechanically (e.g. `grep -c NotebookLM AGENTS.md` expects 0 — currently true) and add it as a ROW.

**P1-5 — §4.5 File 21 spec does not name the stale `*research-github notebook` table row.**
- `.tad/guides/tool-quick-reference-alex.md:169`: `| *research-github notebook <domain> | Create NotebookLM notebook from registry entries | Deep study |` — a stale "NotebookLM as the research action" pointer inside an in-scope file (File 21). File 21's spec (`Handoff:316-329`) covers the External-CLI section and the new Local Wiki suite generally but never names line ~169's row for rewording. Blake following the spec literally may leave it.
- **Fix:** add one bullet to File 21: reword the `*research-github notebook` row to fallback framing (or re-point it at the Local Wiki shim).

### P2 — Observations (Blake-tolerable, Alex triage)

**P2-1 — ROW-05 `diff -u` is valid but brittle; pre-impl baseline is clean.**
- `diff -u` exit 0 on both alex and blake pairs pre-impl, so the gate does not false-FAIL today. The false-FAIL risk (benign drift breaking a byte-equality gate) is real but **intended here**: the handoff's parity rule demands 1:1 mirrors, so any one-sided edit SHOULD fail. Mitigation is procedural: Blake must apply every edit to both mirrors in the same step and re-run ROW-05 before declaring done.

**P2-2 — Spot-check hit outside inventory: `.tad/guides/nondev-execution-track.md:290`.**
- `grep -rn "NotebookLM" .tad/guides/` returns exactly 3 files: the two in-scope quick-refs + `.tad/guides/nondev-execution-track.md:290`. The third file is **not in §2 inventory**. From the visible fragment it reads as historical-protocol prose (Conductor-side research), not a "*research* defaults to NotebookLM" routing pointer, so likely correctly out of scope — but Alex should confirm with a one-line triage note, otherwise a post-impl whole-codebase grep will re-flag it.

**P2-3 — `research-github` LOCAL-WIKI SHIM (2026-08-28) already exists at lines 193–200 — spec should say "extend," not "create."**
- Lines 189–200 already contain a `LOCAL-WIKI SHIM` block stating primary-is-local_wiki and NotebookLM-fallback. The File 27&28 instruction to "彻底移除强制建立 NotebookLM 的入口暗示" is therefore partially done for the command body; the remaining staleness is the frontmatter (lines 3/11) and the later `Step 6/7: Create NotebookLM notebook` steps (lines 232–242), which the spec does not address line-by-line.

**P2-4 — File 2 (`research/CLAUDE.md:41`) is already compliant; spec is a no-op confirmation.**
- Current text: "Primary: `local_wiki`. NotebookLM is **fallback only**… `research-github` writes canon, not notebook." This already satisfies the File 2 modification spec. Suggest rewording File 2 spec to "verify-and-hold (already compliant; confirm byte-stability)" so Blake doesn't invent an unnecessary edit.

---

## AC-by-AC table (verifiability)

| AC | Verdict on testability | Runnable method today (pre-impl) | Finding |
|---|---|---|---|
| AC1 Root Docs | ⚠️ PARTIAL — CLAUDE.md half runnable, AGENTS.md half not | `grep -n "默认走 NotebookLM" CLAUDE.md` → **line 44 hit pre-impl** (post-impl expects empty). AGENTS.md: no method given; file has no NotebookLM text | P1-4: add or drop the AGENTS.md clause |
| AC2 Alex Skill | ✅ RUNNABLE | `grep -n "defaults to NotebookLM" .claude/.agents alex/SKILL.md` → **4 hits (L397+L475 × 2 mirrors) pre-impl**; post-impl expects empty + positive greps for `primary: Local Wiki` / `preflight` / `check_wiki` (positive greps not in §6 — recommend adding) | PASS as negative gate; strengthen with positive-pattern rows |
| AC3 Step 3.8 scan | ⚠️ PARTIAL — no §6 row | No ROW covers Step 3.8; would need `grep -n "Local Wiki.*canon_count\|REGISTRY" alex/SKILL.md` | Missing ROW (add row when fixing §6) |
| AC4 Blake 1_5b | ✅ RUNNABLE (via ROW-03) | `grep -n "1_5b_research_check"` → **currently 0 hits** (only `1_5b_notebook_check` at L587/598 × 2 mirrors); post-impl expects hits in both files | Good discriminating gate (absent→present) |
| "Cat 5" protocols | ❌ DEFECTIVE — mislabeled, drops learn-path | No ROW covers any of the 6 protocols | **P0-2**: rename to AC5, add learn-path, add ROW(s) |
| AC6 Quick-refs | ⚠️ PARTIAL — half covered | ROW-04 covers alex (`Local Wiki Research Suite`, currently 0 hits → present post-impl). **No row for blake** (`Local Wiki Research Lookup (Primary)` section) | Add blake-side grep row |
| AC7 Parity | ⚠️ UNDER-COVERING | ROW-05 diffs 2 of 12 pairs (both exit 0 pre-impl) | **P1-3**: extend to all pairs or narrow the "12" |
| AC8 Fallback+Charter | ❌ DEFECTIVE (charter half) | `test -f setup-notebooklm.sh && test -f REGISTRY.yaml` → **both EXIST**, good. Charter half via ROW-06 → **already non-empty + bad path** | **P0-1**: re-baseline ROW-06 |

---

## Evidence commands run (verbatim, `workdir=/home/box/云同步/TAD`)

**E1 — Stale-pointer existence (ROW-01/02/03 pre-impl baseline).**
- `grep -n "默认走 NotebookLM" CLAUDE.md` → line 44 hit (Handoff:159-162 quote accurate).
- `grep -n "defaults to NotebookLM" .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` → 4 hits (L397+L475 × 2 mirrors).
- `grep -n "1_5b_notebook_check\|1_5b_research_check" .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md` → `1_5b_notebook_check` at L587/598 × 2 mirrors; `1_5b_research_check` 0 hits (correct pre-impl state for a create-gate).

**E2 — SSOT comparison.** Handoff §3.1 tiers (`primary: local_wiki / secondary: notebooklm_research / tertiary: claude_websearch`) match `.tad/config-workflow.yaml:787-791` **byte-for-byte**; §3 trigger elaborations are consistent refinements, not contradictions. Architecture = COMPLETE on this axis.

**E3 — Parity baseline (ROW-05).** `diff -q` on alex pair, blake pair, research-github pair → all exit 0. No pre-existing drift.

**E4 — ROW-06 pre-FAIL + missing charter path (P0-1).** `git status --porcelain docs/pm/ docs/pm-charter.md` → `M docs/pm/intent.md`, `M docs/pm/now.md` (exit 0, non-empty). `ls docs/pm-charter.md` → No such file or directory. `ls docs/pm/` → acceptance.md auth.md intent.md now.md status.md.

**E5 — Spot-check greps.** `grep -rn "NotebookLM" .tad/guides/` → 3 files (2 in-scope quick-refs + nondev-execution-track.md:290). research-github SKILL.md frontmatter lines 3/11 still stale. In-inventory hits confirmed for legacy-pack and academic-research; both `notebooklm-access.md` mirrors + `setup-notebooklm.sh` + `REGISTRY.yaml` exist.

**E6 — Fallback preservation (ROW-07).** `test -f .tad/cross-model/setup-notebooklm.sh && test -f .tad/research-notebooks/REGISTRY.yaml` → exit 0 (both EXIST).

**E7 — Count + AGENTS.md + research/CLAUDE.md.** `grep -c "^#### File"` → 16 headers; highest File number 28. AGENTS.md has no NotebookLM-default line. `research/CLAUDE.md` §6 already compliant ("Primary: `local_wiki`. NotebookLM is **fallback only**…").

---

## Gate 2 checklist mapping (for the Gate 2 record)

| Gate 2 item | This review's result |
|---|---|
| Architecture Complete | ✅ PASS — §3 tiers match SSOT byte-for-byte (E2); triggers are consistent refinements |
| Components Specified | ✅ PASS on sampled verification — CLAUDE.md:44, alex L397/L475 ×2 mirrors, blake 1_5b L587/598 ×2 mirrors all confirmed present (E1); §2 stale-pointer quotes accurate |
| Functions Verified (§1 claim: lint.sh/generate.py/search.py exist) | ⚠️ NOT re-verified in this leg (out of assigned scope; recommend Leg-2 or Blake preflight `test -x` confirmation) |
| Data Flow Mapped | ✅ ADEQUATE — §3.2 + 1_5b spec gives an ordered check→probe→fallback chain with commands |
| AC verifiability | ❌ BLOCKED — P0-1 (ROW-06 false-FAIL), P0-2 (learn-path untested); P1-3/P1-4/AC3/AC6 gaps |
| Scope/boundary | ✅ CLEAR on prohibitions (NotebookLM retention + GM charter, stated ≥3×: §1.2, §1.3, §8) but ❌ COUNT WRONG (26 claimed vs 28 numbered; true scope 28–29 with mirror — P1-1/P1-2) |

**Requested verdict restated:** **CONDITIONAL.** Fix P0-1 (re-baseline ROW-06 + charter path) and P0-2 (AC5 rename + learn-path + ROW), address P1-1–P1-5 in the handoff text, then re-run this leg's E1–E7 commands as the §6 smoke check before releasing to Blake. No files were written by this review.
