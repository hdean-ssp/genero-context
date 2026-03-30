# Genero Tools Reference

**Purpose:** Quick reference for agents using genero-tools to analyze Genero/4GL codebases.

**Version:** 2.1.0 | **Status:** Production Ready

---

## What is genero-tools?

genero-tools extracts function signatures, dependencies, and metadata from Genero/4GL codebases and provides efficient querying via SQLite databases. It enables semantic code analysis without parsing source files repeatedly.

**Key Capabilities:**
- Extract function signatures, parameters, returns, and metrics
- Resolve LIKE type references to database schema
- Query dependencies and call graphs
- Find code references and author information
- Analyze code quality metrics

---

## Quick Start

```bash
# One-time setup: Generate databases from codebase
bash generate_all.sh /path/to/codebase

# Find a function
bash query.sh find-function "my_function"

# Search functions by pattern
bash query.sh search-functions "get_*"

# Find what a function calls
bash query.sh find-function-dependencies "process_order"

# Find what calls a function
bash query.sh find-function-dependents "validate_order"

# Find code references
bash query.sh find-reference "PRB-299"

# Query resolved types
bash query.sh find-function-resolved "process_contract"
```

---

## Core Queries

### Function Queries

| Query | Purpose | Example |
|-------|---------|---------|
| `find-function` | Get function signature, parameters, returns, metrics | `bash query.sh find-function "process_order"` |
| `search-functions` | Search functions by name pattern (wildcards supported) | `bash query.sh search-functions "get_*"` |
| `list-file-functions` | List all functions in a file | `bash query.sh list-file-functions "src/module.4gl"` |
| `find-function-by-name-and-path` | Find specific function instance (for duplicate names) | `bash query.sh find-function-by-name-and-path "process_data" "./src/module1.4gl"` |
| `find-all-function-instances` | Find all instances of a function across files | `bash query.sh find-all-function-instances "process_data"` |

### Dependency Queries

| Query | Purpose | Example |
|-------|---------|---------|
| `find-function-dependencies` | Find all functions that a function calls | `bash query.sh find-function-dependencies "process_order"` |
| `find-function-dependents` | Find all functions that call a function | `bash query.sh find-function-dependents "validate_order"` |

### Code Reference Queries

| Query | Purpose | Example |
|-------|---------|---------|
| `find-reference` | Find files containing a code reference | `bash query.sh find-reference "PRB-299"` |
| `search-references` | Search references by pattern | `bash query.sh search-references "100512"` |
| `find-author` | Find files modified by an author | `bash query.sh find-author "John Smith"` |
| `author-expertise` | Show author's expertise areas | `bash query.sh author-expertise "John Smith"` |

### Type Resolution Queries

| Query | Purpose | Example |
|-------|---------|---------|
| `find-function-resolved` | Get function with resolved LIKE types | `bash query.sh find-function-resolved "process_contract"` |
| `unresolved-types` | Find all unresolved LIKE references | `bash query.sh unresolved-types` |
| `unresolved-types --filter missing_table` | Find missing table references | `bash query.sh unresolved-types --filter missing_table` |
| `unresolved-types --filter missing_column` | Find missing column references | `bash query.sh unresolved-types --filter missing_column` |
| `unresolved-types --limit 10 --offset 20` | Paginate results | `bash query.sh unresolved-types --limit 10 --offset 20` |
| `validate-types` | Validate type resolution data consistency | `bash query.sh validate-types` |

---

## Output Format

All queries return JSON for easy parsing and integration.

### Function Query Output

```json
{
  "name": "process_order",
  "file_path": "src/orders.4gl",
  "line": {"start": 100, "end": 150},
  "signature": "FUNCTION process_order(order_id INTEGER) RETURNS (status INTEGER)",
  "parameters": [
    {"name": "order_id", "type": "INTEGER"}
  ],
  "returns": [
    {"name": "status", "type": "INTEGER"}
  ],
  "complexity": 8,
  "lines_of_code": 50,
  "parameter_count": 1,
  "return_count": 1
}
```

### Dependency Query Output

```json
[
  {
    "name": "validate_order",
    "file_path": "src/validators.4gl",
    "line": 105
  },
  {
    "name": "save_order",
    "file_path": "src/database.4gl",
    "line": 200
  }
]
```

### Type Resolution Output

```json
{
  "name": "process_account",
  "file": "./src/processing.4gl",
  "parameters": [
    {
      "name": "acc",
      "type": "LIKE account.*",
      "is_like_reference": true,
      "resolved": true,
      "table_name": "account",
      "resolved_columns": ["id", "name", "balance"],
      "resolved_types": ["INTEGER", "VARCHAR(100)", "DECIMAL(10,2)"]
    }
  ]
}
```

---

## Common Query Patterns

### Pattern 1: Understand a Function Completely

```bash
# 1. Get function details
bash query.sh find-function "target_function"

# 2. See what it calls
bash query.sh find-function-dependencies "target_function"

# 3. See what calls it
bash query.sh find-function-dependents "target_function"

# 4. Find similar functions
bash query.sh search-functions "target_*"
```

### Pattern 2: Plan a Change

```bash
# 1. Find the function
bash query.sh find-function "function_to_change"

# 2. Understand impact (what depends on it)
bash query.sh find-function-dependents "function_to_change"

# 3. Find similar functions to follow patterns
bash query.sh search-functions "similar_*"

# 4. Verify type resolution
bash query.sh find-function-resolved "function_to_change"
```

### Pattern 3: Verify a Fix

```bash
# 1. Find the function
bash query.sh find-function "fixed_function"

# 2. Verify all dependents still work
bash query.sh find-function-dependents "fixed_function"

# 3. Check for type issues
bash query.sh unresolved-types

# 4. Validate types
bash query.sh validate-types
```

### Pattern 4: Find Code References

```bash
# 1. Find reference
bash query.sh find-reference "PRB-299"

# 2. Get function details
bash query.sh find-function "referenced_function"

# 3. Understand impact
bash query.sh find-function-dependents "referenced_function"
```

---

## Type Resolution

### What is LIKE Type Resolution?

LIKE references in Genero allow functions to accept parameters matching database table structures:

```4gl
FUNCTION process_account(acc LIKE account.*)
  RETURNS result LIKE account.id, status INTEGER
```

genero-tools automatically resolves these to actual database schema types:
- `LIKE account.*` → all columns in account table
- `LIKE account.id` → specific column

### Query Resolved Types

```bash
# Get function with resolved types
bash query.sh find-function-resolved "process_account"

# Find unresolved types (debugging)
bash query.sh unresolved-types

# Filter by error type
bash query.sh unresolved-types --filter missing_table
bash query.sh unresolved-types --filter missing_column

# Validate data consistency
bash query.sh validate-types
```

---

## Performance

| Operation | Time |
|-----------|------|
| Exact function lookup | <1ms |
| Pattern search | <10ms |
| Dependency query | <10ms |
| Type resolution query | <1ms |
| Validation | <1s |

---

## Error Handling

### Database Not Found

```
Error: database file not found
```

**Solution:** Create databases first:
```bash
bash query.sh create-dbs
```

### No Results

1. Verify database exists: `ls -la workspace.db`
2. Check pattern is correct: `bash query.sh search-functions "get_*"`
3. Try simpler pattern: `bash query.sh search-functions "get_*"`

### Too Many Results

1. Use more specific pattern
2. Filter by file or author
3. Use pagination: `--limit 10 --offset 0`

### Schema Not Found

Type resolution is skipped if no `.sch` file found. Provide schema explicitly:
```bash
bash generate_all.sh /path/to/codebase /path/to/schema.sch
```

### Unresolved Types

Check if referenced tables exist in schema:
```bash
bash query.sh unresolved-types --filter missing_table
```

---

## Python API

For programmatic access:

```python
from scripts.query_db import (
    find_function,
    search_functions,
    find_function_dependencies,
    find_function_dependents,
    find_function_resolved,
    find_unresolved_types,
    validate_type_resolution
)

# Find a function
result = find_function('workspace.db', 'my_function')

# Search functions
results = search_functions('workspace.db', 'get_*')

# Get dependencies
deps = find_function_dependencies('workspace.db', 'process_order')

# Get dependents
dependents = find_function_dependents('workspace.db', 'validate_order')

# Get resolved types
resolved = find_function_resolved('workspace.db', 'process_contract')

# Find unresolved types
unresolved = find_unresolved_types('workspace.db')

# Validate types
report = validate_type_resolution('workspace.db')
```

---

## Important: Source Files Only

**genero-tools works ONLY with source files (.4gl)**

Do NOT attempt to query or analyze:
- `.42f` - Compiled form files (binary)
- `.42m` - Compiled module files (binary)
- `.42r` - Compiled report files (binary)

**Always query source files:**
```bash
# Correct: Query source file
bash query.sh find-function "my_function"  # from .4gl

# Wrong: Don't query compiled files
bash query.sh find-function "my_function"  # from .42f (won't work)
```

If you need to work with code that's in compiled form, find the corresponding `.4gl` source file first.

---

## Architecture Overview

genero-tools follows this data flow:

```
Genero Codebase (.4gl files)
    ↓
generate_signatures.sh → workspace.json (function signatures)
    ↓
generate_modules.sh → modules.json (module dependencies)
    ↓
generate_codebase_index.sh → codebase_index.json (unified index)
    ↓
json_to_sqlite.py → workspace.db (indexed SQLite database)
    ↓
query.sh / query_db.py → Query Results (JSON)
```

**Key Components:**

1. **Signature Generation** - Extracts function signatures using sed/awk
2. **Module Generation** - Parses .m3 makefiles for dependencies
3. **Codebase Index** - Merges signatures and modules
4. **Type Resolution** - Resolves LIKE references to schema types
5. **SQLite Database** - Provides efficient indexed querying
6. **Query Interface** - Shell wrapper (query.sh) and Python API

---

## Metrics Extracted

For each function, genero-tools extracts:

- **Lines of Code (LOC)** - Function body line count
- **Cyclomatic Complexity** - Decision point count
- **Parameter Count** - Number of parameters
- **Return Count** - Number of return values
- **Variable Count** - Local variable declarations
- **Call Depth** - Maximum nesting depth

Use these metrics to identify complex functions and refactoring candidates.

---

## Related Documentation

- **GENERO_TOOLS_SETUP.md** - Installation and setup guide
- **genero-tools-docs/ARCHITECTURE.md** - Detailed system design
- **genero-tools-docs/FEATURES.md** - Complete feature list
- **genero-tools-docs/SECURITY.md** - Security considerations

---

## Next Steps

1. **Setup:** Run `bash generate_all.sh /path/to/codebase` to create databases
2. **Query:** Use `bash query.sh` commands to analyze your codebase
3. **Integrate:** Use Python API for programmatic access in your tools
4. **Troubleshoot:** See error handling section above for common issues

