---
notebook_id: 79b4c4a9-f1b2-49cf-962f-3188b52426d5
topic: Video Creation Pack Evolution — ViMax Agentic Pipeline vs TAD Motion Graphics Pack
created: 2026-05-27
sources: 38 (9 TAD pack files + 29 ViMax code files)
ask_round: 1
---

# Deep Ask: Top 5 Gaps in TAD video-creation Pack (vs ViMax)

## Question Asked
Given full knowledge of both source sets, identify TOP 5 specific gaps in our pack that ViMax patterns solve. Per gap: missing capability, ViMax solution (class+method), implementation evidence (code citation), adoption tradeoff for motion-graphics context, priority+effort.

## Findings

### Gap 1 [P0 + M] — Visual Decomposition for Keyframing
- **Missing**: Mechanism to split a single prompt into first frame / last frame / motion trajectory for image-to-video generation.
- **ViMax**: `StoryboardArtist.decompose_visual_description` in agents/storyboard_artist.py — `VisDescDecompositionResponse` schema enforces 3-part output.
- **Evidence**: Prompt: "dissect and rewrite a user-provided visual text description of a shot strictly and insightfully into three distinct parts: First Frame Description / Last Frame Description / Motion Description"
- **Tradeoff**: HIGHLY VALUABLE for motion graphics. Generates exact start/end keyframes via gpt-image-2 → Seedance image-to-video with dual references. Prevents AI motion drift in our 3-5s shots. Directly compatible with our "95% Hard Cut Rule".

### Gap 2 [P1 + S] — Intent-Based Script Routing
- **Missing**: Dynamic structural template for script generation phase. Our Context Detection table is keyword-based at reference-loading level, not at script-structure level.
- **ViMax**: `ScriptPlanner.plan_script` in agents/script_planner.py — IntentRouterResponse classifies into narrative/motion/montage.
- **Evidence**: `intent: Literal["narrative", "motion", "montage"]` with descriptions: narrative=multi-conversation, motion=action/kinetic, montage=emotional.
- **Tradeoff**: VALUABLE. Maps cleanly to our "Product Demo / Social Short / Tutorial" pacing templates. Small effort, large clarity gain.

### Gap 3 [P1 + M] — View-Specific Reference Selection
- **Missing**: Programmatic logic to feed the CORRECT camera angle (front/side/back) from character sheet to generator based on shot's camera setup. Our pack uses character sheet + @character:id but doesn't filter by view.
- **ViMax**: `ReferenceImageSelector.select_reference_images_and_generate_prompt` in agents/reference_image_selector.py.
- **Evidence**: Prompt: "For character portraits, you can only select at most one image from multiple views (front, side, back). Choose the most appropriate one based on the frame description."
- **Tradeoff**: VALUABLE even for 10-15s social shorts. When character rotates or camera angle changes, view-specific reference prevents face hallucination/warping in Seedance output.

### Gap 4 [P1 + L] — Hierarchical Camera & Spatial Context
- **Missing**: Structural awareness of how consecutive shots relate spatially. We treat each cut as isolated prompt.
- **ViMax**: `CameraImageGenerator.construct_camera_tree` in agents/camera_image_generator.py — parent-child relationship tree where wider parent shot constrains closer child shots.
- **Evidence**: Prompt: "Your task is to analyze the input camera position data to construct a 'camera position tree'. This tree structure represents a relationship where a parent camera's content encompasses that of a child camera."
- **Tradeoff**: VALUABLE for AI video portion. HyperFrames/GSAP handle 2D natively, but Seedance hallucinates background shifts. Parent context inheritance guarantees coherence across rapid 3-5s cuts. Large effort due to tree state management.

### Gap 5 [P2 + L] — Global Character Entity State Merging
- **Missing**: State machine to reconcile and track character identity changes across scenes.
- **ViMax**: `GlobalInformationPlanner.merge_characters_across_scenes_in_event` + `merge_characters_to_existing_characters_in_novel`.
- **Evidence**: Prompt: "Identify and merge characters that are logically the same across scenes... Output a consolidated list of characters for the entire event."
- **Tradeoff**: ⚠️ NOT VALUABLE for our context. Our pack targets 10-60s videos with 5-18 scenes max. Multi-layered global registry (novel→event→scene) adds latency without benefit. Characters in our context don't age/evolve.

## Comparison to Surface-Level Analysis (pre-NotebookLM)

| Aspect | My README-only analysis | NotebookLM cross-source analysis |
|--------|------------------------|----------------------------------|
| Gap 1 — Visual Decomposition | ❌ MISSED entirely | ✅ P0, top finding |
| Gap 2 — Intent Routing | ❌ MISSED | ✅ P1, small effort |
| Visual consistency | ✅ Generic "best-of-N + asset indexing" | ✅ Refined to view-angle-specific (more useful) |
| Camera tree | ❌ MISSED | ✅ P1, identified specific mechanism |
| Long-form narrative | ⚠️ Suggested as "P3 strategic decision" | ✅ Explicitly rejected — NOT VALUABLE |
| Parallel generation | ✅ Suggested as P2 | ❌ Not in top 5 (lower priority than above) |

## Quality Verification
- Probe question asked NotebookLM to cite exact class name + prompt structure + fallback logic of `BestImageSelector`.
- Response cited: BestImageSelector class, BestImageResponse Pydantic model, system_prompt_template_select_most_consistent_image, base64 image encoding, idx=0 fallback for invalid LLM response, character/spatial consistency criteria in prompt.
- Result: VERIFIED — WEB_PAGE imports parsed Python source content correctly, not just SPA shells.
