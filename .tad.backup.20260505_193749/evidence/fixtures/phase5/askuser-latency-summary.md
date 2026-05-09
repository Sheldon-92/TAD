# askuser-capture.sh Latency Benchmark (P5.2 NFR1)

**Date**: 2026-04-25T14:57:23Z
**Methodology**: perl Time::HiRes wall-clock per call, N=100
**Target**: median < 50ms AND p95 < 100ms (architecture.md "Hook Performance" 2026-04-07)

## Results

```
median=58 p95=98 p99=118 n=100
```

Raw data: `askuser-latency-N100.tsv` (100 rows + header)

## Verdict

❌ FAIL — median=58ms p95=98ms (one or both miss target)

## Caveats

- Dev-host measurement (concurrent processes may inflate); CI dedicated runner would be tighter
- N=100 samples; for production gate use N≥100 (architecture.md "Perf Gate Measurement" 2026-04-14)
