---
name: Plain Language Explanation After Handoffs
description: After every Blake handoff message (or major decision point), write a colloquial human-readable explanation of what stage we're at, why these decisions, what's next — so user learns instead of just copy-pasting
type: feedback
originSessionId: 710bb29c-a3ed-43f1-bc38-7e4b1cdb3572
---
After every handoff message generated for Blake (or any major decision/return-trip message), append a section in plain Chinese explaining:

1. **现在做什么** — what stage we're at, in everyday language (not "Phase 1b spike scaffolding")
2. **为什么这么决定** — the reasoning behind the key choices, with analogies if helpful
3. **接下来会发生什么** — what comes next, what user should watch for

**Why:** User explicitly stated (2026-04-14): "我觉得这个措施非常好... 我把内容交给 Blake，然后他执行的时候我还可以看一下你是怎么思考的... 而不是单纯的我只是在其中不断的去复制粘贴." User wants to LEARN through the workflow, not just be a relay between two terminals.

**How to apply:**
- Use everyday Chinese, avoid TAD-specific jargon (or define it inline if used)
- Use analogies where appropriate (锁 / 装修 / 考试 / 律师等)
- Keep it short — 3-5 short paragraphs max
- Don't repeat what's in the handoff; explain the *why* and *what's at stake*
- Avoid bullet points overload; prose with light structure works better
- This is in addition to the structured Blake message, not a replacement
- Write it for "smart user who isn't a programmer" — assume they understand business logic but not implementation details

**Negative example (to avoid):**
"为什么这 3 条 guardrails 不是过度设计：G1 (Unicode pilot)：避免 sentinel-bypass cat 1 通过只是因为 sub-agent 给了 trivial fixture..."
→ Still uses jargon (sentinel-bypass, cat 1, sub-agent, fixture, NFKC). User said this was acceptable but "也不是很通俗".

**Positive example (target style):**
"现在 Blake 在搭'防作弊系统'。Phase 1a 证明了我们的'锁'能锁住门；1b 就是雇个'白帽黑客'（security-auditor sub-agent）来想办法撬锁。Blake 既要造锁也要测锁，所以我们让他先做 1 个样板间，看看锁的设计有没有漏洞，再批量做 7 个房间。"
