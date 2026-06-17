---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Hotfix v2.31.1

**From:** Alex
**To:** Blake
**Date:** 2026-06-17
**Task ID:** TASK-20260617-005
**Priority:** Hotfix — 解除下游项目升级阻塞

---

## 🔴 Gate 2: ✅ PASS (express hotfix, 3-line version bump)

---

## 1. Why

v2.31.0 发布后才修了安装器的 5 个 bug（commits b58cdeb + aa972be）。修复已推到 main 但没 bump 版本。结果：

- 已升级到 2.31.0 的项目 → "Already v2.31.0" 直接退出，拿不到修复
- CLAUDE.md merge marker、--force flag、self-check 单向 diff 都到不了下游

Bump 到 v2.31.1 后，所有项目跑 `curl | bash` 看到 "Upgrade available: 2.31.0 → 2.31.1" → 自动应用全部修复。

## 2. Tasks

### Version Bump (4 files, "2.31.0" → "2.31.1")

1. `.tad/version.txt`
2. `.tad/config.yaml` → `version:`
3. `tad.sh` → `TARGET_VERSION=`
4. `package.json` → `"version":` ← 这次别漏了

### CHANGELOG

在 `## [2.31.0]` 上方插入：

```markdown
## [2.31.1] - 2026-06-17

### Fixed
- Installer self-check false positive on upgrade (bidirectional diff → one-directional: only flag source files missing from target)
- CLAUDE.md silently overwritten on upgrade (added marker-based merge preserving project-specific content)
- No way to reinstall same version (added --force flag, refuses downgrade)
- package.json version drift (added to release-runbook version list)
- curl|bash docs missing --yes flag for non-interactive use
- package.json files missing .agents/ directory
```

### Commit + Push + Tag

```bash
git add .tad/version.txt .tad/config.yaml tad.sh package.json CHANGELOG.md
git commit -m "fix(TAD): release v2.31.1 — installer hotfix (self-check + CLAUDE.md merge + --force)"
git push origin main
git tag v2.31.1
git push origin v2.31.1
```

### 验证

在 voice-studio 跑：
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```
应显示 "Upgrade available: 2.31.0 → 2.31.1" 并成功完成（self-check PASS + CLAUDE.md 有 marker）。

## 9. AC

- [ ] AC1: 4 个文件版本号 = 2.31.1
- [ ] AC2: CHANGELOG 有 [2.31.1] 条目
- [ ] AC3: tag v2.31.1 已推送
- [ ] AC4: voice-studio 升级成功（self-check PASS）
- [ ] AC5: voice-studio CLAUDE.md 有 `TAD:PROJECT-CONTENT-BELOW` marker

## Knowledge

教训记录到 project-knowledge：**安装器修改必须在 release 之前完成。先发布再修安装器 = 下游项目卡在旧版本拿不到修复（除非再 bump 版本）。**
