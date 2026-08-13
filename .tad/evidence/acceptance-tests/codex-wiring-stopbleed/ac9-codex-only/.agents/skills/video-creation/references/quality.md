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

> **Upload masters (verified):** the safe upload codec for all three short-form platforms is
> **H.264 High profile + AAC, MP4, faststart** — NOT AV1. YouTube/Shorts and Instagram Reels transcode
> your upload to AV1 for *delivery* server-side, but **AV1 is not an accepted UPLOAD codec** (TikTok
> AV1 uploads "may fail to upload"; observed decode failures). The canonical YouTube upload encode
> (mikoim gist): `-c:v libx264 -profile:v high -preset slow -crf 18 -g 30 -bf 2 -pix_fmt yuv420p
> -c:a aac -b:a 384k -movflags faststart`. Instagram primary spec: HEVC or H.264, AAC ≤48 kHz 1–2 ch
> 128 kbps. [Source: deep-research §(d) — support.google.com/youtube/answer/1722171, developers.facebook.com IG media reference, mikoim gist, engineering.fb.com AV1-Reels — retrieved 2026-06-14]

| Setting | Value | Notes |
|---------|-------|-------|
| Video codec (upload) | **H.264 High + AAC, MP4** | The safe upload codec for YouTube/TikTok/IG. AV1 = delivery only, NOT upload. |
| Alternative codec | VP9 (WebM) | Web-self-host only; not for platform upload |
| CRF — master | **18 (slow/veryslow)** | Visually lossless upload master (YouTube community + mikoim canonical); libx265 equiv ~20–22, SVT-AV1 ~20–25 |
| CRF — web cut | 23 | libx264 default (balanced); +6 CRF ≈ half the file size |
| Remotion CRF | per-codec (set explicitly) | Remotion has no single global CRF default; for H.264, 23 is a good baseline. Set `--crf` per the renderMedia knobs below |
| Preset | master = `slow`/`veryslow`; web = `fast`/`medium` | For a one-time upload master the slow preset is worth it; for iteration it is not |
| GOP / B-frames | `-g 30 -bf 2`, closed GOP, CABAC, 4:2:0 | YouTube-documented H.264 upload structure |
| Audio codec | AAC | Universal; YouTube stereo 384k / mono 128k, 48 kHz |
| Audio bitrate | 128kbps minimum | Higher for music-heavy content (192kbps+) |

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

### Remotion `renderMedia()` Tuning Knobs

> Source: remotion.dev/docs/renderer/render-media + /docs/encoding + npmjs.com/package/remotion, retrieved 2026-06-14 (Remotion v4.0.477). These knobs are NOT covered by the generic "CRF 18–23" rule above — they govern render speed and file size.

| Knob | Default | Tune to | Effect |
|------|---------|---------|--------|
| `--concurrency` | 1 browser tab (1 Lambda) | number of CPU threads | More tabs render frames in parallel — set to physical thread count for fastest local render. (v4.0 renamed the old `parallelism` flag to `concurrency`.) |
| `--jpeg-quality` | frame format = `jpeg` (lossy intermediate) | 0–100 | Default JPEG frames render faster; switch frame format to PNG only when you need transparency (PNG is slower) |
| `--crf` | **per-codec, no single global default** | H.264: 23 is a good baseline (range ~1–51) | **+6 CRF ≈ half the bitrate/filesize; −6 CRF ≈ double it** (exponential). CRF is codec-specific — a value good for H.264 is wrong for WebM. With hardware acceleration enabled you CANNOT set CRF. |

**CRF doubling rule:** moving CRF from 18→24 roughly halves output size; 24→18 roughly doubles it. Pair with the platform table above — e.g. start at CRF 18 master, step to 23 (≈⅓ the size) for a web cut. ⚠️ Remotion's CRF default is **per-codec, not a fixed 18** — set it explicitly; do not assume a global default.

### Resolution Guidance
- **Primary production resolution**: 1920×1080 (16:9) or 1080×1920 (9:16)
- **Minimum acceptable**: 1280×720 for 16:9, 720×1280 for 9:16
- **High-end target**: 2560×1440 (1440p) for YouTube premium content
- **Rendering recommendation**: Render at 1440p, export downscaled to 1080p — better quality than rendering at 1080p

---

### GIF Export (HyperFrames native, v0.6.97+)

> Source: heygen-com/hyperframes releases, retrieved 2026-06-13 (GIF export added 2026-06-11).

HyperFrames v0.6.97 ships **native animated-GIF export** using **two-pass palette encoding** (generate an optimal 256-color palette in pass 1, apply it in pass 2 — avoids the muddy default-palette dithering). It also accepts animated-GIF *input* via VP9 transcode.

When the deliverable is a short looping GIF (e.g. a docs hero, a Slack/Discord reaction, a README demo), prefer HyperFrames' two-pass GIF export over a hand-rolled FFmpeg one-pass `gif` filter. The equivalent manual FFmpeg two-pass (use only if not on HyperFrames):

```bash
# Pass 1 — generate palette
ffmpeg -i input.mp4 -vf "fps=15,scale=480:-1:flags=lanczos,palettegen" palette.png
# Pass 2 — encode using palette (much cleaner than single-pass)
ffmpeg -i input.mp4 -i palette.png \
  -lavfi "fps=15,scale=480:-1:flags=lanczos[x];[x][1:v]paletteuse" output.gif
```

GIFs have no audio and balloon in size — cap at ~15fps and ≤480px wide for shareable assets.

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
- [ ] No clipping (true peak ≤ -1 dBTP; use -2 dBTP for lossy/AAC delivery)
- [ ] Audio normalized to a pragmatic target (-16 LUFS short-form mixed; YouTube documents -14, TikTok/IG publish no number — see §Loudness Normalization, do NOT hard-target an unverified TikTok/IG LUFS)
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

> ⚠️ **There is NO single cross-platform LUFS number, and "-14 LUFS is the TikTok/IG/YouTube
> standard" is FALSE.** Platforms converge near -14 LUFS only superficially — reference level AND
> normalization behavior differ per platform, and **TikTok and Instagram Reels publish no official
> LUFS target at all** (every number you see online for them is a third-party estimate).
> The deep-research finding: the ONLY platform with a documented, verifiable target is **YouTube (-14
> LUFS, attenuate-only)**. Treat everything else as estimate/convention and target conservatively.

```bash
# Measure LUFS
ffmpeg -i input.mp3 -filter:a loudnorm=print_format=json -f null - 2>&1

# Pragmatic master for short-form (mixed speech+music): aim -16 LUFS / -1 dBTP.
# This sits between YouTube's documented -14 and the AES TD1008 mixed recommendation (-17),
# and stays safely under any platform that attenuates-only (you won't get pumped down hard).
ffmpeg -i input.mp3 -filter:a loudnorm=I=-16:TP=-1:LRA=11 output_normalized.mp3
```

**Per-platform loudness — what is DOCUMENTED vs. ESTIMATED:**

| Platform | Integrated target | True Peak | Status / behavior | Source |
|----------|-------------------|-----------|-------------------|--------|
| **YouTube** | **-14 LUFS** | -1 dBTP | **DOCUMENTED behavior** (empirical, verifiable in "Stats for Nerds"; NOT in official encoding-spec page). **Attenuate-only** — louder content turned down, quieter content NOT boosted. | [productionadvice](https://productionadvice.co.uk/stats-for-nerds/) , [rswaver](https://audio.rswaver.com/blog/youtube-loudness-standards) |
| **Spotify** (music) | -14 LUFS | -1 dBTP (-2 if master >-14) | DOCUMENTED. **Bidirectional** (boosts quiet tracks, capped by headroom — a -20 LUFS track lifts only to ~-16, not -14). User-selectable Loud -11 / Normal -14 / Quiet -19. | [Spotify Artists](https://support.spotify.com/us/artists/article/loudness-normalization/) |
| **TikTok** | **UNVERIFIED — no official number** | UNKNOWN | **In-feed normalization is DISPUTED.** Third-party estimates conflict wildly (-7 to -16 LUFS); no controlled measurement or first-party disclosure exists. Do NOT quote a TikTok LUFS as fact. | [songbrain](https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok) , [apu.software](https://apu.software/tiktok-instagram-reels-loudness/) |
| **Instagram Reels** | **UNVERIFIED — no official number** | UNKNOWN | Meta CONFIRMS it normalizes loudness (xHE-AAC + LRAC two-pass DRC, client-side metadata) but **publishes NO LUFS figure**. | [Meta Engineering](https://engineering.fb.com/2023/04/11/video-engineering/high-quality-audio-xhe-aac-codec-meta/) |
| **Apple Music** (Sound Check) | -16 LUFS (ESTIMATED) | -1 dBTP | Third-party reported only — **no primary Apple URL** states the -16 playback target. **Bidirectional** (peak-limited upward gain to quiet tracks — NOT attenuate-only). | [production-expert](https://www.production-expert.com/production-expert-1/apple-choose-16lufs-loudness-level-for-apple-music-heres-why) , [masteringbox](https://www.masteringbox.com/learn/mastering-for-streaming) |
| **Apple Podcasts** | -16 LKFS (±1) | -1 dBFS | DOCUMENTED delivery spec (ITU-R BS.1770-5). | [Apple Podcasters](https://podcasters.apple.com/support/893-audio-requirements) |
| **Amazon Music** | (estimate) | -2 dBTP | -2 dBTP ceiling is the safer general practice for lossy chains (a +0.3 dBTP file can exceed +1 dBTP after AAC encoding). | [matlefflerschulman](https://matlefflerschulman.com/mastering-articles/true-peak-vs-inter-sample-peaks) |
| **EBU R128 broadcast** | -23 LUFS (±0.5) | -1 dBTP | DOCUMENTED delivery standard (origin of why streaming chose higher targets). | [apu.software](https://apu.software/ebu-r128-loudness-target/) |
| **AES TD1008** (rec. TO platforms) | music -16 / speech -18 / mixed -17 | -1 dBTP | Recommendation addressed TO platforms, NOT a creator target (widely misquoted). | [productionadvice TD1008](https://productionadvice.co.uk/td1008/) |

**True-peak:** -1 dBTP is the common ceiling, but **-2 dBTP is safer for lossy (AAC) delivery** — a +0.3 dBTP file can exceed +1.0 dBTP after AAC encoding. [matlefflerschulman](https://matlefflerschulman.com/mastering-articles/true-peak-vs-inter-sample-peaks)

[Sources retrieved 2026-06-14, grounded in deep-research report `.tad/evidence/research/research-engine-for-ai-assisted-short-form-montage-video-productio.md` §(a) LOUDNESS]

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
