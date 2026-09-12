# Epic: P2 TAD process tax cut (principles only)

**Epic ID**: EPIC-20260912-p2-process-tax-cut  
**Created**: 2026-09-12  
**Owner**: TAD PM / Alex (`*discuss`)  
**Process**: Light *discuss land (docs). No Blake this phase. No bump/tag/release.  
**Upstream slice**: grok-cloud `EPIC-20260912-gmpm-improve-after-week1.md` Phase 3 (P2 only)

## Objective

Cut **vacuous-AC Gate 2 amend rounds**, **Layer 2 dirty-tree false P0s**, and **handoff wording that waits for a human `/gate 2`**, without pulling the teeth: **do not cut Gate 2 dual independent review; do not cut Alex≠Blake.**

## Confirmed (human 2026-09-12)

1. Acceptance realism guide — fewer vacuous ACs → fewer Gate 2 amend rounds  
2. Layer 2: before raising P0 on dirty trees, cross-check prior knives' known dirty patterns  
3. Reaffirm process Gate 2 = dual independent reviews **on disk**; ban wording that waits for human `/gate 2` (HO §3.13 already; stop residual **handoff** phrasing)

## Non-goals

- GM P0/P1 (wrong-dir, `pm_miss_n`, routing, insurance roster)  
- Cutting dual review or collapsing Alex/Blake into one session  
- KEEP11 knives; publish / bump / tag  
- Editing grok-cloud (pointer stub only; PM posts 「TAD 反馈」)  
- Mutating L1 `principles.md` SAFETY entries or SKILL/hooks this phase

## Success criteria

- [x] **SC1** Thin guide with copy-paste checklists on disk: `docs/process-tax-cut.md`  
- [x] **SC2** This Epic records the P2 slice + GM Phase 3 pointer stub  
- [x] **SC3** PM posts 「TAD 反馈」align (2026-09-12 human-authorized)  
- [x] **SC4** Wire checklists into agent-loaded surfaces (template / `_index` / verification guide) — Alex land + dual Gate 2 PASS 2026-09-12; Blake pathspec commit remaining

## Phase map

| # | Phase | Status | Deliverable |
|---|-------|--------|-------------|
| 1 | Principles + checklists | ✅ 2026-09-12 *discuss | This Epic + `docs/process-tax-cut.md` |
| 2 | Template wire (SC4) | ✅ Alex land + dual Gate 2 PASS 2026-09-12; Blake pathspec commit | Template / `_index` / verification-guide pointers; residual wait-phrasing grep in **templates only** |

## Sources (read, not edited)

- `/home/box/云同步/grok-cloud/.tad/active/epics/EPIC-20260912-gmpm-improve-after-week1.md` (P2 row)  
- `/home/box/云同步/grok-cloud/docs/research/2026-09-11-gmpm-and-tad-retro.md` §4–§6  
- TAD `.tad/gates/gate-canonical-checklist.md` Gate 2; `.tad/project-knowledge/patterns/ac-verification.md`

## Teeth (do not “optimize” away)

| Keep | Why |
|------|-----|
| Gate 2 = **two independent** review files on disk, P0 resolved | Retro: dual legs changed artifacts (quota CONDITIONAL; knowledge-seam R2/R3 FAIL) |
| Alex ≠ Blake (fresh session; no `-c` onto the other role) | Self-review has no second perspective (`principles.md` Two-Agent) |
| Layer 2 independent review still required | Catalog still needed the review; tax is **adjudication**, not skip |

## Pointer stubs (for GM Epic Phase 3 + 「TAD 反馈」)

**Paste into grok-cloud Epic Phase 3 (TAD PM does not edit grok-cloud this turn):**

```
Phase 3 / P2 — TAD 仓已落盘 2026-09-12 (*discuss, no Blake, no release)
- Epic: /home/box/云同步/TAD/.tad/active/epics/EPIC-20260912-p2-process-tax-cut.md
- Guide: /home/box/云同步/TAD/docs/process-tax-cut.md
- Teeth held: Gate2 dual review; Alex≠Blake
- Optional later: TAD Phase 2 template wire (SC4)
```

**Paste for 「TAD 反馈」align (PM posts):**

```
TAD 过程减税（P2，不砍门牙）
1) 验收写实：AC 必须可空跑；空转/整文件 grep/空集合绿灯 = 空 AC，会烧 Gate2 轮次。
2) Layer2 脏树：先对照前刀已知脏模式再升 P0；假阳性要记，不是免审。
3) 过程 Gate2 = 盘上两份独立审查（P0 已消化）。不要写「等人口头 /gate 2」才派 Blake（HO §3.13）。
Alex≠Blake、双审保留。指南：云同步/TAD/docs/process-tax-cut.md
```

## NEXT

- SC4: Alex landed surfaces 2026-09-12. Dual Gate 2 then Blake **pathspec-only** commit. No bump/tag/publish.  
- v2.44.5 publish remains a **separate** active handoff — do not absorb.  
- Human: SC3 发群 if not already posted.  
