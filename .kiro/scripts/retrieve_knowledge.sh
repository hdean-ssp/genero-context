#!/bin/bash
# Retrieve Knowledge from AKR
# Usage: bash retrieve_knowledge.sh --type function --name "process_order"

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
Usage: bash retrieve_knowledge.sh --type TYPE --name NAME [--path PATH]

Retrieve knowledge about an artifact from the AKR.

Options:
  --type TYPE       Type of artifact: function, file, module, pattern, issue
  --name NAME       Name of artifact (for function, module, pattern, issue)
  --path PATH       Path of artifact (for file type)
  --help            Show this help message

Examples:
  # Retrieve function knowledge
  bash retrieve_knowledge.sh --type function --name "process_order"

  # Retrieve file knowledge
  bash retrieve_knowledge.sh --type file --path "src/orders.4gl"

  # Retrieve module knowledge
  bash retrieve_knowledge.sh --type module --name "payment"

  # Retrieve pattern knowledge
  bash retrieve_knowledge.sh --type pattern --name "error_handling"

  # Retrieve issue knowledge
  bash retrieve_knowledge.sh --type issue --name "type_resolution_issues"
EOF
}

get_knowledge_file() {
  local type=$1
  local name=$2
  local path=$3

  case "$type" in
    function)
      echo "${GENERO_AKR_FUNCTIONS}/${name}.md"
      ;;
    file)
      # Convert path to filename (replace / with _)
      local filename=$(echo "$path" | /bin/sed 's/\//_/g')
      echo "${GENERO_AKR_FILES}/${filename}.md"
      ;;
    module)
      echo "${GENERO_AKR_MODULES}/${name}.md"
      ;;
    pattern)
      echo "${GENERO_AKR_PATTERNS}/${name}.md"
      ;;
    issue)
      echo "${GENERO_AKR_ISSUES}/${name}.md"
      ;;
    *)
      log_error "Unknown type: $type"
      return 1
      ;;
  esac
}

# ============================================================================
# Parse Arguments
# ============================================================================

TYPE=""
NAME=""
PATH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --type)
      TYPE="$2"
      shift 2
      ;;
    --name)
      NAME="$2"
      shift 2
      ;;
    --path)
      PATH="$2"
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

if [ -z "$TYPE" ]; then
  log_error "Missing required option: --type"
  show_usage
  exit 1
fi

if [ "$TYPE" = "file" ]; then
  if [ -z "$PATH" ]; then
    log_error "Missing required option for file type: --path"
    show_usage
    exit 1
  fi
else
  if [ -z "$NAME" ]; then
    log_error "Missing required option: --name"
    show_usage
    exit 1
  fi
fi

# ============================================================================
# Retrieve Knowledge
# ============================================================================

log_debug "Retrieving knowledge: type=$TYPE, name=$NAME, path=$PATH"

KNOWLEDGE_FILE=$(get_knowledge_file "$TYPE" "$NAME" "$PATH")
log_debug "Knowledge file: $KNOWLEDGE_FILE"

if [ ! -f "$KNOWLEDGE_FILE" ]; then
  log_error "Knowledge not found: $TYPE/$NAME"
  log_info "File path: $KNOWLEDGE_FILE"
  exit 1
fi

log_debug "Found knowledge file, displaying content"
log_debug "Knowledge file path: $KNOWLEDGE_FILE"
log_debug "Knowledge file exists: $([ -f "$KNOWLEDGE_FILE" ] && echo YES || echo NO)"
log_debug "About to execute: cat $KNOWLEDGE_FILE"
/bin/cat "$KNOWLEDGE_FILE"

exit 0
