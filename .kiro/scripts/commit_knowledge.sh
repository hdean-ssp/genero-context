#!/bin/bash
# Commit Knowledge to AKR
# Usage: bash commit_knowledge.sh --type function --name "process_order" --findings findings.json --action append

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

log_to_file() {
  local message=$1
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $message" >> "$GENERO_AKR_LOG_FILE"
}

show_usage() {
  cat << 'EOF'
Usage: bash commit_knowledge.sh --type TYPE --name NAME --findings FILE --action ACTION [--path PATH]

Commit knowledge about an artifact to the AKR.

Options:
  --type TYPE       Type of artifact: function, file, module, pattern, issue
  --name NAME       Name of artifact (for function, module, pattern, issue)
  --path PATH       Path of artifact (for file type)
  --findings FILE   JSON file containing findings
  --action ACTION   Action: create, append, update, deprecate
  --help            Show this help message

Actions:
  create            Create new knowledge document (artifact not previously analyzed)
  append            Append findings to existing knowledge (preserve history)
  update            Replace existing knowledge (artifact significantly changed)
  deprecate         Mark knowledge as outdated (artifact no longer relevant)

Examples:
  # Create new function knowledge
  bash commit_knowledge.sh --type function --name "process_order" --findings findings.json --action create

  # Append to existing function knowledge
  bash commit_knowledge.sh --type function --name "process_order" --findings findings.json --action append

  # Update function knowledge (artifact changed)
  bash commit_knowledge.sh --type function --name "process_order" --findings findings.json --action update

  # Mark function knowledge as deprecated
  bash commit_knowledge.sh --type function --name "process_order" --findings findings.json --action deprecate
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

acquire_lock() {
  local lock_file=$1
  local timeout=$2
  local retry_interval=$3
  local elapsed=0

  log_debug "Acquiring lock: $lock_file"

  # Clean up stale lock if it's older than 2x the timeout
  if [ -d "$lock_file" ]; then
    local lock_age=$(( $(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || echo 0) ))
    if [ "$lock_age" -gt $((timeout * 2)) ]; then
      log_info "Removing stale lock (age: ${lock_age}s): $lock_file"
      rmdir "$lock_file" 2>/dev/null || true
    fi
  fi

  # Try to acquire lock immediately
  if mkdir "$lock_file" 2>/dev/null; then
    log_debug "Lock acquired"
    return 0
  fi

  # Retry with delays
  if command -v sleep &> /dev/null; then
    while [ $elapsed -lt $timeout ]; do
      sleep "$retry_interval"
      elapsed=$((elapsed + retry_interval))
      if mkdir "$lock_file" 2>/dev/null; then
        log_debug "Lock acquired after ${elapsed}s"
        return 0
      fi
    done
  fi

  log_error "Failed to acquire lock after ${timeout}s: $lock_file"
  return 1
}

release_lock() {
  local lock_file=$1
  log_debug "Releasing lock: $lock_file"
  rmdir "$lock_file" 2>/dev/null || true
}

create_knowledge_document() {
  local knowledge_file=$1
  local type=$2
  local name=$3
  local path=$4
  local findings_file=$5
  local agent_id=${GENERO_AGENT_ID:-"unknown"}

  log_debug "Creating new knowledge document"

  # Read findings from JSON
  local summary=$(jq -r '.summary // "No summary provided"' "$findings_file" 2>/dev/null || echo "No summary provided")
  local key_findings=$(jq -r '.key_findings // []' "$findings_file" 2>/dev/null || echo "[]")
  local metrics=$(jq -r '.metrics // {}' "$findings_file" 2>/dev/null || echo "{}")
  local dependencies=$(jq -r '.dependencies // {}' "$findings_file" 2>/dev/null || echo "{}")
  local type_info=$(jq -r '.type_information // {}' "$findings_file" 2>/dev/null || echo "{}")
  local patterns=$(jq -r '.patterns // {}' "$findings_file" 2>/dev/null || echo "{}")
  local known_issues=$(jq -r '.known_issues // []' "$findings_file" 2>/dev/null || echo "[]")
  local recommendations=$(jq -r '.recommendations // []' "$findings_file" 2>/dev/null || echo "[]")
  local related=$(jq -r '.related_knowledge // []' "$findings_file" 2>/dev/null || echo "[]")

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  cat > "$knowledge_file" << EOF
# $name

**Type:** $type  
**Path:** $path  
**Last Updated:** $timestamp  
**Updated By:** $agent_id  
**Status:** active

## Summary
$summary

## Key Findings
$(echo "$key_findings" | jq -r '.[] | "- \(.)"' 2>/dev/null || echo "- No findings yet")

## Metrics
$(echo "$metrics" | jq -r 'to_entries[] | "- \(.key): \(.value)"' 2>/dev/null || echo "- No metrics")

## Dependencies
$(echo "$dependencies" | jq -r 'to_entries[] | "- \(.key): \(.value)"' 2>/dev/null || echo "- No dependencies")

## Type Information
$(echo "$type_info" | jq -r 'to_entries[] | "- \(.key): \(.value)"' 2>/dev/null || echo "- No type information")

## Patterns & Conventions
$(echo "$patterns" | jq -r 'to_entries[] | "- \(.key): \(.value)"' 2>/dev/null || echo "- No patterns")

## Known Issues
$(echo "$known_issues" | jq -r '.[] | "- \(.)"' 2>/dev/null || echo "- No known issues")

## Recommendations
$(echo "$recommendations" | jq -r '.[] | "- \(.)"' 2>/dev/null || echo "- No recommendations")

## Related Knowledge
$(echo "$related" | jq -r '.[] | "- \(.)"' 2>/dev/null || echo "- No related knowledge")

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| $timestamp | $agent_id | initial_analysis | Initial analysis |

## Raw Data
See findings.json for raw data
EOF

  log_info "Created new knowledge document: $1"
}

append_to_knowledge() {
  local knowledge_file=$1
  local findings_file=$2
  local agent_id=${GENERO_AGENT_ID:-"unknown"}
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  log_debug "Appending to existing knowledge document"

  # Extract new findings
  local new_findings=$(jq -r '.new_findings // []' "$findings_file" 2>/dev/null || echo "[]")

  # Add to Analysis History
  local history_entry="| $timestamp | $agent_id | extended_analysis | $(echo "$new_findings" | jq -r '.[] | "- \(.)"' 2>/dev/null | head -1) |"

  # Insert before "## Raw Data" section
  /bin/sed -i "/^## Raw Data/i\\
$history_entry" "$knowledge_file"

  log_info "Appended to knowledge document: $knowledge_file"
}

# ============================================================================
# Parse Arguments
# ============================================================================

TYPE=""
NAME=""
PATH=""
FINDINGS_FILE=""
ACTION=""

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
    --findings)
      FINDINGS_FILE="$2"
      shift 2
      ;;
    --action)
      ACTION="$2"
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

if [ -z "$FINDINGS_FILE" ]; then
  log_error "Missing required option: --findings"
  show_usage
  exit 1
fi

if [ ! -f "$FINDINGS_FILE" ]; then
  log_error "Findings file not found: $FINDINGS_FILE"
  exit 1
fi

if [ -z "$ACTION" ]; then
  log_error "Missing required option: --action"
  show_usage
  exit 1
fi

case "$ACTION" in
  create|append|update|deprecate)
    ;;
  *)
    log_error "Invalid action: $ACTION (must be create, append, update, or deprecate)"
    show_usage
    exit 1
    ;;
esac

# ============================================================================
# Commit Knowledge
# ============================================================================

log_debug "Committing knowledge: type=$TYPE, name=$NAME, action=$ACTION"

KNOWLEDGE_FILE=$(get_knowledge_file "$TYPE" "$NAME" "$PATH")
LOCK_FILE="${GENERO_AKR_LOCKS}/${TYPE}_${NAME}.lock"

log_debug "Knowledge file: $KNOWLEDGE_FILE"
log_debug "Lock file: $LOCK_FILE"

# Ensure lock is always released on exit
trap "release_lock '$LOCK_FILE' 2>/dev/null || true" EXIT

# Acquire lock (continue without it if unavailable — concurrent writes may conflict)
LOCK_HELD=0
if acquire_lock "$LOCK_FILE" "$GENERO_AKR_LOCK_TIMEOUT" "$GENERO_AKR_LOCK_RETRY_INTERVAL"; then
  LOCK_HELD=1
else
  log_info "Continuing without lock (may cause conflicts in concurrent scenarios)"
fi

# Perform action
case "$ACTION" in
  create)
    if [ -f "$KNOWLEDGE_FILE" ]; then
      log_info "Knowledge already exists: $TYPE/$NAME — appending instead of creating"
      append_to_knowledge "$KNOWLEDGE_FILE" "$FINDINGS_FILE"
    else
      create_knowledge_document "$KNOWLEDGE_FILE" "$TYPE" "$NAME" "$PATH" "$FINDINGS_FILE"
    fi
    ;;
  append)
    if [ ! -f "$KNOWLEDGE_FILE" ]; then
      log_error "Knowledge does not exist: $TYPE/$NAME"
      log_info "Use --action create to create new knowledge"
      exit 1
    fi
    append_to_knowledge "$KNOWLEDGE_FILE" "$FINDINGS_FILE"
    ;;
  update)
    if [ ! -f "$KNOWLEDGE_FILE" ]; then
      log_error "Knowledge does not exist: $TYPE/$NAME"
      exit 1
    fi
    log_info "Updating knowledge document (replacing existing)"
    create_knowledge_document "$KNOWLEDGE_FILE" "$TYPE" "$NAME" "$PATH" "$FINDINGS_FILE"
    ;;
  deprecate)
    if [ ! -f "$KNOWLEDGE_FILE" ]; then
      log_error "Knowledge does not exist: $TYPE/$NAME"
      exit 1
    fi
    log_info "Marking knowledge as deprecated"
    /bin/sed -i 's/^**Status:** .*/**Status:** deprecated/' "$KNOWLEDGE_FILE"
    ;;
esac

# Log activity
log_to_file "COMMIT: type=$TYPE, name=$NAME, action=$ACTION, agent=${GENERO_AGENT_ID:-unknown}"

log_info "Knowledge committed successfully: $TYPE/$NAME"
log_debug "Knowledge file: $KNOWLEDGE_FILE"

# Update metadata (INDEX.md, statistics.md, last_updated.txt)
log_debug "Updating metadata..."
if bash "${SCRIPT_DIR}/update_metadata.sh" --type "$TYPE" --name "$NAME" --action "$ACTION"; then
  log_debug "Metadata updated successfully"
else
  log_error "Failed to update metadata (continuing anyway)"
fi

exit 0
