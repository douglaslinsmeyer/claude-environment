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
├── CLAUDE.md            # Main Claude configuration file
└── .claude-install-manifest  # Installation tracking
```

## Installation Options

### Location Options
- `--global` - Install to `~/.claude` (default)
- `--local` - Install to current directory `./.claude`

### Component Options
- `--no-commands` - Skip command files
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

## Using Slash Commands

The installed commands can be used as slash commands in Claude Code. Commands use the format `/<prefix>:<command-name> [arguments]` where prefix is either `project:` for project-specific commands or `user:` for personal commands. Since these are installed as personal commands, they use the `user:` prefix.

### Coding Commands

#### `/user:code-review` - Review code for quality and best practices
```bash
# Review a specific file
/user:code-review src/main.py

# Review recent changes
/user:code-review analyze the recent changes in UserService

# Review code you paste or describe
/user:code-review check this function for security issues: [paste code]
```

#### `/user:debug` - Debug issues systematically
```bash
# Debug an error message
/user:debug TypeError: Cannot read property 'length' of undefined

# Debug with context
/user:debug my API returns 500 when I try to update a user

# Debug test failures
/user:debug test failing with timeout in user authentication spec
```

#### `/user:refactor` - Improve code structure and quality
```bash
# Refactor a specific component
/user:refactor improve the UserProfile.jsx component

# Refactor for a specific goal
/user:refactor optimize database queries in UserService

# Refactor code snippet
/user:refactor simplify this nested if-else chain: [paste code]
```

#### `/user:write-tests` - Generate comprehensive test suites
```bash
# Write tests for a function
/user:write-tests create tests for calculateDiscount function

# Write integration tests
/user:write-tests integration tests for user registration flow

# Write tests for pasted code
/user:write-tests unit tests for: [paste code]
```

### Writing Commands

#### `/user:documentation` - Create technical documentation
```bash
# Document an API
/user:documentation create API docs for user authentication endpoints

# Create a README
/user:documentation write README for my CLI tool that processes CSV files

# Document a feature
/user:documentation document real-time collaboration feature in our app
```

#### `/user:blog-post` - Write technical blog posts
```bash
# Write about a technology
/user:blog-post write about getting started with WebAssembly

# Write a tutorial
/user:blog-post tutorial on building a REST API with Node.js

# Write about your experience
/user:blog-post our journey migrating from monolith to microservices
```

#### `/user:email-draft` - Draft professional emails
```bash
# Project update email
/user:email-draft weekly status update for the mobile app project

# Meeting request
/user:email-draft meeting request to discuss API design with backend team

# Technical proposal
/user:email-draft proposal for adopting TypeScript in our frontend codebase
```

#### `/user:technical-article` - Write in-depth technical articles
```bash
# Architecture article
/user:technical-article explain event-driven microservices architecture

# Comparison article
/user:technical-article compare PostgreSQL vs MongoDB for our use case

# Best practices article
/user:technical-article best practices for securing REST APIs
```

### Analysis Commands

#### `/user:explore-data` - Perform exploratory data analysis
```bash
# Analyze a dataset
/user:explore-data analyze user_engagement_metrics.csv

# Analyze specific aspects
/user:explore-data find correlation between user age and purchase frequency

# Data quality check
/user:explore-data check customer database for inconsistencies
```

#### `/user:research-summary` - Research and summarize topics
```bash
# Technology research
/user:research-summary GraphQL adoption in enterprise applications

# Market research
/user:research-summary compare cloud storage solutions for our needs

# Best practices research
/user:research-summary microservices testing strategies and tools
```

#### `/user:trend-analysis` - Analyze trends and patterns
```bash
# Analyze metrics
/user:trend-analysis monthly active users over the last year

# Analyze performance
/user:trend-analysis API response times by endpoint over past quarter

# Market trends
/user:trend-analysis JavaScript framework popularity and trends in 2024
```

### Tips for Using Commands

1. **Personal commands**: These commands are installed in your personal Claude configuration and use the `/user:` prefix
2. **Be specific**: The more context you provide in arguments, the better the output
3. **Natural language arguments**: Write arguments as you would describe the task naturally
4. **Combine with context**: You can paste code, logs, or data directly in your command arguments
5. **Chain commands**: Use multiple commands in sequence, like `/user:debug` followed by `/user:refactor`
6. **Customize output**: Add specific requirements to your command arguments
7. **Project-specific commands**: You can also create custom commands in any project's `.claude/commands/` directory using the `/project:` prefix

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
└── templates/            # Project templates
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