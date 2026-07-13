---
research_complexity: complex
---

# Ask Findings — Claude Code Native Capabilities (2026-07-12)

## S1 (implementer): auto-memory mechanism + load timing [round 1]

Different notebook specified, starting new conversation...
Continuing conversation 1e23357a...
Answer:
### Exact Mechanism of Claude Code Auto-Memory

#### 1. Directory Layout
The primary auto-memory system for a project is stored locally in the filesystem
[1]:
* **Main Storage Path**: Memories are kept in a machine-local directory located 
at `~/.claude/projects/<project>/memory/` [2]. 
* **Repository-Wide Sharing**: The `<project>` identifier is derived from the 
active Git repository [2]. This architectural choice ensures that all Git 
worktrees and subdirectories of that repository share a single, unified 
auto-memory folder [2-4]. If you operate outside of a Git repository, the 
project's root folder is used to resolve the path [2].
* **Custom Paths**: You can redirect where auto-memory is stored on your machine
by configuring the `autoMemoryDirectory` setting in your settings files [2, 5].
* **File Structure**: The memory folder contains a central `MEMORY.md` index 
file and optional separate, topic-specific markdown files (e.g., `debugging.md` 
or `patterns.md`) [1, 6].

#### 2. `MEMORY.md` Index Loading
* **Loading Budget**: At the start of every session, Claude Code loads only the 
first **200 lines or 25KB** of the `MEMORY.md` file (whichever limit is hit 
first) [6, 7]. Any content beyond this threshold is omitted [6].
* **Index Reference Design**: To prevent context bloat, the index file contains 
list pointers to individual memories (rendered in a format such as `- 
[Title](file.md) — hook`) rather than inlining their full text [8].
* **On-Demand Topic Loading**: Topic files (e.g., `debugging.md`) are **never 
loaded at startup** [6]. Instead, they are lazily loaded on demand: Claude Code 
instructs the model to read them only when a specific query or task inside the 
conversation makes that topic relevant [6].

#### 3. When Claude Decides to Write a Memory
Claude Code's auto-memory operates at the system-prompt level and is always 
active by default (unless toggled off via `/memory`, settings, or the 
`CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` environment variable) [2, 8]. Claude decides
to create or update a memory when [9]:
* It identifies valuable, cross-session takeaways, such as build commands, 
debugging insights, architecture notes, code style preferences, or workflow 
habits [9].
* You explicitly command the model to record a learning (e.g., *"remember that 
our API tests require a local Redis instance"*) [10].
* **Verification & Deduplication**: To keep context clean, Claude is strictly 
instructed **not to record facts that the repository already explicitly 
captures**, such as files, code structure, Git commit history, or rules already 
defined in `CLAUDE.md` [8].

#### 4. Typed Frontmatter Schema
Each memory is saved as an individual markdown file with a strict, typed YAML 
frontmatter schema [8]:
* **`name`**: A kebab-case slug representing the memory [8].
* **`description`**: A concise, one-line summary used by the model for relevance
decisions when recalling memories [8].
* **`metadata.type`**: A metadata category that must belong to one of these four
types [8]:
  * `user`: Captures details about who the user is.
  * `feedback`: Guidance given on how the model should work, formatted with 
**Why** and **How to apply** lines.
  * `project`: Ongoing work, goals, and constraints not derivable from code or 
Git (relative dates are automatically converted to absolute dates).
  * `reference`: Reference pointers to external resources.
* **Cross-Linking**: Memories can Bidirectionally reference other files using 
`[]` wiki-links [8]. The system explicitly allows dangling wiki-links to act as 
"worth writing later" placeholders [8].

#### 5. Subagent `memory` Field for Persistent Directories
Custom subagents can declare a `memory` field in their YAML frontmatter to 
enable an isolated, persistent memory directory that survives across 
conversations [11, 12]. This field supports three scopes [13]:
* **`user`**: Saved to `~/.claude/agent-memory/<name-of-agent>/`. Best when the 
subagent's accumulated knowledge should apply globally across all projects on 
your machine.
* **`project`**: Saved to `.claude/agent-memory/<name-of-agent>/`. Best for 
project-specific insights that can be committed and shared via version control.
* **`local`**: Saved to `.claude/agent-memory-local/<name-of-agent>/`. 
Project-specific but excluded from version control (should be added to 
`.gitignore`).

When subagent memory is enabled, the subagent's custom system prompt is injected
with instructions for reading and writing to its memory folder, its `Read`, 
`Write`, and `Edit` tools are auto-enabled, and it is given the first 200 lines 
or 25KB of its own `MEMORY.md` index file [13].

---

### Context Loading Comparison: CLAUDE.md, Auto-Memory, and Skills

These three context mechanisms load at completely different stages of a session,
designed to balance persistent instruction adherence with strict token 
efficiency [14, 15].

| Context Feature | When It Loads | What Loads Into Context | Context Token 
Impact / Cost |
| :--- | :--- | :--- | :--- |
| **`CLAUDE.md`** [14] | **Session Start** [14, 16] (or lazily upon directory 
entry in monorepos [17]) | The full content of all discovered `CLAUDE.md` files 
(managed, user, project, and local levels) [16, 17]. | **High**: The full 
content is sent in every single API request of the session [14]. |
| **Auto-Memory** [6] | **Session Start** (Index) + **On-Demand** (Topic files) 
[6, 15] | At start, only the first 200 lines or 25KB of `MEMORY.md` [6]. 
Individual topic files are read only if Claude explicitly accesses them [6]. | 
**Low at startup**: Only the index list is present initially [6]. Detailed files
are loaded as-needed via standard tool calls [6]. |
| **Skills** [14] | **Session Start** (Metadata) + **On-Demand** (Full body when
used) [14, 16] | At start, only skill names and brief descriptions [16]. When a 
skill is invoked (by you or auto-selected by Claude), its full markdown body is 
loaded [16]. | **Very Low**: ~100 tokens per skill description at startup [18]. 
Full body (typically under 5,000 tokens) is only paid once the skill runs [18]. 
|

#### Specific Loading Differences

* **Compaction and Re-injection**:
  * `CLAUDE.md` files at the project root survive conversation compaction [19]. 
When compaction occurs, Claude Code automatically re-reads the root `CLAUDE.md` 
from disk and re-injects it into the fresh post-compaction context [19].
  * Nested `CLAUDE.md` files are not automatically re-injected; they reload only
when Claude subsequently reads a file in that subdirectory [19].
  * Auto-memory index `MEMORY.md` is re-read on launch or resume, but recalled 
memories remain in the transcript as static `<system-reminder>` blocks [8, 20].
  * Compacted skills are re-attached to the post-compaction context, preserving 
the first 5,000 tokens of each recently used skill up to a combined skill budget
of 25,000 tokens [21].
* **Skill Exceptions**:
  * **`disable-model-invocation: true`**: When this frontmatter is set, the 
skill's name and description are completely hidden from the model at startup 
[16, 22, 23]. This reduces its context cost to absolute zero until you manually 
invoke it with `/<name>` [16, 22, 23].
  * **Subagent Preloading**: In subagents, skills listed in the agent's `skills`
frontmatter field are fully preloaded into context at launch rather than waiting
to load on demand [16].

🧠 I can help you write a custom subagent Markdown file template with persistent
project-level memory and specific tool restrictions if you want to set one up 
for your codebase.

Resumed conversation: 1e23357a-18e6-44e7-80f2-aa5dc65a562d

## S1 follow-up [round 2]: write triggers + subagent memory field + disable/redirect

Different notebook specified, starting new conversation...
Continuing conversation 1e23357a...
Answer:
### 1. Triggers and Signals for Auto-Memory Writes

Claude Code's auto-memory system operates continuously at the system-prompt 
level [1]. Claude evaluates and decides to write or update a memory file based 
on the following specific moments and signals:
*   **Discovered takeaways as it works**: While executing tasks, Claude actively
identifies valuable, cross-session takeaways that would be useful in future 
conversations [1, 2]. These include **build commands, debugging insights, 
architectural decisions, code style preferences, and workflow habits** [1, 2].
*   **User corrections and preferences**: The system automatically captures and 
learns from direct human corrections and style preferences expressed during 
conversations without requiring manual user effort [3, 4].
*   **Explicit user instructions**: Claude immediately triggers a memory write 
when you explicitly command it to record a learning (e.g., *"always use pnpm, 
not npm"* or *"remember that our API tests require a local Redis instance"*) [1,
5].
*   **Deduplication filter**: Claude is explicitly instructed **not to record 
facts already captured elsewhere**, such as codebase structures, Git commit 
history, or rules already defined in `CLAUDE.md` [1].

---

### 2. Subagent `memory` Frontmatter Field Mechanics

Custom subagents can declare a `memory` field in their YAML frontmatter to 
enable an isolated, persistent memory directory that survives across 
conversations [6, 7]. 

#### Storage Location & Scope
The value of the `memory` field configures one of three scopes, which dictate 
where files are saved [8]:
*   **`user`**: Saved to `~/.claude/agent-memory/<name-of-agent>/` [8]. Use this
scope when the subagent should remember learnings globally across all projects 
on your machine [8].
*   **`project`**: Saved to `.claude/agent-memory/<name-of-agent>/` [8]. This is
the recommended default, as it makes the subagent's memory project-specific and 
shareable via version control [8, 9].
*   **`local`**: Saved to `.claude/agent-memory-local/<name-of-agent>/` [8]. 
This scopes memory to the project but keeps it gitignored (excluded from version
control) [8].

#### System Instructions and Behaviors
When memory is enabled for a subagent [8]:
1.  **Injected Prompts**: The subagent's system prompt is automatically appended
with instructions for reading and writing to its designated memory directory 
[8].
2.  **Memory Index Loading**: It receives the first **200 lines or 25KB** of its
own `MEMORY.md` index file as context [8].
3.  **Automatic Tool Access**: The `Read`, `Write`, and `Edit` tools are 
automatically enabled so the subagent has the capabilities to manage and curate 
its memory files directly [8].
4.  **Learning Instructions**: The subagent is instructed to consult its memory 
before starting tasks (to recall patterns) and to update its memory with lessons
learned after completing a task [9].

#### Size and Eviction Rules
*   **Loading Budget**: Only the first 200 lines or 25KB of `MEMORY.md` are 
loaded into context at startup [8].
*   **Index Curation**: The subagent is explicitly instructed to curate and 
prune its `MEMORY.md` file if it starts to exceed this loading budget [8].
*   **No Auto-Eviction**: While temporary session files (transcripts, tasks, 
plans) are automatically cleared after 30 days by default (governed by 
`cleanupPeriodDays`) [10-12], subagent `agent-memory/` directories are **not 
covered by automatic cleanup and persist indefinitely** until manually deleted 
[7, 8, 13].

---

### 3. Disabling and Redirecting Auto-Memory

#### How to Disable Auto-Memory
You can fully disable the auto-memory system in four ways:
1.  **Interactive Menu**: Run the `/memory` command mid-session and use the 
interactive toggle to turn off auto-memory [5, 14].
2.  **Settings Configuration**: Add `"autoMemoryEnabled": false` to your project
or user settings file [14].
3.  **Environment Variable**: Set the `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` 
environment variable before launching your session [1, 14].
4.  **Scripted Bare Mode**: Launching Claude Code with the `--bare` flag for 
non-interactive runs automatically disables all auto-memory mechanics [15, 16].

#### How to Redirect Auto-Memory
To change where memories are written, you can configure the 
**`autoMemoryDirectory`** setting [14]:
*   It must be set in a settings file (user, project, local, policy, or passed 
via `--settings` flag) [14].
*   The value must be configured as an **absolute path** or start with a tilde 
(`~/`) [17].
*   **Trust Guard**: If configured within project-level settings 
(`.claude/settings.json` or `.claude/settings.local.json`), this path redirect 
is only honored after you accept the workspace trust dialog for that folder 
[17].

---

🛠️ I can help you draft a custom subagent configuration markdown file with 
persistent project-level memory and specific tool restrictions if you want to 
set one up for your codebase.

Resumed conversation: 1e23357a-18e6-44e7-80f2-aa5dc65a562d

## S2 (skeptic): changelog 2026-01..07 features + churn [round 1]

Different notebook specified, starting new conversation...
Continuing conversation 1e23357a...
Answer:
Between January 2026 and July 2026, Claude Code shipped a series of significant 
features, refinements, and architectural updates. Below is the structured 
breakdown of these notable features, their version numbers, experimental 
statuses, and any breaking changes or renames:

---

### 1. Auto-Memory (Native Project Memory)
*   **Initial Release (v2.1.32, Feb 5, 2026):** Automatically records and 
recalls memories as it works [1].
*   **Core Feature Rollout (v2.1.59, Feb 26, 2026):** Auto-memory launched 
natively to save useful context across sessions [2].
*   **Custom Storage Directory (v2.1.74, Mar 12, 2026):** Added the 
`autoMemoryDirectory` setting to redirect auto-memory paths [3].
*   **Freshness Metrics (v2.1.75, Mar 13, 2026):** Added last-modified 
timestamps to memory files to distinguish fresh from stale context [4].
*   **Size Caps (v2.1.83, Mar 25, 2026):** To prevent context window bloat, the 
central `MEMORY.md` index file is truncated at **25KB or 200 lines** at session 
start [5].

---

### 2. Subagent Memory
*   **YAML Frontmatter Integration (v2.1.33, Feb 6, 2026):** Custom agents 
received support for the `memory` frontmatter field, enabling isolated 
persistent memory directories with `user`, `project`, or `local` scope [6]. This
allows subagents to record codebase patterns, debugging insights, and 
architectural decisions over time [7].

---

### 3. Agent Teams (Multi-Agent Collaboration)
*   **Initial Release (v2.1.32, Feb 5, 2026):** Shipped as a **Research 
Preview**, requiring the environment flag 
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` [1].
*   **Breaking Changes & Simplification (v2.1.78, June 15, 2026):** **The 
explicit setup tools `TeamCreate` and `TeamDelete` were completely removed.** 
Instead, every session with the experimental flag active got an implicit team, 
allowing Claude to spawn teammates directly via the Agent tool’s `name` 
parameter with zero manual setup [8, 9].

---

### 4. Workflow Tool (Dynamic Workflows)
*   **Initial Release (v2.1.154, May 28, 2026):** Introduced **dynamic 
workflows** allowing Claude to orchestrate tasks in the background across tens 
to hundreds of agents [10].
*   **Keyword Control (v2.1.157, May 29, 2026):** Added a "Workflow keyword 
trigger" configuration setting to prevent the raw word "workflow" in a prompt 
from accidentally initiating a run [11].
*   **Renamed / Breaking Change (v2.1.160, June 2, 2026):** The dynamic-workflow
trigger keyword was **renamed from `workflow` to `ultracode`** [12]. The word 
"workflow" ceased to trigger automatic runs, although asking for it in natural 
language remained supported [12].

---

### 5. Plan Mode Changes
*   **Shortcuts (v2.1.2, Jan 9, 2026):** Added the `Shift+Tab` keyboard shortcut
to quickly select the "auto-accept edits" option while inside plan mode [13].
*   **Quick Entry (v2.1.72, Mar 10, 2026):** Added an optional description 
argument to `/plan` (e.g., `/plan fix the auth bug`) to immediately start 
planning on a task [14].
*   **Re-approval Fixes (v2.1.76, Mar 14, 2026):** Resolved issues where plan 
mode requested re-approval after the plan had already been accepted [15].
*   **Permission Prompt Reduction (v2.1.111, Apr 16, 2026):** Removed the 
permission prompt required to enter plan mode, allowing instant entry [16].
*   **Stateful Checks (v2.1.199, July 2, 2026):** Fixed plan mode to correctly 
prompt for state-changing browser tool calls, while read-only `browser_batch` 
calls are auto-allowed [17].

---

### 6. AskUserQuestion Previews
*   **Interactive Previews (v2.1.70, Mar 6, 2026):** Prebuilt elements of the 
interview system included side-by-side rendered markdown previews for visual 
comparison [18]. A performance regression that re-rendered markdown on every 
notes-input keystroke was resolved [19].
*   **Formatting Fix (v2.1.181, June 17, 2026):** Fixed preview content getting 
cut off at the dialog edge instead of properly word-wrapping [20].

---

### 7. `/code-review ultra`
*   **Cloud Launch (v2.1.111, Apr 16, 2026):** Introduced as **`/ultrareview`**,
running a deep, multi-agent cloud review in a sandboxed environment on a branch 
or PR [21, 22].
*   **Harness Command Merge (v2.1.147, May 21, 2026):** **`/simplify` was 
renamed to `/code-review`**, and `/ultrareview` became a sub-parameter of the 
unified code-review suite [23]. 
*   **Namespace Consolidation (v2.1.178, June 15, 2026):** **The preferred 
command became `/code-review ultra`**, while `/ultrareview` was kept only as a 
backward-compatible alias [8, 24].

---

### 8. Scheduled Agents & Routines
*   **Local Intervals (v2.1.71, Mar 7, 2026):** Added the `/loop` command to 
repeat prompts or slash commands natively [16].
*   **Cloud Scheduling (v2.1.76, Mar 14, 2026):** Added the **`/schedule`** 
command (alias `/routines`) to schedule automated agents that execute on 
Anthropic's cloud infrastructure [25].

---

### 9. Skills System Changes
*   **Hot-Reload & Life-Cycle Forking (v2.1.0, Jan 7, 2026):** Enabled automatic
hot-reloading of skills modified on disk, and added support for running skills 
inside a forked subagent context via `context: fork` [26].
*   **Skills & Commands Merge (v2.1.3, Jan 9, 2026):** **Merged slash commands 
and skills under a single mental model** [27].
*   **Tool Restrictions (v2.1.152, May 27, 2026):** Skills gained the 
`disallowed-tools` frontmatter field to prevent Claude from utilizing specific 
tools while active [28].
*   **Nested Skill Loading (v2.1.178, June 15, 2026):** Allowed skills defined 
in nested `.claude/skills` directories to load automatically when working inside
subdirectories [8].
*   **Skill Stacking (v2.1.199, July 2, 2026):** Added support to stack 
slash-skill invocations (e.g., `/skill-a /skill-b do XYZ`) to load up to 5 
leading skills simultaneously [17].

---

### Summary of Flags and renames

| Feature / Tool | Version | Flagged Category | Reverted / Renamed / Breaking 
Changes |
| :--- | :--- | :--- | :--- |
| **Agent Teams** | `v2.1.32` | **Research Preview** [1] | **Breaking change 
(`v2.1.178`):** Removed `TeamCreate`/`TeamDelete` tools in favor of automatic, 
session-derived team setups [8, 9]. |
| **Agent View** | `v2.1.139` | **Research Preview** [29] | Stays active under 
`claude agents` CLI execution [29]. |
| **PowerShell Tool** | `v2.1.84` | **Opt-in Preview** [30] | Progressively 
rolled out as primary Windows shell fallback [21, 30]. |
| **Advisor Tool** | `v2.1.117` | **Experimental** [31] | Active under 
`/advisor` command to consult a second model [32]. |
| **Agent Hooks** | `v2.1.50` | **Experimental** [33] | Active for `type: 
"agent"` verifiers, supporting up to 50 turns [33, 34]. |
| **Dynamic Workflows** | `v2.1.154` | N/A | **Renamed (`v2.1.160`):** Keyword 
renamed from `workflow` to `ultracode` [12]. |
| **`/ultrareview`** | `v2.1.111` | N/A | **Renamed (`v2.1.178`):** Consolidated
under `/code-review ultra` (retained `/ultrareview` as alias) [8, 24]. |

---

📊 I can help you draft a highly customized, project-specific `SKILL.md` 
template or a `.claude/rules/` file that utilizes these native context-scoping 
mechanics to keep your token costs low.

Resumed conversation: 1e23357a-18e6-44e7-80f2-aa5dc65a562d

## S2 follow-up [round 2]: .claude/rules + directory layout + Advisor tool

Different notebook specified, starting new conversation...
Continuing conversation 1e23357a...
Answer:
### 1. `.claude/rules/` Files

#### Format and Frontmatter
**`.claude/rules/` files are topic-scoped instruction documents written in 
standard Markdown format** [1, 2]. Each file can optionally use **YAML 
frontmatter** (delimited by `---` markers) to specify configuration, most 
notably the `paths` field [2, 3].

#### Path-Scoping
The `paths` field allows you to scope instructions to specific file types or 
directories using standard **glob patterns** (such as `**/*.ts` or `src/**/*`) 
[3]. Brace expansion is supported to combine multiple extensions [4]. 
* **Symlink Support**: If Claude accesses a file via a symlinked path, the 
path-specific rules still correctly resolve and match the target file [3, 5]. 

#### Load Timing
* **Unconditional Rules** (files without a `paths` field in their frontmatter) 
are loaded eagerly into context **at launch (session start)** with the same 
priority as `.claude/CLAUDE.md` [2].
* **Conditional Rules** (files with a `paths` field) are **lazily loaded on 
demand** only when Claude explicitly reads or works with files that match the 
specified glob patterns [3, 6, 7].

#### Differences from `CLAUDE.md` and Skills
These three mechanisms are designed to layer instruction density efficiently:

* **vs. `CLAUDE.md`**: `CLAUDE.md` is loaded unconditionally at the start of 
every single session [8, 9]. It is reserved for project-wide conventions, naming
standards, and build/test commands [8, 10]. Topic-scoped rules in 
`.claude/rules/` keep `CLAUDE.md` lean (ideally under 200 lines) by moving 
language-specific or directory-specific guidelines out of the primary session 
startup context [8, 11, 12].
* **vs. Skills**: Skills (`.claude/skills/<name>/SKILL.md`) are prompt-based 
**actionable workflows or reference knowledge** [8, 13]. Unlike rules, skills 
can be explicitly invoked by the user as a custom slash command (e.g., 
`/deploy`) [14, 15]. While rules act as passive standing context when files are 
loaded [1, 3], skills can actively execute processes, accept arguments [16], 
support supporting subdirectory files [17], and use **dynamic context 
preprocessing** (such as executing shell commands via `!cmd` before sending to 
the model) [18, 19].

---

### 2. Full `.claude` Directory Layout

Based on the documentation, Claude Code recognizes the following files and 
directories, split by scope [1, 20-22]:

#### Project-Level Scope
These files and folders live at your repository root or inside `.claude/` and 
can be committed to share with your team [23, 24]:
* **`./CLAUDE.md`** or **`./.claude/CLAUDE.md`**: Core project instructions [1, 
10, 20].
* **`./CLAUDE.local.md`**: Gitignored personal project-specific preferences [25,
26].
* **`./.mcp.json`**: Team-shared MCP server configurations [1, 20].
* **`./.worktreeinclude`**: List of gitignored files to copy into isolated 
worktrees [1, 20].
* **`./.claude/settings.json`**: Project-scope settings (permissions, hooks, env
vars) [1, 20].
* **`./.claude/settings.local.json`**: Personal project settings overrides 
(gitignored) [1, 20].
* **`./.claude/rules/`**: Folder for topic-scoped, path-gated Markdown rules 
files (e.g., `api-design.md`) [1, 2, 20].
* **`./.claude/skills/`**: Folder containing project-specific, auto-discovered 
skills (e.g., `skills/<name>/SKILL.md`) [1, 20, 27].
* **`./.claude/commands/`**: Legacy folder for single-file custom commands 
(handled identically to skills) [1, 20, 28].
* **`./.claude/agents/`**: Configurations for custom subagents, written as 
Markdown files with YAML frontmatter [1, 20].
* **`./.claude/workflows/`**: JavaScript scripts for fanning out and 
orchestrating multi-agent pipelines [1, 20, 29].
* **`./.claude/agent-memory/`**: Version-controlled persistent memory for 
subagents (scoped as `project`) [1, 30].
* **`./.claude/agent-memory-local/`**: Project-scoped but gitignored subagent 
memory (scoped as `local`) [30].

#### Global/User-Level Scope
These files and directories live in your home directory (`~/.claude/` or under 
`CLAUDE_CONFIG_DIR`) and apply across all projects [1, 23]:
* **`~/.claude.json`**: Stores global app state, OAuth tokens, UI toggles, and 
personal MCP server configs [1].
* **`~/.claude/settings.json`**: Machine-global user settings [1, 23].
* **`~/.claude/keybindings.json`**: Custom keyboard shortcuts [1].
* **`~/.claude/CLAUDE.md`**: Global user-level instructions appended to all 
sessions [26].
* **`~/.claude/rules/`**: Global topic-scoped Markdown rules [4].
* **`~/.claude/skills/`**: Global reusable Markdown skills [31].
* **`~/.claude/agents/`**: Global specialized subagents [32, 33].
* **`~/.claude/themes/`**: Custom JSON color themes [1].
* **`~/.claude/plugins/`**: Cloned marketplaces, cached plugin versions, and 
per-plugin data [25, 34].
* **`~/.claude/history.jsonl`**: Complete log of all typed prompts across all 
projects (used for up-arrow recall) [22].
* **`~/.claude/stats-cache.json`**: Cost and token usage data shown by `/usage` 
[22].
* **`~/.claude/remote-settings.json`**: Cached enterprise-wide, 
administrator-managed settings [22].
* **`~/.claude/teams/`**: Stores active multi-agent team runtime state 
(`config.json` inside `{team-name}/` subfolders) [35].
* **`~/.claude/projects/`**: Persistent directory for auto-memory and 
conversation logs:
  * **`projects/<project-slug>/memory/`**: The **native auto-memory** store, 
containing the central `MEMORY.md` index and topic-specific files [1, 36, 37].
  * **`projects/<project-slug>/<session-id>.jsonl`**: Conversational transcripts
[21].
  * **`projects/<project-slug>/<session-id>/subagents/`**: Logs of spawned 
subagents [21].
  * **`projects/<project-slug>/<session-id>/tool-results/`**: Large tool outputs
spilled to disk [21].
* **`~/.claude/file-history/`**: Snapshot backups of modified files used for 
checkpoint restores [21].
* **`~/.claude/plans/`**: Plans generated during plan mode [21].
* **`~/.claude/debug/`**: Per-session debug logs [21].
* **`~/.claude/paste-cache/`** and **`~/.claude/image-cache/`**: Cache for large
pasted text or images [21].
* **`~/.claude/session-env/`**: Session environment metadata [21].
* **`~/.claude/tasks/`**: Persisted lists used by task-tracking and multi-agent 
coordination tools [21, 35].
* **`~/.claude/shell-snapshots/`**: Captured shell variables used for Bash 
execution (cleaned on clean exit) [21].
* **`~/.claude/backups/`**: Config backups created prior to migration events 
[21, 38].
* **`~/.claude/feedback-bundles/`**: Compressed diagnostics package generated by
`/feedback` [21].
* **`~/.claude/todos/`**, **`~/.claude/statsig/`**, **`~/.claude/logs/`**: 
Legacy directories from older versions, scheduled for automatic cleanup [21].

---

### 3. The Advisor Tool (`/advisor`)

#### What It Is and What It Does
The **Advisor tool (`/advisor`)** is an experimental capability in Claude Code 
that **consults a second model for strategic guidance at key moments during a 
task** [39, 40]. 

When active, it sends context or queries to a secondary model to act as a 
"second opinion" or advisory reviewer, validating or critiquing the primary 
agent's approach to help prevent errors or tunnel vision [29, 40].

#### Models Supported
The `/advisor` command accepts several models [40]:
* **`opus`**
* **`sonnet`**
* **`fable`** (added in v2.1.170+)
* A **full model ID** (such as specific provider endpoints)

Running `/advisor` without arguments opens an interactive picker [40]. The tool 
enforces organizational model limits: if a model is blocked by your 
organization's `availableModels` allowlist, the advisor interface will restrict 
it from being chosen [39].

#### When It Was Added
The Advisor tool was introduced as an experimental feature in **version 
v2.1.117** (April 22, 2026), shipping with an "experimental" label in its UI 
dialog, its own learn-more documentation links, and a startup notification to 
alert users of its availability [39].

---

🎯 Would you like me to draft a conditional `.claude/rules/` Markdown file 
customized with specific path wildcards or a PreToolUse hook to restrict 
destructive command execution in your repository?

Resumed conversation: 1e23357a-18e6-44e7-80f2-aa5dc65a562d

## S3 (operator): hook events + session mgmt + agent hooks [round 1]

Different notebook specified, starting new conversation...
Continuing conversation 1e23357a...
Answer:
Here is the complete breakdown of Claude Code's native hook lifecycle events, 
context management systems, and the experimental agent-based verification hooks.

---

### 1. Supported Hook Lifecycle Events and Capabilities

Claude Code supports a rich matrix of lifecycle events configured via settings 
files or plugins `[1, 2]`. Each event falls into one of three execution 
cadences: once per session, once per turn, or on every tool call inside the 
agentic loop `[3]`. 

Below is the complete list of supported lifecycle events and their capabilities 
to **block** actions, **modify** parameters, or **inject** context:

| Hook Event | Trigger Moment `[4-9]` | Capability: **Block**, **Modify**, or 
**Inject** `[10-20]` |
| :--- | :--- | :--- |
| **`SessionStart`** | Begins or resumes a session. | **Inject**: Appends text 
printed to stdout or returned via `additionalContext` directly into the system 
prompt `[21, 22]`. Can also inject `sessionTitle`, `watchPaths`, `reloadSkills`,
and `initialUserMessage` `[23]`. Cannot block `[14, 21]`. |
| **`Setup`** | Started with `--init-only`, or in non-interactive `-p` runs with
`--init`/`--maintenance`. | **Inject**: Injects `additionalContext` for Claude 
`[24]`. Can write variables to `CLAUDE_ENV_FILE` to persist environment changes 
`[25]`. Cannot block `[14, 21]`. |
| **`InstructionsLoaded`** | An instruction file (`CLAUDE.md` or 
`.claude/rules/*.md`) is eagerly or lazily loaded `[4, 25]`. | **Observability 
only**: Used for audit logging, compliance tracking, or debugging. Cannot block 
or modify `[26]`. |
| **`UserPromptSubmit`** | User submits a prompt, before Claude processes it 
`[4, 26]`. | **Block & Inject**: Can block the turn (exit code 2 or `"decision":
"block"`) to erase/prevent prompt execution `[21, 27]`. Can inject 
`additionalContext` or set `sessionTitle` `[27, 28]`. |
| **`UserPromptExpansion`** | User-typed slash command or skill expands into a 
prompt `[4, 29]`. | **Block & Inject**: Can block the command expansion entirely
(exit code 2 or `{"decision": "block"}`) `[11, 17, 30]`. Can inject 
`additionalContext` `[29, 30]`. |
| **`MessageDisplay`** | While assistant message text is streaming or displayed 
`[4, 31]`. | **Modify**: Can replace the visible text shown on screen via 
`displayContent` (the underlying transcript remains original) `[19, 31]`. Cannot
block `[13]`. |
| **`PreToolUse`** | Before a tool call executes `[4, 32]`. | **Block, Modify, &
Inject**: Can block execution (`"permissionDecision": "deny"`) `[32, 33]`. Can 
modify arguments via `updatedInput` `[33]`. Can inject `additionalContext` next 
to tool results `[33]`. |
| **`PermissionRequest`** | A tool permission dialog appears `[4, 34]`. | 
**Block, Modify, & Inject**: Can block/deny or auto-approve the request 
(`behavior: "allow"/"deny"`) `[34, 35]`. Can modify input arguments 
(`updatedInput`) `[34]`. Can inject in-memory or persisted permission rules 
(`updatedPermissions`) `[34, 36]`. |
| **`PermissionDenied`** | A tool call is denied by the auto-mode classifier 
`[4, 37]`. | **Modify / Retry**: Can inject `{"retry": true}` to allow the model
to try alternative approaches `[4, 6, 30, 37]`. |
| **`PostToolUse`** | Immediately after a tool completes successfully `[4, 38]`.
| **Modify & Inject**: Can modify/replace successful tool output 
(`updatedToolOutput`) `[20, 39]`. Can inject `additionalContext` alongside the 
result `[39]`. Cannot block execution since the tool already ran `[12, 40]`. |
| **`PostToolUseFailure`** | After a tool call fails `[4, 41]`. | **Inject**: 
Injects `additionalContext` alongside the error feedback `[42]`. Cannot block 
`[12]`. |
| **`PostToolBatch`** | After a full batch of parallel tool calls resolves, 
before the next model call `[4, 42]`. | **Block & Inject**: Can block/stop the 
agentic loop before the next request (`"decision": "block"`) `[37]`. Can inject 
aggregated context (`additionalContext`) `[37]`. |
| **`Notification`** | Claude Code sends an interface or desktop notification 
`[4, 43]`. | **Observability only**: Matches on `permission_prompt`, 
`idle_prompt`, `agent_needs_input`, etc `[43, 44]`. Used to forward alerts to 
external services `[45]`. Cannot block `[13]`. |
| **`SubagentStart`** | A subagent is spawned via the `Agent` tool `[4, 45]`. | 
**Inject**: Injects `additionalContext` into the subagent's conversation before 
its first prompt `[46]`. Cannot block `[12, 46]`. |
| **`SubagentStop`** | A subagent finishes its execution `[4, 47]`. | **Block & 
Inject**: Can block/deny the stop (`"decision": "block"`) to force the subagent 
to continue working with fed-back reasons `[48, 49]`. Can inject 
`additionalContext` `[47, 50]`. |
| **`TaskCreated`** | A task is initialized via `TaskCreate` `[4, 49]`. | 
**Block**: Can roll back the task creation (exit code 2 or `{"continue": 
false}`) `[49, 51]`. |
| **`TaskCompleted`** | A task is marked as completed or closed `[4, 51]`. | 
**Block**: Can block/prevent a task from closing until quality criteria (like 
tests passing) are met (exit code 2 or `{"continue": false}`) `[51, 52]`. |
| ****`Stop`**** | The main agent has finished responding `[4, 52]`. | **Block &
Inject**: Can block stopping to force continuation (`"decision": "block"`) `[48,
50]`. Can inject final `additionalContext` `[50]`. |
| **`StopFailure`** | Turn ends due to an API error (rate limits, auth, etc.) 
`[4, 52]`. | **Observability only**: Output and exit codes are ignored `[4, 12, 
53]`. |
| **`TeammateIdle`** | An agent team teammate is about to go idle `[4, 53]`. | 
**Block**: Can block the idle transition and feed back corrections (exit code 2 
or `{"continue": false}`) `[53, 54]`. |
| **`ConfigChange`** | A settings file or skill is modified mid-session `[4, 
55]`. | **Block**: Can block the change from taking effect (exit code 2 or 
`"decision": "block"`) to audit/prevent unauthorized modifications, except for 
`policy_settings` `[56, 57]`. |
| **`CwdChanged`** | Working directory is changed (e.g., via `cd` or `/cd`) `[4,
58]`. | **Inject**: Accesses `CLAUDE_ENV_FILE` to reload environment variables 
on directory entries `[56, 58]`. Cannot block `[13, 59]`. |
| **`FileChanged`** | A watched file (specified literally in matcher) changes on
disk `[4, 59]`. | **Inject**: Can dynamically adjust watched files using 
`watchPaths` `[60, 61]`. Cannot block `[13, 61]`. |
| **`WorktreeCreate`** | An isolated git worktree is being set up `[4, 61]`. | 
**Block & Modify**: Replaces default git worktree behavior `[4, 61]`. Must 
return the absolute path to the created directory on stdout or `worktreePath` 
JSON `[61]`. Any non-zero exit code aborts creation `[10, 62]`. |
| **`WorktreeRemove`** | An isolated git worktree is being torn down `[4, 62]`. 
| **Modify**: Handles custom VCS directory removals to match `WorktreeCreate` 
`[62]`. Cannot block `[13, 63]`. |
| **`PreCompact`** | Claude is about to compress the session history `[4, 63]`. 
| **Block**: Can block compaction (exit code 2 or `"decision": "block"`) `[64, 
65]`. |
| **`PostCompact`** | Conversation compaction has finished `[4, 66]`. | 
**Observability only**: Used to log summaries or sync state `[66]`. Cannot block
`[13]`. |
| **`Elicitation`** | An MCP server requests structured user input mid-task `[4,
67]`. | **Block, Modify, & Inject**: Can programmatically intercept and 
accept/decline/cancel the request or inject form field values `[19, 68]`. |
| **`ElicitationResult`** | User submits their response to an MCP elicitation 
`[4, 68]`. | **Block, Modify, & Inject**: Can intercept, block, or override the 
submitted data `[19, 68]`. |
| **`SessionEnd`** | The active session terminates `[4, 66]`. | **Observability 
only**: No decision control; fires for cleanup or logging `[20, 69]`. |

---

### 2. Session and Context Management

#### Auto-Compaction Behavior
When Claude's context window gets full, compaction automatically summarizes the 
conversation to free space, clearing older tool outputs first `[70-72]`. This 
process operates instantly `[73]`. To prevent endless summarization loops, if a 
file or tool output is so massive that the context refills immediately after 
compacting, a circuit breaker stops compaction after **3 consecutive attempts** 
and surfaces a clear error `[72, 74]`.

#### What Survives Compaction
*   **Project-Root `CLAUDE.md`**: Survives compaction natively. After 
summarization, Claude Code re-reads the root instructions from disk and 
re-injects them into the new conversation start `[71, 75]`.
*   **Nested `CLAUDE.md`**: Do **not** re-inject automatically; they will only 
reload the next time Claude reads a file inside that nested subdirectory `[71, 
75]`.
*   **Invoked Skills**: Carried forward within a token budget. Claude Code 
re-attaches the first **5,000 tokens** of the most recent invocation of each 
skill, up to a combined limit of **25,000 tokens** for all skills `[76]`.
*   **Tool outputs / Progress messages**: Discarded to save context `[72, 
77-79]`.

#### Session Resume (`--resume` / `--continue`)
Conversations are persistent and reversible. You can resume sessions in two 
ways:
*   `claude --continue`: Instantly picks up the most recent session `[80]`.
*   `claude --resume`: Presents an interactive picker of previous sessions, 
including background ones marked with `bg` `[80-82]`.
Resuming a session restores the active permission mode that was in use when the 
session closed or when a tool was deferred (except for `plan` and 
`bypassPermissions` modes, which are never carried over) `[83]`. Resumed 
sessions also preserve folders added via `/add-dir` `[84]` and automatically 
switch back to the correct git worktree if the session was isolated `[85]`.

#### Background Task Notifications
When background agents, workflows, or long-running shell commands run 
concurrently, they are managed via a local background-service daemon `[73, 86, 
87]`. When an agent completes or needs input, it fires the `Notification` hook 
with matchers `agent_needs_input` or `agent_completed` `[43, 44, 88, 89]`. To 
protect system integrity, these background task notifications explicitly state 
that no human input has occurred, preventing the model from acting on fabricated
in-transcript approvals `[90]`.

---

### 3. The Experimental `agent` Hook Type

Introduced in version `v2.1.50`, the **`agent` hook type (`type: "agent"`)** 
enables multi-turn, tool-assisted verification of your codebase `[91-93]`. 

#### How Agent Hooks Work
1.  **Trigger and Spawn**: When an event supporting agent hooks fires, Claude 
Code spawns a dedicated **verification subagent** instead of a single-turn 
prompt or a static script `[94]`.
2.  **Input Delivery**: The subagent is seeded with your custom prompt and the 
hook's JSON input data (injected via the `$ARGUMENTS` placeholder) `[94, 95]`.
3.  **Active Verification**: Unlike static prompt hooks, this subagent is given 
native tool access. It can call **`Read`**, **`Grep`**, and **`Glob`** to 
inspect the actual filesystem, search the codebase, check test output, or 
analyze the state of your project `[91, 94, 95]`.
4.  **Limits & Safety Constraints**:
    *   **Timeout**: Default execution window is **60 seconds** `[91, 95]`.
    *   **Turns**: Capped at **50 tool-use turns** to prevent infinite loops 
`[91, 94]`.
    *   **Recursion**: Prompt hooks do not re-fire on tool calls made by the 
agent-hook verifier to avoid infinite recursion loops `[96]`.
5.  **Decision Return**: The subagent evaluates its findings and must return a 
structured JSON decision: `{ "ok": true }` to allow the action, or `{ "ok": 
false, "reason": "..." }` to block it `[30, 94, 97]`. 

If `ok: false` is returned on a `Stop` hook, Claude is blocked from finishing 
the turn and receives the subagent's `reason` as its next instructions to 
continue iterating on the task `[30, 93]`.

---

🛠️ Want me to draft a custom `PreToolUse` hook script to automatically prevent 
dangerous operations like `rm -rf` in your codebase?

Resumed conversation: 1e23357a-18e6-44e7-80f2-aa5dc65a562d

## S4 (end-user): official recommended workflow [round 1]

Different notebook specified, starting new conversation...
Continuing conversation 1e23357a...
Answer:
### Recommended End-to-End Development Workflow

Anthropic's officially recommended development workflow in Claude Code is built 
around the philosophy of **"explore first, then plan, then code"** to prevent 
jumping straight into implementation and solving the wrong problem [1, 2]. The 
complete recommended sequence spans five distinct stages:

```
  [Spec / Interview]
          │
          ▼
   1. EXPLORE & PLAN (Plan Mode, /plan)
          │
          ▼
   2. IMPLEMENT (Manual / acceptEdits Mode)
          │
          ▼
   3. VERIFY (/verify, /goal, Stop Hooks)
          │
          ▼
   4. REVIEW (/code-review ultra, Writer/Reviewer)
          │
          ▼
   5. AUTOMATE & COMMIT (Hooks, gh CLI, /loop)
```

#### 1. Explore & Plan
*   **The Pre-Flight Interview**: For larger features, start with a minimal 
prompt and let Claude **interview you first using the `AskUserQuestion` tool** 
[3]. Claude will ask about technical implementation, UI/UX, edge cases, and 
tradeoffs [3]. Once the spec is written, **start a fresh session** to execute it
with a clean context [3].
*   **Plan Mode**: Enter plan mode directly (using `Shift+Tab` or `/plan `) [2, 
4, 5]. In this mode, Claude explores the codebase and reads files without making
any changes to your source files [2, 5]. 
*   **Drafting & Editing the Plan**: Ask Claude to generate a detailed 
implementation plan [2]. You can press `Ctrl+G` to open the plan in your local 
text editor for direct editing, or use the interactive markdown plan preview in 
VS Code to add feedback and comments [2, 6, 7].

#### 2. Implement
*   **Execution**: Switch out of plan mode into `acceptEdits` or `manual` mode 
(using `Shift+Tab`) [2, 5]. Let Claude implement the changes, utilizing its own 
git snapshot checkpoints so any file edits remain fully reversible if you need 
to `/rewind` [8, 9].

#### 3. Verify
*   **Continuous Verification**: Provide explicit verification criteria (e.g., 
test cases, build scripts, or visual screenshots) so "looks done" isn't the only
stopping signal [10, 11]. 
*   **Built-in Verification Skills**: Use the bundled `/verify` and `/run` 
skills to build, launch, and interactively observe the app's behavior to confirm
the changes work in a live environment rather than just passing unit tests [12].
*   **Automation Gates**: Set the verification check as a `/goal` condition that
Claude must achieve before stopping [13]. For unattended runs, enforce 
verification deterministically via a **Stop hook** [13] or an **agent-based Stop
hook** that runs your test suite and blocks the turn from ending until tests 
pass [14, 15].

#### 4. Review
*   **Local Review**: Run `/code-review` (or `/simplify` for non-bug-hunting 
cleanup) on your working diff to catch bugs, styling violations, and 
opportunities for reuse [16, 17]. 
*   **Cloud-Scale Review**: Run `/code-review ultra` (or `/ultrareview`) to run 
a deep, multi-agent cloud review in a sandboxed environment on a branch or PR, 
allowing you to automatically apply fixes or post findings directly as inline 
GitHub comments [16, 18, 19].

#### 5. Automate & Commit
*   **VCS Integration**: Use the `gh` CLI natively within Claude to create 
commits, push branches, and open pull requests [20]. 
*   **Deterministic Automation**: Set up **Hooks** in `.claude/settings.json` 
(such as `PostToolUse` on edit/write) to automatically run formatters (like 
Prettier) or linters after edits [21, 22]. 
*   **Recurring Runs**: For long-horizon automation, use the `/loop` command to 
run recurring maintenance checks or monitor deployments [23].

---

### When to Use: Single Session vs. Subagents vs. Agent Teams

The docs recommend matching the architectural complexity to the scope, 
parallelizability, and context demands of the task [24, 25]:

| Approach | Recommended Use Cases | Context & Token Dynamics |
| :--- | :--- | :--- |
| **Single Session** | • **Routine, sequential tasks** (renaming variables, 
small bug fixes, minor additions) [25, 26].<br>• Tasks requiring **frequent, 
tight human back-and-forth** or iterative refinement [27].<br>• Edits that 
happen in the **same files** [28].<br>• When latency is a priority [27]. | 
**High Accumulation**: The entire history, read files, and tool outputs reside 
in a single context window, which fills up quickly and may trigger frequent 
auto-compaction [29-31]. |
| **Subagents** | • **Isolating high-volume operations** (running tests, parsing
massive logs, or fetching heavy documentation) [32, 33].<br>• Codebase 
**investigations and research** that would otherwise flood your main chat with 
unneeded file reads [32, 34].<br>• Standard **read-only codebase exploration** 
(using the built-in `Explore` subagent) [35]. | **Isolated Windows**: Subagents 
run in completely fresh, separate context windows [36, 37]. They execute the 
heavy file-reading/searching separately and return only a concise summary to the
main session [32, 37]. |
| **Agent Teams** | • **Complex, long-horizon tasks** requiring parallel 
exploration and multi-perspective collaboration [38, 39].<br>• Tasks with 
**well-defined, independent boundaries** (e.g., frontend developer, backend 
developer, and QA engineer) [28, 38].<br>• Investigating **competing 
hypotheses** or running parallel reviews [38]. | **Horizontal Scale (Highest 
Cost)**: Each teammate is a fully independent Claude Code session running in its
own context window [40, 41]. Teammates self-coordinate via a shared task list 
and communicate directly via a local mailbox [42]. |

*   **The Transition Point**: If you are running multiple parallel subagents but
hitting main-session context limits, or if your workers need to actively 
communicate with each other, negotiate task dependencies, and collaborate, you 
should transition to **Agent Teams** [25, 43].

---

### Recommended Patterns for Design & Multi-Perspective Review

The documentation lays out several highly structured patterns to guarantee 
rigorous, multi-perspective reviews both before and after code changes are made:

1.  **The Interactive Spec Interview (Pre-Implementation)**: Before writing a 
single line of code for a major feature, start with a minimal prompt and use the
`AskUserQuestion` tool to let Claude interview you [3]. This forces the model to
proactively raise edge cases, UI/UX tradeoffs, and technical constraints you may
not have considered [3]. The spec is written to disk, and a **fresh session is 
opened** to execute it with zero context clutter [3].
2.  **The Writer/Reviewer Pattern (Multi-Session)**: Run two concurrent Claude 
Code sessions [44]. Session A (the "Writer") implements the code [44]. Session B
(the "Reviewer") is kept in a completely fresh, unbiased context and is asked to
review Session A's implementation, specifically searching for edge cases, race 
conditions, and architectural consistency [44].
3.  **Adversarial Debate with Competing Hypotheses (Agent Teams)**: When 
investigating a complex bug or architectural direction, spawn an agent team 
where teammates are explicitly assigned **adversarial, competing theories** 
[45]. Each teammate's goal is to actively gather evidence to prove their own 
theory while trying to disprove and critique the alternative theories of other 
teammates [45]. This structured debate prevents cognitive anchoring and forces 
the team to converge on the truest root cause [45].
4.  **Independent Subagent Diff Review (Post-Implementation)**: Before treating 
a task as complete, spawn an independent reviewer running in a **fresh subagent 
context** [46]. Because the subagent sees only the final diff and the acceptance
criteria (and not the conversational history or assumptions that produced it), 
it evaluates the change entirely on its own merits [46].

---

⚙️ I can draft a conditional `.claude/rules/` Markdown file or setup a custom 
`PreToolUse` hook to automatically enforce your team's code review checklist 
before any git commits are made.

Resumed conversation: 1e23357a-18e6-44e7-80f2-aa5dc65a562d

## S5 (KR O1-KR3): documented limitations + knowledge curation gap [round 1]

Different notebook specified, starting new conversation...
Continuing conversation 1e23357a...
Answer:
### Agent Teams (代理团队)

*   **Token 成本警告（Cost Warnings）**：Agent Teams 是一个高消耗、高 Token 
成本的特性 [1, 2]。每个团队成员都是一个完全独立的 Claude Code 
实例，拥有各自的上下文窗口，Token 消耗量随活跃成员数量呈**线性增长** [2, 
3]。此外，还会带来额外的团队通信与协调开销 [3, 4]。
*   **非目标场景（Explicit Non-goals）**：官方文档明确指出，Agent Teams 
**不适用于**顺序执行的任务、对相同文件的并发编辑，或者依赖过多的任务 
[4]。在这些场景下，单会话（Single Session）或前台子代理（Subagents）反而更加高效
[4]。
*   **协调与已知限制（Coordination Limits）**：
    *   **不支持会话恢复与回滚**：`/resume` 和 `/rewind` 指令无法恢复 in-process
Teammates [5]。在恢复会话后，Leader 可能会向已失效的队友发送消息，必须由用户指示
Leader 重新派生队友 [5]。
    *   
**任务状态同步滞后**：队友有时会无法及时将任务更新为已完成（Completed），导致依
赖该任务的后续任务被挂起或阻塞 [5]。
    *   **退出/关停速度慢**：队友必须在完成当前的 API 请求或工具调用后才能响应 
Leader 的 shutdown 关停指令 [5]。
    *   **单团队限制**：一个 Session 仅能承载一个团队，团队状态随 Session 
绑定，无法跨会话共享 [5]。
    *   **不支持嵌套团队**：队友（Teammates）不能再创建自己的 Teammates，只有 
Leader 能够管理团队 [5]。
    *   **In-process 队友无法调用 background subagents**：In-process Teammates 
派生的 subagents 必须在前台运行，若设置 `background: true` 或 
`run_in_background` 会直接报错（因为队友的后台工作不能超过 Lead 进程的生命周期）
[5]。
    *   **Lead 角色固定**：主会话在生命周期中被锁定为 
Leader，无法中途更换或将队友提拔为 Leader [5]。
    *   **权限设定不灵活**：所有队友在生成时必须继承 Leader 的权限模式（如 
`--dangerously-skip-permissions`），不支持在派生时单独设定 [5]。

---

### Subagent Memory (子代理内存)

*   **持久性保证（Persistence Guarantees）**：子代理的 transcript 
历史保存在独立的 JSONL 文件中（如 `agent-{agentId}.jsonl`） [6]。当主会话触发 
Compaction（上下文自动压缩）时，子代理的 transcript 完全不受影响 
[7]。这些历史文件在 Session 周期内持续保留，直到触发 `cleanupPeriodDays`（默认 
30 天）被自动清理 [7]。
*   **模型与状态阻隔（Staleness & Scope）**：
    *   **无法 resume 一次性代理**：内置的 `Explore` 和 `Plan` 
子代理是“一会性（one-shot）”的，不返回 
`agentId`，因此**无法被恢复（resume）**，只有 `general-purpose` 
或自定义子代理才支持 resume [8]。
    *   **信息阻隔**：为了追求极致的高速度和低成本，`Explore` 和 `Plan` 
子代理默认在启动时会跳过（忽略）`CLAUDE.md` 和 `git status` [8-10]。
    *   
**深度与生命周期锁定**：后台子代理的深度（depth）在首次派生时即被锁定（最大 5 
层） 
[11]。如果从浅层上下文重新唤醒它，它也无法突破深度限制去生成更深层次的嵌套子代理
[11]。
*   **什么不被存储（What is NOT stored）**：
    *   子代理并不会在其 memory 中保存那些已经在 repository 
中显式存在的事实，比如代码库的结构、Git 提交历史或 `CLAUDE.md` 中的既定规则 
[12]。

---

### Auto-Memory (自动记忆)

*   **设计局限与失败模式（Failure Modes）**：
    *   **它不是硬性配置（not enforced configuration）**：Claude 仅将 
auto-memory 视为普通上下文，并不保证会 100% 
严格遵守。如果某项规则非常重要、必须每次执行，则应当写在 Hooks 中而非 prompt 
instructions [13, 14]。
    *   **物理局限性（Machine-local）**：Auto-memory 
是保存在本地的（`~/.claude/projects/`），它通过 Git repo 的 slug 来共享（跨 
worktrees），但**无法跨机器或云端环境共享** [15, 16]。
    *   **潜在冲突与歧义**：如果记忆中存在相互矛盾的规则，Claude 
可能会随机选择其中一个去执行 [17]。
*   **大小限制（Size Limits）**：
    *   为了防止上下文膨胀，Claude 在会话启动时，只会加载主 `MEMORY.md` 
索引文件的**前 200 行或前 25KB**（先到为准），超出部分会被截断 
[18]。具体的细节笔记由 `MEMORY.md` 指向各个独立的 topic 文件（如 `debugging.md`,
`patterns.md`），而这些 topic 文本文件在启动时**不加载**，只有在 Claude 
判定其相关时才通过文件工具按需（on-demand）调取 [18]。

---

### Skills (技能系统)

*   **触发可靠性警告（Trigger Reliability Caveats）**：
    *   Skills 默认是在 session start 时加载其名称与 description（大约每个 skill
消耗 100 tokens 词量） [19]。Claude 依靠将当前的任务匹配 skill 的 description 
来决定是否调用 [20]。如果 skill 的 **description 
写得含糊不清或相互重叠**，Claude 极易调用错误的 skill 或漏掉真正有用的 skill 
[20]。
    *   若 `CLAUDE.md` 过于冗长，规则容易在噪音中丢失，导致 skill 无法被正常应用
[21]。
*   **上下文预算限制（Context Budget Limits）**：
    *   **触发截断**：由于 token 成本控制，skill 列表的 description 和 
`when_to_use` 被硬性限制在 **1,536 个字符**内，多余部分在 skill 列表中会被截断 
[22]。
    *   **自动压缩阶段的丢弃危险**：当会话面临 
Compaction（上下文压缩）时，系统为了释放空间，只会将最近调用的 skills 的前 
**5,000 个 tokens** 重新附加（re-attach）到压缩后的 context 之后，所有 skill 
分享的联合重加载上限为 **25,000 tokens**。这意味着如果一个会话中你调用了太多的 
skill，那些**较老（更早调用）的 skills 会在压缩时被彻底丢弃（dropped 
entirely）** [23]。

---

### Hooks (生命周期钩子)

*   **什么事件不能拦（CANNOT Block）**：
    根据官方决策控制（Decision 
Control）矩阵，以下生命周期事件是**只读/仅用于观测（Observability 
only）**的，挂载在这些事件上的 Hooks 无论如何都**无法阻塞（Cannot 
Block）**该生命周期的进程 [24-26]：
    *   `PostToolUse` 和 
`PostToolUseFailure`（工具此时已经运行完毕或失败，无法挽回） [25, 27]
    *   `PermissionDenied`（拦截动作已执行完） [25]
    *   `Notification` [25]
    *   `SubagentStart` (仅在 spawn 时进行 context 注入) [25, 28]
    *   `SessionStart` / `Setup` / `SessionEnd` (无阻塞能力，只用于初始化或清理)
[26, 29, 30]
    *   `CwdChanged` / `FileChanged` / `PostCompact` [26, 29]
    *   `WorktreeRemove` (失败仅在 debug 模式记录) [26]
    *   `InstructionsLoaded` (用于合规审计等) [31, 32]
    *   `StopFailure` (API 错误导致 turn 终止，直接忽略 hook 返回值) [25, 33]
*   **Hooks 已知的设计局限与空白（Documented Gaps）**：
    *   **不能调用内部指令**：Command-type hooks 只能通过 stdout、stderr 和 exit
codes 交流，**绝对无法触发 `/` 命令或工具调用** [27]。
    *   **非交互模式限制**：`PermissionRequest` 钩子在非交互模式（`-p` 
flag）下是**不触发（don't fire）**的 [27]。在非交互下自动处理权限，必须在 
`PreToolUse` 级别拦截 [27]。
    *   **Stop hook 的全局连续阻塞上限**：防止 Claude 
陷入无限工作循环，主代理在连续被 Stop 钩子阻塞 **8 次**之后，会强制 override 
钩子并终止 turn （除非通过环境变量 `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` 提高上限） 
[34-36]。
    *   **并发非确定性（Non-deterministic）**：当多个 `PreToolUse` 
重新改写同一个 tool 调用的 `updatedInput` 时，只有最晚执行完的 hook 
才会生效。由于 hooks 在系统内是并行的，其先后顺序不确定 [27]。
    *   **不能绕过硬性交互工具**：对于标记为 `requiresUserInteraction` 的 MCP 
工具（如 `AskUserQuestion` 等），Hooks 即使返回 `"allow"` 也无法绕过其 
interactive permission prompt，因为系统无法判定 Hook 是否在自身 UI 
收集了用户的实际输入 [37]。
    *   **退出超时极短**：`SessionEnd` 钩子默认超时时间仅为 **1.5 
秒**（可手动覆盖至最高 60 秒），若清理工作过于耗时会被强制杀死 [30]。

---

### 跨会话知识整理/蒸馏（Knowledge Curation/Distillation）机制

目前 Claude Code 中 
**并没有一套全自动的、生产级（production-ready）的跨会话知识深度整理与自适应更新
系统（如自动去重、权重衰减/老化、跨会话自动合并等）**。

系统提供的相关机制是**由模型引导、并由用户/模型协作来手动或局部维护**的：
1.  **内置防重复写入规则**：当模型决定向 auto-memory 保存新的 takeaway 
时，系统会在 System Prompt 
中注入规则，要求其在写入前检索是否已有相同主题的文件（Update, don't duplicate） 
[12]。
2.  **文件级重组逻辑**： auto-memory 包含一个主索引 `MEMORY.md` 
[16]。模型被要求时刻保持 `MEMORY.md` 简洁（限制在 200 行/25KB 
内），当接近该限制时，模型会被 
Remind（提醒）去手动**将旧的、详细的记忆提炼并归档到其他的 topic markdown 
文件（如 `debugging.md`, `patterns.md`）中** [18, 38]。
3.  **最终清理控制在用户手中**：所有的 auto-memory 文件、topic 文件都是以明文 
markdown 的形式保存在本地 `~/.claude/projects/` 目录下 [39, 40]。用户可以通过 
`/memory` 命令查看并直接用编辑器编辑、删除任何已存记忆，或者执行 `claude project
purge` 来一键彻底清除某个项目在 Claude Code 中的所有本地状态、历史与 memories 
[40, 41]。

🔄 我们可以针对您的工作区和代码规范，设计并编写一个专门针对 `CwdChanged` 或 
`SessionEnd` 事件的 Hook 脚本（例如定期检测您的 auto-memory markdown 
文件并利用脚本去除陈旧规则）。您需要我为您起草一个这样的自动化维护脚本吗？

Resumed conversation: 1e23357a-18e6-44e7-80f2-aa5dc65a562d

