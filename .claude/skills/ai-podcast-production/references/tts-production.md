# TTS Production

> Large-chunk TTS generation with inline denoising and loudness normalization. Grounded in EP1 (Sheldon/VoxCPM2) and EP2 (Colin/VoxCPM2+LoRA). The large-chunk strategy eliminated the volume/timbre instability that plagued EP2 v1's 56 per-sentence segments.

---

## TP1: Large-Chunk Strategy — MANDATORY

**Rule**: Generate TTS in large chunks of 200-350 characters per chunk, organized by chapter/thought unit. Do NOT generate per-sentence.

| Parameter | Value | Rationale |
|---|---|---|
| chunk_size | 200-350 characters | Model maintains consistent tone within chunk |
| chunks_per_episode | ~20 | Covers a 15-25 minute episode |
| post_cut_min_segment | 8 seconds | Cutting to 2s destroys coherence |

**Why**: Each TTS generation call starts from a "cold" state. Per-sentence generation (50+ small segments) means 50+ cold starts, each with random fluctuation in tone, pitch, and volume. Large chunks let the model build and sustain a consistent delivery within each segment.

**Anti-pattern**: Per-sentence TTS generation. EP2 v1 had 56 segments with wildly inconsistent sound. EP2 v2 with 20 large chunks was immediately better.

---

## TP2: Chunk Splitting Strategy

**Rule**: Split the script at natural paragraph/thought boundaries, aiming for 200-350 characters per chunk.

Splitting priority:
1. Chapter/section boundaries (largest natural break)
2. Topic transitions within a chapter
3. Emotional register shifts (analytical → personal, quiet → intense)
4. Hard paragraph breaks in the script

Mark each chunk with an index for later reference: `chunk_00`, `chunk_01`, etc.

**PAUSE_MAP**: Define per-chunk silence durations for emotional transitions. Default inter-segment pause is 0.7s. Emotional transitions get 1.0-1.5s.

```python
PAUSE_MAP = {
    0: 1.0,   # after opening, mood transition
    5: 1.5,   # major topic shift
    12: 1.0,  # personal bridge moment
    18: 1.5,  # before synthesis/conclusion
}
DEFAULT_PAUSE = 0.7  # all other segments
```

---

## TP3: Post-Cut with Silence Detection

**Rule**: After generating large chunks, post-cut using silence detection if individual segments are needed for arrangement.

| Parameter | Value |
|---|---|
| silence_threshold | 0.015 |
| min_segment_length | 8 seconds |

**Anti-pattern**: Cutting to 2-second segments. This destroys the coherence that large-chunk generation achieved. The minimum is 8 seconds.

```python
# Silence detection for post-cutting
def detect_silence_cuts(audio, sr, threshold=0.015, min_seg_sec=8):
    frame_len = int(0.05 * sr)  # 50ms frames
    min_seg_frames = int(min_seg_sec * sr / frame_len)
    # ... energy-based detection
```

---

## TP4: Merged Processing Loop — MANDATORY

**Rule**: TTS generation, denoising, and loudness normalization MUST happen in a single loop iteration per chunk. Never separate them into different cells or steps.

```python
import noisereduce as nr
import soundfile as sf
import pyloudnorm as pyln
import numpy as np

meter = pyln.Meter(48000)  # 48kHz = VoxCPM2 native rate; pyloudnorm impl ITU-R BS.1770-4

# Per-platform integrated-loudness target (LUFS). Do NOT hard-code -16 for all (TP7a).
TARGET_LUFS = {
    "apple_stereo": -16.0,  # Apple Podcasts spec: ~-16 dB LKFS ±1 dB (stereo)
    "apple_mono":   -19.0,  # mono at -19 LUFS sounds as loud as stereo at -16 LUFS
    "spotify":      -14.0,  # Spotify normalizes to -14 LUFS
    "youtube":      -14.0,  # YouTube normalizes to -14 LUFS
    "amazon":       -14.0,  # Amazon Music -14 LUFS
    "google":       -14.0,  # Google -14 LUFS
}
PEAK_CEILING_DBFS = -1.0  # -1 dBFS sample-peak reserve (pyln.normalize.peak = sample-peak, NOT measured dBTP); approximates Apple's -1 dBTP target
target_loudness = TARGET_LUFS["spotify"]  # pick per delivery target; -14 is the multi-platform default

for i, text in enumerate(tqdm(chunks)):
    # 1. Generate
    wav = model.generate(
        text=text,
        prompt_wav_path=ref_wav_path,
        prompt_text=ref_text,
        cfg_value=2.0,
        inference_timesteps=10,
        denoise=False  # use external noisereduce, not built-in
    )
    audio = wav.squeeze().cpu().numpy()

    # 2. Denoise (immediately, same iteration)
    audio = nr.reduce_noise(
        y=audio, sr=48000,
        prop_decrease=0.85,
        stationary=True  # TTS output has no time-varying room noise (see TP7b)
    )

    # 3. Loudness normalize (immediately, same iteration)
    loudness = meter.integrated_loudness(audio)
    audio = pyln.normalize.loudness(audio, loudness, target_loudness)

    # 4. Sample-peak ceiling AFTER loudness (MA8 / TP7a) — lossy encoders do not change
    #    loudness but can clip if headroom is not reserved. Reserve -1 dBFS as a
    #    conservative margin (this is sample-peak, not a measured true-peak/dBTP).
    audio = pyln.normalize.peak(audio, PEAK_CEILING_DBFS)

    # 5. Write (immediately, same iteration)
    sf.write(f"seg_{i:03d}.wav", audio, 48000)
```

**Loudness normalize then peak — order matters**: `pyln.normalize.loudness()` hits the integrated-LUFS target; `pyln.normalize.peak(audio, -1.0)` then caps the **sample peak** at -1 dBFS. Running peak *after* loudness is correct because loudness scaling can push transients above the ceiling. The -1 dBFS reserve is a *conservative headroom margin* against the inter-sample (true-peak) overs that lossy encoders (MP3/AAC) add — but note `normalize.peak` is itself a sample-peak scaler (`np.max(np.abs)`), so it does not *measure* or remove true-peak overs; it only leaves room for them. For an actual dBTP guarantee, post-check with `ffmpeg -af ebur128=peak=true` (see MA8).

**Three failure classes of separation**:
1. **Omission** — forgetting to denoise some segments
2. **Session disconnect** — Colab drops between steps, losing VM state
3. **Mismatch** — applying different parameters to different segments

---

## TP5: Colin Model Loading Gotchas

**Rule**: Colin LoRA model requires two mandatory fixes that Sheldon model does not need.

### Fix 1: Base Model Path Hardcode
`lora_config.json` stores a local cache path (e.g., `/root/.cache/huggingface/hub/...`) as `base_model`. This path is invalid on a fresh Colab VM.

**MUST**: Hardcode the HuggingFace model ID:
```python
# WRONG: uses path from lora_config.json
config = json.load(open("lora_config.json"))
model = VoxCPM.from_pretrained(config["base_model"], ...)

# RIGHT: hardcode HF model ID
model = VoxCPM.from_pretrained("openbmb/VoxCPM2", ...)
```

### Fix 2: Weight File Rename
The trained weight file is named `lora_weights_2000.safetensors` (with step number). VoxCPM2 expects `lora_weights.safetensors`.

**MUST**: Use `shutil.copy2` (not symlink — Google Drive does not support symlinks):
```python
import shutil
shutil.copy2("lora_weights_2000.safetensors", "lora_weights.safetensors")
```

**Future prevention**: When training new models, always save as `lora_weights.safetensors` directly.

---

## TP6: Partial Regeneration for Script Edits

**Rule**: When a script edit affects only one chunk, create a mini TTS notebook that regenerates ONLY that chunk. Do not re-run all TTS.

**Process**:
1. Identify which `chunk_N` was modified
2. Create a mini notebook with: model loading + single chunk generation + denoise + normalize + save to `seg_N_v2.wav`
3. Upload to Drive, replacing only the modified segment file
4. Re-run arrangement notebook (which reads from Drive segment files)

**Anti-pattern**: Re-running all TTS because one paragraph changed. With 20 chunks on A100, full regeneration takes 15-20 minutes. Single chunk takes <1 minute.

---

## TP7: Validated TTS Parameters

| Parameter | Value | Source |
|---|---|---|
| sample_rate | 48000 | VoxCPM2 native rate |
| cfg_value | 2.0 | Classifier-free guidance strength (VoxCPM2 recommended) |
| inference_timesteps | 10 | Diffusion steps (VoxCPM2 recommended) |
| denoise (built-in) | False | Use external noisereduce instead; init with `load_denoiser=False` |
| noisereduce prop_decrease | 0.85 | Noise reduction proportion (1.0 = 100%; default 1.0) — conservative for clean TTS |
| noisereduce stationary | True | Fixed-threshold spectral gating (TTS has no time-varying room noise) |
| target_loudness | per-platform (see TP7a) | NOT a single -16 constant |
| peak_ceiling | -1.0 dBFS (sample-peak) | Conservative reserve approximating Apple's -1 dBTP target; `pyln.normalize.peak` is sample-peak, NOT a dBTP meter |
| LRA target (spoken word) | 5-15 LU | EBU Tech 3342 loudness-range band (see TP7c) |
| lead_in_silence | 1.0 second | Silence before first segment |
| tail_silence | 2.0 seconds | Silence after last segment |
| DEFAULT_PAUSE | 0.7 second | Default inter-segment silence |
| emotional_pause | 1.0-1.5 seconds | At mood shifts (PAUSE_MAP) |

### TP7a: Per-Platform Loudness Targets — MANDATORY (do NOT hard-code -16)

Hard-coding `target_loudness = -16` is correct ONLY for Apple Podcasts stereo and is too quiet for Spotify/YouTube delivery. Encode a per-platform table:

The "Platform peak target" column is each platform's **true-peak (dBTP)** ceiling as published. Our pipeline reserves a **-1 dBFS sample-peak** margin via `pyln.normalize.peak` (a sample-peak scaler — see TP4/MA8), which approximates but does not *measure* these dBTP targets; for an actual dBTP guarantee, post-check with `ffmpeg ebur128=peak=true`.

| Platform | Integrated LUFS | Platform peak target | Note |
|---|---|---|---|
| Apple Podcasts (stereo) | -16 LUFS (±1 dB) | -1 dBTP | Apple spec: precondition to ~-16 dB LKFS, true-peak ≤ -1 dBFS, computed per ITU-R BS.1770-5 |
| Apple Podcasts (mono) | -19 LUFS | -1 dBTP | -19 LUFS mono sounds as loud as -16 LUFS stereo |
| Spotify | -14 LUFS | -1 dBTP | platform normalizes to -14 |
| YouTube | -14 LUFS | -1 dBTP | platform normalizes to -14 |
| Amazon Music | -14 LUFS | -1 dBTP | platform normalizes to -14 |
| Google | -14 LUFS | -1 dBTP | platform normalizes to -14 |
| (contrast) EBU R128 broadcast | -23 LUFS | -1 dBTP | podcast platforms sit 7-9 LU louder than broadcast |

**Default to -14 LUFS** when the delivery platform is unknown (matches Spotify/YouTube/Amazon/Google, only Apple-stereo wants -16). Apple states its loudness/true-peak targets are computed per **ITU-R BS.1770-5**. pyloudnorm, by contrast, implements **BS.1770-4** for `meter.integrated_loudness()` and exposes `meter.loudness_range()` (LRA) + `normalize.loudness()` / `normalize.peak()` — the last being a **sample-peak** scaler (`np.max(np.abs)`), so pyloudnorm provides neither BS.1770-5 nor any true-peak metering.

### TP7b: noisereduce stationary vs non-stationary — choose explicitly

noisereduce (timsainb) is **spectral gating** with two algorithms:
- **stationary=True** — fixed noise threshold across the whole signal. Correct for **clean TTS output** (no time-varying room noise). This is the pack default.
- **stationary=False** — continuously updated threshold. Use when the source is **non-stationary** (e.g., a recorded reference clip with changing background noise).

`prop_decrease` is the proportion of noise reduction (1.0 = 100%, library default 1.0); the pack's **0.85** is a deliberate conservative choice to avoid over-gating TTS into a hollow timbre.

### TP7c: Loudness Range (LRA) acceptance check — EBU Tech 3342

Spoken-word / dialog-heavy content should keep **LRA in the 5-15 LU band** (EBU Tech 3342, supplementing EBU R128). Out-of-band LRA flags a problem: **over-compressed** voice (forbidden by MA11) reads as LRA below 5 LU; under-controlled level swings read as LRA above 15 LU. pyloudnorm's `Meter.loudness_range()` measures LRA per EBU Tech 3342, making this a **runnable acceptance check**, not subjective judgment. (LRA is the one assertion the verifier can fully measure today — true-peak it cannot, see TP7d.) Run `scripts/loudness-check.sh` (TP7d) after final export.

---

## TP8: Dependencies and Installation

```python
# In Colab cell 1:
!pip install voxcpm soundfile numpy tqdm noisereduce pyloudnorm
# huggingface_hub is pre-installed in Colab

from huggingface_hub import snapshot_download
snapshot_download(repo_id="openbmb/VoxCPM2", local_dir="./voxcpm2_model")
```

**Key imports**:
```python
from voxcpm.core import VoxCPM       # NOT VoxCPM2Model
from voxcpm.lora import LoRAConfig
import soundfile as sf
import noisereduce as nr
import pyloudnorm as pyln
import numpy as np
from tqdm import tqdm
```

**CRITICAL**: Use `from voxcpm.core import VoxCPM` (the high-level API), NOT the low-level `VoxCPM2Model.from_local`. The low-level API produces garbage output. See ml-training pack's colab-execution.md Rule 7.

### TP8a: VoxCPM2 model facts and voice-model escape hatches (tool freshness)

**VoxCPM2 (OpenBMB)**: 2B-param, 48kHz, 30-language, **Apache-2.0**. Latest release **v2.0.3 (2026-05-11)** added fine-tuning validation, runtime stability, and streaming improvements. Recommended inference params match TP7: `cfg_value=2.0` + `inference_timesteps=10`. Initialize with `load_denoiser=False` (the pack uses external noisereduce, TP4).

**Voice-model selection escape hatches** (when VoxCPM2 is not the right fit — give a default + alternatives, never force one tool):

| Model | License | When to use |
|---|---|---|
| **VoxCPM2** | Apache-2.0 | Default — 48kHz, 30-lang, LoRA fine-tune support. Only Apache/MIT-class option here that is safe for a monetized show |
| **Kokoro-82M** | Apache-2.0 | Lightweight / fast; low-resource inference. Commercial-safe |
| **XTTS-v2** | ⚠️ **Coqui CPML (NON-COMMERCIAL)** | Research/personal ONLY. CPML permits non-commercial use; Coqui shut down Jan 2024 so **no commercial-license path remains** — do NOT ship in a monetized podcast |
| **F5-TTS** | ⚠️ **CC-BY-NC 4.0 (non-commercial)** | Research/personal ONLY — do NOT ship in a commercial podcast (license violation) |

**MUST** flag BOTH F5-TTS (CC-BY-NC 4.0) and XTTS-v2 (Coqui CPML, non-commercial, no commercial path post-shutdown) as non-commercial before recommending either for a monetized show. For commercial podcasts, default to **VoxCPM2** or **Kokoro-82M** (both Apache-2.0).

---

## TP9: Concatenation and Export

After all chunks are generated:
```python
# Concatenate with pauses
full_audio = np.zeros(int(1.0 * 48000))  # 1s lead-in silence
for i in range(num_chunks):
    seg = sf.read(f"seg_{i:03d}.wav")[0]
    full_audio = np.concatenate([full_audio, seg])
    pause = PAUSE_MAP.get(i, DEFAULT_PAUSE)
    full_audio = np.concatenate([full_audio, np.zeros(int(pause * 48000))])
full_audio = np.concatenate([full_audio, np.zeros(int(2.0 * 48000))])  # 2s tail

sf.write("podcast_voice.wav", full_audio, 48000)
```

Save to Google Drive AND trigger browser download as backup:
```python
import shutil
from google.colab import files
shutil.copy("podcast_voice.wav", "/content/drive/MyDrive/podcast/podcast_voice.wav")
files.download("podcast_voice.wav")
```

---

## Decision Tree: TTS Strategy

```
Is this a full new episode?
├── YES → Use large-chunk strategy (TP1-TP4)
│   ├── Split script into 20 chunks of 200-350 chars (TP2)
│   ├── Generate + denoise + normalize in merged loop (TP4)
│   ├── Post-cut with silence detection if needed (TP3)
│   └── Concatenate with PAUSE_MAP (TP9)
├── NO, partial script edit → Use partial regeneration (TP6)
│   ├── Identify modified chunk_N
│   ├── Create mini notebook for single chunk
│   └── Replace only the modified segment file
└── NO, arrangement-only change → Skip TTS entirely
    └── Re-run arrangement notebook with existing segments
```

---

## TP7d: Runnable Loudness/True-Peak/LRA Verifier

Do NOT punt loudness/peak/LRA judgment to the agent — run `scripts/loudness-check.sh <final.wav> [platform]`. Using pyloudnorm it asserts: integrated LUFS within ±1 LU of the per-platform target (TP7a) and LRA in the 5-15 LU band (TP7c) — both measured. For the peak ceiling it measures the **sample peak** against -1 dBFS as a conservative lower-bound proxy (pyloudnorm has no true-peak meter); the script labels this honestly and does NOT claim a measured dBTP. Exit 0 = PASS, exit 1 = out of spec. If a true dBTP guarantee is required, additionally run `ffmpeg -i <final.wav> -af ebur128=peak=true -f null -` and confirm reported true-peak ≤ -1 dBFS.

---

## Sources

- Per-platform loudness targets (-16 Apple-stereo / -19 Apple-mono / -14 Spotify·YouTube·Amazon·Google): https://www.criticallisteninglab.com/en/learn/loudness/podcast (retrieved 2026-06-13)
- Apple ~-16 dB LKFS ±1 dB + true-peak ≤ -1 dB FS, computed per ITU-R BS.1770-5 (Apple's published targets): https://podcasters.apple.com/support/893-audio-requirements (retrieved 2026-06-13)
- pyloudnorm: BS.1770-4 integrated loudness via `Meter.integrated_loudness()`, LRA via `Meter.loudness_range()` (EBU Tech 3342); `normalize.peak()` is a SAMPLE-peak scaler (`np.max(np.abs(data))`, no oversampling) — NO true-peak meter, NOT BS.1770-5: https://github.com/csteinmetz1/pyloudnorm/blob/master/pyloudnorm/normalize.py (retrieved 2026-06-13)
- True-peak (dBTP) requires an oversampling meter, e.g. ffmpeg `ebur128=peak=true`: https://ffmpeg.org/ffmpeg-filters.html#ebur128 (retrieved 2026-06-13)
- XTTS-v2 Coqui Public Model License = non-commercial; Coqui shut down Jan 2024 (no commercial-license path): https://huggingface.co/coqui/XTTS-v2/blob/main/LICENSE.txt (retrieved 2026-06-13)
- EBU Tech 3342 Loudness Range (LRA) 5-15 LU spoken-word band: https://tech.ebu.ch/docs/tech/tech3342.pdf (retrieved 2026-06-13)
- VoxCPM2 (OpenBMB) 2B / 48kHz / 30-lang / Apache-2.0 / v2.0.3 2026-05-11 / cfg_value 2.0 / load_denoiser flag: https://github.com/OpenBMB/VoxCPM (retrieved 2026-06-13)
- noisereduce (timsainb) stationary vs non-stationary spectral gating, prop_decrease semantics: https://github.com/timsainb/noisereduce (retrieved 2026-06-13)
- Voice-model alternatives (Kokoro-82M, XTTS-v2, F5-TTS license): https://github.com/wildminder/awesome-ai-voice (retrieved 2026-06-13)
