# Ralph Loop 自检 — TASK-20261006-EPIC-P4-SCALE（Blake）

## Round 1 — Phase 0（基线复算＋分诊成表）
- 锚复算：§2 全部锚逐项复测。命中：HEAD/version/双分支尖/体量三面/pack/log/两索引差集/locale 全等。偏差均已归因入 `size-inventory.md` §A：① 总量为时点采样（Phase 0 523M、链末 530M 系并行链在飞写入上行）；② `.tad` +5M 为本链自产证据。tad.sh 设计锚按增补 B5 让位：Phase 0 锚＝盘面 `947a8614…`，记行于盘点件。**更正记（收口复核）**：本轮早段曾据后台 exec 读数记「loose 4.23 MiB／计量口径差」与一 tad.sh blob 谱系，前台复算证明该批读数出自后台会话过期文件视图（loose 实为 6.65 MiB 与锚全等、谱系以盘点件更正记为准），已在盘点件 §A 逐项作废更正——与下条产物丢失同源。
- 过程事件：首轮比对脚本经后台 exec 执行，其写入的证据件与 /tmp 暂存事后查无（同批前台写入均在盘）。处置：改以优化脚本前台重跑（xargs 批量哈希），产物即时验在盘（`ls -la` 目验＋sha 落盘）；后续全部文件写入走前台 exec 并即时复验，不再依赖后台 exec 落盘。
- 比对负控：自造差异目录三植入点逐件命中、判 (b)，判别力成立（`worktree-comparison.md` §A）。
- 发现（新）：四 worktree 副本存在同步通道名称过滤（token/secret/.env 系统性缺失 27 件公共集，probed 级证据）→ 三目录为「子集等值」形态，超出 §4.1 (a)/(b) 字面二分，入停步点 D-P0-1 待 PM 裁；candidate 实质 (b)（116M 非 ref 证据副本＋9 件内容差异）。
- 停步纪律：Phase 2 未启动；Phase 1 步 4（tad.sh 接线）因备份修复链实施提交未到（HEAD 仍 `68593e82`）按 B5 暂跳，其余 Phase 1 步先行。
- ASM 自监：ASM-1 未触发（无 (a) 级字面行被误判；子集形态已显式上报而非径行定级）；ASM-2 未触发（证据面零写入目标外动作；maintainer-evidence 尖未动）；ASM-3 待 Phase 1 步 4（暂跳中）。

## Round 2 — Phase 1（生成面修复与索引复产）
- 步 1 生成器修复：13 点位全改（utcut 字节安全截断＋utstrip_title 原子 em-dash 剥离，perl 为仓内既有工具）；单元探针 10 项全过；骨架 fixture `LC_ALL=C` 干跑新旧对照判别成立（新：解码 OK／NEL 0／标题 16/16；旧：解码 FAIL＋标题不符）→ AC10/AC11 成立。
- 步 2 patterns 索引＋3 行（hook 照 B4 以标题＋首节六维表实测撰写）；comm 双向差集为空（16＝16）→ AC23 前半成立。
- 步 3 真仓复产：298 行／27,432 B、Generated 当日、check7 `age 0d` INFO 无 WARN、state-surface 全检 PASS；覆盖抽核三行＋EPIC 行＋Principles 16＝16 → AC12/AC13 成立。
- 步 3 附带 AC12B（置旧向）：隔离副本回填 2026-09-20（age 16d）→ WARN 且明示 advisory 不计 FAIL，双向齐备。
- 步 4 tad.sh 接线：**B5 串行序未满足，暂跳**。复查时点 HEAD 仍 `68593e82`，备份修复链实施提交未落盘（该链 Blake 在飞：未跟踪件 `tad-backup-test.sh` 在盘）。本步标 BLOCKED-SERIAL，待其提交落盘后以届时 tad.sh 为锚续做（AC14/AC15 随之待办）。
- 步 5 incidents 对账：25 盘面件全在册、悬空 1 件为已毕业留痕（处置＝注记保留）；对账表＋索引尾验证行落盘 → AC24 成立。
- 本轮写集自检：`git status` 改动恰为本链四件（brain-index.md／brain-index-gen.sh／patterns _index／incidents _index），无外溢。

## Round 3 — Phase 3＋Phase 4（D35/收官备料/总验）
- Phase 3：盘点件与设计锚逐值全等（AC18）；计数脚本现行 log 与合成 fixture 双向判读成立（AC19）；模板 Knowledge Usage 节＋evidence-collection §7.1 append 步落盘（AC21）；publish-protocol step3g 落盘（AC16）；收官清单件＋AC26 预检基线（59 hits/34 文件，正口径命令可复跑）落盘。
- Phase 4：§9.1 逐行自跑回填 COMPLETION；dogfood append 实测 log 6→7 行全解析（AC22）；版本冻结复核（version.txt diff 空、无新 tag、origin/main 未动）成立（AC28）。
- release-verify 逐 mode：version/version-sweep/state-surface 绿；freshness（台账长存过期）、migration（发版时点检查的预发版构造形态）、installer-destructive-guard（tad.sh 两 id 重复、P3 后既存）三项非绿，均非本链引入，归因入 COMPLETION 总验节，AC27 如实记 ⚠️ 不凑绿。
- **终验事件**：收口扫发现 porcelain 新增 `tad.sh`／`tad-update.sh` 两件 M——diff 归因全为并行 tadsh-backup-fix 链在飞实施（backup-root 重构），非本链所写；已在 COMPLETION 总验节加附记更正「不在改动集」表述口径。ASM-3 自监：本链对 tad.sh 零编辑，接线未抢跑，ASM-3 未触发（其 fixture 判据随步 4 续做）。
- 终态：Phase 2 待 PM 裁 D-P0-1、步 4 待备份修复链提交——两处续做口径已写入 COMPLETION 与实施说明。
