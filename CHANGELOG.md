# Changelog

All notable changes to the Claude Environment project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/douglaslinsmeyer/claude-environment/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/douglaslinsmeyer/claude-environment/releases/tag/v1.0.0
