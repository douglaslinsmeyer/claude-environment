# Branch Protection Rules

This document describes the recommended branch protection rules for the `main` branch.

## Setting Up Branch Protection

1. Go to Settings → Branches in your GitHub repository
2. Add a branch protection rule for `main`
3. Configure the following settings:

### Required Settings

- ✅ **Require a pull request before merging**
  - ✅ Require approvals: 1
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from CODEOWNERS (if applicable)

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - Required status checks:
    - `CI / Validate Files`
    - `CI / ShellCheck`
    - `CI / BATS Tests (ubuntu-latest)`
    - `CI / BATS Tests (macos-latest)`
    - `CI / Test Installation (ubuntu-latest, global)`
    - `CI / Test Installation (ubuntu-latest, local)`
    - `CI / Test Installation (macos-latest, global)`
    - `CI / Test Installation (macos-latest, local)`
    - `CI / Test Update Scenario`
    - `CI / Test Dry Run`
    - `CI / All Tests`

- ✅ **Require conversation resolution before merging**

- ✅ **Require signed commits** (optional but recommended)

- ✅ **Include administrators** (recommended for consistency)

### Additional Protections

- ✅ **Do not allow bypassing the above settings**
- ✅ **Restrict who can push to matching branches** (optional)
  - Add specific users or teams if needed

## Workflow

1. Create a feature branch from `main`
   ```bash
   git checkout -b feature/my-feature
   ```

2. Make your changes and commit
   ```bash
   git add .
   git commit -m "feat: add new workflow"
   ```

3. Push to GitHub
   ```bash
   git push origin feature/my-feature
   ```

4. Create a Pull Request
   - All CI checks must pass
   - At least one approval required
   - All conversations must be resolved

5. Merge when ready
   - Use "Squash and merge" for clean history
   - Delete branch after merging

## Automated Checks

The following checks run automatically on every PR:

1. **File Validation**
   - All markdown files have content
   - JSON files are valid
   - File permissions are correct

2. **Shell Script Linting**
   - ShellCheck validates all shell scripts
   - No syntax errors
   - Best practices enforced

3. **Unit Tests**
   - Individual functions tested
   - Edge cases covered

4. **Integration Tests**
   - Full installation scenarios
   - Update scenarios
   - Multi-OS testing

5. **Installation Tests**
   - Global installation
   - Local installation
   - Dry run mode
   - Update functionality

## Bypassing Protection (Emergency Only)

In rare cases where protection needs to be bypassed:

1. Must be repository admin
2. Should document reason in commit message
3. Should create follow-up issue to fix any test failures
4. Should notify team members

## Monitoring

- Check Actions tab regularly for CI status
- Review test failure trends
- Update tests when adding new features
- Keep CI configuration up to date