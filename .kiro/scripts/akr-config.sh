#!/bin/bash
# AKR Configuration
# This file centralizes all AKR path configuration
# Change GENERO_AKR_BASE_PATH to move the entire AKR to a different location

# ============================================================================
# CONFIGURATION: Change this path to move AKR to a different location
# ============================================================================
export GENERO_AKR_BASE_PATH="${BRODIR:-/opt/genero}/etc/genero-akr"

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
# Validation
# ============================================================================
if [ ! -d "$GENERO_AKR_BASE_PATH" ]; then
  echo "ERROR: AKR base path does not exist: $GENERO_AKR_BASE_PATH"
  echo "Please run: bash setup_akr.sh"
  exit 1
fi
