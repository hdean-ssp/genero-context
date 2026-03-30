#!/bin/bash

################################################################################
# audit_trail.sh - Generate audit trail of all AKR activities
#
# Purpose: Track all commits, retrievals, and modifications for compliance
#          and debugging
#
# Usage: bash audit_trail.sh [--agent AGENT] [--since DATE] [--format text|json]
#
# Parameters:
#   --agent <id>        Filter by agent ID
#   --since <date>      Show activities since date (ISO format)
#   --format <format>   Output format: text (default), json
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
AGENT_FILTER=""
SINCE_DATE=""
FORMAT="text"

while [[ $# -gt 0 ]]; do
    case $1 in
        --agent) AGENT_FILTER="$2"; shift 2 ;;
        --since) SINCE_DATE="$2"; shift 2 ;;
        --format) FORMAT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate AKR base path
if [[ ! -d "$GENERO_AKR_BASE_PATH" ]]; then
    log_error "AKR base path does not exist: $GENERO_AKR_BASE_PATH"
    exit 1
fi

LOG_FILE="${GENERO_AKR_LOGS}/akr.log"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "No audit trail found"
    exit 0
fi

# Generate audit trail
case "$FORMAT" in
    text)
        echo "# AKR Audit Trail"
        echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        
        if [[ -n "$AGENT_FILTER" ]]; then
            echo "**Filter:** Agent=$AGENT_FILTER"
        fi
        if [[ -n "$SINCE_DATE" ]]; then
            echo "**Filter:** Since=$SINCE_DATE"
        fi
        echo ""
        
        # Extract and format log entries
        grep "COMMIT:" "$LOG_FILE" | \
            if [[ -n "$AGENT_FILTER" ]]; then
                grep "agent=$AGENT_FILTER"
            else
                cat
            fi | \
            if [[ -n "$SINCE_DATE" ]]; then
                awk -v since="$SINCE_DATE" '$1 >= since'
            else
                cat
            fi | \
            awk -F'[\\[\\]]' '{print "- " $2 ": " $NF}' | \
            tail -100
        
        echo ""
        echo "**Total Entries:** $(grep -c "COMMIT:" "$LOG_FILE" || echo 0)"
        ;;
    
    json)
        echo "{"
        echo "  \"generated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
        echo "  \"entries\": ["
        
        grep "COMMIT:" "$LOG_FILE" | \
            if [[ -n "$AGENT_FILTER" ]]; then
                grep "agent=$AGENT_FILTER"
            else
                cat
            fi | \
            if [[ -n "$SINCE_DATE" ]]; then
                awk -v since="$SINCE_DATE" '$1 >= since'
            else
                cat
            fi | \
            awk -F'[\\[\\]]' '{
                gsub(/^.*COMMIT: /, "");
                print "    {\"timestamp\": \"" $1 "\", \"entry\": \"" $0 "\"},"
            }' | \
            sed '$ s/,$//' | \
            tail -100
        
        echo "  ]"
        echo "}"
        ;;
esac

exit 0
