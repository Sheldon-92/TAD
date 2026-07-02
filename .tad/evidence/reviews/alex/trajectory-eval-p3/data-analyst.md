---
reviewer: data-analyst
handoff: HANDOFF-20260702-trajectory-eval-p3.md
scope: §1.2, §2.1, §4.2C, §4.4, §9.1 AC5, §10.2
date: 2026-07-02
focus: measurement-methodology validity of the gate-roi-report.sh contract
---

# Data Analyst Review — Trajectory Eval P3

## 1. Critical Issues (P0)

### P0-1: gate4_delta is a CATCH, not an escape — its placement under "Escaped post-ship" inverts its meaning for the strategic decision

**Location**: §4.2C section 3 ("Escaped post-ship"), §4.4

**What the spec says**: "Escaped post-ship" has two sub-items — (a) bugfix-prefix handoffs and (b) non-empty gate4_delta entries. The doc notes both are "deliberately not summed" because the definitions differ. §4.4 repeats this framing.

**What gate4_delta actually records**: From §2.1 and the handoff frontmatter, gate4_delta captures "Alex prediction vs Gate 4 reality" gaps. These are discrepancies CAUGHT BY Gate 4 — the gate worked, it found something. This is the opposite of a post-ship escape. A non-empty gate4_delta is evidence that Gate 4 provided value, not evidence of a defect that got through.

**Why this matters for the strategic decision**: The ROI report feeds the "mechanical enforcement positioning" decision (§1.2). That decision requires distinguishing:
- "Gates catch things" (argues for enforcement) — gate4_delta belongs here
- "Things slip past gates" (also argues for enforcement, differently) — bugfix-prefix handoffs belong here

By housing gate4_delta under the "escape" section — even with a "not summed" disclaimer — the report trains any reader who scans section headers to associate Gate 4 delta with failure rather than with catch. A decision-maker reading the executive summary will read "Escaped: 6 bugfix handoffs + 7 gate4_delta" and conclude gates leak more than they catch. The opposite conclusion is warranted.

**Required fix**: Move gate4_delta to the "Caught pre-ship" section as a distinct sub-item labeled "Late catches at Gate 4 (gate4_delta non-empty)." Alternatively, create a standalone "Gate 4 efficacy" sub-section. The separation from bugfix-prefix counts is correct; the parent section heading is wrong.

---

### P0-2: No denominator requirement — raw counts are uninterpretable for the enforcement decision

**Location**: §4.2C, §9.1 AC5

**What the spec requires**: AC5 checks `exit=0 + ≥4 sections + each section contains a "compound command" line + empty window does not crash`. There is no requirement that the report compute or state rates.

**The problem**: The data in §2.1 gives: 50 gate_result events, 6 bugfix-prefix handoffs, 7 non-empty gate4_delta entries. These raw counts are uninterpretable without a denominator.

- "6 escapes" over 6 total handoffs accepted = 100% escape rate → mechanical enforcement is urgent.
- "6 escapes" over 120 total handoffs accepted = 5% escape rate → acceptable under advisory regime.

The report currently cannot distinguish these cases because it never computes total accepted handoffs in the window. The same problem applies to the "Caught pre-ship" count: is "50 file×level catches" across 6 reviews or 50 reviews?

**For the enforcement decision, rates are load-bearing, not decoration.** A report that delivers raw counts to a strategic decision without normalization can actively mislead.

**Required fix**: AC5 must require two additional outputs:
1. Total handoffs accepted in the window (derivable from archive slug count filtered by date).
2. Escape rate = (a) count / total accepted handoffs, reported as a fraction with the denominator stated explicitly (e.g., "6 / 42 = 14.3%").

The "compound command" (复算命令) line already exists for re-derivation; rates need to be first-class outputs, not optional derivations.

---

## 2. Recommendations (P1)

### P1-1: per-file-per-level dedup collapses finding density — direction of bias works against the ROI narrative, no caveat required

**Location**: §4.2C section 2 ("Caught pre-ship")

**The dedup rule**: `grep -oE 'P0|P1'` per reviewer file, then "each file×level counts once." A review with 5 P0 findings and a review with 1 P0 finding both contribute exactly 1 to the P0 count.

**Bias direction**: This undervalues high-density reviews. If the actual distribution is "most review files have 1-2 findings" then the undercount is modest; if "many reviews have 3-5 findings per level" then the undercount is severe. The direction of bias works AGAINST the strategic narrative (makes gates look less productive than they are), which is conservative but not neutral.

**Is finding-level count feasible?** The handoff references "P0-1/P0-2 numbering conventions" in the focus brief. If review files consistently use structured numbering (e.g., `P0-1`, `P0-2`, `P1-1`), then `grep -oE 'P[01]-[0-9]+'` would count discrete findings rather than file×level presence. This is more accurate and feasible if the convention is consistent.

**Required action (two options, one must be chosen)**:
- Option A: Audit whether the P0-N/P1-N numbering convention is consistent in `.tad/evidence/reviews/**/*.md`. If yes, switch to finding-level grep and update the AC5 verification command accordingly.
- Option B: Retain per-file-per-level dedup but add a mandatory footnote to the "Caught" section output: "Count = files×levels with at least one finding; reviews with multiple findings per severity level are counted once per file×level. This is a structural lower bound."

Without one of these, the count is presented as if it means "N issues caught" when it means "N file×level combinations had at least one issue."

---

### P1-2: Escape count has no explicit lower-bound caveat required in the report output

**Location**: §4.2C section 3, §9.1 AC5

**The survivorship gap**: bugfix-prefix detection only surfaces escapes that resulted in a filed handoff with a `bugfix-` or `fix-` prefix. Escapes that were fixed inline (no handoff filed), fixed in a subsequent feature handoff without the prefix, or silently absorbed into a later refactor are completely invisible to this method.

The §2.1 data confirms 6 bugfix-prefix handoffs in the window. The actual number of escaped defects could be 2x-5x higher. This is not a methodology flaw unique to this spec — it is inherent to any handoff-based escape detection — but the report consumer must know this.

**The strategic risk**: If the decision-maker reads "6 escapes in 30 days" and treats it as an accurate count, the enforcement decision is based on an undercount of unknown magnitude. If the true escape rate is 3x higher, the enforcement case is much stronger.

**Required fix**: AC5 must verify that the "Escaped" section output contains a literal caveat string, e.g., `grep 'lower bound\|silent fix\|lower-bound' .tad/evidence/eval/gate-roi-*.md`. The caveat must be in the rendered report, not just in the script comments.

---

### P1-3: Judge trend at n=3-10 — per-dim mean is false precision; raw trajectory rows are more honest

**Location**: §4.2C section 4 ("Judge score trend")

**The spec**: n < 3 → "insufficient data" message. Implied: n ≥ 3 → per-dimension mean table.

**The problem at n=3-10**: At n=3, a per-dim mean is `(score_A + score_B + score_C) / 3`. One atypical trajectory (e.g., a very short handoff that the judge scores low on D3-scope) shifts all five dimension means. The mean communicates false precision — it implies a stable estimate when the sample is dominated by individual variation.

Reporting raw per-trajectory rows at n=3-10 is more informative and more honest:
- The decision-maker sees the actual distribution (3-10 data points is scannable).
- Outliers are visible rather than averaged away.
- No false signal from a mean that is sensitive to single observations.

**Required fix**: Add a second threshold to the guard:
- n < 3: "insufficient data (n={N}) — accumulating"
- 3 ≤ n < 10: Report per-trajectory rows (slug, date, D1-D5 scores) with note "raw trajectories (n={N}; mean reported at n≥10)"
- n ≥ 10: Per-dim mean table (current intended behavior)

This costs one additional branch in the script and produces more useful output during the months when data is thin.

---

## 3. Suggestions (P2)

### P2-1: The ONE missing statistic for the enforcement decision — gate-stage attribution of catches

**Location**: §4.2C, §10.2

**What the report answers**: "Do gates catch things?" (yes/no + count).

**What the enforcement decision actually needs**: "Which gates, at what stage, catch the most?" This is gate-stage attribution.

The enforcement decision is not binary (enforce everything or nothing). Enforcement is targeted: "enforce Gate 1 mechanically because it has the highest catch rate" or "enforce Gate 3 because most P0s are found there." Without knowing which gate catches what, the decision defaults to "enforce all or none," which is a blunter instrument than the data can support.

**Concrete implementation**: The `gate_result` trace events in §2.1 (50 events, 6-7 months) already contain gate identity. A fifth section — "Catch attribution by gate" — that cross-references gate_result events with the review-file P0/P1 catch counts (matched by date-slug overlap) would give this. Even a rough approximation (which gates were running when catches were made) closes the gap.

This is the single addition that would most increase the report's fitness for its stated purpose.

---

### P2-2: "handoff §9.2 Audit Trail 행수" in "Caught" section is a proxy metric of unclear validity

**Location**: §4.2C section 2, second sub-item

**The spec adds**: "窗口内 handoff §9.2 Audit Trail 行数（archive 中按文件日期过滤）" to the "Caught pre-ship" count.

**The problem**: §9.2 Audit Trail line count measures how much review activity was recorded, not how many issues were found. A handoff with 10 audit trail lines (one per expert comment back-and-forth) has the same weight as a handoff with 1 line (a single "PASS"). This metric does not measure catches; it measures protocol activity. Mixing it with the P0/P1 grep count without a clear label creates an apples-and-oranges sum.

**Suggested fix**: Either (a) drop this sub-item from the "Caught" section and keep only the P0/P1 file×level count, or (b) report it as a separate "Protocol activity" metric (Audit Trail lines = evidence that review process ran) rather than a sub-item of "Caught pre-ship." The current presentation implies it is a catch count.

---

## 4. Overall Assessment

**CONDITIONAL PASS**

The overall architecture is sound: advisory judge framing (§4.2A, §10.2), active-first bundle resolution (§4.2B), SAFETY line-set discipline (AC3), and the anti-Goodhart constraint (AC8) are all correctly specified. The "not summed" separation of bugfix-prefix vs gate4_delta shows methodological awareness.

However, two P0 issues must be resolved before Blake implements:

1. **P0-1** (gate4_delta misclassification) is the most serious: it structurally inverts a key data point, making Gate 4 catches appear as escapes. A decision-maker reading the report as-is would underestimate gate value and overestimate the escape rate. Fix: reclassify gate4_delta under "Caught pre-ship" as "Late catches at Gate 4."

2. **P0-2** (no denominator) makes all counts uninterpretable for rate-based reasoning. Fix: require total-accepted-handoffs denominator and escape rate as mandatory report outputs; verify in AC5.

The P1 items (per-file-per-level bias caveat, escape lower-bound caveat, n<10 raw rows) are not blocking but materially improve report validity for any reader who will use the numbers to inform a decision.

The P2 gate-stage attribution suggestion is the highest-leverage enhancement if scope allows: it converts the report from "do gates work?" to "which gates, enforce when?" — the question the enforcement decision actually requires.
