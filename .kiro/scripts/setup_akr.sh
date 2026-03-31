#!/bin/bash
# Setup AKR (Agent Knowledge Repository)
# One-time setup script to initialize the AKR directory structure
# Run this as admin/root to set up shared AKR

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/akr-config.sh"

# ============================================================================
# Dependency Verification
# ============================================================================

log_info() {
  echo "[INFO] $*"
}

log_error() {
  echo "[ERROR] $*" >&2
}

log_success() {
  echo "[SUCCESS] $*"
}

log_warning() {
  echo "[WARNING] $*"
}

# Verify dependencies before proceeding
log_info "Verifying dependencies..."
DEPENDENCY_STATUS=$(get_dependency_status)

if [ "$DEPENDENCY_STATUS" = "MISSING_REQUIRED" ]; then
  log_error "Missing required dependencies. Cannot proceed."
  verify_dependencies
  exit 1
fi

if [ "$DEPENDENCY_STATUS" = "MISSING_OPTIONAL" ]; then
  log_warning "Missing optional dependencies. Framework will work with limited features."
  verify_dependencies
fi

log_success "All required dependencies are available"

# ============================================================================
# Functions
# ============================================================================

# ============================================================================
# Main Setup
# ============================================================================

log_info "Setting up AKR at: $GENERO_AKR_BASE_PATH"

# Create base directory
if [ ! -d "$GENERO_AKR_BASE_PATH" ]; then
  log_info "Creating base directory: $GENERO_AKR_BASE_PATH"
  mkdir -p "$GENERO_AKR_BASE_PATH"
  chmod 775 "$GENERO_AKR_BASE_PATH"
else
  log_info "Base directory already exists"
fi

# Create subdirectories
for dir in files functions modules patterns issues metadata .locks .logs; do
  if [ ! -d "$GENERO_AKR_BASE_PATH/$dir" ]; then
    log_info "Creating directory: $dir"
    mkdir -p "$GENERO_AKR_BASE_PATH/$dir"
    chmod 775 "$GENERO_AKR_BASE_PATH/$dir"
  else
    log_info "Directory already exists: $dir"
  fi
done

# Create schema document
if [ ! -f "$GENERO_AKR_BASE_PATH/SCHEMA.md" ]; then
  log_info "Creating SCHEMA.md"
  cat > "$GENERO_AKR_BASE_PATH/SCHEMA.md" << 'EOF'
# AKR Knowledge Document Schema

## Document Structure

All knowledge documents follow this structure:

```markdown
# [Artifact Name]

**Type:** file | function | module | pattern | issue  
**Path:** [Full path to artifact]  
**Last Updated:** [ISO timestamp]  
**Updated By:** [Agent name/ID]  
**Status:** active | deprecated | archived

## Summary
[1-2 sentence overview]

## Key Findings
- Finding 1
- Finding 2
- Finding 3

## Metrics
- Complexity: [value]
- Lines of Code: [value]
- Parameter Count: [value]
- Dependent Count: [value]

## Dependencies
- Calls: [list of functions]
- Called By: [list of functions]
- Related Files: [list of files]

## Type Information
- Parameters: [type details]
- Returns: [type details]
- LIKE References: [resolved types]

## Patterns & Conventions
- Naming: [pattern]
- Error Handling: [approach]
- Validation: [approach]

## Known Issues
- Issue 1: [description]
- Issue 2: [description]

## Recommendations
- Recommendation 1
- Recommendation 2

## Related Knowledge
- [Link to related artifact]
- [Link to related pattern]

## Analysis History
| Date | Agent | Action | Notes |
|------|-------|--------|-------|
| 2026-03-30 | agent-1 | initial_analysis | Found 12 dependents |
| 2026-03-31 | agent-2 | extended_analysis | Added type resolution |

## Raw Data
[Optional: Raw genero-tools output]
```

## File Naming Convention

- Files: `files/[path_with_underscores].md`
  - Example: `files/src_orders_4gl.md`
- Functions: `functions/[function_name].md`
  - Example: `functions/process_order.md`
- Modules: `modules/[module_name].md`
  - Example: `modules/payment_module.md`
- Patterns: `patterns/[pattern_name].md`
  - Example: `patterns/error_handling.md`
- Issues: `issues/[issue_name].md`
  - Example: `issues/circular_dependencies.md`

## Validation Rules

- All paths must be relative to codebase root
- All timestamps must be ISO 8601 format
- All metrics must be non-negative integers
- All references must point to existing artifacts
- Status must be one of: active, deprecated, archived
EOF
  chmod 644 "$GENERO_AKR_BASE_PATH/SCHEMA.md"
else
  log_info "SCHEMA.md already exists"
fi

# Create README
if [ ! -f "$GENERO_AKR_BASE_PATH/README.md" ]; then
  log_info "Creating README.md"
  cat > "$GENERO_AKR_BASE_PATH/README.md" << 'EOF'
# Agent Knowledge Repository (AKR)

Shared knowledge system where agents commit, retrieve, and build upon analysis of Genero/4GL code artifacts.

## Directory Structure

```
.
├── README.md              # This file
├── SCHEMA.md              # Knowledge document schema
├── INDEX.md               # Master index (auto-updated)
├── files/                 # File-level knowledge
├── functions/             # Function-level knowledge
├── modules/               # Module-level knowledge
├── patterns/              # Discovered patterns
├── issues/                # Known issues & risks
├── metadata/              # System metadata
├── .locks/                # Lock files (internal)
└── .logs/                 # Log files (internal)
```

## Quick Start

### Retrieve Knowledge
```bash
bash retrieve_knowledge.sh --type function --name "process_order"
```

### Commit Knowledge
```bash
bash commit_knowledge.sh --type function --name "process_order" --findings findings.json --action append
```

### Search Knowledge
```bash
bash search_knowledge.sh --query "type resolution"
```

## Documentation

- See `.kiro/steering/genero-akr-workflow.md` for workflow guide
- See `SCHEMA.md` for knowledge document format
- See `INDEX.md` for artifact index

## Configuration

AKR path is configured in `.kiro/akr-config.sh`

To change the AKR location:
1. Edit `.kiro/akr-config.sh`
2. Change `GENERO_AKR_BASE_PATH` variable
3. Run `bash setup_akr.sh` to initialize new location
EOF
  chmod 644 "$GENERO_AKR_BASE_PATH/README.md"
else
  log_info "README.md already exists"
fi

# Create INDEX.md template
if [ ! -f "$GENERO_AKR_BASE_PATH/INDEX.md" ]; then
  log_info "Creating INDEX.md"
  cat > "$GENERO_AKR_BASE_PATH/INDEX.md" << 'EOF'
# Agent Knowledge Repository Index

**Last Updated:** [Auto-updated by scripts]  
**Total Artifacts:** 0  
**Total Knowledge Documents:** 0

## Files
(None yet)

## Functions
(None yet)

## Modules
(None yet)

## Patterns
(None yet)

## Issues
(None yet)

## Statistics
- Total Analyses: 0
- Agents Contributed: 0
- Average Knowledge Age: N/A
- Most Analyzed Artifact: N/A
EOF
  chmod 644 "$GENERO_AKR_BASE_PATH/INDEX.md"
else
  log_info "INDEX.md already exists"
fi

# Create metadata files
if [ ! -f "$GENERO_AKR_METADATA/agents.md" ]; then
  log_info "Creating agents.md"
  cat > "$GENERO_AKR_METADATA/agents.md" << 'EOF'
# Agent Activity Log

| Date | Agent | Action | Artifact | Type | Status |
|------|-------|--------|----------|------|--------|
EOF
  chmod 644 "$GENERO_AKR_METADATA/agents.md"
else
  log_info "agents.md already exists"
fi

if [ ! -f "$GENERO_AKR_METADATA/statistics.md" ]; then
  log_info "Creating statistics.md"
  cat > "$GENERO_AKR_METADATA/statistics.md" << 'EOF'
# AKR Statistics

**Last Updated:** [Auto-updated]

## Counts
- Total Knowledge Documents: 0
- Files: 0
- Functions: 0
- Modules: 0
- Patterns: 0
- Issues: 0

## Status Distribution
- Active: 0
- Updated: 0
- Deprecated: 0
- Archived: 0

## Agent Statistics
- Total Agents: 0
- Total Analyses: 0
- Average Analyses per Agent: 0

## Artifact Statistics
- Most Analyzed: N/A
- Least Analyzed: N/A
- Average Age: N/A
EOF
  chmod 644 "$GENERO_AKR_METADATA/statistics.md"
else
  log_info "statistics.md already exists"
fi

if [ ! -f "$GENERO_AKR_METADATA/last_updated.txt" ]; then
  log_info "Creating last_updated.txt"
  date -u +"%Y-%m-%dT%H:%M:%SZ" > "$GENERO_AKR_METADATA/last_updated.txt"
  chmod 644 "$GENERO_AKR_METADATA/last_updated.txt"
else
  log_info "last_updated.txt already exists"
fi

# Set permissions for shared access
log_info "Setting permissions for shared access"
chmod 775 "$GENERO_AKR_BASE_PATH"
chmod 775 "$GENERO_AKR_BASE_PATH"/*
chmod 644 "$GENERO_AKR_BASE_PATH"/*.md
chmod 644 "$GENERO_AKR_METADATA"/*

log_success "AKR setup complete!"
log_info "AKR location: $GENERO_AKR_BASE_PATH"
log_info "To change location, edit: .kiro/akr-config.sh"
log_info ""
log_info "Next steps:"
log_info "1. Verify permissions: ls -la $GENERO_AKR_BASE_PATH"
log_info "2. Test retrieval: bash retrieve_knowledge.sh --type function --name test"
log_info "3. See workflow guide: .kiro/steering/genero-akr-workflow.md"
