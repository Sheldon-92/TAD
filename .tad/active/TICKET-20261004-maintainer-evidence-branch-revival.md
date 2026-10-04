# TICKET-20261004：maintainer-evidence 分支停摆处置

- 登记人：TAD PM（2026-10-04，源自 TASK-20261004 Gate 2 双审 T5/F6 共同 finding）
- 状态：OPEN，未排期，不在本批（状态面收口）范围内

## 事实（双审亲核）

- `.gitignore:122/:123` 整树忽略 `.tad/evidence/` 与 `.tad/archive/`，为有意设计（EPIC-20260816 Phase 4 发行瘦身，F-18），替代载体为 maintainer-evidence 分支。
- 该分支尖停在 2026-09-06（`8713ea4e`）。盘上约 12,014 个 evidence 文件中约 8,500 个无任何 git 载体；2026-09-06 之后的全部 Gate 证据只存于 Syncthing 同步盘。
- 本批三件交付物已由 PM 裁定走单文件 `git add -f` 例外入主仓（见 Gate 2 合并裁定件），不依赖本单。

## 待决

- 分支同步机制是否恢复、恢复到什么频率；或改以其他载体（主仓例外清单常态化等）替代。
- 处置前须先出影响面清单：停摆期间无 git 载体的证据逐件盘点。
