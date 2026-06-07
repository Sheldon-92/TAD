# Music Selection

> BGM selection methodology for podcast production. The core insight: atmosphere > melody. Melodic BGM competes with voice. Grounded in EP1 (3 tracks tried before finding the right one) and EP2 (structured audition workflow, first attempt).

---

## MS1: Atmosphere Over Melody — First Principle

**Rule**: For podcast BGM, the sparser the notes, the better. Melody competes with voice content.

| BGM Type | Podcast Fit | Why |
|---|---|---|
| Ambient/drone | Excellent | No melodic line to compete with voice |
| Sparse piano/guitar | Good | Few notes, mostly atmosphere |
| Classical chamber | Mediocre | Melody pulls attention periodically |
| Full orchestral | Poor | Too much happening |
| Pop/rock instrumental | Bad | Rhythm + melody overwhelm voice |

**EP1 lesson**: An erhu track with prominent melody was distracting despite being culturally appropriate. The replacement ambient track worked immediately.

**Anti-pattern**: Choosing BGM because it matches the cultural theme of the episode content. Cultural appropriateness is secondary to sparseness. An ambient track from any tradition beats a melodic track from the "right" tradition.

---

## MS2: Dual-Track Strategy — MANDATORY for Episodes >10 Minutes

**Rule**: Use two BGM tracks alternating by narrative chapter. Single-track looped for 13+ minutes causes listener fatigue.

**Selection criteria for the pair**:
- Similar overall mood (both contemplative, or both atmospheric)
- Different emotional texture (one ethereal/floating, one grounded/warm)
- Compatible key/tempo (listener should not notice the switch as jarring)
- Both must pass the sparseness test (MS1)

**Alternation pattern**:
- Track A for chapters 1-2 (introduction, first work analysis)
- Track B for chapters 3-4 (personal bridge, second work analysis)
- Track A for chapter 5 (synthesis/conclusion)
- Or: alternate every 2-3 minutes of content

The switch happens at chapter boundaries where the listener expects a change in register.

---

## MS3: Audition Workflow

**Rule**: Follow the structured audition process. Do not blindly pick tracks.

### Step-by-Step

1. **Search**: Find 3 no-copyright candidates matching the episode mood
   - Search terms: "ambient no copyright", "atmospheric background music", "[mood] royalty free"
   - Sources: YouTube Audio Library, Free Music Archive, Incompetech, Pixabay Music
   - Filter: tracks 3-8 minutes long (shorter tracks loop more smoothly)

2. **Download**: Use yt-dlp directly in Colab (not on local machine)
   ```bash
   !pip install yt-dlp
   !yt-dlp -x --audio-format wav -o "bgm_candidate_%(autonumber)s.wav" "URL1" "URL2" "URL3"
   ```

3. **Audition**: Listen to 30 seconds of each candidate
   - Listen at the volume level it will be used (3.5% — very quiet)
   - Ask: "Does this have a melody line that would fight with speech?"
   - Ask: "After 30 seconds, am I aware of the music or has it become invisible?"
   - The best BGM is the one you stop noticing

4. **Select 2**: Pick the best pair for dual-track alternation
   - If all 3 are good, pick the two most different from each other
   - If only 1 is good, search for 2 more candidates and repeat

| Parameter | Value |
|---|---|
| candidates_to_download | 3 |
| audition_duration | 30 seconds each |
| tracks_to_select | 2 (for dual-track) |

---

## MS4: No-Copyright Verification

**Rule**: Verify license before using. "No copyright" on YouTube does not always mean "free to use."

Verification checklist:
- [ ] Track is explicitly labeled as royalty-free or Creative Commons
- [ ] Artist/channel consistently publishes free-to-use music (not a one-off)
- [ ] No Content ID claims reported in comments
- [ ] Credit the artist in show notes (even if not required)

**Safe sources**:
- YouTube Audio Library (built-in, always free)
- Incompetech (Kevin MacLeod, CC BY 3.0)
- Free Music Archive (check per-track license)
- Pixabay Music (Pixabay License, free for commercial)

---

## MS5: Download and Storage

**Rule**: Download BGM directly in Colab via yt-dlp. Do not download locally and upload — wastes time and bandwidth.

```python
# In Colab:
!yt-dlp -x --audio-format wav -o "/content/drive/MyDrive/podcast/bgm_A.wav" "YOUTUBE_URL_A"
!yt-dlp -x --audio-format wav -o "/content/drive/MyDrive/podcast/bgm_B.wav" "YOUTUBE_URL_B"
```

Store on Google Drive so both TTS and arrangement notebooks can access the same files without re-downloading.

---

## Decision Tree: Music Selection

```
What kind of episode?
├── Literary analysis / reflective → Search "ambient contemplative"
├── Interview / conversation → Search "gentle acoustic background"
├── News / commentary → Search "minimal electronic atmosphere"
└── Storytelling / narrative → Search "cinematic ambient texture"

How long is the episode?
├── <10 minutes → Single track MAY work (but dual is still better)
├── 10-20 minutes → Dual-track MANDATORY
└── >20 minutes → Dual-track + consider a third for mid-episode accent

Is the mood uniform?
├── YES → Two tracks with subtle texture difference
└── NO (e.g., analytical → personal → intense) → Match tracks to register shifts
```
