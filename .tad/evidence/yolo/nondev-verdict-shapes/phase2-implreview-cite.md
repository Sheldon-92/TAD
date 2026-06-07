# Phase 2 Impl-Review — Citation / Registry / Byte-Identity Verification

> Independent verification (TAD Gate 3, YOLO Y6). All checks run against on-disk
> state, not the author's claims. Date: 2026-06-06.

**Artifact under review:** product-thinking pressure-test rigor rubric +
deliverable-rubrics.yaml registry entry.

---

## Check 1 — CITATION PROVENANCE (load-bearing)

Every quantitative/threshold claim in the rubric was opened against its cited
source and compared verbatim.

### fatal-flaws.md citations — ALL VERIFIED

| Rubric claim | Cited anchor | On-disk reality | Verdict |
|---|---|---|---|
| "Two or more fatal flaws = KILL verdict regardless of other evidence" (rubric L92-93, L235) | fatal-flaws.md **L5** | L5 verbatim: *"…Two or more fatal flaws = KILL verdict regardless of other evidence."* | ✅ EXACT |
| "15 universal killers" / "15+ … (F1–F16)" (rubric L89, L234) | F1–F16 | `grep -cE '^### F[0-9]+:'` = **16** headers (F1…F16) | ✅ — "15" is the section title's own count (`## The 15 Universal Startup Killers`, L18); F16 was appended later. Rubric hedges as "15+ (F1–F16)" and "the 15 killers", consistent with the source's own self-label. Not a fabrication. |
| Usage: scan / mark / include ≤3 (rubric L90-91, L234) | fatal-flaws.md **L9–14** | L9–14 verbatim: How to Use → scan, mark, "Include ≤3 most relevant" | ✅ EXACT |
| Severity rows `2 fatal flaws \| KILL`, `3+ \| KILL` (rubric L94-95) | Severity Guide **L150–155** | L150–155 is the severity table incl. both rows | ✅ EXACT |
| Single high-severity flaw (F9/F13) can KILL alone (rubric L95, L99, L235) | **L157** | L157 verbatim: *"…A single F-level flaw with high severity (F9 legal, F13 negative unit economics) can be a KILL on its own."* | ✅ EXACT |
| F12 alone NOT auto-KILL (rubric L99, L235 "F12 exception L159") | **L159** | L159 verbatim: F12 note — *"…If F12 is the only flaw, the verdict is not automatically KILL…"* | ✅ EXACT |
| "'I'd use that' … costs nothing. It means nothing" (rubric D2 L76) | fatal-flaws.md **F2 L31** | L31 verbatim: *"**Brutal truth**: 'I'd use that' is the polite thing to say… It costs nothing. It means nothing."* | ✅ EXACT |

### pressure-test.md citations — ALL VERIFIED (one off-by-one, P2)

| Rubric claim | Cited anchor | On-disk reality | Verdict |
|---|---|---|---|
| "this probably won't work. You must prove otherwise" (rubric L54, L231) | **L8** | L8 verbatim | ✅ EXACT |
| "6 forcing rounds (Demand…Future-Fit)" (rubric L54-55, L231) | Steps 0–6 | Steps present: Step 0 (L31), Step 1 Demand Reality (L52), Step 2 Status Quo (L90), Step 3 Desperate Specificity (L121), Step 4 Narrowest Wedge (L151), Step 5 Observation (L184), Step 6 Future-Fit (L216). Steps 1–6 = **6 forcing rounds** (Step 0 is type detection, correctly excluded from the count by the rubric). | ✅ EXACT |
| "No round accepts 'I think'…" / every round searches real data (rubric L74-75, L232) | **L10–11** | L10–11 verbatim | ✅ EXACT |
| "Show me behavior, not opinion" (rubric L74, L232) | **L56** | L56 verbatim (Step 1 ask) | ✅ EXACT |
| "Record: FACT or ASSUMPTION based on evidence quality" across 6 rounds (rubric L75, L233) | **L86, L117, L147, L180, L212, L242** | All 6 lines are `**Record:** FACT…ASSUMPTION` lines (L86 has the exact "based on evidence quality" suffix; the other 5 are the per-round Record variants) | ✅ EXACT |
| Per-round `**Then search:**` blocks (rubric D2 L72, "e.g. L59–63, L96–101") | **L59–63, L96–101** | L59–63 = Step 1 search block; L96–101 = Step 2 `**Then search:**` + queries | ✅ EXACT |
| Confidence 1–10 derived from FACT/ASSUMPTION count (rubric L109, D4 L119) | **L256–261** | L256–261 = the confidence ladder (`6 FACTs → 9-10` … `0-1 → 1-3`) | ✅ EXACT |
| 2-Week Validation Plan + explicit Success signal (rubric L110-111, D4 L119) | **L291–295** | L291–295 = "2-Week Validation Plan (type-specific):" … "Success signal: '[What result changes the verdict to BUILD]'" | ✅ EXACT |
| Step 7 verdict (BUILD/PIVOT/KILL) (rubric L107-108, L236) | **L246–303** | Step 7 header L246; output-format fenced block closes at L303 | ✅ EXACT range |
| Step-0 product-type detection → "load the adapter for that type"; adapter gives data sources / Q4 wedge / 2-week meaning (rubric D5 L127-132, L237) | **L31–50** (L43 quote, L45-49 adapter list) | L43 verbatim contains *"load the adapter for that type"*; L45–49 verbatim list the 3 adapter outputs | ✅ EXACT |
| "Refuse category-level answers … demand actual names" — challenge strongest claim, hard position (rubric D1 L57-58, L62-63, L231) | **L14–28** (and "L28/L139") | Anti-sycophancy block: header L14, "The AI MUST" list L22-27, **"Refuse category-level answers ('product managers at mid-market SaaS') — demand actual names" is at L27** (L28 is a blank line). | ⚠️ See P2 below — the cited line **L28** is off by one; the actual bullet is **L27**. The inclusive RANGE "L14–28" still contains it; the TEXT is real and verbatim. |
| "product managers at mid-market SaaS" rejected (rubric L58, L62-63, L139) | **L139** | L139 verbatim (Step 3 pushback: *"'Product managers at mid-market SaaS companies' is not a person…"*) | ✅ EXACT |

### gate SKILL.md citations — ALL VERIFIED

| Rubric claim | Cited anchor | On-disk reality | Verdict |
|---|---|---|---|
| categorical band→verdict mapping `rigorous→PASS · partial→PARTIAL · superficial→FAIL` (rubric L222) | gate SKILL.md **L457** | L457 verbatim: *"rigorous → PASS · partial → PARTIAL · superficial → FAIL"* | ✅ EXACT |
| `judge_prompt_by_shape.categorical` block; rigor independence; order firewall; swap test (rubric L13-16, L238) | **L453–479** | L453 = `# ── verdict_shape: categorical …`; L454 `categorical:`; L463 `decoupling_firewall:`; L476-477 band/content_verdict; runs through L479 | ✅ EXACT range |
| Order firewall: "`band:` (with justification) MUST appear ABOVE `content_verdict:` in the file" (rubric L196-199) | **L479** | L479 verbatim: *"⚠️ `band:` (with justification) MUST appear ABOVE `content_verdict:` in the file (order firewall)."* | ✅ EXACT |

**Verdict on Check 1:** No fabricated, misattributed, or interpolated threshold.
Every quantitative claim ("2+ fatal flaws = KILL", "6 forcing rounds", "15
killers", confidence ladder, ≤3 flaws, severity rows, rigorous→PASS mapping)
traces to verbatim source text at the cited (or, in one case, off-by-one)
location. **No P0.** One P2 line-number nit (below).

---

## Check 2 — BYTE-IDENTITY (handoff AC5)

```
diff .tad/capability-packs/product-thinking/references/pressure-test-rubric.md \
     .claude/skills/product-thinking/references/pressure-test-rubric.md
→ empty (exit 0)
```

The two rubric copies are **byte-identical**. ✅ PASS — AC5 satisfied. No P0.

---

## Check 3 — REGISTRY

**3a. YAML validity.** System `python3` lacks PyYAML (ModuleNotFoundError: No
module named 'yaml'); `uv`/`.venv` likewise unavailable. Validated instead with
Ruby's bundled YAML parser:
```
ruby -ryaml -e "YAML.load_file('.tad/capability-packs/deliverable-rubrics.yaml')"
→ RUBY_YAML_OK
```
The file parses as valid YAML. ✅ PASS.

**3b. product-thinking row.**
- `rubric_ref: ".claude/skills/product-thinking/references/pressure-test-rubric.md"` — non-null **and the target file EXISTS** (`ls` → 15984 bytes, mtime Jun 6 23:42). ✅
- `verdict_shape: categorical` ✅
- `status: active` ✅
- `pass_threshold: null` / `partial_threshold: null` — correct for a categorical (rigor-band) rubric, consistent with the rubric's own §B band tree. ✅

**3c. No other pack row's values changed vs git.**
`git diff` hunk begins at the `product-thinking:` row. Independent confirmation:
```
diff <(git show HEAD:…deliverable-rubrics.yaml | sed -n '1,45p') <(sed -n '1,45p' …)
→ LINES_1-45_IDENTICAL
```
Lines 1–45 (file header + **academic-research**, **ai-voice-production**,
**video-creation** rows) are **byte-identical to HEAD** — untouched. ✅

**Note on ai-podcast-production:** the task brief listed "ai-podcast" among rows
that "must be untouched," but `git show HEAD` proves the row **did not exist in
HEAD** (HEAD has 4 packs; working tree has 5). The diff adds it wholesale as a
new `active`/`weighted` row (rubric_ref →
`.tad/capability-packs/ai-podcast-production/podcast-quality-rubric.md`). This is
an ADDITION, not a mutation of a pre-existing row, and matches the untracked
`.tad/capability-packs/ai-podcast-production/` + `.claude/skills/ai-podcast-production/`
dirs in `git status`. No existing-row value was altered. Flagged P2 for the
reviewer's awareness only — it does not violate "other rows untouched" (no other
row was modified).

✅ PASS.

---

## Check 4 — SCOPE (`git status --porcelain`)

All changes fall into the expected envelope (rubric files + registry + this
pack's evidence/handoff/epic, plus pre-existing unrelated working-tree churn that
predates this handoff per the start-of-session git status):

Directly attributable to this Phase-2 work:
- ` M .tad/capability-packs/deliverable-rubrics.yaml`  (registry — expected)
- `?? .tad/capability-packs/product-thinking/references/`  (rubric source — expected)
- `?? .claude/skills/product-thinking/references/`  (rubric installed copy — expected)
- `?? .tad/active/handoffs/HANDOFF-20260606-nondev-verdict-shapes-p2.md`  (handoff — expected)
- `?? .tad/evidence/yolo/nondev-verdict-shapes/phase2-impl-blake.md`  (evidence — expected)
- `?? .tad/evidence/decisions/2026-06-06.jsonl`, `?? .tad/evidence/traces/2026-06-06.jsonl`  (today's evidence — expected)

Pre-existing / sibling-work churn (already present in the session-start git
status, NOT introduced by this rubric change): `pack-registry.yaml`,
`_index.md`, `pack-build-rules.md`, REGISTRY.yaml, the ai-podcast-production
pack dirs + skill, 2026-06-03/04/05 evidence, PROPOSAL-*, litellm research,
archive epics/handoffs.

**No unexpected source-code or framework files touched.** ✅ PASS.

---

## Findings Summary

### P0 — none
No fabricated/misattributed citation; rubric copies byte-identical; YAML valid;
rubric_ref target exists; no other pack row mutated.

### P1 — none

### P2 (advisory, non-blocking)
- **P2-1 (citation line-number off-by-one):** The rubric cites the
  "Refuse category-level answers … demand actual names" bullet as **L28** of
  pressure-test.md (rubric D1 L58 "rejected at L28/L139"; Source-Citations table
  L231 range "L14–28"). On disk that bullet is at **L27**; L28 is a blank line.
  The quoted TEXT is verbatim-present and the inclusive range L14–28 still
  contains it, so this is a cosmetic anchor drift, not a fabrication. Suggest
  changing "L28" → "L27" in D1 (rubric L58, L62-63) for byte-precise provenance.
- **P2-2 (brief-vs-reality on ai-podcast row):** the verification brief implied
  ai-podcast-production was a pre-existing row to leave untouched; it is in fact
  a NEW row added by this/sibling work (absent from HEAD). No existing row was
  changed. Informational only.

---

## Overall: PASS

Citation provenance is sound (no interpolated thresholds), byte-identity holds,
the registry is valid YAML with a correct active categorical product-thinking
entry pointing to an existing rubric, all sibling pack rows are byte-identical to
HEAD, and scope is contained. The single P2 line-number nit (L28→L27) is a
one-character cosmetic fix and does not block the gate.
