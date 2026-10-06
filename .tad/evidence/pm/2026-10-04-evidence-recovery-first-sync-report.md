# 首轮同步报告（Phase 3 执行记录＋停步报告）

- 链：证据载体恢复执行链（TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION）
- 执行步：tad-evidence-recovery-impl-p25-01（Blake）；上游：第一段完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-p01-note.md`
- 17 件处置依据（AC4 回指）：`.tad/evidence/pm/2026-10-04-evidence-recovery-17items-ruling.md`（PM 核准文件；处置表 17 行 `ruling_ref` 已全量回填该路径，AC3 两次实跑 PASS）
- **状态：Phase 3 已执行；对账断言 AC6／AC7／AC15 不过 → 按 HANDOFF §4.7 与 Phase 3 第 4 步停步报 PM。Phase 4 推送未执行、Phase 5 未开工。本地新尖未推送、回滚锚完好。**

## 1. 同步执行记录

- 脚本：`.tad/scripts/sync-maintainer-evidence.sh`（本步新作；Phase 2 临时克隆三态自测全过后才跑首轮）
- 命令形态：`sync-maintainer-evidence.sh --expect-base 8713ea4eb88b53f74f70f50477143a6fec05d22a`（默认清单与处置表路径）
- 结果：`RESULT=SYNCED`，退出码 0，耗时约 83 秒
- 基线尖（父）：`8713ea4eb88b53f74f70f50477143a6fec05d22a`
- 新尖：`982e5580649f2da53cb3531b2f91449d893c6fd9`（父＝基线尖本身，提交主题 `chore(evidence): sync`，AC8 父断言 PASS）
- 销账小计：队列入账 8,759 件（47,468,559 B，逐件 `hash-object` 回写 sha＋新尖）；drop 落地 7 件（`dropped-by-ruling`＋新尖）；branch-only keep 9 件标 `kept-branch-only`（blob 9 件，gitlink 另计）；清单 outcome 分布终态：synced 8,759／kept-branch-only 9／dropped-by-ruling 7／carried 4,355（原样）

## 2. 对账结果（问题所在）

- AC7 全量对账：queue 8,759＝synced 8,759；**mismatch 36**。36 件的清单 sha 与盘上现值一致、blob 已写入对象库，但新尖树内无此 36 件条目。
- AC15：新尖中 `.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work` 条目为 `040000 tree`（含 4 件工作文件），**原 `160000 commit d12b4250…` gitlink 指针已被替换**——AC15 不过。
- 根因（一处）：冻结队列含 spike-work 前缀下 40 件盘上文件，与分支的 gitlink 载体模型结构性冲突。spike-work 盘上是一个完整的嵌入 git 工作副本；分支以 gitlink 指针引用其提交 `d12b4250`。队列文件写入临时索引时，gitlink 条目被普通树条目替换（4 件工作文件因此入树，AC7 对此 4 件对账相符）；36 件 `.git/**` 内部文件因路径含 `.git` 组件，git 索引不接受，未入树（脚本 `update-index --index-info` 未报错，静默丢失——脚本对此形态无守卫，是脚本缺陷点）。
- 结论：新尖 `982e5580…` **不可推送**（AC15 已破、AC7 有 36 件账实不符）。其余 8,723 件对账全部相符、7 件 drop 全部落地、STALE 已清零——缺陷被隔离在 spike-work 40 件一簇内。

## 3. 差额清单（spike-work 40 件，全量）

载体冲突簇：`.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work/` 前缀下 40 件。其中 4 件工作文件已入树（替代了 gitlink）：

- `.codex/hooks.json`
- `config.toml`
- `spike-c/capture-hook.sh`
- `spike-d/capture-hook.sh`

36 件 `.git/**` 内部文件未入树（清单标 synced、树内无条目）：

- `.git/COMMIT_EDITMSG`、`.git/HEAD`、`.git/config`、`.git/description`
- `.git/hooks/` 下 14 件 sample（applypatch-msg／commit-msg／fsmonitor-watchman／post-update／pre-applypatch／pre-commit／pre-merge-commit／pre-push／pre-rebase／pre-receive／prepare-commit-msg／push-to-checkout／sendemail-validate／update，皆 `.sample` 后缀）
- `.git/index`、`.git/info/exclude`、`.git/logs/HEAD`、`.git/logs/refs/heads/master`、`.git/refs/heads/master`
- `.git/objects/` 下 13 件（45/21ab…、52/b099…、5b/5608…、72/3d3d…、72/fe1d…、7e/c8ef…、ae/ef33…、d1/2b42…、d4/3acb…、e3/f2d7…、ee/f38d…、ef/87c7…、f6/ef68…；完整路径见执行版清单 spike-work 前缀 40 行）

备注：36 件中含 `.git/objects/d1/2b42505f…` 本身，即 gitlink 所指提交对象——嵌入仓库自带完整对象库，其内容由该仓库自身 git 结构承载。

## 4. 四锚对照（S1 基线／Phase 0 冻结／同步后复算）

| 锚 | S1（2026-10-04） | Phase 0 冻结（23:51Z） | 同步后复算（对新尖） |
|---|---|---|---|
| TOTAL_NOCARRIER | 8706 | 8754 | 44 |
| TOTAL_STALE | 5 | 5 | 0 |
| TOTAL_CARRIED | 4355 | 4355 | 13078 |
| TOTAL_BRANCH_ONLY | 16 | 16 | 9 |

同步后复算分解：

- STALE＝0：§4.7 期望达成（stale 5 件已被新内容覆盖）。
- BRANCH_ONLY＝9：与期望（keep 的 blob 行数，gitlink 不计）逐件相符，集合＝处置表 keep 9 件原路径。
- CARRIED＝13078＝原 carried 4355＋本次真入树 8723（含 spike-work 工作文件 4 件）。
- NOCARRIER＝44＝36（spike-work `.git/**`，即 §3 差额）＋8（冻结后新增残差，逐件列名如下）。AC6 的等式（管线值＝盘上集减清单路径集）因此差 36 不成立，差额即此 36 件。
- 冻结后新增残差 8 件（冻结时点后落盘、不在执行版清单内，属预期形态，下一轮同步自然入账）：`.tad/evidence/research/maintainer-evidence-revival/execution-manifest.jsonl`、`branch-disposition.tsv`（同目录）、`.tad/evidence/pm/2026-10-04-termination-secret-isolation-check.md`、`.tad/evidence/pm/2026-10-04-evidence-recovery-17items-ruling.md`、`.tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md`、`.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-p01-note.md`、`.tad/evidence/activation-packages/tad-evidence-recovery-impl-p25-01.md`、`.tad/evidence/ralph-loops/TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION_state.yaml`。本报告自身落盘后残差另加本件。

## 5. 12 条 CJK 路径（逐件点名，状态 carried）

以下 12 件自 S1 起即完好 carried，本轮复算仍 carried，sha 全等：

1. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/Colin声音项目__archive.txt.gz`
2. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/Colin声音项目__evidence.txt.gz`
3. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/下载md插件__archive.txt.gz`
4. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/下载md插件__evidence.txt.gz`
5. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/买卖__archive.txt.gz`
6. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/买卖__evidence.txt.gz`
7. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/内存管理__archive.txt.gz`
8. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/内存管理__evidence.txt.gz`
9. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/合规ai__archive.txt.gz`
10. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/合规ai__evidence.txt.gz`
11. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/运动打卡小助手__archive.txt.gz`
12. `.tad/evidence/maintenance/2026-06-10-downstream-contamination-cleanup/manifests/运动打卡小助手__evidence.txt.gz`

## 6. 推送三值并列节（AC4 载体）

- 本地尖：`982e5580649f2da53cb3531b2f91449d893c6fd9`（**不可推送，见 §2**）
- 远端尖（ls-remote）：未查——Phase 4 未执行。
- origin 跟踪尖：`8713ea4eb88b53f74f70f50477143a6fec05d22a`（未变）。
- 推送状态：**未执行（BLOCKED）**。停步点在 Phase 3 对账断言；未触碰 grokbox 通道；不存在已推送需回滚的远端状态。

## 7. 停步与回滚锚

- 回滚锚完好：本地 `maintainer-evidence` 可按 §4.7 重置回 `8713ea4eb88b53f74f70f50477143a6fec05d22a`；本步未执行回滚（等 PM 裁定处置路径后按裁定执行，回滚时清单中 8,759＋7＋9 行 outcome 相应回退 `pending` 并在本报告补记回滚一行）。
- 建议处置方向（供 PM／Alex 裁定，Blake 未擅自执行）：
  1. spike-work 前缀 40 件退出同步队列：嵌入仓库由其自身 `.git`＋分支 gitlink 指针承载，盘上文件不逐件入树；清单为此 40 件新设 outcome（如 `embedded-repo`）并在 S1 口径注记中排除 gitlink 前缀与 `.git` 组件路径（S1 盘点管线同样需要此注记，否则每轮复算恒有 36 件假 NOCARRIER）。
  2. 同步脚本加前置守卫：队列路径命中分支 gitlink 前缀或含 `.git` 组件 → 前置断言失败停步（exit 2），不许再静默丢失或替换 gitlink。
  3. 回滚本地尖至锚点后，用修正后队列重跑首轮（预期 synced 8,719、AC7 mismatch 0、AC15 gitlink 原样、NOCARRIER 仅剩冻结后残差）。
- 附带发现（判据缺陷，另报 PM）：AC12 原样脚本的两处 find 锚点（`tad-research-mechanism` 与例外行字符串）在现行 `.gitignore` 中不存在（R1 例外是 `-f` 强加 tracked、`.gitignore` 内无 `!` 例外行），基线时点即不成立；`.gitignore` sha256 至今未变（`3109c530…`），忽略范围实际未漂移。Gate 3 判读 AC12 需 PM 口径。

---

## 续跑（F1 修正后，2026-10-04）

执行步：`tad-evidence-recovery-impl-resume-01`（Blake）；依据：PM 裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-f1-ruling.md`（F1 增补已核销）与 HANDOFF §6 Phase 3「续跑（F1 修正后）」小节。

- **回滚行**：本地尖已按 §4.7 回滚——`git update-ref refs/heads/maintainer-evidence 8713ea4eb88b53f74f70f50477143a6fec05d22a 982e5580…`（带旧值断言）成功，现尖＝锚 `8713ea4e…`；执行版清单首轮回写 outcome 已全量回退：synced 8,759／dropped-by-ruling 7／kept-branch-only 9 → `pending`（sha／commit 同步清空），回退后清单字节数 3,426,326 与 Phase 0 冻结值逐字全等；首轮新尖 `982e5580…` 对象无害保留、未推送状态不变。
- **队列修正行**：按 §4.2 C1 新类回写——以锚尖 `git ls-tree` 实测 gitlink 条目恰 1 条（`spike-work`），命中两类路径（gitlink 前缀下＋含 `.git` 组件）的清单行恰 **40 件**，outcome 置 `embedded-repo`（class 不改、行数不增删），与 §3 差额清单集合一致；修正后同步队列＝**8,719 件**；S1 summary 文末已按写死文本追加「口径增补（2026-10-04，F1）」节（只追加、原文未动，文件 14,450 → 14,985 B）。
- **守卫夹具行**：同步脚本已按 §4.2 C3 加装载体冲突守卫（read-tree 前扫描队列行＋处置表行，命中输出全部命中路径、退出码 2），AC5 原样复跑 PASS、内嵌 python 编译 PASS。/tmp 临时克隆（`/tmp/sync-test-resume`，尖＝锚）夹具结果：① 守卫——队列含 gitlink 前缀下文件 1 件＋含 `.git` 组件路径 1 件时，exit **2**、两件命中全量列出、ref 不动，处置表 gitlink 本体行未误报；② 正常态——普通／CJK＋空格／可执行位（100755）／stale 四件入账，exit 0，新尖父＝锚，keep 在位、drop 消失、gitlink `160000` 原样，清单 outcome 回写正确；③ NO-OP——以新尖为 `--expect-base` 复跑 exit **3**、ref 不动；④ 失败中止——队列含盘上缺失件时 exit **1**、ref 不动。四态全过，许进重跑。
- **续跑断言行**：重跑 exit 0（约 34 秒），新本地尖 **`459ab78f5aa54dc1056522780607dcfeb473c647`**（父＝锚，AC8 PASS），synced **8,719** 件、drop 落地 7 件。同步后四锚（S1 复跑序列逐字＋F1 剔除口径）：**TOTAL_NOCARRIER=14／TOTAL_STALE=0／TOTAL_CARRIED=13,074／TOTAL_BRANCH_ONLY=9**（集合与 keep 的 blob 行逐件合）。AC6 三断言全 PASS（STALE=0；NOCARRIER=14 与同一管线内「盘上集 − 执行版清单路径集」=14 等式成立；BRANCH_ONLY=9=keep blob 行数）；AC7 PASS（queue 8,719＝synced 8,719、mismatch **0**、embedded-repo 恰 40）；AC15 PASS（新尖该路径恰一条 `160000 commit d12b4250…`）；AC4 PASS；12 条 CJK 路径逐件仍 carried（四锚复算中 inter 全匹配、STALE=0 覆盖，名单同 §5）。**NOCARRIER 残差 14 件逐件列名**（全为本链冻结后自产文书与清单 instrument 件，不在执行版清单行内，归看守下一轮）：`.tad/evidence/activation-packages/tad-evidence-recovery-f1-amend-01.md`、`tad-evidence-recovery-impl-p25-01.md`、`tad-evidence-recovery-impl-resume-01.md`、`.tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md`、`2026-10-04-tad-evidence-recovery-f1-amend-note.md`、`2026-10-04-tad-evidence-recovery-impl-p01-note.md`、`2026-10-04-tad-evidence-recovery-impl-p25-note.md`、`.tad/evidence/pm/2026-10-04-evidence-recovery-17items-ruling.md`、`2026-10-04-evidence-recovery-f1-ruling.md`、`2026-10-04-evidence-recovery-first-sync-report.md`（本文件）、`2026-10-04-termination-secret-isolation-check.md`、`.tad/evidence/ralph-loops/TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION_state.yaml`、`.tad/evidence/research/maintainer-evidence-revival/branch-disposition.tsv`、`execution-manifest.jsonl`。
- **推送三值（Phase 4 停步时点）**：本地尖 `459ab78f5aa54dc1056522780607dcfeb473c647`；origin 跟踪尖 `8713ea4eb88b53f74f70f50477143a6fec05d22a`（未推送，未变）；grokbox 侧值**不可测**——2026-10-04 续跑时点三次 `ssh box@grokbox` 均在连接阶段失败（`Connection reset by peer`／`nc: proxy read: Broken pipe`，隧道 CONNECT 阶段被掐签名）。按 §4.5 失败处置与 §8.4（grokbox 不可达 → Phase 4 停步、非实施 FAIL）：未换路、未 VM 直推、未 force-push；本地尖与全部断言成果保留，待隧道恢复后由 PM 决定续推（续推前须先做 §4.5 收敛确认：grokbox 侧 rev-parse 须等于本地新尖）。Phase 5（看守首跑／usage log／COMPLETION）未开工，随 Phase 4 停步一并待续。

## 附录：AC6 四锚断言脚本原文（同步后复算所用，S1 序列同构）

```bash
cd /home/hatch/workspace/yun-sync/TAD
find .tad/evidence .tad/archive -type f -print0 > /tmp/A0.bin
git ls-tree -r -z maintainer-evidence > /tmp/B0.bin
```

```python
import subprocess, collections, json
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
# 断言（HANDOFF §4.2 C6/#3）：STALE==0；BRANCH_ONLY==处置表 keep 的 blob 行数（9，gitlink 不计）；
# NOCARRIER==len(As - 执行版清单路径集)；CARRIED 自洽 len(As)=NOCARRIER+STALE+CARRIED。
# 本轮结果：STALE=0 PASS；BRANCH_ONLY=9 PASS；CARRIED 自洽 13122=44+0+13078 PASS；
# NOCARRIER 等式 FAIL：管线 44 vs 清单外残差 8，差 36＝spike-work .git/**（见 §3）。
```

## 续行停步记（2026-10-04，step `tad-evidence-recovery-impl-push-01`）

隧道恢复后按续跑节续行清单接续 Phase 4：Step 0 断言全过（本地尖 `459ab78f5aa54dc1056522780607dcfeb473c647`、父＝锚、origin 跟踪尖＝锚、隧道 `GB_OK`）；收敛确认 grokbox 侧 `git rev-parse maintainer-evidence`＝`459ab78f…` 与本地尖全等。**但同次前置扫描在 grokbox 检出命中 `.sync-conflict` 恰 1 件**：`.git/logs/refs/remotes/origin/main.sync-conflict-20261004-225943-L64KYDF`（3,898 B；活日志 3,910 B，冲突对象为 grokbox 检出自身 origin/main 远端跟踪 reflog 的 Syncthing 冲突副本，不在本链证据树／分支对象内；VM 侧同扫描零命中）。按 §4.5 第 1 步／§4.7／§8.4 停步报 PM：未推送、未删改冲突文件、Phase 5 未开工；三值维持本地尖 `459ab78f…`／origin 跟踪尖 `8713ea4e…`／grokbox 侧 rev-parse `459ab78f…`（收敛值，非远端实测尖）。停步说明：`.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-push-note.md`，待 PM 裁定冲突件处置与推送放行后按其 §4 续行清单接续。

## 续行二步（2026-10-04，step `tad-evidence-recovery-impl-push2-01`）

PM F4 裁定后以直达指令续行。Step 0 断言全过（仓根、本地尖 `459ab78f5aa54dc1056522780607dcfeb473c647`、父＝锚 `8713ea4e…`、origin 跟踪尖＝锚、隧道 GB_OK）。复扫前置：VM 侧全树 0 命中；grokbox 侧恰 2 件，均为已知 `.git/logs/refs/remotes/origin/main.sync-conflict-20261004-*` 同源 reflog 冲突（冻结不动），`.git` 之外零命中。收敛确认：grokbox 侧 rev-parse＝`459ab78f…` 与本地尖全等。推送经 grokbox 侧 gh 内联 helper 完成：`8713ea4e..459ab78f maintainer-evidence -> maintainer-evidence`。验同尖：VM fetch 后本地尖／origin 跟踪尖／远端实测尖三值全等 `459ab78f…`，AC8∧AC9 合取 PASS。Phase 5：看守脚本 `.tad/scripts/evidence-freshness-check.sh` 与记录 `.tad/evidence/pm/evidence-freshness-log.md` 落盘，首跑 VERDICT=OK（读数见完工说明 `2026-10-04-tad-evidence-recovery-impl-push2-note.md`，含首跑 NOCARRIER 读数与同口径复算差额的如实记述）；usage log 已追加本链引用一行。COMPLETION 已成件，待 Gate 3 双审。
