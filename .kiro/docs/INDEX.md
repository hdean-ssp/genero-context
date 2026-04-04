# Agent Documentation Index

**All agent-facing documentation for the Genero Context Framework**

---

## Quick Navigation

### 🚀 Start Here
- **[AGENT_QUICK_START.md](AGENT_QUICK_START.md)** — Quick start guide for new agents

### 📊 Current Status
- **[IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md)** — Current status and roadmap

### 🔍 Audit Logging (Phase 1 - Ready to Use)
- **[AUDIT_LOGGING_REFERENCE.md](AUDIT_LOGGING_REFERENCE.md)** — Commands and examples
- **[AUDIT_LOGGING_INTEGRATION.md](AUDIT_LOGGING_INTEGRATION.md)** — Where to log at each phase

### 🗄️ Upcoming Phases (Ready for Implementation)
- **[PHASE_2_DATABASE_LAYER.md](PHASE_2_DATABASE_LAYER.md)** — Database implementation (9h)
- **[PHASE_3_CHANGE_DETECTION.md](PHASE_3_CHANGE_DETECTION.md)** — Change detection (6h)
- **[PHASE_4_STALENESS_MANAGEMENT.md](PHASE_4_STALENESS_MANAGEMENT.md)** — Staleness management (5h)
- **[PHASE_5_INTEGRATION_TESTING.md](PHASE_5_INTEGRATION_TESTING.md)** — Integration & testing (3h)

---

## Documentation by Role

### For New Agents
1. Read: `AGENT_QUICK_START.md`
2. Check: `IMPLEMENTATION_STATUS.md`
3. Use: `AUDIT_LOGGING_REFERENCE.md`

### For Implementing Phase 2
1. Read: `PHASE_2_DATABASE_LAYER.md`
2. Reference: `FRAMEWORK_IMPROVEMENTS.md` (Phase 2 section)
3. Start: Task 1 (Design SQLite schema)

### For Implementing Phase 3
1. Read: `PHASE_3_CHANGE_DETECTION.md`
2. Reference: `FRAMEWORK_IMPROVEMENTS.md` (Phase 3 section)
3. Start: Task 1 (Implement track_source_hashes.sh)

### For Implementing Phase 4
1. Read: `PHASE_4_STALENESS_MANAGEMENT.md`
2. Reference: `FRAMEWORK_IMPROVEMENTS.md` (Phase 4 section)
3. Start: Task 1 (Implement detect_staleness.sh)

### For Integration & Testing
1. Read: `PHASE_5_INTEGRATION_TESTING.md`
2. Reference: All previous phases
3. Start: Task 1 (Full integration testing)

---

## Workflow Rules (Auto-Loaded)

These are automatically loaded by Kiro IDE:

- `.kiro/steering/genero-context-workflow.md` — AI-DLC workflow (Inception/Construction/Operation)
- `.kiro/steering/genero-akr-workflow.md` — AKR usage patterns
- `.kiro/steering/genero-context-queries.md` — genero-tools query reference
- `.kiro/steering/genero-context-operations.md` — Error handling and fallback strategies

---

## Current Implementation Status

| Phase | Task | Status | Effort | Priority |
|-------|------|--------|--------|----------|
| 1 | Audit Logging | ✅ COMPLETE | 4h | HIGH |
| 2 | Database Layer | 📋 READY | 9h | HIGH |
| 3 | Change Detection | 📋 READY | 6h | MEDIUM |
| 4 | Staleness Management | 📋 READY | 5h | MEDIUM |
| 5 | Integration & Testing | 📋 READY | 3h | HIGH |

**Total**: 27 hours (4 complete, 23 remaining)

---

## Key Commands

### Audit Logging

```bash
# Log an action
bash ~/.kiro/scripts/audit_log.sh --action AKR_RETRIEVE --phase INCEPTION --hat PLANNER \
  --artifact-type function --artifact-name process_order --result FOUND

# View audit log
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text
```

### AKR Management

```bash
# Retrieve knowledge
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"

# Commit findings
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "process_order" \
  --findings /tmp/findings.json --action append
```

### genero-tools Queries

```bash
# Find a function
bash $BRODIR/etc/genero-tools/query.sh find-function "process_order"

# Find dependents
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "process_order"
```

---

## Environment Setup

```bash
# Add to your shell configuration

# Audit logging
export GENERO_AKR_AUDIT_LOG="$BRODIR/etc/genero-akr/audit.log"
export GENERO_AKR_AUDIT_RETENTION_DAYS=30

# Optional: Enable debug logging
export DEBUG_AUDIT_LOG=0  # Set to 1 for debug output
```

---

## Workflow Checklist

### Inception Phase (Planner Hat)
- [ ] Check AKR for existing knowledge
- [ ] Query genero-tools for context
- [ ] Log actions to audit trail
- [ ] Document plan
- [ ] Present to human for approval

### Construction Phase (Builder Hat)
- [ ] Execute approved plan
- [ ] Query genero-tools as needed
- [ ] Log all actions
- [ ] Test thoroughly
- [ ] Present work for review

### Operation Phase (Reviewer Hat)
- [ ] Validate quality
- [ ] Check dependents
- [ ] Commit findings to AKR
- [ ] Log completion
- [ ] Get human approval

---

## Getting Help

### For Audit Logging
See: `AUDIT_LOGGING_REFERENCE.md` (Troubleshooting section)

### For AKR Issues
See: `.kiro/steering/genero-context-operations.md` (AKR Troubleshooting)

### For genero-tools Issues
See: `.kiro/steering/genero-context-operations.md` (Error Handling)

### For Framework Questions
See: `IMPLEMENTATION_STATUS.md` (Current status and roadmap)

---

## Key Principles

1. **AKR First** — Always check existing knowledge before querying genero-tools
2. **Log Everything** — Every action gets logged for traceability
3. **Verify Output** — When genero-tools returns incomplete data, read the source
4. **Three Gates** — Human approves plan, reviews work, approves completion
5. **Commit Findings** — Every task ends with AKR updated

---

## Next Steps

1. **New agent?** → Read `AGENT_QUICK_START.md`
2. **Check status?** → Read `IMPLEMENTATION_STATUS.md`
3. **Pick a phase?** → See phase-specific guides above
4. **Start implementing?** → Follow the phase guide

---

## File Structure

```
.kiro/docs/
├── INDEX.md                         ← This file
├── AGENT_QUICK_START.md             ← Start here
├── IMPLEMENTATION_STATUS.md         ← Current status
├── AUDIT_LOGGING_REFERENCE.md       ← Commands
├── AUDIT_LOGGING_INTEGRATION.md     ← Integration points
├── PHASE_2_DATABASE_LAYER.md        ← Phase 2 (9h)
├── PHASE_3_CHANGE_DETECTION.md      ← Phase 3 (6h)
├── PHASE_4_STALENESS_MANAGEMENT.md  ← Phase 4 (5h)
└── PHASE_5_INTEGRATION_TESTING.md   ← Phase 5 (3h)
```

---

## Summary

**Phase 1 (Audit Logging) is complete and ready to use.**

**Phases 2-5 are designed and ready for implementation** (23 hours remaining).

**Next priority**: Phase 2 (Database Layer) — 9 hours

Start with `AGENT_QUICK_START.md` for a quick introduction.

