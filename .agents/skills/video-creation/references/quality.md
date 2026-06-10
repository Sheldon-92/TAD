# Quality & Export Reference

> Source: Research notebook a62f253b (27 sources), Layer 5 + Supplementary Research (gap Q3)

---

## Platform Export Specifications

### Platform Reference Table

| Platform | Aspect Ratio | Resolution | Max Duration | Format | Max Size |
|----------|-------------|------------|-------------|--------|---------|
| YouTube (standard) | 16:9 | 1920×1080 | Unlimited | MP4 (H.264) | 256GB |
| YouTube Shorts | 9:16 | 1080×1920 | ≤3 minutes | MP4 (H.264) | — |
| TikTok | 9:16 | 1080×1920 | 15s–60 minutes | MP4 / MOV | 2GB |
| Instagram Reels | 9:16 | 1080×1920 | ≤20 minutes | MP4 / MOV | 4GB |
| Instagram Feed | 4:5 | 1080×1350 | ≤60 seconds | MP4 | 4GB |
| Twitter/X (free) | 16:9 or 1:1 | 1920×1080 | ≤2:20 (140s) | MP4 | 512MB |
| LinkedIn | 16:9 | 1920×1080 | ≤10 minutes | MP4 | 5GB |
| Web (embed) | Variable | ≥1280×720 | Unlimited | MP4 (H.264) or WebM | — |

---

## Export Settings

### Codec & Quality

| Setting | Value | Notes |
|---------|-------|-------|
| Video codec | H.264 (MP4) | Universal compatibility |
| Alternative codec | VP9 (WebM) | Web-optimized, smaller file size |
| CRF range | 18–23 | 18 = visually lossless (large file); 23 = libx264 default (balanced) |
| Use CRF 23 for web; CRF 20 for premium; CRF 18 for archival/master only | | |
| Remotion default | CRF 18 | Remotion's H.264 default — larger files; fine for source export |
| Preset | `fast` or `medium` | `slow` gives marginal quality gain, not worth the time |
| Audio codec | AAC | Universal |
| Audio bitrate | 128kbps minimum | Higher for music-heavy content (192kbps) |

### Platform-Specific Encoding

**Twitter/X minimum bitrate**:
```bash
ffmpeg -i input.mp4 -b:v 5000k -minrate 5000k -maxrate 5000k -bufsize 10000k \
  -c:a aac -b:a 128k output_twitter.mp4
```

**Web optimization** (always add `-movflags +faststart`):
```bash
ffmpeg -i input.mp4 -crf 20 -preset fast -movflags +faststart \
  -c:a aac -b:a 128k output_web.mp4
```

**Mobile-first encoding** (for social platforms):
```bash
ffmpeg -i input.mp4 -vf "scale=1080:1920" -crf 22 -preset fast \
  -movflags +faststart -c:a aac -b:a 128k output_mobile.mp4
```

### Resolution Guidance
- **Primary production resolution**: 1920×1080 (16:9) or 1080×1920 (9:16)
- **Minimum acceptable**: 1280×720 for 16:9, 720×1280 for 9:16
- **High-end target**: 2560×1440 (1440p) for YouTube premium content
- **Rendering recommendation**: Render at 1440p, export downscaled to 1080p — better quality than rendering at 1080p

---

## Accessibility (WCAG)

### Caption Requirements

**Accuracy threshold**: ≥99%
- Auto-generated captions (Whisper, YouTube auto-captions): typically 85–95% accuracy
- **Human review is required** for any auto-generated captions before publication

**Captions ≠ Subtitles**:
| Type | Contains |
|------|---------|
| Subtitles | Speech only (translation) |
| Captions (accessibility) | Speech + speaker ID + sound effects + music cues |

**Required caption elements**:
- `[Speaker Name:]` — identify speaker when multiple speakers or off-screen voice
- `[sound effect]` — describe significant sound effects (e.g., `[door slams]`, `[notification chime]`)
- `[music: mood]` — describe music when relevant (e.g., `[upbeat electronic music]`, `[tense strings]`)

### Caption Format

| Format | Use Case | Notes |
|--------|---------|-------|
| WebVTT (.vtt) | Web delivery | CSS-styleable, supports positioning and cues |
| SRT (.srt) | Universal compatibility | Most platform import support |
| Burn-in | Social media | Encoded into video frame — required for platforms where users watch without sound |
| Soft captions | Web / YouTube | Toggle on/off — preferred for web delivery |

**Social media rule**: Use burn-in captions for TikTok, Instagram Reels, YouTube Shorts — most viewers watch without sound.

**Web rule**: Use soft captions (WebVTT) so users can toggle and customize display.

### Text Contrast Requirements (WCAG AA)

| Text Type | Minimum Contrast Ratio |
|-----------|----------------------|
| Standard text (< 24px normal, < 18px bold) | 4.5:1 |
| Large text (≥ 24px normal or ≥ 18px bold) | 3:1 |
| UI components and graphics | 3:1 |

**Testing approach**: Test text contrast at 3 representative frames:
1. Over the lightest background frame
2. Over the darkest background frame
3. Over a mid-tone frame

Do not test only on a static mockup — motion backgrounds change luminance over time.

**Caption contrast**: Caption text must meet 4.5:1 regardless of size. Use a semi-transparent background panel if direct contrast is insufficient.

### Motion Accessibility

**Flicker threshold**: Avoid content that flashes more than 3 times per second (WCAG 2.3.1 Three Flashes).
**Reduced motion**: If deploying to web (video player with `prefers-reduced-motion`), provide a static alternative or configure the player to respect the media query.

---

## Quality Checklist (Pre-Export)

### Video Quality
- [ ] CRF in range 18–23
- [ ] Resolution meets platform minimum
- [ ] No visible compression artifacts on fast motion
- [ ] `-movflags +faststart` included for web delivery
- [ ] Framerate consistent throughout (no variable framerate)

### Audio Quality
- [ ] Audio bitrate ≥ 128kbps AAC
- [ ] No clipping (peaks below -1dB)
- [ ] Voiceover normalized to -14 LUFS
- [ ] Background music at 10–20% relative to voiceover
- [ ] No echo or room noise in voiceover

### Accessibility
- [ ] Captions present and ≥99% accurate
- [ ] Caption format correct for platform (burn-in for social, soft for web)
- [ ] Required caption elements included (speaker ID, SFX, music cues where relevant)
- [ ] Text contrast ≥ 4.5:1 verified at 3 background luminance levels
- [ ] No content flashing > 3× per second

### Platform Compliance
- [ ] Aspect ratio matches target platform
- [ ] Duration within platform limit
- [ ] File size within platform limit
- [ ] Format (MP4/MOV/WebM) accepted by platform

---

## Render Time Expectations

| Output Type | Typical Render Time |
|------------|-------------------|
| 30s product demo (HyperFrames, 1080p) | 2–5 minutes |
| 60s explainer (HyperFrames, 1080p) | 5–10 minutes |
| 30s (Remotion, 1080p, no Lambda) | 3–8 minutes |
| 30s (Remotion Lambda, distributed) | 30–60 seconds |

Plan render time into your production pipeline. Do not start a render unless all validation steps (lint, validate, inspect) pass.

---

## Common Export Mistakes

### Forgetting `-movflags +faststart`
**Mistake**: Exporting an MP4 without the faststart flag.  
**Impact**: The MP4 moov atom (seeking metadata) is at the END of the file. Browsers must download the entire file before playback starts.  
**Fix**: Always add `-movflags +faststart` to web-delivery exports.

```bash
# Wrong
ffmpeg -i input.mp4 -crf 20 output.mp4

# Correct
ffmpeg -i input.mp4 -crf 20 -movflags +faststart output.mp4
```

---

### Using Variable Frame Rate (VFR)
**Mistake**: Rendering from a screen recording or browser capture without forcing CFR.  
**Impact**: Variable frame rate causes audio sync drift in encoded output. Twitter/X and some platforms reject VFR entirely.  
**Fix**: Always force constant frame rate in the final encode:

```bash
ffmpeg -i input.mp4 -r 30 -vsync cfr -crf 20 output_cfr.mp4
```

---

### Wrong Aspect Ratio Padding
**Mistake**: Converting 16:9 source to 9:16 by cropping center.  
**Impact**: Important content (faces, product) may be cropped out.  
**Fix**: Use letterboxing with blur background for social format conversion:

```bash
# Convert 16:9 to 9:16 with blur background
ffmpeg -i input_169.mp4 \
  -filter_complex "[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,
    pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black[fg];
    [0:v]scale=1080:1920,boxblur=20:2[bg];
    [bg][fg]overlay=(W-w)/2:(H-h)/2" \
  output_916.mp4
```

---

### Exporting at Wrong Color Space
**Mistake**: Rendering in RGB full-range (0-255) and not converting for broadcast/streaming.  
**Impact**: Colors clip on TVs and some streaming platforms.  
**Fix for broadcast-safe output**:
```bash
ffmpeg -i input.mp4 -vf "colorspace=bt709:iall=bt601-6-625:fast=1" \
  -color_primaries bt709 -color_trc bt709 -colorspace bt709 output.mp4
```
**Web-only delivery**: Full range (RGB) is acceptable; skip the colorspace conversion.

---

## Audio Quality Guidance

### Loudness Normalization
Normalize all audio to platform standards before export:

```bash
# Measure LUFS
ffmpeg -i input.mp3 -filter:a loudnorm=print_format=json -f null - 2>&1

# Normalize to -14 LUFS (streaming standard)
ffmpeg -i input.mp3 -filter:a loudnorm=I=-14:TP=-1.5:LRA=11 output_normalized.mp3
```

**Target LUFS by platform**:
| Platform | Target Integrated Loudness |
|----------|--------------------------|
| YouTube | -14 LUFS |
| Spotify (podcasts) | -14 LUFS |
| Apple Podcasts | -16 LUFS |
| Broadcast (EBU R128) | -23 LUFS |
| Social media (general) | -14 LUFS |

### Clipping Prevention
- Peak true peak: maximum -1 dBTP (leave 1 dB headroom)
- Check with: `ffmpeg -i input.mp3 -filter:a ebur128=peak=true -f null - 2>&1 | grep "Peak"`

---

## Accessibility Testing Procedures

### Caption Accuracy Test
1. Export video with burn-in captions OR soft caption file
2. Watch the video without reading the captions — focus only on audio
3. Then watch again reading ONLY the captions — not listening
4. Every spoken word must appear in captions exactly (proper nouns, technical terms)
5. Sound effects and music cues must be described when content-relevant

### Contrast Testing for Motion Backgrounds
```bash
# Extract 10 representative frames for contrast testing
ffmpeg -i input.mp4 -vf "fps=1/3" frame_%04d.png
```
Test each frame in a color contrast checker (WebAIM Contrast Checker or CLI tool).

### Flicker Test (WCAG 2.3.1)
Content must not flash more than 3 times per second.
```bash
# Check for potential flicker
ffmpeg -i input.mp4 -vf "blackdetect=d=0.05:pic_th=0.98:pix_th=0.10" -f null - 2>&1 | grep black_start
```
Rapid alternation between bright/dark frames visible in `blackdetect` output.

---

## Platform Upload Optimization

### YouTube
- Upload in highest quality available (4K or 1440p if rendered at that resolution) — YouTube re-encodes anyway
- Include `English (auto-generated)` caption track and correct it before publishing
- Add chapters in description for videos > 10 minutes (improves watch time)

### TikTok
- Use TikTok's native caption tool rather than burn-in — allows algorithmic sync and user edits
- If burn-in is used, ensure captions are in the TikTok safe zone (avoid bottom 20%)
- Export at 1080×1920 exactly — TikTok does not upscale, it crops

### Instagram Reels
- Max file size: 4GB; max duration: 20 minutes (Reels)
- First frame matters for thumbnail — ensure the first frame is visually strong
- Cover image: export a separate 1080×1920 JPEG at 00:01 (the strong hook frame)

### Twitter/X
- Hard limit (free tier): 512MB and 2:20 (140 seconds). X Premium tiers allow longer durations — verify at help.x.com before publishing premium content.
- Minimum bitrate 5000kbps — below this, Twitter's encoder degrades quality significantly
- Square (1:1) videos perform equally to 16:9 on Twitter mobile feed
