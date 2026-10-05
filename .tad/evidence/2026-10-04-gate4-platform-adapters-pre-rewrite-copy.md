# Gate 4 Acceptance — TASK-20260915-OPENCODE-CURSOR-P1P3 (Platform Adapters P1+P3)

- **Date:** 2026-09-16
- **Owner:** Alex (Solution Lead), Gate 4 验收 — 只验收，不改代码，不 commit，不 push
- **Handoff:** `.tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md` (AC1–AC12)
- **状态:** 改动全部在工作区（未 commit）；工作区基线 `main @ 20223774` (release v3.0.0)
- **Gate 3 CODE:** `.tad/evidence/reviews/2026-09-15-gate3-code-review-platform-adapters.md` → **CONDITIONAL**
- **Gate 3 SAFETY:** `.tad/evidence/reviews/2026-09-15-gate3-safety-review-platform-adapters.md` → **CONDITIONAL PASS**
- **Gate 4 Verdict:** **CONDITIONAL PASS**（机器可读：`verdict: PARTIAL`）

> 说明：本刀是"installer 放宽 + 文档修正"，Gate 4 在 **commit 之前**执行（正常 Gate 4 在 commit 之后）。
> 因此机器令牌取 `PARTIAL`（= 条件性通过），条件全部是 **commit 时操作约束**，非代码返工。

---

## Prerequisite

| Check | Status |
|-------|--------|
| Gate 3 Passed | ⚠️ 条件性 — CODE CONDITIONAL（零功能缺陷，条件=commit 隔离）；SAFETY CONDITIONAL PASS（无红线，条件=commit pathspec） |
| Gate 3 evidence 文件 | ✅ 两份均在盘（code + safety） |
| Completion report | ❌ **缺失** — `COMPLETION-2026-09-15-platform-adapters-p1p3.md` 不存在（§7 manifest 要求） |
| Gate 2 dual reviews | ❌ **缺失** — `2026-09-15-gate2-review-platform-p1p3-{spec,scope}.md` 不在盘（§7 manifest + §9.2 Teeth 要求） |
| Gate 3 evidence manifest 文件 | ❌ **缺失** — `.tad/evidence/reviews/gate3-evidence-platform-p1p3.md`（§7 manifest 要求） |
| task_type | `mixed`（shell installer + YAML + live docs） |
| feedback_required | false — skip |
| e2e_required / research_required | no / no |

> 证据缺口（Gate 2 dual / completion / gate3-evidence）是 **流程证据完整性问题**，不是本刀代码缺陷。
> 两份 Gate 3 独立评审（CODE + SAFETY）实际承担了独立复核，结论可交叉验证。

## Layer 2 audit (smoke alarm, non-blocking)

- 目录 `.tad/evidence/reviews/blake/{platform-adapters-p1p3}/` 不存在 → 同既往各刀，记为 smoke alarm。
- 不阻塞 Gate 4：§9.1 Verification Method 已从盘上 live 重组（见下），Gate 3 code/safety 文件存在。

---

## 1. 两份 CONDITIONAL 条件性质核查（任务问题 1）

**结论：两份条件的剩余项全部是"commit 时操作约束"，零代码返工。**

| 来源 | 条件 | 性质 | 需要改代码？ |
|------|------|------|--------------|
| Gate 3 CODE（§5） | C1 commit 仅含 §6.1 九路径，`git add --` 显式列，禁 `git add -A`；排除 `NEXT.md` / `docs/pm/intent.md` / `docs/pm/now.md` + 6 个他线 untracked | commit hygiene | ❌ 否 |
| Gate 3 CODE（§5） | C2 commit 后运行 AC12，要求 `MISSING=[] EXTRA=[] DELETED=[]`；subject 含 `TASK-20260915-OPENCODE-CURSOR-P1P3` | commit 后机械验证 | ❌ 否 |
| Gate 3 CODE（§5） | C3 观察项：`tad.sh:1298/2367` "only target" 注释过时（另开卫生刀，本刀不碰 guard） | 非阻塞观察 | ❌ 否 |
| SAFETY（§4） | C1 同上 commit pathspec 隔离（含 untracked 本 handoff 需显式 `git add --`） | commit hygiene | ❌ 否 |
| SAFETY（§4） | C2 观察项：文档头 "3.1" vs `version.txt` 未 bump — handoff §6.3 授权 | 授权，无需动作 | ❌ 否 |

**无一条要求修改 `tad.sh` / YAML / 文档 / rename。** 两条件一致，指向同一个 commit 隔离义务。

---

## 2. §9.1 AC 独立重组（任务问题 2a）— 从盘上 live 执行

Gate 4 从当前工作区（未 commit，HEAD `20223774`）**独立重跑**每个 landing Verification Method（不引用 Blake 摘要）：

| AC# | Method | Expected | Alex 实测 | Status |
|-----|--------|----------|-----------|--------|
| 1 | `grep -cF 'KNOWN_PLATFORMS="codex opencode cursor"' tad.sh` | 1 | `1` | ✅ PASS |
| 2 | `validate_platform` 抽取探针（每平台隔离 `bash -c`） | codex/opencode/cursor=ACCEPT；claude-code/both/bogus=REJECT | `codex=ACCEPT opencode=ACCEPT cursor=ACCEPT claude-code=REJECT both=REJECT bogus=REJECT` | ✅ PASS |
| 3 | 安装器自有 `parse_platform_root_files` | 三平台均 `[AGENTS.md]` | `codex:[AGENTS.md] opencode:[AGENTS.md] cursor:[AGENTS.md]` | ✅ PASS |
| 4 | `opencode`/`cursor` 空目录安装（mktemp） | 两者 OK；skills + AGENTS.md 存在；无 `.codex/hooks.json` | `opencode=OK cursor=OK` | ✅ PASS |
| 5 | `bash tad.sh --help \| grep -cE 'opencode\|cursor'` | ≥1 | `1` | ✅ PASS |
| 6 | AGENTS.md canonical tokens | `True` | `True` | ✅ PASS |
| 7 | AGENTS.md `Known Gaps` 含 P2/P4 | `True` | `True` | ✅ PASS |
| 8 | README 无排他声明 + 含 opencode/cursor | `True` | `True` | ✅ PASS |
| 9 | 兄弟文档排他声明清除 | `BAD=[]` exit 0 | `BAD=[]` | ✅ PASS |
| 10 | `.agents/skills/*.md` 无裸根 `.md` | `STRAYS=[]` exit 0 | `STRAYS=[]` | ✅ PASS |
| 11 | codex 安装回归（hooks 仍生成） | `codex=OK` | `codex=OK` | ✅ PASS |
| 12 | commit scope set-equality | post-commit；`MISSING=[] EXTRA=[] DELETED=[]` | ⏸ **待 commit**（HEAD 仍 v3.0.0 基线，`git diff-tree HEAD` 无意义） | ⏸ PENDING |

**AC1–AC11 = 11/11 PASS，逐条与 handoff §9.1 一致（预期值、命令、输出全部吻合）。AC12 唯一未执行项，原因合法：需 commit freeze。**

### 2b. FR 对齐抽查（工作区 diff）

- FR1/FR4：`tad.sh` 仅 4 处语义变更（usage L366 + 注释重写 + `KNOWN_PLATFORMS` + accept arm），`both|*claude*` / `*)` / `resolve_platform` / hooks guard / `project_opencode_command` 全 untouched ✅
- FR2：`.tad/platform-codes.yaml` 追加 `opencode:`/`cursor:` 两块，`extra_deny: []` + `extra_root_files: [AGENTS.md]`，codex 块零改动 ✅
- FR3：AC4 实测两目标无 `.codex/hooks.json`；AC11 codex 仍有 ✅
- FR5/FR6：5 份 live 文档排他声明独立扫描 → 五文件均无 `sole runtime|only target|唯一目标|single install target` token ✅
- FR7：`AGENTS.md` 新增 `## Known Gaps (OpenCode / Cursor)`（P2 点名 `.opencode/plugins/tad.ts` + `.cursor/hooks.json`；P4 明示无真机 transcript）；`INSTALLATION_GUIDE.md` 一行 P2/P4 ✅
- FR8：`R100` rename，byte-identical；skills 根 `*.md` 空 ✅
- FR9：`CHANGELOG.md / PROJECT_CONTEXT.md / OBJECTIVES.md / ROADMAP.md / HISTORY.md / docs/CODEX-USER-GUIDE.md / docs/codex-guide.html / .tad/archive/ / .tad/brain-index.md / .tad/scripts/tad-update.sh / .agents/skills/*/SKILL.md / .tad/hooks/` 全无 diff ✅；`package.json` / `.tad/version.txt` 未动 ✅

### 2c. Known Gaps 声明诚实性

| Gap | 声明 | 诚实？ |
|-----|------|--------|
| P2 hook adapters | 明示未发货（`.opencode/plugins/tad.ts` / `.cursor/hooks.json`），无 SessionStart/PostToolUse、无 trace、无 ask-user 捕获 | ✅ 无夸大 |
| P4 live regression | 明示 "open-box usable rests on vendor docs + installer probe; no live harness transcript" | ✅ 无假装已验证 |
| C-5/C-11/C-12 | 仅 by-reference deferred | ✅ 一致 |

`.tad/codex/README.md` / `docs/MULTI-PLATFORM.md` 保留 "hooks P2 — not yet" 限定，无把 gap 说成已实现。**声明诚实。**

---

## 3. Gate 4 结论（任务问题 3）

### 判定：**CONDITIONAL PASS**（`verdict: PARTIAL`）

理由：
- **零功能/安全缺陷**：AC1–AC11 独立重组 11/11 PASS；FR 逐项对齐；Known Gaps 诚实；零 `D`；记录/版本文件未污染。
- 两份 CONDITIONAL 的剩余项 **全部是 commit 时操作约束**（隔离 + AC12），无需返工。
- 唯一未决 AC（AC12）与两份证据缺口均在 commit 之后才能闭合。

### 剩余项（闭合后即最终 PASS）

1. **commit**：恰含 §6.1 九路径，subject 含 `TASK-20260915-OPENCODE-CURSOR-P1P3`；排除 `NEXT.md`、`docs/pm/intent.md`、`docs/pm/now.md` 及 6 个他线 untracked。
2. **AC12**：commit 后运行 handoff §9.1 原命令，要求 `MISSING=[] EXTRA=[] DELETED=[]`。
3. **补写 COMPLETION**：`COMPLETION-2026-09-15-platform-adapters-p1p3.md`（§7 manifest 要求）。
4. **Gate 2 dual 证据**：`2026-09-15-gate2-review-platform-p1p3-{spec,scope}.md` 落盘，或由人显式 waive（当前 §7 manifest + §9.2 Teeth 未兑现）。
5. **观察（非阻塞）**：`tad.sh:1298/2367` "only target" 注释过时 → 另开卫生刀。

### commit 时 pathspec 要求（精确）

```bash
git add -- \
  tad.sh \
  .tad/platform-codes.yaml \
  AGENTS.md \
  README.md \
  INSTALLATION_GUIDE.md \
  .tad/codex/README.md \
  docs/MULTI-PLATFORM.md \
  .agents/skills/doc-organization.md \
  .agents/skills/_archived/doc-organization.md \
  .tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md
```

- **禁止** `git add -A` / `git add .`
- `docs/pm/**` 只读、不进 commit；`NEXT.md` 不进 commit
- rename 是否已 staged：当前 `.agents/skills/doc-organization.md → _archived/` 已是 `R100` staged；把新旧两路径都列出以保 rename 检测
- commit 后立即跑 AC12；Evidence 文件（本文件）**不进** commit

---

## 4. Decision Compliance（handoff §12）

| Decision | 实现 | Status |
|----------|------|--------|
| P1 mechanism = relax `validate_platform` + `KNOWN_PLATFORMS` + 2 YAML blocks | diff 一致 | ✅ |
| Default target = codex | `resolve_platform` untouched | ✅ |
| Hook generation = codex-gated | AC4/AC11 | ✅ |
| Doc coverage = 5 live docs | AC6–AC9 | ✅ |
| Hygiene = `git mv` 无删除 | R100 | ✅ |
| Records untouched | FR9 抽查全空 | ✅ |
| Version no bump | version 文件无 diff | ✅ |
| P2/P4 = Known Gaps | AGENTS.md + INSTALLATION_GUIDE | ✅ |

---

## 5. Knowledge Assessment (skip_KA?)

- Handoff frontmatter `skip_knowledge_assessment: no` → **不跳过**。
- **New discovery（Alex 侧）**：无架构/需求级新发现。本刀是既定研究结论（defer P2/P4，只做 P1+P3）的落地。
- 一个流程级观察已记入本报告（非 project-knowledge）：§7 `required_evidence_manifest` 声明的 Gate 2 dual / completion / gate3-evidence 三件未落盘，属"清单声明 ≠ 盘上现实"的复现；建议后续 knife 在 Gate 4 前做 manifest 存在性预检。
- Blake 侧实现发现归 Blake Gate 3，本 Gate 4 不重复。

## 6. Friction / Git-status

- Worktree dirty（本刀 8 改动 + rename + 本 handoff untracked；另有 3 tracked EXTRA + 6 untracked 他线文件）。
- 不做 override 吸收：EXTRA/untracked 一律排除，见 §3 pathspec。

## 7. Final

**Gate 4: CONDITIONAL PASS。** commit 可执行，但：
- ✅ **可以 commit** —— 建议按 §3 精确 pathspec 立即 commit，这是闭合 AC12 的必要步骤；本刀纯加法 + 文档 + 一次 rename，可 `git revert` 干净回滚，无状态/迁移/网络。
- ⛔ 在 AC12 通过 **且** COMPLETION / Gate 2 dual 证据补齐（或人显式 waive）之前，**不得**宣告最终 PASS / ACCEPT / 归档。
- 不 push / 不 tag / 不 bump / 不 release；`docs/pm/**` 只读；本 evidence 文件不进 commit。

**Handoff Created By:** Alex (Solution Lead) — Gate 4 acceptance
**Date:** 2026-09-16
