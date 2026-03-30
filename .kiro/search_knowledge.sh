#!/bin/bash
# Search Knowledge in AKR
# Usage: bash search_knowledge.sh --query "type resolution"

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/akr-config.sh"

# ============================================================================
# Functions
# ============================================================================

log_debug() {
  if [ "$GENERO_AKR_LOG_LEVEL" = "debug" ]; then
    echo "[DEBUG] $*" >&2
  fi
}

log_info() {
  if [ "$GENERO_AKR_LOG_LEVEL" != "error" ]; then
    echo "[INFO] $*" >&2
  fi
}

log_error() {
  echo "[ERROR] $*" >&2
}

show_usage() {
  cat << 'EOF'
Usage: bash search_knowledge.sh --query QUERY [--type TYPE] [--category CATEGORY]

Search for knowledge in the AKR.

Options:
  --query QUERY     Search query (required)
  --type TYPE       Limit search to type: function, file, module, pattern, issue
  --category CAT    Limit search to category: files, functions, modules, patterns, issues
  --help            Show this help message

Examples:
  # Search all knowledge
  bash search_knowledge.sh --query "type resolution"

  # Search only functions
  bash search_knowledge.sh --query "complexity" --type function

  # Search only patterns
  bash search_knowledge.sh --query "error handling" --category patterns

  # Search for specific function
  bash search_knowledge.sh --query "process_order"
EOF
}

search_directory() {
  local query=$1
  local directory=$2
  local category=$3

  if [ ! -d "$directory" ]; then
    return
  fi

  log_debug "Searching in $directory for: $query"

  # Search for files containing the query
  local results=$(grep -r -l -i "$query" "$directory" 2>/dev/null || true)

  if [ -z "$results" ]; then
    return
  fi

  # Display results
  while IFS= read -r file; do
    local filename=$(basename "$file")
    local artifact_name="${filename%.md}"
    
    # Count matches in file
    local match_count=$(grep -i -c "$query" "$file" 2>/dev/null || echo "0")
    
    # Extract summary (first line after "## Summary")
    local summary=$(sed -n '/^## Summary/,/^##/p' "$file" | head -2 | tail -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    echo "[$category] $artifact_name ($match_count matches)"
    if [ -n "$summary" ] && [ "$summary" != "##" ]; then
      echo "  Summary: $summary"
    fi
    echo "  File: $file"
    echo ""
  done <<< "$results"
}

# ============================================================================
# Parse Arguments
# ============================================================================

QUERY=""
TYPE=""
CATEGORY=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --query)
      QUERY="$2"
      shift 2
      ;;
    --type)
      TYPE="$2"
      shift 2
      ;;
    --category)
      CATEGORY="$2"
      shift 2
      ;;
    --help)
      show_usage
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      show_usage
      exit 1
      ;;
  esac
done

# ============================================================================
# Validation
# ============================================================================

if [ -z "$QUERY" ]; then
  log_error "Missing required option: --query"
  show_usage
  exit 1
fi

# ============================================================================
# Search Knowledge
# ============================================================================

log_debug "Searching for: $QUERY"

if [ -z "$CATEGORY" ] && [ -z "$TYPE" ]; then
  # Search all categories
  log_info "Searching all knowledge for: $QUERY"
  echo "Search Results for: $QUERY"
  echo "======================================"
  echo ""
  
  search_directory "$QUERY" "$GENERO_AKR_FILES" "FILE"
  search_directory "$QUERY" "$GENERO_AKR_FUNCTIONS" "FUNCTION"
  search_directory "$QUERY" "$GENERO_AKR_MODULES" "MODULE"
  search_directory "$QUERY" "$GENERO_AKR_PATTERNS" "PATTERN"
  search_directory "$QUERY" "$GENERO_AKR_ISSUES" "ISSUE"
  
elif [ -n "$CATEGORY" ]; then
  # Search specific category
  log_info "Searching $CATEGORY for: $QUERY"
  echo "Search Results in $CATEGORY for: $QUERY"
  echo "======================================"
  echo ""
  
  case "$CATEGORY" in
    files)
      search_directory "$QUERY" "$GENERO_AKR_FILES" "FILE"
      ;;
    functions)
      search_directory "$QUERY" "$GENERO_AKR_FUNCTIONS" "FUNCTION"
      ;;
    modules)
      search_directory "$QUERY" "$GENERO_AKR_MODULES" "MODULE"
      ;;
    patterns)
      search_directory "$QUERY" "$GENERO_AKR_PATTERNS" "PATTERN"
      ;;
    issues)
      search_directory "$QUERY" "$GENERO_AKR_ISSUES" "ISSUE"
      ;;
    *)
      log_error "Unknown category: $CATEGORY"
      show_usage
      exit 1
      ;;
  esac
  
elif [ -n "$TYPE" ]; then
  # Search specific type
  log_info "Searching $TYPE for: $QUERY"
  echo "Search Results for $TYPE: $QUERY"
  echo "======================================"
  echo ""
  
  case "$TYPE" in
    file)
      search_directory "$QUERY" "$GENERO_AKR_FILES" "FILE"
      ;;
    function)
      search_directory "$QUERY" "$GENERO_AKR_FUNCTIONS" "FUNCTION"
      ;;
    module)
      search_directory "$QUERY" "$GENERO_AKR_MODULES" "MODULE"
      ;;
    pattern)
      search_directory "$QUERY" "$GENERO_AKR_PATTERNS" "PATTERN"
      ;;
    issue)
      search_directory "$QUERY" "$GENERO_AKR_ISSUES" "ISSUE"
      ;;
    *)
      log_error "Unknown type: $TYPE"
      show_usage
      exit 1
      ;;
  esac
fi

exit 0
