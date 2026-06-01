#!/usr/bin/env bash
# curate-and-ask.sh — Phase 1c: per pack, curate (delete error sources) + 5 seed asks → findings.md
# Run AFTER collection (deep research import) completes. Sequential (NotebookLM stateful).
set -uo pipefail
cd "/Users/sheldonzhao/01-on progress programs/TAD"
NB=~/.tad-notebooklm-venv/bin/notebooklm
BASE=.tad/evidence/research/agent-pack-factory
NBFILE="$BASE/notebooks.txt"

Q1='List the specific tools, libraries, and frameworks for this notebook topic. For EACH: exact name, one-line what-it-does, the install command or CLI invocation, and the source. Prefer concrete commands over concepts.'
Q2='What specific quantitative values appear in the sources for this topic — thresholds, benchmark scores, recommended sizes/counts, cost figures, latency targets, dimensions? List each number with its meaning and source. Give exact figures, do not generalize.'
Q3='What are the named expert rules, anti-patterns, and common failure modes for this topic? What do practitioners say beginners get wrong? Give each as a specific rule with its consequence and source.'
Q4='Decompose this topic into 4 to 6 distinct sub-capabilities a practitioner must master. For each: a short name, the core decision it involves, and 3-5 signal phrases a user would say when they need it.'
Q5='What is the single most important cross-cutting principle for this topic that, if violated, undermines everything — state it with its quantified consequence. Then give a tool-selection decision table: goal then recommended tool then why.'

ask() { # $1=id $2=question
  $NB ask "$2" -n "$1" 2>&1
}

while IFS='|' read -r slug id task; do
  [[ "$slug" == \#* ]] && continue
  [[ -z "$slug" ]] && continue
  OUT="$BASE/$slug/findings.md"
  echo "===== $slug ($id) ====="
  # Curate: delete error sources
  err_ids=$($NB source list --json -n "$id" 2>/dev/null | jq -r '.[] | select(.status | test("error")) | .id' 2>/dev/null)
  ndel=0
  if [[ -n "$err_ids" ]]; then
    while read -r eid; do
      [[ -z "$eid" ]] && continue
      $NB source delete "$eid" -n "$id" --yes >/dev/null 2>&1 && ndel=$((ndel+1))
      sleep 0.3
    done <<< "$err_ids"
  fi
  total=$($NB source list --json -n "$id" 2>/dev/null | jq 'length' 2>/dev/null)
  echo "  curated: deleted $ndel error sources, $total remain"

  {
    echo "# Research Findings: $slug"
    echo "Notebook: $id | Sources: $total (deleted $ndel errors) | Date: 2026-05-31"
    echo "Method: NotebookLM deep research + 5 seed asks. Numbers below carry source citations [N] — build agent MUST preserve provenance."
    echo ""
  } > "$OUT"

  i=0
  for q in "$Q1" "$Q2" "$Q3" "$Q4" "$Q5"; do
    i=$((i+1))
    echo "  ask Q$i ..."
    {
      echo "## Q$i: $q"
      echo ""
      ask "$id" "$q"
      echo ""
      echo "---"
      echo ""
    } >> "$OUT"
    sleep 1
  done
  echo "  ✓ findings saved: $OUT ($(wc -l < "$OUT") lines)"
done < "$NBFILE"
echo "===== ALL FINDINGS COMPLETE ====="
