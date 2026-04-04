#!/bin/bash

################################################################################
# view_audit.sh - Query and display audit log entries
#
# Purpose: Retrieve and filter audit log entries with multiple output formats
#
# Usage: bash view_audit.sh [--agent AGENT_ID] [--session SESSION_ID] \
#          [--action ACTION] [--artifact ARTIFACT_NAME] [--since HOURS] \
#          [--format text|json|csv] [--limit N]
#
# Parameters:
#   --agent <id>            Filter by agent ID
#   --session <id>          Filter by session ID
#   --action <action>       Filter by action type
#   --artifact <name>       Filter by artifact name
#   --since <hours>         Show entries from last N hours
#   --format <format>       Output format: text (default), json, csv
#   --limit <n>             Limit to N most recent entries (default: 100)
#
# Exit Codes:
#   0 - Success
#   1 - Error
#
# Examples:
#   bash view_audit.sh --agent agent-1 --since 24 --format text
#   bash view_audit.sh --artifact process_order --format json
#   bash view_audit.sh --action AKR_RETRIEVE --limit 50
#   bash view_audit.sh --since 1 --format csv > audit_report.csv
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
AGENT_FILTER=""
SESSION_FILTER=""
ACTION_FILTER=""
ARTIFACT_FILTER=""
SINCE_HOURS=""
FORMAT="text"
LIMIT=100

while [[ $# -gt 0 ]]; do
    case $1 in
        --agent) AGENT_FILTER="$2"; shift 2 ;;
        --session) SESSION_FILTER="$2"; shift 2 ;;
        --action) ACTION_FILTER="$2"; shift 2 ;;
        --artifact) ARTIFACT_FILTER="$2"; shift 2 ;;
        --since) SINCE_HOURS="$2"; shift 2 ;;
        --format) FORMAT="$2"; shift 2 ;;
        --limit) LIMIT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate audit log exists
if [[ ! -f "$GENERO_AKR_AUDIT_LOG" ]]; then
    echo "No audit log found at: $GENERO_AKR_AUDIT_LOG"
    exit 0
fi

# Calculate cutoff timestamp if --since specified
CUTOFF_TIMESTAMP=""
if [[ -n "$SINCE_HOURS" ]]; then
    CUTOFF_TIMESTAMP=$(date -u -d "$SINCE_HOURS hours ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")
    log_debug "Cutoff timestamp: $CUTOFF_TIMESTAMP"
fi

# Function to check if entry matches filters
matches_filters() {
    local entry="$1"
    
    # Check timestamp filter
    if [[ -n "$CUTOFF_TIMESTAMP" ]]; then
        local entry_timestamp=$(echo "$entry" | jq -r '.timestamp' 2>/dev/null || echo "")
        if [[ -n "$entry_timestamp" ]] && [[ "$entry_timestamp" < "$CUTOFF_TIMESTAMP" ]]; then
            return 1
        fi
    fi
    
    # Check agent filter
    if [[ -n "$AGENT_FILTER" ]]; then
        if ! echo "$entry" | grep -q "\"agent_id\":\"$AGENT_FILTER\""; then
            return 1
        fi
    fi
    
    # Check session filter
    if [[ -n "$SESSION_FILTER" ]]; then
        if ! echo "$entry" | grep -q "\"session_id\":\"$SESSION_FILTER\""; then
            return 1
        fi
    fi
    
    # Check action filter
    if [[ -n "$ACTION_FILTER" ]]; then
        if ! echo "$entry" | grep -q "\"action\":\"$ACTION_FILTER\""; then
            return 1
        fi
    fi
    
    # Check artifact filter
    if [[ -n "$ARTIFACT_FILTER" ]]; then
        if ! echo "$entry" | grep -q "\"artifact_name\":\"$ARTIFACT_FILTER\""; then
            return 1
        fi
    fi
    
    return 0
}

# Function to format entry as text
format_text() {
    local entry="$1"
    local timestamp=$(echo "$entry" | jq -r '.timestamp' 2>/dev/null || echo "N/A")
    local agent=$(echo "$entry" | jq -r '.agent_id' 2>/dev/null || echo "N/A")
    local action=$(echo "$entry" | jq -r '.action' 2>/dev/null || echo "N/A")
    local phase=$(echo "$entry" | jq -r '.phase' 2>/dev/null || echo "N/A")
    local hat=$(echo "$entry" | jq -r '.hat' 2>/dev/null || echo "N/A")
    local artifact=$(echo "$entry" | jq -r '.artifact_name' 2>/dev/null || echo "N/A")
    local result=$(echo "$entry" | jq -r '.result' 2>/dev/null || echo "N/A")
    local error=$(echo "$entry" | jq -r '.error // empty' 2>/dev/null || echo "")
    
    printf "%-25s %-12s %-15s %-12s %-8s %-20s %-10s" \
        "$timestamp" "$agent" "$action" "$phase" "$hat" "$artifact" "$result"
    
    if [[ -n "$error" ]]; then
        printf " [ERROR: %s]" "$error"
    fi
    
    echo ""
}

# Function to format entry as CSV
format_csv() {
    local entry="$1"
    local timestamp=$(echo "$entry" | jq -r '.timestamp' 2>/dev/null || echo "N/A")
    local agent=$(echo "$entry" | jq -r '.agent_id' 2>/dev/null || echo "N/A")
    local action=$(echo "$entry" | jq -r '.action' 2>/dev/null || echo "N/A")
    local phase=$(echo "$entry" | jq -r '.phase' 2>/dev/null || echo "N/A")
    local hat=$(echo "$entry" | jq -r '.hat' 2>/dev/null || echo "N/A")
    local artifact=$(echo "$entry" | jq -r '.artifact_name' 2>/dev/null || echo "N/A")
    local result=$(echo "$entry" | jq -r '.result' 2>/dev/null || echo "N/A")
    local error=$(echo "$entry" | jq -r '.error // empty' 2>/dev/null || echo "")
    local duration=$(echo "$entry" | jq -r '.duration_ms // empty' 2>/dev/null || echo "")
    
    # Escape quotes for CSV
    timestamp=$(echo "$timestamp" | sed 's/"/""/g')
    agent=$(echo "$agent" | sed 's/"/""/g')
    action=$(echo "$action" | sed 's/"/""/g')
    phase=$(echo "$phase" | sed 's/"/""/g')
    hat=$(echo "$hat" | sed 's/"/""/g')
    artifact=$(echo "$artifact" | sed 's/"/""/g')
    result=$(echo "$result" | sed 's/"/""/g')
    error=$(echo "$error" | sed 's/"/""/g')
    
    echo "\"$timestamp\",\"$agent\",\"$action\",\"$phase\",\"$hat\",\"$artifact\",\"$result\",\"$duration\",\"$error\""
}

# Output based on format
case "$FORMAT" in
    text)
        echo "# Audit Log"
        echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        
        # Print filters if any
        if [[ -n "$AGENT_FILTER" ]] || [[ -n "$ACTION_FILTER" ]] || [[ -n "$ARTIFACT_FILTER" ]] || [[ -n "$SINCE_HOURS" ]]; then
            echo "**Filters:**"
            [[ -n "$AGENT_FILTER" ]] && echo "- Agent: $AGENT_FILTER"
            [[ -n "$ACTION_FILTER" ]] && echo "- Action: $ACTION_FILTER"
            [[ -n "$ARTIFACT_FILTER" ]] && echo "- Artifact: $ARTIFACT_FILTER"
            [[ -n "$SINCE_HOURS" ]] && echo "- Since: $SINCE_HOURS hours ago"
            echo ""
        fi
        
        # Print header
        printf "%-25s %-12s %-15s %-12s %-8s %-20s %-10s\n" \
            "TIMESTAMP" "AGENT" "ACTION" "PHASE" "HAT" "ARTIFACT" "RESULT"
        printf "%s\n" "$(printf '=%.0s' {1..120})"
        
        # Print entries (most recent first)
        ENTRY_COUNT=0
        tac "$GENERO_AKR_AUDIT_LOG" 2>/dev/null | while read -r line; do
            if [[ -z "$line" ]]; then
                continue
            fi
            
            if matches_filters "$line"; then
                format_text "$line"
                ((ENTRY_COUNT++))
                if [[ $ENTRY_COUNT -ge $LIMIT ]]; then
                    break
                fi
            fi
        done
        
        echo ""
        echo "**Total Entries Shown:** $ENTRY_COUNT (limit: $LIMIT)"
        ;;
    
    json)
        echo "{"
        echo "  \"generated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
        echo "  \"filters\": {"
        echo "    \"agent\": \"${AGENT_FILTER:-null}\","
        echo "    \"action\": \"${ACTION_FILTER:-null}\","
        echo "    \"artifact\": \"${ARTIFACT_FILTER:-null}\","
        echo "    \"since_hours\": ${SINCE_HOURS:-null},"
        echo "    \"limit\": $LIMIT"
        echo "  },"
        echo "  \"entries\": ["
        
        ENTRY_COUNT=0
        FIRST=1
        tac "$GENERO_AKR_AUDIT_LOG" 2>/dev/null | while read -r line; do
            if [[ -z "$line" ]]; then
                continue
            fi
            
            if matches_filters "$line"; then
                if [[ $FIRST -eq 0 ]]; then
                    echo ","
                fi
                echo -n "    $line"
                FIRST=0
                ((ENTRY_COUNT++))
                if [[ $ENTRY_COUNT -ge $LIMIT ]]; then
                    break
                fi
            fi
        done
        
        echo ""
        echo "  ]"
        echo "}"
        ;;
    
    csv)
        # Print header
        echo "timestamp,agent_id,action,phase,hat,artifact_name,result,duration_ms,error"
        
        # Print entries (most recent first)
        ENTRY_COUNT=0
        tac "$GENERO_AKR_AUDIT_LOG" 2>/dev/null | while read -r line; do
            if [[ -z "$line" ]]; then
                continue
            fi
            
            if matches_filters "$line"; then
                format_csv "$line"
                ((ENTRY_COUNT++))
                if [[ $ENTRY_COUNT -ge $LIMIT ]]; then
                    break
                fi
            fi
        done
        ;;
    
    *)
        log_error "Unknown format: $FORMAT"
        exit 1
        ;;
esac

exit 0
