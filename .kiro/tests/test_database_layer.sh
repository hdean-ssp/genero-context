#!/bin/bash

################################################################################
# test_database_layer.sh - Test Phase 2 database layer implementation
#
# Purpose: Verify database initialization, sync, and query functionality
#
# Usage:
#   bash test_database_layer.sh [--verbose]
#
# Options:
#   --verbose    Show detailed test output
#
################################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")/scripts"
TEST_DB="/tmp/test_akr.db"
VERBOSE=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose)
      VERBOSE=1
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
test_start() {
  local name="$1"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ $VERBOSE -eq 1 ]]; then
    echo -n "[TEST $TESTS_RUN] $name ... "
  fi
}

test_pass() {
  TESTS_PASSED=$((TESTS_PASSED + 1))
  if [[ $VERBOSE -eq 1 ]]; then
    echo -e "${GREEN}PASS${NC}"
  fi
}

test_fail() {
  local reason="$1"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  if [[ $VERBOSE -eq 1 ]]; then
    echo -e "${RED}FAIL${NC}: $reason"
  fi
}

# Clean up test database
cleanup() {
  if [[ -f "$TEST_DB" ]]; then
    rm -f "$TEST_DB"
  fi
}

# Setup
cleanup
trap cleanup EXIT

echo "Testing Phase 2: Database Layer"
echo "================================"
echo ""

# Test 1: Database initialization
test_start "Database initialization"
if GENERO_AKR_DB_PATH="$TEST_DB" bash "$SCRIPTS_DIR/init_akr_db.sh" > /dev/null 2>&1; then
  if [[ -f "$TEST_DB" ]]; then
    test_pass
  else
    test_fail "Database file not created"
  fi
else
  test_fail "init_akr_db.sh failed"
fi

# Test 2: Database schema verification
test_start "Database schema verification"
TABLE_COUNT=$(sqlite3 "$TEST_DB" "SELECT COUNT(*) FROM sqlite_master WHERE type='table';" 2>/dev/null || echo "0")
if [[ "$TABLE_COUNT" -ge 8 ]]; then
  test_pass
else
  test_fail "Expected 8+ tables, got $TABLE_COUNT"
fi

# Test 3: Indexes created
test_start "Indexes created"
INDEX_COUNT=$(sqlite3 "$TEST_DB" "SELECT COUNT(*) FROM sqlite_master WHERE type='index';" 2>/dev/null || echo "0")
if [[ "$INDEX_COUNT" -gt 0 ]]; then
  test_pass
else
  test_fail "No indexes found"
fi

# Test 4: Views created
test_start "Views created"
VIEW_COUNT=$(sqlite3 "$TEST_DB" "SELECT COUNT(*) FROM sqlite_master WHERE type='view';" 2>/dev/null || echo "0")
if [[ "$VIEW_COUNT" -ge 4 ]]; then
  test_pass
else
  test_fail "Expected 4+ views, got $VIEW_COUNT"
fi

# Test 5: Insert artifact
test_start "Insert artifact"
if sqlite3 "$TEST_DB" "INSERT INTO artifacts (name, type, path, status) VALUES ('test_function', 'function', 'src/test.4gl', 'active');" 2>/dev/null; then
  test_pass
else
  test_fail "Failed to insert artifact"
fi

# Test 6: Insert metrics
test_start "Insert metrics"
if sqlite3 "$TEST_DB" "INSERT INTO metrics (artifact_id, complexity, lines_of_code, parameter_count, dependent_count) SELECT id, 5, 20, 2, 3 FROM artifacts WHERE name='test_function';" 2>/dev/null; then
  test_pass
else
  test_fail "Failed to insert metrics"
fi

# Test 7: Query artifact
test_start "Query artifact"
RESULT=$(sqlite3 "$TEST_DB" "SELECT name FROM artifacts WHERE name='test_function';" 2>/dev/null || echo "")
if [[ "$RESULT" == "test_function" ]]; then
  test_pass
else
  test_fail "Artifact not found"
fi

# Test 8: Query metrics
test_start "Query metrics"
COMPLEXITY=$(sqlite3 "$TEST_DB" "SELECT complexity FROM metrics WHERE artifact_id=1;" 2>/dev/null || echo "0")
if [[ "$COMPLEXITY" == "5" ]]; then
  test_pass
else
  test_fail "Metrics not found or incorrect"
fi

# Test 9: High complexity view
test_start "High complexity view"
if sqlite3 "$TEST_DB" "SELECT * FROM high_complexity_functions;" > /dev/null 2>&1; then
  test_pass
else
  test_fail "View query failed"
fi

# Test 10: Audit trail insert
test_start "Audit trail insert"
if sqlite3 "$TEST_DB" "INSERT INTO audit_trail (action, artifact_id, agent_id, details) VALUES ('TEST_ACTION', 1, 'test-agent', 'test details');" 2>/dev/null; then
  test_pass
else
  test_fail "Failed to insert audit trail"
fi

# Test 11: Staleness table
test_start "Staleness table"
if sqlite3 "$TEST_DB" "INSERT INTO staleness (artifact_id, status, days_since_update) VALUES (1, 'FRESH', 0);" 2>/dev/null; then
  test_pass
else
  test_fail "Failed to insert staleness"
fi

# Test 12: Database size
test_start "Database size reasonable"
DB_SIZE=$(du -b "$TEST_DB" | awk '{print $1}')
if [[ $DB_SIZE -lt 1000000 ]]; then  # Less than 1MB for empty database
  test_pass
else
  test_fail "Database size too large: $DB_SIZE bytes"
fi

# Test 13: Force recreate
test_start "Force recreate database"
if GENERO_AKR_DB_PATH="$TEST_DB" bash "$SCRIPTS_DIR/init_akr_db.sh" --force > /dev/null 2>&1; then
  # Verify data was cleared
  ARTIFACT_COUNT=$(sqlite3 "$TEST_DB" "SELECT COUNT(*) FROM artifacts;" 2>/dev/null || echo "1")
  if [[ "$ARTIFACT_COUNT" == "0" ]]; then
    test_pass
  else
    test_fail "Database not cleared on force recreate"
  fi
else
  test_fail "Force recreate failed"
fi

# Test 14: Multiple inserts
test_start "Multiple inserts"
sqlite3 "$TEST_DB" << EOF > /dev/null 2>&1
INSERT INTO artifacts (name, type, path, status) VALUES ('func1', 'function', 'src/f1.4gl', 'active');
INSERT INTO artifacts (name, type, path, status) VALUES ('func2', 'function', 'src/f2.4gl', 'active');
INSERT INTO artifacts (name, type, path, status) VALUES ('mod1', 'module', 'src/m1.4gl', 'active');
EOF
ARTIFACT_COUNT=$(sqlite3 "$TEST_DB" "SELECT COUNT(*) FROM artifacts;" 2>/dev/null || echo "0")
if [[ "$ARTIFACT_COUNT" == "3" ]]; then
  test_pass
else
  test_fail "Expected 3 artifacts, got $ARTIFACT_COUNT"
fi

# Test 15: Query with filter
test_start "Query with filter"
FUNCTION_COUNT=$(sqlite3 "$TEST_DB" "SELECT COUNT(*) FROM artifacts WHERE type='function';" 2>/dev/null || echo "0")
if [[ "$FUNCTION_COUNT" == "2" ]]; then
  test_pass
else
  test_fail "Expected 2 functions, got $FUNCTION_COUNT"
fi

# Summary
echo ""
echo "================================"
echo "Test Results"
echo "================================"
echo "Tests run:    $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
  echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
else
  echo -e "Tests failed: ${GREEN}0${NC}"
fi
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed${NC}"
  exit 1
fi
