# Generate Diff — Idempotent Check 2026-08-28

- Command: `python3 research/scripts/generate.py --emit all`
- First run: wrote research/canon/_index.md (639B), research/wiki/index.md (694B), research/wiki/topics/_clusters.md (183B)
- Second run: diff <(run1) <(run2) == 0 (canon/_index.md and wiki/index.md identical)
- Stdout diff: `python3 generate.py --emit all > /tmp/run2.md && diff research/canon/_index.md /tmp/run2.md` → PASS (stdout == file via strenv)
- Grep checks: `grep -q canon` PASS, `grep -q wiki` PASS

Evidence: generate.py pure-function, no timestamps, sorted output.
