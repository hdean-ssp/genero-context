# Genero Framework Installation & Setup Guide

**Complete guide to install and configure the Genero Framework for AI-powered code analysis.**

**Last Updated:** March 30, 2026  
**Framework Version:** 1.0.0  
**Status:** Production Ready

---

## What You're Installing

A complete system for AI agents to work consistently and intelligently on Genero/4GL codebases with shared institutional memory.

**Four Core Components:**

1. **Workflow Guidance** (Steering Files)
   - Consistent AI-DLC workflow (Inception → Construction → Operation)
   - Hat-based roles (Planner/Builder/Reviewer)
   - Clear integration points for knowledge retrieval and commitment
   - Files: `.kiro/steering/genero-*.md`

2. **Agent Knowledge Repository (AKR)**
   - Shared knowledge system for code artifacts
   - Support for functions, files, modules, patterns, issues
   - File locking for safe concurrent access (10+ developers)
   - Analysis history tracking
   - Location: `$BRODIR/etc/genero-akr` (configurable)

3. **Production Scripts** (Phase 1-4 Complete)
   - 18 production-ready scripts organized by phase
   - Phase 1: Core (Retrieve, Commit, Search, Validate)
   - Phase 2: Metadata & Conflict (Updates, Merging, Comparison, Statistics)
   - Phase 3: Search & Analysis (Indexing, Patterns, Issues)
   - Phase 4: Automation & Audit (Hooks, Audit Trail, Quality Scoring)
   - Location: `.kiro/scripts/`
   - See `.kiro/scripts/README.md` for complete reference

4. **Comprehensive Documentation**
   - Quick start guide (5 minutes)
   - Comprehensive script guide
   - Workflow integration guide
   - genero-tools documentation
   - Troubleshooting guide

---

## Framework Features

### Workflow Consistency
- ✅ AI-DLC workflow (Inception → Construction → Operation)
- ✅ Hat-based roles (Planner/Builder/Reviewer)
- ✅ Clear integration points for knowledge retrieval and commitment
- ✅ Standardized decision-making process
- ✅ Reduces variability, improves predictability

### Knowledge Management
- ✅ Retrieve existing knowledge before analyzing
- ✅ Commit findings after analysis
- ✅ Search across all knowledge
- ✅ Validate schema compliance
- ✅ Track analysis history
- ✅ Support for 5 knowledge types (functions, files, modules, patterns, issues)

### Multi-Developer Safety
- ✅ File locking for concurrent access
- ✅ Safe for 10+ developers on shared box
- ✅ Prevents data corruption
- ✅ Automatic lock timeout and recovery
- ✅ Error handling and validation

### Configuration & Flexibility
- ✅ Configurable AKR path (single variable change)
- ✅ Environment variable support
- ✅ Logging and debugging
- ✅ Easy to move between environments
- ✅ No external dependencies

### Documentation
- ✅ Quick start guide (5 minutes)
- ✅ Comprehensive script guide (1,000+ lines)
- ✅ Workflow integration guide
- ✅ Troubleshooting guide
- ✅ genero-tools documentation (consolidated)
- ✅ Steering files for agent guidance

---

## Performance & ROI

### Time Savings
- **Avoid redundant analysis:** 2 hours/week × 10 devs × 50 weeks = 1,000 hours/year
- **Faster planning with context:** 1 hour/week × 10 devs × 50 weeks = 500 hours/year
- **Better decisions:** 10% improvement = 150 hours/year
- **Total benefit:** 1,650 hours/year

### Return on Investment
- **Implementation cost:** 45-55 hours (Phase 1+2)
- **Annual maintenance:** ~5 hours/month
- **Total Year 1 cost:** ~100 hours
- **ROI:** 1,650 / 100 = **16.5x return**
- **Payback period:** **3 weeks**

---

## Implementation Roadmap

### Phase 1: ✅ COMPLETE
- Retrieve knowledge
- Commit knowledge
- Search knowledge
- Validate knowledge
- File locking for concurrent access
- **Status:** Production ready

### Phase 2: ✅ COMPLETE
- Conflict resolution for simultaneous writes
- Automatic metadata updates
- Statistics collection
- Knowledge comparison tool
- **Status:** Production ready

### Phase 3: ✅ COMPLETE
- Pattern detection
- Issue flagging
- Recommendation generation
- Full-text search with indexing
- **Status:** Production ready

### Phase 4: ✅ COMPLETE
- Workflow hooks for automation
- Automatic retrieval/commit
- Audit trail
- Quality scoring
- **Status:** Production ready

---

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

### Step 2: Run Installation Script

```bash
bash install.sh
```

This script will:
- Update the repository from GitHub
- Verify all framework files
- Back up any existing files
- Copy framework to your `~/.kiro` directory
- Verify installation

### Step 3: Initialize AKR (Admin Only)

```bash
bash ~/.kiro/scripts/setup_akr.sh
```

This creates the AKR directory structure at `$BRODIR/etc/genero-akr` (or `/opt/genero/etc/genero-akr`).

### Step 4: Verify Setup

```bash
bash ~/.kiro/scripts/validate_knowledge.sh
```

Expected output:
```
[SUCCESS] All knowledge documents are valid!
```

### Step 5: Read Quick Start

```bash
cat ~/.kiro/AKR_QUICK_START.md
```

---

## Manual Installation (Alternative)

## Manual Installation (Alternative)

### Step 1: Determine Installation Location

The framework can be installed anywhere. By default, it uses:
- **AKR Path:** `$BRODIR/etc/genero-akr` (or `/opt/genero/etc/genero-akr`)
- **Scripts:** `~/.kiro/scripts/` directory in your home

### Step 2: Clone Repository

```bash
git clone https://github.com/hdean-ssp/genero-context.git
cd genero-context
```

### Step 3: Copy Files to ~/.kiro

```bash
# Create directories
mkdir -p ~/.kiro/scripts
mkdir -p ~/.kiro/steering

# Copy scripts
cp .kiro/scripts/*.sh ~/.kiro/scripts/
chmod +x ~/.kiro/scripts/*.sh

# Copy documentation
cp .kiro/AKR_QUICK_START.md ~/.kiro/
cp .kiro/AKR_SCRIPTS_README.md ~/.kiro/
cp .kiro/scripts/README.md ~/.kiro/scripts/

# Copy steering files
cp .kiro/steering/*.md ~/.kiro/steering/
```

### Step 4: Configure AKR Path (Optional)

If you want to use a different path:

1. Edit `~/.kiro/scripts/akr-config.sh`:
   ```bash
   # Change this line:
   export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"
   
   # To your desired path:
   export GENERO_AKR_BASE_PATH="/shared/genero-akr"
   ```

2. Save the file

### Step 5: Initialize AKR

Run as admin/root:

```bash
bash ~/.kiro/scripts/setup_akr.sh
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

### Step 6: Verify Installation

```bash
bash ~/.kiro/scripts/validate_knowledge.sh
```

### Step 7: Test Scripts

```bash
# Test retrieval (will fail - no knowledge yet, this is normal)
bash ~/.kiro/scripts/retrieve_knowledge.sh --type function --name "test"

# Test search
bash ~/.kiro/scripts/search_knowledge.sh --query "test"

# Test validation
bash ~/.kiro/scripts/validate_knowledge.sh
```

---

## Configuration

### AKR Path Configuration

All paths are configured in `~/.kiro/scripts/akr-config.sh`:

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
bash ~/.kiro/scripts/commit_knowledge.sh --type function --name "my_func" --findings findings.json --action create
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
bash .kiro/scripts/setup_akr.sh
```

### retrieve_knowledge.sh
Get existing knowledge about an artifact.
```bash
bash .kiro/scripts/retrieve_knowledge.sh --type function --name "process_order"
```

### commit_knowledge.sh
Save knowledge about an artifact.
```bash
bash .kiro/scripts/commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action append
```

### search_knowledge.sh
Search for knowledge in the repository.
```bash
bash .kiro/scripts/search_knowledge.sh --query "type resolution"
```

### validate_knowledge.sh
Check schema compliance and consistency.
```bash
bash .kiro/scripts/validate_knowledge.sh
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
bash ~/.kiro/scripts/setup_akr.sh
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

bash ~/.kiro/scripts/commit_knowledge.sh \
  --type function \
  --name "test_function" \
  --findings /tmp/findings.json \
  --action create
```

### "Failed to acquire lock"
Wait 30 seconds and try again (lock will be released):
```bash
sleep 30
bash ~/.kiro/scripts/commit_knowledge.sh ...
```

### Installation script issues

**"Git not found"**
```bash
# Install git first
sudo apt-get install git  # Ubuntu/Debian
brew install git          # macOS
```

**"Repository has uncommitted changes"**
```bash
# Either commit changes or use --force flag
bash install.sh --force
```

---

## Next Steps

1. **Read Quick Start:** `~/.kiro/AKR_QUICK_START.md`
2. **Understand Workflow:** `~/.kiro/steering/genero-akr-workflow.md`
3. **Train Your Team:** Share `~/.kiro/AKR_SCRIPTS_README.md`
4. **Start Using:** Retrieve and commit knowledge
5. **Monitor Adoption:** Track usage and gather feedback

---

## Support

- **Quick Start:** `~/.kiro/AKR_QUICK_START.md`
- **Full Guide:** `~/.kiro/AKR_SCRIPTS_README.md`
- **Scripts Overview:** `~/.kiro/scripts/README.md`
- **Workflow:** `~/.kiro/steering/genero-akr-workflow.md`
- **Validation:** `bash ~/.kiro/scripts/validate_knowledge.sh`
- **Logs:** `$GENERO_AKR_BASE_PATH/.logs/akr.log`

---

## What's Included

### Essential Files (User-Facing)

**Configuration & Scripts** (`.kiro/scripts/`)
- `akr-config.sh` - Centralized configuration (change AKR path here)
- `setup_akr.sh` - Initialize AKR directory structure
- `retrieve_knowledge.sh` - Retrieve knowledge by type/name
- `commit_knowledge.sh` - Commit knowledge with file locking
- `search_knowledge.sh` - Search knowledge by query
- `validate_knowledge.sh` - Validate schema compliance
- `update_metadata.sh` - Auto-update metadata
- `merge_knowledge.sh` - Conflict resolution
- `compare_knowledge.sh` - Knowledge comparison
- `get_statistics.sh` - Adoption metrics
- `build_index.sh` - Build search index
- `search_indexed.sh` - Fast full-text search
- `detect_patterns.sh` - Pattern detection
- `flag_issues.sh` - Issue flagging
- `auto_retrieve.sh` - Auto retrieval hook
- `auto_commit.sh` - Auto commit hook
- `audit_trail.sh` - Audit trail
- `quality_score.sh` - Quality scoring
- `README.md` - Scripts directory overview

**Documentation** (`.kiro/`)
- `AKR_QUICK_START.md` - 10-step quick start guide (5 minutes)
- `AKR_SCRIPTS_README.md` - Comprehensive script guide (1,000+ lines)

**Workflow Guidance** (`.kiro/steering/`)
- `genero-akr-workflow.md` - How agents use AKR (Planner/Builder/Reviewer integration)
- `genero-context-workflow.md` - AI-DLC workflow (Inception/Construction/Operation phases)
- `genero-context-operations.md` - Operations guide (error handling, fallback strategies)
- `genero-context-queries.md` - Query reference (14 queries with examples)

**genero-tools Documentation** (`genero-tools-docs/`)
- `GENERO_TOOLS_REFERENCE.md` - Query reference and usage patterns
- `GENERO_TOOLS_SETUP.md` - Setup and operations guide
- `CONSOLIDATION_SUMMARY.md` - Documentation consolidation summary
- Plus 8 additional detailed reference files

**Root Documentation**
- `README.md` - Project overview and quick start
- `INSTALLATION.md` - This file
- `LICENSE` - License information

### Archived Files (Reference Only)

**Analysis & Design** (`.kiro/archive/`)
- `CRITICAL_ANALYSIS.md` - Technical analysis of framework value (10 critical questions)
- `FRAMEWORK_VALUE_PROPOSITION.md` - Executive summary and ROI analysis
- `genero-framework-assessment.md` - Multi-developer readiness assessment
- `genero-agent-knowledge-repository.md` - AKR concept and architecture

---

## Directory Structure

```
genero-context/
├── README.md                           # Project overview
├── INSTALLATION.md                     # This file
├── LICENSE                             # License
│
├── .kiro/
│   ├── akr-config.sh                  # Configuration (change AKR path here)
│   ├── setup_akr.sh                   # Setup script
│   ├── retrieve_knowledge.sh           # Retrieval script
│   ├── commit_knowledge.sh             # Commit script
│   ├── search_knowledge.sh             # Search script
│   ├── validate_knowledge.sh           # Validation script
│   │
│   ├── AKR_QUICK_START.md             # Quick start (5 min)
│   ├── AKR_SCRIPTS_README.md          # Comprehensive guide
│   │
│   ├── steering/                       # Workflow guidance
│   │   ├── genero-akr-workflow.md     # AKR workflow
│   │   ├── genero-context-workflow.md # AI-DLC workflow
│   │   ├── genero-context-operations.md # Operations
│   │   └── genero-context-queries.md  # Query reference
│   │
│   └── archive/                        # Reference documents
│       ├── CRITICAL_ANALYSIS.md
│       ├── FRAMEWORK_VALUE_PROPOSITION.md
│       ├── genero-framework-assessment.md
│       └── genero-agent-knowledge-repository.md
│
├── genero-tools-docs/                  # genero-tools documentation
│   ├── GENERO_TOOLS_REFERENCE.md
│   ├── GENERO_TOOLS_SETUP.md
│   ├── CONSOLIDATION_SUMMARY.md
│   ├── FEATURES.md
│   ├── ARCHITECTURE.md
│   ├── QUERYING.md
│   ├── TYPE_RESOLUTION_GUIDE.md
│   ├── DEVELOPER_GUIDE.md
│   ├── SECURITY.md
│   ├── COMMAND_LINE_EXECUTION_GUIDE.md
│   ├── COMMAND_LINE_TESTING_GUIDE.md
│   └── AGENT_INTEGRATION_GUIDE.md
│
└── AKR Runtime Directory (created by setup_akr.sh)
    $BRODIR/etc/genero-akr/
    ├── files/                          # File-level knowledge
    ├── functions/                      # Function-level knowledge
    ├── modules/                        # Module-level knowledge
    ├── patterns/                       # Discovered patterns
    ├── issues/                         # Known issues & risks
    ├── metadata/                       # System metadata
    ├── .locks/                         # Lock files (internal)
    ├── .logs/                          # Log files (internal)
    ├── README.md                       # Repository overview
    ├── SCHEMA.md                       # Knowledge document schema
    └── INDEX.md                        # Master index
```

---

## Version Information

- **Framework Version:** 1.0.0
- **Phase:** 4 (Complete)
- **Status:** Production Ready
- **Last Updated:** March 30, 2026
- **Total Scripts:** 18
- **Total Lines of Code:** 3,000+

