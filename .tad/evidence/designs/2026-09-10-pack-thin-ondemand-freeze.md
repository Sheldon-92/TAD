# Discuss: capability-pack thin / on-demand / freeze (2026-09-10)

**Mode:** Alex `*discuss` only · **Status:** NOT READY_FOR_BLAKE · **No *analyze** · **No skill/gate edits**  
**Subject lock:** capability packs only (not other PARK).  
**Prior TAD:** `.tad/evidence/designs/2026-09-10-pstack-remaining-deltas.md`  
**Room (read-only):** Workshop `docs/research/workshop-next-after-dogfood.md` — packs = thin / on-demand / freeze unused; strong model default **no full pack dump**; weak/failure then feed; real tools / hard gates may pluginize; Workshop pilots loading; **TAD owns principles**.  
**`verify:` N/A** — discuss design; no runnable landing.

---

## Verdict (one screen)

**Recommended sequence: lock load-strategy first, then classify inventory against that strategy.** Do not freeze-or-keep a list while live runs still treat “match → Read SKILL.md” as the duty.

The pain the human named is real and mechanical: TAD already has max-2 load, Rule Soup, and usage-retire *signals*, but Alex `step4_5`, *discuss* `capability_pack_awareness`, Blake `1_5a`, and AGENTS.md “read SKILL.md BEFORE responding” all still **pre-read the pack body**. Disk freeze without loader change = same tax.

**Pre-read should become a pointer** (registry row: name + when-to-load + path). Full SKILL.md is an **escalation**, not a greeting. `references/*.md` stay Step-0-gated (good packs already do this; the protocol dumps the router anyway).

This discuss does **not** Cordis-ize judgment packs, does not absorb into v2.44.4, does not open *analyze.

---

## Human locks so far (honored)

1. Subject = **capability pack** (not other PARK: parallelism, Dune, thick PM, eval harness in core, etc.).
2. Order not yet locked: load-strategy vs keep/freeze inventory — this note **recommends strategy first**.
3. Instinct: many packs can freeze; lots stale/unupdated. Live Alex/Blake still get asked to pre-read; human unsure those reads are still worth it.

Also honored: thin + on-demand + freeze unused; strong-model default no dump; weak/failure then feed; tools/hard gates may pluginize; Workshop pilots; TAD owns principles.

---

## Why strategy before inventory

| If we inventory first | If we lock strategy first |
|---|---|
| Each pack becomes a taste fight (“maybe useful someday”) with **no rule** for whether a KEEP pack may still dump 800 lines at session start. | Inventory answers one question only: **does this pack still earn a pointer, a dump, a freeze, or a plugin?** |
| Frozen-on-disk + mandatory Read SKILL.md = **zero live relief**. | Live relief is a **loader policy**; freeze list is how we stop matching dead packs. |
| 2026-05 “freeze 20 Domain YAML → rebuild SKILL.md” already happened. Rebuilding as SKILL **increased** dump size. Inventory without loader policy repeats that. | Pass 2 (inventory) is cheap once “pointer vs dump” is locked. |

**Pass 1 (now, human lock):** what “pre-read” means; freeze *criteria* (not the full roster).  
**Pass 2 (after lock, still not Blake):** classify each registered pack KEEP-POINTER / KEEP-ESCALATE / FREEZE / PLUGINIZE.  
**Pass 3 (`*analyze` only if human wants landing):** change loader text (step4_5, discuss awareness, Blake 1_5a, AGENTS keyword table). Not pack prose rewrite in the same slice.

---

## What “pre-read” should become

Three different reads get conflated. **Only (B) is in scope.**

| ID | What live runs do today | Keep? |
|---|---|---|
| **A** | Role activation: `principles.md` + `patterns/_index.md` (+ ≤3 pattern files). Blake `1_5_context_refresh` same. | **Out of subject.** Do not mix PARK knowledge layers into this pack policy. |
| **B** | Pack match → **Read entire `SKILL.md`** (Alex step4_5 max 2; *discuss* awareness; Blake 1_5a; AGENTS.md pack table). | **Change.** This is the pre-read tax. |
| **C** | After SKILL is in context, pack Step 0/1 may still pull `references/*.md`. | Already closer to on-demand (e.g. `ai-agent-architecture` Step 0 before any reference). Policy: **C only after B has escalated**. |

**Pointer (default, strong model):**

- Announce: `Pack pointer: {name} — {one-line when}. Path: {SKILL.md}. Do not load unless escalated.`
- Source: `pack-registry.yaml` description + keywords only (already in AGENTS / registry). **Do not Read SKILL.md.**
- Cap still 2 pointers per task (Rule Soup). Collision file stays advisory **after** escalation, not at pointer time.

**Escalate to SKILL.md (router only, still not all references):**

1. Human names the pack or says “load pack”.
2. Weak model / measured failure: Layer 1 retry, Gate FAIL, or human says the generalist output was wrong.
3. Task is **pack-native tools or hard gates** (SAST CLI, install.sh, eval runner) — then load the **tool-facing** slice, not the essay.
4. Collision between two *already escalated* packs.

**Escalate to `references/*.md`:** only the pack’s own Step 0/1 (scoping questions first). Never dump the reference tree because the topic “sounds like frontend.”

**Do not treat “I matched a keyword” as worth.** Anti-slop already says: if a frontier model would emit the same rule without the pack, the pack did not earn tokens. That is the test for whether a pointer should ever escalate on a strong model.

---

## Freeze criteria (draft — human names the trigger; this is the strawman)

Freeze = **remove from auto-match** (registry / AGENTS keywords / step4_5 / Blake 1_5a). Files stay in tree as reference. Not uninstall. Not Cordis. Not a Gate item. Not a hook.

A pack is a **FREEZE candidate** if **two or more** hold (LOW-USAGE alone is not enough — `knowledge-maintain` already says usage-log misses Blake’s hottest path):

1. **No anti-slop residue:** rules a strong model already knows (generic pyramid, “use sufficient sample size”) and no project-measured numbers / exit codes / CONSUMES-PRODUCES that training data cannot invent.
2. **Stale research:** `pack-registry.yaml` `last_scanned: 2026-07-13` plus no pack-quality / dogfood refresh in the anti-slop ~6 month window; API names in the pack are known-drift risk.
3. **Lost or never-won eval:** dogfood “did not beat generalist” (memory: video-creation, knowledge-graph as weakest of the 21). Structural gold ≠ live worth.
4. **No live TAD-core consumer** this quarter (hardware / podcast / academic / GraphRAG unless a real task names them).
5. **Duplicates TAD L2** (`pack-build-rules`, `pack-evaluation`, research methodology already in protocols) — the pack is a second copy of TAD, not a domain.

**KEEP-POINTER** if the pack still holds unique thresholds, failure modes, or project adapters — but default remains pointer, not dump.

**KEEP-ESCALATE-ON-TOOLS** if value is CLI/MCP/hard gate (code-security scanners, ACI capability-detect, pack-eval-runner). That is the **pluginize** fork: executable surface + stable failure codes, **not** judgment prose as a plugin.

**Never freeze via this policy:** Alex/Blake/gate/tad-* role skills; `pack-build-rules` / `pack-evaluation` as **project-knowledge** (not packs).

Illustrative only (Pass 2 must re-score; **not locked**): freeze-leaning — `video-creation`, `knowledge-graph`, academic/hw/podcast/voice unless a named project is active. Escalate-leaning if tools fire — `code-security`, `supply-chain-security`, `web-testing` CI. Pointer-leaning golds — `web-frontend` / `web-backend` / `web-ui-design` (depth exists; **dump is still not the default**).

---

## What TAD has vs the hole

| Already | Missing |
|---|---|
| step4_5 / Blake 1_5a **max 2** | Max 2 **dumps**, not max 2 pointers |
| YOLO L1 Rule Soup + behavioral-eval **action** (unenforced) | Default-thin policy |
| `*knowledge-maintain` LOW-USAGE annotate, never sole retire | Freeze **list** + auto-match skip |
| Pack SKILL Step 0 before references (some packs) | Protocol still Reads SKILL before Step 0 |
| Skill vs MCP: judgment ≠ Cordis (pack-build-rules 2026-06-23) | Loader still treats judgment packs like must-read manuals |
| Workshop: TAD owns principle; Workshop may pilot **loading** | Upstream loader text not written (this discuss; landing = later *analyze) |

---

## Skip list

- Wholesale Cordis / DSH plugin for **judgment** packs (`web-frontend` prose as plugin).
- Other PARK: parallelism, auto-merge, thick PM, Dune / Grok Bot / Glass, playbook second orchestrator.
- New Gate item or PreToolUse hook to “prove packs are thin.”
- Absorb into v2.44.4 publish; skill/gate edits in this discuss.
- Reopening verify-delta locks.
- `*eval` tools in TAD core (`EVAL_STUB_DEFERRED` stays unless a later slice).
- Using knowledge-maintain LOW-USAGE as the only freeze trigger.
- Rewriting all pack bodies thin in one Epic (inventory ≠ rewrite).
- Treating role activation (A) or L3 incidents as this pack policy.
- Second pack SSOT in Workshop.

---

## Open questions for human (max 5)

1. **Sequence lock:** accept **strategy → inventory → (optional) loader *analyze** as the order?
2. **Policy home (from remaining-deltas Q1):** **loader-only** (step4_5 / 1_5a / AGENTS / discuss awareness), **L2** in `pack-build-rules.md`, or **L1** in `principles.md` (Epic)? Recommend: **L2 + loader** first; L1 only if we want it as -ology after a slice works.
3. **Freeze mechanic:** registry `status: frozen` + skip auto-match (files stay), vs also drop AGENTS keyword rows, vs `deprecation.yaml`? Recommend: **registry flag + AGENTS skip**; keep files.
4. **Who may escalate pointer → SKILL dump?** Human-only vs agent-on-failure vs “weak model” heuristic? Recommend: **human + documented failure retry**; no silent dump on keyword match.
5. **Next TAD slice at all?** (remaining-deltas Q5) Pack-policy `*analyze` for **loader only**, or **stop extracting** and let Workshop only pilot a pointer loader on one harness?

---

## Demand-draft (NOT a handoff)

- Outcome if Q1–Q4 lock: one pattern + loader freeze/pointer policy; Workshop remains loading pilot, not a second pack SSOT.
- Non-goals: see Skip list.
- Success: a reader sees **why pre-read feels mandatory** (B), **why freeze-without-loader fails**, and **what to lock next**.

**Sources:** remaining-deltas 2026-09-10; Workshop workshop-next-after-dogfood; `intent-router-protocol` step4_5; Blake `1_5a`; `pack-registry.yaml`; `pack-build-rules` skill-vs-MCP; `pack-evaluation` anti-slop; `knowledge-maintain` LOW-USAGE limits; YOLO Rule Soup principle; 2026-05 freeze-YAML memory (historical, superseded by SKILL rebuild).
