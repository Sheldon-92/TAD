# PM 裁断 — Epic P3 实施三件升级处置（2026-10-06）

判方：TAD PM（本席）。依据：COMPLETION-2026-10-06-epic-p3-runtime §5 三件升级＋首跑裁断（2026-10-06-epic-p2-first-run-ruling）。

## 一、承接 A：授权以本轮洁净对照替换样本集冻结对照（准）

- 事实：样本集 `cases/*/control.md` 三件为首跑 fork 污染捕获（文件头自注）；runner 以冻结对照复算，本轮实质测量成立（洁净对照 0/1/0、被测 5/7/6、must_not 全 0）仍被机械判 INVALID×3——无效性来自冻结参照本身，不来自本轮测量。
- 裁断：**准许替换**。执行要求：① 新 control.md 文件头注明本轮 run id、本裁断路径、被替代件的出处（首跑污染捕获，存档于 `.tad/evidence/regression-runs/20261006-first-run/` 不动）〔路径勘正（Gate 3 SAFETY P2-3／CODE 附带观察，PM 2026-10-06 订正）：原文简写「eval-runs/2026-10-06-first-run/」为笔误，盘面实址为本行所示全路径；执行方实际使用真址，程序无碍〕；② 替换后以同一 runner 复评，**整轮机械 PASS 才许回填销账行**（销账行以新增一行落于首跑裁断件尾）；③ 复评仍非整轮 PASS 即停步报 PM，不许二度替换凑 PASS。

## 二、Codex 真机基线 FAIL：归因厂商配额成立（挂账，不阻 Gate）

- grokbox 侧 Codex 账号用量上限（原文 retry after Oct 10, 2026 10:24 AM），零触发痕、非机制失败。AC16 部分成立维持。补跑排 10-10 配额恢复后，回填 transcript 与 step3f 登记；Gate 3/4 不因此阻塞，结论中如实带此挂账。

## 三、承接 B (ii) 维与 session-state 索引行

- (ii) 工时维：Gate 3 双审工时发生后由 PM 回填，试点结论行随之终定。
- session-state 索引行不在 Blake §7 写集内，其未动属守纪；由 PM 于本链收口时补记。
