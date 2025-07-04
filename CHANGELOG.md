# Changelog

All notable changes to the Claude Environment project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- BATS test suite for version bump script (11 tests)
- ShellCheck integration in test suite for linting shell scripts (10 tests)
- System requirements documentation in README
- Trap for temporary file cleanup in bump-version.sh

### Changed
- Updated Python minimum version from 3.8 to 3.9 in project-setup.md (Python 3.8 reached EOL in October 2024)
- Updated Node.js Docker images from version 18 to 22 (current LTS) in project-setup.md
- Pinned ludeeus/action-shellcheck to version 2.0.0 instead of using @master

### Fixed
- Fixed bump-version.sh script compatibility with macOS awk by removing GNU-specific match() syntax
- Fixed version mismatch between VERSION file (1.1.0) and manifest.json (was 1.0.0)
- Fixed install.sh output capture issue by redirecting print functions to stderr
- Fixed all ShellCheck warnings (SC2155) by declaring and assigning variables separately
- Fixed BATS test setup to work correctly in GitHub Actions environment

## [1.1.0] - 2025-01-04

### Added
- Comprehensive BATS test suite with 43 tests for installation script
- File validation tests to ensure project integrity
- CI/CD pipeline with GitHub Actions for automated testing
- Multi-OS testing support (Ubuntu, macOS)
- Branch protection documentation
- Test documentation in `tests/README.md`
- Release automation workflow
- CHANGELOG.md for tracking project changes
- CONTRIBUTING.md with development guidelines
- Version bump script (`scripts/bump-version.sh`)

### Changed
- Improved JSON parsing in `check_existing_installation()` to handle spaces in manifest files
- Updated test infrastructure to use BATS exclusively
- Enhanced error handling in version detection

### Fixed
- Fixed grep pattern to properly parse JSON with or without spaces
- Fixed BATS tests environment variable inheritance issues
- Corrected test execution for help and version flags

### Removed
- Legacy custom test framework files
- Redundant test implementations

## [1.0.0] - 2024-01-04

### Added
- Initial release of Claude Environment
- Comprehensive installation script (`install.sh`) with auto-update support
- 11 workflow files across three categories:
  - **Coding**: debug-helper, code-review, refactor-guide, test-writer
  - **Writing**: blog-post, documentation, email-draft, technical-article  
  - **Analysis**: data-exploration, research-summary, trend-analysis
- 5 specialized persona configurations:
  - Senior Developer
  - Technical Writer
  - Data Analyst
  - Product Manager
  - Researcher
- Project-specific CLAUDE.md templates:
  - Web Development
  - Data Science
  - Mobile App Development
- Project templates:
  - README template
  - CLAUDE template  
  - Project setup guide
- Installation options:
  - Global installation (`~/.claude`)
  - Local installation (`./.claude`)
  - Component selection flags (`--no-workflows`, `--no-personas`, `--no-templates`)
  - Dry run mode (`--dry-run`)
  - Force mode (`--force`)
- Version tracking and manifest system
- Automatic update detection and file cleanup
- Cross-platform support (macOS, Linux/WSL)
- Comprehensive documentation

[Unreleased]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/douglaslinsmeyer/claude-environment/releases/tag/v1.0.0