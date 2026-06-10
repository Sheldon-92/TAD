# Structured Feedback Architectures in Generative AI: Element-Level Manipulation, Spatiotemporal Steering, and Human-Agent Agency Negotiation

The rapid evolution of generative artificial intelligence has exposed a fundamental friction point in human-machine collaboration: the interface gap between linguistic abstraction and spatial-tactile execution.[1, 2] While early generative paradigms relied on a prompt-and-pray methodology—where users formulated entire natural language instructions to generate static, complete artifacts—modern production-grade workflows require highly steerable, conversational, and element-level feedback loops.[1, 3] For professional creators across user interface design, filmmaking, sound engineering, and graphic design, the ability to selectively target, isolate, and refine specific components of an AI-generated output is critical.[4, 5, 6] This report examines the technical architectures, visual interfaces, and theoretical frameworks governing structured human feedback in contemporary AI creative tools.

---

## Element-Level Feedback and Workspace Sandbox Environments in UI and Application Builders

The software engineering and interface prototyping landscape has consolidated around platforms that translate plain-text descriptions into fully realized, deployable components and applications.[7, 8] However, the key differentiator among these platforms lies in how they facilitate the transition from a rough generative draft to a production-ready application.[4, 9]

```
┌──────────────────────────────────────────────────────────┐
│                   Vercel v0 Design Mode                  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  [Preview Canvas] ──(Cmd+I / Inspect)──> │
│                                                │         │
│  ┌─────────────────────────────────────────────▼──────┐  │
│  │                  Visual Design Panel               │  │
│  ├────────────────────────────────────────────────────┤  │
│  │  • Typography (Font, Alignment, Spacing)           │  │
│  │  • Layout (Margins, Padding via Tailwind)          │  │
│  │  • Content (Direct text override)                  │  │
│  │  • Prompt Input (Attached with Element Screenshot) │  │
│  └───────────────────────────┬────────────────────────┘  │
│                              │                           │
│                     (Click "Apply" Button)               │
│                              │                           │
│                              ▼                           │
│                                  │
│                              │                           │
│                              ▼                           │
│                                   │
└──────────────────────────────────────────────────────────┘
```

### Vercel v0 and the Design Mode Architecture

Vercel's v0 platform generates clean, Next.js React components utilizing Tailwind CSS and shadcn/ui library schemas.[9, 10] To allow users to edit these generated components without manually rewriting code, v0 utilizes a visual "Design Mode".[11, 12] Under this architecture, the user's cursor behaves as a structural selection tool, mapping directly to the Document Object Model (DOM) of the running sandboxed preview.[11, 13] 

When the user activates Design Mode via the prompt form toolbar or keyboard shortcuts (`Cmd + I` or `Ctrl + I`), hovering over the preview highlights elements, and clicking on a target element brings up selection handles along with a dedicated design panel.[11] This panel provides two distinct feedback mechanics:

* **The Design Panel**: A point-and-click stylesheet editor.[11] This allows precise visual modifications of typography (font family, size, weight, line height, alignment), color, background values, layout metrics (margins and padding on all sides), borders, opacity, corner radii, shadows, and direct text content.[11] The system detects if the application uses Tailwind CSS, translating visual adjustments directly into Tailwind-compatible style values.[11] Tweaks made in the panel are applied live in the preview as pending edits.[11]
* **Linguistic Element Prompting**: For complex structural alterations, such as converting a single element into a multi-column grid, the panel provides an instruction input.[11] When a user types a command, the platform captures a localized screenshot of the selected element, compiles the structural metadata, and attaches it to the instruction.[11]

Once the user confirms these adjustments, clicking "Apply" serializes the visual edits and screenshot-accompanied prompts.[11] The system transmits this payload to specialized frontend language models, compiling a new version of the codebase represented as a clean, diffable code patch.[11, 13] 

Despite these capabilities, v0 has clear operational limitations: it does not generate design files (such as Figma exports), meaning the integration runs strictly from design-to-code, not vice versa, and token-based credit pricing causes costs to compound rapidly during long, complex chat histories.[10]

### Lovable and Bolt: Prototyping vs. Full-Stack Production

While v0 focuses primarily on the design-to-component layer, Lovable and Bolt target full-stack application compilation.[7, 9] This creates distinct structural and economic challenges for iterative feedback.[4, 14]

Lovable implements a "Visual Edits" system designed to minimize the cost of design iterations.[7] In standard generative environments, every refinement prompt requires a call to a large language model, consuming token-based credits.[10, 14] Lovable decouples pure styling updates from complex logic changes.[7] Visual modifications—such as adjusting button colors, text content, and layout margins—are handled through a point-and-click WYSIWYG layer that does not consume credit tokens.[7] 

This allows cross-functional team members, such as product managers and designers, to refine UI details freely while developers construct complex database logic utilizing Lovable's auto-provisioned Supabase backend.[7]

Conversely, Bolt relies primarily on a code-first and prompt-based workflow.[7] Operating within StackBlitz's WebContainers environment, Bolt executes an active Node.js server directly in the browser, providing real-time preview rendering of code changes.[7] However, Bolt lacks a native visual element-selection tool.[7] Refinements must be executed either via natural language requests in the main chat timeline or by writing code directly in the browser-based editor.[7] 

While this code-forward paradigm appeals to software engineers, it introduces cognitive barriers for non-technical users and accelerates context-loss as iterations accumulate over a long development session.[4, 8]

### Windsurf and Cursor: Professional Developer Environments

In the professional IDE landscape, Cursor and Windsurf optimize for rapid, code-level feedback loops.[15, 16] Cursor leverages its "Composer" mode, which orchestrates multi-file edits across a codebase by analyzing project-wide indices and executing changes via its parallel "Cursor Agent" (`Cmd +.`).[16, 17, 18] 

Windsurf, developed by Codeium, utilizes a highly collaborative agent named "Cascade".[15, 17] Cascade relies on "Supercomplete"—an advanced code-completion engine that predicts and displays multi-line diff boxes directly within the active file based on surrounding context—and "Cascade Memories," which cache project constraints, package environments, and developer preferences across sessions to maintain context continuity.[17, 19]

### Dualite, Frontman, and Direct Codebase Interaction

To bridge the gap between sandbox prototyping and actual codebase maintenance, tools such as Dualite and Frontman introduce alternative human-in-the-loop workflows.[13, 20]

Dualite incorporates a dedicated "Interaction Mode".[20, 21] When active, clicking on any element in the live preview extracts its precise metadata and location within the component hierarchy.[20, 21] The user then instructs the AI in plain English to alter only that element, bypassing the need to describe *where* the target is situated in the wider layout.[20, 21] 

Furthermore, Dualite compiles to React Native out of the box, allowing target-element edits to translate smoothly into mobile-optimized code structures, whereas v0 remains strictly web-focused.[14]

Frontman directly addresses the limitations of sandboxed generation.[13] Platforms such as v0 and Bolt generate code within a proprietary, virtual environment.[13] Frontman, operating via a browser-side Model Context Protocol (MCP) server, interacts with a developer's actual running local application.[13, 20] 

Rather than generating an entire screen from scratch, Frontman reads the active DOM and CSS in the local browser window and applies AI-assisted modifications directly to the source files in the local repository, preserving local design systems and database connections.[13]

### Comparative Landscape of Generative UI and Application Builders

| Dimension | Vercel v0 [7, 9] | Bolt.new [7, 9] | Lovable.dev [7] | Dualite [14] | Cursor / Windsurf [16, 18] |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Primary Output** | React / Next.js UI Components | Full-Stack Web Prototypes | Full-Stack Web Apps (React + Supabase) | Full-Stack Web & Mobile Apps (React Native) | Production-Ready Multi-File Codebase |
| **UI Feedback Loop** | Point-and-click Design Mode panel + screenshot-anchored instructions [11] | Natural language prompt thread or direct manual code editing [7] | Visual Edits WYSIWYG editor overlaying live preview [4, 7] | Interaction Mode element-selection + conversational prompts [20, 21] | Multi-file text-diff generation via AI agent (Composer / Cascade) [16, 17] |
| **Backend & Persistence** | No native backend; requires manual integration of external services | Auto-provisioned in-browser database and thin Node.js API routes | Auto-provisioned production-ready Supabase backend & databases | Direct Supabase schema provisioning and sync [20, 21] | Full capability via manual codebase scaffolding [17, 18] |
| **Collaboration Model** | Individual developer focus; lacks robust multi-user real-time editing | Standard team roles and advanced workspace sharing | Real-time multi-user simultaneous canvas and code editing [7] | Prompt-based sharing, templates, and full GitHub integration [21, 22] | Git-centric collaborative pull request and review workflows [23] |
| **Pricing Friction** | Token-based credits; rapid accumulation of cost during long chat sessions [10, 14] | Usage-based token consumption [23, 24] | Free visual edits; credit consumption restricted to logic compilation [7] | Message-based flat pricing with unlimited Launch tiers [14] | Flat subscription tiers with unlimited autocomplete and allocated agent queries [12, 19] |

---

## Spatiotemporal Constraints and Inpainting in Generative Video Workflows

Iterative feedback in generative video editing is significantly more complex than in text or layout editors due to the dual dimensions of spatial alignment (where elements reside on a frame) and temporal consistency (how elements behave over time).[5, 25]

```
┌────────────────────────────────────────────────────────┐
│               Runway Video Inpainting Loop             │
├────────────────────────────────────────────────────────┤
│                                                        │
│                  [Import Video Clip]                   │
│                           │                            │
│                           ▼                            │
│                                  │
│               (Dilated automatically +10px)            │
│                           │                            │
│                           ▼                            │
│                [Chronological Keyframing]              │
│       (Create manual keyframes as subject moves)       │
│                           │                            │
│                           ▼                            │
│                     [HCI Checkpass]                    │
│             Is subject blocked? Low contrast?          │
│            Camera shaking? High Depth-of-Field?        │
│             /                                \         │
│          (Yes)                              (No)       │
│           /                                   \        │
│          ▼                                     ▼       │
│              │
│  (Artifacting, physical errors)       (Background Merge)│
└────────────────────────────────────────────────────────┘
```

### Video Inpainting and Motion Tracking: Runway’s Architecture

The primary mechanism for localized video refinement is inpainting—the process of masking and replacing elements within a moving sequence while preserving background motion and lighting continuity.[5, 26] Runway’s inpainting interface integrates a visual, cloud-based video editor that allows users to brush over specific objects within a frame to establish an initial selection mask.[26] 

To account for user imprecision, Runway’s system automatically dilates the masked selection boundary by 10 pixels, ensuring the model captures the complete outline of the targeted subject.[26] 

Once the initial mask is drawn, the feedback loop relies on chronological keyframing.[26] The user previews the video playback, identifying frames where the target subject drifts outside the mask.[26] The user then draws manual correction masks on these specific frames, establishing keyframes.[26] Runway’s underlying optical flow and tracking algorithms interpolate the mask's boundary coordinates across the intervening frames.[26] 

Despite these advanced tracking loops, physical and visual limitations frequently result in model drift and rendering artifacts:

* **Occlusion and Anatomical Physics**: If a masked subject is temporarily blocked by another object, or if a user attempts to reconstruct missing limbs, current models fail to calculate accurate anatomical physics, resulting in warped visual details.[26]
* **Camera Turbulence**: Highly unstable, hand-held camera movements generate erratic frame variations that overwhelm the model's background synthesis, producing localized warping.[26]
* **High Depth-of-Field**: Running an inpainting session that spans a heavily blurred background and a sharp foreground causes boundary calculation failures.[26]
* **Boundary Excursions**: When a masked subject rapidly exits and re-enters the camera frame, the model must make massive structural assumptions, resulting in temporal flickering.[26]

### Dynamic Spatial Steering: Kling, Pika, and CapCut

To address the limitations of static prompting, video platforms have introduced direct spatial steering tools.[5, 27] Kling AI utilizes a "Multi-Motion Brush".[27, 28] Rather than relying on textual prompts to describe movement (such as "the car turns left while the pedestrian runs right"), users draw physical trajectories directly onto the video canvas.[5, 27] Each stroke operates as a localized vector constraint, steering the temporal generation of the specific object without affecting static environmental regions.[5, 27]

Pika introduces a different abstraction layer with its Pika Model Connection Protocol (MCP) and "Pikaffects" framework.[29] Instead of requiring fine-grained manual masking, Pikaffects provides preset-driven physical deformations, allowing users to apply reality-bending transitions like "squish it," "melt it," or "cake-ify it" to uploaded photos with a single tap.[29] This shifts the feedback loop from complex keyframing to predictable, preset-based physical simulations.[29]

CapCut Video Studio shifts the editing paradigm entirely by replacing the traditional linear editing timeline with an infinite, coordinate-free spatial canvas.[30] In this web-based workspace, the canvas serves as an agentic storyboard.[30] An embedded AI agent helps write scripts, plan scene blocking, and generate cohesive visual assets using Dreamina and Seedance 2.0 models.[30] These models leverage "omni-reference" frameworks, allowing creators to pass stylistic, environmental, and character references simultaneously to maintain cross-scene visual consistency.[30] Once assets are positioned across the infinite canvas, creators switch into a focused timeline editor to fine-tune transitions, apply automated captions, and export the finished video.[5, 30]

### Performance Characteristics of Video Feedback Systems

| Tool | AI Edit Capability | Primary Feedback Loop | Creative Control Tier | Target Market |
| :--- | :--- | :--- | :--- | :--- |
| **Runway** | Precision Inpainting, Object Replacement, Relighting [5, 31] | Chronological keyframing + manual mask adjustments [26] | High (frame-by-frame masking precision) [26] | Professional filmmakers, commercial ad directors [5, 31] |
| **Magic Hour** | Strong Video-to-Video Replacement and Restyling [5] | Region-specific modification preserving motion profiles [5] | Medium (focuses on style transfer over manual vectors) [5] | Social media marketers, digital content creators [5] |
| **Kling 3.0** | Motion-Heavy Edits, Vector-Based Directing [5] | Multi-Motion Brush trajectory drawing [5, 27] | High (direct spatial vector input) [27] | Animators, action content producers [5] |
| **Pika** | Style Transfer, Presets, Reality-Bending Presets [29] | MCP Integration + Pikaffects preset triggers [29] | Medium (simplified, high-level preset automation) [29] | Viral social content creators, mobile-first users [29] |
| **Sora** | Complex Scene Extensions [5] | High-level temporal extending [5] | Low (primarily prompt-driven extension) [5] | Narrative filmmakers, long-form storytellers [5] |
| **CapCut AI** | Automated Social Templates, Background Removal [5] | Unified agent-assisted storyboard canvas [30] | Low-Medium (highly templated, automated layer editing) [5] | Short-form social media creators [5, 30] |

---

## Text-Based and Node-Based Paradigms in AI Audio and Podcast Production

The production of high-fidelity spoken-word and musical content has moved away from waveform manipulation.[32] Feedback loops in modern audio software operate on two primary abstractions: text-based timelines and node-based pipeline graphs.[32, 33]

```
┌────────────────────────────────────────────────────────┐
│               ElevenLabs Flows Canvas                  │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ──> ──>      │
│                            │                           │
│                            ├─(Modify Prompt)           │
│                            │                           │
│                            ▼                           │
│                   (Non-Destructive Run)                │
│             Only regenerates downstream path           │
│             Upstream assets remain preserved           │
│                            │                           │
│                            ▼                           │
│                              │
│         (Real-time cursors, node-level comments)       │
└────────────────────────────────────────────────────────┘
```

### Text-Based Waveform Editing: Descript Underlord

Descript pioneer-designed the transcription-to-timeline mapping paradigm.[32, 34] When an audio file is imported, the system transcribes the speech with approximately 95% accuracy.[35] The primary feedback loop occurs directly on the text transcript: deleting a word, sentence, or filler phrase automatically slices and merges the underlying multi-track audio waveform seamlessly, eliminating manual cutting.[32, 36] 

To automate this workflow, Descript utilizes "Underlord," an agentic co-editor.[32, 34] Underlord scans the transcript to identify and isolate filler words ("ums," "uhs," "likes"), repetitive phrases, and audio false starts, letting users remove them in a single click.[32, 34] 

Furthermore, Descript implements "Regenerate" (built upon its Overdub voice cloning engine).[32, 34] If a speaker mispronounces a word, the creator edits the text spelling in the transcript.[32, 34] The model analyzes the surrounding phonetic context, clones the speaker's vocal characteristics, and synthesizes a corrected audio patch.[34, 37] This feedback loop eliminates the need for physical re-recordings, making vocal corrections a purely textual process.[32, 37]

### Collaborative Linear Timelines: ElevenLabs Studio

ElevenLabs Studio 3.0 provides an end-to-end multi-track timeline environment optimized for long-form narrative production.[37, 38] The timeline integrates vocal synthesis, sound effect generation, and automatic background scoring via Eleven Music.[33, 37] 

The critical feedback mechanic in Studio 3.0 is its public review workflow.[37] Creators generate secure, public URLs of active projects.[37] Clients, editors, and external managers open these links directly in their browsers without needing full workspace seats.[33, 37] 

Reviewers play the track and drop comments directly onto specific timestamps on the timeline.[37] Studio 3.0 aggregates these comments into a sidebar checklist, allowing the producer to quickly adjust prompts, swap vocal identities, or refine delivery metrics (speed, stability, style exaggeration) exactly where requested.[37, 39]

### Non-Destructive Node Graphs: ElevenLabs Flows

For complex, multi-model creative pipelines, ElevenLabs introduced "Flows"—a visual, node-based workspace.[33] Flows allows creators to visually link generative models (such as Google Veo, Sora, Kling, Flux, and the ElevenLabs audio stack) into a continuous pipeline graph.[33] 

The primary engineering advantage of this node-based architecture is **non-destructive iteration**.[33] In standard linear workflows, changing an early step (like modifying the base script) requires regenerating the entire subsequent pipeline, wasting time and API credits.[33] 

Flows isolates updates to specific nodes.[33] If a creator edits a voice prompt in a single TTS node, only that node and its connected downstream descendants are recalculated.[33] Unconnected parallel branches (such as background music tracks or environmental sound effects) remain completely untouched, preserving their finalized states.[33]

To coordinate this pipeline, Flows incorporates real-time collaborative features:

* **Live Cursor Presence**: Teammates track each other's active canvas coordinates via real-time colored cursors, preventing overlapping edits.[33]
* **Direct Node Commenting**: Reviewers attach feedback, revision requests, or approvals directly to individual nodes, keeping instructions perfectly contextualized.[33]
* **Shared Execution**: When a team member executes a flow run, the generation results render simultaneously across all active collaborator screens, maintaining a single source of truth.[33]

### Model Dropdowns and Integrated Speech Tuning: Adobe Firefly

To streamline professional voice synthesis, Adobe Firefly integrates ElevenLabs’ voice generation model directly within its Generate Speech panel.[39] Under this workflow, editors paste a text script, select "ElevenLabs Multilingual v2" from a dropdown menu, and choose a vocal profile.[39] 

The system exposes five granular adjustment sliders to fine-tune pronunciation and emotional delivery:

1. **Speed**: Calibrates the rate of speech output.[39]
2. **Stability**: Controls consistency to prevent emotional drift or voice cracking.[39]
3. **Similarity**: Determines how closely the synthesized audio adheres to the target cloned voice.[39]
4. **Style Exaggeration**: Boosts the theatrical delivery of the narration to prevent flat or monotonous pacing.[39]
5. **Speaker Boost**: Enhances vocal clarity and isolates vocal presence in noisy tracks.[39]

The generated file compiles as a `.wav` asset, dropping directly into the editor timeline for immediate post-production mixing.[39]

---

## Infinite Canvases and Vector-Level Structured Revisions in Design Platforms

The graphic design and illustration domains have moved past monolithic "text-to-image" interfaces, embracing node-based pipeline orchestration and selective localized inpainting.[6, 40, 41]

### Selective Region Revision: Midjourney Vary Region and Website Editor

Midjourney’s refinement loop operates through its "Vary Region" (inpainting) tool, which is available via both Discord and its web-based Editor interface.[40, 42] In Discord, when an image is upscaled, the user clicks "Vary Region" to launch a pop-up workspace equipped with lasso and rectangular selection tools.[40, 43, 44] The user highlights an area of concern (for example, a malformed hand or an unwanted accessory).[43, 44] 

With Remix Mode active, the user edits the textual prompt to describe the desired change specifically for the selected region.[40, 44] The model analyzes the surrounding context (lighting, perspective, texture) to generate four localized variations while leaving the rest of the image untouched.[40, 43]

```
┌────────────────────────────────────────────────────────┐
│               Midjourney Smart Select                  │
├────────────────────────────────────────────────────────┤
│                                                        │
│                  [Load Canvas Image]                   │
│                           │                            │
│                           ▼                            │
│                                │
│                           │                            │
│              ┌────────────┴────────────┐               │
│              ▼                         ▼               │
│      [Positive Points]         [Negative Points]       │
│      (Focus regions "+")       (Exclude regions "-")   │
│              │                         │               │
│              └────────────┬────────────┘               │
│                           │                            │
│                           ▼                            │
│                              │
│         (Synthesizes complex boundaries cleanly)       │
└────────────────────────────────────────────────────────┘
```

On the web-based Midjourney Editor, this selection mechanism is enhanced through "Smart Select".[42] Instead of requiring the user to manually paint intricate boundaries, the user places positive coordinate points (Include) to designate target features and negative points (Exclude) to protect adjacent details.[42] 

The system analyzes color contrast and texture edges to automatically construct a precise selection mask, streamlining the masking of complex borders.[42]

### Node-Based Multi-Model Pipelines: Figma Weave

Figma's acquisition of Weavy in 2025 led to the launch of "Figma Weave," a node-based generative AI canvas built for professional design operations.[6, 41] Figma Weave replaces standard, linear generation with a visual flowchart of step-by-step nodes.[41, 45]

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Figma Weave Pipeline                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  [Prompt Node] ──┬──> [Flux Model Node] ──────>          │
│                  ├──> [Ideogram Model Node] ───> [Mask Node]            │
│                  └──> ──────────> [Upscale Node] ─> [Out]│
│                                                                         │
│  • Compares multiple model outputs side-by-side on one canvas           │
│  • Chains generators with professional image processing nodes           │
│  • Packages workflow graphs into simplified, branded mini-apps          │
│  • Trains directly on brand systems (colors, spacing, typography)       │
└─────────────────────────────────────────────────────────────────────────┘
```

Figma Weave provides three key capabilities that set it apart from traditional AI generation tools:

1. **Multi-Model Parallel Generation**: Creators route a single prompt node to multiple generator models simultaneously (such as Flux or Ideogram for product shots, Recraft for illustrations, and Veo or Kling for video).[6, 45] This allows side-by-side output comparisons directly on the infinite canvas.[6]
2. **Professional Image-Processing Nodes**: Unlike standard AI tools, Figma Weave integrates advanced editing nodes directly into the generative pipeline.[6, 46] These include Masking & Cutouts (Mask Extractor, Inpaint, Outpaint), Color & Lighting (Relight, Color Grading, Channels), Spatial Geometry (Z-Depth Extractor, Crop), and Quality Enhancement (4K Upscale, Blur).[6, 46] These nodes chain together dynamically.[6] A designer can generate an asset, pass it through a Relight node to match brand assets, run a Z-Depth extractor to isolate foreground depth, and apply a 4K Upscale—maintaining complete, non-destructive editing control at each step.[6, 41]
3. **Workflow-to-App Compilation**: To bridge the gap between creative directors and non-technical staff, Figma Weave allows developers to package a complex node graph into a simplified "mini-app" with a streamlined user interface.[6, 47] Marketing or localization teams can upload a new product photo, type a basic prompt, and benefit from the advanced composition, color grading, and masking rules defined in the original graph without ever needing to touch the underlying node network.[6, 47]

Furthermore, Figma Weave trains directly on a team's localized design system.[47] The AI analyzes corporate color palettes, typography rules, spacing tokens, and structural component guidelines.[47] 

When a user prompts the canvas to "generate a dark-mode variation" or "create a motion interaction for this button," the engine automatically applies the rules of the brand's design system, maintaining visual coherence across all generated options.[47]

### Natural Language Vector Iteration: Figma Design AI and Canva

Within standard vector editing workspaces, Figma Design AI features "First Draft" (orchestrated by Figma’s agent).[48] This agent allows designers to select a vector frame directly on the canvas and input natural language adjustments via a comment box.[49] 

Commands like "adjust the layout to be responsive" or "convert this pricing table to a dark theme" trigger the agent to analyze the vector layer hierarchy, rename disorganized layers, add interactive prototyping connections, and compile updated vector structures in seconds.[48, 49] This workflow integrates generative speed directly into a standard design environment without requiring complex external plugins.[49]

Similarly, Canva AI, boosted by the acquisition of Leonardo AI, targets streamlined asset creation for small businesses and non-designers.[45, 50] Rather than relying on technical nodes, Canva integrates direct, canvas-based visual prompting to adapt templates, remove backgrounds, and adjust branding assets directly within a simplified drag-and-drop workspace.[50]

For designers seeking a middle ground between loose prompting and structured vector constraints, the third-party Figma plugin "Crafter" establishes a "vibe designing" workflow.[51] Crafter generates multiple design variations simultaneously across the Figma canvas from a single text prompt.[51] 

To bypass layout rendering bugs typical of pure code generation, Crafter outputs designs natively as vector SVGs.[51] The plugin scans local components and extracts styling data to ensure generated layouts automatically conform to active design systems, allowing designers to map edge cases and unhappy user paths instantly during early exploratory phases.[51]

---

## General Human-in-the-Loop Collaboration Patterns in Creative AI

As artificial intelligence shifts from a passive, execution-oriented utility to an active collaborative partner, platforms have adapted their interaction models to balance user control with machine autonomy.[1, 3, 15] This negotiation of roles has produced several distinct human-in-the-loop (HITL) patterns.[13, 52]

```
┌────────────────────────────────────────────────────────┐
│           Review-Driven Development (Antigravity)      │
├────────────────────────────────────────────────────────┤
│                                                        │
│                     [Enter Objective]                  │
│                            │                           │
│                            ▼                           │
│                              │
│                            │                           │
│                            ▼                           │
│                 [Collaborator Comments]                │
│             (Annotates specific tasks/code)            │
│                            │                           │
│                            ▼                           │
│                              │
│          (Agent pauses before terminal commands)       │
│                            │                           │
│                            ▼                           │
│                                   │
└────────────────────────────────────────────────────────┘
```

### Review-Driven Development: Google Antigravity

Google’s Antigravity platform models human-AI collaboration as a series of structured checkpoints, formalizing a pattern known as "Review-Driven Development".[52] When an operator dispatches an AI agent with a high-level task, the agent does not immediately execute the script.[52] Instead, the system progresses through a highly visible task hierarchy:

1. **Plan Generation**: The agent drafts an initial implementation plan.[52]
2. **Collaborative Annotation**: Instead of requiring a rewrite via conversational prompts, collaborators leave Google Docs-style comments directly on the plan’s items.[52] The agent ingests these localized notes, adjusts its proposed task list, and updates its strategy.[52]
3. **Execution Gatekeeping**: The agent pauses for manual approval at critical transition points—such as writing files, executing database migrations, or running terminal commands—ensuring the user retains oversight of the environment.[52]

To maintain workspace safety during autonomous browser tasks, Antigravity implements strict execution boundaries.[52] Administrators configure allowlists and denylists for both terminal commands and browser URLs.[52] This prevents prompt injection attacks or unauthorized actions, demonstrating that robust security parameters are essential for high-trust agentic systems.[52]

### Spec-Driven Development: Remy

While agentic tools help automate routine coding, they often struggle to maintain consistency over multi-step updates, producing fragmented architectures where "the demo works, but the production code breaks".[9] 

To bridge this gap, frameworks like "Remy" introduce **Spec-Driven Development**.[9] Remy decouples the conversational, visual prototyping layer from the core application compilation.[9] 

Rather than editing raw files directly, the user and AI collaborate to construct a single, structured, machine-readable specification file.[9] This specification acts as the source of truth for the entire application.[9] Once verified, Remy compiles this spec file into a clean, integrated codebase, preventing the layout drift and logical regressions common in purely iterative prompting.[9]

---

## Academic Research and Theoretical Frameworks on Human-AI Co-Creation

To formalize these workflows, researchers in human-computer interaction (HCI) and computer-supported cooperative work (CSCW) have developed theoretical frameworks to analyze agency distribution, control balances, and user interaction mechanics.[1, 3]

### Control as a Trajectory: The MOSAAIC Framework

Academic research demonstrates that co-creative control is not a static division of labor or a binary choice between manual execution and automation.[3] Instead, researchers like Alayt Issak, Jeba Rezwana, and Casper Harteveld (CHI 2026) show that **control is a trajectory, not a point**.[3] 

Using the MOSAAIC framework, their research models control as a negotiable, context-dependent relationship that shifts fluidly between the human and the AI partner throughout the creative lifecycle.[3]

```
┌────────────────────────────────────────────────────────┐
│             Co-Creation Control Trajectory             │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ─────────────────────────────────┐   │
│  • AI acts as an active partner / generator        │   │
│  • Low human control, high generative freedom      │   │
│                                                    │   │
│  ───────────────┐             │   │
│  • Shift in initiative; collaborative selection    │   │
│  • Mixed control, shared agency                    │   │
│                                                    │   │
│  <────────────┘             │   │
│  • Human assumes dominant, precise control         │   │
│  • Tightened constraints; AI behaves as a utility  │   │
└────────────────────────────────────────────────────────┘
```

This trajectory aligns with Wallas’ three-stage model of human-AI co-creativity:

* **Ideation**: The divergent phase where the AI operates with high autonomy, proposing diverse concepts and patterns while the human maintains lower, high-level control.[3, 53]
* **Illumination**: The selection and refinement phase where initiative shifts dynamically, allowing both parties to collaborate on defining the project direction.[3, 53]
* **Implementation**: The finalization phase where the human assumes dominant, precise control, using the AI as a high-fidelity utility to execute details.[3, 53]

This model expands on Shneiderman’s older four-phase framework (Collect, Relate, Create, Donate) and Frich's creativity support models by highlighting how shared initiative shifts over time.[53]

### The Structural Interaction Framework

To analyze how interfaces should behave when users refine AI-generated elements, Vincent Cavez (CSCW/UIST) introduced the **Structural Interaction framework**.[54] The framework models a user interface as a directed graph consisting of two nodes:

* **Elements**: The visible objects users perceive (such as a text layer, an image, or a button).[54]
* **Rules**: The organizational nodes governing those elements.[54] These include *declarative rules* (continuous constraints, like a layout container's minimum width) and *imperative rules* (conditional triggers, like button clicks).[54]

Crucially, the framework characterizes rule behavior along two orthogonal axes:

1. **Rigidity**: Defines how much a rule can be modified or redefined by the user, ranging across *Fixed*, *Negotiable*, *Malleable*, and *Authorable*.[54]
2. **Enforcement**: Defines how much a rule yields or bends during real-time interaction, ranging across *Persistent*, *Elastic*, *Escapable*, and *Liftable*.[54]

The intersection of these dimensions forms a 16-cell design space that helps developers analyze when layout constraints should yield or lock:

| Rigidity \ Enforcement | Persistent (Unyielding) | Elastic (Temporary Yield) | Escapable (Persistent Bypass) | Liftable (Suspended) |
| :--- | :--- | :--- | :--- | :--- |
| **Fixed (Immutable)** | Absolute constraints (e.g., core system database schemas) [54] | Magnetic boundaries (e.g., layout bounds that resist dragging but allow minor stretching) | Local exceptions (e.g., standard grid formatting that allows manual alignment overrides) | Optional constraints (e.g., global spellcheck rules that can be toggled off) |
| **Negotiable (Adjustable Bounds)** | Defined range limits (e.g., a volume limiter set with a hard cap) [54] | Spring-loaded boundaries (e.g., responsive page structures that yield on resizing and snap back) | Parameter offsets (e.g., default padding rules that allow lasting manual spacer inserts) | Dynamic toggles (e.g., grid alignment lines that can be completely bypassed on drag) |
| **Malleable (Redefinable)** | Structured schemas (e.g., custom database keys that must be populated) | Redefinable dynamics (e.g., custom gesture controls with temporary dampening) | Persistent overrides (e.g., custom hotkeys that bypass standard application mappings) | Adaptable environments (e.g., modular dashboards where panels can be unlocked and hidden) |
| **Authorable (User-Created)** | Compulsory validation rules (e.g., custom mandatory data-entry macros) [54] | Elastic algorithms (e.g., custom geometric constraints in 3D modeling programs) | Persistent custom rules (e.g., custom workflow triggers that override default system logic) | Extensible modules (e.g., newly written plugins that can be suspended or re-enabled at will) |

This model explains a common design flaw in modern generative UI tools.[54] When an AI generates a component (such as a dashboard layout), it typically compiles static code that behaves as **(fixed, persistent)**.[54] As generated components accumulate, the cost of manual structural revision increases, which often discourages users from iterating.[54] 

For a generative interface to be steerable, the AI system must generate the behavioral rules—the rigidity and enforcement states—alongside the visual components.[54] For example, during early ideation, an AI should output layout rules as **(negotiable, liftable)**, allowing the designer to push elements around freely.[54] As the project nears finalization, the rules can tighten to **(fixed, persistent)** to secure the layout.[54]

### Intent Alignment via Configurable Multimodal Scaffolds

To help designers express visual ideas without forcing them into purely verbal prompting, recent research has explored "Intent Alignment" via configurable multimodal scaffolds, such as **DesignPrompt**.[2] These scaffolds decompose a creator's intent into distinct, adjustable dimensions—such as image inpainting, color tokens, and semantic tags—and map them to an interactive prompt structure.[2] 

This allows designers to hold certain attributes (like a color palette) constant while exploring variations in others, providing a transparent and structured way to configure inputs before sending them to the generative model.[2]

### Attribution and Authorship Dynamics

As generative tools take on greater collaborative roles, the questions of authorship and credit allocation become increasingly complex.[55, 56] HCI research indicates that people's perception of AI authorship is highly nuanced, depending on the type of contribution, the amount of effort, and who led the creative process.[55, 56] 

Survey studies by Jessica He, Stephanie Houde, and Justin D. Weisz (CHI 2025/2026) reveal a consistent social pattern: knowledge workers assign significantly less credit to AI partners than to human partners for equivalent creative contributions.[55, 56] 

This dynamic highlights the need for transparent, AI-specific attribution frameworks that detail exactly *how* the AI contributed to a project (such as outlining whether the AI acted as a brainstormer, a structural editor, or a physical generator), helping teams meet emerging industry transparency requirements.[55]

---

## Conclusions and Strategic Design Principles

The shift from black-box text prompting to structured, element-level feedback loops marks a major step forward in human-AI creative systems.[1, 4, 41] By breaking artifacts down into modular nodes, editable text transcripts, and interactive UI elements, modern tools are successfully bridging the gap between quick prototypes and production-ready assets.[7, 9, 32] Based on this analysis of industry practices and academic frameworks, three core strategic design principles emerge for future creative platforms:

* **Decouple Visual Editing from Credit Consumption**: Following the patterns established by Lovable and Dualite, systems should provide credit-free visual editing overlays.[7, 14] Separating simple style adjustments (layout, color, copy) from heavy, token-based logical generation reduces the cost of iterative refinement, encouraging free, non-destructive experimentation.[7, 14]
* **Incorporate Structural Behavioral States**: In alignment with the Structural Interaction framework, generative tools must move beyond outputting static visual code.[54] AI models should generate both the visual layout and the behavioral rules (rigidity and enforcement) of the components.[54] Providing systems with a shared specification language for constraints (such as making rules *elastic* or *escapable*) ensures that human-AI collaboration remains steerable and prevents users from getting locked into rigid, non-modifiable designs.[54]
* **Build Non-Destructive Node-Based Workspaces**: As demonstrated by Figma Weave and ElevenLabs Flows, professional workflows thrive on node-based setups.[6, 33] Transitioning from linear timelines to modular graphs allows creators to isolate adjustments to specific steps, preventing context-loss and avoiding the need to regenerate unchanged parallel assets.[33, 41]

By building workflows around these structured interaction models, the next generation of creative tools can establish a more balanced, collaborative partnership—preserving human creative control while maximizing the efficiency of generative systems.[2, 3]

---

1. Exploring Collaboration Patterns and Strategies in Human-AI Co-creation through the Lens of Agency: A Scoping Review of the Top-tier HCI Literature - arXiv, [https://arxiv.org/html/2507.06000v2](https://arxiv.org/html/2507.06000v2)
2. Design Generative AI for Practitioners: Exploring Interaction Approaches Aligned with Creative Practice - arXiv, [https://arxiv.org/html/2603.03074v1](https://arxiv.org/html/2603.03074v1)
3. (PDF) "Control Is a Trajectory, Not a Point": Conceptualizing Control in Human-AI Co-Creativity - ResearchGate, [https://www.researchgate.net/publication/401026359_Control_Is_a_Trajectory_Not_a_Point_Conceptualizing_Control_in_Human-AI_Co-Creativity](https://www.researchgate.net/publication/401026359_Control_Is_a_Trajectory_Not_a_Point_Conceptualizing_Control_in_Human-AI_Co-Creativity)
4. Cursor vs Bolt vs Lovable 2026: Which AI Builder Wins? | Lovable, [https://lovable.dev/guides/cursor-vs-bolt-vs-lovable-comparison](https://lovable.dev/guides/cursor-vs-bolt-vs-lovable-comparison)
5. Best AI Video Editing Tools (2026): Extend, Inpaint, Replace, Restyle - Magic Hour, [https://magichour.ai/blog/best-ai-video-editing-tools-2026](https://magichour.ai/blog/best-ai-video-editing-tools-2026)
6. What is Figma Weave? A beginner's guide and a comprehensive analysis of the current state of third-party API integration, [https://help.apiyi.com/en/figma-weave-introduction-apiyi-api-integration-en.html](https://help.apiyi.com/en/figma-weave-introduction-apiyi-api-integration-en.html)
7. Lovable vs Bolt vs v0: AI App Builder Comparison, [https://lovable.dev/guides/lovable-vs-bolt-vs-v0](https://lovable.dev/guides/lovable-vs-bolt-vs-v0)
8. Lovable vs. Bolt vs. v0 – Which AI Web… - Till Freitag, [https://till-freitag.com/blog/lovable-vs-bolt-vs-v0-en](https://till-freitag.com/blog/lovable-vs-bolt-vs-v0-en)
9. Vercel v0 vs Bolt: Generating UIs vs Building Full Apps | MindStudio, [https://www.mindstudio.ai/blog/vercel-v0-vs-bolt](https://www.mindstudio.ai/blog/vercel-v0-vs-bolt)
10. We Tried Vercel v0: Pricing Breakdown and Honest Review - Flowstep, [https://flowstep.ai/blog/v0-pricing/](https://flowstep.ai/blog/v0-pricing/)
11. Design mode | v0 Docs - v0 by Vercel, [https://v0.app/docs/design-mode](https://v0.app/docs/design-mode)
12. Cursor vs v0: Which AI coding tool is right for you? [2026] - Softr, [https://www.softr.io/blog/cursor-vs-v0](https://www.softr.io/blog/cursor-vs-v0)
13. Existing Code vs Generated UI - Frontman vs v0, [https://frontman.sh/vs/v0/](https://frontman.sh/vs/v0/)
14. What is Interaction Mode in Dualite? - Dualite - Build products and websites in minutes, [https://dualite.dev/blogs/what-is-interaction-mode-dualite](https://dualite.dev/blogs/what-is-interaction-mode-dualite)
15. Cursor vs Windsurf (2025): Which AI Code Editor Wins? - Fair Developers, [https://fairdevs.com/blog/cursor-vs-windsurf-ai-code-editor-comparison](https://fairdevs.com/blog/cursor-vs-windsurf-ai-code-editor-comparison)
16. Exploring Leading AI Code Editors in 2025 | by Philip Mutua - Medium, [https://medium.com/@philip.mutua/exploring-leading-ai-code-editors-in-2025-453e6537e36c](https://medium.com/@philip.mutua/exploring-leading-ai-code-editors-in-2025-453e6537e36c)
17. Cursor vs Windsurf vs GitHub Copilot - Builder.io, [https://www.builder.io/blog/cursor-vs-windsurf-vs-github-copilot](https://www.builder.io/blog/cursor-vs-windsurf-vs-github-copilot)
18. v0 vs Cursor: One-to-One Comparison - Emergent, [https://emergent.sh/learn/v0-vs-cursor](https://emergent.sh/learn/v0-vs-cursor)
19. The Best AI Coding Tools in 2025 According To ChatGPT's Deep Research, [https://davidmelamed.com/2025/02/18/the-best-ai-coding-tools-according-to-chatgpts-deep-research/](https://davidmelamed.com/2025/02/18/the-best-ai-coding-tools-according-to-chatgpts-deep-research/)
20. Dualite vs Kombai: Which AI Tool Should You Choose to Build in 2026?, [https://dualite.dev/blogs/dualite-vs-kombai-which-ai-tool-should-you-choose-to-build-in-2026](https://dualite.dev/blogs/dualite-vs-kombai-which-ai-tool-should-you-choose-to-build-in-2026)
21. Dualite vs Plasmic: Which AI Tool Should You Choose to Build in 2026?, [https://dualite.dev/blogs/dualite-vs-plasmic-which-ai-tool-should-you-choose-to-build-in-2026](https://dualite.dev/blogs/dualite-vs-plasmic-which-ai-tool-should-you-choose-to-build-in-2026)
22. Dualite vs Locofy: Which AI Tool Should You Choose to Build in 2026?, [https://dualite.dev/blogs/dualite-vs-locofy-which-ai-tool-should-you-choose-to-build-in-2026](https://dualite.dev/blogs/dualite-vs-locofy-which-ai-tool-should-you-choose-to-build-in-2026)
23. Lovable Alternatives for 2026 - Builder.io, [https://www.builder.io/blog/lovable-alternatives](https://www.builder.io/blog/lovable-alternatives)
24. Vibe Coding in 2026: I Tried Cursor, Replit, Bolt, Lovable, and V0. Here's What Actually Ships. | by Nadia Okafor | Medium, [https://medium.com/@justtalkingtech/vibe-coding-in-2026-i-tried-cursor-replit-bolt-lovable-and-v0-heres-what-actually-ships-11d0b70cf1d5](https://medium.com/@justtalkingtech/vibe-coding-in-2026-i-tried-cursor-replit-bolt-lovable-and-v0-heres-what-actually-ships-11d0b70cf1d5)
25. Runway Gen 3 Video Generator: Steps & Review + Free Alternative, [https://dreamina.capcut.com/resource/runway-gen-3-video-generator](https://dreamina.capcut.com/resource/runway-gen-3-video-generator)
26. Inpainting - Runway, [https://help.runwayml.com/hc/en-us/articles/19155664495379-Inpainting](https://help.runwayml.com/hc/en-us/articles/19155664495379-Inpainting)
27. How to Use Runway's AI Video to Get a Dynamic Video - CapCut, [https://www.capcut.com/resource/runway-ai-video](https://www.capcut.com/resource/runway-ai-video)
28. How To Use The Motion Brush In Kling AI [2026 Guide] - YouTube, [https://www.youtube.com/watch?v=g0VlqSiydik](https://www.youtube.com/watch?v=g0VlqSiydik)
29. Pika, [https://pika.art/](https://pika.art/)
30. CapCut Video Studio Update Introduces Timeline Free AI Video Making on Web - Reddit, [https://www.reddit.com/r/aicuriosity/comments/1s3uzfc/capcut_video_studio_update_introduces_timeline/](https://www.reddit.com/r/aicuriosity/comments/1s3uzfc/capcut_video_studio_update_introduces_timeline/)
31. AI Image and Video Generator - Runway, [https://runwayml.com/product](https://runwayml.com/product)
32. Podcast Editing Software | Record, Edit, Publish - Descript, [https://www.descript.com/podcasting](https://www.descript.com/podcasting)
33. Automate your entire creative workflow with ElevenLabs Flows, [https://elevenlabs.io/flows](https://elevenlabs.io/flows)
34. Descript – AI Video & Podcast Editor | Free, Online, [https://www.descript.com/](https://www.descript.com/)
35. Descript AI Review 2025: Features, Pricing, and Real Results After 100+ Hours of Use, [https://fritz.ai/descript-ai-review/](https://fritz.ai/descript-ai-review/)
36. descript is saving me 3 hours per episode and i feel stupid for not switching sooner - Reddit, [https://www.reddit.com/r/podcasting/comments/1ri7ki9/descript_is_saving_me_3_hours_per_episode_and_i/](https://www.reddit.com/r/podcasting/comments/1ri7ki9/descript_is_saving_me_3_hours_per_episode_and_i/)
37. Studio 3.0 - AI audio and video editor for creators - ElevenLabs, [https://elevenlabs.io/studio](https://elevenlabs.io/studio)
38. ElevenCreative - Creative platform to bring your content to life - ElevenLabs, [https://elevenlabs.io/creative](https://elevenlabs.io/creative)
39. ElevenLabs voice generation in Adobe Firefly., [https://www.adobe.com/products/firefly/partner-models/elevenlabs.html](https://www.adobe.com/products/firefly/partner-models/elevenlabs.html)
40. Vary Region - MidJourney Docs, [https://docs.midjourney.com/hc/en-us/articles/32794723105549-Vary-Region](https://docs.midjourney.com/hc/en-us/articles/32794723105549-Vary-Region)
41. Node-Based AI Tools Explained: Weavy, Flora, and the Future of Creative Workflows, [https://www.houseofgai.com/blog/node-based-ai-tools-weavy-figma-weave](https://www.houseofgai.com/blog/node-based-ai-tools-weavy-figma-weave)
42. Editor - MidJourney Docs, [https://docs.midjourney.com/hc/en-us/articles/32764383466893-Editor](https://docs.midjourney.com/hc/en-us/articles/32764383466893-Editor)
43. Varying regions in Midjourney - by Alexey Inkin - Medium, [https://medium.com/@alexey.inkin/varying-regions-in-midjourney-e3d40d7bf938](https://medium.com/@alexey.inkin/varying-regions-in-midjourney-e3d40d7bf938)
44. Midjourney Inpainting Feature | Vary a Region of an Image | AI Text-to-Image Tutorial Walkthrough - YouTube, [https://www.youtube.com/watch?v=3QGaWF0DYEQ](https://www.youtube.com/watch?v=3QGaWF0DYEQ)
45. What the heck is Weavy (Figma Weave)? The 100% honest review… - Chase Jarvis, [https://chasejarvis.com/blog/what-the-heck-is-weavy-the-100-honest-review-after-the-figma-acqusition/](https://chasejarvis.com/blog/what-the-heck-is-weavy-the-100-honest-review-after-the-figma-acqusition/)
46. Figma Weave | AI-Powered Design Workflows, Built for Creative Pros, [https://weave.figma.com/](https://weave.figma.com/)
47. Inside Figma Weave: An AI Canvas for Collaborative Design and Motion - Amplifi Labs, [https://www.amplifilabs.com/post/inside-figma-weave-an-ai-canvas-for-collaborative-design-and-motion](https://www.amplifilabs.com/post/inside-figma-weave-an-ai-canvas-for-collaborative-design-and-motion)
48. Use AI tools in Figma Design, [https://help.figma.com/hc/en-us/articles/23870272542231-Use-AI-tools-in-Figma-Design](https://help.figma.com/hc/en-us/articles/23870272542231-Use-AI-tools-in-Figma-Design)
49. Figma AI Design Revolution: Select the Canvas, Comment with One Click, and Instantly Become a Professional Editor | by Harsel Givesh | Medium, [https://medium.com/@HarselGivesh/figma-ai-design-revolution-select-the-canvas-comment-with-one-click-and-instantly-become-a-5c23650a2fb1](https://medium.com/@HarselGivesh/figma-ai-design-revolution-select-the-canvas-comment-with-one-click-and-instantly-become-a-5c23650a2fb1)
50. Best AI Tools for Design | NextAutomation, [https://nextautomation.ai/ai-tools/design-tools](https://nextautomation.ai/ai-tools/design-tools)
51. I built a Figma plugin that uses AI to generate iterations on your existing UI designs - Reddit, [https://www.reddit.com/r/FigmaAddOns/comments/1pplhf7/i_built_a_figma_plugin_that_uses_ai_to_generate/](https://www.reddit.com/r/FigmaAddOns/comments/1pplhf7/i_built_a_figma_plugin_that_uses_ai_to_generate/)
52. Google Antigravity vs Cursor vs Claude Code: Honest Comparison After Building with All Three (2026), [https://www.aibuilderclub.com/blog/google-antigravity-complete-guide](https://www.aibuilderclub.com/blog/google-antigravity-complete-guide)
53. Investigating Human-AI Co-creativity in Prewriting with Large Language Models - Bo Wen, [https://wenbo.us/wp-content/uploads/2024/03/cscw-2024.pdf](https://wenbo.us/wp-content/uploads/2024/03/cscw-2024.pdf)
54. Structural Interaction for Generative User Interfaces - Vincent Cavez, [https://www.vincentcavez.com/pdf/Structural_Interaction_Gen_UI.pdf](https://www.vincentcavez.com/pdf/Structural_Interaction_Gen_UI.pdf)
55. Which Contributions Deserve Credit? Perceptions of Attribution in Human-AI Co-Creation - arXiv, [https://arxiv.org/pdf/2502.18357](https://arxiv.org/pdf/2502.18357)
56. [2502.18357] Which Contributions Deserve Credit? Perceptions of Attribution in Human-AI Co-Creation - arXiv, [https://arxiv.org/abs/2502.18357](https://arxiv.org/abs/2502.18357)
