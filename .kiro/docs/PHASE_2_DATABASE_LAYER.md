# Phase 2: Database Layer Implementation

**Status**: 📋 Ready for implementation  
**Effort**: 9 hours  
**Priority**: HIGH

---

## Overview

Add SQLite database layer to enable fast queries on the AKR while keeping markdown as source of truth.

**Benefits**:
- Fast queries (<100ms on 1000+ artifacts)
- Analytics ("what's high-risk?")
- Automatic conflict detection
- Version history and data validation
- Scalability to 10,000+ artifacts

---

## Implementation Tasks

### Task 1: Design SQLite Schema (1 hour)

**Deliverable**: SQL schema file

**What to create**:
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

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 2 section) for detailed schema design

---

### Task 2: Implement sync_akr_db.sh (2 hours)

**Deliverable**: `.kiro/scripts/sync_akr_db.sh`

**What it does**:
1. Parse each markdown file in AKR
2. Extract metadata (name, type, status, timestamps)
3. Extract metrics (complexity, LOC, etc.)
4. Extract findings and issues
5. Insert/update database
6. Validate schema compliance
7. Log sync results

**Usage**:
```bash
bash ~/.kiro/scripts/sync_akr_db.sh
```

**Integration**: Call automatically after every `commit_knowledge.sh`

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 2 section) for detailed implementation

---

### Task 3: Implement query_akr.sh (2 hours)

**Deliverable**: `.kiro/scripts/query_akr.sh`

**What it does**:
- SQL query interface to AKR database
- Support filtering, sorting, grouping
- Output formats: JSON, text, CSV

**Supported queries**:
```bash
# Find high-complexity functions
bash query_akr.sh --type function --filter "complexity > 10"

# Find recently modified artifacts
bash query_akr.sh --type function --filter "updated_after = 7d"

# Find all issues affecting a function
bash query_akr.sh --type issue --filter "artifact_name = process_order"

# Get statistics
bash query_akr.sh --stats --group-by type

# Find conflicts
bash query_akr.sh --conflicts --since 1h
```

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 2 section) for detailed implementation

---

### Task 4: Implement detect_akr_conflicts.sh (1 hour)

**Deliverable**: `.kiro/scripts/detect_akr_conflicts.sh`

**What it does**:
- Find artifacts modified by multiple agents in same time window
- Alert on potential conflicts
- Suggest merge strategy

**Usage**:
```bash
bash ~/.kiro/scripts/detect_akr_conflicts.sh --since 1h
```

**Reference**: See `FRAMEWORK_IMPROVEMENTS.md` (Phase 2 section) for detailed implementation

---

### Task 5: Integration (1 hour)

**What to do**:
1. Update `commit_knowledge.sh` to call `sync_akr_db.sh` after commit
2. Update workflow rules to document new queries
3. Add database troubleshooting to operations guide

**Files to update**:
- `.kiro/scripts/commit_knowledge.sh`
- `.kiro/steering/genero-context-workflow.md`
- `.kiro/steering/genero-context-operations.md`

---

### Task 6: Testing (2 hours)

**What to test**:
- [ ] Schema validation
- [ ] Sync accuracy (markdown → database)
- [ ] Query performance (<100ms for 1000+ artifacts)
- [ ] Concurrent access
- [ ] Conflict detection
- [ ] Output formatting

**Test cases**:
1. Create 100 artifacts, verify sync
2. Query for high-complexity functions
3. Query for recently modified artifacts
4. Simulate concurrent modifications
5. Verify conflict detection

---

## Success Criteria

- ✅ SQLite database created and populated
- ✅ Sync script working correctly
- ✅ Query script supporting all required queries
- ✅ Conflict detection working
- ✅ Query performance <100ms for 1000+ artifacts
- ✅ Database <100MB for 10,000 artifacts
- ✅ All tests passing

---

## New Capabilities

After Phase 2, agents will be able to:

```bash
# Find all high-complexity functions
bash query_akr.sh --type function --filter "complexity > 10"

# Find all functions modified in last 7 days
bash query_akr.sh --type function --filter "updated_after = 7d"

# Find all issues affecting a specific function
bash query_akr.sh --type issue --filter "artifact_name = process_order"

# Get statistics by type
bash query_akr.sh --stats --group-by type

# Find conflicts (multiple agents modified same artifact)
bash query_akr.sh --conflicts --since 1h
```

---

## How to Pick This Up

1. **Read the design**: `FRAMEWORK_IMPROVEMENTS.md` (Phase 2 section)
2. **Review the schema**: See Task 1 above
3. **Start with Task 1**: Design SQLite schema (1 hour)
4. **Then Task 2**: Implement sync_akr_db.sh (2 hours)
5. **Then Task 3**: Implement query_akr.sh (2 hours)
6. **Then Task 4**: Implement detect_akr_conflicts.sh (1 hour)
7. **Then Task 5**: Integration (1 hour)
8. **Then Task 6**: Testing (2 hours)

---

## Related Documentation

- `FRAMEWORK_IMPROVEMENTS.md` — Detailed analysis and design
- `IMPLEMENTATION_STATUS.md` — Current status and roadmap
- `.kiro/steering/genero-context-workflow.md` — Workflow rules
- `.kiro/steering/genero-context-operations.md` — Error handling

---

## Questions?

See `.kiro/docs/IMPLEMENTATION_STATUS.md` for overview and next steps.

