# Show Notes

> Structured show notes for literary podcast episodes. Format derived from EP2 (Colin, "Two Ways to Escape Reality"). 9 sections, each with specific formatting rules. Show notes serve triple duty: podcast app description, social media copy, and listener navigation.

---

## SN1: Episode Header

**Format**:
```
E{NN} | {Title}

{Podcast Name}
{Duration in mm:ss}
```

**Rules**:
- Episode number: `E01`, `E02`, etc. (two digits, zero-padded)
- Vertical bar separator between number and title
- Title should be evocative, not descriptive ("Two Ways to Escape Reality" not "Discussion of Yourcenar and Roth")
- Duration calculated from final audio file length

---

## SN2: One-Paragraph Hook

**Format**: 2-4 sentences after a horizontal rule. Must compress the entire episode into a compelling preview.

**Requirements**:
- Name both works in the diptych
- State the core tension/question
- Include the personal stake (why this matters to a real person, not just a reader)
- Functions as both podcast app description AND social media copy

**Example**:
> When reality disappoints, some people create a world of their own, and some people destroy the world they are in. This episode brings together Yourcenar's ancient fable and Roth's American novel — two very different answers to the same question. One is about a painter who escapes into his own painting; the other is about a father who watches his American Dream collapse piece by piece. The host's ten-year immigration experience becomes the bridge between these two stories.

**Anti-pattern**: Academic abstract ("This episode explores themes of disillusionment in 20th century literature through a comparative analysis of..."). Write it like you are telling a friend why they should listen.

---

## SN3: Timestamped Navigation

**Format**:
```
## Navigation

mm:ss | {Evocative topic description}
mm:ss | {Evocative topic description}
...
```

**Rules**:
- Every major topic transition gets a timestamp
- 10-12 timestamps per 20-minute episode
- Descriptions are evocative, NOT generic
  - GOOD: "The emperor's fury: what you hate is not reality, but the ideal you once believed in"
  - BAD: "Discussion of the emperor character"
- Timestamp format: `mm:ss` (not `hh:mm:ss` for episodes under 1 hour)
- Timestamps must match actual audio positions (verify after final arrangement)

---

## SN4: Book Recommendations

**Format**:
```
## Books Mentioned

**{Title in guillemets}**
{Author Name}
Recommended translation: {Translator Name}, {Publisher}
{1-2 sentence description connecting to episode theme}
```

**Rules**:
- Title in guillemets (Chinese book title marks)
- Author name in standard form (Chinese name for Chinese readers)
- ALWAYS specify recommended translation with translator name and publisher
- Description connects the book to THIS episode's theme, not a generic blurb
- Include ALL books mentioned in the episode, even briefly

---

## SN5: Author Bios

**Format**:
```
## Authors

**{Chinese Name}** ({Original Name in italics}, {birth}-{death})

{1-2 paragraph bio emphasizing the detail most relevant to this episode's theme}
{Include one "signature detail" that makes the author memorable}
```

**Rules**:
- Chinese name first, original name in italics
- Birth-death years
- Bio emphasizes what is RELEVANT TO THIS EPISODE, not a comprehensive biography
- One "signature detail" per author:
  - Yourcenar: Her pen name is an anagram of her birth name (Crayencour) — literature rearranges reality
  - Roth: He never left Newark in his fiction — obsessive geographical fidelity

---

## SN6: Golden Quotes

**Format**:
```
## Golden Quotes

> {Quote from the episode script}

> {Quote from the episode script}

... (8-10 quotes)
```

**Rules**:
- 8-10 direct quotes from the episode script
- Formatted as blockquotes
- Selected for: memorability, shareability, thematic weight
- Function as social media pull-quotes and listener bookmarks
- Mix types: analytical insights, personal reflections, rhetorical questions, synthesis statements
- MUST be actual lines from the script, not invented summaries

**Selection criteria** (in priority order):
1. Does it stand alone without context? (shareable)
2. Does it capture a key insight of the episode? (thematic)
3. Is it short enough for social media? (<140 characters ideal)
4. Does it make someone want to listen? (hook value)

---

## SN7: Thematic Extensions

**Format**:
```
## Further Exploration

- **{Title}** ({Type}) — {One-line connection to episode theme}
- **{Title}** ({Type}) — {One-line connection to episode theme}
... (3-4 items)
```

**Rules**:
- 3-4 recommendations
- Mix media types: book, podcast, film, previous episode
- Each has a one-line connection to the episode's theme
- Frame as "if this question interests you, also try..."
- NOT a reading list — a thematic continuation

---

## SN8: Production Credits

**Format**:
```
## About This Episode

- Voice: {Model identity} ({Technology description})
- Script: {Writing process summary}
- Review: {Review process with correction count}
- Translations cited: {List of translator/edition pairs}
- Music: {Track names, artist names, license status}
- Arrangement: {Technical description, accessible to non-engineers}
```

**Rules**:
- Voice model identity: be transparent about AI voice (e.g., "Colin voice model, VoxCPM2 + LoRA fine-tuned")
- Writing process: acknowledge the human-AI collaboration
- Review: mention Codex review with specific correction count ("25 corrections" not "reviewed by AI")
- Music: credit artists by name even if license does not require it
- Arrangement: describe the algorithm in accessible terms ("dynamic ducking that follows voice energy" not "envelope follower with 5ms attack / 2s release")

---

## SN9: Target Audience

**Format**:
```
## Who Should Listen

- {Specific listener profile with identity marker}
- {Specific listener profile with identity marker}
... (4-5 profiles)
```

**Rules**:
- 4-5 bullet points
- Each profile is SPECIFIC and identity-based, not generic
  - GOOD: "Immigrants, or anyone who has been away from somewhere for a long time"
  - BAD: "People interested in literature"
  - GOOD: "Parents who have watched their children become someone they did not expect"
  - BAD: "People who like family stories"
- Profiles should cover different entry points into the episode

---

## Complete Show Notes Template

```markdown
# E{NN} | {Title}

{Podcast Name}
{Duration}

---

{One-paragraph hook: 2-4 sentences, core tension + both works + personal stake}

## Navigation

00:00 | {Opening}
01:30 | {First topic}
...

## Books Mentioned

**{Title}**
{Author}
Recommended: {Translator}, {Publisher}
{Thematic connection}

## Authors

**{Chinese Name}** ({Original Name}, {years})
{Relevant bio + signature detail}

## Golden Quotes

> {Quote 1}

> {Quote 2}

...

## Further Exploration

- **{Title}** ({Type}) — {Connection}

## About This Episode

- Voice: ...
- Script: ...
- Review: ...
- Music: ...
- Arrangement: ...

## Who Should Listen

- {Profile 1}
- {Profile 2}
...
```

---

## Decision Tree: Show Notes Timing

```
When to write show notes?
├── After final script (v3, post-Codex review)
│   └── Write: SN1 (header), SN2 (hook), SN4 (books), SN5 (authors), SN6 (golden quotes), SN7 (extensions), SN9 (audience)
├── After final audio arrangement
│   └── Write: SN3 (timestamps — need actual audio positions)
├── After production is complete
│   └── Write: SN8 (credits — need final music tracks, correction count, arrangement details)
└── Never write timestamps before final audio — they WILL change
```
