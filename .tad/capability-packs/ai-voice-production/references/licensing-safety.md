# Licensing & Safety

> Commercial safety classification for all TTS tools. Check this BEFORE deploying any tool.
> "Open weights" does NOT mean "commercial use allowed."

---

## License Tiers

### GREEN — Safe for Commercial Use

| Tool | License | Notes |
|---|---|---|
| VoxCPM2 | Apache-2.0 | Full commercial rights, 30+ languages |
| Kokoro | Apache-2.0 | Full commercial rights |
| Qwen3-TTS | Apache-2.0 | Full commercial rights, both 0.6B and 1.7B |
| Chatterbox | MIT | Full commercial rights |
| Bark | MIT | Full commercial rights |
| MeloTTS | MIT | Full commercial rights |
| Piper | MIT | Full commercial rights |
| OpenVoice V2 | MIT | Full commercial rights |
| GPT-SoVITS | MIT | Full commercial rights |
| MLX-Audio | MIT | Full commercial rights |
| F5-TTS | Open-Source | Check specific version — generally permissive |

> Source: ask-findings-summary.md §Licensing (Safe for Commercial)

### YELLOW — Requires Enterprise License or Specific Terms

| Tool | License | Restriction |
|---|---|---|
| Fish Speech S2 Pro | Fish Audio Research License | Research/personal free; commercial requires enterprise agreement with Fish Audio |

**Decision rule**: If building a product that generates revenue, contact Fish Audio for enterprise terms BEFORE shipping.

### RED — Non-Commercial / Restricted

| Tool | License | Restriction |
|---|---|---|
| ChatTTS | CC BY-NC 4.0 | Non-commercial only. Intentionally quality-degraded as anti-commercial measure |
| XTTS-v2 | Non-Commercial | Non-commercial license trap — commonly mistaken as open source |

> Source: ask-findings-summary.md §Anti-Patterns, §Licensing

---

## Watermarking Traps

Some tools embed inaudible watermarks in generated audio:

- **Fish S2 Pro**: May embed watermarks in non-licensed output — verify with Fish Audio
- **Detection**: Use spectral analysis tools to check for sub-audible frequency markers
- **Risk**: Watermarked audio used commercially could trigger DMCA or license enforcement

**Rule**: If using a YELLOW-tier tool without enterprise license, assume watermarks are present until proven otherwise.

---

## Quality Sabotage Patterns

Some tools intentionally degrade output quality to discourage commercial misuse:

| Tool | Sabotage Method | Impact |
|---|---|---|
| ChatTTS | Intentional quality degradation | Output noticeably worse than model's true capability |
| Bark | AR instability (by design for some modes) | Multi-speaker drift, word omission in long texts |

> Source: ask-findings-summary.md §Anti-Patterns

**Rule**: If output quality seems inexplicably poor, check if the tool has anti-commercial measures before debugging your pipeline.

---

## License Check Decision Rule

```
BEFORE deploying any TTS tool:

1. CHECK tier in table above
   ├── GREEN → proceed
   ├── YELLOW → contact vendor for enterprise license
   └── RED → DO NOT use commercially (switch tool)

2. VERIFY model weights license separately from code license
   └── Some repos have MIT code but restricted model weights

3. CHECK training data provenance
   └── Models trained on copyrighted audio without consent may face future legal challenges
   └── Apache-2.0/MIT covers the SOFTWARE, not the training data rights

4. DOCUMENT your license compliance
   └── Record: tool name, version, license, tier, date verified
   └── Keep this in project documentation for audit trail
```

---

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Correct Approach |
|---|---|---|
| "It's on GitHub so it's open source" | Repository visibility ≠ license permissiveness | Read the actual LICENSE file |
| "Open weights means I can use it commercially" | Weight release != commercial license grant | Check license tier above |
| "I'll attribute the tool so it's fine" | Attribution satisfies some licenses but NOT non-commercial restrictions | CC BY-NC 4.0 prohibits commercial use regardless of attribution |
| "It's a small project, nobody will notice" | License enforcement is automated and retroactive | Comply from day one |
| "I'll switch tools later if there's an issue" | Voice identity is tied to tool — switching means re-recording everything | Choose correctly upfront |
