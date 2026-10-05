# PM 验盘记录 — S1 影响面盘点（maintainer-evidence 复活链）

- 日期：2026-10-04（PM 亲验，非执行者自报）
- step_id：`tad-evidence-revival-s1-01`；执行者会话：449e8e64-b7e3-44e1-8097-9dc03d8b9cb6
- 产物：`inventory-manifest.jsonl` 2,747,317 B／13,082 行；`inventory-summary.md` 14,450 B；完工说明 7,203 B；usage log 1,129 B（与完工回执数字逐一实测相符）

## 逐项对单

- **四锚**：summary 锚行 TOTAL_NOCARRIER=8706／TOTAL_STALE=5／TOTAL_CARRIED=4355／TOTAL_BRANCH_ONLY=16；PM 独立重算 manifest 逐行计数与四锚全等，总行数 13,082＝四锚和，重复路径 0。
- **C-T3 集合等式（S1 收口首算）**：PM 以当前盘面重算——manifest 路径集 ⊆ A∪(B−A) 成立（man−expected＝∅）；expected−man＝3 件，恰为枚举时点尚不存在的盘点自产物（manifest、summary、完工说明），与 summary 的 FR3 复跑剔除规则明文一致。集合等式按 FR3 口径判定成立。第二算于 Gate 4。
- **C-T1 关闭**：安全管线照写死执行（ls-tree -z／find -print0、B 集只取 blob、gitlink 1 件单独注记）；PM 抽验 12 条非 ASCII（CJK）路径在 manifest 中全部归 carried；四锚与安全口径一致（交集 4,360 与 Gate 2 tech 独立复算全等）。差额分解成立：8,696→8,706 为设计快照后新增 10 件 no-carrier；stale 4→5 的第 5 件为本链 genesis 写入的 usage log 本身。**C-T1 关闭。**
- **C-T4（S1 部分）**：summary 第 4 行记执行者会话标识（session 449e8e64…＋step_id），在盘可查。**本步部分关闭**，余 S2 部分待 Brief 落盘。
- **AC**：AC3／AC4／AC5 按执行者实跑记录＋PM 重算交叉核对通过；AC8 的 S1 部分——PM 实测 usage log 2 行全可解析、首行 genesis、次行 step=S1，全链阈值待后续步写入达成（执行者如实标注未凑数，接受）。
- **事故留痕**：genesis 写入缺行尾换行致两行拼接、AC8 首跑解析失败，执行者当步逐字节修复（不改内容）并重跑通过，完工说明有完整记录。处置诚实、方法正确，接受，不另立返工。

## 裁定

**S1 验盘 PASS，收口。** 链进 S2（三案比较＋Decision Brief），数字唯一源＝本步 summary 四锚。
