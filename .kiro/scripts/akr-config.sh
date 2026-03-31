#!/bin/bash
# AKR Configuration
# This file centralizes all AKR and genero-tools path configuration
# Change GENERO_AKR_BASE_PATH to move the entire AKR to a different location
# Change GENERO_TOOLS_PATH to use a different genero-tools installation

# ============================================================================
# CONFIGURATION: genero-tools path
# ============================================================================
# Default: Assumes genero-tools is installed at $BRODIR/etc/genero-tools
# Change this if genero-tools is in a different location
# Allow override via environment variable (for testing)
if [ -z "$GENERO_TOOLS_PATH" ]; then
  # Check if genero-tools exists in development directory
  if [ -d "/home/hdean/development/genero-tools" ]; then
    export GENERO_TOOLS_PATH="/home/hdean/development/genero-tools"
  else
    export GENERO_TOOLS_PATH="${BRODIR:-/opt/genero}/etc/genero-tools"
  fi
fi

# ============================================================================
# CONFIGURATION: AKR path
# ============================================================================
# Default: $BRODIR/etc/genero-akr
# Change this path to move AKR to a different location
# Allow override via environment variable (for testing)
if [ -z "$GENERO_AKR_BASE_PATH" ]; then
  # Check if genero-akr exists in development directory
  if [ -d "/home/hdean/development/genero-akr" ]; then
    export GENERO_AKR_BASE_PATH="/home/hdean/development/genero-akr"
  else
    export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"
  fi
fi

# ============================================================================
# Derived paths (do not modify)
# ============================================================================
export GENERO_AKR_FILES="${GENERO_AKR_BASE_PATH}/files"
export GENERO_AKR_FUNCTIONS="${GENERO_AKR_BASE_PATH}/functions"
export GENERO_AKR_MODULES="${GENERO_AKR_BASE_PATH}/modules"
export GENERO_AKR_PATTERNS="${GENERO_AKR_BASE_PATH}/patterns"
export GENERO_AKR_ISSUES="${GENERO_AKR_BASE_PATH}/issues"
export GENERO_AKR_METADATA="${GENERO_AKR_BASE_PATH}/metadata"
export GENERO_AKR_LOCKS="${GENERO_AKR_BASE_PATH}/.locks"
export GENERO_AKR_LOGS="${GENERO_AKR_BASE_PATH}/.logs"

# ============================================================================
# Logging configuration
# ============================================================================
export GENERO_AKR_LOG_LEVEL="${GENERO_AKR_LOG_LEVEL:-info}"  # debug, info, warning, error
export GENERO_AKR_LOG_FILE="${GENERO_AKR_LOGS}/akr.log"

# ============================================================================
# Lock configuration
# ============================================================================
export GENERO_AKR_LOCK_TIMEOUT=30  # seconds
export GENERO_AKR_LOCK_RETRY_INTERVAL=1  # seconds

# ============================================================================
# Dependency Verification Functions
# ============================================================================

# Check if a command is available
check_command() {
  local cmd=$1
  if ! command -v "$cmd" &> /dev/null; then
    return 1
  fi
  return 0
}

# Verify all required dependencies
verify_dependencies() {
  local missing_deps=()
  local optional_deps=()
  
  # Required commands (all standard Unix utilities)
  local required_commands=(
    "bash"
    "grep"
    "sed"
    "awk"
    "find"
    "mkdir"
    "chmod"
    "cp"
    "mv"
    "rm"
    "cat"
    "echo"
    "date"
    "sort"
    "uniq"
    "wc"
    "head"
    "tail"
  )
  
  # Optional commands
  local optional_commands=(
    "jq"
  )
  
  # Check required commands
  for cmd in "${required_commands[@]}"; do
    if ! check_command "$cmd"; then
      missing_deps+=("$cmd")
    fi
  done
  
  # Check optional commands
  for cmd in "${optional_commands[@]}"; do
    if ! check_command "$cmd"; then
      optional_deps+=("$cmd")
    fi
  done
  
  # Report results
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "ERROR: Missing required dependencies:"
    for dep in "${missing_deps[@]}"; do
      echo "  - $dep"
    done
    return 1
  fi
  
  if [ ${#optional_deps[@]} -gt 0 ]; then
    echo "WARNING: Missing optional dependencies (framework will work with limited features):"
    for dep in "${optional_deps[@]}"; do
      echo "  - $dep"
    done
  fi
  
  return 0
}

# Get dependency status summary
get_dependency_status() {
  local status="OK"
  
  # Check required commands
  local required_commands=(
    "bash" "grep" "sed" "awk" "find" "mkdir" "chmod" "cp" "mv" "rm" "cat" "echo" "date" "sort" "uniq" "wc" "head" "tail"
  )
  
  for cmd in "${required_commands[@]}"; do
    if ! check_command "$cmd"; then
      status="MISSING_REQUIRED"
      break
    fi
  done
  
  # Check optional commands
  if [ "$status" = "OK" ]; then
    local optional_commands=("jq")
    for cmd in "${optional_commands[@]}"; do
      if ! check_command "$cmd"; then
        status="MISSING_OPTIONAL"
        break
      fi
    done
  fi
  
  echo "$status"
}

# ============================================================================
# Validation
# ============================================================================
if [ ! -d "$GENERO_AKR_BASE_PATH" ]; then
  echo "ERROR: AKR base path does not exist: $GENERO_AKR_BASE_PATH"
  echo "Please run: bash setup_akr.sh"
  exit 1
fi

# Warn if genero-tools is not found (but don't fail - framework can work without it)
if [ ! -d "$GENERO_TOOLS_PATH" ]; then
  echo "WARNING: genero-tools not found at: $GENERO_TOOLS_PATH"
  echo "Some features may be limited. To install genero-tools:"
  echo "  1. Download from your Genero distribution"
  echo "  2. Extract to: $GENERO_TOOLS_PATH"
  echo "  3. Or set GENERO_TOOLS_PATH to the correct location"
fi

