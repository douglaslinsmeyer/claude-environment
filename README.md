# Claude Configuration Repository

A centralized repository for Claude commands, personas, and configuration files that can be easily shared across multiple computers and projects.

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
├── commands/             # Task-specific Claude commands
│   ├── coding/           # Development commands
│   ├── writing/          # Writing and documentation commands
│   └── analysis/         # Data analysis and research commands
├── personas/             # Role-based Claude configurations
├── templates/            # Project templates and boilerplates
├── snippets/             # Configuration snippets for injection
├── CLAUDE.md            # Main Claude configuration file (if injected)
├── settings.json        # Claude settings (if injected)
└── .claude-environment-manifest.json  # Installation and snippet tracking
```

## Installation Options

### Location Options
- `--global` - Install to `~/.claude` (default)
- `--local` - Install to current directory `./.claude`

### Component Options
- `--no-commands` - Skip command files
- `--no-personas` - Skip persona files
- `--no-templates` - Skip template files
- `--no-snippets` - Skip snippet files
- `--no-inject` - Skip snippet injection into settings.json and CLAUDE.md

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
After global installation, your commands and configurations are available system-wide:

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

## Configuration Snippets

The installer can automatically inject configuration snippets into your Claude settings files:

### Settings Snippet
Adds default Claude environment settings to your `settings.json`:
```json
{
  "claude-environment": {
    "version": "2.5.0",
    "features": {
      "auto-update-check": false,
      "snippet-injection": true
    },
    "defaults": {
      "file-naming": "kebab-case",
      "indentation": "spaces-2"
    }
  }
}
```

### CLAUDE.md Snippet
Appends development standards to your `CLAUDE.md` file:
- Development best practices
- Code quality requirements
- Git workflow guidelines

### Managing Snippets
```bash
# Install without snippet injection
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --no-inject

# Install without downloading snippets at all
curl -sSL https://raw.githubusercontent.com/douglaslinsmeyer/claude-environment/main/install.sh | bash -s -- --no-snippets
```

## Using Slash Commands

The installed commands can be used as slash commands in Claude Code. Once loaded, commands are available directly without any prefix scope.

### Coding Commands

#### `/code-review` - Review code for quality and best practices
```bash
# Review a specific file
/code-review src/main.py

# Review recent changes
/code-review analyze the recent changes in UserService

# Review code you paste or describe
/code-review check this function for security issues: [paste code]
```

#### `/debug` - Debug issues systematically
```bash
# Debug an error message
/debug TypeError: Cannot read property 'length' of undefined

# Debug with context
/debug my API returns 500 when I try to update a user

# Debug test failures
/debug test failing with timeout in user authentication spec
```

#### `/refactor` - Improve code structure and quality
```bash
# Refactor a specific component
/refactor improve the UserProfile.jsx component

# Refactor for a specific goal
/refactor optimize database queries in UserService

# Refactor code snippet
/refactor simplify this nested if-else chain: [paste code]
```

#### `/write-tests` - Generate comprehensive test suites
```bash
# Write tests for a function
/write-tests create tests for calculateDiscount function

# Write integration tests
/write-tests integration tests for user registration flow

# Write tests for pasted code
/write-tests unit tests for: [paste code]
```

#### `/generate-readme` - Generate accurate README.md from project analysis
```bash
# Generate README for current project
/generate-readme .

# Generate README for specific directory
/generate-readme ~/my-project

# Generate README with focus on specific aspects
/generate-readme analyze build process and dependencies in detail
```

### Writing Commands

#### `/documentation` - Create technical documentation
```bash
# Document an API
/documentation create API docs for user authentication endpoints

# Create a README
/documentation write README for my CLI tool that processes CSV files

# Document a feature
/documentation document real-time collaboration feature in our app
```

#### `/blog-post` - Write technical blog posts
```bash
# Write about a technology
/blog-post write about getting started with WebAssembly

# Write a tutorial
/blog-post tutorial on building a REST API with Node.js

# Write about your experience
/blog-post our journey migrating from monolith to microservices
```

#### `/email-draft` - Draft professional emails
```bash
# Project update email
/email-draft weekly status update for the mobile app project

# Meeting request
/email-draft meeting request to discuss API design with backend team

# Technical proposal
/email-draft proposal for adopting TypeScript in our frontend codebase
```

#### `/technical-article` - Write in-depth technical articles
```bash
# Architecture article
/technical-article explain event-driven microservices architecture

# Comparison article
/technical-article compare PostgreSQL vs MongoDB for our use case

# Best practices article
/technical-article best practices for securing REST APIs
```

### Analysis Commands

#### `/explore-data` - Perform exploratory data analysis
```bash
# Analyze a dataset
/explore-data analyze user_engagement_metrics.csv

# Analyze specific aspects
/explore-data find correlation between user age and purchase frequency

# Data quality check
/explore-data check customer database for inconsistencies
```

#### `/research-summary` - Research and summarize topics
```bash
# Technology research
/research-summary GraphQL adoption in enterprise applications

# Market research
/research-summary compare cloud storage solutions for our needs

# Best practices research
/research-summary microservices testing strategies and tools
```

#### `/trend-analysis` - Analyze trends and patterns
```bash
# Analyze metrics
/trend-analysis monthly active users over the last year

# Analyze performance
/trend-analysis API response times by endpoint over past quarter

# Market trends
/trend-analysis JavaScript framework popularity and trends in 2024
```

### Tips for Using Commands

1. **Personal commands**: These commands are installed in your personal Claude configuration
2. **Be specific**: The more context you provide in arguments, the better the output
3. **Natural language arguments**: Write arguments as you would describe the task naturally
4. **Combine with context**: You can paste code, logs, or data directly in your command arguments
5. **Chain commands**: Use multiple commands in sequence, like `/debug` followed by `/refactor`
6. **Customize output**: Add specific requirements to your command arguments
7. **Project-specific commands**: You can also create custom commands in any project's `.claude/commands/` directory

## Repository Structure

```
claude-config/
├── README.md              # This file
├── install.sh            # Installation script
├── VERSION               # Current version
├── manifest.json         # Installation manifest
├── commands/            # Claude command files
│   ├── coding/
│   │   ├── code-review.md
│   │   ├── debug.md
│   │   ├── generate-readme.md
│   │   ├── refactor.md
│   │   └── write-tests.md
│   ├── writing/
│   │   ├── blog-post.md
│   │   ├── documentation.md
│   │   ├── email-draft.md
│   │   └── technical-article.md
│   └── analysis/
│       ├── explore-data.md
│       ├── research-summary.md
│       └── trend-analysis.md
├── personas/             # Claude persona configurations
│   ├── senior-developer.md
│   ├── senior-devops-engineer.md
│   ├── cli-developer.md
│   ├── technical-writer.md
│   ├── data-analyst.md
│   ├── product-manager.md
│   └── researcher.md
├── claude-files/         # Main configuration files
│   ├── global-CLAUDE.md  # Default configuration
│   └── project-templates/
│       ├── web-dev-CLAUDE.md
│       └── data-science-CLAUDE.md
├── templates/            # Project templates
│   └── README-template.md
└── snippets/             # Configuration snippets
    ├── settings.json     # Settings snippet
    └── CLAUDE.md        # CLAUDE.md snippet
    ├── README-template.md
    ├── CLAUDE-template.md
    └── project-setup.md
```

## Customization

### Adding Your Own Files
1. Fork this repository
2. Add your commands to the appropriate directories
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
- **Snippet Injection**: Automatically merges configuration snippets
- **Manifest Tracking**: Single `.claude-environment-manifest.json` tracks all installed components and injected snippets
- **Backup Creation**: Automatic backups before modifying existing files

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

## Automated Release Process

This project uses a fully automated release process to ensure quality:

1. **Development**: Make changes and update VERSION file
2. **Testing**: Push to main triggers comprehensive CI/CD pipeline
3. **Release**: If all tests pass, the CI automatically:
   - Creates a git tag for the version
   - Generates release notes from CHANGELOG.md
   - Creates and publishes a GitHub release

This ensures that:
- Every release has passed all tests
- Releases are consistent and reproducible
- No manual intervention is required
- Version control is maintained automatically

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on how to contribute to this project.

## License

MIT License - feel free to fork and customize for your needs.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.