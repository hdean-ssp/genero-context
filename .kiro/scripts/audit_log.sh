#!/bin/bash

################################################################################
# audit_log.sh - Centralized audit logging for all agent actions
#
# Purpose: Append JSON entries to centralized audit log with file locking,
#          automatic timestamp, and daily rotation
#
# Usage: bash audit_log.sh --action ACTION --phase PHASE --hat HAT \
#          --artifact-type TYPE --artifact-name NAME --result RESULT \
#          [--details JSON] [--error ERROR_MSG] [--duration-ms MS]
#
# Parameters:
#   --action <action>           Action type (AKR_RETRIEVE, GENERO_QUERY, etc.)
#   --phase <phase>             Phase (INCEPTION, CONSTRUCTION, OPERATION)
#   --hat <hat>                 Hat (PLANNER, BUILDER, REVIEWER)
#   --artifact-type <type>      Artifact type (function, module, file, issue, pattern)
#   --artifact-name <name>      Artifact name
#   --result <result>           Result (FOUND, NOT_FOUND, SUCCESS, FAILURE, etc.)
#   --details <json>            Optional JSON details
#   --error <msg>               Optional error message
#   --duration-ms <ms>          Optional duration in milliseconds
#   --agent-id <id>             Optional agent ID (defaults to $AGENT_ID env var)
#   --session-id <id>           Optional session ID (defaults to $SESSION_ID env var)
#
# Exit Codes:
#   0 - Success
#   1 - Error
#
# Examples:
#   bash audit_log.sh --action AKR_RETRIEVE --phase INCEPTION --hat PLANNER \
#     --artifact-type function --artifact-name process_order \
#     --result FOUND --details '{"complexity": 8, "dependents": 12}'
#
#   bash audit_log.sh --action GENERO_QUERY --phase INCEPTION --hat PLANNER \
#     --artifact-type function --artifact-name process_order \
#     --result SUCCESS --duration-ms 145
#
#   bash audit_log.sh --action GENERO_QUERY --phase INCEPTION --hat PLANNER \
#     --artifact-type function --artifact-name nonexistent \
#     --result FAILURE --error "Function not found in database"
#
################################################################################

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/akr-config.sh"

# Logging
log_error() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [ERROR] $*" >&2
}

log_debug() {
    if [[ "${DEBUG_AUDIT_LOG:-0}" == "1" ]]; then
        echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [DEBUG] $*" >&2
    fi
}

# Parse arguments
ACTION=""
PHASE=""
HAT=""
ARTIFACT_TYPE=""
ARTIFACT_NAME=""
RESULT=""
DETAILS=""
ERROR_MSG=""
DURATION_MS=""
AGENT_ID="${AGENT_ID:-unknown}"
SESSION_ID="${SESSION_ID:-$(uuidgen 2>/dev/null || echo "sess-$(date +%s)")}"

while [[ $# -gt 0 ]]; do
    case $1 in
        --action) ACTION="$2"; shift 2 ;;
        --phase) PHASE="$2"; shift 2 ;;
        --hat) HAT="$2"; shift 2 ;;
        --artifact-type) ARTIFACT_TYPE="$2"; shift 2 ;;
        --artifact-name) ARTIFACT_NAME="$2"; shift 2 ;;
        --result) RESULT="$2"; shift 2 ;;
        --details) DETAILS="$2"; shift 2 ;;
        --error) ERROR_MSG="$2"; shift 2 ;;
        --duration-ms) DURATION_MS="$2"; shift 2 ;;
        --agent-id) AGENT_ID="$2"; shift 2 ;;
        --session-id) SESSION_ID="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate required parameters
if [[ -z "$ACTION" ]]; then
    log_error "Missing required parameter: --action"
    exit 1
fi

if [[ -z "$RESULT" ]]; then
    log_error "Missing required parameter: --result"
    exit 1
fi

# Ensure audit log directory exists
mkdir -p "$(dirname "$GENERO_AKR_AUDIT_LOG")"

# Get current timestamp
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Build JSON entry
JSON_ENTRY="{"
JSON_ENTRY+="\"timestamp\":\"$TIMESTAMP\","
JSON_ENTRY+="\"agent_id\":\"$AGENT_ID\","
JSON_ENTRY+="\"session_id\":\"$SESSION_ID\","
JSON_ENTRY+="\"action\":\"$ACTION\","
JSON_ENTRY+="\"phase\":\"${PHASE:-N/A}\","
JSON_ENTRY+="\"hat\":\"${HAT:-N/A}\","
JSON_ENTRY+="\"artifact_type\":\"${ARTIFACT_TYPE:-N/A}\","
JSON_ENTRY+="\"artifact_name\":\"${ARTIFACT_NAME:-N/A}\","
JSON_ENTRY+="\"result\":\"$RESULT\""

if [[ -n "$DURATION_MS" ]]; then
    JSON_ENTRY+=",\"duration_ms\":$DURATION_MS"
fi

if [[ -n "$ERROR_MSG" ]]; then
    # Escape quotes in error message
    ERROR_MSG_ESCAPED=$(echo "$ERROR_MSG" | sed 's/"/\\"/g')
    JSON_ENTRY+=",\"error\":\"$ERROR_MSG_ESCAPED\""
fi

if [[ -n "$DETAILS" ]]; then
    JSON_ENTRY+=",\"details\":$DETAILS"
fi

JSON_ENTRY+="}"

# Append to audit log with file locking
LOCK_FILE="${GENERO_AKR_AUDIT_LOG}.lock"
LOCK_TIMEOUT=10
LOCK_ACQUIRED=0

# Try to acquire lock
for ((i=0; i<LOCK_TIMEOUT; i++)); do
    if mkdir "$LOCK_FILE" 2>/dev/null; then
        LOCK_ACQUIRED=1
        log_debug "Lock acquired after $i attempts"
        break
    fi
    sleep 0.1
done

if [[ $LOCK_ACQUIRED -eq 0 ]]; then
    log_error "Failed to acquire lock on audit log after ${LOCK_TIMEOUT}s"
    exit 1
fi

# Trap to ensure lock is released
trap "rmdir '$LOCK_FILE' 2>/dev/null || true" EXIT

# Append entry to audit log
echo "$JSON_ENTRY" >> "$GENERO_AKR_AUDIT_LOG"

log_debug "Audit entry appended: $ACTION ($RESULT)"

# Check if rotation is needed (daily rotation)
CURRENT_DATE=$(date +%Y-%m-%d)
ROTATION_MARKER="${GENERO_AKR_AUDIT_LOG}.date"

if [[ ! -f "$ROTATION_MARKER" ]] || [[ "$(cat "$ROTATION_MARKER" 2>/dev/null)" != "$CURRENT_DATE" ]]; then
    # Rotate log if it exists and is from a previous day
    if [[ -f "$GENERO_AKR_AUDIT_LOG" ]]; then
        ROTATED_LOG="${GENERO_AKR_AUDIT_LOG}.$(date -d yesterday +%Y-%m-%d)"
        if [[ ! -f "$ROTATED_LOG" ]]; then
            cp "$GENERO_AKR_AUDIT_LOG" "$ROTATED_LOG"
            > "$GENERO_AKR_AUDIT_LOG"  # Truncate current log
            log_debug "Rotated audit log to $ROTATED_LOG"
        fi
    fi
    
    # Update rotation marker
    echo "$CURRENT_DATE" > "$ROTATION_MARKER"
fi

# Clean up old logs (keep GENERO_AKR_AUDIT_RETENTION_DAYS days)
RETENTION_DAYS="${GENERO_AKR_AUDIT_RETENTION_DAYS:-30}"
find "$(dirname "$GENERO_AKR_AUDIT_LOG")" -name "$(basename "$GENERO_AKR_AUDIT_LOG").20*" -mtime "+$RETENTION_DAYS" -delete 2>/dev/null || true

exit 0
