# COMPLETION — TASK-20261005-TAD-CLOSEOUT-BATCH（本体收口批）

> 状态：**Phase 0 完成时 CF-3 停步（§2 留痕）→ PM 裁定采甲案（`.tad/evidence/pm/2026-10-05-closeout-batch-cf3-ruling.md`）→ 续跑 Phase 1–3 全部完成，AC1–AC16 逐条实测见 §6**。gate3_verdict：**PASS**（CODE 路 `.tad/evidence/reviews/2026-10-05-gate3-code-review-closeout-batch.md`、SAFETY 路 `.tad/evidence/reviews/2026-10-05-gate3-safety-review-closeout-batch.md` 均 PASS、证据否决未触发；Gate 4 PASS `.tad/evidence/reviews/2026-10-05-gate4-acceptance-closeout-batch.md`）

## 1. 结果总览

| Phase | 状态 |
|---|---|
| Phase 0 基线、断言与盘点 | ✅ 完成（分类表 §3、基线 §4、CF-3 枚举 §2） |
| Phase 1 条文与脚本 | ✅ 完成（件 7／件 3／件 6／件 2 脚本面；AC14／AC5／AC13／AC3 干跑全过） |
| Phase 2 投影与断言 | ✅ 完成（件 4 物化＋件 4b 指针行＋件 5 断言三态；AC7–AC12 干跑全过） |
| Phase 3 版本收口与总验 | ✅ 完成（bump 两面＋裁定扩面 16 行、双生成器终态重跑；AC1／AC4／AC11／AC15／AC16 全过） |

## 2. ⛔ CF-3 停步记录（报 PM 裁定）

- Phase 0 按 publish-protocol step3c 形态 detect-only 实跑：
  `bash .tad/hooks/lib/release-verify.sh version "$PWD" "3.0.1" "3.0.0"`
  → **exit 1，VERDICT: version FAIL — 191 stale ref(s)**。
  全文捕获：`.tad/evidence/closeout-batch-20261005/cf3-release-verify-version.txt`。
- HANDOFF CF-3 口径：「门判 live stale 且在写集外 → 停步报 PM，不许自行扩写集」。191 件全部在 §7 写集之外，故本链停步。以下分诊仅供 PM 裁定，Blake 未自行判 live/非 live：
  - **类 A·历史叙述型（绝大多数）**：陈述 v3.0.0 事件本身的文本——各 pack `install.sh` 的「removed in TAD v3.0.0」错误消息与版本注释、`ARCHIVED (v3.0.0)` 文件头、`.tad/tests/**` fixture 钉版值（如 `state-surface-fixture/.tad/version.txt`、FIXTURE.md 的正负控说明）、docs 的「升级到 v3.0.0」历史节、CHANGELOG 式记录等。此类文本在 patch 升版时按语义不应改写（改写即篡改历史陈述），疑为门的 over-report 面。
  - **类 B·疑似活复述（点名请 PM 逐件裁定）**：
    - `.tad/TAD-VERSION:1` 内容即 `3.0.0`（§2.2 已注：脚本面无引用、疑似遗留复述，归 CF-3 门判）
    - `.tad/config.yaml:1` 注释头 `TAD Configuration v3.0.0` 与 `:3 version: 3.0.0`
    - `tad.sh:26 TARGET_VERSION="3.0.0"`（§2.2 已注 L39 有 version.txt 派生赋值路径，何者生效需裁定）
    - `package.json:3 "version": "3.0.0"`
    - `README.md:3,190`、`INSTALLATION_GUIDE.md:3,55`、`PROJECT_CONTEXT.md:4,6`、`docs/MULTI-PLATFORM.md:3`、`docs/CODEX-USER-GUIDE.md:3` 的现行版本陈述行
    - `.agents/skills/alex/SKILL.md:50` 与 `.agents/skills/blake/SKILL.md:166` 的 `<!-- TAD v3.0.0 Framework -->` 标记行
    - `.agents/skills/tad-help/SKILL.md:17 Version: v3.0.0 | Generated: [timestamp]`（形态似模板示例行）
    - `NEXT.md:10` 当前版本行（属保留集，CF-2 已定其头部行回填归 PM 收口面）
- **需 PM 裁定**：① 类 B 逐件定性（live 须扩写集／非 live 豁免）；② 若扩写集，授权范围点名；③ 或裁定本批不升版（FR9/AC15 作废）绕开本门。裁定前 Phase 1–3 不开工。

## 3. 件 1 提交面分类表（Phase 0 当值，AC2 底稿）

基线：`git status --porcelain | wc -l` ＝ **72**（捕获 `.tad/evidence/closeout-batch-20261005/git-status-baseline.txt`，与表逐行对账）。
注：`.tad/evidence/**` 不出现在 porcelain 输出中（该树在 main 无 git 载体）；本链自产证据件（设计说明、Gate 2 双 verdict、PM 裁定件、增补说明、本 COMPLETION、`.tad/evidence/closeout-batch-20261005/` 捕获）按 §4.2 预授权口径归丙层，在此点名留痕。

| # | 状态 | 路径 | 层 |
|---|---|---|---|
| 1 | M | `.agents/skills/gate/SKILL.md` | 甲层（件 7 写集；现含 D 线在册改动） |
| 2 | M | `AGENTS.md` | 甲层（件 4b＋版本标记）＋乙层（D 线 +16 行节，同文件分 hunk 判读） |
| 3 | M | `.agents/skills/alex/SKILL.md` | 丙 |
| 4 | M | `.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md` | 丙 |
| 5–16 | D | `.tad/active/handoffs/` 既有 12 件删除（B 线迁档面；设计文称 11 件，Phase 0 实测 12 件，与 tech 路 P2 注记一致） | 丙 |
| 17 | M | `.tad/gates/gate-canonical-checklist.md` | 丙 |
| 18 | M | `.tad/project-knowledge/patterns/ac-verification.md` | 丙 |
| 19 | M | `.tad/project-knowledge/patterns/shell-portability.md` | 丙 |
| 20 | M | `NEXT.md` | 丙 |
| 21–25 | M | `docs/pm/{acceptance,auth,intent,now,ops-knowledge}.md` | 丙 |
| 26 | ?? | `.tad/TAD-POINTER.md` | 丙 |
| 27–29 | ?? | `.tad/active/TICKET-20261004-course-judgment-adoption.md`、`TICKET-20261004-evidence-carrier-recovery-execution.md`、`TICKET-20261005-tad-closeout-batch.md` | 丙 |
| 30 | ?? | `.tad/active/handoffs/HANDOFF-2026-10-05-tad-closeout-batch.md` | 丙（本链自产件，§4.2 点名） |
| 31–32 | ?? | `.tad/scripts/evidence-freshness-check.sh`、`.tad/scripts/sync-maintainer-evidence.sh` | 丙 |
| 33 | ?? | `.tad/templates/dispatch-risk-card.md` | 丙 |
| 34–71 | ?? | `docs/pm/open-cards/**` 38 件（含本链四张开跑卡） | 丙 |
| 72 | ?? | `docs/pm/ops/` | 丙 |

其余写集文件（release-runbook SKILL、evidence-collection.md、scan-downstream-versions.sh、scan-packs.sh、pack-registry.yaml、downstream-versions.md、version.txt）基线时点为 clean，未出现在 porcelain 中，属甲层待改面。
`ROADMAP.md` 基线时点 clean、未出现；若后续出现按 §4.2 归丙层。

## 4. 基线记录（Phase 0）

- AC1 基线（C1 节哈希）：`sed -n '/^### File authority order/,/^### Interaction decisions/p' AGENTS.md | head -n -1 | sha256sum`
  ＝ `849ea922ba24d94768d5c2f107d3f6b4ecbb09d19fd12dde3eea0ed99bce7c38`
  （与设计完工说明基线参考值 `849ea922…` 一致）
- 写集各文件 `wc -l`＋`sha256sum` 全表：`.tad/evidence/closeout-batch-20261005/phase0-baselines.txt`
  （AGENTS.md 184 行／gate SKILL 1003／release-runbook 148／evidence-collection 448／scan-downstream 108／scan-packs 195／registry 210／台账 68／version.txt 1）
- Step 0 路径断言：cwd ＝ `/home/hatch/workspace/yun-sync/TAD` ✅；§7 全部 MODIFY 目标绝对路径 `test -f` 逐件通过 ✅
- shell-portability.md 全文已读 ✅（LC_ALL=C 于 comm/sort、grep 于 $() 的 set -e 陷阱等与本批脚本改动相关条目已记）

## 5. 写集落点

Phase 1–3 实际写面（仓根 `/home/hatch/workspace/yun-sync/TAD`，全部绝对路径操作；git 写操作零）：

| 件 | 落点 | 变化 |
|---|---|---|
| 件 7 | `.agents/skills/gate/SKILL.md` Gate 3 内联副本 | 注释行改 7 items 计数（含 recount fix 注）、`Critical Check (7 items):`、Knowledge Assessment 行后新增 Provenance 行一行；对 HEAD 的 numstat 8+/3− 含 D 线在册 hunk，本件三处按行集判读未回退 |
| 件 3 | `.agents/skills/release-runbook/SKILL.md` | 「Mechanical authority」节后、「Global safety stops」前整节插入 §4.4 草案（+46 行、−0），与草案代码块抽取 diff 为空（逐字） |
| 件 6 | `.tad/tasks/evidence-collection.md` | §7 后、Pattern Recognition 前整节插入 §4.8 草案（+20 行、−0），抽取 diff 为空（逐字）；插入时 awk 重写曾给文件末行补尾随换行，已恢复原 EOF 状态，终态 diff 仅插入节 |
| 件 2 | `.tad/scripts/scan-downstream-versions.sh` | source-of-truth printf 后插入「覆盖口径」printf 一行（+1/−0）；台账本体由 Phase 3 重跑生成（见下） |
| 件 4 | `.agents/skills/research-methodology/`（新建 12 件） | CREATE 集：SKILL.md（CAPABILITY.md 删 `status: frozen` 一行派生，257 行）＋references 5＋checklists 1＋scripts 2＋LICENSE＋LICENSE-ATTRIBUTION.md＋CONVENTIONS.md（11 件与本体 sha256 逐件全等）；禁入四件零出现 |
| 件 4b | `AGENTS.md` Capability Packs 表 | L152 插入 research-methodology 指针行（rag-retrieval 与 synthetic-data 之间），第二列＝registry description 前 70 字符，与 §4.6 给定逐字行脚本比对全等 |
| 件 5 | `.tad/scripts/scan-packs.sh` | 三处落位＋断言段：`--packs-dir` 分支置 `PACKS_DIR_WAS_OVERRIDDEN=1`、`pack_names` 初始化与循环内收集、结尾 echo 前植入 §4.7 断言段（对 HEAD numstat 24+/1−）；`bash -n` 通过 |
| 版本 | `.tad/version.txt` 首行、`AGENTS.md` L9 标记 | 3.0.0 → 3.0.1（§4.10 两面） |
| 扩面 | 裁定扩面 12 文件 16 行 | 逐件见 §6 AC15 点名表，全行改前均单次出现 `3.0.0`、逐行定点替换 |
| 生成面 | `.tad/capability-packs/pack-registry.yaml`、`.tad/evidence/pm/downstream-versions.md` | Phase 3 以改后脚本重跑生成终态（registry numstat 2+/2− 为头部字段；台账 7+/6− 含头注行与 TAD 行版次更新） |

NEXT.md／ROADMAP.md 零触碰（PM 收口面回填，裁定 ③）；类 A 168 件一件未动（裁定 ②）。

## 6. AC 逐项（Phase 1–3 续跑实测，2026-10-05）

| AC | 实测值 | 判 |
|---|---|---|
| AC1 | AC1 原命令（节域提取）Phase 3 复算 ＝ `849ea922ba24d94768d5c2f107d3f6b4ecbb09d19fd12dde3eea0ed99bce7c38`，与 §4 Phase 0 基线**全等**。注：续跑中曾误用整文件 diff 口径复算得 `f604e364…`，查 HANDOFF §5 AC1 原文后确认判据为节域哈希、按原命令重算全等——口径误读已当场纠正，C1 节本身零改动 | ✅ |
| AC2 | §3 分类表（Phase 0 当值，72 行逐行对账，甲 2／乙同文件分 hunk／丙其余） | ✅ |
| AC3 | 脚本内 `grep -n '覆盖口径'` 恰 1 命中于 L93；source-of-truth printf 在 L92、`# 下游仓版本台账` printf 在 L95，行序合判据；`bash -n` 通过 | ✅ |
| AC4 | 生成后台账 `.tad/evidence/pm/downstream-versions.md`：`覆盖口径` 恰 1 命中于 L4，标题 `# 下游仓版本台账` 在 L6（4＜6）；生成器 exit 0（total=53） | ✅ |
| AC5 | awk 行序断言 `ORDER_OK`（Mechanical authority L113 ＜ Project slot 节 L126 ＜ Global safety stops L172）；`PROJECT-SLOT:BEGIN`／`END` grep 各 ＝1；落盘节与 §4.4 草案抽取 diff 为空 | ✅ |
| AC6 | rubric 判读面（Gate 3）：§4.4 五要素（标记对／覆盖前备份／回贴＋逐字比对／无槽存量逐案留痕／trading-agent L1–4 迁移口径）均在落盘节内，Blake 侧已证逐字落盘（见 AC5） | ✅（待 Gate 3 rubric 判） |
| AC7（Gate 2 修订版） | 七项结构判据全过：① 目录＋SKILL.md 在册；② 文件集 12 件与预期集合相等（SET_EQUAL）；③ 禁入四件（CAPABILITY.md／README.md／CHANGELOG.md／install.sh）零出现；④ 符号链接 0；⑤ SKILL.md frontmatter `name: research-methodology` ＝目录名；⑥ 占位符 `{{`／`[TODO]`／`[TBD]` grep 各 ＝0；⑦ 非 SKILL 11 件与本体 sha256 逐件全等（ALL_11_SHA_EQUAL） | ✅ |
| AC8 | 投影内 `grep -RInE '^status: '`（*.md／*/*.md／*/*.sh）exit 1 零命中；scan-packs.sh 既有 status 清理 grep 未动（本批对该脚本的改动不含该行，见 git diff） | ✅ |
| AC9 | `diff CAPABILITY.md SKILL.md` 输出恰一行：`6d5 < status: frozen`（删行在 frontmatter 内，落笔前断言 `^status: ` 全文恰 1 次且位于首个 `---` 围栏后） | ✅ |
| AC10 | `grep -c '^| research-methodology |' AGENTS.md` ＝1（L152）；第二列长度 70（∈[60,75]）、以 `Unified research pipeline` 开头；整行与 §4.6 给定逐字行脚本比对全等（裁定口径：前 70 字符硬截断） | ✅ |
| AC11 | Phase 3 重跑 `scan-packs.sh` exit 0；重跑前后「包名＋status」对集合 diff 为空（SET_OK，Phase 2 正控时亦同）。**计数口径注记**：实测 25 对，非设计文所记 26——`.tad/capability-packs/` 共 26 个目录，其中 `agent-computer-interface/` 无 CAPABILITY.md、不在 scan-packs 登记面内（批前既存盘面，本批未改）；集合相等这一实质判据成立，「26」为设计按目录数计的口径差，在此注明供 Gate 3 判读 | ✅（口径注记如左） |
| AC12 | 同 fixture（`/tmp/closeout-fixture-Ld73IM`）三态齐：对照（未改脚本、pack-b 缺投影）exit 0；负态（植入后、pack-b 缺投影）exit 1 且 stderr 点名 `pack-b`（`ERROR: registered pack(s) missing .agents/skills projection: pack-b`）；正态（补 pack-b 投影）exit 0。捕获：`fixture-control-unmodified.txt`／`fixture-negative-missing.txt`／`fixture-positive-complete.txt`（`.tad/evidence/closeout-batch-20261005/`） | ✅ |
| AC13 | 行序断言 OK：§7 节首 L245 ＜ Capture Path Discipline 节 L284 ＜ Pattern Recognition 节 L304；`mktemp` grep ＝1、`Cross-check before citing` grep ＝1；落盘节与 §4.8 草案抽取 diff 为空 | ✅ |
| AC14 | 三段合取全真：`Critical Check (7 items)` grep ＝1 且 `6 items check 6 distinct artifacts` grep ＝0；`Provenance non-empty` grep ＝1；列表项数 gate SKILL 内联副本 ＝7、Canonical Gate 3 节 ＝7，两边同为 7 | ✅ |
| AC15 | 字面四项：`.tad/version.txt` 首行 ＝ `3.0.1`；`AGENTS.md` 中 `(v3.0.1)` grep ＝1、`(v3.0.0)` grep ＝0；批号 v3.0.1 与 HANDOFF §4.10／票面一致。扩面 16 行逐处点名（改后值）：`.tad/config.yaml` L1 注释头 `v3.0.1`、L3 `version: 3.0.1`；`.tad/TAD-VERSION` 整行 `3.0.1`；`tad.sh` L26 `TARGET_VERSION="3.0.1"`；`package.json` L3 `"version": "3.0.1"`；`README.md` L3 标题行 `Version 3.0.1`、L190 `# Should show: 3.0.1`；`INSTALLATION_GUIDE.md` L3 `Version 3.0.1`、L55 `应显示 3.0.1`；`PROJECT_CONTEXT.md` L4 `Version: 3.0.1`、L6 `TAD v3.0.1`；`docs/MULTI-PLATFORM.md` L3 `Version: 3.0.1`；`.agents/skills/tad-help/SKILL.md` L17 `Version: v3.0.1`；`.agents/skills/alex/SKILL.md` L50 `<!-- TAD v3.0.1 Framework -->`；`.agents/skills/blake/SKILL.md` L166 同标记；`docs/CODEX-USER-GUIDE.md` L58 `应显示 3.0.1`。参考核查：`state-surface-check.sh` check3 PASS（五件 DECL 全 ＝3.0.1）、check4 PASS；check1／check2 FAIL 系 NEXT.md／ROADMAP.md 头部未回填（裁定 ③ 的 PM 收口面，本步按裁定不碰）；check5 四项 FAIL 为 session-state 索引指向已迁 archive 件的批前既存引用，与版本无关。捕获 `state-surface-phase3.txt` | ✅ |
| AC16 | Phase 3 porcelain 93 行 vs Phase 0 基线 72 行：基线行零消失（comm 差集为空，丙层逐行一致）；新增/变化 21 行中 18 行属本批写集＋扩面＋生成面（逐件见 §5）、1 行为新建投影目录 `.agents/skills/research-methodology/`、2 行为 PM 本链开跑卡落盘（`docs/pm/open-cards/2026-10-05-closeout-batch-cf3-triage-start-card.md`、`...-impl-resume-start-card.md`，PM 侧链内过程件、非 Blake 写面，在此点名披露）。封顶未破 | ✅ |

（AC2 底稿见 §3，AC1 基线见 §4。原「待回填」占位行由本节取代。）

## 7. Knowledge Assessment

- **新发现 1（判据口径）**：AC 类哈希判据必须先认清其作用域——AC1 的哈希是「节域提取」而非「整文件 diff」，两者数值天然不同。续跑中按整文件口径首算不等、查原文后按节域口径全等。教训：复算命令逐字照 AC 原文（含 sed 提取段），不许凭「canonical 形式」的一般印象代用。
- **新发现 2（登记面口径）**：scan-packs 的「登记」以 CAPABILITY.md 在册为准，目录数（26）≠ 登记数（25）；无 CAPABILITY.md 的目录（agent-computer-interface）既不登记、也不受件 5 断言约束（其投影实存）。今后凡引「pack 总数」先分清目录数／登记数两口径。
- **Phase 0 遗留观察的处置**：§2 类 A over-report 观察已由 CF-3 分诊与裁定闭环（类 A 按 patch 口径放行、恒久口径修订登记入完事卡遗留节），本节不再重复立条。

## 8. Friction Status

- CF-3 停步一处（§2），属设计预置的停步阀正常触发，非执行摩擦；PM 裁定后同链续跑关闭。
- 续跑过程两处自纠（均当场发现、当场纠正、未污染写面）：① AC1 首算误用整文件 diff 口径（见 §6 AC1 注）；② evidence-collection.md 插入时 awk 重写补入 EOF 尾随换行，已恢复（见 §5 件 6）。
- §4.7 草案 bash 块抽取曾误抓他节代码块（HANDOFF 内该块带列表缩进、围栏非行首锚），改按行号直取后逐点核对落位，未落错位。

## 9. Evidence Checklist

- [x] `.tad/evidence/closeout-batch-20261005/git-status-baseline.txt`（72 行）
- [x] `.tad/evidence/closeout-batch-20261005/phase0-baselines.txt`
- [x] `.tad/evidence/closeout-batch-20261005/cf3-release-verify-version.txt`（exit 1 全文）
- [x] Phase 1–3 证据（`.tad/evidence/closeout-batch-20261005/`）：`registry-names-status-baseline.txt`（25 对基线）、`fixture-control-unmodified.txt`／`fixture-negative-missing.txt`／`fixture-positive-complete.txt`（AC12 三态）、`scan-packs-realtree-phase2.txt`（真实树正控）、`scan-packs-realtree-phase3.txt`（Phase 3 终态重跑）、`scan-downstream-phase3.txt`（台账终态重跑）、`state-surface-phase3.txt`（AC15 参考核查）

## 10. Provenance

- 实施者：Blake（原生 subagent），依据 HANDOFF-2026-10-05-tad-closeout-batch.md（66,327 B／sha256 `dabaf3298234e72855e03874090c18525cb8d0a2095216ba8744c20c40af242e`，开工复算全等）＋ PM 合并裁定（Gate 2 PASS）。
- git 写操作：零。本件与 §3/§4 全部数字均为 2026-10-05 Phase 0 当场实跑值。
- 续跑（Phase 1–3）：Blake（原生 subagent），依据同上 HANDOFF＋PM 裁定 `.tad/evidence/pm/2026-10-05-closeout-batch-cf3-ruling.md`（采甲案）＋分诊件 `.tad/evidence/pm/2026-10-05-closeout-batch-cf3-triage.md`（扩面逐件口径 §2／§6.1）；§5/§6 全部数字为续跑当场实跑值；git 写操作：零。

## 11. 读取清单打勾回执

- [x] 仓根 AGENTS.md（角色原文＋Knowledge Ingress）
- [x] `.tad/project-knowledge/principles.md`
- [x] `.tad/project-knowledge/patterns/_index.md`；全文读 `shell-portability.md`（HANDOFF 指定必读）
- [x] HANDOFF 本体全文＋PM 合并裁定（含定点核销账，Gate 2 PASS）
- [x] publish-protocol step3c 段（CF-3 枚举形态出处）
- [x] `.tad/tasks/evidence-collection.md` §7 区与 gate SKILL Gate 3 节（续跑 Phase 1 动手前已读）
- human CHECK：CHECK 待人
