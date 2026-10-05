# `.tad/evidence/` — 本目录不随发行物分发

**2026-08-16 起（EPIC-20260816 Phase 4）**，本目录与 `.tad/archive/` 已从 `main` 分支移除。

## 为什么

`tad.sh` 拉取的是 GitHub 的 **tarball 快照**（当前树，不含 git 历史），因此从 `main` 移除**即刻**减小所有用户的下载量，**无需重写历史**。

审计 F-18 实测：移除前 tarball 约 25 MB，而用户实际需要的框架文件仅约 4.5 MB。
本目录内容已在 `tad.sh` 的 `TAD_ZERO_TOUCH`（`tad.sh:225-226`）中，**从不复制进用户项目** —— 下载后即被丢弃。

## 如何取回历史内容

完整内容保留在 orphan 分支 `maintainer-evidence`：

```bash
# 读单个文件
git show origin/maintainer-evidence:.tad/evidence/<path>

# 检出整个目录到临时位置
git worktree add /tmp/tad-evidence maintainer-evidence
```

该分支从 `b6956606` 创建，含 **3348** 个 evidence 文件与 **895** 个 archive 文件。

## 本目录仍在运行时使用

框架运行时仍会**写入**本目录（trace、review、acceptance-test 等），
只是这些产物**不再被 git 跟踪**，故不进入发行物。
