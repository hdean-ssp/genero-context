#!/bin/bash
################################################################################
# AKR Comprehensive Test Suite Runner
# Executes all test suites and generates comprehensive report
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="${SCRIPT_DIR}"
RESULTS_DIR="${TESTS_DIR}/results"
REPORT_FILE="${RESULTS_DIR}/TEST_RESULTS.md"

# Test counters
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0

# Test suites
declare -a TEST_SUITES=(
  "test-framework.sh"
  "test-phase1-core.sh"
  "test-phase2-metadata.sh"
)

################################################################################
# Setup
################################################################################

setup_test_environment() {
  # Create results directory
  mkdir -p "${RESULTS_DIR}"
  
  # Create report file
  cat > "${REPORT_FILE}" << 'EOF'
# AKR Comprehensive Test Results

**Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Test Suite**: AKR Framework
**Status**: Running...

---

## Test Execution Summary

EOF

  echo -e "${BLUE}[SETUP]${NC} Test environment initialized"
  echo -e "${BLUE}[SETUP]${NC} Results directory: ${RESULTS_DIR}"
}

################################################################################
# Test Execution
################################################################################

run_test_suite() {
  local suite=$1
  local suite_name=$(basename "$suite" .sh)
  
  echo ""
  echo -e "${BLUE}[TEST SUITE]${NC} Running: $suite_name"
  echo "================================================================================"
  
  # Run test suite and capture output
  local output_file="${RESULTS_DIR}/${suite_name}.log"
  
  bash "${TESTS_DIR}/${suite}" > "${output_file}" 2>&1
  local exit_code=$?
  
  # Extract test counts from the output using grep and awk
  local passed=$(grep "Tests Passed:" "${output_file}" | grep -o '[0-9]\+' | head -1)
  local failed=$(grep "Tests Failed:" "${output_file}" | grep -o '[0-9]\+' | head -1)
  local skipped=$(grep "Tests Skipped:" "${output_file}" | grep -o '[0-9]\+' | head -1)
  
  # Default to 0 if not found
  passed=${passed:-0}
  failed=${failed:-0}
  skipped=${skipped:-0}
  
  # Update totals
  TOTAL_PASSED=$((TOTAL_PASSED + passed))
  TOTAL_FAILED=$((TOTAL_FAILED + failed))
  TOTAL_SKIPPED=$((TOTAL_SKIPPED + skipped))
  TOTAL_TESTS=$((TOTAL_TESTS + passed + failed))
  
  # Display results
  if [ $exit_code -eq 0 ] && [ $failed -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC} $suite_name"
    echo "  Passed: $passed, Failed: $failed, Skipped: $skipped"
  else
    echo -e "${RED}✗ FAIL${NC} $suite_name"
    echo "  Passed: $passed, Failed: $failed, Skipped: $skipped"
    echo "  Exit code: $exit_code"
  fi
  
  # Append to report
  cat >> "${REPORT_FILE}" << EOF

### $suite_name

**Status**: $([ $exit_code -eq 0 ] && [ $failed -eq 0 ] && echo "✅ PASS" || echo "❌ FAIL")
**Passed**: $passed
**Failed**: $failed
**Skipped**: $skipped
**Exit Code**: $exit_code

\`\`\`
$(tail -30 "${output_file}")
\`\`\`

EOF

  return $exit_code
}

################################################################################
# Reporting
################################################################################

generate_final_report() {
  local total=$((TOTAL_PASSED + TOTAL_FAILED))
  local percentage=0
  
  if [ $total -gt 0 ]; then
    percentage=$((TOTAL_PASSED * 100 / total))
  fi
  
  # Print summary to console
  echo ""
  echo "================================================================================"
  echo "Test Execution Complete"
  echo "================================================================================"
  echo "Total Tests Run:    $TOTAL_TESTS"
  echo "Tests Passed:       ${GREEN}$TOTAL_PASSED${NC}"
  echo "Tests Failed:       ${RED}$TOTAL_FAILED${NC}"
  echo "Tests Skipped:      ${YELLOW}$TOTAL_SKIPPED${NC}"
  echo "Success Rate:       ${percentage}%"
  echo "================================================================================"
  
  # Update report file
  cat >> "${REPORT_FILE}" << EOF

---

## Final Summary

| Metric | Value |
|--------|-------|
| Total Tests Run | $TOTAL_TESTS |
| Tests Passed | $TOTAL_PASSED |
| Tests Failed | $TOTAL_FAILED |
| Tests Skipped | $TOTAL_SKIPPED |
| Success Rate | ${percentage}% |

---

## Test Coverage

### Phase 1: Core Scripts
- [x] setup_akr.sh - Directory creation, schema, README, INDEX, metadata
- [x] retrieve_knowledge.sh - Function, file, module, pattern, issue retrieval
- [x] commit_knowledge.sh - Create, append, update, deprecate actions
- [x] search_knowledge.sh - Search all types, filter by type, empty results
- [x] validate_knowledge.sh - Schema validation, required sections

### Phase 2: Metadata & Conflict Resolution
- [x] update_metadata.sh - INDEX creation, statistics update, timestamp
- [x] merge_knowledge.sh - Conflict handling, backup creation
- [x] compare_knowledge.sh - Difference detection, new artifact handling
- [x] get_statistics.sh - Document counting, adoption metrics, JSON format

### Phase 3: Search & Analysis (Pending)
- [ ] build_index.sh
- [ ] search_indexed.sh
- [ ] detect_patterns.sh
- [ ] flag_issues.sh

### Phase 4: Automation & Audit (Pending)
- [ ] auto_retrieve.sh
- [ ] auto_commit.sh
- [ ] audit_trail.sh
- [ ] quality_score.sh

---

## Test Results

**Generated**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Test Framework**: Bash Test Framework
**Status**: $([ $TOTAL_FAILED -eq 0 ] && echo "✅ ALL TESTS PASSED" || echo "❌ SOME TESTS FAILED")

EOF

  if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo "Report saved to: ${REPORT_FILE}"
    return 0
  else
    echo -e "${RED}Some tests failed!${NC}"
    echo "Report saved to: ${REPORT_FILE}"
    return 1
  fi
}

################################################################################
# Main Execution
################################################################################

main() {
  echo "================================================================================"
  echo "AKR Comprehensive Test Suite"
  echo "================================================================================"
  echo "Starting test execution at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  
  # Setup
  setup_test_environment
  
  # Run all test suites
  local failed_suites=0
  for suite in "${TEST_SUITES[@]}"; do
    if [ "$suite" != "test-framework.sh" ]; then  # Skip framework itself
      run_test_suite "$suite" || ((failed_suites++))
    fi
  done
  
  # Generate final report
  generate_final_report
  local result=$?
  
  echo ""
  echo "Test execution completed at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  
  return $result
}

# Run tests
main "$@"
