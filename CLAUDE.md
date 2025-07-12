# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Environment is a centralized repository for Claude commands, personas, and configuration files designed to be easily shared across multiple computers and projects. It provides a structured way to enhance Claude AI interactions through custom commands, personas, and templates.

## Key Architecture Concepts

### Component Structure
The project is organized into modular components that are installed via `install.sh`:
- **Commands**: Task-specific markdown files defining slash commands (e.g., `/code-review`, `/debug`)
- **Personas**: Role-based configurations that define Claude's expertise and communication style
- **Templates**: Project templates and boilerplates for common setups
- **Snippets**: Configuration fragments that can be injected into `CLAUDE.md` and `settings.json`

### Manifest System
- `manifest-source.json`: Contains glob patterns for file discovery
- `manifest.json`: Generated file with expanded file lists (via `npm run generate-manifest`)
- The manifest tracks all components and their files for installation

### Version Management
- Version is maintained in the `VERSION` file
- Version consistency must be maintained across `VERSION`, `manifest.json`, and `package.json`
- Semantic versioning is used with automated releases via GitHub Actions

## Development Commands

### Build and Generate
```bash
# Generate manifest.json from manifest-source.json (MUST run before committing)
npm run generate-manifest
# or
./scripts/generate-manifest.sh
```

### Testing
```bash
# Run all BATS tests
make test
# or
npm test

# Run specific test file
bats tests/install.bats
```

### Linting
```bash
# Run ShellCheck on all shell scripts
make lint
# or
npm run lint
```

### Validation
```bash
# Validate project files (empty files, manifest, permissions)
make validate
# or
npm run validate
```

### Version Management
```bash
# Bump version (updates VERSION, package.json, and triggers manifest generation)
./scripts/bump-version.sh patch|minor|major
```

### Installation Testing
```bash
# Test global installation
./install.sh --dry-run

# Test local installation
./install.sh --local --dry-run
```

## Development Guidelines

### Before Committing
1. Run tests: `make test`
2. Run linting: `make lint`
3. Generate manifest: `npm run generate-manifest`
4. Update CHANGELOG.md with your changes
5. Ensure version consistency across all files

### Adding New Components

#### New Commands
1. Create markdown file in appropriate subdirectory under `commands/`
2. Follow existing command structure (description, usage examples)
3. Update `manifest-source.json` if adding new directories
4. Run `npm run generate-manifest`

#### New Personas
1. Create markdown file in `personas/`
2. Define expertise areas and communication style
3. Run `npm run generate-manifest`

#### New Templates
1. Add template file to `templates/`
2. Run `npm run generate-manifest`

### Shell Script Standards
- All scripts must pass ShellCheck (`make lint`)
- Use POSIX-compliant features for cross-platform compatibility
- Avoid GNU-specific utilities or flags
- Test on both macOS (BSD) and Linux (GNU) environments

### Testing Requirements
- Write BATS tests for any new functionality
- Place tests in `tests/` directory
- Use `test-helpers.sh` for common test utilities
- Ensure tests work on both macOS and Linux

### Release Process
1. Make changes and update `VERSION` file
2. Update `CHANGELOG.md` with your changes
3. Run all tests and validation
4. Push to main branch
5. CI/CD automatically creates release if tests pass

## Special Considerations

### Cross-Platform Compatibility
- Scripts must work on macOS, Linux, and WSL
- Avoid platform-specific commands
- Use feature detection rather than OS detection

### Snippet Injection
- Snippets in `snippets/` can be automatically injected
- Injection markers: `<!-- SNIPPET_START -->` and `<!-- SNIPPET_END -->`
- The installer manages snippet versions and updates

### Manifest Generation
The manifest system is critical:
- Never edit `manifest.json` directly
- Always use `generate-manifest.sh` to update
- The manifest tracks exact file paths for reliable installation

### Installation Modes
- Global: Installs to `~/.claude/`
- Local: Installs to `./.claude/` in current directory
- Components can be selectively installed with flags

## Common Development Tasks

### Testing Installation Scenarios
```bash
# Test fresh install
./install.sh --dry-run --force

# Test update scenario
./install.sh --dry-run

# Test component exclusion
./install.sh --dry-run --no-personas --no-templates
```

### Debugging Installation Issues
```bash
# Verbose output
./install.sh --verbose

# Check manifest generation
./scripts/generate-manifest.sh --verbose
```

### Working with Snippets
```bash
# Test snippet injection
./scripts/snippet-manager.sh inject --dry-run

# List current snippets
./scripts/snippet-manager.sh list
```

## Important Notes

- The project uses Conventional Commits for semantic release
- All commits should follow the format: `type(scope): description`
- CI/CD runs on every push to main
- Releases are fully automated based on commit messages
- The installer script is the primary user interface - keep it robust and user-friendly