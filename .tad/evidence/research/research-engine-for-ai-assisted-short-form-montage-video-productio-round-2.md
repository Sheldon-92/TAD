# Round 2 — for-ai-assisted-short-form-montage-video-productio

- Questions researched: 7
- New findings: 26 (cumulative 98)
- Dry counter: 0/2

## New findings
[
  {
    "claim": "The ffmpeg-devel/256883 zoompan 'fix shaking when zooming' patch (v4, posted February 2020) was NEVER merged into ffmpeg mainline. The FFmpeg patchwork tracker lists the v4 patch status as 'New' (unmerged), and earlier versions v1-v3 as 'Superseded'. The only reviewer response was Paul B Mahol asking about backward-compatibility — no LGTM or acceptance was recorded. The patch stalled and was abandoned.",
    "source_url": "https://patchwork.ffmpeg.org/project/ffmpeg/list/?q=zoompan&state=*",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-deep: ffmpeg-devel/256883 merge status",
    "confidence": "high",
    "source_title": "FFmpeg Patchwork — zoompan patch list"
  },
  {
    "claim": "The vf_zoompan.c git commit history confirms there is NO shaking/jitter fix commit merged from 2020. The only 2020 commit is commit 32d6fe23b660 (June 25, 2020) titled 'avfilter/zoompan: add in_time variable' — a new expression variable addition, not a jitter fix. The jitter bug (ffmpeg trac #4298) therefore remains in mainline through ffmpeg 8.x.",
    "source_url": "https://github.com/FFmpeg/FFmpeg/commits/master/libavfilter/vf_zoompan.c",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-deep: ffmpeg-devel/256883 merge status confirmed via git log",
    "confidence": "high",
    "source_title": "FFmpeg/FFmpeg GitHub — vf_zoompan.c commit history"
  },
  {
    "claim": "The prescale workaround for zoompan jitter (upscaling to e.g. 8000x4000 before applying zoompan) is STILL NECESSARY as of 2024–2026 on ffmpeg 6.x, 7.x, and 8.x because the 2020 fix was never merged. The prescale only reduces 'most of the jitter' — it is not a complete fix for arbitrary x/y pan values.",
    "source_url": "https://www.datarecoveryunion.com/video-ffmpeg-smooth-zoompan-with-no-jiggle/",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-deep: does prescale remain necessary on ffmpeg 6.0+/7.0+/8.0+?",
    "confidence": "high",
    "source_title": "DataRecoveryUnion — ffmpeg: smooth zoompan with no jiggle"
  },
  {
    "claim": "CapCut iOS v18.1.0 was released on June 12, 2026 (requires iOS 16.4+). This is the current iOS version as of mid-June 2026. Wikipedia's macOS (6.5.0, July 2025) and Android (14.6.0, July 2025) entries appear significantly outdated — the large version number gap between platforms (18.x iOS vs 14.x Android vs 6.x macOS) confirms each platform uses an independent versioning scheme.",
    "source_url": "https://capcut.en.softonic.com/iphone",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-capcut-version: CapCut current iOS version mid-2026",
    "confidence": "high",
    "source_title": "Softonic — Download CapCut for iPhone, latest version"
  },
  {
    "claim": "CapCut desktop's 'Beats 1' and 'Beats 2' are beat DENSITY controls, not a downbeat-vs-all-beats music-theory distinction. 'Beats 1' places fewer markers (sparser); 'Beats 2' places more markers (denser). Both modes detect percussive peaks from FFT analysis; the distinction is how many detected peaks are surfaced as edit points, not a filter for bar-downbeats.",
    "source_url": "https://www.creativelysquared.com/article/how-to-add-beats-to-music-in-capcut-for-perfect-video-timing",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-capcut-version: CapCut Beat Sync Beats 1 vs Beats 2 specification",
    "confidence": "medium",
    "source_title": "CreativelySquared — How to add beats to music in CapCut for perfect video timing"
  },
  {
    "claim": "A community-observed (not officially documented) CapCut colored marker system distinguishes beat types: red dots = downbeats (beat 1 of measure), orange dots = regular beats, yellow dots = off-beats. This was surfaced by a community tutorial but is not confirmed in official CapCut help documentation and no technical source specifies whether the detection is onset-based or downbeat-tracking.",
    "source_url": "https://vediting.home.blog/2025/10/28/%F0%9F%8E%B6-how-to-sync-transitions-with-music-beats-in-capcut-beat-sync-tutorial/",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-capcut-version: CapCut Beat Sync colored dots downbeat vs beat",
    "confidence": "low",
    "source_title": "VEditing Blog — How to Sync Transitions with Music Beats in CapCut"
  },
  {
    "claim": "There is NO official Remotion example, documented pattern, or community template specifically for passing externally-computed beat timestamps from madmom/librosa via inputProps. Remotion's official docs confirm @remotion/media-utils has no native beat detection — it outputs frequency amplitudes per frame, not beat timestamps. The documented audio-visualization template covers frequency bars only.",
    "source_url": "https://www.remotion.dev/docs/audio/visualization",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-remotion-beatsync: official Remotion beat sync pattern",
    "confidence": "high",
    "source_title": "Remotion Docs — Audio Visualization"
  },
  {
    "claim": "The community-documented Remotion pattern for beat-snapped cuts: (1) compute beat timestamps externally (librosa/madmom), (2) pass as JSON array of floats in SECONDS via --props='{\"beats\": [0.52, 1.08, 1.63, ...]}' or --props=./beats.json, (3) read inside composition with getInputProps(), (4) convert to frame indices via Math.round(beatTimeInSeconds * fps) inside the component using useVideoConfig().fps, (5) render clips as <Sequence from={beatFrame}> components. Pre-conversion to frame indices is NOT recommended — conversion happens inside the component to stay fps-agnostic.",
    "source_url": "https://github.com/orgs/remotion-dev/discussions/1526",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-remotion-beatsync: recommended data format and pattern for beat timestamps",
    "confidence": "medium",
    "source_title": "Remotion GitHub Discussions #1526 — Large audio clips efficiency"
  },
  {
    "claim": "Remotion's getInputProps() accepts any JSON-serializable value including arrays of floats. The docs explicitly note this API is non-typesafe and recommend using typed React props passed through calculateMetadata() instead for production use. The CLI supports --props=./beats.json for passing a JSON file directly.",
    "source_url": "https://www.remotion.dev/docs/get-input-props",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-remotion-beatsync: JSON format for beat timestamps via inputProps",
    "confidence": "high",
    "source_title": "Remotion Docs — getInputProps()"
  },
  {
    "claim": "Remotion maintainers warn that 1500+ individual <Audio> or <Sequence> tags causes performance issues and recommend pre-mixing into a single audio file instead. For beat-snapped video cuts (not audio clips), large arrays of <Sequence> components mapped from beat timestamps are the standard pattern and do not hit this limit in practice.",
    "source_url": "https://github.com/orgs/remotion-dev/discussions/1526",
    "retrieved_at": "2026-06-14",
    "sub_question": "e-remotion-beatsync: performance caveat for large beat arrays",
    "confidence": "medium",
    "source_title": "Remotion GitHub Discussions #1526"
  },
  {
    "claim": "TikTok's official Content Posting API Media Transfer Guide specifies accepted video codecs as H.264 (recommended), H.265, VP8, and VP9 — but contains NO audio codec, sample rate, or bitrate specifications whatsoever. AV1 is not listed as a supported upload codec.",
    "source_url": "https://developers.tiktok.com/doc/content-posting-api-media-transfer-guide",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-tiktok-audio-spec and d-av1-upload-2026",
    "confidence": "high",
    "source_title": "TikTok Content Posting API: Media Transfer Guide"
  },
  {
    "claim": "TikTok's official Ads Manager in-feed video ad specifications page specifies video file type, dimensions, duration, bitrate, and file size — but contains NO audio codec, sample rate, channel count, or bitrate specifications. TikTok has no first-party published audio spec for standard video uploads.",
    "source_url": "https://ads.tiktok.com/help/article/video-ads-specifications",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-tiktok-audio-spec",
    "confidence": "high",
    "source_title": "TikTok Auction In-Feed Ads Video Ad Specifications"
  },
  {
    "claim": "TikTok Effect House (TikTok's AR creation platform) specifies audio for AR effects as MP3 only at 44100 Hz recommended, stating 'other sample rates will get compressed.' This is a first-party TikTok document specifying 44.1 kHz — but it applies to AR effect assets ONLY, not to uploaded videos, and explicitly does not mention AAC or video upload context.",
    "source_url": "https://effecthouse.tiktok.com/learn/guides/workspace/assets/asset-preparation/audio",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-tiktok-audio-spec",
    "confidence": "high",
    "source_title": "Audio Asset Preparation | TikTok Effect House"
  },
  {
    "claim": "No published controlled A/B test with SPL meter or digital loudness analyzer measuring TikTok in-feed playback output at different input LUFS was found in any audio engineering publication, forum (Gearspace, Reddit, KVR), or academic database. The normalization-vs-no-normalization contradiction for TikTok remains empirically unresolved in all public sources as of mid-2026.",
    "source_url": "https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-tiktok-measurement",
    "confidence": "high",
    "source_title": "LUFS for Spotify, TikTok & Apple Music — Loudness Guide 2026 (Songbrain)"
  },
  {
    "claim": "A Fall 2025 University of Colorado Denver academic thesis studied TikTok audio compression empirically, with a search summary citing findings that 'native captures averaged -33 LUFS with 13-14 LU loudness range, whereas TikTok outputs measured around -28 LUFS with 9-10 LU loudness range' — suggesting platform-side loudness processing. However, the PDF source itself was unreadable binary content; the methodology, author name, and full results could not be directly verified from the document. TREAT AS UNVERIFIED.",
    "source_url": "https://artsandmedia.ucdenver.edu/docs/librariesprovider27/alma-mater/waddell_thesis_fall2025.pdf",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-tiktok-measurement",
    "confidence": "low",
    "source_title": "Audio Compression Comparison Analysis of Videos Recorded in TikTok — University of Colorado Denver (Fall 2025 thesis, UNVERIFIED content)"
  },
  {
    "claim": "The standard public-domain ffmpeg Ken Burns prescale technique uses plain `scale=8000:-1` or `scale=8*iw:-2` with NO explicit `flags=lanczos` specification. The prescale factor of 8000px or 8x image height is the standard recommendation, but the scaler algorithm is left at ffmpeg's default (bicubic). Adding `flags=lanczos` is a user-level addition not present in any widely-cited Ken Burns tutorial.",
    "source_url": "https://www.bannerbear.com/blog/how-to-do-a-ken-burns-style-effect-with-ffmpeg/",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-prescale-lanczos: standard practice",
    "confidence": "high",
    "source_title": "How to Create Videos with a Ken Burns Style Effect using FFmpeg — Bannerbear"
  },
  {
    "claim": "A 2026 WaveSpeed ffmpeg upscaling guide presents a quality/speed ranking (no VMAF/SSIM numbers): lanczos = 'best quality, slowest, final output'; spline = 'very good quality, slow, good for upscaling'; bicubic = 'good quality, medium speed, general use'; bilinear = 'fair quality, fastest, previews only.' Spline is specifically recommended for upscaling scenarios over lanczos due to speed/quality balance.",
    "source_url": "https://wavespeed.ai/blog/posts/blog-how-to-upscale-enhance-video-quality-ffmpeg/",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-prescale-lanczos: quality ranking for upscaling",
    "confidence": "medium",
    "source_title": "How to Upscale and Enhance Video Quality with FFmpeg (2026 Guide) — WaveSpeed"
  },
  {
    "claim": "Streaming Learning Center / NETINT benchmarks of ffmpeg scaling using VMAF, PSNR, and SSIM show Cascade+Lanczos consistently beats default bicubic for DOWNSCALING — default bicubic required 11.24-12.89% higher bitrate to match Cascade+Lanczos quality. Fast bilinear is 'the clear loser.' CRITICAL CAVEAT: these benchmarks are for downscaling only and do NOT address the zoompan prescale upscaling use case.",
    "source_url": "https://streaminglearningcenter.com/ffmpeg/maximizing-quality-and-throughput-in-ffmpeg-scaling.html",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-prescale-lanczos: quantified benchmark (downscaling only)",
    "confidence": "medium",
    "source_title": "Maximizing Quality and Throughput in FFmpeg Scaling — Streaming Learning Center"
  },
  {
    "claim": "No published benchmark or comparison specifically testing flags=lanczos vs default bicubic on the zoompan prescale step for Ken Burns output quality exists. The quality advantage of lanczos for this upscaling use case must be inferred from general upscaling principles. A VideoHelp forum expert (jagabo) recommends using zscale instead of scale for quality-focused rescaling, without a benchmark comparison.",
    "source_url": "https://forum.videohelp.com/threads/399323-Which-spline-resizer-is-ffmpeg-using",
    "retrieved_at": "2026-06-14",
    "sub_question": "c-prescale-lanczos: absence of Ken Burns-specific benchmark",
    "confidence": "high",
    "source_title": "Which spline resizer is ffmpeg using? — VideoHelp Forum"
  },
  {
    "claim": "Meta's Engineering at Meta blog post (February 2023) confirms AV1 is used exclusively on the delivery/playback side for Instagram Reels. The upload pipeline uses H.264 first-stage encode; Meta's backend generates AV1 outputs for streaming. AV1 is Meta's delivery codec, NOT an accepted upload codec.",
    "source_url": "https://engineering.fb.com/2023/02/21/video-engineering/av1-codec-facebook-instagram-reels/",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-av1-upload-2026: Instagram Reels AV1 role",
    "confidence": "high",
    "source_title": "Engineering at Meta — AV1 Codec for Facebook and Instagram Reels (Feb 2023)"
  },
  {
    "claim": "Meta's official Instagram Graph API documentation lists only HEVC (H.265) and H.264 as accepted video codecs for Reels upload: 'Video codec: HEVC or H264, progressive scan, closed GOP, 4:2:0 chroma subsampling.' AV1 is not mentioned as an accepted upload codec anywhere in the API spec.",
    "source_url": "https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media/",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-av1-upload-2026: Instagram Graph API upload codec list",
    "confidence": "high",
    "source_title": "Meta Developers — Instagram Graph API: IG User Media"
  },
  {
    "claim": "TikTok's Content Posting API supported codec enumeration (H.264, H.265, VP8, VP9) is a closed list that excludes AV1. No primary TikTok source was found stating AV1 upload is accepted. A 2026 creator guide (clippie.ai) explicitly states 'AV1-encoded files are not officially supported and may fail to upload' on TikTok.",
    "source_url": "https://clippie.ai/blog/tiktok-export-settings-ai-video-quality-2026",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-av1-upload-2026: TikTok AV1 upload status",
    "confidence": "medium",
    "source_title": "Clippie.ai — TikTok Export Settings AI Video Quality 2026"
  },
  {
    "claim": "A real-world user case from the Lightworks forum shows that exporting with AV1 codec for TikTok caused playback failure on a Samsung Galaxy S23 Android phone — the device could not decode AV1 in TikTok's player. This is a device-side decode failure, not an upload rejection, but confirms AV1 creates practical compatibility problems on midrange Android when used with TikTok.",
    "source_url": "https://forum.lwks.com/threads/problem-uploading-mp4-files-to-tiktok.251060/",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-av1-upload-2026: AV1 playback failure on Android in TikTok",
    "confidence": "medium",
    "source_title": "Lightworks Forum — Problem uploading MP4 files to TikTok"
  },
  {
    "claim": "TikTok uses AV1 for streaming to newer devices (mobile-first optimization for data efficiency), but this is server-side transcoding output, not an upload requirement. Uploaders always use H.264 or H.265 as the input codec; TikTok's backend handles AV1 transcoding for playback on supported devices. AV1 at TikTok is a delivery codec only.",
    "source_url": "https://compresto.app/blog/video-compression-for-you-tube-tik-tok",
    "retrieved_at": "2026-06-14",
    "sub_question": "d-av1-upload-2026: TikTok AV1 delivery-only role",
    "confidence": "medium",
    "source_title": "Compresto — Video Compression for YouTube and TikTok"
  },
  {
    "claim": "The songbrain.ai 2026 loudness guide claims TikTok has 'no integrated LUFS normalization on in-feed playback' — its only supporting evidence is a listening comparison showing a -6 LUFS song sounds louder than a -14 LUFS song when scrolling TikTok. No SPL meter, digital level measurement, or reproducible methodology is described. This is anecdotal, not controlled.",
    "source_url": "https://www.songbrain.ai/guides/lufs-for-spotify-and-tiktok",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-tiktok-measurement: quality of songbrain evidence",
    "confidence": "high",
    "source_title": "LUFS for Spotify, TikTok & Apple Music — Loudness Guide 2026 (Songbrain)"
  },
  {
    "claim": "The apu.software TikTok/Reels loudness page claims TikTok normalizes to approximately -16 LUFS but provides zero methodology, no measurements, and no source citations. It functions as a sales page for loudness processing software rather than a research document.",
    "source_url": "https://apu.software/tiktok-instagram-reels-loudness/",
    "retrieved_at": "2026-06-14",
    "sub_question": "a-tiktok-measurement: quality of apu.software evidence",
    "confidence": "high",
    "source_title": "Social Media (TikTok/Reels) Loudness Target — APU Software"
  }
]

## Next questions (dynamically generated)
[
  "(a-apple-loudness) Apple platform loudness — primary sources: What are the exact integrated LUFS target and true-peak ceiling for (i) Apple Music normalization, (ii) Apple Podcasts upload requirements, and (iii) Apple TV / tvOS? Is there a primary Apple developer documentation page specifying these numbers with ITU-R BS.1770 or EBU R128 methodology citations?",
  "(b-anticipation-offset) Beat-sync cut anticipation offset — primary source hunt: The practitioner community references a '1-2 frame anticipation' rule for cutting slightly before the downbeat to account for human perception lag. Is there a citable primary source — music cognition research, editorial theory text, or NLE documentation — that specifies this offset in ms at specific frame rates? Does Walter Murch's 'In the Blink of an Eye' or any academic paper on audiovisual synchrony specify a numeric offset?",
  "(a-lufs-table-complete) Complete per-platform loudness table — YouTube and Spotify primary sources: Prior rounds accumulated TikTok (contested), Instagram (no normalization spec found), and YouTube (EBU R128 -14 LUFS confirmed via YouTube help). Can we confirm the exact primary-source URL and date for YouTube's -14 LUFS target and -1 dBTP ceiling? Is YouTube's normalization 'attenuate-only' (confirmed by any primary source) or does it also boost quiet content?",
  "(e-hyperframes-audio) HyperFrames audio-reactive / beat-sync capability: Does HyperFrames v0.6.97 support any native audio-reactive keyframe scheduling, or does beat-synced animation require passing externally-computed beat timestamps (same pattern as Remotion)? Is there any HyperFrames example or documentation for audio-driven keyframes?",
  "(a-instagram-loudness) Instagram Reels loudness — primary source: Does Meta publish any official loudness normalization target or audio processing specification for Instagram Reels in-feed playback? Is there a Meta engineering blog post or developer documentation page specifying LUFS targets for Reels, analogous to YouTube's documented -14 LUFS target?",
  "(c-zoompan-zscale) zscale as prescale alternative: The VideoHelp forum expert recommended zscale over scale for quality rescaling. Does the ffmpeg zscale filter (z.lib wrapper) produce measurably better output than scale+lanczos for the zoompan prescale step? Is there any documented comparison of scale vs zscale for the Ken Burns prescale use case, and what is the correct zscale filter syntax for an 8x upscale?",
  "(d-instagram-audio-spec-primary) Instagram Reels audio upload spec — primary source verification: The accumulated finding states Instagram Reels accepts 'AAC, max 48 kHz, 1-2 channels' based on Meta developer docs. Can we locate the exact primary Meta developer documentation URL specifying audio codec, sample rate, and channel count for Reels uploads, and confirm whether 44.1 kHz is also accepted or only 48 kHz?"
]
