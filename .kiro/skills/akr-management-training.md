# AKR Management Specialist - Training Guide

**Purpose**: Hands-on training to master AKR management with focus on deduplication, structure, and sentiment analysis

**Status**: Training Material

**Duration**: 2-3 hours

---

## Training Overview

This guide provides practical exercises to master the AKR Management Specialist skill. You'll learn through real scenarios and hands-on practice.

### Learning Objectives

By completing this training, you will:

1. **Deduplication Mastery**
   - Identify duplicate knowledge entries
   - Merge duplicates correctly
   - Prevent future duplicates
   - Maintain clean repository

2. **Structure Integrity**
   - Validate document structure
   - Fix structural issues
   - Enforce consistency
   - Ensure completeness

3. **Sentiment Analysis**
   - Detect biased language
   - Rewrite objectively
   - Provide evidence
   - Maintain neutrality

---

## Module 1: Deduplication Mastery

### Exercise 1.1: Identify Duplicates

**Scenario**: You're reviewing the AKR and notice several documents that might be duplicates.

**Documents to analyze**:
```
1. functions/process_order.md
2. functions/processOrder.md
3. functions/order_processing.md
4. patterns/order_processing.md
```

**Task**: Determine which are duplicates and which are different

**Solution**:

1. **process_order.md vs processOrder.md**
   - Same artifact (different naming)
   - **Status**: Duplicates
   - **Action**: Merge into canonical name (process_order)

2. **process_order.md vs order_processing.md**
   - Different artifacts (same concept)
   - **Status**: Related but different
   - **Action**: Keep separate, add cross-references

3. **order_processing.md (function) vs order_processing.md (pattern)**
   - Different types (function vs pattern)
   - **Status**: Different artifacts
   - **Action**: Keep separate with clear naming

**Key Learning**: Duplicates have same artifact name and type. Related artifacts have different names but similar concepts.

### Exercise 1.2: Merge Duplicates

**Scenario**: You found two documents for the same function:

**Document 1** (created 2026-03-30 by agent-1):
```markdown
# process_order

**Type:** function
**Status:** active
**Last Updated:** 2026-03-30T10:00:00Z
**Updated By:** agent-1

## Summary
Processes customer orders.

## Key Findings
- 12 dependents
- Complexity: 8

## Metrics
- Complexity: 8
- Lines of Code: 50
- Parameter Count: 1
- Dependent Count: 12

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-30 | agent-1 | initial_analysis | Found 12 dependents |
```

**Document 2** (created 2026-03-31 by agent-2):
```markdown
# process_order

**Type:** function
**Status:** active
**Last Updated:** 2026-03-31T14:00:00Z
**Updated By:** agent-2

## Summary
Processes customer orders with validation.

## Key Findings
- 15 dependents
- Complexity: 10
- Type resolution issue

## Metrics
- Complexity: 10
- Lines of Code: 55
- Parameter Count: 1
- Dependent Count: 15

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-31 | agent-2 | initial_analysis | Found 15 dependents |
```

**Task**: Merge these into a single document

**Solution**:

```markdown
# process_order

**Type:** function
**Status:** active
**Last Updated:** 2026-03-31T14:00:00Z
**Updated By:** agent-2

## Summary
Processes customer orders with validation and persistence. Critical function with 15 dependents.

## Key Findings
- 15 functions depend on this function (increased from 12)
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
- Called By: process_batch, handle_request, api_endpoint

## Type Information
- Parameters: order_id (INTEGER)
- Returns: status (INTEGER)
- LIKE References: account.* (unresolved)

## Known Issues
- 15 dependents make changes risky
- Type resolution issue with LIKE account.*
- Limited error handling

## Recommendations
- HIGH: Test all 15 dependents before changes
- MEDIUM: Resolve LIKE type references
- MEDIUM: Add comprehensive error handling
- LOW: Consider breaking into smaller functions

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-31 | agent-2 | extended_analysis | Added type resolution, found 3 new dependents |
| 2026-03-30 | agent-1 | initial_analysis | Found 12 dependents |
```

**Key Learning**: 
- Keep older document as primary
- Append newer findings
- Preserve all analysis history
- Update metrics to latest values
- Combine findings from both agents

### Exercise 1.3: Prevent Future Duplicates

**Scenario**: You're about to analyze a function. How do you prevent creating a duplicate?

**Workflow**:

1. **Search for existing knowledge**
   ```bash
   bash search_knowledge.sh --query "process_order"
   ```

2. **Check for similar names**
   ```bash
   bash search_knowledge.sh --query "process_*"
   bash search_knowledge.sh --query "*order*"
   ```

3. **Retrieve if found**
   ```bash
   bash retrieve_knowledge.sh --type function --name "process_order"
   ```

4. **Compare findings**
   ```bash
   bash compare_knowledge.sh --type function --name "process_order" --findings findings.json
   ```

5. **Decide on action**
   - If exact duplicate: Don't create, append instead
   - If partial duplicate: Append with `--action append`
   - If new artifact: Create with `--action create`

**Key Learning**: Always search before creating. Use append action to preserve history.

---

## Module 2: Structure Integrity

### Exercise 2.1: Identify Structure Issues

**Scenario**: You're validating knowledge documents. Identify structure issues in this document:

```markdown
# process_order

**Type:** function
**Status:** active

## Summary
Processes orders

## Key Findings
- Complex
- Many dependents

## Metrics
- Complexity: 10
- LOC: 55
```

**Issues Found**:

1. ❌ Missing: Last Updated timestamp
2. ❌ Missing: Updated By field
3. ❌ Missing: Dependencies section
4. ❌ Missing: Known Issues section
5. ❌ Missing: Recommendations section
6. ❌ Missing: Analysis History section
7. ❌ Invalid: Summary too vague
8. ❌ Invalid: Findings not specific
9. ❌ Invalid: Metrics incomplete (missing Parameter Count, Dependent Count)

**Corrected Version**:

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
- Complexity: 10 (exceeds recommended maximum of 10)
- Type resolution issue with LIKE account.* parameter
- No comprehensive error handling

## Metrics
- Complexity: 10
- Lines of Code: 55
- Parameter Count: 1
- Dependent Count: 15

## Dependencies
- Calls: validate_order, save_order, log_message
- Called By: process_batch, handle_request, api_endpoint
- Related Files: src/validators.4gl, src/database.4gl

## Type Information
- Parameters: order_id (INTEGER)
- Returns: status (INTEGER)
- LIKE References: account.* (unresolved)

## Patterns & Conventions
- Naming: verb_noun (process_order)
- Error Handling: return status code
- Validation: validate before process

## Known Issues
- 15 dependents make changes risky
- Type resolution issue with LIKE account.*
- Limited error handling

## Recommendations
- HIGH: Test all 15 dependents before changes
- MEDIUM: Resolve LIKE type references
- MEDIUM: Add comprehensive error handling
- LOW: Consider breaking into smaller functions

## Related Knowledge
- validate_order (called function)
- save_order (called function)
- error_handling (pattern)

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-31 | agent-2 | extended_analysis | Added type resolution, found 3 new dependents |
| 2026-03-30 | agent-1 | initial_analysis | Found 12 dependents |
```

**Key Learning**: All required sections must be present. Use template to ensure consistency.

### Exercise 2.2: Validate Metrics

**Scenario**: Review these metrics and identify issues:

```
Document 1:
- Complexity: "high"
- Lines of Code: 55
- Parameter Count: 1
- Dependent Count: 15

Document 2:
- Complexity: 10
- Lines of Code: 999999
- Parameter Count: -5
- Dependent Count: 15

Document 3:
- Complexity: 10
- Lines of Code: 55
- Parameter Count: 1
- Dependent Count: 15
```

**Issues**:

**Document 1**:
- ❌ Complexity is string ("high"), should be number (10)
- ✅ Other metrics valid

**Document 2**:
- ✅ Complexity valid
- ❌ Lines of Code unreasonable (999999)
- ❌ Parameter Count negative (-5)
- ✅ Dependent Count valid

**Document 3**:
- ✅ All metrics valid and reasonable

**Key Learning**: Metrics must be numbers, reasonable values, and consistent with findings.

### Exercise 2.3: Fix Formatting Issues

**Scenario**: Fix formatting issues in this document:

```markdown
# process_order
Type: function
Status: active
Last Updated: 03/31/2026 2:22 PM
Updated By: Agent 2

Summary: Processes orders

Key Findings:
- Finding 1
- Finding 2

Metrics:
Complexity: 10
Lines of Code: 55
```

**Issues**:

1. ❌ Metadata not in bold format
2. ❌ Timestamp not ISO 8601 format
3. ❌ Agent ID format inconsistent
4. ❌ Section headers not markdown format
5. ❌ Metrics not in list format

**Corrected Version**:

```markdown
# process_order

**Type:** function
**Path:** src/orders.4gl
**Last Updated:** 2026-03-31T14:22:15Z
**Updated By:** agent-2
**Status:** active

## Summary
Processes customer orders with validation and persistence.

## Key Findings
- Finding 1
- Finding 2

## Metrics
- Complexity: 10
- Lines of Code: 55
- Parameter Count: 1
- Dependent Count: 15
```

**Key Learning**: Follow markdown conventions and ISO 8601 format for consistency.

---

## Module 3: Sentiment Analysis & Bias Detection

### Exercise 3.1: Identify Biased Language

**Scenario**: Review these findings and identify biased language:

```
Finding 1: "This function is poorly written and needs to be completely rewritten"
Finding 2: "Complexity is 12, exceeding recommended maximum of 10"
Finding 3: "This is the best error handling pattern ever implemented"
Finding 4: "Type resolution is broken and needs immediate fixing"
Finding 5: "15 functions depend on this function, making changes risky"
```

**Analysis**:

**Finding 1**: ❌ Biased
- Emotional language: "poorly written"
- Vague: "completely rewritten"
- Opinion: Not objective

**Finding 2**: ✅ Objective
- Specific metric: "Complexity is 12"
- Reference standard: "recommended maximum of 10"
- Factual: Based on measurement

**Finding 3**: ❌ Biased
- Subjective: "best ever"
- Emotional: "ever implemented"
- Opinion: Not objective

**Finding 4**: ❌ Biased
- Emotional language: "broken"
- Urgent tone: "immediate"
- Vague: No specifics

**Finding 5**: ✅ Objective
- Specific metric: "15 functions"
- Clear impact: "making changes risky"
- Factual: Based on dependency analysis

**Key Learning**: Objective findings use metrics and evidence. Biased findings use emotional language and opinions.

### Exercise 3.2: Rewrite Biased Findings

**Scenario**: Rewrite these biased findings objectively:

**Original (Biased)**:
```
- This function is a nightmare because it's so complex
- The implementation is terrible and needs to be fixed
- This pattern is poorly designed
```

**Rewritten (Objective)**:
```
- Complexity: 12 (exceeds recommended maximum of 10). Recommend breaking into smaller functions.
- Function has 15 dependents, making changes risky. Recommend comprehensive testing before modifications.
- Pattern used inconsistently across 5 functions. Recommend documenting pattern for consistency.
```

**Key Learning**: Replace emotional language with specific metrics and actionable recommendations.

### Exercise 3.3: Provide Evidence for Claims

**Scenario**: Add evidence to these unsupported claims:

**Original (No Evidence)**:
```
- This function needs refactoring
- Type resolution is an issue
- Error handling is inadequate
```

**With Evidence**:
```
- Complexity: 12 (exceeds recommended maximum of 10). Recommend breaking into smaller functions.
- Type resolution issue: LIKE account.* parameter not resolved. Affects 3 functions.
- Error handling: Function returns no error codes. Recommend implementing status code returns (0=success, 1=validation error, 2=database error).
```

**Key Learning**: Every claim needs supporting evidence (metrics, specific examples, impact).

### Exercise 3.4: Balance Perspective

**Scenario**: Balance these one-sided findings:

**Original (Negative Only)**:
```
- Complexity is too high
- Too many dependents
- No error handling
- Type resolution broken
```

**Balanced**:
```
## Strengths
- Clear naming convention (verb_noun)
- Consistent with existing patterns
- Well-documented parameters

## Concerns
- Complexity: 12 (exceeds recommended maximum of 10)
- 15 dependents make changes risky
- No comprehensive error handling
- Type resolution issue with LIKE account.*

## Recommendations
- HIGH: Test all 15 dependents before changes
- MEDIUM: Resolve LIKE type references
- MEDIUM: Add comprehensive error handling
- LOW: Consider breaking into smaller functions
```

**Key Learning**: Present both strengths and concerns for balanced perspective.

---

## Module 4: Integrated Practice

### Exercise 4.1: Complete Workflow

**Scenario**: You're analyzing a new function. Complete the full workflow:

**Step 1: Search for Existing Knowledge**
```bash
bash search_knowledge.sh --query "validate_order"
```

**Result**: No existing knowledge found

**Step 2: Analyze Function**
```bash
bash query.sh find-function "validate_order"
bash query.sh find-function-dependencies "validate_order"
bash query.sh find-function-dependents "validate_order"
```

**Results**:
- Complexity: 8
- Lines of Code: 45
- Parameters: order_data (LIKE order_table.*)
- Returns: status (INTEGER)
- Calls: check_inventory, verify_customer
- Called By: process_order, process_batch

**Step 3: Create Findings JSON**

```json
{
  "summary": "Validates customer orders before processing. Used by 2 functions.",
  "key_findings": [
    "Complexity: 8 (within recommended range)",
    "2 functions depend on this function",
    "Type resolution issue: LIKE order_table.* not resolved",
    "Consistent error handling pattern"
  ],
  "metrics": {
    "complexity": 8,
    "lines_of_code": 45,
    "parameter_count": 1,
    "dependent_count": 2
  },
  "dependencies": {
    "calls": "check_inventory, verify_customer",
    "called_by": "process_order, process_batch"
  },
  "type_information": {
    "parameters": "order_data (LIKE order_table.*)",
    "returns": "status (INTEGER)",
    "like_references": "order_table.* (unresolved)"
  },
  "patterns": {
    "naming": "verb_noun",
    "error_handling": "return status code (0=success, 1=validation error, 2=data error)"
  },
  "known_issues": [
    "Type resolution issue: LIKE order_table.* not resolved"
  ],
  "recommendations": [
    "MEDIUM: Resolve LIKE type references for better type safety",
    "LOW: Add documentation for validation rules"
  ]
}
```

**Step 4: Validate Structure**
```bash
bash validate_knowledge.sh
```

**Result**: All validations pass

**Step 5: Commit Knowledge**
```bash
bash commit_knowledge.sh \
  --type function \
  --name "validate_order" \
  --findings findings.json \
  --action create
```

**Step 6: Verify Commit**
```bash
bash retrieve_knowledge.sh --type function --name "validate_order"
```

**Key Learning**: Complete workflow ensures quality and prevents duplicates.

### Exercise 4.2: Detect and Fix Issues

**Scenario**: You're reviewing the AKR and find a document with multiple issues:

**Original Document**:
```markdown
# process_order

**Type:** function
**Status:** active

## Summary
Processes orders

## Key Findings
- Complex
- Many dependents
- Broken type resolution

## Metrics
- Complexity: 10
- LOC: 55

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-31 | agent-2 | initial_analysis | Found issues |
```

**Issues Identified**:

1. **Deduplication**: Check if duplicate exists
   ```bash
   bash search_knowledge.sh --query "process_order"
   ```

2. **Structure**: Missing sections
   - Last Updated
   - Updated By
   - Path
   - Dependencies
   - Known Issues
   - Recommendations

3. **Sentiment**: Biased language
   - "Complex" (vague)
   - "Broken" (emotional)

**Fixed Document**:

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
- Complexity: 10 (at recommended maximum)
- 15 functions depend on this function
- Type resolution issue with LIKE account.* parameter
- Consistent error handling pattern

## Metrics
- Complexity: 10
- Lines of Code: 55
- Parameter Count: 1
- Dependent Count: 15

## Dependencies
- Calls: validate_order, save_order, log_message
- Called By: process_batch, handle_request, api_endpoint

## Type Information
- Parameters: order_id (INTEGER)
- Returns: status (INTEGER)
- LIKE References: account.* (unresolved)

## Known Issues
- 15 dependents make changes risky
- Type resolution issue with LIKE account.*

## Recommendations
- HIGH: Test all 15 dependents before changes
- MEDIUM: Resolve LIKE type references
- MEDIUM: Add comprehensive error handling

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-31 | agent-2 | initial_analysis | Found 15 dependents, type resolution issue |
```

**Key Learning**: Systematically address deduplication, structure, and sentiment issues.

---

## Assessment

### Self-Assessment Checklist

After completing this training, verify you can:

**Deduplication**
- [ ] Identify duplicate knowledge entries
- [ ] Distinguish between duplicates and related artifacts
- [ ] Merge duplicates correctly
- [ ] Prevent future duplicates
- [ ] Use search and compare commands effectively

**Structure Integrity**
- [ ] Identify missing sections
- [ ] Validate metadata format
- [ ] Verify metrics are reasonable
- [ ] Ensure consistent formatting
- [ ] Use validation commands

**Sentiment Analysis**
- [ ] Detect biased language
- [ ] Identify emotional words
- [ ] Rewrite objectively
- [ ] Provide evidence for claims
- [ ] Balance perspective

**Integrated Workflow**
- [ ] Complete full analysis workflow
- [ ] Create valid findings JSON
- [ ] Commit knowledge correctly
- [ ] Verify commits
- [ ] Maintain quality standards

### Practical Exercises

**Exercise 1**: Analyze 5 existing knowledge documents
- Identify any duplicates
- Check structure integrity
- Review for bias
- Score quality

**Exercise 2**: Create 3 new knowledge documents
- Search for existing first
- Create valid structure
- Use objective language
- Commit correctly

**Exercise 3**: Review and fix 5 low-quality documents
- Identify issues
- Fix structure
- Remove bias
- Re-commit

---

## Next Steps

After completing this training:

1. **Activate the Skill**: Use the AKR Management Specialist skill in your workflow
2. **Apply Learning**: Use techniques in real AKR management tasks
3. **Maintain Quality**: Regularly validate and improve knowledge quality
4. **Share Knowledge**: Help other agents understand AKR best practices
5. **Iterate**: Refine processes based on experience

---

## Resources

- `.kiro/skills/akr-management-specialist.md` - Full skill documentation
- `.kiro/AKR_SCRIPTS_README.md` - AKR scripts reference
- `.kiro/steering/genero-akr-workflow.md` - AKR workflow guide
- `$GENERO_AKR_BASE_PATH/SCHEMA.md` - Knowledge document schema

---

**Training Status**: Complete  
**Estimated Time**: 2-3 hours  
**Difficulty**: Intermediate  
**Prerequisites**: Basic understanding of AKR system
