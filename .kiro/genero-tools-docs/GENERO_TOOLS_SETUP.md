# Genero Tools Setup & Operations

**Purpose:** Installation, configuration, and operational guidance for genero-tools.

**Version:** 2.1.0 | **Status:** Production Ready

---

## Installation

### Prerequisites

- RHEL 9 or compatible Linux distribution
- Bash 4.0+
- Python 3.8+
- SQLite 3.0+
- Standard Unix utilities (sed, awk, grep, find)

All prerequisites are included in RHEL 9 base installation.

### Setup Steps

1. **Clone or download genero-tools**
   ```bash
   git clone https://github.com/hdean-ssp/genero-context.git
   cd genero-context
   ```

2. **Make scripts executable**
   ```bash
   chmod +x *.sh scripts/*.py
   ```

3. **Generate databases from your codebase**
   ```bash
   bash generate_all.sh /path/to/your/genero/codebase
   ```

4. **Verify installation**
   ```bash
   bash query.sh find-function "any_function_name"
   ```

---

## Configuration

### Environment Variables

```bash
# Database location (default: current directory)
export GENERO_TOOLS_DB_PATH="/path/to/databases"

# Query timeout in seconds (default: 30)
export GENERO_TOOLS_TIMEOUT=60

# Logging level (default: info)
export GENERO_TOOLS_LOG_LEVEL="debug"  # debug, info, warning, error

# Cache TTL in seconds (default: 3600)
export GENERO_TOOLS_CACHE_TTL=7200
```

### Schema Configuration

genero-tools automatically detects and processes schema files (`.sch`):

```bash
# Automatic detection (schema in codebase directory)
bash generate_all.sh /path/to/codebase

# Explicit schema path
bash generate_all.sh /path/to/codebase /path/to/schema.sch

# Multiple schema files (future enhancement)
# Currently supports single schema per workspace
```

---

## Database Generation

### One-Time Setup

```bash
# Generate all databases from codebase
bash generate_all.sh /path/to/codebase

# This creates:
# - workspace.json (function signatures)
# - modules.json (module dependencies)
# - codebase_index.json (unified index)
# - workspace.db (SQLite database for querying)
# - workspace_resolved.json (type-resolved signatures)
```

### Incremental Updates

For large codebases, use incremental updates:

```bash
# Update only changed files
bash scripts/incremental_generator.py workspace.db /path/to/codebase

# This is faster than full regeneration
```

### Regenerate Databases

```bash
# Full regeneration (clears existing data)
bash query.sh create-dbs
bash generate_all.sh /path/to/codebase
```

---

## Database Files

### workspace.db

SQLite database containing:
- **files** - Source files with paths and types
- **functions** - Function signatures, metrics, and metadata
- **parameters** - Function parameters with types
- **returns** - Function return values with types
- **modules** - Module definitions and dependencies

**Size:** ~70KB for typical codebase (vs 15-20MB JSON)

**Indexes:**
- Function name (exact and pattern matching)
- File path (for file-scoped queries)
- Complexity metrics (for quality analysis)

### workspace.json

JSON file containing raw function signatures (kept for reference/debugging).

**Size:** 15-20MB for typical codebase

**Use:** Debugging, manual inspection, backup

### modules.json

JSON file containing module definitions and dependencies.

**Use:** Module-scoped analysis, dependency tracking

### workspace_resolved.json

JSON file containing type-resolved function signatures.

**Use:** Type-aware analysis, IDE integration

---

## Operations

### Querying the Database

```bash
# Basic query
bash query.sh find-function "my_function"

# Pattern search
bash query.sh search-functions "get_*"

# Dependency analysis
bash query.sh find-function-dependencies "process_order"
bash query.sh find-function-dependents "validate_order"

# Type resolution
bash query.sh find-function-resolved "process_contract"
bash query.sh unresolved-types
bash query.sh validate-types

# Code references
bash query.sh find-reference "PRB-299"
bash query.sh find-author "John Smith"
```

### Monitoring Database Health

```bash
# Validate type resolution data
bash query.sh validate-types

# Check database integrity
sqlite3 workspace.db "PRAGMA integrity_check;"

# Get database statistics
sqlite3 workspace.db "SELECT COUNT(*) as functions FROM functions;"
sqlite3 workspace.db "SELECT COUNT(*) as parameters FROM parameters;"

# Check database size
du -h workspace.db
```

### Troubleshooting

#### Database Corruption

```bash
# Symptoms: Queries fail or return incomplete results

# Solution 1: Validate database
bash query.sh validate-types

# Solution 2: Rebuild database
bash query.sh create-dbs
bash generate_all.sh /path/to/codebase

# Solution 3: Check for disk space
df -h
```

#### Slow Queries

```bash
# Symptoms: Queries taking >1 second

# Solution 1: Check system load
uptime

# Solution 2: Rebuild indexes
sqlite3 workspace.db "REINDEX;"

# Solution 3: Use pagination for large result sets
bash query.sh unresolved-types --limit 10 --offset 0

# Solution 4: Use more specific patterns
bash query.sh search-functions "get_account*"  # More specific
bash query.sh search-functions "get_*"         # Less specific
```

#### Missing Functions

```bash
# Symptoms: Function exists but query returns nothing

# Solution 1: Verify database was generated
ls -la workspace.db

# Solution 2: Check if function is in source
grep -r "FUNCTION my_function" --include="*.4gl"

# Solution 3: Regenerate database
bash generate_all.sh /path/to/codebase

# Solution 4: Check for syntax errors in source
grep -n "FUNCTION\|END FUNCTION" /path/to/file.4gl
```

#### Type Resolution Failures

```bash
# Symptoms: Type resolution not working

# Solution 1: Check for unresolved types
bash query.sh unresolved-types

# Solution 2: Verify schema file exists
ls -la /path/to/codebase/*.sch

# Solution 3: Check for missing tables
bash query.sh unresolved-types --filter missing_table

# Solution 4: Regenerate with schema
bash generate_all.sh /path/to/codebase /path/to/schema.sch
```

---

## Integration

### Shell Integration

```bash
# Add to .bashrc or .bash_profile
alias genero-find='bash /path/to/genero-tools/query.sh find-function'
alias genero-search='bash /path/to/genero-tools/query.sh search-functions'
alias genero-deps='bash /path/to/genero-tools/query.sh find-function-dependencies'
alias genero-dependents='bash /path/to/genero-tools/query.sh find-function-dependents'

# Usage
genero-find "my_function"
genero-search "get_*"
genero-deps "process_order"
```

### Python Integration

```python
import sys
sys.path.insert(0, '/path/to/genero-tools')

from scripts.query_db import (
    find_function,
    search_functions,
    find_function_dependencies,
    find_function_dependents
)

# Find a function
result = find_function('workspace.db', 'my_function')
print(f"Function: {result['name']}")
print(f"Complexity: {result['complexity']}")
print(f"LOC: {result['lines_of_code']}")

# Search functions
results = search_functions('workspace.db', 'get_*')
for func in results:
    print(f"{func['name']}: complexity={func['complexity']}")
```

### CI/CD Integration

```bash
#!/bin/bash
# ci-genero-analysis.sh

CODEBASE_PATH="/path/to/codebase"
SCHEMA_PATH="/path/to/schema.sch"

# Generate databases
bash generate_all.sh "$CODEBASE_PATH" "$SCHEMA_PATH"

# Validate type resolution
bash query.sh validate-types
if [ $? -ne 0 ]; then
  echo "Type resolution validation failed"
  exit 1
fi

# Find overly complex functions
COMPLEX=$(bash query.sh search-functions "*" | grep -c '"complexity": [0-9][0-9]')
if [ "$COMPLEX" -gt 5 ]; then
  echo "Warning: Found $COMPLEX complex functions"
fi

# Check for unresolved types
UNRESOLVED=$(bash query.sh unresolved-types | grep -c '"error_type"')
if [ "$UNRESOLVED" -gt 0 ]; then
  echo "Warning: Found $UNRESOLVED unresolved types"
fi

echo "Analysis complete"
```

---

## Performance Tuning

### Query Optimization

```bash
# Good: Specific function lookup (fast)
bash query.sh find-function "process_order"

# Bad: Broad pattern search (slower)
bash query.sh search-functions "*"

# Good: Paginated results (fast)
bash query.sh unresolved-types --limit 10 --offset 0

# Bad: All results at once (slower)
bash query.sh unresolved-types
```

### Database Optimization

```bash
# Rebuild indexes for better performance
sqlite3 workspace.db "REINDEX;"

# Analyze query plans
sqlite3 workspace.db "EXPLAIN QUERY PLAN SELECT * FROM functions WHERE name = 'my_function';"

# Vacuum database (reclaim space)
sqlite3 workspace.db "VACUUM;"
```

### Caching

```bash
# Enable query result caching
export GENERO_TOOLS_CACHE_TTL=3600

# Cache results in shell script
CACHE_FILE="/tmp/genero_cache.txt"
if [ ! -f "$CACHE_FILE" ] || [ $(find "$CACHE_FILE" -mmin +60) ]; then
  bash query.sh search-functions "*" > "$CACHE_FILE"
fi
grep "my_function" "$CACHE_FILE"
```

---

## Maintenance

### Regular Tasks

**Weekly:**
- Monitor database size: `du -h workspace.db`
- Check for errors: `bash query.sh validate-types`

**Monthly:**
- Rebuild indexes: `sqlite3 workspace.db "REINDEX;"`
- Vacuum database: `sqlite3 workspace.db "VACUUM;"`
- Review unresolved types: `bash query.sh unresolved-types`

**Quarterly:**
- Full regeneration: `bash generate_all.sh /path/to/codebase`
- Archive old databases: `tar czf workspace-backup-$(date +%Y%m%d).tar.gz workspace.db`

### Backup Strategy

```bash
# Daily backup
tar czf workspace-backup-$(date +%Y%m%d).tar.gz workspace.db

# Keep last 30 days
find . -name "workspace-backup-*.tar.gz" -mtime +30 -delete

# Restore from backup
tar xzf workspace-backup-20260329.tar.gz
```

---

## Security

### Database Access Control

```bash
# Restrict database file permissions
chmod 600 workspace.db

# Restrict directory permissions
chmod 700 /path/to/databases

# Verify permissions
ls -la workspace.db
```

### Query Validation

```bash
# Validate query input (prevent injection)
# genero-tools uses parameterized queries (safe by default)

# Example: Safe query
bash query.sh find-function "my_function"

# Example: Pattern with special characters (safe)
bash query.sh search-functions "get_*"
```

### Data Privacy

```bash
# Sensitive data in code references
# genero-tools extracts code references as-is
# Ensure schema files don't contain sensitive data

# Mask sensitive references
bash query.sh find-reference "PASSWORD" | sed 's/PASSWORD/****/g'
```

---

## Logging

### Enable Logging

```bash
# Set log level
export GENERO_TOOLS_LOG_LEVEL="debug"

# Run query with logging
bash query.sh find-function "my_function" 2>&1 | tee query.log

# Check logs
tail -f query.log
```

### Log Format

```
[TIMESTAMP] [LEVEL] [COMPONENT] [ACTION] [RESULT]

Example:
[2026-03-29T10:15:30Z] [INFO] [QUERY] find-function "process_order" → Success
[2026-03-29T10:15:45Z] [DEBUG] [DB] Query executed in 0.5ms
[2026-03-29T10:16:00Z] [WARNING] [CACHE] Cache miss for "get_*"
```

---

## Troubleshooting Guide

### Issue: "Database file not found"

**Cause:** Database not generated

**Solution:**
```bash
bash query.sh create-dbs
bash generate_all.sh /path/to/codebase
```

### Issue: "No results found"

**Cause:** Function doesn't exist or pattern is wrong

**Solution:**
```bash
# Verify function exists
grep -r "FUNCTION my_function" --include="*.4gl"

# Try simpler pattern
bash query.sh search-functions "my_*"

# Regenerate database
bash generate_all.sh /path/to/codebase
```

### Issue: "Query timeout"

**Cause:** Query too complex or system under load

**Solution:**
```bash
# Increase timeout
export GENERO_TOOLS_TIMEOUT=60

# Use simpler query
bash query.sh find-function "my_function"

# Check system load
uptime
```

### Issue: "Type resolution not working"

**Cause:** Schema file not found or not processed

**Solution:**
```bash
# Verify schema file exists
ls -la /path/to/codebase/*.sch

# Regenerate with explicit schema
bash generate_all.sh /path/to/codebase /path/to/schema.sch

# Check for unresolved types
bash query.sh unresolved-types
```

---

## Advanced Usage

### Direct Database Queries

```bash
# Query database directly with sqlite3
sqlite3 workspace.db "SELECT name, complexity FROM functions WHERE complexity > 10 ORDER BY complexity DESC;"

# Export results to CSV
sqlite3 -header -csv workspace.db "SELECT name, file_path, complexity FROM functions;" > functions.csv

# Find functions with specific parameter types
sqlite3 workspace.db "SELECT DISTINCT f.name FROM functions f JOIN parameters p ON f.id = p.function_id WHERE p.type = 'STRING';"
```

### Custom Analysis

```python
import sqlite3
import json

# Connect to database
conn = sqlite3.connect('workspace.db')
conn.row_factory = sqlite3.Row
c = conn.cursor()

# Find all functions with complexity > 10
c.execute('SELECT name, file_path, complexity FROM functions WHERE complexity > 10 ORDER BY complexity DESC')
complex_functions = [dict(row) for row in c.fetchall()]

# Export as JSON
with open('complex_functions.json', 'w') as f:
    json.dump(complex_functions, f, indent=2)

conn.close()
```

---

## Related Documentation

- **GENERO_TOOLS_REFERENCE.md** - Query reference and usage guide
- **genero-tools-docs/ARCHITECTURE.md** - System design and components
- **genero-tools-docs/FEATURES.md** - Complete feature list
- **genero-tools-docs/SECURITY.md** - Security considerations

---

## Support

For issues or questions:

1. Check troubleshooting guide above
2. Review logs: `tail -f query.log`
3. Validate database: `bash query.sh validate-types`
4. Regenerate databases: `bash generate_all.sh /path/to/codebase`

