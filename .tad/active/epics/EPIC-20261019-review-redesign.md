# Epic: Requirement clarification and review redesign — clarify by decomposition, review by different lenses and real runs

**Epic ID**: EPIC-20261019-review-redesign
**Created**: 2026-10-19
**Owner**: Cora
**Conductor**: Cora
**Approved**: yes — "复述对，继续跑 EPIC-20261019-review-redesign。" (2026-10-19)
**Budget**: estimate ~28 subagent dispatches (intake; per phase ~9: design, 2 design reviews, implementation, implementation review(s), Gate 3, Gate 4, possible spike; distillation 1). The figure is an estimate; the runaway guard is twice it. No model test runs.
**Depth**: standard — Risk: reversible (framework protocol text, templates, skills); blast radius: how every request is clarified and reviewed in TAD and in every downstream project after its next update.

---

## Requirement

Built with the method this Epic installs (decompose into blocks, ask per block with options + "other", one line per block in the human's words). Sources: the conversation of 2026-10-19; research `.tad/evidence/research/requirement-elicitation-methods-2026-10-19.md`, `review-redesign-synthesis-2026-10-19.md` (+ `review-history-{tad,maimai,menutales}-2026-10-19.md`), `review-design-pstack-bmad-tad-2026-10-19.md`.

### Part 1 — Requirement clarification (the human's answers, per block)
- **A. When and how deep**: decided by whether the request itself is clear, not by tier; decompose first and ask only the blocks still unclear, until clear. When the human says "just do it", Cora plays the requirement back block by block (one line each) and he confirms before work starts.
- **B. How to decompose**: Cora does not announce a problem type; she shows the blocks. Common types each have a small decomposition table, combined with the matching capability pack; otherwise she decomposes on the spot. Big blocks first; an unclear block is split further.
- **C. How to ask**: one block at a time, at most 4 questions per block; each question has concrete options (they show Cora's understanding), a recommended option marked, and "other". When the human writes in "other", Cora restates that block in one line in his words. Added 2026-10-19 from the human's correction ("你不要很刻板的来问我你的建议是什么，我要听到你的专业建议"): before the options, Cora gives her own professional view with its reason; the options are for him to correct her, not a replacement for her judgment; a question he hands back ("你的建议呢") is answered with her recommendation, not re-asked.
- **D. What it produces**: the requirement goes in the Epic's requirement section (simple tier: the journal line): one line per block in the human's words, the Q→A log, and assumptions for what was not asked. Gate 1 passes when the human confirms the per-block playback and an Alex subagent confirms it can design from it.
- **E. Downstream**: when Alex finds a hole, Cora answers from the requirement first and asks the human only what it cannot answer; the design review and Gate 4 check against the requirement; if mid-run the requirement turns out wrong or changed, stop and re-ask only that block.
- **F. Relation to Cora's rules**: asking about requirements is not "blocking the human" — that rule is for execution only; while discussing, Cora only discusses and starts work only when the human says to; clarify first, then state tier and plan; direct `/alex` uses the same method (replaces the old Socratic inquiry and `tad-elicit`).
- Human's own words that set the method: macro or hypothetical questions ("if you are disappointed in three weeks, why?") and big paragraphs of playback are useless; the value is decomposing into concrete small aspects with options so he can correct through "other"; "when you can decompose a problem you can execute it" — the first step is taking it out of his head in a form AI understands; the decomposition is not fixed and depends on the kind of problem (app, research, science, learning …).

### Part 2 — Review and gates (as discussed and agreed, 2026-10-19)
- **Gate 1 (before design)**: conditions — what the human gets and does not want; each deliverable has a check that can judge done/not done; decisions for the human listed, premise and size stated; estimate stated. Checked by: format by script; content by the human (per-block playback, Part 1 D) and an Alex subagent (can design from it).
- **Gate 2 (design written)**: two reviewers with different lenses — `consistency` (contradictions with existing rules/code; runs every acceptance command before the change to prove it can fail) and a risk lens chosen by the change's risk (security, data, money, user-visible UI, platform, domain correctness) or, when none applies, a `fit` lens (is this what the requirement asks, is the size proportionate, does the premise hold; produces questions or P1, never P0). If round 3 still finds non-trivial issues, stop reviewing and look upstream (premise).
- **Gate 3 (built)**: one independent reviewer (not the builder) reads the change and runs every real path the handoff lists (real install, build, call; not-run with a reason where impossible); one extra domain reviewer only when security/data/money is hit. Replaces the former two implementation reviewers plus a Gate 3 verifier. Acceptance commands are re-run by the independent run reviewer in one throwaway project copy (amended 2026-10-19 by the human: "砍掉" — scripted execution dropped after three failed sandbox rounds; the script only checks the evidence and the not-run list). One project is enough for real-run checks ("只需要测试一个项目就可以了"). "Real run" means one real use of each path, never a batch or measurement; anything paid is asked first.
- **Gate 4 (acceptance)**: an Alex subagent that took no part runs, from the human's side, what he will do with the result (real run or driving a browser, screenshots/run logs as evidence) and judges against the requirement. All AI; no human added. Only what AI cannot do (real device, payment, the human's own account login) goes to the human, with the reason. The human receives the verdict plus 3–5 lines of evidence.
- **Reviewer contract**: one file every review/verification/acceptance dispatch loads (header and its self-consistency rule, what a finding must contain — location, scenario, blocks, checked, kind, origin — P0 rule, empty review allowed, no minimum findings); Cora adds no ad-hoc questions.
- **Escape log**: every defect found after acceptance gets one line "found by whom / which gate should have caught it", so the flow is adjusted from real escapes.
- Human's words: "get 三 get 四最后的审查，我觉得是应该真实的来去跑，或者是说操控浏览器呀、啊，然后由 Alex 或者是 Cora 自己来去验收一下。我还是不想要再加人，这个部分还是应该是由 AI 来去做的内容。" / "你上面的那个建议，我觉得都可以，除了这个我提出的这个以外。" / design it as a better quality flow, not as cutting layers; gates must have conditions.

### Part 3 — Inventory before unifying (added 2026-10-19, mid-run)
- **G. Existing paths first**: before Phase 2 is designed, lay out every current way work is reviewed (Cora simple / handoff / Epic tiers; direct `/alex` incl. express handoffs; direct `/blake` Layer 2 tiers by task_type; the gate skill's own rules; frozen Lite): when each is used, how many reviewers, what they look at, which gates. Show it to the human, discuss, then unify. Human's words: "我觉得可能里面有很多以前的做法，包括我们还分了不同的档位啊，然后它的档位的区别就在于它要派几个，reviewer 啊之类的，我觉得可能要把我们本身原来的用法要先说清楚，然后再想办法统一。"

- G answers: inventory `.tad/evidence/yolo/review-redesign/review-paths-inventory.md` shown; "统一为cora". G1 保留入口，走和 Cora 同一套规则 (direct /alex, /blake, express, *bug follow the same review and gate rules). G2 小事的审查人数：一律至少 2 人. Asked whether this covers Gate 3; human: "你不要很刻板的来问我你的建议是什么，我要听到你的专业建议". Cora's recommendation, applied (human may stop it): every review stage has at least two reviewers with different lenses — Gate 3 = one real-run reviewer + one consistency reviewer on the diff, plus a domain reviewer when security/data/money is hit; simple tier = two light reviewers (consistency + run). Supersedes Part 2's "one Gate 3 reviewer".

### Q→A log (2026-10-19)
- Decomposition A–F: "拆得对，开始逐块问".
- A1 看请求本身清不清楚 · A2 拆完后还不清楚的块有几块 · A3 "如果是直接做，那你就需要把按照这个你的理解先把问题就是先把需求复述一遍，然后和人做最后的确认" · A3 form: 按块写，每块一行.
- B1 不说类型，只摆拆出来的块 · B2 常见类型各有一张小表，配合能力包 · B3 先拆大块，不清楚的块再往下拆.
- C1 具体选项加"其他" · C2 一次一块，每块最多 4 题 · C3 都标推荐 · C4 用你的话把这块重述一行.
- D1 写进 Epic 的需求段，简单档写在记录行里 · D2 每块一行你的话 + 问答记录 + 假设 · D3 你确认按块复述 + Alex 确认能据此设计.
- E1 Cora 先对照需求自己答，答不了的再问你 · E2 设计审查和门禁四 · E3 停下，就那一块重新问你.
- F1 不算，"不卡人"只管执行阶段 · F2 你明确说做才开始 · F3 先澄清，再分档报计划 · F4 统一成这套方法.
- Scope of "做吧": 需求澄清 + 审查重设计一起做.

### Assumptions (not asked; Gate 4 lists them to the human)
- C3 "recommend on every question" is kept as answered; Cora observed that after recommendations started the human chose the recommended option 10 of 10 times (possible anchoring); watched in normal use, not changed.
- Decomposition tables start with the types named in the conversation (app, research, science, learning) plus process/method and bug; more are added when met.
- Cross-model review stays an optional slot, off by default.

## Result contract
What the human gets: the Part 1 method in the Cora skill and in direct `/alex` (old Socratic inquiry and `tad-elicit` replaced, not left alongside); the Part 2 review and gate design in the Cora skill and conductor protocol, the gate skill, Blake's own review, Alex's dispatch mode and the handoff/Epic templates, all saying the same thing; the reviewer contract file; the escape-log line.
Not wanted: a new human-facing role; a human added to acceptance; macro/hypothetical questions or paragraph playback; fixed question forms that ignore the kind of problem; model test runs; same-lens second reviewers.

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Requirement clarification method | ✅ Done | HANDOFF-2026-10-19-review-redesign-phase1.md | Part 1 A–F in Cora and direct /alex; requirement section in the Epic template; decomposition tables |
| 2 | Reviewer contract and lenses | ✅ Done | HANDOFF-2026-10-19-review-redesign-phase2.md | Reviewer contract; Gate 2 lenses; Gate 3 single real-run reviewer |
| 3 | Gates and alignment | ✅ Done | HANDOFF-2026-10-19-review-redesign-phase3.md | Gate 1 conditions; Gate 3 scripted re-run; Gate 4 AI real-run/browser acceptance; escape log; Blake/gate/Alex aligned |

### Phase Dependencies
Sequential: Gate 1 (phase 3) relies on the requirement section (phase 1); Gates 3–4 load the reviewer contract (phase 2).

---

## Phase Details
(Filled by the Intake Alex subagent: `.tad/evidence/yolo/review-redesign/intake-details-3.md`. Earlier inputs: `intake-details.md` (intake-1, review part only) and `intake-questions-2.md` (intake-2 stopped: it read the Epic before this rewrite reached disk).)

---

## Run
Pointer: phase 3 | step epic completion
Dispatched: —
Next: acceptance; then git reconciliation (other machine idle) and release 4.0.4 (push/tag asked)
Stopped: Question: merge origin/main (9f0ff925: 1901b97e "Full Layer 2 review brakes", accepted 2026-10-18 on the other machine; 6 overlapping files with Phase 3) into the release line with Alex resolving conflicts (Cora recommends), before release 4.0.4 (acceptance answered: "验收，另一台机器没在用" 2026-10-19) | answer: (none yet)
Owner: —

---

## Notes
- 2026-10-19 protocol version for this run: the Cora skill and conductor protocol as they stand at "continue" review all three phases (rules do not change under a running phase; intake-3 note).
- 2026-10-19 the Epic was first written for the review part only, before the discussion had settled (copy: `.tad/evidence/yolo/review-redesign/epic-v1-before-rewrite.md`); the human pointed out Cora had jumped to a plan mid-discussion. It was rewritten after the per-block clarification (Q→A log above).
- 2026-10-19 intake-2 read the old file: Cora sent the rewrite and the dispatch in parallel and the write failed; intake-2 stopped at Gate 1 instead of guessing. Re-dispatched as intake-3.
