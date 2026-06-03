#!/bin/bash
# tournament-codex.sh — Tournament design exploration via Codex CLI subagents
# Equivalent to tournament-design.workflow.js but using sequential codex exec calls
# Standard mode only (2 competitors + 1 judge + 1 synthesizer)
#
# Usage: tournament-codex.sh --task <file> --prior-art <file1> <file2> [--rubric <file>] [--output <file>]
# All args are file paths — file-as-source-of-truth principle

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMA_DIR="${SCRIPT_DIR}/schemas"

# ── Arg parsing ──────────────────────────────────────────────────

TASK_FILE=""
PRIOR_ART=()
RUBRIC_FILE=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      TASK_FILE="$2"
      shift 2
      ;;
    --prior-art)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
        PRIOR_ART+=("$1")
        shift
      done
      ;;
    --rubric)
      RUBRIC_FILE="$2"
      shift 2
      ;;
    --output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    *)
      echo "ERROR: Unknown arg: $1" >&2
      echo "Usage: $0 --task <file> --prior-art <f1> <f2> [--rubric <file>] [--output <file>]" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$TASK_FILE" ]]; then
  echo "ERROR: --task is required" >&2
  exit 1
fi
if [[ ${#PRIOR_ART[@]} -lt 2 ]]; then
  echo "ERROR: --prior-art requires at least 2 files" >&2
  exit 1
fi
if [[ ! -f "$TASK_FILE" ]]; then
  echo "ERROR: Task file not found: $TASK_FILE" >&2
  exit 1
fi

RUBRIC_DIMS="feasibility, elegance, extensibility, principle_alignment"
if [[ -n "$RUBRIC_FILE" && -f "$RUBRIC_FILE" ]]; then
  RUBRIC_DIMS=$(cat "$RUBRIC_FILE")
fi

# ── Temp dir with cleanup ────────────────────────────────────────

TAD_TMPDIR=$(mktemp -d -t tad-tournament.XXXXXX)
trap 'rm -rf "$TAD_TMPDIR"' EXIT

echo "Tournament: task=$(basename "$TASK_FILE"), competitors=${#PRIOR_ART[@]}, tmpdir=$TAD_TMPDIR"

check_step() {
  local step="$1" file="$2"
  if [[ ! -f "$file" ]]; then
    echo "ERROR: $step failed — output file not created: $file" >&2
    exit 1
  fi
  if [[ ! -s "$file" ]]; then
    echo "ERROR: $step failed — output file is empty: $file" >&2
    exit 1
  fi
  if ! python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$file" 2>/dev/null; then
    echo "ERROR: $step failed — output is not valid JSON: $file" >&2
    exit 1
  fi
}

TASK_CONTENT=$(cat "$TASK_FILE")

# ── Step 1: Competitor A ─────────────────────────────────────────

echo "[1/4] Competitor A..."

PRIOR_A_CONTENT=$(cat "${PRIOR_ART[0]}")

codex exec \
  --sandbox workspace-write \
  --output-last-message "$TAD_TMPDIR/design-a.txt" \
  --output-schema "$SCHEMA_DIR/design.json" \
  -o "$TAD_TMPDIR/design-a.json" \
  "You are Design Competitor A. Your task:

${TASK_CONTENT}

Your assigned prior art (base your approach on it):
${PRIOR_A_CONTENT}

Scoring rubric dimensions: ${RUBRIC_DIMS}
Optimize your design for these dimensions.

Produce a complete, concrete design. Be specific — include data structures, APIs, file layouts, or whatever the task demands. Name your approach something descriptive.

Return your answer as JSON matching the output schema."

check_step "Competitor A" "$TAD_TMPDIR/design-a.json"
echo "  Competitor A done: $TAD_TMPDIR/design-a.json"

# ── Step 2: Competitor B ─────────────────────────────────────────

echo "[2/4] Competitor B..."

PRIOR_B_CONTENT=$(cat "${PRIOR_ART[1]}")

codex exec \
  --sandbox workspace-write \
  --output-last-message "$TAD_TMPDIR/design-b.txt" \
  --output-schema "$SCHEMA_DIR/design.json" \
  -o "$TAD_TMPDIR/design-b.json" \
  "You are Design Competitor B. Your task:

${TASK_CONTENT}

Your assigned prior art (base your approach on it):
${PRIOR_B_CONTENT}

Scoring rubric dimensions: ${RUBRIC_DIMS}
Optimize your design for these dimensions.

Produce a complete, concrete design. Be specific — include data structures, APIs, file layouts, or whatever the task demands. Name your approach something descriptive.

Return your answer as JSON matching the output schema."

check_step "Competitor B" "$TAD_TMPDIR/design-b.json"
echo "  Competitor B done: $TAD_TMPDIR/design-b.json"

# ── Step 3: Judge ────────────────────────────────────────────────

echo "[3/4] Judge evaluating..."

DESIGN_A=$(cat "$TAD_TMPDIR/design-a.json")
DESIGN_B=$(cat "$TAD_TMPDIR/design-b.json")

codex exec \
  --sandbox workspace-write \
  --output-last-message "$TAD_TMPDIR/judge.txt" \
  --output-schema "$SCHEMA_DIR/judge.json" \
  -o "$TAD_TMPDIR/judge.json" \
  "You are an impartial design judge. Compare these two designs:

## Design A
${DESIGN_A}

## Design B
${DESIGN_B}

Score each design 0-10 on these dimensions: ${RUBRIC_DIMS}

Pick a winner. Return 'A' or 'B' as winner/loser, plus the full approach_name as winner_name/loser_name.
Critically: identify what the LOSER did better — specific sub-ideas that the winner lacks and should incorporate.

Return your answer as JSON matching the output schema."

check_step "Judge" "$TAD_TMPDIR/judge.json"
echo "  Judge done: $TAD_TMPDIR/judge.json"

# ── Determine winner ─────────────────────────────────────────────

WINNER_LABEL=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('winner','A'))" "$TAD_TMPDIR/judge.json" 2>/dev/null || echo "A")
if [[ "$WINNER_LABEL" == "A" ]]; then
  WINNER_DESIGN="$DESIGN_A"
  WINNER_NAME=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('approach_name','Design A'))" "$TAD_TMPDIR/design-a.json")
else
  WINNER_DESIGN="$DESIGN_B"
  WINNER_NAME=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('approach_name','Design B'))" "$TAD_TMPDIR/design-b.json")
fi

LOSER_INSIGHTS=$(python3 -c "
import json, sys
j = json.load(open(sys.argv[1]))
items = j.get('what_loser_did_better', [])
for i, item in enumerate(items):
    print(f'{i+1}. {item}')
" "$TAD_TMPDIR/judge.json")

echo "  Winner: $WINNER_NAME ($WINNER_LABEL)"

# ── Step 4: Synthesizer ──────────────────────────────────────────

echo "[4/4] Synthesizing merged design..."

JUDGE_RESULT=$(cat "$TAD_TMPDIR/judge.json")

codex exec \
  --sandbox workspace-write \
  --output-last-message "$TAD_TMPDIR/merged.txt" \
  --output-schema "$SCHEMA_DIR/merged.json" \
  -o "$TAD_TMPDIR/merged.json" \
  "You are a design synthesizer. Create the BEST POSSIBLE merged design.

## Tournament Winner (use as base):
${WINNER_DESIGN}

## Best Ideas from Losers:
${LOSER_INSIGHTS}

## Judge Evaluation:
${JUDGE_RESULT}

Create a merged design that:
1. Uses the winner as the foundation
2. Grafts in specific sub-ideas from losers where they genuinely improve the design
3. Resolves any conflicts between grafted ideas and the base
4. Produces a design that NO single competitor would have created

Be specific about which loser ideas you incorporated and why.

Return your answer as JSON matching the output schema."

check_step "Synthesizer" "$TAD_TMPDIR/merged.json"
echo "  Synthesizer done: $TAD_TMPDIR/merged.json"

# ── Output ───────────────────────────────────────────────────────

if [[ -n "$OUTPUT_FILE" ]]; then
  cp "$TAD_TMPDIR/merged.json" "$OUTPUT_FILE"
  echo "Result written to: $OUTPUT_FILE"
else
  cat "$TAD_TMPDIR/merged.json"
fi

echo ""
echo "Tournament complete (Codex sequential pipeline)"
echo "  Competitors: 2, Judge: 1, Synthesizer: 1"
echo "  Winner: $WINNER_NAME"
