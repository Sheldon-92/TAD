# Round 3 — for-ai-assisted-short-form-montage-video-productio

- Questions researched: 7
- New findings: 31 (cumulative 129)
- Dry counter: 0/2

## New findings
[
  {
    "claim": "Apple Podcasts specifies -16 dB LKFS integrated loudness (±1 dB tolerance) with a true peak ceiling of -1 dBFS, explicitly citing ITU-R BS.1770-5 as the measurement standard. The spec requires preconditioning before encoding to prevent clipping.",
    "source_url": "https://podcasters.apple.com/support/893-audio-requirements",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-apple-loudness",
    "source_title": "Apple Podcasters Support — Audio Requirements",
    "confidence": "high"
  },
  {
    "claim": "Apple Digital Masters / Hi-Res Lossless / Immersive Audio submissions must not exceed -18 LKFS integrated loudness (measured per ITU-R BS.1770-4) with true peak not exceeding -1 dBTP. This is the mastering SUBMISSION CEILING, not the Sound Check playback normalization target — two distinct numbers from the same first-party source family.",
    "source_url": "https://help.apple.com/itc/videoaudioassetguide/en.lproj/static.html",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-apple-loudness",
    "source_title": "Apple Video and Audio Asset Guide",
    "confidence": "high"
  },
  {
    "claim": "Apple Music Dolby Atmos / immersive audio has a separate loudness target of -18 LKFS integrated (±1.0 LU) with true peak -1 dBTP — 2 LU quieter than the stereo Sound Check playback target of -16 LUFS. Apple was the first streaming service to issue specific immersive-content loudness guidelines.",
    "source_url": "https://www.production-expert.com/production-expert-1/apple-first-to-announce-immersive-loudness-guidance",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-apple-loudness",
    "source_title": "Production Expert — Apple First to Announce Immersive Loudness Guidance",
    "confidence": "high"
  },
  {
    "claim": "Apple TV Plus (tvOS streaming service) requires -24 LUFS integrated loudness with a true peak maximum of -1.0 dBTP for content delivery — tighter than Netflix (-2.0 dBTP) and Amazon Prime Video (-2.0 dBTP). Source is third-party industry delivery documentation (Tools for Film), not a publicly accessible primary Apple developer page.",
    "source_url": "https://www.toolsforfilm.com/blog/delivering-audio-netflix-amazon-apple",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-apple-loudness",
    "source_title": "Tools for Film — Delivering Audio to Netflix, Amazon, Apple",
    "confidence": "medium"
  },
  {
    "claim": "No publicly accessible primary Apple developer documentation page (developer.apple.com or apple.com) specifying '-16 LUFS' as the Apple Music Sound Check playback normalization target was found. The -16 LUFS figure for Apple Music Sound Check is universally reported by third-party mastering sources (Production Expert, MeterPlugs, RTW) without a traceable primary Apple source URL. This is a documented sourcing gap.",
    "source_url": "https://podcasters.apple.com/support/893-audio-requirements",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-apple-loudness",
    "source_title": "Apple Podcasters Support (used as proxy for Apple primary sourcing context)",
    "confidence": "high"
  },
  {
    "claim": "No primary Apple developer documentation page at developer.apple.com specifying loudness targets for Apple TV / tvOS HLS anchor loudness was successfully retrieved. The WWDC20 'Deliver a better HLS audio experience' session discusses DRC metadata and ANSI/CTA-2075 but cites no specific LUFS targets.",
    "source_url": "https://developer.apple.com/videos/play/wwdc2020/10158/",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-apple-loudness",
    "source_title": "WWDC20 — Deliver a better HLS audio experience",
    "confidence": "high"
  },
  {
    "claim": "Apple Sound Check updated to LUFS measurement (replacing its proprietary algorithm) in 2022, enabled by default on new iOS/macOS installations, aligning with AES TD1008 guidelines per MeterPlugs reporting. However, no official Apple press release or developer documentation link was found confirming this change — it is third-party reporting only.",
    "source_url": "https://www.meterplugs.com/blog/2022/03/23/apple-switch-to-lufs.html",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-apple-loudness",
    "source_title": "MeterPlugs — Apple Switch to LUFS (2022)",
    "confidence": "medium"
  },
  {
    "claim": "RTW Worldwide Delivery Specification resource cross-platform table: Apple Music stereo = -16 LUFS (±1.0 LU) / -1 dBTP; Apple Music immersive/Dolby Atmos = -18 LKFS (±1.0 LU) / -1 dBTP; Apple Podcasts = -16 LKFS (±1.0 dB) / -1 dBFS; YouTube = -14 LUFS / -1 dBTP. Source is a reputable third-party industry reference, not a primary platform spec page.",
    "source_url": "https://www.rtw.com/en/blog/worldwide-loudness-delivery-standards.html",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-lufs-table-complete",
    "source_title": "RTW — Worldwide Loudness Delivery Standards",
    "confidence": "medium"
  },
  {
    "claim": "YouTube's loudness normalization is attenuate-only: content louder than -14 LUFS is turned down; content quieter than -14 LUFS plays at its original level and is NOT boosted. This is confirmed empirically via 'Stats for Nerds' — a positive 'content loudness' dB value means YouTube reduced the track; a value at or below 0 dB means no normalization was applied. YouTube has no officially published Help Center article specifying '-14 LUFS' as its normalization target.",
    "source_url": "https://productionadvice.co.uk/stats-for-nerds/",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-lufs-table-complete",
    "source_title": "Production Advice — Stats for Nerds (YouTube Loudness)",
    "confidence": "high"
  },
  {
    "claim": "Google Display & Video 360 ad creatives specify -24 LKFS ±2 LKFS per IAB US spec, with Campaign Manager 360 normalizing to -24 LKFS. The DV360 guidelines explicitly state these do NOT apply to YouTube & partners line items — confirming -24 LKFS is for DV360 display ads only, NOT for YouTube organic video content.",
    "source_url": "https://support.google.com/displayvideo/answer/3129957",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-lufs-table-complete",
    "source_title": "Google DV360 Help — Audio Requirements for Video Ads",
    "confidence": "high"
  },
  {
    "claim": "AES TD1008.1.21-9 (2021, superseding TD1004) recommends -16 LUFS for music streaming and -18 LUFS for speech/dramatic content — these are recommendations TO streaming platforms, NOT to content creators or mastering engineers. The document explicitly states it is not intended for artists, producers, or music aggregators. Apple Music's -16 LUFS Sound Check aligns with AES TD1008 music recommendation.",
    "source_url": "https://productionadvice.co.uk/td1008/",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-lufs-table-complete",
    "source_title": "Production Advice — AES TD1008 Explained",
    "confidence": "high"
  },
  {
    "claim": "Walter Murch's 'In the Blink of an Eye' does NOT specify a numeric beat-anticipation cut offset in milliseconds or frames. Murch's contribution is the concept of cutting 'just before the blink' and his Rule of Six (emotion 51%, story 23%, rhythm 10%...). Rhythm ranks third — Murch treats cutting to the beat as subordinate to emotion and story. No quantitative frame/ms offset for beat-anticipation cutting was found in Murch's work.",
    "source_url": "https://www.premiumbeat.com/blog/cutting-on-the-blink-editing-tips-from-walter-murch/",
    "retrieved_at": "2026-06-14",
    "sub_question": "b-anticipation-offset",
    "source_title": "PremiumBeat — Cutting on the Blink: Editing Tips from Walter Murch",
    "confidence": "high"
  },
  {
    "claim": "ITU-R BT.1359-1 (1998) 'Relative timing of sound and vision for broadcasting' specifies detectability thresholds for A/V sync errors at approximately 45ms (audio leading video) to 125ms (audio lagging video), and acceptability thresholds at approximately 90ms (audio leading) to 185ms (audio lagging). This is a broadcast synchrony standard, not an editorial beat-sync spec, but provides the perceptual science baseline explaining why 1-2 frame anticipation (33-66ms at 30fps) falls within the perceptual window.",
    "source_url": "https://www.itu.int/rec/R-REC-BT.1359-1-199811-I/en",
    "retrieved_at": "2026-06-14",
    "sub_question": "b-anticipation-offset",
    "source_title": "ITU-R BT.1359-1 — Relative timing of sound and vision for broadcasting (1998)",
    "confidence": "high"
  },
  {
    "claim": "Academic study (PMC6711538, Frontiers in Psychology) on audiovisual synchrony in human motion to music found that 'movement onsets never coincided with music beats' — physical movement peaks LEAD the beat by up to 100ms. The temporal integration window (TIW) for audiovisual music synchrony was 300-450ms. This provides perceptual science basis for why pre-beat cuts feel 'on the beat' — the visual system expects anticipation. The study is about human physical movement, not editorial cuts specifically.",
    "source_url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC6711538/",
    "retrieved_at": "2026-06-14",
    "sub_question": "b-anticipation-offset",
    "source_title": "PMC6711538 — Frontiers in Psychology: Audiovisual Synchrony in Human Movement to Music",
    "confidence": "medium"
  },
  {
    "claim": "The '1-2 frame anticipation' rule for beat-sync cuts has NO citable primary source in music cognition research, editorial theory texts, or NLE documentation. It is practitioner community convention appearing in editor blogs (e.g., beat2cut.com) without citation to any primary scientific or technical source. The 10-30ms range cited in practitioner guides is illustrative, not empirically derived. This should be flagged as UNVERIFIED practitioner convention.",
    "source_url": "https://beat2cut.com/blog/beat-sync-video-editing-complete-guide/",
    "retrieved_at": "2026-06-14",
    "sub_question": "b-anticipation-offset",
    "source_title": "Beat2Cut — Beat Sync Video Editing Complete Guide",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames v0.6.97 (released June 13, 2026) does NOT support native beat detection or audio-reactive keyframe scheduling. Release notes from v0.6.88 through v0.6.97 describe batch rendering, WebGL determinism, studio resilience, and security hardening — no audio-reactive or beat-sync features appear.",
    "source_url": "https://github.com/heygen-com/hyperframes/releases",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-hyperframes-audio",
    "source_title": "Releases — heygen-com/hyperframes (GitHub)",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames audio-reactive animation requires externally pre-extracted audio frequency data — it is NOT native beat detection. The NousResearch Hermes Agent skill doc explicitly states: 'pre-extract audio bands (bass / mid / treble) and sample per-frame inside the timeline with a for loop of tl.call(draw, [], f / fps).' A single long tween does NOT react to audio — discrete per-frame updates with pre-computed audio data are required.",
    "source_url": "https://github.com/NousResearch/hermes-agent/blob/main/optional-skills/creative/hyperframes/SKILL.md",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-hyperframes-audio",
    "source_title": "hermes-agent/optional-skills/creative/hyperframes/SKILL.md — NousResearch (GitHub)",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames audio-reactive animation maps externally-computed frequency bands to visual properties: bass → scale (pulse), treble → textShadow/boxShadow (glow), overall amplitude → opacity/y/backgroundColor, mids → shape morphing. This external-computation model mirrors Remotion's @remotion/media-utils pattern — both require audio pre-processing outside the renderer, then per-frame values fed into animations.",
    "source_url": "https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/creative/creative-hyperframes",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-hyperframes-audio",
    "source_title": "Hyperframes | Hermes Agent Docs — Nous Research",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames official documentation (hyperframes.mintlify.app) has no dedicated section for audio-reactive animation, beat sync, audio keyframes, or music synchronization — the documentation index covers Catalog, Concepts, Contributing, Deployment, Guides, Packages, Reference, and Examples, none titled for audio reactivity or beat detection.",
    "source_url": "https://hyperframes.mintlify.app/llms.txt",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-hyperframes-audio",
    "source_title": "HyperFrames Documentation Index (llms.txt)",
    "confidence": "high"
  },
  {
    "claim": "HyperFrames compose agent (AI-driven composition tool) lists 'audio-reactive animation' as one of 25+ baked-in skills in the MCP guide. However, the MCP guide provides no technical API details — the agent applies audio reactivity conversationally without exposing audio analysis parameters to users directly. This is a marketing-level claim without technical specification.",
    "source_url": "https://hyperframes.mintlify.app/guides/mcp",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-hyperframes-audio",
    "source_title": "HyperFrames MCP Guide",
    "confidence": "medium"
  },
  {
    "claim": "HyperFrames prompt guide specifies audio-reactive intensity guidelines: keep effects subtle for text (3–6% intensity), go bigger for backgrounds (10–30%). Bass → scale pulse; treble → glow shimmer; amplitude → opacity breathing; mids → shape morphing. No beat-detection API or beat timestamp input format is specified.",
    "source_url": "https://hyperframes.heygen.com/guides/prompting",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-hyperframes-audio",
    "source_title": "Prompt Guide — HyperFrames",
    "confidence": "medium"
  },
  {
    "claim": "Meta's Engineering at Meta blog post (April 2023) on xHE-AAC confirms that loudness management 'leaves the original audio characteristics untouched and delegates loudness management processing to the client via loudness metadata,' using 'loudness range control (LRAC) DRC' in a two-pass encoding process. The post does NOT disclose any specific LUFS/LKFS target number for Instagram Reels in-feed playback.",
    "source_url": "https://engineering.fb.com/2023/04/11/video-engineering/high-quality-audio-xhe-aac-codec-meta/",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-instagram-loudness",
    "source_title": "Engineering at Meta — Why xHE-AAC is being embraced at Meta (April 2023)",
    "confidence": "high"
  },
  {
    "claim": "Meta has never published an official LUFS target or loudness normalization specification for Instagram Reels in any Meta developer documentation, Instagram Help Center page, or Meta engineering blog as of June 2026. No primary Meta source specifying a LUFS number for Reels in-feed playback exists.",
    "source_url": "https://engineering.fb.com/2023/04/11/video-engineering/high-quality-audio-xhe-aac-codec-meta/",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-instagram-loudness",
    "source_title": "Engineering at Meta — xHE-AAC (closest available primary source)",
    "confidence": "high"
  },
  {
    "claim": "Third-party sources give conflicting LUFS estimates for Instagram Reels with zero primary-source backing: apu.software claims -16 LUFS / -1 dBTP (observed platform behavior); audioutils.com recommends -14 LUFS / -1 dBTP (consistent with YouTube); opus.pro recommends -10 to -12 LUFS (noisy environments). All Instagram Reels LUFS numbers in third-party guides are UNVERIFIED estimates, not documented platform specs.",
    "source_url": "https://apu.software/tiktok-instagram-reels-loudness/",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-instagram-loudness",
    "source_title": "APU Software — Social Media (TikTok/Reels) Loudness Target",
    "confidence": "high"
  },
  {
    "claim": "AudioUtils.com reverse-engineers Instagram Reels re-encode via third-party tools: upload at AAC-LC 256–320 kbps, Instagram re-encodes to approximately AAC-LC 128 kbps stereo for default playback, with lower-quality variants at ~64 kbps mono. The site explicitly notes 'Meta does not publish exact ladder specs.' The recommendation of -14 LUFS / -1 dBTP for upload is based on reverse-engineering, not official documentation.",
    "source_url": "https://audioutils.com/blog/best-audio-format-for-instagram",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-instagram-loudness",
    "source_title": "AudioUtils — Best Audio Format for Instagram Reels and Stories",
    "confidence": "medium"
  },
  {
    "claim": "The ffmpeg zscale filter (FFmpeg 8.0.1) supports resize algorithms via the 'filter'/'f' parameter: point, bilinear (DEFAULT — not lanczos), bicubic, spline16, spline36, lanczos. Correct syntax for 8x upscale with spline36: zscale=w=iw*8:h=ih*8:f=spline36. For lanczos: zscale=w=iw*8:h=ih*8:f=lanczos. The lanczos tap count is controlled via param_a. A naive zscale=w=iw*8:h=ih*8 without specifying 'f=' uses bilinear — lower quality than scale=8*iw:-2 with bicubic default.",
    "source_url": "https://ayosec.github.io/ffmpeg-filters-docs/8.0/Filters/Video/zscale.html",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-zoompan-zscale",
    "source_title": "zscale — FFmpeg 8.0.1 Filter Docs",
    "confidence": "high"
  },
  {
    "claim": "ASWF/ORI Encoding Guidelines on zscale vs swscale: 'Its frankly hard to say between zscale and swscale which is better.' For 4:2:0 conversion, 'zscale does produce a slightly improved if occasionally softer result.' No comparison data exists for the zoompan prescale upscaling use case — the ASWF benchmarks cover downsampling and color-space conversion only.",
    "source_url": "https://academysoftwarefoundation.github.io/EncodingGuidelines/EncodeSwsScale.html",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-zoompan-zscale",
    "source_title": "ASWF ORI Encoding Guidelines — FFmpeg Scaling Options",
    "confidence": "high"
  },
  {
    "claim": "No published benchmark or controlled quality comparison between zscale (spline36/lanczos) and scale (lanczos/bicubic) specifically for the zoompan prescale upscaling step exists in any public source. The VideoHelp forum expert recommendation to use zscale for quality rescaling is an expert opinion without a published empirical measurement. The quality advantage of zscale over scale with flags=lanczos for prescale-then-zoompan remains UNVERIFIED by any primary empirical source.",
    "source_url": "https://forum.videohelp.com/threads/399323-Which-spline-resizer-is-ffmpeg-using",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-zoompan-zscale",
    "source_title": "VideoHelp Forum — Which spline resizer is ffmpeg using",
    "confidence": "high"
  },
  {
    "claim": "Meta's official Instagram Graph API documentation exact verbatim text for Reels audio: 'Audio codec: AAC, 48khz sample rate maximum, 1 or 2 channels (mono or stereo). Audio bitrate: 128kbps.' The word 'maximum' implies lower sample rates may be accepted, but 44.1 kHz is NOT mentioned. Container: MOV or MP4 (no edit lists, moov atom at front). Video codec: HEVC or H264, progressive scan, closed GOP, 4:2:0 chroma. Frame rate: 23-60 FPS. Duration: 3s min, 15 min max. File size: 300 MB max.",
    "source_url": "https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media/",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-instagram-audio-spec-primary",
    "source_title": "Meta for Developers — IG User Media Reference (Instagram Graph API)",
    "confidence": "high"
  },
  {
    "claim": "Whether 44.1 kHz is accepted by Instagram Reels upload cannot be answered from any primary Meta source. Third-party reverse-engineering (audioutils.com via youtube-dl/ffprobe on downloaded Reels) found 'sample rate is preserved at 44.1 or 48 kHz' implying 44.1 kHz uploads are accepted. Creator guides disagree: klap.app recommends 44.1 kHz; fone.tips and influenceflow.io recommend 48 kHz. None cite a primary Meta source. The only primary source page specifies only '48khz sample rate maximum.'",
    "source_url": "https://audioutils.com/blog/best-audio-format-for-instagram",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-instagram-audio-spec-primary",
    "source_title": "AudioUtils — Best Audio Format for Instagram (reverse-engineering analysis)",
    "confidence": "medium"
  },
  {
    "claim": "The Instagram Content Publishing Audio API page (developers.facebook.com/docs/instagram-platform/content-publishing/audio-api/) contains no audio format encoding specifications — no codec, sample rate, bitrate, or channel count. It covers API functionality for searching audio assets and attaching audio to Reels only. Developers must cross-reference the IG User Media reference page for encoding specs.",
    "source_url": "https://developers.facebook.com/docs/instagram-platform/content-publishing/audio-api/",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-instagram-audio-spec-primary",
    "source_title": "Instagram Platform — Audio API (Meta for Developers)",
    "confidence": "high"
  }
]

## Next questions (dynamically generated)
[
  "(d-safe-zone-primary) 9:16 safe-zone pixel insets — primary source hunt: What are the EXACT documented safe-zone pixel insets (top, bottom, left/right) on a 1080x1920 canvas for TikTok, Instagram Reels, and YouTube Shorts? Do any of these platforms publish official creative spec sheets or developer documentation specifying UI overlay intrusion zones in pixels? Does TikTok's Effect House or Ads Manager publish safe-zone inset numbers? Does YouTube's Help Center publish safe-zone specs for Shorts? Does Meta publish safe-zone dimensions for Reels?",
  "(d-tiktok-audio-spec) TikTok upload audio spec — primary source: TikTok's Content Posting API lists supported video codecs but contains no audio codec, sample rate, channel count, or bitrate specification. Is there ANY primary TikTok source (TikTok for Business, TikTok Help Center, Effect House, Content Posting API docs) that specifies the accepted audio codec (AAC vs MP3 vs other), sample rate, channel count, and audio bitrate for uploaded videos? If not, what do controlled upload tests (ffprobe analysis of TikTok-delivered streams) reveal about TikTok's output audio encoding parameters?",
  "(d-crf-table-primary) Per-platform recommended x264 CRF values — primary or authoritative source: What CRF value does each platform's upload spec or authoritative encoding guide recommend for H.264 uploads? Specifically: (i) Does YouTube's creator academy or Help Center specify a CRF range? (ii) Does Instagram's Graph API docs or Meta's engineering blog mention CRF or quality settings? (iii) Does TikTok's ads spec or content posting guide mention CRF? What do authoritative third-party encoding guides (Handbrake, ffmpeg wiki, Streaming Learning Center) recommend as CRF for social platform uploads?",
  "(e-capcut-frame-accuracy) CapCut beat detection accuracy — frame-accurate vs heuristic: Is CapCut Beat Sync (iOS v18.1.0) frame-accurate (beat markers snap to exact frame boundaries at the video's native fps) or heuristic (approximate onset detection that may be sub-frame or drift over time)? Does CapCut's technical documentation, any patent filing, or any controlled test (comparing beat marker positions to manually verified downbeats via audio analysis tools like librosa) reveal the underlying detection mechanism — onset detection, FFT peak, or neural beat tracking?",
  "(a-apple-soundcheck-primary) Apple Sound Check primary documentation: Beyond the 2022 MeterPlugs report of Apple switching to LUFS, is there ANY primary Apple source — WWDC session, Apple developer documentation page, Apple Music for Artists page, or AES paper co-authored by Apple engineers — that documents the -16 LUFS Sound Check target with ITU-R BS.1770 methodology? Specifically: does Apple Music for Artists (artists.apple.com) publish any loudness guidance analogous to Spotify for Artists?",
  "(b-downbeat-detection-libraries) Downbeat vs beat detection in audio libraries: Does librosa's beat_track() function detect downbeats (beat 1 of each measure) or all beats equally? Does madmom's BeatTrackingProcessor output downbeat positions separately from beat positions? Is there a documented difference between librosa beat_track() and madmom's DownBeatTrackingProcessor output granularity, and what are the API signatures for passing downbeat-only timestamps into a video renderer?"
]
