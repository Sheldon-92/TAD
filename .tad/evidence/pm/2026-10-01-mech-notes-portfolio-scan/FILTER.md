# FILTER — TASK-20261001-mech-notes-portfolio-scan

分类输入为前刀 GAPS，不重做三洞存在性扫描。yes = 建议下一刀吸收，未实施；defer = TAD 本地延期；hand-GM = 交回 GM 的职责清单，未发送消息。组合重点为国际站+买卖；TAD 仅轻吸收能力基础设施。以下路径均为建议载体，不是写入授权或 HANDOFF。

| note/gap | absorb-now? (yes/defer/hand-GM) | why portfolio-useful or not | suggested carrier path if yes |
| --- | --- | --- | --- |
| charter / HO / model-routing 可解析指针；intent 旧默认与悬空本地路由引用 | yes | 各 PM 席与 GM 共用路由，陈旧默认会造成错派。只保留共享 SSOT 和临时人令指针，把历史先例明确标为历史；不复制模型表，不创建第二份 SSOT。依据前刀 GAPS 路由行、GM LAND、共享 model-routing。 | `docs/pm/intent.md`；直接指向 `/home/box/云同步/grok-cloud/docs/model-routing.md`、`docs/pm-charter.md`、`docs/pm/human-operating.md` 及 GM 临时锁文件 |
| PM 完事/阶段收口禁裸 WAIT；候选名或 HOLD 原因+解锁人 | yes | 让 GM 能衔接组合下一步，避免停工状态无人接。沿 HO §3.8b；候选不等于派活授权，禁止用空值/none 代替 HOLD。 | `docs/pm/acceptance.md`；`docs/pm/templates/exit-human-card.md`（拟建，轻量引用共享模板/规则） |
| 禁「群里只发要拍」；完事/要拍/观感走 PM↔人 1:1 | yes | 全组合统一沟通边界，减少群内决策噪声；前刀只发现本地规则缺口，未证明实际违规。沿 HO §3.9。 | `docs/pm/acceptance.md`；与上一行共用 `docs/pm/templates/exit-human-card.md` |
| 开跑正文落盘+同正文 1:1+step stamp，顺序与真实声明 | yes | 其他席已按 HO §3.7b 工作；TAD 席应能发现同一义务，不能把盘卡当聊天已发。只接 PM 操作规则和共享模板指针，不造包装或检查器。 | `docs/pm/auth.md`（引用 HO §3.7b/§3.7d 与共享 `templates/open-run-card.md`） |
| 复述文件非空、人理解正确迹、包装指针对齐 | yes | PM 与执行侧共同依赖的派活输入，跨席可复用。沿 HO §3.7d/§3.10，保留 discuss 不作 Blake 依据的边界；不另加 TAD 需求仪式。 | 与上一行共用 `docs/pm/auth.md`，引用共享 `templates/restate.md` |
| PM 正式交付收口 KA 显式勾选/无新发现；有项目记忆时盘⇄私有脑两勾，或显式本刀无项目记忆 | yes | 让 GM 跨席追踪收口资产；前刀已有原生 KA，缺的是 PM 接口。沿 HO §3.12，仅接字段与指针，不改 Gate 所有权；盘/脑自述不当外部验证。 | `docs/pm/acceptance.md`；`docs/pm/templates/exit-human-card.md` 引用共享 `templates/gate4-pm-closeout.md`；已有 `docs/pm/ops-knowledge.md` 作记忆盘指针 |
| 上游 Epic/session-state/NEXT/completion 模板逐一补 next_knife_candidate | defer | 禁裸 WAIT 本身有组合价值，逐改 TAD 内部模板只是本仓流程覆盖；PM 席接口先补即可。HO §3.12 明确本轮先改 PM、不改上游。 | — |
| 重建 TAD 原生 KA、改 SKILL/config/Gate 所有权，或另造通用开跑/复述模板体系 | defer | 原生 KA 前刀已判 yes；重复建设无新增跨席收益，扩大能力基础设施负担。轻量 PM 引用足够；无具体失败证据不升级。 | — |
| 当前刀模型记录已有 yes、已有开跑实例/9月21双写实例 | defer | 保留为历史证据；继续美化或回填实例不能补齐共享规则，也不能证明本刀聊天/脑写完成。 | — |
| 临时 Codex 偏好到期/额度变化复检、模型目录及共享路由维护 | hand-GM | 影响全组合新派，属 GM 控制面。临时文件写默认至 10月3日末再检、额度吃紧或人改口即停；TAD 仅引用，不把临时锁永久化、不切进行中模型。 | — |
| 前刀指出共享 gate4 模板候选占位 none 与 HO 候选/HOLD 语义不齐 | hand-GM | 是共享模板源的跨席问题，不是 TAD 上游缺口。本刀沿用前刀提醒，不重扫模板；由 GM 核验源文件并决定修正，TAD 不照抄空候选。 | — |

来源：本仓 `.tad/evidence/pm/2026-10-01-mech-absorb-scan/{STATUS,GAPS,RECOMMEND}.md`；GM `.tad/evidence/pm/2026-10-01-mech-hole-patch/{STATUS,LAND,ACCEPTANCE}.md`；共享 HO §§3.7b/3.7d/3.8b/3.9/3.10/3.12；共享 `docs/model-routing.md`；GM `ops/codex-prefer-temp-2026-10-01.md`。外仓相对路径分别以 `/home/box/云同步/gm/` 和 `/home/box/云同步/grok-cloud/` 为根。
