#!/bin/bash
# Wrapper for track_source_hashes.py
# This script tracks SHA256 hashes of source files using Python

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${SCRIPT_DIR}/track_source_hashes.py" "$@"
