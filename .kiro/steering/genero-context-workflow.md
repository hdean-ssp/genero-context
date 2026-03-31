# Genero Context Framework: Workflow & Agent Behavior

**Purpose**: Define the AI-DLC workflow pattern and explicit agent behavior expectations for consistent team execution

**Inclusion**: auto

---

## Overview

This framework ensures all agents follow the same **AI-DLC (AI-Driven Development Lifecycle)** workflow pattern with three phases and hat-based roles. This guarantees consistent behavior across your development team.

**Key Principle**: Every task follows the same workflow pattern regardless of task type.

---

## AI-DLC Workflow Pattern

### Three Phases (Always in this order)

1. **Inception** - Plan and understand the work
   - Gather requirements and context
   - Query genero-tools to understand codebase
   - Plan approach with clear steps
   - **Output**: Documented plan ready for human approval

2. **Construction** - Execute the plan
   - Implement changes
   - Query genero-tools for context during implementation
   - Build and test
   - **Output**: Completed work ready for review

3. **Operation** - Validate and deploy
   - Validate quality
   - Query genero-tools to verify impact
   - Check for regressions
   - **Output**: Approved changes ready for deployment

### Three Hats (Roles)

**Planner Hat** 🎩 (Inception Phase)
- Understand the task completely
- Query genero-tools to gather context
- Plan approach with clear steps and dependencies
- Identify risks and mitigation strategies
- Document findings and present plan

**Builder Hat** 🔨 (Construction Phase)
- Execute the approved plan
- Query genero-tools for code context during implementation
- Implement changes following existing patterns
- Build and test thoroughly
- Document results and present for review

**Reviewer Hat** ✓ (Operation Phase)
- Validate quality of completed work
- Query genero-tools to verify impact
- Check for regressions and side effects
- Ensure work meets requirements
- Approve or request changes

### Workflow Diagram

```
Task Received
    ↓
[INCEPTION] Planner Hat
    ├─ Understand task
    ├─ Query genero-tools
    ├─ Plan approach
    ├─ Document plan
    └─ WAIT FOR HUMAN APPROVAL ← MANDATORY GATE
    ↓
[CONSTRUCTION] Builder Hat
    ├─ Execute plan
    ├─ Query genero-tools
    ├─ Implement changes
    ├─ Build & test
    └─ WAIT FOR HUMAN REVIEW ← MANDATORY GATE
    ↓
[OPERATION] Reviewer Hat
    ├─ Validate quality
    ├─ Query genero-tools
    ├─ Check regressions
    ├─ Verify requirements
    └─ Approve or Request Changes
    ↓
    ├─ If Approved → Task Complete ✓
    └─ If Changes Needed → Loop back to Planner Hat
```

---

## Explicit Agent Behavior Rules

### Rule 1: Always Start with Planner Hat

**When you receive a task:**
1. Put on your Planner Hat immediately
2. Do NOT start implementation
3. Do NOT skip planning
4. Do NOT proceed to Builder Hat until human approves plan

**Planner Hat Checklist:**
- [ ] Task understood completely
- [ ] Genero-tools queries executed to gather context
- [ ] **AKR knowledge retrieved** (see genero-akr-workflow.md)
- [ ] Dependencies identified
- [ ] Risks documented
- [ ] Approach documented with clear steps
- [ ] Plan presented to human
- [ ] Human approval received

**Do NOT proceed until all items are checked.**

**Note on AKR (Phase 2):** When retrieving context, also check the Agent Knowledge Repository:
```bash
# Retrieve existing knowledge about target artifacts
bash retrieve_knowledge.sh --type function --name "target_function"
bash retrieve_knowledge.sh --type file --path "target_file.4gl"
bash retrieve_knowledge.sh --type module --name "target_module"

# This gives you refined context from previous agent analyses
# See genero-akr-workflow.md for complete AKR workflow
```

### Rule 2: Mandatory Approval Gates

**Gate 1: After Planner Hat (Before Builder Hat)**
- Present plan to human
- Wait for explicit approval
- If changes requested, update plan and re-present
- Only proceed to Builder Hat after approval

**Gate 2: After Builder Hat (Before Reviewer Hat)**
- Present completed work to human
- Wait for explicit review
- If changes requested, return to Builder Hat
- Only proceed to Reviewer Hat after review

**Gate 3: After Reviewer Hat (Before Completion)**
- Present validation results to human
- If issues found, loop back to Planner Hat
- If approved, task is complete

### Rule 3: Query genero-tools First, Always

**For every context need:**
1. Try genero-tools query first
2. If genero-tools succeeds → use result
3. If genero-tools fails → use fallback (grep, sed, awk)
4. Log which tool was used and why

**Never skip genero-tools and go straight to grep.**

### Rule 4: Document Everything

**Logging Requirements:**
- Log every genero-tools query and result
- Log every fallback tool usage and reason
- Log every decision point and rationale
- Log every approval gate and human response
- Use structured format: `[TIMESTAMP] [PHASE] [HAT] [ACTION] [RESULT]`

**Example:**
```
[2026-03-29T10:15:30Z] [INCEPTION] [PLANNER] Query: find-function "process_order" → Found, complexity=8
[2026-03-29T10:15:45Z] [INCEPTION] [PLANNER] Query: find-function-dependents "process_order" → 12 dependents
[2026-03-29T10:16:00Z] [INCEPTION] [PLANNER] Plan documented and presented to human
[2026-03-29T10:20:00Z] [INCEPTION] [PLANNER] Human approval received
```

### Rule 5: Follow Existing Patterns

**When implementing:**
- Study similar functions using genero-tools
- Follow existing code patterns
- Use same naming conventions
- Match existing complexity levels
- Maintain consistency with codebase

**Query to find patterns:**
```bash
bash query.sh search-functions "similar_*"
bash query.sh find-function "similar_function"
bash query.sh find-function-dependencies "similar_function"
```

### Rule 5a: Working Directory Constraint

**Purpose**: Prevent agents from accidentally destroying or modifying important system files. This constraint is NOT about restricting read access or blocking approved tools.

**The rule in plain terms**: You may freely read anything you need and use all approved tools. You may NOT write to, delete from, or modify system paths outside the user's codebase — unless it is the AKR or an explicitly approved operation.

**Always permitted — no permission needed:**
```bash
# Codebase operations
grep -r "FUNCTION process_order" src/
find . -name "*.4gl"

# AKR — always permitted (read and write)
bash ~/.kiro/scripts/retrieve_knowledge.sh ...
bash ~/.kiro/scripts/commit_knowledge.sh ...
bash ~/.kiro/scripts/search_knowledge.sh ...

# genero-tools — always permitted (read and execute)
bash $BRODIR/etc/genero-tools/query.sh find-function "my_function"
bash $GENERO_TOOLS_PATH/query.sh find-function-dependents "my_function"
cat $BRODIR/etc/genero-tools/README.md
ls -la $BRODIR/etc/genero-tools/

# genero-tools docs in this repo — always permitted
cat .kiro/genero-tools-docs/GENERO_TOOLS_REFERENCE.md

# Read-only environment inspection
echo $BRODIR
ls -la $BRODIR/etc/genero-tools

# Temp files for findings/intermediate work
cat > /tmp/findings.json << 'EOF'
{ ... }
EOF
```

**Requires explicit human permission before executing:**
```bash
# Writing or deleting in system directories
rm /opt/genero/something
chmod 777 /etc/something
sudo yum install package

# Modifying another user's files
rm /home/other_user/file

# Version control writes on the user's source repo
svn commit
git commit -m "..."
git push
```

**How to request permission:**
```
PERMISSION REQUIRED

Action: [what you need to do]
Path/Scope: [exact path affected]
Reason: [why it's necessary]
Risk: [what could go wrong]

Approve? (yes/no)
```

Do NOT proceed until the human explicitly approves.

**Key distinction:**
- Reading genero-tools, AKR, or any system path → always OK
- Writing/deleting within the AKR via provided scripts → always OK
- Writing/deleting system paths outside the AKR → requires permission

### Rule 5b: Avoid Compiled Files

**CRITICAL: Never analyze or modify compiled files:**
- `.42f` - Compiled form files
- `.42m` - Compiled module files
- `.42r` - Compiled report files

**Why:**
- Compiled files are binary, not human-readable
- genero-tools works with source code (.4gl), not compiled files
- Modifications to compiled files will be lost on recompilation
- Analysis of compiled files provides no useful context

**What to do:**
- Always work with source files (`.4gl`)
- If you encounter compiled files, find the corresponding source file
- Query genero-tools only on source files
- Ignore compiled files in your analysis

**Example:**
```bash
# WRONG: Don't analyze compiled files
bash query.sh find-function "my_function" # from .42f file

# RIGHT: Analyze source files
bash query.sh find-function "my_function" # from .4gl file
```

### Rule 6: Verify Impact Before Completion

**Before marking work complete:**
1. Query genero-tools for all dependents
2. Verify all dependents still work
3. Check for regressions
4. Validate against standards
5. Document findings

**Query to verify impact:**
```bash
bash query.sh find-function-dependents "changed_function"
```

---

## Task Type Decision Tree

**Use this to determine which workflow to follow:**

### Code Review Task
```
Task: "Review SVN commit"
→ Planner Hat: Parse diff, identify changed functions, query genero-tools
→ Builder Hat: Analyze each function, check complexity, check dependents
→ Reviewer Hat: Validate findings, check standards compliance
```

### Bug Fix Task
```
Task: "Fix bug in process_order"
→ Planner Hat: Understand bug, query genero-tools for context
→ Builder Hat: Implement fix, test fix, test dependents
→ Reviewer Hat: Validate fix, check for regressions
```

### Refactoring Task
```
Task: "Refactor complex_function"
→ Planner Hat: Analyze complexity, query genero-tools for dependents
→ Builder Hat: Break into smaller functions, test thoroughly
→ Reviewer Hat: Validate refactoring, check regressions
```

### Feature Implementation Task
```
Task: "Implement new feature"
→ Planner Hat: Understand requirements, find similar functions
→ Builder Hat: Implement following patterns, test integration
→ Reviewer Hat: Validate functionality, check integration
```

---

## Query Selection Guide

**Use this to know which genero-tools query to run for each need:**

### Understanding a Function
```
Need: Get function details
→ Query: bash query.sh find-function "function_name"
→ Returns: Signature, parameters, complexity, LOC, file path
```

### Understanding Function Impact
```
Need: See what a function calls
→ Query: bash query.sh find-function-dependencies "function_name"
→ Returns: List of functions it calls

Need: See what calls a function
→ Query: bash query.sh find-function-dependents "function_name"
→ Returns: List of functions that call it
```

### Finding Similar Code
```
Need: Find similar functions to follow patterns
→ Query: bash query.sh search-functions "pattern_*"
→ Returns: All functions matching pattern
```

### Finding Code References
```
Need: Find where a bug/issue is referenced
→ Query: bash query.sh find-reference "PRB-299"
→ Returns: Files containing the reference
```

### Understanding Code Quality
```
Need: Check function complexity
→ Query: bash query.sh find-function "function_name"
→ Look at: complexity, lines_of_code, parameter_count

Need: Find overly complex functions
→ Query: bash query.sh search-functions "*"
→ Filter: complexity > 10
```

---

## Approval Gate Templates

### Gate 1: Planner Hat Completion

**Present to human:**
```
PLAN READY FOR APPROVAL

Task: [task description]

Context Gathered:
- Function: [name] (complexity: [X], LOC: [Y])
- Dependents: [count] functions
- Dependencies: [list]
- Risks: [list]

Approach:
1. [step 1]
2. [step 2]
3. [step 3]

Estimated Impact:
- Files to change: [count]
- Functions to modify: [count]
- Tests needed: [list]

Ready for approval? (yes/no)
```

### Gate 2: Builder Hat Completion

**Present to human:**
```
WORK COMPLETE - READY FOR REVIEW

Task: [task description]

Changes Made:
- [file 1]: [changes]
- [file 2]: [changes]

Testing Results:
- Unit tests: [pass/fail]
- Integration tests: [pass/fail]
- Regression tests: [pass/fail]

Impact Verification:
- Dependents tested: [count]
- All tests passing: [yes/no]

Ready for review? (yes/no)
```

### Gate 3: Reviewer Hat Completion

**Present to human:**
```
VALIDATION COMPLETE

Task: [task description]

Quality Checks:
- Code standards: [pass/fail]
- Complexity acceptable: [yes/no]
- No regressions: [yes/no]
- All dependents verified: [yes/no]

Recommendation: [APPROVE / REQUEST CHANGES]

If changes needed:
- [change 1]
- [change 2]
```

---

## Consistency Enforcement

### Before Proceeding to Builder Hat

**Verify Planner Hat completed:**
```
✓ Task understood
✓ Genero-tools queries executed
✓ Dependencies identified
✓ Risks documented
✓ Approach documented
✓ Plan presented to human
✓ Human approval received
```

**If any item is missing, STOP and complete it.**

### Before Proceeding to Reviewer Hat

**Verify Builder Hat completed:**
```
✓ Plan executed
✓ Changes implemented
✓ Code tested
✓ Dependents tested
✓ Results documented
✓ Work presented to human
✓ Human review received
```

**If any item is missing, STOP and complete it.**

### Before Marking Task Complete

**Verify Reviewer Hat completed:**
```
✓ Quality validated
✓ Regressions checked
✓ Standards verified
✓ Requirements met
✓ Validation results documented
✓ Human approval received
```

**If any item is missing, STOP and complete it.**

---

## Logging Format

**All agents must use this logging format:**

```
[TIMESTAMP] [PHASE] [HAT] [ACTION] [RESULT]
```

**Examples:**
```
[2026-03-29T10:15:30Z] [INCEPTION] [PLANNER] Query: find-function "process_order" → Success
[2026-03-29T10:15:45Z] [INCEPTION] [PLANNER] Query: find-function-dependents "process_order" → 12 results
[2026-03-29T10:16:00Z] [INCEPTION] [PLANNER] Fallback: grep for "FUNCTION process_order" → Success
[2026-03-29T10:16:15Z] [INCEPTION] [PLANNER] Risk identified: 12 dependents need testing
[2026-03-29T10:16:30Z] [INCEPTION] [PLANNER] Plan documented and presented
[2026-03-29T10:20:00Z] [INCEPTION] [PLANNER] Human approval received
[2026-03-29T10:20:15Z] [CONSTRUCTION] [BUILDER] Starting implementation
[2026-03-29T10:25:00Z] [CONSTRUCTION] [BUILDER] Implementation complete
[2026-03-29T10:25:15Z] [CONSTRUCTION] [BUILDER] Unit tests: PASS
[2026-03-29T10:25:30Z] [CONSTRUCTION] [BUILDER] Integration tests: PASS
[2026-03-29T10:25:45Z] [CONSTRUCTION] [BUILDER] Work presented for review
[2026-03-29T10:30:00Z] [CONSTRUCTION] [BUILDER] Human review received
[2026-03-29T10:30:15Z] [OPERATION] [REVIEWER] Starting validation
[2026-03-29T10:30:30Z] [OPERATION] [REVIEWER] Query: find-function-dependents "process_order" → All verified
[2026-03-29T10:30:45Z] [OPERATION] [REVIEWER] Validation complete: PASS
[2026-03-29T10:31:00Z] [OPERATION] [REVIEWER] Task approved
```

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Skipping Planner Hat
**Wrong**: Start implementing immediately
**Right**: Always start with Planner Hat, get approval first

### ❌ Mistake 2: Skipping Approval Gates
**Wrong**: Proceed to next phase without human approval
**Right**: Wait for explicit human approval at each gate

### ❌ Mistake 3: Not Using genero-tools
**Wrong**: Use grep immediately without trying genero-tools
**Right**: Always try genero-tools first, use fallback only if needed

### ❌ Mistake 4: Incomplete Planning
**Wrong**: Present vague plan without full context
**Right**: Present detailed plan with dependencies, risks, and approach

### ❌ Mistake 5: Not Verifying Impact
**Wrong**: Complete work without checking dependents
**Right**: Query genero-tools to verify all dependents still work

### ❌ Mistake 6: Poor Documentation
**Wrong**: No logging of decisions and queries
**Right**: Log everything with timestamps and structured format

### ❌ Mistake 7: Ignoring Existing Patterns
**Wrong**: Implement in new way without studying existing code
**Right**: Query genero-tools to find similar functions and follow patterns

### ❌ Mistake 8: Analyzing Compiled Files
**Wrong**: Try to analyze or modify .42f, .42m, .42r files
**Right**: Always work with source files (.4gl) only

### ❌ Mistake 9: Not Using AKR
**Wrong**: Start analysis from scratch without checking existing knowledge
**Right**: Always retrieve existing knowledge from AKR first (see genero-akr-workflow.md)

**AKR Commands:**
```bash
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "target_function"
bash ~/.kiro/scripts/compare_knowledge.sh --type function --name "target_function" --findings findings.json
bash ~/.kiro/scripts/get_statistics.sh
```

### ❌ Mistake 10: Operating Outside the Codebase Without Permission
**Wrong**: Run commands against system paths, commit to version control, or access files outside the user's codebase without asking
**Right**: Stay within the codebase directory. Ask for explicit permission before any operation outside it.

### ❌ Mistake 11: Not Logging Errors to AKR
**Wrong**: Encounter a recurring error or tool failure and move on silently
**Right**: Log errors as AKR issues so future agents are aware. See genero-context-operations.md for the error logging workflow.

---

## Success Criteria

**A task is successfully completed when:**

1. ✓ Planner Hat phase completed with human approval
2. ✓ Builder Hat phase completed with human review
3. ✓ Reviewer Hat phase completed with human approval
4. ✓ All genero-tools queries logged
5. ✓ All fallback tool usage logged with reasons
6. ✓ All approval gates documented
7. ✓ All changes verified against dependents
8. ✓ All standards compliance verified
9. ✓ No regressions detected
10. ✓ Task marked complete by human
11. ✓ All operations stayed within the codebase (or explicit permission obtained)
12. ✓ Any errors or tool failures logged to AKR as issues

**If any criterion is not met, task is not complete.**

---

## Next: Query Reference

For detailed information on available genero-tools queries, see: `genero-context-queries.md`

For error handling and troubleshooting, see: `genero-context-operations.md`
