# Contributing to Claude Environment

Thank you for your interest in contributing to Claude Environment! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/claude-environment.git
   cd claude-environment
   ```
3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/douglaslinsmeyer/claude-environment.git
   ```
4. Install development dependencies:
   ```bash
   make setup
   ```
   This will install BATS, ShellCheck, Node.js, and other required tools.

## Development Process

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 2. Make Your Changes

- Follow the existing code style
- Add tests for new functionality
- Update documentation as needed
- Add your changes to `CHANGELOG.md` under the "Unreleased" section

### 3. Test Your Changes

```bash
# Run all tests
make test

# Run linting only
make lint

# Run validation only
make validate

# Run everything (recommended before committing)
make validate && make lint && make test
```

The test suite includes:
- File validation tests
- Installation tests (unit and integration)
- Version bump script tests
- ShellCheck linting for all shell scripts
- Version consistency checks

### 4. Commit Your Changes

We use [Conventional Commits](https://www.conventionalcommits.org/) for automatic versioning and changelog generation:

```bash
git commit -m "feat: add new command for X"
git commit -m "fix: correct parsing issue in Y"
git commit -m "docs: update README with Z"
```

Commit types and their version impact:
- `feat`: New feature (minor version bump)
- `fix`: Bug fix (patch version bump)
- `docs`: Documentation changes (patch version bump)
- `style`: Code style changes (patch version bump)
- `refactor`: Code refactoring (patch version bump)
- `perf`: Performance improvements (patch version bump)
- `test`: Test additions or changes (patch version bump)
- `build`: Build system changes (patch version bump)
- `ci`: CI/CD changes (patch version bump)
- `chore`: Maintenance tasks (no version bump)
- `revert`: Revert previous commit (patch version bump)

For breaking changes, add `!` after the type:
```bash
git commit -m "feat!: rename workflows directory to commands

BREAKING CHANGE: Users must update their installations"
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

## Pull Request Guidelines

### PR Title
Use the same conventional commit format for PR titles.

### PR Description
Include:
- What changes you made
- Why you made them
- Any breaking changes
- Related issues

### PR Checklist
- [ ] Tests pass locally
- [ ] New tests added for new features
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No debug code or console logs

## Code Style Guidelines

### Shell Scripts
- Use bash shebang: `#!/bin/bash`
- Set error handling: `set -e`
- Use meaningful variable names
- Quote variables: `"$var"` not `$var`
- Use `[[ ]]` for conditionals
- Include error handling
- Add comments for complex logic

### Markdown Files
- Use semantic headings (single H1, hierarchical H2-H6)
- Include code examples
- Use fenced code blocks with language hints
- Keep line length reasonable
- Use descriptive link text

## Testing Guidelines

### Writing Tests
- Use BATS for shell script testing
- Test both success and failure cases
- Test edge cases
- Keep tests isolated and independent
- Use descriptive test names

### Test Structure
```bash
@test "descriptive test name" {
    # Arrange
    setup_test_conditions
    
    # Act
    run_command_under_test
    
    # Assert
    [[ "$status" -eq 0 ]]
    [[ "$output" == "expected" ]]
}
```

## Adding New Components

### New Commands
1. Add the command file to appropriate subdirectory in `commands/`
2. Update `manifest.json` with the new file
3. Update the file list in `install.sh`
4. Add tests for the new command
5. Document in README if significant

### New Personas
1. Add the persona file to `personas/`
2. Update `manifest.json`
3. Update the file list in `install.sh`
4. Follow the existing persona structure

### New Templates
1. Add the template to appropriate directory
2. Update `manifest.json`
3. Update the file list in `install.sh`
4. Include usage instructions

## Changelog Updates

When making changes, update `CHANGELOG.md`:

1. Find the "Unreleased" section
2. Add your changes under the appropriate category:
   - **Added** for new features
   - **Changed** for changes in existing functionality
   - **Fixed** for bug fixes
   - **Removed** for removed features
3. Use bullet points and be descriptive
4. Reference issues/PRs when applicable

Example:
```markdown
### Added
- New Python debugging command for data science projects (#42)

### Fixed
- Fixed installation error on macOS when path contains spaces
```

## Release Process

Releases are automatically managed through our CI/CD pipeline:

### Automatic Release (Recommended)

When changes are merged to main, the pipeline will:
1. Analyze commit messages to determine version bump
2. Update VERSION and CHANGELOG.md automatically
3. Create a git tag
4. Generate and publish a GitHub release

This happens automatically based on your commit types:
- `feat:` commits trigger a minor version bump
- `fix:`, `docs:`, etc. trigger patch version bumps
- `feat!:` or `BREAKING CHANGE:` trigger major version bumps
- `chore:` commits don't trigger releases

### Manual Release (Legacy Process)

For special cases requiring manual version control:

1. Update version using the bump script:
   ```bash
   ./scripts/bump-version.sh [major|minor|patch]
   ```
2. Review and update the Unreleased section in CHANGELOG.md
3. Commit the version bump:
   ```bash
   git add VERSION CHANGELOG.md manifest.json
   git commit -m "chore: bump version to X.Y.Z"
   ```
4. Push to main:
   ```bash
   git push origin main
   ```

The CI/CD pipeline ensures releases are only created from code that has passed all quality checks.

## Questions?

If you have questions:
1. Check existing issues
2. Read the documentation
3. Open a new issue with the question label

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards others

Thank you for contributing!