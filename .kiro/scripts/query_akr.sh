#!/bin/bash
# Wrapper for query_akr.py
# This script queries the AKR database using Python

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "${SCRIPT_DIR}/query_akr.py" "$@"
