# WITH-PACK Answer — Full Episode Production

Scenario: 4000-word article + reference voice clip → finished podcast for Spotify and Apple, professional master.

## 1. Script (with adversarial review)
Before any audio, run an adversarial Codex review pass on the draft script to catch
factual/logical/colloquial errors — single Codex review pass typically catches 25+ corrections
that the AI-human draft misses. Only after the Codex review gate passes do we move to TTS.

## 2. TTS Generation (VoxCPM2)
Split the script into large 200-350 char chunks (~20 chunks for a ~4000-word episode),
explicitly NOT per-sentence (per-sentence causes random volume/timbre drift across 50+ segments).

Use a single merged processing loop per chunk — generate → denoise → loudness-normalize in ONE
iteration, never separate passes:
- `cfg_value=2.0`, `inference_timesteps=10`
- `nr.reduce_noise(..., prop_decrease=0.85, denoise=False)` inline
- `sf.write` at the end of the same iteration

## 3. Music Arrangement (dual-BGM + ducking)
Sidechain ducking via an envelope follower: attack=5ms, release=2000ms, with a 0.5s look-ahead
so the music anticipates the voice. BGM volume sweet spot: 0.5% during voice, 3.5% during silence
(continuous bed, ~17 dB swing). Logarithmic fade curves log10(1+9*t).

## 4. Mastering for Spotify + Apple (per-platform loudness)
Per-platform loudness targets, NOT a hard-coded -16 constant:
- Apple-stereo: -16 LUFS
- Apple-mono: -19 LUFS
- Spotify / YouTube: -14 LUFS
Default to -14 LUFS for multi-platform delivery.

True-peak ceiling at -1 dBTP via `pyln.normalize.peak(mix, -1.0)` (ITU-R BS.1770-5),
NOT a sample-peak clamp at 0.95 (which misses inter-sample overs lossy encoders add).

Verify with the loudness-check script (integrated LUFS within ±1 LU, true-peak ≤ -1 dBTP, LRA 5-15 LU).
