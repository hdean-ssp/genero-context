# AKR Management Hooks - Setup Complete ✅

**Date**: 2026-03-30  
**Status**: Active and Ready  
**Total Hooks**: 3  

---

## What Was Created

Three Kiro hooks that automatically activate the AKR Management Specialist skill during all AKR operations:

### Hook 1: Deduplication Check Before Retrieval
**ID**: `akr-management-pre-retrieve-dedup`  
**Event**: `preToolUse`  
**Triggers**: `retrieve_knowledge.*`  
**Purpose**: Prevent duplicates by searching for existing knowledge first

### Hook 2: Pre-Commit Skill Activation
**ID**: `akr-management-auto-activate`  
**Event**: `preToolUse`  
**Triggers**: `commit_knowledge.*`, `merge_knowledge.*`, `update_metadata.*`  
**Purpose**: Activate skill before committing to ensure quality

### Hook 3: Post-Commit Quality Validation
**ID**: `akr-management-post-commit-validate`  
**Event**: `postToolUse`  
**Triggers**: `commit_knowledge.*`, `merge_knowledge.*`  
**Purpose**: Validate quality after commit

---

## How It Works

### Complete AKR Operation Flow

```
1. RETRIEVAL PHASE
   ├─ Agent calls: retrieve_knowledge.sh
   ├─ Hook 1 triggers: Deduplication Check
   ├─ Agent searches for existing knowledge
   └─ Agent retrieves or decides to create/append

2. ANALYSIS PHASE
   ├─ Agent analyzes artifact
   ├─ Agent creates findings JSON
   └─ Agent prepares for commit

3. COMMIT PHASE
   ├─ Agent calls: commit_knowledge.sh
   ├─ Hook 2 triggers: Pre-Commit Skill Activation
   ├─ Agent uses AKR Management Specialist skill
   ├─ Agent follows quality checklist
   └─ Agent commits knowledge

4. VALIDATION PHASE
   ├─ Commit completes
   ├─ Hook 3 triggers: Post-Commit Quality Validation
   ├─ Agent validates structure
   ├─ Agent checks quality score
   ├─ Agent verifies no duplicates
   └─ Agent reviews for bias

5. COMPLETION
   └─ Knowledge committed with quality assurance
```

---

## What Agents Experience

### Before Retrieval

When an agent calls `retrieve_knowledge.sh`:

```
Hook Message:
"Before retrieving AKR knowledge, use the AKR Management 
Specialist skill's deduplication workflow:

1. Search for existing knowledge
2. Search for similar names
3. Search for related artifacts

This prevents creating duplicate entries."
```

### Before Commit

When an agent calls `commit_knowledge.sh`:

```
Hook Message:
"Before proceeding with this AKR operation, activate the 
AKR Management Specialist skill to ensure:

1. No duplicate knowledge entries are created
2. Document structure is valid and complete
3. All findings are objective and evidence-based (no bias)

Use the skill's deduplication workflow, structure validation, 
and sentiment analysis to guide this operation."
```

### After Commit

When an agent commits knowledge:

```
Hook Message:
"AKR commit completed. Now validate the quality using the 
AKR Management Specialist skill:

1. Run validate_knowledge.sh
2. Run quality_score.sh
3. Search for duplicates
4. Review for bias"
```

---

## Benefits

### For Agents

✅ Automatic skill activation - no need to remember  
✅ Guided workflows - clear steps to follow  
✅ Quality assurance - catches issues early  
✅ Continuous learning - reinforces best practices  

### For AKR Health

✅ No duplicate entries created  
✅ All documents pass structure validation  
✅ All documents have quality score > 80  
✅ All findings are objective and evidence-based  
✅ Consistent quality across all entries  

### For Team

✅ Standardized AKR operations  
✅ Reduced need for post-commit fixes  
✅ Better knowledge quality  
✅ Easier maintenance  
✅ Faster onboarding for new agents  

---

## Quality Assurance Loop

The three hooks create a **continuous quality assurance loop**:

```
PREVENTION (Hook 1)
  ↓
Search for existing knowledge before retrieval
Prevents duplicates from being created
  ↓
GUIDANCE (Hook 2)
  ↓
Activate skill before commit
Follow quality checklist
Ensure standards are met
  ↓
VALIDATION (Hook 3)
  ↓
Validate quality after commit
Check structure, score, duplicates, bias
Fix issues immediately
  ↓
RESULT: High-quality AKR entries
```

---

## Integration Points

### Planner Hat (Inception Phase)

**Hook 1 activates**: Deduplication Check
- Search for existing knowledge
- Check for duplicates
- Validate structure
- Review for bias

### Builder Hat (Construction Phase)

**Hook 2 activates**: Pre-Commit Skill Activation
- Compare with existing knowledge
- Verify findings are objective
- Prepare for commit

### Reviewer Hat (Operation Phase)

**Hook 2 & 3 activate**: Pre-Commit & Post-Commit
- Validate structure
- Check for duplicates
- Verify sentiment
- Commit with appropriate action
- Validate quality

---

## Managing Hooks

### View All Hooks

Open Kiro Hook UI:
```
Command Palette → "Open Kiro Hook UI"
```

### Enable/Disable Hooks

In Hook UI:
- Toggle hook on/off
- View hook details
- Edit hook configuration

### Hook Details

**Hook 1: Deduplication Check Before Retrieval**
- Status: Active ✅
- Event: preToolUse
- Tools: .*retrieve_knowledge.*
- Action: askAgent

**Hook 2: Pre-Commit Skill Activation**
- Status: Active ✅
- Event: preToolUse
- Tools: .*commit_knowledge.*|.*merge_knowledge.*|.*update_metadata.*
- Action: askAgent

**Hook 3: Post-Commit Quality Validation**
- Status: Active ✅
- Event: postToolUse
- Tools: .*commit_knowledge.*|.*merge_knowledge.*
- Action: askAgent

---

## Documentation

### Hook Documentation
**File**: `.kiro/hooks/AKR_MANAGEMENT_HOOKS.md`

Includes:
- Hook details and workflows
- Common scenarios
- Troubleshooting
- Integration with workflow
- Success indicators

### Skill Documentation
**Files**: `.kiro/skills/akr-management-*.md`

Includes:
- Core skill (deduplication, structure, sentiment)
- Training guide (4 modules, 12+ exercises)
- Quick reference (fast lookup)
- Activation guide (how to use)

---

## Success Indicators

### Immediate (First Week)

✅ Hooks are active and triggering  
✅ Agents see hook messages  
✅ Agents follow hook guidance  
✅ Skill is being activated  

### Short Term (First Month)

✅ All AKR commits follow skill guidance  
✅ No duplicate entries created  
✅ All documents pass structure validation  
✅ Average quality score > 80  

### Long Term (Ongoing)

✅ Average quality score > 85  
✅ No documents with score < 70  
✅ All required sections present  
✅ All findings are objective  
✅ All recommendations are actionable  

---

## Common Scenarios

### Scenario 1: Creating New Knowledge

```
1. Agent: retrieve_knowledge.sh --type function --name "process_order"
2. Hook 1: "Search for existing knowledge first"
3. Agent: bash search_knowledge.sh --query "process_order"
4. Result: No existing knowledge
5. Agent: Creates findings and commits
6. Hook 2: "Use AKR Management Specialist skill"
7. Agent: Follows quality checklist
8. Agent: commit_knowledge.sh --action create
9. Hook 3: "Validate quality after commit"
10. Agent: Validates and confirms quality
```

### Scenario 2: Appending to Existing

```
1. Agent: retrieve_knowledge.sh --type function --name "process_order"
2. Hook 1: "Search for existing knowledge first"
3. Agent: bash search_knowledge.sh --query "process_order"
4. Result: Existing knowledge found
5. Agent: Retrieves and analyzes
6. Agent: Creates new findings
7. Agent: commit_knowledge.sh --action append
8. Hook 2: "Use AKR Management Specialist skill"
9. Agent: Follows quality checklist
10. Hook 3: "Validate quality after commit"
11. Agent: Validates and confirms quality
```

### Scenario 3: Merging Duplicates

```
1. Agent: Discovers duplicate knowledge
2. Agent: merge_knowledge.sh
3. Hook 2: "Use AKR Management Specialist skill"
4. Agent: Uses skill to guide merge
5. Hook 3: "Validate quality after commit"
6. Agent: Validates merged knowledge
7. Agent: Confirms no duplicates remain
```

---

## Troubleshooting

### Hook Not Triggering

**Check**:
1. Hook is enabled in Hook UI
2. Tool name matches regex pattern
3. Command syntax is correct
4. Kiro is restarted if needed

### Hook Message Not Clear

**Solution**:
1. Reference AKR Management Specialist skill
2. Use quick reference guide
3. Check training guide for examples
4. Review activation guide

### Quality Validation Fails

**Solution**:
1. Use skill's troubleshooting guide
2. Identify specific issue
3. Fix the issue
4. Re-commit with `--action update`

---

## Next Steps

### Immediate

1. ✅ Hooks are created and active
2. ✅ Skill is ready to use
3. ✅ Documentation is complete

### For Agents

1. Follow hook guidance when it appears
2. Use the AKR Management Specialist skill
3. Follow the quality checklist
4. Validate after commits

### For Team

1. Share hook documentation with team
2. Train team on skill usage
3. Monitor quality metrics
4. Iterate and improve

---

## Files Created

```
.kiro/
├── hooks/
│   └── AKR_MANAGEMENT_HOOKS.md              # Hook documentation
├── skills/
│   ├── akr-management-specialist.md         # Core skill
│   ├── akr-management-training.md           # Training guide
│   ├── akr-management-quick-reference.md    # Quick reference
│   └── ACTIVATION_GUIDE.md                  # Activation guide
└── AKR_HOOKS_SETUP_COMPLETE.md              # This file
```

---

## Summary

**What**: 3 Kiro hooks that automatically activate the AKR Management Specialist skill

**When**: During all AKR retrieval, commit, and merge operations

**Why**: Ensure consistent quality, prevent duplicates, maintain structure integrity, and ensure objective analysis

**How**: 
- Hook 1: Search for existing knowledge before retrieval
- Hook 2: Activate skill before commit
- Hook 3: Validate quality after commit

**Result**: High-quality AKR with no duplicates, valid structure, and objective findings

---

## Ready to Use

✅ Hooks are active  
✅ Skill is ready  
✅ Documentation is complete  
✅ Agents will see guidance automatically  

**No additional setup needed!**

Whenever an agent works with the AKR, the hooks will automatically:
1. Remind them to search for existing knowledge
2. Activate the AKR Management Specialist skill
3. Guide them through quality validation

---

**Status**: Complete ✅  
**Version**: 1.0.0  
**Created**: 2026-03-30  
**Last Updated**: 2026-03-30
