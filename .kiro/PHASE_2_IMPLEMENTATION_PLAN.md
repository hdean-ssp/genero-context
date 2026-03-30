# Phase 2 Implementation Plan

**Phase:** 2 (Conflict Resolution & Metadata Automation)  
**Status:** In Progress  
**Effort:** 25-30 hours  
**Timeline:** Week 2  
**Date Created:** March 30, 2026

---

## Overview

Phase 2 adds automation and conflict handling to make AKR production-ready for concurrent multi-developer use.

**Goals:**
- ✅ Automatic metadata updates (no manual INDEX.md edits)
- ✅ Conflict resolution for simultaneous writes
- ✅ Knowledge comparison tool
- ✅ Statistics collection and reporting

---

## Tasks

### Task 1: Automatic Metadata Updates
**Effort:** 6-8 hours  
**Status:** ✅ COMPLETE

**What:** When knowledge is committed, automatically update:
- INDEX.md (master index of all knowledge)
- statistics.md (counts, trends, adoption metrics)
- last_updated.txt (timestamp)

**Implementation:**
- [x] Create `update_metadata.sh` script
- [x] Call from `commit_knowledge.sh` after successful commit
- [x] Update INDEX.md with new artifact entry
- [x] Update statistics (counts by type, last updated)
- [x] Handle concurrent updates safely (use locking)

**Files Created/Modified:**
- `.kiro/update_metadata.sh` (NEW) - 200 lines
- `.kiro/commit_knowledge.sh` (MODIFIED) - Added metadata update call

---

### Task 2: Conflict Resolution
**Effort:** 8-10 hours  
**Status:** ✅ COMPLETE

**What:** Handle simultaneous writes to same artifact:
- Detect when multiple agents write to same knowledge doc
- Merge findings intelligently
- Preserve analysis history
- Notify agents of merge

**Implementation:**
- [x] Create `merge_knowledge.sh` script
- [x] Detect conflicts in `commit_knowledge.sh`
- [x] Implement 3-way merge (existing + agent1 + agent2)
- [x] Preserve both findings in analysis history
- [x] Log merge events

**Files Created:**
- `.kiro/merge_knowledge.sh` (NEW) - 250 lines

---

### Task 3: Knowledge Comparison Tool
**Effort:** 5-7 hours  
**Status:** ✅ COMPLETE

**What:** Compare current findings with existing knowledge:
- Show what's new
- Show what changed
- Show what's the same
- Help agents understand impact

**Implementation:**
- [x] Create `compare_knowledge.sh` script
- [x] Compare current findings with existing knowledge
- [x] Generate comparison report
- [x] Show metrics changes
- [x] Show dependency changes

**Files Created:**
- `.kiro/compare_knowledge.sh` (NEW) - 280 lines

---

### Task 4: Statistics & Reporting
**Effort:** 4-6 hours  
**Status:** ✅ COMPLETE

**What:** Track adoption and usage metrics:
- Total knowledge documents
- Documents by type
- Documents by module
- Last updated dates
- Agent activity

**Implementation:**
- [x] Create `get_statistics.sh` script
- [x] Count documents by type
- [x] Track agent activity
- [x] Generate adoption report
- [x] Show trends

**Files Created:**
- `.kiro/get_statistics.sh` (NEW) - 220 lines

---

## Implementation Order

1. **Task 1: Automatic Metadata Updates** (Start now)
   - Simplest, highest impact
   - Unblocks other tasks
   - Solves manual update problem

2. **Task 2: Conflict Resolution** (After Task 1)
   - Depends on metadata updates
   - Critical for multi-developer safety
   - Prevents data loss

3. **Task 3: Knowledge Comparison** (After Task 2)
   - Helps agents understand changes
   - Improves decision-making
   - Nice-to-have but valuable

4. **Task 4: Statistics & Reporting** (After Task 3)
   - Tracks adoption
   - Helps with monitoring
   - Lowest priority

---

## Success Criteria

- [x] INDEX.md auto-updates when knowledge committed
- [x] statistics.md auto-updates with current counts
- [x] Simultaneous writes don't cause data loss
- [x] Conflicts are detected and merged
- [x] Agents can compare findings
- [x] Adoption metrics are tracked
- [x] All scripts have error handling
- [x] All scripts have logging
- [ ] Documentation updated

---

## Testing Strategy

### Unit Tests
- Test metadata update logic
- Test merge logic
- Test comparison logic
- Test statistics calculation

### Integration Tests
- Test concurrent commits
- Test metadata consistency
- Test conflict detection
- Test merge results

### Manual Tests
- Two agents commit to same artifact
- Verify merge is correct
- Verify metadata updates
- Verify statistics are accurate

---

## Documentation Updates

After implementation:
- [ ] Update `.kiro/AKR_SCRIPTS_README.md` with new scripts
- [ ] Update `.kiro/AKR_QUICK_START.md` with new workflows
- [ ] Update `.kiro/steering/genero-akr-workflow.md` with conflict handling
- [ ] Create troubleshooting guide for conflicts

---

## Rollout Plan

1. **Develop & Test** (Days 1-3)
   - Implement all 4 tasks
   - Test thoroughly
   - Fix issues

2. **Documentation** (Day 4)
   - Update all guides
   - Create examples
   - Test documentation

3. **Pilot** (Day 5)
   - Deploy to 2-3 developers
   - Gather feedback
   - Fix issues

4. **Full Rollout** (Day 6-7)
   - Deploy to all 10 developers
   - Monitor for issues
   - Provide support

---

## Risk Mitigation

**Risk:** Metadata updates fail, INDEX.md gets corrupted
- **Mitigation:** Backup INDEX.md before update, validate after update

**Risk:** Merge logic is wrong, data is lost
- **Mitigation:** Keep original files, test merge thoroughly, preserve history

**Risk:** Concurrent updates cause lock contention
- **Mitigation:** Use file locking, set reasonable timeouts

---

## Next Steps

1. Start Task 1: Automatic Metadata Updates
2. Create `update_metadata.sh` script
3. Modify `commit_knowledge.sh` to call update_metadata
4. Test with sample knowledge
5. Commit and push

