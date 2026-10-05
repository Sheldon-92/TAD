# Gate 2 Leg-2 Blast-Radius Review

**Design under review:** `.tad/active/handoffs/HANDOFF-20260908-research-route-local-wiki.md` (v1.0, Ready-for-Gate2, Gate 2 PASS not claimed)
**Lens:** BLAST RADIUS + CONSUMER COMPLETENESS + SAFETY (not prose style)
**Pattern basis:** `.tad/project-knowledge/patterns/handoff-design.md` — "git grep Is Blind to Untracked Files" + "Count the Copies Before Editing a Rule" (skimmed as instructed)
**Harness:** OpenCode (charter §3.7 compliant — Gate 2 dual-review executed inside OpenCode, not Cursor).
**Provenance:** Independent subagent session `ses_f7d967a57ffeC5lR9VX2CLYcWr`, output persisted verbatim by Alex. Judge ≠ producer (reviewer did not author the handoff).

## Verdict

**CONDITIONAL** — design direction is sound (Local Wiki primary / NotebookLM fallback / WebSearch tertiary matches `config-workflow.yaml`; fallback preservation and SKILL-body discipline are correct), but Blake must NOT execute as written until the items below are fixed. **1 × P0** (unpassable gate as written), **5 × P1** (fix before Blake), 1 × P2.

- P0-1 (§6 ROW-06 unpassable against dirty `docs/pm/` worktree — Gate 3 cannot go green).
- P1-1 (consumer inventory is sample-verified only; paraphrase sites exist outside the 26-file list).
- P1-2 (§4 File 27&28 omits the `.agents` research-github mirror that exists on disk).
- P1-3 (§5 "Cat 5" AC drops `learn-path-protocol.md` which §4 covers — AC/§4 mismatch).
- P1-4 (26-count vs enumerated slots mismatch).
- P1-5 (`research/` write scope ambiguous: spec text invokes writeful `ingest.sh`/`generate.py` while §1.3 declares `research/` untouched).
- P2-1 (observation: no untracked live-contract collision on exact strings).

---

## Findings (numbered)

### P0-1 — ROW-06 is unpassable in the current worktree (gate-definitional defect)
- **Evidence:** `git status --porcelain docs/pm/ docs/pm-charter.md` returns (verified this session):
  ```
  M docs/pm/intent.md
   M docs/pm/now.md
  ```
  Both modifications pre-date any Blake implementation. ROW-06 expects empty output.
- **Consequence:** As written, Blake's execution **cannot** produce a green ROW-06 through correct behavior — the gate is red on arrival. Blake would be forced to either (a) falsely FAIL a correct implementation, (b) revert another workstream's in-flight edits (out-of-scope write, violates the concurrent-terminals pathspec discipline), or (c) silently amend the gate. This is exactly the P0 class: "design defect causing … unpassable gate."
- **Exact fix (apply one):** Replace ROW-06 with a baseline-scoped assertion, e.g.:
  > `ROW-06 (revised): Record baseline before first edit: git status --porcelain docs/pm/ docs/pm-charter.md > /tmp/row06.baseline (currently: ' M docs/pm/intent.md', ' M docs/pm/now.md'). After implementation, assert git diff of docs/pm/ + docs/pm-charter.md against that baseline is empty — i.e., no NEW modifications beyond the two pre-recorded lines. Attach both outputs as evidence.`
  Alternatively, narrow ROW-06 to the true charter carrier (`docs/pm-charter.md` only) if `docs/pm/*.md` churn is owned by another workstream — but then say so explicitly and record the baseline for `docs/pm/` as informational.

### P1-1 — Consumer inventory is "sample-verified, exhaustion not proven" (paraphrase sites outside inventory)
- **Exact-string scan (§2/§4 coverage): COMPLETE for the 9 tracked hits.** `git grep -n "defaults to NotebookLM\|默认走 NotebookLM\|1_5b_notebook_check"` returns exactly:
  - `CLAUDE.md:44` (covered — Cat A File 1) ✓
  - `.claude/skills/alex/SKILL.md:397,475` + `.agents/skills/alex/SKILL.md:397,475` (covered — Cat B File 3&4) ✓
  - `.claude/skills/blake/SKILL.md:587,598` + `.agents/skills/blake/SKILL.md:587,598` (covered — Cat D File 17&18; :587 is the caller arrow, :598 the definition) ✓
- **Untracked scan: no hidden exact-string collision.** `git ls-files --others --exclude-standard | xargs grep -ln "defaults to NotebookLM\|默认走 NotebookLM"` returns only the handoff itself. No live sibling contract pins these exact strings.
- **But the handoff's real scope is paraphrases, and those demonstrably exceed the inventory.** Verified paraphrase/out-of-inventory sites (at least 2, actually several):
  1. `.claude|agents/skills/alex/SKILL.md:748-749` `1_find_notebook` + `:1094` `research_notebook_awareness` trigger — the body sites are covered, but the *same concepts* recur in files NOT in §2/§4: `alex/references/adaptive-complexity-protocol.md:171-195` (cross-checks `.tad/research-notebooks/REGISTRY.yaml`, notebooklm CLI refresh policy), `alex/references/status-panoramic-protocol.md` (2 REGISTRY hits), `alex/references/deps-protocol.md:132` (`notebooklm-cli` registry-null carve-out), `research-notebook/SKILL.md` (23 self-hits — the fallback engine itself, correctly out of scope but never explicitly ruled out), `research-github/SKILL.md` (22 REGISTRY/notebook hits — §4 covers only "标题和前置条件," leaving the other ~20 hits' disposition unstated), `.agents|claude/skills/alex-lite/SKILL.md:408` (research-notebooks mention in Lite, presumably intentionally untouched — but unstated).
  2. `research-plan-protocol.md` alone has 10+ `*research-notebook`/`notebooklm source add|ask` execution bodies (:264-:474, :634-:661) that §4 re-characterizes as "加上 Fallback 保护层" without line-level disposition of each body — a reviewer cannot tell whether Blake must touch all of them or just the header.
- **Grade rationale (P1, not P0):** the core exact-string set IS complete; the residual risk is missed-consumer drift (rules split between updated entry pointers and stale execution bodies — the "Count the Copies" failure mode), which is fix-before-Blake but not a proof of wrong-implementation.
- **Exact fix:** Either (a) expand §2 with an explicit wordlist sweep table (`1_find_notebook`, `research_notebook_awareness`, `step2_5_notebook_check`, `research-notebook`, `REGISTRY.yaml` scoped to research-notebooks) mapping every hit to in-scope-file:line or to an explicit "OUT-OF-SCOPE + why (reachability unaffected)" ruling; or (b) add a §4.x "Explicitly out of scope" list naming `adaptive-complexity-protocol.md`, `status-panoramic-protocol.md`, `research-notebook/SKILL.md`, `alex-lite/SKILL.md`, `deps-protocol.md`, `pack-upgrade.workflow.js` with one-line reachability justification each. Minimum: the two adaptive/status files + the research-github residual hits must be dispositioned.

### P1-2 — §4 File 27 & 28 omits an existing mirror (mirror not listed explicitly)
- **Evidence:** §4.6 last bullet is headed "File 27 & 28" but names `.tad/capability-packs/academic-research/CAPABILITY.md` **and** `.claude/skills/research-github/SKILL.md` — not a mirror pair. `ls` this session confirms `.agents/skills/research-github/SKILL.md` **exists** yet is named nowhere in §4. The "12 files claimed" mirror invariant (§5 AC 7: "对应的 12 个核心技能与引用文件保持 100% 对齐") therefore has an unnamed 13th mirror file that Blake will either miss (parity split — the exact "Count the Copies" failure) or touch without spec cover (scope ambiguity).
- **Secondary:** `.tad/capability-packs/academic-research/SKILL.md` also exists and is never dispositioned — is it in or out?
- **Exact fix:** Rename the bullet to File 27/28/29 (or two bullets): `File 27: .tad/capability-packs/academic-research/CAPABILITY.md (singleton, no mirror)` + `File 28 & 29: .claude/skills/research-github/SKILL.md & .agents/skills/research-github/SKILL.md (mirror pair)`, and add one line dispositioning `.tad/capability-packs/academic-research/SKILL.md` (in-scope or out with reason). Reconcile the "26 files" headline count accordingly.

### P1-3 — §5 "Cat 5" AC text drops a file that §4 covers (AC/§4 mismatch)
- **Evidence:** §4.3 specifies six reference pairs including `learn-path-protocol.md` (File 15 & 16, Step 3_5 quiz/flashcards). §5's protocol AC (line ~375) enumerates only five: research-plan, handoff-creation, discuss-path, research-decision, research-review — `learn-path-protocol.md` is absent. Gate 3 run against §5 as written would leave File 15 & 16 unverified (or force Blake to guess whether they are required).
- **Exact fix:** Amend the AC bullet to list all six protocols including `learn-path-protocol.md` with its Step 3_5 criterion.

### P1-4 — Headline "26 files" does not match the enumerated slots
- **Evidence:** Counting §4 bullets as specified: Cat A 2 + Cat B 2 + Cat C 12 (six pairs) + Cat D 4 (two pairs) + Cat E 2 + Cat F 6 (legacy 2 + academic 2 + File 27&28 as 2 slots) = **28 slots**, not 26. (If CAPABILITY.md is a singleton and research-github's `.agents` mirror was unintentionally folded in, the true intended set may be 27 — either way ≠ 26.)
- **Exact fix:** Recount after fixing P1-2 and correct the headline in §2/§5/§8 (message to Blake) to the true number, or itemize which two slots are informational-only. Blake's completion check must be able to assert "N files touched, zero more."

### P1-5 — `research/` write scope is ambiguous (side-effecting scripts invoked by the spec)
- **Evidence:** §1.3 hard boundary: "不是重构 Local Wiki 本身（`research/` 核心目录结构、lint 规则保持不变，仅修复引用它的入口和调用规范）". But §4.2 item 5 (`2_ingest_and_compile_if_needed`) and §4.3 research-plan Phase 1–4 describe executing `research/scripts/ingest.sh`, writing 12-field canon entries, compiling wiki pages, running `research/canon/lint.sh` + `research/scripts/generate.py`. `ingest.sh`/`generate.py` are **writeful** (raw/ ingestion, index regeneration); `search.py --json` and `lint.sh` are read-only/verification. Nothing in §4/§5 states whether `research/` outputs are an authorized write target for verification runs or strictly out of scope.
- **Risk:** Blake either (a) runs the toolchain to "verify" and writes files outside the 26-file scope (scope expansion, dirty tree, possible index churn tripping unrelated gates), or (b) avoids running it and leaves the new `preflight`/`standard_execution` logic untested. Both readings are defensible from the current text.
- **Exact fix:** Add one scoping sentence to §4.2 item 5 (and mirror in §5 AC 2), e.g.: "`research/` is READ-ONLY for this task except `lint.sh`/`search.py` dry verification; Blake MUST NOT run `ingest.sh`/`generate.py` in write mode — quote the commands in spec text only. Any `research/` file modification is out of scope and fails scope compliance." Or, if a live index regen IS intended, list the exact generatable paths as in-scope File 29+ with a regeneration-and-revert protocol.

### P2-1 — Positive: no untracked exact-string collision; pre-change mirrors are identical
- Untracked scan surfaced no live sibling contract pinning the exact stale strings (only the handoff itself). Pre-change parity is clean: `diff -q` on alex SKILL pair, blake SKILL pair, and `research-plan-protocol.md` pair all report **identical** (exit 0) — so §5 AC 7's `diff`-based verification starts from a non-drifted base. No action required; recorded so Gate 3 need not re-prove the base.

---

## Consumer scan results (commands + hits)

**Command 1 (tracked):**
`git grep -n "defaults to NotebookLM\|默认走 NotebookLM\|1_5b_notebook_check" -- .`
Result (9 hits, all covered by §2/§4):
```
CLAUDE.md:44: …（默认走 NotebookLM 持久知识库）。 → Cat A File 1 ✓
.claude/skills/alex/SKILL.md:397: tad_replacement: "*research (unified — Quick/Standard/Deep, defaults to NotebookLM)" → Cat B ✓
.claude/skills/alex/SKILL.md:475: research: "Unified research — Quick/Standard/Deep, defaults to NotebookLM Standard" → Cat B ✓
.agents/skills/alex/SKILL.md:397,475: (same ×2) → Cat B mirrors ✓
.claude/skills/blake/SKILL.md:587: → Proceed to 1_5b_notebook_check → Cat D (caller arrow of covered node) ✓
.claude/skills/blake/SKILL.md:598: 1_5b_notebook_check: → Cat D File 17 ✓
.agents/skills/blake/SKILL.md:587,598: (same ×2) → Cat D mirrors ✓
```

**Command 2 (untracked):**
`git ls-files --others --exclude-standard | xargs grep -ln "defaults to NotebookLM\|默认走 NotebookLM"`
Result: only `.tad/active/handoffs/HANDOFF-20260908-research-route-local-wiki.md` (the design itself). No other in-flight contract pins the exact stale strings.

**Paraphrase probe (tracked, scope-check):**
`git grep -n "1_find_notebook\|research_notebook_awareness\|research-notebook\|REGISTRY.yaml"` shows the paraphrase field is an order of magnitude larger than the 9 exact hits — including `alex/SKILL.md:748-749 (1_find_notebook)`, `:1094 (research_notebook_awareness trigger)`, `discuss-path-protocol.md:44+`, `research-decision-protocol.md:100 (step2_5_notebook_check)`, plus **out-of-inventory** `adaptive-complexity-protocol.md:171-195`, `status-panoramic-protocol.md` (2 hits), `research-notebook/SKILL.md` (23 hits), `research-github/SKILL.md` (22 hits), `alex-lite/SKILL.md:408`, `deps-protocol.md:132`, `pack-upgrade.workflow.js`. At least 2 such sites sit outside §2/§4 → inventory graded "sample-verified, exhaustion not proven" (P1-1).

---

## Parity check results

| Pair | Command | Result |
|---|---|---|
| alex SKILL | `diff -q .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` | **identical** (exit 0) |
| blake SKILL | `diff -q .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md` | **identical** (exit 0) |
| research-plan-protocol.md | `diff -q .claude/skills/alex/references/research-plan-protocol.md .agents/skills/alex/references/research-plan-protocol.md` | **identical** (exit 0) |

Does §4 list every mirror explicitly? **No** — all pairs through File 25 & 26 do, but File 27 & 28 does not: the existing `.agents/skills/research-github/SKILL.md` is unnamed, and `.tad/capability-packs/academic-research/SKILL.md` is undispositioned. Flagged as P1.

**Circular-trigger safety (§4 vs principles.md:103): YES — Iron Rule + routing table stay in body.** §4.2 item 5 specifies the rewritten `standard_execution` (`1_check_wiki → 2_ingest_and_compile_if_needed → 3_fallback_notebooklm`) and the `preflight` routing table as content of the SKILL body (Line ~682-750 region), and §📚 lines 104-105 explicitly retain the "must stay in SKILL body" constraint. No load-bearing trigger is moved to `references/`; the reference files receive only non-circular execution bodies. **No P0 here.**

**GM charter + fallback preservation:**
- `test -f .tad/cross-model/setup-notebooklm.sh` → exists; `test -f .tad/research-notebooks/REGISTRY.yaml` → exists (ROW-07 preconditions hold).
- `git status --porcelain docs/pm/ docs/pm-charter.md` → `M docs/pm/intent.md`, `M docs/pm/now.md` (pre-implementation dirt). Full-tree `git status --porcelain` additionally shows extensive unrelated modifications, reinforcing that Blake must work pathspec-scoped and gates must be baseline-relative.

**Write-scope risk:** see P1-5. `research/` outputs are neither explicitly in-scope nor explicitly excluded despite writeful scripts appearing in the spec text.
