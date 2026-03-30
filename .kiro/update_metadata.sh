#!/bin/bash

################################################################################
# update_metadata.sh - Automatically update AKR metadata
#
# Purpose: Update INDEX.md, statistics.md, and last_updated.txt when knowledge
#          is committed. Called automatically by commit_knowledge.sh.
#
# Usage: bash update_metadata.sh --type <type> --name <name> --action <action>
#
# Parameters:
#   --type <type>       Knowledge type (function, file, module, pattern, issue)
#   --name <name>       Knowledge artifact name
#   --action <action>   Action taken (create, append, update, deprecate)
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
ACTION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --type) ARTIFACT_TYPE="$2"; shift 2 ;;
        --name) ARTIFACT_NAME="$2"; shift 2 ;;
        --action) ACTION="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate arguments
if [[ -z "$ARTIFACT_TYPE" ]] || [[ -z "$ARTIFACT_NAME" ]] || [[ -z "$ACTION" ]]; then
    log_error "Missing required arguments: --type, --name, --action"
    exit 1
fi

# Validate AKR base path
if [[ ! -d "$GENERO_AKR_BASE_PATH" ]]; then
    log_error "AKR base path does not exist: $GENERO_AKR_BASE_PATH"
    exit 1
fi

# Lock metadata for updates
METADATA_LOCK="${GENERO_AKR_LOCKS}/metadata.lock"
LOCK_TIMEOUT=30
LOCK_ACQUIRED=0

# Acquire lock
for ((i=0; i<LOCK_TIMEOUT; i++)); do
    if mkdir "$METADATA_LOCK" 2>/dev/null; then
        LOCK_ACQUIRED=1
        break
    fi
    sleep 1
done

if [[ $LOCK_ACQUIRED -eq 0 ]]; then
    log_error "Failed to acquire metadata lock after ${LOCK_TIMEOUT}s"
    exit 1
fi

# Ensure lock is released on exit
trap "rmdir '$METADATA_LOCK' 2>/dev/null || true" EXIT

log_info "Updating metadata for $ARTIFACT_TYPE/$ARTIFACT_NAME (action: $ACTION)"

# Update INDEX.md
update_index() {
    local index_file="${GENERO_AKR_METADATA}/INDEX.md"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local agent_id="${GENERO_AGENT_ID:-unknown}"
    
    # Create INDEX.md if it doesn't exist
    if [[ ! -f "$index_file" ]]; then
        cat > "$index_file" << 'EOF'
# Agent Knowledge Repository Index

**Last Updated:** [TIMESTAMP]  
**Total Documents:** [TOTAL]

## By Type

### Functions
[FUNCTIONS]

### Files
[FILES]

### Modules
[MODULES]

### Patterns
[PATTERNS]

### Issues
[ISSUES]

---

## Statistics

- Total documents: [TOTAL]
- Functions: [FUNC_COUNT]
- Files: [FILE_COUNT]
- Modules: [MOD_COUNT]
- Patterns: [PAT_COUNT]
- Issues: [ISS_COUNT]

---

## Recent Updates

[RECENT]
EOF
    fi
    
    # Count documents by type
    local func_count=$(find "${GENERO_AKR_FUNCTIONS}" -name "*.md" 2>/dev/null | wc -l)
    local file_count=$(find "${GENERO_AKR_FILES}" -name "*.md" 2>/dev/null | wc -l)
    local mod_count=$(find "${GENERO_AKR_MODULES}" -name "*.md" 2>/dev/null | wc -l)
    local pat_count=$(find "${GENERO_AKR_PATTERNS}" -name "*.md" 2>/dev/null | wc -l)
    local iss_count=$(find "${GENERO_AKR_ISSUES}" -name "*.md" 2>/dev/null | wc -l)
    local total=$((func_count + file_count + mod_count + pat_count + iss_count))
    
    # Build function list
    local functions_list=""
    if [[ $func_count -gt 0 ]]; then
        functions_list=$(find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f | \
            xargs -I {} basename {} .md | \
            sort | \
            sed 's/^/- /' | \
            head -20)
        if [[ $func_count -gt 20 ]]; then
            functions_list="${functions_list}
- ... and $((func_count - 20)) more"
        fi
    else
        functions_list="(none)"
    fi
    
    # Build recent updates list
    local recent_list="- $ARTIFACT_TYPE/$ARTIFACT_NAME ($ACTION) - $timestamp by $agent_id"
    
    # Update INDEX.md with new values
    sed -i "s|\[TIMESTAMP\]|$timestamp|g" "$index_file"
    sed -i "s|\[TOTAL\]|$total|g" "$index_file"
    sed -i "s|\[FUNC_COUNT\]|$func_count|g" "$index_file"
    sed -i "s|\[FILE_COUNT\]|$file_count|g" "$index_file"
    sed -i "s|\[MOD_COUNT\]|$mod_count|g" "$index_file"
    sed -i "s|\[PAT_COUNT\]|$pat_count|g" "$index_file"
    sed -i "s|\[ISS_COUNT\]|$iss_count|g" "$index_file"
    sed -i "s|\[FUNCTIONS\]|$functions_list|g" "$index_file"
    sed -i "s|\[RECENT\]|$recent_list|g" "$index_file"
    
    log_info "Updated INDEX.md"
}

# Update statistics.md
update_statistics() {
    local stats_file="${GENERO_AKR_METADATA}/statistics.md"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Count documents by type
    local func_count=$(find "${GENERO_AKR_FUNCTIONS}" -name "*.md" 2>/dev/null | wc -l)
    local file_count=$(find "${GENERO_AKR_FILES}" -name "*.md" 2>/dev/null | wc -l)
    local mod_count=$(find "${GENERO_AKR_MODULES}" -name "*.md" 2>/dev/null | wc -l)
    local pat_count=$(find "${GENERO_AKR_PATTERNS}" -name "*.md" 2>/dev/null | wc -l)
    local iss_count=$(find "${GENERO_AKR_ISSUES}" -name "*.md" 2>/dev/null | wc -l)
    local total=$((func_count + file_count + mod_count + pat_count + iss_count))
    
    # Create statistics.md
    cat > "$stats_file" << EOF
# AKR Statistics

**Last Updated:** $timestamp

## Document Counts

| Type | Count |
|------|-------|
| Functions | $func_count |
| Files | $file_count |
| Modules | $mod_count |
| Patterns | $pat_count |
| Issues | $iss_count |
| **Total** | **$total** |

## Recent Activity

- Last action: $ACTION on $ARTIFACT_TYPE/$ARTIFACT_NAME
- Timestamp: $timestamp
- Agent: ${GENERO_AGENT_ID:-unknown}

EOF
    
    log_info "Updated statistics.md"
}

# Update last_updated.txt
update_timestamp() {
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "$timestamp" > "${GENERO_AKR_METADATA}/last_updated.txt"
    log_info "Updated last_updated.txt"
}

# Execute updates
update_index
update_statistics
update_timestamp

log_info "Metadata update complete"
exit 0
