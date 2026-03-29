# Command-Line Testing Guide

A comprehensive guide for new users to test all command-line functionality of genero-tools. This document provides a sequential list of commands to execute, with variations and expected behaviors.

## Prerequisites

Before running any commands, ensure:
1. You have a Genero codebase with `.4gl` and/or `.m3` files
2. Python 3.6+ is installed
3. You're in the project root directory

For testing purposes, use the sample codebase:
```bash
cd tests/sample_codebase
```

## Phase 1: Generation Commands

These commands extract metadata from your codebase.

### 1.1 Generate All Metadata (Recommended)

**Command:**
```bash
bash generate_all.sh tests/sample_codebase
```

**Expected Output:**
- `workspace.json` - Function signatures
- `workspace.db` - SQLite database for fast queries
- `modules.json` - Module dependencies (if .m3 files exist)
- `modules.db` - SQLite module database (if .m3 files exist)

**Variations:**
```bash
# With verbose output
VERBOSE=1 bash generate_all.sh tests/sample_codebase

# With explicit schema file
bash generate_all.sh tests/sample_codebase tests/sample_codebase/schema.sch

# With custom output directory
cd /tmp && bash /path/to/generate_all.sh /path/to/codebase
```

### 1.2 Generate Function Signatures Only

**Command:**
```bash
bash src/generate_signatures.sh tests/sample_codebase
```

**Expected Output:**
- `workspace.json` containing function signatures

**Variations:**
```bash
# Generate from a single file
bash src/generate_signatures.sh tests/sample_codebase/simple_functions.4gl

# Generate from specific directory
bash src/generate_signatures.sh tests/sample_codebase/lib

# With verbose output
VERBOSE=1 bash src/generate_signatures.sh tests/sample_codebase
```

### 1.3 Generate Module Dependencies

**Command:**
```bash
bash src/generate_modules.sh tests/sample_codebase
```

**Expected Output:**
- `modules.json` containing module dependency information

**Variations:**
```bash
# Generate from modules directory only
bash src/generate_modules.sh tests/sample_codebase/modules

# With verbose output
VERBOSE=1 bash src/generate_modules.sh tests/sample_codebase
```

### 1.4 Create SQLite Databases

**Command:**
```bash
bash query.sh create-dbs
```

**Expected Output:**
- `workspace.db` - Indexed function signatures
- `modules.db` - Indexed module dependencies

**Variations:**
```bash
# Create only signatures database
bash query.sh create-signatures-db

# Create only modules database
bash query.sh create-modules-db

# With custom database location
SIGNATURES_DB=/tmp/custom.db bash query.sh create-signatures-db
```

---

## Phase 2: Function Query Commands

These commands search and retrieve function information.

### 2.1 Find Function by Exact Name

**Command:**
```bash
bash query.sh find-function "calculate_total"
```

**Expected Output:**
```json
{
  "name": "calculate_total",
  "file_path": "tests/sample_codebase/simple_functions.4gl",
  "line_number": 5,
  "parameters": [...],
  "returns": [...],
  "calls": [...]
}
```

**Variations:**
```bash
# Find different functions
bash query.sh find-function "get_value"
bash query.sh find-function "process_data"

# Non-existent function (should return empty or error)
bash query.sh find-function "nonexistent_function"
```

### 2.2 Search Functions by Pattern

**Command:**
```bash
bash query.sh search-functions "get_*"
```

**Expected Output:**
Array of all functions matching the pattern.

**Variations:**
```bash
# Different patterns
bash query.sh search-functions "process_*"
bash query.sh search-functions "*_total"
bash query.sh search-functions "*"

# Case sensitivity
bash query.sh search-functions "GET_*"
bash query.sh search-functions "Calculate*"
```

### 2.3 List Functions in a File

**Command:**
```bash
bash query.sh list-file-functions "tests/sample_codebase/simple_functions.4gl"
```

**Expected Output:**
Array of all functions in the specified file.

**Variations:**
```bash
# Different files
bash query.sh list-file-functions "tests/sample_codebase/complex_types.4gl"
bash query.sh list-file-functions "tests/sample_codebase/lib/complex_types.4gl"

# Non-existent file
bash query.sh list-file-functions "nonexistent.4gl"
```

### 2.4 Find Function by Name and Path

**Command:**
```bash
bash query.sh find-function-by-name-and-path "calculate_total" "tests/sample_codebase/simple_functions.4gl"
```

**Expected Output:**
Specific function instance from the given file.

**Variations:**
```bash
# Different function and file combinations
bash query.sh find-function-by-name-and-path "process_data" "tests/sample_codebase/complex_types.4gl"

# With relative paths
bash query.sh find-function-by-name-and-path "calculate_total" "./simple_functions.4gl"
```

### 2.5 Find All Function Instances

**Command:**
```bash
bash query.sh find-all-function-instances "calculate_total"
```

**Expected Output:**
Array of all instances of the function across different files.

**Variations:**
```bash
# Functions that appear in multiple files
bash query.sh find-all-function-instances "process_data"

# Functions with single instance
bash query.sh find-all-function-instances "get_value"
```

---

## Phase 3: Dependency Query Commands

These commands analyze function call relationships.

### 3.1 Find Function Dependencies (Callees)

**Command:**
```bash
bash query.sh find-function-dependencies "calculate_total"
```

**Expected Output:**
List of functions that `calculate_total` calls.

**Variations:**
```bash
# Different functions
bash query.sh find-function-dependencies "process_data"
bash query.sh find-function-dependencies "get_value"

# Function with no dependencies
bash query.sh find-function-dependencies "simple_function"
```

### 3.2 Find Function Dependents (Callers)

**Command:**
```bash
bash query.sh find-function-dependents "calculate_total"
```

**Expected Output:**
List of functions that call `calculate_total`.

**Variations:**
```bash
# Different functions
bash query.sh find-function-dependents "process_data"
bash query.sh find-function-dependents "get_value"

# Function with no dependents
bash query.sh find-function-dependents "unused_function"
```

### 3.3 Find Dead Code

**Command:**
```bash
bash query.sh find-dead-code
```

**Expected Output:**
List of functions that are never called by any other function.

**Variations:**
```bash
# Run multiple times to verify consistency
bash query.sh find-dead-code
bash query.sh find-dead-code
```

---

## Phase 4: Module Query Commands

These commands work with module dependencies.

### 4.1 Find Module by Name

**Command:**
```bash
bash query.sh find-module "core"
```

**Expected Output:**
Module information including files and dependencies.

**Variations:**
```bash
# Different modules
bash query.sh find-module "utils"
bash query.sh find-module "test"

# Non-existent module
bash query.sh find-module "nonexistent"
```

### 4.2 Search Modules by Pattern

**Command:**
```bash
bash query.sh search-modules "core*"
```

**Expected Output:**
Array of modules matching the pattern.

**Variations:**
```bash
# Different patterns
bash query.sh search-modules "*"
bash query.sh search-modules "test*"
bash query.sh search-modules "*utils"
```

### 4.3 List Modules in a File

**Command:**
```bash
bash query.sh list-file-modules "test.m3"
```

**Expected Output:**
Modules defined in the specified file.

**Variations:**
```bash
# Different files
bash query.sh list-file-modules "multiline.m3"
bash query.sh list-file-modules "modules/test.m3"
```

### 4.4 Find Functions in Module

**Command:**
```bash
bash query.sh find-functions-in-module "core"
```

**Expected Output:**
All functions belonging to the specified module.

**Variations:**
```bash
# Different modules
bash query.sh find-functions-in-module "utils"
bash query.sh find-functions-in-module "test"
```

### 4.5 Find Module for Function

**Command:**
```bash
bash query.sh find-module-for-function "calculate_total"
```

**Expected Output:**
Module(s) containing the specified function.

**Variations:**
```bash
# Different functions
bash query.sh find-module-for-function "process_data"
bash query.sh find-module-for-function "get_value"
```

### 4.6 Find Functions Calling in Module

**Command:**
```bash
bash query.sh find-functions-calling-in-module "core" "calculate_total"
```

**Expected Output:**
Functions in the "core" module that call `calculate_total`.

**Variations:**
```bash
# Different module and function combinations
bash query.sh find-functions-calling-in-module "utils" "process_data"
bash query.sh find-functions-calling-in-module "test" "get_value"
```

### 4.7 Find Module Dependencies

**Command:**
```bash
bash query.sh find-module-dependencies "core"
```

**Expected Output:**
Modules that the "core" module depends on.

**Variations:**
```bash
# Different modules
bash query.sh find-module-dependencies "utils"
bash query.sh find-module-dependencies "test"
```

---

## Phase 5: Header and Reference Query Commands

These commands search code references and author information.

### 5.1 Find Reference

**Command:**
```bash
bash query.sh find-reference "PRB-299"
```

**Expected Output:**
Files containing the code reference "PRB-299".

**Variations:**
```bash
# Different references
bash query.sh find-reference "EH100512"
bash query.sh find-reference "BUG-123"

# Non-existent reference
bash query.sh find-reference "NONEXISTENT-999"
```

### 5.2 Search References by Pattern

**Command:**
```bash
bash query.sh search-references "100512"
```

**Expected Output:**
References matching the pattern (with automatic wildcard expansion).

**Variations:**
```bash
# Partial numeric search
bash query.sh search-references "100512"
bash query.sh search-references "299"

# Prefix search
bash query.sh search-references "EH"
bash query.sh search-references "PRB"

# Explicit wildcard
bash query.sh search-references "EH100512%"
```

### 5.3 Search Reference by Prefix

**Command:**
```bash
bash query.sh search-reference-prefix "EH100512"
```

**Expected Output:**
References starting with "EH100512" (e.g., "EH100512-9a").

**Variations:**
```bash
# Different prefixes
bash query.sh search-reference-prefix "PRB"
bash query.sh search-reference-prefix "BUG-1"
```

### 5.4 Find Author

**Command:**
```bash
bash query.sh find-author "Rich"
```

**Expected Output:**
Files modified by the author "Rich".

**Variations:**
```bash
# Different authors
bash query.sh find-author "Chilly"
bash query.sh find-author "John"

# Partial name match
bash query.sh find-author "R"
```

### 5.5 Get File References

**Command:**
```bash
bash query.sh file-references "tests/sample_codebase/simple_functions.4gl"
```

**Expected Output:**
All code references in the specified file.

**Variations:**
```bash
# Different files
bash query.sh file-references "tests/sample_codebase/complex_types.4gl"
bash query.sh file-references "./simple_functions.4gl"
```

### 5.6 Get File Authors

**Command:**
```bash
bash query.sh file-authors "tests/sample_codebase/simple_functions.4gl"
```

**Expected Output:**
All authors who modified the specified file.

**Variations:**
```bash
# Different files
bash query.sh file-authors "tests/sample_codebase/complex_types.4gl"
bash query.sh file-authors "./simple_functions.4gl"
```

### 5.7 Author Expertise

**Command:**
```bash
bash query.sh author-expertise "Rich"
```

**Expected Output:**
Areas of expertise for the author based on their modifications.

**Variations:**
```bash
# Different authors
bash query.sh author-expertise "Chilly"
bash query.sh author-expertise "John"
```

### 5.8 Recent Changes

**Command:**
```bash
bash query.sh recent-changes 30
```

**Expected Output:**
Files modified in the last 30 days.

**Variations:**
```bash
# Different time ranges
bash query.sh recent-changes 7
bash query.sh recent-changes 1
bash query.sh recent-changes 365

# Default (30 days)
bash query.sh recent-changes
```

---

## Phase 6: Type Resolution Query Commands

These commands work with resolved LIKE type references.

### 6.1 Find Function with Resolved Types

**Command:**
```bash
bash query.sh find-function-resolved "process_contract"
```

**Expected Output:**
Function with LIKE type references resolved to actual schema types.

**Variations:**
```bash
# Different functions
bash query.sh find-function-resolved "calculate_total"
bash query.sh find-function-resolved "process_data"

# Function without LIKE references
bash query.sh find-function-resolved "simple_function"
```

### 6.2 Find Unresolved Types

**Command:**
```bash
bash query.sh unresolved-types
```

**Expected Output:**
Table of all unresolved LIKE type references with error details.

**Variations:**
```bash
# Filter by error type
bash query.sh unresolved-types --filter missing_table
bash query.sh unresolved-types --filter missing_column
bash query.sh unresolved-types --filter invalid_pattern

# Pagination
bash query.sh unresolved-types --limit 10
bash query.sh unresolved-types --limit 10 --offset 5
bash query.sh unresolved-types --limit 20 --offset 0

# Combined filters and pagination
bash query.sh unresolved-types --filter missing_table --limit 5
```

### 6.3 Validate Types

**Command:**
```bash
bash query.sh validate-types
```

**Expected Output:**
Validation report with data consistency checks.

**Variations:**
```bash
# Run multiple times to verify consistency
bash query.sh validate-types
bash query.sh validate-types
```

---

## Phase 7: Batch Query Commands

These commands execute multiple queries in a single operation.

### 7.1 Batch Query from JSON File

**Command:**
```bash
bash query.sh batch-query queries.json
```

**Expected Output:**
Results from all queries in the JSON file.

**Variations:**
```bash
# With output file
bash query.sh batch-query queries.json --output results.json

# Alternative syntax
bash query.sh batch-query --input queries.json --output results.json

# Without output file (prints to stdout)
bash query.sh batch-query queries.json
```

**Sample queries.json:**
```json
{
  "queries": [
    {
      "command": "find-function",
      "args": ["calculate_total"]
    },
    {
      "command": "search-functions",
      "args": ["get_*"]
    },
    {
      "command": "find-function-dependencies",
      "args": ["calculate_total"]
    }
  ]
}
```

---

## Phase 8: Output Format Commands (Vim Plugin Integration)

These commands demonstrate output formatting for editor integration.

### 8.1 Vim Format (Concise Single-Line)

**Command:**
```bash
bash query.sh find-function "calculate_total" --format=vim
```

**Expected Output:**
Single-line function signature suitable for Vim display.

**Variations:**
```bash
# Search with vim format
bash query.sh search-functions "get_*" --format=vim

# With filter
bash query.sh search-functions "*" --format=vim --filter=functions-only
```

### 8.2 Vim Hover Format (Multi-Line)

**Command:**
```bash
bash query.sh find-function "calculate_total" --format=vim-hover
```

**Expected Output:**
Multi-line format with file location and metrics for hover tooltips.

**Variations:**
```bash
# Search with hover format
bash query.sh search-functions "get_*" --format=vim-hover

# Without metrics
bash query.sh search-functions "get_*" --format=vim-hover --filter=no-metrics
```

### 8.3 Vim Completion Format (Tab-Separated)

**Command:**
```bash
bash query.sh search-functions "*" --format=vim-completion
```

**Expected Output:**
Tab-separated format optimized for Vim/Neovim completion.

**Variations:**
```bash
# With filter
bash query.sh search-functions "get_*" --format=vim-completion --filter=functions-only

# Without file info
bash query.sh search-functions "*" --format=vim-completion --filter=no-file-info
```

---

## Phase 9: Filter Options

These commands demonstrate output filtering.

### 9.1 Functions Only Filter

**Command:**
```bash
bash query.sh search-functions "*" --filter=functions-only
```

**Expected Output:**
Only functions with return types (excludes procedures).

**Variations:**
```bash
# With different formats
bash query.sh search-functions "get_*" --format=vim --filter=functions-only
bash query.sh search-functions "*" --format=vim-hover --filter=functions-only
```

### 9.2 No Metrics Filter

**Command:**
```bash
bash query.sh search-functions "get_*" --filter=no-metrics
```

**Expected Output:**
Results without complexity and LOC metrics.

**Variations:**
```bash
# With different formats
bash query.sh search-functions "*" --format=vim-hover --filter=no-metrics
bash query.sh find-function "calculate_total" --filter=no-metrics
```

### 9.3 No File Info Filter

**Command:**
```bash
bash query.sh search-functions "*" --filter=no-file-info
```

**Expected Output:**
Results without file path and line number.

**Variations:**
```bash
# Combined filters
bash query.sh search-functions "*" --filter=no-file-info --filter=no-metrics
bash query.sh search-functions "get_*" --format=vim-completion --filter=no-file-info
```

---

## Phase 10: Error Handling and Edge Cases

These commands test error handling and edge cases.

### 10.1 Non-Existent Database

**Command:**
```bash
SIGNATURES_DB=/tmp/nonexistent.db bash query.sh find-function "test"
```

**Expected Output:**
Error message indicating database not found.

### 10.2 Invalid Function Name

**Command:**
```bash
bash query.sh find-function ""
```

**Expected Output:**
Error or empty result.

### 10.3 Invalid Pattern

**Command:**
```bash
bash query.sh search-functions "[invalid"
```

**Expected Output:**
Error or empty result.

### 10.4 Missing Required Arguments

**Command:**
```bash
bash query.sh find-function
```

**Expected Output:**
Usage error message.

### 10.5 Unknown Command

**Command:**
```bash
bash query.sh unknown-command
```

**Expected Output:**
Usage information and error message.

---

## Phase 11: Performance Testing

These commands test performance characteristics.

### 11.1 Time Exact Lookup

**Command:**
```bash
time bash query.sh find-function "calculate_total"
```

**Expected Output:**
Function result with execution time (should be <1ms).

### 11.2 Time Pattern Search

**Command:**
```bash
time bash query.sh search-functions "get_*"
```

**Expected Output:**
Search results with execution time (should be <10ms).

### 11.3 Time Large Result Set

**Command:**
```bash
time bash query.sh search-functions "*"
```

**Expected Output:**
All functions with execution time.

### 11.4 Time Type Resolution Query

**Command:**
```bash
time bash query.sh find-function-resolved "process_contract"
```

**Expected Output:**
Resolved function with execution time (should be <1ms).

---

## Phase 12: Integration Testing

These commands test integration between different components.

### 12.1 Generate, Create DB, and Query

**Command Sequence:**
```bash
# 1. Generate metadata
bash generate_all.sh tests/sample_codebase

# 2. Create databases
bash query.sh create-dbs

# 3. Query the database
bash query.sh find-function "calculate_total"
bash query.sh search-functions "get_*"
bash query.sh find-function-dependencies "calculate_total"
```

**Expected Output:**
All commands should succeed with consistent results.

### 12.2 Module and Function Integration

**Command Sequence:**
```bash
# Find module
bash query.sh find-module "core"

# Find functions in module
bash query.sh find-functions-in-module "core"

# Find dependencies for a function in the module
bash query.sh find-function-dependencies "calculate_total"
```

**Expected Output:**
Consistent results showing module structure and function relationships.

### 12.3 Reference and Author Integration

**Command Sequence:**
```bash
# Find reference
bash query.sh find-reference "PRB-299"

# Get file references
bash query.sh file-references "tests/sample_codebase/simple_functions.4gl"

# Get file authors
bash query.sh file-authors "tests/sample_codebase/simple_functions.4gl"

# Get author expertise
bash query.sh author-expertise "Rich"
```

**Expected Output:**
Consistent results showing code references and author information.

---

## Testing Checklist

Use this checklist to verify all functionality:

- [ ] Phase 1: Generation commands work and create expected files
- [ ] Phase 2: Function queries return correct results
- [ ] Phase 3: Dependency queries show correct relationships
- [ ] Phase 4: Module queries work with module data
- [ ] Phase 5: Reference and author queries return correct information
- [ ] Phase 6: Type resolution queries work with resolved types
- [ ] Phase 7: Batch queries execute multiple commands
- [ ] Phase 8: Output formats work for Vim integration
- [ ] Phase 9: Filters correctly modify output
- [ ] Phase 10: Error handling works gracefully
- [ ] Phase 11: Performance is within expected ranges
- [ ] Phase 12: Integration between components works correctly

---

## Troubleshooting

### Database Not Found
```bash
# Solution: Create databases first
bash query.sh create-dbs
```

### No Results from Query
```bash
# Verify database exists
ls -la workspace.db

# Verify data was generated
python3 -c "import json; print(len(json.load(open('workspace.json'))))"

# Try a simpler query
bash query.sh search-functions "*"
```

### Permission Denied
```bash
# Make scripts executable
chmod +x generate_all.sh src/*.sh query.sh
```

### Python Errors
```bash
# Verify Python version
python3 --version

# Verify required modules
python3 -c "import json, sqlite3; print('OK')"
```

---

## Next Steps

After completing all tests:

1. Review [docs/QUERYING.md](QUERYING.md) for detailed query documentation
2. Check [docs/VIM_PLUGIN_INTEGRATION_GUIDE.md](VIM_PLUGIN_INTEGRATION_GUIDE.md) for editor integration
3. Explore [docs/TYPE_RESOLUTION_GUIDE.md](TYPE_RESOLUTION_GUIDE.md) for type resolution details
4. Review [docs/ARCHITECTURE.md](ARCHITECTURE.md) for system design
5. Check [docs/api/](api/) for complete API reference

