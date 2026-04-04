# Phase 3: Change Detection Implementation

**Status**: 📋 Ready for implementation  
**Effort**: 6 hours  
**Priority**: MEDIUM  
**Depends on**: Phase 2 (optional, but recommended)

---

## Overview

Detect when source code changes and automatically mark affected AKR entries as stale.

**How it works**:
```
Developer modifies function
  ↓
Source file hash changes
  ↓
detect_source_changes.sh finds change
  ↓
AKR entry marked as "potentially_stale"
  ↓
Next agent re-queries genero-tools
  ↓
AKR updated with new metrics
```

---

## Implementation Tasks

### Task 1: Implement track_source_hashes.sh (1 hour)

**Deliverable**: `.kiro/scripts/track_source_hashes.sh`

**What it does**:
- Compute SHA256 hashes of all .4gl files
- Store in `$GENERO_AKR_SOURCE_HASHES`
- Format: JSON {filename: hash}

**Usage**:
```bash
bash ~/.kiro/scripts/track_source_hashes.sh
```

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 3 section)

---

### Task 2: Implement detect_source_changes.sh (1 hour)

**Deliverable**: `.kiro/scripts/detect_source_changes.sh`

**What it does**:
- Compare current hashes with stored hashes
- Identify changed files
- For each changed file, identify affected functions
- Mark related AKR entries as "potentially_stale"

**Usage**:
```bash
bash ~/.kiro/scripts/detect_source_changes.sh
```

**Output**: JSON with list of changed files and affected artifacts

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 3 section)

---

### Task 3: Create staleness.yaml Config (30 min)

**Deliverable**: `$BRODIR/etc/genero-akr/config/staleness.yaml`

**What it contains**:
```yaml
staleness_thresholds:
  function:
    age_days: 30
    source_change: true
    dependent_change: true
  module:
    age_days: 60
    source_change: true
  issue:
    age_days: 90
    source_change: false

refresh_strategy:
  auto_refresh: true
  refresh_on_task_start: true
  refresh_threshold: 30
```

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 3 section)

---

### Task 4: Create Hook (30 min)

**Deliverable**: `.kiro/hooks/akr-refresh-on-source-change.kiro.hook`

**What it does**:
- Trigger: When source files change
- Action: Mark affected AKR entries as stale

**Hook configuration**:
```json
{
  "name": "AKR Refresh on Source Change",
  "version": "1.0.0",
  "when": {
    "type": "fileEdited",
    "patterns": ["**/*.4gl"]
  },
  "then": {
    "type": "askAgent",
    "prompt": "Source files changed. Run detect_source_changes.sh to mark stale knowledge."
  }
}
```

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 3 section)

---

### Task 5: Workflow Integration (1 hour)

**What to do**:
1. Add change detection step to Planner Hat
2. Update workflow rules to check for changes
3. Document integration points

**New step in Planner Hat**:
```
"Check for source changes"
- Run detect_source_changes.sh
- If changes detected:
  - Identify affected artifacts
  - Mark as "potentially_stale"
  - Re-query genero-tools
  - Update AKR
```

**Files to update**:
- `.kiro/steering/genero-context-workflow.md`

---

### Task 6: Testing (1 hour)

**What to test**:
- [ ] Hash accuracy
- [ ] Change detection
- [ ] Staleness marking
- [ ] Workflow integration

**Test cases**:
1. Modify a function, verify hash changes
2. Verify affected artifacts marked as stale
3. Verify next agent re-queries genero-tools
4. Verify AKR updated with new metrics

---

## Success Criteria

- ✅ Source hashes tracked correctly
- ✅ Changes detected within 1 minute
- ✅ Affected artifacts marked as stale
- ✅ <50ms overhead per task start
- ✅ Workflow integration working
- ✅ All tests passing

---

## How to Pick This Up

1. **Read the design**: `FRAMEWORK_IMPROVEMENTS.md` (Phase 3 section)
2. **Start with Task 1**: Implement track_source_hashes.sh (1 hour)
3. **Then Task 2**: Implement detect_source_changes.sh (1 hour)
4. **Then Task 3**: Create staleness.yaml config (30 min)
5. **Then Task 4**: Create hook (30 min)
6. **Then Task 5**: Workflow integration (1 hour)
7. **Then Task 6**: Testing (1 hour)

---

## Related Documentation

- `FRAMEWORK_IMPROVEMENTS.md` — Detailed analysis and design
- `IMPLEMENTATION_STATUS.md` — Current status and roadmap
- `PHASE_4_STALENESS_MANAGEMENT.md` — Next phase (staleness detection)

---

## Questions?

See `.kiro/docs/IMPLEMENTATION_STATUS.md` for overview and next steps.

