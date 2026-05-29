# Data Preparation — Training Data Pipelines

> Judgment rules for preparing training data for LLM fine-tuning and voice model fine-tuning. Two separate pipelines, different formats, different quality criteria.

---

## LLM Data Pipeline

### Step 1: Source → Raw Extract
- Chat logs (WeChat, Telegram, Discord) → export as text/JSON
- Blog posts, emails, documents → extract relevant paragraphs
- Target: 500+ raw messages for personality cloning

> Source: Round 7, deep-ask-findings.md

### Step 2: Clean & Filter
- Remove system messages, timestamps, URLs, forwarded content
- Filter irrelevant messages (one-word replies, "ok", links without context)
- Expect ~40-60% loss during cleaning (500 raw → 200-300 usable)

> Source: Round 7, deep-ask-findings.md

### Step 3: Convert to Training Format

**ShareGPT multi-turn JSON format** (most tools accept this):
```json
[
  {
    "conversations": [
      {"from": "human", "value": "How do you think about X?"},
      {"from": "gpt", "value": "I think X is..."}
    ]
  }
]
```

Other accepted formats: JSONL ChatML, Alpaca JSON. Check tool documentation.

> Source: Round 3 + Round 7, deep-ask-findings.md

### Step 4: AI Bootstrap (if <500 usable examples)
Use a frontier model (GPT-4/Claude) to generate synthetic training pairs in the target person's style:
1. Feed 50-100 real examples as style reference
2. Generate 300+ synthetic conversations covering diverse topics
3. **Human review ALL synthetic examples** — remove any that feel off-brand
4. Mix ratio: aim for 30-50% real + 50-70% synthetic

> Source: Round 7, deep-ask-findings.md

---

## Voice Data Pipeline

### Step 1: Source Audio
- Minimum: 1 min audio for GPT-SoVITS, 5-10 min for VoxCPM2
- Preferred: clean single-speaker audio, no background music/noise
- Formats: WAV preferred, MP3 acceptable (will convert)

> Source: Round 3, deep-ask-findings.md

### Step 2: Segment & Clean
- Use VAD (Voice Activity Detection) to split into segments
- Remove segments with noise, music, or multiple speakers
- Quality over quantity: 117 clean segments outperformed 248 dirty segments at same step count

> Source: Colin dogfood 2026-05-29, deep-ask-findings.md

### Step 3: Transcribe
- Use Whisper or tool-specific ASR pipeline
- Verify transcript accuracy manually for at least 20% of segments
- GPT-SoVITS: generates `.list` annotation file (path|speaker|language|text)

> Source: Round 3, deep-ask-findings.md

### Step 4: Format for Tool
- **GPT-SoVITS**: `.list` annotation file + WAV segments in structured directory
- **VoxCPM2**: audio + transcript pairs, custom format per tool version

> Source: Round 3, deep-ask-findings.md

---

## Quality Rules

**Rule 1: Clean data beats more data.**
117 clean segments + 3500 training steps produced better voice quality than 248 dirty segments + 2000 steps.

> Source: Colin dogfood 2026-05-29, deep-ask-findings.md

**Rule 2: Minimum viable dataset by task type.**

| Task | Min Examples | Source |
|------|-------------|--------|
| Classification | 100-300 | Round 4 Q1 |
| Extraction | 200-500 | Round 4 Q1 |
| Content generation / style | 500-2K | Round 4 Q1 |
| Personality cloning (LLM) | 100-200 real + 300+ synthetic (500+ total) | Round 7 |
| Voice cloning (GPT-SoVITS) | 1 min audio | Round 3 |
| Voice cloning (VoxCPM2) | 5-10 min audio (Colin used 12.2 min cleaned) | Round 3 + Colin dogfood |

> Source: Rounds 3, 4, 7, deep-ask-findings.md

**Rule 3: AI bootstrap is not optional for personality cloning.**
If you only have 100-200 real examples, the model will underfit. Use frontier model to generate synthetic pairs, human-review them, then train on the mixed dataset.

> Source: Round 7, deep-ask-findings.md

---

## Evaluation (LLM Personality)

No automated "personality score" metric exists. Evaluation is human-judgment-based:
1. **Baseline first**: test few-shot prompting — if this works, don't fine-tune
2. **Coverage**: 20-30 test examples per scenario category
3. **Expert review**: someone who knows the target person reviews 50-100 outputs
4. **Supervised deployment**: collect edge cases for next training iteration

> Source: Round 7, deep-ask-findings.md
