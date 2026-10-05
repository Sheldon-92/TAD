# Design pointer — Patch release v2.44.5 (four already-on-main deltas)

**Date:** 2026-09-11  
**Author:** Alex (Solution Lead), channel=Cursor, model=cursor-grok-4.6-medium  
**Handoff:** `.tad/active/handoffs/HANDOFF-20260911-release-v2445.md`  
**Type:** publish-only patch (no downstream sync)  
**No Gemini. No Blake this design turn.**

## Intent

Ship a public patch tag so installers pulling `v2.44.5` / `main` receive four already-accepted commits that sit on `origin/main` after live `v2.44.4`. Feature work is **already pushed**; this release is version identity + CHANGELOG + tag + GitHub Release only.

## Locked human decisions (this prompt)

| Decision | Lock |
|---|---|
| SemVer | PATCH `2.44.4` → `2.44.5` |
| Payload | Exactly the 4 commits after `v2.44.4` / `83e2ff03` (see table). Remaining KEEP11 knives **out of scope**. |
| Staging | strict pathspec; do not absorb dirty NEXT / PROJECT_CONTEXT noise / stale active twins / judge bundles / `docs/pm/now.md` |
| Publish | commit R (child of `63cf6291`) → push `main` → annotated tag `v2.44.5` → tag push → `gh release` |
| Safety | no `--force`; no `--tags`; no `&&` / `;` across push/tag |
| Sync | none |

## Payload (already on origin/main)

| SHA (short) | Full SHA | Subject |
|---|---|---|
| `7048b835` | `7048b835131c98c591231b7f00272053a918bf76` | feat(verify-delta): runnable Verification Method for *bug/*express |
| `9c33e2e5` | `9c33e2e55d02c86e252761556fea30e79a2d1835` | feat(pack-loader): thin on-demand pointer + freeze skip |
| `eb09597a` | `eb09597a6e639c8fcfce836147a0b400f32d0477` | feat(packs): freeze 14 capability packs via CAPABILITY status + registry regen |
| `63cf6291` | `63cf62912131d1f40273d54b0e6456aad9ba33af` | feat(packs): KEEP11 knife 1 CLI/SHA refresh for code-security + web-deployment |

## Gate 4 / archive citations (do not re-implement)

- verify-delta: `.tad/evidence/reviews/2026-09-10-gate4-verify-delta.md` (PASS). Archives: `.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260910-verify-delta.md` (no `GATE4-*` twin on disk).
- pack-loader: `.tad/evidence/reviews/2026-09-10-gate4-pack-loader-thin-ondemand.md` + `.tad/archive/handoffs/GATE4-20260910-pack-loader-thin-ondemand.md` (PASS).
- freeze: `.tad/evidence/reviews/2026-09-10-gate4-pack-freeze-inventory.md` + `.tad/archive/handoffs/GATE4-20260910-pack-freeze-inventory.md` (PASS).
- knife1: `.tad/evidence/reviews/2026-09-11-gate4-rerun-keep11-knife1-cli-refresh.md` + `.tad/archive/handoffs/GATE4-20260911-keep11-knife1-cli-refresh.md` (PASS). Prior PARTIAL closed by re-run.

## Git facts recorded at design time

| Ref | SHA |
|---|---|
| `HEAD` / local `origin/main` | `63cf62912131d1f40273d54b0e6456aad9ba33af` |
| remote `refs/heads/main` (ls-remote) | `63cf62912131d1f40273d54b0e6456aad9ba33af` |
| Prior live release (peeled `v2.44.4`) | `83e2ff03f48b3510482192797fc7f06e634f425d` |
| Annotated tag object `v2.44.4` | `4a9d655d58315b7c52479100ea87ac00b4380cb1` |
| remote `refs/tags/v2.44.5` | absent |

Blake must re-verify with `git ls-remote` immediately before push.

## Playbook parent

Reuse `.tad/active/handoffs/HANDOFF-20260909-release-v2444.md` (and its archived v2.44.3 parent pattern): 16 identity pathspecs, 3 explicit `cp` (never `parity --fix`), dirty-file reconstruction, P1–P4 unchained.

## Out of scope

Remaining KEEP11 knives; unfreeze/re-roster; `experiment-path` `ai-evaluation` dump; AGENTS ACI leftover; dirty-tree absorption; force-push; downstream `*sync`; feature edits inside commit R.
