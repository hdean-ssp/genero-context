# Audit Logging Integration Guide

**Where to log at each phase of the workflow**

---

## Inception Phase — Planner Hat

### Step 1: AKR Check

**When**: At task start, before anything else

**What to log**:
```bash
# For each artifact you'll analyze:
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_RETRIEVE \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result FOUND \
  --details "{\"status\": \"active\", \"complexity\": 8}"

# If not found:
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_RETRIEVE \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result NOT_FOUND
```

### Step 2: genero-tools Queries

**When**: After AKR check, to gather context

**What to log**:
```bash
START_TIME=$(date +%s%N)

RESULT=$(bash $BRODIR/etc/genero-tools/query.sh find-function "process_order")

END_TIME=$(date +%s%N)
DURATION_MS=$(( (END_TIME - START_TIME) / 1000000 ))

if [[ -n "$RESULT" ]]; then
    bash ~/.kiro/scripts/audit_log.sh \
      --action GENERO_QUERY \
      --phase INCEPTION \
      --hat PLANNER \
      --artifact-type function \
      --artifact-name "process_order" \
      --result SUCCESS \
      --duration-ms "$DURATION_MS" \
      --details "$(echo "$RESULT" | jq '{complexity: .complexity, loc: .lines_of_code}')"
else
    bash ~/.kiro/scripts/audit_log.sh \
      --action GENERO_QUERY \
      --phase INCEPTION \
      --hat PLANNER \
      --artifact-type function \
      --artifact-name "process_order" \
      --result FAILURE \
      --duration-ms "$DURATION_MS" \
      --error "Function not found"
fi
```

### Step 3: Plan Presented

**When**: After plan is documented and ready for human review

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action PLAN_PRESENTED \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result PENDING_APPROVAL \
  --details '{"steps": 3, "risks": 2, "dependents_to_test": 15}'
```

### Step 4: Human Approval

**When**: After human approves the plan

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action HUMAN_APPROVAL \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result APPROVED
```

---

## Construction Phase — Builder Hat

### Step 1: Implementation Start

**When**: Beginning to implement the approved plan

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action IMPL_START \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result IN_PROGRESS \
  --details '{"step": 1, "total_steps": 3}'
```

### Step 2: Implementation Actions

**When**: During implementation, for significant actions

**What to log**:
```bash
# For each major step:
bash ~/.kiro/scripts/audit_log.sh \
  --action IMPL_STEP \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result SUCCESS \
  --details '{"step": 1, "description": "Added error handling", "files_modified": 1}'

# For genero-tools queries during implementation:
bash ~/.kiro/scripts/audit_log.sh \
  --action GENERO_QUERY \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "validate_order" \
  --result SUCCESS \
  --duration-ms 120 \
  --details '{"purpose": "verify dependent", "complexity": 3}'

# For fallback tool usage:
bash ~/.kiro/scripts/audit_log.sh \
  --action FALLBACK_TOOL \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result SUCCESS \
  --details '{"tool": "grep", "reason": "genero-tools timeout", "matches": 5}'
```

### Step 3: Implementation Complete

**When**: All implementation steps done

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action IMPL_END \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result SUCCESS \
  --details '{"files_modified": 2, "tests_passed": 15, "regressions": 0}'
```

### Step 4: Work Presented

**When**: Implementation ready for human review

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action WORK_PRESENTED \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result PENDING_REVIEW \
  --details '{"changes": 2, "tests_passed": 15, "regressions": 0}'
```

### Step 5: Human Review

**When**: Human reviews and approves the work

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action HUMAN_REVIEW \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result APPROVED
```

---

## Operation Phase — Reviewer Hat

### Step 1: Validation Start

**When**: Beginning validation and quality checks

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action VALIDATION_START \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result IN_PROGRESS \
  --details '{"checks": ["dependents", "regressions", "standards"]}'
```

### Step 2: Validation Steps

**When**: During validation, for each check

**What to log**:
```bash
# Verify dependents
bash ~/.kiro/scripts/audit_log.sh \
  --action VALIDATION_CHECK \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result SUCCESS \
  --details '{"check": "dependents", "dependents_verified": 15, "all_passing": true}'

# Check for regressions
bash ~/.kiro/scripts/audit_log.sh \
  --action VALIDATION_CHECK \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result SUCCESS \
  --details '{"check": "regressions", "regressions_found": 0}'

# Verify standards compliance
bash ~/.kiro/scripts/audit_log.sh \
  --action VALIDATION_CHECK \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result SUCCESS \
  --details '{"check": "standards", "complexity_ok": true, "naming_ok": true}'
```

### Step 3: AKR Commit

**When**: Committing findings to AKR

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_COMMIT \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result SUCCESS \
  --details '{"action": "append", "findings": 3, "issues": 0}'

# If committing issues/tool gaps:
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_COMMIT \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type issue \
  --artifact-name "tool_gap_account_schema" \
  --result SUCCESS \
  --details '{"action": "create", "severity": "medium", "affected_functions": 3}'
```

### Step 4: Task Complete

**When**: All validation passed and task is complete

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action TASK_COMPLETE \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result SUCCESS \
  --details '{"total_time_minutes": 45, "approvals": 3, "regressions": 0}'
```

---

## Querying the Audit Log

### View All Entries from Last 24 Hours

```bash
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text
```

### View Entries for a Specific Artifact

```bash
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json
```

### View Entries by a Specific Agent

```bash
bash ~/.kiro/scripts/view_audit.sh --agent agent-1 --format text
```

### View Entries for a Specific Action

```bash
bash ~/.kiro/scripts/view_audit.sh --action AKR_RETRIEVE --format text
```

### Export to CSV for Analysis

```bash
bash ~/.kiro/scripts/view_audit.sh --since 168 --format csv > audit_report.csv
```

### View Decision Trail for a Task

```bash
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json | \
  jq '.entries | sort_by(.timestamp) | .[] | "\(.timestamp) [\(.phase)] \(.action) → \(.result)"'
```

---

## Integration Checklist

- [ ] audit_log.sh implemented ✅
- [ ] view_audit.sh implemented ✅
- [ ] Environment variables configured
- [ ] Audit log directory created
- [ ] Workflow rules updated with audit_log.sh calls
- [ ] Test logging with sample task
- [ ] Test view_audit.sh queries
- [ ] Test log rotation
- [ ] Document audit logging in team wiki
- [ ] Train team on audit log usage

---

## See Also

- `.kiro/docs/AUDIT_LOGGING_REFERENCE.md` — Commands and examples
- `.kiro/docs/AGENT_QUICK_START.md` — Quick start guide
- `.kiro/steering/genero-context-workflow.md` — Workflow rules

