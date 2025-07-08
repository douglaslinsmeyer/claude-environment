# Changelog

All notable changes to the Claude Environment project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.3.0] - 2025-07-08

### Added
- New `/persona` command for adopting specific personas during interactions
  - Dynamically loads persona files from `./personas` directory
  - Provides helpful error messages with available personas list when persona not found
  - Supports persona switching throughout conversation
- Modern CI/CD pipeline with GitOps practices
  - Parallel test execution across OS and test suites
  - Intelligent caching for dependencies
  - Security scanning with Trivy
  - Performance metrics collection
  - Automated semantic versioning setup
- Development tooling improvements
  - Makefile for common tasks (test, lint, validate)
  - Custom GitHub Action for test environment setup
  - Dependabot configuration for automated updates
  - Commitlint for conventional commit enforcement
  - Semantic-release configuration for future automation
- Enhanced .gitignore for Node.js dependencies and test artifacts

### Changed
- Refactored CI/CD workflow for better performance and maintainability
  - Tests now run in parallel matrix (OS × test-suite)
  - Validation fails fast on basic issues
  - Release process is more streamlined
- Updated CONTRIBUTING.md with new development workflow
  - Added make commands for testing
  - Documented conventional commit guidelines
  - Updated release process documentation

## [2.2.2] - 2025-07-06

### Changed
- Optimized test suite for better efficiency and maintainability
  - Reduced install.bats from 48 to 34 tests (29% reduction) while maintaining full regression protection
  - Consolidated redundant test cases into comprehensive single tests
  - Removed tests that checked implementation details rather than behavior
  - Improved test structure by grouping similar scenarios

### Fixed
- Updated tests after claude-files component removal to ensure compatibility
- Fixed ShellCheck style issues in test files
- Restored executable permissions on test files

### Removed
- Redundant tests for get_component_files (4 tests → 1 comprehensive test)
- Duplicate get_remote_version error handling tests (3 tests → 1)
- Overly complex user interaction tests that tested implementation details
- Tests referencing non-existent claude-files component

## [2.2.1] - 2025-07-07

### Fixed
- Fixed failing tests by removing references to deprecated claude-files component
  - Updated manifest.json to remove deleted template files
  - Removed claude-files component from install.sh script
  - Removed obsolete test for claude-files in install.bats
- Fixed CI workflow failures
  - Removed hard-coded claude-files check from validation tests
  - Updated CI installation tests to remove CLAUDE.md verification
  - Changed update test to use README-template.md instead of removed CLAUDE.md
- Fixed ShellCheck warnings in test-helpers.sh by declaring variables separately from assignment
- Fixed install.sh to respect --force flag when version is already up to date

### Added
- CI brittleness analysis documentation with recommendations for improving test resilience
- Test helper script for dynamic manifest validation (tests/test-helpers.sh)
- JSON schema for manifest.json validation (tests/manifest-schema.json)
- Version consistency tests to ensure synchronization across files
- Dynamic component validation in tests - tests now adapt to manifest.json structure
- Improved CI test resilience with dynamic file verification

## [2.2.0] - 2025-07-07

### Added
- New `/generate-readme` command for generating accurate README.md files from project analysis
  - Analyzes project structure, dependencies, and configuration files
  - Creates documentation based on actual codebase state without embellishment
  - Located in commands/coding/ directory alongside other development commands

### Changed
- Updated documentation to reflect that slash commands do not require prefix scopes
  - Removed `/user:` prefix from all command examples in README
  - Commands are now documented as directly accessible (e.g., `/code-review` instead of `/user:code-review`)

### Removed
- Removed deprecated claude-files directory and its contents
  - global-CLAUDE.md moved to standard CLAUDE.md location
  - Project template files (data-science, mobile-app, web-dev)
  - prompt-best-practices.md
- Removed deprecated template files
  - CLAUDE-template.md
  - project-setup.md

## [2.1.1] - 2025-07-06

### Fixed
- Installation manifest (.claude-install-manifest) now correctly records all installed files
  - Fixed issue where INSTALLED_FILES array was being modified in a subshell
  - Changed install_component to use global variable for file count instead of echo
  - Manifest now properly tracks files for clean updates and removals

## [2.1.0] - 2025-07-06

### Added
- Special mappings support in manifest.json for file installation paths
  - Added `special_mappings` section to claude-files component
  - Allows mapping source files to different target paths (e.g., `global-CLAUDE.md` → `CLAUDE.md`)

### Changed
- Refactored install.sh to use manifest.json as single source of truth for file lists
  - Removed hard-coded file lists from installer
  - Installer now reads all file paths directly from manifest.json
  - **BREAKING**: Installer now requires manifest.json to be available (no fallback)
- Fixed CI workflow to check for "commands" directory instead of old "workflows" directory

### Fixed
- Trailing whitespace in install.sh and tests/install.bats
- Test failures due to missing manifest data in test setup

## [2.0.0] - 2025-07-06

### Added
- Comprehensive slash command usage documentation in README
  - Examples for all commands with slash command syntax
  - Natural language argument examples
  - Tips for effective command usage

### Changed
- **BREAKING**: Renamed "workflows" directory to "commands" for better CLI-focused terminology
  - Updated all references in manifest.json, install.sh, and test files
  - Updated installer flag from `--no-workflows` to `--no-commands`
  - Updated documentation to reflect new terminology
- Converted all command files to Claude Code slash command format
  - Added YAML frontmatter with descriptions to all commands
  - Rewrote commands to use `$ARGUMENTS` placeholder
  - Simplified command structure for better usability
  - Renamed some files for consistency (e.g., `debug-helper.md` → `debug.md`)

### Removed
- Removed verbose workflow instructions in favor of concise slash commands
- Removed detailed checklists and templates from command files

## [1.6.0] - 2025-07-06

### Added
- CLI Developer persona based on clig.dev principles
  - Comprehensive understanding of CLI design best practices
  - Focus on human-first design while maintaining UNIX composability
  - Expertise in CLI frameworks across multiple languages (Cobra, Clap, Click, Oclif)
  - Emphasis on error handling, progress feedback, and cross-platform compatibility
  - Includes terminal UI design and distribution strategies
- Enhanced code review command with additional review categories
  - Style & Conventions checks
  - Dependencies review
  - Version Control best practices
  - 12-Factor App and SOLID principles references

## [1.5.0] - 2025-07-06

### Added
- Prompt coaching feature to help engineers write better prompts
  - Added instructions in CLAUDE.md for providing constructive prompt feedback
  - Created comprehensive prompt-best-practices.md guide with examples
  - Includes specific tips for C#/.NET engineers
  - Features prompt templates for common tasks (code review, debugging, refactoring)

### Changed
- Updated Senior Developer persona to include C#/.NET expertise
  - Added C# as primary language alongside existing languages
  - Added ASP.NET Core, .NET 6/7/8, and Entity Framework Core
  - Added SQL Server and .NET ecosystem tools (NuGet, Visual Studio, xUnit, Reqnroll)
  - Added .NET-specific best practices including async/await patterns and SOLID principles

## [1.4.0] - 2025-07-06

### Added
- Senior DevOps Engineer persona with expertise in cloud platforms, infrastructure as code, and automation
  - Includes expertise in AWS, GCP, Azure, and multi-cloud architectures
  - Covers modern DevOps tools: Terraform, Kubernetes, Docker, CI/CD pipelines
  - Features monitoring tools including Prometheus, Grafana, ELK stack, and Signoz
  - Includes service mesh technologies: Cilium, Istio, and Linkerd
  - Comprehensive secrets management: Vault, Azure Key Vault, AWS Secrets Manager

## [1.3.0] - 2025-07-03

### Added
- GH_TOKEN environment variable in CI workflow for GitHub release creation

### Changed
- Consolidated release workflow into main CI pipeline
- Release creation now happens automatically after all tests pass
- Updated validation tests to check for release functionality in CI workflow

### Fixed
- YAML syntax error caused by heredoc (<<EOF) in GitHub Actions workflow
- BATS compatibility issues with older versions (removed 'run !' syntax)
- ShellCheck warnings in validation tests (SC2314)
- Missing release.yml test updated to verify CI workflow contains release steps

### Removed
- Separate release.yml workflow (functionality moved to CI workflow)

## [1.2.0] - 2025-07-03

### Added
- BATS test suite for version bump script (11 tests)
- ShellCheck integration in test suite for linting shell scripts (10 tests)
- System requirements documentation in README
- Trap for temporary file cleanup in bump-version.sh
- Automated release process - CI creates tags and releases after tests pass

### Changed
- Updated Python minimum version from 3.8 to 3.9 in project-setup.md (Python 3.8 reached EOL in October 2024)
- Updated Node.js Docker images from version 18 to 22 (current LTS) in project-setup.md
- Pinned ludeeus/action-shellcheck to version 2.0.0 instead of using @master
- Simplified release process - CI now creates both tags and releases after all tests pass
- Removed separate release workflow, everything handled in single CI pipeline

### Fixed
- Fixed bump-version.sh script compatibility with macOS awk by removing GNU-specific match() syntax
- Fixed version mismatch between VERSION file (1.1.0) and manifest.json (was 1.0.0)
- Fixed install.sh output capture issue by redirecting print functions to stderr
- Fixed all ShellCheck warnings (SC2155) by declaring and assigning variables separately
- Fixed BATS test setup to work correctly in GitHub Actions environment
- Fixed macOS compatibility by replacing mapfile with portable while/read loop
- Fixed broken pipe errors in get_component_files by checking array length

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

[Unreleased]: https://github.com/douglaslinsmeyer/claude-environment/compare/v2.3.0...HEAD
[2.3.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v2.2.2...v2.3.0
[2.2.2]: https://github.com/douglaslinsmeyer/claude-environment/compare/v2.2.0...v2.2.2
[2.2.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v2.1.1...v2.2.0
[2.1.1]: https://github.com/douglaslinsmeyer/claude-environment/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.6.0...v2.0.0
[1.6.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/douglaslinsmeyer/claude-environment/releases/tag/v1.0.0
