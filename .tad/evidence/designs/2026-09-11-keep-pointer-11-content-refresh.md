# Discuss: KEEP-POINTER 11 content refresh (2026-09-11)

**Mode:** Alex `*discuss` only · **Status:** NOT READY_FOR_BLAKE · **No mass rewrite this turn**  
**Channel:** cursor · **Model:** cursor-grok-4.6-medium · **No Gemini**  
**Subject lock:** body freshness of the 11 packs that still auto-**announce** (pointer). Not loader. Not freeze.  
**Prior:** `.tad/evidence/designs/2026-09-10-pack-thin-ondemand-freeze.md` (strategy) → `2026-09-10-pack-freeze-inventory.md` (roster) → apply `eb09597a` (14 frozen)  
**Loader already landed:** `9c33e2e5` pointer-default; this ticket does **not** re-open dump vs pointer.  
**`verify:` N/A** — discuss ranking + slice plan; no runnable landing.

Pack pointer (max 2, not loaded): `ai-evaluation` — whether a refreshed pack still beats a generalist. `ai-prompt-engineering` — prompt/CI rules that go stale with model IDs. Path: `.claude/skills/{name}/SKILL.md`. Do not load unless escalated.

L2 already consulted: `pack-build-rules.md`, `pack-evaluation.md` (~6 month anti-slop window; structural-gold ≠ depth-gold; CLI/exit-code residue).

Local Wiki query `capability pack freshness refresh`: no match. Notebooks: 0 active / 34 archived. No new notebook this turn.

---

## Verdict (one screen)

**Pre-read of SKILL.md is no longer the tax.** Loader + AGENTS already pointer-default; frozen 14 skip auto-match. The remaining pain is: **when a KEEP pack is escalated (or its pointer is trusted as “still current”), is the body still true?**

Calendar honesty: quality-leveling Batch 1–4 was **2026-06-13** (~90d). The Pass-1 **~6 month anti-slop clock has not elapsed**. “Months stale” is still a fair **trust** complaint: research locators cluster **2026-05-07 … 2026-06-01**, and TAD already shipped one **wrong CLI** in a KEEP pack (`gitleaks protect/detect` → fixed **2026-08-16** `58978798`). Stale-scan of `pack-registry.yaml` (`last_scanned: 2026-09-10`) is **not** a refresh vote — that timestamp is freeze apply, not domain research.

**Recommended refresh priority (this discuss):**

| Pri | Packs | Why this band |
|---|---|---|
| **P0** | `code-security`, `web-deployment` | Tool/command residue; wrong command is worse than a stale essay. Security pack already had one live miss. Deploy pack’s SHA pins **rot by design**. |
| **P1** | `web-ui-design` (structure), `web-testing`, `ai-tool-integration`, `agent-orchestration`, `ai-evaluation`, `ai-prompt-engineering` | Either SKILL body too fat for escalate, or versioned APIs (MCP / LangGraph / promptfoo / Claude model IDs) with May–June locators. |
| **P2** | `web-frontend`, `web-backend`, `ai-agent-architecture` | Depth-golds / TAD-identity; slower drift. Frontend got a 2026-09-02 reference restore. Backend CONTROL-also-PASS is fixture weakness, not a CLI landmine. Architecture disasters age slower than CLI flags. |

**Slice plan: sequential knives, not one 11-pack Epic.** One Epic with 11 concurrent packs repeats the 80KB/20-AC failure class. Prefer **one pack (or one CLI-class) per knife**, only one Active at a time. Optional wrapper Epic **only if** the human wants a single tracker; still **one Active phase = one knife**.

This discuss does **not** open `*analyze`, does not unfreeze anyone, does not absorb into v2.44.4, does not touch `experiment-path-protocol.md`.

---

## What this ticket is / is not

| Is | Is not |
|---|---|
| Dated stale signals per KEEP 11 | Freeze/unfreeze roster (`eb09597a` stands) |
| Priority P0/P1/P2 + knife order | Mass rewrite of 11 SKILL trees this turn |
| Whether escalate-time **body** is still worth tokens | Whether keyword match should dump SKILL (already locked: no) |
| Optional later `*analyze` per knife | Pluginize / Cordis / new Gate / hook |

Human pain mapping: “unsure pre-reads still worth it” → **loader already answered no** for greeting. This ticket answers the leftover: **pointer-still-announces ⇒ body must not be a known-stale CLI or a 1200-line router.**

---

## Scoring method (refresh, not freeze)

Universe = **exactly these 11** (registry `status: active` / missing status). Frozen 14 are **out**. Unregistered leftovers out.

A KEEP pack scores a **refresh band** from the **worst** of:

| ID | Signal | Evidence used here |
|---|---|---|
| S1 | **CLI/API can fail closed-wrong** (subcommand rename, SHA tag, SDK import) | Git + `Verified against` comments + known `58978798` |
| S2 | **Research locator age** (retrieved / CHANGELOG 1.0.0 dates) | May–June 2026 cluster; 6-month C2 **not** fired as freeze, **does** fire as “fact-check due soon” |
| S3 | **Escalate payload too fat** (Anthropic progressive-disclosure: SKILL router ≲500 lines) | `wc -l` on `.claude/skills/*/SKILL.md` |
| S4 | **TAD-core still consumes this judgment** | Same C4 as freeze discuss: TAD-core vs named other-project |
| S5 | **Known shipped error class** | Dogfood 2026-06-13 material errors; gitleaks 2026-08-16 |

Do **not** use LOW-USAGE or `behavioral-eval-status.yaml` `verified` as the only trigger (Pass-1 lock).  
Do **not** treat `last_scanned: 2026-09-10` as content freshness.

Line counts (router only, 2026-09-11 disk):

| Pack | SKILL.md lines | refs/ files | Last **domain** git (not installer/eval-harness) |
|---|---|---|---|
| web-frontend | 120 | 8 | **2026-09-02** `2af31d1e` restore `visual-code-bridge.md` (+117) |
| web-backend | 147 | 8 | 2026-05-31 eval fixtures; CHANGELOG 0.1.0 **2026-05-07** |
| web-ui-design | **1202** | 3 | 2026-06-11 install single-source; body still the 2026-06-13 gold **and** structural anti-pattern |
| code-security | 160 | 5 | **2026-08-16** gitleaks CLI rewrite `58978798` |
| web-testing | 141 | 7 | 2026-06-13 Batch 2 dogfood fixes |
| web-deployment | 141 | 7 | 2026-06-13 Batch 4 |
| ai-tool-integration | 145 | 8 | 2026-06-13 Batch 1 |
| ai-agent-architecture | 192 | 11 | 2026-07-03 frontmatter std; research **2026-05-07** |
| agent-orchestration | 129 | 6 | 2026-06-13 Batch 1; locators **2026-06-01** |
| ai-evaluation | 135 | 7 | 2026-06-13 Batch 3 |
| ai-prompt-engineering | **493** | 6 | 2026-06-13 Batch 3; `claude.md` retrieved **2026-05-07** |

KEEP `CAPABILITY.md` files still **lack** `status:` (missing = active). Freeze apply only wrote the 14. Not a defect for this ticket.

---

## Per-pack stale signals + recommended priority

### P0 — wrong command / rotting pin

#### `code-security` — P0

- **KEEP reason (unchanged):** KEEP-ESCALATE-ON-TOOLS; Semgrep/Nuclei/Gitleaks exit codes; TAD `security-auditor` path.
- **Stale signals:** (S1+S5) Pack documented **nonexistent** `gitleaks protect/detect` until 2026-08-16; comment now pins **gitleaks 8.30.1**. Other CLIs (semgrep, nuclei, checkov, osv-scanner, trivy) have **no equivalent “Verified against {ver} on {date}” banner**. (S2) Triage table still cites **2026-05-20** deadlines. (S4) TAD-core still uses this surface (NEXT.md 0e already pointed here).
- **Refresh shape:** CLI dry-run of every documented command against versions on PATH / docs; add per-tool verified-on dates; do **not** rewrite OWASP essays.
- **Not:** unfreeze supply-chain-security leftover; not pluginize this turn.

#### `web-deployment` — P0

- **KEEP reason:** SHA-pin / OIDC / immutable image — training data still emits `@v4`.
- **Stale signals:** (S1) The pack is **correct to SHA-pin**, but the **example SHA** is `actions/checkout@b4ffde65…` labeled v4.1.7 (Batch 4, 2026-06-13). Pins **rot**. Rule CI6 still shows `actions/cache@v4` as the cache API name while CI2 forbids tag pins — refresh must keep the **rule** and **re-pin examples**. (S2) No retrieval date newer than Batch 4. Overlap with `release-runbook` is TAD-publish only; generic web deploy still earns the pointer.
- **Refresh shape:** re-pin example SHAs from current GitHub action tags; verify OIDC/secret-manager names; leave platform-selection judgment unless a named platform died.
- **Not:** merge into `*publish`.

---

### P1 — escalate payload or versioned APIs

#### `web-ui-design` — P1 (structure first)

- **KEEP reason:** anti-slop tokens + token compiler + 14 CLI tools; Layer-B depth gold.
- **Stale signals:** (S3) SKILL.md **1202 lines** vs <500 progressive-disclosure — 2026-06-13 quality bar already named this as the structural anti-pattern hiding inside a depth gold. Pointer does not dump it; **human-named escalate still dumps 1202 lines**. refs/ only **3** files — depth is stuck in the router. LICENSE retrieved 2026-04-25 / 2026-05-07. (S1 secondary) “14 FULLY_CLI tools tested” — test date is Batch era, not 2026-09.
- **Refresh shape:** **split**, don’t freeze: move capability essays into `references/`, leave Vision→Execution→Validation + tool index in SKILL. Optional later: re-run the 14 CLI `--help` smoke. Anti-slop token **content** is P2 unless Anthropic frontend-design skill drifted (not verified this turn; no Gemini).

#### `web-testing` — P1

- **KEEP reason:** TAD-native 4D / pair-testing; Playwright/k6/axe hard gates.
- **Stale signals:** (S1) Playwright / Vitest Browser Mode / k6 APIs move; last domain fix **2026-06-13** dogfood. (S2) ~90d. Freeze discuss: KEEP-ESCALATE-ON-TOOLS fork — same class as security but lower blast (wrong test recipe vs wrong secret scanner).
- **Refresh shape:** command-level verify of documented CLIs + 4D protocol pointer vs current `pair-testing` docs (drift between pack and TAD core). Pyramid collision with frontend stays after escalation.

#### `ai-tool-integration` — P1

- **KEEP reason:** MCP vs CLI wrapping is TAD’s daily surface (10-32x token cost rule is anti-slop residue).
- **Stale signals:** (S1+S2) MCP TypeScript SDK / OAuth 2.1 / Inspector — locators in-pack include example timestamps **2026-05-15**; Batch 1 **2026-06-13**. MCP spec is a high-churn S1.
- **Refresh shape:** fact-check MCP SDK names + wrapping cost rule still true; don’t rewrite schema-design prose unless imports fail.

#### `agent-orchestration` — P1

- **KEEP reason:** behavioral-eval verified; topology / HITL / Temporal numbers.
- **Stale signals:** (S2) PyPI pins `langgraph-sdk==0.3.15` **released 2026-05-22**, retrieved **2026-06-01**. CAPABILITY still says **AutoGen v0.4+**. Framework names in the pointer description will mis-route if AutoGen/CrewAI lines renamed. Keyword overlap with `ai-agent-architecture` (cap 2 pointers — already locked).
- **Refresh shape:** framework-selection.md version/import pass only; durable-execution Temporal APIs; do not rewrite TAD HITL (that’s role protocol).

#### `ai-evaluation` — P1

- **KEEP reason:** discriminative eval `verified`; TAD still evaluates packs/agents.
- **Stale signals:** (S2) Batch 3 **2026-06-13**. (Leftover, **not this ticket**) `experiment-path` still **Reads** this SKILL — freeze would not have stopped that dump; refresh of body also does not close the dump. (S1) promptfoo / deepeval / ragas CLI flags.
- **Refresh shape:** runner/assertion names + n≥ / ICC numbers still match current tools; **do not** fold experiment-path into the same knife.

#### `ai-prompt-engineering` — P1

- **KEEP reason:** promptfoo/DSPy/CI; TAD authors prompts constantly.
- **Stale signals:** (S2+S3) SKILL **493 lines** (at the 500 cap). `references/claude.md` retrieved **2026-05-07**, still names `claude-opus-4-7` / `sonnet-4-6` / `haiku-4-5` and `thinking.budget_tokens`. This session’s model is **cursor-grok-4.6-medium** — the Claude-only file is fine as a named reference, but **locator age + model IDs** are the stale signal. CHANGELOG v1.0.0 **2026-05-07**.
- **Refresh shape:** re-retrieve Anthropic (and optionally DSPy) current API names; slim SKILL if still near 500 after fact-check. No Gemini this discuss; live API confirm is the later knife.

---

### P2 — depth gold / identity; refresh when a knife is cheap, not first

#### `web-frontend` — P2

- **KEEP reason:** Inter/APCA collisions; DESIGN.md → code. Router already thin (120).
- **Stale signals:** (S2) CHANGELOG 1.0.0 **2026-05-08**. **Counter:** 2026-09-02 restored `visual-code-bridge.md` — newest KEEP content besides gitleaks. React/RSC still moves, but this pack is judgment + tokens, not a React version catalog.
- **Refresh shape:** later pass on RSC/compiler only if a named failure-retry says the pointer lied. Not first knife.

#### `web-backend` — P2

- **KEEP reason:** 43 rules + 46-item checklist + validation scripts.
- **Stale signals:** (S2) CHANGELOG 0.1.0 **2026-05-07**. Freeze discuss C3-variant: CONTROL-also-PASS = **fixture** weak, not empty checklist. Last pack-tree git that isn’t installer is eval-harness **2026-05-31**.
- **Refresh shape:** optional discriminative-fixture repair (eval theater), not a body rewrite. Do not treat CONTROL-also-PASS as “rewrite 46 items.”

#### `ai-agent-architecture` — P2

- **KEEP reason:** 10 decisions from named production disasters — TAD identity.
- **Stale signals:** (S2) `research-findings.md` retrieved **2026-05-07** (45 sources). (S3) SKILL 192 — fine. 2026-07-03 was frontmatter standardization, not domain refresh.
- **Refresh shape:** only if a named disaster/API in D1–D10 is known-wrong; don’t open a 11-reference rewrite as Knife 1.

---

## Slice plan (knives)

**Recommended: sequential knives.** Wrapper Epic optional (human Q). Hard rule: **one Active knife**; no 11-pack handoff.

| Knife | Scope | Suggested AC class (when *analyze*) | Depends on |
|---|---|---|---|
| **K0** | This discuss (done when human locks Q1–Q5) | N/A | — |
| **K1** | `code-security` CLI re-verify + verified-on banners | Every documented command extracted and dry-run or docs-pinned; no OWASP essay rewrite | Q lock |
| **K2** | `web-deployment` example SHA re-pin | Pins resolve; `@v4` remains the anti-pattern in prose | Can parallelize with K1 **only if** two humans/two Blakes; else after K1 |
| **K3** | `web-ui-design` SKILL split (structure) | SKILL.md ≤500; refs/ absorb essays; pointer text unchanged; no freeze | Independent of K1 if pathspecs disjoint |
| **K4** | Batch fact-check: `ai-tool-integration` + `agent-orchestration` (MCP + framework pins) | Import/CLI names; retrieval dates updated | Prefer after K1 (same “versioned API” muscle) |
| **K5** | `web-testing` + `ai-evaluation` + `ai-prompt-engineering` | Tool flags + `claude.md` locators; SKILL 493 slim if still over | After K4 or instead of K4 if prompt/eval pain is higher |
| **K6** | P2 trio only on named failure or after 6-month clock (~2026-12 from May research) | Optional | Do not start now |

**One Epic vs knives:** use an Epic **only** as a tracker (`EPIC-YYYYMMDD-keep11-refresh`) with phases = knives above, **one Active phase**. Do **not** put K1–K6 in one handoff. Do **not** wait to “batch all P1” — that recreates Rule Soup for reviewers.

v2.44.4 publish handoff remains a **separate track** (filenames in `.tad/active/handoffs/`; this discuss did not read them). Do not absorb KEEP refresh into that pathspec.

---

## Skip list (this discuss and the later knives unless human re-opens)

- **Do not unfreeze the 14** at `eb09597a`. Reversible freeze stays: delete `status: frozen` + rescan — **not this ticket**.
- **No experiment-path** dump fix in this discuss (ai-evaluation leftover). Needed only if a knife’s AC would lie about “no SKILL Read”; then a **separate** ticket, not a rider.
- Mass rewrite of 11 packs in one turn / one handoff
- Loader / pointer-default / scan-packs freeze mechanic
- AGENTS keyword row strip; leftover SKILL registration; ACI row
- Cordis / pluginize / new Gate / hook
- Gemini CLI (human lock). Cross-model fact-check of APIs, if wanted, is **Codex or WebSearch on a later knife**, not this file
- Absorb into v2.44.4
- Treating `last_scanned` or LOW-USAGE as refresh priority
- Re-running full 24-pack quality-leveling Epic

---

## What TAD has vs this hole

| Already | Still missing until human lock + later `*analyze` |
|---|---|
| Pointer default; 14 frozen skip announce | Any KEEP body with current `Verified against` dates except gitleaks 8.30.1 |
| KEEP 11 still earn auto-match | Sequential knife 1 pathspec |
| web-ui-design named as structural gold **and** 1202-line anti-pattern (2026-06-13) | Actual split |
| 6-month anti-slop **principle** | A calendar trigger (~2026-11/12) if K6 is deferred |

---

## Demand-draft (NOT a handoff)

- Outcome if Q1–Q5 lock: first `*analyze` = **K1 only** (or K1+K2 if human wants one “CLI class” knife), pathspec = that pack’s `references/` + CAPABILITY tool tables + skill mirror pair (`.claude` / `.agents` / capability-packs), parity required, **no** frozen 14, **no** loader, **no** experiment-path.
- Non-goals: skip list.
- Success: a reader can see why `code-security` is first and `ai-agent-architecture` is last without tasting 3000 lines of SKILL.

**Sources:** freeze inventory discuss + `eb09597a`; loader `9c33e2e5`; `pack-registry.yaml` last_scanned 2026-09-10 (14 frozen / 11 active); git log on KEEP trees; `wc -l` SKILL.md; retrieval grep 2026-05/06; NEXT.md 0e gitleaks; pack-evaluation structural-gold pattern; pack-build-rules.

---

## Open questions for human (max 5)

See chat (numbered options). Short form:

1. Refresh bar for Knife 1: CLI-verify only vs CLI + retrieval dates vs also structural split in the same knife?
2. Slice shape: sequential knives (recommended) / wrapper Epic + one Active knife / one 11-pack Epic (not recommended)?
3. P0 lock: `code-security` only / `code-security` + `web-deployment` / add `web-testing` as third CLI pack?
4. Success metric: documented-command dry-run + dated banners vs also re-run discriminative eval vs both?
5. When to open `*analyze`: after these locks / after v2.44.4 publish lands / wait for 6-month clock (~Nov–Dec) except P0 CLI?
