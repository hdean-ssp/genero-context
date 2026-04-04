#!/bin/bash
# Wrapper for detect_akr_conflicts.py
# This script detects concurrent write conflicts in AKR using Python

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${SCRIPT_DIR}/detect_akr_conflicts.py" "$@"
