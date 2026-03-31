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

### Rule 0: AKR First — Always

**Before doing anything else on a task, check the AKR.**

This is not optional. The AKR contains findings from previous agents that may save significant time and prevent repeated mistakes.

```bash
# Check for existing knowledge on every artifact you will touch
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "target_function"
bash ~/.kiro/scripts/retrieve_knowledge.sh --type module --name "target_module"
bash ~/.kiro/scripts/retrieve_knowledge.sh --type file --path "path/to/file.4gl"

# Search for related issues that might affect your work
bash ~/.kiro/scripts/search_knowledge.sh --category issues --query "target_function"
bash ~/.kiro/scripts/search_knowledge.sh --category issues --query "error"
```

**What to do with AKR results:**
- If knowledge exists → read it fully before querying genero-tools. Use it as your baseline.
- If knowledge is empty → proceed with genero-tools, then commit your findings at the end.
- If knowledge is stale (status: deprecated) → re-analyze and update with `--action update`.

**AKR check is a hard gate.** Do not present a plan to the human without first checking the AKR.

---

### Rule 1: Always Start with Planner Hat

**When you receive a task:**
1. Put on your Planner Hat immediately
2. Do NOT start implementation
3. Do NOT skip planning
4. Do NOT proceed to Builder Hat until human approves plan

**Planner Hat Checklist — ALL items required before presenting plan:**
- [ ] AKR checked for all target artifacts (Rule 0)
- [ ] Known issues from AKR reviewed
- [ ] Task understood completely
- [ ] genero-tools queries executed to gather context
- [ ] genero-tools output verified against source (Rule 3a)
- [ ] Dependencies identified
- [ ] Risks documented
- [ ] Approach documented with clear steps
- [ ] Audit log entry written
- [ ] Plan presented to human
- [ ] Human approval received

**Do NOT proceed until all items are checked.**

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
2. If genero-tools succeeds → use result, then verify (see Rule 3a)
3. If genero-tools fails → use fallback (grep, sed, awk)
4. Log which tool was used and why

**Never skip genero-tools and go straight to grep.**

### Rule 3a: Verify genero-tools Output — Never Take It as Absolute Truth

**genero-tools is a powerful analysis tool, but its output reflects what it could extract from the database. Gaps, unknowns, and unresolved references are limitations of the tool's analysis — not necessarily problems in the 4GL code itself.**

**When genero-tools returns incomplete or uncertain data, investigate before drawing conclusions:**

| genero-tools output | What it means | What to do |
|---|---|---|
| Unresolved LIKE reference | Tool couldn't resolve the type | Read the source `.4gl` and `.sch` files to find the actual type |
| Empty dependency list | Tool found no calls | Verify by reading the function body in source |
| Unknown variable type | Tool couldn't infer it | Check DEFINE statements and LIKE references in source |
| Missing function | Not in database | Search source with `grep -r "FUNCTION name" --include="*.4gl"` |
| Complexity seems wrong | Metric may be stale | Check if source file was modified after last database build |

**Investigation workflow when output is incomplete:**

```bash
# 1. genero-tools returns unknown/unresolved result
bash $BRODIR/etc/genero-tools/query.sh find-function-resolved "my_function"
# → LIKE account.* unresolved

# 2. Read the actual source to find the truth
grep -n "LIKE\|DEFINE" path/to/file.4gl | grep -i "account"
# → DEFINE rec LIKE account.*  (it's valid 4GL, tool just couldn't resolve the schema)

# 3. Check the schema file if available
find . -name "*.sch" | xargs grep -l "account" 2>/dev/null

# 4. Document what you found
# - If it's a tool limitation: note it as a tool gap, not a code issue
# - If it's a genuine code issue: document it as a finding
```

**Critical distinction:**
- `LIKE account.*` unresolved by genero-tools → **tool limitation** (schema not in database)
- `LIKE account.*` where `account` table doesn't exist → **genuine code issue**

**Always read the source to determine which it is. Do not report tool gaps as code defects.**

**Log tool gaps to the AKR so future agents know:**
```bash
cat > /tmp/gap_findings.json << 'EOF'
{
  "summary": "genero-tools cannot resolve LIKE account.* — schema not indexed",
  "key_findings": [
    "LIKE account.* appears in 3 functions",
    "Schema file not found in genero-tools database",
    "Source code is valid — account table exists in production schema"
  ],
  "metrics": {"complexity": 0, "lines_of_code": 0, "parameter_count": 0, "dependent_count": 0},
  "known_issues": ["genero-tools cannot resolve account schema — not a code defect"],
  "recommendations": ["Add account.sch to genero-tools database to enable type resolution"]
}
EOF
bash ~/.kiro/scripts/commit_knowledge.sh --type issue --name "tool_gap_account_schema" --findings /tmp/gap_findings.json --action create
```

### Rule 4: Maintain a Continuous Audit Trail

**Every action must be logged. This is not optional.**

The audit trail is how the team knows what was done, what was found, and why decisions were made. It feeds the AKR and enables future agents to build on your work rather than repeat it.

**Log every single one of these:**
- AKR retrieval (what was found, what was missing)
- Every genero-tools query and its result
- Every fallback tool use and the reason genero-tools wasn't sufficient
- Every case where genero-tools output was incomplete and what investigation you did
- Every decision point and the rationale
- Every approval gate — the prompt you presented and the human's response
- Any errors or tool failures

**Format — use this exactly:**
```
[TIMESTAMP] [PHASE] [HAT] [ACTION] [RESULT]
```

**Concrete examples:**
```
[2026-03-31T10:00:00Z] [INCEPTION] [PLANNER] AKR: retrieve function/process_order → Found, complexity=8, 12 dependents known
[2026-03-31T10:00:05Z] [INCEPTION] [PLANNER] AKR: search issues "process_order" → 1 issue: type_resolution_account_schema
[2026-03-31T10:00:10Z] [INCEPTION] [PLANNER] Query: find-function "process_order" → complexity=10, LOC=55
[2026-03-31T10:00:15Z] [INCEPTION] [PLANNER] Query: find-function-dependents "process_order" → 15 dependents
[2026-03-31T10:00:20Z] [INCEPTION] [PLANNER] Query: find-function-resolved "process_order" → LIKE account.* unresolved
[2026-03-31T10:00:25Z] [INCEPTION] [PLANNER] Investigate: grep DEFINE in orders.4gl → account.* is valid LIKE reference, schema not indexed
[2026-03-31T10:00:30Z] [INCEPTION] [PLANNER] Conclusion: unresolved type is tool gap, not code defect
[2026-03-31T10:01:00Z] [INCEPTION] [PLANNER] Plan presented to human
[2026-03-31T10:05:00Z] [INCEPTION] [PLANNER] Human approval received
[2026-03-31T10:05:05Z] [CONSTRUCTION] [BUILDER] Starting implementation
[2026-03-31T10:15:00Z] [CONSTRUCTION] [BUILDER] Implementation complete
[2026-03-31T10:15:05Z] [CONSTRUCTION] [BUILDER] Work presented for review
[2026-03-31T10:20:00Z] [CONSTRUCTION] [BUILDER] Human review received
[2026-03-31T10:20:05Z] [OPERATION] [REVIEWER] Validation complete: PASS
[2026-03-31T10:20:10Z] [OPERATION] [REVIEWER] AKR: commit function/process_order → appended findings
[2026-03-31T10:20:15Z] [OPERATION] [REVIEWER] Task approved by human
```

**At the end of every task, commit your audit findings to the AKR.** If you investigated something and found it was a tool gap, that knowledge belongs in the AKR so the next agent doesn't repeat the investigation.

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

## AKR Quick Reference

### Retrieve (read output directly — no parsing needed)
```bash
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"
bash ~/.kiro/scripts/retrieve_knowledge.sh --type module --name "ws_webservices"
bash ~/.kiro/scripts/search_knowledge.sh --category issues --query "error"
```

### Commit findings
```bash
cat > /tmp/findings.json << 'EOF'
{
  "summary": "One sentence description",
  "key_findings": ["Finding 1", "Finding 2"],
  "metrics": {"complexity": 8, "lines_of_code": 55, "parameter_count": 1, "dependent_count": 12},
  "known_issues": ["Issue description"],
  "recommendations": ["Specific actionable recommendation"]
}
EOF
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "process_order" --findings /tmp/findings.json --action create
# Use --action append if entry already exists
```

### genero-tools queries
```bash
bash $BRODIR/etc/genero-tools/query.sh find-function "process_order"
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "process_order"
bash $BRODIR/etc/genero-tools/query.sh find-function-dependencies "process_order"
bash $BRODIR/etc/genero-tools/query.sh find-function-resolved "process_order"
bash $BRODIR/etc/genero-tools/query.sh search-functions "process_*"
```

See `genero-context-queries.md` for the full query reference.

---

## Bootstrapping a Fresh Codebase

When the AKR is empty (first agent on a new codebase), do an initial sweep before starting any task. This gives the AKR a baseline so subsequent agents benefit immediately.

```bash
# 1. List all modules/files you'll be working with
find . -name "*.4gl" | head -20

# 2. For each key module, run a baseline analysis
bash $BRODIR/etc/genero-tools/query.sh list-file-functions "src/key_module.4gl"

# 3. Commit module-level knowledge
cat > /tmp/module_findings.json << 'EOF'
{
  "summary": "Initial baseline for module X",
  "key_findings": ["Contains N functions", "Primary purpose: ..."],
  "metrics": {"complexity": 0, "lines_of_code": 0, "parameter_count": 0, "dependent_count": 0},
  "known_issues": [],
  "recommendations": ["Baseline only — further analysis needed"]
}
EOF
bash ~/.kiro/scripts/commit_knowledge.sh --type module --name "module_name" --findings /tmp/module_findings.json --action create

# 4. Check for any known tool gaps (unresolved types)
bash $BRODIR/etc/genero-tools/query.sh unresolved-types --limit 10
# If unresolved types exist, investigate and log as AKR issues
```

This takes 10-15 minutes and means every subsequent agent starts with context rather than from scratch.

---

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

**Verify Planner Hat completed — ALL required:**
```
✓ AKR checked for all target artifacts
✓ Known AKR issues reviewed
✓ genero-tools queries executed
✓ genero-tools output verified against source where incomplete
✓ Tool gaps distinguished from code defects
✓ Dependencies identified
✓ Risks documented
✓ Approach documented
✓ Audit log entries written
✓ Plan presented to human
✓ Human approval received
```

**If any item is missing, STOP and complete it.**

### Before Proceeding to Reviewer Hat

**Verify Builder Hat completed — ALL required:**
```
✓ Plan executed
✓ Changes implemented
✓ Code tested
✓ Dependents tested
✓ Audit log entries written for all actions
✓ Results documented
✓ Work presented to human
✓ Human review received
```

**If any item is missing, STOP and complete it.**

### Before Marking Task Complete

**Verify Reviewer Hat completed — ALL required:**
```
✓ Quality validated
✓ Regressions checked
✓ Standards verified
✓ Requirements met
✓ AKR updated with findings (append or create)
✓ Tool gaps logged to AKR as issues
✓ Errors logged to AKR as issues
✓ Audit log complete
✓ Human approval received
```

**If any item is missing, STOP and complete it.**

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Skipping Planner Hat
**Wrong**: Start implementing immediately
**Right**: Always start with Planner Hat, get approval first

### ❌ Mistake 2: Skipping Approval Gates
**Wrong**: Proceed to next phase without human approval
**Right**: Wait for explicit human approval at each gate

### ❌ Mistake 3: Not Checking the AKR
**Wrong**: Start querying genero-tools without first checking the AKR
**Right**: AKR first, always. Check for existing knowledge and known issues before anything else

### ❌ Mistake 4: Not Using genero-tools
**Wrong**: Use grep immediately without trying genero-tools
**Right**: Always try genero-tools first, use fallback only if needed

### ❌ Mistake 5: Treating genero-tools Output as Absolute Truth
**Wrong**: Report an unresolved LIKE reference as a code defect without investigating
**Right**: When genero-tools returns incomplete data, read the source to determine if it's a tool gap or a real issue. Never report tool limitations as code problems.

### ❌ Mistake 6: Not Verifying Impact
**Wrong**: Complete work without checking dependents
**Right**: Query genero-tools to verify all dependents still work

### ❌ Mistake 7: Incomplete Audit Trail
**Wrong**: Skip logging, or only log some actions
**Right**: Log every AKR check, every query, every investigation, every decision, every gate. The audit trail is mandatory.

### ❌ Mistake 8: Ignoring Existing Patterns
**Wrong**: Implement in a new way without studying existing code
**Right**: Query genero-tools to find similar functions and follow patterns

### ❌ Mistake 9: Analyzing Compiled Files
**Wrong**: Try to analyze or modify .42f, .42m, .42r files
**Right**: Always work with source files (.4gl) only

### ❌ Mistake 10: Not Committing Findings to AKR
**Wrong**: Complete a task without updating the AKR
**Right**: Always commit findings at the end of every task — including tool gaps, errors, and patterns discovered

### ❌ Mistake 11: Operating Outside the Codebase Without Permission
**Wrong**: Run commands against system paths or commit to version control without asking
**Right**: Stay within the codebase. Ask for explicit permission before any operation outside it.

### ❌ Mistake 12: Not Logging Tool Gaps as AKR Issues
**Wrong**: Encounter an unresolved type or missing function in genero-tools and move on silently
**Right**: Investigate the gap, determine if it's a tool limitation or a real issue, and log it to the AKR either way

---

## Success Criteria

**A task is successfully completed when ALL of the following are true:**

1. ✓ AKR checked at task start (Rule 0)
2. ✓ Planner Hat phase completed with human approval
3. ✓ Builder Hat phase completed with human review
4. ✓ Reviewer Hat phase completed with human approval
5. ✓ All genero-tools queries logged with results
6. ✓ All incomplete/unknown genero-tools output investigated against source
7. ✓ Tool gaps distinguished from code defects and documented
8. ✓ All fallback tool usage logged with reasons
9. ✓ All approval gates logged with human responses
10. ✓ All changes verified against dependents
11. ✓ AKR updated with findings from this task
12. ✓ Tool gaps and errors committed to AKR as issues
13. ✓ All operations stayed within the codebase (or explicit permission obtained)
14. ✓ Task marked complete by human

**If any criterion is not met, task is not complete.**

---

## Next: Query Reference

For detailed information on available genero-tools queries, see: `genero-context-queries.md`

For error handling and troubleshooting, see: `genero-context-operations.md`
