# Research Constitution — Local Wiki (TAD)

> File is truth. Cloud is optional. Every claim traces to a file on disk.

## 1. Three Layers — One Way

```
raw (sources on disk) → canon (12-field distilled facts) → wiki (compiled answers)
```

- **raw/**: fetched sources per medium (papers/articles/github/manifests). Immutable once ingested.
- **canon/**: `_topics.yaml` + `_questions.yaml` governed, 12-field entries, `citable` flag.
- **wiki/**: compiled pages that ANSWER questions; every claim has `raw_refs` + `locator`.

Direction is **unidirectional**: wiki may read canon+raw; canon may read raw; never reverse.
`generate.py` is the only writer of `_index.md` / `wiki/index.md` (pure function, idempotent).

## 2. Iron Rule — Claims Need Carriers

> **Every wiki claim MUST have at least one `raw_refs` entry with `locator: p.X | para Y | timestamp`.**
> `lint.sh` enforces it. Missing/empty locator, missing file, count mismatch → FAIL. No exceptions.

## 3. Three Depths

- **Quick**: WebSearch only, no canon/wiki. Single fact, no persistence.
- **Standard**: ingest 3+ raw → 2 canon → wiki with Iron Rule → `lint.sh` PASS → `generate.py`.
- **Deep**: Standard + canon loop + saturation probes + contradiction section + archive.

`*research --quick|--standard|--deep` maps directly. Default is Standard via `local_wiki`.

## 4. Saturation — When to Stop

Stop when **(a)** new raw adds no new canon topics, **(b)** `lint.sh` PASS unchanged, **(c)** two consecutive asks add 0 new `locator` refs. Log stall reason in `wiki/log.md`.

## 5. Controlled Vocabulary

`canon/_topics.yaml` core 12, `allow_extend: true` with `added_by + reason` in first canon frontmatter. Unregistered → lint WARN + `⚠️ unregistered` tag in `_index.md`.

## 6. Fallback

Primary: `local_wiki`. NotebookLM is **fallback only** when `~/.tad-notebooklm-venv` missing. `research-github` writes canon, not notebook. Details: `research/canon/README.md`.

## 7. Retrieval

Search before manually loading the corpus:

```bash
python3 research/scripts/search.py query "<question>" --limit 5
```

Use `--scope wiki|canon|raw|governance` to narrow results and `--json` for agent/tool
consumption. Results are local evidence locations, not generated answers: inspect the
returned path and line range before making a claim. The index is rebuilt in memory from
Markdown on every call, so files remain the only source of truth.

## 8. Native browser capture

Use the TAD-owned CLI with an isolated Chrome profile; it reads only the rendered DOM of the
specific tab you select and never asks for browser credentials. Start with
`node research/scripts/browser-capture.mjs launch https://example.com --headless`; the owned
profile marker supplies the active port to `tabs` and `capture` when `--port` is omitted. Use
`tabs`, then `capture --tab TAB_ID` (or supply `--port` explicitly for a separately selected
owned profile). Capture accepts HTTPS pages and local fixtures only at `http://localhost`,
`http://127.0.0.1`, or `http://[::1]`; arbitrary HTTP remains rejected.
