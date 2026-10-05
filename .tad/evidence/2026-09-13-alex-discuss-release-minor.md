# Discuss: 是否适合发布 minor（如 2.45.0）？— TAD 方法库

**Date:** 2026-09-13
**Mode:** Alex `*discuss`（Solution Lead）
**Status:** discuss record only — **not** a handoff，**not** READY_FOR_BLAKE，**no** release/tag/push/publish executed
**Channel locks（本 session）:** 只讨论不改实现 · 只读写本仓 · 不执行 release/tag/push/publish · 不写 `docs/pm/now.md`（VM 侧写）

**Human goal:** 判断 2.44.5 之后是否够格切一个 semver minor（2.45.0），给出 发 / 不发 / 还缺什么。

**Knowledge ingress:** `principles.md` + `patterns/_index.md` 已读；匹配并读 `release-sync.md`（版本门/同步/parity 教训）。Pack pointer（**不加载**）: `ai-evaluation`（eval 决策）`.claude/skills/ai-evaluation/SKILL.md`；`agent-skill-evolution`（技能演进）`.claude/skills/agent-skill-evolution/SKILL.md`。

---

## 0. 已核实盘面（read-only，2026-09-13）

| 事实 | 值 | 命令/来源 |
|------|----|-----------|
| 仓 | grokbox `/home/box/云同步/TAD`（上游 `Sheldon-92/TAD`） | — |
| tag `v2.44.5` peel | `1f6aaad2`（release commit，2026-09-11） | `git rev-parse v2.44.5^{commit}` |
| `origin/main` | `86c89917` | `git rev-parse origin/main` |
| local `HEAD` | `09fe43d4` | `git rev-parse HEAD` |
| 本地领先 origin | **ahead 1**：`09fe43d4` 未推送 | `git status -sb` / `git log origin/main..HEAD` |
| 2.44.5 后 main 提交 | 仅 2 个，**docs-only**：`86c89917`、`09fe43d4` | `git log --oneline v2.44.5..HEAD` |
| 2.44.5..HEAD diffstat | 15 files，+823/−3；**无** `tad.sh`/hooks/SKILL 代码改动 | `git diff --stat v2.44.5..HEAD` |
| 既有 2.44.6/2.45.0 tag | 无 | `git tag -l` |
| 工作树 | **脏**：13 个 tracked 文件 modified/deleted（`NEXT.md`/`PROJECT_CONTEXT.md`/`brain-index.md`/`ac-verification.md` +14 行未提交/多份 active handoff 已归档待删 …）+ 若干 untracked | `git status --short` |

**两个候选提交的内容（都是 docs-only）：**

1. `86c89917` docs(p2-sc4)：把 process-tax-cut 清单接入 agent-loaded surfaces。新增 `.tad/project-knowledge/patterns/process-tax-cut.md`（+82）、`docs/process-tax-cut.md`（+102），改 `_index.md`、`ac-verification.md`、`handoff-a-to-b.md`、`release-handoff.md`、`acceptance-verification-guide.md`、两个 `output-formats/*`、`handoff-creation.md`。
2. `09fe43d4` docs(L2)：skill authoring habits（invocation-split / hard-soft / docs-cache）。改 `pack-build-rules.md`、`_index.md`、`skillify-candidate-template.md`。

**两者均有审查证据在盘（`.tad/evidence/`，gitignored）：** 各自 Gate 2 双 review + Gate 4 PASS 文件；提交信息与 NEXT.md 均标注「local; do not push/tag/release」、「Do not absorb into v2.44.5」。即：**这两笔当时被人为锁定为“不发布”**，不是遗漏。

---

## 1. Semver 判断：够 minor 吗？——不够

SemVer 定义：MAJOR=不兼容、MINOR=**向后兼容地新增功能**、PATCH=向后兼容的缺陷修复。以「TAD 方法库」为产品，其公开契约 = 命令 / Gate / hook / 安装器行为 / 模板 / 知识路由。

- 这两笔**没有任何新功能**：无新命令、无新 Gate、无 hook、无安装器/`tad.sh` 行为变化，纯 `.md` 知识/模板 prose。
- `86c89917` 的新增是**把已有 process-tax-cut 原则写成清单并接到模板**；`09fe43d4` 是给 `pack-build-rules.md` 补 L2 命名习惯。都是对既有做法的**文档化**，不是能力新增。
- 本项目自身惯例佐证：docs-only 的 completion 模板改动（PM Bridge）当年发的是 **PATCH 2.44.1**，CHANGELOG 明写 “docs-only patch”。故 docs-only = **patch**，不是 minor。

**结论：2.45.0（minor）不成立——属于 over-claim。** 最贴合的上限是 **patch**（若人决定消化这两笔，应为 2.44.6，而非 2.45.0）。严格按 SemVer，docs-only 甚至可不发版；但依 2.44.1 先例，house convention 允许 docs-only 走 patch。

---

## 2. 发版时机：要不要等 agent-skills-eval verdict？——不必等

- 该研究的**结论已落定**：源码已读（`b60eebe3`）→ **不导入 runner**。待办的只是“人看 verdict”（`docs/pm/now.md` 一行），不是“结论未定”。
- 研究产物在 `.tad/evidence/research/`（**gitignored，不进发布集**），与本次两笔发布内容**正交**。
- 把一项无关研究的**人工 review** 绑到一个版本上，是把 PM 待办当发布门——制造 process tax，且违反「只选 TAD 已有档位」。若 verdict 后续又生出新的 L2/eval 习惯，那是**将来另一笔**，不是这一版。
- 唯一要处理的只是 PM 侧 `docs/pm/now.md` 的 pending 标记（**VM 侧写，本 session 不碰**）。

**结论：不因该 research 阻塞发布，也不因它而发版。**

---

## 3. 若建议发（patch 2.44.6）——发布前还缺的证据/步骤清单（不执行）

> 前提：这是 **patch**，不是 minor；且 release/tag/publish 属 L3，**须人批**（`docs/pm/acceptance.md`）。

**A. 人类授权与口径**
- [ ] 人签发 Execution Mandate：确认「把这两笔 docs-only 作为 **patch 2.44.6** 对外发布」，并确认版本号语义（明确否定 minor）。
- [ ] 明确这是 publish-only 还是 publish+sync。

**B. 仓库状态前置（当前不满足）**
- [ ] 先把 `09fe43d4` 推 `origin/main`（当前 local ahead 1），使 tag 基线与 `origin/main` 一致。
- [ ] 裁决脏工作树：`M .tad/project-knowledge/patterns/ac-verification.md`（+14 行未提交 L2 知识）需决定**随版提交**还是**显式排除**；`brain-index.md`/`NEXT.md`/`PROJECT_CONTEXT.md`/已归档 active handoff 等 rider 按 pathspec-only 排除（严禁 `git add -A`）。
- [ ] 发布集用**显式 pathspec**（避免 v2.44.0 的 dirty-file version-line 幸存者问题）。

**C. 版本与文档**
- [ ] CHANGELOG `[Unreleased]` → `[2.44.6]`，条目写清两笔 docs-only 内容 + 其 Gate 4 证据路径。
- [ ] bump 12 个 primary identity 文件 + 3 个 `.agents/skills/` 镜像（沿用 v2.44.5 handoff §3.1 的清单），**逐行仅改版本 token**，不得夹带别 ticket hunk（`ac-verification.md` 2026-09-10 教训）。
- [ ] `README`/`INSTALLATION_GUIDE`/`MULTI-PLATFORM` 版本行同步。

**D. 门与证据**
- [ ] `release-verify.sh`：parity / derive-sync-set `--report` / version-sweep（Layer 1 blocking）/ version（advisory，分类 identity vs historical，**不得**改历史 pin 消警）。
- [ ] `tad.sh --verify-denylist`（若 bump 集含 `tad.sh`）。
- [ ] 确认 Gate 4 证据在盘并引用：`2026-09-12-gate4-p2-sc4-process-tax-cut-wire.md`、`2026-09-13-gate4-skill-authoring-habits.md`。

**E. 对外动作（人批后）**
- [ ] 单一 release commit R（pathspec-only）→ push `origin refs/heads/main`（clean FF）。
- [ ] annotated tag `v2.44.6` → push 该 tag only。
- [ ] GitHub Release notes：诚实描述“docs-only 知识/模板”，**不得**暗示安装器行为变化或 fleet 自动升级。
- [ ] post-publish 只读核验（tag peel == R；`origin/main` == R）→ completion report。

> 若人类坚持发 **minor 2.45.0**：先补充一条**真正向后兼容的新功能**（新命令/Gate/hook/安装器行为），否则应在 CHANGELOG 中说明为何 docs-only 被抬为 minor——目前无此依据。

---

## 4. Verdict

**CHECK_REQUIRED**（= 不发 2.45.0；patch 亦未就绪）

- **minor 2.45.0：不建议发**。两笔皆为 docs-only，无向后兼容新增功能，不满足 SemVer minor；且违反本项目 2.44.1「docs-only→patch」先例。
- **patch 2.44.6：技术上可发，但不是“现在”**。缺：① 人类 L3 授权（release/tag/publish 须人批）；② `09fe43d4` 未推 origin，tag 基线不一致；③ 脏树未裁决（含一笔未提交的 L2 知识）；④ CHANGELOG/bump/tag/release notes 全未做。
- **时机**：无需等 agent-skills-eval verdict（结论已定、且与发布集正交）。

**还缺什么（一句话）：** 人的 L3 拍板 + origin/工作树对齐 + 明确的版本语义（应为 patch，非 minor）+ CHANGELOG/version-bump/tag/release-notes 与 post-publish 核验。

**下一步（交人）：** 若只是想让这两笔被发行，请拍板「走 patch 2.44.6」并授权；若目标是凑一个真正的 minor，则先规划一项具名新功能再发。本 session 不 bump / 不 tag / 不 push / 不改实现。

---

## 附：本讨论未触碰
- 未修改任何实现、版本文件、CHANGELOG、tag、remote。
- 未写 `docs/pm/now.md`（PM/VM 侧）。
- 未加载任何 capability pack SKILL.md（仅登记 pointer）。
