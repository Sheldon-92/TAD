# Licensing & Safety

> Commercial safety classification for all TTS tools. Check this BEFORE deploying any tool.
> "Open weights" does NOT mean "commercial use allowed."

---

## License Tiers

### GREEN — Safe for Commercial Use

| Tool | License | Notes |
|---|---|---|
| VoxCPM2 | Apache-2.0 | Full commercial rights, 30+ languages |
| CosyVoice2-0.5B | Apache-2.0 | Full commercial rights; low-latency streaming (~150ms first packet) |
| IndexTTS2 | Apache-2.0 (code) | Code Apache-2.0; verify the model-weights license on the HF model card before shipping |
| Kokoro | Apache-2.0 | Full commercial rights |
| Qwen3-TTS | Apache-2.0 | Full commercial rights, both 0.6B and 1.7B |
| Chatterbox | MIT | Full commercial rights, BUT see §Watermarking — embeds a Perth neural watermark on EVERY generated file by default |
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
| Fish Speech S2 / S2-Pro | Fish Audio Research License | Research / non-commercial **free**; commercial use (INCLUDING self-hosted weights "when you're ready to ship") requires a **separate license via business@fish.audio** |

**Decision rule**: If building a product that generates revenue, contact `business@fish.audio` for a commercial license BEFORE shipping. Self-hosting the weights does NOT exempt you.

> ⚠️ **VERIFIED-NO-CHANGE (2026-06-13, cross-model reviewer-trap avoided)**: An aggregator
> claimed Fish S2 is "MIT-licensed for self-hosting." The **primary sources** —
> fish.audio S2 blog + HuggingFace `fishaudio/s2-pro` model card — confirm the **Fish Audio
> Research License**: research/non-commercial free, commercial (including self-hosted weights)
> requires a separate license. So this entry stays **YELLOW**; do NOT downgrade to GREEN on
> the aggregator's word. Also confirmed: S2-Pro = **5B total** (4B slow-AR + 400M fast-AR),
> trained on **10M+ hrs / 80+ languages**.
> Source: https://huggingface.co/fishaudio/s2-pro (retrieved 2026-06-13)

### RED — Non-Commercial / Restricted

| Tool | License | Restriction |
|---|---|---|
| ChatTTS | CC BY-NC 4.0 | Non-commercial only. Intentionally quality-degraded as anti-commercial measure |
| XTTS-v2 | Non-Commercial | Non-commercial license trap — commonly mistaken as open source |

> Source: ask-findings-summary.md §Anti-Patterns, §Licensing

---

## Watermarking Traps

Some tools embed inaudible watermarks in generated audio:

- **Chatterbox (Resemble AI)**: Embeds a **Perth (Perceptual Threshold) neural watermark on EVERY
  generated file BY DEFAULT** (`PerthImplicitWatermarker`) — imperceptible, ~100% detection
  accuracy, and **survives MP3 compression, audio editing, and common manipulations**. This is
  independent of the MIT license: the code/weights are MIT (commercial-OK), but every output you
  ship carries a Resemble-attributable provenance mark. Material for any deployment that needs
  unmarked audio (e.g. claiming sole authorship, anti-provenance use cases). Removing or defeating
  the watermark may also breach Resemble AI's responsible-use terms.
  > Source: https://huggingface.co/ResembleAI/chatterbox + https://github.com/resemble-ai/chatterbox (retrieved 2026-06-13)
- **Fish S2 Pro**: May embed watermarks in non-licensed output — verify with Fish Audio
- **Detection**: Use spectral analysis tools to check for sub-audible frequency markers
- **Risk**: Watermarked audio used commercially could trigger DMCA or license enforcement

**Rule**: If using a YELLOW-tier tool without enterprise license, assume watermarks are present
until proven otherwise. **Also assume Chatterbox output is ALWAYS watermarked** (it is, by default)
even though it is GREEN/MIT — GREEN means commercial-rights-OK, NOT watermark-free.

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
