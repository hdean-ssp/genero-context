#!/bin/bash

################################################################################
# get_statistics.sh - Get AKR statistics and adoption metrics
#
# Purpose: Track adoption and usage metrics including document counts,
#          agent activity, and trends.
#
# Usage: bash get_statistics.sh [--format text|json|csv]
#
# Parameters:
#   --format <format>   Output format: text (default), json, csv
#
# Exit Codes:
#   0 - Success
#   1 - Error
#
################################################################################

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/akr-config.sh"

# Logging
log_error() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [ERROR] $*" >> "${GENERO_AKR_LOGS}/akr.log"
}

# Parse arguments
FORMAT="text"

while [[ $# -gt 0 ]]; do
    case $1 in
        --format) FORMAT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate format
case "$FORMAT" in
    text|json|csv) ;;
    *) 
        log_error "Invalid format: $FORMAT (must be text, json, or csv)"
        exit 1
        ;;
esac

# Validate AKR base path
if [[ ! -d "$GENERO_AKR_BASE_PATH" ]]; then
    log_error "AKR base path does not exist: $GENERO_AKR_BASE_PATH"
    exit 1
fi

# Count documents by type
count_documents() {
    local type=$1
    local path=$2
    
    if [[ -d "$path" ]]; then
        find "$path" -name "*.md" -type f 2>/dev/null | wc -l
    else
        echo 0
    fi
}

FUNC_COUNT=$(count_documents "functions" "${GENERO_AKR_FUNCTIONS}")
FILE_COUNT=$(count_documents "files" "${GENERO_AKR_FILES}")
MOD_COUNT=$(count_documents "modules" "${GENERO_AKR_MODULES}")
PAT_COUNT=$(count_documents "patterns" "${GENERO_AKR_PATTERNS}")
ISS_COUNT=$(count_documents "issues" "${GENERO_AKR_ISSUES}")
TOTAL=$((FUNC_COUNT + FILE_COUNT + MOD_COUNT + PAT_COUNT + ISS_COUNT))

# Get last updated timestamp
LAST_UPDATED="N/A"
if [[ -f "${GENERO_AKR_METADATA}/last_updated.txt" ]]; then
    LAST_UPDATED=$(cat "${GENERO_AKR_METADATA}/last_updated.txt")
fi

# Count log entries (agent activity)
AGENT_ACTIVITY=0
if [[ -f "${GENERO_AKR_LOGS}/akr.log" ]]; then
    AGENT_ACTIVITY=$(grep -c "COMMIT:" "${GENERO_AKR_LOGS}/akr.log" 2>/dev/null || echo 0)
fi

# Get unique agents
UNIQUE_AGENTS=0
if [[ -f "${GENERO_AKR_LOGS}/akr.log" ]]; then
    UNIQUE_AGENTS=$(grep "COMMIT:" "${GENERO_AKR_LOGS}/akr.log" 2>/dev/null | grep -o "agent=[^,]*" | sort -u | wc -l || echo 0)
fi

# Output statistics
case "$FORMAT" in
    text)
        cat << EOF
# AKR Statistics

**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Document Counts

| Type | Count |
|------|-------|
| Functions | $FUNC_COUNT |
| Files | $FILE_COUNT |
| Modules | $MOD_COUNT |
| Patterns | $PAT_COUNT |
| Issues | $ISS_COUNT |
| **Total** | **$TOTAL** |

## Activity

| Metric | Value |
|--------|-------|
| Total Commits | $AGENT_ACTIVITY |
| Unique Agents | $UNIQUE_AGENTS |
| Last Updated | $LAST_UPDATED |

## Adoption Status

EOF
        if [[ $TOTAL -eq 0 ]]; then
            echo "**Status:** No knowledge documents yet (Phase 1 setup complete)"
        elif [[ $TOTAL -lt 100 ]]; then
            echo "**Status:** Early adoption (1-5% of codebase analyzed)"
        elif [[ $TOTAL -lt 500 ]]; then
            echo "**Status:** Growing adoption (5-25% of codebase analyzed)"
        elif [[ $TOTAL -lt 2000 ]]; then
            echo "**Status:** Strong adoption (25-50% of codebase analyzed)"
        else
            echo "**Status:** Mature adoption (50%+ of codebase analyzed)"
        fi
        ;;
    
    json)
        cat << EOF
{
  "generated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "documents": {
    "functions": $FUNC_COUNT,
    "files": $FILE_COUNT,
    "modules": $MOD_COUNT,
    "patterns": $PAT_COUNT,
    "issues": $ISS_COUNT,
    "total": $TOTAL
  },
  "activity": {
    "total_commits": $AGENT_ACTIVITY,
    "unique_agents": $UNIQUE_AGENTS,
    "last_updated": "$LAST_UPDATED"
  }
}
EOF
        ;;
    
    csv)
        cat << EOF
Type,Count
Functions,$FUNC_COUNT
Files,$FILE_COUNT
Modules,$MOD_COUNT
Patterns,$PAT_COUNT
Issues,$ISS_COUNT
Total,$TOTAL

Metric,Value
Total Commits,$AGENT_ACTIVITY
Unique Agents,$UNIQUE_AGENTS
Last Updated,$LAST_UPDATED
EOF
        ;;
esac

exit 0
