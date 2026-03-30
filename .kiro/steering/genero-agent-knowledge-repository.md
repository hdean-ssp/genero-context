# Genero Agent Knowledge Repository

**Purpose:** Define a shared knowledge system where agents can commit, retrieve, and build upon analysis of Genero/4GL code artifacts.

**Status:** Concept/Design Phase  
**Version:** 1.0.0  
**Inclusion:** manual

---

## Overview

The Agent Knowledge Repository (AKR) is a structured system that allows agents to:
1. **Commit** refined analysis and insights about code artifacts (files, functions, modules)
2. **Retrieve** existing knowledge to avoid redundant analysis
3. **Append** new findings to existing knowledge rather than starting from scratch
4. **Share** context across all agents in the system

**Key Principle:** Knowledge compounds over time. Each agent's analysis enriches the repository for all future agents.

---

## Problem Statement

### Current State
- Each agent analyzes code independently
- No shared context between agents
- Redundant analysis of same files/functions
- Knowledge is lost after agent execution completes
- No institutional memory of codebase insights

### Desired State
- Agents share refined analysis
- Existing knowledge is retrieved and extended
- Analysis compounds over time
- Institutional memory of codebase
- Faster agent execution through cached insights

### Example Scenario

**Agent 1 (Day 1):**
- Analyzes `process_order()` function
- Discovers it has 12 dependents
- Identifies complexity issues
- Commits findings to repository

**Agent 2 (Day 2):**
- Needs to modify `process_order()`
- Retrieves Agent 1's analysis from repository
- Starts with refined context instead of raw code
- Adds new findings about type resolution
- Appends to existing knowledge

**Agent 3 (Day 3):**
- Needs to refactor `process_order()`
- Retrieves combined knowledge from Agents 1 & 2
- Has complete picture: complexity, dependents, types
- Makes better decisions faster

---

## Architecture

### Directory Structure

```
.kiro/agent-knowledge/                          # Root knowledge repository
├── README.md                                   # Repository overview and usage
├── INDEX.md                                    # Master index of all artifacts
├── SCHEMA.md                                   # Knowledge structure schema
│
├── files/                                      # File-level knowledge
│   ├── src_orders_4gl.md                      # Knowledge about src/orders.4gl
│   ├── src_customers_4gl.md                   # Knowledge about src/customers.4gl
│   └── ...
│
├── functions/                                  # Function-level knowledge
│   ├── process_order.md                       # Knowledge about process_order()
│   ├── validate_order.md                      # Knowledge about validate_order()
│   └── ...
│
├── modules/                                    # Module-level knowledge
│   ├── core_module.md                         # Knowledge about core module
│   ├── payment_module.md                      # Knowledge about payment module
│   └── ...
│
├── patterns/                                   # Codebase patterns
│   ├── naming_conventions.md                  # Naming patterns discovered
│   ├── error_handling.md                      # Error handling patterns
│   ├── validation_patterns.md                 # Validation patterns
│   └── ...
│
├── issues/                                     # Known issues and risks
│   ├── type_resolution_issues.md              # Type resolution problems
│   ├── circular_dependencies.md               # Circular dependency issues
│   └── ...
│
└── metadata/                                   # System metadata
    ├── agents.md                              # Agent activity log
    ├── statistics.md                          # Repository statistics
    └── last_updated.txt                       # Last update timestamp
```

### Knowledge Document Structure

Each knowledge document follows a consistent schema:

```markdown
# [Artifact Name]

**Type:** file | function | module | pattern | issue  
**Path:** [Full path to artifact]  
**Last Updated:** [ISO timestamp]  
**Updated By:** [Agent name/ID]  
**Status:** active | deprecated | archived

## Summary
[1-2 sentence summary of the artifact]

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
- Calls: [list of functions it calls]
- Called By: [list of functions that call it]
- Related Files: [list of related files]

## Type Information
- Parameters: [type details]
- Returns: [type details]
- LIKE References: [resolved types]

## Patterns & Conventions
- Naming: [naming pattern used]
- Error Handling: [error handling approach]
- Validation: [validation approach]

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
| 2026-03-30 | agent-1 | Initial analysis | Found 12 dependents |
| 2026-03-31 | agent-2 | Extended analysis | Added type resolution |

## Raw Data
[Optional: Raw genero-tools output for reference]
```

---

## Knowledge Types

### 1. File-Level Knowledge

**What:** Analysis of a single .4gl file

**Includes:**
- File purpose and responsibility
- All functions in the file
- File-level patterns
- Dependencies on other files
- Known issues specific to file
- Recommendations for changes

**Example:** `files/src_orders_4gl.md`

### 2. Function-Level Knowledge

**What:** Analysis of a specific function

**Includes:**
- Function signature and metrics
- What it calls (dependencies)
- What calls it (dependents)
- Type information and LIKE resolutions
- Complexity assessment
- Known issues
- Refactoring recommendations

**Example:** `functions/process_order.md`

### 3. Module-Level Knowledge

**What:** Analysis of a module (collection of files)

**Includes:**
- Module purpose and scope
- Files in module
- Module dependencies
- Key functions
- Module-level patterns
- Integration points

**Example:** `modules/payment_module.md`

### 4. Pattern Knowledge

**What:** Discovered patterns in the codebase

**Includes:**
- Pattern name and description
- Where pattern is used
- Variations of pattern
- When to use pattern
- Anti-patterns to avoid
- Examples

**Examples:**
- `patterns/naming_conventions.md`
- `patterns/error_handling.md`
- `patterns/validation_patterns.md`

### 5. Issue Knowledge

**What:** Known issues, risks, and problems

**Includes:**
- Issue description
- Affected artifacts
- Root cause (if known)
- Impact assessment
- Workarounds
- Recommended fixes

**Examples:**
- `issues/type_resolution_issues.md`
- `issues/circular_dependencies.md`

---

## Agent Workflow Integration

### Phase 1: Retrieve Existing Knowledge

**When:** At start of Inception phase (Planner Hat)

```bash
# Check if knowledge exists for target artifact
bash retrieve_knowledge.sh --type function --name "process_order"

# Returns:
# - Existing analysis
# - Metrics
# - Known issues
# - Related artifacts
# - Analysis history
```

**Planner Hat Actions:**
1. Query genero-tools for current state
2. Retrieve existing knowledge from repository
3. Compare: Has anything changed since last analysis?
4. If changed: Plan to update knowledge
5. If unchanged: Use existing knowledge as baseline

### Phase 2: Analyze and Extend

**When:** During Construction phase (Builder Hat)

```bash
# Analyze artifact
bash query.sh find-function "process_order"

# Compare with existing knowledge
bash compare_knowledge.sh --type function --name "process_order"

# Identify what's new
# - New dependents?
# - Changed complexity?
# - New type issues?
# - New patterns?
```

**Builder Hat Actions:**
1. Perform analysis using genero-tools
2. Retrieve existing knowledge
3. Identify new findings
4. Prepare knowledge update

### Phase 3: Commit Knowledge

**When:** After analysis is complete (Reviewer Hat)

```bash
# Commit new findings
bash commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings "findings.json" \
  --action "append"

# Options:
# --action append    : Add to existing knowledge
# --action update    : Replace existing knowledge
# --action deprecate : Mark as outdated
```

**Reviewer Hat Actions:**
1. Validate findings
2. Commit to repository
3. Update INDEX.md
4. Log agent activity
5. Update statistics

---

## Knowledge Retrieval

### Query Interface

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

# Search across all knowledge
bash search_knowledge.sh --query "type resolution"

# Get analysis history
bash get_history.sh --type function --name "process_order"
```

### Output Format

```json
{
  "artifact": {
    "type": "function",
    "name": "process_order",
    "path": "src/orders.4gl",
    "status": "active"
  },
  "summary": "Processes customer orders with validation and persistence",
  "metrics": {
    "complexity": 8,
    "lines_of_code": 50,
    "parameter_count": 1,
    "dependent_count": 12
  },
  "dependencies": {
    "calls": ["validate_order", "save_order", "log_message"],
    "called_by": ["process_batch", "handle_request", "api_endpoint"]
  },
  "type_information": {
    "parameters": [{"name": "order_id", "type": "INTEGER"}],
    "returns": [{"name": "status", "type": "INTEGER"}],
    "like_references": []
  },
  "patterns": {
    "naming": "verb_noun (process_order)",
    "error_handling": "return status code",
    "validation": "validate before process"
  },
  "known_issues": [
    "12 dependents make changes risky",
    "No type resolution for LIKE references"
  ],
  "recommendations": [
    "Consider breaking into smaller functions",
    "Add comprehensive error handling",
    "Document parameter constraints"
  ],
  "analysis_history": [
    {
      "date": "2026-03-30T10:15:30Z",
      "agent": "agent-1",
      "action": "initial_analysis",
      "notes": "Found 12 dependents"
    },
    {
      "date": "2026-03-31T14:22:15Z",
      "agent": "agent-2",
      "action": "extended_analysis",
      "notes": "Added type resolution findings"
    }
  ]
}
```

---

## Knowledge Lifecycle

### States

```
DRAFT
  ↓
ACTIVE (in use by agents)
  ↓
UPDATED (new findings added)
  ↓
DEPRECATED (artifact changed, knowledge outdated)
  ↓
ARCHIVED (no longer relevant)
```

### Transitions

**DRAFT → ACTIVE**
- Initial analysis complete
- Validated by reviewer
- Ready for agent use

**ACTIVE → UPDATED**
- New findings appended
- Existing knowledge preserved
- Analysis history updated

**ACTIVE → DEPRECATED**
- Artifact significantly changed
- Knowledge no longer accurate
- Marked for review

**DEPRECATED → ACTIVE**
- Re-analyzed and updated
- New findings incorporated
- Status reset to ACTIVE

**ANY → ARCHIVED**
- Artifact removed from codebase
- Knowledge no longer relevant
- Preserved for historical reference

### Validation Rules

**Before Committing Knowledge:**
1. ✅ Artifact still exists in codebase
2. ✅ Findings are based on current genero-tools data
3. ✅ No conflicting information with existing knowledge
4. ✅ All references are valid
5. ✅ Metrics are within expected ranges

**Before Retrieving Knowledge:**
1. ✅ Knowledge status is ACTIVE or UPDATED
2. ✅ Last update is recent (< 30 days)
3. ✅ Artifact still exists in codebase
4. ✅ No deprecation warnings

---

## Implementation Phases

### Phase 1: Foundation (Weeks 1-2)

**Deliverables:**
- Directory structure created
- Schema defined (SCHEMA.md)
- INDEX.md template
- Basic retrieval script (retrieve_knowledge.sh)
- Basic commit script (commit_knowledge.sh)

**Scope:**
- Manual knowledge entry
- Simple file/function/module types
- Basic retrieval by name/path

### Phase 2: Integration (Weeks 3-4)

**Deliverables:**
- Agent workflow integration
- Automatic knowledge retrieval in Planner Hat
- Automatic knowledge commit in Reviewer Hat
- Analysis history tracking
- Statistics collection

**Scope:**
- Automated retrieval during planning
- Automated commit after analysis
- History tracking
- Basic statistics

### Phase 3: Intelligence (Weeks 5-6)

**Deliverables:**
- Pattern detection
- Issue identification
- Recommendation generation
- Search across knowledge
- Knowledge comparison

**Scope:**
- Automatic pattern discovery
- Issue flagging
- Recommendation suggestions
- Full-text search
- Change detection

### Phase 4: Optimization (Weeks 7-8)

**Deliverables:**
- Performance optimization
- Caching layer
- Incremental updates
- Knowledge pruning
- Archive management

**Scope:**
- Query performance
- Update efficiency
- Storage optimization
- Cleanup procedures

---

## Data Structures

### INDEX.md Format

```markdown
# Agent Knowledge Repository Index

**Last Updated:** [ISO timestamp]  
**Total Artifacts:** [count]  
**Total Knowledge Documents:** [count]

## Files ([count])
- src/orders.4gl - [status] - [last updated]
- src/customers.4gl - [status] - [last updated]

## Functions ([count])
- process_order - [status] - [last updated]
- validate_order - [status] - [last updated]

## Modules ([count])
- payment_module - [status] - [last updated]
- customer_module - [status] - [last updated]

## Patterns ([count])
- naming_conventions - [status] - [last updated]
- error_handling - [status] - [last updated]

## Issues ([count])
- type_resolution_issues - [status] - [last updated]
- circular_dependencies - [status] - [last updated]

## Statistics
- Total Analyses: [count]
- Agents Contributed: [count]
- Average Knowledge Age: [days]
- Most Analyzed Artifact: [name]
```

### SCHEMA.md Format

```markdown
# Knowledge Repository Schema

## Document Structure

All knowledge documents follow this structure:

### Metadata Section
- Type: file | function | module | pattern | issue
- Path: Full path to artifact
- Status: active | deprecated | archived
- Last Updated: ISO timestamp
- Updated By: Agent identifier

### Content Sections
- Summary: 1-2 sentence overview
- Key Findings: Bullet list of discoveries
- Metrics: Quantitative data
- Dependencies: Related artifacts
- Type Information: Type details
- Patterns: Discovered patterns
- Known Issues: Problems identified
- Recommendations: Suggested actions
- Analysis History: Timeline of analyses

### Validation Rules
- All paths must be relative to codebase root
- All timestamps must be ISO 8601 format
- All metrics must be non-negative integers
- All references must point to existing artifacts
- Status must be one of: active, deprecated, archived

## File Naming Convention

- Files: `files/[path_with_underscores].md`
  - Example: `files/src_orders_4gl.md`
- Functions: `functions/[function_name].md`
  - Example: `functions/process_order.md`
- Modules: `modules/[module_name].md`
  - Example: `modules/payment_module.md`
- Patterns: `patterns/[pattern_name].md`
  - Example: `patterns/error_handling.md`
- Issues: `issues/[issue_name].md`
  - Example: `issues/circular_dependencies.md`

## Linking Convention

- Internal links: `[text](../functions/process_order.md)`
- Cross-references: `See also: [validate_order](../functions/validate_order.md)`
- File references: `File: [src/orders.4gl](../files/src_orders_4gl.md)`
```

---

## Integration with Steering Files

### Update to genero-context-workflow.md

Add new section to Planner Hat:

```markdown
### Step 3a: Retrieve Existing Knowledge (NEW)

**When:** After understanding task, before planning

**Actions:**
1. Identify target artifacts (files, functions, modules)
2. Query Agent Knowledge Repository
3. Retrieve existing analysis and findings
4. Compare with current genero-tools data
5. Identify what's new or changed
6. Incorporate existing knowledge into plan

**Command:**
```bash
bash retrieve_knowledge.sh --type function --name "target_function"
```

**Output:** Existing analysis, metrics, issues, recommendations
```

### Update to genero-context-operations.md

Add new section for knowledge management:

```markdown
## Knowledge Repository Operations

### Retrieve Knowledge

```bash
# Find existing knowledge
bash retrieve_knowledge.sh --type function --name "my_function"

# Search across all knowledge
bash search_knowledge.sh --query "type resolution"

# Get analysis history
bash get_history.sh --type function --name "my_function"
```

### Commit Knowledge

```bash
# Commit new findings
bash commit_knowledge.sh \
  --type function \
  --name "my_function" \
  --findings findings.json \
  --action append

# Actions: append (add to existing), update (replace), deprecate (mark outdated)
```

### Manage Knowledge

```bash
# Validate knowledge consistency
bash validate_knowledge.sh

# Update artifact status
bash update_status.sh --type function --name "my_function" --status deprecated

# Archive old knowledge
bash archive_knowledge.sh --older-than 90
```
```

---

## Benefits

### For Agents
- **Faster Analysis:** Start with existing knowledge instead of raw code
- **Better Context:** Understand artifact history and previous findings
- **Smarter Decisions:** Build on previous agent insights
- **Reduced Redundancy:** Avoid re-analyzing same artifacts

### For Teams
- **Institutional Memory:** Knowledge persists across agent executions
- **Knowledge Sharing:** All agents benefit from all previous analyses
- **Pattern Recognition:** Discover codebase patterns over time
- **Risk Awareness:** Know about known issues before making changes

### For Codebase
- **Better Understanding:** Comprehensive artifact documentation
- **Improved Quality:** Recommendations from multiple analyses
- **Issue Tracking:** Known problems documented and tracked
- **Change Impact:** Understand impact of changes on dependent artifacts

---

## Challenges & Solutions

### Challenge 1: Knowledge Staleness

**Problem:** Code changes, but knowledge doesn't update

**Solution:**
- Track artifact modification times
- Flag knowledge as deprecated if artifact changed
- Require re-analysis before using stale knowledge
- Automatic validation on retrieval

### Challenge 2: Conflicting Knowledge

**Problem:** Different agents have different findings

**Solution:**
- Append findings rather than replace
- Track analysis history
- Include confidence levels
- Require validation before committing

### Challenge 3: Storage Growth

**Problem:** Repository grows over time

**Solution:**
- Archive old knowledge
- Compress historical data
- Prune rarely-used artifacts
- Implement retention policies

### Challenge 4: Knowledge Quality

**Problem:** Low-quality or incorrect knowledge

**Solution:**
- Validation rules before commit
- Peer review process
- Confidence scoring
- Regular audits

---

## Success Metrics

### Adoption Metrics
- % of agents using knowledge repository
- % of artifacts with knowledge documents
- Average knowledge age
- Knowledge retrieval frequency

### Quality Metrics
- Knowledge accuracy (vs current code)
- Validation pass rate
- Issue detection rate
- Recommendation usefulness

### Efficiency Metrics
- Time saved by using existing knowledge
- Reduction in redundant analysis
- Faster agent execution
- Improved decision quality

### Growth Metrics
- Total knowledge documents
- Total artifacts analyzed
- Total agents contributing
- Knowledge coverage %

---

## Future Enhancements

### Short Term (Months 1-3)
- Automatic pattern detection
- Issue flagging system
- Knowledge comparison tool
- Search across all knowledge

### Medium Term (Months 4-6)
- Machine learning for pattern recognition
- Automatic recommendation generation
- Knowledge quality scoring
- Predictive issue detection

### Long Term (Months 7-12)
- Cross-codebase knowledge sharing
- Knowledge marketplace
- Automated refactoring suggestions
- Predictive code quality analysis

---

## Getting Started

### Step 1: Create Directory Structure

```bash
mkdir -p .kiro/agent-knowledge/{files,functions,modules,patterns,issues,metadata}
```

### Step 2: Create Schema Documents

```bash
# Create SCHEMA.md
# Create README.md
# Create INDEX.md template
```

### Step 3: Create Retrieval Scripts

```bash
# Create retrieve_knowledge.sh
# Create commit_knowledge.sh
# Create search_knowledge.sh
```

### Step 4: Integrate with Workflows

```bash
# Update genero-context-workflow.md
# Update genero-context-operations.md
# Add knowledge retrieval to Planner Hat
# Add knowledge commit to Reviewer Hat
```

### Step 5: Test and Validate

```bash
# Test retrieval with sample knowledge
# Test commit with sample findings
# Validate schema compliance
# Test search functionality
```

---

## Related Documentation

- **genero-context-workflow.md** - Agent workflow (to be updated)
- **genero-context-operations.md** - Operations guide (to be updated)
- **genero-context-queries.md** - Query reference
- **GENERO_TOOLS_REFERENCE.md** - Tool reference

---

## Next Steps

1. **Review & Feedback:** Get team feedback on concept
2. **Refine Design:** Adjust based on feedback
3. **Create Schema:** Implement SCHEMA.md and INDEX.md
4. **Build Scripts:** Create retrieval and commit scripts
5. **Integrate:** Update workflow files
6. **Pilot:** Test with real agent workflows
7. **Iterate:** Refine based on pilot results

