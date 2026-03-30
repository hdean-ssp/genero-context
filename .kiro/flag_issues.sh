#!/bin/bash

################################################################################
# flag_issues.sh - Automatically detect and flag issues across knowledge
#
# Purpose: Scan all knowledge documents for known issues, risks, and problems
#          Track issues and suggest fixes
#
# Usage: bash flag_issues.sh [--severity high|medium|low] [--report]
#
# Parameters:
#   --severity <level>  Filter by severity: high, medium, low
#   --report            Generate detailed issue report
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
SEVERITY_FILTER=""
GENERATE_REPORT=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --severity) SEVERITY_FILTER="$2"; shift 2 ;;
        --report) GENERATE_REPORT=1; shift ;;
        *) shift ;;
    esac
done

# Validate AKR base path
if [[ ! -d "$GENERO_AKR_BASE_PATH" ]]; then
    log_error "AKR base path does not exist: $GENERO_AKR_BASE_PATH"
    exit 1
fi

log_info "Flagging issues (severity=$SEVERITY_FILTER, report=$GENERATE_REPORT)"

# Scan for high complexity functions
scan_complexity() {
    echo "## High Complexity Functions"
    echo ""
    
    find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f 2>/dev/null | while read -r file; do
        complexity=$(grep "^- Complexity:" "$file" 2>/dev/null | sed 's/.*: //' || echo "0")
        if [[ $complexity -gt 10 ]]; then
            name=$(basename "$file" .md)
            echo "- **$name** (complexity: $complexity) - HIGH RISK"
        fi
    done
    
    echo ""
}

# Scan for many dependents
scan_dependents() {
    echo "## Functions with Many Dependents"
    echo ""
    
    find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f 2>/dev/null | while read -r file; do
        dependents=$(grep "^- Dependent Count:" "$file" 2>/dev/null | sed 's/.*: //' || echo "0")
        if [[ $dependents -gt 15 ]]; then
            name=$(basename "$file" .md)
            echo "- **$name** ($dependents dependents) - CHANGE RISK"
        fi
    done
    
    echo ""
}

# Scan for known issues
scan_known_issues() {
    echo "## Known Issues Across Codebase"
    echo ""
    
    find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f 2>/dev/null | while read -r file; do
        if grep -q "^## Known Issues" "$file"; then
            name=$(basename "$file" .md)
            issues=$(sed -n '/^## Known Issues/,/^## /p' "$file" | grep "^- " | head -3)
            if [[ -n "$issues" ]]; then
                echo "**$name:**"
                echo "$issues" | sed 's/^/  /'
                echo ""
            fi
        fi
    done
    
    echo ""
}

# Scan for type resolution issues
scan_type_issues() {
    echo "## Type Resolution Issues"
    echo ""
    
    find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f 2>/dev/null | while read -r file; do
        if grep -q "LIKE\|type resolution\|unresolved" "$file"; then
            name=$(basename "$file" .md)
            echo "- **$name** - Type resolution issue detected"
        fi
    done
    
    echo ""
}

# Scan for deprecated knowledge
scan_deprecated() {
    echo "## Deprecated Knowledge"
    echo ""
    
    find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f 2>/dev/null | while read -r file; do
        if grep -q "^\\*\\*Status:\\*\\* deprecated" "$file"; then
            name=$(basename "$file" .md)
            echo "- **$name** - Marked as deprecated, needs re-analysis"
        fi
    done
    
    echo ""
}

# Generate issue report
generate_report() {
    local report_file="/tmp/issue_report_$(date +%s).txt"
    
    {
        echo "# Issue Detection Report"
        echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        
        scan_complexity
        scan_dependents
        scan_known_issues
        scan_type_issues
        scan_deprecated
        
        echo "## Recommendations"
        echo ""
        echo "- **High Complexity:** Consider breaking into smaller functions"
        echo "- **Many Dependents:** Changes are high-risk, require extensive testing"
        echo "- **Type Issues:** Resolve LIKE references and type resolution"
        echo "- **Deprecated:** Re-analyze and update knowledge"
        echo "- **Known Issues:** Create issue knowledge documents"
        
    } > "$report_file"
    
    cat "$report_file"
    log_info "Issue report generated: $report_file"
}

# Main execution
if [[ $GENERATE_REPORT -eq 1 ]]; then
    generate_report
else
    # Quick issue summary
    echo "# Issue Detection Summary"
    echo ""
    
    high_complexity=$(find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f 2>/dev/null | \
        xargs grep "^- Complexity:" 2>/dev/null | grep -o "[0-9]*" | awk '$1 > 10' | wc -l || echo 0)
    
    many_dependents=$(find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f 2>/dev/null | \
        xargs grep "^- Dependent Count:" 2>/dev/null | grep -o "[0-9]*" | awk '$1 > 15' | wc -l || echo 0)
    
    deprecated=$(find "${GENERO_AKR_FUNCTIONS}" -name "*.md" -type f 2>/dev/null | \
        xargs grep -l "deprecated" 2>/dev/null | wc -l || echo 0)
    
    echo "- High Complexity Functions: $high_complexity"
    echo "- Functions with Many Dependents: $many_dependents"
    echo "- Deprecated Knowledge: $deprecated"
    echo ""
    echo "Use --report flag for detailed issue analysis"
fi

log_info "Issue flagging complete"
exit 0
