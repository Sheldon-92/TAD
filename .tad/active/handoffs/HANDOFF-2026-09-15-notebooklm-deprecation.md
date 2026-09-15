---
task_id: TASK-20260915-NOTEBOOKLM-DEPRECATION
task_type: mixed            # docs + config (yaml) + shell hook de-registration
express: false
skip_knowledge_assessment: no
e2e_required: no
research_required: no
status: READY_FOR_GATE2
feedback_required: false
git_tracked_dirs: []
gate4_delta: []
---

# HANDOFF-2026-09-15-notebooklm-deprecation

**Task ID**: `TASK-20260915-NOTEBOOKLM-DEPRECATION`
**From:** Alex (Terminal 1) **To:** Blake (Terminal 2)
**Created**: 2026-09-15
**Status**: READY_FOR_GATE2 (design only — Blake lands the files; **no NotebookLM/CLI is executed by Blake**)
**Epic:** N/A
**Mode**: docs/config/hook-only. **No push / tag / bump / release.** No file deletion.
**Supersedes verdict**: `.tad/evidence/research/2026-09-15-gemini-notebook-fallback/VERDICT.md` — its "upgrade `notebooklm-py` to 0.8.2" recommendation is **withdrawn**; the user decided whole-layer retirement, not upgrade.
**Channel**: Alex ≠ Blake. Dual Gate 2 on disk. Draft reviewers run via explicit subagent prompting (Codex TAD custom agents not yet active).

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-09-15 (Alex design; dual disk reviews recorded §9.2)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Fallback SSOT + protocol routing + tool-layer DEPRECATED overlay + hook de-registration + CHANGELOG stance. No new pipeline. |
| Components Specified | ✅ | §6.1: exact path list, banner text, per-file rule, hook edits. |
| Functions Verified | ✅ | N/A (no code). All cited paths exist at HEAD and are tracked (§6.4). |
| Data Flow Mapped | ✅ | `*research` → config `fallback_chains.research` → local_wiki, else claude_websearch. §4.1. |

**Process Gate 2 = dual reviews on disk.** Do **not** wait for a human to type `/gate 2`. Human still says `当 Blake` for role switch.

**Alex确认**: 本 handoff 是设计权威。Blake 只改文件、不重设计、不跑任何 NotebookLM/CLI、不删除任何文件。

---

## MQ (human lock)

1. **User**: TAD 框架维护者（grokbox 侧），不是终端产品用户。
2. **Problem**: 试点结论（`VERDICT.md`）原本建议升 pin 修复二级 fallback；用户改为**整层废弃 NotebookLM**——它没有官方消费级 API，更名已打断 <0.8.0 登录，继续维护是非官方客户端的长期负债。现状是"链上仍挂着 `notebooklm_research`，工具面仍指向它"。
3. **Scope**: 把 fallback 链改成 `local_wiki → claude_websearch`；工具面全部标 DEPRECATED（**保留文件、不删除**）；钩子下线；给 2.44.6 CHANGELOG 定废弃口径。
4. **Out**: 不删任何文件；不做迁移/卸载；不改 Local Wiki 工具链；不动 `docs/pm/`；不动历史记录（CHANGELOG 旧条目 / README release history / PROJECT_CONTEXT / OBJECTIVES / evidence / archive）；不复活 frozen `research-methodology` pack；不发布。
5. **Success**: 一个新 session 的 agent 读任何 live routing 文件后，**不会再路由到 NotebookLM**；所有 NotebookLM 工具面文件头部有 DEPRECATED 声明并指向新链；CHANGELOG 口径明确"退役不是升级、保留不是删除"。
6. **Teeth**: config-workflow SSOT；dual Gate 2；Alex ≠ Blake；不删除；SAFETY 锚点字节保留。

**Gate 1**: problem / ICP / scope / verifiable ACs — PASS (§9.1 + this lock)。

### MQ evidence

| MQ | Triggered? | Evidence |
|----|------------|----------|
| MQ1 historical | yes | §2.1 survey: 9 research entries + `*research-notebook` + hook + registries; prior v2.44.3 handoff `TASK-20260908-research-route-local-wiki` preserved NotebookLM as fallback — **this handoff reverses that specific clause**. |
| MQ2 functions | no | Docs/config/hook only. |
| MQ3 data flow | no | No backend/frontend fields; §4.1 routing flow only. |
| MQ4 visual | no | No UI states. |
| MQ5 state sync | yes | SSOT = `.tad/config-workflow.yaml fallback_chains.research`; no second fallback list may remain live (§AC3). |
| MQ6 research | yes | `.tad/evidence/research/2026-09-15-gemini-notebook-fallback/{VERDICT,SOURCES,CRITIC-REVIEW}.md` + repo survey. |

---

## 1. Task Overview

### 1.1 What We're Building

NotebookLM 整层退役：研究 fallback 链由 `local_wiki → notebooklm_research → claude_websearch`
改为 **`local_wiki → claude_websearch`**；所有 NotebookLM 工具面（skill / CLI 包装 / venv / pin /
capability key / setup 脚本 / Blake 访问协议 / 依赖登记 / 休眠钩子）**原地标 DEPRECATED、文件保留、
指向新链**；并给出 2.44.6 CHANGELOG 的废弃声明口径。

### 1.2 Why

- `VERDICT.md` 的实质发现是**二级 fallback 层"看起来保留、实际很可能不可用"**（pin 在更名受影响区间）。
- 修复它要跨 5 个 minor 做回归，而根因（无官方消费级 API + 非官方客户端）**不可由升版本消除**。
- 用户裁定：与其维护一个脆弱且已经出问题的非官方层，不如**整层退役**，让链路回到 `local_wiki` 与
  `claude_websearch` 两个可维护层。

### 1.3 Intent Statement

**真正要解决的问题**：让 live routing 与工具面**不再指向 NotebookLM**，同时**保留全部历史载体**（不删文件、不丢 notebook 数据）。

**不是要做的（避免误解）**：
- ❌ 不是升级 `notebooklm-py`（`VERDICT.md` 的 0.8.2 建议**作废**）。
- ❌ 不是改名 Gemini Notebook（更名方向已无意义——整层退役）。
- ❌ 不是删除文件 / 卸载 venv / 迁移 notebook 数据（**文件与数据原地保留**）。
- ❌ 不是改 Local Wiki 工具链，也不是给 WebSearch 写新引擎。
- ❌ 不是发布（CHANGELOG 只落口径，版本号 bump 属发布单）。

**Blake请确认理解**：这是"改一行链值 + 给一批文件加 DEPRECATED 头 + 下线一个钩子 + 写一条 CHANGELOG"；
不执行研究、不删除文件、不跑 CLI。

---

## 📚 Project Knowledge

**Loaded this knife:** `principles.md`；`patterns/_index.md` → `handoff-design.md`,
`shell-portability.md`, `ac-verification.md`, `research-methodology.md`。

### Research Findings (Local Wiki)

Topic: NotebookLM layer retirement | Local Wiki: `research/canon/_index.md`（本主题无 canon 条目）
| Verdict: `.tad/evidence/research/2026-09-15-gemini-notebook-fallback/VERDICT.md`（升级建议作废，改整层退役）。
Key carriers: `research-track-protocol.md`（RG wrapper，本主题无 NotebookLM 字样）;
`patterns/research-methodology.md`（Local Wiki primary / Upstream Entry Pointer Cleanliness）。

### ⚠️ Blake 必须注意的历史教训

1. **同病治一半是本仓库高频形状**（`NEXT.md` 判断依据）— 只改被点名的文件、漏掉兄弟位置 = 病灶原地转移。
   本 handoff 的 §6.1 是**全量 live-routing 文件清单**，不是示例；AC3/AC13 专门防守漏改。
2. **Rewiring a Gate's Prose Can Trip a `grep -c` SAFETY Count**（`principles.md`）— 不要重写
   `alex/SKILL.md` 的 `NOT_via_alex_auto: true` / `forbidden_implementations` / `anti_rationalization_registry`
   或 `research-plan-protocol.md` 的 `DR-20260531` / `run_adversarial_challenge` 行；AC11/AC12 用精确计数守卫。
3. **Deny-List / diff-r 是通用遗漏捕手**（`principles.md`）— commit 后必须证明 pathspec **双向集合相等**（AC13），
   MISSING 与 EXTRA 都算 FAIL。
4. **Knowledge Is Forged at Distill, Not Captured**（`principles.md`）— 对
   `patterns/research-methodology.md` **只做事实性修订/追加 AMENDED 注记**，不重写历史发现段。
5. **Never Hand-Write What an Existing Tool Already Does**（`principles.md`）— 钩子下线走 `settings.json` /
   `hooks.json` / `tad.sh` 生成器的**删除注册**，不要新增"再判断一次"的脚本逻辑。
6. **Two-Agent + Four-Gate**（`principles.md`）— 研究/Alex 侧，不走 Blake Gate 3/Ralph Loop。

Pack pointers (not loaded): `code-security`（active，与 shell 编辑相关但不 load）。Do not escalate.

---

## 2. Background

### 2.1 Survey — NotebookLM surface today

| # | Surface | Where | Fate |
|---|---------|-------|------|
| 1 | Research fallback chain SSOT | `.tad/config-workflow.yaml` `research_notebook.fallback_chains.research` | **REWIRE** |
| 2 | `*research` unified routing | `.agents|.claude/skills/alex/SKILL.md` `research_unified_protocol` | **REWIRE** |
| 3 | Deep engine fallback execution | `research-plan-protocol.md` (step4) | **REWIRE header + banner** |
| 4 | Alex reference protocols (review/discuss/learn/handoff/decision/adaptive) | `alex/references/*` | **REWIRE fallback wording** |
| 5 | Blake fallback check + access protocol | `blake/SKILL.md`, `blake/references/notebooklm-access.md` | **REWIRE + DEPRECATE** |
| 6 | `*research-notebook` skill | `.agents|.claude/skills/research-notebook/SKILL.md` | **DEPRECATE (retain)** |
| 7 | capability catalog notebooklm_* keys | `.tad/cross-model/capabilities.yaml` | **DEPRECATE (retain)** |
| 8 | setup script + venv + pin | `.tad/cross-model/setup-notebooklm.sh` | **DEPRECATE (inert)** |
| 9 | Quick-reference guides | `.tad/guides/tool-quick-reference-{alex,blake}.md` | **REWIRE + DEPRECATE section** |
| 10 | Dormancy hook + lifecycle lib | `.tad/hooks/notebook-dormant-sync.sh`, `.tad/hooks/lib/notebook-lifecycle.sh` | **DE-REGISTER + DEPRECATE** |
| 11 | Dependency registry | `.tad/dependencies/REGISTRY.yaml` (`notebooklm-cli`) | **DEPRECATE (retain)** |
| 12 | Local notebook registry | `.tad/research-notebooks/REGISTRY.yaml` | **DEPRECATE (retain)** |
| 13 | `research-github` cloud fallback path | `.agents|.claude/skills/research-github/SKILL.md` | **REWIRE (skill stays active)** |
| 14 | Research constitution line | `research/CLAUDE.md:41` | **REWIRE** |
| 15 | Knowledge index/pattern | `.tad/project-knowledge/patterns/{_index,research-methodology}.md` | **REWIRE + AMENDED note** |

### 2.2 Current State vs Target

- **Have**: chain `local_wiki → notebooklm_research → claude_websearch`; NotebookLM tool surface intact and routed-to.
- **Target**: chain `local_wiki → claude_websearch`; every live surface stops routing to NotebookLM; NotebookLM files remain but are inert and labeled.

### 2.3 Dependencies

None at runtime. Files: `config-workflow.yaml`, `CHANGELOG.md`, `tad.sh`, settings/hooks JSON. No new deps, no network.

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: `fallback_chains` is hoisted to **top-level** in `.tad/config-workflow.yaml`; `research.secondary: claude_websearch`; the `tertiary` key is removed; **no `notebooklm_research`** remains in the chain. The old `research_notebook:` block keeps only its lifecycle thresholds and gains a DEPRECATED banner.
- **FR2**: All **live fallback / routing statements** in Alex/Blake protocol & skill files are rewired to `local_wiki → claude_websearch`; no live statement offers NotebookLM as a fallback (§6.1 Group A).
- **FR3**: The six named tool artifacts are **marked DEPRECATED in place** with the canonical banner + pointer to the new chain + the withdrawn-verdict reference. Files are **kept**; no deletion (§6.1 Group B).
- **FR4**: `notebook-dormant-sync.sh` is **removed from every SessionStart registration** (`.claude/settings.json`, `.codex/hooks.json`, `tad.sh` codex generator) and converted to an **inert `{}`/exit-0** script carrying the banner. `notebook-lifecycle.sh` is retained and banner-marked.
- **FR5**: `CHANGELOG.md` gains the `[2.44.6]` `### Deprecated` entry with the exact stance in §6.2. **No version-file bump** (`package.json` / `.tad/version.txt` untouched).
- **FR6**: `.tad/deprecation.yaml` gains **no entry** (it lists deleted files only; nothing is deleted here).
- **FR7**: Dual-platform mirrors (`.agents/` ↔ `.claude/`) stay **byte-identical** (`cmp` = 0) for every mirrored file touched.
- **FR8**: `research-track-protocol.md` gains one header line naming the new chain (the user-named file currently carries **no** NotebookLM string — verified; this makes its chain statement explicit).
- **FR9**: `docs/pm/**`, historical records (past CHANGELOG entries, README release tables, PROJECT_CONTEXT, OBJECTIVES, NEXT.md, `.tad/evidence/**`, `.tad/archive/**`, `.tad/brain-index.md`, `.tad/memory/**`), the frozen `research-methodology` pack, eval fixtures, and LICENSE-ATTRIBUTION files are **not touched**.

### 3.2 Non-Functional Requirements

- **NFR1**: Dual-platform mirrors byte-identical.
- **NFR2**: Every DEPRECATED file states (a) deprecated, (b) date/version, (c) new chain, (d) files retained/no deletion, (e) pointer/SSOT.
- **NFR3**: No new external dependency; no CLI executed; no network.
- **NFR4**: SAFETY anchors preserved byte-for-byte (§AC11/AC12).
- **NFR5**: Zero deleted files; zero renames; zero data migration.

---

## 4. Technical Design

### 4.1 Architecture Overview

```
*research  (entry: alex/SKILL.md research_unified_protocol)
   │  preflight: test -d research/canon && test -f research/canon/lint.sh
   ├─ PASS → Local Wiki engine (primary; Iron Rule + lint.sh)
   └─ FAIL → claude_websearch (WebSearch, in-session)          ← terminal degrade
              (NotebookLM hop REMOVED — retired 2.44.6)

SSOT: .tad/config-workflow.yaml → fallback_chains.research = {primary: local_wiki, secondary: claude_websearch}
Deprecated (retained, inert): *research-notebook · notebooklm CLI/venv · notebooklm-py pin
                              · notebooklm_research(+4) · setup-notebooklm.sh · notebooklm-access.md
                              · notebook-dormant-sync.sh (de-registered)
```

**Design rule — overlay, not excision.** Every deprecated block keeps its bytes; a banner at its entry marks it
unreachable, and the *gateway* (preflight/routing string) is what actually stops entry. Large CLI blocks are
**not** deleted (minimizes diff, preserves the historical record, and matches the user's "文件保留" instruction).

### 4.2 SSOT move decision

`fallback_chains` currently lives **inside** the block named after the tool being deprecated. Leaving the live
routing SSOT inside a deprecated block is the "half-cure" the repo's own pattern warns about. Therefore the chain
is hoisted to **top-level** `fallback_chains:` (indent change only; nothing executable reads the old path —
verified by grep). The `research_notebook:` block survives with its lifecycle thresholds + DEPRECATED banner.

### 4.3 Records vs live claims (scope boundary)

| Class | Decision |
|-------|----------|
| Live routing / capability claim (agent reads it and routes) | **EDIT** |
| Dated historical record (CHANGELOG past, README history, PROJECT_CONTEXT, evidence, archive, NEXT) | **LEAVE** |
| Generated index (`.tad/brain-index.md`) | **LEAVE** (regenerated by maintain; not hand-edited) |
| Frozen pack / eval fixture / attribution | **LEAVE** (frozen = historical; attribution must not change) |
| Knowledge entry making a *current* claim | **AMEND** (append AMENDED note; do not rewrite history) |

### 4.4 Decision summary

| Decision | Choice |
|----------|--------|
| Deprecation mode | Whole-layer retirement; files retained; **no deletion / no migration** |
| Fallback chain | `local_wiki → claude_websearch` (2 hops) |
| Chain SSOT location | Hoisted to top-level `fallback_chains:` |
| Protocol edit method | Overlay banner + rewire gateway (no block excision) |
| Hook | De-register + inert no-op (script kept) |
| CHANGELOG | `[2.44.6]` `### Deprecated`; stance = "retired not upgraded / retained not deleted" |
| `deprecation.yaml` | No entry (nothing deleted) |
| Version files | Untouched (bump = release task) |

---

## 5. Blake 实施步骤

1. `git status` vs §6.1. Do **not** `git add -A`. `docs/pm/intent.md` + `docs/pm/now.md` are **pre-existing dirty** — leave them.
2. Land Group A (routing rewire) first. For every mirrored pair: edit `.agents/…`, then `cp .agents/… .claude/…`, then `cmp` must be 0.
3. Land Group B (deprecated banners / inert script).
4. Land Group C (hook de-registration: settings.json, hooks.json, tad.sh generator).
5. Land Group D (CHANGELOG §6.2 exact text).
6. `git add --` **only** the §6.1 tracked paths + this handoff. Commit subject must contain `TASK-20260915-NOTEBOOKLM-DEPRECATION`.
7. Prove `git diff-tree --name-only -r HEAD` **set-equals** the §6.1 list (AC13) and `--name-status` has **zero `D`** (AC10).
8. Completion report. **No push / tag / bump / release.**

### 6.1 Modify — commit set (43 paths incl. this handoff)

**Canonical banner (Markdown variant; place at top of file, after any YAML frontmatter):**

```
> ⚠️ **DEPRECATED (TAD 2.44.6, 2026-09-15)** — NotebookLM 整层退役（不是升级）。
> 本文件保留仅作历史存档，不参与任何 routing / fallback，不再维护。
> 研究 fallback 链现为 `local_wiki → claude_websearch`
> （SSOT: `.tad/config-workflow.yaml` → `fallback_chains.research`）。
> 请勿再运行 `*research-notebook` / `~/.tad-notebooklm-venv/bin/notebooklm` / `bash .tad/cross-model/setup-notebooklm.sh`。
> 作废依据: `.tad/evidence/research/2026-09-15-gemini-notebook-fallback/VERDICT.md`（0.8.2 升级建议作废）。
```

**Canonical banner (shell variant):** identical text, each line prefixed `# `.

---

#### Group A — Routing rewire

| Path | Edit |
|------|------|
| `.tad/config-workflow.yaml` | Hoist `fallback_chains:` to top level. `research.secondary: claude_websearch`; **delete** `tertiary: claude_websearch`; delete the `notebooklm_research` line. Add a 3-line comment above `fallback_chains` ("NotebookLM removed 2.44.6; research = local_wiki → claude_websearch"). Under `research_notebook:` add the shell/YAML DEPRECATED banner (comment) and keep only thresholds. |
| `.agents/skills/alex/SKILL.md` (+ `.claude`) | L402, L480, L688: `fallback: NotebookLM` → `fallback: claude_websearch`. L698: `Fallback: NotebookLM if local_wiki missing.` → `Fallback: claude_websearch if local_wiki missing.` L716–723 `preflight.on_fail`: remove the `test -x ~/.tad-notebooklm-venv/bin/notebooklm` branch; keep single degrade-to-WebSearch message; add one line "NotebookLM fallback 已于 2.44.6 废弃（整层退役）". `standard_execution`: prefix blocks `3_fallback_notebooklm`, `1_find_notebook`, `2_create_if_needed`, `2b_source_verify`, `3_ask`, `3b_semantic_saturation` with the shell banner one-liner (they are NotebookLM-specific) — **do NOT** banner `4_format_brief` / `4b_verify_claims` / `5_feedback_loop` (they are the generic brief/feedback steps that WebSearch degrade still uses). |
| `.agents/skills/blake/SKILL.md` (+ `.claude`) | L615 description: `Local Wiki (primary) or NotebookLM (fallback)` → `Local Wiki (primary) or WebSearch (fallback)`. L632–638 step 3: replace the `REGISTRY.yaml` + `*research-notebook ask` fallback with a WebSearch degrade; add "NotebookLM layer deprecated 2.44.6". L664: "NotebookLM only as restricted fallback" → "NotebookLM layer retired (2.44.6) — do not query". L666: drop the `NotebookLM CLI not available` conjunct. L681–682 "Fallback (NotebookLM CLI not available)" → "Fallback (Local Wiki unavailable)". L690–734 `notebooklm_access_override` + L1088–1092 `notebooklm_access` body block: prefix banner one-liner (unreachable). |
| `.agents/skills/alex/references/research-track-protocol.md` (+ `.claude`) | Add one header comment line (after the existing `#` header block): `# Fallback chain: local_wiki → claude_websearch (SSOT config-workflow.yaml fallback_chains.research); NotebookLM layer deprecated 2.44.6.` No other change. |
| `.agents/skills/alex/references/research-plan-protocol.md` (+ `.claude`) | L24: `degrade to NotebookLM path` → `degrade to claude_websearch (WebSearch); NotebookLM layer deprecated 2.44.6`. L104–105 `step4.note`: state the NotebookLM fallback execution is retired; when Local Wiki absent use `claude_websearch` in-session. L115–122 preflight: remove the NotebookLM CLI branch; degrade directly to WebSearch. Add the banner one-liner at the entry of the `*research-notebook` fallback execution section. **Do not** restructure phases; keep SAFETY anchors. |
| `.agents/skills/alex/references/research-review-protocol.md` (+ `.claude`) | L13–14: `Part 2 (Secondary - NotebookLM): list …` → `Part 2 (REMOVED — NotebookLM layer deprecated 2.44.6): do not list notebooks; notebook status is no longer part of *research status.` |
| `.agents/skills/alex/references/discuss-path-protocol.md` (+ `.claude`) | L64–66: drop the "offer the NotebookLM alternative" sentence → WebSearch. L98–103: `fallback:` + `note:` reworded to Local Wiki primary / `claude_websearch` fallback; remove the "NotebookLM 是 WebSearch 的补充" clause. |
| `.agents/skills/alex/references/learn-path-protocol.md` (+ `.claude`) | L70–72: `NotebookLM below is the fallback` → "NotebookLM layer retired 2.44.6; generate Quiz/Flashcards from Local Wiki only; else WebSearch-based." |
| `.agents/skills/alex/references/handoff-creation-protocol.md` (+ `.claude`) | L94: "fall back to REGISTRY.yaml NotebookLM lookup below" → "degrade to WebSearch; NotebookLM layer deprecated 2.44.6". |
| `.agents/skills/alex/references/research-decision-protocol.md` (+ `.claude`) | L108–115: remove the notebook lookup + `notebooklm use/ask`; WebSearch only; add deprecation one-liner. |
| `.agents/skills/alex/references/adaptive-complexity-protocol.md` (+ `.claude`) | L174–176: prefix the `notebooklm CLI unavailable` / `notebooklm auth expired` failure lines with a deprecation one-liner (github-registry `notebook_id` refresh is inert). |
| `.agents/skills/research-github/SKILL.md` (+ `.claude`) | L3, L11: `with NotebookLM deep-research fallback` → `with WebSearch fallback`. L33–42 preflight: mark the notebooklm checks deprecated (one-liner); L191–193 + L232–268 (`notebook` command Step 6/7/8 + ask): banner the cloud-fallback pipeline as DEPRECATED (retain). Skill stays **active** for Local Wiki canon. |
| `research/CLAUDE.md` | L41: `NotebookLM is **fallback only** when ~/.tad-notebooklm-venv missing` → `fallback is **`claude_websearch`** (WebSearch); NotebookLM layer retired in 2.44.6`. |
| `.tad/guides/tool-quick-reference-alex.md` | L6 → new-chain statement; L8–20 NotebookLM section: prefix banner + point to WebSearch; L181 row `*research-github notebook` → mark `DEPRECATED`. |
| `.tad/guides/tool-quick-reference-blake.md` | L62–64 NotebookLM section: prefix banner; point to WebSearch (Local Wiki primary). |
| `.tad/project-knowledge/patterns/_index.md` | L18 one-liner: `NotebookLM fallback` → `WebSearch fallback`. |
| `.tad/project-knowledge/patterns/research-methodology.md` | L3 header line: replace `NotebookLM integration` with `(NotebookLM retired 2.44.6)`. Append a short `> AMENDED 2026-09-15 (2.44.6):` note at the top of the Local-Wiki entry (near L57) stating the "NotebookLM as fallback" statements are historical and the current chain is `local_wiki → claude_websearch`. **Do not** rewrite historical Discovery text. |

#### Group B — Tool layer DEPRECATED (retained)

| Path | Edit |
|------|------|
| `.tad/cross-model/setup-notebooklm.sh` | Shell banner after the shebang/usage block + `echo "⚠️ DEPRECATED (2.44.6): NotebookLM layer retired; use WebSearch. No action taken." >&2` then `exit 0` **before** any venv/pip/login mutation. File kept. |
| `.tad/cross-model/capabilities.yaml` | File-header banner. Add `deprecated: true` + `deprecated_in: "2.44.6"` + `replaced_by: "claude_websearch"` to `notebooklm_research`, `notebooklm_fulltext`, `notebooklm_quiz`, `notebooklm_flashcards`, `notebooklm_language`. Leave `codex_image_gen`, `gemini_research` etc. untouched. |
| `.agents/skills/research-notebook/SKILL.md` (+ `.claude`) | Banner after frontmatter. Prefix the frontmatter `description:` with `DEPRECATED — ` so auto-invocation no longer selects it. Keep all 19-command content (historical). |
| `.agents/skills/blake/references/notebooklm-access.md` (+ `.claude`) | Banner at top; keep content. |
| `.tad/dependencies/REGISTRY.yaml` | On the `notebooklm-cli` entry add `deprecated: true` + `deprecated_in: "2.44.6"` + `notes` line "NotebookLM layer retired; retained for record." Leave `files_depending` as historical. |
| `.tad/research-notebooks/REGISTRY.yaml` | Header banner: "DEPRECATED (2.44.6) — NotebookLM layer retired; this registry is frozen/archival; do not add or sync notebooks." Keep 34 archived entries. |

#### Group C — Hook de-registration (mechanical)

| Path | Edit |
|------|------|
| `.tad/hooks/notebook-dormant-sync.sh` | Replace body with an inert script: shell banner + `output_empty`-equivalent → print `{}` to stdout and `exit 0`. Remove the `source lib/notebook-lifecycle.sh` + recompute call. Keep executable bit. |
| `.tad/hooks/lib/notebook-lifecycle.sh` | Add shell banner at top. Keep content (inert; no caller after C1–C3). |
| `.claude/settings.json` | Remove the `notebook-dormant-sync.sh` hook object from `SessionStart` (currently lines 26–29); keep `startup-health.sh`. |
| `.codex/hooks.json` | Remove the `notebook-dormant-sync.sh` entry from `SessionStart` (currently line 9); keep `startup-health.sh`. |
| `tad.sh` | In the codex hooks generator, remove the `notebook-dormant-sync.sh` line (currently L1372) from the heredoc. No other change. |

#### Group D — CHANGELOG

| Path | Edit |
|------|------|
| `CHANGELOG.md` | Insert the exact block in §6.2 immediately below `## [Unreleased]` (and above `## [2.44.5]`). Do **not** bump `package.json` / `.tad/version.txt`. |

### 6.2 CHANGELOG `[2.44.6]` — deprecated-stance 口径 (exact text)

```markdown
## [2.44.6] - 2026-09-15

### Deprecated

- **NotebookLM research layer retired — whole layer, not upgraded**:
  - The research fallback chain is now `local_wiki → claude_websearch` (was
    `local_wiki → notebooklm_research → claude_websearch`). SSOT:
    `.tad/config-workflow.yaml` (`fallback_chains.research`).
  - **Retirement, not upgrade.** The pilot recommendation to upgrade `notebooklm-py` to 0.8.2
    (`.tad/evidence/research/2026-09-15-gemini-notebook-fallback/VERDICT.md`) is **withdrawn**.
    The root causes stand: no official consumer API, and the NotebookLM→Gemini Notebook rename
    broke login below 0.8.0.
  - **Files retained, nothing deleted, no migration.** `*research-notebook`, the `notebooklm`
    CLI integration (`~/.tad-notebooklm-venv`), the `notebooklm-py` pin, the
    `notebooklm_research` capability (plus `notebooklm_fulltext` / `_quiz` / `_flashcards` /
    `_language`), `setup-notebooklm.sh`, and `notebooklm-access.md` are marked **DEPRECATED**
    in place and carry a pointer to the new chain. No `.tad/deprecation.yaml` entry (that
    registry records deleted files only).
  - **Hook de-registered.** `notebook-dormant-sync.sh` is removed from the SessionStart hook
    lists (`.claude/settings.json`, `.codex/hooks.json`, `tad.sh`); the script and
    `notebook-lifecycle.sh` remain as inert DEPRECATED files.
  - **No capability regression.** `claude_websearch` already carried the terminal degradation
    path for Standard/Deep; this change only removes the intermediate NotebookLM hop.
  - **Supersedes** the "preserve NotebookLM intact as cloud fallback" decision of v2.44.3.
```

### 6.3 Out of commit (explicitly NOT touched)

`docs/pm/**` (single-writer + currently dirty), `NEXT.md`, `PROJECT_CONTEXT.md`, `OBJECTIVES.md`,
`README.md`, `HISTORY.md`, `.tad/brain-index.md` (generated), `.tad/evidence/**`, `.tad/archive/**`,
`.tad/memory/**`, `.tad/capability-packs/**` (frozen `research-methodology` + pack research artifacts),
`.tad/eval/**` (golden-set / judge bundles), `LICENSE-ATTRIBUTION.md` files,
`.tad/templates/**` (deliverable-handoff / capability-pack-template — non-routing prose only),
`.tad/guides/nondev-execution-track.md`, `.tad/deprecation.yaml`, `package.json`, `.tad/version.txt`,
`research/**` except `research/CLAUDE.md`, `AGENTS.md`, `CLAUDE.md`.

### 6.4 Grounded Against (Alex step1c 2026-09-15)

- `.tad/config-workflow.yaml` (`research_notebook.fallback_chains` L787–796; thresholds L777–782)
- `.agents/skills/alex/SKILL.md` (`research_unified_protocol` L687–1009; preflight L713–723)
- `.agents/skills/blake/SKILL.md` (`1_5b_research_check` L614–646; `notebooklm_access` L1088–1092)
- `.agents/skills/alex/references/research-plan-protocol.md` (LOCAL-WIKI EXTENSION L13–24; step4 L104+)
- `.agents/skills/research-notebook/SKILL.md`; `.agents/skills/blake/references/notebooklm-access.md`
- `.tad/cross-model/capabilities.yaml`; `.tad/cross-model/setup-notebooklm.sh`
- `.tad/hooks/notebook-dormant-sync.sh`; `.tad/hooks/lib/notebook-lifecycle.sh`
- `.claude/settings.json` (L26–29); `.codex/hooks.json` (L9); `tad.sh` (L1372)
- `.tad/guides/tool-quick-reference-alex.md`, `-blake.md`; `research/CLAUDE.md`
- `.tad/project-knowledge/patterns/{_index,research-methodology}.md`
- `.tad/evidence/research/2026-09-15-gemini-notebook-fallback/VERDICT.md`

LSP/graph: skipped (`task_type: mixed`, no code).

---

## 7. Required Evidence Manifest

```yaml
required_evidence_manifest:
  handoff_id: "HANDOFF-2026-09-15-notebooklm-deprecation"
  evidence_files:
    - path: ".tad/active/handoffs/HANDOFF-2026-09-15-notebooklm-deprecation.md"
      description: "this handoff (design authority)"
    - path: ".tad/evidence/reviews/2026-09-15-gate2-review-notebooklm-deprecation-spec.md"
      description: "Gate 2 Reviewer A — spec/pathspec/AC realism (human-triggered)"
    - path: ".tad/evidence/reviews/2026-09-15-gate2-review-notebooklm-deprecation-scope.md"
      description: "Gate 2 Reviewer B — whole-layer scope / no-deletion / sibling sweep (human-triggered)"
    - path: ".tad/active/handoffs/COMPLETION-2026-09-15-notebooklm-deprecation.md"
      description: "Blake completion after pathspec commit"
    - path: ".tad/evidence/reviews/gate3-evidence-notebooklm-deprecation.md"
      description: "Blake Gate 3 Layer 1 replay of §9.1"
```

---

## 8. Friction / Notes

### 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| None | — | — | — | — |

Docs/config/hook only; `grep`/`python3`/`git`/`cmp` present. No new deps, no auth. No reviewer blockage expected.

### 8.5 feedback_required: false

---

## 9. Acceptance Criteria

### AC realism (copy)

- Every landing AC has exactly one legal Verification Method: command | path-check | fixture | rubric-spawn | light-tier N/A+one-line reason.
- Dry-run on live baseline before Gate 2 lock. Post-impl rows must fail **for the right reason** on unmodified tree.
- Known-GOOD must PASS; known-BAD must FAIL.

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| 1 | Chain SSOT hoisted to top level | post-impl-verifiable | `grep -cE '^fallback_chains:' .tad/config-workflow.yaml` | 1 | (post-impl — baseline 0) |
| 2 | Research chain = local_wiki → claude_websearch, no notebooklm_research, no tertiary | post-impl-verifiable | `python3 -c "import pathlib,re; t=pathlib.Path('.tad/config-workflow.yaml').read_text(); b=t.split('fallback_chains:',1)[1].split('image_generation',1)[0]; ok=('primary: local_wiki' in b and 'secondary: claude_websearch' in b and 'notebooklm_research' not in b and 'tertiary' not in b); print(repr(b)); raise SystemExit(0 if ok else 1)"` | exit 0; block has exactly primary+secondary | (post-impl — baseline KeyError/notebooklm present) |
| 3 | No live NotebookLM-fallback string in Alex/Blake live skills | post-impl-verifiable | `grep -rIncE 'fallback: NotebookLM\|fallback: notebooklm\|NotebookLM \(fallback\)\|NotebookLM fallback' .agents/skills/alex .claude/skills/alex .agents/skills/blake .claude/skills/blake \| grep -v ':0$' \| wc -l` | 0 | (post-impl — baseline > 0) |
| 4 | Six named tool artifacts carry DEPRECATED | post-impl-verifiable | `python3 -c "import pathlib; ps=['.tad/cross-model/setup-notebooklm.sh','.tad/cross-model/capabilities.yaml','.agents/skills/research-notebook/SKILL.md','.claude/skills/research-notebook/SKILL.md','.agents/skills/blake/references/notebooklm-access.md','.claude/skills/blake/references/notebooklm-access.md']; miss=[p for p in ps if 'DEPRECATED' not in pathlib.Path(p).read_text()]; print('MISS='+repr(miss)); raise SystemExit(0 if not miss else 1)"` | exit 0; MISS=[] | (post-impl — baseline MISS=all) |
| 5 | Dual-platform mirrors byte-identical | post-impl-verifiable | `bash -c 'for p in skills/alex/SKILL.md skills/blake/SKILL.md skills/alex/references/research-track-protocol.md skills/alex/references/research-plan-protocol.md skills/alex/references/research-review-protocol.md skills/alex/references/discuss-path-protocol.md skills/alex/references/learn-path-protocol.md skills/alex/references/handoff-creation-protocol.md skills/alex/references/research-decision-protocol.md skills/alex/references/adaptive-complexity-protocol.md skills/research-notebook/SKILL.md skills/blake/references/notebooklm-access.md skills/research-github/SKILL.md; do cmp -s ".agents/$p" ".claude/$p" || { echo DIFF:$p; exit 1; }; done; echo MIRRORS_OK'` | MIRRORS_OK | (post-impl — baseline already OK; guards edits) |
| 6 | Hook de-registered from all three surfaces | post-impl-verifiable | `python3 -c "import pathlib; ps=['.claude/settings.json','.codex/hooks.json','tad.sh']; hits={p:pathlib.Path(p).read_text().count('notebook-dormant-sync') for p in ps}; print(hits); raise SystemExit(0 if all(v==0 for v in hits.values()) else 1)"` | exit 0; all 0 | (post-impl — baseline all ≥1) |
| 7 | Hook is inert + banner-marked | post-impl-verifiable | `python3 -c "import subprocess,pathlib; r=subprocess.run(['bash','.tad/hooks/notebook-dormant-sync.sh'],input='{}',capture_output=True,text=True); print(repr(r.stdout.strip()), r.returncode, 'DEPRECATED' in pathlib.Path('.tad/hooks/notebook-dormant-sync.sh').read_text()); raise SystemExit(0 if (r.returncode==0 and r.stdout.strip()=='{}' and 'DEPRECATED' in pathlib.Path('.tad/hooks/notebook-dormant-sync.sh').read_text()) else 1)"` | exit 0; `'{}' 0 True` | (post-impl — baseline references notebook-lifecycle) |
| 8 | CHANGELOG 2.44.6 deprecated entry, correct stance | post-impl-verifiable | `python3 -c "import pathlib; t=pathlib.Path('CHANGELOG.md').read_text(); need=['## [2.44.6]','### Deprecated','NotebookLM research layer retired','local_wiki → claude_websearch','withdrawn','retained, nothing deleted','deprecation.yaml','Supersedes']; miss=[x for x in need if x not in t]; print('MISS='+repr(miss)); raise SystemExit(0 if not miss else 1)"` | exit 0; MISS=[] | (post-impl — baseline MISS=`['## [2.44.6]','NotebookLM research layer retired','local_wiki → claude_websearch','withdrawn','retained, nothing deleted']`) |
| 9 | `research-track-protocol.md` states new chain, no notebooklm_research | post-impl-verifiable | `python3 -c "import pathlib; a=pathlib.Path('.agents/skills/alex/references/research-track-protocol.md').read_text(); b=pathlib.Path('.claude/skills/alex/references/research-track-protocol.md').read_text(); print('claude_websearch' in a, 'notebooklm_research' in a, a==b); raise SystemExit(0 if ('claude_websearch' in a and 'notebooklm_research' not in a and a==b) else 1)"` | exit 0; `True False True` | (post-impl — baseline: no chain line) |
| 10 | Zero deletions / zero renames in commit | post-impl-verifiable | `python3 -c "import subprocess; ns=subprocess.check_output(['git','diff-tree','--no-commit-id','--name-status','-r','HEAD'],text=True).splitlines(); bad=[l for l in ns if l[:1] in ('D','R')]; print('BAD='+repr(bad)); raise SystemExit(0 if not bad else 1)"` | exit 0; BAD=[] | (post-impl — baseline HEAD not this knife) |
| 11 | alex/SKILL.md SAFETY anchors preserved | pre-impl-verifiable | `python3 -c "import pathlib; t=pathlib.Path('.agents/skills/alex/SKILL.md').read_text(); v=(t.count('NOT_via_alex_auto: true'),t.count('DR-20260531'),t.count('forbidden_implementations'),t.count('anti_rationalization_registry')); print(v); raise SystemExit(0 if (v[0]==1 and v[1]>=3 and v[2]==4 and v[3]>=1) else 1)"` | exit 0; printed `1 3 4 …` (baseline) | `1 3 4 …` (baseline 2026-09-15) |
| 12 | research-plan-protocol SAFETY anchors + mirror | pre-impl-verifiable | `python3 -c "import pathlib; a=pathlib.Path('.agents/skills/alex/references/research-plan-protocol.md').read_text(); b=pathlib.Path('.claude/skills/alex/references/research-plan-protocol.md').read_text(); v=(a.count('DR-20260531'),a.count('run_adversarial_challenge'),a.count('NOT_via_alex_auto'),a==b); print(v); raise SystemExit(0 if (v[0]>=7 and v[1]>=15 and v[2]>=3 and v[3]) else 1)"` | exit 0; printed `8 15 3 True` (baseline) | `8 15 3 True` (baseline 2026-09-15) |
| 13 | Commit pathspec set-equals §6.1 §6.2 set | post-impl-verifiable | `python3 -c "import subprocess; exp=set('.tad/config-workflow.yaml .agents/skills/alex/SKILL.md .claude/skills/alex/SKILL.md .agents/skills/blake/SKILL.md .claude/skills/blake/SKILL.md .agents/skills/alex/references/research-track-protocol.md .claude/skills/alex/references/research-track-protocol.md .agents/skills/alex/references/research-plan-protocol.md .claude/skills/alex/references/research-plan-protocol.md .agents/skills/alex/references/research-review-protocol.md .claude/skills/alex/references/research-review-protocol.md .agents/skills/alex/references/discuss-path-protocol.md .claude/skills/alex/references/discuss-path-protocol.md .agents/skills/alex/references/learn-path-protocol.md .claude/skills/alex/references/learn-path-protocol.md .agents/skills/alex/references/handoff-creation-protocol.md .claude/skills/alex/references/handoff-creation-protocol.md .agents/skills/alex/references/research-decision-protocol.md .claude/skills/alex/references/research-decision-protocol.md .agents/skills/alex/references/adaptive-complexity-protocol.md .claude/skills/alex/references/adaptive-complexity-protocol.md .agents/skills/research-github/SKILL.md .claude/skills/research-github/SKILL.md research/CLAUDE.md .tad/guides/tool-quick-reference-alex.md .tad/guides/tool-quick-reference-blake.md .tad/project-knowledge/patterns/research-methodology.md .tad/project-knowledge/patterns/_index.md .tad/cross-model/setup-notebooklm.sh .tad/cross-model/capabilities.yaml .agents/skills/research-notebook/SKILL.md .claude/skills/research-notebook/SKILL.md .agents/skills/blake/references/notebooklm-access.md .claude/skills/blake/references/notebooklm-access.md .tad/dependencies/REGISTRY.yaml .tad/research-notebooks/REGISTRY.yaml .tad/hooks/notebook-dormant-sync.sh .tad/hooks/lib/notebook-lifecycle.sh .claude/settings.json .codex/hooks.json tad.sh CHANGELOG.md .tad/active/handoffs/HANDOFF-2026-09-15-notebooklm-deprecation.md'.split()); names=set(filter(None,subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r','HEAD'],text=True).splitlines())); subj=subprocess.check_output(['git','log','-1','--format=%s'],text=True); miss=sorted(exp-names); extra=sorted(names-exp); print('MISSING='+repr(miss)); print('EXTRA='+repr(extra)); raise SystemExit(0 if ('TASK-20260915-NOTEBOOKLM-DEPRECATION' in subj and not miss and not extra) else 1)"` | exit 0; MISSING=[]; EXTRA=[] | (post-impl — baseline HEAD not this knife) |
| 14 | `docs/pm/**` and `deprecation.yaml` untouched | post-impl-verifiable | `python3 -c "import subprocess; names=subprocess.check_output(['git','diff-tree','--no-commit-id','--name-only','-r','HEAD'],text=True).splitlines(); bad=[l for l in names if l.startswith('docs/pm/') or l=='.tad/deprecation.yaml' or l in ('package.json','.tad/version.txt')]; print('BAD='+repr(bad)); raise SystemExit(0 if not bad else 1)"` | exit 0; BAD=[] | (post-impl — baseline HEAD not this knife) |

### Verification Method grammar

LEGAL: command in backticks | path-check | fixture | rubric-spawn | light N/A.
ILLEGAL: prose-only.

## AC Dry-Run Log (Alex step1d 2026-09-15)

- AC1–4, AC6–10, AC13–14: post-impl; baselines absent / wrong-count / not-this-knife → fail for the **right** reason.
- AC5: already PASS on baseline (mirrors are in sync today) — it is an **edit-integrity guard**, not a baseline-red row.
- AC11–12: pre-impl; baselines `1 3 4 5` and `8 15 3 True` → **PASS on unmodified tree** (known-GOOD SAFETY anchors).
- Method mix: grep/python/cmp/git only — no network, no CLI.

## 9.2 Expert Review Status

> Dual files on disk = process Gate 2. Not a human `/gate 2` lock.
> **This design turn** (constraint: only the HANDOFF file may be written) ran a self-consistency pass.
> The two on-disk review carriers are produced at the human-triggered Gate 2.

### Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| Alex (self-check) | `research-track-protocol.md` named in scope but carries **no** NotebookLM string | FR8 adds one explicit header line + AC9; §2.1/§10 record the finding | Resolved |
| Alex (self-check) | Live routing SSOT sat inside the deprecated `research_notebook:` block | §4.2 hoists `fallback_chains` to top level; AC1/AC2 guard | Resolved |
| Alex (self-check) | Hook was an un-named part of the layer (would have been missed) | Group C de-registration + AC6/AC7 | Resolved |
| Alex (self-check) | `standard_execution` steps 4/4b/5 are WebSearch-shared, not NotebookLM-only | §6.1 A restricts banners to the NotebookLM-only blocks | Resolved |

### Experts Selected (to run at human-triggered Gate 2)

1. **Reviewer A — Spec & pathspec** — AC realism, dual-mirror, SAFETY anchors, exact CHANGELOG stance.
2. **Reviewer B — Whole-layer scope / sibling sweep** — no-deletion, no-migration, every live routing surface, records-vs-claims boundary.

**Gate 2 结果**: ⚠️ PENDING on-disk dual reviews (human-triggered). In-conversation self-consistency PASS.

---

## 10. Notes

- ⚠️ **Finding recorded**: `.agents/skills/alex/references/research-track-protocol.md` does **not** contain any
  NotebookLM fallback string (verified by grep). The user named it; the actual fallback wording lives in
  `research-plan-protocol.md`, `alex/SKILL.md`, and the reference protocols. FR8 adds the explicit chain line so
  the named file is consistent going forward.
- ⚠️ **Sibling found beyond the 6 named tools**: `.tad/hooks/notebook-dormant-sync.sh` (+ `lib/notebook-lifecycle.sh`)
  is registered as a SessionStart hook in both platforms. Whole-layer deprecation must de-register it or it keeps
  recomputing a retired layer each session (`NEXT.md` "同病治一半" pattern). Included as Group C.
- ⚠️ Documented example uses `notebooklm ask` in prose/blockquotes across reference protocols; those are inside
  the banners' scope — do not chase every literal token, only **live routing statements** (AC3 governs).
- 🔁 **Deferred (not this knife)**: renaming the now-empty `research_notebook:` config block to a neutral name;
  scrubbing illustrative `(NotebookLM)` mentions in `.tad/templates/**` and `nondev-execution-track.md`;
  distilling the retirement into `patterns/research-methodology.md` as a first-class entry.
- ✅ **No `.tad/deprecation.yaml` entry** — that registry is for deleted files; nothing is deleted here.
- ✅ Frozen `research-methodology` pack untouched (files stay; "NotebookLM fallback" text inside is historical).

## 11. Decision Summary

| Decision | Choice | Source |
|----------|--------|--------|
| Deprecation mode | Whole-layer retirement; files retained; no deletion/migration | User direction + `VERDICT.md` (upgrade withdrawn) |
| Fallback chain | `local_wiki → claude_websearch` | User direction |
| SSOT placement | Hoist `fallback_chains` to top level | §4.2 (avoid live chain inside deprecated block) |
| Protocol edit method | Overlay banner + rewire gateway | §4.1 (min-diff, preserve record) |
| Hook | De-register + inert no-op | Group C (sibling catch) |
| CHANGELOG stance | "Retired not upgraded / retained not deleted / no capability regression / supersedes v2.44.3" | §6.2 |
| Knowledge files | Amend, not rewrite | principles: "Knowledge forged at distill" |
| Version files | Untouched | release is a separate task |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-09-15
**Version**: 3.1

---

## Appendix B-Blake (Blake 2026-09-15 执行附录 — 用户指令覆盖 Group D)

用户指令：CHANGELOG 口径按 handoff §6.2 逐字文本预备，先写进本 handoff 附录，**不直接改 `CHANGELOG.md`**，版本号 bump 留到发版步。
因此本 knife 的 commit **不含 `CHANGELOG.md`**（AC8/AC13 按 handoff 原文计为 DEFERRED，见完成结论）；下述文本与 §6.2 逐字一致，发版时直接落盘到 `## [Unreleased]` 之下。

```markdown
## [2.44.6] - 2026-09-15

### Deprecated

- **NotebookLM research layer retired — whole layer, not upgraded**:
  - The research fallback chain is now `local_wiki → claude_websearch` (was
    `local_wiki → notebooklm_research → claude_websearch`). SSOT:
    `.tad/config-workflow.yaml` (`fallback_chains.research`).
  - **Retirement, not upgrade.** The pilot recommendation to upgrade `notebooklm-py` to 0.8.2
    (`.tad/evidence/research/2026-09-15-gemini-notebook-fallback/VERDICT.md`) is **withdrawn**.
    The root causes stand: no official consumer API, and the NotebookLM→Gemini Notebook rename
    broke login below 0.8.0.
  - **Files retained, nothing deleted, no migration.** `*research-notebook`, the `notebooklm`
    CLI integration (`~/.tad-notebooklm-venv`), the `notebooklm-py` pin, the
    `notebooklm_research` capability (plus `notebooklm_fulltext` / `_quiz` / `_flashcards` /
    `_language`), `setup-notebooklm.sh`, and `notebooklm-access.md` are marked **DEPRECATED**
    in place and carry a pointer to the new chain. No `.tad/deprecation.yaml` entry (that
    registry records deleted files only).
  - **Hook de-registered.** `notebook-dormant-sync.sh` is removed from the SessionStart hook
    lists (`.claude/settings.json`, `.codex/hooks.json`, `tad.sh`); the script and
    `notebook-lifecycle.sh` remain as inert DEPRECATED files.
  - **No capability regression.** `claude_websearch` already carried the terminal degradation
    path for Standard/Deep; this change only removes the intermediate NotebookLM hop.
  - **Supersedes** the "preserve NotebookLM intact as cloud fallback" decision of v2.44.3.
```
