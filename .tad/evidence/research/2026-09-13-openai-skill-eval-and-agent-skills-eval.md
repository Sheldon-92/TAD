---
research_complexity: comparison
research_decision_point: "Should TAD import OpenAI skill-eval methodology and/or agent-skills-eval, or only take thin habits vs existing AC / process-tax-cut / pack-eval?"
level: Deep (degraded: Local Wiki ingest/compile skipped; NotebookLM absent; Gemini forbidden; Codex adversarial off)
date: 2026-09-13
channel: Cursor
model: cursor-grok-4.6-medium
constraints: NO Gemini; NO Blake; NO TAD gate edits; NO push/tag
---

# Research: OpenAI skill eval + agent-skills-eval

**Decision question**: For TAD capability/skill quality, which claims from the 2026-09-13 X post are primary-source-true, what is already covered by TAD AC / process-tax-cut / pack-eval, and what (if anything) is a thin optional delta — not a wholesale import.

## Effort classification (Phase 0class)

- **Tier**: comparison (OpenAI blog vs unofficial runner vs TAD). Not a landscape survey.
- **dynamic seeds**: on (comparison). Extra seeds not needed after primary locators closed.
- **adversarial (Codex+Gemini)**: **off** (comparison default + human lock `NO Gemini`). Codex preflight not used as a challenge gate.
- **X MCP**: `plugin-x-x` `needsAuth`. Post recovered via `https://api.fxtwitter.com/snwiki238337/status/2099052462653002157` (200). Direct `x.com` fetch 403.

## Sources (retrieved 2026-09-13)

| ID | Source | Locator | Role |
|----|--------|---------|------|
| S1 | https://developers.openai.com/blog/eval-skills.md | headings **1.**–**8.** | **Primary OpenAI** methodology |
| S2 | WebSearch snippet of HTML post | authors Dominik Kundel, Gabriel Chua; dated **Jan 22, 2026**; section **Codex** | metadata (HTML fetch mixed nav; `.md` is SSOT for body) |
| S3 | https://x.com/snwiki238337/status/2099052462653002157 via fxtwitter JSON | `tweet.text` / `raw_text.facets` | Seed post; unofficial repo URL |
| S4 | https://github.com/darkrishabh/agent-skills-eval README (`gh api`, 2026-09-13) | Why / What you get / judge paragraph | Post-linked unofficial runner |
| S5 | gh metadata darkrishabh | stars **733**, forks **35**, MIT, created **2026-05-06** | Popularity (live API) |
| S6 | https://agentskills.io/skill-creation/evaluating-skills (curl HTML→text) | “core pattern” with/without; workspace `iteration-N`; `evals.json` | Adjacent **Agent Skills** spec eval guide (not the OpenAI Codex post) |
| S7 | https://github.com/caohaotiantian/agent-skills-eval README | Features; Evaluation Dimensions | Same npm name collision; **not** the post’s URL |
| S8 | https://github.com/tardigrde/agent-skill-eval README | How grading works | Real-CLI harness; **singular** name |
| S9 | TAD `patterns/ac-verification.md`, `patterns/process-tax-cut.md`, `docs/process-tax-cut.md`, `patterns/pack-evaluation.md`, `.tad/eval/rubric.md` | entries cited below | Internal compare |

**Not used as primary**: Medium recaps; NVIDIA ACES arXiv `2608.20614` (different “Skill Lift” paper).

---

## 1. X post (recovered text)

Author: **南晚Nanwan** `@snwiki238337` (fxtwitter `name` / `screen_name`). Created: `Sun Sep 13 08:28:00 +0000 2026`. Engagement (API, unverified beyond this pull): likes 34, bookmarks 45, views 1861, retweets 4.

Full `tweet.text` (fxtwitter):

> OpenAI发布了一套方法论，主要是关于如何评测skill效果的。对于做skill的人还是值得一看，而且github也找到一个理念很相近的skill评测器：agent-skills-eval，不过是个人维护的，非官方。
>
> 先定义成功，再写 skill。OpenAI把检查项分为了这四个点：
> Outcome（任务完成没）、Process（调了预期的 skill/步骤没）、Style（产物符合团队规范没）、Efficiency（有没有瞎折腾/烧 token）。
> 没这个定义，skill 就只是个更长的 prompt；有了它，才能进版本管理 + 回归测试 + CI。
> 负样本比正样本更关键。博客里 test-04：用户只是想给现有项目"加 Tailwind"，skill 却新建了一整个 demo app。这种误触发比不触发更危险——因为它会动你的工作区。这是 agent 产品里最容易被忽略的验收口径。
> Trace 是第一性证据。用 codex exec --json 抓 JSONL 事件流，确定性检查（跑没跑 npm install？package.json 生成没？）直接读事件，快、可解释、能进 CI；模型裁判（rubric grading）只做第二层"质量"补充，不替代规则。
> 小样本（10–20 条）起步：显式触发 / 隐式触发（不提 skill 名，靠 description 命中）/ 上下文触发 / 负向控制，各放几条。
> 它的主张我认为非常好：Agent 开发正从 prompt craft 走向 behavior engineering——skill 不该只是写给模型看的说明书，而该是可测、可评分、可回归的类似一个Agent的可复现测试的单元。
>
> 原文：https://developers.openai.com/blog/eval-skills
> 仓库：https://github.com/darkrishabh/agent-skills-eval

Facets confirm replacements: OpenAI blog + `github.com/darkrishabh/agent-skills-eval`.

Post claim vs S1: four axes, “define success before writing the skill”, test-04 Tailwind false-positive, JSONL deterministic-first, 10–20 prompts with four trigger types — **match**. “行为工程 / 可回归单元” is the author’s gloss, not a quoted OpenAI heading.

---

## 2. Primary OpenAI source (S1)

**Title**: Testing Agent Skills Systematically with Evals  
**URL**: https://developers.openai.com/blog/eval-skills (markdown: `…/eval-skills.md`)  
**Authors (S2, HTML)**: Dominik Kundel, Gabriel Chua — **Jan 22, 2026**. Treat date/authors as S2 unless HTML is re-fetched cleanly.

### What it is

A **Codex-oriented practical pattern**, not a new product KPI catalog and not a TAD-style four-gate process. Eval = **prompt → captured run (trace + artifacts) → small checks → comparable score** (S1 intro).

### Four check axes (S1 heading **1. Define success before you write the skill**)

Quoted categories:

- **Outcome goals:** Did the task complete? Does the app run?
- **Process goals:** Did Codex invoke the skill and follow the tools and steps you intended?
- **Style goals:** Does the output follow the conventions you asked for?
- **Efficiency goals:** Did it get there without thrashing (for example, unnecessary commands or excessive token use)?

Keep the list **small, must-pass**. Example skill: Vite + React + Tailwind demo; mix of concrete checks (`npm install`, `package.json`) and a style rubric.

**No invented KPIs in S1.** No required pass-rate number, no composite 0–100 formula in the takeaways. Sample rubric schema allows integer `score` 0–100 as a **schema field** for structured output (S1 §6), not a published industry KPI.

### Workflow (S1 numbered sections)

1. Write measurable success **before** `SKILL.md`.
2. Create skill (`name`/`description` as trigger signals; `$skill-creator`).
3. **Manual** explicit trigger to surface hidden assumptions (env, skip `npm install`, false trigger).
4. Small prompt CSV (~**10–20**). Example rows:
   - test-01 `should_trigger=true` **explicit** (`$setup-demo-app`)
   - test-02 implicit (scenario, no skill name)
   - test-03 contextual (extra domain noise)
   - test-04 `should_trigger=false` (“Add Tailwind styling to my existing React app”) — false-positive / workspace mutation
5. **Deterministic graders** via `codex exec --json` JSONL: `item.started`/`item.completed` + `item.type === command_execution`; file existence. Failures are **explainable by opening the JSONL**.
6. **Second** `codex exec` **read-only** style pass with `--output-schema` (JSON Schema: `overall_pass`, `score`, `checks[]`). Rubric is **layer 2**, not a replacement for rules.
7. Optional extensions: command-count thrashing, token fields on `turn.completed` (`usage.input_tokens` / `usage.output_tokens`), `npm run build`, selective runtime smoke, `git status --porcelain` cleanliness, least-privilege sandbox.
8. Takeaways: measure what matters; checkable definition of done; ground in behavior; Codex rubric where rules fall short; real failures drive coverage.

**Codex-specific**: `--json`, `--full-auto`, `--output-schema`, GitHub Action `codex-args`. This is **not** a harness-neutral standard.

### Adjacent, not the same document

S6 (agentskills.io evaluating-skills) shares **with_skill / without_skill**, `evals/evals.json`, `iteration-N` workspace, assertions with evidence, prefer scripts over LLM for mechanical checks, `timing.json` / `benchmark.json`. It is the **open Agent Skills** eval guide. OpenAI’s post is the **Codex JSONL + output-schema** instantiation. Do not collapse them into one “OpenAI spec.”

---

## 3. Unofficial GitHub: `agent-skills-eval`

### 3.1 The repo the post names (S4/S5)

**https://github.com/darkrishabh/agent-skills-eval** — personal/community, **not OpenAI**. MIT. Stars **733** (gh 2026-09-13). npm: `agent-skills-eval`.

**What it scores (README, no extra invented metrics):**

- Paired runs: **`with_skill` vs `without_skill`** (`--baseline` enables comparison).
- **Judge model** grades each side independently against `expected_output` and **assertions**; pass/fail with cited evidence.
- **Tool-call assertions**: deterministic checks when tools are used.
- Artifacts: `iteration-N/` , `benchmark.json`, per-eval `with_skill/` / `without_skill/`, HTML report.
- Claims **agentskills.io** compliance: `SKILL.md` validation, `evals/evals.json`, official layout.

It does **not** implement OpenAI’s four axes as named Outcome/Process/Style/Efficiency columns. It implements the **paired-run + judge + assertions** idea close to S6. Alignment with S1 is **philosophical** (prove skill lift; don’t vibe), not a 1:1 Codex JSONL harness.

**Scoring detail unverified**: exact judge prompt, assertion JSON schema, pass-rate formula — not fully extracted beyond README. Mark **unverified** until `src/` is read.

### 3.2 Name collisions (do not mix)

| Repo | Relation to post |
|------|------------------|
| **darkrishabh/agent-skills-eval** | **Post’s URL** |
| caohaotiantian/agent-skills-eval (S7) | Same display name; badge “OpenAI eval-skills”; **5-dimensional static** scoring of `SKILL.md` files |
| tardigrde/agent-skill-eval (S8, singular) | Real `claude`/`codex`/`opencode` CLIs; git **state-delta** + LLM rubric fallback; **pass@k** via `--runs N`; skip ≠ fail |

### 3.3 caohaotiantian static “5 dimensions” (S7) — **not** OpenAI’s axes

README **Evaluation Dimensions** reuses the **words** Outcome/Process/Style/Efficiency (+ Security) but scores **document structure**, e.g.:

- Outcome: `has-skill-md`, `has-frontmatter`, `has-name`, `skill-md-size` under 500 lines, optional dirs (weights 1–2)
- Process: kebab-case name, description what+when, usage guidance, clear steps
- Style: docs, modular dirs, **has-tests**, naming, comments
- Efficiency: dependency counts, async, caching, “no unnecessary commands” as **static** criteria
- Security: YAML ScanEngine, CVSS; “Security is 15% of each skill's composite score”

This is **orthogonal** to S1 Outcome (“did the app run?”). Importing these weights into TAD would be **validation theater** relative to OpenAI’s own meaning. Composite 15% security: **repo-claimed**, not OpenAI.

### 3.4 tardigrde grading (S8) — useful analog, not the post

First matching method:

1. Deterministic vs pre/post **git state** + logs (pattern table: branch/commit/file exists/`ran` command/`contains`/`valid json`)
2. Else LLM rubric
3. Else **skipped** (excluded from pass rate)

Negative control: `should_trigger: false` **inverts** branch/commit/push/PR checks. **pass@k** is this project’s metric, **not** claimed in S1.

---

## 4. Light compare to TAD (eval / AC / process-tax-cut)

TAD already has the **spirit** of S1 without the Codex CSV harness:

| OpenAI / post idea | TAD already | Gap |
|--------------------|-------------|-----|
| Define success before writing the artifact | Gate 1 AC verifiable; handoff §9; `docs/process-tax-cut.md` AC realism (legal Method kinds; known-GOOD PASS / known-BAD FAIL) | Rarely applied to **skill trigger** (when **not** to fire) |
| Outcome = task complete / app runs | AC dry-run on live baseline; Gate 3/4 recompute; behavioral fixtures | TAD outcomes are **repo/protocol** not “demo app runs” |
| Process = intended tools/steps | Gate 3 process; trajectory rubric **D3 Process Discipline** (`.tad/eval/rubric.md`); Ralph Loop | Not JSONL `command_execution` order for **SKILL.md** |
| Style = conventions | Layer 2 reviewers; pack anti-slop **named-rule/threshold** markers (`pack-evaluation.md`) | Not `--output-schema` style JSON |
| Efficiency = thrashing / tokens | YOLO cost experiment; process-tax-cut is **process cost**, not token thrashing | No default skill-token budget AC |
| Negative control / false trigger | Discriminative **CONTROL must FAIL** (`pack-eval-runner` `discriminative_pattern`); vacuous-AC bans | No standard `should_trigger=false` row for **capability skills** |
| Trace first, LLM second | traces, claims-need-carriers, verify-delta fail-closed Methods | OpenAI JSONL is Codex-shaped |
| Small 10–20 living fail cases | Golden-set / judge bundles are **trajectory** eval, not skill-prompt CSV | Different object (TAD execution vs SKILL.md) |

**TAD `.tad/eval/`** scores **Alex/Blake trajectories** (D1–D5: spec alignment, verification rigor, process, deviation, …). It is **not** a with/without SKILL.md A/B.

**process-tax-cut** cuts **vacuous Gates**, not agent token loops. Do not rename tax-cut as OpenAI Efficiency.

---

## 5. Claim verification table

| Claim | Check | Result |
|-------|--------|--------|
| OpenAI published skill-eval methodology with Outcome/Process/Style/Efficiency | S1 §1 | ✅ |
| “Define success before writing the skill” | S1 heading 1 | ✅ |
| test-04 = add Tailwind to existing app, should not scaffold | S1 §4 CSV | ✅ |
| `codex exec --json` JSONL + command_execution | S1 §5 | ✅ |
| Rubric via `--output-schema` second pass | S1 §6 | ✅ |
| Post links darkrishabh/agent-skills-eval | S3 facets | ✅ |
| That repo is unofficial / personal | README + not openai org | ✅ |
| 10–20 prompts | S1 §4 | ✅ |
| OpenAI mandates pass@k or 15% security composite | S1 | ❌ not in S1 (tardigrde / caohaotiantian) |
| caohaotiantian Outcome = OpenAI Outcome | S7 vs S1 | ❌ name collision |
| Post author = GitHub maintainer | no evidence | ⚠️ unverified |
| HTML author/date Jan 22 2026 | S2 snippet only | ⚠️ unverified vs `.md` (no byline in `.md` body) |

---

## 6. Decision brief (PM)

### Options

1. **Do nothing mechanical** — treat S1 as confirmation of existing TAD AC/eval doctrine.
2. **Thin habit seeds only** (max 3) — no new Gate, no runner import, no Blake this session.
3. **Adopt darkrishabh or tardigrde as a TAD subsystem** — wholesale; out of scope per human.

### Evidence

- S1 is a **short Codex cookbook**, not a replacement for Gates 1–4.
- darkrishabh is a **chat/judge A/B** for Agent Skills; TAD skills live in Claude/Codex **protocol files** with a different success object (handoff AC).
- caohaotiantian static SKILL.md scores would **fight** TAD’s anti-theater rules.
- tardigrde is the closest **engineering** analog (real CLI, skip≠fail, negative trigger) but is a **new dependency + spend**.

### Recommendation

**Option 2.** Keep Gates untouched. Do not vendor `agent-skills-eval`. Optional later *discuss* on three seeds below.

### Unknown / risks

- Live skill A/B not run (no model spend this session).
- Judge prompts inside darkrishabh **unread**.
- X MCP unauthenticated; fxtwitter is a third-party mirror.

### Optional thin delta seeds (max 3) — **not** ACs, not handoffs

1. **Skill false-trigger row** — when authoring a project Skill, add one adjacent prompt that must **not** invoke it (OpenAI test-04 / TAD known-BAD). Fits `skill-authoring-habits` / capability-builder fixtures. No Gate rewrite.
2. **Deterministic-before-judge reminder** for pack/skill eval: markers and path checks first; LLM rubric only for style leftover (already TAD pack-eval + OpenAI §5–6). Docs sentence only.
3. **Do not** map caohaotiantian 5-dim file lints onto TAD “Outcome.” If anyone cites “OpenAI four axes,” bind the words to **runtime** (task ran / skill invoked / conventions / thrash), never to `has-skill-md`.

**Ignore**: composite security %, pass@k as a TAD Gate number, Codex `--json` as a required Blake tool, importing npm/PyPI runners into `.tad/gates/`.

---

## 7. Protocol notes / degradation

- OBJECTIVES.md O2 KR1 (upgrade directions) / eval theme: this note is coverage for **skill evaluation methodology**, not a KR checkbox edit.
- Local Wiki: `research/canon` present; **no ingest/compile/lint this session** (human asked a single evidence path; avoid wiki churn). Iron Rule: claims above cite S1–S9 locators.
- NotebookLM: binary missing → WebSearch + `gh` + curl.
- Challenge log: Phase 0c/4c **not run** (tier comparison; Gemini lock).

## Paths

- This file: `.tad/evidence/research/2026-09-13-openai-skill-eval-and-agent-skills-eval.md`
- PM line: `docs/pm/now.md`
