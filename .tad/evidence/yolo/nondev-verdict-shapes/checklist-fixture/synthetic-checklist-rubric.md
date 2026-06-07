# Synthetic Checklist Rubric (fixture) — audio export spec

> verdict_shape: **checklist**. Synthetic fixture (P1-4 / DR-20260606) to exercise the
> Phase-1 Gate-3 checklist branch without voice/video hardware. NOT a production rubric.
> Mirrors the kind of export-spec ai-voice-production / video-creation will use.

## Items

| # | Item | Required? | Pass condition |
|---|------|-----------|----------------|
| C1 | Container format | REQUIRED | format is `mp3` or `wav` |
| C2 | Integrated loudness | REQUIRED | RMS/integrated loudness between -23 dB and -18 dB (ACX-style band) |
| C3 | Duration | REQUIRED | duration ≥ 60 seconds |
| C4 | Sample rate | OPTIONAL | sample rate ≥ 44.1 kHz |

malformed_guard: 3 REQUIRED items present (≥1) → rubric is well-formed.

## Mapping (Phase-1 checklist branch)
- ALL required (C1,C2,C3) pass → `verdict: PASS`
- ALL required pass, ≥1 optional (C4) fail → `verdict: PARTIAL`
- ANY required fail → `verdict: FAIL`

## Judge rule
Derive each item pass/fail from the artifact's stated specs you independently read —
never from the artifact's own "this passed" claim (artifact-channel rule).
