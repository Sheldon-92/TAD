# 体量盘点表 — Epic Phase 4 件 4.1（Phase 0 成表，2026-10-06，Blake）

仓根 `/home/hatch/workspace/yun-sync/TAD`。计量口径与 HANDOFF §2 一致（`du -sh`／`git count-objects -vH`／`git ls-tree` blob 求和），Phase 0 亲测复算。

## A. 基线锚复算结果（HANDOFF §2 对盘）

| 锚 | 设计值 | Phase 0 复算 | 判读 |
|---|---|---|---|
| HEAD | `68593e82` | `68593e82` | ✅ 全等 |
| `.tad/version.txt` | `3.1.0` | `3.1.0` | ✅（AC28 基线） |
| maintainer-evidence 尖 | `ea54399f` | `ea54399f` | ✅ |
| 总量 `du -sh .` | 524M（R1 基线 521M） | 523M（Phase 0 采样时点） | ✅ 偏差 −1M：du 块计量波动＋设计后净增减（P4 设计/评审件增、临时件清），逐项可归因（AC1）。**链末附记**：本链收口复测总量为 **530M**——Phase 0 采样后并行 tadsh-backup-fix 链持续在飞写入（其测试/证据产物）使总量上行约 7M，非本链处置对象变化；AC5 复测须以 Phase 2 执行时点采样为准并注明时点 |
| tracked 树 | 1,927 文件／17.25 MiB | 1,927 文件／17.26 MiB（`git ls-tree -r -l HEAD` blob 求和） | ✅（注：`stat` 口径得 17.47 MiB 系符号链接解引用膨胀，blob 口径与设计锚全等） |
| pack | 56.01 MiB／25,987 对象 | 56.01 MiB／25,987 对象／1 pack | ✅ 全等 |
| loose | 1,315 对象／6.65 MiB | 1,315 对象／**6.65 MiB**（`git count-objects -vH` 前台复算，packs＝2、size-pack 合计仍 56.01 MiB、garbage 0） | ✅ 计数与体积均与锚全等。更正记：本链早前曾录一读数「4.23 MiB／packs 1」并归因于计量口径差——该读数出自后台 exec 会话的过期文件视图（与本链 Phase 0 首轮产物丢失同源），**已作废**；前台复算与设计锚逐值一致，无口径差 |
| garbage | 0 | 0 | ✅ |
| 四 worktree 目录 | 141M／30M／30M／26M | 父目录 du 224M；逐目录 141M／30M／30M／26M | ✅ |
| 四分支 ahead | 0／0／0／2 | 0／0／0／2（`git rev-list --count main..<branch>`） | ✅ 全等 |
| `.tad/` | 163M（evidence 133M／archive 17M／active 4.6M／capability-packs 2.9M） | 168M（evidence 133M／archive 17M／active 4.7M／capability-packs 2.9M） | ✅ 总差 +5M＝**本链 Phase 0 自产证据**（基线清单 3.9M＋差集件 1.4M，落 `.tad/evidence/epic-p4-scale-20261006/`）；active +0.1M 为 P4 票/HANDOFF 件 |
| evidence 子面 | yolo 64M／acceptance-tests 40M／research 9.2M／reviews 5.9M | 64M／40M／9.2M／6.0M | ✅ reviews +0.1M 为 P3/P4 评审件增量 |
| 证据载体 | maintainer-evidence 15,456 文件；acceptance-tests 1,642；yolo 8,058；main 跟踪 evidence 2 件 | 15,456／1,642／8,058／2（`git ls-files .tad/evidence`） | ✅ 全等（注：子串 grep 得 1,644 系 codex-regression 沙箱内同名路径 2 件混入，前缀口径复算与锚全等） |
| `.opencode/node_modules` | 62M | 62M（`.opencode` 全量 62M） | ✅ |
| brain-index | 24,904 B／Generated 2026-09-16／解码 byte 4158 失败／NEL 15 | 24,904 B／2026-09-16／严格解码在 byte 4158 失败 ✅；0x85 字节原始计数 17 | ✅ 损坏位点全等；NEL 计数差为口径差（设计锚为「孤立 NEL」计数、本次为原始字节计数，含合法多字节序列的续接字节）——AC10 判据以修复后产物 NEL＝0 为准，不受基线口径影响 |
| usage log | 6 行／4,530 B／2 链 | 6 行／4,530 B／全行 JSON 可解析／genesis 1＋usage 5／链 2 | ✅ 全等（逐件计数 Phase 3 盘点件复核） |
| patterns 差集 | 盘上 17 件（含 `_index.md`）／索引 13 行／差 3 件 runtime-adapter-instance | 17／13／恰 3 件（codex/cursor/opencode） | ✅ 全等 |
| incidents | 仅 2026-05、2026-06 两月目录 | 同（25 件在盘） | ✅ |
| locale | `LC_CTYPE="POSIX"` | `LC_CTYPE="POSIX"` | ✅ |
| **tad.sh 锚** | 任务书所给设计锚 sha `ce4002bc…` | Phase 0 时点盘面 sha **`947a8614f838ac8031d5633caafb8648aa88ec62892143c2472211ded106540a`**（HEAD `68593e82` blob） | ⚠️ **按增补 B5：原设计锚自动让位，本行复算值即 Phase 0 锚**，记行于此。前台复算 blob 谱系（更正记）：`7e407b7c`／`9acf585d` 时 blob＝`c6b4e658…`，P3 实施提交 `dd3aa449` 改至 `947a8614…`、HEAD 同值；设计锚 `ce4002bc…` 与本机近版 blob 均不符、其来源不在本链可验范围（早前一后台读数所记谱系已作废，同 loose 行）。备份修复链（tadsh-backup-fix）实施提交**尚未落盘**（HEAD 仍 `68593e82`、其链在实施中）——Phase 1 步 4 接线按 B5 串行序暂跳，待其实施提交到盘后以届时 tad.sh 为锚开工 |

**`.sync-conflict` 基线（AC9 用）**：Phase 0 采样命令 `find . -name '*.sync-conflict*'`（仓根内）＝ **8 件，全部位于 `.git/` 内**（`refs/remotes/origin/*.sync-conflict-20261005-*` 与 `logs/refs/remotes/origin/*.sync-conflict-20261004/05-*`，均为 2026-10-04/05 既存冻结副本，非本链产生）；仓工作树内（`.git` 外）＝ **0 件**。删除执行前后以同命令同口径比对。

## B. 顶层盘点表（分类照 HANDOFF §4.1 定案；体积为 Phase 0 du 实测）

| 对象 | 体积 | 性质 | 分类 | 同步影响 | 决议 |
|---|---|---|---|---|---|
| `.worktrees/tad-yolo2-candidate` | 141M | Mac 侧 worktree 的同步副本（本机非活 worktree，`.git` 指针指向 `/Users/sheldonzhao/…`）；含 116M／11,292 件 gitignored 证据工作副本＋9 件与尖端内容不同 | **(b) 级·必留（本链）** | 删除会经 Syncthing 传导对端 | 本链不删；比对见 `worktree-comparison.md`；去向归 PM/属主 |
| `.worktrees/local-wiki-phase3` | 30M | 同上副本形态；在盘内容为分支尖端树的**子集**（零多余、零改动，缺 28 件——同步通道名称过滤，见比对件） | **(b) 级（规则字面）／子集等值候选（待 PM 裁）** | 同上 | 停步点候 PM 确认（D-P0-1） |
| `.worktrees/local-wiki-phase3-native` | 30M | 同上（缺 28 件，同过滤集合） | 同上 | 同上 | 同上 |
| `.worktrees/tad-yolo2-scope-proof` | 26M | 同上（缺 27 件） | 同上 | 同上 | 同上 |
| `.tad/evidence/`＋`.tad/archive/` 磁盘副本 | 133M＋17M | 多链证据直读面；权威载体已在 maintainer-evidence 分支（外置已完成） | **必留** | 本地工作面 | 零触碰（REQ-2）；.gitignore 既有注记明文保留 |
| `.git` pack 历史 | 56.01 MiB | 历史大 blob（证据载体分离前入史：31.35MB 验收件、spike 缓存群等） | **必留** | — | history rewrite 唯一瘦身路，代价＝全谱系失效，**本链不提议不执行**（D-1 已裁准）；仅记行：未来若立项须独立议题、归 PM |
| `.git` loose 对象 | 1,315 件 | 未打包对象 | **瘦身（可直接执行）** | 无（不动任何 ref） | Phase 2 `git gc` 常规整理，风险≈0 |
| `.opencode/node_modules/` | 62M | 本机运行时依赖（Phase 3 OpenCode 插件运行面），`.opencode/.gitignore` 排除 | **必留（本机）** | 同步到对端纯属浪费 | 本机保留；**建议行**：以 `.stignore` 在同步面排除——属 yun-sync 文件夹层（GM/infra 面），不在本链写集（D-5 已裁：收口随 Epic 完成通知转 GM/infra） |
| `.tad/` 其余（active 4.7M／capability-packs 2.9M／hooks、scripts、templates 等合计约 10M） | ~17M | 活框架面 | 必留 | — | 零动作 |
| `.agents/` | 5.8M | 活框架面（skills 投影） | 必留 | — | 零动作 |
| `.reading/` 1.8M、`docs/` 960K、`assets/` 852K、`research/` 364K、根目录文件 | ~4M | 活文档/资产面 | 必留 | — | 零动作（docs 较设计锚 944K +16K 为 P4 开跑卡等链务件） |
| `supabase/` | 20K | 跟踪态历史层 | 必留（本链零删改） | — | 引用扫描：tracked 内 7 件提及该路径（含自述与历史记录）；系整洁议题非体量议题，去向若需动作另立小单 |
| `experiments/` | 160K | 同上 | 必留（本链零删改） | — | 引用提及 12 件；同上 |
| `.tad/spike-v3/` | 708K | 同上 | 必留（本链零删改） | — | 引用提及 9 件；同上 |
| `codex-tad-bundle/` | 308K | 同上 | 必留（本链零删改） | — | 引用提及 4 件；同上 |
| `tad-work/` | 224K | 同上 | 必留（本链零删改） | — | 引用提及 4 件；同上 |

五处历史层合计 <2.5M（实测 1,420K＋spike 708K＝约 2.1M），与 §4.1 定性一致：整洁问题不是体量问题，本表不将其列为瘦身来源。

## C. 复测节（Phase 2 执行后回填）

- **复测终值（Phase 2 续行，2026-10-06T13:54Z 删除后、gc 后采样）**：
  - `git count-objects -vH`（gc 后）：count **0**／size **0 bytes**（gc 前 loose 1,315 件／6.65 MiB 全数入 pack）；in-pack **27,302**（gc 前 25,987）；packs 2；size-pack **56.02 MiB**（gc 前 56.01 MiB）；garbage 0。`git gc` 为本续行唯一 git 写动作，未动任何 ref（HEAD 仍 `68593e82`、version.txt 仍 `3.1.0`）。
  - 全仓总量：**440M**（`du -sh .`，删除＋gc 后）。较 R1 基线 521M **下降 81M**；较本续行执行时点采样 530M 下降 90M，逐项归因如下（对盘点表 §B 行）：

    | 归因项 | 盘点表行 | 额 |
    |---|---|---|
    | 删除 `local-wiki-phase3`（删除前 du 实测） | §B 子集等值候选行 | −30M |
    | 删除 `local-wiki-phase3-native` | 同上 | −30M |
    | 删除 `tad-yolo2-scope-proof` | 同上 | −26M |
    | `git gc`（`.git` du 67M→60M；loose 对象面清零、pack 体积基本不变） | §B loose 行 | −7M |
    | 并行链浮动（单列，不算本链账）：tadsh-backup-fix 链在飞写入（tad.sh／tad-update.sh 在盘改动、其测试与证据产物）＋du 兆级取整 | — | +3M |
    | **净额（对执行时点 530M）** | | **−90M** |

    对基线口径复核：521M（R1）→530M 的 +9M 时点差已于 §A 链末附记归因（并行链当日写入），故 521M→440M 的 −81M 与上表 −90M＋9M 严格相符，**无未归因差额**（du 兆级取整内）。AC5 达成形态照 PM 裁定（删除＋gc 构成、执行时点采样）。
- **删除执行记录（AC9）**：执行时点 **2026-10-06T13:54:01Z–13:54:19Z（UTC）**，静默点声明：执行窗口内本仓无其他写入方对 `.worktrees/` 动作，删除在单条命令内一次完成；删除集＝PM 裁定的三 (a′) 目录，无其他。删除前后 `.sync-conflict*` 计数（仓根 `find` 同口径）：**8 → 8，相等**（8 件全在 `.git/` 内、为 2026-10-04/05 既存冻结副本，工作树内前后均 0 件）。删除后断言：三目录 `test -d` 均不存在、`.worktrees/` 仅余 `tad-yolo2-candidate`，且 candidate `test -d` **仍在盘**（141M 未动，AC3 删除负控成立）。**后记（gc 连带，如实补记）**：AC9 的「删除前后相等」以删除命令内的 8→8 为判据时点；其后 `git gc` 的 pack-refs 步骤将 `.git/refs/remotes/origin/` 下 loose ref 文件打包移除，其中 3 件 `.sync-conflict` 冻结副本（refs 面）随之消失，续行末复验总计数为 **5**（余 5 件全在 `.git/logs/refs/` 内）；工作树面（`.git` 外）计数全程 0→0 不变。该 −3 系 gc 标准 ref 打包的 .git 内部连带、非删除动作所致，特记明以免 Gate 3 读数矛盾。
- 回退验证节（AC4，承接 B 常设规程）：**已于删除前执行并全过（2026-10-06，Phase 2 续行 Blake）**。依据 PM 裁定 `.tad/evidence/pm/2026-10-06-epic-p4-dp01-ruling.md`（(a′) 子集等值级＋逐目录复行 AC4 条件）。方法：逐目录 `git archive <分支尖>` 物化至隔离面（`/tmp/p4-ac4/<dir>`），同法生成 sha256 清单，与 `worktree-baseline-manifest.txt` 对应段（段行数含 `.git` 指针行 1 件、比对时排除）逐行比对。首轮脚本因基线清单分隔形态（哈希后 3 空格）解析落空得空集假 PASS，**当场作废**、改固定列宽解析重跑，下表为重跑真值：

| 目录 | 分支尖（复核未移） | 基线段行数（不含指针） | 物化件数 | tip 独有（＝Phase 0 missing） | 在盘缺于 tip | sha 不一致 | 判读 |
|---|---|---|---|---|---|---|---|
| `local-wiki-phase3` | `feat/local-wiki-phase3` `f7e99dc0` | 2,366 | 2,394 | 28 | 0 | 0 | ✅ 全等（子集向） |
| `local-wiki-phase3-native` | `feat/local-wiki-phase3-native` `f235e377` | 2,386 | 2,414 | 28 | 0 | 0 | ✅ 全等（子集向） |
| `tad-yolo2-scope-proof` | `tad/yolo2-scope-proof` `69194cd1` | 2,232 | 2,259 | 27 | 0 | 0 | ✅ 全等（子集向） |

三目录在盘内容 100% 可由对应 ref 物化还原（还原路径已证），准按裁定执行删除。`tad-yolo2-candidate` 不在本验证与删除范围（实质 (b)，冻结在盘）。

## D. 停步点待 PM 裁定（D-P0-1）

比对实测（详见 `worktree-comparison.md`）：三目录（local-wiki-phase3／-native／tad-yolo2-scope-proof）在盘内容**逐件 sha 与分支尖端全等、无任何多余或改动文件**，仅因同步通道对含 `token`/`secret`/`.env` 名称文件的系统性过滤而缺 27–28 件——即在盘内容是尖端树的**真子集、唯一字节为零**，删除不销毁任何 ref 不可还原的内容。但 HANDOFF §4.1 (a) 级字面定义要求「差集为空」，缺失亦在 (b) 触发列。故按字面四目录全 (b)、(a) 级候选为空集。请 PM 在停步点裁定：(i) 子集等值是否按 (a) 级同等对待（三目录合计 86M，裁后 AC5 净降可达）；或 (ii) 维持字面，本链零 worktree 删除、AC5 达成形态另裁（P2-1 预留情形）。

**裁定结果（2026-10-06）**：PM 裁 (i) 变体——立 (a′) 子集等值级、三目录准删（条件：删除前逐目录复行 AC4＋静默点＋冲突计数比对），`tad-yolo2-candidate` 实质 (b) 本链绝不删。正本 `.tad/evidence/pm/2026-10-06-epic-p4-dp01-ruling.md`。执行结果见 §C（AC4 三目录全等、2026-10-06T13:54Z 删除毕、总量 440M）。
