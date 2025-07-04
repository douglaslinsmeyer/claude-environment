# Claude Environment Test Suite

This directory contains the BATS-based test suite for the Claude Environment installation system.

## Overview

The test suite uses BATS (Bash Automated Testing System) to ensure the reliability and correctness of the installation script and all associated files. Tests run automatically on every pull request and push to main.

## Test Structure

```
tests/
├── install.bats       # Installation tests (unit and integration)
├── validation.bats    # File and project validation tests
└── run_bats_tests.sh  # Test runner script
```

## Installing BATS

### macOS
```bash
brew install bats-core
```

### Ubuntu/Debian
```bash
sudo apt-get install bats
```

### From Source
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
```

## Running Tests

### Run All Tests
```bash
bash tests/run_bats_tests.sh
```

### Run Specific Test File
```bash
bats tests/install.bats
bats tests/validation.bats
```

### Run Tests in Docker
```bash
# Ubuntu
docker run --rm -v $(pwd):/work -w /work ubuntu:latest bash -c "apt-get update && apt-get install -y bats && bats tests/*.bats"

# Alpine
docker run --rm -v $(pwd):/work -w /work alpine:latest sh -c "apk add bats && bats tests/*.bats"
```

## Test Files

### install.bats
Tests for the installation script functionality:

**Unit Tests:**
- `get_install_dir()` - Installation directory resolution
- `parse_args()` - Command line argument parsing  
- `check_existing_installation()` - Version detection
- `get_component_files()` - File list generation
- `download_file()` - File download behavior
- `create_manifest()` - Manifest file creation
- `remove_old_files()` - Update cleanup logic

**Integration Tests:**
- Full installation scenarios (global/local)
- Selective installation with flags
- Dry run mode
- Update scenarios
- Error handling
- Help and version output

### validation.bats
Project validation tests:

- Markdown file validation
- JSON structure validation
- Script syntax checking
- File permissions
- Version format validation
- Installation instructions accuracy
- Project structure integrity
- No debug artifacts

## Writing New Tests

### Basic Test Structure
```bash
@test "description of what you're testing" {
    # Setup
    local test_value="something"
    
    # Execute
    result=$(function_to_test "$test_value")
    
    # Assert
    [[ "$result" == "expected" ]]
}
```

### Using Setup and Teardown
```bash
setup() {
    # Runs before each test
    export TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
}

teardown() {
    # Runs after each test
    cd "$ORIGINAL_DIR"
    rm -rf "$TEST_DIR"
}
```

### Common Assertions
```bash
# Basic assertions
[[ "$value" == "expected" ]]              # Equality
[[ "$value" != "unexpected" ]]            # Inequality
[[ -f "/path/to/file" ]]                  # File exists
[[ -d "/path/to/directory" ]]             # Directory exists
[[ -x "/path/to/executable" ]]            # File is executable

# String matching
[[ "$output" == *"substring"* ]]          # Contains substring
[[ "$string" =~ ^pattern$ ]]              # Regex match

# Numeric comparisons
[[ $number -eq 42 ]]                      # Equal
[[ $number -gt 10 ]]                      # Greater than
[[ $number -lt 100 ]]                     # Less than

# Exit status
run command_to_test
[[ "$status" -eq 0 ]]                     # Check exit code
[[ "$output" == "expected output" ]]      # Check output
```

### Skipping Tests
```bash
@test "test that needs special environment" {
    skip "Requires production environment"
    # Test code here won't run
}
```

## CI/CD Integration

Tests run automatically via GitHub Actions:

### Test Matrix
- **Operating Systems**: Ubuntu Latest, macOS Latest
- **Test Categories**: 
  - File validation
  - ShellCheck linting
  - BATS tests (all platforms)
  - Installation scenarios
  - Update testing
  - Dry run validation

### Required Status Checks
All of these must pass before merging:
1. `CI / Validate Files`
2. `CI / ShellCheck` 
3. `CI / BATS Tests (ubuntu-latest)`
4. `CI / BATS Tests (macos-latest)`
5. `CI / Test Installation (ubuntu-latest, global)`
6. `CI / Test Installation (ubuntu-latest, local)`
7. `CI / Test Installation (macos-latest, global)`
8. `CI / Test Installation (macos-latest, local)`
9. `CI / Test Update Scenario`
10. `CI / Test Dry Run`
11. `CI / All Tests`

## Debugging Failed Tests

### Verbose Output
```bash
# Run with extended test output
bats -t tests/install.bats

# Run with TAP output
bats --tap tests/install.bats
```

### Print Debugging
```bash
@test "debugging example" {
    echo "Debug value: $some_var" >&3
    # Test continues...
}
```

### Keep Test Artifacts
```bash
# In your test's teardown, comment out cleanup
teardown() {
    echo "Test directory: $TEST_DIR" >&3
    # rm -rf "$TEST_DIR"  # Commented out
}
```

### Run Single Test
```bash
# Run tests matching a pattern
bats tests/install.bats -f "get_install_dir"
```

## Common Issues

### BATS Not Found
```bash
# Check if BATS is in PATH
which bats

# Install BATS using appropriate method for your OS
```

### Permission Denied
```bash
# Make test files executable
chmod +x tests/*.bats tests/*.sh
```

### Test Timeout
Some tests may take longer on slower systems. Consider:
- Using `skip` for slow tests in CI
- Optimizing test setup/teardown
- Running tests in parallel when possible

## Best Practices

1. **Test Names**: Use descriptive test names that explain what's being tested
2. **Isolation**: Each test should be independent and not rely on others
3. **Cleanup**: Always clean up test artifacts in teardown
4. **Assertions**: Use clear assertions that make failures obvious
5. **Documentation**: Comment complex test logic
6. **Coverage**: Aim for comprehensive coverage of all functions and scenarios

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure all existing tests pass
3. Add appropriate test cases
4. Update this documentation if needed
5. Verify CI passes on your PR

## Resources

- [BATS Documentation](https://bats-core.readthedocs.io/)
- [BATS Tutorial](https://github.com/bats-core/bats-core/wiki/Tutorial)
- [BATS Best Practices](https://github.com/bats-core/bats-core/wiki/Best-Practices)