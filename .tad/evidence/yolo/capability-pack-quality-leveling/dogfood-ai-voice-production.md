# Dogfood Judgment — ai-voice-production skill

**Task:** Narrate a 120k-word audiobook with a single consistent cloned voice on a 16GB M-series Mac, publish to Audible. Which tool + pipeline?

**Date:** 2026-06-13 · **Judge:** independent, blind to which answer used the skill.

## Verdict: Answer 2 wins — CLEAR margin, on correct specifics (not verbosity).

---

## WebSearch verification of key specifics

| Claim | Answer | Verified? | Source |
|---|---|---|---|
| VoxCPM2 = 2B params, Apache-2.0 | A2 | ✅ CORRECT | OpenBMB/VoxCPM GitHub: "2B parameter backbone", Apache-2.0, free commercial |
| VoxCPM2 ~8GB, `--device auto` MPS on Apple Silicon | A2 | ✅ CORRECT | GitHub: ~8GB VRAM in comparison table; `--device auto` "uses MPS when available" |
| VoxCPM2 voice design + controllable cloning | A2 | ✅ CORRECT | GitHub: brand-new voice from text + clone from short ref |
| XTTS-v2 = non-commercial license | A2 (RED) | ✅ CORRECT, in fact WORSE | CPML non-commercial; commercial license unobtainable since Coqui shut down Jan 2024 |
| Chatterbox Perth watermark on EVERY output by default, survives MP3 | A2 | ✅ CORRECT | Resemble AI: PerTh on by default, survives MP3/Opus/editing |
| ACX: 192kbps CBR, 44.1kHz, RMS -23/-18, peak -3, noise floor -60 | A1 + A2 | ✅ CORRECT (both) | help.acx.com + multiple 2026 sources |
| ACX: head room tone 0.5-1s, tail 1-5s | A1 + A2 | ✅ CORRECT (both) | ACX credits guide + spec article |
| Audible Virtual Voice vs ACX human-only split; disclose AI | A1 | ✅ CORRECT | ACX still prohibits synthetic; Audible Virtual Voice is separate (KDP) |
| SIM 70-90%, WER EN 1-3% clone-validation thresholds | A2 | ✅ consistent with skill research ranges; plausible vs SOTA |
| Fish S2 Pro commercial requires paid license even self-hosted | A2 (YELLOW) | ✅ consistent w/ Fish research-license posture |

### Wrong / weak claims found
- **Answer 1 — material licensing error:** recommends **XTTS-v2 as the mature fallback** for a *commercial Audible title* and only calls it "unmaintained," NEVER flagging that XTTS-v2 is **non-commercial-licensed** (CPML, no commercial license obtainable post-shutdown). For a revenue product this is a substantive, dangerous omission — the single biggest correctness gap. Its primary pick "Fish Speech / OpenAudio S1-mini" also carries the same Fish commercial-license restriction A1 never surfaces (A1 dismisses Fish only on cost, not the local-weights license).
- **Answer 1 — minor:** "Llasa-8B won't fit in 16GB" is true but a strawman; fine.
- **Answer 2 — no wrong specifics found.** Every number/name verified. It is appropriately hedged where it should be: explicitly downgrades VoxCPM2's RTF 0.13 to "server-side, slower on local MPS," and offers Kokoro OOM fallback. The one soft spot: official HF repo is `VoxCPM-0.5B`; "VoxCPM2 2B" is the newer release — confirmed real on the official GitHub, so not an error.

---

## Dimension scores (1-5)

### Answer 1 (no-skill / general knowledge)
- Correctness **3** — ACX + policy nuance all correct, but recommends a non-commercial-licensed tool (XTTS-v2) for a commercial title without flagging it, and under-flags Fish's local-weights license. Right pipeline, wrong-for-use-case tool guidance.
- Actionability **4** — clean 7-step pipeline, real ffmpeg directions, ACX-check tools named. Slightly generic (single-pass loudnorm "normalize to ~-20dB").
- Specificity **3** — concrete numbers, but several are generic and the load-bearing licensing specifics are missing.
- Completeness **4** — covers segmentation, reference capture, QC, disclosure, honest caveats. Strong on policy risk.

### Answer 2 (skill-based)
- Correctness **5** — every verified specific is correct; the licensing analysis (the decisive constraint for "publish to Audible") is exactly right and is where A1 failed.
- Actionability **5** — two-pass loudnorm loop, `acx-check.sh` gate, seed-lock + cached embedding, chunk-size with OOM fallback, regenerate-failed-chunks-only. Directly executable.
- Specificity **5** — tool sizes, license tiers, ACX 8-spec list, chunk chars, validation thresholds — all concrete AND correct.
- Completeness **5** — tool selection through ACX gate, plus disqualification reasoning for the traps (XTTS RED, Chatterbox watermark, Fish YELLOW).

---

## Rationale

Both answers nail the ACX technical spec and the broad pipeline shape. The task's decisive constraint is "**publish to Audible**" = a commercial product, which makes **licensing** load-bearing. Answer 2 makes licensing the central filter and gets it verifiably right (VoxCPM2 Apache-2.0; XTTS-v2 non-commercial; Chatterbox watermark; Fish needs paid license). Answer 1 inverts this: it leads with two tools (Fish, XTTS-v2) that are both problematic for a commercial title and never flags the non-commercial license on XTTS-v2 — a real trap a user would walk into. Answer 2 also wins on actionability with the deterministic two-pass loudnorm + scripted ACX gate vs Answer 1's single-pass "normalize to ~-20dB."

Answer 2 wins on **correct specifics**, not verbosity. Answer 1 is well-written and honest (it even warns it's from general knowledge and that the skill exists), but its core tool recommendation contains a use-case-fatal licensing miss. Margin = clear (not decisive: A1's pipeline and policy-risk framing are genuinely good, and a non-expert could still ship from A1 after independently catching the license issue).
