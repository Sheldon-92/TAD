# Journal: lite-core-closure (2026-07-31)

- 行为场景 fixture 的 prompt 必须自带"逐动作 logging 指令"（每个工具动作 append 一行到 raw-transcript.txt），否则 transcript 只能靠 agent 事后自述，无法机判顺序类 AC（S1 的 read-before-write 就是靠 ACTION 行号差判定的）。日志格式要在 prompt 里写死：`ACTION <seq>: <tool> <path>`。

- "两对 Lite 镜像都定义 X"类 AC 容易被读成"两个文件"——实际是 4 个文件（alex 对 + blake 对）。本次 AC2 初版只在 blake-lite 加了 Lite Progress 定义，自检时发现 alex-lite 缺失。教训：实现前把 AC 主语逐条展开成具体文件清单。

- 场景 S3/S4/S6 证明： fresh-context subagent 读更新后的 blake-lite 协议后，在 AC 不可运行、reviewer 不可用、同类错误连续复现三种情况下都能正确停在 GATE FAIL/BLOCK 而不是伪造 PASS——协议文本本身具备行为约束力，不只是纸面合规。

- 机械计数器 vs 契约格式（本轮 L0.5 实发）：handoff 用 `- **AC1 —` 加粗格式导致 `^- ?AC[0-9]` 计数为 0、误判契约未审。下游机械消费者的 regex 是契约格式设计的一部分——改模板或 handoff 格式时必须连带验证消费方的 grep/awk 仍能数到。
