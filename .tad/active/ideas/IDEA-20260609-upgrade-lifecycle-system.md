---
id: IDEA-20260609-upgrade-lifecycle-system
title: "TAD 升级生命周期系统 — 远程用户无垃圾升级"
created: 2026-06-09
status: promoted
scope: framework
priority: P1
source: "用户讨论 2026-06-09 — 要求'深入骨髓'的长期机制，不是一次性修复"
---

# TAD 升级生命周期系统

## 问题

当前 tad.sh 处理全新安装和本地 sync 都没问题，但**远程用户升级**有一个结构性缺口：

1. **废旧文件不清理**：tad.sh 复制新文件但不删除旧版本有、新版本没有的文件。例如 v2.27.0 删掉了 blake/references/completion-protocol.md，升级后旧文件仍在。
2. **重命名造成重复**：文件改名后旧名 + 新名同时存在。
3. **没有 migration manifest**：没有结构化的"v2.26→v2.27 需要删除/重命名/迁移哪些文件"记录。
4. **升级后验证不完整**：verify_install_complete 检查新文件存在，不检查旧文件已清除。

## 用户原话

> "这些东西不是我现在跟你单纯的一次性说的，而是我们以后长期要形成的一个机制。我即便以后 Codex 到 3.0 4.0 5.0，这些东西已经深入骨髓了，不会出错。"

## 已有基础

- `tad.sh`：一键安装 + 升级 + `--platform` + ZERO_TOUCH + deny-list + verify_install_complete
- `*sync`：本地 14 项目同步 + deny-list + diff -rq
- `*publish`：GitHub 发版 + release-verify.sh
- `skill-body-verify.sh`：body 完整性 + 镜像一致性
- `runtime-freshness-verify.sh`：双平台兼容性 ledger

## 需要设计的机制

### Migration Manifest
每个版本附带一个 `.tad/migrations/{from}-to-{to}.yaml`，声明：
- `delete`: 需要删除的文件/目录列表
- `rename`: 需要重命名的文件映射
- `merge`: 需要合并的文件（如 CLAUDE.md）及策略
- `verify`: 升级后需要验证的条件

### tad.sh 升级流程增强
1. 检测当前版本
2. 查找所有 from→to migration 文件（支持跨版本链式升级）
3. 按顺序执行 delete/rename/merge
4. 复制新文件（现有流程）
5. 验证：新文件存在 + 旧文件已清除 + 用户文件未被覆盖

### 发版检查增强
`*publish` 时自动检查：
1. 双平台覆盖（已有）
2. migration manifest 是否已创建（如果有文件删除/重命名）
3. tad.sh 版本号是否自动更新（已有 derive_target_version）
4. GitHub 安装方式是否最新

## 设计原则

- **deny-list 优于 allow-list**（已有原则，延伸到 migration）
- **diff -rq 是终极验证**（已有原则）
- **跨版本链式升级**：v2.25 → v2.27 自动执行 v2.25→v2.26 + v2.26→v2.27
- **ZERO_TOUCH 保护不变**：用户的 project-knowledge、evidence 等永远不被升级触碰
- **幂等**：重复运行升级不会造成损害

## 关联

- principles.md: Deny-List Beats Allow-List
- principles.md: diff -r 是终极遗漏检测器
- principles.md: Never Hand-Write What an Existing Tool Already Does
- EPIC-20260609-dual-platform-native-runtime-architecture (双平台基础)
- EPIC-20260601-self-deriving-release-sync (deny-list 发版基础)

---
Promoted To: Epic (via *analyze — 2026-06-09)
