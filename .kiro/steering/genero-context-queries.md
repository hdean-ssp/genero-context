# Genero Context Framework: Query Reference

**Purpose**: Complete reference for genero-tools queries with selection guidance and output formats

**Inclusion**: auto

---

## Quick Reference: Essential Queries

Use these 6 queries for 90% of your work:

### 1. Find a Function
```bash
bash $BRODIR/etc/genero-tools/query.sh find-function "my_function"
```
**Use when**: You need to understand a specific function
**Returns**: Signature, parameters, returns, complexity, LOC, file path, line numbers

### 2. Find What a Function Calls
```bash
bash $BRODIR/etc/genero-tools/query.sh find-function-dependencies "my_function"
```
**Use when**: You need to understand what a function depends on
**Returns**: List of functions that `my_function` calls

### 3. Find What Calls a Function
```bash
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "my_function"
```
**Use when**: You need to understand impact of changes
**Returns**: List of functions that call `my_function`

### 4. List All Functions in a File
```bash
bash $BRODIR/etc/genero-tools/query.sh list-file-functions "path/to/file.4gl"
```
**Use when**: You need to understand file structure
**Returns**: All functions defined in the file

### 5. Find Code References
```bash
bash $BRODIR/etc/genero-tools/query.sh find-reference "PRB-299"
```
**Use when**: You need to find where a bug/issue is referenced
**Returns**: Files containing the code reference

### 6. Search Functions by Pattern
```bash
bash $BRODIR/etc/genero-tools/query.sh search-functions "get_*"
```
**Use when**: You need to find similar functions to follow patterns
**Returns**: All functions matching the pattern

---

## Complete Query Reference

### Function Queries

#### find-function
Get function metadata, signature, parameters, returns, and quality metrics.

```bash
bash $BRODIR/etc/genero-tools/query.sh find-function "process_order"
```

**Output Format:**
```json
{
  "name": "process_order",
  "file_path": "src/module.4gl",
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

**When to use:**
- Understanding a specific function
- Checking complexity metrics
- Verifying function signature
- Assessing code quality

**Planner Hat**: Use to understand function details during planning
**Builder Hat**: Use to verify implementation matches expectations
**Reviewer Hat**: Use to validate complexity and quality metrics

---

#### search-functions
Search functions by name pattern (supports wildcards).

```bash
bash $BRODIR/etc/genero-tools/query.sh search-functions "get_*"
```

**Output Format:**
```json
[
  {
    "name": "get_customer",
    "file_path": "src/customers.4gl",
    "complexity": 3,
    "lines_of_code": 15
  },
  {
    "name": "get_order",
    "file_path": "src/orders.4gl",
    "complexity": 5,
    "lines_of_code": 25
  }
]
```

**When to use:**
- Finding similar functions to follow patterns
- Identifying functions by naming convention
- Discovering related functionality
- Assessing codebase patterns

**Planner Hat**: Use to find similar functions and understand patterns
**Builder Hat**: Use to follow existing patterns when implementing
**Reviewer Hat**: Use to verify consistency with similar functions

---

#### list-file-functions
List all functions in a specific file.

```bash
bash $BRODIR/etc/genero-tools/query.sh list-file-functions "src/module.4gl"
```

**Output Format:**
```json
[
  {
    "name": "process_order",
    "line": {"start": 100, "end": 150},
    "complexity": 8,
    "lines_of_code": 50
  },
  {
    "name": "validate_order",
    "line": {"start": 155, "end": 180},
    "complexity": 3,
    "lines_of_code": 25
  }
]
```

**When to use:**
- Understanding file structure
- Identifying all functions in a file
- Assessing file complexity
- Planning changes to a file

**Planner Hat**: Use to understand file structure and dependencies
**Builder Hat**: Use to verify all functions in file are tested
**Reviewer Hat**: Use to validate file organization

---

#### find-all-function-instances
Find all instances of a function (when multiple functions have the same name).

```bash
bash $BRODIR/etc/genero-tools/query.sh find-all-function-instances "process_data"
```

**Output Format:**
```json
[
  {
    "name": "process_data",
    "file_path": "src/module1.4gl",
    "line": {"start": 50, "end": 100}
  },
  {
    "name": "process_data",
    "file_path": "src/module2.4gl",
    "line": {"start": 200, "end": 250}
  }
]
```

**When to use:**
- Handling functions with duplicate names
- Understanding scope of function names
- Identifying all implementations

**Planner Hat**: Use to clarify which function you're working with
**Builder Hat**: Use to ensure you're modifying the correct function
**Reviewer Hat**: Use to verify all instances are consistent

---

#### find-function-by-name-and-path
Find specific function instance when multiple functions have the same name.

```bash
bash $BRODIR/etc/genero-tools/query.sh find-function-by-name-and-path "process_data" "./src/module1.4gl"
```

**When to use:**
- Disambiguating functions with duplicate names
- Getting specific function details
- Verifying function location

**Planner Hat**: Use to identify exact function location
**Builder Hat**: Use to ensure correct function is modified
**Reviewer Hat**: Use to verify correct function was changed

---

### Dependency Queries

#### find-function-dependencies
Find all functions that a function calls (what it depends on).

```bash
bash $BRODIR/etc/genero-tools/query.sh find-function-dependencies "process_order"
```

**Output Format:**
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

**When to use:**
- Understanding function dependencies
- Identifying what a function calls
- Assessing impact of dependency changes
- Planning refactoring

**Planner Hat**: Use to understand dependencies and risks
**Builder Hat**: Use to verify dependencies are available
**Reviewer Hat**: Use to validate dependencies are correct

---

#### find-function-dependents
Find all functions that call a function (what depends on it).

```bash
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "validate_order"
```

**Output Format:**
```json
[
  {
    "name": "process_order",
    "file_path": "src/module.4gl",
    "line": 110
  },
  {
    "name": "process_batch",
    "file_path": "src/batch.4gl",
    "line": 250
  }
]
```

**When to use:**
- Understanding impact of changes
- Identifying all callers of a function
- Planning testing strategy
- Assessing regression risk

**Planner Hat**: Use to identify all functions that need testing
**Builder Hat**: Use to test all dependents
**Reviewer Hat**: Use to verify all dependents are tested

---

### Code Reference Queries

#### find-reference
Find files containing a specific code reference (e.g., bug ID, requirement ID).

```bash
bash $BRODIR/etc/genero-tools/query.sh find-reference "PRB-299"
```

**Output Format:**
```json
[
  {
    "file_path": "src/module.4gl",
    "reference": "PRB-299",
    "context": "Fixed issue PRB-299: order processing"
  }
]
```

**When to use:**
- Finding where a bug is referenced
- Locating requirement implementations
- Tracking issue fixes
- Understanding change history

**Planner Hat**: Use to understand issue context
**Builder Hat**: Use to verify fix is in correct location
**Reviewer Hat**: Use to validate issue is properly addressed

---

#### search-references
Search for code references by pattern.

```bash
bash $BRODIR/etc/genero-tools/query.sh search-references "100512"
```

**Output Format:**
```json
[
  {
    "file_path": "src/module.4gl",
    "reference": "EH100512",
    "context": "Enhancement EH100512"
  }
]
```

**When to use:**
- Finding references by pattern
- Locating related issues
- Tracking enhancement implementations

**Planner Hat**: Use to find related changes
**Builder Hat**: Use to ensure consistency with related changes
**Reviewer Hat**: Use to verify all related changes are addressed

---

#### find-author
Find files modified by a specific author.

```bash
bash $BRODIR/etc/genero-tools/query.sh find-author "John Smith"
```

**Output Format:**
```json
[
  {
    "file_path": "src/module.4gl",
    "author": "John Smith",
    "modifications": 5
  }
]
```

**When to use:**
- Finding expertise areas
- Identifying code ownership
- Understanding change history
- Finding subject matter experts

**Planner Hat**: Use to identify experts for consultation
**Builder Hat**: Use to understand code context
**Reviewer Hat**: Use to verify changes align with ownership

---

#### author-expertise
Show what areas an author has expertise in based on modifications.

```bash
bash $BRODIR/etc/genero-tools/query.sh author-expertise "John Smith"
```

**Output Format:**
```json
{
  "author": "John Smith",
  "expertise_areas": [
    {
      "area": "order_processing",
      "files": 12,
      "modifications": 45
    },
    {
      "area": "customer_management",
      "files": 8,
      "modifications": 23
    }
  ]
}
```

**When to use:**
- Finding subject matter experts
- Understanding expertise distribution
- Planning code reviews
- Identifying knowledge gaps

**Planner Hat**: Use to identify experts for consultation
**Builder Hat**: Use to learn from experts
**Reviewer Hat**: Use to assign appropriate reviewers

---

### Type Resolution Queries

#### find-function-resolved
Get function with resolved LIKE type information.

```bash
bash $BRODIR/etc/genero-tools/query.sh find-function-resolved "process_contract"
```

**Output Format:**
```json
{
  "name": "process_contract",
  "parameters": [
    {
      "name": "contract_data",
      "type": "LIKE contract_table.*",
      "resolved_columns": ["id", "name", "amount"],
      "resolved_types": ["INTEGER", "STRING", "DECIMAL"]
    }
  ]
}
```

**When to use:**
- Understanding LIKE type parameters
- Verifying type resolution
- Assessing data structure compatibility

**Planner Hat**: Use to understand data structures
**Builder Hat**: Use to verify type compatibility
**Reviewer Hat**: Use to validate type correctness

---

#### unresolved-types
Find all unresolved LIKE references.

```bash
bash $BRODIR/etc/genero-tools/query.sh unresolved-types
```

With filtering:
```bash
bash $BRODIR/etc/genero-tools/query.sh unresolved-types --filter missing_table
bash $BRODIR/etc/genero-tools/query.sh unresolved-types --filter missing_column
```

With pagination:
```bash
bash $BRODIR/etc/genero-tools/query.sh unresolved-types --limit 10 --offset 20
```

**When to use:**
- Finding type resolution issues
- Identifying missing tables or columns
- Assessing code quality
- Planning refactoring

**Planner Hat**: Use to identify type issues
**Builder Hat**: Use to fix type issues
**Reviewer Hat**: Use to verify type issues are resolved

---

#### validate-types
Validate type resolution data consistency.

```bash
bash $BRODIR/etc/genero-tools/query.sh validate-types
```

**When to use:**
- Validating type resolution consistency
- Checking database integrity
- Assessing data quality

**Planner Hat**: Use to assess type resolution quality
**Builder Hat**: Use to verify types are correct
**Reviewer Hat**: Use to validate type consistency

---

## Query Selection Decision Matrix

**Use this table to find the right query for your need:**

| Need | Query | Hat | Phase |
|------|-------|-----|-------|
| Understand a function | find-function | Planner | Inception |
| Check function complexity | find-function | Reviewer | Operation |
| Find similar functions | search-functions | Planner | Inception |
| Follow existing patterns | search-functions | Builder | Construction |
| Understand dependencies | find-function-dependencies | Planner | Inception |
| Verify dependencies work | find-function-dependencies | Builder | Construction |
| Understand impact | find-function-dependents | Planner | Inception |
| Test all dependents | find-function-dependents | Builder | Construction |
| Verify impact | find-function-dependents | Reviewer | Operation |
| Find file structure | list-file-functions | Planner | Inception |
| Find code reference | find-reference | Planner | Inception |
| Verify fix location | find-reference | Builder | Construction |
| Find expertise | author-expertise | Planner | Inception |
| Verify type resolution | find-function-resolved | Builder | Construction |
| Find type issues | unresolved-types | Planner | Inception |

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
bash $BRODIR/etc/genero-tools/query.sh find-function "my_function"  # from .4gl

# Wrong: Don't query compiled files
bash $BRODIR/etc/genero-tools/query.sh find-function "my_function"  # from .42f (won't work)
```

If you need to work with code that's in compiled form, find the corresponding `.4gl` source file first.

---

## Performance Expectations

| Operation | Time | Use Case |
|-----------|------|----------|
| Exact function lookup | <1ms | find-function |
| Pattern search | <10ms | search-functions |
| Dependency query | <10ms | find-function-dependents |
| Metrics extraction | <1ms | Complexity assessment |
| Type validation | <1s | validate-types |
| Full analysis (100 files) | 5-10 min | Comprehensive review |

---

## Query Tips & Tricks

### Tip 1: Use Wildcards for Pattern Matching
```bash
# Find all get_* functions
bash $BRODIR/etc/genero-tools/query.sh search-functions "get_*"

# Find all process_* functions
bash $BRODIR/etc/genero-tools/query.sh search-functions "process_*"

# Find all validate_* functions
bash $BRODIR/etc/genero-tools/query.sh search-functions "validate_*"
```

### Tip 2: Combine Queries for Full Context
```bash
# Get function details
bash $BRODIR/etc/genero-tools/query.sh find-function "my_function"

# Get what it calls
bash $BRODIR/etc/genero-tools/query.sh find-function-dependencies "my_function"

# Get what calls it
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "my_function"

# Get similar functions
bash $BRODIR/etc/genero-tools/query.sh search-functions "my_*"
```

### Tip 3: Use Pagination for Large Result Sets
```bash
# Get first 10 results
bash $BRODIR/etc/genero-tools/query.sh unresolved-types --limit 10

# Get next 10 results
bash $BRODIR/etc/genero-tools/query.sh unresolved-types --limit 10 --offset 10
```

### Tip 4: Filter Results for Specific Issues
```bash
# Find missing tables
bash $BRODIR/etc/genero-tools/query.sh unresolved-types --filter missing_table

# Find missing columns
bash $BRODIR/etc/genero-tools/query.sh unresolved-types --filter missing_column
```

### Tip 5: Verify Function Instances
```bash
# Find all instances of a function
bash $BRODIR/etc/genero-tools/query.sh find-all-function-instances "process_data"

# Get specific instance
bash $BRODIR/etc/genero-tools/query.sh find-function-by-name-and-path "process_data" "./src/module1.4gl"
```

---

## Common Query Patterns

### Pattern 1: Understand a Function Completely
```bash
# 1. Get function details
bash $BRODIR/etc/genero-tools/query.sh find-function "target_function"

# 2. See what it calls
bash $BRODIR/etc/genero-tools/query.sh find-function-dependencies "target_function"

# 3. See what calls it
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "target_function"

# 4. Find similar functions
bash $BRODIR/etc/genero-tools/query.sh search-functions "target_*"
```

### Pattern 2: Plan a Change
```bash
# 1. Find the function
bash $BRODIR/etc/genero-tools/query.sh find-function "function_to_change"

# 2. Understand impact
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "function_to_change"

# 3. Find similar functions to follow patterns
bash $BRODIR/etc/genero-tools/query.sh search-functions "similar_*"

# 4. Verify type resolution
bash $BRODIR/etc/genero-tools/query.sh find-function-resolved "function_to_change"
```

### Pattern 3: Verify a Fix
```bash
# 1. Find the function
bash $BRODIR/etc/genero-tools/query.sh find-function "fixed_function"

# 2. Verify all dependents
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "fixed_function"

# 3. Check for type issues
bash $BRODIR/etc/genero-tools/query.sh unresolved-types

# 4. Validate types
bash $BRODIR/etc/genero-tools/query.sh validate-types
```

### Pattern 4: Find Code References
```bash
# 1. Find reference
bash $BRODIR/etc/genero-tools/query.sh find-reference "PRB-299"

# 2. Get function details
bash $BRODIR/etc/genero-tools/query.sh find-function "referenced_function"

# 3. Understand impact
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "referenced_function"
```

---

## Next: Error Handling & Operations

For error handling and troubleshooting, see: `genero-context-operations.md`

For workflow and agent behavior, see: `genero-context-workflow.md`
