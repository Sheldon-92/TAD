#!/bin/bash
# NotebookLM one-time auth setup for TAD
# Usage: bash .tad/cross-model/setup-notebooklm.sh
#
# Run this once to authenticate, then again when session expires (typically weeks).
# Auth path mismatch fix: notebooklm login stores browser_profile, CLI reads storage_state.json
# This script bridges the gap with a Playwright export step.

set -e

VENV_PATH="${HOME}/.tad-notebooklm-venv"

echo "=== NotebookLM TAD Setup ==="
echo ""

# Check Python 3.10+ (notebooklm-py uses str | None union syntax, fails on 3.9)
PYTHON_BIN="${PYTHON_BIN:-python3}"
if ! "$PYTHON_BIN" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then
    echo "❌ Need Python 3.10+. Found: $("$PYTHON_BIN" --version 2>&1)"
    echo "   Set PYTHON_BIN to a 3.10+ interpreter, e.g.:"
    echo "   PYTHON_BIN=/opt/homebrew/bin/python3.13 bash .tad/cross-model/setup-notebooklm.sh"
    exit 1
fi
echo "✅ Python version: $("$PYTHON_BIN" --version)"

# Step 1: Create persistent venv (not /tmp — survives reboot)
if [ ! -d "$VENV_PATH" ]; then
    echo "Creating venv at $VENV_PATH..."
    "$PYTHON_BIN" -m venv "$VENV_PATH"
    echo "✅ Venv created"
else
    echo "✅ Venv exists at $VENV_PATH"
fi

source "$VENV_PATH/bin/activate"

# Step 2: Install pinned version (security principle: never upgrade blindly)
echo ""
echo "Installing notebooklm-py==0.1.1 (pinned for supply-chain safety)..."
pip install -q "notebooklm-py[browser]==0.1.1"
playwright install chromium 2>/dev/null || echo "  (playwright chromium may already be installed)"
echo "✅ notebooklm-py installed"

# Step 3: Login (interactive — requires user action)
echo ""
echo "Opening browser for Google login..."
echo "Complete the Google login in the browser window, then return here and press Enter."
echo ""
notebooklm login

# Step 4: Export session state (bridge browser_profile → storage_state.json)
echo ""
echo "Exporting session to ~/.notebooklm/storage_state.json..."
"$VENV_PATH/bin/python" -c "
from playwright.sync_api import sync_playwright
import json, os
profile = os.path.expanduser('~/.notebooklm/browser_profile')
out = os.path.expanduser('~/.notebooklm/storage_state.json')
with sync_playwright() as p:
    ctx = p.chromium.launch_persistent_context(profile, headless=True)
    state = ctx.storage_state()
    json.dump(state, open(out, 'w'))
    ctx.close()
    cookies = state.get('cookies', [])
    if not cookies:
        print('❌ No cookies in session — login may have been incomplete.')
        raise SystemExit(1)
    print(f'✅ Session exported ({len(cookies)} cookies) to ~/.notebooklm/storage_state.json')
"

# Verify export non-empty
STATE_FILE="${HOME}/.notebooklm/storage_state.json"
if [ ! -s "$STATE_FILE" ]; then
    echo "❌ storage_state.json is empty — setup failed. Re-run from Step 3."
    exit 1
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "To use NotebookLM CLI (absolute path — no activation needed):"
echo "  $VENV_PATH/bin/notebooklm ask 'your question'"
echo ""
echo "Or from TAD (Alex *discuss context):"
echo "  *research-notebook ask 'your question'"
echo ""
echo "If auth expires later, re-run this script."
