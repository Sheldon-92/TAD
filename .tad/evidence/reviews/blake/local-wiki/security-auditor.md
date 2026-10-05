# Security Auditor — Local Wiki Research Framework (Gate 3 Layer 2 Re-review)

**Reviewer:** security-auditor (TAD Gate 3 Layer 2, independent)
**Date:** 2026-08-28 (re-review post-fix)
**Handoff:** `.tad/active/handoffs/HANDOFF-20260828-local-wiki-research-framework.md`
**Scope:** Re-read `research/scripts/ingest.sh` full (160 lines), verify fix lines 76-98; re-check YAML injection, Iron Rule, credential leak, path traversal, supply chain; live probes: suffix, --out clamp, injection.
**Gate 2 baseline:** CONDITIONAL PASS (P0 Iron Rule, P0 YAML closed; P1 overwrite open). This re-review verifies Blake fix.

---

## Verdict: PASS

**P0: 0 open / 2 closed · P1: 0 open / 4 closed · P2: 0 open / 1 closed**

Gate 3 security-auditor requires `P0=0, P1≤1`. Fix closes last P1. **PASS**, no conditions.

---

## 1. P1 Fix Verification — research/scripts/ingest.sh:76-98 ✓ CLOSED

Evidence file:line `research/scripts/ingest.sh:76-97`:

```bash
76: SLUG="${SOURCE_TYPE}-${RAW_SLUG}"
77: # Sanitize --out to stay within research/raw (prevent path traversal)
78: if [ -n "$OUT" ]; then
79:   if [[ "$OUT" != research/raw/* ]] && [[ "$OUT" != "$REPO_ROOT/research/raw/"* ]]; then
80:     echo "ERROR: --out must be under research/raw/" >&2
81:     exit 1
82:   fi
83:   if [[ "$OUT" == *".."* ]]; then
84:     echo "ERROR: --out must not contain .." >&2
85:     exit 1
86:   fi
87: fi
88: OUT_PATH="${OUT:-$REPO_ROOT/research/raw/${MEDIUM}/${SLUG}.md}"
89: # Ensure uniqueness if file exists (append counter suffix, not silent overwrite)
90: if [ -e "$OUT_PATH" ]; then
91:   base="${OUT_PATH%.md}"
92:   counter=1
93:   while [ -e "${base}-${counter}.md" ]; do
94:     counter=$((counter+1))
95:   done
96:   OUT_PATH="${base}-${counter}.md"
97: fi
```

**Previous gap:** unconditional `> "$OUT_PATH"` overwrote immutable `raw/`; `--out` unsanitized.

**Fix implements both requirements exactly as handoff asked:**
- `--out` clamp: must be `research/raw/*` or `$REPO_ROOT/research/raw/*`, else `exit 1` (`:79-81`); rejects `..` anywhere (`:83-85`). Prevents `research/wiki/evil`, `/tmp/evil`, `../`, `research/raw/../wiki` escapes.
- Counter suffix: `[ -e "$OUT_PATH" ]` → `${base}-${counter}.md` loop (`:90-96`). Preserves raw immutability (`research/CLAUDE.md:11`).

**Live probes (executed 2026-08-28):**

| Test | Command | Result |
|------|---------|--------|
| suffix 1st ingest | `bash research/scripts/ingest.sh "https://example.com/test-suffix-unique-12345"` | `research/raw/articles/generic_web-test-suffix-unique-12345.md` exit 0 |
| suffix 2nd same URL | same URL again | `generic_web-test-suffix-unique-12345-1.md` exit 0 — no overwrite |
| suffix 3rd | same | `-2.md` exit 0 |
| --out outside | `--out /tmp/evil.md` | `ERROR: --out must be under research/raw/` exit 1 |
| --out wiki | `--out research/wiki/evil.md` | exit 1 |
| --out .. | `--out research/raw/../wiki/evil.md` | `ERROR: --out must not contain ..` exit 1 |
| --out ../articles | `--out research/raw/articles/../github/evil.md` | exit 1 (contains `..`) |
| --out valid | `--out research/raw/articles/custom-valid-test.md` | exit 0, file under `articles/` |
| --out absolute valid | `--out $REPO_ROOT/research/raw/articles/custom-abs-test.md` | exit 0 |
| injection dry-run | `'https://example.com/a?x="b"&y=1' --dry-run` | `yaml safe: "https://example.com/a?x=\"b\"&y=1"` PASS |

Fix is correct. Edge: counter uses `-e` (covers files+dirs), increments until free slot — handles N collisions. `..` check is substring, so `research/raw/a..b.md` would also reject (conservative, safe). No bypass found (absolute path variant only allowed if under `$REPO_ROOT/research/raw/`).

---

## 2. Gate 2 P0 Still CLOSED

### P0-1 Iron Rule — CLOSED ✓

`research/canon/lint.sh:60-190` 6 rules: valid YAML (`ruby -ryaml` + `yq --front-matter=extract`), `raw_refs ≥1` + `claim_count==raw_refs_len` fallback to `[^raw/` count, path exists, `locator =~ p.\|para\|timestamp`, depth derivation.

Live: `bash research/canon/lint.sh` → 5/5 PASS (`concepts/guardrail-layers.md`, `research/mcp-prompt-injection.md`, `wiki/research/mcp-prompt-injection.md`, `wiki/topics/guardrail-layers.md`, `wiki/topics/mcp-security.md`) exit 0. Negative `sed '/locator/d' /tmp/bad.md` → `FAIL: rule4: missing locator` exit 1. AC-E 3 negatives supported.

### P0-2 YAML Injection — CLOSED ✓

`research/scripts/ingest.sh:99-105` uses `yq strenv` safe emission, no shell interpolation:
`URL="$URL" TYPE=... yq -n '.original_url = strenv(URL) | ...' > "$TMP_YAML"` (`:104-105`), then `ruby -ryaml` validate (`:108-118`).

Live injection:
- `'https://example.com/a?x="b"&y=1'` → `yq -o json` = `"https://example.com/a?x=\"b\"&y=1"`; written file `ruby YAML.load_file PASS`, `yq front-matter extract true PASS`.
- `'https://example.com/a?evil=": bad'` → dry-run `yaml safe: "...\" : bad"` ; live file `-1.md` `ruby PASS`.
- Multiline `"\nevil: injected"` → blocked before yq at `source-preprocessor.sh validate` (`[\;\|\&\$\`\(\)\{\}]` at `.tad/cross-model/source-preprocessor.sh:36-40`) → `ERROR: invalid URL (preprocessor validate failed)` exit 1. Defense-in-depth. `&` alone is allowlisted with WARN (`ingest.sh:39-42` stripped-check) because `&` is legitimate in query strings and yq handles it safely.

`lint.sh:64-80` rule 6 also covers durability for any future file.

No `normalize_url` reimplementation: `rg normalize_url research/scripts/ingest.sh` only comment `:6`.

---

## 3. Other Security Items Still PASS

| Check | Verdict | Evidence |
|-------|---------|----------|
| **Credential leak** | PASS | `rg -i "ghp_|gho_|github_pat|sk-proj|sk-ant|AKIA" research/` 0 hits; `rg api_key\|secret` only `migrated-ai-guardrails.md:210` placeholder `REBUFF_API_KEY` and `<SECRET>` mask; `ingest.sh` dry-run prints only `detect:` + `yaml safe:` (URL, not secret); `lint.sh`/`generate.py` print no secrets; `REGISTRY.yaml` 34 archived, no delete token. |
| **Path traversal (URL-derived)** | PASS | `RAW_SLUG` sanitize `tr upper lower \| sed s/[^a-z0-9]+/-/g` (`ingest.sh:73`), `SLUG="${SOURCE_TYPE}-${RAW_SLUG}"` (`:76`), `mkdir -p "$(dirname "$OUT_PATH")"` only under `research/raw/${MEDIUM}`. Live `https://example.com/../../etc/passwd` → `generic_web-passwd.md` under `articles/`, no `../` escape; find confirms `research/raw/articles/generic_web-passwd.md` isolated. |
| **generate.py overwrite** | PASS | `generate.py:303-317` writes only `canon/_index.md`, `wiki/index.md`, `wiki/topics/_clusters.md`; `rg raw research/scripts/generate.py` no raw write; stdlib only `argparse,os,re,sys,pathlib` (`:12-16`), no pip/curl, idempotent. |
| **Iron Rule body discipline** | PASS | `grep "Iron Rule" .claude/skills/alex/SKILL.md` hits at `838` in body (not only references/), per `principles.md:103`. |
| **Supply chain** | PASS | `generate.py` stdlib only; `lint.sh:67` `ruby -ryaml`, `lint.sh:75,85` `yq v4.53.3` present; `ingest.sh:104` `yq strenv` + `ruby`/`python3 yaml` fallback; handlers `curl -s --connect-timeout 10 --max-time 25 -w "\n%{http_code}" -H "Accept: text/markdown" -- "https://r.jina.ai/${url}"` (`handlers/jina-handler.sh:25`) fixed base + `--` terminator; `rg "curl.*\$URL" research/ .tad/cross-model/handlers/` 0 hits on unsanitized URL; no `pip install --upgrade`, no lock drift. |
| **Fallback no cloud delete** | PASS | `REGISTRY.yaml` `grep -c 'status: archived'` 34; no `notebooklm delete` call; migration `cp` to `raw/papers/` via `manifests/migrated-from-notebooklm.txt:1-8`. |

All AC security mappings (AC-A to AC-J table from 2026-08-28 report) unchanged PASS — `AC-D` path traversal now fully PASS with `--out` clamp, `AC-E` lint 6 rules, `AC-F` pure function, `AC-G` `local_wiki` routing at `.tad/config-workflow.yaml:789-791`.

---

## 4. Findings Summary

| ID | Severity | Title | Status | File:line |
|----|----------|-------|--------|-----------|
| P0-1 | P0 | Iron Rule validation theater | CLOSED | `research/canon/lint.sh:64-80,95-190` |
| P0-2 | P0 | YAML injection via `original_url` | CLOSED | `research/scripts/ingest.sh:99-118` (`strenv`+`ruby`), `research/canon/lint.sh:64-80` |
| P1-1 | P1 | Credential leak | CLOSED | `research/raw/papers/migrated-ai-guardrails.md:210` placeholder only |
| P1-2 | P1 | File overwrite / --out unsanitized | **CLOSED (fixed)** | `research/scripts/ingest.sh:77-97` (clamp+counter); live suffix + outside-raw fails verified |
| P1-3 | P1 | `contradiction` field | CLOSED-DEFERRED | `research/CLAUDE.md:27` Deep only per handoff §4.1 |
| P1-4 | P1 | Saturation metric | CLOSED | `research/CLAUDE.md:32-33`, `research/wiki/log.md:1-3` |
| P2-1 | P2 | Supply chain unvetted deps | CLOSED | `research/scripts/generate.py:12-16`, `.tad/cross-model/handlers/jina-handler.sh:25` |

---

## 5. Evidence Index (absolute paths)

- `/Users/sheldonzhao/01-on progress programs/TAD/research/scripts/ingest.sh:1-160` (fix `:76-97`, yq `:104-105`, validate `:38-47`)
- `/Users/sheldonzhao/01-on progress programs/TAD/research/canon/lint.sh:1-234` (`:64-80` YAML, `:95-190` Iron Rule)
- `/Users/sheldonzhao/01-on progress programs/TAD/research/scripts/generate.py:1-324` (`:12-16` stdlib, `:303-317` writes)
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/cross-model/source-preprocessor.sh:27-77` (normalize/validate)
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/cross-model/handlers/jina-handler.sh:25` (curl --)
- `/Users/sheldonzhao/01-on progress programs/TAD/research/CLAUDE.md:1-41` + `research/canon/README.md:14-117` + `research/canon/_topics.yaml:14-15`
- `/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/HANDOFF-20260828-local-wiki-research-framework.md:1-383`

Live probes: suffix creates `-1.md/-2.md`; `--out` outside `research/raw/` exit 1 with `ERROR: --out must be under research/raw/` or `must not contain ..`; injection `yq safe` quoted, `ruby`+`yq front-matter extract` PASS; `lint.sh` PASS exit 0.

---

*Independent re-review — source read + live bash/yq/ruby probes, not COMPLETION narrative. Overwrites 2026-08-28 CONDITIONAL PASS. Fix evidence file:line as requested.*
