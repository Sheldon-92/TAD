# Journal — lite-standard-routing (2026-08-01)

- 行为验证 harness 的 sentinel 不变量必须检查 AFTER 而非 BEFORE（before==clean 只是前置条件，after==clean 才证明"副作用前停止"）；code-reviewer 用篡改实验证实 fail-open，修复后 11/11 PASS。
- `git ls-files <大目录> | grep -q .` 在 `set -o pipefail` 下存在 SIGPIPE 竞态：grep 匹配首行即退出，git 继续写大输出收到 SIGPIPE → 管道返回 141 → if 条件误判 false（gate3-git-tracked-check.sh 对 .tad 3751 文件稳定误报 FAIL）。规避：wc -l 计数替代 grep -q。
- §9.1 AC 的字面锚（如 "independent reviewer"）必须按英文原文落盘；中文概念等价（"独立 reviewer"）不算满足逐字命令——语言漂移会让字面 AC exit 1。
- 行为场景 transcript 的 ssot_hash 与实际契约 sha256 一致是"非 marker-only"的最强证据；fresh invocation 的 raw transcript + sentinel + hash 绑定可复现。
- 禁止修改 hooks 的本单约束下，hook 自身 bug（grep-q+pipefail）只能记录 friction + 用等效检查替代，不能顺手修 hook。
