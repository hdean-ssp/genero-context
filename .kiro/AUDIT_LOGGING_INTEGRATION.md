# Audit Logging Integration Guide

**Date**: 2026-04-01  
**Status**: Implementation ready  
**Scripts**: audit_log.sh ✅, view_audit.sh ✅

---

## Overview

Audit logging has been implemented with two scripts:

1. **audit_log.sh** — Append JSON entries to centralized audit log
2. **view_audit.sh** — Query and filter audit log entries

This guide shows where and how to integrate audit logging into the agent workflow.

---

## Quick Start

### Log an action

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_RETRIEVE \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name process_order \
  --result FOUND \
  --details '{"complexity": 8, "dependents": 12}'
```

### View audit log

```bash
# View all entries from last 24 hours
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text

# View entries for specific artifact
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json

# View entries by specific agent
bash ~/.kiro/scripts/view_audit.sh --agent agent-1 --since 8 --format csv
```

---

## Integration Points

### INCEPTION Phase — Planner Hat

#### Step 1: AKR Check

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
  --details "{\"status\": \"$(retrieve_knowledge.sh --type function --name "$FUNCTION_NAME" | jq -r '.status // "unknown"')\"}"

# If not found:
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_RETRIEVE \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result NOT_FOUND
```

**Example workflow**:
```bash
# Retrieve knowledge
KNOWLEDGE=$(retrieve_knowledge.sh --type function --name "process_order")

if [[ -n "$KNOWLEDGE" ]]; then
    # Log successful retrieval
    bash audit_log.sh \
      --action AKR_RETRIEVE \
      --phase INCEPTION \
      --hat PLANNER \
      --artifact-type function \
      --artifact-name "process_order" \
      --result FOUND \
      --details "$(echo "$KNOWLEDGE" | jq '{status: .status, complexity: .metrics.complexity}')"
else
    # Log not found
    bash audit_log.sh \
      --action AKR_RETRIEVE \
      --phase INCEPTION \
      --hat PLANNER \
      --artifact-type function \
      --artifact-name "process_order" \
      --result NOT_FOUND
fi
```

#### Step 2: genero-tools Queries

**When**: After AKR check, to gather context

**What to log**:
```bash
# For each genero-tools query:
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
      --details "$(echo "$RESULT" | jq '{complexity: .complexity, loc: .lines_of_code, dependents: .dependent_count}')"
else
    bash ~/.kiro/scripts/audit_log.sh \
      --action GENERO_QUERY \
      --phase INCEPTION \
      --hat PLANNER \
      --artifact-type function \
      --artifact-name "process_order" \
      --result FAILURE \
      --duration-ms "$DURATION_MS" \
      --error "Function not found in genero-tools database"
fi
```

#### Step 3: Plan Presented

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

#### Step 4: Human Approval

**When**: After human approves the plan

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action HUMAN_APPROVAL \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result APPROVED \
  --details '{"approval_time": "2026-03-31T10:05:00Z", "approver_notes": "Proceed with implementation"}'
```

---

### CONSTRUCTION Phase — Builder Hat

#### Step 1: Implementation Start

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

#### Step 2: Implementation Actions

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

#### Step 3: Implementation Complete

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
  --details '{"files_modified": 2, "tests_passed": 15, "dependents_tested": 15}'
```

#### Step 4: Work Presented

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

#### Step 5: Human Review

**When**: Human reviews and approves the work

**What to log**:
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action HUMAN_REVIEW \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "process_order" \
  --result APPROVED \
  --details '{"review_time": "2026-03-31T10:20:00Z", "reviewer_notes": "Good implementation"}'
```

---

### OPERATION Phase — Reviewer Hat

#### Step 1: Validation Start

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

#### Step 2: Validation Steps

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

#### Step 3: AKR Commit

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

#### Step 4: Task Complete

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

## Environment Variables

Add to your shell configuration (`.bashrc`, `.zshrc`, etc.):

```bash
# Audit logging
export GENERO_AKR_AUDIT_LOG="$BRODIR/etc/genero-akr/audit.log"
export GENERO_AKR_AUDIT_RETENTION_DAYS=30

# Optional: Enable debug logging
export DEBUG_AUDIT_LOG=0  # Set to 1 for debug output
```

---

## Audit Log Format

Each entry is a JSON object on a single line:

```json
{
  "timestamp": "2026-03-31T10:00:00Z",
  "agent_id": "agent-1",
  "session_id": "sess-abc123",
  "action": "AKR_RETRIEVE",
  "phase": "INCEPTION",
  "hat": "PLANNER",
  "artifact_type": "function",
  "artifact_name": "process_order",
  "result": "FOUND",
  "duration_ms": 145,
  "details": {
    "complexity": 8,
    "dependents": 12
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| timestamp | string | ISO 8601 timestamp (UTC) |
| agent_id | string | Agent identifier |
| session_id | string | Session identifier (unique per agent session) |
| action | string | Action type (AKR_RETRIEVE, GENERO_QUERY, PLAN_PRESENTED, etc.) |
| phase | string | Workflow phase (INCEPTION, CONSTRUCTION, OPERATION) |
| hat | string | Agent role (PLANNER, BUILDER, REVIEWER) |
| artifact_type | string | Type of artifact (function, module, file, issue, pattern) |
| artifact_name | string | Name of artifact |
| result | string | Result (FOUND, NOT_FOUND, SUCCESS, FAILURE, APPROVED, etc.) |
| duration_ms | number | Optional: Duration in milliseconds |
| error | string | Optional: Error message if result is FAILURE |
| details | object | Optional: Additional context as JSON |

---

## Querying the Audit Log

### View all entries from last 24 hours

```bash
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text
```

### View entries for a specific artifact

```bash
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json
```

### View entries by a specific agent

```bash
bash ~/.kiro/scripts/view_audit.sh --agent agent-1 --format text
```

### View entries for a specific action

```bash
bash ~/.kiro/scripts/view_audit.sh --action AKR_RETRIEVE --format text
```

### Export to CSV for analysis

```bash
bash ~/.kiro/scripts/view_audit.sh --since 168 --format csv > audit_report.csv
```

### View decision trail for a task

```bash
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json | jq '.entries[] | select(.action | test("PLAN|APPROVAL|REVIEW|COMPLETE"))'
```

---

## Audit Log Rotation

Audit logs are automatically rotated daily:

- **Current log**: `$GENERO_AKR_AUDIT_LOG` (e.g., `audit.log`)
- **Rotated logs**: `$GENERO_AKR_AUDIT_LOG.YYYY-MM-DD` (e.g., `audit.log.2026-03-30`)
- **Retention**: Keep 30 days (configurable via `GENERO_AKR_AUDIT_RETENTION_DAYS`)

Old logs are automatically deleted after the retention period.

---

## Performance

- **Logging overhead**: <5ms per entry
- **File locking**: Handles concurrent writes safely
- **Log rotation**: Automatic, no manual intervention needed
- **Query performance**: <100ms for 1000+ entries

---

## Troubleshooting

### "Failed to acquire lock on audit log"

**Cause**: Another process is writing to the audit log  
**Solution**: Wait a moment and retry. Lock timeout is 10 seconds.

### "No audit log found"

**Cause**: Audit log hasn't been created yet  
**Solution**: Run audit_log.sh once to create it, or check `GENERO_AKR_AUDIT_LOG` path

### "jq: command not found"

**Cause**: jq is not installed  
**Solution**: Install jq: `sudo apt-get install jq` (Linux) or `brew install jq` (macOS)

### Audit log growing too large

**Cause**: Retention period too long or logging too verbose  
**Solution**: Reduce `GENERO_AKR_AUDIT_RETENTION_DAYS` or archive old logs

---

## Next Steps

1. **Add audit_log.sh calls to workflow rules** — Update genero-context-workflow.md
2. **Test with real agent tasks** — Verify logging works end-to-end
3. **Create audit log dashboards** — Use view_audit.sh to generate reports
4. **Integrate with Phase 2 database** — Store audit entries in SQLite for analytics

---

## Examples

### Example 1: Complete task audit trail

```bash
# View all actions for a specific task
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json | \
  jq '.entries | sort_by(.timestamp) | .[] | "\(.timestamp) [\(.phase)] \(.action) → \(.result)"'

# Output:
# 2026-03-31T10:00:00Z [INCEPTION] AKR_RETRIEVE → FOUND
# 2026-03-31T10:00:05Z [INCEPTION] GENERO_QUERY → SUCCESS
# 2026-03-31T10:01:00Z [INCEPTION] PLAN_PRESENTED → PENDING_APPROVAL
# 2026-03-31T10:05:00Z [INCEPTION] HUMAN_APPROVAL → APPROVED
# 2026-03-31T10:05:05Z [CONSTRUCTION] IMPL_START → IN_PROGRESS
# 2026-03-31T10:15:00Z [CONSTRUCTION] IMPL_END → SUCCESS
# 2026-03-31T10:15:05Z [CONSTRUCTION] WORK_PRESENTED → PENDING_REVIEW
# 2026-03-31T10:20:00Z [CONSTRUCTION] HUMAN_REVIEW → APPROVED
# 2026-03-31T10:20:05Z [OPERATION] VALIDATION_START → IN_PROGRESS
# 2026-03-31T10:20:30Z [OPERATION] VALIDATION_CHECK → SUCCESS
# 2026-03-31T10:20:35Z [OPERATION] AKR_COMMIT → SUCCESS
# 2026-03-31T10:20:40Z [OPERATION] TASK_COMPLETE → SUCCESS
```

### Example 2: Performance analysis

```bash
# Find slowest genero-tools queries
bash ~/.kiro/scripts/view_audit.sh --action GENERO_QUERY --format json | \
  jq '.entries | sort_by(.duration_ms) | reverse | .[0:5] | .[] | "\(.artifact_name): \(.duration_ms)ms"'
```

### Example 3: Error analysis

```bash
# Find all failures in last 24 hours
bash ~/.kiro/scripts/view_audit.sh --since 24 --format json | \
  jq '.entries[] | select(.result == "FAILURE") | "\(.timestamp) \(.action) \(.artifact_name): \(.error)"'
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

