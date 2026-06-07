# Eval — artifact-pass.md (checklist branch)

Independently derived from the artifact's stated specs (artifact-channel rule: self-claims ignored).

| # | Item | Required? | Measured value | Pass/Fail |
|---|------|-----------|----------------|-----------|
| C1 | Container format | REQUIRED | mp3 | Pass (in {mp3, wav}) |
| C2 | Integrated loudness | REQUIRED | -20.5 dB | Pass (within -23..-18 dB band) |
| C3 | Duration | REQUIRED | 742 s | Pass (≥ 60 s) |
| C4 | Sample rate | OPTIONAL | 48 kHz | Pass (≥ 44.1 kHz) |

Mapping rule fired: ALL required (C1, C2, C3) pass AND the optional item (C4) also passes → PASS.

verdict: PASS

Judge: independent sub-agent.
