# COMPLETION — TASK-20261006-EPIC-P1-CLEARANCE（TAD 自优化 Epic Phase 1 本体清账批）

- 执行：Blake（Execution Master），2026-10-06
- HANDOFF：`.tad/active/handoffs/HANDOFF-2026-10-06-epic-p1-clearance.md`（开工锚 53,861 B／sha256 `9c3cc3ff…` 复算全等；实施中经 PM 裁断加 §7 写集扩展注记，终态 54,502 B／sha256 `5cc953955d03688d9dbaf07daa71c5937c42077dd173a027fcb55baea7ea64a6`）
- 证据目录：`.tad/evidence/epic-p1-clearance-20261006/`（基线、逐 AC 输出、fixture 日志全在此）
- gate3_verdict：PASS（CODE＋SAFETY 双 PASS，2026-10-06）；Gate 4：PASS（无条件）
- human CHECK：CHECK 待人
- git 纪律：本链零 git 写；发版／提交／推送归 PM 收口。

## 逐件结果

| 件 | 结果 | 要点 |
|---|---|---|
| 1.1 校验器双类契约＋step3c3 | ✅ | `validate_canonical` 改双类契约（Class P 登记面／Class A 严契约不变）＋usage 头注（含 CF-1 契约变更注记）；publish-protocol 新增 step3c3（受治集双参数形态写死、全发版类型恒阻塞），publish-ops §2.5 加指针行 |
| 1.2 版本口径恒久修订 | ✅ | 推导规则段入 publish-protocol step3c 前言（正本）＋publish-ops §3（镜像）；封顶模式集两文件零残留（AC5） |
| 1.3 史述面口径 | ✅ | publish-ops §3.1 六类口径（L/H1/H2/H3/F/D＋未归类停步条＋分诊记录字段形态）；step3c minor/major 加 100% 覆盖门条件句；史述面零改动（AC6） |
| 1.4 check5 清理＋防再发 | ✅ | session-state 索引块四子串定点改归档实指、其余文字未动；state-surface 全量转 PASS；gate-execution Gate 4 节末加迁档回写衔接句 |
| 1.5 AC11 计数口径 | ✅ | 登记面定义句同句入 handoff-a-to-b §9.1 引导区与 scan-packs 断言节头注 |
| 1.6 genesis 三件套 | ✅ | tad.sh `write_genesis_manifest()`＋engine 链首锚定＋step3d hop 义务句与存量补登口径句（落点与调用点记录见下节） |
| 1.7 hooks.json 收敛 | ✅ | heredoc 向存档件逐字节对齐（fixture 生成件与存档件 `cmp` 全等、805 B）＋heredoc 上方 Canonical copy 注记＋publish-ops §2.5 语义比对句。**注：此裁定与 GM 登记原倾向反向（生成器原输出为非法 JSON），PM 收口知会 GM 时须带明** |
| 1.8 driftcheck (r) | ✅ | 新增 B_dir 集、B 改称 B_type、(c) 收窄、新增 (r) 永不置 drift、(d) source-only 改判 C∖B_dir、C 不可用声明行、头注三层对照缩版 |
| 1.9 读单断言＋新鲜度＋安装面 | ✅（AC23 部分项见 AC 表） | state-surface 新增 check6（AGENTS.md 提取、现行五件全实存 PASS）＋check7（INFO 年龄恒报、超 14 天 WARN 不计 fail、不可读 FAIL）；tad.sh 初装流程加目标侧 brain-index 生成步（失败可见 WARN、禁静默吞） |
| 1.10 负证据纪律 | ✅ | evidence-collection 在 Capture Path Discipline 后插入 Negative Evidence Discipline 全节（§4.10 定稿原文） |
| 1.11 根因模板 | ✅ | CREATE `.tad/templates/root-cause-report.md`（§4.11 草案全文）＋gate-execution Violation Handling 节首加 Root-Cause-First 小节 |
| CF-4 AGENTS.md 注记句 | ✅ | Knowledge Ingress 末注记句订正为指向 check6 的表述；diff 仅该句，版本标记行未动 |

## 关键实施记录

- **tad.sh genesis 落点选择**：三处 version.txt 写点分属 `install`／`upgrade`／`migrate` 三个 ACTION 分支，逐一判定——仅 `install` 分支是 CURRENT_VERSION＝"none" 的初装可达路径，`write_genesis_manifest()` 只挂该分支写点之后；upgrade/migrate 不写 genesis（保既有版本史）。`install_form` 映射既有标记：SOURCE_MODE＝1 → `source`，否则 → `download`。已存在绝不覆写（函数内显式保留并 log）。
- **CF-3 调用点盘清**：`resolve_chain` 全仓仅一处调用——migration-engine.sh 自身 main（改后签名加 TARGET 并在此传 `$TARGET`）；tad.sh 经子进程调 engine，不 source、无第二调用点。engine 对外 CLI 不变。
- **件 1.9 核查点结论（Phase 0 先证后改）**：(i) 初装后目标树 brain-index **缺失**；(ii) 目标 AGENTS.md L43 路由与实存不一致；(iii) 目标侧生成器手动可跑通（exit 0）→ 按 §4.9 走「(i) 为缺」支：初装流程 `copy_framework_files` 后加目标侧生成步。改后 fixture：brain-index 实存、Generated 为当日、check7 age 0d。
- **停步与裁断（如实记录）**：Phase 1 件 1.1 自验撞写集外分歧——agent-orchestration／web-frontend／web-testing 三包的现行投影 `keywords:` 是其 CAPABILITY.md 的严格超集（投影曾带外增补、源包未回同步），Blake 按红线停步上报（`stop-note-item1.1-mirror-divergence.md`）。**PM 裁断采案 A**：三包以投影为现行有效源、CAPABILITY.md 向投影逐字回同步（仅 keywords 行；type 两侧本已一致、无 version 分歧），写集扩三件并注记入 HANDOFF §7；§4.1 镜像判据本身不变。回同步后三件 validate exit 0。此事另证一件历史事实：三包的投影 keywords 增补从未回写源包，registry（由 CAPABILITY 生成）此前亦为旧值——本链未动仓内 registry 文件（其再生成属发版面 scan-packs 动作，隔离副本实跑已验证生成结果与投影一致、断言 exit 0）。

## AC 逐条实测（§9.1）

| AC | 结果 | 实测值（证据文件在证据目录） |
|---|---|---|
| AC1 | PASS | 受治集 27/27 exit 0（registry 25＋alex＋blake），`ac1-validator-governed.txt` |
| AC2 | PASS | 负控三连均 exit 2 且因由正确：(a) 白名单外键 owner；(b) type 与 CAPABILITY 不符；(c) 非 authored-tree 根置 README，`ac2-negative-controls.txt` |
| AC3 | PASS | save-skill exit 2（extra keys）、alex-lite exit 2（块标量），`ac3-class-a-regression.txt` |
| AC4 | PASS | product-thinking type/keywords 与 CAPABILITY 逐字一致；正文 sha256＝`c6a83fc4…`＝基线，`ac4-ac5.txt` |
| AC5 | PASS | 两文件各含推导规则锚段 1 处；封顶模式集 grep 零命中，`ac4-ac5.txt` |
| AC6 | PASS | §3.1 在盘、六类齐、未归类停步条在；step3c 含 100% 覆盖＋未分类硬拦句；史述面抽样 10 件（CF-3 分诊 A1–A10）：9 件 `git diff` 空，A7 所在文件为本链写集件、其历史行经 diff 定点核未删改，`ac6.txt` |
| AC7 | PASS | state-surface 全量 check1–7 全过、exit 0，`ac7-ac18-state-surface-final.txt` |
| AC8 | PASS | 四归档路径逐一 `test -f` 在盘；Gate 4 衔接句 grep 命中 1，`ac8-ac9-ac12-ac13-ac20-ac21.txt` |
| AC9 | PASS | 定义句在两处 grep 命中且同句，同上文件 |
| AC10 | PASS | 初装 fixture `/tmp/epic-p1-fix1-dnggC8`：genesis 在盘、五字段齐、installed_version＝3.0.1＝目标 version.txt；重跑初装哈希不变（`38f61a60…`），`ac10-genesis-fields.txt`／`install-after-fixture.log` |
| AC11 | PASS | 升级 fixture（副本 version 与 genesis 同置 3.0.0）：输出 `NOTE: genesis-anchored at 3.0.0`＋`No manifests found`、无 REJECT、exit 0、genesis 未被覆写；负控：版本不符 → REJECT、链中段缺 hop → REJECT at 3.0.1，`ac11-upgrade-fixture.log`／`ac11-engine-controls.txt` |
| AC12 | PASS | 发布源 `.tad/migrations/genesis.yaml` 不存在；engine 含 NOTE 锚串（L716），同 AC8 文件 |
| AC13 | PASS | step3d hop 义务句与存量补登口径句各 grep 命中 1，同上文件 |
| AC14 | PASS | fixture 真走 tad.sh codex 生成路径：生成件与存档件 `cmp` 逐字节一致、`jq -S` 解析 exit 0，`ac14-ac15-hooks.txt` |
| AC15 | PASS | (a) 改一处 timeout 值 → 规范化比对判不等（漂移）；(b) 仅 jq 重排格式 → 判相等（非漂移），同上文件 |
| AC16 | PASS | driftcheck 源仓实跑含 (r) 节且为空、(c) 为空、product-thinking 不在 (c)、无失实文案；总 exit 1 仅因 (b) 11 件批外存量（CF-2 口径），`ac16-driftcheck-final.txt` |
| AC17 | PASS | 三形态 fixture：(i) 幻影名落 (c) 且 drift 置位 exit 1；(ii) 有源包＋投影无 type 行落 (r)、exit 0；(iii) 无源包集形态打印 Set C unavailable 声明行、(c) 只按 B_dir 判、exit 0，`ac17-driftcheck-fixtures.txt` |
| AC18 | PASS | 全量含 `PASS check6`＋`INFO check7 … age 20d`＋超阈 WARN，总 exit 0，同 AC7 文件 |
| AC19 | PASS | 400 天前 Generated → INFO age 400d＋WARN、check7 不计 fail（骨架仓总 fail 数 9）；删 Generated 行 → check7 FAIL（总 fail 数 10，恰 +1），`ac19-check7-fixture.txt` |
| AC20 | PASS | Negative Evidence Discipline 节在盘（L304，位于 Capture Path Discipline L284 之后、Pattern Recognition Protocol L313 之前），positive probe 与强度标注两要素齐，同 AC8 文件 |
| AC21 | PASS | 模板在盘、定因/定界/验证三段标题与复发三问指引齐；gate-execution 含 Root-Cause-First 指针，同上文件 |
| AC22 | PASS（附注） | 本链变更集 ⊆ §7 写集∪PM 扩展三件∪本链自产件（清单见实施完工说明）；全部改动 .sh 过 `bash -n`；scan-packs 断言在隔离副本实跑 exit 0（仓内 registry 为派生文件，未在本链直接重跑生成以免写集外改动，隔离副本生成结果 25 packs、断言通过）。**附注**：`git status --porcelain` 另有批前既存的非本链脏面（旧链 handoff 迁档删除、NEXT.md 与 docs/pm 若干文件修改、若干未跟踪开跑卡等），本链未触碰、未代为处置，逐类见实施完工说明 |
| AC23 | **PARTIAL — 待 PM 裁断** | 初装副本 `.tad/brain-index.md` **实存**（件 1.9 处置目标达成，check7 在副本 age 0d）；但以 check6 同法提取副本 AGENTS.md 读单逐一验，五件中四件 project-knowledge 路径（principles／patterns/_index／frontend-design／patterns/shell-portability）在初装副本缺失。缺失原因是 installer 既有设计而非本链回归：project-knowledge 属 zero-touch 知识接缝（tad.sh install 分支注记「Option A pure isolation」：新装只给 README 种子、上游 principles/patterns 永不拷贝），下游仓的该四路径由项目自著。AC23 字面「全过」与该 installer 既有设计冲突，Blake 不自行改判据、不扩面改 installer，实测全文在 `ac23-install-surface.txt`，请 PM／Gate 3 裁断 AC23 判读（Blake 倾向：AC23 辖区应限 installer 供给面，即 brain-index 路由；项目自著面不入安装断言） |

## 全量回归

- `bash -n`：六个改动脚本全过（`ac22-bash-n.txt`）。
- scan-packs：隔离副本 exit 0、25 packs（`ac22-scan-packs-isolated.txt`）。
- driftcheck、state-surface：见 AC16／AC7。
- release-verify version detect-only（NEW 3.0.1／OLD 3.0.0）：exit 1、172 stale——与基线一致：v3.0.1 分诊时点 191 件，减已随 3.0.1 bump 改面的 19 件即 172；逐文件核对，写集文件内的命中全为既存 H1 历史行（v3.0.0 事件陈述），且本链全部新增行中零行含 `3.0.0`——**本链未引入任何新 stale 面**（`regression-release-verify-version.log`／`regression-stale-by-file.txt`）。
