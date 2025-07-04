# Claude Configuration Repository

A centralized repository for Claude workflows, personas, and configuration files that can be easily shared across multiple computers and projects.

## Quick Install

**Global Installation (recommended):**
```bash
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash
```

**Local/Project Installation:**
```bash
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --local
```

## What Gets Installed

The installer creates a `.claude` directory with the following structure:

```
~/.claude/                 # Global installation
├── workflows/             # Task-specific Claude workflows
│   ├── coding/           # Development workflows
│   ├── writing/          # Writing and documentation workflows
│   └── analysis/         # Data analysis and research workflows
├── personas/             # Role-based Claude configurations
├── templates/            # Project templates and boilerplates
├── CLAUDE.md            # Main Claude configuration file
└── .claude-install-manifest  # Installation tracking
```

## Installation Options

### Location Options
- `--global` - Install to `~/.claude` (default)
- `--local` - Install to current directory `./.claude`

### Component Options
- `--no-workflows` - Skip workflow files
- `--no-personas` - Skip persona files
- `--no-templates` - Skip template files

### Other Options
- `--force` - Skip confirmation prompts
- `--dry-run` - Preview what would be installed
- `--version` - Show version information
- `--help` - Show help message

## Usage Examples

### Basic Installation
```bash
# Install everything globally
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash

# Install to current project without personas
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --local --no-personas

# Preview installation without making changes
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --dry-run
```

### Updates
The installer automatically detects existing installations and updates them:

```bash
# Same command updates existing installation
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash
```

## Using Your Claude Configuration

### Global Installation
After global installation, your workflows and configurations are available system-wide:

```bash
# Reference in any project
cd ~/my-project
# Your ~/.claude directory is now available to Claude
```

### Local Installation
For project-specific configurations:

```bash
cd ~/my-project
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --local
# Creates ./my-project/.claude with all your configurations
```

## Repository Structure

```
claude-config/
├── README.md              # This file
├── install.sh            # Installation script
├── VERSION               # Current version
├── manifest.json         # Installation manifest
├── workflows/            # Claude workflow files
│   ├── coding/
│   │   ├── debug-helper.md
│   │   ├── code-review.md
│   │   └── refactor-guide.md
│   ├── writing/
│   │   ├── blog-post.md
│   │   ├── documentation.md
│   │   └── email-draft.md
│   └── analysis/
│       ├── data-exploration.md
│       ├── research-summary.md
│       └── trend-analysis.md
├── personas/             # Claude persona configurations
│   ├── senior-developer.md
│   ├── technical-writer.md
│   ├── data-analyst.md
│   ├── product-manager.md
│   └── researcher.md
├── claude-files/         # Main configuration files
│   ├── global-CLAUDE.md  # Default configuration
│   └── project-templates/
│       ├── web-dev-CLAUDE.md
│       └── data-science-CLAUDE.md
└── templates/            # Project templates
    ├── README-template.md
    ├── CLAUDE-template.md
    └── project-setup.md
```

## Customization

### Adding Your Own Files
1. Fork this repository
2. Add your workflows to the appropriate directories
3. Update the `manifest.json` if needed
4. Commit and push your changes
5. Update your install URL to point to your fork

### Creating Workflows
Workflow files are Markdown files that provide Claude with specific instructions for different tasks. Example:

```markdown
# Code Review Workflow

You are an experienced senior developer conducting a thorough code review.

## Review Checklist
- Code functionality and logic
- Performance considerations
- Security implications
- Code style and readability
- Test coverage

## Output Format
Provide feedback in this structure:
1. **Summary**: Brief overall assessment
2. **Issues Found**: List of problems with severity levels
3. **Suggestions**: Specific improvement recommendations
4. **Praise**: Highlight what was done well
```

### Creating Personas
Persona files define specific roles for Claude to assume:

```markdown
# Senior Developer Persona

You are a senior software developer with 10+ years of experience.

## Expertise Areas
- Full-stack development
- System architecture
- Code optimization
- Team mentoring
- Technical decision making

## Communication Style
- Direct and practical
- Focus on best practices
- Provide actionable advice
- Share relevant experience
- Ask clarifying questions when needed
```

## Version Management

The system tracks installed versions and automatically handles updates:

- **Fresh Install**: Installs all components to chosen location
- **Update Detection**: Compares local vs remote versions
- **Clean Updates**: Removes old files before installing new ones
- **Conflict Handling**: Prompts before overwriting existing files

## Platform Support

- ✅ macOS
- ✅ Linux
- ✅ WSL (Windows Subsystem for Linux)
- ❌ Native Windows PowerShell (use WSL instead)

## System Requirements

### Required Tools
- **Bash**: Version 3.2+ (macOS default) or 4.0+ (recommended)
- **curl**: Any recent version with SSL support
- **Git**: Version 2.0+ (for development and contributions)

### Optional Tools
- **jq**: For JSON parsing (falls back to grep/sed if not available)
- **BATS**: Version 1.0+ (for running tests)

### Version Compatibility Notes
- The installer uses POSIX-compliant shell features for maximum compatibility
- All scripts are tested on both macOS (BSD utilities) and Linux (GNU utilities)
- No GNU-specific features are used to ensure cross-platform compatibility

## Troubleshooting

### Installation Issues
```bash
# Check if curl is available
curl --version

# Run with verbose output for debugging
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --dry-run

# Force reinstall
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --force
```

### Permission Issues
```bash
# Ensure target directory is writable
ls -la ~/.claude
chmod 755 ~/.claude

# For local installs, ensure current directory is writable
ls -la .
```

### Version Conflicts
```bash
# Check current installation
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --version

# Force update
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --force
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on how to contribute to this project.

## License

MIT License - feel free to fork and customize for your needs.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.