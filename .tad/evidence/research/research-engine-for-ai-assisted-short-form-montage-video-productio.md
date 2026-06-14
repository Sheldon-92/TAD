# Research Engine — Technical Parameters for AI-Assisted Short-Form / Montage Video Production (2026)

> **Question:** For AI-assisted short-form / montage video production in 2026, what are the EXACT, source-verified technical parameters and decision rules a senior video engineer applies that a generalist would get wrong? (loudness, beat-sync cut timing, ffmpeg zoompan jitter, codec/CRF/bitrate + 9:16 safe zones, current tool capabilities)

---

## Summary

- **The "single -14 LUFS cross-platform standard" is a myth.** Platforms converge near -14 LUFS only superficially: Spotify -14 (bidirectional gain), YouTube -14 (attenuate-only, no official Help doc), Apple Music -16 (Sound Check), Apple Podcasts -16, Apple TV+ -24, EBU R128 broadcast -23. The *behavior* and *reference level* differ per platform, and TikTok / Instagram Reels have published **no** official LUFS target at all. [https://productionadvice.co.uk/td1008/]
- **Cut on the downbeat (and phrase boundaries), not every beat — and cut ~1–2 frames EARLY.** Quantitative music-video analysis (ISMIR 2021) found cuts are systematically placed *just before* the downbeat ("anticipation"); the 1–2 frame offset (≈42–83 ms @24fps, 33–66 ms @30fps) sits inside the ITU-R BT.1359-1 perceptual window. The specific "1–2 frame" rule is practitioner convention, not a primary psychoacoustic measurement. [https://arxiv.org/pdf/2108.00970] [https://www.itu.int/rec/R-REC-BT.1359-1-199811-I/en]
- **ffmpeg zoompan jitter is caused by per-frame integer rounding of the x/y pan expressions; the documented fix is prescaling the input (e.g. to 8000×4000) before zoompan, then scaling down.** It is a PARTIAL fix ("most of the jitter") — the upstream filter-internal patch was never merged into mainline, so the workaround remains necessary on ffmpeg 6.x/7.x/8.x. [https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/] [https://github.com/FFmpeg/FFmpeg/commits/master/libavfilter/vf_zoompan.c]
- **Upload masters: H.264 High profile + AAC, MP4, 1080×1920, CRF 18 (slow), faststart.** YouTube/Shorts publish exact specs; TikTok and Instagram audio specs are partial (Meta) or absent (TikTok video). AV1 is a *delivery* codec for all three platforms, NOT an accepted upload codec. [https://support.google.com/youtube/answer/1722171?hl=en] [https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media/]
- **9:16 safe zones (1080×1920): reserve right rail ~84–120px and bottom ~300–320px; a 900×1400 centered box is the universal safe union.** Bottom inset is state-dependent (collapsed vs expanded description) and the single biggest source of generalist error. [https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide]
- **For frame-accurate Ken Burns / beat-sync, use Remotion v4 or HyperFrames v0.6.97, NOT ffmpeg zoompan or CapCut auto-sync.** Remotion/HyperFrames give code-controlled frame-accurate output but have NO native beat detection — beat timestamps must be computed externally (librosa/madmom) and fed in. CapCut Beat Sync is a heuristic peak detector with a density slider. [https://github.com/remotion-dev/remotion/releases] [https://github.com/heygen-com/hyperframes/releases]

---

## Findings by sub-question

### (a) LOUDNESS — per-platform LUFS / true-peak / in-feed normalization

#### Per-platform loudness table

| Platform | Integrated target | True-peak ceiling | Normalizes in-feed? | Gain direction | Source |
|---|---|---|---|---|---|
| **YouTube** (video) | ~-14 LUFS | -1 dBTP | YES (empirical, not in official Help doc) | Attenuate-only | [stats-for-nerds](https://productionadvice.co.uk/stats-for-nerds/) |
| **Spotify** (music) | -14 LUFS | -1 dBTP (-2 if master >-14) | YES | **Bidirectional** (boost capped by headroom) | [Spotify Artists](https://support.spotify.com/us/artists/article/loudness-normalization/) |
| **Apple Music** (Sound Check) | -16 LUFS | -1 dBTP | YES (on by default iOS) | Bidirectional (peak-limited) — see refutation | [Production Expert](https://www.production-expert.com/production-expert-1/apple-choose-16lufs-loudness-level-for-apple-music-heres-why) |
| **Apple Podcasts** | -16 LKFS (±1) | -1 dBFS | (delivery spec) | n/a (preconditioning) | [Apple Podcasters](https://podcasters.apple.com/support/893-audio-requirements) |
| **Apple Music Atmos** | -18 LKFS (±1) | -1 dBTP | (delivery spec) | n/a | [Production Expert](https://www.production-expert.com/production-expert-1/apple-first-to-announce-immersive-loudness-guidance) |
| **Apple TV+** | -24 LUFS | -1 dBTP | (delivery spec) | n/a | [Tools for Film](https://www.toolsforfilm.com/blog/delivering-audio-netflix-amazon-apple) |
| **Instagram Reels** | **UNKNOWN** (no official #) | UNKNOWN | YES (xHE-AAC LRAC DRC, no # disclosed) | client-side metadata | [Engineering at Meta](https://engineering.fb.com/2023/04/11/video-engineering/high-quality-audio-xhe-aac-codec-meta/) |
| **TikTok** | **UNKNOWN** (no official #) | UNKNOWN | **DISPUTED** (see contradictions) | UNKNOWN | [Songbrain](https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok) |
| **EBU R128 broadcast** | -23 LUFS (±0.5) | -1 dBTP | n/a (delivery std) | n/a | [APU Software](https://apu.software/ebu-r128-loudness-target/) |
| **AES TD1008** (to platforms) | music -16 / speech -18 / mixed -17 | -1 dBTP | recommendation | n/a | [Production Advice](https://productionadvice.co.uk/td1008/) |

**YouTube normalization.** YouTube normalizes to ~-14 LUFS during playback and only attenuates content louder than target; quieter content plays at original level with no boost. Verifiable via "Stats for Nerds" → "Volume / Normalized: 100% / 54% (content loudness 5.3 dB)" where the dB value = gap to -14 LUFS reference. [https://productionadvice.co.uk/stats-for-nerds/] (verify: **confirmed**). The official encoding-specs page does NOT mention -14 LUFS, true peak, or normalization — it lists only codec/channel/bitrate. [https://support.google.com/youtube/answer/1722171] (verify: **confirmed**). Attenuate-only + -1 dBTP confirmed. [https://audio.rswaver.com/blog/youtube-loudness-standards] (verify: **confirmed** via this source rather than apu.software).

**Apple Music.** -16 LUFS Sound Check, AES TD1008-aligned, on by default on iOS, -1 dBTP. [https://www.production-expert.com/production-expert-1/apple-choose-16lufs-loudness-level-for-apple-music-heres-why] **CAUTION — the "attenuate-only" sub-claim was REFUTED** by adversarial verification: Sound Check applies *peak-limited upward gain* to quiet tracks ("turned up until they reach near 0 dBFS for peaks or -16 LUFS, whichever comes first") — bidirectional, not attenuate-only. [https://www.masteringbox.com/learn/mastering-for-streaming] Apple's submission ceiling for Digital Masters is a separate number: -18 LKFS (ITU-R BS.1770-4), -1 dBTP. [https://help.apple.com/itc/videoaudioassetguide/en.lproj/static.html]

**Apple Podcasts.** -16 dB LKFS integrated (±1, range -17 to -15), true peak ≤ -1 dBFS, per ITU-R BS.1770-5, uniform mono/stereo. [https://podcasters.apple.com/support/893-audio-requirements] (verify: **confirmed**). No publicly accessible primary Apple developer page states "-16 LUFS" as the Sound Check *playback* target — a documented sourcing gap; the figure is universally third-party reported. [https://podcasters.apple.com/support/893-audio-requirements] Sound Check switched to LUFS measurement in 2022 (third-party reporting only). [https://www.meterplugs.com/blog/2022/03/23/apple-switch-to-lufs.html]

**Instagram Reels.** Meta deployed xHE-AAC across Reels/Stories with integrated loudness management bringing "the average loudness of all sessions to the same target level" — but **published no LUFS number**. [https://www.socialmediatoday.com/news/meta-updates-audio-encoding-for-reels-and-stories-to-provide-more-volume-co/647414/] (verify: **confirmed**). The engineering blog confirms loudness management "delegates loudness management processing to the client via loudness metadata" using LRAC DRC two-pass, again with no numeric target. [https://engineering.fb.com/2023/04/11/video-engineering/high-quality-audio-xhe-aac-codec-meta/]

**TikTok.** No official LUFS target or documented normalization behavior exists; every online number is an educated guess. [https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok] [https://apu.software/tiktok-instagram-reels-loudness/] (verify: **confirmed** — Meta/social platforms never published targets).

#### Why a single -14 LUFS is a myth
Platforms differ in BOTH reference level AND behavior. Spotify uniquely applies positive AND negative gain (a -20 LUFS / -5 dBFS track is lifted only to -16, not -14, to preserve headroom). [https://support.spotify.com/us/artists/article/loudness-normalization/] EBU R128 broadcast = -23 LUFS, -1 dBTP — the normative origin of why streaming chose higher targets (older portable amps couldn't support -23/-24). [https://apu.software/ebu-r128-loudness-target/] AES TD1008 v3.13 (2021): music -16 / speech-podcast-ads -18 / mixed -17, max -1 dBTP — and explicitly addressed TO platforms, not creators. [https://productionadvice.co.uk/td1008/] Deezer -15; Spotify offers user-selectable Loud -11 / Normal -14 / Quiet -19. [https://www.mastrng.com/lufs/]

#### True-peak ceiling
-1 dBTP is the common ceiling, but a +0.3 dBTP file can exceed +1.0 dBTP AFTER AAC encoding, so -2 dBTP is safer for lossy chains (also Amazon Music's baseline). [https://matlefflerschulman.com/mastering-articles/true-peak-vs-inter-sample-peaks] Spotify's -2 dBTP rule applies specifically when a master exceeds -14 LUFS. [https://support.spotify.com/us/artists/article/loudness-normalization/]

---

### (b) BEAT-SYNC CUT TIMING — downbeat vs every-beat, anticipation offset

**Ruling: downbeats for major cuts; phrase boundaries (8/16 beats) for scene changes; every-beat only in short bursts at peak energy.** Cutting on every beat reads as frantic. Typical cadence: scene changes on downbeats (every 4 beats), angle/detail cuts on beats 2 & 4, every-beat bursts (4–8 beats) only at a drop. [https://beat2cut.com/blog/beat-sync-video-editing-complete-guide/] Larry Jordan's FCP X tutorial confirms aligning cuts to the dominant beat (downbeat), and notes perfect alignment isn't always necessary. [https://larryjordan.com/articles/fcpx-montage-to-music/]

**Anticipation offset (cut BEFORE the transient).** ISMIR 2021 study (TransNet shot detection + Madmom downbeat estimation) found cuts in Adele's "Rolling in the Deep" systematically placed JUST BEFORE the downbeat ("anticipation"); bar-level synchronization appeared in ~1/5 of clips studied. [https://arxiv.org/pdf/2108.00970] The practitioner heuristic is **1–2 frames early**:

| fps | 1 frame | 2 frames |
|---|---|---|
| 24 | 41.7 ms | 83.3 ms |
| 30 | 33.3 ms | 66.7 ms |
| 60 | 16.7 ms | 33.3 ms |

This sits inside ITU-R BT.1359-1 (1998) AV-sync tolerances: detectability ≈ +45 ms (audio leads) to -125 ms (audio lags); acceptability ≈ 90 ms lead to 185 ms lag. [https://www.itu.int/rec/R-REC-BT.1359-1-199811-I/en] [https://www.tvtechnology.com/opinions/av-synchronization-how-bad-is-bad] Perceptual basis: movement peaks lead the beat by up to 100 ms; AV temporal integration window 300–450 ms (PMC6711538, about physical movement, not edits specifically). [https://pmc.ncbi.nlm.nih.gov/articles/PMC6711538/] **FLAG: the "1–2 frame anticipation" rule has NO citable primary source in music-cognition or NLE docs — it is practitioner convention; the 10–30 ms figures are illustrative, not measured.** [https://beat2cut.com/blog/beat-sync-video-editing-complete-guide/] Walter Murch's *In the Blink of an Eye* gives no numeric offset; his Rule of Six ranks rhythm third (emotion 51%, story 23%, rhythm 10%). [https://www.premiumbeat.com/blog/cutting-on-the-blink-editing-tips-from-walter-murch/]

**Detection library outputs (beat vs downbeat):**
- **librosa.beat.beat_track** (v0.11.x): returns (tempo BPM, beats). Beats default to FRAME INDICES, not seconds; default hop_length 512 → 512/22050 ≈ 23.2 ms/frame; convert via `librosa.frames_to_time`. [https://librosa.org/doc/main/generated/librosa.beat.beat_track.html] Documented systematic LATE bias of 20–60 ms (onset-peak vs onset-beginning); madmom found more accurate. [https://github.com/librosa/librosa/issues/1052]
- **madmom DBNDownBeatTrackingProcessor** (v0.16.1): returns 2D array (num_beats, 2): col0 = beat time in SECONDS, col1 = beat number in bar (1 = DOWNBEAT). Accepts beats_per_bar. [https://madmom.readthedocs.io/en/v0.16.1/modules/features/downbeats.html]
- **aubio** (v0.4.9): default hop_size 512; `aubiotrack` outputs beat timestamps in SECONDS — directly timeline-usable, no frames_to_time step. [https://aubio.org/manual/latest/py_analysis.html]

**Frame-rounding error.** At 24fps (41.67 ms/frame), librosa's ~23 ms audio resolution gives ±20 ms snap error. 128 BPM @24fps = 11.25 frames/beat → rounds to 11 → effective 130.9 BPM (~3 BPM drift). 120 BPM @30fps = exactly 15 frames/beat (no error). Worst when beat period isn't an integer multiple of frame period. [https://bchillmix.com/pages/frame-rate-bpm]

---

### (c) KEN BURNS / ffmpeg zoompan JITTER — root cause + prescale fix

**Root cause.** "The filter is rounding the values from the x and y expressions, which may be either rounded up or down. That's creating an uneven motion due to changes in direction of pan." Per-frame integer rounding of x/y at output resolution. [https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/]

**Parameter semantics (ffmpeg 8.0 docs):** `z` = zoom factor expr (1–10, default 1); `x`/`y` = pan position of crop top-left (default 0); `d` = number of OUTPUT frames the effect lasts per INPUT image (default 90); `s` = output size (default hd720); `fps` = output fps (default 25). For VIDEO input use `d=1` (process each input frame independently). [https://ayosec.github.io/ffmpeg-filters-docs/8.0/Filters/Video/zoompan.html] On video, use `pzoom` (previous zoom) not `zoom` in the z expression so it doesn't reset each frame. [https://creatomate.com/blog/how-to-zoom-images-and-videos-using-ffmpeg] For image slideshows, `d = fps × seconds` (e.g. d=125 for 5s @25fps). [https://creatomate.com/blog/how-to-zoom-images-and-videos-using-ffmpeg]

**The prescale fix (copy-pasteable).** Upscale the input BEFORE zoompan so rounding errors become proportionally tiny, do the zoompan large, then scale DOWN to target.

BROKEN (jitters):
```
[0:v]scale=-2:480,zoompan=z='min(zoom+0.0015,1.5)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=125,trim=duration=5[v]
```
FIXED (prescale to 8000×4000):
```
[0:v]scale=8000x4000,zoompan=z='min(zoom+0.0015,1.5)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=125,trim=duration=5,scale=1080:1920[v]
```
[https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/] Bannerbear's documented pattern: `scale=1200:-2` → `crop=1200:670` → `scale=8000:-1` (prescale up) → zoompan → output `s=1200x670`; "without this you may find that your zoom effect is very jerky." [https://www.bannerbear.com/blog/how-to-do-a-ken-burns-style-effect-with-ffmpeg/] Cerberus pattern: `scale=-2:10*ih` before zoompan, `scale=-2:${imgheight}` after. [https://github.com/NapoleonWils0n/cerberus/blob/master/ffmpeg/zoompan.org] Alternative mitigation: wrap x/y in `trunc()` for consistent floor rounding. [https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/]

**On `flags=lanczos`:** Standard public-domain Ken Burns prescale uses plain `scale=8000:-1` / `scale=8*iw:-2` with NO explicit `flags=lanczos` — the scaler is left at ffmpeg's default (bicubic). [https://www.bannerbear.com/blog/how-to-do-a-ken-burns-style-effect-with-ffmpeg/] Quality ranking (no VMAF figures): lanczos best/slowest, spline very-good (recommended for upscaling), bicubic medium, bilinear fastest/previews. [https://wavespeed.ai/blog/posts/blog-how-to-upscale-enhance-video-quality-ffmpeg/] NETINT/SLC benchmarks (DOWNSCALING only): Cascade+Lanczos beats default bicubic by 11.24–12.89% bitrate efficiency. [https://streaminglearningcenter.com/ffmpeg/maximizing-quality-and-throughput-in-ffmpeg-scaling.html] **No Ken-Burns-specific lanczos-vs-bicubic prescale benchmark exists.** [https://forum.videohelp.com/threads/399323-Which-spline-resizer-is-ffmpeg-using] zscale alternative (FFmpeg 8.0.1): default is **bilinear** not lanczos — naive `zscale=w=iw*8:h=ih*8` is worse than `scale` bicubic; use `zscale=...:f=spline36` or `f=lanczos`. [https://ayosec.github.io/ffmpeg-filters-docs/8.0/Filters/Video/zscale.html]

**Fully or partially fixes?** PARTIAL — "gets rid of MOST of the jitter"; ffmpeg bug #4298 notes it "doesn't always have an effect with arbitrary x or y values." [https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/] The 2020 filter-internal patch (float intermediates + chroma-grid alignment, ffmpeg-devel/256883) was **NEVER merged** — patchwork status "New", and vf_zoompan.c git log shows the only 2020 commit (32d6fe23b660, June 25 2020) merely "add in_time variable," not a jitter fix. [https://patchwork.ffmpeg.org/project/ffmpeg/list/?q=zoompan&state=*] [https://github.com/FFmpeg/FFmpeg/commits/master/libavfilter/vf_zoompan.c] So prescale remains necessary on ffmpeg 6.x/7.x/8.x. [https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/] The `geq` filter can zoom-out (zoompan rejects z<1) but is 100–1000× slower; the practical jitter-free alternative is a real NLE / Remotion / HyperFrames. [https://hhsprings.bitbucket.io/docs/programming/examples/ffmpeg/manipulating_video_colors/use_of_geq_as_zoompan_alternative.html]

---

### (d) CODEC / CRF / BITRATE + 9:16 SAFE ZONES (2026)

#### Upload-spec table

| Platform | Container | Video codec | Resolution | fps | Video bitrate | Audio | AV1 upload? | Source |
|---|---|---|---|---|---|---|---|---|
| **YouTube / Shorts** | MP4 (faststart, no edit lists) | H.264 High, 2 B-frames, closed GOP, CABAC, 4:2:0 | 1080×1920 | 30/60 | 1080p 8 Mbps (≥8 min) | AAC-LC/Opus/Eclipsa; stereo 384k, mono 128k, 5.1 512k; 48 kHz | NO (delivery only) | [Google Support](https://support.google.com/youtube/answer/1722171?hl=en) |
| **Instagram Reels** | MOV/MP4 (no edit lists, moov front) | HEVC or H.264, progressive, closed GOP, 4:2:0 | 9:16 | 23–60 | (API file ≤300 MB) | AAC, ≤48 kHz, 1–2 ch, 128 kbps | NO (delivery only) | [Meta Graph API](https://developers.facebook.com/docs/instagram-platform/instagram-platform/instagram-graph-api/reference/ig-user/media/) |
| **TikTok** | MP4/MOV | H.264 (rec), H.265, VP8, VP9 | 1080×1920 | 30 (60 ok) | 8–15 Mbps VBR (third-party) | none in official API | NO (not listed) | [TikTok API](https://developers.tiktok.com/doc/content-posting-api-media-transfer-guide) |

YouTube standard-fps bitrate: 1080p 8 Mbps, 1440p 16 Mbps, 4K 35–45 Mbps; no AV1 as upload recommendation. [https://support.google.com/youtube/answer/1722171?hl=en] Shorts uses the identical spec; YouTube transcodes uploads to AV1 for playback but H.264 is the safe upload codec. [https://support.google.com/youtube/answer/1722171?hl=en]

Instagram exact audio text: "Audio codec: AAC, 48khz sample rate maximum, 1 or 2 channels... Audio bitrate: 128kbps"; container MOV/MP4 no edit lists; video HEVC or H264; frame rate 23–60 FPS; duration 3s–15min; file ≤300 MB. [https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media/] AV1 on Reels is server-side delivery generated from H.264 uploads, NOT an upload codec. [https://engineering.fb.com/2023/02/21/video-engineering/av1-codec-facebook-instagram-reels/] (Third-party creator data, LOW confidence: controlled 5–8 Mbps Reels exports can read 20–30% sharper than very-high-bitrate uploads; 3,500–5,000 kbps H.264 "sufficient" — not Meta-official. [https://www.stayabundant.com/blog/best-instagram-reels-export-settings])

TikTok: official Content Posting API lists H.264/H.265/VP8/VP9 with NO audio spec; the in-feed Ads spec page also has no audio codec/sample-rate/bitrate. [https://developers.tiktok.com/doc/content-posting-api-media-transfer-guide] [https://ads.tiktok.com/help/article/video-ads-specifications] Effect House (AR assets only, not video) specifies MP3 44.1 kHz. [https://effecthouse.tiktok.com/learn/guides/workspace/assets/asset-preparation/audio] Third-party TikTok specs (MEDIUM): MP4/MOV, H.264+AAC 44.1 kHz, 1080×1920, 8–15 Mbps VBR (≥5 Mbps floor), 30fps; file caps 72 MB Android / ~287 MB iOS / ~500 MB desktop. [https://stackinfluence.com/blog/tiktok-video-sizes-the-ultimate-guide] AV1 "not officially supported and may fail to upload" on TikTok; observed decode failure on Galaxy S23. [https://clippie.ai/blog/tiktok-export-settings-ai-video-quality-2026] [https://forum.lwks.com/threads/problem-uploading-mp4-files-to-tiktok.251060/]

#### CRF / x264 master settings
CRF 17–18 veryslow = visually lossless (upload master); CRF 18 slow = YouTube community recommendation; libx265 CRF 20–22 equivalent; SVT-AV1 CRF 20–25. Single-pass CRF is standard for quality work; two-pass NOT prescribed for H.264/H.265 masters (VP9 is the two-pass exception). [https://vibbit.ai/blog/ffmpeg-crf-examples] Canonical YouTube encode (mikoim gist):
```
ffmpeg -i input.mp4 -c:v libx264 -profile:v high -preset slow -crf 18 -g 30 -bf 2 \
  -pix_fmt yuv420p -c:a libfdk_aac -profile:a aac_low -b:a 384k -movflags faststart output.mp4
```
[https://gist.github.com/mikoim/27e4e0dc64e384adbcb91ff10a2d3678]

#### 9:16 safe zones (1080×1920 canvas)

| Platform | Top | Bottom | Left | Right | Safe area | Source |
|---|---|---|---|---|---|---|
| **TikTok** | 108px | 320px (370 ads) | 60px | 120px | 900×1492 | [PostPlanify](https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide) |
| **Instagram Reels** | 210px | 310px | 0px | 84px | 996×1400 | [PostPlanify](https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide) |
| **YouTube Shorts** | 120px | 300px (collapsed) / 360px ads | 0px | 96px | 984×1500 | [PostPlanify](https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide) |
| **Universal union** | — | — | — | — | **900×1400 centered** | [PostPlanify](https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide) |

Shorts bottom inset conflict: postlinkapp.com cites ~575px (fully expanded description + all buttons) vs postplanify/kreatli 300px (collapsed) — use 300px for organic, 360–400px for ads. [https://postlinkapp.com/blog/youtube-shorts-size-and-dimensions]

---

### (e) TOOL CAPABILITIES + VERSIONS (2026)

#### Remotion — v4.0.477 (June 13 2026)
[https://github.com/remotion-dev/remotion/releases] **Frame-accurate model:** `useCurrentFrame()` returns a 0-indexed integer; each composition has `durationInFrames` + `fps`; seconds = frame/fps; first frame 0, last `durationInFrames-1`; all animations driven by `useCurrentFrame()`. [https://www.remotion.dev/docs/the-fundamentals] `interpolate()` maps input→output with multi-point keyframes, per-segment easing, extrapolation (extend/clamp/wrap/identity) — animates CSS scale/translate/rotate for frame-precise Ken Burns. [https://www.remotion.dev/docs/interpolate] `spring()` physics primitive (stiffness/damping/mass, from/to, durationInFrames, delay, reverse since v3.3.92). [https://www.remotion.dev/docs/spring]

**Audio/beat:** `@remotion/media-utils` provides getAudioData/useAudioData/visualizeAudio/visualizeAudioWaveform/useWindowedAudioData/getWaveformPortion — frequency amplitudes per frame, **NO native beat detection.** [https://www.remotion.dev/docs/audio/visualization] `visualizeAudio()` returns 0–1 amplitude per band (bass left, treble right); Remotion does not compute beat positions. [https://www.remotion.dev/docs/visualize-audio] No official beat-detection integration is listed among third-party integrations (Lottie/GSAP/Skia/Rive/Three/etc.). [https://www.remotion.dev/docs/third-party]

**Beat-sync pattern (community, MEDIUM):** compute beats externally (librosa/madmom) → pass JSON float array in SECONDS via `--props='{"beats":[0.52,1.08,...]}'` or `--props=./beats.json` → read with `getInputProps()` → convert inside component `Math.round(beatSec * fps)` using `useVideoConfig().fps` → render `<Sequence from={beatFrame}>`. Convert inside the component to stay fps-agnostic. [https://github.com/orgs/remotion-dev/discussions/1526] No official Remotion beat-sync template exists. [https://www.remotion.dev/docs/audio/visualization] `getInputProps()` accepts JSON-serializable arrays but is non-typesafe (prefer calculateMetadata for production); `--props=./beats.json` supported. [https://www.remotion.dev/docs/get-input-props] v4.0 migration: FFmpeg bundled into @remotion/renderer, config moved to @remotion/cli/config, Node ≥16, MotionBlur→Trail. [https://www.remotion.dev/docs/4-0-migration]

#### HyperFrames (HeyGen) — v0.6.97 (June 13 2026), 212 releases
Open-source HTML-to-video framework (headless Chrome + FFmpeg), NOT a traditional NLE. [https://github.com/heygen-com/hyperframes/releases] Motion model: CSS @keyframes (WAAPI), GSAP timelines, Lottie, Three.js, Anime.js, custom adapters; GSAP is paused/seeked to frame/fps before each capture (solving GSAP's real-time wall-clock). [https://hyperframes.heygen.com/guides/hyperframes-vs-remotion] Two render modes: BeginFrame (Linux, byte-reproducible via Chrome compositor) and Screenshot (mac/Windows fallback, only BeginFrame fully deterministic). [https://hyperframes.heygen.com/guides/hyperframes-vs-remotion] v0.6.92+ per-property-group keyframes + split mutations; v0.6.91+ razor/blade tool; v0.6.97 batch rendering + WebGL determinism. [https://github.com/heygen-com/hyperframes/releases]

**Audio/beat:** NO native beat detection. Release notes v0.6.88–0.6.97 show no audio-reactive/beat-sync features. [https://github.com/heygen-com/hyperframes/releases] Audio-reactive requires externally pre-extracted frequency bands: "pre-extract audio bands (bass/mid/treble) and sample per-frame inside the timeline with a for loop of tl.call(draw,[],f/fps)"; a single long tween does NOT react. [https://github.com/NousResearch/hermes-agent/blob/main/optional-skills/creative/hyperframes/SKILL.md] Mapping: bass→scale, treble→glow, amplitude→opacity, mids→morph (mirrors Remotion's external-data pattern). [https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/creative/creative-hyperframes] Official docs have no audio-reactive/beat-sync section. [https://hyperframes.mintlify.app/llms.txt] The compose-agent lists "audio-reactive animation" as a baked-in skill but with no technical API/parameters (marketing-level). [https://hyperframes.mintlify.app/guides/mcp] Intensity guidance: text 3–6%, backgrounds 10–30%. [https://hyperframes.heygen.com/guides/prompting]

#### CapCut Beat Sync (Auto Beat)
Desktop: right-click audio → Beat Detection → blue markers; "Beats 1"/"Beats 2" density options; manual drag supported. [https://www.creativelysquared.com/article/how-to-add-beats-to-music-in-capcut-for-perfect-video-timing] Mobile: music track → Beats → Auto-Generate → Light-to-Intense intensity (yellow dots); Intense = denser/every-beat, Light = strong-beat. [https://www.creativelysquared.com/article/how-to-add-beats-to-music-in-capcut-for-perfect-video-timing] Auto Cut (the parent AI feature) is on Mobile + Desktop, NOT CapCut Web (web = trim/split only). [https://www.capcut.com/help/auto-cut-in-capcut] Algorithm scans for percussive peaks (FFT), does NOT exclusively detect downbeats; misses soft intros, live drums, swing, syncopation → manual fix. [https://cursa.app/en/page/beat-based-editing-in-capcut-syncing-cuts-transitions-and-motion-to-music] "Beats 1/2" are DENSITY controls (sparser vs denser peak surfacing), not a music-theory downbeat filter. [https://www.creativelysquared.com/article/how-to-add-beats-to-music-in-capcut-for-perfect-video-timing] Community-only (LOW): red dot=downbeat / orange=beat / yellow=off-beat — unconfirmed by official docs. [https://vediting.home.blog/2025/10/28/%F0%9F%8E%B6-how-to-sync-transitions-with-music-beats-in-capcut-beat-sync-tutorial/] Versions diverge per platform: iOS v18.1.0 (June 12 2026, iOS 16.4+) vs Android 14.6.0 / macOS 6.5.0 (July 2025, Wikipedia) — independent versioning, so "CapCut version" is meaningless without platform. [https://capcut.en.softonic.com/iphone]

#### Frame-accurate vs heuristic verdict

| Tool | Output | Verdict |
|---|---|---|
| **Remotion v4** | code-controlled, useCurrentFrame integer model | **Frame-accurate** (own primitives); beat data must be external |
| **HyperFrames v0.6.97** | code-controlled, Chrome BeginFrame byte-reproducible (Linux) | **Frame-accurate** (incl. GSAP via seek); beat data must be external |
| **CapCut Beat Sync** | GUI auto peak-detection + density slider | **Heuristic** (FFT peaks, needs manual correction) |

For zoompan jitter specifically, both Remotion (interpolate→CSS scale/translate per frame) and HyperFrames (seekable GSAP + frame-accurate capture) eliminate the integer-rounding jitter. [https://hyperframes.heygen.com/guides/hyperframes-vs-remotion]

---

## Contradictions / open debates

1. **TikTok in-feed normalization — four sources, four answers (UNRESOLVABLE).** Songbrain 2026 "no integrated LUFS normalization" (recommends -7 to -8 / -9 LUFS) [https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok]; APU -16 LUFS [https://apu.software/tiktok-instagram-reels-loudness/]; ClickyApps/genesismixlab -14 LUFS; Soundplate -9 to -12 LUFS [https://soundplate.com/streaming-loudness-lufs-table/]. Charting tracks average -8.4 LUFS (Soundplate/Teknup) [https://soundplate.com/streaming-loudness-lufs-table/]. A Fall-2025 UC-Denver thesis reportedly found platform processing (-33→-28 LUFS) but the PDF was unreadable binary — **UNVERIFIED**. [https://artsandmedia.ucdenver.edu/docs/librariesprovider27/alma-mater/waddell_thesis_fall2025.pdf] No controlled SPL/loudness A/B test of TikTok in-feed output exists in any audio publication. [https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok]
2. **Apple Music "attenuate-only" myth (REFUTED).** Sound Check is bidirectional (peak-limited upward gain to quiet tracks), contradicting the attenuate-only framing. [https://www.masteringbox.com/learn/mastering-for-streaming] Spotify is also bidirectional — only YouTube is documented attenuate-only. [https://support.spotify.com/us/artists/article/loudness-normalization/]
3. **True-peak ceiling has no single number:** -1 dBTP general, -2 dBTP for lossy / Amazon / Spotify-over-14, -1 dBTP EBU broadcast. [https://matlefflerschulman.com/mastering-articles/true-peak-vs-inter-sample-peaks]
4. **Every-beat vs downbeat — editorial dissent.** Steed Films: "stop cutting to the beat — that's lazy editing," citing Murch's emotion>story>rhythm hierarchy. [https://www.steedfilms.com/learn/stop-cutting-to-the-beat-thats-lazy-editing] Yet auto-tools (CapCut/OpusClip) default to marking ALL beats — tool default vs craft tension. [https://www.opus.pro/blog/best-ai-beat-sync]
5. **zoompan prescale partial vs complete; "fix was merged" is FALSE.** Tutorials claiming ffmpeg-devel/256883 fixed it are wrong — never merged. [https://patchwork.ffmpeg.org/project/ffmpeg/list/?q=zoompan&state=*]
6. **Remotion GSAP compatibility.** Remotion lists GSAP as supported [https://www.remotion.dev/docs/third-party]; HyperFrames (a competitor) says GSAP runs real-time during Remotion render and needs a seek workaround. HyperFrames' technical claim is more precise. [https://hyperframes.heygen.com/guides/hyperframes-vs-remotion]
7. **HyperFrames audio-reactive — marketing vs technical.** Marketing lists "beat sync"; the skill docs reveal it requires external pre-extracted band data (no native beat detection). [https://hyperframes.mintlify.app/guides/mcp] [https://github.com/NousResearch/hermes-agent/blob/main/optional-skills/creative/hyperframes/SKILL.md]
8. **Apple = four numbers, not one:** TV+ -24, Music stereo -16, Music Atmos -18, Podcasts -16. [https://www.rtw.com/en/blog/worldwide-loudness-delivery-standards.html]
9. **Instagram sample rate:** primary spec says only "48 kHz maximum"; reverse-engineering finds 44.1 & 48 preserved; creator guides split. Unresolvable without a controlled upload test. [https://audioutils.com/blog/best-audio-format-for-instagram]
10. **TikTok bitrate:** 8–15 Mbps (stackinfluence) vs 2.5 Mbps minimum (mediasizes) — acceptance floor vs quality recommendation; no primary TikTok bitrate doc. [https://stackinfluence.com/blog/tiktok-video-sizes-the-ultimate-guide]
11. **AES TD1008 misreading:** addressed TO platforms, not creators — widely misrepresented as a creator target. [https://productionadvice.co.uk/td1008/]

---

## Open questions / saturation reason

**Still unanswered:**
- TikTok in-feed loudness behavior + exact target — NO primary source, NO controlled measurement; four conflicting third-party numbers. (UNVERIFIED)
- Instagram Reels exact LUFS target — Meta confirms normalization exists (xHE-AAC/LRAC) but discloses no number. (UNVERIFIED)
- Apple Music Sound Check -16 LUFS *playback* target — no primary Apple developer URL; third-party-only. (sourcing gap)
- Whether 44.1 kHz is accepted by Instagram upload — primary spec says only "48 kHz maximum." (unresolvable without test)
- Optimal beat-cut anticipation in ms from a primary psychoacoustic study for editorial cuts specifically — the "1–2 frame" rule is practitioner convention only. (UNVERIFIED)
- lanczos-vs-bicubic quality delta on the zoompan prescale step — no Ken-Burns-specific benchmark. (UNVERIFIED)
- TikTok video audio codec/sample-rate from a first-party source — none exists (only AR-asset Effect House spec). (UNVERIFIED)

**Why we stopped:** `saturation_reason = max_rounds` (3 rounds; 72→98→129 cumulative findings; dry_counter stayed 0, i.e. each round still produced new findings — stopped on the round cap, not on saturation). Additional rounds would most likely deepen the TikTok/Instagram loudness and lanczos-benchmark gaps, all of which are blocked by absent primary sources rather than insufficient searching.

---

## Confidence note

**Overall confidence: MEDIUM-HIGH.** The technically hard, single-source-of-truth facts (YouTube/Apple Podcasts/Spotify loudness, ffmpeg zoompan mechanics + merge status, Remotion/HyperFrames version + frame model, 9:16 safe zones, library output formats) are HIGH — backed by official docs, git history, and reproducible methods. The platform-loudness questions for TikTok and Instagram Reels are LOW-confidence by nature of the domain: no platform publishes the numbers, so every figure is third-party estimate or UNVERIFIED.

**Refuted/caveated by adversarial verify (applied above):**
- **Apple Music "attenuate-only" — REFUTED.** Corrected to bidirectional peak-limited normalization. [https://www.masteringbox.com/learn/mastering-for-streaming]
- YouTube attenuate-only re-sourced to a confirming source. [https://audio.rswaver.com/blog/youtube-loudness-standards]
- "ffmpeg-devel patch fixed zoompan" — REFUTED (never merged). [https://patchwork.ffmpeg.org/project/ffmpeg/list/?q=zoompan&state=*]
- "1–2 frame anticipation" flagged UNVERIFIED practitioner convention.
- All TikTok/Reels LUFS numbers flagged UNVERIFIED.

**What would raise confidence:** (1) a controlled SPL/digital-loudness A/B measurement of TikTok and Reels in-feed output at varied input LUFS; (2) a primary Apple developer URL for the -16 LUFS Sound Check playback target; (3) a controlled Instagram upload test for 44.1 vs 48 kHz acceptance; (4) a VMAF/SSIM benchmark of lanczos vs bicubic on the zoompan prescale step; (5) a primary TikTok video upload spec page (currently nonexistent).

---

## Sources

1. https://productionadvice.co.uk/stats-for-nerds/
2. https://support.google.com/youtube/answer/1722171
3. https://support.google.com/youtube/answer/1722171?hl=en
4. https://audio.rswaver.com/blog/youtube-loudness-standards
5. https://apu.software/youtube-audio-loudness-target/
6. https://www.production-expert.com/production-expert-1/apple-choose-16lufs-loudness-level-for-apple-music-heres-why
7. https://www.masteringbox.com/learn/mastering-for-streaming
8. https://podcasters.apple.com/support/893-audio-requirements
9. https://help.apple.com/itc/videoaudioassetguide/en.lproj/static.html
10. https://www.production-expert.com/production-expert-1/apple-first-to-announce-immersive-loudness-guidance
11. https://www.toolsforfilm.com/blog/delivering-audio-netflix-amazon-apple
12. https://developer.apple.com/videos/play/wwdc2020/10158/
13. https://www.meterplugs.com/blog/2022/03/23/apple-switch-to-lufs.html
14. https://www.rtw.com/en/blog/worldwide-loudness-delivery-standards.html
15. https://www.socialmediatoday.com/news/meta-updates-audio-encoding-for-reels-and-stories-to-provide-more-volume-co/647414/
16. https://engineering.fb.com/2023/04/11/video-engineering/high-quality-audio-xhe-aac-codec-meta/
17. https://engineering.fb.com/2023/02/21/video-engineering/av1-codec-facebook-instagram-reels/
18. https://apu.software/tiktok-instagram-reels-loudness/
19. https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok
20. https://support.spotify.com/us/artists/article/loudness-normalization/
21. https://apu.software/ebu-r128-loudness-target/
22. https://productionadvice.co.uk/td1008/
23. https://www.mastrng.com/lufs/
24. https://matlefflerschulman.com/mastering-articles/true-peak-vs-inter-sample-peaks
25. https://soundplate.com/streaming-loudness-lufs-table/
26. https://artsandmedia.ucdenver.edu/docs/librariesprovider27/alma-mater/waddell_thesis_fall2025.pdf
27. https://beat2cut.com/blog/beat-sync-video-editing-complete-guide/
28. https://arxiv.org/pdf/2108.00970
29. https://www.tvtechnology.com/opinions/av-synchronization-how-bad-is-bad
30. https://www.itu.int/rec/R-REC-BT.1359-1-199811-I/en
31. https://pmc.ncbi.nlm.nih.gov/articles/PMC6711538/
32. https://www.premiumbeat.com/blog/cutting-on-the-blink-editing-tips-from-walter-murch/
33. https://librosa.org/doc/main/generated/librosa.beat.beat_track.html
34. https://github.com/librosa/librosa/issues/1052
35. https://madmom.readthedocs.io/en/v0.16.1/modules/features/downbeats.html
36. https://aubio.org/manual/latest/py_analysis.html
37. https://bchillmix.com/pages/frame-rate-bpm
38. https://larryjordan.com/articles/fcpx-montage-to-music/
39. https://www.steedfilms.com/learn/stop-cutting-to-the-beat-thats-lazy-editing
40. https://www.opus.pro/blog/best-ai-beat-sync
41. https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/
42. https://ayosec.github.io/ffmpeg-filters-docs/8.0/Filters/Video/zoompan.html
43. https://ayosec.github.io/ffmpeg-filters-docs/8.0/Filters/Video/zscale.html
44. https://creatomate.com/blog/how-to-zoom-images-and-videos-using-ffmpeg
45. https://github.com/NapoleonWils0n/cerberus/blob/master/ffmpeg/zoompan.org
46. https://www.bannerbear.com/blog/how-to-do-a-ken-burns-style-effect-with-ffmpeg/
47. https://ffmpeg.org/pipermail/ffmpeg-devel/2020-February/256883.html
48. https://patchwork.ffmpeg.org/project/ffmpeg/list/?q=zoompan&state=*
49. https://github.com/FFmpeg/FFmpeg/commits/master/libavfilter/vf_zoompan.c
50. https://hhsprings.bitbucket.io/docs/programming/examples/ffmpeg/manipulating_video_colors/use_of_geq_as_zoompan_alternative.html
51. https://wavespeed.ai/blog/posts/blog-how-to-upscale-enhance-video-quality-ffmpeg/
52. https://streaminglearningcenter.com/ffmpeg/maximizing-quality-and-throughput-in-ffmpeg-scaling.html
53. https://forum.videohelp.com/threads/399323-Which-spline-resizer-is-ffmpeg-using
54. https://academysoftwarefoundation.github.io/EncodingGuidelines/EncodeSwsScale.html
55. https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media/
56. https://developers.facebook.com/docs/instagram-platform/content-publishing/audio-api/
57. https://developers.tiktok.com/doc/content-posting-api-media-transfer-guide
58. https://ads.tiktok.com/help/article/video-ads-specifications
59. https://effecthouse.tiktok.com/learn/guides/workspace/assets/asset-preparation/audio
60. https://stackinfluence.com/blog/tiktok-video-sizes-the-ultimate-guide
61. https://clippie.ai/blog/tiktok-export-settings-ai-video-quality-2026
62. https://forum.lwks.com/threads/problem-uploading-mp4-files-to-tiktok.251060/
63. https://compresto.app/blog/video-compression-for-you-tube-tik-tok
64. https://vibbit.ai/blog/ffmpeg-crf-examples
65. https://gist.github.com/mikoim/27e4e0dc64e384adbcb91ff10a2d3678
66. https://www.stayabundant.com/blog/best-instagram-reels-export-settings
67. https://audioutils.com/blog/best-audio-format-for-instagram
68. https://support.google.com/displayvideo/answer/3129957
69. https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide
70. https://postlinkapp.com/blog/youtube-shorts-size-and-dimensions
71. https://github.com/remotion-dev/remotion/releases
72. https://www.remotion.dev/docs/the-fundamentals
73. https://www.remotion.dev/docs/interpolate
74. https://www.remotion.dev/docs/spring
75. https://www.remotion.dev/docs/audio/visualization
76. https://www.remotion.dev/docs/visualize-audio
77. https://www.remotion.dev/docs/third-party
78. https://www.remotion.dev/docs/4-0-migration
79. https://www.remotion.dev/docs/get-input-props
80. https://github.com/orgs/remotion-dev/discussions/1526
81. https://github.com/heygen-com/hyperframes/releases
82. https://hyperframes.heygen.com/guides/hyperframes-vs-remotion
83. https://hyperframes.heygen.com/guides/prompting
84. https://hyperframes.mintlify.app/llms.txt
85. https://hyperframes.mintlify.app/guides/mcp
86. https://github.com/NousResearch/hermes-agent/blob/main/optional-skills/creative/hyperframes/SKILL.md
87. https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/creative/creative-hyperframes
88. https://www.creativelysquared.com/article/how-to-add-beats-to-music-in-capcut-for-perfect-video-timing
89. https://www.capcut.com/help/auto-cut-in-capcut
90. https://cursa.app/en/page/beat-based-editing-in-capcut-syncing-cuts-transitions-and-motion-to-music
91. https://vediting.home.blog/2025/10/28/%F0%9F%8E%B6-how-to-sync-transitions-with-music-beats-in-capcut-beat-sync-tutorial/
92. https://capcut.en.softonic.com/iphone
