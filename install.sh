#!/bin/bash

################################################################################
# install.sh - Install Genero Framework to user's Kiro directory
#
# Purpose: Copy framework files to user's .kiro directory with backup/archive
#          of previous versions for safety. Also verifies genero-tools is
#          available and provides installation instructions if needed.
#
# Usage: bash install.sh [--force] [--skip-genero-check]
#
# Parameters:
#   --force              Skip confirmation prompts
#   --skip-genero-check  Skip genero-tools verification
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
SKIP_GENERO_CHECK=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIRO_DIR="${HOME}/.kiro"
BACKUP_DIR="${KIRO_DIR}/.backup/$(date +%Y%m%d_%H%M%S)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force) FORCE=1; shift ;;
        --skip-genero-check) SKIP_GENERO_CHECK=1; shift ;;
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

check_genero_tools() {
    print_header "Checking genero-tools Installation"
    
    # Check if BRODIR is set
    if [[ -z "$BRODIR" ]]; then
        print_warning "BRODIR environment variable not set"
        echo "Attempting to find Genero installation..."
        
        # Try common locations
        if [[ -d "/opt/genero" ]]; then
            export BRODIR="/opt/genero"
            print_success "Found Genero at /opt/genero"
        elif [[ -d "/usr/local/genero" ]]; then
            export BRODIR="/usr/local/genero"
            print_success "Found Genero at /usr/local/genero"
        else
            print_error "Could not find Genero installation"
            echo ""
            echo "Please set BRODIR environment variable:"
            echo "  export BRODIR=/path/to/genero"
            echo ""
            return 1
        fi
    fi
    
    # Check if genero-tools exists
    if [[ -d "$BRODIR/etc/genero-tools" ]]; then
        print_success "genero-tools found at $BRODIR/etc/genero-tools"
        
        # Check if query.sh exists
        if [[ -f "$BRODIR/etc/genero-tools/query.sh" ]]; then
            print_success "query.sh found"
            
            # Try to get version
            if "$BRODIR/etc/genero-tools/query.sh" --version &>/dev/null; then
                local version=$("$BRODIR/etc/genero-tools/query.sh" --version 2>/dev/null || echo "unknown")
                print_success "genero-tools version: $version"
            else
                print_warning "Could not determine genero-tools version"
            fi
        else
            print_warning "query.sh not found in genero-tools directory"
        fi
        
        return 0
    else
        print_error "genero-tools not found at $BRODIR/etc/genero-tools"
        echo ""
        echo "genero-tools is required for full framework functionality."
        echo ""
        echo "To install genero-tools:"
        echo "1. Download genero-tools from your Genero distribution"
        echo "2. Extract to the standard location:"
        echo "   sudo mkdir -p $BRODIR/etc/genero-tools"
        echo "   sudo tar -xzf genero-tools-*.tar.gz -C $BRODIR/etc/genero-tools"
        echo ""
        echo "3. Set permissions:"
        echo "   sudo chmod 755 $BRODIR/etc/genero-tools"
        echo "   sudo chmod 755 $BRODIR/etc/genero-tools/*"
        echo ""
        echo "4. Verify installation:"
        echo "   $BRODIR/etc/genero-tools/query.sh --version"
        echo ""
        
        if ! confirm "Continue installation without genero-tools?"; then
            print_error "Installation cancelled"
            return 1
        fi
        
        print_warning "Continuing without genero-tools (limited functionality)"
        return 0
    fi
}

# Main installation
main() {
    print_header "Genero Framework Installation"
    echo ""
    
    # Step 0: Check genero-tools (unless skipped)
    if [[ $SKIP_GENERO_CHECK -eq 0 ]]; then
        if ! check_genero_tools; then
            print_error "genero-tools check failed"
            exit 1
        fi
        echo ""
    fi
    
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
        ".kiro/steering/genero-akr-workflow.md"
        ".kiro/steering/genero-context-workflow.md"
        ".kiro/steering/genero-context-operations.md"
        ".kiro/steering/genero-context-queries.md"
        ".kiro/skills/akr-management-specialist.md"
        ".kiro/skills/akr-management-training.md"
        ".kiro/skills/akr-management-quick-reference.md"
        ".kiro/hooks/AKR_MANAGEMENT_HOOKS.md"
        ".kiro/hooks/akr-management-auto-activate.kiro.hook"
        ".kiro/hooks/akr-management-post-commit-validate.kiro.hook"
        ".kiro/hooks/akr-management-pre-retrieve-dedup.kiro.hook"
    )
    
    local missing_files=0
    for file in "${required_files[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            print_error "Missing: $file"
            missing_files=$((missing_files + 1))
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
        "steering/genero-akr-workflow.md"
        "steering/genero-context-workflow.md"
        "steering/genero-context-operations.md"
        "steering/genero-context-queries.md"
        "skills/akr-management-specialist.md"
        "skills/akr-management-training.md"
        "skills/akr-management-quick-reference.md"
        "hooks/AKR_MANAGEMENT_HOOKS.md"
        "hooks/akr-management-auto-activate.kiro.hook"
        "hooks/akr-management-post-commit-validate.kiro.hook"
        "hooks/akr-management-pre-retrieve-dedup.kiro.hook"
    )
    
    local backed_up=0
    for file in "${files_to_backup[@]}"; do
        if [[ -f "$KIRO_DIR/$file" ]]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            cp "$KIRO_DIR/$file" "$BACKUP_DIR/$file"
            backed_up=$((backed_up + 1))
        fi
    done
    
    if [[ $backed_up -gt 0 ]]; then
        print_success "Backed up $backed_up existing files to $BACKUP_DIR"
    else
        print_warning "No existing files to back up"
    fi
    
    # Step 6: Copy framework files
    print_header "Step 6: Installing Framework Files"
    
    # Create directories
    mkdir -p "$KIRO_DIR/scripts"
    mkdir -p "$KIRO_DIR/steering"
    mkdir -p "$KIRO_DIR/skills"
    mkdir -p "$KIRO_DIR/hooks"
    
    # Copy scripts
    echo "Copying scripts..."
    cp "$SCRIPT_DIR/.kiro/scripts"/*.sh "$KIRO_DIR/scripts/"
    chmod +x "$KIRO_DIR/scripts"/*.sh
    print_success "Scripts installed"
    
    # Copy scripts README
    echo "Copying documentation..."
    [[ -f "$SCRIPT_DIR/.kiro/scripts/README.md" ]] && cp "$SCRIPT_DIR/.kiro/scripts/README.md" "$KIRO_DIR/scripts/"
    print_success "Documentation installed"
    
    # Copy steering files
    echo "Copying steering files..."
    cp "$SCRIPT_DIR/.kiro/steering"/*.md "$KIRO_DIR/steering/"
    print_success "Steering files installed"
    
    # Copy skills
    echo "Copying Kiro skills..."
    if [[ -d "$SCRIPT_DIR/.kiro/skills" ]]; then
        cp "$SCRIPT_DIR/.kiro/skills"/*.md "$KIRO_DIR/skills/"
        cp "$SCRIPT_DIR/.kiro/skills/README.md" "$KIRO_DIR/skills/" 2>/dev/null || true
        cp "$SCRIPT_DIR/.kiro/skills/INDEX.md" "$KIRO_DIR/skills/" 2>/dev/null || true
        cp "$SCRIPT_DIR/.kiro/skills/ACTIVATION_GUIDE.md" "$KIRO_DIR/skills/" 2>/dev/null || true
        print_success "Kiro skills installed"
    else
        print_warning "Skills directory not found"
    fi
    
    # Copy hooks
    echo "Copying Kiro hooks..."
    if [[ -d "$SCRIPT_DIR/.kiro/hooks" ]]; then
        cp "$SCRIPT_DIR/.kiro/hooks"/*.md "$KIRO_DIR/hooks/"
        cp "$SCRIPT_DIR/.kiro/hooks"/*.kiro.hook "$KIRO_DIR/hooks/" 2>/dev/null || true
        chmod +x "$KIRO_DIR/hooks"/*.kiro.hook 2>/dev/null || true
        print_success "Kiro hooks installed"
    else
        print_warning "Hooks directory not found"
    fi
    
    # Step 7: Verify installation
    print_header "Step 7: Verifying Installation"
    
    local installed_files=0
    for file in "${required_files[@]}"; do
        local target_file="${file#.kiro/}"
        if [[ -f "$KIRO_DIR/$target_file" ]]; then
            installed_files=$((installed_files + 1))
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
    echo ""
    echo "1. Initialize AKR (admin only, run once):"
    echo "   bash $KIRO_DIR/scripts/setup_akr.sh"
    echo ""
    echo "2. Verify setup:"
    echo "   bash $KIRO_DIR/scripts/validate_knowledge.sh"
    echo ""
    echo "3. Start using AKR:"
    echo "   bash $KIRO_DIR/scripts/retrieve_knowledge.sh --type function --name \"my_function\""
    echo ""
    echo "4. Script reference:"
    echo "   cat $KIRO_DIR/scripts/README.md"
    echo ""
    echo "Installed components:"
    echo "   Scripts:  $KIRO_DIR/scripts/"
    echo "   Steering: $KIRO_DIR/steering/"
    echo "   Skills:   $KIRO_DIR/skills/"
    echo "   Hooks:    $KIRO_DIR/hooks/"
    echo ""
    
    if [[ $backed_up -gt 0 ]]; then
        echo "Previous files backed up to: $BACKUP_DIR"
        echo ""
    fi
    
    print_success "Installation finished!"
}

# Run main
main
exit 0
