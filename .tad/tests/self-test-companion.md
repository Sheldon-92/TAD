# TAD Self-Test — 伴生文档（基线治理＋消费面）

本文件是 `.tad/tests/self-test-protocol.md`（驱动协议）的伴生文档：协议管探针的产生、落盘与处置，本文件管两件协议之外的事——component-health 基线的治理，以及自测信号的消费面。套件构成与 verdict 作用域以协议原文为准，本文件不复述、不改写协议任何条文。

上游出处：本套件 2026-10-31 建成于 Sober Creator 仓（TASK-20261031-002／TASK-20261031-005），2026-11-06 由 TASK-20261106-004（HANDOFF-20261106-sp2-row4-self-test-agent）上游入框架源仓。

## 基线治理

对象：`.tad/project-knowledge/component-health-baseline.txt`（project-owned，安装器永不触碰）。它是检查器 `.tad/hooks/lib/component-health-check.sh` 的主 oracle：每行一件受治文件，`sha256 + 相对路径` 两字段，文件头注释注明其为生成时刻的盘面快照。

### 生成程序

受治集由检查器的比对面推导，不靠手列：

- C2 面：`.tad/hooks/` 下全部 `*.sh`（含 `lib/`，递归）；
- C5 面：`.tad/templates/` 下全部文件（递归）；
- C3/C4 面：`.tad/config.yaml`、`.tad/config-*.yaml`、`.tad/version.txt`、`.tad/TAD-VERSION`。

生成命令（仓根运行；生成与校验共用同一哈希工具选择链 `sha256sum → shasum -a 256`，两工具皆无时停手回报）：

```
HASHCMD=sha256sum; command -v sha256sum >/dev/null 2>&1 || HASHCMD='shasum -a 256'
{ find .tad/hooks -type f -name '*.sh'; find .tad/templates -type f; ls .tad/config.yaml .tad/config-*.yaml .tad/version.txt .tad/TAD-VERSION; } | LC_ALL=C sort | while IFS= read -r f; do $HASHCMD "$f"; done
```

重生成时保留基线文件头注释，只替换哈希行。生成后立即跑一次检查器全量形自证：受治集面（上述集合内的 MISSING／EMPTY／SYNTAX／MODIFIED／UNLISTED）必须零问题；集合外的问题行（如接线引用的脚本缺失、活 settings 文件缺位）与基线无关，不因生成而消失——它们若存在，须逐件显名并按各自去向处置，不许用「自证通过」的话术盖住。

### 重生触发

基线只在受治件发生**可解释的变更**时、且在**同一变更内**重生：框架升级落地、hook／模板／config 受治件增删改，均属此类。无变更不重生；升级收口若发现基线漂移未随升级处理，漂移以检查器的问题行形态留给首跑点名（见消费面），不事后无声补生。

### delta 解释义务

每次重生必须在该变更的完成证据中附 delta 清单：新增／删除／改哈希逐件列名，并逐件给出变更来源（哪个 handoff／哪次升级／哪条工单）。解释不了的条目不许进新基线。

### 禁止消音重生

**禁止为了让检查器闭嘴而重生基线**：任何 MODIFIED 行在被新基线吸收之前，必须先有逐件解释（合法变更的来源，或损坏的确认与修复）。基线是证据快照，不是第二真相源；它与盘面冲突时，检查器只报行、永不自动吸收——重生是经审动作，不是刷新动作。

## 消费面

### SessionStart 信号读法

每次会话启动，startup-health 会把检查器的 `--line` 结论并入 SessionStart 文本（检查器缺位或不可执行时不输出该行，既有行为不变——fail-soft 接线）：

- `Components: OK (v<版本>)`：受治集与基线逐件一致、版本三点一致、接线引用齐全。无事。
- `Components: <k> PROBLEMS: <至多 3 个名字>[, +<n> more]`：有 k 条问题行。名字只是索引——处置前先在仓根跑全量形 `bash .tad/hooks/lib/component-health-check.sh` 看问题行全文，按行点名逐件处置：MISSING／MODIFIED／UNLISTED 回基线治理节判读（合法变更未重生，还是真损坏），UNVERIFIABLE 表示检查源缺失（如活 settings 文件或基线本身不在），先补源再谈其余。PROBLEMS 不是故障宣告，是点名清单；不许看到 PROBLEMS 就重生基线消音（见治理节）。

runner 的 S5 面消费同一 `--line` 结论：结论为 OK 形才 ok，其余形态连同结论原文记入 FAIL 行。

### run 报告落点

完整 run 的报告落 `.tad/evidence/self-test/SELF-TEST-<日期>-v<版本>.md`，四探针 capture 落 `.tad/evidence/self-test/runs/<日期>-v<版本>/capture-<id>.md`（try2 时另有 `capture-<id>-try2.md`，报告显名 NOTE）。verdict 行的作用域语义（裸 PASS 只许出现在含探针断言的完整 run）以协议原文为准。

### 首跑义务（建议口径）

建议：框架升级、整替落地或 hook／skill／config 接线改动收口前，在当仓跑一次完整 run 并把报告路径附进该次变更的收口证据；无报告不算收口。此条在本文件里只是**建议口径**——把它变成发版／升级流程的强制门禁属发版线职责，随 ST1 分诊在组篮时定落点，不在本文件的权限内。
