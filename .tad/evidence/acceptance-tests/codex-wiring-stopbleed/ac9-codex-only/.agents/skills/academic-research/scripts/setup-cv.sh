#!/usr/bin/env bash
# Setup virtual environment for academic-research CV tools
# Installs opencv-python-headless + numpy + scikit-image + Pillow
set -euo pipefail

VENV_DIR="${HOME}/.academic-research-cv-venv"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQ_FILE="${SCRIPT_DIR}/requirements.txt"

if [[ ! -f "$REQ_FILE" ]]; then
  echo "ERROR: requirements.txt not found at ${REQ_FILE}" >&2
  exit 1
fi

echo "=== Academic Research CV Tools Setup ==="
echo "Venv: ${VENV_DIR}"
echo ""

if [[ -d "${VENV_DIR}" ]]; then
  echo "Existing venv found. Updating dependencies..."
else
  echo "Creating virtual environment..."
  if command -v uv >/dev/null 2>&1; then
    uv venv "${VENV_DIR}"
  else
    python3 -m venv "${VENV_DIR}"
  fi
fi

echo "Installing dependencies..."
if command -v uv >/dev/null 2>&1; then
  uv pip install --python "${VENV_DIR}/bin/python3" -r "${REQ_FILE}"
else
  "${VENV_DIR}/bin/pip" install -r "${REQ_FILE}"
fi

echo ""
echo "Validating installation..."
"${VENV_DIR}/bin/python3" -c "
import cv2
import numpy
import skimage
import PIL
print(f'  opencv:       {cv2.__version__}')
print(f'  numpy:        {numpy.__version__}')
print(f'  scikit-image: {skimage.__version__}')
print(f'  Pillow:       {PIL.__version__}')
"

echo ""
echo "✅ Setup successful! Dependencies installed to: ${VENV_DIR}"
echo ""
echo "Usage:"
echo "  ${VENV_DIR}/bin/python3 scripts/image-analysis.py edges input.jpg --output edges.svg"
echo "  ${VENV_DIR}/bin/python3 scripts/image-analysis.py colors input.jpg --output colors.json"
echo "  ${VENV_DIR}/bin/python3 scripts/image-analysis.py match img1.jpg img2.jpg --output result.json"
echo "  ${VENV_DIR}/bin/python3 scripts/image-analysis.py frequency input.jpg --output freq.json"
echo "  ${VENV_DIR}/bin/python3 scripts/image-analysis.py features input.jpg --output features.json"
