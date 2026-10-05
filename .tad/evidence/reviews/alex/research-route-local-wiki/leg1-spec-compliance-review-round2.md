# Gate 2 Round2 Leg-1 Spec-Compliance Review (rev2 delta re-review)

**Design under review:** `.tad/active/handoffs/HANDOFF-20260908-research-route-local-wiki.md` rev2 (Version 2.0, Ready-for-Gate2-rereview)
**Lens:** DESIGN COMPLETENESS + SPEC VERIFIABILITY (not code style, not implementation)
**Pattern basis:** `.tad/project-knowledge/patterns/gate-design.md` §"Claims Need Carriers": every completion/review claim needs an on-disk carrier + existence AC; smoke alarms must fail CLOSED on zero carriers. This review's carrier is its own verbatim persisted output.
**Independence statement:** No knowledge of the Leg-2 Round2 reviewer; all evidence below was re-derived by running the commands myself on 2026-09-08.
**Harness:** OpenCode (charter §3.7 compliant — Gate 2 dual-review executed inside OpenCode, not Cursor).
**Provenance:** Independent subagent session `ses_f7d89b6a6ffe0Rnrd8FPeEIm6j`, output persisted verbatim by Alex. Judge ≠ producer (reviewer did not author the handoff).

---

## Verdict

**CONDITIONAL** (all E1–E7 re-derived; P0-B + P1-1/2/3/4/5/7/8 FIXED; P0-A PARTIAL with one runnable remainder; P1-6 PARTIAL count typo)

---

## 1. Verbatim E1–E7 Command Outputs (re-derived on disk 2026-09-08)

### E1 — stale-pointer existence (create-gate baseline, pre-implementation)

`grep -n "默认走 NotebookLM" CLAUDE.md` → line 44 hit (Handoff §4.1 quote accurate).

`grep -n "defaults to NotebookLM" .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` → 4 hits (L397+L475 × 2 mirrors).

`grep -n "1_5b_notebook_check\|1_5b_research_check" .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md` → `1_5b_notebook_check` at L587/598 × 2 mirrors; `1_5b_research_check` 0 hits (correct pre-impl state for a create-gate).

Supplement: `sed -n '115p'` = `Without this file, Alex cannot invoke NotebookLM, Codex, Gemini, or research commands.` ✓; `sed -n '680,712p'` shows `research_unified_protocol: description: "Unified research entry — Quick/Standard/Deep, defaults to Standard (NotebookLM)"` + `preflight: check: "test -x ~/.tad-notebooklm-venv/bin/notebooklm"` (NotebookLM-only preflight ✓); `sed -n '748,762p'` shows `1_find_notebook:` reading REGISTRY.yaml ✓; `sed -n '280,296p'` shows Step 3.8 reading only REGISTRY.yaml ✓. **Rev2 §4 line anchors (§4.1–4.4) all accurate** within ±2 lines (L682 wording is "defaults to Standard (NotebookLM)" not "defaults to NotebookLM" — substantively identical, immaterial).

### E2 — SSOT tiers vs config

`grep -A5 "fallback_chains" .tad/config-workflow.yaml` → canonical block at lines 788-791:

```
    research:
      primary: local_wiki
      secondary: notebooklm_research  # fallback when local_wiki unavailable
      tertiary: claude_websearch
```

Rev2 §3.1 (Primary local_wiki / Secondary notebooklm_research / Tertiary claude_websearch) **matches byte-for-byte** ✓.

### E3 — 12-pair parity baseline (pre-impl)

All 12 `diff -q` exit 0: alex/SKILL.md, blake/SKILL.md, alex/references/research-plan-protocol.md, handoff-creation-protocol.md, discuss-path-protocol.md, research-decision-protocol.md, research-review-protocol.md, learn-path-protocol.md, blake/references/notebooklm-access.md, capability-upgrade/references/legacy-pack-research.md, academic-research/SKILL.md, research-github/SKILL.md. Rev2 ROW-05 loop re-executed verbatim → `LOOP_EXIT:0` ✓.

### E4 — ROW-06 P0-A fix check

```
$ git status --porcelain docs/pm/
 M docs/pm/intent.md
 M docs/pm/now.md
$ ls docs/pm-charter.md → No such file or directory (EXIT:2)
$ ls docs/pm/ → acceptance.md auth.md intent.md now.md status.md
$ ls -la /tmp/row06.baseline → No such file or directory
$ git status --porcelain docs/pm/ | diff -u /tmp/row06.baseline - → diff: /tmp/row06.baseline: No such file or directory (EXIT:2)
$ test ! -e docs/pm-charter.md → EXIT:0
```

Rev2's dirty-file claim (`M intent.md` + `M now.md`) and absence claim verified ✓. But ROW-06 **as written is unrunnable at Gate-2/3 review time** (exit 2, not 0/1) until Blake creates the baseline.

### E5 — spot checks

`grep -rn "NotebookLM" .tad/guides/` → 3 files: nondev-execution-track.md:290, tool-quick-reference-blake.md:56, tool-quick-reference-alex.md:6 + :169 (`| *research-github notebook <domain> | Create NotebookLM notebook from registry entries | Deep study |`).

research-github SKILL.md frontmatter lines 3/11 staleness claims VERIFIED ✓ (`description: …create deep-research notebooks…`, `then create deep-research NotebookLM notebooks`).

`grep -n "Local Wiki" .claude/skills/alex/references/learn-path-protocol.md` → no output (EXIT:1) → 0 hits pre-impl = correct create-gate; ROW-08 will flip to hits post-impl ✓.

`grep -c "^#### File"` on handoff → 17 headers covering 29 files via pairing; arithmetic 12×2+5=29 holds; automation must count files not headers.

`sed -n '165,172p' .tad/guides/tool-quick-reference-alex.md` → rev2 File-21 old-text quote accurate ✓.

### E6 — fallback preservation

`test -f .tad/cross-model/setup-notebooklm.sh && test -f .tad/research-notebooks/REGISTRY.yaml` → EXIT:0 (both EXIST). ROW-07 runnable, passes ✓.

### E7 — AGENTS.md + research/CLAUDE.md

`grep -n "NotebookLM" AGENTS.md` → no output (0 hits) → AC1 "AGENTS.md 0-hit" clarification VERIFIED ✓.

`grep -n "Primary.*local_wiki\|fallback only" research/CLAUDE.md` → line 41 hit (`Primary: local_wiki. NotebookLM is **fallback only**…`) → rev2 File-2 "Line 41" anchor EXACT ✓.

`ls research/canon/lint.sh research/scripts/search.py research/scripts/generate.py` → all exist, EXIT:0 ✓.

---

## 2. Delta Verdicts (P0-A, P0-B, P1-1..P1-8)

| ID | Verdict | One-line evidence |
|---|---|---|
| **P0-A** | **PARTIAL** | Baseline-relative logic correct + `docs/pm-charter.md` absence verified, but ROW-06 exits 2 pre-Blake (`/tmp/row06.baseline` nonexistent) with no inline creation step and ephemeral `/tmp` path — not Gate-3 runnable as written. |
| **P0-B** | **FIXED** | AC5 names all 6 protocols incl. `learn-path-protocol.md` Step 3_5; ROW-08 dual-mirror `grep -n "Local Wiki"` exists and is syntactically runnable (0 hits now = correct create-gate). |
| **P1-1** | **FIXED** | 29 = 12 pairs (24) + 5 singletons (CLAUDE.md, research/CLAUDE.md, tool-quick-ref-alex, tool-quick-ref-blake, CAPABILITY.md — all `ls`-verified); §2/§4/§5/§8 consistent. |
| **P1-2** | **FIXED** | File 27 singleton (CAPABILITY.md) + File 28&29 research-github pair split correct; `.agents/skills/research-github/SKILL.md` exists; frontmatter lines 3/11 verified; `.tad/capability-packs/academic-research/SKILL.md` dispositioned as out-of-scope item 8. |
| **P1-3** | **FIXED** | ROW-05 loop lists exactly 12 paths; re-executed verbatim → exit 0. |
| **P1-4** | **FIXED** | `grep -n "NotebookLM" AGENTS.md` = 0 hits verified; AC1 now asserts maintain-0-hits (testable negative). |
| **P1-5** | **FIXED** | File 21 line-169 old text quoted byte-accurately; explicit new-row spec present. |
| **P1-6** | **PARTIAL** | §2.2 out-of-scope list exists with reachability rationale, but text says "8 处" while body numbers **9 items** (1–9) — count typo; coverage itself adequate per this lens. |
| **P1-7** | **FIXED** | STRICTLY READ-ONLY scoping sentences present in §1.3, §4.2 note, AC2, §8 message; `ingest.sh`/`generate.py` explicitly carved as future-agent protocol, not Blake execution. |
| **P1-8** | **FIXED** | ROW-04b (Blake quick-ref), ROW-09 (`canon_count` scan), ROW-10 (`primary: Local Wiki` + `1_check_wiki` positive) all present and syntactically runnable; pre-impl 0-hits are expected create-gate baselines. |

---

## 3. Findings

**P0-1 (remainder of P0-A, blocking Gate 3 execution):** ROW-06 `git status --porcelain docs/pm/ | diff -u /tmp/row06.baseline - && test ! -e docs/pm-charter.md` cannot pass until `/tmp/row06.baseline` exists, and `/tmp` is ephemeral (reboot clears it; per-machine). §7/§8 do order Blake to record the baseline before first edit, but ROW-06 itself contains no creation step, no `test -f` guard, and no durable path. **Required fix (text-only, no impl):** inline the creation as ROW-06 step 0 (`git status --porcelain docs/pm/ > /tmp/row06.baseline` before first edit) **and** either add a persistent copy (e.g. `.tad/evidence/reviews/.../row06.baseline.<timestamp>`) or a reviewer guard (`test -f /tmp/row06.baseline || (echo MISSING-BASELINE; exit 2)`). Until then AC8 is only conditionally testable.

**P1-1 (P1-6 count typo):** §2.2 heading/body and delta table say "8 处" but list 9 numbered exclusions. Fix: change "8" → "9".

**P2-1 (automation note, non-blocking):** `grep -c "^#### File"` = 17, not 29 — 29 is the file count after expanding pairs. Gate-3 automation must count files (12×2+5), not headers. Suggest one clarifying parenthetical in §8 scope line.

**P2-2 (stale line anchors, non-blocking):** Rev2 §4.6 cites `academic-research/SKILL.md` lines 159/162/167; actual `NotebookLM` hits are now at lines 175/178/183 (file drifted). Content claim is correct; Blake should locate by `grep`, not absolute line numbers. Suggest "Line ~159–167" or grep-anchored wording.

**P2-3 (E1 wording nit, non-blocking):** Rev2 §4 says alex SKILL L682 "宣称 `defaults to NotebookLM`"; actual L682 is `defaults to Standard (NotebookLM)`. Substantively identical; no fix required beyond optional exact-quote.

---

## 4. AC-by-AC Testability Table

| AC | Testable? | ROW mapping | Pre-impl baseline observed |
|---|---|---|---|
| AC1 Root Docs | ✅ Yes | ROW-01 + AGENTS.md 0-hit assert | PASSABLE |
| AC2 Alex Skill Primary | ✅ Yes | ROW-02 + ROW-09 + ROW-10 + research/ READ-ONLY | PASSABLE |
| AC3 Step 3.8 scan | ✅ Yes | ROW-09 (currently 0 ✓ create-gate) | PASSABLE |
| AC4 Blake 1_5b | ✅ Yes | ROW-03 (currently 0, old pointer at 587/598 ✓ dirty) | PASSABLE |
| AC5 6 protocols | ✅ Yes | ROW-08 (currently 0 ✓ create-gate) | PASSABLE |
| AC6 Tool quick-refs | ✅ Yes | ROW-04 + ROW-04b (currently 0 ✓ create-gate) | PASSABLE |
| AC7 12-pair parity | ✅ Yes | ROW-05 loop exit 0 (all-SAME ✓) | PASSABLE |
| AC8 Fallback & charter | ⚠️ CONDITIONAL | ROW-07 exit 0 ✓; ROW-06 exit 2 pre-baseline (needs P0-1 fix) | PASSABLE only after baseline fix |

---

## 5. Bottom Line

Rev2 genuinely fixes the Round1 substance: every stale pointer re-derived on disk, SSOT matches byte-for-byte, all 12 mirrors parity-clean, counts reconcile to 29, learn-path restored, READ-ONLY scoping explicit, and all new ROWs syntactically runnable. The single blocking remainder per this lens is **ROW-06 operability** (missing baseline + `/tmp` volatility), plus the trivial "8 vs 9" count typo. Fix those two text items and this handoff is **PASS**-ready per this lens; as written it is **CONDITIONAL**.

*Research only; no files written, edited, or created by the reviewer. Blake not contacted. No implementation performed.*
