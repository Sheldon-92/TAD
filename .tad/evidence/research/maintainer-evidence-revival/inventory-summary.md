# S1 影响面盘点 summary —— TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL

as_of: 2026-10-04T22:16Z（枚举时点；仓根 /home/hatch/workspace/yun-sync/TAD；分支 maintainer-evidence 尖 = 8713ea4e）
执行者会话标识：session 449e8e64-b7e3-44e1-8097-9dc03d8b9cb6；step_id：tad-evidence-revival-s1-01（C-T4 本步部分）
上游：HANDOFF-2026-10-04-maintainer-evidence-revival.md §4.2／§6 S1；管线按 Gate 2 条件 C-T1 写死执行。

## 四锚（机器可读锚行）

TOTAL_NOCARRIER=8706
TOTAL_STALE=5
TOTAL_CARRIED=4355
TOTAL_BRANCH_ONLY=16

自洽校验：8706＋5＋4355＝13066＝盘上集 A 总数；交集＝carried＋stale＝4360；manifest 总行数＝13082＝四锚之和。

## 方法与口径（§4.2＋C-T1，不另创口径）

- 盘上集 A：仓根执行 `find .tad/evidence .tad/archive -type f -print0`，as_of 时点 A＝13,066 件。
- 分支集 B：`git ls-tree -r -z maintainer-evidence` 全树 6,596 条目（blob 6,595＋gitlink 1）；仅取路径前缀 `.tad/evidence/` 或 `.tad/archive/` 者参与比对：前缀内 4,377 条目（blob 4,376＋gitlink 1），前缀外 2,219 条目仅备查、不入四类。
- gitlink 单独注记（不入四类、不入 manifest）：`.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work`（mode 160000，commit d12b42505f2dfd2b5d8f5de51cc6e3d0a43aa0fa）。
- 交集 4,360 件逐件比对：盘上 `git hash-object -- <path>`（argv 形式分块 400 件/批调用，与 `git hash-object --stdin-paths` 等价的批量形态；argv 形式对任意文件名字节安全）与 B 的 blob sha 比对，同＝carried、异＝stale-content。
- 路径处理：find -print0 与 git ls-tree -z 成对，路径全程按 NUL 分隔字节流处理；UTF-8 解码失败 0 件；含换行符路径 0 件。
- 日期桶：仅从路径抽第一个 `20\d\d-\d\d-\d\d` 日期串归桶，抽不到记 undated；全程未用 mtime。
- manifest 按 path 排序逐件一行；branch-only 行 bytes＝null。

## 基线对照与差额分解（§2.2 旧读数作废注记）

- HANDOFF §2.2 的 8,708／2,248 是 git 默认引用管线（`git ls-tree` 默认输出对非 ASCII 路径加引号转义后与 find 输出做 comm 差集）的**伪差集读数，就此作废**，原因即 C-T1：12 条 CJK 路径在两侧各被误计 12。
- 分支侧 2,248 分解：前缀外条目 2,219＋前缀内 branch-only blob 16＋gitlink 1＋CJK 伪差 12＝2,248。
- 盘上侧：设计时点默认管线 8,708 → 安全口径同时点 8,696（差 12＝CJK 伪差）→ 本步 as_of 安全口径 8,706（＋10：设计快照后盘上新增 10 件 no-carrier，量级与本链自身落盘件一致，见自产小计；交集 4,360 与 B 侧各计数与 Gate 2 tech 评审独立复算全等，无未解释漂移）。
- 评审时点 A＝13,060 → as_of A＝13,066（＋6 件均为评审后落入 A∖B 的新增件，含本链 phase3-first-chain.md 与 S1 激活包 2 件；交集与 B 锚未动）。
- stale-content 4（评审时点）→ 5：第 5 件＝knowledge-usage-log.jsonl，本步 genesis 写入使盘上内容异于分支侧空文件 blob，属 D35 激活的预期变化。

## 估计 vs 实测对照

- 先行估计（票 TICKET-20261004-maintainer-evidence-branch-revival 面，经 HANDOFF §3.1 转述，估计方法未留痕，仅作对照）：盘上件约 12,014／无载体约 8,500。
- 实测：盘上两树 13,066 件／no-carrier 8,706 件（四锚）。
- 结论数字只认四锚实测；估计与实测的差额（盘上件 ＋1,052、无载体 ＋206）不改变 FR1 影响面构成，估计不作任何下游计算输入。

## 分类计数表（树 × 一级子目录 × 类，括号内为字节量；branch-only 字节恒为 null 不计）

### evidence 树

| 一级子目录 | carried | stale-content | no-carrier | branch-only |
|---|---|---|---|---|
| (root) | 6 (43749B) | 3 (1389B) | 5 (39513B) | 0 |
| acceptance-tests | 1426 (35338701B) | 1 (17139B) | 254 (2035131B) | 7 |
| activation-packages | 0 | 0 | 5 (26512B) | 0 |
| audits | 3 (40766B) | 0 | 0 | 0 |
| codex-regression | 26 (1059127B) | 0 | 0 | 0 |
| codex-validation | 22 (1256442B) | 0 | 0 | 0 |
| completions | 94 (250041B) | 0 | 4 (22904B) | 0 |
| decisions | 65 (449093B) | 0 | 1 (523B) | 0 |
| designs | 42 (458366B) | 0 | 20 (177957B) | 0 |
| discuss | 0 | 0 | 4 (62484B) | 0 |
| dogfood | 5 (795483B) | 0 | 0 | 0 |
| dual-platform-regression | 6 (11255B) | 0 | 0 | 0 |
| e2e | 6 (42359B) | 0 | 0 | 0 |
| eval | 2 (7926B) | 0 | 0 | 0 |
| experiments | 0 | 0 | 131 (219945B) | 0 |
| fixtures | 23 (49498B) | 0 | 3 (2444B) | 0 |
| gate4 | 0 | 0 | 1 (1376B) | 0 |
| gates | 5 (8043B) | 0 | 0 | 0 |
| handoff-reviews | 6 (63369B) | 0 | 0 | 0 |
| handoffs | 5 (82839B) | 0 | 0 | 0 |
| hooks | 16 (14301B) | 0 | 1 (680B) | 0 |
| impl | 0 | 0 | 2 (4886B) | 0 |
| journal | 30 (61012B) | 0 | 10 (36014B) | 0 |
| knowledge-migration | 2 (27578B) | 0 | 0 | 0 |
| learnings | 3 (37405B) | 0 | 0 | 0 |
| maintenance | 29 (10483B) | 0 | 0 | 0 |
| metrics | 2 (8242B) | 0 | 0 | 0 |
| overrides | 2 (136B) | 0 | 2 (323B) | 0 |
| pack-dogfood | 11 (61319B) | 0 | 0 | 0 |
| pack-eval | 56 (464720B) | 0 | 0 | 0 |
| pack-quality | 4 (81601B) | 0 | 0 | 0 |
| pack-system-unification-phase1 | 2 (6958B) | 0 | 0 | 0 |
| pack-system-unification-phase2 | 2 (2189B) | 0 | 0 | 0 |
| pack-system-unification-phase3 | 6 (9684B) | 0 | 0 | 0 |
| patterns | 2 (14494B) | 0 | 0 | 0 |
| pm | 0 | 0 | 101 (169260B) | 0 |
| poc | 11 (26631B) | 0 | 0 | 0 |
| project-logs | 1 (968B) | 0 | 0 | 0 |
| ralph-loops | 41 (44565B) | 0 | 11 (11714B) | 0 |
| release | 0 | 0 | 1 (3252B) | 0 |
| releases | 10 (60773B) | 0 | 5 (515727B) | 0 |
| research | 183 (1979792B) | 0 | 26 (191872B) | 0 |
| reviews | 531 (2397899B) | 0 | 256 (1561492B) | 6 |
| spikes | 338 (889700B) | 0 | 3 (2656B) | 0 |
| surplus-burn-20260705 | 13 (292682B) | 0 | 0 | 0 |
| surplus-plans | 7 (295867B) | 0 | 0 | 0 |
| traces | 77 (754323B) | 0 | 10 (40714B) | 0 |
| yolo | 319 (5112283B) | 1 (227B) | 7737 (40078026B) | 1 |
| yolo2-baseline | 0 | 0 | 5 (63466B) | 0 |

注：research 行的 no-carrier 26 件为枚举时点既有件；本盘点产物目录 research/maintainer-evidence-revival/ 于枚举时点为空（产物于枚举后落盘），不在 manifest 内，复跑处理见「复跑命令序列」。

### archive 树

| 一级子目录 | carried | stale-content | no-carrier | branch-only |
|---|---|---|---|---|
| (root) | 7 (93940B) | 0 | 0 | 0 |
| by_task | 0 | 0 | 2 (33254B) | 0 |
| configs | 5 (82091B) | 0 | 0 | 0 |
| domains | 26 (903391B) | 0 | 0 | 0 |
| dream-candidates | 11 (5631B) | 0 | 0 | 0 |
| epics | 75 (824774B) | 0 | 2 (23986B) | 0 |
| handoffs | 640 (9704958B) | 0 | 97 (1425584B) | 2 |
| ideas | 45 (156310B) | 0 | 0 | 0 |
| knowledge | 1 (1998B) | 0 | 0 | 0 |
| knowledge-snapshots | 3 (243171B) | 0 | 0 | 0 |
| learnings-archived | 19 (36867B) | 0 | 0 | 0 |
| legacy-backups | 6 (258876B) | 0 | 0 | 0 |
| next | 1 (80220B) | 0 | 1 (839B) | 0 |
| playground | 4 (83069B) | 0 | 0 | 0 |
| proposals | 14 (23318B) | 0 | 6 (125575B) | 0 |
| protocols | 1 (14830B) | 0 | 0 | 0 |
| research | 36 (567183B) | 0 | 0 | 0 |
| spikes | 21 (170490B) | 0 | 0 | 0 |

字节量小计（按类）：carried 65,863,779B；stale-content 18,755B；no-carrier 46,878,109B。

## 日期桶分布（路径日期串抽取；A 集 13,066 件；branch-only 16 件全为 undated）

- 2026-01（月计 16）：07:6 20:9 23:1
- 2026-02（月计 5）：06:4 09:1
- 2026-04（月计 18）：02:1 03:1 04:1 07:2 13:1 14:1 15:1 24:3 25:3 27:2 28:2
- 2026-05（月计 95）：01:2 02:2 03:2 04:2 05:3 07:10 08:4 09:2 13:2 14:6 15:9 17:2 18:2 19:6 20:2 22:1 27:12 28:4 29:2 30:2 31:18
- 2026-06（月计 175）：01:52 02:6 03:6 04:3 05:2 06:4 07:5 08:4 09:5 10:43 11:16 13:4 14:4 15:2 16:2 17:4 18:2 19:1 22:4 23:6
- 2026-07（月计 51）：01:6 02:8 03:2 04:1 05:7 06:1 12:9 13:2 14:2 15:1 27:3 30:7 31:2
- 2026-08（月计 3110）：01:6 02:5 03:6 04:3 05:7 06:2 07:2 09:2 10:2 11:2 12:2 13:2 14:2 15:1 16:3 17:1 24:4 26:636 27:1731 28:42 29:631 30:4 31:14
- 2026-09（月计 209）：01:3 02:5 04:9 06:2 07:1 08:64 09:10 10:32 11:13 12:9 13:10 14:10 15:28 16:2 22:2 29:9
- 2026-10（月计 47）：01:21 02:5 04:21
- undated：9,340

读数注记：2026-08-26／27／29 三桶合计 2,998 件，为分支活跃期批量落盘件的路径日期；分支尖停于 2026-09-06 后，09-08 起日期桶锐减（09-08 桶 64 件后多为个位数至两位数），与「停摆期新增」叙事一致——仅作分布读数，不作因果结论（NFR2）。

## stale-content 清单（5 件，全量）

1. `.tad/evidence/README.md`
2. `.tad/evidence/acceptance-tests/discipline-floor/gen-floor.py`
3. `.tad/evidence/knowledge-usage-log.jsonl`（本链 genesis 写入所致，见差额分解）
4. `.tad/evidence/memory-distill-cursor`
5. `.tad/evidence/yolo/yolo2-verified-orchestration/phase3/capabilities/aggregate.json`

## sha 样本行（hash-object 逐件比对样本，≥2）

carried 样本：
- ls-tree 行：`100644 blob 70fb0b37b7c90e940cc5daddffcbbf1679d63672	.tad/archive/.sha-manifest.txt`
- hash-object 结果：`70fb0b37b7c90e940cc5daddffcbbf1679d63672` —— 一致，归 carried。

stale-content 样本：
- ls-tree 行：`100644 blob e69de29bb2d1d6434b8b29ae775ad8c2e48c5391	.tad/evidence/knowledge-usage-log.jsonl`（e69de29 为 git 空文件 blob）
- hash-object 结果：`b147baed3ce0fd98bc994e6bfdf25206b55e4258` —— 不一致，归 stale-content。
- 另一样本：`.tad/evidence/README.md` 分支 sha `0e454df4b6a099f74ebb56a5c750ac8e7709cb9a` vs 盘上 `fef23ee39cf9f5c6f5b594291de1a1ba8d402d73`，归 stale-content。

ls-tree 原始条目样本行（-z 输出，NUL 分隔；此为前缀外备查条目形态样本）：`100644 blob 5bc4ceaf8d1b9ae04b2f27c5f172a3736613edb7	.agents/skills/_archived/ai-integration.md`

## CJK 路径抽验（C-T1）

盘上与分支中共 12 条非 ASCII 路径，全部落在交集内、全部归类 carried，branch-only 与 no-carrier 中非 ASCII 路径为 0——默认引用管线会把这 12 条双边误计为差集，安全管线下误计为 0。12 条全在 `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/` 下（Colin声音项目／下载md插件／买卖／内存管理／合规ai／运动打卡小助手，各 `__archive.txt.gz` 与 `__evidence.txt.gz` 两件），逐件清单见完工说明。

## 本链自产小计（按实类归行，不排除、不回填）

匹配规则（声明，可复算）：路径恰为 `.tad/evidence/phase3-first-chain.md` 或 `.tad/evidence/knowledge-usage-log.jsonl`，或位于 `.tad/evidence/research/maintainer-evidence-revival/` 下，或 basename 含 `maintainer-evidence`／`phase3-anchor`／`evidence-revival` 之一。

小计：12 件 ＝ no-carrier 11＋stale-content 1（knowledge-usage-log.jsonl）。清单：
- .tad/evidence/activation-packages/tad-evidence-revival-s1-01.md
- .tad/evidence/activation-packages/tad-phase3-anchor-design-01.md
- .tad/evidence/activation-packages/tad-phase3-anchor-gate2-fit-01.md
- .tad/evidence/activation-packages/tad-phase3-anchor-gate2-tech-01.md
- .tad/evidence/completions/2026-10-04-tad-phase3-anchor-design-note.md
- .tad/evidence/completions/2026-10-04-tad-phase3-anchor-gate2-fit-note.md
- .tad/evidence/completions/2026-10-04-tad-phase3-anchor-gate2-tech-note.md
- .tad/evidence/knowledge-usage-log.jsonl（stale-content）
- .tad/evidence/phase3-first-chain.md
- .tad/evidence/pm/2026-10-04-phase3-anchor-pm-verify.md
- .tad/evidence/reviews/2026-10-04-gate2-fit-maintainer-evidence-revival.md
- .tad/evidence/reviews/2026-10-04-gate2-tech-maintainer-evidence-revival.md

注：inventory-manifest.jsonl 与本 summary 于枚举时点尚不存在、不在 manifest 内；本步完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-revival-s1-note.md` 亦于枚举后落盘。以上均为枚举后新增件，复跑时按 FR3 以新增件解释，不回填首跑锚值。

## 复跑命令序列（完整，仓根执行；产出四锚供与首跑比对）

复跑剔除规则：A 集须剔除盘点产物本身 2 件（research/maintainer-evidence-revival/ 下的 inventory-manifest.jsonl、inventory-summary.md）；剔除后四锚应与首跑全等。S1 完工说明为枚举后新增件，复跑时按 no-carrier 新增 1 件解释（或一并剔除后比对）。本步已实跑一次复跑验证：未剔除时 no-carrier 锚读数为 8707（差额恰为 manifest 本身 1 件），余三锚（stale 5／carried 4355／branch-only 16）与首跑全等。

```bash
cd /home/hatch/workspace/yun-sync/TAD
find .tad/evidence .tad/archive -type f -print0 > /tmp/A0.bin
git ls-tree -r -z maintainer-evidence > /tmp/B0.bin
PYTHONDONTWRITEBYTECODE=1 python3 - <<'EOF'
import subprocess, collections
A=[p.decode('utf-8') for p in open('/tmp/A0.bin','rb').read().split(b'\0') if p]
EXCL={'.tad/evidence/research/maintainer-evidence-revival/inventory-manifest.jsonl',
      '.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md'}
A=[p for p in A if p not in EXCL]
B={}
for e in open('/tmp/B0.bin','rb').read().split(b'\0'):
    if not e: continue
    meta,pb=e.split(b'\t',1); mode,typ,sha=meta.decode().split(' '); p=pb.decode('utf-8')
    if typ=='blob' and p.startswith(('.tad/evidence/','.tad/archive/')): B[p]=sha
As,Bs=set(A),set(B); inter=sorted(As&Bs); c=collections.Counter()
for i in range(0,len(inter),400):
    ch=inter[i:i+400]
    out=subprocess.run(['git','hash-object','--']+ch,capture_output=True).stdout.decode().split()
    for p,s in zip(ch,out): c['carried' if s==B[p] else 'stale-content']+=1
print('TOTAL_NOCARRIER=%d'%(len(As-Bs))); print('TOTAL_STALE=%d'%c['stale-content'])
print('TOTAL_CARRIED=%d'%c['carried']); print('TOTAL_BRANCH_ONLY=%d'%(len(Bs-As)))
EOF
```

## 作废轮次声明

本盘点单轮完成，方法未中途变更，无作废轮次。（声明位：后续如因方法修正重跑，须在此追加声明先前轮次作废并全量重跑，不许拼接两轮数据。）

## 给 S2 的接口注记

- 影响面本体＝no-carrier 8,706＋stale-content 5（件数与字节量见分类计数表）；可达下界＝carried＋stale＝4,360 件仍同时在分支可达。
- branch-only 16 件（blob 口径）路径全量在 manifest 内（class＝branch-only），另 gitlink 1 件见方法节注记。
- 本 summary 不含处置建议；三案比较属 S2。

## 口径增补（2026-10-04，F1）

复跑命令序列的盘上集 A 在算四锚前，除既有 EXCL 2 件外，另剔除两类路径：(i) 分支 gitlink 条目路径前缀之下的盘上文件；(ii) 路径任一组件为 `.git` 的文件。此类路径记 outcome 类 `embedded-repo`，不入同步队列、不计 TOTAL_NOCARRIER——其内容由嵌入仓库自身 git 结构与分支 gitlink 指针承载。依据：PM 裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-f1-ruling.md` 与 HANDOFF §4.2 C1（F1 增补）。
