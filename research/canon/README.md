# Canon — Detailed Specification

This file expands the 41-line constitution (`research/CLAUDE.md`). It is the normative
reference for canon entry shape, lint rules, and generation. Keep ≤200 lines.

## 1. Authority

`research/canon/` is the structured fact layer between `raw/` (sources) and `wiki/` (answers).
All entries are markdown with YAML frontmatter (`---` delimiters). Body is prose summary
(≤15 lines / ≤120 words, enforced by lint rule 3).

## 2. Schema — 12 Fields (trimmed from Sober 15)

Remove `identifiers.imdb`-style TAD-irrelevant keys. Kept fields:

```yaml
title: string                 # human title
what: string                 # one-sentence what
type: enum [research, concept, tool, pattern]
citable: bool                # false until wiki_page exists + Iron Rule PASS
explores: [topic slug]       # ≥1 topic from _topics.yaml
topics: [topic slug]         # may include secondary topics
availability: enum [open, paywalled, local-only]
verified_on: date (YYYY-MM-DD)
depth: enum [seed, cited, compiled]  # seed=raw-only, cited=has raw_refs, compiled=wiki exists
wiki_page: path | null       # e.g. wiki/research/mcp-prompt-injection.md
raw_refs:                    # ≥1 when citable or depth!=seed
  - path: raw/papers/xxx.md
    locator: "p.3 / para 2" | "para 5" | "timestamp 00:12:34"
    note: short anchor
provenance: string           # source URL or ingest hash
```

Frontmatter must be valid YAML (`ruby -ryaml` / `python3 -c 'import yaml'` PASS).

### Example

```yaml
---
title: MCP Prompt Injection
what: Techniques and defenses for MCP tool prompt injection
type: research
citable: false
explores: [ai-guardrails]
topics: [ai-guardrails, mcp-servers]
availability: open
verified_on: 2026-08-28
depth: cited
wiki_page: wiki/research/mcp-prompt-injection.md
raw_refs:
  - path: raw/papers/mcp-001.md
    locator: "p.2 / para 1"
provenance: "https://arxiv.org/abs/2401.00001"
---
```

## 3. Controlled Vocabulary

`_topics.yaml`:
```yaml
core: [12 slugs]
allow_extend: true
extension_rule: "New topic needs added_by + reason: 1 line in first canon frontmatter"
```
Unregistered topic → lint WARN, `_index.md` marks `⚠️ unregistered`.

`_questions.yaml`: mirrors `socratic_inquiry_protocol.question_dimensions` 6 dims
(value_validation, boundary_clarification, risk_foresight, acceptance_criteria,
user_scenarios, technical_constraints).

`_clusters.yaml` (optional, P1): topic clusters for `generate.py --emit clusters`.

## 4. Iron Rule (mirrors CLAUDE.md §2)

Wiki every claim MUST have `raw_refs` + non-empty `locator` matching `p.|para|timestamp`,
and the referenced `path` must exist. Enforced by `research/canon/lint.sh` 6 rules (see §6).

## 5. Depth Derivation

- `wiki_page == null` → `seed` (must have `citable: false`)
- `wiki_page` exists + lint PASS → `cited` or `compiled` (if wiki compiled from this canon)
- `citable` may only be `true` when `wiki_page` exists AND raw_refs resolve AND locator PASS.

## 6. Lint — 6 Rules (`research/canon/lint.sh`)

1. Frontmatter is valid YAML.
2. Claim count == raw_refs count (or wiki claims section each line has `[^raw/path]`).
3. Body ≤15 lines and ≤120 words.
4. Each `raw_refs[].path` exists on disk.
5. Each `locator` non-empty and matches `p\.|para|timestamp`.
6. Depth derived consistently; YAML parse PASS (injection guard via `ruby -ryaml`).

Rules 2+4+5 are the Iron Rule. Rules 1+6 catch YAML injection.

Run: `bash research/canon/lint.sh` (no arg → lint all canon+wiki) or `bash research/canon/lint.sh <file>`.

## 7. Generation (`research/scripts/generate.py --emit all`)

Pure function, idempotent: `diff <(run1) <(run2) == 0`. Reads canon frontmatter + wiki headers,
writes `canon/_index.md` and `wiki/index.md` (+ `wiki/topics/_clusters.md` if `_clusters.yaml`).
Never hand-edit generated indexes.

## 8. Ingest (`research/scripts/ingest.sh`)

Wrapper around `.tad/cross-model/source-preprocessor.sh` (detect|validate|dispatch).
Must NOT reimplement `normalize_url`/`validate_url`. Uses `printf '%s' "$url" | yq` safe escaping
for frontmatter. Supports `x_article/bilibili/arxiv_abs/substack/medium/generic_web` + `arxiv_pdf` passthrough.

## 9. Wiki Compilation

`wiki/topics/<topic>.md` (topic skeleton) and `wiki/research/<canon-slug>.md` (per-canon answer)

## 9. Retrieval (`research/scripts/search.py`)

```bash
python3 research/scripts/search.py query "MCP prompt injection" --limit 5
python3 research/scripts/search.py query "agent memory" --scope raw --json
python3 research/scripts/search.py eval --dataset research/eval/retrieval-queries.json --json
```

Search is read-only and indexes current eligible Markdown in memory. Human output always
includes repository path, exact line range, layer, heading, and snippet. JSON uses the
same result contract. The checked-in evaluation reports Recall@5 and MRR separately;
it does not claim answer correctness or permit uncited generated conclusions.
compiled FROM canon, with ≥3 `raw_refs` each and `locator`.

## 10. Saturation (see CLAUDE.md §4)

Three-signal stop: no new topics, lint stable, 0 new locators for 2 consecutive asks. Append stall
reason to `wiki/log.md` (append-only).
