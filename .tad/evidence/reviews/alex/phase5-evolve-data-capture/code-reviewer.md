# Code-Reviewer Review: HANDOFF-20260425-phase5-evolve-data-capture

**Reviewer**: code-reviewer (Alex pre-Blake review)
**Date**: 2026-04-25
**Handoff**: `.tad/active/handoffs/HANDOFF-20260425-phase5-evolve-data-capture.md`
**Scope**: Code-level correctness + macOS BSD portability + Anti-Epic-1 compliance + AC verifiability
**Verdict (preview)**: **CONDITIONAL PASS** — 5 P0 must be fixed before sending to Blake.

---

## P0 Findings

### [P0-1] AskUserQuestion stdin envelope field names are unverified guesses — Blake has no contract to validate against

- **Where**: §3 FR2 (line 236), §10.2 line 728 ("AskUserQuestion stdin envelope schema 是 Anthropic 内部 API；`tool_input.questions` 和 `tool_response.answers` 字段名以实际 invocation 为准（Blake fixture 验证）")
- **Why blocks Blake**: The handoff itself admits the field names are guesses. Blake will write `askuser-capture.sh` using `tool_input.questions[].question`, `options[].label`, `tool_response.answers` — but no spike artifact, no `claude -p` probe log, and no reference to a known invocation envelope is cited. There is precedent in `.tad/project-knowledge/architecture.md` for envelopes to surprise (UserPromptSubmit `prompt` field discovery 2026-04-07 was contrary to assumption that `$ARGUMENTS` was used). If field names are wrong, ALL 5 fixtures pass against synthetic JSON but production produces zero data, AND the `is_other` privacy flag depends on a sub-field path Blake is guessing. This is the same failure mode that wasted Phase 2a 45 minutes.
- **Fix**: Add a §0 spike step BEFORE Stage A: "Blake MUST first run a 5-line probe hook (`cat > /tmp/askuser-envelope-$(date +%s).json`) registered as `PostToolUse` matcher `AskUserQuestion`, trigger one AskUserQuestion via `claude -p --settings ... --tools '' --permission-mode default`, and inspect the captured JSON to confirm field paths. Update §3 FR2 schema doc inline with confirmed paths before writing askuser-capture.sh." Also: add a new AC-P5.2-f: "Probe envelope file exists at `.tad/evidence/fixtures/phase5/askuser-envelope-probe.json` and contains `tool_input.questions` (or whatever path Blake confirmed); fixtures MUST mirror probe shape exactly."

### [P0-2] AC-P5.3-c `awk` range pattern is broken — anchor matches start AND end on the same line

- **Where**: §9.2 row 4 / line 650, AC-P5.3-c verification command: `awk '/cancel_protocol:/,/^[a-z_]+_protocol:/' | grep -cE 'pivoted|obsolete|superseded|scope-change'`
- **Why blocks Blake**: I tested this empirically. The awk range `/cancel_protocol:/, /^[a-z_]+_protocol:/` opens on line `cancel_protocol:` AND closes on the SAME line because `^[a-z_]+_protocol:` matches `cancel_protocol:` itself. The range yields 1 line (just the header), grep finds 0 matches, AC reports `= 0` not `= 4` — a passing implementation will FAIL this AC. Confirmed via shell test: `printf 'cancel_protocol:\n  - pivoted\n  - obsolete\nother_protocol:\n' | awk '/cancel_protocol:/,/^[a-z_]+_protocol:/'` outputs only the header line.
- **Fix**: Replace the awk command with the standard "skip-start-anchor" pattern. Change line 650 from:
  ```
  | `grep -B 0 -A 5 '^cancel_reason:' .tad/templates/handoff-a-to-b.md \| grep -cE 'pivoted\|obsolete\|superseded\|scope-change'` | = 4 |
  ```
  …wait, that's row 3. The actual broken row is AC-P5.3-c text in §9.1 (line 616). Change the AC-P5.3-c verification to:
  ```
  awk '/^cancel_protocol:/{flag=1;next} flag && /^[a-z_]+_protocol:/{flag=0} flag' .claude/skills/alex/SKILL.md | grep -cE 'pivoted|obsolete|superseded|scope-change'
  ```
  Expected: `= 4`. Add to §9.2 as a new row replacing the inferred verification.

### [P0-3] AC-G2 grep pattern uses `\|` (literal pipe) instead of `|` (BRE alternation) — passes for any value of exit code

- **Where**: §9.1 AC-G2 (line 639): `grep -rEn 'exit 1\|exit 2\|exit [0-9]+' .tad/hooks/lib/askuser-capture.sh`
- **Why blocks Blake**: Inside single quotes, `\|` is two literal characters: backslash + pipe. With `-E` (ERE), `\|` matches a literal `|`, NOT alternation. So this pattern matches lines containing the LITERAL string `exit 1|exit 2|exit ` followed by a digit — which never occurs in shell script source. The grep returns nothing (exit 1) and "ONLY exit 0" can never be verified. Blake could ship `exit 1` everywhere and AC-G2 would still appear to "pass" (because `set -e` style scripts use `exit 0` only at the end and the grep matches nothing, which the AC operator may falsely accept as "no nonzero exits found"). The same `\|` mistake repeats in §9.2 row 3 (AC-P5.3-a verification): `grep -cE 'pivoted\|obsolete\|superseded\|scope-change'` — but that one is checking a comment line that DOES contain literal `|` separators, so by accident it works. The pattern is NOT consistent and Blake won't know which is intended.
- **Fix**: In §9.1 AC-G2, change `'exit 1\|exit 2\|exit [0-9]+'` to `'exit [0-9]+'` and re-spec as: "every `exit N` occurrence where N != 0 must be absent. Verification: `grep -nE '^[[:space:]]*exit [0-9]+' .tad/hooks/lib/askuser-capture.sh | grep -vE '^[^:]+:[0-9]+:[[:space:]]*exit 0[[:space:]]*$'` returns no lines (exit 1)." In §9.2 row 3 (AC-P5.3-a verification, line 649), change `grep -cE 'pivoted\|obsolete\|superseded\|scope-change'` to `grep -cE 'pivoted|obsolete|superseded|scope-change'` (remove the backslashes). Apply the same audit to ALL §9.2 rows containing `\|` — multiple rows are affected.

### [P0-4] P5.5 YAML dict conversion has unspecified consumer-compat scope — `EC4` admits a known consumer breaks but no remediation specified

- **Where**: §3 FR5 (line 260), §6.1 micro-task #10 (line 451), §8.3 EC4 (line 593), §10.1 line 720
- **Why blocks Blake**: I grep'd all consumers of `quality_criteria`. There is direct evidence in `.tad/evidence/reviews/blake/phase4-domain-pack-expansion/code-reviewer.md` line 124 that consumers use `yq '.capabilities.X.quality_criteria'` and a consumer "scans `quality_criteria` across all capabilities" — meaning at least one Phase 4 reviewer-recorded consumer pattern iterates the list assuming all entries are strings. Converting ONE entry from string to dict means: (a) `yq '.quality_criteria[]'` still returns it (as a dict literal), (b) `select(. | test("..."))` with regex on a dict raises a yq error or returns null silently depending on version, (c) `select(.pattern? == "...")` (the verification command in §6.1) only works for the dict-form entry and silently misses string-form entries. The handoff says "Blake needs grep all `quality_criteria` usage points confirm dict-aware" — but Blake's grep should NOT be a Blake job; Alex must list known consumers. The known consumers from my grep: the verification commands in archived HANDOFF-20260425-phase4-domain-pack-expansion.md lines 287, 291 use `yq '...quality_criteria[] | select(. | contains("15K"))'` — `contains` on a dict will throw or mis-match. Phase 4 archived ACs themselves will retroactively break.
- **Fix**: Either (a) DOWNGRADE FR5 to "append the `applies_when` info as a separate dict-form entry and KEEP the original string entry verbatim alongside it" — backward compat preserved, mild duplication acceptable; OR (b) change FR5 to require Blake to also patch ALL identified consumer call-sites (and list them explicitly: archived HANDOFF-20260425-phase4-domain-pack-expansion.md lines 287/291 verification commands; any future tools planned to iterate `quality_criteria`). Add explicit consumer manifest to §10.2 Known Constraints. My recommendation is (a) because it has zero downstream blast radius. New AC: "AC-P5.5-b: web-backend.yaml line 108 original string content is preserved verbatim somewhere in the file (whether as string entry or as `pattern:` value of a dict entry) — verifiable via `grep -F 'every realtime channel name MUST embed a per-instance UUID' .tad/domains/web-backend.yaml` returns ≥1."

### [P0-5] Order invariant in P5.7 is not enforceable when §10.3 sub-agent suggestions allow parallel-coordinator

- **Where**: §6.2 Stage C (lines 484-488) "Order invariant: First create frontend-design.md (Micro-Task 13) Then delete Warm Palette (Micro-Task 12)", AND §10.3 line 734 "[x] **parallel-coordinator** — Stage A/B/C 之间相对独立，可并行"
- **Why blocks Blake**: The handoff EXPLICITLY allows parallel-coordinator across stages, then EXPLICITLY requires sequencing within Stage C. If Blake parallelizes Stage C tasks via sub-agent calls, two Edit calls go out concurrently — there is no guarantee Micro-Task 13 (Write frontend-design.md) completes before Micro-Task 12 (Edit web-ui-design.yaml). The "no-home-commit-window" warning in §10.1 line 719 is a real hazard if a Gate 3 commit happens between them. Note also: Stage C lists the Micro-Tasks in NUMBER order (10, 11, 13-then-12, 14) which is confusing because the linear "Stage C" reading order suggests 10→11→13→12→14 but a casual scan sees "10,11,12,13,14" and misses the 13-before-12 swap.
- **Fix**: Two changes. (1) §10.3 sub-agent suggestion: change `[x] parallel-coordinator` to `[ ] parallel-coordinator — NOT recommended for Stage C due to P5.7 order invariant; sequential within Stage C is required.` (2) §6.2 Stage C: renumber the steps so the linear order matches execution order. Change to: "10. Edit web-backend.yaml UUID Pub/Sub (Micro-Task 10). 11. Edit web-ui-design.yaml ADR re-anchor (Micro-Task 11). **12a. (Order invariant)** Create frontend-design.md (Micro-Task 13). **12b. (Order invariant)** Delete Warm Palette from web-ui-design.yaml (Micro-Task 12). 13. Edit project-knowledge/README.md (Micro-Task 14)." Also add to §10.1: "⚠️ Even if parallel-coordinator is invoked across Stages A/B/C, Stage C MUST run all 5 micro-tasks in a single sequential agent (NOT parallel)."

---

## P1 Findings

### [P1-1] `cancel_reason: ""` empty string default may fail Alex SKILL pattern-match logic when `*cancel` is invoked

- **Where**: §3 FR3 (line 242), Micro-Task 1 (line 442)
- **Why**: Empty-string default `cancel_reason: ""` means EVERY non-cancelled handoff has the field present with empty value. Alex SKILL `*cancel` flow needs to populate this field; if the SKILL grep checks `^cancel_reason:` to verify cancel was invoked, EVERY handoff matches. Better default is field absent (omit from template) OR `cancel_reason: null` so a non-empty value is the unambiguous "this is cancelled" signal. Backward compat for archived handoffs without the field is also a concern: Alex SKILL must explicitly handle "field absent → not cancelled" (same pattern as `skip_knowledge_assessment` field-absent fallback at SKILL.md line 2325).
- **Fix**: Change Micro-Task 1 to: "Add `gate4_delta: []` (empty list default OK). For `cancel_reason` and `cancel_rationale`: Do NOT add to template by default. Document in template comment: `# Optional — added only when *cancel is invoked. cancel_reason: <pivoted | obsolete | superseded | scope-change>; cancel_rationale: <one-line>`. Alex `*cancel` SKILL writes these fields only at cancel time; field absent = not cancelled."

### [P1-2] §6.2 Stage A insertion points for step4d / step7d are not pinpointed — Blake may misplace

- **Where**: §6.2 Stage A items 2 & 4 (lines 472, 475), Micro-Tasks 2 + 9 (lines 443, 450)
- **Why**: Alex SKILL.md acceptance_protocol is 200+ lines (line 2226-2445). step7 has SEVEN sub-blocks (`pre_check`, `branch_1_skip_no_override`, `branch_2_skip_with_override`, `branch_3_no_skip`, `A_verify_blake_claims`, `B_raw_tsv_recompute`, `C_alex_own_discoveries`, `separation_of_concerns`, `forbidden_implementations`). The handoff says "add step7d" — but where exactly? Before `branch_1`? After `forbidden_implementations`? After `step8`? Same issue for step4d: between step4c (line 2305) and step5 (line 2307), or after step5? Blake will guess and may place step4d between step4 and step4b (before Layer 2 audit), which violates the handoff's "advisory after Layer 2" intent.
- **Fix**: Add to §6 a new sub-section "6.6 Insertion Point Map" with explicit anchors:
  ```
  step4d: insert AFTER step4c (Layer 2 audit) and BEFORE step5 (业务检查).
          The new step4d block lives at SKILL.md ~line 2306 (between current line 2305 `blocking: false` of step4c and line 2307 `step5:`).
  step7d: insert AFTER step7's `forbidden_implementations` block (currently SKILL.md ~line 2427)
          and BEFORE step7b (~line 2428). Sibling key at the same indent level as step7/step8.
  cancel_protocol: insert as a NEW top-level protocol block AFTER acceptance_protocol's
          last line (currently `gate4_v2_checklist:`, ~line 2470 — Blake should grep for the next
          top-level protocol after acceptance_protocol to confirm). Same indent as acceptance_protocol.
  *cancel command entry: insert in the commands_list at SKILL.md line ~30-50 (Blake to find
          and add as sibling to *bug, *discuss, *idea, etc).
  ```

### [P1-3] AC-P5.4-d is "All 7 fixtures PASS" but §8.1 only enumerates 5+5+2=12 fixtures, not 7

- **Where**: §9.1 AC-P5.4-d (line 627): "All 7 trace-digest + trace-step fixtures PASS"; §8.1 lists 5 trace-digest + 2 trace-step dual-write = 7 (not counting the 5 askuser fixtures from a separate AC). Actually re-counting: §8.1 trace-digest fixtures = 5 (lines 567-571), trace-step dual-write fixtures = 2 (lines 573-575). 5+2 = 7. So the count IS correct, but the wording groups them confusingly.
- **Why**: Mild — the AC-P5.4-d wording "trace-digest + trace-step fixtures" is correct but reads ambiguously. A careful reader counts and confirms; a less careful reader sees "5 fixtures" mentioned and thinks AC-P5.4-d is wrong.
- **Fix**: Change AC-P5.4-d (line 627) to: "All 7 fixtures PASS: 5 trace-digest fixtures (`fixture-clean-slug`, `fixture-orphan-slug`, `fixture-failed-slug`, `fixture-missing-slug`, `fixture-invalid-slug`) AND 2 trace-step dual-write fixtures (`with-TAD_HANDOFF_SLUG`, `without-TAD_HANDOFF_SLUG`). Verifiable via `bash .tad/evidence/fixtures/phase5/trace-digest-test.sh && bash .tad/evidence/fixtures/phase5/trace-step-test.sh` — both exit 0 with all 7 PASS markers."

### [P1-4] AC-P5.2-d perf bench methodology stub `awk -F$'\t' 'NR>1{a[NR]=$2}END{...median+p95...}'` has literal "..." that won't run

- **Where**: §9.2 row 8 / line 654: `bash .tad/evidence/fixtures/phase5/askuser-bench.sh \| awk -F$'\t' 'NR>1{a[NR]=$2}END{...median+p95...}'`
- **Why**: The `{...median+p95...}` is a placeholder that will literally fail awk parsing if Blake copy-pastes. The lesson at architecture.md 2026-04-14 ("Hook Latency Measurement: Never Use python3 for Per-Step Timing") explicitly says use `perl -MTime::HiRes`. The handoff §Project Knowledge item 5 (line 162) cites this lesson but the verification command doesn't reflect it.
- **Fix**: Replace §9.2 row 8 with a complete one-liner. Recommendation: "Bench script timestamps with `perl -MTime::HiRes=time -E 'printf \"%.3f\\n\", time'` before & after each invocation, writes TSV `iter\tduration_ms`, runs N=100. Verification: `awk -F'\\t' 'NR>1{n++; a[n]=$2} END{ asort(a); printf \"median=%.0f p95=%.0f\\n\", a[int(n*0.5)], a[int(n*0.95)] }' .tad/evidence/fixtures/phase5/askuser-latency-N100.tsv` — output median<50 AND p95<100." Also: add an `askuser-bench.sh` script spec to §6.1 as a new micro-task (currently the bench script is mentioned only in §9.2 with no creation spec).

### [P1-5] AC-G4 has fuzzy "discovery criteria" — when does Blake know there's a finding worth recording?

- **Where**: §9.1 AC-G4 (line 641)
- **Why**: AC-G4 says ≥1 NEW entry to architecture.md is required, but doesn't specify what counts as a finding. Blake could pad with low-signal entries to satisfy the AC, OR genuinely have no finding and feel pressured to invent one. The Phase 1c "AC Conflict Matrix" lesson (2026-04-14) is relevant: an AC that requires discovery without specifying when discovery is justified creates pressure to invent. Compare with the existing TAD pattern where discoveries are honest opt-in.
- **Fix**: Change AC-G4 to a CONDITIONAL requirement: "If Blake's implementation surfaced any of the following: (a) a portability surprise (e.g., BSD vs GNU divergence not previously documented), (b) a hook envelope field path that differed from the handoff's guess, (c) a measurement methodology pitfall, (d) a YAML consumer that broke unexpectedly during P5.5 conversion — THEN ≥1 NEW entry MUST be added under `### .* - 2026-04-25` in architecture.md. If NONE of these surfaced, write a one-line note in COMPLETION-{slug}.md: 'No new architecture findings — implementation matched handoff spec.' Verifiable via `git diff .tad/project-knowledge/architecture.md` showing N>0 OR completion report containing the no-finding note."

---

## P2 Findings

### [P2-1] §10.3 marks `[x] parallel-coordinator` for Stages A/B/C — but Stage A is 4 sequential SKILL.md edits

- **Where**: §10.3 line 734
- **Why**: Stage A (4 edits to SKILL.md and template) needs sequential edits because all 4 modify the same file; parallel write conflicts are likely. Acknowledged in same line ("Stage A SKILL.md 多个 step 修改建议 sequential") but the `[x]` checkbox is on the wrong row — paint as "selected for use" while text says "sequential". Mild contradiction.
- **Fix**: Move the `[x]` marker to a new line and clarify: `[x] **parallel-coordinator** — Stage B/C parallel OK between hooks. NOT recommended within Stage A (same-file conflicts) or within Stage C (P5.7 order invariant).`

### [P2-2] FR2 schema doesn't specify timestamp format precision

- **Where**: §3 FR2 (line 238) shows `"ts":"2026-04-25T...Z"` but doesn't say second/ms/ns precision
- **Why**: trace-step.sh uses `%Y-%m-%dT%H:%M:%SZ` (second precision). For consistency with existing trace, askuser-capture.sh should use the same. Without a spec, Blake might choose ms precision (`+%Y-%m-%dT%H:%M:%S.%3NZ` GNU-only — `%3N` is NOT BSD portable; macOS `date` has no ms support).
- **Fix**: Add to §3 FR2: "Timestamp format: `date -u +%Y-%m-%dT%H:%M:%SZ` (matches trace-step.sh format; second precision is sufficient for *evolve aggregation; ms precision NOT needed and macOS `date` cannot produce it without `gdate`)."

### [P2-3] §6.5 Grounded Against omits the cancel-protocol target file (Alex SKILL.md commands list area)

- **Where**: §6.5 line 535 lists `.claude/skills/alex/SKILL.md acceptance_protocol section` but not the commands_list area where `*cancel` will be added
- **Why**: Blake needs a confirmed location to add the `*cancel` command entry (sibling to *bug, *discuss, etc). §6.5 only confirms acceptance_protocol was read. The commands_list is at SKILL.md lines ~30-50 area but Blake doesn't have grounded confirmation.
- **Fix**: Add to §6.5: "`.claude/skills/alex/SKILL.md` commands_list section (lines ~30-50, read at 2026-04-25 — confirmed *bug/*discuss/*idea/*learn/*express/*experiment/*publish/*sync/*analyze entries; *cancel will be added as sibling)."

### [P2-4] EC1 (P5.2 hook recursion risk) is reassuring but doesn't say what happens if PostToolUse on AskUserQuestion takes >timeout

- **Where**: §8.3 EC1 (line 590)
- **Why**: PostToolUse hooks have implicit timeouts (Claude Code may kill long-running hooks). With the 100ms p95 budget, normal case is fine, but jq cold-start on a slow host could spike to 200ms. No edge case for "hook timed out, JSONL write incomplete".
- **Fix**: Add to §8.3: "EC5: If askuser-capture.sh exceeds its implicit timeout (configurable in settings.json `timeout` field), Claude Code will kill the process. Mitigation: write to a tmpfile + `mv` (atomic) so a half-written JSONL line never appears in `decisions/{date}.jsonl`. Test: simulate by injecting `sleep 5` in fixture run, confirm the date file is unchanged after kill."

---

## Overall Assessment

**Verdict**: **CONDITIONAL PASS**

The handoff has solid architecture, references all the right historical lessons (11 entries from architecture.md cited and applied), has a thorough §5 MQ section, and Anti-Epic-1 discipline is consistently maintained throughout. The §6.5 Grounded Against table is exemplary (specific timestamps + line ranges).

However, **5 P0 findings must be fixed** before this can go to Blake:

1. **P0-1 (envelope field name guess)** — without a probe spike, the entire P5.2 deliverable risks shipping a hook that runs but produces wrong-shaped data
2. **P0-2 (broken awk range AC)** — AC-P5.3-c will report failure for any correct implementation
3. **P0-3 (literal pipe in grep `\|`)** — AC-G2 verification is meaningless; same bug repeats in §9.2 multiple rows
4. **P0-4 (YAML dict consumer compat)** — known Phase 4 archived consumers will silently break; recommend keeping original string entry alongside dict
5. **P0-5 (parallel-coordinator vs order invariant)** — explicit contradiction between §6.2 ordering and §10.3 sub-agent suggestion

The 5 P1 findings are "should fix" — implementation will likely succeed but with avoidable confusion. The 4 P2 findings are minor polish.

**Recommendation**: Apply P0-1 through P0-5 fixes, then proceed to Gate 2 PASS. P1/P2 can be folded in opportunistically.

**Estimated fix time**: ~30 minutes for P0 fixes (mostly text edits to §6.2, §9.1, §9.2, §3 FR2 + adding §6.6 and §0 spike step).
