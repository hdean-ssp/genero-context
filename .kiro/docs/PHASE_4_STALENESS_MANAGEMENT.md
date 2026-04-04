# Phase 4: Staleness Management Implementation

**Status**: 📋 Ready for implementation  
**Effort**: 5 hours  
**Priority**: MEDIUM  
**Depends on**: Phase 3 (recommended)

---

## Overview

Automatically detect stale knowledge and provide refresh recommendations.

**Features**:
- Age-based staleness thresholds
- Automatic staleness detection
- Refresh recommendations
- Auto-refresh on task start

---

## Implementation Tasks

### Task 1: Implement detect_staleness.sh (1 hour)

**Deliverable**: `.kiro/scripts/detect_staleness.sh`

**What it does**:
- Check each AKR entry against staleness thresholds
- Mark as: FRESH, AGING, STALE, POTENTIALLY_STALE
- Output JSON with status for each artifact

**Usage**:
```bash
bash ~/.kiro/scripts/detect_staleness.sh
bash ~/.kiro/scripts/detect_staleness.sh --type function
bash ~/.kiro/scripts/detect_staleness.sh --artifact-name process_order
```

**Output**:
```json
{
  "artifacts": [
    {
      "name": "process_order",
      "type": "function",
      "status": "STALE",
      "days_since_update": 35,
      "threshold": 30,
      "reason": "Age exceeds threshold"
    }
  ]
}
```

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 4 section)

---

### Task 2: Implement generate_staleness_report.sh (1 hour)

**Deliverable**: `.kiro/scripts/generate_staleness_report.sh`

**What it does**:
- Aggregate staleness status
- Show refresh recommendations
- Generate reports

**Usage**:
```bash
bash ~/.kiro/scripts/generate_staleness_report.sh
bash ~/.kiro/scripts/generate_staleness_report.sh --format json
bash ~/.kiro/scripts/generate_staleness_report.sh --format csv > report.csv
```

**Output**:
```
# Staleness Report
Generated: 2026-04-01T14:22:15Z

## Summary
- Total Artifacts: 150
- FRESH: 120 (80%)
- AGING: 20 (13%)
- STALE: 8 (5%)
- POTENTIALLY_STALE: 2 (1%)

## Refresh Recommendations
- process_order (function): STALE, 35 days old
- validate_order (function): AGING, 28 days old
- payment_module (module): STALE, 65 days old
```

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 4 section)

---

### Task 3: Update AKR Document Format (30 min)

**What to do**:
1. Add staleness fields to AKR documents
2. Update document template

**New fields**:
```markdown
**Staleness Status:** FRESH
**Days Since Update:** 1
**Refresh Recommended:** false
```

**Files to update**:
- `.kiro/steering/genero-akr-workflow.md` (document format section)

---

### Task 4: Create Auto-Refresh Hook (30 min)

**Deliverable**: `.kiro/hooks/akr-auto-refresh-stale.kiro.hook`

**What it does**:
- Trigger: When agent touches a stale artifact
- Action: Re-query genero-tools, update AKR

**Hook configuration**:
```json
{
  "name": "AKR Auto-Refresh Stale",
  "version": "1.0.0",
  "when": {
    "type": "preToolUse",
    "toolTypes": ".*retrieve_knowledge.*"
  },
  "then": {
    "type": "askAgent",
    "prompt": "Knowledge is stale. Consider re-querying genero-tools and updating AKR."
  }
}
```

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 4 section)

---

### Task 5: Workflow Integration (1 hour)

**What to do**:
1. Add staleness check to Planner Hat
2. Update workflow rules
3. Document integration points

**New step in Planner Hat**:
```
"Check knowledge staleness"
For each artifact:
1. Run detect_staleness.sh --artifact-name NAME
2. If status is STALE or POTENTIALLY_STALE:
   a. Re-query genero-tools
   b. Compare with existing knowledge
   c. Update AKR with --action update
   d. Log refresh to audit trail
3. If status is AGING:
   a. Note in plan that knowledge is aging
   b. Plan to refresh if making changes
```

**Files to update**:
- `.kiro/steering/genero-context-workflow.md`

---

### Task 6: Testing (1 hour)

**What to test**:
- [ ] Staleness detection accuracy
- [ ] Refresh triggering
- [ ] Report generation
- [ ] Workflow integration

**Test cases**:
1. Create artifact, verify FRESH status
2. Wait 30+ days (or mock), verify STALE status
3. Verify refresh recommendations
4. Verify auto-refresh hook triggers
5. Verify AKR updated after refresh

---

## Success Criteria

- ✅ Stale knowledge automatically detected
- ✅ Refresh recommendations provided
- ✅ Refresh history tracked in audit log
- ✅ Knowledge quality improves over time
- ✅ Agents can see staleness status
- ✅ All tests passing

---

## Staleness Thresholds

**Default configuration** (configurable in staleness.yaml):
- Functions: 30 days old
- Modules: 60 days old
- Issues: 90 days old

**Staleness statuses**:
- FRESH: Recently updated
- AGING: Approaching threshold
- STALE: Exceeds threshold
- POTENTIALLY_STALE: Source file changed

---

## How to Pick This Up

1. **Read the design**: `FRAMEWORK_IMPROVEMENTS.md` (Phase 4 section)
2. **Start with Task 1**: Implement detect_staleness.sh (1 hour)
3. **Then Task 2**: Implement generate_staleness_report.sh (1 hour)
4. **Then Task 3**: Update AKR document format (30 min)
5. **Then Task 4**: Create auto-refresh hook (30 min)
6. **Then Task 5**: Workflow integration (1 hour)
7. **Then Task 6**: Testing (1 hour)

---

## Related Documentation

- `FRAMEWORK_IMPROVEMENTS.md` — Detailed analysis and design
- `IMPLEMENTATION_STATUS.md` — Current status and roadmap
- `PHASE_3_CHANGE_DETECTION.md` — Previous phase
- `PHASE_5_INTEGRATION_TESTING.md` — Next phase

---

## Questions?

See `.kiro/docs/IMPLEMENTATION_STATUS.md` for overview and next steps.

