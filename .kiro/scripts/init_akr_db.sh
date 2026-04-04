#!/bin/bash
# Wrapper for init_akr_db.py
# This script initializes the SQLite database for AKR using Python

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${SCRIPT_DIR}/init_akr_db.py" "$@"
