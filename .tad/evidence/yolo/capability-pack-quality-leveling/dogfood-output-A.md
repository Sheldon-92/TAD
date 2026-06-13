# WITH-PACK Answer (video-creation pack loaded)

Scenario: 3 张人像照片（不同表情/姿势），做一个 6 秒卡点动态视频，背景配 lofi 音乐。

## Video Production Findings

### Step 0 — Intent Routing (ViMax Pattern 2)
Classify intent FIRST before picking any template. Multiple photos + beat sync (卡点) +
lofi mood → **montage** intent (emotional photo collage), NOT narrative, NOT motion.
montage routes to Emotional/Storytelling pacing (3-5s gradual builds, music-driven cuts,
BPM-aligned). This sits above storytelling.md video-type selection.

### Step 1 — Per-Photo Visual Decomposition (ViMax Pattern 1)
Each of the 3 photos = an AI image-to-video shot (~2s each). Decompose EVERY shot into
3 explicit parts — never feed a single "make it move" narrative:

| Photo | first_frame | last_frame | motion |
|-------|-------------|------------|--------|
| 1 | the photo as-is (neutral) | slight smile develops | subtle zoom in 10% |
| 2 | the photo as-is | head tilts right | slow pan left-to-right |
| 3 | the photo as-is | eyes look up | gentle dolly back |

first_frame is the existing photo; generate the last_frame end-state via gpt-image-2;
feed first_frame + last_frame + motion text to Seedance image-to-video endpoint.

### Step 2 — View consistency check (ViMax Pattern 3)
3 different people / poses → repeated-character condition NOT met → Pattern 3 NOT triggered.
(If it were the same person at different angles, generate a front/side/back view-specific
reference sheet and feed the angle-matched view per shot.)

### Step 3 — Camera Tree / scene cohesion check (ViMax Pattern 4)
3 distinct portraits, no shared physical scene → camera_tree NOT triggered.
(If the photos shared one location across consecutive shots, build a camera_tree: widest
framing = parent shot, tighter child shots cite the parent's spatial elements — object
positions, lighting direction, color temperature — to prevent inter-cut drift.)

### Audio
- montage intent → music BPM target 20-80 (Emotional/Storytelling range); lofi ≈ 75 BPM
- Mix: music = 15% bed (no voiceover in this clip)
- Cut formula: cut_interval = 60 / 75 = 0.8s beat → cut every ~2-3 beats ≈ 2.0s per photo
- SFX Pre-Lead: soft whoosh 20ms before each cut (1.98s, 3.98s)

### Tool
- Selected: HyperFrames (HTML-native, no build) for assembly; Seedance 2.0 for the
  image-to-video clips.

### Quality Targets
- Platform: TikTok/Reels vertical, 1080x1920, H.264 CRF 20.
