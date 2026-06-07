# Eval — artifact-fail.md (checklist branch)

Independently derived from the artifact's stated specs (artifact-channel rule: self-claims ignored).

| # | Item | Required? | Measured value | Pass/Fail |
|---|------|-----------|----------------|-----------|
| C1 | Container format | REQUIRED | mp3 | Pass (in {mp3, wav}) |
| C2 | Integrated loudness | REQUIRED | -30.2 dB | Fail (below -23..-18 dB band; -30.2 < -23) |
| C3 | Duration | REQUIRED | 705 s | Pass (≥ 60 s) |
| C4 | Sample rate | OPTIONAL | 44.1 kHz | Pass (≥ 44.1 kHz) |

Mapping rule fired: ANY required fail → FAIL. Required item C2 (integrated loudness) is out of band, so the FAIL rule fires regardless of the other passing items.

verdict: FAIL

Judge: independent sub-agent.
