# 清理报告 + v2.44.6 版本建议

> 日期：2026-09-15 ｜ 角色：Alex (Solution Lead) ｜ 范围：TAD 仓内文件；`docs/pm/` 只读
> 清理 commit：`78f4ca0f`（本地，未 push / 未 tag / 未 bump）
> 基线：`origin/main = 86c89917`；live tag `v2.44.5` = `b3193d24` → `1f6aaad2`

---

## 一、结论先行

**版本建议：可以做 2.44.6，但先关掉研究机制的人类 CHECK。**

1. **进 2.44.6 的内容**：v2.44.5 之后的 4 个任务 commit（`86c89917`、`09fe43d4`、`c48e5620`、`f92cbc73`）+ 本次清理 commit `78f4ca0f`。
2. **版本号 2.44.6 合适**（patch）—— 4 个 commit 都是在既有面上的「接线/细化」（tax-cut checklist、review habits、research 是套在既有 `*research --deep` 引擎外的 wrapper，fuse 不 fork），无 breaking、无新子系统，与 v2.44.5 同型。
   - ⚠️ 张力点：`CHANGELOG` 自述遵循 SemVer，RG1–RG4 严格算「新增功能」→ 按政策是 **2.45.0**。若想把「TAD Research 机制」作为对外可见的里程碑，用 2.45.0 也成立。**默认建议 2.44.6**，除非你决定让研究机制挂头牌。
3. **发版前唯一硬门**：`f92cbc73`（research 机制）Gate 4 PASS 但状态是「待人类最终 CHECK」。CHECK 不关，不应随版发布；可先发 3 个已 accepted 的，或先 CHECK 再发 4 个。
4. **缺的东西**见 §三：bump commit、CHANGELOG 条目、push、preflight、以及一个「下游能不能看到」的诚实性核对。

---

## 二、任务一：脏工作区清理报告

清理后 `git status` 只剩 **`docs/pm/intent.md`、`docs/pm/now.md`**（按令只读、未动）。清理 commit `78f4ca0f`，20 个文件，+1962/−2293。

### 2.1 已完成事项的归档/清理

| # | 文件 | 状态 | 处置 | 依据 |
|---|------|------|------|------|
| 1 | `.tad/active/epics/EPIC-20260912-p2-process-tax-cut.md` | tracked 删除 | 保留删除 | 归档副本为终版（SC1–SC4 全绿），`.tad/archive/epics/` 已存在 |
| 2 | `HANDOFF-20260910-verify-delta.md` | tracked 删除 | 保留删除 | 归档副本为终版（`gate4_delta` 已补） |
| 3 | `COMPLETION-20260910-verify-delta.md` | tracked 删除 | 保留删除 | 同上 |
| 4 | `HANDOFF-20260912-p2-sc4-process-tax-cut-wire.md` | tracked 删除 | 保留删除 | 归档副本为终版 |
| 5 | `HANDOFF-20260914-ocr-review-habits.md` | tracked 删除 | 保留删除 | 归档副本为终版 |
| 6 | `HANDOFF-20260908-knowledge-seam-isolation.md` | tracked 改 | 归档副本用较新的 active（带 archived_to/gate4_verdict）刷新后删 active | 陈旧孪生；`.tad/archive/` 为 gitignored 权威副本 |
| 7 | `COMPLETION-20260908-knowledge-seam-isolation.md` | tracked 改 | 同上 | 同上 |
| 8 | `HANDOFF-20260913-skill-authoring-habits.md` | tracked 改 | active 与 archive 字节相同 → 删 active | 纯重复孪生 |
| 9 | `HANDOFF-20260908-release-v2443.md` | untracked | 刷新 archive 后删 active | v2.44.3 已发布；archive 已有 |
| 10 | `COMPLETION-20260908-publish-v2443.md` | untracked | 同上 | 同上 |
| 11 | `HANDOFF-20260909-release-v2444.md` | untracked | 归档到 `.tad/archive/handoffs/` | v2.44.4 已发布（NEXT 记 DONE），原无 archive |
| 12 | `COMPLETION-20260909-publish-v2444.md` | untracked | 同上 | 同上 |
| 13 | `HANDOFF-20260911-release-v2445.md` | untracked | 归档 | v2.44.5 已发布（tag 在盘/远端），原无 archive |
| 14 | `COMPLETION-20260911-publish-v2445.md` | untracked | 归档 | 同上 |
| 15 | `COMPLETION-20260915-tad-research-mechanism.md` | untracked | **tracked 进 active**（未归档） | Gate 4 PASS，待人类 CHECK；未 accepted 不归档 |
| 16 | `HANDOFF-2026-09-15-tad-research-mechanism.md` | 已 tracked | 不动 | 随 `f92cbc73` 入库 |

> 归档根因：`.gitignore:126-127` 已把 `.tad/evidence/` 与 `.tad/archive/` 排除出 git——所以「归档 = 落盘到 gitignored 目录 + 从 tracked active 删除」，归档动作本身不产生 commit（除删 active 外）。

### 2.2 modified 文件逐项判断

| 文件 | 处置 | 理由 |
|------|------|------|
| `.tad/brain-index.md` | **保留并 commit** | 09-13 重新生成的索引，反映新 pattern/pack 状态（含 Process Tax Cut 行、Pack Build Rules 更新），是合法生成物 |
| `.tad/project-knowledge/patterns/ac-verification.md` | **保留并 commit** | 2 条已蒸馏 pattern（gitignored fixture 的 Gate 4 机器局部性；pathspec 内混 hunk 需 hunk 级 staging），是 verify-delta / pack-loader 的知识沉淀漏提交 |
| `NEXT.md` | **保留 + 最小修错后 commit** | 新增的 DONE 行准确；但表头仍写 2.44.4→next 2.44.5、且 v2.44.5 段仍是「IN PROGRESS」——与实际（tag 已打）矛盾。已改表头为 2.44.5→next 2.44.6、v2.44.5 段改 DONE、补 2026-09-15 research「待人类 CHECK」行 |
| `PROJECT_CONTEXT.md` | **保留 + 修回归后 commit** | 新增的 Recently Completed 行有价值；但 Version 被从 HEAD 的 2.44.5 **回退成 2.44.3**（疑似云同步旧底稿），已修回 2.44.5、Last Updated 09-15 |
| `docs/pm/intent.md` | **不动（只读）** | 按令 `docs/pm` 只读；内容为 PM bridge 的 MODEL-LOCK / Latest 更新，留待 PM 侧提交 |
| `docs/pm/now.md` | **不动（只读）** | 同上 |

### 2.3 untracked 其余项

| 项 | 处置 | 理由 |
|----|------|------|
| `.dispatch-muse-20260915-175138-{2101,2102}.sentinel` | **加入 .gitignore，文件保留** | 模型派活运行时哨兵，非源码；不删除（可能是活跃 job 标记） |
| 6 个新 judge bundle（keep11/p2-sc4/pack-freeze/pack-loader/skill-authoring/verify-delta） | **路径脱敏后 commit** | 与既有 17 个 tracked bundle 同惯例；但含机器本地路径 `/home/box/云同步/TAD/`，已统一替换为 `<REPO>/`（公开仓卫生，对齐 `5e92914d` 隐私清洗） |
| `keep11-knife1.md`（0 字节） | **删除** | 空文件残渣；真件为 `keep11-knife1-cli-refresh.md` |
| `.git/index.sync-conflict*` 残留 | **未发现** | `find .git -name '*sync-conflict*'` 与全仓 `*.sync-conflict*` 均为空；无需处理 |

### 2.4 边界如实记录

- **未 push / 未 tag / 未 bump**：清理只落一个本地 commit `78f4ca0f`。
- `main` 现 **ahead origin/main 4**（3 个任务 commit + 清理 commit）；`86c89917` 已在 origin。
- v2.44.4 / v2.44.5 的 release handoff/completion **此前从未入库**（untracked）；本次归档到 gitignored archive——历史里补不回，仅作本地留存如实记录。
- `docs/pm/` 两文件仍 dirty，属预期（只读令）。

---

## 三、任务二：v2.44.6 版本建议

### 3.1 建议纳入的 commit

| Commit | 任务 | 分发面 | Gate | 建议 |
|--------|------|--------|------|------|
| `86c89917` | P2 SC4 process-tax-cut wire | `.tad/templates/*`、`.tad/tasks/`（→下游）+ `project-knowledge`/`docs`（上游） | Gate 4 PASS，已在 origin | 纳入 |
| `09fe43d4` | skill authoring habits | `.tad/templates/skillify-candidate-template.md` + `_index`/`pack-build-rules`（上游） | Gate 4 PASS | 纳入 |
| `c48e5620` | OCR K1–K5 review habits | `.tad/templates/output-formats/spec-compliance-format.md` + tax-cut（上游） | Gate 4 PASS | 纳入 |
| `f92cbc73` | TAD Research 机制 RG1–RG4 | `.claude/.agents/skills/alex/**`、`.tad/config-workflow.yaml`、`.tad/gates/`、`.tad/templates/research-*` | Gate 4 PASS，**待人类 CHECK** | **CHECK 后纳入** |
| `78f4ca0f` | 本次清理（bookkeeping） | 无运行时面 | — | 随版（无害） |

**二选一**：
- **(A) 推荐**：先关 `f92cbc73` 的人类 CHECK → 4 个任务 commit 一并发 **2.44.6**。
- **(B) 若想等 CHECK**：先发 3 个已 accepted 的作 2.44.6，研究机制留 2.44.7。⚠️ 但 `f92cbc73` 已在 main 线性历史里，单独排除需在 `c48e5620` 上打 tag（破坏「tag=main 尖端」惯例），代价更高——因此更推荐 (A)。

### 3.2 版本号判断

- **2.44.6（patch）合适**：4 个 commit 均是对既有 surface 的细化/接线，无 breaking、无新子系统；与 v2.44.5（verify-delta fail-close + pack loader + pack freeze 也走 patch）同型。
- **边界提示**：`CHANGELOG.md` 头部声称遵循 SemVer，「新增功能=MINOR」。RG1–RG4 是新增机制，严格按政策是 **2.45.0**。建议：默认 2.44.6；若你希望对外标记「研究机制上线」，用 2.45.0 更诚实。

### 3.3 发版前还缺什么（checklist）

1. **人类 CHECK（硬门）**：`f92cbc73` 的 `.tad/evidence/reviews/2026-09-15-gate4-acceptance-tad-research-mechanism.md` 状态 = PASS / 待最终 CHECK。关掉才能随版。
2. **bump commit `release: v2.44.6`**：按 v2.44.5 的 16 文件模板更新 —— `.tad/version.txt`、`.tad/TAD-VERSION`、`.tad/config.yaml`、`package.json`、`CHANGELOG.md`、`README.md`、`INSTALLATION_GUIDE.md`、`docs/MULTI-PLATFORM.md`、`tad.sh`、6 个 role SKILL 的版本串。`config.yaml version_history` 近期 patch 未登记，可不动。
3. **CHANGELOG `## [2.44.6]` 条目**：`## [Unreleased]` 目前为空，需补 4 项变更（按对下游可见/上游内部两档写）。
4. **push + tag + Release**：`origin/main` 现在停在 `86c89917`；需 push 3 任务 commit + `78f4ca0f` + `release: v2.44.6`，再打 annotated tag `v2.44.6`，建 GitHub Release（Latest）。
5. **preflight 两条命令需 exit 0**：
   - `bash .tad/hooks/lib/release-verify.sh version . 2.44.6 2.44.5`（陈旧版本串；`NEXT.md`/`PROJECT_CONTEXT.md` 已在排除契约内）
   - `bash .tad/hooks/lib/release-verify.sh parity .`（`.claude`/`.agents` 字节级 parity；`f92cbc73` 的镜像 completion 声称 `cmp=0`，需实跑确认）
6. **下游诚实性核对**：`derive-sync-set --dirs` 证实 **`project-knowledge/` 与 `docs/` 均不在分发集**（zero-touch）。因此 tax-cut / OCR / skill-habits 的 pattern 与 `docs/process-tax-cut.md` **下游看不到**；下游只拿到 `.tad/templates/*`、`.tad/gates/*`、`.tad/config-workflow.yaml`、role SKILL。写 CHANGELOG 时不要把上游内部文档说成「给用户的新功能」。
7. **释放路径纪律**：`docs/pm/{intent,now}.md` 仍 dirty（PM 侧），不得进 release pathspec；本次清理未碰。
8. **守则复核**：`EPIC-20260816-framework-health-repair` 的发布禁令已于 2026-09-03 Phase 2 Gate 4 解除，无阻塞。

### 3.4 建议动作序列

```
1. （人）关 research 机制 CHECK → *accept 归档 f92cbc73 单据
2. （Blake）release: v2.44.6 bump commit（16 文件 + CHANGELOG 条目）
3. （Blake）push main → annotated tag v2.44.6 → GitHub Release (Latest)
4. （Alex）Gate 4 复算：version/parity preflight + CHANGELOG 下游诚实性
```

---

## 四、证据锚点

- 清理 commit：`78f4ca0f`（`git show --stat 78f4ca0f`，20 文件）
- tag/SHA：`v2.44.5` = `b3193d24` → `1f6aaad2`；`v2.44.4` = `83e2ff03`
- origin：`git ls-remote --tags origin refs/tags/v2.44.5` → `b3193d24`（已推送）；`origin/main = 86c89917`
- 分发集：`bash .tad/hooks/lib/derive-sync-set.sh --dirs .`（无 `project-knowledge`/`docs`）；`--zero-touch` 含 `project-knowledge`
- 归档根因：`.gitignore:126-127`（`.tad/evidence/`、`.tad/archive/`）
- 隐私清洗先例：`5e92914d chore(privacy): scrub personal paths...`
- 研究机制 Gate 4：`.tad/evidence/reviews/2026-09-15-gate4-acceptance-tad-research-mechanism.md`（PASS，待人类 CHECK）
