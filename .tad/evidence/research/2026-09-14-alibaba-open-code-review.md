# Research: alibaba/open-code-review vs upstream TAD (thin borrow)

**Date:** 2026-09-14  
**Channel:** Cursor · `cursor-grok-4.6-medium`  
**Role:** Alex · `*research` Deep (degraded) + `*discuss` verdict  
**Decision question:** For deciding whether upstream TAD should **thin-borrow habits/principles** from [alibaba/open-code-review](https://github.com/alibaba/open-code-review) (especially Layer 2 / code-reviewer / security-auditor), which seeds are KEEP / DEFER / REJECT — **not** wholesale adopt.

**Human locks (this session):** NO Gemini · NO Blake · NO push/tag · NO edit TAD gates · NO wholesale adopt into TAD.

---

## 0. Method, coverage, degradation

| Intended Deep step | What ran | Status |
|---|---|---|
| Q1 decision point | Human already named evaluate vs borrow for Layer 2 / packs | Used as-is |
| Effort class | Landscape/survey → `complex`; human forbade Gemini | Adversarial Codex+Gemini **off** (human override) |
| Local Wiki ingest + Iron Rule lint | `research/` present in-repo; ingest/shell + raw GitHub fetch **blocked** this session | **Degraded** — no new canon page |
| NotebookLM | Not used (primary is Local Wiki; session did not create a notebook) | Skip |
| Primary sources | GitHub README / README.zh-CN (search snippets), ASSURANCE_CASE, GOVERNANCE, ROADMAP, PRs #383/#808, DeepWiki architecture/rules, arXiv HTML `2608.09290v2` | **Partial verify** |
| Live `gh api` stars / clone / tree | Shell + WebFetch rejected | Star count **unverified live** |
| TAD compare | `principles.md`, `patterns/_index.md`, `process-tax-cut.md`, Blake Layer 2 SKILL, spec-compliance format, `code-security` pack SKILL (pointer only; not escalated), security-review format | Read |

**research_complexity:** complex (overridden: no Gemini/Codex challenge).

---

## 1. What it is (verified from public docs + paper)

**Open Code Review (OCR)** is an Apache-2.0 **Go CLI** (also shipped as npm `@alibaba-group/open-code-review`) that reviews Git diffs (and `ocr scan` for whole files). Architecture is explicitly **hybrid**:

1. **Deterministic engineering** (must-not-go-wrong): file filter, bundling, **four-tier rule resolution**, diff parse, comment **line positioning**.
2. **LLM agent** (judgment): ReAct loop with a **curated 6-tool set**, per-file (or bundled) SubAgents, OpenAI/Anthropic-compatible endpoints.
3. **External modules:** positioning (snippet → line, LLM fallback) and **independent reflection** (filter comments).

README (EN + zh-CN, same claims): originated as Alibaba Group internal AI review assistant; reads diffs; line-level comments; built-in rules covering **NPE, thread-safety, XSS, SQLi**; precision/F1 over recall vs general agents; ~1/9 tokens vs Claude Code (README); paper reports **5–15×** fewer tokens on AACR-Bench.

**Rule stack (DeepWiki + paper Table 1):** first-match-wins glob, four tiers — ad-hoc `--rule` → project `/.opencodereview/rule.json` → user `~/.opencodereview/rule.json` → embedded system rules (`go.md`, `java.md`, …). Project rules can **replace** or **merge** system rules.

**Bundling:** related files as one review unit (i18n pairs; later PR #808 semantic groups, max 10 files/group + token budget). Isolated sub-agent context, parallel.

**Positioning:** `code_comment` + `existing_code` → match new-side hunks → full file → LLM relocate. Engineering, not “trust the model’s line number.”

**Reflection (paper §3.4 — load-bearing for TAD):** after ReAct, a **second pass** gets **only the diff + comment list** (asymmetric info boundary). **Falsification, not verification:** veto only if the **diff directly contradicts** the claim; extra-file claims are **kept**. **Filter-only** (cannot mint new comments). Parse failure **fails open** (keep all). Same LLM allowed; independence is the **smaller evidence bound**, not a second vendor.

**Delegation mode (ROADMAP + PR #383):** `ocr` does not call an LLM; it emits reviewable files + grouped rules for the **host coding agent**. Matches TAD’s “deterministic prep, host agent judges” more than OCR-managed default.

**Ultra mode (ROADMAP + discussion #197):** opt-in **higher recall**, more tokens/time, for security-sensitive changes. Explicitly not the default.

**ASSURANCE_CASE (light):** trust boundaries Git→CLI→LLM→disk; viewer localhost + host allowlist; path jail to repo root; `CGO_ENABLED=0`; HTTPS; no `InsecureSkipVerify`. This is **CLI product security**, not a substitute for TAD `security-auditor`.

**GOVERNANCE (light):** PRs + lazy consensus; Project Lead escalation; significant changes (CLI, LLM providers, diff engine, credentials) need wider review. **Not** a TAD gate analogue.

---

## 2. Unverified / marketing — do not treat as facts

Mark **UNVERIFIED** unless independently measured this session:

| Claim | Where | This session |
|---|---|---|
| “Millions of code defects” identified internally | README EN/zh-CN | **Unverified** (vendor narrative; no public ledger) |
| “Tens of thousands of developers” / two years internal | README | **Unverified** |
| “Alibaba-scale” / battle-tested | README + third-party blogs | **Unverified** as a metric |
| GitHub star count (~11K / blog 11,801) | GitHub UI snippets / CoddyKit | **Unverified live** (`gh api` blocked) |
| Exact 1/9 token ratio | README | **Approximate**; paper Table 3 is the citable range (e.g. Claude-4.6-Opus 385K vs Claude Code 5,664K ≈ **14.7×**) |
| AACR-Bench 200 PRs / 1,505 comments / 80+ engineers | README + paper | **Paper-reported**; not re-run here |
| SEM-F1 25.10% vs Claude Code 11.57% (same model) | Paper Table 3 | **Paper-reported**; LLM-judge metric (construct-validity caveats in paper §6) |

Do **not** put these numbers into TAD ACs or pack copy.

---

## 3. TAD surfaces compared

| TAD surface | Role today | Overlap with OCR | Conflict / thin delta |
|---|---|---|---|
| **Gate 2 dual** (`process-tax-cut.md` §3) | Two **independent** review **files on disk**, P0=0; Alex ≠ Blake; do not wait for human `/gate 2` | Dual eyes vs OCR “second pass” | **Conflict if replaced:** OCR reflector is **same-model, less context, filter-only**. TAD Gate 2 is **role-separated design review**, not comment-veto. Do not collapse Gate 2 into OCR reflection. |
| **Layer 2** (Blake: spec-compliance → code-reviewer → test/security/perf) | Independent subagents; self-review **never** equivalent; ≥2 distinct on non-doc | Independent second perspective | **Complement:** TAD reviewers often re-read **full pathspec + repo**. OCR’s habit is **asymmetric bound + falsify-only**. Thin seed = teach Layer 2 **not to rewrite findings; veto only contradictions; fail-open**. |
| **Dirty-tree adjudicate** (`spec-compliance-format.md` + tax-cut §2) | Label pre-existing dirt **FALSE_POSITIVE** with pointer; still write the finding; second reviewer not skipped | Both fight false P0 | **Different axes:** TAD = pathspec vs **prior-knife dirt**. OCR = comment vs **this-diff contradiction**. Keep both; do not merge into one slogan. |
| **`code-security` pack** (registry **active**) | SAST/DAST/secrets/IaC/triage **tools** (Semgrep, gitleaks, …); pack ≠ process | XSS/SQLi/NPE appear in OCR **LLM checklists** | **Conflict if OCR rules replace scanners.** TAD principle: never hand-write what a tool already does. XSS/SQLi stay **scanner-first**; LLM rules are optional **extra narrative**, not SSOT. |
| **security-auditor + `security-review-format.md`** | Checklist + gitleaks/audit; trigger-gated Group 2 | Language rules (XSS, SQLi) | Overlap on **classes of bug**, not on **pipeline**. Auditor should stay **evidence-carrying scans**, not a 30-round ReAct reviewer. |
| **code-reviewer** | P0/P1 on the **delta**; TAD forbids generic `/code-review` skill | OCR is a **productized** review agent | TAD already **excluded** generic code-review skills in Alex SKILL. Importing OCR as default reviewer **reopens that exclusion**. |
| **Pathspec §7** | Deterministic file set for the knife | OCR Rule-Guided Dispatch | **Already TAD.** Thin reminder: reviewer must not **expand** the file set like a free agent. Bundling is optional for large PRs TAD does not currently have. |

**Already owned by TAD (do not re-import as “new”):** two-agent split; independent review; pathspec; dirty-tree labels; scanner-based security pack; precision via AC/commands (`verify-delta`); fail-closed gates with honest_partial.

---

## 4. Ranked seeds (max 5 KEEP-candidates)

Human asked KEEP/DEFER/REJECT, **max ~5 keep-candidates**. Habits/principles only.

### KEEP (thin, prompt/habit — not a new product)

| # | Seed | Why it is thin | Where it would live (if human later locks) | Do **not** do |
|---|---|---|---|---|
| **K1** | **Asymmetric-bound, falsify-only second pass** | Paper’s strongest transferable idea: second look sees **less** evidence; **veto contradictions only**; **no new findings**; fail-open on parse | Layer 2 **reviewer prompt** / tax-cut sibling paste — **not** a new Gate | Do not replace Gate 2 dual or Alex≠Blake with same-model reflection |
| **K2** | **Precision-over-recall as Layer 2 default** | README/paper: general agents win recall by comment flood; OCR clusters high precision / moderate recall | code-reviewer prompt: prefer fewer P0/P1 with replayable evidence; ban volume-as-quality | Do not lower recall on **security-auditor** triggers; that is Ultra-shaped (K5) |
| **K3** | **Dispatch is engineering, not agent whim** | Same PR → same files + criteria | Already §7 pathspec + FileFilter analogue | Do not add `rule.json` engine |
| **K4** | **Comment claims must be localizable or labeled unanchored** | Positioning as **external** module: don’t trust model line numbers | Review format: path + command/hunk or “unanchored / extra-file” | Do not build OCR’s three-stage matcher in Go |
| **K5** | **Recall-up is opt-in for high-risk deltas** | Ultra mode: more budget when security-sensitive | Existing security-auditor **trigger** = the Ultra analogue | Do not add a named Ultra Gate or extra Ralph round by default |

### DEFER

- Semantic **file bundling** (impl+test, i18n pairs) — useful if TAD ever reviews **large unmanaged PRs**; current knives are pathspec-small.
- **Delegation-mode habit** (“host agent reviews; a deterministic prep lists files+rules”) — TAD **already is** this (handoff). Wiring `ocr delegate` CLI = runtime dependency → DEFER until a human wants an **optional** experiment, not upstream default.
- TAD-owned **language checklists** (NPE/thread-safety) as **project-knowledge patterns**, written in TAD voice — only if a real language-heavy product repo asks; not copied from `internal/config/rules/rule_docs/*.md`.
- ASSURANCE_CASE **template** for a future TAD-shipped CLI — irrelevant until TAD ships a network listener.

### REJECT (do-not-import list — explicit)

1. **Wholesale adopt** the repo into TAD (Go CLI, npm global, plugins under `.claude/commands`, Cursor/Codex OCR skills as default).
2. **Replace** Gate 2 / Gate 3 / Layer 2 with `ocr` / AACR-Bench / SEM-F1.
3. Embed **system_rules.json** / `go.md`/`java.md` XSS-SQLi LLM lists as TAD SSOT (conflicts with `code-security` scanners + “never hand-write the tool”).
4. ReAct 30-iter **generic bash** (OCR itself rejects this) **or** OCR’s six tools as TAD runtime — TAD subagents already have Read/Grep with different duties (AC recompute, not GitHub inline comments).
5. OCR **viewer** HTTP server / host-guard as TAD infrastructure.
6. Marketing numbers (millions of defects, star counts, 1/9 tokens) in TAD docs.
7. **Lazy-consensus GOVERNANCE** as a substitute for TAD human locks / dual Gate 2.
8. Making OCR a **required** Layer 2 expert (violates TAD skill exclusion for generic code-review; couples quality chain to an external CLI).

---

## 5. Discuss verdict (PM → human)

**Worth borrowing?** **Yes, thinly — five habits, zero product.** OCR is a **specialized review appliance** (deterministic dispatch + bounded tools + comment positioning + falsify-filter). TAD is a **two-role quality operating system** (design vs implement, four gates, AC-carrying evidence). The valuable overlap is **how to keep a second look honest**, not **how to run Alibaba’s CLI**.

**Recommend:** lock K1–K5 as **optional prompt paste** in a later `*discuss`/`*idea` (docs-only), **after** v2.44.5 publish is out of the way. **Do not** open a Blake handoff, **do not** edit gates, **do not** add a pack or npm dep.

**If only one sentence:** Steal **falsify-only / less-context / filter-only / fail-open** and **don’t flood comments**; keep TAD dual independent reviewers and scanner-first security.

---

## 6. Sources (locator-style; Iron Rule not applied — no wiki compile)

- [GitHub README](https://github.com/alibaba/open-code-review) — hybrid design, bundling, rules, positioning/reflection, precision trade-off, internal-scale claims.
- [README.zh-CN](https://github.com/alibaba/open-code-review/blob/HEAD/README.zh-CN.md) — same architecture + 数万开发者 / 数百万缺陷 (unverified).
- [ASSURANCE_CASE.md](https://github.com/alibaba/open-code-review/blob/main/ASSURANCE_CASE.md) — trust boundaries, OWASP mapping, path jail.
- [GOVERNANCE.md](https://github.com/alibaba/open-code-review/blob/main/GOVERNANCE.md) — lazy consensus, Project Lead.
- [ROADMAP.md](https://github.com/alibaba/open-code-review/blob/main/ROADMAP.md) — Delegate Mode, Ultra Mode.
- [PR #383](https://github.com/alibaba/open-code-review/pull/383) — `ocr delegate`.
- [PR #808](https://github.com/alibaba/open-code-review/pull/808) — semantic grouping, max 10 files.
- [Discussion #197](https://github.com/alibaba/open-code-review/discussions/197) — Ultra Mode recall gap.
- DeepWiki [core architecture](https://deepwiki.com/alibaba/open-code-review/2-core-architecture), [rules engine](https://deepwiki.com/alibaba/open-code-review/4.2-review-rules-engine).
- Li et al., **OpenCodeReview: Determinism over Non-Determinism…**, arXiv [2608.09290v2](https://arxiv.org/html/2608.09290v2) — §§3.2–3.4 architecture, Table 3 metrics, §5 information-boundary vs model-boundary.
- TAD: `.tad/project-knowledge/patterns/process-tax-cut.md`, `.tad/templates/output-formats/spec-compliance-format.md`, `.claude/skills/blake/SKILL.md` Layer 2, `.tad/capability-packs/pack-registry.yaml` `code-security` **active**.

**Not loaded:** OCR Go sources (clone blocked); TAD `code-security` SKILL body beyond first page (pointer, not escalated).
