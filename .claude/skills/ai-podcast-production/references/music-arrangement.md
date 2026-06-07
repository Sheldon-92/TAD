# Music Arrangement

> Dynamic voice-following arrangement with envelope follower ducking, look-ahead, logarithmic fade curves, and head/tail fades. The FINAL/PRO model after 10+ iterations across 2 episodes. Supersedes v1 (overlay), v2 (hard-cut), v3 (organic breathing), v4 (gap-only breathing).

---

## Iteration History (Context for Why These Rules Exist)

| Version | Approach | Result |
|---|---|---|
| v1 | Overlay: BGM underneath voice with cue-based volume | Cues too mechanical |
| v2 | Hard-cut: music only in gaps, alternating | Jarring transitions |
| v3 | Crossfade: organic breathing, music in gaps only | "Vacuum feel" during voice |
| v3.1 | v3 + new tracks + longer segments | Better but still hollow |
| v4 | Gap breathing: BGM rises only in gaps | Not enough continuous presence |
| **FINAL/PRO** | **Dynamic voice-following + continuous bed** | **Natural, professional** |

The FINAL model works because BGM is ALWAYS present (continuous bed), but its volume dynamically follows voice energy in real time.

---

## MA1: Envelope Follower — Core Algorithm

**Rule**: Use an envelope follower with attack=5ms, release=2000ms for sidechain ducking. This is the DAW-standard algorithm and sounds 10x more natural than compute_energy + linear inversion.

```python
def envelope_follower(signal, sr, attack_ms=5, release_ms=2000):
    """DAW-standard envelope follower for sidechain ducking."""
    T = 1.0 / sr
    attack_coeff = 1 - np.exp(-2.2 * T / (attack_ms / 1000))
    release_coeff = 1 - np.exp(-2.2 * T / (release_ms / 1000))

    envelope = np.zeros(len(signal))
    env = 0.0
    for i in range(len(signal)):
        sample = abs(signal[i])
        if sample > env:
            env += attack_coeff * (sample - env)  # fast attack
        else:
            env += release_coeff * (sample - env)  # slow release
        envelope[i] = env
    return envelope
```

| Parameter | Value | Rationale |
|---|---|---|
| attack_ms | 5 | Fast response to voice onset |
| release_ms | 2000 | Slow BGM recovery = natural breathing |
| attack_coeff formula | `1 - exp(-2.2 * T / (attack_ms/1000))` | Standard RC circuit model |

**Why attack=5ms**: BGM ducks almost instantly when voice starts. Listener never hears BGM and voice at similar volumes.

**Why release=2000ms**: When voice pauses, BGM rises slowly over 2 seconds. This creates the "breathing" effect — music gently fills the space rather than snapping up.

---

## MA2: Per-Sample vs Downsampled Computation

**Rule**: The envelope follower is a per-sample loop and does NOT use np.convolve. It is safe for 48kHz long audio.

However, if you need a separate energy envelope for other purposes (e.g., logging, visualization), ALWAYS downsample first:

```python
# SAFE: envelope follower (per-sample loop, no convolve)
env = envelope_follower(voice_audio, sr=48000)

# DANGEROUS: np.convolve on full-resolution audio
# 48kHz x 13min = 39M samples, large window = HANG
# energy = np.convolve(voice_audio**2, window, 'same')  # DO NOT DO THIS

# SAFE: downsample first for energy analysis
hop = int(0.1 * sr)  # 100ms resolution
energy_ds = np.array([
    np.sqrt(np.mean(voice_audio[i:i+hop]**2))
    for i in range(0, len(voice_audio), hop)
])
# Smooth with small window at low resolution
energy_smooth = np.convolve(energy_ds, np.ones(10)/10, 'same')
# Interpolate back to full resolution
energy_full = np.interp(
    np.arange(len(voice_audio)),
    np.linspace(0, len(voice_audio)-1, len(energy_ds)),
    energy_smooth
)
```

| Parameter | Value |
|---|---|
| energy_downsample_resolution | 100ms per point |
| energy_smooth_window | 10 points (= 1 second at 100ms resolution) |
| interpolation method | np.interp (linear) |

---

## MA3: Look-Ahead Ducking — MANDATORY

**Rule**: Apply 0.5 second look-ahead so music "anticipates" incoming voice. For offline systems (podcast post-production), simply shift the envelope forward.

```python
look_ahead_sec = 0.5
shift = int(look_ahead_sec * sr)

# Shift envelope forward: BGM ducks BEFORE voice arrives
shifted_env = np.zeros_like(envelope)
shifted_env[:len(envelope)-shift] = envelope[shift:]
# Last 0.5s keeps the tail value
shifted_env[len(envelope)-shift:] = envelope[-1]
```

**Why this matters**: Without look-ahead, there is a brief moment at the start of each voice phrase where BGM is still loud. The listener hears "BGM then voice" rather than "voice emerging from bed." Look-ahead eliminates this transient.

---

## MA4: Logarithmic Fade Curves — MANDATORY

**Rule**: Use `log10(1 + 9*t)` for all volume transitions. Linear linspace sounds unnatural because human hearing is logarithmic (Weber-Fechner law).

```python
def log_fade(length, direction='in'):
    """Logarithmic fade matching human hearing perception."""
    t = np.linspace(0, 1, length)
    curve = np.log10(1 + 9 * t)  # 0 → 1, logarithmic
    if direction == 'out':
        curve = curve[::-1]
    return curve
```

| Fade Type | Linear | Logarithmic |
|---|---|---|
| Perceived at 50% point | "already almost full volume" | "naturally halfway there" |
| Perceived at 10% point | "barely started" | "clearly beginning" |
| Overall impression | Abrupt jump then plateau | Smooth, natural arc |

---

## MA5: BGM Volume Sweet Spot — Validated Parameters

**Rule**: BGM volume during voice = 0.5% (nearly inaudible). BGM volume during silence = 3.5% (gentle). These values are the validated sweet spot after 10+ iterations.

| Parameter | Value | Too Low | Too High |
|---|---|---|---|
| BGM_MIN (during voice) | 0.005 (0.5%) | N/A — lower is fine | 1% = noticeable |
| BGM_MAX (during silence) | 0.035 (3.5%) | 1% = too quiet, no presence | 8% = distracting |

**Volume mapping from envelope**:
```python
# envelope is 0-1 (normalized voice energy from envelope follower)
# When voice is loud (envelope→1): BGM → BGM_MIN (0.5%)
# When voice is quiet (envelope→0): BGM → BGM_MAX (3.5%)
BGM_MIN = 0.005
BGM_MAX = 0.035

bgm_volume = BGM_MIN + (BGM_MAX - BGM_MIN) * (1 - shifted_env_normalized)
bgm_arranged = bgm_raw * bgm_volume
```

---

## MA6: Head/Tail Fades — MANDATORY

**Rule**: Every episode needs opening and ending fades. Without them, the show sounds like a switch being flipped on/off.

### Opening
1. **8 seconds** of BGM solo at BGM_MAX volume (music sets the mood before voice)
2. **6 seconds** of fade-in from silence to BGM_MAX (music "appears" gradually)
3. Total: first 14 seconds are music-only

### Ending
1. **15 seconds** of BGM solo after last voice segment (music carries the listener out)
2. **10 seconds** of fade-out from BGM_MAX to silence (music "disappears" gradually)
3. Total: last 25 seconds are music-only

```python
# Opening fade
fade_in_len = int(6 * sr)
opening_solo_len = int(8 * sr)
bgm_track[:fade_in_len] *= log_fade(fade_in_len, 'in')

# Ending fade
fade_out_len = int(10 * sr)
bgm_track[-fade_out_len:] *= log_fade(fade_out_len, 'out')
```

**Anti-pattern**: Starting the episode with voice immediately over BGM. The opening solo establishes the sonic environment and gives the listener a moment to settle in.

---

## MA7: Inter-Segment Gaps

**Rule**: Insert silence gaps between voice segments for natural breathing room.

| Gap Type | Duration | Where |
|---|---|---|
| Intra-chunk gap | 1.5 seconds | Between segments within the same chapter |
| Inter-chapter gap | 2.5 seconds | Between different chapters/major topic shifts |

During gaps, BGM rises to BGM_MAX (3.5%) per the envelope follower's natural release behavior (2s release time approximately matches the gap duration).

---

## MA8: Anti-Clipping Normalization

**Rule**: After mixing voice + BGM, normalize to prevent clipping.

```python
peak = np.max(np.abs(final_mix))
if peak > 0.95:
    final_mix = final_mix / peak * 0.95
```

Peak cap at 0.95 (not 1.0) to leave headroom for format conversion.

---

## MA9: BGM Looping

**Rule**: If BGM track is shorter than the episode, loop seamlessly using modular offset.

```python
def get_bgm_chunk(bgm, offset, length):
    """Extract BGM chunk with seamless looping."""
    result = np.zeros(length)
    pos = 0
    while pos < length:
        bgm_offset = (offset + pos) % len(bgm)
        chunk_len = min(length - pos, len(bgm) - bgm_offset)
        result[pos:pos+chunk_len] = bgm[bgm_offset:bgm_offset+chunk_len]
        pos += chunk_len
    return result
```

---

## MA10: Dual-BGM Track Switching

**Rule**: When using two BGM tracks (MS2), switch at chapter boundaries. Apply crossfade at the switch point.

```python
# At chapter boundary, crossfade between tracks
crossfade_len = int(2.0 * sr)  # 2 second crossfade
fade_out = log_fade(crossfade_len, 'out')
fade_in = log_fade(crossfade_len, 'in')

# Overlap region
bgm_a_end = bgm_a[-crossfade_len:] * fade_out
bgm_b_start = bgm_b[:crossfade_len] * fade_in
crossfaded = bgm_a_end + bgm_b_start
```

---

## MA11: Voice-Only Processing Rule

**Rule**: Do NOT over-process the voice track. Voice should remain as TTS original output after denoise + loudness normalization only.

Forbidden voice processing:
- `soft_limit()` — compresses tail decay, introduces artifacts
- Volume scaling (e.g., `* 0.85`) — unnecessary if loudness normalized
- Dynamic compression — TTS output does not need it
- Any limiter/compressor after denoise + normalize

**Only** adjust BGM volume to fit voice. Never adjust voice to fit BGM.

---

## Complete Arrangement Pipeline

```python
# 1. Load audio
voice, sr = sf.read("podcast_voice.wav")
bgm_a, bgm_sr = sf.read("bgm_A.wav")
bgm_b, bgm_sr_b = sf.read("bgm_B.wav")

# 2. Resample BGM to match voice sample rate
if bgm_sr != sr:
    bgm_a = np.interp(
        np.linspace(0, len(bgm_a)-1, int(len(bgm_a)*sr/bgm_sr)),
        np.arange(len(bgm_a)), bgm_a
    )
# (same for bgm_b)

# 3. Compute voice envelope
env = envelope_follower(voice, sr, attack_ms=5, release_ms=2000)

# 4. Normalize envelope to 0-1
env_norm = env / (np.max(env) + 1e-8)

# 5. Apply look-ahead
shift = int(0.5 * sr)
shifted = np.zeros_like(env_norm)
shifted[:len(env_norm)-shift] = env_norm[shift:]
shifted[len(env_norm)-shift:] = env_norm[-1]

# 6. Compute BGM volume curve
bgm_vol = BGM_MIN + (BGM_MAX - BGM_MIN) * (1 - shifted)

# 7. Apply to BGM (with looping and dual-track switching)
bgm_bed = build_bgm_bed(bgm_a, bgm_b, len(voice), chapter_boundaries)
bgm_arranged = bgm_bed * bgm_vol

# 8. Apply head/tail fades
apply_head_fade(bgm_arranged, sr, solo=8, fade=6)
apply_tail_fade(bgm_arranged, sr, solo=15, fade=10)

# 9. Mix
final = voice + bgm_arranged

# 10. Anti-clipping
peak = np.max(np.abs(final))
if peak > 0.95:
    final = final / peak * 0.95

# 11. Export
sf.write("podcast_final.wav", final, sr)
```

---

## Decision Tree: Arrangement Approach

```
Is voice audio already generated?
├── NO → Go to tts-production.md first
└── YES
    ├── Are BGM tracks selected?
    │   ├── NO → Go to music-selection.md first
    │   └── YES → Proceed with arrangement
    │       ├── Full episode arrangement
    │       │   ├── Load voice + BGMs
    │       │   ├── Compute envelope follower (MA1)
    │       │   ├── Apply look-ahead (MA3)
    │       │   ├── Map to BGM volume (MA5)
    │       │   ├── Apply dual-track switching (MA10)
    │       │   ├── Apply head/tail fades (MA6)
    │       │   ├── Mix + anti-clip (MA8)
    │       │   └── Export
    │       └── Arrangement parameter tweak
    │           ├── Volume too loud/quiet → Adjust BGM_MIN/BGM_MAX (MA5)
    │           ├── Transitions too abrupt → Increase release_ms (MA1)
    │           ├── Music appears too late → Increase look_ahead (MA3)
    │           └── Fades too short/long → Adjust head/tail params (MA6)
```
