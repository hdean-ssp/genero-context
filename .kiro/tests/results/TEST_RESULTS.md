# AKR Comprehensive Test Results

**Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Test Suite**: AKR Framework
**Status**: Running...

---

## Test Execution Summary


### test-phase1-core

**Status**: ❌ FAIL
**Passed**: 033
**Failed**: 033
**Skipped**: 033
**Exit Code**: 0

```
================================================================================
Phase 1 Core Scripts Test Suite
================================================================================

=== Testing setup_akr.sh ===

=== Testing commit_knowledge.sh ===

=== Testing retrieve_knowledge.sh ===

=== Testing search_knowledge.sh ===

=== Testing validate_knowledge.sh ===

=== Integration Tests ===

================================================================================
Test Summary
================================================================================
Total Tests Run:    32
Tests Passed:       \033[0;32m32\033[0m
Tests Failed:       \033[0;31m0\033[0m
Tests Skipped:      \033[1;33m0\033[0m
Success Rate:       100%
================================================================================
[0;32mAll tests passed![0m
```


### test-phase2-metadata

**Status**: ❌ FAIL
**Passed**: 033
**Failed**: 033
**Skipped**: 033
**Exit Code**: 0

```
================================================================================
Phase 2 Metadata & Conflict Resolution Scripts Test Suite
================================================================================

=== Testing update_metadata.sh ===

=== Testing merge_knowledge.sh ===

=== Testing compare_knowledge.sh ===

=== Testing get_statistics.sh ===

=== Integration Tests ===

================================================================================
Test Summary
================================================================================
Total Tests Run:    19
Tests Passed:       \033[0;32m19\033[0m
Tests Failed:       \033[0;31m0\033[0m
Tests Skipped:      \033[1;33m0\033[0m
Success Rate:       100%
================================================================================
[0;32mAll tests passed![0m
```


---

## Final Summary

| Metric | Value |
|--------|-------|
| Total Tests Run | 108 |
| Tests Passed | 54 |
| Tests Failed | 54 |
| Tests Skipped | 54 |
| Success Rate | 50% |

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

**Generated**: 2026-03-31T08:22:13Z
**Test Framework**: Bash Test Framework
**Status**: ❌ SOME TESTS FAILED

