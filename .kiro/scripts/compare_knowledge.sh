#!/bin/bash

################################################################################
# compare_knowledge.sh - Compare current findings with existing knowledge
#
# Purpose: Show what's new, what changed, and what's the same between current
#          findings and existing knowledge. Helps agents understand impact.
#
# Usage: bash compare_knowledge.sh --type <type> --name <name> --findings <file>
#
# Parameters:
#   --type <type>       Knowledge type (function, file, module, pattern, issue)
#   --name <name>       Knowledge artifact name
#   --findings <file>   Current findings to compare
#
# Exit Codes:
#   0 - Success
#   1 - Error
#   2 - No existing knowledge (nothing to compare)
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
    echo "No existing knowledge found for $ARTIFACT_TYPE/$ARTIFACT_NAME"
    exit 2
fi

log_info "Comparing knowledge for $ARTIFACT_TYPE/$ARTIFACT_NAME"

# Extract metrics from existing knowledge
extract_metric() {
    local file=$1
    local metric=$2
    
    grep "^- $metric:" "$file" 2>/dev/null | sed "s/^- $metric: //" || echo "N/A"
}

# Extract metrics from findings JSON
extract_json_metric() {
    local file=$1
    local metric=$2
    
    if command -v jq &> /dev/null; then
        jq -r ".metrics.$metric // \"N/A\"" "$file" 2>/dev/null || echo "N/A"
    else
        echo "N/A"
    fi
}

# Generate comparison report
REPORT_FILE="/tmp/knowledge_comparison_${ARTIFACT_NAME}_$(date +%s).txt"

cat > "$REPORT_FILE" << EOF
# Knowledge Comparison Report

**Artifact:** $ARTIFACT_TYPE/$ARTIFACT_NAME  
**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)  
**Existing Knowledge:** $KNOWLEDGE_FILE  
**Current Findings:** $FINDINGS_FILE

---

## Metrics Comparison

| Metric | Existing | Current | Change |
|--------|----------|---------|--------|
EOF

# Compare complexity
EXISTING_COMPLEXITY=$(extract_metric "$KNOWLEDGE_FILE" "Complexity")
CURRENT_COMPLEXITY=$(extract_json_metric "$FINDINGS_FILE" "complexity")

if [[ "$EXISTING_COMPLEXITY" != "N/A" ]] && [[ "$CURRENT_COMPLEXITY" != "N/A" ]]; then
    CHANGE=$((CURRENT_COMPLEXITY - EXISTING_COMPLEXITY))
    if [[ $CHANGE -gt 0 ]]; then
        CHANGE_STR="↑ +$CHANGE"
    elif [[ $CHANGE -lt 0 ]]; then
        CHANGE_STR="↓ $CHANGE"
    else
        CHANGE_STR="→ No change"
    fi
else
    CHANGE_STR="N/A"
fi

echo "| Complexity | $EXISTING_COMPLEXITY | $CURRENT_COMPLEXITY | $CHANGE_STR |" >> "$REPORT_FILE"

# Compare LOC
EXISTING_LOC=$(extract_metric "$KNOWLEDGE_FILE" "Lines of Code")
CURRENT_LOC=$(extract_json_metric "$FINDINGS_FILE" "lines_of_code")

if [[ "$EXISTING_LOC" != "N/A" ]] && [[ "$CURRENT_LOC" != "N/A" ]]; then
    CHANGE=$((CURRENT_LOC - EXISTING_LOC))
    if [[ $CHANGE -gt 0 ]]; then
        CHANGE_STR="↑ +$CHANGE"
    elif [[ $CHANGE -lt 0 ]]; then
        CHANGE_STR="↓ $CHANGE"
    else
        CHANGE_STR="→ No change"
    fi
else
    CHANGE_STR="N/A"
fi

echo "| Lines of Code | $EXISTING_LOC | $CURRENT_LOC | $CHANGE_STR |" >> "$REPORT_FILE"

# Compare dependents
EXISTING_DEPS=$(extract_metric "$KNOWLEDGE_FILE" "Dependent Count")
CURRENT_DEPS=$(extract_json_metric "$FINDINGS_FILE" "dependent_count")

if [[ "$EXISTING_DEPS" != "N/A" ]] && [[ "$CURRENT_DEPS" != "N/A" ]]; then
    CHANGE=$((CURRENT_DEPS - EXISTING_DEPS))
    if [[ $CHANGE -gt 0 ]]; then
        CHANGE_STR="↑ +$CHANGE (new dependents)"
    elif [[ $CHANGE -lt 0 ]]; then
        CHANGE_STR="↓ $CHANGE (removed dependents)"
    else
        CHANGE_STR="→ No change"
    fi
else
    CHANGE_STR="N/A"
fi

echo "| Dependent Count | $EXISTING_DEPS | $CURRENT_DEPS | $CHANGE_STR |" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'EOF'

---

## Key Findings

### Existing Findings
EOF

grep "^- " "$KNOWLEDGE_FILE" | grep -A 20 "^## Key Findings" | grep "^- " | head -10 >> "$REPORT_FILE" || echo "(none)" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'EOF'

### New Findings
EOF

if command -v jq &> /dev/null; then
    jq -r '.new_findings[]? // .key_findings[]?' "$FINDINGS_FILE" 2>/dev/null | sed 's/^/- /' >> "$REPORT_FILE" || echo "(none)" >> "$REPORT_FILE"
else
    echo "(unable to extract - jq not available)" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << 'EOF'

---

## Known Issues

### Existing Issues
EOF

grep "^- " "$KNOWLEDGE_FILE" | grep -A 20 "^## Known Issues" | grep "^- " | head -10 >> "$REPORT_FILE" || echo "(none)" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'EOF'

### New Issues
EOF

if command -v jq &> /dev/null; then
    jq -r '.known_issues[]?' "$FINDINGS_FILE" 2>/dev/null | sed 's/^/- /' >> "$REPORT_FILE" || echo "(none)" >> "$REPORT_FILE"
else
    echo "(unable to extract - jq not available)" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << 'EOF'

---

## Recommendations

### Existing Recommendations
EOF

grep "^- " "$KNOWLEDGE_FILE" | grep -A 20 "^## Recommendations" | grep "^- " | head -10 >> "$REPORT_FILE" || echo "(none)" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'EOF'

### New Recommendations
EOF

if command -v jq &> /dev/null; then
    jq -r '.recommendations[]?' "$FINDINGS_FILE" 2>/dev/null | sed 's/^/- /' >> "$REPORT_FILE" || echo "(none)" >> "$REPORT_FILE"
else
    echo "(unable to extract - jq not available)" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << 'EOF'

---

## Summary

**Recommendation:** Review the metrics changes above. If complexity or dependent count increased significantly, consider additional testing.

**Next Steps:**
1. Review metrics changes
2. Review new findings and issues
3. Decide on action: create, append, update, or deprecate
4. Commit knowledge with appropriate action

EOF

# Output report
cat "$REPORT_FILE"

log_info "Comparison report generated: $REPORT_FILE"

exit 0
