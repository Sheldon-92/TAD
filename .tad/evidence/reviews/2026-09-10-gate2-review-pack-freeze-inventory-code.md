---
gate: 2
reviewer: Reviewer 2 — code-reviewer (independent, non-author)
handoff: .tad/active/handoffs/HANDOFF-20260910-pack-freeze-inventory.md
design: .tad/evidence/designs/2026-09-10-pack-freeze-apply.md
date: 2026-09-10
channel: cursor
model: inherit
route: host
scope: AC python one-liners, markdown table escapes, git diff-tree HEAD, scan-packs header drift, extract_frontmatter_field insert recipe, KEEP SKILL exclusion
counts: {P0: 3, P1: 4, P2: 3}
verdict: FAIL
round2_counts: {P0: 0, P1: 2, P2: 3}
round2_verdict: PASS
---

Model: harness=cursor | model=inherit | route=host

# Gate 2 Review — code-reviewer — HANDOFF-20260910-pack-freeze-inventory

Independent read-only review of the YAML inventory handoff (not an implementation). Author claims in §7.4 / Verified Output were re-run, not trusted.

## Scope of this review

Handoff §6, §7.2, §9.1 (all AC Verification Methods), §10. `scan-packs.sh` L1–195. `pack-registry.yaml` header (no `status` keys today). Blast-radius greps: `status:` on CAPABILITY.md; scan-packs status emit.

Did **not** insert freeze flags, run live `scan-packs.sh` against the working tree, or stage/commit.

## Independent facts (this review)

| Check | Observed |
|---|---|
| Branch / HEAD | `main` @ `9c33e2e5` (pack-loader thin). **ahead 2** of `origin/main` (`7048b835` verify-delta + `9c33e2e5`) |
| Worktree | 17 porcelain paths (handoffs, NEXT, PROJECT_CONTEXT, patterns, untracked release/pack-freeze files). **None** of §7.2 yet dirty |
| CAPABILITY `^status:` | **0 hits** under `.tad/capability-packs/*/CAPABILITY.md` |
| Registry `status:` | **0 keys**. Header still `last_scanned: "2026-07-13"`, `synced_from_version: "2.44.0"` (no status-derived comment line yet) |
| `.tad/version.txt` | `2.44.4` (so a legal scan **will** rewrite `synced_from_version`) |
| `extract_frontmatter_field` | L47–54: awk `^'"$field"': ` → **`^status: ` with a space required** |
| Coerce / emit | L167–169 `frozen\|active` else `active`; L189 `status: "${pack_status}"` |
| Pack dirs vs FREEZE_14∪KEEP_11 | 25 / 25, no leftovers, no overlap |
| First-fence last keys | Mixed: several FREEZE packs end on `keywords:`; many (incl. `product-thinking`, `research-methodology`) end on `type:` |
| `intent-router` L130 | Present: `Drop every pack whose registry \`status\` equals \`frozen\`` |
| CAPABILITY SKILL.md in packs dir | 8 files, including KEEP `web-frontend`, `web-ui-design`, `ai-agent-architecture` |

Pre-impl AC runs (python bodies **unescaped**, as Alex’s step1d likely did):

| AC | Result |
|---|---|
| AC1 | `[]` / `FAIL` (expected) |
| AC2 | `bad []` / `OK` |
| AC3 unescaped `frozen\|active` | `25 0 [] []` / `FAIL` (expected pre-impl) |
| AC4 | `25 25` |
| AC9 | all 1s, `rm 0 aci 1`, `OK` |
| AC11 unescaped needle | `OK` / `[130]` |

Verbatim **table-cell** runs (Group 0 “run the Method as written”):

| AC | Result |
|---|---|
| AC3 extracted from L411 (`frozen\|active` inside the `r"..."` ) | `25 0 [] []` / `FAIL` — **will stay FAIL after a correct regen** (0 `status` captures) |
| AC5 `HEAD \| python3` as in L413 | `fatal: ambiguous argument '|'` **exit 128** |
| AC11 L437 needle with `\`` | **FAIL**; `needle_repr` keeps backslashes; line list still `[130]` |

---

## 1. Critical Issues (P0)

### P0-1 AC3 table cell is not the regex Alex dry-ran — post-impl false-FAIL

**Where:** §9.1 AC3 Verification Method (single table row, `frozen\|active`); note at L439.

**What the file actually contains:**  
`st=re.findall(r"^\s+status: \"(frozen\|active)\"$",y,re.M)`

In a Python raw string, `\|` is a **literal pipe**, not alternation. Against scan-packs emit `    status: "frozen"` / `"active"` the findall is **empty**. `zip(names, st)` then yields no frozen/active sets → `FAIL` even when FR1–FR3 are perfect.

Alex already wrote “unescape before bash”. That note is **not** the Verification Method. spec-compliance-reviewer (Group 0) is contracted to run the cell **verbatim**. Extracting the cell and executing it (this review) already false-FAILs on today’s registry; it will false-FAIL on a correct post-scan registry too.

**Fix (handoff text only):** Move AC3 into a fenced `bash` block **outside** the table (same pattern as `FENCE_STATUS`) with a real `|` in `(frozen|active)`. Table cell: “run the AC3 fence in §9.1”. Do not rely on a footnote.

### P0-2 AC5–AC8 / AC10 `\|` is not a shell pipe — git ACs do not run

**Where:** §9.1 AC5, AC6, AC7, AC8, AC10.

Source bytes are `git diff-tree … -r HEAD \| python3 -c '…'`.

Verbatim bash: `\|` is an escaped `|` **argument** to `git`, not a pipeline. Observed: `fatal: ambiguous argument '|': unknown revision or path not in the working tree.` exit 128. No `BAD []` / `OK` line, so Gate 3 cannot record Expected Evidence.

Rendered-markdown copy-paste may show a real `|`; the `.md` source (what Group 0 reads) does not.

**Fix:** Fence these five commands outside the table with a real `|`, **or** drop the pipe and use `python3 -c '…' $(git diff-tree …)` / `subprocess` only. Same rule as P0-1.

### P0-3 Git ACs assume impl == `HEAD`, but §6 runs them before the commit — and current `HEAD` is not this ticket

**Where:** §6 Phase 1 steps 4–5 vs AC5–AC8, AC10 `diff-tree -r HEAD`; Phase 1 evidence still says `<impl SHA>`.

§6 order: “Run §9.1 AC1–AC10. Fix until green.” **then** `git add` §7.2 and commit.

If Blake follows that order on **this** repo:

- `HEAD` is `9c33e2e5` pack-loader (12 files including `.claude/skills/**`, `.agents/skills/**`, `AGENTS.md`, `scan-packs.sh`).
- AC5 on that tree: `BAD` includes blake `SKILL.md` + alex intent-router paths → **FAIL**.
- AC8: `AGENTS.md` / `scan-packs.sh` → **FAIL**.
- AC10: extras vs §7.2, missing 15 freeze paths → **FAIL**.

Those FAILs are **false** relative to an uncommitted but correct freeze worktree. Conversely, if another commit lands after the freeze commit, `HEAD` ACs inspect the wrong SHA (false PASS or FAIL).

Repo is also **ahead 2** of origin with a **dirty** tree (17 porcelain). A `git add` that is not exactly §7.2 absorbs noise; `HEAD`-only ACs never see unstaged KEEP SKILL rewrites.

**Fix:**

1. §6: content ACs (1–4, 9, 11) on the worktree **after** scan-packs; git ACs **only** after the impl commit, against **that SHA** (not ambient `HEAD`).
2. Replace `HEAD` in AC5–8/AC10 with an explicit `IMPL_SHA` (or `git rev-parse HEAD` immediately after the freeze commit, with a written guard that `git log -1 --format=%s` matches this task).
3. Warn in §10: do not squash onto `9c33e2e5` / `7048b835`; do not commit while other dirty identity files are mixed into the index.

Until P0-1–P0-3 are in the handoff, Gate 3 Group 0 cannot faithfully accept this ticket.

---

## 2. Recommendations (P1)

### P1-1 AC1 is looser than `extract_frontmatter_field` — §8.3 is wrong

scan-packs L50: `^status: ` (space). AC1/AC2/shared extractor: `r"^status:\s*(.*)$"` (`\s*` allows **no** space / tabs).

This review’s awk replica:

| Insert | AC1 | awk / scan-packs |
|---|---|---|
| `status: frozen` | `frozen` | `frozen` |
| `status:frozen` | `frozen` | **empty → coerce `active`** |
| `status:\tfrozen` | `frozen` | **empty → `active`** |
| `status: Frozen` | `Frozen` | `Frozen` → coerce **`active`** (AC1 also fails `== "frozen"`; AC3 fails — OK) |
| `status: "frozen"` | `frozen` | `frozen` |

§8.3 says `status:frozen` (no space) **must FAIL AC1/AC3**. **AC1 would PASS**; only AC3 (if its regex were fixed) would catch the silent unfreeze.

FR1 already requires space. Tighten AC1 to `r"^status: (.*)$"` (literal space, same as awk) **or** change §8.3 so no-space is “AC3 only”.

### P1-2 AC11 table needle false-FAILs on Python 3.13

Table: `needle="Drop every pack whose registry \`status\` equals \`frozen\`"`.

`python3 -c` of that cell: `SyntaxWarning: invalid escape sequence '\`'`, `needle_repr` is `'… \\`status\\` …'`, first line **FAIL**. Unescaped backticks match L130 (`OK`).

Alex Verified Output used the unescaped form. Verbatim cell ≠ that evidence.

**Fix:** Put the needle in a fenced block with real backticks, or match a backslash-free substring (`"equals \`frozen\`"` without md escapes — better: `"registry status equals frozen"` is too weak; use the exact file line without extra escapes).

### P1-3 KEEP SKILL exclusion ACs catch **committed** rewrites only

AC5 (`/SKILL.md` or `.claude/skills/` or `.agents/skills/` in **impl commit names**) **does** catch:

- KEEP `SKILL.md` under `.tad/capability-packs/{web-frontend,web-ui-design,ai-agent-architecture}/` if staged
- Runtime trees `.claude/skills/**` and `.agents/skills/**`

AC10 ⊆ §7.2 is the second net for KEEP `references/` under capability-packs.

They do **not** catch:

- KEEP SKILL / references rewritten then **left unstaged** (porcelain-only)
- Rewrite + restore in the same commit (byte identity; acceptable)
- Content hunks inside a §7.2 file that are not `status:` (filename ACs, same class as prior Gate 2 reviews)

**Fix:** One pre-commit command, not a new pathspec:  
`git status --porcelain -- .tad/capability-packs .claude/skills .agents/skills`  
must be only the 15 §7.2 paths (or empty besides those). Optional: `git diff HEAD -- KEEP_11 paths` empty.

### P1-4 Dirty / non-impl `HEAD` warning for Blake (operational)

Even after P0-3 text is fixed: this machine’s `HEAD` is pack-loader, not freeze. Running git ACs “to see if we’re green” **now** FAILs AC5/AC8/AC10. Blake must not “fix” that by editing `scan-packs.sh` / AGENTS / skills.

Do not let `last_scanned` / `synced_from_version` panic anyone into reverting the registry by hand (see P2-1).

---

## 3. Minor (P2)

### P2-1 scan-packs header drift will **not** false-FAIL current ACs

§4.2 correctly predicts: new status-derived header comment, `last_scanned` → UTC date of the run, `synced_from_version` `"2.44.0"` → `"2.44.4"`, every row gains `status:`.

No AC asserts `last_scanned == 2026-07-13` or byte-equality of the whole YAML. AC3 (once `|` is real) / AC4 only count names, keywords, and status **sets**. Header comment `# … (status: active|frozen)` does **not** match `^\s+status: "(frozen|active)"$`.

Residual: if Blake is **not** on `main`, `source_branch` also rewrites (not listed in §4.2). Today they are on `main` — OK. Add `source_branch` to the incidental list.

### P2-2 Insert recipe example ≠ several FREEZE last keys

FR1 / §4.1: last key of the **first** fence, exact `status: frozen` (space). That **is** what awk L50 matches. Quoted `"frozen"` also works (sed strips quotes).

The “After” YAML cartoon always shows `keywords: […]` then `status:`. Live first fences: `product-thinking` last key is `type: deep-skill`; `research-methodology` is `type: orchestration-router`; `agent-memory` etc. end on `type:`. Appending after the real last key is correct; copying the cartoon under `keywords:` when `type:` follows would still be “before close `---`” and OK, but a naive “insert after the keywords line” on files where `type:` is last is fine too — **inserting after keywords when type is below keywords** is still last-key if they put status at the bottom.

Risk is `replace_all` on `---` (`academic-research` has **12** `---` lines). §6 already forbids that. P2: say “append immediately before the first closing `---`”, not “after keywords”.

### P2-3 AC1 / AC9 / AC10 methods span multiple markdown table rows

AC1 L401–405, AC9 L417–421, AC10 L422–436 break the one-row-one-cell contract. A row splitter that only reads L401 gets an unclosed `python3 -c '`. Same class as P0-1; fenced blocks fix it.

Shared extractor L391–396 is already a good fence; AC1 should call it instead of inlining a second `\s*` parser.

---

## 4. What is sound (do not churn)

- Durable SSOT on CAPABILITY + derived registry via existing `scan-packs.sh` (L163–169, L189). No second freeze flag. Do not hand-edit registry `status` rows.
- Missing status = active (current live tree). Freeze is insert + rescan.
- §7.2 15-path commit is the right blast radius. Forbidden list matches FR4–FR6.
- Name-set equality (not `wc -l == 14` alone) matches principles.
- KEEP CAPABILITY AC2 is a valid pre-impl baseline; AC7 substring `k in n` does not flag FREEZE names (checked `academic-research` vs KEEP set).
- Reversibility: delete `status: frozen` + rescan. No loader edits.
- `research-methodology` in registry / not in AGENTS: AC9 encodes that; do not add an AGENTS row.

---

## 5. Verdict

**FAIL** — three P0s on Verification Method **runnability** (AC3 `\|`, git `\|`, `HEAD` vs §6 order / current pack-loader HEAD). The freeze **design** (14 first-fence inserts + one scan-packs regen) is coherent and small; Gate 2 cannot pass while Group 0 would false-FAIL a correct impl or false-FAIL a correct worktree.

| Severity | Count | Block Gate 2? |
|---|---|---|
| P0 | 3 | Yes — handoff AC/§6 text |
| P1 | 4 | Fix in the same patch if cheap; else record as Gate 3 obligation |
| P2 | 3 | Non-blocking |

### Blocking-fix checklist (handoff only)

- [ ] AC3, AC5–AC8, AC10, AC11 live in fenced blocks with real `|` / real backticks; table points at those fences
- [ ] Git ACs take impl SHA after commit; §6 order matches
- [ ] AC1 regex aligned with `^status: ` **or** §8.3 corrected
- [ ] Porcelain/KEEP SKILL worktree check (P1-3)

Re-review after those text edits; no product-tree change required for Gate 2.

---

# ROUND 2 (delta) — 2026-09-10

Model: harness=cursor | model=inherit | route=host

Independent re-read of handoff §6 / §7.2 / §9.1 and `.tad/evidence/acceptance-tests/pack-freeze-inventory/verify.py`. Did not re-litigate freeze design. Did not implement.

## P0 AC runnability — closed

| R1 P0 | Delta | Status |
|---|---|---|
| P0-1 AC3 `frozen\|active` in a table raw string | AC3 is `python3 …/verify.py AC3`; regex `r'^\s+status: "([^"]+)"$'` then set-eq on values `frozen`/`active`. No `\|`. Live run: `25 0 0 0` / `FAIL` exit 1 (expected pre-impl; **runnable**) | **Closed** |
| P0-2 `HEAD \| python3` not a pipe | AC5–AC8/AC10 use `subprocess.check_output(["git","diff-tree",…])`. §9.1 Methods are single backtick `python3 … verify.py ACn` with **no** `\|` in the Method cells | **Closed** |
| P0-3 git ACs vs uncommitted worktree / ambient HEAD | §6.4 worktree ACs: 1,2,3,4,9,11,12 **before** commit. §6.5 add §7.2 + record `IMPL_SHA`. §6.6 git ACs 5–8,10 against that SHA. `impl_names()` reads `IMPL_SHA` or `HEAD` | **Closed** |

`py_compile` OK. Verbatim Methods executed from repo: AC2/AC4/AC9/AC11/AC12 exit 0 as claimed; AC1 `[] FAIL`; AC3 `25 0 0 0 FAIL`.

## `parents[4]` chdir

`verify.py` lives at `.tad/evidence/acceptance-tests/pack-freeze-inventory/verify.py`.

| index | path |
|---|---|
| 0 | `…/pack-freeze-inventory` |
| 1 | `…/acceptance-tests` |
| 2 | `…/evidence` |
| 3 | `…/.tad` |
| **4** | **repo root `/home/box/云同步/TAD`** |

`ROOT = Path(__file__).resolve().parents[4]` then `os.chdir(ROOT)` is **correct**. Relative globs (`.tad/capability-packs`, `AGENTS.md`) resolve. Do not change to `parents[3]` (that would chdir into `.tad`).

## AC10 allow set vs §7.2

`ALLOW` = `{.tad/capability-packs/<FREEZE_14>/CAPABILITY.md}` ∪ `{.tad/capability-packs/pack-registry.yaml}` = **15 paths**.

Byte-for-byte the same 15 paths as the §7.2 fence (14 FREEZE CAPABILITY files + registry). No KEEP paths. No `verify.py` (correct: runner is out of Blake pathspec; if it were committed, AC10 would extra-FAIL).

AC10 requires **exact** equality (`not extra and not missing`), which is stricter than Phase 1 evidence bullet `diff-tree ⊆ §7.2` (subset). Grade Gate 3 on AC10, not the subset checkbox.

## Remaining issues (none P0)

### P1-3 (still open) porcelain / unstaged KEEP SKILL

Git ACs still inspect **only the impl commit**. Unstaged KEEP `SKILL.md` / `.claude/skills` / `.agents/skills` still invisible. Same as R1 P1-3. Gate 3 obligation: `git status --porcelain` on those trees must be only the 15 §7.2 paths at commit time. Not a Gate 2 P0.

### P1-4 (downgraded / residual) IMPL_SHA default

Default `HEAD` remains if Blake forgets `IMPL_SHA` and HEAD is still pack-loader. §6.6 and §9.1 prose now forbid grading that HEAD. Operational, not runnability. Do not “fix” AC5/AC8/AC10 by editing loaders.

### P2 (new / leftover text)

- §6 `#### 验证方法` still says “one-line `python3 -c` Methods”. Stale; Methods are `verify.py`. Non-blocking.
- §8.6 still “AC1–AC11”; AC12 exists.
- `first_fence` annotated `-> str` but returns a tuple. Harmless.

R1 P1-1 (awk vs `\s*`) **closed** in runner: AC1/AC2/AC12 use `^status: frozen$` (literal space). R1 P1-2 AC11 backtick **closed** (`chr(96)`). R1 P2-3 multi-row table Methods **closed**.

## Verdict

**PASS** — R1 P0-1/2/3 on Verification Method runnability are closed. `parents[4]` is the repo root. AC10 `ALLOW` == §7.2 (15 paths). No remaining P0 on this delta.

| Severity | Count | Block Gate 2? |
|---|---|---|
| P0 | 0 | No |
| P1 | 2 (porcelain; IMPL_SHA discipline) | No — Gate 3 hygiene |
| P2 | 3 (stale §6 python3 -c; §8.6 AC12; type hint) | No |
