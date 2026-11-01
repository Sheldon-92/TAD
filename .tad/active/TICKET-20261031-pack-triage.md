# Ticket: capability pack 存量分诊（技术研究席咨询提案的裁定与处置）

- **Status**: OPEN（裁定已下；执行排 4.0.9 后批次——台账小修随小修批先行，分诊主体到批次开立 Epic）
- **Owner**: TAD PM（Muse 侧 TAD 席位，裁定属主）

## 来源

- 用户 2026-10-31 亲嘱咨询工作法后，本席向技术研究席发咨询单（submission cd7d3e13）；提案正本：tech-radar 仓 `consult/pack-efficacy-2026-10-31/proposal.md`＋`external-evidence.md`（tech-radar/main c1025285）。
- 提案一句话倾向：冻结新增、存量分诊、兼容待办结清。本席裁定：**全盘采纳**，三待拍点裁定如下。

## 裁定（2026-10-31，TAD PM）

1. **补验窗口**：到 v4.0.10 发版收口为止（一个发版周期）。窗口内 pending 12 包用基线失败派生法补验（先跑对照组、专挑其做错/做漏处建 fixture）；到期未验自动转「观察」：退出默认加载面、保留文件、不再算 pack 资产。
2. **台账状态词表**：接受改动——新增正式状态值「无判别力」（验过、无 delta），失败不许再藏注释；verified 分级表述：现 9 个降格记为 verified-discriminative（单 fixture 存在性证据），verified-in-use 留给将来的真实任务回放＋触发率证据。
3. **compatibility**：本席无具名在等消费方，提案改判条件不成立——「Phase 2 兼容检查」待办**裁**；`synced_from_version` 字段保留为元数据；裁决理由写回注册表注释（防后人重捡）。真需要跨版本兼容时，消费方是发布同步的自衍生校验（EPIC-20260601 先例），按真实需求另立。

## 处置清单（提案汇总表，本席采纳）

- verified 9：保留＋台账降格表述；抽 3 个做触发层抽测（真实任务 prompt 下的加载率——Vercel 评测 56% 未被调用是最大盲区）。
- web-backend、data-engineering：按台账自家 follow-up 收紧判别式（pack 独有规则号/阈值）重验一次；再无 delta 降级为普通参考文档、退出 pack 体系。
- pending 其余 12：见裁定 1。
- ml-training（no-fixture）：不装（装它与冻结新增口径冲突）——摘除注册，文件保留备查。
- 未入台账 2 包（agent-computer-interface、ai-podcast-production）：先补台账行，再按 pending 同规。
- 新增 pack：即日冻结，至本分诊关账。
- 成本读数：补验批次顺手抽 2–3 个真实任务记带包/不带包 token 与轮次差（数量级即可）。

## 执行分工

- 台账小修（状态词表、补 2 行、compatibility 注释回写、9 包降格表述、ml-training 摘注册）：随 4.0.9 后小修批先行，机械改＋回读。
- 分诊主体（收紧重验、补验窗口、触发抽测、成本读数）：4.0.10 批次开时立 Epic 走全链（设计→实施→双审→验收），本票到时并入 Epic 输入。
