# Agent Context & Documentation

**For agents working on the Genero Context Framework**

---

## Quick Start

**New to this project?** Start here:

1. **Read**: `.kiro/docs/AGENT_QUICK_START.md` — Quick start guide
2. **Check**: `.kiro/docs/IMPLEMENTATION_STATUS.md` — Current status and what's next
3. **Use**: `.kiro/docs/AUDIT_LOGGING_REFERENCE.md` — Audit logging commands

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

### For Audit Logging (Phase 1 - Ready to Use)
- `.kiro/docs/AUDIT_LOGGING_REFERENCE.md` — Commands and examples
- `.kiro/docs/AUDIT_LOGGING_INTEGRATION.md` — Where to log at each phase

### For Upcoming Phases
- `.kiro/docs/PHASE_2_DATABASE_LAYER.md` — Database implementation (9h)
- `.kiro/docs/PHASE_3_CHANGE_DETECTION.md` — Change detection (6h)
- `.kiro/docs/PHASE_4_STALENESS_MANAGEMENT.md` — Staleness management (5h)
- `.kiro/docs/PHASE_5_INTEGRATION_TESTING.md` — Integration & testing (3h)

### For Framework Overview
- `README.md` — Project overview
- `FRAMEWORK.md` — Architecture overview
- `INSTALLATION.md` — Setup guide

### For Reference & Analysis
- `FRAMEWORK_IMPROVEMENTS.md` — Comprehensive analysis of all issues and solutions
- `FRAMEWORK_ISSUES_ADDRESSED.md` — Detailed analysis of each issue

---

## How to Pick Up a Phase

### Phase 2: Database Layer (9 hours)
1. Read: `.kiro/docs/PHASE_2_DATABASE_LAYER.md`
2. Review: `FRAMEWORK_IMPROVEMENTS.md` (Phase 2 section)
3. Start with: Design SQLite schema (1 hour)

### Phase 3: Change Detection (6 hours)
1. Read: `.kiro/docs/PHASE_3_CHANGE_DETECTION.md`
2. Review: `FRAMEWORK_IMPROVEMENTS.md` (Phase 3 section)
3. Start with: Implement track_source_hashes.sh (1 hour)

### Phase 4: Staleness Management (5 hours)
1. Read: `.kiro/docs/PHASE_4_STALENESS_MANAGEMENT.md`
2. Review: `FRAMEWORK_IMPROVEMENTS.md` (Phase 4 section)
3. Start with: Implement detect_staleness.sh (1 hour)

### Phase 5: Integration & Testing (3 hours)
1. Read: `.kiro/docs/PHASE_5_INTEGRATION_TESTING.md`
2. Review: All previous phases
3. Start with: Full integration testing (1 hour)

---

## Key Commands

### Audit Logging (Phase 1)

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

### genero-tools Queries

```bash
# Find a function
bash $BRODIR/etc/genero-tools/query.sh find-function "process_order"

# Find dependents
bash $BRODIR/etc/genero-tools/query.sh find-function-dependents "process_order"

# Find dependencies
bash $BRODIR/etc/genero-tools/query.sh find-function-dependencies "process_order"
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

## Key Principles

1. **AKR First** — Always check existing knowledge before querying genero-tools
2. **Log Everything** — Every action gets logged for traceability
3. **Verify Output** — When genero-tools returns incomplete data, read the source
4. **Three Gates** — Human approves plan, reviews work, approves completion
5. **Commit Findings** — Every task ends with AKR updated

---

## Next Steps

1. **Read the quick start**: `.kiro/docs/AGENT_QUICK_START.md`
2. **Check the status**: `.kiro/docs/IMPLEMENTATION_STATUS.md`
3. **Pick a phase**: See "How to Pick Up a Phase" above
4. **Start implementing**: Follow the phase-specific guide

---

## Files & Directories

```
Project Root (User-Facing)
├── README.md                    ← Project overview
├── FRAMEWORK.md                 ← Architecture overview
├── INSTALLATION.md              ← Setup guide
├── LICENSE
├── install.sh
├── README_AGENT_CONTEXT.md      ← This file
├── FRAMEWORK_IMPROVEMENTS.md    ← Reference: Analysis & solutions
├── FRAMEWORK_ISSUES_ADDRESSED.md ← Reference: Issue analysis
│
└── .kiro/
    ├── README.md                ← Framework files overview
    ├── scripts/                 ← 20 AKR management scripts
    ├── steering/                ← Workflow rules (auto-loaded)
    ├── hooks/                   ← Automatic quality checks
    ├── skills/                  ← AKR Management Specialist
    ├── tests/                   ← Test suite
    ├── genero-tools-docs/       ← genero-tools reference
    │
    └── docs/                    ← Agent-facing documentation
        ├── AGENT_QUICK_START.md
        ├── IMPLEMENTATION_STATUS.md
        ├── AUDIT_LOGGING_REFERENCE.md
        ├── AUDIT_LOGGING_INTEGRATION.md
        ├── PHASE_2_DATABASE_LAYER.md
        ├── PHASE_3_CHANGE_DETECTION.md
        ├── PHASE_4_STALENESS_MANAGEMENT.md
        └── PHASE_5_INTEGRATION_TESTING.md
```

---

## Summary

**Phase 1 (Audit Logging) is complete and ready to use.**

**Phases 2-5 are designed and ready for implementation** (23 hours remaining).

**Next priority**: Phase 2 (Database Layer) — 9 hours

Start with `.kiro/docs/AGENT_QUICK_START.md` for a quick introduction.

