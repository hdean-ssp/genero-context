#!/bin/bash

################################################################################
# detect_patterns.sh - Automatically detect patterns across knowledge
#
# Purpose: Discover common patterns in code (naming, error handling, validation)
#          and flag inconsistencies
#
# Usage: bash detect_patterns.sh [--type TYPE] [--report]
#
# Parameters:
#   --type <type>       Analyze specific type: function, file, module
#   --report            Generate detailed report
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
ANALYZE_TYPE=""
GENERATE_REPORT=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --type) ANALYZE_TYPE="$2"; shift 2 ;;
        --report) GENERATE_REPORT=1; shift ;;
        *) shift ;;
    esac
done

# Validate AKR base path
if [[ ! -d "$GENERO_AKR_BASE_PATH" ]]; then
    log_error "AKR base path does not exist: $GENERO_AKR_BASE_PATH"
    exit 1
fi

log_info "Detecting patterns (type=$ANALYZE_TYPE, report=$GENERATE_REPORT)"

# Detect naming patterns
detect_naming_patterns() {
    local type=$1
    local path=$2
    
    if [[ ! -d "$path" ]]; then
        return
    fi
    
    echo "## Naming Patterns - $type"
    echo ""
    
    # Extract function/artifact names
    find "$path" -name "*.md" -type f | while read -r file; do
        name=$(basename "$file" .md)
        
        # Check naming convention
        if [[ $name =~ ^[a-z_]+$ ]]; then
            prefix=$(echo "$name" | cut -d_ -f1)
            echo "- $name (prefix: $prefix)"
        fi
    done | sort | uniq -c | sort -rn | head -10
    
    echo ""
}

# Detect error handling patterns
detect_error_patterns() {
    local type=$1
    local path=$2
    
    if [[ ! -d "$path" ]]; then
        return
    fi
    
    echo "## Error Handling Patterns - $type"
    echo ""
    
    # Look for error handling mentions
    grep -h "Error Handling\|error handling\|return status\|exception" "$path"/*.md 2>/dev/null | \
        sed 's/^- //' | sort | uniq -c | sort -rn | head -10 || echo "(no patterns found)"
    
    echo ""
}

# Detect validation patterns
detect_validation_patterns() {
    local type=$1
    local path=$2
    
    if [[ ! -d "$path" ]]; then
        return
    fi
    
    echo "## Validation Patterns - $type"
    echo ""
    
    # Look for validation mentions
    grep -h "Validation\|validation\|validate\|check" "$path"/*.md 2>/dev/null | \
        sed 's/^- //' | sort | uniq -c | sort -rn | head -10 || echo "(no patterns found)"
    
    echo ""
}

# Generate pattern report
generate_report() {
    local report_file="/tmp/pattern_report_$(date +%s).txt"
    
    {
        echo "# Pattern Detection Report"
        echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        
        if [[ -z "$ANALYZE_TYPE" ]] || [[ "$ANALYZE_TYPE" == "function" ]]; then
            detect_naming_patterns "Functions" "${GENERO_AKR_FUNCTIONS}"
            detect_error_patterns "Functions" "${GENERO_AKR_FUNCTIONS}"
            detect_validation_patterns "Functions" "${GENERO_AKR_FUNCTIONS}"
        fi
        
        if [[ -z "$ANALYZE_TYPE" ]] || [[ "$ANALYZE_TYPE" == "file" ]]; then
            detect_naming_patterns "Files" "${GENERO_AKR_FILES}"
        fi
        
        if [[ -z "$ANALYZE_TYPE" ]] || [[ "$ANALYZE_TYPE" == "module" ]]; then
            detect_naming_patterns "Modules" "${GENERO_AKR_MODULES}"
        fi
        
        echo "## Recommendations"
        echo ""
        echo "- Standardize naming conventions across similar artifacts"
        echo "- Ensure consistent error handling approach"
        echo "- Document validation patterns for new code"
        echo "- Consider creating pattern knowledge documents"
        
    } > "$report_file"
    
    cat "$report_file"
    log_info "Pattern report generated: $report_file"
}

# Main execution
if [[ $GENERATE_REPORT -eq 1 ]]; then
    generate_report
else
    # Quick pattern summary
    echo "# Pattern Detection Summary"
    echo ""
    
    if [[ -z "$ANALYZE_TYPE" ]] || [[ "$ANALYZE_TYPE" == "function" ]]; then
        echo "## Function Naming Patterns"
        find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f 2>/dev/null | \
            xargs -I {} basename {} .md | \
            sed 's/_/\n/g' | sort | uniq -c | sort -rn | head -5 || echo "(no functions)"
        echo ""
    fi
    
    if [[ -z "$ANALYZE_TYPE" ]] || [[ "$ANALYZE_TYPE" == "module" ]]; then
        echo "## Module Naming Patterns"
        find "${GENERO_AKR_MODULES}" -name "*.md" -type f 2>/dev/null | \
            xargs -I {} basename {} .md | \
            sed 's/_/\n/g' | sort | uniq -c | sort -rn | head -5 || echo "(no modules)"
        echo ""
    fi
    
    echo "Use --report flag for detailed pattern analysis"
fi

log_info "Pattern detection complete"
exit 0
