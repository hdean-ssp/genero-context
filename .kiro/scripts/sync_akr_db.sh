#!/bin/bash
# Wrapper for sync_akr_db.py
# This script syncs markdown files from AKR to SQLite database using Python

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${SCRIPT_DIR}/sync_akr_db.py" "$@"
