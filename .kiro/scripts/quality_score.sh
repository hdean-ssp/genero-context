#!/bin/bash

################################################################################
# quality_score.sh - Score knowledge quality and accuracy
#
# Purpose: Rate knowledge documents on quality, accuracy, and completeness
#          Identify stale or low-quality knowledge
#
# Usage: bash quality_score.sh [--type TYPE] [--threshold SCORE]
#
# Parameters:
#   --type <type>       Filter by type: function, file, module
#   --threshold <score> Show only scores below threshold (0-100)
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
FILTER_TYPE=""
THRESHOLD=100

while [[ $# -gt 0 ]]; do
    case $1 in
        --type) FILTER_TYPE="$2"; shift 2 ;;
        --threshold) THRESHOLD="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate AKR base path
if [[ ! -d "$GENERO_AKR_BASE_PATH" ]]; then
    log_error "AKR base path does not exist: $GENERO_AKR_BASE_PATH"
    exit 1
fi

# Score a knowledge document
score_document() {
    local file=$1
    local score=0
    
    # Check for summary (10 points)
    grep -q "^## Summary" "$file" && ((score += 10))
    
    # Check for key findings (15 points)
    grep -q "^## Key Findings" "$file" && ((score += 15))
    
    # Check for metrics (15 points)
    grep -q "^- Complexity:" "$file" && ((score += 15))
    
    # Check for dependencies (10 points)
    grep -q "^## Dependencies" "$file" && ((score += 10))
    
    # Check for known issues (10 points)
    grep -q "^## Known Issues" "$file" && ((score += 10))
    
    # Check for recommendations (10 points)
    grep -q "^## Recommendations" "$file" && ((score += 10))
    
    # Check for analysis history (15 points)
    grep -q "^## Analysis History" "$file" && ((score += 15))
    
    # Check if not deprecated (5 points)
    ! grep -q "deprecated" "$file" && ((score += 5))
    
    echo $score
}

# Main execution
echo "# Knowledge Quality Scores"
echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""
echo "| Type | Name | Score | Status |"
echo "|------|------|-------|--------|"

# Score all documents
for type_dir in "${GENERO_AKR_FUNCTIONS}" "${GENERO_AKR_FILES}" "${GENERO_AKR_MODULES}"; do
    if [[ ! -d "$type_dir" ]]; then
        continue
    fi
    
    type_name=$(basename "$type_dir")
    
    # Skip if type filter specified and doesn't match
    if [[ -n "$FILTER_TYPE" ]] && [[ "$type_name" != "${FILTER_TYPE}s" ]]; then
        continue
    fi
    
    find "$type_dir" -name "*.md" -type f | while read -r file; do
        name=$(basename "$file" .md)
        score=$(score_document "$file")
        
        if [[ $score -lt $THRESHOLD ]]; then
            if [[ $score -ge 80 ]]; then
                status="✅ Good"
            elif [[ $score -ge 60 ]]; then
                status="⚠️  Fair"
            else
                status="❌ Poor"
            fi
            
            echo "| $type_name | $name | $score/100 | $status |"
        fi
    done
done

echo ""
echo "**Scoring Criteria:**"
echo "- 80-100: Good (complete and accurate)"
echo "- 60-79: Fair (missing some details)"
echo "- <60: Poor (incomplete or stale)"

exit 0
