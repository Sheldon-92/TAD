# PM 裁定 — Epic P4 停步点 D-P0-1（worktree 定级与 Phase 2 放行，2026-10-06）

判方：TAD PM。依据：worktree-comparison.md 三向比对实测＋Gate 2 合并裁定 P2-1 预留（AC5 达成形态由 PM 在停步点裁定）。

## 一、定级裁断：立 (a′)「子集等值」级，三目录准删

- 实测事实：`local-wiki-phase3`、`local-wiki-phase3-native`、`tad-yolo2-scope-proof` 三目录均 **extra=0 ∧ sha_diff=0**（在盘每一文件都与对应分支尖端树逐件字节全等），仅 missing 27–28 件（同步通道对敏感名文件的系统性排除所致，副本为尖端树真子集）。
- 判读：删除安全性只取决于「在盘内容有无唯一字节」——extra=0 ∧ sha_diff=0 即唯一字节为零，删除不销毁任何 ref 不可还原的内容，REQ-1 安全实质成立。字面 (a) 级「差集为空」把 missing 向也算入，是判据形态问题、非安全问题。
- 裁定：三目录定 **(a′) 子集等值级，准予删除**，条件：① 删除前逐目录复行 AC4 回退验证（ref 物化→与 Phase 0 基线清单对应段比对，全等才删）；② 基线清单（20,480 行）永久留盘；③ 静默点执行、前后 .sync-conflict 计数比对（AC9）。
- `tad-yolo2-candidate`：实质 (b)（extra 11,275 件、约 116M 非 ref 内容），**本链绝不删**，冻结在盘，去向归 PM 后续另行裁断（属主在研内容可能）。

## 二、AC5 达成形态

- 以三目录删除（约 86M）＋`git gc` 为本链下降构成，逐项归因对盘点表行即为 AC5 达成；复测以 Phase 2 执行时点采样为准（并行链写入引起的总量浮动在归因表中单列，不算本链账）。

## 三、Phase 2 放行

- 准 Blake 续行 Phase 2（删除三目录＋gc＋复测归因＋COMPLETION 追记）。tad.sh 接线步（AC14/AC15）维持 BLOCKED-SERIAL，等备份修复链实施提交落盘后以新锚续做，不在本放行内。
