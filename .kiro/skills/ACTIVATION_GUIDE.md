# AKR Management Specialist Skill - Activation Guide

**Purpose**: Quick guide to activate and use the AKR Management Specialist skill

**Status**: Ready to Use

---

## What Is This Skill?

The **AKR Management Specialist** skill provides expert guidance for maintaining the Agent Knowledge Repository with focus on:

1. **Deduplication** - Preventing and eliminating duplicate knowledge entries
2. **Structure Integrity** - Maintaining consistent, valid document structure
3. **Sentiment Analysis** - Ensuring accurate, unbiased analysis

---

## When to Activate

Activate this skill when:

✅ Creating new AKR knowledge documents  
✅ Reviewing existing AKR knowledge  
✅ Maintaining AKR quality  
✅ Preventing duplicate entries  
✅ Ensuring objective analysis  
✅ Validating document structure  
✅ Detecting and removing bias  

---

## How to Activate

### Option 1: Direct Activation

In your chat, say:

```
I'm working on AKR management. Please activate the 
"AKR Management Specialist" skill.
```

### Option 2: Task-Specific Activation

```
I need to create new AKR knowledge documents and ensure 
they're free of duplicates and bias. Please activate the 
"AKR Management Specialist" skill.
```

### Option 3: Using discloseContext

```
I need to activate the AKR Management Specialist skill 
to guide my work on knowledge repository maintenance.
```

---

## What You Get

Once activated, you have access to:

### 1. Deduplication Expertise
- How to identify duplicates
- When to create vs append
- How to merge duplicates
- How to prevent future duplicates

### 2. Structure Validation
- Standard document structure
- Validation rules
- Metadata requirements
- Metrics validation
- Findings validation

### 3. Sentiment Analysis
- How to detect bias
- How to rewrite objectively
- How to provide evidence
- How to balance perspective

### 4. Quality Framework
- Quality scoring
- Best practices
- Checklists
- Troubleshooting

---

## Quick Start Workflow

### Step 1: Search for Existing Knowledge

```bash
bash search_knowledge.sh --query "artifact_name"
```

**Why**: Prevent creating duplicates

### Step 2: Decide on Action

```
Found existing knowledge?
├─ YES: Use --action append
└─ NO: Use --action create
```

### Step 3: Create/Update Knowledge

```bash
bash commit_knowledge.sh \
  --type function \
  --name "artifact_name" \
  --findings findings.json \
  --action append
```

### Step 4: Validate Structure

```bash
bash validate_knowledge.sh
```

**Why**: Ensure quality and consistency

### Step 5: Check Quality Score

```bash
bash quality_score.sh
```

**Target**: Score > 80

---

## Key Concepts

### Deduplication

**Rule**: One document per artifact

**Actions**:
- `create` - First time analyzing
- `append` - Adding to existing
- `update` - Artifact changed
- `deprecate` - No longer relevant

### Structure

**Rule**: All required sections present

**Sections**:
- Metadata (Type, Path, Last Updated, etc.)
- Summary
- Key Findings
- Metrics
- Dependencies
- Known Issues
- Recommendations
- Analysis History

### Sentiment

**Rule**: Objective, evidence-based, neutral language

**Red Flags**:
- Emotional words (terrible, excellent, etc.)
- Unsupported claims
- One-sided perspective

---

## Common Tasks

### Task 1: Create New Knowledge

```bash
# 1. Search for existing
bash search_knowledge.sh --query "artifact"

# 2. If not found, analyze
bash query.sh find-function "artifact"

# 3. Create findings JSON
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

# 4. Commit
bash commit_knowledge.sh \
  --type function \
  --name "artifact" \
  --findings findings.json \
  --action create
```

### Task 2: Append to Existing

```bash
# 1. Retrieve existing
bash retrieve_knowledge.sh --type function --name "artifact"

# 2. Compare with new findings
bash compare_knowledge.sh \
  --type function \
  --name "artifact" \
  --findings findings.json

# 3. Commit with append
bash commit_knowledge.sh \
  --type function \
  --name "artifact" \
  --findings findings.json \
  --action append
```

### Task 3: Fix Structure Issues

```bash
# 1. Validate
bash validate_knowledge.sh

# 2. Identify issues
# (Review validation output)

# 3. Retrieve document
bash retrieve_knowledge.sh --type function --name "artifact"

# 4. Fix issues
# (Add missing sections, fix format)

# 5. Commit with update
bash commit_knowledge.sh \
  --type function \
  --name "artifact" \
  --findings findings.json \
  --action update
```

### Task 4: Remove Bias

```bash
# 1. Retrieve document
bash retrieve_knowledge.sh --type function --name "artifact"

# 2. Identify biased language
# (Look for emotional words, unsupported claims)

# 3. Rewrite objectively
# (Replace emotional language with metrics)

# 4. Commit with update
bash commit_knowledge.sh \
  --type function \
  --name "artifact" \
  --findings findings.json \
  --action update
```

---

## Decision Trees

### Should I Create or Append?

```
Do I have existing knowledge for this artifact?
├─ NO
│  └─ Use --action create
└─ YES
   └─ Use --action append
```

### Is This a Duplicate?

```
Do I have two documents for the same artifact?
├─ Same name, same type
│  └─ YES: Duplicate → Merge
├─ Different names, same concept
│  └─ YES: Related → Keep separate, link
└─ Different types
   └─ YES: Different → Keep separate
```

### Is This Biased?

```
Does the statement contain emotional language?
├─ YES (terrible, awful, excellent, etc.)
│  └─ Rewrite objectively
└─ NO
   ├─ Does it have supporting evidence?
   │  ├─ NO: Add evidence
   │  └─ YES: OK
   └─ Is the perspective balanced?
      ├─ NO: Add balance
      └─ YES: OK
```

---

## Quality Checklist

Before committing knowledge:

- [ ] Searched for existing knowledge
- [ ] Decided on action (create vs append)
- [ ] All required sections present
- [ ] Metadata valid and complete
- [ ] Metrics are numbers and reasonable
- [ ] Findings are specific and objective
- [ ] Recommendations are actionable
- [ ] Language is neutral (no bias)
- [ ] Analysis history is complete
- [ ] Validation passes

---

## Red Flags

### Deduplication Red Flags

🚩 Creating new document without searching first  
🚩 Multiple documents for same artifact  
🚩 Similar names (process_order vs processOrder)  
🚩 No cross-references between related artifacts  

### Structure Red Flags

🚩 Missing required sections  
🚩 Metadata not in correct format  
🚩 Metrics as strings instead of numbers  
🚩 Inconsistent formatting  

### Sentiment Red Flags

🚩 Emotional language (terrible, excellent, etc.)  
🚩 Unsupported claims  
🚩 One-sided perspective  
🚩 Vague descriptions  

---

## Commands Reference

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

## Learning Path

### Quick Start (30 minutes)

1. Read this activation guide (5 min)
2. Review quick reference (10 min)
3. Try one task (15 min)

### Standard Training (2-3 hours)

1. Complete training guide (1-2 hours)
2. Do all exercises (1-2 hours)
3. Apply to real work (ongoing)

### Deep Dive (4-5 hours)

1. Read core skill document (1-2 hours)
2. Complete training guide (1-2 hours)
3. Do all exercises (1-2 hours)
4. Apply to real work (ongoing)

---

## Resources

### Skill Files
- **Core Skill**: `.kiro/skills/akr-management-specialist.md`
- **Training**: `.kiro/skills/akr-management-training.md`
- **Quick Ref**: `.kiro/skills/akr-management-quick-reference.md`

### AKR Documentation
- **Scripts**: `.kiro/AKR_SCRIPTS_README.md`
- **Workflow**: `.kiro/steering/genero-akr-workflow.md`
- **Schema**: `$GENERO_AKR_BASE_PATH/SCHEMA.md`

### This Guide
- **Summary**: `.kiro/SKILL_TRAINING_SUMMARY.md`
- **Activation**: `.kiro/skills/ACTIVATION_GUIDE.md` (this file)

---

## Next Steps

### Now

1. ✅ Read this activation guide
2. ✅ Bookmark quick reference
3. ✅ Try one task

### Today

1. Complete one exercise
2. Apply to real AKR work
3. Check quality score

### This Week

1. Complete training guide
2. Do all exercises
3. Maintain quality standards

### Ongoing

1. Use skill in daily work
2. Maintain quality > 80
3. Share with team

---

## Support

### Quick Answers
→ Use quick reference guide

### Learning
→ Use training guide

### Deep Dive
→ Read core skill document

### Overview
→ Read skills directory README

---

## Ready to Start?

**Activate the skill**:

```
I'm working on AKR management. Please activate the 
"AKR Management Specialist" skill.
```

**Then**:
1. Choose your learning path
2. Follow the workflows
3. Use the checklists
4. Apply best practices

---

**Status**: Ready to Use ✅  
**Version**: 1.0.0  
**Last Updated**: 2026-03-30
