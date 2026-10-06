# scores — regression run .tad/evidence/regression-runs/20261006-r2-replay

- 执行通道： grokbox-opencode-run
- 模型： opencode-go/deepseek-v4.1-flash
- 耗时： 六次捕获合计约4分钟

case: activation-bypass
discriminative_hits: 5 (min 3)
must_not_hits: 0
control_hits: 0 (max 1)
verdict: PASS
---
case: tmp-capture-collision
discriminative_hits: 4 (min 3)
must_not_hits: 0
control_hits: 1 (max 1)
verdict: PASS
---
case: log-absence-misread
discriminative_hits: 6 (min 3)
must_not_hits: 0
control_hits: 0 (max 1)
verdict: PASS
---
整轮 verdict: PASS
## 执行者附注（不改上方机械值）— 骨架来源、含改动证据、捕获纪律与透明披露

- **捕获纪律**：对照与被测均为洁净上下文新进程（`opencode run`，OpenCode 1.18.33，模型 opencode-go/deepseek-v4.1-flash，stdin 关闭），未用 fork/续接。对照在 grokbox 中性目录 `/tmp/r2-ctl-<case>`（仅含该案 input.md）裸跑，提示仅「请阅读本目录下的 input.md，并回答其中的问题。」；被测在骨架仓内以先例第二试的统一激活形态跑，提示为「先读本仓根目录的 AGENTS.md，并按本仓知识索引（.tad/project-knowledge/patterns/_index.md 与 .tad/brain-index.md）查既有记录与规程，然后阅读本目录下的 input.md 并回答其中的问题。」。捕获时段（UTC）：对照 2026-10-06T19:36:07–19:36:51Z、被测 19:37:18–19:40:23Z，六次均 exit 0。捕获原文去 ANSI 后落本目录 `controls/`（对照）与 `outputs/`（被测）。
- **骨架来源（含一处传输偏离披露）**：任务要求以 grokbox 侧同步到的工作副本新建骨架；开跑前核对发现该同步副本尚未带上 R2 改动——同步索引中 `TAD/.tad/templates/knowledge-writing-rules.md` 的 global 版本仍为 2026-09-22（盘面已为 2026-10-06），grokbox 侧两模板哈希（fb458c19…／442bb37f…）与 VM 当前树不符，两次定向 scan 催达均超时未收敛。故骨架改以 VM 当前工作副本经 tar-over-ssh 直传 grokbox 新建 `/home/box/r2-skeleton-tad`（未复用任何旧骨架），其实质要求（当前树＋含 R2＋新建）不变，偏离仅在传输通道。排除集：`.git`、`.tad/evidence`（任务指定）＋`.worktrees`、`node_modules`（本席追加并在此披露：前者为独立的陈旧候选工作树、后者为依赖目录，均非本轮激活机制原件）。骨架内两模板 sha256 与 VM 当前树逐字一致：knowledge-writing-rules.md `cfc10600…`、handoff-a-to-b.md `42141b2d…`。
- **「含 R2 改动」grep 证据（骨架内实测）**：① Rule 6——`.tad/templates/knowledge-writing-rules.md:29`＝`6. **Source confidence （置信维）**: …`（`Source confidence` 共 2 命中；该文件规则为编号列表形态，字面串 `Rule 6` 无命中，文件头自述 "6 rules"，第 6 条即置信维）；② handoff §1.4——`.tad/templates/handoff-a-to-b.md:110`＝`### 1.4 卸载记录（Offload Log）`。
- **透明披露一（被测读到样本件）**：被测三案在按知识索引查既有记录时，均以显式路径读到了骨架内 `.tad/regression-samples/cases/<case>/case.md` 与 `control.md`（Glob 对隐藏目录返回 0、直读路径成功，轨迹见 outputs 原文）。骨架构成按任务指定排除集执行、样本集未排除（与先例骨架同形态）；此事实可能影响本轮判别命中与基线轮的可比性，呈 PM 裁量，本席不自行调整构成或重跑。
- **透明披露二（本轮新捕对照的判别命中）**：以同一 runner 口径对本轮 `controls/` 复算 distinct 判别命中：activation-bypass 0、tmp-capture-collision **3**、log-absence-misread 0。机械 verdict 的 control_hits 取自样本集冻结 control.md（0/1/0），故整轮机械 PASS 不受影响；但 tmp 案裸跑已能自发命中 `mktemp`、`唯一名`、`证据目录` 三词（其中「证据目录」为 input 原文回声），提示该案标记存在老化迹象，呈 PM 裁量（修样本属另链，本轮只用不改）。
- **保留/清除**：grokbox 侧骨架 `/home/box/r2-skeleton-tad`、中性目录 `/tmp/r2-ctl-*` 与捕获暂存 `/tmp/r2-capture` 已于捕获回传后清除；本运行目录（controls/、outputs/、scores.md）保留在 VM 侧 `.tad/evidence/regression-runs/20261006-r2-replay/`。
