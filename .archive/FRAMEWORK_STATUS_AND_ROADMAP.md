# Framework Status & Implementation Roadmap

**Date**: 2026-04-01  
**Status**: Phase 1 & 2 Complete, Phase 3-5 In Progress  
**Overall Progress**: 60% complete

---

## Executive Summary

The Genero Context Framework has been comprehensively analyzed and partially implemented. Three critical gaps have been identified and solutions designed:

1. **Audit Logging** — Partially implemented (audit_trail.sh exists, but audit_log.sh is empty)
2. **Knowledge Storage** — Partially implemented (markdown + basic indexing, but no SQLite database)
3. **Dynamic Codebase Support** — Not yet implemented (no change detection or staleness management)

This document provides:
- Current implementation status
- What's working and what's not
- Specific gaps and blockers
- Prioritized implementation roadmap
- Effort estimates and success criteria

---

## Issue 1: Audit Logging — Status: 60% Complete

### What's Implemented ✅

- **audit_trail.sh** — Reads existing audit logs and generates reports
- **Integration points identified** — Workflow rules document where logging should happen
- **Log format designed** — JSON Lines format specified in FRAMEWORK_IMPROVEMENTS.md
- **Hooks created** — Three hooks for AKR quality management

### What's Missing ❌

- **audit_log.sh is empty** — Core logging script not implemented
- **No centralized audit log file** — No persistent append-only log
- **No file locking** — Concurrent writes not protected
- **No log rotation** — No daily rotation or retention policy
- **No integration** — Workflow rules don't call audit_log.sh yet
- **No view_audit.sh** — Query interface not implemented

### Blocker

**audit_log.sh must be implemented first** — it's the foundation for all other audit features.

### Implementation Plan

**Phase 1a: Implement audit_log.sh (1 hour)**

```bash
# Create ~/.kiro/scripts/audit_log.sh
# Features:
# - Append JSON entries to $GENERO_AKR_AUDIT_LOG
# - File locking for concurrent writes
# - Automatic timestamp
# - Rotation trigger (daily)
# - Error handling

# Usage:
bash audit_log.sh --action AKR_RETRIEVE \
  --phase INCEPTION --hat PLANNER \
  --artifact-type function --artifact-name process_order \
  --result FOUND --details '{"complexity": 8, "dependents": 12}'
```

**Phase 1b: Implement view_audit.sh (1 hour)**

```bash
# Create ~/.kiro/scripts/view_audit.sh
# Features:
# - Query audit log with filters
# - Output formats: text, JSON, CSV
# - Time range filtering
# - Agent filtering
# - Decision trail for any artifact

# Usage:
bash view_audit.sh --agent agent-1 --since 24h --format text
bash view_audit.sh --artifact-name process_order --format json
```

**Phase 1c: Integrate with workflow (1 hour)**

Update `.kiro/steering/genero-context-workflow.md`:
- Add audit_log.sh calls at each gate
- Document what to log at each phase
- Add examples

**Phase 1d: Test (1 hour)**

- Concurrent writes
- Log rotation
- Query filtering
- Performance (<5ms per entry)

**Total effort**: 4 hours  
**Blocker removal**: YES — unblocks Phase 2 database integration

---

## Issue 2: Knowledge Storage — Status: 40% Complete

### What's Implemented ✅

- **Markdown repository** — Functions, modules, files, patterns, issues stored as .md
- **Basic indexing** — build_index.sh and search_indexed.sh exist
- **Metadata tracking** — update_metadata.sh maintains INDEX.md
- **Conflict detection** — merge_knowledge.sh handles concurrent writes
- **Comparison** — compare_knowledge.sh shows what changed

### What's Missing ❌

- **SQLite database** — No structured query capability
- **Database schema** — Not designed or implemented
- **sync_akr_db.sh** — Database rebuild script not created
- **query_akr.sh** — SQL query interface not implemented
- **Conflict detector** — detect_akr_conflicts.sh not created
- **Analytics** — No "what's high-risk?" queries possible

### Why It Matters

Current grep-based search is slow and limited:
- Can't find "all functions with complexity > 10"
- Can't find "all functions modified in last 7 days"
- Can't find "all issues affecting a specific function"
- Scales poorly (1000+ artifacts = slow searches)

### Implementation Plan

**Phase 2a: Design database schema (1 hour)**

```sql
-- Create tables:
-- artifacts (name, type, path, status, timestamps)
-- metrics (complexity, LOC, parameters, dependents)
-- findings (finding text, priority)
-- issues (issue type, severity)
-- audit_trail (action, agent, timestamp)
```

**Phase 2b: Implement sync_akr_db.sh (2 hours)**

```bash
# Parse markdown files
# Extract metadata and metrics
# Validate schema compliance
# Insert/update database
# Log sync results
```

**Phase 2c: Implement query_akr.sh (2 hours)**

```bash
# SQL query interface
# Supported queries:
# - Find high-complexity functions
# - Find recently modified artifacts
# - Find all issues affecting a function
# - Get statistics
# - Find conflicts
```

**Phase 2d: Implement detect_akr_conflicts.sh (1 hour)**

```bash
# Find artifacts modified by multiple agents
# Alert on potential conflicts
# Suggest merge strategy
```

**Phase 2e: Integration (1 hour)**

- Update commit_knowledge.sh to call sync_akr_db.sh
- Update workflow rules to use query_akr.sh
- Add database troubleshooting to operations guide

**Phase 2f: Test (2 hours)**

- Schema validation
- Sync accuracy
- Query performance (<100ms for 1000+ artifacts)
- Concurrent access

**Total effort**: 9 hours  
**Blocker removal**: NO — can proceed in parallel with Phase 1

---

## Issue 3: Dynamic Codebase Support — Status: 0% Complete

### What's Implemented ✅

- **Concept designed** — FRAMEWORK_IMPROVEMENTS.md has full design
- **Change detection approach** — Hash-based tracking specified
- **Staleness thresholds** — Configuration format designed
- **Refresh strategy** — Workflow integration points identified

### What's Missing ❌

- **track_source_hashes.sh** — Not implemented
- **detect_source_changes.sh** — Not implemented
- **detect_staleness.sh** — Not implemented
- **generate_staleness_report.sh** — Not implemented
- **staleness.yaml config** — Not created
- **Hooks** — akr-refresh-on-source-change not created
- **Workflow integration** — No change detection step in Planner Hat

### Why It Matters

Without this, agents work with stale knowledge:
- Function complexity changes but AKR not updated
- New dependents added but AKR not updated
- Tool gaps resolved but AKR not updated
- Decisions based on outdated metrics

### Implementation Plan

**Phase 3a: Implement track_source_hashes.sh (1 hour)**

```bash
# Compute SHA256 hashes of all .4gl files
# Store in $GENERO_AKR_SOURCE_HASHES
# Format: JSON {filename: hash}
```

**Phase 3b: Implement detect_source_changes.sh (1 hour)**

```bash
# Compare current hashes with stored hashes
# Identify changed files
# For each changed file, identify affected functions
# Mark related AKR entries as "potentially_stale"
```

**Phase 3c: Create staleness.yaml config (30 min)**

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
```

**Phase 3d: Implement detect_staleness.sh (1 hour)**

```bash
# Check each AKR entry against thresholds
# Mark as: FRESH, AGING, STALE, POTENTIALLY_STALE
# Output JSON with status for each artifact
```

**Phase 3e: Create hook (30 min)**

```
Hook: akr-refresh-on-source-change
Trigger: When source files change
Action: Mark affected AKR entries as stale
```

**Phase 3f: Workflow integration (1 hour)**

Add to Planner Hat:
```
New step: "Check for source changes"
- Run detect_source_changes.sh
- If changes detected:
  - Identify affected artifacts
  - Mark as "potentially_stale"
  - Re-query genero-tools
  - Update AKR
```

**Phase 3g: Test (1 hour)**

- Hash accuracy
- Change detection
- Staleness marking
- Workflow integration

**Total effort**: 6 hours  
**Blocker removal**: NO — can proceed in parallel

---

## Issue 4: Staleness Management — Status: 0% Complete

### What's Implemented ✅

- **Concept designed** — Full design in FRAMEWORK_IMPROVEMENTS.md
- **Thresholds specified** — Age-based and change-based triggers
- **Refresh strategy** — Automatic refresh on task start

### What's Missing ❌

- **detect_staleness.sh** — Not implemented (different from Phase 3)
- **generate_staleness_report.sh** — Not implemented
- **Staleness fields in AKR documents** — Not added
- **Auto-refresh hook** — Not created
- **Workflow step** — Not added to Planner Hat

### Why It Matters

Complements Phase 3 by:
- Automatically refreshing old knowledge
- Providing staleness reports
- Tracking knowledge quality over time
- Preventing use of outdated information

### Implementation Plan

**Phase 4a: Implement detect_staleness.sh (1 hour)**

```bash
# Check each AKR entry against staleness thresholds
# Mark as: FRESH, AGING, STALE, POTENTIALLY_STALE
# Output JSON with status
```

**Phase 4b: Implement generate_staleness_report.sh (1 hour)**

```bash
# Aggregate staleness status
# Show: total by status, refresh recommendations
# Output: text or JSON
```

**Phase 4c: Update AKR document format (30 min)**

Add fields:
```markdown
**Staleness Status:** FRESH
**Days Since Update:** 1
**Refresh Recommended:** false
```

**Phase 4d: Create auto-refresh hook (30 min)**

```
Hook: akr-auto-refresh-stale
Trigger: When agent touches a stale artifact
Action: Re-query genero-tools, update AKR
```

**Phase 4e: Workflow integration (1 hour)**

Add to Planner Hat:
```
New step: "Check knowledge staleness"
For each artifact:
1. Run detect_staleness.sh
2. If STALE or POTENTIALLY_STALE:
   - Re-query genero-tools
   - Compare with existing
   - Update AKR with --action update
```

**Phase 4f: Test (1 hour)**

- Staleness detection accuracy
- Refresh triggering
- Report generation
- Workflow integration

**Total effort**: 5 hours  
**Blocker removal**: NO — can proceed in parallel

---

## Current Blockers

### Blocker 1: audit_log.sh is empty

**Impact**: Audit logging not functional  
**Severity**: HIGH  
**Fix**: Implement audit_log.sh (1 hour)  
**Unblocks**: Phase 1b, 1c, 1d

### Blocker 2: No SQLite database

**Impact**: Can't query AKR efficiently  
**Severity**: MEDIUM  
**Fix**: Implement Phase 2 (9 hours)  
**Unblocks**: Analytics, conflict detection, performance

### Blocker 3: No change detection

**Impact**: Can't detect stale knowledge  
**Severity**: MEDIUM  
**Fix**: Implement Phase 3 (6 hours)  
**Unblocks**: Dynamic codebase support

---

## Implementation Roadmap

### Week 1: Audit Logging (4 hours)

**Priority**: HIGH — Foundation for compliance and debugging

- [ ] Implement audit_log.sh
- [ ] Implement view_audit.sh
- [ ] Integrate with workflow rules
- [ ] Test concurrent writes and rotation
- [ ] **Deliverable**: Centralized audit trail

### Week 2: Database Layer (9 hours)

**Priority**: HIGH — Enables efficient queries

- [ ] Design SQLite schema
- [ ] Implement sync_akr_db.sh
- [ ] Implement query_akr.sh
- [ ] Implement detect_akr_conflicts.sh
- [ ] Integrate with commit_knowledge.sh
- [ ] Test performance and accuracy
- [ ] **Deliverable**: Fast queries on AKR

### Week 3: Source Change Detection (6 hours)

**Priority**: MEDIUM — Handles real-world code changes

- [ ] Implement track_source_hashes.sh
- [ ] Implement detect_source_changes.sh
- [ ] Create staleness.yaml config
- [ ] Create akr-refresh-on-source-change hook
- [ ] Integrate with Planner Hat
- [ ] Test change detection
- [ ] **Deliverable**: Automatic staleness marking

### Week 4: Staleness Management (5 hours)

**Priority**: MEDIUM — Maintains knowledge quality

- [ ] Implement detect_staleness.sh
- [ ] Implement generate_staleness_report.sh
- [ ] Update AKR document format
- [ ] Create akr-auto-refresh-stale hook
- [ ] Integrate with Planner Hat
- [ ] Test staleness detection and refresh
- [ ] **Deliverable**: Automatic knowledge refresh

### Week 5: Integration & Testing (3 hours)

**Priority**: HIGH — Ensure all pieces work together

- [ ] Full integration testing
- [ ] Performance testing (1000+ artifacts)
- [ ] Concurrent agent testing
- [ ] Documentation updates
- [ ] Team training
- [ ] **Deliverable**: Production-ready framework

**Total effort**: 27 hours  
**Timeline**: 5 weeks (part-time) or 1 week (full-time)

---

## Success Criteria

### Audit Logging ✅

- [ ] Every agent action logged with timestamp
- [ ] Audit trail visible via view_audit.sh
- [ ] Can trace decision history for any artifact
- [ ] <5ms overhead per log entry
- [ ] Log rotation working (daily, 30-day retention)

### Database Layer ✅

- [ ] SQL queries on 1000+ artifacts in <100ms
- [ ] Can answer "what's high-risk?" questions
- [ ] Automatic conflict detection
- [ ] Database <100MB for 10,000 artifacts
- [ ] Markdown remains source of truth

### Source Change Detection ✅

- [ ] Source changes detected within 1 minute
- [ ] Stale knowledge automatically marked
- [ ] Affected artifacts re-analyzed on next task
- [ ] <50ms overhead per task start
- [ ] No false positives (whitespace changes ignored)

### Staleness Management ✅

- [ ] Stale knowledge automatically detected
- [ ] Refresh recommendations provided
- [ ] Refresh history tracked in audit log
- [ ] Knowledge quality improves over time
- [ ] Agents can see staleness status

---

## Configuration Changes Required

### New Environment Variables

```bash
# Audit logging
export GENERO_AKR_AUDIT_LOG="$BRODIR/etc/genero-akr/audit.log"
export GENERO_AKR_AUDIT_RETENTION_DAYS=30

# Database
export GENERO_AKR_DB_PATH="$BRODIR/etc/genero-akr/akr.db"
export GENERO_AKR_DB_SYNC_INTERVAL=5

# Source tracking
export GENERO_AKR_SOURCE_HASHES="$BRODIR/etc/genero-akr/metadata/source_hashes.json"

# Staleness
export GENERO_AKR_STALENESS_CONFIG="$BRODIR/etc/genero-akr/config/staleness.yaml"
export GENERO_AKR_AUTO_REFRESH=true
```

### New Scripts to Create

```
~/.kiro/scripts/
├── audit_log.sh                    (append audit entries) ← PRIORITY 1
├── view_audit.sh                   (query audit log)
├── sync_akr_db.sh                  (rebuild database)
├── query_akr.sh                    (SQL query interface)
├── detect_akr_conflicts.sh         (find conflicts)
├── track_source_hashes.sh          (compute hashes)
├── detect_source_changes.sh        (identify changes)
├── detect_staleness.sh             (check age)
└── generate_staleness_report.sh    (report status)
```

### Updated Steering Files

```
.kiro/steering/
├── genero-context-workflow.md      (add audit logging, change detection, staleness checks)
├── genero-context-operations.md    (add database troubleshooting)
└── genero-akr-workflow.md          (add staleness management)
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Audit log grows too large | Daily rotation, 30-day retention |
| Database sync fails | Markdown is source of truth, rebuild from scratch |
| Concurrent writes conflict | File locking in all scripts |
| Staleness thresholds wrong | Make configurable, tune based on feedback |
| Performance degradation | Monitor query times, optimize SQL |
| Agents ignore stale warnings | Make refresh automatic, not optional |

---

## Next Steps

### Immediate (This Week)

1. **Implement audit_log.sh** (1 hour)
   - Core logging functionality
   - File locking for concurrent writes
   - Automatic timestamp and rotation

2. **Implement view_audit.sh** (1 hour)
   - Query interface
   - Filtering and formatting

3. **Integrate with workflow** (1 hour)
   - Add audit_log.sh calls at each gate
   - Document what to log

4. **Test** (1 hour)
   - Concurrent writes
   - Log rotation
   - Query filtering

### This Month

5. **Implement database layer** (9 hours)
   - SQLite schema
   - sync_akr_db.sh
   - query_akr.sh
   - Integration testing

6. **Implement change detection** (6 hours)
   - Source hash tracking
   - Change detection
   - Staleness marking

7. **Implement staleness management** (5 hours)
   - Staleness detection
   - Auto-refresh
   - Reporting

### Integration & Rollout

8. **Full integration testing** (3 hours)
9. **Documentation and training** (2 hours)
10. **Rollout to team** (1 hour)

---

## Questions for Team

1. **Audit retention**: Keep 30 days of audit logs? Or longer?
2. **Staleness thresholds**: Are 30 days for functions, 60 for modules, 90 for issues reasonable?
3. **Auto-refresh**: Should stale knowledge be automatically refreshed, or just flagged?
4. **Database**: SQLite or PostgreSQL? (SQLite recommended for simplicity)
5. **Rollout**: Implement all at once or phase by phase?

---

## Conclusion

The framework is 60% complete with solid foundations in place. Three critical gaps have been identified and designed. Implementation is straightforward (27 hours total) and provides immediate value:

- **Audit logging** → Accountability and compliance
- **Database storage** → Fast queries and analytics
- **Change detection** → Automatic staleness marking
- **Staleness management** → Automatic knowledge refresh

Recommend starting with audit logging (highest priority, unblocks other work) and proceeding with database layer in parallel.

