---
gate: gate2
road: tech
subject_path: .tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md
subject_type: design
subject_sha256: 2680499d86bfdd62493eba1a86e2624da0bec08db1f7971131016203f2ce92db
subject_bytes: 50588
reviewed_step_id: tad-phase3-anchor-design-01
review_step_id: tad-phase3-anchor-gate2-tech-01
executor_id: tad-phase3-anchor-design-01
reviewer_role: alex
reviewer_id: b36ef433-362c-473e-9be9-ef38c9bc2604
verdict: CONDITIONAL
basis: 五项技术判据逐项亲读亲跑：数据流与落点、前置与失败路径两项通过；S1 双口径方法成立且不过重（同路径 sha 口径实测分出 stale-content 4 件，证明第二口径有实际增量）。4 条 P1 均为验收口径/管线写死类缺陷，不动链结构：①§4.2 与 AC3 的基线管线用 git 默认引用输出，12 条 CJK 路径被计成伪差集，基线 8708／2248 较安全口径各虚高 12，且 B 集未排除 1 条 gitlink；②AC5／AC6 合并 grep 计数、AC11 裸串 KA 均可误 PASS（反例亲跑成立）；③AC4／AC5 不验 manifest 集合等式，类别计数对得上仍可漏/重路径；④AC7 独立性比对缺执行者会话标识的产物载体。
conditions:
  - "C-T1（P1-1）：S1 派发前，由设计方出勘误或 PM 在 S1 任务书中写死——ls-tree 必须用 -z（或 core.quotepath=false）与 find -print0 成对使用；B 集只取 type=blob 条目，gitlink 单独注记、不入四类；基线 8708／2248 标注为默认引用管线的伪差集读数，安全口径设计时点锚值为盘上独有 8696／分支独有（全树）2236／前缀内 branch-only 条目 17（含 gitlink 1，blob 口径 16）。关闭标准：S1 summary 复跑四锚与安全管线一致，且 12 条 CJK 路径归类抽验正确。"
  - "C-T2（P1-2）：Gate 4 执行前，AC5／AC6／AC11 改为逐项断言（每个锚词单独计数 ≥1，不许合并 grep -cE 一把计总数）。关闭标准：修订后命令对本 verdict 所附三条反例（仅估计×4／仅案一×3／KAGGLE 行）不再误 PASS。"
  - "C-T3（P1-3）：S1 收口 PM 验盘与 Gate 4 各补一次集合等式复算——manifest 路径集 == A 集 ∪ branch-only 集、无重复行、class 与 sha 重算一致。关闭标准：复算输出与 manifest 计数全等并留痕于 PM 验盘记录或 RG4 记录。"
  - "C-T4（P1-4）：S1／S2 任务书写死——inventory-summary 与 decision-brief 各记一行执行者会话标识，AC7 比对以此为据。关闭标准：两产物在盘可查得会话标识，且与 RG3 verdict 所记会话标识不同。"
evidence:
  - .tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md
  - .tad/evidence/completions/2026-10-04-tad-phase3-anchor-design-note.md
  - .tad/evidence/pm/2026-10-04-phase3-anchor-pm-verify.md
  - .tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md
  - .tad/evidence/phase3-census.md
  - .tad/gates/research-gate-canonical-checklist.md
  - .tad/project-knowledge/patterns/ac-verification.md
  - /home/hatch/workspace/yun-sync/gm/.tad/active/handoffs/HANDOFF-gm-phase3.md
  - /home/hatch/workspace/yun-sync/gm/.tad/evidence/2026-10-03-gate-hardgate-design-v2.md
  - "git 对象 maintainer-evidence@8713ea4e（本评审亲跑 ls-tree／hash-object 复算，输出见正文）"
reviewed_at: 2026-10-04T21:54:17Z
---

# Gate 2 技术路评审 — maintainer-evidence 分支复活 HANDOFF

评审员：Alex 独立评审会话（非本链设计者，与设计会话上下文不共享）。评审方式：判据原件亲读＋基线与 AC 命令亲跑复算；只评审，未改设计、未代写 HANDOFF。字段注记：设计完工说明未记录设计步的 spawn agent id，`executor_id` 以被评步 step_id 作可追溯标识；`reviewer_id` 为本评审会话 id，两者不同。

**结论：CONDITIONAL。P0 = 0，P1 = 4。** 按 HANDOFF §6 S0 口径，CONDITIONAL 可启动；4 条条件分别绑定 S1 派发前（C-T1、C-T4）、S1 收口与 Gate 4（C-T3）、Gate 4 执行前（C-T2），关闭标准见头部 conditions 与正文末条件清单。

票面估计（约 12,014／约 8,500）本评审未作判据，仅按「先行估计、待 S1 复核」对待。

---

## 判据 1：S1 盘点方法 —— 有条件通过（P1-1）

**成立的部分。** 双口径设计成立：路径差集只能分出「盘上有无载体」，同路径 sha 差集才能分出内容是否被分支载荷覆盖。亲跑证明第二口径不是冗余——交集 4,360 条中实测 stale-content 4 件，路径口径会把这 4 件误判为已覆盖。方法不过重：分支侧只读 ls-tree 的 blob sha、不读盘上内容；盘上侧只对交集跑 `git hash-object`（本评审全量复算交集 4,360 条，含枚举约 27 秒），manifest 约 1.3 万行，无内容拷贝、无逐件人工。两树前缀过滤的概念正确：分支全树 6,596 条中，前缀外 2,219 条（`.tad/active/` 等）被排除，不进四类。

**缺陷（P1-1）。** §4.2 冻结的管线写 `git ls-tree -r maintainer-evidence`（B 集）与 `find` 按行处理，未写死 `-z`／`core.quotepath=false`；§8.3 只原则性说「-print0／逐行引用安全形态」，没有点名 ls-tree 的引用行为。git 默认输出会把非 ASCII 路径加引号转义，前缀过滤与 comm 比对随之失真。亲跑证据：

```text
$ git ls-tree -r --name-only maintainer-evidence | awk '$0 ~ /^\.tad\/(evidence|archive)\//' | wc -l
4365
$ git ls-tree -r --name-only maintainer-evidence | awk 'substr($0,1,1)=="\"" {n++} END{print n+0}'
12
$ git ls-tree -r --name-only maintainer-evidence | grep -m1 'Colin'
".tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/Colin\345\243\260\351\237\263\351\241\271\347\233\256__archive.txt.gz"
```

安全口径（`ls-tree -r -z` 按字节路径解析）同一时点复算：

```text
A_current 13060
B_all 6596
B_filtered_true 4377
intersection_true 4360
A_minus_B_filtered_true 8700
B_filtered_minus_A_true 17
nonascii_intersection 12
nonascii_branch_only 0
```

即 12 条 CJK 路径全部是交集件，默认管线把它们同时误计入盘上独有与分支独有，两侧各虚高 12；且默认管线下四锚仍能自洽求和，§8.2 的「四锚对不上才停」抓不到这种误分类。另一处同类问题：B 集前缀内含 1 条 gitlink（mode 160000、type commit），§4.2 称 B 取「路径＋blob sha」，gitlink 没有 blob sha、也不是文件：

```text
160000 commit d12b42505f2dfd2b5d8f5de51cc6e3d0a43aa0fa	.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work
B 前缀内条目构成：(100644, blob) 4206 ＋ (100755, blob) 170 ＋ (160000, commit) 1 ＝ 4377
```

处置见 C-T1：管线写死安全形态＋B 集只取 blob 条目，S1 即可正确执行，不需改链结构。

## 判据 2：基线数字一致性 —— 有条件通过（并入 P1-1）

亲跑复核（超过激活包要求的 2 项）：

```text
$ git log -1 --format=%h maintainer-evidence
8713ea4e
$ git log -1 --format='%h %ci %s' maintainer-evidence
8713ea4e 2026-09-06 14:42:29 -0400 chore(evidence): sync 134 post-phase4 evidence and archive records to maintainer-evidence
$ git hash-object --stdin-paths（交集 4360 条全量）
intersection 4360
carried 4356
stale_content 4
sample: .tad/archive/.sha-manifest.txt  branch_sha == disk_sha == 70fb0b37b7c90e940cc5daddffcbbf1679d63672
```

判定：分支尖 8713ea4e ✓；6596 ✓（条目数，含 gitlink 1，称「文件数」差 1，口径注记并入 C-T1）；13056 为设计时点盘面，评审快照为 13,060，差 +4 均为 HANDOFF 落盘后新增的证据件（设计完工说明、PM 验盘记录、双路 Gate 2 激活包存证），HANDOFF 的 as_of／FR3 口径已预声明，不算基线错误。8708／2248 彼此自洽（默认管线交集 4,348：13,056−4,348＝8,708；6,596−4,348＝2,248），但按安全口径，设计时点真值为盘上独有 8,696、分支独有（全树）2,236——两数各含 12 条引用伪差。HANDOFF §2.2／§5 已把两数标注为含口径差、待 S1 前缀重算，AC3 的预期方向（S1 过滤后只许更小）对安全口径仍成立（8,696＜8,708、17＜2,248），故记 P1 而非 P0；但 §2.2 把差异只归因于「两树外口径差」不完整，须按 C-T1 补正引用伪差这一项。

## 判据 3：AC 可验性 —— 有条件通过（P1-2、P1-3、P1-4）

§9.1 十二行每行恰一种 Verification Method，均为 handoff-creation 口径内的合法类型（command／rubric-spawn 等），无一行双 method。pre-impl 行亲跑形态对得上：AC1 输出 `TICKET_PRESENT`、AC2 输出 `8713ea4e`、AC12 `.gitignore` diff exit 0。post-impl 行在基线上以正确理由失败，亲跑：AC4 manifest 不存在 → `FileNotFoundError` exit 1；AC5／AC6／AC9／AC10／AC11 目标文件不存在 → grep exit 2；AC8 输出 `0 0 0`（genesis／本链行均未写）。裁量点 8 的 grep 锚词约束方向不过苛——问题在判别力不足（偏松且有一处反向误判）：

- **P1-2a（AC5）**：`grep -cE 'as_of|复跑|hash-object|估计' ≥4` 是合并计数，证明不了 Expected Evidence 声称的「四类锚词各至少命中一行」。反例亲跑：只含「估计」4 行的文本计数为 4（误 PASS）；反之四锚挤在同一行的合格 summary 计数为 1（误 FAIL）。

```text
$ printf '估计\n估计\n估计\n估计\n' | grep -cE 'as_of|复跑|hash-object|估计'
4
```

- **P1-2b（AC6）**：`grep -cE '案一|案二|案三' ≥3` 同病——只写案一 3 行即计数 3，案二、案三缺席照样 PASS；且该行不验三案是否同维度比较，FR4 的判别实际落在人工读 Brief，AC 行本身只算在场检查，Expected Evidence 的表述超出命令所能证明的范围。

```text
$ printf '案一\n案一\n案一\n' | grep -cE '案一|案二|案三'
3
```

- **P1-2c（AC11）**：锚词含裸串 `KA`，任意含 “ka” 的英文词即命中（如 `KAGGLE` 计数 1），不能证明 Knowledge Assessment 节存在。

```text
$ printf 'KAGGLE benchmark note\n' | grep -ciE 'knowledge assessment|## KA|KA'
1
```

- **P1-3（AC4／AC5 覆盖性）**：AC4 只比 manifest 的 class 计数与 summary 锚数，AC5 只 grep 方法词在场；没有任何一行重算「manifest 路径集 == A 集 ∪ branch-only 集」或查重复行。类别计数全对、但路径漏登/重登/张冠李戴的 manifest 能通过 §9.1 全部行——而逐件清单正是本链核心交付物。S3 抽查 5 行只能抽样兜底，不能替代集合等式。处置见 C-T3。
- **P1-4（AC7 载体缺失）**：AC7 要求比对 RG3 verdict 的会话标识与「S1／S2 产物 provenance 的执行者会话标识」，但 §4.3／§4.4／§7 没有要求 inventory-summary 或 decision-brief 记录执行者会话标识（Brief 的 SOURCES 是来源出处，不是执行者标识）。AC7 按字面无据可比，独立性判定会落回 PM 派发记录这一 AC 未引用的外部载体。处置见 C-T4。

## 判据 4：数据流与落点 —— 通过

§4.1 数据流（S1 manifest＋summary → S2 Decision Brief → S3 RG3 Critic → S4 RG4＋COMPLETION＋F-2 锚行）与 §6 步序、§7 文件结构（创建 9 件／修改 2 件）逐项对得上，各步 Verification 引用的产物路径一致，无悬空引用。S1 清单路径 `.tad/evidence/research/maintainer-evidence-revival/inventory-manifest.jsonl` 位于既有 research 树下、新建子目录即可行；其身处整树忽略区正是本链要解决的问题本身，不构成落点障碍——可见性由 COMPLETION 与 `phase3-first-chain.md` 的 F-2 锚行（修改 2 件之一）补齐，设计自洽。

## 判据 5：前置与失败路径 —— 通过

§6 S0 三条件次序正确：Gate 2 双路 verdict 落盘 → GM 练关等价登记确认 → 登记确认后才跑 S1 首个 precheck 且 exit 0，与 C-P3-4 出路 (b) 一致；登记未确认的 BLOCKED 路径在 §8.4 写明，且明禁以 PM_BYPASS 绕 §2f 类校验，与 scope-privileges 的分界纪律不冲突。mtime 禁用技术上成立：同步拷贝会改写 mtime，以 sha 比对＋as_of 锚替代是正确取舍，§8.3 已写明。S1→S2→S3→S4 为线性依赖（清单→比较→独立评审→收口），无环、无缺步；D35 usage log 自 S1 起写（genesis＋本链行）与步序不冲突。唯一提示（不计问题）：§8.2 四锚自洽校验在默认引用管线下会假自洽，须与 C-T1 的安全管线绑定才有效。

---

## 问题清单汇总

| 编号 | 级别 | 一句话 | 关闭条件 |
|---|---|---|---|
| P1-1 | P1 | §4.2／AC3 管线未写死路径安全形态：12 条 CJK 路径成伪差集（基线 8708／2248 各虚高 12），B 集含 1 条 gitlink 非 blob 条目 | C-T1 |
| P1-2 | P1 | AC5／AC6 合并 grep 计数＋AC11 裸串 KA，判别力不足、可误 PASS（AC5 另有同行误 FAIL） | C-T2 |
| P1-3 | P1 | AC4／AC5 不验 manifest 集合等式与重复行，核心交付物的全覆盖性无机械保证 | C-T3 |
| P1-4 | P1 | AC7 独立性比对缺执行者会话标识的产物载体 | C-T4 |

P0：无。链结构、步序、落点、前置条件均成立，4 条 P1 都是口径写死与验收补强类，不要求推倒设计。

## 评审边界

本评审未调 precheck、未产 stamp/claim；gm 仓只读；除本 verdict 与配套完工说明外未写任何文件。基线复算为评审时点快照，盘面在评审期间仍有其他评审件落盘，数字以 as_of 快照四锚自洽为准。
