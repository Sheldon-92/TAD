# dependency-ops-skill 验收 findings

## 1. F1 类缺陷（本单未发现新的 P0/P1 类实现缺陷）

无。AC1–AC19 全部 PASS 或如实声明（AC13 结构性不可达）。

## 2. 覆盖缺口（AC16 要求，逐条）

### (a) `registry: null` 依赖结构性永远 skipped（3 个）
`notebooklm-cli` / `rsync` / `claude-code-cli` 的 registry 字段为 null，deps-scan.sh
结构性跳过（AC6 实测 3 skipped）。新 skill 如实声明覆盖 3/6，不假装覆盖 6 个。

### (b) limitation-resolution 分支本轮不可达（AC13）
`gh` 的 `known_limitations` 为 `[]` → deps_update 第 5 步的 limitation-resolution 分支
在本轮 dogfood 上未被执行。未用合成 fixture 掩盖（yq 上游无变更、rsync 版本钉死，
强行触发即假数据）。该分支的正确性依赖当次 changelog 输入（D2 切断跨 session 引用），
建议后续在出现真实 limitation 的依赖上补验。

### (c) `deps_init` 未迁（Phase 5）
一次性能力（TAD registry 已存在），不迁移，归 Phase 5「次级能力处置」。

### (d) Homebrew 附带升级
AC19 实测：brew-before/after diff 仅 gh 一行（`< gh 2.96.0` / `> gh 2.96.0 2.97.0`），
**零附带升级**。无其它 formula 被动。

### (e) 新 skill 未在下游任何项目验证
本单只在 TAD 仓库内 dogfood。下游分发与验证属 Phase 6。

## 3. 执行期偏离（如实记录）

- **scope-baseline 重建**：首采版本缺 SHA 列（fence-audit 无法比对 dirty tracked 摘要），
  重建为三列格式（状态 SHA 路径）。重建值以开工时刻为准（11 个 dirty 文件本单未触碰，
  SHA 即开工时值；untracked 875 个历史项）。
- **verify.sh 本单专用**：以 install-smoke-v2410 版为基准派生，排除清单替换为本单路径
  + 授权修改 + txn-lock 目录模式。
- **AC17 首轮 Q3 出处 FAIL**：SKILL.md 的逾期公式/tier 在"定位与口径"说明性节 → 已内联
  到 deps show 第 3 步操作指令 → 增量复核转正。
- **scan-results.yaml 结构**：`results[]`（非 `dependencies[]`），AC6/AC7 用正确路径查询。
- **AC19 diff 行数**：`brew list --formula --versions` 对多 keg 输出合并行
  `gh 2.96.0 2.97.0`，diff 变化行恰 2 行（契约断言成立）。

## 4. 已知残留（不阻塞，如实上报）

- **release 回归未测**：`gh` 是 release ops 依赖（files_depending 4 处：publish-protocol.md /
  layer2-audit.sh / verify-ac-commands.sh / github-registry/REGISTRY.yaml）。升级后 release
  流程行为未做回归（超出本单范围），影响面在下一次 publish 显现。
- **F1（F8 发现）不属本单**：2.41.1 单的 tad.sh 升级判定缺陷，与本单无依赖。
- **skill 未在下游验证**（见 2(e)）。
- **limitation-resolution 未验**（见 2(b)）。

## 5. 验收补录（2026-08-12）

- **围栏基线格式决策**：本单 scope-baseline 采用三列（状态 SHA 路径），与
  install-smoke-v2410 的两列（状态 路径）不同——本单负控 B 需要 audit 半边能比对
  dirty tracked 的摘要，两列格式做不到（F8 遗留缺口）。install-smoke 单已知此局限
  （其 AC17 正控只覆盖 fresh 半边）。建议后续围栏统一用三列格式。
- **BRAIN-INDEX 无基线行处理**：基线不含 brain-index 时跳过（否则误报 VIOLATION）。

## 6. 外部归因记录（2026-08-12，P1-EPIC 处置）

- **EPIC-20260809-full-capability-extraction-retirement.md** 于处置期（09:20:26）被外部
  更新（3c 完成记录 + Phase 5 重定义），非本单写入。fence-audit 曾因基线摘要过期报
  VIOLATION-DIGEST。处置：按 ac-verification.md 2026-08-05 AMENDED 归因原则（外部修改 →
  文档归因 + 实质 PASS），同步基线摘要后 CLEAN。未重拍基线、未扩大排除白名单。
