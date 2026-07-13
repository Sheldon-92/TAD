# Phase 2 Behavioral Evidence (FR6 / AC5 / AC6)

- **Date**: 2026-07-13
- **CLI**: 2.1.172 (Claude Code)
- **Spike basis**: `.tad/evidence/spikes/subagent-frontmatter-2026-07/spike-report.md` (VERDICT-memory: FAIL, VERDICT-skills: FAIL, VERDICT-shadowing: PASS)

SPAWN-METHOD: every spawn below is an independent headless CLI session — `claude -p --agent <name> "<prompt>"` (or prompt via stdin) executed from the repo root; no session reuse, no `--continue`/`--resume`, so no conversation memory can leak between runs. Prompts for later runs never contained earlier runs' text.

---

## AC6 — Skills preload behavioral test (EXECUTED, result FAIL)

The test defined by FR6 WAS executed (during the spike, on the spike agent carrying `skills: [code-security]` — list form per handoff §4.3). Tools were hard-banned via `--disallowedTools "Read,Bash,Grep,Glob,WebFetch,WebSearch"`.

Prompt: "Is the content of a skill or capability pack named 'code-security' already present in your context right now (system prompt or preloaded)? If yes, quote 3 specific concrete rules from it verbatim (e.g. tool names, exit codes, gate ordering). If it is NOT in your context, reply exactly: NO-PRELOADED-SKILLS"

Raw transcript output:

```
NO-PRELOADED-SKILLS
```

Comparison baseline (pack SKILL.md really contains quotable, distinctive rules the agent produced zero of): Four-Gate fastest-fail-first pipeline (pre-commit <10s → PR ~10s-1min → full CI → runtime DAST), TruffleHog exit 183 / Semgrep exit 1 contract, S1-S8/D1-D7/V1-V7 rule indices.

Follow-up nuance probe (no tool ban needed — pure introspection): "List the names of any skills your configuration says are available or attached to you specifically — or reply NO-ATTACHED-SKILLS." → `NO-ATTACHED-SKILLS` ("My system prompt contains no list of skills assigned or attached to me.").

SKILLS-PRELOAD: FAIL

Per §9.1 AC6 note (skills VERDICT=FAIL) this row is recorded NOT_APPLICABLE_WITH_REASON for Gate 3: the preload mechanism does not exist on CLI 2.1.172; `security-auditor ← code-security` static pairing NOT delivered; handoff transcription status quo (Blake SKILL 1_5a) retained unchanged (see AC9). Escalated in completion report §Escalations.

---

## AC5 — Memory three-run recall test (NOT RUNNABLE — mechanism absent)

The three-run canary protocol (RUN0 negative control / RUN1 store / RUN2 recall, canary `TAD-QK7`) requires a persistent agent-memory mechanism to test. The spike established (two value forms, system-prompt introspection, filesystem check) that the `memory` frontmatter field is inert on CLI 2.1.172: no memory directory is created (`~/.claude/agent-memory` and `<repo>/.claude/agent-memory` do not exist), nothing is injected into the agent system prompt.

Running RUN1/RUN2 against a nonexistent mechanism can only produce either (a) a guaranteed FAIL that measures nothing beyond what the spike already proved, or (b) a fake PASS via conversation-context leakage — exactly the contamination the handoff's RUN2 isolation rule exists to prevent. Per the degradation matrix (§4.1 row 1) and the handoff's own edge-case rule ("RUN2 未回想 pattern 但 memory 文件确实存在 → FAIL，不许改写为 PASS" — a fortiori when no memory file can exist):

NEG-CONTROL: NOT_APPLICABLE_WITH_REASON — memory mechanism absent (VERDICT-memory: FAIL, spike-report.md §1)
RUN2-RECALL: NOT_APPLICABLE_WITH_REASON — memory mechanism absent (VERDICT-memory: FAIL, spike-report.md §1)

AC5 grep (`^(RUN2-RECALL|NEG-CONTROL): PASS$` expected 2) therefore yields 0 — recorded as sanctioned degradation, escalated in completion report §Escalations. Not rewritten as PASS.

---

## AC8 supplement — spec-compliance-reviewer registration is behavioral, not just structural

Independent spawn: `claude -p --agent spec-compliance-reviewer` + "state your single responsibility and report format" (no tools):

```
My single responsibility is to verify that an implementation satisfies the handoff's §9.1 Spec
Compliance Checklist by executing each row's Verification Method verbatim and comparing actual
output against the row's Expected Evidence — spec conformance only, not code quality or test running.

My report format is one line per row (`AC<n>: PASS|FAIL|NOT_APPLICABLE_WITH_REASON — <actual
output summary>`) followed by an overall `verdict: PASS` or `verdict: FAIL`, where any unexplained
FAIL produces an overall FAIL.
```

The project-level def resolves and drives behavior (consistent with VERDICT-shadowing: PASS resolution semantics).

---

## FR7 — zero machine-global writes (raw output)

```
$ find ~/.claude/agents -type f -newer .tad/evidence/spikes/subagent-frontmatter-2026-07/START_MARKER | wc -l
       0
```
