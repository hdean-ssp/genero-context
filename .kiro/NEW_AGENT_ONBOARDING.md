# New Agent Onboarding Guide

**Welcome to the Genero Context Framework!**

This guide gets you up to speed in 10 minutes. Everything you need to know to start your first task.

---

## What This Framework Does (60 seconds)

You're part of a team of AI agents working on Genero/4GL codebases. This framework ensures:

1. **You follow the same workflow as every other agent** — Inception → Construction → Operation
2. **You build on previous agents' work** — Check the knowledge repository before starting
3. **You leave knowledge for future agents** — Commit your findings when done
4. **Humans stay in control** — Three approval gates ensure human oversight

**Result**: Knowledge compounds. Each agent makes the next agent smarter.

---

## Your First Task: The Workflow

Every task follows this pattern:

### Phase 1: INCEPTION (Planner Hat) 🎩

**Your job**: Understand the task and plan your approach

**Steps**:
1. **Check the knowledge repository (AKR)**
   ```bash
   bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "target_function"
   bash ~/.kiro/scripts/search_knowledge.sh --query "known issues"
   ```
   - Found existing knowledge? → Use it as your baseline
   - Found known issues? → Plan around them
   - Nothing found? → Proceed to step 2

2. **Query genero-tools for code context**
   ```bash
   bash $BRODIR/etc/genero-tools/query.sh find-function "target_function"
   bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "target_function"
   bash $BRODIR/etc/genero-tools/query.sh find-function-dependencies "target_function"
   ```
   - Got complete results? → Use them
   - Got incomplete results? → Read the source .4gl file to investigate
   - Tool returned "unresolved"? → Check if it's a tool gap (schema not indexed) or a real code issue

3. **Log your findings**
   ```bash
   bash ~/.kiro/scripts/audit_log.sh --action AKR_RETRIEVE --phase INCEPTION \
     --hat PLANNER --artifact-type function --artifact-name target_function --result FOUND
   ```

4. **Document your plan**
   - What you found in AKR
   - What genero-tools returned
   - What gaps you discovered
   - Your approach with clear steps
   - Risks and dependencies

5. **Present to human**
   - Show your plan
   - Wait for approval
   - If changes requested, update and re-present

### Phase 2: CONSTRUCTION (Builder Hat) 🔨

**Your job**: Execute the approved plan

**Steps**:
1. **Execute the plan step by step**
2. **Query genero-tools as needed** for context during implementation
3. **Log every action**
   ```bash
   bash ~/.kiro/scripts/audit_log.sh --action IMPLEMENTATION_START --phase CONSTRUCTION \
     --hat BUILDER --artifact-type function --artifact-name target_function --result IN_PROGRESS
   ```
4. **Test thoroughly**
5. **Present work to human**
   - Show what you changed
   - Show test results
   - Wait for review
   - If changes requested, go back to step 1

### Phase 3: OPERATION (Reviewer Hat) ✓

**Your job**: Validate quality and commit findings

**Steps**:
1. **Validate quality**
   - Check dependents still work
   - Look for regressions
   - Verify against standards

2. **Commit findings to AKR**
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
   bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "target_function" \
     --findings /tmp/findings.json --action create
   ```

3. **Log completion**
   ```bash
   bash ~/.kiro/scripts/audit_log.sh --action TASK_COMPLETE --phase OPERATION \
     --hat REVIEWER --artifact-type function --artifact-name target_function --result SUCCESS
   ```

4. **Present to human**
   - Show validation results
   - Wait for approval
   - Task complete!

---

## Essential Commands (Copy & Paste)

### Check the Knowledge Repository

```bash
# Retrieve knowledge about a function
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"

# Retrieve knowledge about a module
bash ~/.kiro/scripts/retrieve_knowledge.sh --type module --name "ws_webservices"

# Search for known issues
bash ~/.kiro/scripts/search_knowledge.sh --query "type resolution"
bash ~/.kiro/scripts/search_knowledge.sh --category issues --query "error"
```

### Query genero-tools

```bash
# Find a function
bash $BRODIR/etc/genero-tools/query.sh find-function "process_order"

# Find what it calls
bash $BRODIR/etc/genero-tools/query.sh find-function-dependencies "process_order"

# Find what calls it
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "process_order"

# Find similar functions
bash $BRODIR/etc/genero-tools/query.sh search-functions "process_*"

# Find code references
bash $BRODIR/etc/genero-tools/query.sh find-reference "PRB-299"
```

### Log Your Actions

```bash
# Log an action
bash ~/.kiro/scripts/audit_log.sh --action AKR_RETRIEVE --phase INCEPTION \
  --hat PLANNER --artifact-type function --artifact-name process_order --result FOUND

# View audit log
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json
```

### Commit Findings

```bash
# Create findings file
cat > /tmp/findings.json << 'EOF'
{
  "summary": "Brief description",
  "key_findings": ["Finding 1", "Finding 2"],
  "metrics": {"complexity": 8, "lines_of_code": 55, "parameter_count": 1, "dependent_count": 12},
  "known_issues": ["Issue description"],
  "recommendations": ["Specific actionable recommendation"]
}
EOF

# Commit to AKR
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "process_order" \
  --findings /tmp/findings.json --action create

# Or append to existing knowledge
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "process_order" \
  --findings /tmp/findings.json --action append
```

---

## Key Rules (Don't Skip These)

### Rule 1: AKR First
**Always check the knowledge repository before querying genero-tools.** Previous agents may have already analyzed this artifact.

### Rule 2: Verify Incomplete Output
**When genero-tools returns incomplete data, read the source .4gl file to investigate.** Don't assume it's a code defect—it might be a tool gap (schema not indexed).

### Rule 3: Log Everything
**Every action gets logged.** This creates a complete audit trail so humans can understand why decisions were made.

### Rule 4: Three Gates
**Humans approve at three points**: after planning, after implementation, after validation. You don't proceed without approval.

### Rule 5: Commit Findings
**Every task ends with AKR updated.** Include tool gaps and errors, not just successful findings.

---

## Documentation Map

### For Your Current Task
- `.kiro/steering/genero-context-workflow.md` — Workflow rules (auto-loaded by Kiro)
- `.kiro/steering/genero-akr-workflow.md` — How to use the knowledge repository
- `.kiro/steering/genero-context-queries.md` — genero-tools query reference
- `.kiro/steering/genero-context-operations.md` — Error handling and fallbacks

### For Audit Logging
- `.kiro/docs/AUDIT_LOGGING_REFERENCE.md` — Commands and examples
- `.kiro/docs/AUDIT_LOGGING_INTEGRATION.md` — Where to log at each phase

### For Framework Overview
- `CRITICAL_OVERVIEW.md` — Executive summary of the framework
- `FRAMEWORK.md` — Architecture diagram and agent flow
- `.kiro/docs/AGENT_QUICK_START.md` — Quick reference

### For Troubleshooting
- `.kiro/steering/genero-context-operations.md` — Error handling
- `.kiro/docs/AUDIT_LOGGING_REFERENCE.md` — Audit logging troubleshooting

---

## Common Scenarios

### Scenario 1: You Find Existing Knowledge

```bash
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"

# Output shows:
# - Complexity: 8
# - Dependents: 12
# - Known issue: Type resolution problem
# - Last updated: 2026-03-30
```

**What to do**:
1. Use this as your baseline
2. Check if anything changed (re-query genero-tools)
3. If nothing changed, skip re-analysis
4. If something changed, update the knowledge with `--action append` or `--action update`

### Scenario 2: genero-tools Returns "Unresolved"

```bash
bash $BRODIR/etc/genero-tools/query.sh find-function-resolved "process_order"

# Output shows:
# LIKE account.* unresolved
```

**What to do**:
1. Read the source .4gl file
2. Check if `account` table exists in production
3. If it exists → it's a tool gap (schema not indexed), log as issue
4. If it doesn't exist → it's a real code defect, log as finding

### Scenario 3: You Discover a Pattern

```bash
# You notice process_order, validate_order, and save_order all use the same error handling

# Create pattern knowledge
cat > /tmp/pattern.json << 'EOF'
{
  "summary": "Error handling pattern: return status codes",
  "key_findings": [
    "Used in process_order, validate_order, save_order",
    "Status codes: 0=success, 1=validation error, 2=database error"
  ],
  "metrics": {"complexity": 0, "lines_of_code": 0, "parameter_count": 0, "dependent_count": 0},
  "known_issues": [],
  "recommendations": ["Document this pattern for consistency"]
}
EOF

bash ~/.kiro/scripts/commit_knowledge.sh --type pattern --name "error_handling_status_codes" \
  --findings /tmp/pattern.json --action create
```

### Scenario 4: You Find an Error

```bash
# You discover that genero-tools can't resolve LIKE account.* because account.sch is not indexed

cat > /tmp/error.json << 'EOF'
{
  "summary": "genero-tools cannot resolve LIKE account.* — schema not indexed",
  "key_findings": [
    "LIKE account.* in process_order, validate_order",
    "account.sch not in genero-tools database",
    "Source confirmed valid — account table exists in production"
  ],
  "metrics": {"complexity": 0, "lines_of_code": 0, "parameter_count": 0, "dependent_count": 0},
  "known_issues": ["Tool gap: account schema not indexed — not a code defect"],
  "recommendations": ["Add account.sch to genero-tools database"]
}
EOF

bash ~/.kiro/scripts/commit_knowledge.sh --type issue --name "tool_gap_account_schema" \
  --findings /tmp/error.json --action create
```

---

## Checklist for Your First Task

### Inception Phase
- [ ] Checked AKR for existing knowledge
- [ ] Searched for known issues
- [ ] Queried genero-tools for context
- [ ] Verified incomplete output against source
- [ ] Logged findings to audit trail
- [ ] Documented plan with clear steps
- [ ] Presented plan to human
- [ ] Got human approval

### Construction Phase
- [ ] Executed approved plan
- [ ] Queried genero-tools as needed
- [ ] Logged all actions
- [ ] Tested thoroughly
- [ ] Presented work to human
- [ ] Got human review

### Operation Phase
- [ ] Validated quality
- [ ] Checked dependents
- [ ] Committed findings to AKR
- [ ] Logged completion
- [ ] Presented to human
- [ ] Got human approval

---

## Getting Help

### For Workflow Questions
See: `.kiro/steering/genero-context-workflow.md`

### For AKR Questions
See: `.kiro/steering/genero-akr-workflow.md`

### For genero-tools Questions
See: `.kiro/steering/genero-context-queries.md`

### For Error Handling
See: `.kiro/steering/genero-context-operations.md`

### For Audit Logging
See: `.kiro/docs/AUDIT_LOGGING_REFERENCE.md`

### For Framework Overview
See: `CRITICAL_OVERVIEW.md`

---

## Key Principles

1. **AKR First** — Always check existing knowledge before querying genero-tools
2. **Verify Output** — When genero-tools returns incomplete data, read the source
3. **Log Everything** — Every action gets logged for traceability
4. **Three Gates** — Humans approve at planning, implementation, and validation
5. **Commit Findings** — Every task ends with AKR updated, including gaps and errors

---

## Next Steps

1. **Read the workflow rules**: `.kiro/steering/genero-context-workflow.md`
2. **Understand your role**: Planner Hat, Builder Hat, or Reviewer Hat
3. **Use the quick reference**: Copy the commands above
4. **Start your task**: Follow the workflow checklist

---

**You're ready! Good luck with your first task.** 🚀

