# Framework Improvements: Analysis & Solutions

**Date**: 2026-04-01  
**Status**: Comprehensive analysis with implementation roadmap

---

## Executive Summary

Four critical gaps identified in the Genero Context Framework:

1. **Audit Logging Gap** — Interactions not being logged per agent session
2. **Knowledge Storage Gap** — Markdown-only repository lacks query efficiency and metadata
3. **Dynamic Codebase Gap** — No mechanism to detect stale knowledge or refresh outdated findings
4. **Knowledge Staleness Gap** — No automated detection of when knowledge needs re-analysis

This document provides analysis, benefits/tradeoffs, and implementation roadmap for each.

---

## Issue 1: Audit Logging Gap

### Current State

**Problem**: Framework specifies audit logging in Rule 4 (genero-context-workflow.md) but:
- No centralized audit log file is created or maintained
- Agents are told to log but have no designated location
- No mechanism to append logs across multiple agent sessions
- No audit trail visible to humans or subsequent agents
- Logs are lost when agent session ends

**Impact**:
- No accountability for agent actions
- No way to trace decision history
- Subsequent agents can't see what previous agents did
- Compliance/audit requirements not met
- Debugging issues requires re-running analysis

### Solution: Centralized Audit Log System

**Implementation**:

1. **Create audit.log file** (persistent, append-only)
   ```
   Location: $BRODIR/etc/genero-akr/audit.log
   Format: JSON Lines (one JSON object per line)
   Permissions: 644 (readable by all agents, writable by all)
   Rotation: Daily, keep 30 days
   ```

2. **Audit Log Entry Format**
   ```json
   {
     "timestamp": "2026-03-31T10:00:00Z",
     "agent_id": "agent-1",
     "session_id": "sess-abc123",
     "phase": "INCEPTION",
     "hat": "PLANNER",
     "action": "AKR_RETRIEVE",
     "artifact_type": "function",
     "artifact_name": "process_order",
     "result": "FOUND",
     "details": {
       "complexity": 8,
       "dependents": 12,
       "status": "active"
     },
     "duration_ms": 145,
     "error": null
   }
   ```

3. **Audit Log Script** (new: `audit_log.sh`)
   ```bash
   #!/bin/bash
   # Usage: bash audit_log.sh --action ACTION --phase PHASE --hat HAT \
   #          --artifact-type TYPE --artifact-name NAME --result RESULT \
   #          [--details JSON] [--error ERROR_MSG]
   
   # Appends JSON entry to audit.log with automatic timestamp
   # Handles concurrent writes with file locking
   # Rotates log daily
   ```

4. **Integration Points** (where agents call audit_log.sh)
   ```
   INCEPTION Phase:
   - AKR retrieve → audit_log.sh --action AKR_RETRIEVE
   - AKR search → audit_log.sh --action AKR_SEARCH
   - genero-tools query → audit_log.sh --action GENERO_QUERY
   - Plan presented → audit_log.sh --action PLAN_PRESENTED
   - Human approval → audit_log.sh --action HUMAN_APPROVAL
   
   CONSTRUCTION Phase:
   - Implementation start → audit_log.sh --action IMPL_START
   - Implementation end → audit_log.sh --action IMPL_END
   - Work presented → audit_log.sh --action WORK_PRESENTED
   - Human review → audit_log.sh --action HUMAN_REVIEW
   
   OPERATION Phase:
   - Validation start → audit_log.sh --action VALIDATION_START
   - AKR commit → audit_log.sh --action AKR_COMMIT
   - Task complete → audit_log.sh --action TASK_COMPLETE
   ```

5. **Audit Log Viewer** (new: `view_audit.sh`)
   ```bash
   # Usage: bash view_audit.sh [--agent AGENT_ID] [--session SESSION_ID] \
   #          [--action ACTION] [--since HOURS] [--format json|text]
   
   # Queries audit.log with filtering
   # Outputs human-readable or JSON format
   # Shows decision trail for any artifact
   ```

### Benefits

✅ **Accountability** — Every agent action is timestamped and logged  
✅ **Traceability** — Humans can see decision history for any artifact  
✅ **Debugging** — Issues can be traced to specific agent actions  
✅ **Compliance** — Audit trail meets regulatory requirements  
✅ **Learning** — Subsequent agents can see what previous agents did  
✅ **Performance** — Can identify slow queries or repeated failures  

### Tradeoffs

⚠️ **Storage** — Audit log grows ~1MB per 1000 agent interactions (manageable with rotation)  
⚠️ **Overhead** — Each action adds ~5-10ms for logging (negligible)  
⚠️ **Complexity** — New script to maintain, but simple append-only design  

### Implementation Effort

- **audit_log.sh** — 50 lines (append with locking, rotation)
- **view_audit.sh** — 80 lines (query and filter)
- **Integration** — Update workflow rules to call audit_log.sh at each gate
- **Testing** — Verify concurrent writes, rotation, filtering
- **Estimated time** — 2-3 hours

---

## Issue 2: Knowledge Storage Gap

### Current State

**Problem**: AKR uses markdown files only:
- No structured query capability (must grep/search manually)
- No metadata indexing (can't find "all functions with complexity > 10")
- No version history (can't see how knowledge evolved)
- No change tracking (can't see what changed between commits)
- No conflict detection (multiple agents writing same artifact)
- Slow searches (grep across 1000+ files)
- No data validation (malformed documents not caught)

**Impact**:
- Agents spend time searching instead of analyzing
- Can't answer questions like "which functions are high-risk?"
- No way to track knowledge quality over time
- Conflicts between agents go undetected
- Scalability issues as AKR grows

### Solution: Hybrid Storage (Markdown + SQLite Database)

**Architecture**:

```
AKR Storage Layer
├── Markdown Files (primary source of truth)
│   ├── functions/process_order.md
│   ├── modules/payment.md
│   └── issues/tool_gap_account_schema.md
│
└── SQLite Database (queryable index)
    ├── artifacts table (name, type, path, status, updated_at)
    ├── metrics table (artifact_id, complexity, loc, dependents)
    ├── findings table (artifact_id, finding_text, priority)
    ├── issues table (artifact_id, issue_type, severity)
    └── audit_trail table (artifact_id, action, agent_id, timestamp)
```

**Benefits of Hybrid Approach**:
- Markdown remains human-readable and version-controllable
- Database enables fast queries and analytics
- Database is rebuilt from markdown (no sync issues)
- Markdown is source of truth; database is cache

**New Queries Enabled**:

```bash
# Find all high-complexity functions
bash query_akr.sh --type function --filter "complexity > 10"

# Find all functions with unresolved types
bash query_akr.sh --type function --filter "has_unresolved_types = true"

# Find all functions modified in last 7 days
bash query_akr.sh --type function --filter "updated_after = 7d"

# Find all issues affecting a specific function
bash query_akr.sh --type issue --filter "artifact_name = process_order"

# Get statistics by type
bash query_akr.sh --stats --group-by type

# Find conflicts (multiple agents modified same artifact)
bash query_akr.sh --conflicts --since 1h
```

**Implementation**:

1. **Create AKR database schema** (SQLite)
   ```sql
   CREATE TABLE artifacts (
     id INTEGER PRIMARY KEY,
     name TEXT NOT NULL,
     type TEXT NOT NULL,  -- function|module|file|pattern|issue
     path TEXT,
     status TEXT,  -- active|deprecated|archived
     created_at TIMESTAMP,
     updated_at TIMESTAMP,
     updated_by TEXT,
     UNIQUE(name, type)
   );
   
   CREATE TABLE metrics (
     artifact_id INTEGER PRIMARY KEY,
     complexity INTEGER,
     lines_of_code INTEGER,
     parameter_count INTEGER,
     dependent_count INTEGER,
     FOREIGN KEY(artifact_id) REFERENCES artifacts(id)
   );
   
   CREATE TABLE findings (
     id INTEGER PRIMARY KEY,
     artifact_id INTEGER,
     finding_text TEXT,
     priority TEXT,  -- HIGH|MEDIUM|LOW
     FOREIGN KEY(artifact_id) REFERENCES artifacts(id)
   );
   
   CREATE TABLE issues (
     id INTEGER PRIMARY KEY,
     artifact_id INTEGER,
     issue_type TEXT,  -- tool_gap|code_defect|performance|security
     severity TEXT,  -- CRITICAL|HIGH|MEDIUM|LOW
     FOREIGN KEY(artifact_id) REFERENCES artifacts(id)
   );
   
   CREATE TABLE audit_trail (
     id INTEGER PRIMARY KEY,
     artifact_id INTEGER,
     action TEXT,  -- create|append|update|deprecate
     agent_id TEXT,
     timestamp TIMESTAMP,
     FOREIGN KEY(artifact_id) REFERENCES artifacts(id)
   );
   ```

2. **Create sync script** (`sync_akr_db.sh`)
   ```bash
   # Rebuilds database from markdown files
   # Runs after every commit_knowledge.sh
   # Validates markdown format
   # Updates metrics and audit trail
   ```

3. **Create query script** (`query_akr.sh`)
   ```bash
   # SQL query interface to database
   # Supports filtering, sorting, grouping
   # Outputs JSON or text
   ```

4. **Create conflict detector** (`detect_akr_conflicts.sh`)
   ```bash
   # Finds artifacts modified by multiple agents in same time window
   # Alerts agents to potential conflicts
   # Suggests merge strategy
   ```

### Benefits

✅ **Fast queries** — SQL queries on 1000+ artifacts in <100ms  
✅ **Analytics** — Can answer "what's the risk profile of the codebase?"  
✅ **Conflict detection** — Automatic alerts when multiple agents modify same artifact  
✅ **Version history** — Can see how knowledge evolved  
✅ **Data validation** — Database schema enforces consistency  
✅ **Scalability** — Supports 10,000+ artifacts without performance degradation  
✅ **Markdown preserved** — Human-readable, version-controllable source  

### Tradeoffs

⚠️ **Complexity** — New database layer to maintain  
⚠️ **Sync overhead** — Database rebuild after each commit (~100ms)  
⚠️ **Storage** — SQLite database ~10% of markdown size (negligible)  
⚠️ **Learning curve** — Agents need to learn new query syntax  

### Implementation Effort

- **Database schema** — 100 lines SQL
- **sync_akr_db.sh** — 150 lines (parse markdown, validate, insert)
- **query_akr.sh** — 200 lines (SQL queries, output formatting)
- **detect_akr_conflicts.sh** — 100 lines (find concurrent modifications)
- **Integration** — Update commit_knowledge.sh to call sync_akr_db.sh
- **Testing** — Verify schema, sync accuracy, query performance
- **Estimated time** — 4-5 hours

---

## Issue 3: Dynamic Codebase Support

### Current State

**Problem**: Framework assumes static codebase:
- No mechanism to detect when source code changes
- No way to know if AKR knowledge is stale
- Agents don't re-analyze changed functions
- Metrics become outdated (complexity, LOC, dependents)
- Tool gaps may be resolved but knowledge not updated

**Impact**:
- Agents work with outdated information
- Decisions based on stale metrics
- Missed opportunities to update knowledge
- Risk of regression when code changes

### Solution: Change Detection & Knowledge Refresh

**Implementation**:

1. **Create source file hash tracking** (`track_source_hashes.sh`)
   ```bash
   # Stores SHA256 hash of each .4gl file
   # Location: $BRODIR/etc/genero-akr/metadata/source_hashes.json
   # Format:
   # {
   #   "src/orders.4gl": "abc123def456...",
   #   "src/customers.4gl": "xyz789uvw012..."
   # }
   
   # Runs at task start to detect changes
   # Compares current hashes with stored hashes
   # Identifies modified files
   ```

2. **Create change detector** (`detect_source_changes.sh`)
   ```bash
   # Usage: bash detect_source_changes.sh [--since HOURS]
   
   # Compares current source hashes with stored hashes
   # Returns list of changed files
   # For each changed file, identifies affected functions
   # Marks related AKR entries as "potentially_stale"
   ```

3. **Create knowledge refresh trigger** (new hook)
   ```
   Hook: akr-refresh-on-source-change
   Trigger: When source files change
   Action: Mark affected AKR entries as stale
   ```

4. **Update workflow rules** (genero-context-workflow.md)
   ```
   New step in Planner Hat (after AKR check):
   
   "Check for source changes"
   - Run detect_source_changes.sh
   - If changes detected:
     - Identify affected artifacts
     - Mark as "potentially_stale"
     - Re-query genero-tools for updated metrics
     - Update AKR with new findings
   ```

5. **Create staleness indicator** (in AKR documents)
   ```markdown
   # process_order
   
   **Type:** function
   **Path:** src/orders.4gl
   **Last Updated:** 2026-03-30T10:00:00Z
   **Source Last Modified:** 2026-03-31T14:22:00Z  ← NEW
   **Staleness Status:** POTENTIALLY_STALE  ← NEW
   **Updated By:** agent-1
   **Status:** active
   ```

### Benefits

✅ **Automatic detection** — Framework knows when knowledge is stale  
✅ **Proactive refresh** — Agents automatically re-analyze changed code  
✅ **Accurate metrics** — Complexity, LOC, dependents always current  
✅ **Risk awareness** — Agents know which knowledge is outdated  
✅ **Compliance** — Audit trail shows when knowledge was refreshed  

### Tradeoffs

⚠️ **Overhead** — Hash computation on every task start (~50ms for 1000 files)  
⚠️ **False positives** — Whitespace changes trigger refresh (mitigated by semantic hashing)  
⚠️ **Complexity** — New change detection logic  

### Implementation Effort

- **track_source_hashes.sh** — 60 lines (compute and store hashes)
- **detect_source_changes.sh** — 80 lines (compare hashes, identify affected artifacts)
- **Hook configuration** — 20 lines (new hook definition)
- **Workflow updates** — 30 lines (add change detection step)
- **Testing** — Verify hash accuracy, change detection, staleness marking
- **Estimated time** — 2-3 hours

---

## Issue 4: Knowledge Staleness & Refresh

### Current State

**Problem**: No mechanism to update outdated knowledge:
- AKR entries marked "deprecated" but never re-analyzed
- Agents don't know when to refresh knowledge
- No automated staleness detection
- No guidance on when knowledge is "old enough" to refresh
- Tool gaps may be resolved but knowledge not updated

**Impact**:
- Deprecated knowledge accumulates
- Agents work with outdated information
- Missed opportunities to improve knowledge quality
- No way to track knowledge lifecycle

### Solution: Automated Staleness Detection & Refresh

**Implementation**:

1. **Define staleness thresholds** (new config file)
   ```yaml
   # Location: $BRODIR/etc/genero-akr/config/staleness.yaml
   
   staleness_thresholds:
     function:
       age_days: 30  # Mark as stale if not updated in 30 days
       source_change: true  # Mark as stale if source file changed
       dependent_change: true  # Mark as stale if dependents changed
     
     module:
       age_days: 60
       source_change: true
     
     issue:
       age_days: 90  # Issues age slower
       source_change: false
   
   refresh_strategy:
     auto_refresh: true  # Automatically refresh stale knowledge
     refresh_on_task_start: true  # Refresh if artifact is touched
     refresh_threshold: 30  # Refresh if >30 days old
   ```

2. **Create staleness detector** (`detect_staleness.sh`)
   ```bash
   # Usage: bash detect_staleness.sh [--type function|module|issue]
   
   # Checks each AKR entry against staleness thresholds
   # Marks entries as:
   #   - FRESH (recently updated)
   #   - AGING (approaching staleness threshold)
   #   - STALE (exceeds threshold)
   #   - POTENTIALLY_STALE (source changed)
   
   # Output: JSON with staleness status for each artifact
   ```

3. **Create refresh trigger** (new hook)
   ```
   Hook: akr-auto-refresh-stale
   Trigger: When agent touches a stale artifact
   Action: Re-query genero-tools, update AKR with --action update
   ```

4. **Update AKR document format** (add staleness fields)
   ```markdown
   # process_order
   
   **Type:** function
   **Path:** src/orders.4gl
   **Last Updated:** 2026-03-30T10:00:00Z
   **Updated By:** agent-1
   **Status:** active
   **Staleness Status:** FRESH  ← NEW (FRESH|AGING|STALE|POTENTIALLY_STALE)
   **Days Since Update:** 1  ← NEW
   **Refresh Recommended:** false  ← NEW
   ```

5. **Create refresh workflow** (new step in Planner Hat)
   ```
   New step: "Check knowledge staleness"
   
   For each artifact you'll touch:
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

6. **Create refresh report** (`generate_staleness_report.sh`)
   ```bash
   # Usage: bash generate_staleness_report.sh [--format json|text]
   
   # Shows:
   # - Total artifacts by staleness status
   # - Artifacts needing refresh
   # - Refresh recommendations
   # - Refresh history (when last refreshed)
   ```

### Benefits

✅ **Automatic detection** — Framework knows which knowledge is stale  
✅ **Proactive refresh** — Agents automatically refresh when needed  
✅ **Quality tracking** — Can see knowledge quality over time  
✅ **Compliance** — Audit trail shows refresh history  
✅ **Scalability** — Handles 10,000+ artifacts with automatic cleanup  
✅ **Learning** — Agents know which knowledge is reliable  

### Tradeoffs

⚠️ **Overhead** — Staleness checks add ~50ms per task  
⚠️ **Refresh cost** — Re-querying genero-tools for stale artifacts (~100ms each)  
⚠️ **Configuration** — Staleness thresholds need tuning per team  

### Implementation Effort

- **staleness.yaml config** — 30 lines
- **detect_staleness.sh** — 100 lines (check age, source changes, dependents)
- **generate_staleness_report.sh** — 80 lines (aggregate and report)
- **Hook configuration** — 20 lines (auto-refresh trigger)
- **Workflow updates** — 40 lines (add staleness check step)
- **Testing** — Verify threshold logic, refresh accuracy, reporting
- **Estimated time** — 3-4 hours

---

## Implementation Roadmap

### Phase 1: Audit Logging (Week 1)
**Priority**: HIGH — Foundation for all other improvements

1. Create audit_log.sh (append-only logging)
2. Create view_audit.sh (query and filter)
3. Update workflow rules to call audit_log.sh at each gate
4. Test concurrent writes and log rotation
5. **Deliverable**: Centralized audit trail visible to all agents

### Phase 2: Knowledge Storage (Week 2)
**Priority**: HIGH — Enables efficient queries and analytics

1. Design SQLite schema
2. Create sync_akr_db.sh (rebuild from markdown)
3. Create query_akr.sh (SQL query interface)
4. Create detect_akr_conflicts.sh (conflict detection)
5. Integrate with commit_knowledge.sh
6. **Deliverable**: Fast queries on AKR, conflict detection

### Phase 3: Dynamic Codebase Support (Week 3)
**Priority**: MEDIUM — Handles real-world code changes

1. Create track_source_hashes.sh
2. Create detect_source_changes.sh
3. Create akr-refresh-on-source-change hook
4. Update Planner Hat workflow
5. Test with real code changes
6. **Deliverable**: Automatic detection of stale knowledge

### Phase 4: Staleness Management (Week 4)
**Priority**: MEDIUM — Maintains knowledge quality

1. Create staleness.yaml config
2. Create detect_staleness.sh
3. Create generate_staleness_report.sh
4. Create akr-auto-refresh-stale hook
5. Update AKR document format
6. Test staleness detection and refresh
7. **Deliverable**: Automatic knowledge refresh, staleness reporting

### Phase 5: Integration & Testing (Week 5)
**Priority**: HIGH — Ensure all pieces work together

1. Integration testing across all phases
2. Performance testing (1000+ artifacts)
3. Concurrent agent testing
4. Documentation updates
5. Team training
6. **Deliverable**: Production-ready framework

---

## Configuration Changes Required

### New Environment Variables

```bash
# Audit logging
export GENERO_AKR_AUDIT_LOG="$BRODIR/etc/genero-akr/audit.log"
export GENERO_AKR_AUDIT_RETENTION_DAYS=30

# Database
export GENERO_AKR_DB_PATH="$BRODIR/etc/genero-akr/akr.db"
export GENERO_AKR_DB_SYNC_INTERVAL=5  # seconds

# Source tracking
export GENERO_AKR_SOURCE_HASHES="$BRODIR/etc/genero-akr/metadata/source_hashes.json"

# Staleness
export GENERO_AKR_STALENESS_CONFIG="$BRODIR/etc/genero-akr/config/staleness.yaml"
export GENERO_AKR_AUTO_REFRESH=true
```

### New Scripts

```
~/.kiro/scripts/
├── audit_log.sh                    (append audit entries)
├── view_audit.sh                   (query audit log)
├── sync_akr_db.sh                  (rebuild database from markdown)
├── query_akr.sh                    (SQL query interface)
├── detect_akr_conflicts.sh         (find concurrent modifications)
├── track_source_hashes.sh          (compute and store file hashes)
├── detect_source_changes.sh        (identify changed files)
├── detect_staleness.sh             (check knowledge age)
└── generate_staleness_report.sh    (report staleness status)
```

### Updated Steering Files

```
.kiro/steering/
├── genero-context-workflow.md      (add change detection, staleness checks)
├── genero-context-operations.md    (add database troubleshooting)
└── genero-akr-workflow.md          (add staleness management)
```

---

## Success Metrics

### Audit Logging
- ✅ Every agent action logged with timestamp
- ✅ Audit trail visible to humans and agents
- ✅ Can trace decision history for any artifact
- ✅ <5ms overhead per log entry

### Knowledge Storage
- ✅ SQL queries on 1000+ artifacts in <100ms
- ✅ Can answer "what's high-risk?" questions
- ✅ Automatic conflict detection
- ✅ Database stays <100MB for 10,000 artifacts

### Dynamic Codebase
- ✅ Source changes detected within 1 minute
- ✅ Stale knowledge automatically marked
- ✅ Affected artifacts re-analyzed on next task
- ✅ <50ms overhead per task start

### Staleness Management
- ✅ Stale knowledge automatically detected
- ✅ Refresh recommendations provided
- ✅ Refresh history tracked in audit log
- ✅ Knowledge quality improves over time

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Audit log grows too large | Implement daily rotation, keep 30 days |
| Database sync fails | Markdown is source of truth, rebuild from scratch |
| Concurrent writes conflict | Use file locking in all scripts |
| Staleness thresholds wrong | Make configurable, tune based on team feedback |
| Performance degradation | Monitor query times, optimize SQL as needed |
| Agents ignore stale warnings | Make refresh automatic, not optional |

---

## Conclusion

These four improvements transform the framework from a static knowledge repository into a dynamic, auditable, queryable system that adapts to real-world code changes. Implementation is straightforward (9-12 hours total) and provides immediate value:

- **Audit logging** → Accountability and traceability
- **Database storage** → Fast queries and analytics
- **Change detection** → Automatic staleness marking
- **Staleness management** → Automatic knowledge refresh

Recommend implementing in phases, starting with audit logging (foundation) and database storage (high-value queries).

