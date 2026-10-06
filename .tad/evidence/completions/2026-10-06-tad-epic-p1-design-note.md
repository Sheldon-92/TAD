# 设计完工说明 — Epic Phase 1 本体清账批（设计步）

- **task_id**: TASK-20261006-EPIC-P1-CLEARANCE
- **角色**: Alex（Solution Lead），设计步
- **日期**: 2026-10-06
- **交付物**: `.tad/active/handoffs/HANDOFF-2026-10-06-epic-p1-clearance.md`
  - 字节数：**52,982 B**
  - sha256：`767941d8af434449f6c44f95462be3749303c08fe5446a64c89393fcab31fbf8`

## HANDOFF 章节在册清单

Quality Chain Metadata（task_id／tad_scope=full／required_evidence_manifest 九件）→ 标题块 → Gate 2 节（设计完整性自检／高风险触发项逐项核对表／逐件装载点位表）→ Handoff Checklist → §1 Task Overview（12 件总表）→ Project Knowledge → §2 Background（基线锚 MQ-1…MQ-8）→ §3 Requirements（FR-1…FR-12）→ §4 Technical Design（§4.1–§4.11 逐件）→ §5 强制问题回答（Q1–Q5）→ §6 Implementation Steps（Phase 0–3）→ §7 File Structure 写集总表（MODIFY 14／CREATE／FORBIDDEN）→ §8 Testing Requirements → §9 Acceptance Criteria → §9.1 Spec Compliance Checklist（AC1–AC23，文法仅 command｜path-check｜fixture）→ §9.2 Expert Review Status → §10 Important Notes（CF-1…CF-6／发版衔接／红线）→ §12 Sub-Agent 使用记录。

## 逐件落点速览

| 件 | 裁断/落点 |
|---|---|
| 1.1 校验器 | **裁断：改校验器**（双类契约 Class P/A；理由四条在 §4.1，头条＝type/keywords 三处承重消费者）。A2 自检＝publish-protocol 新 step3c3（受治集＝登记面 25＋alex/blake，恒阻塞）；product-thinking 投影补 type/keywords 两行镜像 CAPABILITY，正文不动 |
| 1.2 版本口径 | publish-protocol step3c 前言＋publish-ops §3「改面推导规则」（四源并集＋detect-only 逐 hit 分诊＋分诊记录落 `.tad/evidence/releases/`），封顶表述清扫入 AC5 |
| 1.3 史述面 | publish-ops 新 §3.1 六分类（L/H1/H2/H3/F/D）＋未归类停步条；step3c minor/major 分支加门条件（分诊记录覆盖 100% hits，未分类即硬拦）；本批零改史述面（AC6 抽样 diff 兜底） |
| 1.4 check5 | session-state 索引四子串定点改指归档（逐串点名，含 platform-adapters 的 EPIC 子夹路径）；防再发句入 gate-execution Gate 4 节 |
| 1.5 计数口径 | 登记面定义句同句两落：handoff-a-to-b.md §9.1 引导区＋scan-packs.sh 断言节头注 |
| 1.6 genesis | 三件套：tad.sh 初装写 genesis.yaml（不覆写、文件名对链图惰性）；engine resolve_chain 加 TARGET 参数、链首 genesis 锚定（版本不符/链中段仍 REJECT）；step3d 发版 hop 义务＋存量补登口径（只登记不造假，执行属下游刷新面）。发布源禁自带 genesis.yaml（AC12） |
| 1.7 hooks.json | **裁断与 GM 登记原倾向反向**：设计步亲测生成器 heredoc 输出含尾随逗号、jq exit 5（非法 JSON），存档件才是合法正本——heredoc 向存档件逐字节对齐，存档件本体不动；语义比对口径句入 publish-ops §2.5（jq -S 值序列，覆盖下游旧式生成件） |
| 1.8 driftcheck | 新增 B_dir 集与 (r) registry-only 格（advisory 永不判 drift）；(c) 收窄为 A∖(B_dir∪C)；(d) 收窄为 C∖B_dir；C 集不可得时显式声明行；三层口径对照表成文（源仓断言／driftcheck／探针），与 scan-packs 登记⊆投影同口径对齐 |
| 1.9 断言 | state-surface 新增 check6（从 AGENTS.md Knowledge Ingress 节提取无条件读单、阻塞）／check7（Generated 年龄恒 INFO、＞14 天 WARN、不可读 FAIL）；AGENTS.md 过期注记句同批订正（CF-4）。**安装面覆盖（跨侧核验补入）**：设计步亲测 brain-index.md 在 tad.sh `TAD_TOP_DENY` 内、安装集恒不携带，目标侧靠 brain-index-gen.sh 生成且现行自动调用带 `\|\| true` 静默——已列 Phase 0 核查点（初装 fixture 验三件事），处置规则先定：缺则 tad.sh 初装后加可见失败的生成步、生成器坏死则停步；断言面以 AC23 fixture 覆盖安装面check6 |
| 1.10 B1 | evidence-collection.md 新节（Capture Path Discipline 之后）：一句定义＋正向探针要求＋强度标注三档（probed/observed-absent/assumed），附 2026-10-05 BrowserSkill 假令牌 401 实例锚。条文已在 HANDOFF §4.10 定稿 |
| 1.11 D3 | 模板 `.tad/templates/root-cause-report.md` 全文草案在 §4.11（定因/定界/验证＋填写指引＋复发三问）；指针句入 gate-execution.md Violation Handling 节首 |

## 设计内关键盘面结论（供 Gate 2 打靶）

- 校验器全树实测 PASS 22／FAIL 41；登记面 25 pack 败因＝23 件多键、2 件 authored-tree 禁入件（product-thinking、web-frontend）。
- 件 1.9 的 sighting 最可能出处已定位：发布源与 grokbox 副本 brain-index 均实存（跨侧核验，同字节 tracked），缺口在安装面（deny 名单不携带＋生成可静默失败）——断言只查发布源会永远绿，故 AC23 补安装面。
- 已知弱点自报三条（HANDOFF §9.2）：genesis 三处写点可达性待 Phase 0 追踪；check6 提取规则对 AGENTS.md 节格式敏感；driftcheck (b) 11 件存量未治、源仓总 exit 不承诺为 0。

## 读取清单打勾回执

- [x] tad-alex skill 壳（`~/workspace/skills/tad-alex/SKILL.md`）已加载、按指针进仓读原件
- [x] 仓根 AGENTS.md（含 File authority order、Knowledge Ingress、Lite 冻结注记）
- [x] `.tad/project-knowledge/principles.md`
- [x] `.tad/project-knowledge/patterns/_index.md`，命中条目读全文 ≤3（shell-portability 等）
- [x] `.tad/tasks/handoff-creation.md`；形态前例 `.tad/archive/handoffs/HANDOFF-2026-10-05-tad-closeout-batch.md`
- [x] `.tad/gates/gate-canonical-checklist.md` Gate 2 节（风险卡触发项与装载点位判据原文）
- [x] Epic `.tad/active/epics/EPIC-20261006-tad-self-optimization.md` Phase 1 节；票 `.tad/active/TICKET-20261006-epic-p1-clearance.md`
- [x] 完事卡遗留 `docs/pm/open-cards/done-20261005-tad-closeout-batch.md`
- [x] GM 登记三件 `.tad/evidence/pm/2026-10-05-gm-input-migration-genesis.md`／`-hooks-json-format.md`／`-driftcheck-registry-only.md`
- [x] 判断正本 `.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md` A1/B1/D3 节
- [x] CF-3 分诊与裁定 `.tad/evidence/pm/2026-10-05-closeout-batch-cf3-triage.md`／`-cf3-ruling.md`
- [x] PM 跨侧核验补件（brain-index 双侧实存＋安装面核查要求）——已入 §4.9 与 AC23

## 纪律自报

本步只写 HANDOFF 与本说明两件；仓外零写；git 只读。下一程：PM 验盘 → Gate 2 双审（须就件 1.1 裁断与件 1.7 反向裁断给明确结论）→ 合并裁定 → Blake 实施。
