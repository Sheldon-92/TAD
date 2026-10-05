# EDGES — TASK-20261002-TAD-HYGIENE-EXIT-HO-CHARTER-EDGE-SCAN

Alex · discuss / scan only · 2026-10-02

分类含义：absorb-now = 有价值的 TAD PM 本地澄清候选，**本刀不实施、不代表下一刀授权**；defer = 无新增缺口或不应扩范围；hand-GM = 共享源/组合控制面归属 GM。本表不是 HANDOFF。路径以 TAD 仓为根；共享根为 `/home/box/云同步/grok-cloud/`。

| edge | TAD path checked | status | absorb-now/defer/hand-GM | suggested carrier |
| --- | --- | --- | --- | --- |
| 共享 charter / HO / 模型路由入口可发现性 | `docs/pm/intent.md`, `auth.md`, `acceptance.md`, `status.md` | 已吸收：intent 有绝对 SSOT 指针，auth/acceptance 分别指向开跑与收口规则；charter/HO 源可读。相对“云同步”引用不是独立职责源。未发现须另建入口的实际失败。 | defer | 保留现有指针；不复制 charter/模型表。 |
| 本地 `templates/` 为空，是否缺薄 wrapper | `docs/pm/templates/`, `auth.md`, `acceptance.md`; absorb `LAND.md` | 目录未枚举到文件；四个共享模板直接引用且可读，前刀明确无需 wrapper。空目录不是功能缺口。 | defer | 继续直接引用共享模板；仅有实际导航失败证据才考虑本地纯指针入口。 |
| exit / 完事 human_card 正文与禁静音成功路径 | `docs/pm/acceptance.md`; 共享 `exit-human-card.md`, HO §§3.8b/3.9 | 部分：本地已有 1:1 与候选/HOLD，尚未显式提示 human_card 必含“交了什么 / 怎样算过 / 要人回什么”及禁只写盘不发卡。共享模板已覆盖，属本地发现性澄清，不是新规则。 | absorb-now | 后续授权文档刀可在 `docs/pm/acceptance.md` 加一条引用共享 human_card 必填正文/禁静音；不创建 wrapper、不宣称已发送。 |
| 正式收口的是/否+一句、结果合同与 PM 所有权 | `docs/pm/acceptance.md`, `auth.md`; charter §3.1(5), HO §3.12(4) | 部分：本地写 Routine Gate4 由 Alex 收口；共享 PM 操作层明确 PM 拍板、agent 可列检查草稿，正式门4对照已批准结果合同写是/否+一句。本地未明确两层区别，易误读为另派验收 agent。 | absorb-now | 后续仅澄清 `docs/pm/{auth,acceptance}.md` 的 PM 操作接口与共享条文优先级；保留 TAD 原生 Alex Gate4 职责，不改 SKILL/Gate，不扩大授权。 |
| 正式观感 / exit-wake 前置盘证与 helper 入口 | `docs/pm/acceptance.md`, `ops-knowledge.md`, `ops/agent-tune-eval-hooks-draft-20260929.md`; HO §§3.4/3.12(5) | 部分：acceptance 只写观感 1:1；旧 draft 提到 human-look，但不是生效入口。正式观感须 PM 先过、一个预览最多三点，门3与门4盘证先齐、check=0、走 send helper；draft_preview / 开跑 / 红灯 / 诚实 BLOCKED 分支未在本地入口说明。未测试运行时 helper 或 wake。 | absorb-now | 后续 `docs/pm/acceptance.md` 轻引用 HO §3.12(5)，说明适用分支；不改脚本、不加第二闸、不把 discuss PASS 当正式门4。 |
| KA 与盘/脑分别勾选 / 无项目记忆分支 | `docs/pm/acceptance.md`, `ops-knowledge.md`; absorb `ACCEPTANCE.md`; 共享 gate4 模板 | 已吸收：KA、“无新发现”、两字段分别勾选并给指针、或“本刀无项目记忆”已明确；无需重复模板化。未核验外部脑或消息实际完成。 | defer | 保留现有正文与共享模板引用；PM 将来收口须按实际事实填写。 |
| 停工候选/HOLD 与共享 gate4 模板 `none` | `docs/pm/acceptance.md`, absorb segment; 共享 `templates/gate4-pm-closeout.md` | 本地已明确禁空候选；本次重新读源确认共享模板仍为 `<TASK-… or none>`，note 才另列 HOLD，和 HO §3.8b 不齐。前 FILTER hand-GM 仍成立。 | hand-GM | GM 核验/修正共享源；TAD 使用现有候选或 HOLD+原因+解锁人，不照抄 none。本刀未发送交办消息。 |
| 开跑 / 复述输入透明与 stamp 真实性 | `docs/pm/auth.md`, 本刀 restate; 共享 open-run/restate, HO §§3.7b/3.7d/3.10 | 已吸收：落盘→同正文1:1→stamp→包装、非空复述+理解正确迹、discuss 不能充 HANDOFF。共享模板补全六字段与地图位置；无须另造准入仪式。 | defer | 保留共享直接引用；实际发卡/运行证据由 PM 核验，不用盘上声明代证。 |
| 是否下一刀运行 FORGET-INDEX-EXECUTE-P0 | `segment-status/seg-20261001-{mech-absorb-scan,mech-notes-portfolio-scan,tad-hygiene-skill-p0}.md`; dryrun `DRYRUN.md`/`KEEP.md`, absorb `STATUS.md` | **建议 yes**：三文件仍分别写“未实施”“未授权实施”“须另行授权候选”，与已完成 absorb PASS 冲突；目标和 KEEP 已精确界定。误派重复刀风险明确，优先于新增文案。推荐不是授权，本轮不执行。 | absorb-now | `TASK-20261001-TAD-HYGIENE-FORGET-INDEX-EXECUTE-P0`：只退役三个 current-facing 旧候选措辞，链接 successor PASS/HOLD；保留历史 Verdict、原证据、scope 边界，零删除。 |
| 旧 status 版本 / intent 今日目标占位 | `docs/pm/status.md`, `intent.md`, `now.md` | status 的 2.44.0 摘要明确有 9月4日时间限定，intent Latest 2.44.5；今日目标 TBD 与本刀 now 的机制卫生在途并置。可能影响位置感，但本刀不能据此改人目标或判当前外部 release。 | defer | PM 后续有已确认目标/版本来源时整理 `docs/pm/{status,intent}.md`；不并入本次三措辞 execute。 |
| 本地卫生 drafts 的生效边界 | `docs/pm/ops/mech-absorb-thin-scan-steps-draft-20261001.md`, `skill-draft-mech-absorb-thin-scan-20261001.md` | 明标 DRAFT / inactive，示例属历史。steps 有更新 now/segment 的一般步骤，本刀用户“仅证据目录可写”优先；不能借草案更新 PM 正文或安装 skill。 | defer | 草案原位保留；人定稿另行处理，不改技能/上游模板。 |
| 临时 Codex 偏好到期与共享运行说明旧模型 | `docs/pm/intent.md`, 两份 hygiene draft; charter §3.4/§3.5 与路由 SSOT 段 | 临时到期提醒沿 FILTER 与草案继承，未独立读取 GM 锁/额度。charter 的历史 Codex TBD 与旧模型运行说明仍可见，顶部/工具栈段已指向路由 SSOT；共享消歧不是 TAD 改默认的理由。 | hand-GM | GM 按原锁到期/额度/人改口条件复检，并决定共享历史说明消歧；TAD 只引用，不切进行中模型、不永久化锁。 |
| 上游 Epic/NEXT/session/completion 补字段或重建 KA | 前 FILTER defer 行；`docs/pm/acceptance.md` 与 draft scope | 未发现新失败证据可推翻前刀 defer；HO 明确先改 PM、不改 TAD 上游。 | defer | 保持前刀 defer；本次不读取 HANDOFF 正文、不改上游 Gate/技能/模板。 |

## 判断与边界

剩余值得轻吸收的是 PM 入口的完事正文、正式收口责任/字段、正式观感适用分支；共享规则本身已经存在，不能据此称机制未建立。它们只入库存，不并入唯一推荐的三措辞 execute 刀。

本刀 now 与 Oct-2 segment 仍显示在途，是 PM 尚未收到扫描结果时的合法状态，不能先判 stale 或代做 PM closeout。Oct-1 absorb/dryrun closed 状态及原 FILTER/RECOMMEND 都保留。

Verification Method：直接读盘比较上述路径与共享 HO/charter/template 条文，枚举本地 templates/ops/segment，复核三条 dryrun 目标仍存在。结论限于文档接口；未验证外部聊天、私有脑、模型额度、helper/check、远端 job 或 per-owner exit webhook。
