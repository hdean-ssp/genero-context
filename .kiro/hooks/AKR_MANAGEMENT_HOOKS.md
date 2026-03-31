# AKR Management Hooks

**Purpose**: Automatic activation of AKR Management Specialist skill during all AKR operations

**Status**: Active

**Created**: 2026-03-30

---

## Overview

Three Kiro hooks automatically activate the AKR Management Specialist skill during AKR operations:

1. **Pre-Retrieval Deduplication Check** - Before retrieving knowledge
2. **Pre-Commit Skill Activation** - Before committing knowledge
3. **Post-Commit Quality Validation** - After committing knowledge

These hooks ensure that every AKR operation follows the skill's best practices for deduplication, structure integrity, and sentiment analysis.

---

## Hook 1: Deduplication Check Before Retrieval

**Hook ID**: `akr-management-pre-retrieve-dedup`

**Event**: `preToolUse`

**Triggers On**: `retrieve_knowledge.*`

**Action**: `askAgent`

**Purpose**: Prevent duplicate AKR entries by ensuring agents search for existing knowledge before retrieval

### What It Does

When an agent calls `retrieve_knowledge.sh`, this hook:

1. Reminds agent to use the deduplication workflow
2. Suggests searching for existing knowledge first
3. Recommends checking for naming variations
4. Suggests looking for related artifacts

### Workflow

```
Agent calls: bash retrieve_knowledge.sh --type function --name "process_order"
                                    ↓
Hook triggers (preToolUse)
                                    ↓
Hook asks agent to:
  1. Search for existing knowledge
  2. Search for similar names
  3. Search for related artifacts
                                    ↓
Agent follows deduplication workflow
                                    ↓
Agent retrieves knowledge (or decides to create/append)
```

### Commands Suggested

```bash
# Search for existing knowledge
bash search_knowledge.sh --query "artifact_name"

# Search for similar names
bash search_knowledge.sh --query "partial_*"

# Search for related artifacts
bash search_knowledge.sh --query "related_concept"
```

### Benefits

✅ Prevents duplicate entries before they're created  
✅ Helps agents find existing knowledge  
✅ Encourages use of append action instead of create  
✅ Maintains clean repository  

---

## Hook 2: Pre-Commit Skill Activation

**Hook ID**: `akr-management-auto-activate`

**Event**: `preToolUse`

**Triggers On**: `commit_knowledge.*`, `merge_knowledge.*`, `update_metadata.*`

**Action**: `askAgent`

**Purpose**: Automatically activate AKR Management Specialist skill before committing to ensure quality

### What It Does

When an agent calls `commit_knowledge.sh`, `merge_knowledge.sh`, or `update_metadata.sh`, this hook:

1. Activates the AKR Management Specialist skill
2. Reminds agent of the three pillars (deduplication, structure, sentiment)
3. Suggests using the quick checklist
4. Ensures quality standards are met

### Workflow

```
Agent calls: bash commit_knowledge.sh --type function --name "process_order" ...
                                    ↓
Hook triggers (preToolUse)
                                    ↓
Hook activates AKR Management Specialist skill
                                    ↓
Hook reminds agent to:
  1. Check for duplicates
  2. Validate structure
  3. Review for bias
                                    ↓
Agent uses skill to guide the commit
                                    ↓
Agent commits knowledge with quality assurance
```

### Quality Checklist Applied

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

### Benefits

✅ Ensures skill is always used for commits  
✅ Prevents low-quality knowledge from being committed  
✅ Maintains consistency across all AKR entries  
✅ Reduces need for post-commit fixes  

---

## Hook 3: Post-Commit Quality Validation

**Hook ID**: `akr-management-post-commit-validate`

**Event**: `postToolUse`

**Triggers On**: `commit_knowledge.*`, `merge_knowledge.*`

**Action**: `askAgent`

**Purpose**: Validate committed knowledge meets quality standards

### What It Does

After an agent commits knowledge, this hook:

1. Suggests running structure validation
2. Recommends checking quality score
3. Suggests verifying no duplicates were created
4. Recommends reviewing for bias

### Workflow

```
Agent commits: bash commit_knowledge.sh ...
                                    ↓
Commit completes successfully
                                    ↓
Hook triggers (postToolUse)
                                    ↓
Hook suggests validation steps:
  1. Run validate_knowledge.sh
  2. Run quality_score.sh
  3. Search for duplicates
  4. Review for bias
                                    ↓
Agent validates the commit
                                    ↓
If issues found, agent fixes them
```

### Validation Commands

```bash
# Validate structure
bash validate_knowledge.sh

# Check quality score
bash quality_score.sh

# Search for duplicates
bash search_knowledge.sh --query "[artifact_name]"

# Retrieve and review for bias
bash retrieve_knowledge.sh --type function --name "[artifact_name]"
```

### Quality Standards

- ✅ Structure validation passes
- ✅ Quality score > 80
- ✅ No duplicates created
- ✅ Findings are objective
- ✅ Language is neutral

### Benefits

✅ Catches quality issues immediately after commit  
✅ Prevents low-quality knowledge from staying in repository  
✅ Provides feedback loop for continuous improvement  
✅ Ensures all commits meet standards  

---

## Hook Interaction Flow

### Complete AKR Operation Workflow

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

## Hook Configuration

### Hook Files

All hooks are configured in Kiro's hook system:

```
Hook 1: akr-management-pre-retrieve-dedup
  - Event: preToolUse
  - Tools: .*retrieve_knowledge.*
  - Action: askAgent

Hook 2: akr-management-auto-activate
  - Event: preToolUse
  - Tools: .*commit_knowledge.*|.*merge_knowledge.*|.*update_metadata.*
  - Action: askAgent

Hook 3: akr-management-post-commit-validate
  - Event: postToolUse
  - Tools: .*commit_knowledge.*|.*merge_knowledge.*
  - Action: askAgent
```

### Enabling/Disabling Hooks

To view all hooks:
```
Open Kiro Hook UI (Command Palette: "Open Kiro Hook UI")
```

To disable a hook:
```
In Hook UI, toggle the hook off
```

To re-enable a hook:
```
In Hook UI, toggle the hook on
```

---

## Best Practices

### 1. Always Follow Hook Guidance

When a hook activates:
- ✅ Read the guidance carefully
- ✅ Follow the suggested workflow
- ✅ Use the provided commands
- ✅ Apply the checklist

### 2. Use the Skill Actively

When the skill is activated:
- ✅ Reference the quick checklist
- ✅ Follow the decision trees
- ✅ Apply the frameworks
- ✅ Use the examples

### 3. Validate After Commit

After committing knowledge:
- ✅ Run validation commands
- ✅ Check quality score
- ✅ Verify no duplicates
- ✅ Review for bias

### 4. Fix Issues Immediately

If validation finds issues:
- ✅ Identify the problem
- ✅ Use the skill's troubleshooting guide
- ✅ Fix the issue
- ✅ Re-commit with `--action update`

---

## Common Scenarios

### Scenario 1: Creating New Knowledge

```
1. Agent calls: retrieve_knowledge.sh --type function --name "process_order"
2. Hook 1 activates: Suggests searching first
3. Agent searches: bash search_knowledge.sh --query "process_order"
4. Result: No existing knowledge found
5. Agent analyzes and creates findings
6. Agent calls: commit_knowledge.sh --action create
7. Hook 2 activates: Activates skill, reminds of quality checklist
8. Agent follows checklist and commits
9. Hook 3 activates: Suggests validation
10. Agent validates and confirms quality
```

### Scenario 2: Appending to Existing Knowledge

```
1. Agent calls: retrieve_knowledge.sh --type function --name "process_order"
2. Hook 1 activates: Suggests searching first
3. Agent searches: bash search_knowledge.sh --query "process_order"
4. Result: Existing knowledge found
5. Agent retrieves existing knowledge
6. Agent analyzes and creates new findings
7. Agent calls: commit_knowledge.sh --action append
8. Hook 2 activates: Activates skill, reminds of quality checklist
9. Agent follows checklist and commits
10. Hook 3 activates: Suggests validation
11. Agent validates and confirms quality
```

### Scenario 3: Merging Duplicates

```
1. Agent discovers duplicate knowledge
2. Agent calls: merge_knowledge.sh
3. Hook 2 activates: Activates skill, reminds of quality checklist
4. Agent uses skill to guide merge
5. Agent merges duplicates
6. Hook 3 activates: Suggests validation
7. Agent validates merged knowledge
8. Agent confirms no duplicates remain
```

---

## Troubleshooting

### Issue: Hook Not Triggering

**Problem**: Hook doesn't activate when expected

**Solution**:
1. Check hook is enabled in Hook UI
2. Verify tool name matches regex pattern
3. Check command syntax is correct
4. Restart Kiro if needed

### Issue: Hook Guidance Not Clear

**Problem**: Hook message is confusing

**Solution**:
1. Reference the AKR Management Specialist skill
2. Use the quick reference guide
3. Check the training guide for examples
4. Review the activation guide

### Issue: Quality Validation Fails

**Problem**: Validation finds issues after commit

**Solution**:
1. Use skill's troubleshooting guide
2. Identify the specific issue
3. Fix the issue
4. Re-commit with `--action update`

---

## Integration with Workflow

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

## Success Indicators

### For AKR Health

✅ All commits follow skill guidance  
✅ No duplicate entries created  
✅ All documents pass structure validation  
✅ All documents have quality score > 80  
✅ All findings are objective and evidence-based  

### For Team Adoption

✅ Agents use hooks consistently  
✅ Agents follow skill guidance  
✅ Agents validate after commits  
✅ Agents fix issues immediately  
✅ Agents maintain quality standards  

### For Knowledge Quality

✅ Average quality score > 85  
✅ No documents with score < 70  
✅ All required sections present  
✅ All metrics are reasonable  
✅ All findings are specific  

---

## Related Documentation

- **AKR Management Specialist Skill**: `.kiro/skills/akr-management-specialist.md`
- **Quick Reference**: `.kiro/skills/akr-management-quick-reference.md`
- **Training Guide**: `.kiro/skills/akr-management-training.md`
- **AKR Scripts**: `.kiro/AKR_SCRIPTS_README.md`
- **AKR Workflow**: `.kiro/steering/genero-akr-workflow.md`

---

## Summary

These three hooks ensure that:

1. **Before Retrieval**: Agents search for existing knowledge to prevent duplicates
2. **Before Commit**: Agents activate the skill and follow quality checklist
3. **After Commit**: Agents validate quality and fix any issues

Together, they create a **continuous quality assurance loop** that maintains AKR health and ensures all knowledge meets standards.

---

**Status**: Active ✅  
**Version**: 1.0.0  
**Created**: 2026-03-30  
**Last Updated**: 2026-03-30
