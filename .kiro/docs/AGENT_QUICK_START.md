# Agent Quick Start Guide

**For agents starting a new task on the Genero Context Framework**

---

## Before You Start Any Task

### 1. Check the Current Status
```bash
# See what phases are complete and what's next
cat .kiro/docs/IMPLEMENTATION_STATUS.md
```

### 2. Understand the Workflow
- Read: `.kiro/steering/genero-context-workflow.md` (auto-loaded by Kiro)
- This defines the three phases: Inception, Construction, Operation

### 3. Know Your Tools
- **genero-tools**: Query code structure and dependencies
- **AKR scripts**: Retrieve and commit knowledge
- **Audit logging**: Log all actions for traceability

---

## Quick Command Reference

### Audit Logging (Phase 1 - Ready to Use)

```bash
# Log an action
bash ~/.kiro/scripts/audit_log.sh \
  --action AKR_RETRIEVE \
  --phase INCEPTION \
  --hat PLANNER \
  --artifact-type function \
  --artifact-name process_order \
  --result FOUND

# View audit log
bash ~/.kiro/scripts/view_audit.sh --since 24 --format text
bash ~/.kiro/scripts/view_audit.sh --artifact process_order --format json
```

See: `.kiro/docs/AUDIT_LOGGING_REFERENCE.md`

### AKR Management

```bash
# Retrieve knowledge
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"

# Commit findings
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "process_order" \
  --findings /tmp/findings.json --action append

# Search knowledge
bash ~/.kiro/scripts/search_knowledge.sh --query "type resolution"
```

See: `.kiro/steering/genero-akr-workflow.md`

### genero-tools Queries

```bash
# Find a function
bash $BRODIR/etc/genero-tools/query.sh find-function "process_order"

# Find dependents
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "process_order"

# Find dependencies
bash $BRODIR/etc/genero-tools/query.sh find-function-dependencies "process_order"
```

See: `.kiro/steering/genero-context-queries.md`

---

## Current Implementation Status

| Phase | Task | Status | Effort |
|-------|------|--------|--------|
| 1 | Audit Logging | ✅ COMPLETE | 4h |
| 2 | Database Layer | 📋 READY | 9h |
| 3 | Change Detection | 📋 READY | 6h |
| 4 | Staleness Management | 📋 READY | 5h |
| 5 | Integration & Testing | 📋 READY | 3h |

**Next priority**: Phase 2 (Database Layer) — 9 hours

---

## Documentation Map

### For Your Current Task
- `.kiro/steering/genero-context-workflow.md` — Workflow rules (auto-loaded)
- `.kiro/steering/genero-akr-workflow.md` — AKR usage patterns
- `.kiro/steering/genero-context-queries.md` — genero-tools reference
- `.kiro/steering/genero-context-operations.md` — Error handling

### For Audit Logging (Phase 1)
- `.kiro/docs/AUDIT_LOGGING_REFERENCE.md` — Commands and examples
- `.kiro/docs/AUDIT_LOGGING_INTEGRATION.md` — Where to log at each phase

### For Upcoming Phases
- `.kiro/docs/PHASE_2_DATABASE_LAYER.md` — Database implementation (9h)
- `.kiro/docs/PHASE_3_CHANGE_DETECTION.md` — Change detection (6h)
- `.kiro/docs/PHASE_4_STALENESS_MANAGEMENT.md` — Staleness management (5h)
- `.kiro/docs/PHASE_5_INTEGRATION_TESTING.md` — Integration & testing (3h)

### For Framework Overview
- `README.md` — Project overview (user-facing)
- `INSTALLATION.md` — Setup guide (user-facing)
- `FRAMEWORK.md` — Architecture overview (user-facing)

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

## Environment Setup

```bash
# Add to your shell configuration (.bashrc, .zshrc, etc.)

# Audit logging
export GENERO_AKR_AUDIT_LOG="$BRODIR/etc/genero-akr/audit.log"
export GENERO_AKR_AUDIT_RETENTION_DAYS=30

# Optional: Enable debug logging
export DEBUG_AUDIT_LOG=0  # Set to 1 for debug output
```

---

## Getting Help

### For Audit Logging Issues
See: `.kiro/docs/AUDIT_LOGGING_REFERENCE.md` (Troubleshooting section)

### For AKR Issues
See: `.kiro/steering/genero-context-operations.md` (AKR Troubleshooting)

### For genero-tools Issues
See: `.kiro/steering/genero-context-operations.md` (Error Handling)

### For Framework Questions
See: `.kiro/docs/IMPLEMENTATION_STATUS.md` (Current status and roadmap)

---

## Next Steps

1. **Read the workflow rules**: `.kiro/steering/genero-context-workflow.md`
2. **Understand your role**: Planner Hat, Builder Hat, or Reviewer Hat
3. **Use the quick reference**: `.kiro/docs/AUDIT_LOGGING_REFERENCE.md`
4. **Start your task**: Follow the workflow checklist above

---

## Key Principles

1. **AKR First** — Always check existing knowledge before querying genero-tools
2. **Log Everything** — Every action gets logged for traceability
3. **Verify Output** — When genero-tools returns incomplete data, read the source
4. **Three Gates** — Human approves plan, reviews work, approves completion
5. **Commit Findings** — Every task ends with AKR updated

---

See also: `.kiro/docs/IMPLEMENTATION_STATUS.md` for current status and upcoming phases.

