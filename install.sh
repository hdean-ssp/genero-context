#!/bin/bash

################################################################################
# install.sh - Install Genero Framework to user's Kiro directory
#
# Purpose: Copy framework files to user's .kiro directory with backup/archive
#          of previous versions for safety
#
# Usage: bash install.sh [--force]
#
# Parameters:
#   --force     Skip confirmation prompts
#
# Exit Codes:
#   0 - Success
#   1 - Error
#
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FORCE=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIRO_DIR="${HOME}/.kiro"
BACKUP_DIR="${KIRO_DIR}/.backup/$(date +%Y%m%d_%H%M%S)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force) FORCE=1; shift ;;
        *) shift ;;
    esac
done

# Helper functions
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

confirm() {
    if [[ $FORCE -eq 1 ]]; then
        return 0
    fi
    
    local prompt="$1"
    local response
    read -p "$prompt (y/n) " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Main installation
main() {
    print_header "Genero Framework Installation"
    echo ""
    
    # Step 1: Check if repo is up to date
    print_header "Step 1: Checking Repository"
    
    if ! command -v git &> /dev/null; then
        print_error "Git not found. Please install git first."
        exit 1
    fi
    
    cd "$SCRIPT_DIR"
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "Repository has uncommitted changes"
        if ! confirm "Continue anyway?"; then
            print_error "Installation cancelled"
            exit 1
        fi
    fi
    
    # Pull latest changes
    print_header "Step 2: Updating Repository"
    
    if git remote get-url origin &> /dev/null; then
        echo "Pulling latest changes from remote..."
        if git pull origin main 2>/dev/null; then
            print_success "Repository updated"
        else
            print_warning "Could not pull from remote (offline?)"
        fi
    else
        print_warning "No remote configured"
    fi
    
    # Step 3: Verify framework files
    print_header "Step 3: Verifying Framework Files"
    
    local required_files=(
        ".kiro/scripts/setup_akr.sh"
        ".kiro/scripts/retrieve_knowledge.sh"
        ".kiro/scripts/commit_knowledge.sh"
        ".kiro/scripts/search_knowledge.sh"
        ".kiro/scripts/validate_knowledge.sh"
        ".kiro/scripts/akr-config.sh"
        ".kiro/AKR_QUICK_START.md"
        ".kiro/AKR_SCRIPTS_README.md"
        ".kiro/steering/genero-akr-workflow.md"
        ".kiro/steering/genero-context-workflow.md"
        ".kiro/steering/genero-context-operations.md"
        ".kiro/steering/genero-context-queries.md"
    )
    
    local missing_files=0
    for file in "${required_files[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            print_error "Missing: $file"
            ((missing_files++))
        fi
    done
    
    if [[ $missing_files -gt 0 ]]; then
        print_error "Framework files missing. Installation cannot proceed."
        exit 1
    fi
    
    print_success "All framework files present"
    
    # Step 4: Create Kiro directory if needed
    print_header "Step 4: Preparing Installation"
    
    if [[ ! -d "$KIRO_DIR" ]]; then
        echo "Creating $KIRO_DIR..."
        mkdir -p "$KIRO_DIR"
        print_success "Created $KIRO_DIR"
    fi
    
    # Step 5: Backup existing files
    print_header "Step 5: Backing Up Existing Files"
    
    local files_to_backup=(
        "AKR_QUICK_START.md"
        "AKR_SCRIPTS_README.md"
        "steering/genero-akr-workflow.md"
        "steering/genero-context-workflow.md"
        "steering/genero-context-operations.md"
        "steering/genero-context-queries.md"
    )
    
    local backed_up=0
    for file in "${files_to_backup[@]}"; do
        if [[ -f "$KIRO_DIR/$file" ]]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            cp "$KIRO_DIR/$file" "$BACKUP_DIR/$file"
            ((backed_up++))
        fi
    done
    
    if [[ $backed_up -gt 0 ]]; then
        print_success "Backed up $backed_up existing files to $BACKUP_DIR"
    else
        print_warning "No existing files to back up"
    fi
    
    # Step 6: Copy framework files
    print_header "Step 6: Installing Framework Files"
    
    # Create scripts directory
    mkdir -p "$KIRO_DIR/scripts"
    mkdir -p "$KIRO_DIR/steering"
    
    # Copy scripts
    echo "Copying scripts..."
    cp "$SCRIPT_DIR/.kiro/scripts"/*.sh "$KIRO_DIR/scripts/"
    chmod +x "$KIRO_DIR/scripts"/*.sh
    print_success "Scripts installed"
    
    # Copy documentation
    echo "Copying documentation..."
    cp "$SCRIPT_DIR/.kiro/AKR_QUICK_START.md" "$KIRO_DIR/"
    cp "$SCRIPT_DIR/.kiro/AKR_SCRIPTS_README.md" "$KIRO_DIR/"
    cp "$SCRIPT_DIR/.kiro/scripts/README.md" "$KIRO_DIR/scripts/"
    print_success "Documentation installed"
    
    # Copy steering files
    echo "Copying steering files..."
    cp "$SCRIPT_DIR/.kiro/steering"/*.md "$KIRO_DIR/steering/"
    print_success "Steering files installed"
    
    # Step 7: Verify installation
    print_header "Step 7: Verifying Installation"
    
    local installed_files=0
    for file in "${required_files[@]}"; do
        local target_file="${file#.kiro/}"
        if [[ -f "$KIRO_DIR/$target_file" ]]; then
            ((installed_files++))
        else
            print_warning "Not found: $target_file"
        fi
    done
    
    if [[ $installed_files -eq ${#required_files[@]} ]]; then
        print_success "All files installed successfully"
    else
        print_warning "Some files may not have been installed correctly"
    fi
    
    # Step 8: Display next steps
    print_header "Installation Complete!"
    echo ""
    echo "Framework installed to: $KIRO_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Read the quick start guide:"
    echo "   cat $KIRO_DIR/AKR_QUICK_START.md"
    echo ""
    echo "2. Initialize AKR (admin only):"
    echo "   bash $KIRO_DIR/scripts/setup_akr.sh"
    echo ""
    echo "3. Verify setup:"
    echo "   bash $KIRO_DIR/scripts/validate_knowledge.sh"
    echo ""
    echo "4. Start using AKR:"
    echo "   bash $KIRO_DIR/scripts/retrieve_knowledge.sh --type function --name \"my_function\""
    echo ""
    
    if [[ $backed_up -gt 0 ]]; then
        echo "Backup location: $BACKUP_DIR"
        echo ""
    fi
    
    print_success "Installation finished!"
}

# Run main
main
exit 0
