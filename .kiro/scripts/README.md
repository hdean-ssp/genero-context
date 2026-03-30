# AKR Scripts

**Production-ready scripts for the Agent Knowledge Repository system.**

---

## Overview

This directory contains 18 production-ready scripts organized by phase:

- **Phase 1 (5 scripts):** Core functionality - Retrieve, Commit, Search, Validate
- **Phase 2 (4 scripts):** Metadata & Conflict - Updates, Merging, Comparison, Statistics
- **Phase 3 (4 scripts):** Search & Analysis - Indexing, Patterns, Issues
- **Phase 4 (5 scripts):** Automation & Audit - Hooks, Audit Trail, Quality Scoring

---

## Quick Start

### Initialize AKR (Admin Only)

```bash
bash .kiro/scripts/setup_akr.sh
```

### Retrieve Knowledge (Agent)

```bash
bash .kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"
```

### Commit Knowledge (Agent)

```bash
bash .kiro/scripts/commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action append
```

### Search Knowledge (Agent)

```bash
bash .kiro/scripts/search_knowledge.sh --query "error handling"
```

---

## Scripts by Phase

### Phase 1: Core Functionality

| Script | Purpose |
|--------|---------|
| `setup_akr.sh` | Initialize AKR directory structure |
| `retrieve_knowledge.sh` | Get existing knowledge about artifacts |
| `commit_knowledge.sh` | Save knowledge with file locking |
| `search_knowledge.sh` | Find knowledge by query |
| `validate_knowledge.sh` | Check schema compliance |

### Phase 2: Metadata & Conflict Resolution

| Script | Purpose |
|--------|---------|
| `update_metadata.sh` | Auto-update INDEX.md, statistics.md |
| `merge_knowledge.sh` | Merge conflicting writes |
| `compare_knowledge.sh` | Compare findings with existing knowledge |
| `get_statistics.sh` | Track adoption metrics |

### Phase 3: Search & Pattern Analysis

| Script | Purpose |
|--------|---------|
| `build_index.sh` | Build search index for fast lookup |
| `search_indexed.sh` | Fast full-text search (<50ms) |
| `detect_patterns.sh` | Discover patterns across knowledge |
| `flag_issues.sh` | Detect and flag issues |

### Phase 4: Automation & Audit

| Script | Purpose |
|--------|---------|
| `auto_retrieve.sh` | Auto-retrieve in Planner Hat |
| `auto_commit.sh` | Auto-commit with action selection |
| `audit_trail.sh` | Generate audit trail |
| `quality_score.sh` | Score knowledge quality |

### Configuration

| File | Purpose |
|------|---------|
| `akr-config.sh` | Centralized configuration (change AKR path here) |

---

## Configuration

### Change AKR Location

Edit `akr-config.sh`:

```bash
# Default: $BRODIR/etc/genero-akr
export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"

# Change to your preferred location:
export GENERO_AKR_BASE_PATH="/shared/genero-akr"
```

Then run setup:
```bash
bash .kiro/scripts/setup_akr.sh
```

### Environment Variables

```bash
# Set agent ID for logging
export GENERO_AGENT_ID="agent-1"

# Set log level
export GENERO_AKR_LOG_LEVEL="info"  # debug, info, warning, error
```

---

## Usage Examples

### Retrieve Knowledge

```bash
# Retrieve function knowledge
bash .kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"

# Retrieve file knowledge
bash .kiro/scripts/retrieve_knowledge.sh --type file --path "src/orders.4gl"

# Retrieve module knowledge
bash .kiro/scripts/retrieve_knowledge.sh --type module --name "payment"
```

### Commit Knowledge

```bash
# Create new knowledge
bash .kiro/scripts/commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action create

# Append to existing knowledge
bash .kiro/scripts/commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action append

# Update existing knowledge
bash .kiro/scripts/commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action update
```

### Search Knowledge

```bash
# Search all knowledge
bash .kiro/scripts/search_knowledge.sh --query "error handling"

# Search indexed (fast)
bash .kiro/scripts/search_indexed.sh --query "validation" --type function

# Build index first
bash .kiro/scripts/build_index.sh
```

### Compare Knowledge

```bash
# Compare before committing
bash .kiro/scripts/compare_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json
```

### Get Statistics

```bash
# Text format
bash .kiro/scripts/get_statistics.sh

# JSON format
bash .kiro/scripts/get_statistics.sh --format json

# CSV format
bash .kiro/scripts/get_statistics.sh --format csv
```

### Detect Patterns

```bash
# Quick summary
bash .kiro/scripts/detect_patterns.sh

# Detailed report
bash .kiro/scripts/detect_patterns.sh --report

# Analyze specific type
bash .kiro/scripts/detect_patterns.sh --type function --report
```

### Flag Issues

```bash
# Quick summary
bash .kiro/scripts/flag_issues.sh

# Detailed report
bash .kiro/scripts/flag_issues.sh --report
```

### Quality Scoring

```bash
# Score all knowledge
bash .kiro/scripts/quality_score.sh

# Show only low-quality
bash .kiro/scripts/quality_score.sh --threshold 70

# Score specific type
bash .kiro/scripts/quality_score.sh --type function
```

### Audit Trail

```bash
# View all activities
bash .kiro/scripts/audit_trail.sh

# Filter by agent
bash .kiro/scripts/audit_trail.sh --agent agent-1

# JSON format
bash .kiro/scripts/audit_trail.sh --format json
```

---

## Error Handling

All scripts include:
- ✅ Error checking and validation
- ✅ Logging to `$GENERO_AKR_BASE_PATH/.logs/akr.log`
- ✅ File locking for concurrent safety
- ✅ Meaningful error messages
- ✅ Exit codes for scripting

### Common Issues

**"AKR base path does not exist"**
```bash
bash .kiro/scripts/setup_akr.sh
```

**"Permission denied"**
```bash
# Check permissions
ls -la $GENERO_AKR_BASE_PATH

# Ask admin to fix if needed
chmod 775 $GENERO_AKR_BASE_PATH
chmod 775 $GENERO_AKR_BASE_PATH/*
```

**"Failed to acquire lock"**
```bash
# Wait 30 seconds and retry
sleep 30
bash .kiro/scripts/commit_knowledge.sh ...
```

---

## Documentation

- **Quick Start:** `.kiro/AKR_QUICK_START.md`
- **Comprehensive Guide:** `.kiro/AKR_SCRIPTS_README.md`
- **Workflow Integration:** `.kiro/steering/genero-akr-workflow.md`
- **Installation:** `INSTALLATION.md`

---

## Support

For issues or questions:
1. Check logs: `tail -f $GENERO_AKR_BASE_PATH/.logs/akr.log`
2. Validate setup: `bash .kiro/scripts/validate_knowledge.sh`
3. Review documentation: `.kiro/AKR_SCRIPTS_README.md`
4. Check steering files: `.kiro/steering/genero-akr-workflow.md`

---

## Version

- **Framework Version:** 1.0.0
- **Phase:** 4 (Complete)
- **Status:** Production Ready
- **Total Scripts:** 18
- **Total Lines:** 3,000+

