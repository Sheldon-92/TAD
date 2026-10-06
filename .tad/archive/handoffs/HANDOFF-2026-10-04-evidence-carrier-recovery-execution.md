# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: mixed       # git 载体恢复（plumbing 同步）+ shell/python 脚本 + 看守落地；无 UI、无运行时代码变更
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
required_evidence_manifest:
  - .tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md（本链票，范围四项与红线出处）
  - .tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md（PM 载体裁定：案一＋看守参数＋17 件强制首步）
  - .tad/evidence/research/maintainer-evidence-revival/inventory-summary.md（S1 四锚与复跑命令序列，本链开链复算的唯一口径来源）
  - .tad/evidence/research/maintainer-evidence-revival/inventory-manifest.jsonl（13,082 行逐件清单，执行版清单的母本）
  - Gate 2 dual reviews ×2（待 PM 另派独立会话落盘后回填路径）+ PM 合并裁定
  - COMPLETION-2026-10-04-evidence-carrier-recovery-execution.md (Blake 完工件，落 .tad/evidence/completions/)
tad_scope: full
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-04
**Project:** TAD Framework（证据载体恢复执行链：maintainer-evidence 分支同步恢复＋新鲜度看守落地）
**Task ID:** TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION
**Handoff Version:** 1.0
**Ticket:** `.tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md`
**Ruling:** `.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`（采纳案一；看守参数、17 件强制首步以裁定原文为准）
**Upstream chain:** 证据复活链（研究轨已收口）——S1 盘点／S2 Decision Brief（案一）／RG3 PASS／RG4＋COMPLETION，见 `.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md`

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 待 PM 另派两独立会话双审（tech／fit 两路）落盘后回填本节；双审与 PM 合并裁定转 PASS 前，Blake 不得开工。

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅（待双审确认） | §4 同步架构（plumbing 临时索引）＋推送路径（grokbox 通道）＋看守三件齐备 |
| Components Specified | ✅（待双审确认） | 逐项到文件：同步脚本、看守脚本、执行版清单、处置表、首轮报告、看守日志（§7） |
| Functions Verified | ✅（待双审确认） | MQ2：git plumbing 命令族与 S1 复跑管线均已在设计步实跑验证（rev-parse／ls-tree／cat-file／hash-object） |
| Data Flow Mapped | ✅（待双审确认） | MQ3 数据流：manifest → 执行版清单 → 临时索引 → 分支提交 → grokbox 推送 → origin；看守：复算管线 → 四锚 → 日志行 |

**Gate 2 结果**: ⏳ **PENDING** — 待双审落盘＋PM 合并裁定。裁定转 PASS 后 Blake 独立根据本文档完成实施；本文档附录 A 的 17 件意见是**草案**，不构成核准（核准是 Phase 1 的 PM 动作，见 §6 Phase 1 硬前置）。

> **Process Gate 2 = dual reviews on disk** (P2 tax-cut). PASS ⇔ two independent artifacts under `.tad/evidence/reviews/` (P0=0 or sanctioned). Do **not** write a dispatch lock that waits for a human chat string `/gate 2`.

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节（含票、裁定、S1 summary 全文）
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 特别确认：Phase 1 的 PM 核准是硬前置——核准文件不在盘，Phase 2 起一步都不许动
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

把自 2026-09-06 起停摆的 maintainer-evidence 证据载体恢复为常态机制，四件事：

1. **开链复算＋执行版清单**：按 S1 summary 的复跑命令序列重算四锚，把 S1 manifest 增补为带 outcome 列的执行版清单并冻结为同步队列。
2. **17 件逐件处置**：branch-only 16 件＋gitlink 1 件逐件定「保留／弃置」，经 PM 核准后才许动载体（强制首步）。
3. **同步脚本＋首轮全量补同步**：写一个可重跑的同步脚本，把队列内 8,706 件 no-carrier＋5 件 stale-content（以开链复算为准）逐件入 maintainer-evidence 分支，逐件当场重算内容 sha 销账；同步后复算断言收尾；经 grokbox 通道推送 origin 并验同尖。
4. **新鲜度看守落地**：看守脚本＋复算记录日志落盘并首跑一次，参数逐字认 PM 裁定二。

### 1.2 Why We're Building It

两树（`.tad/evidence/`、`.tad/archive/`）被 `.gitignore` 整树忽略是 F-18 发行瘦身的有意设计，替代载体就是 maintainer-evidence 分支。该分支尖停在 2026-09-06 后约四周无人察觉，8,706 件证据（46,878,109 B）无任何 git 载体——盘损即永久丢失，且任何 status 类检查都看不见（「忽略树盲视」，见 Project Knowledge）。研究链已裁定采纳案一（恢复分支同步＋脚本化＋看守）；本链是该裁定的执行部分。

### 1.3 🆕 Intent Statement（意图声明）

- **做完的世界**：盘上每件证据要么已在 maintainer-evidence 分支有逐字节相同的载体，要么是同步时点后新增、且数量在看守阈值内可解释；分支停摆会在下一条链收口或月度补跑时被机械发现并报警，不再靠偶然自查。
- **不靠自觉**：同步是脚本＋同步后断言，看守是脚本＋固定周期＋报警行格式；没有一步依赖「记得做」。
- **逐件销账**：队列每一行最终都有 outcome 与当场重算的 sha；不许整批「已同步」一笔带过。

### 1.4 非范围（明确不做）

- 不改 `.gitignore`；不动 F-18/SC3 判据；不回退主仓已 tracked 的 3 件例外（清单见 §2.2）。
- 不处置任何证据的**内容对错**（本链只管载体，不管内容质量）。
- 不删除盘上任何文件；不动 main 分支与其他分支；不重写 git 历史。
- 不为关键件开主仓直读路（裁定三的重议触发未达，不在本链）。

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

命中 `patterns/ac-verification.md` 两条与 `patterns/shell-portability.md` 一条（均 2026-10-04 由上游链落盘，与本链直接相关）。

### 步骤 2：历史经验摘录

**① Ignored-tree blindness in inventory claims**（`patterns/ac-verification.md:707`）
> Second instance, same day: TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL — the evidence carrier branch stalled on 2026-09-06 and 8,706 files (46.9 MB) sat without any git carrier for ~4 weeks, invisible to every status-based check; surfaced only by the R1 self-review's explicit disk enumeration (S1 four anchors: NOCARRIER=8706／STALE=5／CARRIED=4355／BRANCH_ONLY=16).
- 对本链的含义：验收只认盘面枚举复算（四锚），不认 `git status` 干净、脚本 exit 0 这类状态信号。

**② AC 断言逐项化（per-term 合取）**（`patterns/ac-verification.md:122` 镜像实例）
> a combined `grep -cE` tally plus a threshold also false-PASSes — one term repeated N times satisfies a "≥N distinct terms" check … Rule of thumb: per-term assertion guards both directions.
- 对本链的含义：§9.1 每条 AC 的多词断言一律逐词独立 grep 合取；脚本与报告的自检同理（例：四锚断言逐锚比对，不许合并计数）。

**③ git 默认 quotepath 转义制造路径集伪差集**（`patterns/shell-portability.md:316`）
> 任何 git 路径集与盘上路径集之间的差集/交集运算，一律 `git ls-tree -z`（或 `-c core.quotepath=false`）与 `find -print0` 成对走 NUL 管线；分支集只取 `type=blob` 条目，gitlink 单独注记、不入计数。
- 对本链的含义：同步与复算全程 NUL 分隔管线＋argv 传参；12 条 CJK 路径是现成的真负控样本（同步后必须逐件 carried）。

**原则层**（`.tad/project-knowledge/principles.md`）：Measure Before Optimizing——先复算四锚再动手，队列以复算为准不以旧快照为准；本链全程适用。

### Blake 确认

- [ ] 已读上列三条并理解对本链的含义（在 COMPLETION 中逐条回指）

---

## 2. Background Context

### 2.1 Previous Work

- **F-18／SC3（红线出处，逐字对过原件）**：审计 `.tad/active/designs/AUDIT-20260816-framework-health.md` F-18——发行路径下载整棵工作树 30.19 MB、实际只需 4.54 MB，evidence 占仓 67%。EPIC `.tad/active/epics/framework-health-repair/EPIC.md` Phase 4 Scope 原文：「将 `.tad/evidence/` 与 `.tad/archive/` 移出 `main` 分支工作树（保留于 orphan 分支以维持可追溯），不做 git 历史重写」；SC3 主判据：`git ls-files '.tad/evidence/*' | wc -l` == `0` 且 archive 同（2026-09-06 由 commit `98b7e396` 达成；其后 R1 链有 3 件经裁定的单批例外，见 §2.2）。`.gitignore:120-123` 原文即两树忽略＋维护者注记（本地 `git show maintainer-evidence:<path>` 读法）。
- **2026-09-06 末次同步**：分支尖提交 `8713ea4e` “chore(evidence): sync 134 post-phase4 evidence and archive records to maintainer-evidence”，手工 chore 动作，无脚本留存（Brief 实查：`.tad/hooks/`、`.tad/scripts/`、`tad.sh` 三处均无 maintainer-evidence 同步机制可复用）。
- **证据复活链（2026-10-04，本链上游）**：S1 盘点四锚（见 §2.2）；S2 Brief 三案比较推荐案一，机制要点：显式清单/`-f`、同步后四锚断言、不许绿着空转；Q4 定死执行输入形态（manifest 按 class 分三队、执行前复算增补、逐件 outcome＋当场 sha）。RG3 Critic PASS（0.875）；PM 裁定采纳案一并定死看守参数与 17 件强制首步。

### 2.2 Current State（设计步 2026-10-04 亲跑基线）

| 基线项 | 值 | 取法 |
|---|---|---|
| maintainer-evidence 本地尖 | `8713ea4eb88b53f74f70f50477143a6fec05d22a`（2026-09-06） | `git rev-parse maintainer-evidence` |
| origin/maintainer-evidence | 同上（同尖） | `git rev-parse origin/maintainer-evidence` |
| main 尖 | `5619b09556863b6d2587d6fa71b46e71bb8b1174` | `git rev-parse main` |
| main 两树 tracked | 恰 3 件：`.tad/archive/next/NEXT-completed-through-20261004.md`、`.tad/evidence/pm/downstream-versions.md`、`.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md` | `git ls-files -- .tad/evidence/ .tad/archive/` |
| `.gitignore` 指纹 | sha256 `3109c53025688cc5ad6d1d8f4b5b908b4f88d0c1db7358a1f96e58be0081bfab` | `sha256sum .gitignore` |
| S1 四锚（as_of 2026-10-04T22:16Z） | NOCARRIER=8706／STALE=5／CARRIED=4355／BRANCH_ONLY=16；盘上集 A=13,066；manifest 13,082 行 | S1 summary |
| 待入载体队列（S1 时点） | no-carrier 8,706 件（46,878,109 B）＋stale-content 5 件（清单见 S1 summary「stale-content 清单」节，全量 5 件） | S1 summary |
| gitlink 件 | `.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work`，mode 160000，指向 commit `d12b42505f2dfd2b5d8f5de51cc6e3d0a43aa0fa`，不入四锚 | S1 summary 方法节 |
| VM GitHub 凭据 | 无（R1 收口实测：VM 直推认证失败；经 grokbox 以 gh 登录态推送成功） | 本仓收口记录／MEMORY |

注：S1 时点后盘上仍在新增件（本链自身的设计与评审产物亦在其中），故开链复算的锚值预期与 S1 略有差额——差额必须逐件以「时点后新增」解释（Phase 0），不许改首跑口径。

### 2.3 Dependencies

- **PM 核准（Phase 1）**：17 件处置的 PM 裁定文件是 Phase 2–5 的硬前置。
- **grokbox 通道（Phase 4）**：`ssh box@grokbox` 可达＋grokbox 侧 gh 登录态有效＋Syncthing 已把本地 `.git` 收敛到 grokbox 检出（`/home/box/云同步/TAD`）。三者任一不成立，Phase 4 停步报 PM，不许改走 VM 直推。
- **并发写盘**：执行期间其他链仍可能往两树落盘；冻结口径（§4.2）已把这类新增件排除在队列外，差额在 Phase 3 断言时逐件列名解释。

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 开链复算**：实施第一步按 S1 summary「复跑命令序列」逐字重算四锚（剔除规则照 summary：盘点产物 2 件剔除、枚举后新增件按新增解释），结果记入 Phase 0 完工记录；与 S1 锚的差额逐件归因（时点后新增／本链自产），不许出现未解释差额。
- **FR2 执行版清单**：以 `inventory-manifest.jsonl` 为母本生成执行版清单 `.tad/evidence/research/maintainer-evidence-revival/execution-manifest.jsonl`：母本 13,082 行全量带入；复算时点盘上新增而母本无的行按同一管线补算 class 后**新增行追加**（差集计算与清单追加同样适用 S1 的 EXCL 剔除规则：盘点产物 2 件 `inventory-manifest.jsonl`、`inventory-summary.md` 不入清单、不入队列，仅在四锚比对中按 summary 口径处理——Gate 2 增补 A3）；每行补 `outcome` 字段（初始 `pending`）。母本文件本身只读、不许改。清单冻结后即为同步队列唯一来源。
- **FR3 17 件逐件处置**：对 branch-only 16 件＋gitlink 1 件逐件形成「保留／弃置＋理由」（草案见附录 A），落 `.tad/evidence/research/maintainer-evidence-revival/branch-disposition.tsv`（列：path／class／decision／reason／ruling_ref）；17 行的 decision 必须全部经 PM 裁定文件确认或改判后才定稿，**PM 裁定文件不在盘，Phase 2 起禁止启动**（硬前置，§6 Phase 1）。
- **FR4 同步脚本**：落 `.tad/scripts/sync-maintainer-evidence.sh`，行为规格见 §4.3：输入＝执行版清单队列（class ∈ {no-carrier, stale-content} 且 outcome=pending 的行）＋处置表；机制＝临时索引 plumbing（不用朴素 `git add`）；路径全程 NUL/argv 安全管线；逐件 `hash-object -w` 当场算 sha；幂等（盘面无变化时重跑产出 NO-OP 报告且不产生空提交）；任一件失败即整体中止且分支 ref 不动。
- **FR5 首轮全量补同步**：以 FR4 脚本执行首轮同步，队列逐件销账回写执行版清单（outcome=synced＋sha＋commit）；随后按 S1 管线复算四锚断言：STALE=0、NOCARRIER 恰等于冻结后新增件数（逐件列名）、BRANCH_ONLY 恰等于处置表 keep 的 blob 行数（gitlink 不计）；断言结果落首轮报告 `.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`（日期段以实际执行日为准）。
- **FR6 推送**：首轮同步提交经 grokbox 通道推送 origin 的 maintainer-evidence 分支（路径写死见 §4.5），推送后验远端尖与本地尖同值并回写报告。
- **FR7 新鲜度看守**：落 `.tad/scripts/evidence-freshness-check.sh`＋记录文件 `.tad/evidence/pm/evidence-freshness-log.md`，参数逐字认裁定二（§4.4）；本链收口前首跑一次并落首行记录（预期 VERDICT=OK）。
- **FR8 逐件 sha 凭据**：入载体时当场以 `git hash-object` 重算内容 sha 记入执行版清单；不许以 manifest 的 bytes 字段充当内容凭据（票红线）。

### 3.2 Non-Functional Requirements

- **NFR1 路径字节安全**：全程 `find -print0`／`git ls-tree -z`／argv 数组传参；含 CJK（12 条已知）、空格、引号的路径不得丢件、错位或被转义污染（quotepath 条目，Project Knowledge ③）。
- **NFR2 围栏可验**：git 写操作只许 §4.6 围栏内形态；main 尖、`.gitignore` 指纹、3 件例外在实施全程逐项可复核不变（AC10–AC12）。
- **NFR3 凭据卫生**：任何凭据不落盘、不进脚本、不进报告；推送只许借 grokbox 既有 gh 登录态经内联 credential helper 使用，用完不留配置（脚本内不得出现 `git config credential.helper` 持久化写法）。
- **NFR4 可重放**：同步脚本与看守脚本连跑两次，除时间戳／记录追加行外结果一致；同步脚本第二跑必须 NO-OP。
- **NFR5 原子性**：分支 ref 只在全部队列件成功写入对象库并组装完树后一次性前移（update-ref 为最后一步）；中途失败分支保持旧尖，盘面与 main 零影响。

### 3.3 Optimization Target (Optional)

无。首轮以正确与可验优先；8,711 件量级的 plumbing 管线在本机为分钟级，不做性能优化。

---

## 4. Technical Design

### 4.1 Architecture Overview

同步不用工作树检出分支（避免污染 main 工作区与 Syncthing 面），用 **git plumbing＋临时索引**：以分支现尖为基线树读入临时索引 → 逐件把盘上内容写成 blob 并以 cacheinfo 更新索引条目 → write-tree → commit-tree（父＝旧尖）→ update-ref 一次性前移。删除方向同理由处置表驱动（force-remove 指定行），机制上不存在「镜像删除」——处置表未点名的分支条目一律原样保留。

```text
inventory-manifest.jsonl ──(Phase 0 复算增补)──► execution-manifest.jsonl（冻结队列）
branch-disposition.tsv（Phase 1，PM 核准）──┐
                                            ▼
sync-maintainer-evidence.sh： GIT_INDEX_FILE=<tmp>
  read-tree maintainer-evidence
  队列行： hash-object -w ─► update-index --cacheinfo <mode>,<sha>,<path>
  弃置行： update-index --force-remove <path>
  write-tree ─► commit-tree -p <旧尖> ─► update-ref refs/heads/maintainer-evidence
                                            │
  Phase 3 断言： S1 管线复算四锚 vs 期望（§6 Phase 3）
                                            │
  Phase 4 推送： ssh box@grokbox（gh 登录态）push origin maintainer-evidence ─► 验同尖
                                            │
  Phase 5 看守： evidence-freshness-check.sh ─► evidence-freshness-log.md 追加行
```

### 4.2 Component Specifications

**C1 执行版清单** `.tad/evidence/research/maintainer-evidence-revival/execution-manifest.jsonl`
- 行形：母本行全字段（path／tree／class／bytes／date_bucket）＋`outcome`（pending→synced／kept-branch-only／dropped-by-ruling／embedded-repo）＋`sha`（synced 行必填，40 位 hex）＋`commit`（synced 行必填）。
- 追加行：复算时点 A 集减母本路径集的差集逐件补算 class 后追加，行内注 `appended_at_phase0: true`。
- 冻结：Phase 0 结束即冻结；Phase 1–5 只回写 outcome／sha／commit，不增删行（执行期间盘上再新增件不入本链队列，留待看守下一轮——差额解释规则据此成立）。唯一例外：§4.7 同名改写件以新增行追加进清单（行内注 `appended_at_phase3: true`），不算破冻；AC1 的计数式只数 `appended_at_phase0` 行，Phase 3 追加行不污染其口径（Gate 2 增补 A5）。
- **outcome 类 `embedded-repo`（F1 增补，2026-10-04；依据 PM 裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-f1-ruling.md`）**：专记两类路径——(i) 位于分支任一 gitlink 条目（mode 160000）路径前缀之下的盘上文件；(ii) 路径任一组件为 `.git` 的文件。此类路径**不是无载体证据**：其内容由所指嵌入仓库自身的 git 结构承载、分支以 gitlink 指针引用该仓库（指针本体按 C2 处置表 gitlink 行与 AC15 保全），逐件入树在结构上不可能、也不应该（`.git` 组件路径 git 索引不接受；工作文件入树会挤掉指针本体——首轮实测，见首轮报告 §2–§3）。
- **`embedded-repo` 计数口径（写死）**：此类行 outcome 直接置 `embedded-repo`，**不入同步队列**（FR4 队列条件 class ∈ {no-carrier, stale-content} 且 outcome=pending——此类行 outcome 非 pending，天然在队列外；其 class 字段保留 Phase 0 复算原值不改）；**不计 TOTAL_NOCARRIER**——四锚复算（Phase 0／Phase 3／看守 C5 同适用）的盘上集 A 在算差集前，除既有 EXCL 2 件外另剔除此两类路径，与清单侧「盘上集减清单路径集」同口径，否则每轮复算恒生此类假差额。首轮实测此类共 40 件（`.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work/` 前缀下 4 件工作文件＋36 件 `.git/**` 内部文件，全量清单见首轮报告 §3），续跑时由 Phase 3 续跑小节回写 outcome。
- **盘点口径注记（落点与文本写死）**：S1 summary（`.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md`）文末由续跑 Blake 追加一节，标题 `## 口径增补（2026-10-04，F1）`，正文逐字为：「复跑命令序列的盘上集 A 在算四锚前，除既有 EXCL 2 件外，另剔除两类路径：(i) 分支 gitlink 条目路径前缀之下的盘上文件；(ii) 路径任一组件为 `.git` 的文件。此类路径记 outcome 类 `embedded-repo`，不入同步队列、不计 TOTAL_NOCARRIER——其内容由嵌入仓库自身 git 结构与分支 gitlink 指针承载。依据：PM 裁定 `.tad/evidence/pm/2026-10-04-evidence-recovery-f1-ruling.md` 与 HANDOFF §4.2 C1（F1 增补）。」§7 FORBIDDEN 对 S1 summary 的只读约束开此唯一例外：只许文末追加本节，不许改原文任何一行。

**C2 处置表** `.tad/evidence/research/maintainer-evidence-revival/branch-disposition.tsv`
- 恰 17 数据行（branch-only 16＋gitlink 1，gitlink 行 class 记 `gitlink`）；列：`path`、`class`、`decision`（keep／drop）、`reason`、`ruling_ref`（PM 裁定文件路径，定稿后回填；草案阶段该列记 `PENDING-PM`）、`origin_path`、`origin_sha256`（裁定 2 对照列，仅 drop 行必填，见下两条）。
- 裁定 2 对照（Gate 2 增补 A1）：每件 drop 件在 Phase 1 定稿时留一行对照——`origin_path`＝该件内容原件的现行在册路径，`origin_sha256`＝定稿时对该原件当场重算的 sha256；Phase 3 对账回指该对照复核（见 §6 Phase 3 步骤 2 与 AC3）。
- 自动转保留（裁定 2 保险）：任一 drop 件在定稿或对账时点找不到在册原件（`origin_path` 不存在或不可读），该件 decision **自动转 keep**，并在 Phase 1 定稿记录与首轮报告中逐件报 PM——不许在无对照的情况下弃置。

**C3 同步脚本** `.tad/scripts/sync-maintainer-evidence.sh`
- 形态：bash 入口＋内嵌 python3 驱动（`PYTHONDONTWRITEBYTECODE=1`；S1 管线已证此形态在本机可靠；路径经 argv 数组进 git 子进程，禁止 shell 字符串拼路径）。
- 输入：执行版清单路径、处置表路径（参数或同仓默认路径）；保护集＝处置表 decision=keep 的行＋gitlink 行——脚本对这两类路径**永不**生成删除或覆盖动作（gitlink 根本不入索引操作面）。
- 步骤（§4.1 图）：前置自检（仓根断言 `git rev-parse --show-toplevel` 等于本仓绝对路径；分支尖期望基线断言：脚本接受 `--expect-base <sha>` 参数并断言当前分支尖与之相等——首跑取 Phase 0 记录尖、再跑（NO-OP 复跑／§4.7 补跑）取上轮产出尖（以运行记录登记值为准）；未给参数时默认断言当前尖为 Phase 0 记录尖或其由本脚本产生的后继提交，不一致即停——Gate 2 增补 A4；**载体冲突守卫（F1 增补）：队列行与处置表任一路径命中下列两类即前置断言失败——(i) 位于分支现尖任一 gitlink 条目（`git ls-tree` mode 160000）路径前缀之下（前缀本体路径本身除外，其为处置表 gitlink 行、归保护集管辖）；(ii) 路径任一组件为 `.git`。断言形态：脚本在 read-tree 之前逐行扫描两输入，命中即输出全部命中路径清单并以退出码 2 停步（区别于失败中止的非零码：2 专记守卫拦截）；不许静默跳过、不许降级为警告续跑**）→ 临时索引 read-tree → 队列逐件 hash-object -w＋cacheinfo（mode：盘上可执行位→100755，否则 100644）→ 弃置行 force-remove → write-tree；若新树与旧尖树相同，输出 `NO-OP` 并以约定退出码 3 结束（不是成功绿：调用方须在报告中如实记 NO-OP）→ commit-tree → update-ref → 输出新尖与逐件结果摘要（件数、字节数、新尖 sha）。
- 失败：任一子进程非零 → 立即中止、不执行 update-ref、退出码非零、已写 blob 保留（无害游离对象）；报告记失败行 path 与 stderr 摘要。

**C4 首轮报告** `.tad/evidence/pm/2026-10-04-evidence-recovery-first-sync-report.md`（日期段随执行日）
- 必含节：复算锚（Phase 0 与 Phase 3 两组四锚并列）、队列件数与销账小计、断言逐项结果（STALE／NOCARRIER 差额逐件列名／BRANCH_ONLY 与 keep 数对账）、新分支尖与父提交、推送验证值（本地尖／ls-remote 值／fetch 后 origin 跟踪值三值并列）。

**C5 看守脚本** `.tad/scripts/evidence-freshness-check.sh`
- 行为：自包含复算四锚（管线与 S1 summary 复跑序列同口径，剔除盘点产物 2 件与 `embedded-repo` 两类路径——§4.2 C1 计数口径，F1 增补）；读分支尖提交时间算 TIP_AGE_DAYS；按 §4.4 阈值判定；向 C6 追加一行；报警时退出码非零并在 stdout 明示 `ALARM`（供 PM 巡查面捕获）。阈值判定须以 bash `[ … -gt 100 ]`／`[ … -gt 21 ]` 形态落地（Gate 2 增补 A8；AC14 的字面 grep 以此为准，不许以内嵌 python 的等价比较式替代）。

**C6 看守记录** `.tad/evidence/pm/evidence-freshness-log.md`
- 文件头固定记：参数（阈值／周期／责任人，逐字抄裁定二）、报警行格式、历次运行表头。
- 运行行格式（写死）：`- <YYYY-MM-DD> CHECK NOCARRIER=<n> STALE=<n> CARRIED=<n> BRANCH_ONLY=<n> TIP=<sha12> TIP_AGE_DAYS=<d> VERDICT=OK`
- 报警行格式（写死）：`- <YYYY-MM-DD> ALARM NOCARRIER=<n> STALE=<n> CARRIED=<n> BRANCH_ONLY=<n> TIP=<sha12> TIP_AGE_DAYS=<d> TRIGGER=<NOCARRIER|TIP_AGE|BOTH> — PM 当日立处置票并向用户播报`

### 4.3 Data Models

无新数据模型；执行版清单与处置表的行形即 C1／C2，两者均为本链工作文件（在 evidence 树内，其最终版于下一轮同步时入分支——与 S1 manifest 不入自身枚举同例，Gate 3/4 的验收对象是盘上件）。

### 4.4 看守参数（逐字认裁定二，不许改写）

- **阈值**：按 S1 summary 的复跑命令序列重算四锚——`TOTAL_NOCARRIER` 超过 **100** 件，或分支尖最新提交距复算日超过 **21 天**，任一命中即判「停摆报警」：PM 当日立处置票并向用户播报，不许只记不报。
- **周期**：每条 TAD 链收口时必跑一次；当月无链收口时，PM 在月度自查中补跑一次。
- **责任人**：TAD PM。看守不依赖任何执行者自觉，复算与判定都是 PM 动作。

### 4.5 推送路径（写死，含依据）

- **依据**：本 VM 无 GitHub 凭据——R1 状态面收口链实测 VM 直推认证失败、SSH 22/443 经代理均不通；同一批六笔提交改经 grokbox 以其 gh 登录态（Sheldon-92）＋内联 credential helper 推送成功，远端尖经核对一致。本链沿用此已证路径，不新开通道。
- **执行形态**（Phase 4 逐步）：
  1. 同步收敛确认：`ssh box@grokbox "cd /home/box/云同步/TAD && git rev-parse maintainer-evidence"` 须等于本地新尖；不等则等 Syncthing 收敛后复查（间隔复查，不许在 grokbox 侧手工补提交）；若发现 `.sync-conflict` 文件，停步报 PM。
  2. 推送：`ssh box@grokbox "cd /home/box/云同步/TAD && git -c credential.helper='!gh auth git-credential' push origin maintainer-evidence"`（推送的是分支 ref，grokbox 检出停在 main 不影响）。
  3. 验证：VM 侧 `git fetch origin` 后 `git rev-parse origin/maintainer-evidence` 等于本地尖，三值（本地尖／origin 跟踪尖／首轮报告记录值）并列记入报告。
- **失败处置**：grokbox 不可达或 gh 登录态失效 → 停步报 PM（登录态恢复属人机动作）；不许尝试 VM 直推、不许把任何凭据写入脚本/配置/报告。

### 4.6 git 写操作围栏（AC 可验形态）

本链授权的 git 写操作**只有**下列四类，其余一律禁动：

| # | 授权写操作 | 验法 |
|---|---|---|
| W1 | 向对象库写 blob（hash-object -w）、临时索引操作（GIT_INDEX_FILE 指向 /tmp 下文件） | 脚本正文只出现这两类与 read-tree/write-tree/commit-tree/update-ref(仅本分支） |
| W2 | `update-ref refs/heads/maintainer-evidence`（含回滚时的同 ref 写，见 §4.7） | `git reflog maintainer-evidence` 条目与各 Phase 报告记录逐条对账 |
| W3 | 经 grokbox 向 origin 推送 maintainer-evidence 分支（§4.5） | 远端尖与本地尖同值（AC9） |
| W4 | 工作文件仓内落盘：§7 CREATE 清单内文件（脚本两件落 `.tad/scripts/` 只落盘；其入 main 的提交不在本链授权内，属 PM 收口动作，见 §10.3 裁量点） | `git status --porcelain` 中 main 跟踪文件零修改；未跟踪项 ⊆ §7 清单 |

**禁动清单**：main 分支 ref 与其一切提交；其他任何分支；`.gitignore`（指纹基线见 §2.2）；main 已 tracked 3 件例外的内容与跟踪状态；盘上两树既有文件的删除或改写（同步只读盘）。

### 4.7 风险与回滚

- **首轮同步失败回退**：update-ref 前失败＝分支未动，无需回退，修因后重跑（脚本幂等）。update-ref 后、推送前发现问题：`git update-ref refs/heads/maintainer-evidence 8713ea4eb88b53f74f70f50477143a6fec05d22a` 即回到旧尖（游离 blob/commit 无害保留），执行版清单 outcome 相应回退为 pending 并在报告记回滚一行。
- **推送后发现问题**：**不许 force-push**（不在本链授权）；停步报 PM，由 PM 裁定前向修复（追加更正提交）或授权回滚。
- **推送失败**：见 §4.5 失败处置；本地尖保留，链停在 Phase 4 待 PM/用户处理登录态，不算实施失败。
- **执行期间盘面新增件**：不入队（冻结口径），Phase 3 断言以「差额＝冻结后新增件逐件列名」解释；若新增件中出现队列路径同名件被改写（stale 化），断言 STALE 项会非零——此时把该件以新增行追加进执行版清单并补跑一轮同步（仅该件），报告记明。
- **Syncthing 冲突**：Phase 4 前置检查命中 `.sync-conflict` 即停步报 PM，不许自行删改冲突文件。

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

#### 搜索证据
- 上游 Brief 已实查并经本步复核口径：仓内现无任何 maintainer-evidence 同步脚本（`.tad/hooks/`、`.tad/scripts/`、`tad.sh` 三处无同步机制）；2026-09-06 同步为手工 chore 提交（尖提交信息实查：`chore(evidence): sync 134 post-phase4 evidence and archive records to maintainer-evidence`）。
- 可复用资产：S1 summary 的复跑命令序列（四锚管线，本链 Phase 0 与看守脚本的口径母本）；`.tad/scripts/scan-downstream-versions.sh`（R1 链落盘的脚本形态先例：bash＋自包含＋可重放）。

#### 决策说明
同步机制从零写，但枚举/复算口径不新造——全程沿 S1 已三方复核过的管线，避免第二套口径产生伪差（quotepath 教训）。

### MQ2: 函数存在性验证

#### 函数清单
- git plumbing 命令族 `read-tree`／`update-index --cacheinfo`／`write-tree`／`commit-tree`／`update-ref`／`hash-object`：本步设计期间已实跑同族只读命令（`rev-parse`／`ls-tree -z`／`cat-file -s`／`log`／`hash-object` 口径见 S1 管线），命令面在位；写形态由 Gate 3 在脚本正文与 reflog 双向核。
- grokbox 通道：`ssh box@grokbox` 与 gh credential helper 形态与 R1 已证推送命令逐字同构（§4.5）。

### MQ3: 数据流完整性

#### 数据流对照表
| 源 | 变换 | 汇 | 校验点 |
|---|---|---|---|
| 母本 manifest（13,082 行） | Phase 0 复算增补＋outcome 列 | 执行版清单（冻结） | 行数对账＋差额逐件归因（AC1/AC2） |
| 执行版清单队列行 | hash-object -w 当场 sha | 分支新树条目 | 逐件 sha 与分支 blob sha 全量对账（AC7） |
| 处置表（PM 核准） | keep 保护／drop 删除 | 分支新树 | BRANCH_ONLY 后值＝keep 的 blob 行数（AC6） |
| 本地分支新尖 | grokbox 推送 | origin 分支尖 | 三值同尖（AC9） |
| 四锚复算 | 阈值判定 | 看守日志行 | 行格式与参数逐字（AC13/AC14） |

#### 数据流图
见 §4.1 图。

### MQ4: 视觉层级

N/A——本链无 UI、无用户可见界面产物；「观感」验收点为零，Gate 4 以盘面复算为准。

### MQ5: 状态同步

#### 状态存储位置
- 分支状态：`refs/heads/maintainer-evidence`（本地）与 origin 同名 ref；状态转移全程记首轮报告与 COMPLETION。
- 队列状态：执行版清单 outcome 列（单写者＝实施 Blake；Gate 3 只读复核）。

#### 状态流图
`8713ea4e（旧尖）` ──Phase 3──► `新尖（父=8713ea4e）` ──Phase 4──► `origin 同尖` ──Phase 5──► `看守首行 VERDICT=OK`

---

## 6. Implementation Steps（分Phase）

> 串行执行，Phase 间不得跳步；Phase 1 未定稿（含 PM 裁定文件落盘）前，Phase 2 起一律 BLOCKED。每 Phase 完工在 COMPLETION 草稿中逐节记证据指针，最终随 Phase 5 一并定稿（COMPLETION 模板认仓内惯例，含 KA／Friction／Evidence Checklist／Provenance 四节）。

### Phase 0: 开链复算＋执行版清单冻结

#### 交付物
- Phase 0 完工记录（落 COMPLETION 草稿首节或独立小结 `.tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md`）：两组四锚（S1 值／复算值）并列、差额逐件归因表。
- 执行版清单 C1（冻结版）。

#### 实施步骤
1. 仓根断言：在 `/home/hatch/workspace/yun-sync/TAD` 执行，`git rev-parse --show-toplevel` 等值断言通过才继续。
2. 逐字跑 S1 summary「复跑命令序列」（剔除规则照 summary 原文），得复算四锚。
3. 差额归因：A 集与母本路径集做差（NUL 管线），新增件逐件列名并归类（上游链自产／他链新增／本链自产）；归类不出的件停步报 PM。差集计算先按 S1 口径剔除盘点产物 2 件（EXCL：`inventory-manifest.jsonl`、`inventory-summary.md`），2 件不入归因表、不入清单、不入队列，仅在四锚比对中按 summary 口径处理（Gate 2 增补 A3）。
4. 生成执行版清单：母本全量带入＋差集补算 class 追加行＋outcome 列全置 pending；行数对账（总行数＝13,082＋追加行数）写入完工记录后冻结。

#### 验证方法
AC1、AC2（§9.1）。

### Phase 1: 17 件处置定稿（硬前置）

#### 交付物
- 处置表 C2 定稿（17 行 decision 全部落定，ruling_ref 回填）。
- 第 16 件核查备案件：`.tad/evidence/pm/<执行日>-termination-secret-isolation-check.md`（Blake 只读核查产物：核查人／核查方法／结论，不引疑似凭据原文；Phase 1 定稿记录回指此路径——裁定 3，Gate 2 增补 A2）。
- PM 裁定文件（PM 落盘，非 Blake 产物）：`.tad/evidence/pm/<执行日>-evidence-recovery-17items-ruling.md`，逐件记保留／弃置（可改判附录 A 草案，改判须附理由）。

#### 实施步骤
1. Blake 以附录 A 草案为底生成处置表（decision 先填草案值、ruling_ref=PENDING-PM），并对附录 A 第 16 件（termination-secret-isolation.json）在本步做**只读内容检查**（`git show maintainer-evidence:<path>`，模式扫描＋人工目检），核查结果写成书面备案件落 `.tad/evidence/pm/<执行日>-termination-secret-isolation-check.md`（记核查人、核查方法（模式扫描范围＋人工目检范围）、结论（有无真实凭据迹象）；不许引用任何疑似凭据原文），并在 Phase 1 定稿记录中回指备案件路径（裁定 3，Gate 2 增补 A2）；若核出真实凭据迹象：立即停手报 PM，**该件 decision 悬置、其余 16 件照常推进**，且该件在 PM 另行裁定前**不许进入任何载体（分支、主仓、同步清单均不许）**。
2. 把处置表与内容检查结论交 PM；**等待 PM 裁定文件落盘**（等待期间不许做 Phase 2 任何预备动作之外的载体动作；脚本可以先写，但不许对真实队列试跑）。
3. 裁定落盘后按裁定回填处置表定稿（decision 与裁定不一致处以裁定为准并留痕）。回填时同步落裁定 2 对照：每件 drop 件填 `origin_path`／`origin_sha256`（对原件当场重算），任一件找不到在册原件即按 §4.2 C2 的自动转保留规则转 keep 并在定稿记录中报 PM。

#### 验证方法
AC3、AC4、AC15、AC16（§9.1）。

### Phase 2: 同步脚本

#### 交付物
- `.tad/scripts/sync-maintainer-evidence.sh`（规格 §4.2 C3，只落盘）。

#### 实施步骤
1. 按 C3 规格实现；路径处理全程 NUL/argv；脚本头部注释写明输入、退出码语义（0=已同步／3=NO-OP／其他非零=失败）与围栏声明。
2. 自测（§8.2 的 fixture 与负控全过才算完工）：在临时克隆（`git clone` 本仓到 /tmp）内以小型假队列试跑——含 CJK 路径件、空格路径件、可执行位件各至少 1；验树内容逐字节一致、第二跑以 `--expect-base` 传第一跑产出尖并验 NO-OP（退出码 3）、人为制造一件 hash 失败时 ref 不动。

#### 验证方法
AC5（§9.1）＋§8.2 自测证据（COMPLETION 附命令与输出摘要）。

### Phase 3: 首轮全量补同步＋断言

#### 交付物
- 分支新尖（父＝8713ea4e…）。
- 执行版清单销账完成版（队列行 outcome／sha／commit 全回填）。
- 首轮报告 C4。

#### 实施步骤
1. 跑同步脚本（真实队列）；记录新尖、件数小计。
2. 逐件对账：以新尖 `git ls-tree -r -z` 建 path→blob sha 映射，与执行版清单 synced 行 sha 全量比对（不许抽样）。同时回指 §4.2 C2 裁定 2 对照复核：drop 行 `origin_path`／`origin_sha256` 两列非空且 sha 与原件现行内容当场重算一致；对账时点找不到在册原件的 drop 件按自动转保留规则处理并记报告。
3. 复算四锚断言（逐锚独立断言）：STALE＝0；NOCARRIER＝冻结后盘上新增件数（逐件列名于报告，含本链自产的报告/记录类文件）；BRANCH_ONLY＝处置表 keep 的 blob 行数（gitlink 行不计）；CARRIED＝复算 A 集减其余三锚（自洽校验）。
4. 断言任一不过：按 §4.7 处置（同名改写件补跑一轮／其余停步报 PM 并附差额清单），不许改断言口径凑绿。

#### 续跑（F1 修正后，2026-10-04 PM 裁定）

首轮因 gitlink 前缀 40 件建模冲突停步（首轮报告 §2–§3；新尖 `982e5580…` 不可推送、未推送）。续跑按序执行，不跳步：

1. **回滚**：本地尖按 §4.7 回滚至锚 `8713ea4eb88b53f74f70f50477143a6fec05d22a`；执行版清单中首轮回写的 synced／dropped-by-ruling／kept-branch-only 行 outcome 相应回退为 pending，首轮报告补记回滚一行。
2. **队列修正**：spike-work 前缀 40 件（首轮报告 §3 全量清单）outcome 回写为 `embedded-repo`（§4.2 C1 新类；只回写 outcome，不增删行、class 不改）；S1 summary 文末按 §4.2 C1 盘点口径注记的写死文本追加口径增补节。
3. **守卫落地＋补夹具**：同步脚本按 §4.2 C3 增载体冲突守卫；Phase 2 自测补两件夹具（队列含 gitlink 前缀下文件 1 件、含 `.git` 组件路径 1 件），验守卫退出码 2、命中清单输出、ref 不动；原三态自测（正常／NO-OP／失败中止）复跑仍全过，才许进下一步。
4. **重跑**：按本 Phase 步骤 1–3 重跑首轮同步与对账断言（断言口径以 F1 增补后的 AC6／AC7／AC15 为准）。**期望值（期望，非判据放宽）**：synced 8,719 件、AC7 mismatch 0、新尖中 gitlink 条目 `160000 commit d12b4250…` 原样、新尖父＝锚 `8713ea4e…`；NOCARRIER 仅余冻结后新增残差（逐件列名，含本链自产件）。
5. **续行**：断言全过后续 Phase 4 推送、Phase 5 看守与 COMPLETION（原步序与判据不变）；首轮报告在原文件续写「续跑」节（回滚行／队列修正行／守卫夹具结果／续跑断言与推送三值），不另起文件。

#### 验证方法
AC6、AC7、AC8（§9.1）。

### Phase 4: 推送 origin

#### 交付物
- origin/maintainer-evidence 与本地同尖；验证三值记入首轮报告推送节。

#### 实施步骤
按 §4.5 三步逐字执行（收敛确认→grokbox 推送→VM fetch 验证）。每步输出摘要回写报告；任一步失败按 §4.5 失败处置停步。

#### 验证方法
AC9（§9.1）。

### Phase 5: 看守落地＋收口材料

#### 交付物
- `.tad/scripts/evidence-freshness-check.sh`（规格 §4.2 C5，只落盘）。
- `.tad/evidence/pm/evidence-freshness-log.md`（文件头＋首行记录，首跑 VERDICT 应为 OK；若首跑即 ALARM，如实记并当日报 PM，不许改阈值）。
- COMPLETION 定稿 `.tad/evidence/completions/COMPLETION-2026-10-04-evidence-carrier-recovery-execution.md`。

#### 实施步骤
1. 实现看守脚本，参数逐字认 §4.4；脚本内嵌的复算管线与 S1 口径一致（剔除规则同 summary）。
2. 负控自测：在 /tmp 临时克隆内把分支尖指回旧尖（或构造 NOCARRIER 超阈的假盘面）跑一次，验报警行格式与非零退出码；负控证据记 COMPLETION，真日志不写负控行。
3. 真跑一次，首行落 C6；回填 COMPLETION 四节（KA 至少回指 Project Knowledge 三条的适用情况）。收口时按 `.tad/evidence/knowledge-usage-log.jsonl` 既有格式追加一行，记本链对 S1 盘点产物与 PM 载体裁定的引用（该文件是 D35 计数与载体裁定三重议触发的计数基础，本链为载体恢复链，留行与上游链惯例一致——Gate 2 增补 A12）。

#### 验证方法
AC13、AC14（§9.1）。

---

## 7. File Structure

**CREATE（落盘；标注载体）**
- `.tad/scripts/sync-maintainer-evidence.sh`（main 工作区落盘，入 main 提交属 PM 收口动作——§10.3 裁量点 1）
- `.tad/scripts/evidence-freshness-check.sh`（同上）
- `.tad/evidence/research/maintainer-evidence-revival/execution-manifest.jsonl`（evidence 树，下一轮同步入分支）
- `.tad/evidence/research/maintainer-evidence-revival/branch-disposition.tsv`（同上）
- `.tad/evidence/pm/<执行日>-evidence-recovery-first-sync-report.md`（同上）
- `.tad/evidence/pm/evidence-freshness-log.md`（同上；后续每跑追加一行）
- `.tad/evidence/pm/<执行日>-termination-secret-isolation-check.md`（同上；第 16 件只读核查备案件）
- `.tad/evidence/completions/COMPLETION-2026-10-04-evidence-carrier-recovery-execution.md`（同上）
- Phase 0 小结（如独立落盘）：`.tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md`

**CREATE（PM 产物，Blake 不写）**
- `.tad/evidence/pm/<执行日>-evidence-recovery-17items-ruling.md`

**MODIFY**
- 分支 maintainer-evidence 的树：＋队列件、－处置 drop 件（仅此一处「改」）；执行版清单 outcome 列回写（盘上件）。
- `.tad/evidence/knowledge-usage-log.jsonl`：Phase 5 收口时按既有格式追加一行（本链引用记录，Gate 2 增补 A12）。
- main 工作树跟踪文件：**零修改**。

**FORBIDDEN（禁动）**
- `.gitignore`；main 与其他分支的 ref；main 已 tracked 3 件例外；`inventory-manifest.jsonl` 与 S1 summary（只读母本；S1 summary 仅许按 §4.2 C1 盘点口径注记在文末追加一节，F1 增补）；盘上两树既有文件（只读源）；grokbox 侧除 §4.5 命令外的任何写操作。

---

## 8. Testing Requirements

### 8.1 Unit Tests
- 同步脚本：/tmp 临时克隆内小队列试跑（Phase 2 自测），含正常入账、NO-OP、失败中止三态。

### 8.2 Integration Tests
- 首轮同步后四锚断言（Phase 3）即集成验收：真实盘面、真实分支、全量逐件 sha 对账（AC6/AC7）。
- 看守脚本：真跑首行（Phase 5）＋临时克隆负控报警行各一次。

### 8.3 Edge Cases
- CJK 路径 12 条（已知清单在 S1 summary）：同步后必须逐件归 carried，逐件点名验（AC7 对账天然覆盖，报告中另行点名列出）。
- 含空格/引号路径、可执行位文件、空文件（blob e69de29…形态）：管线不得丢件或错位。
- gitlink 件：同步与复算全程不跟随、不检出、不删除（AC15）。
- 执行期间他链新增件：冻结口径＋差额列名（Phase 3 断言）。

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| PM 核准 17 件 | Phase 1 等裁定文件落盘 | PM 逐件裁定（可改判草案） | 无——口头同意不算 | 裁定缺失 → Phase 2 起 BLOCKED |
| grokbox gh 登录态失效 | Phase 4 推送前探活 | 报 PM，由人恢复登录态 | 无——不许 VM 直推、不许落盘凭据 | 失效 → Phase 4 停步（非实施 FAIL） |
| Syncthing 未收敛／冲突文件 | Phase 4 前置 rev-parse 对比 | 等收敛复查；冲突停步报 PM | 无 | 未同尖 → 不许推送 |
| 盘面执行期新增/改写件 | Phase 3 断言差额列名 | 同名改写件补跑一轮；新增件留下轮 | 无 | 未解释差额 → Gate 3 FAIL |
| 脚本第二跑非 NO-OP | Phase 2 自测 | 修脚本至幂等后才许 Phase 3 | 无 | 不幂等 → Phase 3 BLOCKED |

**Status Enum**: `READY` / `BLOCKED` / `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` / `NOT_APPLICABLE_WITH_REASON`
当前：Phase 0 = READY；Phase 1 = READY（待 PM 裁定回路）；Phase 2 起 = BLOCKED on Phase 1 定稿（设计使然，非异常）。

## 8.5 Feedback Collection (Non-Code Artifacts)
```yaml
feedback_required: false
artifact_type: generic
notes: "git 载体与脚本批，人类验收点在 Gate 4 由 Alex 从盘上重算 §9.1；推送与看守首跑结果由 PM 在收口播报中呈用户"
```

## 8.6 🆕 Test Evidence Required
Blake必须提供：
- [ ] Phase 0 复算命令与四锚输出原文（完工记录附）
- [ ] Phase 2 自测三态输出摘要（临时克隆路径、试跑件清单、NO-OP 与失败中止的退出码）
- [ ] Phase 3 全量 sha 对账结果（比对件数、mismatch 数＝0 的输出）与四锚断言逐锚结果
- [ ] Phase 4 三步命令输出摘要（收敛 rev-parse 值、push 输出、fetch 后 rev-parse 值）
- [ ] Phase 5 看守负控报警行样本与真跑首行原文

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] §9.1 逐行 PASS（Gate 3 执行）
- [ ] Phase 1 硬前置成立（PM 裁定文件在盘且处置表定稿）后才发生的 Phase 2–5 动作（时序可由文件 mtime 与报告记录互证）
- [ ] 禁区零触碰（§4.6 围栏；AC10–AC12、AC15）
- [ ] 推送同尖且看守首跑落行（AC9、AC13）
- [ ] AC9 与 AC8 合取判读：AC9 单独 PASS（旧尖同尖时亦 PASS）不构成推送完成证据，推送完成 ⇔ AC8∧AC9 同真（fit F-4，Gate 2 增补 A11；Gate 3 按此执行）

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

> 断言纪律：多词断言一律逐词独立 grep 合取（per-term），不许合并计数（Project Knowledge ②）。基线均为 2026-10-04 设计步实测。

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---|---|---|---|---|
| 1 | AC1 执行版清单成立：母本全量带入＋追加行对账＋outcome 列齐 | post-impl-verifiable | command: `python3 -c "import json; rows=[json.loads(l) for l in open('.tad/evidence/research/maintainer-evidence-revival/execution-manifest.jsonl',encoding='utf-8')]; app=[r for r in rows if r.get('appended_at_phase0')]; ok=len(rows)>=13082 and len(rows)-13082==len(app) and all('outcome' in r for r in rows); print(len(rows), len(app), ok); raise SystemExit(0 if ok else 1)"` | exit 0；总行数＝13,082＋追加行数 | 基线：文件不存在（母本 13,082 行在盘） |
| 2 | AC2 开链复算留痕：Phase 0 记录含复算四锚与 S1 基线对照、差额归因 | post-impl-verifiable | command: `grep -q 'TOTAL_NOCARRIER=' .tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md && grep -q 'TOTAL_STALE=' .tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md && grep -q 'TOTAL_CARRIED=' .tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md && grep -q 'TOTAL_BRANCH_ONLY=' .tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md && grep -q '8706' .tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md` | exit 0（五词逐项命中） | 基线：文件不存在 |
| 3 | AC3 处置表定稿：恰 17 行、decision 全落定、无 PENDING 残留、drop 行裁定 2 对照两列非空且 sha 与原件当场重算一致 | post-impl-verifiable | command: `python3 -c "import csv,hashlib; rows=list(csv.DictReader(open('.tad/evidence/research/maintainer-evidence-revival/branch-disposition.tsv',encoding='utf-8'),delimiter='\t')); sha=lambda p: hashlib.sha256(open(p,'rb').read()).hexdigest(); ok=len(rows)==17 and all(r['decision'] in ('keep','drop') for r in rows) and all(r['ruling_ref']!='PENDING-PM' for r in rows) and any(r['class']=='gitlink' for r in rows) and all(r.get('origin_path') and r.get('origin_sha256')==sha(r['origin_path']) for r in rows if r['decision']=='drop'); print(len(rows), ok); raise SystemExit(0 if ok else 1)"` | exit 0；17 行且含 gitlink 行，drop 行对照断言全过 | 基线：文件不存在；对象集＝S1 四锚 BRANCH_ONLY=16＋gitlink 1 |
| 4 | AC4 PM 核准硬前置：裁定文件在盘且首轮报告回指之 | post-impl-verifiable | command: `ls .tad/evidence/pm/*-evidence-recovery-17items-ruling.md >/dev/null 2>&1 && grep -lq '17items-ruling' .tad/evidence/pm/*-evidence-recovery-first-sync-report.md && grep -q '核准' .tad/evidence/pm/*-evidence-recovery-17items-ruling.md` | exit 0 | 基线：裁定文件不存在（Phase 1 待 PM 动作） |
| 5 | AC5 同步脚本形态：plumbing 机制在位、朴素 add 与 main ref 零出现 | post-impl-verifiable | command: `grep -q 'GIT_INDEX_FILE' .tad/scripts/sync-maintainer-evidence.sh && grep -q 'hash-object' .tad/scripts/sync-maintainer-evidence.sh && grep -q 'update-index' .tad/scripts/sync-maintainer-evidence.sh && grep -q 'read-tree' .tad/scripts/sync-maintainer-evidence.sh && grep -q 'write-tree' .tad/scripts/sync-maintainer-evidence.sh && grep -q 'commit-tree' .tad/scripts/sync-maintainer-evidence.sh && test "$(grep -v '^[[:space:]]*#' .tad/scripts/sync-maintainer-evidence.sh | grep -c 'git add')" = "0" && test "$(grep -c 'refs/heads/main' .tad/scripts/sync-maintainer-evidence.sh)" = "0"` | exit 0（六正项逐项命中＋两负项为 0；`git add` 负项只对非注释行判定） | 基线：文件不存在 |
| 6 | AC6 同步后四锚断言：STALE=0、NOCARRIER=冻结后新增件数、BRANCH_ONLY=keep 数 | post-impl-verifiable | command: 按 S1 summary「复跑命令序列」逐字重算四锚，再逐锚断言：`TOTAL_STALE` 等于 0；`TOTAL_NOCARRIER` 等于盘上路径集减执行版清单路径集的件数（同一 python 管线内算出并比对；盘上路径集与 S1 序列同一剔除口径：先剔除盘点产物 2 件（EXCL——Gate 2 增补 A3）与 `embedded-repo` 两类路径（gitlink 前缀下盘上内容＋含 `.git` 组件路径——F1 增补，§4.2 C1），等式两侧同口径）；`TOTAL_BRANCH_ONLY` 等于处置表 decision=keep 的 blob 行数（gitlink 不计）；三断言各自独立输出 PASS/FAIL（断言脚本原文须附于首轮报告，Gate 3 原样重跑） | 三断言全 PASS | 基线（S1）：8706／5／4355／16 |
| 7 | AC7 逐件 sha 全量对账：synced 行 sha 与分支 blob sha 逐件相等、件数与队列相等 | post-impl-verifiable | command: `python3 -c "import json,subprocess; rows=[json.loads(l) for l in open('.tad/evidence/research/maintainer-evidence-revival/execution-manifest.jsonl',encoding='utf-8')]; q=[r for r in rows if r['class'] in ('no-carrier','stale-content') and r.get('outcome')!='embedded-repo']; e=[r for r in rows if r.get('outcome')=='embedded-repo']; s=[r for r in rows if r.get('outcome')=='synced']; out=subprocess.run(['git','ls-tree','-r','-z','maintainer-evidence'],capture_output=True).stdout.decode('utf-8'); m={e.split('\t',1)[1]:e.split('\t',1)[0].split(' ')[2] for e in out.split('\0') if '\t' in e}; bad=[r['path'] for r in s if m.get(r['path'])!=r.get('sha')]; print('queue',len(q),'synced',len(s),'embedded-repo',len(e),'mismatch',len(bad)); raise SystemExit(0 if len(q)==len(s) and len(e)==40 and not bad else 1)"` | exit 0；mismatch＝0、embedded-repo＝40（F1 队列修正件数，§4.2 C1） | 基线：synced 行 0（未实施） |
| 8 | AC8 分支尖推进且父为旧尖 | post-impl-verifiable | command: `test "$(git rev-parse maintainer-evidence^)" = "8713ea4eb88b53f74f70f50477143a6fec05d22a" && test "$(git rev-parse maintainer-evidence)" != "8713ea4eb88b53f74f70f50477143a6fec05d22a"` | exit 0 | 基线：尖＝8713ea4e…（2026-09-06） |
| 9 | AC9 推送同尖：origin 跟踪尖与本地尖同值 | post-impl-verifiable | command: `git fetch origin >/dev/null 2>&1; test "$(git rev-parse origin/maintainer-evidence)" = "$(git rev-parse maintainer-evidence)"` | exit 0 | 基线：两值同为 8713ea4e…（旧尖同尖，未推送新尖） |
| 10 | AC10 main 围栏：main 尖未动、跟踪文件零修改 | post-impl-verifiable | command: `test "$(git rev-parse main)" = "5619b09556863b6d2587d6fa71b46e71bb8b1174" && test "$(git status --porcelain | grep -vc '^??')" = "0"` | exit 0 | 基线：main 尖＝5619b095…；设计步 status 跟踪修改 0 |
| 11 | AC11 .gitignore 指纹不变 | post-impl-verifiable | command: `test "$(sha256sum .gitignore | cut -d' ' -f1)" = "3109c53025688cc5ad6d1d8f4b5b908b4f88d0c1db7358a1f96e58be0081bfab"` | exit 0 | 基线即左值（设计步实测） |
| 12 | AC12 主仓例外恰 3 件且集合不变、`.gitignore` 指纹未变（指纹法，F1 增补） | post-impl-verifiable | command: `test "$(sha256sum .gitignore \| cut -d' ' -f1)" = "3109c53025688cc5ad6d1d8f4b5b908b4f88d0c1db7358a1f96e58be0081bfab" && git ls-files -- .tad/evidence/ .tad/archive/ \| sort \| diff - <(printf '%s\n' '.tad/archive/next/NEXT-completed-through-20261004.md' '.tad/evidence/pm/downstream-versions.md' '.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md')` | exit 0（指纹与 §2.2 登记值全等 ∧ 例外集合 diff 空——指纹法两件齐，PM 裁定口径：`.gitignore` sha256 与登记指纹一致、且忽略集实测未漂移，即判 PASS） | 基线：指纹即左值、例外恰此 3 件（设计步实测） |
| 13 | AC13 看守首跑落行：脚本与日志在盘、首行含四锚字段与 VERDICT=OK | post-impl-verifiable | command: `test -f .tad/scripts/evidence-freshness-check.sh && test -f .tad/evidence/pm/evidence-freshness-log.md && grep -q 'VERDICT=OK' .tad/evidence/pm/evidence-freshness-log.md && grep -q 'NOCARRIER=' .tad/evidence/pm/evidence-freshness-log.md && grep -q 'TIP_AGE_DAYS=' .tad/evidence/pm/evidence-freshness-log.md && grep -q 'BRANCH_ONLY=' .tad/evidence/pm/evidence-freshness-log.md` | exit 0（逐项命中） | 基线：两文件均不存在 |
| 14 | AC14 看守参数逐字：阈值 100／21 在脚本、责任人与周期在日志头 | post-impl-verifiable | command: `grep -qE '\-gt 100' .tad/scripts/evidence-freshness-check.sh && grep -qE '\-gt 21' .tad/scripts/evidence-freshness-check.sh && grep -q 'evidence-freshness-log.md' .tad/scripts/evidence-freshness-check.sh && grep -q '责任人' .tad/evidence/pm/evidence-freshness-log.md && grep -q 'TAD PM' .tad/evidence/pm/evidence-freshness-log.md && grep -q '月度' .tad/evidence/pm/evidence-freshness-log.md` | exit 0（逐项命中） | 基线：两文件均不存在；参数出处＝裁定二原文 |
| 15 | AC15 gitlink 保全：分支内指针 160000 原样（F1 增补后唯一期望态） | post-impl-verifiable | command: `test "$(git ls-tree maintainer-evidence -- .tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work \| wc -l)" = "1" && git ls-tree maintainer-evidence -- .tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work \| grep -q '160000 commit d12b42505f2dfd2b5d8f5de51cc6e3d0a43aa0fa'` | exit 0（该路径恰一条条目且为 160000 指针原值；处置已定稿 keep（PM 核准），原 drop 备选形态删除——指针被普通树替换即 FAIL，无第二形态可过） | 基线：指针在位（mode 160000，d12b4250…） |

| 16 | AC16 第 16 件核查备案件成立：备案件在盘、含核查人/核查方法/结论三项 | post-impl-verifiable | command: `ls .tad/evidence/pm/*-termination-secret-isolation-check.md >/dev/null 2>&1 && grep -q '核查人' .tad/evidence/pm/*-termination-secret-isolation-check.md && grep -q '核查方法' .tad/evidence/pm/*-termination-secret-isolation-check.md && grep -q '结论' .tad/evidence/pm/*-termination-secret-isolation-check.md` | exit 0（三项逐项命中）；备案件不引疑似凭据原文由 Gate 3 safety 路人工核（备案件文本与该 json 内容片段不重合） | 基线：文件不存在 |

> **Verification Method grammar**: 本表除 AC6 外均为 command 文法；AC6 以首轮报告所附断言脚本为执行形态（脚本原文附于首轮报告，Gate 3 原样重跑）。

> **基线时点声明（Gate 2 增补 A7）**：AC8 的父值基线与 AC10 的 main 尖基线以 Phase 0 完工记录中复算时点登记值为准（Phase 0 记录即基线源）；表中钉值是设计时点值，Gate 3 执行 AC8／AC10 时以 Phase 0 登记值替换表中钉值比对，登记值与设计时点值的差异须在 Phase 0 记录中逐件归因。

## 9.2 Expert Review Status (Alex 必填)

### Gate 结构（逐门：谁判／判据／证据落点）

| Gate | 谁判 | 判据 | 证据落点 |
|---|---|---|---|
| Gate 2 tech 路 | PM 另派独立 Alex 会话（与设计者不同会话） | plumbing 机制正确性、围栏可验性、推送路径可行性、AC 文法逐行可跑 | `.tad/evidence/reviews/<日期>-gate2-tech-evidence-carrier-recovery.md` |
| Gate 2 fit 路 | PM 另派独立 Alex 会话（与 tech 路互不可见） | 范围与票四项一一对应、红线全入、看守参数与裁定逐字一致、17 件流程合裁定四 | `.tad/evidence/reviews/<日期>-gate2-fit-evidence-carrier-recovery.md` |
| Gate 2 合并裁定 | PM | 两路条件去重、冲突裁决、转 PASS 才许开工 | HANDOFF Gate 2 节回填＋裁定记录 |
| Gate 3 code 路 | 独立会话（Blake 评审形态，只审不改） | §9.1 逐行重跑、脚本正文核（围栏 W1–W4）、幂等与失败中止证据 | `.tad/evidence/reviews/gate3-code-evidence-carrier-recovery.md` |
| Gate 3 safety 路 | 独立会话（与 code 路互不可见） | 凭据卫生（NFR3）、禁区零触碰、回滚可用性、推送面核对 | `.tad/evidence/reviews/gate3-safety-evidence-carrier-recovery.md` |
| Gate 4 | Alex 独立会话 | 从盘上重算 §9.1 全行（不采信 COMPLETION 自述）、四锚独立复算、KA 完整性 | `.tad/evidence/reviews/gate4-evidence-carrier-recovery.md`；其后 PM 收口播报＋用户 CHECK |

### Audit Trail

| 时间 | 事件 |
|---|---|
| 2026-10-04 | 研究链收口：PM 裁定采纳案一并立本链票（`TICKET-20261004-evidence-carrier-recovery-execution`） |
| 2026-10-04 | Alex 设计步（本文件）：基线亲跑（分支尖/main 尖/例外 3 件/.gitignore 指纹/17 件逐件信息） |

### Experts Selected（供 PM 派 Gate 2 双审时参考）

- tech 路：git plumbing 与 shell 管线方向；fit 路：TAD 流程与裁定契合方向。两路均须独立会话、互不可见，自评不算。

### Overall Assessment (post-integration)

设计自足性：执行者只读本文件＋票＋裁定＋S1 summary 即可开工；唯一外部等待是 Phase 1 的 PM 裁定（设计内硬前置，非缺口）。

---

## 10. Important Notes

### 10.1 Critical Warnings

- **朴素 `git add` 会静默空转**：两树整树忽略，不带显式清单/`-f` 等价机制的提交会「成功」地什么都不加——脚本假绿是本链第一风险，全靠 Phase 3 逐件 sha 对账＋四锚断言堵（AC6/AC7），不许以脚本 exit 0 代替断言。
- **不许 force-push**：推送后回滚不在本链授权（§4.7）。
- **凭据零落盘**：推送只借 grokbox gh 登录态的内联 helper；任何把凭据写进脚本、git config、报告的动作即 Gate 3 safety FAIL。
- **冻结口径不可破**：执行期间盘上新增件不临时入队；「顺手一起同步」会使差额断言失去解释基准。

### 10.2 Known Constraints（禁区）

§4.6 围栏与 §7 FORBIDDEN 清单即本链禁区全集；另：仓外文件一律以绝对路径为准、禁写（仓内外同名文件教训，2026-10-04 R1 链实证）。

### 10.3 🆕 Sub-Agent使用建议

- 实施以单个 Blake 会话串行跑完 Phase 0–5 为宜（状态都在盘上清单与报告里，不依赖会话记忆）；Gate 3 双审另派两独立会话。
- **裁量点（PM 收口时定，Blake 不自决）**：脚本两件（`.tad/scripts/`）入 main 的提交方式——本链只落盘，其入 main 比照 R1 收口批经 PM/用户拍板后提交；Gate 4 验收对象为盘上脚本本体。

---

## 11. 🆕 Learning Content（可选）

### 11.1 Decision Rationale: plumbing 临时索引 vs worktree 检出

选 plumbing：① 不动 main 工作树与当前检出，Syncthing 面零新增大目录；② ref 只在最后一步前移，失败原子回退天然成立；③ 逐件 sha 在写入时即产生，与 FR8 销账凭据同源。worktree 方案需多检出约 65 MB 且删除语义靠 rsync 镜像，与「不存在默认删除」的处置模型冲突，故不选。

### 11.2 Decision Rationale: 删除只许点名

分支是唯一载体：镜像式同步会把「盘上已删」误作「应当删除」，16 件 branch-only 正是盘上已无副本的历史件。故同步机制在结构上无镜像删除，删除只能由处置表逐件点名（裁定四「不许默认吞掉」的机制化）。

---

## 12. 🆕 Sub-Agent使用记录

| Phase | 会话 | 角色 | 结果 |
|---|---|---|---|
| （实施期回填） | | | |

---

## 附录 A：17 件处置意见草案（待 PM 核准，非定稿）

> 意见由设计步 Alex 给出草案，效力以 Phase 1 的 PM 裁定文件为准（裁定四：本裁定不预判去向）。件信息为设计步亲跑（blob 字节数／分支内末次触碰提交与日期）。汇总：**保留 10 件（A.1 八件＋A.3 附条件 1 件＋gitlink 1 件）、弃置候选 7 件**。

### A.1 历史链记录（8 件）——意见：全部保留

同属 2026-04-27 tad-token-efficiency 链，盘上原路径已无副本，分支是唯一载体；HANDOFF／COMPLETION／评审成套，拆散即损审计完整性。

| # | 路径 | 字节 | 末次触碰 | 意见 | 理由 |
|---|---|---|---|---|---|
| 1 | `.tad/archive/handoffs/HANDOFF-20260427-tad-token-efficiency.md` | 64,484 | 4709ada2（2026-04-27） | 保留 | 已收口链 HANDOFF 唯一副本 |
| 2 | `.tad/archive/handoffs/COMPLETION-20260427-tad-token-efficiency.md` | 22,317 | e5bdefa7（2026-04-27） | 保留 | 同链 COMPLETION 唯一副本 |
| 3 | `.tad/evidence/reviews/blake/tad-token-efficiency/backend-architect.md` | 24,989 | c3ce2738（2026-04-27） | 保留 | 同链评审记录唯一副本 |
| 4 | `.tad/evidence/reviews/blake/tad-token-efficiency/backend-architect-blake-impl.md` | 10,994 | c3ce2738（2026-04-27） | 保留 | 同上 |
| 5 | `.tad/evidence/reviews/blake/tad-token-efficiency/backend-architect-blake-impl-v3.md` | 14,333 | 4709ada2（2026-04-27） | 保留 | 同上 |
| 6 | `.tad/evidence/reviews/blake/tad-token-efficiency/code-reviewer.md` | 19,713 | c3ce2738（2026-04-27） | 保留 | 同上 |
| 7 | `.tad/evidence/reviews/blake/tad-token-efficiency/code-reviewer-blake-impl.md` | 12,029 | c3ce2738（2026-04-27） | 保留 | 同上 |
| 8 | `.tad/evidence/reviews/blake/tad-token-efficiency/code-reviewer-blake-impl-v3.md` | 5,954 | 4709ada2（2026-04-27） | 保留 | 同上 |

### A.2 验收夹具内嵌技能副本（7 件）——意见：弃置候选（建议弃置，非强制）

同在 `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only/.agents/skills/` 下（下表路径为该前缀后段），末次触碰均为 47918da7（2026-08-13）。性质为验收试验沙箱内嵌的技能文件**副本**，非证据本体；技能本体另有现行维护路径，副本留存价值低且易与本体混淆。若 PM 倾向全保，保留亦无害（分支不进发行面）——此组是 17 件中唯一建议 PM 认真考虑弃置的一组。

| # | 路径（前缀见上） | 字节 | 意见 | 理由 |
|---|---|---|---|---|
| 9 | `ai-agent-architecture/references/cost-token-economics.md` | 8,356 | 弃置候选 | 夹具副本，非证据本体 |
| 10 | `code-security/references/secret-detection-rules.md` | 9,154 | 弃置候选 | 同上 |
| 11 | `web-frontend/examples/design-token-consumption.md` | 3,358 | 弃置候选 | 同上 |
| 12 | `web-frontend/references/design-tokens.md` | 8,936 | 弃置候选 | 同上 |
| 13 | `web-ui-design/examples/starter-tokens.json` | 6,865 | 弃置候选 | 同上 |
| 14 | `web-ui-design/references/brand-tokens.md` | 5,214 | 弃置候选 | 同上 |
| 15 | `web-ui-design/tools/tokens-to-css.sh` | 2,272 | 弃置候选 | 夹具脚本副本，同上 |

### A.3 试验夹具（1 件）——意见：保留（附条件）

| # | 路径 | 字节 | 末次触碰 | 意见 | 理由 |
|---|---|---|---|---|---|
| 16 | `.tad/evidence/yolo/yolo2-verified-orchestration/phase3/fixtures/termination-secret-isolation.json` | 752 | 8713ea4e（2026-09-06） | 保留（附条件） | yolo 链试验夹具本体、小件；文件名涉 secret，Phase 1 须先只读核内容无真实凭据（§6 Phase 1 步骤 1），确认后保留；若疑似含真实凭据，停步报 PM 另行处置，不直接弃置了事 |

### A.4 gitlink（1 件）——意见：保留指针

| # | 路径 | 形态 | 意见 | 理由 |
|---|---|---|---|---|
| 17 | `.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work` | mode 160000 → commit `d12b42505f2dfd2b5d8f5de51cc6e3d0a43aa0fa` | 保留指针 | 指针本身即 spike 试验记录；内容不在本仓、保留成本为零；同步与看守全程不跟随、不检出、不删除（AC15） |
