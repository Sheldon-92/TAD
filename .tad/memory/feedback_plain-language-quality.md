---
name: plain-language-quality
description: 人话版质量差 — 太模板化、太长、不解释为什么。需要从读者价值倒推而非结构合规检查
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 200be572-d78a-457f-8e88-47938966d38a
---

人话版（plain-language explanation）三个问题：太模板化/公式化、太长/啰嗦、没有真正解释"为什么"。

**Why:** 现有规则优化结构合规（有没有业务价值开头？有没有 anti-theater 句子？3 内容项？按复杂度 4-5 段？），agent 可以满足所有规则同时产出又长又模板又不解释为什么的文本。规则定义了"what to include"但没定义"reader should walk away knowing what"。

**How to apply:** 用读者价值测试替代结构合规检查。读完后用户应能回答：(1) 体验具体哪里不同了？(2) 为什么走这条路？(3) 接下来我需要什么决定/注意？任何答案换个任务也能用 → 重写。长度上限 2-3 段不管复杂度。影响 Alex SKILL step7 和 Blake completion protocol 的 message 人话版规则。

Related: [[plain-language-after-handoffs]]
