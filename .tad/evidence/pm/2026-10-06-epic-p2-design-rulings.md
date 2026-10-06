# PM 裁断 — Epic Phase 2 设计待裁项 D-1–D-4（2026-10-06，Gate 2 前落定）

对象：HANDOFF-2026-10-06-epic-p2-measurement（76,370 B／sha256 `ff8eda17…`，PM 复算全等）§11。

- **D-1（票面标签）**：设计的读法成立——件 2.6＝B2 变更/回退证据试验、件 2.7＝C2 失败聚类与趋势行，以 Epic 件目表／判断正本／提案包原文三方为准。票面两行已由 PM 当场更正（TICKET-20261006-epic-p2-measurement L16–17），不留双读。
- **D-2（件 2.0 git 写例外）**：**认设计主案**——sync-maintainer-evidence 的 git 写（只写 maintainer-evidence 分支 ref＋blob、不动工作树与其他 ref、不推送、可由旧尖复位）是 A 线机制自带的受控围栏，属该机制的本职动作，不算票面红线（其辖区是 main 与发版面 git 写）的违反。本裁断落盘即解除 HANDOFF 中「裁断前 Blake 只许只读测算」的硬拦；实施时脚本只许默认形态跑、禁 `--expect-base` 绕谱系断言，PM 在 Gate 3 侧复核分支尖轨迹。
- **D-3（件 2.4 HARD 激活）**：**认设计主案 baseline-flip**——首份基线在盘之版起转 HARD；备选（本批补跑真机基线即刻 HARD）与 Phase 3「真机执行」分工相冲，不采。ADVISORY 缺面未登记即红的配套照设计。
- **D-4（同病扫描固化）**：**认设计主案**——本链一次性扫描＋方法记录，不新设机器步；是否固化指针入 publish-ops，待扫描结果回 PM 后另裁。

另两处设计内裁断（件 2.0 陈旧行 supersede 写法、件 2.9 断言寄生机器面）照设计提请 Gate 2 双审明确表态，PM 在合并裁定时落定。
