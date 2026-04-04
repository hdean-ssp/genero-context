# Audit Logging Reference

**Phase 1 — Complete and Ready to Use**

---

## Quick Commands

### Log an Action

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action ACTION_TYPE \
  --phase PHASE \
  --hat HAT \
  --artifact-type TYPE \
  --artifact-name NAME \
  --result RESULT \
  [--details JSON] \
  [--error ERROR_MSG] \
  [--duration-ms MS]
```

### View Audit Log

```bash
# View all entries from last 24 hours
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text

# View entries for specific artifact
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json

# View entries by specific agent
bash ~/.kiro/scripts/view_audit.sh --agent agent-1 --format csv

# Export to CSV
bash ~/.kiro/scripts/view_audit.sh --since 168 --format csv > audit_report.csv
```

---

## Common Actions

| Action | When | Example |
|--------|------|---------|
| AKR_RETRIEVE | Retrieving from AKR | `--result FOUND` or `NOT_FOUND` |
| GENERO_QUERY | Querying genero-tools | `--result SUCCESS` or `FAILURE` |
| PLAN_PRESENTED | Plan ready for review | `--result PENDING_APPROVAL` |
| HUMAN_APPROVAL | Human approves | `--result APPROVED` |
| IMPL_START | Starting implementation | `--result IN_PROGRESS` |
| IMPL_END | Implementation complete | `--result SUCCESS` |
| WORK_PRESENTED | Work ready for review | `--result PENDING_REVIEW` |
| HUMAN_REVIEW | Human reviews | `--result APPROVED` |
| VALIDATION_START | Starting validation | `--result IN_PROGRESS` |
| AKR_COMMIT | Committing to AKR | `--result SUCCESS` |
| TASK_COMPLETE | Task complete | `--result SUCCESS` |

---

## Phases & Hats

**Phases**: INCEPTION, CONSTRUCTION, OPERATION  
**Hats**: PLANNER, BUILDER, REVIEWER  
**Artifact Types**: function, module, file, issue, pattern

---

## Examples

### Example 1: Log AKR Retrieval

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_RETRIEVE \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name process_order \
  --result FOUND \
  --details '{"status": "active", "complexity": 8}'
```

### Example 2: Log genero-tools Query

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action GENERO_QUERY \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name process_order \
  --result SUCCESS \
  --duration-ms 145 \
  --details '{"complexity": 8, "dependents": 12}'
```

### Example 3: Log Query Failure

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action GENERO_QUERY \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name nonexistent \
  --result FAILURE \
  --error "Function not found in database"
```

### Example 4: Log Task Complete

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action TASK_COMPLETE \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name process_order \
  --result SUCCESS \
  --details '{"total_time_minutes": 45, "approvals": 3, "regressions": 0}'
```

---

## Integration Points

### Inception Phase (Planner Hat)

**Step 1: AKR Check**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_RETRIEVE \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result FOUND
```

**Step 2: genero-tools Queries**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action GENERO_QUERY \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result SUCCESS \
  --duration-ms "$DURATION_MS"
```

**Step 3: Plan Presented**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action PLAN_PRESENTED \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result PENDING_APPROVAL
```

**Step 4: Human Approval**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action HUMAN_APPROVAL \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result APPROVED
```

### Construction Phase (Builder Hat)

**Step 1: Implementation Start**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action IMPL_START \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result IN_PROGRESS
```

**Step 2: Implementation End**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action IMPL_END \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result SUCCESS \
  --details '{"files_modified": 2, "tests_passed": 15}'
```

**Step 3: Work Presented**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action WORK_PRESENTED \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result PENDING_REVIEW
```

**Step 4: Human Review**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action HUMAN_REVIEW \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result APPROVED
```

### Operation Phase (Reviewer Hat)

**Step 1: Validation Start**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action VALIDATION_START \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result IN_PROGRESS
```

**Step 2: AKR Commit**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_COMMIT \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result SUCCESS \
  --details '{"action": "append", "findings": 3}'
```

**Step 3: Task Complete**
```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action TASK_COMPLETE \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name "$FUNCTION_NAME" \
  --result SUCCESS
```

---

## Output Formats

### Text Format (Default)

```bash
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text
```

Output:
```
TIMESTAMP                 AGENT        ACTION              PHASE          HAT      ARTIFACT             RESULT
================================================================================================================
2026-03-31T10:20:40Z      agent-1      TASK_COMPLETE       OPERATION      REVIEWER process_order        SUCCESS
2026-03-31T10:20:35Z      agent-1      AKR_COMMIT          OPERATION      REVIEWER process_order        SUCCESS
```

### JSON Format

```bash
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json
```

Output:
```json
{
  "generated": "2026-03-31T14:22:15Z",
  "entries": [
    {
      "timestamp": "2026-03-31T10:20:40Z",
      "agent_id": "agent-1",
      "action": "TASK_COMPLETE",
      "phase": "OPERATION",
      "hat": "REVIEWER",
      "artifact_name": "process_order",
      "result": "SUCCESS"
    }
  ]
}
```

### CSV Format

```bash
bash ~/.kiro/scripts/view_audit.sh --since 168 --format csv > audit_report.csv
```

---

## Environment Setup

Add to your shell configuration (`.bashrc`, `.zshrc`, etc.):

```bash
# Audit logging
export GENERO_AKR_AUDIT_LOG="$BRODIR/etc/genero-akr/audit.log"
export GENERO_AKR_AUDIT_RETENTION_DAYS=30

# Optional: Enable debug logging
export DEBUG_AUDIT_LOG=0  # Set to 1 for debug output
```

---

## Troubleshooting

### "Failed to acquire lock on audit log"

**Cause**: Another process is writing to the audit log  
**Solution**: Wait a moment and retry. Lock timeout is 10 seconds.

### "No audit log found"

**Cause**: Audit log hasn't been created yet  
**Solution**: Run audit_log.sh once to create it

### "jq: command not found"

**Cause**: jq is not installed  
**Solution**: Install jq: `sudo apt-get install jq` (Linux) or `brew install jq` (macOS)

### Audit log growing too large

**Cause**: Retention period too long  
**Solution**: Reduce `GENERO_AKR_AUDIT_RETENTION_DAYS` or archive old logs

---

## Performance

- **Logging overhead**: <5ms per entry
- **File locking**: Handles concurrent writes safely
- **Log rotation**: Automatic daily
- **Query performance**: <100ms for 1000+ entries

---

## See Also

- `.kiro/docs/AUDIT_LOGGING_INTEGRATION.md` — Where to log at each phase
- `.kiro/docs/AGENT_QUICK_START.md` — Quick start guide
- `.kiro/steering/genero-context-workflow.md` — Workflow rules

