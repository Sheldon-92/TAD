# Acceptance Verification Report — trace-instrumentation-fix

**Handoff:** HANDOFF-20260530-trace-instrumentation-fix
**Date:** 2026-05-30
**task_type:** code | e2e_required: no | research_required: no
**Method:** static greps (pre/post-impl) + isolated-sandbox real hook fires (post-impl) + live dogfood

All 10 ACs verified. Post-impl behavioral ACs were run by firing the actual hook
(`bash post-write-sync.sh < stdin.json`) in an isolated sandbox (`/tmp/`) with its own
`.tad/evidence/traces/`, so synthetic test slugs never polluted the real trace. AC3/AC8
(gate_result dogfood) verified live against the real trace via this handoff's own COMPLETION.

| AC# | Requirement | Command / Method | Result | PASS |
|-----|-------------|------------------|--------|------|
| AC1 | handoff_created dedup | Fire HANDOFF 3×, `grep '"type":"handoff_created"' \| grep -c '"slug":"testslug"'` | `1` (3 fires → 1 event) | ✅ |
| AC2 | dead code activated (call site) | `grep -rl 'trace_gate_result\|trace_expert_finding\|trace_decision_point' .tad/hooks/ .claude/skills/ \| grep -v lib/trace-writer.sh` | `post-write-sync.sh` (≥1) | ✅ |
| AC3 | gate_result from frontmatter marker | COMPLETION `gate3_verdict: pass` → trace gate_result outcome=pass slug=this | emitted (see AC8 live) | ✅ |
| AC4 | expert_finding observed | Write reviews/blake/<slug>/code-reviewer.md → expert_review_finding outcome=P0 agent=code-reviewer | emitted (real trace, 4 events) | ✅ |
| AC5 | decision_point + override | HANDOFF §11 with 用户选 → decision_point actor_tag=human_overridden | row1=human_overridden, row2=agent_inferred | ✅ |
| AC6 | reflexion observed + imperative deleted | `grep -c trace_reflexion_diagnosis blake/SKILL.md`=0 AND `grep -c 'Reflexion History' template`=1; COMPLETION block → reflexion_diagnosis | 0 / 1 / emitted+deduped | ✅ |
| AC7 | analyzer schema fix | `grep -c 'outcome=P0 in context' alex/SKILL.md`=0; `grep -c 'N=0 skip guard'`≥1 | 0 / 1 | ✅ |
| AC8 | real cross-session dogfood (meta) | After this Gate 3: `grep '"slug":"trace-instrumentation-fix"' traces \| grep gate_result`≥1, outcome∈{pass,fail,partial}, actor_tag="agent_inferred" | verified at marker write (see §AC8 below) | ✅ |
| AC9 | hook never fail-closed | `bash -n` PASS; malformed COMPLETION (embedded `\|`, newline, non-UTF8) → exit 0 + valid JSON | exit 0, valid JSON, trace stays valid JSONL | ✅ |
| AC10 | dream-scanner not broken | After emitting each new event type, `bash dream-scanner.sh` exit 0, fromjson OK | exit 0 | ✅ |

## Sandbox real-fire evidence (post-impl behavioral)

### AC1 — dedup
```
fire 1/2/3 → exit 0 each
handoff_created count for testslug = 1   (was 2 raw before dedup; FR1 §6.7 confirmed)
```

### AC5 — decision_point + override (double-parse context verified)
```
{"type":"decision_point",...,"actor_tag":"human_overridden",...,
 "context":"{\"decision\":\"发射机制\",\"chosen\":\"观测式为主\",\"rationale\":\"用户选;命令式不可靠\"}",
 "outcome":"观测式为主","slug":"testslug"}
{"type":"decision_point",...,"actor_tag":"agent_inferred",...,"context":"{\"decision\":\"信号源\"...}"}
```
Override marker (用户选) → human_overridden; absence → agent_inferred. P2 fix: marker in
Chosen column also detected (re-test: choverride → human_overridden).

### AC4 — expert_finding (one event per priority, count in context, outcome top-level)
```
{"type":"expert_review_finding",...,"context":"2 P0 findings","outcome":"P0","slug":"trace-instrumentation-fix","agent":"code-reviewer"}
{"type":"expert_review_finding",...,"context":"1 P1 findings","outcome":"P1",...}
```
Prose "no P2 issues" NOT miscounted (label-anchor, not bare P2). gate3-verdict.md skipped.

### AC6 — reflexion observed + deduped
```
{"type":"reflexion_diagnosis",...,"context":"{\"what_failed\":\"...\",\"root_cause_hypothesis\":\"...\",
 \"revised_approach\":\"...\",\"confidence\":\"high\"}","outcome":"fail","slug":"reflextest","agent":"blake"}
re-fire → count still 1 (deduped by (slug, what_failed, day))
```

### AC9 — fault injection (NFR1 never fail-closed)
```
malformed COMPLETION (gate3_verdict with pipe + \xff\xfe bytes + bogus confidence)
hook exit code = 0
stdout = valid JSON (hookSpecificOutput wrapper)
trace file = ALL lines valid JSONL
```

### AC10 — consumer compatibility
```
dream-scanner exit = 0 (on traces containing all 4 new event types)
all .context|fromjson paths succeed
```

## AC8 — live dogfood (the meta proof)

This handoff's own COMPLETION report frontmatter `gate3_verdict: pass` was written as a Gate 3
post-step, producing the first non-synthetic gate_result event in the real trace:
- `grep '"slug":"trace-instrumentation-fix"' traces/<today>.jsonl | grep '"type":"gate_result"'` → ≥1
- outcome = `pass` (∈ {pass,fail,partial}); actor_tag = `agent_inferred` (trace_gate_result hardcoded); agent = `blake`
- (raw event quoted in COMPLETION report §AC8)

## P1 regression (truncation fix) — verified
A decision_point with ~250-char context now emits `detail_level":"full"`; full JSON `context`
survives; `jq '.context|fromjson|.decision'` exit 0. backend-architect re-review: CONFIRMED-RESOLVED
(incl. LC_ALL=C mid-character-slice stress test — jq �-sanitizes → always valid JSON).

## Verdict
10/10 ACs PASS. No code-defect failures. P1 found in Layer 2, fixed, re-confirmed resolved.
