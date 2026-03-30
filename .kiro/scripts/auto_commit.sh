#!/bin/bash

################################################################################
# auto_commit.sh - Automatically commit knowledge in Reviewer Hat
#
# Purpose: Hook that runs in Reviewer Hat to automatically commit knowledge
#          with intelligent action selection
#
# Usage: bash auto_commit.sh --type TYPE --name NAME --findings FILE
#
# Parameters:
#   --type <type>       Knowledge type: function, file, module, pattern, issue
#   --name <name>       Artifact name
#   --findings <file>   Findings JSON file
#   --action <action>   Action: create, append, update, deprecate (optional)
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
log_info() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [INFO] $*" >> "${GENERO_AKR_LOGS}/akr.log"
}

log_error() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [ERROR] $*" >> "${GENERO_AKR_LOGS}/akr.log"
}

# Parse arguments
ARTIFACT_TYPE=""
ARTIFACT_NAME=""
FINDINGS_FILE=""
ACTION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --type) ARTIFACT_TYPE="$2"; shift 2 ;;
        --name) ARTIFACT_NAME="$2"; shift 2 ;;
        --findings) FINDINGS_FILE="$2"; shift 2 ;;
        --action) ACTION="$2"; shift 2 ;;
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

log_info "Auto-committing knowledge: $ARTIFACT_TYPE/$ARTIFACT_NAME"

# Determine action if not specified
if [[ -z "$ACTION" ]]; then
    # Check if knowledge exists
    if bash "${SCRIPT_DIR}/retrieve_knowledge.sh" --type "$ARTIFACT_TYPE" --name "$ARTIFACT_NAME" >/dev/null 2>&1; then
        # Knowledge exists, check if it changed significantly
        if bash "${SCRIPT_DIR}/compare_knowledge.sh" --type "$ARTIFACT_TYPE" --name "$ARTIFACT_NAME" --findings "$FINDINGS_FILE" >/dev/null 2>&1; then
            # Check for significant changes
            if grep -q "↑\|↓" /tmp/knowledge_comparison_*.txt 2>/dev/null; then
                ACTION="update"
            else
                ACTION="append"
            fi
        else
            ACTION="append"
        fi
    else
        # No existing knowledge
        ACTION="create"
    fi
    
    log_info "Auto-selected action: $ACTION"
fi

# Commit knowledge
echo "💾 Committing knowledge: $ARTIFACT_TYPE/$ARTIFACT_NAME (action: $ACTION)"
echo ""

if bash "${SCRIPT_DIR}/commit_knowledge.sh" \
    --type "$ARTIFACT_TYPE" \
    --name "$ARTIFACT_NAME" \
    --findings "$FINDINGS_FILE" \
    --action "$ACTION"; then
    
    echo "✅ Knowledge committed successfully"
    log_info "Knowledge committed: $ARTIFACT_TYPE/$ARTIFACT_NAME (action: $ACTION)"
    exit 0
else
    echo "❌ Failed to commit knowledge"
    log_error "Failed to commit knowledge: $ARTIFACT_TYPE/$ARTIFACT_NAME"
    exit 1
fi
