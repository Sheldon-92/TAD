#!/bin/bash
# AC8: No changes to settings.json
changes=$(git diff --name-only .claude/settings.json 2>/dev/null)
if [ -z "$changes" ]; then
  echo "PASS: no settings.json changes"
  exit 0
else
  echo "FAIL: settings.json was modified"
  exit 1
fi
