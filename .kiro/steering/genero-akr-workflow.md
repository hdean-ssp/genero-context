# Genero Agent Knowledge Repository (AKR) Workflow

**Purpose:** Practical workflow guide for agents to retrieve, analyze, and commit knowledge about Genero/4GL code artifacts.

**Status:** Implementation Ready  
**Version:** 1.0.0  
**Inclusion:** auto

---

## Quick Reference

### Retrieve Knowledge
```bash
bash retrieve_knowledge.sh --type function --name "process_order"
```

### Commit Knowledge
```bash
bash commit_knowledge.sh --type function --name "process_order" --findings findings.json --action append
```

### Search Knowledge
```bash
bash search_knowledge.sh --query "type resolution"
```

---

## Overview

The Agent Knowledge Repository (AKR) is a shared memory system where agents:
1. **Retrieve** existing analysis before starting work
2. **Analyze** code using genero-tools
3. **Compare** findings with existing knowledge
4. **Commit** new insights to the repository
5. **Build** on previous agent work

**Key Benefit:** Knowledge compounds. Each agent makes the next agent smarter.

---

## Directory Structure

```
.kiro/agent-knowledge/                    # AKR Root
├── README.md                             # Repository overview
├── INDEX.md                              # Master index (auto-updated)
├── SCHEMA.md                             # Knowledge structure
│
├── files/                                # File-level knowledge
│   ├── src_orders_4gl.md
│   ├── src_customers_4gl.md
│   └── ...
│
├── functions/                            # Function-level knowledge
│   ├── process_order.md
│   ├── validate_order.md
│   └── ...
│
├── modules/                              # Module-level knowledge
│   ├── payment_module.md
│   ├── customer_module.md
│   └── ...
│
├── patterns/                             # Discovered patterns
│   ├── naming_conventions.md
│   ├── error_handling.md
│   └── ...
│
├── issues/                               # Known issues & risks
│   ├── type_resolution_issues.md
│   ├── circular_dependencies.md
│   └── ...
│
└── metadata/                             # System metadata
    ├── agents.md                         # Agent activity log
    ├── statistics.md                     # Repository stats
    └── last_updated.txt
```

---

## Knowledge Document Format

All knowledge documents follow this structure:

```markdown
# [Artifact Name]

**Type:** file | function | module | pattern | issue  
**Path:** [Full path to artifact]  
**Last Updated:** [ISO timestamp]  
**Updated By:** [Agent name/ID]  
**Status:** active | deprecated | archived

## Summary
[1-2 sentence overview]

## Key Findings
- Finding 1
- Finding 2
- Finding 3

## Metrics
- Complexity: [value]
- Lines of Code: [value]
- Parameter Count: [value]
- Dependent Count: [value]

## Dependencies
- Calls: [list of functions]
- Called By: [list of functions]
- Related Files: [list of files]

## Type Information
- Parameters: [type details]
- Returns: [type details]
- LIKE References: [resolved types]

## Patterns & Conventions
- Naming: [pattern]
- Error Handling: [approach]
- Validation: [approach]

## Known Issues
- Issue 1: [description]
- Issue 2: [description]

## Recommendations
- Recommendation 1
- Recommendation 2

## Related Knowledge
- [Link to related artifact]
- [Link to related pattern]

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-30 | agent-1 | initial_analysis | Found 12 dependents |
| 2026-03-31 | agent-2 | extended_analysis | Added type resolution |

## Raw Data
[Optional: Raw genero-tools output]
```

---

## Agent Workflow

### Phase 1: Planner Hat - Retrieve Knowledge

**When:** At start of Inception phase, after understanding the task

**Steps:**

1. **Identify Target Artifacts**
   ```bash
   # What files/functions/modules are you analyzing?
   TARGET_FUNCTION="process_order"
   TARGET_FILE="src/orders.4gl"
   TARGET_MODULE="payment"
   ```

2. **Retrieve Existing Knowledge**
   ```bash
   # Check if knowledge exists
   bash retrieve_knowledge.sh --type function --name "$TARGET_FUNCTION"
   bash retrieve_knowledge.sh --type file --path "$TARGET_FILE"
   bash retrieve_knowledge.sh --type module --name "$TARGET_MODULE"
   ```

3. **Review Existing Analysis**
   - Read summary and key findings
   - Check metrics and complexity
   - Review known issues
   - Note recommendations
   - Review analysis history

4. **Compare with Current State**
   ```bash
   # Query current state with genero-tools
   bash query.sh find-function "$TARGET_FUNCTION"
   bash query.sh find-function-dependents "$TARGET_FUNCTION"
   bash query.sh find-function-dependencies "$TARGET_FUNCTION"
   ```

5. **Identify Changes**
   - Has complexity changed?
   - Are there new dependents?
   - Have dependencies changed?
   - Are there new type issues?

6. **Incorporate into Plan**
   - Use existing knowledge as baseline
   - Plan to update knowledge if changed
   - Note what's new or different
   - Document in planning phase

**Output:** Refined understanding of artifact with historical context

---

### Phase 2: Builder Hat - Analyze and Extend

**When:** During Construction phase, while implementing changes

**Steps:**

1. **Perform Current Analysis**
   ```bash
   # Get fresh data from genero-tools
   bash query.sh find-function "$TARGET_FUNCTION"
   bash query.sh find-function-dependencies "$TARGET_FUNCTION"
   bash query.sh find-function-dependents "$TARGET_FUNCTION"
   bash query.sh find-function-resolved "$TARGET_FUNCTION"
   ```

2. **Retrieve Existing Knowledge**
   ```bash
   # Get what we already know
   bash retrieve_knowledge.sh --type function --name "$TARGET_FUNCTION"
   ```

3. **Compare Findings**
   ```bash
   # Use comparison tool (when available)
   bash compare_knowledge.sh --type function --name "$TARGET_FUNCTION"
   ```

4. **Identify New Insights**
   - What's new since last analysis?
   - What changed?
   - What patterns did we discover?
   - What issues did we find?
   - What recommendations do we have?

5. **Document Findings**
   ```json
   {
     "artifact": {
       "type": "function",
       "name": "process_order",
       "path": "src/orders.4gl"
     },
     "new_findings": [
       "Discovered 3 new dependents",
       "Complexity increased from 8 to 10",
       "Type resolution issue with LIKE account.*"
     ],
     "metrics": {
       "complexity": 10,
       "lines_of_code": 55,
       "parameter_count": 1,
       "dependent_count": 15
     },
     "issues": [
       "Type resolution issue with LIKE account.*",
       "15 dependents make changes risky"
     ],
     "recommendations": [
       "Consider breaking into smaller functions",
       "Add comprehensive error handling",
       "Resolve LIKE type references"
     ]
   }
   ```

6. **Prepare for Commit**
   - Save findings to JSON file
   - Prepare analysis history entry
   - Note agent ID and timestamp

**Output:** Structured findings ready for knowledge commit

---

### Phase 3: Reviewer Hat - Validate and Commit

**When:** After analysis is complete, before marking work done

**Steps:**

1. **Validate Findings**
   ```bash
   # Ensure artifact still exists
   bash query.sh find-function "$TARGET_FUNCTION"
   
   # Verify metrics are reasonable
   # Check that all references are valid
   # Confirm no conflicting information
   ```

2. **Decide Commit Action**
   
   **If first analysis of artifact:**
   ```bash
   ACTION="create"
   ```
   
   **If updating existing knowledge:**
   ```bash
   ACTION="append"  # Add new findings to existing knowledge
   ```
   
   **If artifact significantly changed:**
   ```bash
   ACTION="update"  # Replace with new analysis
   ```
   
   **If artifact no longer relevant:**
   ```bash
   ACTION="deprecate"  # Mark as outdated
   ```

3. **Commit Knowledge**
   ```bash
   bash commit_knowledge.sh \
     --type function \
     --name "$TARGET_FUNCTION" \
     --findings findings.json \
     --action "$ACTION"
   ```

4. **Verify Commit**
   ```bash
   # Retrieve to confirm it was saved
   bash retrieve_knowledge.sh --type function --name "$TARGET_FUNCTION"
   ```

5. **Update Related Knowledge**
   - If function calls other functions, update their knowledge
   - If function is called by others, update their knowledge
   - If patterns discovered, create/update pattern knowledge
   - If issues found, create/update issue knowledge

6. **Log Activity**
   - Agent ID recorded automatically
   - Timestamp recorded automatically
   - Action recorded in analysis history
   - Statistics updated automatically

**Output:** Knowledge committed and available for next agent

---

## Knowledge Types & Examples

### 1. Function-Level Knowledge

**File:** `functions/process_order.md`

**When to Create:**
- Analyzing a specific function
- Function is complex or has many dependents
- Function has known issues
- Function is frequently modified

**What to Include:**
- Function signature and metrics
- What it calls (dependencies)
- What calls it (dependents)
- Type information
- Known issues
- Recommendations

**Example:**
```markdown
# process_order

**Type:** function  
**Path:** src/orders.4gl  
**Last Updated:** 2026-03-31T14:22:15Z  
**Updated By:** agent-2  
**Status:** active

## Summary
Processes customer orders with validation and persistence. Critical function with 15 dependents.

## Key Findings
- 15 functions depend on this function
- Complexity increased from 8 to 10 in recent changes
- Type resolution issue with LIKE account.* parameter
- No comprehensive error handling

## Metrics
- Complexity: 10
- Lines of Code: 55
- Parameter Count: 1
- Dependent Count: 15

## Dependencies
- Calls: validate_order, save_order, log_message
- Called By: process_batch, handle_request, api_endpoint, ...
- Related Files: src/validators.4gl, src/database.4gl

## Type Information
- Parameters: order_id (INTEGER)
- Returns: status (INTEGER)
- LIKE References: None resolved

## Patterns & Conventions
- Naming: verb_noun (process_order)
- Error Handling: return status code
- Validation: validate before process

## Known Issues
- 15 dependents make changes risky
- No type resolution for LIKE references
- Limited error handling

## Recommendations
- Consider breaking into smaller functions
- Add comprehensive error handling
- Document parameter constraints
- Resolve LIKE type references

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-30 | agent-1 | initial_analysis | Found 12 dependents |
| 2026-03-31 | agent-2 | extended_analysis | Added type resolution, found 3 new dependents |
```

### 2. File-Level Knowledge

**File:** `files/src_orders_4gl.md`

**When to Create:**
- Analyzing an entire file
- File has multiple functions
- File has file-level patterns
- File has known issues

**What to Include:**
- File purpose
- All functions in file
- File-level patterns
- Dependencies on other files
- Known issues
- Recommendations

### 3. Pattern Knowledge

**File:** `patterns/error_handling.md`

**When to Create:**
- Discovered a pattern used across multiple functions
- Pattern is important for consistency
- Pattern has variations
- Pattern has anti-patterns to avoid

**What to Include:**
- Pattern description
- Where pattern is used
- Pattern variations
- When to use
- Anti-patterns to avoid
- Examples

**Example:**
```markdown
# Error Handling Pattern

**Type:** pattern  
**Status:** active

## Summary
Standard error handling approach used across order processing functions.

## Pattern Description
Functions return status codes instead of raising exceptions:
- 0 = success
- 1 = validation error
- 2 = database error
- 3 = system error

## Where Used
- process_order
- validate_order
- save_order
- process_batch

## Variations
- Some functions return detailed error messages
- Some functions log errors before returning
- Some functions retry on transient errors

## When to Use
- For functions that can fail gracefully
- For functions called by multiple callers
- For functions in critical paths

## Anti-Patterns to Avoid
- Mixing return codes with exceptions
- Inconsistent error code meanings
- Silent failures (no logging)
- Unhandled exceptions

## Examples
See: process_order, validate_order
```

### 4. Issue Knowledge

**File:** `issues/type_resolution_issues.md`

**When to Create:**
- Found a problem affecting multiple artifacts
- Problem is recurring
- Problem has workarounds
- Problem needs fixing

**What to Include:**
- Issue description
- Affected artifacts
- Root cause
- Impact assessment
- Workarounds
- Recommended fixes

---

## Workflow Integration Points

### In Planner Hat (Inception Phase)

**Add to Step 3: Retrieve Existing Knowledge**

```markdown
### Step 3a: Retrieve Existing Knowledge

**When:** After understanding task, before planning

**Actions:**
1. Identify target artifacts (files, functions, modules)
2. Query Agent Knowledge Repository
3. Retrieve existing analysis and findings
4. Compare with current genero-tools data
5. Identify what's new or changed
6. Incorporate existing knowledge into plan

**Commands:**
```bash
bash retrieve_knowledge.sh --type function --name "target_function"
bash retrieve_knowledge.sh --type file --path "target_file.4gl"
bash retrieve_knowledge.sh --type module --name "target_module"
```

**Output:** Refined understanding with historical context
```

### In Builder Hat (Construction Phase)

**Add to Code Generation Part 2: Generation**

```markdown
### Step 5: Compare with Existing Knowledge

**When:** After implementing changes

**Actions:**
1. Retrieve existing knowledge about modified artifacts
2. Compare current analysis with existing knowledge
3. Identify new findings
4. Document changes and new insights
5. Prepare findings for commit

**Commands:**
```bash
bash retrieve_knowledge.sh --type function --name "modified_function"
bash compare_knowledge.sh --type function --name "modified_function"
```

**Output:** Structured findings ready for commit
```

### In Reviewer Hat (Operation Phase)

**Add to Validation**

```markdown
### Step 6: Commit Knowledge to Repository

**When:** After validating changes

**Actions:**
1. Validate findings against current code
2. Decide commit action (create/append/update/deprecate)
3. Commit knowledge to repository
4. Verify commit was successful
5. Update related knowledge documents

**Commands:**
```bash
bash commit_knowledge.sh \
  --type function \
  --name "modified_function" \
  --findings findings.json \
  --action append
```

**Output:** Knowledge committed and available for next agent
```

---

## Practical Examples

### Example 1: Analyzing a Function

**Scenario:** Agent needs to modify `process_order()` function

**Step 1: Retrieve Knowledge (Planner Hat)**
```bash
bash retrieve_knowledge.sh --type function --name "process_order"

# Output shows:
# - 15 dependents (high risk)
# - Complexity: 10 (moderate)
# - Known issue: Type resolution problem
# - Previous agent found 3 new dependents recently
```

**Step 2: Plan with Context**
- Understand why it's complex
- Know about the 15 dependents
- Aware of type resolution issue
- Plan to test all 15 dependents

**Step 3: Analyze (Builder Hat)**
```bash
bash query.sh find-function "process_order"
bash query.sh find-function-dependents "process_order"
bash query.sh find-function-resolved "process_order"

# Compare with existing knowledge
bash compare_knowledge.sh --type function --name "process_order"

# Findings:
# - Complexity now 11 (increased)
# - 16 dependents (1 new)
# - Type resolution still unresolved
```

**Step 4: Commit (Reviewer Hat)**
```bash
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action append

# Knowledge updated with:
# - New complexity metric
# - New dependent discovered
# - Confirmed type resolution issue
# - Analysis history updated
```

**Result:** Next agent will know about the new dependent and increased complexity

---

### Example 2: Discovering a Pattern

**Scenario:** Agent notices error handling pattern across multiple functions

**Step 1: Identify Pattern**
- process_order returns status codes
- validate_order returns status codes
- save_order returns status codes
- All use same error code meanings

**Step 2: Create Pattern Knowledge**
```bash
bash commit_knowledge.sh \
  --type pattern \
  --name "error_handling" \
  --findings pattern_findings.json \
  --action create
```

**Step 3: Link to Functions**
- Update process_order knowledge: "See pattern: error_handling"
- Update validate_order knowledge: "See pattern: error_handling"
- Update save_order knowledge: "See pattern: error_handling"

**Result:** Future agents understand the pattern and can follow it consistently

---

### Example 3: Finding an Issue

**Scenario:** Agent discovers type resolution problem affecting multiple functions

**Step 1: Identify Issue**
- LIKE account.* not resolved in process_order
- LIKE account.* not resolved in validate_order
- LIKE customer.* not resolved in process_customer

**Step 2: Create Issue Knowledge**
```bash
bash commit_knowledge.sh \
  --type issue \
  --name "type_resolution_issues" \
  --findings issue_findings.json \
  --action create
```

**Step 3: Link to Affected Functions**
- Update process_order knowledge: "Known issue: type_resolution_issues"
- Update validate_order knowledge: "Known issue: type_resolution_issues"
- Update process_customer knowledge: "Known issue: type_resolution_issues"

**Result:** Future agents are aware of the issue and can plan accordingly

---

## Commands Reference

### Retrieve Knowledge

```bash
# Find knowledge about a function
bash retrieve_knowledge.sh --type function --name "process_order"

# Find knowledge about a file
bash retrieve_knowledge.sh --type file --path "src/orders.4gl"

# Find knowledge about a module
bash retrieve_knowledge.sh --type module --name "payment"

# Find knowledge about a pattern
bash retrieve_knowledge.sh --type pattern --name "error_handling"

# Find knowledge about an issue
bash retrieve_knowledge.sh --type issue --name "circular_dependencies"

# Get analysis history
bash get_history.sh --type function --name "process_order"
```

### Commit Knowledge

```bash
# Create new knowledge
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action create

# Append to existing knowledge
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action append

# Update existing knowledge
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action update

# Mark as deprecated
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action deprecate
```

### Search Knowledge

```bash
# Search across all knowledge
bash search_knowledge.sh --query "type resolution"

# Search in specific type
bash search_knowledge.sh --type function --query "complexity"

# Search in specific category
bash search_knowledge.sh --category issues --query "circular"
```

### Manage Knowledge

```bash
# Validate knowledge consistency
bash validate_knowledge.sh

# Update artifact status
bash update_status.sh --type function --name "process_order" --status deprecated

# Archive old knowledge
bash archive_knowledge.sh --older-than 90

# Get repository statistics
bash get_statistics.sh
```

---

## Best Practices

### 1. Always Retrieve First

**Before analyzing an artifact, always check if knowledge exists:**
```bash
bash retrieve_knowledge.sh --type function --name "target_function"
```

**Why:** Avoid redundant analysis and build on previous work

### 2. Compare Before Committing

**Always compare current findings with existing knowledge:**
```bash
bash compare_knowledge.sh --type function --name "target_function"
```

**Why:** Identify what's new and what's changed

### 3. Append, Don't Replace

**Use `--action append` to preserve analysis history:**
```bash
bash commit_knowledge.sh --action append
```

**Why:** Keep historical context and track how artifact evolved

### 4. Link Related Knowledge

**When creating knowledge, link to related artifacts:**
- If analyzing a function, link to functions it calls
- If analyzing a file, link to functions in the file
- If discovering a pattern, link to functions using it
- If finding an issue, link to affected functions

**Why:** Create a knowledge graph that helps future agents

### 5. Document Metrics

**Always include quantitative metrics:**
- Complexity
- Lines of Code
- Parameter Count
- Dependent Count

**Why:** Helps identify high-risk artifacts and track changes

### 6. Include Analysis History

**Always update analysis history with:**
- Date (ISO timestamp)
- Agent ID
- Action taken
- Notes about findings

**Why:** Shows how artifact evolved and who analyzed it

### 7. Be Specific in Recommendations

**Instead of:** "Improve error handling"  
**Write:** "Add try-catch for database errors and return status code 2"

**Why:** Makes recommendations actionable for next agent

---

## Knowledge Lifecycle

### States

```
DRAFT (being created)
  ↓
ACTIVE (ready for use)
  ↓
UPDATED (new findings added)
  ↓
DEPRECATED (artifact changed, needs review)
  ↓
ARCHIVED (no longer relevant)
```

### When to Update Status

**ACTIVE → UPDATED**
- New findings appended
- Existing knowledge preserved
- Analysis history updated

**ACTIVE → DEPRECATED**
- Artifact significantly changed
- Knowledge no longer accurate
- Marked for re-analysis

**DEPRECATED → ACTIVE**
- Re-analyzed and updated
- New findings incorporated
- Status reset to ACTIVE

**ANY → ARCHIVED**
- Artifact removed from codebase
- Knowledge no longer relevant
- Preserved for historical reference

---

## Troubleshooting

### Knowledge Not Found

**Problem:** `retrieve_knowledge.sh` returns empty

**Solutions:**
1. Check artifact name spelling
2. Check artifact type (function vs file vs module)
3. Check if knowledge has been created yet
4. Search for similar artifacts: `bash search_knowledge.sh --query "partial_name"`

### Conflicting Knowledge

**Problem:** Different findings from different agents

**Solution:**
- Use `--action append` to preserve both findings
- Include analysis history to show when each finding was made
- Add notes explaining differences
- Let future agents decide which finding is more relevant

### Stale Knowledge

**Problem:** Knowledge is outdated

**Solution:**
1. Retrieve current state with genero-tools
2. Compare with existing knowledge
3. If significantly different, use `--action update`
4. If slightly different, use `--action append`
5. Update status to UPDATED

### Storage Growing

**Problem:** Repository getting too large

**Solution:**
1. Archive old knowledge: `bash archive_knowledge.sh --older-than 90`
2. Remove deprecated knowledge: `bash cleanup_knowledge.sh --status deprecated`
3. Compress historical data: `bash compress_knowledge.sh`

---

## Integration with Existing Workflows

### Planner Hat Integration

**Current:** Understand task and plan approach

**New:** Also retrieve existing knowledge about target artifacts

**Benefit:** Start with refined context instead of raw code

### Builder Hat Integration

**Current:** Implement changes and test

**New:** Also compare findings with existing knowledge

**Benefit:** Identify what's new and what changed

### Reviewer Hat Integration

**Current:** Validate quality and approve

**New:** Also commit knowledge to repository

**Benefit:** Share insights with all future agents

---

## Success Indicators

### For Individual Agents
- ✅ Retrieve knowledge before analyzing
- ✅ Compare findings with existing knowledge
- ✅ Commit findings after analysis
- ✅ Link related artifacts
- ✅ Include metrics and recommendations

### For Team
- ✅ Knowledge repository growing
- ✅ Agents using existing knowledge
- ✅ Patterns being discovered
- ✅ Issues being tracked
- ✅ Analysis time decreasing

### For Codebase
- ✅ Comprehensive artifact documentation
- ✅ Known issues documented
- ✅ Patterns identified
- ✅ Recommendations available
- ✅ Change impact understood

---

## Related Documentation

- **genero-agent-knowledge-repository.md** - Concept and architecture
- **genero-context-workflow.md** - Agent workflow (to be updated)
- **genero-context-operations.md** - Operations guide (to be updated)
- **genero-context-queries.md** - Query reference
- **GENERO_TOOLS_REFERENCE.md** - Tool reference

---

## Next Steps

1. **Create Directory Structure**
   ```bash
   mkdir -p .kiro/agent-knowledge/{files,functions,modules,patterns,issues,metadata}
   ```

2. **Create Schema Documents**
   - SCHEMA.md - Knowledge structure
   - README.md - Repository overview
   - INDEX.md - Master index

3. **Create Scripts**
   - retrieve_knowledge.sh
   - commit_knowledge.sh
   - search_knowledge.sh
   - compare_knowledge.sh
   - Other management scripts

4. **Integrate with Workflows**
   - Update genero-context-workflow.md
   - Update genero-context-operations.md
   - Add knowledge retrieval to Planner Hat
   - Add knowledge commit to Reviewer Hat

5. **Test and Validate**
   - Test retrieval with sample knowledge
   - Test commit with sample findings
   - Validate schema compliance
   - Test search functionality

6. **Pilot with Real Workflows**
   - Use with actual agent tasks
   - Gather feedback
   - Refine based on usage
   - Iterate and improve

