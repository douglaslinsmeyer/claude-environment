# Test Coverage Todo List

## High Priority - Core Functionality

### Installation Script Functions (`install.sh`)
- [ ] `get_remote_version()` - Network operations for version fetching
- [ ] `get_remote_manifest()` - Network operations for manifest fetching
- [ ] `confirm_action()` - User interaction prompts
- [ ] `get_special_mapping()` - Special file path handling
- [ ] `install_component()` - Full integration tests beyond dry run
- [ ] `print_error()` / `print_warning()` / `print_info()` - Output formatting
- [ ] Error handling for network failures (connection timeout, 404s, etc.)

### Error Handling & Edge Cases
- [ ] Installation with missing dependencies (no curl, no jq)
- [ ] Partial installation failures (some components fail mid-install)
- [ ] Installation with insufficient permissions
- [ ] Handling of corrupted manifest files
- [ ] Concurrent installation attempts
- [ ] Installation when disk space is low

## Medium Priority - Update & Migration

### Update Scenarios
- [ ] Downgrade scenarios (installing older version over newer)
- [ ] Major version migrations
- [ ] Handling of user-modified files during updates
- [ ] Force update with local changes
- [ ] Update with missing remote files
- [ ] Rollback capabilities after failed update

### Component Installation
- [ ] Individual component installation success paths
- [ ] Component installation with existing files
- [ ] Component removal/uninstall
- [ ] Component dependency handling

## Low Priority - Platform & Performance

### Cross-platform Compatibility
- [ ] WSL-specific installation paths
- [ ] BSD vs GNU utility differences (readlink, sed, etc.)
- [ ] File path handling with spaces
- [ ] Case sensitivity on different filesystems

### Performance & Security
- [ ] Installation speed with large file counts
- [ ] Memory usage during installation
- [ ] Input validation for malicious inputs
- [ ] File permission preservation
- [ ] Secure handling of temporary files

## Test Infrastructure Improvements
- [ ] Mock framework for curl operations
- [ ] Mock framework for file system operations
- [ ] Coverage reporting integration
- [ ] Performance benchmarking framework
- [ ] End-to-end test scenarios

## Notes
- Focus on simple, maintainable tests
- Use mocks for unit tests, avoid for integration tests
- Each test must pass before moving to the next
- Test the spirit of features, not minutiae