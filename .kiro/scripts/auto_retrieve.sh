#!/bin/bash

################################################################################
# auto_retrieve.sh - Automatically retrieve knowledge in Planner Hat
#
# Purpose: Hook that runs at start of Planner Hat to automatically retrieve
#          existing knowledge about target artifacts
#
# Usage: bash auto_retrieve.sh --type TYPE --name NAME
#
# Parameters:
#   --type <type>       Knowledge type: function, file, module
#   --name <name>       Artifact name
#
# Exit Codes:
#   0 - Success
#   1 - Error
#   2 - No knowledge found (normal)
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

while [[ $# -gt 0 ]]; do
    case $1 in
        --type) ARTIFACT_TYPE="$2"; shift 2 ;;
        --name) ARTIFACT_NAME="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate arguments
if [[ -z "$ARTIFACT_TYPE" ]] || [[ -z "$ARTIFACT_NAME" ]]; then
    log_error "Missing required arguments: --type, --name"
    exit 1
fi

log_info "Auto-retrieving knowledge: $ARTIFACT_TYPE/$ARTIFACT_NAME"

# Retrieve knowledge
echo "🔍 Retrieving existing knowledge for $ARTIFACT_TYPE/$ARTIFACT_NAME..."
echo ""

if bash "${SCRIPT_DIR}/retrieve_knowledge.sh" --type "$ARTIFACT_TYPE" --name "$ARTIFACT_NAME"; then
    log_info "Knowledge retrieved successfully"
    exit 0
else
    echo "ℹ️  No existing knowledge found (this is normal for new artifacts)"
    log_info "No knowledge found for $ARTIFACT_TYPE/$ARTIFACT_NAME"
    exit 2
fi
