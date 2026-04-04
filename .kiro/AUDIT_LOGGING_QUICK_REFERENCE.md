# Audit Logging Quick Reference

**Quick commands for audit logging**

---

## Log an Action

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

### Common Actions

| Action | When | Example |
|--------|------|---------|
| AKR_RETRIEVE | Retrieving from AKR | `--action AKR_RETRIEVE --result FOUND` |
| GENERO_QUERY | Querying genero-tools | `--action GENERO_QUERY --result SUCCESS` |
| PLAN_PRESENTED | Plan ready for review | `--action PLAN_PRESENTED --result PENDING_APPROVAL` |
| HUMAN_APPROVAL | Human approves | `--action HUMAN_APPROVAL --result APPROVED` |
| IMPL_START | Starting implementation | `--action IMPL_START --result IN_PROGRESS` |
| IMPL_END | Implementation complete | `--action IMPL_END --result SUCCESS` |
| WORK_PRESENTED | Work ready for review | `--action WORK_PRESENTED --result PENDING_REVIEW` |
| HUMAN_REVIEW | Human reviews | `--action HUMAN_REVIEW --result APPROVED` |
| VALIDATION_START | Starting validation | `--action VALIDATION_START --result IN_PROGRESS` |
| AKR_COMMIT | Committing to AKR | `--action AKR_COMMIT --result SUCCESS` |
| TASK_COMPLETE | Task complete | `--action TASK_COMPLETE --result SUCCESS` |

### Common Phases

- `INCEPTION` — Planning phase
- `CONSTRUCTION` — Implementation phase
- `OPERATION` — Validation phase

### Common Hats

- `PLANNER` — Planning role
- `BUILDER` — Implementation role
- `REVIEWER` — Validation role

### Common Results

- `FOUND` — Found in AKR
- `NOT_FOUND` — Not found in AKR
- `SUCCESS` — Operation succeeded
- `FAILURE` — Operation failed
- `APPROVED` — Human approved
- `PENDING_APPROVAL` — Waiting for approval
- `IN_PROGRESS` — Currently executing

---

## View Audit Log

```bash
bash ~/.kiro/scripts/view_audit.sh [OPTIONS]
```

### Common Queries

```bash
# View all entries from last 24 hours
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text

# View entries for specific artifact
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json

# View entries by specific agent
bash ~/.kiro/scripts/view_audit.sh --agent agent-1 --format text

# View entries for specific action
bash ~/.kiro/scripts/view_audit.sh --action AKR_RETRIEVE --format text

# Export to CSV
bash ~/.kiro/scripts/view_audit.sh --since 168 --format csv > audit_report.csv

# View last 50 entries
bash ~/.kiro/scripts/view_audit.sh --limit 50 --format text
```

### Output Formats

- `text` — Human-readable table (default)
- `json` — JSON format for parsing
- `csv` — CSV format for spreadsheets

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

### Example 4: Log Plan Presentation

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action PLAN_PRESENTED \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name process_order \
  --result PENDING_APPROVAL \
  --details '{"steps": 3, "risks": 2, "dependents_to_test": 15}'
```

### Example 5: Log Human Approval

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action HUMAN_APPROVAL \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name process_order \
  --result APPROVED
```

### Example 6: Log Implementation Complete

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action IMPL_END \
  --phase CONSTRUCTION \
  --hat BUILDER \
  --artifact-type function \
  --artifact-name process_order \
  --result SUCCESS \
  --details '{"files_modified": 2, "tests_passed": 15, "regressions": 0}'
```

### Example 7: Log AKR Commit

```bash
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_COMMIT \
  --phase OPERATION \
  --hat REVIEWER \
  --artifact-type function \
  --artifact-name process_order \
  --result SUCCESS \
  --details '{"action": "append", "findings": 3, "issues": 0}'
```

### Example 8: Log Task Complete

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

## View Examples

### View All Entries from Last 24 Hours

```bash
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text
```

Output:
```
# Audit Log
**Generated:** 2026-03-31T14:22:15Z

**Filters:**
- Since: 24 hours ago

TIMESTAMP                 AGENT        ACTION              PHASE          HAT      ARTIFACT             RESULT
================================================================================================================
2026-03-31T10:20:40Z      agent-1      TASK_COMPLETE       OPERATION      REVIEWER process_order        SUCCESS
2026-03-31T10:20:35Z      agent-1      AKR_COMMIT          OPERATION      REVIEWER process_order        SUCCESS
2026-03-31T10:20:30Z      agent-1      VALIDATION_CHECK    OPERATION      REVIEWER process_order        SUCCESS
2026-03-31T10:20:05Z      agent-1      VALIDATION_START    OPERATION      REVIEWER process_order        IN_PROGRESS
2026-03-31T10:15:05Z      agent-1      WORK_PRESENTED      CONSTRUCTION   BUILDER  process_order        PENDING_REVIEW
2026-03-31T10:15:00Z      agent-1      IMPL_END            CONSTRUCTION   BUILDER  process_order        SUCCESS
2026-03-31T10:05:05Z      agent-1      IMPL_START          CONSTRUCTION   BUILDER  process_order        IN_PROGRESS
2026-03-31T10:05:00Z      agent-1      HUMAN_APPROVAL      INCEPTION      PLANNER  process_order        APPROVED
2026-03-31T10:01:00Z      agent-1      PLAN_PRESENTED      INCEPTION      PLANNER  process_order        PENDING_APPROVAL
2026-03-31T10:00:05Z      agent-1      GENERO_QUERY        INCEPTION      PLANNER  process_order        SUCCESS
2026-03-31T10:00:00Z      agent-1      AKR_RETRIEVE        INCEPTION      PLANNER  process_order        FOUND

**Total Entries Shown:** 11 (limit: 100)
```

### View Entries for Specific Artifact (JSON)

```bash
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json
```

Output:
```json
{
  "generated": "2026-03-31T14:22:15Z",
  "filters": {
    "agent": null,
    "action": null,
    "artifact": "process_order",
    "since_hours": null,
    "limit": 100
  },
  "entries": [
    {
      "timestamp": "2026-03-31T10:20:40Z",
      "agent_id": "agent-1",
      "session_id": "sess-abc123",
      "action": "TASK_COMPLETE",
      "phase": "OPERATION",
      "hat": "REVIEWER",
      "artifact_type": "function",
      "artifact_name": "process_order",
      "result": "SUCCESS",
      "details": {
        "total_time_minutes": 45,
        "approvals": 3,
        "regressions": 0
      }
    }
  ]
}
```

### View Entries by Agent (CSV)

```bash
bash ~/.kiro/scripts/view_audit.sh --agent agent-1 --format csv
```

Output:
```csv
timestamp,agent_id,action,phase,hat,artifact_name,result,duration_ms,error
2026-03-31T10:20:40Z,agent-1,TASK_COMPLETE,OPERATION,REVIEWER,process_order,SUCCESS,,
2026-03-31T10:20:35Z,agent-1,AKR_COMMIT,OPERATION,REVIEWER,process_order,SUCCESS,,
2026-03-31T10:20:30Z,agent-1,VALIDATION_CHECK,OPERATION,REVIEWER,process_order,SUCCESS,,
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

- `.kiro/AUDIT_LOGGING_INTEGRATION.md` — Full integration guide
- `FRAMEWORK_STATUS_AND_ROADMAP.md` — Comprehensive roadmap
- `FRAMEWORK_IMPLEMENTATION_SUMMARY.md` — Implementation summary

