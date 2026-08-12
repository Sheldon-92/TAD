# dependency-ops-skill 执行 journal（2026-08-12）

## 概要
LITE-20260811-2254：建 dependency-ops capability skill（双平台镜像）+ 真实 gh 2.96.0→2.97.0 dogfood。

## AC 执行记录

| AC | 结果 | 证据 |
|---|---|---|
| AC1 源覆盖 | PASS | source-coverage.md（表 A 19 / 表 B 9 / init NOT-MIGRATED） |
| AC2 frontmatter | PASS | AC2.txt |
| AC3 parity | PASS | AC3.txt（逐字节） |
| AC4 无悬空 | PASS | AC4.txt（引用 0 / 禁用词 0 / changelog 正向 2 / yq -i 0） |
| AC5 check 可执行 | PASS | AC5.txt（exit 0，last_scan==TODAY=2026-08-12） |
| AC6 覆盖面 | PASS | AC6.txt（success 3：gh/yq/jq；skipped 3：notebooklm-cli/rsync/claude-code-cli） |
| AC7 变更检出 | PASS | AC7.txt（gh 2.97.0/true；yq/jq false） |
| AC8 逾期 | PASS | AC8.txt（L1=22 / L2=15，公式逐位相等，非快照 21/14） |
| AC9 relevance | PASS | AC9.txt（HIGH，逐字引用 capabilities_used；无 breaking） |
| AC10 升级 | PASS | AC10.txt（gh 2.97.0） |
| AC18 keg | PASS | AC18.txt（2.96.0 + 2.97.0 并存） |
| AC19 附带 | PASS | AC19.txt（diff 2 行，仅 gh，零附带） |
| AC11 update 记录 | PASS | AC11.txt（三字段 + 6 行变化全在 gh 区间） |
| AC12 YAML | PASS | AC12.txt（yq 0，length 6） |
| AC13 不可达声明 | PASS | AC13.txt（known_limitations=[] 显式声明） |
| AC14 围栏 | PASS | AC14.txt（新增恰为 REGISTRY+scan-results） |
| AC15 双控 | PASS | AC15.txt（负控 A fresh 报出；负控 B audit 报出 + shasum 复原） |
| AC16 缺口 | PASS | AC16.txt（5 条全声明） |
| AC17 承重 | PASS | AC17.txt（Q1-Q6 全答；Q3 首轮 FAIL → 修复 → 转正） |

## 意外发现 / 教训

- **Bash 工具 PATH 在 while 循环/管道内丢失**（zsh 5.9 非交互 + opencode 注入）：
  循环内调用外部命令需用绝对路径或 /bin/sh 包裹。这不是脚本问题，是工具环境问题；
  verify.sh 不受影响（bash 运行）。
- **fence-audit 基线格式**：install-smoke 版两列基线（状态 路径）导致 dirty tracked
  摘要比对永落 NEW-PATH 排除分支（audit 半边空洞）。本单改三列（状态 SHA 路径），
  负控 B 实证报出 VIOLATION-DIGEST。
- **AC17 反小抄的 Q3 盲点**：口径定义（公式/tier）放"定位与口径"说明性节会被判
  「说明性文字」→ FAIL。内联到操作步骤才达标。这验证了契约判分基准的判别力。
- **scan-results.yaml 用 results[] 非 dependencies[]**（L2.25 表未记，执行期发现）。
- **gh 2.97.0 changelog 含 4 个安全公告**（terminal escape injection 等）——升级理由
  从"例行维护"升级为"安全修复"，AC9 HIGH 判定的实证基础。

## 残留（已进 findings.md §4）
release 回归未测 / limitation 分支未验 / 下游未验证 / F1 不属本单。
