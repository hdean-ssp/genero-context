# Genero Framework Installation & Setup Guide

**Complete guide to install and configure the Genero Framework for AI-powered code analysis.**

---

## What You're Installing

A complete system for AI agents to work consistently and intelligently on Genero/4GL codebases with shared institutional memory.

**Components:**
1. **Workflow Guidance** - Consistent AI-DLC workflow for all agents
2. **Agent Knowledge Repository (AKR)** - Shared knowledge system
3. **Production Scripts** - Retrieve, commit, search, validate knowledge
4. **Comprehensive Documentation** - Guides and references

---

## Prerequisites

- Linux/Unix system (RHEL 9 or compatible)
- Bash 4.0+
- Standard utilities: grep, sed, awk, mkdir, chmod
- Write access to shared directory (for AKR)
- Optional: `jq` for JSON parsing (scripts work without it)

---

## Quick Start (5 Minutes)

### Step 1: Clone Repository

```bash
git clone https://github.com/hdean-ssp/genero-context.git
cd genero-context
```

### Step 2: Initialize AKR (Admin Only)

```bash
bash .kiro/setup_akr.sh
```

This creates the AKR directory structure at `$BRODIR/etc/genero-akr` (or `/opt/genero/etc/genero-akr`).

### Step 3: Verify Setup

```bash
bash .kiro/validate_knowledge.sh
```

Expected output:
```
[SUCCESS] All knowledge documents are valid!
```

### Step 4: Read Quick Start

```bash
cat .kiro/AKR_QUICK_START.md
```

---

## Installation Steps

### Step 1: Determine Installation Location

The framework can be installed anywhere. By default, it uses:
- **AKR Path:** `$BRODIR/etc/genero-akr` (or `/opt/genero/etc/genero-akr`)
- **Scripts:** `.kiro/` directory in your workspace

### Step 2: Configure AKR Path (Optional)

If you want to use a different path:

1. Edit `.kiro/akr-config.sh`:
   ```bash
   # Change this line:
   export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"
   
   # To your desired path:
   export GENERO_AKR_BASE_PATH="/shared/genero-akr"
   ```

2. Save the file

### Step 3: Initialize AKR

Run as admin/root:

```bash
bash .kiro/setup_akr.sh
```

This creates:
```
$GENERO_AKR_BASE_PATH/
├── files/              # File-level knowledge
├── functions/          # Function-level knowledge
├── modules/            # Module-level knowledge
├── patterns/           # Discovered patterns
├── issues/             # Known issues & risks
├── metadata/           # System metadata
├── .locks/             # Lock files (internal)
├── .logs/              # Log files (internal)
├── README.md           # Repository overview
├── SCHEMA.md           # Knowledge document schema
└── INDEX.md            # Master index
```

### Step 4: Verify Installation

```bash
bash .kiro/validate_knowledge.sh
```

### Step 5: Test Scripts

```bash
# Test retrieval (will fail - no knowledge yet, this is normal)
bash .kiro/retrieve_knowledge.sh --type function --name "test"

# Test search
bash .kiro/search_knowledge.sh --query "test"

# Test validation
bash .kiro/validate_knowledge.sh
```

---

## Configuration

### AKR Path Configuration

All paths are configured in `.kiro/akr-config.sh`:

```bash
# Main configuration (change this to move AKR)
export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"

# Derived paths (auto-configured)
export GENERO_AKR_FILES="${GENERO_AKR_BASE_PATH}/files"
export GENERO_AKR_FUNCTIONS="${GENERO_AKR_BASE_PATH}/functions"
export GENERO_AKR_MODULES="${GENERO_AKR_BASE_PATH}/modules"
export GENERO_AKR_PATTERNS="${GENERO_AKR_BASE_PATH}/patterns"
export GENERO_AKR_ISSUES="${GENERO_AKR_BASE_PATH}/issues"
export GENERO_AKR_METADATA="${GENERO_AKR_BASE_PATH}/metadata"
export GENERO_AKR_LOCKS="${GENERO_AKR_BASE_PATH}/.locks"
export GENERO_AKR_LOGS="${GENERO_AKR_BASE_PATH}/.logs"
```

### Environment Variables

```bash
# Set agent ID for logging
export GENERO_AGENT_ID="agent-1"

# Set log level (debug, info, warning, error)
export GENERO_AKR_LOG_LEVEL="info"

# Then run scripts
bash .kiro/commit_knowledge.sh --type function --name "my_func" --findings findings.json --action create
```

---

## File Permissions

For shared access by multiple developers:

```bash
# Check permissions
ls -la $GENERO_AKR_BASE_PATH

# Should be: drwxrwxr-x (775)
# If not, fix permissions (admin only):
chmod 775 $GENERO_AKR_BASE_PATH
chmod 775 $GENERO_AKR_BASE_PATH/*
```

---

## Scripts Overview

### setup_akr.sh
Initialize AKR directory structure and files.
```bash
bash .kiro/setup_akr.sh
```

### retrieve_knowledge.sh
Get existing knowledge about an artifact.
```bash
bash .kiro/retrieve_knowledge.sh --type function --name "process_order"
```

### commit_knowledge.sh
Save knowledge about an artifact.
```bash
bash .kiro/commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action append
```

### search_knowledge.sh
Search for knowledge in the repository.
```bash
bash .kiro/search_knowledge.sh --query "type resolution"
```

### validate_knowledge.sh
Check schema compliance and consistency.
```bash
bash .kiro/validate_knowledge.sh
```

---

## Documentation

### For Getting Started
- **[.kiro/AKR_QUICK_START.md](.kiro/AKR_QUICK_START.md)** - 10-step quick start guide
- **[.kiro/AKR_SCRIPTS_README.md](.kiro/AKR_SCRIPTS_README.md)** - Comprehensive script guide

### For Workflow Integration
- **[.kiro/steering/genero-akr-workflow.md](.kiro/steering/genero-akr-workflow.md)** - How agents use AKR
- **[.kiro/steering/genero-context-workflow.md](.kiro/steering/genero-context-workflow.md)** - AI-DLC workflow
- **[.kiro/steering/genero-context-operations.md](.kiro/steering/genero-context-operations.md)** - Operations guide
- **[.kiro/steering/genero-context-queries.md](.kiro/steering/genero-context-queries.md)** - Query reference

### For genero-tools
- **[genero-tools-docs/GENERO_TOOLS_REFERENCE.md](genero-tools-docs/GENERO_TOOLS_REFERENCE.md)** - Query reference
- **[genero-tools-docs/GENERO_TOOLS_SETUP.md](genero-tools-docs/GENERO_TOOLS_SETUP.md)** - Setup guide

---

## Troubleshooting

### "AKR base path does not exist"
```bash
bash .kiro/setup_akr.sh
```

### "Permission denied"
```bash
# Check permissions
ls -la $GENERO_AKR_BASE_PATH

# Ask admin to fix if needed
chmod 775 $GENERO_AKR_BASE_PATH
chmod 775 $GENERO_AKR_BASE_PATH/*
```

### "Knowledge not found"
This is normal if no knowledge has been created yet. Create sample knowledge:
```bash
cat > /tmp/findings.json << 'EOF'
{
  "summary": "Test function",
  "key_findings": ["Test finding"],
  "metrics": {"complexity": 5}
}
EOF

bash .kiro/commit_knowledge.sh \
  --type function \
  --name "test_function" \
  --findings /tmp/findings.json \
  --action create
```

### "Failed to acquire lock"
Wait 30 seconds and try again (lock will be released):
```bash
sleep 30
bash .kiro/commit_knowledge.sh ...
```

---

## Next Steps

1. **Read Quick Start:** `.kiro/AKR_QUICK_START.md`
2. **Understand Workflow:** `.kiro/steering/genero-akr-workflow.md`
3. **Train Your Team:** Share `.kiro/AKR_SCRIPTS_README.md`
4. **Start Using:** Retrieve and commit knowledge
5. **Monitor Adoption:** Track usage and gather feedback

---

## Support

- **Quick Start:** `.kiro/AKR_QUICK_START.md`
- **Full Guide:** `.kiro/AKR_SCRIPTS_README.md`
- **Workflow:** `.kiro/steering/genero-akr-workflow.md`
- **Validation:** `bash .kiro/validate_knowledge.sh`
- **Logs:** `$GENERO_AKR_BASE_PATH/.logs/akr.log`

---

## What's Included

### Essential Files (User-Facing)
- `.kiro/setup_akr.sh` - Setup script
- `.kiro/retrieve_knowledge.sh` - Retrieval script
- `.kiro/commit_knowledge.sh` - Commit script
- `.kiro/search_knowledge.sh` - Search script
- `.kiro/validate_knowledge.sh` - Validation script
- `.kiro/akr-config.sh` - Configuration
- `.kiro/AKR_QUICK_START.md` - Quick start guide
- `.kiro/AKR_SCRIPTS_README.md` - Comprehensive guide
- `.kiro/steering/` - Workflow guidance files
- `genero-tools-docs/` - genero-tools documentation

### Archived Files (Reference Only)
- `.kiro/archive/CRITICAL_ANALYSIS.md` - Technical analysis
- `.kiro/archive/FRAMEWORK_VALUE_PROPOSITION.md` - Value proposition
- `.kiro/archive/genero-framework-assessment.md` - Framework assessment
- `.kiro/archive/genero-agent-knowledge-repository.md` - AKR concept

---

## Version Information

- **Framework Version:** 1.0.0
- **Phase:** 1 (Complete)
- **Status:** Production Ready
- **Last Updated:** March 30, 2026

