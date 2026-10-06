# Gate 2 Tech Review — EPIC-P1-CLEARANCE（本体清账批）

- 评审对象：`.tad/active/handoffs/HANDOFF-2026-10-06-epic-p1-clearance.md`
- 开审对锚：52,982 B／sha256 `767941d8af434449f6c44f95462be3749303c08fe5446a64c89393fcab31fbf8`，与派发锚全等。
- 审法：AC1–AC23 逐条文法与命令面核对＋设计两处裁断与四处盘面实测的独立复跑（非采信自报）。

## 结论：CONDITIONAL（P0＝0／P1＝0／P2＝2；两项均为一行级增补，PM 定点核可销）

## 两处裁断的 tech 结论（应设计要求明示）

1. **件 1.1「改校验器」——支持。** 三处承重消费者本席独立实测属实：driftcheck Set B 探针以 `^type: (reference-based|deep-skill|orchestration-router)` grep 投影 SKILL.md（driftcheck L53）；scan-packs 自 CAPABILITY.md 抽 keywords 生成 registry（scan-packs L56–57）；指针表口径承前批实证。删键路线确会打断探针面。基线值复跑全等：`validate <root> <name>` 形态下 alex／blake exit 0、save-skill／alex-lite exit 2、抽测投影（academic-research／web-frontend／product-thinking）exit 2；academic-research 的报错原文正是「extra keys: version/type」，与 MQ-1 归因逐字吻合；product-thinking 投影根实存 README.md＋CHANGELOG.md、SKILL.md frontmatter 仅两键，其 exit 2 源于禁入件而非多键，与 MQ-1 的 authored-tree 归因一致；其 CAPABILITY.md 的 `type: deep-skill` 与 keywords 行在盘，AC4 抄写源存在。双类契约的 Class A 不回归可由 AC3 现值（双 exit 2）机械见证。
2. **件 1.7 收敛方向反向（以存档件为正本）——支持，且为本席亲测坐实。** 本席自 tad.sh 提取 heredoc 输出体实测：668 B、`jq` 严格解析 **exit 5**（parse error：尾随逗号，line 9）；存档件 `.codex/hooks.json` 805 B、jq exit 0。字节数与设计 MQ-6 逐值全等。生成器输出本身非法，GM 登记原倾向（存档向生成器收敛）确不可采，设计裁断成立。

## 其余指定复核点

- **件 1.9 两处盘面实测属实**：`TAD_TOP_DENY`（tad.sh L588）内容恰为 `sync-registry.yaml`＋`brain-index.md` 两行，安装/同步集恒不携带 brain-index 成立；quarantine 流程对 brain-index-gen.sh 的调用在 `quarantine-framework-pk.sh:135`，形态为 `>/dev/null 2>&1 || true`，失败静默吞属实。check6 提取面核对：Knowledge Ingress 节内无条件反引号路径与「If」条件行、glob 记号的分布与 §4.9 描述一致（见 P2-2 的计数订正）。
- **件 1.6 衔接可照行**：manifest 集实测止于 `2.43.0-to-2.43.1.yaml`；空操作前例属实（该文件 `delete: []`／`rename: []`＋note 在盘）；`resolve_chain` 在 migration-engine.sh L667、main 调用 L975、其后 L978 有 "No manifests found" 成功路径——锚定返回空链成功的接续点真实存在。genesis 文件名无 `-to-` 段对链图惰性的论证与 resolve_chain 按 from/to 组图的实现一致，AC11/AC12 可实证。
- **件 1.3 门条件句落点可核查**：publish-protocol step3c 是具名步骤（L98–99），其 exit 1＋minor/major → HARD BLOCK 分支为独立条目（L119–120），条件句有具体可 grep 的落位形态；AC6 以 §3.1 六类＋门条件句 grep 锚＋史述面抽样 `git diff` 为空判读，文法成立。
- **基线旁证**：state-surface 现跑 check1–4 PASS、check5 恰四项 FAIL，与件 1.4 清单逐项对应，四件归档实指本席抽验 2 件在盘。brain-index `Generated:` 行与约 20 天龄与 MQ-8 一致（前批已核）。

## 条件（P2，一行级）

- **C1（AC1–AC3 命令形态未钉死）**：`capability-skill.sh validate` 的真实调用形态是双参数 `validate <project-root> <skill-name>`；单参数调用恒回 usage 错误 exit 1（本席实测）。AC1–AC3 只写「validate exit 0/2」，未写明调用形态——实施者与 Gate 3 若按字面单参数跑，将得到全集 exit 1 的假判读。修正：AC1–AC3（及 §4.1 A2 自检步文）把命令形态钉死为 `capability-skill.sh validate "$PWD" <name>`（或等价根参数写法）。
- **C2（§4.9 无条件集计数与自家提取规则不符）**：§4.9 称现行无条件集「应为四件」，但按其自定提取规则（跳过含「If」行、glob、目录记号）对现行 Knowledge Ingress 节实跑，另有一件漏计：`.tad/project-knowledge/patterns/shell-portability.md` 出现在「Before editing any shell file…」句中，该行无「If」、非 glob、非目录记号，按规则应入集（实得五件）。该件实存，check6 结论不变，且 §4.9 已有「以 Phase 0 提取实跑为准冻结」的兜底，故仅 P2。修正：冻结清单按提取实得集（含此件）为准，或在提取规则中显式排除「Before editing」类条件句行，二选一写明。

## 非条件注记

- AC14 要求在隔离目录真走 tad.sh codex 生成路径——与 Phase 0 全新初装 fixture 同一演练面，可行但为全批最重 fixture；实施时应复用同一次初装演练取证，避免双跑。
- AC11 链中段缺 hop 负控需在 fixture 的 SOURCE 副本内自造 manifest 集构造中段链，§9.1 未写明构造法；mktemp 骨架内可照行（自造两 hop 缺其一），Gate 3 执行时以「构造在案」为准，不作条件。
- 件 1.1 双类契约的 fallback 判据（目标仓无 registry 时以 type 行判 Class P）与 (r) 分类的探针不可见形态存在一处已知张力：无 type 行的 Class P 件在无 registry 的目标仓会被判 Class A 而严拒——此为契约设计内可解释结果（validate 的辖区是发布源与安装自检面），本席记注不作条件。

（自报行见文末追加）

自报行：正文 5762 B／sha256 fe8cb37c4947070a37e44d213fdb1bad507c7452047d33e6d19d76dbe2fa7be8（本行追加后以 head -c 5762 复算）
