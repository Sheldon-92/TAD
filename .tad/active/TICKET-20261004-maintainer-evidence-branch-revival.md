# TICKET-20261004：maintainer-evidence 分支停摆处置

- 登记人：TAD PM（2026-10-04，源自 TASK-20261004 Gate 2 双审 T5/F6 共同 finding）
- 状态：**CLOSED（2026-10-04）**——研究轨链 TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL 已收口：影响面实测四锚 NOCARRIER=8706／STALE=5／CARRIED=4355／BRANCH_ONLY=16（票面估计已被实测取代）；PM 裁定采纳案一（恢复分支同步＋脚本化＋新鲜度看守），裁定件 `.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`；恢复执行另立票 TICKET-20261004-evidence-carrier-recovery-execution。

## 事实（双审亲核）

- `.gitignore:122/:123` 整树忽略 `.tad/evidence/` 与 `.tad/archive/`，为有意设计（EPIC-20260816 Phase 4 发行瘦身，F-18），替代载体为 maintainer-evidence 分支。
- 该分支尖停在 2026-09-06（`8713ea4e`）。盘上约 12,014 个 evidence 文件中约 8,500 个无任何 git 载体；2026-09-06 之后的全部 Gate 证据只存于 Syncthing 同步盘。
- 本批三件交付物已由 PM 裁定走单文件 `git add -f` 例外入主仓（见 Gate 2 合并裁定件），不依赖本单。

## 待决（已决，2026-10-04）

- 分支同步机制是否恢复、恢复到什么频率；或改以其他载体（主仓例外清单常态化等）替代。→ **已决**：恢复分支同步＋脚本化＋新鲜度看守（阈值 NOCARRIER>100 或分支尖超 21 天报警、每链收口必查、责任人 TAD PM），细节认 PM 裁定件。
- 处置前须先出影响面清单：停摆期间无 git 载体的证据逐件盘点。→ **已出**：S1 manifest 13,082 行逐件清单＋四锚，落 `.tad/evidence/research/maintainer-evidence-revival/`。
