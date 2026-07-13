---
name: feedback_research-before-upgrade
description: "升级能力包必须先做深度研究(research-engine)再升级,不能边搜边改的\"浅研究盲目升级\""
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 171b1263-2f86-44fb-89c9-ed31cb384805
---

升级/深化能力包**必须先做深度研究、把研究报告当地基,再升级**——不是 agent 顺手 WebSearch 几下就重写(那是"盲目升级")。

**Why**:2026-06-14 深化 video-creation + knowledge-graph 时,我让 deepen agent "边搜边改"(浅研究 + 重写一步到位)。结果 re-dogfood:两个都翻成 WITH-PACK 赢了,**但 video-creation 顺手塞进一个新事实错**——声称"-14 LUFS 是 TikTok/IG/YouTube 2026 统一标准",错的(TikTok/IG 不做 in-feed 归一,创作者压到 -10~-12;-14 只是 YouTube)。浅研究升级会"想当然出跨平台统一标准"这类错。用户当场纠正:"深入研究以后再升级,而不是盲目升级。"

**How to apply**:
- 升级前先跑 **`research-engine`**(深度研究 workflow:plan + 多轮动态深挖 + saturation + 带引用)产出 cited 报告 → 再让升级 agent **读报告 + 当前包 → 升级**。研究 DRIVE 升级,不是升级时顺带研究。
- 每个具体声称(数字/阈值/版本/跨平台标准)必须有一手来源 + 日期;**跨平台"统一标准"类断言最危险**,逐平台分别核实。
- 系统性修复 ✅ DONE (2026-06-14, commit 257cbcc):`pack-upgrade` Plan 阶段现在组合 research-engine(max_rounds=2)→ 带引用报告地基 → 每个 Layer-B 声称引报告源 + UNVERIFIED 强制标注;Upgrade 禁止断言跨平台"统一标准"类。research 失败 → 降级 flag-everything,不退回训练知识瞎断言。所以"深研究先行"现在是 workflow 默认,不靠记。dogfood-with-factcheck 仍是出厂前最后一关。

讽刺点:我那轮刚建好 `research-engine` 专为深度研究,却没用它就去升级。工具建了要用。

Related: [[feedback_research-methodology]] [[feedback_tool-freshness]] [[project_tier1-workflow-formalization]] [[project_pack-quality-leveling-epic]]。
