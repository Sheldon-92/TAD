# Gate 3 评审 — Epic Phase 1「本体清账批」（CODE 路）

- 评审对象：HANDOFF-2026-10-06-epic-p1-clearance（终态 54,502 B／sha256 `5cc95395…`，开审复算全等）＋ COMPLETION-2026-10-06-epic-p1-clearance（11,130 B）
- 判据：票 TICKET-20261006 §9.1 AC1–AC23（修订后文本）、PM 合并裁定（Gate 2）、PM AC23 裁定（2026-10-06）
- 审法：AC 逐条原样实跑复算——含自建 fixture（校验器负控、初装/升级、driftcheck 三形态、check7 骨架、scan-packs 隔离副本），不采信实施者捕获件作判据（仅作对照）。

## 结论：PASS（P0＝0／P1＝0／P2＝3，均非关闭条件）

证据否决子款**未触发**：实施者自报的每一个关键值经本审独立复算均逐值相符（受治集 27/27、genesis 字段与哈希不变性、hooks 805 B 逐字节、check7 fail 计数 9→10、driftcheck 输出逐字节、AC16 捕获与本审实跑仅差其尾注一行）。

## AC 逐条复算结果（本审实测）

| AC | 判 | 本审实测值 |
|---|---|---|
| AC1 | PASS | 现场名单（registry 25＋alex＋blake）逐一 `validate "$PWD" <name>`：**27/27 exit 0** |
| AC2 | PASS | 自建 fixture 三连均 exit 2 且因由逐字同自报：(a) 白名单外键 owner；(b) type 与 CAPABILITY 不符；(c) 非 authored-tree 根置 README |
| AC3 | PASS | `save-skill` exit 2（extra keys）、`alex-lite` exit 2（块标量＋extra keys），Class A 严契约未放行 |
| AC4 | PASS | product-thinking type/keywords 与 CAPABILITY 逐字一致；正文 sha256＝`c6a83fc4…`＝Phase 0 基线 |
| AC5 | PASS | 推导规则段在 publish-protocol（L107 区）与 publish-ops（L110 区）各 1 处、内容与 §4.2 四项构成全等（Registry∪check1–3∪前例未覆盖∪{version.txt, 标记行}＋分诊记录路径＋patch advisory 前提）；封顶模式集两文件 grep **零命中** |
| AC6 | PASS | publish-ops §3.1 六类齐（L/H1/H2/H3/F/D）＋未归类停步条＋记录四字段；step3c minor/major 含 100% 覆盖＋未分类硬拦句；史述面抽样 diff 空（本审另查 6 件：仅 CODEX-USER-GUIDE 有 1 行 diff，mtime 2026-10-05、本链开工前一日，非本链且不在抽样集内）；A7 历史行（capability-skill.sh L442「removed in TAD v3.0.0」）在盘未动 |
| AC7 | PASS | state-surface 全量实跑：check1–7 全 PASS/INFO/WARN、**exit 0**（check5 已转绿） |
| AC8 | PASS | 四归档路径逐一 `test -f` 全在盘；gate-execution L267 迁档回写衔接句命中 |
| AC9 | PASS | 登记面定义句在 handoff-a-to-b §9.1 引导区与 scan-packs 断言节头注两处命中且同句 |
| AC10 | PASS | 本审自建初装 fixture：genesis.yaml 在盘、五字段齐（schema_version/kind/installed_version/installed_at/install_form）＋installer/note，installed_version＝3.0.1＝目标 version.txt；重跑初装后 genesis sha256 **不变** |
| AC11 | PASS | engine 正控：`NOTE: genesis-anchored at 3.0.0`＋`No manifests found`＋exit 0；负控 mismatch（installed_version 不符）→ REJECT exit 2；负控 midgap（3.0.0→3.0.1 有 hop、3.0.1 后断）→ `REJECT: chain gap at 3.0.1` exit 2；tad.sh 全路径升级演练：NOTE＋exit 0＋genesis 未覆写＋版本进 3.0.1 |
| AC12 | PASS | 发布源 `.tad/migrations/genesis.yaml` 不存在；NOTE 锚串在 migration-engine.sh L716 |
| AC13 | PASS | publish-protocol step3d（L185–191）含 hop 义务句与存量补登口径句 |
| AC14 | PASS | 本审 fixture 经真 tad.sh 初装路径生成的 `.codex/hooks.json` 与存档件 `cmp` **逐字节一致**（805 B）、`jq -S` exit 0 |
| AC15 | PASS | 语义比对双控：改一处 timeout 值 → 规范化比对判不等（漂移）；仅 jq 重排格式 → 判相等（非漂移） |
| AC16 | PASS | driftcheck 源仓实跑与自报捕获逐字节一致（仅差尾注）：(r) 节在且为空、(c) 为空、product-thinking 不在 (c)、无失实文案；总 exit 1 仅由 (b) 11 件批外存量驱动（CF-2／§9.2(c) 预声明口径，见 P2-2） |
| AC17 | PASS | 自建三形态 fixture 各归其格：(i) 幻影名落 (c) 且 exit 1；(ii) 有源包＋投影无 type 行落 (r)、exit 0；(iii) 无源包集打印 `Set C unavailable` 声明行、(c) 只按 B_dir 判、exit 0 |
| AC18 | PASS | 同 AC7 实跑：含 `PASS check6`（5 paths）与 `INFO check7 … age 20d`＋超阈 WARN，总 exit 0 |
| AC19 | PASS | 自建骨架仓精确复现：Generated 改 400 天前 → INFO age 400d＋WARN、总 fail 9（check7 不计）；删 Generated 行 → check7 FAIL、总 fail 10（恰 +1） |
| AC20 | PASS | Negative Evidence Discipline 节在 evidence-collection L304（Capture Path Discipline L284 之后、Pattern Recognition L313 之前），positive probe 与 strength label（probed/observed-absent/assumed）两要素齐 |
| AC21 | PASS | `.tad/templates/root-cause-report.md` 在盘（1,549 B）：定因/定界/验证三段标题＋复发三问指引齐；gate-execution L296 Root-Cause-First 小节含模板指针 |
| AC22 | PASS（附注判读） | porcelain 84 行逐行归属完毕：本链写集 14 件（session-state.md 经 .gitignore:35 豁免不入 porcelain，其盘面改动由 check5 PASS 与字节表 sha 见证）∪PM 扩展 3 件∪本链自产件（票/Epic/HANDOFF/CREATE 模板/开跑卡）∪批前既存脏面（B 线迁档删除、保留集、旧链开跑卡组——COMPLETION 附注已如实披露）；改动 6 脚本 `bash -n` 全过；scan-packs 隔离副本实跑 exit 0、25 packs |
| AC23 | **PASS（附归因）** | 按 PM 裁定以 installer 供给面判读。事实经本审自建初装 fixture 独立复现：副本 `.tad/brain-index.md` **实存**（Generated 当日、副本 check7 age 0d）——件 1.9 处置目标达成；check6 同法提取五件中四件 project-knowledge 路径在副本缺失，成因为 installer Option A zero-touch 设计（tad.sh L2663/L2680 明文：新装只给 README 种子、上游 principles/patterns 永不拷贝），属项目自著面、不在 installer 供给面内，不作缺陷计 |

## 案 A 扩展面行级保真（按 PM 裁定要求独立复核）

三件 CAPABILITY.md（agent-orchestration／web-frontend／web-testing）与对应投影的 `keywords:` 行逐字全等（本审逐件比对）；type/version 无分歧，与 HANDOFF §7 扩展注记「仅 keywords 一行」相符。仓内 registry 仍为旧值一节，PM 裁定已列入发版收口清单（隔离副本 regen 实跑生成 25 packs、断言 exit 0，本审 AC22 同法复现），不算实施缺口。

## P2 注记（非关闭条件）

- **P2-1**：AC5 的推导规则锚段以英文落文（HANDOFF §4.2 草案为中文），实质构成全等、判据满足；仅记语言形态差，供后续模板双语对齐参考。
- **P2-2**：AC16 源仓 driftcheck 总 exit 仍为 1，系 (b) 11 件 skill-only 存量（登记滞后、CF-2 批外）置位，与本批 (c)/(r) 判读面无关；Gate 4 判读 driftcheck 时以分节为准、勿以总 exit 误判件 1.8 未过。
- **P2-3**：件 1.7 的双文本同源面（tad.sh heredoc 与 `.codex/hooks.json`）本批靠注记＋语义比对口径防漂移、无机器闸（CF-6 已明记成本判断）；本审 AC14/AC15 实证口径当前有效，机器闸与否留 Phase 2 测量面议，与设计一致。

## 评审过程自记（透明）

本审首轮 AC17 fixture 因自建 registry 缩进格式不合解析器（Set A 读 0）与首轮 midgap 骨架源缺 hooks 组件各失败一次，均系评审侧 fixture 构造问题、非实施缺陷；按正确形态重建后三形态与负控全部精确复现自报值。已在上表按复现后值判读。

自报行：正文 7679 B／sha256 `6d3d1d76b95e6be3060df492b6a27e249f0b344b34647bda6981c186b885a3ed`（不含本行；落盘后以 head -c 复算核对）
