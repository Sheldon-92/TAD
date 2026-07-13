# T1 Spike Report: Subagent Frontmatter `memory` / `skills` / Shadowing Semantics

- **Date**: 2026-07-13
- **CLI**: 2.1.172 (Claude Code) — verified via `claude --version`
- **Handoff**: HANDOFF-20260713-native-capability-adoption-phase2.md (FR1)
- **Spawn method**: headless CLI spawn from repo root — `claude -p --agent <name> "<prompt>"` (project-level `.claude/agents/` resolved from cwd; each invocation is an independent fresh session, no shared conversation state)
- **Spike agent**: `tad-spike-memory-agent.md` (now preserved at `fixtures/tad-spike-memory-agent.md`)

---

## Verdicts

VERDICT-memory: FAIL
VERDICT-skills: FAIL
VERDICT-shadowing: PASS

---

## 1. `memory` field — FAIL (silently ignored, both value forms)

### Attempt 1: boolean form (`memory: true`)

Frontmatter used:

```yaml
---
name: tad-spike-memory-agent
description: T1 spike agent ...
model: sonnet
memory: true
skills:
  - code-security
---
```

- Field was **accepted without error or warning** (agent spawned normally, replied `SPIKE-ALIVE` to connectivity probe).
- Probe: "Does your system prompt or configuration mention a persistent memory directory assigned to you?"
- First answer was a false positive: the agent cited `/Users/sheldonzhao/01-on progress programs/TAD/.tad/memory/` — that is the **project auto-memory** (CLAUDE.md §7.5 redirect, loaded for every session), NOT an agent-specific memory. Discriminating re-probe (quote system-prompt memory sentences verbatim) returned:

> Here are every line from my system prompt ... that contains the word "memory":
> [quotes ONLY the spike agent's own body instructions]
> No concrete path or memory directory is specified anywhere in my system prompt.
> Therefore ... **NO-MEMORY-DIRECTORY**.

The only "memory" text in the agent's system prompt was the spike def's own body. The field injected nothing.

### Attempt 2: path form (`memory: ".claude/agent-memory/tad-spike-memory-agent"`)

Probe: "Does your system prompt assign you a persistent memory directory or mention any path containing 'agent-memory'?"

Raw output:

```
NO-AGENT-MEMORY-IN-SYSTEM-PROMPT
```

### Filesystem evidence (no memory landing point exists)

```
$ ls ~/.claude/agent-memory
ls: /Users/sheldonzhao/.claude/agent-memory: No such file or directory
$ ls <repo>/.claude/agent-memory
ls: ... No such file or directory
```

`claude --help` contains no agent-memory flag (only auto-memory in `--bare` description).

**Memory landing point: NONE (field inert)** → FR4 gitignore entry is NOT_APPLICABLE_WITH_REASON (no memory files are created anywhere, in-repo or out).

---

## 2. `skills` field — FAIL (not preloaded, not attached)

Frontmatter carried `skills:\n  - code-security` (list form per handoff §4.3) throughout all probes. Accepted without error or warning.

### Preload probe (tools banned via `--disallowedTools "Read,Bash,Grep,Glob,WebFetch,WebSearch"`)

Prompt: "Is the content of a skill or capability pack named 'code-security' already present in your context right now? If yes, quote 3 specific concrete rules from it verbatim ... If NOT, reply exactly: NO-PRELOADED-SKILLS"

Raw output:

```
NO-PRELOADED-SKILLS
```

(The pack's real content — Four-Gate fastest-fail-first pipeline, TruffleHog exit 183, Semgrep exit 1, S1-S8/D1-D7/V1-V7 rule indices — is distinctive; a preloaded agent could have quoted any of it. It quoted none.)

### Availability nuance probe

Prompt: "List the names of any skills your configuration says are available or attached to you specifically — or reply NO-ATTACHED-SKILLS."

Raw output (excerpt):

> **NO-ATTACHED-SKILLS**
> My system prompt contains no list of skills assigned or attached to me. The large skill list visible in the `<system-reminder>` block is the project-level registry (available to the harness), not declared as part of my agent's own configuration.

So the field is fully inert on 2.1.172: neither preload (AC6 semantics) nor attach/availability semantics.

---

## 3. Project-level shadowing of same-name user-level agent — PASS

Temp project-level `code-reviewer.md` (unique marker `SHADOW-MARKER-TAD-QX93Z`, body reply `PROJECT-LEVEL-BODY-ACTIVE`, `model: sonnet`) created while user-level `~/.claude/agents/code-reviewer.md` (model: opus, "senior code review specialist", "three-pass analysis") remained untouched.

### Probe 1 — whose body is active?

```
(1) My marker phrase is: **SHADOW-MARKER-TAD-QX93Z**
(2) I do not have a specific model ID string configured in my system prompt. **UNKNOWN-MODEL**
```

### Probe 2 — replace vs merge?

Prompt asked for review framework + whether system prompt contains 'three-pass analysis' or 'a senior code review specialist' (both present verbatim in the user-level body).

```
(1) **PROJECT-LEVEL-BODY-ACTIVE**
(2) **NO-DOES-NOT-CONTAIN**
```

**Conclusion**: project-level def **completely replaces** the user-level same-name def (body replaced, zero merge/leak of user-level content). Caveat: model replacement could not be introspected from inside the session (agents don't see their own model id); body-replacement — the load-bearing semantics for def precision — is confirmed clean. Temp def moved to `fixtures/code-reviewer.md` immediately after the test (`.claude/agents/` left with no spike residue).

---

## Degradation matrix branch selected (§4.1)

`memory FAIL + skills FAIL + shadowing PASS` → combined rows 1+2:

- FR2 shadow defs with `memory` field: **NOT delivered** (field inert — a dead `memory:` key would be config theater; also keeps AC3 in its sanctioned VACUOUS-PASS branch).
- FR5 `skills` preload on security-auditor: **NOT delivered** — handoff transcription status quo (Blake SKILL 1_5a) retained, zero changes to Blake SKILL (AC9).
- FR3/FR4: NOT_APPLICABLE_WITH_REASON (no memory-enabled defs / no memory landing point).
- FR6 behavioral evidence: SKILLS-PRELOAD honestly recorded FAIL (test WAS executed, during spike); memory RUN0/RUN1/RUN2 not runnable (mechanism absent) — see phase2-behavioral-evidence.md.
- **Still delivered (unconditional per AC8)**: `spec-compliance-reviewer.md` project-level registration (no same-name conflict; shadowing PASS confirms project-level defs resolve). Carries dormant Memory Protocol boundary section (documented as dormant; no `memory:` frontmatter key).
- All FAIL branches escalated in completion report §Escalations (NFR2 — never silently drop).

## Phase status: DEGRADED (honest partial), not Done-as-designed.

---

## RE-SPIKE ADDENDUM — CLI 2.1.207 (2026-07-13, post-upgrade; Conductor-run via nested headless session)

- VERDICT-memory: **FAIL (still inert)** — frontmatter `memory: ".claude/agent-memory/tad-spike-memory-agent"` did NOT create/inject its own directory; agent reproduced the documented false-positive (reported project auto-memory `.tad/memory/` from CLAUDE.md §7.5 instead; marker written there was spike pollution, removed). BLOCKED-UNTIL remains for reviewer persistent memory.
- VERDICT-skills: **PASS (provisional)** — with tools banned, agent quoted 3 rules verbatim-authentic to `.claude/skills/code-security/SKILL.md` (grep-verified: "72% of organizations" ×1, "exit 183" ×2) and reported the pack arrived as a command block in its context at spawn. Same probe on 2.1.172 returned NO-PRELOADED-SKILLS. Residual confound: probe ran via nested `claude -p` wrapper (agent registry needed a fresh process — project-level defs are NOT hot-registered mid-session, live-tested today); confirm once via direct Agent-tool spawn in a session where the def was present at startup.
- Side-effects: REGISTRY.yaml diff clean this run; spike def restored to fixtures/ (not left in .claude/agents/).
- Unlock: P2 FR5 static pairing (security-auditor ← code-security via `skills:` field) is now implementable — queue as small handoff, do NOT ad-hoc.

---

## DELIVERY-ATTEMPT ADDENDUM #2 — 2026-07-13 PM (FR5 delivery BLOCKED; re-spike PASS refuted)

Attempted delivery per HANDOFF-20260713-skills-preload-delivery.md (Gate 2 passed, YOLO).
Outcome: **AC1a headless preload probe FAIL 5/5** (implementer agent, worktree) **+ 1/1 FAIL on
Conductor's independent main-repo probe** with the staged def present. Full raw evidence:
`fr5-delivery-evidence.md` (same dir).

### VERDICT-skills: downgraded PASS(provisional) → **FAIL (confound identified)**

Two independent mechanism findings explain the morning's false PASS:

1. **The `Skill` tool was never in the ban list.** The Conductor's confirmation probe agent
   stated plainly: only the one-line router description of `code-security` is in context; the
   rule bodies would require an explicit `Skill(code-security)` call — a tool the morning
   re-spike probe left available. An agent that loads the pack on demand and quotes it is
   indistinguishable from preload under that probe design.
2. **`--disallowedTools` is variadic on 2.1.207 and comma-joined form mis-parses**: a comma-
   joined single arg plus trailing prompt makes the CLI treat every prompt word as a deny rule
   ("Permission deny rule 'Is' matches no known tool") and error out — or, in other orderings,
   leaves bans ineffective. The working form is space-separated tool names + prompt via stdin.
   Reproduced independently by implementer (worktree) and Conductor (main).

Additional diagnostics (implementer, all FAIL → field inert): def persona confirmed active
(body IS the system prompt — only `skills:` inert); exact re-spike fixture def; env-stripped
spawn; full re-spike replication from main root.

### State after this attempt

- Def NOT committed (§5 AC1a row honored — no false capability claim in repo). Assembled def
  **staged UNTRACKED** at `.claude/agents/security-auditor.md` solely to enable AC1b.
- **AC1b (next fresh interactive session, direct Agent-tool spawn) is now the DECISIVE test**,
  not a confirmation: headless `claude -p` and the interactive harness are different spawn
  paths; the harness path is the one TAD actually uses. If AC1b also FAIL → remove the staged
  def's `skills:` key (or drop the def), keep VERDICT-skills: FAIL, return the idea to
  BLOCKED-UNTIL-CLI-support. If AC1b PASS → headless-vs-harness divergence is the new ground
  truth; commit def per handoff.
- Probe-design lesson (for any future capability spike): **ban the `Skill` tool (and
  ToolSearch-loadable equivalents) in preload probes**, and verify ban efficacy in-band
  (AC1a-guard pattern) before trusting a quote-based verdict.

---

## ADDENDUM #3 — 2026-07-13, AC1b decisive test: VERDICT-skills FINAL = PASS(harness-path) / FAIL(headless-path)

Fresh interactive session (staged def registered at startup). Discriminative pair, both spawns
via Agent tool, 0 tool uses each, all-tools-banned prompts:

1. security-auditor (def WITH `skills: [code-security]`): DEF: PROJECT confirmed via body markers;
   3 verbatim rules quoted (grep-F-authentic); pack present as command block AT SPAWN.
2. spec-compliance-reviewer (def WITHOUT `skills:`): CODE-SECURITY-BLOCK: ABSENT, NO-SKILL-BLOCKS.

Only variable = the `skills:` key → **SKILLS-PRELOAD-DIRECT: PASS**. Full raw outputs:
fr5-delivery-evidence.md §AC1b.

**Final ground truth (2.1.207)**: `skills:` frontmatter works ONLY on the interactive-harness
Agent-tool spawn path (pack injected as command block at spawn); INERT on headless
`claude -p --agent` (6/6 FAIL, ADDENDUM #2) and on ≤2.1.172 (original spike). ADDENDUM #2's
"FAIL (confound identified)" verdict is superseded for the harness path; its probe-design
lesson (ban the Skill tool in preload probes) and the headless findings stand.

Consequence: HANDOFF-20260713-skills-preload-delivery §5 AC1b-PASS branch → def merged.
Reviewer-persistent-memory (`memory:` field) remains FAIL/BLOCKED — unchanged.
