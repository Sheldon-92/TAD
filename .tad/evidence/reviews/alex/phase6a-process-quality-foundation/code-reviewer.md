# Code-Reviewer Report: HANDOFF-20260425-phase6a-process-quality-foundation

**Reviewer**: code-reviewer (Alex pre-handoff Layer 2 round)
**Date**: 2026-04-25
**Scope**: Code-level correctness + portability of the Phase 6-A draft handoff before it ships to Blake.
**Self-dogfood note**: This very handoff installs the rule "Layer 2 ≥2 distinct reviewers"; backend-architect runs in parallel.

---

## Overall Assessment: **CONDITIONAL PASS**

The handoff design is sound (gray zones correctly diagnosed, Anti-Epic-1 respected, fixtures sensible), and many surface details are good — but **6 P0 issues** must be fixed before it goes to Blake. The most damning issue is that **step1d itself failed to catch a step1d-class bug in this very handoff's §9.2** (a markdown-table-escape `\|` regex bug — see P0-1). That self-dogfood failure is a strong signal that the §9.2 dual-column mechanism needs one more rule (un-rendered command snippets) before it can do its job.

---

## P0 (Blocking — must fix before Blake)

### [P0-1] step1d's own dogfood §9.2 contains the exact bug class step1d is meant to catch (markdown pipe-escape `\|` makes BSD `grep -E` regex literal, not alternation)

- **Where**: §9.2 row 4 (AC-P6A-2-b), line 682:
  ```
  `grep -A 20 'hard_requirement_distinct_reviewers' .claude/skills/blake/SKILL.md \| grep -cE 'backend-architect\|security-auditor\|performance-optimizer\|ux-expert-reviewer'`
  ```
- **Why blocks Blake**: When Blake copy-pastes this command from the rendered handoff into a shell, the markdown `\|` escapes (necessary inside table cells) become **literal backslash-pipe** in the shell. Empirical test on macOS BSD grep:
  ```
  $ printf 'backend-architect\nsecurity-auditor\n' | grep -cE 'backend-architect\|security-auditor'
  0
  ```
  In ERE mode `\|` is a literal `|`, NOT alternation. The verification command will return `0` against correct content, falsely fail AC-P6A-2-b, and Blake will rabbit-hole exactly the same way Phase 5 did — and the §6.7 dry-run log already classified this row as "post-impl" so Alex never ran it. **This is the precise Phase 5 AC-G2 failure mode reincarnated, inside the handoff that installs the fix for it.**
- **Fix**: Three required edits:
  1. **Add a step1d sub-rule** (FR1 action step) requiring Alex to (a) author every §9.2 verification command in PLAIN form first, (b) dry-run it from raw form, (c) THEN escape pipes for markdown table — and to record the un-escaped raw form in §6.5/§6.7 rather than the rendered cell. Example added rule text:
     > Step1d.action.6: For any verification command containing pipes (`|`), Alex MUST (a) author the command in raw form (no `\|` escapes), (b) dry-run from raw form, (c) record the raw form in `**AC Dry-Run Log**` block, (d) only escape pipes for markdown table rendering AFTER dry-run.
  2. **Fix this handoff's §9.2 row 4** to use a non-pipe formulation, e.g.:
     ```
     grep -A 20 'hard_requirement_distinct_reviewers' .claude/skills/blake/SKILL.md | grep -oE 'backend-architect|security-auditor|performance-optimizer|ux-expert-reviewer' | sort -u | wc -l
     ```
     and quote the command in a fenced code block above the table (or in §6.5) so Blake copies un-escaped form. Also note: `grep -cE 'A|B|C|D'` returns the **number of matching LINES** (1 if all 4 reviewer names appear on the same line, 4 if separate lines) — NOT the number of distinct matches. The expected `=4` only works if the FR3 YAML formatting puts each name on its own line (it currently does, but a future formatter could break this). The `grep -oE … | sort -u | wc -l` form is robust to layout.
  3. **Reclassify AC-P6A-2-b as pre-impl-verifiable IF Alex stages FR3 in a draft block first**, OR keep post-impl but require Blake's Layer 1 acceptance script to test the un-escaped form, NOT what's in the table cell.
- Note that AC-P6A-2-b row in §9.2 is currently marked "post-impl" so step1d (per its own contract) skipped it. This is a structural gap: post-impl rows that contain pipes still need their syntax validated at draft time (a syntax check, not an output check). Add to step1d.action: "For ALL rows including post-impl, validate command shell-syntax using `bash -n <(echo "$cmd")` or run-with-bogus-target dry-run."

---

### [P0-2] FR3 / §6.6 insertion target `layer2_expert_review.minimum_required` does not exist in `.claude/skills/blake/SKILL.md`; `layer2_expert_review` is a flat YAML list, not a nested mapping

- **Where**: §6.6 row 2 says "Insert AFTER the existing `layer2_expert_review.minimum_required` block end, BEFORE next sibling block, indent 4-space (under `gate3_v2`)".
- **Empirical verification**: 
  ```
  $ grep -n 'minimum_required' .claude/skills/blake/SKILL.md
  (no output — string does not exist)
  $ awk 'NR>=906 && NR<=913' .claude/skills/blake/SKILL.md
      layer2_expert_review:
        - "Group 0: spec-compliance-reviewer（AC 全满足）"
        - "Group 1: code-reviewer（P0=0, P1=0）"
        - "Group 2: test-runner + security-auditor + performance-optimizer（按 trigger 规则）"
        - "Expert 说 PASS 才算完成 — 不是 Blake 自己判断"
  ```
- **Why blocks Blake**: `layer2_expert_review` is a YAML **sequence of strings** (list, lines 907-910), not a **mapping** with sub-keys. You cannot graft a `hard_requirement_distinct_reviewers:` mapping under a sequence — it produces invalid YAML. Blake will either: (a) get stuck deciding placement, (b) silently convert the sequence to a mapping and break every other consumer that expects the list form, or (c) place it at sibling level (under `gate3_v2`) which contradicts §6.6's "under `gate3_v2.layer2_expert_review`" intent.
- **Fix**: Choose ONE of these structural options and rewrite §6.6 + FR3:
  - **Option A (recommended)**: Convert `layer2_expert_review` from list to mapping. Original 4 list items become a `bullets:` sub-key (preserves existing semantics), then `hard_requirement_distinct_reviewers:` becomes a peer sub-key. Add explicit before/after YAML in §6.6 so Blake doesn't guess. Also add an AC verifying the four legacy bullets still parse.
  - **Option B**: Keep `layer2_expert_review` as a list and add `hard_requirement_distinct_reviewers:` as a sibling key under `gate3_v2:` (NOT under `layer2_expert_review`). Update FR3 wording + §6.6 to reflect sibling, not nested. AC-P6A-2-a verification stays the same (just a `grep -c` for the keyword).
- **Side question**: Verify whether anything in the codebase reads `gate3_v2.layer2_expert_review` as YAML (vs just SKILL prose). `grep -rE 'layer2_expert_review' .tad .claude` would tell us. Currently appears to be prose-only (no parser), so Option B is lower-risk; Option A is cleaner long-term.

---

### [P0-3] Step1d §6.7 dry-run log AC-G2 entry is FACTUALLY WRONG — re-derived empirical value differs from Alex's pasted output

- **Where**: §6.7 row "AC-G2", line 589. Handoff claims:
  > AC-G2 (layer2-audit.sh advisory only — no exit-on-Write hook) | pre-impl-verifiable | `grep -c 'exit 1' .tad/hooks/lib/layer2-audit.sh` → **1** (existing FAIL path; OK because not from new code; Blake will preserve) ✅ matches existing
- **Empirical verification** (Alex Gate-4-style re-derive):
  ```
  $ grep -c 'exit 1' .tad/hooks/lib/layer2-audit.sh
  3
  ```
  The actual current file has **3** `exit 1` occurrences (lines 86, 126, 135 — all existing FAIL paths). Alex's pasted output `1` is wrong.
- **Why blocks Blake**: If §6.7 is the single source of truth for "what step1d verified", and the truth is wrong, Blake's Gate 3 verification will diverge from Alex's claim. Worse, AC-G2 in §9.2 (row 11) says expected `= 0` for `grep -c '"deny"'` — but §6.7 quotes a different command (`grep -c 'exit 1'`) for AC-G2. The AC-G2 description itself is inconsistent between §9.1, §9.2, and §6.7.
  - §9.1 AC-G2: "layer2-audit.sh after enhancement is still advisory… `grep -c '"deny"'… = 0`"
  - §9.2 row 11: same as §9.1 (`= 0` for `'"deny"'`)
  - §6.7: `grep -c 'exit 1'… → 1` (different command, wrong number)
- **Fix**: 
  1. Replace §6.7 AC-G2 entry with the actual §9.1/§9.2 command and its empirically-correct output:
     ```
     | AC-G2 | pre-impl-verifiable | `grep -c '"deny"' .tad/hooks/lib/layer2-audit.sh` → 0 ✅ matches expected = 0 |
     ```
     (Re-classify from the previous ambiguous "post-impl" comment in §9.2 row 11.)
  2. **Reclassify AC-G2 in §9.2 from post-impl-verifiable → pre-impl-verifiable**. The current layer2-audit.sh already has 0 occurrences of `"deny"` (verified: 0). The AC measures "after enhancement still 0" — but if Blake's enhancement also doesn't add `"deny"` (per Anti-Epic-1, it shouldn't), the verification command runs identically pre and post. Mark as **pre-impl-verifiable + post-impl-revisited** (Alex confirmed pre-existing 0; Blake re-confirms post-impl). This is exactly the kind of timing classification step1d is meant to surface — the original handoff got it wrong.
  3. Run all §6.7 entries through a re-derive pass before sending. **Recommended**: Add to step1d.action.5 a literal: "Re-derive every pre-impl-verifiable AC value with a one-liner; never trust memory or copy-paste from another section."

---

### [P0-4] FR4 reviewer-name extraction has no defense for filenames with non-ASCII or whitespace; whitelist filtering uses unspecified mechanism

- **Where**: §3.1 FR4 step 2 says `${basename%.md}`; step 3 says "Filter to known reviewer names: `code-reviewer | backend-architect | security-auditor | performance-optimizer | ux-expert-reviewer | api-designer | data-analyst | bug-hunter` (extensible whitelist)".
- **Why blocks Blake**: Three concrete portability/correctness gaps:
  1. **`${basename%.md}` only strips the suffix**; it doesn't sanitize. A file like `code-reviewer (1).md` (macOS Finder duplicate) would yield reviewer name `code-reviewer (1)` which is not in the whitelist → silently dropped. Acceptable behavior, but Blake needs a documented rule.
  2. **Filenames with whitespace** break unquoted bash expansions. The existing `layer2-audit.sh` uses `find ... -print0` with `read -d ''` — Blake's enhancement MUST follow the same pattern, NOT a `for f in $(ls ...)` loop. The handoff doesn't say so explicitly.
  3. **Whitelist filter mechanism unspecified.** §3.1 lists names with `|` separators (regex form?), §4.3 lists them as a space-separated bash array (`KNOWN_REVIEWERS="code-reviewer ..."`). For BSD-portable + faster matching, a `case "$name" in code-reviewer|backend-architect|...) … ;; *) … ;; esac` is the cleanest form (single-line, no fork, no regex engine). Recommend `case` over `grep -E` since names are fixed strings. Document this choice in §6.6 / FR4.
- **Fix**: Add to §3.1 FR4 step 2-3 explicit:
  - Use `find ... -print0` + `while IFS= read -r -d '' f` (existing layer2-audit.sh pattern).
  - Use `name=${f##*/}; name=${name%.md}` (strip both directory + suffix).
  - Use `case "$name" in code-reviewer|backend-architect|security-auditor|performance-optimizer|ux-expert-reviewer|api-designer|data-analyst|bug-hunter) reviewers+="$name\n" ;; self-review|feedback-integration|gate3-verdict) : ;; *) unknown+="$name\n" ;; esac` — `case` is BSD-portable, fork-free, and faster than grep.
  - For unknown names (EC1): list them in stderr WARN message (don't silently drop).

---

### [P0-5] AC-P6A-4-b regex `WARN.*1 distinct` is fragile — depends on exact wording of the WARN message that FR4 has not pinned down

- **Where**: §9.2 row 7. AC-P6A-4-b verification: `grep -cE 'WARN.*1 distinct'`. Expected ≥1.
- **Why blocks Blake**: FR4 §3.1 step 5 specifies the WARN message as:
  > `Layer 2 audit WARN: only N distinct reviewers (need ≥2 unless *express); found: <list>`
  The regex `WARN.*1 distinct` will only match if Blake writes `1 distinct` literally — but a perfectly reasonable wording is `only 1 distinct reviewer` (singular) or `1 distinct external reviewers`. If Blake substitutes the singular `reviewer` (which English grammar suggests), the regex still matches because it doesn't anchor on `reviewer`. **However**, if Blake formats as `only 1 (one) distinct reviewer` or localizes the number, AC fails.
  More importantly, the regex matches `WARN.*1 distinct` which is satisfied by `WARN: 11 distinct reviewers` (substring). Concrete bug: with 11 reviewers (extensible whitelist could grow), `1 distinct` is a substring of `11 distinct` and the AC will say WARN-fired even when the true distinct count is 11. **Use word boundaries** correctly per architecture.md 2026-04-24 entry "Word-Boundary Matching for Identifier-Style Slugs": don't use `\b`, use bracket class.
- **Fix**: 
  1. Pin the exact WARN string format in FR4 — make it a named constant, not free prose. E.g., "`%s: %d %s` where format is `Layer 2 audit WARN: only N distinct external reviewers (need ≥2 unless *express); found: <list>`". 
  2. Make AC-P6A-4-b grep specifically: `grep -E '(^|[^0-9])1 distinct external reviewer'` — non-digit boundary prevents `11 distinct` substring match.
  3. Or, even better, make FR4 emit a structured stderr line like `WARN_REVIEWER_COUNT=1` that AC matches with `grep -E '^WARN_REVIEWER_COUNT=1$'` — exact-match, no language fragility.

---

### [P0-6] `*express` glob detection (FR4 step 5) has a false-positive on `expression`; rule is also under-specified for handoffs that contain `express` as a non-prefix word

- **Where**: §3.1 FR4 step 5 says "filename pattern `*express*` OR handoff frontmatter `task_type: express`".
- **Empirical verification**:
  ```
  $ for s in compress expression toy-express-bug express; do case "$s" in *express*) echo MATCH: $s;; *) echo no: $s;; esac; done
  no:    compress
  MATCH: expression          # ← false positive
  MATCH: toy-express-bug
  MATCH: express
  ```
- **Why blocks Blake**: A handoff slug like `phase7-expression-language-redesign` would be silently classified as *express path → single-reviewer-allowed → AR-001 attack surface (the very surface this Epic is closing). The architecture.md AR-001 entry specifically warns "letter-not-spirit" defenses are required.
- **Fix**: Use word-boundary matching per the 2026-04-24 architecture.md entry:
  - Slug detection: `case "$slug" in express|*-express|*-express-*|express-*) IS_EXPRESS=1 ;; *) IS_EXPRESS=0 ;; esac` — matches `express`, `toy-express`, `toy-express-bug`, `express-bug` but NOT `expression`, `compress`.
  - OR (preferred): Drop filename-glob detection entirely; require the COMPLETION report's `task_type: express` frontmatter as the SOLE signal. CLI fallback: env var `LAYER2_AUDIT_EXPRESS=1`. Filename heuristic is too fragile.
- Also: `task_type: express` is not currently a defined value in `task_type` enum (current enum: `code | yaml | research | e2e | mixed | doc-only`). Either add `express` to the enum (template change) OR introduce a separate `path_type: express` frontmatter field. Specify in FR2.

---

## P1 (Should fix)

### [P1-1] Section numbering inside the handoff is inconsistent with the actual `.tad/templates/handoff-a-to-b.md`

- The handoff calls its Spec Compliance Checklist `§9.2`, but in the current template, §9.1 = Spec Compliance Checklist and §9.2 = Expert Review Status. The handoff's own structure is §9.1 = "List of N", §9.2 = "Spec Compliance Checklist", §9.3 = "Required Evidence Manifest", §9.4 = "Expert Review Status". This doesn't match the template Blake will edit (FR2).
- **Why a problem**: FR2 says "Edit `.tad/templates/handoff-a-to-b.md` §9.2" but the actual template's §9.2 is Expert Review Status — Blake will edit the wrong section.
- **Fix**: Either renumber this handoff to match the template (§9.1 = Spec Compliance, §9.2 = Expert Review, §9.3 = Required Evidence Manifest), OR explicitly state in FR2: "Edit §9.1 'Spec Compliance Checklist' (NOT §9.2 — section numbering in template differs from this handoff)".

### [P1-2] Indentation rule says "4-space (sibling to step1c)" — empirically correct, but `step1c` and friends are nested at 4-space INSIDE `workflow:` which itself is at 2-space; Blake might mis-count

- **Where**: §6.6 indent column. Empirically verified `step1c` and `step2` are at 4 spaces leading whitespace. ✅
- **But**: `handoff_creation_protocol.workflow.step1c` has structure: top-level `handoff_creation_protocol:` (0 spaces) → `workflow:` (2 spaces) → `step1c:` (4 spaces) → `step1c.action:` (6 spaces). Indent depth alone is ambiguous if Blake misreads the parent.
- **Fix**: §6.6 should specify the FULL YAML path: `handoff_creation_protocol.workflow.step1d` and `gate3_v2.layer2_expert_review.hard_requirement_distinct_reviewers` (per P0-2 Option A) OR `gate3_v2.hard_requirement_distinct_reviewers` (Option B). Plus give a concrete "after this exact line, before this exact line" anchor with line-number range as backup.

### [P1-3] FR4 backward-compat states "Add WARN as exit 0 + stderr message (advisory)" but existing FAIL paths (lines 124, 133) ALREADY use stderr + exit 1

- **Where**: §3.1 FR4 last paragraph + AC-P6A-4-d.
- **Why a problem**: The handoff conflates two new states — `WARN` (1 distinct reviewer, non-express) and `PASS-with-substitutes-only` — with existing FAIL. Specifically:
  - Today: `qualified ≥ 1` → PASS exit 0; `qualified == 0` → FAIL exit 1.
  - After enhancement: should `code-reviewer + self-review` (1 distinct external) be WARN exit 0 (advisory) or FAIL exit 1 (escalate)? §3.1 says WARN exit 0; AC-P6A-4-b confirms exit 0. OK.
  - But what about `0 distinct external + 2 substitutes`? That's a stronger drift than "1 distinct + 1 substitute". The current FR4 step 5 says `Layer 2 audit FAIL: 0 distinct reviewers found in <dir>; only substitution files: <list>` if substitution-only. Is this exit 1 (FAIL) or exit 0 (WARN)? Not specified. Anti-Epic-1 says no fail-closed, so probably exit 0 with FAIL message. But "FAIL" message + exit 0 contradicts the existing convention where FAIL = exit 1.
- **Fix**: §3.1 FR4 add an explicit verdict-to-exit-code table:
  | Distinct reviewers | substitutes? | message | exit |
  |---|---|---|---|
  | ≥2 | any | PASS: N distinct | 0 |
  | 1, *express slug | any | PASS: 1 distinct (express OK) | 0 |
  | 1, non-express | any | WARN: 1 distinct (need ≥2) | 0 |
  | 0, has substitutes | yes | WARN: 0 distinct, substitutes only | 0 (advisory) |
  | 0, no files | no | FAIL: directory empty | 1 |
  | dir missing | n/a | FAIL: directory missing | 1 |
  | invalid slug | n/a | FAIL: invalid slug | 2 |

### [P1-4] FR5 fixture's "step1d would catch this" assertion mechanism is unspecified — fixture is bash but step1d is Alex SKILL prose

- **Where**: §3.1 FR5 + §8.1.
- **Why a problem**: Step1d is a prose-level instruction in Alex's SKILL.md, not executable code. A bash fixture cannot "test step1d catches this". What the fixture CAN actually test is: "given this buggy command from §9.2, does running it return output that mismatches expected evidence?" — i.e., the fixture demonstrates the BUG, not the CATCH. The "catch" is performed by Alex's reasoning at step1d-time.
- **Fix**: Reword FR5 + §8.1 + AC-P6A-5-a to be honest:
  - The fixture **demonstrates** that the Phase 5 AC-G2 buggy command, when actually run, returns output that does NOT match the AC's "Expected Evidence" — i.e., proves the bug is detectable when the command is run.
  - The "catch" is Alex following step1d (prose). The fixture is a regression suite: any future PR that breaks step1d's reasoning won't be caught, but any PR that breaks the assertion (the buggy command's output IS now mismatching) will be.
  - Three PASS markers: (1) buggy command runs without error, (2) buggy command's stdout does NOT contain the Expected Evidence string, (3) the well-formed command (the Phase 5 fix) does match Expected Evidence.

### [P1-5] FR6 fixture case 3 ("WARN if non-express, PASS if express slug") needs invocation contract — what slug does the test pass to layer2-audit.sh?

- **Where**: §3.1 FR6 case 3 + §8.1.
- **Why a problem**: layer2-audit.sh is invoked as `bash layer2-audit.sh <slug>`. The fixture must invoke it twice with different slugs (e.g., `phase6a-process-quality-foundation` and `phase6a-express-test`) — the fixture spec doesn't say which dirs to populate or which slug names to use.
- **Fix**: §8.1 Case 3 spec: "Create temp dirs `<root>/phase6a-test/` and `<root>/phase6a-express-test/`, each with only `code-reviewer.md`. Run `bash layer2-audit.sh phase6a-test` (expect WARN), then `bash layer2-audit.sh phase6a-express-test` (expect PASS). Note: layer2-audit.sh hardcodes `.tad/evidence/reviews/blake/<slug>/` — the fixture either needs to chdir to a tmp project root or set a `LAYER2_AUDIT_REVIEW_ROOT` env var (which doesn't exist yet — would require a small FR4 addition)."

### [P1-6] FR4 §3.1 step 1 says "existing: count files matching `*.md` excluding hidden + tiny" but the existing script also rejects symlinks-to-tiny (line 105-107). Enhancement spec drops this distinction.

- **Where**: §3.1 FR4 step 1 vs existing script lines 91-109.
- **Why a problem**: The existing script differentiates "symlink to <200B target" (had_symlink_small=1) from "regular file <200B" (had_small=1). If Blake replaces the file-counting loop wholesale, this distinction is lost.
- **Fix**: §3.1 FR4 add: "Preserve existing min_bytes=200 filter and symlink-distinction logic; reviewer-name detection layers ON TOP of existing qualification, NOT IN PLACE OF it. A file is qualified-AND-named-as-known-reviewer to count as a 'distinct reviewer'."

### [P1-7] AC-P6A-1-c verification "by line numbers ascending" has no command in §9.2

- **Where**: §9.1 AC-P6A-1-c says "step1d block insertion AFTER step1c AND BEFORE step2 (verifiable by line numbers ascending)". §9.2 has no row for AC-P6A-1-c.
- **Why a problem**: AC has no verification command → Blake will improvise → drift.
- **Fix**: Add §9.2 row:
  ```
  | AC-P6A-1-c | post-impl-verifiable | `awk '/^( ){4}step1c:/{c=NR} /^( ){4}step1d:/{d=NR} /^( ){4}step2:/{t=NR} END{exit !(c<d && d<t)}' .claude/skills/alex/SKILL.md && echo OK` | OK | (post-impl) |
  ```

---

## P2 (Nice to have)

### [P2-1] §6.7 dry-run log claims "2/2 pre-impl-verifiable ACs PASS" — but per P0-3 this count is wrong (3 ACs are actually pre-impl, not 2)

If P0-3's reclassification is accepted, AC-G2 also becomes pre-impl. The Result line in §6.7 should read "3/3 pre-impl-verifiable ACs PASS" after the fix.

### [P2-2] §10.1 warning about "*express" mentions "*express path 也必须 ≥1 review" — but FR3's `exception_express` says "*express 仅需 code-reviewer (single expert OK)". Two phrasings are consistent but the §10.1 paragraph could be clearer that *express still requires ≥1 reviewer (not zero).

Reword §10.1: "*express path: ≥1 review (code-reviewer alone OK); standard/*analyze/*experiment: ≥2 distinct (code-reviewer + ≥1 domain expert)."

### [P2-3] §11.1 Decision #3 says "Hard ≥2 distinct sub-agent" — but §11.2 Decision #11 says reviewer whitelist is "Extensible bash array at top of layer2-audit.sh". The two should cross-reference: when array is extended, what bumps the version of the audit script?

Add a one-liner: "Whitelist additions don't change exit-code semantics; only require Blake to update the array literal and keep PASS/WARN/FAIL message format stable."

### [P2-4] Re-derive `grep -c '"deny"' layer2-audit.sh = 0` — verified empirically OK. But the AC-G2 wording "no exit-on-Write hook" is misleading: layer2-audit.sh isn't a hook regardless of `"deny"` content; it's a CLI. The AC purpose is to verify "no fail-closed escalation". Recommend rewording to "AC-G2: layer2-audit.sh contains no `"deny"` literal (Anti-Epic-1: confirms enhancement did not add fail-closed action types)".

### [P2-5] §3.1 FR4 reviewer-name extraction list includes `bug-hunter` — but architecture.md does not document `bug-hunter` as a sub-agent. Verify this is a real sub-agent name (or remove from default whitelist; can be added when first used).

### [P2-6] No mention of how layer2-audit.sh handles the slug-truncation fallback (existing lines 60-79) when a "truncated" slug dir has reviewer-name detection that disagrees from the original. Probably fine in practice but worth one sentence in §3.1 FR4: "Slug-truncation fallback (existing) operates BEFORE reviewer-name detection; once a dir is selected, name detection runs on that dir's files."

---

## Summary Table

| Severity | Count | Notable |
|---|---|---|
| P0 | 6 | P0-1 self-dogfood failure (table-pipe regex bug step1d should have caught), P0-2 invalid YAML graft target, P0-3 wrong dry-run output |
| P1 | 7 | section numbering, exit code table, fixture honesty |
| P2 | 6 | wording, cross-reference polish |

**Verdict: CONDITIONAL PASS** — Do not send to Blake until P0-1 through P0-6 are fixed. P1 items should be cleaned up in the same revision; P2 can defer.

The handoff's design is right; its instance is buggy. The strongest signal from this review: **step1d itself needs (a) a "raw-form-before-rendered-form" rule for table-cell pipe escapes, (b) a syntax-validate-even-for-post-impl-rows rule, and (c) a re-derive-don't-quote rule for §6.5 / §6.7 dry-run logs.** Add these as sub-rules under FR1 step1d.action so the very next handoff doesn't repeat P0-1 / P0-3.
