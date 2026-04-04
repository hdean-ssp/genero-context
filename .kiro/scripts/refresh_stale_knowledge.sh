#!/bin/bash
# refresh_stale_knowledge.sh - Wrapper for refresh_stale_knowledge.py

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/refresh_stale_knowledge.py"

# Check if Python script exists
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "[ERROR] Python script not found: $PYTHON_SCRIPT" >&2
    exit 1
fi

# Run Python script with all arguments
python3 "$PYTHON_SCRIPT" "$@"
