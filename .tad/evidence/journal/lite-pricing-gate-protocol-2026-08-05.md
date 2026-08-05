# Journal: lite-pricing-gate-protocol (2026-08-05)

- **快照基线 vs 框架产物的时序冲突**：§5.0 untracked 快照在 1_init 创建 ralph state 文件**之前**执行 → AC6 把框架产物（`.tad/evidence/ralph-loops/*_state.yaml`）视为"新增"且不在授权集 → 结构性误报。处置：实现开始前重拍 untracked 基线（差分设计本意），而非改授权集。教训：任何"快照-差分"类 AC，凡实现开始前还会被框架步骤创建文件的，都要在**所有框架产物落盘之后**再拍基线。

- **双向围栏的互补分工**：负向探针（touch 禁区文件）只被 AC6（untracked 围栏）抓到，AC5（tracked 围栏，`git diff --name-only`）天然看不见 untracked 文件——这是设计互补不是盲区。测 untracked 围栏用 touch 新建；测 tracked 围栏需先 git add 一个禁区文件。

- **规格受保护时发现规格缺陷的正确路径**：实现与 §4.1 逐字一致（AC1-AC7 全绿 + byte diff 仅空行）但 code-reviewer 执行实证报 2 条 P1（awk 扫描无处置感知 → 僵旗永久 OVERDUE；摘要格 "review-by <日期>" 字样 → 假阳性）。根因在契约文本 → Blake 无权改规格 → 走"人裁定条件放行 + P1b 修订单闭合"而非自行修。条件放行的依据：台账当前零数据行，两条 P1 在 P1b 回填前不可触发。

- **判别力自检的强度实证**：spec-compliance reviewer 将插入节与 §4.1 规格块 byte diff——仅一处差异（节末空行，非受保护字面量）。这比 14 个字面量 grep 更强，值得在后续单的 AC 设计里推广（规格块 byte diff 作为 AC 判别力上限）。

- **untracked 围栏对实现后框架产物的结构性敏感（AC6 盲区第三实例）**：untracked-before 快照在实现开始前拍摄，但 full 通道**实现后必然产生**框架文件：COMPLETION（step5 强制 + step3c 明示排除于 commit）与 decisions jsonl（askuser-capture.sh hook 在每次 AskUserQuestion 时自动追加）——两者都不在任何契约授权集内，Gate 3 阶段重跑 AC6 必然输出它们。处置：逐条归因判定实质 PASS，不重拍基线（实现后改快照 = 掩盖时序，且 decisions 会随 gate3_verdict Edit 再变，重拍无法稳定）。设计启示：untracked 围栏类 AC 的判定时点应固定在"实现产物齐备、流程文书未生"的窗口（§5 验证时），Gate 3 重跑仅作 smoke；或授权集显式吸收已知流程产物路径（.tad/active/handoffs/、.tad/evidence/decisions/）。
