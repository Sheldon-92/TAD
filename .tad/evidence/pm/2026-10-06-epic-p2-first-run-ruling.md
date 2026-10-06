# PM 裁断 — Epic Phase 2 件 2.1 首跑收口方式（2026-10-06）

事实（实施自报＋COMPLETION 附注记二）：样本集、runner、Gate 3 挂载全部落地、结构面自检 exit 0；被测侧判别命中 5/5/4、must_not 全 0。首跑的**对照捕获**失效：fork 型 subagent 继承会话上下文、引用了 input 外事实，三案按判分规则机械判 INVALID、整轮 FAIL，AC7/AC8 如实记 FAIL。

**裁断**：
1. 本轮 INVALID 属**捕获通道效度问题**，非样本集缺陷、非被测机制回归——评分器按冻结规则判 INVALID 正是其设计职能，本轮记为「首跑轮次无效、已归因」，不重判、不改判分规则迁就通道。
2. 件 2.1 的资产（样本集＋runner＋挂载）判**落地成立**；AC7/AC8 以 FAIL（已归因）收口本链，**首个有效基线跑列 Phase 3 开工前置**：借 Phase 3 真机回归的隔离捕获面重捕三案对照与被测输出后复评，结果落 `.tad/evidence/regression-runs/` 并回填本裁断的销账行。
3. Gate 3 双审按本裁断判读件 2.1：审资产与判分保真、污染实证是否成立，不以 AC7/AC8 的 FAIL 否决整批；Gate 4 同口径。
- **销账（2026-10-06）**：本裁断第 2 条所列 Phase 3 前置——首个有效基线跑——已完成：运行目录 `.tad/evidence/regression-runs/20261006-first-valid-baseline/`；样本集三件 `cases/*/control.md` 经 PM 裁断 `.tad/evidence/pm/2026-10-06-epic-p3-three-escalations-ruling.md` 第一节授权，以本轮洁净对照替换（新 sha256：`ec5d4bdf…`／`227e1182…`／`f49c13c6…`），同 runner 复评整轮机械 PASS（判别命中 5/7/6、must_not 全 0、对照命中 0/1/0）。件 2.1 首个有效基线至此成立，本条销账。
