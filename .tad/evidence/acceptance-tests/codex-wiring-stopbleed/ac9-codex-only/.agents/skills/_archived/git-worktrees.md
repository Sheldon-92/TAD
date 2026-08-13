# Git Worktrees Skill

---
title: "Git Worktrees"
version: "3.0"
last_updated: "2026-01-07"
tags: [git, worktree, isolation, parallel]
domains: [engineering]
level: intermediate
estimated_time: "20min"
prerequisites: []
sources:
  - "Git Documentation"
  - "obra/superpowers"
enforcement: recommended
tad_gates: [Gate3_Implementation_Quality]
---

> 来源: obra/superpowers，已适配 TAD 框架

## TL;DR Quick Checklist

```
1. [ ] 每个工作项创建独立 worktree（避免频繁切分支）
2. [ ] 规划分支与路径；清理策略明确（worktree prune）
3. [ ] 避免文件重叠造成冲突；建立 PR 合并路径
4. [ ] 并行开发时说明限制与共享依赖
5. [ ] 记录分支计划与合并策略（Artifacts）
```

**Red Flags:** 在同一工作区做多项工作、随意切换导致未保存更改丢失、worktree 残留未清理

## 触发条件

当 Claude 需要在隔离环境中进行功能开发、或需要并行处理多个分支时，自动应用此 Skill。

---

## 核心原则

**"使用 Worktree 创建隔离工作区，无需频繁切换分支。"**

Git Worktree 允许在同一仓库中同时检出多个分支到不同目录。

---

## 什么是 Git Worktree？

```
主仓库 (main)
├── .git/
├── src/
└── ...

Worktree 1 (feature-a)          Worktree 2 (bugfix-b)
├── .git -> 主仓库/.git         ├── .git -> 主仓库/.git
├── src/                        ├── src/
└── ...                         └── ...
```

**优点**：
- 无需 stash 或 commit 未完成工作
- 可以同时编译/运行多个分支
- 共享 Git 历史和配置

---

## Worktree 设置流程

### Step 1: 选择目录

```bash
# 检查现有目录约定
ls -la .worktrees/ worktrees/ 2>/dev/null

# 常用位置
.worktrees/          # 项目内（需 gitignore）
../project-worktrees/ # 项目外（推荐）
```

### Step 2: 安全验证

**项目内 Worktree 必须被 gitignore**：
```bash
# 检查 .gitignore
grep -q "worktrees" .gitignore || echo ".worktrees/" >> .gitignore
```

### Step 3: 创建 Worktree

```bash
# 创建新分支的 worktree
git worktree add .worktrees/feature-x -b feature-x

# 基于现有分支
git worktree add .worktrees/bugfix-y bugfix-y

# 查看所有 worktrees
git worktree list
```

### Step 4: 初始化环境

```bash
cd .worktrees/feature-x

# 安装依赖
npm install  # 或 yarn, pnpm

# 运行基准测试
npm test
```

### Step 5: 验证就绪

```
检查清单:
□ 依赖已安装
□ 基准测试通过
□ 开发服务器可启动
```

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type  | Description                 | Location                           |
|----------------|-----------------------------|------------------------------------|
| `branch_plan`  | 分支与 worktree 规划         | `.tad/evidence/git/plan.md`        |
| `isolation`    | 隔离约束与共享依赖说明       | `.tad/evidence/git/isolation.md`   |
| `merge_strategy`| 合并策略与冲突处理流程      | `.tad/evidence/git/merge-strategy.md` |

### Acceptance Criteria

```
[ ] 独立 worktree 对应独立任务；分支规划清晰
[ ] 冲突风险评估与处理流程明确
[ ] 清理策略（prune）规范执行；无残留
```

### Artifacts

| Artifact        | Path                                      |
|-----------------|-------------------------------------------|
| Branch Plan     | `.tad/evidence/git/plan.md`               |
| Isolation Notes | `.tad/evidence/git/isolation.md`          |
| Merge Strategy  | `.tad/evidence/git/merge-strategy.md`     |

## Worktree 管理命令

```bash
# 列出所有 worktrees
git worktree list

# 删除 worktree
git worktree remove .worktrees/feature-x

# 强制删除（有未提交更改时）
git worktree remove --force .worktrees/feature-x

# 清理已删除分支的 worktree 引用
git worktree prune
```

---

## 常见场景

### 场景 1: 紧急 Hotfix

```bash
# 当前在 feature 分支工作，需要紧急修复 main
git worktree add .worktrees/hotfix-urgent main
cd .worktrees/hotfix-urgent
git checkout -b hotfix/urgent-fix

# 修复完成后
git push origin hotfix/urgent-fix
cd ../..
git worktree remove .worktrees/hotfix-urgent
```

### 场景 2: 并行功能开发

```bash
# 同时开发两个功能
git worktree add .worktrees/feature-a -b feature-a
git worktree add .worktrees/feature-b -b feature-b

# 在不同终端中分别工作
# Terminal 1: cd .worktrees/feature-a
# Terminal 2: cd .worktrees/feature-b
```

### 场景 3: 代码审查

```bash
# 为 PR 审查创建 worktree
git fetch origin pull/123/head:pr-123
git worktree add .worktrees/pr-123 pr-123

# 审查完成后清理
git worktree remove .worktrees/pr-123
```

---

## 与 TAD 框架的集成

在 TAD 的开发流程中：

```
Alex 设计完成 → 创建 Worktree → Blake 实现 → 合并/PR
                    ↓
              [ 此 Skill ]
```

**TAD 使用场景**：
1. 设计验证后创建隔离开发环境
2. 并行开发多个独立功能
3. 紧急修复不影响当前工作

---

## 安全规则

### ⚠️ 关键警告

```
❌ 永远不要提交 worktree 目录
❌ 永远不要在两个 worktree 中检出同一分支
❌ 永远不要删除有未推送提交的 worktree
```

### ✅ 最佳实践

```
✅ 项目内 worktree 必须在 .gitignore 中
✅ 定期清理不再使用的 worktree
✅ 完成工作后使用 finishing-branch skill
```

---

## 基准测试失败处理

如果基准测试失败：

```markdown
## 测试失败分析

### 情况 A: 已知问题
如果失败是 main 分支的已知问题：
- 记录失败状态
- 继续开发
- 修复时不要掩盖已有问题

### 情况 B: 环境问题
如果是依赖/环境问题：
- 重新安装依赖
- 检查 Node/Python 版本
- 确认数据库/服务运行

### 情况 C: 需要许可
如果需要继续但测试失败：
- 明确告知用户
- 获得明确许可后继续
```

---

## 清理模板

```bash
#!/bin/bash
# cleanup-worktrees.sh

# 列出所有 worktrees
echo "Current worktrees:"
git worktree list

# 清理已删除分支的引用
git worktree prune

# 交互式删除（可选）
for dir in .worktrees/*/; do
  read -p "Remove $dir? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git worktree remove "$dir"
  fi
done
```

---

*此 Skill 指导 Claude 使用 Git Worktree 创建隔离的开发环境。*
