# First-Party Harness Introspection — Claude Code as observed from inside a live session

**Source type**: First-party ground truth. Written 2026-07-12 by the running model (Claude Fable 5, model id `claude-fable-5[1m]`) inside an active Claude Code CLI session on macOS, by directly describing the capabilities visible in its own system prompt and tool inventory. This is NOT web research — it is what the harness actually injects and exposes TODAY. Use it to validate/date-check web sources.

**Scope note**: Describes the CLI harness as configured on this machine (some tools come from user-installed MCP servers/plugins and are marked as such). Facts only, no judgments.

---

## 1. Model tier

- Running model: **Claude Fable 5** — first model of the Claude 5 family, new "Mythos-class" tier positioned ABOVE Claude Opus in capability. Fable 5 and Claude Mythos 5 share the same underlying model; Fable is the generally-available variant with additional dual-use safety measures; Mythos is restricted to approved organizations.
- Most recent model families known to the harness: Fable 5 and Claude 4.x (Opus 4.8, Sonnet 4.6, Haiku 4.5).
- "Fast mode" (/fast) uses Claude Opus with faster output on Opus 4.6/4.7/4.8 — it is NOT a downgrade to a smaller model.
- Knowledge cutoff of the running model: January 2026.

## 2. Native auto-memory system (system-prompt level — always on)

This is injected into EVERY session's system prompt (not a skill, not opt-in):

- Each project gets a persistent memory directory: `~/.claude/projects/<project-slug>/memory/`.
- One fact per file, markdown with YAML frontmatter: `name` (kebab-case slug), `description` (one-line, used for relevance decisions during recall), `metadata.type` ∈ {`user`, `feedback`, `project`, `reference`}.
- Typed semantics: `user` = who the user is; `feedback` = guidance user gave on how the model should work (with **Why** and **How to apply** lines); `project` = ongoing work/goals/constraints not derivable from code or git history (relative dates converted to absolute); `reference` = pointers to external resources.
- Cross-linking: `[[name]]` wiki-links between memory files; dangling links are explicitly allowed as "worth writing later" markers.
- `MEMORY.md` is an index file **loaded into context at every session start** — one line per memory (`- [Title](file.md) — hook`), content never inlined.
- Maintenance rules injected: check for existing file before saving (update, don't duplicate); delete wrong memories; do NOT save what the repo already records (code structure, git history, CLAUDE.md contents); recalled memories arrive in `<system-reminder>` blocks and are labeled background context, to be re-verified before use.
- **Precedence observation (relevant to TAD)**: these memory instructions live at SYSTEM PROMPT level, while TAD's knowledge instructions (journal → distillation → `.tad/project-knowledge/`) live at SKILL level (loaded only when /alex or /blake is invoked). The system-level instruction is always present; the skill-level one is conditional. This is the mechanical reason the model "defaults to writing memory instead of knowledge."

## 3. Native skill system

- Skills are SKILL.md files invocable via a `Skill` tool; user typing `/<name>` maps to skill invocation.
- Skills carry trigger descriptions; the harness instructs the model to check available skills BEFORE responding and treat a matching skill as a BLOCKING requirement (invoke before any other response about the task).
- Levels observed: user-level (`~/.claude/skills/`), project-level (`.claude/skills/`), plugin-namespaced (`plugin:skill` form, e.g. `claude-hud:setup`, `frontend-design:frontend-design`), and built-in harness skills (e.g. `/loop`, `/schedule`, `/code-review`, `/verify`, `/simplify`, `/init`, `/review`, `/security-review`, `/update-config`, `claude-api` reference).
- Skills can carry their own model-facing trigger/skip rules (e.g. the `claude-api` skill has explicit TRIGGER/SKIP grep heuristics).

## 4. Native subagent & multi-agent orchestration

- **Agent tool**: spawn typed subagents (~30 types registered on this machine, incl. general-purpose, Explore (read-only search), Plan (architecture planning), code-reviewer, security-auditor, product-expert, etc.). Options: named agents, `run_in_background`, `isolation: "worktree"` (auto-created/cleaned git worktree), model override per agent, permission `mode` (e.g. plan).
- **SendMessage**: continue a previously-spawned agent with its context intact (persistent addressable teammates, not fire-and-forget).
- **TeamCreate / TeamDelete**: team constructs for spawned agents (deferred tools present in inventory).
- **Workflow tool**: deterministic multi-agent orchestration via inline JavaScript scripts — `agent()` (with JSON-schema-forced structured output, per-agent model/worktree/agentType), `pipeline()` (no-barrier staged fan-out), `parallel()` (barrier), `phase()`, `log()`, token `budget` API tied to user "+500k"-style directives, nested `workflow()` (1 level), concurrency cap ~min(16, cores−2), lifetime cap 1000 agents, **journal-based resume** (`resumeFromRunId` — unchanged agent() prefix returns cached results). Scripts are persisted to disk automatically.
- **Opt-in gating**: Workflow use requires explicit user opt-in ("ultracode" keyword, session toggle, or user asking for multi-agent orchestration in their own words). Documented quality patterns in the tool spec itself: adversarial verify (N refuters + majority), judge panels, loop-until-dry discovery, multi-modal sweeps, completeness critics.

## 5. Native planning & structured user-choice flows

- **Plan mode**: EnterPlanMode/ExitPlanMode tools — model drafts a plan, user approves before edits happen; permission modes include `plan`, `acceptEdits`, `dontAsk`, `bypassPermissions`.
- **AskUserQuestion**: up to 4 questions per call, 2-4 options each, multiSelect, and **`preview` fields — side-by-side rendered markdown previews (UI mockups, code variants, diagrams) for visual comparison before choosing**. Users can always answer free-text via "Other".
- Harness guidance discourages using it for choices with conventional defaults (act, mention, proceed) — it is reserved for genuine user-owned decisions.

## 6. Native review & verification capabilities

- **/code-review**: reviews current diff at selectable effort levels (low→ultra). **`ultra` level = multi-agent cloud review of the branch or a GitHub PR** (deprecated alias /ultrareview), user-triggered and billed; needs a git repo. `--comment` posts inline PR comments; `--fix` applies findings.
- **/security-review**: dedicated security review skill.
- **/verify**: runs the app and observes behavior to confirm a change does what it claims (behavioral verification, not just tests).
- **/simplify**: reuse/simplification/efficiency cleanup pass (explicitly not bug-hunting).
- **/review**: PR review skill.

## 7. Native automation & scheduling

- **ScheduleWakeup**: self-paced recurring wakeups within a session (/loop dynamic mode) with cache-aware delay guidance.
- **CronCreate/CronList/CronDelete** (+ /schedule skill): scheduled CLOUD agents ("routines") on cron schedules, incl. one-time scheduled runs.
- **/loop skill**: recurring prompt/slash-command execution on an interval or self-paced.
- **Background execution**: Bash `run_in_background` (detached, re-invokes the model on exit), background Agents and Workflows with completion notifications, Monitor tool, TaskCreate/TaskList/TaskOutput/TaskStop task tracking with task IDs.
- **RemoteTrigger / PushNotification**: remote triggering and push notification tools (deferred inventory).

## 8. Context management & session state (native)

- Long conversations are AUTO-SUMMARIZED by the harness; the summary plus remaining context carries into the next context window — the model is explicitly told it does NOT need to wrap up early or hand off mid-task.
- `<system-reminder>` injection mechanism for harness state (hook output, recalled memories, tool notices).
- CLAUDE.md hierarchy natively loaded: user-global (`~/.claude/CLAUDE.md`) + project (`CLAUDE.md`) with `@import` support.
- Hooks configured via settings.json (SessionStart, PreToolUse, PostToolUse, etc.), managed through the native `/update-config` skill; hook output is treated as user feedback.

## 9. Native tool-discovery & integration surface

- **ToolSearch**: deferred-tool system — large tool inventories (MCP servers etc.) load schemas on demand instead of bloating context.
- **MCP**: first-class MCP client (this machine has claude.ai-hosted connectors: Linear, Google Drive/Calendar/Gmail, Canva, Gamma; plus local MCP servers: claude-in-chrome browser automation, codebase-memory graph).
- **Browser automation**: claude-in-chrome MCP suite (navigate, computer, read_page, form_input, gif recording, console/network debugging) with harness-level usage guidance baked into the system prompt.
- **LSP tool** present (deferred).
- **EnterWorktree/ExitWorktree**: session-level git worktree isolation.

## 10. Communication & operating norms injected at system level

- "Lead with the outcome", final-message-completeness rule, confirmation-before-irreversible-actions, faithful outcome reporting (report failing tests as failing), autonomous-operation norms (act without asking for reversible in-scope actions).
- Code-comment norm: only state constraints code can't show; no PR-reviewer-directed comments.

## 11. Observed instruction-collision surfaces with TAD (factual, no verdict)

1. **Memory vs knowledge**: system-level auto-memory (§2) vs TAD journal→distillation→project-knowledge; both fire on "record what we learned" moments.
2. **AskUserQuestion previews / plan mode** vs TAD Feedback Collector overlay HTML + feedback JSON + read_feedback_protocol.
3. **Workflow tool + Agent teams** vs TAD yolo-epic/surplus-execute/Conductor orchestration scripts.
4. **/code-review (incl. ultra) + /security-review + /verify** vs TAD Gate 3 Layer-2 expert chain and Gate 2 handoff expert review.
5. **Native skill auto-trigger + /save-type flows** vs TAD *save-skill / *save-workflow / skillify T1-T3 / *harvest.
6. **Auto-summarization + memory recall** vs TAD session-state.md + post-compact recovery protocol.
7. **CronCreate routines + /loop** vs TAD github-registry weekly scan routine and similar scheduled scans.
8. **EnterPlanMode** vs TAD *analyze→*design→*handoff (TAD already explicitly forbids EnterPlanMode for its agents).
9. **TaskCreate/TaskList native task tracking** vs TAD NEXT.md / task_management config.
10. **claude-hud statusline, /fewer-permission-prompts, /update-config** vs TAD hooks maintenance conventions.
