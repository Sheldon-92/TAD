# S2 完工说明 —— 三案比较＋Decision Brief（TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL）

- step_id：`tad-evidence-revival-s2-01`；执行者会话标识：session 208ee03a-98d3-4065-b1fc-5ca7ab3b40c8（与 S1 的 449e8e64-b7e3-44e1-8097-9dc03d8b9cb6 不同会话）
- 完工时点：2026-10-04（本步全部查证与落盘均于 2026-10-04 完成）

## 产物（字节数与章节清单）

1. **`.tad/evidence/research/maintainer-evidence-revival/decision-brief.md` — 18,774 B**
   章节：标题与头（决策问题／服务决策／研究日期／链与 step／研究级别／执行者会话标识 C-T4 行／结论段 verdict-first／问题树对答与四锚基线）→ `## 选项` → `## 案一 恢复分支同步`（机制描述／一次性成本／常态运维负担／风险与失效模式／与 F-18 发行瘦身意图的相容性／盘上证据）→ `## 案二 主仓例外清单常态化`（同六小节）→ `## 案三 分级混合载体`（同六小节）→ `## 迁移输入形态（Q4）` → `## 推荐`（推荐案一＋5 条依据＋置信度「中高」及重议条件）→ `## 未知风险（未知项清单）`（6 项）→ `## Claim 验证`（8 行）→ `## SOURCES`（8 行）。
2. **`.tad/evidence/knowledge-usage-log.jsonl` — append 1 行**（step=S2；文件由 2 行/1,129 B 变为 3 行/2,116 B，仅尾加，未改既有行）。
3. 本完工说明。

结论要点：推荐**案一**（恢复分支同步＋同步脚本化＋四锚新鲜度看守）。置信度：中高。

## ③ 读取清单逐项打勾回执

- [x] 1. HANDOFF §3.1（FR4–FR6）、§3.3、§4.3、§4.4、§4.5、§6 S2、§9.1 AC6——已读；另读 §2（背景/基线）与 §5 MQ1（F-18 指针）备查。
- [x] 2. S1 summary 全文——已读；本 Brief 现状数字只引其四锚（8706/5/4355/16）、分类计数表、日期桶、按类字节小计。
- [x] 3. PM 的 S1 验盘记录 `.tad/evidence/pm/2026-10-04-evidence-revival-s1-pm-verify.md`——已读（四锚经 PM 独立重算、C-T1 关闭、C-T3 首算成立在册）。
- [x] 4. 模板原件 `.tad/templates/research-decision-brief.md`——已读，Brief 结构认模板（选项/证据/推荐/未知风险/Claim 验证＋FR5 要求的 `## SOURCES` 节内表）。
- [x] 5. F-18 原文——按 HANDOFF §2/MQ1 指针查得：`.tad/active/designs/AUDIT-20260816-framework-health.md`「发行重量」节 F-18 原文＋`.tad/active/epics/framework-health-repair/EPIC.md` Phase 4 Scope 与 SC3 判据原文，三案相容性均对原文判（案一 完全相容；案二/案三 部分相容且须显式修订 SC3）。
- [x] 6. `.tad/project-knowledge/principles.md` 与 `patterns/_index.md`——已读；命中 patterns 读 2 条（≤3）：`release-sync.md`、`ac-verification.md`（分别用于载体/同步面判断与 AC6 计数自查口径）。
- 附：仓内 `AGENTS.md` 已读（本步所在目录规程）；`.gitignore:120-123` 原文已查。

本步盘上实查（git 只读，结果已写入 Brief 正文/SOURCES）：`git log -1 maintainer-evidence`＝8713ea4e（2026-09-06）；`git ls-files` 两树＝3 件；`git rev-parse maintainer-evidence origin/maintainer-evidence` 同尖；grep `.tad/hooks/`、`.tad/scripts/`、`tad.sh` 的 maintainer-evidence 引用零命中（无现存同步脚本）。

## AC6 自查逐项结果

AC6 验证命令口径（HANDOFF §9.1）：`grep -cE '案一|案二|案三' brief`、`grep -c '^## SOURCES' brief`、`grep -c '推荐' brief`，期望依次 ≥3、＝1、≥1。

- 案一|案二|案三 计数＝**21**（≥3 ✅）
- `^## SOURCES` 计数＝**1**（＝1 ✅）
- 推荐 计数＝**6**（≥1 ✅）
- **AC6 自查结论：PASS。**

配套自查：FR4 五维度三案逐项在位（`### 机制描述`/`### 一次性成本`/`### 常态运维负担`/`### 风险与失效模式`/`### 与 F-18 发行瘦身意图的相容性` 各计数＝3）；FR5 SOURCES 表 8 行，数字类断言逐条回指 S1 summary 或本步实查，票面估计未入结论与 SOURCES（仅在「已被实测取代」语境提及、无数字）；FR6 推荐＋依据 5 条＋置信度＋未知项 6 项齐；结论第一段 ≤3 句给出推荐；C-T4 会话标识行在 Brief 头部在盘。

## usage 行写入与解析自验

- append 前确认：文件 2 行（genesis＋S1）、尾字节为换行；仅以 `>>` 尾加一行 step=S2，既有行未动。
- append 后自验：`json.loads` 逐行解析 3 行全过；计数 genesis=1、chain=TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL 共 3 行、含 handoff 路径 2 行（AC8 全链阈值 ≥1/≥3/≥2 于本步时点达成）；steps 序列＝[genesis, S1, S2]。

## 写面守恒

本步仅写激活包 §⑤ 三处：decision-brief.md（新建）、knowledge-usage-log.jsonl（append 一行）、本完工说明（新建）。未改 HANDOFF、未改 S1 产物、git 全程只读（log/ls-tree/ls-files/rev-parse/grep），未做任何载体恢复动作。

## 未决/存疑事项

- Brief 已如实列 6 项未知（最大缺口：关键证据直读频率无数据，usage log 本链才激活）——属 FR6 要求明写的证据不足，非本步未尽事项。
- 无现存同步脚本的结论查证范围限 `.tad/hooks/`、`.tad/scripts/`、`tad.sh` 三处（Claim 表已注范围）；仓外或他仓脚本不在本链 scope。
- origin 分支他端状态未做实时 `ls-remote`（只认本地远端跟踪引用），已列入 Brief 未知项 2。
