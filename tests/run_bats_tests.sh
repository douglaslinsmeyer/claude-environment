#!/bin/bash

# BATS test runner for Claude Environment
# Runs all BATS tests and provides summary

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test directory
TEST_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Claude Environment BATS Test Suite${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if bats is installed
if ! command -v bats >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ BATS is not installed${NC}"
    echo ""
    echo "Install BATS using one of these methods:"
    echo ""
    echo "macOS:"
    echo "  brew install bats-core"
    echo ""
    echo "Ubuntu/Debian:"
    echo "  sudo apt-get install bats"
    echo ""
    echo "From source:"
    echo "  git clone https://github.com/bats-core/bats-core.git"
    echo "  cd bats-core"
    echo "  ./install.sh /usr/local"
    echo ""
    echo -e "${RED}Tests cannot run without BATS${NC}"
    exit 1
fi

# Track results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a BATS test file
run_bats_file() {
    local test_name="$1"
    local test_file="$2"

    echo -e "\n${YELLOW}Running: $test_name${NC}"
    echo -e "${YELLOW}────────────────────────────────────────${NC}"

    # Run bats with TAP output for better parsing
    if output=$(bats "$test_file" 2>&1); then
        # Extract test counts from output
        local tests_run
        tests_run=$(echo "$output" | grep -E '^1\.\.[0-9]+' | sed 's/1\.\.//')
        local tests_passed
        tests_passed=$(echo "$output" | grep -c '^ok ')
        local tests_failed
        tests_failed=$(echo "$output" | grep -c '^not ok ')

        TOTAL_TESTS=$((TOTAL_TESTS + tests_run))
        PASSED_TESTS=$((PASSED_TESTS + tests_passed))
        FAILED_TESTS=$((FAILED_TESTS + tests_failed))

        if [[ $tests_failed -eq 0 ]]; then
            echo -e "${GREEN}✓ All tests passed ($tests_passed/$tests_run)${NC}"
        else
            echo -e "${RED}✗ Some tests failed ($tests_failed/$tests_run)${NC}"
            # Show failed test details
            echo "$output" | grep -A 2 '^not ok'
        fi
    else
        echo -e "${RED}✗ Test suite failed to run${NC}"
        echo "$output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Make test files executable
chmod +x "$TEST_DIR"/*.bats 2>/dev/null || true
chmod +x "$TEST_DIR"/*.sh 2>/dev/null || true

# Run BATS test suites
if [[ -f "$TEST_DIR/validation.bats" ]]; then
    run_bats_file "File Validation Tests" "$TEST_DIR/validation.bats"
fi

if [[ -f "$TEST_DIR/install.bats" ]]; then
    run_bats_file "Installation Tests" "$TEST_DIR/install.bats"
fi

# Run any additional .bats files
for bats_file in "$TEST_DIR"/*.bats; do
    [[ ! -f "$bats_file" ]] && continue
    [[ "$bats_file" == *"validation.bats" ]] && continue
    [[ "$bats_file" == *"install.bats" ]] && continue

    basename=$(basename "$bats_file" .bats)
    run_bats_file "$basename Tests" "$bats_file"
done

# Overall summary
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Overall Test Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Total tests run: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "\n${GREEN}All tests passed! ✨${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed. Please check the output above.${NC}"
    exit 1
fi