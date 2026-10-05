# Gate 3 返工 R4 证据 — V-P7 `tad.sh` 侧 zero-mutation sandbox 实证（含负控）

- **Role**: Blake (Execution Master) — 只跑 sandbox；未改 `tad.sh`；未 commit
- **Date**: 2026-09-16 | **Installer**: 工作树 `tad.sh`（v3.0.0 移除批已 stage）
- **Sandbox**: `/tmp/opencode/vp7/target`（fresh `--platform codex` 安装，`exit 0`，落盘 `.agents/skills/alex`，无 `.claude` 生成）
- **Handoff**: §6.3 V-P7（tombstone + fail-before-mutation + 恢复命令）

## 静态顺序（本树实测行号）

- `resolve_platform` 调用 `tad.sh:2363` ≪ `NEED_ROLLBACK=1` `:2571` ≪ `take_rollback_snapshot` `:2575`
- `validate_platform`（`:519-536`）：`both|*claude*` → 报错 + 3 条恢复命令 + `exit 1`，`No files were changed`
- 结论：tombstone 结构性先于快照/首个 mutation（fail-before-mutation）

## 正控（V-P7 字面命令，sandbox）

1. `cp -a target target.pre`
2. `bash tad.sh --source $REPO --platform both --yes` → `exit=1`，tombstone 文案 + 3 条恢复命令（含 `--platform codex`）
3. `bash tad.sh --source $REPO --platform claude-code --yes` → `exit=1`，同上
4. `diff -rq target target.pre` → 空（**zero mutation**）
5. `… --platform both … | grep -F -- '--platform codex'` → 命中 3 行（恢复命令可复制）
6. 完整日志：`/tmp/opencode/vp7/intact-both.log`（`No files were changed` ×1，rollback 痕迹 ×0）

## 负控（判别力实证）

- **N1 顺序回归**：faulty 安装器（`resolve_platform` 调用从 `:2363` 移到 `take_rollback_snapshot` 之后，`bash -n` 通过，见 `/tmp/opencode/vp7/tad-faulty.sh:2576`）
  → `--platform both --yes --force` 仍 `exit=1`，但日志出现 backup/rollback 痕迹 ×3（`Rolling back…/Restored from backup…/Rollback complete`），与正控"零 backup churn"行为可区分 → **顺序断言 FAIL（按预期）**。
  附带诚实记录：文件终态 `diff -rq` 仍空——rollback 把备份复原（纵深防御吸收了单步后移）。终态等价 ≠ 无副作用，排序回归由日志侧暴露。
- **N2 恢复文案剥离**：faulty 副本删 3 条恢复命令（`/tmp/opencode/vp7/tad-norecovery.sh`）→ `grep -F -- '--platform codex'` 无命中（`exit=1`）→ **文案断言 FAIL（按预期）**。

## 附带：`tad-update-fixture.sh --case states`（R4 要求一并执行）

- `OLD_VERSION=2.44.6 bash .tad/tests/tad-update-fixture.sh --case states` → **14/14 PASS**（含 `explicit --platform both → removed-error`、`both present → platform codex forwarded (never both)`）。
- 注：`--old-version` flag 因派生先于参数解析而不生效（pre-existing 小瑕，不本批改），用 `OLD_VERSION=2.44.6` 环境变量绕行；`*-to-3.0.0.yaml` 缺失即 L2 设计的 chain gap（`! test -f` 另由 V-P6 断言）。

## 结论

V-P7 正控全绿 + 双负控均按预期 FAIL（有判别力）+ updater 相关用例 14/14。R4 关闭。
