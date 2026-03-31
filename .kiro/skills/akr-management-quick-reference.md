# AKR Management Specialist - Quick Reference

**Purpose**: Fast lookup guide for common AKR management tasks

**Status**: Quick Reference

---

## Deduplication Quick Reference

### Search for Duplicates
```bash
# Exact match
bash search_knowledge.sh --query "artifact_name"

# Partial match
bash search_knowledge.sh --query "partial_*"

# By type
bash search_knowledge.sh --type function --query "process_*"
```

### Decide on Action
```
Found existing knowledge?
├─ YES: Same artifact, same findings
│  └─ Action: DON'T CREATE, use --action append
├─ YES: Same artifact, different findings
│  └─ Action: Use --action append
├─ YES: Different artifact, related concept
│  └─ Action: Create new, add cross-references
└─ NO: First time analyzing
   └─ Action: Use --action create
```

### Merge Duplicates
```bash
# Compare before merging
bash compare_knowledge.sh --type function --name "artifact" --findings findings.json

# Merge
bash merge_knowledge.sh --type function --name "artifact" --findings findings.json

# Verify
bash retrieve_knowledge.sh --type function --name "artifact"
```

### Deduplication Checklist
- [ ] Searched for existing knowledge
- [ ] Searched for similar names
- [ ] Searched for related artifacts
- [ ] Reviewed existing if found
- [ ] Compared current findings
- [ ] Decided on action (create vs append)
- [ ] Verified no duplicates created

---

## Structure Integrity Quick Reference

### Required Sections
```
✓ Title: # [Artifact Name]
✓ Type: **Type:** function|file|module|pattern|issue
✓ Path: **Path:** [full path]
✓ Last Updated: **Last Updated:** YYYY-MM-DDTHH:MM:SSZ
✓ Updated By: **Updated By:** agent-id
✓ Status: **Status:** active|deprecated|archived
✓ Summary: ## Summary [1-2 sentences]
✓ Key Findings: ## Key Findings [bullet list]
✓ Metrics: ## Metrics [specific numbers]
✓ Dependencies: ## Dependencies [calls, called_by]
✓ Known Issues: ## Known Issues [specific issues]
✓ Recommendations: ## Recommendations [actionable]
✓ Analysis History: ## Analysis History [table]
```

### Validate Structure
```bash
# Validate all
bash validate_knowledge.sh

# Validate specific type
bash validate_knowledge.sh --type function

# Get quality scores
bash quality_score.sh

# Show low-quality documents
bash quality_score.sh --threshold 70
```

### Metrics Format
```
## Metrics
- Complexity: [0-20 integer]
- Lines of Code: [positive integer]
- Parameter Count: [non-negative integer]
- Dependent Count: [non-negative integer]
```

### Metadata Format
```
**Type:** function
**Path:** src/orders.4gl
**Last Updated:** 2026-03-31T14:22:15Z
**Updated By:** agent-2
**Status:** active
```

### Structure Checklist
- [ ] All required sections present
- [ ] Metadata fields valid
- [ ] Metrics are numbers (not strings)
- [ ] Metrics are reasonable
- [ ] Findings are specific
- [ ] Recommendations are actionable
- [ ] Analysis history in reverse chronological order
- [ ] Validation passes

---

## Sentiment Analysis Quick Reference

### Red Flags (Biased Language)

**Emotional Words**:
- Negative: terrible, awful, horrible, broken, mess, nightmare, frustrating
- Positive: excellent, amazing, perfect, best, wonderful
- Vague: good, bad, nice, ugly, weird

**Replace with**:
- Specific metrics: "Complexity: 12"
- Objective descriptions: "Type resolution issue"
- Neutral language: "Needs refactoring"

### Objective vs Subjective

❌ **Subjective**: "This function is poorly written"
✅ **Objective**: "Complexity: 12 (exceeds recommended maximum of 10)"

❌ **Subjective**: "This is broken"
✅ **Objective**: "Type resolution issue: LIKE account.* not resolved"

❌ **Subjective**: "This is the best pattern"
✅ **Objective**: "Pattern used consistently across 5 functions"

### Evidence Check

For each claim, ask:
- [ ] Is there supporting evidence?
- [ ] Is the evidence quantifiable?
- [ ] Is the evidence verifiable?

If "no" to any, rewrite the claim.

### Sentiment Checklist
- [ ] All findings are objective
- [ ] All findings have evidence
- [ ] No emotional language
- [ ] No unsubstantiated claims
- [ ] Balanced perspective
- [ ] All recommendations are actionable
- [ ] All recommendations have rationale
- [ ] All recommendations are prioritized

---

## Common Tasks

### Task 1: Create New Knowledge

```bash
# Step 1: Search for existing
bash search_knowledge.sh --query "artifact_name"

# Step 2: Analyze (if not found)
bash query.sh find-function "artifact_name"

# Step 3: Create findings JSON
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
  "known_issues": ["Issue 1"],
  "recommendations": ["Recommendation 1"]
}
EOF

# Step 4: Validate structure
bash validate_knowledge.sh

# Step 5: Commit
bash commit_knowledge.sh \
  --type function \
  --name "artifact_name" \
  --findings findings.json \
  --action create
```

### Task 2: Append to Existing Knowledge

```bash
# Step 1: Retrieve existing
bash retrieve_knowledge.sh --type function --name "artifact_name"

# Step 2: Compare with new findings
bash compare_knowledge.sh \
  --type function \
  --name "artifact_name" \
  --findings findings.json

# Step 3: Commit with append
bash commit_knowledge.sh \
  --type function \
  --name "artifact_name" \
  --findings findings.json \
  --action append
```

### Task 3: Fix Structure Issues

```bash
# Step 1: Validate
bash validate_knowledge.sh

# Step 2: Identify issues
# (Review validation output)

# Step 3: Retrieve document
bash retrieve_knowledge.sh --type function --name "artifact_name"

# Step 4: Fix issues
# (Edit document to add missing sections)

# Step 5: Commit with update
bash commit_knowledge.sh \
  --type function \
  --name "artifact_name" \
  --findings findings.json \
  --action update
```

### Task 4: Remove Bias

```bash
# Step 1: Retrieve document
bash retrieve_knowledge.sh --type function --name "artifact_name"

# Step 2: Identify biased language
# (Review for emotional words, unsupported claims)

# Step 3: Rewrite objectively
# (Replace emotional language with metrics)

# Step 4: Commit with update
bash commit_knowledge.sh \
  --type function \
  --name "artifact_name" \
  --findings findings.json \
  --action update
```

### Task 5: Merge Duplicates

```bash
# Step 1: Search for duplicates
bash search_knowledge.sh --query "artifact_name"

# Step 2: Retrieve both documents
bash retrieve_knowledge.sh --type function --name "artifact_name"

# Step 3: Compare findings
bash compare_knowledge.sh \
  --type function \
  --name "artifact_name" \
  --findings findings.json

# Step 4: Merge
bash merge_knowledge.sh \
  --type function \
  --name "artifact_name" \
  --findings findings.json

# Step 5: Verify
bash retrieve_knowledge.sh --type function --name "artifact_name"
```

---

## Decision Trees

### Should I Create or Append?

```
Do I have existing knowledge for this artifact?
├─ NO
│  └─ Use --action create
└─ YES
   ├─ Are my findings identical to existing?
   │  └─ YES: Use --action append (preserve history)
   └─ Are my findings different?
      └─ YES: Use --action append (combine insights)
```

### Is This a Duplicate?

```
Do I have two documents for the same artifact?
├─ Same name, same type
│  └─ YES: Duplicate
│     └─ Merge into one document
├─ Different names, same concept
│  └─ YES: Related but different
│     └─ Keep separate, add cross-references
└─ Different types (function vs pattern)
   └─ YES: Different artifacts
      └─ Keep separate
```

### Is This Biased?

```
Does the statement contain emotional language?
├─ YES (terrible, awful, excellent, etc.)
│  └─ Rewrite objectively
└─ NO
   ├─ Does the statement have supporting evidence?
   │  ├─ NO: Add evidence or rewrite
   │  └─ YES
   │     ├─ Is the evidence quantifiable?
   │     │  ├─ NO: Make quantifiable
   │     │  └─ YES: OK
   │     └─ Is the perspective balanced?
   │        ├─ NO: Add balance
   │        └─ YES: OK
```

---

## Quality Scoring

### Quality Score Ranges

- **90-100**: Excellent ✅
- **80-89**: Good ✅
- **70-79**: Fair ⚠️
- **60-69**: Poor ❌
- **<60**: Unacceptable ❌

### Quality Score Components

**Structure (30 points)**
- All required sections: 10 points
- Valid metadata: 10 points
- Consistent formatting: 10 points

**Content (40 points)**
- Specific, objective findings: 15 points
- Accurate, reasonable metrics: 15 points
- Actionable recommendations: 10 points

**Sentiment (20 points)**
- Neutral language: 10 points
- No emotional bias: 10 points

**Deduplication (10 points)**
- No duplicates: 5 points
- Proper cross-references: 5 points

### Check Quality Score

```bash
# All documents
bash quality_score.sh

# Specific type
bash quality_score.sh --type function

# Low-quality only
bash quality_score.sh --threshold 70
```

---

## Common Issues & Solutions

### Issue: Duplicate Found

**Solution**:
1. Retrieve both documents
2. Compare findings
3. Merge into one with `--action update`
4. Preserve analysis history
5. Delete duplicate

### Issue: Structure Validation Fails

**Solution**:
1. Run `bash validate_knowledge.sh`
2. Identify missing sections
3. Add missing sections
4. Re-validate
5. Commit with `--action update`

### Issue: Biased Language Detected

**Solution**:
1. Identify emotional words
2. Extract objective facts
3. Rewrite using neutral language
4. Add supporting evidence
5. Commit with `--action update`

### Issue: Metrics Seem Wrong

**Solution**:
1. Verify with genero-tools
2. Compare with similar artifacts
3. Check for data entry errors
4. Update if incorrect
5. Commit with `--action update`

---

## Workflow Integration

### In Planner Hat
```bash
# Retrieve existing knowledge
bash retrieve_knowledge.sh --type function --name "target"

# Check for duplicates
bash search_knowledge.sh --query "target"

# Validate structure
bash validate_knowledge.sh
```

### In Builder Hat
```bash
# Compare with existing
bash compare_knowledge.sh --type function --name "target" --findings findings.json

# Verify findings are objective
# (Review for bias)

# Prepare for commit
```

### In Reviewer Hat
```bash
# Validate structure
bash validate_knowledge.sh

# Check for duplicates
bash search_knowledge.sh --query "target"

# Commit
bash commit_knowledge.sh \
  --type function \
  --name "target" \
  --findings findings.json \
  --action append
```

---

## Commands Summary

### Search & Retrieve
```bash
bash search_knowledge.sh --query "term"
bash retrieve_knowledge.sh --type function --name "artifact"
```

### Commit & Merge
```bash
bash commit_knowledge.sh --type function --name "artifact" --findings findings.json --action create
bash merge_knowledge.sh --type function --name "artifact" --findings findings.json
```

### Compare & Validate
```bash
bash compare_knowledge.sh --type function --name "artifact" --findings findings.json
bash validate_knowledge.sh
```

### Quality & Statistics
```bash
bash quality_score.sh
bash get_statistics.sh
```

---

## Best Practices Checklist

### Before Creating Knowledge
- [ ] Searched for existing knowledge
- [ ] Searched for similar names
- [ ] Searched for related artifacts
- [ ] Reviewed existing if found
- [ ] Compared current findings
- [ ] Decided on action (create vs append)

### Before Committing Knowledge
- [ ] All required sections present
- [ ] Metadata valid and complete
- [ ] Metrics are numbers and reasonable
- [ ] Findings are specific and objective
- [ ] Recommendations are actionable
- [ ] Language is neutral (no bias)
- [ ] Analysis history is complete
- [ ] Validation passes

### After Committing Knowledge
- [ ] Verified commit was successful
- [ ] Retrieved to confirm saved
- [ ] Updated related knowledge
- [ ] Checked quality score
- [ ] Logged activity

---

## Quick Links

- Full Skill: `.kiro/skills/akr-management-specialist.md`
- Training Guide: `.kiro/skills/akr-management-training.md`
- AKR Scripts: `.kiro/AKR_SCRIPTS_README.md`
- AKR Workflow: `.kiro/steering/genero-akr-workflow.md`
- AKR Schema: `$GENERO_AKR_BASE_PATH/SCHEMA.md`

---

**Last Updated**: 2026-03-30  
**Version**: 1.0.0  
**Status**: Production Ready
