# Round 1 — for-ai-assisted-short-form-montage-video-productio

- Questions researched: 6
- New findings: 72 (cumulative 72)
- Dry counter: 0/2

## New findings
[
  {
    "claim": "YouTube normalizes integrated loudness to approximately -14 LUFS (LKFS) during playback and only attenuates content louder than that target — it does NOT apply upward gain to quieter content. This is verifiable via the 'Stats for Nerds' right-click panel which shows 'Volume / Normalized: 100% / 54% (content loudness 5.3 dB)' where the content loudness value indicates the gap between measured loudness and the -14 LUFS reference.",
    "source_url": "https://productionadvice.co.uk/stats-for-nerds/",
    "source_title": "Stats for Nerds — Production Advice",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — YouTube normalization",
    "confidence": "high"
  },
  {
    "claim": "YouTube's official recommended encoding specs page (support.google.com/youtube/answer/1722171) does NOT mention -14 LUFS, true peak ceilings, or loudness normalization at all — it only lists codec (AAC-LC, Opus, Eclipsa), channel config, and bitrate recommendations. The -14 LUFS figure is widely cited in the engineering community but is NOT explicitly stated in YouTube's public upload spec documentation.",
    "source_url": "https://support.google.com/youtube/answer/1722171",
    "source_title": "YouTube Recommended Upload Encoding Settings",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — YouTube normalization",
    "confidence": "high"
  },
  {
    "claim": "YouTube's loudness normalization is attenuation-only: content louder than ~-14 LUFS is turned down; content quieter is played at its original level with no boost. True peak ceiling is -1 dBTP. This makes mastering louder than -14 LUFS ineffective — it yields no perceived loudness advantage on YouTube.",
    "source_url": "https://apu.software/youtube-audio-loudness-target/",
    "source_title": "YouTube Audio Loudness Target — APU Software",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — YouTube normalization",
    "confidence": "medium"
  },
  {
    "claim": "Apple Music Sound Check normalizes playback to -16 LUFS integrated (following AES TD1008 recommendations, which differ from Spotify/YouTube/Tidal/Amazon at -14 LUFS). Sound Check is now ON by default on iOS. Apple's normalization is attenuation-only — tracks quieter than -16 LUFS are NOT boosted, they play at their original level. True peak ceiling is -1 dBTP.",
    "source_url": "https://www.production-expert.com/production-expert-1/apple-choose-16lufs-loudness-level-for-apple-music-heres-why",
    "source_title": "Why Apple Music Chose -16 LUFS — Production Expert",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — Apple Music vs Apple Podcasts",
    "confidence": "high"
  },
  {
    "claim": "Apple Podcasts official audio requirements specify: target integrated loudness -16 dB LKFS (±1 dB tolerance, range -17 to -15 LUFS), and true-peak must not exceed -1 dB FS. These apply uniformly — there is no separate spec for mono vs stereo in the official documentation. The spec follows ITU-R BS.1770-5.",
    "source_url": "https://podcasters.apple.com/support/893-audio-requirements",
    "source_title": "Apple Podcasters Audio Requirements",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — Apple Music vs Apple Podcasts",
    "confidence": "high"
  },
  {
    "claim": "Meta implemented xHE-AAC audio encoding across Instagram Reels and Stories to address inconsistent audio levels. The codec includes an integrated loudness management system that brings 'the average loudness of all sessions to the same target level.' Meta did NOT publish the specific LUFS target number in this announcement — they only stated 'the same target level' without specifying it.",
    "source_url": "https://www.socialmediatoday.com/news/meta-updates-audio-encoding-for-reels-and-stories-to-provide-more-volume-co/647414/",
    "source_title": "Meta Updates Audio Encoding for Reels and Stories — Social Media Today",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — Instagram Reels",
    "confidence": "high"
  },
  {
    "claim": "TikTok, Instagram, Facebook, X/Twitter, and Twitch have NEVER published official LUFS targets. The -14 LUFS or -16 LUFS figures cited for TikTok and Reels in audio engineering guides are industry estimates and educated approximations, not documented platform specifications. Any 'TikTok = -14 LUFS' claim in audio guides lacks a primary source.",
    "source_url": "https://apu.software/tiktok-instagram-reels-loudness/",
    "source_title": "TikTok and Instagram Reels Loudness — APU Software",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — TikTok normalization",
    "confidence": "high"
  },
  {
    "claim": "Sources on TikTok's normalization are directly contradictory: (1) songbrain.ai states 'There's no integrated LUFS normalization on TikTok in-feed playback' and recommends -7 to -8 LUFS; (2) apu.software states TikTok normalizes to -16 LUFS; (3) genesismixlab.com says testing suggests TikTok targets -14 LUFS. The contradiction is unresolved because TikTok has no official spec page. This is a verified CONTRADICTION in the source literature.",
    "source_url": "https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok",
    "source_title": "LUFS for Spotify, TikTok & Apple Music — Songbrain 2026",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — TikTok normalization",
    "confidence": "high"
  },
  {
    "claim": "Spotify normalizes to -14 LUFS (ITU 1770 standard) and uniquely applies BOTH upward and downward gain during playback. For quiet masters, positive gain is applied but capped: a -20 LUFS track with -5 dBFS true peak would only be lifted to -16 LUFS, not the full -14 LUFS target, to preserve headroom. True peak ceiling: below -1 dBTP; if master exceeds -14 LUFS, keep true peak below -2 dBTP to avoid distortion.",
    "source_url": "https://support.spotify.com/us/artists/article/loudness-normalization/",
    "source_title": "Loudness Normalization — Spotify for Artists",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — why single -14 LUFS is a myth",
    "confidence": "high"
  },
  {
    "claim": "EBU R128 broadcast standard mandates -23 LUFS integrated (±0.5 LU) and -1 dBTP true peak maximum, mandatory for broadcast in most European countries. This is the normative basis for why streaming platforms chose HIGHER (less negative) loudness targets: older portable devices lacked amplifier gain to support -23/-24 LUFS reference levels. The ITU-R BS.1770 algorithm (K-weighting + gating) is the shared measurement standard across EBU R128 and streaming targets.",
    "source_url": "https://apu.software/ebu-r128-loudness-target/",
    "source_title": "EBU R128 Loudness Target — APU Software",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — why single -14 LUFS is a myth",
    "confidence": "high"
  },
  {
    "claim": "AES TD1008 v3.13 (2021) streaming loudness recommendations by content type: music = -16 LUFS, speech/podcasts/ads = -18 LUFS, mixed/radio = -17 LUFS. Maximum true peak: -1 dBTP at codec input. These are recommendations for online radio/streaming services, not production targets for individual artists. AES notes speech normalized to same BS.1770 level as music sounds 2-3 dB louder, justifying separate targets.",
    "source_url": "https://productionadvice.co.uk/td1008/",
    "source_title": "AES TD1008 Streaming Loudness Recommendations — Production Advice",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — why single -14 LUFS is a myth",
    "confidence": "high"
  },
  {
    "claim": "The 'single -14 LUFS universal target' is a myth because platforms differ materially: Spotify -14 LUFS (both attenuation and boost), YouTube -14 LUFS (attenuation only), Apple Music -16 LUFS (Sound Check, attenuation only), Deezer -15 LUFS. Additionally, Spotify offers user-selectable levels: Loud (-11 LUFS), Normal (-14 LUFS), Quiet (-19 LUFS). Amazon and Pandora differ from Spotify on album vs track normalization.",
    "source_url": "https://www.mastrng.com/lufs/",
    "source_title": "LUFS Mastering Guide — Mastrng",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — why single -14 LUFS is a myth",
    "confidence": "high"
  },
  {
    "claim": "True peak ceiling for lossy codec content: a file at +0.3 dBTP before encoding can exceed +1.0 dBTP AFTER AAC conversion. This means the -1 dBTP ceiling used by most streaming platforms can still result in post-codec clipping. For content going through lossy encoding chains, -2 dBTP is the safer ceiling (also Amazon Music's published requirement). The -1 dBTP vs -2 dBTP distinction matters more for highly compressed masters going through AAC/MP3.",
    "source_url": "https://matlefflerschulman.com/mastering-articles/true-peak-vs-inter-sample-peaks",
    "source_title": "True Peak vs Inter-Sample Peaks — Matleffler Schulman",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — true peak ceiling",
    "confidence": "high"
  },
  {
    "claim": "Spotify's -2 dBTP recommendation applies specifically to masters louder than -14 LUFS: 'if your master exceeds -14 dB LUFS, maintain True Peak below -2 dB.' This is documented in Spotify's official artist support page and is a specific edge-case rule, not the universal baseline.",
    "source_url": "https://support.spotify.com/us/artists/article/loudness-normalization/",
    "source_title": "Loudness Normalization — Spotify for Artists",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — true peak ceiling",
    "confidence": "high"
  },
  {
    "claim": "Professional montage editors favor downbeats (beat 1 of the bar) for major cuts, not every beat. Industry guidance: cutting on every beat reads as frantic. Typical cadence structures: major scene changes on downbeats (every 4 beats), angle/detail cuts on beats 2 and 4, short every-beat bursts (4-8 beats) only at peak energy moments like a drop. Musical phrase boundaries (8 or 16 beats) are the preferred transition points for major scene changes.",
    "source_url": "https://beat2cut.com/blog/beat-sync-video-editing-complete-guide/",
    "source_title": "Beat Sync Video Editing Complete Guide — Beat2Cut",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — downbeat vs every beat",
    "confidence": "medium"
  },
  {
    "claim": "A quantitative academic study of official music video clips (ISMIR 2021, arxiv 2108.00970) found that cuts in Adele's 'Rolling in the Deep' are systematically placed JUST BEFORE the downbeat — what the authors call 'anticipation.' The study used TransNet for shot detection and Madmom for downbeat estimation to quantify this pattern across music videos. Synchronization at the bar level (cuts at downbeats) was found for roughly one fifth (1/5) of the clips studied.",
    "source_url": "https://arxiv.org/pdf/2108.00970",
    "source_title": "Music Video Beat Synchronization Study — ISMIR 2021 (arXiv 2108.00970)",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — anticipation offset",
    "confidence": "high"
  },
  {
    "claim": "The perceptual anticipation offset for cut-before-beat is empirically cited as 1-2 frames in practitioner guides, with the rationale that 'visual processing takes time' and cutting 1-2 frames early causes the new shot to feel 'on the beat' when the audio transient arrives. This is presented as a practitioner heuristic rather than a rigorously measured perceptual latency value. No specific millisecond figure from a psychoacoustics study was found for this exact editing context.",
    "source_url": "https://beat2cut.com/blog/beat-sync-video-editing-complete-guide/",
    "source_title": "Beat Sync Video Editing Complete Guide — Beat2Cut",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — anticipation offset",
    "confidence": "medium"
  },
  {
    "claim": "ITU-R BT.1359-1 (1998) defines audiovisual synchronization tolerances: detectability threshold — audio leading video by up to +45ms or lagging by up to -125ms is at the detection edge; acceptability threshold — audio may lead video by up to 90ms or lag by up to 185ms and remain acceptable on average. This standard grounds the claim that a few-frame (40-83ms at 24fps) cut anticipation falls within perceptual acceptability.",
    "source_url": "https://www.tvtechnology.com/opinions/av-synchronization-how-bad-is-bad",
    "source_title": "AV Synchronization: How Bad Is Bad — TV Technology",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — anticipation offset",
    "confidence": "high"
  },
  {
    "claim": "librosa.beat.beat_track (v0.11.x) returns a tuple of (tempo in BPM, beats array). Default units for beats are FRAME INDICES (not seconds). The default hop_length is 512 samples. At 22050 Hz sample rate, temporal resolution is 512/22050 ≈ 23.2ms per frame. Conversion to seconds requires librosa.frames_to_time(beats, sr=sr) using the formula times[i] = frames[i] * hop_length / sr.",
    "source_url": "https://librosa.org/doc/main/generated/librosa.beat.beat_track.html",
    "source_title": "librosa.beat.beat_track — librosa docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — librosa output format",
    "confidence": "high"
  },
  {
    "claim": "librosa beat_track has a documented systematic timing bias: beats are detected 0.02-0.06 seconds (20-60ms) LATER than the actual beat position across multiple test songs. This bias persisted across different sample rates (22050 and 44100 Hz). The root cause hypothesis: librosa detects onset strength peaks rather than onset beginnings, and beats typically occur at onset beginnings not peaks. GitHub issue #1052 reports this; madmom's beat positions were found more perceptually accurate.",
    "source_url": "https://github.com/librosa/librosa/issues/1052",
    "source_title": "librosa beat_track timing bias — GitHub Issue #1052",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — librosa output format",
    "confidence": "high"
  },
  {
    "claim": "madmom DBNDownBeatTrackingProcessor (v0.16.1) returns a 2D numpy array of shape (num_beats, 2): column 0 = beat position in SECONDS, column 1 = beat number within the bar (starting at 1). Example output: [[0.09, 1.], [0.45, 2.], [2.14, 3.], [2.49, 4.]]. Column 2=1 marks DOWNBEATS (beat 1 of bar). The processor accepts beats_per_bar parameter (e.g., [3,4] for mixed meter).",
    "source_url": "https://madmom.readthedocs.io/en/v0.16.1/modules/features/downbeats.html",
    "source_title": "madmom DBNDownBeatTrackingProcessor — madmom docs v0.16.1",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — madmom output format",
    "confidence": "high"
  },
  {
    "claim": "Frame rounding error when snapping beat timestamps to video frames: at 24fps (41.67ms/frame), librosa's ~23ms audio frame resolution creates a quantization error of up to ±20ms when snapping to video frames. At 128 BPM with 24fps, frames per beat = 11.25, which rounds to 11 frames → effective tempo 130.9 BPM, creating ~3 BPM drift. At 30fps (33.33ms/frame), 120 BPM gives exactly 15 frames/beat (no rounding error). The rounding error is worst when beat period is not an integer multiple of the video frame period.",
    "source_url": "https://bchillmix.com/pages/frame-rate-bpm",
    "source_title": "Frame Rate vs BPM — BChillMix",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — frame rounding error",
    "confidence": "high"
  },
  {
    "claim": "aubio's tempo detection class (v0.4.9) uses default hop_size=512. The aubiotrack command-line tool outputs TIMESTAMPS of detected beats (in seconds), not frame indices. Unlike librosa, aubio's primary interface is beat/onset timestamps in seconds, making it more directly usable for video timeline synchronization without a separate frames_to_time conversion step.",
    "source_url": "https://aubio.org/manual/latest/py_analysis.html",
    "source_title": "aubio Python Analysis — aubio manual",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — aubio output format",
    "confidence": "medium"
  },
  {
    "claim": "Larry Jordan's professional FCP X montage-to-music tutorial confirms: use downbeats (the 'dominant beat') as primary alignment points for cuts, not every beat. He marks downbeats explicitly and positions clip end-points to align with those markers. He also notes that 'perfect beat alignment isn't always necessary' — sometimes misaligned shots create better flow.",
    "source_url": "https://larryjordan.com/articles/fcpx-montage-to-music/",
    "source_title": "Montage to Music in FCP X — Larry Jordan",
    "retrieved_at": "2026-06-14",
    "sub_question": "(b) BEAT-SYNC CUT TIMING — downbeat vs every beat",
    "confidence": "medium"
  },
  {
    "claim": "The -14 LUFS cross-platform mastering myth persists because Spotify, YouTube, and Tidal all converge at -14 LUFS integrated, but the normalization BEHAVIOR differs: YouTube only attenuates, Spotify applies both positive and negative gain (with headroom cap), Apple Music only attenuates to -16 LUFS, and social platforms (TikTok/Reels) have no officially published targets. A single -14 LUFS master is suboptimal for Apple platforms and unknown-effect for TikTok/Reels.",
    "source_url": "https://productionadvice.co.uk/td1008/",
    "source_title": "AES TD1008 Streaming Loudness Recommendations — Production Advice",
    "retrieved_at": "2026-06-14",
    "sub_question": "(a) LOUDNESS — why single -14 LUFS is a myth",
    "confidence": "high"
  },
  {
    "claim": "ffmpeg zoompan jitter root cause: the filter rounds the float values from the x and y expressions, which may be either rounded up or down on each frame, producing an uneven motion due to changes in direction of pan. Quote: 'the filter is rounding the values from the x and y expressions, which may be either rounded up or down. That's creating an uneven motion due to changes in direction of pan.'",
    "source_url": "https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/",
    "source_title": "FFmpeg: Smooth Zoompan With No Jiggle — DataRecoveryUnion",
    "retrieved_at": "2026-06-14",
    "sub_question": "(c) ffmpeg zoompan jitter",
    "confidence": "high"
  },
  {
    "claim": "ffmpeg zoompan prescale fix (canonical form): upscale the input to 8000x4000 BEFORE zoompan so that rounding errors are proportionally smaller. BROKEN filtergraph: '[0:v]scale=-2:480,zoompan=z=\\'min(zoom+0.0015,1.5)\\':x=\\'iw/2-(iw/zoom/2)\\':y=\\'ih/2-(ih/zoom/2)\\':d=125,trim=duration=5[v]'. FIXED filtergraph: '[0:v]scale=8000x4000,zoompan=z=\\'min(zoom+0.0015,1.5)\\':x=\\'iw/2-(iw/zoom/2)\\':y=\\'ih/2-(ih/zoom/2)\\':d=125,trim=duration=5[v]'. A downstream scale filter must be added to bring the output back to target resolution.",
    "source_url": "https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/",
    "source_title": "FFmpeg: Smooth Zoompan With No Jiggle — DataRecoveryUnion",
    "retrieved_at": "2026-06-14",
    "sub_question": "(c) ffmpeg zoompan jitter",
    "confidence": "high"
  },
  {
    "claim": "Alternative to prescale: apply trunc() to x and y expressions to stabilize rounding direction. DataRecoveryUnion lists this as a second valid mitigation. The principle is that trunc() forces consistent floor rounding instead of letting the filter round arbitrarily up or down.",
    "source_url": "https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/",
    "source_title": "FFmpeg: Smooth Zoompan With No Jiggle — DataRecoveryUnion",
    "retrieved_at": "2026-06-14",
    "sub_question": "(c) ffmpeg zoompan jitter",
    "confidence": "medium"
  },
  {
    "claim": "ffmpeg zoompan parameter semantics (ffmpeg 8.0.1 official filter docs): z = zoom factor expression, range 1-10, default 1. x/y = pan position expressions (top-left corner of crop window), default 0. d = duration in number of OUTPUT FRAMES the effect lasts for a single INPUT image, default 90. s = output size, default 'hd720'. fps = output frame rate, default 25. For video input, use d=1 to apply zoompan to each input frame individually rather than stretching one frame across 90 output frames.",
    "source_url": "https://ayosec.github.io/ffmpeg-filters-docs/8.0/Filters/Video/zoompan.html",
    "source_title": "ffmpeg 8.0 zoompan filter docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(c) ffmpeg zoompan jitter",
    "confidence": "high"
  },
  {
    "claim": "For video input with zoompan, replace the 'zoom' variable with 'pzoom' (previous zoom) in z expressions and set d=1 so each input frame is processed independently without stretching. Using zoom (not pzoom) with d=1 on video causes the expression to reset to initial state each frame.",
    "source_url": "https://creatomate.com/blog/how-to-zoom-images-and-videos-using-ffmpeg",
    "source_title": "How to Zoom Images and Videos Using ffmpeg — Creatomate",
    "retrieved_at": "2026-06-14",
    "sub_question": "(c) ffmpeg zoompan jitter",
    "confidence": "medium"
  },
  {
    "claim": "Canonical Ken Burns prescale filtergraph pattern from NapoleonWilson/cerberus: uses scale=-2:10*ih (scale to 10x input height) BEFORE zoompan, then scale=-2:${imgheight} AFTER to normalize output. Pattern: [prescale UP] → [zoompan at large size] → [scale DOWN to output]. No resampling flag (e.g. :flags=lanczos) is explicitly specified in this source, but Lanczos is the quality flag typically added to the scale filters in production use.",
    "source_url": "https://github.com/NapoleonWils0n/cerberus/blob/master/ffmpeg/zoompan.org",
    "source_title": "zoompan.org — NapoleonWilson/cerberus (GitHub)",
    "retrieved_at": "2026-06-14",
    "sub_question": "(c) ffmpeg zoompan jitter",
    "confidence": "high"
  },
  {
    "claim": "Bannerbear documents a three-step prescale pipeline for Ken Burns with ffmpeg: (1) scale=1200:-2 to target output width, (2) crop=1200:670 to target frame, (3) scale=8000:-1 (upscale to 8000px wide), then zoompan, then output at s=1200x670. Quote: 'scale=8000:-1 this is optional but without this you may find that your zoom effect is very jerky, this helps to smooth it out.' No resampling flag mentioned.",
    "source_url": "https://www.bannerbear.com/blog/how-to-do-a-ken-burns-style-effect-with-ffmpeg/",
    "source_title": "Ken Burns Effect with ffmpeg — Bannerbear",
    "retrieved_at": "2026-06-14",
    "sub_question": "(c) ffmpeg zoompan jitter",
    "confidence": "high"
  },
  {
    "claim": "ffmpeg 2020 patch (ffmpeg-devel list) fixed a related zoompan shaking bug via: (1) a scale_to_grid() function aligning crop dimensions to chroma subsampling grid, (2) floating-point intermediate calculations (double dw, dh, dx_scaled, dy_scaled) before converting to integers, (3) two-stage overscaled_frame + av_frame_apply_cropping() instead of direct integer arithmetic, (4) pixel coordinate masking with chroma alignment bits. This is a filter-internal fix committed to ffmpeg source — distinct from the prescale workaround.",
    "source_url": "https://ffmpeg.org/pipermail/ffmpeg-devel/2020-February/256883.html",
    "source_title": "ffmpeg-devel: zoompan shaking fix — ffmpeg mailing list (Feb 2020)",
    "retrieved_at": "2026-06-14",
    "sub_question": "(c) ffmpeg zoompan jitter",
    "confidence": "high"
  },
  {
    "claim": "zoompan d parameter semantics for still vs video input: with a STILL IMAGE input, d=1 means the effect lasts exactly 1 output frame — no animation. For Ken Burns slideshows, d is typically set to (fps * duration_in_seconds), e.g., d=25*5 for 5 seconds at 25fps. With VIDEO input, d=1 applies zoompan independently to each input frame — the correct mode for video. Otherwise d=90 (default) stretches one input frame to 90 output frames.",
    "source_url": "https://creatomate.com/blog/how-to-zoom-images-and-videos-using-ffmpeg",
    "source_title": "How to Zoom Images and Videos Using ffmpeg — Creatomate",
    "retrieved_at": "2026-06-14",
    "sub_question": "(c) ffmpeg zoompan jitter",
    "confidence": "high"
  },
  {
    "claim": "YouTube recommended upload encoding (official Google support page, current 2026): container MP4 with moov atom at front (Fast Start), no edit lists. Video codec H.264 High Profile, progressive scan, 2 consecutive B-frames, closed GOP, CABAC, 4:2:0 chroma. Audio: AAC-LC or Opus or Eclipsa Audio; stereo 384 kbps, mono 128 kbps, 5.1 = 512 kbps; 48 kHz sample rate. Video bitrate at standard (24-30fps): 1080p = 8 Mbps, 1440p = 16 Mbps, 4K = 35-45 Mbps. No AV1 mentioned as upload recommendation.",
    "source_url": "https://support.google.com/youtube/answer/1722171?hl=en",
    "source_title": "YouTube Recommended Upload Encoding Settings — Google Support",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) CODEC / CRF / BITRATE",
    "confidence": "high"
  },
  {
    "claim": "YouTube Shorts uses identical encoding spec to main YouTube (same help article). Recommended resolution 1080x1920 (9:16), H.264 + AAC, MP4, 30fps or 60fps, minimum 8 Mbps bitrate for 1080p. YouTube converts all uploaded content to AV1 for playback on its end, but AV1 is not a recommended upload codec — H.264 remains the safe upload choice.",
    "source_url": "https://support.google.com/youtube/answer/1722171?hl=en",
    "source_title": "YouTube Recommended Upload Encoding Settings — Google Support",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) CODEC / CRF / BITRATE",
    "confidence": "high"
  },
  {
    "claim": "TikTok video upload specs (2026, third-party sources — no official TikTok spec page found): container MP4 or MOV, video codec H.264 + AAC audio at 44.1 kHz. Recommended resolution 1080x1920 (9:16). Recommended bitrate 8-15 Mbps VBR; below 5 Mbps triggers quality downgrade flag; above 20 Mbps is flattened anyway. Frame rate: 30fps constant recommended, 60fps supported. File size limits: 72 MB Android, ~287 MB iOS, ~500 MB desktop. AV1 not mentioned as accepted upload codec. NOTE: these figures are from third-party creator guides, not TikTok's own documentation.",
    "source_url": "https://stackinfluence.com/blog/tiktok-video-sizes-the-ultimate-guide",
    "source_title": "TikTok Video Sizes Ultimate Guide — Stack Influence",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) CODEC / CRF / BITRATE",
    "confidence": "medium"
  },
  {
    "claim": "Instagram Reels upload specs (Meta official developer docs): video codec HEVC or H.264, progressive scan, closed GOP, 4:2:0 chroma. Audio AAC, max 48 kHz, 1-2 channels. Container MOV or MP4 (MPEG-4 Part 14), no edit lists, moov atom at file front. Frame rate 23-60 fps. File size maximum 8 MB per the API (though direct app uploads allow much larger). Aspect ratio 9:16 recommended. H.265/HEVC accepted in spec but causes frequent upload errors in practice — H.264 is the safe choice.",
    "source_url": "https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media/",
    "source_title": "Instagram Graph API — Meta Developer Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) CODEC / CRF / BITRATE",
    "confidence": "high"
  },
  {
    "claim": "x264/ffmpeg CRF for upload masters: CRF 17-18 with veryslow preset = visually lossless, large files — appropriate for upload master before platform re-encode. CRF 18 with slow preset is YouTube's community-documented recommendation. H.265/libx265 equivalent quality achieved at CRF 20-22. AV1/SVT-AV1 at CRF 20-25. Single-pass CRF is the standard for quality-focused work; two-pass is NOT prescribed for H.264/H.265 masters. VP9 is the exception that benefits from two-pass.",
    "source_url": "https://vibbit.ai/blog/ffmpeg-crf-examples",
    "source_title": "ffmpeg CRF Examples — vibbit.ai",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) CODEC / CRF / BITRATE",
    "confidence": "medium"
  },
  {
    "claim": "YouTube community-documented ffmpeg encode command (gist by mikoim, updated 2020): ffmpeg -i input.mp4 -c:v libx264 -profile:v high -preset slow -crf 18 -g 30 -bf 2 -pix_fmt yuv420p -c:a libfdk_aac -profile:a aac_low -b:a 384k -movflags faststart output.mp4. Key choices: CRF 18, High profile, 30-frame GOP, 2 B-frames, 384 kbps stereo AAC, faststart flag.",
    "source_url": "https://gist.github.com/mikoim/27e4e0dc64e384adbcb91ff10a2d3678",
    "source_title": "YouTube Upload ffmpeg Settings — mikoim gist (GitHub)",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) CODEC / CRF / BITRATE",
    "confidence": "high"
  },
  {
    "claim": "TikTok 9:16 safe zone pixel insets on 1080x1920 canvas (postplanify.com 2026 guide, cross-referenced with kreatli.com): top = 108px (profile picture, Follow button), bottom = 320px (captions, engagement buttons, sound attribution), left = 60px (edge margin), right = 120px (like/comment/share/bookmark icon stack). Safe content area = 900x1492px centered. For TikTok Ads (Spark/In-Feed): bottom increases to ~370px due to CTA button and 'Sponsored' label.",
    "source_url": "https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide",
    "source_title": "Social Media Safe Zones 2026 Complete Guide — PostPlanify",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) 9:16 SAFE ZONES",
    "confidence": "high"
  },
  {
    "claim": "Instagram Reels 9:16 safe zone pixel insets on 1080x1920 canvas (postplanify.com 2026 guide, cross-referenced with kreatli.com): top = 210px (profile picture, Follow button, three-dot menu), bottom = 310px (caption bar, audio attribution, engagement buttons), left = 0px (full width available), right = 84px (engagement buttons). Safe content area = 996x1400px centered.",
    "source_url": "https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide",
    "source_title": "Social Media Safe Zones 2026 Complete Guide — PostPlanify",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) 9:16 SAFE ZONES",
    "confidence": "high"
  },
  {
    "claim": "YouTube Shorts 9:16 safe zone pixel insets on 1080x1920 canvas (postplanify.com 2026 guide, cross-referenced with kreatli.com): top = 120px (minimal UI, grows on notched devices), bottom = 300px (channel name, Subscribe button, audio attribution, description), left = 0px (full width available), right = 96px (engagement buttons). Safe content area = 984x1500px centered. When description is expanded, bottom margin grows to ~360px.",
    "source_url": "https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide",
    "source_title": "Social Media Safe Zones 2026 Complete Guide — PostPlanify",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) 9:16 SAFE ZONES",
    "confidence": "high"
  },
  {
    "claim": "Universal cross-platform safe zone: 900x1400px centered in 1080x1920 provides compatibility coverage across TikTok, Instagram Reels, and YouTube Shorts simultaneously. This represents the most restrictive union of all three platforms' safe margins.",
    "source_url": "https://postplanify.com/blog/social-media-safe-zones-2026-complete-guide",
    "source_title": "Social Media Safe Zones 2026 Complete Guide — PostPlanify",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) 9:16 SAFE ZONES",
    "confidence": "high"
  },
  {
    "claim": "YouTube Shorts bottom safe zone CONFLICT: postlinkapp.com cites ~575px bottom inset (covering username, title, like/comment/share, description, hashtags — fully expanded), while postplanify.com/kreatli.com cite 300px (default collapsed-description state). The 300px figure is more operationally correct for standard non-expanded playback; 360-400px is recommended for ads.",
    "source_url": "https://postlinkapp.com/blog/youtube-shorts-size-and-dimensions",
    "source_title": "YouTube Shorts Size and Dimensions — PostLink",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) 9:16 SAFE ZONES",
    "confidence": "medium"
  },
  {
    "claim": "Remotion is currently on major version 4, with the latest patch release being v4.0.477 (released June 13, 2026). The version is in continuous active development with frequent patch releases.",
    "source_url": "https://github.com/remotion-dev/remotion/releases",
    "source_title": "Releases — remotion-dev/remotion (GitHub)",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "Remotion's frame-accurate model: useCurrentFrame() returns a 0-indexed integer frame number; every composition has durationInFrames (total frame count) and fps; time in seconds is computed as frame / fps; the first frame is 0 and the last is durationInFrames - 1. All animations must be driven by useCurrentFrame().",
    "source_url": "https://www.remotion.dev/docs/the-fundamentals",
    "source_title": "The Fundamentals — Remotion Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "Remotion's interpolate() function maps an input value (typically useCurrentFrame()) to an output range, supporting multi-point keyframes, per-segment easing, and extrapolation modes (extend, clamp, wrap, identity). It can animate CSS transforms including scale, translate, and rotate — enabling Ken Burns-style pan/zoom effects at frame-level precision.",
    "source_url": "https://www.remotion.dev/docs/interpolate",
    "source_title": "interpolate() — Remotion Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "Remotion's spring() is a physics-based animation primitive. Parameters include frame (from useCurrentFrame()), fps (from useVideoConfig()), config (stiffness, damping, mass), from/to, durationInFrames, delay, and reverse. The spring() reverse parameter was added in v3.3.92.",
    "source_url": "https://www.remotion.dev/docs/spring",
    "source_title": "spring() — Remotion Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "The @remotion/media-utils package provides: getAudioData(), useAudioData(), visualizeAudio() (frequency-domain amplitude array per frame), visualizeAudioWaveform(), useWindowedAudioData() (wav files only), and getWaveformPortion(). It supports audio-reactive animation but has NO native beat detection — it outputs frequency amplitudes, not beat timestamps. Beat sync requires external beat-detection data piped in as frame-indexed offsets.",
    "source_url": "https://www.remotion.dev/docs/audio/visualization",
    "source_title": "Audio Visualization — Remotion Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "Remotion's visualizeAudio() takes audioData, frame, fps, numberOfSamples (power of 2: 32, 64, 128, etc.), smoothing (boolean, default true), and optional optimizeFor ('accuracy'/'speed') and dataOffsetInSeconds. It returns a 0-1 amplitude array per frequency band — low frequencies (bass) on the left, high frequencies on the right. Remotion itself does not compute beat positions.",
    "source_url": "https://www.remotion.dev/docs/visualize-audio",
    "source_title": "visualizeAudio() — Remotion Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "Remotion's third-party integrations include Lottie (@remotion/lottie), Anime.js, CSS animations, GreenSock (GSAP), React Native Skia (@remotion/skia), Rive (@remotion/rive), Three.js (@remotion/three), Vidstack, GIFs (@remotion/gif), and TailwindCSS — but NO beat detection library is officially listed. The docs state 'all animations in Remotion must be driven by the value returned by useCurrentFrame().'",
    "source_url": "https://www.remotion.dev/docs/third-party",
    "source_title": "Third Party Integrations — Remotion Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames (by HeyGen) is an open-source HTML-to-video rendering framework. Current version is v0.6.97, released June 13, 2026, with 212 total releases. It is NOT a traditional NLE; developers write plain HTML/CSS/JS with animation libraries and it renders to MP4 via headless Chrome + FFmpeg.",
    "source_url": "https://github.com/heygen-com/hyperframes/releases",
    "source_title": "Releases — heygen-com/hyperframes (GitHub)",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames' keyframe/motion model uses CSS @keyframes (via Web Animations API adapter), GSAP timelines, Lottie, Three.js, Anime.js, WAAPI, and custom frame adapters. GSAP is paused and seeked to frame/fps before each capture — solving the problem that GSAP's internal wall-clock runs in real time and would otherwise complete entire animations before frame capture.",
    "source_url": "https://hyperframes.heygen.com/guides/hyperframes-vs-remotion",
    "source_title": "HyperFrames vs Remotion — HyperFrames Official Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames has two frame-accurate rendering modes: BeginFrame mode (Linux only) using Chrome's atomic compositor control for byte-reproducible frames; and Screenshot mode (macOS/Windows) using real-time Chrome screenshots as fallback. Only BeginFrame mode is fully deterministic at the byte level.",
    "source_url": "https://hyperframes.heygen.com/guides/hyperframes-vs-remotion",
    "source_title": "HyperFrames vs Remotion — HyperFrames Official Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames v0.6.92+ introduced per-property-group keyframe foundations with split mutations and replace-with-keyframes functionality. v0.6.91+ added a razor/blade tool for splitting timeline clips with GSAP-aware keyframe preservation. v0.6.97 (June 13, 2026) adds batch rendering and WebGL determinism improvements.",
    "source_url": "https://github.com/heygen-com/hyperframes/releases",
    "source_title": "Releases — heygen-com/hyperframes (GitHub)",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames vs Remotion key distinction: Remotion uses React reconciliation per frame — GSAP and other libraries with their own internal clocks do NOT compose cleanly with React's per-frame render and run at real-time speed during rendering. HyperFrames solves this via explicit GSAP seek-to-frame. Remotion gives frame-accurate output for its own interpolate/spring primitives; HyperFrames gives frame-accurate output for HTML/CSS/GSAP animations.",
    "source_url": "https://hyperframes.heygen.com/guides/hyperframes-vs-remotion",
    "source_title": "HyperFrames vs Remotion — HyperFrames Official Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "CapCut Auto Beat (Beat Sync) on desktop: accessed by right-clicking the audio track → Beat Detection. Auto-generates beat markers (shown as blue marks on desktop). Offers 'Beats 1' and 'Beats 2' options that control how frequently beats appear — effectively a density control. Users can also add and drag markers manually.",
    "source_url": "https://www.creativelysquared.com/article/how-to-add-beats-to-music-in-capcut-for-perfect-video-timing",
    "source_title": "How to Add Beats to Music in CapCut — CreativelySquared",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "medium"
  },
  {
    "claim": "CapCut Beat Sync on mobile: tap the music track → Beats → Auto-Generate → choose intensity from Light to Intense. Yellow dots mark detected beats. 'Intense' adds more beat points for detailed timing on fast-paced songs. The sensitivity/intensity slider controls beat density — effectively choosing between every-beat (Intense) and only strong-beat/downbeat (Light) detection.",
    "source_url": "https://www.creativelysquared.com/article/how-to-add-beats-to-music-in-capcut-for-perfect-video-timing",
    "source_title": "How to Add Beats to Music in CapCut — CreativelySquared",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "medium"
  },
  {
    "claim": "CapCut Auto Cut (the broader AI editing feature encompassing Beat Sync) is available on Mobile (iOS/Android) and Desktop (Windows/macOS) as of 2026, but is NOT supported on CapCut Web. The web version only supports basic trimming and splitting.",
    "source_url": "https://www.capcut.com/help/auto-cut-in-capcut",
    "source_title": "What Is Auto Cut in CapCut? — CapCut Help Center",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "CapCut's beat detection algorithm scans audio for peaks (percussive transients) representing beats. It does not exclusively detect downbeats — users control density via the Light-to-Intense slider (mobile) or Beats 1/Beats 2 (desktop). The auto-detection can miss beats with soft intros, live drums, swing rhythms, or heavy syncopation, requiring manual adjustment.",
    "source_url": "https://cursa.app/en/page/beat-based-editing-in-capcut-syncing-cuts-transitions-and-motion-to-music",
    "source_title": "Beat-Based Editing in CapCut — Cursa",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "medium"
  },
  {
    "claim": "TikTok has NO official published LUFS target or documented normalization behavior. Multiple audio engineering sources confirm: 'TikTok has never published an official LUFS target or documented their normalisation behaviour. Every number you see online (usually -14 LUFS) is an educated guess based on testing, not an official spec.'",
    "source_url": "https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok",
    "source_title": "LUFS for Spotify, TikTok & Apple Music — Songbrain 2026",
    "retrieved_at": "2026-06-14",
    "sub_question": "(f) DISSENT / CONTRADICTION",
    "confidence": "high"
  },
  {
    "claim": "Songbrain's 2026 loudness guide states TikTok has 'no integrated LUFS normalization on in-feed playback — whatever level your audio arrives at, that's the level it plays.' It recommends a TikTok-specific master at -7 to -8 LUFS with hotter limiting, or -10 LUFS if delivering one master for all platforms. Applying a -14 LUFS Spotify master to TikTok 'sounds soft.'",
    "source_url": "https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok",
    "source_title": "LUFS for Spotify, TikTok & Apple Music — Songbrain 2026",
    "retrieved_at": "2026-06-14",
    "sub_question": "(f) DISSENT / CONTRADICTION",
    "confidence": "high"
  },
  {
    "claim": "CONTRADICTION ON TIKTOK LUFS: Soundplate's 2026 streaming loudness table lists TikTok/Reels at -9 to -12 LUFS; APU Software's social media page lists TikTok/Reels at -16 LUFS integrated; ClickyApps 2025 guide lists TikTok at -14 LUFS; Songbrain 2026 states -7 to -9 LUFS with no normalization. These four sources give four conflicting numbers for the same platform — none cite an official TikTok spec page.",
    "source_url": "https://soundplate.com/streaming-loudness-lufs-table/",
    "source_title": "The Ultimate Guide to Streaming Loudness (LUFS Table 2026) — Soundplate",
    "retrieved_at": "2026-06-14",
    "sub_question": "(f) DISSENT / CONTRADICTION",
    "confidence": "high"
  },
  {
    "claim": "Real-world measurements of top-charting TikTok tracks average -8.4 LUFS (cited by Teknup via Soundplate), confirming that loud masters perform better on TikTok in-feed regardless of any theoretical normalization, and that the -14 LUFS target optimized for Spotify does not apply to TikTok.",
    "source_url": "https://soundplate.com/streaming-loudness-lufs-table/",
    "source_title": "The Ultimate Guide to Streaming Loudness (LUFS Table 2026) — Soundplate",
    "retrieved_at": "2026-06-14",
    "sub_question": "(f) DISSENT / CONTRADICTION",
    "confidence": "medium"
  },
  {
    "claim": "Editor dissent on downbeat vs every-beat cutting: Walter Murch's editing hierarchy (cited by Steed Films) ranks rhythm third in importance — behind emotion and story. The Steed Films article explicitly argues 'stop cutting to the beat — that's lazy editing,' calling it 'conventional wisdom' but a 'totally backwards approach' that creates 'disjointed pacing where some shots linger too long while others feel rushed' and produces predictable, mechanical content.",
    "source_url": "https://www.steedfilms.com/learn/stop-cutting-to-the-beat-thats-lazy-editing",
    "source_title": "Stop Cutting to the Beat. That's Lazy Editing. — Steed Films",
    "retrieved_at": "2026-06-14",
    "sub_question": "(f) DISSENT / CONTRADICTION",
    "confidence": "high"
  },
  {
    "claim": "Mainstream beat-sync editing guidance recommends using downbeats for major scene changes and weaker beats (2 and 4) for smaller transitions — not cutting on every single beat. However, the auto-beat-sync tool paradigm (CapCut, OpusClip, etc.) defaults to marking all detected beats, creating tension between tool defaults and editorial craft.",
    "source_url": "https://www.opus.pro/blog/best-ai-beat-sync",
    "source_title": "12 Best AI Beat-Sync & Cut-to-Music Tools — OpusClip Blog",
    "retrieved_at": "2026-06-14",
    "sub_question": "(f) DISSENT / CONTRADICTION",
    "confidence": "medium"
  },
  {
    "claim": "ffmpeg zoompan prescale fix is PARTIAL, not a complete elimination of jitter: the source says the upscale 'gets rid of MOST of the jitter.' Separately, the upstream ffmpeg bug #4298 notes the workaround 'doesn't always seem to have an effect with arbitrary x or y values' — confirming prescale is not a complete fix for all cases.",
    "source_url": "https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/",
    "source_title": "FFmpeg: Smooth Zoompan With No Jiggle — DataRecoveryUnion",
    "retrieved_at": "2026-06-14",
    "sub_question": "(f) DISSENT / CONTRADICTION",
    "confidence": "high"
  },
  {
    "claim": "Alternative to zoompan for Ken Burns: the ffmpeg geq filter can do zoom-out (which zoompan cannot — zoompan silently rejects z<1.0), but geq is 100-1000x slower than zoompan. The geq approach also does not smooth zooming without additional effort. The practical alternative for smooth, jitter-free Ken Burns is a real NLE or Remotion/HyperFrames.",
    "source_url": "https://hhsprings.bitbucket.io/docs/programming/examples/ffmpeg/manipulating_video_colors/use_of_geq_as_zoompan_alternative.html",
    "source_title": "Use of geq as zoompan alternative — ffmpeg examples",
    "retrieved_at": "2026-06-14",
    "sub_question": "(f) DISSENT / CONTRADICTION",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames explicitly positions itself as the alternative to ffmpeg zoompan for AI-generated Ken Burns effects: it uses seekable GSAP animations with frame-accurate Chrome capture, producing deterministic pixel-identical frames without integer rounding jitter. Remotion also eliminates zoompan jitter by using React interpolate() driving CSS scale/translate per frame.",
    "source_url": "https://hyperframes.heygen.com/guides/hyperframes-vs-remotion",
    "source_title": "HyperFrames vs Remotion — HyperFrames Official Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(f) DISSENT / CONTRADICTION",
    "confidence": "medium"
  },
  {
    "claim": "Remotion v4.0 (major version migration) key changes: FFmpeg now bundled into @remotion/renderer (no separate install); config file moved from 'remotion' to '@remotion/cli/config'; minimum Node.js version 16.0.0; MotionBlur component removed (use Trail instead); rich timeline removed due to performance issues; inputProps behavior changed in renderMedia().",
    "source_url": "https://www.remotion.dev/docs/4-0-migration",
    "source_title": "v4.0 Migration — Remotion Docs",
    "retrieved_at": "2026-06-14",
    "sub_question": "(e) TOOL CAPABILITIES + VERSIONS",
    "confidence": "high"
  },
  {
    "claim": "For Instagram Reels, creator tests show exporting at a controlled 5-8 Mbps can produce 20-30% higher perceived sharpness than very high bitrate uploads that trigger harsher re-compression. H.264 at 3,500-5,000 kbps is flagged as sufficient for good quality while keeping file sizes manageable. NOTE: this is from a third-party creator blog, not Meta's official documentation.",
    "source_url": "https://www.stayabundant.com/blog/best-instagram-reels-export-settings",
    "source_title": "Best Instagram Reels Export Settings — StayAbundant",
    "retrieved_at": "2026-06-14",
    "sub_question": "(d) CODEC / CRF / BITRATE",
    "confidence": "low"
  }
]

## Next questions (dynamically generated)
[
  "(c-deep) ffmpeg zoompan 2020 patch merge status: Was the ffmpeg-devel/256883 zoompan float-arithmetic + chroma-grid-alignment fix merged into ffmpeg mainline, and if so in which release (v4.x, v5.x, v6.x)? Does prescale remain necessary on ffmpeg 6.0+ / 7.0+ / 8.0+, or did the internal fix reduce jitter enough that prescale is now redundant?",
  "(e-capcut-version) CapCut version and Beat Sync specification: What is the current CapCut version number (iOS/Android/Desktop) as of mid-2026? Does CapCut's Beat Sync 'Beats 1 / Light' mode correspond to music-theory bar downbeats (beat 1 of each measure) or to highest-amplitude percussive transients — and is there any technical documentation or reverse-engineering analysis that distinguishes these two?",
  "(e-remotion-beatsync) Remotion beat-sync workflow in practice: Is there an official Remotion example, community template, or documented pattern for passing externally-computed beat timestamps (from madmom/librosa) into a Remotion composition via inputProps, and then snapping cuts/animations to those frames? What is the recommended data format (JSON array of seconds, or pre-converted frame indices)?",
  "(d-tiktok-audio-spec) TikTok audio upload specification: Does TikTok's Creator Portal, Business Help Center, or any first-party TikTok documentation specify audio codec, sample rate, or bitrate for uploaded videos? Specifically: is AAC at 44.1 kHz the only confirmed audio codec/sample-rate, or does TikTok also accept 48 kHz / stereo / higher bitrates from an official source?",
  "(a-tiktok-measurement) TikTok in-feed loudness — controlled measurement: Has any audio engineer or researcher published a controlled A/B test comparing the same audio at different LUFS targets played back on TikTok in-feed, measuring the actual output level (via SPL meter or loudness analyzer on the phone output)? This is the only way to empirically resolve the normalization-vs-no-normalization contradiction. Any such measurement study with methodology and results?",
  "(c-prescale-lanczos) Prescale filter quality flag for Ken Burns: When upscaling an image 8-10x before zoompan, does specifying :flags=lanczos on the scale filter produce a materially sharper result than the default bicubic scaler? Has any ffmpeg user benchmarked or compared Lanczos vs bicubic at the prescale stage for Ken Burns quality? Is there a recommended alternative (e.g., spline16, sinc)?",
  "(d-av1-upload-2026) AV1 as upload codec on TikTok and Instagram Reels: As of 2026, do TikTok or Instagram Reels officially accept AV1-encoded video as an upload container? Or is H.264 still the only reliably-accepted upload codec on both platforms, with AV1 used only on the delivery/playback side?"
]
