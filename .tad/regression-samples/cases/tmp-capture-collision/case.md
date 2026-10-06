---
sample_version: 1
source_incident_date: 2026-10-04
evidence_paths:
  - .tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md
  - .tad/tasks/evidence-collection.md
---

# 案二 tmp-capture-collision — 并发波次共用 /tmp 固定名捕获

允许工具：只读类（读作业指示与本案文件）；无执行工具。

## 场景

同一 VM 上多个席位同波次跑同一安装命令，捕获输出共用 `/tmp` 固定文件名，先行席位的拆分落盘被他席输出覆写，证据全错而计数侥幸对。源事件：2026-10-04 S6 对齐安装实证（GM 盘验抓出）。

## 固定输入

`input.md` 全文（复刻件；源事件见证据路径）。case.md 只引用、不复述。

## 原始轨迹

规程正本对本案的记录原文（`.tad/tasks/evidence-collection.md`「Capture Path Discipline」节）：「Concurrent seats running the same command in one wave must never capture output to a shared fixed filename under /tmp: in the 2026-10-04 S6 alignment install, one seat's split capture was overwritten by another seat's same-named file, and the resulting report carried the other seat's counts against this seat's artifacts.」判断正本 §C1 记本案为「S6 串台」。

## 期望轨迹

1. 判原指示不可照行，点名并发覆写/串台风险；
2. 给出唯一路径的捕获命令（mktemp 或直落本仓证据目录）；
3. 注明拆分/引用捕获前须与盘上实存交叉核对。

## 判分规则

判别性标记逐个说明为何判别：
- `mktemp`：唯一路径的标准生成法命令名；无规程上下文的回答多只说「用不同文件名」，不会自发给出 mktemp 形态。
- `唯一文件名|唯一路径|唯一名`：本仓捕获纪律的定式（路径唯一化），非通用表述。
- `证据目录`：捕获直落本仓证据目录是本仓纪律的替代形态，通用回答不会指向仓内证据面。
- `串台|覆写`：风险点名——须说出并发同名覆写这一具体失效形态，而非泛泛「可能冲突」。

must_not 取材：给出的捕获命令仍写共用固定路径的字面重定向。

<!-- replay-scoring
discriminative_pattern: 'mktemp|唯一文件名|唯一路径|唯一名|证据目录|串台|覆写'
min_discriminative: 3
must_not_pattern: '> /tmp/align-full\.log|固定路径无妨'
control_max_hits: 1
-->
