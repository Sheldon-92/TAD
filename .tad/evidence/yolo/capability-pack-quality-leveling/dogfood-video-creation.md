# Dogfood Judgment — video-creation pack

Task: 3 人像照片 → 6 秒卡点 lofi 动态视频。

## Verification of key specifics (WebSearch + skill file)

| Claim | Answer | Verdict |
|-------|--------|---------|
| lofi BPM ~70-90 (A1) / 75 within 70-90 (A2) | both | CORRECT (web: 60-90, most-cited 70-90) |
| CapCut 自动踩点 / Beat Sync auto beat markers | A1 | CORRECT — real feature, mobile+desktop, drops beat markers on waveform; NOT on Web (A1 says phone/desktop, consistent) |
| ffmpeg concat 6×1s + scale/crop 1080x1920 + map audio + -shortest | A1 | CORRECT — valid, runnable filter_complex; pix_fmt yuv420p / aac correct |
| HyperFrames = HeyGen open-source, HTML/CSS/GSAP, deterministic seek render via Chrome beginFrame + FFmpeg | A2 | CORRECT — matches HeyGen repo/docs exactly |
| HyperFrames forbids Date.now/Math.random/setInterval (non-determinism breaks seek render) | A2 | CORRECT — seek-driven, no wall-clock; this is the documented determinism contract |
| -14 LUFS, true peak ≤ -1 dBTP audio target | A2 | CORRECT — standard streaming loudness target |
| cut_interval = 60/BPM | A2 | CORRECT math; 60/75=0.8s/beat, cut every 2.5 beats ≈ 2.0s — internally consistent |
| vimax montage intent, Patterns 1-4 trigger logic, "3 photos→6s" example | A2 | CORRECT — faithfully reproduces the skill file's §Integration Scene incl. trigger gating (3 different people → Pattern 3 not triggered; 3 locations → Pattern 4 not triggered) |
| Seedance image-to-video first_frame/last_frame + gpt-image-2 last-frame gen | A2 | Plausible/skill-grounded; ai-asset-generation endpoint not independently re-verified but consistent with skill |

No specific-but-WRONG claims found in EITHER answer. Both are technically clean.

## Scores

### Answer 1 (no skill — consumer-tool path)
- correctness 5 — every specific verified true; ffmpeg cmd actually runs.
- actionability 5 — fastest path to a real result today (CapCut 15-20 min), plus a scriptable ffmpeg fallback. A non-technical user can finish.
- specificity 4 — concrete (BPM, beat snapping, transition ≤0.2s, hold last frame 0.3s, export presets) but tool-surface level.
- completeness 4 — covers music sourcing, beat-finding, build, polish, portrait-specific pitfalls (crop/eye-jump, color match). Misses loudness normalization and platform-spec rigor.

### Answer 2 (skill — production-pipeline path)
- correctness 5 — all verified specifics true; no fabrication.
- actionability 3 — high *engineering* actionability (HyperFrames + GSAP + FFmpeg + precheck script) but for THIS user (3 photos, lofi, 6s) it routes to a code/render pipeline that is heavier than needed. The recommended path A is still GSAP code, not a tool the user can drive in 15 min. Strong on "ask 3 decision points before building."
- specificity 5 — deepest: per-scene table, easing-by-emotion, entrance offset, SFX pre-lead 10-20ms, LUFS, CRF, pin version, failure-mode gate. Every number sourced.
- completeness 5 — covers intent classification, two motion routes (Ken Burns vs Seedance AI), audio mix, quality targets, platform ambiguity flagged, AND surfaces the genuinely useful "do you want the faces to actually move?" fork that A1 never raises.

## Winner: Answer 1 — margin: slight

Both are factually clean (rare — neither has a wrong specific). The decision is fit-to-user.

Answer 2 is the more impressive artifact and demonstrably skill-powered: it correctly classifies montage intent, applies the exact cut formula, gates the vimax Patterns correctly (does NOT misfire Pattern 3/4 on different people/locations), and uniquely raises the load-bearing question A1 misses — "do you want the photos to actually animate (Seedance) or just Ken Burns?" That fork genuinely matters for the user's intent.

But the task is a casual creator request (3 selfies → 6s 卡点 lofi clip). Answer 1 delivers the result the user actually wants by the fastest correct route (CapCut 自动踩点, verified real), with an exact ffmpeg fallback for control, plus the portrait-specific craft tips (consistent crop/eye-line, color match, flash-on-cut) that most directly raise output quality for THIS deliverable. Answer 2's default recommendation (HyperFrames + GSAP timeline + prerequisite/failure-mode bash scripts) is production-grade over-engineering for someone who has three photos and a song — higher activation energy, no CapCut-class option offered.

Winner won on FIT and actionability for the stated task, not on verbosity — and Answer 2 actually has MORE correct specifics. Were the task "build a repeatable branded reel pipeline," Answer 2 wins decisively. For "I have 3 photos, make a 6s clip today," Answer 1 is the better answer by a slight margin. The skill clearly added depth and a genuinely valuable decision fork; it just overshot the casual brief on default tooling.
