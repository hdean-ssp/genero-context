# Phase 2 Implementation Guide: Database Layer

**Date**: 2026-04-01  
**Status**: Scripts created, ready for testing and integration  
**Effort**: 9 hours (4 hours scripts created, 5 hours remaining for testing and integration)

---

## What's Been Created

### 1. init_akr_db.sh
**Purpose**: Initialize SQLite database with schema

**Features**:
- Creates SQLite database with 8 tables
- Defines indexes for common queries
- Creates 4 views for frequent queries
- Supports --force flag to recreate database

**Tables**:
- `artifacts` — Metadata about each artifact
- `metrics` — Code quality metrics
- `findings` — Individual findings
- `issues` — Known issues and tool gaps
- `recommendations` — Actionable recommendations
- `dependencies` — Function call relationships
- `audit_trail` — Action history
- `staleness` — Knowledge age tracking

**Views**:
- `high_complexity_functions` — Functions with complexity > 10
- `high_risk_functions` — Functions with complexity > 10 OR dependents > 15
- `stale_knowledge` — Knowledge marked as stale
- `recent_changes` — Recently modified artifacts

**Usage**:
```bash
bash init_akr_db.sh                # Create database
bash init_akr_db.sh --force        # Recreate database
```

---

### 2. sync_akr_db.sh
**Purpose**: Sync markdown files to SQLite database

**Features**:
- Parses markdown files from AKR
- Extracts metadata and metrics
- Inserts/updates database
- Supports partial sync (by type or artifact)
- Generates sync statistics

**Supported Types**:
- function
- module
- file
- pattern
- issue

**Usage**:
```bash
bash sync_akr_db.sh                    # Full sync
bash sync_akr_db.sh --full            # Full sync (rebuild)
bash sync_akr_db.sh --type function    # Sync only functions
bash sync_akr_db.sh --artifact name    # Sync specific artifact
```

---

### 3. query_akr.sh
**Purpose**: Query AKR database with SQL interface

**Features**:
- Pre-built queries for common use cases
- Custom SQL query support
- Multiple output formats (json, text, csv)
- Filtering and limiting

**Pre-built Queries**:
- `--high-complexity` — Find high-complexity functions
- `--high-risk` — Find high-risk functions
- `--stale` — Find stale knowledge
- `--recent` — Find recently modified artifacts
- `--conflicts` — Find concurrent modifications

**Usage**:
```bash
# Find high-complexity functions
bash query_akr.sh --high-complexity --limit 10

# Find high-risk functions
bash query_akr.sh --high-risk

# Find stale knowledge
bash query_akr.sh --stale

# Query by type with filter
bash query_akr.sh --type function --filter "complexity > 10" --format json

# Custom SQL query
bash query_akr.sh --sql "SELECT name, complexity FROM high_complexity_functions"
```

---

### 4. detect_akr_conflicts.sh
**Purpose**: Detect concurrent write conflicts

**Features**:
- Finds artifacts modified by multiple agents
- Shows agent count and modification count
- Configurable time window
- Multiple output formats

**Usage**:
```bash
# Find conflicts in last hour
bash detect_akr_conflicts.sh

# Find conflicts in last 24 hours
bash detect_akr_conflicts.sh --since 24

# Output as JSON
bash detect_akr_conflicts.sh --format json
```

---

## What's Remaining (5 hours)

### 1. Testing (2 hours)

**Unit Tests**:
- [ ] Test database initialization
- [ ] Test metadata extraction
- [ ] Test sync accuracy
- [ ] Test query performance
- [ ] Test conflict detection

**Integration Tests**:
- [ ] Test with real AKR data
- [ ] Test concurrent access
- [ ] Test query performance on 1000+ artifacts
- [ ] Test database size limits

**Performance Tests**:
- [ ] Query <100ms on 1000+ artifacts
- [ ] Sync <1s for 100 artifacts
- [ ] Database <100MB for 10,000 artifacts

### 2. Integration with Workflow (2 hours)

**Update commit_knowledge.sh**:
- [ ] Call sync_akr_db.sh after commit
- [ ] Handle sync errors gracefully
- [ ] Log sync results

**Update workflow rules**:
- [ ] Add database query examples
- [ ] Document query capabilities
- [ ] Add troubleshooting guide

**Create database troubleshooting guide**:
- [ ] Common errors and solutions
- [ ] Performance tuning
- [ ] Database maintenance

### 3. Documentation (1 hour)

**Create database reference**:
- [ ] Schema documentation
- [ ] Query examples
- [ ] Performance tips
- [ ] Troubleshooting guide

**Update steering files**:
- [ ] Add database queries to workflow
- [ ] Add database troubleshooting to operations

---

## Implementation Checklist

### Phase 2a: Database Schema ✅
- [x] Design SQLite schema
- [x] Create init_akr_db.sh
- [x] Define tables and indexes
- [x] Create views for common queries

### Phase 2b: Sync Script ✅
- [x] Create sync_akr_db.sh
- [x] Implement metadata extraction
- [x] Implement metrics extraction
- [x] Support partial sync

### Phase 2c: Query Interface ✅
- [x] Create query_akr.sh
- [x] Implement pre-built queries
- [x] Support custom SQL
- [x] Support multiple output formats

### Phase 2d: Conflict Detection ✅
- [x] Create detect_akr_conflicts.sh
- [x] Find concurrent modifications
- [x] Show agent count and details

### Phase 2e: Testing 📋
- [ ] Unit tests for each script
- [ ] Integration tests with real data
- [ ] Performance tests
- [ ] Concurrent access tests

### Phase 2f: Integration 📋
- [ ] Update commit_knowledge.sh
- [ ] Update workflow rules
- [ ] Create troubleshooting guide

### Phase 2g: Documentation 📋
- [ ] Create database reference
- [ ] Update steering files
- [ ] Create performance tuning guide

---

## Quick Start

### 1. Initialize Database
```bash
bash .kiro/scripts/init_akr_db.sh
```

### 2. Sync Existing AKR Data
```bash
bash .kiro/scripts/sync_akr_db.sh
```

### 3. Query Database
```bash
# Find high-complexity functions
bash .kiro/scripts/query_akr.sh --high-complexity

# Find high-risk functions
bash .kiro/scripts/query_akr.sh --high-risk

# Find stale knowledge
bash .kiro/scripts/query_akr.sh --stale
```

### 4. Detect Conflicts
```bash
bash .kiro/scripts/detect_akr_conflicts.sh
```

---

## Database Schema

### artifacts table
```sql
CREATE TABLE artifacts (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL (function|module|file|pattern|issue),
  path TEXT,
  status TEXT NOT NULL (active|deprecated|archived),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  updated_by TEXT,
  UNIQUE(name, type)
);
```

### metrics table
```sql
CREATE TABLE metrics (
  id INTEGER PRIMARY KEY,
  artifact_id INTEGER NOT NULL UNIQUE,
  complexity INTEGER,
  lines_of_code INTEGER,
  parameter_count INTEGER,
  dependent_count INTEGER,
  return_count INTEGER,
  FOREIGN KEY(artifact_id) REFERENCES artifacts(id)
);
```

### Other tables
- `findings` — Individual findings about artifacts
- `issues` — Known issues and tool gaps
- `recommendations` — Actionable recommendations
- `dependencies` — Function call relationships
- `audit_trail` — Action history
- `staleness` — Knowledge age tracking

---

## Query Examples

### Find High-Complexity Functions
```bash
bash query_akr.sh --high-complexity --limit 10
```

### Find High-Risk Functions
```bash
bash query_akr.sh --high-risk
```

### Find Stale Knowledge
```bash
bash query_akr.sh --stale
```

### Find Recently Modified Artifacts
```bash
bash query_akr.sh --recent --days 7
```

### Find Concurrent Modifications
```bash
bash detect_akr_conflicts.sh --since 24
```

### Custom SQL Query
```bash
bash query_akr.sh --sql "SELECT name, complexity FROM high_complexity_functions WHERE complexity > 15"
```

---

## Performance Targets

| Operation | Target | Status |
|-----------|--------|--------|
| Query <100ms | 1000+ artifacts | 📋 To test |
| Sync <1s | 100 artifacts | 📋 To test |
| Database size | <100MB for 10,000 artifacts | 📋 To test |
| Concurrent access | Safe with file locking | 📋 To test |

---

## Next Steps

### Immediate (Today)
1. Test database initialization
2. Test sync with sample data
3. Test query performance

### This Week
1. Complete unit tests
2. Complete integration tests
3. Update commit_knowledge.sh
4. Update workflow rules

### Next Week
1. Performance tuning
2. Documentation finalization
3. Team training

---

## Troubleshooting

### Database not found
```bash
bash init_akr_db.sh
```

### Sync fails
```bash
# Check AKR directory exists
ls -la $BRODIR/etc/genero-akr/

# Check database is writable
sqlite3 $BRODIR/etc/genero-akr/akr.db "SELECT 1;"
```

### Query returns no results
```bash
# Check database has data
bash query_akr.sh --sql "SELECT COUNT(*) FROM artifacts;"

# Check sync completed
bash sync_akr_db.sh --full
```

### Performance issues
```bash
# Check database size
du -sh $BRODIR/etc/genero-akr/akr.db

# Analyze query performance
sqlite3 $BRODIR/etc/genero-akr/akr.db "EXPLAIN QUERY PLAN SELECT ..."
```

---

## Success Criteria

- ✅ Database initializes successfully
- ✅ Sync completes without errors
- ✅ Queries return correct results
- ✅ Queries complete in <100ms
- ✅ Conflict detection works
- ✅ Integration with workflow complete
- ✅ Documentation complete
- ✅ Team trained

---

## Related Documentation

- [FRAMEWORK_STATUS_AND_ROADMAP.md](../../FRAMEWORK_STATUS_AND_ROADMAP.md) — Phase 2 details
- [PHASE_2_DATABASE_LAYER.md](PHASE_2_DATABASE_LAYER.md) — Original design
- [CRITICAL_OVERVIEW.md](../../CRITICAL_OVERVIEW.md) — Framework overview

