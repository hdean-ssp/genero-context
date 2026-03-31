#!/bin/bash
################################################################################
# AKR Test Framework
# Provides common testing utilities for all AKR scripts
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test configuration
TEST_TEMP_DIR=""
TEST_AKR_BASE=""
VERBOSE=${VERBOSE:-0}

################################################################################
# Setup and Teardown
################################################################################

setup_test_environment() {
  # Create temporary test directory
  TEST_TEMP_DIR=$(mktemp -d)
  TEST_AKR_BASE="${TEST_TEMP_DIR}/akr"
  
  # Create AKR directory structure
  mkdir -p "${TEST_AKR_BASE}"/{files,functions,modules,patterns,issues,metadata,.locks,.logs}
  
  # Export for use in tests
  export GENERO_AKR_BASE_PATH="${TEST_AKR_BASE}"
  export GENERO_AKR_FILES="${TEST_AKR_BASE}/files"
  export GENERO_AKR_FUNCTIONS="${TEST_AKR_BASE}/functions"
  export GENERO_AKR_MODULES="${TEST_AKR_BASE}/modules"
  export GENERO_AKR_PATTERNS="${TEST_AKR_BASE}/patterns"
  export GENERO_AKR_ISSUES="${TEST_AKR_BASE}/issues"
  export GENERO_AKR_METADATA="${TEST_AKR_BASE}/metadata"
  export GENERO_AKR_LOCKS="${TEST_AKR_BASE}/.locks"
  export GENERO_AKR_LOGS="${TEST_AKR_BASE}/.logs"
  export GENERO_AKR_LOG_FILE="${TEST_AKR_LOGS}/akr.log"
  export GENERO_AKR_LOG_LEVEL="info"
  
  # Create initial metadata files
  cat > "${GENERO_AKR_METADATA}/agents.md" << 'EOF'
# Agent Activity Log

| Date | Agent | Action | Artifact | Type | Status |
|------|-------|--------|----------|------|--------|
EOF

  cat > "${GENERO_AKR_METADATA}/statistics.md" << 'EOF'
# AKR Statistics

**Last Updated:** [Auto-updated]

## Counts
- Total Knowledge Documents: 0
- Files: 0
- Functions: 0
- Modules: 0
- Patterns: 0
- Issues: 0
EOF

  date -u +"%Y-%m-%dT%H:%M:%SZ" > "${GENERO_AKR_METADATA}/last_updated.txt"
  
  if [ $VERBOSE -eq 1 ]; then
    echo -e "${BLUE}[SETUP]${NC} Test environment created at ${TEST_AKR_BASE}"
  fi
}

teardown_test_environment() {
  if [ -n "$TEST_TEMP_DIR" ] && [ -d "$TEST_TEMP_DIR" ]; then
    rm -rf "$TEST_TEMP_DIR"
    if [ $VERBOSE -eq 1 ]; then
      echo -e "${BLUE}[TEARDOWN]${NC} Test environment cleaned up"
    fi
  fi
}

################################################################################
# Test Assertions
################################################################################

assert_equals() {
  local expected=$1
  local actual=$2
  local message=${3:-"Values should be equal"}
  
  if [ "$expected" = "$actual" ]; then
    pass_test "$message"
  else
    fail_test "$message (expected: '$expected', got: '$actual')"
  fi
}

assert_not_equals() {
  local expected=$1
  local actual=$2
  local message=${3:-"Values should not be equal"}
  
  if [ "$expected" != "$actual" ]; then
    pass_test "$message"
  else
    fail_test "$message (both are: '$expected')"
  fi
}

assert_file_exists() {
  local file=$1
  local message=${2:-"File should exist: $file"}
  
  if [ -f "$file" ]; then
    pass_test "$message"
  else
    fail_test "$message"
  fi
}

assert_file_not_exists() {
  local file=$1
  local message=${2:-"File should not exist: $file"}
  
  if [ ! -f "$file" ]; then
    pass_test "$message"
  else
    fail_test "$message"
  fi
}

assert_dir_exists() {
  local dir=$1
  local message=${2:-"Directory should exist: $dir"}
  
  if [ -d "$dir" ]; then
    pass_test "$message"
  else
    fail_test "$message"
  fi
}

assert_exit_code() {
  local expected=$1
  local actual=$2
  local message=${3:-"Exit code should be $expected"}
  
  if [ "$expected" -eq "$actual" ]; then
    pass_test "$message"
  else
    fail_test "$message (expected: $expected, got: $actual)"
  fi
}

assert_contains() {
  local haystack=$1
  local needle=$2
  local message=${3:-"String should contain: $needle"}
  
  if echo "$haystack" | grep -q "$needle"; then
    pass_test "$message"
  else
    fail_test "$message"
  fi
}

assert_not_contains() {
  local haystack=$1
  local needle=$2
  local message=${3:-"String should not contain: $needle"}
  
  if ! echo "$haystack" | grep -q "$needle"; then
    pass_test "$message"
  else
    fail_test "$message"
  fi
}

################################################################################
# Test Result Tracking
################################################################################

pass_test() {
  local message=$1
  ((TESTS_PASSED++))
  ((TESTS_RUN++))
  if [ $VERBOSE -eq 1 ]; then
    echo "[PASS] $message"
  fi
}

fail_test() {
  local message=$1
  ((TESTS_FAILED++))
  ((TESTS_RUN++))
  echo "[FAIL] $message"
}

skip_test() {
  local message=$1
  ((TESTS_SKIPPED++))
  if [ $VERBOSE -eq 1 ]; then
    echo "[SKIP] $message"
  fi
}

################################################################################
# Test Reporting
################################################################################

print_test_summary() {
  local total=$((TESTS_PASSED + TESTS_FAILED))
  local percentage=0
  
  if [ $total -gt 0 ]; then
    percentage=$((TESTS_PASSED * 100 / total))
  fi
  
  echo ""
  echo "================================================================================"
  echo "Test Summary"
  echo "================================================================================"
  echo "Total Tests Run:    $TESTS_RUN"
  echo "Tests Passed:       ${GREEN}$TESTS_PASSED${NC}"
  echo "Tests Failed:       ${RED}$TESTS_FAILED${NC}"
  echo "Tests Skipped:      ${YELLOW}$TESTS_SKIPPED${NC}"
  echo "Success Rate:       ${percentage}%"
  echo "================================================================================"
  
  if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    return 0
  else
    echo -e "${RED}Some tests failed!${NC}"
    return 1
  fi
}

################################################################################
# Helper Functions
################################################################################

create_test_knowledge() {
  local type=$1
  local name=$2
  local content=$3
  
  local file=""
  case "$type" in
    function)
      file="${GENERO_AKR_FUNCTIONS}/${name}.md"
      ;;
    file)
      file="${GENERO_AKR_FILES}/${name}.md"
      ;;
    module)
      file="${GENERO_AKR_MODULES}/${name}.md"
      ;;
    pattern)
      file="${GENERO_AKR_PATTERNS}/${name}.md"
      ;;
    issue)
      file="${GENERO_AKR_ISSUES}/${name}.md"
      ;;
  esac
  
  cat > "$file" << EOF
# $name

**Type:** $type
**Path:** test/$name
**Last Updated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Updated By:** test-framework
**Status:** active

## Summary
Test knowledge document for $name

## Key Findings
- Finding 1
- Finding 2

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| $(date -u +%Y-%m-%d) | test-framework | create | Test document |

$content
EOF
}

run_script_with_args() {
  local script=$1
  shift
  local args=("$@")
  
  bash "$script" "${args[@]}" 2>&1
  return $?
}

################################################################################
# Export functions for use in tests
################################################################################

export -f assert_equals
export -f assert_not_equals
export -f assert_file_exists
export -f assert_file_not_exists
export -f assert_dir_exists
export -f assert_exit_code
export -f assert_contains
export -f assert_not_contains
export -f pass_test
export -f fail_test
export -f skip_test
export -f print_test_summary
export -f create_test_knowledge
export -f run_script_with_args
