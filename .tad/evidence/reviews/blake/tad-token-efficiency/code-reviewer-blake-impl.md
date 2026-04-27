# Code Reviewer — Blake Impl Review (post-implementation)

**Reviewer**: code-reviewer
**Reviewed**: 2026-04-27
**Handoff**: HANDOFF-20260427-tad-token-efficiency.md
**Slug**: tad-token-efficiency
**Verdict**: PASS

---

## P0 findings

**None.** All five handoff-specified P0 risk areas verified clean:

1. **YAML structural integrity (rule: | block)** — Blake correctly used 10-space indent for the appended tier-mapping comments inside `rule: |` (lines 927-932 in blake/SKILL.md). The handoff text said "11 spaces" but the actual surrounding `rule: |` content (lines 920-926) is at **10 spaces**, with sub-bullet continuation lines at 12 spaces. Blake matched the actual file rather than the handoff's mistaken spec value — this is correct behavior. Synthesized YAML parse test of the full block (`yaml.safe_load` over an isolated mock containing the new comments) parses cleanly; rule string ends with the final "*express exception" comment, all six tier-mapping lines included as part of the literal block. The handoff's specified "11-space" was off-by-one in its own indent-counting; Blake's choice preserves block scalar integrity.

2. **Constraint-字样 byte-preservation (NFR2 / AC11)** — `grep -c "MANDATORY\|VIOLATION\|forbidden"` returns alex=64 + blake=32 = **96**, exactly equal to the baseline. No constraint-rule字样 was deleted during prose edits.

3. **AR-001 mechanical anchor (NFR3 / AC10)** — `awk '/^express_path_protocol:/{flag=1;n=0;print;next} flag && n<50 {print; n++}' alex/SKILL.md | grep -c 'expert review.*code-reviewer'` returns **= 2** as required. The two anchor lines are at 962 (required_steps comment) and 967 (step2 prose). Neither was disturbed by L4 file_count_max edit.

4. **step4c Interpret tier-aware branching preserves exit 0 semantics** (alex/SKILL.md L2347-2366) — Blake correctly split the original "exit 0 → ✅ verified" into two sub-branches: (a) `exit 0 AND DISTINCT_COUNT ≥ tier_threshold → PASS message`, (b) `exit 0 AND DISTINCT_COUNT < tier_threshold → VISIBLE WARN ("LAYER 2 TIER UNDER-MET")`. The exit 1 / exit 2 cases are byte-preserved in their existing form. Crucially, the WARN branch does NOT block — it inserts a visible warning into the acceptance report and continues. This is consistent with the smoke-alarm philosophy declared at step4c top (`blocking: false` line 2374). No silent failure-mode masking introduced.

5. **step 3.5 indent alignment** — step 3.5 numbered marker is at **6 spaces** (alex/SKILL.md L2331), matching the surrounding numbered steps `3.` (L2327) and `4.` (L2347). Sub-bullet body content at 11/13 spaces matches the existing `3.` body indent style. No indent regression.

**L2 lazy-load step 8+ renumbering** — Verified clean. The new sequence is steps 1-7 (lazy-load reorder) + 8-12 (preserved keyword-matching + stale-check). Internal references in steps 8 and 11 correctly point at `step 4` (matched-files reading) and `step 1` (keyword identification) / `step 3` (category match) — these are the NEW step numbers, not orphan references to old positions. Cross-reference integrity verified.

---

## P1 findings

### P1-1: AC16 enumeration symmetry — INTENT-PASS-LITERAL-FAIL (acceptable per recurring pattern)

- **Cite**: blake/SKILL.md L929 vs alex/SKILL.md L2338
- **Problem**: The handoff's literal AC16 diff command (`diff <(awk ...| sort) <(awk ...| sort)`) returns non-empty output:
  ```
  1c1,2
  <           # Tier 2 (≥1 distinct, code-reviewer): task_type=yaml OR task_type=research OR task_type=doc-only
  ---
  >            - TASK_TYPE = `yaml` OR `research` OR `doc-only` → tier_threshold=1, tier_name="Tier 2"
  >       ```yaml
  ```
  The two prose forms are stylistically different (Blake = comment with `task_type=` prefix; Alex = list bullet with `TASK_TYPE =` prefix and trailing `tier_threshold=` annotation). Plus a phantom `\`\`\`yaml` extra line picked up by Alex's awk because `tier_threshold=1` appears later in `(≥1 expert per existing exception)`.
- **Set-equality verification (intent-level)**: Both sides enumerate exactly `{yaml, research, doc-only}`. The semantic enumeration IS symmetric; only literal text differs. This is the same INTENT-PASS-LITERAL-FAIL pattern caught in the precedent KA "AC Verification Drift Pattern Recurring 4 Phases in a Row - 2026-04-27" — Phase 6/7 already documented this gray zone.
- **Recommendation**: Accept as INTENT-PASS-LITERAL-FAIL with explicit caveat in completion report (per honest_partial_protocol pattern). Phase-future Epic to operationalize per-AC dry-run during handoff drafting (per the standing 4-phases-in-a-row architecture KA). No fix needed for THIS handoff — the semantic enumeration is correct.

### P1-2: DISTINCT_COUNT field name reference is GROUNDED (no fix needed)

- **Cite**: alex/SKILL.md L2329 + L2348-2349 reference `DISTINCT_COUNT`
- **Verification**: Inspected `.tad/hooks/lib/layer2-audit.sh` — the script emits `printf 'DISTINCT_COUNT=%d\n' "$distinct_count"` at line 85 (machine-readable structured output to stdout, not stderr as the handoff text claims). Note: the SKILL prose at L2329 says "DISTINCT_COUNT field appears in stderr summary" — this is technically inaccurate (the field is on stdout per `printf` not `printf >&2`), but the field name itself is correct and grounded.
- **Recommendation (advisory P2, not blocking)**: Future Phase could correct `stderr summary` → `stdout structured output` in step4c step 3 prose for accuracy. Not blocking — Alex Gate 4 readers will find the field regardless of which stream the SKILL claims.

### P1-3: step 3.5 awk shell quoting / glob safety — SAFE under expected execution model

- **Cite**: alex/SKILL.md L2332-2335
- **Concern raised**: Does the `${slug}` expansion in `.tad/active/handoffs/HANDOFF-*-${slug}.md` glob risk shell injection or unintended glob expansion?
- **Analysis**: `${slug}` originates from regex capture group `^(HANDOFF|COMPLETION)-\d{8}-([a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_])\.md$` (step4c step 1, L2317) — the whitelist is identical to layer2-audit.sh's strict whitelist (line 103 of the script). The slug regex disallows shell metacharacters (`$`, `\``, `;`, `|`, `&`, spaces, quotes). The remaining glob `*` is intentional (matches the date portion). No injection vector.
- **Verdict**: SAFE. No fix needed.

### P1-4: L2 lazy-load silent quality loss path — MITIGATED by inclusivity rule

- **Cite**: alex/SKILL.md L1679-1695 (steps 8-11)
- **Concern**: Cross-cutting handoff (e.g., security + performance) where Alex's keyword identification step 1 misses a category — does step 11 ("if keyword identification feels under-coverage, EXPAND step 3 category match") actually save it, or is it decoration?
- **Analysis**: Step 11 has TWO defenses: (a) BA-P1-3 "false positives acceptable, false negatives are not" prose remains intact (L1693), instructing inclusive matching; (b) the explicit fallback "EXPAND step 3 category match (e.g., add architecture.md as broad fallback)" gives Alex a concrete remediation path. Combined with step 3's "Default include: architecture.md" (L1668-1669), the floor is `architecture.md always read`. The worst-case quality loss is bounded — Alex would miss e.g. `security.md` for a security-adjacent task, but architecture.md (where most cross-cutting entries land per L1669) would catch most. This is a bounded inclusive-by-default design.
- **Verdict**: Acceptable. Not perfect (true cross-cutting could still miss security-specific entries), but the existing inclusive-match prose + architecture.md default + EXPAND fallback together make this a reasonable token/quality tradeoff.

### P1-5: L4 widening implicit defense impact — VERIFIED no other gating point

- **Cite**: alex/SKILL.md L949 + L996
- **Concern**: Does ">5 files" change any other implicit defense besides over_limit_action? Anything in adaptive_complexity_protocol that gates on file count?
- **Verification**: `grep` over alex/SKILL.md for file-count gating outside express_path_protocol:
  - Line 13 (skill description frontmatter): "新功能（预计修改 >3 个文件...)" — narrative description, not enforcement. Could be slightly inconsistent now (description says >3 → use Alex; *express limit raised to 5). Minor inconsistency, not a defense.
  - Line 33 (CLAUDE.md narrative): "影响 >3个文件 → 必须用 TAD" — narrative routing rule, says "must use TAD" not "must skip *express". Still consistent (5 files is still TAD via *express path).
  - Lines 1127, 1134, 1141 (adaptive_complexity_protocol scope buckets): Light=1-3 / Standard=3-8 / Full=8+ — ranges overlap (3 is in both Light and Standard). No file_count_max enforcement gate. Independent of *express scope.
- **Verdict**: No other gating point disturbed. The L4 widening is contained to express_path_protocol scope_constraints. Minor advisory: future cleanup could harmonize the SKILL description string ">3 files" reference to ">5" for consistency, but this is not a defense layer.

---

## P2 findings

### P2-1: Comment quality / readability of L4 annotations — clear and useful

- L949 inline comment "L4: 2026-04-27 widened from 3 per Opus 4.7 token-economics relief" is useful provenance.
- L996 inline annotation "— L4 (2026-04-27): widened from 3" provides historical context without disrupting the bullet's enforcement intent.
- Verdict: Good annotation practice; not noise.

### P2-2: Cross-reference text — Tier 2 mentions code-reviewer in Blake but not Alex

- **Cite**: blake/SKILL.md L929 says `Tier 2 (≥1 distinct, code-reviewer)`. Alex L2338 says `tier_threshold=1, tier_name="Tier 2"` — does NOT name code-reviewer.
- **Risk**: Future reader of step 3.5 might infer "any single reviewer counts" without consulting Blake SKILL for the constraint that the single reviewer MUST be code-reviewer.
- **Recommendation (P2, advisory)**: Future docs Phase could add to alex/SKILL.md L2338: `tier_name="Tier 2 (code-reviewer required)"`. Not blocking — the Blake SKILL is the canonical source; cross-references back via L2353 already say "per Blake SKILL hard_requirement_distinct_reviewers tier rule".

### P2-3: AC16 literal command will keep failing on future verification

- The handoff's AC16 literal diff command is intrinsically broken (the awk extraction patterns are stylistically asymmetric). Even after future maintenance, this command will keep returning non-empty.
- **Recommendation**: When Alex Gate 4 verifies, accept INTENT-PASS-LITERAL-FAIL with documented set-equality `{yaml, research, doc-only}` symmetry. Same precedent as Phase 5 AC-G2.

---

## Verdict rationale

All 16 ACs verified PASS or INTENT-PASS:
- AC1 (Tier 1 grep =2) — PASS
- AC2 (self-review forbidden preserved =1) — PASS
- AC3 (rationale_single_source =1) — PASS
- AC4 (L2 lazy-load =2) — PASS
- AC5 (Read ALL files =0) — PASS
- AC6 (file_count_max:5 =1) — PASS
- AC7 (file_count_max:3 =0) — PASS
- AC8 (tier_threshold count =high) — PASS (≥2)
- AC9 (LAYER 2 TIER UNDER-MET =1) — PASS
- AC10 (AR-001 anchor =2) — PASS exactly
- AC11 (constraint-字样 ≥96) — PASS exactly =96
- AC12 (layer2-audit.sh untouched, git diff =0) — PASS
- AC13 (2 SKILL files modified) — PASS
- AC14 (Layer 2 ≥2 distinct sub-agents) — Blake-side dogfood handled per honest_partial fallback if quota-blocked
- AC15 (>3 files removed from express block) — PASS (0 hits in express scope, ≥1 hit on >5)
- AC16 (Tier 2 enumeration symmetry) — INTENT-PASS-LITERAL-FAIL (set-equality verified, literal diff stylistically asymmetric — same precedent as Phase 5)

No P0, no P1 blocking. Three P2 advisories (one annotation harmonization, one stream-name accuracy fix, one AC drafting note) are deferred to future cleanup. The implementation faithfully executes all 4 edits across 2 files; constraint-rule preservation is byte-perfect; AR-001 mechanical anchor preserved exactly; tier-aware branching does not introduce silent failure paths.

**Recommended sign-off: PASS.**
