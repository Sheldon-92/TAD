# NEXT.md 已完成条目归档（截至 2026-10-08）

> 从 `NEXT.md` 迁出的已完成条目，原文逐字保留。
> 本次迁出 31 个已完成小节（320 行；Epic EPIC-20261008 Phase 5a），外加附录：被移除的结构行与被就地改写的行的原文。仍未了结的行已抄进 `NEXT.md` 的「Carried from completed sections」。

---

### ✅ DONE 2026-09-14. OCR K1–K5 optional paste — Gate 4 PASS, archived

- Task ID: `TASK-20260914-OCR-REVIEW-HABITS`
- Handoff & Completion & Gate4: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260914-ocr-review-habits.md`
- Commit: `c48e5620` (4 §6.2 files; local; do not push/tag/release)
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-14-gate4-ocr-review-habits.md` (Verdict: PASS; AC1–AC13 recomputed from HEAD; pathspec set-equal; short intent lens holds)
- Human lock held: KEEP K1–K5 optional; REJECT CLI/npm, rule.json SSOT, replacing Gate2/3/Layer2, AACR-Bench KPI. Dual Gate 2 on disk. `layer2-audit.sh` missing `blake/{slug}/` (smoke alarm; not blocking).
- Do not absorb into v2.44.5. No tad.sh change.

### ✅ DISCUSS LANDED 2026-09-14. Thin user story vs AC / Gate3·4 (*research + *discuss, no Blake)

- Evidence: `.tad/evidence/research/2026-09-14-thin-user-story-vs-ac-gate34.md`
- Verdict: **recommend-practice only** for thin slices (who / situation / outcome / non-goals). **Reject** mandatory story format and dual SSOT. Gate3=AC/spec/evidence **consistent**. Gate4 = **AC recompute stays** + optional short intent lens (not intent-only).
- Teeth held: Gate 2 dual; Alex≠Blake. No charter/gate rewrite as locked policy.
- Human next: **lock** before any handoff/Blake. Do not absorb into v2.44.5.

### ✅ DONE 2026-09-13. Skill authoring habits (docs-only L2 + skillify) — Gate 4 PASS, archived

- Task ID: `TASK-20260913-SKILL-AUTHORING-HABITS`
- Handoff & Completion & Gate4: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260913-skill-authoring-habits.md`
- Commit: `09fe43d4` (4 §6.2 files; local; do not push/tag/release)
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-13-gate4-skill-authoring-habits.md` (Verdict: PASS; AC1–AC13 recomputed from HEAD; pathspec set-equal)
- Human lock held: Q1=② Q2=② Q3=①. Dual Gate 2 on disk. Layer 2 `blake/{slug}/` missing (smoke alarm; not blocking).
- Do not absorb into v2.44.5. No pack edits.

### ✅ DONE 2026-09-12. P2 SC4 process-tax-cut wire — Gate 4 PASS, archived

- Task ID: `TASK-20260912-P2-SC4-TAX-CUT-WIRE`
- Handoff & Completion & Gate4: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260912-p2-sc4-process-tax-cut-wire.md`
- Epic archived: `.tad/archive/epics/EPIC-20260912-p2-process-tax-cut.md` (SC1–SC4 complete)
- Commit: `86c89917` (12 §7 files; local; do not push/tag/release)
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-12-gate4-p2-sc4-process-tax-cut-wire.md` (Verdict: PASS; AC1–AC13 recomputed from commit blobs; pathspec set-equal)
- Do not absorb into v2.44.5. Residual WT riders stay other knives.

### ✅ DISCUSS LANDED 2026-09-12. P2 process tax-cut principles (no Blake, no release)

- Epic archived with SC4 (see DONE row above). Guide SSOT: `docs/process-tax-cut.md`
- Teeth held: Gate 2 dual review; Alex≠Blake. Out of scope: GM P0/P1, KEEP11, publish.
- Do not absorb into v2.44.5 R. Do not bump/tag.

### ✅ DONE 2026-09-11. KEEP11 Knife 1 CLI refresh — Gate 4 PASS, archived

- Task ID: `TASK-20260911-KEEP11-KNIFE1`
- Handoff & Completion: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260911-keep11-knife1-cli-refresh.md`
- Commit: `63cf6291` (41 allow-prefix files; local; do not push/tag/release)
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-11-gate4-rerun-keep11-knife1-cli-refresh.md` (Verdict: PASS; AC1–AC9 recomputed from disk; pathspec `extra []`; KA justified No)
- Prior PARTIAL: `.tad/evidence/reviews/2026-09-11-gate4-acceptance-keep11-knife1-cli-refresh.md` (KA missing; closed by Blake amend)
- Human locks held: two KEEP packs only; no Gemini; no freeze/unfreeze; no absorb into v2.44.4
- Carry (later knives): Netlify v27.5.2 re-resolve; banner GONE wording; pre-existing SAST `checkout@v4` example
- Human next: none for this task (archived)

### ✅ DISCUSS LOCKED 2026-09-11. KEEP-POINTER 11 content refresh ranking (Q1–Q5 = 2,1,2,1,1)

- Design: `.tad/evidence/designs/2026-09-11-keep-pointer-11-content-refresh.md`
- Roster lock holds: KEEP 11 still announce; 14 frozen at `eb09597a` (do not unfreeze).
- Later knives (not this handoff): web-ui-design split; P1 API packs; P2 trio.

### ✅ DONE 2026-09-10. Pack freeze inventory apply — Gate 4 PASS, archived

- Task ID: `TASK-20260910-PACK-FREEZE-INVENTORY`
- Handoff & Completion: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260910-pack-freeze-inventory.md`
- Commit: `eb09597a` (§7.2 15 paths only; local; do not push/tag/release)
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-10-gate4-pack-freeze-inventory.md` (Verdict: PASS; AC1–AC12 recomputed from disk; pathspec set-equal)
- Registry: 14 `frozen` / 11 `active`. Files stay. AGENTS rows stay.
- Human next: none for this task (archived). Do not absorb into v2.44.4.
- Out of scope (later tickets): leftovers, AGENTS ACI row, experiment-path dump, KEEP body refresh

### ✅ DONE 2026-09-10. Pack freeze inventory (*discuss) — roster locked by human

- Design: `.tad/evidence/designs/2026-09-10-pack-freeze-inventory.md`
- Lock: KEEP-POINTER 11 / FREEZE 14 (Unsure six frozen with the eight). Mechanic = CAPABILITY status + scan-packs. AGENTS rows kept.
- Superseded as active work by apply handoff above.

### ✅ DONE 2026-09-10. Pack loader thin / on-demand / freeze — Gate 4 PASS, accepted

- Task ID: `TASK-20260910-PACK-LOADER-THIN`
- Handoff & Completion: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260910-pack-loader-thin-ondemand.md`
- Commit: `9c33e2e5` (§7.2 12 files only; local; do not push/tag/release)
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-10-gate4-pack-loader-thin-ondemand.md` (Verdict: PASS; AC1–AC12 recomputed from disk)
- Human locks held: pointer max-2 / frozen-skip+files-stay / human-named OR recorded failure-retry escalate / loader pathspec only
- Residual (deferred): `experiment-path-protocol.md` `capability_pack_auto_load` still dumps `ai-evaluation` SKILL — later ticket
- Do not absorb into v2.44.4

### ✅ DONE 2026-09-10. verify-delta (runnable Verification Method fail-close) — Gate 4 PASS, archived

- Task ID: `TASK-20260910-VERIFY-DELTA`
- Handoff & Completion: `.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260910-verify-delta.md`
- Commit: `7048b835` (§7 pathspec only; riders unstaged; do not push/tag/release)
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-10-gate4-verify-delta.md` (Verdict: PASS; 23/23 Methods recomputed from disk)
- P2-2: legal-grep fixture exists locally under gitignored `.tad/evidence/acceptance-tests/verify-delta/` (not in the commit)
- Human next: none for this task (archived). Do not absorb into v2.44.4.

### ✅ DONE 2026-09-11. Publish patch v2.44.5 — shipped (live tag `b3193d24`)

- Task ID: `TASK-20260911-PUBLISH-V2445`
- Handoff & Completion: `.tad/archive/handoffs/{HANDOFF,COMPLETION}-2026091*-*v2445*` (archived 2026-09-15)
- Commit R: `1f6aaad2` (`release: v2.44.5`); annotated tag `b3193d24` → R; GitHub Release live.
- Payload: three commits after live `v2.44.4` / `83e2ff03` (verify-delta + pack loader/freeze + KEEP11 knife 1).
- Boundary: publish-only (no sync). Local handoff cleanup done 2026-09-15.
- Remaining KEEP11 knives out of scope.

### ✅ DONE 2026-09-09. Publish patch v2.44.4 (knowledge-seam) — shipped (live tag)

- Prior live tag `v2.44.4` / `83e2ff03`. Stale active twins of that handoff must not enter v2.44.5 R.

### ✅ DONE 2026-09-09. Upstream knowledge seam & downstream isolation — Gate 4 PASS, accepted (commits `e6e2126e` + `65963d6b`)

- Task ID: `TASK-20260908-KNOWLEDGE-SEAM-ISOLATION`
- Handoff & Completion: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260908-knowledge-seam-isolation.md`
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-09-gate4-acceptance-knowledge-seam-isolation.md` (Verdict: PASS)
- Gate 4 Rulings:
  - (a) Human locks hold strictly: Option A pure isolation (only README.md on clean installs, empty patterns/incidents); quarantine opt-in only via `tad.sh --quarantine-pk` (zero auto-quarantine on update).
  - (b) Layer 2 independent reviews: spec-compliance 19/19 PASS, code-reviewer PASS (P0:0, P1:0, P2:5; 3 applied, 2 deferred to Alex), test-runner 19/19 PASS + 5/5 supplemental probes green.
  - (c) Implementation adaptations D1 (cd-form install), D2 (scoped local/ skip for fresh install seeds), and D3 (script-dir resolution for `--quarantine-pk`) verified as `EQUIVALENT_SUBSTITUTE` and intent-preserving.
  - (d) Boundaries: local-only commits `e6e2126e` + `65963d6b`; no push, no tag, no release.

### ✅ DONE 2026-09-08. Clean TAD upstream research-routing entry pointers (Local Wiki primary, NotebookLM fallback) — Gate 4 PASS, accepted

- Task ID: `TASK-20260908-research-route-local-wiki`
- Handoff & Completion: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260908-research-route-local-wiki.md`
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-08-gate4-acceptance-research-route-local-wiki.md` (Verdict: PASS)
- Gate 4 Rulings:
  - (a) Layer 2 audit warning accepted as `EQUIVALENT_SUBSTITUTE` (substantive independent reviews verified).
  - (b) Protected boundaries clean: `docs/pm/` baseline exact match (0 added diff), `research/` read-only strictly adhered to.
  - (c) Scope: 28 modified in-scope files across 6 categories; 12 dual-platform mirror pairs 100% byte-for-byte identical; NotebookLM preserved intact as fallback under explicit `(Fallback)` designation.


### ✅ DONE 2026-09-08. TAD thin-tad harness adapter & OpenCode contract alignment — Gate 4 PASS, accepted (commit `d23f78ab`)

- Epic: `.tad/active/epics/EPIC-20260907-thin-tad-evaluation.md` — Harness Alignment Track completed.
- Task ID: `TASK-20260908-thin-tad-harness-adapter`
- Handoff & Completion: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260908-thin-tad-harness-adapter.md`
- Implementation Commit: `d23f78ab` (4 files under `experiments/thin-tad-pilot/`: `oc-adapter.sh` 100755, `runner.mjs`, `runner.test.mjs`, `README.md`)
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-08-gate4-acceptance-thin-tad-harness-adapter.md` (Verdict: PASS)
- Gate 4 Rulings:
  - (a) PREREQ-2 live OPEN accepted (`DELEGATED_TO_LIVE_RUN_PAIR`); 40/40 tests cover offline & real adapter spawn.
  - (b) Layer 2 in-harness subagents accepted as `EQUIVALENT_SUBSTITUTE` (R1 caught 3×P0, R2 verified all closed).
  - (c) Runner suite files committed to git (`d23f78ab`); handoff and completion archived.
- Boundary: Zero live model spend, zero forged runs, zero production TAD core edits. Hard stop.

### ✅ DONE 2026-09-08. TAD reliable-delivery cost experiment — Epic Complete (P1/P2/P3 Gate 4 PASS / Accepted & Closed)

- **Epic**: `.tad/active/epics/EPIC-20260907-thin-tad-evaluation.md` — All 3 phases completed and closed.
- **Phase 1 (Offline Suite)**: Gate 4 PASS (commit `fc2c07ce`).
- **Phase 2 (Tools Leg & Ineligible Matrix)**: Tools leg ACCEPT, live matrix `ADAPTER_INELIGIBLE` fail-closed closed.
- **Phase 3 (Offline Analysis & Decision)**: Gate 4 PASS (`.tad/evidence/reviews/2026-09-08-gate4-acceptance-thin-tad-evaluation-p3.md`). Deliverables `analysis.md` + `decision.md` + `verify-p3.mjs` accepted. Rulings: `MAINTAIN_CURRENT_RULES` + `NO_PRODUCTION_RULE_DELETION`; status `LIVE_EFFECT_UNDETERMINED` + `EMPIRICAL_DATA_ABSENT`.
- **Handoff & Completion**: Archived to `.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260908-thin-tad-evaluation-p3.md`.
- **Boundary**: Zero live model calls, zero forged runs, zero production TAD core edits. Hard stop.

### ✅ DONE 2026-09-08. TAD reliable-delivery cost experiment — Phase 1 Gate 4 PASS, accepted (commit `fc2c07ce`)

- Epic: `.tad/active/epics/EPIC-20260907-thin-tad-evaluation.md` — Phase 1/3 completed.
- Handoff & Completion: `.tad/active/handoffs/{HANDOFF,COMPLETION}-20260907-thin-tad-evaluation-p1.md`
- Implementation Commit: `fc2c07ce` (5 files under `experiments/thin-tad-pilot/`)
- Verification & Reviews: AC0–AC9 all green (`.tad/evidence/acceptance-tests/thin-tad-evaluation-p1/`), unit/negatives 32/32; Layer 2 spec + code reviews both DELTA-RECHECK PASS (`.tad/evidence/reviews/blake/thin-tad-evaluation-p1/`).
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-08-gate4-acceptance-thin-tad-evaluation-p1.md` (Verdict: PASS).
- Status & Boundary: P1 offline task package and validation chain accepted. No model executed, no OS sandbox isolation claimed, tokens/costs null/synthetic.

### ✅ DONE 2026-09-04. Public-facade cleanup — Gate 4 PASS, accepted (was: ~~Public-facade cleanup — Express handoff READY, Gate 2 PASS (awaiting Blake)~~)

- **Implementation**: `39a4aa50` (README.md only, 5+/3-: R1a headline patch-honest / R1b pointer + dual CHANGELOG anchors / R1c hybrid naming / R1d footer mirror); package.json verify-only (canon, zero edits)
- **Public writes**: `gh repo edit --description` (hybrid-c) + draft v2.44.0 (full SHA, non-Latest) → draft v2.44.1 (full SHA, Latest) → human draft-render approval → publish 2026-09-04T22:52:08Z/22:52:10Z; Latest = v2.44.1; v2.43.0 body hash unchanged (`d3af1fff…1b0c6c`)
- **Gates**: Gate 3 PASS (AC1–AC7 + dual Layer-2, 0 findings); Gate 4 PASS (Alex 7/7 independent recompute + fresh code/security reviews, P0/P1 = 0; performance N/A docs-facade; UX N/A)
- **档**: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260904-public-facade-cleanup.md` + `.tad/archive/proposals/DESIGN-20260904-public-facade-cleanup.md`
- **Notes**: completion `gate3_verdict:` marker left empty (Blake post-step telemetry gap, non-blocking, recorded in GATE4 §1); DESIGN AC6 comment "3 expected" miscounts case-sensitive count (actual 2, threshold ≥ 2 met — P2 observation, no action)

### ✅ DONE 2026-09-04. Publish v2.44.0 bundle — Gate 4 PASS, live

- **发布**: `origin/main = 40cf3234`（`2af31d1e` FF），annotated tag `v2.44.0`（obj `b9ac39c8`，peeled `40cf3234`）；CHANGELOG `[2.44.0]`（②Builder evolve+打包 ③安装器数据安全余项 + ①v2.43.1 三件套）
- **档**: `.tad/archive/handoffs/{HANDOFF,COMPLETION-STOPPED,COMPLETION-FINAL,GATE4}-20260904-publish-v2440-bundle.md`；AC1 `PASS-PER-A1`（14 条定性非漂移、仅本版有效），AC2–AC8 全 PASS
- **知识**: 1 条 pattern 进 `release-sync.md`（version-grep 门 exclusion 契约债）
- **待办**: P1 version 门 exclusion 契约更新（另起设计单）；ROADMAP:27 “v2.43.1 | Published” docs 小单；B-track 设计。以上全在本地、未受影响。

### ✅ DONE 2026-09-07. Publish v2.44.2 — Framework Health close-out B + Lite mute (-72.5% tarball)

- **Release Commit**: `7c1eb5a8` (`release: v2.44.2`, 16 files changed, +35/-22, version markers + CHANGELOG only).
- **Remote Branches**:
  - `origin/maintainer-evidence` synchronized to `8713ea4e` (clean fast-forward, 4377 evidence/archive files preserved).
  - `origin/main` synchronized to `7c1eb5a8` (clean fast-forward, ahead by 8 commits from `6a29edad`).
- **Tag & Release**: Annotated tag `v2.44.2` (`a11ed702`, peeled to `7c1eb5a8`) pushed; GitHub Release created at https://github.com/Sheldon-92/TAD/releases/tag/v2.44.2.
- **Gates**: Gate 3 PASS (Layer 1 8/8 ACs + Layer 2 DISTINCT_COUNT=2); Gate 4 PASS (Alex independent recompute verified).
- **档**: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260907-publish-v2442.md`.

### ✅ DONE 2026-09-06. Workspace hygiene & GitHub Registry scan — Gate 4 PASS, accepted

- **Implementation**: `fdd4831f` (exactly 5 files: `.gitignore`, `phase2-pair-driver.mjs`, `release-sync.md`, `NEXT.md`, `scan-log.yaml`)
- **Scan**: 54 lists, 33 updates, 43 pending candidates; REGISTRY.yaml untouched; `last_scan: 2026-09-04` per AC4
- **Gates**: Gate 3 PASS (Layer 1 7/7 + Layer 2 spec/code/test PASS); Gate 4 PASS (Alex 7/7 independent recompute + Layer 2 audit PASS, P0/P1 = 0). No push.
- **档**: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260904-workspace-hygiene-and-scan.md`

### ✅ DONE 2026-09-06. Full-channel Lite trigger mute — Gate 4 PASS, accepted

- **Implementation**: `30aa5ea4` (`fix(docs): mute Lite triggers on the Full-channel default path`, 2 files: `AGENTS.md`, `CLAUDE.md`)
- **Outcome**: Role Switching lite triggers muted; Alex/Blake definitions intact; footer `## Frozen Channel: TAD Lite` preserves explicit triggers; `CLAUDE.md` header compressed to 1 line blockquote; §2.5 byte-identical.
- **Gates**: Gate 3 PASS (Layer 1 5/5 + Layer 2 spec/code PASS, DISTINCT_COUNT=2); Gate 4 PASS (Alex 5/5 independent recompute + Layer 2 audit PASS, P0/P1 = 0). No push.
- **档**: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260903-bugfix-lite-mute.md`

### ✅ DONE 2026-09-06. Framework-health close-out B — 1b 搬运 + SC2 + SC3 re-slim (Gate 4 PASS, accepted)

- **Implementation (local, NOT pushed)**: Commit 1 `5f500691`（12 alex skill files，parity PASS）；Commit 2 `98b7e396`（`git rm --cached` 134 files + `.gitignore` 取回注释）。物理文件仍在磁盘（`find` ≥ 12558）。
- **Orphan**: 本地 `maintainer-evidence` = `8713ea4e`（4377 files，含 2 个 `.log`，`git add -f` 保护）；`origin/maintainer-evidence` 仍锁 `b6956606`（未 push）。
- **AC8**: `git archive | gzip -9` = `8704939` bytes → `SIZE_PASS`（载体 `.tad/evidence/acceptance-tests/TASK-20260906-FWHEALTH-B/ac8-tarball.txt` L1；降幅 72.50% ≥ 70%）。
- **Gates**: Gate 3 PASS（Layer 1 10/10 + Layer 2 spec/code PASS，P0/P1=0）；Gate 4 PASS（Alex 10/10 独立复算 PASS + Layer 2 审计 DISTINCT_COUNT=2 通过）。无 push。
- **Epic**: `EPIC-20260816-framework-health-repair` 全部 Phase（1a, 1a-2, 1b, 2, 3, 4）与全部 SC（SC1–SC5）全满贯闭环完成！
- **档**: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260906-framework-health-closeout-b.md` + `.tad/archive/proposals/DESIGN-20260906-framework-health-closeout-b.md`

### ✅ DONE 2026-09-03. Framework-health close-out A — installer data-safety remainder (Gate 4 PASS, human accepted)

- **Handoff/completion/Gate-4**: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260903-framework-health-phase2-remainder.md` + `.tad/archive/proposals/DESIGN-20260903-framework-health-phase2-remainder.md`
- **Implementation**: `f61c1892` + fix `1a256534` + fixture `b09aa052` (all local, NOT pushed).
- **Epic effect**: Phase 2 全 DONE，发布禁令已解除（条件满足）。v2.43.1 发布仍待人明确指令（issue-2 待定）。
- **Knowledge**: 1 条 pattern 已蒸馏进 `shell-portability.md`（red-first + cancelled-agent + printf-dash）。
- **Next**: B 单（1b deny_ref 搬运 + SC2 + SC3 re-slim）→ 发布裁定 v2.43.1(a/b) → ideas。

### ✅ GATE-4-PASS 2026-09-03. TAD v2.43.1 backup repair + `/tad-update` (accepted, NOT published)

- **Handoff/completion/Gate-4**: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260902-tad-update-v2431.md`
- **Gate 3 (Blake)**: PASS — AC1–AC13 verified; Layer 2 all PASS.
- **Gate 4 (Alex, independent recompute)**: PASS — 69/69 assertions re-verified on macOS; one finding (AC10 red: fixture's own `OLD_VERSION` literal vs version gate) fixed test-tooling-only in `8b8c7877`, re-verified 7/7+8/8. **Accepted SHA: `8b8c7877`** (local only).
- **⛔ Publish 待定**: framework-health Phase-2 禁令已解除（A-track Gate 4 PASS 2026-09-03）。发布仍需人明确指令：(a) 按原 SHA `8b8c7877` 发 v2.43.1；(b) 并入 A-track 重验再发。然后 AC14 + publish exact SHA。
- **Scope**: macOS dangling-symlink backup repair + one shared updater (Claude Code / Codex / updater-only OpenCode).

### ✅ DONE 2026-09-03. Capability Builder v1 — Phase 2 Evolve + Phase 3 Package (3/4, accepted `bba6ce84`, NOT published)

- **Handoff/completion/Gate-4**: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260903-capability-builder-phase23-evolve-package.md` + `.tad/archive/proposals/DESIGN-20260903-capability-builder-phase23-evolve-package.md`
- **Gate 2**: PASS (R1 双 FAIL 11 P0 全修 → R2 双 CONDITIONAL 0 P0). **Gate 3**: PASS (Layer-1 10/10 + Layer-2 双审 + fix-round 重验；P4 打靶纠偏 + rollback 前缀卫 4 行修复）。
- **Gate 4 (Alex)**: PASS — evolve 上线（含无信号空转闸）+ runner 资源设界 + 单 Skill 单 Plugin 打包；R1 核心零改动复核过；知识蒸馏 APPROVED 待应用（shell-portability 在 R1  fence 内， deferred 到 knowledge-maintain）。
- **Epic 现状**：Create ✅ / Evolve ✅ / Package ✅ / Dogfood ⬚（Voice Studio 边界，需人另起）。
- **剩余 P2**：stale-lock 恢复、大树哈希开销、timeout 路径跨机验证、`awk --` 卫生。

### ✅ DONE 2026-09-02. Local Wiki native browser capture

- TAD now owns the Node/Chrome-CDP capture path; the external download-Markdown plugin is prior art only and is not a runtime dependency.
- Gate 4 PASS at product `7cce3f78`; final AC scan repair `f235e377`; Node 12/12 and Python 24/24 PASS.
- Real rendered-page capture is accepted. Public YouTube captions remain experimental and degrade honestly on first-use failure.

### ✅ DONE 2026-09-01. **EPIC-20260824-yolo2-verified-orchestration** —— 4/4 accepted, remains opt-in

- **Epic**: `.tad/archive/epics/EPIC-20260824-yolo2-verified-orchestration.md` (4/4 accepted)
- **Reset decision**: `.tad/decisions/DR-20260824-yolo2-vertical-slice-first.md`
- **Status**: old 1,171-line Phase-1 verifier handoff is archived as SUPERSEDED and must not go to Blake; Cycle 6 is cancelled as a product path, not repaired locally.
- **Why reset**: five Gate-2 cycles optimized AST/VM/verifier safety before any real compact/kill/resume YOLO behavior existed. State integrity was strong, but semantic re-entry and final-quality non-regression were not first-class outcomes.
- **New Phase 1**: one real opt-in recovery vertical slice on a capability-proven reference harness: approved goal → verified work → forced compact/kill → fresh context semantic recovery assertion → continue → existing Gate.
- **Kept**: local files, frozen Handoff, bounded MEA slices, no blind retry, independent review, Y1–Y8/Gate authority and honest harness modes.
- **Deferred**: universal six-schema reducer, hash chain/fencing, bespoke JavaScript sandbox, full three-harness parity and default-on.
- **Decision**: human confirmed Epic v2 on 2026-08-24 (option 1).
- **Phase 3 P3-R1 decision (2026-09-01)**: Codex live `strict` is sufficient for the
  core release. Claude Code, OpenCode, and DeepSeek are experimental adapters and are
  qualified on first use; they no longer block Phase 3. The bounded Codex-only mandate
  was subsequently exercised by Alex with two calls and zero retries.
- **Phase 3 acceptance (2026-09-01)**: Alex independently completed two bounded Codex
  calls and proved native fresh/resume state recovery. Human accepted the limited core
  with runner packet injection and native resume argv wiring explicitly deferred to
  first actual automated use. No further provider calls are pending for Phase 3.
- **Phase 4 closure (2026-09-01)**: human selected immediate opt-in closure. The
  original 50–100 trajectory program is retained only as a future default-on proof
  requirement; it was not run. Epic closed with zero new provider calls/tests.
- **Phase 1 archive**: `.tad/archive/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` + matching COMPLETION.
- **🟢 Gate 3 substance PASS 2026-08-25**: current HEAD `4d9039c9`; runtime/dogfood/reviewer blockers closed.
- **✅ Gate 4 PASS 2026-08-25**: round-3 fix `7b12d429` makes lifecycle must-appear assertions follow the resolved pair. Alex independently passed active, simulated-archive, disposable committed-archive, and final real post-archive full suites (10/10, exit 0). The checker rejects absent, incomplete, duplicate, and split lifecycle states; recovery runtime and dogfood remained unchanged.
  - **dogfood 3/3 恢复全过**（base `84c3666c`）：interruption-a/b/c 各 hard 8/8 + soft 1.00 + 继续 + 隐藏验收 13/13 + Gate PASS + receipt。
  - ⚠️ **三次机制修复**（真实失败购买）：recovery packet 缺 VERIFICATION MODEL / PROHIBITIONS / side-effect 分类规则 → 各 0.88 → 修后 1.00。详见 `knowledge-assessment.md` + patterns/memory-and-learning.md 新条目。
  - ⚠️ 已知偏差：fresh context 为 OpenCode Task 子代理（DEGRADED_WITH_APPROVAL，人类 2026-08-25 明确批准，仅限 Phase 1）。
- **Phase 2 handoff**: `.tad/active/handoffs/HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md`
  implementation fixed at `b8faef6e` after explicit YOLO execution. Phase-1 and Phase-2
  suites are green; final mechanism-matched dogfood is 5/5 control + 5/5 treatment,
  repeated verified actions 0, unauthorized-next-action metric 0.
- **Gate 3 disposition**: `HONEST_PARTIAL`, not PASS. Independent Group-0 review
  reports `NOT_SATISFIED=8`, `PARTIALLY_SATISFIED=3`, `SATISFIED=1`. Matching completion,
  verdict, and knowledge assessment are recorded under the active handoff/evidence.
- **🟢 NEW HANDOFF 2026-08-27**: `.tad/active/handoffs/HANDOFF-20260827-yolo2-phase2-completion.md`
  —— 人类已选**修正案路径**并签署 `.tad/decisions/DR-20260827-yolo2-phase2-amended-acceptance.md`
  （接受 capability 9 降级 / resume-chain 会话延续 / 同 harness 异会话 reviewer 为有效证据）。
  Blake 按 §4 AC-B…AC-J 补齐：scope proof、六预算 fixture、alignment 链、arm 冻结等价、
  原生独立 reviewer、per-call 归因、durable §12 tree、三轮盲评 judges，最终 Group 0
  PASS → Layer 2 → Gate 3。Gate 4 归档仍由 Alex 执行。
  原 20260825 handoff 保留为设计权威；DR 仅取代其 strict-only 验收条款（限 Phase 2）。
- ~~Blocking next actions~~（由上述 completion handoff 接管）：strict assertion 边界已由
  显式降级批准绑定解决（`6eaef1fb`）；其余并入 AC-B…AC-J。

- **Current blocker (2026-08-30)**: final AC-B scope proof is red because the shared
  `96bbfada..HEAD` range includes the unrelated parallel local-wiki commit `f967276f`
  (35 paths outside the YOLO2 §3.1 allowlist). Do not widen the allowlist or revert
  that task (Local Wiki Gate 4 accepted and archived 2026-08-30); reconcile the acceptance baseline/range, then rerun Phase-1 AC-B before
  Group-0 and Layer-2. Evidence: `.tad/evidence/journal/yolo2-phase2-completion-2026-08-29.md`.

### 0. ✅ **DONE 2026-08-16** — Gate 3 Check 8 已改成「出声但不拦」（commit `f5f62af`）

- [x] **`pre-gate-check.sh` 补了 `else`**，读不到判定行时发 WARNING 并点名它读的文件。
      Gate 2（code-reviewer + security-auditor，5 个 P0）+ Gate 3 + Gate 4（Alex 独立复算）全过。
      归档：`.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260816-gate3-check8-audible.md`
      ⚠️ **本条原来的三处说法都是错的，留档备查**（清单不准 = 清单有害）：
      (a) 称它是「Gate 3 FAIL 唯一的 BLOCK 路径」→ 实际有 4 条 exit-2 路径，
          只有这条以**判定本身**为触发条件；主拦截是「无 COMPLETION」那条。
      (b) 原修法「补 else → `HAS_BLOCK=1`」→ **照做会误拦 90% 的报告**。
          实测最近 20 份 COMPLETION 有 **18 份根本不写任何 Gate 3 判定标记**。
          用户 2026-08-16 裁定：只出声，不拦截。
      (c) 起草时一度提出「扩 grep 抓 frontmatter `gate3_verdict:`」→ 也错：
          那字段是 Gate 3 **跑完后**的 post-step 才写，PreToolUse 时点按设计就是空的。

### 0d. ✅ 隐私：trace hook 写绝对路径 —— **源头已修**（Gate 4 accepted 2026-08-16）

- [x] **✅ DONE 2026-08-16 — 源头已修（commit `87c3db93`，Gate 3 PASS）**
      `record_trace()` 在 stat 之后把 `file_path` 转成**仓库相对路径**
      （`git rev-parse --show-toplevel` + case 前缀剥离，一处覆盖 jq/无-jq 两条输出路径）。
      15 条 AC 全绿（负控改前红 + 判别力实测：错序实现被 AC3 抓、jq 分支内插被 AC5 抓）；
      Layer 2：code-reviewer PASS、test-runner R1 CONDITIONAL → R2 PASS（F1-F4 全修复）。
      hook 端到端等效验证：`post-write-sync.sh` 产出的新 trace 是相对路径
      （`file":".tad/evidence/...`，不再以 `/` 开头、不含 `/Users/`）。
      AC12 钉死已知残留：**跨仓库写入保持绝对路径**（`*sync` 写下游项目仍泄漏），见下一条 NEXT。
      **Gate 4（Alex 独立复算，2026-08-16）**：自建 harness 重跑五条核心行为全过
      （含唯一有判别力的 AC3 —— cwd=子目录时 `size_bytes=2` 且路径相对，证明转换在 `stat` 之后）。
      **真实 Write→PostToolUse 链路已复核**（Blake 环境限制的那一环）：Alex 用 Write 工具建探针文件，
      hook 触发，`file` 字段为 `.tad/evidence/.../gate4-probe.md` —— **相对路径，修复在真实链路上生效**。
      探针与当天 trace 已清理；同文件内另一条 `/Users/` 是 `18:46:32Z` 产生的、
      **早于修复 commit `19:56:29Z`**，属修复前残留而非回归，已脱敏。
      ⚠️ **Gate 4 更正了 handoff 的一处机理描述**：「`case` 加引号防空格」是错的
      （`case` 模式不分词，含空格加不加引号都 MATCH）；引号真正防的是 **glob 元字符**
      （`/a[b]/repo` 不加引号 NO MATCH）。**结论没变，理由变了** —— 已进 `patterns/shell-portability.md`。


---

## 附录 A：从 NEXT.md 移除的结构行（原文）

---

## 🔴 优先队列（2026-09-03 晚：YOLO 三轨落地；B 单测量完成，设计待续 —— 明天继续）


## 附录 B：NEXT.md 内就地改写前的原文（路径修正、状态行、ACTIVE 块）

### 🔄 ACTIVE 2026-10-08. EPIC-20261008 multi-harness restore & cleanup (target v3.3.0)

- Epic: `.tad/active/epics/EPIC-20261008-multi-harness-restore-and-cleanup.md` (6 phases; branch `epic/multi-harness-restore`, local commits only)
- Decision record: `.tad/decisions/DR-20261008-claude-code-runtime-restore.md`
- Phase 1 (Claude Code instance spike) DONE 2026-10-08: D1 = per-skill symlinks; AGENTS.md load/suppress/@include conditions measured; shared hooks callable without shims. Gate report (local evidence): `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase1-gate-report.md`
- Next: Phase 2 installer + projection. Open carry C1: interactive-surface AGENTS.md loading not yet verified (needs a human `/memory` look).
- Stop point: push and tag in Phase 6 require human confirmation.
**当前版本**：3.2.0（自优化 Epic EPIC-20261006 总收口：Phase 3 运行时适配＋Phase 4 体量与知识复产＋tad.sh 备份修复）→ next：下一轮 PM 自查批 ｜ **默认通道**：full（`/alex` `/blake` `/gate`）｜ lite 🧊 冻结于 2026-08-13
- Handoff (tracked): `.tad/active/handoffs/HANDOFF-2026-09-15-tad-research-mechanism.md`
- Completion: `.tad/active/handoffs/COMPLETION-20260915-tad-research-mechanism.md`
- **Epic**: `.tad/active/epics/EPIC-20260816-framework-health-repair.md`（Phase 1 = 🔄 Active）
完整清单见 `.tad/ideas/`。此处只留最近三批的入口：
- **2026-06-16（SkillOpt 深研）**：见 `.tad/ideas/`
