<!-- FILES-READ -->
- /var/folders/ht/dds194f911zbp3nk0vl3ssr00000gn/T/opencode/tad-p1b/formB.md
- /var/folders/ht/dds194f911zbp3nk0vl3ssr00000gn/T/opencode/tad-p1b/costs.md

（仅读以上两个文件，未读其它任何文件）

<!-- 套不上 -->
- 冗余：无。逐对检查了同失败类候选（D01/D02、D04/D08、D05/D13、D05/D15、D03/D12），D01/D02 显式标注「同根」而非冗余；D04/D08 覆盖不对等（每单 vs 罕见一次性）且 D08 含反证词「量化约 44 处」「已证伪」，禁止判冗余；其余均属不同失败类。
- 弱推断说明（无显式文本互引，仅靠「删掉会怎样」失败类推断为互补，置信度较低，请复核）：D03↔D12（重量裁定 vs 约束准入，共字「流程重量」）、D10↔D11（角色分离 vs Execution Mandate，共字「越权」）、D05↔D13（门禁 vs AC可执行性，同属机械验证）。
- 任务二边界：D13「1次空跑」落在 机械近零/机械一次 边界（判 机械近零，若空跑实际执行 build/test 且 ≥10s 则为 机械一次）；D11「1次准入」执行主体（人裁定 vs 机械准入）在成本列未明说，按 formB「mandate 内零可避免运行时询问」推断为一次性人授权，判 人一次。

<!-- GRAPH -->
D01: 同根→D02
D02: 同根→D01
D04: 互补→D05
D05: 互补→D04
D04: 互补→D08
D08: 互补→D04
D04: 互补→D13
D13: 互补→D04
D04: 互补→D14
D14: 互补→D04
D04: 互补→D15
D15: 互补→D04
D05: 互补→D13
D13: 互补→D05
D10: 互补→D11
D11: 互补→D10
D03: 互补→D12
D12: 互补→D03
独立行：D06（失败类「依赖演进/安全公告无人监测，安全盲区」）／D07（失败类「教训流失不可见」）／D09（失败类「真机/真外部系统验证缺失，具体失败未知」）

<!-- COST-TIER -->
D01: 人多轮（lite: 人一次）
D02: 人一次
D03: 人一次
D04: agent一次
D05: 机械近零
D06: 机械近零
D07: agent一次
D08: agent一次
D09: 人一次
D10: 零
D11: 人一次
D12: 机械一次
D13: 机械近零
D14: 零
D15: 机械一次

REVIEWER-MODEL=deepseek/deepseek-v4-pro
SUBAGENT_TYPE=main-assistant（独立复核者，非 TAD 专用 subagent，未以 Alex/Blake 身份启动）
