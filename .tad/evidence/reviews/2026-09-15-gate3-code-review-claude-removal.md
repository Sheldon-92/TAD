# Gate 3 独立 CODE 评审 — Claude 路径彻底移除 (v3.0.0)

- **Role**: Blake (Execution Master), Gate 3 独立评审 — 只评审不写代码，未改任何源码，未 commit
- **Date**: 2026-09-16 | **Workdir**: TAD 仓库 (grokbox 侧) | **HEAD**: `c32bde27` (v2.44.6)
- **Handoff**: `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan.md` (720 行, §S0–S9/AC1–AC21/V-P0–V-P7)
- **Dirty tree**: 722 entries (572 D staged / 142 M staged / 1 R staged / 1 M unstaged / 6 untracked)
- **docs/pm**: 只读，未写 (发现的 2 个 staged 改动见 C-2，内容与本任务无关)

## 结论: CONDITIONAL PASS

五个评审区**零功能性缺陷**，关键行为均已沙盒实测。放行条件仅为**流程卫生项** (C-1–C-4，无需返工代码逻辑；
C-1 为合入前必须，其余可 out-of-band)。任一条件未满足不得合入/发布，但**不需要回 Alex 重设计**。

### 必须返工项 (合入前)

- **C-1 (必须)**: `git add` 漏了 `.tad/tests/migration-fixtures/run-fixtures.sh` (唯一 unstaged M)。
  内容本身正确 (migration-gate fixture `.claude/skills` → `.agents/skills`，注释写明历史回放仍由引擎侧覆盖)，
  合入前 stage 即可。证据: `git diff -- .tad/tests/migration-fixtures/run-fixtures.sh`。
- **C-2 (必须)**: 批次中 staged 了 `docs/pm/intent.md`、`docs/pm/now.md` (各 2–4 行)。
  内容是 09-13 MODEL-LOCK 与 09-14 OCR status 的 PM 日常更新，**与移除任务无关、早于任务存在** (AC10 意图 PASS)，
  但按 handoff MQ Out (`docs/pm` 只读) 与 AC10 字面 (`git status --porcelain docs/pm` 须空) 不得随 v3.0.0 提交。
  处置: unstage 并另行提交/还原 (`git restore --staged docs/pm`)。
- **C-3 (建议，同批一行)**: V-P1 字面 grep (`\.claude/skills` over `.tad/hooks/lib`) 会命中
  `.tad/hooks/lib/parity-criterion.md:90,102`。该文件已按 §3.I20 选了 ARCHIVED 方案，两处是归档内的历史示例，
  保留是正确的；但 V-P1/AC20 命令需同步加 carve-out (`--exclude=parity-criterion.md`)，否则验证剧场 (门永远红)。
- **C-4 (建议，另单)**: `runtime-freshness-verify.sh` 当前 BLOCK (6 BLOCK/6 WARN)，但**全部**是 codex ledger 日期过期
  (`next_review 2026-09-02`，44 天 stale)，claude ledger 已正确 retired-skip (见区 5)。HEAD 上同样 BLOCK，
  与本批无关。AC21 字面 exit 0 需一次 codex ledger 日期刷新——另单做，**不得塞进移除批次**。

## 关键发现清单 (按评审区)

### 1. tad.sh 平台矩阵 + SSOT 反转 — PASS
- `KNOWN_PLATFORMS="codex"` (:514)，默认 codex (:544)，usage `(codex)` (:366)。
- tombstone `both|*claude*` (:523–531): exit 1 + 三条恢复命令 + `No files were changed`。顺序
  `resolve_platform` (main:2363) ≪ `NEED_ROLLBACK=1` (:2571) ≪ `take_rollback_snapshot` (:2575) → 结构性 fail-before-mutation。
- SSOT: 双 copy 循环均读 `$src/.agents/skills` (:1168,:1428)；`TARGET_SKILL_DIR=".agents/skills"` (:2367)；
  `resolve_pack_dir`/pack list (:825,:882)；rollback 只 snap `.agents/skills` (:1811)，`.claude` 零 snap/零 rmdir。
  全文件唯一 `.claude` 残留是 :1163 SAFETY 注释 (下游预存树永不删除——应保留)。
- 协同: `platform-codes.yaml` 仅 codex；`tad-install.mjs` 动态读 + tombstone + 默认 codex；
  `detect-platform.sh` 仅 codex/none；`tad-update.sh` 只认 `.agents/skills/alex`。
- **行为证据 (沙盒)**: `--platform both` / `claude-code` 均 exit 1 + 恢复文案 + target 零 mutation；
  默认 fresh 安装 exit 0，落盘 63 skills，无 `.claude` 生成。

### 2. release-verify parity/platform-skills + structural — PASS
- `parity`/`platform-skills` dispatch 整段删除；头注释保留移除说明 + 旧调用方 fail-closed (usage exit 2)。
- `structural` 比对 `.agents/skills` (:198，local-skill extras 按 FR7 正确豁免)；must-version registry → `.agents/skills` (:570–572)；
  migration scope 去 `.claude` (:77)。skills 内零 `release-verify.sh parity` 调用 (孤儿检查 PASS)。
- `parity-criterion.md` 按 §3.I20 选了 ARCHIVED (头注 + 不再被执行)——正确，见 C-3。
- **行为证据**: `structural . .` PASS；`version-sweep 3.0.0` PASS；`tad.sh --verify-denylist` PASS。

### 3. 消费者路径改写 (26 install.sh + 全清单) — PASS (附 C-3 说明)
- 注: handoff I12 为 **26** 个 install.sh (任务简报写 22 是约数)，实测 26/26 零 `.claude`，目标均为 `.agents/skills`。
- `capability-skill.sh`: canonical `.agents/skills` + `project` 子命令 tombstone (fail-closed)。
- 全绿: `brain-index-gen`、`pack-registry-driftcheck`、`scan-collisions`、`pack-eval-runner`、
  `pack-collisions.yaml` refs、`collision-signatures.txt`、`behavioral-eval-status.yaml`、
  `skill-body-verify`、`drift-check`、`knowledge-blame`、`migration-draft` scope、
  `detect-state-fixture` (PARTIAL sentinel→`.agents/skills`)、根 `tad` CLI、templates。
- `memory-redirect.sh` 按 §3.I4 正确处置: 整文件改为 RETIRED fail-closed (exit 2，无 mutation)，记忆数据不动。
- 剩余 `.claude/skills` 字面均有归属: (a) `tad-update-fixture.sh` + `migration-fixtures/test-15`——前者模拟旧 both 树 (S2/L6 需要)，
  后者验证历史 manifest 回放 (§3.L 需要)；(b) `skills-config.yaml`/`manifest.yaml`/`.tad/agents/*`——头注 `stale by design / historical record`
  (§3.K annotate-legacy 选项，无活代码读者)；(c) 见 C-3。
- 双写中性化: `.agents/skills` 内零 `<!-- Claude Code:`；标签 `websearch`/`code_reviewer` 全仓一致；
  `teammate_model: "inherit"`；judge README 已中性化。`research-methodology.md` 的 Claude 字面全在 Discovery/Grounded-in 历史文本 (§3.K 不动之列)。

### 4. YOLO harness + pair-driver — PASS
- `yolo-harness-profiles.json` 零 claude；测试断言 3 profiles (`codex/opencode/opencode-deepseek`)，
  **实跑 `yolo-harness-runner.test.mjs` exit 0 全 PASS**。
- `phase2-pair-driver.mjs` 零 `claude`/`sonnet` (grep -c = 0)；`JUDGE_MODEL_FAMILY` 默认 `'opencode'`；
  `.bak` 不存在；`node --check` 通过 (pair-driver + yolo-recovery)。
- `yolo-recovery.mjs` forbidden_scope → `.agents/`；三测试文件零 claude。
- 观察 (非问题): `.tad/guides/cross-model-invocation.md:54` 以对比口吻提及 `claude -p` 外部 CLI flag
  (防与 `codex exec` 混用)，属文档域、非运行时调用，不在 V-P1 硬零范围。

### 5. migration-engine allow-list — PASS
- `migration-engine.sh:72–73` 保留 `.claude/*` + `CLAUDE.md` (历史 manifest 只读回放不断裂)；
  **实跑** `--from 2.26.0 --to 2.27.0 --dry-run` exit 0，`.claude/skills/**` 路径正常 would-verify，无 REJECT。
- `2.44.6-to-3.0.0.yaml` 不存在；`migration-draft.sh:97` scope 已去 `.claude/`/`CLAUDE.md`；
  `deprecation.yaml` 仅含 pre-existing `.claude/commands/tad-*.md` 单文件条目 (L6 范围界定内，无目录条目)。
- 升级安全 fixture (`installer-data-safety-fixture.sh`) 覆盖矩阵字节一致 + AC2.4 用户 `CLAUDE.md` 不变。

## 未跑项 (声明)

- `installer-data-safety-fixture.sh` 全量执行 (耗时长；已静态确认 L6 覆盖 + 升级语义；fresh-install 沙盒已覆盖主路径)。
- V-P5/V-P7 负控逐条执行 (tombstone 顺序已静态确认 main:2363≪2571/2575；draft/deprecation 负控逻辑已读，未实际注入 sandbox 故障)。
- `docs/pm`、`CHANGELOG` 历史块、`.tad/evidence|archive|memory`、`.tad/migrations/*` 历史 manifest 均未动 (除 CHANGELOG 允许的 S9 新版本块)。

## 版本物料 (已核)

`.tad/version.txt` = `3.0.0`，`tad.sh TARGET_VERSION` = `3.0.0`，`package.json` = `3.0.0`；
CHANGELOG `## [3.0.0]` 仅 `### Removed` (无 2.45.0 Deprecated 块，§5.3 文案一致)；
`.claude/**` + `CLAUDE.md` 零 tracked (残留 `.claude/` 仅 untracked machine-local，§3.A8 范围外)；
`research/CLAUDE.md` → `research/AGENTS.md` (R)；`AGENTS.md TAD_PLATFORM=codex|none`；
公共文档零 "first-class … Claude Code" 断言；`.opencode/` 无改动；`.gitignore`/`package.json` 零 `.claude`。
