#!/bin/bash

# Claude Configuration Installer
# Installs Claude workflows, personas, and configuration files
# Works on macOS and Linux (including WSL)

set -e  # Exit on any error

# Default values
REPO_URL="https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main"
INSTALL_TYPE="global"
INSTALL_WORKFLOWS=true
INSTALL_PERSONAS=true
INSTALL_TEMPLATES=true
FORCE=false
DRY_RUN=false
MANIFEST_FILE=".claude-install-manifest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

# Show usage
show_usage() {
    cat << EOF
Claude Configuration Installer

USAGE:
    curl -sSL ${REPO_URL}/install.sh | bash [OPTIONS]

OPTIONS:
    --global          Install to ~/.claude (default)
    --local           Install to current directory
    --no-workflows    Skip workflow files
    --no-personas     Skip persona files  
    --no-templates    Skip template files
    --force           Skip confirmation prompts
    --dry-run         Show what would be installed without doing it
    --version         Show version info
    --help            Show this help message

EXAMPLES:
    # Global installation (default)
    curl -sSL ${REPO_URL}/install.sh | bash

    # Local installation without personas
    curl -sSL ${REPO_URL}/install.sh | bash -s -- --local --no-personas

    # Dry run to see what would be installed
    curl -sSL ${REPO_URL}/install.sh | bash -s -- --dry-run
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --global)
                INSTALL_TYPE="global"
                shift
                ;;
            --local)
                INSTALL_TYPE="local"
                shift
                ;;
            --no-workflows)
                INSTALL_WORKFLOWS=false
                shift
                ;;
            --no-personas)
                INSTALL_PERSONAS=false
                shift
                ;;
            --no-templates)
                INSTALL_TEMPLATES=false
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --version)
                show_version
                exit 0
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Get the target installation directory
get_install_dir() {
    if [[ "$INSTALL_TYPE" == "global" ]]; then
        echo "$HOME/.claude"
    else
        echo "$(pwd)/.claude"
    fi
}

# Download and parse the remote VERSION file
get_remote_version() {
    curl -sSfL "${REPO_URL}/VERSION" 2>/dev/null || echo "unknown"
}

# Download and parse the remote manifest
get_remote_manifest() {
    curl -sSfL "${REPO_URL}/manifest.json" 2>/dev/null || echo "{}"
}

# Show version information
show_version() {
    local remote_version=$(get_remote_version)
    echo "Claude Config Installer"
    echo "Remote version: $remote_version"
    
    local install_dir=$(get_install_dir)
    if [[ -f "$install_dir/$MANIFEST_FILE" ]]; then
        local installed_version=$(grep -o '"version":"[^"]*"' "$install_dir/$MANIFEST_FILE" | cut -d'"' -f4)
        echo "Installed version: $installed_version"
    else
        echo "Not currently installed"
    fi
}

# Check if installation exists and get version
check_existing_installation() {
    local install_dir=$(get_install_dir)
    local manifest_path="$install_dir/$MANIFEST_FILE"
    
    if [[ -f "$manifest_path" ]]; then
        local installed_version=$(grep -o '"version":"[^"]*"' "$manifest_path" | cut -d'"' -f4 2>/dev/null || echo "unknown")
        echo "$installed_version"
    else
        echo ""
    fi
}

# Confirm action with user
confirm_action() {
    local message="$1"
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    
    echo -e "${YELLOW}$message${NC}"
    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Download a file from the repository
download_file() {
    local remote_path="$1"
    local local_path="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would download: $remote_path -> $local_path"
        return 0
    fi
    
    # Create directory if it doesn't exist
    local dir=$(dirname "$local_path")
    mkdir -p "$dir"
    
    # Download the file
    if curl -sSfL "${REPO_URL}/${remote_path}" -o "$local_path" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Remove files listed in manifest
remove_old_files() {
    local install_dir="$1"
    local manifest_path="$install_dir/$MANIFEST_FILE"
    
    if [[ ! -f "$manifest_path" ]]; then
        return 0
    fi
    
    print_info "Removing old installation files..."
    
    # Extract file list from manifest and remove files
    if command -v jq >/dev/null 2>&1; then
        # Use jq if available
        jq -r '.files[]?' "$manifest_path" 2>/dev/null | while read -r file; do
            if [[ -n "$file" && -f "$install_dir/$file" ]]; then
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "Would remove: $install_dir/$file"
                else
                    rm -f "$install_dir/$file"
                fi
            fi
        done
    else
        # Fallback without jq (basic parsing)
        grep -o '"[^"]*\.md"' "$manifest_path" 2>/dev/null | sed 's/"//g' | while read -r file; do
            if [[ -f "$install_dir/$file" ]]; then
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "Would remove: $install_dir/$file"
                else
                    rm -f "$install_dir/$file"
                fi
            fi
        done
    fi
}

# Get list of files for a component
get_component_files() {
    local component="$1"
    local files=()
    
    case "$component" in
        "workflows")
            files=(
                "workflows/coding/debug-helper.md"
                "workflows/coding/code-review.md"
                "workflows/coding/refactor-guide.md"
                "workflows/coding/test-writer.md"
                "workflows/writing/blog-post.md"
                "workflows/writing/documentation.md"
                "workflows/writing/email-draft.md"
                "workflows/writing/technical-article.md"
                "workflows/analysis/data-exploration.md"
                "workflows/analysis/research-summary.md"
                "workflows/analysis/trend-analysis.md"
            )
            ;;
        "personas")
            files=(
                "personas/senior-developer.md"
                "personas/technical-writer.md"
                "personas/data-analyst.md"
                "personas/product-manager.md"
                "personas/researcher.md"
            )
            ;;
        "claude-files")
            files=(
                "claude-files/global-CLAUDE.md"
                "claude-files/project-templates/web-dev-CLAUDE.md"
                "claude-files/project-templates/data-science-CLAUDE.md"
                "claude-files/project-templates/mobile-app-CLAUDE.md"
            )
            ;;
        "templates")
            files=(
                "templates/README-template.md"
                "templates/CLAUDE-template.md"
                "templates/project-setup.md"
            )
            ;;
    esac
    
    printf '%s\n' "${files[@]}"
}

# Install component files
install_component() {
    local component="$1"
    local install_dir="$2"
    local file_count=0
    local failed_count=0
    
    # Check if component should be skipped
    case "$component" in
        "workflows")
            [[ "$INSTALL_WORKFLOWS" == "false" ]] && return 0
            ;;
        "personas")
            [[ "$INSTALL_PERSONAS" == "false" ]] && return 0
            ;;
        "templates")
            [[ "$INSTALL_TEMPLATES" == "false" ]] && return 0
            ;;
    esac
    
    # Get list of files for this component
    local files=($(get_component_files "$component"))
    
    # Special handling for CLAUDE.md
    if [[ "$component" == "claude-files" ]]; then
        local claude_file="$install_dir/CLAUDE.md"
        if [[ -f "$claude_file" && "$FORCE" == "false" && "$DRY_RUN" == "false" ]]; then
            if ! confirm_action "CLAUDE.md already exists. Overwrite it?"; then
                # Skip CLAUDE.md but continue with other files
                files=("${files[@]/claude-files\/global-CLAUDE.md/}")
            fi
        fi
    fi
    
    # Download each file
    for file in "${files[@]}"; do
        [[ -z "$file" ]] && continue
        
        local target_path="$install_dir/$file"
        
        # Special case: rename global-CLAUDE.md to CLAUDE.md
        if [[ "$file" == "claude-files/global-CLAUDE.md" ]]; then
            target_path="$install_dir/CLAUDE.md"
        fi
        
        if download_file "$file" "$target_path"; then
            ((file_count += 1))
            # Track the installed file
            if [[ "$file" == "claude-files/global-CLAUDE.md" ]]; then
                INSTALLED_FILES+=("CLAUDE.md")
            else
                INSTALLED_FILES+=("$file")
            fi
        else
            print_warning "Failed to download: $file"
            ((failed_count += 1))
        fi
    done
    
    if [[ $file_count -gt 0 ]]; then
        print_success "$component ($file_count files)"
    fi
    
    if [[ $failed_count -gt 0 ]]; then
        print_warning "$component ($failed_count files failed)"
    fi
    
    echo "$file_count"
}

# Track installed files globally
INSTALLED_FILES=()

# Create installation manifest
create_manifest() {
    local install_dir="$1"
    local version="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would create manifest file"
        return 0
    fi
    
    local manifest_path="$install_dir/$MANIFEST_FILE"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local components=()
    
    [[ "$INSTALL_WORKFLOWS" == "true" ]] && components+=("workflows")
    [[ "$INSTALL_PERSONAS" == "true" ]] && components+=("personas")
    components+=("claude-files")
    [[ "$INSTALL_TEMPLATES" == "true" ]] && components+=("templates")
    
    # Create manifest with file list
    cat > "$manifest_path" << EOF
{
  "version": "$version",
  "installed_at": "$timestamp",
  "install_type": "$INSTALL_TYPE",
  "components": [$(printf '"%s",' "${components[@]}" | sed 's/,$//')],
  "files": [$(printf '"%s",' "${INSTALLED_FILES[@]}" | sed 's/,$//')]
}
EOF
}

# Main installation function
main() {
    parse_args "$@"
    
    local install_dir=$(get_install_dir)
    local remote_version=$(get_remote_version)
    local existing_version=$(check_existing_installation)
    
    # Show what we're about to do
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN - No files will be modified"
    fi
    
    print_info "Installation directory: $install_dir"
    print_info "Remote version: $remote_version"
    
    # Check if already installed and up to date
    if [[ -n "$existing_version" && "$existing_version" == "$remote_version" && "$DRY_RUN" == "false" ]]; then
        print_success "claude-config v$existing_version already installed and up to date."
        exit 0
    fi
    
    # Determine if this is an install or update
    if [[ -n "$existing_version" ]]; then
        print_info "Updating claude-config from v$existing_version to v$remote_version..."
        remove_old_files "$install_dir"
    else
        print_info "Installing claude-config v$remote_version to $install_dir..."
    fi
    
    # Create installation directory
    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$install_dir"
    fi
    
    # Install components
    local total_files=0
    for component in "workflows" "personas" "claude-files" "templates"; do
        local count=$(install_component "$component" "$install_dir")
        ((total_files += count))
    done
    
    # Create manifest
    create_manifest "$install_dir" "$remote_version"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Dry run complete. Would install $total_files files."
    else
        print_success "Installation complete! Installed $total_files files."
        
        if [[ "$INSTALL_TYPE" == "global" ]]; then
            print_info "Files installed to: ~/.claude"
            print_info "Add ~/.claude to your Claude context in your projects"
        else
            print_info "Files installed to: ./.claude"
            print_info "This directory is ready for Claude context"
        fi
    fi
}

# Run main function with all arguments
main "$@"