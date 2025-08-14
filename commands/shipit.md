---
name: shipit
description: Prepare and push local changes following project contribution guidelines
args:
  - name: instruction
    description: Additional instruction for shipping changes
    required: false
---

# Ship It - Push Changes Following Project Guidelines

## Overview
Review and follow the project's contribution and release guidelines to properly ship local changes.

## Process

1. **Check Project Documentation**
   - Look for CLAUDE.md file for project-specific contribution/release instructions
   - Check for VERSION, CHANGELOG.md, package.json, or similar versioning files
   - Review README.md for contribution guidelines
   - Look for CONTRIBUTING.md or similar documentation

2. **Prepare Changes**
   - Run all tests and linting as specified in project documentation
   - Update version numbers consistently across all relevant files (VERSION, package.json, manifest.json, etc.)
   - Update CHANGELOG.md with a clear description of changes
   - Ensure all code quality standards are met

3. **Git Operations**
   - Stage all relevant changes
   - Create a descriptive commit message following project conventions
   - If working on a feature branch, rebase off main/master before pushing
   - Push changes to the appropriate branch

4. **Post-Push Actions**
   - Create pull request if required by project workflow
   - Follow any additional release procedures (tagging, publishing, etc.)

## Important Considerations
- Always check for and run pre-commit hooks or validation scripts
- Ensure cross-platform compatibility if specified
- Follow semantic versioning conventions
- Document any breaking changes clearly
- If no clear guidelines exist, follow common open-source conventions

## Additional Instructions
{{instruction}}

## Execution Steps
1. First, examine the project structure and existing documentation
2. Identify the release/contribution workflow from available documentation
3. Prepare all necessary file updates (version, changelog, etc.)
4. Run validation (tests, linting) before committing
5. Commit and push following identified conventions
6. Complete any post-push requirements (PR creation, etc.)

If no project-specific guidelines are found, create or update CLAUDE.md with reasonable defaults based on the project type and existing patterns.