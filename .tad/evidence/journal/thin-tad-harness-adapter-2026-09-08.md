# Journal — thin-tad-harness-adapter (Blake Gate 3, 2026-09-08)

## Q1: 值得追溯的发现、踩坑、关键决策
1. **Live-path vs mock-path 分裂是 Layer 1  green 下最危险的缺口。** 首轮 37/37 全绿，但两名独立 reviewer 各自用运行时证据打出 FAIL/CONDITIONAL：`executeArm` 从未传 `--prompt-file`（P2 遗留：`buildOcArgv` 的 `extraPrompt` 可选，而唯一 live 调用方从不传）；`classifyOutcome` 无 `FAILED_HARNESS_USAGE` 映射（exit 2 被当 infra 重试）。教训：凡"适配器强制要求 X"，必须有一个从 live 入口直达的集成测试，而非仅手拼 argv 的单元测试。本单新增的 `executeArm wires prompt-file through real adapter to COMPLETED`（真 adapter + mock raw + 默认 spawnOc）即为此类"端到端但零费用"的测试形态，可复用。
2. **`execFileSync` 成功路径丢弃 stderr。** 测试 helper 用 `execFileSync` 捕获输出，exit-0 时 stderr 不在返回值中，导致 NOTE 断言假失败。改用 `spawnSync` 取 `status/stdout/stderr` 三元组。任何需断言 stderr 的适配器测试必须用 `spawnSync`。
3. **AC7 法币词是"会自我触发"的检查。** 审计文档若复述 handoff 的"严禁 USD 换算"原话，自身即含禁用词而失败。写法：用"法币折算"中文表述，并引用"见 handoff AC7 验证命令原文"而不拼写 tokens。另注意 `percent` 必须连写（`per cent` 分写会命中 `\bcent\b`）。
4. **Snapshot-diff 围栏对 untracked-in-place 修改盲视。** `runner.mjs` 系 P2 遗留 untracked 文件，原地修改不产生 status 增量；`comm -13` 只能捕获新增路径。配套手段：记录表内文件 sha256 + `git status` 全量 diff。本单 AC8 证据即采用"1 行 status 增量 + 5 个 sha"双轨。
5. **探针"诚实失败"与"纸面门"的边界。** 默认读取器把 Tier-2 正控委托给 run-pair（零模型花费），live 探针永为 fail-closed。这是正确的诚实设计，但 handoff PREREQ-2 原文仍把 `probe_passed: true` 写成可执行门。Blake 无权改 handoff，只能在审计文档中如实标注 OPEN 状态交 Alex Gate 4 裁决——"标注 OPEN"本身就是交付物的一部分。

## Q2: 可复用的工作模式
Yes — "零费用端到端"测试形态：真被测通道（本例为真 adapter 二进制）+ 末端 mock（本例为 mock raw bin 输出遥测 JSON）+ 默认生产执行器（本例为未注入 executor 的 `executeArm`）。既覆盖了手拼 argv 覆盖不到的接线错误，又不消耗真实调用预算。适用于任何"昂贵末端 + 诚实中间层"结构。

## Q3: workflow 模式
No — 未做多 agent 编排；Layer 2 为两轮串行双专家（eval + code），第二轮为聚焦复验。现有 workflow 无缺陷发现。
