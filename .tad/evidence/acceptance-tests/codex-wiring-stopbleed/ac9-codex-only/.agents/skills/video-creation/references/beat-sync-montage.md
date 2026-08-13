# Beat-Sync Montage & Complexity-Tier Routing

> Closes the gap surfaced by the 2026-06-13 dogfood: the pack scored 5/5 on specificity but LOST
> a casual "3 photos + a song → 6s clip" brief because it always routed to a heavyweight
> GSAP/HyperFrames pipeline. This reference adds (a) an explicit **complexity tier** decision so the
> pack picks the right-WEIGHT path, and (b) the **photo-montage beat-sync craft** specifics
> (cut placement in frames, Ken Burns jitter fix, eye-line continuity) that a generalist does NOT emit.
>
> All numbers carry a source URL + retrieval date. Retrieval date for this file: **2026-06-14**.

---

## Tier-0 Decision: pick the WEIGHT of the path BEFORE picking the tool

A montage / beat-sync request can be satisfied at three weights. Choosing the wrong weight is the
#1 quality failure on casual briefs — a code-render pipeline for "3 selfies + a song" is
over-engineering (higher activation energy, no faster, worse fit). Score the request on these axes,
then route:

| Axis | Casual signal | Production signal |
|------|---------------|-------------------|
| Asset count | ≤ ~8 stills/clips | dozens, or recurring batches |
| Reuse | one-off | repeatable/branded pipeline, re-render on data change |
| Determinism need | none ("just make it") | byte-identical re-render, CI, version control |
| Brand system | none | DESIGN.md tokens, brand fonts/colors enforced |
| Editor on hand | user has a phone/CapCut | user wants code they own |

**Routing:**

- **Tier 1 — Consumer tool (DEFAULT for casual one-off).** ≤8 assets, one-off, no determinism/brand
  requirement → recommend **CapCut Beat Sync** (auto beat markers) as the fastest correct path, and
  give an exact **FFmpeg** fallback for users who want a scriptable/headless build. Finish in minutes,
  not a render pipeline. THIS is the tier the dogfood casual brief wanted.
- **Tier 2 — FFmpeg script (headless / no-GUI / batch).** Same casual output but the user is on a
  server, wants a reproducible command, or is batching → the FFmpeg `zoompan` + `xfade` + `concat`
  recipe below. No composition framework.
- **Tier 3 — Composition framework (HyperFrames/Remotion).** Brand system, motion-design rigor,
  determinism, reuse, or per-data re-render → the production pipeline in `references/production.md`
  + `references/visual-design.md`. Only here do the GSAP easing-by-emotion / 17-failure-mode rules apply.

> **Anti-overshoot rule**: do NOT default to Tier 3. Default to Tier 1 for casual briefs and only
> escalate when a production signal above is actually present. State which tier you chose and why.

[Source: dogfood-video-creation.md verdict 2026-06-13 (FIT loss) — internal evidence]

---

## Tier 1 — CapCut Beat Sync (consumer path)

CapCut analyzes the imported track and **auto-drops beat markers along the audio waveform**; you
snap photo/clip cuts to those markers. Two related features:

- **Beat Sync / Beat Detection** — manual+auto beat-marker alignment on the waveform (Audio → Beats → Auto).
- **Auto Cut** — AI auto-trims and syncs footage to a track/beat pattern (Mobile + Desktop; **NOT on CapCut Web** as of 2026 — Web is trim/split only).

Facts (verify before quoting a version to a user — CapCut ships fast and **versions diverge per
platform**: iOS, Android, macOS each version independently, so "CapCut version" is meaningless without
the platform):

- Beat Sync works on **mobile and desktop**; runs on **user-supplied music files in the FREE tier**.
- ⚠️ **The CapCut beat detector is a HEURISTIC FFT peak detector, NOT a music-theory downbeat filter.**
  Mobile "Light → Intense" / desktop "Beats 1 / Beats 2" are **DENSITY** controls (sparser vs. denser
  peak surfacing), not "downbeat-only" toggles. The algorithm **misses soft intros, live drums, swing,
  and syncopation** → expect to manually fix markers. So even on the consumer path, apply the
  cut-on-downbeat / anticipation craft below by hand. [Source: deep-research §(e) — creativelysquared.com, cursa.app, capcut.com/help — retrieved 2026-06-14]
- Do NOT quote an exact desktop build number or "max beats" / sensitivity value — none is documented per-platform (do not invent one).

**Tier-1 workflow for "N photos → beat-synced clip":**
1. Import song → run **Beat Sync (Auto)** to populate beat markers.
2. Place photos; snap each cut to a **downbeat** marker (not every beat — see Cut Placement below).
3. Add a subtle Ken Burns push per photo (CapCut: keyframe scale 1.00→1.05) so no frame is a static JPEG.
4. Export 1080×1920 (9:16) H.264, AAC — respect the safe zone below.

[Source: https://www.capcut.com/help/auto-cut-in-capcut , https://www.capcut.com/explore/beat-sync , https://graphicdesignresource.com/how-to-sync-videos-to-beat-drops-using-capcuts-beat-detection/ , https://bigvu.tv/blog/capcut-free-vs-pro-what-2026s-restructure-actually-gives-you/ — retrieved 2026-06-14]

---

## Tier 2 — FFmpeg headless beat-sync recipe

For a scriptable/headless build of the same casual output (no GUI). Drives the photos with Ken Burns,
crossfades or hard-cuts on the beat, lays the track under, trims to length.

### Cut interval from BPM
`seconds_per_beat = 60 / BPM`. lofi hip-hop is **70–90 BPM** (most-cited; some sources 60–80).
At 75 BPM, 1 beat = 0.8s. **Cut on downbeats** (every 4th beat ≈ 3.2s) for major cuts, or every 2nd
beat for an energetic montage — NOT every beat (that reads frantic).

[Source: https://bpmcalc.com/genres/lo-fi/ , https://www.drumloopai.com/lofi/what-is-the-tempo-of-the-lofi-beat/ — retrieved 2026-06-14]

### Ken Burns per photo (ffmpeg `zoompan`) — with the jitter fix
**Root cause of the jitter (verified):** `zoompan` rounds the x/y pan expressions to integer pixels
per frame at OUTPUT resolution; the up/down rounding changes pan direction frame-to-frame → visible
jiggle on slow zooms. **Documented fix: pre-scale the still to a much higher resolution BEFORE zoompan
(rounding error becomes proportionally tiny), then downscale to output.**

```bash
# 1 photo → 2s (50 frames @ 25fps) gentle zoom-in, prescaled to reduce jitter
ffmpeg -loop 1 -i photo.jpg -filter_complex \
  "scale=8000x4000,zoompan=z='min(zoom+0.0015,1.5)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=50:s=1080x1920:fps=25" \
  -t 2 -pix_fmt yuv420p out_photo.mp4
```
- `scale=8000x4000` first = the jitter mitigation (sub-pixel movement smooths out on the big canvas).
  The Bannerbear/Cerberus public-domain recipes use plain `scale=8000:-1` / `scale=-2:10*ih` with the
  scaler left at ffmpeg's DEFAULT (bicubic) — **do NOT add `flags=lanczos` and claim it's sharper:
  there is no Ken-Burns-specific lanczos-vs-bicubic prescale benchmark (UNVERIFIED).** [Source: bannerbear.com, cerberus zoompan.org]
- ⚠️ **This is a PARTIAL fix, not a cure** — the source says it removes "most of the jitter," and ffmpeg
  bug #4298 notes it "doesn't always have an effect with arbitrary x or y values." The filter-internal
  patch (ffmpeg-devel/256883, float intermediates) was **NEVER merged into mainline**, so the prescale
  workaround is still required on ffmpeg 6.x / 7.x / 8.x. For truly jitter-free Ken Burns, use a real
  NLE or a frame-accurate composition framework (Remotion `interpolate()` / HyperFrames seekable GSAP),
  which do per-frame CSS transforms with no integer-rounding jitter. [Source: deep-research §(c) — datarecoveryunion.com, patchwork.ffmpeg.org zoompan, github FFmpeg vf_zoompan.c git log]
- `zoom+0.0015` = the most-cited working increment; drop to `0.0005` for a very gradual push. `0.002+` reads as a noticeable linear zoom.
- On VIDEO (not still) input use `d=1` and `pzoom` (previous zoom) in the z expression so zoom doesn't reset each frame. `zoompan` rejects z<1 (can't zoom OUT) — use `geq` (100–1000× slower) or an NLE for zoom-out. [Source: deep-research §(c) — ffmpeg 8.0 zoompan docs, creatomate.com]
- `d` = OUTPUT frames per input image (fps × seconds for stills); `s` = output size. No universal "recommended" d/s — project-driven.

[Source: deep-research report §(c) KEN BURNS / zoompan JITTER — datarecoveryunion.com, bannerbear.com, ffmpeg 8.0 docs, patchwork.ffmpeg.org — retrieved 2026-06-14]

### Beat-synced transition (ffmpeg `xfade`)
`xfade` crossfades two clips. `duration` is in seconds (range 0–60, **default 1s**); `offset` is when
the crossfade starts relative to the first input. For a beat-sync montage, keep crossfades SHORT
(0.1–0.2s) or use hard cuts — long crossfades blur the beat hit.

```bash
ffmpeg -i a.mp4 -i b.mp4 -filter_complex \
  "xfade=transition=fade:duration=0.15:offset=1.85" ab.mp4   # cut lands at ~2.0s beat
```
Transition types include `fade` (default), `dissolve`, `wipeleft/right`, `slideup/down`, `circleopen`, `pixelize`.

[Source: https://ottverse.com/crossfade-between-videos-ffmpeg-xfade-filter/ , https://ayosec.github.io/ffmpeg-filters-docs/8.0/Filters/Video/xfade.html — retrieved 2026-06-14]

### Lay the track under + trim
Use the `amix`/`volume` + `loudnorm` patterns in `references/audio-design.md`; trim to the beat grid
with `-shortest` or `-t`. Normalize to **−16 LUFS / −1 dBTP** (pragmatic short-form target — see
§Loudness below for why there is NO single cross-platform number).

---

## Cut Placement: the frame-accurate beat-sync craft (Tier 1 & 2)

These are the specifics a generalist does NOT emit — they decide WHERE in the timeline (down to the
frame) a cut lands relative to the audio beat.

1. **Cut on the downbeat (and phrase boundaries), not every beat.** Major scene cuts land on downbeats
   (every 4th beat); angle/detail cuts on beats 2 & 4; every-beat bursts only in short runs (4–8 beats)
   at a drop. Cutting on every beat reads frantic. A quantitative music-video analysis (ISMIR 2021,
   TransNet shot detection + Madmom downbeats) found bar-level sync in only ~1/5 of studied clips —
   beat-locking is the exception, not the rule. [Source: arxiv.org/pdf/2108.00970 ; beat2cut.com beat-sync guide — retrieved 2026-06-14]
2. **Place the cut 1–2 frames BEFORE the beat (anticipation).** The viewer sees the new shot, THEN
   hears the beat → the hit reads stronger. At 24fps that is ~42–83ms early; 30fps ~33–67ms; 60fps
   ~17–33ms. This offset sits well inside the ITU-R BT.1359-1 AV-sync perceptual window (detectability
   ≈ +45ms audio-leads to −125ms audio-lags). ⚠️ **The "1–2 frame anticipation" figure is PRACTITIONER
   CONVENTION, not a measured psychoacoustic result** — there is no primary music-cognition or NLE study
   that quantifies the editorial-cut offset; the ISMIR study confirms cuts land *before* the downbeat
   ("anticipation") but does not validate the 1–2 frame number. Treat it as a starting point, not fact.
   (Distinct from the audio-pre-lead in `audio-design.md §SFX Pre-Lead`, which leads the VISUAL by
   10–20ms for SFX.) [Source: deep-research §(b) — arxiv.org/pdf/2108.00970, itu.int BT.1359-1; "1–2 frame" flagged UNVERIFIED convention — retrieved 2026-06-14]
3. **Hold-then-cut.** Hold one shot across several beats through a build-up or a beat of silence, then
   cut hard on the next big downbeat. The withheld cut makes the drop land harder than uniform cutting.

> **Editorial dissent (documented):** some editors argue cutting to the beat at all is "lazy editing"
> (Murch's Rule of Six ranks rhythm only 3rd: emotion 51% > story 23% > rhythm 10%), while auto-tools
> (CapCut/OpusClip) default to marking *every* beat. Beat-sync is a tool, not a mandate. [Source: steedfilms.com ; premiumbeat.com on Murch — retrieved 2026-06-14]

> **If you need frame-accurate beat timestamps**, compute them externally — `madmom`
> `DBNDownBeatTrackingProcessor` (v0.16.1) returns beat time in SECONDS + a downbeat flag (col1==1),
> which is what you want for downbeat cuts; `librosa.beat.beat_track` returns FRAME INDICES by default
> (convert via `librosa.frames_to_time`) and has a documented ~20–60ms LATE bias; `aubiotrack` outputs
> seconds directly. Watch frame-rounding: 128 BPM @24fps = 11.25 frames/beat → rounds to 11 → ~3 BPM
> drift; 120 BPM @30fps = exactly 15 frames/beat (no error). [Source: deep-research §(b) — librosa/madmom/aubio docs, librosa issue #1052, bchillmix.com — retrieved 2026-06-14]

---

## Portrait-photo montage continuity (the craft that won the dogfood control)

When montaging multiple portrait stills (different expressions/poses/people), three continuity
defenses prevent the "jump-cut amateur" read. These are judgment rules, not sourced numbers — apply
them per shot:

- **Crop/scale parity.** Keep the subject's head at a consistent height/scale across photos so the
  cut doesn't "jump" the face up/down the frame. Set a target head-position band (e.g. eyes at ~⅓ from
  top) and crop each photo to it before montaging.
- **Eye-line continuity.** Avoid cutting between two photos where the subject's gaze direction flips
  hard left↔right on the beat unless the cut is meant as a punch. Order photos so gaze flows.
- **Color/white-balance match.** Photos shot in different light read as a different video each cut.
  Match white point across stills (the pack's ±500K rule in `visual-design.md §Color temperature`)
  before assembling, or apply one global grade.
- **No static frame.** Every still gets a Ken Burns push (Tier 1 keyframe or Tier 2 `zoompan`) — a
  frozen still in a video context reads as a paused/broken playback (see `visual-design.md §JPEG`).

> A dedicated published guide on portrait-montage eye-line/crop parity was NOT found in 2026-06-14
> research; these are craft heuristics, flagged as such (no fabricated citation).

---

## 9:16 safe zone — exact pixels (1080×1920)

Snap captions/CTA inside the safe zone or the platform UI covers them. The **bottom inset is the #1
generalist error** — it is state-dependent (collapsed vs. expanded description, organic vs. ads).

| Platform | Top | Bottom | Left | Right | Safe area |
|----------|-----|--------|------|-------|-----------|
| **TikTok** | 108px | 320px (370 ads) | 60px | 120px | 900×1492 |
| **Instagram Reels** | 210px | 310px | 0px | 84px | 996×1400 |
| **YouTube Shorts** | 120px | 300px collapsed (360 ads) | 0px | 96px | 984×1500 |
| **Universal union** | — | — | — | — | **900×1400 centered** |

**Rule:** when targeting more than one platform, design captions/CTA inside the **900×1400 centered
union** — it clears all three. For ads, reserve **360–400px** at the bottom (CTA button). The Shorts
bottom inset is disputed (300px collapsed vs. ~575px fully-expanded description) — use 300px organic,
360px ads, and preview with the description expanded before publishing.

[Source: deep-research report §(d) 9:16 SAFE ZONES — postplanify.com/blog/social-media-safe-zones-2026-complete-guide, postlinkapp.com — retrieved 2026-06-14]

---

## Loudness target (all tiers)

> ⚠️ **There is NO single cross-platform LUFS number — "-14 LUFS for TikTok/IG/YouTube" is a myth.**
> The deep-research finding: only **YouTube** has a documented, verifiable target (**-14 LUFS,
> attenuate-only**). **TikTok and Instagram Reels publish no official LUFS figure**; every online
> number for them is a third-party estimate (TikTok estimates alone span -7 to -16 LUFS, with no
> controlled measurement). Do NOT tell a user "-14 LUFS is the TikTok standard."

Pragmatic recommendation for a casual short-form montage (mixed music + maybe voice): normalize to
**−16 LUFS integrated, −1 dBTP true peak** — `loudnorm=I=-16:TP=-1:LRA=11`. This sits under YouTube's
documented -14 attenuate-only target (so you won't be pumped down hard) and near the AES TD1008
mixed-content recommendation (-17). Use **-2 dBTP** if the file will be re-encoded to AAC downstream
(inter-sample peaks can exceed +1 dBTP after lossy encoding). Full documented-vs-estimated per-platform
table: `references/quality.md §Loudness Normalization`.

[Source: deep-research report `.tad/evidence/research/research-engine-for-ai-assisted-short-form-montage-video-productio.md` §(a) LOUDNESS — YouTube [productionadvice.co.uk/stats-for-nerds], TikTok/IG UNVERIFIED [songbrain, Meta Engineering], AES TD1008 [productionadvice.co.uk/td1008] — retrieved 2026-06-14]
