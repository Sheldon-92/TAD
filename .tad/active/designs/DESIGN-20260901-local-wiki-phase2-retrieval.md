# Design — Local Wiki Phase 2 Retrieval Foundations

**Epic:** `.tad/active/epics/EPIC-20260901-local-wiki-retrieval.md`  
**Decision:** `.tad/decisions/DR-20260901-local-wiki-retrieval-before-multimedia.md`

## 1. Problem

Local Wiki can ingest, lint, and compile evidence, but it has no query surface. Users
must know filenames or manually inspect generated indexes. Media ingestion would add
more material without fixing findability.

## 2. Product contract

`python3 research/scripts/search.py query "<text>"` returns ranked local matches with:

- repository-relative path;
- source layer (`wiki`, `canon`, `raw`, or `governance`);
- nearest Markdown heading;
- exact start/end lines and a short snippet;
- stable JSON output when `--json` is requested.

The same executable provides `eval` over a checked-in real-query dataset and reports
Recall@5 plus MRR. Retrieval and future answer-generation evaluation remain separate.

## 3. Architecture

### 3.1 Indexing

- Discover eligible product Markdown under the resolved `research/` root using this
  closed map: `research/wiki/**/*.md → wiki`, `research/canon/**/*.md → canon`,
  `research/raw/**/*.md → raw`, and exactly `research/CLAUDE.md` plus
  `research/canon/README.md → governance`. Generated indexes, logs, fixtures, hidden
  paths, and every other unclassified path are excluded.
- Read regular files only. Reject symlinks and reject any candidate whose resolved path
  is outside the resolved `research/` root. Emitted paths are repository-relative and
  may not contain `..`.
- Parse YAML frontmatter only for `title` and `topics`, then index body content after the
  closing delimiter. Split body by Markdown headings. For a headingless page, use the
  frontmatter title as its heading and one body chunk whose range begins immediately
  after frontmatter. Every chunk retains exact one-based start/end lines.
- Build an in-memory SQLite FTS5 index for each invocation. At the current corpus size
  this avoids stale-cache state and preserves “files are truth”.
- Use parameterized SQL and a literal-query encoder. No user text is interpolated into
  SQL or treated as an FTS operator expression.

### 3.2 Ranking

- FTS5 trigram/BM25 is the primary baseline because it supports mixed English and CJK
  substring search and requires no third-party package. Whitespace-separated terms of
  three or more characters are literal-quoted and joined with `OR`; an unsegmented CJK
  query is one literal term. Short-only queries use the substring fallback.
- Indexed columns are `title`, `heading`, and `body`; BM25 weights are `8.0`, `5.0`, and
  `1.0`. Results are ordered by BM25 ascending, then layer priority
  `wiki < canon < governance < raw`, then path and start-line ascending. The layer order
  is a tie-break only—there is no opaque “closeness” boost.
- A result is unique by `(path, start_line, end_line)`.
- Queries too short for trigram matching use a deterministic case-folded substring
  fallback.

### 3.3 Evaluation

The JSON dataset has schema `{version: 1, cases: [{id, query, scope, expected_paths}]}`.
IDs and query strings must be unique and non-empty; scope uses the public enum; each
expected path must be unique, repository-relative, safe, and present in the indexed
corpus. `eval` calls the same query function as the CLI.

- Per-case retrieval is de-duplicated by path, retaining its first/highest-ranked chunk.
  Recall@5 is binary hit-rate: a case scores 1 when any accepted path is in its first
  five unique paths, otherwise 0; the reported metric is the case mean.
- MRR uses the reciprocal rank of the first unique returned path found in
  `expected_paths`, or zero when absent; the reported metric is the case mean.
- Recall@5 target: `1.0` for the checked-in smoke set; MRR target: `>= 0.75`.
- A failed semantic/paraphrase query is evidence for evaluating an embedding extension;
  it is not permission to silently weaken the metric.

### 3.4 Vector boundary

No vector dependency ships in this phase. A future vector candidate must use the same
result schema and evaluation set, report lexical and semantic metrics separately, and
demonstrate improvement before hybrid fusion is accepted.

## 4. Failure behavior

- Empty query, invalid scope/limit, missing corpus, unavailable FTS5, malformed eval
  data, unsafe/unknown expected paths, and symlink/path escape exit non-zero with concise
  diagnostics.
- Zero matches is a successful empty result, not fabricated fallback content.
- Search never writes beneath `research/raw`, `research/canon`, or `research/wiki`.

## 5. Verification

One focused unittest module covers ranking, headingless pages, all scopes, CJK, JSON
schema, hostile query text, malformed/impossible evaluation cases, FTS unavailability,
and a temporary-repository symlink escape. Existing Local Wiki lint and generator
idempotence are the only regressions required; no provider or broad repository test
matrix is needed.
