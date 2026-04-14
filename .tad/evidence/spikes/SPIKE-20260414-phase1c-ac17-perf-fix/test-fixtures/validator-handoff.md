# Evidence Report (hot-path fixture for hardened-evidence-validator)

This file exists so the hardened-evidence-validator.sh hot path (git ls-files
scan, archive sha manifest diff, handoff staleness check) can be exercised
during N=100 perf benchmarking without hitting the usage-error early-exit.

Overall: PASS

## References (must resolve via git ls-files, ≥3 required)

- CLAUDE.md
- README.md
- package.json

## Rationale

Benign, self-describing evidence fixture for Phase 1c perf measurement. The
evidence-validator will walk this file through size check, Overall regex,
code-fence detection, git ls-files cross-check, archive sha dedup, and
staleness check — representative hot path.
