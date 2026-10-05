# Gate 2 review — spec/design — pack freeze inventory

Model: harness=cursor | model=inherit | route=host

**Role:** Independent Gate 2 design/spec reviewer (not implementation, not the author).  
**Handoff:** `.tad/active/handoffs/HANDOFF-20260910-pack-freeze-inventory.md`  
**Scope read:** §3 FR + FREEZE_14/KEEP_11; §6; §7 pathspec; §9 + §9.1; §10; `scan-packs.sh` extract/coerce/emit (L47–54, L163–190); `academic-research/CAPABILITY.md` first 20 lines.  
**Out of scope (honored):** pack SKILL rewrites, leftovers, ACI, experiment-path, loader edits.

**Overall: FAIL**

The freeze mechanic, locked name lists, and pathspec are internally consistent and would freeze the right 14 names if Blake follows FR1–FR3 and ignores the broken table-cell commands. Gate 3 Group 0 is specified to run §9.1 Verification Methods verbatim. Several of those methods, as stored in the table, false-FAIL on a correct tree. That is a blocking AC-design defect, not an inventory-roster defect.

---

## P0

### P0-1 — AC3 `frozen\|active` is a literal-pipe regex; name-set check never binds

**Cite:** §9.1 AC3 Verification Method; AC3 regex note (after the table); `scan-packs.sh` L189 `status: "${pack_status}"`.

AC3 does **name-set equality** (`fz==freeze and ac==keep and len(names)==25`), which is the right shape (not count-only). The pattern that fills `st` is stored in the markdown table as:

`r"^\s+status: \"(frozen\|active)\"$"`

In Python that is a match for the five-character token `frozen|active`, not alternation. Verbatim run against a correct regen (`status: "frozen"` / `"active"`) yields `st=[]`, `zip` produces empty sets, prints `FAIL`.

The footnote tells Blake to unescape. Gate 3 spec-compliance is “run the Method verbatim.” Alex’s §7.4 “Temp copy dry-run: 25/14/11 OK” is therefore not evidence that the **table cell** command passes. Same class of defect as AC Verification Drift (`ac-verification.md`): Verified Output was produced from a different command than the one in the cell.

**Gate 3 impact:** correct freeze + scan still FAILS AC3.

**Required fix (spec only):** put AC3 in a fenced bash block **outside** the table (real `|`), or use two findalls / `frozen` and `active` without `|`. Do not rely on an unescape footnote.

### P0-2 — AC5 / AC6 / AC8 / AC10 table cells use `HEAD \| python3`

**Cite:** §9.1 AC5, AC6, AC8, AC10.

Those Methods are written `git diff-tree … HEAD \| python3 -c '…'`. Copied into bash, `\|` is an escaped pipe character, **not** a pipeline. `git` never feeds the name list to Python. Verbatim Gate 3 run cannot PASS even when the commit is exactly §7.2.

§9.1 intro says “unescape if copied from a table cell” but only AC3’s `|` inside a regex is called out. Pipeline `|` is the same markdown-table problem.

**Gate 3 impact:** post-impl pathspec ACs false-FAIL. Blake following the written Methods fails Gate 3.

### P0-3 — AC11 needle is markdown-escaped; live loader line does not match

**Cite:** §9.1 AC11; Alex Verified Output `OK` / `[130]`; `.claude/skills/alex/references/intent-router-protocol.md` L130.

Live text: `Drop every pack whose registry `status` equals `frozen` (exact match).`

Table Method: `needle="Drop every pack whose registry \`status\` equals \`frozen\`"`.

Verbatim run on current HEAD (this review): `FAIL` plus `SyntaxWarning: invalid escape sequence '\`'`, while the secondary line scan still prints `[130]`. Expected Evidence requires first line `OK`. Pre-impl AC is already red. Claimed Verified Output does not match the stored command.

This ticket must **not** edit loaders; AC11 is only a presence check. The Method still has to be executable as written.

**Gate 3 impact:** Group 0 fails AC11 on an unchanged, correct loader.

### P0-4 — §6 tells Blake to run AC1–AC10 **before** the impl commit

**Cite:** §6 Phase 1 steps 4–5; §9.1 AC5–AC8, AC10 (`git diff-tree … -r HEAD`).

Step 4: run AC1–AC10 until green. Step 5: `git add` §7.2 and commit.

AC5–AC8 and AC10 inspect **HEAD**, not the worktree. Linear execution of §6 either (a) grades the previous commit (false PASS/FAIL), or (b) fails AC10 because the 15 paths are not on HEAD yet. “Fix until green” cannot close those rows without a commit that the next step has not created.

**Gate 3 impact:** a Blake who follows the numbered recipe cannot get a coherent AC5–AC10 green before commit; after commit, table-escape P0-2 still applies.

**Required fix:** split worktree ACs (AC1–AC4) vs post-commit ACs (AC5–AC8, AC10); pin `IMPL_SHA` not ambient HEAD; run post-commit ACs only after step 5.

---

## P1

### P1-1 — First-fence recipe is right; Gate 3 cannot prove body was not corrupted

**Cite:** §3 FR1; §4.1; §6 step 1; §8.3 / §8.4; §10.1; `academic-research/CAPABILITY.md` (`---` at L1, L7, then L16, L35, L78, … — **12** `^---$` lines).

`extract_frontmatter_field` (`awk '/^---$/{if(++n==2) exit} n==1 && /^status: /'`) and the shared Python first-fence extractor (`find("\n---\n", 4)`) both stop at the **second** fence. Later `---` in academic-research are body. Inserting `status: frozen` as last key of the **first** pair cannot be misread as a later fence by scan-packs. That part of the spec **does** prevent freeze-mechanic corruption.

What it does **not** prevent is Blake `replace_all` on `---` or inserting `status: frozen` before every closing fence. First fence would still look frozen → AC1 PASS; body would be wrecked; no §9.1 row asserts “hunk = one added `status: frozen` line; bytes after first closing `---` unchanged.” Phase 1 “完成证据” mentions that diff in prose; it is not an executable Method. `ac-verification.md` hunk-not-file is named in Project Knowledge and not encoded in §9.1.

§6 says “Prefer” a first-fence-only editor, not a mandatory snippet. A careful Blake is safe; Gate 3 would still stamp PASS on a destroyed academic-research body.

Not P0 under the “following the recipe” test (recipe forbids global `---`). Still a spec hole before Blake starts: make first-fence-only insert **mandatory** with a copy-paste script, and add a hunk AC (e.g. `git diff -U0` only `+status: frozen` on those 14 files).

### P1-2 — AC1 `^status:\s*` vs scan-packs `^status: ` (space required)

**Cite:** §3 FR1; §4.1 (`^status: ` + coerce L167–169); §8.3 (`status:frozen` must FAIL AC1/AC3); §9.1 AC1.

`scan-packs.sh` L47–54: `/^field: /` — no space after colon → field missing → coerce `active`. AC1 uses `^status:\s*`, so `status:frozen` (no space) **passes AC1** and fails AC3 (registry still active). §8.3 overclaims AC1. Wrong-set freeze is still caught by AC3 **if** AC3’s regex is fixed (P0-1). Align AC1 with `^status: ` (space) so Layer 1 fails at the CAPABILITY file, not only after regen.

`Frozen` is correctly rejected by AC1 (`s=="frozen"`). That path is fine.

### P1-3 — Dual-platform: pathspec is complete for this ticket; AC11 is Claude-only

**Cite:** §3 FR4–FR5; §4.3; §7.2 Forbidden; §9.1 AC5, AC8, AC11; `.agents/skills/alex/references/intent-router-protocol.md` L130 (same skip sentence as `.claude`).

Pathspec is **minimal and complete** for the CAPABILITY+registry mechanic: 14 FREEZE `CAPABILITY.md` + live `pack-registry.yaml`. Explicitly excludes `scan-packs.sh`, loaders, AGENTS, CLAUDE, both skill trees. That is correct: this ticket must not edit loaders; dual-platform SKILL copies stay byte-identical.

Gaps (not “add loader edits”):

- AC11 only Reads `.claude/.../intent-router-protocol.md`. The `.agents/` twin is the Codex auto-match path. A stale/.agents-only drift would not fail AC11. Cheap spec fix: same needle on both files, still no loader edits.
- AC9 only grades root `AGENTS.md` keyword rows. Fine for FR5; Claude `CLAUDE.md` has no matching pack table (spot-check). No extra pathspec needed.

### P1-4 — AC4 is count-only (mitigated by a working AC3)

**Cite:** §9.1 AC4 (`25 25`); Project Knowledge deny-list / never pin absolute counts; §3 locked lists.

AC4 alone cannot prove the right 14 names. AC1+AC3 (once P0-1 is fixed) are the load-bearing name-set checks. AC4 is a useful sanity count (names vs `keywords:` lines) and is acceptable as a **companion**, not as the freeze oracle.

---

## P2

- **P2-1** §4.2 incidental registry header drift (`last_scanned`, `synced_from_version` from `.tad/version.txt`, `source_repo`) is documented; no AC that non-status pack fields stayed equal. Alex dry-run claim is not a Method. Low risk if Blake only runs stock `scan-packs.sh`.
- **P2-2** AC10 requires **all 15** paths on a **single** HEAD commit. A two-commit fix round fails AC10 even if the union is §7.2. State “one impl commit” as blocking, or allow `git diff-tree <base>..HEAD` union.
- **P2-3** Shared extractor `assert t.startswith("---\n")` / `find("\n---\n")` vs awk `^---$`: CRLF CAPABILITY would diverge. Live academic-research / product-thinking are LF first fences.
- **P2-4** AC7 KEEP detection uses substring `k in n`. The 11 names are distinct enough for this tree; still looser than path equality against the KEEP list.

---

## Focus answers (compressed)

| Focus | Verdict |
|--------|---------|
| 1. ACs executable vs prose Methods | Intent is command/path-check throughout. Several Methods are **not** executable as stored in the table (P0-1, P0-2, P0-3). AC1–AC4/AC9/AC11 **shape** is executable once escapes are removed. |
| 2. First-fence vs later `---` | Mechanic (scan-packs + Python first pair) ignores later fences. Recipe forbids `replace_all` on `---`. No AC proves body integrity (P1-1). |
| 3. Name-set vs count; `frozen\|active` | AC1/AC3 are name-set; AC4 is count-only companion. `frozen\|active` in the table is a **P0 false-FAIL**. |
| 4. Pathspec / dual-platform / no loaders | §7.2 is complete and minimal for CAPABILITY+registry. Dual-platform SKILLs correctly forbidden. AC11 should assert both intent-router copies without editing them. |
| 5. Wrong freeze set vs Gate 3 fail | Roster + FR1–FR3 would freeze FREEZE_14, not KEEP_11. P0s are **Gate 3 false-FAIL on a correct apply**, not a wrong roster. |

---

## What is already load-bearing (do not “redesign”)

- FREEZE_14 ∪ KEEP_11 = 25; both lists appear in §3, AC1–AC3, AC7, AC9, §7.2 (14 files + registry).
- FR1 last-key unquoted `status: frozen`; §4.1 warning that `Frozen` coerces to active (`scan-packs.sh` L167–169 `case frozen|active`).
- Durable SSOT = first fence; registry derived; do not hand-edit status (L163–165, §10.1).
- `research-methodology` in freeze + pathspec; AGENTS row count 0 left alone (§4.4, AC9).
- Forbidden commit set matches “must not edit loaders.”

---

## Gate 2 checklist (this reviewer’s)

| Item | Status |
|------|--------|
| Architecture complete | Yes — CAPABILITY first fence → scan-packs emit → existing frozen skip |
| Components specified | Yes — 14 files + registry; KEEP untouched |
| Functions verified (spec) | Extract/coerce/emit exist; ACs that observe them are broken as table text |
| Data flow | Yes — MQ5; AC3 intended as regen evidence |
| AC executable | **No** until P0-1–P0-4 patched |

**Verdict: FAIL** until P0-1–P0-4 are integrated into the handoff (unescape-free Methods; commit-then-verify). P1-1 should be closed in the same edit so academic-research body corruption cannot PASS Gate 3. Do not send Blake until those land.

Independent of author. No implementation performed.

---

## ROUND 2 — delta recheck (2026-09-10)

Model: harness=cursor | model=inherit | route=host

**Role:** Independent Gate 2 spec reviewer (delta only). Author claimed R1 P0s integrated. No freeze applied.

**Checked:** handoff §6 steps 4–6, §7.2, §9.1 Methods AC1–AC12, §9.2 audit trail; `.tad/evidence/acceptance-tests/pack-freeze-inventory/verify.py`.

### §9.1 Methods (verbatim Gate 3 shape)

All 12 Method cells are exactly:

`python3 .tad/evidence/acceptance-tests/pack-freeze-inventory/verify.py ACn`

No shell pipe in the Method. No markdown `\|` inside Method cells. AC3 regex lives in `verify.py` as `status: "([^"]+)"` (no alternation pipe). AC5–AC8/AC10 use `subprocess.check_output(["git","diff-tree",...])` with `IMPL_SHA` or HEAD — not `HEAD | python3`.

§6 “验证方法” still says “one-line `python3 -c` Methods” — stale prose vs the table. Gate 3 is specified to run §9.1 Methods, not that sentence. **Not P0.**

### Pre-impl ACs (this round, live tree, no freeze)

| AC | stdout | exit |
|----|--------|------|
| AC2 | `bad []` / `OK` | 0 |
| AC4 | `25 25` | 0 |
| AC9 | `rm 0 aci 1` / `OK` | 0 |
| AC11 | `OK` | 0 |
| AC12 | `BAD []` / `OK` | 0 |

### P0 close-out

| ID | R1 defect | R2 evidence | Status |
|----|-----------|-------------|--------|
| P0-1 | AC3 `frozen\|active` literal pipe | Method is `verify.py AC3`; runner findalls quoted status values | **Closed** |
| P0-2 | `HEAD \| python3` in table | Methods are `verify.py AC5–AC8/AC10`; git via argv list | **Closed** |
| P0-3 | AC11 markdown-escaped backticks | `needle = "equals " + chr(96) + "frozen" + chr(96)`; both `.claude` and `.agents` twins; live L130 matches; AC11 exit 0 | **Closed** |
| P0-4 | §6 run git ACs before commit | Step 4 worktree AC1/2/3/4/9/11/12; step 5 commit; step 6 post-commit AC5–AC8/AC10 with `IMPL_SHA` | **Closed** |

R1 P1 items encoded as claimed: AC12 (P1-1 body fence), `^status: frozen$` (P1-2), AC11 twins (P1-3), name-sets in AC1/AC3 (P1-4). AC12 is presence-of-body-`status: frozen`, not a full hunk-byte AC; remains P1 residual, not P0.

### Remaining P0?

**None.** Correct freeze + scan can be graded by the stored Methods without table-escape false-FAIL. Do not implement freeze in this review.

**Verdict: PASS**

