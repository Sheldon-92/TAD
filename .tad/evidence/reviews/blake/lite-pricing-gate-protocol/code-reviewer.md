# Layer 2 Group 1 Code Review — HANDOFF-20260805-lite-pricing-gate-protocol

Model: harness=claude-code | model=deepseek-v4-flash | route=host
(机械捕获：`ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`、`ANTHROPIC_MODEL=deepseek-v4-flash`；
`~/.claude/settings.json` 的 `model=opus[1m]` 是 harness 侧偏好，运行时被 env 覆盖；BASE_URL 非 api.anthropic.com → route=host)

Reviewer: Group 1 code-reviewer | Date: 2026-08-05 | Base: 31a96aae3332adc87c565d06defff808cc8bef06（= HEAD，实现为工作树/暂存区状态，未提交）

---

## Verdict: CONDITIONAL

8 条 AC 全部执行验证通过（静默）、parity PASS、两 skill 节逐字节相同、位置正确、awk 命令可复制可运行。
无 P0。**1 个 P1**（执行实证）：前置扫描命令未锚定状态列且无处置感知，存在两类可复现的误报/僵旗缺陷——需以 handoff 修订方式路由给 P1b（在 P1b 开始填处置行之前），并在 Completion 中记录。另 3 个 P2。

---

## 审查维度结论

### 维度 1：spec 符合性 — PASS（1 处 P2 级偏差）

- 插入位置：alex-lite `## 约束准入` 在 L350，`## Forbidden` 在 L401；blake-lite L404 / L455。均位于 `## Forbidden` 之前。[执行实证]
- 两文件逐字节相同：`cmp` 通过（51 行对 51 行）。[执行实证]
- 与 §4.1 规格块（handoff L130–179）逐字对比：唯一差异是**节尾多一个空行**（规格块 50 行 vs 实际节 51 行，`diff` 输出 `50a51 > <空行>`）——即 `## Forbidden` 前的 markdown 分隔空行。14 个字面量全部逐字出现（AC1 独立验证 + 全节 diff 佐证）；awk 命令块与规格逐字一致。[执行实证]
- §4.2 台账：表头行、分隔行 `|---|---|---|---|---|---|---|---|` 逐字正确，无数据行（AC3 通过）。[执行实证]

### 维度 2：内容质量 — PASS（P1 见下）

- 六态取值封闭：6 态 + "不得自创"声明，自洽。[阅读推断]
- 复查默认删除 + 反合理化双侧钩子：准入侧/复查侧均成对出现。[阅读推断]
- 触发点诚实声明："没有后台自动机制"逐字存在；两个真实触发点（追加前扫描 + Epic 起草 handoff 前人工扫描）与 §2 决策 2 一致；"已知残余风险"段与决策 2 的 R3 对抗审查结论一致。[阅读推断]
- "闸付自己的通行费"与 P1b 回填关系：无矛盾——本节自身占行是 P1b 义务，当前空台账不违反（§1.3 明确"不填台账数据行（P1b）"）。[阅读推断]
- PROVISIONAL 到期后谁触发复查：有答案（追加前扫描 + Epic 触发点），残余风险已明记——设计自洽。[阅读推断]

### 维度 3：文档陷阱 — PASS（无自踩）

- awk 命令块可复制性：从节内逐字抽取 awk 块（含 2 空格缩进与行尾 `\` 续行）`bash` 直接运行成功（exit 0），对真实台账静默。[执行实证]
- awk 纯 ASCII：`grep -n '[^ -~]'` 无命中；`d < t` 只比较 ISO 日期纯 ASCII，规避了本机 `/usr/bin/awk` 中文比较缺陷（该缺陷存在性已实测确认：`awk 'BEGIN{a="身份"; b="精髓"; print (a==b)}'` → 1）。[执行实证]
- 错误目标自检：把扫描命令误指向 SKILL.md 本身 → 静默（六态模板行 `PROVISIONAL: review-by {YYYY-MM-DD}` 中 `{YYYY-MM-DD}` 不满足 `[0-9-]+`，不会假触发）。[执行实证]
- `AC principal` 反引号锚：节内仅 1 处（L8，规格强制的示例句）；节内 awk/grep 语法不含该子串；post-impl-check.sh 无对该锚的负向 grep。无自踩。[执行实证]

### 维度 4：parity 纪律 — PASS

- `bash .tad/hooks/lib/release-verify.sh parity .` → `VERDICT: parity PASS (exit 0)`；`.agents/skills/{alex,blake}-lite/SKILL.md` 与 `.claude/skills/` 逐字节一致（AC7 + 独立 cmp）。[执行实证]
- "仅经 parity --fix 生成"是过程性主张，从结果只能验证到"当前镜像与源字节一致"（过程本身标 UNVERIFIED-BY-EXECUTION: {生成过程不可从文件反推}），但结果状态满足纪律要求。

---

## Findings

### P0 — 无

### P1-1（执行实证）前置扫描命令未锚定状态列 + 无处置感知 → 两类可复现误报

插入节内的扫描命令（§4.1 规格强制逐字，故为 spec 级缺陷，非 Blake 实现缺陷）：

```
awk -v t="$(date +%F)" '/review-by/ { if (match($0, /review-by [0-9-]+/)) { d = substr($0, RSTART+10, 10); if (d < t) print "OVERDUE: " $0 } }' ...
```

两个已用最小探针复现的失败模式：

**子缺陷 A — 处置后永久僵旗（stale flag）**。台账是 append-only（"RETIRED 已删除该约束（追加行，不擦除原行）"），处置 = 追加新行，原 PROVISIONAL 行永不改动。探针：合成台账含超期 `PROVISIONAL: review-by 2026-01-01` 行 + 其后已追加 RETIRED 处置行 → 扫描仍输出 `OVERDUE: <原行>`，且此后每次扫描永远复现。协议自身的处置流程（"有超期行先处置再追加"）对"已处置但仍被标记"的行**没有定义任何收尾动作**——追加"已处置"说明行不改变原行，改原行状态格违反 append-only 字面。后果：扫描输出变成二义信号（"真未处置" vs "已处置但僵旗"），操作者被训练成无视扫描输出——正是该协议自己警告的"事后无法区分'扫过、确认无超期'与'根本没扫直接追加'"的失效路径。P1b 回填 34 节必然产生首批 PROVISIONAL 与处置，此缺陷在第一次处置后即触发。

**子缺陷 B — 首个命中假阳性（first-occurrence）**。`match($0, /review-by [0-9-]+/)` 取整行第一个 `review-by <日期>`，不锚定状态列。探针：`约束摘要` 格里恰好出现 "review-by 2026-01-01" 字样、状态为 `PROVISIONAL: review-by 2026-11-01`（未来）的行 → 被误报 OVERDUE。鉴于该节自己要求"挡什么失败模式"格附 grep 锚，摘要/备注格含 `review-by <日期>` 语料是可预期的。

修复方向（P1b handoff 修订，不适用于本单内改——awk 为规格逐字保护）：
1. 锚定状态列：`/\| PROVISIONAL: review-by [0-9-]+ \|/`（或等价尾列锚）——修复子缺陷 B；
2. 处置感知：放宽 append-only 为"**允许处置时原位改写原行的状态格**（行内容不擦除、其余列不动）"，审计意图（"不擦除历史行"）保留且扫描自然停止僵旗——修复子缺陷 A；或改用可做"每约束取最后一行状态"的工具替代纯 awk。
建议在 P1b 填充任何处置行前以修订单闭合，并在 Completion 记录。

### P2-1（执行实证）节尾多一个空行 vs §4.1 规格块

实际节 51 行 = 规格块 50 行 + 末尾 1 空行（`## Forbidden` 前的分隔空行）。两 skill 间逐字节一致（AC2 只互比、不比规格，是文档化的已接受残余 Gate2-R3 P2-3）。无害；建议要么在规格块末尾显式包含该空行，要么在 Completion 记一句"已知格式偏差"，避免后人误以为有内容差异。

### P2-2（阅读推断）`AC principal` 示例锚是"活的"字面量，未来负向 regex AC 必须避开

journal `lite-capability-complete-2026-07-31.md` 的教训："负向 AC 应选只出现在旧行为、绝不出现于合法新散文的字面量"。本节的示例句（规格强制逐字）包含 `` `AC principal` ``——任何未来对 lite skill 做 `! grep 'AC principal'` 的负向 AC 会被示例句自踩。当前无此 AC（已查 post-impl-check.sh，无对该锚的负向 grep），8 条 AC 全绿。属 spec 级设计取舍，需在手册/AC 设计纪律中记一笔，防未来复踩。

### P2-3（阅读推断）AC2 的 `## Forbidden` 取末行匹配，靠"当前每文件恰好 1 个"保证正确

post-impl-check.sh AC2 中 `b=$(grep -n '^## Forbidden' "$SK" | cut -d: -f1)` 取**最后一个**匹配行；当前两文件 `^## Forbidden` 计数均为 1（已验证），故正确。若未来某节新增第二个 `## Forbidden` 标题（如嵌套节），AC2 提取区间会静默吞入中间内容而仍 PASS。建议加 `| head -1` 并断言 `count == 1`（与本单 AC3 的 `^\|[^-]` 修正同一类防御）。

---

## UNVERIFIED-BY-EXECUTION 清单

- `parity --fix` 生成过程本身（"`.agents/` 仅经 parity --fix 生成"是过程主张；结果态 byte-identity + parity PASS 已执行验证）。原因：生成历史不可从当前文件状态反推。

---

## 执行证据

以下命令均在仓库根 `/path/to/TAD` 执行（探针只写 /tmp）。

**E1. 节定位与计数**
```
$ for f in alex-lite blake-lite; do SK=.claude/skills/$f/SKILL.md; a=$(grep -n '^## 约束准入' "$SK" | cut -d: -f1); b=$(grep -n '^## Forbidden' "$SK" | cut -d: -f1); echo "$f: 约束准入 line=$a | Forbidden lines=[$b] | count准入=$(grep -c '^## 约束准入' "$SK") | countForbidden=$(grep -c '^## Forbidden' "$SK")"; done
alex-lite: 约束准入 line=350 | Forbidden lines=[401] | count准入=1 | countForbidden=1
blake-lite: 约束准入 line=404 | Forbidden lines=[455] | count准入=1 | countForbidden=1
```

**E2. 逐字节对比（两 skill 互比 + 与 §4.1 规格块比）**
```
$ cmp /tmp/sec-alex-lite.txt /tmp/sec-blake-lite.txt && echo "RESULT: 两 skill 节逐字节相同"
RESULT: 两 skill 节逐字节相同
$ cmp /tmp/sec-alex-lite.txt /tmp/spec-41.txt && echo "RESULT: alex 节 == §4.1 规格块" || echo "RESULT: alex 节 != §4.1 规格块 (diff below)"
cmp: EOF on /tmp/spec-41.txt
RESULT: alex 节 != §4.1 规格块 (diff below)
$ diff /tmp/spec-41.txt /tmp/sec-alex-lite.txt
50a51
> 
（即唯一差异 = 节尾一个空行；wc -l：sec 各 51 行，spec 50 行）
```

**E3. 重跑 post-impl-check.sh（8 条 AC）**
```
$ bash .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/post-impl-check.sh
=== AC results ===
AC1: PASS (silent)
AC2: PASS (silent)
AC3: PASS (silent)
AC4: PASS (silent)
AC5: PASS (silent)
AC5b: PASS (silent)
AC6: PASS (silent)
AC7: PASS (silent)
```

**E4. parity 判定**
```
$ bash .tad/hooks/lib/release-verify.sh parity .
=========================================
PARITY VERIFY (.claude/skills <-> .agents/skills byte-identity)
  REPO: /path/to/TAD
=========================================
  ✅ .claude/skills <-> .agents/skills byte-identical
VERDICT: parity PASS (exit 0)
```

**E5. 探针 1 — 节内 awk 块逐字抽取后原样运行（可复制性）**
```
$ sed -n '22,25p' /tmp/sec-alex-lite.txt > /tmp/awk-verbatim.sh   # 含 2 空格缩进与行尾 \ 续行
$ bash /tmp/awk-verbatim.sh ; echo "exit=$?"
exit=0 (无输出 = 预期)
```

**E6. 探针 2a — 合成台账：超期/未来 PROVISIONAL + 已处置行（P1-1 子缺陷 A）**
```
$ awk -v t="$(date +%F)" '/review-by/ { if (match($0, /review-by [0-9-]+/)) { d = substr($0, RSTART+10, 10); if (d < t) print "OVERDUE: " $0 } }' /tmp/ledger-probe.md
OVERDUE: | 2026-08-05 | blake-lite | §Y | 载体待补的约束 | 2读1写 | 无载体硬加 | 无 | PROVISIONAL: review-by 2026-01-01 |
（超期行正确标记；未来行未标记；中文行不破坏 awk；同一约束的 RETIRED 处置行存在时原行仍被永久标记 → 僵旗）
```

**E7. 探针 2b — 错误目标（对 SKILL.md 跑扫描）应静默**
```
$ awk ... .claude/skills/alex-lite/SKILL.md ; echo "exit=$?"
exit=0 （六态模板行 review-by {YYYY-MM-DD} 不满足 [0-9-]+ → 无假触发）
```

**E8. 探针 2c — 本机 awk 中文比较缺陷声称**
```
$ awk 'BEGIN{a="身份"; b="精髓"; print (a==b)}'
1
（§6 风险 1 的声称属实；节内 awk 只比较 ASCII 日期，规避成立）
```

**E9. 探针 2d — 首个命中假阳性（P1-1 子缺陷 B）**
```
$ awk ... /tmp/ledger-fp.md   # 摘要列含 "review-by 2026-01-01"、状态为未来 2026-11-01
OVERDUE: | 2026-08-05 | alex-lite | §W | 摘要里恰好写了 review-by 2026-01-01 这种字样 | 1读 | 某失败 | journal/x.md | PROVISIONAL: review-by 2026-11-01 |
（未来到期行被误报 OVERDUE → 未锚定状态列）
```

**E10. 辅助验证**
```
$ grep -n 'AC principal' /tmp/sec-alex-lite.txt
8:   结尾附一个反引号包裹的逐字 grep 锚（例：…AC principal 缺陷穿透自审 `AC principal`）
$ grep -n 'AC principal' .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/post-impl-check.sh ; echo "exit=$? (1=无，预期)"
exit=1
$ grep -n '[^ -~]' /tmp/awk-verbatim.sh ; echo "grep exit=$? (1=纯ASCII)"
grep exit=1
$ git diff --numstat 31a96aae3332adc87c565d06defff808cc8bef06 -- .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md
51	0	.claude/skills/alex-lite/SKILL.md
51	0	.claude/skills/blake-lite/SKILL.md
$ git log --oneline -1
31a96aa feat(TAD): add Evidence replayable advisory check to Gate 3 checklist [Gate 3 pending]
（HEAD == BASE，实现为暂存区/工作树状态，符合 Gate 3 进行中）
```
