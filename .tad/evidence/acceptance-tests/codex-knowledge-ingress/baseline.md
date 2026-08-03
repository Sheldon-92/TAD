# Codex knowledge ingress baseline

Date: 2026-08-03 (America/New_York)
Repository HEAD before product edits: `e73a3c88bd4152e53204fb2991623aae34903b84`

This baseline was captured before changing any product file. The Codex scratch
probe files under this evidence directory are the only files created by this
task at baseline time. The other dirty paths listed below predate this task and
are preserved unchanged.

## Measured guards

| Check | Baseline result |
|---|---|
| `bash .tad/hooks/pre-gate-check.sh 3 </dev/null` | exit 0, stdout `{}`, stderr empty (known false-green) |
| `bash .tad/hooks/pre-accept-check.sh </dev/null` | exit 0, stdout `{}`, stderr empty (known false-green) |
| `bash .tad/hooks/lib/runtime-freshness-verify.sh` | exit 0; `Total: 21 entries \| PASS: 21 \| WARN: 0 \| BLOCK: 0` |
| `# Source: .claude` headers in both skill trees | 38 lines across 19 files |
| `.tad/brain-index.md` MD5 | `cdeeda1b56f63db871ed3ae2f74b834c` |
| `alex-lite` sentinel MD5, `.claude` and `.agents` | `a55d37738775322062ebebc6e078851b` each |
| `blake-lite` sentinel MD5, `.claude` and `.agents` | `dc7699fa33e0439874fea1c2e25463a7` each |
| all current hook shell files | `bash -n` PASS |

The source-header count was measured with:

```sh
rg -n '^# Source: \.claude' .claude/skills .agents/skills | wc -l
```

The four lite sentinels were measured individually with BSD `md5 -q`.

## Pre-existing dirty paths

These paths were present before this task and are not part of the requested
implementation: `NEXT.md`, the three modified project-knowledge pattern files,
the deleted/added lite-review completion/archive records, the archived
stopbleed handoff/completion records, the stopbleed evidence directories, and
`.tad/evidence/traces/2026-08-03.jsonl`.
