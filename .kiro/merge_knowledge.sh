#!/bin/bash

################################################################################
# merge_knowledge.sh - Merge conflicting knowledge documents
#
# Purpose: Handle simultaneous writes to same artifact by merging findings
#          intelligently and preserving analysis history.
#
# Usage: bash merge_knowledge.sh --type <type> --name <name> --findings <file>
#
# Parameters:
#   --type <type>       Knowledge type (function, file, module, pattern, issue)
#   --name <name>       Knowledge artifact name
#   --findings <file>   New findings to merge
#
# Exit Codes:
#   0 - Success (merged)
#   1 - Error
#   2 - No conflict (no merge needed)
#
################################################################################

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/akr-config.sh"

# Logging
log_info() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [INFO] $*" >> "${GENERO_AKR_LOGS}/akr.log"
}

log_error() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [ERROR] $*" >> "${GENERO_AKR_LOGS}/akr.log"
}

log_debug() {
    if [[ "$GENERO_AKR_LOG_LEVEL" == "debug" ]]; then
        echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [DEBUG] $*" >> "${GENERO_AKR_LOGS}/akr.log"
    fi
}

# Parse arguments
ARTIFACT_TYPE=""
ARTIFACT_NAME=""
FINDINGS_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --type) ARTIFACT_TYPE="$2"; shift 2 ;;
        --name) ARTIFACT_NAME="$2"; shift 2 ;;
        --findings) FINDINGS_FILE="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate arguments
if [[ -z "$ARTIFACT_TYPE" ]] || [[ -z "$ARTIFACT_NAME" ]] || [[ -z "$FINDINGS_FILE" ]]; then
    log_error "Missing required arguments: --type, --name, --findings"
    exit 1
fi

if [[ ! -f "$FINDINGS_FILE" ]]; then
    log_error "Findings file not found: $FINDINGS_FILE"
    exit 1
fi

# Get knowledge file path
get_knowledge_file() {
    local type=$1
    local name=$2
    
    case "$type" in
        function) echo "${GENERO_AKR_FUNCTIONS}/${name}.md" ;;
        file) echo "${GENERO_AKR_FILES}/${name}.md" ;;
        module) echo "${GENERO_AKR_MODULES}/${name}.md" ;;
        pattern) echo "${GENERO_AKR_PATTERNS}/${name}.md" ;;
        issue) echo "${GENERO_AKR_ISSUES}/${name}.md" ;;
        *) return 1 ;;
    esac
}

KNOWLEDGE_FILE=$(get_knowledge_file "$ARTIFACT_TYPE" "$ARTIFACT_NAME")

# Check if knowledge file exists
if [[ ! -f "$KNOWLEDGE_FILE" ]]; then
    log_debug "No existing knowledge file, no merge needed"
    exit 2
fi

log_info "Merging knowledge for $ARTIFACT_TYPE/$ARTIFACT_NAME"

# Create backup
BACKUP_FILE="${KNOWLEDGE_FILE}.backup.$(date +%s)"
cp "$KNOWLEDGE_FILE" "$BACKUP_FILE"
log_debug "Created backup: $BACKUP_FILE"

# Extract sections from existing knowledge
extract_section() {
    local file=$1
    local section=$2
    
    sed -n "/^## $section$/,/^## /p" "$file" | sed '$ d'
}

# Extract new findings from JSON
extract_new_findings() {
    local file=$1
    
    if command -v jq &> /dev/null; then
        jq -r '.new_findings[]? // .key_findings[]?' "$file" 2>/dev/null | sed 's/^/- /'
    else
        # Fallback if jq not available
        grep -o '"[^"]*"' "$file" | head -5 | sed 's/"//g' | sed 's/^/- /'
    fi
}

# Merge key findings
merge_key_findings() {
    local existing_file=$1
    local new_findings_file=$2
    
    # Extract existing findings
    local existing=$(extract_section "$existing_file" "Key Findings")
    
    # Extract new findings
    local new=$(extract_new_findings "$new_findings_file")
    
    # Combine (remove duplicates)
    {
        echo "## Key Findings"
        echo "$existing" | grep "^-" | sort -u
        echo "$new" | sort -u
    } | sort -u
}

# Merge metrics
merge_metrics() {
    local existing_file=$1
    local new_findings_file=$2
    
    # Extract existing metrics
    local existing=$(extract_section "$existing_file" "Metrics")
    
    # Extract new metrics from JSON
    local new=""
    if command -v jq &> /dev/null; then
        new=$(jq -r '.metrics | to_entries[] | "- \(.key): \(.value)"' "$new_findings_file" 2>/dev/null)
    fi
    
    # Combine (new metrics override old ones)
    {
        echo "## Metrics"
        echo "$existing" | grep "^-" | grep -v "^- Complexity:\|^- Lines of Code:\|^- Parameter Count:\|^- Dependent Count:" || true
        echo "$new"
    } | sort -u
}

# Update analysis history
update_analysis_history() {
    local file=$1
    local agent_id="${GENERO_AGENT_ID:-unknown}"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Find the analysis history table
    local history_line=$(grep -n "^| $timestamp" "$file" | tail -1 | cut -d: -f1)
    
    if [[ -z "$history_line" ]]; then
        # Add new entry before "## Raw Data"
        local insert_line=$(grep -n "^## Raw Data" "$file" | cut -d: -f1)
        if [[ -n "$insert_line" ]]; then
            sed -i "${insert_line}i| $timestamp | $agent_id | merged_analysis | Merged findings from concurrent analysis |" "$file"
        fi
    fi
}

# Perform merge
log_debug "Merging key findings..."
merge_key_findings "$KNOWLEDGE_FILE" "$FINDINGS_FILE" > /tmp/merged_findings.txt

log_debug "Merging metrics..."
merge_metrics "$KNOWLEDGE_FILE" "$FINDINGS_FILE" > /tmp/merged_metrics.txt

log_debug "Updating analysis history..."
update_analysis_history "$KNOWLEDGE_FILE"

# Update last modified timestamp
sed -i "s/^**Last Updated:** .*/**Last Updated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)/" "$KNOWLEDGE_FILE"

log_info "Merge complete for $ARTIFACT_TYPE/$ARTIFACT_NAME"
log_debug "Backup saved to: $BACKUP_FILE"

exit 0
