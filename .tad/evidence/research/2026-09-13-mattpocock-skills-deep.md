# Deep research: mattpocock/skills

**Date**: 2026-09-13  
**Mode**: Alex `*research --deep` (Cursor / cursor-grok-4.6-medium)  
**Decision point (human, pre-answered)**: What is this repo actually doing, and which (if any) ideas are **thin optional deltas** for upstream TAD — **not** wholesale adoption, not copying the repo.  
**Out of scope (human locks)**: KEEP11 knives; publish; editing capability-packs wholesale; inventing KPIs; Gemini; Blake; editing TAD product gates; push/tag.

## Research method / degradation

| Layer | Status |
|-------|--------|
| Local Wiki | Present; **no prior match** on this topic (fresh). Full canon/wiki compile **not** run (would expand `research/canon/` beyond the requested deliverable). |
| NotebookLM | **Unavailable** (`~/.tad-notebooklm-venv/bin/notebooklm` missing). |
| Primary sources | `gh api` + `curl` against GitHub + skills.sh HTML meta. Prefer remote reads; no durable clone left in `/tmp`. |
| Adversarial (Phase 0c/4c) | **Off.** Human: **NO Gemini**. Channel locked to Cursor. Codex exists on host but was not invoked. |

**Repo pin**: `mattpocock/skills` @ `3cca18b368ae95cdbdebbff572ccafa662551015` (merge 2026-09-04, `link-skills: stop linking misc/`).  
**Live metadata** (`gh api repos/mattpocock/skills`, 2026-09-13): MIT, default `main`, created 2026-02-03, **260778** stars, **22005** forks, homepage `https://aihero.dev/skills`, package `mattpocock-skills` **1.2.3**, **164** blobs in recursive tree. Treat star counts as social proof, not quality.

**research_complexity**: complex (landscape + comparison). Dynamic seeds: on (comparison axes below). Adversarial: off (human lock).

---

## 1. What it is

Matt Pocock’s **personal, promoted set of Agent Skills** (“Skills For Real Engineers”), published as:

1. A **Claude Code plugin** (`mattpocock-skills`, official marketplace) — subscribe, read-only, auto-update.  
2. **skills.sh / `npx skills@latest add mattpocock/skills`** — copy editable files into a project (Codex and other Agent-Skills harnesses).

It is **not** a two-agent quality framework, not a gate system, and not a product-process OS. It is a **library of composable slash-skills** plus a small per-repo setup that points engineering skills at an **issue tracker** and a **ubiquitous-language** doc (`CONTEXT.md` + ADRs).

Self-positioning (README, first screen): GSD, BMAD, and Spec-Kit “try to help by owning the process” and thereby “take away your control”; these skills are “small, easy to adapt, and composable,” “work with any model,” “based on decades of engineering experience.”

## 2. Problem it claims to solve

Four failure modes (README “Why These Skills Exist”):

| # | Failure | Named fix |
|---|---------|-----------|
| 1 | Agent didn’t do what I want (misalignment) | Grilling: `/grill-me` / `/grill-with-docs` |
| 2 | Agent too verbose (no shared jargon) | Domain model: `CONTEXT.md` + ADRs via `/grill-with-docs` → `/domain-modeling` |
| 3 | Code doesn’t work | Feedback loops: `/tdd`, `/diagnosing-bugs` |
| 4 | Ball of mud (entropy under agent speed) | Deep modules: `/to-spec` seam quiz, `/improve-codebase-architecture`, `/codebase-design` |

These are classic SE problems restated for coding agents. The distinctive product is **grilling as the default front door**, not spec-first or role-first.

## 3. Install / runtime

### 3.1 Two exclusive routes

Canonical wording lives in `.agents/install-block.md` (README must copy it).

| Route | Command | Philosophy |
|-------|---------|------------|
| Claude Code plugin | `claude plugins install mattpocock-skills` or `/plugin install mattpocock-skills` | Managed bundle; official marketplace (`claude-plugins-official`); **auto-update**. ADR 0002: official listing **pins a SHA**, so users lag `main` until the pin moves. |
| skills.sh | `npx skills@latest add mattpocock/skills` | Editable copies; choose skills + target agents; `npx skills update` to pull. **Must include `setup-matt-pocock-skills`** if using engineering publish skills. |

**Do not install both** (duplicate skills).  
`.claude-plugin/marketplace.json` is an **undocumented fallback** (fork / unreleased commit), not the user story.

**Codex plugin**: deferred. ADR 0002: Codex `plugin.json` accepts **one** skills path string and recurses; bucketed `skills/engineering` + `skills/productivity` (excluding `misc/` / `in-progress/` / `deprecated/`) cannot be expressed as a single path without shipping drafts. Dual-harness instead: each skill has `agents/openai.yaml` (`interface.display_name`, `interface.short_description`; user-invoked: `policy.allow_implicit_invocation: false`). `AGENTS.md` is a symlink to `CLAUDE.md` (changelog 1.2.0).

Maintainer local install: `scripts/link-skills.sh` symlinks into `~/.claude/skills` and `~/.agents/skills` (HEAD commit **excludes `misc/`**).

### 3.2 Per-repo runtime (`/setup-matt-pocock-skills`)

User-invoked, **prompt-driven not a script**. Explores remotes, existing `CLAUDE.md`/`AGENTS.md`, `CONTEXT.md`, `docs/adr`, `.scratch/`, whether `triage` is installed, monorepo signals. Then writes:

- Pointer block `## Agent skills` in existing `CLAUDE.md` **or** `AGENTS.md` (never invents the other).  
- `docs/agents/issue-tracker.md` from GitHub / GitLab / local-markdown templates (or freeform “other”).  
- Optional `docs/agents/triage-labels.md` **only if triage is installed**.  
- `docs/agents/domain.md` (single-context default).

**ADR 0001**: only **hard-dependency** skills (`to-tickets`, `to-spec`, `triage`) must say “run setup if missing.” Soft skills (`tdd`, diagnose, architecture) stay token-light.

**Issue-tracker coupling**: GitHub (`gh`), GitLab (`glab`), local `.scratch/<feature>/issues/<NN>-<slug>.md`, or custom prose. Out-of-scope note: **mainstream trackers only**; niche backends refused (#99 dex). Linear is **not** first-class in the skill body (README still says “GitHub, Linear, or local” — **doc drift**).

### 3.3 Invocation model (the load-bearing architecture)

`.agents/invocation.md`:

- **User-invoked**: `disable-model-invocation: true` + Codex `allow_implicit_invocation: false`. Human-facing one-line `description`. **No other skill may fire it.**  
- **Model-invoked**: rich trigger `description`; user *or* model; other skills compose via **`Call the Skill tool with "name"`** (not `/slash` in operative steps; not relative `../other/SKILL.md`). One skill per Skill-tool call.

Invariant: user-invoked may call model-invoked; **never** user-invoked → user-invoked. Setup is always “tell the human to run `/setup-…`”.

Router: `/ask-matt` (user-invoked) maps flows so the human is the index. CLAUDE.md: if a promoted skill is added/renamed, **re-sync ask-matt** or the router lies.

### 3.4 How work actually runs (ask-matt main flow)

`idea → /grill-with-docs → (/prototype via /handoff if needed) → /to-spec → /to-tickets → /implement`  
`/implement` drives `/tdd` at seams and `/code-review` (Standards + Spec, parallel sub-agents) then **commits**.

Context hygiene: keep grill+spec+tickets in **one window**; `/implement` starts fresh per ticket. Smart-zone ~150k tokens; `/compact` is last among continue / clear / handoff / subagent / compact (`PHASE-BOUNDARIES.md`).

On-ramps: `/triage` (incoming issues you didn’t create), `/diagnosing-bugs`, `/wayfinder` (fog bigger than one session — **decisions not deliverables**, then merge at `/to-spec`, not straight to implement).

## 4. Skill inventory (grouped)

**Promoted** (plugin.json array, 25 paths; also README + bucket README + `docs/<bucket>/<name>.md` at `https://aihero.dev/skills-<name>`).

**Git tree**: **37** `SKILL.md` files, **37** `agents/openai.yaml`.  
**skills.sh HTML meta** (curl 2026-09-13): “**53** agent skills from mattpocock/skills”. That **does not match** the 37 SKILL.md blobs on HEAD. Treat 53 as **overclaim / indexer lag / counting non-SKILL artifacts**.

### 4.1 Engineering — user-invoked (orchestrators)

| Skill | SKILL.md size (bytes, git tree) | Notes |
|-------|----------------------------------|-------|
| ask-matt | 11417 | Router; fattest promoted skill after wayfinder. |
| grill-with-docs | **247** | Body is two Skill-tool calls: `grilling` + `domain-modeling`. |
| triage | 6557 | Issue/PR state machine; labels; hard setup dep. |
| improve-codebase-architecture | 5993 | Survey deepening; HTML report; YAGNI via recent commits. |
| setup-matt-pocock-skills | 6841 | Per-repo config. |
| to-spec | 3043 | Synthesize conversation → spec on tracker; **no interview**; seam check; `ready-for-agent`. |
| to-tickets | 5671 | Tracer bullets + blocking edges; wide-refactor expand/contract. |
| implement | **433** | Thin: tdd + typecheck + code-review + **commit**. |
| wayfinder | 11908 | Multi-session decision map on tracker. |

### 4.2 Engineering — model-invoked (discipline)

| Skill | Size | Notes |
|-------|------|-------|
| prototype | 2931 | Throwaway HTML (logic) or UI variants; keep on `prototype/<name>` branch as primary source. |
| diagnosing-bugs | 8529 | Red loop → minimise → hypothesise → instrument → fix; **Redact** secrets (1.2.3). |
| research | **794** | Background agent; **primary sources**; one cited md in-repo. |
| tdd | 3549 | Reference-only red→green; **seam**; tautological-test anti-pattern; refactor deferred to review. |
| domain-modeling | 3331 | Glossary + ADR + `CONTEXT.md`. |
| codebase-design | 6446 | Ousterhout deep modules; `DESIGN-IT-TWICE.md`. |
| code-review | 6589 | Two axes; Fowler smell **baseline** (judgment, not hard fail); repo standard wins. |
| resolving-merge-conflicts | 918 | Hunk-by-intent; never `--abort`. |
| wizard | 4123 | Interactive bash for **human-only** clicks/secrets; `template.sh`. |

### 4.3 Productivity — user-invoked

| Skill | Size | Notes |
|-------|------|-------|
| grill-me | **157** | Entire body: `Call the Skill tool with "grilling".` |
| handoff | 894 | Compact conversation to **OS temp dir** (not workspace); suggested skills; no duplicate of specs/ADRs. |
| teach | 9506 | Multi-session teaching workspace + reusable `./assets/`. |
| to-questionnaire | 2904 | Grill the **send**, not the subject. |
| wait-what | **394** | Listener-state micro-skill; ASD-STE100 + `CONTEXT.md`. |

### 4.4 Productivity — model-invoked

| Skill | Size | Notes |
|-------|------|-------|
| grilling | 1987 | Shared interview primitive: **rounds / frontier**; facts vs decisions; confirm before acting. |
| writing-for-agents | 10886 | Meta-skill for skills/AGENTS/CLAUDE; `SKILL-MECHANICS.md` for invocation. |

### 4.5 Non-promoted

**misc/** (plugin excluded; link-skills no longer links): git-guardrails-claude-code (PreToolUse block dangerous git), migrate-to-shoehorn, scaffold-exercises, setup-pre-commit.  
**in-progress/** (beta, skills.sh `--skill=`): loop-me, writing-beats/fragments/shape, claude-handoff (`claude --bg`), setup-ts-deep-modules (dependency-cruiser), implement-spec (concurrent implementer subagents → one PR), retro (**STUB**).  
**deprecated/**: empty bucket; retired skills are **deleted** (changelog 1.2.0 removed six).

### 4.6 Composability / triggers / tracker

- **Thin wrappers** (`grill-me`, `grill-with-docs`) prove the architecture: orchestrators are user-invoked; discipline is model-invoked and reused.  
- **Triggers**: model-invoked descriptions recruit pretrained **leading words** (`grill`, `prototype`, `wait`). User-invoked descriptions strip “use when…”.  
- **Tracker coupling**: high for to-spec / to-tickets / triage / wayfinder / implement close-out; **zero** for grill-me / wait-what / writing-for-agents / tdd (soft).  
- **Issue hygiene**: `to-tickets` produced tickets must **not** be triaged again.

## 5. Design principles (from their own docs)

1. **Composability over process ownership** — small skills the user can hack; contrast GSD/BMAD/Spec-Kit.  
2. **Invocation split as a load budget** — user-invoked spends *human* cognitive load; model-invoked spends *context* load. Router skills cure “too many user commands to remember.”  
3. **Skill tool, not slash, in operative steps** — harness-neutral.  
4. **Progressive disclosure** — in-file steps vs disclosed reference; `writing-for-agents`.  
5. **Environment is SSOT; docs are cache** — don’t restate `package.json` / `--help`. Aligns with TAD “never hand-write what a tool already does.”  
6. **Leading words** over coined jargon (`frontier`, `seam`, `decision ticket`, `smart zone`).  
7. **Prompt the positive** (negation / elephant); **negative space** = omitted branches are silent priors.  
8. **Facts vs decisions** — agent looks up facts; humans answer decisions; grilling wait-gate.  
9. **HITL vs AFK** on wayfinder tickets — grilling answering itself is a known failure they named.  
10. **Hard vs soft setup dependency** (ADR 0001).  
11. **No em-dashes** house style (CLAUDE.md) — process tax, not engineering.  
12. **Human-facing docs contract**: What it does / When to reach / Common questions / It’s working if.

## 6. Comparison

### 6.1 vs TAD (this repo)

| Axis | mattpocock/skills | TAD (upstream as of 2026-09) |
|------|-------------------|-------------------------------|
| Unit of design | Composable Agent Skills | Two roles (Alex/Blake) + Gates 1–4 + handoff contract |
| Who owns process | Human picks `/ask-matt` flows; skills don’t own the SDLC | TAD **does** own a default path (`/alex` `/blake` `/gate`); Lite frozen |
| Alignment | Grilling rounds (frontier) until confirm | Socratic 3–5 + Adaptive Complexity; human decides depth |
| Spec | `/to-spec` from conversation, published to **issues** | Handoff §AC + design docs; not GitHub-issue-native |
| Implementation | Same agent `/implement` + TDD + self code-review + commit | Blake + Ralph + independent Layer 2 reviewers; Alex **must not** implement |
| Review | Two-axis subagents inside one skill | spec-compliance-reviewer + code-reviewer; Gate 3/4 split |
| Knowledge | `CONTEXT.md` glossary + ADRs | `.tad/project-knowledge/` + journals + distillation |
| Research | Thin primary-source background agent | Local Wiki Iron Rule + NotebookLM fallback; no Gemini this session |
| Handoff | Temp-dir session compact | Gate-2 reviewed HANDOFF is Blake’s only info |
| Distribution | Plugin subscribe **or** editable copy | `tad.sh` / versioned framework; not “subscribe to Matt” |
| Skill size | 157 B wrappers … ~12 KB wayfinder | Role SKILLs are large protocols; packs pointer-then-escalate |
| Tracker | First-class GitHub/GitLab/local | Optional; TAD state is files under `.tad/` |
| Safety | misc git-guardrails (not promoted) | Friction protocol, SAFETY entries, no Alex hook writes |

**Overlap already in TAD (do not re-import):** two-axis review, elicitation before build, AC/spec vs implementation, progressive disclosure of packs, environment-as-SSOT, “express ≠ skip review.”

### 6.2 vs GSD / BMAD / Spec-Kit (as *they* claim + primary blurbs)

Matt’s claim is one sentence: those three **own the process** and steal control / make process bugs hard to fix. Brief primary check (2026-09-13):

| System | What it actually is (their README, not Matt) | Fit to Matt’s jab |
|--------|-----------------------------------------------|-------------------|
| **Spec-Kit** (`github/spec-kit`, ~136k★) | Spec-driven toolkit: constitution → specify → plan → tasks → implement → **converge**. Specs become executable. Multi-agent integrations. | **Mostly fair.** A prescribed SDD pipeline *is* process ownership. Extensible, but the spine is owned. |
| **BMAD** (`bmad-code-org/BMAD-METHOD`, ~53k★) | Agile AiDD: Clarify / Plan / Build / Learn; `npx skills add bmad-code-org/BMAD-METHOD`; plugin marketplaces; `bmad setup` / `bmad-build` / `bmad doctor`. “Decisions stay explicit.” | **Fair historically and now.** TAD itself forked-and-simplified BMAD (10+ fictional roles → 2). BMAD still ships a method + runtime. |
| **GSD** | Ambiguous name. Live agent-SDD cluster: `open-gsd/gsd-pi` (gsd-2 archived redirect) — “meta-prompting, context engineering and spec-driven development” for long autonomous runs. Also unrelated `open-gsd/gsd-core` “Git. Ship. Done”. | Matt almost certainly means **agent GSD (Pi / gsd-2)**, not Git.Ship.Done. **Unverified** which exact product he named. The jab (“owns process, long autonomous”) matches GSD Pi’s self-description better than Spec-Kit’s converge loop. |

TAD is closer to **BMAD-simplified** than to Matt’s library: TAD still owns gates/roles. Matt is closer to a **skill catalog + interview primitive**. Spec-Kit is spec-as-king. GSD-Pi is long-horizon autonomy.

## 7. Risks / overclaim

1. **“Small, easy to adapt”** vs **wayfinder 12 KB + ask-matt 11 KB + writing-for-agents 11 KB**. Some skills are small; the *system* is not small if you take the main flow.  
2. **“Works with any model”** — dual-harness metadata is real (Claude + Codex yaml); “any model” is marketing. Wizard/git hooks are bash-shaped.  
3. **skills.sh “53 skills” vs 37 SKILL.md** on pinned HEAD.  
4. **README Linear** vs setup skill GitHub/GitLab/local/other.  
5. **Official plugin SHA pin** (ADR 0002) vs “updates arrive automatically” — auto-update of a **lagging pin**, not `main`. They documented this; README still sounds live-at-HEAD.  
6. **Star count ~261k** — extraordinary; do not use as a quality argument.  
7. **`/implement` commits** — process bug if the human wanted review-before-commit (TAD’s whole point).  
8. **Grilling unbounded** (out-of-scope: question caps; #44 Codex asked 200 questions). Escape hatch is NL “stop,” not a counter.  
9. **Handoff to OS temp** — portable, easy to lose, not a quality gate.  
10. **Research skill** has no Iron Rule / locator lint — citation theater risk TAD already rejected.  
11. **Newsletter funnel** (~60k claim) is product, not methodology.  
12. **No independent reviewer role** — grilling+self-review can still be designer-implements-accepts (TAD failure_mode on Two-Agent System).

## 8. Candidate thin deltas for upstream TAD (optional, ranked)

Human: **do not** propose wholesale adoption. These are **discussion seeds**, not a handoff.

| Rank | Delta | Why thin | Cost / conflict |
|------|-------|----------|-----------------|
| 1 | **Name the invocation split** in pack/skill authoring notes: user-invoked orchestrator vs model-invoked discipline; “Call Skill X” vs human-typed command. TAD already has pointer-max-2 / freeze. | Docs/pattern only | Must not rewrite alex/blake SKILL bodies or gates |
| 2 | **Hard vs soft dependency pointers** (ADR 0001 analogue): only load-bearing setup (e.g. issue tracker) gets a “run X if missing” line | One pattern paragraph | Easy to cargo-cult into every protocol |
| 3 | **wait-what as a *discuss* recovery move** (listener-state re-pitch + project vocabulary) — maps to existing `plain_language_rules`, not a new gate | Tiny user-invoked habit | Don’t add a global always-on skill (context load) |
| 4 | **Facts vs decisions** reminder in elicitation: don’t let Alex answer its own Gate-1 decisions | Aligns with existing Socratic + human-decides | Already mostly true; avoid a second interview OS |
| 5 | **writing-for-agents “docs are cache of the environment”** as a citation in skillify / pack-build — TAD already has the principle | Cross-link, not import | Don’t import their 11 KB SKILL |
| 6 | **Phase-boundary menu** (continue / clear / portable handoff / subagent / compact) as *discuss* hygiene — TAD already has compact recovery + terminal isolation | Teaching, not product | TAD handoff is **not** their temp-dir handoff |

### 8.1 Do not import

- The whole catalog, plugin, or skills.sh as TAD distribution.  
- `/implement` + auto-commit as a TAD path (Alex/Blake split).  
- `/wayfinder` as Epic replacement (TAD Epics + one Active phase).  
- Issue-tracker state machine / triage labels as TAD SSOT (`.tad/` files are SSOT).  
- Unbounded grilling replacing 3–5 Socratic + Gate 1.  
- `CONTEXT.md` replacing `.tad/project-knowledge/` (different job: product glossary vs methodology).  
- Research-as-background-agent **without** Iron Rule.  
- House style (no em-dashes), newsletter, teach/wizard/writing-beats.  
- git-guardrails hooks (Alex must not register hooks; TAD already rejected fail-closed PreToolUse on single-user CLI).  
- `implement-spec` concurrent subagent swarm.  
- Fowler smell list as a third TAD review axis (we already have reviewers).

## Sources (locators)

| Carrier | Locator |
|---------|---------|
| README | `https://github.com/mattpocock/skills/blob/3cca18b/README.md` — install dual-route; GSD/BMAD/Spec-Kit jab; four failure modes; skill lists |
| CONTEXT.md | domain terms: Issue tracker / Issue / Decision ticket / Triage role |
| AGENTS.md / CLAUDE.md | buckets, plugin array = promoted set, ask-matt re-sync, no em-dash |
| `.agents/invocation.md` | user vs model invoked; Skill tool calling rule |
| `.agents/install-block.md` | canonical install; exclusive routes; marketplace fallback |
| ADR 0001 | hard vs soft setup deps |
| ADR 0002 | plugin vs Codex path constraint; SHA pin |
| `.claude-plugin/plugin.json` | v1.2.3, 25 skill paths |
| CHANGELOG.md | 1.0.0–1.2.3 behavior history |
| skills.sh HTML `<meta name="description">` | “53 agent skills” (2026-09-13 curl) |
| `github/spec-kit` README | SDD loop + converge |
| `bmad-code-org/BMAD-METHOD` README | skills CLI + plugins + bmad setup |
| `gsd-build/gsd-2` README | archived → `open-gsd/gsd-pi` |
| Sample SKILL.md | grill-me (157 B), grill-with-docs (247 B), wait-what, implement, grilling, research, to-spec, ask-matt, wayfinder, writing-for-agents, setup |

## Discuss verdict (PM → human)

mattpocock/skills is a **MIT skill library** (plugin subscribe or editable `npx skills` copy), not a TAD-class process OS: the spine is **grill → spec/tickets → implement**, with a sharp **user-invoked vs model-invoked** split and tiny orchestrators that call shared discipline skills. It is philosophically **anti-GSD/BMAD/Spec-Kit process ownership**, but the **main flow still is a process**—just one you can delete a file from. For TAD, **do not adopt the catalog or `/implement`**. The only honest thin deltas are **authoring habits** we partly already have: invocation/load budget, hard-vs-soft setup pointers, facts-vs-decisions, and “docs cache the environment.” Tracker-native wayfinder/triage and unbounded grilling conflict with Gates, two-agent split, and `.tad/` as SSOT. Overclaims to discount: “53 skills,” “any model,” README Linear, and plugin “always current” vs a **pinned SHA**.
)
