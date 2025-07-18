#!/bin/bash

# Claude Configuration Installer
# Installs Claude commands, personas, and configuration files
# Works on macOS and Linux (including WSL)

set -e  # Exit on any error

# Default values
# Allow REPO_URL to be overridden by environment variable (useful for CI/testing)
REPO_URL="${CLAUDE_ENV_REPO_URL:-https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main}"
INSTALL_TYPE="global"
INSTALL_COMMANDS=true
INSTALL_PERSONAS=true
INSTALL_TEMPLATES=true
INSTALL_SNIPPETS=true
INJECT_SNIPPETS=true
FORCE=false
DRY_RUN=false
MANIFEST_FILE=".claude-environment-manifest.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_success() { echo -e "${GREEN}✓${NC} $1" >&2; }
print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1" >&2; }
print_info() { echo -e "${BLUE}ℹ${NC} $1" >&2; }

# Show usage
show_usage() {
    cat << EOF >&2
Claude Configuration Installer

USAGE:
    curl -sSL ${REPO_URL}/install.sh | bash [OPTIONS]

OPTIONS:
    --global          Install to ~/.claude (default)
    --local           Install to current directory
    --no-commands     Skip command files
    --no-personas     Skip persona files
    --no-templates    Skip template files
    --no-snippets     Skip snippet files
    --no-inject       Skip snippet injection into settings.json and CLAUDE.md
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
            --no-commands)
                INSTALL_COMMANDS=false
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
            --no-snippets)
                INSTALL_SNIPPETS=false
                shift
                ;;
            --no-inject)
                INJECT_SNIPPETS=false
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

# Cache manifest data globally
MANIFEST_DATA=""

# Load manifest data
load_manifest_data() {
    if [[ -z "$MANIFEST_DATA" ]]; then
        MANIFEST_DATA=$(get_remote_manifest)
    fi
}

# Show version information
show_version() {
    local remote_version
    remote_version=$(get_remote_version)
    echo "Claude Config Installer" >&2
    echo "Remote version: $remote_version" >&2

    local install_dir
    install_dir=$(get_install_dir)
    if [[ -f "$install_dir/$MANIFEST_FILE" ]]; then
        local installed_version
        if command -v jq >/dev/null 2>&1; then
            installed_version=$(jq -r '.installation.version // empty' "$install_dir/$MANIFEST_FILE" 2>/dev/null || echo "unknown")
        else
            installed_version=$(grep -A5 '"installation"' "$install_dir/$MANIFEST_FILE" | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' 2>/dev/null || echo "unknown")
        fi
        echo "Installed version: $installed_version" >&2
    else
        echo "Not currently installed" >&2
    fi
}

# Check if installation exists and get version
check_existing_installation() {
    local install_dir
    install_dir=$(get_install_dir)
    local manifest_path="$install_dir/$MANIFEST_FILE"

    if [[ -f "$manifest_path" ]]; then
        local installed_version
        # Extract version from installation.version in new structure
        if command -v jq >/dev/null 2>&1; then
            installed_version=$(jq -r '.installation.version // empty' "$manifest_path" 2>/dev/null || echo "unknown")
        else
            # Fallback grep for installation.version
            installed_version=$(grep -A5 '"installation"' "$manifest_path" | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' 2>/dev/null || echo "unknown")
        fi
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
    local dir
    dir=$(dirname "$local_path")
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
        # Use jq if available - now reading from installation.files
        jq -r '.installation.files[]?' "$manifest_path" 2>/dev/null | while read -r file; do
            if [[ -n "$file" && -f "$install_dir/$file" ]]; then
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "Would remove: $install_dir/$file"
                else
                    rm -f "$install_dir/$file"
                fi
            fi
        done
    else
        # Fallback without jq - find files array in installation section
        sed -n '/installation.*{/,/^[[:space:]]*}/p' "$manifest_path" | grep -o '"[^"]*\.\(md\|json\)"' | sed 's/"//g' | while read -r file; do
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

# Get list of files for a component from manifest
get_component_files() {
    local component="$1"

    # Manifest is required - no fallback
    if [[ -z "$MANIFEST_DATA" ]]; then
        print_error "Unable to load manifest data"
        return 1
    fi

    if command -v jq >/dev/null 2>&1; then
        # Use jq to parse the manifest
        echo "$MANIFEST_DATA" | jq -r ".components.\"$component\".files[]?" 2>/dev/null
    else
        # Basic parsing without jq
        # Extract the component section and parse files
        local in_component=false
        local in_files=false
        local brace_count=0

        while IFS= read -r line; do
            # Look for the component section
            if [[ "$line" =~ \"$component\" ]]; then
                in_component=true
            fi

            if [[ "$in_component" == true ]]; then
                # Track braces to know when we're in the files array
                if [[ "$line" =~ \"files\"[[:space:]]*: ]]; then
                    in_files=true
                fi

                if [[ "$in_files" == true ]]; then
                    # Extract file paths from quotes
                    if [[ "$line" =~ \"([^\"]+\.md)\" ]]; then
                        echo "${BASH_REMATCH[1]}"
                    fi

                    # Check if we've reached the end of this component
                    if [[ "$line" =~ \}[[:space:]]*$ ]]; then
                        ((brace_count++))
                        if [[ $brace_count -ge 2 ]]; then
                            break
                        fi
                    fi
                fi
            fi
        done <<< "$MANIFEST_DATA"
    fi
}

# Get special mappings for a component from manifest
get_special_mapping() {
    local component="$1"
    local file="$2"

    if [[ -z "$MANIFEST_DATA" ]]; then
        return 0
    fi

    if command -v jq >/dev/null 2>&1; then
        # Use jq to get the special mapping
        echo "$MANIFEST_DATA" | jq -r ".components.\"$component\".special_mappings.\"$file\"? // empty" 2>/dev/null
    fi
}

# Install component files
install_component() {
    local component="$1"
    local install_dir="$2"
    local file_count=0
    local failed_count=0

    # Check if component should be skipped
    case "$component" in
        "commands")
            [[ "$INSTALL_COMMANDS" == "false" ]] && return 0
            ;;
        "personas")
            [[ "$INSTALL_PERSONAS" == "false" ]] && return 0
            ;;
        "templates")
            [[ "$INSTALL_TEMPLATES" == "false" ]] && return 0
            ;;
        "snippets")
            [[ "$INSTALL_SNIPPETS" == "false" ]] && return 0
            ;;
    esac

    # Get list of files for this component
    local files=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && files+=("$file")
    done < <(get_component_files "$component")


    # Download each file
    for file in "${files[@]}"; do
        [[ -z "$file" ]] && continue

        local target_path="$install_dir/$file"

        # Check for special mapping
        local special_target
        special_target=$(get_special_mapping "$component" "$file")
        if [[ -n "$special_target" ]]; then
            target_path="$install_dir/$special_target"
        fi

        if download_file "$file" "$target_path"; then
            ((file_count += 1))
        else
            print_warning "Failed to download: $file"
            ((failed_count += 1))
            continue
        fi

        # Track the installed file (even in dry-run mode)
        if [[ -n "$special_target" ]]; then
            INSTALLED_FILES+=("$special_target")
        else
            INSTALLED_FILES+=("$file")
        fi
    done

    if [[ $file_count -gt 0 ]]; then
        print_success "$component ($file_count files)"
    fi

    if [[ $failed_count -gt 0 ]]; then
        print_warning "$component ($failed_count files failed)"
    fi

    # Return the count via global variable instead of echo to avoid subshell issues
    COMPONENT_FILE_COUNT=$file_count
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
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local components=()

    [[ "$INSTALL_COMMANDS" == "true" ]] && components+=("commands")
    [[ "$INSTALL_PERSONAS" == "true" ]] && components+=("personas")
    [[ "$INSTALL_TEMPLATES" == "true" ]] && components+=("templates")
    [[ "$INSTALL_SNIPPETS" == "true" ]] && components+=("snippets")

    # Create manifest with new structure
    cat > "$manifest_path.tmp" << EOF
{
  "_meta": {
    "manifest_version": "1.0",
    "generated_at": "$timestamp"
  },
  "installation": {
    "version": "$version",
    "installed_at": "$timestamp",
    "install_type": "$INSTALL_TYPE",
    "components": [$(printf '"%s",' "${components[@]}" | sed 's/,$//')],
    "files": [$(printf '"%s",' "${INSTALLED_FILES[@]}" | sed 's/,$//')]
  },
  "snippets": {
    "injected": {}
  }
}
EOF
    
    # Atomic move
    mv "$manifest_path.tmp" "$manifest_path"
}

# Process snippet injections
process_snippet_injections() {
    local install_dir="$1"
    local remote_version="$2"
    
    if [[ "$INJECT_SNIPPETS" == "false" ]]; then
        return 0
    fi
    
    print_info "Processing snippet injections..."
    
    # Download snippet manager to a temporary location
    local temp_dir
    temp_dir=$(mktemp -d)
    local snippet_manager="$temp_dir/snippet-manager.sh"
    
    if download_file "scripts/snippet-manager.sh" "$snippet_manager"; then
        if [[ "$DRY_RUN" == "false" ]]; then
            chmod +x "$snippet_manager"
        fi
    else
        print_warning "Could not download snippet manager, skipping injections"
        rm -rf "$temp_dir"
        return 0
    fi
    
    # Find all downloaded snippet files
    local snippets_processed=0
    local settings_target="$install_dir/settings.json"
    local claude_target="$install_dir/CLAUDE.md"
    
    # Process settings.json snippet
    if [[ -f "$install_dir/snippets/settings.json" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            "$snippet_manager" inject "$install_dir/snippets/settings.json" "$settings_target" true
        else
            if ! "$snippet_manager" inject "$install_dir/snippets/settings.json" "$settings_target"; then
                print_warning "Failed to inject settings.json snippet"
            else
                ((snippets_processed++)) || true
            fi
        fi
    fi
    
    # Process CLAUDE.md snippet
    if [[ -f "$install_dir/snippets/CLAUDE.md" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            "$snippet_manager" inject "$install_dir/snippets/CLAUDE.md" "$claude_target" true
        else
            if ! "$snippet_manager" inject "$install_dir/snippets/CLAUDE.md" "$claude_target"; then
                print_warning "Failed to inject CLAUDE.md snippet"
            else
                ((snippets_processed++)) || true
            fi
        fi
    fi
    
    if [[ $snippets_processed -gt 0 ]]; then
        print_success "Processed $snippets_processed snippet injections"
    fi
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
}

# Main installation function
main() {
    parse_args "$@"

    # Reset installed files tracking
    INSTALLED_FILES=()

    # Load manifest data early
    load_manifest_data

    local install_dir
    install_dir=$(get_install_dir)
    local remote_version
    remote_version=$(get_remote_version)
    local existing_version
    existing_version=$(check_existing_installation)

    # Show what we're about to do
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN - No files will be modified"
    fi

    print_info "Installation directory: $install_dir"
    print_info "Remote version: $remote_version"

    # Check if already installed and up to date
    if [[ -n "$existing_version" && "$existing_version" == "$remote_version" && "$DRY_RUN" == "false" && "$FORCE" == "false" ]]; then
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
    COMPONENT_FILE_COUNT=0
    for component in "commands" "personas" "templates" "snippets"; do
        install_component "$component" "$install_dir"
        ((total_files += COMPONENT_FILE_COUNT))
    done

    # Create manifest
    create_manifest "$install_dir" "$remote_version"
    
    # Process snippet injections
    process_snippet_injections "$install_dir" "$remote_version"

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

# Run main function with all arguments (unless being sourced for testing)
if [[ "${CLAUDE_ENV_TESTING:-false}" != "true" ]]; then
    main "$@"
fi