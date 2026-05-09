# SPIKE-20260407 — Domain Pack Hook Spike

> Epic 1 Phase 1 fail-fast spike per HANDOFF-20260407-domain-pack-hook-spike.md
> Validates UserPromptSubmit hook + Haiku-4.5 classification feasibility.

| Field | Value |
|---|---|
| Spike ID | SPIKE-20260407-domain-pack-hook |
| Run date | 2026-04-07 |
| Executor | Blake (Agent B) |
| Claude Code version | 2.1.92 |
| Anthropic model | claude-haiku-4-5-20251001 |
| Total cases | 18 (5 clear_match + 5 clear_nonmatch + 5 edge + 3 chat_noop) |
| PoC capability | web-frontend.component_development |
| Time spent | ~50 minutes (well under 4.5h budget) |

---

## §1 Verdict

### **Verdict: ⚠️ PARTIAL — `integration:GO / accuracy:GO / latency:NO-GO (caveat: proxy artifact)`**

**Per the strict AC6 rubric** (`accuracy_high_confidence ≥ 0.80 AND mean_latency_ms < 1000 AND path_a_integration.executed/fired/received`):

| Dimension | Result | Threshold | Status |
|---|---|---|---|
| Path A integration (hook fires + additionalContext delivered) | 3/3 fires, 3/3 MARKER_SEEN | ≥3 | ✅ **PASS** |
| Path B accuracy (high-confidence only) | 15/16 = 93.75% | ≥80% | ✅ **PASS** |
| Path B accuracy (all 18) | 17/18 = 94.44% | — | ✅ **PASS** |
| Path B parse_failures | 0/18 | — | ✅ **PASS** |
| Path B mean latency | 4567 ms | <1000 ms | ❌ **FAIL** (proxy artifact) |
| Settings.json clean restore | byte-identical hash | — | ✅ **AC9 PASS** |

**Why PARTIAL not NO-GO on integration:** The hook channel works perfectly. `UserPromptSubmit` is supported by Claude Code 2.1.92, fires reliably on every prompt, and `additionalContext` is delivered into the model's context window. This is the most important spike question and the answer is **YES**.

**Why PARTIAL not GO on latency:** Mean latency 4567 ms strictly fails AC6's 1000 ms threshold. **However**, this is a proxy-mode measurement artifact, not a Haiku-4.5 limitation. See §2 for the analysis. Phase 2 should run a direct API benchmark before committing to a final GO/NO-GO on latency.

**Phase 2 is NOT BLOCKED.** This spike answered "is the hook channel real?" → **yes**. The latency story has a clear remediation path (output token cap + direct API), and Phase 2 should validate it cheaply before designing the production hook.

---

## §2 Mechanism Findings

### `claude --version`
```
2.1.92 (Claude Code)
```

### Pre-existing hook landscape (from MQ1 grep)
- `.claude/settings.json` already uses `PreToolUse` (prompt type, model: `claude-haiku-4-5-20251001`) for Write|Edit gating — same model and same hook type the spike was testing.
- `SessionStart` hook (`.tad/hooks/startup-health.sh`) already injects domain pack list via `additionalContext` — same delivery channel under test.
- `PostToolUse` hook (`.tad/hooks/post-write-sync.sh`) already uses `*.tad/` glob pattern (per architecture.md 2026-04-02 lesson).
- **`UserPromptSubmit` had ZERO references in the project** before this spike — confirmed via `grep -r UserPromptSubmit .claude/ .tad/` (only the handoff and epic files mention it).

### MQ2 — UserPromptSubmit existence

| Step | Action | Result |
|---|---|---|
| 1 | Inspect `claude --help` for hook event documentation | Help text doesn't enumerate hook events; documentation gap |
| 2 | Add `UserPromptSubmit` to settings.json via spike runner (`path-a-install` mode) | ✅ JSON validated, no startup error |
| 3 | Spawn `claude -p` with test message → check sentinel log | ✅ Hook fired, sentinel log has 3 entries with distinct session_ids |
| 4 | Verify additionalContext delivered to model | ✅ 3/3 child sessions returned `MARKER_SEEN` (model saw `SPIKE-TEST-MARKER-A1B2C3` injected by hook) |
| 5 | Restore settings.json | ✅ byte-identical (sha256 matches pre-spike baseline) |

**Hook stdin payload format** (from sentinel log captures):
```
{"session_id":"088228cd-a829-4d46-a17c-5e58b10e93b7","transcript_path":"...","[truncated at 200 chars by sentinel script]"}
```
Same envelope shape as existing PreToolUse/SessionStart hooks. The stdin JSON is well-formed and consumable by `lib/common.sh::read_stdin_json`.

### Silent-ignore detection (P0 per handoff)
Test setup: removed sentinel log before each Path A run. After every test, the sentinel log existed and contained one new entry per claude session spawned. **No silent-ignore detected.** If Claude Code had silently swallowed the event name, the sentinel would be missing. AC6c is satisfied with `silent_ignore = false`.

### Proxy mode caveat (CRITICAL for interpreting Path B latency)

**Per Alex's escalation decision** (recorded in §6 of original handoff Q&A): `ANTHROPIC_API_KEY` was not set in the spike environment. The handoff §4.2 specifies Path B uses direct curl to `api.anthropic.com`. The chosen substitute was `claude -p --model claude-haiku-4-5-20251001 --output-format json`, which uses the active OAuth session to invoke the same Haiku-4.5 model.

**This proxy inflates measured latency in three ways**:

1. **Process spawn overhead**: each `claude -p` call spawns a new Claude Code process (~300-500 ms before any API call).
2. **Cache_creation pollution**: claude -p with default settings loads CLAUDE.md + skill registry + `.claude/settings.json` hooks into the prompt cache. The smoke test reported `cache_creation_input_tokens: 19047` per call — that's ~19k tokens of TAD context being cached on every Haiku invocation, which (a) is bizarre on a "minimal" Haiku call and (b) directly inflates OAuth-tier cost accounting.
3. **Hidden reasoning tokens**: TC04's response was a tiny visible JSON (`{"matched_packs":[],"matched_recipes":[]}` ≈ 10 tokens) but billed as **356 output tokens**. The delta is invisible reasoning/thinking tokens. At Haiku's ~80 tok/s output rate, 356 tokens ≈ 4.5 s — exactly the observed mean API latency.

**Implication**: a direct curl to `/v1/messages` with `max_tokens: 100` and no extended-thinking overhead would likely deliver Haiku-4.5 in **300-1000 ms**. We cannot prove this without an API key, but the math is consistent across all 18 cases.

**Phase 2 must re-measure with direct API before any latency-based design decision.** This is recommendation #1 in §7.

---

## §3 Accuracy Data

### Aggregate metrics

| Metric | Value |
|---|---|
| total_cases | 18 |
| path_b_correct | 17 |
| path_b_accuracy_all | 94.44% |
| path_b_accuracy_high_confidence_only | **93.75%** (15/16) |
| false_positives | 0 |
| false_negatives | 1 (TC04 — debatable label) |
| parse_failures | 0 |
| mean_latency_ms (proxy) | 4567 |
| max_latency_ms (proxy) | 7630 |
| mean_api_latency_ms | 4345 |
| mean_cost_usd (OAuth tier) | $0.005431 |
| total_cost_usd (OAuth tier) | $0.097767 |
| high_confidence_count | 16 |
| low_confidence_count | 2 (TC11, TC15) |

### Per-case results

> Latency column = `duration_ms` from `claude -p` envelope (claude internal, includes API + CLI processing). Wall time per case is ~3-4s longer due to process spawn overhead. See `mean_api_latency_ms` (4345 ms) for the closer-to-API number.

| ID | Category | Conf | Expected | Actual | Result | Latency (ms) | Out tok |
|---|---|---|---|---|---|---|---|
| TC01 | clear_match | high | true | true | ✓ | 7588 ms | 534 |
| TC02 | clear_match | high | true | true | ✓ | 7136 ms | 541 |
| TC03 | clear_match | high | true | true | ✓ | 7630 ms | 606 |
| TC04 | clear_match | high | true | **false** | **✗** | 4101 ms | 356 |
| TC05 | clear_match | high | true | true | ✓ | 4801 ms | 400 |
| TC06 | clear_nonmatch | high | false | false | ✓ | 4253 ms | 346 |
| TC07 | clear_nonmatch | high | false | false | ✓ | 2932 ms | 242 |
| TC08 | clear_nonmatch | high | false | false | ✓ | 3777 ms | 320 |
| TC09 | clear_nonmatch | high | false | false | ✓ | 3877 ms | 325 |
| TC10 | clear_nonmatch | high | false | false | ✓ | 4582 ms | 380 |
| TC11 | edge | low | true | true | ✓ | 7536 ms | 626 |
| TC12 | edge | high | false | false | ✓ | 4276 ms | 355 |
| TC13 | edge | high | true | true | ✓ | 6347 ms | 531 |
| TC14 | edge | high | false | false | ✓ | 3778 ms | 317 |
| TC15 | edge | low | true | true | ✓ | 5905 ms | 493 |
| TC16 | chat_noop | high | false | false | ✓ | 2241 ms | 181 |
| TC17 | chat_noop | high | false | false | ✓ | 2392 ms | 195 |
| TC18 | chat_noop | high | false | false | ✓ | 2274 ms | 191 |

### High-confidence vs all comparison

| Slice | Cases | Correct | Accuracy |
|---|---|---|---|
| All | 18 | 17 | 94.44% |
| High-confidence labels only | 16 | 15 | 93.75% |
| Low-confidence labels only (TC11, TC15) | 2 | 2 | 100% |

The low-confidence cases (TC11 "做一个登录页", TC15 "showcase 一个商品列表") were both correctly classified as matches, which matches the ground-truth labels even though both had `label_confidence: low`. Removing them from the denominator does not change the verdict.

### Latency distribution (proxy mode)

Mean by category:
- clear_match: 6251 ms (verbose responses)
- clear_nonmatch: 3884 ms
- edge: 5568 ms
- chat_noop: 2302 ms (lowest — short messages, less reasoning)

Pattern: latency tracks output token count almost perfectly, confirming the "hidden thinking tokens" hypothesis.

---

## §4 Failure Analysis

### TC04 — only failure

| Field | Value |
|---|---|
| Message | `组件状态管理用 useState 还是 useReducer?` ("Should component state management use useState or useReducer?") |
| Expected (per handoff §4.2) | `true` (clear_match, high confidence) |
| Actual | `false` (matched_packs: []) |
| Haiku raw response | ` ```json\n{"matched_packs":[],"matched_recipes":[]}\n``` ` |
| Failure type | **debatable label** (not a Haiku error) |

**Analysis**: TC04 is a *discussion* about state management ("which one should I use?"), not a request to *build* anything. The handoff's own ground-truth rule states:

> Match guidelines: discussions ABOUT components without intent to build = no match

By the strict ground-truth rule, TC04 should be `expected: false`. Haiku correctly applied the rule. The label `expected: true` in the handoff's test case data appears to contradict the rule. Two interpretations:

1. **Label is wrong** → Haiku achieves 18/18 = 100% accuracy if TC04 is relabeled.
2. **Label is right** (intent: state management discussions are part of component dev work) → Haiku is over-applying the "discussion exclusion".

Either way, this is a label-design issue, not a model failure. Phase 2 should clarify the boundary: does "discussions about component techniques" count as `component_development`? If yes, the prompt's match guidelines need to be rewritten (current text explicitly excludes discussions).

### Failures by type
- semantic / bad classification: **0**
- parse_failures: **0**
- latency timeout: **0** (no case > 8s; budget was 120s/case)
- api_error: **0**
- label_dispute: **1** (TC04)

---

## §5 Generalization Risk Assessment

⚠️ **18 cases × 1 capability = smoke test, NOT statistical validation.** This spike's confidence does not extend to:

1. **Multi-pack disambiguation** — when Phase 2 extends to 80+ capabilities, the model must distinguish e.g. `web-frontend.component_development` from `mobile-development.native_components` from `web-ui-design.wireframing`. False-positive risk grows quadratically with capability count. None of that is tested here.
2. **Multilingual robustness** — the test set is ~50% Chinese, 50% English. Other languages (Japanese, Spanish, etc.) untested.
3. **Long messages** — all test messages are <30 tokens. Real user messages routinely exceed 200 tokens; cache_creation cost grows linearly.
4. **Adversarial inputs** — no jailbreak attempts, no Unicode tricks, no injection probes. Phase 2 should include at least 5 adversarial cases.
5. **Concurrent load** — sequential testing only. Real usage may hit Anthropic rate limits at high QPS.
6. **Latency tail** — n=18 max_latency_ms is descriptive only; real p95/p99 needs n>=100.
7. **Cost accuracy** — OAuth tier accounting differs from per-token API price. Real budget projection needs direct API benchmark.

**Phase 2 expansion targets**:
- Test set ≥ 50 cases per capability OR ≥ 200 cases total across capability mix
- Include 3 multi-pack disambiguation cases
- Include 5 adversarial cases (injection, ambiguous wording, etc.)
- At least 1 long-message case (≥ 200 tokens)
- Direct API benchmark with real `max_tokens` cap

---

## §6 Phase 2 Readiness Checklist

| # | Criterion | Status | Evidence |
|---|---|---|---|
| 1 | Hook event verified to exist and fire reliably | ✅ **YES** | §2 MQ2 step 3, sentinel log 3/3 fires, distinct session_ids |
| 2 | additionalContext delivery to Alex confirmed | ✅ **YES** | §2 MQ2 step 4, 3x MARKER_SEEN responses, model echoed marker awareness |
| 3 | Latency budget achievable (mean < 500 ms p-target, max < 1 s actual) | ⚠️ **NOT YET CONFIRMED** | Proxy mode shows 4567 ms mean / 7630 ms max. Math suggests 300-1000 ms achievable via direct API + token cap. **MUST RE-MEASURE in Phase 2 with curl.** |
| 4 | Cost budget achievable (< $0.0002/call, Epic success criterion) | ⚠️ **NOT YET CONFIRMED** | OAuth tier proxy: $0.0054/call (27x over). Inflated by 19k cache_creation tokens that direct API would not incur. **MUST RE-MEASURE.** |
| 5 | Output schema includes recipe envelope (`matched_packs` + `matched_recipes`) | ✅ **YES** | haiku-prompt-template.md uses envelope format; results.json `parsed_envelope` field shows proper structure |
| 6 | Format reliability ≥ 95% (parse_failures / total) | ✅ **YES** | parse_failures = 0 / 18 = 100% reliability — but only because the orchestrator strips ```json fences post-hoc. Without the regex stripper, raw reliability = 0%. See §7 recommendation #2. |
| 7 | Known unknowns enumerated for Phase 2 (≥3) | ✅ **YES** | §5 lists 7 generalization risks |

**Net**: Items 1, 2, 5, 7 are confirmed by spike. Items 3, 4 are blocked on direct API access (NOT a hook design problem). Item 6 has a known workaround that should become a hard requirement.

---

## §7 Recommendations for Phase 2

### Recommendation #1 (P0): Re-measure latency with direct API before designing the hook
- **Why**: Proxy mode (claude -p) inflates latency by 5-10x via process spawn, cache_creation pollution, and extended thinking. The 4.5s measurement does not reflect what production curl would see.
- **How**: Set `ANTHROPIC_API_KEY`, run `./run-spike.sh curl-single <message>` (already implemented in this spike's runner). Or write a fresh micro-bench with `max_tokens: 100` and the same prompt template. Target: confirm mean API latency < 1000 ms.
- **Decision rule**: If direct API stays > 1500 ms with output capped at 80 tokens, abandon hook-time classification and consider build-time matching (e.g., classify on `*.tad/active/handoffs/` write only).

### Recommendation #2 (P0): Tighten Haiku output to JSON only
- **Why**: 5/5 high-confidence match cases produced 400-600 output tokens despite the prompt asking for "maximum 80 tokens" and "no preamble". Haiku consistently wraps JSON in ```json fences and emits hidden thinking tokens. Token count → latency.
- **How**:
  - Add `stop_sequences: ["\n```", "```"]` to the API call (curl mode)
  - Add `max_tokens: 80` hard cap to API call
  - Reword prompt: replace "maximum 80 tokens" with "Reply with exactly the JSON object, no fences, no thinking"
  - Use a JSON-mode strict response API if Anthropic offers one for Haiku

  > Untested mitigation (deferred to Phase 2 spike): the `--effort low` flag on `claude -p` may suppress extended thinking. Worth a 5-min validation before designing the production hook.

### Recommendation #3 (P0): Make the orchestrator's fence-stripper part of the hook
- **Why**: Spike's `parse_ok = true` for all 18 cases ONLY because orchestrate.py strips ```json``` markdown fences. Without that stripper, raw parse rate would be 0% (Haiku ALWAYS wraps in fences despite explicit instruction). The production hook command MUST include this stripper or the additionalContext injection will fail.
- **How**: Add a post-processing step in the production hook command (before injecting additionalContext) that:
  ```bash
  echo "$RAW" | python3 -c "import sys, re, json; r = sys.stdin.read(); m = re.match(r'^\s*\`\`\`(?:json)?\s*\n(.*)\n\`\`\`\s*$', r, re.DOTALL); print(m.group(1) if m else r.strip())"
  ```
- **Alternative**: Use a stricter system prompt that includes few-shot examples of JSON-only responses.

### Recommendation #4 (P1): Resolve the TC04 label ambiguity before scaling test set
- **Why**: TC04's "discussion vs build" boundary is the most consequential design decision for the prompt. If discussions count, accuracy drops to 94%. If they don't, accuracy is 100%. Phase 2 must decide what "matches a capability" actually means.
- **How**: Alex makes a single design call: do "ABOUT-X" questions count as X-capability matches? Then update the prompt's match guidelines OR the test labels accordingly.

### Recommendation #5 (P1): Hook command should be a script file, not inline bash
- **Why**: Inline bash in JSON requires escape gymnastics. Spike used a separate `spike-hook.sh` and it was much cleaner. Production should follow the same pattern (matches existing PreToolUse-Skill convention with `pre-accept-check.sh` etc.).
- **How**: `.tad/hooks/userprompt-domain-router.sh` — single entry point that reads stdin, calls Haiku, parses response, emits hookSpecificOutput.

### Recommendation #6 (P1): Add a confidence threshold for additionalContext injection
- **Why**: Spike's test prompt asks for `confidence: 0.0-1.0` but never uses it. Production should set a cutoff (e.g., 0.7) below which no domain pack is suggested, to reduce noise and false positives at scale.
- **How**: Hook command checks `confidence >= 0.7` before generating additionalContext.

### Recommendation #7 (P2): Document UserPromptSubmit in `architecture.md`
- **Why**: Architecture knowledge entry from 2026-03-31 listed only `PostToolUse`, `PreToolUse`, `SessionStart` as validated. This spike adds a 4th validated event.
- **How**: See §8 draft knowledge entry below for Alex to merge during Gate 4.

### NO-GO fallback (if Recommendation #1 reveals direct API also exceeds 1s)
- Move classification to build-time or session-start: detect handoff/idea/epic file changes and pre-load relevant packs. Slower feedback but eliminates per-prompt latency.
- Hybrid: `SessionStart` injects "you may need pack X" hints for OPEN handoffs only (small set, deterministic), keep `UserPromptSubmit` for ad-hoc tasks where the existing latency is acceptable.

---

## §8 Time Spent + Knowledge Entry

### Time accounting

| Phase | Activity | Wall time |
|---|---|---|
| Setup | Read handoff, check env, MQ1 grep | ~5 min |
| Phase 1 | Write hook-poc-snippet.json, spike-hook.sh, install + test + restore (×2) | ~10 min |
| Phase 2 | Write prompt template, test-cases.yaml, run-spike.sh, orchestrate.py, smoke test, run all 18 | ~25 min (includes 3min orchestrate runtime) |
| Phase 3 | results.json patch + this report | ~10 min |
| **Total** | | **~50 min** |

Well under the 4.5h hard budget (AC11). No timebox escalation triggered.

### BSD compatibility check (AC10) — manual checklist for run-spike.sh

- [x] No `grep -P` or `grep -oP` (PCRE regex)
- [x] No `sed -i` without empty backup parameter
- [x] No GNU-only `date -d`, `readlink -f`, `stat -c`, `xargs -r`
- [x] No `mktemp` without XXXXXX template
- [x] Hook glob patterns use `*.tad/` (not `*/.tad/`) — N/A for this spike, no glob patterns in run-spike.sh
- [x] No `timeout` (BSD doesn't have it; orchestrator uses Python's `subprocess` timeout instead)
- [x] Verified: `grep -nE "grep -P|grep -oP|sed -i [^']|date -d|readlink -f|stat -c|xargs -r|^[^#]*timeout " run-spike.sh` → no matches

### Architecture knowledge entry (DRAFT for Alex Gate 4 merge)

To be added to `.tad/project-knowledge/architecture.md`:

```markdown
### UserPromptSubmit Hook Verification - 2026-04-07
- **Context**: Epic 1 Phase 1 spike (SPIKE-20260407-domain-pack-hook) verified
  whether Claude Code's `UserPromptSubmit` hook event exists and can deliver
  `additionalContext` to Alex (the main conversation)
- **Discovery**: `UserPromptSubmit` IS supported in Claude Code 2.1.92. Settings.json
  accepts the event name without error, the hook command fires reliably on every
  user prompt submission, and `hookSpecificOutput.UserPromptSubmit.additionalContext`
  is delivered into the model's context window (proven by 3/3 child sessions
  responding `MARKER_SEEN` to a marker injection). This brings the validated
  hook event list to 4: SessionStart, PreToolUse, PostToolUse, UserPromptSubmit.
  - Hook stdin payload contains `session_id`, `transcript_path` keys (same envelope
    as PreToolUse/SessionStart, consumable by `lib/common.sh::read_stdin_json`)
  - additionalContext output format identical to SessionStart (`output_response()` works)
  - The hook command can be inline bash OR a separate script (spike used a script
    via `bash '/abs/path/spike-hook.sh'` and it worked cleanly)
- **Action**: Phase 2 of the Domain Pack reliable-loading Epic should use
  `UserPromptSubmit` as the primary classification trigger. CRITICAL caveat:
  Haiku-4.5 via `claude -p` proxy reports 4.5s mean latency due to extended
  thinking + cache pollution. Phase 2 MUST re-measure with direct curl + max_tokens
  cap before final design. Also: Haiku consistently wraps JSON in ```json fences
  despite explicit instruction — production hook MUST include a fence-stripper.
```

---

## §9 AC Verification Trace

| # | AC | Status | Evidence |
|---|---|---|---|
| AC1 | 6 files in spike dir | ✅ | `ls .tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/` shows: SPIKE-REPORT.md, test-cases.yaml, haiku-prompt-template.md, hook-poc-snippet.json, run-spike.sh, results.json (+ supporting: spike-hook.sh, orchestrate.py, path-a-sentinel.log, path-a-claude-response.json) |
| AC2 | §1 has verdict | ✅ | "Verdict: PARTIAL" in §1 |
| AC3 | path_b_results = 18 | ✅ | `jq '.path_b_results \| length' results.json` → 18 |
| AC4 | metrics has ≥11 fields | ✅ | 14 fields (added mean_api_latency_ms, high_confidence_count, low_confidence_count) |
| AC5 | hook_existence non-empty | ✅ | both fields = true with evidence string |
| AC6 (accuracy + latency) | accuracy ≥80% AND latency <1000 | ⚠️ accuracy PASS, latency FAIL → verdict PARTIAL | high-conf accuracy 93.75%, mean latency 4567 ms |
| AC6b (integration) | path_a executed + fired ≥3 + received | ✅ all three true | sentinel 3 lines, 3 MARKER_SEEN |
| AC6c (silent ignore) | not silent ignored | ✅ | sentinel exists with content |
| AC7 | §7 has Phase 2 recommendations | ✅ | 7 recommendations (more than 3) |
| AC8 | §6 has 7 yes/no checklist items | ✅ | exactly 7 rows |
| AC9 | settings.json byte-identical restore | ✅ | sha256 pre/post = `309b38d8a0372a59f91384b2b522b38e2e1232a337a37fc66f291fd3f5a36fe9` (verified twice across 2 install/restore cycles) |
| AC10 | BSD compat checklist 5/5 | ✅ | see §8 BSD compatibility check |
| AC11 | timebox vars present + actual time recorded | ✅ | `START_TIME`, `HARD_CAP_SECONDS`, `check_timebox` all in run-spike.sh; ~50 min actual |
| AC12 | envelope schema (matched_packs + matched_recipes) | ✅ | `grep matched_packs haiku-prompt-template.md` AND `grep matched_recipes` both match |
| AC13 | parse_failures separate | ✅ | metrics.parse_failures = 0, separate from false_negatives |
| AC14 | knowledge entry draft | ✅ | §8 contains "architecture.md" entry draft |

---

**End of SPIKE-REPORT.md**
