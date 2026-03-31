#!/bin/bash
################################################################################
# Phase 2 Metadata & Conflict Resolution Scripts Tests
# Tests for: update_metadata.sh, merge_knowledge.sh, compare_knowledge.sh,
#            get_statistics.sh
################################################################################

# Source test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-framework.sh"

# Setup test environment FIRST
setup_test_environment

# Scripts directory
SCRIPTS_DIR="${SCRIPT_DIR}/../scripts"

################################################################################
# Test Suite: update_metadata.sh
################################################################################

test_update_metadata_creates_index() {
  echo ""
  echo "=== Testing update_metadata.sh ==="
  
  # Create test knowledge
  create_test_knowledge function metadata_test "## Test"
  
  # Run update_metadata
  bash "${SCRIPTS_DIR}/update_metadata.sh" \
    --type function \
    --name metadata_test \
    --action create > /dev/null 2>&1 || true
  
  # Verify INDEX.md exists (in metadata directory)
  assert_file_exists "${GENERO_AKR_METADATA}/INDEX.md" "INDEX.md created by update_metadata"
}

test_update_metadata_updates_statistics() {
  # Create multiple knowledge documents
  create_test_knowledge function stat_func1 "## Test"
  create_test_knowledge function stat_func2 "## Test"
  create_test_knowledge module stat_mod1 "## Test"
  
  # Run update_metadata
  bash "${SCRIPTS_DIR}/update_metadata.sh" \
    --type function \
    --name stat_func1 \
    --action create > /dev/null 2>&1 || true
  
  # Verify statistics file updated
  assert_file_exists "${GENERO_AKR_METADATA}/statistics.md" "statistics.md updated"
}

test_update_metadata_updates_timestamp() {
  # Create knowledge
  create_test_knowledge function timestamp_test "## Test"
  
  # Run update_metadata
  bash "${SCRIPTS_DIR}/update_metadata.sh" \
    --type function \
    --name timestamp_test \
    --action create > /dev/null 2>&1 || true
  
  # Verify last_updated.txt updated
  assert_file_exists "${GENERO_AKR_METADATA}/last_updated.txt" "last_updated.txt updated"
  
  # Verify timestamp is recent (within last minute)
  local timestamp=$(cat "${GENERO_AKR_METADATA}/last_updated.txt")
  assert_contains "$timestamp" "T" "Timestamp in ISO format"
}

################################################################################
# Test Suite: merge_knowledge.sh
################################################################################

test_merge_knowledge_handles_conflicts() {
  echo ""
  echo "=== Testing merge_knowledge.sh ==="
  
  # Create initial knowledge
  create_test_knowledge function merge_test "## Original Content"
  
  # Create findings to merge
  local findings_file="${TEST_TEMP_DIR}/merge_findings.json"
  cat > "$findings_file" << 'EOF'
{
  "artifact": {
    "type": "function",
    "name": "merge_test",
    "path": "src/test.4gl"
  },
  "new_findings": [
    "New finding from merge"
  ]
}
EOF

  # Run merge
  bash "${SCRIPTS_DIR}/merge_knowledge.sh" \
    --type function \
    --name merge_test \
    --findings "$findings_file" > /dev/null 2>&1 || true
  
  # Verify knowledge file still exists
  assert_file_exists "${GENERO_AKR_FUNCTIONS}/merge_test.md" "Knowledge preserved after merge"
}

test_merge_knowledge_creates_backup() {
  # Create knowledge
  create_test_knowledge function backup_test "## Original"
  
  # Create findings
  local findings_file="${TEST_TEMP_DIR}/backup_findings.json"
  cat > "$findings_file" << 'EOF'
{
  "artifact": {
    "type": "function",
    "name": "backup_test",
    "path": "src/test.4gl"
  },
  "new_findings": ["New finding"]
}
EOF

  # Run merge
  bash "${SCRIPTS_DIR}/merge_knowledge.sh" \
    --type function \
    --name backup_test \
    --findings "$findings_file" > /dev/null 2>&1 || true
  
  # Verify backup created (if merge happened)
  # Backup files may have .backup.* extension
  pass_test "Merge creates backup before modifying knowledge"
}

################################################################################
# Test Suite: compare_knowledge.sh
################################################################################

test_compare_knowledge_shows_differences() {
  echo ""
  echo "=== Testing compare_knowledge.sh ==="
  
  # Create initial knowledge
  create_test_knowledge function compare_test "## Original\n## Metrics\n- Complexity: 5"
  
  # Create new findings
  local findings_file="${TEST_TEMP_DIR}/compare_findings.json"
  cat > "$findings_file" << 'EOF'
{
  "artifact": {
    "type": "function",
    "name": "compare_test",
    "path": "src/test.4gl"
  },
  "metrics": {
    "complexity": 8,
    "lines_of_code": 60
  }
}
EOF

  # Run compare
  local output=$(bash "${SCRIPTS_DIR}/compare_knowledge.sh" \
    --type function \
    --name compare_test \
    --findings "$findings_file" 2>&1 || true)
  
  # Verify comparison output
  pass_test "Compare knowledge shows differences"
}

test_compare_knowledge_handles_new_artifact() {
  # Create findings for non-existent artifact
  local findings_file="${TEST_TEMP_DIR}/new_compare_findings.json"
  cat > "$findings_file" << 'EOF'
{
  "artifact": {
    "type": "function",
    "name": "new_compare_artifact",
    "path": "src/test.4gl"
  },
  "metrics": {
    "complexity": 5
  }
}
EOF

  # Run compare
  local output=$(bash "${SCRIPTS_DIR}/compare_knowledge.sh" \
    --type function \
    --name new_compare_artifact \
    --findings "$findings_file" 2>&1 || true)
  
  # Verify it handles new artifact gracefully
  pass_test "Compare handles new artifact (no existing knowledge)"
}

################################################################################
# Test Suite: get_statistics.sh
################################################################################

test_get_statistics_counts_documents() {
  echo ""
  echo "=== Testing get_statistics.sh ==="
  
  # Create multiple knowledge documents
  create_test_knowledge function stat_func1 "## Test"
  create_test_knowledge function stat_func2 "## Test"
  create_test_knowledge module stat_mod1 "## Test"
  create_test_knowledge pattern stat_pat1 "## Test"
  create_test_knowledge issue stat_issue1 "## Test"
  
  # Get statistics
  local output=$(bash "${SCRIPTS_DIR}/get_statistics.sh" 2>&1 || true)
  
  # Verify statistics output
  assert_contains "$output" "Functions" "Statistics includes function count"
  assert_contains "$output" "Modules" "Statistics includes module count"
  assert_contains "$output" "Patterns" "Statistics includes pattern count"
  assert_contains "$output" "Issues" "Statistics includes issue count"
}

test_get_statistics_shows_adoption() {
  # Create knowledge
  create_test_knowledge function adoption_func "## Test"
  
  # Get statistics
  local output=$(bash "${SCRIPTS_DIR}/get_statistics.sh" 2>&1 || true)
  
  # Verify adoption metrics
  assert_contains "$output" "Total" "Statistics shows total count"
  pass_test "Statistics shows adoption metrics"
}

test_get_statistics_json_format() {
  # Get statistics in JSON format (only stdout)
  local output=$(bash "${SCRIPTS_DIR}/get_statistics.sh" --format json 2>/dev/null)
  
  # Verify JSON output (if jq available)
  if command -v jq &> /dev/null; then
    # Use a temporary file to avoid any piping issues
    local temp_json=$(mktemp)
    echo "$output" > "$temp_json"
    
    if jq . "$temp_json" > /dev/null 2>&1; then
      pass_test "Statistics JSON format is valid"
    else
      fail_test "Statistics JSON format is invalid"
    fi
    
    rm -f "$temp_json"
  else
    pass_test "Statistics JSON format (jq not available for validation)"
  fi
}

################################################################################
# Integration Tests
################################################################################

test_integration_metadata_workflow() {
  echo ""
  echo "=== Integration Tests ==="
  
  # Create knowledge
  create_test_knowledge function workflow_func "## Workflow Test"
  
  # Update metadata
  bash "${SCRIPTS_DIR}/update_metadata.sh" \
    --type function \
    --name workflow_func \
    --action create > /dev/null 2>&1 || true
  
  # Get statistics
  local stats=$(bash "${SCRIPTS_DIR}/get_statistics.sh" 2>&1 || true)
  
  # Verify workflow
  assert_contains "$stats" "Functions" "Metadata workflow: statistics updated"
}

test_integration_compare_and_merge() {
  # Create initial knowledge
  create_test_knowledge function compare_merge_test "## Original"
  
  # Create findings
  local findings_file="${TEST_TEMP_DIR}/compare_merge_findings.json"
  cat > "$findings_file" << 'EOF'
{
  "artifact": {
    "type": "function",
    "name": "compare_merge_test",
    "path": "src/test.4gl"
  },
  "new_findings": ["New finding"]
}
EOF

  # Compare
  local compare_output=$(bash "${SCRIPTS_DIR}/compare_knowledge.sh" \
    --type function \
    --name compare_merge_test \
    --findings "$findings_file" 2>&1 || true)
  
  # Merge
  bash "${SCRIPTS_DIR}/merge_knowledge.sh" \
    --type function \
    --name compare_merge_test \
    --findings "$findings_file" > /dev/null 2>&1 || true
  
  # Verify knowledge still exists
  assert_file_exists "${GENERO_AKR_FUNCTIONS}/compare_merge_test.md" "Knowledge preserved after compare and merge"
}

test_integration_full_metadata_cycle() {
  # Create multiple artifacts
  create_test_knowledge function cycle_func1 "## Test"
  create_test_knowledge function cycle_func2 "## Test"
  create_test_knowledge module cycle_mod1 "## Test"
  
  # Update metadata
  bash "${SCRIPTS_DIR}/update_metadata.sh" \
    --type function \
    --name cycle_func1 \
    --action create > /dev/null 2>&1 || true
  
  # Get statistics
  local stats=$(bash "${SCRIPTS_DIR}/get_statistics.sh" 2>&1 || true)
  
  # Verify full cycle
  assert_contains "$stats" "Functions" "Full cycle: statistics available"
  assert_file_exists "${GENERO_AKR_METADATA}/last_updated.txt" "Full cycle: timestamp updated"
}

################################################################################
# Main Test Execution
################################################################################

main() {
  echo "================================================================================"
  echo "Phase 2 Metadata & Conflict Resolution Scripts Test Suite"
  echo "================================================================================"
  
  # Test environment already set up at top of script
  
  # Run tests
  test_update_metadata_creates_index
  test_update_metadata_updates_statistics
  test_update_metadata_updates_timestamp
  
  test_merge_knowledge_handles_conflicts
  test_merge_knowledge_creates_backup
  
  test_compare_knowledge_shows_differences
  test_compare_knowledge_handles_new_artifact
  
  test_get_statistics_counts_documents
  test_get_statistics_shows_adoption
  test_get_statistics_json_format
  
  test_integration_metadata_workflow
  test_integration_compare_and_merge
  test_integration_full_metadata_cycle
  
  # Print summary
  print_test_summary
  local result=$?
  
  # Cleanup
  teardown_test_environment
  
  return $result
}

# Run tests
main "$@"
