#!/usr/bin/env bash
set -euo pipefail

CMD="${1:?Usage: step4d-run.sh <prepare|finalize> <slug> [json-path]}"
SLUG="${2:?Usage: step4d-run.sh <prepare|finalize> <slug> [json-path]}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

case "$CMD" in
  prepare)
    # Skip check 1: environment variable opt-out
    if [ "${TAD_NO_JUDGE:-0}" = "1" ]; then
      echo "judge: skipped (TAD_NO_JUDGE=1)"
      exit 0
    fi

    # Skip check 2: judge-prompt.md must exist
    if [ ! -f "$SCRIPT_DIR/judge-prompt.md" ]; then
      echo "judge: skipped (judge-prompt.md not found)"
      exit 0
    fi

    # Skip check 3: assembler must succeed
    BUNDLE_OUTPUT=$(bash "$SCRIPT_DIR/assemble-bundle.sh" "$SLUG" 2>&1) || {
      echo "judge: skipped (assembler failed: $BUNDLE_OUTPUT)"
      exit 0
    }

    BUNDLE_PATH="$SCRIPT_DIR/bundles/${SLUG}.md"
    if [ ! -f "$BUNDLE_PATH" ] || [ ! -s "$BUNDLE_PATH" ]; then
      echo "judge: skipped (bundle empty or missing)"
      exit 0
    fi

    echo "$BUNDLE_PATH"
    ;;

  finalize)
    JSON_PATH="${3:?Usage: step4d-run.sh finalize <slug> <json-path>}"
    EVIDENCE_DIR="$ROOT/evidence/acceptance-tests/${SLUG}"
    DEST="$EVIDENCE_DIR/trajectory-judge.json"

    if [ ! -f "$JSON_PATH" ]; then
      echo "judge: skipped (json file not found: $JSON_PATH)"
      exit 0
    fi

    # Schema validation: all 5 dimensions present with valid score+rationale
    VALID=$(jq -e '[.D1,.D2,.D3,.D4,.D5] | all(type=="object" and ((.score|type=="number" and .>=1 and .<=5) or .score=="UNRECOVERABLE") and (.rationale|type=="string" and length>0))' "$JSON_PATH" 2>/dev/null) || VALID="false"

    if [ "$VALID" != "true" ]; then
      echo "judge: skipped (invalid-json)"
      exit 0
    fi

    mkdir -p "$EVIDENCE_DIR"
    cp "$JSON_PATH" "$DEST"
    echo "judge: finalized $DEST"
    ;;

  *)
    echo "ERROR: unknown command '$CMD'. Use 'prepare' or 'finalize'." >&2
    exit 1
    ;;
esac
