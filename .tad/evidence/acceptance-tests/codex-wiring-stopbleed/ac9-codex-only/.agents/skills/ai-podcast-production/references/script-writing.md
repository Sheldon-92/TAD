# Script Writing

> Article/book analysis to podcast script with adversarial Codex review. Grounded in 2 episodes: EP1 (Sheldon, Time Game), EP2 (Colin, Yourcenar + Roth diptych). The methodology produces 95-point scripts via a repeatable 5-step quality delta.

---

## SS1: Source Selection — Thematic Diptych

**Rule**: Choose 2+ literary works that form a thematic diptych (coin metaphor) — works that appear distant but share a deep thematic question.

| Dimension | Work A | Work B |
|---|---|---|
| Thematic | Creation | Destruction |
| Tonal | Myth register | Realist register |
| Structural | Short story | Novel |
| Personal | Quiet night reading | Daytime driving in America |

**Example**: EP2 paired Yourcenar's "How Wang Fo Was Saved" (mythic, creation) with Roth's "American Pastoral" (realist, destruction). Both answer: "When a person is disappointed with reality, what happens?"

**Anti-pattern**: Picking two works from the same author or same genre. The diptych requires DISTANCE between the works so the shared question becomes surprising.

---

## SS2: Thematic Framing — Personal Question, Not Abstract Thesis

**Rule**: Open with a personal, specific question (not an academic thesis). The question must feel intimate.

- GOOD: "When a person is disappointed with reality, what happens?"
- BAD: "This episode explores the theme of disillusionment in 20th century literature."
- GOOD: "You know that moment when the city you live in stops feeling like home?"
- BAD: "Immigration and cultural identity are complex topics."

The question establishes the listener's personal stake before any literary analysis begins.

---

## SS3: Structural Architecture — Setup to Non-Resolution

**Rule**: Build toward a non-binary conclusion. Refuse to pick sides.

Episode arc:
1. **Opening question** — personal, specific, emotionally loaded
2. **Work A deep dive** — with original-text quotation, technique analysis, author context
3. **Personal bridge** — first-person experiential passage connecting A to speaker's life
4. **Work B deep dive** — mirroring structure of A but from opposite angle
5. **Synthesis** — hold contradictions in tension: "Cynicism is easy. Fanaticism is easy. The hardest thing is the middle state."
6. **Coda** — return to the opening question, now transformed by the journey

**Anti-pattern**: Tidy conclusion that picks a winner. "Wang Fu's approach is better because..." destroys the intellectual signature. The thesis IS the refusal to resolve.

---

## SS4: Reference Style — Xu Zhiqiang (Kan Lixiang) Method

**Rule**: Adopt 8 techniques from the model practitioner. These are not optional flourishes — they are the structural difference between 85 and 95 points.

### Technique 1: Direct Original-Text Quotation with Translator Attribution
Quote passages directly from named translations, always crediting the translator.
- GOOD: "Duan Yinghong's translation roughly says: 'The sea water from the painting overflowed, submerging the jade tile floor of the palace...'"
- BAD: "The general meaning of the original text is that the painting becomes real."

### Technique 2: Scholar-Register Oral Tone
Complex ideas in short, punchy oral sentences. Educated but never stiff.
- GOOD: "We say lies are sweet coffee, art is bitter coffee."
- BAD: "One might argue that literary art serves as a dialectical counterpoint to comfortable illusions."

### Technique 3: Technique-Level Analysis (NOT Plot Summary)
Explain HOW the author achieves the effect, not just WHAT happens.
- GOOD: "Roth uses exhaustive realism to build a world solid enough that its collapse hurts. Without the solidity, the collapse would not hurt."
- BAD: "Roth writes about a family that falls apart."

### Technique 4: Anecdotal Author Asides (Xianbi / Idle Brushstrokes)
Biographical details as narrative texture reinforcing theme, not Wikipedia info-dumps.
- GOOD: Yourcenar's anagram name (rearranging letters of reality = literature rearranges life), her Maine island life (withdrawal from reality), her Academie Francaise election (institutional recognition of her escape)
- BAD: "Marguerite Yourcenar was born in 1903 and died in 1987."

### Technique 5: Personal Reading Memory as Emotional Anchor
Specific sensory detail, not abstract reflection.
- GOOD: "I was reading under a desk lamp, the only light in the room, and the suburban mailboxes outside were all identical."
- BAD: "This book made me think about my life as an immigrant."

### Technique 6: Thematic Threading Across Works
Multiple works under one question, creating resonance — not isolation.

### Technique 7: Rhetorical Question as Pacing Device
Questions to the listener create breathing room. "You see, this emotion is not ancient at all." / "Why is this ending moving? Not because it is magical."

### Technique 8: Cultural Bridging (Making the Foreign Familiar)
Connect foreign literature to listener's lived experience via culturally specific touchpoints (visas, rent, identity anxiety, a Chinese poem late at night).

---

## SS5: First Draft Production

**Rule**: Write in oral-register Chinese. Short paragraphs (1-3 sentences). Rhythmic repetition. Rhetorical questions. Remove all markdown section headers — they break oral flow.

**Chunk size for TTS**: Keep natural paragraph/thought units to 200-350 characters. This serves dual purpose: optimal TTS generation AND natural oral rhythm.

**PAUSE_MAP**: Mark emotional transitions in the script where longer pauses (1.0-1.5s vs default 0.7s) will be inserted during TTS. These are script-level decisions, not post-production decisions.

---

## SS6: Personal Bridge Passages

**Rule**: Insert first-person experiential passages that connect literary analysis to the speaker's own life. These are NOT decorative — they are the emotional throughline.

Requirements:
- Grounded in specific sensory detail (the lamp, the suburban lawns, the mailboxes)
- Connected to a concrete timeframe ("ten years ago", "my first winter in America")
- Bridges FROM the literary analysis TO the listener's potential identification
- Minimum 1 per work discussed, ideally 1 between works as transition

---

## SS7: Oral Naturalness Checklist

Before sending to TTS, verify:
- [ ] No section headers (###, ##) remaining
- [ ] No academic jargon or passive voice
- [ ] Short sentences (under 40 characters preferred for Chinese)
- [ ] Rhetorical questions every 3-5 paragraphs
- [ ] No "firstly/secondly/thirdly" list structures
- [ ] Contractions and colloquial connectors used
- [ ] Reading aloud takes 15-25 minutes (target podcast length)

---

## SS8: Fact-Check Preparation

**Rule**: Before Codex review, prepare a fact-check checklist of every verifiable claim:
- Author names, birth/death years
- Book titles, publication dates
- Translator names and editions cited
- Character names and plot details
- Awards and honors mentioned
- Historical events referenced

This preparation makes Codex review more efficient — give Codex the checklist alongside the script.

---

## SS9: Codex Adversarial Review — MANDATORY

**Rule**: Submit the complete draft to Codex (OpenAI Codex CLI/API, current default model — GPT-5.5-class as of 2026-06; use whatever the installed CLI ships) for independent adversarial review. This is NOT proofreading — it is structural and factual review that catches errors the original AI-human collaborative draft misses due to collaborative blind spots.

**Process**:
1. Raw article analysis → first draft (v1/v2)
2. Submit to Codex with instruction: "Independently verify every factual claim. Flag logic errors. Identify missing critical details. Suggest precision upgrades."
3. Codex returns 25+ corrections (validated across 2 episodes)
4. Incorporate corrections → final draft (v3)

**5 Correction Categories**:

| Category | Example (EP2) |
|---|---|
| **Factual precision** | "beauty queen" → "former Miss New Jersey Dawn" |
| **Source fidelity** | Vague paraphrase → direct quote from Duan Yinghong translation |
| **Missing critical details** | Ling subplot (red scarf, death, return from painting) entirely absent in v2 |
| **Logic errors** | "reading while driving" flagged as physically impossible |
| **Structural upgrades** | Section headers removed for oral flow; three-generation arc expanded |

**Anti-pattern**: Skipping Codex review because "the draft feels good." EP2 had 25+ errors that felt invisible until independently verified. Collaborative blind spots are real.

---

## SS10: Codex Review Prompting

**Effective prompt structure for Codex**:
```
Review this podcast script for a literary analysis episode.

Source materials:
- [Work A: full title, author, translator/edition]
- [Work B: full title, author, translator/edition]

Review criteria:
1. Verify every factual claim (character names, plot events, dates, awards, translator names)
2. Flag logical impossibilities or contradictions
3. Identify vague paraphrases that should be direct quotes with translator attribution
4. Find missing critical plot elements or character arcs
5. Check that oral register is consistent (no academic jargon creeping in)
6. Verify structural symmetry of the diptych

Script:
[full script text]
```

---

## SS11: Incorporating Codex Corrections

**Rule**: Apply corrections category by category, not line by line. This prevents introducing new errors while fixing old ones.

Order:
1. **Factual precision** first — these are binary right/wrong
2. **Missing details** second — these require inserting new passages
3. **Source fidelity** third — replace paraphrases with direct quotes
4. **Logic errors** fourth — rewrite problematic passages
5. **Structural upgrades** last — these may require reordering

After incorporation, re-read the full script aloud to catch any flow disruptions from the edits.

---

## SS12: Quality Scoring Rubric

### 100-Point Scale

| Dimension | Points | What 85 Looks Like | What 95 Looks Like |
|---|---|---|---|
| Factual Accuracy | 0-15 | Correct general facts, some imprecision | Every claim independently verifiable, granular detail |
| Source Quotation | 0-15 | Paraphrases ("the meaning is...") | Direct quotes with translator name and edition |
| Technique Analysis | 0-15 | Plot summary ("X happens") | Craft analysis ("X achieves Y by doing Z") |
| Personal Memory | 0-15 | Abstract ("this made me think") | Sensory-specific ("under the desk lamp, mailboxes identical") |
| Oral Naturalness | 0-10 | Readable but slightly literary | Sounds like natural speech with rhythm and breath |
| Structural Architecture | 0-10 | Linear progression | Diptych with mirroring at every level |
| Thematic Courage | 0-10 | Tidy conclusion | Holds contradictions in tension; refuses to resolve |
| Author Context | 0-10 | Biographical trivia | Details that reinforce theme (anagram name = literature rearranges reality) |

### The 85→95 Gap (10 Points, 5 Steps)

| Step | Delta | How |
|---|---|---|
| Original text quotation vs paraphrase | +2 | Name translator, quote exact sentence |
| Technique analysis vs plot summary | +2 | "HOW the author achieves" not "WHAT happens" |
| Personal memory specificity | +2 | Sensory grounding, concrete timeframe |
| Factual precision via Codex review | +2 | 25+ corrections applied |
| Non-resolution thesis | +2 | "The hardest thing is the middle state" |

Each step is learnable, repeatable, and auditable — not talent-dependent.
