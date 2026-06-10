# E2E Dogfood: Modification Notes (Session C)
Date: 2026-06-10
Feedback JSON: tad-intro-feedback.json
Iteration: 1

## read_feedback_protocol Execution

### Step 1: Load JSON
- Schema version: 1.0 ✅
- Artifact: tad-intro.html (frontend_page)

### Step 2: Summary
- Elements total: 7
- Reviewed: 0 (none interacted)
- Verdicts: none
- Global notes: present (substantive)

### Step 3: Group by verdict
- ok: 0, modify: 0, delete: 0, replace: 0
- Skipped: 7 (all reviewed=false)

### Step 4: Modification handoff
- No element-level modifications requested
- Global notes contain META-FEEDBACK about the approach itself (see below)

## Critical Dogfood Discovery

User's global_notes feedback (verbatim):
> "我觉得是大概这个意思，但是不太对。首先他应该给我看的是因为他是一个页面前端，所以他应该给我看的是over，就是整体应该是什么，然后比如说我可以标记，我点一个东西，然后标记一个东西，然后把它记录下一个 node，就有点像随机记笔记的一个方式。或者是说我在旁边给它的这些元素都可以是引用的，或者是这些做的都可以在上面引用，然后做相当于是做笔记。
>
> 现在这个就是他把首先他把这个网页拆成了很多很小的部分，然后他也没有我也不知道他原来长什么样子，然后所以就整体无法给判断和无法给评价，就其实现在的这种状态就只能说哦他的文案对不对。"

### Translation of feedback into design insight:

1. **For frontend pages, the feedback HTML should SHOW the actual page** — not extract elements into isolated cards. The user needs to see the whole to judge the parts.

2. **Overlay model, not card model** — The user wants to click on elements ON the actual page to annotate them, like taking notes on a document. The current card-based approach removes spatial context.

3. **The card model works for sequential media (audio segments, video timeline) but NOT for spatial media (web pages, design layouts)** — because spatial relationships between elements are part of what's being judged.

4. **The approach needs to be artifact-type-aware:**
   - `frontend_page` / `design` → OVERLAY on actual artifact (embed or iframe + click-to-annotate)
   - `audio` / `video` → CARD/TIMELINE model (segments are inherently sequential, spatial context less important)
   - `brand` → HYBRID (some elements spatial like logo placement, some sequential like tagline options)

## Protocol Gaps Found

1. **read_feedback_protocol handles zero-reviewed-elements poorly**: when all elements are unreviewed but global_notes has content, the protocol outputs "No changes" — but the real feedback is in global_notes. Need a global_notes-only path.

2. **The feedback HTML generation guidelines assume card-based decomposition for all artifact types**: this is wrong for spatial artifacts. Phase 3 (or a P1 hotfix) should differentiate frontend_page → overlay model.

## Verdict

E2E loop MECHANICALLY WORKS: JSON exports correctly, read_feedback_protocol parses it, modification notes generated. The dogfood ALSO revealed a critical design insight about overlay vs card models for different artifact types. This is exactly what dogfooding is for.
