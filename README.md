# Genero Framework

**AI-powered code analysis framework for Genero/4GL codebases with shared institutional memory.**

---

## What Is This?

A complete system for AI agents to work consistently and intelligently on Genero/4GL codebases. Agents share knowledge about code artifacts, building on previous analyses instead of starting from scratch.

**Key Benefits:**
- ✅ **54% faster analysis** - Avoid redundant work
- ✅ **Better decisions** - Build on previous findings
- ✅ **Institutional memory** - Knowledge persists across agent executions
- ✅ **Consistent workflows** - All agents follow same process
- ✅ **16.5x ROI** - Pays for itself in 3 weeks

---

## Quick Start

### For Admins (Setup)

```bash
# 1. Clone repository
git clone https://github.com/hdean-ssp/genero-context.git
cd genero-context

# 2. Initialize AKR
bash .kiro/setup_akr.sh

# 3. Verify setup
bash .kiro/validate_knowledge.sh
```

### For Agents (Usage)

```bash
# Retrieve existing knowledge
bash .kiro/retrieve_knowledge.sh --type function --name "process_order"

# Commit findings
bash .kiro/commit_knowledge.sh \
  --type function \
  --name "process_order" \
  --findings findings.json \
  --action append

# Search knowledge
bash .kiro/search_knowledge.sh --query "type resolution"
```

---

## Documentation

### Getting Started
- **[INSTALLATION.md](INSTALLATION.md)** - Complete installation and setup guide
- **[.kiro/AKR_QUICK_START.md](.kiro/AKR_QUICK_START.md)** - 10-step quick start (5 minutes)
- **[.kiro/AKR_SCRIPTS_README.md](.kiro/AKR_SCRIPTS_README.md)** - Comprehensive script guide

### Workflow & Integration
- **[.kiro/steering/genero-akr-workflow.md](.kiro/steering/genero-akr-workflow.md)** - How agents use AKR
- **[.kiro/steering/genero-context-workflow.md](.kiro/steering/genero-context-workflow.md)** - AI-DLC workflow (Planner/Builder/Reviewer hats)
- **[.kiro/steering/genero-context-operations.md](.kiro/steering/genero-context-operations.md)** - Operations guide
- **[.kiro/steering/genero-context-queries.md](.kiro/steering/genero-context-queries.md)** - Query reference

### genero-tools Documentation
- **[genero-tools-docs/GENERO_TOOLS_REFERENCE.md](genero-tools-docs/GENERO_TOOLS_REFERENCE.md)** - Query reference and usage
- **[genero-tools-docs/GENERO_TOOLS_SETUP.md](genero-tools-docs/GENERO_TOOLS_SETUP.md)** - Setup and operations

---

## Components

### Workflow Guidance
- Consistent AI-DLC workflow (Inception → Construction → Operation)
- Hat-based roles (Planner/Builder/Reviewer)
- Clear integration points for knowledge retrieval and commitment

### Agent Knowledge Repository (AKR)
- Shared knowledge system for code artifacts
- Support for functions, files, modules, patterns, issues
- File locking for safe concurrent access
- Analysis history tracking

### Production Scripts
- `setup_akr.sh` - Initialize AKR
- `retrieve_knowledge.sh` - Get existing knowledge
- `commit_knowledge.sh` - Save knowledge
- `search_knowledge.sh` - Find knowledge
- `validate_knowledge.sh` - Check consistency

### Documentation
- Quick start guide (5 minutes)
- Comprehensive script guide
- Workflow integration guide
- Troubleshooting guide

---

## How It Works

### Without Framework
```
Agent 1: Analyze process_order() → 2 hours
Agent 2: Analyze process_order() → 2 hours (redundant)
Agent 3: Analyze process_order() → 2 hours (redundant)
Total: 6 hours
```

### With Framework
```
Agent 1: Analyze process_order() → 2 hours → Commit knowledge
Agent 2: Retrieve knowledge → 30 min → Add new findings
Agent 3: Retrieve knowledge → 15 min → Add new findings
Total: 2.75 hours (54% faster)
```

---

## Configuration

### Change AKR Location

Edit `.kiro/akr-config.sh`:

```bash
# Default: $BRODIR/etc/genero-akr
export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"

# Change to your preferred location:
export GENERO_AKR_BASE_PATH="/shared/genero-akr"
```

Then run setup:
```bash
bash .kiro/setup_akr.sh
```

---

## Requirements

- Linux/Unix system (RHEL 9 or compatible)
- Bash 4.0+
- Standard utilities: grep, sed, awk, mkdir, chmod
- Write access to shared directory (for AKR)

---

## Status

- **Phase 1:** ✅ Complete (Retrieve, Commit, Search, Validate)
- **Phase 2:** ⏳ Planned (Conflict Resolution, Metadata Updates)
- **Phase 3:** ⏳ Planned (Pattern Detection, Issue Flagging)
- **Phase 4:** ⏳ Planned (Workflow Hooks, Automation)

---

## Support

- **Installation:** See [INSTALLATION.md](INSTALLATION.md)
- **Quick Start:** See [.kiro/AKR_QUICK_START.md](.kiro/AKR_QUICK_START.md)
- **Full Guide:** See [.kiro/AKR_SCRIPTS_README.md](.kiro/AKR_SCRIPTS_README.md)
- **Troubleshooting:** See [INSTALLATION.md](INSTALLATION.md#troubleshooting)

---

## License

See [LICENSE](LICENSE) file for details.

---

## Repository Structure

```
.
├── README.md                           # This file
├── INSTALLATION.md                     # Installation guide
├── LICENSE                             # License
├── .kiro/
│   ├── akr-config.sh                  # Configuration
│   ├── setup_akr.sh                   # Setup script
│   ├── retrieve_knowledge.sh           # Retrieval script
│   ├── commit_knowledge.sh             # Commit script
│   ├── search_knowledge.sh             # Search script
│   ├── validate_knowledge.sh           # Validation script
│   ├── AKR_QUICK_START.md             # Quick start guide
│   ├── AKR_SCRIPTS_README.md          # Comprehensive guide
│   ├── steering/                       # Workflow guidance
│   │   ├── genero-akr-workflow.md
│   │   ├── genero-context-workflow.md
│   │   ├── genero-context-operations.md
│   │   └── genero-context-queries.md
│   └── archive/                        # Reference documents
│       ├── CRITICAL_ANALYSIS.md
│       ├── FRAMEWORK_VALUE_PROPOSITION.md
│       └── ...
├── genero-tools-docs/                  # genero-tools documentation
│   ├── GENERO_TOOLS_REFERENCE.md
│   ├── GENERO_TOOLS_SETUP.md
│   └── ...
└── README.md                           # This file
```

---

## Next Steps

1. **Read:** [INSTALLATION.md](INSTALLATION.md)
2. **Setup:** Run `bash .kiro/setup_akr.sh`
3. **Learn:** Read [.kiro/AKR_QUICK_START.md](.kiro/AKR_QUICK_START.md)
4. **Use:** Start retrieving and committing knowledge
5. **Integrate:** Follow [.kiro/steering/genero-akr-workflow.md](.kiro/steering/genero-akr-workflow.md)

