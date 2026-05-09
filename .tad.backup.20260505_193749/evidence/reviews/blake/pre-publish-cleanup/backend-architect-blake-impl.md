# Backend-Architect Layer 2 Review — Blake Implementation of HANDOFF-20260427-pre-publish-cleanup

**Reviewer**: backend-architect (Layer 2, post-implementation)
**Subject**: Blake's working-tree implementation of HANDOFF-20260427-pre-publish-cleanup.md
**Review date**: 2026-04-27
**Mandate**: §6 Phase 6 step 5 fresh-codebase grep dogfood (AC13) + verify §3.1 FR1-FR5 + assess scope completeness against §10.5 allowlist
**Verdict**: **PASS-WITH-P1** — implementation is functionally correct end-to-end, all 3 dangling consumers migrated and the migrated test runner achieves 30/30 PASS. Two AC wording defects flagged as P1 (literal verification commands diverge from intent — same recurring "AC Verification Commands Need Pre-Ship Smoke Test" pattern noted in architecture.md 2026-04-25).

---

## 1. Summary

| Aspect | Status | Notes |
|---|---|---|
| FR1 — `run-phase2b-tests.sh` migrated to `.router.log` | PASS | 30/30 PASS on smoke run; 5-tuple parse + delta-based detection works |
| FR2 — `AC-P1.4-router-event-filter.sh` `_assert_match` migrated | PASS | Reads `.router.log` via `wc -l`/`tail -1`/`awk '{print $3}'` pattern symmetric with FR1 |
| FR3 — release-runbook smoke test updated | PASS | Phase 7 now `tail -1 ... | grep -q "web-frontend"` instead of stdout JSON parse |
| FR4 — Alex SKILL BUSINESS-VALUE-FIRST inserted | PASS | 8-space indent, 17 lines, sentinel `<!-- END-BUSINESS-VALUE-FIRST -->` present (line 2055-2072) |
| FR5 — Blake SKILL byte-symmetric copy | PASS-WITH-CAVEAT | Content semantically identical; indent is 4-space (per host YAML nesting depth) — see P1 #1 below |
| AC13 — fresh grep dogfood (this review) | PASS | 3 remaining hits all classify (b)/(c), zero real consumers |
| `.router.log` contract drift risk | P1 noted | Format documented in hook header but not in any CONTRACT/README the 3 consumers reference |
| Hook scope-drift recurrence risk | P1 noted | See §4 recommendation for `dangling consumer` lint pattern |

Smoke test evidence (run during this review):
```
Total:    30/30 (100.0%)
Positive: 25/25
Negative: 5/5
AC9 thresholds: ✅ PASS / ✅ PASS / ✅ PASS
```

---

## 2. AC13 Fresh Grep Dogfood Result

Command run verbatim per handoff §6 Phase 6 step 5:

```bash
grep -rln -E "additionalContext|hookSpecificOutput" .tad/ .claude/ 2>/dev/null \
  | grep -vE "^\.tad/archive/" \
  | grep -vE "^\.tad/active/handoffs/" \
  | grep -vE "^\.tad/evidence/" \
  | grep -vE "^\.tad/spike-v3/" \
  | grep -vE "^\.tad/hooks/startup-health\.sh$" \
  | grep -vE "^\.tad/hooks/post-write-sync\.sh$" \
  | grep -vE "^\.tad/hooks/lib/common\.sh$" \
  | grep -vE "^\.claude/skills/alex/SKILL\.md$" \
  | grep -vE "^\.claude/skills/blake/SKILL\.md$"
```

**Result: 3 hits returned** (handoff §3 prediction matches: §3 acknowledged these would remain; spec said empty post-fix is the goal but the 3 doc files were never expected to be in scope of this surgical handoff).

| # | Hit (path:line) | Kind of mention | Classify | Recommended action |
|---|---|---|---|---|
| 1 | `.tad/deprecation.yaml:73` | Note in v2.8.4 entry: `userprompt-domain-router.sh: additionalContext injection removed (passive mode)` — describes the removal itself in the deprecation log | **(b) Documentation** | **None** — this IS the deprecation record. Removing it would erase the audit trail of WHY the removal happened. Recommend extending §10.5 allowlist to include `^\.tad/deprecation\.yaml$`. |
| 2 | `.tad/tests/test-domain-pack.md:10,27,53,56` | Test plan markdown for `startup-health.sh` (SessionStart hook). Lines 10/27 describe how to verify SessionStart hook output contains `additionalContext` field. Lines 53-56 describe legacy `PostToolUse async additionalContext delivery` test (post-write-sync.sh territory) | **(c) Test plan of allowlisted hook** | **None** — both `startup-health.sh` and `post-write-sync.sh` are explicitly in §10.5 allowlist. Their test PLAN file is a logical extension of that allowlist. Recommend extending §10.5 allowlist to include `^\.tad/tests/test-domain-pack\.md$` (or, more general: `^\.tad/tests/.*\.md$`). |
| 3 | `.tad/project-knowledge/architecture.md:167,233,234,236,241,242,258,497,498,511,513,514,515,517` | Historical knowledge entries describing past spikes (UserPromptSubmit Hook Verified - 2026-04-07, type:prompt vs type:command - 2026-04-07, claude -p Valid Channel - 2026-04-07, Pre-Handoff vs Post-Implementation Reviewer - 2026-04-27, Mechanism Output Signature Drift - 2026-04-27) | **(b) Documentation** | **None** — knowledge entries record HISTORICAL discoveries about a mechanism that was later removed. They are the institutional memory of WHY removal was safe. Per the "Stale-knowledge revalidation rule" pattern (architecture.md 2026-04-24), any entry that cites the now-removed mechanism should bear `**Revalidated**: YYYY-MM-DD` once a human reads it; that's the existing maintenance contract — not a defect of THIS handoff. Recommend extending §10.5 allowlist to include `^\.tad/project-knowledge/.*\.md$`. |

**Net AC13 result**: **PASS — zero real consumers (kind a) remain**. All 3 hits are documentation/audit/test-plan referring to either the removal record itself or to allowlisted hooks. The 3 in-scope dangling consumers Blake was tasked to migrate (run-phase2b-tests.sh, AC-P1.4, release-runbook) are now `additionalContext`-free as verified by the same grep returning none of them.

**Allowlist extension recommendation** (P1): the §10.5 allowlist as written is missing 3 documentation directories that legitimately mention the string. Future Alex `*publish` Phase 7 smoke runs of this same grep WILL re-surface these 3 paths and waste review cycles. Recommend amending §10.5 to add:
```
| grep -vE "^\.tad/deprecation\.yaml$" \
| grep -vE "^\.tad/tests/.*\.md$" \
| grep -vE "^\.tad/project-knowledge/.*\.md$" \
```
This is a doc-file allowlist update, not new code work.

---

## 3. Critical Issues (P0)

**None.** All 3 dangling consumers are migrated and functional. The byte-symmetry intent of FR4/FR5 is met semantically; smoke test is green; release-runbook smoke target is correctly pointed at `.router.log`. Architecture is sound.

---

## 4. Recommendations (P1)

### P1 #1 — `.router.log` 5-tuple format is now load-bearing for 3 consumers, but documented in only 1 place (hook header comment)

**Observation**: Three independent consumers now parse `.router.log`:
- `run-phase2b-tests.sh` line 73-75 (Python `last[2]`/`last[3]` field index)
- `AC-P1.4-router-event-filter.sh` line 59 (`awk '{print $3}'`)
- `release-runbook/SKILL.md` line 301 (`grep -q "web-frontend"` against `tail -1`)

The format `<ISO-timestamp> <elapsed_ms> <pack|none> <matched/total|0> <msglen>` is documented only in the hook source at line 16 (header comment) and line 73-75 of `run-phase2b-tests.sh` (in-code comment). If a future contributor reorders the columns or adds a 6th field at position 3, ALL 3 consumers break silently (the `print $3` in AC-P1.4 would surface a different field, the Python `last[2]` would too, and release-runbook would just stop matching `web-frontend`).

**Recommendation**: Add a short `.tad/hooks/.router.log.CONTRACT.md` (or a `# CONTRACT:` block at the very top of the hook file) declaring the format as load-bearing with the 3 consumers listed by path:line. Cost: ~10 lines of markdown. Benefit: one search target if format change is ever proposed. This is the same pattern as the "OUTPUT MECHANISM signature" lesson in architecture.md (2026-04-27 "Mechanism Output Signature Drift") — a removed mechanism's replacement should declare its contract explicitly.

### P1 #2 — AC8/9 verification command will literally fail (returns 2, not 1) due to spec-vs-grep mismatch

Per handoff §9.1:
- **AC8**: `grep -c "BUSINESS-VALUE-FIRST" .claude/skills/alex/SKILL.md` should return `1`
- **AC9**: same against Blake → should return `1`

Actual on Blake's working tree:
```
.claude/skills/alex/SKILL.md:2
.claude/skills/blake/SKILL.md:2
```

Cause: the rule contains the literal string `BUSINESS-VALUE-FIRST` in BOTH the opening header (`⚠️ BUSINESS-VALUE-FIRST RULE (MANDATORY, ...)`) AND the closing sentinel marker (`<!-- END-BUSINESS-VALUE-FIRST -->`). `grep -c` counts BOTH lines.

This is the **4th consecutive Phase exhibiting "AC Verification Commands Need Pre-Ship Smoke Test"** (architecture.md 2026-04-25) — the same drift pattern. Alex didn't dry-run the AC command on the actual sentinel-bearing prose. Intent (one rule installed) is met; literal command fails.

**Recommendation**: For Gate 4 acceptance, count this as INTENT-PASS-LITERAL-FAIL (Blake's track record from Phase 5). For the next AC review pass, reword AC8/9 to either:
- `grep -c "BUSINESS-VALUE-FIRST RULE (MANDATORY" ...` should return 1 (uniqueness anchor on the header line), OR
- `awk '/BUSINESS-VALUE-FIRST RULE/{c++}END{print c}' ...` should return 1.

Phase 6-A.1 (or a follow-up to it) really should land the "every non-trivial AC verification command must be dry-run on a representative artifact during handoff drafting" §9.2 dry-run-evidence column rule that architecture.md flagged. This is recurrence #4.

### P1 #3 — AC10 byte-symmetric verification command literally fails due to indent (intent met, command shape wrong)

Per handoff §9.1 AC10:
```
diff <(awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/' .claude/skills/alex/SKILL.md) \
     <(awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/' .claude/skills/blake/SKILL.md) → empty
```

Actual on Blake's working tree:
- Alex insertion at line 2055 → 8-space leading indent (because `step7` is nested deeper in the YAML hierarchy)
- Blake insertion at line 1084 → 4-space leading indent (because `step8` is at a shallower YAML nesting depth)

The diff fires on every single line because of the indent delta (8→4 = 4-char left shift on 17 lines). However, when whitespace is normalized:

```
diff <(awk ... | sed 's/^[[:space:]]*//') <(awk ... | sed 's/^[[:space:]]*//')
EXIT_normalized=0  ← content-symmetric PASS
```

The CONTENT is byte-symmetric (which is what NFR3 architecturally needs — same rule both sides, no semantic drift). The literal AC10 command is wrong because it ignores the host YAML structure imposing different indent on each side.

**Acceptable per NFR3 intent**: YES — NFR3 §3.1 says "FR4 + FR5 的 BUSINESS-VALUE-FIRST RULE 必须**字字一致**" and explicitly notes "Blake 在 FR5 用 Read tool 验证 FR4 已写入的 prose，然后 Edit copy". Blake DID Read+Edit copy. The indent shift is mechanically required by the host file's YAML nesting (a literal byte-identical insert would break Blake SKILL's YAML indentation and thus break the parser). This is the "host-imposed structure" exception the handoff did not explicitly acknowledge but is architecturally unavoidable.

**Recommendation**: Update AC10 to normalize whitespace before diff:
```bash
diff <(awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/' .claude/skills/alex/SKILL.md | sed 's/^[[:space:]]*//') \
     <(awk '/BUSINESS-VALUE-FIRST RULE/,/END-BUSINESS-VALUE-FIRST/' .claude/skills/blake/SKILL.md | sed 's/^[[:space:]]*//')
```

This is the third documented case of "AC literal-vs-intent gap caused by Alex not dry-running the command against the real artifact during handoff drafting" in this surgical handoff alone (AC8 + AC9 + AC10). Strong signal that Phase 6-A.1 §9.2 dry-run column is overdue.

### P1 #4 — Forward-looking: scope-drift recurrence pattern for the NEXT 6 months

The architecture.md "Pre-Handoff vs Post-Implementation Reviewer" + "Mechanism Output Signature Drift" entries (2026-04-27) capture the root cause — primary-mention bias misses CONSUMERS. Two future scope-drift candidates I see in the current codebase:

1. **`startup-health.sh` SessionStart `additionalContext` emission**: if user later decides "Domain Pack catalog injection at session start is also annoying", removing it will repeat this exact pattern. Consumers TODAY: Alex SKILL line 561/570/1541 references that catalog; Blake SKILL same. Removal would dangle Alex/Blake SKILL prose AND test-domain-pack.md tests 1/4. Mitigation: declare a CONSUMERS list as part of any "remove this hook output" decision document (per architecture.md "Mechanism Output Signature Drift" — extract the OUTPUT MECHANISM signature).
2. **`.router.log` itself**: now 3 consumers parse it. If anyone proposes changing the column order or adding fields, ALL 3 break. P1 #1 above (CONTRACT.md) is the mitigation.

**Pattern recommendation**: For the upcoming `*publish` cycle, add to release-runbook Phase 1 pre-flight a step "FOR EACH file deleted/output-changed in this release: run `grep -rln -E '<output-mechanism-signature>' .tad/ .claude/` and verify zero unexpected hits before commit". This embeds the CONSUMER scan into the release flow itself. The 4-line addition to release-runbook would have prevented this entire follow-up handoff.

---

## 5. Suggestions (P2)

### P2 #1 — `_invoke_hook` in AC-P1.4 still captures stdout even though stdout is now empty

Lines 22-35 of `AC-P1.4-router-event-filter.sh` still build a temp file for stdout and `cat` it back to the caller. Since the hook now never emits stdout context, this is dead capture. Could be simplified to `printf '%s' "$json" | bash "$HOOK" 2>/dev/null; return $?`. Minor: 8 lines of dead tempfile code. Defer to a future cleanup pass; not worth re-rolling this handoff.

### P2 #2 — `run_case` `NO_LOG_DELTA` defensive return path is unreachable in current hook

Lines 79-80 of `run-phase2b-tests.sh`: `if len(lines) <= pre_lines: return ("", "NO_LOG_DELTA")`. Looking at the hook code lines 246-252, the printf to LOG_FILE is unconditional after passing the kill-switch and dependency check. The `NO_LOG_DELTA` branch only fires if (a) hook exited 0 before reaching line 246 (early-return on whitelist or kill-switch) OR (b) LOG_FILE write was redirected to `|| true` after a chmod issue. Both are valid defensive cases — keep the branch, but consider documenting in a comment that this is the "kill-switch / whitelist-exit / disk-full" defensive path, not the normal flow.

### P2 #3 — `lib/common.sh` is allowlisted but I didn't verify it actually still uses `additionalContext`

The §10.5 allowlist excludes `^\.tad/hooks/lib/common\.sh$`. I did not inspect whether common.sh still legitimately references the string (it should — it's the shared hook library and other allowlisted hooks like startup-health.sh consume its `output_response()`). If a future cleanup also removes SessionStart's additionalContext emission, common.sh would also need to drop those references. Out of scope for this review; flagging for the next "remove additionalContext entirely" Epic if it's ever proposed.

### P2 #4 — Smoke test evidence file `perf-P1.4-router.tsv` is dirty in working tree

`git status` shows `.tad/evidence/completions/phase1-state-consistency/perf-P1.4-router.tsv` as modified. Likely Blake re-ran AC-P1.4 to verify the migration. Not a defect — it's expected evidence regeneration. Confirm the regenerated p95 is still < 200ms before commit (Blake should have done this in Layer 1 self-check; flagging in case it slipped).

---

## 6. Overall Assessment

**Verdict**: **PASS** — recommended for Gate 3 acceptance with the documented INTENT-PASS-LITERAL-FAIL caveats on AC8/9/10 (verification command wording, not implementation defects) and the P1 allowlist extension request for §10.5.

**Why PASS despite 3 P1s**:
- All 3 in-scope dangling consumers are functionally migrated and verified end-to-end (30/30 PASS).
- The 3 remaining grep hits all classify as (b) documentation or (c) other-allowlisted-hook test plans, NOT real consumers.
- The byte-symmetric BUSINESS-VALUE-FIRST RULE is content-identical between Alex and Blake — the indent delta is structurally required by host YAML nesting and was the right call (alternative: introduce a 4-space outdented insert in Alex that would break Alex SKILL's YAML parser).
- All 3 P1s are about Alex's AC wording / future-proofing, NOT Blake's implementation. Blake delivered exactly what the handoff text said to deliver.

**Architectural verdict**: This is a clean surgical fix per the "smoke alarm > automatic extinguisher" principle (architecture.md 2026-04-15). Scope was held to the 3 known dangling consumers + the 2 SKILL prose updates, with no scope expansion. The CONSUMER blind spot pattern that caused the original drift (architecture.md 2026-04-27 "Pre-Handoff vs Post-Implementation Reviewer") is now exhaustively scanned and clean.

**Critical follow-up for *publish smoke test (Phase 7)**: Once committed, Phase 7 of release-runbook will run `tail -1 "$project/.tad/hooks/.router.log" | grep -q "web-frontend"`. This depends on the upstream sync having delivered the post-2.8.4 hook. Blake should verify in `*publish` smoke that the seed fixture used to populate `.router.log` actually fires keyword `frontend` (or `react` / `vue`) — otherwise the smoke test will spuriously fail on a brand-new project where `.router.log` doesn't yet exist or contains pack `none`. Recommend the smoke test be amended to pre-seed via a known-good prompt before the assertion. Out of scope for THIS handoff but flagging for the next *publish run.

---

**Reviewer signature**: backend-architect (Layer 2)
**Review duration**: ~25 minutes
**Files inspected**: 5 modified + 3 grep hits + 1 hook source + 1 handoff spec
**Acceptance recommendation to Alex Gate 4**: ACCEPT with note that AC8/9/10 wording be relaxed in §9.1 retroactive and §10.5 allowlist be extended in commit message.
