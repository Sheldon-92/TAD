# AI Asset Generation Reference

> Pricing last verified: 2026-05-08
> Sources: RS-20260508-001 (7e9c2c57, 25 sources — images/video) + RS-20260508-002 (65359194, 21 sources — voice/SFX)
> Remotion/FFmpeg patterns supplemented from existing video-creation pack knowledge (not notebook sources).

---

## Decision Tree

Use this tree to select the generation tool before writing any code.

```
Need to GENERATE visual assets? →

  Need a static image?
  (character art, background, product shot, storyboard, icon, banner)
    YES → Codex gpt-image-2 (§Codex gpt-image-2 Rules)

  Need a video clip?

    Is 4K resolution mandatory?
      YES → Kling 3.0 (native 4K@60fps — highest raw fidelity)
      NO  ↓

    Is the existing toolchain Runway-native?
    (team already using Runway Gen-4 in production)
      YES → Runway Gen-4 (ecosystem continuity)
      NO  ↓

    → Seedance 2.0 (default for agent workflows)
      Reasons: native audio + multimodal input (9 img + 3 vid + 3 aud) +
               first/last frame control + well-documented async API
      (§Seedance 2.0 Rules)

Need to GENERATE audio assets? →

  Need voiceover / narration?
    Does Seedance already provide lip-synced speech for this scene?
      YES → Use Seedance native lip-sync audio (free, auto-synced, no extra API call)
      NO  ↓
    Is cross-lingual or CJK quality critical?
      YES → Fish Audio S2 Pro (80+ languages, 10s clone, best CJK)
      NO  ↓
    Is maximum English expressiveness critical?
      YES → ElevenLabs v3 (industry benchmark for English drama/emotion)
      NO  ↓
    → OpenAI TTS tts-1-hd (simplest, cheapest, good-enough quality)
    (§TTS Voiceover Rules)

  Need voice cloning (brand voice consistency)?
    ⚠️ CONSENT GATE: agent MUST confirm user has authorization before ANY clone API call
    Is cross-lingual cloning needed?
      YES → Fish Audio (10-15s sample, 80+ languages cross-lingual)
      NO  → ElevenLabs IVC (30-60s sample, English benchmark)
    (§Voice Cloning Rules)

  Need standalone sound effects?
    Is the SFX tied to video motion (diegetic — footsteps, ambient, explosions)?
      YES → Use Seedance native audio (free, auto-synced)
      NO  → ElevenLabs SFX API (text → sound, max 30s, looping supported)
    (§AI Sound Effects Rules)
```

> [Claim 5: RS-20260508-001] Visual competitive positioning verified. [Claim 1-3: RS-20260508-002] Audio routing from TTS/cloning/SFX research.

---

## Seedance 2.0 Rules

### Seedance Endpoint Selection

Choose the endpoint based on what inputs you have:

| Input | Endpoint | Notes |
|-------|----------|-------|
| Text description only | **text-to-video** | Generates from prompt alone |
| Text + 1-2 start/end images | **image-to-video** | JPEG/PNG/WebP, max 30MB each |
| Text + multiple references (images, clips, audio) | **reference-to-video** | Up to 9 img + 3 vid + 3 aud |

> [Claim 1: RS-20260508-001] Endpoint specs from 6 official sources with consistent data.

### Endpoint Specification Table

| Spec | Text-to-Video | Image-to-Video | Reference-to-Video |
|------|--------------|----------------|-------------------|
| **Inputs** | Text prompt | Text + 1-2 images (JPEG/PNG/WebP) | Text + ≤9 images + ≤3 videos + ≤3 audio |
| **Resolution** | 480p / 720p | 480p / 720p / 1080p (Standard) | 480p / 720p / 1080p (Standard) |
| **Duration** | 4–15 seconds | 4–15 seconds | 4–15 seconds |
| **Aspect Ratios** | auto, 21:9, 16:9, 4:3, 1:1, 3:4, 9:16 | Same + auto from image | Same |
| **Audio** | Native sync (SFX, lip-sync, ambient) — free | Native sync — free | Native + reference audio for lip-sync |
| **Cost (fal.ai)** | Standard $0.30/s, Fast $0.24/s | Standard $0.30/s, Fast $0.24/s | Standard $0.30/s, Fast $0.24/s ($0.18/s with video input) |
| **Cost (Atlas Cloud)** | Standard $0.10/s, Fast $0.08/s | Standard $0.10/s, Fast $0.08/s | Standard $0.10/s, Fast $0.08/s |

**Input constraints:**
- Images: max 30MB each
- Video inputs: 2–15s combined, <50MB, 480–720p
- Audio: max 15MB each, ≤15s combined, requires ≥1 image/video

> [Claim 1: RS-20260508-001]

### Async API Pattern

**Never use `fal_client.subscribe()`** — it blocks the calling thread. Use submit-then-poll.

#### Submit-Then-Poll

```python
import fal_client
import hashlib, json, time

# 1. Hash the request before submission (deduplication)
params = {
    "model_id": "fal-ai/seedance-1-lite",  # or seedance-1-pro
    "route": "text-to-video",
    "prompt": "A hero walks through a neon city at night, Shot 1: wide establishing shot",
    "resolution": "720p",
    "duration": 5,
}
request_hash = hashlib.sha256(
    json.dumps(params, sort_keys=True).encode()
).hexdigest()

# 2. Submit (async — returns immediately)
result = fal_client.submit(
    "fal-ai/seedance-1-lite/text-to-video",
    arguments=params,
)
task_id = result.request_id  # Save this with request_hash

# 3. Poll with schedule: initial 5s, then every 10s, max 120s
INITIAL_DELAY = 5    # seconds before first poll
POLL_INTERVAL = 10   # seconds between polls
MAX_TIMEOUT = 120    # seconds total

time.sleep(INITIAL_DELAY)
elapsed = INITIAL_DELAY
while elapsed < MAX_TIMEOUT:
    status = fal_client.status("fal-ai/seedance-1-lite/text-to-video", task_id)
    # States: queued → running → succeeded / failed / expired
    if status.status == "succeeded":
        video_url = status.response["video"]["url"]
        break
    elif status.status in ("failed", "expired"):
        raise RuntimeError(f"Generation {status.status}: {status.response}")
    time.sleep(POLL_INTERVAL)
    elapsed += POLL_INTERVAL
else:
    raise TimeoutError(f"Generation exceeded {MAX_TIMEOUT}s timeout")
```

**Task state machine:** `queued` → `running` → `succeeded` / `failed` / `expired`

> [Claim 3: RS-20260508-001] Submit-then-poll pattern from 3 sources with code examples.

#### Poll Schedule

- **Initial poll:** 5 seconds after submission
- **Poll interval:** every 10 seconds
- **Max timeout:** 120 seconds total
- **On timeout:** report to user, do NOT auto-retry generation

> [Claim 3 / BA-P0-1: RS-20260508-001]

#### Webhook Alternative

For agents with a reachable HTTP endpoint, use webhooks as the primary notification mechanism:

```python
result = fal_client.submit(
    "fal-ai/seedance-1-lite/text-to-video",
    arguments=params,
    webhook_url="https://your-agent-endpoint/seedance-callback",
)
```

**Requirements:**
- Webhook handlers must be **idempotent** — dedup by `request_id` (Seedance task_id), not by event_id or timestamp
- Always run a **fallback poller** alongside webhooks (delivery not guaranteed)
- Fallback poller uses the same 10s/120s schedule above
- Update task state atomically — partial state transitions on duplicate events defeat the dedup

> [Claim 3 / BA-P0-1: RS-20260508-001]

### Request Hashing

Hash every request BEFORE the API call to prevent duplicate paid generations.

```python
# Hash composition: model_id + route + prompt + media_urls + settings
def compute_request_hash(model_id, route, prompt, media_urls=None, settings=None):
    payload = {
        "model_id": model_id,
        "route": route,
        "prompt": prompt,
        "media_urls": sorted(media_urls or []),
        "settings": settings or {},
    }
    return hashlib.sha256(json.dumps(payload, sort_keys=True).encode()).hexdigest()
```

**Deduplication logic:**
1. Compute hash before any API call
2. Persist `{request_hash, task_id, status, submitted_at}` to **durable storage** (sqlite, JSON file) **immediately after submit returns** — before the first poll. This enables crash-resume without duplicate charges.
3. Check local state: if hash + provider_id already exists → resume polling, NEVER resubmit
4. If hash exists but no provider_id (network failure) → resubmit once, update provider_id
5. If no existing record → submit and store hash + task_id together

**⚠️ Presigned URL warning:** If media_urls contain presigned S3/R2/GCS URLs (query params like `?X-Amz-Signature=...&Expires=...`), strip the query string before hashing. Presigned tokens change on every upload of the same file, defeating deduplication. Hash by stable resource identifier (S3 key without query string) or content hash (sha256 of file bytes).

**Re-generation escape hatch:** If the user explicitly requests a re-roll (not a retry):

```python
# Append attempt_number to bypass dedup
attempt = 2  # increment per re-roll
payload["attempt_number"] = attempt
request_hash = compute_request_hash(**payload)
```

> [Claim 3 / BA-P0-2: RS-20260508-001]

### Rate Limiting

- **Max concurrent submissions:** 2–3 per agent instance
- **Multi-scene projects:** serialize submissions (submit scene 2 only after scene 1 is queued/running)
- **On 429 response:** backoff 30 seconds before retrying

```python
import time
from threading import Semaphore

# Self-imposed concurrency cap (cost + politeness): 2-3 per agent instance
# Provider-enforced 429 is a separate concern — handle independently
MAX_CONCURRENT = 2
_semaphore = Semaphore(MAX_CONCURRENT)

def submit_with_rate_limit(endpoint, params):
    """Acquire semaphore before submitting to limit concurrent requests."""
    _semaphore.acquire()
    try:
        result = fal_client.submit(endpoint, arguments=params)
        return result
    except Exception:
        _semaphore.release()
        raise

def on_task_complete():
    """Call when a task finishes (succeeded, failed, or expired)."""
    _semaphore.release()

def handle_429(response):
    # On 429, backoff 30s then retry submission
    time.sleep(30)
    raise Exception("Rate limited by provider — retry after 30s")
```

> [Claim 3 / BA-P0-3: RS-20260508-001] Rate limiting from research; exact limit not specified by provider (serialize as precaution).

### Retry Strategy

| Error Type | Action |
|-----------|--------|
| Network transient (5xx, timeout) | Retry polling with backoff — NEVER resubmit |
| Generation failure (bad input, content moderation) | Zero automatic resubmission — report to user |
| Provider 429 | Backoff 30s, then retry submission |
| Task expired | Report to user — do NOT silently resubmit |

> Content moderation rejections must be reported to the user; do NOT attempt to rephrase and resubmit automatically.

### Prompt Rules

#### Motion Safety
- ❌ Avoid the word **"fast"** in prompts — causes visual jitter
- ✅ Keep one element fast at a time (either camera OR subject — not both)
- ✅ Separate camera motion and subject motion into distinct shots when both are needed

#### Duration-to-Shot Allocation
- Minimum **3–5 seconds per shot** (fewer = compressed/skipped frames)
- Never request 4 shots in 5 seconds
- Use explicit **"Shot N:"** labels for multi-shot sequences

```
✅ Good: "Shot 1: Wide establishing shot of the city (5s). Shot 2: Close-up on hero face (4s)."
❌ Bad:  "4 shots of hero walking through city in 5 seconds"
```

#### Character Consistency
- Generate a 4K multi-panel character sheet from 1–3 reference photos
- Use `@character:<id>` tag in subsequent prompts to maintain identity

#### Omni-Reference Prompting
- Tag reference images in prompt text: `@Image1`, `@Image2`, etc.
- Tag reference videos: `@Video1`, `@Video2`
- Tag reference audio: `@Audio1`
- Order: describe scene → reference tags → motion instructions

> [Claim 6: RS-20260508-001]

---

## Codex gpt-image-2 Rules

### Supported Asset Types

Use gpt-image-2 to generate static images for video compositions:

| Asset Type | Example Use Case |
|-----------|-----------------|
| Characters & concept art | Character design sheets, hero portraits |
| Product/packaging shots | Product demos, e-commerce videos |
| UI/UX mockups & wireframes | Tutorial overlay graphics |
| Multi-panel storyboards | 6-panel format for pre-viz |
| Icons & banners | Lower thirds, thumbnail overlays |
| Illustrations & sprite sheets | Motion graphics source assets |
| Infographics & diagrams | Data visualization overlays |

> [Claim 2: RS-20260508-001] Asset types from 4 official OpenAI sources.

### Output Specifications

| Spec | Value |
|------|-------|
| Max resolution | 4K (stable output at 2K/2560×1440) |
| Edge constraint | Must be multiples of 16px |
| Aspect ratio | Max 3:1 ratio |
| Formats | PNG, JPEG, WebP |
| Text rendering | >99% accuracy (Latin, CJK, Arabic) |
| Transparency | ❌ No native transparent background |

**No-transparency workaround:** Use chroma-key technique:
1. Prompt: include "on a solid green background (#00FF00)"
2. Post-process with FFmpeg:
   ```bash
   ffmpeg -i image.png -vf "chromakey=0x00ff00:0.1:0.2" output.png
   ```
3. Verify alpha channel is correctly removed in the output

> [Claim 2 / BA-P1-6: RS-20260508-001]

### Invocation

**In Codex:** Use `$imagegen` keyword or natural language in prompt.

```
# Natural language
Generate a character sheet for the hero: athletic build, red jacket, dark hair

# Explicit keyword
$imagegen: character design sheet showing front/side/back views, studio lighting
```

**Default save path:** `$CODEX_HOME/generated_images/` — Codex auto-moves to requested path if specified.

**API billing:** Set `OPENAI_API_KEY` for batch work to avoid 3–5x plan consumption:
```bash
export OPENAI_API_KEY=sk-...
# Now use API billing instead of Codex plan limits
```

> [Claim 2: RS-20260508-001]

### Prompt Structure

Order matters — follow this sequence every time:

```
1. Background / scene context
2. Subject (who/what)
3. Key details (style, lighting, mood)
4. Constraints ("on white background", "no text")
```

**Example:**
```
Futuristic neon city at dusk (background),
athletic hero in red jacket standing at corner (subject),
cinematic lighting, high contrast, detailed fabric texture (details),
portrait orientation, no text overlay (constraints)
```

> [Claim 6: RS-20260508-001]

### Identity Preservation

When iterating on a character across multiple generations:

1. **Use the edit endpoint** (`/v1/images/edits`), NOT regeneration from scratch
2. **Pass reference image** as input to maintain visual identity
3. **Invariant anchoring:** In EVERY iteration prompt, explicitly list what must not change:
   ```
   Keep unchanged: face shape, eye color, red jacket, hair style.
   Change: background environment only.
   ```

> [Claim 6: RS-20260508-001] Identity preservation from official OpenAI sources.

### Edit Capabilities

| Edit Type | Use Case |
|----------|----------|
| Inpainting | Replace specific regions (sky, background) |
| Style transfer | Apply artistic style to existing image |
| Background replacement | Swap background, keep subject |
| Sketch → render | Upgrade rough sketch to final art |

### Quality Parameter

| Use Case | `quality` Setting |
|---------|-----------------|
| Text-heavy overlays | `"high"` |
| Layout-sensitive assets | `"high"` |
| Draft/iteration assets | `"low"` |
| Final production assets | `"high"` |

```python
# API example
response = client.images.generate(
    model="gpt-image-2",
    prompt="...",
    quality="high",  # or "low" for drafts
    size="1024x1024",
)
```

---

## Pipeline Integration

### File Path Convention

Paths are split by the downstream composition tool. Generated files must be moved to the correct location after generation.

| Tool | Generated Images | Generated Video Clips |
|------|-----------------|----------------------|
| **HyperFrames** | `assets/generated-images/` | `assets/generated-clips/` |
| **Remotion** | `public/generated-images/` | `public/generated-clips/` |

> [BA-P0-4: RS-20260508-001] Path split required: HyperFrames resolves HTML paths directly from `assets/`; Remotion's `staticFile()` resolves from `public/` only.

### Post-Generation File Placement

Codex saves to `$CODEX_HOME/generated_images/` by default. Move files to the project convention path after generation:

```bash
# HyperFrames project
mv "$CODEX_HOME/generated_images/hero.png" ./assets/generated-images/hero.png
mv "$CODEX_HOME/generated_images/bg.png"   ./assets/generated-images/bg.png

# Remotion project
mv "$CODEX_HOME/generated_images/hero.png" ./public/generated-images/hero.png
mv "$CODEX_HOME/generated_images/bg.png"   ./public/generated-images/bg.png
```

For Seedance clips (downloaded from URL):
```bash
# HyperFrames
curl -o ./assets/generated-clips/scene1.mp4 "$VIDEO_URL"

# Remotion
curl -o ./public/generated-clips/scene1.mp4 "$VIDEO_URL"
```

> [BA-P1-3: RS-20260508-001]

### HyperFrames Integration

Standard HTML tags — no build step required:

```html
<!-- Generated image -->
<img src="./assets/generated-images/hero.png" alt="Hero character">

<!-- Generated video clip -->
<video src="./assets/generated-clips/scene1.mp4" autoplay muted playsinline></video>
```

> [Claim 4: RS-20260508-001] HyperFrames confirmed from notebook sources.

### Remotion Integration

Use Remotion's media components with `staticFile()`:

```tsx
import { Img, Video, Audio, staticFile } from "remotion";

// Generated image (file in public/generated-images/)
<Img src={staticFile("generated-images/hero.png")} />

// Generated video clip (file in public/generated-clips/)
<Video src={staticFile("generated-clips/scene1.mp4")} />

// Seedance-generated audio (file in public/generated-audio/)
<Audio src={staticFile("generated-audio/scene1-ambient.wav")} />
```

> [Claim 4 / BA-P0-4: RS-20260508-001] `public/` prefix required for staticFile() resolution.

### FFmpeg Post-Processing

Combine or transform generated assets using FFmpeg:

```bash
# Concatenate multiple Seedance clips
ffmpeg -f concat -safe 0 -i clip-list.txt -c copy output.mp4

# Overlay gpt-image-2 image on video
ffmpeg -i video.mp4 -i overlay.png \
  -filter_complex "[0:v][1:v]overlay=10:10" output.mp4

# Mix Seedance native audio with background music
ffmpeg -i video.mp4 -i seedance_audio.wav -i bgm.mp3 \
  -filter_complex "[2:a]volume=0.15[bg];[1:a][bg]amix=inputs=2:duration=first[mix]" \
  -map 0:v -map "[mix]" -c:v copy -c:a aac output.mp4
```

> [Claim 4: RS-20260508-001] FFmpeg patterns supplemented from existing pack knowledge (not notebook sources).

---

## Cost Control

### Tiered Generation Strategy

**Tier selection rule:**

| Tier | Purpose | Resolution | Quality |
|------|---------|-----------|---------|
| Fast | Drafts, style approval, iteration | 480p | Low cost |
| Standard | Production, final delivery | 1080p | Full fidelity |

**Never use production quality for drafts.** Always tier:

1. **Draft** → 480p / Fast tier → confirm style and motion
2. **Approval** → show draft to user for explicit go-ahead
3. **Final** → 1080p / Standard tier → production asset

```python
# Draft submission
draft_params = {**params, "resolution": "480p", "quality": "Fast"}

# Final submission (only after approval)
final_params = {**params, "resolution": "1080p", "quality": "Standard"}
```

### Duration Caps

- Start with **5-second** test clips — cheapest feedback loop
- Extend to **10–15 seconds** only after style approval
- Avoid generating 15s clips for initial testing

### Video Reference Discount

Using video inputs in `reference-to-video` triggers a **0.6x price multiplier**:

- Standard rate: $0.30/s (fal.ai) or $0.10/s (Atlas Cloud)
- With video input: $0.18/s (fal.ai) or $0.06/s (Atlas Cloud)

### Cost Table

| Provider | Tier | Rate | 5s clip | 10s clip | 15s clip |
|----------|------|------|---------|---------|---------|
| fal.ai | Standard | $0.30/s | $1.50 | $3.00 | $4.50 |
| fal.ai | Fast | $0.24/s | $1.20 | $2.40 | $3.60 |
| fal.ai | Standard + video ref | $0.18/s | $0.90 | $1.80 | $2.70 |
| Atlas Cloud | Standard | $0.10/s | $0.50 | $1.00 | $1.50 |
| Atlas Cloud | Fast | $0.08/s | $0.40 | $0.80 | $1.20 |

**gpt-image-2 cost estimate:**
- 4 images at high quality: ~$0.84
- Use `OPENAI_API_KEY` for batch work (>3 images) to avoid 3–5x plan consumption

**Typical project cost range:** $6.84 – $19.04 (4 images + 60s video)

> [Claim 7: RS-20260508-001]

---

## Visual Consistency Rules

### Cross-Asset Consistency

Apply these rules across both Codex and Seedance to maintain visual coherence:

#### Color Palette Lock
- Generate a color palette reference image first (gpt-image-2)
- Include palette hex codes in EVERY subsequent prompt
- Example: "Use palette: primary #1a1a2e, accent #e94560, background #16213e"

#### Lighting Continuity
- Choose one lighting direction (e.g., "soft left-side rim light")
- Include lighting specification verbatim in every prompt

#### Style Anchoring (gpt-image-2)
- First generate a style reference image at target quality
- Use edit endpoint for all subsequent assets (not fresh generation)
- Invariant anchoring: "Keep lighting, color grading, and art style unchanged"

#### Character Consistency (Seedance)
1. Generate 4K character sheet with front/side/back/expression views
2. Register sheet as `@character:<id>` in the project
3. Include `@character:<id>` tag in every scene that features this character

#### Style Drift Mitigation
- **Codex:** Every 3rd iteration, compare to the original reference using side-by-side; restart from reference if drift exceeds tolerance
- **Seedance:** Use Omni-reference (`@Image1`, `@Image2`) with 2 reference frames from prior approved clips to anchor style

> [Claim 6: RS-20260508-001]

---

## Quality Thresholds

### Seedance Clip Quality Checks

Before accepting a clip as production-ready:

- [ ] No visible artifacts or compression blocks
- [ ] No compressed/skipped shots (check that all labeled shots are present)
- [ ] Motion matches shot description (no jitter from "fast" vocabulary)
- [ ] Audio sync intact (if native audio was requested)
- [ ] Duration matches spec (±0.5s acceptable)

### gpt-image-2 Image Quality Checks

- [ ] No transparency limitations violated (check if alpha needed → use chroma-key workaround)
- [ ] Text rendered accurately (>99% Latin/CJK/Arabic)
- [ ] Edge dimensions are multiples of 16px
- [ ] Aspect ratio does not exceed 3:1

### Anti-Patterns

| Anti-Pattern | Consequence | Fix |
|-------------|-------------|-----|
| ❌ Use `fal_client.subscribe()` | Blocks agent thread | Use submit-then-poll |
| ❌ No request hashing before retry | Duplicate paid generation | Hash before every call |
| ❌ Start with 1080p/Standard drafts | 3x unnecessary cost | Draft at 480p/Fast |
| ❌ Use "fast" in Seedance prompt | Visual jitter | Remove — describe speed via context |
| ❌ Request many shots in short clips | Compressed/skipped frames | Min 3–5s per shot |
| ❌ Regenerate for identity preservation | Identity drift | Use edit endpoint + reference |
| ❌ Use submit-then-poll for TTS | TTS is synchronous — no polling needed | Call API, receive bytes directly |
| ❌ Call clone API without consent check | Legal/ethical violation | Consent Gate FIRST, always |

---

## TTS Voiceover Rules

> Source: RS-20260508-002 (65359194, 21 sources, 5 ask rounds)

### API Pattern: Synchronous Response (NOT Async)

**⚠️ TTS APIs return audio bytes directly in the HTTP response body. There is NO task_id, NO polling, and NO webhook.**

This is the OPPOSITE of Seedance (which uses submit-then-poll). Do not copy the async pattern.

```python
# ✅ CORRECT — TTS is synchronous
audio_bytes = client.text_to_speech.convert(text="Hello", voice_id="...")
with open("output.mp3", "wb") as f:
    for chunk in audio_bytes:
        f.write(chunk)

# ❌ WRONG — TTS has no task_id to poll
task_id = client.text_to_speech.submit(text="Hello")  # This does not exist
```

**Batch mode rule:** Wait for the full response before proceeding. Do NOT use streaming for video production pipelines — streaming is for real-time conversation apps, not voiceover generation.

> [Claim 4: RS-20260508-002] All three TTS APIs (ElevenLabs, OpenAI, Fish Audio) return audio bytes directly.

### Tool Comparison Table

| Feature | ElevenLabs | OpenAI TTS | Fish Audio |
|---------|-----------|-----------|-----------|
| **Models** | v3 (expressive), Multilingual v2 (stable), Flash v2.5 (~75ms) | tts-1 (fast), tts-1-hd (quality), gpt-4o-mini-tts (newest) | S1 (fast), S2 Pro (flagship 5B param) |
| **Languages** | 70+ | 50+ | 80+ |
| **Emotion control** | Natural language cues in text | None | 15,000+ inline tags + `(happy)`/`(sad)` syntax |
| **Output formats** | MP3, PCM, WAV, Opus, μ-law | MP3, Opus, AAC, FLAC, WAV, PCM | MP3, Opus, WAV, PCM |
| **Built-in voices** | 3,000–10,000+ | 6 | 2,000,000+ community |
| **Pricing** | Subscription $5+/mo | $15/1M chars (tts-1), $30/1M (tts-1-hd) | $15/1M UTF-8 bytes |
| **Cloning min** | 30-60s (IVC) | None | 10–15s |

> [Claim 1: RS-20260508-002]

### Model Selection Rules

**ElevenLabs:**
- `eleven_v3` — Maximum expressiveness, English drama/emotion (default for English)
- `eleven_multilingual_v2` — Stable, 29 languages (non-English default)
- `eleven_flash_v2_5` — ~75ms latency, for real-time preview only

**OpenAI TTS:**
- `tts-1` — Fast, lower quality, good for iteration
- `tts-1-hd` — High quality, 2× slower (default for final production)
- `gpt-4o-mini-tts` — Newest, instruction-following for tone control

**Fish Audio:**
- `S1` — Fast inference, good quality
- `S2 Pro` — Flagship 5B param, best CJK, most expressive (default for Fish Audio)

### Emotion Control

| Platform | Mechanism | Example |
|---------|----------|---------|
| ElevenLabs | Natural language cues embedded in text | "...said with a trembling voice. [pause] She looked up." |
| Fish Audio | 15,000+ inline tags + `(emotion)` syntax | `(happy) Great news! (serious) But there are risks.` |
| OpenAI | None — voice selection only | N/A |

### ElevenLabs Python SDK Example

```python
import os
from elevenlabs.client import ElevenLabs

client = ElevenLabs(api_key=os.getenv("ELEVENLABS_API_KEY"))

# Batch mode: collect full response (NOT streaming)
audio = client.text_to_speech.convert(
    text="The first move is what sets everything in motion.",
    voice_id="JBFqnCBsd6RMkjVDRZzb",
    model_id="eleven_v3",
    output_format="pcm_44100",  # WAV/PCM for video pipeline (see Format Recommendation)
)

# audio is bytes — write directly
output_path = "assets/generated-audio/voiceover/scene01-voiceover.wav"
with open(output_path, "wb") as f:
    for chunk in audio:
        f.write(chunk)
```

> [Claim 4: RS-20260508-002] SDK pattern from official ElevenLabs docs.

### Format Recommendation

**Request WAV/PCM output for video production pipelines** — lossless intermediate format prevents quality loss during FFmpeg mixing.

```python
# ElevenLabs: request PCM
output_format="pcm_44100"  # or "pcm_24000"

# OpenAI: request WAV
response_format="wav"

# Fish Audio: request WAV or PCM natively (no transcode needed)
TTSRequest(text="...", format="wav", sample_rate=44100)
# Or PCM:
TTSRequest(text="...", format="pcm", sample_rate=44100)
# Only transcode if you explicitly requested MP3 for a legacy reason:
# ffmpeg -i voiceover.mp3 -c:a pcm_s16le voiceover.wav
```

> [BA-P1-1 amended: RS-20260508-002] Fish Audio natively supports WAV and PCM via `format` parameter in `TTSRequest` — request the right format upfront instead of transcoding.

### Rate Limiting

- Serialize multi-scene TTS calls: **1 at a time** (TTS is fast, 1–5s each — serialization cost is low)
- On **429**: backoff 10 seconds before retry
- On **400**: do not retry — report to user (bad request, usually text too long or bad voice_id)
- On **401**: API key issue — halt and report
- TTS is synchronous, so no concurrent request tracking needed

> [BA-P1-4: RS-20260508-002]

### Timing Rule

**Generate TTS voiceover BEFORE composing video scenes.**

Voiceover audio duration drives scene timing. Build scene durations to match the TTS output, not the other way around. (Cross-ref: audio-design.md — "Record voiceover first, then build scene durations to match.")

---

## Voice Cloning Rules

> Source: RS-20260508-002 (65359194)

### Consent Gate (MANDATORY)

**⚠️ Before ANY voice cloning API call, the agent MUST obtain explicit user authorization.**

```
AskUserQuestion:
"You are about to clone a voice from [sample file]. 
Do you confirm that you have authorization from the voice owner to clone this voice?"
Options: [YES, I have authorization] / [NO, cancel]
```

- **Do NOT proceed** if user selects NO
- **Log the confirmation** alongside the voice_id in project state
- Platform-specific consent mechanisms (e.g., ElevenLabs voice captcha) are ADDITIONAL to this gate, not a replacement
- This applies to ALL platforms (ElevenLabs, Fish Audio, and any future platform)

> [BA-P0-3: RS-20260508-002] Consent gate is legal/ethical requirement, not optional.

### Fish Audio Cloning Workflow

```python
from fish_audio_sdk import Session, TTSRequest, ReferenceAudio

session = Session(api_key=os.getenv("FISH_API_KEY"))

# Step 1: Read reference sample bytes (10-15s minimum, SNR >30dB)
# Fish Audio inlines the sample in the TTS call — no separate upload step
with open("brand-voice-sample.wav", "rb") as f:
    sample_bytes = f.read()

# Step 2: TTS with voice cloning — session.tts() returns a Generator, NOT a context manager
request = TTSRequest(
    text="Your voiceover script here.",
    reference_id=None,   # use stored reference_id OR inline references, not both
    references=[ReferenceAudio(audio=sample_bytes, text="[exact transcript of brand-voice-sample.wav]")],
    format="wav",        # Native WAV output — no transcode needed (see Format Recommendation)
    sample_rate=44100,
)

output_path = "assets/generated-audio/voiceover/scene01-voiceover.wav"
with open(output_path, "wb") as out:
    for chunk in session.tts(request):   # Note: for chunk in ..., NOT with ... as response
        out.write(chunk)
```

- **Minimum sample:** 10–15 seconds (lowest threshold of any platform)
- **Processing:** < 30 seconds for instant mode; ~5 minutes for high-quality mode
- **Cross-lingual:** 80+ languages — preferred for CJK content

> [Claim 2: RS-20260508-002]

### ElevenLabs Cloning Workflow

| Mode | Requirement | Training Time | Use Case |
|------|------------|---------------|---------|
| IVC (Instant Voice Clone) | 30–60 seconds audio | None (instant) | Quick brand voice replication |
| PVC (Professional Voice Clone) | 30+ minutes audio | 3–6 hours | Maximum fidelity, stable long-form |

```python
# IVC — uses voice_id from ElevenLabs voice library after uploading
audio = client.text_to_speech.convert(
    text="Your script.",
    voice_id="your_cloned_voice_id",  # ID from IVC upload
    model_id="eleven_v3",
    output_format="pcm_44100",
)
```

### Recording Quality Rule

**SNR >30dB matters more than sample length** for clone quality.

- Record in a quiet room (noise floor < −60 dBFS)
- Use a cardioid microphone positioned 6–12 inches from the speaker
- A clean 10-second recording outperforms a noisy 60-second recording
- Avoid room reverb — it gets cloned along with the voice

### voice_id Lifecycle

```python
# Store voice_id in project config after creation
project_config = {
    "cloned_voice_id": "abc123",
    "cloned_voice_platform": "elevenlabs",
    "consent_confirmed": True,  # Log consent
    "created_at": "2026-05-08",
}

# Validate before first use in each session
try:
    client.voices.get(voice_id="abc123")
except NotFoundException:
    # Do NOT auto-re-create — requires new sample + consent
    raise RuntimeError("voice_id expired. Re-clone requires new sample and consent gate.")
```

**Rules:**
- Store `voice_id` in project config immediately after cloning
- Validate `voice_id` with a `GET /voices/{id}` call before first use
- On **404**: report to user and halt — do NOT auto-re-create (requires new sample + consent)
- Do NOT hardcode `voice_id` in code — store in project config or env

> [BA-P1-5: RS-20260508-002]

### Cross-Lingual Decision

| Scenario | Platform |
|---------|---------|
| CJK (Chinese/Japanese/Korean) voiceover | Fish Audio S2 Pro |
| Cross-lingual content (e.g., English clone → speak Mandarin) | Fish Audio |
| English-only, highest fidelity | ElevenLabs IVC/PVC |
| Simple multi-language, no cloning | OpenAI TTS (50+ languages) |

---

## AI Sound Effects Rules

> Source: RS-20260508-002 (65359194)

### ElevenLabs SFX API

```python
import httpx

response = httpx.post(
    "https://api.elevenlabs.io/v1/sound-generation",
    headers={"xi-api-key": os.getenv("ELEVENLABS_API_KEY")},
    json={
        "text": "A deep resonant braam suitable for a cinematic trailer",
        "model_id": "eleven_text_to_sound_v2",  # Required for loop support
        "duration_seconds": 8.0,   # Optional; omit for model-determined duration
        "prompt_influence": 0.3,   # 0.0 = more creative, 1.0 = literal
        # "loop": true,            # Uncomment for seamless ambient loops — requires eleven_text_to_sound_v2
    },
)
audio_bytes = response.content
with open("sfx/braam.mp3", "wb") as f:
    f.write(audio_bytes)
```

- **Endpoint:** `POST /v1/sound-generation`
- **Model:** `eleven_text_to_sound_v2`
- **Max duration:** 30 seconds
- **Looping:** Set `"loop": true` in request body — **only works with `model_id="eleven_text_to_sound_v2"`** (pin explicitly when using looping)
- **Cost:** 40 credits/second when `duration_seconds` specified
- **Output formats:** MP3 (default), WAV 48kHz (non-looping), PCM 44.1kHz (Pro tier)

> [Claim 3: RS-20260508-002]

### SFX Source Decision

| Sound type | Use | Why |
|-----------|-----|-----|
| Diegetic sounds (footsteps, ambient tied to scene motion) | Seedance native audio | Free, auto-synced to video, no extra API call |
| Specific/imaginative SFX ("cinematic braam", "sci-fi portal") | ElevenLabs SFX API | Seedance only generates what's in the scene |
| Looping ambient backgrounds | ElevenLabs SFX API | Seedance loops are tied to clip duration |
| SFX needed BEFORE video generation | ElevenLabs SFX API | Seedance requires video clip to exist first |

---

## Voice Pipeline Integration

> Source: RS-20260508-002 + RS-20260508-001 (supplemented)

### File Path Convention

```
# HyperFrames project
assets/generated-audio/
├── voiceover/                  # TTS output
│   ├── scene01-voiceover.wav
│   └── scene02-voiceover.wav
├── sfx/                        # AI-generated SFX
│   ├── whoosh-transition.mp3
│   └── ambient-rain-loop.mp3
└── cloned-voices/              # Voice clone reference samples
    └── brand-voice-sample.wav

# Remotion project — same structure but under public/
public/generated-audio/voiceover/
public/generated-audio/sfx/
public/generated-audio/cloned-voices/
```

> [Claim 5: RS-20260508-002]

### Audio Priority Order

When mixing, apply levels in this order:

1. **Voiceover/Dialogue** — 100% reference level (−6 to −3 dBFS)
2. **SFX** (Seedance native + standalone ElevenLabs) — duck under dialogue
3. **Background music** — 10–20% of voiceover level (−18 to −20 dBFS)

(Cross-ref: audio-design.md Volume Rules + FFmpeg ducking commands)

### Seedance Audio + TTS Collision Rule

When both Seedance native speech audio AND a TTS voiceover exist for the same scene:

**Strip the Seedance speech audio** — keep only Seedance SFX/ambient, replace dialogue with TTS voiceover.

```bash
# ⚠️ Simplest approach: re-generate the Seedance clip with audio disabled, then add TTS.
# This preserves all visual content while cleanly replacing audio.

# Recommended: re-generate clip → mix TTS + separate ambient SFX
ffmpeg -i seedance_clip_no_audio.mp4 -i tts_voiceover.wav \
  -c:v copy -c:a aac scene01_final.mp4

# Alternative (drops ALL Seedance audio incl. SFX): mute original, mix TTS only
# Use only when re-generation is not an option and Seedance SFX are not needed
ffmpeg -i seedance_clip.mp4 -i tts_voiceover.wav \
  -filter_complex "[0:a]volume=0[orig];[orig][1:a]amix=inputs=2" \
  -c:v copy scene01_final.mp4
```

> [BA-P1-3: RS-20260508-002] Collision rule: TTS voiceover takes priority when explicitly generated.

### Fish Audio Timestamps for Subtitle Sync

Fish Audio's streaming API returns word-level timestamps for subtitle generation:

```python
# Request timestamps via streaming API
# Timestamps align to actual TTS output (not script — TTS timing differs from script)
```

(Full implementation: Fish Audio "Streaming with Timestamps" API docs)

---

## Voice Cost Control

> Source: RS-20260508-002

### Platform Cost Comparison

| Platform | Model | Cost | Notes |
|---------|-------|------|-------|
| ElevenLabs | Subscription | $5+/month | Includes character credits; credit pricing varies by plan |
| ElevenLabs SFX | Per second | 40 credits/sec | Credit-to-dollar ratio depends on plan tier |
| OpenAI | tts-1 | $15/1M chars | ~180K English words per $15 |
| OpenAI | tts-1-hd | $30/1M chars | Higher quality, 2× price |
| Fish Audio | S1 / S2 Pro | $15/1M UTF-8 bytes | ~180K English words; CJK = 3 bytes/char → ~333K chars — verify at fish.audio/pricing |

> ⚠️ ElevenLabs credit pricing varies by subscription plan. Verify current rates at elevenlabs.io/pricing before estimating project cost.

> [Claim 1: RS-20260508-002] Pricing data from 2026-05-08 research.

### API Key Setup

```bash
export ELEVENLABS_API_KEY=sk-...
export FISH_API_KEY=...
# OpenAI TTS uses the same OPENAI_API_KEY as gpt-image-2
```

Use API keys for all batch work. ElevenLabs and Fish Audio do not have a "plan consumption" issue (unlike Codex), but batch operations without API keys may hit session limits on some tiers.
