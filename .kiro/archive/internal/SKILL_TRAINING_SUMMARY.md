# AKR Management Specialist Skill - Training Summary

**Date**: 2026-03-30  
**Skill**: AKR Management Specialist  
**Status**: Complete and Ready for Use  
**Training Duration**: 2-3 hours  

---

## What Was Created

You now have a complete Kiro skill for AKR management with three components:

### 1. Core Skill Document
**File**: `.kiro/skills/akr-management-specialist.md`

**Size**: ~3,500 lines  
**Sections**: 3 major parts + integration + reference

**Covers**:
- **Part 1: Deduplication Strategy** (5 sections)
  - Why deduplication matters
  - Deduplication workflow (4 steps)
  - Merge duplicates process
  - Common deduplication patterns
  - Deduplication checklist

- **Part 2: Structure Integrity** (6 sections)
  - Why structure matters
  - Standard document structure
  - Structure validation rules (6 rules)
  - Structure validation workflow
  - Structure integrity checklist

- **Part 3: Sentiment Analysis** (7 sections)
  - Why sentiment analysis matters
  - Sentiment analysis framework (4 principles)
  - Sentiment analysis checklist
  - Bias detection techniques (4 techniques)
  - Sentiment analysis workflow
  - Sentiment analysis examples (4 examples)
  - Quality scoring framework

### 2. Training Guide
**File**: `.kiro/skills/akr-management-training.md`

**Size**: ~2,000 lines  
**Modules**: 4 modules with 12+ exercises

**Includes**:
- **Module 1: Deduplication Mastery** (3 exercises)
  - Exercise 1.1: Identify duplicates
  - Exercise 1.2: Merge duplicates
  - Exercise 1.3: Prevent future duplicates

- **Module 2: Structure Integrity** (3 exercises)
  - Exercise 2.1: Identify structure issues
  - Exercise 2.2: Validate metrics
  - Exercise 2.3: Fix formatting issues

- **Module 3: Sentiment Analysis** (4 exercises)
  - Exercise 3.1: Identify biased language
  - Exercise 3.2: Rewrite biased findings
  - Exercise 3.3: Provide evidence for claims
  - Exercise 3.4: Balance perspective

- **Module 4: Integrated Practice** (2 exercises)
  - Exercise 4.1: Complete workflow
  - Exercise 4.2: Detect and fix issues

- **Assessment**: Self-assessment checklist + practical exercises

### 3. Quick Reference Guide
**File**: `.kiro/skills/akr-management-quick-reference.md`

**Size**: ~1,000 lines  
**Sections**: 10 quick reference sections

**Includes**:
- Deduplication quick reference
- Structure integrity quick reference
- Sentiment analysis quick reference
- Common tasks (5 tasks with step-by-step)
- Decision trees (3 trees)
- Quality scoring guide
- Common issues & solutions
- Workflow integration
- Commands summary
- Best practices checklist

### 4. Skills Directory README
**File**: `.kiro/skills/README.md`

**Purpose**: Overview of all Kiro skills and how to use them

**Includes**:
- What are skills
- How to use skills
- Available skills inventory
- Skill structure
- How to create new skills
- Skill lifecycle
- Best practices for skills

---

## Key Features

### Deduplication (Part 1)

**Workflow**:
1. Identify potential duplicates (search)
2. Analyze existing knowledge (retrieve)
3. Decide on action (create vs append)
4. Merge duplicates (if found)

**Patterns Covered**:
- Naming variations (process_order vs processOrder)
- Scope variations (function vs pattern)
- Time-based duplicates (same artifact, different times)
- Agent-based duplicates (multiple agents, same artifact)

**Checklist**: 7-item deduplication checklist

### Structure Integrity (Part 2)

**Standard Structure**:
- Metadata (Type, Path, Last Updated, Updated By, Status)
- Summary
- Key Findings
- Metrics
- Dependencies
- Type Information
- Patterns & Conventions
- Known Issues
- Recommendations
- Related Knowledge
- Analysis History

**Validation Rules**:
1. Required sections
2. Metadata validation
3. Metrics validation
4. Findings validation
5. Recommendations validation
6. Analysis history validation

**Checklist**: 10-item structure integrity checklist

### Sentiment Analysis (Part 3)

**Framework**:
1. Objective vs subjective statements
2. Evidence-based claims
3. Neutral tone
4. Balanced perspective

**Bias Detection**:
- Emotional language detection
- Evidence check
- Perspective check
- Actionability check

**Examples**: 4 real-world examples showing before/after

**Checklist**: 10-item sentiment analysis checklist

---

## How to Use This Skill

### For Learning

**Step 1**: Start with training guide
```
Read: .kiro/skills/akr-management-training.md
Time: 1-2 hours
```

**Step 2**: Complete exercises
```
Do: All 12+ exercises
Time: 1-2 hours
```

**Step 3**: Review core skill
```
Read: .kiro/skills/akr-management-specialist.md
Time: 30-60 minutes
```

**Step 4**: Use quick reference
```
Bookmark: .kiro/skills/akr-management-quick-reference.md
Use: As needed during work
```

### For Daily Use

**When creating knowledge**:
1. Activate skill: "Please activate AKR Management Specialist"
2. Use deduplication workflow
3. Use structure template
4. Check sentiment for bias
5. Use quality checklist

**When reviewing knowledge**:
1. Use validation commands
2. Check for duplicates
3. Verify structure
4. Review for bias
5. Score quality

**When fixing issues**:
1. Use quick reference
2. Follow decision trees
3. Apply checklists
4. Reference examples
5. Commit with appropriate action

### For Team Training

**Share with team**:
1. Point to `.kiro/skills/akr-management-specialist.md`
2. Have them complete training
3. Review exercises together
4. Establish team standards
5. Use quick reference as reference

---

## Key Concepts

### Deduplication

**Core Principle**: One document per artifact

**Actions**:
- `create` - First time analyzing artifact
- `append` - Adding to existing knowledge
- `update` - Artifact significantly changed
- `deprecate` - Artifact no longer relevant

**Decision**: Search first, then decide on action

### Structure Integrity

**Core Principle**: Consistent, complete, valid structure

**Validation**: All required sections present, metadata valid, metrics reasonable

**Quality**: Structure score is 30% of overall quality

### Sentiment Analysis

**Core Principle**: Objective, evidence-based, neutral language

**Red Flags**: Emotional words, unsupported claims, one-sided perspective

**Quality**: Sentiment score is 20% of overall quality

---

## Quality Scoring

### Components

- **Structure** (30%): All sections, valid metadata, consistent format
- **Content** (40%): Specific findings, accurate metrics, actionable recommendations
- **Sentiment** (20%): Neutral language, no emotional bias
- **Deduplication** (10%): No duplicates, proper cross-references

### Ranges

- **90-100**: Excellent ✅
- **80-89**: Good ✅
- **70-79**: Fair ⚠️
- **60-69**: Poor ❌
- **<60**: Unacceptable ❌

### Target

Maintain average quality score > 85 across all knowledge documents

---

## Integration with Workflow

### Planner Hat (Inception Phase)

**Use skill to**:
- Search for existing knowledge
- Check for duplicates
- Validate structure
- Review for bias

**Commands**:
```bash
bash search_knowledge.sh --query "artifact"
bash retrieve_knowledge.sh --type function --name "artifact"
bash validate_knowledge.sh
```

### Builder Hat (Construction Phase)

**Use skill to**:
- Compare with existing knowledge
- Verify findings are objective
- Prepare for commit

**Commands**:
```bash
bash compare_knowledge.sh --type function --name "artifact" --findings findings.json
```

### Reviewer Hat (Operation Phase)

**Use skill to**:
- Validate structure
- Check for duplicates
- Verify sentiment
- Commit with appropriate action

**Commands**:
```bash
bash validate_knowledge.sh
bash commit_knowledge.sh --type function --name "artifact" --findings findings.json --action append
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

## Next Steps

### Immediate (Today)

1. **Review this summary** (5 minutes)
2. **Skim the core skill** (15 minutes)
3. **Bookmark quick reference** (1 minute)

### Short Term (This Week)

1. **Complete training guide** (2-3 hours)
2. **Do all exercises** (1-2 hours)
3. **Apply to real AKR work** (ongoing)

### Medium Term (This Month)

1. **Use skill in daily work** (ongoing)
2. **Maintain quality standards** (ongoing)
3. **Share with team** (1-2 hours)
4. **Refine based on experience** (ongoing)

### Long Term (Ongoing)

1. **Keep quality high** (ongoing)
2. **Update skill with learnings** (quarterly)
3. **Train new team members** (as needed)
4. **Iterate and improve** (continuous)

---

## Files Created

```
.kiro/skills/
├── README.md                                    # Skills directory overview
├── akr-management-specialist.md                 # Core skill (3,500 lines)
├── akr-management-training.md                   # Training guide (2,000 lines)
└── akr-management-quick-reference.md            # Quick reference (1,000 lines)

.kiro/
└── SKILL_TRAINING_SUMMARY.md                    # This file
```

**Total**: 4 files, ~7,500 lines of documentation

---

## How to Activate the Skill

### In Chat

```
I'm working on AKR management and need expertise in 
deduplication, structure integrity, and sentiment analysis. 
Please activate the "AKR Management Specialist" skill.
```

### Using discloseContext

```
I need to activate the AKR Management Specialist skill 
to guide my work on knowledge repository maintenance.
```

---

## Key Takeaways

### Three Pillars of AKR Management

1. **Deduplication** - One document per artifact
   - Search first
   - Use append action
   - Merge duplicates
   - Prevent future duplicates

2. **Structure Integrity** - Consistent, complete, valid
   - Follow template
   - Validate before commit
   - Complete all sections
   - Use consistent formatting

3. **Sentiment Analysis** - Objective, evidence-based, neutral
   - Use metrics not opinions
   - Provide evidence
   - Use neutral language
   - Balance perspective

### Quality Framework

- **Structure** (30%) - All sections, valid metadata
- **Content** (40%) - Specific findings, accurate metrics
- **Sentiment** (20%) - Neutral language, no bias
- **Deduplication** (10%) - No duplicates, cross-references

### Workflow Integration

- **Planner Hat**: Search, retrieve, validate
- **Builder Hat**: Compare, verify, prepare
- **Reviewer Hat**: Validate, check, commit

---

## Support Resources

### Documentation
- Core Skill: `.kiro/skills/akr-management-specialist.md`
- Training: `.kiro/skills/akr-management-training.md`
- Quick Ref: `.kiro/skills/akr-management-quick-reference.md`
- Skills Dir: `.kiro/skills/README.md`

### AKR Documentation
- Scripts: `.kiro/AKR_SCRIPTS_README.md`
- Workflow: `.kiro/steering/genero-akr-workflow.md`
- Schema: `$GENERO_AKR_BASE_PATH/SCHEMA.md`

### Related Skills (Planned)
- Genero Code Analysis Specialist
- Genero Script Development
- Genero Workflow Orchestration
- Genero Type Resolution Expert

---

## Questions?

Refer to:
1. **Quick answers**: Quick reference guide
2. **Learning**: Training guide
3. **Deep dive**: Core skill document
4. **Overview**: Skills directory README

---

**Training Complete** ✅

You now have a comprehensive Kiro skill for AKR management with:
- ✅ Core expertise documentation
- ✅ Hands-on training materials
- ✅ Quick reference guide
- ✅ Integration with workflow
- ✅ Quality framework
- ✅ Best practices

**Ready to use in your AKR management work!**

---

**Created**: 2026-03-30  
**Version**: 1.0.0  
**Status**: Production Ready
