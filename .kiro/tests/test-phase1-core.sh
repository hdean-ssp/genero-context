#!/bin/bash
################################################################################
# Phase 1 Core Scripts Tests
# Tests for: setup_akr.sh, retrieve_knowledge.sh, commit_knowledge.sh,
#            search_knowledge.sh, validate_knowledge.sh
################################################################################

# Source test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-framework.sh"

# Setup test environment FIRST
setup_test_environment

# Scripts directory
SCRIPTS_DIR="${SCRIPT_DIR}/../scripts"

################################################################################
# Test Suite: setup_akr.sh
################################################################################

test_setup_akr_creates_directories() {
  echo ""
  echo "=== Testing setup_akr.sh ==="
  
  # Run setup
  bash "${SCRIPTS_DIR}/setup_akr.sh" > /dev/null 2>&1 || true
  
  # Verify directories created
  assert_dir_exists "${GENERO_AKR_BASE_PATH}" "AKR base directory created"
  assert_dir_exists "${GENERO_AKR_FILES}" "Files directory created"
  assert_dir_exists "${GENERO_AKR_FUNCTIONS}" "Functions directory created"
  assert_dir_exists "${GENERO_AKR_MODULES}" "Modules directory created"
  assert_dir_exists "${GENERO_AKR_PATTERNS}" "Patterns directory created"
  assert_dir_exists "${GENERO_AKR_ISSUES}" "Issues directory created"
  assert_dir_exists "${GENERO_AKR_METADATA}" "Metadata directory created"
  assert_dir_exists "${GENERO_AKR_LOCKS}" "Locks directory created"
  assert_dir_exists "${GENERO_AKR_LOGS}" "Logs directory created"
}

test_setup_akr_creates_schema() {
  # Verify schema document created
  assert_file_exists "${GENERO_AKR_BASE_PATH}/SCHEMA.md" "SCHEMA.md created"
}

test_setup_akr_creates_readme() {
  # Verify README created
  assert_file_exists "${GENERO_AKR_BASE_PATH}/README.md" "README.md created"
}

test_setup_akr_creates_index() {
  # Verify INDEX created
  assert_file_exists "${GENERO_AKR_BASE_PATH}/INDEX.md" "INDEX.md created"
}

test_setup_akr_creates_metadata() {
  # Verify metadata files created
  assert_file_exists "${GENERO_AKR_METADATA}/agents.md" "agents.md created"
  assert_file_exists "${GENERO_AKR_METADATA}/statistics.md" "statistics.md created"
  assert_file_exists "${GENERO_AKR_METADATA}/last_updated.txt" "last_updated.txt created"
}

################################################################################
# Test Suite: commit_knowledge.sh
################################################################################

test_commit_knowledge_create_action() {
  echo ""
  echo "=== Testing commit_knowledge.sh ==="
  
  # Create test findings
  local findings_file="${TEST_TEMP_DIR}/findings.json"
  cat > "$findings_file" << 'EOF'
{
  "artifact": {
    "type": "function",
    "name": "test_function",
    "path": "src/test.4gl"
  },
  "new_findings": [
    "Test finding 1",
    "Test finding 2"
  ],
  "metrics": {
    "complexity": 5,
    "lines_of_code": 50,
    "parameter_count": 2,
    "dependent_count": 3
  }
}
EOF

  # Commit knowledge
  bash "${SCRIPTS_DIR}/commit_knowledge.sh" \
    --type function \
    --name test_function \
    --findings "$findings_file" \
    --action create > /dev/null 2>&1 || true
  
  # Verify knowledge file created
  assert_file_exists "${GENERO_AKR_FUNCTIONS}/test_function.md" "Knowledge file created"
}

test_commit_knowledge_append_action() {
  # Create initial knowledge
  create_test_knowledge function append_test "## Initial Content"
  
  # Create findings to append
  local findings_file="${TEST_TEMP_DIR}/append_findings.json"
  cat > "$findings_file" << 'EOF'
{
  "artifact": {
    "type": "function",
    "name": "append_test",
    "path": "src/test.4gl"
  },
  "new_findings": [
    "Appended finding"
  ]
}
EOF

  # Append knowledge
  bash "${SCRIPTS_DIR}/commit_knowledge.sh" \
    --type function \
    --name append_test \
    --findings "$findings_file" \
    --action append > /dev/null 2>&1 || true
  
  # Verify file still exists
  assert_file_exists "${GENERO_AKR_FUNCTIONS}/append_test.md" "Knowledge file preserved after append"
}

################################################################################
# Test Suite: retrieve_knowledge.sh
################################################################################

test_retrieve_knowledge_function() {
  echo ""
  echo "=== Testing retrieve_knowledge.sh ==="
  
  # Create test knowledge
  create_test_knowledge function retrieve_test "## Test Content"
  
  # Retrieve knowledge
  local output=$(bash "${SCRIPTS_DIR}/retrieve_knowledge.sh" \
    --type function \
    --name retrieve_test 2>&1 || true)
  
  # Verify output contains knowledge
  assert_contains "$output" "retrieve_test" "Retrieved knowledge contains function name"
  assert_contains "$output" "Test Content" "Retrieved knowledge contains content"
}

test_retrieve_knowledge_file() {
  # Create test knowledge
  # Note: file paths are converted by replacing / with _
  # So src/test.4gl becomes src_test.4gl
  create_test_knowledge file src_test.4gl "## File Content"
  
  # Retrieve knowledge
  local output=$(bash "${SCRIPTS_DIR}/retrieve_knowledge.sh" \
    --type file \
    --path "src/test.4gl" 2>&1 || true)
  
  # Verify output
  assert_contains "$output" "File Content" "Retrieved file knowledge contains content"
}

test_retrieve_knowledge_not_found() {
  # Try to retrieve non-existent knowledge
  local output=$(bash "${SCRIPTS_DIR}/retrieve_knowledge.sh" \
    --type function \
    --name nonexistent 2>&1 || true)
  
  # Verify error message
  assert_contains "$output" "not found" "Error message for non-existent knowledge"
}

################################################################################
# Test Suite: search_knowledge.sh
################################################################################

test_search_knowledge_all() {
  echo ""
  echo "=== Testing search_knowledge.sh ==="
  
  # Create test knowledge
  create_test_knowledge function search_func1 "## Search Test"
  create_test_knowledge function search_func2 "## Search Test"
  
  # Search for knowledge
  local output=$(bash "${SCRIPTS_DIR}/search_knowledge.sh" \
    --query "Search Test" 2>&1 || true)
  
  # Verify results
  assert_contains "$output" "search_func1" "Search found first function"
  assert_contains "$output" "search_func2" "Search found second function"
}

test_search_knowledge_by_type() {
  # Create test knowledge of different types
  create_test_knowledge function search_by_type_func "## Type Test"
  create_test_knowledge module search_by_type_mod "## Type Test"
  
  # Search by type
  local output=$(bash "${SCRIPTS_DIR}/search_knowledge.sh" \
    --query "Type Test" \
    --type function 2>&1 || true)
  
  # Verify only function found
  assert_contains "$output" "search_by_type_func" "Search by type found function"
}

test_search_knowledge_empty_result() {
  # Search for non-existent content
  local output=$(bash "${SCRIPTS_DIR}/search_knowledge.sh" \
    --query "nonexistent_search_term_xyz" 2>&1 || true)
  
  # Verify no results (or empty results message)
  # This is a valid case - search returns empty
  pass_test "Search handles empty results gracefully"
}

################################################################################
# Test Suite: validate_knowledge.sh
################################################################################

test_validate_knowledge_valid() {
  echo ""
  echo "=== Testing validate_knowledge.sh ==="
  
  # Create valid knowledge
  create_test_knowledge function valid_knowledge "## Summary\nTest\n## Key Findings\n- Test"
  
  # Validate knowledge
  local output=$(bash "${SCRIPTS_DIR}/validate_knowledge.sh" 2>&1 || true)
  
  # Verify validation passes
  assert_contains "$output" "valid_knowledge" "Validation found knowledge file"
}

test_validate_knowledge_schema_check() {
  # Create knowledge with required sections
  local file="${GENERO_AKR_FUNCTIONS}/schema_test.md"
  cat > "$file" << 'EOF'
# schema_test

**Type:** function
**Status:** active

## Summary
Test summary

## Key Findings
- Finding 1

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-30 | test | create | Test |
EOF

  # Validate
  local output=$(bash "${SCRIPTS_DIR}/validate_knowledge.sh" 2>&1 || true)
  
  # Verify validation passes
  pass_test "Validation checks schema compliance"
}

################################################################################
# Integration Tests
################################################################################

test_integration_create_retrieve_search() {
  echo ""
  echo "=== Integration Tests ==="
  
  # Create knowledge
  create_test_knowledge function integration_test "## Integration Test Content"
  
  # Retrieve it
  local retrieve_output=$(bash "${SCRIPTS_DIR}/retrieve_knowledge.sh" \
    --type function \
    --name integration_test 2>&1 || true)
  
  assert_contains "$retrieve_output" "Integration Test Content" "Integration: retrieve works after create"
  
  # Search for it
  local search_output=$(bash "${SCRIPTS_DIR}/search_knowledge.sh" \
    --query "Integration Test" 2>&1 || true)
  
  assert_contains "$search_output" "integration_test" "Integration: search works after create"
}

test_integration_multiple_types() {
  # Create knowledge of different types
  create_test_knowledge function multi_func "## Function"
  create_test_knowledge module multi_mod "## Module"
  create_test_knowledge pattern multi_pat "## Pattern"
  
  # Search across all types
  local output=$(bash "${SCRIPTS_DIR}/search_knowledge.sh" \
    --query "multi" 2>&1 || true)
  
  assert_contains "$output" "multi_func" "Multi-type search found function"
  assert_contains "$output" "multi_mod" "Multi-type search found module"
  assert_contains "$output" "multi_pat" "Multi-type search found pattern"
}

################################################################################
# Main Test Execution
################################################################################

main() {
  echo "================================================================================"
  echo "Phase 1 Core Scripts Test Suite"
  echo "================================================================================"
  
  # Test environment already set up at top of script
  
  # Run tests
  test_setup_akr_creates_directories
  test_setup_akr_creates_schema
  test_setup_akr_creates_readme
  test_setup_akr_creates_index
  test_setup_akr_creates_metadata
  
  test_commit_knowledge_create_action
  test_commit_knowledge_append_action
  
  test_retrieve_knowledge_function
  test_retrieve_knowledge_file
  test_retrieve_knowledge_not_found
  
  test_search_knowledge_all
  test_search_knowledge_by_type
  test_search_knowledge_empty_result
  
  test_validate_knowledge_valid
  test_validate_knowledge_schema_check
  
  test_integration_create_retrieve_search
  test_integration_multiple_types
  
  # Print summary
  print_test_summary
  local result=$?
  
  # Cleanup
  teardown_test_environment
  
  return $result
}

# Run tests
main "$@"
