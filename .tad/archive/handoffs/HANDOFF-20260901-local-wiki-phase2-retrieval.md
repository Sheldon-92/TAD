---
task_type: code
e2e_required: false
research_required: false
git_tracked_dirs:
  - research
  - .tad/evidence/research/local-wiki-phase2
---
# HANDOFF-20260901 — Local Wiki Phase 2 Retrieval Foundations

**Task ID:** `TASK-20260901-LOCAL-WIKI-P2-RETRIEVAL`
**Epic:** `.tad/active/epics/EPIC-20260901-local-wiki-retrieval.md`
**Mode:** YOLO, human-authorized 2026-09-01
**Status:** Gate 1 PASS; Gate 2 PASS (architecture + safety, P0=0/P1=0)

## 1. Goal

Deliver a local search surface over the existing Local Wiki so agents can retrieve
ranked, traceable evidence before Phase 3 expands the corpus with audio/video.

## 2. Allowed product changes

- `research/scripts/search.py` (create)
- `research/tests/test_search.py` (create)
- `research/eval/retrieval-queries.json` (create)
- `research/CLAUDE.md` (modify retrieval instructions)
- `research/canon/README.md` (modify operator instructions)
- new task-specific `.tad/active`, `.tad/evidence`, `.tad/decisions`, and archive files

Do not modify source evidence or compiled canon/wiki pages merely to make evaluation
pass. Do not add a third-party runtime dependency.

## 3. Functional requirements

1. `query` supports text, `--limit`, `--scope all|wiki|canon|raw|governance`, and `--json`.
2. Every result includes path, layer, heading, start/end line, snippet, and numeric score.
3. Mixed English/CJK queries work; sub-trigram queries have an honest fallback.
4. SQL/FTS control characters are treated as literal text and cannot alter the query.
5. Indexing is read-only and derives from current Markdown on every invocation.
6. `eval` computes Recall@5 and MRR from checked-in cases and fails below thresholds.
7. Existing Local Wiki lint and generation remain green and idempotent.

Dataset contract: `{version: 1, cases: [{id, query, scope, expected_paths}]}` with
unique non-empty IDs/queries and safe, indexed, unique expected paths. Metrics de-duplicate
results by path: Recall@5 is mean binary accepted-path hit@5; MRR is mean reciprocal rank
of the first accepted path.

## 6. Implementation steps

1. Implement the closed path-to-layer map and safe Markdown section parser, including
   frontmatter-title fallback for headingless canon/wiki pages.
2. Implement one in-memory FTS5 trigram index per invocation with literal OR-term query,
   fixed BM25 weights `title=8`, `heading=5`, `body=1`, and deterministic tie-breaks.
3. Implement human and JSON result renderers plus the strict shared evaluation path.
4. Add the real-query dataset and focused tests, then update operator documentation.
5. Run all §9.1 checks and bind outputs into task evidence.

## 9.1 Spec Compliance Checklist / Acceptance criteria

### AC1 — usable query

```bash
python3 research/scripts/search.py query "MCP prompt injection" --limit 3
```

PASS: exit 0 and a result under `research/wiki/` or `research/canon/` includes line data.

### AC2 — JSON and filtering

```bash
python3 research/scripts/search.py query "agent memory vector database" --scope raw --json
```

PASS: valid non-empty JSON; every result has the seven required fields,
`layer == "raw"`, a finite numeric score, integer `start_line >= 1`, and integer
`end_line >= start_line`.

### AC3 — safety and CJK

```bash
python3 -m unittest research.tests.test_search
```

PASS: literal hostile input, all four scopes, headingless pages, CJK, short-query
fallback, invalid scope/limit, malformed/impossible eval data, unavailable FTS5,
symlink/path escape, and no-write checks pass.

### AC4 — retrieval quality

```bash
python3 research/scripts/search.py eval --dataset research/eval/retrieval-queries.json --json
```

PASS: Recall@5 `1.0`, MRR `>=0.75`, and per-case ranks are present.

### AC5 — Phase 1 regression

```bash
bash research/canon/lint.sh
tmp1=$(mktemp); tmp2=$(mktemp)
python3 research/scripts/generate.py --emit all >"$tmp1"
python3 research/scripts/generate.py --emit all >"$tmp2"
diff -u "$tmp1" "$tmp2"
```

PASS: lint succeeds and generated stdout is identical.

## 10. Gate rules

- Gate 2 requires two independent reviews with P0=0 and all P1 resolved.
- Gate 3 requires focused tests plus code-reviewer and test-runner reports; no paid/live
  provider tests.
- Gate 4 may archive automatically under the accepted YOLO mandate when all ACs pass.
