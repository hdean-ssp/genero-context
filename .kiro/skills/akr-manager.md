# AKR Manager Skill

**Purpose**: Deploy and maintain the system-wide Agent Knowledge Repository (AKR) at `$BRODIR/etc/genero-akr/`

**Keywords**: akr, knowledge, repository, validation, repair, maintenance

---

## Overview

The AKR Manager skill provides comprehensive tools to:
- Initialize and validate the AKR system
- Repair schema compliance issues in existing documents
- Maintain AKR consistency and integrity
- Monitor AKR health and statistics
- Clean up stale locks and logs

## Quick Start

### 1. Initialize AKR
```bash
bash ~/.kiro/scripts/setup_akr.sh
```

### 2. Verify AKR Health
```bash
bash ~/.kiro/scripts/verify_akr_consistency.sh
```

### 3. Validate All Documents
```bash
source ~/.kiro/scripts/akr-config.sh
bash ~/.kiro/scripts/validate_knowledge.sh
```

### 4. Repair Schema Issues
```bash
source ~/.kiro/scripts/akr-config.sh
bash ~/.kiro/scripts/repair_akr.sh --fix-all
```

### 5. Check Statistics
```bash
source ~/.kiro/scripts/akr-config.sh
bash ~/.kiro/scripts/get_statistics.sh
```

---

## AKR Manager Commands

### Setup & Initialization

**Initialize AKR structure**
```bash
bash ~/.kiro/scripts/setup_akr.sh
```
Creates all required directories, schema files, and metadata. Safe to run multiple times.

**Verify AKR consistency**
```bash
bash ~/.kiro/scripts/verify_akr_consistency.sh
```
Checks directory structure, permissions, and metadata files. Returns exit code 0 if all checks pass.

---

### Validation & Repair

**Validate all documents**
```bash
source ~/.kiro/scripts/akr-config.sh
bash ~/.kiro/scripts/validate_knowledge.sh
```
Checks all documents for schema compliance. Reports invalid metadata, timestamps, and missing sections.

**Repair all documents (dry-run)**
```bash
source ~/.kiro/scripts/akr-config.sh
bash ~/.kiro/scripts/repair_akr.sh --dry-run --fix-all
```
Shows what would be fixed without making changes.

**Repair all documents (apply fixes)**
```bash
source ~/.kiro/scripts/akr-config.sh
bash ~/.kiro/scripts/repair_akr.sh --fix-all
```
Applies all fixes:
- Adds missing Type field (inferred from directory)
- Adds missing Status field (defaults to "active")
- Fixes invalid timestamp formats (converts to ISO 8601)
- Adds missing required sections (Key Findings, Metrics, Dependencies, Analysis History)

**Repair specific file**
```bash
source ~/.kiro/scripts/akr-config.sh
bash ~/.kiro/scripts/repair_akr.sh --file functions/my_function.md --fix-all
```

---

### Maintenance

**Clean up stale locks**
```bash
source ~/.kiro/scripts/akr-config.sh
find "$GENERO_AKR_BASE_PATH/.locks" -type d -mmin +5 -exec rmdir {} \; 2>/dev/null
```
Removes lock directories older than 5 minutes.

**View AKR statistics**
```bash
source ~/.kiro/scripts/akr-config.sh
bash ~/.kiro/scripts/get_statistics.sh
```
Shows document counts, status distribution, and agent activity.

**View AKR logs**
```bash
source ~/.kiro/scripts/akr-config.sh
tail -50 "$GENERO_AKR_BASE_PATH/.logs/akr.log"
```

---

## AKR Document Schema

All AKR documents must follow this structure:

```markdown
# [Artifact Name]

**Type:** file | function | module | pattern | issue
**Path:** [source file path, or N/A]
**Last Updated:** [ISO 8601 timestamp, e.g., 2026-03-31T10:00:00Z]
**Updated By:** [Agent name/ID]
**Status:** active | deprecated | archived

## Summary
[1-2 sentence overview]

## Key Findings
- Finding 1
- Finding 2

## Metrics
- Complexity: [integer or N/A]
- Lines of Code: [integer or N/A]
- Parameter Count: [integer or N/A]
- Dependent Count: [integer or N/A]

## Dependencies
- Calls: [comma-separated list or N/A]
- Called By: [comma-separated list or N/A]

## Known Issues
- Issue 1: [description]

## Recommendations
- Recommendation 1

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-31 | agent-1 | initial_analysis | [notes] |
```

---

## Common Issues & Solutions

### Issue: "AKR base path does not exist"
**Solution:**
```bash
bash ~/.kiro/scripts/setup_akr.sh
```

### Issue: "Permission denied" on AKR operations
**Solution:**
```bash
source ~/.kiro/scripts/akr-config.sh
chmod 775 "$GENERO_AKR_BASE_PATH"
chmod 775 "$GENERO_AKR_BASE_PATH"/*
```

### Issue: "Failed to acquire lock after 30s"
**Solution:**
```bash
source ~/.kiro/scripts/akr-config.sh
find "$GENERO_AKR_BASE_PATH/.locks" -type d -mmin +5 -exec rmdir {} \; 2>/dev/null
```

### Issue: Documents have invalid metadata
**Solution:**
```bash
source ~/.kiro/scripts/akr-config.sh
bash ~/.kiro/scripts/repair_akr.sh --fix-all
```

---

## Configuration

AKR paths are configured in `~/.kiro/scripts/akr-config.sh`:

```bash
# Default AKR location
GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"

# Override by setting environment variable
export GENERO_AKR_BASE_PATH="/custom/path/to/akr"
```

---

## Workflow Integration

The AKR Manager skill integrates with the Genero Context Framework:

1. **Inception Phase**: Use `retrieve_knowledge.sh` to check existing knowledge
2. **Construction Phase**: Use `commit_knowledge.sh` to save findings
3. **Operation Phase**: Use `validate_knowledge.sh` to verify quality

See `genero-context-workflow.md` for complete workflow details.

---

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup_akr.sh` | Initialize AKR structure | `bash setup_akr.sh` |
| `verify_akr_consistency.sh` | Check AKR health | `bash verify_akr_consistency.sh` |
| `validate_knowledge.sh` | Validate document schema | `bash validate_knowledge.sh` |
| `repair_akr.sh` | Fix schema issues | `bash repair_akr.sh --fix-all` |
| `get_statistics.sh` | Show AKR statistics | `bash get_statistics.sh` |
| `retrieve_knowledge.sh` | Get knowledge document | `bash retrieve_knowledge.sh --type function --name foo` |
| `commit_knowledge.sh` | Save knowledge document | `bash commit_knowledge.sh --type function --name foo --findings findings.json --action create` |
| `search_knowledge.sh` | Search knowledge | `bash search_knowledge.sh --query "pattern"` |
| `cleanup_akr_locks.sh` | Clean stale locks | `bash cleanup_akr_locks.sh` |

---

## Next Steps

1. Run `bash ~/.kiro/scripts/setup_akr.sh` to initialize
2. Run `bash ~/.kiro/scripts/verify_akr_consistency.sh` to verify
3. Run `bash ~/.kiro/scripts/validate_knowledge.sh` to check documents
4. Run `bash ~/.kiro/scripts/repair_akr.sh --fix-all` to fix issues
5. See `genero-context-workflow.md` for workflow integration
