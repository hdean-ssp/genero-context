# Framework Improvements: Implementation Guide

**Date**: 2026-04-01  
**Status**: Ready for execution  
**Estimated effort**: 9-12 hours across 5 phases

## Quick Reference: What Gets Built

| Component | Purpose | Effort | Priority |
|-----------|---------|--------|----------|
| Audit logging system | Centralized action log | 2-3h | HIGH |
| SQLite database layer | Fast queries on AKR | 4-5h | HIGH |
| Source change detection | Automatic staleness marking | 2-3h | MEDIUM |
| Staleness management | Auto-refresh old knowledge | 3-4h | MEDIUM |
| Integration & testing | Ensure all pieces work | 2-3h | HIGH |

## Phase 1: Audit Logging (2-3 hours)

### 1.1 Create audit_log.sh

Location: `~/.kiro/scripts/audit_log.sh`

Purpose: Append JSON entries to centralized audit log with file locking

Features:
- Append-only (never overwrites)
- Concurrent write safety (file locking)
- Daily rotation (keep 30 days)
- Automatic timestamp
- JSON format for parsing

### 1.2 Create view_audit.sh

Location: `~/.kiro/scripts/view_audit.sh`

Purpose: Query and filter audit log

Features:
- Filter by agent, session, action, artifact
- Time range filtering (--since HOURS)
- Output formats: JSON, text, CSV
- Show decision trail for any artifact

### 1.3 Update Workflow Rules

File: `.kiro/steering/genero-context-workflow.md`

Add audit_log.sh calls at these points:
- AKR retrieve (Planner Hat)
- genero-tools query (Planner Hat)
- Plan presented (Planner Hat)
- Human approval (Planner Hat)
- Implementation start (Builder Hat)
- Implementation end (Builder Hat)
- Work presented (Builder Hat)
- Human review (Builder Hat)
- Validation start (Reviewer Hat)
- AKR commit (Reviewer Hat)
- Task complete (Reviewer Hat)

## Phase 2: SQLite Database Layer (4-5 hours)

### 2.1 Create Database Schema

Location: `~/.kiro/scripts/init_akr_db.sh`

Creates SQLite database with tables:
- artifacts (name, type, path, status, timestamps)
- metrics (complexity, LOC, parameters, dependents)
- findings (finding text, priority)
- issues (issue type, severity)
- audit_trail (action, agent, timestamp)

### 2.2 Create sync_akr_db.sh

Location: `~/.kiro/scripts/sync_akr_db.sh`

Purpose: Rebuild database from markdown files

Process:
1. Parse each markdown file in AKR
2. Extract metadata (name, type, status, timestamps)
3. Extract metrics (complexity, LOC, etc.)
4. Extract findings and issues
5. Insert/update database
6. Validate schema compliance
7. Log sync results

Runs automatically after every commit_knowledge.sh

### 2.3 Create query_akr.sh

Location: `~/.kiro/scripts/query_akr.sh`

Purpose: SQL query interface to AKR database

Supported queries:
- Find high-complexity functions
- Find functions with unresolved types
- Find recently modified artifacts
- Find all issues affecting a function
- Get statistics
- Find conflicts

## Phase 3: Source Change Detection (2-3 hours)

### 3.1 Create track_source_hashes.sh

Location: `~/.kiro/scripts/track_source_hashes.sh`

Purpose: Compute and store SHA256 hashes of all .4gl files

Storage: `$BRODIR/etc/genero-akr/metadata/source_hashes.json`

### 3.2 Create detect_source_changes.sh

Location: `~/.kiro/scripts/detect_source_changes.sh`

Purpose: Compare current hashes with stored hashes

Output:
- List of changed files
- For each changed file, affected functions
- Recommendation to refresh AKR

### 3.3 Create akr-refresh-on-source-change Hook

Location: `.kiro/hooks/akr-refresh-on-source-change.kiro.hook`

Trigger: When source files change  
Action: Mark affected AKR entries as "potentially_stale"

## Phase 4: Staleness Management (3-4 hours)

### 4.1 Create staleness.yaml Config

Location: `$BRODIR/etc/genero-akr/config/staleness.yaml`

Defines staleness thresholds by artifact type

### 4.2 Create detect_staleness.sh

Location: `~/.kiro/scripts/detect_staleness.sh`

Purpose: Check each AKR entry against staleness thresholds

Output: JSON with staleness status for each artifact
- FRESH (recently updated)
- AGING (approaching threshold)
- STALE (exceeds threshold)
- POTENTIALLY_STALE (source changed)

### 4.3 Create generate_staleness_report.sh

Location: `~/.kiro/scripts/generate_staleness_report.sh`

Purpose: Report staleness status across AKR

## Phase 5: Integration & Testing (2-3 hours)

### 5.1 Integration Testing

- Full workflow with audit logging
- Database sync after commit
- Source change detection + staleness
- Concurrent agents
- Query performance

## Environment Variables to Add

```bash
export GENERO_AKR_AUDIT_LOG="$BRODIR/etc/genero-akr/audit.log"
export GENERO_AKR_AUDIT_RETENTION_DAYS=30
export GENERO_AKR_DB_PATH="$BRODIR/etc/genero-akr/akr.db"
export GENERO_AKR_DB_SYNC_INTERVAL=5
export GENERO_AKR_SOURCE_HASHES="$BRODIR/etc/genero-akr/metadata/source_hashes.json"
export GENERO_AKR_STALENESS_CONFIG="$BRODIR/etc/genero-akr/config/staleness.yaml"
export GENERO_AKR_AUTO_REFRESH=true
```

## Success Criteria

### Phase 1: Audit Logging
- ✅ Every agent action logged with timestamp
- ✅ Audit trail visible via view_audit.sh
- ✅ Can trace decision history for any artifact
- ✅ <5ms overhead per log entry

### Phase 2: Database Layer
- ✅ SQL queries on 1000+ artifacts in <100ms
- ✅ Can answer "what's high-risk?" questions
- ✅ Automatic conflict detection
- ✅ Database <100MB for 10,000 artifacts

### Phase 3: Source Change Detection
- ✅ Source changes detected within 1 minute
- ✅ Stale knowledge automatically marked
- ✅ Affected artifacts re-analyzed on next task
- ✅ <50ms overhead per task start

### Phase 4: Staleness Management
- ✅ Stale knowledge automatically detected
- ✅ Refresh recommendations provided
- ✅ Refresh history tracked in audit log
- ✅ Knowledge quality improves over time

## Rollout Strategy

### Week 1: Audit Logging
- Deploy audit_log.sh and view_audit.sh
- Update workflow rules
- Verify all agents logging actions

### Week 2: Database Layer
- Deploy database schema and sync script
- Deploy query_akr.sh
- Rebuild database from existing markdown

### Week 3: Source Change Detection
- Deploy source hash tracking
- Deploy change detection
- Create hook for auto-staleness marking

### Week 4: Staleness Management
- Deploy staleness detection
- Deploy auto-refresh hook
- Update AKR document format

### Week 5: Integration & Optimization
- Full integration testing
- Performance tuning
- Documentation finalization
- Team training

