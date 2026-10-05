# Discuss: capability-pack freeze inventory (2026-09-10)

**Mode:** Alex `*discuss` only · **Status:** NOT READY_FOR_BLAKE · **No live registry freeze yet**  
**Subject lock:** registered capability packs only (not other PARK).  
**Prior:** `.tad/evidence/designs/2026-09-10-pack-thin-ondemand-freeze.md` (Pass 1 strategy)  
**Loader landed:** TASK-20260910-PACK-LOADER-THIN · `9c33e2e5` (local) · Gate 4 PASS · archived `{HANDOFF,COMPLETION,GATE4}-20260910-pack-loader-thin-ondemand`  
**Sequence lock (human):** strategy (done) → **inventory (this)** → optional later leftovers (`experiment-path` dump defer)  
**`verify:` N/A** — discuss roster; no runnable landing.

Pack pointer: `pack-evaluation` is L2, not a pack. Closest active registry matches (not loaded): `ai-evaluation` — scoring whether a pack beat a generalist. `product-thinking` — keep/kill on a product surface. Path: `.claude/skills/{name}/SKILL.md`. Do not load unless escalated.

---

## Verdict (one screen)

**Recommended lock: KEEP-POINTER 11 / FREEZE 8 / UNSURE 6.** Freeze = registry `status: frozen` on `CAPABILITY.md` → `scan-packs.sh` emit → auto-match skip, **files stay**. Do not mass-edit the live registry until the human locks this roster.

Loader already made KEEP cheap (pointer, not dump). Inventory now answers only: **does this pack still earn an auto-match pointer?** Pre-read of SKILL.md is not “worth it” on keyword match; that is already locked. What remains is whether a stale pack should even *announce*.

Calendar honesty: `pack-registry.yaml` `last_scanned: 2026-07-13` (~59d) and dogfood 2026-06-13 (~89d) do **not** hit the Pass-1 “~6 month anti-slop window” by themselves. **Stale-scan is not a free freeze vote.** FREEZE below requires **two other** Pass-1 criteria (no TAD-core consumer this quarter, lost/non-discriminative eval, no anti-slop residue, or L2 duplicate).

This discuss does **not** open `*analyze`, does not set live `status: frozen`, does not absorb into v2.44.4.

---

## Scoring method (Pass 1, applied)

Universe = **25 rows in** `.tad/capability-packs/pack-registry.yaml` (no `status` keys today = all active).  
Durable freeze SSOT = `CAPABILITY.md` frontmatter `status` (loader lock). None of the 25 CAPABILITY files have `status:` yet.

Pass-1 freeze if **≥2** of:

| ID | Criterion | How scored here |
|---|---|---|
| C1 | No anti-slop residue (strong model already knows; no measured numbers / exit codes / CONSUMES-PRODUCES a generalist cannot invent) | Structural gold ≠ residue. `web-backend` / `data-engineering` CONTROL-also-PASS is a C1/C3 signal. |
| C2 | Stale research (~6 month window + API drift) | **Not counted** for the whole set (window not elapsed). Noted only where a named fact-error already shipped. |
| C3 | Lost or never-won live eval | 2026-06-13 dogfood: `video-creation` / `knowledge-graph` weakest; later deepen flipped WITH-win but introduced fact errors. Discriminative CONTROL-also-PASS = C3-variant. Behavioral-eval `verified` is **structural**, not a KEEP veto against C4. |
| C4 | No live TAD-core consumer this quarter | TAD-core = this repo’s default work (roles, gates, research wiki, release, security of tad.sh, agent design). Named other-project (Colin podcast, hardware IoT) ≠ TAD-core. |
| C5 | Duplicates TAD L2 / role protocol | `research-methodology` vs `*research`; `agent-memory` vs `memory-and-learning` + compact recovery. |

Never freeze via this policy: Alex/Blake/gate/tad-* role skills; L2 `pack-build-rules` / `pack-evaluation`.

---

## KEEP-POINTER (11) — still earn auto-match (pointer only)

Default remains pointer. Escalate only human-named or recorded failure-retry. **Dump is still not the default.**

| Pack | Why KEEP | Criteria that did *not* fire |
|---|---|---|
| `web-frontend` | Depth-gold; Inter/APCA collisions are pack-unique; DESIGN.md → code adapter | C3 pending (not a loss). TAD itself is not a React app, but this is the default frontend judgment surface when a task *is* UI. |
| `web-backend` | Depth-gold; 46-item checklist + validation scripts. CONTROL-also-PASS means *fixture* is weak, not that the checklist is empty | C3-variant on fixture only. |
| `web-ui-design` | Depth-gold; anti-slop tokens + token compiler + 14 CLI tools | — |
| `code-security` | **KEEP-ESCALATE-ON-TOOLS** fork: Semgrep/Nuclei/Gitleaks exit codes; behavioral-eval `verified`; TAD security-auditor path | Pluginize later; not freeze. |
| `web-testing` | TAD-native 4D / pair-testing; Playwright/k6/axe hard gates | Collision with frontend pyramid stays after escalation. |
| `web-deployment` | SHA-pin / OIDC / immutable image rules that training data still fakes | Overlaps `release-runbook` for *TAD publish*, not for generic web deploy. Pointer still earns. |
| `ai-tool-integration` | MCP vs CLI wrapping is TAD’s daily surface | — |
| `ai-agent-architecture` | 10 decisions from named production disasters — TAD identity | Keyword overlap with orchestration; cap still 2 pointers. |
| `agent-orchestration` | Behavioral-eval `verified`; framework/topology/HITL numbers | — |
| `ai-evaluation` | Discriminative eval `verified`; TAD still has an `*experiment` leftover dump of this SKILL — freezing would **not** stop that dump | Pluginize/`*eval` stay deferred. |
| `ai-prompt-engineering` | promptfoo/DSPy/CI gates; TAD authors prompts constantly | — |

Illustrative Pass-1 “pointer-leaning golds” confirmed. Escalate-leaning tools confirmed for `code-security` / `web-testing`.

---

## FREEZE-candidate (8) — drop auto-match; files stay

Human instinct (“many stale / can freeze”) matches this set **without** waiting for the 6-month C2 clock.

| Pack | Freeze because (≥2) | Do **not** uninstall |
|---|---|---|
| `video-creation` | C3 original dogfood loss (zero-error, still lost to generalist); C4 no TAD-core video this quarter. Deepen later “won” by stuffing a false LUFS “2026 unified standard” | Files + fixtures stay for named escalate |
| `knowledge-graph` | C3 weakest of 21 + citation fact-error; C4 no GraphRAG consumer in TAD-core | Same |
| `academic-research` | C4 no academic task this quarter; C1 PRISMA/PubMed procedure a strong model already emits | Same |
| `ai-podcast-production` | C4 Colin-bound, not TAD-core; C1 quality-delta is project-owned (belongs in that project’s skill, not global auto-match) | Same |
| `ai-voice-production` | C4 no TAD-core TTS; overlaps podcast; parked adjacent to ml-training | Same |
| `ml-training` | C4 parked EPIC; historical `no-fixture`; cloud-GPU Colab/RunPod essay is not TAD-core | SKILL is now installed — still freeze auto-match |
| `research-methodology` | C5 duplicates TAD `*research` (Local Wiki + Iron Rule); C4 pack SKILL **not even in** `.claude/skills/research-methodology/` and **absent from AGENTS table** while still in registry | Registry freeze stops any future scan-pack auto-match if someone reinstalls |
| `data-engineering` | C3-variant: WITH and CONTROL both passed (markers = common senior-DE knowledge); C4 no TAD-core warehouse/pipeline | Same |

Pass-1 illustrative freeze-leaning (`video-creation`, `knowledge-graph`, academic / podcast / voice unless a named project is active) **confirmed**. Hardware was illustrative in Pass 1; hw packs are **not in this registry** (see leftovers).

---

## UNSURE (6) — human names keep vs freeze

Each has **one** strong KEEP signal **and** one strong FREEZE signal. Agent must not pick.

| Pack | KEEP signal | FREEZE signal |
|---|---|---|
| `product-thinking` | Deep-skill BUILD/PIVOT/KILL adapters; Alex *discuss* is product work | C1: a strong model already pressure-tests ideas; TAD does this without the pack |
| `agent-memory` | Behavioral-eval `verified`; MemGPT/Letta/CoALA numbers | C5: TAD already has compact recovery + `memory-and-learning` L2 |
| `llm-observability` | Behavioral-eval `verified`; OTel GenAI / TTFT specifics | C4: TAD-core does not run Langfuse/Phoenix |
| `ai-guardrails` | Behavioral-eval `verified`; OWASP LLM / Presidio wiring | C4: TAD safety is role/friction protocol, not NeMo Guardrails |
| `rag-retrieval` | Behavioral-eval `verified`; chunk/RRF/rerank numbers | C4: live TAD retrieval is Local Wiki, not a vector RAG pipeline |
| `synthetic-data` | Behavioral-eval `verified`; contamination/DPO specifics | C4: no fine-tune dataset work this quarter |

**Recommendation if the human wants a binary (not a sixth table):** freeze the Unsure six **with** the eight. Rationale: KEEP signal is *structural eval*, which Pass-1 already rejected as sole worth; live TAD-core consumer is the load-bearing KEEP test, and none of the six have one this quarter. Reversible: un-freeze = delete `status: frozen` + rescan.

---

## Out of registry (not this freeze mechanic)

Freeze skip is **registry `status`**. These SKILL trees exist on disk and are **out of scope for CAPABILITY.md freeze** until someone registers them. Sequence says leftovers are **optional later** (with `experiment-path` dump).

| On disk | AGENTS keyword row? | Registry? | Note |
|---|---|---|---|
| `agent-computer-interface` | **Yes** | **No** | Leak: Codex AGENTS auto-match can still pointer this pack with no registry freeze hook |
| `research-methodology` | No | Yes | Covered in FREEZE table |
| `supply-chain-security` | No | No | YAML Domain Pack retired 2.30.0; SKILL remains. **KEEP-ESCALATE-ON-TOOLS** if ever registered (`*deps` / litellm poisoning). Do not register-just-to-freeze |
| `hw-circuit-design` / `hw-enclosure` / `hw-firmware` / `hw-testing` | No | No | Pass-1 freeze-leaning; T2 skill-library already preserves migrate-on-demand |
| `mobile-development` / `mobile-release` / `mobile-testing` / `mobile-ui-design` | No | No | Same Domain Pack retirement |
| `agent-skill-evolution` | No | No | Overlaps parked Capability Builder Phase 2 `evolve` |
| `reading-companion` | No | No | Epic complete; skill is project feature, not a registry pack |

`experiment-path-protocol.md` `capability_pack_auto_load` still **Reads** `ai-evaluation/SKILL.md`. Frozen-or-not, that dump is a **later ticket**, not this inventory.

---

## What TAD has vs this hole

| Already (after `9c33e2e5`) | Still missing until human lock + later `*analyze` |
|---|---|
| Pointer default; frozen skip; missing status = active | Any live `status: frozen` (AC11 of loader: zero packs frozen on purpose) |
| KEEP vs dump distinguished | Roster which packs may still *announce* |
| `scan-packs.sh` can emit `status` | First regen of live `pack-registry.yaml` **after** CAPABILITY frontmatter edits |
| AGENTS table still lists 25 keyword rows including ACI | Registry 25 ≠ AGENTS 25 (`research-methodology` vs `agent-computer-interface`) |

---

## Skip list (reaffirm)

- Mass-edit live registry / CAPABILITY `status` in this discuss
- Rewriting pack bodies thin in the same slice
- Uninstall / Cordis / new Gate / hook
- Using LOW-USAGE / `behavioral-eval-status.yaml` `verified` as the only trigger
- Absorb into v2.44.4
- Registering leftover SKILLs just so they can be frozen
- Closing `experiment-path` dump in this inventory

---

## Demand-draft (NOT a handoff)

- Outcome if Q1–Q4 lock: one inventory-only `*analyze` that sets `status: frozen` on the locked FREEZE set’s `CAPABILITY.md`, runs `scan-packs.sh`, leaves files and AGENTS table rows (escalate-by-name still works), does not touch experiment-path.
- Non-goals: skip list.
- Success: a reader can lock KEEP / FREEZE / UNSURE without tasting each pack’s prose.

**Sources:** Pass-1 freeze discuss; loader Gate 4 `9c33e2e5`; `pack-registry.yaml` (25, no status, last_scanned 2026-07-13); `behavioral-eval-status.yaml` (stale 2026-06-01 side-file); dogfood memory 2026-06-13; AGENTS Capability Packs table; deprecation.yaml 2.17.0 / 2.30.0 leftover YAML→SKILL; pack-build-rules loader pattern.

---

## Proposed next `*analyze` pathspec (only if roster locked)

Inventory-only. **Not READY_FOR_BLAKE until human answers Q1–Q4.**

1. Set `status: frozen` on locked FREEZE packs’ `.tad/capability-packs/<name>/CAPABILITY.md` frontmatter (durable SSOT).
2. `bash .tad/scripts/scan-packs.sh` → regen `.tad/capability-packs/pack-registry.yaml` (header already forbids hand-edit of status).
3. Fixture: frozen names skip auto-match; missing/active still pointer; zero SKILL Reads in loader paths (already true).
4. **Do not** rewrite SKILL bodies, AGENTS keyword rows (recommend keep so human-named escalate still has a path), experiment-path, leftover unregistered SKILLs, or v2.44.4.

If Unsure is “freeze-all”, pathspec = 8+6 = 14 CAPABILITY files + one registry regen. If Unsure stays open, pathspec = 8 CAPABILITY files only.

---

## Open questions for human (max 5)

See chat (numbered options). Short form:

1. Lock KEEP 11 / FREEZE 8 as written, or freeze more / keep more?
2. UNSURE 6: freeze-all (recommended if binary) / keep-all / you name a subset?
3. Unregistered leftovers: leave out (recommended) / drop AGENTS `agent-computer-interface` row only / register-then-freeze?
4. Mechanic: CAPABILITY `status` + scan-packs only (recommended) vs also strip AGENTS keyword rows?
5. Next slice: inventory-only `*analyze` with the pathspec above, or wait and bundle experiment-path dump later?
