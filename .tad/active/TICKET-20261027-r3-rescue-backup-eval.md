# TICKET — R3 抢救备份命名空间评估（.tad-migrate-backup 留存/迁移/退役）

- **Status**: OPEN（Owner 已落定，待触发——触发条件见 §6；蒸馏报告观察项经 conductor 于 Epic 收口核正，2026-10-27）
- **Filed**: 2026-10-27（EPIC-20261027-r4-batch Phase 5，C9 立票；dispatch_id: r4-p5-impl-a-1）
- **Owner**: TAD PM（Muse 侧 TAD 席位）— 2026-10-27 于 EPIC-20261027-r4-batch 收口落定接单（见 §5）

## 1. 登记源（逐字路径）

- `.tad/evidence/pm/2026-10-06-r3-gate4-final-ruling.md`（R3 终裁正本）
- `.tad/evidence/pm/2026-10-06-supplement2-judgment.md`
- `.tad/evidence/pm/2026-10-06-supplement3-judgment-addendum.md`
- 评估正本：`.tad/evidence/self-review-r2-20261006/g3-r3-migrate-backup-assessment.md`（R2 期对 migrate 备份的评估；本票的评估须以其为起点复核，不重做）

## 2. 对象身份

本票对象＝`tad.sh migrate` 在项目根生成的 `.tad-migrate-backup` 命名空间：目录名形如 `.tad-migrate-backup[.<时间戳>]`，位于各项目根，是 migrate 执行时对项目 `.tad` 树的抢救备份。

**非本票对象（显名区分，勿混入处置）**：
- `~/.tad-backups/tad-checkout-rescue-20261016`（58 MB，2026-10-16）——checkout 抢救集，属 GM 裁定的唯一副本保留件，不在本票范围。
- `~/.tad-backups/` 其余条目（各项目快照目录，2026-10-27 普查共 47 项）——快照面，与 migrate 命名空间无关。
- 本仓（TAD）内：无 `.tad-migrate-backup*` 实例（普查实测）。

## 3. 普查（2026-10-27 实查，只读 find/du/stat）

普查面：`~/workspace/yun-sync/` 各项目根（maxdepth 3 内含 AppleDouble 残件形态）＋`~/.tad-backups/`。

| 路径 | 体积 | 日期（mtime） | 形态 |
|---|---|---|---|
| `health-assistant/.tad-migrate-backup.20261023_140452` | 5 MB（du -sm） | 2026-10-23 14:04:52 | 完整备份目录 |
| `health-assistant/.tad-migrate-backup.20261023_141338` | 6 MB（du -sm） | 2026-10-23 14:13:38 | 完整备份目录（同日第二次 migrate） |
| `Voice Studio/._.tad-migrate-backup.20260923_121514` | 163 字节 | 2026-09-23 16:15:14 UTC | AppleDouble 残件（`._` 前缀元数据文件，非备份本体；其本体目录不在盘） |

`~/.tad-backups/` 内无 `.tad-migrate-backup*` 命名条目（该目录装的是 §2 所列快照面）。活实例合计 3 处，与立票时点的有界预查一致；备份本体在本票下只登记不动（不读内容、不移、不删）。

## 4. 待评估问题

对 `.tad-migrate-backup` 命名空间给出留存策略裁定，三选一或分项组合：

1. **保留**：维持现状（各项目根原地保留）——须定期限与复查点，不许无限期默认保留。
2. **迁移**：统一迁往集中保管面（如 `~/.tad-backups/` 下专设命名空间）——须定迁移形态（谁执行、何时、迁后项目根留什么指针）与同步冻结期口径（同步树内的移动在冻结期属受限动作，须用户当场许可或等解冻）。
3. **退役**：确认无恢复价值后删除——须先逐件核内容唯一性（备份可能是某次 migrate 前状态的唯一副本），核法与判据先于删除定。

附带问题：migrate 流程本身是否应改备份落点/命名/自动清理策略（治本项，与存量处置分开裁定）。

## 5. Owner 与落定动作

- Owner 落定：**TAD PM（Muse 侧 TAD 席位）**，2026-10-27 接单。本票属 TAD 本体运维卫生面，触发时由该席分诊处置（评估范围与建议形态见 §2–§4）。
- 落定动作：**EPIC-COMPLETION 落盘前，由 PM（TAD 席）把属主落定到具名席位并回写本票 Owner 行**——不在本票内预设属主，落定须有具名席位接单记录。

## 6. 触发（先到者）

- 下一次任一仓执行 `tad.sh migrate`（新实例产生即复查本票）；或
- 日期上限 **2027-01-31**。

## 7. Done criteria（任一成立且留痕即关票）

1. 留存策略已裁定并落盘（保留/迁移/退役或分项组合，含期限与执行者），且存量 3 处已按裁定处置完毕、处置结果逐件回写本票；或
2. 裁定为保留且已设明示复查日期（写入本票并同步登记到属主的复查面）；或
3. 经评估确认该命名空间已由 migrate 流程改版自然消亡（新版不再生成且存量已逐件核毕处置），证据指针落本票。
