# Gate 2 技术路独立评审 — Epic Phase 4「体量与知识复产」（TASK-20261006-EPIC-P4-SCALE）

- 评审路：tech（与 fit 路独立、互不可见）
- 评审者：Alex（Solution Lead，原生 subagent，tad_alex 壳激活）
- 日期：2026-10-06
- 对象：`.tad/active/handoffs/HANDOFF-2026-10-06-epic-p4-scale.md`（49,664 B／sha256 `4acb634139a1…`，开工复算全等）
- 参照：设计说明 `.tad/evidence/designs/2026-10-06-tad-epic-p4-design-note.md`；PM 裁断 `.tad/evidence/pm/2026-10-06-epic-p4-design-rulings.md`（D-1–D-5）
- 判据：`.tad/gates/gate-canonical-checklist.md` Gate 2 八项；纪律：只读（干跑仅 /tmp 隔离副本，已清）、git 只读、真仓 brain-index 干跑后逐字节未动（cmp 对干跑前副本全等）

## 激活自报（已读原件）

薄壳 `~/workspace/skills/tad-alex/SKILL.md`；仓内 `AGENTS.md`、`.tad/project-knowledge/principles.md`、patterns `_index.md`＋命中全文 3 件（release-sync、shell-portability、ac-verification）、`.tad/tasks/gate-execution.md`、`.tad/gates/gate-canonical-checklist.md`（Gate 2 节）；被审三件全文；生成器 `.tad/hooks/lib/brain-index-gen.sh` 全文亲读；tad.sh 相关段亲读。

## 总判：CONDITIONAL PASS

无 P0。设计的安全架构（件 4.1 三闸＋(a)/(b) 分级）经实测抽核证明判别力成立；全部基线锚复算对齐；接线点与装载点逐项实存。两条 P1 均为 HANDOFF 文本层面的判据/范围措辞问题，修订不需重设计、不动 §3/§4 架构；修订后可直接放行 Blake，Gate 3 判据（AC10/AC11）本身即构成对两条 P1 的机器复核。

## 逐项实测（设计锚 → 本路复算）

### ① 体量三面 — 全等
- 总量 524M ✓；`.worktrees/` 224M ✓（四目录 141/30/30/26M 逐一全等）；`.tad/` 163M ✓（evidence 133M、yolo/yolo2-verified-orchestration 62M、archive 17M、active 4.7M、capability-packs 2.9M）；`.git/` 67M ✓；`.opencode/` 62M ✓；根目录其余逐项全等（docs 948K vs 设计 944K，du 取整差，可归因）。
- `git count-objects -vH`：pack 56.01 MiB／25,987 对象 ✓、loose 1,315 件／6.65 MiB ✓、garbage 0 ✓。
- tracked 树：1,927 文件 ✓／17.26 MiB（设计记 17.25，ls-tree 求和口径尾差，可归因）✓。
- pack 最大 blob 31,351,794 B ✓（设计 31.35MB）、次大 10,176,524 B ✓（设计 10.18MB）。
- 面 C：main tracked evidence＝2 文件 ✓；maintainer-evidence 尖 `ea54399f` ✓、全分支 15,456 文件 ✓、acceptance-tests 1,642 ✓、yolo 8,058 ✓。
- HEAD `68593e82` ✓、`.tad/version.txt`＝`3.1.0` ✓。

### ② 件 4.1 worktree 两级处置与三闸 — 方法成立（预估数字见 P2-1）
- 四目录 `.git` 指针全指 `/Users/sheldonzhao/云同步/TAD/.git/worktrees/…`（Mac 侧路径、本机不存在）✓「本机非活 worktree、只是文件副本」成立；分支 ahead：local-wiki-phase3 0／-native 0／scope-proof 0／yolo2-candidate 2 ✓；`.gitignore:20` ✓。
- **比对法抽核（本路亲跑）**：`git archive feat/local-wiki-phase3` 物化尖端树 → `diff -rq` 对副本：副本 2,367 文件 vs 尖端 2,394 文件；差集 29 行＝28 件 tip-only（多为 token/secret/.env 命名件与 examples 目录）＋0 件 differ＋1 件 copy-only（`.git` 指针，属预期）。按设计规则该目录判 **(b) 级**——分级流程在真实数据上判别力成立、且误判方向朝安全侧（多判 (b) 只少删、不误删）。AC4 回退验证形态（ref 物化→哈希比对）与本抽核同构，可执行 ✓。三闸顺序（比对→PM 确认停步→回退验证→执行）在 §6 写死、可审计 ✓。

### ③ brain-index 生成器根因 — 大方向成立，定案不完整（见 P1-1）
- 在盘件 24,904 B ✓、Generated 2026-09-16 ✓；check7 活跑：age 20d＋advisory WARN（阈值 `BRAIN_INDEX_WARN_AGE_DAYS=14`，state-surface-check.sh:43 ✓，不计 FAIL ✓）。
- 源文件合法：principles.md（25,219 B）、AGENTS.md 均 UTF-8 严格解码通过 ✓。
- **隔离干跑复现（/tmp 副本，本路亲跑，两 locale 串行）**：POSIX 产物 25,332 B，严格解码失败 5 处（byte 759／1900／3249／4170／21765 区）；`LC_ALL=C.UTF-8` 产物 25,320 B，仍失败 2 处（4158／21753 区）。在盘件失败点 4158 与 C.UTF-8 干跑同位 ✓（设计「两 locale 同位失败」属实）。设计干跑 25,243 B 与本路差约 90 B，系设计后树内新增 P4 票据/HANDOFF 件的行增量，可归因。
- 缺陷解剖（本路定案，细于设计）：损坏有**两类点位**——(i) 摘要/字段的 `cut -c1-120`（及 L250 的 `-c1-80`）字节截断：本机 GNU cut 9.4 经实测在 POSIX、C、C.UTF-8 **全部 locale 下均按字节计**（50 个汉字 `cut -c1-40` 三种 locale 均输出 40 字节），设计「POSIX locale 下按字节截断」的归因不精确，但「必须显式做字符安全截断、不能靠 locale」的结论方向不变且更强；(ii) **生成器 L37 标题日期后缀剥离 sed**：在 POSIX/C locale 下把标题尾的 `—` 劈成 `\xe2\x80` 残字节（实测 3 处标题行：Judgment-Only／Never Hand-Write／Deny-List Granularity；C.UTF-8 下该三处干净，od 对照实证），该路径**不经任何 cut**。
- fixture 判据足够性：AC10（`LC_ALL=C` 干跑＋严格解码 exit 0＋NEL 0）是全产物判据，任一类损坏都使其变红，且能判别「脚本内强制 LC_ALL=C.UTF-8」式伪修复（cut 仍按字节、必红）——判据集足够 ✓。AC11 措辞问题见 P1-2。

### ④ 下游刷新接线点 — 实存且定位准确
- `generate_target_brain_index()` 定义在 tad.sh:1142 ✓；全文唯一调用点在 tad.sh:2815、位于 `case $ACTION` 的 `"install"` 分支内 ✓「只接初装路径」属实；`upgrade`/`migrate` 分支独立存在（detect_state L2615–2674），接线落点真实、与设计「同一函数、同一失败口径」可执行 ✓。函数本体失败只 `log_warn`＋`return 0`（fail-open）✓ 与 §4.2-3 口径及 §8 接线负控（缺生成器只 WARN 不中断）一致，负控可构造 ✓。

### ⑤ 件 4.3 记账装载点三件 — 点位全真
- 模板：`.tad/templates/completion-report.md` 现有节含 `## 📖 Knowledge Assessment`（L198），**无 Knowledge Usage 节** ✓ 缺口真实、新增点位明确。
- 规程：`.tad/tasks/evidence-collection.md` 为分点收口结构（Evidence Collection Points §1–§6+），append 动作行有真实落点 ✓。
- 口径源：revival HANDOFF §4.5（archive 件 L310「D35 usage log 字段口径」）实存 ✓。
- 计数脚本判据：usage log 本路全量复算——6 行／4,530 B ✓、genesis 1＋usage 5 ✓、2 链 ✓、knowledge 共引 28 个不同件 ✓、最高 `inventory-summary.md` 4 提及／2 链 ✓、关键件跨链最高 2 ✓——D35 双条件（50 行／跨链 5）均未达，**D-3 空集结论驳验不成立、设计成立** ✓。合成 fixture 判读翻转（AC19）构造可行 ✓。
- patterns 对账：盘上 17 个 `.md`（含 `_index.md`）✓、索引登记 13 行 ✓、差集恰为 runtime-adapter-instance-{codex,cursor,opencode} 3 件 ✓（本路 comm 实测）。incidents 索引止于 2026-06 ✓（盘上仅 2026-05/06 两月目录）。

### ⑥ §10 发版 9 步与 3.2.0 并版 — 技术自洽
- hop 命名与在册件型一致：`.tad/migrations/` 实存 `3.0.1-to-3.0.2.yaml`、`3.0.2-to-3.1.0.yaml` ✓；§10 的 `3.1.0-to-3.2.0.yaml` 命名合法。在船断言形态沿 P2 件 2.9 有先例 ✓。
- CF-7 两段缺口实测确不存在（migrations 目录无 2.43.1-to-3.0.0、无 3.0.0-to-3.0.1）✓，§10 的去向建议以此事实为据成立。
- step3f 锚点真实：publish-protocol.md:237 `step3f:` 实存 ✓，§10 步 3「按发版清单实跑」有出处；步 4 的周期步与本链 AC16 同为 publish-protocol 内落点、首行使关系自洽 ✓。
- tag 步（步 6）与承接 D 三要素断言口径衔接 ✓；分诊落点 `.tad/evidence/releases/` 有 3.0.2/3.1.0 两代先例 ✓。
- 3.2.0 并版：与 PM 裁断 D-4 一致；本链 AC28 冻结自验（version.txt 逐字 `3.1.0`、未打 tag、未 push）使「备料只写不执行」可审计 ✓。技术面无矛盾。

### 设计内决断驳验结论（技术路）
- **D-1（pack 不重写）：赞同，且设计对收益的估计偏高**——最大 blob 31.35MB 在 pack 内已压至 1.88MB，pack 56.01MiB 为压缩后总量；重写可回收上限即此量级且与 maintainer-evidence 15,456 件的载体谱系共根。性价比判断成立。
- **D-2（(a)/(b) 分级）：规则成立**（抽核判别有效），预估句不成立 → P2-1。
- **D-3（复产清单空集）：成立**（计数复算全等，见 ⑤）。
- **D-4（终值 3.2.0）：技术自洽**（见 ⑥），终裁归 PM（已裁采纳）。
- **D-5（.stignore 只记建议）：写集边界与 §7 一致**，本路只确认技术事实：node_modules 62M 在 `.opencode/.gitignore:1` 排除面内、同步面处置确属仓外文件夹层，非本链可落点。

## Findings

### P1-1 根因定案不完整：§4.2-1 修复范围字面不覆盖 L37 sed 标题剥离
§4.2-1 写「把全部 `cut -c1-120` 类截断改为 locale 无关的 UTF-8 安全截断」。实测生成器 L37 的标题日期后缀剥离 sed 在 POSIX/C locale 下独立劈裂多字节字符（3 处标题行尾残 `\xe2\x80`，见 ③(ii)），该路径不经 cut。Blake 照字面范围执行将漏修此处，AC10（LC_ALL=C 严格解码）与 AC11（Deny-List Granularity 行标题即 L37 产物）必红，多耗一轮返工。**条件**：§4.2-1 修复范围改写为「全部字节不安全截断/剥离点——cut 各处（L12/45/50/94/95/116/139/157/178/213/229/250）＋ L37 标题 sed 后缀剥离」，验收仍以 AC10/AC11 的产物判据为准（判据本身不需改）。附带记明：以「生成器内强制 LC_ALL=C.UTF-8」充作修复在本机无效（cut 实测全 locale 按字节），Blake 勿走此路；AC10 fixture 可判别。

### P1-2 AC11 判据措辞与生成器既定行为矛盾，照字面判读会 false-FAIL 正确实现
AC11 要求两行标题「与 principles.md 原标题逐字相等」。实测源标题为 `### Deny-List Must Be Applied at EVERY Copy Granularity, and Verifiers Must Match Each Granularity — 2026-06-01` 与 `### AI/Human Judgment Domain Awareness — Agent 应自觉判断域归属 - 2026-07-03`——生成器按既定行为剥离日期后缀，正确产物与原始标题**不可能**逐字相等。**条件**：AC11 改写为「与源标题去日期后缀后逐字相等、无残字/替换符」；并注明两行的实测损坏部位——Deny-List 行为**标题段**（L37 sed），AI/Human 行为**摘要段**（cut，其标题本身未损），免 Gate 3 判读错位。

### P2-1 D-2 预估句与抽核不符；AC5 存在 gc-only 达标口径风险（不阻塞，建议 PM 在 Phase 0 停步点处置）
§5 D-2 称「(a) 级预估已含 224M 中的大部」。本路抽核 local-wiki-phase3（30M）实判 (b)（差集 29 行，见 ②）。若四目录多为 (b)，件 4.1 的下降将只剩 `git gc` 一路（loose 6.65 MiB 重打包＋prune，量级数 MiB），而 AC5 以 R1 基线 521M 为线、以现值 524M 起算需净降 >3M，达标与否取决于 gc 实测，口径悬空。建议：Phase 0 比对落盘后，PM 在删除确认停步点一并裁定 AC5 的达成形态（如四目录 (a) 级为空集时，以 524M 设计锚为复测基线、或接受 gc-only 降幅并在盘点件记录），不要留给 Blake 在 Phase 2 末撞口径。注：此为预估与判据基线问题，分级规则与三闸本身无缺陷。

### P2-2 §11「无并行在飞链」与盘面不符：tadsh-backup-fix 链同改 tad.sh，须 PM 定串行序
同日已立 `TICKET-20261006-tadsh-backup-fix`（full 档，改 tad.sh `backup_existing`/rollback 面）；本链改 tad.sh ACTION 分支接线面——同文件不同区域。两链若并行实施，diff 冲突与 tad.sh 自检/fixture 互相干扰的风险真实存在。建议 PM 明确两链 tad.sh 改动的先后序与后到链的 fixture 复跑义务；本链 §11 的冲突预检句按盘面订正。

### P2-3 AC23 的 hook 一致性判读源不存在
§4.3b/AC23 称 3 行 hook「照各文件内索引节实测撰写」、AC23 以「与各文件内索引节一致」为判据。实测 3 件 runtime-adapter-instance 文件内无索引节（grep 零命中；内容为标题＋六维声明表）。建议判读源改写为「文件标题＋六维声明内容」，或 Gate 3 以 rubric 判读相符性；否则 AC23 该子句不可执行。

### P2-4 §2.2 NEL 数字口径注记（不影响判据）
设计称在盘件含「15 个孤立 NEL(0x85) 字节」。本路复算：在盘件 raw 0x85＝17、fresh 干跑＝15；且 raw 0x85 计数混含合法 UTF-8 续字节，不能独立作判据。AC10 的实际判据形态（严格解码 exit 0＋解码后孤立 NEL 计数 0）成立且更强，此条仅为 §2.2 数字出处注记，Gate 3 按 AC10 原文执行即可。

## Canonical Gate 2 对照（技术路）

| 项 | 结论 | 依据 |
|---|---|---|
| Expert review complete (min 2) | 本路完成，待 fit 路与 PM 合并 | 本件 |
| All P0 resolved | ✅ 无 P0；P1×2 以条件提出，纯文本修订 | Findings |
| Architecture complete | ✅ | §3 四原则与四件结构经实测锚支撑 |
| Components specified | ✅ | §4.1–§4.4 写集/回退/负控齐备 |
| Functions verified | ✅ | 生成器全文、tad.sh:1142/2815、check7:43、模板与规程点位全亲测 |
| Data flow mapped | ✅ | §5 MQ3 与实测流向一致 |
| Risk card | 草案在 §11（ASM-1–3 证伪式齐备），正式卡待 PM 派发前落盘——属派发前置、非设计缺陷 | HANDOFF §11 |
| Load points declared | ✅ | 装载点表逐项核过：publish-protocol step0 REFUSE（L17）实存、AGENTS 路由实存、模板节为真实缺口点 |

**放行条件**：P1-1、P1-2 两处文本修订落 HANDOFF 后（PM 核销），本路转 PASS；P2 四条交 PM 处置/登记，不阻塞实施。

---

**自报**：本件 14,367 B；正文（本行之前）sha256 `8013cfa9e95e179522c6a6a4dfa86951ed3abe083adf6e35bf331ee9c2b4cad4`，全件字节数以落盘复算为准。
