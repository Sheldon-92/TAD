# AC Results — LITE-20260809-1543-full-capability-inventory-contract

**Date**: 2026-08-09
**Executor**: Blake-Lite
**Base**: `4116517`（HEAD）
**Status**: 8/9 PASS（AC9 待 L3 reviewer 文件落盘后终验；下述记录为各 AC 实际执行输出）

## AC1 — YAML schema、类型与枚举封闭

```text
AC1-PASS rows=19
```

- 顶层键精确 {schema_version, generated_at, grounded_against, baseline, capabilities} ✓
- `schema_version=1`、`grounded_against=4116517`、`generated_at` 为 String ✓
- baseline 六键 Integer ✓；19 个能力条目全部 17 字段精确闭合 ✓
- disposition / safety_class / supported_roles / modes 封闭枚举 ✓
- 日期值全部加引号字符串，无隐式 Date ✓

## AC2 — 可重放 source set 与 disposition 双向闭合

```text
AC2-PASS
AC2-PARITY-PASS
```

- generator `bash -n` 通过；fresh raw 与 mapped 前三列 `diff` 为空 ✓
- 4 列闭合：`canonical_file+mirror_file` union == source_files union（35+35）✓
- `legacy_trigger` / `standalone_skill` / `route_consumer+live_contract_consumer` union 全部双向闭合 ✓
- active `HANDOFF-*.md` glob == inventoried（当前 0 张，一致）✓
- canonical_file=35、mirror_file=35、legacy_trigger=45（≥29）✓
- 10 个 standalone_skill 全部 `File.directory?` 通过 ✓
- 35 对 canonical/mirror byte parity 全 PASS ✓

## AC3 — 13 个战略能力逐项存在

```text
AC3-PASS
```

- 13 个战略 ID 全部存在；summary/disposition/rationale/migration_dependency 非空 ✓
- 候选（release-ops=EXTEND, dependencies=EXTRACT）：target_skill / carrier_paths /
  supported_roles / modes / trigger_examples(≥2) / resource_plan.skill 精确绑定 /
  forward_test_prompt 全部非空 ✓

## AC4 — D1–D10 逐项选择 pattern/rationale/cost/source

```text
PASS: all 10 decision IDs (D1-D10) present
PASS: named artifact (Architecture Decision Document / Audit Report) present
N/A : no untrusted external input declared — dual-agent trigger not required
RESULT: structurally complete (exit 0)
AC4-PASS
```

- `audit-decisions.sh` 结构检查通过（10 ID + 标题；无 untrusted-external-input 触发条件）✓
- 表头 `| Decision | Pattern | Rationale | Cost impact | Source |` 逐字命中 ✓
- 10 行解析 5 列非空、D1–D10 ID 齐全、每行 Source 精确指向
  `.agents/skills/ai-agent-architecture/references/<expected>.md` 且文件存在 ✓

## AC5 — 权限与恢复反例形成结构化拒绝规范

```text
AC5-PASS
AC5-ANCHORS-PASS
```

- 6 fixtures ID 精确匹配；字段 schema 精确闭合；expected_verdict 全部 ∈ {DENY, BLOCKED} ✓
- decision_ids 与 D5/D6/D9/D10 映射表精确匹配 ✓
- 7 个逐字锚点全部命中：`Lite ∩ Skill ∩ Human`、`single task-state owner`、
  `pinned skill version`、`skill cannot override`、`fail closed`、
  `consume-once approval`、`idempotency key` ✓

## AC6 — Skill-creator 输入按候选 ID 一一对应，无提前创建

```text
AC6-PASS
```

- YAML EXTRACT/EXTEND 候选 {dependencies, release-ops} == contract `## Candidate:` 标题（diff 空）✓
- `.claude/skills` 62 目录 basename md5 `532e3b02…` == 基线 ✓
- `.agents/skills` 61 目录 basename md5 `948a58ef…` == 基线 ✓
- 未初始化任何 skill 目录（含 gitignored 路径不可逃逸）✓

## AC7 — 下游基线与 37 张 legacy handoff manifest 可重放、逐文件闭合

```text
AC7-PASS registered=14 reachable=12 missing=2 with_full=12 with_lite=1 active_full_handoffs=37
```

- fresh manifest == 交付 manifest（diff 空）✓
- downstream_summary 行 SOURCE==`.tad/sync-registry.yaml`，六值 == baseline ✓
- manifest 39 行：37 `pending` + 2 `missing-project`；四列格式、无 (project,path) 重复 ✓
- pending==active_full_handoffs、missing-project==missing、reachable+missing==registered ✓
- manifest 只经 `find -name 'HANDOFF-*.md'`，未读取任何正文 ✓

## AC8 — 运行时相对 immutable base 零变化

```text
AC8-PASS
```

- `4116517` 为 HEAD 祖先 ✓
- ledger / alex-lite / blake-lite md5 与契约钉死值一致 ✓
- tracked protected diff（CLAUDE.md AGENTS.md README.md INSTALLATION_GUIDE.md tad.sh
  .claude/skills .agents/skills .tad/hooks .tad/deprecation.yaml）为空 ✓
- protected 路径无 untracked 文件 ✓
- 全节点 path-set md5：`.claude/skills=226a1e01…`、`.agents/skills=6d932d6a…` 与基线一致 ✓

## AC9 — 本单成品路径集精确

**初跑（2026-08-09，ac-results.md 落盘时）**：

```text
bfs: error: .tad/evidence/acceptance-tests/full-capability-inventory-contract: No such file or directory.
bfs: error: .tad/evidence/reviews/blake/full-capability-inventory-contract: No such file or directory.
--- /var/folders/.../tmp.0CDBPGH0d0	2026-08-09 16:53:09
+++ /var/folders/.../tmp.Mzw55v5z7Z	2026-08-09 16:53:09
@@ -1,8 +1,6 @@
-.tad/evidence/acceptance-tests/full-capability-inventory-contract/ac-results.md
 .tad/evidence/designs/full-capability-extraction/capability-disposition.yaml
 .tad/evidence/designs/full-capability-extraction/composition-negative-fixtures.yaml
 .tad/evidence/designs/full-capability-extraction/generate-inventory.sh
 .tad/evidence/designs/full-capability-extraction/legacy-handoff-manifest.tsv
 .tad/evidence/designs/full-capability-extraction/skill-composition-contract.md
 .tad/evidence/designs/full-capability-extraction/source-inventory.tsv
-.tad/evidence/reviews/blake/full-capability-inventory-contract/code-reviewer.md
AC9-FAIL
```

原因（非实现缺陷）：acceptance-tests 与 reviews 两个目录尚未创建——ac-results.md 与
code-reviewer.md 为后续阶段交付物（L3 reviewer 文件落盘前路径集本就不完整）。

**终验复跑（2026-08-09，8 文件全部落盘后）**：

```text
AC9-PASS
```

`diff -u` 为空：路径集精确，无额外设计/证据文件。L3 reviewer 亦独立复跑确认
（code-reviewer.md §5：落盘后 `AC9-PASS`）。
