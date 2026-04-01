#!/bin/bash

# Comprehensive AKR Repair Script
# Fixes all schema compliance issues in AKR documents
# This script is more robust than repair_akr.sh and handles edge cases

set -e

# Source configuration
if [ -f ~/.kiro/scripts/akr-config.sh ]; then
    source ~/.kiro/scripts/akr-config.sh
elif [ -f /home/hdean/.kiro/scripts/akr-config.sh ]; then
    source /home/hdean/.kiro/scripts/akr-config.sh
else
    echo "ERROR: akr-config.sh not found"
    exit 1
fi

AKR_BASE="${GENERO_AKR_BASE_PATH}"
LOG_FILE="${AKR_BASE}/.logs/repair_comprehensive.log"
STATS_FILE="${AKR_BASE}/.logs/repair_stats.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_FILES=0
REPAIRED_FILES=0
FAILED_FILES=0
TOTAL_CHANGES=0

# Logging functions
log() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%SZ')] $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1" | tee -a "$LOG_FILE"
}

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log_info "Starting comprehensive AKR repair"
log_info "AKR Base: $AKR_BASE"
log_info "Log File: $LOG_FILE"

# Function to infer type from directory
infer_type() {
    local file="$1"
    if [[ "$file" == */functions/* ]]; then
        echo "function"
    elif [[ "$file" == */modules/* ]]; then
        echo "module"
    elif [[ "$file" == */patterns/* ]]; then
        echo "pattern"
    elif [[ "$file" == */issues/* ]]; then
        echo "issue"
    else
        echo "file"
    fi
}

# Function to validate ISO 8601 timestamp
is_valid_iso8601() {
    local timestamp="$1"
    if [[ $timestamp =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
        return 0
    fi
    return 1
}

# Function to convert date to ISO 8601
to_iso8601() {
    local date_str="$1"
    
    # Already ISO 8601
    if is_valid_iso8601 "$date_str"; then
        echo "$date_str"
        return 0
    fi
    
    # Try to parse and convert
    if [[ $date_str =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "${date_str}T00:00:00Z"
        return 0
    fi
    
    # Default to current time
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Function to repair a single file
repair_file() {
    local file="$1"
    local changes=0
    
    if [ ! -f "$file" ]; then
        log_warn "File not found: $file"
        ((FAILED_FILES++))
        return 1
    fi
    
    ((TOTAL_FILES++))
    local filename=$(basename "$file")
    log_debug "Processing: $filename"
    
    # Read file content
    local content=$(cat "$file")
    local original_content="$content"
    
    # Extract title (first line starting with #)
    local title=$(echo "$content" | grep "^# " | head -1 | sed 's/^# //')
    if [ -z "$title" ]; then
        title="$filename"
    fi
    
    # Infer type from directory
    local inferred_type=$(infer_type "$file")
    
    # Check and fix Type field
    if ! echo "$content" | grep -q "^\\*\\*Type:\\*\\*"; then
        log_debug "  Adding Type field: $inferred_type"
        # Insert after title
        content=$(echo "$content" | sed "1a\\
\\
**Type:** $inferred_type")
        ((changes++))
    else
        # Validate Type value
        local current_type=$(echo "$content" | grep "^\\*\\*Type:\\*\\*" | head -1 | sed 's/.*: //')
        if [[ ! "$current_type" =~ ^(file|function|module|pattern|issue)$ ]]; then
            log_debug "  Fixing invalid Type: $current_type -> $inferred_type"
            content=$(echo "$content" | sed "s/^\\*\\*Type:\\*\\*.*/\*\*Type:\*\* $inferred_type/")
            ((changes++))
        fi
    fi
    
    # Check and fix Status field
    if ! echo "$content" | grep -q "^\\*\\*Status:\\*\\*"; then
        log_debug "  Adding Status field: active"
        # Insert after Type
        content=$(echo "$content" | sed "/^\\*\\*Type:\\*\\*/a\\
**Status:** active")
        ((changes++))
    else
        # Validate Status value
        local current_status=$(echo "$content" | grep "^\\*\\*Status:\\*\\*" | head -1 | sed 's/.*: //')
        if [[ ! "$current_status" =~ ^(active|deprecated|archived)$ ]]; then
            log_debug "  Fixing invalid Status: $current_status -> active"
            content=$(echo "$content" | sed "s/^\\*\\*Status:\\*\\*.*/\*\*Status:\*\* active/")
            ((changes++))
        fi
    fi
    
    # Check and fix Last Updated timestamp
    if ! echo "$content" | grep -q "^\\*\\*Last Updated:\\*\\*"; then
        log_debug "  Adding Last Updated field"
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        content=$(echo "$content" | sed "/^\\*\\*Status:\\*\\*/a\\
**Last Updated:** $timestamp")
        ((changes++))
    else
        # Validate and fix timestamp format
        local current_timestamp=$(echo "$content" | grep "^\\*\\*Last Updated:\\*\\*" | head -1 | sed 's/.*: //')
        if ! is_valid_iso8601 "$current_timestamp"; then
            local fixed_timestamp=$(to_iso8601 "$current_timestamp")
            log_debug "  Fixing timestamp format: $current_timestamp -> $fixed_timestamp"
            content=$(echo "$content" | sed "s/^\\*\\*Last Updated:\\*\\*.*/\*\*Last Updated:\*\* $fixed_timestamp/")
            ((changes++))
        fi
    fi
    
    # Check and fix Updated By field
    if ! echo "$content" | grep -q "^\\*\\*Updated By:\\*\\*"; then
        log_debug "  Adding Updated By field"
        content=$(echo "$content" | sed "/^\\*\\*Last Updated:\\*\\*/a\\
**Updated By:** repair-script")
        ((changes++))
    fi
    
    # Check and fix Path field
    if ! echo "$content" | grep -q "^\\*\\*Path:\\*\\*"; then
        log_debug "  Adding Path field"
        content=$(echo "$content" | sed "/^\\*\\*Updated By:\\*\\*/a\\
**Path:** N/A")
        ((changes++))
    fi
    
    # Check for required sections
    local required_sections=("Key Findings" "Metrics" "Dependencies" "Known Issues" "Recommendations" "Analysis History")
    
    for section in "${required_sections[@]}"; do
        if ! echo "$content" | grep -q "^## $section"; then
            log_debug "  Adding missing section: $section"
            
            case "$section" in
                "Key Findings")
                    content=$(echo "$content"
</content>
</file>\n'"## Key Findings"
</content>
</file>\n'"- [Placeholder: Add specific findings]")
                    ;;
                "Metrics")
                    content=$(echo "$content"
</content>
</file>\n'"## Metrics"
</content>
</file>\n'"- Complexity: N/A"
</content>
</file>\n'"- Lines of Code: N/A"
</content>
</file>\n'"- Parameter Count: N/A"
</content>
</file>\n'"- Dependent Count: N/A")
                    ;;
                "Dependencies")
                    content=$(echo "$content"
</content>
</file>\n'"## Dependencies"
</content>
</file>\n'"- Calls: N/A"
</content>
</file>\n'"- Called By: N/A")
                    ;;
                "Known Issues")
                    content=$(echo "$content"
</content>
</file>\n'"## Known Issues"
</content>
</file>\n'"- None known")
                    ;;
                "Recommendations")
                    content=$(echo "$content"
</content>
</file>\n'"## Recommendations"
</content>
</file>\n'"- [Placeholder: Add recommendations]")
                    ;;
                "Analysis History")
                    local timestamp=$(date +%Y-%m-%d)
                    content=$(echo "$content"
</content>
</file>\n'"## Analysis History"
</content>
</file>\n'"| Date | Agent | Action | Notes |"
</content>
</file>\n'"|------|-------|--------|-------|"
</content>
</file>\n'"| $timestamp | repair-script | structural_repair | Fixed schema compliance |")
                    ;;
            esac
            ((changes++))
        fi
    done
    
    # Write changes if content was modified
    if [ "$changes" -gt 0 ]; then
        echo "$content" > "$file"
        log_info "✓ Repaired $filename ($changes changes)"
        ((REPAIRED_FILES++))
        ((TOTAL_CHANGES+=changes))
    else
        log_debug "✓ $filename already compliant"
    fi
    
    return 0
}

# Main repair logic
log_info "Starting repair of all AKR documents..."
log_info ""

for dir in files functions modules patterns issues; do
    if [ -d "$AKR_BASE/$dir" ]; then
        log_info "Processing directory: $dir"
        
        for file in "$AKR_BASE/$dir"/*.md; do
            if [ -f "$file" ]; then
                repair_file "$file" || true
            fi
        done
        
        log_info ""
    fi
done

# Summary
log_info "=========================================="
log_info "Repair Summary"
log_info "=========================================="
log_info "Total files processed: $TOTAL_FILES"
log_info "Files repaired: $REPAIRED_FILES"
log_info "Files failed: $FAILED_FILES"
log_info "Total changes applied: $TOTAL_CHANGES"
log_info "=========================================="

# Write statistics
cat > "$STATS_FILE" << EOF
Repair Statistics
=================
Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Total Files: $TOTAL_FILES
Repaired: $REPAIRED_FILES
Failed: $FAILED_FILES
Total Changes: $TOTAL_CHANGES
EOF

log_info "Statistics saved to: $STATS_FILE"
log_info "Repair complete!"

exit 0
