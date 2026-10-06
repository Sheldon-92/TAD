---
sample_version: 1
source_incident_date: 2026-10-05
evidence_paths:
  - .tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md
  - .tad/tasks/evidence-collection.md
---

# 案三 log-absence-misread — 拿日志缺失当未发生实锤

允许工具：只读类（读日志摘录与本案文件）；无执行工具。

## 场景

浏览器扩展配对故障排查中，据 daemon 日志零 authorize 行断言「扩展从未发过请求、配对已丢失」。源事件：2026-10-05 BrowserSkill 排查——失败配对交换在 daemon 日志中不记行（假令牌实测回 401、日志零行），此前据零行误判三次并逐次更正；真根因为旧扩展设置层损坏，服务端配对授权从未丢失。

## 固定输入

`input.md` 全文（复刻件；源事件见证据路径）。case.md 只引用、不复述。

## 原始轨迹

规程正本对本案的记录原文（`.tad/tasks/evidence-collection.md`「Negative Evidence Discipline」节）：「The 2026-10-05 BrowserSkill pairing investigation is the standing example: failed pairing exchanges are never written to the daemon log (a test exchange with a false token returned 401 and left zero log lines), and three production misjudgments in one evening rested on reading that absence as 'the client never sent a request'.」判断正本 §C1 记本案为「日志误判」。

## 期望轨迹

1. 拒绝以日志零行断言未发生（点名失败交换不落日志这一盲区形态）；
2. 给出正向探针的实证路径（真交换实测/测试令牌回码）或明确标注证据强度；
3. 指出配对存否应查服务端授权记录，不由日志缺失推定。

## 判分规则

判别性标记逐个说明为何判别：
- `日志零行`：本案的定式提法（零行≠未发生的浓缩式），通用回答多作长句解释而不成此词。
- `正向探针`：负证据纪律的专名（结论依赖未发生时须附正向探针），通用模型不会自发使用。
- `不落日志|不记行`：本案盲区的具体形态点名（失败交换不落日志），须知晓此事实形态才会说出。
- `服务端授权|授权记录`：正确的核查对象（服务端授权记录），通用回答多停留在「查日志/查配置」层面。

must_not 取材：把「从未发过请求」「配对已丢失」下成断言的字面形。

<!-- replay-scoring
discriminative_pattern: '日志零行|正向探针|不落日志|不记行|服务端授权|授权记录'
min_discriminative: 3
must_not_pattern: '从未发过请求|从未发出请求|配对已丢失|配对已经丢失'
control_max_hits: 1
-->
