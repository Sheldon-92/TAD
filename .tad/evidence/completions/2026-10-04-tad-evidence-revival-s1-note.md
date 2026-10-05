# COMPLETION（执行者自报，self）— S1 影响面机械盘点

- step_id：tad-evidence-revival-s1-01；task：TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL
- 执行者会话标识（C-T4 本步部分）：session 449e8e64-b7e3-44e1-8097-9dc03d8b9cb6（原生 subagent，执行会话 A）
- 执行时段：2026-10-04T22:15Z–22:2xZ；as_of（枚举时点）：2026-10-04T22:16Z
- 判定口径声明：本说明为执行者 self 自报；AC 结论以 PM／Gate 侧独立复跑为准。

## 停机条件核查结果（开工第一动作，先于 genesis）

- `.tad/evidence/knowledge-usage-log.jsonl` 开工前实测：**0 字节、0 行**，无 genesis 行、无任何既有行。停机条件未触发，按 §4.5 写入 genesis（全文件第一行，ts 2026-10-04T22:15:55Z，字段与 note 文案逐字按 §4.5）。
- S0 前置复核：Gate 2 双 verdict 已落盘且 PM 合并裁定已回填 HANDOFF；开链记录 `.tad/evidence/phase3-first-chain.md` 在盘；分支尖 maintainer-evidence＝8713ea4e（AC2 基线成立）。

## 产物清单（字节数＋章节）

1. `.tad/evidence/research/maintainer-evidence-revival/inventory-manifest.jsonl` — 2,747,317 B，13,082 行（逐件一行，字段 path/tree/class/bytes/date_bucket；无重复路径）。
2. `.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md` — 14,450 B。章节：四锚锚行／方法与口径／基线对照与差额分解／估计 vs 实测对照／分类计数表（evidence 树＋archive 树）／日期桶分布／stale-content 清单／sha 样本行／CJK 路径抽验／本链自产小计／复跑命令序列／作废轮次声明／给 S2 的接口注记。
3. `.tad/evidence/knowledge-usage-log.jsonl` — append 2 行（genesis＋S1 usage），现 1,129 B、2 行，全行 JSON 可解析（修复事件见「异常与说明」）。

## 四锚实测值

- TOTAL_NOCARRIER=8706
- TOTAL_STALE=5
- TOTAL_CARRIED=4355
- TOTAL_BRANCH_ONLY=16
- 自洽：8706＋5＋4355＝13,066＝盘上集 A；交集 4,360；B 全树 6,596 条目（blob 6,595＋gitlink 1），两树前缀内 4,377（blob 4,376＋gitlink 1，前缀外 2,219 备查）；gitlink 1 件（`.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work`）单独注记、不入四类。
- 与设计时点安全口径锚值对照：盘上独有 8,696（设计时点）→ 8,706（as_of，＋10 由快照后新增件解释，见 summary 差额分解）；分支独有全树口径 2,236（默认管线）→ 安全口径分解为前缀外 2,219＋branch-only 16＋gitlink 1（另 CJK 伪差 12 在默认管线读数 2,248 中，见 summary）；交集与 B 侧计数与 Gate 2 tech 评审独立复算全等。

## C-T1 执行情况（管线命令原文）

- 盘上集：`find .tad/evidence .tad/archive -type f -print0`（仓根执行，NUL 分隔）。
- 分支集：`git ls-tree -r -z maintainer-evidence`（NUL 分隔；只取 type＝blob 条目参与比对，gitlink 单独注记）。
- sha 比对：交集逐件 `git hash-object -- <path>`，argv 形式分块 400 件/批（与 §4.2 许可的 `--stdin-paths` 批量形态等价，对任意文件名字节安全）。
- 未使用 git 默认引用输出做任何差集。UTF-8 解码失败 0 件、含换行路径 0 件。
- CJK 抽验：12 条非 ASCII 路径全在交集、全归 carried，逐件如下（均在 `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/` 下）：Colin声音项目__archive.txt.gz、Colin声音项目__evidence.txt.gz、下载md插件__archive.txt.gz、下载md插件__evidence.txt.gz、买卖__archive.txt.gz、买卖__evidence.txt.gz、内存管理__archive.txt.gz、内存管理__evidence.txt.gz、合规ai__archive.txt.gz、合规ai__evidence.txt.gz、运动打卡小助手__archive.txt.gz、运动打卡小助手__evidence.txt.gz。no-carrier 与 branch-only 中非 ASCII 路径为 0。

## AC 实跑结果（命令均为 HANDOFF §9.1 字面命令，仓根执行）

- AC3（pre-impl 方法基线）：命令 `comm -23 <(find .tad/evidence .tad/archive -type f | sort) <(git ls-tree -r --name-only maintainer-evidence | sort) | wc -l && comm -13 … | wc -l` → exit 0，输出 8719／2248，两计数为正整数。**PASS**（基线成立；数值较设计时点 8708 的差额＝盘面增长＋manifest 自包含，构成见 summary 差额分解；S1 正式口径以安全管线四锚为准）。
- AC4（post-impl）：命令按 §9.1 字面执行 → manifest 按 class 计数 Counter({'no-carrier': 8706, 'carried': 4355, 'branch-only': 16, 'stale-content': 5})、总数 13,082；summary grep 锚行恰 4 行：8706／5／4355／16。前四数与四锚逐一相等、总数＝四锚之和。**PASS**。
- AC5（post-impl）：`grep -cE 'as_of|复跑|hash-object|估计' inventory-summary.md` → 16 ≥ 4，exit 0。**PASS**（按现行行文实跑；C-T2 的逐项断言化属 Gate 4 前事项，非本步）。
- AC8 的 S1 部分：字面命令实跑 → 输出 `1 2 1`，exit 0，全行 JSON 可解析。genesis＝1 ✓；本链 chain 行＝2（genesis＋S1 usage），全链阈值 ≥3 于 S2 写入其 usage 行后达成；handoff 命中行＝1，全链阈值 ≥2 于 S2 后达成。数字按 S1 时点如实记录，未凑数。
- FR3 复跑一致性（本步已实跑）：同管线复跑，未剔除时 no-carrier 读数 8707（差额恰为 manifest 本身 1 件），余三锚全等；按 summary 复跑剔除规则剔除盘点产物 2 件后四锚与首跑全等。

## 读取清单回执（逐项打勾）

- [x] 激活包 `.tad/evidence/activation-packages/tad-evidence-revival-s1-01.md` 全文
- [x] HANDOFF 全文（重点 §4.2／§4.5／§6 S0＋S1／§7／§9.1）
- [x] Gate 2 tech verdict（重点 C-T1 全文与基线复算）
- [x] 开链记录 `.tad/evidence/phase3-first-chain.md`
- [x] principles.md＋patterns/_index.md＋命中条目 3 条（ac-verification／release-sync／research-methodology）
- [x] 本仓 AGENTS.md
- [x] 票 TICKET-20261004-maintainer-evidence-branch-revival（仅背景）
- [x] 研究轨判据原件 research-gate-canonical-checklist.md（RG1–RG4）

## 异常与说明（如实记录）

1. usage log 换行修复：genesis 行写入时文件未带行尾换行，S1 usage 行 append 后两行拼接为一行（1,127 B、0 换行），AC8 首跑因此 JSON 解析失败。本步当即修复：在两行接合处补入换行并补行尾换行（两行内容逐字节未改，修复后 1,129 B、2 行、各行可解析），AC8 重跑通过。此为本步自身写入格式事故，已闭合；根因是写文件工具不自动补行尾换行，后续步 append 前应先确认文件以换行结尾。
2. manifest 中 knowledge-usage-log.jsonl 一行记的是枚举时点状态（194 B、stale-content）；S1 usage 行 append 后该文件现为 1,129 B，属枚举后预期变化，不回填 manifest（FR3 口径）。
3. 方法未中途变更，盘点单轮完成，无作废轮次（summary 已设声明位）。
4. 纪律件执行：写入仅限激活包 §⑤ 三处；git 仅只读操作（ls-tree／hash-object）；仓外零写入；python 全部带 PYTHONDONTWRITEBYTECODE=1；未调 precheck／闸脚本、未产 stamp／claim。
