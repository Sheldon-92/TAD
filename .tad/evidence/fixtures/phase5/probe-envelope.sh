#!/bin/bash
# Phase 5 §0 spike — capture AskUserQuestion PostToolUse stdin envelope
ENVELOPE_FILE=".tad/evidence/fixtures/phase5/askuser-envelope-probe.json"
mkdir -p "$(dirname "$ENVELOPE_FILE")"
cat > "$ENVELOPE_FILE"
exit 0
