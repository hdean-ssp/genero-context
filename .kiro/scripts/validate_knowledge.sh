#!/bin/bash
# Validate Knowledge in AKR
# Checks schema compliance and consistency

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/akr-config.sh"

# ============================================================================
# Functions
# ============================================================================

log_info() {
  echo "[INFO] $*"
}

log_warning() {
  echo "[WARNING] $*"
}

log_error() {
  echo "[ERROR] $*"
}

log_success() {
  echo "[SUCCESS] $*"
}

validate_file() {
  local file=$1
  local filename=$(basename "$file")
  local errors=0

  # Check if file is readable
  if [ ! -r "$file" ]; then
    log_error "File not readable: $file"
    return 1
  fi

  # Check for required sections
  local required_sections=("Summary" "Key Findings" "Analysis History")
  for section in "${required_sections[@]}"; do
    if ! grep -q "^## $section" "$file"; then
      log_warning "Missing section in $filename: $section"
      ((errors++))
    fi
  done

  # Check for valid status
  if ! grep -q "^**Status:** (active|deprecated|archived)" "$file"; then
    if ! grep -q "^**Status:** active" "$file" && \
       ! grep -q "^**Status:** deprecated" "$file" && \
       ! grep -q "^**Status:** archived" "$file"; then
      log_warning "Invalid or missing status in $filename"
      ((errors++))
    fi
  fi

  # Check for valid timestamp format
  if ! grep -q "^**Last Updated:** [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z" "$file"; then
    log_warning "Invalid timestamp format in $filename"
    ((errors++))
  fi

  # Check for valid type
  if ! grep -q "^**Type:** (file|function|module|pattern|issue)" "$file"; then
    if ! grep -q "^**Type:** file" "$file" && \
       ! grep -q "^**Type:** function" "$file" && \
       ! grep -q "^**Type:** module" "$file" && \
       ! grep -q "^**Type:** pattern" "$file" && \
       ! grep -q "^**Type:** issue" "$file"; then
      log_warning "Invalid or missing type in $filename"
      ((errors++))
    fi
  fi

  return $errors
}

validate_directory() {
  local directory=$1
  local category=$2
  local total=0
  local valid=0
  local invalid=0

  if [ ! -d "$directory" ]; then
    log_info "Directory not found: $directory"
    return 0
  fi

  log_info "Validating $category..."

  for file in "$directory"/*.md; do
    if [ -f "$file" ]; then
      ((total++))
      if validate_file "$file"; then
        ((valid++))
      else
        ((invalid++))
      fi
    fi
  done

  log_info "  Total: $total, Valid: $valid, Invalid: $invalid"
  return $invalid
}

# ============================================================================
# Main Validation
# ============================================================================

log_info "Validating AKR at: $GENERO_AKR_BASE_PATH"
echo ""

total_invalid=0

validate_directory "$GENERO_AKR_FILES" "Files" || ((total_invalid+=$?))
validate_directory "$GENERO_AKR_FUNCTIONS" "Functions" || ((total_invalid+=$?))
validate_directory "$GENERO_AKR_MODULES" "Modules" || ((total_invalid+=$?))
validate_directory "$GENERO_AKR_PATTERNS" "Patterns" || ((total_invalid+=$?))
validate_directory "$GENERO_AKR_ISSUES" "Issues" || ((total_invalid+=$?))

echo ""

if [ $total_invalid -eq 0 ]; then
  log_success "All knowledge documents are valid!"
  exit 0
else
  log_error "Found $total_invalid validation issues"
  exit 1
fi
