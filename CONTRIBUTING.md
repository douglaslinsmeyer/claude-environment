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

Run the test suite:
```bash
# Install BATS if you haven't already
brew install bats-core  # macOS
# or
sudo apt-get install bats  # Ubuntu/Debian

# Install ShellCheck for linting
brew install shellcheck  # macOS
# or
sudo apt-get install shellcheck  # Ubuntu/Debian

# Run tests
bash tests/run_bats_tests.sh
```

The test suite now includes:
- File validation tests
- Installation tests
- Version bump script tests
- ShellCheck linting for all shell scripts

### 4. Commit Your Changes

Follow conventional commit format:
```bash
git commit -m "feat: add new command for X"
git commit -m "fix: correct parsing issue in Y"
git commit -m "docs: update README with Z"
```

Commit types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions or changes
- `chore`: Maintenance tasks
- `refactor`: Code refactoring

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

Releases are automatically created after all CI tests pass on the main branch:

1. Update version using the bump script:
   ```bash
   ./scripts/bump-version.sh [major|minor|patch]
   ```
2. Review and update the Unreleased section in CHANGELOG.md with your changes
3. Commit the version bump:
   ```bash
   git add VERSION CHANGELOG.md
   git commit -m "chore: bump version to X.Y.Z"
   ```
4. Push to main:
   ```bash
   git push origin main
   ```
5. The CI/CD pipeline will automatically:
   - Run all tests (unit, integration, linting)
   - If all tests pass, create a git tag for the version
   - Create a GitHub release with changelog content
   - Publish the release with installation instructions

This ensures that releases are only created from code that has passed all quality checks.

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