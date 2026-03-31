# Genero Context Framework: Operations & Troubleshooting

**Purpose**: Error handling, fallback strategies, configuration, and troubleshooting guide

**Inclusion**: auto

---

## Handling Incomplete genero-tools Output

**genero-tools reflects what it could extract and index. Gaps are normal and expected — they are not automatically code defects.**

### The Investigation Obligation

When genero-tools returns incomplete, unknown, or unresolved data, you are **required** to investigate before drawing any conclusion. Do not report a tool limitation as a code problem.

### Common Gaps and How to Investigate

#### Unresolved LIKE Reference

```
genero-tools output: LIKE account.* → unresolved
```

**This means**: The schema for `account` was not in the genero-tools database when it was built.

**Investigate:**
```bash
# 1. Find the DEFINE statement in source
grep -n "LIKE account\." path/to/file.4gl

# 2. Look for the schema file
find . -name "*.sch" | xargs grep -l "account" 2>/dev/null
find $BRODIR -name "account.sch" 2>/dev/null

# 3. Check if the table is referenced elsewhere
grep -r "account\." --include="*.4gl" | head -10
```

**Conclusion:**
- If schema file exists and table is valid → **tool gap** (schema not indexed). Note it, don't flag as defect.
- If no schema and no evidence of table → **potential code issue**. Investigate further.

#### Empty Dependency List

```
genero-tools output: find-function-dependencies "my_function" → []
```

**This means**: genero-tools found no CALL statements it could resolve.

**Investigate:**
```bash
# Read the actual function body
grep -n "CALL\|LET.*=.*(" path/to/file.4gl | sed -n '/FUNCTION my_function/,/END FUNCTION/p'

# Or extract the full function
sed -n '/^FUNCTION my_function/,/^END FUNCTION/p' path/to/file.4gl
```

**Conclusion:**
- If function body has CALL statements → **tool gap** (calls not indexed). List them manually.
- If function body has no calls → result is correct.

#### Missing Function

```
genero-tools output: find-function "my_function" → not found
```

**Investigate:**
```bash
# Search source files directly
grep -rn "FUNCTION my_function\|PRIVATE FUNCTION my_function" --include="*.4gl"

# Check if it might be in a different module
grep -rn "my_function" --include="*.4gl" | grep -v "CALL\|#"
```

**Conclusion:**
- If found in source → **tool gap** (file not indexed). Use grep result.
- If not found anywhere → function genuinely doesn't exist.

#### Unexpected Complexity Value

```
genero-tools output: complexity=3 (but function looks complex)
```

**Investigate:**
```bash
# Count decision points manually
grep -c "IF\|WHILE\|FOR\|CASE\|WHEN\|AND\|OR" path/to/file.4gl
```

**Conclusion:**
- If manual count differs significantly → database may be stale. Note it.

### Logging Tool Gaps to AKR

Every tool gap you discover should be logged so future agents don't repeat the investigation:

```bash
cat > /tmp/gap.json << 'EOF'
{
  "summary": "genero-tools cannot resolve LIKE account.* — schema not indexed",
  "key_findings": [
    "LIKE account.* appears in functions: process_order, validate_order",
    "account.sch not found in genero-tools database path",
    "Source code is valid — account table confirmed in production schema via grep"
  ],
  "metrics": {"complexity": 0, "lines_of_code": 0, "parameter_count": 0, "dependent_count": 0},
  "known_issues": ["genero-tools cannot resolve account schema — this is a tool indexing gap, not a code defect"],
  "recommendations": [
    "Add account.sch to genero-tools database to enable type resolution",
    "When encountering LIKE account.* treat as valid until schema is indexed"
  ]
}
EOF
bash ~/.kiro/scripts/commit_knowledge.sh --type issue --name "tool_gap_account_schema" --findings /tmp/gap.json --action create
```

---

## AKR Error Logging

**MANDATORY: All significant errors must be logged to the AKR as issues.**

This ensures future agents are aware of recurring problems, tool failures, and environmental issues without having to rediscover them.

### When to Log an Error to AKR

Log to AKR when:
- genero-tools fails repeatedly (not just a one-off timeout)
- A fallback tool also fails or produces unreliable results
- A script error blocks progress
- A permission or environment issue is encountered
- A pattern of failures is detected across multiple operations

Do NOT log every transient error — only those that are likely to recur or affect other agents.

### How to Log an Error to AKR

```bash
# Create an error findings file
cat > /tmp/error_findings.json << 'EOF'
{
  "summary": "Brief description of the error",
  "key_findings": [
    "Error: [exact error message]",
    "Context: [what was being attempted]",
    "Frequency: [how often this occurs]",
    "Impact: [what it blocks]"
  ],
  "metrics": {
    "complexity": 0,
    "lines_of_code": 0,
    "parameter_count": 0,
    "dependent_count": 0
  },
  "known_issues": ["[error description]"],
  "recommendations": [
    "Workaround: [what to do instead]",
    "Fix: [how to resolve permanently]"
  ]
}
EOF

# Commit as an issue
bash ~/.kiro/scripts/commit_knowledge.sh \
  --type issue \
  --name "error_[short_description]" \
  --findings /tmp/error_findings.json \
  --action create
```

### Error Naming Convention

Use descriptive, searchable names:
- `error_genero_tools_timeout` — genero-tools query timeouts
- `error_akr_lock_timeout` — AKR file lock timeouts
- `error_permission_denied_akr` — permission issues on AKR path
- `error_missing_brodir` — BRODIR environment variable not set

### Check for Known Errors Before Starting

At the start of each task, check if known errors exist that might affect your work:

```bash
bash ~/.kiro/scripts/search_knowledge.sh --category issues --query "error"
bash ~/.kiro/scripts/search_knowledge.sh --category issues --query "genero_tools"
```

### Error Logging Examples

**genero-tools timeout:**
```bash
cat > /tmp/error_findings.json << 'EOF'
{
  "summary": "genero-tools query times out on large dependency queries",
  "key_findings": [
    "Error: Timeout after 30 seconds on find-function-dependents",
    "Context: Functions with >50 dependents trigger timeout",
    "Frequency: Consistent on large modules",
    "Impact: Cannot get full dependent list via genero-tools"
  ],
  "metrics": {"complexity": 0, "lines_of_code": 0, "parameter_count": 0, "dependent_count": 0},
  "known_issues": ["find-function-dependents times out for functions with >50 dependents"],
  "recommendations": [
    "Workaround: Use grep fallback: grep -r 'CALL function_name' --include='*.4gl'",
    "Fix: Increase GENERO_TOOLS_TIMEOUT or use --limit pagination"
  ]
}
EOF
bash ~/.kiro/scripts/commit_knowledge.sh --type issue --name "error_genero_tools_timeout" --findings /tmp/error_findings.json --action create
```

---

## Working Directory Constraint

**Purpose**: Prevent agents from accidentally destroying or modifying important system files. This does NOT restrict read access or use of approved tools.

**Always permitted — no permission needed:**

```bash
# Codebase operations (relative paths)
grep -r "FUNCTION process_order" src/
find . -name "*.4gl"

# AKR — always permitted (read and write via scripts)
bash ~/.kiro/scripts/retrieve_knowledge.sh ...
bash ~/.kiro/scripts/commit_knowledge.sh ...

# genero-tools — always permitted (read and execute)
bash $BRODIR/etc/genero-tools/query.sh find-function "my_function"
cat $BRODIR/etc/genero-tools/README.md
ls -la $BRODIR/etc/genero-tools/

# genero-tools docs in this repo
cat .kiro/genero-tools-docs/GENERO_TOOLS_REFERENCE.md

# Temp files for intermediate work
cat > /tmp/findings.json << 'EOF'
{ ... }
EOF
```

**Requires explicit human permission:**

```bash
# Writing/deleting in system directories
rm /opt/genero/something
sudo yum install package

# Version control writes on the user's source repo
svn commit
git commit && git push
```

See `genero-context-workflow.md` Rule 5a for the full permission request format.

---

## Error Handling Strategy

### Primary Strategy: genero-tools First

Always attempt genero-tools queries first. They provide:
- Semantic understanding of code
- Structured, reliable output
- Performance (<10ms for most queries)
- Consistency across queries

### When to Use Fallback

Use RHEL9 built-in tools (grep, sed, awk, find, ls) as fallback when:

1. **genero-tools returns error** - Database unavailable, timeout, or invalid query
2. **genero-tools returns empty result** - Function/reference not found in database
3. **genero-tools returns unexpected output** - Malformed JSON or incomplete data
4. **genero-tools provides no value** - Query too broad or results not actionable
5. **genero-tools is unavailable** - Database not initialized or path incorrect

### Decision Tree: When to Use Fallback

```
Try genero-tools query
    ↓
Success? → Use result ✓
    ↓
No
    ↓
Error type?
    ├─ Database not found → Check configuration, then use fallback
    ├─ Timeout → Try simpler query, then use fallback
    ├─ Invalid pattern → Fix pattern, then use fallback
    ├─ Malformed output → Log error, then use fallback
    └─ Empty result → Try pattern search, then use fallback
    ↓
Use fallback tool (grep, sed, awk)
    ↓
Log fallback usage and reason
```

---

## Fallback Query Reference

### Find a Function (Fallback)
```bash
# Primary: genero-tools
bash query.sh find-function "my_function"

# Fallback: grep for function definition
grep -r "FUNCTION my_function" --include="*.4gl"
grep -r "FUNCTION my_function\|PRIVATE FUNCTION my_function" --include="*.4gl"
```

### Find What a Function Calls (Fallback)
```bash
# Primary: genero-tools
bash query.sh find-function-dependencies "my_function"

# Fallback: grep for function calls within function body
# 1. Find function definition
grep -n "FUNCTION my_function" file.4gl
# 2. Extract function body (from start line to END FUNCTION)
sed -n '/FUNCTION my_function/,/END FUNCTION/p' file.4gl
# 3. Find function calls (pattern: CALL function_name or function_name())
grep -E "CALL [a-z_]+|[a-z_]+\(" | grep -v "FUNCTION\|END FUNCTION"
```

### Find What Calls a Function (Fallback)
```bash
# Primary: genero-tools
bash query.sh find-function-dependents "my_function"

# Fallback: grep for function calls across all files
grep -r "CALL my_function\|my_function(" --include="*.4gl"
# Filter out function definition itself
grep -r "CALL my_function\|my_function(" --include="*.4gl" | grep -v "FUNCTION my_function"
```

### List All Functions in a File (Fallback)
```bash
# Primary: genero-tools
bash query.sh list-file-functions "path/to/file.4gl"

# Fallback: grep for all function definitions
grep -n "^FUNCTION\|^PRIVATE FUNCTION" path/to/file.4gl
# Extract function names
grep -n "^FUNCTION\|^PRIVATE FUNCTION" path/to/file.4gl | sed 's/.*FUNCTION //' | awk '{print $1}'
```

### Find Code References (Fallback)
```bash
# Primary: genero-tools
bash query.sh find-reference "PRB-299"

# Fallback: grep for reference pattern
grep -r "PRB-299\|EH100512\|BUG-\|ISSUE-" --include="*.4gl" --include="*.md"
# With context
grep -r "PRB-299" --include="*.4gl" -B 2 -A 2
```

### Find Author Information (Fallback)
```bash
# Primary: genero-tools
bash query.sh find-author "Author Name"

# Fallback: SVN log for author modifications
svn log --search "Author Name" -v
# Or check file history
svn log path/to/file.4gl | grep "Author Name"
```

### Search Functions by Pattern (Fallback)
```bash
# Primary: genero-tools
bash query.sh search-functions "get_*"

# Fallback: grep with regex
grep -r "^FUNCTION get_\|^PRIVATE FUNCTION get_" --include="*.4gl"
# Extract just function names
grep -r "^FUNCTION get_\|^PRIVATE FUNCTION get_" --include="*.4gl" | sed 's/.*FUNCTION //' | awk '{print $1}' | sort -u
```

---

## Common Errors and Solutions

### Error 1: Function Not Found

**Symptom:**
```bash
bash query.sh find-function "nonexistent_function"
# Returns: empty result or error
```

**Causes:**
- Function name misspelled
- Function doesn't exist
- Function is in different module

**Solution:**
```bash
# 1. Check function name spelling
grep -r "nonexistent_function" --include="*.4gl"

# 2. Try pattern search
bash query.sh search-functions "*nonexistent*"

# 3. If still not found, search with grep
grep -r "FUNCTION.*nonexistent" --include="*.4gl"

# 4. Log the issue
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Function not found: nonexistent_function" >> agent.log
```

---

### Error 2: Database Not Found

**Symptom:**
```bash
bash query.sh find-function "my_function"
# Error: genero-tools database not found
# Error: GENERO_TOOLS_DB_PATH not set or invalid
```

**Causes:**
- genero-tools not installed
- Database path not configured
- Database corrupted

**Solution:**
```bash
# 1. Verify database path
echo $GENERO_TOOLS_DB_PATH
ls -la $GENERO_TOOLS_DB_PATH

# 2. Check if genero-tools is installed
which query.sh
ls -la /opt/genero-tools/

# 3. If not installed, use grep-based analysis
grep -r "FUNCTION" --include="*.4gl" | head -20

# 4. Log warning and continue with fallback
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] WARNING: genero-tools unavailable, using grep-based analysis" >> agent.log
```

---

### Error 3: Query Timeout

**Symptom:**
```bash
bash query.sh find-function-dependents "large_function"
# Timeout after 30 seconds
```

**Causes:**
- Query too complex
- Database too large
- System under load

**Solution:**
```bash
# 1. Try simpler query
bash query.sh find-function "large_function"

# 2. Increase timeout if possible
GENERO_TOOLS_TIMEOUT=60 bash query.sh find-function-dependents "large_function"

# 3. Use grep for faster results
grep -r "CALL large_function\|large_function(" --include="*.4gl" | wc -l

# 4. For large result sets, use pagination
bash query.sh find-function-dependents "large_function" --limit 10 --offset 0

# 5. Log the timeout
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Query timeout: find-function-dependents large_function" >> agent.log
```

---

### Error 4: Invalid Pattern

**Symptom:**
```bash
bash query.sh search-functions "invalid[pattern"
# Error: Invalid regex pattern
```

**Causes:**
- Special characters not escaped
- Invalid regex syntax
- Unsupported pattern

**Solution:**
```bash
# 1. Escape special characters
bash query.sh search-functions "invalid\[pattern"

# 2. Use simpler pattern
bash query.sh search-functions "invalid*"

# 3. Use grep with proper escaping
grep -r "invalid\[pattern\]" --include="*.4gl"

# 4. Use find for file-based search
find . -name "*.4gl" -exec grep -l "invalid" {} \;

# 5. Log the error
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Invalid pattern: invalid[pattern" >> agent.log
```

---

### Error 5: Malformed Output

**Symptom:**
```bash
bash query.sh find-function "my_function" | jq .
# Error: parse error
```

**Causes:**
- genero-tools version mismatch
- Database corruption
- Output truncation

**Solution:**
```bash
# 1. Check genero-tools version
bash query.sh --version

# 2. Verify database integrity
bash query.sh validate-types

# 3. Use grep-based analysis
grep -n "FUNCTION my_function" --include="*.4gl" -r

# 4. Log error and continue with fallback
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Malformed genero-tools output" >> agent.log
```

---

## Fallback Tools Reference

### grep - Search for text patterns

**Basic search:**
```bash
grep "pattern" file.txt
```

**Recursive search:**
```bash
grep -r "pattern" directory/
```

**Case-insensitive:**
```bash
grep -i "pattern" file.txt
```

**Show line numbers:**
```bash
grep -n "pattern" file.txt
```

**Show context (2 lines before and after):**
```bash
grep -B 2 -A 2 "pattern" file.txt
```

**Exclude patterns:**
```bash
grep -v "exclude_pattern" file.txt
```

**Count matches:**
```bash
grep -c "pattern" file.txt
```

**Only filenames:**
```bash
grep -l "pattern" *.4gl
```

---

### sed - Stream editor for text transformation

**Extract lines between patterns:**
```bash
sed -n '/START/,/END/p' file.txt
```

**Replace text:**
```bash
sed 's/old/new/' file.txt
```

**Delete lines:**
```bash
sed '/pattern/d' file.txt
```

**Extract specific line range:**
```bash
sed -n '10,20p' file.txt
```

**In-place editing:**
```bash
sed -i 's/old/new/' file.txt
```

---

### awk - Text processing and analysis

**Extract specific columns:**
```bash
awk '{print $1, $3}' file.txt
```

**Filter by condition:**
```bash
awk '$2 > 100 {print $1}' file.txt
```

**Count occurrences:**
```bash
awk '{count[$1]++} END {for (word in count) print word, count[word]}' file.txt
```

**Extract function names from grep output:**
```bash
grep "FUNCTION" file.4gl | awk '{print $2}'
```

---

### find - Search for files

**Find files by name:**
```bash
find . -name "*.4gl"
```

**Find files modified in last 7 days:**
```bash
find . -name "*.4gl" -mtime -7
```

**Find files by size:**
```bash
find . -name "*.4gl" -size +1M
```

**Execute command on found files:**
```bash
find . -name "*.4gl" -exec grep -l "pattern" {} \;
```

---

### ls - List files with details

**List with details:**
```bash
ls -la
```

**Sort by modification time:**
```bash
ls -lt
```

**Show file sizes in human-readable format:**
```bash
ls -lh
```

**Recursive listing:**
```bash
ls -R
```

**Count files:**
```bash
ls -1 | wc -l
```

---

## Best Practices for Fallback Usage

### Practice 1: Log Fallback Usage
Always log when using fallback tools:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [FALLBACK] Using grep for find-function" >> agent.log
```

### Practice 2: Combine Approaches
Use genero-tools for primary analysis, grep for verification:
```bash
# Get function from genero-tools
FUNC_INFO=$(bash query.sh find-function "my_function")

# Verify with grep
grep -q "FUNCTION my_function" $(echo $FUNC_INFO | jq -r '.file_path')
```

### Practice 3: Cache Results
Store fallback results to avoid repeated queries:
```bash
CACHE_FILE="/tmp/function_cache.txt"
if [ ! -f "$CACHE_FILE" ]; then
  grep -r "FUNCTION" --include="*.4gl" > "$CACHE_FILE"
fi
grep "my_function" "$CACHE_FILE"
```

### Practice 4: Handle Large Result Sets
Use pagination and filtering:
```bash
# Get first 10 results
grep -r "FUNCTION" --include="*.4gl" | head -10

# Get next 10 results
grep -r "FUNCTION" --include="*.4gl" | tail -n +11 | head -10
```

### Practice 5: Validate Results
Always validate fallback results before using:
```bash
# Check if result is valid
if [ -z "$RESULT" ]; then
  echo "ERROR: No results found"
  exit 1
fi
```

### Practice 6: Document Fallback Decisions
Explain why fallback was used:
```bash
# genero-tools unavailable, using grep-based analysis
# Reason: Database timeout after 30 seconds
# Fallback: grep -r "FUNCTION" --include="*.4gl"
```

---

## Graceful Degradation Strategy

If genero-tools is unavailable:

### Step 1: Log the Issue
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] genero-tools unavailable: $ERROR_MESSAGE" >> error.log
```

### Step 2: Switch to Fallback
```bash
grep -r "FUNCTION" --include="*.4gl"
```

### Step 3: Reduce Scope
Limit analysis to specific files or patterns:
```bash
grep -r "FUNCTION" src/ --include="*.4gl"
```

### Step 4: Continue Analysis
Don't stop, just use less precise tools:
```bash
# Continue with grep results
# Note: Results may be less accurate than genero-tools
```

### Step 5: Inform User
Explain limitations of fallback analysis:
```bash
echo "Note: Using grep-based analysis (less accurate than genero-tools)"
```

---

## Configuration

### Environment Variables

```bash
# genero-tools Configuration
GENERO_TOOLS_PATH="/opt/genero-tools"
GENERO_TOOLS_DB_PATH="/var/lib/genero-tools/workspace.db"
GENERO_TOOLS_TIMEOUT=30  # seconds

# SVN Configuration (for code review use case)
SVN_REPOSITORY_URL="svn://svn.internal/genero-codebase"
SVN_USERNAME=""  # Leave empty to use SVN credentials
SVN_PASSWORD=""  # Leave empty to use SVN credentials

# Performance Configuration
CACHE_TTL=3600         # 1 hour
MAX_CONCURRENT_QUERIES=5
BATCH_SIZE=100

# Logging Configuration
LOG_LEVEL="info"  # debug, info, warning, error
LOG_PATH="/var/log/genero-context"
```

### Standards Configuration (standards.yaml)

```yaml
standards:
  - id: "naming-functions"
    name: "Function Naming Convention"
    description: "Functions must follow snake_case naming"
    pattern: "^[a-z_][a-z0-9_]*$"
    severity: "high"
    enabled: true
    language: "genero"
    documentation_url: "https://standards.internal/naming"
  
  - id: "max-function-length"
    name: "Maximum Function Length"
    description: "Functions should not exceed 100 lines"
    rule_type: "complexity"
    threshold: 100
    severity: "medium"
    enabled: true
```

### Formatting Configuration (formatting.yaml)

```yaml
formatting:
  - id: "indent-spaces"
    name: "Indentation"
    indent_type: "spaces"
    indent_size: 4
    severity: "medium"
    auto_correctable: true
    enabled: true
  
  - id: "line-length"
    name: "Line Length"
    max_length: 100
    severity: "low"
    auto_correctable: false
    enabled: true
```

---

## Compiled Files: What to Avoid

### Compiled File Types

Genero compiles source code into binary files:
- `.42f` - Compiled form files
- `.42m` - Compiled module files
- `.42r` - Compiled report files

### Why Avoid Compiled Files

1. **Not Human-Readable**: Binary format, cannot be analyzed
2. **genero-tools Won't Work**: Designed for source code (.4gl), not compiled files
3. **Changes Lost**: Any modifications to compiled files are lost on recompilation
4. **No Context**: Compiled files provide no useful context for analysis
5. **Wrong Source of Truth**: Source files (.4gl) are the authoritative version

### What to Do Instead

**Always work with source files:**
```bash
# WRONG: Don't query compiled files
bash query.sh find-function "my_function"  # from .42f

# RIGHT: Query source files
bash query.sh find-function "my_function"  # from .4gl
```

**If you encounter compiled files:**
1. Identify the corresponding source file (.4gl)
2. Query genero-tools on the source file
3. Ignore the compiled file
4. Make changes only to source files

**Example workflow:**
```bash
# 1. Find source file
find . -name "*.4gl" -exec grep -l "my_function" {} \;

# 2. Query genero-tools on source
bash query.sh find-function "my_function"

# 3. Modify source file
# (edit the .4gl file, not the .42f/.42m/.42r)

# 4. Recompile
# (compilation happens automatically or via build process)
```

### Logging Compiled File Encounters

If you encounter compiled files in your analysis:
```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [WARNING] Compiled file encountered: file.42f - using source file instead" >> agent.log
```

---

### Issue: Slow Queries

**Symptom**: Queries taking longer than expected

**Diagnosis:**
```bash
# Check system load
uptime

# Check genero-tools process
ps aux | grep query.sh

# Check database size
du -sh $GENERO_TOOLS_DB_PATH
```

**Solution:**
- Use pagination for large result sets
- Try simpler queries
- Increase timeout
- Check system resources

---

### Issue: Inconsistent Results

**Symptom**: Same query returns different results

**Diagnosis:**
```bash
# Verify database integrity
bash query.sh validate-types

# Check genero-tools version
bash query.sh --version

# Compare with grep results
grep -r "FUNCTION my_function" --include="*.4gl"
```

**Solution:**
- Regenerate database
- Update genero-tools
- Check for concurrent modifications

---

### Issue: Missing Functions

**Symptom**: Function exists but genero-tools doesn't find it

**Diagnosis:**
```bash
# Search with grep
grep -r "FUNCTION my_function" --include="*.4gl"

# Check file encoding
file path/to/file.4gl

# Check for syntax errors
grep -n "FUNCTION\|END FUNCTION" path/to/file.4gl
```

**Solution:**
- Regenerate database
- Check file encoding
- Fix syntax errors
- Verify file is included in database

---

### Issue: Type Resolution Failures

**Symptom**: Type resolution not working

**Diagnosis:**
```bash
# Check for unresolved types
bash query.sh unresolved-types

# Validate types
bash query.sh validate-types

# Check database integrity
bash query.sh validate-types
```

**Solution:**
- Fix missing tables/columns
- Regenerate database
- Update type definitions

---

## Logging Best Practices

### Log Format
```
[TIMESTAMP] [LEVEL] [COMPONENT] [ACTION] [RESULT]
```

### Log Levels
- **DEBUG**: Detailed diagnostic information
- **INFO**: General informational messages
- **WARNING**: Warning messages for potential issues
- **ERROR**: Error messages for failures

### Example Logs
```
[2026-03-29T10:15:30Z] [INFO] [GENERO-TOOLS] Query: find-function "process_order" → Success
[2026-03-29T10:15:45Z] [INFO] [GENERO-TOOLS] Query: find-function-dependents "process_order" → 12 results
[2026-03-29T10:16:00Z] [WARNING] [FALLBACK] Using grep for find-function → Database timeout
[2026-03-29T10:16:15Z] [INFO] [ANALYSIS] Risk identified: 12 dependents need testing
[2026-03-29T10:16:30Z] [ERROR] [GENERO-TOOLS] Malformed output from find-function
```

---

## Performance Tuning

### Optimize Query Performance

**Use specific queries instead of broad searches:**
```bash
# Good: Specific function lookup
bash query.sh find-function "process_order"

# Bad: Broad pattern search
bash query.sh search-functions "*"
```

**Use pagination for large result sets:**
```bash
# Good: Paginated results
bash query.sh unresolved-types --limit 10 --offset 0

# Bad: All results at once
bash query.sh unresolved-types
```

**Cache results to avoid repeated queries:**
```bash
# Good: Cache results
CACHE_FILE="/tmp/functions.txt"
if [ ! -f "$CACHE_FILE" ]; then
  bash query.sh search-functions "*" > "$CACHE_FILE"
fi

# Bad: Query every time
bash query.sh search-functions "*"
```

---

## Phase 2 AKR Troubleshooting

### Issue: Metadata Updates Failing

**Symptom**: INDEX.md not updating after commit

**Diagnosis:**
```bash
# Check if update_metadata.sh is executable
ls -la .kiro/update_metadata.sh

# Check logs for errors
tail -20 $GENERO_AKR_BASE_PATH/.logs/akr.log | grep ERROR
```

**Solution:**
- Make script executable: `chmod +x .kiro/update_metadata.sh`
- Check AKR base path exists: `ls -la $GENERO_AKR_BASE_PATH`
- Check permissions: `ls -la $GENERO_AKR_BASE_PATH/metadata/`
- Ask admin to fix permissions if needed

---

### Issue: Conflict Detection Not Working

**Symptom**: Multiple agents write to same artifact, no merge happens

**Diagnosis:**
```bash
# Check if merge_knowledge.sh is executable
ls -la .kiro/merge_knowledge.sh

# Check logs for merge events
grep "Merging knowledge" $GENERO_AKR_BASE_PATH/.logs/akr.log
```

**Solution:**
- Make script executable: `chmod +x .kiro/merge_knowledge.sh`
- Verify file locking is working: `ls -la $GENERO_AKR_BASE_PATH/.locks/`
- Check for stale locks: `find $GENERO_AKR_BASE_PATH/.locks/ -type d -mtime +1`

---

### Issue: Compare Knowledge Returns No Results

**Symptom**: `compare_knowledge.sh` shows "No existing knowledge"

**Diagnosis:**
```bash
# Check if knowledge file exists
ls -la $GENERO_AKR_BASE_PATH/functions/target_function.md

# Check if artifact name is correct
bash retrieve_knowledge.sh --type function --name "target_function"
```

**Solution:**
- Verify artifact name spelling
- Verify artifact type (function vs file vs module)
- Create knowledge first: `bash commit_knowledge.sh --type function --name "target_function" --findings findings.json --action create`
- Then compare: `bash compare_knowledge.sh --type function --name "target_function" --findings findings.json`

---

### Issue: Statistics Show Zero Documents

**Symptom**: `get_statistics.sh` shows all counts as 0

**Diagnosis:**
```bash
# Check if AKR directories exist
ls -la $GENERO_AKR_BASE_PATH/functions/
ls -la $GENERO_AKR_BASE_PATH/files/

# Count documents manually
find $GENERO_AKR_BASE_PATH/functions/ -name "*.md" | wc -l
```

**Solution:**
- Initialize AKR: `bash setup_akr.sh`
- Create sample knowledge: `bash commit_knowledge.sh --type function --name "test" --findings findings.json --action create`
- Run statistics again: `bash get_statistics.sh`

---

### Issue: Lock Timeout on Commit

**Symptom**: "Failed to acquire lock after 30s"

**Diagnosis:**
```bash
# Check for stale locks
ls -la $GENERO_AKR_BASE_PATH/.locks/

# Check lock age
find $GENERO_AKR_BASE_PATH/.locks/ -type d -mmin +30
```

**Solution:**
- Wait 30 seconds and retry (lock will be released)
- If lock is stale (>30 minutes old), ask admin to remove: `rmdir $GENERO_AKR_BASE_PATH/.locks/stale_lock`
- Check if another agent is stuck: `ps aux | grep commit_knowledge`

---

### Issue: Merge Backup Files Accumulating

**Symptom**: Many `.backup.*` files in knowledge directories

**Diagnosis:**
```bash
# Count backup files
find $GENERO_AKR_BASE_PATH -name "*.backup.*" | wc -l

# List recent backups
find $GENERO_AKR_BASE_PATH -name "*.backup.*" -mtime -7
```

**Solution:**
- Backups are normal (created before merge)
- Clean up old backups (>30 days): `find $GENERO_AKR_BASE_PATH -name "*.backup.*" -mtime +30 -delete`
- Or ask admin to clean up: `find $GENERO_AKR_BASE_PATH -name "*.backup.*" -mtime +30 -delete`

---

## Next: Workflow & Agent Behavior

For workflow and agent behavior, see: `genero-context-workflow.md`

For query reference, see: `genero-context-queries.md`

For AKR workflow, see: `genero-akr-workflow.md`
