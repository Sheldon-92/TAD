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

meter = pyln.Meter(48000)  # 48kHz = VoxCPM2 native rate
target_loudness = -16  # LUFS, broadcast standard

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
        stationary=True
    )

    # 3. Loudness normalize (immediately, same iteration)
    loudness = meter.integrated_loudness(audio)
    audio = pyln.normalize.loudness(audio, loudness, target_loudness)

    # 4. Write (immediately, same iteration)
    sf.write(f"seg_{i:03d}.wav", audio, 48000)
```

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
| cfg_value | 2.0 | Classifier-free guidance strength |
| inference_timesteps | 10 | Diffusion steps |
| denoise (built-in) | False | Use external noisereduce instead |
| noisereduce prop_decrease | 0.85 | Noise reduction strength |
| noisereduce stationary | True | Stationary noise assumption for TTS output |
| target_loudness | -16 LUFS | Broadcast standard |
| lead_in_silence | 1.0 second | Silence before first segment |
| tail_silence | 2.0 seconds | Silence after last segment |
| DEFAULT_PAUSE | 0.7 second | Default inter-segment silence |
| emotional_pause | 1.0-1.5 seconds | At mood shifts (PAUSE_MAP) |

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
