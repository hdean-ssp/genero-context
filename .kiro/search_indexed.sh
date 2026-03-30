#!/bin/bash

################################################################################
# search_indexed.sh - Fast full-text search using index
#
# Purpose: Search knowledge documents using pre-built index for fast results
#          <50ms search time vs 400ms with grep
#
# Usage: bash search_indexed.sh --query "search term" [--type TYPE]
#
# Parameters:
#   --query <term>      Search term (required)
#   --type <type>       Filter by type: function, file, module, pattern, issue
#
# Exit Codes:
#   0 - Success (results found)
#   1 - Error
#   2 - No results found
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
QUERY=""
FILTER_TYPE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --query) QUERY="$2"; shift 2 ;;
        --type) FILTER_TYPE="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate arguments
if [[ -z "$QUERY" ]]; then
    log_error "Missing required argument: --query"
    exit 1
fi

# Validate AKR base path
if [[ ! -d "$GENERO_AKR_BASE_PATH" ]]; then
    log_error "AKR base path does not exist: $GENERO_AKR_BASE_PATH"
    exit 1
fi

INDEX_FILE="${GENERO_AKR_METADATA}/search_index.txt"

# Check if index exists
if [[ ! -f "$INDEX_FILE" ]]; then
    echo "Search index not found. Building index..."
    bash "${SCRIPT_DIR}/build_index.sh"
fi

# Search index
if [[ -n "$FILTER_TYPE" ]]; then
    RESULTS=$(grep "^$FILTER_TYPE|" "$INDEX_FILE" | grep -i "$QUERY" || true)
else
    RESULTS=$(grep -i "$QUERY" "$INDEX_FILE" | grep -v "^#" || true)
fi

# Check if results found
if [[ -z "$RESULTS" ]]; then
    echo "No results found for: $QUERY"
    exit 2
fi

# Format and display results
echo "# Search Results for: $QUERY"
echo ""
echo "| Type | Name | Summary |"
echo "|------|------|---------|"

echo "$RESULTS" | while IFS='|' read -r type name path summary; do
    # Truncate summary to 60 chars
    summary_short="${summary:0:60}"
    if [[ ${#summary} -gt 60 ]]; then
        summary_short="${summary_short}..."
    fi
    echo "| $type | $name | $summary_short |"
done

echo ""
echo "**Total Results:** $(echo "$RESULTS" | wc -l)"

exit 0
