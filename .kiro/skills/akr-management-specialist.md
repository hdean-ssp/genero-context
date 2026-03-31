# AKR Management Specialist Skill

**Purpose**: Expert guidance for maintaining the Agent Knowledge Repository with focus on deduplication, structure integrity, and sentiment analysis

**Keywords**: AKR, knowledge-management, deduplication, structure, sentiment-analysis, quality-assurance

**Inclusion**: manual

**Version**: 1.0.0

**Status**: Production Ready

---

## Overview

This skill provides specialized expertise for managing the Agent Knowledge Repository (AKR) system. It focuses on three critical areas:

1. **Deduplication** - Preventing and eliminating duplicate knowledge entries
2. **Structure Integrity** - Maintaining consistent, valid document structure
3. **Sentiment Analysis** - Ensuring accurate, unbiased analysis in knowledge documents

The AKR is a shared memory system where agents accumulate knowledge about Genero/4GL code artifacts. Without proper management, it can become cluttered with duplicates, inconsistent structure, and biased analysis.

---

## Part 1: Deduplication Strategy

### Why Deduplication Matters

**Problem**: Multiple agents analyzing the same artifact independently creates duplicates:
- Same function analyzed by Agent 1 and Agent 2 → Two separate knowledge documents
- Same pattern discovered independently → Multiple pattern documents
- Same issue flagged by different agents → Duplicate issue entries

**Impact**:
- Repository bloat (storage waste)
- Conflicting information (which is correct?)
- Confusion for future agents (which document to trust?)
- Maintenance burden (update all duplicates)

### Deduplication Workflow

#### Step 1: Identify Potential Duplicates

**Before creating new knowledge, always check for existing entries:**

```bash
# Search for exact matches
bash ~/.kiro/scripts/search_knowledge.sh --query "exact_artifact_name"

# Search for partial matches
bash ~/.kiro/scripts/search_knowledge.sh --query "partial_name"

# Search by type
bash ~/.kiro/scripts/search_knowledge.sh --type function --query "process_*"

# Search by category
bash ~/.kiro/scripts/search_knowledge.sh --category functions --query "order"
```

**What to look for:**
- Same artifact name (exact match)
- Similar names (typos, variations)
- Same concept (different names)
- Related artifacts (dependencies)

#### Step 2: Analyze Existing Knowledge

**If potential duplicate found, retrieve and analyze:**

```bash
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"
```

**Compare:**
- Artifact name (exact match?)
- Artifact path (same file?)
- Artifact type (function vs pattern vs issue?)
- Content (same findings?)
- Timestamp (when was it created?)
- Agent ID (who created it?)

#### Step 3: Decide on Action

**Three scenarios:**

**Scenario A: Exact Duplicate**
- Same artifact, same findings, different agent
- **Action**: Don't create new document
- **Instead**: Append to existing with `--action append`
- **Benefit**: Preserves analysis history, shows multiple agents confirmed findings

**Scenario B: Partial Duplicate**
- Same artifact, different findings, different agent
- **Action**: Use `--action append` to add new findings
- **Benefit**: Combines insights from multiple agents
- **Note**: Include analysis history to show when each finding was made

**Scenario C: Related but Different**
- Different artifacts, related concepts
- **Action**: Create new document with cross-references
- **Benefit**: Maintains separate documents while linking related knowledge
- **Example**: `process_order` and `validate_order` are different functions but related

#### Step 4: Merge Duplicates (If Found)

**If duplicates already exist in repository:**

```bash
# Compare the two documents
bash ~/.kiro/scripts/compare_knowledge.sh --type function --name "process_order" --findings findings.json

# Merge findings
bash ~/.kiro/scripts/merge_knowledge.sh --type function --name "process_order" --findings findings.json

# Verify merge
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"
```

**Merge Strategy:**
1. Keep the older document as primary
2. Append newer findings to it
3. Preserve all analysis history
4. Create backup before merge
5. Update metadata

### Deduplication Checklist

Before committing any knowledge:

- [ ] Searched for existing knowledge with exact name
- [ ] Searched for similar names (typos, variations)
- [ ] Searched for related artifacts
- [ ] Reviewed existing knowledge if found
- [ ] Compared current findings with existing
- [ ] Decided on action (create vs append)
- [ ] If appending, verified analysis history will be preserved
- [ ] If creating new, verified it's truly different from existing

### Common Deduplication Patterns

#### Pattern 1: Naming Variations

**Problem**: Same artifact, different names
```
process_order.md
processOrder.md
process-order.md
order_processing.md
```

**Solution**:
1. Identify canonical name (use genero-tools output)
2. Keep document with canonical name
3. Merge others into canonical
4. Add aliases in "Related Knowledge" section

#### Pattern 2: Scope Variations

**Problem**: Same concept at different scopes
```
functions/process_order.md (specific function)
patterns/order_processing.md (general pattern)
```

**Solution**:
1. Keep both (different scopes)
2. Link them: "See pattern: order_processing"
3. In pattern, reference: "See function: process_order"

#### Pattern 3: Time-Based Duplicates

**Problem**: Same artifact analyzed at different times
```
2026-03-30: process_order.md (complexity: 8)
2026-03-31: process_order.md (complexity: 10)
```

**Solution**:
1. Keep original document
2. Append new findings with `--action append`
3. Analysis history shows evolution
4. Status remains "active" (not deprecated)

#### Pattern 4: Agent-Based Duplicates

**Problem**: Multiple agents analyze same artifact independently
```
Agent 1: process_order.md (found 12 dependents)
Agent 2: process_order.md (found 15 dependents)
```

**Solution**:
1. Keep Agent 1's document
2. Append Agent 2's findings
3. Analysis history shows both agents' work
4. Metadata shows multiple contributors

---

## Part 2: Structure Integrity

### Why Structure Matters

**Problem**: Inconsistent document structure makes knowledge hard to use:
- Missing sections (no metrics, no recommendations)
- Inconsistent formatting (different date formats)
- Invalid data types (complexity as string instead of number)
- Broken references (links to non-existent artifacts)

**Impact**:
- Agents can't find information they need
- Automated tools fail (can't parse inconsistent structure)
- Quality assessment impossible (missing metrics)
- Maintenance difficult (inconsistent patterns)

### Standard Knowledge Document Structure

**All knowledge documents must follow this structure:**

```markdown
# [Artifact Name]

**Type:** file | function | module | pattern | issue  
**Path:** [Full path to artifact]  
**Last Updated:** [ISO 8601 timestamp]  
**Updated By:** [Agent name/ID]  
**Status:** active | deprecated | archived

## Summary
[1-2 sentence overview of artifact]

## Key Findings
- Finding 1
- Finding 2
- Finding 3

## Metrics
- Complexity: [integer 0-20]
- Lines of Code: [integer]
- Parameter Count: [integer]
- Dependent Count: [integer]

## Dependencies
- Calls: [comma-separated list]
- Called By: [comma-separated list]
- Related Files: [comma-separated list]

## Type Information
- Parameters: [type details]
- Returns: [type details]
- LIKE References: [resolved types or "unresolved"]

## Patterns & Conventions
- Naming: [pattern description]
- Error Handling: [approach description]
- Validation: [approach description]

## Known Issues
- Issue 1: [description]
- Issue 2: [description]

## Recommendations
- Recommendation 1: [specific, actionable]
- Recommendation 2: [specific, actionable]

## Related Knowledge
- [Link to related artifact]
- [Link to related pattern]

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-30 | agent-1 | initial_analysis | [notes] |
| 2026-03-31 | agent-2 | extended_analysis | [notes] |

## Raw Data
[Optional: Raw genero-tools output or additional context]
```

### Structure Validation Rules

#### Rule 1: Required Sections

**Every document must have:**
- [ ] Title (# [Artifact Name])
- [ ] Type metadata (Type, Path, Last Updated, Updated By, Status)
- [ ] Summary section
- [ ] Key Findings section
- [ ] Metrics section (for functions/files)
- [ ] Dependencies section (for functions)
- [ ] Known Issues section
- [ ] Recommendations section
- [ ] Analysis History section

**Optional sections:**
- Type Information (for functions with complex types)
- Patterns & Conventions (for patterns and functions)
- Related Knowledge (for cross-references)
- Raw Data (for detailed technical info)

#### Rule 2: Metadata Validation

**Type field:**
- Must be one of: `file`, `function`, `module`, `pattern`, `issue`
- Case-sensitive
- No variations (not "Function" or "FUNCTION")

**Path field:**
- Must be valid file path (for file type)
- Must be empty or N/A (for function/module/pattern/issue)
- Use forward slashes (not backslashes)

**Last Updated field:**
- Must be ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`
- Must be valid date/time
- Must be recent (not in future)

**Updated By field:**
- Must be agent ID or name
- Should be consistent format (e.g., "agent-1" not "Agent 1")
- Should match GENERO_AGENT_ID environment variable

**Status field:**
- Must be one of: `active`, `deprecated`, `archived`
- Case-sensitive
- Reflects current state of artifact

#### Rule 3: Metrics Validation

**For function documents:**
- Complexity: integer 0-20 (0=trivial, 20=extremely complex)
- Lines of Code: integer > 0
- Parameter Count: integer >= 0
- Dependent Count: integer >= 0

**For file documents:**
- Total Functions: integer > 0
- Total Lines: integer > 0
- Average Complexity: decimal 0-20

**For pattern documents:**
- Usage Count: integer > 0 (how many artifacts use this pattern)
- Consistency Score: percentage 0-100

**Validation:**
- All metrics must be numbers (not strings)
- All metrics must be reasonable (not 999999)
- All metrics must be consistent with findings

#### Rule 4: Findings Validation

**Key Findings must:**
- Be specific and actionable
- Reference metrics or evidence
- Be written in neutral tone (no bias)
- Be unique (no duplicates in list)
- Be relevant to artifact

**Examples:**

❌ **Bad**: "This function is bad"
✅ **Good**: "Complexity of 12 exceeds recommended maximum of 10"

❌ **Bad**: "Needs improvement"
✅ **Good**: "15 dependents make changes risky; recommend breaking into smaller functions"

#### Rule 5: Recommendations Validation

**Recommendations must:**
- Be specific and actionable
- Include rationale (why?)
- Be prioritized (high/medium/low)
- Be realistic (achievable)
- Reference findings or metrics

**Format:**
```
- [Priority] [Action]: [Rationale]

Examples:
- HIGH: Break into smaller functions: Complexity of 12 exceeds recommended maximum
- MEDIUM: Add error handling: Currently returns no error codes
- LOW: Add documentation: Function purpose not clearly documented
```

#### Rule 6: Analysis History Validation

**Analysis History must:**
- Have entries in reverse chronological order (newest first)
- Include ISO 8601 timestamp
- Include agent ID
- Include action (initial_analysis, extended_analysis, update, etc.)
- Include brief notes

**Format:**
```
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-31 | agent-2 | extended_analysis | Added type resolution, found 3 new dependents |
| 2026-03-30 | agent-1 | initial_analysis | Found 12 dependents |
```

### Structure Validation Workflow

#### Step 1: Validate Before Commit

```bash
# Validate all knowledge
bash ~/.kiro/scripts/validate_knowledge.sh

# Output shows:
# [INFO] Validating AKR at: /opt/genero/etc/genero-akr
# [INFO] Validating Functions...
#   Total: 45, Valid: 44, Invalid: 1
# [WARNING] Invalid document: functions/old_function.md
#   - Missing "Recommendations" section
#   - Metrics not in correct format
```

#### Step 2: Fix Invalid Documents

**For each invalid document:**

1. Retrieve the document
2. Identify missing/invalid sections
3. Add missing sections or fix format
4. Re-validate
5. Commit with `--action update`

#### Step 3: Enforce Structure in New Documents

**Before committing new knowledge:**

```bash
# Create findings JSON with all required fields
cat > findings.json << 'EOF'
{
  "summary": "Brief description",
  "key_findings": ["Finding 1", "Finding 2"],
  "metrics": {
    "complexity": 10,
    "lines_of_code": 55,
    "parameter_count": 1,
    "dependent_count": 15
  },
  "dependencies": {
    "calls": "validate_order, save_order",
    "called_by": "process_batch, handle_request"
  },
  "known_issues": ["Issue 1", "Issue 2"],
  "recommendations": ["Recommendation 1", "Recommendation 2"]
}
EOF

# Commit with structure validation
bash ~/.kiro/scripts/commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action create
```

### Structure Integrity Checklist

Before committing any knowledge:

- [ ] All required sections present
- [ ] Metadata fields valid (type, status, timestamp)
- [ ] Metrics are numbers (not strings)
- [ ] Metrics are reasonable (not extreme values)
- [ ] Findings are specific and actionable
- [ ] Recommendations are prioritized
- [ ] Analysis history in reverse chronological order
- [ ] All links/references are valid
- [ ] No typos or formatting errors
- [ ] Validation passes: `bash ~/.kiro/scripts/validate_knowledge.sh`

---

## Part 3: Sentiment Analysis & Bias Detection

### Why Sentiment Analysis Matters

**Problem**: Knowledge documents can contain bias, emotion, or inaccurate sentiment:
- Negative bias: "This function is poorly written" (opinion, not fact)
- Positive bias: "This is the best implementation" (subjective)
- Emotional language: "Frustratingly complex" (not objective)
- Unsubstantiated claims: "This is broken" (without evidence)

**Impact**:
- Future agents make decisions based on biased information
- Recommendations are not objective
- Quality assessment is skewed
- Trust in knowledge repository decreases

### Sentiment Analysis Framework

#### Principle 1: Objective vs. Subjective

**Objective statements** (based on facts/metrics):
- "Complexity is 12 (exceeds recommended maximum of 10)"
- "15 functions depend on this function"
- "Type resolution issue with LIKE account.*"

**Subjective statements** (based on opinion):
- "This function is poorly written"
- "The implementation is elegant"
- "This is a mess"

**Rule**: All findings and recommendations must be objective

#### Principle 2: Evidence-Based Claims

**Every claim must have supporting evidence:**

❌ **Bad**: "This function needs refactoring"
✅ **Good**: "This function has complexity of 12 (exceeds recommended maximum of 10) and 15 dependents; recommend breaking into smaller functions"

❌ **Bad**: "Type resolution is broken"
✅ **Good**: "Type resolution issue: LIKE account.* parameter not resolved; affects 3 functions"

#### Principle 3: Neutral Tone

**Use neutral, professional language:**

❌ **Bad**: "Frustratingly complex", "Poorly designed", "Broken"
✅ **Good**: "High complexity", "Needs refactoring", "Type resolution issue"

❌ **Bad**: "This is the best pattern", "Excellent implementation"
✅ **Good**: "Consistent pattern used across 5 functions", "Follows established conventions"

#### Principle 4: Balanced Perspective

**Present both positive and negative findings:**

❌ **Bad**: "This function is terrible"
✅ **Good**: "Strengths: Clear naming, consistent error handling. Concerns: High complexity (12), 15 dependents make changes risky"

### Sentiment Analysis Checklist

Before committing any knowledge, review for bias:

#### Findings Review

- [ ] Each finding is objective (based on facts/metrics)
- [ ] Each finding has supporting evidence
- [ ] No emotional language (frustrating, terrible, excellent, etc.)
- [ ] No unsubstantiated claims
- [ ] Balanced perspective (not all negative or all positive)
- [ ] Specific metrics referenced (not vague)

#### Recommendations Review

- [ ] Each recommendation is actionable
- [ ] Each recommendation has clear rationale
- [ ] Rationale is based on metrics/findings (not opinion)
- [ ] Recommendations are prioritized (HIGH/MEDIUM/LOW)
- [ ] No emotional language
- [ ] Realistic and achievable

#### Known Issues Review

- [ ] Each issue is specific (not vague)
- [ ] Each issue has supporting evidence
- [ ] Issues are factual (not opinions)
- [ ] Issues are relevant to artifact
- [ ] No emotional language

### Sentiment Analysis Examples

#### Example 1: Complexity Finding

❌ **Biased**: "This function is frustratingly complex and poorly written"

✅ **Objective**: "Complexity: 12 (exceeds recommended maximum of 10). Recommend breaking into smaller functions to improve maintainability."

**Why**: 
- Removes emotional language ("frustratingly", "poorly")
- Provides specific metric (complexity: 12)
- References standard (recommended maximum of 10)
- Provides actionable recommendation

#### Example 2: Dependent Count Finding

❌ **Biased**: "This function is a nightmare because so many things depend on it"

✅ **Objective**: "15 functions depend on this function, making changes risky. Recommend comprehensive testing before modifications."

**Why**:
- Removes emotional language ("nightmare")
- Provides specific metric (15 dependents)
- Explains impact (changes risky)
- Provides actionable recommendation

#### Example 3: Type Resolution Issue

❌ **Biased**: "The type resolution is broken and needs to be fixed immediately"

✅ **Objective**: "Type resolution issue: LIKE account.* parameter not resolved. Affects 3 functions. Recommend resolving type references or documenting workaround."

**Why**:
- Removes emotional language ("broken", "immediately")
- Specific issue description
- Quantifies impact (3 functions)
- Provides options (resolve or document)

#### Example 4: Pattern Finding

❌ **Biased**: "This is the best error handling pattern ever"

✅ **Objective**: "Error handling pattern: Functions return status codes (0=success, 1=validation error, 2=database error, 3=system error). Used consistently across 5 functions. Recommend documenting pattern for new developers."

**Why**:
- Removes subjective language ("best ever")
- Describes pattern objectively
- Quantifies usage (5 functions)
- Provides actionable recommendation

### Bias Detection Techniques

#### Technique 1: Emotional Language Detection

**Red flags** (emotional language):
- Negative: terrible, awful, horrible, broken, mess, nightmare, frustrating
- Positive: excellent, amazing, perfect, best, wonderful
- Vague: good, bad, nice, ugly, weird

**Replace with**:
- Specific metrics: "Complexity: 12"
- Objective descriptions: "Type resolution issue"
- Neutral language: "Needs refactoring"

#### Technique 2: Evidence Check

**For each claim, ask:**
- Is there supporting evidence?
- Is the evidence quantifiable?
- Is the evidence verifiable?

**If answer is "no" to any question, rewrite the claim**

#### Technique 3: Perspective Check

**For each finding, ask:**
- Is this finding balanced?
- Are there positive aspects mentioned?
- Are there concerns mentioned?
- Could someone disagree with this finding?

**If perspective is one-sided, add balance**

#### Technique 4: Actionability Check

**For each recommendation, ask:**
- Is this recommendation specific?
- Can someone act on this recommendation?
- Is the recommendation realistic?
- Is the recommendation prioritized?

**If answer is "no" to any question, rewrite the recommendation**

### Sentiment Analysis Workflow

#### Step 1: Review Findings for Bias

```bash
# Retrieve knowledge
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"

# Review each finding:
# - Is it objective?
# - Does it have evidence?
# - Is the language neutral?
# - Is it balanced?
```

#### Step 2: Review Recommendations for Bias

```bash
# For each recommendation:
# - Is it actionable?
# - Is it based on findings/metrics?
# - Is it realistic?
# - Is it prioritized?
```

#### Step 3: Rewrite Biased Content

**If bias detected:**

1. Identify the biased statement
2. Extract the objective facts
3. Rewrite using objective language
4. Add supporting evidence
5. Verify neutrality

#### Step 4: Validate and Commit

```bash
# Validate structure
bash ~/.kiro/scripts/validate_knowledge.sh

# Commit with updated findings
bash ~/.kiro/scripts/commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action update
```

### Sentiment Analysis Checklist

Before committing any knowledge:

- [ ] All findings are objective (based on facts/metrics)
- [ ] All findings have supporting evidence
- [ ] No emotional language in findings
- [ ] No unsubstantiated claims
- [ ] Balanced perspective (not one-sided)
- [ ] All recommendations are actionable
- [ ] All recommendations have clear rationale
- [ ] All recommendations are prioritized
- [ ] No emotional language in recommendations
- [ ] Known issues are specific and factual

---

## Integration with AKR Workflow

### In Planner Hat (Inception Phase)

**When retrieving existing knowledge:**

1. Check for duplicates (search for similar artifacts)
2. Verify structure integrity (all sections present)
3. Assess sentiment (is analysis objective?)
4. Use findings as baseline for planning

```bash
# Retrieve knowledge
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "target_function"

# Check for duplicates
bash ~/.kiro/scripts/search_knowledge.sh --query "target_function"

# Validate structure
bash ~/.kiro/scripts/validate_knowledge.sh
```

### In Builder Hat (Construction Phase)

**When analyzing and comparing:**

1. Compare current findings with existing (use compare_knowledge.sh)
2. Identify new insights (what's different?)
3. Ensure new findings are objective
4. Prepare for commit

```bash
# Compare with existing
bash ~/.kiro/scripts/compare_knowledge.sh --type function --name "target_function" --findings findings.json

# Verify findings are objective (no bias)
# Verify structure is valid
# Prepare for commit
```

### In Reviewer Hat (Operation Phase)

**When committing knowledge:**

1. Validate structure (all sections present)
2. Check for duplicates (should we append or create?)
3. Verify sentiment (objective language?)
4. Commit with appropriate action

```bash
# Validate structure
bash ~/.kiro/scripts/validate_knowledge.sh

# Check for duplicates
bash ~/.kiro/scripts/search_knowledge.sh --query "artifact_name"

# Commit
bash ~/.kiro/scripts/commit_knowledge.sh \
  --type function \
  --name "target_function" \
  --findings findings.json \
  --action append
```

---

## Quality Scoring Framework

### Quality Score Components

**Structure (30 points)**
- All required sections present (10 points)
- Metadata valid and complete (10 points)
- Formatting consistent (10 points)

**Content (40 points)**
- Findings are specific and objective (15 points)
- Metrics are accurate and reasonable (15 points)
- Recommendations are actionable (10 points)

**Sentiment (20 points)**
- Language is neutral (10 points)
- No emotional bias (10 points)

**Deduplication (10 points)**
- No duplicate entries (5 points)
- Proper cross-references (5 points)

### Quality Score Interpretation

- **90-100**: Excellent (ready for use)
- **80-89**: Good (minor improvements needed)
- **70-79**: Fair (some issues to address)
- **60-69**: Poor (significant improvements needed)
- **<60**: Unacceptable (needs major revision)

### Quality Scoring Command

```bash
# Score all knowledge
bash ~/.kiro/scripts/quality_score.sh

# Score specific type
bash ~/.kiro/scripts/quality_score.sh --type function

# Show only low-quality documents
bash ~/.kiro/scripts/quality_score.sh --threshold 70
```

---

## Best Practices Summary

### Deduplication Best Practices

1. **Always search first** - Before creating new knowledge, search for existing
2. **Use append action** - Preserve analysis history when adding to existing
3. **Link related artifacts** - Create cross-references between related knowledge
4. **Merge duplicates** - If duplicates exist, merge them into single document
5. **Document variations** - If similar names exist, document why they're different

### Structure Best Practices

1. **Follow template** - Use standard structure for all documents
2. **Validate before commit** - Run `validate_knowledge.sh` before committing
3. **Complete all sections** - Don't skip optional sections if they're relevant
4. **Use consistent formatting** - Follow markdown conventions
5. **Keep metrics current** - Update metrics when artifact changes

### Sentiment Best Practices

1. **Be objective** - Base all claims on facts and metrics
2. **Provide evidence** - Every claim needs supporting evidence
3. **Use neutral language** - Avoid emotional or subjective words
4. **Balance perspective** - Present both strengths and concerns
5. **Be specific** - Use concrete metrics instead of vague descriptions

---

## Troubleshooting Guide

### Issue: Duplicate Knowledge Found

**Problem**: Multiple documents for same artifact

**Solution**:
1. Retrieve both documents
2. Compare findings
3. Merge into single document with `--action update`
4. Preserve analysis history
5. Delete duplicate

### Issue: Structure Validation Fails

**Problem**: Document missing required sections

**Solution**:
1. Identify missing sections
2. Add missing sections with appropriate content
3. Verify format matches template
4. Re-validate
5. Commit with `--action update`

### Issue: Biased Language Detected

**Problem**: Findings contain emotional or subjective language

**Solution**:
1. Identify biased statements
2. Extract objective facts
3. Rewrite using neutral language
4. Add supporting evidence
5. Commit with `--action update`

### Issue: Metrics Seem Unreasonable

**Problem**: Metrics don't match findings or seem extreme

**Solution**:
1. Verify metrics with genero-tools
2. Compare with similar artifacts
3. Check for data entry errors
4. Update metrics if incorrect
5. Commit with `--action update`

---

## Related Documentation

- `.kiro/AKR_SCRIPTS_README.md` - AKR scripts reference
- `.kiro/steering/genero-akr-workflow.md` - AKR workflow guide
- `.kiro/steering/genero-context-workflow.md` - AI-DLC workflow
- `$GENERO_AKR_BASE_PATH/SCHEMA.md` - Knowledge document schema
- `$GENERO_AKR_BASE_PATH/README.md` - AKR overview

---

## Quick Reference Commands

### Deduplication
```bash
# Search for existing knowledge
bash ~/.kiro/scripts/search_knowledge.sh --query "artifact_name"

# Compare with existing
bash ~/.kiro/scripts/compare_knowledge.sh --type function --name "artifact_name" --findings findings.json

# Merge duplicates
bash ~/.kiro/scripts/merge_knowledge.sh --type function --name "artifact_name" --findings findings.json
```

### Structure Validation
```bash
# Validate all knowledge
bash ~/.kiro/scripts/validate_knowledge.sh

# Validate specific type
bash ~/.kiro/scripts/validate_knowledge.sh --type function

# Get quality scores
bash ~/.kiro/scripts/quality_score.sh
```

### Sentiment Analysis
```bash
# Retrieve knowledge for review
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "artifact_name"

# Review for bias and update if needed
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "artifact_name" --findings findings.json --action update
```

---

## Success Indicators

### For AKR Health

✅ No duplicate knowledge documents  
✅ All documents pass structure validation  
✅ All documents have quality score > 80  
✅ All findings are objective and evidence-based  
✅ All recommendations are actionable  
✅ Analysis history shows multiple contributors  
✅ Cross-references are accurate and complete  

### For Team Adoption

✅ Agents retrieve knowledge before analyzing  
✅ Agents append to existing knowledge (not create duplicates)  
✅ Agents use objective language  
✅ Agents include metrics and evidence  
✅ Agents link related artifacts  
✅ Agents update analysis history  

### For Knowledge Quality

✅ Average quality score > 85  
✅ No documents with score < 70  
✅ All required sections present  
✅ All metrics are reasonable  
✅ All findings are specific  
✅ All recommendations are prioritized  

---

## Activation Instructions

To activate this skill in your workflow:

```
I'm working on AKR management and need expertise in deduplication, 
structure integrity, and sentiment analysis. Please activate the 
"AKR Management Specialist" skill.
```

This skill will provide:
- Deduplication strategies and workflows
- Structure validation and enforcement
- Sentiment analysis and bias detection
- Quality scoring and assessment
- Best practices and troubleshooting

---

**Last Updated**: 2026-03-30  
**Version**: 1.0.0  
**Status**: Production Ready
