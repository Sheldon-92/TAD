# Design: capability-pack freeze apply (inventory-only)

**Mode:** Alex `*analyze` · **Status:** READY_FOR_GATE2 · **No Blake yet**  
**Task ID:** `TASK-20260910-PACK-FREEZE-INVENTORY`  
**Handoff:** `.tad/active/handoffs/HANDOFF-20260910-pack-freeze-inventory.md`  
**Prior discuss (roster source):** `.tad/evidence/designs/2026-09-10-pack-freeze-inventory.md`  
**Loader already landed:** TASK-20260910-PACK-LOADER-THIN · `9c33e2e5` (local) · Gate 4 PASS  

Human lock (this session, 2026-09-10): **FREEZE 14 / KEEP-POINTER 11**. Mechanic = CAPABILITY.md `status: frozen` + `scan-packs.sh` regen only. Files stay. AGENTS keyword rows stay (named escalate). Out of scope: unregistered leftovers, AGENTS ACI row, experiment-path dump, KEEP body refresh, push/tag/v2.44.4.

---

## Locked roster

**FREEZE (14)** — drop auto-match; files stay:

`video-creation`, `knowledge-graph`, `academic-research`, `ai-podcast-production`, `ai-voice-production`, `ml-training`, `research-methodology`, `data-engineering`, `product-thinking`, `agent-memory`, `llm-observability`, `ai-guardrails`, `rag-retrieval`, `synthetic-data`

**KEEP-POINTER (11)** — do not rewrite pack bodies; do not add `status:` to their CAPABILITY.md (missing = active):

`web-frontend`, `web-backend`, `web-ui-design`, `code-security`, `web-testing`, `web-deployment`, `ai-tool-integration`, `ai-agent-architecture`, `agent-orchestration`, `ai-evaluation`, `ai-prompt-engineering`

---

## Architecture

```
CAPABILITY.md first YAML fence  --(scan-packs.sh)-->  pack-registry.yaml status
                                                      |
        loaders (already shipped 9c33e2e5)  <---------+
        skip iff status == "frozen" (exact)
        missing status == active
```

Durable SSOT = first frontmatter fence of `.tad/capability-packs/<name>/CAPABILITY.md`.  
`extract_frontmatter_field` matches `^status: ` inside the first `---` pair only (required: space after colon).  
Insert exactly `status: frozen` as the **last key** of that first fence. Do not edit later `---` fences (e.g. `academic-research` has many).

Registry is generated. After regen, all 25 rows emit `status:`. KEEP packs with no CAPABILITY `status` emit `status: "active"`. Expected incidental header refresh (live registry is stale 2026-07-13): `last_scanned` UTC date, `synced_from_version` from `.tad/version.txt` (currently `2.44.4`), plus the scan-packs comment line forbidding hand-edit of status. Description/keywords/consumes/produces/type/path were byte-equal in a temp dry-run.

Do **not** modify `scan-packs.sh`, loaders, AGENTS.md, pack SKILL trees, experiment-path, tad.sh, hooks, principles.

---

## Data flow

1. Blake inserts `status: frozen` on the 14 FREEZE CAPABILITY files (first fence only).
2. `bash .tad/scripts/scan-packs.sh` (live packs dir, no `--packs-dir`).
3. Auto-match readers of `pack-registry.yaml` skip the 14; KEEP 11 still pointer.
4. Human-named escalate still works via existing AGENTS keyword rows (13 of 14 FREEZE packs already listed; `research-methodology` has **no** AGENTS row today — do not add one).

---

## Temp dry-run (Alex, `/tmp`, repo untouched)

`scan-packs.sh --packs-dir=<copy>` after inserting 14 `status: frozen`: **25 packs, 14 frozen, 11 active**, name sets match the lock, keyword/description/consumes/produces/type/path lines equal to live registry. Live baseline: **0** CAPABILITY `status`, **0** registry `status` keys.

---

## Options considered (MQ6)

| Option | Verdict |
|--------|---------|
| A. CAPABILITY `status` + scan-packs only | **Adopted** (human lock) |
| B. Also strip AGENTS keyword rows | Rejected — named escalate needs the table |
| C. Uninstall / delete SKILL trees | Rejected — files stay |
| D. Register leftovers then freeze | Out of scope |
| E. Bundle experiment-path dump | Out of scope (later ticket) |

---

## Skip list (reaffirm)

Unregistered leftover SKILLs · AGENTS `agent-computer-interface` row · `experiment-path-protocol.md` dump of `ai-evaluation` · KEEP pack body refresh · rewrite `scan-packs.sh` · live loader edits · push/tag/release / absorb into v2.44.4 publish payload.

---

## Gate 1 (Alex)

| Item | Status |
|------|--------|
| Problem defined | Loader skip exists; no live pack is frozen (AC11 of loader). Auto-match still announces stale packs. |
| User | TAD maintainer / future zero-context Alex·Blake |
| Scope bounded | 14 CAPABILITY + one registry regen |
| AC verifiable | Handoff §9.1 AC1–AC11 |
