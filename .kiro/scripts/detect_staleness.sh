#!/bin/bash
# detect_staleness.sh - Wrapper for detect_staleness.py

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/detect_staleness.py"

# Check if Python script exists
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "[ERROR] Python script not found: $PYTHON_SCRIPT" >&2
    exit 1
fi

# Run Python script with all arguments
python3 "$PYTHON_SCRIPT" "$@"
