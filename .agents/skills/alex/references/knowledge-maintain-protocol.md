# Knowledge Maintenance Protocol

> Run after distillation_loop produces a new entry, or via standalone *knowledge-maintain.
> Rule-driven, near-zero LLM calls (except reconciliation step). Fully advisory — proposes, never auto-executes.

## 1. Hash-Dedup Pre-Filter (zero LLM)

Normalize the new entry's `label` + `value` (lowercase, strip whitespace, strip punctuation):
```bash
echo -n "$normalized" | md5 -q    # macOS; Linux: md5sum | cut -d' ' -f1
```
Compare against the same normalized hash of all existing entries in project-knowledge/.
- Exact match → **NOOP**: report "byte-identical entry already exists: {existing_label}". Do not add.
- No match → continue to next step.

## 2. Candidate Retrieval (lexical, _index.md)

Extract keywords from the new entry's `selector` + `label`.
Match against `project-knowledge/patterns/_index.md` and `### ` headings in each category.md
using in-context LLM semantic judgment (not grep — use Alex's context window, no extra API call).
Take top-5 most similar existing entries as the candidate set.

Known limitation: this is lexical + in-context LLM matching, not embedding retrieval.
Entries described in completely different words for the same pattern will be missed
(over-ADD is the expected failure mode). Accept this limit; do not fake "semantic retrieval."

## 3. Reconciliation (LLM, 4-way decision)

Present the new entry + top-5 candidates to Alex as a numbered list:

```
## Existing candidates (number = temporary ID, not real ID):
0: [label: bgm-loop-seam, selector: "...", failure_mode: "..."]
1: [label: tts-reference-audio, selector: "...", failure_mode: "..."]
...

## New entry:
[label: bgm-swell-volume, selector: "...", value: "...", failure_mode: "..."]

## For each candidate, judge the relationship with the new entry (must pick one):
- ADD: new entry is new information, no overlap with any candidate → add directly
- UPDATE {N}: new entry is an updated version of candidate N (keep original label, merge richer content) → propose
- DELETE {N}: new entry contradicts candidate N (not supplementary, negates it) → propose
- NOOP: new entry's information is fully covered by an existing candidate, nothing new → do not add
```

Numbered→label mapping: temporary numbers are used only for the reconciliation judgment;
output translates back to real labels (anti-hallucination, Mem0 UUID→int technique).

NOOP is a first-class citizen: default is "do nothing", not "append." (Mem0 lesson)

## 4. Human Gate (DELETE/UPDATE only)

- **ADD** → execute directly (write entry to playbook)
- **NOOP** → do not execute (report "covered by {existing_label}")
- **UPDATE {label}** → show old vs new comparison → AskUserQuestion: "Update {label}?" →
  execute only on user confirmation; UPDATE keeps original label, merges content (keep the
  version with more information), old version preserved as comment for audit trail
  - **User rejects UPDATE** → new entry still ADDed (two entries coexist). Report: "UPDATE
    rejected, new entry added as independent item. May have overlap — next *knowledge-maintain
    will re-detect." (Do not discard new entry — information loss > mild duplication)
- **DELETE {label}** → show rationale + contradiction evidence → AskUserQuestion: "Delete
  {label}?" → execute only on user confirmation; DELETE does not physically remove from file,
  marks with `[SUPERSEDED by {new_label}, {date}]`
  - **User rejects DELETE** → new entry still ADDed (contradictory entries coexist). Report:
    "DELETE rejected, contradictory entries coexist — recommend manual review to decide which
    to keep."

## 5. Usage-Utility Retire Signal (honest approximation)

Problem: on a file system, cannot precisely track "how many recent tasks actually used this entry"
like SkillOps does.

Approximation:
- During each distillation_loop step1 (read journal) and step0_5 (handoff creation knowledge reload):
  log "which _index.md entries matched this task" to `evidence/knowledge-usage-log.jsonl`
  Format: `{"date":"2026-06-22","handoff":"xxx","matched_labels":["bgm-loop-seam","tts-ref"]}`
- When *knowledge-maintain runs: read last N entries (default 20) from usage-log, count label frequency
  - 0 matches in last 20 tasks → annotate "[LOW-USAGE — not matched in last 20 tasks]"
  - Do not auto-delete; annotate only, human decides

Known limitations (honestly listed):
- Does NOT cover Blake's `1_5_context_refresh` (the most frequent auto-load path — runs every task,
  keyword-matches pattern files). Covering it requires adding a log emit line in Blake SKILL, which
  is cross-agent write — not done in this phase (protocol boundary).
- Does NOT cover direct human Read of files.
- Therefore usage signal **significantly underestimates** entries frequently loaded by Blake.
  LOW-USAGE annotation is advisory only, never the sole basis for retirement.

## 5b. Dedup Health Metric (over-ADD early warning)

When *knowledge-maintain runs, append an entry-count health check:
```bash
for f in "$DIR"/*.md "$DIR"/patterns/*.md; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  [[ "$base" == "README.md" || "$base" == "_index.md" ]] && continue
  count=$(grep -c '^### ' "$f" 2>/dev/null || echo 0)
  if [ "$count" -gt 30 ]; then
    echo "WARN: $base has $count entries (>30) — consider manual consolidation review"
  fi
done
```
More than 30 entries = leading signal that over-ADD happened (lexical candidate selection missed
synonymous duplicates). WARN level, does not block.

## 6. Lint Integration

Run `knowledge-lint.sh` on project-knowledge/ to check all entries for format compliance.
See script at `.tad/hooks/lib/knowledge-lint.sh`. Results displayed to user, never blocks.
