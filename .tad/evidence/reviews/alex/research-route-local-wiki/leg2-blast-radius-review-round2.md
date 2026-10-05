# Gate 2 Round2 Leg-2 Blast-Radius Review (rev2 delta re-review)

**Target:** `.tad/active/handoffs/HANDOFF-20260908-research-route-local-wiki.md` rev2 (Version 2.0, Ready-for-Gate2-rereview)
**Lens:** BLAST RADIUS + CONSUMER COMPLETENESS + SAFETY (code-reviewer perspective, not prose style)
**Pattern basis:** `.tad/project-knowledge/patterns/handoff-design.md` — "git grep Is Blind to Untracked Files" + "Count the Copies Before Editing a Rule"
**Workdir:** `/home/box/云同步/TAD` · **State:** PRE-implementation (only handoff text changed rev1→rev2) · **Method:** all commands re-executed by this reviewer; no files written; no contact with Blake; no knowledge of Leg-1 Round2 reviewer.
**Harness:** OpenCode (charter §3.7 compliant).
**Provenance:** Independent subagent session `ses_f7d89b689ffeookyt2kIDyyzhg`, output persisted verbatim by Alex. Judge ≠ producer (reviewer did not author the handoff).

## Verdict

**CONDITIONAL** — both P0s fixed in text; two P1s PARTIAL; two NEW safety/robustness notes. Blake must NOT start until the two PARTIALs are closed in text (both are text-only fixes, no implementation).

- P0-1 (=P0-A ROW-06): **FIXED** (+ NEW N1 `/tmp` lifecycle note).
- P1-1 (paraphrase inventory): **PARTIAL** — 9-item §2.2 verified, but 3 active surfaces undispositioned.
- P1-2 (mirror omission): **FIXED**.
- P1-3 (ROW-05 coverage): **FIXED** (+ advisory on `|| exit 1` early-exit).
- P1-4 (count): **FIXED** (+ trivial 8/9 text mismatch).
- P1-5 (research/ write-scope): **PARTIAL** — strict in §1.3/AC2, re-softened in §8 ("in write mode"); generate.py has no dry mode. One-line fix.

---

## 1. Evidence commands executed (all in `/home/box/云同步/TAD`)

| ID | Command | Result summary |
|---|---|---|
| C1 | `git grep -n "defaults to NotebookLM\|默认走 NotebookLM\|1_5b_notebook_check" -- .` | 9 tracked hits (details §2) |
| C2 | `git ls-files --others --exclude-standard \| xargs grep -ln "defaults to NotebookLM\|默认走 NotebookLM"` | exactly 1 hit: the handoff itself (expected) |
| C3 | `git grep -n "1_find_notebook\|research_notebook_awareness\|step2_5_notebook_check\|research-notebook\|REGISTRY.yaml" -- .` (full count + file histogram) | **601 hits across ~60 files** (details §3) |
| C4 | `diff -q` over all 12 ROW-05 pairs + `ls` File 27/28/29 split | all 12 IDENTICAL pre-implementation; split matches disk (details §4) |
| C5 | `git status --porcelain docs/pm/`; full-tree `git status --porcelain` + count; `ls docs/pm/ docs/pm-charter.md` | `M docs/pm/intent.md`, `M docs/pm/now.md`; full tree **228 dirty entries**; `docs/pm-charter.md` confirmed absent (details §5) |
| C6 | `ls research/canon/lint.sh research/scripts/{search.py,generate.py,ingest.sh}` + `--help` probes | all 4 exist; `generate.py` has **no dry-run mode** (details §6) |
| C7 | `grep -n "Iron Rule\|research_unified_protocol\|1_check_wiki" .claude/skills/alex/SKILL.md` | lines 681/692/700, body-resident with stay-in-body comment (details §7) |
| C8 | `grep -c "^#### File"` + header list + singleton `ls` | 17 headers, highest File 29, 5 singletons all exist (details §8) |

---

## 2. C1 — Tracked exact-string disposition (9 hits, all covered → no new P0/P1)

| Hit | Rev2 coverage | Disposition |
|---|---|---|
| `CLAUDE.md:44` 默认走 NotebookLM | §4.1 File 1, ROW-01, AC1 | ✅ covered |
| `.claude/skills/alex/SKILL.md:397` + `:475` defaults to NotebookLM | §4.2 File 3&4 items 3–4, ROW-02, AC2 | ✅ covered |
| `.agents/skills/alex/SKILL.md:397` + `:475` (mirror) | same File 3&4 + ROW-05 pair 1 | ✅ covered |
| `.claude/skills/blake/SKILL.md:587` + `:598` 1_5b_notebook_check | §4.4 File 17&18, ROW-03, AC4 | ✅ covered |
| `.agents/skills/blake/SKILL.md:587` + `:598` (mirror) | same + ROW-05 pair 8 | ✅ covered |

C2 confirms no untracked file carries the exact stale strings except the handoff itself. **C1/C2: PASS.**

---

## 3. C3 — Paraphrase sweep (601 hits): 9-item §2.2 verified, but sweep leaves active surfaces undispositioned → P1-1 PARTIAL

### 3a. Rev2 §2.2 nine items — existence + plausibility check (all exist; one path defect)

| # | Rev2 claim | Disk reality | Plausibility |
|---|---|---|---|
| 1 | adaptive-complexity-protocol.md:171-195 REGISTRY/notebooklm-cli refresh | exists both mirrors; hits confirmed (8 per mirror) | ✅ plausible (complexity health-sense, not routing) |
| 2 | status-panoramic-protocol.md passive inventory | exists; `REGISTRY.yaml` hits at :17/:56/:63 confirmed | ✅ plausible (reporting, not decision entry) |
| 3 | research-notebook/SKILL.md engine itself | exists both mirrors; 82 hits each (largest holder) | ✅ plausible (Hard Boundary 1 requires preservation) |
| 4 | alex-lite/SKILL.md:408 frozen channel | exists; :408 region mentions `.tad/research-notebooks/` | ✅ plausible (2026-08-13 freeze) |
| 5 | deps-protocol.md:132 notebooklm-cli exempt | exists; :132-area `registry: null … notebooklm-cli` confirmed | ✅ plausible (dependency governance) |
| 6 | `pack-upgrade.workflow.js` | ❌ **path wrong**: no root-level file; actual is **`.claude/workflows/pack-upgrade.workflow.js`** | ⚠️ reason plausible, **path must be corrected** — Blake cannot locate the claimed path |
| 7 | nondev-execution-track.md:290 | exists; :285-295 NotebookLM-stateful producer note confirmed (line number ±5, acceptable) | ✅ plausible-ish (Conductor-side history) |
| 8 | `.tad/capability-packs/academic-research/SKILL.md` install-source template | exists (3 hits) | ✅ plausible (distribution source; active file is mirror pair 11) |
| 9 | research-github SKILL 232-242 Step 6/7 notebook creation retained | exists; Step 6 limit-check + Step 7 `notebooklm create` confirmed | ✅ plausible (cloud fallback retention) |

Text defect: §4.6/P1-6 row says "8 处" while §2.2 enumerates **9** items. Trivial but shows the recount was hand-edited.

### 3b. Paraphrase hits NOT dispositioned either way (the residual P1-1)

| File(s) | Hits | In §2/§4 scope? | In §2.2 o-o-s? | Judgment |
|---|---|---|---|---|
| research-notebook SKILL ×2, alex SKILL ×2, blake SKILL ×2, 6 alex refs ×2, notebooklm-access ×2, research-github SKILL ×2, academic-research SKILL ×2 | bulk | ✅ yes (Files 3–20, 25/26, 28/29) | n/a | covered |
| adaptive/panoramic/lite/deps/pack-upgrade/nondev/cap-pack-SKILL/github-232-242 | ~30 | no | ✅ items 1–9 | covered (modulo #6 path) |
| **`.tad/guides/tool-quick-reference-alex.md` (11 hits: :19-20 registry pointer, :149-160 `*research-notebook` daily-use table)** | 11 | File 21 **partially** — §4.5 specifies External-CLI + Research Commands + L169 only; **no line-anchored rewrite for :149-160 table or :19-20 registry line** | no | ⚠️ **UNCOVERED active routing surface** — the :149-160 table presents notebook-first daily commands with no fallback label; :19-20 mandates registry update after every create |
| **`.tad/cross-model/capabilities.yaml` (:39-63 `*research-notebook` 19-command capability declaration)** | 10 | no | no | ⚠️ **UNCOVERED** — live capability advertisement; at minimum needs explicit o-o-s or File-scope ruling |
| **`.tad/capability-packs/research-methodology/CAPABILITY.md` (:253 strict-superset keyword priority over research-notebook)** | 2 | no | no | ⚠️ **UNCOVERED** — keyword-routing priority claim is routing-relevant |
| `CHANGELOG.md` (10 hits, historical) | 10 | no | no | noise-but-undispositioned; one-line "history, immutable" o-o-s entry would close it |
| `dependency-ops/SKILL.md` ×2 (`.tad/dependencies/REGISTRY.yaml` — different registry, false positive) | 20 | no | no | needs one-line boundary note (distinct REGISTRY namespace) |
| `README.md` (3), `NEXT.md` (1), `.tad/memory/*` (several), hooks/templates/eval-bundles/blake-lite mirrors, `.tad/research-notebooks/REGISTRY.yaml` itself, `.tad/config-workflow.yaml` | ~40 scattered | no | no | mostly noise/history, but "全面排查" claim (§2.2 intro) is over-broad vs 601-hit reality |

**Conclusion C3:** the 9-item list is real progress over Round1, and every item was verified to exist with a plausible reason — but the sweep pattern still returns ~60 files, and at least three **active** routing surfaces (tool-ref-alex :149-160/:19-20, capabilities.yaml, research-methodology pack) have no disposition. The §2.2 intro claim of "全面排查" is therefore not yet earned. → **P1-1 PARTIAL** (closeable with a text-only §2.2 supplement: correct #6 path, fix "8处"→"9处", add ~4 explicit entries).

---

## 4. C4 — Parity table (all 12 ROW-05 pairs IDENTICAL pre-implementation → text FIXED)

| ROW-05 pair | `diff -q` result |
|---|---|
| alex/SKILL.md | IDENTICAL |
| blake/SKILL.md | IDENTICAL |
| alex/references/research-plan-protocol.md | IDENTICAL |
| alex/references/handoff-creation-protocol.md | IDENTICAL |
| alex/references/discuss-path-protocol.md | IDENTICAL |
| alex/references/research-decision-protocol.md | IDENTICAL |
| alex/references/research-review-protocol.md | IDENTICAL |
| alex/references/learn-path-protocol.md | IDENTICAL |
| blake/references/notebooklm-access.md | IDENTICAL |
| capability-upgrade/references/legacy-pack-research.md | IDENTICAL |
| academic-research/SKILL.md | IDENTICAL |
| research-github/SKILL.md | IDENTICAL |

File 27/28/29 split: `.agents/skills/research-github/SKILL.md` ✅ exists; `.tad/capability-packs/academic-research/SKILL.md` ✅ exists; `.tad/capability-packs/academic-research/CAPABILITY.md` ✅ exists. Frontmatter lines 3/11 stale text confirmed on disk verbatim (`create deep-research notebooks`, `then create deep-research NotebookLM notebooks`), matching §4.6 anchors. LOCAL-WIKI SHIM at 189-200 confirmed present. → **P1-2, P1-3 FIXED in text.**

Robustness note (NEW, non-blocking): ROW-05's `… || exit 1` loop **exits at the first divergent pair**, hiding the remaining pairs' status from the Gate log, and `diff -u` dumps full diffs. Recommend `|| FAIL=$((FAIL+1))` accumulation. Advisory only.

---

## 5. C5 — ROW-06 safety judgment (passable, ownership clear, but NEW lifecycle + full-tree notes)

- **Premise verified:** `git status --porcelain docs/pm/` → exactly `M docs/pm/intent.md` + `M docs/pm/now.md` (matches rev2's claim); `docs/pm/` contains acceptance/auth/intent/now/status; `docs/pm-charter.md` confirmed nonexistent. The rev1 false-FAIL trap is genuinely defused by the baseline-relative formulation.
- **Message mandate:** §8 orders baseline capture before first edit; §1.3/§5-AC8/§6-ROW-06/§7 repeat it consistently; ownership is Blake's pre-first-edit step. **Clear enough; passable without reverting the other workstream.**
- **NEW finding N1 — `/tmp/row06.baseline` lifecycle:** `/tmp` on a shared box is ephemeral and session-scoped. If Gate 3 verification runs in a different session/container, the baseline is gone and ROW-06 becomes unexecutable (or worse, Blake re-creates it post-edit, silently re-baselining his own pollution). Recommend a durable carrier alongside `/tmp`, e.g. `.tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline` (tracked or explicitly untracked), with `/tmp` kept only as working copy. Text-only fix.
- **Full-tree context:** `git status --porcelain | wc -l` = **228** (massive pre-existing dirt: mode/content `M` on dozens of skill scripts, plus ~25 untracked handoff/design/epic files). ROW-06's pathspec (`docs/pm/`) correctly scopes the assertion, but the handoff gives Blake **no general pathspec-scoped work discipline** for the other ~226 dirty entries — editor normalization on any `M`-marked script would silently widen his diff. One sentence in §8 ("Blake must constrain all edits/git-ops to the 29 listed files; do not normalize or touch any other dirty path") would close it. Advisory; does not block since ROW-06 itself is sound.
- **Correlated observation:** `research/canon/lint.sh`, `research/scripts/generate.py`, `research/scripts/ingest.sh` themselves show `M` in the full-tree status — pre-existing dirt on the very files inside the READ-ONLY boundary. Harmless for Gate 2 (Blake hasn't started) but Gate 3 needs a stated rule for whether that dirt is someone else's (leave alone).

---

## 6. C6 — `research/` write-scope (strict in §1.3/AC2, re-softened in §8 → PARTIAL)

- Existence: `research/canon/lint.sh`, `research/scripts/search.py`, `research/scripts/generate.py`, `research/scripts/ingest.sh` — **all present**.
- Capability probe: `ingest.sh` supports `--dry-run`; **`generate.py --help` shows only `--emit {all,index,clusters,ammo}` — every invocation writes**. There is no "generate.py in write mode" vs "non-write mode" distinction; the §8 Message's phrasing *"do NOT run ingest.sh or generate.py in write mode"* (§8 line 498) therefore **re-opens the exact ambiguity** §1.3 ("严禁运行任何写入型脚本（如 ingest.sh 或 generate.py）") and AC2 ("严格保持 READ-ONLY，未执行任何写入动作") had closed. A literalist Blake could argue `generate.py --emit index` is "verification."
- **Required text fix (one line):** change §8 item 4 to match §1.3 verbatim — *"research/ is STRICTLY READ-ONLY: run only `research/canon/lint.sh` and `research/scripts/search.py`; do NOT run `ingest.sh` or `generate.py` in any mode."* → **P1-5 PARTIAL** pending that single edit.

---

## 7. C7 — Circular-trigger (PASS)

`grep -n "Iron Rule\|research_unified_protocol\|1_check_wiki" .claude/skills/alex/SKILL.md` → `:681 research_unified_protocol:`, `:692 execution: "local_wiki research: …"`, `:700 Iron Rule (local_wiki): … stays in SKILL body per principles.md:103 (circular trigger — execution discipline must not move to references/)`. Load-bearing triggers remain in the SKILL body with an explicit anti-migration comment; rev2 §4.2 does not relocate any to `references/`. **PASS, no finding.**

---

## 8. C8 — Count reconciliation (PASS with arithmetic confirmed)

`grep -c "^#### File"` = **17 headers**, highest File number **29**. Mapping: 12 pairs (Files 3&4, 5&6, 7&8, 9&10, 11&12, 13&14, 15&16, 17&18, 19&20, 23&24, 25&26, 28&29 = 24 files) + 5 singletons (**File 1 `CLAUDE.md`**, **File 2 `research/CLAUDE.md`**, **File 21 tool-quick-reference-alex**, **File 22 tool-quick-reference-blake**, **File 27 academic CAPABILITY.md** — all five verified on disk). 24+5 = **29** ✅. AC5 lists all 6 Cat-C protocols including learn-path; ROW-08/09/10 cover the previously orphan ACs. → **P1-4 FIXED** (modulo the trivial "8处"/9-item mismatch noted in §3a).

---

## 9. Delta verdicts vs Round1 Leg-2 findings

| Round1 ID | Subject | Rev2 disposition | This reviewer's verdict |
|---|---|---|---|
| P0-1 (=P0-A) | ROW-06 unpassable vs dirty docs/pm/ + phantom pm-charter | baseline-relative ROW-06 + non-existence assertion; both premises verified on disk | **FIXED** (+ NEW N1 `/tmp` lifecycle note) |
| P1-1 | paraphrase sites outside inventory | 9-item §2.2 added, all verified; but 3 active surfaces + history/noise bucket still undispositioned | **PARTIAL** |
| P1-2 | File 27&28 mirror omission | File 27 singleton + 28&29 pair; matches disk incl. line anchors | **FIXED** |
| P1-3 | ROW-05 covered only 2 pairs | 12-pair loop; all pairs identical pre-state | **FIXED** (+ advisory on `‖ exit 1` early-exit) |
| P1-4 | 26-count vs 28 slots | 29 = 24+5 reconciled; singletons verified | **FIXED** (+ trivial 8/9 text mismatch) |
| P1-5 | research/ write-scope ambiguity | strict in §1.3/AC2, but §8 "in write mode" qualifier re-opens it; generate.py has no dry mode | **PARTIAL** (one-line fix) |

**No new blast-radius expansion introduced by rev2** beyond N1 (baseline lifecycle) and the full-tree-dirt discipline advisory. No evidence of load-bearing trigger migration, scope creep into `docs/pm/`, or NotebookLM-fallback deletion (ROW-07 paths `setup-notebooklm.sh`/`REGISTRY.yaml` untouched by the text).

---

## 10. Required text-only changes before PASS (no implementation, Blake still held)

1. **§8 item 4:** replace *"do NOT run ingest.sh or generate.py in write mode"* with the §1.3-strict sentence (C6).
2. **§2.2:** correct item 6 path to `.claude/workflows/pack-upgrade.workflow.js`; fix "8 处"→"9 处"; append explicit entries for: tool-quick-reference-alex :149-160/:19-20 (either extend File 21 spec with line-anchored rewrites or give a reachability exemption), `.tad/cross-model/capabilities.yaml`, `.tad/capability-packs/research-methodology/CAPABILITY.md`, plus a "history/immutable + distinct-registry-namespace" bucket (CHANGELOG, dependency-ops `.tad/dependencies/REGISTRY.yaml`) (C3).
3. **ROW-06 (advisory, recommended):** dual-write baseline to a durable evidence path in addition to `/tmp/row06.baseline` (N1); one sentence constraining Blake's edits/git-ops to the 29 listed files given 228-entry full-tree dirt (C5).

*End of Leg-2 Round2 report. Research only; no files written, edited, or created by the reviewer. Blake not contacted. No implementation performed.*
