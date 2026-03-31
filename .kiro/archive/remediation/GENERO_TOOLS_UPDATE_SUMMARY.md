# genero-tools References Update Summary

**Date**: 2026-03-30  
**Status**: ✅ COMPLETE  
**Effort**: 2 hours  
**Impact**: Updated all documentation and scripts to properly reference genero-tools

---

## What Was Done

Updated all references to genero-tools throughout the Genero Framework to assume it is pre-installed at `$BRODIR/etc/genero-tools`, with comprehensive setup guidance and installation script enhancements.

---

## Files Updated

### 1. DEPENDENCIES.md
**Changes**:
- Updated genero-tools section to reflect pre-installed assumption
- Added default location: `$BRODIR/etc/genero-tools`
- Added manual installation instructions
- Added configuration options
- Added troubleshooting for genero-tools issues
- Added BRODIR troubleshooting

**Key Additions**:
```markdown
### genero-tools
**Status**: External tool (assumed to be pre-installed)  
**Purpose**: Code analysis and querying for Genero/4GL codebases  
**Required**: Yes (for full framework functionality)  
**Default Location**: `$BRODIR/etc/genero-tools`  
**Configurable**: Yes (via environment variable)
```

---

### 2. INSTALLATION.md
**Changes**:
- Added Genero installation verification step
- Added genero-tools verification step
- Updated requirements to include Genero/4GL
- Added reference to GENERO_TOOLS_SETUP.md
- Updated quick start with genero-tools check

**Key Additions**:
```markdown
## Requirements
- Genero/4GL installed (with genero-tools at `$BRODIR/etc/genero-tools`)
```

---

### 3. README.md
**Changes**:
- Updated quick start to include BRODIR setup
- Added genero-tools verification step
- Updated environment setup instructions

**Key Additions**:
```bash
# 1. Set Genero environment (if not already set)
export BRODIR=/opt/genero

# 2. Verify genero-tools is installed
ls -la $BRODIR/etc/genero-tools
```

---

### 4. install.sh (Enhanced)
**Major Changes**:
- Added `check_genero_tools()` function
- Detects BRODIR automatically
- Searches common Genero installation locations
- Verifies genero-tools installation
- Provides installation instructions if missing
- Allows continuation without genero-tools (with warning)
- Added `--skip-genero-check` flag for automation
- Updated final output with environment setup

**New Features**:
```bash
# Automatic BRODIR detection
# Checks /opt/genero, /usr/local/genero, etc.

# genero-tools verification
# Checks for query.sh and tries to get version

# Installation guidance
# Provides step-by-step instructions if missing

# Graceful degradation
# Allows installation to continue without genero-tools
```

**New Parameters**:
- `--force` - Skip confirmation prompts
- `--skip-genero-check` - Skip genero-tools verification

---

### 5. .kiro/scripts/akr-config.sh
**Changes**:
- Added GENERO_TOOLS_PATH configuration
- Added genero-tools validation
- Added helpful warning if genero-tools not found
- Documented configuration options

**Key Additions**:
```bash
# genero-tools path configuration
export GENERO_TOOLS_PATH="${BRODIR:-/opt/genero}/etc/genero-tools"

# Validation with helpful warning
if [ ! -d "$GENERO_TOOLS_PATH" ]; then
  echo "WARNING: genero-tools not found at: $GENERO_TOOLS_PATH"
  echo "Some features may be limited..."
fi
```

---

### 6. New File: GENERO_TOOLS_SETUP.md (400+ lines)
**Content**:
- Complete genero-tools setup guide
- Prerequisites and requirements
- Installation options (3 methods)
- Configuration options (3 methods)
- Verification procedures
- Comprehensive troubleshooting
- Integration with framework
- Performance considerations
- Security considerations
- Maintenance tasks
- Support resources

**Key Sections**:
- Overview
- Prerequisites
- Installation (3 options)
- Configuration (3 options)
- Verification
- Troubleshooting (6 common issues)
- Integration with Framework
- Performance Considerations
- Security Considerations
- Maintenance
- Support & Resources

---

## Key Changes Summary

### Before
- genero-tools was optional and external
- No clear installation guidance
- No verification in install script
- Limited troubleshooting help

### After
- genero-tools is assumed to be pre-installed
- Clear installation guidance provided
- Installation script verifies genero-tools
- Comprehensive troubleshooting guide
- Graceful degradation if not found

---

## Installation Script Enhancements

### New Function: check_genero_tools()
```bash
check_genero_tools() {
    # 1. Check if BRODIR is set
    # 2. Auto-detect Genero installation if needed
    # 3. Verify genero-tools exists
    # 4. Check query.sh exists
    # 5. Try to get version
    # 6. Provide installation instructions if missing
    # 7. Allow continuation without genero-tools
}
```

### New Features
- ✅ Automatic BRODIR detection
- ✅ Searches common installation locations
- ✅ Verifies genero-tools installation
- ✅ Provides helpful error messages
- ✅ Allows graceful degradation
- ✅ Can be skipped with `--skip-genero-check`

### Usage Examples
```bash
# Normal installation (with genero-tools check)
bash install.sh

# Force mode (skip prompts)
bash install.sh --force

# Skip genero-tools check (for automation)
bash install.sh --skip-genero-check

# Force mode + skip check
bash install.sh --force --skip-genero-check
```

---

## Configuration Options

### Default Configuration
```bash
# Automatically uses:
export BRODIR=/opt/genero  # or detected location
export GENERO_TOOLS_PATH=$BRODIR/etc/genero-tools
```

### Custom Configuration (3 Methods)

**Method 1: Edit akr-config.sh**
```bash
export GENERO_TOOLS_PATH="/custom/path/to/genero-tools"
```

**Method 2: Set Environment Variable**
```bash
export GENERO_TOOLS_PATH="/custom/path/to/genero-tools"
bash ~/.kiro/scripts/retrieve_knowledge.sh ...
```

**Method 3: Update BRODIR**
```bash
export BRODIR=/custom/path/to/genero
bash ~/.kiro/scripts/retrieve_knowledge.sh ...
```

---

## Troubleshooting Improvements

### New Troubleshooting Sections
1. "genero-tools not found" - 5 solutions
2. "query.sh: command not found" - 4 solutions
3. "Permission denied" - 4 solutions
4. "BRODIR not set" - 4 solutions
5. "Database not found" - 4 solutions

### Troubleshooting Coverage
- ✅ Installation issues
- ✅ Configuration issues
- ✅ Permission issues
- ✅ Environment issues
- ✅ Database issues

---

## Documentation Structure

### New Documentation Hierarchy
```
README.md
├── Quick Start (with BRODIR setup)
├── Installation (references GENERO_TOOLS_SETUP.md)
└── Configuration

INSTALLATION.md
├── Requirements (includes Genero/4GL)
├── Quick Start (with genero-tools check)
└── References GENERO_TOOLS_SETUP.md

DEPENDENCIES.md
├── System Requirements (includes Genero)
├── genero-tools section (detailed)
└── Troubleshooting (includes genero-tools)

GENERO_TOOLS_SETUP.md (NEW)
├── Overview
├── Prerequisites
├── Installation (3 methods)
├── Configuration (3 methods)
├── Verification
├── Troubleshooting (6 issues)
├── Integration
├── Performance
├── Security
└── Maintenance
```

---

## Impact Assessment

### Documentation Quality
- ✅ More comprehensive
- ✅ Better organized
- ✅ More helpful
- ✅ Better troubleshooting

### User Experience
- ✅ Clearer setup process
- ✅ Better error messages
- ✅ More guidance
- ✅ Graceful degradation

### Framework Functionality
- ✅ Better genero-tools integration
- ✅ Automatic detection
- ✅ Flexible configuration
- ✅ Works without genero-tools

---

## Files Created/Updated

### Updated Files (5)
- ✅ DEPENDENCIES.md - Enhanced genero-tools section
- ✅ INSTALLATION.md - Added genero-tools verification
- ✅ README.md - Updated quick start
- ✅ install.sh - Enhanced with genero-tools check
- ✅ .kiro/scripts/akr-config.sh - Added genero-tools config

### New Files (1)
- ✅ GENERO_TOOLS_SETUP.md - Comprehensive setup guide (400+ lines)

### Total New Content
- **Lines Created**: 400+
- **Files Created**: 1
- **Files Updated**: 5

---

## Testing Recommendations

### Manual Testing
```bash
# Test 1: Normal installation
bash install.sh

# Test 2: Force mode
bash install.sh --force

# Test 3: Skip genero-tools check
bash install.sh --skip-genero-check

# Test 4: Custom BRODIR
export BRODIR=/custom/path
bash install.sh

# Test 5: Custom genero-tools path
export GENERO_TOOLS_PATH=/custom/path/genero-tools
bash ~/.kiro/scripts/validate_knowledge.sh
```

### Verification Steps
```bash
# Verify BRODIR is set
echo $BRODIR

# Verify genero-tools is found
ls -la $BRODIR/etc/genero-tools

# Verify query.sh works
$BRODIR/etc/genero-tools/query.sh --version

# Verify framework works
bash ~/.kiro/scripts/validate_knowledge.sh
```

---

## Next Steps

### Immediate
- ✅ Update all genero-tools references
- ✅ Enhance installation script
- ✅ Create setup guide
- ✅ Update documentation

### Short Term
- → Task 5: Verify Script Dependencies (2h)
- → Task 10: Create Test Suite (8h)

### Medium Term
- → Task 11: Integration Tests (6h)
- → Task 12: Workflow Execution Guide (4h)

---

## Summary

Successfully updated all references to genero-tools throughout the Genero Framework documentation and scripts. The framework now:

- ✅ Assumes genero-tools is pre-installed at `$BRODIR/etc/genero-tools`
- ✅ Provides comprehensive setup guidance
- ✅ Automatically detects Genero installation
- ✅ Verifies genero-tools during installation
- ✅ Allows graceful degradation if not found
- ✅ Supports custom configuration
- ✅ Includes comprehensive troubleshooting

---

**Status**: ✅ COMPLETE  
**Files Updated**: 5  
**Files Created**: 1  
**Total Content**: 400+ lines  
**Ready for Next Task**: ✅ Yes

---

*Updated by AI Agent on 2026-03-30*
