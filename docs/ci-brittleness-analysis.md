# CI Brittleness Analysis

## Issues Identified

### 1. Hard-coded Component Dependencies
**Problem**: Tests in `validation.bats` and CI workflow explicitly check for specific components (e.g., "claude-files") that may be removed or renamed.
**Impact**: When components are removed from the project, multiple test files need manual updates.
**Solution**: Tests should dynamically read the manifest.json to determine which components to validate.

### 2. Duplicated File Existence Checks
**Problem**: File existence checks are duplicated between:
- `tests/validation.bats`
- `.github/workflows/ci.yml` installation tests
- `install.sh` script itself

**Impact**: When file structure changes, multiple places need updates, leading to inconsistent failures.
**Solution**: Centralize validation logic in the test suite and have CI use those tests.

### 3. Static Test Data
**Problem**: The update test scenario uses hard-coded file paths (previously CLAUDE.md, now README-template.md).
**Impact**: If these files are removed or renamed, tests break.
**Solution**: The test should dynamically select a file from the manifest to test update behavior.

### 4. Missing Integration Between Tests and Implementation
**Problem**: The test suite doesn't automatically validate against the actual manifest structure.
**Impact**: Changes to manifest.json or install.sh can pass local tests but fail in CI.
**Solution**: Tests should read manifest.json and validate the actual structure.

## Recommendations

### 1. Dynamic Component Validation
Replace hard-coded component checks with dynamic validation:
```bash
# Instead of:
[[ "$components" == *"commands"* ]]
[[ "$components" == *"personas"* ]]

# Use:
while IFS= read -r component; do
    [[ -n "$component" ]] || continue
    # Validate component exists in manifest
done < <(jq -r '.components | keys[]' manifest.json)
```

### 2. Single Source of Truth
Create a test helper that reads manifest.json and provides:
- List of expected components
- List of expected files
- Component file counts

### 3. Test Data Generation
For update tests, dynamically select test files:
```bash
# Get first file from manifest
TEST_FILE=$(jq -r '.components[].files[0]' manifest.json | head -1)
```

### 4. CI Test Consolidation
Move all validation logic to BATS tests and have CI simply run:
```yaml
- name: Run all tests
  run: ./tests/run_bats_tests.sh
```

### 5. Add Manifest Schema Validation
Create a JSON schema for manifest.json and validate against it in tests to catch structural issues early.

### 6. Version Consistency Checks
Add automated checks to ensure version numbers are synchronized across:
- VERSION file
- manifest.json
- CHANGELOG.md
- Git tags

## Implementation Priority

1. **High**: Fix hard-coded component checks (completed)
2. **High**: Remove duplicate file existence validations
3. **Medium**: Implement dynamic test data selection
4. **Medium**: Add manifest schema validation
5. **Low**: Consolidate all CI tests into BATS