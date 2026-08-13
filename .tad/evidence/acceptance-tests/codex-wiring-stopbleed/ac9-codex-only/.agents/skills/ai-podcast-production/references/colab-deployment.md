# Colab Deployment

> Notebook deployment patterns for podcast production on Google Colab. Two notebooks: TTS (requires A100 GPU) and arrangement (no GPU needed). Grounded in 2 episodes of production experience and lessons from ml-training pack's colab-execution.md.

---

## CD1: Two-Notebook Architecture — MANDATORY

**Rule**: Split production into two separate notebooks. TTS requires A100 GPU; arrangement does NOT need GPU. Running arrangement on a GPU runtime wastes quota.

| Notebook | GPU Required | Purpose | Runtime |
|---|---|---|---|
| `podcast_tts_v{N}.ipynb` | A100 (mandatory) | Voice generation + denoise + normalize | 15-25 min |
| `podcast_arrange_v{N}.ipynb` | None (CPU) | BGM loading + envelope ducking + mixing | 2-5 min |

**Workflow**:
1. Upload and run TTS notebook on A100 runtime → saves segment WAVs to Drive
2. Disconnect GPU runtime (save quota)
3. Upload and run arrangement notebook on CPU runtime → reads segments from Drive, produces final WAV
4. If arrangement needs tweaking, iterate on CPU notebook only (free)

**Anti-pattern**: Running arrangement on GPU runtime "because it is already connected." This burns Colab GPU quota on CPU-only work.

---

## CD2: Self-Contained Notebooks — MANDATORY

**Rule**: Every notebook must be completely self-contained. Never ask users to paste code into cells.

**Why**: Pasting code caused 3 documented errors:
1. User accidentally overwrites adjacent cells
2. Variables defined in paste context but undefined in notebook context
3. Parameter names in pasted code do not match notebook variable names

**Requirements for a self-contained notebook**:
- All imports in cell 1
- All configuration (paths, parameters) in cell 2
- All function definitions in cell 3
- Execution cells clearly numbered and documented
- No external dependencies beyond pip-installable packages
- Version in filename: `podcast_tts_v2.ipynb`, `podcast_arrange_FINAL.ipynb`

**When modifying**: Always upload a complete new notebook with incremented version. Never give "paste this into cell N" instructions.

---

## CD3: Drive Upload Format

**Rule**: Upload notebooks to Google Drive using `textContent` + `application/json` + `disableConversionToGoogleType`. Do NOT use base64 (it truncates the notebook content).

```python
# Correct Drive upload pattern for notebooks
from google.colab import drive
import json

# Method 1: Direct file write to mounted Drive
drive.mount('/content/drive')
with open('/content/drive/MyDrive/podcast/notebook.ipynb', 'w') as f:
    json.dump(notebook_dict, f, ensure_ascii=False, indent=2)

# Method 2: Drive API upload (from Claude Code via MCP)
# Use: textContent + application/json + disableConversionToGoogleType=true
# Do NOT use: base64 encoding (truncates)
```

---

## CD4: Drive Mount Recovery

**Rule**: Drive mount occasionally times out. The fix is always the same: disconnect and delete runtime, then retry.

**Steps**:
1. In Colab menu: Runtime → Disconnect and delete runtime
2. Wait 10 seconds
3. Reconnect to a new runtime
4. Re-run drive.mount('/content/drive')

**Anti-pattern**: Trying to fix mount timeout by running `drive.mount()` again in the same runtime. Once the runtime is stuck, only a full reset fixes it.

---

## CD5: Notebook Cell Structure for TTS

```
Cell 1: Environment Setup
  - !pip install voxcpm soundfile numpy tqdm noisereduce pyloudnorm
  - Import all packages
  - Mount Google Drive

Cell 2: Configuration
  - MODEL_PATH, LORA_PATH, REF_WAV, REF_TEXT
  - CHUNK_SIZE, PAUSE_MAP, TARGET_LOUDNESS
  - OUTPUT_DIR on Drive

Cell 3: Model Loading
  - snapshot_download (if needed)
  - Colin fixes (TP5): hardcode base_model, copy weight file
  - VoxCPM.from_pretrained with LoRA config

Cell 4: Script Data
  - chunks = ["chunk_00 text...", "chunk_01 text...", ...]
  - All text embedded directly in the notebook (not loaded from file)

Cell 5: Generate + Denoise + Normalize (merged loop)
  - for i, text in enumerate(tqdm(chunks)):
      generate → squeeze → nr.reduce_noise → pyln.normalize → sf.write

Cell 6: Concatenate + Export
  - Load all segments, concatenate with PAUSE_MAP gaps
  - Save to Drive + trigger download

Cell 7: Verification
  - Print total duration, segment count, file sizes
  - Play a sample segment inline
```

---

## CD6: Notebook Cell Structure for Arrangement

```
Cell 1: Environment Setup
  - !pip install soundfile numpy pyloudnorm
  - Import packages (no voxcpm needed)
  - Mount Google Drive

Cell 2: Configuration
  - VOICE_PATH, BGM_A_PATH, BGM_B_PATH (all on Drive)
  - BGM_MIN, BGM_MAX, ATTACK_MS, RELEASE_MS, LOOK_AHEAD
  - FADE_IN, FADE_OUT, OPENING_SOLO, ENDING_SOLO
  - CHAPTER_BOUNDARIES (segment indices where track switches)

Cell 3: Function Definitions
  - envelope_follower()
  - log_fade()
  - get_bgm_chunk()
  - resample_if_needed()
  - load_audio() (with stereo→mono conversion)

Cell 4: Load Audio
  - Load voice WAV from Drive
  - Load BGM WAVs from Drive
  - Resample BGMs to match voice sample rate

Cell 5: Compute Ducking Envelope
  - Envelope follower on voice
  - Normalize envelope
  - Apply look-ahead shift
  - Compute BGM volume curve

Cell 6: Build BGM Bed
  - Dual-track switching at chapter boundaries
  - BGM looping where needed
  - Apply volume curve
  - Apply head/tail fades

Cell 7: Mix + Export
  - final = voice + bgm_arranged
  - Anti-clipping normalization
  - Save to Drive + trigger download

Cell 8: Verification
  - Print total duration, peak level, LUFS measurement
  - Play first 30 seconds inline
```

---

## CD7: Session Management

**Rules from ml-training pack** (colab-execution.md) that apply to podcast production:

1. **Account unification** (BLOCKING): Verify MCP Drive + CLI + browser all use the same Google account
2. **Drive-first storage**: ALL artifacts go to Drive, never VM-local only
3. **CLI for prep (<10 min), browser for generation (>10 min)**: TTS generation takes 15-25 min → MUST use browser
4. **Never CLI while training/generating**: `colab new` from CLI resets browser runtime, losing all VM data

---

## CD8: Versioning Convention

| Artifact | Naming | Location |
|---|---|---|
| TTS notebook | `podcast_tts_ep{N}_v{M}.ipynb` | Drive: `/podcast/notebooks/` |
| Arrangement notebook | `podcast_arrange_ep{N}_v{M}.ipynb` | Drive: `/podcast/notebooks/` |
| Voice segments | `seg_{NNN}.wav` | Drive: `/podcast/ep{N}/segments/` |
| Full voice track | `podcast_voice_ep{N}.wav` | Drive: `/podcast/ep{N}/` |
| BGM tracks | `bgm_A.wav`, `bgm_B.wav` | Drive: `/podcast/ep{N}/bgm/` |
| Final arranged audio | `podcast_ep{N}_FINAL.wav` | Drive: `/podcast/ep{N}/` |
| Show notes | `show_notes_ep{N}.md` | Drive: `/podcast/ep{N}/` |

**Version increments**:
- `v1` → `v2`: major change (new chunking strategy, new BGM)
- `v2` → `v2.1`: minor change (parameter tweak, single chunk re-record)
- `vN` → `FINAL`: human approval of the episode

---

## Decision Tree: Deployment

```
What needs to be deployed?
├── New full episode
│   ├── Create TTS notebook (CD5) with A100 runtime
│   ├── Create arrangement notebook (CD6) with CPU runtime
│   └── Follow versioning (CD8)
├── Script edit (1-2 chunks changed)
│   ├── Create mini TTS notebook for modified chunks only
│   ├── Run on A100, save modified segments to Drive
│   └── Re-run existing arrangement notebook (no GPU needed)
├── Arrangement parameter tweak
│   ├── Edit arrangement notebook configuration cell only
│   ├── Upload as new version (v2.1, etc.)
│   └── Run on CPU runtime (no GPU needed)
└── New BGM tracks
    ├── Download via yt-dlp in Colab (MS5)
    ├── Save to Drive BGM directory
    └── Update arrangement notebook BGM paths + re-run
```
