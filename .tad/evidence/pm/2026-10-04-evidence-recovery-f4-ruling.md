# PM 裁定 — F4 冲突副本与 Phase 4 推送放行

- 日期：2026-10-04
- 裁定人：📐 TAD PM
- 输入：Blake 续行步停步报告（完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-push-note.md`，5,726 B）；PM 已亲查 grokbox 侧盘面复核。

## 事实（PM 复核）

- 冲突副本实为**两件**（Blake 报告一件，PM 复查见第二件）：`.git/logs/refs/remotes/origin/main.sync-conflict-20261004-225943-L64KYDF`（3,898 B）与 `…-231158-L64KYDF`（3,898 B），均位于 **grokbox 检出自身的 `.git/logs/`** 内，是 origin/main 远端跟踪 ref 的 reflog 被 Syncthing 同步时的冲突副本；活日志（3,910 B）末行与 Blake 所述一致（fetch 快进至 `5619b095…`）。
- grokbox 侧全树复扫：`.git` 之外 `.sync-conflict` **零命中**——证据树、工作树、分支对象均无冲突。

## 裁定

1. **冲突副本冻结不动**：不删、不合、不改名。它们属同步冲突存量，由用户/GM 的冲突处置流程管辖（本席已另行报 GM 知悉：同步面包含活动检出的 `.git` 目录，此类 reflog 冲突属结构性噪声源）。本链任何步骤不许触碰这两件。
2. **Phase 4 推送放行**：§4.5「命中 `.sync-conflict` 停步」的保护目的是防在证据树/工作树冲突状态下误推；本两件位于推送数据路径（git 对象与 ref）之外、证据树之外，该目的未被触及。Blake 停步报 PM 正确，本裁定即为该停步的出口。
3. **放行附加条件**：续行步开工先全树复扫——冲突命中若出现在 `.git` 之外任何位置，立即再次停步报 PM；仅 `.git` 内且仍为该 reflog 同源冲突时，按本裁定继续。推送与 Phase 5 按停步说明 §5/§4 续行清单原样执行，判据不变。
