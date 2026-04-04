#!/bin/bash
# Wrapper for detect_source_changes.py
# This script detects source code changes and marks stale knowledge using Python

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${SCRIPT_DIR}/detect_source_changes.py" "$@"
