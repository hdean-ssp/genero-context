#!/bin/bash

# Improved AKR Validation Script
# Checks schema compliance with correct regex patterns

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
LOG_FILE="${AKR_BASE}/.logs/validation.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Counters
TOTAL_FILES=0
VALID_FILES=0
INVALID_FILES=0

# Logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

mkdir -p "$(dirname "$LOG_FILE")"

log_info "Starting AKR validation"
log_info "AKR Base: $AKR_BASE"

# Function to validate a single file
validate_file() {
    local file="$1"
    local filename=$(basename "$file")
    local errors=0
    
    if [ ! -r "$file" ]; then
        log_error "File not readable: $filename"
        return 1
    fi
    
    ((TOTAL_FILES++))
    
    # Check for Type field
    if ! grep -q "^\*\*Type:\*\*" "$file"; then
        log_warn "Missing Type field in $filename"
        ((errors++))
    else
        # Validate Type value - extract everything after "**Type:** "
        local type=$(grep "^\*\*Type:\*\*" "$file" | head -1 | cut -d' ' -f2-)
        if [[ ! "$type" =~ ^(file|function|module|pattern|issue)$ ]]; then
            log_warn "Invalid Type value in $filename: '$type'"
            ((errors++))
        fi
    fi
    
    # Check for Status field
    if ! grep -q "^\*\*Status:\*\*" "$file"; then
        log_warn "Missing Status field in $filename"
        ((errors++))
    else
        # Validate Status value
        local status=$(grep "^\*\*Status:\*\*" "$file" | head -1 | cut -d' ' -f2-)
        if [[ ! "$status" =~ ^(active|deprecated|archived)$ ]]; then
            log_warn "Invalid Status value in $filename: '$status'"
            ((errors++))
        fi
    fi
    
    # Check for Last Updated field
    if ! grep -q "^\*\*Last Updated:\*\*" "$file"; then
        log_warn "Missing Last Updated field in $filename"
        ((errors++))
    else
        # Validate timestamp format (ISO 8601)
        local timestamp=$(grep "^\*\*Last Updated:\*\*" "$file" | head -1 | cut -d' ' -f3-)
        if ! [[ "$timestamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
            log_warn "Invalid timestamp format in $filename: '$timestamp'"
            ((errors++))
        fi
    fi
    
    # Check for required sections
    local required_sections=("Summary" "Key Findings" "Metrics" "Dependencies" "Analysis History")
    for section in "${required_sections[@]}"; do
        if ! grep -q "^## $section" "$file"; then
            log_warn "Missing section in $filename: $section"
            ((errors++))
        fi
    done
    
    if [ "$errors" -eq 0 ]; then
        ((VALID_FILES++))
        return 0
    else
        ((INVALID_FILES++))
        return 1
    fi
}

# Validate each directory
for dir in files functions modules patterns issues; do
    if [ -d "$AKR_BASE/$dir" ]; then
        log_info "Validating $dir..."
        
        for file in "$AKR_BASE/$dir"/*.md; do
            if [ -f "$file" ]; then
                validate_file "$file" || true
            fi
        done
    fi
done

# Summary
log_info ""
log_info "=========================================="
log_info "Validation Summary"
log_info "=========================================="
log_info "Total files: $TOTAL_FILES"
log_info "Valid files: $VALID_FILES"
log_info "Invalid files: $INVALID_FILES"
log_info "=========================================="

if [ "$INVALID_FILES" -eq 0 ]; then
    log_info "✓ All documents are valid!"
    exit 0
else
    log_error "✗ Found $INVALID_FILES invalid documents"
    exit 1
fi
